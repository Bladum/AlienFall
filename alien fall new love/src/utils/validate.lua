--- Validation Utilities Module
--- Provides comprehensive validation functions to reduce repeated assertion patterns
--- and ensure consistent error messages across the codebase.
---
--- @module utils.validate
--- @author AlienFall Development Team
--- @copyright 2025

local Validate = {}

--- Require that an object has specific fields
--- Throws an error if any required field is missing or nil
---
--- @param obj table The object to validate
--- @param fields table Array of required field names
--- @param obj_name string Optional name for error messages (default: "object")
--- @throws error if any field is missing
---
--- @usage
--- validate.require_fields(unit, {'id', 'name', 'health'}, "unit")
function Validate.require_fields(obj, fields, obj_name)
    obj_name = obj_name or "object"
    
    if type(obj) ~= "table" then
        error(string.format("%s must be a table, got %s", obj_name, type(obj)))
    end
    
    for _, field in ipairs(fields) do
        if obj[field] == nil then
            error(string.format("%s is missing required field '%s'", obj_name, field))
        end
    end
end

--- Require that a value has a specific type
--- Throws an error if the type doesn't match
---
--- @param value any The value to validate
--- @param expected_type string The expected type name
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if type doesn't match
---
--- @usage
--- validate.require_type(health, "number", "health")
function Validate.require_type(value, expected_type, value_name)
    value_name = value_name or "value"
    local actual_type = type(value)
    
    if actual_type ~= expected_type then
        error(string.format("%s must be %s, got %s", value_name, expected_type, actual_type))
    end
end

--- Require that a numeric value is within a specific range
--- Throws an error if the value is out of range
---
--- @param value number The value to validate
--- @param min number Minimum allowed value (inclusive)
--- @param max number Maximum allowed value (inclusive)
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if value is out of range or not a number
---
--- @usage
--- validate.require_range(health, 0, 100, "health")
function Validate.require_range(value, min, max, value_name)
    value_name = value_name or "value"
    
    if type(value) ~= "number" then
        error(string.format("%s must be a number, got %s", value_name, type(value)))
    end
    
    if value < min or value > max then
        error(string.format("%s must be between %s and %s, got %s", value_name, min, max, value))
    end
end

--- Require that a value is one of a set of valid values
--- Throws an error if the value is not in the valid set
---
--- @param value any The value to validate
--- @param valid_values table Array of valid values
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if value is not in valid set
---
--- @usage
--- validate.require_enum(unit_type, {'soldier', 'engineer', 'medic'}, "unit_type")
function Validate.require_enum(value, valid_values, value_name)
    value_name = value_name or "value"
    
    for _, valid in ipairs(valid_values) do
        if value == valid then
            return  -- Valid value found
        end
    end
    
    -- Build error message with valid options
    local valid_str = table.concat(valid_values, "', '")
    error(string.format("%s must be one of ['%s'], got '%s'", value_name, valid_str, tostring(value)))
end

--- Require that a value is not nil
--- Throws an error if the value is nil
---
--- @param value any The value to validate
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if value is nil
---
--- @usage
--- validate.require_not_nil(weapon, "weapon")
function Validate.require_not_nil(value, value_name)
    value_name = value_name or "value"
    
    if value == nil then
        error(string.format("%s must not be nil", value_name))
    end
end

--- Require that a string is not empty
--- Throws an error if the string is empty or not a string
---
--- @param value string The string to validate
--- @param value_name string Optional name for error messages (default: "string")
--- @throws error if string is empty or not a string
---
--- @usage
--- validate.require_non_empty_string(unit_name, "unit_name")
function Validate.require_non_empty_string(value, value_name)
    value_name = value_name or "string"
    
    if type(value) ~= "string" then
        error(string.format("%s must be a string, got %s", value_name, type(value)))
    end
    
    if value == "" then
        error(string.format("%s must not be empty", value_name))
    end
end

