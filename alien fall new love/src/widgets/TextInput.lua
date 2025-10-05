--- TextInput Widget
-- Single-line text input field with cursor and selection
--
-- @classmod widgets.TextInput

-- GROK: TextInput provides single-line text editing with grid alignment
-- GROK: Grid-aligned widget using 20px grid system
-- GROK: Key methods: draw(), textinput(), keypressed(), getText(), setText()
-- GROK: Used for save names, search filters, numeric inputs

local class = require 'lib.Middleclass'

--- TextInput class
-- @type TextInput
local TextInput = class('TextInput')

--- Create a new TextInput
-- @param x X position (pixels)
-- @param y Y position (pixels)
-- @param width Width (pixels, multiple of 20)
-- @param height Height (pixels, multiple of 20)
-- @param options Optional configuration {placeholder, maxLength, numeric}
-- @return TextInput instance
function TextInput:initialize(x, y, width, height, options)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    options = options or {}
    self.text = ""
    self.placeholder = options.placeholder or "Enter text..."
    self.maxLength = options.maxLength or 32
    self.numeric = options.numeric or false
    
    self.focused = false
    self.cursorPos = 0
    self.cursorBlink = 0
    self.cursorVisible = true
    
    -- Colors
    self.bgColor = {0.1, 0.1, 0.15}
    self.focusedBgColor = {0.15, 0.15, 0.2}
    self.borderColor = {0.4, 0.4, 0.5}
    self.focusedBorderColor = {0.5, 0.7, 1.0}
    self.textColor = {1, 1, 1}
    self.placeholderColor = {0.5, 0.5, 0.5}
end

--- Set text
-- @param text New text value
function TextInput:setText(text)
    self.text = text:sub(1, self.maxLength)
    self.cursorPos = #self.text
end

--- Get text
-- @return string Current text
function TextInput:getText()
    return self.text
end

--- Set focused state
-- @param focused Focused state
function TextInput:setFocused(focused)
    self.focused = focused
    if focused then
        self.cursorBlink = 0
        self.cursorVisible = true
    end
end

--- Handle text input
-- @param char Character entered
function TextInput:textinput(char)
    if not self.focused then return end
    
    -- Filter numeric if needed
    if self.numeric and not char:match("%d") then
        return
    end
    
    -- Check max length
    if #self.text >= self.maxLength then
        return
    end
    
    -- Insert character at cursor position
    self.text = self.text:sub(1, self.cursorPos) .. char .. self.text:sub(self.cursorPos + 1)
    self.cursorPos = self.cursorPos + 1
    
    -- Reset cursor blink
    self.cursorBlink = 0
    self.cursorVisible = true
end

--- Handle key press
-- @param key Key name
function TextInput:keypressed(key)
    if not self.focused then return end
    
    if key == 'backspace' then
        if self.cursorPos > 0 then
            self.text = self.text:sub(1, self.cursorPos - 1) .. self.text:sub(self.cursorPos + 1)
            self.cursorPos = self.cursorPos - 1
        end
    elseif key == 'delete' then
        if self.cursorPos < #self.text then
            self.text = self.text:sub(1, self.cursorPos) .. self.text:sub(self.cursorPos + 2)
        end
    elseif key == 'left' then
        self.cursorPos = math.max(0, self.cursorPos - 1)
    elseif key == 'right' then
        self.cursorPos = math.min(#self.text, self.cursorPos + 1)
    elseif key == 'home' then
        self.cursorPos = 0
    elseif key == 'end' then
        self.cursorPos = #self.text
    end
    
    -- Reset cursor blink
    self.cursorBlink = 0
    self.cursorVisible = true
end

--- Update widget
-- @param dt Delta time
function TextInput:update(dt)
    if self.focused then
        -- Blink cursor
        self.cursorBlink = self.cursorBlink + dt
        if self.cursorBlink >= 0.5 then
            self.cursorVisible = not self.cursorVisible
            self.cursorBlink = 0
        end
    end
end

--- Draw widget
function TextInput:draw()
    -- Draw background
    local bgColor = self.focused and self.focusedBgColor or self.bgColor
    love.graphics.setColor(bgColor)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Draw border
    local borderColor = self.focused and self.focusedBorderColor or self.borderColor
    love.graphics.setColor(borderColor)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    -- Draw text or placeholder
    local font = love.graphics.getFont()
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    local textX = self.x + 8
    
    if #self.text > 0 then
        love.graphics.setColor(self.textColor)
        love.graphics.print(self.text, textX, textY)
        
        -- Draw cursor
        if self.focused and self.cursorVisible then
            local cursorX = textX + font:getWidth(self.text:sub(1, self.cursorPos))
            love.graphics.line(cursorX, textY, cursorX, textY + textHeight)
        end
    else
        -- Draw placeholder
        love.graphics.setColor(self.placeholderColor)
        love.graphics.print(self.placeholder, textX, textY)
    end
end

--- Handle mouse press
-- @param mx Mouse X
-- @param my Mouse Y
-- @param button Mouse button
-- @return boolean Handled
function TextInput:mousepressed(mx, my, button)
    if button ~= 1 then return false end
    
    local wasInside = self:contains(mx, my)
    self:setFocused(wasInside)
    
    if wasInside then
        -- Calculate cursor position from click
        local font = love.graphics.getFont()
        local clickX = mx - (self.x + 8)
        
        -- Find closest character position
        local bestPos = 0
        local bestDist = math.abs(clickX)
        
        for i = 1, #self.text do
            local textWidth = font:getWidth(self.text:sub(1, i))
            local dist = math.abs(clickX - textWidth)
            if dist < bestDist then
                bestDist = dist
                bestPos = i
            end
        end
        
        self.cursorPos = bestPos
        self.cursorBlink = 0
        self.cursorVisible = true
    end
    
    return wasInside
end

--- Check if point is inside widget
-- @param x Point X
-- @param y Point Y
-- @return boolean Inside widget
function TextInput:contains(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

return TextInput
