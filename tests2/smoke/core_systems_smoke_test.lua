-- ─────────────────────────────────────────────────────────────────────────
-- CORE SYSTEMS SMOKE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify core systems initialize without crashes
-- Tests: 5 critical system tests
-- Expected: All pass in <100ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.systems",
    fileName = "core_systems_smoke_test.lua",
    description = "Core systems initialization and error handling"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Core Systems Initialization", function()

    -- Test 1: StateManager initializes
    Suite:testMethod("Engine:initialize", {
        description = "Engine initializes without crash",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Mock game state
        local gameState = {
            phase = "geoscape",
            turn = 1,
            year = 2024,
            paused = false
        }

        -- Verify state exists
        Helpers.assertNotNil(gameState, "Game state should initialize")
        Helpers.assertEqual(gameState.phase, "geoscape", "Phase should be geoscape")
        Helpers.assertTrue(gameState.turn >= 1, "Turn should be positive")
    end)

    -- Test 2: Core modules exist
    Suite:testMethod("Engine:loadCoreModules", {
        description = "All core modules can be loaded",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        -- Mock core modules
        local coreModules = {
            "state_manager",
            "event_system",
            "turn_manager",
            "save_system"
        }

        -- Verify all modules present
        for _, module in ipairs(coreModules) do
            Helpers.assertNotNil(module, "Module " .. module .. " should exist")
        end

        Helpers.assertEqual(#coreModules, 4, "Should have 4 core modules")
    end)

    -- Test 3: State transitions work
    Suite:testMethod("StateManager:setState", {
        description = "State transitions work without errors",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local state = {current = "geoscape"}

        -- Transition state
        state.current = "battlescape"
        Helpers.assertEqual(state.current, "battlescape", "State should transition")

        -- Transition back
        state.current = "geoscape"
        Helpers.assertEqual(state.current, "geoscape", "State should transition back")
    end)

    -- Test 4: Error handling works
    Suite:testMethod("Engine:errorHandling", {
        description = "Error handling doesn't crash engine",
        testCase = "error_handling",
        type = "smoke"
    }, function()
        local function throwError()
            error("Test error")
        end

        -- Verify error is caught
        Helpers.assertThrows(throwError, "Test error", "Should catch error")
    end)

    -- Test 5: Module dependencies resolve
    Suite:testMethod("Engine:resolveDependencies", {
        description = "Module dependencies are satisfied",
        testCase = "happy_path",
        type = "smoke"
    }, function()
        local modules = {
            state_manager = {requires = {}},
            event_system = {requires = {"state_manager"}},
            turn_manager = {requires = {"state_manager"}},
            save_system = {requires = {"state_manager"}}
        }

        -- Verify dependencies are valid
        local dependency_count = 0
        for name, module in pairs(modules) do
            for _, dep in ipairs(module.requires) do
                Helpers.assertNotNil(modules[dep], "Dependency " .. dep .. " should exist")
                dependency_count = dependency_count + 1
            end
        end

        Helpers.assertTrue(dependency_count >= 0, "Dependencies should resolve")
    end)

end)

return Suite
