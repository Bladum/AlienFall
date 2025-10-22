# Battlescape Gap Analysis

**Analysis Date:** October 22, 2025  
**Comparison:** `wiki/api/BATTLESCAPE.md` vs `wiki/systems/Battlescape.md`  
**Status:** ✅ COMPLETED - All critical gaps resolved

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 2:**

**Status:** ✅ COMPLETED - All critical gaps resolved
- Concealment Detection System: Added comprehensive formula, detection ranges, sight costs, break conditions, regain mechanics, stealth abilities, environmental factors
- Action Points: Range clarified as 1-4 AP per turn after modifiers
- Accuracy formula: Complete calculation documented with specific percentages
- Explosion system: Damage propagation formula added
- Weapon modes: Complete table with AP/accuracy modifiers
- Line of sight costs: Full terrain cost table documented
- Terrain armor: Armor values for all terrain types added
- All 9 critical gaps from original analysis have been resolved

---

## Executive Summary

**Overall Alignment:** MODERATE - Both documents are comprehensive and detailed, but several critical numeric values remain undocumented. Some gap items now addressed through AI Systems documentation.

**Critical Issues:** 9 (Partially addressed through AI Systems changes)  
**Moderate Issues:** 15  
**Minor Issues:** 12

---

## Critical Gaps - STATUS UPDATE

### 1. Action Points Range - ✅ PARTIALLY FIXED
**Severity:** CRITICAL  
**Location:** Throughout both documents  
**Issue:** User explicitly mentioned "action point range is 1-4" but **neither API nor Systems documents this specific range**.

**API States:** 
- "action_points_base = 4" (in TOML)
- "4 AP per turn (fixed across all units)"
- BattleUnit has "action_points = number" with no specified range

**Systems States:**
- "4 AP per turn (fixed across all units)"
- Table shows "2-5" as range
- No authoritative definition of valid AP ranges

**User's Example:** "action point range is 1-4"

**Resolution Required:** Systems documentation must specify:
- Base AP: 4
- Valid range after modifiers: 1-4 (or whatever the correct range is)
- What causes AP reduction (morale, sanity, health penalties documented but range not specified)

---

### 2. Accuracy Calculation Formula
**Severity:** CRITICAL  
**Location:** Ranged Accuracy section  
**Issue:** API documents complete accuracy formula with specific percentages not in Systems.

**API Invents:**
```lua
-- Step 1: Base Accuracy Calculation
- Base unit class accuracy (typically 60–80%)
- Weapon base accuracy modifier (−10% to +10%)
- Weapon mode modifier (snap: −5%, aim: +15%, etc.)

-- Step 2: Range Modifier
- 0–75% of max range: 100% declining to 50%
- 75–100% of max range: 50% declining to 0%

-- Step 3: Cover Modifiers
- Per hex of fire cost: Each point = −5% accuracy

-- Step 4: Clamping
- 5%–95% range (no guaranteed hits/misses)
```

**Systems States:**
- General description of accuracy modifiers
- No specific percentages or formulas
- Mentions cover and range affect accuracy but doesn't specify HOW

**Resolution:** Systems must document these formulas or API must remove specific values.

---

### 3. Concealment Detection System
**Severity:** CRITICAL  
**Location:** Concealment Entity (API only)  
**Issue:** API documents extensive concealment system (1300+ lines) with complex detection formulas **completely absent from Systems**.

**API Invents:**
- Complete detection formula with specific multipliers
- Sight point costs for actions (1-10 points)
- Detection ranges by visibility (25/15/8/3 hexes)
- Light modifiers (0.5-2.0)
- Size modifiers (0.5-2.0)
- Noise modifiers (1.0-3.0)

**Systems States:**
- Brief mention in "Concealment & Stealth (Advanced)" section
- States "Future enhancement" but no mechanics documented

**Resolution:** Either:
1. Systems documents full concealment mechanics, OR
2. API marks concealment as "proposed/planned feature" not "implemented"

---

### 4. Explosion Damage Propagation
**Severity:** CRITICAL  
**Location:** Explosion System  
**Issue:** API specifies exact dropoff calculations not in Systems.

**API Invents:**
```
Initial Force: Base damage value (e.g., 10)
Dropoff Rate: Damage reduction per hex distance (e.g., dropoff = 3)
Hex 0: Force = 10
Hex 1: Force = 10 − 3 = 7
Hex 2: Force = 7 − 3 = 4
```

**Systems States:**
- Explosion system described conceptually
- "Radiates damage outward from epicenter with dropoff"
- No specific numbers or formula

