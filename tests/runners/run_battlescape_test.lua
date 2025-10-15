-- Simple test runner for battlescape systems
print("Loading battlescape systems test...")

local success, TestSuite = pcall(require, "tests.battle.test_battlescape_systems")
if not success then
    print("Failed to load test suite: " .. tostring(TestSuite))
    return
end

print("Running tests...")
local testSuccess, result = pcall(TestSuite.runAll)
if not testSuccess then
    print("Test suite crashed: " .. tostring(result))
    print("Stack trace:")
    print(debug.traceback())
else
    print("Tests completed successfully")
end





















