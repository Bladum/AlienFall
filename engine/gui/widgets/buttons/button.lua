---Button Widget - Clickable Text Button
---
---A clickable button widget with text label, hover states, and click event handling.
---Foundation widget for UI interactions. Grid-aligned for consistent positioning.
---
---Features:
---  - Click event callbacks
---  - Hover state highlighting (lighter background)
---  - Enabled/disabled states
---  - Grid-aligned positioning (24×24 pixels)
---  - Theme-based styling
---  - Text centering
---
---Visual States:
---  - Normal: Default button appearance
---  - Hover: Lighter background when mouse over
---  - Pressed: Darker while mouse button held
---  - Disabled: Grayed out, no interaction
---
---Key Exports:
---  - Button.new(x, y, width, height, text): Creates button
---  - setText(text): Updates button label
---  - setCallback(func): Sets click handler
---  - draw(): Renders button
---  - mousepressed(x, y, button): Click handling
---  - mousemoved(x, y): Hover detection
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.buttons.button
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Button = require("gui.widgets.buttons.button")
---  local btn = Button.new(0, 0, 96, 48, "Click Me")
---  btn:setCallback(function() print("Clicked!") end)
---  btn:draw()
---
---@see widgets.buttons.imagebutton For image buttons

--[[
    Button Widget
    
    A clickable button with text label.
    Features:
    - Click events
    - Hover states
    - Enabled/disabled states
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local Button = setmetatable({}, {__index = BaseWidget})
Button.__index = Button

--[[
    Create a new button
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param text string - Button label text
    @return table - New button instance
]]
function Button.new(x, y, width, height, text)
    local self = BaseWidget.new(x, y, width, height, "button")
    setmetatable(self, Button)
    
    self.text = text or "Button"
    self.pressed = false
    
    return self
end

--[[
    Draw the button
]]
function Button:draw()
    if not self.visible then
        return
    end
    
    -- Determine button color based on state (using global styles)
    local bgColor
    if not self.enabled then
        bgColor = self.disabledColor
    elseif self.pressed then
        bgColor = self.activeColor
    elseif self.hovered then
        bgColor = self.hoverColor
    else
        bgColor = self.backgroundColor
    end
    
    -- Draw background
    Theme.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw text
    Theme.setFont(self.font)
    if self.enabled then
        Theme.setColor(self.textColor)
    else
        Theme.setColor(self.disabledTextColor)
    end
    
    local font = Theme.getFont(self.font)
    if not font then
        print("[ERROR] Button: No font available for '" .. tostring(self.font) .. "'")
        return
    end
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.text, textX, textY)
end

--[[
    Handle mouse press
]]
function Button:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        self.pressed = true
        return true
    end
    
    return false
end

--[[
    Handle mouse release
]]
function Button:mousereleased(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self.pressed and button == 1 then
        self.pressed = false
        
        if self:containsPoint(x, y) and self.onClick then
            self.onClick(self, x, y)
        end
        
        return true
    end
    
    return false
end

--[[
    Set button text
    @param text string - New button text
]]
function Button:setText(text)
    self.text = text
end

--[[
    Get button text
    @return string - Button text
]]
function Button:getText()
    return self.text
end

print("[Button] Button widget loaded")

return Button



























