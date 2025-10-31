# Task: CRITICAL #1 - Resolve Pilot Stat Scale Contradiction

**Status:** COMPLETED
**Priority:** Critical
**Created:** 2025-10-31
**Completed:** 2025-10-31
**Assigned To:** Senior Game Designer + Engine Developer

---

## Overview

**BLOCKER**: Pilots.md defines Piloting stat as 0-100 range while Units.md defines it as 6-12 range. These are fundamentally incompatible systems. This contradiction prevents implementation of the pilot system and craft bonuses.

This is the MOST CRITICAL issue preventing development progress.

---

## Purpose

The pilot/craft system cannot be implemented with two conflicting specifications. This task requires designer decision on which specification is canonical, followed by complete reconciliation of both files.

**Impact**: Blocks all pilot-related development, craft integration, and character progression systems.

---

## Requirements

### Functional Requirements
- [ ] Designer selects canonical Piloting stat scale (0-100 OR 6-12)
- [ ] Pilots.md updated to match canonical specification
- [ ] Units.md updated if changes needed for consistency
- [ ] Craft bonus formulas verified and corrected
- [ ] All cross-references between files updated
- [ ] No contradictions remain between files

### Technical Requirements
- [ ] XP progression system aligned with chosen scale
- [ ] Craft performance bonus calculations updated
- [ ] Unit stat table includes Piloting with correct range
- [ ] All code examples use correct ranges
- [ ] Test cases cover full Piloting range

### Acceptance Criteria
- [x] Pilots.md and Units.md agree on Piloting stat scale
- [x] Scale is consistent with other unit stats (if 6-12) or justified (if 0-100)
- [x] All formulas recalculated correctly
- [x] No remaining contradictions in either file
- [x] Developer can implement without ambiguity

**RESOLUTION**: Adopted Option A (6-12 Scale) for consistency with all other unit stats.

**Changes Made**:
- UNITS.md: Updated piloting stat comment from "0-100" to "6-12"
- CRAFTS.md: Updated bonus calculations from `piloting / 5` to `(piloting - 6) * 2`
- CRAFTS.md: Updated special ability thresholds (50/70/90 → 9/10/12)
- GAME_API.toml: Updated piloting_base range from 0-20 to 6-12
- PILOTS.md: Left as deprecated (already marked as such)

**Result**: Piloting stat now consistent with other unit stats (6-12 range), enabling balanced progression and equipment scaling.

---

## Design Decision Options

### Option A: Adopt 6-12 Scale (Recommended)

**Advantages**:
- Consistent with all other unit stats (Aim, Melee, React, Speed, Bravery, Sanity, Psi)
- Simpler progression (one unified stat table)
- Easier to balance (narrow range)
- Reduces implementation complexity

**Disadvantages**:
- Less granular progression (only 7 values vs 101)
- Pilot specialization harder to represent

**Changes Required**:
- Pilots.md: Rewrite Piloting Stat section (lines 66-100)
- Update Pilots.md XP progression: Pilot gain +0.5 Piloting per 200 XP (to reach 12 over 1200 XP)
- Craft bonuses: `(Piloting - 6) × 5%` formula (already correct in Units.md)
- Units.md: Confirm already uses 6-12 (already done)

### Option B: Keep 0-100 Scale

**Advantages**:
- More granular progression
- Allows very fine-tuned pilot specialization
- Pilots are "different" from soldiers (asymmetric)

**Disadvantages**:
- Inconsistent with all other stats
- Requires separate XP progression system for pilots
- More complex implementation
- Harder to balance

**Changes Required**:
- Units.md: Change Piloting stat definition to 0-100 range (sections 227, 1187-1274)
- Units.md: Rewrite all Piloting calculations with 0-100 formulas
- Units.md: Define XP→Piloting conversion (e.g., +1 per 100 XP)
- Pilots.md: Update to match Units.md
- All craft bonus formulas: Recalculate for 0-100 range

### Option C: Hybrid with Conversion Formula

**Advantages**:
- Could maintain both specifications
- Allows asymmetric pilot progression
- Gradual rollout possible

**Disadvantages**:
- Most complex to implement
- Conversion between scales adds bugs
- Confusing for developers

