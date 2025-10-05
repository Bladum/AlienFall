--[[
widgets/core.lua
Core subsystem & Base widget


Core widget system providing foundational services for all UI components in the AlienFall
tactical strategy game. This module serves as the central hub for OpenXCOM-style interfaces,
ensuring consistent behavior across geoscape, battlescape, and base management screens.

PURPOSE:
- Provide foundational services for all widgets: configuration, theming, focus management,
  accessibility hooks, common helpers, and the `Base` widget class that others extend.
- Central hub for OpenXCOM-style UI, ensuring consistent behavior across all game screens.
- Manage global state and provide utilities for widget lifecycle and interaction.

PROVIDED APIs & RESPONSIBILITIES:
- core.config: Global runtime options (tooltip delay, keyboard navigation, debugging)
- core.theme: Centralized theme/colors/fonts used by all widgets
- core.focus: Focus management (register/unregister, setFocus, focusNext, focusPrevious)
- core.accessibility: Announcement queue and accessibility toggles for screen readers
- Helper functions: isInside, clamp, lerp, safeCall, deepCopy, etc.
- Base: Minimal widget class exposing lifecycle methods (update/draw/mouse/key events)

@see widgets.common.Base
@see widgets.common.theme
@see widgets.common.focus
]]

local core = {}

-- Global widget configuration
core.config = {
    debugMode = false,
    tooltipDelay = 0.8,
    animationSpeed = 1.0,
    defaultFont = nil, -- Will use love.graphics.getFont() if nil
    errorReporting = true,
    performanceMonitoring = false,
    enableKeyboardNavigation = true,
    enableAccessibility = true,
    tabOrderMode = "spatial" -- "spatial" or "declaration"
}

-- Focus management system
core.focus = {
    current = nil,
    previous = nil,
    focusableWidgets = {},
    tabIndex = 1,
    focusRingColor = { 0.2, 0.6, 1, 1 },
    focusRingWidth = 2
}

-- Accessibility system
core.accessibility = {
    screenReaderEnabled = true,
    highContrastMode = false,
    largeTextMode = false,
    announcements = {},
    lastAnnouncement = 0
}
--- Registers a widget as focusable for keyboard navigation.
---
---@param widget table The widget to register as focusable.
function core.registerFocusableWidget(widget)
    if widget and widget.focusable ~= false then
        table.insert(core.focus.focusableWidgets, widget)
        widget.focusIndex = #core.focus.focusableWidgets
    end
end

--- Unregisters a widget from the focusable list.
---
---@param widget table The widget to unregister from focus management.
function core.unregisterFocusableWidget(widget)
    for i, w in ipairs(core.focus.focusableWidgets) do
        if w == widget then
            table.remove(core.focus.focusableWidgets, i)
            -- Update focus indices
            for j = i, #core.focus.focusableWidgets do
                core.focus.focusableWidgets[j].focusIndex = j
            end
            break
        end
    end
    if core.focus.current == widget then
        core.focus.current = nil
    end
end

--- Sets focus to a specific widget.
---
---@param widget? table The widget to focus, or nil to clear focus.
function core.setFocus(widget)
    if core.focus.current and core.focus.current.onFocusLost then
        core.focus.current:onFocusLost()
    end

    core.focus.previous = core.focus.current
    core.focus.current = widget

    if widget and widget.onFocusGained then
        widget:onFocusGained()
    end

    -- Announce focus change for accessibility
    if core.config.enableAccessibility and widget and widget.getAccessibilityLabel then
        core.announce(widget:getAccessibilityLabel() .. " focused")
    end
end

--- Moves focus to the next focusable widget in the tab order.
function core.focusNext()
    if #core.focus.focusableWidgets == 0 then return end

    local currentIndex = 0
    if core.focus.current then
        for i, w in ipairs(core.focus.focusableWidgets) do
            if w == core.focus.current then
                currentIndex = i
                break
            end
        end
    end

    local nextIndex = currentIndex + 1
    if nextIndex > #core.focus.focusableWidgets then
        nextIndex = 1
    end

    core.setFocus(core.focus.focusableWidgets[nextIndex])
