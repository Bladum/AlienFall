# TASK-PILOT-004: Implement PERKS System (Base Framework)

**Status:** TODO | **Priority:** CRITICAL | **Duration:** 6-8 hours  
**Depends On:** TASK-PILOT-001 (pilots must exist)  
**Blocks:** TASK-PILOT-005, TASK-PILOT-009, TASK-PILOT-010

---

## Overview

Create a comprehensive boolean flag-based system for unit traits/perks. Each unit has a set of perks that can be enabled/disabled, affecting unit capabilities and behavior. This system provides tactical customization and enables features like dual-wield, special movement types, and immunities.

---

## What Needs to be Done

### 1. Create PerkSystem Core Module

**File:** `engine/battlescape/systems/perks_system.lua` (NEW, 300+ lines)

```lua
---
-- @module PerkSystem
-- Boolean flag-based unit trait system
-- Manages per-unit perk tracking and application
--

local PerkSystem = {}

-- Global perk registry: {perk_id -> perk_definition}
PerkSystem.registry = {}

-- Per-unit perk states: {unit_id -> {perk_id -> boolean}}
PerkSystem.unitPerks = {}

---
-- Register a perk definition
-- @param id string Unique perk ID (e.g., "can_move")
-- @param name string Display name (e.g., "Can Move")
-- @param description string Perk description/effects
-- @param category string Perk category (e.g., "basic", "combat", "survival")
-- @param default_enabled boolean Whether perk starts enabled
--
function PerkSystem.register(id, name, description, category, default_enabled)
    PerkSystem.registry[id] = {
        id = id,
        name = name,
        description = description,
        category = category or "misc",
        default_enabled = default_enabled ~= false  -- Default to true
    }
end

---
-- Initialize perks for a unit
-- @param unit_id string
-- @param initial_perks table {perk_id -> boolean}
--
function PerkSystem.initUnit(unit_id, initial_perks)
    PerkSystem.unitPerks[unit_id] = initial_perks or {}
end

---
-- Check if unit has a perk active
-- @param unit_id string
-- @param perk_id string
-- @return boolean True if perk is active
--
function PerkSystem.hasPerk(unit_id, perk_id)
    if not PerkSystem.unitPerks[unit_id] then
        return false
    end
    return PerkSystem.unitPerks[unit_id][perk_id] or false
end

---
-- Enable a perk for unit
-- @param unit_id string
-- @param perk_id string
-- @return boolean Success
--
function PerkSystem.enablePerk(unit_id, perk_id)
    if not PerkSystem.registry[perk_id] then
        print("[WARNING] Perk not registered: " .. perk_id)
        return false
    end
    
    if not PerkSystem.unitPerks[unit_id] then
        PerkSystem.initUnit(unit_id)
    end
    
    PerkSystem.unitPerks[unit_id][perk_id] = true
    return true
end

---
-- Disable a perk for unit
-- @param unit_id string
-- @param perk_id string
--
function PerkSystem.disablePerk(unit_id, perk_id)
    if PerkSystem.unitPerks[unit_id] then
        PerkSystem.unitPerks[unit_id][perk_id] = false
    end
end

---
-- Toggle a perk for unit
-- @param unit_id string
-- @param perk_id string
-- @return boolean New state
--
function PerkSystem.togglePerk(unit_id, perk_id)
    local current = PerkSystem.hasPerk(unit_id, perk_id)
    if current then
        PerkSystem.disablePerk(unit_id, perk_id)
        return false
    else
        PerkSystem.enablePerk(unit_id, perk_id)
        return true
    end
end

---
-- Get all active perks for unit
-- @param unit_id string
-- @return table Array of active perk IDs
--
function PerkSystem.getActivePerks(unit_id)
    if not PerkSystem.unitPerks[unit_id] then
        return {}
    end
    
    local active = {}
    for perk_id, enabled in pairs(PerkSystem.unitPerks[unit_id]) do
        if enabled then
            table.insert(active, perk_id)
        end
    end
    return active
end

---
-- Get all perks for unit (active and inactive)
-- @param unit_id string
-- @return table {perk_id -> boolean}
--
function PerkSystem.getAllPerks(unit_id)
    return PerkSystem.unitPerks[unit_id] or {}
end

---
-- Get perk definition
-- @param perk_id string
-- @return table Perk definition or nil
--
function PerkSystem.getPerk(perk_id)
    return PerkSystem.registry[perk_id]
end

---
-- Get all registered perks
-- @return table All perk definitions
--
function PerkSystem.getAllDefinitions()
    return PerkSystem.registry
end

---
-- Get perks by category
-- @param category string
-- @return table Perks in category
--
function PerkSystem.getByCategory(category)
    local result = {}
    for perk_id, perk in pairs(PerkSystem.registry) do
        if perk.category == category then
            table.insert(result, perk)
        end
    end
    return result
end

---
-- Get perk info for display
-- @param perk_id string
-- @return string Formatted perk info
--
function PerkSystem.formatPerkInfo(perk_id)
    local perk = PerkSystem.getPerk(perk_id)
    if not perk then
        return "Unknown perk: " .. perk_id
    end
    
    return string.format("%s: %s (%s)", perk.name, perk.description, perk.category)
end

---
-- Load all perks from TOML data
-- @param toml_data table Loaded TOML data with perks array
--
function PerkSystem.loadFromTOML(toml_data)
    if not toml_data or not toml_data.perks then
        return
    end
    
    for _, perk_def in ipairs(toml_data.perks) do
        PerkSystem.register(
            perk_def.id,
            perk_def.name,
            perk_def.description,
            perk_def.category,
            perk_def.default_enabled
        )
    end
end

return PerkSystem
```

