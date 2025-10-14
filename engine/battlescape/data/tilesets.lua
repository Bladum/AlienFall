-- Tileset System - Loader and Registry
-- Manages tilesets and Map Tiles with KEY-based lookups

local MapTile = require("battlescape.data.maptile")

local Tilesets = {}

-- Tileset registry: { tilesetId -> { tiles = {}, path = "", metadata = {} } }
Tilesets.registry = {}

-- Map Tile KEY index: { KEY -> MapTile }
Tilesets.tileIndex = {}

-- Loaded state tracking
Tilesets.loaded = {}

---Parse TOML file using custom parser
---@param filepath string Path to TOML file
---@return table? Parsed TOML data
local function parseTOML(filepath)
    local content, err = love.filesystem.read(filepath)
    if not content then
        print(string.format("[Tilesets] Error reading file %s: %s", filepath, err))
        return nil
    end
    
    -- Use custom parser that supports [[maptile]] array syntax
    -- (libs/toml.lua doesn't support array of tables)
        local data = {maptile = {}}
        local currentSection = nil
        
        for line in content:gmatch("[^\r\n]+") do
            line = line:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim
            
            -- Skip comments and empty lines
            if line:match("^#") or line == "" then
                goto continue
            end
            
            -- Section header
            if line:match("^%[%[maptile%]%]") then
                currentSection = {}
                table.insert(data.maptile, currentSection)
            elseif line:match("^%[tileset%]") then
                data.tileset = {}
                currentSection = data.tileset
            else
                -- Key-value pair
                local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
                if key and value and currentSection then
                    -- Parse value
                    value = value:gsub('"', ''):gsub("'", '')  -- Remove quotes
                    if value == "true" then value = true
                    elseif value == "false" then value = false
                    elseif tonumber(value) then value = tonumber(value)
                    end
                    currentSection[key] = value
                end
            end
            
            ::continue::
        end
        
        return data
end

---Register a tileset (metadata only, doesn't load assets)
---@param tilesetId string Tileset identifier (folder name)
---@param path string Path to tileset folder
function Tilesets.register(tilesetId, path)
    if Tilesets.registry[tilesetId] then
        print(string.format("[Tilesets] Warning: Tileset %s already registered", tilesetId))
        return
    end
    
    Tilesets.registry[tilesetId] = {
        id = tilesetId,
        path = path,
        tiles = {},
        metadata = {}
    }
    
    print(string.format("[Tilesets] Registered tileset: %s at %s", tilesetId, path))
end

---Load tileset TOML file and parse Map Tiles
---@param tilesetId string Tileset identifier
---@return boolean success
function Tilesets.load(tilesetId)
    local tileset = Tilesets.registry[tilesetId]
    if not tileset then
        print(string.format("[Tilesets] Error: Tileset %s not registered", tilesetId))
        return false
    end
    
    if Tilesets.loaded[tilesetId] then
        return true  -- Already loaded
    end
    
    local tomlPath = tileset.path .. "/tilesets.toml"
    print(string.format("[Tilesets] Loading tileset from: %s", tomlPath))
    
    local data = parseTOML(tomlPath)
    if not data then
        print(string.format("[Tilesets] Error: Failed to parse %s", tomlPath))
        return false
    end
    
    -- Load metadata
    if data.tileset then
        tileset.metadata = data.tileset
    end
    
    -- Load Map Tiles
    if data.maptile then
        local tileCount = 0
        for _, tileDef in ipairs(data.maptile) do
            -- Add tileset reference
            tileDef.tileset = tilesetId
            
            local success, mapTile = pcall(MapTile.new, tileDef)
            if success then
                -- Validate tile
                local valid, err = mapTile:validate()
                if valid then
                    -- Store in tileset
                    tileset.tiles[mapTile.key] = mapTile
                    
                    -- Index globally by KEY
                    if Tilesets.tileIndex[mapTile.key] then
                        print(string.format("[Tilesets] Warning: Duplicate KEY %s (overwriting)", mapTile.key))
                    end
                    Tilesets.tileIndex[mapTile.key] = mapTile
                    
                    tileCount = tileCount + 1
                else
                    print(string.format("[Tilesets] Validation error for tile: %s", err))
                end
            else
                print(string.format("[Tilesets] Error creating tile: %s", tostring(mapTile)))
            end
        end
        
        print(string.format("[Tilesets] Loaded %d tiles from tileset: %s", tileCount, tilesetId))
    end
    
    Tilesets.loaded[tilesetId] = true
    return true
end

---Unload tileset assets (free memory)
---@param tilesetId string Tileset identifier
function Tilesets.unload(tilesetId)
    local tileset = Tilesets.registry[tilesetId]
    if not tileset then
        return
    end
    
    -- Remove tiles from global index
    for key, _ in pairs(tileset.tiles) do
        Tilesets.tileIndex[key] = nil
    end
    
    -- Clear tileset tiles
    tileset.tiles = {}
    Tilesets.loaded[tilesetId] = false
    
    print(string.format("[Tilesets] Unloaded tileset: %s", tilesetId))
end

---Load all tilesets from mods directory
---@param modsPath string? Path to mods directory (default: "mods/core")
---@return number Number of tilesets loaded
function Tilesets.loadAll(modsPath)
    modsPath = modsPath or "mods/core"
    local tilesetsPath = modsPath .. "/tilesets"
    
    print(string.format("[Tilesets] Scanning for tilesets in: %s", tilesetsPath))
    
    -- Use love.filesystem to scan directory
    local items = love.filesystem.getDirectoryItems(tilesetsPath)
    local loadedCount = 0
    
    for _, item in ipairs(items) do
        local fullPath = tilesetsPath .. "/" .. item
        local info = love.filesystem.getInfo(fullPath)
        
        if info and info.type == "directory" then
            -- Check if tilesets.toml exists
            local tomlPath = fullPath .. "/tilesets.toml"
            if love.filesystem.getInfo(tomlPath) then
                Tilesets.register(item, fullPath)
                Tilesets.load(item)
                loadedCount = loadedCount + 1
            end
        end
    end
    
    print(string.format("[Tilesets] Loaded %d tilesets with %d total tiles", 
        Tilesets.getCount(), Tilesets.getTileCount()))
    
    return loadedCount
end

---Get Map Tile by KEY
---@param key string Map Tile KEY
---@return MapTile?
function Tilesets.getTile(key)
    return Tilesets.tileIndex[key]
end

---Get all tiles from a tileset
---@param tilesetId string Tileset identifier
---@return table<string, MapTile>
function Tilesets.getTileset(tilesetId)
    local tileset = Tilesets.registry[tilesetId]
    if tileset then
        return tileset.tiles
    end
    return {}
end

---Get all tileset IDs
---@return string[]
function Tilesets.getAllIds()
    local ids = {}
    for id, _ in pairs(Tilesets.registry) do
        table.insert(ids, id)
    end
    return ids
end

---Get tileset metadata
---@param tilesetId string Tileset identifier
---@return table?
function Tilesets.getMetadata(tilesetId)
    local tileset = Tilesets.registry[tilesetId]
    if tileset then
        return tileset.metadata
    end
    return nil
end

---Get count of registered tilesets
---@return number
function Tilesets.getCount()
    local count = 0
    for _ in pairs(Tilesets.registry) do
        count = count + 1
    end
    return count
end

---Get total count of loaded tiles
---@return number
function Tilesets.getTileCount()
    local count = 0
    for _ in pairs(Tilesets.tileIndex) do
        count = count + 1
    end
    return count
end

---Check if tileset is loaded
---@param tilesetId string Tileset identifier
---@return boolean
function Tilesets.isLoaded(tilesetId)
    return Tilesets.loaded[tilesetId] or false
end

---Get all tiles matching filter
---@param filter fun(tile: MapTile): boolean Filter function
---@return MapTile[]
function Tilesets.findTiles(filter)
    local results = {}
    for _, tile in pairs(Tilesets.tileIndex) do
        if filter(tile) then
            table.insert(results, tile)
        end
    end
    return results
end

---Clear all tilesets and tiles
function Tilesets.clear()
    Tilesets.registry = {}
    Tilesets.tileIndex = {}
    Tilesets.loaded = {}
    print("[Tilesets] Cleared all tilesets")
end

return Tilesets
