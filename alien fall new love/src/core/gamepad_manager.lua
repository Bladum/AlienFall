-- GamepadManager - Gamepad/Controller Support
-- Handles gamepad detection, button mapping, and UI navigation

local class = require('lib.middleclass')
local Logger = require('engine.logger')

local GamepadManager = class('GamepadManager')

-- Button mapping constants (Love2D 12.0 SDL3 compatible)
GamepadManager.static.BUTTONS = {
    A = 'a',
    B = 'b',
    X = 'x',
    Y = 'y',
    BACK = 'back',
    GUIDE = 'guide',
    START = 'start',
    LEFT_STICK = 'leftstick',
    RIGHT_STICK = 'rightstick',
    LEFT_SHOULDER = 'leftshoulder',
    RIGHT_SHOULDER = 'rightshoulder',
    DPAD_UP = 'dpup',
    DPAD_DOWN = 'dpdown',
    DPAD_LEFT = 'dpleft',
    DPAD_RIGHT = 'dpright',
    -- Love2D 12.0 new buttons (SDL3)
    MISC1 = 'misc1',
    PADDLE1 = 'paddle1',
    PADDLE2 = 'paddle2',
    PADDLE3 = 'paddle3',
    PADDLE4 = 'paddle4',
    TOUCHPAD = 'touchpad'
}

GamepadManager.static.AXES = {
    LEFT_X = 'leftx',
    LEFT_Y = 'lefty',
    RIGHT_X = 'rightx',
    RIGHT_Y = 'righty',
    TRIGGER_LEFT = 'triggerleft',
    TRIGGER_RIGHT = 'triggerright'
}

function GamepadManager:initialize()
    self.logger = Logger.new("GamepadManager")
    
    -- Connected controllers
    self.joysticks = {}
    self.active_joystick = nil
    
    -- Button mapping (default to Xbox controller layout)
    self.button_mapping = {
        confirm = GamepadManager.static.BUTTONS.A,
        cancel = GamepadManager.static.BUTTONS.B,
        menu = GamepadManager.static.BUTTONS.START,
        special1 = GamepadManager.static.BUTTONS.X,
        special2 = GamepadManager.static.BUTTONS.Y,
        shoulder_left = GamepadManager.static.BUTTONS.LEFT_SHOULDER,
        shoulder_right = GamepadManager.static.BUTTONS.RIGHT_SHOULDER,
    }
    
    -- Analog stick settings
    self.stick_deadzone = 0.2
    self.stick_repeat_delay = 0.3
    self.stick_repeat_rate = 0.1
    self.stick_timer = 0
    self.last_stick_direction = nil
    
    -- UI navigation state
    self.navigation_enabled = true
    self.cursor_x = 0
    self.cursor_y = 0
    
    -- Detect initially connected joysticks
    self:detectJoysticks()
    
    self.logger:info("GamepadManager initialized")
end

function GamepadManager:detectJoysticks()
    local joysticks = love.joystick.getJoysticks()
    
    for _, joystick in ipairs(joysticks) do
        if joystick:isGamepad() then
            self:addJoystick(joystick)
        end
    end
    
    if #self.joysticks > 0 and not self.active_joystick then
        self.active_joystick = self.joysticks[1]
        self.logger:info("Active gamepad: " .. self.active_joystick:getName())
    end
end

function GamepadManager:addJoystick(joystick)
    for _, existing in ipairs(self.joysticks) do
        if existing == joystick then
            return
        end
    end
    
    table.insert(self.joysticks, joystick)
    self.logger:info("Gamepad connected: " .. joystick:getName())
    
    if not self.active_joystick then
        self.active_joystick = joystick
    end
end

function GamepadManager:removeJoystick(joystick)
    for i, existing in ipairs(self.joysticks) do
        if existing == joystick then
            table.remove(self.joysticks, i)
            self.logger:info("Gamepad disconnected: " .. joystick:getName())
            
            if self.active_joystick == joystick then
                self.active_joystick = self.joysticks[1] or nil
                if self.active_joystick then
                    self.logger:info("Switched to gamepad: " .. self.active_joystick:getName())
                end
            end
            break
        end
    end
end

function GamepadManager:isConnected()
    return self.active_joystick ~= nil
end

function GamepadManager:getActiveJoystick()
    return self.active_joystick
end

function GamepadManager:setActiveJoystick(joystick)
    for _, js in ipairs(self.joysticks) do
        if js == joystick then
            self.active_joystick = joystick
            self.logger:info("Active gamepad changed: " .. joystick:getName())
            return true
        end
    end
    return false
end

function GamepadManager:isButtonPressed(action)
    if not self.active_joystick then
        return false
    end
    
    local button = self.button_mapping[action]
    if not button then
        return false
    end
    
    return self.active_joystick:isGamepadDown(button)
end

function GamepadManager:getAxisValue(axis)
    if not self.active_joystick then
        return 0
    end
    
    local value = self.active_joystick:getGamepadAxis(axis)
    
    -- Apply deadzone
    if math.abs(value) < self.stick_deadzone then
        return 0
    end
    
    return value
end

function GamepadManager:getLeftStick()
    return self:getAxisValue(GamepadManager.static.AXES.LEFT_X),
           self:getAxisValue(GamepadManager.static.AXES.LEFT_Y)
end