end

--- Moves focus to the previous focusable widget in the tab order.
function core.focusPrevious()
    if #core.focus.focusableWidgets == 0 then return end

    local currentIndex = 0
    if core.focus.current then
        for i, w in ipairs(core.focus.focusableWidgets) do
            if w == core.focus.current then
                currentIndex = i
                break
            end
        end
    end

    local prevIndex = currentIndex - 1
    if prevIndex < 1 then
        prevIndex = #core.focus.focusableWidgets
    end

    core.setFocus(core.focus.focusableWidgets[prevIndex])
end

--- Clears focus from all widgets.
function core.clearFocus()
    if core.focus.current and core.focus.current.onFocusLost then
        core.focus.current:onFocusLost()
    end
    core.focus.previous = core.focus.current
    core.focus.current = nil
end

-- Accessibility functions
--- Announces text for accessibility (screen reader support).
---
---@param text string The text to announce to screen readers.
function core.announce(text)
    if not core.config.enableAccessibility or not core.accessibility.screenReaderEnabled then
        return
    end

    table.insert(core.accessibility.announcements, {
        text = text,
        timestamp = love.timer.getTime()
    })

    -- Keep only recent announcements
    while #core.accessibility.announcements > 10 do
        table.remove(core.accessibility.announcements, 1)
    end

    print("Screen Reader: " .. text) -- In a real implementation, this would interface with screen reader APIs
end

--- Gets the appropriate color based on high contrast mode settings.
---
---@param normalColor table Normal color as {r, g, b, a} table.
---@param highContrastColor? table High contrast color as {r, g, b, a} table.
---@return table The appropriate color based on accessibility settings.
function core.getHighContrastColor(normalColor, highContrastColor)
    if core.accessibility.highContrastMode then
        return highContrastColor or { 1, 1, 1, 1 }
    end
    return normalColor
end

-- Theme
core.theme = {
    primary = { 0.7, 0.7, 0.7, 1 },
    primaryHover = { 0.8, 0.8, 0.8, 1 },
    primaryPressed = { 0.5, 0.5, 0.5, 1 },
    primaryDisabled = { 0.4, 0.4, 0.4, 1 },
    secondary = { 0.9, 0.9, 0.9, 1 },
    secondaryHover = { 0.95, 0.95, 0.95, 1 },
    accent = { 0.2, 0.8, 0.2, 1 },
    accentHover = { 0.3, 0.9, 0.3, 1 },
    text = { 0, 0, 0, 1 },
    textSecondary = { 0.3, 0.3, 0.3, 1 },
    textDisabled = { 0.6, 0.6, 0.6, 1 },
    textInverse = { 1, 1, 1, 1 },
    border = { 0, 0, 0, 1 },
    borderFocus = { 0.2, 0.6, 1, 1 },
    background = { 1, 1, 1, 1 },
    backgroundDark = { 0.1, 0.1, 0.1, 1 },
    error = { 1, 0.2, 0.2, 1 },
    warning = { 1, 0.8, 0.2, 1 },
    success = { 0.2, 0.8, 0.2, 1 },
    info = { 0.2, 0.6, 1, 1 },
    selection = { 0.3, 0.6, 1, 0.3 },
    tooltip = { 0.1, 0.1, 0.1, 0.9 }
}

-- Tooltip system (kept minimal; widgets call core.setTooltipWidget when hovered)
local tooltipSystem = { currentWidget = nil, timer = 0, x = 0, y = 0, text = "", visible = false }

-- Helpers

