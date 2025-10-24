# Pilot System - Aircraft Operators & Progression

**Status:** Complete Implementation
**Last Updated:** October 23, 2025
**Version:** 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Pilot Classes](#pilot-classes)
3. [Progression System](#progression-system)
4. [Pilot Bonuses](#pilot-bonuses)
5. [Specialization](#specialization)
6. [Best Practices](#best-practices)
7. [Modding Pilots](#modding-pilots)

---

## Overview

Pilots are specialized units trained to operate aircraft during interception combat. Unlike ground troops who gain experience through both ground battles and interception, pilots gain experience exclusively from interception combat, making them specialized operators rather than combat troops.

### Key Differences from Combat Units

| Aspect | Ground Units | Pilots |
|--------|-------------|--------|
| **Experience Source** | Ground battles + Interception | Interception only |
| **Progression Speed** | Slower (balanced) | Faster (specialized) |
| **Ground Deployment** | Primary role | Secondary role |
| **Craft Bonuses** | None | Yes (stat transfer) |
| **Retirement** | Post-mission recovery | Minimal (pilots recover 100% between missions) |

### Pilot Roles in Missions

1. **Interception Craft Operation** - Pilots fly craft in space/air combat
2. **Ground Unit (Emergency)** - Can be deployed as combat troops if craft lands
3. **Support Role** - Pilots can crew ground operations when craft is not in combat

---

## Pilot Classes

Four pilot specializations handle different aircraft types and roles:

### 1. PILOT (Standard Pilot)

**Stats:**
```
Health: 50 | Strength: 5 | Speed: 8 | Aim: 7 | Reaction: 8 | Energy: 10 | Wisdom: 6 | Psi: 0
```

**Role:** General-purpose pilot for any non-specialized craft
**Tier:** 2 (Intermediate)

**Strengths:**
- Balanced stats for multiple aircraft types
- Good all-around performance
- Can operate most aircraft

**Weaknesses:**
- No specialization bonuses
- Not optimal for any specific aircraft type

**Best For:** Transport (Skyranger), Scout (Condor), mixed-role squadrons

---

### 2. FIGHTER_PILOT (Interceptor Specialist)

**Stats:**
```
Health: 55 | Strength: 6 | Speed: 9 | Aim: 8 | Reaction: 9 | Energy: 10 | Wisdom: 7 | Psi: 0
```

**Role:** Elite dogfighting specialist for interceptor craft
**Tier:** 3 (Elite)

**Strengths:**
- Highest speed (9) for maximum maneuverability
- Highest reaction (9) for rapid targeting
- High aim (8) for accurate weapon locks
- Ace pilot bonus for advanced flying maneuvers

**Weaknesses:**
- Lower health (55) than heavy pilots
- Poor at long-range strategic flying

**Best For:** Lightning (Interceptor), dogfighting scenarios, UFO interception

**Special Perks:**
- `skilled_pilot` - Craft bonuses
- `ace_pilot` - Advanced piloting maneuvers (+10% dodge)
- `sharpshooter` - Better weapon accuracy

---

### 3. BOMBER_PILOT (Heavy Craft Specialist)

**Stats:**
```
Health: 60 | Strength: 7 | Speed: 7 | Aim: 6 | Reaction: 7 | Energy: 12 | Wisdom: 7 | Psi: 0
```

**Role:** Heavy payload specialist for transport and bomber craft
**Tier:** 2 (Intermediate)

**Strengths:**
- Highest strength (7) for stable heavy craft control
- Higher health (60) for survivability
- Higher energy (12) for long missions
- Steady hand perk reduces accuracy losses during heavy maneuvers

**Weaknesses:**
- Lower speed (7) than fighter pilots
- Slower reactions for dogfighting
- Lower aim for precise targeting

**Best For:** Avenger (Bomber), Skyranger (Transport), long-range missions

**Special Perks:**
- `skilled_pilot` - Craft bonuses
- `steady_hand` - Reduced accuracy loss during maneuvers
- `iron_constitution` - Better damage resistance

---

### 4. HELICOPTER_PILOT (VTOL Specialist)

**Stats:**
```
Health: 55 | Strength: 5 | Speed: 7 | Aim: 7 | Reaction: 9 | Energy: 10 | Wisdom: 8 | Psi: 0
```

**Role:** Vertical takeoff/landing specialist for VTOL aircraft
**Tier:** 2 (Intermediate)

**Strengths:**
- Highest reaction (9) for precise hover control
- Higher wisdom (8) for spatial awareness
- Excellent at low-altitude maneuvering
- Precision control perk enables stable hovering

**Weaknesses:**
- Lower speed than fighter pilots
- Lower strength than bomber pilots

**Best For:** VTOL aircraft, low-altitude operations, precise maneuvers

**Special Perks:**
- `skilled_pilot` - Craft bonuses
- `precision_control` - Hover bonuses (+5% accuracy while hovering)
- `steady_aim` - Better accuracy during hovering

---

## Progression System

Pilots progress through a simplified 3-rank system focused on interception excellence:

### Rank Progression

| Rank | Name | XP Range | Stat Bonuses | Abilities |
|------|------|----------|--------------|-----------|
| 0 | **Rookie** | 0-99 XP | Base stats | Basic operations |
| 1 | **Veteran** | 100-299 XP | +1 Speed, +1 Aim, +1 Reaction | Enhanced dodging |
| 2 | **Ace** | 300+ XP | +2 Speed, +2 Aim, +2 Reaction | Master maneuvers |

### Stat Progression Formula

Each rank increase grants:
- **Speed +1** - Faster maneuverability and movement
- **Aim +1** - Better weapon accuracy
- **Reaction +1** - Quicker response times

**Example:** Fighter Pilot progression:
```
Rookie:   Speed 9 → AIM 8 → Reaction 9
Veteran:  Speed 10 → Aim 9 → Reaction 10
Ace:      Speed 11 → Aim 10 → Reaction 11
```

### XP Gain System

Pilots gain experience exclusively from interception victories:

| Event | XP Award | Notes |
|-------|----------|-------|
| Enemy Defeated | 50 + (Enemy HP / 10) | Based on enemy difficulty |
| Mission Success | +100 | Bonus for completing mission |
| UFO Destroyed | +200 | Bonus for destroying UFO |
| Perfect Mission | +50 | No damage taken |

**Example:**
- Shooting down a UFO with 150 HP = 50 + (150/10) = 65 XP
- Plus mission success bonus = 100 XP
- Plus UFO destroyed bonus = 200 XP
- **Total: 365 XP = Promotion from Rookie to Veteran**

### Recovery Between Missions

**Key Feature:** Pilots recover 100% between missions regardless of injuries.

Unlike ground troops that suffer wounds and require medical recovery:
- Pilots don't accumulate wounds
- Pilots don't require recovery time
- Pilots are ready for next mission immediately
- Focus is on interception experience, not ground combat

---

## Pilot Bonuses

Pilot stats directly transfer to craft stats, enhancing performance during interception:

### Bonus Formula

```
Craft Bonus = (Pilot Stat - 5) / 100 × Bonus Multiplier
```

**Example:** Fighter Pilot with Speed 9:
```
Bonus = (9 - 5) / 100 × 1 = 4% Speed Bonus to craft
```

### Bonus Mapping

| Pilot Stat | Craft Effect | Per-Point | Max Bonus |
|-----------|--------------|-----------|-----------|
| **Speed** | Craft Speed | +1% | +30% |
| **Aim** | Weapon Accuracy | +1% | +25% |
| **Reaction** | Evasion/Dodge | +1% | +25% |
| **Strength** | Weapon Damage | +0.5% | +20% |
| **Energy** | Energy Pool | +2% | +25% |
| **Wisdom** | Sensor Range | +5% | +30% |
| **Psi** | Psionic Defense | +0.5% | +15% |

### Multi-Pilot Stacking

When multiple pilots operate the same craft (co-pilot configurations):

```
Combined Bonus = (Pilot1 Bonus + Pilot2 Bonus) / Number of Pilots
```

**With Diminishing Returns:**
- First pilot contributes 100% of bonuses
- Second pilot contributes 75% of bonuses
- Third pilot contributes 50% of bonuses
- Each additional pilot -25% contribution

**Example: Two Fighter Pilots (Speed 9):**
```
Pilot 1: (9-5) = 4% speed bonus
Pilot 2: (9-5) = 4% speed bonus × 0.75 = 3% speed bonus
Total: 4% + 3% = 7% combined speed bonus
Average: 7% / 2 = 3.5% per pilot position
```

---

## Specialization

### Pilot-Craft Compatibility

Each pilot class has preferred aircraft types, but can operate any craft:

| Pilot Class | Best Aircraft | OK Aircraft | Avoid |
|------------|---------------|-------------|-------|
| **Standard Pilot** | Transport, Scout | Any | None (jack-of-all-trades) |
| **Fighter Pilot** | Interceptor | Scout, Sentinel | Transport, Bomber |
| **Bomber Pilot** | Bomber, Avenger | Transport, Sentinel | Interceptor |
| **Helicopter Pilot** | VTOL, Transport | Scout, Sentinel | Interceptor, Bomber |

### Craft Requirements

Craft define minimum pilot requirements in their configuration:

```toml
[craft_types.pilots]
required_count = 1              # Number of pilots needed
min_level = 0                   # Minimum rank (0=Rookie)
preferred_classes = ["pilot"]   # Preferred classes
```

**Examples:**

**Lightning Interceptor:**
```
required_count = 1
min_level = 0
preferred_classes = ["fighter_pilot"]
```

**Avenger Bomber:**
```
required_count = 2
min_level = 1  # Requires Veteran rank minimum
preferred_classes = ["bomber_pilot"]
```

---

## Best Practices

### Pilot Management Strategy

1. **Recruit Multiple Pilots** - Always have 2-3 pilots per active craft
2. **Specialize Early** - Train pilots in specific craft types to optimize bonuses
3. **Rank Them Up** - Prioritize getting pilots to Veteran (rank 1) for combat bonus
4. **Keep Rotating** - Rotate pilots through different aircraft to gain general experience
5. **Track Performance** - Monitor XP gain rates to identify top performers

### Optimal Squadron Composition

**Small Squadron (3 Pilots):**
- 1 Fighter Pilot (Interceptor)
- 1 Standard Pilot (Transport/Scout)
- 1 Helicopter Pilot (VTOL)

**Large Squadron (6+ Pilots):**
- 2 Fighter Pilots (dual Interceptors)
- 2 Bomber Pilots (transport + support)
- 2 Standard Pilots (backup)

### Interception Strategy

1. **Scout First** - Use Scout pilot to detect threats
2. **Send Fighter Pilot** - Once detected, dispatch Fighter Pilot
3. **Backup Support** - Have Transport/Bomber pilot ready as support
4. **Rotate Frequently** - Switch pilots between missions to spread XP gain

### Minimizing Pilot Loss

- **Never Send Unprepared** - Always have at least Rookie-ranked pilot (rank 0)
- **Avoid Overextension** - Don't engage superior UFOs without backup
- **Use Numbers** - Two Veteran pilots often beat one Ace pilot
- **Retreat Option** - Pilots can retreat without death (ejection + rescue)

---

## Modding Pilots

### Adding New Pilot Classes

In `mods/core/rules/unit/classes.toml`:

```toml
[[unit_classes]]
id = "transport_pilot"
name = "Transport Pilot"
type = "soldier"
description = "Specialized transport and cargo aircraft pilot"
tier = 2

# Base stats
health = 60
strength = 8
speed = 6
aim = 5
reaction = 6
energy = 15
wisdom = 8
psi = 0

# Default perks
[unit_classes_NEW.perks]
default = [
    "can_move",
    "can_run",
    "can_shoot",
    "can_melee",
    "can_throw",
    "skilled_pilot",
    "cargo_expert"
]
```

### Customizing Pilot Bonuses

Edit `engine/geoscape/logic/craft_pilot_system.lua`:

```lua
CraftPilotSystem.STAT_MAPPING = {
    speed = {
        craft_stat = "speed",
        bonus_per_point = 1.5,  -- Custom multiplier
        max_bonus = 40,         -- Higher cap
    },
    -- ... other stats ...
}
```

### Creating Custom Progression

Override `pilot_progression.lua` methods:

```lua
function PilotProgression.gainXP(pilotId, xpAmount, source)
    -- Custom XP calculation
    local modified = math.floor(xpAmount * 1.5)  -- 50% XP boost
    -- ... continue with standard progression ...
end
```

---

## Integration with Other Systems

### With Interception Combat

Pilots gain XP during `interception_system.lua` mission completion. XP is calculated based on:
- Enemy HP defeated
- Mission success completion
- UFO destruction bonuses

### With Craft System

Pilot bonuses are automatically applied by `craft_pilot_system.lua`:
1. Get active pilots from craft
2. Calculate individual bonuses
3. Stack bonuses with diminishing returns
4. Apply to craft stats

### With Base Management

Pilots are managed in basescape:
- Recruit pilots at base
- Assign pilots to specific craft
- Track pilot status and experience
- Schedule pilot rotation/retirement

---

## Advanced Topics

### Pilot Retirement

After reaching Ace rank (rank 2), pilots can be:
- **Retired** - Removed from active duty (no XP gain)
- **Kept Active** - Continue gaining xp (XP tracking in mission logs)
- **Promoted** - Become squadron leader with leadership bonuses

### Pilot-Craft Bonding

*Feature for future expansion:*
- Pilots can become "bonded" to specific aircraft
- Bonded pilots gain +5% bonus to familiar craft
- Switching aircraft removes bonus (requires 5 missions to rebond)

### Pilot Status Effects

During missions, pilots can gain statuses:
- **EXHAUSTED** - After 3 consecutive missions (-10% accuracy)
- **CELEBRATED** - After successful mission (+15% morale, +5% XP gain)
- **TRAUMATIZED** - After heavy losses (-20% accuracy, -10% dodge)

---

## Summary

The Pilot System provides:
- **Simplified Progression** - 3 ranks focused on interception excellence
- **Specialization** - 4 distinct pilot classes with unique strengths
- **Craft Synergy** - Pilot stats directly enhance aircraft performance
- **Fast Recovery** - Pilots recover 100% between missions
- **Strategic Depth** - Multi-pilot configurations with stacking bonuses

Pilots transform interception combat from a static mini-game into a dynamic strategic layer where player decisions about pilot assignment and advancement directly impact combat effectiveness.

---

**Documentation Version:** 1.0
**Last Updated:** October 23, 2025
**Status:** Complete & Tested
