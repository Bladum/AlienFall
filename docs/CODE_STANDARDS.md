# AlienFall Code Standards

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

Code style, naming conventions, and organization standards for AlienFall Lua codebase.

---

## Table of Contents

- [Overview](#overview)
- [Naming Conventions](#naming-conventions)
- [File Organization](#file-organization)
- [Code Style](#code-style)
- [Module Structure](#module-structure)
- [Error Handling](#error-handling)
- [Performance](#performance)
- [Checklist](#checklist)

---

## Overview

**Goals**:
- Consistency across codebase
- Easy to read and maintain
- Discoverable patterns for learning
- Minimal technical debt
- Support for code review

**Tools**:
- Love2D 12.0+
- Lua 5.1
- VS Code with sumneko.lua extension

---

## Naming Conventions

### Variables and Functions

- **Local variables**: `camelCase`
  ```lua
  local playerUnit = getUnit(1)
  local damageMultiplier = 1.5
  local isAlive = true
  ```

- **Functions**: `camelCase`
  ```lua
  function calculateDamage(attacker, defender)
      return attacker.damage - defender.armor
  end
  ```

- **Private functions**: Prefix with underscore
  ```lua
  local function _internalHelper()
      -- Private function, not in module interface
  end
  ```

- **Constants**: `UPPER_CASE`
  ```lua
  local MAX_UNITS = 12
  local DEFAULT_HP = 100
  local PI = 3.14159
  ```

- **Module names**: `PascalCase`
  ```lua
  local StateManager = {}
  local BattleSystem = {}
  ```

### Boolean Variables

Use `is`, `has`, `can`, `should` prefixes:

```lua
local isAlive = true
local hasWeapon = false
local canMove = true
local shouldRender = false
```

### Table Keys

- **Public keys**: `lowercase_with_underscores` in data tables
  ```lua
  local unit = {
      unit_id = "soldier_001",
      unit_name = "John Smith",
      current_hp = 10,
      max_hp = 12
  }
  ```

- **Event names**: `UPPER_CASE` or `camelCase` depending on usage
  ```lua
  events.UNIT_DIED = "unit_died"
  events.onBattleStart = "onBattleStart"
  ```

### Abbreviations

Avoid abbreviations unless universally known:

```lua
-- Good
local playerDamage = 45
local armorValue = 10

-- Avoid
local pDmg = 45
local aVal = 10

-- OK (universal abbreviations)
local maxHP = 100
local attackPoints = 4
```

---

## File Organization

### File Structure

```
module/
├── README.md              -- Module documentation
├── manager.lua            -- Main module coordinator
├── data/
│   ├── config.lua         -- Configuration tables
│   └── templates.lua      -- Entity templates
├── logic/
│   ├── calculator.lua     -- Calculations
│   └── processor.lua      -- Processing logic
├── systems/
│   ├── system_a.lua       -- System implementations
│   └── system_b.lua
└── utils/
    └── helpers.lua        -- Helper functions
```

### File Naming

- **Module files**: `module_name.lua` (lowercase_with_underscores)
- **Test files**: `test_module_name.lua`
- **Config files**: `config.lua` or specific name like `units_config.lua`
- **Utilities**: `utils.lua` or specific like `math_utils.lua`

### File Size

Keep files under 500 lines. If larger, split into multiple files:

```
battle/
├── manager.lua         -- Main coordinator (100 lines)
├── unit_handler.lua    -- Unit-specific logic (150 lines)
├── combat_resolver.lua -- Damage calculation (200 lines)
└── ai.lua              -- AI logic (250 lines)
```

---

## Code Style

### Indentation

Use **4 spaces** (not tabs):

```lua
function myFunction()
    if condition then
        for i = 1, 10 do
            print(i)
        end
    end
end
```

### Line Length

Keep lines **under 100 characters**. Break long lines:

```lua
-- Good - breaks at logical point
local message = string.format(
    "Unit %s took %d damage from %s",
    target.name, damage, attacker.name
)

-- Good - reasonable expression continuation
local multiplied = (baseValue * modifier * difficultyScale) +
                   bonusFromSpecialization

-- Avoid - too long
local message = string.format("Unit %s took %d damage from %s", target.name, damage, attacker.name)
```

### Spacing

```lua
-- Around operators
local x = 10 + 5
local y = damage * multiplier
local z = (a + b) / 2

-- Function calls (no space before parenthesis)
someFunction(arg1, arg2)
myTable.method(self)

-- Tables
local tbl = { key = value, another = data }
local emptyTbl = {}

-- Conditionals
if condition then
    -- code
elseif other then
    -- code
else
    -- code
end

for i = 1, 10 do
    -- code
end

while true do
    -- code
end
```

### Blank Lines

Use blank lines to separate logical sections:

```lua
-- Section 1: Data initialization
local unit = {}
local stats = {}

-- Section 2: Setup
function unit.init()
    -- ...
end

-- Section 3: Core methods
function unit.update(dt)
    -- ...
end

function unit.draw()
    -- ...
end
```

---

## Module Structure

### Basic Module Pattern

```lua
-- modules/my_module.lua

local MyModule = {}

-- Private variables (encapsulated state)
local state = {}
local config = {
    max_units = 10,
    default_damage = 50
}

-- Public functions
function MyModule.init()
    print("[MyModule] Initializing...")
    state.initialized = true
end

function MyModule.update(dt)
    -- Main update logic
end

function MyModule.getValue()
    return state.value
end

-- Private functions (not exported)
local function _calculateInternal(a, b)
    return a + b
end

function MyModule.cleanup()
    print("[MyModule] Cleaning up...")
    state = {}
end

return MyModule
```

### Module with Multiple Subsystems

```lua
-- modules/complex_module.lua

local ComplexModule = {}

-- Submodules (kept private)
local Subsystem1 = {}
local Subsystem2 = {}

-- Public interface
function ComplexModule.init()
    Subsystem1.init()
    Subsystem2.init()
end

function ComplexModule.update(dt)
    Subsystem1.update(dt)
    Subsystem2.update(dt)
end

function ComplexModule.publicMethod()
    return Subsystem1.getResult()
end

-- Subsystem implementations (private)
function Subsystem1.init()
    -- ...
end

function Subsystem1.update(dt)
    -- ...
end

function Subsystem1.getResult()
    -- ...
end

return ComplexModule
```

---

## Error Handling

### Use PCal for Risky Operations

```lua
-- Risky operation - wrap in pcall
local success, result = pcall(riskyFunction, param1, param2)

if success then
    print("Result: " .. tostring(result))
else
    print("[ERROR] " .. result)
end
```

### Validate Inputs

```lua
function calculateDamage(attacker, defender)
    -- Validate inputs
    if not attacker or not defender then
        error("[calculateDamage] Missing attacker or defender")
    end
    
    if not attacker.damage or not defender.armor then
        error("[calculateDamage] Invalid unit data")
    end
    
    -- Safe to proceed
    return attacker.damage - defender.armor
end
```

### Assertions for Development

```lua
-- During development: catch programming errors
assert(value ~= nil, "Value should not be nil")
assert(type(damage) == "number", "Damage should be number")
assert(damage > 0, "Damage should be positive")
```

### Meaningful Error Messages

```lua
-- Good: states what went wrong and why
error("[StateManager] Cannot switch to 'invalid_state' - state not registered")

-- Bad: unclear
error("Invalid state")
```

---

## Performance

### Avoid Global Variables

```lua
-- Avoid
totalDamage = 0  -- Global!

function addDamage(damage)
    totalDamage = totalDamage + damage
end

-- Good: encapsulated
local DamageTracker = {}
local totalDamage = 0

function DamageTracker.add(damage)
    totalDamage = totalDamage + damage
end

return DamageTracker
```

### Use Local Variables

```lua
-- Good: local variables are faster
function processUnits(units)
    local count = #units
    for i = 1, count do
        local unit = units[i]
        unit:update()
    end
end

-- Avoid: repeated table access
function processUnits(units)
    for i = 1, #units do
        units[i]:update()
    end
end
```

### Reuse Objects

```lua
-- Create once, reuse
local tempVector = {}

function updatePositions(units)
    for _, unit in ipairs(units) do
        tempVector.x = unit.x + unit.dx
        tempVector.y = unit.y + unit.dy
        
        unit:moveTo(tempVector.x, tempVector.y)
    end
end
```

### Pre-calculate When Possible

```lua
-- Calculate once during init
function Unit.init()
    self.maxAP = 4
    self.speedStat = 5
    self.apPerHex = 1  -- Pre-calculate
end

-- Use pre-calculated value
function Unit.getMovementRange()
    return self.maxAP * self.apPerHex  -- No re-calculation
end
```

---

## Checklist

Before committing code:

- [ ] Naming follows conventions (camelCase, UPPER_CASE, etc.)
- [ ] Functions have clear, descriptive names
- [ ] Lines under 100 characters
- [ ] Proper indentation (4 spaces)
- [ ] Blank lines separate logical sections
- [ ] No global variables (except modules)
- [ ] Local variables used throughout
- [ ] Error handling for risky operations
- [ ] Input validation on public functions
- [ ] Meaningful error messages
- [ ] Comments explain non-obvious code (see Comment Standards)
- [ ] Performance considerations addressed
- [ ] No dead/unused code
- [ ] Consistent with rest of codebase

---

## Example: Properly Styled Code

```lua
-- modules/battle/unit_handler.lua

local UnitHandler = {}

-- Private state
local activeUnits = {}
local unitIDCounter = 0

-- Configuration
local CONFIG = {
    max_units_per_side = 12,
    default_hp = 100,
    level_up_xp = 1000
}

-- Initialization
function UnitHandler.init()
    print("[UnitHandler] Initializing...")
    activeUnits = {}
    unitIDCounter = 0
end

-- Create new unit
function UnitHandler.createUnit(name, class)
    -- Validate inputs
    assert(name and #name > 0, "Unit name required")
    assert(class and #class > 0, "Unit class required")
    
    -- Check capacity
    if #activeUnits >= CONFIG.max_units_per_side then
        error("[UnitHandler] Maximum unit capacity reached")
    end
    
    -- Create unit
    unitIDCounter = unitIDCounter + 1
    local unit = {
        id = unitIDCounter,
        name = name,
        class = class,
        current_hp = CONFIG.default_hp,
        max_hp = CONFIG.default_hp,
        xp = 0
    }
    
    table.insert(activeUnits, unit)
    print(string.format("[UnitHandler] Created unit: %s (%s)", name, class))
    
    return unit
end

-- Update all units
function UnitHandler.update(dt)
    for _, unit in ipairs(activeUnits) do
        _updateUnit(unit, dt)
    end
end

-- Private helper function
local function _updateUnit(unit, dt)
    if unit.current_hp <= 0 then
        _removeUnit(unit)
        return
    end
    
    -- Update unit state
    unit.action_points = unit.action_points or 4
end

-- Remove unit (private)
local function _removeUnit(unit)
    for i, u in ipairs(activeUnits) do
        if u.id == unit.id then
            table.remove(activeUnits, i)
            return
        end
    end
end

-- Get all active units
function UnitHandler.getUnits()
    return activeUnits
end

-- Cleanup
function UnitHandler.cleanup()
    print("[UnitHandler] Cleaning up...")
    activeUnits = nil
end

return UnitHandler
```

---

## Related Documentation

- **[Comment Standards](COMMENT_STANDARDS.md)** - How to write comments
- **[Architecture Patterns](../architecture/README.md)** - Design patterns
- **[Debugging Guide](developers/DEBUGGING.md)** - Debugging tips

---

**Last Updated**: October 2025 | **Status**: Active | **Difficulty**: Beginner

