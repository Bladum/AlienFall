-- Battlescape Render Module
-- Handles all drawing operations for the battlescape

local BattlescapeRender = {}

-- Constants
local TILE_SIZE = 24
local MAP_WIDTH = 90
local MAP_HEIGHT = 90
local GUI_WIDTH = 240  -- 10 tiles × 24px
local GUI_HEIGHT = 720  -- 30 tiles × 24px
local SECTION_HEIGHT = 240  -- 10 tiles × 24px

function BattlescapeRender:draw(battlescape)
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.1, 1)
    
    -- Draw battlefield
    self:drawBattlefield(battlescape)
    
    -- Draw GUI
    self:drawGUI(battlescape)
    
    -- Draw debug info if enabled
    if battlescape.showDebug then
        self:drawDebugInfo(battlescape)
    end
end

function BattlescapeRender:drawBattlefield(battlescape)
    -- Set viewport for battlefield (left side)
    love.graphics.setScissor(0, 0, 720, 720)
    
    -- Draw the battlefield using the renderer
    battlescape.battlefieldRenderer:draw(
        battlescape.battlefield,
        battlescape.camera,
        battlescape.teamManager,
        battlescape.currentTeam,
        battlescape.isNight,
        720,
        720
    )
    
    -- Reset scissor
    love.graphics.setScissor()
end

function BattlescapeRender:drawGUI(battlescape)
    -- Set viewport for GUI (right side)
    love.graphics.setScissor(720, 0, 240, 720)
    
    -- Draw GUI background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill", 720, 0, 240, 720)
    
    -- Draw GUI border
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", 720, 0, 240, 720)
    
    -- Draw turn indicator
    self:drawTurnIndicator(battlescape)
    
    -- Draw unit info panel
    self:drawUnitInfoPanel(battlescape)
    
    -- Draw action buttons
    self:drawActionButtons(battlescape)
    
    -- Reset scissor
    love.graphics.setScissor()
end

function BattlescapeRender:drawTurnIndicator(battlescape)
    local turnText = string.format("Turn %d", battlescape.turnNumber or 1)
    local teamName = battlescape.currentTeam and battlescape.currentTeam.name or "Unknown"
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(turnText, 730, 10)
    love.graphics.print(teamName, 730, 30)
end

function BattlescapeRender:drawUnitInfoPanel(battlescape)
    local selectedUnit = battlescape.unitSelection:getSelectedUnit()
    
    if selectedUnit then
        -- Draw unit info
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Unit: " .. selectedUnit.type, 730, 60)
        love.graphics.print(string.format("HP: %d/%d", selectedUnit.health, selectedUnit.maxHealth), 730, 80)
        love.graphics.print(string.format("AP: %d/%d", selectedUnit.actionPoints, selectedUnit.maxActionPoints), 730, 100)
        
        -- Draw health bar
        local barX, barY = 730, 120
        local barWidth, barHeight = 200, 20
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
        love.graphics.setColor(0, 1, 0, 1)
        local healthPercent = selectedUnit.health / selectedUnit.maxHealth
        love.graphics.rectangle("fill", barX, barY, barWidth * healthPercent, barHeight)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("No unit selected", 730, 60)
    end
end

function BattlescapeRender:drawActionButtons(battlescape)
    -- Draw action buttons section
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", 720, 480, 240, 240)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", 720, 480, 240, 240)
    
    -- Draw button labels
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Actions:", 730, 490)
    
    local actions = {"Move", "Attack", "End Turn", "Toggle Grid"}
    for i, action in ipairs(actions) do
        local y = 510 + (i-1) * 30
        love.graphics.print(action, 740, y)
    end
end

function BattlescapeRender:drawDebugInfo(battlescape)
    -- Draw debug information overlay
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    
    local mouseX, mouseY = love.mouse.getPosition()
    love.graphics.print(string.format("Mouse: %d, %d", mouseX, mouseY), 10, 30)
    
    if battlescape.camera then
        love.graphics.print(string.format("Camera: %.1f, %.1f (zoom: %.2f)", 
            battlescape.camera.x, battlescape.camera.y, battlescape.camera.zoom), 10, 50)
    end
    
    local unitCount = battlescape:countUnits()
    love.graphics.print("Units: " .. unitCount, 10, 70)
end

return BattlescapeRender