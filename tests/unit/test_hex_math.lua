---Test Suite for Hex Math System
---Tests hexagonal grid mathematics and coordinate conversions

local HexMath = require("engine.battlescape.battle_ecs.hex_math")

local TestHexMath = {}
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

---Test: Hex direction vectors
function TestHexMath.testDirections()
    assert(#HexMath.DIRECTIONS == 6, "Should have 6 directions")
    
    -- Check specific directions
    assert(HexMath.DIRECTIONS[1].q == 1 and HexMath.DIRECTIONS[1].r == 0, "Direction 1 should be E")
    assert(HexMath.DIRECTIONS[3].q == 0 and HexMath.DIRECTIONS[3].r == -1, "Direction 3 should be NW")
    assert(HexMath.DIRECTIONS[4].q == -1 and HexMath.DIRECTIONS[4].r == 0, "Direction 4 should be W")
end

---Test: Offset to axial conversion
function TestHexMath.testOffsetToAxial()
    local q, r = HexMath.offsetToAxial(0, 0)
    assert(q == 0 and r == 0, "Origin should be (0,0) in axial")
    
    q, r = HexMath.offsetToAxial(2, 2)
    assert(q ~= nil and r ~= nil, "Should convert (2,2)")
    
    q, r = HexMath.offsetToAxial(5, 10)
    assert(q ~= nil and r ~= nil, "Should convert (5,10)")
end

---Test: Axial to offset conversion
function TestHexMath.testAxialToOffset()
    local col, row = HexMath.axialToOffset(0, 0)
    assert(col == 0 and row == 0, "Origin should be (0,0) in offset")
    
    col, row = HexMath.axialToOffset(5, 5)
    assert(col ~= nil and row ~= nil, "Should convert (5,5)")
    
    col, row = HexMath.axialToOffset(-3, 2)
    assert(col ~= nil and row ~= nil, "Should convert negative coordinates")
end

---Test: Round trip conversion (offset -> axial -> offset)
function TestHexMath.testRoundTripConversion()
    local originalCol, originalRow = 10, 15
    
    local q, r = HexMath.offsetToAxial(originalCol, originalRow)
    local col, row = HexMath.axialToOffset(q, r)
    
    assert(col == originalCol and row == originalRow, 
        string.format("Round trip should preserve coordinates: (%d,%d) -> (%d,%d)", 
            originalCol, originalRow, col, row))
end

---Test: Hex distance calculation
function TestHexMath.testDistance()
    -- Same hex
    local dist = HexMath.distance(0, 0, 0, 0)
    assert(dist == 0, "Distance to self should be 0")
    
    -- Adjacent hexes
    dist = HexMath.distance(0, 0, 1, 0)
    assert(dist == 1, "Distance to adjacent hex should be 1")
    
    -- Diagonal
    dist = HexMath.distance(0, 0, 3, 2)
    assert(dist == 5, "Distance (0,0) to (3,2) should be 5")
    
    -- Negative coordinates
    dist = HexMath.distance(-2, -3, 1, 2)
    assert(dist > 0, "Distance with negative coords should be positive")
end

---Test: Get neighbor hex
function TestHexMath.testNeighbor()
    -- Get neighbor in each direction
    for dir = 1, 6 do
        local nq, nr = HexMath.neighbor(10, 10, dir)
        assert(nq ~= nil and nr ~= nil, string.format("Should get neighbor in direction %d", dir))
        
        -- Neighbor should be distance 1
        local dist = HexMath.distance(10, 10, nq, nr)
        assert(dist == 1, string.format("Neighbor %d should be distance 1", dir))
    end
end

---Test: Get all neighbors
function TestHexMath.testNeighbors()
    local neighbors = HexMath.neighbors(10, 10)
    assert(#neighbors == 6, "Should have 6 neighbors")
    
    -- All neighbors should be distance 1
    for i, neighbor in ipairs(neighbors) do
        local dist = HexMath.distance(10, 10, neighbor.q, neighbor.r)
        assert(dist == 1, string.format("Neighbor %d should be distance 1", i))
    end
    
    -- All neighbors should be unique
    local seen = {}
    for _, neighbor in ipairs(neighbors) do
        local key = neighbor.q .. "," .. neighbor.r
        assert(not seen[key], "Neighbors should be unique")
        seen[key] = true
    end
end

---Test: Axial to cube conversion
function TestHexMath.testAxialToCube()
    local q, r, s = HexMath.axialToCube(3, 5)
    assert(q == 3 and r == 5, "Q and R should be preserved")
    assert(s == -q - r, "S should equal -q-r")
    assert(q + r + s == 0, "Cube constraint: q+r+s=0")
end

---Test: Cube to axial conversion
function TestHexMath.testCubeToAxial()
    local q, r = HexMath.cubeToAxial(3, 5, -8)
    assert(q == 3 and r == 5, "Should extract Q and R")
end

---Test: Line interpolation (lerp)
function TestHexMath.testLerp()
    -- Lerp from (0,0) to (2,0)
    local q, r = HexMath.lerp(0, 0, 2, 0, 0.0)
    assert(q == 0 and r == 0, "Lerp at t=0 should be start")
    
    q, r = HexMath.lerp(0, 0, 2, 0, 1.0)
    assert(q == 2 and r == 0, "Lerp at t=1 should be end")
    
    q, r = HexMath.lerp(0, 0, 2, 0, 0.5)
    assert(q ~= nil and r ~= nil, "Lerp at t=0.5 should be midpoint")
end

---Test: Line drawing between hexes
function TestHexMath.testLineDraw()
    local line = HexMath.lineDraw(0, 0, 3, 0)
    assert(line ~= nil, "Should return line")
    assert(#line >= 2, "Line should have at least start and end")
    
    -- First point should be start
    assert(line[1].q == 0 and line[1].r == 0, "First point should be start")
    
    -- Last point should be end
    local last = line[#line]
    assert(last.q == 3 and last.r == 0, "Last point should be end")
end

---Test: Distance symmetry
function TestHexMath.testDistanceSymmetry()
    local dist1 = HexMath.distance(5, 10, 15, 20)
    local dist2 = HexMath.distance(15, 20, 5, 10)
    assert(dist1 == dist2, "Distance should be symmetric")
end

---Test: Triangle inequality
function TestHexMath.testTriangleInequality()
    local a = {q = 0, r = 0}
    local b = {q = 5, r = 5}
    local c = {q = 10, r = 0}
    
    local dAB = HexMath.distance(a.q, a.r, b.q, b.r)
    local dBC = HexMath.distance(b.q, b.r, c.q, c.r)
    local dAC = HexMath.distance(a.q, a.r, c.q, c.r)
    
    -- Triangle inequality: dAC <= dAB + dBC
    assert(dAC <= dAB + dBC, 
        string.format("Triangle inequality: %d <= %d + %d", dAC, dAB, dBC))
end

---Test: Neighbor consistency
function TestHexMath.testNeighborConsistency()
    -- Get neighbor, then get reverse neighbor
    local nq, nr = HexMath.neighbor(10, 10, 1)  -- Get neighbor to E
    local backQ, backR = HexMath.neighbor(nq, nr, 4)  -- Go back W
    
    assert(backQ == 10 and backR == 10, "Going to neighbor and back should return to origin")
end

---Test: Performance with many calculations
function TestHexMath.testPerformance()
    local startTime = os.clock()
    
    -- Do 10000 distance calculations
    for i = 1, 10000 do
        local q1, r1 = math.random(-50, 50), math.random(-50, 50)
        local q2, r2 = math.random(-50, 50), math.random(-50, 50)
        HexMath.distance(q1, r1, q2, r2)
    end
    
    local elapsed = os.clock() - startTime
    print(string.format("[Performance] 10000 distance calculations: %.4fs", elapsed))
    
    assert(elapsed < 1.0, "10000 calculations should complete in under 1 second")
end

-- Run all tests
function TestHexMath.runAll()
    print("\n=== Running Hex Math Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Hex Directions", TestHexMath.testDirections)
    runTest("Offset to Axial", TestHexMath.testOffsetToAxial)
    runTest("Axial to Offset", TestHexMath.testAxialToOffset)
    runTest("Round Trip Conversion", TestHexMath.testRoundTripConversion)
    runTest("Hex Distance", TestHexMath.testDistance)
    runTest("Get Neighbor", TestHexMath.testNeighbor)
    runTest("Get All Neighbors", TestHexMath.testNeighbors)
    runTest("Axial to Cube", TestHexMath.testAxialToCube)
    runTest("Cube to Axial", TestHexMath.testCubeToAxial)
    runTest("Line Interpolation", TestHexMath.testLerp)
    runTest("Line Drawing", TestHexMath.testLineDraw)
    runTest("Distance Symmetry", TestHexMath.testDistanceSymmetry)
    runTest("Triangle Inequality", TestHexMath.testTriangleInequality)
    runTest("Neighbor Consistency", TestHexMath.testNeighborConsistency)
    runTest("Performance", TestHexMath.testPerformance)
    
    print("\n=== Hex Math Test Results ===")
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

return TestHexMath
