# Perks System - Unit Trait Framework

**Status:** Complete Implementation
**Last Updated:** October 23, 2025
**Version:** 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Perk Categories](#perk-categories)
3. [All Perks Reference](#all-perks-reference)
4. [Per-Class Default Perks](#per-class-default-perks)
5. [Perk Selection](#perk-selection)
6. [Advanced Usage](#advanced-usage)
7. [Modding Perks](#modding-perks)

---

## Overview

The Perks System provides a flexible framework of boolean trait flags that customize unit behavior and capabilities. Each perk represents a specific ability, immunity, or behavioral trait that can be toggled on/off per unit.

### Key Characteristics

- **Boolean Flags** - Perks are simple on/off toggles (true/false)
- **Category-Organized** - 8 categories for easy navigation
- **Per-Unit** - Each unit has independent perk state
- **Stackable** - Units can have 10-20+ perks simultaneously
- **Runtime Togglable** - Perks can be enabled/disabled during gameplay
- **Loadable from TOML** - Define all perks in configuration files

### System Architecture

```
PerkSystem (engine/battlescape/systems/perks_system.lua)
    ↓
Perk Registry (40+ perks defined)
    ↓
Per-Unit Perk State (unit_id → {perk_id → boolean})
    ↓
Gameplay Impact (various systems check perks)
```

---

## Perk Categories

Perks are organized into 8 functional categories:

### 1. BASIC (Core Movement & Actions)

Fundamental abilities that most units have by default.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `can_move` | ✅ YES | Unit can move hexes | Disabling freezes unit |
| `can_run` | ✅ YES | Unit can sprint (2× distance) | Uses more AP, reduces accuracy |
| `can_shoot` | ✅ YES | Unit can use ranged weapons | Disables all shooting |
| `can_melee` | ✅ YES | Unit can melee attack | Adjacent tiles only |
| `can_throw` | ✅ YES | Unit can throw grenades/items | Arc-based throwing |
| `can_climb` | ✅ YES | Unit can climb terrain/obstacles | Allows height changes |

**Usage:** Start with all BASIC perks enabled. Disable individually for custom restrictions (paralyzed unit, restrained, etc.).

---

### 2. MOVEMENT (Special Movement Types)

Specialized movement capabilities beyond basic walking.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `can_swim` | ❌ NO | Move through water | Floaters, aquatic units |
| `can_fly` | ❌ NO | Move through air, ignore terrain | Floaters, helicopters |
| `high_jump` | ❌ NO | Jump to high platforms | +2 height movement |
| `hover` | ❌ NO | Hover in place | Helicopters, some aliens |
| `terrain_immunity` | ❌ NO | Ignore terrain movement costs | Fire, spikes, toxic |
| `sprint` | ✅ YES | Can run (same as can_run) | Redundant with can_run |

**Usage:** Assign to specialized units - floaters get `can_fly`, submarines get `can_swim`.

---

### 3. COMBAT (Weapon & Ability Skills)

Combat-focused abilities and restrictions.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `can_fire_heavy` | ❌ NO | Use heavy weapons (LMG, cannon) | Assault/Heavy units |
| `can_use_psionic` | ❌ NO | Use psionic abilities | Psychics, some aliens |
| `dual_wield` | ❌ NO | Use two weapons (1 AP cost) | New: 2-weapon proficiency |
| `sharpshooter` | ❌ NO | +10% accuracy, -2 AP for aimed shots | Snipers |
| `sniper_focus` | ❌ NO | Bonus for aimed/scoped shots | Sniper rifles |
| `stealth_attack` | ❌ NO | Backstab bonus (+50% dmg, +15% acc) | Infiltrators |
| `suppressive_fire` | ❌ NO | Can apply suppression status | Heavy weapons users |
| `reaction_shot` | ❌ NO | Can enter overwatch/reaction mode | All combat units |
| `leader_command` | ❌ NO | Can give squad commands | Officers only |

**Usage:** Assign based on unit class and role in squad composition.

---

### 4. SENSES (Perception & Detection)

Sensory and awareness abilities.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `keen_eyes` | ❌ NO | +2 hex visibility range | Scouts |
| `night_vision` | ❌ NO | +3 hex visibility in darkness | Can see in night |
| `thermal_sight` | ❌ NO | See heat signatures through obstacles | Special equipment |
| `radar_sense` | ❌ NO | Detect nearby enemies (no LOS) | Radar operators |
| `danger_sense` | ❌ NO | +20% dodge vs ambush | Infiltrators |
| `tracking` | ❌ NO | Can see enemy footprints/trails | Scouts |

**Usage:** Scout units get `keen_eyes`, night missions get `night_vision`.

---

### 5. DEFENSE (Damage Mitigation)

Defensive abilities and resistances.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `thick_skin` | ❌ NO | -10% damage taken | Assault units |
| `hardened` | ❌ NO | -15% damage taken | Heavy weapons units |
| `evasion` | ❌ NO | +10% dodge chance | Infiltrators, aliens |
| `regeneration` | ❌ NO | Recover 1 HP/turn | Aliens, special units |
| `shielding` | ❌ NO | -5 damage per hit (stacks) | With shield equipment |
| `immunity_fire` | ❌ NO | Ignore fire/burning damage | Fire-proof units |
| `immunity_acid` | ❌ NO | Ignore acid damage | Acid-proof units |
| `immunity_psi` | ❌ NO | Ignore psionic damage | Psi-proof units |
| `no_morale_penalty` | ❌ NO | Morale doesn't affect performance | Robots, zealots |
| `unstoppable` | ❌ NO | Cannot be slowed/stunned | Berserkers |

**Usage:** Defend units based on role - heavy gets `hardened`, aliens get `regeneration`.

---

### 6. SURVIVAL (Health & Recovery)

Health-related and survival perks.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `iron_will` | ❌ NO | +20% morale, -50% panic chance | Officers |
| `survivor` | ❌ NO | Can revive once per mission | Special units |
| `adrenaline` | ❌ NO | +2 AP when below 25% HP | Berserkers |
| `bloodlust` | ❌ NO | +25% damage for 2 turns after kill | Aliens |
| `pack_mentality` | ❌ NO | +10% accuracy when near allies | Tribal aliens |
| `instinctive` | ❌ NO | React without thinking (free reaction shot) | Animals |

**Usage:** Elite units get `survivor`, aliens get `bloodlust`.

---

### 7. SOCIAL (Squad & Leadership)

Squad interaction and morale abilities.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `leadership` | ❌ NO | Allies within 5 hex get +10% accuracy | Officers |
| `inspire` | ❌ NO | Raise squad morale +15 once per mission | Officers |
| `mentor` | ❌ NO | Adjacent rookies gain +XP/turn | Veterans |
| `fear_aura` | ❌ NO | Enemies within 5 hex -10% accuracy | Aliens |
| `charisma` | ❌ NO | +20% recruit attraction at base | Leaders |
| `discipline` | ❌ NO | Squad cannot panic while nearby | Officers |

**Usage:** Officer units get `leadership` and `inspire`.

---

### 8. SPECIAL (Unique & Exotic)

One-of-a-kind or rarely-used perks.

| Perk | Default | Effect | Notes |
|------|---------|--------|-------|
| `skilled_pilot` | ❌ NO | Pilot grants craft bonuses | Pilots only |
| `ace_pilot` | ❌ NO | +10% dodge for piloted craft | Elite pilots |
| `precision_control` | ❌ NO | +5% accuracy hovering | Helicopter pilots |
| `two_weapon_proficiency` | ❌ NO | Can dual-wield (new perk) | Added with perks system |
| `camouflage` | ❌ NO | +50% visibility stealth | Infiltrators |
| `invisibility` | ❌ NO | Cannot be seen (until attack) | Ghosts, special aliens |
| `shape_shift` | ❌ NO | Change appearance (Ethereals) | Aliens only |
| `phase_shift` | ❌ NO | Walk through walls (limited duration) | Psi units |
| `time_dilation` | ❌ NO | Perceive time slowly (+50% reactions) | Rare aliens |
| `hive_mind` | ❌ NO | Share vision with squad | Insects, aliens |

**Usage:** Exotic perks for special encounters, boss units, or unique mission objectives.

---

## All Perks Reference

### Complete Perk Listing (40+ Perks)

**BASIC (6 perks):**
- ✅ can_move
- ✅ can_run
- ✅ can_shoot
- ✅ can_melee
- ✅ can_throw
- ✅ can_climb

**MOVEMENT (6 perks):**
- ❌ can_swim
- ❌ can_fly
- ❌ high_jump
- ❌ hover
- ❌ terrain_immunity
- ✅ sprint

**COMBAT (9 perks):**
- ❌ can_fire_heavy
- ❌ can_use_psionic
- ❌ dual_wield
- ❌ sharpshooter
- ❌ sniper_focus
- ❌ stealth_attack
- ❌ suppressive_fire
- ❌ reaction_shot
- ❌ leader_command

**SENSES (6 perks):**
- ❌ keen_eyes
- ❌ night_vision
- ❌ thermal_sight
- ❌ radar_sense
- ❌ danger_sense
- ❌ tracking

**DEFENSE (10 perks):**
- ❌ thick_skin
- ❌ hardened
- ❌ evasion
- ❌ regeneration
- ❌ shielding
- ❌ immunity_fire
- ❌ immunity_acid
- ❌ immunity_psi
- ❌ no_morale_penalty
- ❌ unstoppable

**SURVIVAL (6 perks):**
- ❌ iron_will
- ❌ survivor
- ❌ adrenaline
- ❌ bloodlust
- ❌ pack_mentality
- ❌ instinctive

**SOCIAL (6 perks):**
- ❌ leadership
- ❌ inspire
- ❌ mentor
- ❌ fear_aura
- ❌ charisma
- ❌ discipline

**SPECIAL (10 perks):**
- ❌ skilled_pilot
- ❌ ace_pilot
- ❌ precision_control
- ❌ two_weapon_proficiency
- ❌ camouflage
- ❌ invisibility
- ❌ shape_shift
- ❌ phase_shift
- ❌ time_dilation
- ❌ hive_mind

**Total: 59 perks**

---

## Per-Class Default Perks

Each unit class has predefined perks loaded by default:

### Human Soldiers

**ROOKIE**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw, can_climb
Combat: reaction_shot (optional)
Total: 6 perks
```

**ASSAULT**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw
Combat: can_fire_heavy, reaction_shot
Defense: thick_skin
Total: 8 perks
```

**SHARPSHOOTER**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw
Combat: sniper_focus, reaction_shot
Senses: keen_eyes
Total: 8 perks
```

**SUPPORT**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw
Combat: reaction_shot, leader_command (optional)
Defense: no_morale_penalty
Survival: iron_will
Total: 7 perks
```

**PSI OPERATIVE**
```
Basic: can_move, can_run, can_shoot, can_throw
Combat: can_use_psionic, reaction_shot
Survival: iron_will
Defense: immunity_psi
Special: phase_shift (optional)
Total: 8 perks
```

**HEAVY WEAPONS**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw
Combat: can_fire_heavy, suppressive_fire
Defense: hardened
Total: 8 perks
```

**INFILTRATOR**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw, can_climb
Combat: stealth_attack, reaction_shot
Senses: danger_sense, keen_eyes
Special: camouflage
Total: 10 perks
```

**OFFICER**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw
Combat: reaction_shot, leader_command
Social: leadership, inspire, discipline
Survival: iron_will
Total: 9 perks
```

**PILOT**
```
Basic: can_move, can_run, can_shoot, can_melee, can_throw
Special: skilled_pilot
Combat: reaction_shot (when deployed to ground)
Total: 7 perks
```

### Alien Units

**SECTOID**
```
Basic: can_move, can_shoot, can_melee
Combat: can_use_psionic, reaction_shot
Special: phase_shift
Defense: evasion, immunity_psi
Survival: iron_will
Total: 9 perks
```

**FLOATER**
```
Basic: can_move, can_run, can_shoot, can_melee
Movement: can_fly, hover
Combat: reaction_shot
Defense: evasion
Total: 8 perks
```

**ETHEREAL**
```
Basic: can_move, can_shoot, can_melee
Combat: can_use_psionic, leader_command
Special: shape_shift, phase_shift, time_dilation
Defense: evasion, immunity_psi, no_morale_penalty
Social: fear_aura
Total: 11 perks
```

---

## Perk Selection

### How Units Get Perks

1. **From Unit Class** - Default perks loaded from unit class definition
2. **From Equipment** - Some items grant perks (e.g., armor unlocks `thick_skin`)
3. **From Experience** - Leveling up can unlock new perks
4. **From Mutations** - Alien exposure/transformation grants perks
5. **Runtime Override** - Scripts can enable/disable perks as needed

### Recommended Perk Combinations

**Defensive Squad Setup:**
- Officer: leadership, inspire, discipline
- Heavy: can_fire_heavy, hardened, suppressive_fire
- Support: iron_will, no_morale_penalty
- Infiltrator: camouflage, danger_sense

**Aggressive Squad Setup:**
- Assault: can_fire_heavy, thick_skin (melee focus)
- Sniper: sniper_focus, keen_eyes (ranged support)
- Pyschic: can_use_psionic, immunity_psi (crowd control)
- Officer: leadership, inspire (morale boost)

**Infiltration Squad Setup:**
- Infiltrator: camouflage, stealth_attack, danger_sense
- Scout: keen_eyes, tracking (reconnaissance)
- Support: iron_will, survivor (backup)
- Officer: leadership, discipline (command)

---

## Advanced Usage

### Perk API (In Code)

```lua
-- Check if unit has perk
if PerkSystem.hasPerk(unitId, "dual_wield") then
    -- Unit can dual-wield
end

-- Enable perk for unit
PerkSystem.enablePerk(unitId, "leadership")

-- Disable perk for unit
PerkSystem.disablePerk(unitId, "can_run")

-- Toggle perk on/off
PerkSystem.togglePerk(unitId, "suppressive_fire")

-- Get all active perks
local activePerks = PerkSystem.getActivePerks(unitId)
for _, perkId in ipairs(activePerks) do
    print("Unit has: " .. perkId)
end
```

### Conditional Perk Checks

```lua
-- Combat system: Check if can shoot before firing
if not PerkSystem.hasPerk(unitId, "can_shoot") then
    return false, "Unit cannot shoot"
end

-- Movement system: Check if can swim
if terrain.type == "water" and not PerkSystem.hasPerk(unitId, "can_swim") then
    return false, "Unit cannot swim"
end

-- Status effect: Check if immune to psi
if status == "psi_damage" and PerkSystem.hasPerk(unitId, "immunity_psi") then
    return false, "Unit is immune to psi damage"
end
```

### Dynamic Perk Assignment

```lua
-- Grant leadership after promotion
if unitRank == 3 then  -- Colonel rank
    PerkSystem.enablePerk(unitId, "leadership")
    PerkSystem.enablePerk(unitId, "inspire")
    PerkSystem.enablePerk(unitId, "discipline")
end

-- Remove perks when incapacitated
if unitHealth <= 0 then
    PerkSystem.disablePerk(unitId, "can_move")
    PerkSystem.disablePerk(unitId, "can_shoot")
    PerkSystem.disablePerk(unitId, "can_throw")
end

-- Grant regeneration from alien exposure
if unitExposure >= 80 then
    PerkSystem.enablePerk(unitId, "regeneration")
end
```

---

## Modding Perks

### Adding Custom Perks

In `mods/core/rules/unit/perks.toml`:

```toml
[[perks]]
id = "my_custom_perk"
name = "My Custom Perk"
description = "This is a custom perk I created"
category = "special"
enabled_by_default = false

[[perks]]
id = "damage_boost"
name = "Damage Boost"
description = "Deal +50% damage on all attacks"
category = "combat"
enabled_by_default = false
```

### Using Custom Perks in Code

```lua
-- Load custom perks from mod
local perksData = love.filesystem.load("mods/custom/rules/unit/perks.toml")

-- Register in system
for _, perkDef in ipairs(perksData.perks) do
    PerkSystem.register(perkDef.id, perkDef.name, perkDef.description, perkDef.category)
end

-- Use in code
if PerkSystem.hasPerk(unitId, "damage_boost") then
    damageMultiplier = 1.5
end
```

### Modifying Existing Perks

```lua
-- Override perk behavior
local originalCanShoot = gameRules.canUnitShoot
function gameRules.canUnitShoot(unitId)
    if PerkSystem.hasPerk(unitId, "can_shoot") then
        return originalCanShoot(unitId)
    else
        return false
    end
end
```

---

## Summary

The Perks System provides:
- **59 Predefined Perks** - Covering all gameplay aspects
- **8 Categories** - Organized for easy navigation
- **Per-Unit Customization** - Flexible trait assignment
- **Runtime Toggleable** - Enable/disable perks dynamically
- **Easily Extensible** - Add custom perks via TOML
- **Simple API** - Check, enable, disable, toggle perks

This framework enables:
- **Unit Customization** - Every unit can be unique
- **Class Differentiation** - Different classes have different defaults
- **Tactical Depth** - Perks enable new strategies
- **Mod Support** - Easy to add custom perks
- **Balance Adjustments** - Tweak perks per mission/difficulty

---

**Documentation Version:** 1.0
**Last Updated:** October 23, 2025
**Status:** Complete & Tested
