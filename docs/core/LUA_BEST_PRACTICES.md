# Lua Best Practices - Quick Reference

## Essential Patterns

### 1. Module Pattern ✅
```lua
local MyModule = {}

-- Public function
function MyModule.doSomething(x, y)
    return MyModule._privateHelper(x + y)
end

-- Private function (underscore prefix)
function MyModule._privateHelper(value)
    return value * 2
end

return MyModule
```

### 2. Always Use `local` ✅
```lua
-- Good ✅
local function calculate(x)
    local result = x * 2
    return result
end

-- Bad ❌
function calculate(x)
    result = x * 2  -- Global leak!
    return result
end
```

### 3. Error Handling ✅
```lua
-- Protected call for risky operations
local success, result = pcall(function()
    return someRiskyOperation()
end)

if not success then
    print("[ERROR] Operation failed: " .. tostring(result))
    return nil
end

return result
```

### 4. Pure Functions (No Side Effects) ✅
```lua
-- Good: Pure function ✅
local function distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Bad: Has side effects ❌
local totalDistance = 0
local function distanceWithSideEffect(x1, y1, x2, y2)
    local dist = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    totalDistance = totalDistance + dist  -- Side effect!
    return dist
end
```

### 5. Component Composition Over Inheritance ✅
```lua
-- Good: Composition ✅
local Entity = {}

function Entity.new()
    return {
        transform = Transform.new(),
        health = Health.new(),
        movement = Movement.new()
    }
end

-- Bad: Deep inheritance ❌
local Entity = {}
local Soldier = setmetatable({}, {__index = Entity})
local EliteSoldier = setmetatable({}, {__index = Soldier})  -- Too deep!
```

### 6. Configuration Over Hardcoding ✅
```lua
-- Good: Externalized config ✅
local CONFIG = {
    MOVE_COST_BASE = 2,
    MOVE_COST_ROUGH = 3,
    MOVE_COST_WATER = 6
}

local function getMoveCost(terrain)
    return CONFIG["MOVE_COST_" .. terrain:upper()] or CONFIG.MOVE_COST_BASE
end

-- Bad: Hardcoded ❌
local function getMoveCost(terrain)
    if terrain == "rough" then
        return 3
    elseif terrain == "water" then
        return 6
    end
    return 2
end
```

### 7. Documentation Standards ✅
```lua
--- Calculate hex distance between two points
-- Uses cube coordinate system for accurate hex grid distance
-- @param x1 number First hex X coordinate
-- @param y1 number First hex Y coordinate  
-- @param x2 number Second hex X coordinate
-- @param y2 number Second hex Y coordinate
-- @return number Distance in hex tiles
-- @usage local dist = HexMath.distance(0, 0, 3, 0)  -- Returns 3
function HexMath.distance(x1, y1, x2, y2)
    local a = HexMath.offsetToCube(x1, y1)
    local b = HexMath.offsetToCube(x2, y2)
    return (math.abs(a.q - b.q) + math.abs(a.r - b.r) + math.abs(a.s - b.s)) / 2
end
```

### 8. Performance: Cache in Hot Loops ✅
```lua
-- Good: Local caching ✅
local function processUnits(units)
    local count = #units
    for i = 1, count do
        local unit = units[i]
        local x, y = unit.transform.x, unit.transform.y
        processPosition(x, y)
    end
end

-- Bad: Repeated table access ❌
local function processUnits(units)
    for i = 1, #units do
        processPosition(units[i].transform.x, units[i].transform.y)
    end
end
```

### 9. Resource Cleanup ✅
```lua
function Battlescape:cleanup()
    -- Clear references to prevent memory leaks
    self.units = nil
    self.battlefield = nil
    
    -- Cleanup systems
    if self.renderSystem then
        self.renderSystem:cleanup()
    end
    
    -- Force garbage collection
    collectgarbage("collect")
end
```

