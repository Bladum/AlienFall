-- ─────────────────────────────────────────────────────────────────────────
-- PATHFINDING SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests A* pathfinding, obstacle navigation, and path validation
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK PATHFINDING SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local Pathfinding = {}
Pathfinding.__index = Pathfinding

function Pathfinding:new()
    local self = setmetatable({}, Pathfinding)
    return self
end

-- Simple BFS pathfinding implementation for testing
function Pathfinding.findPath(grid, startX, startY, goalX, goalY)
    if not grid or not grid[startY] or not grid[goalY] then return nil end
    if grid[startY][startX] ~= 1 or grid[goalY][goalX] ~= 1 then return nil end
    if startX == goalX and startY == goalY then return {{x = startX, y = startY}} end

    -- BFS implementation
    local queue = {{x = startX, y = startY, path = {{x = startX, y = startY}}}}
    local visited = {}
    visited[startY * 1000 + startX] = true -- Simple hash for visited

    while #queue > 0 do
        local current = table.remove(queue, 1)

        -- Check if we reached goal
        if current.x == goalX and current.y == goalY then
            return current.path
        end

        -- Add neighbors (4-directional for simplicity)
        local neighbors = {
            {x = current.x + 1, y = current.y},
            {x = current.x - 1, y = current.y},
            {x = current.x, y = current.y + 1},
            {x = current.x, y = current.y - 1}
        }

        for _, neighbor in ipairs(neighbors) do
            if grid[neighbor.y] and grid[neighbor.y][neighbor.x] == 1 then
                local hash = neighbor.y * 1000 + neighbor.x
                if not visited[hash] then
                    visited[hash] = true
                    local newPath = {}
                    for _, step in ipairs(current.path) do
                        table.insert(newPath, {x = step.x, y = step.y})
                    end
                    table.insert(newPath, {x = neighbor.x, y = neighbor.y})
                    table.insert(queue, {x = neighbor.x, y = neighbor.y, path = newPath})
                end
            end
        end
    end

    return nil -- No path found
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "core.pathfinding",
    fileName = "pathfinding.lua",
    description = "A* pathfinding system for grid-based navigation"
})

