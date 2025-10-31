# Master Stat Table - AlienFall Unit Statistics

**Status:** Complete Reference
**Version:** 1.0
**Created:** 2025-10-31
**Last Updated:** 2025-10-31

---

## Overview

This document is the **authoritative source** for all unit statistics in AlienFall. It defines every stat, its range, applications, and calculation formulas. All game systems must reference this table for consistency.

**Key Principles:**
- All combat stats use 6-12 scale (standardized)
- Bonuses calculated as percentage multipliers
- Stats progress through unit advancement
- No stat exceeds hard caps without special conditions

---

## Section 1: Complete Stat Universe

### Core Combat Stats (6-12 Scale)

| Stat | Range | Base Value | Applications | Description |
|------|-------|------------|--------------|-------------|
| **Aim** | 6-12 | 7 (rookie) | Ranged accuracy, targeting | Determines hit chance for ballistic/energy weapons |
| **Melee** | 6-12 | 7 (rookie) | Close combat accuracy | Determines hit chance for hand-to-hand combat |
| **Reaction** | 6-12 | 7 (rookie) | Initiative, dodge, overwatch | Turn order position, defensive reactions |
| **Speed** | 6-12 | 7 (rookie) | Movement distance | Hexagons moved per movement action |
| **Bravery** | 6-12 | 6 (rookie) | Morale resistance | Resistance to panic and morale loss |
| **Sanity** | 6-12 | 7 (rookie) | Psychological resistance | Resistance to alien-induced mental effects |

### Specialized Stats

| Stat | Range | Base Value | Applications | Description |
|------|-------|------------|--------------|-------------|
| **Strength** | 5-15 | 7 (rookie) | Carry capacity, melee damage | Physical power and carrying ability |
| **Piloting** | 6-12 | 0 (untrained) | Craft control, evasion | Aircraft/spacecraft operation skills |
| **Psychic** | 2-12 | 0 (untrained) | Psionic abilities | Mental powers (rare, asymmetric range) |

### Resource Stats

| Stat | Range | Base Value | Applications | Description |
|------|-------|------------|--------------|-------------|
| **Health** | 50-200 | Varies by unit type | Damage absorption | Hit points before incapacitation |
| **Time Units (AP)** | 1-5 | 4 (standard) | Action economy | Actions available per turn |
| **Morale** | 0-12 | Equals Bravery | Combat effectiveness | Current psychological state |

---

## Section 2: Stat Ranges & Distributions

### Rookie Unit Generation (Starting Stats)

**Random Generation Formula:**
```
For each combat stat: Roll 1d6 + 5  (Results: 6-11)
Strength: Roll 1d4 + 4  (Results: 5-8)
Bravery: Roll 1d3 + 4  (Results: 5-7)
Sanity: Roll 1d2 + 5  (Results: 6-7)
```

**Typical Rookie Distributions:**
```
Stat        Min   Max   Mean   80% Range   Notes
─────────────────────────────────────────────────
Aim         6     11    7.5    6-9         Most rookies 7-8
Melee       6     11    7.5    6-9         Most rookies 7-8
Reaction    6     11    7.8    6-9         Slightly higher variance
Speed       6     11    7.5    6-9         Most rookies 7-8
Bravery     5     7     6.0    5-7         New recruits are anxious
Sanity      6     7     6.5    6-7         Start mentally healthy
Strength    5     8     6.5    5-8         Physical capability varies
```

### Elite Unit Ranges (End-Game)

**Maximum Achievable:**
```
Stat        Min   Max   Typical Elite   Notes
─────────────────────────────────────────────
Aim         9     12    10-11           Veteran marksmen
Melee       9     12    10-11           Trained fighters
Reaction    9     12    11-12           Battle-hardened
Speed       8     12    9-12            Specialized roles
Bravery     9     12    10-11           Combat veterans
Sanity      6     12    8-10            Variable experience
Strength    8     15    10-12           Enhanced training
Piloting    6     12    9-12            Ace pilots
```

### Unit Type Modifiers (Applied After Base Roll)

