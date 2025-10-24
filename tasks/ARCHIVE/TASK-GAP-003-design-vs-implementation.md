# TASK-GAP-003: Compare Design Mechanics vs Engine Implementation

**Status:** TODO
**Priority:** MEDIUM
**Created:** October 23, 2025
**Estimated Time:** 10-12 hours
**Task Type:** Design Validation + Code Audit

---

## Overview

Compare game design specifications against engine code to verify:
1. Game mechanics implemented as designed
2. Balance parameters in sync with design
3. Systems behave according to specifications
4. Missing design implementations
5. Undesigned implemented features

---

## Scope: TWO SOURCES ONLY

**Source A:** `design/mechanics/` (design specifications)
**Source B:** `engine/` (implementation code)

**Systems to Compare:**
1. Units system
2. Battlescape combat
3. Geoscape strategy
4. Basescape facilities
5. Economy system
6. Research & tech tree
7. AI systems
8. Craft system
9. Items & equipment
10. Weapons & armor

---

## Detailed Verification Plan

### Phase 1: Units System (1-2 hours)

**Design File:** `design/mechanics/Units.md`
**Engine Files:** `engine/content/units/`, `engine/battlescape/systems/`

**Compare:**
- [ ] Unit classes: Are all designed classes in engine?
- [ ] Unit stats: Health, energy, morale - match design values?
- [ ] Experience system: Matches design progression?
- [ ] Abilities: All designed abilities implemented?
- [ ] Equipment slots: Capacity and types correct?
- [ ] Recovery mechanics: Match design specs?

**Discrepancies to Document:**
- What's designed but not implemented?
- What's implemented but not designed?
- What balance values differ?

---

### Phase 2: Battlescape Combat (2-3 hours)

**Design File:** `design/mechanics/Battlescape.md`
**Engine Files:** `engine/battlescape/systems/`, `engine/battlescape/battle/`

**Compare:**
- [ ] Turn structure: Sequential as designed?
- [ ] Action economy: AP costs match design?
- [ ] Line of sight: Algorithm matches spec?
- [ ] Cover system: Full/half/low/none as designed?
- [ ] Damage calculations: Formula matches?
- [ ] Status effects: All implemented?
- [ ] Terrain destruction: Rules as designed?

**Discrepancies to Document:**
- Missing mechanics?
- Different parameters?
- Incomplete implementations?

---

### Phase 3: Geoscape Strategy (1-2 hours)

**Design File:** `design/mechanics/Geoscape.md`
**Engine Files:** `engine/geoscape/`, `engine/geoscape/campaign_manager.lua`

**Compare:**
- [ ] World structure: 90×45 hex grid correct?
- [ ] Province system: Terrain types match?
- [ ] Campaign phases: All 4 phases implemented?
- [ ] Threat levels: Progression as designed?
- [ ] UFO spawning: Algorithm matches?
- [ ] Mission generation: Uses correct parameters?

**Discrepancies to Document:**
- Missing features?
- Unimplemented phases?
- Different threat scaling?

---

### Phase 4: Basescape Facilities (1-2 hours)

**Design File:** `design/mechanics/Basescape.md`
**Engine Files:** `engine/basescape/facilities/`, `engine/basescape/base_manager.lua`

**Compare:**
- [ ] Facility types: All 9+ types implemented?
- [ ] Grid layout: 5×5 with HQ center?
- [ ] Construction costs: Match design?
- [ ] Construction times: Correct?
- [ ] Adjacency bonuses: All combinations work?
- [ ] Capacity calculations: Formula correct?
- [ ] Service provision: All services implemented?

**Discrepancies to Document:**
- Missing facility types?
- Incorrect costs/times?
- Incomplete bonus system?

---

### Phase 5: Economy System (1-2 hours)

**Design File:** `design/mechanics/Economy.md`
**Engine Files:** `engine/economy/`, `engine/basescape/`

**Compare:**
- [ ] Resource types: Credits, materials, supplies?
- [ ] Manufacturing queue: Time calculations correct?
- [ ] Marketplace: Pricing algorithm matches?
- [ ] Supplier system: Works as designed?
- [ ] Budget system: Tracking complete?

**Discrepancies to Document:**
- Missing systems?
- Incorrect formulas?
- Budget calculation differences?

---

### Phase 6: Research & Tech Tree (1 hour)

**Design File:** `design/mechanics/` (Research component)
**Engine Files:** `engine/basescape/research/`

**Compare:**
- [ ] Tech tree structure: Matches design?
- [ ] Prerequisite chains: All correct?
- [ ] Unlock conditions: All implemented?
- [ ] Research costs: Match design?
- [ ] Facility integration: Labs contribute correctly?

**Discrepancies to Document:**
- Missing techs?
- Incorrect prerequisites?
- Wrong costs?

---

### Phase 7: AI Systems (1-2 hours)

**Design File:** `design/mechanics/AI_Systems.md`
**Engine Files:** `engine/ai/`, `engine/battlescape/ai/`

**Compare:**
- [ ] Behavior trees: All patterns supported?
- [ ] Decision-making: Threat assessment accurate?
- [ ] Squad coordination: Works as designed?
- [ ] Difficulty scaling: AI adapts correctly?
- [ ] Tactical behaviors: All implemented?

**Discrepancies to Document:**
- Missing behaviors?
- Incomplete difficulty scaling?
- Squad coordination gaps?

---

### Phase 8: Craft System (1 hour)

**Design File:** `design/mechanics/Crafts.md`
**Engine Files:** `engine/content/crafts/`, `engine/interception/`

**Compare:**
- [ ] Craft types: All variants implemented?
- [ ] Speed/range: Match design values?
- [ ] Equipment slots: Capacity correct?
- [ ] Fuel consumption: Formula matches?
- [ ] Pilot bonuses: All work correctly?

**Discrepancies to Document:**
- Missing craft types?
- Incorrect stats?
- Equipment differences?

---

## Deliverables

### Design-Implementation Gap Report
**File:** `docs/DESIGN_IMPLEMENTATION_VALIDATION.md`

Should contain:
- System-by-system comparison
- Design features implemented ✅
- Design features missing ❌
- Implemented features not in design ⚠️
- Balance parameter differences
- Priority list for corrections

### Corrective Action Tasks
For each gap:
- Create issue if implementation needs fixing
- Create task if design needs updating
- Create task if documentation needs updating

### Balance Parameter Audit
Document any differences in:
- Damage values
- Healing values
- Cost/time estimates
- Stat ranges
- Success rate calculations

---

## Success Criteria

✅ All 10 systems compared
✅ All design requirements verified
✅ Discrepancies documented with severity
✅ Corrective actions identified
✅ Report created

---

## Related Files

**Compare These:**
- Design: `design/mechanics/Units.md` ↔ Code: `engine/content/units/` + `engine/battlescape/systems/`
- Design: `design/mechanics/Battlescape.md` ↔ Code: `engine/battlescape/systems/` + `engine/battlescape/battle/`
- Design: `design/mechanics/Geoscape.md` ↔ Code: `engine/geoscape/`
- (... 7 more pairs)

**Reference Report:** `design/gaps/ENGINE_IMPLEMENTATION_GAPS.md` (Use for system status)

---

**Task ID:** TASK-GAP-003
**Assignee:** [Designer + Developer]
**Due:** November 6, 2025
**Complexity:** High (deep design validation)
