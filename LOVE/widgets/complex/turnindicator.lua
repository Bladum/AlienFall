--[[
widgets/turnindicator.lua
TurnIndicator widget for turn-based game state and timers


Visual control for displaying and managing turn-based game state, timers, and player information.
Essential for turn-based strategy games with multiple players and time limits.

PURPOSE:
- Display and control turn-related information in turn-based games
- Show current turn number, active player/faction, and game phase
- Provide timer functionality with visual warnings for time pressure
- Enable quick actions like end turn and undo for better UX

KEY FEATURES:
- Current turn number and player/faction display
- Optional turn timer with countdown and visual warnings
- Phase indicators for different game stages
- End-turn and undo controls with customizable actions
- Configurable layout (horizontal/vertical) and positioning
- Animated transitions between turns and phases
- Visual feedback for low time remaining
- Accessibility features for screen readers
- Integration with game state management
- Customizable themes and visual styling

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Button = require("widgets.common.button")
local Label = require("widgets.common.label")

local TurnIndicator = {}
TurnIndicator.__index = TurnIndicator
setmetatable(TurnIndicator, { __index = core.Base })

function TurnIndicator:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Turn state
    obj.currentTurn = (options and options.currentTurn) or 1
    obj.currentPlayer = (options and options.currentPlayer) or "Player"
    obj.maxTurns = (options and options.maxTurns) or nil           -- nil for unlimited
    obj.turnTimeLimit = (options and options.turnTimeLimit) or nil -- seconds
    obj.currentTurnTime = 0
    obj.turnPhase = (options and options.turnPhase) or "action"    -- "action", "movement", "end"

    -- Player/faction information
    obj.players = (options and options.players) or {}
    obj.currentPlayerIndex = 1

    -- Visual configuration
    obj.showTurnNumber = (options and options.showTurnNumber) ~= false
    obj.showPlayerName = (options and options.showPlayerName) ~= false
    obj.showTimer = (options and options.showTimer) ~= false
    obj.showPhase = (options and options.showPhase) ~= false
    obj.showEndTurnButton = (options and options.showEndTurnButton) ~= false
    obj.showUndoButton = (options and options.showUndoButton) ~= false

    -- Layout properties
    obj.orientation = (options and options.orientation) or "horizontal" -- "horizontal" or "vertical"
    obj.padding = (options and options.padding) or { 8, 8, 8, 8 }
    obj.spacing = (options and options.spacing) or 8
    obj.buttonWidth = (options and options.buttonWidth) or 80
    obj.buttonHeight = (options and options.buttonHeight) or 32

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundLight
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.timerColor = (options and options.timerColor) or { 1, 1, 1 }
    obj.warningColor = (options and options.warningColor) or { 1, 0.8, 0.2 }
    obj.criticalColor = (options and options.criticalColor) or { 1, 0.2, 0.2 }
    obj.showBorder = (options and options.showBorder) ~= false
    obj.borderRadius = (options and options.borderRadius) or 4

    -- Player colors
    obj.playerColors = (options and options.playerColors) or {
        { 0.2, 0.8, 0.2 }, -- Green
        { 0.8, 0.2, 0.2 }, -- Red
        { 0.2, 0.2, 0.8 }, -- Blue
        { 0.8, 0.8, 0.2 }, -- Yellow
        { 0.8, 0.2, 0.8 }, -- Magenta
        { 0.2, 0.8, 0.8 }, -- Cyan
        { 0.8, 0.6, 0.2 }, -- Orange
        { 0.6, 0.2, 0.8 }  -- Purple
    }

    -- Timer settings
    obj.timerWarningThreshold = (options and options.timerWarningThreshold) or 10  -- seconds
    obj.timerCriticalThreshold = (options and options.timerCriticalThreshold) or 5 -- seconds
    obj.pauseTimer = false
    obj.timerRunning = false

    -- Animation and effects
    obj.animateTransition = (options and options.animateTransition) ~= false
    obj.pulseOnTimeWarning = (options and options.pulseOnTimeWarning) ~= false
    obj.transitionEffect = nil
    obj.warningEffect = nil

    -- Turn history and undo
    obj.turnHistory = {}
    obj.maxUndoSteps = (options and options.maxUndoSteps) or 10
    obj.canUndo = false

    -- Phase information
    obj.phases = (options and options.phases) or {
        { id = "movement", name = "Movement", color = { 0.2, 0.8, 0.2 } },
        { id = "action",   name = "Action",   color = { 0.8, 0.4, 0.2 } },
        { id = "end",      name = "End Turn", color = { 0.6, 0.6, 0.6 } }
    }

    -- Components
    obj.components = {}

    -- Callbacks
    obj.onTurnEnd = options and options.onTurnEnd
    obj.onPlayerChange = options and options.onPlayerChange
    obj.onPhaseChange = options and options.onPhaseChange
    obj.onTimerExpired = options and options.onTimerExpired
    obj.onUndo = options and options.onUndo

    setmetatable(obj, self)
    obj:_buildComponents()
    return obj
end

function TurnIndicator:_buildComponents()
    self.components = {}

    local currentX = self.x + self.padding[4]
    local currentY = self.y + self.padding[1]
    local availableWidth = self.w - self.padding[2] - self.padding[4]
    local availableHeight = self.h - self.padding[1] - self.padding[3]

    if self.orientation == "horizontal" then
        self:_buildHorizontalLayout(currentX, currentY, availableWidth, availableHeight)
    else
        self:_buildVerticalLayout(currentX, currentY, availableWidth, availableHeight)
    end
end

function TurnIndicator:_buildHorizontalLayout(x, y, w, h)
    local currentX = x
    local labelHeight = math.min(24, h / 3)

    -- Turn number
    if self.showTurnNumber then
        local turnWidth = 100
        local turnText = self.maxTurns and
            string.format("Turn %d/%d", self.currentTurn, self.maxTurns) or
            string.format("Turn %d", self.currentTurn)

        local turnLabel = Label:new(currentX, y, turnWidth, labelHeight, {
            text = turnText,
            font = core.theme.fontBold,
            align = "left",
            valign = "center"
        })

        table.insert(self.components, {
            type = "component",
            component = turnLabel
        })

        currentX = currentX + turnWidth + self.spacing
    end

    -- Player name and color
    if self.showPlayerName then
        local playerWidth = 120
        local player = self:_getCurrentPlayer()
        local playerColor = self:_getCurrentPlayerColor()

        local playerLabel = Label:new(currentX, y, playerWidth, labelHeight, {
            text = player.name or self.currentPlayer,
            font = core.theme.fontBold,
            color = playerColor,
            align = "left",
            valign = "center"
        })

        table.insert(self.components, {
            type = "component",
            component = playerLabel
        })

        currentX = currentX + playerWidth + self.spacing
    end

    -- Phase indicator
    if self.showPhase then
        local phaseWidth = 80
        local phase = self:_getCurrentPhase()

        local phaseLabel = Label:new(currentX, y, phaseWidth, labelHeight, {
            text = phase.name,
            color = phase.color,
            align = "left",
            valign = "center"
        })

        table.insert(self.components, {
            type = "component",
            component = phaseLabel
        })

        currentX = currentX + phaseWidth + self.spacing
    end

    -- Timer
    if self.showTimer and self.turnTimeLimit then
        local timerWidth = 60

        table.insert(self.components, {
            type = "timer",
            x = currentX,
            y = y,
            w = timerWidth,
            h = labelHeight
        })

        currentX = currentX + timerWidth + self.spacing
    end

    -- Buttons row
    local buttonY = y + labelHeight + 4
    local buttonCurrentX = x

    -- Undo button
    if self.showUndoButton then
        local undoButton = Button:new(buttonCurrentX, buttonY, self.buttonWidth, self.buttonHeight, {
            text = "Undo",
            variant = self.canUndo and "secondary" or "disabled",
            fontSize = 12,
            onClick = function()
                if self.canUndo then
                    self:undo()
                end
            end
        })

        table.insert(self.components, {
            type = "component",
            component = undoButton
        })

        buttonCurrentX = buttonCurrentX + self.buttonWidth + self.spacing
    end

    -- End turn button
    if self.showEndTurnButton then
        local endTurnButton = Button:new(buttonCurrentX, buttonY, self.buttonWidth, self.buttonHeight, {
            text = "End Turn",
            variant = "primary",
            fontSize = 12,
            onClick = function()
                self:endTurn()
            end
        })

        table.insert(self.components, {
            type = "component",
            component = endTurnButton
        })
    end
end

function TurnIndicator:_buildVerticalLayout(x, y, w, h)
    local currentY = y
    local labelHeight = 20

    -- Turn number
    if self.showTurnNumber then
        local turnText = self.maxTurns and
            string.format("Turn %d/%d", self.currentTurn, self.maxTurns) or
            string.format("Turn %d", self.currentTurn)

        local turnLabel = Label:new(x, currentY, w, labelHeight, {
            text = turnText,
            font = core.theme.fontBold,
            align = "center",
            valign = "center"
        })

        table.insert(self.components, {
            type = "component",
            component = turnLabel
        })

        currentY = currentY + labelHeight + self.spacing
    end

    -- Player info
    if self.showPlayerName then
        local player = self:_getCurrentPlayer()
        local playerColor = self:_getCurrentPlayerColor()

        local playerLabel = Label:new(x, currentY, w, labelHeight, {
            text = player.name or self.currentPlayer,
            font = core.theme.fontBold,
            color = playerColor,
            align = "center",
            valign = "center"
        })

        table.insert(self.components, {
            type = "component",
            component = playerLabel
        })

        currentY = currentY + labelHeight + self.spacing
    end

    -- Phase
    if self.showPhase then
        local phase = self:_getCurrentPhase()

        local phaseLabel = Label:new(x, currentY, w, labelHeight, {
            text = phase.name,
            color = phase.color,
            align = "center",
            valign = "center"
        })

        table.insert(self.components, {
            type = "component",
            component = phaseLabel
        })

        currentY = currentY + labelHeight + self.spacing
    end

    -- Timer
    if self.showTimer and self.turnTimeLimit then
        table.insert(self.components, {
            type = "timer",
            x = x,
            y = currentY,
            w = w,
            h = labelHeight
        })

        currentY = currentY + labelHeight + self.spacing
    end

    -- Buttons
    if self.showUndoButton then
        local undoButton = Button:new(x, currentY, w, self.buttonHeight, {
            text = "Undo",
            variant = self.canUndo and "secondary" or "disabled",
            fontSize = 12,
            onClick = function()
                if self.canUndo then
                    self:undo()
                end
            end
        })

        table.insert(self.components, {
            type = "component",
            component = undoButton
        })

        currentY = currentY + self.buttonHeight + self.spacing
    end

    if self.showEndTurnButton then
        local endTurnButton = Button:new(x, currentY, w, self.buttonHeight, {
            text = "End Turn",
            variant = "primary",
            fontSize = 12,
            onClick = function()
                self:endTurn()
            end
        })

        table.insert(self.components, {
            type = "component",
            component = endTurnButton
        })
    end
end

function TurnIndicator:_getCurrentPlayer()
    if #self.players > 0 then
        return self.players[self.currentPlayerIndex] or {}
    end
    return { name = self.currentPlayer }
end

function TurnIndicator:_getCurrentPlayerColor()
    local playerIndex = self.currentPlayerIndex
    if playerIndex > 0 and playerIndex <= #self.playerColors then
        return self.playerColors[playerIndex]
    end
    return { 1, 1, 1 }
end

function TurnIndicator:_getCurrentPhase()
    for _, phase in ipairs(self.phases) do
        if phase.id == self.turnPhase then
            return phase
        end
    end
    return { id = "unknown", name = "Unknown", color = { 0.5, 0.5, 0.5 } }
end

function TurnIndicator:startTurn()
    self.currentTurnTime = 0
    self.timerRunning = true
    self.pauseTimer = false
    self.warningEffect = nil

    -- Save turn state for undo
    self:_saveTurnState()
end

function TurnIndicator:endTurn()
    -- Save current state before ending turn
    self:_saveTurnState()

    -- Trigger transition effect
    if self.animateTransition then
        self:_triggerTransitionEffect()
    end

    -- Move to next player/turn
    self:_advanceTurn()

    -- Callback
    if self.onTurnEnd then
        self.onTurnEnd(self.currentTurn, self.currentPlayer, self)
    end

    self:startTurn()
end

function TurnIndicator:_advanceTurn()
    if #self.players > 0 then
        self.currentPlayerIndex = self.currentPlayerIndex + 1
        if self.currentPlayerIndex > #self.players then
            self.currentPlayerIndex = 1
            self.currentTurn = self.currentTurn + 1
        end

        local player = self.players[self.currentPlayerIndex]
        self.currentPlayer = player.name or ("Player " .. self.currentPlayerIndex)

        if self.onPlayerChange then
            self.onPlayerChange(self.currentPlayer, self.currentPlayerIndex, self)
        end
    else
        self.currentTurn = self.currentTurn + 1
    end

    self:_buildComponents()
end

function TurnIndicator:setPhase(phaseId)
    local oldPhase = self.turnPhase
    self.turnPhase = phaseId

    if self.onPhaseChange then
        self.onPhaseChange(phaseId, oldPhase, self)
    end

    self:_buildComponents()
end

function TurnIndicator:_saveTurnState()
    local state = {
        turn = self.currentTurn,
        player = self.currentPlayer,
        playerIndex = self.currentPlayerIndex,
        phase = self.turnPhase,
        time = love.timer.getTime()
    }

    table.insert(self.turnHistory, state)

    -- Limit history size
    if #self.turnHistory > self.maxUndoSteps then
        table.remove(self.turnHistory, 1)
    end

    self.canUndo = #self.turnHistory > 1
    self:_buildComponents()
end

function TurnIndicator:undo()
    if #self.turnHistory <= 1 then return false end

    -- Remove current state
    table.remove(self.turnHistory)

    -- Restore previous state
    local prevState = self.turnHistory[#self.turnHistory]
    if prevState then
        self.currentTurn = prevState.turn
        self.currentPlayer = prevState.player
        self.currentPlayerIndex = prevState.playerIndex
        self.turnPhase = prevState.phase
    end

    self.canUndo = #self.turnHistory > 1

    if self.onUndo then
        self.onUndo(prevState, self)
    end

    self:_buildComponents()
    return true
end

function TurnIndicator:_triggerTransitionEffect()
    self.transitionEffect = {
        startTime = love.timer.getTime(),
        duration = 0.5
    }
end

function TurnIndicator:update(dt)
    core.Base.update(self, dt)

    -- Update timer
    if self.timerRunning and not self.pauseTimer and self.turnTimeLimit then
        self.currentTurnTime = self.currentTurnTime + dt

        local remainingTime = self.turnTimeLimit - self.currentTurnTime

        -- Check for warnings
        if remainingTime <= self.timerCriticalThreshold and not self.warningEffect then
            self.warningEffect = {
                type = "critical",
                startTime = love.timer.getTime()
            }
        elseif remainingTime <= self.timerWarningThreshold and not self.warningEffect then
            self.warningEffect = {
                type = "warning",
                startTime = love.timer.getTime()
            }
        end

        -- Check for time expiry
        if self.currentTurnTime >= self.turnTimeLimit then
            self.timerRunning = false
            if self.onTimerExpired then
                self.onTimerExpired(self)
            else
                self:endTurn() -- Auto end turn on timeout
            end
        end
    end

    -- Update components
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.update then
            comp.component:update(dt)
        end
    end

    -- Update transition effect
    if self.transitionEffect then
        local elapsed = love.timer.getTime() - self.transitionEffect.startTime
        if elapsed >= self.transitionEffect.duration then
            self.transitionEffect = nil
        end
    end
end

function TurnIndicator:draw()
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)

    -- Draw transition effect
    if self.transitionEffect then
        local elapsed = love.timer.getTime() - self.transitionEffect.startTime
        local progress = elapsed / self.transitionEffect.duration
        local alpha = 0.5 * math.sin(progress * math.pi)

        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)
    end

    -- Draw components
    for _, comp in ipairs(self.components) do
        if comp.type == "component" then
            comp.component:draw()
        elseif comp.type == "timer" then
            self:_drawTimer(comp)
        end
    end

    -- Draw border
    if self.showBorder then
        love.graphics.setColor(unpack(self.borderColor))
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)
    end
