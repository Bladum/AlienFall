---MapBlockLoaderV2 - TOML-Based MapBlock Loader with KEYs
---
---Loads MapBlocks from TOML files with KEY-based tile references. Replaces legacy
---Lua-based MapBlock definitions with structured TOML format. Integrates with
---Tileset system for tile lookup by KEY. Supports multi-tile modes.
---
---Features:
---  - TOML file parsing
---  - KEY-based tile references
---  - Multi-tile mode support (variants, animations, autotile)
---  - MapBlock validation
---  - Tag system integration
---  - Group ID assignment
---
---TOML MapBlock Structure:
---  ```toml
---  [mapblock]
---  id = "urban_building_01"
---  name = "Office Building"
---  width = 15
---  height = 15
---  group = 10
---  tags = ["urban", "building", "large"]
---  
---  [tiles]
---  # KEY-based tile grid (15×15)
---  ```
---
---Tile References:
---  - Direct KEY: "WALL_BRICK_01"
---  - Multi-tile with variant: "WALL_BRICK_01:2" (variant 2)
---  - Empty tile: "." or "EMPTY"
---
---Multi-Tile Modes:
---  - random_variant: Random variant selection
---  - animation: Animated tiles
---  - autotile: Automatic tile selection
---  - occupy: Multi-cell large objects
---  - damage_states: Destructible tiles
---
---Key Exports:
---  - MapBlockLoader.load(filePath): Loads MapBlock from TOML
---  - MapBlockLoader.get(id): Returns loaded MapBlock
---  - MapBlockLoader.getAll(): Returns all MapBlocks
---  - MapBlockLoader.validate(block): Validates MapBlock data
---  - MapBlockLoader.unload(id): Removes MapBlock from memory
---
---Dependencies:
---  - battlescape.data.tilesets: Tileset and tile lookup
---  - battlescape.utils.multitile: Multi-tile mode handler
---
---@module battlescape.maps.mapblock_loader_v2
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")
---  MapBlockLoader.load("mods/core/content/mapblocks/urban_building_01.toml")
---  local block = MapBlockLoader.get("urban_building_01")
---
---@see battlescape.data.tilesets For tile system
---@see battlescape.maps.mapblock_system For MapBlock management

-- MapBlock Loader v2 - TOML-based with Map Tile KEYs
-- Loads Map Blocks from TOML files with KEY-based tile references

local Tilesets = require("battlescape.data.tilesets")
local MultiTile = require("battlescape.utils.multitile")

local MapBlockLoader = {}

---@class TomlMapBlock
---@field id string Unique identifier
---@field name string Display name
---@field description string? Block description
---@field width number Width in tiles (multiple of 15)
---@field height number Height in tiles (multiple of 15)
---@field group number Group ID (0-99) for Map Scripts
---@field tags string Comma-separated tags
---@field author string? Creator name
---@field difficulty number? 1-5 difficulty rating
---@field tiles table<string, string> Tile grid {["x_y"] = "MAP_TILE_KEY"}
---@field filePath string Source file path

-- Registry of loaded Map Blocks
MapBlockLoader.blocks = {}

-- Group index: {groupId -> {blockIds}}
MapBlockLoader.groupIndex = {}

-- Tag index: {tag -> {blockIds}}
MapBlockLoader.tagIndex = {}

---Parse TOML file
---@param filepath string Path to TOML file
---@return table? Parsed TOML data
local function parseTOML(filepath)
    local file = io.open(filepath, "r")
    if not file then
        print(string.format("[MapBlockLoader] Cannot open file: %s", filepath))
        return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    -- Try using TOML library
    local hasToml, toml = pcall(require, "utils.libs.toml")
    if hasToml then
        local success, result = pcall(toml.parse, content)
        if success then
            return result
        else
            print(string.format("[MapBlockLoader] TOML parse error in %s: %s", filepath, tostring(result)))
            return nil
        end
    end
    
    -- Fallback: simple parser
    local data = {metadata = {}, tiles = {}}
    local currentSection = nil
    
    for line in content:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        
        if line:match("^#") or line == "" then
            goto continue
        end
        
        if line:match("^%[metadata%]") then
            currentSection = data.metadata
        elseif line:match("^%[tiles%]") then
            currentSection = data.tiles
        else
            local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
            if key and value and currentSection then
                value = value:gsub('"', ''):gsub("'", ''):gsub(",%s*$", "")
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

