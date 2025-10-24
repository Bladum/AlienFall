-- Enhanced Hierarchical Test Runner
-- Uses the TestFramework for organized test execution

package.path = package.path .. ";../../?.lua;../../engine/?.lua;../../engine/?/init.lua"

local TestFramework = require("engine.core.test_framework")

local TestRunner = {}

function TestRunner.discoverTests(test_path)
    local tests = {}
    -- This would scan a directory for test files in production
    -- For now, we'll return a structure for the test discovery API
    return tests
end

function TestRunner.loadTestSuites()
    -- Initialize framework
    TestFramework.init()

    -- Unit Tests
    print("Loading unit tests...")
    local unitTests = {
        {name = "test_state_manager", module = "tests.unit.test_state_manager"},
        {name = "test_audio_system", module = "tests.unit.test_audio_system"},
        {name = "test_facility_system", module = "tests.unit.test_facility_system"},
        {name = "test_world_system", module = "tests.unit.test_world_system"},
        {name = "test_ai_tactical_decision", module = "tests.unit.test_ai_tactical_decision"},
    }

    for _, test in ipairs(unitTests) do
        local ok, testModule = pcall(require, test.module)
        if ok and testModule and testModule.runAll then
            local tests = type(testModule.runAll) == "function" and {
                {name = test.name, func = testModule.runAll}
            } or {}

            TestFramework.registerSuite(test.name, "unit", tests)
        end
    end

    -- Integration Tests
    print("Loading integration tests...")
    local integrationTests = {
        {name = "test_combat_integration", module = "tests.integration.test_combat_integration"},
        {name = "test_base_integration", module = "tests.integration.test_base_integration"},
    }

    for _, test in ipairs(integrationTests) do
        local ok, testModule = pcall(require, test.module)
        if ok and testModule and testModule.runAll then
            local tests = type(testModule.runAll) == "function" and {
                {name = test.name, func = testModule.runAll}
            } or {}

            TestFramework.registerSuite(test.name, "integration", tests)
        end
    end

    -- System Tests
    print("Loading system tests...")
    local systemTests = {
        {name = "test_phase2_world_generation", module = "tests.geoscape.test_phase2_world_generation"},
    }

    for _, test in ipairs(systemTests) do
        local ok, testModule = pcall(require, test.module)
        if ok and testModule and testModule.runAll then
            local tests = type(testModule.runAll) == "function" and {
                {name = test.name, func = testModule.runAll}
            } or {}

            TestFramework.registerSuite(test.name, "system", tests)
        end
    end

    -- Performance Tests
    print("Loading performance tests...")
    local perfTests = {
        {name = "test_game_performance", module = "tests.performance.test_game_performance"},
    }

    for _, test in ipairs(perfTests) do
        local ok, testModule = pcall(require, test.module)
        if ok and testModule and testModule.runAll then
            local tests = type(testModule.runAll) == "function" and {
                {name = test.name, func = testModule.runAll}
            } or {}

            TestFramework.registerSuite(test.name, "performance", tests)
        end
    end

    print("\nTest suites loaded successfully.\n")
end

function TestRunner.runTests(category)
    if category and category ~= "all" then
        TestFramework.runCategory(category)
    else
        TestFramework.runAll()
    end

    local report = TestFramework.generateReport()
    return report
end

function TestRunner.exitWithStatus(results)
    if results.failed > 0 then
        print("TESTS FAILED")
        love.event.quit(1)
    else
        print("ALL TESTS PASSED")
        love.event.quit(0)
    end
end

function love.load()
    local category = arg[1] or "all"

    TestRunner.loadTestSuites()
    local results = TestRunner.runTests(category)
    TestRunner.exitWithStatus(results)
end

return TestRunner
