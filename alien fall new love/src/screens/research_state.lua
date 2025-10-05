local BaseState = require "screens.base_state"

local ResearchState = {}
ResearchState.__index = ResearchState
setmetatable(ResearchState, { __index = BaseState })

function ResearchState.new(registry)
    local self = BaseState.new({
        name = "research",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, ResearchState)

    self.topics = {}
    self.titleFont = love.graphics.newFont(28)
    self.bodyFont = love.graphics.newFont(18)
    return self
end

function ResearchState:enter(payload)
    BaseState.enter(self, payload)
    self.topics = payload and payload.topics or {
        { name = "Alien Alloys", days = 7 },
        { name = "Laser Weapons", days = 12 }
    }
end

function ResearchState:keypressed(key)
    if key == "escape" then
        self.stack:pop({})
    end
end

function ResearchState:draw()
    love.graphics.clear(0.06, 0.1, 0.12, 1)
    love.graphics.setColor(0.9, 0.95, 1, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("RESEARCH", 0, 60, love.graphics.getWidth(), "center")

    love.graphics.setFont(self.bodyFont)
    for index, topic in ipairs(self.topics) do
        love.graphics.print(string.format("%d) %s (%d days)", index, topic.name, topic.days), 120, 160 + (index - 1) * 30)
    end
    love.graphics.print("Press ESC to return", 120, 460)
end

return ResearchState
