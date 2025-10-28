-- ─────────────────────────────────────────────────────────────────────────
-- SINGLE TEST FILE RUNNER
-- ─────────────────────────────────────────────────────────────────────────
-- Usage: lovec tests2/runners/run_single_test.lua [test_name]
-- Examples:
--   lovec tests2/runners/run_single_test.lua core/state_manager_test
--   lovec tests2/runners/run_single_test.lua battlescape/tactical_combat_test
--   lovec tests2/runners/run_single_test.lua ai/advanced_ai_test
-- ─────────────────────────────────────────────────────────────────────────

function love.load()
    -- Get test name from command line arguments
    local testName = arg[3] or arg[2] or "core/state_manager_test"

    print("\n" .. string.rep("═", 80))
    print(string.format("AlienFall Test Suite 2 - Single Test: %s", testName))
    print(string.rep("═", 80) .. "\n")

    -- Convert test name to module path
    local modulePath = "tests2." .. testName:gsub("/", ".")

    -- Add _test suffix if not already present
    if not modulePath:match("_test$") then
        modulePath = modulePath .. "_test"
    end

    print("[RUNNER] Loading from: " .. modulePath)

    local ok, result = pcall(function()
        local testModule = require(modulePath)

        if testModule and testModule.run then
            return testModule:run()
        elseif testModule then
            return testModule
        else
            error("Could not load test: " .. modulePath)
        end
    end)

    if ok then
        print("\n[RUNNER] Test completed successfully")
    else
        print("\n[RUNNER] ERROR: " .. tostring(result))
    end

    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Single Test Runner - Check console for output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
