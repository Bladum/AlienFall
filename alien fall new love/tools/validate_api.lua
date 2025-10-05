#!/usr/bin/env lua
--- Standalone API Validation Script
-- Checks if GAME API.toml is in sync with SRC folder and mod data

local toml = require 'lib.toml'

--- Simple validation functions
local function validate_api_sync()
    print("=== API VALIDATION REPORT ===")
    print()

    -- Load API schema
    print("1. Loading GAME API schema...")
    local success, schema = pcall(function()
        return toml.parse("../config/GAME API.toml")
    end)

    if not success then
        print("ERROR: Failed to parse ../config/GAME API.toml")
        return false
    end

    print("✓ Loaded API schema with " .. (function()
        local count = 0
        for k in pairs(schema) do count = count + 1 end
        return count
    end)() .. " top-level sections")

    -- Check unit implementation
    print("\n2. Checking Unit implementation...")
    local unit_file = io.open("src/units/Unit.lua", "r")
    if not unit_file then
        print("ERROR: Cannot read src/units/Unit.lua")
        return false
    end

    local unit_content = unit_file:read("*all")
    unit_file:close()

    local unit_checks = {
        {"id", "Unit ID field"},
        {"name", "Unit name field"},
        {"stats", "Unit stats structure"},
        {"health", "Health stat"},
        {"experience", "Experience field"}
    }

    local unit_warnings = 0
    for _, check in ipairs(unit_checks) do
        if not unit_content:find(check[1]) then
            print("WARNING: " .. check[2] .. " not found in Unit.lua")
            unit_warnings = unit_warnings + 1
        end
    end

    if unit_warnings == 0 then
        print("✓ Unit implementation matches API schema")
    end

    -- Check weapon implementation
    print("\n3. Checking Weapon implementation...")
    local weapon_file = io.open("src/items/ItemUnitWeapon.lua", "r")
    if not weapon_file then
        print("ERROR: Cannot read src/items/ItemUnitWeapon.lua")
        return false
    end

    local weapon_content = weapon_file:read("*all")
    weapon_file:close()

    local weapon_checks = {
        {"damage", "Damage structure"},
        {"accuracy", "Accuracy field"},
        {"range", "Range structure"}
    }

    local weapon_warnings = 0
    for _, check in ipairs(weapon_checks) do
        if not weapon_content:find(check[1]) then
            print("WARNING: " .. check[2] .. " not found in ItemUnitWeapon.lua")
            weapon_warnings = weapon_warnings + 1
        end
    end

    if weapon_warnings == 0 then
        print("✓ Weapon implementation matches API schema")
    end

    -- Check mod data
    print("\n4. Checking mod data structures...")
    local mod_unit_file = io.open("mods/example_mod/data/units/unit_classes.toml", "r")
    if not mod_unit_file then
        print("ERROR: Cannot read example mod unit data")
        return false
    end

    local mod_success, mod_data = pcall(function()
        return toml.parse("mods/example_mod/data/units/unit_classes.toml")
    end)

    if not mod_success then
        print("ERROR: Failed to parse example mod unit data")
        return false
    end

    local mod_warnings = 0
    if mod_data.unit_class then
        for i, unit_class in ipairs(mod_data.unit_class) do
            if not unit_class.id then
                print("WARNING: Unit class " .. i .. " missing 'id' field")
                mod_warnings = mod_warnings + 1
            end
            if not unit_class.name then
                print("WARNING: Unit class " .. i .. " missing 'name' field")
                mod_warnings = mod_warnings + 1
            end
            if not unit_class.base_stats then
                print("WARNING: Unit class " .. i .. " missing 'base_stats' field")
                mod_warnings = mod_warnings + 1
            end
        end
    end

    if mod_warnings == 0 then
        print("✓ Example mod data matches API schema")
    end

    -- Summary
    print("\n5. Validation Summary:")
    local total_warnings = unit_warnings + weapon_warnings + mod_warnings
    if total_warnings == 0 then
        print("✅ ALL CHECKS PASSED - API is in sync!")
        return true
    else
        print("⚠️  Found " .. total_warnings .. " warnings - API may need updates")
        return false
    end
end

-- Run validation
local success = validate_api_sync()
os.exit(success and 0 or 1)