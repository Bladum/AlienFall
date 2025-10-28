# 🔌 API & Modding Best Practices for AlienFall

**Domain**: API Design & Modding Architecture  
**Focus**: Extensibility, content modding, TOML format, versioning  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [API Design Principles](#api-design-principles)
2. [Content Modding Architecture](#content-modding-architecture)
3. [TOML Format & Data](#toml-format--data)
4. [Data Validation & Schema](#data-validation--schema)
5. [Mod File Structure](#mod-file-structure)
6. [OpenXCOM Reference](#openxcom-reference)
7. [Extension Points & Hooks](#extension-points--hooks)
8. [Content Balance](#content-balance)
9. [Versioning & Compatibility](#versioning--compatibility)
10. [Mod Distribution](#mod-distribution)
11. [Advanced Patterns](#advanced-patterns)
12. [Testing & Validation](#testing--validation)

---

## API Design Principles

### ✅ DO: Design APIs for Common Use Cases

Make the normal case simple.

**Good API Design:**

```lua
-- Simple case (most common)
local soldier = Soldier:new("John")
soldier:equip(rifle)
soldier:promote("Squaddie")

-- Complex case (still possible)
local config = {
    experience = 500,
    abilities = {"FireBurst", "Stability"},
    customSkills = {
        accuracy = 0.85,
        criticalChance = 0.15
    }
}
local veteran = Soldier:new("John", config)
```

### ✅ DO: Use Sensible Defaults

Users shouldn't specify everything.

**Default Values:**

```lua
-- Simple - uses defaults
Unit:new("Soldier")
-- Becomes: name="Soldier", rank="Rookie", health=100

-- Explicit - override defaults
Unit:new("Soldier", { health = 80, rank = "Squaddie" })

Defaults make simple cases simple
```

### ✅ DO: Provide Clear Error Messages

Errors should guide users.

**Good Error Messages:**

```
✗ BAD:
"Invalid parameter"

✓ GOOD:
"Weapon.damage must be positive number, got 'string'"

✓ BETTER:
"Weapon.damage configuration error: Expected positive number between 10-500, got string 'auto'. " ..
"Fix in mods/weapons.toml line 42"

Include:
- What was expected
- What was found
- Where to fix it
- Example of correct value
```

---

## Content Modding Architecture

### ✅ DO: Separate Data from Code

Content modders shouldn't write Lua.

**Data vs Code Separation:**

```
Code (Lua - for programmers):
engine/game/combat_system.lua
engine/game/unit_manager.lua

Content (TOML - for modders):
mods/units.toml
mods/weapons.toml
mods/missions.toml
mods/balance.toml

Modder edits TOML
Engine loads TOML → uses Code to process
```

### ✅ DO: Use Declarative Content

TOML describes "what", not "how".

**Declarative Content:**

```toml
# Good: Declares item properties
[sword]
name = "Combat Knife"
damage = 25
accuracy = 15
cost = 500
weight = 2

# Bad: Tries to define behavior
[sword]
onHit = "applyBleeding"
calculateDamage = "roll1d20 + 5"
```

---

## TOML Format & Data

### ✅ DO: Use TOML for Configuration

TOML is human-readable and structured.

**TOML Basics:**

```toml
# Comment
title = "AlienFall Units"

# String
name = "Sectoid"

# Number
damage = 25
accuracy = 0.8

# Boolean
flying = false

# Array
abilities = ["mind_control", "clairvoyance"]

# Table (nested structure)
[units.sectoid]
name = "Sectoid"
health = 30
damage = 15
abilities = ["mind_control"]

# Array of tables
[[units]]
name = "Floater"
health = 35
damage = 20

[[units]]
name = "Zombie"
health = 40
damage = 25
```

### ✅ DO: Organize TOML by Domain

Logical grouping aids discovery.

**TOML Organization:**

```toml
# mods/units.toml - All unit definitions
[units.soldier]
[units.soldier.rookies]
[units.soldier.elite]

# mods/weapons.toml - All weapon definitions
[weapons.rifles]
[weapons.pistols]
[weapons.melee]

# mods/balance.toml - All balance numbers
[difficulty]
[difficulty.easy]
[difficulty.hard]

[economy]
[economy.income]
[economy.costs]
```

### ✅ DO: Validate TOML Structure

Catch errors early.

**Validation:**

```lua
-- Schema definition
local UnitSchema = {
    name = { type = "string", required = true },
    health = { type = "number", min = 1, max = 1000 },
    damage = { type = "number", min = 0 },
    abilities = { type = "array", items = { type = "string" } }
}

-- Validation function
local function validateUnit(unit, schema)
    for key, definition in pairs(schema) do
        if definition.required and not unit[key] then
            error("Missing required field: " .. key)
        end
        
        if unit[key] and definition.type then
            if type(unit[key]) ~= definition.type then
                error(key .. " must be " .. definition.type)
            end
        end
    end
end

-- Validate before using
validateUnit(loadedUnit, UnitSchema)
```

---

## Data Validation & Schema

### ✅ DO: Define Schema for All Content

Schema = Contract between code and data.

**Schema Definition:**

```lua
-- weapons_schema.lua
return {
    -- Metadata
    version = "1.0",
    domain = "weapons",
    
    -- Field definitions
    fields = {
        id = {
            type = "string",
            required = true,
            pattern = "^[a-z_]+$"  -- lowercase with underscores only
        },
        name = {
            type = "string",
            required = true,
            minLength = 1,
            maxLength = 50
        },
        damage = {
            type = "number",
            required = true,
            min = 1,
            max = 500
        },
        accuracy = {
            type = "number",
            min = 0,
            max = 100,
            default = 80
        },
        cost = {
            type = "number",
            min = 0,
            default = 0
        },
        ammunition = {
            type = "string",
            oneOf = { "9mm", "5.56mm", "7.62mm", "12ga", "none" }
        },
        abilities = {
            type = "array",
            items = {
                type = "string",
                ref = "abilities"  -- References another schema
            }
        }
    }
}
```

### ✅ DO: Provide Validation Feedback

Show what went wrong clearly.

**Validation Errors:**

```
Validating: mods/weapons.toml

ERROR in [rifles.laser_rifle]:
  Field 'damage': Got 1200, but max allowed is 500
  Fix: Lower damage value or adjust schema

ERROR in [rifles.laser_rifle]:
  Field 'ammunition': Got 'laser_cell', but must be one of: 9mm, 5.56mm, 7.62mm, 12ga, none
  Fix: Change ammunition type or add 'laser_cell' to schema

✓ All other weapons validated successfully
✗ 2 errors found, mod not loaded
```

---

## Mod File Structure

### ✅ DO: Create Consistent Mod Layout

Standard structure aids navigation.

**Mod Directory Structure:**

```
my_mod/
├── mod.toml                 # Metadata
├── README.md                # Documentation
├── LICENSE                  # License
├── content/
│   ├── units.toml          # Unit definitions
│   ├── weapons.toml        # Weapon definitions
│   ├── missions.toml       # Mission definitions
│   ├── balance.toml        # Balance tweaks
│   └── custom.toml         # Custom content
├── scripts/                # Optional Lua scripts
│   ├── init.lua           # Mod initialization
│   └── custom_logic.lua   # Custom logic
├── assets/
│   ├── sprites/           # Character sprites
│   ├── tiles/             # Tile graphics
│   └── sounds/            # Audio files
└── localization/
    ├── en.toml            # English strings
    ├── es.toml            # Spanish strings
    └── fr.toml            # French strings
```

### ✅ DO: Create mod.toml Metadata

Every mod needs metadata.

**mod.toml Template:**

```toml
# Mod metadata
name = "My Awesome Mod"
version = "1.0.0"
author = "Modder Name"
description = "Adds new units and weapons"

# Compatibility
gameVersion = ">=1.0.0,<2.0.0"  # Supported game versions
dependencies = [
    "base_mod>=1.0",
    "community_fix>=2.1"
]
conflicts = [
    "other_mod_name"  # Can't be used together
]

# Content
content = [
    "units",
    "weapons",
    "balance"
]

# Optional
license = "MIT"
repository = "https://github.com/user/my-mod"
supportUrl = "https://discord.gg/..."
```

---

## OpenXCOM Reference

### ✅ DO: Use OpenXCOM Format Where Applicable

Established format, familiar to modders.

**OpenXCOM Compatibility:**

```
AlienFall can load OpenXCOM ruleset files:

OpenXCOM Format:
units.rul
weapons.rul
armor.rul

AlienFall Maps to:
units.toml ← units.rul
weapons.toml ← weapons.rul
armor.toml ← armor.rul

Modders familiar with XCOM modding can
contribute quickly
```

### ✅ DO: Document XCom Equivalents

Help modders understand field mapping.

**Equivalence Guide:**

```toml
# OpenXCOM ruleset:
# Units.rul
# [STR_SECTOID]
#   health: 30
#   bravery: 50
#   reactions: 63

# AlienFall TOML:
[units.sectoid]
name = "Sectoid"
health = 30
morale = 50          # XCom "bravery"
reflexes = 63        # XCom "reactions"

# Field mapping documented in:
# docs/modding/XCOM_CONVERSION_GUIDE.md
```

---

## Extension Points & Hooks

### ✅ DO: Provide Hook System

Let mods trigger custom behavior.

**Hook System Design:**

```lua
-- Core hook system
local Hooks = {}

function Hooks.register(hookName, callback)
    if not Hooks[hookName] then
        Hooks[hookName] = {}
    end
    table.insert(Hooks[hookName], callback)
end

function Hooks.call(hookName, ...)
    local results = {}
    if Hooks[hookName] then
        for _, callback in ipairs(Hooks[hookName]) do
            table.insert(results, callback(...))
        end
    end
    return results
end

-- Usage in core code
function Unit:takeDamage(amount)
    Hooks.call("beforeDamage", self, amount)
    self.health = self.health - amount
    Hooks.call("afterDamage", self, amount)
end

-- Mod uses hook
-- mods/my_mod/scripts/init.lua
Hooks.register("afterDamage", function(unit, damage)
    if unit.health < 0 then
        print("Unit " .. unit.name .. " defeated!")
    end
end)
```

### ✅ DO: Document All Hook Points

Modders need to know what's available.

**Hook Documentation:**

```
Available Hooks:

Combat Hooks:
- beforeDamage(unit, damage) - Before damage applied
- afterDamage(unit, damage) - After damage applied
- beforeAttack(attacker, defender, weapon) - Before attack rolls
- afterAttack(attacker, defender, hit) - After attack resolved
- beforeHeal(unit, amount) - Before healing applied
- afterHeal(unit, amount) - After healing applied

Unit Hooks:
- onUnitCreated(unit) - When unit spawned
- onUnitKilled(unit) - When unit dies
- onUnitPromoted(unit, newRank) - When unit promoted
- onUnitEquipped(unit, item) - When item equipped

Level Hooks:
- beforeMissionStart(mission) - Before mission begins
- afterMissionStart(mission) - Mission started
- onMissionObjectiveComplete(objective) - Objective done
- beforeMissionEnd(mission) - Before mission ends

Each hook documented with: parameters, return type, usage example
```

---

## Content Balance

### ✅ DO: Create Balance Configuration

Centralize numbers for easy tweaking.

**Balance File:**

```toml
# mods/balance.toml
# Central location for all balance numbers

[difficulty]
[difficulty.easy]
damageMultiplier = 0.7
enemyCount = 0.6
playerHealthBonus = 1.3

[difficulty.normal]
damageMultiplier = 1.0
enemyCount = 1.0
playerHealthBonus = 1.0

[difficulty.hard]
damageMultiplier = 1.3
enemyCount = 1.3
playerHealthBonus = 0.8

[economy]
[economy.income]
baseMonthly = 150000
salvagePercentage = 0.15

[economy.costs]
soldierSalary = 500
weaponMaintenance = 100
fuelPerMission = 500

[progression]
baseExperience = 100
killBonus = 50
survivalBonus = 25
```

### ✅ DO: Provide Balance Templates

Give modders starting points.

**Balance Presets:**

```
Balance Templates:

Classic (Balanced):
- Difficulty: 1.0x
- Rewards: Standard
- Economy: Tight but fair

Hardcore (Challenging):
- Difficulty: 1.5x
- Rewards: +50%
- Economy: Tight

Casual (Relaxed):
- Difficulty: 0.7x
- Rewards: +25%
- Economy: Generous

Modders choose template + make tweaks
```

---

## Versioning & Compatibility

### ✅ DO: Implement Semantic Versioning

Clear versioning system.

**Semantic Versioning:**

```
Version: MAJOR.MINOR.PATCH

MAJOR (1.0.0 → 2.0.0): Breaking changes
- Changed data format
- Removed/renamed fields
- Incompatible with 1.x

MINOR (1.0.0 → 1.1.0): New features
- Added fields (backward compatible)
- New content types
- Compatible with 1.0.x

PATCH (1.0.0 → 1.0.1): Bug fixes
- Typo corrections
- Logic fixes
- Fully compatible

AlienFall 1.0: Supports mods for 1.0.x
AlienFall 2.0: Doesn't support 1.x mods without update
```

### ✅ DO: Define Compatibility Rules

Be clear about what works together.

**Compatibility Declaration:**

```toml
[mod]
name = "New Weapons Pack"
version = "1.2.0"

# Required game version
gameVersion = ">=1.0.0,<2.0.0"

# Mod dependencies
dependencies = [
    "base_content_pack>=1.0",
    "ui_improvements>=1.1"
]

# Conflicting mods
conflicts = [
    "old_weapons_pack",
    "incompatible_balance_mod"
]

Game checks before loading:
✓ Game version compatible?
✓ Dependencies installed?
✗ Conflicts present?
```

---

## Mod Distribution

### ✅ DO: Create Mod Portal

Centralized mod management.

**Mod Portal Features:**

```
Mod Portal:
- Browse mods by category
- Search by name/keyword
- Sort by rating/downloads/recent
- View mod details (version, author, rating)
- One-click install
- Auto-update mods

Integration with game:
Settings → Mods → [Browse Portal]
→ Downloads mod
→ Installs to mods/
→ Enables automatically
```

### ✅ DO: Provide Mod Validation

Catch problems before release.

**Pre-Release Validation:**

```
Mod Submission Checklist:
□ mod.toml present and valid
□ All TOML files valid syntax
□ Schema validation passes
□ No conflicts with core content
□ README.md present
□ License specified
□ Version follows semantic versioning
□ Content is balanced (not overpowered)
□ No harmful code/scripts

Automated checks catch 95% of issues
```

---

## Advanced Patterns

### Trait System

```toml
# mods/traits.toml
[[traits]]
id = "steady_aim"
name = "Steady Aim"
description = "+10% accuracy"
cost = 2  # cost in skill points

[[traits]]
id = "sharp_eyes"
name = "Sharp Eyes"
description = "Detect enemies 2 cells further"
cost = 3

# Unit can have multiple traits
[units.veteran_sniper]
name = "Veteran Sniper"
traits = ["steady_aim", "sharp_eyes"]
```

### Event System

```toml
# mods/events.toml
[[events]]
id = "ufo_crash"
name = "UFO Crash Site"
description = "Alien craft crashed, recover technology"
reward = 25000
casualtyRisk = 0.3

[[events]]
id = "abduction"
name = "Abduction Panic"
description = "Aliens abducted scientists from this region"
panic_increase = 50
```

---

## Testing & Validation

### ✅ DO: Provide Mod Testing Tools

Modders need debugging support.

**Testing Features:**

```lua
-- In-game mod tester
local ModTester = {}

function ModTester.testMod(modName)
    print("Testing mod: " .. modName)
    
    -- Load mod
    local mod = loadMod(modName)
    
    -- Validate structure
    validateModStructure(mod)
    
    -- Validate schema
    validateSchema(mod)
    
    -- Test functionality
    testUnitCreation(mod)
    testCombat(mod)
    testBalance(mod)
    
    print("Test complete!")
end

-- Launch game with: lovec engine --test-mod my_mod
```

### ✅ DO: Create Error Reporting

Make debugging easier.

**Error Output:**

```
Mod Loading Error:

Mod: "My Mod" v1.0.0
Error Type: Schema Validation

Problem in units.toml:
[units.custom_soldier]
  Field 'health': Expected number, got "very high"

Location: Line 42

Fix: Change "very high" to a number like 100

For help: Read docs/modding/TROUBLESHOOTING.md
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*See also: docs/modding/ for complete modding documentation*
