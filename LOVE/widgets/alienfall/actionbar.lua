--[[
widgets/actionbar.lua
ActionBar widget for unit ability and action selection


Unit ability and action selection interface for tactical combat in turn-based strategy games.
Provides organized display of available actions with cooldowns, costs, and visual feedback.

PURPOSE:
- Display available unit abilities, actions, and commands in an organized bar format
- Enable quick selection of actions during tactical combat phases
- Provide visual feedback for action states and limitations
- Support strategic decision making in turn-based gameplay

KEY FEATURES:
- Configurable action slots with cooldowns, costs, and visual feedback
- Support for action categories (attack, defense, movement, utility, special)
- Hotkey display, tooltips, and accessibility features
- Optional drag-and-drop reordering and animation effects
- Action point tracking and turn management integration
- Visual indicators for available, on-cooldown, and disabled actions
- Customizable layout and theming options
- Integration with unit stats and game state

@see widgets.common.core.Base
@see widgets.common.button
@see widgets.complex.unitpanel
]]

--- ActionBar widget module for unit ability and action selection.
--
-- Unit ability and action selection interface for tactical combat in turn-based strategy games.
-- Provides organized display of available actions with cooldowns, costs, and visual feedback.
--
-- @module ActionBar
-- @see widgets.common.core.Base
-- @see widgets.common.button
-- @see widgets.complex.unitpanel

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Button = require("widgets.common.button")

--- ActionBar class for displaying unit abilities and actions.
-- Provides a configurable action bar with cooldowns, costs, tooltips, and visual feedback
-- for turn-based strategy game combat interfaces.
-- @type ActionBar
local ActionBar = {}
ActionBar.__index = ActionBar
setmetatable(ActionBar, { __index = core.Base })

--- Creates a new ActionBar instance.
--
-- @param x The x coordinate of the action bar
-- @param y The y coordinate of the action bar
-- @param w The width of the action bar
-- @param h The height of the action bar
-- @param options Configuration options table
-- @return ActionBar A new ActionBar instance
function ActionBar:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Actions configuration
    obj.actions = (options and options.actions) or {}
    obj.maxActions = (options and options.maxActions) or 8
    obj.orientation = (options and options.orientation) or "horizontal" -- "horizontal" or "vertical"
    obj.allowReordering = (options and options.allowReordering) or false

    -- Layout properties
    obj.spacing = (options and options.spacing) or 4
    obj.padding = (options and options.padding) or { 4, 4, 4, 4 }
    obj.buttonSize = (options and options.buttonSize) or 48
    obj.showLabels = (options and options.showLabels) ~= false
    obj.showHotkeys = (options and options.showHotkeys) ~= false
    obj.showCooldowns = (options and options.showCooldowns) ~= false
    obj.showCosts = (options and options.showCosts) ~= false

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundDark
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.showBorder = (options and options.showBorder) ~= false
    obj.borderRadius = (options and options.borderRadius) or 6

    -- Action states and effects
    obj.selectedAction = nil
    obj.hoveredAction = nil
    obj.actionCooldowns = {}
    obj.actionAnimations = {}
    obj.pulseEffects = {}

    -- Colors for different action states
    obj.stateColors = {
        available = { 0.2, 0.8, 0.2, 0.9 },
        unavailable = { 0.4, 0.4, 0.4, 0.6 },
        cooldown = { 0.8, 0.4, 0.2, 0.7 },
        selected = { 0.2, 0.6, 1, 0.9 },
        charging = { 1, 1, 0.2, 0.8 }
    }

    -- Action categories and colors
    obj.categoryColors = {
        attack = { 1, 0.3, 0.3 },
        defense = { 0.3, 0.3, 1 },
        movement = { 0.3, 1, 0.3 },
        utility = { 1, 1, 0.3 },
        special = { 1, 0.3, 1 }
    }

    -- Animation settings
    obj.animateActions = (options and options.animateActions) ~= false
    obj.highlightAvailable = (options and options.highlightAvailable) ~= false
    obj.pulseNewActions = (options and options.pulseNewActions) ~= false

    -- Interaction
    obj.draggedAction = nil
    obj.dragOffset = { x = 0, y = 0 }
    obj.showTooltips = (options and options.showTooltips) ~= false

    -- Callbacks
    obj.onActionClick = options and options.onActionClick
    obj.onActionHover = options and options.onActionHover
    obj.onActionReorder = options and options.onActionReorder
    obj.onActionContext = options and options.onActionContext

    -- Tooltip state
    obj.tooltipText = ""
    obj.tooltipX = 0
    obj.tooltipY = 0
    obj.showTooltip = false

    setmetatable(obj, self)
    return obj
