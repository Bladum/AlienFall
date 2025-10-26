-- Standalone Test Runner for Love2D
-- Run with: lovec tests/runners

-- Configure path for loading modules
package.path = package.path .. ";../../?.lua;../../engine/?.lua;../../engine/?/init.lua"

local testResults = {}
local currentTest = nil
local testComplete = false

function love.load()
    print("\n" .. string.rep("=", 60))
    print("XCOM SIMPLE - TEST SUITE")
    print(string.rep("=", 60) .. "\n")

    -- Debug: print arguments
    print("Debug - arg table:")
    for i, v in ipairs(arg) do
        print("  arg[" .. i .. "] = '" .. tostring(v) .. "'")
    end
    print()

    -- Check for command line arguments
    local category = arg[2] or "all"  -- Changed from arg[1] to arg[2]
    print("Running category: " .. category .. "\n")

    -- Load all test modules
    local allTests = {
        {name = "State Manager", module = "tests.unit.test_state_manager"},
        {name = "Audio System", module = "tests.unit.test_audio_system"},
        {name = "Facility System", module = "tests.unit.test_facility_system"},
        {name = "World System", module = "tests.unit.test_world_system"},
        {name = "Combat Integration", module = "tests.integration.test_combat_integration"},
        {name = "Base Integration", module = "tests.integration.test_base_integration"},
        {name = "Performance", module = "tests.performance.test_game_performance"},
        {name = "Phase 2 World Generation", module = "tests.geoscape.test_phase2_world_generation"}
    }

    -- AI tests
    local aiTests = {
        {name = "AI Tactical Decision", module = "tests.unit.test_ai_tactical_decision"}
    }

    -- Select tests based on category
    local tests = allTests
    if category == "ai" then
        tests = aiTests
    elseif category ~= "all" then
        print("Unknown category: " .. category)
        print("Available categories: all, ai")
        love.event.quit()
        return
    end

    print("Starting test execution...\n")

    -- Run each test with progress updates
    for i, test in ipairs(tests) do
        -- Show progress
        local progress = string.format("[%d/%d] ", i, #tests)
        print(progress .. "Running: " .. test.name)

        local success, testModule = pcall(require, test.module)

        if success and testModule and type(testModule.runAll) == "function" then
            local testSuccess, testError = pcall(testModule.runAll)

            table.insert(testResults, {
                name = test.name,
                success = testSuccess,
                error = testError
            })

            if testSuccess then
                print(progress .. "[PASS] " .. test.name)
            else
                print(progress .. "[FAIL] " .. test.name)
                print("       Error: " .. tostring(testError))
            end
        else
            table.insert(testResults, {
                name = test.name,
                success = false,
                error = "Failed to load module: " .. tostring(testModule)
            })
            print(progress .. "[FAIL] Failed to load: " .. test.name)
        end
    end

    -- Print summary
    print("\n" .. string.rep("=", 60))
    print("TEST SUMMARY")
    print(string.rep("=", 60))

    local passed = 0
    local failed = 0

    for _, result in ipairs(testResults) do
        if result.success then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end

    print(string.format("Total Tests: %d", #testResults))
    print(string.format("Passed: %d", passed))
    print(string.format("Failed: %d", failed))
    print(string.format("Pass Rate: %.1f%%", passed / #testResults * 100))

    if failed == 0 then
        print("\n[PASS] ALL TESTS PASSED!")
    else
        print("\n[FAIL] SOME TESTS FAILED")
        print("\nFailed tests:")
        for _, result in ipairs(testResults) do
            if not result.success then
                print("  - " .. result.name)
            end
        end
    end

    print(string.rep("=", 60) .. "\n")

    testComplete = true

    -- Quit after 2 seconds
    love.timer.sleep(2)
    love.event.quit(failed == 0 and 0 or 1)
end

function love.update(dt)
    -- Nothing to update
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Running tests... Check console for output", 10, 10)

    if testComplete then
        local y = 40
        for _, result in ipairs(testResults) do
            if result.success then
                love.graphics.setColor(0, 1, 0)
                love.graphics.print("[PASS] " .. result.name, 10, y)
            else
                love.graphics.setColor(1, 0, 0)
                love.graphics.print("[FAIL] " .. result.name, 10, y)
            end
            y = y + 20
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
