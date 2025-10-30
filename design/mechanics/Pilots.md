# Pilot System

> **Status**: Technical Specification  
> **Last Updated**: 2025-10-28  
> **Related Systems**: Units.md, Crafts.md, Interception.md  
> **⚠️ UNIFIED SPECIFICATION**: See **Units.md §Unified Pilot Specification** for canonical pilot mechanics  
> **Purpose**: This file provides detailed pilot specialization and historical context. For core mechanics, refer to Units.md.

## Table of Contents

- [Overview](#overview)
- [Pilot Role Assignment](#pilot-role-assignment)
- [Piloting Stat](#piloting-stat)
- [Pilot Bonuses](#pilot-bonuses)
- [Experience System](#experience-system)
- [Crew vs Pilot](#crew-vs-pilot)
- [Summary](#summary)

---

## Overview

**Simple Concept**: Units are soldiers. Any unit can be assigned to pilot a craft. When piloting, they provide bonuses based on their **Piloting** stat.

**Key Principles**:
- Units are NOT specialized pilots - they're soldiers who CAN pilot
- Units gain same XP from interception missions as from ground missions (one XP pool)
- Only the PILOT unit provides craft bonuses (crew are just passengers)
- Piloting is a stat (like Strength or Dexterity) that improves with XP/class/traits/equipment
- Units can switch between pilot role and soldier role freely

---

## Pilot Role Assignment

### Assignment States

**Assigned as Pilot**:
- Unit occupies the pilot slot on a craft
- Provides bonuses to craft based on Piloting stat
- Cannot deploy to battlescape while craft is in use
- Gains XP from interception missions
- At risk if craft crashes

**Assigned as Crew/Passenger**:
- Unit occupies a passenger slot
- Provides NO bonuses to craft (just cargo)
- Cannot deploy to battlescape while craft is in use
- Gains XP from interception missions
- At risk if craft crashes

**Unassigned (Available for Ground Combat)**:
- Unit available for battlescape deployment
- Gains XP from ground combat missions
- No craft bonuses provided

### Reassignment

- Takes 1 turn (craft must be at base)
- No XP penalty
- Cannot reassign during active mission
- Simple: Just unassign from craft, unit becomes available

---

## Piloting Stat

### Core Stat

**Piloting** is a unit stat (0-100 range):
- Base: 20-40 (random at recruitment)
- Improved by: XP gain, class progression, traits, equipment
- Affects: Craft accuracy, dodge, and special abilities

**Not a Separate Class**: There is no "Pilot Class" - just units with varying Piloting stats.

### Improvement Sources

**1. XP Progression**:
- Every 100 XP gained: +1 Piloting
- XP from ANY source (ground combat OR interception)
- No separate pilot XP track

**2. Class Bonuses**:
- Some unit classes naturally better at piloting:
  - Scout: +10 Piloting
  - Sniper: +5 Piloting
  - Heavy: -5 Piloting (too bulky)
  - Assault: +0 Piloting (neutral)

**3. Traits**:
- "Natural Pilot": +15 Piloting
- "Ace": +20 Piloting (requires 500+ XP)
- "Clumsy": -10 Piloting
- "Enhanced Reflexes": +10 Piloting

**4. Equipment**:
- Flight Helmet: +5 Piloting
- Neural Link: +10 Piloting (advanced tech)
- Stimulants: +5 Piloting (temporary, one mission)

### Example Calculation

```
Name: Sarah "Viper" Chen
Class: Scout (Rank 3)
Total XP: 450
Traits: Natural Pilot
Equipment: Flight Helmet

Piloting Stat:
- Base: 35 (rolled at recruitment)
- XP bonus: +4 (450 XP / 100 = 4)
- Scout class: +10
- Natural Pilot trait: +15
- Flight Helmet: +5
--------------------------------
Total Piloting: 69
```

---

## Pilot Bonuses

### Bonus Formula

**Only the PILOT provides bonuses**. Crew/passengers = nothing.

**Craft Dodge**:
```
Craft Dodge = Base Craft Dodge + (Pilot Piloting / 5)
Example: Pilot with 60 Piloting = +12% dodge
```

**Craft Accuracy**:
```
Craft Accuracy = Base Craft Accuracy + (Pilot Piloting / 5)
Example: Pilot with 60 Piloting = +12% accuracy
```

**Special Abilities** (unlock at thresholds):
- Piloting 50+: **Evasive Maneuvers** - Dodge +20% for 1 turn (5 turn cooldown)
- Piloting 70+: **Precision Strike** - Accuracy +30% for 1 shot (once per battle)
- Piloting 90+: **Ace Maneuver** - Perfect dodge for 1 turn (once per battle)

### No Crew Bonuses

**Why crew provide nothing**:
- Simplicity: Only pilot matters
- Balance: Prevents craft from being too strong
- Clarity: Easy to understand (1 pilot = all bonuses, everyone else = cargo)

**Crew are just**:
- Passengers being transported
- They gain XP if craft survives
- They can deploy to ground combat after landing
- They do NOT affect craft performance in any way

---

## Experience System

### Unified XP Pool

**Single XP System**: Units gain XP from ALL sources added to one pool:
- Interception mission victory: +50 XP
- Ground combat mission victory: +50 XP
- Enemy killed (air or ground): +10 XP per kill
- Mission completion bonus: Varies by difficulty

**No Separate Tracks**: 
- No "Pilot XP" vs "Ground XP" distinction
- All XP contributes to unit rank and Piloting stat
- Whether XP came from air or ground doesn't matter

### Progression Example

```
Unit Progression:
XP:      0 → 100 → 300 → 600 → 1000 → 1500 → 2100
Rank:    0    1     2     3      4       5       6
Piloting Bonus: +0 +1 +3 +6 +10 +15 +21

Example:
- Unit gains 200 XP from ground combat (Rank 1, Piloting +2)
- Unit gains 250 XP from interceptions (Rank 2, Piloting +4)
- Total: 450 XP = Rank 2 + Piloting bonus +4
```

**Why Unified?**:
- Simpler to implement and balance
- Players don't need to track two XP pools
- Units naturally become better pilots through all combat experience
- Veteran soldiers make better pilots (makes thematic sense)

---

## Crew vs Pilot

### Role Comparison

| Role | Craft Bonuses? | Can Fight in Battlescape? | Gains XP? |
|------|----------------|---------------------------|-----------|
| **Pilot** | ✅ Yes | ✅ Yes (after landing) | ✅ Yes |
| **Crew/Passenger** | ❌ No | ✅ Yes (after landing) | ✅ Yes |

**Key Insight**: The only difference is whether the unit is in the pilot slot (bonuses) or passenger slot (no bonuses).

### Craft Requirements

**Universal Rule**: Every craft needs exactly 1 pilot.

| Craft Type | Pilot Needed | Passenger Capacity |
|------------|--------------|-------------------|
| Scout | 1 | 0 |
| Interceptor | 1 | 0 |
| Transport | 1 | 8 |
| Heavy Transport | 1 | 16 |
| Submarine | 1 | 6 |

**No Minimum Piloting Stat**: 
- Any unit can pilot any craft
- Low Piloting = poor performance
- High Piloting = excellent performance
- That's it - simple

### Strategic Decisions

**Question**: "Should I use my high-Piloting unit as pilot or send them to ground combat?"

**Factors**:
- High Piloting unit in craft = safer interceptions, more successful
- High Piloting unit on ground = better soldier (veteran with high XP)
- Resource tension: Can only use unit in one place at a time
- Risk: If craft crashes, pilot might die (lose valuable veteran)

**Example Scenario**:
```
You have:
- Veteran soldier (Piloting 75, great in both roles)
- UFO approaching (need to intercept)
- Tough ground mission available

Choices:
1. Assign veteran to craft = 87% interception success, weak ground team
2. Send veteran to ground = 60% interception success, strong ground team
3. Use rookie pilot (Piloting 35) = 40% interception success, strong ground team + veteran safe

Player must decide!
```

---

## Summary

### The Complete Pilot System in 5 Points

1. **Any unit can pilot** - No special pilot class needed
2. **Piloting is a stat** - Improves with XP, class, traits, equipment
3. **Only pilot provides bonuses** - Crew/passengers = cargo (no bonuses)
4. **One XP pool** - All XP (ground or air) contributes equally
5. **Simple assignment** - Assign to pilot slot = bonuses, unassign = available for ground combat

### Design Philosophy

**Why Simple?**:
- Easy to understand: "This unit pilots, this unit doesn't"
- Easy to balance: Only one stat to tune (Piloting)
- Easy to implement: No dual XP tracking, no complex crew bonuses
- Strategic depth: Choose which units pilot vs fight on ground

**Rejected Complexity**:
- ❌ Separate pilot XP track
- ❌ Pilot-specific classes (Fighter Pilot, Bomber Pilot, etc.)
- ❌ Crew bonuses (co-pilot, gunner, navigator)
- ❌ Minimum Piloting requirements per craft
- ❌ Pilot-only equipment restrictions

**Result**: Clean, simple system that's easy to learn and provides meaningful strategic choices.

---

**End of Specification**

*Pilots are just units with a Piloting stat. That's the whole system.*

---
## Integration with Other Systems
> **Note**: For complete pilot mechanics, see [Units.md �Unified Pilot Specification](Units.md#unified-pilot-specification)
Pilot system integrates with:
### Units System
- All units have piloting stat
- Pilot class specializes in craft operation
- Dual XP tracks (ground combat + flight)
### Crafts System
- Pilot skills modify craft performance
- Minimum piloting requirements per craft type
- Ace pilots provide combat bonuses
### Interception System
- Pilot experience gained through air combat
- Piloting skill affects interception success
- Squadron commanders control multiple craft
### Geoscape System
- Pilots required for craft deployment
- Craft grounded without qualified pilots
- Pilot assignment affects mission availability
**For complete system integration details, see [Integration.md](Integration.md)**
