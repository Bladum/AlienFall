---LandingZonePreviewUI - Mission Map and Landing Zone Selection
---
---Interactive map preview showing terrain, objectives, and available landing zones for
---mission deployment. Allows players to select optimal insertion points based on terrain,
---objectives, and enemy positions. Part of mission setup and deployment systems (Batch 8).
---
---Features:
---  - Miniature map display with terrain visualization
---  - Landing zone markers with selection interface
---  - Objective and enemy position indicators
---  - Biome-based terrain coloring
---  - Hover tooltips for landing zone details
---  - Strategic deployment planning
---  - Map size scaling (small to huge missions)
---
---Key Exports:
---  - init(): Initialize/reset the UI state
---  - show(mapData, onConfirm, onCancel): Display map preview with landing zones
---  - hide(): Hide the preview screen
---  - isVisible(): Check if UI is currently visible
---  - update(dt): Update animations and hover states
---  - draw(): Render the map and landing zone interface
---  - mousepressed(x, y, button): Handle landing zone selection
---  - keypressed(key): Handle keyboard input
---
---Dependencies:
---  - require("widgets"): UI widget library for panels and buttons
---  - require("battlescape.maps.map_generator"): Map data structures
---
---@module battlescape.ui.landing_zone_preview_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local LandingZonePreviewUI = require("battlescape.ui.landing_zone_preview_ui")
---  LandingZonePreviewUI.init()
---  LandingZonePreviewUI.show(mapData, onLZSelected, onCancel)
---
---@see battlescape.ui.unit_deployment_ui For unit placement after LZ selection
---@see battlescape.maps.map_generator For map data generation

-- Landing Zone Preview UI System
-- Visual map preview showing landing zones and objectives
-- Part of Batch 8: Mission Setup & Deployment Systems

local LandingZonePreviewUI = {}

-- Configuration
local PANEL_WIDTH = 480
local PANEL_HEIGHT = 480
local PANEL_X = (960 - PANEL_WIDTH) / 2
local PANEL_Y = (720 - PANEL_HEIGHT) / 2
local PADDING = 12
local LINE_HEIGHT = 18

-- Map sizes to landing zone counts
local MAP_SIZE_TO_LZ = {
    SMALL = {grid = 4, lzCount = 1},   -- 4x4 blocks
    MEDIUM = {grid = 5, lzCount = 2},  -- 5x5 blocks
    LARGE = {grid = 6, lzCount = 3},   -- 6x6 blocks
    HUGE = {grid = 7, lzCount = 4}     -- 7x7 blocks
}

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    MAP_CELL = {r=60, g=80, b=70},
    LZ_AVAILABLE = {r=100, g=220, b=100},
    LZ_SELECTED = {r=255, g=200, b=60},
    LZ_HOVER = {r=140, g=240, b=140},
    OBJECTIVE_DEFEND = {r=100, g=140, b=220},
    OBJECTIVE_CAPTURE = {r=220, g=180, b=60},
    OBJECTIVE_CRITICAL = {r=220, g=60, b=60},
    ENEMY_INTEL = {r=255, g=80, b=80},
    BIOME_FOREST = {r=40, g=120, b=40},
    BIOME_URBAN = {r=100, g=100, b=120},
    BIOME_DESERT = {r=200, g=180, b=120},
    BIOME_ARCTIC = {r=180, g=220, b=240},
    BIOME_INDUSTRIAL = {r=80, g=80, b=80}
}

-- Biome colors map
local BIOME_COLORS = {
    FOREST = COLORS.BIOME_FOREST,
    URBAN = COLORS.BIOME_URBAN,
    DESERT = COLORS.BIOME_DESERT,
    ARCTIC = COLORS.BIOME_ARCTIC,
    INDUSTRIAL = COLORS.BIOME_INDUSTRIAL
}

-- State
local visible = false
local mapData = nil  -- {size, grid, biome, landingZones[], objectives[], enemyMarkers[]}
local selectedLZ = nil
local hoveredLZ = nil
local confirmCallback = nil
local cancelCallback = nil

--- Initialize landing zone preview UI
function LandingZonePreviewUI.init()
    visible = false
    mapData = nil
    selectedLZ = nil
    hoveredLZ = nil
    confirmCallback = nil
    cancelCallback = nil
end

--- Show landing zone preview
-- @param map Table {size, grid, biome, landingZones[], objectives[], enemyMarkers[]}
-- @param onConfirm Callback function: onConfirm(selectedLZ)
-- @param onCancel Callback function
function LandingZonePreviewUI.show(map, onConfirm, onCancel)
    mapData = map
    confirmCallback = onConfirm
    cancelCallback = onCancel
    visible = true
    
    -- Auto-select first landing zone
    if mapData and mapData.landingZones and #mapData.landingZones > 0 then
        selectedLZ = mapData.landingZones[1]
    end
end

--- Hide landing zone preview
function LandingZonePreviewUI.hide()
    visible = false
end