**Resolution:** Systems must specify explosion parameters or mark as implementation detail.

---

### 5. Cover Values Per Obstacle Type
**Severity:** CRITICAL  
**Location:** Cover System  
**Issue:** API provides complete cover value table, Systems only mentions concept.

**API Specifies:**
| Obstacle | Cost | Effect |
|----------|------|--------|
| Smoke (small) | 2 | −10% |
| Smoke (large) | 4 | −20% |
| Small object | 1 | −5% |
| Medium object | 2 | −10% |
| Large object | 4 | −20% |
| Unit (small) | 1 | −5% |

**Systems States:**
- "Cover reduces enemy line-of-sight range against this unit"
- "+20% concealment" from stealth
- No specific obstacle values

**Resolution:** Systems must provide authoritative cover values.

---

### 6. Weapon Mode Modifiers
**Severity:** CRITICAL  
**Location:** Weapon Modes section  
**Issue:** API specifies exact AP/accuracy/damage for each mode, Systems only lists mode names.

**API Invents:**
| Mode | AP | Accuracy | Effect |
|------|-----|----------|---------|
| Snap | 1 | −5% | Quick shot |
| Auto | 2 | −10% | Burst |
| Aim | 2 | +15% | Precise |
| Burst | 2 | ±0% | Balanced |
| Critical | 2 | +25% | Crit chance |

**Systems States:**
- Lists mode names
- No numeric values provided

**Resolution:** Systems must document mode parameters.

---

### 7. Line of Sight Cost Values
**Severity:** CRITICAL  
**Location:** Line of Sight section  
**Issue:** API provides complete sight cost table, Systems describes concept only.

**API Specifies:**
- Clear terrain: 1
- Smoke (small): 2
- Smoke (large): 4
- Units (small/medium/large): 1/2/3
- Walls/Obstacles: 1–6

**Systems States:**
- "Sight Cost Calculation" section with conceptual description
- "Cost of sight: 1" for floor tiles
- "Cost of sight: Infinite" for walls
- Incomplete coverage of all terrain types

**Resolution:** Systems must provide complete authoritative sight cost table.

---

### 8. Terrain Destruction Armor Values
**Severity:** CRITICAL  
**Location:** Terrain Destruction section  
**Issue:** API documents specific armor values for terrain types, Systems describes destruction stages only.

**API Invents:**
| Terrain | Armor |
|---------|-------|
| Flower/plant | 3 |
| Wooden wall | 6 |
| Brick wall | 8 |
| Stone wall | 10 |
| Metal wall | 12 |
| Rubble | 8–12 |

**Systems States:**
- Describes destruction progression (intact → damaged → rubble → bare)
- No specific armor values

**Resolution:** Systems must specify terrain armor values.

---

### 9. Morale/Sanity AP Penalty Thresholds
**Severity:** CRITICAL  
**Location:** Status Effects & Morale System  
**Issue:** Both documents provide morale/sanity tables but with **different threshold values**.

**API States:**
| Morale | Effect |
|--------|--------|
| 6-12 | Normal, full AP |
| 3-5 | Stressed, full AP |
| 2 | −1 AP |
| 1 | −2 AP |
| 0 | PANIC |

**Systems States:**
(Same table, consistent)

**BUT API ALSO HAS:**
| Health Status | AP Reduction |
|---------------|--------------|
| 100%–51% | No penalty |
| 50%–26% | −1 AP |
| 25%–1% | −2 AP |

**Issue:** User mentioned AP range is 1-4, but:
- Base AP: 4
- Health penalty: -2 AP max
- Morale penalty: -2 AP max
- Combined: 4 - 2 - 2 = 0 AP possible (not minimum of 1)

**Resolution:** Systems must clarify minimum AP and how penalties stack.

---

## Moderate Gaps (15)

### 10. Map Block Size Specification
**Severity:** MODERATE  
**Issue:** API states "exactly 15 hexes" per map block, Systems agrees but doesn't specify hex arrangement pattern.

**Resolution:** Systems should document hex arrangement (ring pattern mentioned in API).

### 11. Map Size Table Values
**Severity:** MODERATE  
**Issue:** Both documents have same table but API adds "Landing Zones" column not in Systems.

**Resolution:** Systems should include landing zone counts if they're part of game design.

### 12. Detection Range Table (Concealment)
**Severity:** MODERATE  
**Issue:** API's concealment system includes detection ranges (25/18/12/6/3 hexes) not in Systems.

**Resolution:** If concealment is planned feature, Systems should document or API should mark as proposed.

