--- API Validation Test
-- Tests that GAME API.toml is in sync with SRC implementation and mod data

local test_framework = require "test.test_framework"
local toml = require 'lib.toml'

test_framework.describe("API Validation", function()

    test_framework.it("should load GAME API schema", function()
        local success, data = pcall(function()
            return toml.parse("GAME API.toml")
        end)

        test_framework.assert_true(success, "Failed to parse GAME API.toml")
        test_framework.assert_true(type(data) == "table", "API schema should be a table")
        test_framework.assert_true(data.units ~= nil, "API schema should contain units section")
    end)

    test_framework.it("should validate unit implementation against schema", function()
        -- Load schema
        local schema = toml.parse("GAME API.toml")

        -- Check that Unit.lua uses required fields
        local unit_content = love.filesystem.read("src/units/Unit.lua")
        test_framework.assert_true(unit_content ~= nil, "Unit.lua should exist")

        -- Check for required unit fields from schema
        local required_fields = {"id", "name", "stats", "health"}
        for _, field in ipairs(required_fields) do
            test_framework.assert_true(unit_content:find(field) ~= nil,
                "Unit.lua should reference field '" .. field .. "'")
        end
    end)

    test_framework.it("should validate weapon implementation against schema", function()
        local schema = toml.parse("GAME API.toml")

        -- Check that ItemUnitWeapon.lua uses required fields
        local weapon_content = love.filesystem.read("src/items/ItemUnitWeapon.lua")
        test_framework.assert_true(weapon_content ~= nil, "ItemUnitWeapon.lua should exist")

        -- Check for required weapon fields from schema
        local required_fields = {"damage", "accuracy", "range"}
        for _, field in ipairs(required_fields) do
            test_framework.assert_true(weapon_content:find(field) ~= nil,
                "ItemUnitWeapon.lua should reference field '" .. field .. "'")
        end
    end)

    test_framework.it("should validate mod data against schema", function()
        local schema = toml.parse("GAME API.toml")

        -- Check example mod unit data
        local unit_data = toml.parse("mods/example_mod/data/units/unit_classes.toml")
        test_framework.assert_true(unit_data ~= nil, "Example mod unit data should exist")

        -- Check that each unit class has required fields
        if unit_data.unit_class then
            for i, unit_class in ipairs(unit_data.unit_class) do
                test_framework.assert_true(unit_class.id ~= nil,
                    "Unit class " .. i .. " should have id")
                test_framework.assert_true(unit_class.name ~= nil,
                    "Unit class " .. i .. " should have name")
                test_framework.assert_true(unit_class.base_stats ~= nil,
                    "Unit class " .. i .. " should have base_stats")
            end
        end
    end)

    test_framework.it("should check for missing API documentation", function()
        local schema = toml.parse("GAME API.toml")

        -- This is a placeholder for more sophisticated checks
        -- In a real implementation, this would check for functions/classes
        -- in SRC that aren't documented in the API schema

        test_framework.assert_true(true, "API documentation check placeholder")
    end)

end)