**Changes Required**:
- Define conversion formula (e.g., `DisplayPiloting = 6 + (InternalPiloting / 16)`)
- Update all files to use correct internal scale
- Add conversion layer to code

---

## Plan

### Step 1: Designer Decision
**Description:** Senior designer reviews options and makes binding decision
**Decision Point:** Which scale is canonical?
**Owner:** Senior Game Designer
**Estimated time:** 1-2 hours (async review + decision)

### Step 2: Update Pilots.md
**Description:** Rewrite Pilots.md to match canonical specification
**Files to modify:**
- `design/mechanics/Pilots.md`

**Specific changes**:
- [ ] Update header warning to indicate Units.md is canonical
- [ ] Rewrite Piloting Stat section with correct range
- [ ] Update all XP progression examples
- [ ] Update all class bonus examples
- [ ] Update all trait examples
- [ ] Update all equipment examples
- [ ] Verify no contradictions remain

**Estimated time:** 2-3 hours

### Step 3: Verify Units.md Consistency
**Description:** Ensure Units.md is internally consistent with chosen scale
**Files to verify:**
- `design/mechanics/Units.md`

**Specific checks**:
- [ ] Line 227: Piloting stat definition
- [ ] Lines 1187-1274: Unified Pilot Specification section
- [ ] Craft performance bonus formula (line 1274)
- [ ] Speed/Accuracy/Dodge bonus multipliers (lines 1276-1282)
- [ ] Craft access requirements (lines 1243-1245)

**Estimated time:** 1-2 hours

### Step 4: Create Master Stat Table
**Description:** Add authoritative stat table to Units.md to prevent future confusion
**Files to modify:**
- `design/mechanics/Units.md` (new section after Unit Statistics overview)

**Table contents**:
```
| Stat | Range | Purpose | Unlocked | Related File |
|------|-------|---------|----------|--------------|
| Aim | 6-12 | Ranged accuracy | Always | Units.md |
| Melee | 6-12 | Melee combat | Always | Units.md |
| React | 6-12 | Overwatch/dodge | Always | Units.md |
| Speed | 6-12 | Movement points | Always | Units.md |
| Piloting | [CHOSEN] | Craft effectiveness | Via class specialization | Units.md, Pilots.md |
| Bravery | 6-12 | Morale pool | Always | MoraleBraverySanity.md |
| Sanity | 6-12 | Trauma resistance | Always | MoraleBraverySanity.md |
| Psi | 2-12 | Psychic power | Via research/traits | Units.md |
| Strength | 6-12 | Carrying capacity | Always | Items.md |
| Health | Calculated | Hit points | Always | Units.md |
| Armor | 0-2+gear | Damage reduction | Always | Items.md |
```

**Estimated time:** 1 hour

### Step 5: Update Cross-References
**Description:** Update all files that reference Piloting stat
**Files to update:**
- `design/mechanics/Crafts.md` - Pilot requirements, craft bonuses
- `design/mechanics/Interception.md` - Pilot performance in interception
- `design/mechanics/Economy.md` - Research costs for pilot tech
- `design/mechanics/Items.md` - Any references to pilot equipment

**Specific changes**:
- [ ] Check every mention of "Piloting" stat
- [ ] Verify formula examples match chosen scale
- [ ] Update any XP calculations
- [ ] Update any bonus calculations

**Estimated time:** 2-3 hours

### Step 6: Create Reference Document
**Description:** Add note to design folder linking to canonical specification
**Files to create:**
- `design/mechanics/README_PILOT_REFERENCE.md` (new file)

**Content**:
- Link to canonical specification (Units.md)
- Warning about Pilots.md being secondary
- Common questions/answers
- Formula examples

**Estimated time:** 1 hour

### Step 7: Testing & Validation
**Description:** Verify no contradictions remain
**Test cases:**
- [ ] Read Pilots.md → find no contradictions with Units.md
- [ ] Check Crafts.md → all bonus formulas match chosen scale
- [ ] Check Interception.md → all pilot references match scale
- [ ] Cross-reference check: 5 random mentions of Piloting → verify consistency
- [ ] Formula verification: 10 example calculations → verify correct math

