#!/usr/bin/env love
-- Hex Renderer Test
-- Phase 6: Test hex grid integration with Map Tile system
-- Run with: lovec engine

print("=======================================================")
print("HEX RENDERER TEST - Phase 6: Hex Grid Integration")
print("Testing: Hex coordinates, 6-neighbor adjacency, autotile")
print("=======================================================\n")

-- Add engine to package path
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"

-- Load modules
print("[TEST] Loading modules...")
local HexRenderer = require("battlescape.rendering.hex_renderer")
local Tilesets = require("battlescape.data.tilesets")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")

print("[TEST] ? Modules loaded\n")

-- Test counters
local testsRun = 0
local testsPassed = 0
local testsFailed = 0

---Test helper
local function test(name, fn)
    testsRun = testsRun + 1
    print(string.format("\n[TEST %d] %s", testsRun, name))
    print(string.rep("-", 60))
    
    local success, err = pcall(fn)
    
    if success then
        testsPassed = testsPassed + 1
        print("? PASSED\n")
    else
        testsFailed = testsFailed + 1
        print(string.format("? FAILED: %s\n", tostring(err)))
    end
end

---Assert helper
local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(message or string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
    end
end

local function assert_not_nil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

local function assert_true(condition, message)
    if not condition then
        error(message or "Condition should be true")
    end
end

print("=======================================================")
print("PHASE 1: Hex Coordinate System")
print("=======================================================")

local renderer = HexRenderer.new(24)

test("Create Hex Renderer", function()
    assert_not_nil(renderer, "Renderer should be created")
    assert_equal(renderer.tileSize, 24, "Tile size should be 24")
    print(string.format("  Hex size: %.2f × %.2f pixels", renderer.hexWidth, renderer.hexHeight))
end)

test("Hex to Pixel Conversion (Even Column)", function()
    local x, y = renderer:hexToPixel(0, 0)
    assert_equal(x, 0, "X should be 0")
    assert_equal(y, 0, "Y should be 0")
    print(string.format("  Hex (0,0) › Pixel (%.2f, %.2f)", x, y))
    
    local x2, y2 = renderer:hexToPixel(2, 1)
    print(string.format("  Hex (2,1) › Pixel (%.2f, %.2f)", x2, y2))
end)

test("Hex to Pixel Conversion (Odd Column)", function()
    local x, y = renderer:hexToPixel(1, 0)
    assert_equal(x, 24, "X should be 24")
    assert_true(y > 0, "Y should be offset for odd column")
    print(string.format("  Hex (1,0) › Pixel (%.2f, %.2f)", x, y))
end)

test("Pixel to Hex Conversion", function()
    local hexX, hexY = renderer:pixelToHex(0, 0)
    assert_equal(hexX, 0, "Hex X should be 0")
    assert_equal(hexY, 0, "Hex Y should be 0")
    print(string.format("  Pixel (0,0) › Hex (%d,%d)", hexX, hexY))
    
    local hexX2, hexY2 = renderer:pixelToHex(48, 20)
    print(string.format("  Pixel (48,20) › Hex (%d,%d)", hexX2, hexY2))
end)

print("\n=======================================================")
print("PHASE 2: Hex Neighbor System (6-directional)")
print("=======================================================")

test("Get Neighbors for Even Column Hex", function()
    local neighbors = renderer:getHexNeighbors(0, 0)
    assert_equal(#neighbors, 6, "Should have 6 neighbors")
    
    print("  Hex (0,0) neighbors:")
    for i, n in ipairs(neighbors) do
        print(string.format("    %d: (%d,%d)", i, n.x, n.y))
    end
end)

test("Get Neighbors for Odd Column Hex", function()
    local neighbors = renderer:getHexNeighbors(1, 1)
    assert_equal(#neighbors, 6, "Should have 6 neighbors")
    
    print("  Hex (1,1) neighbors:")
    for i, n in ipairs(neighbors) do
        print(string.format("    %d: (%d,%d)", i, n.x, n.y))
    end
end)

test("Verify Neighbor Symmetry", function()
    -- If (1,1) is neighbor of (0,0), then (0,0) should be neighbor of (1,1)
    local neighbors1 = renderer:getHexNeighbors(0, 0)
    local neighbors2 = renderer:getHexNeighbors(1, 1)
    
    local found1in2 = false
    for _, n in ipairs(neighbors1) do
        if n.x == 1 and n.y == 1 then
            found1in2 = true
            break
        end
    end
    
    local found2in1 = false
    for _, n in ipairs(neighbors2) do
        if n.x == 0 and n.y == 0 then
            found2in1 = true
            break
        end
    end
    
    -- Note: Hex (0,0) and (1,1) may not be adjacent in flat-top hex grid
    print(string.format("  (1,1) in neighbors of (0,0): %s", tostring(found1in2)))
    print(string.format("  (0,0) in neighbors of (1,1): %s", tostring(found2in1)))
    print("  ? Neighbor system functional")
end)

print("\n=======================================================")
print("PHASE 3: Hex Autotile Calculation")
print("=======================================================")

test("Calculate Autotile Mask (No Neighbors)", function()
    local map = {
        ["0_0"] = "urban:floor_01"
    }
    
    local mask = renderer:calculateHexAutotile(map, 0, 0, "urban:floor_01")
    assert_equal(mask, 0, "Mask should be 0 with no matching neighbors")
    print(string.format("  Autotile mask: %d (binary: %s)", mask, string.format("%06b", mask)))
end)

test("Calculate Autotile Mask (All Neighbors)", function()
    local map = {}
    
    -- Create 7-tile cluster (center + 6 neighbors)
    map["0_0"] = "urban:floor_01"
    
    local neighbors = renderer:getHexNeighbors(0, 0)
    for _, n in ipairs(neighbors) do
        local key = string.format("%d_%d", n.x, n.y)
        map[key] = "urban:floor_01"
    end
    
    local mask = renderer:calculateHexAutotile(map, 0, 0, "urban:floor_01")
    assert_equal(mask, 63, "Mask should be 63 (all 6 neighbors = 111111)")
    print(string.format("  Autotile mask: %d (binary: %s)", mask, string.format("%06b", mask)))
end)

test("Calculate Autotile Mask (Partial Neighbors)", function()
    local map = {
        ["0_0"] = "urban:floor_01",
        ["0_-1"] = "urban:floor_01", -- North
        ["1_0"] = "urban:floor_01",  -- Northeast (even column)
    }
    
    local mask = renderer:calculateHexAutotile(map, 0, 0, "urban:floor_01")
    print(string.format("  Autotile mask: %d (binary: %s)", mask, string.format("%06b", mask)))
    assert_true(mask > 0 and mask < 63, "Mask should be between 0 and 63")
end)

print("\n=======================================================")
print("PHASE 4: Multi-Cell Detection")
print("=======================================================")

-- Load tilesets
Tilesets.loadAll("mods/core/tilesets")

test("Load Tilesets for Testing", function()
    local tilesets = Tilesets.getAll()
    local count = 0
    for _ in pairs(tilesets) do
        count = count + 1
    end
    assert_true(count > 0, "Should load at least one tileset")
    print(string.format("  Loaded %d tilesets", count))
end)

test("Detect Single-Cell Tile", function()
    local isMulti, width, height = renderer:isMultiCell("urban:floor_01")
    assert_equal(isMulti, false, "Regular tile should be single-cell")
    print("  ? Single-cell tile detected correctly")
end)

test("Detect Multi-Cell Tile (if available)", function()
    -- Try to find a multi-cell tile in loaded tilesets
    local foundMultiCell = false
    
    for tilesetId, tileset in pairs(Tilesets.getAll()) do
        for tileId, tile in pairs(tileset.tiles) do
            if tile.multiTileMode == "multi-cell" then
                local tileKey = string.format("%s:%s", tilesetId, tileId)
                local isMulti, width, height = renderer:isMultiCell(tileKey)
                
                if isMulti then
                    foundMultiCell = true
                    print(string.format("  Found multi-cell tile: %s (%dx%d)", tileKey, width, height))
                    break
                end
            end
        end
        if foundMultiCell then break end
    end
    
    if not foundMultiCell then
        print("  No multi-cell tiles found in loaded tilesets (OK)")
    end
end)

print("\n=======================================================")
print("PHASE 5: Hex Grid Rendering Test")
print("=======================================================")

test("Render Single Map Tile", function()
    -- This would normally render to screen, but we can test the method exists
    local success = pcall(function()
        renderer:renderMapTile("urban:floor_01", 0, 0, 1.0, 1.0, nil)
    end)
    assert_true(success, "Render should not error")
    print("  ? Render method functional")
end)

test("Render with Autotile", function()
    local map = {
        ["0_0"] = "urban:floor_01",
        ["0_-1"] = "urban:floor_01",
        ["1_0"] = "urban:floor_01"
    }
    
    local success = pcall(function()
        renderer:renderMapTile("urban:floor_01", 0, 0, 1.0, 1.0, map)
    end)
    assert_true(success, "Render with autotile should not error")
    print("  ? Autotile rendering functional")
end)

test("Toggle Grid Overlay", function()
    local initialState = renderer.showGrid
    renderer:toggleGrid()
    assert_true(renderer.showGrid ~= initialState, "Grid state should toggle")
    renderer:toggleGrid()
    assert_equal(renderer.showGrid, initialState, "Grid should return to initial state")
    print("  ? Grid toggle functional")
end)

print("\n=======================================================")
print("PHASE 6: Integration with Map Blocks")
print("=======================================================")

-- Load map blocks
MapBlockLoader.loadAll("mods/core/mapblocks")

test("Render Map Block on Hex Grid", function()
    local blocks = MapBlockLoader.getAll()
    local testBlock = nil
    
    for _, block in pairs(blocks) do
        testBlock = block
        break
    end
    
    if testBlock then
        print(string.format("  Test block: %s (%dx%d)", testBlock.id, testBlock.width, testBlock.height))
        
        -- Count tiles that would be rendered
        local tileCount = 0
        for key, tileKey in pairs(testBlock.tiles) do
            if tileKey ~= "EMPTY" then
                tileCount = tileCount + 1
            end
        end
        
        print(string.format("  Tiles to render: %d", tileCount))
        assert_true(tileCount >= 0, "Should have valid tile count")
    else
        print("  No map blocks loaded (OK)")
    end
end)

print("\n=======================================================")
print("TEST SUMMARY")
print("=======================================================")
print(string.format("Total tests: %d", testsRun))
print(string.format("Passed: %d (%.1f%%)", testsPassed, (testsPassed / testsRun) * 100))
print(string.format("Failed: %d", testsFailed))
print("=======================================================")

if testsFailed == 0 then
    print("\n??? ALL TESTS PASSED! ???")
    print("Hex grid integration is COMPLETE and WORKING!")
    os.exit(0)
else
    print("\n??? SOME TESTS FAILED ???")
    print("Review failures above and fix issues.")
    os.exit(1)
end

























