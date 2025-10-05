# Integration Anti-Patterns

**Tags:** #integration #best-practices #anti-patterns #technical  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Mission_Lifecycle]], [[Debugging_Guide]]

---

## Overview

This document identifies common integration mistakes and anti-patterns in Alien Fall development. Learn what NOT to do when integrating systems to avoid bugs, performance issues, and maintenance nightmares.

---

## System Integration Anti-Patterns

### ❌ Tight Coupling
**Anti-Pattern:** Systems directly reference each other's internal state

```lua
-- BAD: Direct coupling
function BattlescapeSystem:init()
    self.economy = game.geoscape.economy  -- Tight coupling!
    self.unit_manager = game.systems.units  -- Direct reference!
end
```

**Problem:**
- Changes to one system break others
- Cannot test systems in isolation
- Hard to replace or refactor systems

**Solution:** Use Service Locator or dependency injection
```lua
-- GOOD: Loose coupling through services
function BattlescapeSystem:init()
    self.economy = ServiceLocator:get("economy")
    self.unit_manager = ServiceLocator:get("unit_manager")
end
```

---

### ❌ Circular Dependencies
**Anti-Pattern:** System A depends on B, B depends on A

```lua
-- BAD: Circular dependency
-- In GeoSystem.lua
local BattleSystem = require("systems.BattleSystem")

-- In BattleSystem.lua  
local GeoSystem = require("systems.GeoSystem")  -- CIRCULAR!
```

**Problem:**
- Initialization order problems
- Cannot load modules
- Deadlock scenarios

**Solution:** Use events/messages or interface abstraction
```lua
-- GOOD: Event-based communication
function GeoSystem:startMission(mission_id)
    EventBus:emit("mission_start", {mission_id = mission_id})
end

function BattleSystem:init()
    EventBus:on("mission_start", self.loadMission, self)
end
```

---

### ❌ God Object
**Anti-Pattern:** Single object knows and does everything

```lua
-- BAD: God object
function GameManager:update(dt)
    self:updateGeoscape(dt)
    self:updateBattlescape(dt)
    self:updateEconomy(dt)
    self:updateResearch(dt)
    self:updateDiplomacy(dt)
    self:updateAI(dt)
    self:renderEverything()
    -- 5000 more lines...
end
```

**Problem:**
- Unmaintainable code
- Hard to test
- Performance bottlenecks
- Team conflicts (everyone edits same file)

**Solution:** Separate concerns into distinct systems
```lua
-- GOOD: Separated systems
function Game:update(dt)
    self.state_stack:update(dt)  -- Each state manages its systems
end
```

---

### ❌ Magic Numbers
**Anti-Pattern:** Hard-coded constants scattered in code

```lua
-- BAD: Magic numbers
if unit.health < 5 then  -- What is 5?
    unit:panic()
end

if distance > 12 then  -- Why 12?
    return false
end
```

**Problem:**
- Unclear meaning
- Hard to balance
- Inconsistent values
- Difficult to mod

**Solution:** Named constants in data files
```toml
# data/balance/constants.toml
[combat]
panic_health_threshold = 5  # HP below which units may panic
max_sight_range = 12  # Tiles visible in clear conditions
```

---

### ❌ Premature Optimization
**Anti-Pattern:** Optimizing before profiling

```lua
-- BAD: Complex optimization without measurement
local unit_cache = {}
local cache_dirty = {}
function getUnitPosition(unit_id)
    if not cache_dirty[unit_id] then
        return unit_cache[unit_id]
    end
    -- Complex caching logic...
end
```

**Problem:**
- Makes code complex unnecessarily
- May not improve performance
- Harder to maintain
- Premature abstraction

**Solution:** Write clear code first, profile, then optimize hotspots
```lua
-- GOOD: Simple, clear code (optimize later if needed)
function getUnitPosition(unit_id)
    return self.units[unit_id].position
end
```

---

### ❌ Silent Failures
**Anti-Pattern:** Ignoring errors or returning nil without logging

```lua
-- BAD: Silent failure
function loadMission(mission_id)
    local data = readFile("missions/" .. mission_id .. ".toml")
    if not data then
        return nil  -- Silent failure!
    end
    return parseTOML(data)
end
```

**Problem:**
- Hard to debug
- Cascading failures
- Unclear error source

**Solution:** Log errors and provide context
```lua
-- GOOD: Explicit error handling
function loadMission(mission_id)
    local filepath = "missions/" .. mission_id .. ".toml"
    local data = readFile(filepath)
    
    if not data then
        error(string.format("Failed to load mission '%s' from %s", 
            mission_id, filepath))
    end
    
    local success, result = pcall(parseTOML, data)
    if not success then
        error(string.format("Failed to parse mission '%s': %s",
            mission_id, result))
    end
    
    return result
end
```

---

### ❌ Global State Pollution
**Anti-Pattern:** Using global variables for system state

```lua
-- BAD: Global state
CURRENT_MISSION = nil
PLAYER_SQUAD = {}
ENEMY_UNITS = {}
TURN_COUNT = 0
```

**Problem:**
- Name collisions
- Hard to track state changes
- Testing nightmare
- Modding conflicts

**Solution:** Encapsulate state in objects
```lua
-- GOOD: Encapsulated state
function MissionState:new()
    return {
        mission_data = nil,
        player_squad = {},
        enemy_units = {},
        turn_count = 0
    }
end
```

---

