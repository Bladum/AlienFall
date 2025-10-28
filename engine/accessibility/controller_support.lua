---Controller Support - Game controller / gamepad support
---
---Manages gamepad input, button mapping, analog stick configuration,
---and controller-based UI navigation.
---
---@module controller_support
---@author AlienFall Development Team
---@license Open Source

local ControllerSupport = {}
ControllerSupport.__index = ControllerSupport

function ControllerSupport.new()
    local self = setmetatable({}, ControllerSupport)

    self.enabled = true
    self.controllers = {}
    self.buttonMap = {
        a = "confirm",
        b = "cancel",
        x = "action1",
        y = "action2",
        lb = "previousTab",
        rb = "nextTab",
        lt = "zoomOut",
        rt = "zoomIn",
    }

    print("[ControllerSupport] Controller support initialized")
    return self
end

---Enable/disable controller support
---
---@param enabled boolean
function ControllerSupport:setEnabled(enabled)
    self.enabled = enabled
    print("[ControllerSupport] Controller support: " .. (enabled and "enabled" or "disabled"))
end

---Get connected joysticks
---
---@return table Array of connected joysticks
function ControllerSupport:getConnectedControllers()
    return love.joystick.getJoysticks()
end

---Handle joystick button press
---
---@param joystick lightuserdata Joystick object
---@param button number Button number
function ControllerSupport:joystickpressed(joystick, button)
    if not self.enabled then return end

    -- Map button to action
    -- TODO: Implement button mapping
end

return ControllerSupport

