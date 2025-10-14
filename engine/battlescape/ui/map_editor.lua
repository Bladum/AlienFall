-- Map Editor - Visual Map Block Editor
-- Phase 5: Map Editor Enhancement
-- Allows visual editing of Map Blocks with paint/erase tools

local Widgets = require("widgets")
local Tilesets = require("battlescape.data.tilesets")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")

local MapEditor = {}
MapEditor.__index = MapEditor

---@class MapEditor
---@field width number Editor width in tiles
---@field height number Editor height in tiles
---@field grid table Map grid {[x_y] = MAP_TILE_KEY}
---@field metadata table Block metadata {id, name, group, tags, author, difficulty}
---@field selectedTileset string? Currently selected tileset
---@field selectedTile string? Currently selected Map Tile KEY
---@field tool string Current tool ("paint" or "erase")
---@field currentTool string Current tool ("paint" or "erase")
---@field camera table Camera offset {x, y}
---@field zoom number Zoom level
---@field history table[] Undo/redo stack
---@field historyIndex number Current position in history
---@field isDirty boolean Has unsaved changes
---@field dirty boolean Has unsaved changes (alias)
---@field getStats fun(self): table Get editor statistics
---@field undo fun(self) Undo last action
---@field redo fun(self) Redo last undone action
---@field new_blank fun(self) Create new blank map
---@field setTool fun(self, tool: string) Set current tool
---@field paintTile fun(self, x: number, y: number) Paint tile at position
---@field eraseTile fun(self, x: number, y: number) Erase tile at position
---@field selectTileset fun(self, tilesetId: string) Select tileset
---@field selectTile fun(self, tileKey: string) Select tile

---Create a new Map Editor
---@param width number Block width in tiles (15, 30, 45, etc.)
---@param height number Block height in tiles (15, 30, 45, etc.)
---@return MapEditor
function MapEditor.new(width, height)
    local self = setmetatable({}, MapEditor)
    
    self.width = width or 15
    self.height = height or 15
    self.grid = {}
    self.metadata = {
        id = "new_block",
        name = "New Map Block",
        group = 0,
        tags = "custom",
        author = "Unknown",
        difficulty = 1
    }
    
    self.selectedTileset = nil
    self.selectedTile = nil
    self.tool = "paint"
    self.camera = {x = 0, y = 0}
    self.zoom = 1.0
    self.history = {}
    self.historyIndex = 0
    self.dirty = false
    self.isDirty = false  -- Alias for tests
    
    -- Initialize empty grid
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            self.grid[key] = "EMPTY"
        end
    end
    
    -- Save initial state
    self:saveHistory()
    
    print("[MapEditor] Created " .. width .. "x" .. height .. " editor")
    return self
end

---Get tile at position
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return string? tileKey Map Tile KEY or nil
function MapEditor:getTile(x, y)
    if x < 0 or x >= self.width or y < 0 or y >= self.height then
        return nil
    end
    local key = string.format("%d_%d", x, y)
    return self.grid[key]
end

---Set tile at position
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@param tileKey string Map Tile KEY
function MapEditor:setTile(x, y, tileKey)
    if x < 0 or x >= self.width or y < 0 or y >= self.height then
        return
    end
    local key = string.format("%d_%d", x, y)
    if self.grid[key] ~= tileKey then
        self.grid[key] = tileKey
        self.dirty = true
        self.isDirty = true
    end
end

---Paint tile (left click)
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
function MapEditor:paintTile(x, y)
    if not self.selectedTile then
        print("[MapEditor] No tile selected")
        return
    end
    
    self:setTile(x, y, self.selectedTile)
    self:saveHistory()
end

---Erase tile (right click or erase tool)
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
function MapEditor:eraseTile(x, y)
    self:setTile(x, y, "EMPTY")
    self:saveHistory()
end

