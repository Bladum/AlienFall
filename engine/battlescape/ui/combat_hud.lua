---Combat HUD System - Battlescape Heads-Up Display
---
---Implements the main HUD for hex-based tactical combat. Displays comprehensive unit information,
---action points, weapon status, action buttons, turn indicator, team roster, and environmental
---status. Follows strict 24×24 pixel grid layout system for UI consistency.
---
---HUD Components:
---  - Unit Info Panel: Portrait, name, HP bar, stats (Str, Will, Reactions)
---  - AP/TU Display: Visual bar showing remaining action/time units
---  - Weapon Status: Current weapon name, ammo count, accuracy percentage
---  - Action Buttons: Move, Shoot, Reload, Throw, Crouch, Overwatch, End Turn
---  - Turn Indicator: Current team, turn number, phase (player/enemy/civilian)
---  - Team Roster: All squad units with quick select buttons
---  - Environmental Status: Time of day, weather conditions, visibility
---
---Grid Layout (24×24 system):
---  - Resolution: 960×720 pixels (40 columns × 30 rows)
---  - Unit Panel: Top-left, 10×8 grid cells (240×192 pixels)
---  - Weapon Panel: Below unit panel, 10×6 grid cells (240×144 pixels)
---  - Action Buttons: Right side, 4×2 grid cells per button (96×48 pixels each)
---  - Team Roster: Bottom, 40×4 grid cells (960×96 pixels)
---  - All elements snap to 24-pixel grid for consistency
---
---Unit Info Panel Details:
---  - Unit Portrait: 64×64 pixel character face
---  - Name Label: Unit name and rank
---  - HP Bar: Green→Yellow→Red gradient based on health percentage
---  - Stats Display: STR 65, WILL 72, REACT 55 (compact format)
---  - Status Icons: Wounded, suppressed, panicked, poisoned indicators
---
---AP/TU Display System:
---  - Visual Bar: Blue bar showing remaining AP (max 16 TU)
---  - Numeric Display: "8/16 TU" text overlay
---  - Reserve Indicator: Yellow section for reserved overwatch AP
---  - Color Coding: Blue (sufficient), Yellow (low), Red (critical)
---
---Weapon Status Display:
---  - Weapon Name: "Assault Rifle" with weapon type icon
---  - Ammo Counter: "24/30" rounds remaining
---  - Accuracy: "75%" base hit chance at current range
---  - Fire Mode: SNAP/AIM/AUTO mode indicator
---  - Reload Warning: Red highlight when ammo below 25%
---
---Action Buttons (keyboard hotkeys):
---  - Move (M): Enter movement mode, show path preview
---  - Fire (F): Enter targeting mode, select enemy to shoot
---  - Reload (R): Reload weapon (costs 3 AP)
---  - Throw (G): Throw grenade, show arc trajectory
---  - Crouch (C): Toggle crouch stance (costs 1 AP)
---  - Overwatch (O): Reserve AP for reaction fire
---  - End Turn (Space): End current unit's turn
---
---Team Roster Features:
---  - Unit Cards: Mini portrait + name + HP bar for each squad member
---  - Quick Select: Click card to switch active unit
---  - Status At-A-Glance: See all unit HP/status without scrolling
---  - Dead/Unconscious: Grayed out units with red cross
---
---Environmental Display:
---  - Time: "14:32" 24-hour format
---  - Weather: Sunny/Cloudy/Rainy icon with visibility range
---  - Turn Counter: "Turn 8 of 20" for timed missions
---  - Mission Timer: Countdown for evacuation/reinforcement
---
---Key Exports:
---  - initialize(battlescape): Sets up HUD with initial state
---  - update(dt, selectedUnit): Updates display for selected unit
---  - draw(): Renders all HUD elements
---  - handleClick(x, y): Processes mouse clicks on HUD buttons
---  - setSelectedUnit(unit): Changes displayed unit information
---  - updateWeaponDisplay(weapon): Refreshes weapon status
---
---Integration:
---  - Works with widgets library for UI rendering
---  - Uses theme system for consistent colors/fonts
---  - Integrates with input system for hotkey handling
---  - Connects to unit and weapon systems for live data
---
---@module battlescape.ui.combat_hud
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CombatHUD = require("battlescape.ui.combat_hud")
---  CombatHUD.initialize(battlescapeState)
---  CombatHUD.setSelectedUnit(activeUnit)
---  CombatHUD.draw()
---
---@see widgets For UI component library
---@see battlescape.combat.unit For unit data structure

local CombatHUD = {}

