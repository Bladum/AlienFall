-- Comprehensive Test Runner
-- Runs all unit and integration tests

-- Set up paths
package.path = package.path .. ";../../?.lua;../../engine/?.lua;../../engine/?/init.lua"

print("\n" .. string.rep("=", 60))
print("XCOM SIMPLE - COMPREHENSIVE TEST SUITE")
print(string.rep("=", 60) .. "\n")

local totalTests = 0
local passedTests = 0
local failedTests = 0
local errors = {}

-- Helper to run a test module safely
local function runTestModule(name, modulePath)
    print("\n" .. string.rep("-", 60))
    print("Running: " .. name)
    print(string.rep("-", 60))
    
    local success, testModule = pcall(require, modulePath)
    
    if not success then
        print("✗ Failed to load test module: " .. name)
        print("  Error: " .. tostring(testModule))
        failedTests = failedTests + 1
        table.insert(errors, {name = name, error = testModule})
        return false
    end
    
    if type(testModule.runAll) ~= "function" then
        print("✗ Test module " .. name .. " has no runAll() function")
        failedTests = failedTests + 1
        return false
    end
    
    local testSuccess, testError = pcall(testModule.runAll)
    
    if testSuccess then
        print("✓ " .. name .. " completed successfully")
        passedTests = passedTests + 1
        return true
    else
        print("✗ " .. name .. " failed")
        print("  Error: " .. tostring(testError))
        failedTests = failedTests + 1
        table.insert(errors, {name = name, error = testError})
        return false
    end
end

-- Mock love.graphics functions for headless testing
if not love or not love.graphics then
    love = love or {}
    love.graphics = love.graphics or {}
    love.graphics.print = function() end
    love.graphics.setColor = function() end
    love.graphics.rectangle = function() end
    love.graphics.circle = function() end
    love.graphics.line = function() end
    love.graphics.draw = function() end
    love.graphics.newImage = function() return {} end
    love.graphics.newQuad = function() return {} end
    love.graphics.push = function() end
    love.graphics.pop = function() end
    love.graphics.translate = function() end
    love.graphics.scale = function() end
    love.graphics.rotate = function() end
end

-- UNIT TESTS
print("\n" .. string.rep("=", 60))
print("UNIT TESTS")
print(string.rep("=", 60))

local unitTests = {
    {"State Manager", "tests.unit.test_state_manager"},
    {"Audio System", "tests.unit.test_audio_system"},
    {"Facility System", "tests.unit.test_facility_system"},
    {"World System", "tests.unit.test_world_system"}
}

for _, test in ipairs(unitTests) do
    totalTests = totalTests + 1
    runTestModule(test[1], test[2])
end

-- INTEGRATION TESTS
print("\n" .. string.rep("=", 60))
print("INTEGRATION TESTS")
print(string.rep("=", 60))

local integrationTests = {
    {"Combat Integration", "tests.integration.test_combat_integration"},
    {"Base Management Integration", "tests.integration.test_base_integration"}
}

for _, test in ipairs(integrationTests) do
    totalTests = totalTests + 1
    runTestModule(test[1], test[2])
end

-- SUMMARY
print("\n" .. string.rep("=", 60))
print("TEST SUMMARY")
print(string.rep("=", 60))
print(string.format("Total Tests: %d", totalTests))
print(string.format("Passed:      %d (%.1f%%)", passedTests, passedTests / totalTests * 100))
print(string.format("Failed:      %d (%.1f%%)", failedTests, failedTests / totalTests * 100))

if #errors > 0 then
    print("\n" .. string.rep("=", 60))
    print("ERROR DETAILS")
    print(string.rep("=", 60))
    for i, err in ipairs(errors) do
        print(string.format("\n%d. %s", i, err.name))
        print("   " .. tostring(err.error))
    end
end

print("\n" .. string.rep("=", 60))

if failedTests == 0 then
    print("✓ ALL TESTS PASSED!")
    print(string.rep("=", 60) .. "\n")
    if love and love.event then
        love.event.quit(0)
    end
else
    print("✗ SOME TESTS FAILED")
    print(string.rep("=", 60) .. "\n")
    if love and love.event then
        love.event.quit(1)
    end
end

-- If running standalone, exit
if not love then
    os.exit(failedTests == 0 and 0 or 1)
end



