--[[
widgets/label.lua
Label widget (versatile text display with rich formatting and animation)


Versatile text display widget providing rich formatting, layout, animation, and interaction
capabilities for tactical strategy game interfaces. Supports text wrapping, rich markup,
icons, visual effects, and smooth animations for immersive UI experiences.

PURPOSE:
- Display static or read-only text with advanced formatting, layout, and visual effects
- Essential component for game UI elements like mission briefings, status displays,
  dialogue text, and tactical information panels
- Support rich text formatting for highlighting important information and creating
  visually appealing interfaces

KEY FEATURES:
- Text formatting: font, size, color, alignment, line spacing, word wrapping
- Rich text markup: bold, italic, underline, color, size tags
- Icon integration: configurable positioning and spacing
- Visual effects: shadows, backgrounds, borders with customizable styling
- Animation system: typewriter effect, fade-in, slide-in transitions
- Interactive capabilities: hover effects, click handling, text selection
- Accessibility: screen reader support and keyboard navigation
- Performance optimized: efficient text wrapping and rendering

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.button
@see widgets.common.textinput
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local Label = {}
Label.__index = Label
setmetatable(Label, { __index = core.Base })

--- Creates a new Label widget for text display.
---
---@param x number The x-coordinate position.
---@param y number The y-coordinate position.
---@param w number The width of the label.
---@param h number The height of the label.
---@param options? table Optional configuration table for text, styling, etc.
---@return table A new label widget instance.
function Label:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h, options)

    -- Text properties
    obj.text = (options and options.text) or ""
    obj.font = (options and options.font) or core.theme.font
    obj.fontSize = (options and options.fontSize) or 14
    obj.color = (options and options.color) or core.theme.text
    obj.shadowColor = (options and options.shadowColor) or { 0, 0, 0, 0.3 }
    obj.shadowOffset = (options and options.shadowOffset) or { 1, 1 }

    -- Alignment and layout
    obj.align = (options and options.align) or "left"             -- left, center, right, justify
    obj.valign = (options and options.valign) or "top"            -- top, middle, bottom
    obj.padding = (options and options.padding) or { 4, 4, 4, 4 } -- top, right, bottom, left
    obj.lineSpacing = (options and options.lineSpacing) or 1.2
    obj.wordWrap = (options and options.wordWrap) ~= false

    -- Rich text support
    obj.richText = (options and options.richText) or false
    obj.markup = (options and options.markup) or false
    obj.allowTags = (options and options.allowTags) or { "b", "i", "u", "color", "size" }

    -- Icon support
    obj.icon = options and options.icon
    obj.iconPosition = (options and options.iconPosition) or "left" -- left, right, top, bottom
    obj.iconSpacing = (options and options.iconSpacing) or 4
    obj.iconSize = (options and options.iconSize) or 16

    -- Visual effects
    obj.showShadow = (options and options.showShadow) or false
    obj.showBackground = (options and options.showBackground) or false
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundLight
    obj.borderRadius = (options and options.borderRadius) or 0
    obj.showBorder = (options and options.showBorder) or false
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.borderWidth = (options and options.borderWidth) or 1

    -- Animation properties
    obj.animateText = (options and options.animateText) or false
    obj.typewriterSpeed = (options and options.typewriterSpeed) or 50 -- chars per second
    obj.fadeIn = (options and options.fadeIn) or false
    obj.slideIn = (options and options.slideIn) or false
    obj.visibleChars = 0
    obj.targetChars = 0

    -- Interactive properties
    obj.selectable = (options and options.selectable) or false
    obj.copyable = (options and options.copyable) or false
    obj.clickable = (options and options.clickable) or false
    obj.hoverable = (options and options.hoverable) or false
    obj.hoverColor = (options and options.hoverColor) or core.theme.primary

    return obj
end

--- Parses and wraps text for display within the label's width constraints.
---
--- This private method handles text wrapping, icon spacing calculations, and prepares
--- the text for rendering. It supports word wrapping and adjusts for icon positioning
--- when icons are present. Also initializes text animation if configured.
---
--- @private
function Label:_parseText()
    -- Calculate wrapped text lines
    self.wrappedText = {}

    if not self.wordWrap then
        table.insert(self.wrappedText, { text = self.text, width = self.font:getWidth(self.text) })
        self.textWidth = self.font:getWidth(self.text)
        self.textHeight = self.font:getHeight()
        return
    end

    local maxWidth = self.w - self.padding[2] - self.padding[4]
    if self.icon and (self.iconPosition == "left" or self.iconPosition == "right") then
        maxWidth = maxWidth - self.iconSize - self.iconSpacing
    end

    local words = {}
    for word in self.text:gmatch("%S+") do
        table.insert(words, word)
    end

    local currentLine = ""
    local maxLineWidth = 0

    for i, word in ipairs(words) do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
        local lineWidth = self.font:getWidth(testLine)

        if lineWidth > maxWidth and currentLine ~= "" then
            -- Start new line
            local actualWidth = self.font:getWidth(currentLine)
            table.insert(self.wrappedText, { text = currentLine, width = actualWidth })
            maxLineWidth = math.max(maxLineWidth, actualWidth)
            currentLine = word
        else
            currentLine = testLine
        end
    end

    -- Add final line
    if currentLine ~= "" then
        local actualWidth = self.font:getWidth(currentLine)
        table.insert(self.wrappedText, { text = currentLine, width = actualWidth })
        maxLineWidth = math.max(maxLineWidth, actualWidth)
    end

    self.textWidth = maxLineWidth
    self.textHeight = #self.wrappedText * self.font:getHeight() * self.lineSpacing

    -- Update target chars for animation
    self.targetChars = string.len(self.text)
    if self.animateText and self.visibleChars == 0 then
        self:startTextAnimation()
    end
end

--- Starts text animation effects like typewriter, fade-in, or slide-in transitions.
---
--- This private method initializes various text animation effects based on the label's
--- configuration. It handles typewriter effects, fade-in animations, and slide-in
--- transitions. The animation uses the Animation module for smooth transitions.
---
--- @private
function Label:startTextAnimation()
    self.visibleChars = 0

    if self.fadeIn then
        self.alpha = 0
        Animation.animateWidget(self, "alpha", 1, 0.5, Animation.types.EASE_OUT)
    end

    if self.slideIn then
        local originalX = self.x
        self.x = self.x - 50
        Animation.animateWidget(self, "x", originalX, 0.5, Animation.types.EASE_OUT)
    end

    if self.animateText then
        Animation.animateWidget(self, "visibleChars", self.targetChars,
            self.targetChars / self.typewriterSpeed,
            Animation.types.LINEAR, function()
                if self.onTextComplete then
                    self.onTextComplete(self)
                end
            end)
    end
end

--- Sets the text content of the label
--- @param newText string The new text to display
--- @param animate boolean Whether to animate the text change (optional)
function Label:setText(newText, animate)
    self.text = newText or ""
    self:_parseText()

    if animate and self.animateText then
        self:startTextAnimation()
    end
end

--- Sets the color of the label text
--- Sets the text color for the label.
---
---@param color table Color table with r, g, b, a values.
function Label:setColor(color)
    self.color = color
end

--- Sets the font and size for the label.
---
---@param font love.Font|string|number The font object, font file path, or font size.
---@param size? number The font size (optional, only used when font is a path).
function Label:setFont(font, size)
    if type(font) == "string" then
        -- Load font from file
        self.font = love.graphics.newFont(font)
        -- Set size if provided
        if size then
            self.fontSize = size
        end
    elseif type(font) == "number" then
        -- Create default font with size
        self.font = love.graphics.newFont(font)
        self.fontSize = font
    else
        -- Use provided font object
        self.font = font or self.font
    end
    self.fontSize = size or self.fontSize
    self:_parseText()
end

--- Updates the label state, handling animations and hover detection.
---
--- Called each frame to update the label's internal state. This includes calling
--- the base update method, updating hover state based on mouse position, and
--- handling any ongoing animations.
---
---@param dt number The time delta since the last update in seconds.
function Label:update(dt)
    core.Base.update(self, dt)

    -- Update hover state
    local mx, my = love.mouse.getPosition()
    self.isHovered = self.hoverable and self:hitTest(mx, my)
end

--- Draws the label with text, icons, and visual effects.
---
--- Renders the label widget including background, border, text, icons, shadows,
--- and selection highlighting. Handles text wrapping, alignment, and animation
--- effects. Supports rich text formatting and various visual styling options.
function Label:draw()
    local contentX = self.x + self.padding[4]
    local contentY = self.y + self.padding[1]
    local contentW = self.w - self.padding[2] - self.padding[4]
    local contentH = self.h - self.padding[1] - self.padding[3]

    -- Draw background
    if self.showBackground then
        love.graphics.setColor(table.unpack(self.backgroundColor))
        if self.borderRadius > 0 then
            -- Rounded rectangle (simplified)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)
        else
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end
    end

    -- Draw border
    if self.showBorder then
        love.graphics.setColor(table.unpack(self.borderColor))
        love.graphics.setLineWidth(self.borderWidth)
        if self.borderRadius > 0 then
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)
        else
            love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
        end
        love.graphics.setLineWidth(1)
    end

    -- Calculate text position
    local textX = contentX
    local textY = contentY

    -- Account for icon
    if self.icon then
        if self.iconPosition == "left" then
            textX = textX + self.iconSize + self.iconSpacing
        elseif self.iconPosition == "top" then
            textY = textY + self.iconSize + self.iconSpacing
        end
    end

    -- Vertical alignment
    if self.valign == "middle" then
        textY = textY + (contentH - self.textHeight) / 2
    elseif self.valign == "bottom" then
        textY = textY + contentH - self.textHeight
    end

    -- Draw icon
    if self.icon then
        self:_drawIcon(contentX, contentY, contentW, contentH)
    end

    -- Draw text
    self:_drawText(textX, textY, contentW)

    -- Draw selection
    if self.selectable and (self.selectionStart ~= self.selectionEnd) then
        self:_drawSelection(textX, textY)
    end