--- Checks if a point is inside a rectangle.
---
---@param x number The x coordinate of the point.
---@param y number The y coordinate of the point.
---@param rx number The x coordinate of the rectangle.
---@param ry number The y coordinate of the rectangle.
---@param rw number The width of the rectangle.
---@param rh number The height of the rectangle.
---@return boolean True if the point is inside the rectangle, false otherwise.
local function isInside(x, y, rx, ry, rw, rh)
    if type(x) ~= "number" or type(y) ~= "number" or
        type(rx) ~= "number" or type(ry) ~= "number" or
        type(rw) ~= "number" or type(rh) ~= "number" then
        return false
    end
    return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end
core.isInside = isInside

--- Clamps a value between min and max bounds.
---
---@param value number The value to clamp.
---@param min? number The minimum bound (default: -infinity).
---@param max? number The maximum bound (default: infinity).
---@return number? The clamped value, or nil if value is not a number.
local function clamp(value, min, max)
    if type(value) ~= "number" then return min end
    return math.max(min or -math.huge, math.min(max or math.huge, value))
end
core.clamp = clamp

--- Linear interpolation between two values.
---
---@param a number The starting value.
---@param b number The ending value.
---@param t number The interpolation factor (0-1).
---@return number The interpolated value.
local function lerp(a, b, t)
    if type(a) ~= "number" or type(b) ~= "number" or type(t) ~= "number" then
        return a
    end
    return a + (b - a) * clamp(t, 0, 1)
end
core.lerp = lerp

--- Safely calls a function with error handling.
---
---@param func function The function to call.
---@param context? string Context description for error reporting.
---@param ... any Arguments to pass to the function.
---@return boolean success Whether the call succeeded.
---@return any result The result of the function call, or error message on failure.
local function safeCall(func, context, ...)
    if type(func) ~= "function" then
        if core.config.errorReporting then
            print("Widget Warning: Attempted to call non-function", context or "unknown")
        end
        return false, "Not a function"
    end
    local success, result = pcall(func, ...)
    if not success and core.config.errorReporting then
        print("Widget Error in " .. (context or "unknown") .. ": " .. tostring(result))
        if core.config.debugMode then print(debug.traceback()) end
    end
    return success, result
end
core.safeCall = safeCall

-- Validators

--- Validates and clamps a number value.
---
---@param value any The value to validate.
---@param default number The default value if validation fails.
---@param min? number The minimum allowed value.
---@param max? number The maximum allowed value.
---@return number The validated and clamped number.
local function validateNumber(value, default, min, max)
    if type(value) ~= "number" then return default end
    local clamped = clamp(value, min, max)
    return clamped or default
end
core.validateNumber = validateNumber

--- Validates a string value.
---
---@param value any The value to validate.
---@param default string The default value if validation fails.
---@return string The validated string.
local function validateString(value, default)
    return type(value) == "string" and value or default
end
core.validateString = validateString

--- Validates a table value.
---
---@param value any The value to validate.
---@param default? table The default value if validation fails.
---@return table The validated table.
local function validateTable(value, default)
    return type(value) == "table" and value or default or {}
end
core.validateTable = validateTable

--- Validates a color table value.
---
---@param color any The color value to validate.
---@param default? table The default color if validation fails.
---@return table The validated color as {r, g, b, a} table.
local function validateColor(color, default)
    if type(color) ~= "table" or #color < 3 then
        return default or core.theme.primary
    end
    return { validateNumber(color[1], 1, 0, 1), validateNumber(color[2], 1, 0, 1), validateNumber(color[3], 1, 0, 1),
        validateNumber(color[4], 1, 0, 1) }
end
core.validateColor = validateColor

-- Tooltip functions

--- Updates tooltip state based on mouse position and time.
---
---@param dt number Delta time since last update.
---@param mouseX number Current mouse X position.
---@param mouseY number Current mouse Y position.
function core.updateTooltips(dt, mouseX, mouseY)
    if tooltipSystem.currentWidget and tooltipSystem.currentWidget.getTooltip and tooltipSystem.currentWidget:getTooltip() then
        tooltipSystem.timer = tooltipSystem.timer + dt
        if tooltipSystem.timer >= core.config.tooltipDelay then
            tooltipSystem.visible = true
            tooltipSystem.x = mouseX + 15
            tooltipSystem.y = mouseY - 25
            tooltipSystem.text = tooltipSystem.currentWidget:getTooltip()
        end
    else
        tooltipSystem.timer = 0
        tooltipSystem.visible = false
        tooltipSystem.currentWidget = nil
    end
