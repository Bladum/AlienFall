# AlienFall Performance Guide

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Guidelines for profiling, optimizing, and maintaining AlienFall's performance.

---

## Overview

**Targets**:
- **Frame Rate**: 60 FPS (16ms per frame)
- **Memory**: <200 MB during gameplay
- **Load Time**: <5 seconds for battle maps
- **Turn Time**: <1 second for unit turn processing

**Profiling Tools**:
- Love2D timer API (`love.timer`)
- Memory usage tracking (`collectgarbage`)
- Custom profiler (see examples)

---

## Profiling

### Simple Frame Rate Monitor

```lua
local fps_counter = 0
local fps_timer = 0
local current_fps = 0

function love.update(dt)
    fps_timer = fps_timer + dt
    fps_counter = fps_counter + 1
    
    if fps_timer >= 1 then
        current_fps = fps_counter
        fps_counter = 0
        fps_timer = 0
        
        if current_fps < 50 then
            print(string.format("[PERF] WARNING: Low FPS: %d", current_fps))
        end
    end
end

function love.draw()
    -- Draw FPS
    love.graphics.print("FPS: " .. current_fps, 10, 10)
end
```

### Measure Specific Operations

```lua
function profileOperation(name, func)
    local start = love.timer.getTime()
    local result = func()
    local elapsed = (love.timer.getTime() - start) * 1000
    
    if elapsed > 1 then  -- Print if over 1ms
        print(string.format("[PERF] %s: %.2f ms", name, elapsed))
    end
    
    return result
end

-- Usage
profileOperation("pathfinding", function()
    return calculatePath(unit, destination)
end)
```

### Memory Profiling

```lua
function printMemory()
    local mem = collectgarbage("count")
    print(string.format("[MEM] Current usage: %.2f KB", mem))
end

function love.update(dt)
    -- Print memory every second
    if frameCount % 60 == 0 then
        printMemory()
    end
end
```

---

## Common Bottlenecks

### 1. Pathfinding

**Problem**: Calculating paths for many units each turn

**Optimization**:
- Pre-calculate paths only when needed
- Cache paths between turns
- Use A* instead of breadth-first search
- Limit search depth for distant goals

```lua
-- Cache paths
local pathCache = {}

function getPath(unit, dest)
    local cacheKey = unit.id .. ":" .. dest.id
    
    if pathCache[cacheKey] then
        return pathCache[cacheKey]
    end
    
    local path = calculatePath(unit, dest)
    pathCache[cacheKey] = path
    
    return path
end
```

### 2. Line-of-Sight Calculations

**Problem**: Checking visibility for many units

**Optimization**:
- Precalculate at start of turn
- Cache visibility for stable situations
- Use simplified checks for distant units
- Limit to units in viewport

```lua
-- Precalculate visibility once per turn
function updateVisibility()
    visibilityCache = {}
    
    for _, unit in ipairs(visibleUnits) do
        visibilityCache[unit.id] = calculateVisibleUnits(unit)
    end
end

-- Use cache during turn
function canSee(unit, target)
    local visible = visibilityCache[unit.id]
    return visible and visible[target.id] or false
end
```

### 3. Rendering

**Problem**: Drawing too many objects each frame

**Optimization**:
- Use batch rendering
- Draw only visible objects (frustum culling)
- Combine similar objects into atlases
- Reduce draw call count

```lua
-- Batch similar draws
function love.draw()
    -- Draw all units together
    love.graphics.setColor(1, 1, 1)
    for _, unit in ipairs(units) do
        if isVisible(unit) then
            love.graphics.draw(unit.sprite, unit.x, unit.y)
        end
    end
    
    -- Draw all effects together
    love.graphics.setColor(1, 0.5, 0.5)
    for _, effect in ipairs(effects) do
        love.graphics.circle("fill", effect.x, effect.y, effect.radius)
    end
end
```

### 4. Loop Iterations

**Problem**: Processing too many items in tight loops

**Optimization**:
- Break early when possible
- Use indexed loops (`for i=1,n`) instead of pairs
- Pre-calculate loop counts
- Remove inactive items

```lua
-- Good: Indexed loop, pre-calculated length
local count = #units
for i = 1, count do
    local unit = units[i]
    unit:update(dt)
end

-- Avoid: Pairs iteration, slower
for _, unit in pairs(units) do
    unit:update(dt)
end
```

---

## Optimization Techniques

### 1. Cache Calculations

```lua
-- Calculate once, reuse
local damage_multiplier = 1.0 + (difficulty * 0.1)

function calculateDamage(attacker, defender)
    local base = attacker.damage - defender.armor
    return base * damage_multiplier  -- Use cached value
end
```

