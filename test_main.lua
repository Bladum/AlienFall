-- Test Main
-- Simple main.lua that runs tests

function love.load()
    print("Starting test suite...")

    -- Set up package path
    package.path = package.path .. ";./?.lua;./?/init.lua"

    -- Run tests
    local success, err = pcall(function()
        local TestRunner = require("tests.test_runner")
        TestRunner.runAllTests()
    end)

    if not success then
        print("Test suite failed: " .. tostring(err))
        print(debug.traceback())
    else
        print("Test suite completed successfully!")
    end

    -- Quit after tests
    love.event.quit()
end

function love.draw()
    love.graphics.print("Running tests...", 10, 10)
end