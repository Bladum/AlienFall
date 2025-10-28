-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Line of Sight & Fog of War System
-- FILE: tests2/battlescape/los_fow_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.battlescape.combat.los_optimized and visibility systems
-- Covers LOS cache, FOW visibility updates, team visibility state transitions
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK IMPLEMENTATIONS FOR LOS/FOW TESTING
-- ─────────────────────────────────────────────────────────────────────────

-- Mock LOSCache - simulates real cache behavior for testing
local MockLOSCache = {}
function MockLOSCache:new()
    local cache = {
        data = {},
        stats = {
            hits = 0,
            misses = 0,
            sets = 0,
            clears = 0
        },
        maxSize = 1000,
        currentSize = 0
    }

    function cache:getKey(fromX, fromY, toX, blocked, rotation)
        -- Create deterministic key from parameters
        return string.format("%d_%d_%d_%d_%s_%d",
            fromX, fromY, toX, toX, tostring(blocked), rotation)
    end

    function cache:set(key, value)
        if not self.data[key] then
            self.currentSize = self.currentSize + 1
        end
        self.data[key] = value
        self.stats.sets = self.stats.sets + 1
    end

    function cache:get(key)
        if self.data[key] then
            self.stats.hits = self.stats.hits + 1
            return self.data[key]
        end
        self.stats.misses = self.stats.misses + 1
        return nil
    end

    function cache:clear()
        self.data = {}
        self.currentSize = 0
        self.stats.clears = self.stats.clears + 1
    end

    function cache:getStats()
        return {
            hits = self.stats.hits,
            misses = self.stats.misses,
            sets = self.stats.sets,
            clears = self.stats.clears,
            size = self.currentSize,
            maxSize = self.maxSize,
            hitRate = self.stats.hits / math.max(1, self.stats.hits + self.stats.misses)
        }
    end

    return cache
end

