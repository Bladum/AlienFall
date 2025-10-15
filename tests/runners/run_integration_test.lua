--[[
    Integration Test Suite
    Tests complete map generation pipeline with all systems integrated
--]]

local Tilesets = require("battlescape.map.tilesets")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local MapScripts = require("battlescape.map.mapscripts_v2")
local MapScriptExecutor = require("battlescape.map.mapscript_executor")
local HexRenderer = require("battlescape.rendering.hex_renderer")
local MapEditor = require("battlescape.ui.map_editor")

---@class MapEditor
---@field setMetadata fun(self, field: string, value: any)
---@field setTile fun(self, x: number, y: number, tileKey: string)
---@field save fun(self, filepath: string): boolean
---@field getTile fun(self, x: number, y: number): string

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

-- Helper assertions
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

local function assertEquals(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\nExpected: %s\nActual: %s", 
            message or "Assertion failed", 
            tostring(expected), 
            tostring(actual)))
    end
end

print("[TEST SUITE] Integration Tests")
print("[INIT] Loading all systems...")

-- Initialize all systems
Tilesets.loadAll("mods/core/tilesets")
MapBlockLoader.loadAll("mods/core/mapblocks")
MapScripts.loadAll("mods/core/mapscripts")

print(string.format("[INIT] Loaded %d tilesets", Tilesets.count()))
print(string.format("[INIT] Loaded %d map blocks", MapBlockLoader.count()))
print(string.format("[INIT] Loaded %d map scripts", MapScripts.count()))

-- Phase 1: Tileset › Map Block › Hex Renderer
print("\n=== Phase 1: Tileset › Map Block › Hex Renderer ===")

test("Render Map Block on hex grid", function()
    local renderer = HexRenderer.new(24)
    assertNotNil(renderer, "HexRenderer should be created")
    
    local block = MapBlockLoader.get("urban_small_01")
    assertNotNil(block, "Map Block should be loaded")
    assertNotNil(block, "Block should be loaded")
    if not block then return end
    assertNotNil(block.height, "Block should have height")
    assertNotNil(block.width, "Block should have width")
    if not block.height or not block.width then return end
    
    local renderedCount = 0
    for y = 0, block.height - 1 do
        for x = 0, block.width - 1 do
            local key = string.format("%d_%d", x, y)
            local tileKey = block.tiles[key]
            if tileKey and tileKey ~= "EMPTY" then
                -- Mock rendering (no love.graphics in test)
                renderedCount = renderedCount + 1
            end
        end
    end
    
    assertTrue(renderedCount > 0, "Should render at least one tile")
    print(string.format("  Rendered %d tiles from Map Block", renderedCount))
end)

test("Calculate hex autotile for Map Block", function()
    local renderer = HexRenderer.new(24)
    local block = MapBlockLoader.get("urban_small_01")
    assertNotNil(block, "Should load test block")
    
    -- Find a tile with neighbors
    local foundTile = false
    if block and block.height and block.width then
        for y = 1, block.height - 2 do
            for x = 1, block.width - 2 do
                local key = string.format("%d_%d", x, y)
                local tileKey = block.tiles and block.tiles[key]
                if tileKey and tileKey ~= "EMPTY" then
                    local mask = renderer:calculateHexAutotile(block.tiles, x, y, tileKey)
                    assertTrue(mask >= 0 and mask <= 63, "Mask should be 0-63")
                    foundTile = true
                    print(string.format("  Tile at (%d,%d) autotile mask: %d", x, y, mask))
                    break
                end
            end
            if foundTile then break end
        end
    end
    
    assertTrue(foundTile, "Should find at least one tile to test")
end)

-- Phase 2: Map Editor › TOML › Map Block Loader
print("\n=== Phase 2: Map Editor › TOML › Map Block Loader ===")

