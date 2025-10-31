# 🎯 CRITICAL_005: Resolve Unit Stat Ranges

**Severity**: 🔴 CRITICAL
**Blocker For**: Character progression, equipment balance, achievement system
**Estimated Effort**: 8 hours
**Dependencies**: C4 (Master Stat Table) - should be parallel/sequential

---

## OVERVIEW

**Problem**: Unit stat ranges are inconsistent across different files:

1. **Primary Definition (Units.md)**: Claims 6-12 for most stats
2. **Alternate Reference (Pilots.md)**: Claims 0-100 for Piloting
3. **Implied by Examples (Battlescape.md)**: Some references suggest 0-20 range
4. **Items.md References**: Equipment bonuses use different scaling
5. **Achievement System**: Lacks stat thresholds

**Current Contradictions**:
- What does "high Aim" mean? 10? 12? 90 out of 100?
- Can stats ever exceed 12? (Some traits suggest yes)
- What's the minimum? (Crippled units = 1? 0? undefined?)
- How do modifiers stack? (Traits + equipment + status effects)

**Impact**:
- Equipment balance impossible without knowing stat ranges
- Achievement design can't set meaningful thresholds
- Unit generation may create invalid characters
- Stat displays ambiguous to players ("92 Aim" vs "11 Aim"?)

**Solution**: Establish definitive, consistent stat ranges and enforce them everywhere.

---

## DESIGN SPECIFICATION

### Section 1: Comprehensive Stat Range Audit

#### Current Contradictions Identified

**Issue 1: Piloting Stat Range**
```
Units.md Line 1187:    "Piloting Stat: 6-12 Scale"
Pilots.md Line 70:     "Piloting is a unit stat (0-100 range)"
Pilots.md Line 80:     "Every 100 XP gained: +1 Piloting"
Pilots.md Line 86-89:  "Scout +10 Piloting, Gunner +5 Piloting"

Resolution: C1 must be completed first
Likely Outcome: 6-12 scale (matches all others), Pilots.md is outdated
```

**Issue 2: Stat Maximums**
```
Units.md claims:       "Maximum is 12"
Traits.md suggests:    Some traits allow exceeding 12 (e.g., "Superhuman Strength")
Economics imply:       High-rank units might reach 13-15 after 100 missions

Resolution: Clarify hard caps vs soft caps
- Hard cap: Absolute max (always enforced)
- Soft cap: Balance point (gains slow down)
```

**Issue 3: Minimum Values**
```
Units.md specifies:    "Minimum 6"
Injuries might create: Less than 6?
Permanently disabled:  At what stat value?

Resolution: Define recovery and permanent injury mechanics
```

**Issue 4: Stat Distribution**
```
Rookies:              6-8 typical
Elite soldiers:       10-12 typical
But what about       extreme outliers?
10 rookies generated  = any guarantee of distribution?
```

### Section 2: Definitive Stat Range Specification

#### Standard Ranges (Apply to all combat stats)

```
Stat Category       Min     Soft Cap  Hard Cap  Typical Range
──────────────────────────────────────────────────────────────
Combat Stats        6       10        12        6-12
(Aim, Melee,
 Reaction, Speed,
 Bravery, Sanity)

Specialty Stats     Varies  Varies    Varies    See below
(Strength,
 Piloting, Hacking)

Psychic Stat        2       8         12        2-12 (asymmetric)
(Unique case)
```

#### Stat-by-Stat Range Breakdown

**COMBAT STATS - Standard 6-12 Range**

| Stat | Min | Soft Cap | Hard Cap | Below Min | Above Max | Notes |
|------|-----|----------|----------|-----------|-----------|-------|
| **Aim** | 6 | 10 | 12 | Never occurs (rookies 6+) | Elite + trait | Can exceed 12 with specific traits |
| **Melee** | 6 | 10 | 12 | Combat injury | Specialized training | Combat veterancy can exceed 12 |
| **Reaction** | 6 | 10 | 12 | Shellshock (-2) | Rare trait | Genetic condition rare |
| **Speed** | 6 | 10 | 12 | Injury (-2 to -4) | Rare trait | Superhuman speed unusual |
| **Bravery** | 5 | 9 | 12 | Permanently broken (<2) | Iron will trait | Can start below 6 |
| **Sanity** | 1 | 8 | 12 | Full breakdown (<1) | Trained psychologist | Psychotic state possible |

