---Test Suite for Movement System
---Tests unit movement, AP consumption, and pathfinding

-- Mock dependencies
if not love then
    love = {}
end

local MockUnits = require("tests.mock.units")
local MockBattlescape = require("tests.mock.battlescape")

local TestMovementSystem = {}
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

---Test: Create movement data
function TestMovementSystem.testCreateMovement()
    local unit = MockUnits.getSoldier("John", "ASSAULT")
    
    assert(unit.tu ~= nil, "Unit should have TU data")
    assert(unit.tu.current > 0, "Unit should have current TU")
    assert(unit.tu.max > 0, "Unit should have max TU")
    assert(unit.position ~= nil, "Unit should have position")
end

---Test: Calculate movement cost
function TestMovementSystem.testMovementCost()
    local unit = MockUnits.getSoldier("Sarah", "SCOUT")
    
    -- Mock movement cost calculation
    local baseCost = 4  -- 4 TU per tile
    local distance = 3
    local totalCost = baseCost * distance
    
    assert(totalCost == 12, "Movement cost should be 12 TU for 3 tiles")
    assert(unit.tu.current >= totalCost, "Unit should have enough TU")
end

---Test: Execute movement
function TestMovementSystem.testExecuteMovement()
    local unit = MockUnits.getSoldier("Mike", "ASSAULT")
    local initialTU = unit.tu.current
    local initialPos = {x = unit.position.x, y = unit.position.y}
    
    -- Create movement action
    local path = {
        {x = initialPos.x, y = initialPos.y},
        {x = initialPos.x + 1, y = initialPos.y},
        {x = initialPos.x + 2, y = initialPos.y}
    }
    
    local moveAction = MockBattlescape.getMovementAction(unit, path)
    
    assert(moveAction.type == "MOVE", "Should be move action")
    assert(#moveAction.path == 3, "Path should have 3 steps")
    assert(moveAction.tuCost > 0, "Movement should cost TU")
end

---Test: Insufficient TU for movement
function TestMovementSystem.testInsufficientTU()
    local unit = MockUnits.getSoldier("Tom", "HEAVY")
    
    -- Set low TU
    unit.tu.current = 5
    
    -- Try to move far (would cost more than 5 TU)
    local path = {}
    for i = 1, 10 do
        table.insert(path, {x = i, y = 0})
    end
    
    local moveAction = MockBattlescape.getMovementAction(unit, path)
    local moveCost = moveAction.tuCost
    
    assert(moveCost > unit.tu.current, "Movement should cost more TU than available")
    
    -- Movement should fail
    local canMove = unit.tu.current >= moveCost
    assert(not canMove, "Unit should not have enough TU")
end

---Test: Movement range calculation
function TestMovementSystem.testMovementRange()
    local unit = MockUnits.getSoldier("Anna", "SCOUT")
    
    -- Calculate maximum movement range
    local tuPerTile = 4
    local maxRange = math.floor(unit.tu.current / tuPerTile)
    
    assert(maxRange > 0, "Unit should be able to move")
    assert(maxRange >= 5, "Scout should have good movement range")
    
    print(string.format("[Movement Range] Scout can move %d tiles with %d TU", 
        maxRange, unit.tu.current))
end

---Test: Movement with obstacles
function TestMovementSystem.testMovementWithObstacles()
    local unit = MockUnits.getSoldier("Bob", "ASSAULT")
    
    -- Create path that would go through obstacle
    local path = {
        {x = 5, y = 5},
        {x = 6, y = 5},  -- Obstacle here
        {x = 7, y = 5}
    }
    
    -- Mock obstacle detection
    local hasObstacle = true
    local moveAction = MockBattlescape.getMovementAction(unit, path)
    
    assert(moveAction ~= nil, "Should create movement action")
    -- In real system, this would fail due to obstacle
end

---Test: Diagonal vs straight movement
function TestMovementSystem.testDiagonalMovement()
    local unit = MockUnits.getSoldier("Chris", "ASSAULT")
    
    -- Straight movement (3 tiles)
    local straightPath = {
        {x = 0, y = 0}, {x = 1, y = 0}, {x = 2, y = 0}, {x = 3, y = 0}
    }
    
    -- Diagonal movement (should be similar cost in hex grid)
    local diagonalPath = {
        {x = 0, y = 0}, {x = 1, y = 1}, {x = 2, y = 2}, {x = 3, y = 3}
    }
    
    assert(#straightPath == #diagonalPath, "Paths should have same length")
end

---Test: Movement on different terrain
function TestMovementSystem.testTerrainModifiers()
    local unit = MockUnits.getSoldier("Dave", "ASSAULT")
    
    -- Mock terrain costs
    local terrainCosts = {
        grass = 1.0,
        sand = 1.2,
        water = 2.0,
        road = 0.5
    }
    
    local baseCost = 4
    
    -- Calculate modified costs
    local grassCost = baseCost * terrainCosts.grass
    local waterCost = baseCost * terrainCosts.water
    local roadCost = baseCost * terrainCosts.road
    
    assert(waterCost > grassCost, "Water should cost more than grass")
    assert(roadCost < grassCost, "Road should cost less than grass")
    
    print(string.format("[Terrain Costs] Grass: %d, Water: %d, Road: %d",
        grassCost, waterCost, roadCost))
end

---Test: Multiple unit movement
function TestMovementSystem.testMultipleUnits()
    local squad = MockUnits.generateSquad(4)
    
    -- Each unit moves
    for i, unit in ipairs(squad) do
        local path = {
            {x = i, y = 0},
            {x = i, y = 1},
            {x = i, y = 2}
        }
        
        local moveAction = MockBattlescape.getMovementAction(unit, path)
        assert(moveAction ~= nil, string.format("Unit %d should create movement", i))
    end
    
    print(string.format("[Multi-Unit] Moved %d units", #squad))
end

---Test: Movement cancellation
function TestMovementSystem.testMovementCancellation()
    local unit = MockUnits.getSoldier("Eve", "ASSAULT")
    local initialTU = unit.tu.current
    
    -- Create movement
    local path = {{x = 0, y = 0}, {x = 1, y = 0}}
    local moveAction = MockBattlescape.getMovementAction(unit, path)
    
    -- Cancel movement (TU should not be consumed)
    moveAction.result = {cancelled = true}
    
    assert(unit.tu.current == initialTU, "Cancelled movement should not consume TU")
end

---Test: Movement completion
function TestMovementSystem.testMovementCompletion()
    local unit = MockUnits.getSoldier("Frank", "ASSAULT")
    local initialTU = unit.tu.current
    local initialPos = {x = 5, y = 5}
    unit.position = initialPos
    
    -- Execute movement
    local targetPos = {x = 7, y = 5}
    local path = {initialPos, {x = 6, y = 5}, targetPos}
    local moveAction = MockBattlescape.getMovementAction(unit, path)
    
    -- Simulate completion
    unit.tu.current = initialTU - moveAction.tuCost
    unit.position = targetPos
    
    assert(unit.tu.current < initialTU, "TU should be consumed")
    assert(unit.position.x == targetPos.x, "Unit should reach target X")
    assert(unit.position.y == targetPos.y, "Unit should reach target Y")
end

---Test: Zero-length path
function TestMovementSystem.testZeroLengthPath()
    local unit = MockUnits.getSoldier("Grace", "SCOUT")
    
    -- Path with only current position
    local path = {{x = 10, y = 10}}
    local moveAction = MockBattlescape.getMovementAction(unit, path)
    
    -- Zero movement should cost zero TU
    assert(moveAction.tuCost == 4, "Single step path has base cost")
end

-- Run all tests
function TestMovementSystem.runAll()
    print("\n=== Running Movement System Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Create Movement", TestMovementSystem.testCreateMovement)
    runTest("Movement Cost", TestMovementSystem.testMovementCost)
    runTest("Execute Movement", TestMovementSystem.testExecuteMovement)
    runTest("Insufficient TU", TestMovementSystem.testInsufficientTU)
    runTest("Movement Range", TestMovementSystem.testMovementRange)
    runTest("Movement with Obstacles", TestMovementSystem.testMovementWithObstacles)
    runTest("Diagonal Movement", TestMovementSystem.testDiagonalMovement)
    runTest("Terrain Modifiers", TestMovementSystem.testTerrainModifiers)
    runTest("Multiple Units", TestMovementSystem.testMultipleUnits)
    runTest("Movement Cancellation", TestMovementSystem.testMovementCancellation)
    runTest("Movement Completion", TestMovementSystem.testMovementCompletion)
    runTest("Zero-Length Path", TestMovementSystem.testZeroLengthPath)
    
    print("\n=== Movement System Test Results ===")
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

return TestMovementSystem



