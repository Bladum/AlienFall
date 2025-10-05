local SafeIO = require("utils.safe_io")

local AssetCache = {}
AssetCache.__index = AssetCache

--- Asset type detection patterns
local ASSET_PATTERNS = {
    image = {"%.png$", "%.jpg$", "%.jpeg$", "%.bmp$", "%.tga$"},
    audio = {"%.ogg$", "%.wav$", "%.mp3$"},
    font = {"%.ttf$", "%.otf$"},
    shader = {"%.glsl$", "%.vert$", "%.frag$"}
}

function AssetCache.new(opts)
    local self = setmetatable({}, AssetCache)
    opts = opts or {}
    
    self.assets = {}
    self.telemetry = opts.telemetry
    self.logger = opts.logger
    self.maxSize = opts.maxSize or 100  -- Max items per kind
    self.maxMemoryMB = opts.maxMemoryMB or 256  -- Total memory limit
    self.accessTimes = {}  -- Track LRU for eviction
    self.accessCounter = 0  -- Monotonic counter for LRU
    self.modSearchPaths = {"mods/"}  -- Mod directories to search
    self.assetRegistry = {}  -- Map of asset ID to file path
    self.lazyLoad = opts.lazyLoad ~= false  -- Lazy loading enabled by default
    
    if self.logger then
        self.logger:info("AssetCache initialized with max size: " .. self.maxSize)
    end
    
    return self
end

local function loadImage(path)
    -- Use safe loading with fallback
    return SafeIO.safe_load_image(path)
end

local function loadFont(path, size)
    -- Use safe loading with fallback
    return SafeIO.safe_load_font(path, size)
end

--- Evict least recently used asset from a kind
-- @param kind string: Asset kind to evict from
local function evictLRU(self, kind)
    local bucket = self.assets[kind]
    local accessBucket = self.accessTimes[kind]
    
    if not bucket or not accessBucket then
        return
    end
    
    -- Find least recently used asset
    local lruKey = nil
    local lruTime = math.huge
    
    for key, accessTime in pairs(accessBucket) do
        if accessTime < lruTime then
            lruTime = accessTime
            lruKey = key
        end
    end
    
    if lruKey then
        bucket[lruKey] = nil
        accessBucket[lruKey] = nil
        
        if self.telemetry then
            self.telemetry:recordEvent({
                type = "asset-evicted",
                kind = kind,
                key = lruKey
            })
        end
    end
end

function AssetCache:fetch(kind, key, loader)
    assert(type(kind) == "string" and kind ~= "", "asset kind must be string")
    assert(type(key) == "string" and key ~= "", "asset key must be string")

    if not self.assets[kind] then
        self.assets[kind] = {}
    end
    
    if not self.accessTimes[kind] then
        self.accessTimes[kind] = {}
    end

    local bucket = self.assets[kind]
    local accessBucket = self.accessTimes[kind]
    
    -- Cache hit - update access time and return
    if bucket[key] then
        self.accessCounter = self.accessCounter + 1
        accessBucket[key] = self.accessCounter
        
        if self.telemetry then
            self.telemetry:recordEvent({
                type = "asset-cache-hit",
                kind = kind,
                key = key
            })
        end
        
        return bucket[key]
    end

    -- Cache miss - load resource
    local resource
    local loadSuccess = false
    
    if loader then
        -- Use custom loader with error handling
        local ok, result = pcall(loader)
        if ok then
            resource = result
            loadSuccess = true
        else
            print("[ERROR] Custom loader failed for " .. kind .. ":" .. key .. " - " .. tostring(result))
        end
    else
        -- Use default loaders based on kind
        if kind == "image" then
            resource = loadImage(key)
            loadSuccess = true
        elseif kind == "font" then
            -- Parse size from key if present (e.g., "path/to/font.ttf:16")
            local fontPath, sizeStr = key:match("([^:]+):?(%d*)")
            local size = tonumber(sizeStr) or 12
            resource = loadFont(fontPath, size)
            loadSuccess = true
        else
            print("[ERROR] No loader for asset kind: " .. kind)
            return nil
        end
    end
    
    if not loadSuccess or not resource then
        return nil
    end

    -- Check if cache is full and evict LRU if needed
    local count = 0
    for _ in pairs(bucket) do
        count = count + 1
    end
    
    if count >= self.maxSize then
        evictLRU(self, kind)
    end

    -- Store in cache with access time
    bucket[key] = resource
    self.accessCounter = self.accessCounter + 1
    accessBucket[key] = self.accessCounter

    if self.telemetry then
        self.telemetry:recordEvent({
            type = "asset-loaded",
            kind = kind,
            key = key
        })
    end

    return resource
end

--- Clear all cached assets
function AssetCache:flush()
    self.assets = {}
    self.accessTimes = {}
    self.accessCounter = 0
end

--- Clear assets of a specific kind
-- @param kind string: Asset kind to clear
function AssetCache:flushKind(kind)
    if self.assets[kind] then
        self.assets[kind] = {}
    end
    if self.accessTimes[kind] then
        self.accessTimes[kind] = {}
    end
end

