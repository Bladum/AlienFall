#!/usr/bin/env love
-- Map Integration Test
-- Tests the complete map generation pipeline with Phase 3-4 systems
-- Run with: lovec engine

print("=======================================================")
print("MAP INTEGRATION TEST - Phase 3-4 Systems")
print("Testing: MapBlockLoader v2, MapScriptExecutor, Pipeline")
print("=======================================================\n")

-- Add engine to package path
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"

-- Load required modules
print("[TEST] Loading modules...")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local MapScripts = require("battlescape.mapscripts.mapscripts")
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
local MapBlockSystem = require("battlescape.map.mapblock_system")
local MapGenerator = require("battlescape.map.map_generator")
local Tilesets = require("battlescape.data.tilesets")

print("[TEST] ? All modules loaded successfully\n")

-- Test counters
local testsRun = 0
local testsPassed = 0
local testsFailed = 0

---Test helper function
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
local function assert_not_nil(value, message)
    if value == nil then
        error(message or "Value should not be nil")
    end
end

local function assert_greater(value, threshold, message)
    if value <= threshold then
        error(message or string.format("Value %s should be > %s", tostring(value), tostring(threshold)))
    end
end

print("=======================================================")
print("PHASE 1: Load Tilesets and Map Blocks")
print("=======================================================")

test("Load Tilesets", function()
    local count = Tilesets.loadAll("mods/core/tilesets")
    print(string.format("  Loaded %d tilesets", count))
    assert_greater(count, 0, "Should load at least 1 tileset")
end)

test("Load Map Blocks", function()
    local count = MapBlockLoader.loadAll("mods/core/mapblocks")
    print(string.format("  Loaded %d Map Blocks", count))

    -- Show some stats
    local stats = MapBlockLoader.getStats()
    print(string.format("  Groups: %s", table.concat(stats.groups, ", ")))
    print(string.format("  Total blocks: %d", stats.totalBlocks))

    assert_greater(count, 0, "Should load at least 1 Map Block")
end)

test("Load Map Scripts", function()
    local count = MapScripts.loadAll("mods/core/mapscripts")
    print(string.format("  Loaded %d Map Scripts", count))

    -- List available scripts
    local scripts = MapScripts.getAll()
    print("  Available Map Scripts:")
    for id, script in pairs(scripts) do
        print(string.format("    - %s: %s", id, script.name or "Unnamed"))
    end

    assert_greater(count, 0, "Should load at least 1 Map Script")
end)

print("\n=======================================================")
print("PHASE 2: Test MapScriptExecutor")
print("=======================================================")

test("Execute urban_patrol MapScript", function()
    local script = MapScripts.get("urban_patrol")
    assert_not_nil(script, "urban_patrol MapScript should exist")

    -- Type assertion for linter
    ---@cast script MapScript

    local scriptName = script.name or "Unnamed"
    local scriptSize = script.mapSize or {width = 0, height = 0}
    local scriptCommands = script.commands or {}

    print(string.format("  MapScript: %s", scriptName))
    print(string.format("  Size: %dx%d blocks", scriptSize.width, scriptSize.height))
    print(string.format("  Commands: %d", #scriptCommands))

    local context = MapScriptExecutor.execute(script, 12345)
    assert_not_nil(context, "Execution should return context")

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Result: %.1f%% filled (%d filled, %d empty)",
        stats.fillPercentage, stats.filledCount, stats.emptyCount))

    assert_greater(stats.fillPercentage, 0, "Map should have some filled tiles")
end)

test("Execute forest_patrol MapScript", function()
    local script = MapScripts.get("forest_patrol")
    assert_not_nil(script, "forest_patrol MapScript should exist")

    -- Type assertion for linter
    ---@cast script MapScript

    print(string.format("  MapScript: %s", script.name or "Unnamed"))

    local context = MapScriptExecutor.execute(script, 54321)
    assert_not_nil(context, "Execution should return context")

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Result: %.1f%% filled", stats.fillPercentage))

    assert_greater(stats.fillPercentage, 50, "Forest should be >50% filled")
end)

test("Execute ufo_crash_scout MapScript", function()
    local script = MapScripts.get("ufo_crash_scout")
    assert_not_nil(script, "ufo_crash_scout MapScript should exist")

    -- Type assertion for linter
    ---@cast script MapScript

    print(string.format("  MapScript: %s", script.name or "Unnamed"))

    local context = MapScriptExecutor.execute(script, 99999)
    assert_not_nil(context, "Execution should return context")

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Result: %.1f%% filled", stats.fillPercentage))

    -- Check for craft and UFO spawn
    if context.craftSpawn then
        print(string.format("  Craft spawn: (%d, %d)", context.craftSpawn.x, context.craftSpawn.y))
    end
    if context.ufoObjective then
        print(string.format("  UFO objective: (%d, %d)", context.ufoObjective.x, context.ufoObjective.y))
    end

    assert_not_nil(context.craftSpawn, "Should have craft spawn point")
    assert_not_nil(context.ufoObjective, "Should have UFO objective")
end)

