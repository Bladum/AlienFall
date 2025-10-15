--- MapBlock Class
--- Represents a 15x15 tile template for procedural map generation.
---
--- MapBlocks are the building blocks of larger battlefields. Each block
--- contains terrain data and metadata for procedural generation.
--- Blocks can be loaded from TOML files or created programmatically.
---
--- Example usage:
---   local block = MapBlock.new("forest_01", 15, 15)
---   block:setTile(5, 5, "wall")
---   local terrain = block:getTile(5, 5)

--- @class MapBlock
--- @field id string Unique identifier for this block
--- @field width number Block width in tiles (typically 15)
--- @field height number Block height in tiles (typically 15)
--- @field tiles table 2D array of terrain IDs [y][x]
--- @field metadata table Block metadata (name, biome, difficulty, etc.)
local MapBlock = {}
MapBlock.__index = MapBlock

--- Constructor
---

--- Create a new MapBlock instance.
---
--- Initializes empty block with default floor terrain.
---
--- @param id string Unique identifier (default: "unknown")
--- @param width number Block width in tiles (default: 15)
--- @param height number Block height in tiles (default: 15)
--- @return table New MapBlock instance
function MapBlock.new(id, width, height)
    local self = setmetatable({}, MapBlock)

    self.id = id or "unknown"
    self.width = width or 15
    self.height = height or 15
    self.tiles = {}  -- [y][x] = terrain_id
    self.metadata = {
        name = "",
        description = "",
        biome = "mixed",
        difficulty = 1,
        author = "",
        tags = {}
    }

    -- Initialize empty tiles
    for y = 1, self.height do
        self.tiles[y] = {}
        for x = 1, self.width do
            self.tiles[y][x] = "floor"  -- Default terrain
        end
    end

    return self
end

--- Tile Access
---

--- Get terrain ID at tile position.
---
--- @param x number Tile X coordinate (1-based)
--- @param y number Tile Y coordinate (1-based)
--- @return string|nil Terrain ID or nil if out of bounds
function MapBlock:getTile(x, y)
    if y >= 1 and y <= self.height and x >= 1 and x <= self.width then
        return self.tiles[y] and self.tiles[y][x]
    end
    return nil
end

--- Set terrain ID at tile position.
---
--- @param x number Tile X coordinate (1-based)
--- @param y number Tile Y coordinate (1-based)
--- @param terrainId string Terrain identifier
--- @return boolean True if position is valid and tile was set
function MapBlock:setTile(x, y, terrainId)
    if y >= 1 and y <= self.height and x >= 1 and x <= self.width then
        if not self.tiles[y] then
            self.tiles[y] = {}
        end
        self.tiles[y][x] = terrainId
        return true
    end
    return false
end

--- TOML Serialization
---

--- Load MapBlock from TOML file.
---
--- Parses TOML file containing block metadata and terrain data.
---
--- @param filepath string Path to TOML file
--- @return table|nil MapBlock instance or nil on error
function MapBlock.loadFromTOML(filepath)
    print(string.format("[MapBlock] Loading from TOML: %s", filepath))
    
    local data = TOML.load(filepath)
    if not data then
        print(string.format("[MapBlock] ERROR: Failed to parse TOML: %s", filepath))
        return nil
    end
    
    -- Read metadata
    local meta = data.metadata or {}
    local id = meta.id or "unknown"
    local width = meta.width or 15
    local height = meta.height or 15
    
    -- Create MapBlock
    local block = MapBlock.new(id, width, height)
    block.metadata.name = meta.name or ""
    block.metadata.description = meta.description or ""
    block.metadata.biome = meta.biome or "mixed"
    block.metadata.difficulty = meta.difficulty or 1
    block.metadata.author = meta.author or ""
    
    -- Parse tags
    if meta.tags then
        block.metadata.tags = {}
        for tag in meta.tags:gmatch("[^,]+") do
            table.insert(block.metadata.tags, tag:match("^%s*(.-)%s*$"))
        end
    end
    
    -- Read tiles
    local tiles = data.tiles or {}
    for key, terrainId in pairs(tiles) do
        -- Parse "row_col" format
        local row, col = key:match("(%d+)_(%d+)")
        if row and col then
            local y = tonumber(row) + 1  -- TOML is 0-indexed, Lua is 1-indexed
            local x = tonumber(col) + 1
            block:setTile(x, y, terrainId)
        end
    end
    
    print(string.format("[MapBlock] Loaded '%s' (%dx%d, %s)", 
        block.metadata.name, block.width, block.height, block.metadata.biome))
    
    return block
