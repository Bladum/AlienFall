-- ─────────────────────────────────────────────────────────────────────────
-- MAIN ENTRY POINT FOR tests2/runners - Test Suite Runners
-- ─────────────────────────────────────────────────────────────────────────
-- Usage: lovec tests2/runners run_smoke
-- ─────────────────────────────────────────────────────────────────────────

function love.load()
    -- Get runner name from arguments
    -- When called as: lovec tests2/runners run_smoke
    -- arg[1] = "tests2/runners" (the folder)
    -- arg[2] = "run_smoke" (the runner name)

    local runnerName = arg[2] or "all"

    -- Build module path for runner
    local runnerModule = "tests2.runners." .. runnerName

    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite - Loading Runner: " .. runnerName)
    print(string.rep("═", 80) .. "\n")

    -- Load and execute the runner
    local ok, result = pcall(function()
        local runner = require(runnerModule)
        if runner and runner.run then
            return runner:run()
        else
            print("[ERROR] Runner " .. runnerModule .. " does not have a run() method")
        end
    end)

    if not ok then
        print("\n[ERROR] Failed to load runner: " .. tostring(result))
    end

    love.event.quit()
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Test Runner - Check console for output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
