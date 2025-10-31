# 🎯 CRITICAL_004: Create Master Stat Table

**Severity**: 🔴 CRITICAL
**Blocker For**: All stat-dependent systems (equipment, progression, combat balance)
**Estimated Effort**: 5 hours
**Dependencies**: C1 (Pilot stat scale decision) must be resolved first

---

## OVERVIEW

**Problem**: Unit stat definitions are scattered across multiple files with inconsistent ranges and applications:
- Pilots.md: Claims 0-100 range (contradicted by Units.md)
- Units.md: Claims 6-12 range
- DamageTypes.md: References stats without defining ranges
- Items.md: References "Strength" stat (undefined)
- No centralized reference showing all stats, their ranges, and applications

**Impact**:
- Developers guess at stat ranges while implementing systems
- Trait bonuses calculated inconsistently (+10 to what scale?)
- Equipment balance impossible to tune without knowing stat distributions
- Different systems apply same stat different ways

**Solution**: Create authoritative Master Stat Table that:
1. Defines all unit stats (10-12 total)
2. Specifies range for each (minimum, maximum, typical distribution)
3. Shows where each stat applies
4. Standardizes how bonuses are calculated
5. Becomes the single source of truth

---

## DESIGN SPECIFICATION

### Section 1: Stat Universe (All 10 Core Stats)

#### Combat Stats (6-12 scale)
```
Stat Name       Range   Source          Application                      Notes
─────────────────────────────────────────────────────────────────────────────
Aim             6-12    Unit type       Accuracy in combat               Primary for shooters
Melee           6-12    Unit type       Melee attack accuracy            Primary for close combat
Reaction        6-12    Unit type       Initiative + dodge chance        Turn order, overwatch
Speed           6-12    Unit type       Hex movement per turn            Combat mobility
Bravery         6-12    Unit type       Morale loss resistance           Fear mechanics
Sanity          6-12    Unit type       Panic/suppression resistance    Alien exposure
```

#### Specialized Stats (variable ranges)
```
Stat Name       Range   Source          Application                      Notes
─────────────────────────────────────────────────────────────────────────────
Strength        5-15    Equipment       Carry capacity, melee damage     NEEDS DEFINITION
Piloting        6-12    Pilot training  Craft control, evasion           Once C1 resolved
Hacking         6-12    Training        Terminal/UFO hacking success     If enabled
Psychic         2-12    Rare trait      Psionic attack/defense           Asymmetric range
```

#### Resource Stats (fixed)
```
Stat Name       Range   Source          Application                      Notes
─────────────────────────────────────────────────────────────────────────────
Health          Variable Unit type       Damage absorption               50-200 typical
TimeUnits       Typical 60 Action economy Movement/action costs            Fixed per role
Morale          1-10    Dynamic         Suppression, retreat behavior     Affected by events
```

### Section 2: Stat Ranges & Distribution

#### Standard Combat Stats (6-12 scale)

**Rookie Unit Distribution**:
```
Stat        Min Max  Avg  Typical Roll Distribution
─────────────────────────────────────────────────
Aim         6   8    7    Most rookies: 7-8
Melee       6   8    7    Most rookies: 7-8
Reaction    6   9    7.5  Slightly higher variance
Speed       6   8    7    Most rookies: 7-8
Bravery     5   7    6    Lower - new recruits anxious
Sanity      6   8    7    Starts healthy
```

**Elite Unit Distribution** (end-game):
```
Stat        Min Max  Avg  Typical Range
─────────────────────────────────────────────────
Aim         9   12   10.5 Veteran soldiers 10-11
Melee       9   12   10.5 Trained fighters 10-11
Reaction    9   12   11   Quick learners 11-12
Speed       8   12   10   Specialized roles vary
Bravery     9   12   10.5 Hardened by combat
Sanity      6   12   8    Combat experience varies
```