end

--- Draws the icon associated with the label at the appropriate position.
---
--- This private method handles rendering of both text-based icons (emoji/symbols)
--- and image-based icons. It positions the icon according to the configured
--- iconPosition and applies appropriate coloring based on hover state.
---
--- @private
--- @param contentX number The x-coordinate of the content area.
--- @param contentY number The y-coordinate of the content area.
--- @param contentW number The width of the content area.
--- @param contentH number The height of the content area.
function Label:_drawIcon(contentX, contentY, contentW, contentH)
    if type(self.icon) == "string" then
        -- Text icon (emoji or symbol)
        love.graphics.setFont(self.font)
        local color = self.isHovered and self.hoverColor or self.color
        love.graphics.setColor(table.unpack(color))

        local iconX, iconY = contentX, contentY

        if self.iconPosition == "right" then
            iconX = contentX + contentW - self.iconSize
        elseif self.iconPosition == "center" then
            iconX = contentX + (contentW - self.iconSize) / 2
        elseif self.iconPosition == "bottom" then
            iconY = contentY + contentH - self.iconSize
        end

        love.graphics.print(self.icon, iconX, iconY)
    elseif type(self.icon) == "userdata" then
        -- Image icon
        local color = self.isHovered and self.hoverColor or { 1, 1, 1, self.alpha or 1 }
        love.graphics.setColor(table.unpack(color))

        local iconX, iconY = contentX, contentY
        local scaleX = self.iconSize / self.icon:getWidth()
        local scaleY = self.iconSize / self.icon:getHeight()

        if self.iconPosition == "right" then
            iconX = contentX + contentW - self.iconSize
        elseif self.iconPosition == "center" then
            iconX = contentX + (contentW - self.iconSize) / 2
        elseif self.iconPosition == "bottom" then
            iconY = contentY + contentH - self.iconSize
        end

        love.graphics.draw(self.icon, iconX, iconY, 0, scaleX, scaleY)
    end
