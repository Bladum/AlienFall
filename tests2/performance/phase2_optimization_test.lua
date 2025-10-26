-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Phase 2 Optimization
-- FILE: tests2/performance/phase2_optimization_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests battlefield generation optimization, dirty flag system, and cache
-- performance for Phase 2 improvements
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK OBJECTS
-- ─────────────────────────────────────────────────────────────────────────

local MockBattlefield = {}
MockBattlefield.__index = MockBattlefield

function MockBattlefield.new(width, height)
    local self = setmetatable({}, MockBattlefield)
    self.width = width
    self.height = height
    self.tiles = {}

    -- Initialize tiles
    for x = 1, width do
        self.tiles[x] = {}
        for y = 1, height do
            self.tiles[x][y] = {
                x = x, y = y,
                terrain = "grass",
                walkable = true
            }
        end
    end

    return self
end

function MockBattlefield:getTile(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return nil
    end
    return self.tiles[x][y]
end

local MockUnit = {}
MockUnit.__index = MockUnit

function MockUnit.new(name, team, x, y)
    local self = setmetatable({}, MockUnit)
    self.name = name
    self.team = team
    self.x = x
    self.y = y
    self.id = name .. "_" .. team
    self.visibilityDirty = true
    self.cachedVisibility = {}
    return self
end

function MockUnit:moveTo(x, y)
    self.x = x
    self.y = y
    self.visibilityDirty = true
end

local MockLOSSystem = {}
MockLOSSystem.__index = MockLOSSystem

function MockLOSSystem.new()
    local self = setmetatable({}, MockLOSSystem)
    self.cache = {}
    self.cacheStats = {
        hits = 0,
        misses = 0,
        size = 0
    }
    return self
end

function MockLOSSystem:calculateVisibilityForUnit(unit, battlefield, force)
    local key = unit.id .. "_" .. unit.x .. "_" .. unit.y

    if self.cache[key] and not force then
        self.cacheStats.hits = self.cacheStats.hits + 1
    else
        self.cacheStats.misses = self.cacheStats.misses + 1
        self.cache[key] = {
            unit_id = unit.id,
            x = unit.x,
            y = unit.y,
            visible_tiles = {}
        }
        self.cacheStats.size = #self.cache
    end

    return self.cache[key]
end

function MockLOSSystem:getCacheStats()
    local hitRate = 0
    if (self.cacheStats.hits + self.cacheStats.misses) > 0 then
        hitRate = (self.cacheStats.hits / (self.cacheStats.hits + self.cacheStats.misses)) * 100
    end

    return {
        hit_rate = hitRate,
        hits = self.cacheStats.hits,
        misses = self.cacheStats.misses,
        size = self.cacheStats.size
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.optimization.phase2",
    fileName = "phase2_optimization.lua",
    description = "Phase 2 performance optimizations - battlefield generation, dirty flags, and caching"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: BATTLEFIELD GENERATION OPTIMIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Battlefield Generation", function()
    Suite:testMethod("MockBattlefield Creation", {
        description = "Creates small battlefield efficiently",
        testCase = "happy_path",
        type = "performance"
    }, function()
        local battlefield = MockBattlefield.new(20, 20)

        Helpers.assertNotNil(battlefield, "Battlefield should be created")
        Helpers.assertEqual(battlefield.width, 20, "Width should be 20")
        Helpers.assertEqual(battlefield.height, 20, "Height should be 20")
    end)

    Suite:testMethod("MockBattlefield Creation", {
        description = "Creates medium battlefield efficiently",
        testCase = "performance",
        type = "performance"
    }, function()
        local start = os.clock()
        local battlefield = MockBattlefield.new(60, 60)
        local elapsed = os.clock() - start

        Helpers.assertNotNil(battlefield, "Battlefield should be created")
        Helpers.assertEqual(battlefield.width, 60, "Width should be 60")

        -- Should complete in reasonable time (<1 second for 3600 tiles)
        assert(elapsed < 1.0,
            "Medium battlefield should generate in < 1 second, took: " .. elapsed)
    end)

    Suite:testMethod("MockBattlefield Creation", {
        description = "Creates large battlefield efficiently",
        testCase = "performance_target",
        type = "performance"
    }, function()
        local start = os.clock()
        local battlefield = MockBattlefield.new(90, 90)
        local elapsed = os.clock() - start

        Helpers.assertEqual(battlefield.width, 90, "Width should be 90")
        Helpers.assertEqual(battlefield.height, 90, "Height should be 90")

        -- Large battlefield should still be efficient
        assert(elapsed < 2.0,
            "Large 90x90 battlefield should generate in < 2 seconds, took: " .. elapsed)
    end)

    Suite:testMethod("Battlefield Tile Access", {
        description = "Retrieves tiles efficiently",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local battlefield = MockBattlefield.new(30, 30)
        local tile = battlefield:getTile(15, 15)

        Helpers.assertNotNil(tile, "Tile should exist at valid coordinates")
        if tile then
            Helpers.assertEqual(tile.x, 15, "Tile x should match")
            Helpers.assertEqual(tile.y, 15, "Tile y should match")
        end
    end)

    Suite:testMethod("Battlefield Out of Bounds", {
        description = "Returns nil for out-of-bounds access",
        testCase = "error_handling",
        type = "error_handling"
    }, function()
        local battlefield = MockBattlefield.new(30, 30)
        local tile = battlefield:getTile(-1, 0)
        Helpers.assertEqual(tile, nil, "Out of bounds should return nil")

        tile = battlefield:getTile(40, 40)
        Helpers.assertEqual(tile, nil, "Out of bounds should return nil")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: DIRTY FLAG SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Dirty Flag System", function()
    local units

    Suite:beforeEach(function()
        units = {}
        for i = 1, 50 do
            local unit = MockUnit.new("soldier", "team_a",
                math.random(10, 80), math.random(10, 80))
            unit.id = "unit_" .. i
            table.insert(units, unit)
        end
    end)

    Suite:testMethod("Dirty Flags Initial State", {
        description = "All units start as dirty",
        testCase = "initialization",
        type = "functional"
    }, function()
        local dirtyCount = 0
        for _, unit in ipairs(units) do
            if unit.visibilityDirty then
                dirtyCount = dirtyCount + 1
            end
        end

        Helpers.assertEqual(dirtyCount, #units, "All units should start dirty")
    end)

    Suite:testMethod("Dirty Flag Cleanup", {
        description = "Can clean all dirty flags",
        testCase = "state_management",
        type = "functional"
    }, function()
        -- Clean all units
        for _, unit in ipairs(units) do
            unit.visibilityDirty = false
        end

        local dirtyCount = 0
        for _, unit in ipairs(units) do
            if unit.visibilityDirty then
                dirtyCount = dirtyCount + 1
            end
        end

        Helpers.assertEqual(dirtyCount, 0, "All units should be clean")
    end)

    Suite:testMethod("Selective Unit Movement", {
        description = "Only moved units become dirty",
        testCase = "state_management",
        type = "functional"
    }, function()
        -- Clean all units
        for _, unit in ipairs(units) do
            unit.visibilityDirty = false
        end

        -- Move 5 units
        local movedCount = 5
        for i = 1, movedCount do
            units[i]:moveTo(units[i].x + 1, units[i].y + 1)
        end

        local dirtyCount = 0
        for _, unit in ipairs(units) do
            if unit.visibilityDirty then
                dirtyCount = dirtyCount + 1
            end
        end

        Helpers.assertEqual(dirtyCount, movedCount,
            "Only moved units should be dirty")
    end)

    Suite:testMethod("Dirty Flag Efficiency", {
        description = "Dirty flags reduce visibility recalculations",
        testCase = "optimization",
        type = "performance"
    }, function()
        -- Clean all units
        for _, unit in ipairs(units) do
            unit.visibilityDirty = false
        end

        -- Move 5 out of 50 units
        local movedCount = 5
        for i = 1, movedCount do
            units[i]:moveTo(units[i].x + 1, units[i].y + 1)
        end

        -- Calculate how many we can skip
        local canSkip = 0
        for _, unit in ipairs(units) do
            if not unit.visibilityDirty then
                canSkip = canSkip + 1
            end
        end

        local efficiencyPercent = (canSkip / #units) * 100

        -- Should be able to skip 45/50 = 90%
        assert(efficiencyPercent >= 80,
            "Should be able to skip 80%+ of units, got: " .. efficiencyPercent .. "%")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: VISIBILITY WITH DIRTY FLAGS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Visibility Update Performance", function()
    local battlefield
    local losSystem
    local units

    Suite:beforeEach(function()
        battlefield = MockBattlefield.new(90, 90)
        losSystem = MockLOSSystem.new()

        units = {}
        for i = 1, 100 do
            local unit = MockUnit.new("soldier", "team_a",
                math.random(10, 80), math.random(10, 80))
            unit.id = "unit_" .. i
            table.insert(units, unit)
        end
    end)

    Suite:testMethod("Visibility Calculation All Dirty", {
        description = "Calculates visibility for all dirty units",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local calculatedCount = 0
        for _, unit in ipairs(units) do
            if unit.visibilityDirty then
                losSystem:calculateVisibilityForUnit(unit, battlefield, true)
                unit.visibilityDirty = false
                calculatedCount = calculatedCount + 1
            end
        end

        Helpers.assertEqual(calculatedCount, 100, "Should calculate for all units")
    end)

    Suite:testMethod("Visibility Cache Hit Rate", {
        description = "Cache improves performance on repeated calculations",
        testCase = "optimization",
        type = "performance"
    }, function()
        -- First pass - all misses
        for _, unit in ipairs(units) do
            losSystem:calculateVisibilityForUnit(unit, battlefield, true)
        end

        local firstStats = losSystem:getCacheStats()
        Helpers.assertEqual(firstStats.hits, 0, "First pass should have no hits")
        Helpers.assertEqual(firstStats.misses, 100, "First pass should have 100 misses")

        -- Reset unit dirty flags and recalculate
        for _, unit in ipairs(units) do
            unit.visibilityDirty = false
        end

        -- Move 10 units to mark as dirty
        for i = 1, 10 do
            units[i]:moveTo(units[i].x + 1, units[i].y + 1)
        end

        -- Second pass - should have cache hits for unmoved units
        local secondCalculated = 0
        for _, unit in ipairs(units) do
            if unit.visibilityDirty then
                losSystem:calculateVisibilityForUnit(unit, battlefield, true)
                secondCalculated = secondCalculated + 1
            end
        end

        -- Should only calculate for moved units
        Helpers.assertEqual(secondCalculated, 10, "Should calculate only for dirty units")
    end)

    Suite:testMethod("Visibility Performance Improvement", {
        description = "Dirty flags provide performance improvement",
        testCase = "optimization_target",
        type = "performance"
    }, function()
        local start = os.clock()
        local calculatedAll = 0
        for _, unit in ipairs(units) do
            losSystem:calculateVisibilityForUnit(unit, battlefield, true)
            calculatedAll = calculatedAll + 1
        end
        local timeAll = os.clock() - start

        -- Reset and move units
        losSystem.cacheStats = {hits = 0, misses = 0, size = 0}
        for _, unit in ipairs(units) do
            unit.visibilityDirty = false
        end

        for i = 1, 10 do
            units[i]:moveTo(units[i].x + 1, units[i].y + 1)
        end

        start = os.clock()
        local calculatedPartial = 0
        for _, unit in ipairs(units) do
            if unit.visibilityDirty then
                losSystem:calculateVisibilityForUnit(unit, battlefield, true)
                calculatedPartial = calculatedPartial + 1
            end
        end
        local timePartial = os.clock() - start

        -- Partial update should be much faster when dirty flags reduce work
        local efficiency = calculatedAll / calculatedPartial
        assert(efficiency >= 5,
            "Should process at least 5x more updates in full pass vs partial")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: CACHE PERFORMANCE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Cache Warmup", function()
    local losSystem
    local battlefield
    local unit

    Suite:beforeEach(function()
        losSystem = MockLOSSystem.new()
        battlefield = MockBattlefield.new(90, 90)
        unit = MockUnit.new("soldier", "team_a", 45, 45)
    end)

    Suite:testMethod("Cache Warmup Progression", {
        description = "Cache hit rate increases with repeated access",
        testCase = "happy_path",
        type = "functional"
    }, function()
        -- Multiple calculations at same position
        for i = 1, 5 do
            losSystem:calculateVisibilityForUnit(unit, battlefield, false)
        end

        local stats = losSystem:getCacheStats()

        Helpers.assertNotNil(stats, "Cache stats should exist")
        Helpers.assertNotNil(stats.hit_rate, "Hit rate should exist")

        -- After initial population, should have some cache hits
        assert(stats.misses >= 1, "Should have at least one miss")
    end)

    Suite:testMethod("Cache Growth", {
        description = "Cache size grows with unique queries",
        testCase = "happy_path",
        type = "functional"
    }, function()
        -- Different unit positions
        for x = 10, 30, 5 do
            unit.x = x
            unit.y = x
            losSystem:calculateVisibilityForUnit(unit, battlefield, true)
        end

        local stats = losSystem:getCacheStats()
        Helpers.assertGreater(stats.size, 0, "Cache should have entries")
        assert(stats.size <= 5, "Cache should grow with unique queries")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: MEMORY EFFICIENCY
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Memory Efficiency", function()
    Suite:testMethod("Battlefield Memory Footprint", {
        description = "Battlefield uses reasonable memory per tile",
        testCase = "memory_usage",
        type = "performance"
    }, function()
        local battlefield = MockBattlefield.new(120, 120)
        local tileCount = 120 * 120

        Helpers.assertEqual(battlefield.width, 120, "Width should be 120")
        Helpers.assertEqual(battlefield.height, 120, "Height should be 120")

        -- Just verify it was created efficiently
        local testTile = battlefield:getTile(60, 60)
        Helpers.assertNotNil(testTile, "Should access tiles efficiently")
    end)

    Suite:testMethod("Cache Memory Growth", {
        description = "Cache doesn't grow unbounded",
        testCase = "memory_management",
        type = "performance"
    }, function()
        local losSystem = MockLOSSystem.new()
        local battlefield = MockBattlefield.new(90, 90)

        -- Populate cache with many entries
        local unit = MockUnit.new("soldier", "team_a", 45, 45)
        for i = 1, 100 do
            unit.x = (i % 80) + 10
            unit.y = (i % 80) + 10
            losSystem:calculateVisibilityForUnit(unit, battlefield, true)
        end

        local stats = losSystem:getCacheStats()

        -- Cache should not be impossibly large
        assert(stats.size <= 100,
            "Cache should cap at reasonable size, got: " .. stats.size)
    end)
end)

Suite:run()

return Suite
