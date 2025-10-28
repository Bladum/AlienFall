-- ─────────────────────────────────────────────────────────────────────────
-- REGRESSION TEST RUNNER
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Run regression tests to catch known bugs resurfacing
-- Usage: lovec tests2/runners/run_regression.lua
-- Expected: 38 tests, <2 seconds execution time
-- ─────────────────────────────────────────────────────────────────────────

local RunRegression = {}

function RunRegression:run()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - REGRESSION TESTS (Bug Prevention)")
    print(string.rep("═", 80) .. "\n")

    local ok, result = pcall(function()
        print("[RUNNER] Loading regression test suite...")

        -- Load tests directly from tests2.regression
        local regressionTests = require("tests2.regression")

        local totalTests = 0
        local passedTests = 0
        local failedTests = 0

        print("[RUNNER] Found " .. #regressionTests .. " test modules\n")

        for _, testModulePath in ipairs(regressionTests) do
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
        print(string.format("REGRESSION TEST SUMMARY"))
        print(string.rep("─", 80))
        print(string.format("Total:  %d", totalTests))
        print(string.format("Passed: %d", passedTests))
        print(string.format("Failed: %d", failedTests))
        print(string.rep("─", 80))

        if failedTests == 0 and totalTests > 0 then
            print("\n✓ ALL REGRESSION TESTS PASSED (No bugs detected)\n")
        else
            print(string.format("\n✗ %d REGRESSION TESTS FAILED\n", failedTests))
        end

        return {
            total = totalTests,
            passed = passedTests,
            failed = failedTests
        }
    end)

    if not ok then
        print("\n[RUNNER] ERROR: " .. tostring(result))
        print("[RUNNER] Regression test runner failed\n")
    end
end

function love.load()
    RunRegression:run()
    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Regression Test Runner - Check console for output", 10, 10)
    love.graphics.print("(Running bug prevention tests)", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return RunRegression
