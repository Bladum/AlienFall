--[[
widgets/dialog.lua
Dialog widget (modal and non-modal interaction windows)


Versatile dialog widget providing modal and non-modal interaction windows with customizable
content, button layouts, and accessibility features for tactical strategy game interfaces.
Essential for mission briefings, confirmations, settings panels, and user interactions
in OpenXCOM-style games.

PURPOSE:
- Provide flexible dialog windows for user interactions
- Support both modal (blocking) and non-modal operation
- Enable complex content layouts with multiple widgets
- Offer customizable button configurations and actions
- Core component for game UI interactions and information display

KEY FEATURES:
- Modal and non-modal operation modes
- Draggable title bar with visual feedback
- Optional resizable functionality
- Customizable button layouts and actions
- Content area supporting any widget type
- Automatic screen centering and positioning
- Focus management and keyboard navigation
- Accessibility support with screen reader announcements
- Visual styling with modal backdrop

@see widgets.common.core.Base
@see widgets.common.button
@see widgets.common.label
@see widgets.common.panel
@see widgets.common.window
]]

local core = require("widgets.core")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")
local Dialog = {}
Dialog.__index = Dialog

function Dialog:new(title, content, options)
    options = options or {}
    local width = options.width or 400
    local height = options.height or 300
    local x = options.x or (love.graphics.getWidth() - width) / 2
    local y = options.y or (love.graphics.getHeight() - height) / 2

    local obj = core.Base:new(x, y, width, height, options)

    obj.title = title or "Dialog"
    obj.content = content
    obj.modal = options.modal ~= false
    obj.draggable = options.draggable ~= false
    obj.resizable = options.resizable or false
    obj.buttons = {}

    -- Title bar
    obj.titleBarHeight = 30
    obj.contentY = y + obj.titleBarHeight + 5
    obj.contentHeight = height - obj.titleBarHeight - 40 - 5 -- 40 for button bar

    -- Dragging state
    obj.dragging = false
    obj.dragOffsetX = 0
    obj.dragOffsetY = 0

    obj.accessibilityLabel = obj.accessibilityLabel or title or "Dialog"
    obj.accessibilityHint = obj.accessibilityHint or "Dialog window with content and buttons"

    -- Position content
    if obj.content then
        obj.content.x = x + 10
        obj.content.y = obj.contentY
        obj.content.w = width - 20
        obj.content.h = obj.contentHeight
        obj:addChild(obj.content)
    end

    setmetatable(obj, self)
    return obj
end

--- Adds a button to the dialog
--- @param text string The button text
--- @param callback function The function to call when the button is clicked
--- @param options table Optional configuration table for the button
--- @return Button The created button widget
function Dialog:addButton(text, callback, options)
    options = options or {}
    local buttonWidth = 80
    local buttonHeight = 30
    local buttonSpacing = 10
    local totalButtonsWidth = (#self.buttons + 1) * buttonWidth + (#self.buttons * buttonSpacing)
    local startX = self.x + (self.w - totalButtonsWidth) / 2

    local buttonX = startX + #self.buttons * (buttonWidth + buttonSpacing)
    local buttonY = self.y + self.h - buttonHeight - 10

    local button = Button:new(buttonX, buttonY, buttonWidth, buttonHeight, text, function()
        if callback then
            callback(self)
        end
        if options.closeOnClick ~= false then
            self:close()
        end
    end, options)

    table.insert(self.buttons, button)
    self:addChild(button)

    return button
end

--- Shows the dialog
function Dialog:show()
    self.visible = true
    if core.config.enableAccessibility then
        core.announce("Dialog opened: " .. self.title)
    end
end

--- Closes the dialog
function Dialog:close()
    self.visible = false
    if core.config.enableAccessibility then
        core.announce("Dialog closed: " .. self.title)
    end
end

--- Updates the dialog and all its children
--- @param dt number Time delta since last update
function Dialog:update(dt)
    if not self.visible then return end

    core.Base.update(self, dt)

    -- Update all children
    for _, child in ipairs(self.children) do
        if child.update then
            child:update(dt)
        end
    end
end

--- Draws the dialog and all its visual elements
function Dialog:draw()
    if not self.visible then return end

    core.Base.draw(self)

    -- Draw modal backdrop
    if self.modal then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end

    -- Draw dialog background
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Draw title bar
    love.graphics.setColor(unpack(core.theme.secondary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.titleBarHeight)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.titleBarHeight)

    -- Draw title
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf(self.title, self.x + 10,
        self.y + (self.titleBarHeight - love.graphics.getFont():getHeight()) / 2, self.w - 20, "left")

    -- Draw content area
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.contentY - 2, self.w, self.contentHeight + 2)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.contentY - 2, self.w, self.contentHeight + 2)

    -- Draw all children
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw()
        end
    end
