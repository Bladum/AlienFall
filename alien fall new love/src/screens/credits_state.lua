local BaseState = require "screens.base_state"
local Button = require "widgets.Button"

local CreditsState = {}
CreditsState.__index = CreditsState
setmetatable(CreditsState, { __index = BaseState })

local GRID_SIZE = 20
local GRID_COLS = 40
local GRID_ROWS = 30

function CreditsState.new(registry)
    local self = BaseState.new({
        name = "credits",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, CreditsState)

    self.lines = {
        "AlienFall",
        "An open-source strategy game",
        "Design: AlienFall Community",
        "Programming: Contributors",
        "Documentation: AF_WIKI",
        "",
        "Love2D Engine Implementation"
    }
    self.titleFont = love.graphics.newFont(16)
    self.bodyFont = love.graphics.newFont(16)
    
    -- Back button
    self.backButton = Button:new({
        id = "back",
        label = "Back",
        onClick = function()
            self.stack:pop({ from = "credits" })
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.backButton:setPosition(20, 600 - 20 - 2 * GRID_SIZE)
    
    return self
end

function CreditsState:update(dt)
    self.backButton:update(dt)
end

function CreditsState:draw()
    love.graphics.clear(0.07, 0.07, 0.1, 1)
    
    -- Draw subtle grid background
    love.graphics.setColor(0.1, 0.1, 0.15, 0.3)
    for x = 0, GRID_COLS - 1 do
        for y = 0, GRID_ROWS - 1 do
            if (x + y) % 2 == 0 then
                love.graphics.rectangle("fill", x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
            end
        end
    end
    
    -- Title
    love.graphics.setColor(0, 0.6, 0.9, 1)
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("CREDITS", 0, 2 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")

    -- Credits text
    love.graphics.setColor(0.8, 0.9, 1, 1)
    love.graphics.setFont(self.bodyFont)
    for index, line in ipairs(self.lines) do
        love.graphics.printf(line, 0, 6 * GRID_SIZE + (index - 1) * 1.5 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    end
    
    -- Draw back button
    self.backButton:draw(self.backButton.hovered)
end

function CreditsState:mousepressed(x, y, button)
    if button ~= 1 then return false end
    
    if self.backButton:mousepressed(x, y, button) then return true end
    
    return false
end

function CreditsState:mousereleased(x, y, button)
    self.backButton:mousereleased(x, y, button)
end

return CreditsState