---Select tileset
---@param tilesetId string Tileset ID
function MapEditor:selectTileset(tilesetId)
    local tiles = Tilesets.getTileset(tilesetId)
    if tiles and next(tiles) then
        self.selectedTileset = tilesetId
        self.selectedTile = nil -- Clear tile selection
        print(string.format("[MapEditor] Selected tileset: %s", tilesetId))
    else
        print(string.format("[MapEditor] Tileset not found: %s", tilesetId))
    end
end

---Select Map Tile
---@param tileKey string Map Tile KEY
function MapEditor:selectTile(tileKey)
    -- Validate tile exists
    local tileset, tileId = tileKey:match("^([^:]+):(.+)$")
    if tileset and tileId then
        local tiles = Tilesets.getTileset(tileset)
        if tiles and tiles[tileId] then
            self.selectedTile = tileKey
            print(string.format("[MapEditor] Selected tile: %s", tileKey))
        else
            print(string.format("[MapEditor] Invalid tile: %s", tileKey))
        end
    else
        print(string.format("[MapEditor] Invalid tile KEY format: %s", tileKey))
    end
end

---Set tool (paint or erase)
---@param tool string Tool name ("paint" or "erase")
function MapEditor:setTool(tool)
    if tool == "paint" or tool == "erase" then
        self.currentTool = tool
        self.tool = tool
        print(string.format("[MapEditor] Tool: %s", tool))
    end
end

---Save current state to history
function MapEditor:saveHistory()
    -- Remove any states after current index
    while #self.history > self.historyIndex do
        table.remove(self.history)
    end
    
    -- Deep copy current grid
    local state = {
        grid = {},
        metadata = {}
    }
    
    for key, value in pairs(self.grid) do
        state.grid[key] = value
    end
    
    for key, value in pairs(self.metadata) do
        state.metadata[key] = value
    end
    
    table.insert(self.history, state)
    self.historyIndex = #self.history
    
    -- Limit history to 50 states
    if #self.history > 50 then
        table.remove(self.history, 1)
        self.historyIndex = self.historyIndex - 1
    end
end

---Undo last action
function MapEditor:undo()
    if self.historyIndex > 1 then
        self.historyIndex = self.historyIndex - 1
        local state = self.history[self.historyIndex]
        
        -- Restore grid
        self.grid = {}
        for key, value in pairs(state.grid) do
            self.grid[key] = value
        end
        
        -- Restore metadata
        for key, value in pairs(state.metadata) do
            self.metadata[key] = value
        end
        
        self.dirty = true
        print("[MapEditor] Undo")
    else
        print("[MapEditor] Nothing to undo")
    end
end

---Redo last undone action
function MapEditor:redo()
    if self.historyIndex < #self.history then
        self.historyIndex = self.historyIndex + 1
        local state = self.history[self.historyIndex]
        
        -- Restore grid
        self.grid = {}
        for key, value in pairs(state.grid) do
            self.grid[key] = value
        end
        
        -- Restore metadata
        for key, value in pairs(state.metadata) do
            self.metadata[key] = value
        end
        
        self.dirty = true
        print("[MapEditor] Redo")
    else
        print("[MapEditor] Nothing to redo")
    end
end

---Update metadata
---@param field string Field name
---@param value any New value
function MapEditor:setMetadata(field, value)
    if self.metadata[field] ~= nil then
        self.metadata[field] = value
        self.dirty = true
        self:saveHistory()
    end
end

---Load Map Block from file
---@param filepath string Path to TOML file
---@return boolean success
function MapEditor:load(filepath)
    local block = MapBlockLoader.loadBlock(filepath)
    if not block then
        print(string.format("[MapEditor] Failed to load: %s", filepath))
        return false
    end
    
    -- Resize if needed
    self.width = block.width
    self.height = block.height
    
    -- Load grid
    self.grid = {}
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            self.grid[key] = block.tiles[key] or "EMPTY"
        end
    end
    
    -- Load metadata
    self.metadata = {
        id = block.id,
        name = block.name,
        group = block.group,
        tags = block.tags,
        author = block.author or "Unknown",
        difficulty = block.difficulty or 1
    }
    
    self.dirty = false
    self.history = {}
    self.historyIndex = 0
    self:saveHistory()
    
    print(string.format("[MapEditor] Loaded: %s", filepath))
    return true