test("Create Map Block with editor and load it", function()
    ---@type MapEditor
    local editor = MapEditor.new(15, 15)
    editor:setMetadata("id", "integration_test_block")
    editor:setMetadata("name", "Integration Test Block")
    editor:setMetadata("group", 99)
    
    -- Paint a simple pattern
    for i = 0, 4 do
        editor:setTile(i, 0, "urban:floor_01")
        editor:setTile(i, 4, "urban:floor_01")
    end
    for i = 0, 4 do
        editor:setTile(0, i, "urban:wall_01")
        editor:setTile(4, i, "urban:wall_01")
    end
    
    -- Save to temp
    local tempDir = os.getenv("TEMP")
    local filepath = tempDir .. "\\integration_test_block.toml"
    
    local saveSuccess = editor:save(filepath)
    assertTrue(saveSuccess, "Save should succeed")
    
    -- Load with MapBlockLoader
    MapBlockLoader.loadFile(filepath)
    local loadedBlock = MapBlockLoader.get("integration_test_block")
    assertNotNil(loadedBlock, "Block should be loadable")
    if loadedBlock then
        assertEquals(loadedBlock.width, 15, "Width should match")
        assertEquals(loadedBlock.height, 15, "Height should match")
        assertEquals(loadedBlock.group, 99, "Group should match")
        
        -- Verify tiles
        assertEquals(loadedBlock.tiles["0_0"], "urban:wall_01", "Corner tile should match")
        assertEquals(loadedBlock.tiles["2_0"], "urban:floor_01", "Floor tile should match")
    end
    
    os.remove(filepath) -- Cleanup
    print("  Successfully round-tripped Map Block through editor")
end)

-- Phase 3: Map Script › Map Block Placement › Hex Rendering
print("\n=== Phase 3: Map Script › Map Block Placement › Hex Rendering ===")

test("Execute Map Script and render result", function()
    local script = MapScripts.get("urban_patrol")
    assertNotNil(script, "Map Script should be loaded")
    
    local executor = MapScriptExecutor.new(script)
    assertNotNil(executor, "Executor should be created")
    
    local success = executor:execute()
    assertTrue(success, "Script should execute successfully")
    
    local finalMap = executor:getMap()
    assertNotNil(finalMap, "Final map should exist")
    assertTrue(finalMap.width > 0, "Map should have width")
    assertTrue(finalMap.height > 0, "Map should have height")
    
    -- Count renderable tiles
    local renderer = HexRenderer.new(24)
    local tileCount = 0
    for y = 0, finalMap.height - 1 do
        for x = 0, finalMap.width - 1 do
            local key = string.format("%d_%d", x, y)
            if finalMap.tiles[key] and finalMap.tiles[key] ~= "EMPTY" then
                tileCount = tileCount + 1
            end
        end
    end
    
    assertTrue(tileCount > 0, "Generated map should have tiles")
    print(string.format("  Generated %dx%d map with %d tiles", 
        finalMap.width, finalMap.height, tileCount))
end)

test("Render multiple Map Scripts", function()
    local scriptNames = {"urban_patrol", "forest_patrol", "ufo_crash_scout"}
    local renderer = HexRenderer.new(24)
    
    for _, scriptName in ipairs(scriptNames) do
        local script = MapScripts.get(scriptName)
        if script then
            local executor = MapScriptExecutor.new(script)
            local success = executor:execute()
            assertTrue(success, string.format("%s should execute", scriptName))
            
            local map = executor:getMap()
            local tileCount = 0
            for y = 0, map.height - 1 do
                for x = 0, map.width - 1 do
                    local key = string.format("%d_%d", x, y)
                    if map.tiles[key] and map.tiles[key] ~= "EMPTY" then
                        tileCount = tileCount + 1
                    end
                end
            end
            print(string.format("  %s: %dx%d with %d tiles", 
                scriptName, map.width, map.height, tileCount))
        end
    end
end)

-- Phase 4: Performance Tests
print("\n=== Phase 4: Performance Tests ===")

test("Large map rendering performance", function()
    local script = MapScripts.get("terror_urban")
    assertNotNil(script, "Terror urban script should exist")
    
    local executor = MapScriptExecutor.new(script)
    local startTime = os.clock()
    local success = executor:execute()
    local executeTime = os.clock() - startTime
    
    assertTrue(success, "Large map script should execute")
    print(string.format("  Map generation time: %.3f seconds", executeTime))
    
    local map = executor:getMap()
    local renderer = HexRenderer.new(24)
    
    -- Simulate rendering all tiles
    local renderStart = os.clock()
    local renderCount = 0
    for y = 0, map.height - 1 do
        for x = 0, map.width - 1 do
            local key = string.format("%d_%d", x, y)
            if map.tiles[key] and map.tiles[key] ~= "EMPTY" then
                -- Mock render operation
                local px, py = renderer:hexToPixel(x, y)
                renderCount = renderCount + 1
            end
        end
    end
    local renderTime = os.clock() - renderStart
    
    print(string.format("  Rendered %d tiles in %.3f seconds", renderCount, renderTime))
    print(string.format("  Average: %.3f ms per tile", (renderTime / renderCount) * 1000))
end)