```
Unit Type       Aim   Melee   Reaction   Speed   Bravery   Sanity   Strength
───────────────────────────────────────────────────────────────────────────
Soldier         +0    +0      +0         +0      +1        +0       +0
Assault         -1    +2      +0         +0      +1        -1       +2
Scout           +1    -1      +1         +1      -1        +0       -1
Medic           -1    +0      +0         +0      +1        +2       +0
Support         +0    +0      +1         +0      +0        +1       +0
Heavy Weapons   +0    +0      -1         -1      +0        +0       +3
Sniper          +2    -1      +1         +0      +0        -1       +0
```

---

## Section 3: Stat Progression & Growth

### Experience-Based Growth

**Growth Rates (per stat point gained):**
```
Stat        Missions Required   Typical Triggers
─────────────────────────────────────────────────
Aim         8-12 missions       Ranged combat kills
Melee       10-15 missions      Close combat engagements
Reaction    12-18 missions      Surviving firefights
Speed       15-20 missions      Extended movement
Bravery     6-10 missions       Squad casualties overcome
Sanity      20-30 missions      Alien exposure survival
Strength    12-18 missions      Heavy equipment usage
Piloting    8-12 missions       Successful craft operations
```

### Diminishing Returns (Elite Units)

**Growth Penalty by Rank:**
```
Rank Level    Growth Multiplier   Notes
───────────────────────────────────────
Ranks 1-3     100% (full gains)   Normal progression
Rank 4        75% (reduced)       Elite specialization
Rank 5+       50% (halved)        Master level caps
```

**Example: Aim Stat Progression**
```
Starting: 7
After 10 missions: 8 (+100%)
After 20 missions: 9 (+75% of normal)
After 30 missions: 9.375 → 9.4 (+50% of normal)
After 40 missions: 9.7 → 9.7 (+50% of normal)
Max achievable: 12 (hard cap)
```

### Soft Caps & Limits

**Soft Cap Effects:**
```
Stat        Soft Cap   Effect After Cap
───────────────────────────────────────
Aim         11         Halved gains (50% effective)
Bravery     10         Morale loss +5% extra severe
Sanity      9          Recovery slowed by 20%
Strength    12         Carry penalties increase
```

---

## Section 4: Bonus Calculation Formulas

### Standardized Bonus Template

**All stat bonuses follow this pattern:**
```
Bonus Percentage = (Stat - 6) × Rate
Applied Modifier = Base Value × (1 + Bonus Percentage)
```

### Complete Bonus Matrix

| Stat | Application | Rate | Formula | Example (Stat 10) |
|------|-------------|------|---------|-------------------|
| **Aim** | Ranged accuracy | 5% per point | `Base% × (1 + (Aim-6)×0.05)` | 70% × 1.20 = 84% |
| **Melee** | Melee damage | 3% per point | `Base DMG × (1 + (Melee-6)×0.03)` | 15 × 1.12 = 16.8 |
| **Reaction** | Initiative bonus | +2 per point | `Turn Order + (Reaction-6)×2` | +8 initiative |
| **Speed** | Movement hexes | Direct | `Movement = Speed hexes per AP` | 10 hexes per AP |
| **Bravery** | Morale loss reduction | -5% per point | `Loss × (1 - (Bravery-6)×0.05)` | 30% less morale loss |
| **Sanity** | Panic resistance | -5% per point | `Panic × (1 - (Sanity-6)×0.05)` | 30% less panic chance |
| **Strength** | Carry capacity | +2 kg per point | `50 + (Strength-5)×2 kg` | 54 kg capacity |
| **Piloting** | Craft evasion | +3% per point | `5% + (Piloting-6)×3%` | 17% evasion |

### Lua Implementation Reference

