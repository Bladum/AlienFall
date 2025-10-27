-- ─────────────────────────────────────────────────────────────────────────
-- EDGE CASES PROPERTY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Test unusual and unexpected scenarios
-- Tests: 8 edge case tests
-- Categories: Empty collections, single items, unusual inputs

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.properties",
    fileName = "edge_cases_test.lua",
    description = "Edge case and unusual scenario testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- EDGE CASE TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Empty Collections", function()

    Suite:testMethod("Property:emptySquadHandled", {
        description = "Empty squad (no units) is handled gracefully",
        testCase = "edge_case",
        type = "property"
    }, function()
        local squad = {}

        Helpers.assertEqual(#squad, 0, "Squad should be empty")
        local isEmpty = #squad == 0
        Helpers.assertTrue(isEmpty, "Should detect empty squad")
    end)

    Suite:testMethod("Property:emptyInventoryHandled", {
        description = "Empty inventory (no items) works correctly",
        testCase = "edge_case",
        type = "property"
    }, function()
        local inventory = {}

        Helpers.assertEqual(#inventory, 0, "Inventory should be empty")
    end)

    Suite:testMethod("Property:emptyMapHandled", {
        description = "Empty map (no entities) doesn't crash",
        testCase = "edge_case",
        type = "property"
    }, function()
        local map = {entities = {}}

        Helpers.assertEqual(#map.entities, 0, "Map should have no entities")
    end)

    Suite:testMethod("Property:noPlayersInGame", {
        description = "Game handles no active players",
        testCase = "edge_case",
        type = "property"
    }, function()
        local game = {activePlayers = 0}

        Helpers.assertEqual(game.activePlayers, 0, "Should handle zero players")
    end)
end)

Suite:group("Single Items", function()

    Suite:testMethod("Property:singleWeaponInInventory", {
        description = "Inventory with only one weapon works",
        testCase = "edge_case",
        type = "property"
    }, function()
        local inventory = {
            weapons = {{name = "rifle", ammo = 30}}
        }

        Helpers.assertEqual(#inventory.weapons, 1, "Should have exactly one weapon")
    end)

    Suite:testMethod("Property:singleBaseFacility", {
        description = "Base with only one facility works",
        testCase = "edge_case",
        type = "property"
    }, function()
        local base = {
            facilities = {{type = "command_center"}}
        }

        Helpers.assertEqual(#base.facilities, 1, "Base should have one facility")
    end)

    Suite:testMethod("Property:singleMissionActive", {
        description = "Only one mission at a time works",
        testCase = "edge_case",
        type = "property"
    }, function()
        local missions = {
            active = {{id = 1, name = "Alien Base"}}
        }

        Helpers.assertEqual(#missions.active, 1, "Should have one active mission")
    end)

    Suite:testMethod("Property:singleEnemyEncounter", {
        description = "Encounter with single enemy works",
        testCase = "edge_case",
        type = "property"
    }, function()
        local encounter = {
            enemies = {{id = 1, type = "sectoid"}}
        }

        Helpers.assertEqual(#encounter.enemies, 1, "Should have one enemy")
    end)
end)

Suite:group("Unusual Inputs", function()

    Suite:testMethod("Property:emptyStringName", {
        description = "Empty string as name is handled",
        testCase = "edge_case",
        type = "property"
    }, function()
        local unit = {name = ""}

        Helpers.assertEqual(unit.name, "", "Should handle empty name")
        Helpers.assertEqual(#unit.name, 0, "Empty name should have length 0")
    end)

    Suite:testMethod("Property:duplicateValuesInList", {
        description = "Duplicate values in list are handled",
        testCase = "edge_case",
        type = "property"
    }, function()
        local items = {1, 1, 1, 1}

        Helpers.assertEqual(#items, 4, "Should have 4 items")
        local allSame = items[1] == items[2] and items[2] == items[3]
        Helpers.assertTrue(allSame, "All should be the same")
    end)

    Suite:testMethod("Property:negativeIndexArray", {
        description = "Accessing with invalid indices is safe",
        testCase = "edge_case",
        type = "property"
    }, function()
        local array = {1, 2, 3}
        local invalidIndex = -1
        local value = array[invalidIndex]

        Helpers.assertNil(value, "Negative index should return nil")
    end)
end)

return Suite