end

--- Sets the actions to be displayed in the action bar.
---
--- Replaces the current actions and triggers pulse effects for new actions.
---
---@param actions table Array of action objects to display.
function ActionBar:setActions(actions)
    local oldActions = {}
    for _, action in ipairs(self.actions) do
        oldActions[action.id] = true
    end

    self.actions = actions

    -- Trigger pulse effect for new actions
    if self.pulseNewActions then
        for _, action in ipairs(actions) do
            if not oldActions[action.id] then
                self:_triggerPulse(action.id)
            end
        end
    end
end

--- Adds a single action to the action bar.
---
---@param action table The action object to add.
function ActionBar:addAction(action)
    table.insert(self.actions, action)

    if self.pulseNewActions then
        self:_triggerPulse(action.id)
    end
end

--- Removes an action from the action bar by ID.
---
---@param actionId any The ID of the action to remove.
function ActionBar:removeAction(actionId)
    for i, action in ipairs(self.actions) do
        if action.id == actionId then
            table.remove(self.actions, i)
            break
        end
    end
end

--- Updates an existing action's properties.
---
---@param actionId any The ID of the action to update.
---@param data table Table of properties to update.
function ActionBar:updateAction(actionId, data)
    for _, action in ipairs(self.actions) do
        if action.id == actionId then
            for key, value in pairs(data) do
                action[key] = value
            end
            break
        end
    end
end

--- Sets a cooldown for an action.
---
---@param actionId any The ID of the action.
---@param cooldown number The cooldown duration in seconds.
---@param maxCooldown? number Optional maximum cooldown value.
function ActionBar:setActionCooldown(actionId, cooldown, maxCooldown)
    self.actionCooldowns[actionId] = {
        current = cooldown,
        max = maxCooldown or cooldown,
        startTime = love.timer.getTime()
    }
end

function ActionBar:_triggerPulse(actionId)
    self.pulseEffects[actionId] = {
        startTime = love.timer.getTime(),
        duration = 1.0
    }
end

function ActionBar:_getActionButton(action, index)
    local buttonsPerRow, totalRows = self:_calculateLayout()

    local buttonX, buttonY
    if self.orientation == "horizontal" then
        local col = (index - 1) % buttonsPerRow
        local row = math.floor((index - 1) / buttonsPerRow)
        buttonX = self.x + self.padding[4] + col * (self.buttonSize + self.spacing)
        buttonY = self.y + self.padding[1] + row * (self.buttonSize + self.spacing)
    else
        local row = (index - 1) % buttonsPerRow
        local col = math.floor((index - 1) / buttonsPerRow)
        buttonX = self.x + self.padding[4] + col * (self.buttonSize + self.spacing)
        buttonY = self.y + self.padding[1] + row * (self.buttonSize + self.spacing)
    end

    return buttonX, buttonY
end

