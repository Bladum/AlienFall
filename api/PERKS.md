# Perks System API Reference

**System:** Tactical Layer (Unit Abilities & Traits)  
**Module:** `engine/battlescape/systems/perks_system.lua`  
**Latest Update:** 2025-10-27  
**Status:** ✅ Complete

---

## 📋 Scope & Related Systems

**This API covers:**
- Perk registration and management
- Per-unit perk tracking
- Perk categories and organization
- Runtime perk enable/disable
- TOML loading support

**For related systems, see:**
- **[UNITS.md](UNITS.md)** - Unit system (perks modify unit behavior)
- **Design:** `design/mechanics/Units.md` - Unit design philosophy

---

## Overview

The Perk System manages boolean trait flags that affect unit capabilities and behavior. Perks are organized into categories and can be enabled or disabled per unit, providing customization and specialization options. Each unit has a set of active perks that modify their actions, resistances, and special abilities.

**Layer Classification:** Tactical / Unit Abilities  
**Primary Responsibility:** Perk definitions, per-unit tracking, capability flags  
**Integration Points:** Units (capability modification), Combat (action validation)

**Key Characteristics:**
- **Boolean Flags**: Each perk is on/off for a unit
- **Category Organization**: Perks grouped by type (basic, combat, movement, etc.)
- **Default States**: Some perks enabled by default, others require unlocking
- **Runtime Modification**: Perks can be toggled during gameplay
- **TOML Configuration**: All perks defined in external data files

---

## Implementation Status

### ✅ Implemented (in engine/battlescape/systems/)
- Perk registration system (`perks_system.lua`)
- Per-unit perk tracking
- Enable/disable/toggle functionality
- Active perk queries
- Category organization
- TOML loading support

### 🚧 Partially Implemented
- Perk effect application in combat
- Perk requirements and prerequisites
- Perk unlocking through progression

### 📋 Planned (in design/)
- Perk trees and dependencies
- Equipment-granted perks
- Temporary perk buffs
- Perk synergies and combinations

---

## Core Concepts

### Perk Definition

A perk is a boolean capability flag with metadata:

```lua
{
  id = "can_move",               -- Unique identifier
  name = "Can Move",             -- Display name
  description = "Unit can move", -- Detailed description
  category = "basic",            -- Category for organization
  enabled_by_default = true,     -- Default state
}
```

### Perk Categories

Perks are organized into 9 categories:

1. **Basic** - Core movement and actions (can_move, can_shoot, can_melee)
2. **Movement** - Special movement types (can_swim, can_fly, terrain_immunity)
3. **Combat** - Combat skills (two_weapon_proficiency, sniper_focus, quickdraw)
4. **Senses** - Perception abilities (darkvision, thermal_vision, keen_eyes)
5. **Defense** - Protection and resistance (regeneration, poison_immunity, hardened)
6. **Survival** - Morale and resilience (iron_will, evasion, adrenaline_rush)
7. **Social** - Leadership and support (leadership, inspire, mentor)
8. **Special** - Unique abilities (stealth, phase_shift, teleport)
9. **Flight** - Aerial capabilities (specialized flight perks)

---

## Perk Registry

### Entity: Perk

Perk definition stored in the global registry.

**Properties:**
```lua
Perk = {
  id = string,                    -- "can_move"
  name = string,                  -- "Can Move"
  description = string,           -- Full description
  category = string,              -- "basic", "movement", "combat", etc.
  enabled_by_default = boolean,   -- Default state for new units
  created_at = number,            -- Registration timestamp
}
```

**TOML Configuration:**
```toml
[[perks]]
id = "can_move"
name = "Can Move"
description = "Unit can move during its turn"
category = "basic"
enabled_by_default = true
```

---

## Functions

### Perk Registration

#### PerkSystem.register(id, name, description, category, enabled)
Register a new perk definition.

**Parameters:**
- `id` (string) - Unique perk identifier
- `name` (string) - Display name
- `description` (string) - Detailed description
- `category` (string) - Category key
- `enabled` (boolean) - Default enabled state (optional)

**Returns:** boolean - Success indicator

```lua
local PerkSystem = require("battlescape.systems.perks_system")

PerkSystem.register(
    "can_move",
    "Can Move",
    "Unit can move during its turn",
    "basic",
    true
)
```

---

#### PerkSystem.loadFromTOML(perkData)
Load perks from TOML data array.

**Parameters:**
- `perkData` (table) - Array of perk definitions from TOML

