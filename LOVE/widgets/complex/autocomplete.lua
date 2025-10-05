--[[
widgets/autocomplete.lua
AutoComplete widget for intelligent text input with suggestions


Intelligent text input widget with contextual suggestions for strategy games.
Provides fuzzy matching and filtering for quick selection from large datasets.

PURPOSE:
- Provide intelligent text input with contextual suggestions for strategy games
- Enable quick selection from large lists of soldiers, research projects, equipment
- Support fuzzy matching for improved user experience with large datasets
- Facilitate fast data entry in base management and tactical planning screens

KEY FEATURES:
- Fuzzy matching and filtering of suggestions based on user input
- Customizable suggestion limits and display options
- Keyboard navigation and accessibility support
- Integration with validation system for input checking
- Real-time suggestion updates as user types
- Support for different data sources and suggestion providers
- Customizable suggestion formatting and display
- History tracking for frequently used items
- Multi-language support for international datasets

@see widgets.common.core.Base
@see widgets.common.textinput
@see widgets.common.validation
]]
local core = require("widgets.core")
local Validation = require("widgets.common.validation")
local AutoComplete = {}
AutoComplete.__index = AutoComplete

function AutoComplete:new(x, y, w, h, placeholder, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.text = ""
    obj.placeholder = placeholder or ""
    obj.cursor = 0
    obj.selectionStart = 0
    obj.selectionEnd = 0

    -- Autocomplete features
    obj.suggestions = options.suggestions or {}
    obj.filteredSuggestions = {}
    obj.selectedSuggestion = -1
    obj.showSuggestions = false
    obj.maxSuggestions = options.maxSuggestions or 10
    obj.minQueryLength = options.minQueryLength or 1
    obj.fuzzyMatch = options.fuzzyMatch ~= false
    obj.caseSensitive = options.caseSensitive or false

    -- Visual options
    obj.suggestionHeight = options.suggestionHeight or 25
    obj.maxSuggestionsHeight = options.maxSuggestionsHeight or 200

    -- Events
    obj.onSuggestionSelect = options.onSuggestionSelect
    obj.onTextChange = options.onTextChange
    obj.onSuggestionFilter = options.onSuggestionFilter

    -- Validation
    obj.validator = options.validator
    obj.validationErrors = {}
    obj.isValid = true

    -- Input formatting
    obj.inputFilter = options.inputFilter -- function to filter input characters
    obj.formatter = options.formatter     -- function to format display text
    obj.maxLength = options.maxLength

    -- Accessibility
    obj.accessibilityLabel = obj.accessibilityLabel or "Autocomplete text input"
    obj.accessibilityHint = obj.accessibilityHint or "Type to see suggestions, use arrow keys to navigate"

    setmetatable(obj, self)
    return obj
end

function AutoComplete:update(dt)
    core.Base.update(self, dt)

    -- Auto-hide suggestions if not focused
    if not self.focused and self.showSuggestions then
        self.showSuggestions = false
        self.selectedSuggestion = -1
    end
end

function AutoComplete:draw()
    core.Base.draw(self)

    -- Input field background
    local bgColor = self.focused and core.theme.primaryHover or
        self.hovered and core.theme.secondary or
        core.theme.background

    if not self.isValid then
        bgColor = { 0.8, 0.3, 0.3, 0.3 } -- Red tint for invalid input
    end

    love.graphics.setColor(table.unpack(bgColor))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Border
    local borderColor = self.focused and core.focus.focusRingColor or
        not self.isValid and { 0.8, 0.3, 0.3 } or
        core.theme.border

    love.graphics.setColor(table.unpack(borderColor))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Text content
    self:_drawText()

    -- Suggestions dropdown
    if self.showSuggestions and #self.filteredSuggestions > 0 then
        self:_drawSuggestions()
    end

    -- Validation errors
    if not self.isValid and #self.validationErrors > 0 then
        self:_drawValidationErrors()
    end
end

function AutoComplete:_drawText()
    local displayText = self.text == "" and self.placeholder or self.text
    local textColor = self.text == "" and core.theme.textSecondary or core.theme.text

    if self.formatter and self.text ~= "" then
        displayText = self.formatter(self.text)
    end

    love.graphics.setColor(table.unpack(textColor))

    -- Setup clipping for text overflow
    love.graphics.push()
    love.graphics.intersectScissor(self.x + 5, self.y, self.w - 10, self.h)

    local font = love.graphics.getFont()
    local textY = self.y + self.h / 2 - font:getHeight() / 2

    -- Selection background
    if self.selectionStart ~= self.selectionEnd and self.focused then
        local selStart = math.min(self.selectionStart, self.selectionEnd)
        local selEnd = math.max(self.selectionStart, self.selectionEnd)
        local selText = self.text:sub(1, selStart)
        local selWidth = font:getWidth(self.text:sub(selStart + 1, selEnd))
        local selX = self.x + 5 + font:getWidth(selText)

        love.graphics.setColor(table.unpack(core.theme.accent))
        love.graphics.rectangle("fill", selX, textY, selWidth, font:getHeight())
    end

    love.graphics.setColor(table.unpack(textColor))
    love.graphics.print(displayText, self.x + 5, textY)

    -- Cursor
    if self.focused then
        local cursorX = self.x + 5 + font:getWidth(self.text:sub(1, self.cursor))
        love.graphics.setColor(table.unpack(core.theme.text))
        love.graphics.line(cursorX, textY, cursorX, textY + font:getHeight())
    end

    love.graphics.pop()
end

function AutoComplete:_drawSuggestions()
    local suggestionsHeight = math.min(#self.filteredSuggestions * self.suggestionHeight, self.maxSuggestionsHeight)
    local dropdownY = self.y + self.h + 2

    -- Dropdown background
    love.graphics.setColor(table.unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, dropdownY, self.w, suggestionsHeight)

    -- Dropdown border
    love.graphics.setColor(table.unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, dropdownY, self.w, suggestionsHeight)

    -- Setup clipping for scrollable suggestions
    love.graphics.push()
    love.graphics.intersectScissor(self.x, dropdownY, self.w, suggestionsHeight)

    -- Draw suggestions
    for i, suggestion in ipairs(self.filteredSuggestions) do
        if i > self.maxSuggestions then break end

        local itemY = dropdownY + (i - 1) * self.suggestionHeight

        -- Highlight selected suggestion
        if i - 1 == self.selectedSuggestion then
            love.graphics.setColor(unpack(core.theme.accent))
            love.graphics.rectangle("fill", self.x, itemY, self.w, self.suggestionHeight)
        end

        -- Suggestion text
        love.graphics.setColor(unpack(core.theme.text))
        local displayText = type(suggestion) == "table" and suggestion.text or tostring(suggestion)
        love.graphics.printf(displayText, self.x + 8, itemY + 4, self.w - 16, "left")

        -- Separator line
        if i < #self.filteredSuggestions and i < self.maxSuggestions then
            love.graphics.setColor(unpack(core.theme.border))
            love.graphics.line(self.x, itemY + self.suggestionHeight, self.x + self.w, itemY + self.suggestionHeight)
        end
    end

    love.graphics.pop()
end

function AutoComplete:_drawValidationErrors()
    local errorY = self.y + self.h + 5
    if self.showSuggestions and #self.filteredSuggestions > 0 then
        local suggestionsHeight = math.min(#self.filteredSuggestions * self.suggestionHeight, self.maxSuggestionsHeight)
        errorY = errorY + suggestionsHeight + 5
    end

    love.graphics.setColor(0.8, 0.3, 0.3, 1)
    local font = love.graphics.getFont()

    for i, error in ipairs(self.validationErrors) do
        love.graphics.print(error, self.x, errorY + (i - 1) * font:getHeight())
    end
end

function AutoComplete:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end

    -- Handle suggestion navigation
    if self.showSuggestions and #self.filteredSuggestions > 0 then
        if key == "down" then
            self.selectedSuggestion = math.min(self.selectedSuggestion + 1, #self.filteredSuggestions - 1)
            return true
        elseif key == "up" then
            self.selectedSuggestion = math.max(self.selectedSuggestion - 1, -1)
            return true
        elseif key == "return" or key == "tab" then
            if self.selectedSuggestion >= 0 then
                self:_selectSuggestion(self.selectedSuggestion + 1)
                return true
            end
        elseif key == "escape" then
            self.showSuggestions = false
            self.selectedSuggestion = -1
            return true
        end
    end

    -- Regular text input handling
    if key == "backspace" then
        if self.selectionStart ~= self.selectionEnd then
            self:_deleteSelection()
        elseif self.cursor > 0 then
            self.text = self.text:sub(1, self.cursor - 1) .. self.text:sub(self.cursor + 1)
            self.cursor = self.cursor - 1
        end
        self:_onTextChange()
    elseif key == "delete" then
        if self.selectionStart ~= self.selectionEnd then
            self:_deleteSelection()
        elseif self.cursor < #self.text then
            self.text = self.text:sub(1, self.cursor) .. self.text:sub(self.cursor + 2)
        end
        self:_onTextChange()
    elseif key == "left" then
        if love.keyboard.isDown("lshift", "rshift") then
            self.selectionEnd = math.max(0, self.selectionEnd - 1)
        else
            self.cursor = math.max(0, self.cursor - 1)
            self.selectionStart = self.cursor
            self.selectionEnd = self.cursor
        end
    elseif key == "right" then
        if love.keyboard.isDown("lshift", "rshift") then
            self.selectionEnd = math.min(#self.text, self.selectionEnd + 1)
        else
            self.cursor = math.min(#self.text, self.cursor + 1)
            self.selectionStart = self.cursor
            self.selectionEnd = self.cursor
        end
    elseif key == "home" then
        if love.keyboard.isDown("lshift", "rshift") then
            self.selectionEnd = 0
        else
            self.cursor = 0
            self.selectionStart = 0
            self.selectionEnd = 0
        end
    elseif key == "end" then
        if love.keyboard.isDown("lshift", "rshift") then
            self.selectionEnd = #self.text
        else
            self.cursor = #self.text
            self.selectionStart = self.cursor
            self.selectionEnd = self.cursor
        end
    elseif key == "return" or key == "kpenter" then
        if not self.showSuggestions then
            core.focusNext()
        end
    elseif key == "escape" then
        core.clearFocus()
    elseif key == "a" and love.keyboard.isDown("lctrl", "rctrl") then
        -- Select all
        self.selectionStart = 0
        self.selectionEnd = #self.text
        self.cursor = #self.text
    end

    return true
end

function AutoComplete:textinput(text)
    if not self.focused then return end

    -- Apply input filter
    if self.inputFilter and not self.inputFilter(text) then
        return
    end

    -- Check max length
    if self.maxLength and #self.text >= self.maxLength then
        return
    end

    -- Replace selection or insert text
    if self.selectionStart ~= self.selectionEnd then
        self:_deleteSelection()
    end

    self.text = self.text:sub(1, self.cursor) .. text .. self.text:sub(self.cursor + 1)
    self.cursor = self.cursor + #text
    self.selectionStart = self.cursor
    self.selectionEnd = self.cursor

    self:_onTextChange()
end

function AutoComplete:_onTextChange()
    -- Update suggestions
    self:_updateSuggestions()

    -- Validate input
    self:_validateInput()

    -- Trigger callback
    if self.onTextChange then
        self.onTextChange(self.text)
    end
end

function AutoComplete:_updateSuggestions()
    self.filteredSuggestions = {}
    self.selectedSuggestion = -1

    if #self.text < self.minQueryLength then
        self.showSuggestions = false
        return
    end

    local query = self.caseSensitive and self.text or self.text:lower()

    -- Custom suggestion filter
    if self.onSuggestionFilter then
        self.filteredSuggestions = self.onSuggestionFilter(self.text, self.suggestions)
    else
        -- Default filtering
        for _, suggestion in ipairs(self.suggestions) do
            local suggestionText = type(suggestion) == "table" and suggestion.text or tostring(suggestion)
            if not self.caseSensitive then
                suggestionText = suggestionText:lower()
            end

            if self.fuzzyMatch then
                if self:_fuzzyMatch(query, suggestionText) then
                    table.insert(self.filteredSuggestions, suggestion)
                end
            else
                if suggestionText:find(query, 1, true) == 1 then -- starts with query
                    table.insert(self.filteredSuggestions, suggestion)
                end
            end

            if #self.filteredSuggestions >= self.maxSuggestions then
                break
            end
        end
    end

    self.showSuggestions = #self.filteredSuggestions > 0
end

function AutoComplete:_fuzzyMatch(query, text)
    local queryIndex = 1
    local textIndex = 1

    while queryIndex <= #query and textIndex <= #text do
        if query:sub(queryIndex, queryIndex) == text:sub(textIndex, textIndex) then
            queryIndex = queryIndex + 1
        end
        textIndex = textIndex + 1
    end

    return queryIndex > #query
end

function AutoComplete:_validateInput()
    if self.validator then
        self.isValid, self.validationErrors = self.validator:validate(self.text)
    else
        self.isValid = true
        self.validationErrors = {}
    end
end

function AutoComplete:_selectSuggestion(index)
    if index > 0 and index <= #self.filteredSuggestions then
        local suggestion = self.filteredSuggestions[index]
        local suggestionText = type(suggestion) == "table" and suggestion.value or tostring(suggestion)

        self.text = suggestionText
        self.cursor = #self.text
        self.selectionStart = self.cursor
        self.selectionEnd = self.cursor

        self.showSuggestions = false
        self.selectedSuggestion = -1

        self:_validateInput()

        if self.onSuggestionSelect then
            self.onSuggestionSelect(suggestion, suggestionText)
        end
    end
end

function AutoComplete:_deleteSelection()
    local selStart = math.min(self.selectionStart, self.selectionEnd)
    local selEnd = math.max(self.selectionStart, self.selectionEnd)

    self.text = self.text:sub(1, selStart) .. self.text:sub(selEnd + 1)
    self.cursor = selStart
    self.selectionStart = selStart
    self.selectionEnd = selStart
end

function AutoComplete:mousepressed(x, y, button)
    if button ~= 1 then return false end

    -- Check if clicking on suggestions
    if self.showSuggestions and #self.filteredSuggestions > 0 then
        local suggestionsHeight = math.min(#self.filteredSuggestions * self.suggestionHeight, self.maxSuggestionsHeight)
        local dropdownY = self.y + self.h + 2

        if x >= self.x and x <= self.x + self.w and y >= dropdownY and y <= dropdownY + suggestionsHeight then
            local suggestionIndex = math.floor((y - dropdownY) / self.suggestionHeight) + 1
            if suggestionIndex <= #self.filteredSuggestions then
                self:_selectSuggestion(suggestionIndex)
                return true
            end
        end
    end

    -- Regular text input click handling
    if self:hitTest(x, y) then
        core.setFocus(self)

        -- Position cursor based on click
        local font = love.graphics.getFont()
        local relativeX = x - (self.x + 5)
        local textWidth = 0

        for i = 0, #self.text do
            local charWidth = font:getWidth(self.text:sub(1, i))
            if charWidth > relativeX then
                self.cursor = i
                break
            end
            self.cursor = i
        end

        self.selectionStart = self.cursor
        self.selectionEnd = self.cursor

        return true
    end

    return false
end

-- Public methods
function AutoComplete:setSuggestions(suggestions)
    self.suggestions = suggestions or {}
    if self.focused then
        self:_updateSuggestions()
    end
end

function AutoComplete:getText()
    return self.text
end

function AutoComplete:setText(text)
    self.text = text or ""
    self.cursor = #self.text
    self.selectionStart = self.cursor
    self.selectionEnd = self.cursor
    self:_onTextChange()
end

function AutoComplete:clearText()
    self:setText("")
end

return AutoComplete
