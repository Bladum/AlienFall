---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global
---@diagnostic disable: missing-parameter
-- World Editor Application
-- Standalone Love2D application for strategic world editing

-- Add engine directory to Lua path for require() to work
package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"

local World = require("geoscape.world.world")
local HexGrid = require("geoscape.systems.hex_grid")
local Widgets = require("gui.widgets.init")
local Theme = require("gui.widgets.core.theme")

local WorldEditorApp = {}

---Initialize the world editor application
function WorldEditorApp.init()
    print("[WorldEditorApp] Initializing...")

    -- Create world (90×45 hex grid as per spec)
    WorldEditorApp.world = World.new({
        id = "earth",
        name = "Earth",
        width = 90,
        height = 45
    })

    -- Editor state
    WorldEditorApp.selectedTile = nil
    WorldEditorApp.selectedProvince = nil
    WorldEditorApp.selectedRegion = nil
    WorldEditorApp.selectedCountry = nil
    WorldEditorApp.selectedBiome = nil
    WorldEditorApp.selectedTerrainType = "LAND"

    -- Layer display mode
    WorldEditorApp.layerMode = "province"  -- province, region, country, biome, terrain

    -- Canvas state
    WorldEditorApp.canvasX = 250
    WorldEditorApp.canvasY = 60
    WorldEditorApp.hexSize = 24
    WorldEditorApp.gridVisible = true

    -- UI state
    WorldEditorApp.isDragging = false
    WorldEditorApp.lastMouseX = 0
    WorldEditorApp.lastMouseY = 0

    -- Definitions loaded from TOML (cached)
    WorldEditorApp.definitions = {
        provinces = {},
        regions = {},
        countries = {},
        biomes = {}
    }

    print("[WorldEditorApp] Ready")
end

---Update (called each frame)
---@param dt number Delta time
function WorldEditorApp.update(dt)
    -- Nothing for now
end

---Draw the application
function WorldEditorApp.draw()
    -- Clear background
    love.graphics.clear(0.15, 0.15, 0.15, 1)

    -- Draw title bar
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 0, 0, 1200, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Theme.fonts.default)
    love.graphics.print("World Editor - " .. WorldEditorApp.world.name, 10, 14)

    -- Draw stats
    local statsText = string.format("Size: %dx%d | Layer: %s | Selected: %s",
        WorldEditorApp.world.width, WorldEditorApp.world.height,
        WorldEditorApp.layerMode:upper(),
        WorldEditorApp.selectedProvince or "NONE")
    love.graphics.print(statsText, 300, 14)

    -- Draw world canvas
    WorldEditorApp.drawCanvas()

    -- Draw left panel (definitions)
    WorldEditorApp.drawLeftPanel()

    -- Draw right panel (properties)
    WorldEditorApp.drawRightPanel()

    -- Draw help text
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("LMB: Select | RMB: Pan | Mouse Wheel: Zoom | P/R/C/B: Switch Layer | Ctrl+S: Save", 10, 760)
end

---Draw the canvas (world grid)
function WorldEditorApp.drawCanvas()
    love.graphics.push()

    -- Set scissor for canvas area
    love.graphics.setScissor(250, 60, 650, 700)

    -- Draw canvas background
    love.graphics.setColor(0.25, 0.25, 0.25, 1)
    love.graphics.rectangle("fill", 250, 60, 650, 700)

    -- Draw grid
    if WorldEditorApp.gridVisible then
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        for q = 0, WorldEditorApp.world.width do
            local screenX = WorldEditorApp.canvasX + q * WorldEditorApp.hexSize
            love.graphics.line(screenX, WorldEditorApp.canvasY,
                             screenX, WorldEditorApp.canvasY + WorldEditorApp.world.height * WorldEditorApp.hexSize)
        end
        for r = 0, WorldEditorApp.world.height do
            local screenY = WorldEditorApp.canvasY + r * WorldEditorApp.hexSize
            love.graphics.line(WorldEditorApp.canvasX, screenY,
                             WorldEditorApp.canvasX + WorldEditorApp.world.width * WorldEditorApp.hexSize, screenY)
        end
    end

    -- Draw hex grid with layer coloring
    for q = 0, WorldEditorApp.world.width - 1 do
        for r = 0, WorldEditorApp.world.height - 1 do
            local screenX = WorldEditorApp.canvasX + q * WorldEditorApp.hexSize
            local screenY = WorldEditorApp.canvasY + r * WorldEditorApp.hexSize

            -- Color based on layer mode
            local color = WorldEditorApp.getLayerColor(q, r)
            if color then
                love.graphics.setColor(color[1], color[2], color[3], 0.7)
                love.graphics.rectangle("fill", screenX + 1, screenY + 1,
                                      WorldEditorApp.hexSize - 2, WorldEditorApp.hexSize - 2)
            end

            -- Draw border
            love.graphics.setColor(0.5, 0.5, 0.5, 0.3)
            love.graphics.rectangle("line", screenX, screenY, WorldEditorApp.hexSize, WorldEditorApp.hexSize)
        end
    end

    -- Draw cursor highlight
    local mouseX, mouseY = love.mouse.getPosition()
    if mouseX >= WorldEditorApp.canvasX and mouseX < WorldEditorApp.canvasX + WorldEditorApp.world.width * WorldEditorApp.hexSize and
       mouseY >= WorldEditorApp.canvasY and mouseY < WorldEditorApp.canvasY + WorldEditorApp.world.height * WorldEditorApp.hexSize then

        local q = math.floor((mouseX - WorldEditorApp.canvasX) / WorldEditorApp.hexSize)
        local r = math.floor((mouseY - WorldEditorApp.canvasY) / WorldEditorApp.hexSize)

        local highlightX = WorldEditorApp.canvasX + q * WorldEditorApp.hexSize
        local highlightY = WorldEditorApp.canvasY + r * WorldEditorApp.hexSize

        love.graphics.setColor(1, 1, 0, 0.2)
        love.graphics.rectangle("fill", highlightX, highlightY, WorldEditorApp.hexSize, WorldEditorApp.hexSize)

        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.rectangle("line", highlightX, highlightY, WorldEditorApp.hexSize, WorldEditorApp.hexSize)
    end

    love.graphics.setScissor()
    love.graphics.pop()
