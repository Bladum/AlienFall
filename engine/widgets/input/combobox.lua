--[[
    ComboBox Widget
    
    A combination of text input and dropdown.
    Features:
    - Editable text
    - Dropdown selection
    - Auto-complete suggestions
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local ComboBox = setmetatable({}, {__index = BaseWidget})
ComboBox.__index = ComboBox

--[[
    Create a new combo box
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New combo box instance
]]
function ComboBox.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "combobox")
    setmetatable(self, ComboBox)
    
    self.text = ""
    self.options = {}
    self.expanded = false
    self.selectedIndex = 0
    self.cursorPos = 0
    
    return self
end

--[[
    Draw the combo box
]]
function ComboBox:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
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
    
    -- Draw dropdown arrow
    local arrowX = self.x + self.width - 16
    local arrowY = self.y + self.height / 2
    love.graphics.polygon("fill",
        arrowX, arrowY - 3,
        arrowX + 6, arrowY - 3,
        arrowX + 3, arrowY + 3
    )
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw expanded options
    if self.expanded and #self.options > 0 then
        local optionHeight = self.height
        local maxVisible = 5
        local visibleCount = math.min(maxVisible, #self.options)
        local dropdownHeight = visibleCount * optionHeight
        
        -- Draw dropdown background
        Theme.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y + self.height, self.width, dropdownHeight)
        
        -- Draw dropdown border
        Theme.setColor(self.borderColor)
        love.graphics.rectangle("line", self.x, self.y + self.height, self.width, dropdownHeight)
        
        -- Draw options
        Theme.setFont(self.font)
        for i = 1, visibleCount do
            local option = self.options[i]
            local optionY = self.y + self.height + (i - 1) * optionHeight
            
            -- Highlight on hover
            local mx, my = love.mouse.getPosition()
            if mx >= self.x and mx < self.x + self.width and
               my >= optionY and my < optionY + optionHeight then
                Theme.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x, optionY, self.width, optionHeight)
            end
            
            -- Draw option text
            Theme.setColor(self.textColor)
            local textY = optionY + (optionHeight - textHeight) / 2
            love.graphics.print(option, self.x + 4, textY)
        end
    end
end

--[[
    Handle mouse press
]]
function ComboBox:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check if clicking main box
    if x >= self.x and x < self.x + self.width and
       y >= self.y and y < self.y + self.height then
        self.expanded = not self.expanded
        self.focused = true
        return true
    end
    
    -- Check if clicking an option
    if self.expanded then
        local optionHeight = self.height
        for i, option in ipairs(self.options) do
            local optionY = self.y + self.height + (i - 1) * optionHeight
            
            if x >= self.x and x < self.x + self.width and
               y >= optionY and y < optionY + optionHeight then
                self.text = option
                self.selectedIndex = i
                self.expanded = false
                
                if self.onChange then
                    self.onChange(option)
                end
                
                return true
            end
        end
    end
    
    return false
end

--[[
    Handle text input
]]
function ComboBox:textinput(text)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    self.text = self.text .. text
    self.cursorPos = #self.text
    
    return true
end

--[[
    Handle key press
]]
function ComboBox:keypressed(key)
    if not self.visible or not self.enabled or not self.focused then
        return false
    end
    
    if key == "backspace" and #self.text > 0 then
        self.text = self.text:sub(1, -2)
        self.cursorPos = #self.text
        return true
    end
    
    return false
end

return ComboBox
