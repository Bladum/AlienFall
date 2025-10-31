# Task: CRITICAL #3 - Clarify Action Point (AP) System

**Status:** TODO
**Priority:** Critical
**Created:** 2025-10-31
**Completed:** N/A
**Assigned To:** Combat Designer + Engine Developer

---

## Overview

**BLOCKER**: AP system contradicts itself on maximum value and has ambiguous health penalty thresholds.

**Contradictions**:
- Units.md says Range 1-4 but also mentions "Maximum: 5 AP (rare, exceptional)"
- Health penalty says "<50%" but doesn't specify exact threshold
- Movement costs unclear (1-2 AP per action vs AP × Speed stat formula)

**Impact**: Combat feel unpredictable, difficulty tuning impossible, action economy unbalanced.

---

## Purpose

Combat action economy is fundamental to tactical gameplay. Ambiguous AP system makes it impossible to:
- Balance difficulty
- Design meaningful tactical decisions
- Ensure fair player experience
- Test combat properly

---

## Requirements

### Functional Requirements
- [ ] Maximum AP clearly defined (4 or 5?)
- [ ] Minimum AP clearly defined (1 AP guaranteed)
- [ ] Health penalty threshold exact (e.g., "≤50%" or "<50%")
- [ ] AP penalty mechanics fully specified
- [ ] Movement cost formula clear and consistent
- [ ] Difficulty scaling implications documented

### Technical Requirements
- [ ] All penalty sources quantified
- [ ] Penalty application order specified (order matters for min/max)
- [ ] Edge cases defined (what if all penalties apply?)
- [ ] Formula matches implementation requirements

### Acceptance Criteria
- [ ] No contradictions between Battlescape.md and Units.md
- [ ] Every example calculation works with formula
- [ ] Developers can implement without guessing
- [ ] Combat balance testable

---

## Current Contradictions

### Contradiction #1: Maximum AP

**Units.md (lines 131-176)**:
```
Valid Range: 1-4 AP per turn
Minimum: 1 AP (guaranteed)
Maximum: 5 AP (with positive modifiers - rare, exceptional)
```

**Question**: Is max 4 or 5?
- If **1-4 is valid range**, then 5 violates range
- If **5 is possible**, then range is 1-5, not 1-4

**Impact**:
- If max is 4: Balanced action economy
- If max is 5: One extra action possible (balance breaking?)

### Contradiction #2: Health Penalty

**Units.md (line 144)**:
```
- Health <50%: -1 AP
```

**Question**: At what EXACT health value does penalty apply?
- If health == 49.9%: penalty applies? (seems yes, <50%)
- If health == 50.0%: penalty applies? (seems no, not <50%)
- If health == 50.1%: penalty applies? (seems no, >50%)

**But implementation needs exact threshold**:
- Do we check "health < max_health * 0.5"?
- Do we check "health <= max_health * 0.5"?
- Do we use integer health (e.g., 25 HP = 50% of 50)?

### Contradiction #3: Movement Cost

**Units.md (lines 157-159)**:
```
Usage: Alternative AP cost for movement based on terrain
Calculation: Speed determines hexagons traversable per movement action
Affected By: Armor weight, encumbrance, status effects (stunned, exhausted)
```

**But also (line 168)**:
```
Movement Points
- Base: AP × Speed stat
```

**Question**: What's the actual formula?
- Option A: "Movement action costs 1 AP, grants Speed hexagons of movement"
- Option B: "Movement grants AP × Speed total hexagons"
- Option C: "Each hex costs 1/(Speed) AP"

**Impact**: Heavily affects combat pacing

---

## Plan

### Step 1: Designer Decision on Combat Philosophy
**Description**: Determine what combat AP should feel like
**Decision Points**:
- [ ] Should players feel "tight" on actions (lower AP) or "generous"?
- [ ] Should health penalties be significant (punish risky play)?
- [ ] Should Speed stat feel impactful?