end

function TurnIndicator:_drawTimer(timerComp)
    if not self.turnTimeLimit then return end

    local remainingTime = self.turnTimeLimit - self.currentTurnTime
    remainingTime = math.max(0, remainingTime)

    -- Determine timer color
    local timerColor = self.timerColor
    if remainingTime <= self.timerCriticalThreshold then
        timerColor = self.criticalColor
    elseif remainingTime <= self.timerWarningThreshold then
        timerColor = self.warningColor
    end

    -- Apply warning pulse effect
    if self.warningEffect and self.pulseOnTimeWarning then
        local elapsed = love.timer.getTime() - self.warningEffect.startTime
        local pulseSpeed = self.warningEffect.type == "critical" and 8 or 4
        local pulse = 0.5 + 0.5 * math.sin(elapsed * pulseSpeed)

        timerColor = {
            timerColor[1] + (1 - timerColor[1]) * pulse * 0.3,
            timerColor[2],
            timerColor[3]
        }
    end

    -- Format time
    local minutes = math.floor(remainingTime / 60)
    local seconds = remainingTime % 60
    local timeText = string.format("%d:%02d", minutes, seconds)

    -- Draw timer background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", timerComp.x, timerComp.y, timerComp.w, timerComp.h, 2)

    -- Draw timer text
    love.graphics.setColor(unpack(timerColor))
    love.graphics.setFont(core.theme.fontBold)
    love.graphics.printf(timeText, timerComp.x, timerComp.y + (timerComp.h - core.theme.fontBold:getHeight()) / 2,
        timerComp.w, "center")
