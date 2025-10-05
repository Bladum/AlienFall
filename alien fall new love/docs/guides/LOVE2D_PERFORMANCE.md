# Love2D Performance Optimization Guide

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Target Audience:** Developers optimizing turn-based strategy games

---

## Table of Contents

1. [Introduction](#introduction)
2. [Performance Cache System](#performance-cache-system)
3. [Object Pooling](#object-pooling)
4. [Rendering Optimization](#rendering-optimization)
5. [Memory Management](#memory-management)
6. [Hot Path Optimization](#hot-path-optimization)
7. [Profiling and Benchmarking](#profiling-and-benchmarking)
8. [Turn-Based Game Optimizations](#turn-based-game-optimizations)

---

## Introduction

This guide covers performance optimization techniques specifically for Love2D games, with focus on turn-based strategy games like Alien Fall. Performance is critical in:

- **AI turn processing**: Pathfinding, decision making, action execution
- **Rendering**: Drawing large tactical maps with many units
- **Line-of-sight calculations**: Real-time visibility updates
- **Physics/collision detection**: Environmental interactions

### Performance Goals

- **60 FPS** during player turn
- **AI turn < 5 seconds** for 10+ enemy units
- **Memory < 500 MB** for typical mission
- **Load times < 2 seconds** for tactical missions

---

## Performance Cache System

### Overview

The Performance Cache provides LRU (Least Recently Used) caching for expensive calculations in hot code paths:

1. **Pathfinding Cache**: Caches A* pathfinding results
2. **Line-of-Sight Cache**: Caches visibility calculations
3. **Detection Cache**: Caches radar detection power calculations

### Implementation

```lua
--- Performance Cache with LRU eviction and TTL
-- @class PerformanceCache
local PerformanceCache = {}
PerformanceCache.__index = PerformanceCache

function PerformanceCache.new(max_size)
    local self = setmetatable({}, PerformanceCache)
    
    self.max_size = max_size or 1000
    
    -- Separate caches for different systems
    self.path_cache = {
        entries = {},
        access_times = {},
        turn_created = {},
        size = 0,
        hits = 0,
        misses = 0
    }
    
    self.los_cache = {
        entries = {},
        access_times = {},
        turn_created = {},
        size = 0,
        hits = 0,
        misses = 0
    }
    
    self.detection_cache = {
        entries = {},
        access_times = {},
        day_created = {},
        size = 0,
        hits = 0,
        misses = 0
    }
    
    self.evictions = 0
    
    return self
end

--- Cache a pathfinding result
-- @param startX number Starting X coordinate
-- @param startY number Starting Y coordinate
-- @param goalX number Goal X coordinate
-- @param goalY number Goal Y coordinate
-- @param unitId number Unit identifier
-- @param path table The calculated path
-- @param currentTurn number Current game turn
function PerformanceCache:cachePath(startX, startY, goalX, goalY, unitId, path, currentTurn)
    local key = string.format("path|%d|%d|%d|%d|%d", startX, startY, goalX, goalY, unitId)
    
    -- Check if cache is full
    if self.path_cache.size >= self.max_size then
        self:evictLRU(self.path_cache)
    end
    
    -- Store path with metadata
    self.path_cache.entries[key] = path
    self.path_cache.access_times[key] = love.timer.getTime()
    self.path_cache.turn_created[key] = currentTurn
    self.path_cache.size = self.path_cache.size + 1
end

--- Get cached pathfinding result
-- @param startX number Starting X coordinate
-- @param startY number Starting Y coordinate
-- @param goalX number Goal X coordinate
-- @param goalY number Goal Y coordinate
-- @param unitId number Unit identifier
-- @param currentTurn number Current game turn
-- @return table|nil Cached path or nil if not found/expired
function PerformanceCache:getPath(startX, startY, goalX, goalY, unitId, currentTurn)
    local key = string.format("path|%d|%d|%d|%d|%d", startX, startY, goalX, goalY, unitId)
    
    local path = self.path_cache.entries[key]
    
    if not path then
        self.path_cache.misses = self.path_cache.misses + 1
        return nil
    end
    
    -- Check TTL (Time To Live) - paths expire after 5 turns
    local turn_created = self.path_cache.turn_created[key]
    if currentTurn - turn_created > 5 then
        -- Expired, remove from cache
        self:invalidatePath(key)
        self.path_cache.misses = self.path_cache.misses + 1
        return nil
    end
    
    -- Update access time for LRU
    self.path_cache.access_times[key] = love.timer.getTime()
    self.path_cache.hits = self.path_cache.hits + 1
    
    return path
end

--- Evict least recently used entry from cache
-- @param cache table The cache to evict from
function PerformanceCache:evictLRU(cache)
    local oldest_time = math.huge
    local oldest_key = nil
    
    -- Find least recently accessed entry
    for key, time in pairs(cache.access_times) do
        if time < oldest_time then
            oldest_time = time
            oldest_key = key
        end
    end
    
    if oldest_key then
        cache.entries[oldest_key] = nil
        cache.access_times[oldest_key] = nil
        if cache.turn_created then
            cache.turn_created[oldest_key] = nil
        end
        if cache.day_created then
            cache.day_created[oldest_key] = nil
        end
        cache.size = cache.size - 1
        self.evictions = self.evictions + 1
    end
end

--- Get cache statistics
-- @return table Statistics including hit rates, sizes, evictions
function PerformanceCache:getStatistics()
    local function calcHitRate(hits, misses)
        local total = hits + misses
        return total > 0 and (hits / total) or 0
    end
    
    return {
        path = {
            hits = self.path_cache.hits,
            misses = self.path_cache.misses,
            hitRate = calcHitRate(self.path_cache.hits, self.path_cache.misses),
            size = self.path_cache.size
        },
        los = {
            hits = self.los_cache.hits,
            misses = self.los_cache.misses,
            hitRate = calcHitRate(self.los_cache.hits, self.los_cache.misses),
            size = self.los_cache.size
        },
        detection = {
            hits = self.detection_cache.hits,
            misses = self.detection_cache.misses,
            hitRate = calcHitRate(self.detection_cache.hits, self.detection_cache.misses),
            size = self.detection_cache.size
        },
        evictions = self.evictions,
        totalSize = self.path_cache.size + self.los_cache.size + self.detection_cache.size
    }
end

--- Print cache statistics to console
function PerformanceCache:printStatistics()
    local stats = self:getStatistics()
    
    print("=== Performance Cache Statistics ===")
    print(string.format("Path Cache: %.1f%% hit rate, %d entries, %d hits, %d misses",
        stats.path.hitRate * 100, stats.path.size, stats.path.hits, stats.path.misses))
    print(string.format("LOS Cache: %.1f%% hit rate, %d entries, %d hits, %d misses",
        stats.los.hitRate * 100, stats.los.size, stats.los.hits, stats.los.misses))
    print(string.format("Detection Cache: %.1f%% hit rate, %d entries, %d hits, %d misses",
        stats.detection.hitRate * 100, stats.detection.size, stats.detection.hits, stats.detection.misses))
    print(string.format("Total: %d entries, %d evictions", stats.totalSize, stats.evictions))
end

--- Invalidate all path cache entries
function PerformanceCache:invalidatePathCache()
    self.path_cache.entries = {}
    self.path_cache.access_times = {}
    self.path_cache.turn_created = {}
    self.path_cache.size = 0
end

--- Invalidate all caches
function PerformanceCache:clearAll()
    self:invalidatePathCache()
    self:invalidateLOSCache()
    self:invalidateDetectionCache()
end

return PerformanceCache
```

### Integration Example

```lua
-- In pathfinding system
local cache = PerformanceCache.new()
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

### Cache Invalidation Rules

**When to Invalidate:**

- **Path Cache**: Map tiles change, obstacles destroyed, units moved
- **LOS Cache**: Map changes, lighting changes, smoke/fire effects
- **Detection Cache**: Radar facilities changed, daily update

```lua
-- Invalidate when map changes
function Battlefield:destroyTile(x, y)
    self:getTile(x, y).destroyed = true
    
    -- Invalidate affected caches
    self.performanceCache:invalidatePathCache()
    self.performanceCache:invalidateLOSCache()
end
```

### Expected Performance Gains

Based on typical gameplay patterns:

- **Pathfinding**: 60-80% hit rate → 40-60% faster AI turns
- **Line-of-Sight**: 70-90% hit rate → 50-70% faster visibility updates
- **Detection**: 90-95% hit rate → 80-90% faster geoscape updates

---

## Object Pooling

### Overview

Object pooling reduces garbage collection overhead by reusing objects instead of creating new ones. Critical for:

- Projectiles (created/destroyed frequently)
- Particle effects (explosions, smoke)
- UI elements (tooltips, damage numbers)

### Generic Object Pool

```lua
--- Generic Object Pool
-- @class ObjectPool
local ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool:new(factoryFunc, resetFunc, initialSize, maxSize)
    local self = setmetatable({}, ObjectPool)
    
    self.factory = factoryFunc or function() return {} end
    self.reset = resetFunc or function(obj) return obj end
    self.maxSize = maxSize or 100
    
    self.available = {}
    self.active = {}
    
    -- Statistics
    self.stats = {
        created = 0,
        acquired = 0,
        released = 0,
        reused = 0
    }
    
    -- Pre-allocate initial objects
    for i = 1, (initialSize or 10) do
        local obj = self.factory()
        table.insert(self.available, obj)
        self.stats.created = self.stats.created + 1
    end
    
    return self
end

--- Acquire an object from the pool
-- @return table An object from the pool (reused or newly created)
function ObjectPool:acquire()
    local obj
    
    if #self.available > 0 then
        -- Reuse existing object
        obj = table.remove(self.available)
        self.stats.reused = self.stats.reused + 1
    else
        -- Create new object
        obj = self.factory()
        self.stats.created = self.stats.created + 1
    end
    
    table.insert(self.active, obj)
    self.stats.acquired = self.stats.acquired + 1
    
    return obj
end

--- Release an object back to the pool
-- @param obj table The object to release
function ObjectPool:release(obj)
    -- Find and remove from active
    for i, activeObj in ipairs(self.active) do
        if activeObj == obj then
            table.remove(self.active, i)
            break
        end
    end
    
    -- Reset object state
    obj = self.reset(obj)
    
    -- Return to pool if not at max capacity
    if #self.available < self.maxSize then
        table.insert(self.available, obj)
        self.stats.released = self.stats.released + 1
    end
end

--- Get pool statistics
-- @return table Pool statistics including reuse rate
function ObjectPool:getStats()
    local reuse_rate = 0
    if self.stats.acquired > 0 then
        reuse_rate = (self.stats.reused / self.stats.acquired) * 100
    end
    
    return {
        created = self.stats.created,
        acquired = self.stats.acquired,
        released = self.stats.released,
        reused = self.stats.reused,
        reuse_rate = reuse_rate,
        available = #self.available,
        active = #self.active
    }
end

return ObjectPool
```

### Specialized Pools

```lua
--- Battle Pools - Pre-configured pools for common game objects
local Pools = {}

-- Projectile pool
Pools.projectile_pool = nil

-- Particle effect pool
Pools.effect_pool = nil

--- Initialize all pools (call once at game start)
function Pools.initialize()
    -- Projectile pool
    Pools.projectile_pool = ObjectPool:new(
        -- Factory function
        function()
            return {
                x = 0,
                y = 0,
                vx = 0,
                vy = 0,
                speed = 0,
                damage = 0,
                active = false,
                sprite = nil,
                lifetime = 0
            }
        end,
        -- Reset function
        function(obj)
            obj.x = 0
            obj.y = 0
            obj.vx = 0
            obj.vy = 0
            obj.active = false
            obj.lifetime = 0
            return obj
        end,
        20,   -- Initial size
        100   -- Max size
    )
    
    -- Particle effect pool
    Pools.effect_pool = ObjectPool:new(
        function()
            return {
                x = 0,
                y = 0,
                particles = {},
                effect_type = nil,
                active = false,
                lifetime = 0
            }
        end,
        function(obj)
            obj.x = 0
            obj.y = 0
            obj.particles = {}
            obj.active = false
            obj.lifetime = 0
            return obj
        end,
        10,
        50
    )
end

--- Create a projectile from the pool
function Pools.createProjectile(startX, startY, targetX, targetY, speed, damage, sprite)
    local projectile = Pools.projectile_pool:acquire()
    
    projectile.x = startX
    projectile.y = startY
    projectile.speed = speed
    projectile.damage = damage
    projectile.sprite = sprite
    projectile.active = true
    projectile.lifetime = 0
    
    -- Calculate velocity
    local dx = targetX - startX
    local dy = targetY - startY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > 0 then
        projectile.vx = (dx / distance) * speed
        projectile.vy = (dy / distance) * speed
    end
    
    return projectile
end

--- Release a projectile back to the pool
function Pools.releaseProjectile(projectile)
    Pools.projectile_pool:release(projectile)
end

--- Create a particle effect from the pool
function Pools.createEffect(x, y, effect_type, color, particle_count)
    local effect = Pools.effect_pool:acquire()
    
    effect.x = x
    effect.y = y
    effect.effect_type = effect_type
    effect.active = true
    effect.lifetime = 0
    
    -- Generate particles
    for i = 1, particle_count do
        table.insert(effect.particles, {
            x = 0,
            y = 0,
            vx = math.random() * 200 - 100,
            vy = math.random() * 200 - 100,
            life = math.random() * 0.5 + 0.5,
            color = color
        })
    end
    
    return effect
end

--- Release an effect back to the pool
function Pools.releaseEffect(effect)
    Pools.effect_pool:release(effect)
end

return Pools
```

### Usage Example

```lua
local Pools = require('battlescape.pools')

function love.load()
    Pools.initialize()
end

-- Create projectile
local bullet = Pools.createProjectile(
    soldier.x, soldier.y,  -- Start
    alien.x, alien.y,      -- Target
    300,                    -- Speed
    25,                     -- Damage
    bullet_sprite           -- Sprite
)

-- Update projectile
function love.update(dt)
    if bullet.active then
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        bullet.lifetime = bullet.lifetime + dt
        
        -- Check for hit or timeout
        if bullet.lifetime > 2.0 or hitTarget(bullet) then
            bullet.active = false
            Pools.releaseProjectile(bullet)  -- Return to pool
        end
    end
end
```

---

## Rendering Optimization

### Batch Drawing

Reduce draw calls by batching similar sprites:

```lua
-- Batch rendering system
local Batch = {}

function Batch.new(sprite, max_sprites)
    local self = setmetatable({}, {__index = Batch})
    
    self.sprite_batch = love.graphics.newSpriteBatch(sprite, max_sprites)
    self.sprites = {}
    
    return self
end

function Batch:add(x, y, rotation, scale_x, scale_y)
    table.insert(self.sprites, {
        x = x, y = y,
        rotation = rotation or 0,
        scale_x = scale_x or 1,
        scale_y = scale_y or 1
    })
end

function Batch:draw()
    self.sprite_batch:clear()
    
    for _, sprite in ipairs(self.sprites) do
        self.sprite_batch:add(
            sprite.x, sprite.y,
            sprite.rotation,
            sprite.scale_x, sprite.scale_y
        )
    end
    
    love.graphics.draw(self.sprite_batch)
    self.sprites = {}
end
```

### Canvas Caching

Cache static elements to reduce draw calls:

```lua
-- Cache background map to canvas
local MapRenderer = {}

function MapRenderer.new(map)
    local self = setmetatable({}, {__index = MapRenderer})
    
    -- Create canvas for static map
    self.map_canvas = love.graphics.newCanvas(map.width * TILE_SIZE, map.height * TILE_SIZE)
    self.map = map
    self.dirty = true
    
    return self
end

function MapRenderer:renderToCanvas()
    love.graphics.setCanvas(self.map_canvas)
    love.graphics.clear()
    
    -- Draw all static tiles once
    for y = 1, self.map.height do
        for x = 1, self.map.width do
            local tile = self.map:getTile(x, y)
            love.graphics.draw(tile.sprite, (x-1) * TILE_SIZE, (y-1) * TILE_SIZE)
        end
    end
    
    love.graphics.setCanvas()
    self.dirty = false
end

function MapRenderer:draw()
    -- Only re-render if map changed
    if self.dirty then
        self:renderToCanvas()
    end
    
    -- Draw cached map (single draw call!)
    love.graphics.draw(self.map_canvas)
end
```

### Culling Off-Screen Elements

Only draw what's visible:

```lua
function Renderer:isVisible(x, y, width, height, camera)
    return x + width >= camera.x and
           x <= camera.x + camera.width and
           y + height >= camera.y and
           y <= camera.y + camera.height
end

function Renderer:drawUnits(units, camera)
    local drawn = 0
    
    for _, unit in ipairs(units) do
        if self:isVisible(unit.x, unit.y, unit.width, unit.height, camera) then
            self:drawUnit(unit)
            drawn = drawn + 1
        end
    end
    
    -- Statistics for optimization
    return drawn, #units
end
```

---

## Memory Management

### Garbage Collection Control

```lua
-- Control GC during critical game phases
local MemoryManager = {}

function MemoryManager:pauseGC()
    collectgarbage("stop")
end

function MemoryManager:resumeGC()
    collectgarbage("restart")
end

function MemoryManager:manualGC()
    -- Force full collection during safe times (loading screens)
    collectgarbage("collect")
end

-- Usage during AI turn
function AIController:executeTurn()
    MemoryManager:pauseGC()  -- Prevent GC spikes during AI
    
    for _, unit in ipairs(self.units) do
        self:processUnit(unit)
    end
    
    MemoryManager:resumeGC()
    MemoryManager:manualGC()  -- Clean up after AI turn
end
```

### Memory Profiling

```lua
function MemoryManager:getMemoryUsage()
    return collectgarbage("count")  -- Returns KB
end

function MemoryManager:logMemoryUsage(label)
    local mem_kb = self:getMemoryUsage()
    local mem_mb = mem_kb / 1024
    print(string.format("%s: %.2f MB", label, mem_mb))
end

-- Track memory during game session
function love.update(dt)
    if DEBUG_MODE and love.timer.getTime() % 5 < dt then
        MemoryManager:logMemoryUsage("Current Memory")
    end
end
```

---

## Hot Path Optimization

### Micro-Optimizations for Critical Code

```lua
-- Cache frequently accessed values
local math_sqrt = math.sqrt
local math_abs = math.abs
local table_insert = table.insert

-- Pre-allocate tables
local reusable_results = {}

function calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math_sqrt(dx * dx + dy * dy)
end

-- Use local functions
local function fastCompare(a, b)
    return a < b
end
```

### Avoid Table Creation in Loops

```lua
-- BAD: Creates garbage every frame
function badUpdate(dt)
    for i, enemy in ipairs(enemies) do
        local pos = {x = enemy.x, y = enemy.y}  -- New table every iteration!
        updateEnemy(pos, dt)
    end
end

-- GOOD: Reuse values
function goodUpdate(dt)
    for i, enemy in ipairs(enemies) do
        updateEnemy(enemy.x, enemy.y, dt)  -- Pass values directly
    end
end
```

---

## Profiling and Benchmarking

### Simple Profiler

```lua
local Profiler = {}
Profiler.timings = {}

function Profiler:start(name)
    self.timings[name] = self.timings[name] or {count = 0, total = 0}
    self.timings[name].start_time = love.timer.getTime()
end

function Profiler:stop(name)
    local elapsed = love.timer.getTime() - self.timings[name].start_time
    self.timings[name].total = self.timings[name].total + elapsed
    self.timings[name].count = self.timings[name].count + 1
end

function Profiler:report()
    print("=== Performance Report ===")
    for name, data in pairs(self.timings) do
        local avg = data.total / data.count
        print(string.format("%s: %.3fms avg (%d calls, %.3fms total)",
            name, avg * 1000, data.count, data.total * 1000))
    end
end

-- Usage
Profiler:start("pathfinding")
local path = pathfinding:findPath(x1, y1, x2, y2)
Profiler:stop("pathfinding")
```

---

## Turn-Based Game Optimizations

### Deferred Updates

```lua
-- Update units incrementally across frames
local UpdateScheduler = {}

function UpdateScheduler.new()
    local self = setmetatable({}, {__index = UpdateScheduler})
    self.update_queue = {}
    self.updates_per_frame = 5
    return self
end

function UpdateScheduler:queueUpdate(unit, update_func)
    table.insert(self.update_queue, {unit = unit, func = update_func})
end

function UpdateScheduler:processQueue(dt)
    local processed = 0
    
    while #self.update_queue > 0 and processed < self.updates_per_frame do
        local task = table.remove(self.update_queue, 1)
        task.func(task.unit, dt)
        processed = processed + 1
    end
end
```

---

**Tags:** `#performance` `#optimization` `#love2d` `#caching` `#pooling`
