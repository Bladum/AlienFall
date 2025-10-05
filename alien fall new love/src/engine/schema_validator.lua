--- Schema Validator
--
-- Validates TOML data against defined schemas from GAME API.toml.
-- Provides field type checking, required field validation, and enum validation.
--
-- GROK: This system ensures all loaded game data meets the expected structure
-- before being used by game systems. Prevents runtime errors from malformed data.
--
-- @module engine.schema_validator
-- @usage local validator = require "engine.schema_validator"
--        local valid, err = validator.validate(data, "unit")

local schema_validator = {}

--- Schema definitions extracted from GAME API.toml
schema_validator.schemas = {
    -- Unit validation schema
    unit = {
        required_fields = {"id", "name", "type", "stats"},
        field_types = {
            id = "string",
            name = "string",
            type = "string",
            stats = "table"
        },
        enum_checks = {
            type = {"soldier", "alien", "civilian", "vehicle"}
        }
    },
    
    -- Item validation schema
    item = {
        required_fields = {"id", "name", "type"},
        field_types = {
            id = "string",
            name = "string",
            type = "string",
            weight = "number",
            cost = "number"
        },
        enum_checks = {
            type = {"weapon", "armor", "equipment", "resource", "lore", "craft"}
        }
    },
    
    -- Mission validation schema
    mission = {
        required_fields = {"id", "name", "type", "difficulty"},
        field_types = {
            id = "string",
            name = "string",
            type = "string",
            difficulty = "string"
        },
        enum_checks = {
            difficulty = {"easy", "medium", "hard", "very_hard"},
            type = {"ufo", "site", "terror", "base_defense", "alien_base"}
        }
    },
    
    -- Mod validation schema
    mod = {
        required_fields = {"id", "name", "version"},
        field_types = {
            id = "string",
            name = "string",
            version = "string",
            author = "string",
            description = "string"
        },
        pattern_checks = {
            version = "^%d+%.%d+%.%d+$" -- Semver pattern
        }
    },
    
    -- Facility validation schema
    facility = {
        required_fields = {"id", "name", "type", "size"},
        field_types = {
            id = "string",
            name = "string",
            type = "string",
            size = "table",
            cost = "number",
            build_time = "number"
        }
    },
    
    -- Research validation schema
    research = {
        required_fields = {"id", "name", "cost"},
        field_types = {
            id = "string",
            name = "string",
            cost = "number",
            time = "number",
            prerequisites = "table"
        }
    }
}

--- Validate data against a schema
-- @param data table: Data to validate
-- @param schemaName string: Name of schema to validate against
-- @return boolean: True if valid
-- @return string: Error message if invalid, nil if valid
function schema_validator.validate(data, schemaName)
    local schema = schema_validator.schemas[schemaName]
    if not schema then
        return false, "Unknown schema: " .. tostring(schemaName)
    end
    
    -- Check required fields
    if schema.required_fields then
        for _, field in ipairs(schema.required_fields) do
            if data[field] == nil then
                return false, string.format("Missing required field: %s", field)
            end
        end
    end
    
    -- Check field types
    if schema.field_types then
        for field, expectedType in pairs(schema.field_types) do
            if data[field] ~= nil then
                local actualType = type(data[field])
                if expectedType == "number" then
                    if actualType ~= "number" then
                        return false, string.format("Field '%s' must be number, got %s", field, actualType)
                    end
                elseif expectedType == "string" then
                    if actualType ~= "string" then
                        return false, string.format("Field '%s' must be string, got %s", field, actualType)
                    end
                elseif expectedType == "boolean" then
                    if actualType ~= "boolean" then
                        return false, string.format("Field '%s' must be boolean, got %s", field, actualType)
                    end
                elseif expectedType == "table" then
                    if actualType ~= "table" then
                        return false, string.format("Field '%s' must be table, got %s", field, actualType)
                    end
                end
            end
        end
    end
    
    -- Check enum constraints
    if schema.enum_checks then
        for field, validValues in pairs(schema.enum_checks) do
            if data[field] ~= nil then
                local found = false
                for _, validValue in ipairs(validValues) do
                    if data[field] == validValue then
                        found = true
                        break
                    end
                end
                if not found then
                    return false, string.format(
                        "Field '%s' has invalid value '%s', must be one of: %s",
                        field, tostring(data[field]), table.concat(validValues, ", ")
                    )
                end
            end
        end
    end
    
    -- Check pattern constraints (for strings)
    if schema.pattern_checks then
        for field, pattern in pairs(schema.pattern_checks) do
            if data[field] ~= nil then
                if type(data[field]) == "string" then
                    if not data[field]:match(pattern) then
                        return false, string.format(
                            "Field '%s' value '%s' does not match required pattern: %s",
                            field, data[field], pattern
                        )
                    end
                end
            end
        end
    end
    
    return true, nil
end

--- Validate a collection of items against a schema
-- @param collection table: Collection of items to validate
-- @param schemaName string: Schema to validate each item against
-- @return boolean: True if all items valid
-- @return table: Map of item id -> error message for failed validations
function schema_validator.validateCollection(collection, schemaName)
    local errors = {}
    local allValid = true
    
    for id, item in pairs(collection) do
        local valid, err = schema_validator.validate(item, schemaName)
        if not valid then
            errors[id] = err
            allValid = false
        end
    end
    
    return allValid, errors
end

--- Add a custom schema
-- @param name string: Schema name
-- @param schema table: Schema definition
function schema_validator.addSchema(name, schema)
    schema_validator.schemas[name] = schema
end

--- Get schema definition
-- @param name string: Schema name
-- @return table: Schema definition or nil
function schema_validator.getSchema(name)
    return schema_validator.schemas[name]
end

--- List all available schemas
-- @return table: Array of schema names
function schema_validator.listSchemas()
    local names = {}
    for name, _ in pairs(schema_validator.schemas) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return schema_validator
