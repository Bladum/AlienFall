-- ─────────────────────────────────────────────────────────────────────────
-- PROPERTY-BASED TEST RUNNER
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Run property-based tests to check edge cases and stress
-- Usage: lovec tests2/runners/run_property.lua
-- Expected: 55 tests, <8 seconds execution time
-- ─────────────────────────────────────────────────────────────────────────

local RunProperty = {}

function RunProperty:run()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - PROPERTY-BASED TESTS (Edge Cases & Stress)")
    print(string.rep("═", 80) .. "\n")

    local ok, result = pcall(function()
        print("[RUNNER] Loading property-based test suite...")

        -- Load tests directly from tests2.by_type.property
        local propertyTests = require("tests2.by_type.property")

        local totalTests = 0
        local passedTests = 0
        local failedTests = 0

        print("[RUNNER] Found " .. #propertyTests .. " test modules\n")

        for _, testModulePath in ipairs(propertyTests) do
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
        print(string.format("PROPERTY-BASED TEST SUMMARY"))
        print(string.rep("─", 80))
        print(string.format("Total:  %d", totalTests))
        print(string.format("Passed: %d", passedTests))
        print(string.format("Failed: %d", failedTests))
        print(string.rep("─", 80))

        if failedTests == 0 and totalTests > 0 then
            print("\n✓ ALL PROPERTY-BASED TESTS PASSED (Edge cases handled)\n")
        else
            print(string.format("\n✗ %d PROPERTY TESTS FAILED\n", failedTests))
        end

        return {
            total = totalTests,
            passed = passedTests,
            failed = failedTests
        }
    end)

    if not ok then
        print("\n[RUNNER] ERROR: " .. tostring(result))
        print("[RUNNER] Property-based test runner failed\n")
    end
end

function love.load()
    RunProperty:run()
    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Property-Based Test Runner - Check console for output", 10, 10)
    love.graphics.print("(Running edge case and stress tests)", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return RunProperty