**Progression Arc** (per stat gain):
```
Rank    Aim Gain    Melee Gain   Reaction Gain   Typical Path
─────────────────────────────────────────────────────────────
Rookie  0           0            0               Start: all 7
1       +0.2        +0.1         +0.15           After 5 missions
2       +0.2        +0.2         +0.15           Moderate usage
3       +0.2        +0.2         +0.2            Specialized use
4       +0.1        +0.3         +0.2            Elite path
5       +0.1        +0.3         +0.1            Specialization
6       +0.05       +0.2         +0.05           Diminishing returns
```

**Gain Formula**:
- Aim: +0.05 per combat kill
- Melee: +0.05 per melee combat
- Reaction: +0.03 per turn survived
- Speed: +0.02 per 10 hexes moved
- Bravery: +0.02 per casualty in squad (morale loss)
- Sanity: +0.01 per alien kill (exposure survival)

### Section 3: Bonus Calculation Standardization

#### Template: How Bonuses Work

**All stat bonuses follow this pattern**:
```
Base Value = Character's Raw Stat (6-12)
Bonus Percentage = (Stat - 6) × Bonus Rate
Applied Modifier = Base Value × (1 + Bonus Percentage)

Example: Aim 10, weapon base accuracy 70%
  Bonus% = (10 - 6) × 5% = 20%
  Final Accuracy = 70% × (1 + 0.20) = 84%
```

#### Stat Application Matrix

| Bonus Source | Type | Rate | Calculation | File Reference |
|---|---|---|---|---|
| **Aim Stat** | Accuracy | 5% per point | Base% × (1 + (Aim-6)×0.05) | DamageTypes.md |
| **Melee Stat** | Damage | 3% per point | Base DMG × (1 + (Melee-6)×0.03) | Items.md |
| **Reaction Stat** | Initiative | +2 per point | Turn Order + (Reaction-6)×2 | Battlescape.md |
| **Speed Stat** | Movement | +0.5 hex | Movement = Speed - 5 hexes/AP | Battlescape.md |
| **Bravery Stat** | Morale Loss | -5% per point | Morale Loss × (1 - (Bravery-6)×0.05) | MoraleBraverySanity.md |
| **Sanity Stat** | Panic Resist | -5% per point | Panic Check × (1 - (Sanity-6)×0.05) | MoraleBraverySanity.md |
| **Strength Stat** | Carry | +2 capacity | Max Carry = 50 + (Strength-5)×2 | Inventory.md |
| **Piloting Stat** | Evasion | +3% per point | Evasion = 5% + (Piloting-6)×3% | Crafts.md |

### Section 4: Stat Modifiers (Permanent & Temporary)

#### Trait Bonuses (Permanent)
```
Trait Name              Stats Affected          Bonus Amount
────────────────────────────────────────────────────────────
Quick Reflexes          Reaction                +2
Sharp Eyes              Aim                     +1
Strong Will             Bravery                 +2
Iron Lungs              Sanity                  +1
Heavy Build             Strength                +2
Commanding Presence     Bravery (squad)         +1 nearby
Natural Medic           Sanity (allied)         +1 nearby
```

#### Status Effect Modifiers (Temporary)
```
Status              Affected Stat           Penalty         Duration
────────────────────────────────────────────────────────────────────
Suppression         Aim                     -2              Until suppressed
Bleeding            Reaction                -1              Until healed
Burning             Bravery                 -2              Until extinguished
Poisoned            Sanity                  -1              Until antidote
Stunned             All                     -4              1-2 turns
```

#### Equipment Modifiers
```
Equipment Type      Stat Modified           Modifier        Context
─────────────────────────────────────────────────────────────────
Scope              Aim                     +1              Ranged weapons
Body Armor         Speed                   -1              Reduces mobility
Combat Stimulant   Bravery                 +2              Mission duration
Psi Armor          Sanity                  +3              Against psychics
```

### Section 5: Strength Stat - NEW DEFINITION

**Issue**: Strength referenced in Items.md but never defined in Units.md

**Solution - Strength Stat Specification**:

#### Range
```
Rookie: 5-8
Elite:  8-15
Maximum: 15 (superhuman)
Minimum: 3 (crippled state)
```

#### Applications
1. **Carry Capacity** (primary)
   - Base capacity: 50 kg
   - Per point: +2 kg per point above 5
   - Formula: Capacity = 50 + (Strength - 5) × 2

