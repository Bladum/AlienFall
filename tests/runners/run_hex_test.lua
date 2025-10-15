-- Quick test runner for hex grid
-- Run this with: lovec engine run_hex_test.lua

local HexGrid = require("geoscape.systems.hex_grid")

print("\n========== HEX GRID TESTS ==========")

-- Test 1: Grid creation
print("\n[TEST 1] Grid Creation")
local grid = HexGrid.new(80, 40, 12)
assert(grid and grid.width == 80 and grid.height == 40, "Grid creation failed")
print("? PASS")

-- Test 2: Distance calculation
print("\n[TEST 2] Distance Calculation")
local dist = HexGrid.distance(0, 0, 3, 4)
assert(dist == 7, string.format("Expected distance 7, got %d", dist))
print("? PASS")

-- Test 3: Neighbors
print("\n[TEST 3] Neighbor Finding")
local neighbors = HexGrid.neighbors(0, 0)
assert(#neighbors == 6, string.format("Expected 6 neighbors, got %d", #neighbors))
print("? PASS")

-- Test 4: Ring
print("\n[TEST 4] Ring Generation")
local ring1 = HexGrid.ring(0, 0, 1)
local ring2 = HexGrid.ring(0, 0, 2)
assert(#ring1 == 6 and #ring2 == 12, "Ring sizes incorrect")
print("? PASS")

-- Test 5: Area
print("\n[TEST 5] Area Generation")
local area1 = HexGrid.area(0, 0, 1)
local area2 = HexGrid.area(0, 0, 2)
assert(#area1 == 7 and #area2 == 19, "Area sizes incorrect")
print("? PASS")

print("\n?? ALL TESTS PASSED!")
print("==================================\n")






















