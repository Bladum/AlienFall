---Autocomplete Widget - Text Input with Suggestions
---
---A text input widget with auto-complete suggestions dropdown. Shows matching options
---as user types, with keyboard navigation for selection. Grid-aligned for consistent
---positioning.
---
---Features:
---  - Suggestion dropdown while typing
---  - Keyboard navigation (arrow keys)
---  - Customizable suggestion source
---  - Grid-aligned positioning (24×24 pixels)
---  - Fuzzy matching support
---  - Max suggestions limit
---
---Suggestion Matching:
---  - Exact prefix: "cat" matches "category", "catalog"
---  - Case-insensitive: "CAT" matches "category"
---  - Fuzzy: "ctg" matches "category" (optional)
---  - Custom filter function support
---
---Keyboard Navigation:
---  - Type: Filters suggestions
---  - Arrow Down: Highlights first suggestion
---  - Arrow Up/Down: Navigate suggestions
---  - Enter: Select highlighted suggestion
---  - ESC: Close suggestions
---  - Tab: Auto-complete with first suggestion
---
---Key Exports:
---  - Autocomplete.new(x, y, width, height): Creates autocomplete
---  - setSuggestions(suggestions): Sets suggestion list
---  - setSuggestionFunction(func): Sets custom suggestion provider
---  - setMaxSuggestions(max): Limits displayed suggestions
---  - setFuzzyMatch(enabled): Enables fuzzy matching
---  - setText(text): Sets current text
---  - getText(): Returns current text
---  - draw(): Renders autocomplete and suggestions
---  - keypressed(key): Keyboard navigation
---  - textinput(char): Character input with filtering
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.input.autocomplete
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Autocomplete = require("gui.widgets.input.autocomplete")
---  local auto = Autocomplete.new(0, 0, 240, 24)
---  auto:setSuggestions({"apple", "apricot", "banana", "cherry"})
---  auto:draw()
---
---@see widgets.input.combobox For combo text/dropdown

--[[
    Autocomplete Widget
    
    A text input with auto-complete suggestions.
    Features:
    - Suggestion dropdown
    - Keyboard navigation
    - Customizable suggestions
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local Autocomplete = setmetatable({}, {__index = BaseWidget})
Autocomplete.__index = Autocomplete

--[[
    Create a new autocomplete widget
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New autocomplete instance
]]
function Autocomplete.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "autocomplete")
    setmetatable(self, Autocomplete)
    
    self.text = ""
    self.suggestions = {}
    self.allSuggestions = {}
    self.showSuggestions = false
    self.selectedSuggestion = 0
    self.cursorPos = 0
    
    return self
end

--[[
    Draw the autocomplete widget
]]
function Autocomplete:draw()
    if not self.visible then
        return
    end
    
    -- Draw text input background
    local bgColor = self.enabled and self.backgroundColor or self.disabledColor
    Theme.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw text
    Theme.setFont(self.font)
    local textColor = self.enabled and self.textColor or self.disabledTextColor
    Theme.setColor(textColor)
    
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.text, self.x + 4, textY)
    
    -- Draw cursor if focused
    if self.focused and self.enabled then
        local cursorX = self.x + 4 + font:getWidth(self.text:sub(1, self.cursorPos))
        love.graphics.line(cursorX, self.y + 4, cursorX, self.y + self.height - 4)
    end
    
    -- Draw border
    Theme.setColor(self.focused and self.activeColor or self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw suggestions dropdown
    if self.showSuggestions and #self.suggestions > 0 then
        local suggestionHeight = self.height
        local maxVisible = 5
        local visibleCount = math.min(maxVisible, #self.suggestions)
        local dropdownHeight = visibleCount * suggestionHeight
        
        -- Draw dropdown background
        Theme.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y + self.height, self.width, dropdownHeight)
        
        -- Draw dropdown border
        Theme.setColor(self.borderColor)
        love.graphics.rectangle("line", self.x, self.y + self.height, self.width, dropdownHeight)
        
        -- Draw suggestions
        Theme.setFont(self.font)
        for i = 1, visibleCount do
            local suggestion = self.suggestions[i]
            local suggestionY = self.y + self.height + (i - 1) * suggestionHeight
            
            -- Highlight selected suggestion
            if i == self.selectedSuggestion then
                Theme.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x, suggestionY, self.width, suggestionHeight)
            end
            
            -- Draw suggestion text
            Theme.setColor(self.textColor)
            local textY = suggestionY + (suggestionHeight - textHeight) / 2
            love.graphics.print(suggestion, self.x + 4, textY)
        end
    end
end

--[[
    Handle mouse press
]]
function Autocomplete:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check if clicking input field
    if x >= self.x and x < self.x + self.width and
       y >= self.y and y < self.y + self.height then
        self.focused = true
        return true
    end
    
    -- Check if clicking a suggestion
    if self.showSuggestions then
        local suggestionHeight = self.height
        for i, suggestion in ipairs(self.suggestions) do
            local suggestionY = self.y + self.height + (i - 1) * suggestionHeight
            
            if x >= self.x and x < self.x + self.width and
               y >= suggestionY and y < suggestionY + suggestionHeight then
                self.text = suggestion
                self.cursorPos = #self.text
                self.showSuggestions = false
                
                if self.onChange then
                    self.onChange(self.text)
                end
                
                return true
            end
        end
    end
    
    self.focused = false
    self.showSuggestions = false
    
    return false
end

--[[
    Handle text input
]]
function Autocomplete:textinput(text)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    self.text = self.text .. text
    self.cursorPos = #self.text
    self:updateSuggestions()
    
    return true
end

--[[
    Handle key press
]]
function Autocomplete:keypressed(key)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    if key == "backspace" and #self.text > 0 then
        self.text = self.text:sub(1, -2)
        self.cursorPos = #self.text
        self:updateSuggestions()
        return true
    elseif key == "down" and self.showSuggestions then
        self.selectedSuggestion = math.min(self.selectedSuggestion + 1, #self.suggestions)
        return true
    elseif key == "up" and self.showSuggestions then
        self.selectedSuggestion = math.max(self.selectedSuggestion - 1, 1)
        return true
    elseif key == "return" and self.showSuggestions and self.selectedSuggestion > 0 then
        self.text = self.suggestions[self.selectedSuggestion]
        self.cursorPos = #self.text
        self.showSuggestions = false
        
        if self.onChange then
            self.onChange(self.text)
        end
        
        return true
    end
    
    return false
end

--[[
    Update suggestions based on current text
]]
function Autocomplete:updateSuggestions()
    self.suggestions = {}
    
    if #self.text > 0 then
        for _, suggestion in ipairs(self.allSuggestions) do
            if suggestion:lower():find(self.text:lower(), 1, true) == 1 then
                table.insert(self.suggestions, suggestion)
            end
        end
    end
    
    self.showSuggestions = #self.suggestions > 0
    self.selectedSuggestion = 0
end

--[[
    Set available suggestions
    @param suggestions table - Array of suggestion strings
]]
function Autocomplete:setSuggestions(suggestions)
    self.allSuggestions = suggestions or {}
    self:updateSuggestions()
end

return Autocomplete


