end

--- Handles mouse press events
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function Dialog:mousepressed(x, y, button)
    if not self.visible then return false end

    -- Handle title bar dragging
    if self.draggable and button == 1 and core.isInside(x, y, self.x, self.y, self.w, self.titleBarHeight) then
        self.dragging = true
        self.dragOffsetX = x - self.x
        self.dragOffsetY = y - self.y
        return true
    end

    -- Handle children
    for _, child in ipairs(self.children) do
        if child:mousepressed(x, y, button) then
            return true
        end
    end

    -- Close dialog if clicking outside (for non-modal)
    if not self.modal and not core.isInside(x, y, self.x, self.y, self.w, self.h) then
        self:close()
        return true
    end

    return false
end

--- Handles mouse movement events
--- @param x number The current x-coordinate of the mouse
--- @param y number The current y-coordinate of the mouse
--- @param dx number The change in x-coordinate since last movement
--- @param dy number The change in y-coordinate since last movement
function Dialog:mousemoved(x, y, dx, dy)
    if not self.visible then return end

    -- Handle dragging
    if self.dragging then
        self.x = x - self.dragOffsetX
        self.y = y - self.dragOffsetY
        -- Update content position
        if self.content then
            self.content.x = self.x + 10
            self.content.y = self.contentY
        end
        -- Update button positions
        for i, button in ipairs(self.buttons) do
            button.y = self.y + self.h - 30 - 10
        end
        return
    end

    -- Handle children
    for _, child in ipairs(self.children) do
        if child.mousemoved then
            child:mousemoved(x, y, dx, dy)
        end
    end
end

--- Handles mouse release events
--- @param x number The x-coordinate of the mouse release
--- @param y number The y-coordinate of the mouse release
--- @param button number The mouse button that was released
function Dialog:mousereleased(x, y, button)
    if not self.visible then return end

    self.dragging = false

    for _, child in ipairs(self.children) do
        if child.mousereleased then
            child:mousereleased(x, y, button)
        end
    end
end

--- Handles keyboard input for the dialog
--- @param key string The key that was pressed
--- @return boolean True if the event was handled, false otherwise
function Dialog:keypressed(key)
    if not self.visible then return false end

    if key == "escape" then
        self:close()
        return true
    end

    -- Handle children
    for _, child in ipairs(self.children) do
        if child.keypressed and child:keypressed(key) then
            return true
        end
    end

    return false
end

--- Serializes the dialog state for saving
--- @return table The serialized dialog data
function Dialog:serialize()
    return {
        title = self.title,
        modal = self.modal,
        draggable = self.draggable,
        resizable = self.resizable,
        titleBarHeight = self.titleBarHeight,
        -- Note: content and buttons would need separate serialization
        contentType = self.content and self.content.__index or nil,
        buttonCount = #self.buttons
    }
end

--- Deserializes dialog state from saved data
--- @param data table The serialized dialog data to restore
function Dialog:deserialize(data)
    self.title = data.title or "Dialog"
    self.modal = data.modal or true
    self.draggable = data.draggable or true
    self.resizable = data.resizable or false
    self.titleBarHeight = data.titleBarHeight or 30
end

return Dialog
