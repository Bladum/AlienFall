--[[
    Button Widget
    
    A clickable button with text label.
    Features:
    - Click events
    - Hover states
    - Enabled/disabled states
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

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
