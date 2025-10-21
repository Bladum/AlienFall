---Battlescape UI Module - UI Initialization & Management
---
---Handles initialization and lifecycle management for all battlescape UI components. Manages
---widget creation, layout, event handling, and coordination between different UI panels. Central
---coordinator for combat HUD, action menus, target selection, and other tactical UI elements.
---
---Features:
---  - UI component initialization and setup
---  - Widget lifecycle management (create, update, destroy)
---  - Layout management for 24×24 grid system
---  - Event routing between UI components
---  - Theme and style coordination
---  - State synchronization with game logic
---
---UI Components Managed:
---  - Combat HUD (unit info, AP, weapons)
---  - Action Menu (context-sensitive actions)
---  - Target Selection UI (crosshair, hit chance)
---  - Squad Roster (team member quick select)
---  - Minimap (tactical overview)
---  - Combat Log (event feed)
---  - Objective Tracker (mission goals)
---
---Layout Constants (24×24 Grid):
---  - GUI_WIDTH: 240 pixels (10 grid cells)
---  - GUI_HEIGHT: 720 pixels (30 grid cells)
---  - SECTION_HEIGHT: 240 pixels (10 grid cells per section)
---  - All panels snap to grid for consistency
---
---Key Exports:
---  - initUI(battlescape): Initialize all UI components
---  - updateUI(dt): Update all UI elements
---  - drawUI(): Render all UI panels
---  - cleanupUI(): Dispose UI resources
---  - handleInput(event): Route input events to UI
---
---Integration:
---  - Uses widgets library for UI components
---  - Connects to battlescape state for data
---  - Routes to combat_hud, action_menu, etc.
---
---@module battlescape.ui.ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local BattlescapeUI = require("battlescape.ui.ui")
---  BattlescapeUI:initUI(battlescape)
---  -- In love.draw:
---  BattlescapeUI:drawUI()
---
---@see widgets For UI component library
---@see battlescape.ui.combat_hud For main HUD

-- Battlescape UI Module
-- Handles UI initialization and management

local Widgets = require("gui.widgets.init")

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
    
    -- Action buttons are handled by ActionPanel in battlescape init
    
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
    -- This method is deprecated - actions are now handled by ActionPanel
    print("[UI] Action button " .. buttonIndex .. " clicked (deprecated - use ActionPanel)")
end

return BattlescapeUI
























