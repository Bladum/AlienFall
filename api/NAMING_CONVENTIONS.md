# API Naming Conventions

**Purpose:** Standardize method and property names across all API documentation  
**Status:** ✅ Established Standard  
**Last Updated:** 2025-10-27

---

## Implementation Status

### ✅ Implemented
- Complete naming standards documentation
- Method naming patterns established
- Property naming conventions defined
- Percentage vs ratio clarification
- Engine reality documentation approach

### 🚧 Partially Implemented
- Automated naming validation
- IDE plugin for naming enforcement
- Code review checklist integration

### 📋 Planned
- Automated refactoring tool for naming compliance
- Real-time naming suggestion system
- Documentation generator using naming standards

---

## Overview

This document defines the official naming conventions for all API documentation. When documenting methods from the engine, follow these standards to ensure consistency and clarity.

---

## Method Naming Standards

### Percentage/Ratio Methods

**Rule:** Use descriptive suffixes to indicate the return value range.

#### Recommended Pattern

```lua
-- For 0.0-1.0 ratio (decimal)
entity:getFuelRatio() → number  -- 0.0-1.0
entity:getHealthRatio() → number  -- 0.0-1.0

-- For 0-100 percentage
entity:getFuelPercent() → number  -- 0-100
entity:getHealthPercent() → number  -- 0-100
```

#### Engine Reality Check

**Current Engine Implementation (craft.lua):**
```lua
-- Primary method returns 0.0-1.0
function Craft:getFuelPercentage()
    return self.currentFuel / self.fuelCapacity  -- Returns 0.0-1.0
end

-- Alias for compatibility
function Craft:getFuelPercent()
    return self:getFuelPercentage()  -- Returns 0.0-1.0
end
```

**API Documentation Standard:**

When engine methods return 0.0-1.0 but are named with "Percent":

```lua
-- Document the actual behavior
craft:getFuelPercentage() → number  -- 0.0-1.0 ratio (primary)
craft:getFuelPercent() → number  -- 0.0-1.0 ratio (alias)

-- Or provide conversion helpers
craft:getFuelPercentDisplay() → number  -- 0-100 for UI (multiply by 100)
```

**Note:** Do NOT change engine implementation. Document what exists and clarify the range.

---

### Getters (Simple Properties)

**Rule:** Use `get` prefix when computation is involved, omit for simple property access.

```lua
-- Simple property access (no "get")
entity.name → string
entity.health → number
entity.type → string

-- Computed values (use "get")
entity:getName() → string  -- When it requires processing
entity:getHealth() → number  -- When modified by buffs/debuffs
entity:getMaxHealth() → number  -- Calculated value
```

**Examples:**
```lua
-- GOOD: Simple property
local name = unit.name

-- GOOD: Computed getter
local effectiveHealth = unit:getHealth()  -- Includes buffs
local maxHP = unit:getMaxHealth()  -- Calculated from class + equipment
```

---

### Boolean Queries

**Rule:** Use `is`, `has`, or `can` prefixes for boolean methods.

```lua
-- State queries (is)
entity:isAlive() → boolean
entity:isReady() → boolean
entity:isOperational() → boolean

-- Possession queries (has)
entity:hasItem(itemId) → boolean
entity:hasSkill(skillId) → boolean
entity:hasStatusEffect(effect) → boolean

-- Capability queries (can)
entity:canMove() → boolean
entity:canAttack() → boolean
entity:canReach(destination) → boolean
```

---

### Modification Methods

**Rule:** Use clear verbs indicating the operation type.

```lua
-- Setting values (set)
entity:setHealth(value) → void
entity:setStatus(status) → void

-- Modifying values (modify, add, remove)
entity:modifyHealth(delta) → void
entity:addItem(item) → boolean
entity:removeItem(itemId) → boolean

-- Specific operations (gain, lose, take, apply)
entity:gainExperience(xp) → void
entity:takeDamage(damage) → void
entity:applyBuff(buff) → void
```

---

### Retrieval Methods

