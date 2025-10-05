--[[
widgets/common/togglebutton.lua
Toggle button widget that maintains a persistent on/off state

The ToggleButton extends the basic Button widget to provide persistent state
management. When clicked, it toggles between on and off states, maintaining
its current state until clicked again. This makes it ideal for settings,
preferences, and any binary choice that needs to persist.

PURPOSE:
- Provide persistent state management for on/off toggles
- Extend Button widget for consistent behavior
- Support settings, preferences, and binary choices

KEY FEATURES:
- Persistent on/off state with visual feedback
- Extends Button widget for consistent behavior
- Callback system for state change notifications
- Visual distinction between toggled and untoggled states
- Theme integration with accent color for active state
- All Button features (hover, press, disabled states)
- Accessibility support inherited from Button

@see widgets.common.button
]]

local core = require("widgets.core")
local Button = require("widgets.common.button")

local ToggleButton = setmetatable({}, { __index = Button })
ToggleButton.__index = ToggleButton

--- Creates a new ToggleButton widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the toggle button
--- @param h number The height of the toggle button
--- @param text string The text to display on the button
--- @param callback function The callback function to call when toggled
--- @param options table Optional configuration table
--- @return ToggleButton A new toggle button widget instance
function ToggleButton:new(x, y, w, h, text, callback, options)
    local obj = Button:new(x, y, w, h, text, callback, options)
    obj.toggled = options and options.toggled or false
    setmetatable(obj, self)
    return obj
end

--- Handles mouse release events for the toggle button widget
--- @param x number The x-coordinate of the mouse release
--- @param y number The y-coordinate of the mouse release
--- @param button number The mouse button that was released
--- @return boolean True if the event was handled, false otherwise
function ToggleButton:mousereleased(x, y, button)
    if not self.enabled then return false end
    if button == 1 and self.pressed then
        if self.hovered then
            self.toggled = not self.toggled
            if type(self.callback) == "function" then
                pcall(self.callback, self.toggled)
            end
            return true
        end
        self.pressed = false
    end
    return false
end

--- Draws the toggle button widget with toggled state visual feedback
function ToggleButton:draw()
    -- draw background based on toggled state, else fallback to Button
    if self.toggled then
        love.graphics.setColor(unpack(core.theme.accent))
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        love.graphics.setColor(unpack(self.colors.border or core.theme.border))
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    else
        Button.draw(self)
    end
    -- draw text on top
    love.graphics.setFont(self.font or love.graphics.getFont())
    love.graphics.setColor(unpack(self.colors.text or core.theme.text))
    local textY = self.y + self.h / 2 - (self.font and self.font:getHeight() or love.graphics.getFont():getHeight()) / 2
    love.graphics.printf(self.text or "", self.x, textY, self.w, "center")
end

return ToggleButton
