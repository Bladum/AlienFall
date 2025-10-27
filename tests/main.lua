-- Main entry point for Queen MIDI test
-- This allows Love2D to run the test

-- Load the test module
local test = require("queen_test")

-- Forward Love2D callbacks to the test
function love.load()
    test.love.load()
end

function love.update(dt)
    test.love.update(dt)
end

function love.draw()
    test.love.draw()
end

function love.keypressed(key)
    test.love.keypressed(key)
end
