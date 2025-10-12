--[[
    ProgressBar Widget
    
    A horizontal progress bar.
    Features:
    - 0.0 to 1.0 value range
    - Animated fill
    - Customizable colors
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local ProgressBar = setmetatable({}, {__index = BaseWidget})
ProgressBar.__index = ProgressBar

--[[
    Create a new progress bar
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New progress bar instance
]]
function ProgressBar.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "progressbar")
    setmetatable(self, ProgressBar)
    
    self.value = 0.0  -- 0.0 to 1.0
    self.fillColor = {r = 0, g = 200, b = 100, a = 255}
    self.showPercentage = true
    
    return self
end

--[[
    Draw the progress bar
]]
function ProgressBar:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw filled portion
    if self.value > 0 then
        love.graphics.setColor(
            self.fillColor.r / 255,
            self.fillColor.g / 255,
            self.fillColor.b / 255,
            self.fillColor.a / 255
        )
        local fillWidth = math.floor(self.width * self.value)
        love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height)
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw percentage text
    if self.showPercentage then
        Theme.setFont(self.font)
        Theme.setColor(self.textColor)
        
        local percentage = math.floor(self.value * 100) .. "%"
        local font = Theme.getFont(self.font)
        local textWidth = font:getWidth(percentage)
        local textHeight = font:getHeight()
        local textX = self.x + (self.width - textWidth) / 2
        local textY = self.y + (self.height - textHeight) / 2
        
        love.graphics.print(percentage, textX, textY)
    end
end

--[[
    Set progress value
    @param value number - Progress value (0.0 to 1.0)
]]
function ProgressBar:setValue(value)
    self.value = math.max(0, math.min(1, value))
end

--[[
    Get progress value
    @return number - Current progress value
]]
function ProgressBar:getValue()
    return self.value
end

--[[
    Set fill color
    @param r number - Red (0-255)
    @param g number - Green (0-255)
    @param b number - Blue (0-255)
    @param a number - Alpha (0-255, optional)
]]
function ProgressBar:setFillColor(r, g, b, a)
    self.fillColor = {r = r, g = g, b = b, a = a or 255}
end

return ProgressBar
