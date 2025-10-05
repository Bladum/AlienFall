--- TOML Schema Validator
--- Provides comprehensive validation for TOML configuration files to catch errors early.
--- Defines schemas for all game configuration types and validates them on load.
---
--- @module core.config.schema_validator
--- @author AlienFall Development Team
--- @copyright 2025

local validate = require('utils.validate')

local SchemaValidator = {}

--- Schema field definition
--- @class FieldSchema
--- @field type string Field type ("string", "number", "boolean", "table", "array")
--- @field required boolean True if field is required
--- @field default any Default value if field is missing
--- @field enum table Array of valid values (for enum validation)
--- @field min number Minimum value (for numbers)
--- @field max number Maximum value (for numbers)
--- @field pattern string Regex pattern (for strings)
--- @field schema table Nested schema (for tables/objects)
--- @field item_schema table Schema for array items

--- Validate a value against a field schema
---
--- @param value any Value to validate
--- @param field_schema FieldSchema Field schema definition
--- @param field_name string Field name for error messages
--- @return boolean, string Success status and error message
local function validateField(value, field_schema, field_name)
    -- Check required
    if value == nil then
        if field_schema.required then
            return false, string.format("Required field '%s' is missing", field_name)
        end
        return true, nil
    end
    
    -- Check type
    local actual_type = type(value)
    local expected_type = field_schema.type
    
    if expected_type == "array" then
        if actual_type ~= "table" then
            return false, string.format("Field '%s' must be an array, got %s", field_name, actual_type)
        end
        -- Validate array items if schema provided
        if field_schema.item_schema then
            for i, item in ipairs(value) do
                local ok, err = validateField(item, field_schema.item_schema, field_name .. "[" .. i .. "]")
                if not ok then
                    return false, err
                end
            end
        end
    elseif expected_type ~= actual_type then
        return false, string.format("Field '%s' must be %s, got %s", field_name, expected_type, actual_type)
    end
    
    -- Type-specific validation
    if expected_type == "string" then
        -- Check enum
        if field_schema.enum then
            local valid = false
            for _, allowed in ipairs(field_schema.enum) do
                if value == allowed then
                    valid = true
                    break
                end
            end
            if not valid then
                return false, string.format("Field '%s' must be one of %s, got '%s'", 
                    field_name, table.concat(field_schema.enum, ", "), value)
            end
        end
        
        -- Check pattern
        if field_schema.pattern then
            if not value:match(field_schema.pattern) then
                return false, string.format("Field '%s' does not match pattern %s", field_name, field_schema.pattern)
            end
        end
        
    elseif expected_type == "number" then
        -- Check range
        if field_schema.min and value < field_schema.min then
            return false, string.format("Field '%s' must be >= %s, got %s", field_name, field_schema.min, value)
        end
        if field_schema.max and value > field_schema.max then
            return false, string.format("Field '%s' must be <= %s, got %s", field_name, field_schema.max, value)
        end
        
    elseif expected_type == "table" then
        -- Validate nested schema
        if field_schema.schema then
            local ok, err = SchemaValidator.validate(value, field_schema.schema, field_name)
            if not ok then
                return false, err
            end
        end
    end
    
    return true, nil
end

--- Validate data against a schema
---
--- @param data table Data to validate
--- @param schema table Schema definition (field_name -> FieldSchema)
--- @param context string Optional context for error messages
--- @return boolean, string Success status and error message
function SchemaValidator.validate(data, schema, context)
    context = context or "data"
    
    if type(data) ~= "table" then
        return false, string.format("%s must be a table, got %s", context, type(data))
    end
    
    -- Validate each field in schema
    for field_name, field_schema in pairs(schema) do
        local value = data[field_name]
        local ok, err = validateField(value, field_schema, context .. "." .. field_name)
        if not ok then
            return false, err
        end
    end
    
    return true, nil
end

--- Apply defaults to data based on schema
--- Fills in missing fields with default values
---
--- @param data table Data to fill with defaults
--- @param schema table Schema definition
--- @return table Data with defaults applied
function SchemaValidator.applyDefaults(data, schema)
    data = data or {}
    
    for field_name, field_schema in pairs(schema) do
        if data[field_name] == nil and field_schema.default ~= nil then
            data[field_name] = field_schema.default
        end
    end
    
    return data
end

--- Common schema definitions for game data

--- Unit class schema
SchemaValidator.SCHEMAS = {}

SchemaValidator.SCHEMAS.unit_class = {
    id = {type = "string", required = true, pattern = "^[a-z_]+$"},
    name = {type = "string", required = true},
    description = {type = "string", required = false},
    base_stats = {
        type = "table",
        required = true,
        schema = {
            health = {type = "number", required = true, min = 1},
            armor = {type = "number", required = true, min = 0},
            time_units = {type = "number", required = true, min = 1},
            stamina = {type = "number", required = true, min = 1},
            strength = {type = "number", required = true, min = 1},
            accuracy = {type = "number", required = true, min = 0, max = 100},
            reactions = {type = "number", required = true, min = 0, max = 100},
            bravery = {type = "number", required = true, min = 0, max = 100}
        }
    },
    sprite = {type = "string", required = false},
    cost = {type = "number", required = false, min = 0, default = 0}
}