end

---Save Map Block to TOML file
---@param filepath string Path to save TOML file
---@return boolean success
function MapEditor:save(filepath)
    -- Validate metadata
    if not self.metadata.id or self.metadata.id == "" then
        print("[MapEditor] Cannot save: ID is required")
        return false
    end
    
    -- Build TOML content
    local toml = {}
    table.insert(toml, "[metadata]")
    table.insert(toml, string.format('id = "%s"', self.metadata.id))
    table.insert(toml, string.format('name = "%s"', self.metadata.name))
    table.insert(toml, string.format('description = "Created with Map Editor"'))
    table.insert(toml, string.format('width = %d', self.width))
    table.insert(toml, string.format('height = %d', self.height))
    table.insert(toml, string.format('group = %d', self.metadata.group))
    table.insert(toml, string.format('tags = "%s"', self.metadata.tags))
    table.insert(toml, string.format('author = "%s"', self.metadata.author))
    table.insert(toml, string.format('difficulty = %d', self.metadata.difficulty))
    table.insert(toml, "")
    table.insert(toml, "[tiles]")
    
    -- Add tiles (skip EMPTY)
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            local tileKey = self.grid[key]
            if tileKey and tileKey ~= "EMPTY" then
                table.insert(toml, string.format('"%s" = "%s"', key, tileKey))
            end
        end
    end
    
    -- Write to file
    local file = io.open(filepath, "w")
    if not file then
        print(string.format("[MapEditor] Cannot write file: %s", filepath))
        return false
    end
    
    file:write(table.concat(toml, "\n"))
    file:close()
    
    self.dirty = false
    self.isDirty = false
    print(string.format("[MapEditor] Saved: %s", filepath))
    return true
end

---Get statistics
---@return table stats {totalTiles, filledTiles, emptyTiles, fillPercentage, uniqueTiles}
function MapEditor:getStats()
    local totalTiles = self.width * self.height
    local filledTiles = 0
    local uniqueTiles = {}
    
    for key, tileKey in pairs(self.grid) do
        if tileKey and tileKey ~= "EMPTY" then
            filledTiles = filledTiles + 1
            uniqueTiles[tileKey] = true
        end
    end
    
    local uniqueCount = 0
    for _ in pairs(uniqueTiles) do
        uniqueCount = uniqueCount + 1
    end
    
    return {
        totalTiles = totalTiles,
        filledTiles = filledTiles,
        emptyTiles = totalTiles - filledTiles,
        fillPercentage = (filledTiles / totalTiles) * 100,
        uniqueTiles = uniqueCount
    }
end

---New blank block
---@param width number? Optional new width (defaults to current)
---@param height number? Optional new height (defaults to current)
function MapEditor:new_blank(width, height)
    -- Update dimensions if provided
    if width then self.width = width end
    if height then self.height = height end
    
    -- Clear grid and initialize
    self.grid = {}
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            self.grid[key] = "EMPTY"
        end
    end
    
    -- Reset metadata
    self.metadata = {
        id = "",
        name = "",
        group = 0,
        tags = "",
        author = "",
        difficulty = 1
    }
    
    self.dirty = false
    self.history = {}
    self.historyIndex = 0
    self:saveHistory()
    
    print("[MapEditor] New blank block created")
end

---Get metadata field
---@param field string Metadata field name
---@return any
function MapEditor:getMetadata(field)
    return self.metadata[field]
end

