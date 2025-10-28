-- ─────────────────────────────────────────────────────────────────────────
-- SMOKE TEST RUNNER - Quick validation tests
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Run quick smoke tests to verify core systems work
-- Usage: lovec tests2/runners/run_smoke.lua
-- Expected: 22 tests, <500ms execution time
-- ─────────────────────────────────────────────────────────────────────────

local RunSmoke = {}

function RunSmoke:run()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - SMOKE TESTS (Quick Validation)")
    print(string.rep("═", 80) .. "\n")

    local ok, result = pcall(function()
        print("[RUNNER] Loading smoke test suite...")

        -- Load tests directly from tests2.smoke
        local smokeTests = require("tests2.smoke")

        local totalTests = 0
        local passedTests = 0
        local failedTests = 0

        print("[RUNNER] Found " .. #smokeTests .. " test modules\n")

        for _, testModulePath in ipairs(smokeTests) do
            print("[RUNNER] Loading: " .. testModulePath)
            local testModule = require(testModulePath)

            if testModule and testModule.run then
                local result = testModule:run()
                totalTests = totalTests + (result.total or 0)
                passedTests = passedTests + (result.passed or 0)
                failedTests = failedTests + (result.failed or 0)
            end
        end

        print("\n" .. string.rep("─", 80))
        print(string.format("SMOKE TEST SUMMARY"))
        print(string.rep("─", 80))
        print(string.format("Total:  %d", totalTests))
        print(string.format("Passed: %d", passedTests))
        print(string.format("Failed: %d", failedTests))
        print(string.rep("─", 80))

        if failedTests == 0 and totalTests > 0 then
            print("\n✓ ALL SMOKE TESTS PASSED\n")
        else
            print(string.format("\n✗ %d TESTS FAILED\n", failedTests))
        end

        return {
            total = totalTests,
            passed = passedTests,
            failed = failedTests
        }
    end)

    if not ok then
        print("\n[RUNNER] ERROR: " .. tostring(result))
        print("[RUNNER] Smoke test runner failed\n")
    end
end

function love.load()
    RunSmoke:run()
    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Smoke Test Runner - Check console for output", 10, 10)
    love.graphics.print("(Running quick validation tests)", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return RunSmoke
