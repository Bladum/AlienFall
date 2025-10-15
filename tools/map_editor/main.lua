---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global
---@diagnostic disable: missing-parameter
-- Map Editor Application
-- Phase 5: Map Editor Enhancement
-- Complete map editing application with UI

-- Add engine directory to Lua path for require() to work
package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"

local MapEditor = require("battlescape.ui.map_editor")
local TilesetBrowser = require("battlescape.ui.tileset_browser")
local TilePalette = require("battlescape.ui.tile_palette")
local Tilesets = require("battlescape.data.tilesets")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local Widgets = require("widgets.init")
local Theme = require("widgets.core.theme")

local MapEditorApp = {}

---Initialize the map editor application
function MapEditorApp.init()
    print("[MapEditorApp] Initializing...")
    
    -- Load tilesets
    Tilesets.loadAll("mods/core/tilesets")
    
    -- Create editor
    MapEditorApp.editor = MapEditor.new(15, 15)
    
    -- Get tileset list
    local tilesetList = {}
    for id, tileset in pairs(Tilesets.getAll()) do
        table.insert(tilesetList, {id = id, tileset = tileset})
    end
    table.sort(tilesetList, function(a, b) return a.id < b.id end)
    
    -- Create UI widgets (using 24×24 grid)
    -- Left panel: Tileset Browser (10 cols × 20 rows = 240×480)
    MapEditorApp.tilesetBrowser = TilesetBrowser.new(0, 48, 240, 480, tilesetList)
    -- MapEditorApp.tilesetBrowser.onSelect = function(tilesetId)
    --     MapEditorApp.tilePalette:setTileset(tilesetId)
    --     MapEditorApp.editor:selectTileset(tilesetId)
    -- end
    
    -- Right panel: Tile Palette (10 cols × 20 rows = 240×480)
    MapEditorApp.tilePalette = TilePalette.new(720, 48, 240, 480)
    -- MapEditorApp.tilePalette.onSelect = function(tileKey)
    --     MapEditorApp.editor:selectTile(tileKey)
    -- end
    
    -- Canvas offset and zoom
    MapEditorApp.canvasX = 250
    MapEditorApp.canvasY = 60
    MapEditorApp.tileSize = 24
    MapEditorApp.gridVisible = true
    
    -- Tool state
    MapEditorApp.isDragging = false
    MapEditorApp.lastMouseX = 0
    MapEditorApp.lastMouseY = 0
    
    print("[MapEditorApp] Ready")
end

---Update (called each frame)
---@param dt number Delta time
function MapEditorApp.update(dt)
    -- Nothing for now
end

---Draw the application
function MapEditorApp.draw()
    -- Clear background
    love.graphics.clear(0.15, 0.15, 0.15, 1)
    
    -- Draw title bar
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 0, 0, 960, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Theme.fonts.default)
    love.graphics.print("Map Editor - " .. MapEditorApp.editor.metadata.name, 10, 14)
    
    -- Draw stats
    local stats = MapEditorApp.editor:getStats()
    local statsText = string.format("Size: %dx%d | Fill: %.1f%% (%d/%d) | Unique: %d",
        MapEditorApp.editor.width, MapEditorApp.editor.height,
        stats.fillPercentage, stats.filledTiles, stats.totalTiles, stats.uniqueTiles)
    love.graphics.print(statsText, 300, 14)
    
    -- Draw tool indicator
    local tool = MapEditorApp.editor.tool
    local toolText = string.format("Tool: %s | Selected: %s", 
        tool:upper(), MapEditorApp.editor.selectedTile or "NONE")
    love.graphics.print(toolText, 300, 30)
    
    -- Draw canvas area
    MapEditorApp.drawCanvas()
    
    -- Draw UI widgets
    MapEditorApp.tilesetBrowser:draw()
    MapEditorApp.tilePalette:draw()
    
    -- Draw help text
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("LMB: Paint | RMB: Erase | Mouse Wheel: Zoom | F9: Grid | Ctrl+Z: Undo | Ctrl+Y: Redo | Ctrl+S: Save | Ctrl+O: Open", 10, 700)
end

