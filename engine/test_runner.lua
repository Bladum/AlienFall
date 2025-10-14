-- Test Runner for Battle Systems
-- Runs from engine/ directory

print("\n===========================================")
print("BATTLESCAPE SYSTEMS TEST RUNNER")
print("===========================================\n")

-- Run tests
local TestSuite = require("tests.battle.test_battlescape_systems")

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