end

function MapBlock:saveToTOML(filepath)
    print(string.format("[MapBlock] Saving to TOML: %s", filepath))
    
    local data = {
        metadata = {
            id = self.id,
            name = self.metadata.name,
            description = self.metadata.description,
            width = self.width,
            height = self.height,
            biome = self.metadata.biome,
            difficulty = self.metadata.difficulty,
            author = self.metadata.author,
            tags = table.concat(self.metadata.tags, ", ")
        },
        tiles = {}
    }
    
    -- Write tiles
    for y = 1, self.height do
        for x = 1, self.width do
            local terrainId = self.tiles[y][x]
            if terrainId and terrainId ~= "floor" then  -- Only save non-default
                local key = string.format("%d_%d", y - 1, x - 1)  -- 0-indexed
                data.tiles[key] = terrainId
            end
        end
    end
    
    return TOML.save(filepath, data)
end

---
--- Utility
---

-- Load all MapBlocks from directory
function MapBlock.loadAll(directory)
    print(string.format("[MapBlock] Loading all blocks from: %s", directory))
    
    local blocks = {}
    
    -- Use love.filesystem if available
    if love and love.filesystem then
        local files = love.filesystem.getDirectoryItems(directory)
        for _, filename in ipairs(files) do
            if filename:match("%.toml$") then
                local filepath = directory .. "/" .. filename
                local block = MapBlock.loadFromTOML(filepath)
                if block then
                    table.insert(blocks, block)
                end
            end
        end
    else
        -- Fallback: manual file list (for testing)
        print("[MapBlock] WARNING: love.filesystem not available, using fallback")
    end
    
    print(string.format("[MapBlock] Loaded %d blocks", #blocks))
    return blocks
end

-- Create default blocks for testing
function MapBlock.createDefaults()
    local blocks = {}
    
    -- Open field block
    local open = MapBlock.new("open_01", 15, 15)
    open.metadata.name = "Open Field"
    open.metadata.biome = "rural"
    for y = 1, 15 do
        for x = 1, 15 do
            open:setTile(x, y, math.random() < 0.1 and "bushes" or "floor")
        end
    end
    table.insert(blocks, open)
    
    -- Urban block
    local urban = MapBlock.new("urban_01", 15, 15)
    urban.metadata.name = "City Block"
    urban.metadata.biome = "urban"
    -- Roads on edges
    for x = 1, 15 do
        urban:setTile(x, 1, "road")
        urban:setTile(x, 15, "road")
    end
    for y = 1, 15 do
        urban:setTile(1, y, "road")
        urban:setTile(15, y, "road")
    end
    -- Building in center
    for y = 5, 11 do
        for x = 5, 11 do
            if y == 5 or y == 11 or x == 5 or x == 11 then
                urban:setTile(x, y, "wall")
            else
                urban:setTile(x, y, "floor")
            end
        end
    end
    table.insert(blocks, urban)
    
    -- Forest block
    local forest = MapBlock.new("forest_01", 15, 15)
    forest.metadata.name = "Dense Forest"
    forest.metadata.biome = "forest"
    for y = 1, 15 do
        for x = 1, 15 do
            local rand = math.random()
            if rand < 0.3 then
                forest:setTile(x, y, "trees")
            elseif rand < 0.5 then
                forest:setTile(x, y, "bushes")
            else
                forest:setTile(x, y, "floor")
            end
        end
    end
    table.insert(blocks, forest)
    
    print(string.format("[MapBlock] Created %d default blocks", #blocks))
    return blocks
end

return MapBlock






















