--- Base Widget Class
--- Provides common functionality for all UI widgets to reduce code duplication.
--- All widgets should inherit from this base class.
---
--- @module widgets.BaseWidget
--- @author AlienFall Development Team
--- @copyright 2025

local class = require('lib.middleclass')
local validate = require('utils.validate')

--- BaseWidget class that all UI widgets should inherit from
--- Provides standardized position, size, visibility, and interaction handling
---
--- @class BaseWidget
local BaseWidget = class('BaseWidget')

--- Initialize a new widget
--- Override this in subclasses and call BaseWidget.initialize(self, ...) first
---
--- @param x number X position (in pixels)
--- @param y number Y position (in pixels)
--- @param width number Widget width (in pixels)
--- @param height number Widget height (in pixels)
function BaseWidget:initialize(x, y, width, height)
    -- Position and size
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 100
    
    -- State
    self.visible = true
    self.enabled = true
    self.hovered = false
    self.focused = false
    
    -- Optional tooltip
    self.tooltip = nil
    
    -- Layout hints (for parent containers)
    self.anchor = nil  -- {x = "left"/"center"/"right", y = "top"/"center"/"bottom"}
    self.padding = {left = 0, right = 0, top = 0, bottom = 0}
    self.margin = {left = 0, right = 0, top = 0, bottom = 0}
    
    -- Children (for container widgets)
    self.children = {}
    
    -- Parent widget reference
    self.parent = nil
end

--- Check if a point is within the widget's bounds
---
--- @param px number X coordinate to check
--- @param py number Y coordinate to check
--- @return boolean True if point is within bounds
function BaseWidget:contains(px, py)
    return px >= self.x
        and px <= self.x + self.width
        and py >= self.y
        and py <= self.y + self.height
end

--- Get the widget's absolute position (accounting for parent)
--- Override this if widget uses custom coordinate system
---
--- @return number, number Absolute X and Y coordinates
function BaseWidget:getAbsolutePosition()
    local abs_x = self.x
    local abs_y = self.y
    
    if self.parent then
        local parent_x, parent_y = self.parent:getAbsolutePosition()
        abs_x = abs_x + parent_x
        abs_y = abs_y + parent_y
    end
    
    return abs_x, abs_y
end

--- Set widget position
---
--- @param x number New X position
--- @param y number New Y position
function BaseWidget:setPosition(x, y)
    validate.require_type(x, "number", "x")
    validate.require_type(y, "number", "y")
    self.x = x
    self.y = y
end

--- Get widget position
---
--- @return number, number X and Y position
function BaseWidget:getPosition()
    return self.x, self.y
end

--- Set widget size
---
--- @param width number New width
--- @param height number New height
function BaseWidget:setSize(width, height)
    validate.require_positive(width, "width")
    validate.require_positive(height, "height")
    self.width = width
    self.height = height
end

--- Get widget size
---
--- @return number, number Width and height
function BaseWidget:getSize()
    return self.width, self.height
end

--- Set widget bounds (position and size)
---
--- @param x number X position
--- @param y number Y position
--- @param width number Width
--- @param height number Height
function BaseWidget:setBounds(x, y, width, height)
    self:setPosition(x, y)
    self:setSize(width, height)
end

--- Get widget bounds
---
--- @return number, number, number, number X, Y, width, height
function BaseWidget:getBounds()
    return self.x, self.y, self.width, self.height
end

--- Set widget visibility
---
--- @param visible boolean True to make visible, false to hide
function BaseWidget:setVisible(visible)
    validate.require_type(visible, "boolean", "visible")
    self.visible = visible
end

--- Check if widget is visible
---
--- @return boolean True if visible
function BaseWidget:isVisible()
    -- Widget is visible if it and all parents are visible
    if not self.visible then
        return false
    end
    
    if self.parent then
        return self.parent:isVisible()
    end
    
    return true
end

--- Set widget enabled state
---
--- @param enabled boolean True to enable, false to disable
function BaseWidget:setEnabled(enabled)
    validate.require_type(enabled, "boolean", "enabled")
    self.enabled = enabled
end

--- Check if widget is enabled
---
--- @return boolean True if enabled
function BaseWidget:isEnabled()
    -- Widget is enabled if it and all parents are enabled
    if not self.enabled then
        return false
    end
    
    if self.parent then
        return self.parent:isEnabled()
    end
    
    return true
