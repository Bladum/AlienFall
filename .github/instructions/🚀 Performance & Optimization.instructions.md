# 🚀 Performance & Optimization Best Practices

**Domain:** Performance Engineering  
**Focus:** FPS optimization, memory management, profiling, bottleneck identification  
**Version:** 1.0  
**Date:** October 2025

## Table of Contents

1. [Profiling Fundamentals](#profiling-fundamentals)
2. [FPS & Frame Time Management](#fps--frame-time-management)
3. [Memory Management](#memory-management)
4. [Love2D-Specific Optimizations](#love2d-specific-optimizations)
5. [Draw Call Optimization](#draw-call-optimization)
6. [Entity & Collision Performance](#entity--collision-performance)
7. [Garbage Collection Strategies](#garbage-collection-strategies)
8. [Spatial Partitioning & Culling](#spatial-partitioning--culling)
9. [Caching & Memoization](#caching--memoization)
10. [Bottleneck Identification](#bottleneck-identification)
11. [Performance Testing](#performance-testing)
12. [Audio & Resource Performance](#audio--resource-performance)
13. [Network Performance (if applicable)](#network-performance-if-applicable)
14. [Optimization Workflow](#optimization-workflow)
15. [Common Performance Mistakes](#common-performance-mistakes)

---

## Profiling Fundamentals

### ✅ DO: Profile Before Optimizing

**Why:** The biggest performance myth is that you know where the bottleneck is. You don't. Profile first.

```lua
-- Comprehensive profiling approach
local profiler = {
    marks = {},
    results = {}
}

function profiler:start(name)
    self.marks[name] = love.timer.getTime()
end

function profiler:stop(name)
    if self.marks[name] then
        local elapsed = love.timer.getTime() - self.marks[name]
        if not self.results[name] then
            self.results[name] = { count = 0, total = 0, min = math.huge, max = 0 }
        end
        self.results[name].count = self.results[name].count + 1
        self.results[name].total = self.results[name].total + elapsed
        self.results[name].min = math.min(self.results[name].min, elapsed)
        self.results[name].max = math.max(self.results[name].max, elapsed)
        self.marks[name] = nil
    end
end

function profiler:report()
    print("\n=== PERFORMANCE REPORT ===")
    for name, stats in pairs(self.results) do
        local avg = stats.total / stats.count
        print(string.format(
            "%s: avg=%.2fms, min=%.2fms, max=%.2fms, calls=%d",
            name, avg*1000, stats.min*1000, stats.max*1000, stats.count
        ))
    end
    print("========================\n")
end

-- Usage in game loop
function love.update(dt)
    profiler:start("update_entities")
    updateEntities(dt)
    profiler:stop("update_entities")
    
    profiler:start("update_ai")
    updateAI(dt)
    profiler:stop("update_ai")
end

function love.draw()
    profiler:start("draw_call")
    love.graphics.clear(0.1, 0.1, 0.1)
    drawGame()
    profiler:stop("draw_call")
    
    if showDebug then
        profiler:report()
    end
end
```

**When to apply:**
- At start of major optimization effort
- When FPS drops unexpectedly
- Before each release
- When adding new features

**Impact:** 80/20 rule - 20% of code causes 80% of slowdowns. Find that 20%.

---

### ✅ DO: Use Love2D Statistics API

Love2D provides built-in performance metrics:

```lua
function love.draw()
    -- Get performance stats
    local stats = love.graphics.getStats()
    local objects = love.graphics.getStats().objects or {}
    
    love.graphics.print("Draw Calls: " .. stats.drawcalls, 10, 10)
    love.graphics.print("Textures: " .. (objects.texture or 0), 10, 30)
    love.graphics.print("Canvases: " .. (objects.canvas or 0), 10, 50)
    
    -- Monitor memory usage
    local memKB = collectgarbage("count")
    love.graphics.print("Memory: " .. math.ceil(memKB/1024) .. " MB", 10, 70)
end
```

**Best practices:**
- Check stats during development
- Record baseline metrics
- Monitor before/after optimization
- Track trends across versions

---

### ❌ DON'T: Ignore Performance Until Late

**The problem:** Optimization is much harder when it's late in development. Performance should be considered from day one.

**Why it fails:**
- Architecture may prevent optimization
- Refactoring becomes riskier
- Features may need to be cut
- Time pressure increases

**Better approach:** Build with performance in mind from the start with reasonable defaults.

---

## FPS & Frame Time Management

### ✅ DO: Cap Delta Time

Uncapped delta time can cause major issues:

```lua
function love.update(dt)
    -- Cap delta time to prevent physics/logic jumps
    dt = math.min(dt, 1/60)  -- Max 60 FPS delta
    
    -- Now update with bounded dt
    updatePhysics(dt)
    updateGame(dt)
    updateAI(dt)
end
```

**Why this matters:**
- Without cap: 1 frame skip = 30ms jump = massive physics errors
- With cap: Worst case = 2 frames of calculations in 1 frame (manageable)
- Prevents catastrophic failures on frame spikes

**Recommended caps:**
- 60 FPS target: Cap at 1/60 (16.67ms)
- 30 FPS target: Cap at 1/30 (33.33ms)
- Adaptive: `dt = math.min(dt, 1/targetFPS)`

---

### ✅ DO: Monitor and Report Frame Pacing

```lua
local frameStats = {
    current = 0,
    history = {},
    maxHistory = 120
}

function love.update(dt)
    frameStats.current = dt
    table.insert(frameStats.history, dt)
    if #frameStats.history > frameStats.maxHistory then
        table.remove(frameStats.history, 1)
    end
end

function getFrameStats()
    local stats = {
        current = frameStats.current * 1000,  -- ms
        avg = 0,
        min = math.huge,
        max = 0,
        fps = 0
    }
    
    for _, dt in ipairs(frameStats.history) do
        stats.avg = stats.avg + dt
        stats.min = math.min(stats.min, dt)
        stats.max = math.max(stats.max, dt)
    end
    
    stats.avg = stats.avg / #frameStats.history * 1000  -- ms
    stats.fps = 1 / (stats.avg / 1000)
    
    return stats
end

function love.draw()
    local stats = getFrameStats()
    love.graphics.print(string.format(
        "FPS: %.0f | Frame: %.2fms avg (%.2f-%.2f) | Current: %.2fms",
        stats.fps, stats.avg, stats.min*1000, stats.max*1000, stats.current
    ), 10, 10)
end
```

**What to look for:**
- Average frame time should be consistent
- Spikes indicate bottlenecks
- Min/max range shows frame pacing issues
- Target: <16.67ms for 60 FPS

---

### ❌ DON'T: Use love.window.setVSync for Performance Testing

VSync masks frame pacing issues. For accurate profiling, disable it:

```lua
function love.conf(t)
    t.window.vsync = 0  -- Disable VSync for performance testing
    t.window.resizable = false
    t.window.width = 960
    t.window.height = 720
end
```

---

## Memory Management

### ✅ DO: Understand Lua Memory Model

Lua uses garbage collection. You need to work with it, not against it:

```lua
-- Track memory usage over time
local memoryTracker = {
    baseline = 0,
    current = 0,
    peak = 0
}

function updateMemory()
    memoryTracker.current = collectgarbage("count") / 1024  -- MB
    memoryTracker.peak = math.max(memoryTracker.peak, memoryTracker.current)
    
    if memoryTracker.baseline == 0 then
        memoryTracker.baseline = memoryTracker.current
    end
end

function love.draw()
    updateMemory()
    
    local delta = memoryTracker.current - memoryTracker.baseline
    love.graphics.print(string.format(
        "Memory: %.1f MB (delta: +%.1f MB, peak: %.1f MB)",
        memoryTracker.current,
        delta,
        memoryTracker.peak
    ), 10, 30)
end
```

**Key principles:**
- Lua GC runs automatically - let it work
- Memory peaks indicate object creation patterns
- Memory deltas show leaks
- Profile memory during gameplay, not menu

---

### ✅ DO: Reuse Objects Instead of Creating New Ones

**Object pool pattern for high-frequency allocations:**

```lua
local bulletPool = {
    available = {},
    active = {},
    maxPoolSize = 1000
}

function bulletPool:acquire()
    local bullet
    if #self.available > 0 then
        bullet = table.remove(self.available)
    else
        bullet = {
            x = 0, y = 0,
            vx = 0, vy = 0,
            active = false
        }
    end
    
    bullet.active = true
    table.insert(self.active, bullet)
    return bullet
end

function bulletPool:release(bullet)
    bullet.active = false
    table.insert(self.available, bullet)
end

function bulletPool:update(dt)
    local i = 1
    while i <= #self.active do
        local bullet = self.active[i]
        
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        
        -- Check if bullet should die
        if bullet.x < 0 or bullet.x > 960 or bullet.y < 0 or bullet.y > 720 then
            self:release(bullet)
            table.remove(self.active, i)
        else
            i = i + 1
        end
    end
end
```

**Benefits:**
- No garbage collection pressure
- Predictable frame timing
- Massive performance improvement for particle effects, bullets, etc.

---

### ❌ DON'T: Create Tables in Hot Loops

**Bad (creates garbage every frame):**
```lua
function updateEntities(dt)
    for i, entity in ipairs(entities) do
        local pos = {x = entity.x, y = entity.y}  -- NEW TABLE EACH ITERATION!
        updateEntity(entity, pos, dt)
    end
end
```

**Good (reuse or pass directly):**
```lua
function updateEntities(dt)
    for i, entity in ipairs(entities) do
        updateEntity(entity, dt)  -- Pass entity directly
    end
end

function updateEntity(entity, dt)
    -- Use entity.x, entity.y directly
    entity.x = entity.x + entity.vx * dt
    entity.y = entity.y + entity.vy * dt
end
```

---

## Love2D-Specific Optimizations

### ✅ DO: Batch Draw Calls

Love2D's performance is heavily dependent on draw call count:

```lua
-- Use Canvases to reduce draw calls
local uiCanvas = love.graphics.newCanvas(960, 720)

function love.draw()
    -- Draw game world
    love.graphics.setCanvas()
    love.graphics.clear(0.1, 0.1, 0.1)
    drawGameWorld()
    
    -- Draw UI to canvas (only when dirty)
    if uiDirty then
        love.graphics.setCanvas(uiCanvas)
        love.graphics.clear(0, 0, 0, 0)
        drawUI()
        love.graphics.setCanvas()
        uiDirty = false
    end
    
    -- Draw UI canvas (1 draw call)
    love.graphics.draw(uiCanvas, 0, 0)
end
```

**Draw call budget:**
- Mobile: < 100 draw calls
- Desktop: < 500 draw calls
- Each draw call = significant overhead

---

### ✅ DO: Use Sprite Atlases and Batching

```lua
local atlas = {
    image = love.graphics.newImage("sprites/atlas.png"),
    quads = {},
    batchSize = 1000
}

-- Create quads for sprite atlas
function atlas:addSprite(name, x, y, w, h)
    self.quads[name] = love.graphics.newQuad(x, y, w, h, self.image:getDimensions())
end

-- Use batch for drawing
local spriteBatch = love.graphics.newSpriteBatch(atlas.image, atlas.batchSize)

function love.draw()
    spriteBatch:clear()
    
    -- Add all visible sprites to batch
    for _, sprite in ipairs(visibleSprites) do
        spriteBatch:add(atlas.quads[sprite.type], sprite.x, sprite.y)
    end
    
    -- Single draw call for all sprites
    love.graphics.draw(spriteBatch, 0, 0)
end
```

**Impact:** Reduces 1000 draw calls to 1 draw call.

---

### ✅ DO: Culling Invisible Objects

```lua
function isSpriteVisible(x, y, w, h)
    return x + w >= camera.x and
           x <= camera.x + screenWidth and
           y + h >= camera.y and
           y <= camera.y + screenHeight
end

function love.draw()
    local spriteBatch = love.graphics.newSpriteBatch(atlas.image)
    
    for _, sprite in ipairs(sprites) do
        if isSpriteVisible(sprite.x, sprite.y, sprite.w, sprite.h) then
            spriteBatch:add(atlas.quads[sprite.type], sprite.x, sprite.y)
        end
    end
    
    love.graphics.draw(spriteBatch, 0, 0)
end
```

---

## Draw Call Optimization

### ✅ DO: Minimize State Changes

Each state change (texture, shader, blend mode) forces a flush:

```lua
-- Bad: Interleaved state changes
function drawGameBad()
    love.graphics.setColor(1, 0, 0)
    love.graphics.draw(redSprite, 0, 0)
    
    love.graphics.setColor(0, 0, 1)
    love.graphics.draw(blueSprite, 100, 0)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.draw(redSprite, 200, 0)
end

-- Good: Group by state
function drawGameGood()
    love.graphics.setColor(1, 0, 0)
    love.graphics.draw(redSprite, 0, 0)
    love.graphics.draw(redSprite, 200, 0)
    
    love.graphics.setColor(0, 0, 1)
    love.graphics.draw(blueSprite, 100, 0)
end
```

---

### ❌ DON'T: Draw Thousands of Rectangles

**Bad:**
```lua
function drawGrid()
    for x = 0, 100 do
        for y = 0, 100 do
            love.graphics.rectangle("line", x*32, y*32, 32, 32)
        end
    end
end
```

**Good (use mesh or canvas):**
```lua
local gridMesh = nil

function generateGridMesh()
    local vertices = {}
    local idx = 1
    
    for x = 0, 100 do
        for y = 0, 100 do
            vertices[idx] = {x*32, y*32, 0, 0}
            vertices[idx+1] = {x*32+32, y*32, 0, 0}
            vertices[idx+2] = {x*32+32, y*32+32, 0, 0}
            idx = idx + 3
        end
    end
    
    gridMesh = love.graphics.newMesh(vertices, "triangles")
end

function drawGridMesh()
    if not gridMesh then generateGridMesh() end
    love.graphics.draw(gridMesh, 0, 0)
end
```

---

## Entity & Collision Performance

### ✅ DO: Use Quadtrees for Spatial Queries

```lua
local quadtree = {
    x = 0, y = 0, w = 960, h = 720,
    maxItems = 4,
    children = nil,
    items = {}
}

function quadtree:insert(item, x, y, w, h)
    if self.children then
        -- Has children, place in appropriate child
        for _, child in ipairs(self.children) do
            if self:overlaps(child, x, y, w, h) then
                child:insert(item, x, y, w, h)
            end
        end
    else
        -- Leaf node, add item
        table.insert(self.items, {item = item, x = x, y = y, w = w, h = h})
        
        -- Split if too many items
        if #self.items > self.maxItems then
            self:split()
        end
    end
end

function quadtree:query(x, y, w, h, results)
    results = results or {}
    
    -- Check items in this node
    for _, entry in ipairs(self.items) do
        if self:overlaps(entry.x, entry.y, entry.w, entry.h, x, y, w, h) then
            table.insert(results, entry.item)
        end
    end
    
    -- Check children
    if self.children then
        for _, child in ipairs(self.children) do
            if self:overlaps(child, x, y, w, h) then
                child:query(x, y, w, h, results)
            end
        end
    end
    
    return results
end

-- Usage
function getNearbyEntities(entity, range)
    return quadtree:query(
        entity.x - range, entity.y - range,
        range * 2, range * 2
    )
end
```

**Benefits:**
- Reduce collision checks from O(n²) to O(n log n)
- Massive speedup with many entities

---

### ✅ DO: Early Exit Collision Checks

```lua
function checkCollision(a, b)
    -- AABB early exit (bounding box)
    if a.x + a.w < b.x or a.x > b.x + b.w or
       a.y + a.h < b.y or a.y > b.y + b.h then
        return false  -- No collision
    end
    
    -- Only do expensive checks if bounding boxes overlap
    return expensiveShapeCollision(a, b)
end
```

---

## Garbage Collection Strategies

### ✅ DO: Force GC During Safe Times

```lua
-- Force garbage collection during loading or pause screens
function love.update(dt)
    if gameState == "paused" or gameState == "loading" then
        collectgarbage("collect")  -- Run full collection
    else
        collectgarbage("step", 1)  -- Run incremental collection
    end
end
```

**Why:** GC pauses are noticeable during gameplay but invisible during menus.

---

### ✅ DO: Monitor GC Performance

```lua
local gcStats = {
    lastCollection = 0,
    collectionTime = 0
}

function love.update(dt)
    local before = love.timer.getTime()
    collectgarbage("step", 1)
    local after = love.timer.getTime()
    
    gcStats.collectionTime = after - before
    
    if gcStats.collectionTime > 0.01 then  -- > 10ms
        print(string.format("[WARN] GC took %.2fms", gcStats.collectionTime * 1000))
    end
end
```

---

## Spatial Partitioning & Culling

### ✅ DO: Implement Frustum Culling for Camera

```lua
local camera = {
    x = 0, y = 0,
    w = 960, h = 720,
    margin = 100  -- Cull slightly beyond screen
}

function camera:isVisible(x, y, w, h)
    return x + w + self.margin > self.x and
           x - self.margin < self.x + self.w and
           y + h + self.margin > self.y and
           y - self.margin < self.y + self.h
end

function love.draw()
    local visibleCount = 0
    
    for _, entity in ipairs(entities) do
        if camera:isVisible(entity.x, entity.y, entity.w, entity.h) then
            drawEntity(entity)
            visibleCount = visibleCount + 1
        end
    end
    
    love.graphics.print("Visible: " .. visibleCount .. "/" .. #entities, 10, 100)
end
```

---

## Caching & Memoization

### ✅ DO: Cache Computed Values

```lua
local distanceCache = {}

function getDistance(x1, y1, x2, y2)
    local key = string.format("%.0f,%.0f,%.0f,%.0f", x1, y1, x2, y2)
    
    if not distanceCache[key] then
        distanceCache[key] = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    end
    
    return distanceCache[key]
end

-- Clear cache periodically
function love.update(dt)
    frameCount = frameCount + 1
    if frameCount % 300 == 0 then  -- Every 5 seconds at 60 FPS
        distanceCache = {}  -- Clear cache
    end
end
```

---

### ✅ DO: Use Lookup Tables Instead of Calculations

```lua
-- Precompute sine/cosine table
local sinTable = {}
local cosTable = {}

function initTrigTables()
    for angle = 0, 359 do
        local rad = angle * math.pi / 180
        sinTable[angle] = math.sin(rad)
        cosTable[angle] = math.cos(rad)
    end
end

function getSin(angle)
    angle = angle % 360
    return sinTable[math.floor(angle)] or math.sin(angle * math.pi / 180)
end

function getCos(angle)
    angle = angle % 360
    return cosTable[math.floor(angle)] or math.cos(angle * math.pi / 180)
end

-- In love.load()
love.load = function()
    initTrigTables()
    -- ... rest of setup
end
```

**Impact:** 10x+ faster than computing trigonometry on the fly.

---

## Bottleneck Identification

### ✅ DO: Systematic Profiling Approach

1. **Measure baseline:** Get starting numbers
2. **Identify bottleneck:** Where is time spent?
3. **Optimize strategically:** Focus on highest impact
4. **Measure result:** Compare before/after
5. **Iterate:** Repeat until target achieved

```lua
local bottlenecks = {}

function profileFunction(name, func, ...)
    local before = love.timer.getTime()
    local result = func(...)
    local after = love.timer.getTime()
    
    local elapsed = after - before
    if not bottlenecks[name] then
        bottlenecks[name] = {count = 0, total = 0}
    end
    
    bottlenecks[name].count = bottlenecks[name].count + 1
    bottlenecks[name].total = bottlenecks[name].total + elapsed
    
    return result
end

function reportBottlenecks()
    print("\n=== BOTTLENECK REPORT ===")
    local sorted = {}
    
    for name, stats in pairs(bottlenecks) do
        table.insert(sorted, {
            name = name,
            time = stats.total,
            avg = stats.total / stats.count
        })
    end
    
    table.sort(sorted, function(a, b) return a.time > b.time end)
    
    for _, entry in ipairs(sorted) do
        print(string.format(
            "%s: %.2fms total (%.4fms avg)",
            entry.name,
            entry.time * 1000,
            entry.avg * 1000
        ))
    end
end
```

---

### ❌ DON'T: Optimize Prematurely

**The problem:** Spending hours optimizing code that only runs 1% of the time.

**Reality:**
- Find the actual bottleneck first
- 80/20 rule: 80% of time in 20% of code
- Profile before optimizing

---

## Performance Testing

### ✅ DO: Create Performance Benchmarks

```lua
local benchmark = {
    tests = {},
    results = {}
}

function benchmark:add(name, func, iterations)
    table.insert(self.tests, {name = name, func = func, iterations = iterations or 1000})
end

function benchmark:run()
    for _, test in ipairs(self.tests) do
        local before = love.timer.getTime()
        
        for i = 1, test.iterations do
            test.func()
        end
        
        local after = love.timer.getTime()
        local elapsed = after - before
        
        self.results[test.name] = {
            time = elapsed,
            avg = elapsed / test.iterations,
            iterations = test.iterations
        }
    end
end

function benchmark:report()
    print("\n=== BENCHMARK RESULTS ===")
    for name, result in pairs(self.results) do
        print(string.format(
            "%s: %.4fms per call (%.2fms total for %d iterations)",
            name,
            result.avg * 1000,
            result.time * 1000,
            result.iterations
        ))
    end
end

-- Usage
benchmark:add("distance_calculation", function()
    local d = math.sqrt((100-200)^2 + (200-300)^2)
end, 10000)

benchmark:add("lookup_distance", function()
    local d = getDistance(100, 200, 200, 300)
end, 10000)

benchmark:run()
benchmark:report()
```

---

## Audio & Resource Performance

### ✅ DO: Manage Audio Resources

```lua
local audioPool = {
    sounds = {},
    sources = {},
    maxSources = 32
}

function audioPool:loadSound(name, path)
    if not self.sounds[name] then
        self.sounds[name] = love.audio.newSource(path, "static")
    end
    return self.sounds[name]
end

function audioPool:play(name, pitch, volume)
    pitch = pitch or 1
    volume = volume or 1
    
    -- Find available source
    for i = 1, self.maxSources do
        if not self.sources[i] or not self.sources[i]:isPlaying() then
            self.sources[i] = self.sounds[name]:clone()
            self.sources[i]:setPitch(pitch)
            self.sources[i]:setVolume(volume)
            self.sources[i]:play()
            return
        end
    end
end
```

**Why:** Audio sources are expensive resources. Reuse and limit them.

---

## Network Performance (if applicable)

### ✅ DO: Batch Network Messages

```lua
local networkBatcher = {
    messages = {},
    batchInterval = 0.1,  -- Send batch every 100ms
    timeSinceLastSend = 0
}

function networkBatcher:add(message)
    table.insert(self.messages, message)
end

function networkBatcher:update(dt)
    self.timeSinceLastSend = self.timeSinceLastSend + dt
    
    if self.timeSinceLastSend >= self.batchInterval then
        self:send()
        self.timeSinceLastSend = 0
    end
end

function networkBatcher:send()
    if #self.messages > 0 then
        -- Send all messages as one batch
        local batch = {type = "batch", messages = self.messages}
        sendToServer(batch)
        self.messages = {}
    end
end
```

---

## Optimization Workflow

### ✅ DO: Follow Optimization Process

1. **Profile baseline:** Measure current performance
2. **Set target:** Define acceptable performance
3. **Identify hotspot:** Find where time is spent
4. **Optimize:** Apply optimization technique
5. **Measure:** Compare to baseline
6. **Iterate:** Continue until target reached

```lua
-- Example optimization checklist
local optimizations = {
    {name = "profile_game_loop", done = false},
    {name = "reduce_draw_calls", done = false},
    {name = "implement_culling", done = false},
    {name = "object_pooling", done = false},
    {name = "spatial_partitioning", done = false},
    {name = "gc_tuning", done = false},
    {name = "measure_final", done = false}
}

function printOptimizationChecklist()
    print("\n=== OPTIMIZATION CHECKLIST ===")
    for _, opt in ipairs(optimizations) do
        print(string.format("[%s] %s", opt.done and "X" or " ", opt.name))
    end
end
```

---

## Common Performance Mistakes

### ❌ Mistake: Creating Tables in Love.draw()

**Why it fails:**
- Garbage is created every frame
- GC pauses make frame pacing worse
- Visual stutters occur

**Solution:**
- Reuse table structures
- Use object pools
- Allocate once in love.load()

---

### ❌ Mistake: Not Culling Off-Screen Objects

**Why it fails:**
- Wasting CPU updating invisible entities
- Wasting GPU drawing invisible sprites
- Massive slowdown with many entities

**Solution:**
- Implement frustum culling
- Only update/draw visible entities
- Can handle 10x more entities with culling

---

### ❌ Mistake: Not Using Batching

**Why it fails:**
- Each draw call = significant overhead
- Can only render 100-500 objects before stalling
- Unscalable approach

**Solution:**
- Use sprite batches
- Group by texture/shader
- Reduce draw calls from 1000 to 10

---

### ❌ Mistake: Premature Optimization

**Why it fails:**
- Code becomes unreadable
- Optimizations may not help actual bottleneck
- Time wasted on low-impact changes

**Solution:**
- Profile first
- Focus on highest impact optimizations
- Verify improvements with measurements

---

### ❌ Mistake: Ignoring GC Pauses

**Why it fails:**
- Unpredictable frame pacing
- Players notice stutters
- Professional perception damage

**Solution:**
- Monitor GC time
- Object pooling reduces GC pressure
- Collate GC during safe times

---

## Performance Optimization Checklist

### Before Release:

- [ ] Profile baseline (60 FPS target at 720p)
- [ ] Identify bottlenecks with profiler
- [ ] Implement object pooling for high-frequency objects
- [ ] Add frustum culling for camera-based rendering
- [ ] Use sprite batches (target: <50 draw calls)
- [ ] Monitor and cap memory usage (<500MB)
- [ ] Test frame pacing (should be <20ms avg)
- [ ] Verify GC doesn't cause stutters
- [ ] Profile on target hardware
- [ ] Create performance regression tests
- [ ] Document performance characteristics
- [ ] Set up performance monitoring in build

---

## Performance Best Practices Summary

### ✅ DO
- Profile before optimizing (measure, don't guess)
- Use Love2D statistics API during development
- Implement object pools for high-frequency allocations
- Use sprite batching and canvases
- Implement frustum culling for large maps
- Cache expensive computations
- Monitor GC performance
- Test on target hardware
- Document performance characteristics
- Create performance regressions tests

### ❌ DON'T
- Create tables in hot loops
- Draw thousands of individual objects
- Render off-screen sprites
- Ignore GC pauses
- Assume you know where bottleneck is
- Optimize prematurely
- Use expensive operations in love.draw()
- Create uncapped delta time
- Ignore memory leaks
- Skip performance testing

---

## References

- Love2D Documentation: https://love2d.org/wiki/Main_Page
- Lua Performance Tips: https://www.lua.org/gems/sample.pdf
- Game Programming Patterns: https://gameprogrammingpatterns.com/
- GDC Talks on Performance