print("\n=======================================================")
print("PHASE 3: Test MapBlockSystem")
print("=======================================================")

test("MapBlockSystem.loadLibrary()", function()
    local count = MapBlockSystem.loadLibrary("mods/core/mapblocks")
    print(string.format("  Loaded %d blocks into library", count))
    assert_greater(count, 0, "Should load blocks")
end)

test("MapBlockSystem.generateBattlefield() with auto-select", function()
    local context = MapBlockSystem.generateBattlefield(7, 7, nil)
    assert_not_nil(context, "Should generate battlefield")

    -- Type assertion for linter
    ---@cast context ExecutionContext

    local stats = MapScriptExecutor.getStats(context)
    local width = context.width or 0
    local height = context.height or 0
    local fillPercentage = stats.fillPercentage or 0
    print(string.format("  Generated: %dx%d, %.1f%% filled",
        width, height, fillPercentage))
end)

test("MapBlockSystem.generateBattlefield() with specific script", function()
    local context = MapBlockSystem.generateBattlefield(7, 7, "urban_patrol")
    assert_not_nil(context, "Should generate battlefield with urban_patrol")

    -- Type assertion for linter
    ---@cast context ExecutionContext

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Generated: %dx%d, %.1f%% filled",
        context.width, context.height, stats.fillPercentage))
end)

print("\n=======================================================")
print("PHASE 4: Test MapGenerator")
print("=======================================================")

test("MapGenerator.generateFromMapScript() - urban_patrol", function()
    local context = MapGenerator.generateFromMapScript("urban_patrol", 42)
    assert_not_nil(context, "Should generate map")

    -- Type assertion for linter
    ---@cast context ExecutionContext

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Result: %dx%d blocks, %.1f%% filled",
        context.width, context.height, stats.fillPercentage))
end)

test("MapGenerator.generateFromMapScript() - terror_urban", function()
    local context = MapGenerator.generateFromMapScript("terror_urban", 777)
    assert_not_nil(context, "Should generate map")

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Result: %.1f%% filled", stats.fillPercentage))
end)

test("MapGenerator.generateFromMapScript() - base_defense", function()
    local context = MapGenerator.generateFromMapScript("base_defense", 1234)
    assert_not_nil(context, "Should generate map")

    local stats = MapScriptExecutor.getStats(context)
    print(string.format("  Result: %.1f%% filled", stats.fillPercentage))
end)

print("\n=======================================================")
print("PHASE 5: Performance Test")
print("=======================================================")

test("Generate 10 maps quickly", function()
    local startTime = os.clock()
    local successCount = 0

    for i = 1, 10 do
        local context = MapGenerator.generateFromMapScript("urban_patrol", i * 1000)
        if context then
            successCount = successCount + 1
        end
    end

    local elapsed = os.clock() - startTime
    local avgTime = elapsed / 10

    print(string.format("  Generated: %d/10 maps", successCount))
    print(string.format("  Total time: %.3f seconds", elapsed))
    print(string.format("  Average: %.3f seconds per map", avgTime))

    assert_greater(successCount, 8, "Should generate at least 9/10 maps")

    if avgTime < 0.1 then
        print("  ? Excellent performance (<100ms per map)")
    elseif avgTime < 0.5 then
        print("  ? Good performance (<500ms per map)")
    else
        print("  ? Slow performance (>500ms per map)")
    end
end)

print("\n=======================================================")
print("PHASE 6: Memory Test")
print("=======================================================")

test("Memory usage after 50 generations", function()
    collectgarbage("collect")
    local startMem = collectgarbage("count")

    print(string.format("  Starting memory: %.2f KB", startMem))

    -- Generate 50 maps
    for i = 1, 50 do
        local context = MapGenerator.generateFromMapScript("urban_patrol", i * 123)
        context = nil
    end

    collectgarbage("collect")
    local endMem = collectgarbage("count")
    local growth = endMem - startMem

    print(string.format("  Ending memory: %.2f KB", endMem))
    print(string.format("  Growth: %.2f KB", growth))
    print(string.format("  Per map: %.2f KB", growth / 50))

    if growth < 500 then
        print("  ? Low memory growth")
    elseif growth < 2000 then
        print("  ? Moderate memory growth")
    else
        print("  ? High memory growth (possible leak)")
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
    print("Phase 3-4 integration is COMPLETE and WORKING!")
    os.exit(0)
else
    print("\n??? SOME TESTS FAILED ???")
    print("Review failures above and fix issues.")
    os.exit(1)
end
