local BaseState = require "screens.base_state"
local Button = require "widgets.Button"
local Checkbox = require "widgets.Checkbox"
local OptionsState = {}
OptionsState.__index = OptionsState
setmetatable(OptionsState, { __index = BaseState })

local GRID_SIZE = 20
local GRID_COLS = 40
local GRID_ROWS = 30

function OptionsState.new(registry)
    local self = BaseState.new({
        name = "options",
        registry = registry,
        eventBus = registry and registry:eventBus(),
        logger = registry and registry:logger()
    })
    setmetatable(self, OptionsState)

    self.titleFont = love.graphics.newFont(16)
    self.labelFont = love.graphics.newFont(16)
    
    -- Option controls
    self.optionControls = {}
    local startY = 8 * GRID_SIZE
    
    local fullscreenCheckbox = Checkbox:new({
        id = "fullscreen",
        label = "Fullscreen",
        checked = love.window.getFullscreen(),
        onChange = function(checked)
            love.window.setFullscreen(checked)
        end,
        width = 16 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    fullscreenCheckbox:setPosition(12 * GRID_SIZE, startY)
    self.optionControls[1] = fullscreenCheckbox
    
    local telemetryCheckbox = Checkbox:new({
        id = "telemetry",
        label = "Enable Telemetry",
        checked = false, -- Default to false, could be loaded from settings
        onChange = function(checked)
            local telemetry = registry and registry:resolve("telemetry")
            if telemetry then
                telemetry:setEnabled(checked)
            end
        end,
        width = 16 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    telemetryCheckbox:setPosition(12 * GRID_SIZE, startY + 3 * GRID_SIZE)
    self.optionControls[2] = telemetryCheckbox
    
    -- Back button
    self.backButton = Button:new({
        id = "back",
        label = "Back",
        onClick = function()
            self.stack:pop({ cancelled = true })
        end,
        width = 6 * GRID_SIZE,
        height = 2 * GRID_SIZE
    })
    self.backButton:setPosition(20, 600 - 20 - 2 * GRID_SIZE)
    
    return self
end

function OptionsState:update(dt)
    for _, control in ipairs(self.optionControls) do
        control:update(dt)
    end
    self.backButton:update(dt)
end

function OptionsState:draw()
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
    love.graphics.printf("OPTIONS", 0, 2 * GRID_SIZE, GRID_COLS * GRID_SIZE, "center")
    
    -- Draw option controls
    for _, control in ipairs(self.optionControls) do
        control:draw(control.hovered)
    end
    
    -- Draw back button
    self.backButton:draw(self.backButton.hovered)
end

function OptionsState:mousepressed(x, y, button)
    if button ~= 1 then return false end
    
    for _, control in ipairs(self.optionControls) do
        if control:mousepressed(x, y, button) then return true end
    end
    if self.backButton:mousepressed(x, y, button) then return true end
    
    return false
end

function OptionsState:mousereleased(x, y, button)
    for _, control in ipairs(self.optionControls) do
        control:mousereleased(x, y, button)
    end
    self.backButton:mousereleased(x, y, button)
end

function OptionsState:mousemoved(x, y, dx, dy, istouch)
    for _, control in ipairs(self.optionControls) do
        control:mousemoved(x, y)
    end
    self.backButton:mousemoved(x, y)
end

return OptionsState