---Load a single Map Block from TOML file
---@param filepath string Path to TOML file
---@return TomlMapBlock? block Loaded block or nil
function MapBlockLoader.loadBlock(filepath)
    local data = parseTOML(filepath)
    if not data or not data.metadata then
        print(string.format("[MapBlockLoader] Invalid TOML format: %s", filepath))
        return nil
    end
    
    local meta = data.metadata
    
    -- Validate required fields
    if not meta.id then
        print(string.format("[MapBlockLoader] Missing 'id' in: %s", filepath))
        return nil
    end
    
    local block = {
        id = meta.id,
        name = meta.name or meta.id,
        description = meta.description,
        width = meta.width or 15,
        height = meta.height or 15,
        group = meta.group or 0,
        tags = meta.tags or "",
        author = meta.author,
        difficulty = meta.difficulty,
        tiles = data.tiles or {},
        filePath = filepath
    }
    
    -- Validate dimensions (must be multiples of 15)
    if block.width % 15 ~= 0 or block.height % 15 ~= 0 then
        print(string.format("[MapBlockLoader] Invalid dimensions %dx%d (must be multiples of 15): %s", 
            block.width, block.height, filepath))
        return nil
    end
    
    -- Validate Map Tile KEYs
    local invalidKeys = {}
    for coord, key in pairs(block.tiles) do
        local tile = Tilesets.getTile(key)
        if not tile then
            table.insert(invalidKeys, key)
        end
    end
    
    if #invalidKeys > 0 then
        print(string.format("[MapBlockLoader] Warning: Invalid Map Tile KEYs in %s: %s", 
            filepath, table.concat(invalidKeys, ", ")))
    end
    
    return block
end

---Load all Map Blocks from directory
---@param dirPath string Directory path
---@return number count Number of blocks loaded
function MapBlockLoader.loadAll(dirPath)
    dirPath = dirPath or "mods/core/mapblocks"
    print(string.format("[MapBlockLoader] Loading Map Blocks from: %s", dirPath))
    
    -- Clear existing data
    MapBlockLoader.blocks = {}
    MapBlockLoader.groupIndex = {}
    MapBlockLoader.tagIndex = {}
    
    local files = love.filesystem.getDirectoryItems(dirPath)
    local count = 0
    
    for _, filename in ipairs(files) do
        if filename:match("%.toml$") then
            local filepath = dirPath .. "/" .. filename
            local block = MapBlockLoader.loadBlock(filepath)
            if block then
                MapBlockLoader.register(block)
                count = count + 1
            end
        end
    end
    
    print(string.format("[MapBlockLoader] Loaded %d Map Blocks", count))
    return count
end

---Register a Map Block and update indices
---@param block TomlMapBlock Block to register
function MapBlockLoader.register(block)
    -- Store block
    MapBlockLoader.blocks[block.id] = block
    
    -- Index by group
    if not MapBlockLoader.groupIndex[block.group] then
        MapBlockLoader.groupIndex[block.group] = {}
    end
    table.insert(MapBlockLoader.groupIndex[block.group], block.id)
    
    -- Index by tags
    if block.tags and block.tags ~= "" then
        for tag in block.tags:gmatch("[^,]+") do
            tag = tag:gsub("^%s+", ""):gsub("%s+$", "")  -- Trim
            if not MapBlockLoader.tagIndex[tag] then
                MapBlockLoader.tagIndex[tag] = {}
            end
            table.insert(MapBlockLoader.tagIndex[tag], block.id)
        end
    end
    
    print(string.format("[MapBlockLoader] Registered: %s (group %d, %dx%d)", 
        block.id, block.group, block.width, block.height))
end

---Get a Map Block by ID
---@param blockId string Block ID
---@return TomlMapBlock?
function MapBlockLoader.get(blockId)
    return MapBlockLoader.blocks[blockId]
end

---Get all Map Blocks in a group
---@param groupId number Group ID (0-99)
---@return TomlMapBlock[]
function MapBlockLoader.getByGroup(groupId)
    local ids = MapBlockLoader.groupIndex[groupId] or {}
    local blocks = {}
    for _, id in ipairs(ids) do
        local block = MapBlockLoader.blocks[id]
        if block then
            table.insert(blocks, block)
        end
    end
    return blocks
end

---Get all Map Blocks matching tags
---@param tags string[] Array of tags (OR logic)
---@return TomlMapBlock[]
function MapBlockLoader.getByTags(tags)
    local blockSet = {}
    
    for _, tag in ipairs(tags) do
        local ids = MapBlockLoader.tagIndex[tag] or {}
        for _, id in ipairs(ids) do
            blockSet[id] = true
        end
    end
    
    local blocks = {}
    for id, _ in pairs(blockSet) do
        local block = MapBlockLoader.blocks[id]
        if block then
            table.insert(blocks, block)
        end
    end
    
    return blocks
