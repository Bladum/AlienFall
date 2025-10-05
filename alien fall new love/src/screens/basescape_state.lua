local BaseState = require "screens.base_state"
local FacilityGrid = require "basescape.FacilityGrid"

local BasescapeState = {}
BasescapeState.__index = BasescapeState
setmetatable(BasescapeState, { __index = BaseState })

function BasescapeState.new(registry)
    local self = BaseState.new({
        name = "basescape",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, BasescapeState)

    self.grid = FacilityGrid.new({ size = 6 })
    self.notifications = {}
    self.titleFont = love.graphics.newFont(32)
    self.subtitleFont = love.graphics.newFont(18)

    return self
end

function BasescapeState:enter(payload)
    BaseState.enter(self, payload)
    self.grid:reset()
    if payload and payload.facility then
        self.grid:addFacility(payload.facility)
    end
end

function BasescapeState:draw()
    love.graphics.clear(0.1, 0.08, 0.05, 1)
    love.graphics.setColor(0.9, 0.83, 0.64, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("BASESCAPE", 0, 32, love.graphics.getWidth(), "center")

    self.grid:draw(96, 128)

    love.graphics.setFont(self.subtitleFont)
    love.graphics.setColor(0.8, 0.9, 1, 1)
    love.graphics.print("Press G to return to Geoscape", 96, 520)
end

function BasescapeState:keypressed(key)
    if key == "g" or key == "escape" then
        self.stack:pop({ to = "geoscape" })
    elseif key == "m" then
        self.stack:push("manufacturing", {})
    elseif key == "r" then
        self.stack:push("research", {})
    end
end

return BasescapeState
