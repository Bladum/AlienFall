# Phase 2: Engine Alignment Fixes - Complete Roadmap

**Created:** October 21, 2025  
**Total Duration:** 26-36 hours  
**Target Completion:** 2-3 weeks  

---

## Overview

Phase 2 implements the critical engine alignment fixes identified in Phase 1 audit. Three parallel workstreams (2A/2B/2C) address the top 3 system gaps:
1. **Phase 2A** (10-11 hours): Battlescape combat mechanics
2. **Phase 2B** (6-8 hours): Finance and economy systems  
3. **Phase 2C** (10-15 hours): AI and strategic systems

---

## Phase 2 Structure

### 2A: Battlescape Combat Fixes

**Gap Closure:** LOS/Cover, Threat Assessment, Flanking
**Duration:** 10-11 hours
**Files:** `tasks/TODO/PHASE_2A_BATTLESCAPE_COMBAT_FIXES.md`

**Key Implementations:**
- Enhanced LOS/Cover system with visible indicators
- 4-factor threat assessment (damage, position, range, weapon)
- Flanking detection with damage modifiers (rear: 150%, side: 125%)
- Combat flow verification

**Success Metrics:**
- [ ] All LOS calculations accurate
- [ ] Threat scores 0-100 range, meaningful differences
- [ ] Flanking detected and applied correctly
- [ ] No console errors

**Execution Path:**
```
2A.1 (2-3h)  → Analyze & enhance LOS/Cover
2A.2 (2-3h)  → Enhance threat assessment  
2A.3 (2-3h)  → Implement flanking system
2A.4 (1-2h)  → Verify combat flow
TESTING (1h) → Manual verification + console check
```

---

### 2B: Finance System Fixes

**Gap Closure:** Personnel costs, Supplier pricing, Budget forecast, Finance reporting  
**Duration:** 6-8 hours
**Files:** `tasks/TODO/PHASE_2B_FINANCE_SYSTEM_FIXES.md`

**Key Implementations:**
- Role-based personnel salaries (soldier: 100, scientist/engineer: 150, commander: 300)
- Supplier pricing multipliers (hostile: 1.5x, friendly: 0.9x, allied: 0.8x)
- 6-month budget forecasting with what-if scenarios
- Monthly finance reports with historical tracking

**Success Metrics:**
- [ ] All salary calculations correct
- [ ] Relations affect prices properly
- [ ] Budget forecast accurate for 6 months
- [ ] Finance reports complete and detailed

**Execution Path:**
```
2B.1 (1-2h)  → Implement personnel cost system
2B.2 (1.5-2h)→ Implement supplier pricing
2B.3 (2-3h)  → Create budget forecasting UI
2B.4 (1-2h)  → Implement finance reporting
TESTING (1h) → Manual verification + console check
```

---

### 2C: AI Systems Enhancement

**Gap Closure:** Strategic planning, Unit coordination, Resource awareness, Threat assessment enhancements, Diplomatic AI  
**Duration:** 10-15 hours
**Files:** `tasks/TODO/PHASE_2C_AI_SYSTEMS_ENHANCEMENTS.md`

**Key Implementations:**
- Mission scoring (0-100 based on reward/risk/relations/strategic value)
- Multi-turn strategic planning (3-6 month horizon)
- Squad leaders with formation control (diamond, line, wedge, column)
- Unit roles (leader, heavy, medic, scout, support)
- Ammo/energy/budget resource awareness
- 4-factor threat assessment (damage, position, range, weapon)
- Diplomatic AI with country decisions

**Success Metrics:**
- [ ] Missions ranked with meaningful scores
- [ ] Squad formations working and responsive
- [ ] Unit roles assigned and behaviors executed
- [ ] Resource constraints enforced in AI decisions
- [ ] Diplomatic AI makes contextual decisions

**Execution Path:**
```
2C.1 (3-4h)  → Strategic planning system
2C.2 (3-4h)  → Unit coordination & squads
2C.3 (2-3h)  → Resource awareness
2C.4 (2-3h)  → Enhanced threat assessment
2C.5 (2-3h)  → Diplomatic AI
TESTING (2h) → Manual verification + console check
```

---

## Execution Strategy

### Option A: Sequential (Recommended for first implementation)
```
Week 1: Phase 2A (10-11h) + Phase 2B (6-8h) = 16-19 hours
Week 2: Phase 2C (10-15h) = 10-15 hours
Week 3: Phase 3 (Testing & Documentation) = 8-12 hours
```

**Advantages:**
- Each phase can be tested independently
- Earlier phases establish patterns for later ones
- Less cognitive load
- Clear validation points

**Timeline:** 3 weeks total

---

### Option B: Parallel (Aggressive timeline)
```
All three phases: 2A/2B/2C run in parallel
- 2A Focus: Combat mechanics (10-11h)
- 2B Focus: Finance systems (6-8h)
- 2C Focus: AI systems (10-15h)
```

**Advantages:**
- Faster overall completion
- Different developers can work different areas

**Challenges:**
- Requires careful coordination
- Testing more complex
- Integration challenges