end

--- Draws the current tooltip if visible.
function core.drawTooltips()
    if not tooltipSystem.visible or not tooltipSystem.text then return end
    local font = core.config.defaultFont or love.graphics.getFont()
    local width = font:getWidth(tooltipSystem.text) + 16
    local height = font:getHeight() + 12
    love.graphics.setColor(unpack(core.theme.tooltip))
    love.graphics.rectangle("fill", tooltipSystem.x, tooltipSystem.y, width, height)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", tooltipSystem.x, tooltipSystem.y, width, height)
    love.graphics.setColor(unpack(core.theme.textInverse))
    love.graphics.setFont(font)
    love.graphics.print(tooltipSystem.text, tooltipSystem.x + 8, tooltipSystem.y + 6)
end

--- Sets the widget that should display a tooltip.
---
---@param widget? table The widget to set as the tooltip source, or nil to clear.
function core.setTooltipWidget(widget)
    if tooltipSystem.currentWidget ~= widget then
        tooltipSystem.currentWidget = widget
        tooltipSystem.timer = 0
        tooltipSystem.visible = false
    end
end

-- Base widget
core.Base = {}
core.Base.__index = core.Base

--- Creates a new Base widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the widget
--- @param h number The height of the widget
--- @param options? table Optional configuration table
--- @return table A new Base widget instance
function core.Base:new(x, y, w, h, options)
    local obj = {
        x = x or 0,
        y = y or 0,
        w = w or 100,
        h = h or 30,
        visible = true,
        enabled = true,
        focusable = true,
        focused = false,
        hovered = false,
        pressed = false,
        tooltip = nil,
        accessibilityLabel = nil,
        accessibilityHint = nil,
        tabIndex = nil,
        parent = nil,
        children = {},
        id = nil,
        style = {},
        animations = {},
        dragData = nil,
        dropTarget = false
    }

    -- Apply options
    if options then
        for k, v in pairs(options) do
            obj[k] = v
        end
    end

    setmetatable(obj, self)

    -- Register for focus if focusable
    if obj.focusable then
        core.registerFocusableWidget(obj)
    end

    return obj
end

function core.Base:update(dt)
    -- Update animations
    for k, anim in pairs(self.animations) do
        if anim then
            anim.time = anim.time + dt
            if anim.time >= anim.duration then
                self[k] = anim.target
                self.animations[k] = nil
            else
                local t = anim.time / anim.duration
                self[k] = core.lerp(anim.start, anim.target, t)
            end
        end
    end
end

function core.Base:draw()
    -- Draw focus ring if focused
    if self.focused and core.config.enableKeyboardNavigation then
        love.graphics.setColor(unpack(core.focus.focusRingColor))
        love.graphics.setLineWidth(core.focus.focusRingWidth)
        love.graphics.rectangle("line", self.x - 2, self.y - 2, self.w + 4, self.h + 4)
        love.graphics.setLineWidth(1)
    end
end

function core.Base:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    if button == 1 and self:hitTest(x, y) then
        core.setFocus(self)
        self.pressed = true
        return true
    end
    return false
end

function core.Base:mousereleased(x, y, button)
    if button == 1 then
        self.pressed = false
    end
end

function core.Base:mousemoved(x, y, dx, dy)
    local wasHovered = self.hovered
    self.hovered = self.visible and self.enabled and self:hitTest(x, y)

    if self.hovered and not wasHovered and self.tooltip then
        core.setTooltipWidget(self)
    elseif not self.hovered and wasHovered then
        core.setTooltipWidget(nil)
    end
