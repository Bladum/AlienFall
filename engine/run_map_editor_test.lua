--[[
    Map Editor Test Runner
    Executes all Map Editor unit tests
--]]

function love.load()
    -- Load test suite
    local results = require("battlescape.ui.tests.test_map_editor")
    
    -- Exit with appropriate code
    if results.failed > 0 then
        love.event.quit(1)
    else
        print("\n✅ All Map Editor tests passed!")
        love.event.quit(0)
    end
end

function love.draw()
    -- Nothing to draw
end

function love.update(dt)
    -- Nothing to update
end
