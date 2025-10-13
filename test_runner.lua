-- Test Runner Script
-- Run with: lovec "engine" --test

local args = {...}
if args[1] == "--test" then
    print("Running test suite...")

    -- Load test framework
    package.path = package.path .. ";engine/?.lua;engine/?/init.lua"

    local TestRunner = require("tests.test_runner")
    TestRunner.runAllTests()

    print("Test suite completed.")
    love.event.quit()
else
    -- Normal game startup
    require("engine.main")
end