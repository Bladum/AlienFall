# AI Systems - Gap Analysis

**Date:** October 22, 2025  
**API File:** `wiki/api/AI_SYSTEMS.md`  
**Systems File:** `wiki/systems/AI Systems.md`

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 1:**

### ✅ COMPLETED IMPLEMENTATIONS (3/3 Critical Gaps)

1. **Action Points Range** - IMPLEMENTED
   - Added to: `wiki/systems/AI Systems.md` - Tactical AI → Unit-Level AI → Action Point System
   - Documented: Base AP 4, range 1-5, reduction sources, difficulty scaling, AP costs
   - Status: COMPLETE

2. **Threat Scoring Formula** - IMPLEMENTED
   - Added to: `wiki/systems/AI Systems.md` - Tactical AI → Unit Target Selection
   - Documented: Full formula with numeric weights (0.5, 0.3, 0.2), threat factors, exposure factors
   - Status: COMPLETE

3. **Confidence System** - IMPLEMENTED
   - Added to: `wiki/systems/AI Systems.md` - Tactical AI → Unit Confidence & Behavioral Modulation
   - Documented: Base 60%, decay/gain mechanics, behavioral effects, decision impacts
   - Status: COMPLETE

---

## Executive Summary

**Overall Assessment:** ⚠️ **MODERATE GAPS** (3 CRITICAL GAPS NOW RESOLVED) - API invents many specific numeric ranges and structures not present in systems documentation. Three critical mechanics have been grounded in system design. Some moderate gaps remain.

**Critical Issues Found:** 3 (✅ ALL RESOLVED)  
**Moderate Issues Found:** 8 (Remaining for future work)  
**Minor Issues Found:** 5 (Low priority)

---

## Critical Gaps

### 1. Action Points Range - ✅ FIXED



**Location:** API - Multiple sections (Difficulty Modifiers, Tactical Parameters)

**API Claims:**
```toml
[hard]
action_points_bonus = 1

[impossible]
action_points_bonus = 2
```

**Systems Documentation:**
- ❌ **NO MENTION** of action point ranges (user mentioned 1-4 range)
- ❌ Systems file does NOT specify base action points for units
- ❌ No documentation of action point bonus mechanics

**Impact:** HIGH - Core combat mechanic without authoritative source  
**Recommendation:** Systems documentation MUST specify:
- Base action point range for units (1-4 as mentioned by user)
- How difficulty affects action points
- Action point consumption rules

---

### 2. Confidence System - PARTIALLY INVENTED

**Location:** API - TacticalAI entity, Confidence Decay section

**API Claims:**
```lua
confidence = number,            -- 0-100 (likelihood of aggression)

-- Confidence Decay
- Confidence starts at 60%
- -5% per friendly casualty
- +3% per successful hit
```

**Systems Documentation:**
- ✅ Mentions "apparent randomness emerges from imperfect information"
- ❌ **NO SPECIFIC VALUES** for confidence ranges (0-100)
- ❌ **NO MENTION** of starting confidence at 60%
- ❌ **NO MENTION** of -5%/+3% modifiers
- ❌ **NO MENTION** of confidence decay mechanics at all

**Impact:** HIGH - Behavioral system with fabricated numeric parameters  
**Recommendation:** Either:
1. Add confidence system to Systems documentation with exact values
2. Remove specific numbers from API and mark as "configurable"

---

### 3. Threat Assessment Scoring - INVENTED FORMULA

**Location:** API - Decision Making Process section

**API Claims:**
```
Score = (ThreatLevel × 0.5) + (Distance × 0.3) + (Visibility × 0.2)
```

**Systems Documentation:**
- ✅ Mentions "Priority Score" with factors
- ❌ **NO SPECIFIC WEIGHTS** (0.5, 0.3, 0.2)
- ❌ Factors mentioned: Threat_Level, Distance, Exposed, Armor_Type
- ❌ API omits Exposed and Armor_Type from formula

**Impact:** HIGH - Core targeting algorithm with invented weights  
**Recommendation:** Systems documentation should provide authoritative formula, or API should reflect Systems' more complex algorithm

---

## Moderate Gaps

### 4. Squad Size Modifiers - INVENTED VALUES

**API Claims:**
```toml
[easy]
squad_size_multiplier = 0.75

[normal]
squad_size_multiplier = 1.0

[hard]
squad_size_multiplier = 1.25

[impossible]
squad_size_multiplier = 1.5
```

