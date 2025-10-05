local BaseState = require "screens.base_state"
local InterceptionGrid = require "interception.gui.GridDisplay"
local InterceptionService = require "interception.InterceptionService"
local Button = require "widgets.Button"

local InterceptionState = {}
InterceptionState.__index = InterceptionState
setmetatable(InterceptionState, { __index = BaseState })

local GRID_SIZE = 20

function InterceptionState.new(registry)
    local self = BaseState.new({
        name = "interception",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, InterceptionState)

    self.grid = InterceptionGrid.new({})
    self.turn = 1
    self.titleFont = love.graphics.newFont(32)
    self.subtitleFont = love.graphics.newFont(18)

    -- Get or create interception service
    self.interceptionService = registry:resolve("interceptionService")
    if not self.interceptionService then
        self.interceptionService = InterceptionService.new(registry)
        registry:registerService("interceptionService", self.interceptionService)
    end

    -- UI state
    self.pendingActions = {}
    self.selectedCraft = nil

    -- Create UI elements
    self:_createUI()

    return self
end

function InterceptionState:_createUI()
    -- End turn button
    self.endTurnButton = Button:new({
        id = "end_turn",
        label = "End Turn",
        onClick = function()
            self:_endTurn()
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.endTurnButton:setPosition(600 - 20 - 6 * GRID_SIZE, 600 - 20 - 2 * GRID_SIZE)

    -- Action buttons (dynamically created)
    self.actionButtons = {}
end

function InterceptionState:enter(payload)
    BaseState.enter(self, payload)
    self.turn = 1

    -- Start interception with payload data
    if payload then
        self.interceptionService:startInterception(
            payload.missionId,
            payload.missionType,
            payload.playerCrafts,
            payload.alienCrafts,
            payload.detected
        )
    end

    if self.eventBus then
        self.eventBus:publish("interception:engaged", payload or {})
    end
end

function InterceptionState:update(dt)
    self.grid:update(dt)
    self.endTurnButton:update(dt)

    -- Update action buttons
    for _, button in ipairs(self.actionButtons) do
        button:update(dt)
    end
end

function InterceptionState:draw()
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(0.2, 0.9, 0.3, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("INTERCEPTION", 0, 32, love.graphics.getWidth(), "center")
    love.graphics.setFont(self.subtitleFont)
    love.graphics.printf("Turn " .. tostring(self.interceptionService:getCurrentRound()), 0, 80, love.graphics.getWidth(), "center")

    self.grid:draw(160, 140)

    -- Draw end turn button
    self.endTurnButton:draw()

    -- Draw action buttons
    for _, button in ipairs(self.actionButtons) do
        button:draw()
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Press SPACE to resolve round", 160, 420)
    love.graphics.print("Press ESC to abort", 160, 450)
end

function InterceptionState:keypressed(key)
    if key == "space" then
        self:_endTurn()
    elseif key == "escape" then
        self.stack:pop({ abort = true })
    end
end

function InterceptionState:_endTurn()
    -- Process pending actions
    local result = self.interceptionService:processRound(self.pendingActions)

    -- Clear pending actions
    self.pendingActions = {}

    -- Check if interception ended
    if type(result) == "string" then
        -- Interception ended
        self:_handleInterceptionEnd(result)
    else
        -- Continue to next round
        self.turn = self.interceptionService:getCurrentRound()
        if self.eventBus then
            self.eventBus:publish("interception:round_resolved", { turn = self.turn })
        end
    end
end

function InterceptionState:_handleInterceptionEnd(outcome)
    -- Transition based on outcome
    if outcome == "victory" then
        -- Proceed to mission
        self.stack:replace("briefing", {
            from = "interception",
            interceptionResult = "victory"
        })
    elseif outcome == "defeat" then
        -- Return to geoscape with penalties
        self.stack:replace("geoscape", {
            interceptionResult = "defeat",
            penalties = {"base_damage", "panic_increase"}
        })
    else -- stalemate
        -- Mission continues but with modifications
        self.stack:replace("geoscape", {
            interceptionResult = "stalemate",
            missionContinues = true
        })
    end
end

return InterceptionState
