# Object Pooling Usage Guide

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Target Audience:** Developers optimizing game performance

---

## Table of Contents

1. [Overview](#overview)
2. [Core Components](#core-components)
3. [Performance Benefits](#performance-benefits)
4. [Best Practices](#best-practices)
5. [Integration Example](#integration-example)
6. [Monitoring and Debugging](#monitoring-and-debugging)
7. [Troubleshooting](#troubleshooting)
8. [Testing](#testing)
9. [Summary](#summary)

---

## Overview

The object pooling system reduces garbage collection overhead by reusing objects instead of creating new ones. This is especially important for frequently created/destroyed objects like projectiles and particle effects.

## Core Components

### 1. ObjectPool (Generic Pool)

**File:** `src/utils/object_pool.lua`

Generic object pool that works with any object type.

```lua
local ObjectPool = require('utils.object_pool')

-- Create a pool
local bullet_pool = ObjectPool:new(
    function() return {x=0, y=0, active=false} end,  -- Factory
    function(obj) obj.active = false end,             -- Reset function
    10,   -- Initial size
    50    -- Max size
)

-- Use the pool
local bullet = bullet_pool:acquire()
bullet.x = 100
bullet.y = 200
bullet.active = true

-- When done, release back to pool
bullet_pool:release(bullet)

-- Get statistics
local stats = bullet_pool:getStats()
print("Reuse rate:", stats.reuse_rate, "%")
```

### 2. Specialized Pools

**File:** `src/battlescape/pools.lua`

Pre-configured pools for common game objects.

#### Initialize Pools (Once at Game Start)

```lua
local Pools = require('battlescape.pools')

function love.load()
    Pools.initialize()
end
```

#### Projectile Pool

```lua
-- Create a projectile
local projectile = Pools.createProjectile(
    start_x, start_y,    -- Starting position
    target_x, target_y,  -- Target position
    300,                 -- Speed
    25,                  -- Damage
    bullet_sprite        -- Sprite image
)

-- Update projectile
function love.update(dt)
    projectile:update(dt)
    
    -- Check if hit target or expired
    if not projectile.active then
        Pools.releaseProjectile(projectile)
    end
end

-- Draw projectile
function love.draw()
    projectile:draw()
end
```

#### Particle Effect Pool

```lua
-- Create explosion effect
local explosion = Pools.createEffect(
    x, y,                        -- Position
    "explosion",                 -- Effect type
    {1, 0.5, 0, 1},             -- Color (RGBA)
    30                           -- Particle count
)

-- Update effect
function love.update(dt)
    explosion:update(dt)
    
    if not explosion.active then
        Pools.releaseEffect(explosion)
    end
end

-- Draw effect
function love.draw()
    explosion:draw()
end
```

#### Temporary Table Pool

For calculations, pathfinding, etc. to reduce GC pressure:

```lua
-- Get a temporary table
local temp = Pools.getTempTable()

-- Use it for calculations
temp.distance = calculate_distance(a, b)
temp.path = find_path(start, goal)

-- Release when done
Pools.releaseTempTable(temp)
```

## Performance Benefits

### Expected Improvements

- **Garbage Collection:** 30-50% reduction in GC time
- **Object Reuse:** 60-80% reuse rate in typical gameplay
- **Memory Stability:** No spikes from repeated allocation/deallocation
- **Frame Rate:** Smoother, more consistent FPS

### Statistics Tracking

```lua
-- Get pool statistics
local stats = Pools.getStats()

print("Projectile Pool:")
print("  Created:", stats.projectiles.created)
print("  Reused:", stats.projectiles.reused)
print("  Reuse rate:", stats.projectiles.reuse_rate, "%")
print("  Current usage:", stats.projectiles.current_usage)
print("  Peak usage:", stats.projectiles.peak_usage)

print("Effect Pool:")
print("  Reuse rate:", stats.effects.reuse_rate, "%")

print("Table Pool:")
print("  Available:", stats.temp_tables.available)
```

## Best Practices

### ✅ DO

1. **Always Release Objects**
   ```lua
   local obj = pool:acquire()
   -- Use object
   pool:release(obj)  -- Don't forget!
   ```

2. **Release When Inactive**
   ```lua
   if not projectile.active then
       Pools.releaseProjectile(projectile)
   end
   ```

3. **Use Temp Tables for Calculations**
   ```lua
   local temp = Pools.getTempTable()
   temp.result = expensive_calculation()
   process(temp.result)
   Pools.releaseTempTable(temp)
   ```

4. **Pre-warm Pools for Known Load**
   ```lua
   bullet_pool:prewarm(100)  -- Pre-allocate 100 bullets
   ```

### ❌ DON'T

1. **Don't Hold References After Release**
   ```lua
   local obj = pool:acquire()
   pool:release(obj)
   obj.x = 100  -- BAD! Object might be reused
   ```

2. **Don't Release Multiple Times**
   ```lua
   pool:release(obj)
   pool:release(obj)  -- BAD! Will corrupt pool
   ```

3. **Don't Forget to Release**
   ```lua
   -- This causes memory leaks!
   for i = 1, 1000 do
       local obj = pool:acquire()
       -- Never released!
   end
   ```

## Integration Example

### Complete Combat System Integration

```lua
local Pools = require('battlescape.pools')

function CombatSystem:fireWeapon(attacker, target)
    -- Create projectile from pool
    local projectile = Pools.createProjectile(
        attacker.x, attacker.y,
        target.x, target.y,
        400,  -- Speed
        self:calculateDamage(attacker, target),
        self.bullet_sprite
    )
    
    -- Track active projectiles
    table.insert(self.active_projectiles, projectile)
end

function CombatSystem:update(dt)
    -- Update all projectiles
    for i = #self.active_projectiles, 1, -1 do
        local proj = self.active_projectiles[i]
        proj:update(dt)
        
        -- Check collision
        if self:checkCollision(proj) then
            -- Create impact effect
            local impact = Pools.createEffect(
                proj.x, proj.y,
                "explosion",
                {1, 0.8, 0, 1},
                20
            )
            table.insert(self.active_effects, impact)
            
            -- Release projectile
            Pools.releaseProjectile(proj)
            table.remove(self.active_projectiles, i)
        end
    end
    
    -- Update all effects
    for i = #self.active_effects, 1, -1 do
        local effect = self.active_effects[i]
        effect:update(dt)
        
        if not effect.active then
            Pools.releaseEffect(effect)
            table.remove(self.active_effects, i)
        end
    end
end

function CombatSystem:cleanup()
    -- Release all objects when scene ends
    for _, proj in ipairs(self.active_projectiles) do
        Pools.releaseProjectile(proj)
    end
    for _, effect in ipairs(self.active_effects) do
        Pools.releaseEffect(effect)
    end
    
    self.active_projectiles = {}
    self.active_effects = {}
end
```

## Monitoring and Debugging

### Debug Visualization

```lua
function love.draw()
    -- Draw pool statistics
    local stats = Pools.getStats()
    love.graphics.print(string.format(
        "Projectiles: %d/%d (%.1f%% reuse)",
        stats.projectiles.current_usage,
        stats.projectiles.peak_usage,
        stats.projectiles.reuse_rate
    ), 10, 10)
end
```

### Memory Profiling

```lua
-- Before pooling
collectgarbage("collect")
local mem_before = collectgarbage("count")

-- Run game for 60 seconds

-- After pooling
collectgarbage("collect")
local mem_after = collectgarbage("count")

print("Memory growth:", mem_after - mem_before, "KB")
```

## Troubleshooting

### Problem: Low Reuse Rate

**Symptom:** Reuse rate below 50%

**Solutions:**
- Increase initial pool size
- Check if objects are being released
- Verify reset function clears state properly

### Problem: Memory Still Growing

**Symptom:** Memory usage increases over time

**Solutions:**
- Set max pool size to prevent unbounded growth
- Check for reference leaks (objects not released)
- Use `Pools.clear()` between levels

### Problem: Objects Have Stale Data

**Symptom:** Reused objects show old values

**Solutions:**
- Ensure reset function clears all fields
- Check reset function is being called
- Initialize all fields in factory function

## Testing

Run the object pool tests:

```bash
./love-11.5-win64/lovec.exe . --test util/test_object_pool
```

Expected output:
- All tests pass
- Reuse rate > 80% in tests
- No memory leaks detected

---

## Summary

Object pooling is a powerful optimization technique. Use it for:
- ✅ Projectiles (bullets, missiles)
- ✅ Particle effects (explosions, smoke)
- ✅ Temporary tables (calculations, pathfinding)
- ✅ UI elements (tooltips, notifications)
- ✅ Any frequently created/destroyed objects

**Key Takeaway:** Always acquire from pool, use, then release. Monitor statistics to ensure good reuse rates.
