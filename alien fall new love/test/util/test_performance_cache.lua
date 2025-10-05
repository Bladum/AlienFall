--- Test Performance Cache
-- Unit tests for PerformanceCache optimization system
--
-- Tests cache functionality, TTL, LRU eviction, and performance

local PerformanceCache = require("utils.performance_cache")

local TestPerformanceCache = {}

---Test basic path caching
function TestPerformanceCache.test_path_cache_basic()
    local cache = PerformanceCache()
    
    -- Cache a path
    local path = {{x=1, y=1}, {x=2, y=2}, {x=3, y=3}}
    cache:cachePath(1, 1, 3, 3, 123, path, 1)
    
    -- Retrieve cached path
    local cachedPath = cache:getPath(1, 1, 3, 3, 123, 1)
    
    assert(cachedPath ~= nil, "Path should be cached")
    assert(#cachedPath == 3, "Cached path should have 3 nodes")
    assert(cachedPath[1].x == 1 and cachedPath[1].y == 1, "Path start correct")
    assert(cachedPath[3].x == 3 and cachedPath[3].y == 3, "Path end correct")
    
    print("✓ Path cache basic test passed")
    return true
end

---Test path cache TTL expiration
function TestPerformanceCache.test_path_cache_ttl()
    local cache = PerformanceCache()
    
    -- Cache a path at turn 1
    local path = {{x=1, y=1}, {x=2, y=2}}
    cache:cachePath(1, 1, 2, 2, 123, path, 1)
    
    -- Retrieve at turn 1 (should hit)
    local hit1 = cache:getPath(1, 1, 2, 2, 123, 1)
    assert(hit1 ~= nil, "Path should be cached at turn 1")
    
    -- Retrieve at turn 5 (should hit, within TTL)
    local hit2 = cache:getPath(1, 1, 2, 2, 123, 5)
    assert(hit2 ~= nil, "Path should be cached at turn 5 (within TTL)")
    
    -- Retrieve at turn 10 (should miss, expired)
    local miss = cache:getPath(1, 1, 2, 2, 123, 10)
    assert(miss == nil, "Path should be expired at turn 10")
    
    print("✓ Path cache TTL test passed")
    return true
end

---Test LOS cache basic functionality
function TestPerformanceCache.test_los_cache_basic()
    local cache = PerformanceCache()
    
    -- Cache LOS visibility
    local visibleTiles = {
        {x=1, y=1, distance=0},
        {x=2, y=1, distance=1},
        {x=1, y=2, distance=1}
    }
    cache:cacheLOS(456, 1, 1, false, visibleTiles, 1)
    
    -- Retrieve cached LOS
    local cachedLOS = cache:getLOS(456, 1, 1, false, 1)
    
    assert(cachedLOS ~= nil, "LOS should be cached")
    assert(#cachedLOS == 3, "Cached LOS should have 3 tiles")
    
    print("✓ LOS cache basic test passed")
    return true
end

---Test LOS cache with night flag
function TestPerformanceCache.test_los_cache_night()
    local cache = PerformanceCache()
    
    -- Cache day visibility
    local dayTiles = {{x=1, y=1}}
    cache:cacheLOS(456, 1, 1, false, dayTiles, 1)
    
    -- Cache night visibility (different)
    local nightTiles = {{x=1, y=1}, {x=2, y=1}}
    cache:cacheLOS(456, 1, 1, true, nightTiles, 1)
    
    -- Retrieve day (should hit)
    local dayCache = cache:getLOS(456, 1, 1, false, 1)
    assert(dayCache ~= nil and #dayCache == 1, "Day cache should exist")
    
    -- Retrieve night (should hit)
    local nightCache = cache:getLOS(456, 1, 1, true, 1)
    assert(nightCache ~= nil and #nightCache == 2, "Night cache should exist")
    
    print("✓ LOS cache night flag test passed")
    return true
end

---Test detection cache basic functionality
function TestPerformanceCache.test_detection_cache_basic()
    local cache = PerformanceCache()
    
    -- Cache detection power
    cache:cacheDetection(789, 111, 45.5, 1)
    
    -- Retrieve cached detection
    local cachedPower = cache:getDetection(789, 111, 1)
    
    assert(cachedPower ~= nil, "Detection should be cached")
    assert(cachedPower == 45.5, "Cached detection power should be 45.5")
    
    print("✓ Detection cache basic test passed")
    return true
end

---Test LRU eviction
function TestPerformanceCache.test_lru_eviction()
    local cache = PerformanceCache(10) -- Small cache
    
    -- Fill cache
    for i = 1, 10 do
        local path = {{x=i, y=i}}
        cache:cachePath(i, i, i, i, i, path, 1)
    end
    
    local stats = cache:getStatistics()
    assert(stats.path.size == 10, "Cache should have 10 entries")
    
    -- Add 11th entry (should evict LRU)
    cache:cachePath(11, 11, 11, 11, 11, {{x=11, y=11}}, 1)
    
    stats = cache:getStatistics()
    assert(stats.path.size == 10, "Cache should still have 10 entries")
    assert(stats.evictions == 1, "Should have 1 eviction")
    
    print("✓ LRU eviction test passed")
    return true
end

---Test cache statistics
function TestPerformanceCache.test_statistics()
    local cache = PerformanceCache()
    
    -- Cache some data
    cache:cachePath(1, 1, 2, 2, 1, {{x=1, y=1}}, 1)
    
    -- Hit
    local hit = cache:getPath(1, 1, 2, 2, 1, 1)
    assert(hit ~= nil, "Should hit cache")
    
    -- Miss
    local miss = cache:getPath(9, 9, 9, 9, 9, 1)
    assert(miss == nil, "Should miss cache")
    
    -- Check statistics
    local stats = cache:getStatistics()
    assert(stats.path.hits == 1, "Should have 1 hit")
    assert(stats.path.misses == 1, "Should have 1 miss")
    assert(stats.path.hitRate == 0.5, "Hit rate should be 50%")
    
    print("✓ Statistics test passed")
    return true
end

---Test cache invalidation
function TestPerformanceCache.test_invalidation()
    local cache = PerformanceCache()
    
    -- Add data to all caches
    cache:cachePath(1, 1, 2, 2, 1, {{x=1, y=1}}, 1)
    cache:cacheLOS(1, 1, 1, false, {{x=1, y=1}}, 1)
    cache:cacheDetection(1, 1, 50.0, 1)
    
    local stats = cache:getStatistics()
    assert(stats.totalSize == 3, "Should have 3 total entries")
    
    -- Invalidate path cache
    cache:invalidatePathCache()
    stats = cache:getStatistics()
    assert(stats.path.size == 0, "Path cache should be empty")
    assert(stats.totalSize == 2, "Should have 2 total entries")
    
    -- Clear all
    cache:clearAll()
    stats = cache:getStatistics()
    assert(stats.totalSize == 0, "All caches should be empty")
    
    print("✓ Invalidation test passed")
    return true
end

---Test cache hit rate improvement simulation
function TestPerformanceCache.test_hit_rate_simulation()
    local cache = PerformanceCache()
    
    -- Simulate repeated pathfinding queries (common in AI)
    local queries = {
        {1, 1, 5, 5, 100},
        {2, 2, 6, 6, 101},
        {1, 1, 5, 5, 100}, -- Repeat
        {3, 3, 7, 7, 102},
        {2, 2, 6, 6, 101}, -- Repeat
        {1, 1, 5, 5, 100}, -- Repeat
    }
    
    for _, query in ipairs(queries) do
        local cached = cache:getPath(query[1], query[2], query[3], query[4], query[5], 1)
        if not cached then
            -- Simulate expensive calculation
            local path = {{x=query[1], y=query[2]}, {x=query[3], y=query[4]}}
            cache:cachePath(query[1], query[2], query[3], query[4], query[5], path, 1)
        end
    end
    
    local stats = cache:getStatistics()
    local hitRate = stats.path.hitRate
    
    assert(hitRate >= 0.5, "Hit rate should be at least 50% with repeated queries")
    print(string.format("✓ Hit rate simulation test passed (%.1f%% hit rate)", hitRate * 100))
    
    return true
end

---Test performance benchmark
function TestPerformanceCache.test_performance_benchmark()
    local cache = PerformanceCache()
    
    -- Benchmark without cache
    local startTime = os.clock()
    for i = 1, 1000 do
        -- Simulate pathfinding calculation
        local path = {}
        for j = 1, 20 do
            table.insert(path, {x=j, y=j})
        end
    end
    local withoutCacheTime = os.clock() - startTime
    
    -- Benchmark with cache (same query repeated)
    startTime = os.clock()
    for i = 1, 1000 do
        local cached = cache:getPath(1, 1, 20, 20, 1, 1)
        if not cached then
            local path = {}
            for j = 1, 20 do
                table.insert(path, {x=j, y=j})
            end
            cache:cachePath(1, 1, 20, 20, 1, path, 1)
        end
    end
    local withCacheTime = os.clock() - startTime
    
    local improvement = ((withoutCacheTime - withCacheTime) / withoutCacheTime) * 100
    
    print(string.format("✓ Performance benchmark: %.1f%% improvement with cache", improvement))
    print(string.format("  Without cache: %.4fs, With cache: %.4fs", withoutCacheTime, withCacheTime))
    
    return true
end

---Run all tests
function TestPerformanceCache.runAll()
    print("\n=== Performance Cache Tests ===")
    
    local tests = {
        TestPerformanceCache.test_path_cache_basic,
        TestPerformanceCache.test_path_cache_ttl,
        TestPerformanceCache.test_los_cache_basic,
        TestPerformanceCache.test_los_cache_night,
        TestPerformanceCache.test_detection_cache_basic,
        TestPerformanceCache.test_lru_eviction,
        TestPerformanceCache.test_statistics,
        TestPerformanceCache.test_invalidation,
        TestPerformanceCache.test_hit_rate_simulation,
        TestPerformanceCache.test_performance_benchmark,
    }
    
    local passed = 0
    local failed = 0
    
    for i, test in ipairs(tests) do
        local success, err = pcall(test)
        if success then
            passed = passed + 1
        else
            failed = failed + 1
            print("✗ Test failed: " .. tostring(err))
        end
    end
    
    print(string.format("\n%d/%d tests passed", passed, passed + failed))
    print("===============================\n")
    
    return failed == 0
end

return TestPerformanceCache
