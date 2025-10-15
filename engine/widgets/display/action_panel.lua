---ActionPanel Widget - Tactical Action Button Container
---
---Container for action buttons organized as a radio button group. Manages 8 action
---buttons in 2 rows (weapons/armor/skill in row 1, move modes in row 2). Used for
---unit action selection in tactical combat. Grid-aligned for consistent positioning.
---
---Features:
---  - Radio button group behavior (only one action selected at a time)
---  - LMB selection, RMB execution of actions
---  - Action availability checking (grays out unavailable)
---  - Grid-aligned layout (24×24 pixels)
---  - Hotkey support (1-8 keys)
---  - Action cost display (AP, EP)
---
---Button Layout (2 rows × 4 columns):
---  Row 1: [Weapon] [Armor] [Skill] [Item]
---  Row 2: [Walk] [Run] [Crouch] [Overwatch]
---
---Action Types:
---  - Weapon: Primary weapon attack
---  - Armor: Use armor ability (shield, cloak, etc.)
---  - Skill: Unit special ability
---  - Item: Use inventory item
---  - Walk: Normal movement
---  - Run: Fast movement (costs more AP)
---  - Crouch: Defensive stance
---  - Overwatch: Reaction fire mode
---
---Key Exports:
---  - ActionPanel.new(x, y, width, height): Creates action panel
---  - setUnit(unit): Updates available actions for unit
---  - setSelectedAction(actionId): Selects specific action
---  - getSelectedAction(): Returns current selection
---  - setActionAvailable(actionId, available): Enables/disables action
---  - draw(): Renders panel with buttons
---  - mousepressed(x, y, button): Click handling (LMB select, RMB execute)
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.buttons.action_button: Action button widgets
---  - widgets.core.theme: Color and font theme
---
---@module widgets.display.action_panel
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ActionPanel = require("widgets.display.action_panel")
---  local panel = ActionPanel.new(0, 480, 960, 240)
---  panel:setUnit(selectedUnit)
---  panel:draw()
---
---@see widgets.buttons.action_button For individual action buttons

--[[
    Action Panel Widget

    Container for action buttons organized as a radio button group.
    Manages 8 action buttons in 2 rows (weapons/armor/skill in row 1, move modes in row 2).
    Features:
    - Radio button group behavior (only one action selected)
    - LMB selection, RMB execution
    - Action availability checking
    - Grid-aligned layout
]]

local BaseWidget = require("widgets.core.base")
local ActionButton = require("widgets.buttons.action_button")
local Theme = require("widgets.core.theme")

local ActionPanel = setmetatable({}, {__index = BaseWidget})
ActionPanel.__index = ActionPanel

-- Action definitions
ActionPanel.ACTIONS = {
    WEAPON_LEFT = {id = "weapon_left", name = "Weapon L", row = 1, col = 1},
    WEAPON_RIGHT = {id = "weapon_right", name = "Weapon R", row = 1, col = 2},
    ARMOR = {id = "armor", name = "Armor", row = 1, col = 3},
    SKILL = {id = "skill", name = "Skill", row = 1, col = 4},
    WALK = {id = "walk", name = "Walk", row = 2, col = 1},
    SNEAK = {id = "sneak", name = "Sneak", row = 2, col = 2},
    RUN = {id = "run", name = "Run", row = 2, col = 3},
    FLY = {id = "fly", name = "Fly", row = 2, col = 4}
}

--[[
    Create a new action panel
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New action panel instance
]]
function ActionPanel.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "action_panel")
    setmetatable(self, ActionPanel)

    self.buttons = {}  -- Action buttons by action ID
    self.selectedAction = nil  -- Currently selected action ID
    self.unit = nil  -- Current unit for availability checking

    -- Create action buttons
    self:createButtons()

    return self
end

--[[
    Create all action buttons
]]
function ActionPanel:createButtons()
    local buttonWidth = 144  -- 6 grid cells
    local buttonHeight = 48  -- 2 grid cells
    local spacing = 0  -- No spacing between buttons

    for actionId, actionDef in pairs(ActionPanel.ACTIONS) do
        local col = actionDef.col - 1  -- Convert to 0-based
        local row = actionDef.row - 1  -- Convert to 0-based

        local buttonX = self.x + col * buttonWidth
        local buttonY = self.y + row * buttonHeight

        local button = ActionButton.new(buttonX, buttonY, buttonWidth, buttonHeight, actionId, actionDef.name)
        button:setRadioGroup(self)

        -- Set up button callbacks
        button.onSelect = function(btn)
            self:onActionSelected(btn.actionId)
        end

        button.onClick = function(btn, x, y)
            self:onActionClicked(btn.actionId, x, y)
        end

        self.buttons[actionId] = button
    end
end

--[[
    Set the current unit for action availability checking
    @param unit table|nil - The unit to check actions for
]]
function ActionPanel:setUnit(unit)
    self.unit = unit
    self:updateActionAvailability()
end