### 2. Create Perks TOML Configuration

**File:** `mods/core/rules/unit/perks.toml` (NEW, 150+ lines)

```toml
# PERKS SYSTEM - Boolean trait flags for units
# Each perk is a simple on/off flag that affects unit behavior
# Perks are loaded from this file and assigned to units/classes

# ============================================================================
# BASIC MOVEMENT PERKS
# ============================================================================

[[perks]]
id = "can_move"
name = "Can Move"
description = "Unit can move normally across hex grid"
category = "basic"
default_enabled = true

[[perks]]
id = "can_run"
name = "Can Run"
description = "Unit can run (double movement distance, double AP cost)"
category = "basic"
default_enabled = true

[[perks]]
id = "can_climb"
name = "Can Climb"
description = "Unit can climb vertical surfaces and mountains"
category = "movement"
default_enabled = false

[[perks]]
id = "can_swim"
name = "Can Swim"
description = "Unit can move through deep water without drowning"
category = "movement"
default_enabled = false

[[perks]]
id = "can_breathe"
name = "Can Breathe (Any Atmosphere)"
description = "Unit survives without oxygen/air (underwater, vacuum, toxic)"
category = "survival"
default_enabled = false

[[perks]]
id = "high_jump"
name = "High Jump"
description = "Unit can jump 2 tiles high (vs normal 1)"
category = "movement"
default_enabled = false

# ============================================================================
# FLIGHT & SPECIAL MOVEMENT
# ============================================================================

[[perks]]
id = "can_fly"
name = "Can Fly"
description = "Unit can fly over terrain and obstacles"
category = "movement"
default_enabled = false

[[perks]]
id = "hover"
name = "Hover"
description = "Unit can hover in place without moving"
category = "movement"
default_enabled = false

[[perks]]
id = "teleport"
name = "Teleport"
description = "Unit can teleport short distances (psionic or tech)"
category = "movement"
default_enabled = false

# ============================================================================
# COMBAT PERKS
# ============================================================================

[[perks]]
id = "can_shoot"
name = "Can Shoot"
description = "Unit can use firearms and ranged weapons"
category = "combat"
default_enabled = true

[[perks]]
id = "can_melee"
name = "Can Melee"
description = "Unit can perform melee attacks with weapons"
category = "combat"
default_enabled = true

[[perks]]
id = "can_throw"
name = "Can Throw"
description = "Unit can throw grenades and throwable items"
category = "combat"
default_enabled = true

[[perks]]
id = "can_use_psionics"
name = "Can Use Psionics"
description = "Unit has access to psionic abilities"
category = "combat"
default_enabled = false

[[perks]]
id = "can_use_heavy_weapons"
name = "Can Use Heavy Weapons"
description = "Unit can wield heavy weapons (minigun, rocket launcher)"
category = "combat"
default_enabled = false

[[perks]]
id = "two_weapon_proficiency"
name = "Two-Weapon Proficiency"
description = "Can fire 2 identical weapons in one action (1 AP, 2x energy cost, -10% accuracy)"
category = "combat"
default_enabled = false

[[perks]]
id = "quickdraw"
name = "Quickdraw"
description = "Weapon switching costs 0 AP (normally 1 AP)"
category = "combat"
default_enabled = false

[[perks]]
id = "ambidextrous"
name = "Ambidextrous"
description = "No accuracy penalty for non-dominant hand attacks"
category = "combat"
default_enabled = false

# ============================================================================
# SENSES & PERCEPTION
# ============================================================================

[[perks]]
id = "darkvision"
name = "Darkvision"
description = "Can see in complete darkness"
category = "senses"
default_enabled = false

[[perks]]
id = "thermal_vision"
name = "Thermal Vision"
description = "Can see heat signatures through walls and smoke"
category = "senses"
default_enabled = false

[[perks]]
id = "x_ray_vision"
name = "X-Ray Vision"
description = "Can see through solid walls (limited range)"
category = "senses"
default_enabled = false

[[perks]]
id = "keen_eyes"
name = "Keen Eyes"
description = "Vision range increased by 25%"
category = "senses"
default_enabled = false

[[perks]]
id = "danger_sense"
name = "Danger Sense"
description = "Receives early warning of incoming threats"
category = "senses"
default_enabled = false

# ============================================================================
# DEFENSE & SURVIVAL
# ============================================================================

[[perks]]
id = "regeneration"
name = "Regeneration"
description = "Recover 1 HP per turn (always active, not suppressible)"
category = "survival"
default_enabled = false

[[perks]]
id = "poison_immunity"
name = "Poison Immunity"
description = "Cannot be poisoned or take poison damage"
category = "survival"
default_enabled = false

[[perks]]
id = "fire_immunity"
name = "Fire Immunity"
description = "Cannot be burned or take fire damage"
category = "survival"
default_enabled = false

[[perks]]
id = "fear_immunity"
name = "Fear Immunity"
description = "Cannot panic or be mind-controlled by fear effects"
category = "survival"
default_enabled = false

[[perks]]
id = "pain_immunity"
name = "Pain Immunity"
description = "Morale penalties from damage reduced by 50%"
category = "survival"
default_enabled = false

[[perks]]
id = "hardened"
name = "Hardened Skin"
description = "Armor rating +5 (equivalent to wearing extra armor)"
category = "defense"
default_enabled = false

[[perks]]
id = "shield_use"
name = "Shield Proficiency"
description = "Can equip and use shields (+10 armor when equipped)"
category = "defense"
default_enabled = false

# ============================================================================
# SOCIAL & MORALE
# ============================================================================

[[perks]]
id = "leadership"
name = "Leadership"
description = "Nearby allies gain +5% accuracy and +10 morale"
category = "social"
default_enabled = false

[[perks]]
id = "inspire"
name = "Inspire"
description = "Can use action to grant nearby allies +10 morale for 2 turns"
category = "social"
default_enabled = false

[[perks]]
id = "no_morale_penalty"
name = "No Morale Penalty"
description = "Unit is immune to morale loss from ally casualties"
category = "survival"
default_enabled = false

# ============================================================================
# SPECIAL ABILITIES
# ============================================================================

[[perks]]
id = "stealth"
name = "Stealth"
description = "Unit is harder to detect and leaves less sound"
category = "special"
default_enabled = false

[[perks]]
id = "mimic"
name = "Mimic"
description = "Unit can disguise as other unit types"
category = "special"
default_enabled = false

[[perks]]
id = "camouflage"
name = "Camouflage"
description = "Unit blends with environment (harder to spot)"
category = "special"
default_enabled = false

[[perks]]
id = "self_destruct"
name = "Self-Destruct"
description = "Unit can explode as final action (3 hex radius, 50 damage)"
category = "special"
default_enabled = false

[[perks]]
id = "mind_control"
name = "Mind Control"
description = "Unit can take control of other units temporarily"
category = "special"
default_enabled = false

[[perks]]
id = "shapeshift"
name = "Shapeshift"
description = "Unit can change form (visuals and stats)"
category = "special"
default_enabled = false
```

