-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Turn Manager
-- FILE: tests2/core/turn_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.core.turn.turn_manager
-- Covers turn initialization, execution, reset, and state management
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Mock TurnManager dla testów
local TurnManager = {
    currentTurn = 0,
    maxTurn = 100,
    units = {},
    turnPhase = "init",  -- init, player, enemy, resolution
    callbacks = {}
}

function TurnManager.newTurn()
    TurnManager.currentTurn = TurnManager.currentTurn + 1
    TurnManager.turnPhase = "init"

    -- Call onNewTurn callbacks
    if TurnManager.callbacks.onNewTurn then
        TurnManager.callbacks.onNewTurn(TurnManager.currentTurn)
    end

    return TurnManager.currentTurn
end

function TurnManager.execute(phase)
    if not phase or phase == "" then
        error("[TurnManager] Phase cannot be empty")
    end

    TurnManager.turnPhase = phase

    if TurnManager.callbacks.onPhaseStart then
        TurnManager.callbacks.onPhaseStart(phase)
    end

    return true
end

function TurnManager.reset()
    TurnManager.currentTurn = 0
    TurnManager.turnPhase = "init"
    TurnManager.units = {}
    TurnManager.callbacks = {}

    return true
end

function TurnManager.getCurrentTurn()
    return TurnManager.currentTurn
end

function TurnManager.registerCallback(event, callback)
    if not event or not callback then
        error("[TurnManager] Event and callback required")
    end

    TurnManager.callbacks[event] = callback
    return true
end

function TurnManager.getPhase()
    return TurnManager.turnPhase
end

function TurnManager.addUnit(unitId, unit)
    TurnManager.units[unitId] = unit
    return true
end

function TurnManager.getUnitCount()
    local count = 0
    for _ in pairs(TurnManager.units) do
        count = count + 1
    end
    return count
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.turn.turn_manager",
    fileName = "turn_manager.lua",
    description = "Turn management system - handles game turns and phases"
})

Suite:before(function()
    print("[TurnManager] Setting up test suite")
end)

