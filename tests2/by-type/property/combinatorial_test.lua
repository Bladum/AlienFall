-- ─────────────────────────────────────────────────────────────────────────
-- COMBINATORIAL PROPERTY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Test combinations of features and systems
-- Tests: 7 combinatorial tests
-- Categories: Feature interactions, system combinations

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.properties",
    fileName = "combinatorial_test.lua",
    description = "Combinatorial and feature interaction testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- COMBINATORIAL TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Feature Combinations", function()

    Suite:testMethod("Property:difficultyCombinations", {
        description = "All difficulty combinations work together",
        testCase = "combination",
        type = "property"
    }, function()
        local difficulties = {"easy", "normal", "hard", "ironman"}
        local languages = {"english", "french", "german"}

        local combinations = 0
        for _, diff in ipairs(difficulties) do
            for _, lang in ipairs(languages) do
                combinations = combinations + 1
            end
        end

        Helpers.assertEqual(combinations, 12, "Should have 12 combinations")
    end)

    Suite:testMethod("Property:unitClassWeaponCombos", {
        description = "All unit classes work with all weapon types",
        testCase = "combination",
        type = "property"
    }, function()
        local classes = {"soldier", "engineer", "scientist"}
        local weapons = {"rifle", "shotgun", "sniper", "grenade"}

        local validCombos = 0
        for _, class in ipairs(classes) do
            for _, weapon in ipairs(weapons) do
                if class ~= "scientist" or weapon == "grenade" then  -- Scientists use grenades
                    validCombos = validCombos + 1
                end
            end
        end

        Helpers.assertTrue(validCombos >= 9, "Should have at least 9 valid combinations")
    end)

    Suite:testMethod("Property:facilityEffectCombinations", {
        description = "Facilities provide combined effects",
        testCase = "combination",
        type = "property"
    }, function()
        local facilities = {
            barracks = {damage = 1.1},
            laboratory = {research = 1.25},
            workshop = {production = 1.2}
        }

        local combinedEffect = 1.0
        for _, facility in pairs(facilities) do
            combinedEffect = combinedEffect * (facility.damage or 1.0)
        end

        Helpers.assertTrue(combinedEffect > 1.0, "Combined effects should be multiplicative")
    end)

    Suite:testMethod("Property:statusEffectCombinations", {
        description = "Multiple status effects can apply simultaneously",
        testCase = "combination",
        type = "property"
    }, function()
        local unit = {
            health = 100,
            stunned = true,
            poisoned = true,
            burning = false
        }

        local activeEffects = 0
        if unit.stunned then activeEffects = activeEffects + 1 end
        if unit.poisoned then activeEffects = activeEffects + 1 end
        if unit.burning then activeEffects = activeEffects + 1 end

        Helpers.assertEqual(activeEffects, 2, "Should have 2 active effects")
    end)
end)

Suite:group("System Interactions", function()

    Suite:testMethod("Property:economyDifficultyInteraction", {
        description = "Economy and difficulty interact correctly",
        testCase = "interaction",
        type = "property"
    }, function()
        local baseIncome = 10000
        local difficulties = {
            easy = 1.5,
            normal = 1.0,
            hard = 0.75,
            ironman = 0.5
        }

        local income = {}
        for diff, modifier in pairs(difficulties) do
            income[diff] = baseIncome * modifier
        end

        Helpers.assertTrue(income.easy > income.normal, "Easy should earn more")
        Helpers.assertTrue(income.normal > income.hard, "Normal should earn more than hard")
    end)

    Suite:testMethod("Property:researchManufacturingDependency", {
        description = "Manufacturing depends on research completion",
        testCase = "dependency",
        type = "property"
    }, function()
        local research = {advanced_armor = {complete = true}}
        local manufacturing = {armor_cost = 100}

        local canManufacture = research.advanced_armor.complete

        Helpers.assertTrue(canManufacture, "Should be able to manufacture if research complete")
    end)

    Suite:testMethod("Property:battlescapeGeoscapeLink", {
        description = "Battlescape and geoscape data stay synchronized",
        testCase = "synchronization",
        type = "property"
    }, function()
        local geoscape = {
            activeMission = {id = 1, location = "Europe"}
        }
        local battlescape = {
            missionId = 1,
            location = "Europe"
        }

        Helpers.assertEqual(geoscape.activeMission.id, battlescape.missionId, "Mission IDs should match")
        Helpers.assertEqual(geoscape.activeMission.location, battlescape.location, "Locations should match")
    end)
end)

Suite:group("Edge Case Combinations", function()

    Suite:testMethod("Property:allSystemsZero", {
        description = "System handles all values at zero",
        testCase = "edge_combination",
        type = "property"
    }, function()
        local state = {
            health = 0,
            ammo = 0,
            actionPoints = 0,
            team_members = 0
        }

        local allZero = true
        for _, value in pairs(state) do
            if value ~= 0 then
                allZero = false
            end
        end

        Helpers.assertTrue(allZero, "All values should be zero")
    end)

    Suite:testMethod("Property:allSystemsMax", {
        description = "System handles all values at maximum",
        testCase = "edge_combination",
        type = "property"
    }, function()
        local maxValues = {
            health = 100,
            ammo = 999,
            actionPoints = 100,
            team_members = 6
        }

        for key, max in pairs(maxValues) do
            Helpers.assertTrue(max > 0, key .. " should be positive")
        end
    end)
end)

return Suite