2. **Melee Damage** (secondary)
   - Bonus damage per melee hit
   - Formula: Melee Bonus = (Strength - 5) × 2 damage
   - Example: Strength 10 = +10 damage per melee attack

3. **Climbing/Jumping** (situational)
   - Climbing cost: 2-3 AP (reduced by 0.5 per Strength above 8)
   - Jumping distance: 1 hex + (Strength-5)÷2 hexes
   - Example: Strength 11 = 3 hex jump

#### Acquisition
- **Base**: Determined by unit type (Soldier 7, Tank 12, Scout 6)
- **Gain**: +0.02 per 50 kg item carried (encourages heavy equipment users)
- **Training**: +1 from "Strength Training" facility (monthly)
- **Trait**: "Strong Build" trait starts with +2 Strength

#### Equipment Restrictions
```
Item Type           Strength Required   Penalty if Below
──────────────────────────────────────────────────────
Plasma Rifle        8                   -20% accuracy
Heavy Armor         10                  -1 movement
Rocket Launcher     12                  -2 AP to fire
Mining Laser        7                   Can't carry more than 1
```

### Section 6: Stat Cap & Soft Limits

#### Hard Caps (cannot exceed)
```
Stat            Absolute Max    Override Condition
──────────────────────────────────────────────────
All Combat      12              None (universal rule)
Psychic         12              Exception to 2-12 rule
Strength        15              Only with specific traits
Health          Varies          Unique per unit type
```

#### Soft Caps (balance at these points)
```
Stat            Soft Cap    Gain Penalty After Cap
──────────────────────────────────────────────────
Aim             11          Halved gains
Bravery         10          Loss from casualties = +5% extra
Sanity          9           Recovery slowed by 20%
```

#### Diminishing Returns
```
For all stats, once unit reaches elite rank:
- Level 1-3: Full gains
- Level 4-5: 75% gains
- Level 6+: 50% gains

This prevents single units becoming overpowered.
```

### Section 7: Reference Tables for Developers

#### Quick Lookup: Stat Bonus Formulas

```lua
-- Aim accuracy bonus
function get_aim_bonus(aim_stat)
  return (aim_stat - 6) * 0.05  -- +5% per point above 6
end

-- Melee damage bonus
function get_melee_bonus(melee_stat)
  return (melee_stat - 6) * 3  -- +3 damage per point
end

-- Reaction initiative bonus
function get_reaction_bonus(reaction_stat)
  return (reaction_stat - 6) * 2  -- +2 initiative per point
end

-- Speed movement bonus
function get_speed_bonus(speed_stat)
  return speed_stat - 5  -- Hexes per turn
end

-- Bravery morale reduction
function get_bravery_bonus(bravery_stat)
  return (bravery_stat - 6) * 0.05  -- -5% morale loss per point
end

-- Strength carry bonus
function get_carry_capacity(strength_stat)
  return 50 + (strength_stat - 5) * 2  -- Base 50 + 2 per point
end
```

#### Distribution Tables

**Random rookie generation**:
```
Roll 1d6+5 for each combat stat (results 6-11)
Roll 1d4+4 for Strength (results 5-8)
Roll 1d2+5 for Sanity (results 6-7)
Roll 1d3+4 for Bravery (results 5-7)
```

**Unit type modifiers** (applied after roll):
```
Soldier:   Aim +0, Melee +0, Bravery +1, Sanity +0
Assault:   Aim -1, Melee +2, Bravery +1, Sanity -1, Strength +2
Scout:     Aim +1, Melee -1, Reaction +1, Speed +1, Bravery -1
Medic:     Aim -1, Sanity +2, Bravery +1
Support:   Reaction +1, Bravery +0
```

---

## ACCEPTANCE CRITERIA

This task is complete when:

- ✅ Master Stat Table document created and linked
- ✅ All 10-12 stats defined with ranges
- ✅ Bonus calculation formulas documented with examples
- ✅ Strength stat completely specified
- ✅ Lua reference code provided
- ✅ Distribution tables for game generation
- ✅ Cross-references updated in all mechanics files
- ✅ No contradictions between files
- ✅ Developer can implement without guessing
- ✅ Reviewed and approved by Lead Designer

