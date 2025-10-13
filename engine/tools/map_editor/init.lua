--- Map Editor Module
--- Interactive hex grid map editor with tile palette and save/load functionality.
---
--- Allows creating and editing mapblock TOML files with a visual interface.
--- Features tile painting, terrain selection, and map validation.
---
--- @class MapEditor
--- @field mapData table Current map data being edited
--- @field selectedTileType string Currently selected terrain type
--- @field tilePalette table Available terrain tiles
--- @field brushSize number Size of the painting brush
--- @field showGrid boolean Whether to display grid overlay
---
--- @usage
---   local MapEditor = require("tools.map_editor.init")
---   MapEditor:enter()  -- Initialize editor
---   MapEditor:draw()   -- Render editor interface

-- Map Editor Module
-- Interactive hex grid map editor with tile palette and save/load functionality
-- Allows creating and editing mapblock TOML files

local StateManager = require("core.state_manager")
local Widgets = require("widgets.init")
local DataLoader = require("core.data_loader")
local ModManager = require("core.mod_manager")
local MapBlock = require("battlescape.map.map_block")

local MapEditor = {}

-- Constants
local TILE_SIZE = 24
local MAP_WIDTH = 15  -- Standard mapblock size
local MAP_HEIGHT = 15
local GUI_WIDTH = 240  -- 10 tiles × 24px

function MapEditor:enter()
    print("[MapEditor] Entering map editor state")
    
    -- Window dimensions
    local windowWidth = 960
    local windowHeight = 720
    
    -- Current map data
    self.currentMap = {
        id = "new_map",
        name = "Untitled Map",
        width = MAP_WIDTH,
        height = MAP_HEIGHT,
        biome = "mixed",
        tiles = {}
    }
    
    -- Initialize empty map with floor tiles
    for y = 1, MAP_HEIGHT do
        self.currentMap.tiles[y] = {}
        for x = 1, MAP_WIDTH do
            self.currentMap.tiles[y][x] = "floor"
        end
    end
    
    -- Editor state
    self.activeTerrain = "floor"  -- Currently selected tile
    self.mapList = {}  -- Available mapblocks
    self.terrainList = {}  -- Available terrain types
    self.filteredMapList = {}
    self.filteredTerrainList = {}
    self.mapFilter = ""
    self.terrainFilter = ""
    
    -- Undo/Redo system
    self.undoStack = {}
    self.redoStack = {}
    self.maxUndoHistory = 50
    
    -- Camera/viewport for editor grid
    self.cameraX = 0
    self.cameraY = 0
    self.centerOffsetX = GUI_WIDTH  -- Start of center panel
    self.centerWidth = windowWidth - GUI_WIDTH * 2  -- 480px
    self.centerHeight = windowHeight  -- 720px
    
    -- Load available maps
    self:scanMapblocks()
    
    -- Load available terrain types
    self:loadTerrainTypes()
    
    -- Initialize UI
    self:initUI()
    
    print("[MapEditor] Map editor initialized")
end

function MapEditor:exit()
    print("[MapEditor] Exiting map editor state")
end

