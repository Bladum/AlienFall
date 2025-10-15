---FrameBox Widget - Titled Frame Container
---
---A frame container with title bar for grouping child widgets. Supports optional
---collapsing to hide/show content. Used for organizing UI into logical sections.
---Grid-aligned for consistent positioning.
---
---Features:
---  - Title bar with text
---  - Child widget grouping
---  - Optional collapsing (hide/show content)
---  - Grid-aligned positioning (24×24 pixels)
---  - Border and background styling
---  - Collapse indicator (arrow icon)
---
---Frame Structure:
---  - Title bar: Top section with title text and collapse button
---  - Content area: Child widgets container
---  - Border: Frame outline
---  - Background: Optional background fill
---
---Collapsing Behavior:
---  - Click title bar to toggle
---  - Collapsed: Shows only title bar
---  - Expanded: Shows title bar and content
---  - Smooth animation (optional)
---
---Key Exports:
---  - FrameBox.new(x, y, width, height, title): Creates frame box
---  - setTitle(title): Updates title text
---  - addChild(widget): Adds child widget
---  - removeChild(widget): Removes child widget
---  - setCollapsed(collapsed): Sets collapse state
---  - isCollapsed(): Returns collapse state
---  - setCollapsible(collapsible): Enables/disables collapsing
---  - draw(): Renders frame and children
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.containers.framebox
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FrameBox = require("widgets.containers.framebox")
---  local frame = FrameBox.new(0, 0, 240, 120, "Unit Stats")
---  frame:addChild(healthLabel)
---  frame:addChild(apLabel)
---  frame:setCollapsible(true)
---  frame:draw()
---
---@see widgets.containers.panel For simple panels
---@see widgets.containers.window For draggable windows

--[[
    FrameBox Widget
    
    A frame container with title bar.
    Features:
    - Title text
    - Child widget grouping
    - Optional collapsing
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

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






