**Owner:** Combat Designer
**Estimated time:** 1-2 hours

### Step 2: Define Exact AP Values
**Description**: Nail down exact maximum and minimum AP
**Decisions needed**:
- [ ] Max AP: 4 or 5? (Recommend 4 for balance)
- [ ] Min AP: Always 1? (Recommend yes)
- [ ] Neutral state AP: 4 (most common)

**Estimated time:** 1 hour

### Step 3: Define Health Penalty Thresholds
**Description**: Specify EXACT health percentages for penalties
**Penalties to define**:
- [ ] Health <50%: -1 AP (at what exact health?)
- [ ] Health <25%: Additional penalty? (Not currently mentioned!)
- [ ] Health 0 or below: -4 AP (death)?

**Recommendation**:
```
Penalty Structure:
- 100%-51% health: No penalty
- 50%-26% health: -1 AP (critical)
- 25%-1% health: -2 AP (critical)
- 0% health: Unit incapacitated (0 AP)
```

**Estimated time:** 1 hour

### Step 4: Define Movement Formula
**Description**: Choose and fully specify movement cost formula
**Options**:

**Option A: Movement Action Model** (Recommended)
```
Movement Action: Costs 1 AP, grants Speed hexagons
Examples:
- Speed 6: 1 AP = 6 hexagons movement
- Speed 9: 1 AP = 9 hexagons movement
- Speed 12: 1 AP = 12 hexagons movement
```

**Option B: Total Movement Points Model**
```
Total Movement: AP × Speed hexagons per turn
Examples:
- 4 AP × Speed 6 = 24 hexagons total per turn
- 4 AP × Speed 12 = 48 hexagons total per turn
```

**Option C: Cost Per Hex Model**
```
Each hex costs: 1/Speed AP
Examples:
- Speed 6: Each hex costs 0.167 AP ≈ 0.17 AP per hex
- Speed 12: Each hex costs 0.083 AP per hex
```

**Recommendation**: Option A (cleanest, most intuitive)

**Estimated time:** 1 hour

### Step 5: Create AP System Specification
**Description**: Write definitive AP specification document
**Files to create**:
- `design/mechanics/COMBAT_AP_SYSTEM_SPEC.md` (new)

**Contents**:
- Complete AP formula with all modifiers
- Penalty application order
- Example calculations (10+ worked examples)
- Edge cases (what if all penalties apply?)
- Movement formula with examples
- Difficulty scaling

**Estimated time:** 3 hours

### Step 6: Update Units.md
**Description**: Rewrite AP section with definitive spec
**Files to modify**:
- `design/mechanics/Units.md` (lines 131-176: Action Points section)

**Specific changes**:
- [ ] Remove contradictions
- [ ] Add exact penalty thresholds
- [ ] Add movement formula clarity
- [ ] Add 10 worked examples

**Estimated time:** 2 hours

### Step 7: Update Battlescape.md
**Description**: Verify Battlescape.md matches definitive AP spec
**Files to verify**:
- `design/mechanics/Battlescape.md`

**Specific checks**:
- [ ] Any AP references match new spec
- [ ] Movement calculations consistent
- [ ] Action economy examples valid

**Estimated time:** 1 hour

### Step 8: Testing & Validation
**Description**: Verify AP system is playable and balanced
**Test cases**:
- [ ] Unit with 4 AP can do meaningful actions (not stuck)
- [ ] Health penalty feels significant but fair
- [ ] Movement speed is intuitive (units move at expected rate)
- [ ] AP penalties stack correctly (no double-counting)

**Estimated time:** 2-3 hours

---

## Complete AP System Specification (Proposed)

### Base Action Points
```
Base AP per turn: 4 (fixed)
Minimum AP: 1 (guaranteed after all penalties)
Maximum AP: 4 (without bonuses)
Maximum with bonuses: 5 (rare, exceptional circumstances)
```

### Penalty Sources and Application

