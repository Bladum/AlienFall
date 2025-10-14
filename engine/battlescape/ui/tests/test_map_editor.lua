--[[
    Map Editor Unit Tests
    Tests MapEditor class functionality including:
    - Grid management
    - Tool operations
    - History (undo/redo)
    - Save/load
    - Metadata
    - Statistics
--]]

local MapEditor = require("battlescape.ui.map_editor")
local Tilesets = require("battlescape.data.tilesets")

-- Test results
local tests = {}
local passCount = 0
local failCount = 0

-- Helper function to run test
local function test(name, fn)
    local success, err = pcall(fn)
    if success then
        print(string.format("[PASS] %s", name))
        passCount = passCount + 1
        table.insert(tests, {name = name, passed = true})
    else
        print(string.format("[FAIL] %s: %s", name, err))
        failCount = failCount + 1
        table.insert(tests, {name = name, passed = false, error = err})
    end
end

-- Helper function to assert
local function assertEquals(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s", 
            message or "Assertion failed", 
            tostring(expected), 
            tostring(actual)))
    end
end

local function assertNotNil(value, message)
    if value == nil then
        error(message or "Expected non-nil value")
    end
end

local function assertTrue(condition, message)
    if not condition then
        error(message or "Expected true")
    end
end

-- Initialize tilesets for testing
print("[TEST SUITE] Map Editor Unit Tests")
print("[INIT] Loading tilesets...")
Tilesets.loadAll("mods/core/tilesets")
print(string.format("[INIT] Loaded %d tilesets", Tilesets.getCount()))

-- Phase 1: Basic Grid Operations
print("\n=== Phase 1: Basic Grid Operations ===")

test("Create MapEditor with default size", function()
    local editor = MapEditor.new(15, 15)
    assertNotNil(editor, "Editor should be created")
    assertEquals(editor.width, 15, "Width should be 15")
    assertEquals(editor.height, 15, "Height should be 15")
end)

test("Get/Set tile at position", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(5, 5, "urban:floor_01")
    local tile = editor:getTile(5, 5)
    assertEquals(tile, "urban:floor_01", "Tile should be set")
end)

test("Get empty tile returns EMPTY", function()
    local editor = MapEditor.new(15, 15)
    local tile = editor:getTile(0, 0)
    assertEquals(tile, "EMPTY", "Empty tile should return EMPTY")
end)

test("Get out-of-bounds returns nil", function()
    local editor = MapEditor.new(15, 15)
    local tile = editor:getTile(20, 20)
    assertEquals(tile, nil, "Out of bounds should return nil")
end)

-- Phase 2: Tool Operations
print("\n=== Phase 2: Tool Operations ===")

test("Select tileset", function()
    local editor = MapEditor.new(15, 15)
    editor:selectTileset("urban")
    assertEquals(editor.selectedTileset, "urban", "Tileset should be selected")
end)

test("Select tile", function()
    local editor = MapEditor.new(15, 15)
    editor:selectTile("urban:floor_01")
    assertEquals(editor.selectedTile, "urban:floor_01", "Tile should be selected")
end)

test("Paint tile with selected tile", function()
    local editor = MapEditor.new(15, 15)
    editor:selectTile("urban:floor_01")
    editor:paintTile(3, 3)
    local tile = editor:getTile(3, 3)
    assertEquals(tile, "urban:floor_01", "Tile should be painted")
end)

test("Erase tile", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(4, 4, "urban:floor_01")
    editor:eraseTile(4, 4)
    local tile = editor:getTile(4, 4)
    assertEquals(tile, "EMPTY", "Tile should be erased")
end)

test("Set tool to paint/erase", function()
    local editor = MapEditor.new(15, 15)
    editor:setTool("paint")
    assertEquals(editor.currentTool, "paint", "Tool should be paint")
    editor:setTool("erase")
    assertEquals(editor.currentTool, "erase", "Tool should be erase")
end)

-- Phase 3: History (Undo/Redo)
print("\n=== Phase 3: History (Undo/Redo) ===")