---

## IMPLEMENTATION PLAN

### Step 1: Create Master Document (1h)
1. Create `design/mechanics/MASTER_STAT_TABLE.md`
2. Copy all tables above
3. Add HTML version for quick reference
4. Create Lua constants file `engine/core/stat_constants.lua`

### Step 2: Update Cross-References (1h)
1. Update Units.md: Add link to Master Stat Table
2. Update Pilots.md: Link to stat definitions
3. Update Items.md: Reference Strength stat specification
4. Update Battlescape.md: Reference bonus formulas

### Step 3: Create Reference Materials (1.5h)
1. Create `design/mechanics/STAT_QUICK_REFERENCE.md` (one-page lookup)
2. Create `design/mechanics/STAT_EXAMPLES.md` (worked examples)
3. Create `design/mechanics/STAT_PROGRESSION_CURVES.md` (visual graphs)

### Step 4: Developer Integration (0.5h)
1. Add constants to `engine/core/stat_constants.lua`
2. Create unit test for stat bonus calculations
3. Create validator for stat ranges

### Step 5: Validation (1h)
1. Cross-check all formulas
2. Verify no contradictions with other files
3. Get designer approval
4. Get balance designer approval on progression curves

---

## TESTING STRATEGY

### Test Scenarios

**Scenario 1: Rookie Unit Stat Generation**
```
Create 100 rookie units, verify:
- All stats in range 6-8 (or type-specific)
- Strength in 5-8 range
- No unit exceeds hard caps
```

**Scenario 2: Stat Bonus Application**
```
Apply bonuses correctly:
- 10 Aim = 70% base × 1.20 = 84% ✓
- 8 Melee = 10 base DMG × 1.06 = 10.6 DMG ✓
- 12 Speed = 7 hexes/turn ✓
```

**Scenario 3: Stat Progression**
```
Simulate unit progression:
- 10 missions of combat
- Verify stat gains within defined limits
- Check soft caps applied at rank 4+
```

**Scenario 4: Stat Modifiers Stack Correctly**
```
Unit with:
- Base Aim: 9
- Trait bonus +1 = 10
- Scope bonus +1 = 11
- Suppression penalty -2 = 9
Final result: 9 ✓
```

---

## DOCUMENTATION TO UPDATE

| File | Section | Change |
|------|---------|--------|
| design/mechanics/Units.md | Section 1 | Add link to Master Stat Table |
| design/mechanics/Pilots.md | All | Add reference to Master Stat Table |
| design/mechanics/Items.md | Equipment bonuses | Reference Master Stat Table formulas |
| design/mechanics/DamageTypes.md | Damage calculations | Use standardized formulas |
| design/mechanics/Battlescape.md | Combat resolution | Reference master bonus table |
| design/mechanics/MoraleBraverySanity.md | Morale calculations | Use standardized formulas |
| api/GAME_API.toml | [unit.stats] | Add Strength stat definition |
| README.md | Quick Reference | Link to Master Stat Table |

---

## COMPLETION CHECKLIST

- [ ] Read design/mechanics/Units.md Section 1-3
- [ ] Review gap analysis findings on stat inconsistencies
- [ ] Create Master Stat Table document
- [ ] Define Strength stat completely
- [ ] Create Lua constants file
- [ ] Create one-page quick reference
- [ ] Create worked examples document
- [ ] Update all cross-references
- [ ] Create unit tests
- [ ] Run test scenarios
- [ ] Get designer review
- [ ] Publish and communicate to team

---

## NOTES

**Coordinate With**: C1 (Pilot Stat Scale) - once that's decided, verify Piloting stat spec
**Updates**: Depends on C1 decision being finalized first
**Risk**: Strength stat addition may require equipment rebalancing
**Communication**: Inform all systems designers once complete

---

**Created**: October 31, 2025
**Status**: READY FOR DESIGN DECISION
**Approver**: Lead Game Designer