--- Get cache statistics
-- @return table: Statistics about cache usage
function AssetCache:getStats()
    local stats = {
        totalAssets = 0,
        registeredAssets = 0,
        byKind = {}
    }
    
    for kind, bucket in pairs(self.assets) do
        local count = 0
        for _ in pairs(bucket) do
            count = count + 1
        end
        stats.byKind[kind] = count
        stats.totalAssets = stats.totalAssets + count
    end
    
    -- Count registered assets
    for _ in pairs(self.assetRegistry) do
        stats.registeredAssets = stats.registeredAssets + 1
    end
    
    return stats
end

--- Detect asset type from file extension
-- @param filename string: File name or path
-- @return string: Asset type or nil
function AssetCache:detectAssetType(filename)
    for assetType, patterns in pairs(ASSET_PATTERNS) do
        for _, pattern in ipairs(patterns) do
            if filename:match(pattern) then
                return assetType
            end
        end
    end
    return nil
end

--- Scan mod directory for assets
-- @param modPath string: Path to mod directory
-- @return table: Map of asset ID -> {path, type}
function AssetCache:scanModAssets(modPath)
    local assets = {}
    
    -- Check if directory exists
    local info = love.filesystem.getInfo(modPath)
    if not info or info.type ~= "directory" then
        if self.logger then
            self.logger:warn("AssetCache: Mod path not found: " .. modPath)
        end
        return assets
    end
    
    -- Scan assets directory
    local assetsPath = modPath .. "/assets"
    local assetsInfo = love.filesystem.getInfo(assetsPath)
    
    if assetsInfo and assetsInfo.type == "directory" then
        self:scanDirectory(assetsPath, assets, "")
    end
    
    if self.logger then
        local count = 0
        for _ in pairs(assets) do count = count + 1 end
        self.logger:debug(string.format("AssetCache: Scanned %d assets from %s", count, modPath))
    end
    
    return assets
end

--- Recursively scan directory for assets
-- @param dirPath string: Directory to scan
-- @param assets table: Assets map to populate
-- @param prefix string: ID prefix for nested directories
function AssetCache:scanDirectory(dirPath, assets, prefix)
    local items = love.filesystem.getDirectoryItems(dirPath)
    
    for _, item in ipairs(items) do
        local fullPath = dirPath .. "/" .. item
        local info = love.filesystem.getInfo(fullPath)
        
        if info then
            if info.type == "file" then
                local assetType = self:detectAssetType(item)
                if assetType then
                    -- Create asset ID from path
                    local assetId = prefix .. item:gsub("%.[^.]+$", "")  -- Remove extension
                    assets[assetId] = {
                        path = fullPath,
                        type = assetType
                    }
                end
            elseif info.type == "directory" then
                -- Recursively scan subdirectory
                local newPrefix = prefix .. item .. "/"
                self:scanDirectory(fullPath, assets, newPrefix)
            end
        end
    end
end

--- Register assets from all mods
-- @param mods table: Array of mod paths
function AssetCache:registerModAssets(mods)
    for _, modPath in ipairs(mods) do
        local assets = self:scanModAssets(modPath)
        
        for assetId, assetInfo in pairs(assets) do
            self.assetRegistry[assetId] = assetInfo
        end
    end
    
    if self.telemetry then
        self.telemetry:increment("asset_cache.mods_scanned", #mods)
    end
    
    if self.logger then
        local total = 0
        for _ in pairs(self.assetRegistry) do total = total + 1 end
        self.logger:info(string.format("AssetCache: Registered %d assets from %d mods", total, #mods))
    end
end

--- Get asset by ID (with lazy loading)
-- @param assetId string: Asset identifier
-- @return any: Loaded asset or nil
function AssetCache:getAsset(assetId)
    local assetInfo = self.assetRegistry[assetId]
    
    if not assetInfo then
        if self.logger then
            self.logger:warn("AssetCache: Asset not found: " .. assetId)
        end
        return nil
    end
    
    -- Load asset using fetch
    return self:fetch(assetInfo.type, assetInfo.path)
end

--- Preload specific assets (override lazy loading)
-- @param assetIds table: Array of asset IDs to preload
function AssetCache:preloadAssets(assetIds)
    local loaded = 0
    
    for _, assetId in ipairs(assetIds) do
        if self:getAsset(assetId) then
            loaded = loaded + 1
        end
    end
    
    if self.logger then
        self.logger:debug(string.format("AssetCache: Preloaded %d/%d assets", loaded, #assetIds))
    end
    
    return loaded
end

--- Add mod search path
-- @param path string: Path to add
function AssetCache:addModSearchPath(path)
    table.insert(self.modSearchPaths, path)
    
    if self.logger then
        self.logger:debug("AssetCache: Added search path: " .. path)
    end
end

--- Check if asset exists in registry
-- @param assetId string: Asset ID
-- @return boolean: True if registered
function AssetCache:hasAsset(assetId)
    return self.assetRegistry[assetId] ~= nil
end

--- List all registered asset IDs
-- @param assetType string: Optional filter by type
-- @return table: Array of asset IDs
function AssetCache:listAssets(assetType)
    local ids = {}
    
    for assetId, assetInfo in pairs(self.assetRegistry) do
        if not assetType or assetInfo.type == assetType then
            table.insert(ids, assetId)
        end
    end
    
    table.sort(ids)
    return ids
end

return AssetCache
