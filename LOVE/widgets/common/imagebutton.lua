--[[
widgets/imagebutton.lua
ImageButton widget for image-based button controls


Image-based button widget with hover and press states for visual interfaces.
Extends basic button functionality to display images or icons with state feedback.

PURPOSE:
- Provide image-based button controls for visual interfaces
- Enable icon-based navigation and action triggers
- Support visual feedback for different interaction states
- Facilitate intuitive user interfaces with graphical elements

KEY FEATURES:
- Image/icon display with automatic scaling and positioning
- Visual state feedback (normal, hover, pressed, disabled)
- Tooltip support for accessibility and additional context
- Callback system for click events and state changes
- Theme integration for consistent visual styling
- Border drawing and visual effects for interaction feedback
- Disabled state with opacity and interaction blocking
- Customizable image scaling and positioning options
- Support for image atlases and sprite sheets
- Animation support for state transitions

@see widgets.common.core.Base
@see widgets.common.button
@see widgets.common.tooltip
]]

local core = require("widgets.core")
local Interactive = require("widgets.common.interactive_mixin")
local ImageButton = {}
ImageButton.__index = ImageButton

function ImageButton:new(x, y, w, h, image, callback, options)
    local obj = {
        x = x,
        y = y,
        w = w,
        h = h,
        image = image,
        callback = callback,
        hovered = false,
        pressed = false,
        enabled = options and options.enabled ~= false or true,
        tooltip = options and options.tooltip or nil
    }
    -- Attach interactive helpers
    Interactive.init(obj)
    setmetatable(obj, self)
    return obj
end

--- Updates the image button state
--- @param dt number Time delta since last update
function ImageButton:update(dt)
    local mx, my = love.mouse.getPosition()
    if self.enabled then
        self:_updateHover(mx, my)
    else
        self._interactive.hovered = false
    end
    -- Keep legacy pressed flag in sync with mixin state
    self.pressed = self._interactive.pressed or (self.pressed and love.mouse.isDown(1))
end

--- Draws the image button
function ImageButton:draw()
    if not self.enabled then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    elseif self.pressed then
        love.graphics.setColor(0.8, 0.8, 0.8)
    elseif self.hovered then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.9, 0.9, 0.9)
    end

    if self.image then
        love.graphics.draw(self.image, self.x, self.y, 0, self.w / self.image:getWidth(), self.h / self.image:getHeight())
    end

    -- Draw border if hovered or pressed
    if self.hovered or self.pressed then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    end
end

--- Handles mouse press events for the image button
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function ImageButton:mousepressed(x, y, button)
    if button ~= 1 then return false end
    if core.isInside(x, y, self.x, self.y, self.w, self.h) then
        -- Use mixin helper to mark pressed and trigger callback on release
        if self:_mousepressed(x, y, button) then
            -- Keep legacy pressed state for compatibility
            self.pressed = self._interactive.pressed
            return true
        end
    end
    return false
end

return ImageButton
