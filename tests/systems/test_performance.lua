-- Performance Test Suite
-- Comprehensive benchmarks for battlescape systems
-- Run with: love engine --test performance

local LOS = require("battlescape.combat.los_system")
local Pathfinding = require("core.pathfinding")
local Battlefield = require("battlescape.logic.battlefield")
local Unit = require("battlescape.combat.unit")
local ActionSystem = require("battlescape.combat.action_system")

local PerformanceTests = {}

-- Test configuration
local CONFIG = {
    warmup_runs = 3,
    benchmark_runs = 10,
    stress_test_units = {50, 100, 200, 500},
    path_lengths = {5, 10, 20, 50},
    sight_ranges = {5, 10, 15, 20}
}

---
--- Utility Functions
---

-- Measure execution time
local function benchmark(name, fn, runs)
    -- Warmup
    for i = 1, CONFIG.warmup_runs do
        fn()
    end
    
    -- Collect garbage before test
    collectgarbage("collect")
    local memBefore = collectgarbage("count")
    
    -- Actual benchmark
    local startTime = love.timer.getTime()
    for i = 1, runs do
        fn()
    end
    local endTime = love.timer.getTime()
    
    -- Memory usage
    collectgarbage("collect")
    local memAfter = collectgarbage("count")
    
    local totalTime = (endTime - startTime) * 1000  -- ms
    local avgTime = totalTime / runs
    local memUsed = memAfter - memBefore
    
    return {
        name = name,
        total_ms = totalTime,
        avg_ms = avgTime,
        runs = runs,
        mem_kb = memUsed
    }
end

-- Print benchmark results
local function printResults(results)
    print(string.format("\n[BENCHMARK] %s", results.name))
    print(string.format("  Total Time: %.2f ms", results.total_ms))
    print(string.format("  Average:    %.2f ms", results.avg_ms))
    print(string.format("  Runs:       %d", results.runs))
    print(string.format("  Memory:     %.2f KB", results.mem_kb))
    
    -- Performance rating
    local rating = "EXCELLENT"
    if results.avg_ms > 100 then rating = "POOR"
    elseif results.avg_ms > 50 then rating = "NEEDS_WORK"
    elseif results.avg_ms > 16 then rating = "GOOD"
    end
    print(string.format("  Rating:     %s", rating))
end

---
--- Test 1: LOS Calculation Performance
---

function PerformanceTests.testLOSCalculation()
    print("\n" .. string.rep("=", 60))
    print("TEST 1: Line of Sight Calculation Performance")
    print(string.rep("=", 60))
    
    local los = LOS.new()
    local battlefield = Battlefield.new(90, 90)
    
    -- Test omnidirectional sight at various ranges
    for _, range in ipairs(CONFIG.sight_ranges) do
        local results = benchmark(
            string.format("LOS Omni-directional (range %d)", range),
            function()
                los:calculateOmniSight(battlefield, 45, 45, range)
            end,
            CONFIG.benchmark_runs
        )
        printResults(results)
        
        -- Calculate theoretical tile count
        local tileCount = range * (range + 1) * 3 + 1  -- Hex area formula
        print(string.format("  Tiles checked: ~%d", tileCount))
        print(string.format("  Per-tile cost: %.3f ms", results.avg_ms / tileCount))
    end
end

---
--- Test 2: Pathfinding Performance
---

function PerformanceTests.testPathfinding()
    print("\n" .. string.rep("=", 60))
    print("TEST 2: Pathfinding Performance")
    print(string.rep("=", 60))
    
    local pathfinder = Pathfinding.new()
    local battlefield = Battlefield.new(90, 90)
    local actionSystem = ActionSystem.new()
    
    -- Create test unit
    local unit = Unit.new("soldier", "test_team", 10, 10)
    unit.movementPoints = 100
    unit.movementPointsLeft = 100
    
    -- Test paths of varying lengths
    local destinations = {
        {x = 15, y = 10, name = "short (5 tiles)"},
        {x = 20, y = 10, name = "medium (10 tiles)"},
        {x = 30, y = 10, name = "long (20 tiles)"},
        {x = 60, y = 10, name = "very long (50 tiles)"},
    }
    
    for _, dest in ipairs(destinations) do
        local results = benchmark(
            string.format("Pathfinding - %s", dest.name),
            function()
                pathfinder:findPath(unit, 10, 10, dest.x, dest.y, battlefield, actionSystem)
            end,
            CONFIG.benchmark_runs
        )
        printResults(results)
    end
    
    -- Test pathfinding with obstacles
    print("\n--- With Obstacles ---")
    
    -- Add walls in path
    for i = 15, 25 do
        battlefield:getTile(i, 10).terrain = {blocksSight = true, moveCost = 0}
    end
    
    local results = benchmark(
        "Pathfinding - obstacle avoidance",
        function()
            pathfinder:findPath(unit, 10, 10, 30, 10, battlefield, actionSystem)
        end,
        CONFIG.benchmark_runs
    )
    printResults(results)
