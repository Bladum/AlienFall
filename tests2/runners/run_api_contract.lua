-- ─────────────────────────────────────────────────────────────────────────
-- API CONTRACT TEST RUNNER
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Run API contract tests to verify interfaces
-- Usage: lovec tests2/runners/run_api_contract.lua
-- Expected: 45 tests, <3 seconds execution time
-- ─────────────────────────────────────────────────────────────────────────

local RunApiContract = {}

function RunApiContract:run()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - API CONTRACT TESTS (Interface Verification)")
    print(string.rep("═", 80) .. "\n")

    local ok, result = pcall(function()
        print("[RUNNER] Loading API contract test suite...")

        -- Load tests directly from tests2.api_contract
        local apiContractTests = require("tests2.api_contract")

        local totalTests = 0
        local passedTests = 0
        local failedTests = 0

        print("[RUNNER] Found " .. #apiContractTests .. " test modules\n")

        for _, testModulePath in ipairs(apiContractTests) do
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
        print(string.format("API CONTRACT TEST SUMMARY"))
        print(string.rep("─", 80))
        print(string.format("Total:  %d", totalTests))
        print(string.format("Passed: %d", passedTests))
        print(string.format("Failed: %d", failedTests))
        print(string.rep("─", 80))

        if failedTests == 0 and totalTests > 0 then
            print("\n✓ ALL API CONTRACTS VERIFIED (Interfaces stable)\n")
        else
            print(string.format("\n✗ %d API CONTRACT TESTS FAILED\n", failedTests))
        end

        return {
            total = totalTests,
            passed = passedTests,
            failed = failedTests
        }
    end)

    if not ok then
        print("\n[RUNNER] ERROR: " .. tostring(result))
        print("[RUNNER] API contract test runner failed\n")
    end
end

function love.load()
    RunApiContract:run()
    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("API Contract Test Runner - Check console for output", 10, 10)
    love.graphics.print("(Running interface verification tests)", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return RunApiContract
