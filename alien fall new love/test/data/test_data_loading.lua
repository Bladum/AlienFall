--- Test suite for Data Loading
--
-- Tests data loading functionality including mod loading and data registry integration.
--
-- @module test.test_data_loading

local test_framework = require "test.framework.test_framework"
local DataRegistry = require "core.services.data_registry"
local toml_loader = require "core.util.toml_loader"

local test_data_loading = {}

--- Helper function to load TOML mock data
local function load_toml_mock(filename)
    local path = "test/mock/data/" .. filename
    local file = io.open(path, "r")
    if not file then
        error("Could not load TOML mock: " .. path)
    end
    local content = file:read("*all")
    file:close()
    return toml_loader.parse(content)
end

--- Helper function to load Lua mock data
local function load_lua_mock(filename)
    local path = "test/mock/data/" .. filename
    return dofile(path)
end

--- Run all data loading tests
function test_data_loading.run()
    test_framework.run_suite("Data Loading", {
        test_mod_data_loading = test_data_loading.test_mod_data_loading,
        test_catalog_registration = test_data_loading.test_catalog_registration,
        test_data_validation = test_data_loading.test_data_validation,
        test_mod_integration = test_data_loading.test_mod_integration
    })
end

--- Test loading mod data from TOML
function test_data_loading.test_mod_data_loading()
    local mod_data = load_toml_mock("mod_data.toml")
    test_framework.assert_not_nil(mod_data)
    test_framework.assert_equal(mod_data.mod.id, "test_mod")
    test_framework.assert_equal(mod_data.mod.name, "Test Mod")
    test_framework.assert_table_equal(mod_data.content.units, {"soldier.toml", "medic.toml"})
    test_framework.assert_table_equal(mod_data.content.items, {"rifle.toml"})
end

--- Test catalog registration from mod data
function test_data_loading.test_catalog_registration()
    local registry = DataRegistry.new()

    -- Load sample unit data
    local units_data = load_lua_mock("units_data.lua")

    -- Register units catalog
    registry:registerCatalog("units", units_data, "test_mod")

    -- Verify registration
    local units = registry:getCatalog("units")
    test_framework.assert_not_nil(units)
    test_framework.assert_equal(units.soldier.name, "Soldier")
    test_framework.assert_equal(units.medic.healing, 20)
    test_framework.assert_equal(units.soldier.source_mod, "test_mod")
    test_framework.assert_equal(units.medic.source_mod, "test_mod")
end

--- Test data validation during loading
function test_data_loading.test_data_validation()
    -- Test valid mod config
    local valid_mod = load_lua_mock("valid_mod.lua")

    local is_valid, error_msg = toml_loader.validateModConfig(valid_mod)
    test_framework.assert_true(is_valid)
    test_framework.assert_nil(error_msg)

    -- Test invalid mod config (missing required fields)
    local invalid_mod = load_lua_mock("invalid_mod.lua")

    local is_invalid, error_msg2 = toml_loader.validateModConfig(invalid_mod)
    test_framework.assert_false(is_invalid)
    test_framework.assert_not_nil(error_msg2)
end

--- Test complete mod integration workflow
function test_data_loading.test_mod_integration()
    local registry = DataRegistry.new()

    -- Load mod config
    local mod_config = load_lua_mock("mod_config.lua")

    -- Validate mod config
    local valid, err = toml_loader.validateModConfig(mod_config)
    test_framework.assert_true(valid, err)

    -- Load and register unit data
    local unit_data = load_lua_mock("unit_data.lua")
    registry:registerCatalog("units", unit_data, mod_config.mod.id)

    -- Load and register facility data
    local facility_data = load_lua_mock("facility_data.lua")
    registry:registerCatalog("facilities", facility_data, mod_config.mod.id)

    -- Verify integration
    local marine = registry:get("units", "marine")
    test_framework.assert_not_nil(marine)
    test_framework.assert_equal(marine.name, "Marine")
    test_framework.assert_equal(marine.class, "infantry")

    local barracks = registry:get("facilities", "barracks")
    test_framework.assert_not_nil(barracks)
    test_framework.assert_equal(barracks.cost, 1500)
    test_framework.assert_equal(barracks.type, "training")

    -- Verify source tracking
    test_framework.assert_equal(marine.source_mod, "integration_test_mod")
    test_framework.assert_equal(barracks.source_mod, "integration_test_mod")
end

return test_data_loading