test("Save history creates snapshot", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(1, 1, "urban:floor_01")
    editor:saveHistory()
    assertTrue(#editor.history > 0, "History should have snapshot")
end)

test("Undo restores previous state", function()
    local editor = MapEditor.new(15, 15)
    editor:saveHistory() -- Save empty state
    editor:setTile(2, 2, "urban:floor_01")
    editor:saveHistory() -- Save painted state
    editor:undo()
    local tile = editor:getTile(2, 2)
    assertEquals(tile, "EMPTY", "Tile should be reverted")
end)

test("Redo restores undone state", function()
    local editor = MapEditor.new(15, 15)
    editor:saveHistory() -- Save empty
    editor:setTile(3, 3, "urban:floor_01")
    editor:saveHistory() -- Save painted
    editor:undo() -- Back to empty
    editor:redo() -- Forward to painted
    local tile = editor:getTile(3, 3)
    assertEquals(tile, "urban:floor_01", "Tile should be restored")
end)

test("History limited to 50 states", function()
    local editor = MapEditor.new(15, 15)
    for i = 1, 60 do
        editor:setTile(0, 0, "urban:floor_01")
        editor:saveHistory()
    end
    assertTrue(#editor.history <= 50, "History should be limited to 50")
end)

-- Phase 4: Metadata
print("\n=== Phase 4: Metadata ===")

test("Set metadata fields", function()
    local editor = MapEditor.new(15, 15)
    editor:setMetadata("id", "test_block")
    editor:setMetadata("name", "Test Block")
    editor:setMetadata("group", 5)
    assertEquals(editor.metadata.id, "test_block", "ID should be set")
    assertEquals(editor.metadata.name, "Test Block", "Name should be set")
    assertEquals(editor.metadata.group, 5, "Group should be set")
end)

test("Get metadata fields", function()
    local editor = MapEditor.new(15, 15)
    editor:setMetadata("tags", "urban, test")
    local tags = editor:getMetadata("tags")
    assertEquals(tags, "urban, test", "Tags should be retrieved")
end)

-- Phase 5: Statistics
print("\n=== Phase 5: Statistics ===")

test("Calculate fill percentage", function()
    local editor = MapEditor.new(15, 15) -- 225 tiles
    for i = 0, 49 do -- Paint 50 tiles
        local x = i % 15
        local y = math.floor(i / 15)
        editor:setTile(x, y, "urban:floor_01")
    end
    local stats = editor:getStats()
    local expected = (50 / 225) * 100
    assertTrue(math.abs(stats.fillPercentage - expected) < 0.1, 
        "Fill percentage should be ~22.2%")
end)

test("Count unique tiles", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(0, 0, "urban:floor_01")
    editor:setTile(1, 0, "urban:floor_01")
    editor:setTile(2, 0, "urban:wall_01")
    editor:setTile(3, 0, "urban:door_01")
    local stats = editor:getStats()
    assertEquals(stats.uniqueTiles, 3, "Should have 3 unique tiles")
end)

-- Phase 6: Save/Load
print("\n=== Phase 6: Save/Load ===")

test("Save map to TOML", function()
    local editor = MapEditor.new(15, 15)
    editor:setMetadata("id", "test_save")
    editor:setMetadata("name", "Test Save")
    editor:setTile(0, 0, "urban:floor_01")
    editor:setTile(1, 1, "urban:wall_01")
    
    local tempDir = os.getenv("TEMP")
    local filepath = tempDir .. "\\test_map_save.toml"
    
    local success = editor:save(filepath)
    assertTrue(success, "Save should succeed")
    
    -- Verify file exists
    local file = io.open(filepath, "r")
    assertNotNil(file, "File should exist")
    if file then
        file:close()
        os.remove(filepath) -- Cleanup
    end
end)

test("Load map from TOML", function()
    local editor = MapEditor.new(15, 15)
    editor:setMetadata("id", "test_load")
    editor:setMetadata("name", "Test Load")
    editor:setTile(5, 5, "urban:floor_01")
    editor:setTile(6, 6, "urban:wall_01")
    
    local tempDir = os.getenv("TEMP")
    local filepath = tempDir .. "\\test_map_load.toml"
    
    editor:save(filepath)
    
    -- Create new editor and load
    local editor2 = MapEditor.new(15, 15)
    local success = editor2:load(filepath)
    assertTrue(success, "Load should succeed")
    assertEquals(editor2:getMetadata("id"), "test_load", "Metadata should be loaded")
    assertEquals(editor2:getTile(5, 5), "urban:floor_01", "Tile should be loaded")
    assertEquals(editor2:getTile(6, 6), "urban:wall_01", "Tile should be loaded")
    
    os.remove(filepath) -- Cleanup
end)

-- Phase 7: New Blank Map
print("\n=== Phase 7: New Blank Map ===")

test("Create new blank map", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(0, 0, "urban:floor_01")
    editor:setMetadata("id", "old_map")
    
    editor:new_blank(10, 10)
    
    assertEquals(editor.width, 10, "Width should be reset")
    assertEquals(editor.height, 10, "Height should be reset")
    assertEquals(editor:getTile(0, 0), "EMPTY", "Grid should be empty")
    assertEquals(editor:getMetadata("id"), "", "Metadata should be reset")
end)

-- Phase 8: Dirty Flag
print("\n=== Phase 8: Dirty Flag ===")

test("Dirty flag set on tile change", function()
    local editor = MapEditor.new(15, 15)
    editor.isDirty = false
    editor:setTile(0, 0, "urban:floor_01")
    assertTrue(editor.isDirty, "Dirty flag should be set")
end)

test("Dirty flag cleared on save", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(0, 0, "urban:floor_01")
    editor:setMetadata("id", "dirty_test")
    
    local tempDir = os.getenv("TEMP")
    local filepath = tempDir .. "\\test_dirty.toml"
    
    editor:save(filepath)
    assertTrue(not editor.isDirty, "Dirty flag should be cleared")
    
    os.remove(filepath) -- Cleanup
end)

-- Summary
print("\n=== Test Summary ===")
print(string.format("Total Tests: %d", passCount + failCount))
print(string.format("Passed: %d", passCount))
print(string.format("Failed: %d", failCount))

if failCount > 0 then
    print("\nFailed Tests:")
    for _, test in ipairs(tests) do
        if not test.passed then
            print(string.format("  - %s: %s", test.name, test.error))
        end
    end
end

return {
    passed = passCount,
    failed = failCount,
    total = passCount + failCount,
    tests = tests
}
