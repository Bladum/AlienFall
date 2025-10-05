--- Time Controls Widget
-- UI widget for controlling time progression (pause, speed scaling)
-- Designed for 20x20 grid system at 800x600 resolution
--
-- @module widgets.TimeControls

local class = require 'lib.Middleclass'
local Button = require 'widgets.Button'

local TimeControls = class('TimeControls')

--- Create a new TimeControls widget
-- @param options table: {timeService, x, y, width, height}
-- @return TimeControls instance
function TimeControls:initialize(options)
    options = options or {}
    
    self.timeService = options.timeService
    self.x = options.x or 0
    self.y = options.y or 0
    self.width = options.width or 200  -- 10 grid units
    self.height = options.height or 40  -- 2 grid units
    self.font = options.font or love.graphics.newFont(12)
    
    -- Buttons
    self.pauseButton = nil
    self.speedButtons = {}
    
    -- State
    self.isPaused = false
    self.currentSpeed = 1
    
    self:_createButtons()
end

--- Create control buttons
function TimeControls:_createButtons()
    local buttonWidth = 40
    local buttonHeight = 40
    local spacing = 5
    
    -- Pause button
    self.pauseButton = Button:new({
        id = "time_pause",
        label = "||",  -- Pause symbol
        onClick = function()
            self:togglePause()
        end,
        width = buttonWidth,
        height = buttonHeight,
        font = self.font
    })
    self.pauseButton:setPosition(self.x, self.y)
    
    -- Speed buttons (1x, 5x, 30x)
    local speeds = {1, 5, 30}
    for i, speed in ipairs(speeds) do
        local button = Button:new({
            id = "time_speed_" .. speed,
            label = speed .. "x",
            onClick = function()
                self:setSpeed(speed)
            end,
            width = buttonWidth,
            height = buttonHeight,
            font = self.font
        })
        button:setPosition(self.x + (buttonWidth + spacing) * i, self.y)
        self.speedButtons[speed] = button
    end
end

--- Toggle pause state
function TimeControls:togglePause()
    if self.timeService then
        self.timeService:togglePause()
        self.isPaused = self.timeService:isPaused()
        
        -- Update button label
        self.pauseButton.label = self.isPaused and ">" or "||"
    end
end

--- Set time speed
-- @param speed number: Time scale (1, 5, or 30)
function TimeControls:setSpeed(speed)
    if self.timeService then
        self.timeService:setTimeScale(speed)
        self.currentSpeed = self.timeService:getTimeScale()
    end
end

--- Handle keyboard input
-- @param key string: Key pressed
function TimeControls:keypressed(key)
    if key == "space" then
        self:togglePause()
        return true
    elseif key == "1" then
        self:setSpeed(1)
        return true
    elseif key == "2" then
        self:setSpeed(5)
        return true
    elseif key == "3" then
        self:setSpeed(30)
        return true
    end
    return false
end

--- Update widget state
-- @param dt number: Delta time
function TimeControls:update(dt)
    -- Sync state with time service
    if self.timeService then
        self.isPaused = self.timeService:isPaused()
        self.currentSpeed = self.timeService:getTimeScale()
        self.pauseButton.label = self.isPaused and ">" or "||"
    end
    
    -- Update buttons
    self.pauseButton:update(dt)
    for _, button in pairs(self.speedButtons) do
        button:update(dt)
    end
end

--- Draw widget
function TimeControls:draw()
    -- Draw background panel
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(0.5, 0.5, 0.8, 1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw pause button
    self.pauseButton:draw()
    
    -- Draw speed buttons
    for speed, button in pairs(self.speedButtons) do
        -- Highlight current speed
        if speed == self.currentSpeed and not self.isPaused then
            love.graphics.setColor(0.2, 0.8, 0.2, 0.3)
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        end
        button:draw()
    end
    
    -- Draw current status text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    local statusText = self.isPaused and "PAUSED" or (self.currentSpeed .. "x")
    love.graphics.print(statusText, self.x + self.width - 50, self.y + 10)
end

--- Handle mouse press
-- @param x number: Mouse X
-- @param y number: Mouse Y
-- @param button number: Mouse button
function TimeControls:mousepressed(x, y, button)
    if self.pauseButton:isMouseOver(x, y) then
        self.pauseButton:onClick()
        return true
    end
    
    for _, speedButton in pairs(self.speedButtons) do
        if speedButton:isMouseOver(x, y) then
            speedButton:onClick()
            return true
        end
    end
    
    return false
end

--- Set position
-- @param x number: X coordinate
-- @param y number: Y coordinate
function TimeControls:setPosition(x, y)
    local dx = x - self.x
    local dy = y - self.y
    
    self.x = x
    self.y = y
    
    -- Update button positions
    self.pauseButton:setPosition(self.pauseButton.x + dx, self.pauseButton.y + dy)
    for _, button in pairs(self.speedButtons) do
        button:setPosition(button.x + dx, button.y + dy)
    end
end

return TimeControls