**Timeline:** 1.5-2 weeks total

---

## Phase Dependencies

```
Phase 1 ✅ COMPLETE
  ↓
Phase 2A (Combat)     ← Can start immediately (no dependencies)
Phase 2B (Finance)    ← Can start immediately (independent)
Phase 2C (AI)         ← Can start immediately (mostly independent)
                        Except: 2A threat assessment can inform 2C threat calc
  ↓
Phase 3 (Testing)     ← Requires all Phase 2 complete
  ↓
Phase 4 (Documentation) ← Requires Phase 3 complete
```

---

## Integration Points

### 2A ↔ 2C: Threat Assessment
- Phase 2A implements basic threat calculation
- Phase 2C enhances with strategic context
- Shared: `threat_assessment.lua`

### 2B ↔ 2C: Budget Awareness
- Phase 2B implements budget forecasting
- Phase 2C uses budget data for AI decisions
- Shared: `funding_manager.lua`, `budget_forecast.lua`

### 2A ↔ 2B: No direct integration
- Combat system independent of finance
- Both use core systems

---

## Testing Strategy

### Phase 2A Testing
```bash
Run: lovec "engine"

Console should show:
✓ [LOS] Los calculations: X samples
✓ [Threat] Threat assessment: ready
✓ [Flanking] Flanking detection: ready
✓ [Combat] Combat flow: 3-turn test passed

Test scenarios:
- LOS: Can unit see target over wall?
- Cover: Damage reduced in cover?
- Flanking: Rear attack does 150% damage?
- Threat: Score 0-100? Priority correct?
```

### Phase 2B Testing
```bash
Run: lovec "engine"

Console should show:
✓ [Finance] Personnel costs calculated
✓ [Finance] Supplier pricing multipliers applied
✓ [Finance] Budget forecast: 6 months ahead
✓ [Finance] Monthly report generated

Test scenarios:
- Personnel: Soldier = 100, scientist = 150?
- Pricing: Allied supplier = 0.8x price?
- Forecast: Shows balance for 6 months?
- Report: Breakdown complete and accurate?
```

### Phase 2C Testing
```bash
Run: lovec "engine"

Console should show:
✓ [AI] Strategic planner ready
✓ [AI] Squad leaders assigned
✓ [AI] Formations ready
✓ [AI] Resource awareness active
✓ [AI] Diplomatic AI initialized

Test scenarios:
- Strategy: High-reward missions ranked first?
- Squads: Diamond formation positioning correct?
- Resources: Low ammo triggers conservation?
- Threat: 4 factors weighted correctly?
- Diplomacy: Allied country friendly? Hostile hostile?
```

### Integration Testing (Phase 3)
```bash
- Can AI make budget-aware decisions?
- Do squads use combat tactics correctly?
- Does threat assessment influence strategy?
- Do all systems run without errors?
```

---

## Files to Create

### Phase 2A (Battlescape Combat)
```
engine/battlescape/combat/
  ├── flanking_system.lua           [NEW]
  ├── threat_assessment_enhanced.lua [NEW or enhanced]
  └── combat_flow.lua               [NEW]

Documentation:
  tasks/TODO/PHASE_2A_BATTLESCAPE_COMBAT_FIXES.md ✅
```

### Phase 2B (Finance System)
```
engine/geoscape/systems/
  ├── personnel_system.lua          [NEW]
  ├── supplier_pricing_system.lua   [NEW]
  ├── budget_forecast.lua           [NEW]
  ├── finance_report.lua            [NEW]
  └── funding_manager.lua           [ENHANCE]

engine/ui/
  ├── budget_forecast_screen.lua    [NEW]
  └── finance_report_screen.lua     [NEW]

Documentation:
  tasks/TODO/PHASE_2B_FINANCE_SYSTEM_FIXES.md ✅
```

### Phase 2C (AI Systems)
```
engine/battlescape/ai/
  ├── strategic_planner.lua         [NEW]
  ├── unit_roles.lua                [NEW]
  ├── formations.lua                [NEW]
  ├── resource_awareness.lua        [NEW]
  ├── threat_assessment_enhanced.lua [SHARED with 2A]
  └── diplomatic_ai.lua             [NEW]

engine/geoscape/ai/
  ├── country_decisions.lua         [NEW]
  └── faction_strategy.lua          [NEW]

Documentation:
  tasks/TODO/PHASE_2C_AI_SYSTEMS_ENHANCEMENTS.md ✅
```

**Total: ~25 files to create/enhance**

---

## Documentation Updates

After Phase 2 completion, update:
- `wiki/API.md` - Add new system APIs
- `wiki/FAQ.md` - Update gameplay mechanics
- `wiki/DEVELOPMENT.md` - Update architecture
- `wiki/systems/` - Update individual system docs

---

## Quality Checklist

Each phase must have:
- ✅ Detailed implementation plan with steps
- ✅ Lua code examples for each major component
- ✅ Testing strategy with manual checklist
- ✅ Success criteria (clear pass/fail)
- ✅ Console verification method
- ✅ Time estimates with buffer
- ✅ Integration points documented

---

## Progress Tracking

