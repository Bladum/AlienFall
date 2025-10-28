# Update Mechanics Workflow - Final Report

> **Date**: 2025-10-28  
> **User Question**: "what about engine and test? nothing to change there?"  
> **Answer**: YES - Significant work needed in both layers!

---

## Quick Answer

**Engine Layer**: ⚠️ **40% Complete** - Basic systems exist but need major expansion (~1,550 lines to add)
**Test Layer**: ⚠️ **20% Complete** - Basic karma tests exist, morale/sanity completely untested (~930 lines to add)

---

## What Was Already Done

### ✅ Documentation (100% Complete)
- **Design Layer**: 2 new comprehensive specs (BlackMarket.md, MoraleBraverySanity.md) + 4 updated files
- **API Layer**: 2 files updated with complete function specifications
- **Docs Layer**: 2 new FAQ files + 2 updated FAQ files
- **Total**: ~2,500 lines of documentation across 10 files

---

## What Needs to Be Done

### ⚠️ Engine Layer (~40% → 100%)

**Existing Files Found That Need Updates**:

1. **`engine/battlescape/systems/morale_system.lua`**
   - ✅ Has: Basic morale/sanity tracking, bravery initialization
   - ❌ Missing: Morale events (8 functions), action functions (Rest, Rally, Aura), detailed thresholds, post-mission trauma, sanity recovery
   - **Work**: ~200 lines to add

2. **`engine/economy/marketplace/black_market_system.lua`**
   - ✅ Has: Basic item purchase, karma penalties, discovery mechanics
   - ❌ Missing: Mission generation, event purchasing, unit recruitment, craft purchase, corpse trading, access tiers
   - **Work**: ~500 lines to add

3. **`engine/geoscape/processing/unit_recovery_progression.lua`**
   - ✅ Has: Basic sanity recovery tracking
   - ❌ Missing: Temple facility bonus detection, updated recovery rates
   - **Work**: ~50 lines to update

**New Files Needed**:
1. `engine/economy/corpse_trading.lua` (~150 lines)
2. `engine/economy/mission_generation.lua` (~200 lines)
3. `engine/economy/event_purchasing.lua` (~200 lines)
4. `engine/basescape/temple_facility.lua` (~100 lines)
5. `engine/battlescape/morale_actions.lua` (~150 lines)

**Total Engine Work**: ~1,550 lines across 8 files

---

### ⚠️ Test Layer (~20% → 100%)

**Existing Tests Found**:
- `tests2/politics/karma_system_test.lua` - Has basic black market access tests
- `tests2/basescape/karma_reputation_test.lua` - Has basic karma effects tests

**Missing Tests (0% coverage)**:
- Morale system (0 tests)
- Sanity system (0 tests)
- Black market expansion features (0 tests)
- Corpse trading (0 tests)

**New Test Files Needed**:
1. `tests2/battlescape/morale_system_test.lua` (~200 lines)
2. `tests2/battlescape/sanity_system_test.lua` (~150 lines)
3. `tests2/economy/black_market_expansion_test.lua` (~250 lines)
4. `tests2/economy/corpse_trading_test.lua` (~100 lines)
5. `tests2/integration/morale_sanity_integration_test.lua` (~150 lines)

**Existing Tests to Update**:
1. `tests2/politics/karma_system_test.lua` (~50 lines to add)
2. `tests2/basescape/karma_reputation_test.lua` (~30 lines to add)

**Total Test Work**: ~930 lines across 7 files

---

## Why This Matters

### Current State
The design documentation describes a comprehensive system with:
- **Morale**: 8 event types, 3 action types, 5 threshold levels, accuracy penalties
- **Sanity**: 4 trauma levels, 3 recovery methods, broken state, deployment restrictions
- **Black Market**: 6 service categories (items, units, craft, missions, events, corpses)

The existing engine implementation has:
- **Morale**: Basic tracking only (~30% of design)
- **Sanity**: Basic recovery only (~40% of design)
- **Black Market**: Item purchases only (~20% of design)

### Gap Analysis

**Morale System Gaps**:
- ❌ Missing: onAllyKilled(), onTakeDamage(), onCriticalHit(), onFlanked(), onOutnumbered(), onCommanderKilled()
- ❌ Missing: restAction(), leaderRally(), leaderAura()
- ❌ Missing: Detailed accuracy penalties (only checks ≤2)
- ❌ Missing: Granular thresholds (4-5 morale, 3 morale)

**Sanity System Gaps**:
- ❌ Missing: Post-mission trauma application
- ❌ Missing: Temple facility bonus
- ❌ Missing: Medical treatment option
- ❌ Missing: Leave/vacation option
- ❌ Missing: Broken state deployment prevention

**Black Market Gaps**:
- ❌ Missing: Mission generation (7 types)
- ❌ Missing: Event purchasing (8 types)
- ❌ Missing: Unit recruitment (5 types)
- ❌ Missing: Craft purchasing (4 types)
- ❌ Missing: Corpse trading system (5 types)
- ❌ Missing: Access tier system (4 tiers)

---

## Recommended Action

### Immediate (Critical Path)
1. **Read** the action plan: `temp/engine_test_action_plan.md`
2. **Update** morale system (~200 lines)
3. **Create** morale actions (~150 lines)
4. **Create** morale/sanity tests (~350 lines)
5. **Verify** with test run

### Follow-up (High Value)
1. **Update** black market system (~500 lines)
2. **Create** 4 new economy systems (~700 lines)
3. **Create** black market tests (~350 lines)
4. **Verify** with test run

### Polish (Quality Assurance)
1. **Create** integration tests (~150 lines)
2. **Update** karma tests (~80 lines)
3. **Run** full test suite
4. **Verify** game runs (Exit Code 0)

---

## Timeline Estimate

- **Week 1**: Core morale/sanity implementation (~500 lines + 350 test lines)
- **Week 2**: Black market expansion (~1,050 lines + 580 test lines)
- **Week 3**: Integration, polish, verification

**Total**: 15-20 hours of implementation work

---

## Files Summary

### Documentation (✅ Complete)
- Created: 4 new files
- Updated: 6 existing files
- Total: ~2,500 lines

### Engine (⚠️ Needs Work)
- Update: 3 existing files (~750 lines)
- Create: 5 new files (~800 lines)
- Total: ~1,550 lines needed

### Tests (⚠️ Needs Work)
- Create: 5 new files (~850 lines)
- Update: 2 existing files (~80 lines)
- Total: ~930 lines needed

### Grand Total
- Documentation: 2,500 lines ✅
- Code to write: 2,480 lines ⚠️
- **Work remaining**: ~50% of total effort

---

## Conclusion

**Question**: "what about engine and test? nothing to change there?"

**Answer**: **A LOT to change!**

While the documentation is 100% complete and provides comprehensive specifications, the engine implementations are only 20-40% complete and require significant expansion to match the design. Additionally, test coverage for the new features is minimal (20%) or non-existent (0% for morale/sanity).

**Good News**: 
- All design work is done (clear specifications)
- Basic implementations exist (not starting from scratch)
- No architectural changes needed (extending existing systems)
- Clear action plan provided

**Next Steps**: Follow `temp/engine_test_action_plan.md` for systematic implementation.

---

**Report Date**: 2025-10-28  
**Status**: Documentation Complete, Implementation Required  
**Priority**: High (design complete, awaiting code)  
**Blockers**: None (all dependencies satisfied)