function GamepadManager:getRightStick()
    return self:getAxisValue(GamepadManager.static.AXES.RIGHT_X),
           self:getAxisValue(GamepadManager.static.AXES.RIGHT_Y)
end

function GamepadManager:getTriggers()
    return self:getAxisValue(GamepadManager.static.AXES.TRIGGER_LEFT),
           self:getAxisValue(GamepadManager.static.AXES.TRIGGER_RIGHT)
end

-- Get navigation direction from D-pad or left stick
function GamepadManager:getNavigationDirection()
    if not self.active_joystick or not self.navigation_enabled then
        return nil
    end
    
    -- Check D-pad first
    if self.active_joystick:isGamepadDown(GamepadManager.static.BUTTONS.DPAD_UP) then
        return 'up'
    elseif self.active_joystick:isGamepadDown(GamepadManager.static.BUTTONS.DPAD_DOWN) then
        return 'down'
    elseif self.active_joystick:isGamepadDown(GamepadManager.static.BUTTONS.DPAD_LEFT) then
        return 'left'
    elseif self.active_joystick:isGamepadDown(GamepadManager.static.BUTTONS.DPAD_RIGHT) then
        return 'right'
    end
    
    -- Check left stick with threshold
    local stick_x, stick_y = self:getLeftStick()
    local threshold = 0.5
    
    if math.abs(stick_y) > math.abs(stick_x) then
        if stick_y < -threshold then
            return 'up'
        elseif stick_y > threshold then
            return 'down'
        end
    else
        if stick_x < -threshold then
            return 'left'
        elseif stick_x > threshold then
            return 'right'
        end
    end
    
    return nil
end

function GamepadManager:update(dt)
    if not self.navigation_enabled then
        return
    end
    
    -- Handle navigation direction repeat
    local direction = self:getNavigationDirection()
    
    if direction then
        if direction == self.last_stick_direction then
            self.stick_timer = self.stick_timer + dt
            
            -- Trigger repeat navigation
            if self.stick_timer >= self.stick_repeat_rate then
                self.stick_timer = 0
                return direction
            end
        else
            -- New direction
            self.last_stick_direction = direction
            self.stick_timer = -self.stick_repeat_delay -- Initial delay
            return direction
        end
    else
        -- No direction held
        self.last_stick_direction = nil
        self.stick_timer = 0
    end
    
    return nil
end

function GamepadManager:setNavigationEnabled(enabled)
    self.navigation_enabled = enabled
end

function GamepadManager:isNavigationEnabled()
    return self.navigation_enabled
end

function GamepadManager:setButtonMapping(action, button)
    self.button_mapping[action] = button
    self.logger:info(string.format("Button mapping changed: %s = %s", action, button))
end

function GamepadManager:getButtonMapping(action)
    return self.button_mapping[action]
end

function GamepadManager:setDeadzone(deadzone)
    self.stick_deadzone = math.max(0, math.min(1, deadzone))
end

function GamepadManager:getDeadzone()
    return self.stick_deadzone
end

-- Get button prompt text for UI display
function GamepadManager:getButtonPrompt(action)
    if not self.active_joystick then
        return nil
    end
    
    local button = self.button_mapping[action]
    if not button then
        return nil
    end
    
    -- Return user-friendly button names
    local prompts = {
        [GamepadManager.static.BUTTONS.A] = '[A]',
        [GamepadManager.static.BUTTONS.B] = '[B]',
        [GamepadManager.static.BUTTONS.X] = '[X]',
        [GamepadManager.static.BUTTONS.Y] = '[Y]',
        [GamepadManager.static.BUTTONS.START] = '[Start]',
        [GamepadManager.static.BUTTONS.BACK] = '[Back]',
        [GamepadManager.static.BUTTONS.LEFT_SHOULDER] = '[LB]',
        [GamepadManager.static.BUTTONS.RIGHT_SHOULDER] = '[RB]',
    }
    
    return prompts[button] or '[?]'
end

-- Vibration/rumble support
function GamepadManager:vibrate(left, right, duration)
    if not self.active_joystick then
        return false
    end
    
    if self.active_joystick:isVibrationSupported() then
        return self.active_joystick:setVibration(left, right, duration)
    end
    
    return false
end

function GamepadManager:stopVibration()
    if self.active_joystick and self.active_joystick:isVibrationSupported() then
        self.active_joystick:setVibration(0, 0)
    end
end

-- Save/load button mappings
function GamepadManager:saveMapping()
    local mapping_data = {
        button_mapping = self.button_mapping,
        stick_deadzone = self.stick_deadzone,
        stick_repeat_delay = self.stick_repeat_delay,
        stick_repeat_rate = self.stick_repeat_rate
    }
    
    return mapping_data
end

function GamepadManager:loadMapping(mapping_data)
    if mapping_data.button_mapping then
        self.button_mapping = mapping_data.button_mapping
    end
    if mapping_data.stick_deadzone then
        self.stick_deadzone = mapping_data.stick_deadzone
    end
    if mapping_data.stick_repeat_delay then
        self.stick_repeat_delay = mapping_data.stick_repeat_delay
    end
    if mapping_data.stick_repeat_rate then
        self.stick_repeat_rate = mapping_data.stick_repeat_rate
    end
    
    self.logger:info("Gamepad mapping loaded")
end

return GamepadManager