end

---
--- Test 3: Visibility Update (Multiple Units)
---

function PerformanceTests.testVisibilityUpdate()
    print("\n" .. string.rep("=", 60))
    print("TEST 3: Multi-Unit Visibility Update")
    print(string.rep("=", 60))
    
    local los = LOS.new()
    local battlefield = Battlefield.new(90, 90)
    
    -- Test with varying unit counts
    for _, unitCount in ipairs(CONFIG.stress_test_units) do
        -- Create units in a spread pattern
        local units = {}
        for i = 1, unitCount do
            local x = 10 + (i % 70)
            local y = 10 + math.floor(i / 70) * 10
            local unit = Unit.new("soldier", "team1", x, y)
            unit.stats = {sight = 15}
            table.insert(units, unit)
        end
        
        local results = benchmark(
            string.format("Visibility Update - %d units", unitCount),
            function()
                -- Simulate full team visibility calculation
                local allVisible = {}
                for _, unit in ipairs(units) do
                    local visible = los:calculateVisibilityForUnit(unit, battlefield, true)
                    for _, tile in ipairs(visible or {}) do
                        allVisible[string.format("%d,%d", tile.x, tile.y)] = tile
                    end
                end
            end,
            math.max(1, math.floor(CONFIG.benchmark_runs / (unitCount / 50)))  -- Fewer runs for large counts
        )
        printResults(results)
        
        -- Per-unit cost
        print(string.format("  Per-unit:   %.3f ms", results.avg_ms / unitCount))
        
        -- Check if meets 30 FPS budget (33ms)
        local fps_ok = results.avg_ms < 33
        print(string.format("  30 FPS:     %s", fps_ok and "? PASS" or "? FAIL"))
    end
end

---
--- Test 4: Battlefield Generation
---

function PerformanceTests.testBattlefieldGeneration()
    print("\n" .. string.rep("=", 60))
    print("TEST 4: Battlefield Generation")
    print(string.rep("=", 60))
    
    local sizes = {
        {w = 30, h = 30, name = "Small (30�30)"},
        {w = 60, h = 60, name = "Medium (60�60)"},
        {w = 90, h = 90, name = "Large (90�90)"},
        {w = 120, h = 120, name = "Huge (120�120)"},
    }
    
    for _, size in ipairs(sizes) do
        local results = benchmark(
            string.format("Battlefield Gen - %s", size.name),
            function()
                Battlefield.new(size.w, size.h)
            end,
            math.max(1, math.floor(CONFIG.benchmark_runs / 2))
        )
        printResults(results)
        
        local tileCount = size.w * size.h
        print(string.format("  Tiles:      %d", tileCount))
        print(string.format("  Per-tile:   %.4f ms", results.avg_ms / tileCount))
    end
end

---
--- Test 5: Coordinate Conversion Overhead
---

function PerformanceTests.testCoordinateConversion()
    print("\n" .. string.rep("=", 60))
    print("TEST 5: Coordinate Conversion Overhead")
    print(string.rep("=", 60))
    
    local HexMath = require("battlescape.battle.utils.hex_math")
    
    -- Test string concatenation vs numeric key
    local results1 = benchmark(
        "String key generation (string.format)",
        function()
            for i = 1, 1000 do
                local key = string.format("%d,%d", i % 90, math.floor(i / 90))
            end
        end,
        CONFIG.benchmark_runs
    )
    printResults(results1)
    
    local results2 = benchmark(
        "Numeric key generation (y*width+x)",
        function()
            for i = 1, 1000 do
                local key = (math.floor(i / 90)) * 90 + (i % 90)
            end
        end,
        CONFIG.benchmark_runs
    )
    printResults(results2)
    
    local speedup = results1.avg_ms / results2.avg_ms
    print(string.format("\n  Numeric keys are %.1fx faster", speedup))
    
    -- Test coordinate conversions
    local results3 = benchmark(
        "Offset to Axial conversion",
        function()
            for x = 1, 90 do
                for y = 1, 90 do
                    HexMath.offsetToAxial(x, y)
                end
            end
        end,
        1  -- Only 1 run, already doing 8100 conversions
    )
    printResults(results3)
    print(string.format("  Per conversion: %.4f ms", results3.avg_ms / 8100))
end

---
--- Test 6: Memory Allocation Patterns
---

