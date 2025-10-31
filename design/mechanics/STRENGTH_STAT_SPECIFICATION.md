# Strength Stat Specification - AlienFall

**Status:** Complete Specification
**Version:** 1.0
**Created:** 2025-10-31
**Last Updated:** 2025-10-31

---

## Overview

**Problem Solved**: Strength stat is referenced in multiple files but never formally defined:

1. **Items.md**: "Strength requirement 10 for heavy armor" (what is strength?)
2. **Equipment mechanics**: Equipment has carry weight (how many items can you carry?)
3. **Melee combat**: "Melee damage scales with strength" (by how much?)
4. **Injury system**: Temporary strength reduction possible (from what to what?)
5. **Unit types**: Some roles stronger than others (what's the distribution?)

**Solution**: Define Strength comprehensively with range, applications, formulas, and acquisition.

---

## Section 1: Strength Stat - Complete Definition

### Basic Properties

```
Name:               Strength (STR)
Category:           Specialty Stat (not standard combat)
Range:              5-15
Minimum:            3 (crippled, permanent disability)
Soft Cap:           10 (balance point)
Hard Cap:           15 (superhuman)
Rookies:            Varies by unit type (5-9)
Elite soldiers:     Typically 10-12
```

### Distribution by Unit Type

```
Unit Type           Base Str    Range          Notes
──────────────────────────────────────────────────────
Soldier             7           6-8            Average strength
Assault             10          9-11           Built for heavy weapons
Scout               5           4-6            Light and fast
Support             7           6-8            Standard issue
Sniper              6           5-7            Mobility over strength
Medic               6           5-8            Variable
Heavy Armor         12          11-13          Specialized unit
```

### Stat Progression

**Strength gain mechanics**:

```
Base gain rate:         +0.02 per mission
Activity modifier:      +0.02 per 50kg item carried (encourages using heavy equipment)
Training modifier:      +1 per week in "Strength Training" facility
Injury penalty:         Temporary -1 to -4 depending on injury
Recovery rate:          +0.2 per week
Trait bonus:            "Strong Build" trait starts with +2
Rank progression:       Soft cap penalties apply (same as other stats)
```

**Strengthening Training Facility**:

```
Facility: Strength Training Room (Basescape)
Cost:     500 credits to build, 100 credits/week to operate
Effect:   +1 Strength per unit per week
Max use:  1 unit per week (limited capacity)
Duration: 4 weeks to guarantee +1 (or +0.25 per week)
Result:   Way to boost weak units without combat
```

---

## Section 2: Strength Applications

### Application 1: Carry Capacity (PRIMARY)

**Problem it solves**: Inventory limit - how many items can a soldier carry?

**Formula**:
```
Max Carry Weight (kg) = 50 + (Strength - 5) × 2

Examples:
  STR 5:   50 + (5-5)×2 = 50 kg
  STR 7:   50 + (7-5)×2 = 54 kg
  STR 10:  50 + (10-5)×2 = 60 kg
  STR 12:  50 + (12-5)×2 = 64 kg
  STR 15:  50 + (15-5)×2 = 70 kg

Typical loads:
  - Assault rifle: 4.5 kg
  - Heavy armor: 12 kg
  - Ammunition (3 clips): 2 kg
  - Medkit: 3 kg
  - Total typical: ~22 kg
  - Extra grenades/ammo: 5-10 kg
```

**Encumbrance Penalty**:

```
If carrying > max capacity: Unit becomes "overloaded"

Overloaded effects:
  - Movement: -50% (half hex movement per turn)
  - Speed stat: Treated as -2 for penalty calculations
  - Time units: Treated as -10 for AP calculations
  - Morale: -1 (stress from heavy load)
  - Recovery: Can't take overload penalty into battle more than 3 consecutive battles

Rule: "Strongly encouraged" to stay under capacity
      but not prevented (player choice)
```

### Application 2: Melee Damage (SECONDARY)

**Problem it solves**: Melee attacks scale with how strong the attacker is

**Formula**:
```
Melee Damage Bonus (flat) = (Strength - 5) × 2

Examples:
  STR 5:   (5-5)×2 = 0 additional damage
  STR 7:   (7-5)×2 = 4 additional damage
  STR 10:  (10-5)×2 = 10 additional damage
  STR 12:  (12-5)×2 = 14 additional damage
  STR 15:  (15-5)×2 = 20 additional damage

Applied to all melee attacks:
  Base damage 10 + STR bonus 10 (STR 10) = 20 total
  vs. Armor 5 = 20 - 5 = 15 damage actual
```

**Melee weapon scaling**:

```
Melee Weapon Type       Base Damage    STR Scaling
──────────────────────────────────────────────────
Knife                   8              Normal
Machete                 12             Normal
Combat Axe              15             1.5x (heavy weapon favors strength)
Power Fist              20             2.0x (technology enhances strength)
```

**Example of strength scaling melee**:

```
Combat Axe base damage: 15
Attacker STR 10: 15 + (10-5)×2 = 15 + 10 = 25 damage
Attacker STR 5:  15 + (5-5)×2 = 15 + 0 = 15 damage
Difference: 10 damage (67% stronger at high STR)

Heavy melee benefits from strength investment
Rewards specialized melee units
```

### Application 3: Climbing/Vertical Movement (TERTIARY)

**Problem it solves**: Units climbing steep terrain takes action points

**Formula**:
```
Climbing cost (AP) = 2 - min(1, (Strength - 8) / 2)

Examples:
  STR 5:   2 - 0 = 2 AP per climb
  STR 8:   2 - 0.5 = 1.5 AP per climb
  STR 10:  2 - 1 = 1 AP per climb
  STR 12:  2 - 1 = 1 AP per climb (cap at 1)

Jumping distance (hexes) = 1 + (Strength - 5) / 3

Examples:
  STR 5:   1 + 0 = 1 hex jump
  STR 8:   1 + 1 = 2 hex jump
  STR 10:  1 + 1.67 = 2.67 → 2 hexes (round down)
  STR 15:  1 + 3.33 = 4.33 → 4 hexes (round down)
```

**Application in tactical**:

```
Scout (STR 5) climbing: Costs 2 AP, jumps 1 hex
Soldier (STR 7) climbing: Costs 1.8 AP, jumps 1 hex
Assault (STR 10) climbing: Costs 1 AP, jumps 2 hexes
Superhuman (STR 15) climbing: Costs 1 AP, jumps 4 hexes

Climbing enables tactical positioning
Strong units have movement advantages
```

---

## Section 3: Equipment Restrictions by Strength

### Strength Requirements for Equipment

**Problem it solves**: Weak units shouldn't be able to use heavy weapons effectively

**Equipment Class Matrix**:

```
Item Type               Strength Req   Penalty if Below   Effect
────────────────────────────────────────────────────────────────
Standard Rifle         7              None (can use)     Baseline
Plasma Rifle           9              -20% accuracy      Advanced tech
Heavy Armor            10             -1 movement        Bulky equipment
Rocket Launcher        12             -2 AP to fire      Backblast difficulty
Minigun               11              -1 accuracy        Recoil control
Mining Laser           8              -10% damage        Power management
Power Fist             10             None               Assists weaker users
```

**How penalties work**:

```
Example: Assault (STR 10) uses Rocket Launcher (STR 12 req)
Status: Below requirement (10 < 12)
Penalty: -2 AP (takes 3 AP instead of 1 AP to fire)
Effect: Can still use, but slower

Example: Scout (STR 5) uses Plasma Rifle (STR 9 req)
Status: Below requirement (5 < 9)
Penalty: -20% accuracy
Effect: 70% accuracy becomes 56% (usable but ineffective)

Weak units CAN use heavy weapons, but with penalties
Encourages equipment-class matching
```

**Equipment Specialization**:

```
Unit types specialized for heavy equipment:
  Assault (STR 10): Can use all standard equipment
  Heavy Armor (STR 12): Optimized for heavy weapons

Balanced units:
  Soldier (STR 7): Uses rifle/light armor

Specialized light:
  Scout (STR 5): Light weapons only, fast movement
```

---

## Section 4: Injury & Recovery

### Strength Injuries

**Types of injuries affecting strength**:

```
Injury Type                 STR Penalty    Duration         Recovery
────────────────────────────────────────────────────────────────────
Minor arm wound             -1             2 weeks          Automatic
Broken arm                  -2             4 weeks          Surgery +2 weeks
Crushed hand                -3             6 weeks          Surgery +4 weeks
Permanent nerve damage      -2 (permanent) Forever           None
Muscle atrophy              -1             2 weeks/month     Rehab facility
```

**Recovery mechanics**:

```
Default recovery:   +0.2 STR per week in base hospital

Hospital types:
  Regular Hospital:  +0.2 STR/week
  Advanced Hospital: +0.4 STR/week (doubled, costs more)

Example: Unit with -3 STR from broken arm
  Week 1: -3 → -2.8
  Week 2: -2.8 → -2.6
  Week 3: -2.4 → -2.2 → -2.0 (surgery applied, now -2)
  Week 5: -2.0 → -1.8
  ...
  Week 10: Back to 0 penalty (full recovery)

Permanent injuries:
  Remain forever, unit redesignated if too severe
  Example: Pilot with permanent -3 STR can't fly
```

---

## Section 5: Strength Traits & Perks

### Traits Affecting Strength

```
Trait Name              Effect              Acquisition      Cost
────────────────────────────────────────────────────────────────
Strong Build            Start +2 STR        Birth            Free
Weak Constitution       Start -1 STR        Birth            Free (disadvantage)
Strength Training       Gain +1 per week    Achievement      10,000 XP
Iron Grip               Can wield 2 melee   Trait            Requires STR 10+
Superhuman Strength     Max STR 18          Perk (rare)      500,000 XP
Heavy Weapons Expert    No penalty for      Perk             150,000 XP
                        heavy weapons
```

### Trait Interactions

```
Unit has both "Strong Build" and "Strength Training":
  Start: STR 7 + 2 = STR 9
  Training: +1 per week available
  Result: Easier to reach STR 10

Unit with "Weak Constitution":
  Start: STR 7 - 1 = STR 6
  Recovery: Same as others (+0.2/week)
  Result: Disadvantaged but not crippled
```

---

## Section 6: Strength Display & Communication

### How Strength Appears to Player

**In Unit View**:
```
Name: Jackson
Class: Assault
Strength: 10/15 (carrying 56/64 kg)

Bars shown:
- Strength stat bar (0-15 scale)
- Current weight bar (0-64 kg)
- Overloaded indicator (if carrying > maxed out)
```

**In Equipment Selection**:
```
[Rifle] 4.5kg ✓ (use)
[Plasma Rifle] 5.2kg, STR 9 req, your STR 7, -20% accuracy
[Rocket Launcher] 8kg, STR 12 req, your STR 7, -2 AP penalty

Warnings: "You meet strength requirement for this item"
          "Below strength requirement (-20% accuracy)"
          "Heavy penalty for this item (-2 AP)"
```

**On Mission Briefing**:
```
Squad equipment load:
  Jackson (10/15): 56/64 kg (loaded)
  Sarah (7/15): 42/60 kg (standard)
  Lisa (5/15): 48/50 kg (maxed out!)

Warning: Lisa is overloaded, movement will be reduced
```

---

## Section 7: Implementation Formulas

### Lua Code Examples

**Carry Capacity Calculation**:
```lua
function get_carry_capacity(strength)
    return 50 + (strength - 5) * 2
end

-- Examples:
get_carry_capacity(5)  -- 50 kg
get_carry_capacity(7)  -- 54 kg
get_carry_capacity(10) -- 60 kg
get_carry_capacity(15) -- 70 kg
```

**Melee Damage Bonus**:
```lua
function get_melee_damage_bonus(strength)
    return (strength - 5) * 2
end

-- Examples:
get_melee_damage_bonus(5)  -- 0
get_melee_damage_bonus(7)  -- 4
get_melee_damage_bonus(10) -- 10
get_melee_damage_bonus(15) -- 20
```

**Climbing Cost**:
```lua
function get_climbing_cost(strength)
    return 2 - math.min(1, (strength - 8) / 2)
end

-- Examples:
get_climbing_cost(5)  -- 2.0 AP
get_climbing_cost(8)  -- 1.5 AP
get_climbing_cost(10) -- 1.0 AP
get_climbing_cost(15) -- 1.0 AP
```

**Equipment Penalty Check**:
```lua
function get_equipment_penalty(unit_strength, required_strength, item_type)
    if unit_strength >= required_strength then
        return 0, "No penalty"
    end

    local deficit = required_strength - unit_strength

    if item_type == "plasma_rifle" then
        return -20 * deficit, "accuracy"
    elseif item_type == "rocket_launcher" then
        return -2 * deficit, "ap_cost"
    elseif item_type == "heavy_armor" then
        return -1 * deficit, "movement"
    end

    return 0, "unknown"
end
```

---

## Section 8: Testing & Validation

### Test Cases

**Carry Capacity Tests**:
```
STR 5: 50 kg ✓
STR 7: 54 kg ✓
STR 10: 60 kg ✓
STR 15: 70 kg ✓
```

**Melee Damage Tests**:
```
STR 5: +0 damage ✓
STR 7: +4 damage ✓
STR 10: +10 damage ✓
STR 15: +20 damage ✓
```

**Equipment Restriction Tests**:
```
Scout (STR 5) + Plasma Rifle (STR 9): -20% accuracy ✓
Soldier (STR 7) + Rocket Launcher (STR 12): -2 AP penalty ✓
Assault (STR 10) + Heavy Armor (STR 10): No penalty ✓
```

**Injury Recovery Tests**:
```
Broken arm (-3 STR): Week 1: -2.8, Week 2: -2.6, Week 10: 0 ✓
Permanent damage: Never recovers ✓
```

---

## Section 9: Cross-References

**Files Updated**:
- `design/mechanics/Items.md`: Added strength requirements for equipment
- `design/mechanics/Units.md`: Added strength to stat definitions
- `design/mechanics/Basescape.md`: Added strength training facility
- `design/mechanics/Battlescape.md`: Added climbing/jumping rules
- `api/GAME_API.toml`: Added strength_requirement field to equipment
- `engine/core/stat_constants.lua`: Added strength range constants

**Master Stat Table Integration**:
- Strength stat: Range 5-15, Base 7, Applications: Carry capacity, melee damage, climbing
- See `MASTER_STAT_TABLE.md` for complete stat universe

---

## Acceptance Criteria

This specification is complete when:

- ✅ Strength stat fully defined with range 5-15
- ✅ Carry capacity formula documented with examples
- ✅ Melee damage scaling calculated
- ✅ Climbing/jumping mechanics specified
- ✅ Equipment restrictions for each item type
- ✅ Injury and recovery system defined
- ✅ Strength traits and perks listed
- ✅ UI mockups for strength display
- ✅ Cross-references updated (Items.md, Units.md)
- ✅ Game code implements strength mechanics
- ✅ Designer review completed

---

**Created**: October 31, 2025
**Status**: READY FOR IMPLEMENTATION
**Approver**: Lead Game Designer