**SPECIALTY STATS - Variable Ranges**

| Stat | Min | Soft Cap | Hard Cap | Application | Notes |
|------|-----|----------|----------|-------------|-------|
| **Strength** | 3 | 10 | 15 | Carry capacity, melee dmg | Can exceed 12; superhuman possible |
| **Piloting** | 2 | 9 | 12 | Craft control, evasion | Once C1 resolved; starts lower for non-pilots |
| **Hacking** | 4 | 9 | 12 | Terminal/UFO hacking | Optional system; specialists only |

**PSYCHIC STAT - Exception Case**

| Property | Value | Rationale |
|----------|-------|-----------|
| **Min** | 0 | Non-psychics have Psychic = 0 |
| **Starting** | 2 | Rare birth trait |
| **Soft Cap** | 8 | Balance point |
| **Hard Cap** | 12 | Same as combat stats |
| **Acquisition** | Trait-locked | Only psychic units have this |
| **Scaling** | Different? | May use different bonus formula |

#### Health Points - Special Case

**Not a "stat" but needs range definition**:
```
Unit Type       Base HP    Min         Max         Notes
─────────────────────────────────────────────────────────
Soldier         100        50 (crit)   150 (rare)  Standard
Heavy           150        100         200         Tank role
Scout           75         50          100         Glass cannon
Medic           90         60          120         Support

Modifiers:
- Injury reduces max HP by 5-25%
- Armor provides damage reduction, not HP bonus
- Strength +1 = +5 HP (equipment effect)
```

### Section 3: Stat Soft Caps & Progression Boundaries

#### Soft Cap Mechanics

**What is a Soft Cap?**
- At soft cap, experience gains/stat increases slow down
- Encourages diverse unit development
- Prevents single unit domination
- Balances unit progression across roster

**Soft Cap Rules**:

```
Tier 1: Below Soft Cap (Rookie progression)
  - Gains: Full rate
  - Duration: Missions 1-20
  - Typical result: Reach soft cap by rank 4-5

Tier 2: At Soft Cap (Elite progression)
  - Gains: 75% rate
  - Duration: Missions 20-50
  - Typical result: Reach 11-12 by rank 6-7

Tier 3: Above Soft Cap (Veteran mastery)
  - Gains: 50% rate
  - Duration: Missions 50+
  - Typical result: Rare to exceed hard cap
```

**Implementation**:
```lua
function apply_soft_cap_penalty(stat_gain, current_stat, soft_cap, hard_cap)
    if current_stat < soft_cap then
        return stat_gain  -- Full gains
    elseif current_stat < hard_cap then
        return stat_gain * 0.75  -- 75% gains at soft cap
    else
        return 0  -- No gains at hard cap
    end
end
```

### Section 4: Range Consistency Rules

#### Universal Rules (Apply Everywhere)

**Rule 1: 6-12 Scale is Standard**
```
ANY new stat must default to 6-12 range
Exceptions require explicit design decision documented in Design Decisions Log
```

**Rule 2: Minimum Never Below Min Defined**
```
Aim cannot fall below 6 through any mechanic
Exception: Permanent injury (special case)
```

**Rule 3: Hard Cap is Hard**
```
No normal mechanic can exceed hard cap
Traits/perks may grant temporary bypass
Only very rare trait allows permanent bypass
```

**Rule 4: Stat Display Consistency**
```
UI shows "Aim: 10" not "Aim: 10/12" (redundant)
UI shows "Health: 85/100" (current/max, exception)
Tooltips show range on hover: "Aim (6-12)"
```

### Section 5: Stat Modifier Stacking

#### How Modifiers Combine

**Problem**: Current system unclear about stacking
- Traits give +1-+2 each
- Equipment gives +1
- Status effects give -1 to -4
- What's the total? How many can stack?

**Solution: Explicit Stacking Rules**

#### Stacking Hierarchy

**Permanent Modifiers (applied first, stack normally)**:
```
Base Stat (6-12)
  + Trait 1 bonus
  + Trait 2 bonus
  + Class bonus
  ─────────────────
  = Modified Base Stat
```