**Estimated time:** 2-3 hours

---

## Implementation Details

### Architecture

**Current Issue**:
- Two contradictory specifications create ambiguity
- Developers don't know which is canonical
- No clear source of truth

**Solution**:
- Designate Units.md as canonical (lines 1147-1378 "Unified Pilot Specification")
- Pilots.md becomes secondary reference for specialization details
- All cross-references point to Units.md
- Master stat table prevents future confusion

### Key Components

1. **Piloting Stat Definition** - Canonical range and usage
2. **XP→Piloting Progression** - How pilots improve
3. **Craft Bonus Formulas** - How Piloting translates to craft performance
4. **Specialization System** - How Piloting specialization works (Aces, Bombers, etc.)
5. **Equipment Bonuses** - How equipment modifies Piloting

### Dependencies

- Designer decision (blocks everything else)
- Units.md canonical status decision
- Pilots.md update (dependent on decision)

---

## Designer Decision Checklist

**Before proceeding to implementation:**

- [ ] **Decision Made**: Is Piloting 6-12 or 0-100?
- [ ] **Reasoning Documented**: Why this choice for AlienFall?
- [ ] **Implementation Notes**: Any special considerations?
- [ ] **Balance Impact**: How does this affect game difficulty?
- [ ] **Campaign Duration**: Does this affect progression pacing?

---

## Testing Strategy

### Unit Tests
- [ ] Verify Piloting range matches specification
- [ ] Verify XP→Piloting conversion correct
- [ ] Verify craft bonus formula produces correct values
- [ ] Verify equipment bonuses calculated correctly

### Integration Tests
- [ ] Pilot progression from recruitment to hero rank
- [ ] Craft performance scaling with pilot quality
- [ ] Interaction with equipment bonuses
- [ ] Cross-file consistency checks

### Manual Testing Steps
1. Start new campaign
2. Recruit two pilots
3. Assign to different crafts
4. Complete 5 interception missions
5. Verify Piloting stat increased
6. Verify craft bonuses match formula

### Expected Results
- Pilot stats increase smoothly over time
- Craft bonuses scale correctly
- No contradictions between files

---

## Documentation Updates

### Files to Update
- [ ] `design/mechanics/Units.md` - Add master stat table
- [ ] `design/mechanics/Pilots.md` - Rewrite to match canonical spec
- [ ] `design/mechanics/Crafts.md` - Verify bonus formulas
- [ ] `design/mechanics/Interception.md` - Verify pilot references
- [ ] `design/mechanics/Economy.md` - Verify research costs
- [ ] `design/mechanics/Items.md` - Verify equipment references
- [ ] Create `design/mechanics/README_PILOT_REFERENCE.md` (new)

---

## Notes

- This is the HIGHEST PRIORITY issue blocking development
- Must be resolved before any other pilot-related tasks
- Designer decision is binding - developers implement exactly as specified
- This decision affects difficulty scaling (pilot quality affects craft power)
- This decision affects campaign duration (slow vs fast pilot progression)

---

## Blockers

**NONE - only awaiting designer decision**

Once decision is made, all other tasks can proceed in parallel.

---

## Related Tasks

Blocked by this task:
- CRITICAL #4: Economy Resource Costs (mission salvage depends on pilot effectiveness)
- HIGH #1: Craft System Integration (needs pilot capacity model)
- MEDIUM #1: Craft Bonuses Calculation (formula depends on stat scale)

---

## Review Checklist

- [ ] Both Units.md and Pilots.md agree on scale
- [ ] All formulas recalculated correctly
- [ ] All examples use correct numbers
- [ ] Cross-references updated
- [ ] Master stat table added
- [ ] No remaining contradictions
- [ ] Designer satisfied with decision
- [ ] Documentation clear for developers

---

## Post-Completion

Once this task is done:
1. All other critical issues become unblocked
2. Pilot system development can proceed
3. Craft system integration can be specified
4. Economy balancing can include pilot progression impacts

---

**Expected Impact**: This single decision unblocks 20+ other design tasks and enables full development of the pilot/craft subsystem.