```lua
-- Stat bonus calculation functions
function get_aim_accuracy_bonus(aim_stat)
    return (aim_stat - 6) * 0.05  -- +5% per point above 6
end

function get_melee_damage_bonus(melee_stat)
    return (melee_stat - 6) * 0.03  -- +3% damage per point
end

function get_reaction_initiative_bonus(reaction_stat)
    return (reaction_stat - 6) * 2  -- +2 initiative per point
end

function get_speed_movement_hexes(speed_stat)
    return speed_stat  -- Direct: stat = hexes per movement action
end

function get_bravery_morale_reduction(bravery_stat)
    return (bravery_stat - 6) * 0.05  -- -5% morale loss per point
end

function get_sanity_panic_reduction(sanity_stat)
    return (sanity_stat - 6) * 0.05  -- -5% panic chance per point
end

function get_strength_carry_capacity(strength_stat)
    return 50 + (strength_stat - 5) * 2  -- Base 50kg + 2kg per point
end

function get_piloting_evasion_bonus(piloting_stat)
    return 0.05 + (piloting_stat - 6) * 0.03  -- 5% base + 3% per point
end
```

---

## Section 5: Trait & Equipment Modifiers

### Permanent Trait Bonuses

| Trait | Stats Affected | Bonus Amount | Notes |
|-------|----------------|--------------|-------|
| **Quick Reflexes** | Reaction | +2 | Rank 2+ requirement |
| **Sharp Eyes** | Aim | +1 | Passive perception |
| **Strong Will** | Bravery | +2 | Mental resilience |
| **Iron Lungs** | Sanity | +1 | Poison resistance |
| **Heavy Build** | Strength | +2 | Physical power |
| **Commanding Presence** | Bravery (squad) | +1 nearby | Leadership aura |
| **Natural Medic** | Sanity (allied) | +1 nearby | Healing bonus |

### Temporary Status Effects

| Status | Stats Affected | Penalty | Duration |
|--------|----------------|---------|----------|
| **Suppression** | Aim | -2 | Until cover reached |
| **Bleeding** | Reaction | -1 | Until healed |
| **Burning** | Bravery | -2 | Until extinguished |
| **Poisoned** | Sanity | -1 | Until antidote |
| **Stunned** | All | -4 | 1-2 turns |

### Equipment Modifiers

| Equipment | Stat Modified | Modifier | Context |
|-----------|----------------|----------|---------|
| **Rifle Scope** | Aim | +1 | Ranged weapons |
| **Body Armor** | Speed | -1 | Heavy armor |
| **Combat Stimulant** | Bravery | +2 | Mission duration |
| **Psi Armor** | Sanity | +3 | Anti-psychic |
| **Exoskeleton** | Strength | +2 | Power assistance |

---

## Section 6: Strength Stat - Complete Specification

### Range & Generation
```
Rookie Range: 5-8 (1d4 + 4)
Elite Range: 8-15 (maximum 15)
Hard Cap: 15 (superhuman limit)
Soft Cap: 12 (diminishing returns)
```

### Primary Applications

#### 1. Carry Capacity
```
Base Capacity: 50 kg
Per Point Bonus: +2 kg per point above 5
Formula: Capacity = 50 + (Strength - 5) × 2

Examples:
Strength 5: 50 kg (minimum)
Strength 7: 54 kg (rookie average)
Strength 10: 60 kg (veteran)
Strength 15: 70 kg (maximum)
```

#### 2. Melee Damage Bonus
```
Bonus Damage: +2 per point above 5
Formula: Melee Bonus = (Strength - 5) × 2

Examples:
Strength 5: +0 damage
Strength 7: +4 damage
Strength 10: +10 damage
Strength 15: +20 damage
```

#### 3. Climbing/Jumping (Situational)
```
Climbing AP Cost: 2-3 AP, reduced by 0.5 per point above 8
Jumping Distance: 1 + (Strength-5)÷2 hexes

Examples:
Strength 10: Climbing 1.5 AP, Jump 2.5 hexes
Strength 15: Climbing 0.5 AP, Jump 5 hexes
```

### Equipment Restrictions

| Equipment Type | Strength Required | Penalty if Below |
|----------------|-------------------|------------------|
| **Plasma Rifle** | 8 | -20% accuracy |
| **Heavy Armor** | 10 | -1 movement hex |
| **Rocket Launcher** | 12 | -2 AP to fire |
| **Mining Laser** | 7 | Cannot carry more than 1 |

