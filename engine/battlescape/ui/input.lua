---BattlescapeInput - Battlescape Input Handler
---
---Handles all user input for the battlescape including keyboard, mouse, and touch controls.
---Manages unit selection, movement, actions, camera control, and UI interaction. Central
---input processing for tactical combat.
---
---Features:
---  - Keyboard input (WASD, hotkeys, ESC)
---  - Mouse input (click, drag, scroll)
---  - Unit selection and commands
---  - Camera pan and zoom
---  - Action shortcuts (F for shoot, R for reload, etc.)
---  - Menu navigation (ESC for pause/return)
---
---Input Mapping:
---  - ESC: Return to geoscape
---  - WASD: Camera pan
---  - Mouse click: Select unit/tile
---  - Mouse drag: Camera pan
---  - Mouse scroll: Zoom in/out
---  - F: Fire weapon
---  - R: Reload
---  - Space: End turn
---
---Key Exports:
---  - BattlescapeInput.keypressed(battlescape, key): Keyboard handler
---  - BattlescapeInput.mousepressed(battlescape, x, y, button): Mouse click
---  - BattlescapeInput.mousereleased(battlescape, x, y, button): Mouse release
---  - BattlescapeInput.mousemoved(battlescape, x, y, dx, dy): Mouse move
---  - BattlescapeInput.wheelmoved(battlescape, x, y): Mouse wheel
---
---Dependencies:
---  - core.state_manager: State switching
---
---@module battlescape.ui.input
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local BattlescapeInput = require("battlescape.ui.input")
---  function love.keypressed(key)
---    BattlescapeInput.keypressed(battlescape, key)
---  end
---
---@see battlescape.ui.combat_hud For HUD interaction

-- Battlescape Input Module
-- Handles all user input for the battlescape

local StateManager = require("core.state_manager")

local BattlescapeInput = {}

-- Constants
local TILE_SIZE = 24

function BattlescapeInput:keypressed(battlescape, key)
    if key == "escape" then
        -- Return to geoscape
        StateManager.switch("geoscape")
        return true
    elseif key == "g" then
        -- Toggle grid
        battlescape.battlefieldRenderer:toggleGrid()
        return true
    elseif key == "d" then
        -- Toggle debug view
        battlescape.showDebug = not battlescape.showDebug
        print("[Battlescape] Debug view: " .. tostring(battlescape.showDebug))
        return true
    elseif key == "n" then
        -- Toggle day/night
        battlescape:toggleDayNight()
        return true
    elseif key == "tab" then
        -- Cycle through units
        self:cycleUnitSelection(battlescape)
        return true
    elseif key == "return" or key == "kpenter" then
        -- End turn
        if battlescape.turnManager then
            battlescape.turnManager:endTurn()
        end
        return true
    elseif key == "f12" then
        -- Toggle fullscreen
        love.window.setFullscreen(not love.window.getFullscreen())
        return true
    end
    
    return false
end

function BattlescapeInput:mousepressed(battlescape, x, y, button)
    if button == 1 then  -- Left click
        if x < 720 then  -- Battlefield area
            self:handleBattlefieldClick(battlescape, x, y)
        else  -- GUI area
            self:handleGUIClick(battlescape, x, y)
        end
        return true
    elseif button == 2 then  -- Right click
        if x < 720 then  -- Battlefield area
            self:handleBattlefieldRightClick(battlescape, x, y)
        end
        return true
    elseif button == 3 then  -- Middle click
        -- Center camera on click position
        if x < 720 and battlescape.camera then
            local worldX, worldY = battlescape.camera:screenToWorld(x, y)
            battlescape.camera:centerOn(worldX, worldY)
        end
        return true
    end
    
    return false
end

function BattlescapeInput:mousemoved(battlescape, x, y, dx, dy)
    -- Handle camera panning with middle mouse button
    if love.mouse.isDown(3) and battlescape.camera then
        battlescape.camera:move(-dx / battlescape.camera.zoom, -dy / battlescape.camera.zoom)
        return true
    end
    
    -- Update hovered tile
    if x < 720 and battlescape.camera then
        local worldX, worldY = battlescape.camera:screenToWorld(x, y)
        local tileX = math.floor(worldX / TILE_SIZE) + 1
        local tileY = math.floor(worldY / TILE_SIZE) + 1
        
        battlescape.hoveredTile = {
            x = tileX,
            y = tileY,
            worldX = worldX,
            worldY = worldY
        }
    else
        battlescape.hoveredTile = nil
    end
    
    return false
end

function BattlescapeInput:wheelmoved(battlescape, x, y)
    -- Handle camera zoom
    if battlescape.camera then
        local zoomFactor = 1.1
        if y > 0 then
            battlescape.camera:zoomIn(zoomFactor)
        elseif y < 0 then
            battlescape.camera:zoomOut(zoomFactor)
        end
        return true
    end
    
    return false