---Draw the canvas (map grid)
function MapEditorApp.drawCanvas()
    love.graphics.push()
    
    -- Set scissor for canvas area
    love.graphics.setScissor(240, 48, 480, 672)
    
    -- Draw canvas background
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    love.graphics.rectangle("fill", 240, 48, 480, 672)
    
    -- Draw grid
    if MapEditorApp.gridVisible then
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        for y = 0, MapEditorApp.editor.height do
            local screenY = MapEditorApp.canvasY + y * MapEditorApp.tileSize
            love.graphics.line(MapEditorApp.canvasX, screenY,
                             MapEditorApp.canvasX + MapEditorApp.editor.width * MapEditorApp.tileSize, screenY)
        end
        for x = 0, MapEditorApp.editor.width do
            local screenX = MapEditorApp.canvasX + x * MapEditorApp.tileSize
            love.graphics.line(screenX, MapEditorApp.canvasY,
                             screenX, MapEditorApp.canvasY + MapEditorApp.editor.height * MapEditorApp.tileSize)
        end
    end
    
    -- Draw tiles
    for y = 0, MapEditorApp.editor.height - 1 do
        for x = 0, MapEditorApp.editor.width - 1 do
            local tileKey = MapEditorApp.editor:getTile(x, y)
            if tileKey and tileKey ~= "EMPTY" then
                local screenX = MapEditorApp.canvasX + x * MapEditorApp.tileSize
                local screenY = MapEditorApp.canvasY + y * MapEditorApp.tileSize
                
                -- Draw tile (placeholder - just a colored square)
                love.graphics.setColor(0.5, 0.6, 0.7, 1)
                love.graphics.rectangle("fill", screenX + 1, screenY + 1,
                                      MapEditorApp.tileSize - 2, MapEditorApp.tileSize - 2)
                
                -- Draw tile KEY (abbreviated)
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.setFont(Theme.fonts.small)
                local displayKey = tileKey:sub(1, 6)
                love.graphics.print(displayKey, screenX + 2, screenY + 2)
            end
        end
    end
    
    -- Draw cursor highlight
    local mouseX, mouseY = love.mouse.getPosition()
    if mouseX >= MapEditorApp.canvasX and mouseX < MapEditorApp.canvasX + MapEditorApp.editor.width * MapEditorApp.tileSize and
       mouseY >= MapEditorApp.canvasY and mouseY < MapEditorApp.canvasY + MapEditorApp.editor.height * MapEditorApp.tileSize then
        
        local tileX = math.floor((mouseX - MapEditorApp.canvasX) / MapEditorApp.tileSize)
        local tileY = math.floor((mouseY - MapEditorApp.canvasY) / MapEditorApp.tileSize)
        
        local highlightX = MapEditorApp.canvasX + tileX * MapEditorApp.tileSize
        local highlightY = MapEditorApp.canvasY + tileY * MapEditorApp.tileSize
        
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.rectangle("fill", highlightX, highlightY, MapEditorApp.tileSize, MapEditorApp.tileSize)
        
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.rectangle("line", highlightX, highlightY, MapEditorApp.tileSize, MapEditorApp.tileSize)
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
end

