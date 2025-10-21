-- Unit Tests for Pathfinding System
-- Tests A* pathfinding, hex navigation, and path validation

local PathfindingTest = {}

-- Helper to create test grid
local function createTestGrid(width, height, obstacles)
    obstacles = obstacles or {}
    local grid = {}
    
    for y = 1, height do
        grid[y] = {}
        for x = 1, width do
            grid[y][x] = 1 -- Walkable by default
        end
    end
    
    -- Add obstacles
    for _, obstacle in ipairs(obstacles) do
        if grid[obstacle.y] then
            grid[obstacle.y][obstacle.x] = 0
        end
    end
    
    return grid
end

-- Test basic pathfinding
function PathfindingTest.testBasicPath()
    local Pathfinding = require("core.pathfinding")
    
    -- Create simple 10x10 grid
    local grid = createTestGrid(10, 10)
    
    -- Find path from (1,1) to (5,5)
    local path = Pathfinding.findPath(grid, 1, 1, 5, 5)
    
    assert(path ~= nil, "Path should be found")
    assert(#path > 0, "Path should have steps")
    assert(path[#path].x == 5 and path[#path].y == 5, "Path should reach goal")
    
    print("✓ testBasicPath passed")
end

-- Test pathfinding with obstacles
function PathfindingTest.testPathWithObstacles()
    local Pathfinding = require("core.pathfinding")
    
    -- Create grid with wall
    local obstacles = {
        {x = 3, y = 1}, {x = 3, y = 2}, {x = 3, y = 3},
        {x = 3, y = 4}, {x = 3, y = 5}
    }
    local grid = createTestGrid(10, 10, obstacles)
    
    -- Find path around wall
    local path = Pathfinding.findPath(grid, 1, 3, 5, 3)
    
    assert(path ~= nil, "Path should navigate around obstacle")
    assert(#path > 0, "Path should exist")
    
    -- Verify path doesn't go through obstacles
    for _, step in ipairs(path) do
        assert(grid[step.y][step.x] == 1, "Path should not go through obstacles")
    end
    
    print("✓ testPathWithObstacles passed")
end

-- Test impossible path
function PathfindingTest.testImpossiblePath()
    local Pathfinding = require("core.pathfinding")
    
    -- Create grid with complete wall
    local obstacles = {}
    for y = 1, 10 do
        table.insert(obstacles, {x = 5, y = y})
    end
    local grid = createTestGrid(10, 10, obstacles)
    
    -- Try to find path through wall
    local path = Pathfinding.findPath(grid, 1, 5, 9, 5)
    
    assert(path == nil or #path == 0, "Impossible path should return nil/empty")
    
    print("✓ testImpossiblePath passed")
end

-- Test straight line path
function PathfindingTest.testStraightPath()
    local Pathfinding = require("core.pathfinding")
    
    local grid = createTestGrid(10, 10)
    
    -- Horizontal path
    local path = Pathfinding.findPath(grid, 1, 5, 10, 5)
    
    assert(path ~= nil, "Straight path should be found")
    
    -- All steps should be on same row
    for _, step in ipairs(path) do
        assert(step.y == 5, "Path should be straight horizontal")
    end
    
    print("✓ testStraightPath passed")
end

-- Test diagonal path
function PathfindingTest.testDiagonalPath()
    local Pathfinding = require("core.pathfinding")
    
    local grid = createTestGrid(10, 10)
    
    -- Diagonal path
    local path = Pathfinding.findPath(grid, 1, 1, 10, 10)
    
    assert(path ~= nil, "Diagonal path should be found")
    assert(#path > 0, "Path should have steps")
    
    print("✓ testDiagonalPath passed")
end

-- Test path length calculation
function PathfindingTest.testPathLength()
    local Pathfinding = require("core.pathfinding")
    
    local grid = createTestGrid(10, 10)
    
    -- Create path
    local path = Pathfinding.findPath(grid, 1, 1, 5, 1)
    
    assert(path ~= nil, "Path should exist")
    
    -- Calculate length
    local length = #path
    assert(length >= 4, "Path should have at least 4 steps") -- Distance is 4
    
    print("✓ testPathLength passed")
end

-- Test path at grid edges
function PathfindingTest.testEdgePath()
    local Pathfinding = require("core.pathfinding")
    
    local grid = createTestGrid(10, 10)
    
    -- Path along edge
    local path = Pathfinding.findPath(grid, 1, 1, 1, 10)
    
    assert(path ~= nil, "Edge path should be found")
    
    -- All steps should be at x = 1
    for _, step in ipairs(path) do
        assert(step.x == 1, "Path should be along edge")
    end
    
    print("✓ testEdgePath passed")
end

-- Test same start and goal
function PathfindingTest.testSameStartGoal()
    local Pathfinding = require("core.pathfinding")
    
    local grid = createTestGrid(10, 10)
    
    -- Same position
    local path = Pathfinding.findPath(grid, 5, 5, 5, 5)
    
    -- Should return empty or single-point path
    assert(path == nil or #path <= 1, "Same position should return empty/single path")
    
    print("✓ testSameStartGoal passed")
end

-- Test large grid performance
function PathfindingTest.testLargeGrid()
    local Pathfinding = require("shared.pathfinding")
    
    local grid = createTestGrid(100, 100)
    
    local startTime = os.clock()
    local path = Pathfinding.findPath(grid, 1, 1, 100, 100)
    local endTime = os.clock()
    
    assert(path ~= nil, "Path should be found in large grid")
    
    local time = endTime - startTime
    print(string.format("  Large grid pathfinding: %.4f seconds", time))
    
    assert(time < 1.0, "Large grid pathfinding should complete in < 1 second")
    
    print("✓ testLargeGrid passed")
end

-- Test multiple paths
function PathfindingTest.testMultiplePaths()
    local Pathfinding = require("core.pathfinding")
    
    local grid = createTestGrid(10, 10)
    
    -- Find multiple paths
    local paths = {
        Pathfinding.findPath(grid, 1, 1, 5, 5),
        Pathfinding.findPath(grid, 5, 5, 10, 10),
        Pathfinding.findPath(grid, 1, 10, 10, 1)
    }
    
    for i, path in ipairs(paths) do
        assert(path ~= nil, "Path " .. i .. " should be found")
        assert(#path > 0, "Path " .. i .. " should have steps")
    end
    
    print("✓ testMultiplePaths passed")
end

-- Run all tests
function PathfindingTest.runAll()
    print("\n=== Pathfinding Tests ===")
    
    PathfindingTest.testBasicPath()
    PathfindingTest.testPathWithObstacles()
    PathfindingTest.testImpossiblePath()
    PathfindingTest.testStraightPath()
    PathfindingTest.testDiagonalPath()
    PathfindingTest.testPathLength()
    PathfindingTest.testEdgePath()
    PathfindingTest.testSameStartGoal()
    PathfindingTest.testLargeGrid()
    PathfindingTest.testMultiplePaths()
    
    print("✓ All Pathfinding tests passed!\n")
end

return PathfindingTest



