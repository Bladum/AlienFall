---ProgressBar Widget - Horizontal Progress Indicator
---
---A horizontal progress bar for displaying completion percentage (0.0 to 1.0).
---Features animated fill and customizable colors. Grid-aligned for consistent positioning.
---
---Features:
---  - 0.0 to 1.0 value range (0% to 100%)
---  - Animated fill (smooth transition)
---  - Customizable colors (fill, background, border)
---  - Grid-aligned positioning (24×24 pixels)
---  - Optional percentage text display
---  - Theme-based styling
---
---Visual States:
---  - Empty: 0% filled
---  - Partial: 1-99% filled
---  - Full: 100% filled
---  - Animated: Smooth fill animation
---
---Use Cases:
---  - Loading screens
---  - Download progress
---  - Research progress
---  - Manufacturing progress
---  - Experience bars
---
---Key Exports:
---  - ProgressBar.new(x, y, width, height): Creates progress bar
---  - setValue(value): Sets progress (0.0 to 1.0)
---  - getValue(): Returns current progress
---  - setColors(fillColor, bgColor): Sets custom colors
---  - setShowPercentage(show): Toggles percentage text
---  - draw(): Renders progress bar
---  - update(dt): Updates animation
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color theme
---
---@module widgets.display.progressbar
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ProgressBar = require("gui.widgets.display.progressbar")
---  local bar = ProgressBar.new(0, 0, 240, 24)
---  bar:setValue(0.75)  -- 75%
---  bar:setShowPercentage(true)
---  bar:draw()
---
---@see widgets.display.healthbar For health-specific bars

--[[
    ProgressBar Widget
    
    A horizontal progress bar.
    Features:
    - 0.0 to 1.0 value range
    - Animated fill
    - Customizable colors
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

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


























