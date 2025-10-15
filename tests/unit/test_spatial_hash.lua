---Test Suite for Spatial Hash System
---Tests grid-based spatial partitioning for collision detection and proximity queries

-- Mock Love2D if not available
if not love then
    love = {}
end

local SpatialHash = require("engine.core.spatial_hash")

local TestSpatialHash = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper function to run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper function to assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Create spatial hash grid
function TestSpatialHash.testCreateGrid()
    local grid = SpatialHash.new(100, 100, 10)
    assert(grid ~= nil, "Grid should be created")
    assert(grid.width == 100, "Width should be 100")
    assert(grid.height == 100, "Height should be 100")
    assert(grid.cellSize == 10, "Cell size should be 10")
    assert(grid.gridWidth == 10, "Grid width should be 10 cells")
    assert(grid.gridHeight == 10, "Grid height should be 10 cells")
end

---Test: Insert items into grid
function TestSpatialHash.testInsertItems()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1", name = "Soldier"}
    local unit2 = {id = "unit2", name = "Enemy"}
    
    grid:insert(5, 5, unit1)
    grid:insert(15, 15, unit2)
    
    assert(grid.itemCount == 2, "Should have 2 items in grid")
end

---Test: Query exact position
function TestSpatialHash.testQueryExact()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1", name = "Soldier"}
    grid:insert(5, 5, unit1)
    
    local results = grid:queryExact(5, 5)
    assert(#results == 1, "Should find 1 item at exact position")
    assert(results[1].item.id == "unit1", "Should find correct unit")
end

---Test: Query radius
function TestSpatialHash.testQueryRadius()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1"}
    local unit2 = {id = "unit2"}
    local unit3 = {id = "unit3"}
    
    grid:insert(10, 10, unit1)  -- Center
    grid:insert(12, 10, unit2)  -- 2 tiles away
    grid:insert(50, 50, unit3)  -- Far away
    
    local results = grid:queryRadius(10, 10, 5)
    assert(#results >= 2, "Should find at least 2 units within 5 tile radius")
    
    -- Verify far unit not included
    local foundFarUnit = false
    for _, item in ipairs(results) do
        if item.item.id == "unit3" then
            foundFarUnit = true
        end
    end
    assert(not foundFarUnit, "Should not find far unit in radius query")
end

---Test: Query rectangle
function TestSpatialHash.testQueryRect()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1"}
    local unit2 = {id = "unit2"}
    local unit3 = {id = "unit3"}
    
    grid:insert(10, 10, unit1)  -- Inside rect
    grid:insert(15, 15, unit2)  -- Inside rect
    grid:insert(50, 50, unit3)  -- Outside rect
    
    local results = grid:queryRect(5, 5, 20, 20)
    assert(#results == 2, "Should find 2 units in rectangle")
end

---Test: Remove items from grid
function TestSpatialHash.testRemoveItems()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1"}
    grid:insert(10, 10, unit1)
    assert(grid.itemCount == 1, "Should have 1 item")
    
    grid:remove(10, 10, unit1)
    assert(grid.itemCount == 0, "Should have 0 items after removal")
    
    local results = grid:queryExact(10, 10)
    assert(#results == 0, "Should not find removed item")
end

---Test: Check if position is occupied
function TestSpatialHash.testIsOccupied()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1"}
    grid:insert(10, 10, unit1)
    
    assert(grid:isOccupied(10, 10), "Position should be occupied")
    assert(not grid:isOccupied(20, 20), "Empty position should not be occupied")
end

---Test: Clear entire grid
function TestSpatialHash.testClear()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1"}
    local unit2 = {id = "unit2"}
    grid:insert(10, 10, unit1)
    grid:insert(20, 20, unit2)
    
    assert(grid.itemCount == 2, "Should have 2 items")
    
    grid:clear()
    assert(grid.itemCount == 0, "Should have 0 items after clear")
end

---Test: Get grid statistics
function TestSpatialHash.testGetStats()
    local grid = SpatialHash.new(100, 100, 10)
    
    local unit1 = {id = "unit1"}
    local unit2 = {id = "unit2"}
    grid:insert(10, 10, unit1)
    grid:insert(20, 20, unit2)
    
    local stats = grid:getStats()
    assert(stats ~= nil, "Should return stats")
    assert(stats.itemCount == 2, "Stats should show 2 items")
    assert(stats.cellsUsed >= 1, "Stats should show cells used")
end

---Test: World to cell coordinate conversion
function TestSpatialHash.testWorldToCell()
    local grid = SpatialHash.new(100, 100, 10)
    
    local cellX, cellY = grid:worldToCell(1, 1)
    assert(cellX == 0 and cellY == 0, "Position (1,1) should be cell (0,0)")
    
    cellX, cellY = grid:worldToCell(10, 10)
    assert(cellX == 0 and cellY == 0, "Position (10,10) should be cell (0,0)")
    
    cellX, cellY = grid:worldToCell(11, 11)
    assert(cellX == 1 and cellY == 1, "Position (11,11) should be cell (1,1)")
end

---Test: Performance with many items
function TestSpatialHash.testPerformance()
    local grid = SpatialHash.new(100, 100, 10)
    
    -- Insert 1000 items
    local startTime = os.clock()
    for i = 1, 1000 do
        local x = math.random(1, 100)
        local y = math.random(1, 100)
        grid:insert(x, y, {id = "unit" .. i})
    end
    local insertTime = os.clock() - startTime
    
    -- Query radius
    startTime = os.clock()
    for i = 1, 100 do
        local results = grid:queryRadius(50, 50, 10)
    end
    local queryTime = os.clock() - startTime
    
    print(string.format("[Performance] Insert 1000 items: %.4fs, 100 radius queries: %.4fs", 
        insertTime, queryTime))
    
    assert(insertTime < 1.0, "Insert should complete in under 1 second")
    assert(queryTime < 0.5, "Queries should complete in under 0.5 seconds")
end

-- Run all tests
function TestSpatialHash.runAll()
    print("\n=== Running Spatial Hash Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Create Grid", TestSpatialHash.testCreateGrid)
    runTest("Insert Items", TestSpatialHash.testInsertItems)
    runTest("Query Exact", TestSpatialHash.testQueryExact)
    runTest("Query Radius", TestSpatialHash.testQueryRadius)
    runTest("Query Rectangle", TestSpatialHash.testQueryRect)
    runTest("Remove Items", TestSpatialHash.testRemoveItems)
    runTest("Is Occupied", TestSpatialHash.testIsOccupied)
    runTest("Clear Grid", TestSpatialHash.testClear)
    runTest("Get Stats", TestSpatialHash.testGetStats)
    runTest("World to Cell", TestSpatialHash.testWorldToCell)
    runTest("Performance", TestSpatialHash.testPerformance)
    
    print("\n=== Spatial Hash Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d (%.1f%%)",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed,
        (testsFailed / (testsPassed + testsFailed)) * 100
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All tests passed!")
    end
    
    return testsPassed, testsFailed
end

return TestSpatialHash