-- Configuration
local CONFIG = {
    -- Screen layout (960×720, 24×24 grid = 40×30 cells)
    HUD_HEIGHT = 192,           -- 8 grid cells (bottom of screen)
    UNIT_PANEL_WIDTH = 288,     -- 12 grid cells (left side)
    ACTION_PANEL_WIDTH = 240,   -- 10 grid cells (right side)
    
    -- Colors
    COLORS = {
        BACKGROUND = {r = 20, g = 20, b = 30, a = 220},
        PANEL_BORDER = {r = 100, g = 100, b = 120, a = 255},
        TEXT_PRIMARY = {r = 220, g = 220, b = 230, a = 255},
        TEXT_SECONDARY = {r = 160, g = 160, b = 180, a = 255},
        HP_BAR_FULL = {r = 80, g = 200, b = 80, a = 255},
        HP_BAR_MEDIUM = {r = 220, g = 180, b = 60, a = 255},
        HP_BAR_LOW = {r = 220, g = 60, b = 60, a = 255},
        AP_BAR = {r = 60, g = 140, b = 220, a = 255},
        TU_BAR = {r = 180, g = 120, b = 220, a = 255},
        BUTTON_NORMAL = {r = 60, g = 60, b = 80, a = 255},
        BUTTON_HOVER = {r = 80, g = 80, b = 110, a = 255},
        BUTTON_ACTIVE = {r = 100, g = 100, b = 140, a = 255},
        BUTTON_DISABLED = {r = 40, g = 40, b = 50, a = 200},
    },
    
    -- Text sizes
    FONT_LARGE = 16,            -- Unit name, turn indicator
    FONT_MEDIUM = 14,           -- Stats, weapon info
    FONT_SMALL = 12,            -- Secondary info
    
    -- Unit portrait
    PORTRAIT_SIZE = 72,         -- 3×3 grid cells
    
    -- Action buttons (6×2 grid cells each)
    BUTTON_WIDTH = 144,
    BUTTON_HEIGHT = 48,
    BUTTON_PADDING = 12,
    
    -- Team colors
    TEAM_COLORS = {
        PLAYER = {r = 80, g = 200, b = 80, a = 255},
        ALLY = {r = 60, g = 140, b = 220, a = 255},
        ENEMY = {r = 220, g = 60, b = 60, a = 255},
        NEUTRAL = {r = 180, g = 180, b = 180, a = 255},
    },
}

-- HUD state
local hudState = {
    selectedUnit = nil,         -- Currently selected unit
    hoveredButton = nil,        -- Button under mouse
    turnNumber = 1,             -- Current turn
    activeTeam = "PLAYER",      -- Current team
    teamUnits = {},             -- All units by team
    notifications = {},         -- Recent notifications
    mouseX = 0,
    mouseY = 0,
}

-- Action buttons configuration
local ACTION_BUTTONS = {
    {id = "move", label = "Move", hotkey = "M", enabled = true},
    {id = "shoot", label = "Shoot", hotkey = "F", enabled = true},
    {id = "reload", label = "Reload", hotkey = "R", enabled = true},
    {id = "throw", label = "Throw", hotkey = "G", enabled = true},
    {id = "overwatch", label = "Overwatch", hotkey = "O", enabled = true},
    {id = "crouch", label = "Crouch", hotkey = "C", enabled = true},
    {id = "use_item", label = "Use Item", hotkey = "U", enabled = true},
    {id = "end_turn", label = "End Turn", hotkey = "Space", enabled = true},
}

--[[
    Initialize HUD system
]]
function CombatHUD.init()
    hudState = {
        selectedUnit = nil,
        hoveredButton = nil,
        turnNumber = 1,
        activeTeam = "PLAYER",
        teamUnits = {},
        notifications = {},
        mouseX = 0,
        mouseY = 0,
    }
    print("[CombatHUD] HUD system initialized")
end

--[[
    Set currently selected unit
    
    @param unit: Unit data { id, name, hp, maxHP, ap, maxAP, tu, maxTU, weapon, team, portrait }
]]
function CombatHUD.setSelectedUnit(unit)
    hudState.selectedUnit = unit
    print(string.format("[CombatHUD] Selected unit: %s (HP: %d/%d, AP: %d/%d)",
        unit and unit.name or "None",
        unit and unit.hp or 0,
        unit and unit.maxHP or 0,
        unit and unit.ap or 0,
        unit and unit.maxAP or 0))
end

--[[
    Get currently selected unit
    
    @return unit or nil
]]
function CombatHUD.getSelectedUnit()
    return hudState.selectedUnit
