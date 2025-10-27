-- ─────────────────────────────────────────────────────────────────────────
-- COMPLIANCE TEST RUNNER
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Run compliance tests to verify game rules and constraints
-- Usage: lovec tests2/runners/run_compliance.lua
-- Expected: 44 tests, <5 seconds execution time
-- ─────────────────────────────────────────────────────────────────────────

local RunCompliance = {}

function RunCompliance:run()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - COMPLIANCE TESTS (Game Rules & Constraints)")
    print(string.rep("═", 80) .. "\n")

    local ok, result = pcall(function()
        print("[RUNNER] Loading compliance test suite...")

        -- Load tests directly from tests2.by_type.compliance
        local complianceTests = require("tests2.by_type.compliance")

        local totalTests = 0
        local passedTests = 0
        local failedTests = 0

        print("[RUNNER] Found " .. #complianceTests .. " test modules\n")

        for _, testModulePath in ipairs(complianceTests) do
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
        print(string.format("COMPLIANCE TEST SUMMARY"))
        print(string.rep("─", 80))
        print(string.format("Total:  %d", totalTests))
        print(string.format("Passed: %d", passedTests))
        print(string.format("Failed: %d", failedTests))
        print(string.rep("─", 80))

        if failedTests == 0 and totalTests > 0 then
            print("\n✓ ALL COMPLIANCE TESTS PASSED (Game rules enforced)\n")
        else
            print(string.format("\n✗ %d COMPLIANCE TESTS FAILED\n", failedTests))
        end

        return {
            total = totalTests,
            passed = passedTests,
            failed = failedTests
        }
    end)

    if not ok then
        print("\n[RUNNER] ERROR: " .. tostring(result))
        print("[RUNNER] Compliance test runner failed\n")
    end
end

function love.load()
    RunCompliance:run()
    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Compliance Test Runner - Check console for output", 10, 10)
    love.graphics.print("(Running game rules and constraints verification)", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return RunCompliance
