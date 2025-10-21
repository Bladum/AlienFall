---Legacy UI System
---
---DEPRECATED: Simple UI widget library for buttons, labels, and panels. This is a
---legacy system being replaced by the new widgets system (widgets.init).
---
---Use widgets.init for new development instead of this module.
---
---Key Exports:
---  - UI.Button(x, y, width, height, text, callback): Creates button widget
---  - UI.Label(x, y, text): Creates text label
---  - UI.Panel(x, y, width, height): Creates container panel
---
---Dependencies:
---  - love.graphics: For rendering UI elements
---  - love.mouse: For input handling
---
---@module core.ui
---@deprecated Use widgets.init for new UI development
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- DEPRECATED - Use widgets.init instead
---  local UI = require("core.ui")
---  local button = UI.Button(100, 100, 200, 50, "Click Me", function()
---    print("Clicked!")
---  end)
---
---@see widgets.init For modern UI widget system
---@see widgets.buttons.button For replacement button widget

local UI = {}

-- Button widget
function UI.Button(x, y, width, height, text, callback)
    local button = {
        x = x,
        y = y,
        width = width,
        height = height,
        text = text,
        callback = callback,
        hovered = false,
        pressed = false,
        enabled = true,
        
        -- Colors
        normalColor = {0.3, 0.3, 0.4},
        hoverColor = {0.4, 0.4, 0.5},
        pressColor = {0.2, 0.2, 0.3},
        disabledColor = {0.2, 0.2, 0.2},
        textColor = {1, 1, 1},
        disabledTextColor = {0.5, 0.5, 0.5}
    }
    
    function button:update(mx, my)
        if not self.enabled then
            self.hovered = false
            return
        end
        
        self.hovered = mx >= self.x and mx <= self.x + self.width and
                      my >= self.y and my <= self.y + self.height
    end
    
    function button:draw()
        -- Choose color based on state
        local color
        if not self.enabled then
            color = self.disabledColor
        elseif self.pressed and self.hovered then
            color = self.pressColor
        elseif self.hovered then
            color = self.hoverColor
        else
            color = self.normalColor
        end
        
        -- Draw button background
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- Draw border
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        
        -- Draw text
        local textColor = self.enabled and self.textColor or self.disabledTextColor
        love.graphics.setColor(textColor)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(self.text)
        local textHeight = font:getHeight()
        love.graphics.print(
            self.text,
            self.x + (self.width - textWidth) / 2,
            self.y + (self.height - textHeight) / 2
        )
        
        love.graphics.setColor(1, 1, 1) -- Reset color
    end
    
    function button:mousepressed(x, y, btn)
        if btn == 1 and self.enabled and self.hovered then
            self.pressed = true
            return true
        end
        return false
    end
    
    function button:mousereleased(x, y, btn)
        if btn == 1 and self.pressed and self.hovered and self.enabled then
            self.pressed = false
            if self.callback then
                self.callback()
            end
            return true
        end
        self.pressed = false
        return false
    end
    
    return button
end

-- Label widget
function UI.Label(x, y, text, align)
    local label = {
        x = x,
        y = y,
        text = text,
        align = align or "left", -- left, center, right
        color = {1, 1, 1},
        scale = 1
    }
    
    function label:draw()
        love.graphics.setColor(self.color)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(self.text) * self.scale
        
        local drawX = self.x
        if self.align == "center" then
            drawX = self.x - textWidth / 2
        elseif self.align == "right" then
            drawX = self.x - textWidth
        end
        
        love.graphics.print(self.text, drawX, self.y, 0, self.scale, self.scale)
        love.graphics.setColor(1, 1, 1) -- Reset color
    end
    
    function label:setText(text)
        self.text = text
    end
    
    return label
end

-- Panel widget (container)
function UI.Panel(x, y, width, height, title)
    local panel = {
        x = x,
        y = y,
        width = width,
        height = height,
        title = title,
        backgroundColor = {0.1, 0.1, 0.15, 0.9},
        borderColor = {0.5, 0.5, 0.6},
        titleColor = {1, 1, 1}
    }
    
    function panel:draw()
        -- Draw background
        love.graphics.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- Draw border
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        
        -- Draw title if exists
        if self.title then
            love.graphics.setColor(self.titleColor)
            local font = love.graphics.getFont()
            local textHeight = font:getHeight()
            love.graphics.print(self.title, self.x + 10, self.y + 5)
            
            -- Draw title separator line
            love.graphics.setColor(self.borderColor)
            love.graphics.line(
                self.x, 
                self.y + textHeight + 10,
                self.x + self.width,
                self.y + textHeight + 10
            )
        end
        
        love.graphics.setColor(1, 1, 1) -- Reset color
    end
    
    return panel
end

return UI

