--- Require that a table is not empty
--- Throws an error if the table is empty or not a table
---
--- @param value table The table to validate
--- @param value_name string Optional name for error messages (default: "table")
--- @throws error if table is empty or not a table
---
--- @usage
--- validate.require_non_empty_table(abilities, "abilities")
function Validate.require_non_empty_table(value, value_name)
    value_name = value_name or "table"
    
    if type(value) ~= "table" then
        error(string.format("%s must be a table, got %s", value_name, type(value)))
    end
    
    if next(value) == nil then
        error(string.format("%s must not be empty", value_name))
    end
end

--- Require that a value is a positive number
--- Throws an error if the value is not positive or not a number
---
--- @param value number The value to validate
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if value is not positive or not a number
---
--- @usage
--- validate.require_positive(damage, "damage")
function Validate.require_positive(value, value_name)
    value_name = value_name or "value"
    
    if type(value) ~= "number" then
        error(string.format("%s must be a number, got %s", value_name, type(value)))
    end
    
    if value <= 0 then
        error(string.format("%s must be positive, got %s", value_name, value))
    end
end

--- Require that a value is a non-negative number
--- Throws an error if the value is negative or not a number
---
--- @param value number The value to validate
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if value is negative or not a number
---
--- @usage
--- validate.require_non_negative(armor, "armor")
function Validate.require_non_negative(value, value_name)
    value_name = value_name or "value"
    
    if type(value) ~= "number" then
        error(string.format("%s must be a number, got %s", value_name, type(value)))
    end
    
    if value < 0 then
        error(string.format("%s must be non-negative, got %s", value_name, value))
    end
end

--- Require that a value is an integer
--- Throws an error if the value is not an integer or not a number
---
--- @param value number The value to validate
--- @param value_name string Optional name for error messages (default: "value")
--- @throws error if value is not an integer or not a number
---
--- @usage
--- validate.require_integer(turn_number, "turn_number")
function Validate.require_integer(value, value_name)
    value_name = value_name or "value"
    
    if type(value) ~= "number" then
        error(string.format("%s must be a number, got %s", value_name, type(value)))
    end
    
    if value ~= math.floor(value) then
        error(string.format("%s must be an integer, got %s", value_name, value))
    end
end

--- Require that coordinates are valid (within bounds)
--- Throws an error if coordinates are out of bounds or not numbers
---
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param min_x number Minimum X value (inclusive)
--- @param min_y number Minimum Y value (inclusive)
--- @param max_x number Maximum X value (inclusive)
--- @param max_y number Maximum Y value (inclusive)
--- @param coord_name string Optional name for error messages (default: "coordinate")
--- @throws error if coordinates are out of bounds or not numbers
---
--- @usage
--- validate.require_valid_coordinates(tile_x, tile_y, 0, 0, 50, 50, "tile")
function Validate.require_valid_coordinates(x, y, min_x, min_y, max_x, max_y, coord_name)
    coord_name = coord_name or "coordinate"
    
    if type(x) ~= "number" or type(y) ~= "number" then
        error(string.format("%s must have numeric x and y values", coord_name))
    end
    
    if x < min_x or x > max_x then
        error(string.format("%s x must be between %s and %s, got %s", coord_name, min_x, max_x, x))
    end
    
    if y < min_y or y > max_y then
        error(string.format("%s y must be between %s and %s, got %s", coord_name, min_y, max_y, y))
    end
end

--- Require that a callable (function or table with __call) is provided
--- Throws an error if the value is not callable
---
--- @param value any The value to validate
--- @param value_name string Optional name for error messages (default: "callback")
--- @throws error if value is not callable
---
--- @usage
--- validate.require_callable(on_click, "on_click")
function Validate.require_callable(value, value_name)
    value_name = value_name or "callback"
    
    local t = type(value)
    if t == "function" then
        return  -- Functions are callable
    end
    
    if t == "table" then
        local mt = getmetatable(value)
        if mt and mt.__call then
            return  -- Tables with __call are callable
        end
    end
    
    error(string.format("%s must be a function or callable table, got %s", value_name, t))
end

return Validate