end

function TurnIndicator:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.mousepressed then
            if comp.component:mousepressed(x, y, button) then
                return true
            end
        end
    end

    return true
end

function TurnIndicator:mousereleased(x, y, button)
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.mousereleased then
            comp.component:mousereleased(x, y, button)
        end
    end
end

function TurnIndicator:mousemoved(x, y, dx, dy)
    for _, comp in ipairs(self.components) do
        if comp.component and comp.component.mousemoved then
            comp.component:mousemoved(x, y, dx, dy)
        end
    end
end

-- Public API
function TurnIndicator:pauseTimer()
    self.pauseTimer = true
end

function TurnIndicator:resumeTimer()
    self.pauseTimer = false
end

function TurnIndicator:addTime(seconds)
    self.currentTurnTime = math.max(0, self.currentTurnTime - seconds)
end

function TurnIndicator:setPlayers(players)
    self.players = players
    if #players > 0 then
        self.currentPlayerIndex = 1
        self.currentPlayer = players[1].name or "Player 1"
    end
    self:_buildComponents()
end

function TurnIndicator:getCurrentPlayer()
    return self:_getCurrentPlayer()
end

function TurnIndicator:getRemainingTime()
    if not self.turnTimeLimit then return nil end
    return math.max(0, self.turnTimeLimit - self.currentTurnTime)
end

return TurnIndicator






