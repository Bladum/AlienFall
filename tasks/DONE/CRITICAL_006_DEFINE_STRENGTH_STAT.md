# 🎯 CRITICAL_006: Define Strength Stat

**Severity**: 🔴 CRITICAL
**Blocker For**: Equipment system, inventory management, character progression
**Estimated Effort**: 4 hours
**Dependencies**: C4 (Master Stat Table), C5 (Stat Ranges)

---

## OVERVIEW

**Problem**: Strength stat is referenced in multiple files but never formally defined:

1. **Items.md**: "Strength requirement 10 for heavy armor" (what is strength?)
2. **Equipment mechanics**: Equipment has carry weight (how many items can you carry?)
3. **Melee combat**: "Melee damage scales with strength" (by how much?)
4. **Injury system**: Temporary strength reduction possible (from what to what?)
5. **Unit types**: Some roles stronger than others (what's the distribution?)

**Current State**:
- Strength mentioned in 4+ files with different contexts
- No clear range (0-100? 6-12? 5-15?)
- No formula for carry capacity
- No acquisition mechanism (only fixed by unit type)
- Equipment restrictions vague ("heavy armor requires strong user")

**Impact**:
- Inventory system can't be implemented (max carry undefined)
- Equipment balance impossible (weight undefined)
- Melee combat balance uncertain (strength bonus undefined)
- Character creation broken (strength stat missing)

**Solution**: Define Strength comprehensively with range, applications, formulas, and acquisition.

---

## DESIGN SPECIFICATION

### Section 1: Strength Stat - Complete Definition

#### Basic Properties

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

#### Distribution by Unit Type

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

#### Stat Progression

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

**Example progression**:

```
Mission 1-5:     STR stays 7 (rookie baseline)
            → Carry 60kg equipment for 2 missions
            → Gain +0.04 (from heavy carry)
            → STR becomes 7.04

Mission 10:      STR = 7.1 after 10 missions
Mission 20:      STR = 7.3 after 20 missions
Mission 50:      STR = 7.8 after 50 missions
Rank 5+:         Soft cap penalty kicks in: 75% gains
Mission 100:     STR = 8.5 at veteran level
Mission 200:     STR = 9.0 (approaching soft cap at 10)
                 → Gains slow to 50%
Mission 300:     STR = 9.8 (rarely exceed hard cap)
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

### Section 2: Strength Applications

#### Application 1: Carry Capacity (PRIMARY)

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

#### Application 2: Melee Damage (SECONDARY)

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

#### Application 3: Climbing/Vertical Movement (TERTIARY)

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

### Section 3: Equipment Restrictions by Strength

#### Strength Requirements for Equipment

**Problem it solves**: Weak units shouldn't be able to use heavy weapons effectively

**Equipment Class Matrix**:

```
Item Type               Strength Req   Penalty if Below   Effect
─────────────────────────────────────────────────────────────────
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

### Section 4: Injury & Recovery

#### Strength Injuries

**Types of injuries affecting strength**:

```
Injury Type                 STR Penalty    Duration         Recovery
──────────────────────────────────────────────────────────────────────
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

### Section 5: Strength Traits & Perks

#### Traits Affecting Strength

```
Trait Name              Effect              Acquisition      Cost
──────────────────────────────────────────────────────────────────
Strong Build            Start +2 STR        Birth            Free
Weak Constitution       Start -1 STR        Birth            Free (disadvantage)
Strength Training       Gain +1 per week    Achievement      10,000 XP
Iron Grip               Can wield 2 melee   Trait            Requires STR 10+
Superhuman Strength     Max STR 18          Perk (rare)      500,000 XP
Heavy Weapons Expert    No penalty for      Perk             150,000 XP
                        heavy weapons
```

#### Trait Interactions

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

### Section 6: Strength Display & Communication

#### How Strength Appears to Player

**In Unit View**:
```
Name: Jackson
Class: Assault
Strength: 10/15 (carrying 56/64 kg)

Bars shown:
- Strength stat bar (0-15 scale)
- Current weight bar (0-64 kg)
- Overloaded indicator (if carrying > max)
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

## ACCEPTANCE CRITERIA

This task is complete when:

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

## IMPLEMENTATION PLAN

### Step 1: Create Authoritative Document (1h)
1. Create `design/mechanics/STRENGTH_STAT_SPECIFICATION.md`
2. Include all sections from above
3. Add visual graphs of carry capacity vs strength
4. Add equipment matrix table

### Step 2: Update Existing Mechanics (0.5h)
1. Update Items.md: Reference strength requirements
2. Update Units.md: Add strength to stat definitions
3. Update Basescape.md: Add strength training facility
4. Update Battlescape.md: Add climbing/jumping rules

### Step 3: Implement in Code (1h)
1. Create `engine/utils/strength_calculations.lua`
2. Implement `get_carry_capacity(strength)` function
3. Implement `get_melee_damage_bonus(strength)` function
4. Implement `get_climbing_cost(strength)` function
5. Create inventory weight tracking system

### Step 4: Update UI (1h)
1. Add strength stat display to unit view
2. Add weight indicator to inventory
3. Add strength requirement warnings in equipment selection
4. Add overload indicator in squad view
5. Add strength training facility to basescape

### Step 5: Testing & Validation (0.5h)
1. Create unit tests for strength formulas
2. Test carry capacity calculation
3. Test equipment restrictions
4. Test injury recovery
5. Get balance designer approval

---

## TESTING STRATEGY

### Test Scenarios

**Scenario 1: Carry Capacity Formula**
```
Rookie (STR 7): 50 + (7-5)×2 = 54 kg ✓
Elite (STR 10): 50 + (10-5)×2 = 60 kg ✓
Superhuman (STR 15): 50 + (15-5)×2 = 70 kg ✓
```

**Scenario 2: Equipment Restrictions**
```
Scout (STR 5) picks up Plasma Rifle (STR 9 req):
- Equipment screen shows: "STR 9 required (-20% accuracy)"
- Player can equip anyway
- In battle: -20% accuracy penalty applied
```

**Scenario 3: Melee Damage Scaling**
```
Combat Axe base 15 dmg:
  STR 5: 15 + 0 = 15 dmg
  STR 10: 15 + 10 = 25 dmg
  STR 15: 15 + 20 = 35 dmg
Verify: +10 damage per 5 points of strength
```

**Scenario 4: Overload Penalty**
```
Scout carries 56kg (max 50kg):
  - Overloaded indicator shows
  - Movement: 6 hexes → 3 hexes (50% penalty)
  - Speed stat treated as -2
```

**Scenario 5: Injury & Recovery**
```
Unit takes broken arm (-2 STR):
  STR 10 → 8 temporary
  After 1 week in hospital: 8 + 0.2 = 8.2
  After 4 weeks: 10 (recovered)
```

---

## DOCUMENTATION TO UPDATE

| File | Section | Change |
|------|---------|--------|
| design/mechanics/Units.md | Section 1 | Add Strength stat definition |
| design/mechanics/Items.md | Equipment bonuses | Reference strength requirements |
| design/mechanics/Basescape.md | Facilities | Add Strength Training facility |
| design/mechanics/Battlescape.md | Movement | Add climbing/jumping rules |
| api/GAME_API.toml | [equipment.items] | Add strength_requirement field |
| engine/core/stat_constants.lua | Constants | Add strength range constants |

---

## COMPLETION CHECKLIST

- [ ] Create authoritative specification document
- [ ] Update all cross-references
- [ ] Implement strength calculation functions
- [ ] Implement inventory weight system
- [ ] Update UI for strength display
- [ ] Test carry capacity mechanics
- [ ] Test equipment restriction system
- [ ] Test injury recovery system
- [ ] Test melee damage scaling
- [ ] Get balance designer approval
- [ ] Communicate to team

---

## NOTES

**Depends On**: C4 (Master Stat Table), C5 (Stat Ranges)
**Coordinates With**: Equipment system, inventory system, melee combat
**Impact**: Character creation, equipment balance, inventory management
**Priority**: High - blocks equipment and inventory implementation

---

**Created**: October 31, 2025
**Status**: READY FOR IMPLEMENTATION
**Approver**: Lead Game Designer
