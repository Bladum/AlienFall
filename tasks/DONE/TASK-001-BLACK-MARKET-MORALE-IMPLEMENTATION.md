# Task: Black Market & Morale/Sanity System Implementation

**Status:** IN_PROGRESS  
**Priority:** High  
**Created:** 2025-10-28  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement missing Engine, Mods, and Tests features for:
1. **Morale/Bravery/Sanity System** - Complete psychological warfare mechanics
2. **Black Market System** - Mission generation, event purchasing, corpse trading, unit/craft recruitment

Design and API documentation is 100% complete. Need to:
- Update 3 existing engine files (~750 lines)
- Create 5 new engine files (~800 lines)
- Create 5 new test files (~850 lines)
- Update 2 existing test files (~80 lines)
- Create TOML configuration files
- Update architecture diagrams

---

## Purpose

Align engine implementation and test coverage with comprehensive design specifications in:
- `design/mechanics/MoraleBraverySanity.md`
- `design/mechanics/BlackMarket.md`
- `api/UNITS.md` (morale/sanity functions)
- `api/ECONOMY.md` (black market functions)

---

## Requirements

### Functional Requirements
- [x] Design documentation complete (MoraleBraverySanity.md, BlackMarket.md)
- [x] API documentation complete (UNITS.md, ECONOMY.md)
- [ ] Engine implementation matches design
- [ ] Test coverage ≥80% for new features
- [ ] TOML configuration for all content
- [ ] Architecture diagrams updated
- [ ] Game runs without errors (Exit Code 0)

### Technical Requirements
- [ ] All morale event functions implemented (8 functions)
- [ ] All morale action functions implemented (3 functions)
- [ ] All sanity recovery functions implemented (4 functions)
- [ ] Black market services implemented (5 categories)
- [ ] Corpse trading system implemented
- [ ] Temple facility implemented
- [ ] Unit tests pass 100%
- [ ] Integration tests pass 100%

### Acceptance Criteria
- [ ] All engine files created/updated
- [ ] All test files created/updated
- [ ] All TOML files created
- [ ] Architecture diagrams updated
- [ ] `lovec "engine"` exits with code 0
- [ ] All tests pass: `lovec "tests2/runners" run_all`
- [ ] Cross-layer consistency verified

---

## Plan

### Phase 1: Architecture Updates (30 min)
Update architecture diagrams to reflect psychological and economy systems integration.

**Files to modify:**
- `architecture/systems/economy_system.md` (add black market)
- `architecture/systems/combat_system.md` (add morale/sanity)
- Create `architecture/systems/psychological_system.md`

**Estimated time:** 30 minutes

---

### Phase 2: Engine - Morale/Sanity System (4 hours)

#### Step 2.1: Update morale_system.lua (~200 lines)
**Files to modify:**
- `engine/battlescape/systems/morale_system.lua`

**Add functions:**
- Morale event functions (8): onAllyKilled, onTakeDamage, onCriticalHit, onFlanked, onOutnumbered, onCommanderKilled, onNewAlien, onNightMission
- Action functions (3): restAction, leaderRally, leaderAura
- Sanity post-mission (1): applyMissionTrauma
- Sanity recovery (4): weeklyBaseRecovery, weeklyTempleRecovery, medicalTreatment, leaveVacation
- Penalty calculations (3): getMoraleAccuracyPenalty, getSanityAccuracyPenalty, canDeploy
- State queries (2): getMoraleStatus, getSanityStatus

**Estimated time:** 2 hours

#### Step 2.2: Create morale_actions.lua (~150 lines)
**Files to create:**
- `engine/battlescape/morale_actions.lua`

**Implement:**
- Rest action (2 AP → +1 morale)
- Leader rally (4 AP → +2 morale to target)
- Leader aura (passive +1 morale/turn within 8 hexes)
- Integration with battle action system

**Estimated time:** 1.5 hours

#### Step 2.3: Update unit_recovery_progression.lua (~50 lines)
**Files to modify:**
- `engine/geoscape/processing/unit_recovery_progression.lua`

**Update:**
- Sanity recovery rates (+1/week base, +2/week with Temple)
- Temple facility detection
- Medical treatment option
- Leave/vacation option

**Estimated time:** 30 minutes

---

### Phase 3: Engine - Black Market Expansion (6 hours)

#### Step 3.1: Update black_market_system.lua (~500 lines)
**Files to modify:**
- `engine/economy/marketplace/black_market_system.lua`

**Add systems:**
- Mission generation (7 types)
- Event purchasing (8 types)
- Unit recruitment (5 types)
- Craft purchasing (4 types)
- Corpse trading integration
- Access tier system (4 tiers)
- Discovery risk calculation per service

**Estimated time:** 4 hours

#### Step 3.2: Create corpse_trading.lua (~150 lines)
**Files to create:**
- `engine/economy/corpse_trading.lua`

**Implement:**
- Corpse item creation from dead units
- Value calculation (type, condition, freshness)
- Karma penalties per corpse type
- Discovery risk (5%)
- Alternative uses (research, burial, ransom)