**Equipment Modifiers (add to modified base)**:
```
Modified Base Stat
  + Armor bonus
  + Weapon bonus
  + Accessory bonus
  ─────────────────
  = Equipment-Enhanced Stat
```

**Status Effect Modifiers (applied last, can go negative)**:
```
Equipment-Enhanced Stat
  - Suppression penalty
  - Wound penalty
  - Burn penalty
  - Stun penalty
  ─────────────────
  = Final Combat Stat

Final stat: Cannot go below 1 (minimum competence)
Final stat: Capped at hard cap (12 for most)
```

#### Stacking Limits

```
Trait bonuses:     Maximum 2 traits affecting same stat
Equipment bonuses: Maximum 3 items affecting same stat
Status penalties:  Stack normally (multiple debuffs allowed)

Example:
  Aim 8 (base)
  + Quick Shot trait (+1) = 9
  + Sniper trait (+1) = 10
  + Scope equipment (+1) = 11
  - Suppressed (-2) = 9 final

Traits limit prevents stacking bonuses infinitely
Equipment limit prevents stacking optimal gear
Status effects allowed to stack for tactical challenge
```

### Section 6: Out-of-Range Scenarios

#### What Happens When Stat Would Go Out of Range?

**Scenario 1: Stat Gains Would Exceed Hard Cap**
```
Rule: Clamp to hard cap
Example: Veteran at 12 Aim gains XP → still 12 Aim
Design: Encourages roster diversification
```

**Scenario 2: Injury Reduces Stat Below Minimum**
```
Rule: Stat reduced but not below minimum
Example: Veteran 11 Aim, arm broken → 8 Aim (minimum 6)
Recovery: +1 per week in base hospital
Design: Injuries matter but aren't permanent
```

**Scenario 3: Permanent Disability**
```
Rule: Some injuries permanently reduce max stat
Example: "Nerve damage" trait: Max Aim = 9 (permanent)
Acceptance: Unit still playable, different role
Design: Retirement or reassignment
```

**Scenario 4: Multiple Status Effects Drop Stat Below 1**
```
Rule: Minimum 1 (can barely function)
Example: Suppressed (-2), wounded (-1), stunned (-2) = below 0
Result: Stat effective 1 (5% base effectiveness)
Design: Heavily wounded soldiers nearly useless
```

### Section 7: Stat Range Reference for Each System

#### Combat System (Battlescape.md)
```
Stats used: Aim, Melee, Reaction, Speed
Range: Always 6-12
Modifiers applied: Equipment, traits, status, morale
Display: "Aim: 10" (integer only)
Formula examples:
  Accuracy = base_accuracy × (1 + (aim_stat - 6) × 0.05)
  Initiative = base_init × (reaction_stat / 9)
```

#### Equipment System (Items.md)
```
Stats used: Aim, Melee, Strength
Range: 6-12 (standard) or 5-15 (Strength special)
Bonuses: +1 typical (equipment does NOT stack with stats)
Formula:
  Carry capacity = 50 + (strength_stat - 5) × 2
  Melee damage = base_damage × (1 + (melee_stat - 6) × 0.03)
```

#### Progression System (Units.md)
```
Stats used: All (Aim, Melee, Reaction, Speed, Bravery, Sanity)
Range: 6-12 (hard cap at 12, soft cap at 10)
Gain rate: 0.05-0.2 per mission (depends on stat)
Soft cap penalty: 75% gains from rank 5+, 50% from rank 6+
```

#### Morale System (MoraleBraverySanity.md)
```
Stats used: Bravery, Sanity (not standard 6-12)
Bravery: 5-12 range (can start lower due to recruits)
Sanity: 1-12 range (psychotic episodes possible)
Effect: Morale loss = Base × (1 - (Bravery - 5) × 0.05)
```

---

## ACCEPTANCE CRITERIA

This task is complete when:

- ✅ All stat ranges defined in single authoritative document
- ✅ Soft cap vs hard cap clearly distinguished
- ✅ Stacking rules explicit and unambiguous
- ✅ Out-of-range scenarios covered with examples
- ✅ Cross-references updated in Units.md, Items.md, Battlescape.md
- ✅ Lua code for range validation exists
- ✅ Unit tests verify range enforcement
- ✅ UI properly displays stats and their ranges
- ✅ No contradictions between files
- ✅ Designer review completed