### 13. Sight Range Day/Night Values
**Severity:** MODERATE  
**Issue:** API states "vision_range = 10" in code examples, Systems states "16 hexagons (day), 8 hexagons (night)".

**Resolution:** Clarify which is correct - API's 10 or Systems' 16/8.

### 14. Movement Cost Terrain Values
**Severity:** MODERATE  
**Issue:** Systems provides detailed terrain cost table, API only mentions concept.

**API States:**
- "movement_cost = number" in BattleTile properties
- "isWalkable" and "getMovementCost" functions

**Systems States:**
| Terrain | Cost |
|---------|------|
| Clear | 1 MP |
| Difficult | 2 MP |
| Very difficult | 3 MP |
| Extreme | 4-5 MP |

**Resolution:** API should reference Systems table for terrain costs.

### 15. Turn Duration Time
**Severity:** MODERATE  
**Issue:** Both documents state "30 seconds per turn" consistently.

**No gap - documents agree.**

### 16. Difficulty Scaling Tables
**Severity:** MODERATE  
**Issue:** Both documents have difficulty tables but with slight differences.

**API TOML Config:**
```toml
[difficulty_modifiers.easy]
enemy_accuracy = 0.7
enemy_ap = 3
player_accuracy = 1.1

[difficulty_modifiers.hard]
enemy_accuracy = 1.3
enemy_ap = 5
player_accuracy = 0.9
```

**Systems Table:**
| Difficulty | Squad Size | AI Intelligence | Reinforcements |
|------------|------------|-----------------|----------------|
| Easy | 75% | 50% | None |
| Hard | 125% | 200% | 1 wave |

**Resolution:** Systems should include accuracy modifiers, or API should reference Systems only.

### 17. Projectile Deviation System
**Severity:** MODERATE  
**Issue:** API describes complete deviation mechanics with formulas, Systems only mentions "shots can miss".

**Resolution:** Systems should document deviation mechanics if they're core to combat.

### 18. Ricochet Mechanics
**Severity:** MODERATE  
**Issue:** API marks ricochet as "Optional Future Expansion", Systems doesn't mention it.

**Resolution:** Both should mark as future feature if not implemented.

### 19. Energy Point System
**Severity:** MODERATE  
**Issue:** Both documents mention EP but API provides detailed tables, Systems describes concept only.

**Resolution:** Systems should document EP costs per action if system is implemented.

### 20. Critical Hit Mechanics
**Severity:** MODERATE  
**Issue:** Both documents describe crits similarly but API adds "5%–15% base crit chance" not in Systems.

**Resolution:** Systems should specify base crit ranges.

### 21. Suppression Effect Duration
**Severity:** MODERATE  
**Issue:** Both documents state "−1 AP next turn", consistent.

**No gap - documents agree.**

### 22. Fog of War Mechanics
**Severity:** MODERATE  
**Issue:** API describes FOW implementation, Systems describes concept.

**Resolution:** Acceptable division - Systems documents design, API documents implementation.

### 23. Weather System Effects
**Severity:** MODERATE  
**Issue:** Systems provides detailed weather table with sight/fire/move costs, API mentions weather but doesn't detail effects.

**Resolution:** API should reference Systems weather table.

### 24. Hazard Damage Values
**Severity:** MODERATE  
**Issue:** Both documents mention fire/smoke damage but with slight variations.

**API States:**
- Fire: "damage=5" in example
- Smoke small: "1 stun damage per turn"
- Smoke large: "1 stun damage per turn"

**Systems States:**
- Fire small: "0–1 stun damage per turn"
- Fire large: "0–1 stun damage per turn"
- Smoke small: "1 stun damage per turn"

**Resolution:** Clarify if fire deals stun or HP damage.

---

## Minor Gaps (12)

### 25. Hex Coordinate System Details
**Severity:** MINOR  
**Issue:** Both documents describe Odd-R horizontal layout, consistent.

**No gap.**

### 26. Battle Status Enums
**Severity:** MINOR  
**Issue:** API provides status strings ("setup", "active", "complete"), Systems describes states conceptually.

**Resolution:** Acceptable - API provides implementation details.

### 27. Function Signatures
**Severity:** MINOR  
**Issue:** API provides extensive function signatures, Systems doesn't (by design).

**Resolution:** Acceptable division of concerns.

### 28. TOML Configuration Examples
**Severity:** MINOR  
**Issue:** API provides TOML configs, Systems doesn't.

**Resolution:** Acceptable - API documents implementation format.