**Estimated time:** 1 hour

#### Step 3.3: Create mission_generation.lua (~200 lines)
**Files to create:**
- `engine/economy/mission_generation.lua`

**Implement:**
- 7 mission types (assassination, sabotage, heist, kidnapping, false_flag, data_theft, smuggling)
- Cost calculation (20K-60K)
- Karma penalties (-10 to -40)
- Mission spawn on Geoscape (3-7 days)
- Reward calculation (150-300% profit)

**Estimated time:** 1 hour

---

### Phase 4: Engine - Supporting Systems (3 hours)

#### Step 4.1: Create event_purchasing.lua (~200 lines)
**Files to create:**
- `engine/economy/event_purchasing.lua`

**Implement:**
- 8 event types (improve_relations, sabotage_economy, incite_rebellion, etc.)
- Cost calculation (20K-80K)
- Karma penalties (-5 to -35)
- Event effects application
- Duration tracking (3-6 months or permanent)

**Estimated time:** 1.5 hours

#### Step 4.2: Create temple_facility.lua (~100 lines)
**Files to create:**
- `engine/basescape/facilities/temple_facility.lua`

**Implement:**
- Temple facility definition
- Sanity bonus (+1/week to all units)
- Integration with base facility system
- Configuration (2x2, 12K cost, 8 power)

**Estimated time:** 1 hour

#### Step 4.3: Update unit.lua integration (~50 lines)
**Files to modify:**
- `engine/battlescape/combat/unit.lua`

**Add:**
- Psychological state integration
- Penalty calculation calls
- Deployment check integration

**Estimated time:** 30 minutes

---

### Phase 5: Tests - Morale/Sanity (4 hours)

#### Step 5.1: Create morale_system_test.lua (~200 lines)
**Files to create:**
- `tests2/battlescape/morale_system_test.lua`

**Test coverage:**
- Bravery initialization (6-12 range)
- All morale event functions (8 tests)
- All action functions (3 tests)
- Thresholds (AP penalties at 2, 1, 0)
- Accuracy penalties (5 levels)
- Panic state (0 morale)

**Estimated time:** 2 hours

#### Step 5.2: Create sanity_system_test.lua (~150 lines)
**Files to create:**
- `tests2/battlescape/sanity_system_test.lua`

**Test coverage:**
- Post-mission sanity loss (4 difficulty levels)
- Additional trauma factors (night, deaths, failure)
- Recovery mechanics (base, Temple, medical, leave)
- Broken state (0 sanity)
- Accuracy penalties
- Deployment checks

**Estimated time:** 1.5 hours

#### Step 5.3: Create morale_sanity_integration_test.lua (~150 lines)
**Files to create:**
- `tests2/integration/morale_sanity_integration_test.lua`

**Test coverage:**
- Penalty stacking (morale + sanity)
- Complete mission flow
- Recovery cycles
- Roster rotation scenarios

**Estimated time:** 1 hour

---

### Phase 6: Tests - Black Market (3 hours)

#### Step 6.1: Create black_market_expansion_test.lua (~250 lines)
**Files to create:**
- `tests2/economy/black_market_expansion_test.lua`

**Test coverage:**
- Mission generation (7 types)
- Event purchasing (8 types)
- Unit recruitment (5 types)
- Craft purchasing (4 types)
- Access tiers (karma/fame gates)
- Discovery risk calculation
- Karma penalties

**Estimated time:** 2 hours

#### Step 6.2: Create corpse_trading_test.lua (~100 lines)
**Files to create:**
- `tests2/economy/corpse_trading_test.lua`

**Test coverage:**
- Corpse creation
- Value calculation with modifiers
- Karma penalties
- Discovery risk
- Alternative uses

**Estimated time:** 1 hour

---

### Phase 7: Tests - Updates (1 hour)

#### Step 7.1: Update karma_system_test.lua (~50 lines)
**Files to modify:**
- `tests2/politics/karma_system_test.lua`

**Add tests:**
- New karma penalties for all black market services

**Estimated time:** 30 minutes

#### Step 7.2: Update karma_reputation_test.lua (~30 lines)
**Files to modify:**
- `tests2/basescape/karma_reputation_test.lua`

**Add tests:**
- Discovery consequences
- Fame penalties

**Estimated time:** 30 minutes

---

### Phase 8: Mods - Configuration (2 hours)

#### Step 8.1: Create black_market.toml
**Files to create:**
- `mods/core/rules/economy/black_market.toml`

**Define:**
- Mission types with costs/karma
- Event types with costs/karma/effects
- Unit types with costs/karma/stats
- Craft types with costs/karma/specs
- Corpse values

**Estimated time:** 1 hour

#### Step 8.2: Create temple.toml
**Files to create:**
- `mods/core/rules/facility/temple.toml`

**Define:**
- Temple facility configuration
- Size, cost, power, services

**Estimated time:** 30 minutes

#### Step 8.3: Create psychological_traits.toml
**Files to create:**
- `mods/core/rules/unit/psychological_traits.toml`

**Define:**
- Brave trait (+2 bravery)
- Fearless trait (+3 bravery)
- Timid trait (-2 bravery)
- Other psychological modifiers