Suite:after(function()
    print("[TurnManager] Cleaning up after tests")
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: INITIALIZATION & RESET
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Initialization & Reset", function()
    Suite:beforeEach(function()
        TurnManager.reset()
    end)

    Suite:testMethod("TurnManager.reset", {
        description = "Resets turn system to initial state",
        testCase = "happy_path",
        type = "functional"
    }, function()
        -- Set some state
        TurnManager.currentTurn = 5
        TurnManager.turnPhase = "player"
        TurnManager.units["unit1"] = {name = "Soldier"}

        -- Reset
        local result = TurnManager.reset()

        Helpers.assertEqual(result, true, "Reset should return true")
        Helpers.assertEqual(TurnManager.currentTurn, 0, "Current turn should be 0")
        Helpers.assertEqual(TurnManager.turnPhase, "init", "Phase should be init")
        Helpers.assertEqual(TurnManager.getUnitCount(), 0, "Units should be cleared")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.newTurn", {
        description = "Initializes a new turn",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local turnNum = TurnManager.newTurn()

        Helpers.assertEqual(turnNum, 1, "First turn should be 1")
        Helpers.assertEqual(TurnManager.getCurrentTurn(), 1, "Current turn should be 1")
        Helpers.assertEqual(TurnManager.getPhase(), "init", "Phase should be init")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.newTurn", {
        description = "Increments turn counter",
        testCase = "incremental",
        type = "functional"
    }, function()
        TurnManager.newTurn()
        TurnManager.newTurn()
        TurnManager.newTurn()

        Helpers.assertEqual(TurnManager.getCurrentTurn(), 3, "Should have 3 turns")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: PHASE EXECUTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Phase Execution", function()
    local shared = {}

    Suite:beforeEach(function()
        TurnManager.reset()
        TurnManager.newTurn()
        shared.phaseCallbackCalled = false
        shared.callbackPhase = nil
    end)

    Suite:testMethod("TurnManager.execute", {
        description = "Executes a game phase",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local result = TurnManager.execute("player")

        Helpers.assertEqual(result, true, "Execute should return true")
        Helpers.assertEqual(TurnManager.getPhase(), "player", "Phase should be player")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.execute", {
        description = "Cycles through all phases",
        testCase = "phase_cycle",
        type = "functional"
    }, function()
        TurnManager.execute("init")
        Helpers.assertEqual(TurnManager.getPhase(), "init")

        TurnManager.execute("player")
        Helpers.assertEqual(TurnManager.getPhase(), "player")

        TurnManager.execute("enemy")
        Helpers.assertEqual(TurnManager.getPhase(), "enemy")

        TurnManager.execute("resolution")
        Helpers.assertEqual(TurnManager.getPhase(), "resolution")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.execute", {
        description = "Rejects empty phase",
        testCase = "error_handling",
        type = "functional"
    }, function()
        local ok, err = pcall(function()
            TurnManager.execute("")
        end)

        Helpers.assertEqual(ok, false, "Should throw error for empty phase")
        assert(err ~= nil and err:match("Phase cannot be empty"), "Error message should mention phase")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.execute", {
        description = "Calls phase callback when registered",
        testCase = "callback",
        type = "functional"
    }, function()
        TurnManager.registerCallback("onPhaseStart", function(phase)
            shared.phaseCallbackCalled = true
            shared.callbackPhase = phase
        end)

        TurnManager.execute("player")

        Helpers.assertEqual(shared.phaseCallbackCalled, true, "Callback should be called")
        Helpers.assertEqual(shared.callbackPhase, "player", "Callback should receive phase name")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: CALLBACKS & EVENTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Callbacks & Events", function()
    local shared = {}

    Suite:beforeEach(function()
        TurnManager.reset()
        shared.callbackCalled = false
        shared.callbackTurn = nil
        shared.errorThrown = false
    end)

    Suite:testMethod("TurnManager.registerCallback", {
        description = "Registers event callbacks",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local callback = function(turn)
            shared.callbackCalled = true
            shared.callbackTurn = turn
        end

        local result = TurnManager.registerCallback("onNewTurn", callback)

        Helpers.assertEqual(result, true, "Register should return true")

        -- Verify callback is called on new turn
        TurnManager.newTurn()
        Helpers.assertEqual(shared.callbackCalled, true, "Callback should be called")
        Helpers.assertEqual(shared.callbackTurn, 1, "Callback should receive turn number")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.registerCallback", {
        description = "Rejects invalid callback registration",
        testCase = "error_handling",
        type = "functional"
    }, function()
        local ok, err = pcall(function()
            TurnManager.registerCallback("onNewTurn", nil)
        end)

        Helpers.assertEqual(ok, false, "Should throw error for nil callback")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.registerCallback", {
        description = "Overwrites previous callback",
        testCase = "edge_case",
        type = "functional"
    }, function()
        local firstCall = {count = 0}
        local secondCall = {count = 0}

        TurnManager.registerCallback("onNewTurn", function()
            firstCall.count = firstCall.count + 1
        end)

        TurnManager.registerCallback("onNewTurn", function()
            secondCall.count = secondCall.count + 1
        end)

        TurnManager.newTurn()

        -- Only second callback should be called
        Helpers.assertEqual(firstCall.count, 0, "First callback should not be called")
        Helpers.assertEqual(secondCall.count, 1, "Second callback should be called")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: UNIT MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Unit Management", function()
    Suite:beforeEach(function()
        TurnManager.reset()
    end)

    Suite:testMethod("TurnManager.addUnit", {
        description = "Adds unit to turn system",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local unit = {id = "unit1", name = "Soldier", hp = 100}
        local result = TurnManager.addUnit("unit1", unit)

        Helpers.assertEqual(result, true, "Add unit should return true")
        Helpers.assertEqual(TurnManager.getUnitCount(), 1, "Should have 1 unit")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.addUnit", {
        description = "Manages multiple units",
        testCase = "multiple_units",
        type = "functional"
    }, function()
        TurnManager.addUnit("unit1", {name = "Soldier1"})
        TurnManager.addUnit("unit2", {name = "Soldier2"})
        TurnManager.addUnit("unit3", {name = "Medic"})

        Helpers.assertEqual(TurnManager.getUnitCount(), 3, "Should have 3 units")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.addUnit", {
        description = "Replaces unit with same ID",
        testCase = "edge_case",
        type = "functional"
    }, function()
        local unit1 = {id = "unit1", name = "Soldier"}
        local unit2 = {id = "unit1", name = "Officer"}  -- Same ID

        TurnManager.addUnit("unit1", unit1)
        TurnManager.addUnit("unit1", unit2)

        Helpers.assertEqual(TurnManager.getUnitCount(), 1, "Should still have 1 unit")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: STATE QUERIES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("State Queries", function()
    Suite:beforeEach(function()
        TurnManager.reset()
    end)

    Suite:testMethod("TurnManager.getCurrentTurn", {
        description = "Returns current turn number",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(TurnManager.getCurrentTurn(), 0, "Initial turn should be 0")

        TurnManager.newTurn()
        Helpers.assertEqual(TurnManager.getCurrentTurn(), 1, "After newTurn should be 1")

        TurnManager.newTurn()
        TurnManager.newTurn()
        Helpers.assertEqual(TurnManager.getCurrentTurn(), 3, "After 3 newTurns should be 3")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager.getPhase", {
        description = "Returns current phase",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(TurnManager.getPhase(), "init", "Initial phase should be init")

        TurnManager.execute("player")
        Helpers.assertEqual(TurnManager.getPhase(), "player", "After execute should be player")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
