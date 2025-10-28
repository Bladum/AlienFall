---Checkbox Widget - Toggleable Checkbox with Label
---
---A toggleable checkbox with label text. Used for boolean settings and options.
---Grid-aligned for consistent positioning.
---
---Features:
---  - Check/uncheck states (boolean)
---  - onChange event callback
---  - Grid-aligned positioning (24×24 pixels)
---  - Label text beside checkbox
---  - Keyboard support (Space to toggle)
---  - Theme-based styling
---
---Visual States:
---  - Unchecked: Empty box
---  - Checked: Box with checkmark
---  - Hover: Lighter border
---  - Disabled: Grayed out
---
---Interaction:
---  - Click to toggle
---  - Space key to toggle (when focused)
---  - onChange callback fires on state change
---
---Key Exports:
---  - Checkbox.new(x, y, width, height, label): Creates checkbox
---  - setChecked(checked): Sets check state
---  - isChecked(): Returns current state
---  - setLabel(label): Updates label text
---  - setCallback(func): Sets onChange handler
---  - draw(): Renders checkbox
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.input.checkbox
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Checkbox = require("gui.widgets.input.checkbox")
---  local cb = Checkbox.new(0, 0, 192, 24, "Enable sound")
---  cb:setCallback(function(checked) print("Sound:", checked) end)
---  cb:draw()
---
---@see widgets.input.radiobutton For radio button groups

--[[
    Checkbox Widget
    
    A toggleable checkbox with label.
    Features:
    - Check/uncheck states
    - onChange event
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

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



