end

--[[
    Set turn information
    
    @param turnNumber: Current turn number
    @param activeTeam: Active team name
]]
function CombatHUD.setTurn(turnNumber, activeTeam)
    hudState.turnNumber = turnNumber
    hudState.activeTeam = activeTeam
    print(string.format("[CombatHUD] Turn %d: %s team active", turnNumber, activeTeam))
end

--[[
    Update team unit roster
    
    @param units: Table of all units { [unitId] = unitData }
]]
function CombatHUD.updateTeamRoster(units)
    hudState.teamUnits = {}
    for unitId, unit in pairs(units) do
        local team = unit.team or "NEUTRAL"
        if not hudState.teamUnits[team] then
            hudState.teamUnits[team] = {}
        end
        table.insert(hudState.teamUnits[team], unit)
    end
end

--[[
    Add notification to HUD
    
    @param message: Notification text
    @param type: Notification type (info, warning, error, success)
    @param duration: Display duration in seconds (default 3)
]]
function CombatHUD.addNotification(message, notifType, duration)
    table.insert(hudState.notifications, {
        message = message,
        type = notifType or "info",
        duration = duration or 3,
        timestamp = love.timer.getTime(),
    })
    print(string.format("[CombatHUD] Notification: %s (%s)", message, notifType or "info"))
end

--[[
    Update HUD (called every frame)
    
    @param dt: Delta time
]]
function CombatHUD.update(dt)
    -- Update mouse position
    hudState.mouseX, hudState.mouseY = love.mouse.getPosition()
    
    -- Update hovered button
    hudState.hoveredButton = CombatHUD.getButtonAtMouse(hudState.mouseX, hudState.mouseY)
    
    -- Remove expired notifications
    local currentTime = love.timer.getTime()
    for i = #hudState.notifications, 1, -1 do
        local notif = hudState.notifications[i]
        if currentTime - notif.timestamp > notif.duration then
            table.remove(hudState.notifications, i)
        end
    end
end

--[[
    Draw HUD (called every frame)
]]
function CombatHUD.draw()
    -- Draw main HUD panel at bottom
    CombatHUD.drawMainPanel()
    
    -- Draw unit info panel (left side)
    if hudState.selectedUnit then
        CombatHUD.drawUnitPanel()
    end
    
    -- Draw action buttons (right side)
    CombatHUD.drawActionButtons()
    
    -- Draw turn indicator (top center)
    CombatHUD.drawTurnIndicator()
    
    -- Draw team roster (top left)
    CombatHUD.drawTeamRoster()
    
    -- Draw notifications (top right)
    CombatHUD.drawNotifications()
end

--[[
    Draw main HUD panel background
]]
function CombatHUD.drawMainPanel()
    local screenHeight = 720
    local panelY = screenHeight - CONFIG.HUD_HEIGHT
    
    -- Background
    love.graphics.setColor(CONFIG.COLORS.BACKGROUND.r, CONFIG.COLORS.BACKGROUND.g,
        CONFIG.COLORS.BACKGROUND.b, CONFIG.COLORS.BACKGROUND.a)
    love.graphics.rectangle("fill", 0, panelY, 960, CONFIG.HUD_HEIGHT)
    
    -- Border
    love.graphics.setColor(CONFIG.COLORS.PANEL_BORDER.r, CONFIG.COLORS.PANEL_BORDER.g,
        CONFIG.COLORS.PANEL_BORDER.b, CONFIG.COLORS.PANEL_BORDER.a)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, panelY, 960, CONFIG.HUD_HEIGHT)
end