end

--- Set hover state
---
--- @param hovered boolean True if mouse is hovering
function BaseWidget:setHovered(hovered)
    self.hovered = hovered
end

--- Check if widget is hovered
---
--- @return boolean True if hovered
function BaseWidget:isHovered()
    return self.hovered
end

--- Set focus state
---
--- @param focused boolean True if widget has focus
function BaseWidget:setFocused(focused)
    self.focused = focused
end

--- Check if widget has focus
---
--- @return boolean True if focused
function BaseWidget:isFocused()
    return self.focused
end

--- Set tooltip text
---
--- @param text string Tooltip text (or nil to remove)
function BaseWidget:setTooltip(text)
    if text ~= nil then
        validate.require_type(text, "string", "tooltip text")
    end
    self.tooltip = text
end

--- Get tooltip text
---
--- @return string|nil Tooltip text
function BaseWidget:getTooltip()
    return self.tooltip
end

--- Add a child widget
--- For container widgets
---
--- @param child BaseWidget Child widget to add
function BaseWidget:addChild(child)
    validate.require_type(child, "table", "child")
    table.insert(self.children, child)
    child.parent = self
end

--- Remove a child widget
---
--- @param child BaseWidget Child widget to remove
--- @return boolean True if child was removed
function BaseWidget:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            return true
        end
    end
    return false
end

--- Remove all children
function BaseWidget:clearChildren()
    for _, child in ipairs(self.children) do
        child.parent = nil
    end
    self.children = {}
end

--- Get all children
---
--- @return table Array of child widgets
function BaseWidget:getChildren()
    return self.children
end

--- Update widget state
--- Override this in subclasses for custom update logic
---
--- @param dt number Delta time since last update
function BaseWidget:update(dt)
    -- Update children
    for _, child in ipairs(self.children) do
        if child.visible then
            child:update(dt)
        end
    end
end

--- Handle mouse press event
--- Override this in subclasses for custom interaction
---
--- @param x number Mouse X coordinate
--- @param y number Mouse Y coordinate
--- @param button number Mouse button (1=left, 2=right, 3=middle)
--- @return boolean True if event was handled
function BaseWidget:onMousePressed(x, y, button)
    -- Check children first (reverse order for proper layering)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.visible and child.enabled and child:onMousePressed(x, y, button) then
            return true
        end
    end
    
    -- Check if click is on this widget
    if self:contains(x, y) and self.enabled then
        return true  -- Event handled
    end
    
    return false  -- Event not handled
end

--- Handle mouse release event
--- Override this in subclasses for custom interaction
---
--- @param x number Mouse X coordinate
--- @param y number Mouse Y coordinate
--- @param button number Mouse button
--- @return boolean True if event was handled
function BaseWidget:onMouseReleased(x, y, button)
    -- Check children first
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.visible and child.enabled and child:onMouseReleased(x, y, button) then
            return true
        end
    end
    
    return false
end

--- Handle mouse move event
--- Override this in subclasses for custom hover effects
---
--- @param x number Mouse X coordinate
--- @param y number Mouse Y coordinate
--- @param dx number Change in X
--- @param dy number Change in Y
function BaseWidget:onMouseMoved(x, y, dx, dy)
    -- Update hover state
    local was_hovered = self.hovered
    self.hovered = self:contains(x, y)
    
    -- Update children
    for _, child in ipairs(self.children) do
        if child.visible then
            child:onMouseMoved(x, y, dx, dy)
        end
    end
end

--- Draw the widget
--- Override this in subclasses to implement actual rendering
--- Always call BaseWidget.draw(self) first to handle visibility
function BaseWidget:draw()
    if not self.visible then
        return
    end
    
    -- Draw children
    for _, child in ipairs(self.children) do
        if child.visible then
            child:draw()
        end
    end
end

--- Get debug information about the widget
---
--- @return table Debug information
function BaseWidget:getDebugInfo()
    return {
        class = self.class.name,
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height,
        visible = self.visible,
        enabled = self.enabled,
        hovered = self.hovered,
        focused = self.focused,
        children = #self.children
    }
end

return BaseWidget