--- Weapon schema
SchemaValidator.SCHEMAS.weapon = {
    id = {type = "string", required = true, pattern = "^[a-z_]+$"},
    name = {type = "string", required = true},
    description = {type = "string", required = false},
    damage = {type = "number", required = true, min = 0},
    damage_type = {
        type = "string",
        required = true,
        enum = {"kinetic", "energy", "explosive", "incendiary", "acid"}
    },
    accuracy_modifier = {type = "number", required = false, default = 0},
    range = {type = "number", required = true, min = 1},
    ammo_capacity = {type = "number", required = false, min = 1},
    reload_cost = {type = "number", required = false, min = 0},
    cost = {type = "number", required = false, min = 0, default = 0},
    sprite = {type = "string", required = false}
}

--- Facility schema
SchemaValidator.SCHEMAS.facility = {
    id = {type = "string", required = true, pattern = "^[a-z_]+$"},
    name = {type = "string", required = true},
    description = {type = "string", required = false},
    build_cost = {type = "number", required = true, min = 0},
    build_time = {type = "number", required = true, min = 1},
    maintenance_cost = {type = "number", required = false, default = 0},
    size = {
        type = "table",
        required = true,
        schema = {
            width = {type = "number", required = true, min = 1},
            height = {type = "number", required = true, min = 1}
        }
    },
    provides = {type = "array", required = false, item_schema = {type = "string"}},
    sprite = {type = "string", required = false}
}

--- Research schema
SchemaValidator.SCHEMAS.research = {
    id = {type = "string", required = true, pattern = "^[a-z_]+$"},
    name = {type = "string", required = true},
    description = {type = "string", required = false},
    cost = {type = "number", required = true, min = 1},
    requires = {type = "array", required = false, item_schema = {type = "string"}},
    unlocks = {type = "array", required = false, item_schema = {type = "string"}},
    category = {
        type = "string",
        required = false,
        enum = {"weapons", "armor", "craft", "facility", "alien"}
    }
}

--- Craft schema
SchemaValidator.SCHEMAS.craft = {
    id = {type = "string", required = true, pattern = "^[a-z_]+$"},
    name = {type = "string", required = true},
    description = {type = "string", required = false},
    cost = {type = "number", required = true, min = 0},
    build_time = {type = "number", required = false, min = 1, default = 1},
    speed = {type = "number", required = true, min = 1},
    fuel_capacity = {type = "number", required = true, min = 1},
    weapon_slots = {type = "number", required = false, min = 0, default = 0},
    soldier_capacity = {type = "number", required = true, min = 1},
    sprite = {type = "string", required = false}
}

--- Mod manifest schema
SchemaValidator.SCHEMAS.mod_manifest = {
    mod_id = {type = "string", required = true, pattern = "^[a-z_]+$"},
    version = {type = "string", required = true, pattern = "^%d+%.%d+%.%d+$"},
    name = {type = "string", required = true},
    author = {type = "string", required = false},
    description = {type = "string", required = false},
    dependencies = {type = "array", required = false, item_schema = {type = "string"}},
    load_priority = {type = "number", required = false, min = 0, max = 100, default = 50}
}

--- Validate and load a TOML file with schema
---
--- @param filepath string Path to TOML file
--- @param schema_name string Schema name from SCHEMAS
--- @return table|nil, string Loaded data or nil, error message
function SchemaValidator.validateFile(filepath, schema_name)
    local schema = SchemaValidator.SCHEMAS[schema_name]
    if not schema then
        return nil, string.format("Unknown schema: %s", schema_name)
    end
    
    -- Load TOML file using SafeIO
    local SafeIO = require('utils.safe_io')
    local data = SafeIO.safe_load_toml(filepath)
    if not data then
        return nil, string.format("Failed to load TOML file: %s", filepath)
    end
    
    -- Apply defaults
    data = SchemaValidator.applyDefaults(data, schema)
    
    -- Validate against schema
    local ok, err = SchemaValidator.validate(data, schema, filepath)
    if not ok then
        return nil, err
    end
    
    return data, nil
end

--- Validate multiple files with same schema
---
--- @param filepaths table Array of file paths
--- @param schema_name string Schema name
--- @return table Array of loaded data entries
--- @return table Array of errors (if any)
function SchemaValidator.validateFiles(filepaths, schema_name)
    local results = {}
    local errors = {}
    
    for _, filepath in ipairs(filepaths) do
        local data, err = SchemaValidator.validateFile(filepath, schema_name)
        if data then
            table.insert(results, data)
        else
            table.insert(errors, {file = filepath, error = err})
        end
    end
    
    return results, errors
end

return SchemaValidator
