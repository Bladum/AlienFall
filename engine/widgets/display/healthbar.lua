--[[
    HealthBar Widget
    
    A specialized progress bar for displaying health/HP.
    Features:
    - Current/max health display
    - Color changes based on health level
    - Optional label
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local HealthBar = setmetatable({}, {__index = BaseWidget})
HealthBar.__index = HealthBar

--[[
    Create a new health bar
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New health bar instance
]]
function HealthBar.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "healthbar")
    setmetatable(self, HealthBar)
    
    self.currentHealth = 100
    self.maxHealth = 100
    self.label = ""
    self.showValues = true
    
    return self
end

--[[
    Draw the health bar
]]
function HealthBar:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Calculate health percentage
    local healthPercent = self.maxHealth > 0 and (self.currentHealth / self.maxHealth) or 0
    
    -- Determine fill color based on health level
    local fillColor
    if healthPercent > 0.6 then
        fillColor = {r = 0, g = 200, b = 100}  -- Green
    elseif healthPercent > 0.3 then
        fillColor = {r = 255, g = 200, b = 0}  -- Yellow
    else
        fillColor = {r = 255, g = 50, b = 50}  -- Red
    end
    
    -- Draw filled portion
    if healthPercent > 0 then
        love.graphics.setColor(fillColor.r / 255, fillColor.g / 255, fillColor.b / 255)
        local fillWidth = math.floor(self.width * healthPercent)
        love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height)
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw label and values
    if self.showValues or self.label ~= "" then
        Theme.setFont(self.font)
        Theme.setColor(self.textColor)
        
        local text = ""
        if self.label ~= "" then
            text = self.label .. ": "
        end
        if self.showValues then
            text = text .. self.currentHealth .. "/" .. self.maxHealth
        end
        
        local font = Theme.getFont(self.font)
        local textHeight = font:getHeight()
        local textY = self.y + (self.height - textHeight) / 2
        
        love.graphics.print(text, self.x + 4, textY)
    end
end

--[[
    Set health values
    @param current number - Current health
    @param max number - Maximum health (optional)
]]
function HealthBar:setHealth(current, max)
    self.currentHealth = math.max(0, current)
    if max then
        self.maxHealth = math.max(1, max)
    end
    self.currentHealth = math.min(self.currentHealth, self.maxHealth)
end

--[[
    Set label text
    @param label string - Label text
]]
function HealthBar:setLabel(label)
    self.label = label or ""
end

--[[
    Get current health
    @return number - Current health value
]]
function HealthBar:getCurrentHealth()
    return self.currentHealth
end

--[[
    Get max health
    @return number - Maximum health value
]]
function HealthBar:getMaxHealth()
    return self.maxHealth
end

return HealthBar
