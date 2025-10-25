---BaseWidget Class - Foundation for All Widgets
---
---Base class that all widgets inherit from. Provides grid snapping, event handling,
---enabled/disabled states, visibility, and common properties. Core of the widget system.
---
---Core Features:
---  - Grid snapping (24×24 pixels, automatic)
---  - Position and size management
---  - Enabled/disabled state
---  - Visible/hidden state
---  - Event handling (mouse, keyboard)
---  - Parent-child relationships
---  - Z-order management
---
---Grid System Integration:
---  - All positions snap to 24×24 grid automatically
---  - All sizes snap to multiples of 24
---  - Grid helpers: snapToGrid(), snapSize()
---  - Grid coordinates: gridX, gridY
---
---Event System:
---  - mousepressed(x, y, button): Mouse click
---  - mousereleased(x, y, button): Mouse release
---  - mousemoved(x, y, dx, dy): Mouse movement
---  - wheelmoved(x, y): Scroll wheel
---  - keypressed(key, scancode, isrepeat): Keyboard input
---  - textinput(text): Character input
---
---Common Properties:
---  - x, y: Position (pixels, grid-aligned)
---  - width, height: Size (pixels, grid-aligned)
---  - enabled: Can be interacted with
---  - visible: Is rendered
---  - parent: Parent widget (for hierarchy)
---  - children: Array of child widgets
---
---Key Exports:
---  - BaseWidget.new(x, y, width, height): Creates widget
---  - setPosition(x, y): Moves widget (snaps to grid)
---  - setSize(width, height): Resizes widget (snaps to grid)
---  - setEnabled(enabled): Enables/disables widget
---  - setVisible(visible): Shows/hides widget
---  - addChild(widget): Adds child widget
---  - draw(): Renders widget (override in subclasses)
---  - update(dt): Updates widget (override in subclasses)
---
---Dependencies:
---  - widgets.core.grid: Grid system and snapping
---  - widgets.core.theme: Theme system
---
---@module widgets.core.base
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local BaseWidget = require("gui.widgets.core.base")
---  local MyWidget = setmetatable({}, {__index = BaseWidget})
---  function MyWidget.new(x, y, width, height)
---    local self = BaseWidget.new(x, y, width, height)
---    setmetatable(self, MyWidget)
---    return self
---  end
---
---@see widgets.core.grid For grid system
---@see widgets.core.theme For theming

--[[
    Base Widget Class
    
    All widgets inherit from this base class.
    Provides grid snapping, event handling, and common properties.
]]

local Grid = require("gui.widgets.core.grid")
local Theme = require("gui.widgets.core.theme")

local BaseWidget = {}
BaseWidget.__index = BaseWidget

--[[
    Create a new base widget
    @param x number - X position (will be snapped to grid)
    @param y number - Y position (will be snapped to grid)
    @param width number - Width (will be snapped to grid)
    @param height number - Height (will be snapped to grid)
    @return table - New widget instance
]]
function BaseWidget.new(x, y, width, height, widgetType)
    local self = setmetatable({}, BaseWidget)
    
    -- Snap position and size to grid (always multiples of 24)
    self.x, self.y = Grid.snapToGrid(x or 0, y or 0)
    self.width, self.height = Grid.snapSize(width or Grid.CELL_SIZE, height or Grid.CELL_SIZE)
    
    -- Verify grid alignment
    if not Grid.isOnGrid(self.x, self.y) then
        print("[BaseWidget] Warning: Widget position not on grid: (" .. self.x .. ", " .. self.y .. ")")
    end
    if not Grid.isValidSize(self.width, self.height) then
        print("[BaseWidget] Warning: Widget size not grid-aligned: (" .. self.width .. ", " .. self.height .. ")")
    end
    
    -- Common properties
    self.visible = true
    self.enabled = true
    self.focused = false
    self.hovered = false
    
    -- Z-index for drawing order (higher values drawn on top)
    self.zIndex = 0
    
    -- Event callbacks
    self.onClick = nil
    self.onHover = nil
    self.onFocus = nil
    self.onBlur = nil
    self.onChange = nil
    
    -- Parent/child relationships
    self.parent = nil
    self.children = {}
    
    -- Theme reference
    self.theme = Theme
    
    -- Apply global widget style if widget type is specified
    if widgetType then
        Theme.applyWidgetStyle(self, widgetType)
    end
    
    return self
end

--[[
    Check if a point is inside the widget
    @param px number - Point X coordinate
    @param py number - Point Y coordinate
    @return boolean - True if point is inside widget
]]
function BaseWidget:containsPoint(px, py)
    return px >= self.x and px < self.x + self.width and
           py >= self.y and py < self.y + self.height
end