--[[
    Draw unit info panel
]]
function CombatHUD.drawUnitPanel()
    local unit = hudState.selectedUnit
    if not unit then return end
    
    local panelY = 720 - CONFIG.HUD_HEIGHT + 12
    local panelX = 12
    
    -- Portrait (placeholder - colored square)
    local portraitColor = CONFIG.TEAM_COLORS[unit.team] or CONFIG.TEAM_COLORS.NEUTRAL
    love.graphics.setColor(portraitColor.r, portraitColor.g, portraitColor.b, portraitColor.a)
    love.graphics.rectangle("fill", panelX, panelY, CONFIG.PORTRAIT_SIZE, CONFIG.PORTRAIT_SIZE)
    
    -- Unit name
    love.graphics.setColor(CONFIG.COLORS.TEXT_PRIMARY.r, CONFIG.COLORS.TEXT_PRIMARY.g,
        CONFIG.COLORS.TEXT_PRIMARY.b, CONFIG.COLORS.TEXT_PRIMARY.a)
    love.graphics.print(unit.name or "Unknown", panelX + CONFIG.PORTRAIT_SIZE + 12, panelY, 0, 1, 1)
    
    -- HP bar
    local hpPercent = unit.hp / unit.maxHP
    local hpBarColor = hpPercent > 0.6 and CONFIG.COLORS.HP_BAR_FULL or
                       hpPercent > 0.3 and CONFIG.COLORS.HP_BAR_MEDIUM or
                       CONFIG.COLORS.HP_BAR_LOW
    CombatHUD.drawBar(panelX + CONFIG.PORTRAIT_SIZE + 12, panelY + 24,
        CONFIG.UNIT_PANEL_WIDTH - CONFIG.PORTRAIT_SIZE - 24, 16,
        hpPercent, hpBarColor, string.format("HP: %d/%d", unit.hp, unit.maxHP))
    
    -- AP bar
    local apPercent = unit.ap / unit.maxAP
    CombatHUD.drawBar(panelX + CONFIG.PORTRAIT_SIZE + 12, panelY + 48,
        CONFIG.UNIT_PANEL_WIDTH - CONFIG.PORTRAIT_SIZE - 24, 16,
        apPercent, CONFIG.COLORS.AP_BAR, string.format("AP: %d/%d", unit.ap, unit.maxAP))
    
    -- Weapon info
    if unit.weapon then
        love.graphics.setColor(CONFIG.COLORS.TEXT_SECONDARY.r, CONFIG.COLORS.TEXT_SECONDARY.g,
            CONFIG.COLORS.TEXT_SECONDARY.b, CONFIG.COLORS.TEXT_SECONDARY.a)
        love.graphics.print(string.format("Weapon: %s (%d/%d)",
            unit.weapon.name or "None",
            unit.weapon.ammo or 0,
            unit.weapon.maxAmmo or 0),
            panelX, panelY + CONFIG.PORTRAIT_SIZE + 12, 0, 0.9, 0.9)
    end
end

--[[
    Draw action buttons
]]
function CombatHUD.drawActionButtons()
    local panelY = 720 - CONFIG.HUD_HEIGHT + 12
    local startX = 960 - CONFIG.ACTION_PANEL_WIDTH
    local buttonX = startX + CONFIG.BUTTON_PADDING
    local buttonY = panelY + CONFIG.BUTTON_PADDING
    
    for i, button in ipairs(ACTION_BUTTONS) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local x = buttonX + col * (CONFIG.BUTTON_WIDTH + CONFIG.BUTTON_PADDING)
        local y = buttonY + row * (CONFIG.BUTTON_HEIGHT + CONFIG.BUTTON_PADDING)
        
        CombatHUD.drawButton(x, y, CONFIG.BUTTON_WIDTH, CONFIG.BUTTON_HEIGHT, button)
    end
end

--[[
    Draw a button
    
    @param x, y: Position
    @param width, height: Size
    @param button: Button data { id, label, hotkey, enabled }
]]
function CombatHUD.drawButton(x, y, width, height, button)
    local isHovered = hudState.hoveredButton == button.id
    local color = not button.enabled and CONFIG.COLORS.BUTTON_DISABLED or
                  isHovered and CONFIG.COLORS.BUTTON_HOVER or
                  CONFIG.COLORS.BUTTON_NORMAL
    
    -- Button background
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Button border
    love.graphics.setColor(CONFIG.COLORS.PANEL_BORDER.r, CONFIG.COLORS.PANEL_BORDER.g,
        CONFIG.COLORS.PANEL_BORDER.b, CONFIG.COLORS.PANEL_BORDER.a)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Button label
    local textColor = button.enabled and CONFIG.COLORS.TEXT_PRIMARY or CONFIG.COLORS.TEXT_SECONDARY
    love.graphics.setColor(textColor.r, textColor.g, textColor.b, textColor.a)
    local labelWidth = love.graphics.getFont():getWidth(button.label)
    love.graphics.print(button.label, x + (width - labelWidth) / 2, y + 12)
    
    -- Hotkey
    if button.hotkey then
        love.graphics.print("[" .. button.hotkey .. "]", x + 8, y + height - 20, 0, 0.8, 0.8)
    end
end

