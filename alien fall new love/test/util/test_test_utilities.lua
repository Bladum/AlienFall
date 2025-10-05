--- Test suite for Test Utilities
--
-- Tests the test utility functions and helpers.
--
-- @module test.test_test_utilities

local test_framework = require "test.framework.test_framework"
local test_utilities = require "test.util.test_utilities"

local test_test_utilities = {}

--- Run all test utilities tests
function test_test_utilities.run()
    test_framework.run_suite("Test Utilities", {
        test_sample_mod_config = test_test_utilities.test_sample_mod_config,
        test_sample_unit_data = test_test_utilities.test_sample_unit_data,
        test_sample_item_data = test_test_utilities.test_sample_item_data,
        test_sample_facility_data = test_test_utilities.test_sample_facility_data,
        test_generate_test_toml = test_test_utilities.test_generate_test_toml,
        test_mock_logger = test_test_utilities.test_mock_logger,
        test_mock_telemetry = test_test_utilities.test_mock_telemetry
    })
end

--- Test sample mod config generation
function test_test_utilities.test_sample_mod_config()
    local config = test_utilities.create_sample_mod_config()

    test_framework.assert_not_nil(config)
    test_framework.assert_not_nil(config.mod)
    test_framework.assert_equal(config.mod.id, "sample_mod")
    test_framework.assert_equal(config.mod.name, "Sample Mod")
    test_framework.assert_equal(config.mod.version, "1.0.0")
    test_framework.assert_table_equal(config.content.units, {"soldier.toml", "tank.toml"})
end

--- Test sample unit data generation
function test_test_utilities.test_sample_unit_data()
    local units = test_utilities.create_sample_unit_data()

    test_framework.assert_not_nil(units)
    test_framework.assert_not_nil(units.soldier)
    test_framework.assert_equal(units.soldier.name, "Soldier")
    test_framework.assert_equal(units.soldier.health, 100)
    test_framework.assert_equal(units.soldier.class, "infantry")

    test_framework.assert_not_nil(units.tank)
    test_framework.assert_equal(units.tank.name, "Tank")
    test_framework.assert_equal(units.tank.health, 500)
    test_framework.assert_equal(units.tank.class, "vehicle")
end

--- Test sample item data generation
function test_test_utilities.test_sample_item_data()
    local items = test_utilities.create_sample_item_data()

    test_framework.assert_not_nil(items)
    test_framework.assert_not_nil(items.rifle)
    test_framework.assert_equal(items.rifle.name, "Assault Rifle")
    test_framework.assert_equal(items.rifle.type, "weapon")
    test_framework.assert_equal(items.rifle.damage, 35)

    test_framework.assert_not_nil(items.armor)
    test_framework.assert_equal(items.armor.name, "Body Armor")
    test_framework.assert_equal(items.armor.type, "armor")
    test_framework.assert_equal(items.armor.defense, 20)
end

--- Test sample facility data generation
function test_test_utilities.test_sample_facility_data()
    local facilities = test_utilities.create_sample_facility_data()

    test_framework.assert_not_nil(facilities)
    test_framework.assert_not_nil(facilities.barracks)
    test_framework.assert_equal(facilities.barracks.name, "Barracks")
    test_framework.assert_equal(facilities.barracks.type, "training")
    test_framework.assert_equal(facilities.barracks.cost, 1000)
    test_framework.assert_equal(facilities.barracks.capacity, 20)
end

--- Test TOML generation
function test_test_utilities.test_generate_test_toml()
    local toml = test_utilities.generate_test_toml("test_mod")

    test_framework.assert_not_nil(toml)
    -- Should contain the mod definition
    test_framework.assert_true(toml:find('id = "test_mod"') ~= nil)
    test_framework.assert_true(toml:find('name = "Test Mod test_mod"') ~= nil)
    test_framework.assert_true(toml:find('version = "1.0.0"') ~= nil)
end

--- Test mock logger creation
function test_test_utilities.test_mock_logger()
    local logger = test_utilities.create_mock_logger()

    test_framework.assert_not_nil(logger)
    test_framework.assert_equal(type(logger.debug), "function")
    test_framework.assert_equal(type(logger.info), "function")
    test_framework.assert_equal(type(logger.warn), "function")
    test_framework.assert_equal(type(logger.error), "function")
    test_framework.assert_equal(logger.level, "debug")
end

--- Test mock telemetry creation
function test_test_utilities.test_mock_telemetry()
    local telemetry = test_utilities.create_mock_telemetry()

    test_framework.assert_not_nil(telemetry)
    test_framework.assert_equal(type(telemetry.record), "function")
    test_framework.assert_true(telemetry.enabled)
end

return test_test_utilities