--[[
    Update widget state (called each frame)
    @param dt number - Delta time
]]
function BaseWidget:update(dt)
    if not self.visible or not self.enabled then
        return
    end
    
    -- Update hover state
    local mx, my = love.mouse.getPosition()
    local wasHovered = self.hovered
    self.hovered = self:containsPoint(mx, my)
    
    if self.hovered and not wasHovered and self.onHover then
        self.onHover(self, true)
    elseif not self.hovered and wasHovered and self.onHover then
        self.onHover(self, false)
    end
    
    -- Update children
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

--[[
    Draw the widget (called each frame)
    Override in child classes
]]
function BaseWidget:draw()
    if not self.visible then
        return
    end
    
    -- Default: draw a simple rectangle
    if self.enabled then
        Theme.setColor("backgroundLight")
    else
        Theme.setColor("disabled")
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    Theme.setColor("border")
    love.graphics.setLineWidth(Theme.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw children
    for _, child in ipairs(self.children) do
        child:draw()
    end
end

--[[
    Handle mouse press event
    @param x number - Mouse X coordinate
    @param y number - Mouse Y coordinate
    @param button number - Mouse button
    @return boolean - True if event was handled
]]
function BaseWidget:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Check children first (reverse order for proper layering)
    for i = #self.children, 1, -1 do
        if self.children[i]:mousepressed(x, y, button) then
            return true
        end
    end
    
    if self:containsPoint(x, y) and button == 1 then
        self.focused = true
        if self.onClick then
            self.onClick(self, x, y)
        end
        if self.onFocus then
            self.onFocus(self)
        end
        return true
    end
    
    return false
end

--[[
    Handle mouse release event
    @param x number - Mouse X coordinate
    @param y number - Mouse Y coordinate
    @param button number - Mouse button
    @return boolean - True if event was handled
]]
function BaseWidget:mousereleased(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Pass to children
    for i = #self.children, 1, -1 do
        if self.children[i]:mousereleased(x, y, button) then
            return true
        end
    end
    
    return false
end

--[[
    Handle mouse move event
    @param x number - Mouse X coordinate
    @param y number - Mouse Y coordinate
    @param dx number - Mouse delta X
    @param dy number - Mouse delta Y
    @return boolean - True if event was handled
]]
function BaseWidget:mousemoved(x, y, dx, dy)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Pass to children
    for i = #self.children, 1, -1 do
        if self.children[i]:mousemoved(x, y, dx, dy) then
            return true
        end
    end
    
    return false
end

--[[
    Handle keyboard input
    @param key string - Key pressed
    @return boolean - True if event was handled
]]
function BaseWidget:keypressed(key)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    -- Pass to children
    for _, child in ipairs(self.children) do
        if child:keypressed(key) then
            return true
        end
    end
    
    return false
end

--[[
    Handle text input
    @param text string - Text entered
    @return boolean - True if event was handled
]]
function BaseWidget:textinput(text)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    -- Pass to children
    for _, child in ipairs(self.children) do
        if child:textinput(text) then
            return true
        end
    end
    
    return false
end

--[[
    Add a child widget
    @param child table - Child widget to add
]]
function BaseWidget:addChild(child)
    table.insert(self.children, child)
    child.parent = self
end

--[[
    Remove a child widget
    @param child table - Child widget to remove
]]
function BaseWidget:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            break
        end
    end
end

--[[
    Set widget position (snapped to grid)
    @param x number - New X position
    @param y number - New Y position
]]
function BaseWidget:setPosition(x, y)
    self.x, self.y = Grid.snapToGrid(x, y)
end

--[[
    Set widget size (snapped to grid)
    @param width number - New width
    @param height number - New height
]]
function BaseWidget:setSize(width, height)
    self.width, self.height = Grid.snapSize(width, height)
end

--[[
    Get widget bounds
    @return number, number, number, number - x, y, width, height
]]
function BaseWidget:getBounds()
    return self.x, self.y, self.width, self.height
end

--[[
    Show the widget
]]
function BaseWidget:show()
    self.visible = true
end

--[[
    Hide the widget
]]
function BaseWidget:hide()
    self.visible = false
end

--[[
    Enable the widget
]]
function BaseWidget:enable()
    self.enabled = true
end

--[[
    Disable the widget
]]
function BaseWidget:disable()
    self.enabled = false
end

--[[
    Destroy the widget (cleanup)
]]
function BaseWidget:destroy()
    -- Remove all children
    for _, child in ipairs(self.children) do
        child:destroy()
    end
    self.children = {}
    
    -- Remove from parent
    if self.parent then
        self.parent:removeChild(self)
    end
end

print("[BaseWidget] Base widget class loaded")

return BaseWidget



























