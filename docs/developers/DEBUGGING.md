# AlienFall Debugging Guide

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Comprehensive guide to debugging AlienFall using Love2D console, print statements, and debugging techniques.

---

## Table of Contents

- [Overview](#overview)
- [Setting Up Console](#setting-up-console)
- [Print Statements](#print-statements)
- [Common Debugging Scenarios](#common-debugging-scenarios)
- [Console Commands](#console-commands)
- [Profiling & Performance](#profiling--performance)
- [Visual Debugging](#visual-debugging)
- [Error Messages](#error-messages)
- [Debugging Checklist](#debugging-checklist)

---

## Overview

**Key Principle**: The Love2D console is your primary debugging tool for AlienFall.

**Why console-based debugging?**
- No IDE debugger needed
- Works on all platforms consistently
- Outputs to dedicated window separate from game
- Perfect for turn-based game development

**Console is enabled in**: `engine/conf.lua`

```lua
t.console = true  -- Console window on Windows
```

---

## Setting Up Console

### Verify Console is Enabled

Open `engine/conf.lua` and check:

```lua
function love.conf(t)
    t.console = true  -- This should be true
    -- ... other config
end
```

### Run with Console Enabled

Use `lovec` instead of `love` to enable console:

```powershell
# Correct - console enabled
lovec "engine"

# Wrong - no console
love "engine"
```

### Console Behavior

**Windows**:
- Console window opens as separate window
- Closes when game closes
- Shows all print output and errors
- Can be resized and scrolled

**Linux/Mac**:
- Console output prints to terminal
- Run game from terminal to see output

---

## Print Statements

### Print Statement Format

Use consistent format for debugging output:

```lua
print("[ModuleName] Message: " .. tostring(value))
```

### Standard Prefix Categories

```lua
-- Initialization
print("[Core] Engine initializing...")
print("[StateManager] Loading state...")
print("[AssetManager] Loading assets...")

-- Game flow
print("[Battle] Combat started")
print("[Geoscape] Player moved to province X")
print("[Basescape] Base expanded")

-- Debugging
print("[DEBUG] Variable value: " .. tostring(var))
print("[DEBUG] Function called with args: " .. table.concat(args, ", "))

-- Warnings and errors
print("[WARN] This might be a problem")
print("[ERROR] Critical issue: " .. error_msg)

-- Performance
print("[PERF] Operation took: " .. elapsed_time .. "ms")

-- AI/Decisions
print("[AI] Decision: attack unit at " .. target.x .. "," .. target.y)
print("[Strategy] Evaluating " .. num_options .. " options")
```

### Conditional Debugging

Use debug flags to control output verbosity:

```lua
-- In a core module
local DEBUG = true  -- Toggle to enable/disable

if DEBUG then
    print("[ModuleName] Detailed debug info...")
end

-- Or per-system:
local DEBUG_MOVEMENT = true
local DEBUG_LOS = false

if DEBUG_MOVEMENT then
    print("[Movement] Unit moved to new hex")
end
```

### Safe Printing

Handle edge cases when printing:

```lua
-- Good - safe even if value is nil
print("[Debug] Result: " .. tostring(result))

-- Good - works with tables
print("[Debug] Table: " .. table.tostring(my_table))

-- Avoid - crashes if nil
-- print("[Debug] Result: " .. result)  -- ERROR if result is nil

-- Good - check before printing
if value then
    print("[Debug] Value: " .. value)
else
    print("[Debug] Value is nil")
end

-- Good - format strings
print(string.format("[Debug] Damage: %.2f, Accuracy: %d%%", damage, accuracy))
```

---

## Common Debugging Scenarios

### Scenario 1: Game Crashes Immediately

**Symptom**: Love2D window closes immediately, console shows error.

**Debugging**:
1. Run with: `lovec "engine"` to capture console output
2. Look for `[ERROR]` lines in console
3. Note the stack trace (file and line number)
4. Check the mentioned file for issues

**Example console output**:
```
[ERROR] main.lua:15: attempt to index a nil value (global 'game')
stack traceback:
    main.lua:15: in function 'love.update'
```

**Fix**: Go to `main.lua` line 15 and check that `game` exists before using it.

### Scenario 2: Feature Not Working

**Symptom**: Feature should work but doesn't.

**Debugging**:
1. Add print statements at key points:
   ```lua
   -- Before the feature logic
   print("[Feature] Feature triggered")
   
   -- Inside the logic
   print("[Feature] Processing step 1")
   print("[Feature] Value: " .. tostring(value))
   
   -- After completion
   print("[Feature] Feature complete")
   ```

2. Run game and check console for output
3. If first print doesn't show, feature isn't being called
4. Add prints progressively to find where execution stops

### Scenario 3: Wrong Values/Results

**Symptom**: Feature runs but produces wrong output.

**Debugging**:
1. Add print statements showing actual values:
   ```lua
   print("[Combat] Calculating accuracy")
   print("[Combat] Base accuracy: " .. base_accuracy)
   print("[Combat] Distance: " .. distance)
   print("[Combat] Cover modifier: " .. cover_mod)
   
   local final = base_accuracy + distance + cover_mod
   print("[Combat] Final accuracy: " .. final)
   ```

2. Compare values to expected values
3. Identify which calculation is wrong
4. Fix the formula or data

### Scenario 4: Infinite Loop / Game Hangs

**Symptom**: Game starts but freezes, no response to input.

**Debugging**:
1. Add print before and after loops:
   ```lua
   print("[Loop] Starting loop")
   for i = 1, items do
       if i % 100 == 0 then  -- Print every 100 iterations
           print("[Loop] Iteration " .. i)
       end
   end
   print("[Loop] Loop complete")
   ```

2. Look for missing loop conditions
3. Check for functions that don't return

4. Add `break` statements if needed as workaround

### Scenario 5: Memory Leak

**Symptom**: Game runs but gets progressively slower over time.

**Debugging**:
1. Use console to track memory:
   ```lua
   local mem = collectgarbage("count")
   print(string.format("[Memory] Current usage: %.2f KB", mem))
   ```

2. Call during game loop to track memory growth
3. Look for objects that aren't being freed
4. Check for circular references between objects

---

## Console Commands

### Runtime Checks

In the game code, add checks that print diagnostics:

```lua
-- Check if object exists
function assertExists(obj, name)
    if not obj then
        error("[Assert] Missing: " .. (name or "unknown"))
    end
end

-- Check valid value
function assertValid(value, min, max, name)
    if value < min or value > max then
        print(string.format(
            "[Assert] Invalid %s: %.2f (should be %.2f-%.2f)",
            name, value, min, max
        ))
    end
end

-- Usage
assertExists(playerUnit, "player unit")
assertValid(damage, 1, 100, "damage")
```

### Dumping Tables

Create a function to display table contents:

```lua
function dumpTable(t, indent, visited)
    indent = indent or 0
    visited = visited or {}
    
    if visited[t] then return end  -- Prevent cycles
    visited[t] = true
    
    local prefix = string.rep("  ", indent)
    
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(prefix .. key .. " = {")
            dumpTable(value, indent + 1, visited)
            print(prefix .. "}")
        else
            print(string.format(
                "%s%s = %s (%s)",
                prefix, key, tostring(value), type(value)
            ))
        end
    end
end

-- Usage
print("[Debug] Unit structure:")
dumpTable(unit)
```

### State Tracking

Monitor state transitions:

```lua
function setGameState(newState)
    if newState ~= currentState then
        print(string.format(
            "[StateManager] Transition: %s -> %s",
            currentState, newState
        ))
    end
    currentState = newState
end
```

---

## Profiling & Performance

### Simple Performance Measurement

Measure how long operations take:

```lua
local startTime = love.timer.getTime()

-- Do something
doExpensiveOperation()

local elapsed = (love.timer.getTime() - startTime) * 1000
print(string.format("[Perf] Operation took: %.2f ms", elapsed))
```

### Performance Profiling

Create a profiler for systematic analysis:

```lua
local Profiler = {}

function Profiler.start(label)
    if not profiler then profiler = {} end
    profiler[label] = {
        startTime = love.timer.getTime(),
        startMem = collectgarbage("count")
    }
end

function Profiler.end_profile(label)
    if not profiler or not profiler[label] then return end
    
    local data = profiler[label]
    local elapsed = (love.timer.getTime() - data.startTime) * 1000
    local memUsed = collectgarbage("count") - data.startMem
    
    print(string.format(
        "[Perf] %s: %.2f ms, +%.2f KB",
        label, elapsed, memUsed
    ))
    
    profiler[label] = nil
end

-- Usage
Profiler.start("pathfinding")
calculatePath()
Profiler.end_profile("pathfinding")
```

### Frame Rate Monitoring

Track FPS to identify performance issues:

```lua
function love.update(dt)
    -- Track FPS
    if frameCount == 0 then
        lastSecond = love.timer.getTime()
    end
    frameCount = frameCount + 1
    
    if love.timer.getTime() - lastSecond >= 1 then
        print(string.format("[Perf] FPS: %d", frameCount))
        frameCount = 0
    end
    
    -- ... game update
end
```

---

## Visual Debugging

### On-Screen Debug Display

Draw debug info directly on screen:

```lua
function love.draw()
    -- ... normal drawing
    
    -- Debug display (top-left corner)
    if DEBUG_DRAW then
        love.graphics.setColor(1, 1, 1)  -- White
        love.graphics.setFont(debugFont)
        
        love.graphics.print("Mouse: " .. love.mouse.getX() .. "," .. love.mouse.getY(), 10, 10)
        love.graphics.print("State: " .. gameState, 10, 30)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 50)
        
        -- Draw selection box
        if selectedUnit then
            drawDebugBox(selectedUnit.x, selectedUnit.y)
        end
    end
end

function drawDebugBox(x, y)
    love.graphics.setColor(1, 0, 0, 0.5)  -- Red, semi-transparent
    love.graphics.rectangle("line", x - 10, y - 10, 20, 20)
end
```

### Draw Grid for Battlescape

Visualize hex grid for debugging:

```lua
function drawDebugGrid()
    if not DEBUG_GRID then return end
    
    love.graphics.setColor(0.5, 0.5, 0.5, 0.3)  -- Gray, transparent
    
    local hexSize = 16  -- pixels
    for x = 0, love.graphics.getWidth(), hexSize * 2 do
        for y = 0, love.graphics.getHeight(), hexSize * 2 do
            love.graphics.circle("line", x, y, hexSize)
        end
    end
end
```

### Draw Line of Sight

Visualize LOS calculations:

```lua
function drawLineOfSight(unit)
    if not DEBUG_LOS then return end
    
    love.graphics.setColor(0, 1, 0, 0.3)  -- Green, transparent
    
    for target in pairs(visibleUnits) do
        love.graphics.line(unit.x, unit.y, target.x, target.y)
    end
end
```

---

## Error Messages

### Common Error Types

| Error | Cause | Fix |
|-------|-------|-----|
| `attempt to index a nil value` | Using `.` on nil | Check value before use |
| `attempt to call a nil value` | Function doesn't exist | Check function name |
| `bad argument #1 to 'xxx'` | Wrong parameter type | Check parameter types |
| `table index is nil` | Accessing non-existent table key | Check table structure |
| `attempt to perform arithmetic on a nil value` | Math operation on nil | Initialize variables |

### Reading Stack Traces

When an error occurs, console shows:

```
[ERROR] modules/battlescape/units.lua:42: attempt to index a nil value (global 'battleState')
stack traceback:
    [C]: in function 'assert'
    modules/battlescape/units.lua:42: in function 'updateUnit'
    modules/battlescape/battle.lua:55: in function 'update'
    main.lua:15: in function 'love.update'
```

**How to read**:
1. Error is on line 42 of `units.lua`
2. Called from `battle.lua` line 55
3. Which was called from `main.lua` line 15
4. Start fixing from line 42

---

## Debugging Checklist

**When debugging, follow this checklist**:

- [ ] Run with `lovec "engine"` (console enabled)
- [ ] Check console for `[ERROR]` messages
- [ ] Verify all required files exist and load
- [ ] Add print statements at key points
- [ ] Check that variables aren't nil before using
- [ ] Verify loop conditions and iterations
- [ ] Monitor memory usage and performance
- [ ] Visualize data with on-screen debug display
- [ ] Check for circular dependencies
- [ ] Test with different input values
- [ ] Verify game state is correct

---

## Advanced Techniques

### Breakpoint-Style Debugging

Pause execution for investigation:

```lua
function breakpoint(message)
    print("[BREAKPOINT] " .. message)
    print("[BREAKPOINT] Paused. Press 'p' to continue...")
    
    paused = true
end

function love.keypressed(key)
    if key == "p" and paused then
        paused = false
        print("[BREAKPOINT] Resumed")
    end
end
```

### Post-Mortem Debugging

Capture state before crash:

```lua
function saveGameState()
    local state = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        gameState = currentState,
        unitsCount = countUnits(),
        memory = collectgarbage("count"),
        -- ... more state
    }
    
    local json = serializeToJson(state)  -- Your JSON function
    local file = io.open("debug_state.json", "w")
    file:write(json)
    file:close()
    
    print("[Debug] State saved to debug_state.json")
end

-- Call before risky operations
saveGameState()
```

---

## Related Documentation

- **[Setup Guide](SETUP_WINDOWS.md)** - Getting Love2D running
- **[Workflow Guide](WORKFLOW.md)** - Git workflow for commits
- **[Code Standards](../CODE_STANDARDS.md)** - Code quality
- **[Troubleshooting](TROUBLESHOOTING.md)** - More help
- **[Love2D Docs](https://love2d.org/wiki/Main_Page)** - Framework reference

---

**Last Updated**: October 2025 | **Status**: Active | **Difficulty**: Intermediate

