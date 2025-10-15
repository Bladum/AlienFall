-- Quick Test Runner for Individual Test Files
-- Usage: lovec tests/runners/quick_test.lua

-- Set up package path
package.path = package.path .. ";../?.lua;../engine/?.lua;../engine/?/init.lua"

function love.load()
    print("Running map generation test...")

    -- Load and run the test
    local success, testModule = pcall(require, "tests.unit.test_map_generation")

    if success and testModule and type(testModule.runAll) == "function" then
        local testSuccess, testError = pcall(testModule.runAll)

        if testSuccess then
            print("\n✓ Test PASSED")
        else
            print("\n✗ Test FAILED")
            print("Error: " .. tostring(testError))
        end
    else
        print("Failed to load test module")
        if not success then
            print("Error: " .. tostring(testModule))
        elseif not testModule then
            print("Module is nil")
        elseif type(testModule.runAll) ~= "function" then
            print("runAll function not found")
        end
    end
end

function love.draw()
    love.graphics.print("Test completed - check console output", 10, 10)
end