**Order of Application** (apply in this order to be precise):

1. **Base AP**: Start with 4
2. **Health Penalty**: If health ≤50% of max: -1 AP
3. **Morale Penalty**: If morale ≤2: -1 AP
4. **Sanity Penalty**: If sanity ≤4: -1 AP (proposed new)
5. **Stun Effect**: If stunned: -2 AP (replaces actions)
6. **Suppression**: If suppressed: -0 AP (but actions limited)
7. **Clamp to minimum**: If result < 1: Set to 1 AP

**Example Calculation**:
```
Base: 4 AP
- Health at 30% (≤50%): -1 AP = 3 AP
- Morale at 1 (≤2): -1 AP = 2 AP
- Sanity at 3 (≤4): -1 AP = 1 AP
- Stunned: -2 AP = -1 AP
- Clamp to min 1: 1 AP (final)
Result: Unit can take 1 action while recovering from stun
```

### Bonus Sources (Rare)

**Ways to exceed 4 AP**:
- Leadership aura: +1 AP (within 8 hexes of leader)
- Adrenaline trait: +1 AP (under fire)
- Special equipment: +1 AP (psi-tech enhancement)

**Result**: Maximum 5 AP achievable through stacking

### Movement Formula

**Chosen: Movement Action Model**

```
Movement Action:
- Cost: 1 AP
- Result: Move up to Speed stat number of hexagons
- Notes: Must be continuous path, cannot exceed movement allowance

Examples:
Speed 6: 1 AP = move up to 6 hexagons in straight line
Speed 9: 1 AP = move up to 9 hexagons (faster unit)
Speed 12: 1 AP = move up to 12 hexagons (elite unit)

Maximum Movement per Turn:
With 4 AP available and movement taking 1 AP:
- Could move 4 times: 4 × Speed stat hexagons maximum
- Example: Speed 6 unit could move 4 × 6 = 24 hexagons if using all AP
- But other actions (shoot, use item) also cost AP
- Typical: 1-2 movement actions per turn + 1-2 combat actions
```

### Armor Weight Modifier (for Movement)

**Armor encumbrance penalty**:
```
Light Armor: No penalty
Medium Armor: Speed -1
Heavy Armor: Speed -2
```

**Applied before calculation**:
```
Example: Heavy Armor user with Speed 9
Effective Speed: 9 - 2 = 7
1 AP movement = 7 hexagons (not 9)
```

### Example Scenarios

**Scenario 1: Healthy Soldier**
```
Health: 100/100 (100%)
Morale: 8 (strong)
Sanity: 10 (stable)
Armor: Medium

Calculation:
Base: 4 AP
- No health penalty (100% > 50%)
- No morale penalty (8 > 2)
- No sanity penalty (10 > 4)
- Not stunned

Final AP: 4 AP
Effective Speed: 9 - 1 = 8 hexagons per move

Action: Move (1 AP) + Shoot + Move (1 AP) = 3 AP used, 1 AP remaining
```

**Scenario 2: Wounded Soldier**
```
Health: 25/100 (25%)
Morale: 2 (panicked)
Sanity: 5 (stable)
Armor: Heavy

Calculation:
Base: 4 AP
- Health ≤50%: -1 AP = 3 AP
- Morale ≤2: -1 AP = 2 AP
- No sanity penalty (5 > 4)

Final AP: 2 AP
Effective Speed: 6 - 2 = 4 hexagons per move

Action: Move (1 AP) + Shoot (1 AP) = 2 AP used, 0 AP remaining
(Unit has taken no action this turn, just moved and shot once)
```

**Scenario 3: Stunned Soldier**
```
Health: 80/100 (80%)
Morale: 6 (good)
Sanity: 8 (stable)
Status: Stunned

Calculation:
Base: 4 AP
- No health penalty (80% > 50%)
- No morale penalty (6 > 2)
- No sanity penalty (8 > 4)
- Stunned: -2 AP = 2 AP

Final AP: 2 AP
BUT: Stunned units cannot use AP normally
Effect: Unit can take 1 action at 50% effectiveness OR must spend all 2 AP to recover

Next turn: Stun effect wears off, unit regains normal action economy
```

