# AlienFall Troubleshooting Guide

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Common issues and solutions for AlienFall development.

---

## Table of Contents

- [Setup Issues](#setup-issues)
- [Runtime Issues](#runtime-issues)
- [Performance Issues](#performance-issues)
- [Game Logic Issues](#game-logic-issues)
- [Getting Help](#getting-help)

---

## Setup Issues

### Issue: "love.exe not found"

**Problem**: Running game fails with "love.exe not found" or "lovec not recognized"

**Solutions**:
1. **Check installation**: Verify `C:\Program Files\LOVE\` exists
2. **Restart terminal**: PATH changes require terminal restart
3. **Use full path**: `"C:\Program Files\LOVE\lovec.exe" "engine"`
4. **Reinstall Love2D**: If still fails, uninstall and reinstall Love2D

---

## Runtime Issues

### Issue: Game crashes immediately

**Problem**: Love2D window opens then closes, no error visible

**Solutions**:
1. **Run with console**: Use `lovec` not `love` to see errors
2. **Check main.lua**: Verify syntax is correct (Lua syntax error?)
3. **Check conf.lua**: Configuration errors prevent startup
4. **Review console output**: Look for `[ERROR]` messages

### Issue: "Module not found"

**Problem**: Console shows `error: modules/xxx.lua not found`

**Solutions**:
1. **Check file exists**: Verify the file exists at path
2. **Check path**: Ensure `require("core.module")` matches file location
3. **Use forward slashes**: `require("path/to/module")` not `require("path\to\module")`
4. **No file extension**: Don't use `.lua` in require: `require("module")` not `require("module.lua")`

### Issue: Nil reference error

**Problem**: Console shows `attempt to index a nil value`

**Solutions**:
1. **Add nil checks**: Always check before using objects
   ```lua
   if object then
       object.property = value
   end
   ```
2. **Add debug prints**: Print values before using them
   ```lua
   print("[Debug] object = " .. tostring(object))
   ```
3. **Check initialization**: Verify all objects are initialized
4. **Look at stack trace**: Identifies exact line with error

### Issue: Game doesn't respond to input

**Problem**: Game runs but keyboard/mouse don't work

**Solutions**:
1. **Check focus**: Game window must have focus (click on it)
2. **Check keypressed function**: Verify `love.keypressed` is defined
3. **Check state implementation**: Current state must implement `keypressed`
4. **Debug with prints**: Add `print` in keypressed to verify it's called

---

## Performance Issues

### Issue: Game runs slow (low FPS)

**Problem**: Game lags, FPS counter shows <60

**Solutions**:
1. **Check update function**: Look for heavy computations
2. **Profile loops**: Add timing around expensive operations
   ```lua
   local start = love.timer.getTime()
   -- Expensive operation
   local elapsed = (love.timer.getTime() - start) * 1000
   print(string.format("Operation took: %.2f ms", elapsed))
   ```
3. **Reduce draw calls**: Combine renders into single call
4. **Use love profiler**: See PERFORMANCE.md for profiling tools
5. **Check for infinite loops**: Look for loops without breaks

### Issue: Memory usage grows (memory leak)

**Problem**: Game starts fine but gets slower over time

**Solutions**:
1. **Monitor memory**: Print memory usage each frame
   ```lua
   local mem = collectgarbage("count")
   if frameCount % 60 == 0 then  -- Every 1 second
       print(string.format("[Mem] %.2f KB", mem))
   end
   ```
2. **Check for unreleased resources**: Verify images/sounds freed
3. **Look for circular references**: Objects referencing each other
4. **Force garbage collection**: Call `collectgarbage()` periodically
5. **Profile memory**: Record memory over time to find leak point

---

## Game Logic Issues

### Issue: Unit doesn't move

**Problem**: Selected unit doesn't move to destination

**Debug Steps**:
1. Check if unit is selected
   ```lua
   print("[Debug] Selected unit: " .. tostring(selectedUnit))
   ```
2. Check if destination is set
   ```lua
   print("[Debug] Destination: " .. tostring(destination))
   ```
3. Check pathfinding
   ```lua
   local path = findPath(unit.position, destination)
   print("[Debug] Path length: " .. #path)
   ```
4. Check movement points
   ```lua
   print("[Debug] AP: " .. unit.action_points)
   ```

### Issue: Accuracy calculation wrong

**Problem**: Shots have wrong accuracy

**Debug**:
1. Print all factors in calculation
   ```lua
   print("[Accuracy] Base: " .. base_accuracy)
   print("[Accuracy] Distance: " .. distance_mod)
   print("[Accuracy] Cover: " .. cover_mod)
   print("[Accuracy] Final: " .. final_accuracy)
   ```
2. Compare to expected values from design doc
3. Verify formula matches design
4. Check for operator precedence errors

### Issue: Wrong damage amount

**Problem**: Damage doesn't match expected value

**Debug**:
1. Print attacker stats
   ```lua
   print("[Damage] Attacker HP: " .. attacker.damage)
   ```
2. Print defender armor
   ```lua
   print("[Damage] Armor: " .. defender.armor)
   ```
3. Print intermediate calculations
   ```lua
   local base = attacker.damage - defender.armor
   local multiplier = 1.0 + (attacker.strength / 100)
   print("[Damage] Base: " .. base .. ", Multiplier: " .. multiplier)
   ```
4. Verify formula order

---

## Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `attempt to index a nil value` | Using `.` on nil | Check value is not nil |
| `attempt to call a nil value` | Function doesn't exist | Check function name |
| `bad argument #1 to 'xxx'` | Wrong parameter type | Check parameter types |
| `table index is nil` | Key doesn't exist | Check table has key |
| `attempt to perform arithmetic on a nil value` | Math with nil | Initialize variables |

---

## Debugging Workflow

When something breaks:

1. **Run with console**: `lovec "engine"`
2. **Look for [ERROR] messages**: Likely cause visible
3. **Add print statements**: Narrow down problem area
4. **Check variable values**: Are they what you expect?
5. **Verify assumptions**: Does code match design?
6. **Isolate the problem**: Disable parts to find root cause
7. **Review related code**: Look for recent changes

---

## Getting Help

**If you're stuck**:

1. **Check this guide**: Search for your issue
2. **Read Debugging Guide**: [DEBUGGING.md](developers/DEBUGGING.md)
3. **Review relevant code**: Look at similar working features
4. **Ask a teammate**: Explain what you've tried
5. **Search documentation**: Use [Navigation Guide](NAVIGATION.md)

---

## Related Documentation

- **[Debugging Guide](developers/DEBUGGING.md)** - Detailed debugging techniques
- **[Setup Guide](developers/SETUP_WINDOWS.md)** - Installation help
- **[Workflow Guide](developers/WORKFLOW.md)** - Development process
- **[Code Standards](CODE_STANDARDS.md)** - Best practices

---

**Last Updated**: October 2025 | **Status**: Active

