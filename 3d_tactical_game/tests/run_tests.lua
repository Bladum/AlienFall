--- Master test runner
--- Executes all test suites for the 3D Tactical Game

print(string.rep("=", 80))
print("3D TACTICAL GAME - TEST SUITE")
print(string.rep("=", 80))
print("")

-- Load all test modules
local TestTile = require("tests.test_tile")
local TestUnit = require("tests.test_unit")
local TestTeam = require("tests.test_team")
local TestVisibility = require("tests.test_visibility")
local TestMapLoader = require("tests.test_maploader")
local TestInputHandler = require("tests.test_inputhandler")

-- Track test results
local totalTests = 0
local passedTests = 0
local failedTests = 0
local skippedTests = 0

local testResults = {}

--- Run a test suite and track results
local function runTestSuite(name, testModule)
    print(string.format("\n### Running %s ###", name))
    
    local success, err = pcall(function()
        testModule.runAll()
    end)
    
    if success then
        passedTests = passedTests + 1
        testResults[name] = "PASSED ✓"
        print(string.format("### %s: PASSED ✓ ###\n", name))
    else
        failedTests = failedTests + 1
        testResults[name] = "FAILED ✗"
        print(string.format("### %s: FAILED ✗ ###", name))
        print(string.format("Error: %s\n", tostring(err)))
    end
    
    totalTests = totalTests + 1
end

--- Print test summary
local function printSummary()
    print("\n" .. string.rep("=", 80))
    print("TEST SUMMARY")
    print(string.rep("=", 80))
    print("")
    
    -- Print individual test results
    print("Test Suite Results:")
    for name, result in pairs(testResults) do
        print(string.format("  %s: %s", name, result))
    end
    
    print("")
    print(string.format("Total Test Suites: %d", totalTests))
    print(string.format("Passed: %d", passedTests))
    print(string.format("Failed: %d", failedTests))
    print(string.format("Skipped: %d", skippedTests))
    
    if failedTests == 0 then
        print("")
        print("🎉 ALL TESTS PASSED! 🎉")
    else
        print("")
        print("⚠️  SOME TESTS FAILED ⚠️")
    end
    
    print(string.rep("=", 80))
end

-- Run all test suites
print("Starting test execution...\n")

runTestSuite("Tile Tests", TestTile)
runTestSuite("Unit Tests", TestUnit)
runTestSuite("Team Tests", TestTeam)
runTestSuite("Visibility System Tests", TestVisibility)
runTestSuite("MapLoader Tests", TestMapLoader)
runTestSuite("InputHandler Tests", TestInputHandler)

-- Print summary
printSummary()

-- Exit with appropriate code
if failedTests > 0 then
    love.event.quit(1)
else
    love.event.quit(0)
end
