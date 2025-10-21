function love.load()
    -- Disable graphics for testing
    love.window.close()
    
    -- Load and run validation tests
    local testResults = require("tests.test_phase5_comprehensive_validation")
    
    -- Exit with appropriate code
    if testResults.failed == 0 then
        os.exit(0)  -- Success
    else
        os.exit(1)  -- Failure
    end
end
