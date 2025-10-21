-- Test Runner Main
-- Simple love entry point for running integration tests

local Tests = require("manual_gameplay_test")

function love.load()
    print("\n[TEST] Loading manual gameplay integration tests...\n")
    Tests.runAll()
    love.event.quit()
end

function love.update(dt)
end

function love.draw()
end



