--[[
    UnitCard Widget
    
    Displays unit information in a card format for tactical games.
    Features:
    - Unit portrait/icon
    - Name and rank
    - Health bar
    - Stats display
    - Action points indicator
    - Equipment slots
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local UnitCard = setmetatable({}, {__index = BaseWidget})
UnitCard.__index = UnitCard

--[[
    Create a new unit card
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New unit card instance
]]
function UnitCard.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, UnitCard)
    
    -- Unit data
    self.unitName = "Soldier"
    self.rank = "Private"
    self.health = 100
    self.maxHealth = 100
    self.actionPoints = 8
    self.maxActionPoints = 10
    self.portrait = nil
    self.stats = {
        accuracy = 75,
        defense = 50,
        mobility = 8
    }
    self.equipment = {}
    self.selected = false
    
    -- Card layout
    self.portraitSize = 48
    self.padding = 8
    
    return self
end

--[[
    Draw the unit card
]]
function UnitCard:draw()
    if not self.visible then
        return
    end
    
    -- Draw card background
    if self.selected then
        Theme.setColor(self.activeColor)
    else
        Theme.setColor(self.backgroundColor)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border (highlight if selected)
    if self.selected then
        love.graphics.setLineWidth(3)
        Theme.setColor(self.activeColor)
    else
        love.graphics.setLineWidth(self.borderWidth)
        Theme.setColor(self.borderColor)
    end
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    local currentY = self.y + self.padding
    
    -- Draw portrait placeholder (if no image, draw colored box)
    local portraitX = self.x + self.padding
    if self.portrait then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.portrait, portraitX, currentY, 0, 
                          self.portraitSize / self.portrait:getWidth(),
                          self.portraitSize / self.portrait:getHeight())
    else
        -- Draw placeholder
        Theme.setColor(self.hoverColor)
        love.graphics.rectangle("fill", portraitX, currentY, self.portraitSize, self.portraitSize)
        Theme.setColor(self.borderColor)
        love.graphics.rectangle("line", portraitX, currentY, self.portraitSize, self.portraitSize)
    end
    
    -- Draw name and rank
    local textX = portraitX + self.portraitSize + self.padding
    Theme.setFont("default")
    Theme.setColor(self.textColor)
    love.graphics.print(self.unitName, textX, currentY)
    
    Theme.setFont("small")
    Theme.setColor(self.disabledTextColor)
    love.graphics.print(self.rank, textX, currentY + 16)
    
    currentY = currentY + self.portraitSize + self.padding
    
    -- Draw health bar
    local healthBarWidth = self.width - self.padding * 2
    local healthBarHeight = 20
    local healthPercent = self.maxHealth > 0 and (self.health / self.maxHealth) or 0
    
    -- Health bar background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x + self.padding, currentY, healthBarWidth, healthBarHeight)
    
    -- Health bar fill (color based on health level)
    local healthColor
    if healthPercent > 0.6 then
        healthColor = {0, 0.8, 0.4}  -- Green
    elseif healthPercent > 0.3 then
        healthColor = {1, 0.8, 0}    -- Yellow
    else
        healthColor = {1, 0.2, 0.2}  -- Red
    end
    love.graphics.setColor(healthColor[1], healthColor[2], healthColor[3])
    love.graphics.rectangle("fill", self.x + self.padding, currentY, 
                           healthBarWidth * healthPercent, healthBarHeight)
    
    -- Health bar border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x + self.padding, currentY, healthBarWidth, healthBarHeight)
    
    -- Health text
    Theme.setFont("small")
    Theme.setColor(self.textColor)
    local healthText = string.format("HP: %d/%d", self.health, self.maxHealth)
    love.graphics.print(healthText, self.x + self.padding + 4, currentY + 4)
    
    currentY = currentY + healthBarHeight + self.padding
    
    -- Draw action points
    local apBarWidth = healthBarWidth
    local apBarHeight = 16
    local apPercent = self.maxActionPoints > 0 and (self.actionPoints / self.maxActionPoints) or 0
    
    -- AP bar background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x + self.padding, currentY, apBarWidth, apBarHeight)
    
    -- AP bar fill
    love.graphics.setColor(0.2, 0.6, 1)  -- Blue
    love.graphics.rectangle("fill", self.x + self.padding, currentY, 
                           apBarWidth * apPercent, apBarHeight)
    
    -- AP bar border
    Theme.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x + self.padding, currentY, apBarWidth, apBarHeight)
    
    -- AP text
    Theme.setColor(self.textColor)
    local apText = string.format("AP: %d/%d", self.actionPoints, self.maxActionPoints)
    love.graphics.print(apText, self.x + self.padding + 4, currentY + 2)
    
    currentY = currentY + apBarHeight + self.padding
    
    -- Draw stats
    Theme.setFont("small")
    Theme.setColor(self.textColor)
    love.graphics.print("ACC: " .. self.stats.accuracy .. "%", self.x + self.padding, currentY)
    love.graphics.print("DEF: " .. self.stats.defense, self.x + self.padding + 80, currentY)
    love.graphics.print("MOV: " .. self.stats.mobility, self.x + self.padding + 160, currentY)
end

--[[
    Set unit data
    @param unitData table - Unit data {name, rank, health, maxHealth, etc.}
]]
function UnitCard:setUnit(unitData)
    self.unitName = unitData.name or "Soldier"
    self.rank = unitData.rank or "Private"
    self.health = unitData.health or 100
    self.maxHealth = unitData.maxHealth or 100
    self.actionPoints = unitData.actionPoints or 8
    self.maxActionPoints = unitData.maxActionPoints or 10
    self.portrait = unitData.portrait
    self.stats = unitData.stats or {accuracy = 75, defense = 50, mobility = 8}
    self.equipment = unitData.equipment or {}
end

--[[
    Handle mouse press
]]
function UnitCard:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if self:containsPoint(x, y) and button == 1 then
        self.selected = not self.selected
        
        if self.onClick then
            self.onClick(self)
        end
        
        return true
    end
    
    return false
end

--[[
    Set selected state
    @param selected boolean - Selected state
]]
function UnitCard:setSelected(selected)
    self.selected = selected
end

--[[
    Update unit health
    @param health number - New health value
]]
function UnitCard:setHealth(health)
    self.health = math.max(0, math.min(health, self.maxHealth))
end

--[[
    Update action points
    @param ap number - New action points value
]]
function UnitCard:setActionPoints(ap)
    self.actionPoints = math.max(0, math.min(ap, self.maxActionPoints))
end

return UnitCard
