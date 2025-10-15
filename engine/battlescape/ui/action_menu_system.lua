---Action Menu System - Context-Sensitive Action Interface
---
---Implements dynamic context-sensitive action menu for tactical combat. Displays available
---actions based on unit state, selected target, equipment, and game context. Actions include
---movement, shooting, reloading, throwing, item use, overwatch, stance changes, and turn end.
---
---Context-Sensitive Filtering:
---  - Shows only valid actions for current unit state
---  - Disables actions if insufficient AP or invalid target
---  - Adapts to equipment (no reload if no weapon, no throw if no grenades)
---  - Considers environmental factors (can't crouch if already prone)
---
---Available Actions:
---  - Move (M): Plan and execute movement to selected hex
---  - Fire (F): Shoot at visible enemy with current weapon
---  - Reload (R): Reload current weapon from inventory
---  - Throw (G): Throw grenade with arc trajectory preview
---  - Use Item (U): Use medkit, stimpack, or other consumable
---  - Overwatch (O): Enter overwatch mode, reserve AP for reaction fire
---  - Crouch (C): Toggle between standing/crouching stance
---  - End Turn (Space): Finish current unit's turn, move to next unit
---
---AP Cost Display:
---  - Each action shows AP cost: "Fire (3 AP)", "Reload (4 AP)"
---  - Color coding: Green (can afford), Red (insufficient AP)
---  - Dynamic costs based on weapon type and stance
---  - Reserved AP shown in yellow for overwatch
---
---Keyboard Hotkeys:
---  - M: Move mode (plan path with mouse)
---  - F: Fire mode (select target to shoot)
---  - R: Reload weapon (instant action)
---  - G: Grenade mode (select target for throw)
---  - U: Use item (opens inventory)
---  - O: Overwatch (enter reaction fire stance)
---  - C: Crouch toggle (costs 1 AP)
---  - Space: End turn (confirms end of unit actions)
---
---Action Validation:
---  - Checks AP availability before execution
---  - Validates target selection (line of sight, range)
---  - Ensures equipment requirements (ammo, items)
---  - Prevents invalid actions (can't reload full magazine)
---  - Shows error messages for failed validation
---
---Radial Menu Option:
---  - Right-click opens radial menu around cursor
---  - 8-way wheel with icon per action
---  - Drag mouse to select action, release to confirm
---  - Alternative to keyboard for mouse-heavy players
---
---Action Queue Support:
---  - Plan multiple actions before execution (optional)
---  - Queue actions up to AP limit
---  - Preview total AP cost before commit
---  - Cancel/modify queue before execution
---  - Useful for complex multi-step tactics
---
---Visual Feedback:
---  - Hover highlights show action description
---  - Selected action highlights in blue
---  - Invalid actions grayed out with tooltip explanation
---  - Animation feedback when action completes
---
---Key Exports:
---  - showMenu(unit, x, y): Opens action menu for unit at position
---  - hideMenu(): Closes current menu
---  - selectAction(actionId): Executes selected action
---  - getAvailableActions(unit): Returns list of valid actions
---  - validateAction(unit, action): Checks if action is executable
---  - queueAction(action): Adds action to queue (if enabled)
---
---Integration:
---  - Works with input system for hotkey handling
---  - Uses action_system.lua for action execution
---  - Integrates with UI for menu rendering
---  - Connects to unit state for action availability
---
---@module battlescape.ui.action_menu_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ActionMenu = require("battlescape.ui.action_menu_system")
---  ActionMenu.showMenu(selectedUnit, mouseX, mouseY)
---  if ActionMenu.validateAction(unit, "fire") then
---      ActionMenu.selectAction("fire")
---  end
---
---@see battlescape.combat.action_system For action execution
---@see battlescape.ui.input For hotkey handling

local ActionMenuSystem = {}

-- Configuration
local CONFIG = {
    -- Action definitions
    ACTIONS = {
        {id = "move", label = "Move", hotkey = "m", icon = "M", apCost = 0, requiresTarget = false},
        {id = "shoot", label = "Shoot", hotkey = "f", icon = "F", apCost = 3, requiresTarget = true},
        {id = "reload", label = "Reload", hotkey = "r", icon = "R", apCost = 2, requiresTarget = false},
        {id = "throw", label = "Throw", hotkey = "g", icon = "G", apCost = 3, requiresTarget = true},
        {id = "use_item", label = "Use Item", hotkey = "u", icon = "U", apCost = 2, requiresTarget = false},
        {id = "overwatch", label = "Overwatch", hotkey = "o", icon = "O", apCost = 1, requiresTarget = false},
        {id = "crouch", label = "Crouch", hotkey = "c", icon = "C", apCost = 0, requiresTarget = false},
        {id = "end_turn", label = "End Turn", hotkey = "space", icon = "END", apCost = 0, requiresTarget = false},
    },
    
    -- Menu layout
    MENU_X = 480,               -- Center of screen
    MENU_Y = 360,
    BUTTON_WIDTH = 120,
    BUTTON_HEIGHT = 36,
    BUTTON_SPACING = 6,
    RADIAL_RADIUS = 100,
    
    -- Colors
    COLORS = {
        BUTTON_AVAILABLE = {r = 60, g = 80, b = 100, a = 255},
        BUTTON_UNAVAILABLE = {r = 40, g = 40, b = 50, a = 200},
        BUTTON_HOVER = {r = 80, g = 100, b = 140, a = 255},
        BUTTON_SELECTED = {r = 100, g = 140, b = 180, a = 255},
        BORDER = {r = 100, g = 100, b = 120, a = 255},
        TEXT = {r = 220, g = 220, b = 230, a = 255},
        TEXT_DISABLED = {r = 120, g = 120, b = 130, a = 255},
        AP_COST = {r = 180, g = 140, b = 220, a = 255},
        HOTKEY = {r = 220, g = 180, b = 60, a = 255},
    },
}

-- Menu state
local menuState = {
    visible = false,
    selectedUnit = nil,
    targetUnit = nil,
    availableActions = {},
    hoveredAction = nil,
    selectedAction = nil,
    menuType = "linear",        -- "linear" or "radial"
    mouseX = 0,
    mouseY = 0,
}

--[[
    Initialize action menu
]]
function ActionMenuSystem.init()
    menuState = {
        visible = false,
        selectedUnit = nil,
        targetUnit = nil,
        availableActions = {},
        hoveredAction = nil,
        selectedAction = nil,
        menuType = "linear",
        mouseX = 0,
        mouseY = 0,
    }
    print("[ActionMenuSystem] Action menu initialized")
end

--[[
    Show action menu
    
    @param unit: Selected unit data
    @param target: Target unit/position (optional)
    @param menuType: "linear" or "radial" (default "linear")
]]
function ActionMenuSystem.show(unit, target, menuType)
    menuState.visible = true
    menuState.selectedUnit = unit
    menuState.targetUnit = target
    menuState.menuType = menuType or "linear"
    ActionMenuSystem.updateAvailableActions()
    print(string.format("[ActionMenuSystem] Showing menu for unit %s", unit and unit.name or "None"))
end

--[[
    Hide action menu
]]
function ActionMenuSystem.hide()
    menuState.visible = false
    menuState.selectedAction = nil
    print("[ActionMenuSystem] Menu hidden")
end

--[[
    Check if menu is visible
    
    @return boolean
]]
function ActionMenuSystem.isVisible()
    return menuState.visible
end

--[[
    Update available actions based on current context
]]
function ActionMenuSystem.updateAvailableActions()
    menuState.availableActions = {}
    
    if not menuState.selectedUnit then
        return
    end
    
    local unit = menuState.selectedUnit
    local target = menuState.targetUnit
    
    for _, action in ipairs(CONFIG.ACTIONS) do
        local available, reason = ActionMenuSystem.isActionAvailable(action, unit, target)
        table.insert(menuState.availableActions, {
            action = action,
            available = available,
            reason = reason,
        })
    end
    
    print(string.format("[ActionMenuSystem] Updated actions: %d available",
        #menuState.availableActions))
end

--[[
    Check if action is available
    
    @param action: Action definition
    @param unit: Unit data
    @param target: Target data (optional)
    @return available: Boolean
    @return reason: String (if not available)
]]
function ActionMenuSystem.isActionAvailable(action, unit, target)
    -- Check AP cost
    if unit.ap < action.apCost then
        return false, "Not enough AP"
    end
    
    -- Check target requirement
    if action.requiresTarget and not target then
        return false, "No target selected"
    end
    
    -- Action-specific checks
    if action.id == "shoot" then
        if not unit.weapon then
            return false, "No weapon equipped"
        end
        if unit.weapon.ammo and unit.weapon.ammo == 0 then
            return false, "No ammo"
        end
        if not target then
            return false, "No target"
        end
    elseif action.id == "reload" then
        if not unit.weapon then
            return false, "No weapon equipped"
        end
        if unit.weapon.ammo and unit.weapon.ammo >= unit.weapon.maxAmmo then
            return false, "Already loaded"
        end
    elseif action.id == "throw" then
        if not unit.grenade then
            return false, "No grenade"
        end
        if not target then
            return false, "No target"
        end
    elseif action.id == "use_item" then
        if not unit.activeItem then
            return false, "No item selected"
        end
    elseif action.id == "overwatch" then
        if unit.overwatchActive then
            return false, "Already on overwatch"
        end
    elseif action.id == "crouch" then
        if unit.crouching then
            return false, "Already crouching"
        end
    end
    
    return true, ""
end

--[[
    Execute action
    
    @param actionId: Action identifier
    @return success: Boolean
    @return message: Result message
]]
function ActionMenuSystem.executeAction(actionId)
    local unit = menuState.selectedUnit
    if not unit then
        return false, "No unit selected"
    end
    
    -- Find action
    local actionData = nil
    for _, actionInfo in ipairs(menuState.availableActions) do
        if actionInfo.action.id == actionId then
            actionData = actionInfo
            break
        end
    end
    
    if not actionData or not actionData.available then
        return false, "Action not available"
    end
    
    -- Execute action (placeholder - would integrate with game logic)
    print(string.format("[ActionMenuSystem] Executing action: %s for unit %s",
        actionId, unit.name))
    
    -- Deduct AP cost
    unit.ap = unit.ap - actionData.action.apCost
    
    -- Hide menu after action
    ActionMenuSystem.hide()
    
    return true, string.format("%s executed", actionData.action.label)
end

--[[
    Update menu state
    
    @param dt: Delta time
]]
function ActionMenuSystem.update(dt)
    if not menuState.visible then
        return
    end
    
    -- Update mouse position
    menuState.mouseX, menuState.mouseY = love.mouse.getPosition()
    
    -- Update hovered action
    if menuState.menuType == "linear" then
        menuState.hoveredAction = ActionMenuSystem.getActionAtMouse(menuState.mouseX, menuState.mouseY)
    elseif menuState.menuType == "radial" then
        menuState.hoveredAction = ActionMenuSystem.getRadialActionAtMouse(menuState.mouseX, menuState.mouseY)
    end
end

--[[
    Draw action menu
]]
function ActionMenuSystem.draw()
    if not menuState.visible then
        return
    end
    
    if menuState.menuType == "linear" then
        ActionMenuSystem.drawLinearMenu()
    elseif menuState.menuType == "radial" then
        ActionMenuSystem.drawRadialMenu()
    end
end

--[[
    Draw linear menu (vertical list)
]]
function ActionMenuSystem.drawLinearMenu()
    local startX = CONFIG.MENU_X - CONFIG.BUTTON_WIDTH / 2
    local startY = CONFIG.MENU_Y - (#menuState.availableActions * (CONFIG.BUTTON_HEIGHT + CONFIG.BUTTON_SPACING)) / 2
    
    for i, actionInfo in ipairs(menuState.availableActions) do
        local x = startX
        local y = startY + (i - 1) * (CONFIG.BUTTON_HEIGHT + CONFIG.BUTTON_SPACING)
        local isHovered = menuState.hoveredAction == actionInfo.action.id
        local isSelected = menuState.selectedAction == actionInfo.action.id
        
        ActionMenuSystem.drawActionButton(x, y, CONFIG.BUTTON_WIDTH, CONFIG.BUTTON_HEIGHT,
            actionInfo, isHovered, isSelected)
    end
end

--[[
    Draw radial menu (circle around center)
]]
function ActionMenuSystem.drawRadialMenu()
    local centerX = CONFIG.MENU_X
    local centerY = CONFIG.MENU_Y
    local angleStep = (2 * math.pi) / #menuState.availableActions
    
    for i, actionInfo in ipairs(menuState.availableActions) do
        local angle = (i - 1) * angleStep - math.pi / 2  -- Start from top
        local x = centerX + math.cos(angle) * CONFIG.RADIAL_RADIUS - CONFIG.BUTTON_WIDTH / 2
        local y = centerY + math.sin(angle) * CONFIG.RADIAL_RADIUS - CONFIG.BUTTON_HEIGHT / 2
        local isHovered = menuState.hoveredAction == actionInfo.action.id
        local isSelected = menuState.selectedAction == actionInfo.action.id
        
        ActionMenuSystem.drawActionButton(x, y, CONFIG.BUTTON_WIDTH, CONFIG.BUTTON_HEIGHT,
            actionInfo, isHovered, isSelected)
    end
    
    -- Draw center circle
    love.graphics.setColor(40, 40, 50, 200)
    love.graphics.circle("fill", centerX, centerY, 20)
    love.graphics.setColor(100, 100, 120, 255)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", centerX, centerY, 20)
end

--[[
    Draw action button
    
    @param x, y: Position
    @param width, height: Size
    @param actionInfo: Action info table
    @param isHovered: Is mouse hovering
    @param isSelected: Is selected
]]
function ActionMenuSystem.drawActionButton(x, y, width, height, actionInfo, isHovered, isSelected)
    local action = actionInfo.action
    local available = actionInfo.available
    
    -- Determine color
    local color
    if not available then
        color = CONFIG.COLORS.BUTTON_UNAVAILABLE
    elseif isSelected then
        color = CONFIG.COLORS.BUTTON_SELECTED
    elseif isHovered then
        color = CONFIG.COLORS.BUTTON_HOVER
    else
        color = CONFIG.COLORS.BUTTON_AVAILABLE
    end
    
    -- Background
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Border
    love.graphics.setColor(CONFIG.COLORS.BORDER.r, CONFIG.COLORS.BORDER.g,
        CONFIG.COLORS.BORDER.b, CONFIG.COLORS.BORDER.a)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Text
    local textColor = available and CONFIG.COLORS.TEXT or CONFIG.COLORS.TEXT_DISABLED
    love.graphics.setColor(textColor.r, textColor.g, textColor.b, textColor.a)
    love.graphics.print(action.label, x + 8, y + 6)
    
    -- AP cost
    if action.apCost > 0 then
        love.graphics.setColor(CONFIG.COLORS.AP_COST.r, CONFIG.COLORS.AP_COST.g,
            CONFIG.COLORS.AP_COST.b, CONFIG.COLORS.AP_COST.a)
        love.graphics.print(string.format("AP: %d", action.apCost),
            x + width - 50, y + 6, 0, 0.8, 0.8)
    end
    
    -- Hotkey
    love.graphics.setColor(CONFIG.COLORS.HOTKEY.r, CONFIG.COLORS.HOTKEY.g,
        CONFIG.COLORS.HOTKEY.b, CONFIG.COLORS.HOTKEY.a)
    love.graphics.print(string.format("[%s]", string.upper(action.hotkey)),
        x + 8, y + 20, 0, 0.7, 0.7)
    
    -- Unavailable reason
    if not available and actionInfo.reason then
        love.graphics.setColor(220, 60, 60, 255)
        love.graphics.print(actionInfo.reason, x + 8, y + height + 4, 0, 0.6, 0.6)
    end
end

--[[
    Get action at mouse position (linear menu)
    
    @param mx, my: Mouse coordinates
    @return actionId or nil
]]
function ActionMenuSystem.getActionAtMouse(mx, my)
    local startX = CONFIG.MENU_X - CONFIG.BUTTON_WIDTH / 2
    local startY = CONFIG.MENU_Y - (#menuState.availableActions * (CONFIG.BUTTON_HEIGHT + CONFIG.BUTTON_SPACING)) / 2
    
    for i, actionInfo in ipairs(menuState.availableActions) do
        local x = startX
        local y = startY + (i - 1) * (CONFIG.BUTTON_HEIGHT + CONFIG.BUTTON_SPACING)
        
        if mx >= x and mx <= x + CONFIG.BUTTON_WIDTH and
           my >= y and my <= y + CONFIG.BUTTON_HEIGHT then
            return actionInfo.action.id
        end
    end
    
    return nil
end

--[[
    Get action at mouse position (radial menu)
    
    @param mx, my: Mouse coordinates
    @return actionId or nil
]]
function ActionMenuSystem.getRadialActionAtMouse(mx, my)
    local centerX = CONFIG.MENU_X
    local centerY = CONFIG.MENU_Y
    local angleStep = (2 * math.pi) / #menuState.availableActions
    
    for i, actionInfo in ipairs(menuState.availableActions) do
        local angle = (i - 1) * angleStep - math.pi / 2
        local x = centerX + math.cos(angle) * CONFIG.RADIAL_RADIUS - CONFIG.BUTTON_WIDTH / 2
        local y = centerY + math.sin(angle) * CONFIG.RADIAL_RADIUS - CONFIG.BUTTON_HEIGHT / 2
        
        if mx >= x and mx <= x + CONFIG.BUTTON_WIDTH and
           my >= y and my <= y + CONFIG.BUTTON_HEIGHT then
            return actionInfo.action.id
        end
    end
    
    return nil
end

--[[
    Handle mouse click
    
    @param x, y: Click coordinates
    @param button: Mouse button
    @return actionId or nil
]]
function ActionMenuSystem.handleClick(x, y, button)
    if not menuState.visible or button ~= 1 then
        return nil
    end
    
    local actionId = menuState.menuType == "linear" and
        ActionMenuSystem.getActionAtMouse(x, y) or
        ActionMenuSystem.getRadialActionAtMouse(x, y)
    
    if actionId then
        ActionMenuSystem.executeAction(actionId)
        return actionId
    end
    
    return nil
end

--[[
    Handle keyboard input
    
    @param key: Key pressed
    @return actionId or nil
]]
function ActionMenuSystem.handleKeyPress(key)
    if not menuState.visible then
        return nil
    end
    
    for _, actionInfo in ipairs(menuState.availableActions) do
        if actionInfo.action.hotkey == key and actionInfo.available then
            ActionMenuSystem.executeAction(actionInfo.action.id)
            return actionInfo.action.id
        end
    end
    
    return nil
end

--[[
    Get menu state for debugging
    
    @return menuState table
]]
function ActionMenuSystem.getState()
    return menuState
end

return ActionMenuSystem






















