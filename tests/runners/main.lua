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
    
    -- Check for command line arguments
    local category = arg[1] or "all"
    print("Running category: " .. category .. "\n")
    
    -- Load all test modules
    local allTests = {
        {name = "State Manager", module = "tests.unit.test_state_manager"},
        {name = "Audio System", module = "tests.unit.test_audio_system"},
        {name = "Facility System", module = "tests.unit.test_facility_system"},
        {name = "World System", module = "tests.unit.test_world_system"},
        {name = "Combat Integration", module = "tests.integration.test_combat_integration"},
        {name = "Base Integration", module = "tests.integration.test_base_integration"},
        {name = "Performance", module = "tests.performance.test_game_performance"}
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
    
    -- Run each test
    for _, test in ipairs(tests) do
        print("\n" .. string.rep("-", 60))
        print("Running: " .. test.name)
        print(string.rep("-", 60))
        
        local success, testModule = pcall(require, test.module)
        
        if success and testModule and type(testModule.runAll) == "function" then
            local testSuccess, testError = pcall(testModule.runAll)
            
            table.insert(testResults, {
                name = test.name,
                success = testSuccess,
                error = testError
            })
            
            if testSuccess then
                print("✓ " .. test.name .. " PASSED")
            else
                print("✗ " .. test.name .. " FAILED")
                print("  Error: " .. tostring(testError))
            end
        else
            table.insert(testResults, {
                name = test.name,
                success = false,
                error = "Failed to load module: " .. tostring(testModule)
            })
            print("✗ Failed to load: " .. test.name)
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
    
    print(string.format("Total: %d", #testResults))
    print(string.format("Passed: %d (%.1f%%)", passed, passed / #testResults * 100))
    print(string.format("Failed: %d (%.1f%%)", failed, failed / #testResults * 100))
    
    if failed == 0 then
        print("\n✓ ALL TESTS PASSED!")
    else
        print("\n✗ SOME TESTS FAILED")
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
                love.graphics.print("✓ " .. result.name, 10, y)
            else
                love.graphics.setColor(1, 0, 0)
                love.graphics.print("✗ " .. result.name, 10, y)
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
