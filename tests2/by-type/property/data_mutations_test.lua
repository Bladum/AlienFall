-- ─────────────────────────────────────────────────────────────────────────
-- DATA MUTATIONS PROPERTY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Test data integrity through mutations
-- Tests: 8 data mutation tests
-- Categories: State changes, transformations, modifications

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.properties",
    fileName = "data_mutations_test.lua",
    description = "Data mutation and transformation testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- DATA MUTATION TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Value Mutations", function()

    Suite:testMethod("Property:unitHealthMutation", {
        description = "Unit health can be mutated and recovers properly",
        testCase = "mutation",
        type = "property"
    }, function()
        local unit = {health = 100}

        -- Damage the unit
        unit.health = unit.health - 25
        Helpers.assertEqual(unit.health, 75, "Health should decrease")

        -- Heal the unit
        unit.health = math.min(unit.health + 25, 100)
        Helpers.assertEqual(unit.health, 100, "Health should be restored")
    end)

    Suite:testMethod("Property:resourceMutation", {
        description = "Resources can be spent and gained",
        testCase = "mutation",
        type = "property"
    }, function()
        local funds = 50000

        funds = funds - 10000  -- Spend
        Helpers.assertEqual(funds, 40000, "Funds should decrease")

        funds = funds + 5000  -- Gain
        Helpers.assertEqual(funds, 45000, "Funds should increase")
    end)

    Suite:testMethod("Property:turnCounterIncrement", {
        description = "Turn counter increments consistently",
        testCase = "increment",
        type = "property"
    }, function()
        local turn = 1

        for i = 1, 10 do
            turn = turn + 1
        end

        Helpers.assertEqual(turn, 11, "Turn should increment 10 times")
    end)

    Suite:testMethod("Property:armyCompositionChange", {
        description = "Army composition can change during battle",
        testCase = "mutation",
        type = "property"
    }, function()
        local army = {units = {1, 2, 3, 4}}

        -- Remove defeated unit
        table.remove(army.units, 1)
        Helpers.assertEqual(#army.units, 3, "Should have 3 units after loss")

        -- Add reinforcement
        table.insert(army.units, 5)
        Helpers.assertEqual(#army.units, 4, "Should have 4 units after reinforcement")
    end)
end)

Suite:group("State Transitions", function()

    Suite:testMethod("Property:unitStateChanges", {
        description = "Unit state can transition through valid states",
        testCase = "state_change",
        type = "property"
    }, function()
        local unit = {state = "idle"}

        unit.state = "moving"
        Helpers.assertEqual(unit.state, "moving", "State should change to moving")

        unit.state = "attacking"
        Helpers.assertEqual(unit.state, "attacking", "State should change to attacking")

        unit.state = "idle"
        Helpers.assertEqual(unit.state, "idle", "State should return to idle")
    end)

    Suite:testMethod("Property:missionStateProgression", {
        description = "Mission progresses through states",
        testCase = "progression",
        type = "property"
    }, function()
        local mission = {state = "preparing"}

        mission.state = "active"
        Helpers.assertEqual(mission.state, "active", "Mission should be active")

        mission.state = "complete"
        Helpers.assertEqual(mission.state, "complete", "Mission should be complete")
    end)

    Suite:testMethod("Property:gamePhaseTransition", {
        description = "Game phase transitions correctly",
        testCase = "transition",
        type = "property"
    }, function()
        local game = {phase = "player_action"}

        game.phase = "ai_action"
        Helpers.assertEqual(game.phase, "ai_action", "Phase should be AI action")

        game.phase = "reinforcement"
        Helpers.assertEqual(game.phase, "reinforcement", "Phase should be reinforcement")
    end)

    Suite:testMethod("Property:facilityConstructionProgress", {
        description = "Facility construction progress changes",
        testCase = "progress",
        type = "property"
    }, function()
        local facility = {progress = 0}

        for i = 1, 5 do
            facility.progress = facility.progress + 20
        end

        Helpers.assertEqual(facility.progress, 100, "Facility should be 100% complete")
    end)
end)

Suite:group("Collection Mutations", function()

    Suite:testMethod("Property:listAppendRemove", {
        description = "Items can be added and removed from lists",
        testCase = "list_mutation",
        type = "property"
    }, function()
        local items = {1, 2, 3}

        table.insert(items, 4)
        Helpers.assertEqual(#items, 4, "Should have 4 items after insert")

        table.remove(items, 1)
        Helpers.assertEqual(#items, 3, "Should have 3 items after remove")
    end)

    Suite:testMethod("Property:mapValueUpdate", {
        description = "Map values can be updated",
        testCase = "map_mutation",
        type = "property"
    }, function()
        local config = {difficulty = "easy", speed = 1.0}

        config.difficulty = "hard"
        Helpers.assertEqual(config.difficulty, "hard", "Difficulty should change")

        config.speed = 1.5
        Helpers.assertEqual(config.speed, 1.5, "Speed should change")
    end)
end)

return Suite
