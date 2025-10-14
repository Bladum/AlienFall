-- MapBlock Loader - Load and Filter MapBlocks by Tags
-- Handles loading MapBlock files from mods and filtering by tags

local MapBlockLoader = {}

---@class LegacyMapBlock
---@field id string Unique MapBlock identifier
---@field name string Display name
---@field size table Dimensions {width, height} in tiles
---@field tags table Array of tags for filtering
---@field tiles table 2D array of tile data [y][x]
---@field filePath string Source file path
---@field modId string Mod that provided this block

---@class MapBlockLoader
---@field blocks table Registry of loaded MapBlocks {id = block}
---@field tagIndex table Index for fast tag lookup {tag = {ids}}
---@field modManager table Reference to mod manager
---@field cacheValid boolean Whether cache is valid

---Create a new MapBlock loader
---@param modManager table Reference to mod manager
---@return MapBlockLoader
function MapBlockLoader.new(modManager)
    local self = setmetatable({}, {__index = MapBlockLoader})
    
    self.blocks = {}
    self.tagIndex = {}
    self.modManager = modManager
    self.cacheValid = false
    
    return self
end

---Load all MapBlocks from active mods
---@return number count Number of blocks loaded
function MapBlockLoader:loadAll()
    print("[MapBlockLoader] Loading MapBlocks from active mods...")
    
    -- Clear existing data
    self.blocks = {}
    self.tagIndex = {}
    
    local count = 0
    
    -- Get active mods from mod manager
    if not self.modManager then
        print("[MapBlockLoader] No mod manager available")
        return 0
    end
    
    local activeMods = self.modManager:getActiveMods()
    if not activeMods then
        print("[MapBlockLoader] No active mods found")
        return 0
    end
    
    -- Load MapBlocks from each mod
    for _, modId in ipairs(activeMods) do
        local modPath = self.modManager:getModPath(modId)
        if modPath then
            local blocksPath = modPath .. "/mapblocks"
            count = count + self:loadFromDirectory(blocksPath, modId)
        end
    end
    
    self.cacheValid = true
    print(string.format("[MapBlockLoader] Loaded %d MapBlocks", count))
    return count
end

---Load MapBlocks from a directory
---@param dirPath string Directory path
---@param modId string Mod identifier
---@return number count Number of blocks loaded
function MapBlockLoader:loadFromDirectory(dirPath, modId)
    -- Check if directory exists
    local info = love.filesystem.getInfo(dirPath)
    if not info or info.type ~= "directory" then
        return 0
    end
    
    local count = 0
    local files = love.filesystem.getDirectoryItems(dirPath)
    
    for _, filename in ipairs(files) do
        if filename:match("%.lua$") then
            local filePath = dirPath .. "/" .. filename
            local block = self:loadBlock(filePath, modId)
            if block then
                self:registerBlock(block)
                count = count + 1
            end
        end
    end
    
    return count
end

---Load a single MapBlock file
---@param filePath string File path
---@param modId string Mod identifier
---@return LegacyMapBlock? block Loaded block or nil
function MapBlockLoader:loadBlock(filePath, modId)
    local success, chunk = pcall(love.filesystem.load, filePath)
    if not success then
        print(string.format("[MapBlockLoader] Failed to load: %s - %s", filePath, chunk))
        return nil
    end
    
    local success, block = pcall(chunk)
    if not success then
        print(string.format("[MapBlockLoader] Failed to execute: %s - %s", filePath, block))
        return nil
    end
    
    if not block or type(block) ~= "table" then
        print(string.format("[MapBlockLoader] Invalid block format: %s", filePath))
        return nil
    end
    
    -- Validate required fields
    if not block.id or not block.tiles then
        print(string.format("[MapBlockLoader] Missing required fields: %s", filePath))
        return nil
    end
    
    -- Add metadata
    block.filePath = filePath
    block.modId = modId
    
    -- Ensure tags exist
    block.tags = block.tags or {}
    
    -- Calculate size if not specified
    if not block.size then
        block.size = {
            width = #(block.tiles[1] or {}),
            height = #block.tiles
        }
    end
    
    return block
