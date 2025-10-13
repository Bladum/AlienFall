-- Battlescape UI Module
-- Handles UI initialization and management

local Widgets = require("widgets.init")

local BattlescapeUI = {}

-- Constants
local GUI_WIDTH = 240
local GUI_HEIGHT = 720
local SECTION_HEIGHT = 240

function BattlescapeUI:initUI(battlescape)
    print("[BattlescapeUI] Initializing UI components")
    
    battlescape.ui = {}
    
    -- Create main UI panel
    battlescape.ui.mainPanel = Widgets.Panel.new({
        x = 720,
        y = 0,
        width = GUI_WIDTH,
        height = GUI_HEIGHT,
        backgroundColor = {0.2, 0.2, 0.2, 0.9},
        borderColor = {0.5, 0.5, 0.5, 1}
    })
    
    -- Create turn indicator label
    battlescape.ui.turnLabel = Widgets.Label.new({
        x = 730,
        y = 10,
        text = "Turn 1",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    -- Create team label
    battlescape.ui.teamLabel = Widgets.Label.new({
        x = 730,
        y = 30,
        text = "Player",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    -- Create unit info panel
    battlescape.ui.unitPanel = Widgets.Panel.new({
        x = 720,
        y = 50,
        width = GUI_WIDTH,
        height = 150,
        backgroundColor = {0.15, 0.15, 0.15, 0.8},
        borderColor = {0.4, 0.4, 0.4, 1}
    })
    
    -- Unit info labels
    battlescape.ui.unitNameLabel = Widgets.Label.new({
        x = 730,
        y = 60,
        text = "No unit selected",
        font = love.graphics.getFont(),
        color = {0.7, 0.7, 0.7, 1}
    })
    
    battlescape.ui.unitHealthLabel = Widgets.Label.new({
        x = 730,
        y = 80,
        text = "",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    battlescape.ui.unitActionLabel = Widgets.Label.new({
        x = 730,
        y = 100,
        text = "",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    -- Create action buttons panel
    battlescape.ui.actionPanel = Widgets.Panel.new({
        x = 720,
        y = 480,
        width = GUI_WIDTH,
        height = 240,
        backgroundColor = {0.3, 0.3, 0.3, 1},
        borderColor = {0.5, 0.5, 0.5, 1}
    })
    
    -- Action buttons
    battlescape.ui.actionButtons = {}
    
    local buttonY = 490
    local buttonLabels = {"Move", "Attack", "End Turn", "Toggle Grid"}
    
    for i, label in ipairs(buttonLabels) do
        local button = Widgets.Button.new({
            x = 730,
            y = buttonY,
            width = 200,
            height = 25,
            text = label,
            onClick = function()
                self:handleActionButton(battlescape, i)
            end
        })
        table.insert(battlescape.ui.actionButtons, button)
        buttonY = buttonY + 30
    end
    
    -- Create debug panel (initially hidden)
    battlescape.ui.debugPanel = Widgets.Panel.new({
        x = 10,
        y = 10,
        width = 300,
        height = 100,
        backgroundColor = {0, 0, 0, 0.7},
        borderColor = {1, 1, 1, 1},
        visible = false
    })
    
    -- Debug labels
    battlescape.ui.fpsLabel = Widgets.Label.new({
        x = 20,
        y = 20,
        text = "FPS: 60",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    battlescape.ui.mouseLabel = Widgets.Label.new({
        x = 20,
        y = 40,
        text = "Mouse: 0, 0",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    battlescape.ui.cameraLabel = Widgets.Label.new({
        x = 20,
        y = 60,
        text = "Camera: 0, 0",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    battlescape.ui.unitCountLabel = Widgets.Label.new({
        x = 20,
        y = 80,
        text = "Units: 0",
        font = love.graphics.getFont(),
        color = {1, 1, 1, 1}
    })
    
    print("[BattlescapeUI] UI initialization complete")
end

function BattlescapeUI:updateUI(battlescape, dt)
    -- Update turn indicator
    if battlescape.ui.turnLabel then
        battlescape.ui.turnLabel:setText(string.format("Turn %d", battlescape.turnNumber or 1))
    end
    
    -- Update team indicator
    if battlescape.ui.teamLabel and battlescape.currentTeam then
        battlescape.ui.teamLabel:setText(battlescape.currentTeam.name)
    end
    
    -- Update unit info
    self:updateUnitInfo(battlescape)
    
    -- Update debug info if visible
    if battlescape.showDebug and battlescape.ui.debugPanel then
        battlescape.ui.debugPanel:setVisible(true)
        self:updateDebugInfo(battlescape)
    elseif battlescape.ui.debugPanel then
        battlescape.ui.debugPanel:setVisible(false)
    end
end

function BattlescapeUI:updateUnitInfo(battlescape)
    local selectedUnit = battlescape.unitSelection:getSelectedUnit()
    
    if selectedUnit then
        battlescape.ui.unitNameLabel:setText("Unit: " .. selectedUnit.type)
        battlescape.ui.unitNameLabel:setColor({1, 1, 1, 1})
        
        battlescape.ui.unitHealthLabel:setText(string.format("HP: %d/%d", 
            selectedUnit.health, selectedUnit.maxHealth))
        
        battlescape.ui.unitActionLabel:setText(string.format("AP: %d/%d", 
            selectedUnit.actionPoints, selectedUnit.maxActionPoints))
    else
        battlescape.ui.unitNameLabel:setText("No unit selected")
        battlescape.ui.unitNameLabel:setColor({0.7, 0.7, 0.7, 1})
        battlescape.ui.unitHealthLabel:setText("")
        battlescape.ui.unitActionLabel:setText("")
    end
end

function BattlescapeUI:updateDebugInfo(battlescape)
    if not battlescape.ui.fpsLabel then return end
    
    battlescape.ui.fpsLabel:setText("FPS: " .. love.timer.getFPS())
    
    local mouseX, mouseY = love.mouse.getPosition()
    battlescape.ui.mouseLabel:setText(string.format("Mouse: %d, %d", mouseX, mouseY))
    
    if battlescape.camera then
        battlescape.ui.cameraLabel:setText(string.format("Camera: %.1f, %.1f (zoom: %.2f)", 
            battlescape.camera.x, battlescape.camera.y, battlescape.camera.zoom))
    end
    
    local unitCount = battlescape:countUnits()
    battlescape.ui.unitCountLabel:setText("Units: " .. unitCount)
end

function BattlescapeUI:drawUI(battlescape)
    -- Draw all UI components
    for _, component in pairs(battlescape.ui) do
        if type(component) == "table" and component.draw then
            component:draw()
        end
    end
end

function BattlescapeUI:handleActionButton(battlescape, buttonIndex)
    if buttonIndex == 1 then
        -- Move action
        print("[UI] Move action selected")
        -- TODO: Implement move action
    elseif buttonIndex == 2 then
        -- Attack action
        print("[UI] Attack action selected")
        -- TODO: Implement attack action
    elseif buttonIndex == 3 then
        -- End turn
        if battlescape.turnManager then
            battlescape.turnManager:endTurn()
            print("[UI] Turn ended")
        end
    elseif buttonIndex == 4 then
        -- Toggle grid
        battlescape.battlefieldRenderer:toggleGrid()
        print("[UI] Grid toggled")
    end
end

return BattlescapeUI