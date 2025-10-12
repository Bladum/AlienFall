--[[
    RadioButton Widget
    
    A radio button for mutually exclusive options.
    Features:
    - Selected/unselected states
    - Radio button groups
    - onChange event
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local RadioButton = setmetatable({}, {__index = BaseWidget})
RadioButton.__index = RadioButton

--[[
    Create a new radio button
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param label string - Radio button label
    @param group string - Group identifier (optional)
    @return table - New radio button instance
]]
function RadioButton.new(x, y, width, height, label, group)
    local self = BaseWidget.new(x, y, width, height, "radiobutton")
    setmetatable(self, RadioButton)
    
    self.label = label or "Radio"
    self.selected = false
    self.group = group or "default"
    
    return self
end

--[[
    Draw the radio button
]]
function RadioButton:draw()
    if not self.visible then
        return
    end
    
    local circleSize = math.min(self.height - 4, 18)
    local circleX = self.x + 2 + circleSize / 2
    local circleY = self.y + self.height / 2
    
    -- Draw radio circle background
    if self.enabled then
        Theme.setColor(self.backgroundColor)
    else
        Theme.setColor(self.disabledColor)
    end
    love.graphics.circle("fill", circleX, circleY, circleSize / 2)
    
    -- Draw radio circle border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.circle("line", circleX, circleY, circleSize / 2)
    
    -- Draw selection dot if selected
    if self.selected then
        if self.enabled then
            Theme.setColor(self.textColor)
        else
            Theme.setColor(self.disabledTextColor)
        end
        love.graphics.circle("fill", circleX, circleY, circleSize / 4)
    end
    
    -- Draw label
    Theme.setFont(self.font)
    if self.enabled then
        Theme.setColor(self.textColor)
    else
        Theme.setColor(self.disabledTextColor)
    end
    
    local textX = self.x + circleSize + 8
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.label, textX, textY)
end

--[[
    Handle mouse press
]]
function RadioButton:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        if not self.selected then
            self.selected = true
            
            if self.onChange then
                self.onChange(true)
            end
        end
        
        return true
    end
    
    return false
end

--[[
    Set selected state
    @param selected boolean - New selected state
]]
function RadioButton:setSelected(selected)
    if self.selected ~= selected then
        self.selected = selected
        
        if self.onChange then
            self.onChange(self.selected)
        end
    end
end

--[[
    Get selected state
    @return boolean - Current selected state
]]
function RadioButton:isSelected()
    return self.selected
end

return RadioButton
