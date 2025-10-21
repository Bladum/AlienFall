---TurnIndicator Widget - Turn Counter and Team Display
---
---Displays current turn number and whose turn it is (player/AI, team/faction).
---Shows turn counter, team indicator, time remaining (optional), and turn phase.
---Grid-aligned for consistent UI positioning.
---
---Features:
---  - Turn counter (e.g., "Turn 5")
---  - Team/faction indicator (e.g., "Player Team")
---  - Time remaining display (optional, for timed turns)
---  - Turn phase display (movement, action, reaction, end)
---  - Grid-aligned positioning (24×24 pixels)
---  - Color-coded team indicators
---
---Display Modes:
---  - Simple: Turn number only
---  - Full: Turn + team + phase
---  - Timed: Turn + team + time remaining
---  - Detailed: All information
---
---Visual States:
---  - Player Turn: Highlighted (green/blue)
---  - AI Turn: Dimmed (gray)
---  - Time Warning: Yellow (< 30s remaining)
---  - Time Critical: Red (< 10s remaining)
---
---Key Exports:
---  - TurnIndicator.new(x, y, width, height): Creates turn indicator
---  - setTurn(turnNumber): Updates turn counter
---  - setTeam(teamName, color): Sets current team
---  - setPhase(phaseName): Sets turn phase
---  - setTimeRemaining(seconds): Sets time limit
---  - draw(): Renders turn indicator
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.advanced.turnindicator
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TurnIndicator = require("gui.widgets.advanced.turnindicator")
---  local indicator = TurnIndicator.new(0, 0, 192, 48)
---  indicator:setTurn(5)
---  indicator:setTeam("Player", {0, 128, 255})
---  indicator:setPhase("Movement")
---  indicator:draw()
---
---@see widgets.display.label For text display

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

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

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


