---

## Difficulty Scaling Impact

### Easy Mode
- Base AP: 5 (more generous action economy)
- Health penalty threshold: <25% instead of <50% (units more resilient)
- Morale penalty threshold: <1 instead of <2 (morale more forgiving)

### Normal Mode
- Base AP: 4 (standard)
- Health penalty: <50%
- Morale penalty: <2

### Hard Mode
- Base AP: 4 (same)
- Health penalty: <60% (more aggressive)
- Morale penalty: <3 (morale more fragile)
- Stun effect: -3 AP instead of -2 (more punishing)

---

## Implementation Details

### Code Pattern

```lua
function calculate_action_points(unit)
    local ap = 4  -- Base AP

    -- Health penalty
    local health_percent = unit.health / unit.max_health
    if health_percent <= 0.50 then
        ap = ap - 1
    end

    -- Morale penalty
    if unit.morale <= 2 then
        ap = ap - 1
    end

    -- Stun effect (special case)
    if unit.is_stunned then
        ap = ap - 2
    end

    -- Bonuses
    if is_near_leader(unit, 8) then
        ap = ap + 1
    end

    -- Clamp to valid range
    ap = math.max(1, ap)  -- Minimum 1
    ap = math.min(5, ap)  -- Maximum 5

    return ap
end
```

---

## Testing Strategy

### Unit Tests
- [ ] Each penalty calculated correctly
- [ ] Penalties stack correctly
- [ ] Minimum AP enforced (always ≥1)
- [ ] Maximum AP enforced (always ≤5)
- [ ] Movement formula produces correct hex count

### Integration Tests
- [ ] Unit with all penalties applied correctly
- [ ] Leadership aura bonus applies at range
- [ ] Stun effect prevents normal actions
- [ ] Health percentage calculation correct

### Manual Testing Steps
1. Create unit with 100% health → verify 4 AP
2. Damage unit to 50% health → verify 3 AP (-1)
3. Panic unit (morale 2) → verify 2 AP (-1 more)
4. Apply stun effect → verify 0 AP (but can use 1 after clamp to min)
5. Move unit with Speed 9 → verify 1 AP moves 9 hexagons
6. Apply leadership aura → verify +1 AP bonus

### Expected Results
- AP system feels responsive to unit state
- Damage and morale have meaningful impact
- Combat pacing feels right (not too slow, not too fast)

---

## Documentation Updates

### Files to Update
- [ ] `design/mechanics/Units.md` (lines 131-176)
- [ ] `design/mechanics/Battlescape.md` (verify AP references)
- [ ] Create `design/mechanics/COMBAT_AP_SYSTEM_SPEC.md` (new)
- [ ] `design/mechanics/MoraleBraverySanity.md` (if sanity penalties added)

---

## Review Checklist

- [ ] No contradictions between max 4 and 5
- [ ] Health penalty threshold exact
- [ ] Movement formula clear and consistent
- [ ] All penalty sources documented
- [ ] Example calculations work correctly
- [ ] Implementation code pattern provided
- [ ] Difficulty scaling defined
- [ ] Combat balance feels fair

---

## Related Tasks

Related to this task:
- CRITICAL #1: Pilot Stat Scale (affects difficulty tuning)
- MEDIUM #6: Turn Order & Initiative (affects turn sequence)
- MEDIUM #8: Damage Application Timing (affects AP timing)

---

## Success Criteria

**AP system is complete when**:
- ✅ Developers can implement without ambiguity
- ✅ Playtesters report combat feels balanced
- ✅ Health penalties feel meaningful but fair
- ✅ Action economy supports diverse tactics
- ✅ Difficulty modes have distinct AP feel