### ❌ Synchronous Loading
**Anti-Pattern:** Blocking main thread to load resources

```lua
-- BAD: Blocks game for 2 seconds
function loadAllAssets()
    for i = 1, 1000 do
        local img = love.graphics.newImage("sprites/unit_" .. i .. ".png")
        assets[i] = img
    end
end
```

**Problem:**
- Game freezes
- Poor user experience
- Long load times

**Solution:** Async loading with progress bar
```lua
-- GOOD: Async loading
function loadAssetsAsync(callback)
    local loader = coroutine.create(function()
        for i = 1, 1000 do
            local img = love.graphics.newImage("sprites/unit_" .. i .. ".png")
            assets[i] = img
            coroutine.yield(i, 1000)  -- Report progress
        end
    end)
    
    return loader
end
```

---

### ❌ String-Based Type Checking
**Anti-Pattern:** Using strings to identify types

```lua
-- BAD: String type checking
if entity.type == "soldier" then
    -- Handle soldier
elseif entity.type == "alien" then
    -- Handle alien
end
```

**Problem:**
- Typos cause bugs
- No IDE autocomplete
- String comparison overhead
- Hard to refactor

**Solution:** Use enums or constants
```lua
-- GOOD: Enum-based types
EntityType = {
    SOLDIER = 1,
    ALIEN = 2,
    CIVILIAN = 3
}

if entity.type == EntityType.SOLDIER then
    -- Handle soldier
end
```

---

### ❌ Leaked Iterators
**Anti-Pattern:** Modifying collections while iterating

```lua
-- BAD: Modifying during iteration
for i, unit in ipairs(units) do
    if unit.health <= 0 then
        table.remove(units, i)  -- DANGEROUS!
    end
end
```

**Problem:**
- Skips elements
- Array index corruption
- Crashes

**Solution:** Iterate backwards or use separate list
```lua
-- GOOD: Safe removal
for i = #units, 1, -1 do
    if units[i].health <= 0 then
        table.remove(units, i)
    end
end
```

---

## Data Integration Anti-Patterns

### ❌ No Schema Validation
**Anti-Pattern:** Loading data without validation

```lua
-- BAD: No validation
local unit_data = loadTOML("units/soldier.toml")
local health = unit_data.stats.health  -- May be nil!
```

**Solution:** Validate against schema
```lua
-- GOOD: Schema validation
local schema = require("schemas.unit_schema")
local unit_data = loadTOML("units/soldier.toml")
schema:validate(unit_data)  -- Throws if invalid
```

---

### ❌ Hardcoded File Paths
**Anti-Pattern:** Absolute paths in code

```lua
-- BAD: Hardcoded paths
local data = readFile("C:/Users/Dev/AlienFall/data/units.toml")
```

**Solution:** Use path utilities
```lua
-- GOOD: Relative paths with utilities
local data = readFile(Path.join("data", "units.toml"))
```

---

## Performance Anti-Patterns

### ❌ Unoptimized Rendering
**Anti-Pattern:** Rendering everything every frame

```lua
-- BAD: Renders 10,000 tiles every frame
function renderMap()
    for y = 1, 100 do
        for x = 1, 100 do
            love.graphics.draw(tiles[y][x], x*20, y*20)
        end
    end
end
```

**Solution:** Render only visible area
```lua
-- GOOD: Culling + batching
function renderMap(camera)
    local visible = camera:getVisibleArea()
    for y = visible.y1, visible.y2 do
        for x = visible.x1, visible.x2 do
            love.graphics.draw(tiles[y][x], x*20, y*20)
        end
    end
end
```

---

### ❌ N+1 Query Pattern
**Anti-Pattern:** Multiple queries in loop

```lua
-- BAD: Queries for each unit
for _, unit_id in ipairs(squad_unit_ids) do
    local unit = getUnitById(unit_id)  -- Query!
    local stats = getUnitStats(unit_id)  -- Query!
    local equipment = getUnitEquipment(unit_id)  -- Query!
end
```

**Solution:** Batch queries
```lua
-- GOOD: Single batch query
local units = getUnitsByIds(squad_unit_ids)  -- One query
```

---

## Testing Anti-Patterns

### ❌ No Tests
**Anti-Pattern:** Not writing any tests

**Solution:** Write tests for critical systems

### ❌ Testing Implementation Details
**Anti-Pattern:** Tests coupled to internal implementation

```lua
-- BAD: Tests internal state
function test_unit_creation()
    local unit = Unit:new()
    assert(unit._internal_cache == {})  -- Testing private details!
end
```

**Solution:** Test public interface only
```lua
-- GOOD: Tests behavior
function test_unit_creation()
    local unit = Unit:new()
    assert(unit:getHealth() == 10)  -- Public API
end
```

---

## Best Practices Summary

### ✅ DO:
- Use Service Locator for system access
- Emit events for cross-system communication
- Validate all data loads
- Log errors with context
- Encapsulate state
- Write tests for critical paths
- Profile before optimizing
- Use constants for magic numbers

### ❌ DON'T:
- Directly couple systems
- Create circular dependencies
- Use global variables
- Ignore errors silently
- Hardcode values in code
- Modify collections while iterating
- Optimize prematurely
- Skip validation

---

## Related Documentation

- [[README]] - Integration overview
- [[Debugging_Guide]] - Troubleshooting integration issues
- [[Mission_Lifecycle]] - Proper mission integration
- [[../technical/README]] - Technical architecture

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Technical Lead