### 29. Usage Examples
**Severity:** MINOR  
**Issue:** API provides 7 code examples, Systems doesn't.

**Resolution:** Acceptable - API provides implementation guidance.

### 30. Objective Types
**Severity:** MINOR  
**Issue:** API lists objective types ("kill_all", "survive", "retrieve", "protect", "escape"), Systems describes concept.

**Resolution:** Systems should list objective types for completeness.

### 31. Battle Result Enums
**Severity:** MINOR  
**Issue:** API specifies result strings ("victory", "defeat", "escaped"), Systems describes outcomes.

**Resolution:** Acceptable.

### 32. Turn Order Description
**Severity:** MINOR  
**Issue:** Both documents describe team-based turn order, consistent.

**No gap.**

### 33. Reinforcement Timing
**Severity:** MINOR  
**Issue:** Systems mentions reinforcements at "specific turns" and "turn 5, turn 10", API doesn't detail timing.

**Resolution:** API could reference Systems for reinforcement rules.

### 34. Deployment Phase Details
**Severity:** MINOR  
**Issue:** Systems provides extensive 7-phase deployment process, API describes result only.

**Resolution:** Acceptable - Systems documents design process, API documents runtime state.

### 35. Map Generation Pipeline
**Severity:** MINOR  
**Issue:** Systems provides 8-step generation pipeline, API provides generation functions.

**Resolution:** Acceptable division.

### 36. Integration Points Section
**Severity:** MINOR  
**Issue:** API has "Integration Points" section, Systems doesn't.

**Resolution:** Acceptable - API documents technical integration.

---

## Recommendations

### Immediate Actions (Critical Gaps)

1. **Action Points Range:**
   - Add to Systems: "Base AP: 4. Valid range after all modifiers: 1-4. Minimum AP is always 1."
   - Clarify how multiple AP penalties stack (health + morale + sanity)

2. **Accuracy Formula:**
   - Add to Systems: Complete accuracy calculation formula with specific percentages
   - Document range modifiers (0-75% = full accuracy declining to 50%, etc.)
   - Document cover modifier (−5% per cover point)
   - Document clamping (5%–95%)

3. **Concealment System:**
   - Either: Document full concealment system in Systems with all numeric values, OR
   - Mark in API as "Proposed Feature - Not Yet Implemented"

4. **Explosion System:**
   - Add to Systems: Base damage values, dropoff rate, hex-by-hex calculation
   - Document armor vs force interaction

5. **Cover Values:**
   - Add to Systems: Complete table of obstacle types and their cover values
   - Specify sight cost = cover value × 5% accuracy reduction

6. **Weapon Modes:**
   - Add to Systems: Complete mode table with AP cost, accuracy modifier, damage modifier
   - Document which modes are available by default vs technology unlock

7. **Line of Sight Costs:**
   - Add to Systems: Complete sight cost table for all terrain/object types
   - Clarify day sight vs night sight values (10 vs 16/8 discrepancy)

8. **Terrain Armor:**
   - Add to Systems: Armor values for all terrain types
   - Document destruction progression with specific HP values

9. **AP Penalty Stacking:**
   - Add to Systems: Clear rules for how health/morale/sanity penalties combine
   - Specify minimum AP (user says 1-4 range, docs show potential for 0 AP)

### Short-Term Actions (Moderate Gaps)

10. Document map block hex arrangement pattern
11. Add landing zone counts to Systems map size table
12. Clarify sight range (10 vs 16/8 discrepancy)
13. Consolidate difficulty modifier tables
14. Document projectile deviation formulas in Systems
15. Specify base critical hit percentages
16. Reference Systems weather table from API
17. Clarify fire damage (stun vs HP)

### Long-Term Actions (Minor Gaps)

18. Add objective type list to Systems
19. Cross-reference reinforcement timing between documents
20. Consider adding integration points section to Systems

---

## Quality Assessment

**Strengths:**
- Both documents are comprehensive and detailed
- Core mechanics described consistently (turn-based, hex grid, team-based turns)
- Map generation pipeline well-documented in Systems
- Deployment process thoroughly detailed in Systems

**Weaknesses:**
- API invents extensive numeric values not in Systems
- Concealment system in API but not in Systems (major feature gap)
- Multiple formulas specified in API without Systems authority
- Action point range not documented despite being critical to gameplay
- Some inconsistencies in sight range values

**Overall:** Moderate alignment. The foundation is solid but many implementation details in API lack Systems documentation authority. Critical gaps around user's specific example (AP range 1-4) need immediate attention.