function ActionBar:_calculateLayout()
    local availableWidth = self.w - self.padding[2] - self.padding[4]
    local availableHeight = self.h - self.padding[1] - self.padding[3]

    if self.orientation == "horizontal" then
        local buttonsPerRow = math.floor((availableWidth + self.spacing) / (self.buttonSize + self.spacing))
        local totalRows = math.ceil(#self.actions / buttonsPerRow)
        return buttonsPerRow, totalRows
    else
        local buttonsPerCol = math.floor((availableHeight + self.spacing) / (self.buttonSize + self.spacing))
        local totalCols = math.ceil(#self.actions / buttonsPerCol)
        return buttonsPerCol, totalCols
    end
end

--- Updates the action bar state.
---
---@param dt number Delta time since last update.
function ActionBar:update(dt)
    core.Base.update(self, dt)

    -- Update cooldowns
    for actionId, cooldown in pairs(self.actionCooldowns) do
        cooldown.current = math.max(0, cooldown.current - dt)
        if cooldown.current <= 0 then
            self.actionCooldowns[actionId] = nil
        end
    end

    -- Update pulse effects
    for actionId, pulse in pairs(self.pulseEffects) do
        local elapsed = love.timer.getTime() - pulse.startTime
        if elapsed >= pulse.duration then
            self.pulseEffects[actionId] = nil
        end
    end
end

--- Draws the action bar and all its action buttons.
function ActionBar:draw()
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)

    -- Draw border
    if self.showBorder then
        love.graphics.setColor(unpack(self.borderColor))
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)
    end

    -- Draw action buttons
    for i, action in ipairs(self.actions) do
        if i <= self.maxActions then
            self:_drawActionButton(action, i)
        end
    end

    -- Draw tooltip
    if self.showTooltip and self.showTooltips then
        self:_drawTooltip()
    end
end

