-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Hexagonal Grid Mathematics
-- FILE: tests2/utils/hex_math_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.battlescape.battle_ecs.hex_math
-- Covers coordinate systems, distance calculations, neighbors, and conversions
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")
local HexMath = require("engine.battlescape.battle_ecs.hex_math")

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.battle_ecs.hex_math",
    fileName = "hex_math.lua",
    description = "Hexagonal grid mathematics - coordinate systems, distances, neighbors"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: COORDINATE SYSTEM BASICS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Coordinate System Basics", function()
    Suite:testMethod("HexMath:DIRECTIONS", {
        description = "Direction constant table has exactly 6 neighbor directions",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(#HexMath.DIRECTIONS, 6, "Should have 6 directions")

        -- Verify each direction has q and r components
        for i, dir in ipairs(HexMath.DIRECTIONS) do
            Helpers.assertNotNil(dir.q, "Direction " .. i .. " should have q component")
            Helpers.assertNotNil(dir.r, "Direction " .. i .. " should have r component")
        end
    end)

    Suite:testMethod("HexMath:offsetToAxial", {
        description = "Converting origin from offset to axial coordinates preserves location",
        testCase = "origin",
        type = "functional"
    }, function()
        local q, r = HexMath.offsetToAxial(0, 0)
        Helpers.assertEqual(q, 0, "Origin should map to q=0")
        Helpers.assertEqual(r, 0, "Origin should map to r=0")
    end)

    Suite:testMethod("HexMath:offsetToAxial", {
        description = "Converting arbitrary offset coordinates produces valid axial output",
        testCase = "arbitrary_conversion",
        type = "functional"
    }, function()
        local q, r = HexMath.offsetToAxial(5, 10)
        Helpers.assertNotNil(q, "Should return q coordinate")
        Helpers.assertNotNil(r, "Should return r coordinate")
        -- Both should be numbers
        Helpers.assertEqual(type(q), "number", "q should be a number")
        Helpers.assertEqual(type(r), "number", "r should be a number")
    end)

    Suite:testMethod("HexMath:axialToOffset", {
        description = "Converting origin from axial to offset coordinates preserves location",
        testCase = "origin",
        type = "functional"
    }, function()
        local col, row = HexMath.axialToOffset(0, 0)
        Helpers.assertEqual(col, 0, "Axial (0,0) should map to offset col=0")
        Helpers.assertEqual(row, 0, "Axial (0,0) should map to offset row=0")
    end)

    Suite:testMethod("HexMath:axialToOffset", {
        description = "Converting arbitrary axial coordinates produces valid offset output",
        testCase = "arbitrary_conversion",
        type = "functional"
    }, function()
        local col, row = HexMath.axialToOffset(5, 5)
        Helpers.assertNotNil(col, "Should return col coordinate")
        Helpers.assertNotNil(row, "Should return row coordinate")
        Helpers.assertEqual(type(col), "number", "col should be a number")
        Helpers.assertEqual(type(row), "number", "row should be a number")
    end)

    Suite:testMethod("HexMath:axialToOffset", {
        description = "Converting negative axial coordinates produces valid output",
        testCase = "negative_coords",
        type = "functional"
    }, function()
        local col, row = HexMath.axialToOffset(-3, -2)
        Helpers.assertNotNil(col, "Should handle negative q")
        Helpers.assertNotNil(row, "Should handle negative r")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: COORDINATE CONVERSIONS (Round-trip validation)
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Coordinate Conversions", function()
    Suite:testMethod("HexMath:offsetToAxial/axialToOffset", {
        description = "Round-trip conversion preserves original offset coordinates",
        testCase = "round_trip_origin",
        type = "functional"
    }, function()
        local origCol, origRow = 0, 0
        local q, r = HexMath.offsetToAxial(origCol, origRow)
        local col, row = HexMath.axialToOffset(q, r)

        Helpers.assertEqual(col, origCol, "Round-trip should preserve col at origin")
        Helpers.assertEqual(row, origRow, "Round-trip should preserve row at origin")
    end)

    Suite:testMethod("HexMath:offsetToAxial/axialToOffset", {
        description = "Round-trip conversion preserves arbitrary offset coordinates",
        testCase = "round_trip_arbitrary",
        type = "functional"
    }, function()
        local testCases = {
            {10, 15},
            {5, 3},
            {20, 20},
            {1, 1}
        }

        for _, coords in ipairs(testCases) do
            local origCol, origRow = coords[1], coords[2]
            local q, r = HexMath.offsetToAxial(origCol, origRow)
            local col, row = HexMath.axialToOffset(q, r)

            Helpers.assertEqual(col, origCol,
                "Round-trip col failed for (" .. origCol .. "," .. origRow .. ")")
            Helpers.assertEqual(row, origRow,
                "Round-trip row failed for (" .. origCol .. "," .. origRow .. ")")
        end
    end)

    Suite:testMethod("HexMath:axialToCube", {
        description = "Axial to cube conversion maintains cube constraint q+r+s=0",
        testCase = "cube_constraint",
        type = "functional"
    }, function()
        local testAxialCoords = {
            {3, 5},
            {0, 0},
            {-2, 3},
            {10, -5}
        }

        for _, coords in ipairs(testAxialCoords) do
            local q, r, s = HexMath.axialToCube(coords[1], coords[2])
            local sum = q + r + s
            Helpers.assertEqual(sum, 0,
                "Cube constraint violated for axial (" .. coords[1] .. "," .. coords[2] .. ")")
        end
    end)

    Suite:testMethod("HexMath:cubeToAxial", {
        description = "Cube to axial conversion correctly extracts q and r components",
        testCase = "cube_extraction",
        type = "functional"
    }, function()
        local q, r = HexMath.cubeToAxial(3, 5, -8)
        Helpers.assertEqual(q, 3, "Should extract correct q from cube")
        Helpers.assertEqual(r, 5, "Should extract correct r from cube")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: DISTANCE CALCULATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Distance Calculations", function()
    Suite:testMethod("HexMath:distance", {
        description = "Distance from hex to itself is zero",
        testCase = "same_hex",
        type = "functional"
    }, function()
        local dist = HexMath.distance(0, 0, 0, 0)
        Helpers.assertEqual(dist, 0, "Distance to self should be 0")

        dist = HexMath.distance(10, 15, 10, 15)
        Helpers.assertEqual(dist, 0, "Distance to arbitrary self should be 0")
    end)

    Suite:testMethod("HexMath:distance", {
        description = "Distance to adjacent hex is 1",
        testCase = "adjacent_hex",
        type = "functional"
    }, function()
        local dist = HexMath.distance(0, 0, 1, 0)
        Helpers.assertEqual(dist, 1, "Distance to E neighbor should be 1")
    end)

    Suite:testMethod("HexMath:distance", {
        description = "Distance calculation is symmetric (d(A,B) = d(B,A))",
        testCase = "symmetry",
        type = "functional"
    }, function()
        local d1 = HexMath.distance(5, 10, 15, 20)
        local d2 = HexMath.distance(15, 20, 5, 10)
        Helpers.assertEqual(d1, d2, "Distance should be symmetric")
    end)

    Suite:testMethod("HexMath:distance", {
        description = "Distance between arbitrary hexes produces positive integer",
        testCase = "arbitrary_distance",
        type = "functional"
    }, function()
        local dist = HexMath.distance(0, 0, 3, 2)
        Helpers.assertGreater(dist, 0, "Distance should be positive")
        Helpers.assertEqual(type(dist), "number", "Distance should be a number")
    end)

    Suite:testMethod("HexMath:distance", {
        description = "Triangle inequality holds: d(A,C) <= d(A,B) + d(B,C)",
        testCase = "triangle_inequality",
        type = "functional"
    }, function()
        local a = {q = 0, r = 0}
        local b = {q = 5, r = 5}
        local c = {q = 10, r = 0}

        local dAB = HexMath.distance(a.q, a.r, b.q, b.r)
        local dBC = HexMath.distance(b.q, b.r, c.q, c.r)
        local dAC = HexMath.distance(a.q, a.r, c.q, c.r)

        Helpers.assertGreaterOrEqual(dAB + dBC, dAC,
            "Triangle inequality: d(A,C)=" .. dAC .. " should be <= " ..
            "d(A,B)=" .. dAB .. " + d(B,C)=" .. dBC)
    end)

    Suite:testMethod("HexMath:distance", {
        description = "Distance works with negative coordinates",
        testCase = "negative_coords",
        type = "functional"
    }, function()
        local dist = HexMath.distance(-5, -5, 5, 5)
        Helpers.assertGreater(dist, 0, "Distance with negative coords should be positive")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: NEIGHBOR OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Neighbor Operations", function()
    Suite:testMethod("HexMath:neighbor", {
        description = "Getting neighbor in each direction returns a valid hex at distance 1",
        testCase = "all_directions",
        type = "functional"
    }, function()
        local centerQ, centerR = 10, 10

        for dir = 1, 6 do
            local nq, nr = HexMath.neighbor(centerQ, centerR, dir)

            Helpers.assertNotNil(nq, "Direction " .. dir .. " should return valid q")
            Helpers.assertNotNil(nr, "Direction " .. dir .. " should return valid r")

            local dist = HexMath.distance(centerQ, centerR, nq, nr)
            Helpers.assertEqual(dist, 1, "Neighbor " .. dir .. " should be distance 1")
        end
    end)

    Suite:testMethod("HexMath:neighbors", {
        description = "Getting all neighbors returns exactly 6 hexes",
        testCase = "count",
        type = "functional"
    }, function()
        local neighbors = HexMath.neighbors(10, 10)
        Helpers.assertNotNil(neighbors, "Should return neighbors table")
        Helpers.assertEqual(#neighbors, 6, "Should have exactly 6 neighbors")
    end)

    Suite:testMethod("HexMath:neighbors", {
        description = "All neighbors are at distance 1 from center",
        testCase = "distance_verification",
        type = "functional"
    }, function()
        local centerQ, centerR = 10, 10
        local neighbors = HexMath.neighbors(centerQ, centerR)

        for i, neighbor in ipairs(neighbors) do
            local dist = HexMath.distance(centerQ, centerR, neighbor.q, neighbor.r)
            Helpers.assertEqual(dist, 1, "Neighbor " .. i .. " should be distance 1")
        end
    end)

    Suite:testMethod("HexMath:neighbors", {
        description = "All neighbors are unique (no duplicates)",
        testCase = "uniqueness",
        type = "functional"
    }, function()
        local neighbors = HexMath.neighbors(10, 10)
        local seen = {}

        for _, neighbor in ipairs(neighbors) do
            local key = neighbor.q .. "," .. neighbor.r
            Helpers.assertNil(seen[key], "Duplicate neighbor at (" .. key .. ")")
            seen[key] = true
        end
    end)

    Suite:testMethod("HexMath:neighbor", {
        description = "Going to neighbor and back via opposite direction returns to origin",
        testCase = "bidirectional",
        type = "functional"
    }, function()
        local origQ, origR = 10, 10

        -- Test each direction
        for dir = 1, 6 do
            local nq, nr = HexMath.neighbor(origQ, origR, dir)
            -- Opposite direction is dir + 3 (mod 6, but add 1 for 1-indexing)
            local oppositeDir = ((dir - 1 + 3) % 6) + 1
            local backQ, backR = HexMath.neighbor(nq, nr, oppositeDir)

            Helpers.assertEqual(backQ, origQ,
                "Going to neighbor " .. dir .. " and back should return origin q")
            Helpers.assertEqual(backR, origR,
                "Going to neighbor " .. dir .. " and back should return origin r")
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: LINE INTERPOLATION AND DRAWING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Line Drawing", function()
    Suite:testMethod("HexMath:lerp", {
        description = "Lerp at t=0 returns start position",
        testCase = "lerp_start",
        type = "functional"
    }, function()
        local q, r = HexMath.lerp(0, 0, 10, 10, 0.0)
        Helpers.assertEqual(q, 0, "Lerp at t=0 should return start q")
        Helpers.assertEqual(r, 0, "Lerp at t=0 should return start r")
    end)

    Suite:testMethod("HexMath:lerp", {
        description = "Lerp at t=1 returns end position",
        testCase = "lerp_end",
        type = "functional"
    }, function()
        local q, r = HexMath.lerp(0, 0, 10, 10, 1.0)
        Helpers.assertEqual(q, 10, "Lerp at t=1 should return end q")
        Helpers.assertEqual(r, 10, "Lerp at t=1 should return end r")
    end)

    Suite:testMethod("HexMath:lerp", {
        description = "Lerp at midpoint produces valid hex coordinate",
        testCase = "lerp_midpoint",
        type = "functional"
    }, function()
        local q, r = HexMath.lerp(0, 0, 10, 10, 0.5)
        Helpers.assertNotNil(q, "Midpoint lerp should return q")
        Helpers.assertNotNil(r, "Midpoint lerp should return r")
    end)

    Suite:testMethod("HexMath:lineDraw", {
        description = "Line draw returns path with at least start and end points",
        testCase = "line_endpoints",
        type = "functional"
    }, function()
        local line = HexMath.lineDraw(0, 0, 5, 0)
        Helpers.assertNotNil(line, "Should return line table")
        Helpers.assertGreaterOrEqual(#line, 2, "Line should have at least start and end")

        -- First point should be start
        Helpers.assertEqual(line[1].q, 0, "First point should be start q")
        Helpers.assertEqual(line[1].r, 0, "First point should be start r")

        -- Last point should be end
        Helpers.assertEqual(line[#line].q, 5, "Last point should be end q")
        Helpers.assertEqual(line[#line].r, 0, "Last point should be end r")
    end)

    Suite:testMethod("HexMath:lineDraw", {
        description = "Line draw produces continuous path without gaps",
        testCase = "line_continuity",
        type = "functional"
    }, function()
        local line = HexMath.lineDraw(0, 0, 10, 10)

        -- Each consecutive point should be distance 1
        for i = 2, #line do
            local prevPoint = line[i - 1]
            local currPoint = line[i]
            local dist = HexMath.distance(prevPoint.q, prevPoint.r, currPoint.q, currPoint.r)
            Helpers.assertLessOrEqual(dist, 1,
                "Line should be continuous between points " .. (i-1) .. " and " .. i)
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: PERFORMANCE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()
    Suite:testMethod("HexMath:distance", {
        description = "1000 distance calculations complete within reasonable time",
        testCase = "distance_throughput",
        type = "performance"
    }, function()
        local startTime = os.clock()
        local iterations = 1000

        for i = 1, iterations do
            local q1 = math.random(-50, 50)
            local r1 = math.random(-50, 50)
            local q2 = math.random(-50, 50)
            local r2 = math.random(-50, 50)
            HexMath.distance(q1, r1, q2, r2)
        end

        local elapsed = os.clock() - startTime
        local avgTime = (elapsed / iterations) * 1000000  -- Convert to microseconds

        print("[HexMath Performance] 1000 distance calls: " .. string.format("%.2f ms", elapsed * 1000) ..
              " (avg: " .. string.format("%.2f µs", avgTime) .. " per call)")

        -- Should complete in under 100ms
        Helpers.assertLess(elapsed, 0.1, "1000 distance calculations should complete in <100ms")
    end)

    Suite:testMethod("HexMath:neighbors", {
        description = "Neighbor lookups are efficiently computed",
        testCase = "neighbor_performance",
        type = "performance"
    }, function()
        local startTime = os.clock()
        local iterations = 10000

        for i = 1, iterations do
            local q = math.random(-100, 100)
            local r = math.random(-100, 100)
            HexMath.neighbors(q, r)
        end

        local elapsed = os.clock() - startTime
        print("[HexMath Performance] 10000 neighbor lookups: " ..
              string.format("%.2f ms", elapsed * 1000))

        -- Should complete in under 50ms
        Helpers.assertLess(elapsed, 0.05, "10000 neighbor lookups should complete in <50ms")
    end)

    Suite:testMethod("HexMath:lineDraw", {
        description = "Line drawing over moderate distances completes efficiently",
        testCase = "line_draw_performance",
        type = "performance"
    }, function()
        local startTime = os.clock()

        -- Draw 100 lines of varying distances
        for i = 1, 100 do
            HexMath.lineDraw(0, 0, 20, 20)
        end

        local elapsed = os.clock() - startTime
        print("[HexMath Performance] 100 line draws (distance ~28): " ..
              string.format("%.2f ms", elapsed * 1000))

        -- Should complete in under 100ms
        Helpers.assertLess(elapsed, 0.1, "100 line draws should complete in <100ms")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