**Returns:** number - Count of perks loaded

```lua
local perks = DataLoader.loadPerks()
local count = PerkSystem.loadFromTOML(perks)
print(count .. " perks loaded")
```

---

### Per-Unit Perk Management

#### PerkSystem.hasPerk(unitId, perkId)
Check if a unit has a specific perk enabled.

**Parameters:**
- `unitId` (number) - Unit ID
- `perkId` (string) - Perk ID to check

**Returns:** boolean - True if perk is enabled

```lua
if PerkSystem.hasPerk(unit.id, "can_move") then
    -- Allow movement
end
```

---

#### PerkSystem.enablePerk(unitId, perkId)
Enable a perk for a unit.

**Parameters:**
- `unitId` (number) - Unit ID
- `perkId` (string) - Perk ID to enable

**Returns:** boolean - Success indicator

```lua
local success = PerkSystem.enablePerk(unit.id, "darkvision")
if success then
    print("Darkvision enabled")
end
```

---

#### PerkSystem.disablePerk(unitId, perkId)
Disable a perk for a unit.

**Parameters:**
- `unitId` (number) - Unit ID
- `perkId` (string) - Perk ID to disable

**Returns:** void

```lua
PerkSystem.disablePerk(unit.id, "can_run")
```

---

#### PerkSystem.togglePerk(unitId, perkId)
Toggle a perk on/off for a unit.

**Parameters:**
- `unitId` (number) - Unit ID
- `perkId` (string) - Perk ID to toggle

**Returns:** boolean - New state (true = enabled)

```lua
local newState = PerkSystem.togglePerk(unit.id, "stealth")
print("Stealth is now " .. (newState and "ON" or "OFF"))
```

---

#### PerkSystem.getActivePerks(unitId)
Get all active perks for a unit.

**Parameters:**
- `unitId` (number) - Unit ID

**Returns:** string[] - Array of active perk IDs

```lua
local activePerks = PerkSystem.getActivePerks(unit.id)
for _, perkId in ipairs(activePerks) do
    print("Active perk: " .. perkId)
end
```

---

#### PerkSystem.getPerksByCategory(category)
Get all perks in a category.

**Parameters:**
- `category` (string) - Category key

**Returns:** table[] - Array of perk definitions

```lua
local combatPerks = PerkSystem.getPerksByCategory("combat")
```

---

#### PerkSystem.initializeUnit(unitId, perkIds)
Initialize perks for a new unit.

**Parameters:**
- `unitId` (number) - Unit ID
- `perkIds` (string[]) - Array of perk IDs to enable

**Returns:** void

```lua
PerkSystem.initializeUnit(unit.id, {
    "can_move",
    "can_shoot",
    "can_melee",
})
```

---

## Complete Perk List

### Basic Abilities (Category: basic)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `can_move` | Can Move | Unit can move during its turn | ✅ |
| `can_run` | Can Run | Unit can run (double movement, half accuracy) | ✅ |
| `can_shoot` | Can Shoot | Unit can fire ranged weapons | ✅ |
| `can_melee` | Can Melee | Unit can perform melee attacks | ✅ |
| `can_throw` | Can Throw | Unit can throw grenades | ✅ |
| `can_climb` | Can Climb | Unit can climb terrain and obstacles | ✅ |

### Movement (Category: movement)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `can_swim` | Can Swim | Unit can move through water | ❌ |
| `can_fly` | Can Fly | Unit can fly, ignoring ground terrain | ❌ |
| `high_jump` | High Jump | Unit can jump to high elevations | ❌ |
| `hover` | Hover | Unit can hover in place | ❌ |
| `terrain_immunity` | Terrain Immunity | Ignores difficult terrain penalties | ❌ |
| `swimming_speed` | Swimming Speed | Moves at normal speed through water | ❌ |

### Combat (Category: combat)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `two_weapon_proficiency` | Two-Weapon Proficiency | Fire two weapons (1 AP, 2x energy, -10% accuracy) | ❌ |
| `can_use_psionic` | Can Use Psionic | Can cast psionic abilities | ❌ |
| `can_fire_heavy` | Can Fire Heavy | Can fire heavy weapons | ❌ |
| `quickdraw` | Quickdraw | Swap weapons as free action | ❌ |
| `ambidextrous` | Ambidextrous | No penalty for two-weapon fighting | ❌ |
| `sniper_focus` | Sniper Focus | +20% accuracy with sniper rifles | ❌ |

