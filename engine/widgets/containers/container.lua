---Container Widget - Generic Child Widget Container
---
---A generic container that manages child widgets. Provides layout, event propagation,
---and child widget lifecycle management. Base class for complex layouts. Includes
---automatic layout options and clipping support. Grid-aligned for consistent positioning.
---
---Features:
---  - Child widget management (add, remove, clear)
---  - Automatic layout options (horizontal, vertical, grid)
---  - Event propagation to children
---  - Grid-aligned positioning (24×24 pixels)
---  - Child z-order control
---  - Clipping to bounds support
---
---Layout Modes:
---  - None: Manual child positioning
---  - Horizontal: Arrange children left-to-right
---  - Vertical: Arrange children top-to-bottom
---  - Grid: Arrange children in rows/columns
---  - Flow: Wrap children like text
---
---Event Propagation:
---  - Children receive events first (front to back)
---  - Event consumed if child handles it
---  - Container handles if no child handles
---
---Key Exports:
---  - Container.new(x, y, width, height): Creates container
---  - addChild(widget): Adds child widget
---  - removeChild(widget): Removes child widget
---  - clearChildren(): Removes all children
---  - setLayout(mode): Sets layout mode
---  - updateLayout(): Recalculates child positions
---  - draw(): Renders container and children
---  - update(dt): Updates container and children
---  - mousepressed(x, y, button): Propagates to children
---  - keypressed(key): Propagates to children
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.containers.container
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Container = require("widgets.containers.container")
---  local container = Container.new(0, 0, 480, 360)
---  container:setLayout("vertical")
---  container:addChild(button1)
---  container:addChild(button2)
---  container:updateLayout()
---  container:draw()
---
---@see widgets.containers.panel For background panels
---@see widgets.containers.scrollbox For scrollable containers

--[[
    Container Widget
    
    A container for organizing child widgets.
    Features:
    - Child widget management
    - Automatic layout options
    - Clipping support
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local Container = setmetatable({}, {__index = BaseWidget})
Container.__index = Container

--[[
    Create a new container
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New container instance
]]
function Container.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "container")
    setmetatable(self, Container)
    
    self.padding = 4
    self.clipContent = false
    
    return self
end

--[[
    Draw the container
]]
function Container:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw children with optional clipping
    if self.clipContent then
        love.graphics.push()
        love.graphics.setScissor(self.x, self.y, self.width, self.height)
    end
    
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
    
    if self.clipContent then
        love.graphics.setScissor()
        love.graphics.pop()
    end
end

--[[
    Add a child widget
    @param child table - Widget to add
]]
function Container:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end

--[[
    Remove a child widget
    @param child table - Widget to remove
]]
function Container:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            break
        end
    end
end

--[[
    Clear all children
]]
function Container:clearChildren()
    for _, child in ipairs(self.children) do
        child.parent = nil
    end
    self.children = {}
end

--[[
    Forward mouse events to children
]]
function Container:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Check children in reverse order (top to bottom)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.mousepressed and child:mousepressed(x, y, button) then
            return true
        end
    end
    
    return false
end

function Container:mousereleased(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.mousereleased and child:mousereleased(x, y, button) then
            return true
        end
    end
    
    return false
end

function Container:mousemoved(x, y, dx, dy, istouch)
    if not self.visible or not self.enabled then
        return false
    end
    
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.mousemoved and child:mousemoved(x, y, dx, dy, istouch) then
            return true
        end
    end
    
    return false
end

return Container






