end

---Get color for a tile based on current layer mode
---@param q number Hex column
---@param r number Hex row
---@return table? color {r, g, b} or nil
function WorldEditorApp.getLayerColor(q, r)
    -- For now, return default colors based on terrain type
    -- This would be populated from world tile data when implemented
    return {0.4, 0.6, 0.3}  -- Green for land
end

---Draw left panel (definitions)
function WorldEditorApp.drawLeftPanel()
    love.graphics.push()

    -- Left panel background
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 0, 48, 240, 752)

    -- Panel title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Theme.fonts.default)
    love.graphics.print("Definitions", 10, 60)

    -- Layer tabs (simplified)
    local tabs = {"Province", "Region", "Country", "Biome"}
    local tabWidth = 50
    for i, tab in ipairs(tabs) do
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        if WorldEditorApp.layerMode == tab:lower() then
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.rectangle("fill", 10 + (i-1) * (tabWidth + 5), 85, tabWidth, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print(tab:sub(1, 1), 15 + (i-1) * (tabWidth + 5), 90)
    end

    love.graphics.pop()
end

---Draw right panel (properties)
function WorldEditorApp.drawRightPanel()
    love.graphics.push()

    -- Right panel background
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 900, 48, 300, 752)

    -- Panel title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Theme.fonts.default)
    love.graphics.print("Properties", 910, 60)

    -- Show selected tile properties
    if WorldEditorApp.selectedTile then
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print("Selected Tile:", 910, 90)
        love.graphics.print("Q: " .. (WorldEditorApp.selectedTile.q or 0), 920, 110)
        love.graphics.print("R: " .. (WorldEditorApp.selectedTile.r or 0), 920, 130)
        love.graphics.print("Province: " .. (WorldEditorApp.selectedProvince or "None"), 920, 150)
        love.graphics.print("Biome: " .. (WorldEditorApp.selectedBiome or "None"), 920, 170)
        love.graphics.print("Terrain: " .. (WorldEditorApp.selectedTerrainType or "LAND"), 920, 190)
    else
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print("(No tile selected)", 910, 100)
    end

    love.graphics.pop()
end

---Handle mouse press
---@param x number Mouse X
---@param y number Mouse Y
---@param button number Button (1=left, 2=right)
function WorldEditorApp.mousepressed(x, y, button)
    -- Check canvas area
    if x >= WorldEditorApp.canvasX and x < WorldEditorApp.canvasX + WorldEditorApp.world.width * WorldEditorApp.hexSize and
       y >= WorldEditorApp.canvasY and y < WorldEditorApp.canvasY + WorldEditorApp.world.height * WorldEditorApp.hexSize then

        local q = math.floor((x - WorldEditorApp.canvasX) / WorldEditorApp.hexSize)
        local r = math.floor((y - WorldEditorApp.canvasY) / WorldEditorApp.hexSize)

        if button == 1 then -- Left click - select
            WorldEditorApp.selectedTile = {q = q, r = r}
            print(string.format("[WorldEditorApp] Selected tile: %d,%d", q, r))
            WorldEditorApp.isDragging = false
        elseif button == 2 then -- Right click - pan
            WorldEditorApp.isDragging = true
        end
    end
end

---Handle mouse release
---@param x number Mouse X
---@param y number Mouse Y
---@param button number Button
function WorldEditorApp.mousereleased(x, y, button)
    WorldEditorApp.isDragging = false
end

---Handle mouse wheel
---@param x number Scroll X
---@param y number Scroll Y
function WorldEditorApp.wheelmoved(x, y)
    if y > 0 then
        WorldEditorApp.hexSize = math.min(48, WorldEditorApp.hexSize + 2)
    else
        WorldEditorApp.hexSize = math.max(8, WorldEditorApp.hexSize - 2)
    end
end

---Handle key press
---@param key string Key name
function WorldEditorApp.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

    if key == "p" then
        WorldEditorApp.layerMode = "province"
    elseif key == "r" then
        WorldEditorApp.layerMode = "region"
    elseif key == "c" then
        WorldEditorApp.layerMode = "country"
    elseif key == "b" then
        WorldEditorApp.layerMode = "biome"
    elseif key == "f9" then
        WorldEditorApp.gridVisible = not WorldEditorApp.gridVisible
    elseif ctrl and key == "s" then
        print("[WorldEditorApp] Save not yet implemented")
    end
end

return WorldEditorApp