### Senses (Category: senses)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `darkvision` | Darkvision | See in darkness without penalty | ❌ |
| `thermal_vision` | Thermal Vision | See heat signatures through walls | ❌ |
| `x_ray_vision` | X-Ray Vision | See through walls and obstacles | ❌ |
| `keen_eyes` | Keen Eyes | See further, spot enemies at distance | ❌ |
| `danger_sense` | Danger Sense | Bonus dodge against attacks | ❌ |

### Defense (Category: defense)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `regeneration` | Regeneration | Heal 5 HP at end of each turn | ❌ |
| `poison_immunity` | Poison Immunity | Immune to poison and toxins | ❌ |
| `fire_immunity` | Fire Immunity | Immune to fire and burn damage | ❌ |
| `fear_immunity` | Fear Immunity | Immune to fear and panic | ❌ |
| `shock_immunity` | Shock Immunity | Immune to electrical/EMP damage | ❌ |
| `hardened` | Hardened | Take 25% less damage from all sources | ❌ |
| `shield_user` | Shield User | Can equip and use shields | ❌ |
| `damage_reflection` | Damage Reflection | Reflect 25% damage back to attacker | ❌ |

### Survival (Category: survival)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `no_morale_penalty` | No Morale Penalty | Not affected by morale/panic | ✅ |
| `iron_will` | Iron Will | Increased willpower, resist mind control | ❌ |
| `evasion` | Evasion | +30% dodge chance | ❌ |
| `thick_skin` | Thick Skin | Innate 5 point armor bonus | ❌ |
| `adrenaline_rush` | Adrenaline Rush | Spend 1 AP for +25% damage for one turn | ❌ |

### Social (Category: social)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `leadership` | Leadership | +10% accuracy bonus to nearby allies | ❌ |
| `inspire` | Inspire | Restore morale to nearby allies | ❌ |
| `mentor` | Mentor | Grant +5 XP to nearby allies on kills | ❌ |

### Special (Category: special)

| Perk ID | Name | Description | Default |
|---------|------|-------------|---------|
| `stealth` | Stealth | Move invisibly (breaks on attack) | ❌ |
| `phase_shift` | Phase Shift | Pass through solid objects | ❌ |
| `teleport` | Teleport | Instant movement to visible location | ❌ |

---

## Usage Examples

### Example 1: Checking Unit Capabilities

```lua
local PerkSystem = require("battlescape.systems.perks_system")

-- Check if unit can perform action
if PerkSystem.hasPerk(unit.id, "can_move") then
    -- Allow movement
    unit:move(targetX, targetY)
else
    print("Unit cannot move")
end

-- Check multiple capabilities
local canFight = PerkSystem.hasPerk(unit.id, "can_shoot") or
                 PerkSystem.hasPerk(unit.id, "can_melee")

if canFight then
    -- Unit can engage in combat
end
```

### Example 2: Granting Perks on Level Up

```lua
-- When unit reaches level 5, grant darkvision
if unit:getLevel() >= 5 then
    PerkSystem.enablePerk(unit.id, "darkvision")
    print(unit.name .. " gained Darkvision!")
end

-- Grant multiple perks
local newPerks = {"thermal_vision", "keen_eyes"}
for _, perkId in ipairs(newPerks) do
    PerkSystem.enablePerk(unit.id, perkId)
end
```

### Example 3: Equipment-Based Perks

```lua
-- When unit equips special armor
function Unit:equipArmor(armor)
    -- ...existing equipment logic...
    
    -- Grant perks from armor
    if armor.grants_perks then
        for _, perkId in ipairs(armor.grants_perks) do
            PerkSystem.enablePerk(self.id, perkId)
        end
    end
end

-- When unequipping
function Unit:unequipArmor()
    -- Remove armor-granted perks
    PerkSystem.disablePerk(self.id, "fire_immunity")
    PerkSystem.disablePerk(self.id, "thick_skin")
end
```

### Example 4: Loading Perks from Unit Class

```lua
-- When creating a unit from TOML definition
local unitDef = DataLoader.unitClasses.get("soldier")

-- Initialize with default perks
if unitDef.perks and unitDef.perks.default then
    PerkSystem.initializeUnit(unit.id, unitDef.perks.default)
end

-- Example unit TOML:
--[[
[unit.perks]
default = ["can_move", "can_run", "can_shoot", "can_melee", "can_throw"]
]]
```

### Example 5: Dynamic Perk Effects