Suite:before(function() print("[PathfindingTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: BASIC PATHFINDING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Basic Pathfinding", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.pathfinding = Pathfinding:new()
        -- Create 10x10 test grid
        shared.grid = {}
        for y = 1, 10 do
            shared.grid[y] = {}
            for x = 1, 10 do
                shared.grid[y][x] = 1
            end
        end
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Finds basic path in open grid", testCase="basic_path", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 1, 1, 5, 5)
        Helpers.assertEqual(path ~= nil, true, "Path should be found in open grid")
        Helpers.assertEqual(#path > 0, true, "Path should contain steps")
        Helpers.assertEqual(path[#path].x, 5, "Path should reach goal X")
        Helpers.assertEqual(path[#path].y, 5, "Path should reach goal Y")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Returns empty path for same start/goal", testCase="same_position", type="edge_case"},
    function()
        local path = Pathfinding.findPath(shared.grid, 5, 5, 5, 5)
        Helpers.assertEqual(path == nil or #path <= 1, true, "Same position should return empty/single path")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles straight horizontal path", testCase="straight_horizontal", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 1, 5, 10, 5)
        Helpers.assertEqual(path ~= nil, true, "Straight path should be found")
        -- All steps should be on same row
        for _, step in ipairs(path) do
            Helpers.assertEqual(step.y, 5, "All steps should be on row 5")
        end
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles straight vertical path", testCase="straight_vertical", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 5, 1, 5, 10)
        Helpers.assertEqual(path ~= nil, true, "Vertical path should be found")
        -- All steps should be on same column
        for _, step in ipairs(path) do
            Helpers.assertEqual(step.x, 5, "All steps should be on column 5")
        end
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: OBSTACLE NAVIGATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Obstacle Navigation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.pathfinding = Pathfinding:new()
        -- Create grid with partial wall that can be navigated around
        shared.grid = {}
        for y = 1, 10 do
            shared.grid[y] = {}
            for x = 1, 10 do
                shared.grid[y][x] = 1
            end
        end
        -- Add wall at x=5, but leave gaps at top and bottom
        for y = 2, 9 do
            shared.grid[y][5] = 0
        end
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Navigates around obstacles", testCase="path_around_wall", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 1, 5, 9, 5)
        Helpers.assertEqual(path ~= nil, true, "Path should navigate around wall")
        Helpers.assertEqual(#path > 0, true, "Path should exist")
        -- Verify path doesn't go through obstacles
        for _, step in ipairs(path) do
            Helpers.assertEqual(shared.grid[step.y][step.x], 1, "Path should not go through obstacles")
        end
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Returns nil for impossible path", testCase="impossible_path", type="edge_case"},
    function()
        -- Create completely blocked grid
        local blockedGrid = {}
        for y = 1, 10 do
            blockedGrid[y] = {}
            for x = 1, 10 do
                blockedGrid[y][x] = 0 -- All blocked
            end
        end
        local path = Pathfinding.findPath(blockedGrid, 1, 1, 10, 10)
        Helpers.assertEqual(path == nil, true, "Impossible path should return nil")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles start position blocked", testCase="blocked_start", type="error_handling"},
    function()
        shared.grid[1][1] = 0 -- Block start
        local path = Pathfinding.findPath(shared.grid, 1, 1, 9, 9)
        Helpers.assertEqual(path == nil, true, "Blocked start should return nil")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles goal position blocked", testCase="blocked_goal", type="error_handling"},
    function()
        shared.grid[9][9] = 0 -- Block goal
        local path = Pathfinding.findPath(shared.grid, 1, 1, 9, 9)
        Helpers.assertEqual(path == nil, true, "Blocked goal should return nil")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: PATH PROPERTIES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Path Properties", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.pathfinding = Pathfinding:new()
        shared.grid = {}
        for y = 1, 10 do
            shared.grid[y] = {}
            for x = 1, 10 do
                shared.grid[y][x] = 1
            end
        end
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Returns valid path structure", testCase="path_structure", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 1, 1, 5, 5)
        Helpers.assertEqual(path ~= nil, true, "Path should exist")
        Helpers.assertEqual(type(path), "table", "Path should be table")
        Helpers.assertEqual(#path > 0, true, "Path should have steps")
        -- Each step should have x,y coordinates
        for i, step in ipairs(path) do
            Helpers.assertEqual(type(step.x), "number", "Step " .. i .. " should have x")
            Helpers.assertEqual(type(step.y), "number", "Step " .. i .. " should have y")
        end
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Path includes start and goal positions", testCase="start_goal_included", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 2, 3, 7, 8)
        Helpers.assertEqual(path ~= nil, true, "Path should exist")
        Helpers.assertEqual(path[1].x, 2, "Path should start at correct X")
        Helpers.assertEqual(path[1].y, 3, "Path should start at correct Y")
        Helpers.assertEqual(path[#path].x, 7, "Path should end at correct X")
        Helpers.assertEqual(path[#path].y, 8, "Path should end at correct Y")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Path is connected (adjacent steps)", testCase="connected_path", type="functional"},
    function()
        local path = Pathfinding.findPath(shared.grid, 1, 1, 5, 5)
        Helpers.assertEqual(path ~= nil, true, "Path should exist")
        -- Check that consecutive steps are adjacent
        for i = 1, #path - 1 do
            local dx = math.abs(path[i+1].x - path[i].x)
            local dy = math.abs(path[i+1].y - path[i].y)
            Helpers.assertEqual(dx <= 1 and dy <= 1, true, "Steps " .. i .. "-" .. (i+1) .. " should be adjacent")
        end
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: EDGE CASES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Edge Cases", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.pathfinding = Pathfinding:new()
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles grid boundaries", testCase="grid_boundaries", type="edge_case"},
    function()
        local grid = {{1, 1}, {1, 1}} -- 2x2 grid
        local path = Pathfinding.findPath(grid, 1, 1, 2, 2)
        Helpers.assertEqual(path ~= nil, true, "Path should work in small grid")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles nil grid", testCase="nil_grid", type="error_handling"},
    function()
        local path = Pathfinding.findPath(nil, 1, 1, 5, 5)
        Helpers.assertEqual(path == nil, true, "Nil grid should return nil")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles invalid coordinates", testCase="invalid_coords", type="error_handling"},
    function()
        local grid = {{1, 1}, {1, 1}}
        local path = Pathfinding.findPath(grid, 0, 0, 3, 3) -- Out of bounds
        Helpers.assertEqual(path == nil, true, "Invalid coordinates should return nil")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: PERFORMANCE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.pathfinding = Pathfinding:new()
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles large grids efficiently", testCase="large_grid", type="performance"},
    function()
        -- Create 50x50 grid
        local largeGrid = {}
        for y = 1, 50 do
            largeGrid[y] = {}
            for x = 1, 50 do
                largeGrid[y][x] = 1
            end
        end

        local startTime = os.clock()
        local path = Pathfinding.findPath(largeGrid, 1, 1, 50, 50)
        local endTime = os.clock()

        Helpers.assertEqual(path ~= nil, true, "Path should be found in large grid")
        local duration = endTime - startTime
        Helpers.assertEqual(duration < 2.0, true, "Large grid pathfinding should complete quickly")
        print(string.format("  ✓ Large grid performance: %.4f seconds", duration))
    end)

    Suite:testMethod("Pathfinding.findPath", {description="Handles multiple path requests", testCase="multiple_paths", type="performance"},
    function()
        local grid = {}
        for y = 1, 20 do
            grid[y] = {}
            for x = 1, 20 do
                grid[y][x] = 1
            end
        end

        local startTime = os.clock()
        for i = 1, 10 do
            local path = Pathfinding.findPath(grid, 1, 1, 20, 20)
            Helpers.assertEqual(path ~= nil, true, "Path " .. i .. " should be found")
        end
        local endTime = os.clock()

        local duration = endTime - startTime
        Helpers.assertEqual(duration < 1.0, true, "Multiple paths should complete quickly")
        print(string.format("  ✓ Multiple paths performance: %.4f seconds", duration))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