### 10. Testable Design ✅
```lua
-- Good: Pure, testable function ✅
local function calculateDamage(attack, defense)
    return math.max(0, attack - defense)
end

-- Tests
assert(calculateDamage(10, 5) == 5, "Should deal 5 damage")
assert(calculateDamage(5, 10) == 0, "Should deal 0 damage (not negative)")
assert(calculateDamage(0, 0) == 0, "Should handle zero values")

-- Bad: Hard to test ❌
local function attackUnit(attacker, defender)
    defender.health = defender.health - (attacker.attack - defender.defense)
    if defender.health < 0 then defender.health = 0 end
    updateUI()  -- Side effect!
    playSound("hit")  -- Side effect!
end
```

---

## ECS Architecture Pattern

### Component (Data Only)
```lua
local Transform = {}

function Transform.new(x, y, facing)
    return {
        x = x or 0,
        y = y or 0,
        facing = facing or 0
    }
end

return Transform
```

### System (Logic Only)
```lua
local MovementSystem = {}

function MovementSystem:moveUnit(unit, targetX, targetY)
    -- Validate
    if not self:canMoveTo(unit, targetX, targetY) then
        return false
    end
    
    -- Execute
    unit.transform.x = targetX
    unit.transform.y = targetY
    
    return true
end

return MovementSystem
```

### Entity (Composition)
```lua
local UnitEntity = {}

function UnitEntity.new(x, y)
    return {
        transform = Transform.new(x, y),
        movement = Movement.new(24),
        health = Health.new(100)
    }
end

return UnitEntity
```

---

## Common Pitfalls to Avoid

### ❌ Global Variable Leaks
```lua
-- Bad
function calculate()
    result = 10  -- Oops, forgot 'local'!
    return result
end

-- Good
function calculate()
    local result = 10
    return result
end
```

### ❌ Modifying Tables During Iteration
```lua
-- Bad
for i, unit in ipairs(units) do
    if unit.health <= 0 then
        table.remove(units, i)  -- Don't do this!
    end
end

-- Good
local toRemove = {}
for i, unit in ipairs(units) do
    if unit.health <= 0 then
        table.insert(toRemove, i)
    end
end

for i = #toRemove, 1, -1 do
    table.remove(units, toRemove[i])
end
```

### ❌ Forgetting to Return Module
```lua
-- Bad - Module won't work!
local MyModule = {}

function MyModule.doStuff()
    return "stuff"
end

-- Forgot to return!

-- Good
local MyModule = {}

function MyModule.doStuff()
    return "stuff"
end

return MyModule  -- Don't forget!
```

### ❌ Using `pairs()` When Order Matters
```lua
-- Bad - Order not guaranteed
for k, v in pairs(orderedList) do
    print(k, v)
end

-- Good - Use ipairs for arrays
for i, v in ipairs(orderedList) do
    print(i, v)
end
```

---

## Debugging Tips

### Print with Context
```lua
print(string.format("[%s] Unit %s moved to (%d, %d)", 
    os.date("%H:%M:%S"),
    unit.name, 
    unit.transform.x, 
    unit.transform.y))
```

### Conditional Debug Logging
```lua
local DEBUG = true

local function debug(...)
    if DEBUG then
        print("[DEBUG]", ...)
    end
end

debug("Vision calculated:", visibleTiles)
```

### Inspect Tables
```lua
local function inspect(t, indent)
    indent = indent or 0
    for k, v in pairs(t) do
        print(string.rep("  ", indent) .. tostring(k) .. ": " .. tostring(v))
        if type(v) == "table" then
            inspect(v, indent + 1)
        end
    end
end

inspect(unit)
```

---

## Performance Tips

1. **Cache `#table` in loops**
   ```lua
   local count = #items
   for i = 1, count do
       -- ...
   end
   ```

2. **Use local copies in hot paths**
   ```lua
   local sin, cos = math.sin, math.cos
   for i = 1, 1000 do
       local x = cos(angle) * radius
       local y = sin(angle) * radius
   end
   ```

3. **Reuse tables instead of creating new ones**
   ```lua
   local tempTable = {}
   for i = 1, 1000 do
       -- Clear and reuse instead of creating new
       for k in pairs(tempTable) do
           tempTable[k] = nil
       end
       -- Use tempTable
   end
   ```

4. **Profile before optimizing**
   ```lua
   local start = love.timer.getTime()
   expensiveOperation()
   local duration = love.timer.getTime() - start
   print(string.format("Took %.4fms", duration * 1000))
   ```

---

**Keep this reference handy during implementation!**