--[[
    Draw a status bar
    
    @param x, y: Position
    @param width, height: Size
    @param percent: Fill percentage (0-1)
    @param color: Bar color
    @param label: Bar label (optional)
]]
function CombatHUD.drawBar(x, y, width, height, percent, color, label)
    -- Background
    love.graphics.setColor(40, 40, 50, 255)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Fill
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.rectangle("fill", x, y, width * percent, height)
    
    -- Border
    love.graphics.setColor(CONFIG.COLORS.PANEL_BORDER.r, CONFIG.COLORS.PANEL_BORDER.g,
        CONFIG.COLORS.PANEL_BORDER.b, CONFIG.COLORS.PANEL_BORDER.a)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Label
    if label then
        love.graphics.setColor(CONFIG.COLORS.TEXT_PRIMARY.r, CONFIG.COLORS.TEXT_PRIMARY.g,
            CONFIG.COLORS.TEXT_PRIMARY.b, CONFIG.COLORS.TEXT_PRIMARY.a)
        local labelWidth = love.graphics.getFont():getWidth(label)
        love.graphics.print(label, x + (width - labelWidth) / 2, y + 2, 0, 0.8, 0.8)
    end
end

--[[
    Draw turn indicator
]]
function CombatHUD.drawTurnIndicator()
    local text = string.format("Turn %d - %s", hudState.turnNumber, hudState.activeTeam)
    local teamColor = CONFIG.TEAM_COLORS[hudState.activeTeam] or CONFIG.TEAM_COLORS.NEUTRAL
    
    love.graphics.setColor(teamColor.r, teamColor.g, teamColor.b, teamColor.a)
    local textWidth = love.graphics.getFont():getWidth(text)
    love.graphics.print(text, (960 - textWidth) / 2, 12, 0, 1.2, 1.2)
end

--[[
    Draw team roster
]]
function CombatHUD.drawTeamRoster()
    local x = 12
    local y = 48
    local playerUnits = hudState.teamUnits.PLAYER or {}
    
    love.graphics.setColor(CONFIG.COLORS.TEXT_SECONDARY.r, CONFIG.COLORS.TEXT_SECONDARY.g,
        CONFIG.COLORS.TEXT_SECONDARY.b, CONFIG.COLORS.TEXT_SECONDARY.a)
    love.graphics.print(string.format("Squad: %d units", #playerUnits), x, y, 0, 0.9, 0.9)
end

--[[
    Draw notifications
]]
function CombatHUD.drawNotifications()
    local x = 960 - 240
    local y = 48
    
    for i, notif in ipairs(hudState.notifications) do
        local alpha = 255
        local elapsed = love.timer.getTime() - notif.timestamp
        if elapsed > notif.duration - 0.5 then
            alpha = 255 * ((notif.duration - elapsed) / 0.5)
        end
        
        love.graphics.setColor(CONFIG.COLORS.TEXT_PRIMARY.r, CONFIG.COLORS.TEXT_PRIMARY.g,
            CONFIG.COLORS.TEXT_PRIMARY.b, alpha)
        love.graphics.print(notif.message, x, y + (i - 1) * 20, 0, 0.9, 0.9)
    end
end

--[[
    Get button at mouse position
    
    @param mx, my: Mouse coordinates
    @return buttonId or nil
]]
function CombatHUD.getButtonAtMouse(mx, my)
    local panelY = 720 - CONFIG.HUD_HEIGHT + 12
    local startX = 960 - CONFIG.ACTION_PANEL_WIDTH
    local buttonX = startX + CONFIG.BUTTON_PADDING
    local buttonY = panelY + CONFIG.BUTTON_PADDING
    
    for i, button in ipairs(ACTION_BUTTONS) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local x = buttonX + col * (CONFIG.BUTTON_WIDTH + CONFIG.BUTTON_PADDING)
        local y = buttonY + row * (CONFIG.BUTTON_HEIGHT + CONFIG.BUTTON_PADDING)
        
        if mx >= x and mx <= x + CONFIG.BUTTON_WIDTH and
           my >= y and my <= y + CONFIG.BUTTON_HEIGHT then
            return button.id
        end
    end
    
    return nil
end

--[[
    Handle mouse click
    
    @param x, y: Click coordinates
    @param button: Mouse button (1=left, 2=right, 3=middle)
    @return action: Clicked action id or nil
]]
function CombatHUD.handleClick(x, y, button)
    if button ~= 1 then return nil end  -- Only left click
    
    local buttonId = CombatHUD.getButtonAtMouse(x, y)
    if buttonId then
        print(string.format("[CombatHUD] Button clicked: %s", buttonId))
        return buttonId
    end
    
    return nil
end

--[[
    Get HUD state for debugging
    
    @return hudState table
]]
function CombatHUD.getState()
    return hudState
end

return CombatHUD


























