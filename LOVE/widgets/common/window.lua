--[[
widgets/window.lua
Window widget (movable, resizable floating container)


Advanced window widget providing movable, resizable floating containers with title bars,
window controls, and modal functionality for complex tactical strategy game interfaces.
Essential for dialogs, tool panels, and floating UI elements in OpenXCOM-style games.

PURPOSE:
- Provide framed, focusable containers for complex UI content
- Support window management operations (move, resize, minimize, maximize, close)
- Enable modal dialogs and docking functionality
- Manage child widget layout within window content area
- Core component for floating panels and dialog systems

KEY FEATURES:
- Movable windows with draggable title bar
- Resizable with corner and edge grips
- Window controls: close, minimize, maximize
- Modal dialog support with input blocking
- Docking system with snap zones
- Child widget management and layout
- State management (normal, minimized, maximized, docked)
- Animation support for state transitions
- Visual feedback for interactions
- Accessibility support with keyboard navigation

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.panel
@see widgets.common.dialog
@see widgets.common.windowmanager
]]
local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Container = require("widgets.common.container")

--- @class Window
local Window = {}
Window.__index = Window
setmetatable(Window, { __index = Container })

--- Creates a new Window widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the window
--- @param h number The height of the window
--- @param options table Optional configuration table
--- @return Window A new window widget instance
function Window:new(x, y, w, h, options)
    local obj = Container:new(x, y, w, h, options)

    -- Window properties
    obj.title = (options and options.title) or "Window"
    obj.resizable = (options and options.resizable) ~= false
    obj.closable = (options and options.closable) ~= false
    obj.minimizable = (options and options.minimizable) ~= false
    obj.maximizable = (options and options.maximizable) ~= false
    obj.dockable = (options and options.dockable) or false

    -- State management
    obj.windowState = "normal" -- normal, minimized, maximized, docked
    obj.previousState = { x = x, y = y, w = w, h = h }
    obj.isModal = (options and options.modal) or false

    -- Interaction states
    obj.dragging = false
    obj.resizing = false
    obj.resizeMode = "none" -- none, n, s, e, w, ne, nw, se, sw
    obj.offsetX = 0
    obj.offsetY = 0
    obj.minWidth = (options and options.minWidth) or 200
    obj.minHeight = (options and options.minHeight) or 150
    obj.maxWidth = (options and options.maxWidth) or love.graphics.getWidth()
    obj.maxHeight = (options and options.maxHeight) or love.graphics.getHeight()

    -- Visual properties
    obj.titleBarHeight = 30
    obj.borderWidth = 2
    obj.resizeGripSize = 8
    obj.shadowOffset = 4
    obj.cornerRadius = 6

    -- Docking
    obj.dockZone = "none" -- none, left, right, top, bottom, center
    obj.dockPosition = { x = 0, y = 0, w = 0, h = 0 }
    obj.snapDistance = 20

    -- Animation
    obj.animateStateChanges = (options and options.animateStateChanges) ~= false
    obj.animationDuration = 0.3

    -- Layout (children managed by Container)
    obj.contentX = obj.x + obj.borderWidth
    obj.contentY = obj.y + obj.titleBarHeight
    obj.contentW = obj.w - obj.borderWidth * 2
    obj.contentH = obj.h - obj.titleBarHeight - obj.borderWidth

    -- Callbacks
    obj.onClose = options and options.onClose
    obj.onMinimize = options and options.onMinimize
    obj.onMaximize = options and options.onMaximize
    obj.onResize = options and options.onResize
    obj.onMove = options and options.onMove
    obj.onDock = options and options.onDock
    obj.onStateChange = options and options.onStateChange

    -- Visual feedback
    obj.closeButtonHover = false
    obj.minimizeButtonHover = false
    obj.maximizeButtonHover = false
    obj.titleBarHover = false

    setmetatable(obj, self)
    obj:_updateLayout()
    return obj
end