```lua
-- Apply perk effects during combat
function CombatSystem:calculateDamage(attacker, target, baseDamage)
    local damage = baseDamage
    
    -- Check attacker perks
    if PerkSystem.hasPerk(attacker.id, "sniper_focus") and
       attacker.equipped_weapon == "sniper_rifle" then
        damage = damage * 1.2  -- +20% damage
    end
    
    -- Check defender perks
    if PerkSystem.hasPerk(target.id, "hardened") then
        damage = damage * 0.75  -- -25% damage taken
    end
    
    if PerkSystem.hasPerk(target.id, "damage_reflection") then
        local reflected = damage * 0.25
        attacker:takeDamage(reflected)
    end
    
    return damage
end
```

---

## Integration Guide

### With Units System

Perks modify unit behavior and capabilities. Units have a set of active perks that determine what actions they can perform.

```lua
-- Unit creation
local unit = Unit.new("soldier", "player", x, y)

-- Initialize perks from class
PerkSystem.initializeUnit(unit.id, unit.class.default_perks)

-- Check capabilities before actions
if not PerkSystem.hasPerk(unit.id, "can_move") then
    return  -- Movement disabled
end
```

### With Combat System

Perks affect combat calculations, damage, and special abilities.

```lua
-- Before attack
if not PerkSystem.hasPerk(attacker.id, "can_shoot") then
    return false, "Unit cannot shoot"
end

-- Damage calculation
local damage = weapon.damage
if PerkSystem.hasPerk(attacker.id, "sniper_focus") then
    damage = damage * 1.2
end
```

### With Equipment System

Equipment can grant temporary perks while equipped.

```lua
-- Armor with perks
{
  id = "power_armor",
  grants_perks = {"fire_immunity", "shock_immunity", "thick_skin"}
}

-- Apply when equipped
for _, perkId in ipairs(armor.grants_perks) do
    PerkSystem.enablePerk(unit.id, perkId)
end
```

---

## Configuration Reference

### TOML Schema

```toml
[[perks]]
id = "string"                    # Unique identifier (required)
name = "string"                  # Display name (required)
description = "string"           # Full description (required)
category = "string"              # Category key (required)
enabled_by_default = boolean     # Default state (optional, default: false)

# Categories: basic, movement, combat, senses, defense, survival, social, special, flight
```

### Example Configuration

```toml
[[perks]]
id = "regeneration"
name = "Regeneration"
description = "Unit heals 5 HP at the end of each turn"
category = "defense"
enabled_by_default = false

[[perks]]
id = "can_fly"
name = "Can Fly"
description = "Unit can move through air, ignoring ground terrain"
category = "movement"
enabled_by_default = false
```

---

## Best Practices

### ✅ Do This

**1. Check perks before actions**
```lua
-- GOOD: Validate capability
if PerkSystem.hasPerk(unit.id, "can_move") then
    unit:move(x, y)
end
```

**2. Initialize perks on unit creation**
```lua
-- GOOD: Set default perks
PerkSystem.initializeUnit(unit.id, defaultPerks)
```

**3. Use perks for capability flags**
```lua
-- GOOD: Clear intent
if PerkSystem.hasPerk(unit.id, "darkvision") then
    -- No penalty in darkness
end
```

### ❌ Don't Do This

**1. Don't skip perk checks**
```lua
-- BAD: Assume capability
unit:fly(x, y)  -- May fail if can't fly
```

**2. Don't hardcode capabilities**
```lua
-- BAD: Magic numbers
if unit.type == "alien" then
    canFly = true
end

-- GOOD: Use perks
canFly = PerkSystem.hasPerk(unit.id, "can_fly")
```

**3. Don't modify registry at runtime**
```lua
-- BAD: Modifying global definitions
PerkSystem.registry["can_move"].enabled_by_default = false

-- GOOD: Modify per-unit state
PerkSystem.disablePerk(unit.id, "can_move")
```

---

## Related Documentation

- **[UNITS.md](UNITS.md)** - Unit system (perks modify units)
- **[WEAPONS_AND_ARMOR.md](WEAPONS_AND_ARMOR.md)** - Equipment that grants perks
- **[Design: Units](../design/mechanics/Units.md)** - Unit design philosophy
- **[TOML: perks.toml](../mods/core/rules/unit/perks.toml)** - Perk definitions
- **[Engine: perks_system.lua](../engine/battlescape/systems/perks_system.lua)** - Implementation

---

**End of Perks API Reference**