end

--- Handles key press events for the widget.
---
---@param key string The key that was pressed.
---@return boolean True if the event was handled, false otherwise.
function core.Base:keypressed(key)
    if not self.focused then return false end

    -- Handle Tab navigation
    if key == "tab" then
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            core.focusPrevious()
        else
            core.focusNext()
        end
        return true
    end

    return false
end

--- Handles text input events for the widget.
---
---@param text string The text that was input.
function core.Base:textinput(text)
    -- Default implementation - widgets can override
end

--- Tests if a point is within the widget's bounds.
---
---@param x number The x coordinate to test.
---@param y number The y coordinate to test.
---@return boolean True if the point is within the widget's bounds.
function core.Base:hitTest(x, y)
    if not self.visible or type(self.x) ~= "number" or type(self.y) ~= "number" or
        type(self.w) ~= "number" or type(self.h) ~= "number" then
        return false
    end
    return core.isInside(x, y, self.x, self.y, self.w, self.h)
end

--- Converts global coordinates to local widget coordinates.
---
---@param x number Global x coordinate.
---@param y number Global y coordinate.
---@return number localX Local x coordinate.
---@return number localY Local y coordinate.
function core.Base:toLocal(x, y)
    return x - (self.x or 0), y - (self.y or 0)
end

--- Converts local widget coordinates to global coordinates.
---
---@param x number Local x coordinate.
---@param y number Local y coordinate.
---@return number globalX Global x coordinate.
---@return number globalY Global y coordinate.
function core.Base:toGlobal(x, y)
    return x + (self.x or 0), y + (self.y or 0)
end

--- Gets the tooltip text for the widget.
---
---@return string? The tooltip text, or nil if no tooltip.
function core.Base:getTooltip()
    return self.tooltip
end

--- Gets the accessibility label for screen readers.
---
---@return string The accessibility label describing the widget.
function core.Base:getAccessibilityLabel()
    return self.accessibilityLabel or self.id or "Widget"
end

--- Gets the accessibility hint for screen readers.
---
---@return string? The accessibility hint with additional context.
function core.Base:getAccessibilityHint()
    return self.accessibilityHint
end

--- Called when the widget gains focus.
function core.Base:onFocusGained()
    self.focused = true
    if core.config.enableAccessibility then
        core.announce("Focused: " .. self:getAccessibilityLabel())
    end
end

--- Called when the widget loses focus.
function core.Base:onFocusLost()
    self.focused = false
end

--- Sets whether the widget is enabled.
---
---@param enabled boolean Whether the widget should be enabled.
function core.Base:setEnabled(enabled)
    self.enabled = enabled
    if not enabled and self.focused then
        core.clearFocus()
    end
end

--- Sets whether the widget is visible.
---
---@param visible boolean Whether the widget should be visible.
function core.Base:setVisible(visible)
    self.visible = visible
    if not visible and self.focused then
        core.clearFocus()
    end
end

--- Adds a child widget to this widget.
---
---@param child table The child widget to add.
function core.Base:addChild(child)
    child.parent = self
    table.insert(self.children, child)
end

--- Removes a child widget from this widget.
---
---@param child table The child widget to remove.
function core.Base:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            child.parent = nil
            table.remove(self.children, i)
            break
        end
    end
end

--- Starts an animation for a widget property.
---
---@param property string The property name to animate.
---@param target number The target value for the property.
---@param duration? number The animation duration in seconds (default: 0.3).
function core.Base:animate(property, target, duration)
    duration = duration or 0.3
    self.animations[property] = {
        start = self[property],
        target = target,
        time = 0,
        duration = duration
    }
end

-- Drag and drop methods

--- Starts a drag operation with the given data.
---
---@param data table The drag data containing information about what's being dragged.
function core.Base:startDrag(data)
    self.dragData = data
    if core.config.enableAccessibility then
        core.announce("Started dragging " .. (data.label or "item"))
    end
