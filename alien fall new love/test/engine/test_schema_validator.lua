--- Test suite for Schema Validator
--
-- Tests schema validation for units, items, missions, mods, and other game data.
--
-- @module test.engine.test_schema_validator

local test_framework = require "test.framework.test_framework"
local schema_validator = require "engine.schema_validator"

local test_schema_validator = {}

--- Run all schema validator tests
function test_schema_validator.run()
    test_framework.run_suite("Schema Validator", {
        test_unit_validation = test_schema_validator.test_unit_validation,
        test_item_validation = test_schema_validator.test_item_validation,
        test_mission_validation = test_schema_validator.test_mission_validation,
        test_mod_validation = test_schema_validator.test_mod_validation,
        test_enum_validation = test_schema_validator.test_enum_validation,
        test_pattern_validation = test_schema_validator.test_pattern_validation,
        test_collection_validation = test_schema_validator.test_collection_validation,
        test_custom_schema = test_schema_validator.test_custom_schema
    })
end

--- Test unit validation
function test_schema_validator.test_unit_validation()
    -- Valid unit
    local validUnit = {
        id = "soldier_rookie",
        name = "Rookie Soldier",
        type = "soldier",
        stats = {health = 100, tu = 60}
    }
    
    local valid, err = schema_validator.validate(validUnit, "unit")
    test_framework.assert_true(valid, "Valid unit should pass")
    test_framework.assert_nil(err)
    
    -- Missing required field
    local invalidUnit = {
        id = "soldier_rookie",
        name = "Rookie Soldier"
        -- missing type and stats
    }
    
    valid, err = schema_validator.validate(invalidUnit, "unit")
    test_framework.assert_false(valid, "Invalid unit should fail")
    test_framework.assert_not_nil(err)
end

--- Test item validation
function test_schema_validator.test_item_validation()
    -- Valid item
    local validItem = {
        id = "rifle_basic",
        name = "Basic Rifle",
        type = "weapon",
        weight = 4.5,
        cost = 1000
    }
    
    local valid, err = schema_validator.validate(validItem, "item")
    test_framework.assert_true(valid, "Valid item should pass")
    
    -- Wrong type for field
    local invalidItem = {
        id = "rifle_basic",
        name = "Basic Rifle",
        type = "weapon",
        weight = "heavy",  -- should be number
        cost = 1000
    }
    
    valid, err = schema_validator.validate(invalidItem, "item")
    test_framework.assert_false(valid, "Item with wrong type should fail")
    test_framework.assert_not_nil(err)
end

--- Test mission validation
function test_schema_validator.test_mission_validation()
    -- Valid mission
    local validMission = {
        id = "ufo_small",
        name = "Small UFO Crash",
        type = "ufo",
        difficulty = "easy"
    }
    
    local valid, err = schema_validator.validate(validMission, "mission")
    test_framework.assert_true(valid, "Valid mission should pass")
    
    -- Invalid difficulty
    local invalidMission = {
        id = "ufo_large",
        name = "Large UFO",
        type = "ufo",
        difficulty = "nightmare"  -- not in enum
    }
    
    valid, err = schema_validator.validate(invalidMission, "mission")
    test_framework.assert_false(valid, "Mission with invalid difficulty should fail")
    test_framework.assert_not_nil(err)
end

--- Test mod validation
function test_schema_validator.test_mod_validation()
    -- Valid mod
    local validMod = {
        id = "test_mod",
        name = "Test Mod",
        version = "1.0.0",
        author = "Test Author"
    }
    
    local valid, err = schema_validator.validate(validMod, "mod")
    test_framework.assert_true(valid, "Valid mod should pass")
    
    -- Missing required field
    local invalidMod = {
        id = "test_mod",
        name = "Test Mod"
        -- missing version
    }
    
    valid, err = schema_validator.validate(invalidMod, "mod")
    test_framework.assert_false(valid, "Mod missing version should fail")
    test_framework.assert_not_nil(err)
end

--- Test enum validation
function test_schema_validator.test_enum_validation()
    -- Valid enum value
    local validUnit = {
        id = "alien_sectoid",
        name = "Sectoid",
        type = "alien",  -- valid enum value
        stats = {}
    }
    
    local valid = schema_validator.validate(validUnit, "unit")
    test_framework.assert_true(valid, "Valid enum should pass")
    
    -- Invalid enum value
    local invalidUnit = {
        id = "unknown",
        name = "Unknown",
        type = "invalid_type",  -- not in enum
        stats = {}
    }
    
    valid = schema_validator.validate(invalidUnit, "unit")
    test_framework.assert_false(valid, "Invalid enum should fail")
end

--- Test pattern validation
function test_schema_validator.test_pattern_validation()
    -- Valid version pattern
    local validMod = {
        id = "test",
        name = "Test",
        version = "1.2.3"  -- matches semver pattern
    }
    
    local valid = schema_validator.validate(validMod, "mod")
    test_framework.assert_true(valid, "Valid version pattern should pass")
    
    -- Invalid version pattern
    local invalidMod = {
        id = "test",
        name = "Test",
        version = "v1.2"  -- doesn't match semver pattern
    }
    
    valid = schema_validator.validate(invalidMod, "mod")
    test_framework.assert_false(valid, "Invalid version pattern should fail")
end

--- Test collection validation
function test_schema_validator.test_collection_validation()
    local itemCollection = {
        rifle1 = {
            id = "rifle1",
            name = "Rifle 1",
            type = "weapon"
        },
        rifle2 = {
            id = "rifle2",
            name = "Rifle 2",
            type = "weapon"
        },
        invalid = {
            id = "invalid"
            -- missing name and type
        }
    }
    
    local allValid, errors = schema_validator.validateCollection(itemCollection, "item")
    test_framework.assert_false(allValid, "Collection with invalid items should fail")
    test_framework.assert_not_nil(errors.invalid, "Should have error for invalid item")
    test_framework.assert_nil(errors.rifle1, "Valid items should not have errors")
end

--- Test custom schema addition
function test_schema_validator.test_custom_schema()
    -- Add custom schema
    local customSchema = {
        required_fields = {"id", "value"},
        field_types = {
            id = "string",
            value = "number"
        }
    }
    
    schema_validator.addSchema("custom", customSchema)
    
    -- Test with custom schema
    local validData = {id = "test", value = 42}
    local valid = schema_validator.validate(validData, "custom")
    test_framework.assert_true(valid, "Custom schema should work")
    
    -- List schemas should include custom
    local schemas = schema_validator.listSchemas()
    local found = false
    for _, name in ipairs(schemas) do
        if name == "custom" then
            found = true
            break
        end
    end
    test_framework.assert_true(found, "Custom schema should be listed")
end

return test_schema_validator
