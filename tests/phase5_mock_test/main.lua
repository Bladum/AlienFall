-- Love2D Test Runner for Phase 5 Mock Data Generation
-- Run: lovec "tests/phase5_mock_test" from project root

function love.load()
    -- Setup path for requiring modules
    package.path = package.path .. ";?.lua;?/init.lua"
    
    -- Load test suite
    local TestSuite = require("tests.test_phase5_mock_generation")
    
    -- Run all tests
    print("\n")
    local success = TestSuite.runAll()
    
    -- Exit with appropriate code
    if success then
        print("\n✓ All tests passed!")
        love.event.quit(0)
    else
        print("\n✗ Some tests failed!")
        love.event.quit(1)
    end
end

function love.update(dt)
    -- Nothing to do
end

function love.draw()
    -- Nothing to draw
end