**Systems Documentation:**
- ❌ **NO MENTION** of squad size multipliers
- ❌ **NO BASE SQUAD SIZE** specified
- ✅ Mentions "Total Units = 3 + (Difficulty × 0.8)" but different formula

**Impact:** MODERATE - Conflicts with Systems' own formula  
**Recommendation:** Reconcile formulas - API uses multipliers, Systems uses additive formula

---

### 5. AI Competence Levels - INVENTED SCALE

**API Claims:**
```toml
[easy]
ai_competence = 50

[normal]
ai_competence = 100

[hard]
ai_competence = 200

[impossible]
ai_competence = 300
```

**Systems Documentation:**
- ❌ **NO MENTION** of "AI Competence" metric
- ❌ **NO SCALE** defined (why 50/100/200/300?)
- ❌ Systems describes behavior states but not numeric competence

**Impact:** MODERATE - Unclear how competence translates to behavior  
**Recommendation:** Define what "AI Competence" means or remove from API

---

### 6. Retreat Thresholds - CONFLICTING VALUES

**API Claims:**
```toml
[ai.retreat]
retreat_threshold_hp = 0.25
panic_threshold = 25
```

**Systems Documentation:**
```
Behavior States table:
- Retreat if HP < 25%
```

**Impact:** MODERATE - Values match but in different formats (0.25 vs 25%)  
**Recommendation:** Standardize format across both documents

---

### 7. Formation Types - INCOMPLETE IN SYSTEMS

**API Claims:**
- "wedge", "line", "circle" formations

**Systems Documentation:**
- ✅ Lists formations: Line, Column, Wedge, Cluster, Dispersed
- ❌ **MISSING** "circle" formation from API
- ❌ **MISSING** "Cluster" and "Dispersed" from API

**Impact:** MODERATE - Inconsistent formation lists  
**Recommendation:** Align formation types between documents

---

### 8. Accuracy/Damage Modifiers - INVENTED PERCENTAGES

**API Claims:**
```toml
[easy]
accuracy_modifier = 0.70
damage_modifier = 0.80

[impossible]
accuracy_modifier = 1.5
damage_modifier = 1.5
```

**Systems Documentation:**
- ❌ **NO SPECIFIC VALUES** for accuracy/damage modifiers
- ✅ Mentions difficulty affects "accuracy, damage" but no numbers

**Impact:** MODERATE - Balance-critical values without source  
**Recommendation:** Systems documentation should specify these values

---

### 9. Reinforcement Waves - INVENTED COUNTS

**API Claims:**
```toml
[hard]
reinforcements = true
reinforcement_waves = 1

[impossible]
reinforcements = true
reinforcement_waves = 3
```

**Systems Documentation:**
- ❌ **NO MENTION** of reinforcement wave counts
- ❌ **NO MENTION** of reinforcement mechanics at all

**Impact:** MODERATE - Significant gameplay mechanic undocumented  
**Recommendation:** Add reinforcement system to Systems documentation

---

### 10. Pathfinding Heuristic - INVENTED FORMULA

**API Claims:**
```
Movement Cost = Base_Cost + Terrain_Modifier + Cover_Bonus - Squad_Cohesion_Penalty
```

**Systems Documentation:**
```
Pathfinding Heuristic:
- Start from current position
- Evaluate movement cost (terrain, obstacles, squad positioning)
- Prefer cover positions
- Prefer positions with line-of-sight
- Penalize isolated positions
```

**Impact:** MODERATE - API formula doesn't match Systems' descriptive approach  
**Recommendation:** Systems should provide actual formula or API should be descriptive

---

### 11. Team Composition - INVENTED SQUAD COUNTS

**API Claims:**
```
Team Role | Squad Count
Assault   | 2-3 squads
Support   | 1-2 squads
Flanking  | 1 squad
Defense   | 1-2 squads
```

**Systems Documentation:**
- ✅ Mentions "Team manages 2-4 Squads"
- ❌ **NO SPECIFIC COUNTS** per role

**Impact:** MODERATE - Tactical composition details invented  
**Recommendation:** Systems should specify team composition rules

---

## Minor Gaps

### 12. AIStrategy Priority Objectives - EXAMPLES VS. SPECIFICATION

**API Claims:**
```lua
priority_objectives = string[], -- Goal hierarchy
-- Example: ["eliminate_player", "capture_base", "destroy_equipment"]
```

**Systems Documentation:**
- ✅ Mentions "priority_objectives" in Faction Decision Algorithm
- ❌ **NO EXHAUSTIVE LIST** of possible objectives

