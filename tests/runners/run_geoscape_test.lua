-- Geoscape World Generation Test Runner
-- Run with: lovec tests/runners/run_geoscape_test.lua

-- Configure path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

function love.load()
    -- Load test suite
    local TestSuite = require("tests.geoscape.test_world_generation")

    -- Run all tests
    local exit_code = TestSuite:runAll()

    -- Exit with appropriate code
    love.timer.sleep(1)
    love.event.quit(exit_code)
end

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Geoscape World Generation Tests - Check console output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