test("Map Editor memory usage", function()
    local initialMem = collectgarbage("count")
    
    -- Create and manipulate multiple editors
    local editors = {}
    for i = 1, 10 do
        local editor = MapEditor.new(15, 15)
        for y = 0, 14 do
            for x = 0, 14 do
                editor:setTile(x, y, "urban:floor_01")
            end
        end
        table.insert(editors, editor)
    end
    
    local afterMem = collectgarbage("count")
    local memUsed = afterMem - initialMem
    
    print(string.format("  10 editors (15×15 filled): %.2f KB", memUsed))
    assertTrue(memUsed < 5000, "Memory usage should be reasonable")
    
    -- Cleanup
    editors = nil
    collectgarbage("collect")
end)

-- Phase 5: Error Handling
print("\n=== Phase 5: Error Handling ===")

test("Handle invalid Map Tile KEY", function()
    local editor = MapEditor.new(15, 15)
    editor:setTile(0, 0, "invalid:tile_key")
    
    -- Should not crash, just store invalid key
    local tile = editor:getTile(0, 0)
    assertEquals(tile, "invalid:tile_key", "Should store invalid key")
end)

test("Handle missing Map Block gracefully", function()
    local block = MapBlockLoader.get("nonexistent_block")
    assertEquals(block, nil, "Should return nil for missing block")
end)

test("Handle missing Map Script gracefully", function()
    local script = MapScripts.get("nonexistent_script")
    assertEquals(script, nil, "Should return nil for missing script")
end)

test("Hex renderer handles empty tiles", function()
    local renderer = HexRenderer.new(24)
    local map = {["0_0"] = "EMPTY"}
    
    -- Should not crash when calculating autotile for empty
    local mask = renderer:calculateHexAutotile(map, 0, 0, "EMPTY")
    assertTrue(mask >= 0, "Should handle empty tiles")
end)

-- Phase 6: End-to-End Workflow
print("\n=== Phase 6: End-to-End Workflow ===")

test("Complete workflow: Create › Save › Load › Execute › Render", function()
    -- Step 1: Create Map Block with editor
    local editor = MapEditor.new(15, 15)
    editor:setMetadata("id", "workflow_test")
    editor:setMetadata("name", "Workflow Test")
    editor:setMetadata("group", 1)
    
    for y = 0, 14 do
        for x = 0, 14 do
            if x == 0 or x == 14 or y == 0 or y == 14 then
                editor:setTile(x, y, "urban:wall_01")
            else
                editor:setTile(x, y, "urban:floor_01")
            end
        end
    end
    
    -- Step 2: Save to TOML
    local tempDir = os.getenv("TEMP")
    local blockPath = tempDir .. "\\workflow_test_block.toml"
    assertTrue(editor:save(blockPath), "Should save Map Block")
    
    -- Step 3: Load Map Block
    MapBlockLoader.loadFile(blockPath)
    local block = MapBlockLoader.get("workflow_test")
    assertNotNil(block, "Should load Map Block")
    
    -- Step 4: Create Map Script that uses this block
    local scriptContent = [=[
[metadata]
id = "workflow_test_script"
name = "Workflow Test Script"
type = "urban_patrol"
width = 15
height = 15

[[commands]]
type = "addBlock"
block = "workflow_test"
x = 0
y = 0
]=]
    
    local scriptPath = tempDir .. "\\workflow_test_script.toml"
    local file = io.open(scriptPath, "w")
    if not file then
        error("Failed to open script file for writing")
    end
    file:write(scriptContent)
    file:close()
    
    -- Step 5: Execute Map Script
    MapScripts.loadFile(scriptPath)
    local script = MapScripts.get("workflow_test_script")
    assertNotNil(script, "Should load Map Script")
    
    local executor = MapScriptExecutor.new(script)
    assertTrue(executor:execute(), "Should execute script")
    
    -- Step 6: Render result on hex grid
    local renderer = HexRenderer.new(24)
    local finalMap = executor:getMap()
    
    local renderCount = 0
    for y = 0, finalMap.height - 1 do
        for x = 0, finalMap.width - 1 do
            local key = string.format("%d_%d", x, y)
            if finalMap.tiles[key] and finalMap.tiles[key] ~= "EMPTY" then
                local px, py = renderer:hexToPixel(x, y)
                renderCount = renderCount + 1
            end
        end
    end
    
    assertTrue(renderCount > 0, "Should render tiles")
    print(string.format("  Complete workflow rendered %d tiles", renderCount))
    
    -- Cleanup
    os.remove(blockPath)
    os.remove(scriptPath)
end)

-- Summary
print("\n=== Integration Test Summary ===")
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
    os.exit(1)
else
    print("\n? All integration tests passed!")
    os.exit(0)
end






