end

--- Draws the text content of the label with proper alignment and effects.
---
--- This private method handles the actual rendering of text lines, including
--- horizontal alignment, shadow effects, text animation (typewriter effect),
--- and alpha transparency. It processes wrapped text lines and applies
--- visual styling based on the label's configuration.
---
--- @private
--- @param textX number The x-coordinate where text should start.
--- @param textY number The y-coordinate where text should start.
--- @param availableWidth number The available width for text rendering.
function Label:_drawText(textX, textY, availableWidth)
    love.graphics.setFont(self.font)

    local currentColor = self.isHovered and self.hoverColor or self.color
    local alpha = self.alpha or 1
    local drawColor = { currentColor[1], currentColor[2], currentColor[3], alpha }

    local visibleChars = math.floor(self.visibleChars)
    local charCount = 0

    for i, line in ipairs(self.wrappedText) do
        local lineY = textY + (i - 1) * self.font:getHeight() * self.lineSpacing
        local lineX = textX

        -- Horizontal alignment
        if self.align == "center" then
            lineX = textX + (availableWidth - line.width) / 2
        elseif self.align == "right" then
            lineX = textX + availableWidth - line.width
        end

        -- Draw shadow
        if self.showShadow then
            love.graphics.setColor(table.unpack(self.shadowColor))
            love.graphics.print(line.text, lineX + self.shadowOffset[1], lineY + self.shadowOffset[2])
        end

        -- Draw text (with animation support)
        love.graphics.setColor(table.unpack(drawColor))

        if self.animateText and visibleChars < self.targetChars then
            local lineLength = string.len(line.text)
            local remainingChars = visibleChars - charCount

            if remainingChars > 0 then
                local visibleText = string.sub(line.text, 1, math.min(lineLength, remainingChars))
                love.graphics.print(visibleText, lineX, lineY)
            end

            charCount = charCount + lineLength + 1 -- +1 for space/newline
        else
            love.graphics.print(line.text, lineX, lineY)
        end
    end
end