--- Check if visible
function LandingZonePreviewUI.isVisible()
    return visible
end

--- Draw the landing zone preview UI
function LandingZonePreviewUI.draw()
    if not visible or not mapData then return end
    
    -- Panel background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, COLORS.BACKGROUND.a/255)
    love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Panel border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Header
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("LANDING ZONE SELECTION", PANEL_X + PADDING, PANEL_Y + PADDING)
    
    -- Map size info
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Map: " .. (mapData.size or "MEDIUM"), PANEL_X + PADDING, PANEL_Y + PADDING + 24)
    love.graphics.print("Biome: " .. (mapData.biome or "UNKNOWN"), PANEL_X + PADDING, PANEL_Y + PADDING + 40)
    
    local lzCount = MAP_SIZE_TO_LZ[mapData.size] and MAP_SIZE_TO_LZ[mapData.size].lzCount or 2
    love.graphics.print("Landing Zones: " .. lzCount, PANEL_X + PADDING, PANEL_Y + PADDING + 56)
    
    -- Draw map grid
    local gridSize = mapData.grid or 5
    local mapAreaSize = 360
    local mapAreaX = PANEL_X + (PANEL_WIDTH - mapAreaSize) / 2
    local mapAreaY = PANEL_Y + 120
    local cellSize = mapAreaSize / gridSize
    
    -- Get biome color
    local biomeColor = BIOME_COLORS[mapData.biome] or COLORS.MAP_CELL
    
    -- Draw map cells
    for y = 0, gridSize - 1 do
        for x = 0, gridSize - 1 do
            local cellX = mapAreaX + x * cellSize
            local cellY = mapAreaY + y * cellSize
            
            -- Cell background (biome colored)
            love.graphics.setColor(biomeColor.r/255, biomeColor.g/255, biomeColor.b/255, 0.6)
            love.graphics.rectangle("fill", cellX, cellY, cellSize - 2, cellSize - 2)
            
            -- Cell border
            love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", cellX, cellY, cellSize - 2, cellSize - 2)
        end
    end
    
    -- Draw objectives
    if mapData.objectives then
        for _, obj in ipairs(mapData.objectives) do
            local objColor = COLORS.OBJECTIVE_DEFEND
            if obj.type == "CAPTURE" then
                objColor = COLORS.OBJECTIVE_CAPTURE
            elseif obj.type == "CRITICAL" then
                objColor = COLORS.OBJECTIVE_CRITICAL
            end
            
            local objX = mapAreaX + obj.x * cellSize + cellSize / 2
            local objY = mapAreaY + obj.y * cellSize + cellSize / 2
            
            -- Draw objective marker (star shape approximation)
            love.graphics.setColor(objColor.r/255, objColor.g/255, objColor.b/255, 0.9)
            love.graphics.circle("fill", objX, objY, 8)
            love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
            love.graphics.circle("line", objX, objY, 8)
        end
    end
    
    -- Draw enemy intel markers
    if mapData.enemyMarkers then
        for _, marker in ipairs(mapData.enemyMarkers) do
            local markerX = mapAreaX + marker.x * cellSize + cellSize / 2
            local markerY = mapAreaY + marker.y * cellSize + cellSize / 2
            
            love.graphics.setColor(COLORS.ENEMY_INTEL.r/255, COLORS.ENEMY_INTEL.g/255, COLORS.ENEMY_INTEL.b/255, 0.7)
            love.graphics.circle("fill", markerX, markerY, 6)
            love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
            love.graphics.circle("line", markerX, markerY, 6)
            
            -- Draw "E" for enemy
            love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
            love.graphics.print("E", markerX - 3, markerY - 6, 0, 0.8, 0.8)
        end
    end
    
    -- Draw landing zones
    if mapData.landingZones then
        for i, lz in ipairs(mapData.landingZones) do
            local isSelected = (selectedLZ and selectedLZ.id == lz.id)
            local isHovered = (hoveredLZ and hoveredLZ.id == lz.id)
            
            local lzColor = COLORS.LZ_AVAILABLE
            if isSelected then
                lzColor = COLORS.LZ_SELECTED
            elseif isHovered then
                lzColor = COLORS.LZ_HOVER
            end
            
            local lzX = mapAreaX + lz.x * cellSize
            local lzY = mapAreaY + lz.y * cellSize
            
            -- LZ highlight
            love.graphics.setColor(lzColor.r/255, lzColor.g/255, lzColor.b/255, 0.7)
            love.graphics.rectangle("fill", lzX, lzY, cellSize - 2, cellSize - 2)
            
            -- LZ border (thicker)
            love.graphics.setColor(lzColor.r/255, lzColor.g/255, lzColor.b/255)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", lzX, lzY, cellSize - 2, cellSize - 2)
            
            -- LZ number
            love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
            local lzLabel = "LZ" .. i
            local labelWidth = love.graphics.getFont():getWidth(lzLabel)
            love.graphics.print(lzLabel, lzX + (cellSize - labelWidth) / 2, lzY + cellSize / 2 - 8)
        end
    end
    
    -- Legend
    local legendY = mapAreaY + mapAreaSize + 12
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("LEGEND:", PANEL_X + PADDING, legendY)
    
    -- LZ legend
    love.graphics.setColor(COLORS.LZ_AVAILABLE.r/255, COLORS.LZ_AVAILABLE.g/255, COLORS.LZ_AVAILABLE.b/255)
    love.graphics.rectangle("fill", PANEL_X + PADDING, legendY + 18, 12, 12)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Landing Zone", PANEL_X + PADDING + 18, legendY + 18)
    
    -- Objective legend
    love.graphics.setColor(COLORS.OBJECTIVE_DEFEND.r/255, COLORS.OBJECTIVE_DEFEND.g/255, COLORS.OBJECTIVE_DEFEND.b/255)
    love.graphics.circle("fill", PANEL_X + PADDING + 6, legendY + 42, 6)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Objective", PANEL_X + PADDING + 18, legendY + 36)
    
    -- Enemy legend
    love.graphics.setColor(COLORS.ENEMY_INTEL.r/255, COLORS.ENEMY_INTEL.g/255, COLORS.ENEMY_INTEL.b/255)
    love.graphics.circle("fill", PANEL_X + PADDING + 156, legendY + 24, 6)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Enemy Intel", PANEL_X + PADDING + 168, legendY + 18)
    
    -- Confirm/Cancel buttons
    local confirmX = PANEL_X + PANEL_WIDTH - 120 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    love.graphics.setColor(COLORS.LZ_AVAILABLE.r/255, COLORS.LZ_AVAILABLE.g/255, COLORS.LZ_AVAILABLE.b/255)
    love.graphics.rectangle("fill", confirmX, confirmY, 108, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", confirmX, confirmY, 108, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CONFIRM", confirmX + 24, confirmY + 12)
    
    local cancelX = PANEL_X + PADDING
    love.graphics.setColor(COLORS.ENEMY_INTEL.r/255, COLORS.ENEMY_INTEL.g/255, COLORS.ENEMY_INTEL.b/255, 0.7)
    love.graphics.rectangle("fill", cancelX, confirmY, 84, 36)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", cancelX, confirmY, 84, 36)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CANCEL", cancelX + 18, confirmY + 12)
