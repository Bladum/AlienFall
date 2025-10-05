local BaseState = require "screens.base_state"
local ReportPanel = require "basescape.MonthlyReport"

local DebriefingState = {}
DebriefingState.__index = DebriefingState
setmetatable(DebriefingState, { __index = BaseState })

function DebriefingState.new(registry)
    local self = BaseState.new({
        name = "debriefing",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, DebriefingState)

    self.reportPanel = ReportPanel.new({})
    self.titleFont = love.graphics.newFont(26)
    self.bodyFont = love.graphics.newFont(16)
    return self
end

function DebriefingState:enter(payload)
    BaseState.enter(self, payload)
    self.reportPanel:setReport(payload or { outcome = "unknown" })
    if self.eventBus then
        self.eventBus:publish("debriefing:entered", payload or {})
    end
end

function DebriefingState:keypressed(key)
    if key == "return" or key == "space" or key == "escape" then
        self.stack:replace("geoscape", {})
        if self.eventBus then
            self.eventBus:publish("debriefing:resolved", {})
        end
    end
end

function DebriefingState:draw()
    love.graphics.clear(0.08, 0.06, 0.02, 1)
    love.graphics.setColor(0.95, 0.95, 0.85, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("MISSION DEBRIEF", 0, 40, love.graphics.getWidth(), "center")
    self.reportPanel:draw(120, 120)
    love.graphics.setFont(self.bodyFont)
    love.graphics.print("Press ENTER to return to Geoscape", 120, 640)
end

return DebriefingState
