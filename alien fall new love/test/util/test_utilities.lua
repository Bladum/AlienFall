--- Test Utilities
--
-- Utility functions for testing, including test data generation and helpers.
--
-- @module test.test_utilities

local test_utilities = {}

--- Create a sample mod configuration for testing
-- @return table: Sample mod config
function test_utilities.create_sample_mod_config()
    return {
        mod = {
            id = "sample_mod",
            name = "Sample Mod",
            version = "1.0.0",
            author = "Test Author",
            description = "A sample mod for testing"
        },
        dependencies = {
            required_mods = {"core"}
        },
        content = {
            units = {"soldier.toml", "tank.toml"},
            items = {"rifle.toml", "armor.toml"},
            facilities = {"barracks.toml"}
        }
    }
end

--- Create sample unit data for testing
-- @return table: Sample unit data
function test_utilities.create_sample_unit_data()
    return {
        soldier = {
            id = "soldier",
            name = "Soldier",
            health = 100,
            armor = 10,
            damage = 25,
            range = 15,
            class = "infantry",
            cost = 50
        },
        tank = {
            id = "tank",
            name = "Tank",
            health = 500,
            armor = 100,
            damage = 150,
            range = 30,
            class = "vehicle",
            cost = 500
        }
    }
end

--- Create sample item data for testing
-- @return table: Sample item data
function test_utilities.create_sample_item_data()
    return {
        rifle = {
            id = "rifle",
            name = "Assault Rifle",
            type = "weapon",
            damage = 35,
            range = 25,
            ammo_capacity = 30,
            weight = 4,
            cost = 200
        },
        armor = {
            id = "armor",
            name = "Body Armor",
            type = "armor",
            defense = 20,
            weight = 8,
            cost = 150
        }
    }
end

--- Create sample facility data for testing
-- @return table: Sample facility data
function test_utilities.create_sample_facility_data()
    return {
        barracks = {
            id = "barracks",
            name = "Barracks",
            type = "training",
            cost = 1000,
            maintenance = 100,
            capacity = 20,
            build_time = 15
        }
    }
end

--- Generate a temporary TOML file content for testing
-- @param mod_id string: Mod ID
-- @return string: TOML content
function test_utilities.generate_test_toml(mod_id)
    return string.format([[
[mod]
id = "%s"
name = "Test Mod %s"
version = "1.0.0"
author = "Test Suite"

[content]
units = ["test_unit.toml"]
items = ["test_item.toml"]

[test_unit]
name = "Test Unit"
health = 100

[test_item]
name = "Test Item"
damage = 25
]], mod_id, mod_id)
end

--- Create a mock logger for testing
-- @return table: Mock logger object
function test_utilities.create_mock_logger()
    return {
        debug = function(self, message) end,
        info = function(self, message) end,
        warn = function(self, message) end,
        error = function(self, message) end,
        level = "debug"
    }
end

--- Create a mock telemetry service for testing
-- @return table: Mock telemetry object
function test_utilities.create_mock_telemetry()
    return {
        record = function(self, event, data) end,
        enabled = true
    }
end

return test_utilities