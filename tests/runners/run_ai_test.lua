-- AI Test Runner
-- Run with: lovec tests/runners/run_ai_test.lua

package.path = package.path .. ";../../?.lua;../../engine/?.lua;../../engine/?/init.lua"

print("\n=============================================================")
print("AI TACTICAL DECISION SYSTEM TESTS")
print("=============================================================\n")

local success, testModule = pcall(require, "tests.unit.test_ai_tactical_decision")

if success and testModule and type(testModule.runAll) == "function" then
    local testSuccess, testError = pcall(testModule.runAll)

    if testSuccess then
        print("\n✓ AI Tactical Decision System PASSED")
        os.exit(0)
    else
        print("\n✗ AI Tactical Decision System FAILED")
        print("  Error: " .. tostring(testError))
        os.exit(1)
    end
else
    print("\n✗ Failed to load AI test module")
    if not success then
        print("  Error: " .. tostring(testModule))
    else
        print("  Module loaded but no runAll function found")
    end
    os.exit(1)
end