function PerformanceTests.testMemoryAllocation()
    print("\n" .. string.rep("=", 60))
    print("TEST 6: Memory Allocation Patterns")
    print(string.rep("=", 60))
    
    collectgarbage("collect")
    local memStart = collectgarbage("count")
    
    -- Test table allocation
    local tables = {}
    for i = 1, 10000 do
        table.insert(tables, {x = i, y = i, distance = i})
    end
    
    collectgarbage("collect")
    local memAfterTables = collectgarbage("count")
    
    print(string.format("  10,000 tables: %.2f KB", memAfterTables - memStart))
    
    -- Test string allocation
    local strings = {}
    for i = 1, 10000 do
        table.insert(strings, string.format("%d,%d", i, i))
    end
    
    collectgarbage("collect")
    local memAfterStrings = collectgarbage("count")
    
    print(string.format("  10,000 strings: %.2f KB", memAfterStrings - memAfterTables))
    
    -- Test unit allocation
    local units = {}
    for i = 1, 1000 do
        table.insert(units, Unit.new("soldier", "team1", i % 90, math.floor(i / 90)))
    end
    
    collectgarbage("collect")
    local memAfterUnits = collectgarbage("count")
    
    print(string.format("  1,000 units: %.2f KB", memAfterUnits - memAfterStrings))
    print(string.format("  Per unit: %.2f KB", (memAfterUnits - memAfterStrings) / 1000))
end

---
--- Test 7: Cache Performance
---

function PerformanceTests.testCachePerformance()
    print("\n" .. string.rep("=", 60))
    print("TEST 7: Cache Hit/Miss Performance")
    print(string.rep("=", 60))
    
    local los = LOS.new()
    local battlefield = Battlefield.new(90, 90)
    
    -- Test without cache (always recalculate)
    local results1 = benchmark(
        "LOS without caching (100 calls, same position)",
        function()
            for i = 1, 100 do
                los:calculateOmniSight(battlefield, 45, 45, 15)
            end
        end,
        1
    )
    printResults(results1)
    
    -- Simulate with cache (pre-calculate once)
    local cachedResult = los:calculateOmniSight(battlefield, 45, 45, 15)
    local results2 = benchmark(
        "LOS with caching (100 calls, cached)",
        function()
            for i = 1, 100 do
                local result = cachedResult  -- Just return cached
            end
        end,
        1
    )
    printResults(results2)
    
    local speedup = results1.avg_ms / results2.avg_ms
    print(string.format("\n  Caching provides %.0fx speedup", speedup))
    print(string.format("  Savings per call: %.2f ms", (results1.avg_ms - results2.avg_ms) / 100))
end

---
--- Test 8: Stress Test (Full Battlescape Init)
---

function PerformanceTests.testFullBattlescapeInit()
    print("\n" .. string.rep("=", 60))
    print("TEST 8: Full Battlescape Initialization (Stress Test)")
    print(string.rep("=", 60))
    
    -- This test simulates the full initialization sequence
    -- but without loading the actual battlescape state
    
    local results = benchmark(
        "Full Init Simulation (90�90 map, 150 units)",
        function()
            -- 1. Create battlefield
            local battlefield = Battlefield.new(90, 90)
            
            -- 2. Create LOS system
            local los = LOS.new()
            
            -- 3. Create 150 units
            local units = {}
            for i = 1, 150 do
                local x = 10 + (i % 70)
                local y = 10 + math.floor(i / 70) * 10
                local unit = Unit.new("soldier", string.format("team%d", (i % 6) + 1), x, y)
                unit.stats = {sight = 15}
                table.insert(units, unit)
            end
            
            -- 4. Calculate initial visibility
            for _, unit in ipairs(units) do
                los:calculateVisibilityForUnit(unit, battlefield, true)
            end
        end,
        3  -- Fewer runs for stress test
    )
    printResults(results)
    
    -- Compare to target
    print(string.format("\n  Target:     < 200 ms"))
    print(string.format("  Actual:     %.2f ms", results.avg_ms))
    print(string.format("  Status:     %s", results.avg_ms < 200 and "? PASS" or "? FAIL"))
end

---
--- Run All Tests
---

function PerformanceTests.runAll()
    print("\n" .. string.rep("=", 60))
    print("PERFORMANCE TEST SUITE")
    print("Version: 1.0")
    print("Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
    print(string.rep("=", 60))
    
    local overallStart = love.timer.getTime()
    
    PerformanceTests.testLOSCalculation()
    PerformanceTests.testPathfinding()
    PerformanceTests.testVisibilityUpdate()
    PerformanceTests.testBattlefieldGeneration()
    PerformanceTests.testCoordinateConversion()
    PerformanceTests.testMemoryAllocation()
    PerformanceTests.testCachePerformance()
    PerformanceTests.testFullBattlescapeInit()
    
    local overallEnd = love.timer.getTime()
    local overallTime = (overallEnd - overallStart) * 1000
    
    print("\n" .. string.rep("=", 60))
    print("TEST SUITE COMPLETE")
    print(string.format("Total Time: %.2f ms (%.2f seconds)", overallTime, overallTime / 1000))
    print(string.rep("=", 60))
    
    -- Summary recommendations
    print("\n=== RECOMMENDATIONS ===")
    print("1. Implement LOS caching for 100x speedup")
    print("2. Use numeric keys instead of string concatenation")
    print("3. Add spatial grid for unit lookups")
    print("4. Consider shadow casting algorithm for LOS")
    print("5. Implement incremental visibility updates")
    print("\nSee: tasks/TODO/TASK-PERFORMANCE-ANALYSIS.md for details")
end

---
--- Export
---

return PerformanceTests






