**Rule:** Distinguish between single items and collections.

```lua
-- Single item (get + singular)
manager:getCountry(id) → Country | nil
manager:getUnit(id) → Unit | nil

-- Multiple items (get + plural or getAll)
manager:getAllCountries() → Country[]
manager:getUnits() → Unit[]
manager:getUnitsByType(type) → Unit[]

-- Filtered retrieval (getBy + criteria)
manager:getCountriesByRegion(region) → Country[]
manager:getCountriesByType(type) → Country[]
manager:getCountriesByRelation(min, max) → Country[]
```

---

## Property Naming Standards

### Standard Properties

```lua
-- Identity
id = string  -- Unique identifier
name = string  -- Display name
type = string  -- Entity type

-- Numeric values (use descriptive names)
health = number  -- Current health
max_health = number  -- Maximum health (NOT maxHealth in Lua tables)
current_xp = number  -- Current experience
total_xp = number  -- Total experience
```

### Aliases

**Rule:** Document aliases but prefer the primary name.

```lua
-- Primary
health = number  -- Current HP

-- Aliases (document but note they're aliases)
hp = number  -- Alias for health
hp_current = number  -- Alias for health
```

**In API Documentation:**
```lua
Unit = {
  health = number,  -- Current HP (primary)
  hp = number,  -- Alias for health
  hp_current = number,  -- Alias for health
}
```

---

## Naming by Entity Type

### For Units

```lua
-- Stats
unit:getStat(statName) → number  -- Base stat
unit:getEffectiveStat(statName) → number  -- With modifiers
unit:updateStats() → void  -- Recalculate

-- Health
unit:getHealth() → number
unit:getMaxHealth() → number
unit:getHealthPercent() → number  -- 0-100
unit:getHealthRatio() → number  -- 0.0-1.0

-- Actions
unit:takeDamage(amount) → void
unit:heal(amount) → void
unit:gainExperience(xp) → void
```

### For Crafts

```lua
-- Fuel
craft:getFuel() → number
craft:getFuelCapacity() → number
craft:getFuelPercentage() → number  -- 0.0-1.0 (engine actual)
craft:getFuelPercent() → number  -- 0.0-1.0 (alias)
craft:consumeFuel(amount) → void
craft:refuel(amount) → void

-- Health/Damage
craft:getHP() → number
craft:getMaxHP() → number
craft:getHealthPercent() → number  -- Document actual range
craft:getDamagePercentage() → number
```

### For Countries

```lua
-- Retrieval
manager:getCountry(id) → Country | nil
manager:getAllCountries() → Country[]
manager:getCountriesByType(type) → Country[]
manager:getCountriesByRegion(region) → Country[]

-- State
manager:updateCountryState(id, updates) → boolean
manager:modifyRelation(id, delta, reason) → void
manager:modifyPanic(id, delta, reason) → void
```

---

## Percentage vs Ratio Clarification

### The Problem

Many engine methods named with "Percent" actually return 0.0-1.0 ratios, not 0-100 percentages.

### The Solution

**Document the actual behavior, not the name:**

```lua
-- Engine implementation returns 0.0-1.0
craft:getFuelPercentage() → number  -- Returns 0.0-1.0 ratio (NOT 0-100)
craft:getFuelPercent() → number  -- Returns 0.0-1.0 ratio (alias)

-- For UI display, convert:
local displayPercent = craft:getFuelPercentage() * 100  -- 0-100 for UI
```

**API Documentation Pattern:**

```markdown
### craft:getFuelPercentage()
Get fuel level as ratio.

**Returns:** number - Fuel ratio (0.0-1.0)

**Note:** Despite the name "Percentage", this returns a 0.0-1.0 ratio.
For UI display as 0-100, multiply by 100.

```lua
local ratio = craft:getFuelPercentage()  -- 0.75
local percent = ratio * 100  -- 75 for UI display
```
```

---

## Consistency Checklist

When documenting a method, ensure:

