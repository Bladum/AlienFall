--- Performance Optimization Documentation
-- Implementation of hot-path optimizations for game performance
-- 
-- This document describes the performance caching system implemented
-- to optimize frequently executed code paths in the game.

# Performance Cache System

## Overview

The `PerformanceCache` class provides centralized LRU (Least Recently Used) caching
for expensive calculations in hot code paths:

1. **Pathfinding Cache**: Caches A* pathfinding results
2. **Line-of-Sight Cache**: Caches visibility calculations
3. **Detection Cache**: Caches radar detection power calculations

## Architecture

### Cache Structure

Each cache type maintains:
- `entries`: Key-value store of cached results
- `accessTimes`: Timestamp of last access (for LRU eviction)
- `turnCreated` or `dayCreated`: Creation time (for TTL invalidation)
- `size`: Current number of entries

### Cache Keys

Cache keys are generated from input parameters using serialization:
- Path: `"path|startX|startY|goalX|goalY|unitId"`
- LOS: `"los|unitId|unitX|unitY|isNight"`
- Detection: `"detection|missionId|radarId"`

### Time-to-Live (TTL)

Cached entries are automatically invalidated after:
- **Path Cache**: 5 turns (pathfinding)
- **LOS Cache**: 3 turns (line-of-sight)
- **Detection Cache**: 1 day (radar detection)

### LRU Eviction

When cache reaches maximum size (default: 1000 entries), the least recently
accessed entry is evicted to make room for new entries.

## Integration

### Pathfinding System

```lua
local cache = PerformanceCache()
local pathfinding = Pathfinding:new(map, cache)

-- Set current turn for TTL
pathfinding:setCurrentTurn(battleState.currentTurn)

-- Pathfinding automatically uses cache
local path = pathfinding:findPath(startX, startY, goalX, goalY, unit)

-- Invalidate cache when map changes
pathfinding:invalidateCache()

-- Get performance statistics
local stats = pathfinding:getCacheStatistics()
```

### Line-of-Sight System

```lua
local cache = PerformanceCache()
local los = LineOfSight:new(missionSeed, map, cache)

-- Set current turn for TTL
los:setCurrentTurn(battleState.currentTurn)

-- LOS automatically uses cache
local visibleTiles = los:calculateUnitVisibility(unit, maxRange, isNight, effects)

-- Invalidate cache when environment changes
los:invalidateCache()

-- Get performance statistics
local stats = los:getCacheStatistics()
```

### Detection System

```lua
local cache = PerformanceCache()
local detection = DetectionSystem.new({
    base_manager = baseManager,
    cache = cache
})

-- Set current day for TTL
detection:setCurrentDay(geoscape.currentDay)

-- Detection automatically uses cache
detection:updateDetection(missions, provinces)

-- Invalidate cache when radar facilities change
detection:invalidateCache()

-- Get performance statistics
local stats = detection:getCacheStatistics()
```

## Cache Invalidation

### When to Invalidate

Caches must be invalidated when underlying data changes:

**Path Cache**:
- Map tiles change (destruction, new obstacles)
- Unit movement capabilities change
- Environmental effects change (fire, smoke)

**LOS Cache**:
- Map tiles change
- Environmental effects change
- Unit positions change (automatic via TTL)
- Unit sight stats change

**Detection Cache**:
- Radar facilities added/removed/upgraded
- Radar power changes
- Mission/province positions change
- Daily update (automatic via TTL)

### Invalidation Methods

```lua
-- Invalidate specific cache type
cache:invalidatePathCache()
cache:invalidateLOSCache()
cache:invalidateDetectionCache()

-- Invalidate all caches
cache:clearAll()
```

## Performance Monitoring

### Cache Statistics

```lua
local stats = cache:getStatistics()
-- Returns:
-- {
--   path = {hits, misses, hitRate, size},
--   los = {hits, misses, hitRate, size},
--   detection = {hits, misses, hitRate, size},
--   evictions = total_evictions,
--   totalSize = total_entries
-- }

-- Print statistics to console
cache:printStatistics()
```

### Expected Performance Gains

Based on typical gameplay patterns:

**Pathfinding**:
- AI units often recalculate same paths
- Expected hit rate: 60-80%
- Performance improvement: 40-60% in AI turn processing

**Line-of-Sight**:
- Static units recalculate same visibility
- Expected hit rate: 70-90%
- Performance improvement: 50-70% in visibility updates

**Detection**:
- Radar calculations are deterministic for fixed positions
- Expected hit rate: 90-95%
- Performance improvement: 80-90% in daily updates

### Profiling Results

Profiling should be done before and after optimization:

```lua
-- Before optimization
local startTime = love.timer.getTime()
-- ... operation ...
local endTime = love.timer.getTime()
print("Time: " .. (endTime - startTime) .. "s")

-- After optimization (with cache)
-- Compare times and verify improvement
```

## Memory Considerations

### Memory Usage

Each cache entry stores:
- Key: ~30-50 bytes
- Value: varies by type
  - Path: ~100-500 bytes (depends on path length)
  - LOS: ~500-2000 bytes (depends on visible tiles)
  - Detection: ~8 bytes (single number)
- Metadata: ~40 bytes

### Memory Limits

Default maximum cache size: 1000 entries
Estimated maximum memory: ~2-5 MB

Can be configured during initialization:
```lua
local cache = PerformanceCache(2000)  -- 2000 entry limit
```

## Best Practices

1. **Share Cache Instance**: Use single cache instance across related systems
2. **Monitor Hit Rates**: Hit rates <50% indicate poor cache effectiveness
3. **Adjust TTL**: Tune TTL values based on game update frequency
4. **Profile Regularly**: Measure actual performance improvements
5. **Invalidate Properly**: Always invalidate cache when data changes

## Implementation Notes

### Thread Safety

The cache is NOT thread-safe. Lua/Love2D is single-threaded, so this is not
an issue for current implementation.

### Determinism

Caching does NOT affect game determinism:
- Cache hits return identical results to cache misses
- RNG state is not affected by cache operations
- Cache invalidation is deterministic

### Testing

Test cache behavior with:
1. Cache hit/miss verification
2. TTL expiration tests
3. LRU eviction tests
4. Determinism verification (seeded RNG)
5. Performance benchmarks

## Maintenance

### Adding New Cache Types

To add a new cache type:

1. Add cache structure in `PerformanceCache:initialize()`
2. Add statistics tracking
3. Implement cache/get methods with TTL checking
4. Implement invalidation method
5. Update `getStatistics()` method
6. Document usage patterns

### Monitoring Cache Health

Regularly check cache statistics:
- Low hit rates (<40%) indicate ineffective caching
- High eviction counts indicate cache too small
- Zero hits indicates cache not being used

## Future Optimizations

Potential future improvements:
1. Spatial indexing for faster neighbor queries
2. Hierarchical pathfinding for long-distance paths
3. Precomputed LOS templates for common scenarios
4. Persistent cache across game sessions
5. Adaptive cache sizing based on available memory

---

**Implementation Date**: September 30, 2025
**Performance Target**: 30%+ improvement in hot paths
**Status**: COMPLETED