end

function BattlescapeInput:handleBattlefieldClick(battlescape, x, y)
    if not battlescape.camera then return end
    
    -- Convert screen coordinates to world coordinates
    local worldX, worldY = battlescape.camera:screenToWorld(x, y)
    
    -- Convert world coordinates to tile coordinates
    local tileX = math.floor(worldX / TILE_SIZE) + 1
    local tileY = math.floor(worldY / TILE_SIZE) + 1
    
    -- Check bounds
    if tileX < 1 or tileX > battlescape.battlefield.width or 
       tileY < 1 or tileY > battlescape.battlefield.height then
        return
    end
    
    -- Try to select unit at this position
    local clickedUnit = self:findUnitAtPosition(battlescape, tileX, tileY)
    if clickedUnit then
        battlescape.unitSelection:selectUnit(clickedUnit)
        print(string.format("[Input] Selected unit: %s at (%d, %d)", 
            clickedUnit.type, tileX, tileY))
    else
        -- Deselect current unit
        battlescape.unitSelection:clearSelection()
        print(string.format("[Input] Clicked empty tile at (%d, %d)", tileX, tileY))
    end
end

function BattlescapeInput:handleBattlefieldRightClick(battlescape, x, y)
    if not battlescape.camera then return end
    
    -- Convert screen coordinates to world coordinates
    local worldX, worldY = battlescape.camera:screenToWorld(x, y)
    
    -- Convert world coordinates to tile coordinates
    local tileX = math.floor(worldX / TILE_SIZE) + 1
    local tileY = math.floor(worldY / TILE_SIZE) + 1
    
    -- Check bounds
    if tileX < 1 or tileX > battlescape.battlefield.width or 
       tileY < 1 or tileY > battlescape.battlefield.height then
        return
    end
    
    local selectedUnit = battlescape.unitSelection:getSelectedUnit()
    if selectedUnit then
        -- Try to move selected unit to this position
        if battlescape.pathfinding then
            local path = battlescape.pathfinding:findPath(
                selectedUnit.x, selectedUnit.y, 
                tileX * TILE_SIZE, tileY * TILE_SIZE,
                battlescape.battlefield
            )
            
            if path and #path > 0 then
                -- Execute movement
                selectedUnit:moveAlongPath(path)
                print(string.format("[Input] Moving unit to (%d, %d)", tileX, tileY))
            else
                print("[Input] No valid path found")
            end
        end
    end
end

function BattlescapeInput:handleGUIClick(battlescape, x, y)
    -- Handle GUI button clicks
    local guiX = x - 720  -- Adjust for GUI offset
    
    -- Action buttons area (y: 480-720)
    if y >= 480 and y <= 720 then
        local buttonIndex = math.floor((y - 490) / 30) + 1
        
        if buttonIndex == 1 then
            -- Move action
            print("[Input] Move action selected")
        elseif buttonIndex == 2 then
            -- Attack action
            print("[Input] Attack action selected")
        elseif buttonIndex == 3 then
            -- End turn
            if battlescape.turnManager then
                battlescape.turnManager:endTurn()
            end
        elseif buttonIndex == 4 then
            -- Toggle grid
            battlescape.battlefieldRenderer:toggleGrid()
        end
    end
end

function BattlescapeInput:findUnitAtPosition(battlescape, tileX, tileY)
    -- Convert tile coordinates to world coordinates (center of tile)
    local worldX = (tileX - 1) * TILE_SIZE + TILE_SIZE / 2
    local worldY = (tileY - 1) * TILE_SIZE + TILE_SIZE / 2
    
    -- Check all units
    for _, unit in ipairs(battlescape.units) do
        local distance = math.sqrt((unit.x - worldX)^2 + (unit.y - worldY)^2)
        if distance <= TILE_SIZE / 2 then  -- Within tile radius
            return unit
        end
    end
    
    return nil
end

function BattlescapeInput:cycleUnitSelection(battlescape)
    if #battlescape.units == 0 then return end
    
    local currentSelected = battlescape.unitSelection:getSelectedUnit()
    local currentIndex = 0
    
    -- Find current selection index
    if currentSelected then
        for i, unit in ipairs(battlescape.units) do
            if unit == currentSelected then
                currentIndex = i
                break
            end
        end
    end
    
    -- Select next unit
    local nextIndex = currentIndex + 1
    if nextIndex > #battlescape.units then
        nextIndex = 1
    end
    
    battlescape.unitSelection:selectUnit(battlescape.units[nextIndex])
    print(string.format("[Input] Cycled to unit %d/%d", nextIndex, #battlescape.units))
end

return BattlescapeInput

