### Phase 2A Status
- [x] Plan created ✅
- [ ] Step 1.1: Analyze LOS system
- [ ] Step 1.2: Enhance cover system
- [ ] Step 1.3: Implement flanking detection
- [ ] Step 1.4: Test and verify

**Est. Start:** After Phase 2 kickoff  
**Est. Complete:** 10-11 hours

### Phase 2B Status
- [x] Plan created ✅
- [ ] Step 1.1: Analyze personnel system
- [ ] Step 1.2: Implement role-based salaries
- [ ] Step 1.3: Track in budget
- [ ] Step 2.1: Create pricing system
- [ ] Step 2.2: Integrate marketplace
- [ ] Step 2.3: Test pricing
- [ ] Step 3.1: Create forecasting engine
- [ ] Step 3.2: Build forecast UI
- [ ] Step 4.1: Create report system
- [ ] Step 4.2: Add historical tracking

**Est. Start:** Parallel or after 2A  
**Est. Complete:** 6-8 hours

### Phase 2C Status
- [x] Plan created ✅
- [ ] Step 1.1: Mission scoring system
- [ ] Step 1.2: Resource impact analysis
- [ ] Step 1.3: Multi-turn planning
- [ ] Step 2.1: Squad leader role
- [ ] Step 2.2: Role-based behaviors
- [ ] Step 2.3: Squad formations
- [ ] Step 3.1: Ammo/energy management
- [ ] Step 3.2: Research/budget awareness
- [ ] Step 4.1: Multi-factor threat calc
- [ ] Step 5.1: Diplomatic AI

**Est. Start:** Parallel or after 2A  
**Est. Complete:** 10-15 hours

---

## Risk Assessment

### Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Combat changes break existing battles | High | Comprehensive testing, incremental changes |
| Finance system breaks economy balance | Medium | Test with multiple scenarios, verify math |
| AI changes cause infinite loops or crashes | High | Extensive console logging, unit testing |
| Integration issues between systems | High | Clear API documentation, integration tests |
| Time overruns on complex algorithms | Medium | Break down steps into smaller pieces, test early |

---

## Success Criteria for Phase 2

Phase 2 is complete when:

✅ **All 3 phases executed:**
- Phase 2A combat mechanics fully implemented
- Phase 2B finance systems fully implemented
- Phase 2C AI systems fully implemented

✅ **All systems tested:**
- Manual testing checklist passed
- Console verification shows no errors
- Integration tests passed

✅ **Code quality maintained:**
- Follow Code Standards (Lua best practices)
- Comprehensive comments and documentation
- Modular, maintainable code

✅ **No regressions:**
- Existing functionality unaffected
- All previous tests still pass
- Game runs without crashes

✅ **Documentation updated:**
- API.md updated with new systems
- FAQ.md updated with new mechanics
- Implementation documented for future devs

---

## Next Steps After Phase 2

### Phase 3: Comprehensive Testing (8-12 hours)
- Full integration testing
- Combat scenario testing
- Economy balance verification
- AI behavior observation
- Performance profiling

### Phase 4: Documentation Updates (4-6 hours)
- API documentation
- System architecture docs
- Gameplay mechanics docs
- Developer guide updates

### Post-Phase 4: Optional Enhancements
- Phase 3 enhancements (cosmetics, polish)
- Performance optimizations
- Additional AI improvements
- Community feedback incorporation

---

## Files Reference

**Master Plans:**
- `tasks/TODO/PHASE_2A_BATTLESCAPE_COMBAT_FIXES.md` - Combat implementation
- `tasks/TODO/PHASE_2B_FINANCE_SYSTEM_FIXES.md` - Finance implementation
- `tasks/TODO/PHASE_2C_AI_SYSTEMS_ENHANCEMENTS.md` - AI implementation
- `tasks/TODO/PHASE_2_ENGINE_ALIGNMENT_ROADMAP.md` - This file

**Phase 1 Reference:**
- `docs/ENGINE_DESIGN_ALIGNMENT_PHASE_1_AUDIT.md` - Gap analysis
- `docs/diagrams/` - Visual system documentation

**Game Documentation:**
- `wiki/API.md` - API reference
- `wiki/FAQ.md` - Game mechanics
- `wiki/systems/` - System specifications

---

## Timeline Summary

```
START: Oct 21, 2025 (Phase 2 planning complete)

Option A (Sequential):
├─ Week 1: 2A (10-11h) + 2B (6-8h) = 16-19 hours
├─ Week 2: 2C (10-15h) = 10-15 hours
├─ Week 3: Phase 3 + 4 (12-18h) = 12-18 hours
└─ COMPLETE: ~3 weeks

Option B (Parallel):
├─ Week 1: 2A/2B/2C parallel (~26-36 hours)
├─ Week 2: Phase 3 testing (8-12 hours)
└─ COMPLETE: ~1.5-2 weeks

LAUNCH: Ready for release after Phase 4 documentation
```

---

**Status:** ✅ Phase 2 fully planned and ready for execution

**Next Action:** Begin Phase 2A - Battlescape Combat Fixes (whenever ready to start implementation)
