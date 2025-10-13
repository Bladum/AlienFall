-- run_range_accuracy_tests.lua
-- Simple test runner for range and accuracy system tests

local TestSuite = require("tests.battle.test_range_accuracy")

print("Running Range and Accuracy System Tests...")
print("==========================================")

local success = TestSuite.runAll()

if success then
    print("\n🎉 All tests passed!")
    love.event.quit(0)
else
    print("\n💥 Tests failed!")
    love.event.quit(1)
end