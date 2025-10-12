--[[
    Checkbox Widget
    
    A toggleable checkbox with label.
    Features:
    - Check/uncheck states
    - onChange event
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.base")
local Theme = require("widgets.theme")

local Checkbox = setmetatable({}, {__index = BaseWidget})
Checkbox.__index = Checkbox

--[[
    Create a new checkbox
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @param label string - Checkbox label text
    @return table - New checkbox instance
]]
function Checkbox.new(x, y, width, height, label)
    local self = BaseWidget.new(x, y, width, height, "checkbox")
    setmetatable(self, Checkbox)
    
    self.label = label or "Checkbox"
    self.checked = false
    
    return self
end

--[[
    Draw the checkbox
]]
function Checkbox:draw()
    if not self.visible then
        return
    end
    
    local boxSize = math.min(self.height - 4, 20)
    local boxX = self.x + 2
    local boxY = self.y + (self.height - boxSize) / 2
    
    -- Draw checkbox box background
    if self.enabled then
        Theme.setColor(self.backgroundColor)
    else
        Theme.setColor(self.disabledColor)
    end
    love.graphics.rectangle("fill", boxX, boxY, boxSize, boxSize)
    
    -- Draw checkbox border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", boxX, boxY, boxSize, boxSize)
    
    -- Draw checkmark if checked
    if self.checked then
        if self.enabled then
            Theme.setColor(self.textColor)
        else
            Theme.setColor(self.disabledTextColor)
        end
        love.graphics.setLineWidth(2)
        love.graphics.line(
            boxX + 4, boxY + boxSize / 2,
            boxX + boxSize / 2, boxY + boxSize - 4,
            boxX + boxSize - 4, boxY + 4
        )
    end
    
    -- Draw label
    Theme.setFont(self.font)
    if self.enabled then
        Theme.setColor(self.textColor)
    else
        Theme.setColor(self.disabledTextColor)
    end
    
    local textX = boxX + boxSize + 8
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.label, textX, textY)
end

--[[
    Handle mouse press
]]
function Checkbox:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        self.checked = not self.checked
        
        if self.onChange then
            self.onChange(self.checked)
        end
        
        return true
    end
    
    return false
end

--[[
    Set checked state
    @param checked boolean - New checked state
]]
function Checkbox:setChecked(checked)
    if self.checked ~= checked then
        self.checked = checked
        
        if self.onChange then
            self.onChange(self.checked)
        end
    end
end

--[[
    Get checked state
    @return boolean - Current checked state
]]
function Checkbox:isChecked()
    return self.checked
end

return Checkbox
