--- Input Validation Module
--- Provides comprehensive input validation and sanitization for mouse, keyboard,
--- and other input sources. Ensures all input is within valid bounds and safe to use.
---
--- @module core.input_validation
--- @author AlienFall Development Team
--- @copyright 2025

local validate = require('utils.validate')

local InputValidation = {}

-- Constants for input validation
local INTERNAL_WIDTH = 800
local INTERNAL_HEIGHT = 600
local MAX_TEXT_LENGTH = 1000
local ALLOWED_KEYCODES = {
    -- Alphanumeric
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    -- Function keys
    "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12",
    -- Modifiers
    "lshift", "rshift", "lctrl", "rctrl", "lalt", "ralt",
    -- Navigation
    "up", "down", "left", "right", "home", "end", "pageup", "pagedown",
    -- Editing
    "return", "escape", "backspace", "delete", "tab", "space",
    -- Numpad
    "kp0", "kp1", "kp2", "kp3", "kp4", "kp5", "kp6", "kp7", "kp8", "kp9",
    "kp.", "kp/", "kp*", "kp-", "kp+", "kpenter",
}

-- Create lookup table for fast validation
local KEYCODE_LOOKUP = {}
for _, key in ipairs(ALLOWED_KEYCODES) do
    KEYCODE_LOOKUP[key] = true
end

--- Validate and clamp mouse coordinates to internal resolution
--- Converts window coordinates to internal 800x600 space
---
--- @param x number Mouse X coordinate (window space)
--- @param y number Mouse Y coordinate (window space)
--- @param window_width number Current window width
--- @param window_height number Current window height
--- @return number, number Clamped coordinates in internal space
function InputValidation.validateMouseCoordinates(x, y, window_width, window_height)
    -- Validate input types
    validate.require_type(x, "number", "mouse x")
    validate.require_type(y, "number", "mouse y")
    validate.require_type(window_width, "number", "window_width")
    validate.require_type(window_height, "number", "window_height")
    
    -- Convert from window space to internal space
    local scale_x = INTERNAL_WIDTH / window_width
    local scale_y = INTERNAL_HEIGHT / window_height
    
    local internal_x = x * scale_x
    local internal_y = y * scale_y
    
    -- Clamp to internal resolution bounds
    internal_x = math.max(0, math.min(INTERNAL_WIDTH, internal_x))
    internal_y = math.max(0, math.min(INTERNAL_HEIGHT, internal_y))
    
    return internal_x, internal_y
end

--- Validate mouse button input
--- Ensures button number is valid (1=left, 2=right, 3=middle)
---
--- @param button number Mouse button number
--- @return boolean True if valid
function InputValidation.validateMouseButton(button)
    validate.require_type(button, "number", "mouse button")
    return button >= 1 and button <= 3
end

--- Validate keyboard key input
--- Ensures key is in the allowed keycodes list
---
--- @param key string Key code string
--- @return boolean True if valid
function InputValidation.validateKeyCode(key)
    if type(key) ~= "string" then
        return false
    end
    
    -- Normalize to lowercase
    key = key:lower()
    
    return KEYCODE_LOOKUP[key] == true
end

--- Sanitize text input
--- Removes control characters and limits length
---
--- @param text string Text to sanitize
--- @param max_length number Optional maximum length (default: MAX_TEXT_LENGTH)
--- @return string Sanitized text
function InputValidation.sanitizeTextInput(text, max_length)
    validate.require_type(text, "string", "text")
    max_length = max_length or MAX_TEXT_LENGTH
    
    -- Remove control characters (except newline and tab)
    text = text:gsub("[%c]", function(c)
        if c == "\n" or c == "\t" then
            return c
        end
        return ""
    end)
    
    -- Limit length
    if #text > max_length then
        text = text:sub(1, max_length)
    end
    
    return text
end

--- Validate UI bounds
--- Checks if coordinates are within a UI element's bounds
---
--- @param x number X coordinate to check
--- @param y number Y coordinate to check
--- @param element_x number Element X position
--- @param element_y number Element Y position
--- @param element_width number Element width
--- @param element_height number Element height
--- @return boolean True if coordinates are within bounds
function InputValidation.isWithinBounds(x, y, element_x, element_y, element_width, element_height)
    validate.require_type(x, "number", "x")
    validate.require_type(y, "number", "y")
    validate.require_type(element_x, "number", "element_x")
    validate.require_type(element_y, "number", "element_y")
    validate.require_type(element_width, "number", "element_width")
    validate.require_type(element_height, "number", "element_height")
    
    return x >= element_x 
        and x <= element_x + element_width
        and y >= element_y
        and y <= element_y + element_height
