local BaseState = require "screens.base_state"

local ManufacturingState = {}
ManufacturingState.__index = ManufacturingState
setmetatable(ManufacturingState, { __index = BaseState })

function ManufacturingState.new(registry)
    local self = BaseState.new({
        name = "manufacturing",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, ManufacturingState)

    self.projects = {}
    self.titleFont = love.graphics.newFont(28)
    self.bodyFont = love.graphics.newFont(18)
    return self
end

function ManufacturingState:enter(payload)
    BaseState.enter(self, payload)
    self.projects = payload and payload.projects or {}
end

function ManufacturingState:keypressed(key)
    if key == "escape" then
        self.stack:pop({})
    end
end

function ManufacturingState:draw()
    love.graphics.clear(0.1, 0.07, 0.07, 1)
    love.graphics.setColor(1, 0.9, 0.8, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("MANUFACTURING", 0, 60, love.graphics.getWidth(), "center")

    love.graphics.setFont(self.bodyFont)
    for index, project in ipairs(self.projects) do
        love.graphics.print(string.format("%d) %s", index, project.name or "Unknown"), 120, 160 + (index - 1) * 30)
    end
    love.graphics.print("Press ESC to return", 120, 460)
end

return ManufacturingState