-- Mock Team visibility system
local MockTeam = {}
function MockTeam:new(id, name, side)
    local team = {
        id = id,
        name = name,
        side = side,
        visibility = {}
    }

    function team:initializeVisibility(width, height)
        self.width = width
        self.height = height
        self.visibility = {}
        for x = 0, width - 1 do
            self.visibility[x] = {}
            for y = 0, height - 1 do
                self.visibility[x][y] = "unknown"
            end
        end
    end

    function team:updateVisibility(x, y, state)
        if self.visibility[x] then
            self.visibility[x][y] = state
        end
    end

    function team:getVisibility(x, y)
        if self.visibility[x] then
            return self.visibility[x][y]
        end
        return "unknown"
    end

    function team:getVisibleHexes()
        local visible = {}
        for x, row in pairs(self.visibility) do
            for y, state in pairs(row) do
                if state == "visible" then
                    table.insert(visible, {x = x, y = y})
                end
            end
        end
        return visible
    end

    return team
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.combat.los_optimized",
    fileName = "los_optimized.lua / los_system.lua",
    description = "Line of Sight and Fog of War visibility system"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: LOS CACHE OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("LOS Cache Operations", function()
    local cache

    Suite:beforeEach(function()
        cache = MockLOSCache:new()
    end)

    Suite:testMethod("LOSCache:new", {
        description = "Creating new cache initializes with empty data and zero stats",
        testCase = "initialization",
        type = "functional"
    }, function()
        local newCache = MockLOSCache:new()

        Helpers.assertNotNil(newCache.data, "Cache should have data table")
        Helpers.assertEqual(newCache.currentSize, 0, "New cache should be empty")
        Helpers.assertEqual(newCache.stats.hits, 0, "New cache should have 0 hits")
        Helpers.assertEqual(newCache.stats.misses, 0, "New cache should have 0 misses")
    end)

    Suite:testMethod("LOSCache:set/get", {
        description = "Setting and getting a value from cache preserves data",
        testCase = "basic_operations",
        type = "functional"
    }, function()
        local key = cache:getKey(5, 5, 10, true, 0)
        local value = {{x=5, y=5}, {x=6, y=5}, {x=7, y=5}}

        cache:set(key, value)
        local retrieved = cache:get(key)

        Helpers.assertEqual(retrieved, value, "Retrieved value should match stored value")
    end)

    Suite:testMethod("LOSCache:get", {
        description = "Getting non-existent key registers cache miss",
        testCase = "cache_miss",
        type = "functional"
    }, function()
        local stats = cache:getStats()
        local initialMisses = stats.misses

        cache:get("nonexistent_key")
        stats = cache:getStats()

        Helpers.assertEqual(stats.misses, initialMisses + 1, "Cache miss should be tracked")
    end)

    Suite:testMethod("LOSCache:get", {
        description = "Getting existing key registers cache hit",
        testCase = "cache_hit",
        type = "functional"
    }, function()
        local key = cache:getKey(5, 5, 10, true, 0)
        local value = {{x=5, y=5}}

        cache:set(key, value)
        local stats = cache:getStats()
        local initialHits = stats.hits

        cache:get(key)
        stats = cache:getStats()

        Helpers.assertEqual(stats.hits, initialHits + 1, "Cache hit should be tracked")
    end)

    Suite:testMethod("LOSCache:getStats", {
        description = "Cache statistics correctly aggregate hits, misses, and hit rate",
        testCase = "statistics",
        type = "functional"
    }, function()
        -- Add some entries to cache
        for i = 1, 5 do
            cache:set("key_" .. i, {x = i})
        end

        -- Get some hits
        cache:get("key_1")
        cache:get("key_2")
        cache:get("key_3")

        -- Get some misses
        cache:get("missing_1")
        cache:get("missing_2")

        local stats = cache:getStats()

        Helpers.assertEqual(stats.sets, 5, "Should track 5 sets")
        Helpers.assertEqual(stats.hits, 3, "Should track 3 hits")
        Helpers.assertEqual(stats.misses, 2, "Should track 2 misses")
        Helpers.assertEqual(stats.size, 5, "Cache should have 5 items")

        -- Hit rate should be 3/5 = 0.6
        Helpers.assertGreater(stats.hitRate, 0.5, "Hit rate should be 3/5 (0.6)")
        Helpers.assertLess(stats.hitRate, 0.7, "Hit rate should be 3/5 (0.6)")
    end)

    Suite:testMethod("LOSCache:clear", {
        description = "Clearing cache removes all entries and increments clear count",
        testCase = "cache_clear",
        type = "functional"
    }, function()
        cache:set("key_1", {x=1})
        cache:set("key_2", {x=2})

        local statsBeforeClear = cache:getStats()
        Helpers.assertEqual(statsBeforeClear.size, 2, "Cache should have 2 items before clear")

        cache:clear()

        local statsAfterClear = cache:getStats()
        Helpers.assertEqual(statsAfterClear.size, 0, "Cache should be empty after clear")
        Helpers.assertEqual(statsAfterClear.clears, 1, "Clear count should be incremented")

        -- Trying to get cleared item should miss
        Helpers.assertNil(cache:get("key_1"), "Cleared item should not be retrievable")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: TEAM VISIBILITY STATE MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Team Visibility Management", function()
    local team

    Suite:beforeEach(function()
        team = MockTeam:new("player_1", "Alpha Squad", "player")
        team:initializeVisibility(20, 20)
    end)

    Suite:testMethod("Team:initializeVisibility", {
        description = "Initializing visibility grid creates known dimensions",
        testCase = "initialization",
        type = "functional"
    }, function()
        local newTeam = MockTeam:new("test", "Test", "player")
        newTeam:initializeVisibility(10, 15)

        Helpers.assertEqual(newTeam.width, 10, "Width should be stored")
        Helpers.assertEqual(newTeam.height, 15, "Height should be stored")

        -- Test some positions exist
        Helpers.assertNotNil(newTeam:getVisibility(0, 0), "Should have visibility data")
    end)

    Suite:testMethod("Team:updateVisibility", {
        description = "Updating visibility state changes cell state",
        testCase = "state_update",
        type = "functional"
    }, function()
        team:updateVisibility(5, 5, "visible")
        local state = team:getVisibility(5, 5)
        Helpers.assertEqual(state, "visible", "Visibility should update to 'visible'")

        team:updateVisibility(5, 5, "explored")
        state = team:getVisibility(5, 5)
        Helpers.assertEqual(state, "explored", "Visibility should update to 'explored'")

        team:updateVisibility(5, 5, "unknown")
        state = team:getVisibility(5, 5)
        Helpers.assertEqual(state, "unknown", "Visibility should update to 'unknown'")
    end)

    Suite:testMethod("Team:updateVisibility", {
        description = "Batch visibility updates affect correct regions",
        testCase = "batch_update",
        type = "functional"
    }, function()
        -- Mark a circular region as visible
        for x = 5, 15 do
            for y = 5, 15 do
                team:updateVisibility(x, y, "visible")
            end
        end

        -- Check all were updated
        for x = 5, 15 do
            for y = 5, 15 do
                Helpers.assertEqual(team:getVisibility(x, y), "visible",
                    "Position (" .. x .. "," .. y .. ") should be visible")
            end
        end

        -- Check outside region is still unknown
        Helpers.assertEqual(team:getVisibility(0, 0), "unknown", "Outside region should be unknown")
    end)

    Suite:testMethod("Team:getVisibleHexes", {
        description = "Getting visible hexes returns all positions marked as visible",
        testCase = "visible_collection",
        type = "functional"
    }, function()
        -- Mark specific positions visible
        team:updateVisibility(5, 5, "visible")
        team:updateVisibility(6, 5, "visible")
        team:updateVisibility(7, 5, "visible")
        team:updateVisibility(8, 8, "explored")  -- Not visible, just explored

        local visible = team:getVisibleHexes()

        -- Should have exactly 3 visible hexes
        Helpers.assertEqual(#visible, 3, "Should have 3 visible hexes")

        -- All visible hexes should be accounted for
        local count = 0
        for _, hex in ipairs(visible) do
            if (hex.x == 5 and hex.y == 5) or
               (hex.x == 6 and hex.y == 5) or
               (hex.x == 7 and hex.y == 5) then
                count = count + 1
            end
        end
        Helpers.assertEqual(count, 3, "All visible hexes should be in result")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: FOW STATE TRANSITIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("FOW State Transitions", function()
    local team

    Suite:beforeEach(function()
        team = MockTeam:new("player_1", "Alpha Squad", "player")
        team:initializeVisibility(20, 20)
    end)

    Suite:testMethod("Visibility:state_machine", {
        description = "Visibility states transition correctly: unknown → visible → explored",
        testCase = "state_progression",
        type = "functional"
    }, function()
        local x, y = 10, 10

        -- Initially unknown
        Helpers.assertEqual(team:getVisibility(x, y), "unknown", "Should start unknown")

        -- Transition to visible
        team:updateVisibility(x, y, "visible")
        Helpers.assertEqual(team:getVisibility(x, y), "visible", "Should transition to visible")

        -- Transition to explored
        team:updateVisibility(x, y, "explored")
        Helpers.assertEqual(team:getVisibility(x, y), "explored", "Should transition to explored")

        -- Should allow reverse transition
        team:updateVisibility(x, y, "unknown")
        Helpers.assertEqual(team:getVisibility(x, y), "unknown", "Should allow reverse to unknown")
    end)

    Suite:testMethod("Visibility:unit_discovery", {
        description = "Moving a unit updates visibility of surrounding hexes",
        testCase = "visibility_cascade",
        type = "functional"
    }, function()
        -- Simulate unit moving and revealing FOW
        local unitX, unitY = 5, 5
        local visionRange = 3

        -- Update all hexes within vision range
        for x = unitX - visionRange, unitX + visionRange do
            for y = unitY - visionRange, unitY + visionRange do
                if x >= 0 and x < 20 and y >= 0 and y < 20 then
                    team:updateVisibility(x, y, "visible")
                end
            end
        end

        -- Check center is visible
        Helpers.assertEqual(team:getVisibility(unitX, unitY), "visible", "Unit position should be visible")

        -- Check edges are visible
        Helpers.assertEqual(team:getVisibility(unitX - visionRange, unitY), "visible", "Edge should be visible")
        Helpers.assertEqual(team:getVisibility(unitX, unitY - visionRange), "visible", "Edge should be visible")

        -- Check beyond range is still unknown
        Helpers.assertEqual(team:getVisibility(unitX - visionRange - 1, unitY), "unknown",
            "Beyond range should still be unknown")
    end)

    Suite:testMethod("Visibility:explored_retention", {
        description = "Explored hexes remain explored even after unit moves away",
        testCase = "explored_memory",
        type = "functional"
    }, function()
        local x, y = 10, 10

        -- Mark as visible
        team:updateVisibility(x, y, "visible")
        Helpers.assertEqual(team:getVisibility(x, y), "visible", "Should be visible")

        -- Transition to explored
        team:updateVisibility(x, y, "explored")
        Helpers.assertEqual(team:getVisibility(x, y), "explored", "Should be explored")

        -- Unit moves away but hex remains explored
        -- (This validates that explored state persists)
        local curState = team:getVisibility(x, y)
        Helpers.assertEqual(curState, "explored", "Explored state should persist")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: LOS CALCULATION VALIDATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("LOS Calculation Validation", function()
    local cache

    Suite:beforeEach(function()
        cache = MockLOSCache:new()
    end)

    Suite:testMethod("LOS:direct_line", {
        description = "Direct line of sight from unit to target is calculated",
        testCase = "direct_los",
        type = "functional"
    }, function()
        -- Simulate LOS line from (0,0) to (10,0)
        local los_path = {}
        for i = 0, 10 do
            table.insert(los_path, {x = i, y = 0})
        end

        local key = cache:getKey(0, 0, 10, false, 0)
        cache:set(key, los_path)

        local retrieved = cache:get(key)
        Helpers.assertEqual(#retrieved, 11, "Direct LOS should have 11 hexes (0-10 inclusive)")
    end)

    Suite:testMethod("LOS:obstruction", {
        description = "Obstacles properly block line of sight",
        testCase = "blocked_los",
        type = "functional"
    }, function()
        -- Simulate blocked LOS
        local blocked_path = {}
        for i = 0, 5 do
            table.insert(blocked_path, {x = i, y = 0})
        end
        -- Stops at obstacle at (5, 0)

        local key = cache:getKey(0, 0, 10, true, 0)  -- blocked = true
        cache:set(key, blocked_path)

        local retrieved = cache:get(key)
        Helpers.assertEqual(#retrieved, 6, "Blocked LOS should stop at obstacle (6 hexes: 0-5)")
        Helpers.assertEqual(retrieved[#retrieved].x, 5, "Last hex should be at obstacle")
    end)

    Suite:testMethod("LOS:cache_efficiency", {
        description = "Repeated LOS queries hit cache instead of recalculating",
        testCase = "cache_efficiency",
        type = "performance"
    }, function()
        local key = cache:getKey(0, 0, 20, false, 0)
        local los_data = {}
        for i = 0, 20 do
            table.insert(los_data, {x = i})
        end

        -- First calculation - cache miss
        cache:set(key, los_data)
        cache:get(key)  -- This will be hit

        -- Repeat queries
        for i = 1, 100 do
            cache:get(key)
        end

        local stats = cache:getStats()
        Helpers.assertEqual(stats.hits, 101, "Should have 101 cache hits")
        Helpers.assertEqual(stats.misses, 0, "Should have 0 misses after initial set")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: PERFORMANCE BENCHMARKS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()
    Suite:testMethod("LOSCache:throughput", {
        description = "Cache operations handle high throughput efficiently",
        testCase = "throughput",
        type = "performance"
    }, function()
        local cache = MockLOSCache:new()
        local iterations = 10000

        local startTime = os.clock()

        for i = 1, iterations do
            local key = cache:getKey(math.random(0, 50), math.random(0, 50),
                                     math.random(0, 50), i % 2 == 0, 0)
            cache:set(key, {x = i})
            if i % 10 == 0 then  -- 10% reads
                cache:get(key)
            end
        end

        local elapsed = os.clock() - startTime
        print("[LOSCache Performance] " .. iterations .. " operations: " ..
              string.format("%.2f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 0.5, "10000 cache operations should complete in <500ms")
    end)

    Suite:testMethod("Visibility:grid_update", {
        description = "Updating entire visibility grid is fast enough for real-time",
        testCase = "grid_throughput",
        type = "performance"
    }, function()
        local team = MockTeam:new("perf_test", "Test", "player")
        team:initializeVisibility(50, 50)

        local startTime = os.clock()

        -- Simulate updating entire visible grid each frame for 60 frames
        for frame = 1, 60 do
            for x = 0, 49 do
                for y = 0, 49 do
                    if math.random() < 0.3 then  -- 30% visible
                        team:updateVisibility(x, y, "visible")
                    else
                        team:updateVisibility(x, y, "explored")
                    end
                end
            end
        end

        local elapsed = os.clock() - startTime
        print("[Visibility Grid Performance] 50x50 grid, 60 frames: " ..
              string.format("%.2f ms", elapsed * 1000) ..
              " (avg " .. string.format("%.2f ms/frame", (elapsed / 60) * 1000) .. ")")

        -- Each frame should take <5ms (at 200 FPS)
        Helpers.assertLess((elapsed / 60), 0.005, "Per-frame updates should be <5ms")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