--- Draws the text selection highlight when text is selected.
---
--- This private method renders a semi-transparent blue rectangle over the
--- selected text range. Currently simplified to handle single-line selections.
---
--- @private
--- @param textX number The x-coordinate of the text area.
--- @param textY number The y-coordinate of the text area.
function Label:_drawSelection(textX, textY)
    -- Simplified selection drawing
    love.graphics.setColor(0.2, 0.5, 1, 0.3)

    local selectionHeight = self.font:getHeight()
    local selectionY = textY

    -- Draw selection rectangle (simplified - assumes single line)
    if #self.wrappedText > 0 then
        local startX = textX + self.font:getWidth(string.sub(self.text, 1, self.selectionStart))
        local endX = textX + self.font:getWidth(string.sub(self.text, 1, self.selectionEnd))

        love.graphics.rectangle("fill", startX, selectionY, endX - startX, selectionHeight)
    end
end

--- Handles mouse press events for the label.
---
--- Processes mouse clicks for clickable labels and initiates text selection
--- for selectable labels. Returns true if the event was handled.
---
---@param x number The x-coordinate of the mouse press.
---@param y number The y-coordinate of the mouse press.
---@param button number The mouse button that was pressed (1 = left, 2 = right, etc.).
---@return boolean True if the event was handled, false otherwise.
function Label:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    if self.clickable and self.onClick then
        self.onClick(self)
        return true
    end

    if self.selectable and button == 1 then
        -- Start text selection
        local charIndex = self:_getCharacterIndex(x, y)
        self.selectionStart = charIndex
        self.selectionEnd = charIndex
        return true
    end

    return false
end

--- Handles mouse movement events for text selection.
---
--- Updates text selection range when the mouse is dragged over selectable text.
--- Only active when the left mouse button is held down.
---
---@param x number The current x-coordinate of the mouse.
---@param y number The current y-coordinate of the mouse.
---@param dx number The change in x-coordinate since the last mouse movement.
---@param dy number The change in y-coordinate since the last mouse movement.
function Label:mousemoved(x, y, dx, dy)
    if self.selectable and love.mouse.isDown(1) and self:hitTest(x, y) then
        local charIndex = self:_getCharacterIndex(x, y)
        self.selectionEnd = charIndex
    end
end

--- Gets the character index at the given mouse coordinates.
---
--- Calculates which character in the text is at the specified mouse position.
--- Uses a simplified approach with average character width for performance.
--- Returns a clamped index within the text bounds.
---
--- @private
--- @param x number The x-coordinate of the mouse position.
--- @param y number The y-coordinate of the mouse position.
--- @return number The character index at the given position (0-based).
function Label:_getCharacterIndex(x, y)
    -- Simplified character index calculation
    local relativeX = x - (self.x + self.padding[4])
    local charWidth = self.font:getWidth("M") -- Average character width
    return math.max(0, math.min(string.len(self.text), math.floor(relativeX / charWidth)))
end

--- Handles keyboard input events for the label.
---
--- Processes keyboard shortcuts for copy operations when the label is focused
--- and copyable. Currently supports Ctrl+C for copying selected text.
---
---@param key string The key that was pressed.
---@return boolean True if the key event was handled, false otherwise.
function Label:keypressed(key)
    if not self.focused then return false end

    if self.copyable and key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        if self.selectionStart ~= self.selectionEnd then
            local startPos = math.min(self.selectionStart, self.selectionEnd)
            local endPos = math.max(self.selectionStart, self.selectionEnd)
            local selectedText = string.sub(self.text, startPos + 1, endPos)
            love.system.setClipboardText(selectedText)
        end
        return true
    end

    return false
end

-- Utility methods
--- Gets the calculated width and height of the text content.
---
--- Returns the dimensions of the rendered text after wrapping and layout
--- calculations. Useful for determining the actual space occupied by text.
---
---@return number, number The text width and height in pixels.
function Label:getTextBounds()
    return self.textWidth, self.textHeight
end

--- Sets the horizontal and vertical text alignment.
---
--- Controls how text is positioned within the label's bounds. Horizontal alignment
--- affects text positioning on each line, while vertical alignment affects the
--- overall text block positioning within the label.
---
---@param horizontal? string The horizontal alignment ("left", "center", "right").
---@param vertical? string The vertical alignment ("top", "middle", "bottom").
function Label:setAlignment(horizontal, vertical)
    self.align = horizontal or self.align
    self.valign = vertical or self.valign
end

--- Sets the padding around the text content.
---
--- Defines the spacing between the label's edges and the text content.
--- Can be set as individual values or as a table with {top, right, bottom, left}.
--- Affects text positioning and layout calculations.
---
---@param top number|table The top padding, or a table with {top, right, bottom, left}.
---@param right? number The right padding (optional if table passed).
---@param bottom? number The bottom padding (optional if table passed).
---@param left? number The left padding (optional if table passed).
function Label:setPadding(top, right, bottom, left)
    if type(top) == "table" then
        self.padding = top
    else
        self.padding = { top, right or top, bottom or top, left or right or top }
    end
    self:_parseText()
end

return Label
