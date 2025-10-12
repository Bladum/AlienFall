--[[
    TextArea Widget
    
    A multi-line text input field.
    Features:
    - Multiple lines of text
    - Scrolling
    - Text selection
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local TextArea = setmetatable({}, {__index = BaseWidget})
TextArea.__index = TextArea

--[[
    Create a new text area
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param placeholder string - Placeholder text (optional)
    @return table - New text area instance
]]
function TextArea.new(x, y, width, height, placeholder)
    local self = BaseWidget.new(x, y, width, height, "textarea")
    setmetatable(self, TextArea)
    
    self.text = ""
    self.placeholder = placeholder or "Enter text..."
    self.cursorPos = 0
    self.scrollY = 0
    self.lineHeight = 20
    self.padding = 4
    
    return self
end

--[[
    Draw the text area
]]
function TextArea:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    local bgColor = self.enabled and self.backgroundColor or self.disabledColor
    Theme.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Set scissor for text clipping
    love.graphics.push()
    love.graphics.setScissor(self.x + self.padding, self.y + self.padding, 
                            self.width - self.padding * 2, self.height - self.padding * 2)
    
    -- Draw text or placeholder
    Theme.setFont(self.font)
    local font = Theme.getFont(self.font)
    
    if #self.text > 0 then
        local textColor = self.enabled and self.textColor or self.disabledTextColor
        Theme.setColor(textColor)
        
        -- Split text into lines
        local lines = {}
        for line in self.text:gmatch("[^\n]*\n?") do
            if line ~= "" then
                table.insert(lines, line:gsub("\n", ""))
            end
        end
        
        -- Draw each line
        for i, line in ipairs(lines) do
            local lineY = self.y + self.padding + (i - 1) * self.lineHeight - self.scrollY
            love.graphics.print(line, self.x + self.padding, lineY)
        end
        
        -- Draw cursor if focused
        if self.focused and self.enabled then
            local cursorLine = 1
            local cursorCol = self.cursorPos
            local charCount = 0
            
            for i, line in ipairs(lines) do
                if charCount + #line + 1 > self.cursorPos then
                    cursorLine = i
                    cursorCol = self.cursorPos - charCount
                    break
                end
                charCount = charCount + #line + 1
            end
            
            local cursorX = self.x + self.padding
            if cursorCol > 0 and lines[cursorLine] then
                cursorX = cursorX + font:getWidth(lines[cursorLine]:sub(1, cursorCol))
            end
            local cursorY = self.y + self.padding + (cursorLine - 1) * self.lineHeight - self.scrollY
            
            love.graphics.line(cursorX, cursorY, cursorX, cursorY + self.lineHeight)
        end
    else
        -- Draw placeholder
        Theme.setColor(self.disabledTextColor)
        love.graphics.print(self.placeholder, self.x + self.padding, self.y + self.padding)
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
    
    -- Draw border
    Theme.setColor(self.focused and self.activeColor or self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

--[[
    Handle mouse press
]]
function TextArea:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        self.focused = true
        return true
    end
    
    self.focused = false
    return false
end

--[[
    Handle text input
]]
function TextArea:textinput(text)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    -- Insert text at cursor position
    local before = self.text:sub(1, self.cursorPos)
    local after = self.text:sub(self.cursorPos + 1)
    self.text = before .. text .. after
    self.cursorPos = self.cursorPos + #text
    
    if self.onChange then
        self.onChange(self.text)
    end
    
    return true
end

--[[
    Handle key press
]]
function TextArea:keypressed(key)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    if key == "backspace" and self.cursorPos > 0 then
        local before = self.text:sub(1, self.cursorPos - 1)
        local after = self.text:sub(self.cursorPos + 1)
        self.text = before .. after
        self.cursorPos = self.cursorPos - 1
        
        if self.onChange then
            self.onChange(self.text)
        end
        
        return true
    elseif key == "return" then
        -- Insert newline
        local before = self.text:sub(1, self.cursorPos)
        local after = self.text:sub(self.cursorPos + 1)
        self.text = before .. "\n" .. after
        self.cursorPos = self.cursorPos + 1
        
        if self.onChange then
            self.onChange(self.text)
        end
        
        return true
    elseif key == "left" and self.cursorPos > 0 then
        self.cursorPos = self.cursorPos - 1
        return true
    elseif key == "right" and self.cursorPos < #self.text then
        self.cursorPos = self.cursorPos + 1
        return true
    end
    
    return false
end

--[[
    Set text content
    @param text string - New text content
]]
function TextArea:setText(text)
    self.text = text or ""
    self.cursorPos = #self.text
end

--[[
    Get text content
    @return string - Current text content
]]
function TextArea:getText()
    return self.text
end

return TextArea