end

--- Validate scroll wheel input
--- Ensures scroll delta is reasonable
---
--- @param delta_x number Horizontal scroll delta
--- @param delta_y number Vertical scroll delta
--- @return number, number Clamped scroll deltas
function InputValidation.validateScrollWheel(delta_x, delta_y)
    validate.require_type(delta_x, "number", "scroll delta_x")
    validate.require_type(delta_y, "number", "scroll delta_y")
    
    -- Clamp to reasonable values (prevent scroll injection)
    local MAX_SCROLL = 10
    delta_x = math.max(-MAX_SCROLL, math.min(MAX_SCROLL, delta_x))
    delta_y = math.max(-MAX_SCROLL, math.min(MAX_SCROLL, delta_y))
    
    return delta_x, delta_y
end

--- Validate gamepad button input
--- Ensures button number is within valid range
---
--- @param button number Gamepad button number
--- @return boolean True if valid
function InputValidation.validateGamepadButton(button)
    validate.require_type(button, "number", "gamepad button")
    -- Love2D gamepad buttons are typically 1-15
    return button >= 1 and button <= 15
end

--- Validate gamepad axis input
--- Ensures axis value is within -1 to 1 range
---
--- @param axis_value number Axis value
--- @return number Clamped axis value
function InputValidation.validateGamepadAxis(axis_value)
    validate.require_type(axis_value, "number", "axis_value")
    -- Clamp to valid range
    return math.max(-1, math.min(1, axis_value))
end

--- Validate screen coordinates for grid system
--- Ensures coordinates align to the 20x20 grid system
---
--- @param x number X coordinate
--- @param y number Y coordinate
--- @return number, number Grid-aligned coordinates
function InputValidation.alignToGrid(x, y)
    validate.require_type(x, "number", "x")
    validate.require_type(y, "number", "y")
    
    local GRID_SIZE = 20
    
    -- Round to nearest grid cell
    local grid_x = math.floor(x / GRID_SIZE) * GRID_SIZE
    local grid_y = math.floor(y / GRID_SIZE) * GRID_SIZE
    
    return grid_x, grid_y
end

--- Validate touch input (for future mobile support)
--- Ensures touch ID and coordinates are valid
---
--- @param id any Touch identifier
--- @param x number Touch X coordinate
--- @param y number Touch Y coordinate
--- @return boolean True if valid
function InputValidation.validateTouch(id, x, y)
    if id == nil then
        return false
    end
    
    validate.require_type(x, "number", "touch x")
    validate.require_type(y, "number", "touch y")
    
    -- Validate coordinates are within internal bounds
    return x >= 0 and x <= INTERNAL_WIDTH and y >= 0 and y <= INTERNAL_HEIGHT
end

--- Sanitize file path input
--- Prevents directory traversal attacks
---
--- @param path string File path to sanitize
--- @return string Sanitized path, or nil if invalid
function InputValidation.sanitizeFilePath(path)
    validate.require_type(path, "string", "path")
    
    -- Remove directory traversal attempts
    path = path:gsub("%.%.", "")
    
    -- Remove leading slashes
    path = path:gsub("^[/\\]+", "")
    
    -- Only allow safe characters
    if not path:match("^[%w_%-%./ ]+$") then
        return nil  -- Invalid characters
    end
    
    return path
end

--- Validate numeric input with optional range
--- Useful for validating user input in text fields
---
--- @param value string String value to validate
--- @param min number Optional minimum value
--- @param max number Optional maximum value
--- @return number, boolean Parsed number and success status
function InputValidation.validateNumericInput(value, min, max)
    validate.require_type(value, "string", "value")
    
    -- Try to parse as number
    local num = tonumber(value)
    if not num then
        return nil, false
    end
    
    -- Check range if provided
    if min and num < min then
        return num, false
    end
    
    if max and num > max then
        return num, false
    end
    
    return num, true
end

--- Get internal resolution constants
--- Useful for other modules that need to validate coordinates
---
--- @return number, number Internal width and height
function InputValidation.getInternalResolution()
    return INTERNAL_WIDTH, INTERNAL_HEIGHT
end

return InputValidation
