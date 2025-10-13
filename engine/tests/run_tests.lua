-- Test Runner
-- Runs all test suites for the battle system

print("\n===========================================")
print("BATTLE SYSTEMS TEST RUNNER")
print("===========================================\n")

-- Add engine directory to package path
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"

-- Run tests
local TestSuite = require("tests.battle.test_battle_systems")

local success, result = pcall(function()
    return TestSuite.runAll()
end)

if not success then
    print("\n[ERROR] Test suite crashed: " .. tostring(result))
    os.exit(1)
elseif result then
    print("\n[SUCCESS] All tests passed!")
    os.exit(0)
else
    print("\n[FAILURE] Some tests failed!")
    os.exit(1)
end
