--[[
widgets/textinput.lua
TextInput widget (advanced text entry with validation and autocomplete)


Advanced text input widget providing comprehensive text entry capabilities with validation,
autocomplete, masking, and accessibility features for tactical strategy game interfaces.
Supports single-line and multiline input with rich formatting and user experience enhancements.

PURPOSE:
- Provide reliable text input with support for various input types and validation
- Essential component for forms, search fields, command inputs, and data entry
- Enable secure password entry and specialized input formats (phone, email, numbers)
- Support autocomplete for improved user experience in complex UIs

KEY FEATURES:
- Input types: text, password, email, number, phone, url with type-specific validation
- Single-line and multiline modes with word wrapping and scrolling
- Input masking and formatting for structured data entry
- Real-time validation with visual feedback and error messages
- Autocomplete integration with fuzzy matching and suggestions
- Multiple visual styles: default, filled, outlined, underlined
- Icon support with left/right positioning
- Password visibility toggle for secure fields
- Character counter and helper text
- Accessibility: labels, hints, keyboard navigation
- Animation: floating labels, cursor blinking, focus transitions

@see widgets.common.core.Base
@see widgets.common.validation
@see widgets.complex.autocomplete
@see widgets.common.button
@see widgets.common.form
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Validation = require("widgets.common.validation")
local AutoComplete = require("widgets.complex.autocomplete")
local AutoCompleteMixin = require("widgets.common.autocomplete_mixin")

--- @class TextInput
local TextInput = {}
TextInput.__index = TextInput

--- Creates a new TextInput widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the text input widget
--- @param h number The height of the text input widget
--- @param placeholder string The placeholder text to display when empty
--- @param options table Optional configuration table
--- @return TextInput A new text input widget instance
function TextInput:new(x, y, w, h, placeholder, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    -- Basic properties
    obj.text = options.text or ""
    obj.placeholder = placeholder or ""
    obj.cursor = 0
    obj.selectionStart = 0
    obj.selectionEnd = 0

    -- Enhanced input properties
    obj.inputType = options.inputType or "text" -- text, password, email, number, phone, url
    obj.maxLength = options.maxLength
    obj.minLength = options.minLength
    obj.readonly = options.readonly or false
    obj.multiline = options.multiline or false
    obj.wordWrap = options.wordWrap or false

    -- Masking and formatting
    obj.mask = options.mask     -- e.g., "(###) ###-####" for phone
    obj.maskChar = options.maskChar or "#"
    obj.format = options.format -- custom format function
    obj.parser = options.parser -- custom parser function

    -- Auto-complete integration
    obj.autoComplete = options.autoComplete
    obj.autoCompleteSource = options.autoCompleteSource or {}
    obj.autoCompleteWidget = nil
    obj.showAutoComplete = false

    -- Validation
    obj.validator = options.validator
    obj.validationState = "none" -- none, valid, invalid, warning
    obj.validationMessage = ""
    obj.validateOnChange = options.validateOnChange ~= false
    obj.validateOnBlur = options.validateOnBlur ~= false

    -- Visual styling
    obj.style = options.style or "default" -- default, filled, outlined, underlined
    obj.size = options.size or "medium"    -- small, medium, large
    obj.cornerRadius = options.cornerRadius or 4
    obj.borderWidth = options.borderWidth or 1

    -- Icon support
    obj.leftIcon = options.leftIcon
    obj.rightIcon = options.rightIcon
    obj.iconSize = options.iconSize or 16
    obj.iconSpacing = options.iconSpacing or 8

    -- Password visibility toggle
    obj.showPassword = false
    obj.passwordToggle = options.passwordToggle ~= false

    -- Character counter
    obj.showCounter = options.showCounter or false
    obj.counterPosition = options.counterPosition or "bottom-right"

    -- Suggestion/helper text
    obj.helperText = options.helperText
    obj.helperTextPosition = options.helperTextPosition or "bottom"

    -- Animation and interaction
    obj.animateLabel = options.animateLabel ~= false
    obj.labelFloating = false
    obj.cursorBlinkTime = 0
    obj.cursorVisible = true
    obj.scrollOffset = 0

    -- Colors (will be set up based on style)
    obj:_setupColors(options)

    -- Event callbacks
    obj.onChange = options.onChange
    obj.onValidation = options.onValidation
    obj.onFocus = options.onFocus
    obj.onBlur = options.onBlur
    obj.onEnter = options.onEnter

    -- Accessibility
    obj.accessibilityLabel = obj.accessibilityLabel or obj.placeholder or "Text input"
    obj.accessibilityHint = obj.accessibilityHint or "Type to enter text"

    setmetatable(obj, self)

    -- Initialize auto-complete if enabled
    if obj.autoComplete then
        obj:_initAutoComplete()
        -- attach mixin helpers for simple show/hide API
        AutoCompleteMixin.init(obj)
    end

    return obj
end

--- Sets up color scheme for the text input widget (private method)
--- @param options table Configuration options containing color settings
function TextInput:_setupColors(options)
    local theme = core.theme
    local styleColors = {
        default = {
            background = theme.surface,
            backgroundFocused = theme.surface,
            backgroundHover = theme.surfaceHover,
            border = theme.border,
            borderFocused = theme.accent,
            borderHover = theme.borderHover,
            text = theme.text,
            placeholder = theme.textSecondary,
            label = theme.textSecondary,
            counter = theme.textSecondary,
            helper = theme.textSecondary
        },
        filled = {
            background = theme.surfaceVariant,
            backgroundFocused = theme.surface,
            backgroundHover = theme.surfaceHover,
            border = { 0, 0, 0, 0 }, -- Transparent
            borderFocused = theme.accent,
            borderHover = theme.borderHover,
            text = theme.text,
            placeholder = theme.textSecondary,
            label = theme.textSecondary,
            counter = theme.textSecondary,
            helper = theme.textSecondary
        },
        outlined = {
            background = { 0, 0, 0, 0 }, -- Transparent
            backgroundFocused = { 0, 0, 0, 0 },
            backgroundHover = theme.surfaceHover,
            border = theme.border,
            borderFocused = theme.accent,
            borderHover = theme.borderHover,
            text = theme.text,
            placeholder = theme.textSecondary,
            label = theme.textSecondary,
            counter = theme.textSecondary,
            helper = theme.textSecondary
        },
        underlined = {
            background = { 0, 0, 0, 0 }, -- Transparent
            backgroundFocused = { 0, 0, 0, 0 },
            backgroundHover = theme.surfaceHover,
            border = theme.border,
            borderFocused = theme.accent,
            borderHover = theme.borderHover,
            text = theme.text,
            placeholder = theme.textSecondary,
            label = theme.textSecondary,
            counter = theme.textSecondary,
            helper = theme.textSecondary
        }
    }

    local baseColors = styleColors[self.style] or styleColors.default
    self.colors = {}
    for key, value in pairs(baseColors) do
        self.colors[key] = (options.colors and options.colors[key]) or value
    end

    -- Validation state colors
    self.colors.valid = theme.success
    self.colors.invalid = theme.error
    self.colors.warning = theme.warning
end

--- Initializes the autocomplete functionality (private method)
function TextInput:_initAutoComplete()
    if not self.autoCompleteWidget then
        self.autoCompleteWidget = AutoComplete:new(
            self.x, self.y + self.h + 2, self.w, 150,
            {
                source = self.autoCompleteSource,
                maxItems = 8,
                fuzzySearch = true,
                onSelect = function(item)
                    self:setText(item.text or item)
                    self:_hideAutoComplete()
                end
            }
        )
        self.autoCompleteWidget.visible = false
    end
end

--- Updates the text input widget state
--- @param dt number The time delta since the last update
function TextInput:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    -- Update cursor blink
    self.cursorBlinkTime = self.cursorBlinkTime + dt
    if self.cursorBlinkTime >= 1.0 then
        self.cursorBlinkTime = 0
        self.cursorVisible = not self.cursorVisible
    end

    -- Handle mouse interaction
    local mx, my = love.mouse.getPosition()
    if not self.focused then
        if love.mouse.isDown(1) and self:hitTest(mx, my) then
            core.setFocus(self)
        end
    end

    -- Update auto-complete
    if self.autoCompleteWidget then
        self.autoCompleteWidget:update(dt)
    end

    -- Auto-validate on change
    if self.validateOnChange and self.validator then
        self:validate()
    end
end

--- Draws the text input widget and its components
function TextInput:draw()
    core.Base.draw(self)

    -- Setup clipping for text content
    love.graphics.push()
    love.graphics.intersectScissor(self.x, self.y, self.w, self.h)

    -- Draw background
    self:_drawBackground()

    -- Draw border
    self:_drawBorder()

    -- Draw icons
    self:_drawIcons()

    -- Draw text content
    self:_drawTextContent()

    -- Draw cursor and selection
    if self.focused then
        self:_drawCursor()
        self:_drawSelection()
    end

    love.graphics.pop()

    -- Draw validation indicator
    if self.validationState ~= "none" then
        self:_drawValidationIndicator()
    end

    -- Draw label (if animated and floating)
    if self.animateLabel and (self.focused or self.text ~= "") then
        self:_drawFloatingLabel()
    end

    -- Draw helper text
    if self.helperText or self.validationMessage then
        self:_drawHelperText()
    end

    -- Draw character counter
    if self.showCounter and self.maxLength then
        self:_drawCounter()
    end

    -- Draw auto-complete dropdown
    if self.autoCompleteWidget and self.showAutoComplete then
        self.autoCompleteWidget:draw()
    end

    -- Draw focus ring
    if self.focused then
        self:_drawFocusRing()
    end
end

function TextInput:_drawBackground()
    local bgColor
    if not self.enabled then
        bgColor = self.colors.background
    elseif self.focused then
        bgColor = self.colors.backgroundFocused
    elseif self.hovered then
        bgColor = self.colors.backgroundHover
    else
        bgColor = self.colors.background
    end

    -- Skip transparent backgrounds
    if bgColor[4] and bgColor[4] == 0 then return end

    love.graphics.setColor(unpack(bgColor))

    if self.style == "underlined" then
        -- Only draw a thin line at the bottom
        local lineY = self.y + self.h - 2
        love.graphics.rectangle("fill", self.x, lineY, self.w, 2)
    elseif self.cornerRadius > 0 then
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius)
    else
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end
end

function TextInput:_drawBorder()
    local borderColor
    if not self.enabled then
        borderColor = self.colors.border
    elseif self.validationState == "invalid" then
        borderColor = self.colors.invalid
    elseif self.validationState == "warning" then
        borderColor = self.colors.warning
    elseif self.validationState == "valid" then
        borderColor = self.colors.valid
    elseif self.focused then
        borderColor = self.colors.borderFocused
    elseif self.hovered then
        borderColor = self.colors.borderHover
    else
        borderColor = self.colors.border
    end

    -- Skip transparent borders
    if borderColor[4] and borderColor[4] == 0 then return end

    love.graphics.setColor(unpack(borderColor))
    love.graphics.setLineWidth(self.focused and 2 or self.borderWidth)

    if self.style == "underlined" then
        local lineY = self.y + self.h - 1
        love.graphics.line(self.x, lineY, self.x + self.w, lineY)
    elseif self.cornerRadius > 0 then
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.cornerRadius)
    else
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    end

    love.graphics.setLineWidth(1)
end

function TextInput:_drawIcons()
    local leftIconWidth = 0
    local rightIconWidth = 0

    -- Left icon
    if self.leftIcon then
        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.print(self.leftIcon, self.x + 8, self.y + (self.h - self.iconSize) / 2)
        leftIconWidth = self.iconSize + self.iconSpacing
    end

    -- Right icon (or password toggle)
    local rightIcon = self.rightIcon
    if self.inputType == "password" and self.passwordToggle then
        rightIcon = self.showPassword and "👁" or "🔒"
    end

    if rightIcon then
        love.graphics.setColor(unpack(self.colors.text))
        love.graphics.print(rightIcon, self.x + self.w - self.iconSize - 8,
            self.y + (self.h - self.iconSize) / 2)
        rightIconWidth = self.iconSize + self.iconSpacing
    end

    -- Store for text positioning
    self._leftIconWidth = leftIconWidth
    self._rightIconWidth = rightIconWidth
end

function TextInput:_drawTextContent()
    local font = love.graphics.getFont()
    local textPadding = 8
    local leftPadding = textPadding + (self._leftIconWidth or 0)
    local rightPadding = textPadding + (self._rightIconWidth or 0)
    local availableWidth = self.w - leftPadding - rightPadding

    local displayText = self:_getDisplayText()
    local textColor = displayText == self.placeholder and self.colors.placeholder or self.colors.text

    love.graphics.setColor(unpack(textColor))
    love.graphics.setFont(font)

    local textX = self.x + leftPadding - self.scrollOffset
    local textY = self.y + (self.h - font:getHeight()) / 2

    if self.multiline then
        love.graphics.printf(displayText, textX, textY, availableWidth, "left")
    else
        love.graphics.print(displayText, textX, textY)
    end
end

function TextInput:_drawCursor()
    if not self.cursorVisible then return end

    local font = love.graphics.getFont()
    local textPadding = 8
    local leftPadding = textPadding + (self._leftIconWidth or 0)

    local displayText = self:_getDisplayText()
    local cursorText = displayText == self.placeholder and "" or displayText:sub(1, self.cursor)
    local cursorX = self.x + leftPadding + font:getWidth(cursorText) - self.scrollOffset

    love.graphics.setColor(unpack(self.colors.text))
    love.graphics.line(cursorX, self.y + 4, cursorX, self.y + self.h - 4)
end

function TextInput:_drawSelection()
    if self.selectionStart == self.selectionEnd then return end

    local font = love.graphics.getFont()
    local textPadding = 8
    local leftPadding = textPadding + (self._leftIconWidth or 0)

    local startPos = math.min(self.selectionStart, self.selectionEnd)
    local endPos = math.max(self.selectionStart, self.selectionEnd)

    local displayText = self:_getDisplayText()
    if displayText == self.placeholder then return end

    local beforeSelection = displayText:sub(1, startPos)
    local selectedText = displayText:sub(startPos + 1, endPos)

    local selectionX = self.x + leftPadding + font:getWidth(beforeSelection) - self.scrollOffset
    local selectionWidth = font:getWidth(selectedText)

    -- Selection background
    love.graphics.setColor(0.3, 0.6, 1, 0.3)
    love.graphics.rectangle("fill", selectionX, self.y + 4, selectionWidth, self.h - 8)
end

function TextInput:_drawValidationIndicator()
    local indicatorSize = 6
    local indicatorX = self.x + self.w - indicatorSize - 2
    local indicatorY = self.y + 2

    local color
    if self.validationState == "valid" then
        color = self.colors.valid
    elseif self.validationState == "invalid" then
        color = self.colors.invalid
    elseif self.validationState == "warning" then
        color = self.colors.warning
    else
        return
    end

    love.graphics.setColor(unpack(color))
    love.graphics.circle("fill", indicatorX + indicatorSize / 2, indicatorY + indicatorSize / 2, indicatorSize / 2)
end

function TextInput:_drawFloatingLabel()
    if not self.placeholder then return end

    love.graphics.setColor(unpack(self.colors.label))
    local font = love.graphics.getFont()
    local labelY = self.y - font:getHeight() - 2
    love.graphics.print(self.placeholder, self.x + 8, labelY)
end

function TextInput:_drawHelperText()
    local text = self.validationMessage ~= "" and self.validationMessage or self.helperText
    if not text then return end

    local color = self.colors.helper
    if self.validationState == "invalid" then
        color = self.colors.invalid
    elseif self.validationState == "warning" then
        color = self.colors.warning
    elseif self.validationState == "valid" then
        color = self.colors.valid
    end

    love.graphics.setColor(unpack(color))
    local font = love.graphics.getFont()
    local helperY = self.y + self.h + 4
    love.graphics.print(text, self.x + 8, helperY)
end

function TextInput:_drawCounter()
    local current = #self.text
    local max = self.maxLength
    local text = string.format("%d/%d", current, max)

    local color = current > max and self.colors.invalid or self.colors.counter
    love.graphics.setColor(unpack(color))

    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local counterX = self.x + self.w - textWidth - 8
    local counterY = self.y + self.h + 4

    love.graphics.print(text, counterX, counterY)
end

function TextInput:_drawFocusRing()
    love.graphics.setColor(unpack(core.focus.focusRingColor))
    love.graphics.setLineWidth(2)

    local padding = 1
    if self.cornerRadius > 0 then
        love.graphics.rectangle("line", self.x - padding, self.y - padding,
            self.w + padding * 2, self.h + padding * 2,
            self.cornerRadius + padding)
    else
        love.graphics.rectangle("line", self.x - padding, self.y - padding,
            self.w + padding * 2, self.h + padding * 2)
    end

    love.graphics.setLineWidth(1)
end

-- Helper methods
function TextInput:_getDisplayText()
    if self.text == "" then
        return self.placeholder
    elseif self.inputType == "password" and not self.showPassword then
        return string.rep("•", #self.text)
    elseif self.mask then
        return self:_applyMask(self.text)
    else
        return self.text
    end
end

function TextInput:_applyMask(text)
    if not self.mask then return text end

    local result = ""
    local textIndex = 1

    for i = 1, #self.mask do
        local maskChar = self.mask:sub(i, i)
        if maskChar == self.maskChar then
            if textIndex <= #text then
                result = result .. text:sub(textIndex, textIndex)
                textIndex = textIndex + 1
            end
        else
            result = result .. maskChar
        end
    end

    return result
end

function TextInput:_stripMask(text)
    if not self.mask then return text end

    local result = ""
    local maskIndex = 1

    for i = 1, #text do
        if maskIndex <= #self.mask then
            local maskChar = self.mask:sub(maskIndex, maskIndex)
            if maskChar == self.maskChar then
                result = result .. text:sub(i, i)
            end
            maskIndex = maskIndex + 1
        end
    end

    return result
end

function TextInput:_showAutoComplete()
    if not self.autoCompleteWidget or self.text == "" then return end

    self.autoCompleteWidget:setQuery(self.text)
    self.autoCompleteWidget.x = self.x
    self.autoCompleteWidget.y = self.y + self.h + 2
    self.autoCompleteWidget.w = self.w
    self.autoCompleteWidget.visible = true
    self.showAutoComplete = true
end

function TextInput:_hideAutoComplete()
    if self.autoCompleteWidget then
        self.autoCompleteWidget.visible = false
    end
    self.showAutoComplete = false
end

function TextInput:_updateScrollOffset()
    local font = love.graphics.getFont()
    local textPadding = 8
    local leftPadding = textPadding + (self._leftIconWidth or 0)
    local rightPadding = textPadding + (self._rightIconWidth or 0)
    local availableWidth = self.w - leftPadding - rightPadding

    local cursorText = self.text:sub(1, self.cursor)
    local cursorPos = font:getWidth(cursorText)

    -- Scroll to keep cursor visible
    if cursorPos - self.scrollOffset > availableWidth then
        self.scrollOffset = cursorPos - availableWidth + 10
    elseif cursorPos - self.scrollOffset < 0 then
        self.scrollOffset = math.max(0, cursorPos - 10)
    end
end

-- Enhanced input handling
--- Handles key press events for the text input widget
--- @param key string The key that was pressed
--- @return boolean True if the key was handled, false otherwise
function TextInput:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end
    if self.readonly then return true end

    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

    self.cursorBlinkTime = 0
    self.cursorVisible = true

    -- Handle auto-complete navigation
    if self.showAutoComplete then
        if key == "down" or key == "up" or key == "return" or key == "escape" then
            return self.autoCompleteWidget:keypressed(key)
        end
    end

    if key == "backspace" then
        if self.selectionStart ~= self.selectionEnd then
            self:_deleteSelection()
        elseif self.cursor > 0 then
            if ctrl then
                -- Delete word
                local wordStart = self:_findWordBoundary(self.cursor, -1)
                self.text = self.text:sub(1, wordStart) .. self.text:sub(self.cursor + 1)
                self.cursor = wordStart
            else
                self.text = self.text:sub(1, self.cursor - 1) .. self.text:sub(self.cursor + 1)
                self.cursor = self.cursor - 1
            end
            self:_onChange()
        end
    elseif key == "delete" then
        if self.selectionStart ~= self.selectionEnd then
            self:_deleteSelection()
        elseif self.cursor < #self.text then
            if ctrl then
                -- Delete word
                local wordEnd = self:_findWordBoundary(self.cursor, 1)
                self.text = self.text:sub(1, self.cursor) .. self.text:sub(wordEnd + 1)
            else
                self.text = self.text:sub(1, self.cursor) .. self.text:sub(self.cursor + 2)
            end
            self:_onChange()
        end
    elseif key == "left" then
        if ctrl then
            self.cursor = self:_findWordBoundary(self.cursor, -1)
        else
            self.cursor = math.max(0, self.cursor - 1)
        end
        if not shift then
            self:_clearSelection()
        else
            self.selectionEnd = self.cursor
        end
    elseif key == "right" then
        if ctrl then
            self.cursor = self:_findWordBoundary(self.cursor, 1)
        else
            self.cursor = math.min(#self.text, self.cursor + 1)
        end
        if not shift then
            self:_clearSelection()
        else
            self.selectionEnd = self.cursor
        end
    elseif key == "home" then
        self.cursor = 0
        if not shift then
            self:_clearSelection()
        else
            self.selectionEnd = self.cursor
        end
    elseif key == "end" then
        self.cursor = #self.text
        if not shift then
            self:_clearSelection()
        else
            self.selectionEnd = self.cursor
        end
    elseif key == "a" and ctrl then
        -- Select all
        self.selectionStart = 0
        self.selectionEnd = #self.text
        self.cursor = #self.text
    elseif key == "c" and ctrl then
        -- Copy
        if self.selectionStart ~= self.selectionEnd then
            local startPos = math.min(self.selectionStart, self.selectionEnd)
            local endPos = math.max(self.selectionStart, self.selectionEnd)
            local selectedText = self.text:sub(startPos + 1, endPos)
            love.system.setClipboardText(selectedText)
        end
    elseif key == "v" and ctrl then
        -- Paste
        local clipboardText = love.system.getClipboardText()
        self:_insertText(clipboardText)
    elseif key == "x" and ctrl then
        -- Cut
        if self.selectionStart ~= self.selectionEnd then
            local startPos = math.min(self.selectionStart, self.selectionEnd)
            local endPos = math.max(self.selectionStart, self.selectionEnd)
            local selectedText = self.text:sub(startPos + 1, endPos)
            love.system.setClipboardText(selectedText)
            self:_deleteSelection()
        end
    elseif key == "return" or key == "kpenter" then
        if self.multiline then
            self:_insertText("\n")
        else
            if self.onEnter then
                self.onEnter(self.text, self)
            end
            if self.showAutoComplete then
                self:_hideAutoComplete()
            end
            core.focusNext()
        end
    elseif key == "escape" then
        if self.showAutoComplete then
            self:_hideAutoComplete()
        else
            if self.onBlur then
                self.onBlur(self.text, self)
            end
            core.clearFocus()
        end
    elseif key == "tab" then
        if self.showAutoComplete then
            self:_hideAutoComplete()
        end
        return core.Base.keypressed(self, key)
    end

    self:_updateScrollOffset()
    return true
end

--- Handles text input events for the text input widget
--- @param text string The text that was input
function TextInput:textinput(text)
    if not self.focused or self.readonly then return end

    self:_insertText(text)
end

function TextInput:_insertText(text)
    -- Validate input based on type
    if not self:_validateInput(text) then return end

    -- Check max length
    if self.maxLength and #self.text + #text > self.maxLength then
        text = text:sub(1, self.maxLength - #self.text)
    end

    -- Delete selection first if any
    if self.selectionStart ~= self.selectionEnd then
        self:_deleteSelection()
    end

    -- Insert text
    self.text = self.text:sub(1, self.cursor) .. text .. self.text:sub(self.cursor + 1)
    self.cursor = self.cursor + #text

    self:_onChange()
    self:_updateScrollOffset()
end

function TextInput:_validateInput(text)
    if self.inputType == "number" then
        return text:match("^[0-9%.%-]$") ~= nil
    elseif self.inputType == "phone" then
        return text:match("^[0-9%-%s%(%)]$") ~= nil
    elseif self.inputType == "email" then
        return text:match("^[%w%.@%-_]$") ~= nil
    end
    return true
end

function TextInput:_onChange()
    if self.onChange then
        self.onChange(self.text, self)
    end

    -- Show auto-complete
    if self.autoComplete and self.text ~= "" then
        self:_showAutoComplete()
    elseif self.showAutoComplete and self.text == "" then
        self:_hideAutoComplete()
    end

    -- Auto-validate
    if self.validateOnChange then
        self:validate()
    end
end

function TextInput:_deleteSelection()
    if self.selectionStart == self.selectionEnd then return end

    local startPos = math.min(self.selectionStart, self.selectionEnd)
    local endPos = math.max(self.selectionStart, self.selectionEnd)

    self.text = self.text:sub(1, startPos) .. self.text:sub(endPos + 1)
    self.cursor = startPos
    self:_clearSelection()
    self:_onChange()
end

function TextInput:_clearSelection()
    self.selectionStart = self.cursor
    self.selectionEnd = self.cursor
end

function TextInput:_findWordBoundary(pos, direction)
    if direction > 0 then
        -- Find next word boundary
        local i = pos + 1
        while i <= #self.text and not self.text:sub(i, i):match("%s") do
            i = i + 1
        end
        while i <= #self.text and self.text:sub(i, i):match("%s") do
            i = i + 1
        end
        return math.min(i - 1, #self.text)
    else
        -- Find previous word boundary
        local i = pos
        while i > 1 and self.text:sub(i, i):match("%s") do
            i = i - 1
        end
        while i > 1 and not self.text:sub(i - 1, i - 1):match("%s") do
            i = i - 1
        end
        return math.max(0, i - 1)
    end
end

--- Handles mouse press events for the text input widget
--- @param x number The x-coordinate of the mouse press
--- @param y number The y-coordinate of the mouse press
--- @param button number The mouse button that was pressed
--- @return boolean True if the event was handled, false otherwise
function TextInput:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    if button == 1 then
        core.setFocus(self)

        -- Check for password toggle click
        if self.inputType == "password" and self.passwordToggle then
            local iconX = self.x + self.w - self.iconSize - 8
            local iconW = self.iconSize + 8
            if x >= iconX and x <= iconX + iconW then
                self.showPassword = not self.showPassword
                return true
            end
        end

        -- Position cursor
        self:_positionCursorFromMouse(x, y)

        -- Start text selection
        self.selectionStart = self.cursor
        self.selectionEnd = self.cursor

        return true
    end

    return false
end

function TextInput:mousemoved(x, y, dx, dy)
    if love.mouse.isDown(1) and self.focused then
        self:_positionCursorFromMouse(x, y)
        self.selectionEnd = self.cursor
    end
end

function TextInput:_positionCursorFromMouse(x, y)
    local font = love.graphics.getFont()
    local textPadding = 8
    local leftPadding = textPadding + (self._leftIconWidth or 0)

    local relativeX = x - (self.x + leftPadding) + self.scrollOffset

    -- Find cursor position
    local bestPos = 0
    local bestDistance = math.abs(relativeX)

    for i = 1, #self.text do
        local textWidth = font:getWidth(self.text:sub(1, i))
        local distance = math.abs(relativeX - textWidth)

        if distance < bestDistance then
            bestDistance = distance
            bestPos = i
        end
    end

    self.cursor = bestPos
    self.cursorBlinkTime = 0
    self.cursorVisible = true
end

-- Focus handling
function TextInput:onFocusGain()
    core.Base.onFocusGain(self)

    if self.onFocus then
        self.onFocus(self)
    end

    -- Animate floating label
    if self.animateLabel then
        self.labelFloating = true
    end

    -- Reset cursor blink
    self.cursorBlinkTime = 0
    self.cursorVisible = true
end

function TextInput:onFocusLoss()
    core.Base.onFocusLoss(self)

    if self.onBlur then
        self.onBlur(self.text, self)
    end

    -- Validate on blur
    if self.validateOnBlur then
        self:validate()
    end

    -- Hide auto-complete
    if self.showAutoComplete then
        self:_hideAutoComplete()
    end

    -- Animate floating label
    if self.animateLabel and self.text == "" then
        self.labelFloating = false
    end
end

--- Validates the current text input value
--- @return boolean True if validation passed, false otherwise
--- Validates the current text input against the configured validator.
---
--- Runs validation on the current text content using the assigned validator.
--- Updates the validation state and triggers the onValidation callback if set.
--- The validation state can be "valid", "invalid", or "none".
---
function TextInput:validate()
    if not self.validator then
        self.validationState = "none"
        return true
    end

    local result = Validation.validateWidget(self, self.validator)
    self.validationState = result.state
    self.validationMessage = result.message or ""

    if self.onValidation then
        self.onValidation(result, self)
    end

    return result.state == "valid" or result.state == "none"
end

--- Sets the text content of the text input widget.
---
--- Updates the text content, moves the cursor to the end, clears any selection,
--- and updates the scroll offset. Triggers the onChange callback if set.
---
---@param text string The text to set.
function TextInput:setText(text)
    self.text = text or ""
    self.cursor = #self.text
    self:_clearSelection()
    self:_updateScrollOffset()

    if self.onChange then
        self.onChange(self.text, self)
    end
end

--- Gets the current text content of the text input widget.
---
--- Returns the current text content. If masking is enabled, returns the
--- unmasked version of the text.
---
---@return string The current text content.
function TextInput:getText()
    if self.mask then
        return self:_stripMask(self.text)
    else
        return self.text
    end
end

--- Sets the placeholder text displayed when the input is empty.
---
---@param placeholder string The placeholder text to display.
function TextInput:setPlaceholder(placeholder)
    self.placeholder = placeholder or ""
end

--- Sets whether the text input is read-only.
---
--- When read-only, the user cannot edit the text content.
---
---@param readonly boolean Whether the input should be read-only.
function TextInput:setReadonly(readonly)
    self.readonly = readonly
end

--- Sets the maximum length for the text input.
---
--- Limits the number of characters that can be entered. If the current text
--- exceeds the new limit, it will be truncated.
---
---@param maxLength number The maximum number of characters allowed.
function TextInput:setMaxLength(maxLength)
    self.maxLength = maxLength

    -- Trim text if needed
    if maxLength and #self.text > maxLength then
        self.text = self.text:sub(1, maxLength)
        self.cursor = math.min(self.cursor, #self.text)
    end
end

--- Sets the validator for the text input.
---
--- Assigns a validation function or Validator object to check input validity.
--- Resets the validation state to "none".
---
---@param validator function|table The validator function or Validator object.
function TextInput:setValidator(validator)
    self.validator = validator
    self.validationState = "none"
end

function TextInput:setInputType(inputType)
    self.inputType = inputType

    -- Reset password visibility when changing away from password type
    if inputType ~= "password" then
        self.showPassword = false
    end
end

function TextInput:setMask(mask, maskChar)
    self.mask = mask
    self.maskChar = maskChar or "#"
end

function TextInput:setAutoCompleteSource(source)
    self.autoCompleteSource = source or {}
    if self.autoCompleteWidget then
        self.autoCompleteWidget:setSource(source)
    end
end

--- Gets the current validation state and message.
---
--- Returns the current validation state ("valid", "invalid", or "none")
--- and any associated validation error message.
---
---@return string, string The validation state and error message.
function TextInput:getValidationState()
    return self.validationState, self.validationMessage
end

--- Selects all text in the input field.
---
--- Sets the selection to encompass all text content and moves the cursor
--- to the end of the text.
function TextInput:selectAll()
    self.selectionStart = 0
    self.selectionEnd = #self.text
    self.cursor = #self.text
end

function TextInput:clearSelection()
    self:_clearSelection()
end

function TextInput:clear()
    self.text = ""
    self.cursor = 0
    self:_clearSelection()
    self:_updateScrollOffset()

    if self.onChange then
        self.onChange(self.text, self)
    end
end

--- Serializes the text input widget state for saving
--- @return table A table containing the serialized text input data
function TextInput:serialize()
    return {
        text = self.text,
        placeholder = self.placeholder,
        cursor = self.cursor,
        inputType = self.inputType,
        maxLength = self.maxLength,
        readonly = self.readonly,
        multiline = self.multiline,
        mask = self.mask,
        maskChar = self.maskChar,
        style = self.style,
        size = self.size,
        cornerRadius = self.cornerRadius,
        borderWidth = self.borderWidth,
        leftIcon = self.leftIcon,
        rightIcon = self.rightIcon,
        showCounter = self.showCounter,
        helperText = self.helperText,
        validationState = self.validationState,
        validationMessage = self.validationMessage
    }
end

--- Deserializes and restores the text input widget state from saved data
--- @param data table The serialized data to restore from
function TextInput:deserialize(data)
    self.text = data.text or ""
    self.placeholder = data.placeholder or ""
    self.cursor = data.cursor or 0
    self.inputType = data.inputType or "text"
    self.maxLength = data.maxLength
    self.readonly = data.readonly or false
    self.multiline = data.multiline or false
    self.mask = data.mask
    self.maskChar = data.maskChar or "#"
    self.style = data.style or "default"
    self.size = data.size or "medium"
    self.cornerRadius = data.cornerRadius or 4
    self.borderWidth = data.borderWidth or 1
    self.leftIcon = data.leftIcon
    self.rightIcon = data.rightIcon
    self.showCounter = data.showCounter or false
    self.helperText = data.helperText
    self.validationState = data.validationState or "none"
    self.validationMessage = data.validationMessage or ""

    self:_updateScrollOffset()
end

return TextInput