### 2. Object Pooling

```lua
-- Reuse objects instead of creating new ones
local projectilePool = {}

function getProjectile()
    if #projectilePool > 0 then
        return table.remove(projectilePool)  -- Reuse
    else
        return createProjectile()  -- Create if needed
    end
end

function returnProjectile(proj)
    table.insert(projectilePool, proj)  -- Return to pool
end
```

### 3. Lazy Evaluation

```lua
-- Only calculate expensive things if needed
function Unit.getVisibleEnemies()
    if not self._cachedEnemies or self._cacheOutdated then
        self._cachedEnemies = calculateVisibleEnemies(self)
        self._cacheOutdated = false
    end
    return self._cachedEnemies
end

-- Mark cache as outdated when needed
function battle.moveUnit(unit, dest)
    unit._cacheOutdated = true  -- Visibility changed
    -- ... move unit
end
```

### 4. Early Exit

```lua
-- Exit loops early when result found
function findUnit(id)
    for _, unit in ipairs(units) do
        if unit.id == id then
            return unit  -- Exit immediately
        end
    end
    return nil
end

-- Check conditions efficiently
function isTargetValid(unit, target)
    -- Check inexpensive conditions first
    if not target or target.current_hp <= 0 then
        return false
    end
    if not canSee(unit, target) then  -- Expensive check last
        return false
    end
    return true
end
```

---

## Memory Management

### 1. Cleanup Resources

```lua
function BattleSystem.endBattle()
    -- Clear unit references
    for i = #units, 1, -1 do
        units[i] = nil
    end
    units = {}
    
    -- Release other resources
    visibilityCache = nil
    pathCache = nil
    
    print("[BattleSystem] Cleaned up resources")
end
```

### 2. Garbage Collection

```lua
function love.update(dt)
    -- ... game update
    
    -- Run garbage collection periodically
    if turnCount % 10 == 0 then
        collectgarbage()  -- Run garbage collection
    end
end
```

### 3. Avoid Memory Leaks

```lua
-- Problem: Circular reference prevents cleanup
unit.battle = battle
battle.units[unit.id] = unit  -- Circular!

-- Solution: Use weak references (if supported)
-- Or: Explicitly clean up references
function battle.cleanup()
    for id, unit in pairs(self.units) do
        unit.battle = nil  -- Break reference
        self.units[id] = nil
    end
end
```

---

## Performance Checklist

**Before Release**:

- [ ] Average FPS ≥ 55 in all scenes
- [ ] No FPS drops during normal gameplay
- [ ] Memory usage stable over time (no leaks)
- [ ] Load times reasonable (<5 seconds)
- [ ] No console warnings or errors
- [ ] Profiler identifies no major bottlenecks

**During Development**:

- [ ] Test with maximum unit count (12 per side)
- [ ] Test large maps (maximum size battles)
- [ ] Monitor memory growth over extended play
- [ ] Profile pathfinding with many units
- [ ] Check rendering performance with all effects

---

## Performance Regression Testing

### Baseline Measurements

Establish baseline performance targets:

```
Scene: Battlescape with 24 units
- Render: 2-3 ms
- Update: 5-8 ms
- Pathfinding: <1 ms (cached)
- Total: <16 ms (60 FPS)

Memory: <150 MB during active battle
```

### Regression Detection

Monitor for performance regressions:

```lua
-- Log performance each turn
function logPerformance()
    local mem = collectgarbage("count")
    local fps = love.timer.getFPS()
    
    print(string.format(
        "[PERF] FPS: %d, Memory: %.1f KB",
        fps, mem
    ))
    
    if fps < 50 then
        print("[PERF] WARNING: Performance regression detected!")
    end
end
```

---

## Performance by System

### Geoscape (Strategic Layer)

**Target**: One turn < 500 ms

**Optimizations**:
- Batch mission generation
- Cache faction calculations
- Limit UFO pathfinding

### Basescape (Base Management)

**Target**: Interface response < 100 ms

**Optimizations**:
- Cache facility connections
- Pre-calculate production rates
- Defer non-critical updates

### Battlescape (Tactical Combat)

**Target**: One turn < 1 second

**Optimizations**:
- Pre-calculate visibility at turn start
- Cache unit AI decisions
- Batch rendering updates

---

## Related Documentation

- **[Debugging Guide](developers/DEBUGGING.md)** - Debugging techniques
- **[Code Standards](CODE_STANDARDS.md)** - Best practices
- **[Troubleshooting](developers/TROUBLESHOOTING.md)** - Common issues

---

**Last Updated**: October 2025 | **Status**: Active
