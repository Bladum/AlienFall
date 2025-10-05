--[[
widgets/radiobutton.lua
RadioButton widget (exclusive selection control with group management)


Radio button widget providing exclusive selection within groups for tactical strategy
game interfaces. Essential for mutually exclusive option selection in settings panels,
difficulty choices, and configuration screens in OpenXCOM-style games.

PURPOSE:
- Provide exclusive selection controls within defined groups
- Enable mutually exclusive option choices in game interfaces
- Support group management for automatic deselection behavior
- Facilitate settings and configuration panels with clear choices
- Core component for option selection in strategy game UIs

KEY FEATURES:
- Exclusive selection within configurable groups
- Visual feedback for hover and selection states
- Automatic deselection of other buttons in same group
- Callback system for selection change notifications
- Circular design with filled center when selected
- Theme integration for consistent visual styling

@see widgets.common.checkbox
@see widgets.common.button
@see widgets.common.core.Base
]]

local core = require("widgets.core")
local RadioButton = {}
RadioButton.__index = RadioButton

--- Creates a new RadioButton widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param size number The diameter of the radio button
--- @param selected boolean Whether the radio button is initially selected
--- @param group table Array of other RadioButton instances in the same group
--- @param callback function The function to call when the radio button is selected
--- @return RadioButton A new radio button widget instance
function RadioButton:new(x, y, size, selected, group, callback)
    local obj = { x = x, y = y, size = size, selected = selected, group = group, callback = callback, hovered = false }
    setmetatable(obj, self)
    return obj
end

--- Updates the radio button state and hover detection
--- @param dt number Time delta since last update
function RadioButton:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = core.isInside(mx, my, self.x, self.y, self.size, self.size)
end

--- Draws the radio button with visual feedback for hover and selection states
function RadioButton:draw()
    if self.hovered then love.graphics.setColor(0.8, 0.8, 0.8) else love.graphics.setColor(0.7, 0.7, 0.7) end
    love.graphics.circle("fill", self.x + self.size / 2, self.y + self.size / 2, self.size / 2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", self.x + self.size / 2, self.y + self.size / 2, self.size / 2)
    if self.selected then love.graphics.circle("fill", self.x + self.size / 2, self.y + self.size / 2, self.size / 4) end
end

--- Handles mouse press events for the radio button
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
function RadioButton:mousepressed(x, y, button)
    if button == 1 and self.hovered then
        for _, rb in ipairs(self.group or {}) do rb.selected = false end
        self.selected = true
        if self.callback then self.callback() end
    end
end

return RadioButton
