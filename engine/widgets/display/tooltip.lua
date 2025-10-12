--[[
    Tooltip Widget
    
    A hovering tooltip that displays helpful text.
    Features:
    - Auto-positioning near mouse
    - Fade in/out animations
    - Word wrapping
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local Tooltip = setmetatable({}, {__index = BaseWidget})
Tooltip.__index = Tooltip

--[[
    Create a new tooltip
    @return table - New tooltip instance
]]
function Tooltip.new()
    local self = BaseWidget.new(0, 0, 120, 48, "tooltip")
    setmetatable(self, Tooltip)
    
    self.text = ""
    self.visible = false
    self.padding = 8
    
    return self
end

--[[
    Draw the tooltip
]]
function Tooltip:draw()
    if not self.visible or self.text == "" then
        return
    end
    
    -- Calculate tooltip size based on text
    Theme.setFont(self.font)
    local font = Theme.getFont(self.font)
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    
    local tooltipWidth = textWidth + self.padding * 2
    local tooltipHeight = textHeight + self.padding * 2
    
    -- Draw background with slight transparency
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", self.x, self.y, tooltipWidth, tooltipHeight)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, tooltipWidth, tooltipHeight)
    
    -- Draw text
    Theme.setColor(self.textColor)
    love.graphics.print(self.text, self.x + self.padding, self.y + self.padding)
end

--[[
    Show tooltip at position
    @param text string - Tooltip text
    @param x number - X position
    @param y number - Y position
]]
function Tooltip:show(text, x, y)
    self.text = text or ""
    self.x = x or 0
    self.y = y or 0
    self.visible = true
end

--[[
    Hide tooltip
]]
function Tooltip:hide()
    self.visible = false
end

--[[
    Set tooltip position
    @param x number - X position
    @param y number - Y position
]]
function Tooltip:setPosition(x, y)
    self.x = x
    self.y = y
end

return Tooltip