- [ ] **Return type clearly specified** (number, boolean, string, table, etc.)
- [ ] **Range documented for numbers** (0-100, 0.0-1.0, 1-10, etc.)
- [ ] **Aliases noted** if multiple names exist
- [ ] **Parameters have types** and descriptions
- [ ] **Nil returns documented** for optional returns
- [ ] **Examples show actual usage**

---

## Common Patterns

### Percentage/Ratio Pattern

```lua
-- Pattern 1: Ratio methods (0.0-1.0)
entity:getHealthRatio() → number  -- 0.0-1.0
entity:getFuelRatio() → number  -- 0.0-1.0

-- Pattern 2: Percent methods (0-100)
entity:getHealthPercent() → number  -- 0-100
entity:getFuelPercent() → number  -- 0-100

-- Pattern 3: Engine reality (document actual behavior)
craft:getFuelPercentage() → number  -- 0.0-1.0 (despite name)
```

### Boolean Query Pattern

```lua
-- State checks
entity:isAlive() → boolean
entity:isReady() → boolean

-- Capability checks
entity:canMove() → boolean
entity:canAttack() → boolean

-- Possession checks
entity:hasItem(id) → boolean
entity:hasSkill(id) → boolean
```

### Collection Retrieval Pattern

```lua
-- Get single
manager:getEntity(id) → Entity | nil

-- Get all
manager:getAllEntities() → Entity[]

-- Get filtered
manager:getEntitiesByType(type) → Entity[]
manager:getEntitiesBy<Criteria>(...) → Entity[]
```

---

## Standardization Process

### For New API Documentation

1. **Check engine implementation first**
2. **Document actual behavior**, not assumed behavior
3. **Follow these conventions** for consistency
4. **Add examples** showing real usage
5. **Note any aliases** or alternative names

### For Existing API Documentation

1. **Audit method names** against engine
2. **Verify return value ranges**
3. **Clarify ambiguous names** with notes
4. **Add missing range documentation**
5. **Update examples** to show correct usage

---

## Examples of Proper Documentation

### Example 1: Clear Range Documentation

```lua
-- GOOD: Clear range specification
unit:getHealthPercent() → number  -- 0-100 percentage
unit:getHealthRatio() → number  -- 0.0-1.0 ratio

-- BAD: Ambiguous
unit:getHealth() → number  -- How much health? (unclear)
```

### Example 2: Documenting Engine Reality

```lua
-- Engine method name: getFuelPercentage()
-- Engine returns: 0.0-1.0 (not 0-100!)

-- GOOD: Document actual behavior
craft:getFuelPercentage() → number  -- 0.0-1.0 ratio
-- Despite the name, returns 0.0-1.0. Multiply by 100 for UI display.

-- BAD: Assume based on name
craft:getFuelPercentage() → number  -- 0-100 percentage (WRONG!)
```

### Example 3: Boolean Queries

```lua
-- GOOD: Clear intent
unit:isAlive() → boolean
unit:canMove() → boolean
unit:hasItem(itemId) → boolean

-- BAD: Unclear intent
unit:checkAlive() → boolean  -- Use "is" not "check"
unit:moveAllowed() → boolean  -- Use "canMove"
unit:itemExists(itemId) → boolean  -- Use "hasItem"
```

---

## Migration Notes

### Updating Existing Documentation

When standardizing existing API files:

1. **Do NOT change engine code** - document what exists
2. **Add clarifying notes** for confusing names
3. **Document ranges explicitly**
4. **Keep aliases** but mark them as such
5. **Add examples** showing correct usage

### Priority Areas

1. ✅ **CRAFTS.md** - getFuelPercentage clarified
2. **UNITS.md** - getHealthPercent vs getHPPercent
3. **BATTLESCAPE.md** - Various percentage methods
4. **INTERCEPTION.md** - Health/damage percentages

---

## Related Documentation

- [API README](README.md) - Overall API documentation guide
- [Best Practices](README.md#best-practices) - General API best practices
- [API Template](README.md#api-documentation-template) - Standard file template

---

**End of Naming Conventions**

