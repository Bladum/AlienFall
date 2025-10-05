# Integration Debugging Guide

**Tags:** #debugging #integration #troubleshooting #technical  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Anti_Patterns]], [[Mission_Lifecycle]]

---

## Quick Debugging Checklist

### System Won't Load
- [ ] Check console for Lua errors
- [ ] Verify TOML syntax is valid
- [ ] Confirm all required files exist
- [ ] Check file paths (case-sensitive on Linux)
- [ ] Validate ServiceLocator has required services

### Mission Won't Start
- [ ] Mission data file exists and valid
- [ ] All prerequisites met (research, story flags)
- [ ] Map blocks referenced exist
- [ ] Enemy units defined and valid
- [ ] Spawn points within map boundaries

### Combat Issues
- [ ] Units have valid AI behavior assigned
- [ ] Pathfinding grid generated correctly
- [ ] LOS data computed
- [ ] Weapon data valid (damage, range, etc.)
- [ ] Turn order system initialized

### Performance Problems
- [ ] Profile with F3 debug overlay
- [ ] Check draw call count
- [ ] Monitor memory usage
- [ ] Verify asset loading is async
- [ ] Check for infinite loops in update()

### Save/Load Broken
- [ ] State is serializable (no functions/metatables)
- [ ] Version compatibility checked
- [ ] All systems registered for serialization
- [ ] Mods don't conflict with save data

---

## Common Integration Errors

### Error: "Attempt to index nil value"
**Symptom:** `attempt to index a nil value (field 'X')`

**Causes:**
1. Service not registered in ServiceLocator
2. Entity ID doesn't exist
3. Component not attached to entity
4. Data file failed to load

**Debug Steps:**
```lua
-- Add debug output
print("Entity:", entity)
print("Component:", entity and entity.position)

-- Check if service exists
local service = ServiceLocator:get("unit_manager")
if not service then
    error("unit_manager service not registered!")
end
```

---

### Error: "Stack Overflow"
**Symptom:** Game crashes with stack overflow

**Causes:**
1. Infinite recursion
2. Circular event loop
3. Recursive require() calls

**Debug Steps:**
```lua
-- Add recursion guard
local depth = 0
function recursiveFunction()
    depth = depth + 1
    if depth > 100 then
        error("Recursion depth exceeded: " .. debug.traceback())
    end
    -- Function body
    depth = depth - 1
end
```

---

### Error: "Bad argument to 'X'"
**Symptom:** `bad argument #2 to 'X' (number expected, got nil)`

**Causes:**
1. Missing parameter
2. Wrong data type
3. Failed calculation returned nil

**Debug Steps:**
```lua
-- Validate parameters
function calculateDamage(base_damage, armor)
    assert(type(base_damage) == "number", "base_damage must be number")
    assert(type(armor) == "number", "armor must be number")
    
    return math.max(0, base_damage - armor)
end
```

---

## System-Specific Debugging

### Mission System

**Problem:** Mission doesn't appear on geoscape

**Check:**
```lua
-- Verify mission generation
function debugMissionGeneration()
    local missions = self.mission_manager:getActiveMissions()
    print("Active missions:", #missions)
    
    for _, mission in ipairs(missions) do
        print("Mission:", mission.id, mission.type, mission.location)
    end
end
```

**Problem:** Mission loads but no enemies spawn

**Check:**
```lua
-- Debug enemy spawning
function debugEnemySpawns(mission)
    print("Enemy groups:", #mission.enemy_groups)
    
    for _, group in ipairs(mission.enemy_groups) do
        print("Group:", group.id, "Count:", #group.units)
        for _, unit in ipairs(group.units) do
            print("  Unit:", unit.type, "Position:", unit.spawn_pos)
        end
    end
end
```

---

### Combat System

**Problem:** Units can't move or attack