end

--- Ends the current drag operation.
function core.Base:endDrag()
    self.dragData = nil
end

--- Checks if the widget can accept the given drop data.
---
---@param data table The drop data to check.
---@return boolean True if the widget can accept the drop.
function core.Base:canDrop(data)
    return self.dropTarget
end

--- Handles a drop operation on this widget.
---
---@param data table The drop data.
---@return boolean True if the drop was successful.
function core.Base:drop(data)
    if self:canDrop(data) and self.onDrop then
        self:onDrop(data)
        if core.config.enableAccessibility then
            core.announce("Dropped " .. (data.label or "item") .. " on " .. self:getAccessibilityLabel())
        end
        return true
    end
    return false
end

-- Global input handling

--- Handles global key press events for widget navigation.
---
---@param key string The key that was pressed.
---@param scancode string The scancode of the key.
---@param isrepeat boolean Whether this is a key repeat event.
---@return boolean True if the event was handled.
function core.handleKeyPressed(key, scancode, isrepeat)
    if core.config.enableKeyboardNavigation then
        -- Global navigation keys
        if key == "tab" then
            if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                core.focusPrevious()
            else
                core.focusNext()
            end
            return true
        elseif key == "escape" then
            core.clearFocus()
            return true
        end

        -- Pass to focused widget
        if core.focus.current and core.focus.current.keypressed then
            return core.focus.current:keypressed(key, scancode, isrepeat)
        end
    end
    return false
end

--- Handles global text input events for focused widgets.
---
---@param text string The text that was input.
---@return boolean True if the event was handled.
function core.handleTextInput(text)
    if core.focus.current and core.focus.current.textinput then
        core.focus.current:textinput(text)
        return true
    end
    return false
end

--- Handles global mouse press events for widgets.
---
---@param x number The mouse x coordinate.
---@param y number The mouse y coordinate.
---@param button number The mouse button that was pressed.
---@param istouch boolean Whether this was triggered by a touch event.
---@param presses number The number of presses in a short time frame.
---@return boolean True if the event was handled.
function core.handleMousePressed(x, y, button, istouch, presses)
    -- Handle drag and drop
    if core.dragData then
        -- Find drop target
        for _, widget in ipairs(core.focus.focusableWidgets) do
            if widget:canDrop(core.dragData) and widget:hitTest(x, y) then
                widget:drop(core.dragData)
                core.dragData = nil
                return true
            end
        end
        -- No valid drop target, cancel drag
        if core.dragData.source and core.dragData.source.endDrag then
            core.dragData.source:endDrag()
        end
        core.dragData = nil
        return true
    end

    -- Normal mouse handling
    for _, widget in ipairs(core.focus.focusableWidgets) do
        if widget.visible and widget.enabled and widget:hitTest(x, y) then
            if widget:mousepressed(x, y, button, istouch, presses) then
                return true
            end
        end
    end
    return false
end

--- Handles global mouse release events for widgets.
---
---@param x number The mouse x coordinate.
---@param y number The mouse y coordinate.
---@param button number The mouse button that was released.
---@param istouch boolean Whether this was triggered by a touch event.
---@param presses number The number of presses in a short time frame.
function core.handleMouseReleased(x, y, button, istouch, presses)
    for _, widget in ipairs(core.focus.focusableWidgets) do
        if widget.visible and widget.enabled and widget.mousepressed then
            widget:mousereleased(x, y, button, istouch, presses)
        end
    end
end

--- Handles global mouse movement events for widgets.
---
---@param x number The current mouse x coordinate.
---@param y number The current mouse y coordinate.
---@param dx number The change in x coordinate since last movement.
---@param dy number The change in y coordinate since last movement.
---@param istouch boolean Whether this was triggered by a touch event.
function core.handleMouseMoved(x, y, dx, dy, istouch)
    for _, widget in ipairs(core.focus.focusableWidgets) do
        if widget.visible and widget.enabled and widget.mousemoved then
            widget:mousemoved(x, y, dx, dy, istouch)
        end
    end
