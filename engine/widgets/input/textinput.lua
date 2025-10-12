--[[
    TextInput Widget
    
    Single-line text input field.
    Features:
    - Text entry and editing
    - Cursor positioning
    - Text selection
    - Copy/paste support
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local TextInput = setmetatable({}, {__index = BaseWidget})
TextInput.__index = TextInput

--[[
    Create a new text input
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param placeholder string - Placeholder text
    @return table - New text input instance
]]
function TextInput.new(x, y, width, height, placeholder)
    local self = BaseWidget.new(x, y, width, height, "textinput")
    setmetatable(self, TextInput)
    
    self.text = ""
    self.placeholder = placeholder or ""
    self.cursorPos = 0
    self.cursorVisible = true
    self.cursorTimer = 0
    self.cursorBlinkRate = 0.5
    self.maxLength = nil
    
    return self
end

--[[
    Update the text input
]]
function TextInput:update(dt)
    BaseWidget.update(self, dt)
    
    if not self.visible or not self.enabled then
        return
    end
    
    -- Blink cursor
    if self.focused then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= self.cursorBlinkRate then
            self.cursorVisible = not self.cursorVisible
            self.cursorTimer = 0
        end
    else
        self.cursorVisible = false
    end
end

--[[
    Draw the text input
]]
function TextInput:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    if self.focused then
        Theme.setColor(self.focusColor)
    else
        Theme.setColor(self.borderColor)
    end
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw text or placeholder
    Theme.setFont(self.font)
    local font = Theme.getFont(self.font)
    local textY = self.y + (self.height - font:getHeight()) / 2
    
    if self.text == "" and not self.focused then
        -- Draw placeholder
        Theme.setColor(self.placeholderColor)
        love.graphics.print(self.placeholder, self.x + self.padding, textY)
    else
        -- Draw text
        Theme.setColor(self.textColor)
        love.graphics.print(self.text, self.x + self.padding, textY)
        
        -- Draw cursor
        if self.focused and self.cursorVisible then
            local textBeforeCursor = string.sub(self.text, 1, self.cursorPos)
            local cursorX = self.x + self.padding + font:getWidth(textBeforeCursor)
            Theme.setColor(self.textColor)
            love.graphics.line(cursorX, textY, cursorX, textY + font:getHeight())
        end
    end
end

--[[
    Handle text input
]]
function TextInput:textinput(text)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    -- Check max length
    if self.maxLength and #self.text >= self.maxLength then
        return true
    end
    
    -- Insert text at cursor
    self.text = string.sub(self.text, 1, self.cursorPos) .. text .. string.sub(self.text, self.cursorPos + 1)
    self.cursorPos = self.cursorPos + #text
    
    if self.onChange then
        self.onChange(self, self.text)
    end
    
    return true
end

--[[
    Handle key presses
]]
function TextInput:keypressed(key)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    if key == "backspace" then
        if self.cursorPos > 0 then
            self.text = string.sub(self.text, 1, self.cursorPos - 1) .. string.sub(self.text, self.cursorPos + 1)
            self.cursorPos = self.cursorPos - 1
            if self.onChange then
                self.onChange(self, self.text)
            end
        end
        return true
    elseif key == "delete" then
        if self.cursorPos < #self.text then
            self.text = string.sub(self.text, 1, self.cursorPos) .. string.sub(self.text, self.cursorPos + 2)
            if self.onChange then
                self.onChange(self, self.text)
            end
        end
        return true
    elseif key == "left" then
        self.cursorPos = math.max(0, self.cursorPos - 1)
        self.cursorVisible = true
        self.cursorTimer = 0
        return true
    elseif key == "right" then
        self.cursorPos = math.min(#self.text, self.cursorPos + 1)
        self.cursorVisible = true
        self.cursorTimer = 0
        return true
    elseif key == "home" then
        self.cursorPos = 0
        return true
    elseif key == "end" then
        self.cursorPos = #self.text
        return true
    end
    
    return false
end

--[[
    Handle mouse press
]]
function TextInput:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        self.focused = true
        self.cursorVisible = true
        self.cursorTimer = 0
        
        -- Calculate cursor position from mouse click
        local font = Theme.getFont("default")
        local relX = x - (self.x + Theme.padding)
        self.cursorPos = 0
        
        for i = 1, #self.text do
            local textWidth = font:getWidth(string.sub(self.text, 1, i))
            if textWidth > relX then
                break
            end
            self.cursorPos = i
        end
        
        if self.onFocus then
            self.onFocus(self)
        end
        
        return true
    else
        if self.focused and self.onBlur then
            self.onBlur(self)
        end
        self.focused = false
    end
    
    return false
end

--[[
    Set text value
    @param text string - New text value
]]
function TextInput:setText(text)
    self.text = text
    self.cursorPos = #text
    if self.onChange then
        self.onChange(self, self.text)
    end
end

--[[
    Get text value
    @return string - Current text value
]]
function TextInput:getText()
    return self.text
end

--[[
    Set placeholder text
    @param placeholder string - Placeholder text
]]
function TextInput:setPlaceholder(placeholder)
    self.placeholder = placeholder
end

--[[
    Set maximum text length
    @param maxLength number - Maximum length (nil for unlimited)
]]
function TextInput:setMaxLength(maxLength)
    self.maxLength = maxLength
end

print("[TextInput] TextInput widget loaded")

return TextInput