### 3. Load Perks into Engine

**File:** `engine/core/data_loader.lua` (EXTEND)

Add perk loading:

```lua
function DataLoader.loadPerks()
    local perksPath = "mods/core/rules/unit/perks.toml"
    local data = loadTOML(perksPath)
    
    if data and data.perks then
        local PerkSystem = require("battlescape.systems.perks_system")
        PerkSystem.loadFromTOML(data)
        print(string.format("[DataLoader] Loaded %d perks", #data.perks))
    end
end
```

Call in initialization:
```lua
function DataLoader.load()
    -- ... other loading ...
    DataLoader.loadPerks()
end
```

### 4. Integrate Perks with Units

**File:** `engine/basescape/logic/unit_system.lua` (EXTEND)

When creating units from class, initialize perks:

```lua
function UnitSystem.createUnit(classId, name)
    local classData = DataLoader.getUnitClass(classId)
    
    local unit = {
        -- ... other fields ...
        perks = {}
    }
    
    -- Initialize default perks from class
    if classData.perks then
        local PerkSystem = require("battlescape.systems.perks_system")
        for _, perkId in ipairs(classData.perks) do
            unit.perks[perkId] = true
        end
        PerkSystem.initUnit(unit.id, unit.perks)
    end
    
    return unit
end
```