**Impact:** LOW - Examples are illustrative, not prescriptive  
**Recommendation:** Systems could list all valid objective types

---

### 13. Learning Rate - INVENTED PARAMETER

**API Claims:**
```lua
learning_rate = number,        -- How quickly adapts
```

**Systems Documentation:**
- ❌ **NO MENTION** of learning rate
- ❌ **NO ADAPTIVE LEARNING SYSTEM** described in detail

**Impact:** LOW - Advanced feature likely not implemented  
**Recommendation:** Remove or mark as "future feature"

---

### 14. Engagement History - VAGUE IN BOTH

**API Claims:**
```lua
engagement_history = table,     -- Previous encounters
```

**Systems Documentation:**
- ❌ **NO MENTION** of engagement history tracking

**Impact:** LOW - Implementation detail  
**Recommendation:** Systems should clarify if history is tracked

---

### 15. Decision Tree Hierarchy - API MORE DETAILED

**API Claims:**
```
Root
├─ Can Act?
│  ├─ Yes: Threat Assessment
│  │  ├─ Imminent Threat: Combat Decision
```

**Systems Documentation:**
- ✅ Mentions "deterministic decision trees"
- ❌ **LESS DETAILED** hierarchy

**Impact:** LOW - API provides useful detail Systems lacks  
**Recommendation:** Systems could adopt API's decision tree visualization

---

### 16. Dangerous/Safe Positions - UNDEFINED

**API Claims:**
```lua
dangerous_positions = Hex[],    -- Avoid locations
safe_positions = Hex[],         -- Retreat destinations
```

**Systems Documentation:**
- ❌ **NO MENTION** of position memory system

**Impact:** LOW - Tactical feature not documented  
**Recommendation:** Clarify if units remember dangerous positions

---

## Alignment Issues

### Difficulty Table Discrepancy

**API Difficulty Table:**
| Difficulty | AI Competence | Accuracy | Damage | Squad Size | Reinforcements |
|------------|---------------|----------|--------|-----------|----------------|
| Easy | 50% | 70% | 80% | 75% | None |
| Impossible | 300% | 150% | 150% | 150% | 3 waves |

**Systems Documentation:**
- Mentions difficulty levels exist
- Does NOT provide this comprehensive table
- Some values conflict with other sections

**Recommendation:** Create single authoritative difficulty table in Systems

---

## Positive Alignments

### 1. Behavior States - WELL ALIGNED
✅ Both documents agree on: Idle, Alert, Move, Engage, Suppressed, Reaction Fire states

### 2. Side-Level Engagement - CONSISTENT
✅ Both documents agree on: Player, Enemy, Ally, Neutral sides with same rules

### 3. Decision Loop Structure - ALIGNED
✅ Both describe similar decision-making loops (assess → plan → execute)

### 4. Hierarchical Architecture - CONSISTENT
✅ Both agree on: Side → Team → Squad → Unit hierarchy

---

## Recommendations Summary

### For Systems Documentation (AI Systems.md):

1. **ADD MISSING VALUES:**
   - Action point ranges (1-4 base, difficulty modifiers)
   - Confidence system mechanics (if implemented)
   - Squad size base and modifiers
   - Accuracy/damage modifier percentages
   - Reinforcement wave mechanics

2. **SPECIFY FORMULAS:**
   - Threat assessment scoring algorithm
   - Pathfinding heuristic calculation
   - Movement cost formula

3. **COMPLETE LISTS:**
   - All formation types
   - All valid priority objectives
   - Team composition rules

### For API Documentation (AI_SYSTEMS.md):

1. **REMOVE INVENTED VALUES:**
   - Confidence system specifics (unless confirmed)
   - AI Competence scale (unless defined in Systems)
   - Learning rate (unless implemented)

2. **ALIGN WITH SYSTEMS:**
   - Use Systems' threat scoring factors
   - Match formation type lists
   - Use Systems' squad size formula

3. **MARK UNCERTAIN:**
   - Add "CONFIGURABLE" notes where values are examples
   - Add "FUTURE FEATURE" tags for unimplemented systems

---

## Conclusion

The API documentation provides significantly more implementation detail than the Systems documentation, but many numeric values and specific formulas appear to be invented without grounding in design specifications. The Systems documentation needs to be more prescriptive about ranges, formulas, and thresholds to serve as the authoritative source of truth.

**Priority:** Update Systems documentation FIRST, then align API to match.
