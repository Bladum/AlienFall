--[[
    ScrollBox Widget
    
    A scrollable container for content that exceeds viewport.
    Features:
    - Vertical scrolling
    - Scroll bar
    - Mouse wheel support
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local ScrollBox = setmetatable({}, {__index = BaseWidget})
ScrollBox.__index = ScrollBox

--[[
    Create a new scroll box
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New scroll box instance
]]
function ScrollBox.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "scrollbox")
    setmetatable(self, ScrollBox)
    
    self.contentHeight = 0
    self.scrollY = 0
    self.scrollBarWidth = 12
    self.draggingScrollBar = false
    
    return self
end

--[[
    Draw the scroll box
]]
function ScrollBox:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Set scissor for content clipping
    love.graphics.push()
    love.graphics.setScissor(self.x, self.y, self.width - self.scrollBarWidth, self.height)
    
    -- Draw children with scroll offset
    love.graphics.translate(0, -self.scrollY)
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
    love.graphics.translate(0, self.scrollY)
    
    love.graphics.setScissor()
    love.graphics.pop()
    
    -- Draw scroll bar if needed
    if self.contentHeight > self.height then
        local scrollBarX = self.x + self.width - self.scrollBarWidth
        local scrollBarHeight = math.max(20, (self.height / self.contentHeight) * self.height)
        local scrollBarY = self.y + (self.scrollY / (self.contentHeight - self.height)) * (self.height - scrollBarHeight)
        
        -- Draw scroll track
        Theme.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", scrollBarX, self.y, self.scrollBarWidth, self.height)
        
        -- Draw scroll bar
        Theme.setColor(self.hoverColor)
        love.graphics.rectangle("fill", scrollBarX, scrollBarY, self.scrollBarWidth, scrollBarHeight)
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

--[[
    Handle mouse wheel scrolling
]]
function ScrollBox:wheelmoved(x, y)
    if not self.visible or not self.enabled then
        return false
    end
    
    local mx, my = love.mouse.getPosition()
    if self:containsPoint(mx, my) then
        self.scrollY = self.scrollY - y * 20
        self.scrollY = math.max(0, math.min(self.scrollY, self.contentHeight - self.height))
        return true
    end
    
    return false
end

--[[
    Set content height
    @param height number - Total content height
]]
function ScrollBox:setContentHeight(height)
    self.contentHeight = height
    self.scrollY = math.max(0, math.min(self.scrollY, self.contentHeight - self.height))
end

return ScrollBox
