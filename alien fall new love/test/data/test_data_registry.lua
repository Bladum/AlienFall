--- Test suite for Data Registry
--
-- Tests the data registry functionality for catalog management and data retrieval.
--
-- @module test.test_data_registry

local test_framework = require "test.framework.test_framework"
local DataRegistry = require "core.services.data_registry"

local test_data_registry = {}

--- Helper function to load Lua mock data
local function load_lua_mock(filename)
    local path = "test/mock/services/" .. filename
    return dofile(path)
end

--- Run all data registry tests
function test_data_registry.run()
    test_framework.run_suite("Data Registry", {
        test_initialization = test_data_registry.test_initialization,
        test_register_catalog = test_data_registry.test_register_catalog,
        test_get_catalog = test_data_registry.test_get_catalog,
        test_get_entry = test_data_registry.test_get_entry,
        test_catalog_with_source = test_data_registry.test_catalog_with_source,
        test_multiple_catalogs = test_data_registry.test_multiple_catalogs,
        test_empty_catalog = test_data_registry.test_empty_catalog
    })
end

--- Test data registry initialization
function test_data_registry.test_initialization()
    local registry = DataRegistry.new()

    test_framework.assert_not_nil(registry)
    test_framework.assert_not_nil(registry.catalogs)
    test_framework.assert_equal(type(registry.catalogs), "table")
    test_framework.assert_nil(registry.logger)
    test_framework.assert_nil(registry.telemetry)
end

--- Test registering a catalog
function test_data_registry.test_register_catalog()
    local registry = DataRegistry.new()

    local test_entries = load_lua_mock("items_catalog.lua")

    registry:registerCatalog("items", test_entries)

    test_framework.assert_not_nil(registry.catalogs.items)
    test_framework.assert_equal(registry.catalogs.items.item1.name, "Sword")
    test_framework.assert_equal(registry.catalogs.items.item2.defense, 5)
end

--- Test getting a catalog
function test_data_registry.test_get_catalog()
    local registry = DataRegistry.new()

    local test_entries = load_lua_mock("units_catalog.lua")

    registry:registerCatalog("units", test_entries)

    local catalog = registry:getCatalog("units")
    test_framework.assert_not_nil(catalog)
    test_framework.assert_equal(catalog.unit1.name, "Soldier")
    test_framework.assert_equal(catalog.unit2.health, 80)
end

--- Test getting a specific entry
function test_data_registry.test_get_entry()
    local registry = DataRegistry.new()

    local test_entries = load_lua_mock("weapons_catalog.lua")

    registry:registerCatalog("weapons", test_entries)

    local entry = registry:get("weapons", "weapon1")
    test_framework.assert_not_nil(entry)
    test_framework.assert_equal(entry.name, "Laser Gun")
    test_framework.assert_equal(entry.power, 50)

    -- Test non-existent entry
    local missing = registry:get("weapons", "nonexistent")
    test_framework.assert_nil(missing)

    -- Test non-existent catalog
    local missing_catalog = registry:get("nonexistent", "key")
    test_framework.assert_nil(missing_catalog)
end

--- Test catalog registration with source mod
function test_data_registry.test_catalog_with_source()
    local registry = DataRegistry.new()

    local test_entries = load_lua_mock("facilities_catalog.lua")

    registry:registerCatalog("facilities", test_entries, "core_mod")

    test_framework.assert_equal(registry.catalogs.facilities.facility1.source_mod, "core_mod")
    test_framework.assert_equal(registry.catalogs.facilities.facility2.source_mod, "core_mod")
end

--- Test multiple catalogs
function test_data_registry.test_multiple_catalogs()
    local registry = DataRegistry.new()

    -- Register weapons catalog
    local weapons = load_lua_mock("weapons_catalog_multi.lua")
    registry:registerCatalog("weapons", weapons)

    -- Register armor catalog
    local armor = load_lua_mock("armor_catalog.lua")
    registry:registerCatalog("armor", armor)

    -- Test both catalogs exist
    test_framework.assert_not_nil(registry.catalogs.weapons)
    test_framework.assert_not_nil(registry.catalogs.armor)

    -- Test content
    test_framework.assert_equal(registry:get("weapons", "rifle").damage, 40)
    test_framework.assert_equal(registry:get("armor", "heavy").defense, 25)
end

--- Test getting empty/non-existent catalog
function test_data_registry.test_empty_catalog()
    local registry = DataRegistry.new()

    local empty_catalog = registry:getCatalog("nonexistent")
    test_framework.assert_not_nil(empty_catalog)
    test_framework.assert_equal(type(empty_catalog), "table")

    -- Should return empty table for non-existent catalogs
    local count = 0
    for _ in pairs(empty_catalog) do
        count = count + 1
    end
    test_framework.assert_equal(count, 0)
end

return test_data_registry