---Handle mouse press
---@param x number Mouse X
---@param y number Mouse Y
---@param button number Button (1=left, 2=right)
function MapEditorApp.mousepressed(x, y, button)
    -- Check UI widgets first
    -- if MapEditorApp.tilesetBrowser:handleClick(x, y, button) then
    --     return
    -- end
    -- if MapEditorApp.tilePalette:handleClick(x, y, button) then
    --     return
    -- end
    
    -- Check canvas area
    if x >= MapEditorApp.canvasX and x < MapEditorApp.canvasX + MapEditorApp.editor.width * MapEditorApp.tileSize and
       y >= MapEditorApp.canvasY and y < MapEditorApp.canvasY + MapEditorApp.editor.height * MapEditorApp.tileSize then
        
        local tileX = math.floor((x - MapEditorApp.canvasX) / MapEditorApp.tileSize)
        local tileY = math.floor((y - MapEditorApp.canvasY) / MapEditorApp.tileSize)
        
        if button == 1 then -- Left click - paint
            MapEditorApp.editor:paintTile(tileX, tileY)
            MapEditorApp.isDragging = true
        elseif button == 2 then -- Right click - erase
            MapEditorApp.editor:eraseTile(tileX, tileY)
            MapEditorApp.isDragging = true
        end
    end
end

---Handle mouse release
---@param x number Mouse X
---@param y number Mouse Y
---@param button number Button
function MapEditorApp.mousereleased(x, y, button)
    MapEditorApp.isDragging = false
end

---Handle mouse move
---@param x number Mouse X
---@param y number Mouse Y
function MapEditorApp.mousemoved(x, y, dx, dy)
    MapEditorApp.lastMouseX = x
    MapEditorApp.lastMouseY = y
    
    -- Handle drag painting/erasing
    if MapEditorApp.isDragging then
        if x >= MapEditorApp.canvasX and x < MapEditorApp.canvasX + MapEditorApp.editor.width * MapEditorApp.tileSize and
           y >= MapEditorApp.canvasY and y < MapEditorApp.canvasY + MapEditorApp.editor.height * MapEditorApp.tileSize then
            
            local tileX = math.floor((x - MapEditorApp.canvasX) / MapEditorApp.tileSize)
            local tileY = math.floor((y - MapEditorApp.canvasY) / MapEditorApp.tileSize)
            
            if love.mouse.isDown(1) then
                MapEditorApp.editor:paintTile(tileX, tileY)
            elseif love.mouse.isDown(2) then
                MapEditorApp.editor:eraseTile(tileX, tileY)
            end
        end
    end
end

---Handle mouse wheel
---@param x number Scroll X
---@param y number Scroll Y
function MapEditorApp.wheelmoved(x, y)
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- Check if over widgets
    if MapEditorApp.tilesetBrowser:isPointInside(mouseX, mouseY) then
        MapEditorApp.tilesetBrowser:handleScroll(y)
    elseif MapEditorApp.tilePalette:isPointInside(mouseX, mouseY) then
        MapEditorApp.tilePalette:handleScroll(y)
    else
        -- Zoom canvas
        if y > 0 then
            MapEditorApp.tileSize = math.min(48, MapEditorApp.tileSize + 2)
        else
            MapEditorApp.tileSize = math.max(8, MapEditorApp.tileSize - 2)
        end
    end
end

---Handle key press
---@param key string Key name
function MapEditorApp.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    
    if key == "f9" then
        MapEditorApp.gridVisible = not MapEditorApp.gridVisible
    elseif ctrl and key == "z" then
        MapEditorApp.editor:undo()
    elseif ctrl and key == "y" then
        MapEditorApp.editor:redo()
    elseif ctrl and key == "s" then
        -- Save
        local filepath = "mods/core/mapblocks/" .. MapEditorApp.editor.metadata.id .. ".toml"
        if MapEditorApp.editor:save(filepath) then
            print(string.format("[MapEditorApp] Saved to: %s", filepath))
        end
    elseif ctrl and key == "o" then
        -- Open (for now, just print message)
        print("[MapEditorApp] Open dialog not implemented - use editor:load(filepath)")
    elseif ctrl and key == "n" then
        -- New
        MapEditorApp.editor:new_blank(15, 15)
    elseif key == "p" then
        MapEditorApp.editor:setTool("paint")
    elseif key == "e" then
        MapEditorApp.editor:setTool("erase")
    end
end

return MapEditorApp






















