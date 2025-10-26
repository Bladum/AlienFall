-- ─────────────────────────────────────────────────────────────────────────
-- SUBSYSTEM TEST RUNNER - Run tests for a specific subsystem
-- ─────────────────────────────────────────────────────────────────────────
-- Usage: lovec tests2/runners/run_subsystem.lua [subsystem]
-- Examples:
--   lovec tests2/runners/run_subsystem.lua core
--   lovec tests2/runners/run_subsystem.lua geoscape
--   lovec tests2/runners/run_subsystem.lua battlescape
-- ─────────────────────────────────────────────────────────────────────────

local Suite = require("tests2.framework.hierarchical_suite")

function love.load()
    -- Get subsystem from command line arguments
    local subsystem = arg[3] or arg[2] or "core"
    subsystem = subsystem:lower()

    print("\n" .. string.rep("═", 80))
    print(string.format("AlienFall Test Suite 2 - Subsystem: %s", subsystem:upper()))
    print(string.rep("═", 80) .. "\n")

    local ok, result = pcall(function()
        local subsystemPath = "tests2." .. subsystem
        print("[RUNNER] Loading from: " .. subsystemPath)

        local subsystemModule = require(subsystemPath)

        if subsystemModule and subsystemModule.run then
            return subsystemModule:run()
        elseif subsystemModule then
            return subsystemModule
        else
            error("Could not load subsystem: " .. subsystem)
        end
    end)

    if ok then
        print("\n[RUNNER] Subsystem tests completed successfully")
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
    love.graphics.print("Subsystem Test Runner - Check console for output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