-- Scan available mapblocks
function MapEditor:scanMapblocks()
    self.mapList = {}
    
    local mapblocksPath = ModManager.getContentPath("mapblocks")
    if not mapblocksPath then
        print("[MapEditor] ERROR: Could not get mapblocks path")
        return
    end
    
    local blockPool = MapBlock.loadAll(mapblocksPath)
    
    for _, block in ipairs(blockPool) do
        table.insert(self.mapList, {
            id = block.id,
            name = block.name or block.id,
            biome = block.biome or "unknown",
            block = block
        })
    end
    
    self:updateMapFilter()
    
    print(string.format("[MapEditor] Loaded %d mapblocks", #self.mapList))
end

-- Load available terrain types
function MapEditor:loadTerrainTypes()
    self.terrainList = {}
    
    local terrainTypes = DataLoader.terrainTypes.getAll()
    
    for id, terrain in pairs(terrainTypes) do
        table.insert(self.terrainList, {
            id = id,
            name = terrain.name or id,
            color = terrain.color or {100, 100, 100}
        })
    end
    
    -- Sort by name
    table.sort(self.terrainList, function(a, b)
        return a.name < b.name
    end)
    
    self:updateTerrainFilter()
    
    print(string.format("[MapEditor] Loaded %d terrain types", #self.terrainList))
end

-- Update map list filter
function MapEditor:updateMapFilter()
    self.filteredMapList = {}
    
    local filter = self.mapFilter:lower()
    
    for _, map in ipairs(self.mapList) do
        if filter == "" or 
           map.name:lower():find(filter, 1, true) or
           map.biome:lower():find(filter, 1, true) then
            table.insert(self.filteredMapList, map.name)
        end
    end
    
    -- Update ListBox items
    if self.mapListBox then
        self.mapListBox.items = self.filteredMapList
    end
end

-- Update terrain palette filter
function MapEditor:updateTerrainFilter()
    self.filteredTerrainList = {}
    
    local filter = self.terrainFilter:lower()
    
    for _, terrain in ipairs(self.terrainList) do
        if filter == "" or terrain.name:lower():find(filter, 1, true) then
            table.insert(self.filteredTerrainList, terrain.name)
        end
    end
    
    -- Update ListBox items
    if self.terrainListBox then
        self.terrainListBox.items = self.filteredTerrainList
    end
end

-- Initialize UI
function MapEditor:initUI()
    local windowWidth = 960
    local windowHeight = 720
    
    -- LEFT PANEL: Map List (0, 0) - (240, 720)
    self.leftPanel = Widgets.Panel.new(0, 0, GUI_WIDTH, windowHeight)
    
    -- Map list title
    self.mapListLabel = Widgets.Label.new(24, 24, 192, 24, "MAP LIST")
    self.leftPanel:addChild(self.mapListLabel)
    
    -- Map filter
    self.mapFilterInput = Widgets.TextInput.new(24, 72, 192, 24, "")
    self.mapFilterInput.placeholder = "Filter maps..."
    self.mapFilterInput.onChange = function(text)
        self.mapFilter = text
        self:updateMapFilter()
    end
    self.leftPanel:addChild(self.mapFilterInput)
    
    -- Map list box
    self.mapListBox = Widgets.ListBox.new(24, 120, 192, 456)
    self.mapListBox.items = self.filteredMapList
    self.mapListBox.onSelect = function(index, item)
        self:loadMapFromList(item)
    end
    self.leftPanel:addChild(self.mapListBox)
    
    -- New map button
    self.newMapButton = Widgets.Button.new(24, 600, 90, 48, "NEW")
    self.newMapButton.onClick = function()
        self:createNewMap()
    end
    self.leftPanel:addChild(self.newMapButton)
    
    -- Save button
    self.saveButton = Widgets.Button.new(126, 600, 90, 48, "SAVE")
    self.saveButton.onClick = function()
        self:saveCurrentMap()
    end
    self.leftPanel:addChild(self.saveButton)
    
    -- Back button
    self.backButton = Widgets.Button.new(24, 672, 192, 48, "BACK TO MENU")
    self.backButton.onClick = function()
        StateManager.switch("menu")
    end
    self.leftPanel:addChild(self.backButton)
    
    -- RIGHT PANEL: Tile Palette (720, 0) - (960, 720)
    self.rightPanel = Widgets.Panel.new(windowWidth - GUI_WIDTH, 0, GUI_WIDTH, windowHeight)
    
    -- Terrain palette title
    self.terrainLabel = Widgets.Label.new(windowWidth - GUI_WIDTH + 24, 24, 192, 24, "TILE PALETTE")
    self.rightPanel:addChild(self.terrainLabel)
    
    -- Terrain filter
    self.terrainFilterInput = Widgets.TextInput.new(windowWidth - GUI_WIDTH + 24, 72, 192, 24, "")
    self.terrainFilterInput.placeholder = "Filter tiles..."
    self.terrainFilterInput.onChange = function(text)
        self.terrainFilter = text
        self:updateTerrainFilter()
    end
    self.rightPanel:addChild(self.terrainFilterInput)
    
    -- Terrain list box
    self.terrainListBox = Widgets.ListBox.new(windowWidth - GUI_WIDTH + 24, 120, 192, 576)
    self.terrainListBox.items = self.filteredTerrainList
    self.terrainListBox.onSelect = function(index, item)
        -- Find terrain ID from name
        for _, terrain in ipairs(self.terrainList) do
            if terrain.name == item then
                self.activeTerrain = terrain.id
                print("[MapEditor] Selected terrain: " .. terrain.id)
                break
            end
        end
    end
    self.rightPanel:addChild(self.terrainListBox)
    
    print("[MapEditor] UI initialized")
end

-- Create new blank map
function MapEditor:createNewMap()
    print("[MapEditor] Creating new map")
    
    self.currentMap = {
        id = "new_map_" .. os.time(),
        name = "Untitled Map",
        width = MAP_WIDTH,
        height = MAP_HEIGHT,
        biome = "mixed",
        tiles = {}
    }
    
    -- Initialize with floor tiles
    for y = 1, MAP_HEIGHT do
        self.currentMap.tiles[y] = {}
        for x = 1, MAP_WIDTH do
            self.currentMap.tiles[y][x] = "floor"
        end
    end
    
    -- Clear undo/redo
    self.undoStack = {}
    self.redoStack = {}
end

-- Load map from list
function MapEditor:loadMapFromList(mapName)
    print("[MapEditor] Loading map: " .. mapName)
    
    -- Find map in list
    for _, mapData in ipairs(self.mapList) do
        if mapData.name == mapName then
            local block = mapData.block
            
            self.currentMap = {
                id = block.id,
                name = block.name or block.id,
                width = block.width,
                height = block.height,
                biome = block.biome or "mixed",
                tiles = {}
            }
            
            -- Copy tiles
            for y = 1, block.height do
                self.currentMap.tiles[y] = {}
                for x = 1, block.width do
                    self.currentMap.tiles[y][x] = block:getTile(x, y) or "floor"
                end
            end
            
            -- Clear undo/redo
            self.undoStack = {}
            self.redoStack = {}
            
            print("[MapEditor] Map loaded successfully")
            return
        end
    end
    
    print("[MapEditor] ERROR: Map not found")
end

-- Save current map
function MapEditor:saveCurrentMap()
    print("[MapEditor] Saving map: " .. self.currentMap.id)
    
    -- Create MapBlock object
    local block = MapBlock.new(self.currentMap.id, self.currentMap.width, self.currentMap.height)
    block.name = self.currentMap.name
    block.biome = self.currentMap.biome
    
    -- Set tiles
    for y = 1, self.currentMap.height do
        for x = 1, self.currentMap.width do
            block:setTile(x, y, self.currentMap.tiles[y][x])
        end
    end
    
    -- Get save path
    local mapblocksPath = ModManager.getContentPath("mapblocks")
    if not mapblocksPath then
        print("[MapEditor] ERROR: Could not get mapblocks path")
        return
    end
    
    local filename = mapblocksPath .. "/" .. self.currentMap.id .. ".toml"
    
    -- Save to TOML
    local success = block:saveToTOML(filename)
    
    if success then
        print("[MapEditor] Map saved successfully")
        -- Refresh map list
        self:scanMapblocks()
    else
        print("[MapEditor] ERROR: Failed to save map")
    end
end

function MapEditor:update(dt)
    -- Update UI widgets
    if self.leftPanel then self.leftPanel:update(dt) end
    if self.rightPanel then self.rightPanel:update(dt) end
end

function MapEditor:draw()
    -- Clear background
    love.graphics.clear(0.15, 0.15, 0.2)
    
    -- Draw hex grid in center panel
    self:drawHexGrid()
    
    -- Draw UI panels
    if self.leftPanel then self.leftPanel:draw() end
    if self.rightPanel then self.rightPanel:draw() end
    
    -- Draw title/info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Map Editor - " .. self.currentMap.name, 250, 10)
    love.graphics.print("Active Tile: " .. self.activeTerrain, 250, 30)
end

function MapEditor:drawHexGrid()
    -- Draw grid in center panel
    local startX = self.centerOffsetX
    local startY = 0
    local gridWidth = self.centerWidth
    local gridHeight = self.centerHeight
    
    -- Clip to center panel
    love.graphics.setScissor(startX, startY, gridWidth, gridHeight)
    
    -- Draw tiles
    for y = 1, self.currentMap.height do
        for x = 1, self.currentMap.width do
            local tileX = startX + (x - 1) * TILE_SIZE
            local tileY = startY + (y - 1) * TILE_SIZE
            
            -- Get terrain color
            local terrainId = self.currentMap.tiles[y][x]
            local terrain = DataLoader.terrainTypes.get(terrainId)
            
            if terrain and terrain.color then
                love.graphics.setColor(terrain.color[1]/255, terrain.color[2]/255, terrain.color[3]/255)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            
            love.graphics.rectangle("fill", tileX, tileY, TILE_SIZE, TILE_SIZE)
            
            -- Grid lines
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("line", tileX, tileY, TILE_SIZE, TILE_SIZE)
        end
    end
    
    love.graphics.setScissor()
end

function MapEditor:mousepressed(x, y, button)
    -- Check UI first
    if self.leftPanel and self.leftPanel:mousepressed(x, y, button) then return end
    if self.rightPanel and self.rightPanel:mousepressed(x, y, button) then return end
    
    -- Check hex grid clicks
    if button == 1 then  -- LMB: Paint
        self:paintTile(x, y)
    elseif button == 2 then  -- RMB: Pick
        self:pickTile(x, y)
    end
end

function MapEditor:mousereleased(x, y, button)
    if self.leftPanel then self.leftPanel:mousereleased(x, y, button) end
    if self.rightPanel then self.rightPanel:mousereleased(x, y, button) end
end

function MapEditor:mousemoved(x, y, dx, dy)
    if self.leftPanel then self.leftPanel:mousemoved(x, y, dx, dy) end
    if self.rightPanel then self.rightPanel:mousemoved(x, y, dx, dy) end
end

function MapEditor:textinput(text)
    if self.leftPanel then self.leftPanel:textinput(text) end
    if self.rightPanel then self.rightPanel:textinput(text) end
end

function MapEditor:keypressed(key, scancode, isrepeat)
    if self.leftPanel then self.leftPanel:keypressed(key) end
    if self.rightPanel then self.rightPanel:keypressed(key) end
    
    -- Undo/Redo
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
        if key == "z" then
            self:undo()
        elseif key == "y" then
            self:redo()
        end
    end
end

-- Paint tile at mouse position
function MapEditor:paintTile(mx, my)
    -- Convert mouse to grid coordinates
    local gridX = math.floor((mx - self.centerOffsetX) / TILE_SIZE) + 1
    local gridY = math.floor(my / TILE_SIZE) + 1
    
    -- Check bounds
    if gridX < 1 or gridX > self.currentMap.width or
       gridY < 1 or gridY > self.currentMap.height then
        return
    end
    
    -- Save to undo stack
    local oldTerrain = self.currentMap.tiles[gridY][gridX]
    table.insert(self.undoStack, {x = gridX, y = gridY, terrain = oldTerrain})
    
    if #self.undoStack > self.maxUndoHistory then
        table.remove(self.undoStack, 1)
    end
    
    -- Clear redo stack
    self.redoStack = {}
    
    -- Paint tile
    self.currentMap.tiles[gridY][gridX] = self.activeTerrain
    
    print(string.format("[MapEditor] Painted %s at (%d, %d)", self.activeTerrain, gridX, gridY))
end

-- Pick tile at mouse position
function MapEditor:pickTile(mx, my)
    -- Convert mouse to grid coordinates
    local gridX = math.floor((mx - self.centerOffsetX) / TILE_SIZE) + 1
    local gridY = math.floor(my / TILE_SIZE) + 1
    
    -- Check bounds
    if gridX < 1 or gridX > self.currentMap.width or
       gridY < 1 or gridY > self.currentMap.height then
        return
    end
    
    -- Pick terrain
    self.activeTerrain = self.currentMap.tiles[gridY][gridX]
    
    print(string.format("[MapEditor] Picked %s from (%d, %d)", self.activeTerrain, gridX, gridY))
end

-- Undo last action
function MapEditor:undo()
    if #self.undoStack == 0 then return end
    
    local action = table.remove(self.undoStack)
    
    -- Save current state to redo
    local currentTerrain = self.currentMap.tiles[action.y][action.x]
    table.insert(self.redoStack, {x = action.x, y = action.y, terrain = currentTerrain})
    
    -- Restore old state
    self.currentMap.tiles[action.y][action.x] = action.terrain
    
    print("[MapEditor] Undo")
end

-- Redo last undone action
function MapEditor:redo()
    if #self.redoStack == 0 then return end
    
    local action = table.remove(self.redoStack)
    
    -- Save current state to undo
    local currentTerrain = self.currentMap.tiles[action.y][action.x]
    table.insert(self.undoStack, {x = action.x, y = action.y, terrain = currentTerrain})
    
    -- Restore redo state
    self.currentMap.tiles[action.y][action.x] = action.terrain
    
    print("[MapEditor] Redo")
end

return MapEditor