### Progression
```
Gain Rate: +0.02 per 50 kg carried (encourages heavy equipment)
Training: +1 from "Strength Training" facility (monthly)
Trait: "Strong Build" starts with +2 Strength
Maximum: 15 (only with specific cybernetic enhancements)
```

---

## Section 7: Validation & Testing

### Stat Range Validation

**Unit Creation Test:**
```lua
function validate_unit_stats(unit)
    assert(unit.aim >= 6 and unit.aim <= 12, "Aim out of range")
    assert(unit.melee >= 6 and unit.melee <= 12, "Melee out of range")
    assert(unit.reaction >= 6 and unit.reaction <= 12, "Reaction out of range")
    assert(unit.speed >= 6 and unit.speed <= 12, "Speed out of range")
    assert(unit.bravery >= 6 and unit.bravery <= 12, "Bravery out of range")
    assert(unit.sanity >= 6 and unit.sanity <= 12, "Sanity out of range")
    assert(unit.strength >= 5 and unit.strength <= 15, "Strength out of range")
    return true
end
```

### Bonus Calculation Tests

**Accuracy Bonus Test:**
```lua
function test_aim_bonus()
    local base_accuracy = 0.70  -- 70%
    local aim_stat = 10
    local bonus = (aim_stat - 6) * 0.05  -- 0.20 (20%)
    local final_accuracy = base_accuracy * (1 + bonus)  -- 0.84 (84%)
    assert(final_accuracy == 0.84, "Aim bonus calculation failed")
end
```

### Progression Tests

**Stat Growth Test:**
```lua
function test_stat_progression()
    local unit = {aim = 7, missions = 0}
    -- Simulate 10 missions with aim usage
    for i = 1, 10 do
        unit.aim = unit.aim + 0.1  -- +0.1 per mission
        unit.missions = unit.missions + 1
    end
    assert(unit.aim == 8.0, "Stat progression failed")
    assert(unit.missions == 10, "Mission count failed")
end
```

---

## Section 8: Quick Reference Tables

### Stat Summary Table

| Stat | Range | Typical Rookie | Elite Max | Primary Use |
|------|-------|----------------|-----------|-------------|
| Aim | 6-12 | 7 | 12 | Ranged accuracy |
| Melee | 6-12 | 7 | 12 | Close combat |
| Reaction | 6-12 | 7 | 12 | Initiative/dodge |
| Speed | 6-12 | 7 | 12 | Movement |
| Bravery | 6-12 | 6 | 12 | Morale |
| Sanity | 6-12 | 7 | 12 | Psychology |
| Strength | 5-15 | 7 | 15 | Physical power |
| Piloting | 6-12 | 0 | 12 | Craft control |

### Bonus Rate Quick Reference

```
Stat Bonus Rates:
- Aim: +5% accuracy per point above 6
- Melee: +3% damage per point above 6
- Reaction: +2 initiative per point above 6
- Speed: +1 hex movement per point (direct)
- Bravery: -5% morale loss per point above 6
- Sanity: -5% panic chance per point above 6
- Strength: +2 kg carry per point above 5
- Piloting: +3% evasion per point above 6
```

---

## Cross-References

This Master Stat Table is referenced by:
- `design/mechanics/Units.md` - Core unit definitions
- `design/mechanics/Pilots.md` - Piloting stat applications
- `design/mechanics/Items.md` - Equipment stat requirements
- `design/mechanics/DamageTypes.md` - Accuracy calculations
- `design/mechanics/Battlescape.md` - Combat resolution
- `design/mechanics/MoraleBraverySanity.md` - Psychological stats
- `api/GAME_API.toml` - Stat validation schema

---

## Change Log

- **v1.0** (2025-10-31): Complete master stat table with all ranges, formulas, and examples
  - Defined all 9 core stats with ranges and applications
  - Standardized bonus calculation formulas
  - Added Strength stat complete specification
  - Included Lua reference code and validation tests
  - Created progression curves and soft caps</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\MASTER_STAT_TABLE.md