### 5. Create Perks Documentation

**File:** `docs/content/unit_systems/perks.md` (NEW, 500+ lines)

Include:
- System overview
- All 40+ perk descriptions
- Per-class default perks
- Modding guide
- Examples

---

## Testing Checklist

- [ ] PerkSystem module loads without errors
- [ ] Perks TOML loads with all 40+ perks
- [ ] Can register new perks via API
- [ ] Can enable/disable perks on units
- [ ] Can check if unit has perk via `hasPerk()`
- [ ] Perks initialize correctly for units from classes
- [ ] PILOT and other units have correct default perks
- [ ] Game runs without errors

---

## Files Modified/Created

1. ✅ `engine/battlescape/systems/perks_system.lua` - New (300+ lines)
2. ✅ `mods/core/rules/unit/perks.toml` - New (150+ lines)
3. ✅ `engine/core/data_loader.lua` - Extended with loadPerks()
4. ✅ `engine/basescape/logic/unit_system.lua` - Extended with perk init
5. ✅ `docs/content/unit_systems/perks.md` - New documentation

---

## Related Tasks

- **TASK-PILOT-005:** Dual-Wield (uses two_weapon_proficiency perk)
- **TASK-PILOT-009:** Create 40+ Standard Perks
- **TASK-PILOT-010:** Update Unit Classes TOML (add perks to all classes)

---

## Notes

- Perks are purely boolean flags (no numeric values)
- Perks can be enabled/disabled at any time
- Default perks vary by class (defined in classes.toml)
- Modders can add custom perks to perks.toml
- Perks affect unit behavior through various systems (movement, combat, senses, etc.)

---

**Task Created:** October 23, 2025

