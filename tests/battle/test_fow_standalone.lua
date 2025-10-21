-- Standalone FOW Test Runner
-- This creates a minimal Love2D test environment to verify FOW functionality

-- Run with: lovec .
-- Then press Space to see test results

local losOptimized = require("systems.los_optimized")
local Team = require("core.team")
local Debug = require("battlescape.battle.utils.debug")

local testResults = {}
local testComplete = false

function love.load()
    print("===========================================")
    print("FOW System Test (Standalone)")
    print("===========================================")
    
    -- Test 1: LOS System exists
    table.insert(testResults, {
        name = "LOS System Loaded",
        passed = losOptimized ~= nil,
        message = losOptimized and "Optimized LOS available" or "LOS system missing"
    })
    
    -- Test 2: Team visibility
    local team = Team.new("test", "Test Team", Team.SIDES.PLAYER)
    team:initializeVisibility(10, 10)
    team:updateVisibility(5, 5, "visible")
    local visibility = team:getVisibility(5, 5)
    table.insert(testResults, {
        name = "Team Visibility System",
        passed = visibility == "visible",
        message = "Visibility state: " .. tostring(visibility)
    })
    
    -- Test 3: Debug FOW flag
    table.insert(testResults, {
        name = "Debug.showFOW Flag",
        passed = Debug.showFOW ~= nil,
        message = "showFOW = " .. tostring(Debug.showFOW)
    })
    
    -- Test 4: Debug toggle function
    local initialState = Debug.showFOW
    Debug.toggleFOW()
    local toggledState = Debug.showFOW
    Debug.toggleFOW() -- Toggle back
    table.insert(testResults, {
        name = "FOW Toggle Function",
        passed = initialState ~= toggledState,
        message = string.format("Toggle works: %s -> %s -> %s", 
            tostring(initialState), tostring(toggledState), tostring(Debug.showFOW))
    })
    
    -- Test 5: LOSCache system
    if losOptimized.LOSCache then
        local cache = losOptimized.LOSCache.new()
        local key = cache:getKey(5, 5, 10, true, 0)
        cache:set(key, {{x=5, y=5}})
        local cached = cache:get(key)
        table.insert(testResults, {
            name = "LOSCache System",
            passed = cached ~= nil and #cached == 1,
            message = "Cache operations work correctly"
        })
    else
        table.insert(testResults, {
            name = "LOSCache System",
            passed = false,
            message = "LOSCache not available"
        })
    end
    
    testComplete = true
    
    -- Print results
    print("\n--- Test Results ---")
    local passCount = 0
    for i, result in ipairs(testResults) do
        local status = result.passed and "[PASS]" or "[FAIL]"
        print(string.format("%s Test %d: %s - %s", status, i, result.name, result.message))
        if result.passed then passCount = passCount + 1 end
    end
    print(string.format("\n%d/%d tests passed", passCount, #testResults))
    print("===========================================")
    print("\nPress ESC to exit")
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("FOW System Test", 10, 10)
    love.graphics.print("See console for results", 10, 30)
    love.graphics.print("Press ESC to exit", 10, 50)
    
    if testComplete then
        local y = 80
        local passCount = 0
        for i, result in ipairs(testResults) do
            local color = result.passed and {0, 1, 0} or {1, 0, 0}
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.print(string.format("%s: %s", result.name, result.passed and "PASS" or "FAIL"), 10, y)
            y = y + 20
            if result.passed then passCount = passCount + 1 end
        end
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Total: %d/%d passed", passCount, #testResults), 10, y + 20)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

