end

---Register a MapBlock and update indices
---@param block LegacyMapBlock Block to register
function MapBlockLoader:registerBlock(block)
    -- Store block
    self.blocks[block.id] = block
    
    -- Index by tags
    for _, tag in ipairs(block.tags) do
        if not self.tagIndex[tag] then
            self.tagIndex[tag] = {}
        end
        table.insert(self.tagIndex[tag], block.id)
    end
end

---Get a MapBlock by ID
---@param blockId string Block ID
---@return LegacyMapBlock? block Block or nil
function MapBlockLoader:getBlock(blockId)
    return self.blocks[blockId]
end

---Find MapBlocks matching all required tags
---@param requiredTags table Array of required tags
---@param excludeTags? table Array of tags to exclude
---@return table Array of MapBlock IDs
function MapBlockLoader:findByTags(requiredTags, excludeTags)
    if not requiredTags or #requiredTags == 0 then
        -- Return all blocks if no tags specified
        local allIds = {}
        for id, _ in pairs(self.blocks) do
            table.insert(allIds, id)
        end
        return allIds
    end
    
    excludeTags = excludeTags or {}
    
    -- Start with blocks matching first tag
    local candidates = {}
    if self.tagIndex[requiredTags[1]] then
        for _, id in ipairs(self.tagIndex[requiredTags[1]]) do
            candidates[id] = true
        end
    else
        return {} -- No blocks with first tag
    end
    
    -- Filter by remaining required tags
    for i = 2, #requiredTags do
        local tag = requiredTags[i]
        if self.tagIndex[tag] then
            local newCandidates = {}
            for _, id in ipairs(self.tagIndex[tag]) do
                if candidates[id] then
                    newCandidates[id] = true
                end
            end
            candidates = newCandidates
        else
            return {} -- No blocks with this tag
        end
    end
    
    -- Filter by excluded tags
    for _, tag in ipairs(excludeTags) do
        if self.tagIndex[tag] then
            for _, id in ipairs(self.tagIndex[tag]) do
                candidates[id] = nil
            end
        end
    end
    
    -- Convert to array
    local results = {}
    for id, _ in pairs(candidates) do
        table.insert(results, id)
    end
    
    return results
end

---Find MapBlocks matching any of the provided tags
---@param tags table Array of tags (OR logic)
---@param excludeTags? table Array of tags to exclude
---@return table Array of MapBlock IDs
function MapBlockLoader:findByAnyTag(tags, excludeTags)
    excludeTags = excludeTags or {}
    
    local candidates = {}
    
    -- Gather all blocks with any of the tags
    for _, tag in ipairs(tags) do
        if self.tagIndex[tag] then
            for _, id in ipairs(self.tagIndex[tag]) do
                candidates[id] = true
            end
        end
    end
    
    -- Filter by excluded tags
    for _, tag in ipairs(excludeTags) do
        if self.tagIndex[tag] then
            for _, id in ipairs(self.tagIndex[tag]) do
                candidates[id] = nil
            end
        end
    end
    
    -- Convert to array
    local results = {}
    for id, _ in pairs(candidates) do
        table.insert(results, id)
    end
    
    return results
end