---

## IMPLEMENTATION PLAN

### Step 1: Create Range Authority Document (2h)
1. Create `design/mechanics/STAT_RANGES_AUTHORITATIVE.md`
2. Include all tables from Section 1-7 above
3. Add visual graphs of progression curves
4. Create one-page reference sheet

### Step 2: Update Core Mechanics Files (2h)
1. Update Units.md: Add hard/soft cap terminology
2. Update Items.md: Reference range tables
3. Update Battlescape.md: Show range in formulas
4. Update MoraleBraverySanity.md: Specify Bravery/Sanity ranges

### Step 3: Implement Range Validation (2h)
1. Create `engine/core/stat_validator.lua`
2. Implement `is_valid_stat(stat_name, value)` function
3. Implement `clamp_to_range(stat_name, value)` function
4. Add unit tests for validation logic

### Step 4: Update UI Display (1h)
1. Update stat display widgets to show range on hover
2. Add visual indicator for soft cap (e.g., color change at 10)
3. Add visual indicator for hard cap reached
4. Create stat comparison tool showing ranges

### Step 5: Communicate & Verify (1h)
1. Update GAME_API.toml with range specifications
2. Brief development team on new ranges
3. Get approval from balance designer
4. Document in developer handbook

---

## TESTING STRATEGY

### Test Scenarios

**Scenario 1: Stat Generation Respects Ranges**
```
Create 1000 rookie units, verify:
- All Aim stats in 6-8 range
- No stats below 6 (except Bravery/Sanity)
- No stats above 12 (except Strength)
```

**Scenario 2: Soft Cap Slows Progression**
```
Simulate veteran unit gaining XP:
- Rank 1-3: Stats gain at normal rate
- Rank 4-5: Stats gain at 75% rate
- Rank 6+: Stats gain at 50% rate
- Rank 7: Verify hard cap at 12
```

**Scenario 3: Stacking Rules Enforced**
```
Unit with:
- Trait 1 bonus: +1 Aim
- Trait 2 bonus: +1 Aim (allow 2 traits max)
- Trait 3 bonus: +1 Aim (BLOCK - exceeds limit)
Final: Only traits 1 & 2 applied
```

**Scenario 4: Out of Range Clamping**
```
Status effects reduce Aim from 10:
- Suppression -2 → Aim 8 ✓
- Wound -2 → Aim 6 (minimum, can't go lower) ✓
- Additional -1 → Still 6 (clamped) ✓
```

**Scenario 5: Range Display Correct**
```
UI shows:
- Aim: 10 (with tooltip "6-12")
- Health: 85/100 (shows current/max)
- Suppressed unit: Red indicator on Aim stat
```

---

## DOCUMENTATION TO UPDATE

| File | Section | Change |
|------|---------|--------|
| design/mechanics/Units.md | Stat definitions | Add range specification table |
| design/mechanics/Items.md | Equipment bonuses | Reference stat ranges |
| design/mechanics/Battlescape.md | Combat formulas | Show stat range in examples |
| design/mechanics/MoraleBraverySanity.md | Stat effects | Specify Bravery/Sanity ranges |
| api/GAME_API.toml | [unit.stats] section | Add range/min/max specifications |
| engine/core/stat_constants.lua | Constants | Add range definitions |
| README.md | Quick ref | Link to range specifications |

---

## COMPLETION CHECKLIST

- [ ] Create definitive range document
- [ ] Update all cross-references
- [ ] Implement validation code
- [ ] Create unit tests
- [ ] Update UI for range display
- [ ] Test soft cap mechanics
- [ ] Test stacking rules
- [ ] Brief team on changes
- [ ] Get designer approval
- [ ] Get balance approval
- [ ] Publish and archive old docs

---

## NOTES

**Depends On**: C4 (Master Stat Table) should complete first
**Coordinates With**: C1 (Pilot stat), C6 (Strength stat)
**Impact**: All downstream systems depend on consistent ranges
**Communication**: Announce to all game teams once finalized

---

**Created**: October 31, 2025
**Status**: READY FOR DESIGN DECISION
**Approver**: Lead Game Designer
