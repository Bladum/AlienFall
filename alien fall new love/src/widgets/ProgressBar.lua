--- ProgressBar Widget
-- Displays horizontal progress bar with customizable colors
--
-- @classmod widgets.ProgressBar

-- GROK: ProgressBar shows visual progress (0-100%) with grid alignment
-- GROK: Grid-aligned widget using 20px grid system
-- GROK: Key methods: draw(), setValue(), setColors()
-- GROK: Used for research progress, construction progress, health bars

local class = require 'lib.Middleclass'

--- ProgressBar class
-- @type ProgressBar
local ProgressBar = class('ProgressBar')

--- Create a new ProgressBar
-- @param x X position (pixels)
-- @param y Y position (pixels)
-- @param width Width (pixels, should be multiple of 20)
-- @param height Height (pixels, should be multiple of 20)
-- @param options Optional configuration {barColor, bgColor, borderColor, showText}
-- @return ProgressBar instance
function ProgressBar:initialize(x, y, width, height, options)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    options = options or {}
    self.barColor = options.barColor or {0.2, 0.6, 1.0}
    self.bgColor = options.bgColor or {0.1, 0.1, 0.15}
    self.borderColor = options.borderColor or {0.4, 0.4, 0.5}
    self.showText = options.showText ~= false -- Default true
    self.textColor = options.textColor or {1, 1, 1}
    
    self.value = 0 -- 0-100
    self.maxValue = 100
end

--- Set progress value
-- @param value Current value (0-maxValue)
-- @param maxValue Optional max value (default 100)
function ProgressBar:setValue(value, maxValue)
    self.maxValue = maxValue or self.maxValue
    self.value = math.max(0, math.min(value, self.maxValue))
end

--- Get progress percentage
-- @return number Percentage (0-100)
function ProgressBar:getPercentage()
    if self.maxValue == 0 then return 0 end
    return (self.value / self.maxValue) * 100
end

--- Set bar color
-- @param r Red (0-1)
-- @param g Green (0-1)
-- @param b Blue (0-1)
function ProgressBar:setBarColor(r, g, b)
    self.barColor = {r, g, b}
end

--- Draw the progress bar
function ProgressBar:draw()
    -- Draw background
    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Draw progress
    local percentage = self:getPercentage()
    local fillWidth = (self.width * percentage) / 100
    
    if fillWidth > 0 then
        love.graphics.setColor(self.barColor)
        love.graphics.rectangle('fill', self.x, self.y, fillWidth, self.height)
    end
    
    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    -- Draw text
    if self.showText then
        local text = string.format("%.0f%%", percentage)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        
        love.graphics.setColor(self.textColor)
        love.graphics.print(
            text,
            self.x + (self.width - textWidth) / 2,
            self.y + (self.height - textHeight) / 2
        )
    end
end

--- Update (currently no-op, for future animations)
-- @param dt Delta time
function ProgressBar:update(dt)
    -- Future: smooth animations
end

--- Check if point is inside widget
-- @param x Point X
-- @param y Point Y
-- @return boolean Inside widget
function ProgressBar:contains(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

return ProgressBar
