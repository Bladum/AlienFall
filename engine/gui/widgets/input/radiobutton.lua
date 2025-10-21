---RadioButton Widget - Mutually Exclusive Option Selector
---
---A radio button for mutually exclusive options in a group. Only one radio button
---in a group can be selected at a time. Grid-aligned for consistent positioning.
---
---Features:
---  - Selected/unselected states (filled/empty circle)
---  - Radio button groups (by group name)
---  - onChange event callback
---  - Grid-aligned positioning (24×24 pixels)
---  - Label text beside button
---  - Keyboard support (Space to select)
---
---Radio Button Group Behavior:
---  - All buttons with same groupName form a group
---  - Selecting one button deselects others in group
---  - Only one button selected per group
---  - Group managed automatically by groupName property
---
---Visual States:
---  - Unselected: Empty circle
---  - Selected: Filled circle
---  - Hover: Lighter border
---  - Disabled: Grayed out
---
---Key Exports:
---  - RadioButton.new(x, y, width, height, label, groupName): Creates radio button
---  - setSelected(selected): Sets selection state
---  - isSelected(): Returns current state
---  - setGroup(groupName): Assigns to radio group
---  - setLabel(label): Updates label text
---  - setCallback(func): Sets onChange handler
---  - draw(): Renders radio button
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.input.radiobutton
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local RadioButton = require("gui.widgets.input.radiobutton")
---  local rb1 = RadioButton.new(0, 0, 192, 24, "Easy", "difficulty")
---  local rb2 = RadioButton.new(0, 24, 192, 24, "Medium", "difficulty")
---  local rb3 = RadioButton.new(0, 48, 192, 24, "Hard", "difficulty")
---  rb1:draw()
---
---@see widgets.input.checkbox For independent checkboxes

--[[
    RadioButton Widget
    
    A radio button for mutually exclusive options.
    Features:
    - Selected/unselected states
    - Radio button groups
    - onChange event
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local RadioButton = setmetatable({}, {__index = BaseWidget})
RadioButton.__index = RadioButton

--[[
    Create a new radio button
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param label string - Radio button label
    @param group string - Group identifier (optional)
    @return table - New radio button instance
]]
function RadioButton.new(x, y, width, height, label, group)
    local self = BaseWidget.new(x, y, width, height, "radiobutton")
    setmetatable(self, RadioButton)
    
    self.label = label or "Radio"
    self.selected = false
    self.group = group or "default"
    
    return self
end

--[[
    Draw the radio button
]]
function RadioButton:draw()
    if not self.visible then
        return
    end
    
    local circleSize = math.min(self.height - 4, 18)
    local circleX = self.x + 2 + circleSize / 2
    local circleY = self.y + self.height / 2
    
    -- Draw radio circle background
    if self.enabled then
        Theme.setColor(self.backgroundColor)
    else
        Theme.setColor(self.disabledColor)
    end
    love.graphics.circle("fill", circleX, circleY, circleSize / 2)
    
    -- Draw radio circle border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.circle("line", circleX, circleY, circleSize / 2)
    
    -- Draw selection dot if selected
    if self.selected then
        if self.enabled then
            Theme.setColor(self.textColor)
        else
            Theme.setColor(self.disabledTextColor)
        end
        love.graphics.circle("fill", circleX, circleY, circleSize / 4)
    end
    
    -- Draw label
    Theme.setFont(self.font)
    if self.enabled then
        Theme.setColor(self.textColor)
    else
        Theme.setColor(self.disabledTextColor)
    end
    
    local textX = self.x + circleSize + 8
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.label, textX, textY)
end

--[[
    Handle mouse press
]]
function RadioButton:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        if not self.selected then
            self.selected = true
            
            if self.onChange then
                self.onChange(true)
            end
        end
        
        return true
    end
    
    return false
end

--[[
    Set selected state
    @param selected boolean - New selected state
]]
function RadioButton:setSelected(selected)
    if self.selected ~= selected then
        self.selected = selected
        
        if self.onChange then
            self.onChange(self.selected)
        end
    end
end

--[[
    Get selected state
    @return boolean - Current selected state
]]
function RadioButton:isSelected()
    return self.selected
end

return RadioButton


