--- Adds a child widget to the window
--- @param child table The child widget to add
function Window:add(child)
    table.insert(self.children, child)
    self:_updateChildPositions()
end

--- Removes a child widget from the window
--- @param child table The child widget to remove
function Window:remove(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            break
        end
    end
    self:_updateChildPositions()
end

function Window:_updateLayout()
    self.contentX = self.x + self.borderWidth
    self.contentY = self.y + self.titleBarHeight
    self.contentW = self.w - self.borderWidth * 2
    self.contentH = self.h - self.titleBarHeight - self.borderWidth
    self:_updateChildPositions()
end

function Window:_updateChildPositions()
    -- Update child positions relative to content area
    for _, child in ipairs(self.children) do
        if child.updatePosition then
            child:updatePosition(self.contentX, self.contentY, self.contentW, self.contentH)
        end
    end
end

--- Updates the window and its child widgets
--- @param dt number The time delta since the last update
function Window:update(dt)
    Container.update(self, dt)

    -- Check for docking zones during drag
    if self.dragging and self.dockable then
        self:_updateDockZone()
    end
end

--- Draws the window and its contents
function Window:draw()
    if self.windowState == "minimized" then
        return -- Don't draw minimized windows
    end

    -- Draw shadow
    if self.windowState ~= "maximized" then
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill",
            self.x + self.shadowOffset,
            self.y + self.shadowOffset,
            self.w, self.h,
            self.cornerRadius)
    end

    -- Draw window background
    love.graphics.setColor(table.unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius)

    -- Draw border
    love.graphics.setColor(table.unpack(self.focused and core.theme.focusBorder or core.theme.border))
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.cornerRadius)

    -- Draw title bar
    self:_drawTitleBar()

    -- Draw content area
    self:_drawContent()

    -- Draw resize grips
    if self.resizable and self.windowState == "normal" then
        self:_drawResizeGrips()
    end

    -- Draw docking preview
    if self.dragging and self.dockable and self.dockZone ~= "none" then
        self:_drawDockPreview()
    end

    love.graphics.setLineWidth(1)
end

function Window:_drawTitleBar()
    local titleBarY = self.y
    local titleBarH = self.titleBarHeight

    -- Title bar background
    local titleColor = self.focused and core.theme.primaryDark or core.theme.backgroundDark
    love.graphics.setColor(table.unpack(titleColor))
    love.graphics.rectangle("fill", self.x, titleBarY, self.w, titleBarH, self.cornerRadius, self.cornerRadius, 0, 0)

    -- Title text
    love.graphics.setColor(table.unpack(core.theme.text))
    love.graphics.setFont(core.theme.font)
    local titleY = titleBarY + (titleBarH - core.theme.font:getHeight()) / 2
    love.graphics.print(self.title, self.x + 10, titleY)

    -- Window controls
    self:_drawWindowControls()
end

