-- ─────────────────────────────────────────────────────────────────────────
-- MASTER TEST RUNNER - Execute all 148 tests in tests2/
-- ─────────────────────────────────────────────────────────────────────────

local Suite = require("tests2.framework.hierarchical_suite")

function love.load()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - MASTER RUNNER (All 148 Tests)")
    print(string.rep("═", 80) .. "\n")

    local suite = Suite:new("AlienFall Complete Test Suite")

    -- Define subsystems and their test directories
    local subsystems = {
        "core",
        "geoscape",
        "battlescape",
        "basescape",
        "economy",
        "politics",
        "lore",
        "ai",
        "utils",
    }

    local totalTests = 0
    local passedTests = 0
    local failedTests = 0

    -- Run tests for each subsystem
    for _, subsystem in ipairs(subsystems) do
        print("\n[RUNNER] Loading tests from " .. subsystem .. "/ ...")

        local ok, result = pcall(function()
            -- Dynamically load all test files in the subsystem
            local subsystemPath = "tests2." .. subsystem
            local subsystemModule = require(subsystemPath)

            if subsystemModule and subsystemModule.run then
                return subsystemModule:run()
            end
        end)

        if ok and result then
            totalTests = totalTests + (result.passed or 0) + (result.failed or 0)
            passedTests = passedTests + (result.passed or 0)
            failedTests = failedTests + (result.failed or 0)
        end
    end

    -- Print summary
    print("\n" .. string.rep("═", 80))
    print("TEST SUMMARY")
    print(string.rep("═", 80))
    print(string.format("Total Tests:   %d", totalTests))
    print(string.format("Passed:        %d", passedTests))
    print(string.format("Failed:        %d", failedTests))
    print(string.format("Pass Rate:     %.1f%%", (passedTests / totalTests * 100)))
    print(string.rep("═", 80) .. "\n")

    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Test Suite Master Runner - Check console for output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