end

-- Serialization/Deserialization

--- Serializes a widget to a data table for saving/loading.
---
---@param widget table The widget to serialize.
---@return table The serialized widget data.
function core.serializeWidget(widget)
    local data = {
        type = widget.__index == core.Base and "Base" or tostring(widget.__index),
        id = widget.id,
        x = widget.x,
        y = widget.y,
        w = widget.w,
        h = widget.h,
        visible = widget.visible,
        enabled = widget.enabled,
        focusable = widget.focusable,
        tooltip = widget.tooltip,
        accessibilityLabel = widget.accessibilityLabel,
        accessibilityHint = widget.accessibilityHint,
        style = widget.style,
        -- Widget-specific data
        data = {}
    }

    -- Add widget-specific serialization
    if widget.serialize then
        data.data = widget:serialize()
    end

    return data
end

--- Deserializes a widget from saved data.
---
---@param data table The serialized widget data.
---@return table? The deserialized widget, or nil if deserialization failed.
function core.deserializeWidget(data)
    local widgetClass = data.type == "Base" and core.Base or _G[data.type]
    if not widgetClass then
        print("Warning: Unknown widget type " .. data.type)
        return nil
    end

    local widget = widgetClass:new(data.x, data.y, data.w, data.h, {
        id = data.id,
        visible = data.visible,
        enabled = data.enabled,
        focusable = data.focusable,
        tooltip = data.tooltip,
        accessibilityLabel = data.accessibilityLabel,
        accessibilityHint = data.accessibilityHint,
        style = data.style
    })

    -- Add widget-specific deserialization
    if widget.deserialize and data.data then
        widget:deserialize(data.data)
    end

    return widget
end

-- Layout managers
core.layouts = {}

--- Arranges widgets in a vertical layout.
---
---@param x number The starting x coordinate.
---@param y number The starting y coordinate.
---@param widgets table Array of widgets to arrange.
---@param spacing? number Spacing between widgets (default: 5).
function core.layouts.vertical(x, y, widgets, spacing)
    spacing = spacing or 5
    local currentY = y
    for _, widget in ipairs(widgets) do
        widget.x = x
        widget.y = currentY
        currentY = currentY + widget.h + spacing
    end
end

--- Arranges widgets in a horizontal layout.
---
---@param x number The starting x coordinate.
---@param y number The starting y coordinate.
---@param widgets table Array of widgets to arrange.
---@param spacing? number Spacing between widgets (default: 5).
function core.layouts.horizontal(x, y, widgets, spacing)
    spacing = spacing or 5
    local currentX = x
    for _, widget in ipairs(widgets) do
        widget.x = currentX
        widget.y = y
        currentX = currentX + widget.w + spacing
    end
end

--- Arranges widgets in a grid layout.
---
---@param x number The starting x coordinate.
---@param y number The starting y coordinate.
---@param widgets table Array of widgets to arrange.
---@param cols number Number of columns in the grid.
---@param spacing? number Spacing between widgets (default: 5).
function core.layouts.grid(x, y, widgets, cols, spacing)
    spacing = spacing or 5
    local col = 0
    local row = 0
    for _, widget in ipairs(widgets) do
        widget.x = x + col * (widget.w + spacing)
        widget.y = y + row * (widget.h + spacing)
        col = col + 1
        if col >= cols then
            col = 0
            row = row + 1
        end
    end
end

--- Centers a widget within a container.
---
---@param containerX number The container's x coordinate.
---@param containerY number The container's y coordinate.
---@param containerW number The container's width.
---@param containerH number The container's height.
---@param widget table The widget to center.
function core.layouts.center(containerX, containerY, containerW, containerH, widget)
    widget.x = containerX + (containerW - widget.w) / 2
    widget.y = containerY + (containerH - widget.h) / 2
end

-- Export core
return core