---Get random MapBlock matching tags
---@param requiredTags table Array of required tags
---@param excludeTags? table Array of tags to exclude
---@return string? blockId Random matching block ID or nil
function MapBlockLoader:getRandomByTags(requiredTags, excludeTags)
    local matches = self:findByTags(requiredTags, excludeTags)
    
    if #matches == 0 then
        return nil
    end
    
    return matches[math.random(1, #matches)]
end

---Get all MapBlock IDs
---@return table Array of block IDs
function MapBlockLoader:getAllIds()
    local ids = {}
    for id, _ in pairs(self.blocks) do
        table.insert(ids, id)
    end
    return ids
end

---Get all registered tags
---@return table Array of tag strings
function MapBlockLoader:getAllTags()
    local tags = {}
    for tag, _ in pairs(self.tagIndex) do
        table.insert(tags, tag)
    end
    return tags
end

---Get MapBlock count
---@return number count Number of loaded blocks
function MapBlockLoader:getCount()
    local count = 0
    for _, _ in pairs(self.blocks) do
        count = count + 1
    end
    return count
end

---Invalidate cache (call when mods change)
function MapBlockLoader:invalidateCache()
    self.cacheValid = false
end

---Check if cache is valid
---@return boolean valid True if cache is valid
function MapBlockLoader:isCacheValid()
    return self.cacheValid
end

---Print statistics about loaded MapBlocks
function MapBlockLoader:printStatistics()
    print("\n[MapBlockLoader] Statistics")
    print("----------------------------------------")
    print(string.format("Total blocks: %d", self:getCount()))
    print(string.format("Unique tags: %d", #self:getAllTags()))
    
    -- Count blocks by mod
    local modCounts = {}
    for _, block in pairs(self.blocks) do
        modCounts[block.modId] = (modCounts[block.modId] or 0) + 1
    end
    
    print("\nBlocks by mod:")
    for modId, count in pairs(modCounts) do
        print(string.format("  %s: %d", modId, count))
    end
    
    -- Top 10 most common tags
    local tagCounts = {}
    for tag, ids in pairs(self.tagIndex) do
        table.insert(tagCounts, {tag = tag, count = #ids})
    end
    table.sort(tagCounts, function(a, b) return a.count > b.count end)
    
    print("\nTop 10 most common tags:")
    for i = 1, math.min(10, #tagCounts) do
        print(string.format("  %s: %d blocks", tagCounts[i].tag, tagCounts[i].count))
    end
    print("----------------------------------------\n")
end

---Create a mock MapBlock for testing
---@param id string Block ID
---@param tags table Array of tags
---@param size? table {width, height} in tiles
---@return LegacyMapBlock block Mock block
function MapBlockLoader.createMockBlock(id, tags, size)
    size = size or {width = 10, height = 10}
    
    -- Create empty tile grid
    local tiles = {}
    for y = 1, size.height do
        tiles[y] = {}
        for x = 1, size.width do
            tiles[y][x] = {type = "floor"}
        end
    end
    
    return {
        id = id,
        name = "Mock Block: " .. id,
        size = size,
        tags = tags,
        tiles = tiles,
        filePath = "mock/" .. id .. ".lua",
        modId = "mock"
    }
end

---Get total number of loaded blocks
---@return number count Number of blocks
function MapBlockLoader:getCount()
    local count = 0
    for _ in pairs(self.blocks) do
        count = count + 1
    end
    return count
end

---Get all available tags
---@return table<string, number> tags Tag counts {tag = count}
function MapBlockLoader:getAllTags()
    local tags = {}
    for _, block in pairs(self.blocks) do
        if block.tags then
            for _, tag in ipairs(block.tags) do
                tags[tag] = (tags[tag] or 0) + 1
            end
        end
    end
    return tags
end

---Get all block IDs
---@return table ids Array of block IDs
function MapBlockLoader:getAllIds()
    local ids = {}
    for id in pairs(self.blocks) do
        table.insert(ids, id)
    end
    return ids
end

---Print statistics about loaded blocks
function MapBlockLoader:printStatistics()
    local count = self:getCount()
    local tags = self:getAllTags()
    
    print(string.format("[MapBlockLoader] Statistics:"))
    print(string.format("  Total blocks: %d", count))
    print(string.format("  Total tags: %d", #tags))
    
    if count > 0 then
        print("  Tags:")
        for tag, count in pairs(tags) do
            print(string.format("    %s: %d blocks", tag, count))
        end
    end
end

return MapBlockLoader
