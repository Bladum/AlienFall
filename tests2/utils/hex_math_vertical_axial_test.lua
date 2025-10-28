-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Hexagonal Grid Mathematics (Vertical Axial)
-- FILE: tests2/utils/hex_math_vertical_axial_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.battlescape.battle_ecs.hex_math
-- Validates vertical axial coordinate system implementation
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
    description = "Vertical axial hex mathematics - directions, distances, conversions"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: DIRECTION SYSTEM VALIDATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Direction System", function()
    Suite:testMethod("HexMath.DIRECTIONS", {
        description = "Direction vectors match vertical axial specification",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(#HexMath.DIRECTIONS, 6, "Should have exactly 6 directions")

        -- Validate each direction according to vertical axial spec
        Helpers.assertEqual(HexMath.DIRECTIONS[1].q, 1, "Dir 0 (E): q+1")
        Helpers.assertEqual(HexMath.DIRECTIONS[1].r, 0, "Dir 0 (E): r+0")

        Helpers.assertEqual(HexMath.DIRECTIONS[2].q, 0, "Dir 1 (SE): q+0")
        Helpers.assertEqual(HexMath.DIRECTIONS[2].r, 1, "Dir 1 (SE): r+1")

        Helpers.assertEqual(HexMath.DIRECTIONS[3].q, -1, "Dir 2 (SW): q-1")
        Helpers.assertEqual(HexMath.DIRECTIONS[3].r, 1, "Dir 2 (SW): r+1")

        Helpers.assertEqual(HexMath.DIRECTIONS[4].q, -1, "Dir 3 (W): q-1")
        Helpers.assertEqual(HexMath.DIRECTIONS[4].r, 0, "Dir 3 (W): r+0")

        Helpers.assertEqual(HexMath.DIRECTIONS[5].q, 0, "Dir 4 (NW): q+0")
        Helpers.assertEqual(HexMath.DIRECTIONS[5].r, -1, "Dir 4 (NW): r-1")

        Helpers.assertEqual(HexMath.DIRECTIONS[6].q, 1, "Dir 5 (NE): q+1")
        Helpers.assertEqual(HexMath.DIRECTIONS[6].r, -1, "Dir 5 (NE): r-1")
    end)

    Suite:testMethod("HexMath.DIRECTION_NAMES", {
        description = "Direction names array has correct labels",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(#HexMath.DIRECTION_NAMES, 6, "Should have 6 direction names")
        Helpers.assertEqual(HexMath.DIRECTION_NAMES[1], "E", "Dir 0 is East")
        Helpers.assertEqual(HexMath.DIRECTION_NAMES[2], "SE", "Dir 1 is Southeast")
        Helpers.assertEqual(HexMath.DIRECTION_NAMES[3], "SW", "Dir 2 is Southwest")
        Helpers.assertEqual(HexMath.DIRECTION_NAMES[4], "W", "Dir 3 is West")
        Helpers.assertEqual(HexMath.DIRECTION_NAMES[5], "NW", "Dir 4 is Northwest")
        Helpers.assertEqual(HexMath.DIRECTION_NAMES[6], "NE", "Dir 5 is Northeast")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: COORDINATE CONVERSIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Coordinate Conversions", function()
    Suite:testMethod("HexMath.axialToCube", {
        description = "Converts axial to cube coordinates correctly",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local x, y, z = HexMath.axialToCube(0, 0)
        Helpers.assertEqual(x, 0, "Origin: x=0")
        Helpers.assertEqual(y, 0, "Origin: y=0")
        Helpers.assertEqual(z, 0, "Origin: z=0")
        Helpers.assertEqual(x + y + z, 0, "Cube constraint: x+y+z=0")

        local x2, y2, z2 = HexMath.axialToCube(3, 4)
        Helpers.assertEqual(x2, 3, "q=3 -> x=3")
        Helpers.assertEqual(z2, 4, "r=4 -> z=4")
        Helpers.assertEqual(x2 + y2 + z2, 0, "Cube constraint maintained")
    end)

    Suite:testMethod("HexMath.cubeToAxial", {
        description = "Converts cube to axial coordinates correctly",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local q, r = HexMath.cubeToAxial(0, 0, 0)
        Helpers.assertEqual(q, 0, "Origin: q=0")
        Helpers.assertEqual(r, 0, "Origin: r=0")

        local q2, r2 = HexMath.cubeToAxial(5, -8, 3)
        Helpers.assertEqual(q2, 5, "x=5 -> q=5")
        Helpers.assertEqual(r2, 3, "z=3 -> r=3")
    end)

    Suite:testMethod("HexMath.axialToCube + cubeToAxial", {
        description = "Round-trip conversion preserves coordinates",
        testCase = "round_trip",
        type = "functional"
    }, function()
        local q1, r1 = 7, 12
        local x, y, z = HexMath.axialToCube(q1, r1)
        local q2, r2 = HexMath.cubeToAxial(x, y, z)
        Helpers.assertEqual(q2, q1, "Q coordinate preserved")
        Helpers.assertEqual(r2, r1, "R coordinate preserved")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: DISTANCE CALCULATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Distance Calculations", function()
    Suite:testMethod("HexMath.distance", {
        description = "Calculates correct distance between hexes",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local dist1 = HexMath.distance(0, 0, 0, 0)
        Helpers.assertEqual(dist1, 0, "Distance to self is 0")

        local dist2 = HexMath.distance(0, 0, 1, 0)
        Helpers.assertEqual(dist2, 1, "Adjacent hex distance is 1")

        -- Example from design doc: {q=0, r=0} to {q=5, r=3} = 8 hexes
        local dist3 = HexMath.distance(0, 0, 5, 3)
        Helpers.assertEqual(dist3, 8, "Distance matches design example")
    end)

    Suite:testMethod("HexMath.distance", {
        description = "Distance works with negative coordinates",
        testCase = "negative_coords",
        type = "functional"
    }, function()
        local dist = HexMath.distance(-3, -2, 3, 2)
        Helpers.assertNotNil(dist, "Should handle negative coordinates")
        Helpers.assertTrue(dist > 0, "Distance should be positive")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: NEIGHBOR CALCULATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Neighbor Calculations", function()
    Suite:testMethod("HexMath.neighbor", {
        description = "Gets correct neighbor in each direction",
        testCase = "all_directions",
        type = "functional"
    }, function()
        local q, r = 3, 4

        -- Direction 0: E (q+1, r+0)
        local nq0, nr0 = HexMath.neighbor(q, r, 0)
        Helpers.assertEqual(nq0, 4, "E: q+1")
        Helpers.assertEqual(nr0, 4, "E: r+0")

        -- Direction 1: SE (q+0, r+1)
        local nq1, nr1 = HexMath.neighbor(q, r, 1)
        Helpers.assertEqual(nq1, 3, "SE: q+0")
        Helpers.assertEqual(nr1, 5, "SE: r+1")

        -- Direction 2: SW (q-1, r+1)
        local nq2, nr2 = HexMath.neighbor(q, r, 2)
        Helpers.assertEqual(nq2, 2, "SW: q-1")
        Helpers.assertEqual(nr2, 5, "SW: r+1")

        -- Direction 3: W (q-1, r+0)
        local nq3, nr3 = HexMath.neighbor(q, r, 3)
        Helpers.assertEqual(nq3, 2, "W: q-1")
        Helpers.assertEqual(nr3, 4, "W: r+0")

        -- Direction 4: NW (q+0, r-1)
        local nq4, nr4 = HexMath.neighbor(q, r, 4)
        Helpers.assertEqual(nq4, 3, "NW: q+0")
        Helpers.assertEqual(nr4, 3, "NW: r-1")

        -- Direction 5: NE (q+1, r-1)
        local nq5, nr5 = HexMath.neighbor(q, r, 5)
        Helpers.assertEqual(nq5, 4, "NE: q+1")
        Helpers.assertEqual(nr5, 3, "NE: r-1")
    end)

    Suite:testMethod("HexMath.getNeighbors", {
        description = "Returns all 6 neighbors",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local neighbors = HexMath.getNeighbors(5, 10)
        Helpers.assertEqual(#neighbors, 6, "Should return 6 neighbors")

        for i, neighbor in ipairs(neighbors) do
            Helpers.assertNotNil(neighbor.q, "Neighbor " .. i .. " has q")
            Helpers.assertNotNil(neighbor.r, "Neighbor " .. i .. " has r")
        end
    end)

    Suite:testMethod("HexMath.getDirection", {
        description = "Identifies direction from hex1 to hex2",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local dir0 = HexMath.getDirection(3, 4, 4, 4)  -- E
        Helpers.assertEqual(dir0, 0, "East direction is 0")

        local dir1 = HexMath.getDirection(3, 4, 3, 5)  -- SE
        Helpers.assertEqual(dir1, 1, "Southeast direction is 1")

        local dir3 = HexMath.getDirection(3, 4, 2, 4)  -- W
        Helpers.assertEqual(dir3, 3, "West direction is 3")

        local dirNone = HexMath.getDirection(0, 0, 5, 5)  -- Not adjacent
        Helpers.assertEqual(dirNone, -1, "Non-adjacent returns -1")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: LINE OF SIGHT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Line of Sight", function()
    Suite:testMethod("HexMath.hexLine", {
        description = "Returns line of hexes from source to target",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local line = HexMath.hexLine(0, 0, 3, 0)
        Helpers.assertNotNil(line, "Should return line array")
        Helpers.assertTrue(#line > 0, "Line should have hexes")
        Helpers.assertEqual(line[1].q, 0, "First hex is source")
        Helpers.assertEqual(line[1].r, 0, "First hex is source")
    end)

    Suite:testMethod("HexMath.hexLine", {
        description = "Line to self returns single hex",
        testCase = "same_hex",
        type = "functional"
    }, function()
        local line = HexMath.hexLine(5, 5, 5, 5)
        Helpers.assertEqual(#line, 1, "Should return single hex")
        Helpers.assertEqual(line[1].q, 5, "Returns same hex")
        Helpers.assertEqual(line[1].r, 5, "Returns same hex")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: RANGE AND AREA
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Range and Area", function()
    Suite:testMethod("HexMath.hexesInRange", {
        description = "Returns all hexes within range",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local hexes0 = HexMath.hexesInRange(0, 0, 0)
        Helpers.assertEqual(#hexes0, 1, "Range 0 returns center only")

        local hexes1 = HexMath.hexesInRange(0, 0, 1)
        Helpers.assertEqual(#hexes1, 7, "Range 1 returns center + 6 neighbors")

        local hexes2 = HexMath.hexesInRange(0, 0, 2)
        Helpers.assertTrue(#hexes2 > 7, "Range 2 returns more hexes")
    end)

    Suite:testMethod("HexMath.hexRing", {
        description = "Returns hexes at exact distance",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local ring0 = HexMath.hexRing(0, 0, 0)
        Helpers.assertEqual(#ring0, 1, "Ring 0 is center only")

        local ring1 = HexMath.hexRing(0, 0, 1)
        Helpers.assertEqual(#ring1, 6, "Ring 1 has 6 hexes")

        local ring2 = HexMath.hexRing(0, 0, 2)
        Helpers.assertEqual(#ring2, 12, "Ring 2 has 12 hexes")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 7: PIXEL CONVERSION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Pixel Conversion", function()
    Suite:testMethod("HexMath.hexToPixel", {
        description = "Converts hex to pixel coordinates",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local x, y = HexMath.hexToPixel(0, 0, 24)
        Helpers.assertEqual(x, 0, "Origin hex at pixel (0, 0)")
        Helpers.assertEqual(y, 0, "Origin hex at pixel (0, 0)")

        local x2, y2 = HexMath.hexToPixel(1, 0, 24)
        Helpers.assertTrue(x2 > 0, "East hex has positive X")
        Helpers.assertTrue(y2 > 0, "Odd column shifted down")
    end)

    Suite:testMethod("HexMath.pixelToHex", {
        description = "Converts pixel to hex coordinates",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local q, r = HexMath.pixelToHex(0, 0, 24)
        Helpers.assertEqual(q, 0, "Origin pixel at hex (0, 0)")
        Helpers.assertEqual(r, 0, "Origin pixel at hex (0, 0)")
    end)

    Suite:testMethod("HexMath.hexToPixel + pixelToHex", {
        description = "Round-trip conversion preserves hex coordinates",
        testCase = "round_trip",
        type = "functional"
    }, function()
        local q1, r1 = 5, 3
        local x, y = HexMath.hexToPixel(q1, r1, 24)
        local q2, r2 = HexMath.pixelToHex(x, y, 24)
        Helpers.assertEqual(q2, q1, "Q coordinate preserved")
        Helpers.assertEqual(r2, r1, "R coordinate preserved")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 8: UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Utility Functions", function()
    Suite:testMethod("HexMath.equals", {
        description = "Compares hex coordinates for equality",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertTrue(HexMath.equals(5, 3, 5, 3), "Same coords are equal")
        Helpers.assertFalse(HexMath.equals(5, 3, 5, 4), "Different r not equal")
        Helpers.assertFalse(HexMath.equals(5, 3, 6, 3), "Different q not equal")
    end)

    Suite:testMethod("HexMath.isValid", {
        description = "Validates hex coordinates",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertTrue(HexMath.isValid(0, 0), "Origin is valid")
        Helpers.assertTrue(HexMath.isValid(5, 3), "Positive coords valid")
        Helpers.assertTrue(HexMath.isValid(-5, -3), "Negative coords valid")
        Helpers.assertFalse(HexMath.isValid(nil, 0), "Nil q is invalid")
        Helpers.assertFalse(HexMath.isValid(0, nil), "Nil r is invalid")
    end)

    Suite:testMethod("HexMath.rotationToFace", {
        description = "Calculates rotation needed to face target",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local rot1 = HexMath.rotationToFace(0, 1)
        Helpers.assertEqual(rot1, 1, "0->1 requires +1 rotation")

        local rot2 = HexMath.rotationToFace(0, 5)
        Helpers.assertEqual(rot2, -1, "0->5 prefers -1 (shorter)")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RETURN SUITE
-- ─────────────────────────────────────────────────────────────────────────

return Suite

