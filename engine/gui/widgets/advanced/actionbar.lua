---ActionBar Widget - Horizontal Action Button Bar
---
---A horizontal bar containing multiple action buttons with cooldowns and hotkeys.
---Common in RPGs and strategy games for quick access to unit abilities and actions.
---Grid-aligned for consistent positioning.
---
---Features:
---  - Multiple action buttons in horizontal row
---  - Cooldown indicators (circular overlay)
---  - Hotkey labels (1-9, 0, -, =)
---  - Action point cost display
---  - Grid-aligned positioning (24×24 pixels)
---  - Disabled state for unavailable actions
---
---Button Layout:
---  - Button size: Configurable (typically 48×48 or 72×72)
---  - Spacing: Grid-aligned gaps between buttons
---  - Hotkey: Displayed in corner of each button
---  - AP cost: Action points required
---
---Action Structure:
---  - Icon: Visual representation
---  - Label: Action name
---  - Hotkey: Keyboard shortcut
---  - Callback: Function to execute
---  - AP Cost: Action points required
---  - Enabled: Can be used
---
---Key Exports:
---  - ActionBar.new(x, y, buttonCount): Creates action bar
---  - setAction(index, action): Assigns action to slot
---  - getAction(index): Returns action at slot
---  - clearAction(index): Removes action from slot
---  - setButtonSize(size): Sets button dimensions
---  - draw(): Renders action bar with buttons
---  - keypressed(key): Hotkey activation
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---  - widgets.buttons.imagebutton: Action buttons
---
---@module widgets.advanced.actionbar
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ActionBar = require("gui.widgets.advanced.actionbar")
---  local bar = ActionBar.new(0, 600, 10)
---  bar:setAction(1, {icon = moveIcon, callback = moveFunc, hotkey = "1"})
---  bar:setAction(2, {icon = shootIcon, callback = shootFunc, hotkey = "2"})
---  bar:draw()
---
---@see widgets.display.action_panel For vertical action layout

--[[
    ActionBar Widget
    
    Displays available unit actions in a horizontal bar.
    Features:
    - Action buttons with icons
    - Hotkey display
    - Action point cost
    - Disabled state for unavailable actions
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local ActionBar = setmetatable({}, {__index = BaseWidget})
ActionBar.__index = ActionBar

--[[
    Create a new action bar
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New action bar instance
]]
function ActionBar.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, ActionBar)
    
    self.actions = {}  -- {name, icon, hotkey, cost, callback, enabled}
    self.buttonSize = 48
    self.buttonSpacing = 4
    self.selectedAction = 0
    
    return self
end

--[[
    Draw the action bar
]]
function ActionBar:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw action buttons
    local startX = self.x + self.buttonSpacing
    local buttonY = self.y + (self.height - self.buttonSize) / 2
    
    Theme.setFont("small")
    
    for i, action in ipairs(self.actions) do
        local buttonX = startX + (i - 1) * (self.buttonSize + self.buttonSpacing)
        
        -- Draw button background
        local bgColor
        if i == self.selectedAction then
            bgColor = self.activeColor
        elseif not action.enabled then
            bgColor = self.disabledColor
        elseif self:isButtonHovered(buttonX, buttonY) then
            bgColor = self.hoverColor
        else
            bgColor = self.backgroundColor
        end
        
        Theme.setColor(bgColor)
        love.graphics.rectangle("fill", buttonX, buttonY, self.buttonSize, self.buttonSize)
        
        -- Draw button border
        Theme.setColor(self.borderColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", buttonX, buttonY, self.buttonSize, self.buttonSize)
        
        -- Draw icon or text
        if action.icon then
            love.graphics.setColor(1, 1, 1, action.enabled and 1 or 0.5)
            local iconScale = self.buttonSize / action.icon:getWidth()
            love.graphics.draw(action.icon, buttonX, buttonY, 0, iconScale, iconScale)
        else
            local textColor = action.enabled and self.textColor or self.disabledTextColor
            Theme.setColor(textColor)
            local font = Theme.getFont("small")
            ---@cast font love.Font
            local text = action.name:sub(1, 3):upper()
            local textX = buttonX + (self.buttonSize - font:getWidth(text)) / 2
            local textY = buttonY + (self.buttonSize - font:getHeight()) / 2
            love.graphics.print(text, textX, textY)
        end
        
        -- Draw hotkey
        if action.hotkey then
            Theme.setColor(self.textColor)
            love.graphics.print(action.hotkey, buttonX + 2, buttonY + 2)
        end
        
        -- Draw cost
        if action.cost and action.cost > 0 then
            Theme.setColor(self.textColor)
            local costText = tostring(action.cost)
            local font = Theme.getFont("small")
            ---@cast font love.Font
            local textX = buttonX + self.buttonSize - font:getWidth(costText) - 2
            local textY = buttonY + self.buttonSize - font:getHeight() - 2
            love.graphics.print(costText, textX, textY)
        end
    end
end

--[[
    Check if mouse is hovering over a button
]]
function ActionBar:isButtonHovered(buttonX, buttonY)
    local mx, my = love.mouse.getPosition()
    return mx >= buttonX and mx < buttonX + self.buttonSize and
           my >= buttonY and my < buttonY + self.buttonSize
end

--[[
    Handle mouse press
]]
function ActionBar:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check which button was clicked
    local startX = self.x + self.buttonSpacing
    local buttonY = self.y + (self.height - self.buttonSize) / 2
    
    for i, action in ipairs(self.actions) do
        local buttonX = startX + (i - 1) * (self.buttonSize + self.buttonSpacing)
        
        if x >= buttonX and x < buttonX + self.buttonSize and
           y >= buttonY and y < buttonY + self.buttonSize then
            if action.enabled then
                self.selectedAction = i
                
                if action.callback then
                    action.callback(action)
                end
                
                return true
            end
        end
    end
    
    return false
end

--[[
    Add an action to the bar
    @param action table - {name, icon, hotkey, cost, callback, enabled}
]]
function ActionBar:addAction(action)
    action.enabled = action.enabled ~= false  -- Default to true
    table.insert(self.actions, action)
end

--[[
    Clear all actions
]]
function ActionBar:clearActions()
    self.actions = {}
    self.selectedAction = 0
end

--[[
    Set action enabled state
    @param index number - Action index
    @param enabled boolean - Enabled state
]]
function ActionBar:setActionEnabled(index, enabled)
    if index >= 1 and index <= #self.actions then
        self.actions[index].enabled = enabled
    end
end

return ActionBar



























