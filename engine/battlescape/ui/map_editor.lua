---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
---@diagnostic disable: duplicate-doc-field
---@diagnostic disable: luadoc-miss-module-name
---MapEditor - Visual Map Block Creation and Editing Tool
---
---Interactive visual editor for creating and modifying 15×15 map blocks used in procedural
---map generation. Features paint/erase tools, tileset selection, undo/redo, and TOML export.
---Part of map editor enhancement (Phase 5).
---
---Features:
---  - Visual tile painting and erasing
---  - Tileset browser integration
---  - Undo/redo system with history tracking
---  - Zoom and pan camera controls
---  - Metadata editing (ID, name, group, tags, difficulty)
---  - TOML export for map block definitions
---  - Grid overlay and coordinate display
---  - Real-time preview of edited blocks
---
---Key Exports:
---  - new(width, height): Create new map editor instance
---  - loadFromTOML(filepath): Load existing map block from TOML file
---  - saveToTOML(filepath): Export current block to TOML file
---  - setTile(x, y, tileKey): Set tile at coordinates
---  - getTile(x, y): Get tile key at coordinates
---  - undo(): Undo last action
---  - redo(): Redo undone action
---  - update(dt): Update editor state
---  - draw(): Render editor interface
---  - mousepressed(x, y, button): Handle mouse input
---  - keypressed(key): Handle keyboard shortcuts
---
---Dependencies:
---  - require("widgets"): UI widget library
---  - require("battlescape.data.tilesets"): Tileset definitions
---  - require("battlescape.maps.mapblock_loader_v2"): Map block I/O
---
---@module battlescape.ui.map_editor
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapEditor = require("battlescape.ui.map_editor")
---  local editor = MapEditor.new(15, 15)
---  editor:loadFromTOML("maps/forest_01.toml")
---  -- Edit tiles interactively
---  editor:saveToTOML("maps/custom_block.toml")
---
---@see battlescape.ui.tileset_browser For tileset selection interface
---@see battlescape.maps.mapblock_loader_v2 For TOML map block format

-- Map Editor - Visual Map Block Editor
-- Phase 5: Map Editor Enhancement
-- Allows visual editing of Map Blocks with paint/erase tools

local Widgets = require("gui.widgets.init")
local Tilesets = require("battlescape.data.tilesets")
local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")

---@class MapEditor
local MapEditor = {}
MapEditor.__index = MapEditor

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

---Create new blank map
---@param width number New width in tiles
---@param height number New height in tiles
function MapEditor:new_blank(width, height)
    self.width = width or 15
    self.height = height or 15
    self.grid = {}
    self.metadata = {
        id = "",
        name = "New Map Block",
        group = 0,
        tags = "custom",
        author = "Map Editor",
        difficulty = 1
    }
    self.selectedTileset = nil
    self.selectedTile = nil
    self.currentTool = "paint"
    self.tool = "paint"
    self.camera = {x = 0, y = 0}
    self.zoom = 1
    self.history = {}
    self.historyIndex = 0
    self.dirty = false
    self.isDirty = false

    -- Initialize empty grid
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            self.grid[key] = "EMPTY"
        end
    end

    self:saveHistory()
    print(string.format("[MapEditor] New blank map: %dx%d", self.width, self.height))
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

---Get map statistics
---@return table statistics {totalTiles, filledTiles, uniqueTiles, fillPercentage}
function MapEditor:getStats()
    local totalTiles = self.width * self.height
    local filledTiles = 0
    local uniqueTiles = {}

    -- Count filled tiles and track unique tiles
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local key = string.format("%d_%d", x, y)
            local tileKey = self.grid[key]
            if tileKey and tileKey ~= "EMPTY" then
                filledTiles = filledTiles + 1
                uniqueTiles[tileKey] = true
            end
        end
    end

    -- Count unique tiles
    local uniqueCount = 0
    for _ in pairs(uniqueTiles) do
        uniqueCount = uniqueCount + 1
    end

    -- Calculate percentage
    local fillPercentage = (filledTiles / totalTiles) * 100

    return {
        totalTiles = totalTiles,
        filledTiles = filledTiles,
        uniqueTiles = uniqueCount,
        fillPercentage = fillPercentage
    }
end

return MapEditor
