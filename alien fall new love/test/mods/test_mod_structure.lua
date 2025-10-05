--- Test suite for Mod Structure
--
-- Tests the new mod structure with data folders and array-based TOML files.
--
-- @module test.test_mod_structure

local test_framework = require "test.framework.test_framework"
local toml_loader = require "core.util.toml_loader"

local test_mod_structure = {}

--- Helper function to load TOML mock data
local function load_toml_mock(filename)
    local path = "test/mock/mods/" .. filename
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
    local path = "test/mock/mods/" .. filename
    return dofile(path)
end

--- Run all mod structure tests
function test_mod_structure.run()
    test_framework.run_suite("Mod Structure", {
        test_main_toml_parsing = test_mod_structure.test_main_toml_parsing,
        test_units_data_parsing = test_mod_structure.test_units_data_parsing,
        test_items_data_parsing = test_mod_structure.test_items_data_parsing,
        test_facilities_data_parsing = test_mod_structure.test_facilities_data_parsing,
        test_missions_data_parsing = test_mod_structure.test_missions_data_parsing,
        test_mod_content_structure = test_mod_structure.test_mod_content_structure
    })
end

--- Test parsing the main.toml file
function test_mod_structure.test_main_toml_parsing()
    local data = load_toml_mock("main.toml")
    test_framework.assert_not_nil(data)
    test_framework.assert_equal(data.mod.id, "example_mod")
    test_framework.assert_equal(data.mod.name, "Example Mod")
    -- Content section is no longer needed - content is auto-discovered
    test_framework.assert_nil(data.content)
end

--- Test parsing units data with arrays
function test_mod_structure.test_units_data_parsing()
    local data = load_toml_mock("units.toml")
    test_framework.assert_not_nil(data)
    test_framework.assert_not_nil(data.units)
    test_framework.assert_equal(#data.units, 2)

    -- Check first unit
    test_framework.assert_equal(data.units[1].id, "soldier")
    test_framework.assert_equal(data.units[1].name, "Soldier")
    test_framework.assert_equal(data.units[1].health, 100)
    test_framework.assert_equal(data.units[1].strength, 40)

    -- Check second unit
    test_framework.assert_equal(data.units[2].id, "medic")
    test_framework.assert_equal(data.units[2].name, "Medic")
    test_framework.assert_equal(data.units[2].health, 80)
    test_framework.assert_equal(data.units[2].strength, 30)
end

--- Test parsing items data with multiple arrays
function test_mod_structure.test_items_data_parsing()
    local data = load_toml_mock("items.toml")
    test_framework.assert_not_nil(data)

    -- Check weapons array
    test_framework.assert_not_nil(data.weapons)
    test_framework.assert_equal(#data.weapons, 2)
    test_framework.assert_equal(data.weapons[1].id, "rifle")
    test_framework.assert_equal(data.weapons[1].damage, 35)
    test_framework.assert_equal(data.weapons[2].id, "pistol")
    test_framework.assert_equal(data.weapons[2].damage, 20)

    -- Check armor array
    test_framework.assert_not_nil(data.armor)
    test_framework.assert_equal(#data.armor, 2)
    test_framework.assert_equal(data.armor[1].id, "helmet")
    test_framework.assert_equal(data.armor[1].defense, 5)
    test_framework.assert_equal(data.armor[2].id, "vest")
    test_framework.assert_equal(data.armor[2].defense, 15)
end

--- Test parsing facilities data
function test_mod_structure.test_facilities_data_parsing()
    local data = load_toml_mock("facilities.toml")
    test_framework.assert_not_nil(data)
    test_framework.assert_not_nil(data.facilities)
    test_framework.assert_equal(#data.facilities, 2)

    test_framework.assert_equal(data.facilities[1].id, "barracks")
    test_framework.assert_equal(data.facilities[1].cost, 1000)
    test_framework.assert_equal(data.facilities[1].effects.capacity, 20)

    test_framework.assert_equal(data.facilities[2].id, "lab")
    test_framework.assert_equal(data.facilities[2].cost, 1500)
    test_framework.assert_equal(data.facilities[2].effects.research_bonus, 15)
end

--- Test parsing missions data
function test_mod_structure.test_missions_data_parsing()
    local data = load_toml_mock("missions.toml")
    test_framework.assert_not_nil(data)
    test_framework.assert_not_nil(data.missions)
    test_framework.assert_equal(#data.missions, 2)

    test_framework.assert_equal(data.missions[1].id, "recon")
    test_framework.assert_equal(data.missions[1].difficulty, "easy")
    test_framework.assert_equal(data.missions[1].rewards.experience, 50)
    test_framework.assert_equal(data.missions[1].rewards.credits, 15000)

    test_framework.assert_equal(data.missions[2].id, "combat")
    test_framework.assert_equal(data.missions[2].difficulty, "hard")
    test_framework.assert_equal(data.missions[2].rewards.experience, 200)
    test_framework.assert_equal(data.missions[2].rewards.credits, 50000)
end

--- Test overall mod content structure validation
function test_mod_structure.test_mod_content_structure()
    -- Test that the mod structure is valid according to our schema
    local mod_config = load_lua_mock("mod_config.lua")

    local valid, err = toml_loader.validateModConfig(mod_config)
    test_framework.assert_true(valid, err)
    test_framework.assert_nil(err)
end

return test_mod_structure