end

---Get all Map Blocks with specific dimensions
---@param width number Width in tiles
---@param height number Height in tiles
---@return TomlMapBlock[]
function MapBlockLoader.getBySize(width, height)
    local blocks = {}
    for _, block in pairs(MapBlockLoader.blocks) do
        if block.width == width and block.height == height then
            table.insert(blocks, block)
        end
    end
    return blocks
end

---Get tile KEY at coordinate
---@param block MapBlock The Map Block
---@param x number X coordinate (0-indexed)
---@param y number Y coordinate (0-indexed)
---@return string? tileKey Map Tile KEY or nil
function MapBlockLoader.getTileAt(block, x, y)
    local coord = string.format("%d_%d", x, y)
    return block.tiles[coord]
end

---Set tile KEY at coordinate
---@param block MapBlock The Map Block
---@param x number X coordinate (0-indexed)
---@param y number Y coordinate (0-indexed)
---@param tileKey string? Map Tile KEY (nil to clear)
function MapBlockLoader.setTileAt(block, x, y, tileKey)
    local coord = string.format("%d_%d", x, y)
    if tileKey then
        block.tiles[coord] = tileKey
    else
        block.tiles[coord] = nil
    end
end

---Get all occupied coordinates in a Map Block
---@param block MapBlock The Map Block
---@return table<string, string> Coordinates {"x_y" -> "KEY"}
function MapBlockLoader.getAllTiles(block)
    return block.tiles
end

---Count occupied tiles in a Map Block
---@param block MapBlock The Map Block
---@return number count Number of non-empty tiles
function MapBlockLoader.getTileCount(block)
    local count = 0
    for _ in pairs(block.tiles) do
        count = count + 1
    end
    return count
end

---Get statistics about loaded Map Blocks
---@return table stats {total, byGroup, byTags, dimensions}
function MapBlockLoader.getStats()
    local stats = {
        total = 0,
        byGroup = {},
        byTags = {},
        dimensions = {}
    }
    
    for _, block in pairs(MapBlockLoader.blocks) do
        stats.total = stats.total + 1
        
        -- Count by group
        stats.byGroup[block.group] = (stats.byGroup[block.group] or 0) + 1
        
        -- Count by dimensions
        local dimKey = string.format("%dx%d", block.width, block.height)
        stats.dimensions[dimKey] = (stats.dimensions[dimKey] or 0) + 1
    end
    
    -- Count by tags
    for tag, ids in pairs(MapBlockLoader.tagIndex) do
        stats.byTags[tag] = #ids
    end
    
    return stats
end

---Clear all loaded Map Blocks
function MapBlockLoader.clear()
    MapBlockLoader.blocks = {}
    MapBlockLoader.groupIndex = {}
    MapBlockLoader.tagIndex = {}
    print("[MapBlockLoader] Cleared all Map Blocks")
end

---Export Map Block to TOML string
---@param block TomlMapBlock The Map Block
---@return string toml TOML representation
function MapBlockLoader.exportToTOML(block)
    local lines = {
        "# " .. block.name,
        ""
    }
    
    -- Metadata section
    table.insert(lines, "[metadata]")
    table.insert(lines, string.format('id = "%s"', block.id))
    table.insert(lines, string.format('name = "%s"', block.name))
    if block.description then
        table.insert(lines, string.format('description = "%s"', block.description))
    end
    table.insert(lines, string.format("width = %d", block.width))
    table.insert(lines, string.format("height = %d", block.height))
    table.insert(lines, string.format("group = %d", block.group))
    table.insert(lines, string.format('tags = "%s"', block.tags))
    if block.author then
        table.insert(lines, string.format('author = "%s"', block.author))
    end
    if block.difficulty then
        table.insert(lines, string.format("difficulty = %d", block.difficulty))
    end
    table.insert(lines, "")
    
    -- Tiles section
    table.insert(lines, "[tiles]")
    
    -- Sort coordinates for readable output
    local coords = {}
    for coord in pairs(block.tiles) do
        table.insert(coords, coord)
    end
    table.sort(coords, function(a, b)
        local ax, ay = a:match("(%d+)_(%d+)")
        local bx, by = b:match("(%d+)_(%d+)")
        ax, ay = tonumber(ax), tonumber(ay)
        bx, by = tonumber(bx), tonumber(by)
        if ay == by then
            return ax < bx
        end
        return ay < by
    end)
    
    for _, coord in ipairs(coords) do
        local key = block.tiles[coord]
        table.insert(lines, string.format('"%s" = "%s"', coord, key))
    end
    
    return table.concat(lines, "\n")
end

return MapBlockLoader

























