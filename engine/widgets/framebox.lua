--[[
    FrameBox Widget
    
    A frame container with title bar.
    Features:
    - Title text
    - Child widget grouping
    - Optional collapsing
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local FrameBox = setmetatable({}, {__index = BaseWidget})
FrameBox.__index = FrameBox

--[[
    Create a new frame box
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param title string - Frame title
    @return table - New frame box instance
]]
function FrameBox.new(x, y, width, height, title)
    local self = BaseWidget.new(x, y, width, height, "framebox")
    setmetatable(self, FrameBox)
    
    self.title = title or "Frame"
    self.titleHeight = 24
    self.padding = 4
    self.collapsed = false
    
    return self
end

--[[
    Draw the frame box
]]
function FrameBox:draw()
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
    love.graphics.print(self.title, self.x + self.padding, textY)
    
    -- Draw content area if not collapsed
    if not self.collapsed then
        local contentY = self.y + self.titleHeight
        local contentHeight = self.height - self.titleHeight
        
        -- Draw content background
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
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    if self.collapsed then
        love.graphics.rectangle("line", self.x, self.y, self.width, self.titleHeight)
    else
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.line(self.x, self.y + self.titleHeight, self.x + self.width, self.y + self.titleHeight)
    end
end

--[[
    Add a child widget
    @param child table - Widget to add
]]
function FrameBox:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end

--[[
    Toggle collapsed state
]]
function FrameBox:toggleCollapsed()
    self.collapsed = not self.collapsed
end

return FrameBox