**Estimated time:** 30 minutes

---

### Phase 9: Verification (1 hour)

#### Step 9.1: Run all tests
```bash
lovec "tests2/runners" run_subsystem battlescape
lovec "tests2/runners" run_subsystem economy
lovec "tests2/runners" run_subsystem politics
lovec "tests2/runners" run_all
```

**Expected:** All tests passing (100%)

#### Step 9.2: Run game
```bash
lovec "engine"
```

**Expected:** Exit Code 0, no console errors

#### Step 9.3: Manual testing
- Deploy unit → Test morale events
- Complete mission → Test sanity loss
- Access black market → Test new services
- Verify Temple facility functionality

**Estimated time:** 1 hour

---

## Implementation Order

### Week 1 (Day 1-3): Core Systems
1. ✅ Architecture updates (30 min) - COMPLETE
   - Created `architecture/systems/PSYCHOLOGICAL_SYSTEM.md`
   - Updated `architecture/systems/ECONOMY.md` with Black Market diagrams
2. ✅ Morale/Sanity engine (4 hours) - COMPLETE
   - Updated `engine/battlescape/systems/morale_system.lua` (+250 lines)
   - Created `engine/battlescape/morale_actions.lua` (+280 lines)
   - Updated `engine/geoscape/processing/unit_recovery_progression.lua` (+100 lines)
   - Added Temple to `engine/basescape/facilities/facility_types.lua`
3. ⏳ Morale/Sanity tests (4 hours) - PENDING
4. ⏳ Supporting systems (3 hours) - PENDING

### Week 1 (Day 4-5): Black Market
5. ⏳ Black Market expansion (6 hours)
6. ⏳ Black Market tests (3 hours)
7. ⏳ Test updates (1 hour)

### Week 2 (Day 1): Configuration & Verification
8. ⏳ TOML configuration (2 hours)
9. ⏳ Verification & testing (1 hour)

---

## Files Summary

### Architecture (3 files)
- Update: `architecture/systems/economy_system.md`
- Update: `architecture/systems/combat_system.md`
- Create: `architecture/systems/psychological_system.md`

### Engine (8 files, ~1,550 lines)
- Update: `engine/battlescape/systems/morale_system.lua` (+200)
- Update: `engine/economy/marketplace/black_market_system.lua` (+500)
- Update: `engine/geoscape/processing/unit_recovery_progression.lua` (+50)
- Update: `engine/battlescape/combat/unit.lua` (+50)
- Create: `engine/battlescape/morale_actions.lua` (+150)
- Create: `engine/economy/corpse_trading.lua` (+150)
- Create: `engine/economy/mission_generation.lua` (+200)
- Create: `engine/economy/event_purchasing.lua` (+200)
- Create: `engine/basescape/facilities/temple_facility.lua` (+100)

### Tests (7 files, ~930 lines)
- Create: `tests2/battlescape/morale_system_test.lua` (+200)
- Create: `tests2/battlescape/sanity_system_test.lua` (+150)
- Create: `tests2/integration/morale_sanity_integration_test.lua` (+150)
- Create: `tests2/economy/black_market_expansion_test.lua` (+250)
- Create: `tests2/economy/corpse_trading_test.lua` (+100)
- Update: `tests2/politics/karma_system_test.lua` (+50)
- Update: `tests2/basescape/karma_reputation_test.lua` (+30)

### Mods (3 files)
- Create: `mods/core/rules/economy/black_market.toml`
- Create: `mods/core/rules/facility/temple.toml`
- Create: `mods/core/rules/unit/psychological_traits.toml`

---

## Dependencies

**Satisfied:**
- ✅ Design documentation complete
- ✅ API documentation complete
- ✅ Existing morale_system.lua (basic)
- ✅ Existing black_market_system.lua (basic)
- ✅ Unit system exists
- ✅ Economy system exists
- ✅ Karma/fame systems exist

**None blocking.**

---

## Testing Strategy

1. **Unit tests first** - Test individual functions in isolation
2. **Integration tests** - Test system interactions
3. **Game verification** - Manual testing in running game
4. **Cross-layer consistency** - Verify design ↔ API ↔ engine alignment

---

## Success Metrics

- [ ] All engine files implemented and functional
- [ ] All test files created with ≥80% coverage
- [ ] All tests passing (100%)
- [ ] Game runs without errors (Exit Code 0)
- [ ] Manual testing confirms functionality
- [ ] Architecture diagrams updated
- [ ] TOML configuration complete
- [ ] Documentation cross-references verified

---

## Estimated Total Time

- Architecture: 0.5 hours
- Engine: 13 hours
- Tests: 8 hours
- Mods: 2 hours
- Verification: 1 hour
- **Total: 24.5 hours**

---

## Notes

- Following update_mechanics.prompt.md workflow strictly
- Design → API → Architecture → Engine → Mods → Tests sequence
- Systematic implementation, no skipping layers
- Continuous testing and verification

---

**Last Updated:** 2025-10-28
**Status:** Ready to begin implementation

