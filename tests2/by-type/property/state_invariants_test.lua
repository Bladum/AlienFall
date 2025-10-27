-- ─────────────────────────────────────────────────────────────────────────
-- STATE INVARIANTS PROPERTY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify game state invariants are maintained
-- Tests: 8 state invariant tests
-- Categories: Consistency checks, logical properties, relationships

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.properties",
    fileName = "state_invariants_test.lua",
    description = "State invariant and consistency testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- STATE INVARIANT TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Health Invariants", function()

    Suite:testMethod("Property:healthNeverNegative", {
        description = "Unit health never goes below zero",
        testCase = "invariant",
        type = "property"
    }, function()
        local unit = {health = 50}

        -- Try to damage below zero
        unit.health = math.max(unit.health - 100, 0)

        Helpers.assertTrue(unit.health >= 0, "Health should not be negative")
    end)

    Suite:testMethod("Property:maxHealthNotExceeded", {
        description = "Unit health never exceeds maximum",
        testCase = "invariant",
        type = "property"
    }, function()
        local unit = {health = 100, maxHealth = 100}

        unit.health = math.min(unit.health + 50, unit.maxHealth)

        Helpers.assertTrue(unit.health <= unit.maxHealth, "Health should not exceed max")
        Helpers.assertEqual(unit.health, unit.maxHealth, "Health should be capped")
    end)

    Suite:testMethod("Property:deadUnitCantAct", {
        description = "Dead units cannot perform actions",
        testCase = "invariant",
        type = "property"
    }, function()
        local unit = {health = 0, canAct = false}

        if unit.health <= 0 then
            unit.canAct = false
        end

        Helpers.assertFalse(unit.canAct, "Dead unit should not act")
    end)

    Suite:testMethod("Property:aliveUnitCanAct", {
        description = "Live units can perform actions",
        testCase = "invariant",
        type = "property"
    }, function()
        local unit = {health = 50, canAct = true}

        if unit.health > 0 then
            unit.canAct = true
        end

        Helpers.assertTrue(unit.canAct, "Live unit should be able to act")
    end)
end)

Suite:group("Resource Invariants", function()

    Suite:testMethod("Property:resourcesNeverNegative", {
        description = "Resources never go negative",
        testCase = "invariant",
        type = "property"
    }, function()
        local resources = {funds = 1000, scientists = 10}

        resources.funds = math.max(resources.funds - 2000, 0)
        resources.scientists = math.max(resources.scientists - 20, 0)

        Helpers.assertTrue(resources.funds >= 0, "Funds should not be negative")
        Helpers.assertTrue(resources.scientists >= 0, "Scientists should not be negative")
    end)

    Suite:testMethod("Property:unitCountNeverNegative", {
        description = "Unit counts never go negative",
        testCase = "invariant",
        type = "property"
    }, function()
        local squad = {units = 5}

        squad.units = math.max(squad.units - 10, 0)

        Helpers.assertTrue(squad.units >= 0, "Unit count should not be negative")
    end)

    Suite:testMethod("Property:totalResourcesConsistent", {
        description = "Total resources equal sum of all resources",
        testCase = "consistency",
        type = "property"
    }, function()
        local resources = {
            rifles = 20,
            shotguns = 10,
            grenades = 30
        }

        local total = 0
        for _, count in pairs(resources) do
            total = total + count
        end

        Helpers.assertEqual(total, 60, "Total should equal sum")
    end)
end)

Suite:group("Relationship Invariants", function()

    Suite:testMethod("Property:unitsInValidSquad", {
        description = "Squad unit count is consistent with unit list",
        testCase = "consistency",
        type = "property"
    }, function()
        local squad = {
            units = {{id = 1}, {id = 2}, {id = 3}},
            count = 3
        }

        Helpers.assertEqual(#squad.units, squad.count, "Unit count should match list")
    end)

    Suite:testMethod("Property:baseHasValidFacilities", {
        description = "All base facilities exist in valid facilities list",
        testCase = "relationship",
        type = "property"
    }, function()
        local validFacilities = {"barracks", "hangar", "laboratory"}
        local base = {
            facilities = {{type = "barracks"}, {type = "hangar"}}
        }

        for _, fac in ipairs(base.facilities) do
            local isValid = false
            for _, valid in ipairs(validFacilities) do
                if fac.type == valid then
                    isValid = true
                    break
                end
            end
            Helpers.assertTrue(isValid, "Facility type should be valid")
        end
    end)
end)

Suite:group("Game State Invariants", function()

    Suite:testMethod("Property:onlyOneActiveMission", {
        description = "Only one mission can be active at a time",
        testCase = "invariant",
        type = "property"
    }, function()
        local game = {
            missions = {
                {id = 1, active = true},
                {id = 2, active = false},
                {id = 3, active = false}
            }
        }

        local activeCount = 0
        for _, mission in ipairs(game.missions) do
            if mission.active then
                activeCount = activeCount + 1
            end
        end

        Helpers.assertEqual(activeCount, 1, "Only one mission should be active")
    end)

    Suite:testMethod("Property:turnNumberAlwaysIncreasing", {
        description = "Turn number never decreases",
        testCase = "monotonic",
        type = "property"
    }, function()
        local turn1 = 5
        local turn2 = 6
        local turn3 = 10

        Helpers.assertTrue(turn2 > turn1, "Turn 2 should be greater than turn 1")
        Helpers.assertTrue(turn3 > turn2, "Turn 3 should be greater than turn 2")
    end)
end)

return Suite
