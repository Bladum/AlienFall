--[[
    TurnIndicator Widget
    
    Displays current turn number and whose turn it is.
    Features:
    - Turn counter
    - Team/faction indicator
    - Time remaining (optional)
    - Turn phase display
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local TurnIndicator = setmetatable({}, {__index = BaseWidget})
TurnIndicator.__index = TurnIndicator

function TurnIndicator.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, TurnIndicator)
    
    self.turnNumber = 1
    self.currentTeam = "Player"
    self.phase = "Movement"
    self.timeRemaining = nil
    self.teamColor = {r = 100, g = 200, b = 255}
    
    return self
end

function TurnIndicator:draw()
    if not self.visible then
        return
    end
    
    -- Draw background with team color tint
    love.graphics.setColor(
        self.teamColor.r / 255 * 0.3,
        self.teamColor.g / 255 * 0.3,
        self.teamColor.b / 255 * 0.3
    )
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(
        self.teamColor.r / 255,
        self.teamColor.g / 255,
        self.teamColor.b / 255
    )
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    local currentY = self.y + 8
    
    -- Draw turn number
    Theme.setFont("large")
    Theme.setColor(self.textColor)
    local turnText = "TURN " .. self.turnNumber
    local font = Theme.getFont("large")
    local textX = self.x + (self.width - font:getWidth(turnText)) / 2
    love.graphics.print(turnText, textX, currentY)
    
    currentY = currentY + font:getHeight() + 4
    
    -- Draw current team
    Theme.setFont("default")
    font = Theme.getFont("default")
    local teamX = self.x + (self.width - font:getWidth(self.currentTeam)) / 2
    love.graphics.setColor(
        self.teamColor.r / 255,
        self.teamColor.g / 255,
        self.teamColor.b / 255
    )
    love.graphics.print(self.currentTeam, teamX, currentY)
    
    currentY = currentY + font:getHeight() + 4
    
    -- Draw phase
    Theme.setFont("small")
    Theme.setColor(self.textColor)
    font = Theme.getFont("small")
    local phaseX = self.x + (self.width - font:getWidth(self.phase)) / 2
    love.graphics.print(self.phase, phaseX, currentY)
    
    currentY = currentY + font:getHeight() + 4
    
    -- Draw time remaining if set
    if self.timeRemaining then
        local timeText = string.format("Time: %ds", self.timeRemaining)
        local timeX = self.x + (self.width - font:getWidth(timeText)) / 2
        love.graphics.print(timeText, timeX, currentY)
    end
end

function TurnIndicator:setTurn(turnNumber, team, phase)
    self.turnNumber = turnNumber or self.turnNumber
    self.currentTeam = team or self.currentTeam
    self.phase = phase or self.phase
end

function TurnIndicator:setTimeRemaining(seconds)
    self.timeRemaining = seconds
end

function TurnIndicator:setTeamColor(r, g, b)
    self.teamColor = {r = r, g = g, b = b}
end

function TurnIndicator:advanceTurn()
    self.turnNumber = self.turnNumber + 1
end

return TurnIndicator