---Get editor statistics
---@return table stats {totalTiles, filledTiles, fillPercentage, uniqueTiles}
function MapEditor:getStats()
    local totalTiles = self.width * self.height
    local filledTiles = 0
    local uniqueTiles = {}
    
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local tile = self:getTile(x, y)
            if tile and tile ~= "EMPTY" then
                filledTiles = filledTiles + 1
                uniqueTiles[tile] = true
            end
        end
    end
    
    return {
        totalTiles = totalTiles,
        filledTiles = filledTiles,
        fillPercentage = (filledTiles / totalTiles) * 100,
        uniqueTiles = #uniqueTiles
    }
end

---Undo last action
function MapEditor:undo()
    if self.historyIndex > 0 then
        self.historyIndex = self.historyIndex - 1
        self:restoreFromHistory()
    end
end

---Redo last undone action
function MapEditor:redo()
    if self.historyIndex < #self.history then
        self.historyIndex = self.historyIndex + 1
        self:restoreFromHistory()
    end
end

---Create new blank block
---@param width number? Block width (default 15)
---@param height number? Block height (default 15)
function MapEditor:new_blank(width, height)
    width = width or 15
    height = height or 15
    
    -- Clear current data
    self.width = width
    self.height = height
    self.grid = {}
    self.metadata = {
        id = "new_block",
        name = "New Map Block",
        group = 0,
        tags = "custom",
        author = "Unknown",
        difficulty = 1
    }
    
    -- Initialize empty grid
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            self.grid[key] = "EMPTY"
        end
    end
    
    self.dirty = false
    self.history = {}
    self.historyIndex = 0
    self:saveHistory()
    
    print("[MapEditor] New blank block created")
end

---Set current tool
---@param tool string "paint" or "erase"
function MapEditor:setTool(tool)
    if tool == "paint" or tool == "erase" then
        self.tool = tool
    end
end

---Paint tile at position
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
function MapEditor:paintTile(x, y)
    if self.selectedTile then
        self:setTile(x, y, self.selectedTile)
        self:saveHistory()
    end
end

---Erase tile at position
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
function MapEditor:eraseTile(x, y)
    self:setTile(x, y, "EMPTY")
    self:saveHistory()
end

---Select tileset
---@param tilesetId string Tileset identifier
function MapEditor:selectTileset(tilesetId)
    self.selectedTileset = tilesetId
    self.selectedTile = nil
end

---Select tile
---@param tileKey string Map Tile KEY
function MapEditor:selectTile(tileKey)
    self.selectedTile = tileKey
end

---Get editor statistics
---@return table stats {totalTiles, filledTiles, fillPercentage, uniqueTiles}
function MapEditor:getStats()
    local totalTiles = self.width * self.height
    local filledTiles = 0
    local uniqueTiles = {}
    
    for y = 1, self.height do
        for x = 1, self.width do
            local key = self:getTile(x, y)
            if key and key ~= "EMPTY" then
                filledTiles = filledTiles + 1
                uniqueTiles[key] = true
            end
        end
    end
    
    return {
        totalTiles = totalTiles,
        filledTiles = filledTiles,
        fillPercentage = (filledTiles / totalTiles) * 100,
        uniqueTiles = #uniqueTiles
    }
end

---Undo last action
function MapEditor:undo()
    if self.historyIndex > 1 then
        self.historyIndex = self.historyIndex - 1
        self.grid = self:deepCopy(self.history[self.historyIndex])
        self.isDirty = true
    end
end

---Redo last undone action
function MapEditor:redo()
    if self.historyIndex < #self.history then
        self.historyIndex = self.historyIndex + 1
        self.grid = self:deepCopy(self.history[self.historyIndex])
        self.isDirty = true
    end
end

---Create new blank map
function MapEditor:new_blank()
    self.grid = {}
    self.metadata = {
        id = "new_block",
        name = "New Map Block",
        group = 0,
        tags = "custom",
        author = "Unknown",
        difficulty = 1
    }
    self.history = {{}}
    self.historyIndex = 1
    self.isDirty = false
end

---Set current tool
---@param tool string Tool name ("paint" or "erase")
function MapEditor:setTool(tool)
    if tool == "paint" or tool == "erase" then
        self.tool = tool
    end
end

return MapEditor