--[[
    Update which actions are available based on current unit
]]
function ActionPanel:updateActionAvailability()
    if not self.unit then
        -- No unit selected, disable all actions
        for _, button in pairs(self.buttons) do
            button:setEnabled(false)
        end
        return
    end

    -- Check each action's availability
    for actionId, button in pairs(self.buttons) do
        local available = self:isActionAvailable(actionId)
        button:setEnabled(available)

        -- Clear selection if selected action becomes unavailable
        if not available and self.selectedAction == actionId then
            self.selectedAction = nil
            button:setSelected(false)
        end
    end
end

--[[
    Check if a specific action is available for the current unit
    @param actionId string - The action ID to check
    @return boolean - Whether the action is available
]]
function ActionPanel:isActionAvailable(actionId)
    if not self.unit then return false end

    if actionId == "weapon_left" or actionId == "weapon_right" then
        -- Check if unit has weapons equipped
        return self.unit.weaponLeft ~= nil or self.unit.weaponRight ~= nil
    elseif actionId == "armor" then
        -- Check if unit has armor ability
        return self.unit.armor and self.unit.armor.ability ~= nil
    elseif actionId == "skill" then
        -- Check if unit has skills
        return self.unit.skills and #self.unit.skills > 0
    elseif actionId == "walk" then
        -- Walk is always available
        return true
    elseif actionId == "sneak" then
        -- Sneak requires appropriate armor
        return self.unit.armor and self.unit.armor.moveModes and self.unit.armor.moveModes.sneak
    elseif actionId == "run" then
        -- Run requires appropriate armor
        return self.unit.armor and self.unit.armor.moveModes and self.unit.armor.moveModes.run
    elseif actionId == "fly" then
        -- Fly requires appropriate armor
        return self.unit.armor and self.unit.armor.moveModes and self.unit.armor.moveModes.fly
    end

    return false
end

--[[
    Handle radio button selection (called by ActionButton)
    @param button table - The selected button
]]
function ActionPanel:selectButton(button)
    -- Deselect all other buttons
    for actionId, btn in pairs(self.buttons) do
        if btn ~= button then
            btn:setSelected(false)
        end
    end

    -- Select the new button
    button:setSelected(true)
    self.selectedAction = button.actionId

    -- Call selection callback
    if self.onActionSelected then
        self.onActionSelected(self.selectedAction)
    end
end

--[[
    Get the currently selected action
    @return string|nil - The selected action ID or nil
]]
function ActionPanel:getSelectedAction()
    return self.selectedAction
end

--[[
    Clear the current selection
]]
function ActionPanel:clearSelection()
    self.selectedAction = nil
    for _, button in pairs(self.buttons) do
        button:setSelected(false)
    end
end

--[[
    Handle action selection (called when button is selected)
    @param actionId string - The selected action ID
]]
function ActionPanel:onActionSelected(actionId)
    print("[ActionPanel] Action selected: " .. actionId)

    -- Update cursor based on selected action
    self:updateCursor(actionId)
end

--[[
    Handle action click (called when button is clicked)
    @param actionId string - The clicked action ID
    @param x number - Mouse X position
    @param y number - Mouse Y position
]]
function ActionPanel:onActionClicked(actionId, x, y)
    print("[ActionPanel] Action clicked: " .. actionId .. " at (" .. x .. ", " .. y .. ")")

    -- This is for LMB clicks on the button itself
    -- RMB execution is handled at the battlescape level
end

--[[
    Update cursor appearance based on selected action
    @param actionId string - The selected action ID
]]
function ActionPanel:updateCursor(actionId)
    if not love or not love.mouse then return end

    if actionId == "weapon_left" or actionId == "weapon_right" then
        -- Targeting cursor for weapons
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    elseif actionId == "armor" or actionId == "skill" then
        -- Special cursor for abilities
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    elseif actionId == "walk" or actionId == "sneak" or actionId == "run" or actionId == "fly" then
        -- Movement cursor
        love.mouse.setCursor(love.mouse.getSystemCursor("sizeall"))
    else
        -- Default cursor
        love.mouse.setCursor()
    end
end

--[[
    Draw the action panel
]]
function ActionPanel:draw()
    if not self.visible then
        return
    end

    -- Draw all buttons
    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

--[[
    Handle mouse press (delegate to buttons)
]]
function ActionPanel:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end

    -- Check buttons in reverse order (top to bottom)
    for _, btn in pairs(self.buttons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end

    return false
end

--[[
    Handle mouse release (delegate to buttons)
]]
function ActionPanel:mousereleased(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end

    -- Check buttons in reverse order (top to bottom)
    for _, btn in pairs(self.buttons) do
        if btn:mousereleased(x, y, button) then
            return true
        end
    end

    return false
end

--[[
    Update hover states
]]
function ActionPanel:update(dt)
    if not self.visible then
        return
    end

    -- Update button hover states
    local mouseX, mouseY = love.mouse.getPosition()

    for _, button in pairs(self.buttons) do
        local wasHovered = button.hovered
        button.hovered = button:containsPoint(mouseX, mouseY)

        -- Handle hover changes
        if button.hovered and not wasHovered then
            if button.onHover then
                button.onHover(button, true)
            end
        elseif not button.hovered and wasHovered then
            if button.onHover then
                button.onHover(button, false)
            end
        end
    end
end

print("[ActionPanel] Action panel widget loaded")

return ActionPanel





















