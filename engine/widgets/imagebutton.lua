--[[
    ImageButton Widget
    
    A button with an image instead of text.
    Features:
    - Image rendering
    - Hover states
    - Click events
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local ImageButton = setmetatable({}, {__index = BaseWidget})
ImageButton.__index = ImageButton

--[[
    Create a new image button
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param image table - Love2D image object (optional)
    @return table - New image button instance
]]
function ImageButton.new(x, y, width, height, image)
    local self = BaseWidget.new(x, y, width, height, "imagebutton")
    setmetatable(self, ImageButton)
    
    self.image = image
    self.pressed = false
    self.scaleImage = true
    
    return self
end

--[[
    Draw the image button
]]
function ImageButton:draw()
    if not self.visible then
        return
    end
    
    -- Determine button color based on state
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
    
    -- Draw image
    if self.image then
        love.graphics.setColor(1, 1, 1, self.enabled and 1 or 0.5)
        
        if self.scaleImage then
            local scaleX = self.width / self.image:getWidth()
            local scaleY = self.height / self.image:getHeight()
            love.graphics.draw(self.image, self.x, self.y, 0, scaleX, scaleY)
        else
            local imgX = self.x + (self.width - self.image:getWidth()) / 2
            local imgY = self.y + (self.height - self.image:getHeight()) / 2
            love.graphics.draw(self.image, imgX, imgY)
        end
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

--[[
    Handle mouse press
]]
function ImageButton:mousepressed(x, y, button)
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
function ImageButton:mousereleased(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button == 1 and self.pressed then
        self.pressed = false
        
        if self:containsPoint(x, y) and self.onClick then
            self.onClick()
        end
        
        return true
    end
    
    return false
end

--[[
    Set button image
    @param image table - Love2D image object
]]
function ImageButton:setImage(image)
    self.image = image
end

return ImageButton
