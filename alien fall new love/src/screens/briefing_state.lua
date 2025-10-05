local BaseState = require "screens.base_state"
local SquadPanel = require "battlescape.gui.squad_panel"

local BriefingState = {}
BriefingState.__index = BriefingState
setmetatable(BriefingState, { __index = BaseState })

function BriefingState.new(registry)
    local self = BaseState.new({
        name = "briefing",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, BriefingState)

    self.panel = SquadPanel.new({})
    self.selection = {}
    self.titleFont = love.graphics.newFont(32)
    self.bodyFont = love.graphics.newFont(18)
    return self
end

function BriefingState:enter(payload)
    BaseState.enter(self, payload)
    self.selection = {}
    self.panel:populate(payload and payload.squad or {})
end

function BriefingState:keypressed(key)
    if key == "space" or key == "return" then
        if self.eventBus then
            self.eventBus:publish("briefing:mission_confirmed", {
                squad = self.selection
            })
        end
        self.stack:replace("battlescape", {
            squad = self.selection
        })
    elseif key == "escape" then
        self.stack:pop({ aborted = true })
    end
end

function BriefingState:draw()
    love.graphics.clear(0.08, 0.08, 0.08, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("MISSION BRIEFING", 0, 32, love.graphics.getWidth(), "center")
    self.panel:draw(80, 120)

    love.graphics.setFont(self.bodyFont)
    love.graphics.print("SPACE to deploy, ESC to cancel", 80, 460)
end

return BriefingState