function Window:_drawWindowControls()
    local buttonSize = 16
    local buttonSpacing = 4
    local buttonY = self.y + (self.titleBarHeight - buttonSize) / 2
    local buttonX = self.x + self.w - buttonSize - 10

    -- Close button
    if self.closable then
        local closeColor = self.closeButtonHover and { 1, 0.3, 0.3 } or core.theme.textLight
        love.graphics.setColor(table.unpack(closeColor))
        love.graphics.rectangle("fill", buttonX, buttonY, buttonSize, buttonSize, 2)

        love.graphics.setColor(1, 1, 1)
        love.graphics.line(
            buttonX + 4, buttonY + 4,
            buttonX + buttonSize - 4, buttonY + buttonSize - 4
        )
        love.graphics.line(
            buttonX + buttonSize - 4, buttonY + 4,
            buttonX + 4, buttonY + buttonSize - 4
        )

        buttonX = buttonX - buttonSize - buttonSpacing
    end

    -- Maximize button
    if self.maximizable then
        local maxColor = self.maximizeButtonHover and core.theme.primary or core.theme.textLight
        love.graphics.setColor(unpack(maxColor))
        love.graphics.rectangle("fill", buttonX, buttonY, buttonSize, buttonSize, 2)

        love.graphics.setColor(1, 1, 1)
        if self.windowState == "maximized" then
            -- Restore icon
            love.graphics.rectangle("line", buttonX + 3, buttonY + 5, buttonSize - 8, buttonSize - 10)
            love.graphics.rectangle("line", buttonX + 5, buttonY + 3, buttonSize - 8, buttonSize - 10)
        else
            -- Maximize icon
            love.graphics.rectangle("line", buttonX + 4, buttonY + 4, buttonSize - 8, buttonSize - 8)
        end

        buttonX = buttonX - buttonSize - buttonSpacing
    end

    -- Minimize button
    if self.minimizable then
        local minColor = self.minimizeButtonHover and core.theme.primary or core.theme.textLight
        love.graphics.setColor(unpack(minColor))
        love.graphics.rectangle("fill", buttonX, buttonY, buttonSize, buttonSize, 2)

        love.graphics.setColor(1, 1, 1)
        love.graphics.line(
            buttonX + 4, buttonY + buttonSize - 4,
            buttonX + buttonSize - 4, buttonY + buttonSize - 4
        )
    end
end

function Window:_drawContent()
    -- Clip content to content area
    love.graphics.push()
    love.graphics.intersectScissor(self.contentX, self.contentY, self.contentW, self.contentH)
    -- Draw children via Container helper
    self:drawChildren()

    love.graphics.pop()
end

function Window:_drawResizeGrips()
    love.graphics.setColor(table.unpack(core.theme.border))
    local gripSize = self.resizeGripSize

    -- Corner grips (more visible)
    local corners = {
        { self.x + self.w - gripSize, self.y + self.h - gripSize }, -- SE
        { self.x,                     self.y + self.h - gripSize }, -- SW
        { self.x + self.w - gripSize, self.y },                     -- NE
        { self.x,                     self.y }                      -- NW
    }

    for _, corner in ipairs(corners) do
        love.graphics.rectangle("fill", corner[1], corner[2], gripSize, gripSize)
    end
end