function ActionBar:_drawActionButton(action, index)
    local buttonX, buttonY = self:_getActionButton(action, index)
    local isSelected = self.selectedAction == action.id
    local isHovered = self.hoveredAction == action.id

    -- Determine button state and color
    local state = "available"
    if not action.available then
        state = "unavailable"
    elseif self.actionCooldowns[action.id] then
        state = "cooldown"
    elseif action.charging then
        state = "charging"
    elseif isSelected then
        state = "selected"
    end

    local buttonColor = self.stateColors[state]

    -- Apply pulse effect
    local pulseIntensity = 1
    if self.pulseEffects[action.id] then
        local pulse = self.pulseEffects[action.id]
        local elapsed = love.timer.getTime() - pulse.startTime
        local progress = elapsed / pulse.duration
        pulseIntensity = 1 + 0.5 * math.sin(progress * math.pi * 6) * (1 - progress)
    end

    -- Apply hover effect
    if isHovered then
        buttonColor = {
            math.min(1, buttonColor[1] * 1.2),
            math.min(1, buttonColor[2] * 1.2),
            math.min(1, buttonColor[3] * 1.2),
            buttonColor[4]
        }
    end

    -- Draw button background
    love.graphics.setColor(unpack(buttonColor))
    local buttonSize = self.buttonSize * pulseIntensity
    local offsetX = (self.buttonSize - buttonSize) / 2
    local offsetY = (self.buttonSize - buttonSize) / 2
    love.graphics.rectangle("fill", buttonX + offsetX, buttonY + offsetY, buttonSize, buttonSize, 6)

    -- Draw category color indicator
    if action.category and self.categoryColors[action.category] then
        love.graphics.setColor(unpack(self.categoryColors[action.category]))
        love.graphics.rectangle("fill", buttonX + 2, buttonY + 2, 8, 8)
    end

    -- Draw action icon or text
    if action.icon then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.fontBold)
        local iconSize = 24
        local iconX = buttonX + (self.buttonSize - iconSize) / 2
        local iconY = buttonY + (self.buttonSize - iconSize) / 2
        love.graphics.print(action.icon, iconX, iconY)
    elseif action.image then
        love.graphics.setColor(1, 1, 1)
        local scale = math.min((self.buttonSize - 8) / action.image:getWidth(),
            (self.buttonSize - 8) / action.image:getHeight())
        local imageX = buttonX + (self.buttonSize - action.image:getWidth() * scale) / 2
        local imageY = buttonY + (self.buttonSize - action.image:getHeight() * scale) / 2
        love.graphics.draw(action.image, imageX, imageY, 0, scale, scale)
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.font)
        local text = action.name or "?"
        local textWidth = core.theme.font:getWidth(text)
        local textHeight = core.theme.font:getHeight()
        love.graphics.print(text,
            buttonX + (self.buttonSize - textWidth) / 2,
            buttonY + (self.buttonSize - textHeight) / 2)
    end

    -- Draw cooldown overlay
    if self.showCooldowns and self.actionCooldowns[action.id] then
        local cooldown = self.actionCooldowns[action.id]
        local progress = cooldown.current / cooldown.max

        -- Cooldown overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", buttonX, buttonY, self.buttonSize, self.buttonSize * progress, 6)

        -- Cooldown text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.fontBold)
        local cooldownText = string.format("%.1f", cooldown.current)
        local textWidth = core.theme.fontBold:getWidth(cooldownText)
        love.graphics.print(cooldownText,
            buttonX + (self.buttonSize - textWidth) / 2,
            buttonY + self.buttonSize / 2)
    end

    -- Draw cost indicator
    if self.showCosts and action.cost then
        love.graphics.setColor(1, 1, 0.6)
        love.graphics.setFont(core.theme.font)
        local costText = tostring(action.cost)
        love.graphics.print(costText, buttonX + 2, buttonY + self.buttonSize - 12)
    end

    -- Draw hotkey
    if self.showHotkeys and action.hotkey then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.setFont(core.theme.font)
        local hotkeyText = action.hotkey
        local textWidth = core.theme.font:getWidth(hotkeyText)
        love.graphics.print(hotkeyText,
            buttonX + self.buttonSize - textWidth - 2,
            buttonY + 2)
    end

    -- Draw button border
    love.graphics.setColor(isSelected and { 1, 1, 1 } or { 0.6, 0.6, 0.6 })
    love.graphics.setLineWidth(isSelected and 3 or 1)
    love.graphics.rectangle("line", buttonX, buttonY, self.buttonSize, self.buttonSize, 6)

    -- Draw availability indicator
    if self.highlightAvailable and action.available and not self.actionCooldowns[action.id] then
        local glow = 0.5 + 0.5 * math.sin(love.timer.getTime() * 4)
        love.graphics.setColor(0.2, 1, 0.2, glow * 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", buttonX - 1, buttonY - 1, self.buttonSize + 2, self.buttonSize + 2, 6)
    end
end

function ActionBar:_drawTooltip()
    if not self.tooltipText or self.tooltipText == "" then return end

    love.graphics.setFont(core.theme.font)
    local lines = {}
    for line in self.tooltipText:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local maxWidth = 0
    for _, line in ipairs(lines) do
        maxWidth = math.max(maxWidth, core.theme.font:getWidth(line))
    end

    local tooltipWidth = maxWidth + 16
    local tooltipHeight = #lines * core.theme.font:getHeight() + 12

    local tooltipX = math.min(self.tooltipX, love.graphics.getWidth() - tooltipWidth)
    local tooltipY = self.tooltipY - tooltipHeight - 10

    if tooltipY < 0 then
        tooltipY = self.tooltipY + 20
    end

    -- Draw tooltip background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4)

    -- Draw tooltip border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4)

    -- Draw tooltip text
    love.graphics.setColor(1, 1, 1)
    for i, line in ipairs(lines) do
        love.graphics.print(line, tooltipX + 8, tooltipY + 6 + (i - 1) * core.theme.font:getHeight())
    end
end

--- Handles mouse press events on the action bar.
---
---@param x number The mouse x coordinate.
---@param y number The mouse y coordinate.
---@param button number The mouse button that was pressed.
---@return boolean True if the event was handled.
function ActionBar:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    -- Check for action clicks
    for i, action in ipairs(self.actions) do
        if i <= self.maxActions then
            local buttonX, buttonY = self:_getActionButton(action, i)

            if core.isInside(x, y, buttonX, buttonY, self.buttonSize, self.buttonSize) then
                if button == 1 then -- Left click
                    self.selectedAction = action.id

                    if action.available and not self.actionCooldowns[action.id] then
                        if self.onActionClick then
                            self.onActionClick(action, self)
                        end
                    end
                elseif button == 2 then -- Right click
                    if self.onActionContext then
                        self.onActionContext(action, self)
                    end
                end

                return true
            end
        end
    end

    -- Clear selection if clicking empty space
    self.selectedAction = nil
    return true
