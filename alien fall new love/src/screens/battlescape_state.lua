local BaseState = require "screens.base_state"
local ActionMenu = require "battlescape.ActionMenu"
local TurnIndicator = require "battlescape.TurnIndicator"

local BattlescapeState = {}
BattlescapeState.__index = BattlescapeState
setmetatable(BattlescapeState, { __index = BaseState })

function BattlescapeState.new(registry)
    local self = BaseState.new({
        name = "battlescape",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, BattlescapeState)

    self.turnNumber = 1
    self.actionMenu = ActionMenu.new({
        onActionSelected = function(action)
            self:onActionSelected(action)
        end
    })
    self.indicator = TurnIndicator.new({})
    self.titleFont = love.graphics.newFont(28)
    self.bodyFont = love.graphics.newFont(16)
    return self
end

function BattlescapeState:enter(payload)
    BaseState.enter(self, payload)
    self.turnNumber = 1
    self.actionMenu:setActions({
        { id = "move", label = "Move" },
        { id = "overwatch", label = "Overwatch" },
        { id = "grenade", label = "Throw Grenade" },
        { id = "end_turn", label = "End Turn" }
    })
    self.indicator:setTurn(self.turnNumber, "XCOM")
end

function BattlescapeState:onActionSelected(action)
    if action.id == "end_turn" then
        self.turnNumber = self.turnNumber + 1
        self.indicator:setTurn(self.turnNumber, "Aliens")
        if self.eventBus then
            self.eventBus:publish("battlescape:turn_started", {
                turn = self.turnNumber
            })
        end
    else
        if self.eventBus then
            self.eventBus:publish("battlescape:unit_action", action)
        end
    end
end

function BattlescapeState:keypressed(key)
    if key == "escape" then
        self.stack:replace("debriefing", {
            result = "retreat"
        })
    else
        self.actionMenu:keypressed(key)
    end
end

function BattlescapeState:draw()
    love.graphics.clear(0.05, 0.05, 0.05, 1)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("BATTLESCAPE", 0, 24, love.graphics.getWidth(), "center")

    self.indicator:draw(32, 96)
    self.actionMenu:draw(32, 180)

    love.graphics.setFont(self.bodyFont)
    love.graphics.print("Press ESC to abort mission", 32, 520)
end

return BattlescapeState
