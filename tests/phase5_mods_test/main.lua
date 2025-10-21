function love.load()
    -- Disable graphics for testing
    love.window.close()
    
    -- Load and run tests
    local testResults = require("tests.test_phase5_example_mods")
    
    -- Exit with appropriate code
    if testResults.failed == 0 then
        os.exit(0)  -- Success
    else
        os.exit(1)  -- Failure
    end
end
