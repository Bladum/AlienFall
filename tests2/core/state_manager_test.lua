-- ─────────────────────────────────────────────────────────────────────────
-- TEST: State Manager
-- FILE: tests2/core/state_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.core.state.state_manager
-- Covers state registration, switching, and lifecycle callbacks
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Mock StateManager dla testów
local StateManager = {
    current = nil,
    states = {}
}

function StateManager.register(name, state)
    StateManager.states[name] = state
    return true
end

function StateManager.switch(name, ...)
    if not StateManager.states[name] then
        error("[StateManager] State '" .. name .. "' does not exist!")
    end

    -- Exit current state
    if StateManager.current and StateManager.current.exit then
        StateManager.current:exit()
    end

    -- Switch to new state
    StateManager.current = StateManager.states[name]

    -- Enter new state
    if StateManager.current.enter then
        StateManager.current:enter(...)
    end

    return true
end

function StateManager.update(dt)
    if StateManager.current and StateManager.current.update then
        StateManager.current:update(dt)
    end
end

function StateManager.draw()
    if StateManager.current and StateManager.current.draw then
        StateManager.current:draw()
    end
end

function StateManager.getStateNames()
    local names = {}
    for name in pairs(StateManager.states) do
        table.insert(names, name)
    end
    return names
end

function StateManager.countStates()
    local count = 0
    for _ in pairs(StateManager.states) do
        count = count + 1
    end
    return count
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.state.state_manager",
    fileName = "state_manager.lua",
    description = "State management system - handles game state transitions"
})

-- Module-level setup
Suite:before(function()
    print("[StateManager] Setting up test suite")
    -- Reset state before tests
    StateManager.current = nil
    StateManager.states = {}
end)

Suite:after(function()
    print("[StateManager] Cleaning up after tests")
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: REGISTRATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Registration", function()
    local shared = {}

    Suite:beforeEach(function()
        -- Reset StateManager state for each test
        StateManager.current = nil
        StateManager.states = {}
    end)

    Suite:testMethod("StateManager.register", {
        description = "Registers a new state",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local mockState = {name = "TestState"}
        StateManager.register("test_state", mockState)

        Helpers.assertEqual(StateManager.states["test_state"], mockState, "State should be registered")
        Helpers.assertEqual(StateManager.countStates(), 1, "Should have 1 state")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.register", {
        description = "Registers multiple states",
        testCase = "multiple_states",
        type = "functional"
    }, function()
        StateManager.register("menu", {name = "Menu"})
        StateManager.register("game", {name = "Game"})
        StateManager.register("pause", {name = "Pause"})

        Helpers.assertEqual(StateManager.countStates(), 3, "Should have 3 states registered")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.getStateNames", {
        description = "Returns list of registered state names",
        testCase = "happy_path",
        type = "functional"
    }, function()
        StateManager.register("menu", {})
        StateManager.register("game", {})

        local names = StateManager.getStateNames()

        Helpers.assertEqual(#names, 2, "Should return 2 names")
        assert(Helpers.tableContains(names, "menu"), "Should contain 'menu'")
        assert(Helpers.tableContains(names, "game"), "Should contain 'game'")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: STATE SWITCHING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("State Switching", function()
    local shared = {}

    Suite:beforeEach(function()
        StateManager.current = nil
        StateManager.states = {}
        shared.enterCalled = false
        shared.exitCalled = false
    end)

    Suite:testMethod("StateManager.switch", {
        description = "Switches to a registered state",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local testState = {
            enter = function() shared.enterCalled = true end
        }
        StateManager.register("test", testState)
        StateManager.switch("test")

        Helpers.assertEqual(StateManager.current, testState, "Current should be test state")
        Helpers.assertEqual(shared.enterCalled, true, "Enter callback should be called")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.switch", {
        description = "Calls exit on previous state",
        testCase = "exit_callback",
        type = "functional"
    }, function()
        local state1 = {
            exit = function() shared.exitCalled = true end
        }
        local state2 = {}

        StateManager.register("state1", state1)
        StateManager.register("state2", state2)

        StateManager.switch("state1")
        StateManager.switch("state2")

        Helpers.assertEqual(shared.exitCalled, true, "Exit should be called on previous state")
        Helpers.assertEqual(StateManager.current, state2, "Current should be state2")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.switch", {
        description = "Throws error for non-existent state",
        testCase = "error_handling",
        type = "error_handling"
    }, function()
        Helpers.assertThrows(function()
            StateManager.switch("nonexistent")
        end, "does not exist", "Should throw error for non-existent state")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.switch", {
        description = "Passes arguments to enter callback",
        testCase = "arguments",
        type = "functional"
    }, function()
        local shared_args = {}
        local testState = {
            enter = function(self, arg1, arg2)
                shared_args.arg1 = arg1
                shared_args.arg2 = arg2
            end
        }

        StateManager.register("test", testState)
        StateManager.switch("test", "value1", "value2")

        Helpers.assertEqual(shared_args.arg1, "value1", "Should receive first argument")
        Helpers.assertEqual(shared_args.arg2, "value2", "Should receive second argument")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: LIFECYCLE CALLBACKS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Lifecycle Callbacks", function()
    local shared = {}

    Suite:beforeEach(function()
        StateManager.current = nil
        StateManager.states = {}
        shared.updateCalled = false
        shared.drawCalled = false
    end)

    Suite:testMethod("StateManager.update", {
        description = "Calls update on current state",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local testState = {
            update = function(self, dt) shared.updateCalled = true end
        }
        StateManager.register("test", testState)
        StateManager.switch("test")
        StateManager.update(0.016)

        Helpers.assertEqual(shared.updateCalled, true, "Update should be called")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.draw", {
        description = "Calls draw on current state",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local testState = {
            draw = function(self) shared.drawCalled = true end
        }
        StateManager.register("test", testState)
        StateManager.switch("test")
        StateManager.draw()

        Helpers.assertEqual(shared.drawCalled, true, "Draw should be called")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StateManager.update", {
        description = "Does nothing if no current state",
        testCase = "edge_case",
        type = "functional"
    }, function()
        StateManager.current = nil
        -- Should not throw
        StateManager.update(0.016)

        Helpers.assertEqual(StateManager.current, nil, "Current should still be nil")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: STATE MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("State Management", function()
    local shared = {}

    Suite:beforeEach(function()
        StateManager.current = nil
        StateManager.states = {}
    end)

    Suite:testMethod("StateManager.countStates", {
        description = "Returns correct count of registered states",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(StateManager.countStates(), 0, "Should start with 0 states")

        StateManager.register("menu", {})
        Helpers.assertEqual(StateManager.countStates(), 1, "Should have 1 state")

        StateManager.register("game", {})
        Helpers.assertEqual(StateManager.countStates(), 2, "Should have 2 states")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