function Window:_drawDockPreview()
    local preview = self:_getDockPreview()
    if preview then
        love.graphics.setColor(0.2, 0.6, 1, 0.3)
        love.graphics.rectangle("fill", preview.x, preview.y, preview.w, preview.h)
        love.graphics.setColor(0.2, 0.6, 1, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", preview.x, preview.y, preview.w, preview.h)
        love.graphics.setLineWidth(1)
    end
end

--- Handles mouse press events for the window
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function Window:mousepressed(x, y, button)
    if self.windowState == "minimized" then return false end
    if button ~= 1 then return false end

    core.setFocus(self)

    -- Check window control buttons
    if self:_checkControlButtons(x, y) then
        return true
    end

    -- Check resize grips
    if self.resizable and self.windowState == "normal" then
        local resizeMode = self:_getResizeMode(x, y)
        if resizeMode ~= "none" then
            self.resizing = true
            self.resizeMode = resizeMode
            self.offsetX = x - self.x
            self.offsetY = y - self.y
            return true
        end
    end

    -- Check title bar for dragging
    if core.isInside(x, y, self.x, self.y, self.w, self.titleBarHeight) then
        if self.windowState ~= "maximized" then
            self.dragging = true
            self.offsetX = x - self.x
            self.offsetY = y - self.y
        end
        return true
    end

    -- Forward to children (relative coordinates)
    local handled = self:forwardMouseEvent("mousepressed", x - self.contentX, y - self.contentY, button)
    if handled then return true end

    return core.isInside(x, y, self.x, self.y, self.w, self.h)
end

--- Handles mouse release events for the window
--- @param x number The x-coordinate of the mouse release
--- @param y number The y-coordinate of the mouse release
--- @param button number The mouse button that was released
function Window:mousereleased(x, y, button)
    if button == 1 then
        -- Handle docking
        if self.dragging and self.dockable and self.dockZone ~= "none" then
            self:_applyDocking()
        end

        self.dragging = false
        self.resizing = false
        self.resizeMode = "none"
    end

    -- Forward to children
    self:forwardMouseEvent("mousereleased", x - self.contentX, y - self.contentY, button)
end

--- Handles mouse movement events for the window
--- @param x number The current x-coordinate of the mouse
--- @param y number The current y-coordinate of the mouse
--- @param dx number The change in x-coordinate since the last mouse movement
--- @param dy number The change in y-coordinate since the last mouse movement
function Window:mousemoved(x, y, dx, dy)
    -- Update button hover states
    self:_updateButtonHover(x, y)

    if self.dragging then
        local newX = x - self.offsetX
        local newY = y - self.offsetY

        -- Constrain to screen bounds
        newX = math.max(0, math.min(love.graphics.getWidth() - self.w, newX))
        newY = math.max(0, math.min(love.graphics.getHeight() - self.titleBarHeight, newY))

        self.x = newX
        self.y = newY
        self:_updateLayout()

        if self.onMove then
            self.onMove(self.x, self.y, self)
        end
    elseif self.resizing then
        self:_handleResize(x, y)
    end

    -- Forward to children
    self:forwardMouseEvent("mousemoved", x - self.contentX, y - self.contentY, dx, dy)
end

-- Helper methods
function Window:_checkControlButtons(x, y)
    local buttonSize = 16
    local buttonSpacing = 4
    local buttonY = self.y + (self.titleBarHeight - buttonSize) / 2
    local buttonX = self.x + self.w - buttonSize - 10

    -- Close button
    if self.closable and core.isInside(x, y, buttonX, buttonY, buttonSize, buttonSize) then
        self:close()
        return true
    end

    if self.closable then
        buttonX = buttonX - buttonSize - buttonSpacing
    end

    -- Maximize button
    if self.maximizable and core.isInside(x, y, buttonX, buttonY, buttonSize, buttonSize) then
        if self.windowState == "maximized" then
            self:restore()
        else
            self:maximize()
        end
        return true
    end

    if self.maximizable then
        buttonX = buttonX - buttonSize - buttonSpacing
    end

    -- Minimize button
    if self.minimizable and core.isInside(x, y, buttonX, buttonY, buttonSize, buttonSize) then
        self:minimize()
        return true
    end

    return false
end

function Window:_updateButtonHover(x, y)
    local buttonSize = 16
    local buttonSpacing = 4
    local buttonY = self.y + (self.titleBarHeight - buttonSize) / 2
    local buttonX = self.x + self.w - buttonSize - 10

    -- Close button
    self.closeButtonHover = self.closable and core.isInside(x, y, buttonX, buttonY, buttonSize, buttonSize)

    if self.closable then
        buttonX = buttonX - buttonSize - buttonSpacing
    end

    -- Maximize button
    self.maximizeButtonHover = self.maximizable and core.isInside(x, y, buttonX, buttonY, buttonSize, buttonSize)

    if self.maximizable then
        buttonX = buttonX - buttonSize - buttonSpacing
    end

    -- Minimize button
    self.minimizeButtonHover = self.minimizable and core.isInside(x, y, buttonX, buttonY, buttonSize, buttonSize)

    -- Title bar hover
    self.titleBarHover = core.isInside(x, y, self.x, self.y, self.w, self.titleBarHeight)
end

function Window:_getResizeMode(x, y)
    local grip = self.resizeGripSize
    local modes = {
        { self.x + self.w - grip, self.y + self.h - grip, grip,              grip,              "se" },
        { self.x,                 self.y + self.h - grip, grip,              grip,              "sw" },
        { self.x + self.w - grip, self.y,                 grip,              grip,              "ne" },
        { self.x,                 self.y,                 grip,              grip,              "nw" },
        { self.x + grip,          self.y + self.h - 2,    self.w - grip * 2, 2,                 "s" },
        { self.x + grip,          self.y,                 self.w - grip * 2, 2,                 "n" },
        { self.x + self.w - 2,    self.y + grip,          2,                 self.h - grip * 2, "e" },
        { self.x,                 self.y + grip,          2,                 self.h - grip * 2, "w" }
    }

    for _, mode in ipairs(modes) do
        if core.isInside(x, y, mode[1], mode[2], mode[3], mode[4]) then
            return mode[5]
        end
    end

    return "none"
end

function Window:_handleResize(x, y)
    local newX, newY, newW, newH = self.x, self.y, self.w, self.h

    if string.find(self.resizeMode, "e") then
        newW = math.max(self.minWidth, math.min(self.maxWidth, x - self.x))
    end
    if string.find(self.resizeMode, "w") then
        local rightEdge = self.x + self.w
        newX = math.max(0, x)
        newW = math.max(self.minWidth, rightEdge - newX)
    end
    if string.find(self.resizeMode, "s") then
        newH = math.max(self.minHeight, math.min(self.maxHeight, y - self.y))
    end
    if string.find(self.resizeMode, "n") then
        local bottomEdge = self.y + self.h
        newY = math.max(0, y)
        newH = math.max(self.minHeight, bottomEdge - newY)
    end

    self.x, self.y, self.w, self.h = newX, newY, newW, newH
    self:_updateLayout()

    if self.onResize then
        self.onResize(self.w, self.h, self)
    end
end

function Window:_updateDockZone()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local snap = self.snapDistance

    local centerX = self.x + self.w / 2
    local centerY = self.y + self.h / 2

    -- Reset dock zone
    self.dockZone = "none"

    -- Check screen edges
    if self.x <= snap then
        self.dockZone = "left"
    elseif self.x + self.w >= screenW - snap then
        self.dockZone = "right"
    elseif self.y <= snap then
        self.dockZone = "top"
    elseif self.y + self.h >= screenH - snap then
        self.dockZone = "bottom"
    elseif centerX > screenW / 4 and centerX < 3 * screenW / 4 and
        centerY > screenH / 4 and centerY < 3 * screenH / 4 then
        self.dockZone = "center"
    end
end

function Window:_getDockPreview()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if self.dockZone == "left" then
        return { x = 0, y = 0, w = screenW / 2, h = screenH }
    elseif self.dockZone == "right" then
        return { x = screenW / 2, y = 0, w = screenW / 2, h = screenH }
    elseif self.dockZone == "top" then
        return { x = 0, y = 0, w = screenW, h = screenH / 2 }
    elseif self.dockZone == "bottom" then
        return { x = 0, y = screenH / 2, w = screenW, h = screenH / 2 }
    elseif self.dockZone == "center" then
        return { x = 0, y = 0, w = screenW, h = screenH }
    end

    return nil
end

function Window:_applyDocking()
    local preview = self:_getDockPreview()
    if not preview then return end

    self:_saveState()

    if self.animateStateChanges then
        Animation.animateWidget(self, "x", preview.x, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "y", preview.y, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "w", preview.w, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "h", preview.h, self.animationDuration, Animation.types.EASE_OUT, function()
            self:_updateLayout()
        end)
    else
        self.x, self.y, self.w, self.h = preview.x, preview.y, preview.w, preview.h
        self:_updateLayout()
    end

    self.windowState = "docked"
    self.dockPosition = { x = preview.x, y = preview.y, w = preview.w, h = preview.h }

    if self.onDock then
        self.onDock(self.dockZone, self)
    end

    if self.onStateChange then
        self.onStateChange("docked", self)
    end
end

function Window:_saveState()
    if self.windowState == "normal" then
        self.previousState = { x = self.x, y = self.y, w = self.w, h = self.h }
    end
end

-- Public state management methods
function Window:minimize()
    if not self.minimizable or self.windowState == "minimized" then return end

    self:_saveState()
    self.windowState = "minimized"

    if self.onMinimize then
        self.onMinimize(self)
    end

    if self.onStateChange then
        self.onStateChange("minimized", self)
    end
end

function Window:maximize()
    if not self.maximizable or self.windowState == "maximized" then return end

    self:_saveState()

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if self.animateStateChanges then
        Animation.animateWidget(self, "x", 0, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "y", 0, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "w", screenW, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "h", screenH, self.animationDuration, Animation.types.EASE_OUT, function()
            self:_updateLayout()
        end)
    else
        self.x, self.y, self.w, self.h = 0, 0, screenW, screenH
        self:_updateLayout()
    end

    self.windowState = "maximized"

    if self.onMaximize then
        self.onMaximize(self)
    end

    if self.onStateChange then
        self.onStateChange("maximized", self)
    end
end

function Window:restore()
    if self.windowState == "normal" then return end

    local targetX = self.previousState.x
    local targetY = self.previousState.y
    local targetW = self.previousState.w
    local targetH = self.previousState.h

    if self.animateStateChanges then
        Animation.animateWidget(self, "x", targetX, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "y", targetY, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "w", targetW, self.animationDuration, Animation.types.EASE_OUT)
        Animation.animateWidget(self, "h", targetH, self.animationDuration, Animation.types.EASE_OUT, function()
            self:_updateLayout()
        end)
    else
        self.x, self.y, self.w, self.h = targetX, targetY, targetW, targetH
        self:_updateLayout()
    end

    self.windowState = "normal"

    if self.onStateChange then
        self.onStateChange("normal", self)
    end
end

function Window:close()
    if not self.closable then return end

    if self.onClose then
        if self.onClose(self) == false then
            return -- Allow canceling close
        end
    end

    -- Remove from parent or window manager
    if self.parent and self.parent.remove then
        self.parent:remove(self)
    end

    if self.onStateChange then
        self.onStateChange("closed", self)
    end
end

-- Public API methods
function Window:setTitle(title)
    self.title = title or ""
end

function Window:getTitle()
    return self.title
end

function Window:setState(state)
    if state == "minimized" then
        self:minimize()
    elseif state == "maximized" then
        self:maximize()
    elseif state == "normal" then
        self:restore()
    end
end

function Window:getState()
    return self.windowState
end

function Window:setResizable(resizable)
    self.resizable = resizable
end

function Window:setModal(modal)
    self.isModal = modal
end

function Window:bringToFront()
    if self.parent and self.parent.bringToFront then
        self.parent:bringToFront(self)
    end
end

-- Serialization
function Window:serialize()
    return {
        title = self.title,
        x = self.x,
        y = self.y,
        w = self.w,
        h = self.h,
        windowState = self.windowState,
        previousState = self.previousState,
        resizable = self.resizable,
        closable = self.closable,
        minimizable = self.minimizable,
        maximizable = self.maximizable,
        dockable = self.dockable,
        isModal = self.isModal,
        dockPosition = self.dockPosition
    }
end

function Window:deserialize(data)
    self.title = data.title or "Window"
    self.x = data.x or 100
    self.y = data.y or 100
    self.w = data.w or 300
    self.h = data.h or 200
    self.windowState = data.windowState or "normal"
    self.previousState = data.previousState or { x = self.x, y = self.y, w = self.w, h = self.h }
    self.resizable = data.resizable ~= false
    self.closable = data.closable ~= false
    self.minimizable = data.minimizable ~= false
    self.maximizable = data.maximizable ~= false
    self.dockable = data.dockable or false
    self.isModal = data.isModal or false
    self.dockPosition = data.dockPosition or { x = 0, y = 0, w = 0, h = 0 }

    self:_updateLayout()
end

return Window