end

--- Handles mouse movement events on the action bar.
---
---@param x number The current mouse x coordinate.
---@param y number The current mouse y coordinate.
---@param dx number The change in x coordinate since last movement.
---@param dy number The change in y coordinate since last movement.
function ActionBar:mousemoved(x, y, dx, dy)
    if not self:hitTest(x, y) then
        self.hoveredAction = nil
        self.showTooltip = false
    end

    local wasHovered = self.hoveredAction
    self.hoveredAction = nil

    -- Check for action hover
    for i, action in ipairs(self.actions) do
        if i <= self.maxActions then
            local buttonX, buttonY = self:_getActionButton(action, i)
            if core.isInside(x, y, buttonX, buttonY, self.buttonSize, self.buttonSize) then
                self.hoveredAction = action.id
                -- Show tooltip
                self.tooltipText = self:_getActionTooltip(action)
                self.tooltipX = x
                self.tooltipY = y
                self.showTooltip = true

                if self.onActionHover and wasHovered ~= action.id then
                    self.onActionHover(action, self)
                end

                break
            end
        end
    end
end

function ActionBar:keypressed(key)
    -- Handle hotkeys
    for _, action in ipairs(self.actions) do
        if action.hotkey and action.hotkey:lower() == key:lower() then
            if action.available and not self.actionCooldowns[action.id] then
                self.selectedAction = action.id
                if self.onActionClick then
                    self.onActionClick(action, self)
                end
            end
            return true
        end
    end

    return false
end

function ActionBar:_getActionTooltip(action)
    local tooltip = action.name or "Action"

    if action.description then
        tooltip = tooltip .. "\n" .. action.description
    end

    if action.cost then
        tooltip = tooltip .. "\nCost: " .. action.cost
    end

    if action.damage then
        tooltip = tooltip .. "\nDamage: " .. action.damage
    end

    if action.range then
        tooltip = tooltip .. "\nRange: " .. action.range
    end

    if action.cooldown then
        tooltip = tooltip .. "\nCooldown: " .. action.cooldown .. "s"
    end

    if action.hotkey then
        tooltip = tooltip .. "\nHotkey: " .. action.hotkey
    end

    local cooldown = self.actionCooldowns[action.id]
    if cooldown then
        tooltip = tooltip .. "\nCooldown: " .. string.format("%.1fs", cooldown.current)
    end

    if not action.available then
        tooltip = tooltip .. "\nUnavailable"
    end

    return tooltip
end

-- Public API
--- Selects an action by ID.
---
---@param actionId any The ID of the action to select.
function ActionBar:selectAction(actionId)
    self.selectedAction = actionId
end

--- Clears the current action selection.
function ActionBar:clearSelection()
    self.selectedAction = nil
end

--- Gets the currently selected action ID.
---
---@return any? The ID of the selected action, or nil if none selected.
function ActionBar:getSelectedAction()
    return self.selectedAction
end

--- Triggers an action by ID if it's available.
---
---@param actionId any The ID of the action to trigger.
---@return boolean True if the action was triggered successfully.
function ActionBar:triggerAction(actionId)
    for _, action in ipairs(self.actions) do
        if action.id == actionId then
            if action.available and not self.actionCooldowns[action.id] then
                self.selectedAction = actionId
                if self.onActionClick then
                    self.onActionClick(action, self)
                end
                return true
            end
            break
        end
    end
    return false
end

--- Checks if an action is ready to be used.
---
---@param actionId any The ID of the action to check.
---@return boolean True if the action is available and not on cooldown.
function ActionBar:isActionReady(actionId)
    for _, action in ipairs(self.actions) do
        if action.id == actionId then
            return action.available and not self.actionCooldowns[action.id]
        end
    end
    return false
end

return ActionBar