end

--- Handle mouse click
function LandingZonePreviewUI.handleClick(mouseX, mouseY)
    if not visible or not mapData then return false end
    
    -- Check landing zone clicks
    local gridSize = mapData.grid or 5
    local mapAreaSize = 360
    local mapAreaX = PANEL_X + (PANEL_WIDTH - mapAreaSize) / 2
    local mapAreaY = PANEL_Y + 120
    local cellSize = mapAreaSize / gridSize
    
    if mapData.landingZones then
        for _, lz in ipairs(mapData.landingZones) do
            local lzX = mapAreaX + lz.x * cellSize
            local lzY = mapAreaY + lz.y * cellSize
            
            if mouseX >= lzX and mouseX <= lzX + cellSize and
               mouseY >= lzY and mouseY <= lzY + cellSize then
                selectedLZ = lz
                return true
            end
        end
    end
    
    -- Check confirm button
    local confirmX = PANEL_X + PANEL_WIDTH - 120 - PADDING
    local confirmY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    if mouseX >= confirmX and mouseX <= confirmX + 108 and
       mouseY >= confirmY and mouseY <= confirmY + 36 then
        if selectedLZ and confirmCallback then
            confirmCallback(selectedLZ)
            LandingZonePreviewUI.hide()
        end
        return true
    end
    
    -- Check cancel button
    local cancelX = PANEL_X + PADDING
    if mouseX >= cancelX and mouseX <= cancelX + 84 and
       mouseY >= confirmY and mouseY <= confirmY + 36 then
        if cancelCallback then
            cancelCallback()
        end
        LandingZonePreviewUI.hide()
        return true
    end
    
    return false
end

--- Handle mouse movement
function LandingZonePreviewUI.handleMouseMove(mouseX, mouseY)
    if not visible or not mapData then return end
    
    hoveredLZ = nil
    
    local gridSize = mapData.grid or 5
    local mapAreaSize = 360
    local mapAreaX = PANEL_X + (PANEL_WIDTH - mapAreaSize) / 2
    local mapAreaY = PANEL_Y + 120
    local cellSize = mapAreaSize / gridSize
    
    if mapData.landingZones then
        for _, lz in ipairs(mapData.landingZones) do
            local lzX = mapAreaX + lz.x * cellSize
            local lzY = mapAreaY + lz.y * cellSize
            
            if mouseX >= lzX and mouseX <= lzX + cellSize and
               mouseY >= lzY and mouseY <= lzY + cellSize then
                hoveredLZ = lz
            end
        end
    end
end

--- Get selected landing zone
function LandingZonePreviewUI.getSelectedLZ()
    return selectedLZ
end

return LandingZonePreviewUI

























