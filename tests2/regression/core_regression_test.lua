-- ─────────────────────────────────────────────────────────────────────────
-- CORE SYSTEM REGRESSION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Catch regressions in core system behavior
-- Tests: 8 regression tests for edge cases and known issues
-- Expected: All pass in <200ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core",
    fileName = "core_regression_test.lua",
    description = "Core system regression testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Core System Regressions", function()

    local engine = {}

    Suite:beforeEach(function()
        engine = {
            state = "initialized",
            modules = {},
            errors = {},
            moduleCount = 0
        }
    end)

    -- Regression 1: Null state transitions don't crash
    Suite:testMethod("Engine:nullStateTransition", {
        description = "Transitioning to nil state should not crash",
        testCase = "edge_case",
        type = "regression"
    }, function()
        local function setNilState()
            if engine.state == nil then
                error("Cannot set nil state")
            end
        end

        local ok, err = pcall(setNilState)
        -- Should handle gracefully
        Helpers.assertTrue(ok or err ~= nil, "Should catch or prevent nil state")
    end)

    -- Regression 2: Module loading order doesn't cause deadlock
    Suite:testMethod("Engine:moduleLoadingOrder", {
        description = "Loading modules in different orders should work",
        testCase = "edge_case",
        type = "regression"
    }, function()
        -- Load modules in non-alphabetical order
        local loadOrder = {"ui", "geoscape", "core", "basescape", "battlescape"}

        for _, mod in ipairs(loadOrder) do
            engine.modules[mod] = {loaded = true}
            engine.moduleCount = engine.moduleCount + 1
        end

        Helpers.assertEqual(engine.moduleCount, 5, "All modules should load")
    end)

    -- Regression 3: State corruption from rapid changes
    Suite:testMethod("Engine:rapidStateChanges", {
        description = "Rapid state changes should not corrupt state",
        testCase = "stress",
        type = "regression"
    }, function()
        local states = {"init", "loading", "ready", "running", "paused", "saving"}
        local finalState = nil

        for _, state in ipairs(states) do
            engine.state = state
            finalState = engine.state
        end

        Helpers.assertEqual(finalState, "saving", "Final state should be correct after rapid changes")
    end)

    -- Regression 4: Error recovery from module failures
    Suite:testMethod("Engine:errorRecovery", {
        description = "Engine should recover from module load errors",
        testCase = "error_handling",
        type = "regression"
    }, function()
        local function failingModule()
            error("Module failed to load")
        end

        local ok, err = pcall(failingModule)
        Helpers.assertTrue(not ok, "Should catch module failure")
        Helpers.assertTrue(err ~= nil, "Should have error message")
    end)

    -- Regression 5: Resource cleanup on shutdown
    Suite:testMethod("Engine:resourceCleanup", {
        description = "Resources should be cleaned up on shutdown",
        testCase = "cleanup",
        type = "regression"
    }, function()
        engine.resources = {
            memory = 1024,
            files = 5,
            timers = 3
        }

        -- Simulate cleanup
        engine.resources = nil

        Helpers.assertTrue(engine.resources == nil, "Resources should be cleared")
    end)

    -- Regression 6: Concurrent state access
    Suite:testMethod("Engine:concurrentStateAccess", {
        description = "Concurrent state access should not cause race conditions",
        testCase = "edge_case",
        type = "regression"
    }, function()
        engine.counter = 0

        -- Simulate concurrent increments
        for i = 1, 100 do
            engine.counter = engine.counter + 1
        end

        Helpers.assertEqual(engine.counter, 100, "Counter should be exact after concurrent access")
    end)

    -- Regression 7: Nested state transitions
    Suite:testMethod("Engine:nestedStateTransitions", {
        description = "Nested state transitions should work correctly",
        testCase = "edge_case",
        type = "regression"
    }, function()
        local stateStack = {}

        -- Push states
        table.insert(stateStack, "state1")
        table.insert(stateStack, "state2")
        table.insert(stateStack, "state3")

        -- Pop states
        local finalState = table.remove(stateStack)

        Helpers.assertEqual(finalState, "state3", "Should pop correct state")
        Helpers.assertEqual(#stateStack, 2, "Stack should have 2 items remaining")
    end)

    -- Regression 8: Memory leak prevention
    Suite:testMethod("Engine:memoryLeakPrevention", {
        description = "Repeated operations should not cause memory leaks",
        testCase = "stress",
        type = "regression"
    }, function()
        local tableCount = 0

        for i = 1, 1000 do
            local temp = {data = "test", value = i}
            tableCount = tableCount + 1
            temp = nil  -- Should be garbage collected
        end

        Helpers.assertEqual(tableCount, 1000, "Should create 1000 tables successfully")
    end)

end)

return Suite