**Check:**
```lua
-- Debug action points
function debugUnitAP(unit)
    print("Unit:", unit.id)
    print("Current AP:", unit.action_points)
    print("Max AP:", unit.max_action_points)
    print("Can act:", unit:canAct())
end

-- Debug pathfinding
function debugPathfinding(unit, target_pos)
    local path = self.pathfinder:findPath(unit.position, target_pos)
    
    if not path then
        print("No path found!")
        print("Start:", unit.position)
        print("End:", target_pos)
        
        -- Check if target is walkable
        local tile = self.map:getTile(target_pos)
        print("Target walkable:", tile.walkable)
    else
        print("Path length:", #path)
    end
end
```

**Problem:** Weapons don't fire

**Check:**
```lua
-- Debug weapon system
function debugWeapon(unit)
    local weapon = unit:getEquippedWeapon()
    
    if not weapon then
        print("No weapon equipped!")
        return
    end
    
    print("Weapon:", weapon.id)
    print("Ammo:", weapon.current_ammo, "/", weapon.max_ammo)
    print("Can fire:", weapon:canFire())
    print("AP cost:", weapon.ap_cost)
    print("Unit AP:", unit.action_points)
end
```

---

### Economy System

**Problem:** Can't build/research items

**Check:**
```lua
-- Debug prerequisites
function debugPrerequisites(item_id)
    local item = self.data:getItem(item_id)
    
    print("Item:", item_id)
    print("Research required:", item.research_required)
    
    if item.research_required then
        local completed = self.research:isCompleted(item.research_required)
        print("Research completed:", completed)
    end
    
    print("Cost:", item.cost)
    print("Player money:", self.economy:getMoney())
    print("Can afford:", self.economy:canAfford(item.cost))
end
```

---

## Performance Debugging

### FPS Drops

**Enable profiling:**
```lua
-- Add to conf.lua
function love.conf(t)
    t.console = true  -- Enable console
end

-- In main.lua
function love.keypressed(key)
    if key == "f3" then
        DEBUG_MODE = not DEBUG_MODE
    end
end

function love.draw()
    -- Your rendering
    
    if DEBUG_MODE then
        local stats = love.graphics.getStats()
        love.graphics.print(string.format(
            "FPS: %d\nDraw Calls: %d\nTexture Memory: %.2f MB",
            love.timer.getFPS(),
            stats.drawcalls,
            stats.texturememory / 1024 / 1024
        ), 10, 10)
    end
end
```

**Profile hot paths:**
```lua
local Profiler = {}

function Profiler:start(label)
    self.timers = self.timers or {}
    self.timers[label] = love.timer.getTime()
end

function Profiler:stop(label)
    local elapsed = love.timer.getTime() - self.timers[label]
    print(string.format("%s: %.4f ms", label, elapsed * 1000))
end

-- Usage
Profiler:start("renderMap")
renderMap()
Profiler:stop("renderMap")
```

---

### Memory Leaks

**Track memory usage:**
```lua
function debugMemory()
    collectgarbage("collect")
    local mem = collectgarbage("count")
    print(string.format("Memory: %.2f MB", mem / 1024))
end

-- Call periodically
function love.update(dt)
    self.memory_timer = (self.memory_timer or 0) + dt
    
    if self.memory_timer > 5 then  -- Every 5 seconds
        debugMemory()
        self.memory_timer = 0
    end
end
```

---

## Lua Console Commands

Enable debug console with these useful commands:

```lua
-- Print all active entities
/entities

-- Spawn test unit
/spawn unit_type x y

-- Give money
/money 100000

-- Complete research
/research tech_id

-- Jump to mission
/mission mission_id

-- Toggle god mode
/godmode

-- Reload data files
/reload

-- Run Lua code
/lua print(ServiceLocator:get("economy"):getMoney())
```

---

## Log File Analysis

**Enable detailed logging:**
```lua
-- logging.lua
local LOG_FILE = "debug.log"
local LOG_LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

function log(level, message, ...)
    local msg = string.format(message, ...)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local log_line = string.format("[%s] [%s] %s\n", 
        timestamp, level, msg)
    
    -- Write to file
    local file = io.open(LOG_FILE, "a")
    file:write(log_line)
    file:close()
    
    -- Also print to console
    print(log_line)
end
```

---

## Related Documentation

- [[Anti_Patterns]] - Common mistakes to avoid
- [[README]] - Integration overview
- [[../technical/README]] - Technical architecture

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Technical Lead
