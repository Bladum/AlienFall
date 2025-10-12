--[[
    Window Widget
    
    A draggable window container.
    Features:
    - Title bar with drag support
    - Close button
    - Resizable content area
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local Window = setmetatable({}, {__index = BaseWidget})
Window.__index = Window

--[[
    Create a new window
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param title string - Window title
    @return table - New window instance
]]
function Window.new(x, y, width, height, title)
    local self = BaseWidget.new(x, y, width, height, "window")
    setmetatable(self, Window)
    
    self.title = title or "Window"
    self.titleHeight = 24
    self.dragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.showCloseButton = true
    self.onClose = nil
    
    return self
end

--[[
    Draw the window
]]
function Window:draw()
    if not self.visible then
        return
    end
    
    -- Draw title bar
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.titleHeight)
    
    -- Draw title text
    Theme.setFont(self.font)
    Theme.setColor(self.textColor)
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local textY = self.y + (self.titleHeight - textHeight) / 2
    love.graphics.print(self.title, self.x + 8, textY)
    
    -- Draw close button
    if self.showCloseButton then
        local closeX = self.x + self.width - self.titleHeight
        local closeY = self.y
        
        Theme.setColor(self.hoverColor)
        love.graphics.rectangle("fill", closeX, closeY, self.titleHeight, self.titleHeight)
        
        Theme.setColor(self.textColor)
        love.graphics.setLineWidth(2)
        local padding = 6
        love.graphics.line(
            closeX + padding, closeY + padding,
            closeX + self.titleHeight - padding, closeY + self.titleHeight - padding
        )
        love.graphics.line(
            closeX + self.titleHeight - padding, closeY + padding,
            closeX + padding, closeY + self.titleHeight - padding
        )
    end
    
    -- Draw content area
    local contentY = self.y + self.titleHeight
    local contentHeight = self.height - self.titleHeight
    
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, contentY, self.width, contentHeight)
    
    -- Draw children
    love.graphics.push()
    love.graphics.setScissor(self.x, contentY, self.width, contentHeight)
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
    love.graphics.setScissor()
    love.graphics.pop()
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.line(self.x, self.y + self.titleHeight, self.x + self.width, self.y + self.titleHeight)
end

--[[
    Handle mouse press
]]
function Window:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check close button
    if self.showCloseButton then
        local closeX = self.x + self.width - self.titleHeight
        if x >= closeX and x < closeX + self.titleHeight and
           y >= self.y and y < self.y + self.titleHeight then
            if self.onClose then
                self.onClose()
            else
                self.visible = false
            end
            return true
        end
    end
    
    -- Check title bar for dragging
    if x >= self.x and x < self.x + self.width and
       y >= self.y and y < self.y + self.titleHeight then
        self.dragging = true
        self.dragOffsetX = x - self.x
        self.dragOffsetY = y - self.y
        return true
    end
    
    -- Forward to children
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.mousepressed and child:mousepressed(x, y, button) then
            return true
        end
    end
    
    return self:containsPoint(x, y)
end

--[[
    Handle mouse release
]]
function Window:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
    end
end

--[[
    Handle mouse movement
]]
function Window:mousemoved(x, y, dx, dy, istouch)
    if self.dragging then
        self.x = x - self.dragOffsetX
        self.y = y - self.dragOffsetY
        return true
    end
    
    return false
end

--[[
    Add a child widget
]]
function Window:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end

return Window
