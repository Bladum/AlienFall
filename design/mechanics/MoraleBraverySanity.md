# Morale, Bravery, and Sanity System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Battlescape.md, Units.md, Basescape.md

## Table of Contents

- [Overview](#overview)
- [Bravery Stat](#bravery-stat)
- [Morale System (In-Battle)](#morale-system-in-battle)
- [Sanity System (Between Battles)](#sanity-system-between-battles)
- [Integration with Combat](#integration-with-combat)
- [Recovery Mechanics](#recovery-mechanics)
- [Strategic Implications](#strategic-implications)

---

## Overview

AlienFall uses a dual psychological system to represent unit mental state:

- **Bravery**: Core stat (6-12 range) that determines base morale capacity
- **Morale**: In-battle psychological buffer that degrades under stress
- **Sanity**: Between-battle psychological stability that degrades from trauma

**Key Principle**: Bravery is the foundation; morale is the active buffer during combat; sanity is the long-term mental health tracker.

---

## Bravery Stat

### Definition

**Bravery** is a core unit statistic representing inherent courage and resistance to fear. It acts as the baseline for morale during combat.

### Range & Values

- **Range**: 6-12 (standard stat range)
- **Average**: 8-9 (typical soldier)
- **Low**: 6-7 (inexperienced or timid units)
- **High**: 10-12 (veterans or brave units)

### How Bravery is Determined

**Base Bravery by Unit Type**:

| Unit Type | Base Bravery | Reasoning |
|-----------|--------------|-----------|
| **Conscript** | 6 | Untrained, afraid |
| **Soldier** | 8 | Standard training |
| **Veteran** | 10 | Combat experience |
| **Elite** | 11 | Specialized training |
| **Hero** | 12 | Legendary courage |
| **Alien (Sectoid)** | 7 | Physically weak, fearful |
| **Alien (Muton)** | 11 | Fearless warriors |
| **Robot/Mechanical** | 12 | No fear (immune to morale) |

### Bravery Modifiers

**Permanent Modifiers**:
- **Trait "Brave"**: +2 bravery
- **Trait "Timid"**: -2 bravery
- **Trait "Fearless"**: +3 bravery (rare)
- **Trait "Coward"**: -3 bravery (negative trait)

**Experience-Based**:
- +1 bravery per 3 ranks gained (maximum +4)
- Veterans naturally become braver through exposure

**Equipment-Based**:
- **Officer Gear**: +1 bravery (command presence)
- **Ceremonial Armor**: +1 bravery (psychological boost)
- **Medal Display**: +1 bravery per 3 medals (visual reminder)

**Temporary Modifiers** (mission-specific):
- **Leader Presence**: +1 bravery if leader within 8 hexes
- **Outnumbered**: -1 bravery if enemies outnumber 2:1
- **Night Mission**: -1 bravery (fear of darkness)

### Bravery Impact

**Direct Effects**:
- **Morale Pool**: Bravery = starting morale in battle
- **Panic Resistance**: Higher bravery = harder to panic
- **Leadership**: Leaders with high bravery boost nearby allies
- **Psionic Defense**: Bravery adds +1 psi defense per 2 points

**Example**:
```
Unit: Veteran Soldier
Base Bravery: 10
Trait "Brave": +2
Equipment "Officer Badge": +1
Total Bravery: 13 (capped at 12)
→ Starts battle with 12 morale
```

---

## Morale System (In-Battle)

### Definition

**Morale** is the active psychological state during combat. It represents unit confidence, willingness to fight, and resistance to panic. Morale degrades under stress and can be restored through rest actions.

### Morale Baseline

**Starting Morale**:
- **At Battle Start**: Morale = Bravery stat
- **Example**: Unit with Bravery 10 starts with 10 morale

**Morale Range**:
- **Minimum**: 0 (panic state)
- **Maximum**: Equal to Bravery stat (cannot exceed)

### Morale Loss Events

Units lose morale when encountering stressful combat situations:

| Event | Morale Loss | Frequency |
|-------|-------------|-----------|
| **Ally killed (within 5 hexes)** | -1 morale | Per death witnessed |
| **Taking damage** | -1 morale | Per hit received |
| **Critical hit received** | -2 morale | Per critical |
| **Flanked by enemies** | -1 morale | Per turn flanked |
| **Outnumbered (3:1)** | -1 morale | Per turn |
| **Alien revealed (first time)** | -1 morale | Per new alien type |
| **Mission night/horror** | -1 morale | Start of mission |
| **Commander killed** | -2 morale | One-time event |
| **Failed attack (critical miss)** | -1 morale | Per miss at <30% chance |

### Morale Thresholds & Effects

| Morale Level | Status | AP Penalty | Accuracy Penalty | Behavioral Effect |
|--------------|--------|------------|-----------------|-------------------|
| **6-12** (high) | **Confident** | 0 | 0% | Normal behavior, full capability |
| **5** | **Steady** | 0 | 0% | Still functional, no penalties |
| **4** | **Nervous** | 0 | -5% | Minor accuracy reduction |
| **3** | **Stressed** | 0 | -10% | Noticeable combat degradation |
| **2** | **Shaken** | -1 AP | -15% | Reduced actions per turn |
| **1** | **Panicking** | -2 AP | -25% | Severely impaired |
| **0** | **PANIC MODE** | All AP lost | -50% | Unit cannot act this turn |

### Panic Mode (Morale = 0)

**When Morale Reaches 0**:
- Unit loses ALL Action Points for current turn
- Cannot perform any actions (movement, shooting, etc.)
- Accuracy penalty: -50% if forced to shoot
- Unit may flee toward map edge (10% chance per turn)
- Unit may drop weapon (5% chance per turn)
- Unit may surrender (if enemies adjacent)

**Panic Duration**:
- Lasts until morale is restored above 0
- Can be restored via Rest action or leader rally

**Morale Lock**:
- Unit at 0 morale cannot naturally recover
- Requires active intervention (Rest action or leader)

### Morale Recovery

**Rest Action**:
- **Cost**: 2 AP
- **Effect**: +1 morale
- **Frequency**: Once per turn
- **Usage**: Unit spends time composing themselves

**Leader Rally**:
- **Cost**: 4 AP (leader action)
- **Effect**: +2 morale to target unit within 5 hexes
- **Frequency**: Once per turn per leader
- **Requirement**: Leader must have "Leadership" trait

**End of Turn**:
- **No automatic recovery** during battle
- Morale only recovers via actions

**End of Mission**:
- **Full Recovery**: All units reset to base Bravery value
- Morale does NOT carry between missions

### Special Morale Mechanics

**Leader Aura**:
- Units within 8 hexes of leader: +1 morale per turn (passive)
- Stacks with Rest action
- Multiple leaders do not stack

**Victory Momentum**:
- Killing enemy: +1 morale to killer
- Mission success: +2 morale to all units (final turn)

**Mechanical Units**:
- Robots/Drones: Immune to morale (always 12 morale)
- Cannot panic, cannot be demoralized
- No morale loss from any source

---

## Sanity System (Between Battles)

### Definition

**Sanity** is a long-term psychological stability stat that degrades from traumatic missions and recovers slowly between deployments. Unlike morale, sanity persists across missions and represents cumulative mental strain.

### Sanity Baseline

**Starting Sanity**:
- **Range**: 6-12 (same as other core stats)
- **Default**: 8-10 for most units
- **Variation**: Depends on unit class and traits

**Sanity by Unit Type**:

| Unit Type | Base Sanity | Notes |
|-----------|-------------|-------|
| **Rookie** | 8 | Average mental fortitude |
| **Veteran** | 10 | Hardened to combat |
| **Psionic** | 6 | Sensitive to horror |
| **Medic** | 12 | Trained for trauma |
| **Scout** | 9 | Moderate exposure |
| **Heavy** | 11 | Thick-skinned |

### Sanity Loss (Post-Mission)

**Sanity drops AFTER mission completion** based on mission difficulty and events:

| Mission Type | Sanity Loss | Condition |
|--------------|-------------|-----------|
| **Standard Mission** | 0 | Routine operations |
| **Moderate Mission** | -1 | High casualties or horror |
| **Hard Mission** | -2 | Extreme trauma |
| **Horror Mission** | -3 | Psychological terror |

**Additional Sanity Loss Factors**:

| Event | Sanity Loss | Applies When |
|-------|-------------|--------------|
| **Night mission** | -1 | Darkness + fear |
| **Ally killed** | -1 per death | Witnessed death |
| **Civilian casualties** | -1 per 5 deaths | Guilt from failure |
| **Alien horror** | -1 | First encounter with new alien type |
| **Mission failure** | -2 | Lost mission, retreat |
| **Base assault survived** | -3 | Home violated |
| **Capture/interrogation witnessed** | -2 | Torture exposure |

**Example Calculation**:
```
Mission: Hard difficulty alien base assault
Base sanity loss: -2 (hard mission)
Night mission: -1
3 allies killed: -3
Total sanity loss: -6 sanity
```

### Sanity Thresholds & Effects (DEPLOYMENT ONLY - NO IN-BATTLE EFFECTS)

| Sanity Level | Status | In-Battle Effects | Deployment |
|--------------|--------|-------------------|-----------|
| **8-12** | **Stable** | None (no penalty) | ✅ Can deploy |
| **5-7** | **Stressed** | None (no penalty) | ✅ Can deploy |
| **2-4** | **Fragile** | None (no penalty) | ✅ Can deploy |
| **1** | **Critical** | None (no penalty) | ✅ Can deploy (risky) |
| **0** | **BROKEN** | Cannot participate | ❌ Cannot deploy |

**KEY DESIGN POINT**: Sanity has NO in-battle effects (no accuracy penalties, no AP penalties). It only determines deployment eligibility. The distinction is clear:
- **Morale** = IN-BATTLE buffer (affects combat performance with accuracy & AP penalties)
- **Sanity** = BETWEEN-BATTLE gate (pure deployment lock at 0)

### Broken State (Sanity = 0)

**When Sanity Reaches 0**:
- Unit CANNOT be deployed on missions
- Unit is "Broken" status
- Requires psychological treatment
- Occupies base slot but cannot fight

**Treatment Options**:
- **Hospital/Psych Ward**: +1 sanity per week (requires facility)
- **Psychological Counseling**: +2-3 sanity per session (100 credits per session)
- **Leave/Vacation**: +1 sanity per 2 weeks off-duty
- **Promotion**: +2 sanity upon rank advancement
- **Mission Success**: +1 sanity upon completing objective (if sanity < 8)

**Treatment Duration**:
- Typical recovery: 1-6 weeks to restore sanity to deployable levels (sanity 1+)
- Full recovery: 6-12 weeks to restore to maximum (sanity 8-12)
- Unit cannot deploy until sanity reaches 1+ (can deploy at 1 with risk)

### Sanity Recovery

**Passive Recovery** (between missions):
- **Base Recovery**: +1 sanity per week in base
- **Temple Facility**: +1 additional sanity per week (requires temple)
- **Total**: +2 sanity per week with temple

**Active Recovery**:
- **Psychological Treatment**: 4 AP medical action, +2 sanity (requires medic)
- **Meditation**: Unit can "rest" for full week, +3 sanity
- **Leave**: Send unit on 2-week vacation, +5 sanity (costs 5,000 credits)

**Mission Success**:
- **Easy victory**: +1 sanity (morale boost)
- **Perfect mission** (no casualties): +2 sanity (confidence boost)

**Recovery Limits**:
- Sanity cannot exceed base stat value
- Recovery is slow by design (weeks, not days)
- Strategic roster rotation required

### Long-Term Sanity Management

**Rotation Strategy**:
- Deploy different units each mission
- Avoid consecutive deployments of same unit
- Keep "reserve squad" for rotation
- Monitor sanity levels before deployment

**Warning Signs**:
- Unit at 4-6 sanity: Consider resting
- Unit at 1-3 sanity: Mandatory rest
- Unit at 0 sanity: Treatment required

**Prevention**:
- Build Temple facility early (doubles recovery)
- Avoid horror missions with low-sanity units
- Success streaks restore sanity
- Large roster enables rotation

---

## Integration with Combat

### Bravery → Morale → Sanity Flow

**During Mission**:
1. Unit enters with **Morale = Bravery**
2. Morale degrades from combat stress
3. Morale affects AP and accuracy
4. Morale can be restored via Rest action
5. Morale resets to Bravery at mission end

**After Mission**:
1. Sanity drops based on mission horror
2. Sanity is ONLY a deployment gate (affects ability to deploy, not performance)
3. Sanity recovers slowly in base (1-2 per week with facilities)
4. At 0 sanity: Unit cannot deploy (binary lock)

**Interaction Example** (Corrected):
```
Bravery 10 → Start mission with 10 morale
Morale drops to 3 during combat → -10% accuracy (from morale)
Mission ends: Morale resets to 10
Sanity drops by 2 (horror mission) → 8 sanity remaining
Next mission: Start with 10 morale, NO accuracy penalty from sanity
  (Sanity affects DEPLOYMENT, not performance)
```

### Morale vs Sanity - Clear Distinction

| System | Scope | Effect | Applies When |
|--------|-------|--------|--------------|
| **Morale** | In-Battle | Affects AP and accuracy penalties | During active combat |
| **Sanity** | Between-Battles | Deployment lock (0 = cannot deploy) | Mission planning phase |

**Design Principle**:
- **Morale** = Tactical in-battle performance buffer (affects how unit fights NOW)
- **Sanity** = Strategic campaign management gate (affects which units can deploy NEXT)
- They are independent systems serving different game functions
- Morale penalties CAN stack with each other (strained -5%, shaken -10%, etc.)
- Sanity does NOT create additional accuracy penalties on top of morale

---

## Recovery Mechanics

### Summary Table

| System | Recovery Method | Recovery Rate | Requirements |
|--------|----------------|---------------|--------------|
| **Morale** | Rest action | +1 per Rest (2 AP) | During combat |
| **Morale** | Leader rally | +2 per Rally (4 AP) | Leader within 5 hexes |
| **Morale** | End of mission | Full reset to Bravery | Automatic |
| **Sanity** | Base recovery | +1 per week | In base, not deployed |
| **Sanity** | Temple facility | +1 per week (bonus) | Requires temple |
| **Sanity** | Medical treatment | +3 immediate | Costs 10,000 credits |
| **Sanity** | Leave/vacation | +5 over 2 weeks | Costs 5,000 credits |

### Strategic Recovery Planning

**Short-Term** (morale):
- Use Rest action mid-combat
- Position leaders near stressed units
- Avoid overextending low-morale units

**Long-Term** (sanity):
- Rotate units between missions
- Build Temple facility for faster recovery
- Send veterans on leave after horror missions
- Maintain 2-3x squad size for rotation

---

## Strategic Implications

### Roster Management

**Optimal Roster Size**:
- Minimum: 2x squad size (12-16 units for 6-man squad)
- Optimal: 3x squad size (18-24 units for 6-man squad)
- Reasoning: Allows rotation while units recover sanity

**Unit Specialization**:
- High Bravery units: Frontline combat roles
- Low Bravery units: Support roles (medic, engineer)
- High Sanity units: Horror mission specialists
- Low Sanity units: Routine missions only

### Mission Selection

**Considerations**:
- Check squad sanity before accepting horror missions
- Decline missions if all units have low sanity
- Accept standard missions to give veterans rest

### Facility Priorities

**Critical Facilities**:
1. **Temple**: +1 sanity recovery per week (game-changer)
2. **Medical Bay**: Faster wounded recovery (enables rotation)
3. **Living Quarters**: More unit capacity (enables rotation)

### Endgame Challenges

**Attrition Spiral**:
- Hard missions → sanity loss → fewer deployable units
- Fewer units → must deploy low-sanity units → worse performance
- Worse performance → more deaths → more trauma → more sanity loss

**Mitigation**:
- Large roster investment early
- Temple facility mandatory mid-game
- Strategic mission selection (avoid consecutive horror missions)

---

## Implementation Notes

**Unit Data Structure**:

Units track the following psychological state:
- **Bravery**: Base stat (6-12 range) - core morale capacity
- **Morale**: Current in-battle value (resets each mission) - current psychological state
- **Sanity**: Long-term psychological stability (persists across missions) - cumulative trauma
- **Traits**: Applied modifiers (e.g., "Brave" grants +2 bravery bonus)
- **Modifiers**: Runtime adjustments including:
  - Bravery bonuses from traits/equipment
  - Morale penalties from current battle effects
  - Sanity penalties from cumulative campaign trauma

**Integration Points**:
- **Battlescape.md**: Morale combat mechanics
- **Units.md**: Bravery stat progression
- **Basescape.md**: Sanity recovery facilities
- **Economy.md**: Medical treatment costs

---

**Last Updated**: 2025-10-28
**Version**: 1.0
**Status**: Complete Design Specification

---
## Integration with Other Systems
Morale/Bravery/Sanity integrates with:
### Battlescape System
- Morale affects AP availability in combat
- Panic state disables unit actions
- Bravery determines resistance to fear
### Units System
- Bravery is base unit stat
- Sanity persists between missions
- Affects unit long-term viability
### Basescape System
- Temple facility improves sanity recovery
- Medical treatment restores sanity
- Rest and rotation prevent breakdowns
### Missions System
- Mission difficulty affects sanity loss
- Night missions impose morale penalties
- Horror scenarios cause sanity damage
**For complete system integration details, see [Integration.md](Integration.md)**

## Examples

### Scenario 1: Combat Morale Break
**Setup**: Unit with bravery 8 enters combat, takes heavy casualties
**Action**: Morale drops below threshold from repeated losses
**Result**: Unit panics, reduced accuracy, potential retreat

### Scenario 2: Sanity Degradation
**Setup**: Unit survives multiple horror missions
**Action**: Accumulates sanity damage over campaigns
**Result**: Unit becomes unreliable, requires medical treatment

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Base Bravery | 6-12 | 1-20 | Core courage stat | +2 on Hard |
| Morale Threshold | 50% of bravery | 25-75% | Panic trigger | -10% on Easy |
| Sanity Range | 0-12 | 0-20 | Mental health scale | +2 max on Hard |
| Recovery Rate | +1/week | 0.5-2 | Healing pace | +0.5 on Easy |

## Difficulty Scaling

### Easy Mode
- Higher base bravery values
- More forgiving morale thresholds
- Faster sanity recovery
- Reduced psychological penalties

### Normal Mode
- Standard bravery/morale mechanics
- Balanced sanity degradation
- Normal recovery rates

### Hard Mode
- Lower base bravery values
- Stricter morale requirements
- Increased sanity damage
- Slower recovery rates

### Impossible Mode
- Minimum bravery stats
- Harsh morale penalties
- Severe sanity degradation
- Minimal recovery

## Testing Scenarios

- [ ] **Morale Combat Test**: Unit under fire loses morale
  - **Setup**: Unit in combat with bravery 8
  - **Action**: Take 3 casualties in one turn
  - **Expected**: Morale drops below 4, panic occurs
  - **Verify**: Unit shows panic status and reduced accuracy

- [ ] **Sanity Recovery Test**: Unit treated in hospital
  - **Setup**: Unit with sanity 3
  - **Action**: Assign to hospital for 2 weeks
  - **Expected**: Sanity increases to 5
  - **Verify**: Sanity display updates correctly

## Related Features

- **[Battlescape System]**: Combat morale mechanics (Battlescape.md)
- **[Units System]**: Core unit stats and progression (Units.md)
- **[Basescape System]**: Recovery facilities and treatment (Basescape.md)
- **[Missions System]**: Psychological mission effects (Missions.md)

## Implementation Notes

- Bravery as core stat with morale as derived buffer
- Sanity tracking separate from health systems
- Recovery mechanics tied to base facilities
- Integration with combat resolution systems

## Review Checklist

- [ ] Bravery stat mechanics defined
- [ ] Morale system in-battle documented
- [ ] Sanity system between-battles specified
- [ ] Integration with combat complete
- [ ] Recovery mechanics balanced
- [ ] Strategic implications clear
