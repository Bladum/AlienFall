# 🐛 Debugging & Problem-Solving Best Practices

**Domain:** Debugging & Troubleshooting  
**Focus:** Systematic debugging, error handling, troubleshooting methodologies  
**Version:** 1.0  
**Date:** October 2025

## Table of Contents

1. [Debugging Fundamentals](#debugging-fundamentals)
2. [Systematic Debugging Method](#systematic-debugging-method)
3. [Print-Based Debugging](#print-based-debugging)
4. [Console Output Analysis](#console-output-analysis)
5. [Breakpoint & Step Debugging](#breakpoint--step-debugging)
6. [Memory Debugging](#memory-debugging)
7. [Performance Debugging](#performance-debugging)
8. [Logic Errors](#logic-errors)
9. [Race Conditions & Concurrency](#race-conditions--concurrency)
10. [Love2D-Specific Debugging](#love2d-specific-debugging)
11. [Crash Analysis](#crash-analysis)
12. [Debuggingcommon Game Issues](#debugging-common-game-issues)
13. [Creating Minimal Reproducible Examples](#creating-minimal-reproducible-examples)
14. [Documentation & Learning from Bugs](#documentation--learning-from-bugs)
15. [Debugging Checklist](#debugging-checklist)

---

## Debugging Fundamentals

### ✅ DO: Assume Your Code Has Bugs

**The mindset:** Your code doesn't work until proven otherwise.

```lua
-- Pattern: Defensive programming
function updateEntity(entity, dt)
    -- Validate inputs first
    if not entity then
        error("Entity is nil")
    end
    
    if not dt or dt < 0 then
        error("Invalid delta time: " .. tostring(dt))
    end
    
    -- Now proceed with confidence
    entity.x = entity.x + entity.vx * dt
    entity.y = entity.y + entity.vy * dt
end
```

**Why it matters:**
- Bugs hide in assumptions
- Defensive code catches bugs early
- Saves debugging time later

---

### ✅ DO: Start with Reproducibility

**Before you debug, answer:**
1. Can I reproduce it consistently?
2. What are exact steps?
3. Does it happen every time or randomly?

```markdown
# Bug Report: Units Get Stuck in Corners

## Reproduction Steps
1. Load battlescape
2. Spawn 10 soldiers
3. Send them to opposite corner
4. Wait 5-10 seconds
5. 2-3 units get stuck (don't move further)

## Consistency
- Happens 80% of the time
- More likely with more units
- Doesn't happen on large maps

## Environment
- Love2D 12.0
- macOS 12.1
- Windows 10 (also tested)
```

**Why this matters:**
- Intermittent bugs are 10x harder to debug
- Reproducibility = can verify fix

---

### ❌ DON'T: Debug Without Understanding

**Bad approach:** Try random things until bug disappears

**Better approach:** Understand WHAT is broken before fixing.

---

## Systematic Debugging Method

### ✅ DO: Follow Scientific Debugging

**The process:**

```
1. Observe: What's the exact symptom?
2. Hypothesis: What could cause this?
3. Test: Check if hypothesis is correct
4. Conclude: Was hypothesis right?
5. Fix: If right, implement fix. If wrong, go to step 2.
```

**Example:**

```markdown
## Bug: Player takes damage despite cover

### Observation
- Unit behind cover: 80% damage reduction
- Actual damage: 95% (nearly full damage)
- Cover status shows "protected" in UI

### Hypothesis 1: Cover calculation is wrong
- Test: Log cover_reduction value
- Result: Logs show 80% correctly
- Conclusion: ❌ Not the issue

### Hypothesis 2: Cover reduction not applied correctly
- Test: Log damage before/after reduction
- Result: Before=100, After=95 (reduction not working)
- Conclusion: ✅ Issue found!

### Root Cause
- Line 342 in damage_calc.lua: `damage = damage * (1 - cover_reduction)`
- Should be: `damage = damage * cover_reduction`
- Off-by-one in logic

### Fix
Change line 342 to correct calculation
```

---

### ✅ DO: Use Binary Search to Find Bug Location

**If you know behavior is wrong, narrow it down:**

```lua
-- Broken code somewhere in this sequence
function updateBattle(dt)
    updatePhysics(dt)      -- 1
    updateAI(dt)           -- 2
    updateAnimation(dt)    -- 3
    updateEffects(dt)      -- 4
    checkCollisions()      -- 5
    resolveCollisions()    -- 6
    updateUI()             -- 7
end

-- Binary search: comment out half
function updateBattle(dt)
    updatePhysics(dt)      -- 1
    updateAI(dt)           -- 2
    updateAnimation(dt)    -- 3
    updateEffects(dt)      -- 4
    -- Disable second half to isolate
    -- checkCollisions()   -- 5
    -- resolveCollisions() -- 6
    -- updateUI()          -- 7
end

-- If bug still occurs: problem in first 4
-- If bug gone: problem in second half (7)

-- Narrow further
```

---

## Print-Based Debugging

### ✅ DO: Strategic Print Debugging

```lua
-- GOOD: Contextual debug output
function updateEntity(entity, dt)
    if DEBUG then
        print(string.format(
            "[Entity %d] pos=(%.1f, %.1f) vel=(%.1f, %.1f)",
            entity.id,
            entity.x, entity.y,
            entity.vx, entity.vy
        ))
    end
    
    -- ... update logic ...
    
    if DEBUG and entity.x < 0 or entity.x > 960 then
        print(string.format("[ERROR] Entity %d out of bounds: x=%.1f", entity.id, entity.x))
    end
end
```

---

### ✅ DO: Use Different Log Levels

```lua
-- Logging framework
local LOG = {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    level = 1  -- Set min level to display
}

function LOG:debug(msg, ...)
    if self.level <= self.DEBUG then
        print(string.format("[DEBUG] " .. msg, ...))
    end
end

function LOG:info(msg, ...)
    if self.level <= self.INFO then
        print(string.format("[INFO] " .. msg, ...))
    end
end

function LOG:warn(msg, ...)
    if self.level <= self.WARN then
        print(string.format("[WARN] " .. msg, ...))
    end
end

function LOG:error(msg, ...)
    if self.level <= self.ERROR then
        print(string.format("[ERROR] " .. msg, ...))
    end
end

-- Usage
LOG:debug("Entity %d spawned at (%.1f, %.1f)", entity.id, entity.x, entity.y)
LOG:warn("Unit health low: %d", unit.hp)
LOG:error("Save file corrupted!")
```

---

### ✅ DO: Guard Against Side Effects in Debug Code

```lua
-- BAD: Debug code affects logic
if love.keyboard.isDown("d") then
    print(variable)  -- Tiny lag spike
    performance = false
end

-- GOOD: Separate debug mode
local DEBUG_MODE = false  -- Set once, leave for session

if DEBUG_MODE then
    printDebugInfo()  -- Safe to call frequently
end

-- Or even better: only when needed
local showDebug = false

function love.keypressed(key)
    if key == "d" then
        showDebug = not showDebug  -- Toggle on key
    end
end

function love.draw()
    if showDebug then
        drawDebugOverlay()
    end
end
```

---

## Console Output Analysis

### ✅ DO: Read Error Messages Carefully

```
Error message:
"attempt to call a nil value"

Don't stop here! Read more carefully:
"attempt to call a nil value (field 'update')"
stack traceback:
    engine/entity.lua:45: in function 'updateEntity'
    engine/battle.lua:120: in function 'updateBattle'
    main.lua:78: in function 'love.update'

Root cause: entity.update is nil
Location: entity.lua line 45 (function updateEntity)
Called from: battle.lua line 120
```

**Process:**
1. What's the error? (nil value)
2. What is nil? (entity.update)
3. Where did it happen? (entity.lua:45)
4. Why would it be nil? (entity not properly initialized)

---

### ✅ DO: Capture Stack Traces

```lua
-- In love.run or at game start
local function errorhandler(msg)
    msg = tostring(msg)
    
    local trace = debug.traceback("", 2)
    
    -- Log to file for later analysis
    local file = io.open("error.log", "a")
    if file then
        file:write(os.date("%Y-%m-%d %H:%M:%S") .. " ERROR\n")
        file:write(msg .. "\n")
        file:write(trace .. "\n")
        file:write("---\n")
        file:close()
    end
    
    print(msg)
    print(trace)
end

-- Use it
if not pcall(riskyFunction) then
    errorhandler("Something went wrong")
end
```

---

## Breakpoint & Step Debugging

### ✅ DO: Use Love2D Debugger Extension

For VS Code:

```json
// .vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "LÖVE",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/engine",
            "cwd": "${workspaceFolder}",
            "stopOnEntry": false,
            "console": "integratedTerminal"
        }
    ]
}
```

**Usage:**
- Click line number to set breakpoint
- F5 to start debugging
- Step over/into/out with F10/F11
- Inspect variables in debug console

---

### ✅ DO: Strategic Breakpoint Placement

```lua
-- Set breakpoint at function entry to trace calls
function updateEntity(entity, dt)
    -- Breakpoint here to see when called
    
    -- Then step through logic
    entity.x = entity.x + entity.vx * dt  -- Step into
    entity.y = entity.y + entity.vy * dt  -- Step into
    
    if entity.active then  -- Step over (conditional)
        updateEntity(entity)
    end
end
```

---

## Memory Debugging

### ✅ DO: Monitor Memory Leaks

```lua
-- Memory leak detector
local MemoryMonitor = {}

function MemoryMonitor.start()
    MemoryMonitor.baseline = collectgarbage("count") / 1024  -- MB
    MemoryMonitor.peak = MemoryMonitor.baseline
    MemoryMonitor.history = {}
end

function MemoryMonitor.sample()
    local current = collectgarbage("count") / 1024  -- MB
    local delta = current - MemoryMonitor.baseline
    
    table.insert(MemoryMonitor.history, {
        time = love.timer.getTime(),
        current = current,
        delta = delta
    })
    
    MemoryMonitor.peak = math.max(MemoryMonitor.peak, current)
    
    -- Alert if growing
    if delta > 100 then  -- > 100 MB over baseline
        print(string.format(
            "[WARN] Memory leak suspected: +%.1f MB (peak: %.1f MB)",
            delta,
            MemoryMonitor.peak
        ))
    end
end

-- In love.draw()
MemoryMonitor.sample()
```

---

### ✅ DO: Find Memory Leaks Systematically

```markdown
## Memory Leak Investigation

### Step 1: Confirm It's a Leak
- Baseline memory: 150 MB
- After 1 hour gameplay: 450 MB
- After restarting level: Still 450 MB
- Conclusion: YES, memory leak (doesn't reset)

### Step 2: Narrow Down System
- Disable AI system: Still leaks
- Disable particles: Still leaks
- Disable UI: Leak gone!
- Conclusion: Leak is in UI system

### Step 3: Find Exact Location
- UI main loop: Allocates 2 MB/min ✓ LEAK
- Widget creation: 0.1 MB/min (ok)
- Rendering: 0.05 MB/min (ok)
- Conclusion: Main loop creates objects

### Step 4: Find Root Cause
Code: `for i = 1, 1000 do table.insert(buttons, {}) end`
Problem: `table.insert()` called in every frame!
Solution: Create buttons once, reuse them
```

---

## Performance Debugging

### ✅ DO: Profile to Find Bottleneck

```lua
-- Profiler
local profiler = {
    marks = {},
    results = {}
}

function profiler:start(label)
    self.marks[label] = love.timer.getTime()
end

function profiler:stop(label)
    if self.marks[label] then
        local elapsed = love.timer.getTime() - self.marks[label]
        if not self.results[label] then
            self.results[label] = {total = 0, count = 0}
        end
        self.results[label].total = self.results[label].total + elapsed
        self.results[label].count = self.results[label].count + 1
        self.marks[label] = nil
    end
end

function profiler:report()
    print("\n=== PROFILE REPORT ===")
    for label, stats in pairs(self.results) do
        print(string.format(
            "%s: %.2fms avg (%.2fms total, %d calls)",
            label,
            (stats.total / stats.count) * 1000,
            stats.total * 1000,
            stats.count
        ))
    end
end

-- Usage
function love.update(dt)
    profiler:start("update_entities")
    updateEntities(dt)
    profiler:stop("update_entities")
    
    profiler:start("update_ai")
    updateAI(dt)
    profiler:stop("update_ai")
end

function love.draw()
    profiler:report()  -- Shows results
end
```

---

## Logic Errors

### ✅ DO: Check Boundary Conditions

**Off-by-one errors are common:**

```lua
-- BAD: Off-by-one in loop
for i = 0, #entities do  -- includes one past end!
    if entities[i] then  -- entities[0] doesn't exist
        updateEntity(entities[i])
    end
end

-- GOOD: Correct bounds
for i = 1, #entities do  -- Lua tables start at 1
    updateEntity(entities[i])
end

-- Or use pairs/ipairs
for i, entity in ipairs(entities) do
    updateEntity(entity)
end
```

---

### ✅ DO: Test Edge Cases

```lua
-- Test function with edge cases
function clamp(value, min, max)
    -- Boundary cases
    assert(clamp(5, 0, 10) == 5, "Normal value")
    assert(clamp(-1, 0, 10) == 0, "Below min")
    assert(clamp(15, 0, 10) == 10, "Above max")
    assert(clamp(0, 0, 10) == 0, "Min value")
    assert(clamp(10, 0, 10) == 10, "Max value")
    
    -- Implementation
    return math.max(min, math.min(max, value))
end
```

---

## Race Conditions & Concurrency

### ✅ DO: Identify Timing Dependencies

```lua
-- Problematic: Depends on callback order
function setupGame()
    loadAssets()        -- 1000ms
    initializeAI()      -- Assumes assets loaded
    startBattle()       -- Assumes AI initialized
end

-- Issue: If loadAssets is slow, initializeAI might run early

-- Better: Explicit dependencies
function setupGame()
    loadAssets()
    assert(assetsLoaded, "Assets must load first")
    
    initializeAI()
    assert(AIInitialized, "AI must initialize first")
    
    startBattle()
end
```

---

## Love2D-Specific Debugging

### ✅ DO: Use Love2D Debug Mode

```lua
-- In conf.lua
function love.conf(t)
    t.console = true  -- Enable debug console
    t.window.vsync = 0  -- Disable vsync for frame analysis
end

-- Console output visible automatically on Windows
-- On Mac/Linux, run: lovec engine
```

---

### ✅ DO: Use Statistics API

```lua
function love.draw()
    local stats = love.graphics.getStats()
    
    love.graphics.print("Draw calls: " .. stats.drawcalls, 10, 10)
    love.graphics.print("Memory: " .. math.ceil(collectgarbage("count")/1024) .. " MB", 10, 30)
    
    -- Check for anomalies
    if stats.drawcalls > 500 then
        print("[WARN] High draw call count!")
    end
end
```

---

## Crash Analysis

### ✅ DO: Analyze Crashes with Stack Traces

```
Crash error:
"attempt to index a nil value (field 'vx')"

Stack trace shows:
- main.lua:78: love.update(dt)
- engine/battle.lua:120: updateBattle()
- engine/entity.lua:45: updateEntity(entity)

Analysis:
- Line 45 in entity.lua tries to access `entity.vx`
- But entity is nil
- Check where entity comes from (battle.lua:120)

Root cause: Entity wasn't initialized before update
```

---

### ✅ DO: Create Crash Report Format

```markdown
# Crash Report Template

## Crash Details
- **Error Message:** [Copy exact error]
- **Time of Crash:** [When it happened]
- **Reproducibility:** [Always / Sometimes / Once]

## Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Crash occurs]

## Stack Trace
[Paste complete stack trace]

## Environment
- Love2D version: [version]
- OS: [Windows/Mac/Linux]
- GPU: [if applicable]

## Expected Behavior
[What should have happened]

## Additional Information
[Screenshots, logs, etc.]
```

---

## Debugging Common Game Issues

### ✅ DO: Systematic Approach for Common Issues

**Issue: "Game runs slow during battles"**

```markdown
## Investigation Steps

### 1. Is it consistent?
- Yes: Memory leak or bottleneck
- No: Random slowdowns (GC or network?)

### 2. Profile the issue
- Entity updates taking too long?
- Draw calls too high?
- Memory usage growing?

### 3. Isolate cause
- Disable entity AI: Faster? → AI issue
- Reduce entity count: Faster? → Scaling issue
- Lower graphics settings: Faster? → GPU issue

### 4. Root cause
- Profiler shows AI taking 50ms per frame
- Each unit checks 100 other units: O(n²)
- Solution: Use spatial partitioning (quadtree)
```

---

## Creating Minimal Reproducible Examples

### ✅ DO: Isolate Problem Code

```lua
-- Problem: "Units get stuck pathing in corners"

-- BAD: Send entire game/entity system
-- (Too much code, hard to debug)

-- GOOD: Minimal reproducible example
local quadtree = require("engine/pathfinding/quadtree")
local pathfinder = require("engine/pathfinding/pathfinder")

-- Create minimal map with corner
local map = {
    {0, 0, 0},
    {0, 1, 0},  -- Wall in corner
    {0, 0, 0}
}

-- Try pathfinding
local path = pathfinder.findPath(map, {1, 1}, {3, 3})
print("Path found:", path)  -- Should handle corner correctly

-- This small example can be shared and debugged easily
```

---

## Documentation & Learning from Bugs

### ✅ DO: Log Bugs for Learning

```markdown
# Bug Log: Pathfinding Corner Case

## Date Discovered
2025-10-16

## Description
Units sometimes get stuck in certain corners, unable to path around walls.

## Root Cause
Pathfinding used depth-first search, which could get stuck in dead ends
when exploring corners due to wall configuration.

## Solution
Switched to A* pathfinding algorithm with better heuristic.
Kept DFS as fallback for performance in simple areas.

## Prevention
- Created regression tests for corner cases
- Added visual debugging mode for pathfinding
- Document pathfinding assumptions in code

## Time to Fix
- Investigation: 2 hours
- Implementation: 3 hours
- Testing: 1 hour
- Total: 6 hours

## Key Learnings
1. Visualization makes pathfinding bugs obvious
2. A* better than DFS for maze-like environments
3. Regression tests would have caught this immediately
```

---

## Debugging Checklist

- [ ] Can you reproduce the bug consistently?
- [ ] Have you read the error message carefully?
- [ ] Have you checked the stack trace?
- [ ] Have you printed key variables?
- [ ] Have you narrowed down the location with binary search?
- [ ] Have you tested edge cases?
- [ ] Have you checked memory usage?
- [ ] Have you profiled the code?
- [ ] Have you created minimal reproducible example?
- [ ] Have you documented the bug and fix?

---

## References

- Debugging: https://gameprogrammingpatterns.com/
- Love2D Debugging: https://love2d.org/wiki/Getting_Started
- Profiling: https://en.wikipedia.org/wiki/Profiling_(computer_programming)
- Crash Analysis: https://en.wikipedia.org/wiki/Stack_trace

