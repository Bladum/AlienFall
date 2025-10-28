# Test Migration Checklist

**Project:** AlienFall
**Objective:** Migrate missing tests from `tests/` to `tests2/` folder
**Plan Reference:** `/tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md`
**Status:** In Progress (75% Complete)
**Start Date:** October 26, 2025
**Target Completion:** November 2, 2025

---

## 📋 Master Task List

### Phase 0: Preparation

- [ ] **P0.1** Create development branch `test-migration`
- [ ] **P0.2** Review MIGRATION_PLAN_TESTS_TO_TESTS2.md
- [ ] **P0.3** Set up test runner: `lovec tests2/runners run_all`
- [ ] **P0.4** Verify tests2 infrastructure working
- [ ] **P0.5** Document baseline test count

**Status:** ⏳ Pending
**Est. Time:** 1 hour

---

## 🎵 Phase 1: Audio System Tests (TASK 1)

**Priority:** HIGH
**Source File:** `tests/unit/test_audio_system.lua` (7 tests)
**Target File:** `tests2/core/audio_system_test.lua`
**Est. Time:** 2-3 hours

### Development

- [x] **A1.1** Create `tests2/core/audio_system_test.lua`
- [x] **A1.2** Set up HierarchicalSuite with modulePath
- [x] **A1.3** Create mock AudioSystem if needed
- [x] **A1.4** Implement "Initialization" group
  - [x] AudioSystem:new() - creation test

- [x] **A1.5** Implement "Volume Control" group
  - [x] setVolume/getVolume - setter/getter
  - [x] Volume clamping - 0.0 to 1.0

- [x] **A1.6** Implement "Categories" group
  - [x] Test all categories: master, music, sfx, ui, ambient
  - [x] Invalid category handling

- [x] **A1.7** Implement "Muting" group
  - [x] Mute functionality
  - [x] Unmute functionality

- [x] **A1.8** Implement "Update Cycle" group
  - [x] Update method without crashing

- [x] **A1.9** Implement "Volume Mixing" group
  - [x] Effective volume calculation

### Integration

- [x] **A1.10** Add to `tests2/core/init.lua`
- [x] **A1.11** Add routing to `tests2/main.lua`
- [x] **A1.12** Test: `lovec tests2 run core/audio_system_test`
- [x] **A1.13** Verify all tests pass
- [x] **A1.14** Update `tests2/README.md` with Audio System section

### Validation

- [x] **A1.15** Run full suite: `lovec tests2/runners run_all`
- [x] **A1.16** Check execution time (<1 second)
- [x] **A1.17** Mark TASK 1 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 2-3 hours

---

## 🏢 Phase 2: Facility System Tests (TASK 2)

**Priority:** HIGH
**Source File:** `tests/unit/test_facility_system.lua` (11 tests)
**Target File:** `tests2/basescape/facility_system_test.lua`
**Est. Time:** 3-4 hours

### Development

- [x] **A2.1** Create `tests2/basescape/facility_system_test.lua`
- [x] **A2.2** Set up HierarchicalSuite with modulePath
- [x] **A2.3** Create mock FacilitySystem if needed
- [x] **A2.4** Implement "Initialization" group
  - [x] FacilitySystem:new() - creation
  - [x] Default values check

- [x] **A2.5** Implement "Base Setup" group
  - [x] buildMandatoryHQ() - HQ construction
  - [x] HQ at position (2, 2)

- [x] **A2.6** Implement "Position Validation" group
  - [x] Valid positions
  - [x] Occupied positions
  - [x] Out of bounds handling

- [x] **A2.7** Implement "Construction Lifecycle" group
  - [x] Start construction
  - [x] Complete construction
  - [x] Daily construction updates
  - [x] Construction queue management

- [x] **A2.8** Implement "Capacity Management" group
  - [x] Capacity calculation
  - [x] Capacity updates on construction

- [x] **A2.9** Implement "Damage & Status" group
  - [x] Damage application
  - [x] Destruction
  - [x] Operational status tracking

- [x] **A2.10** Implement "Services" group
  - [x] Service availability
  - [x] Service types: RESEARCH, TRAINING, etc.

- [x] **A2.11** Implement "Maintenance" group
  - [x] Monthly maintenance calculation
  - [x] Maintenance changes on construction

### Integration

- [x] **A2.12** Add to `tests2/basescape/init.lua`
- [x] **A2.13** Add routing to `tests2/main.lua`
- [x] **A2.14** Test: `lovec tests2 run basescape/facility_system_test`
- [x] **A2.15** Verify all tests pass
- [x] **A2.16** Update `tests2/README.md` with Facility System section

### Validation

- [x] **A2.17** Run full suite: `lovec tests2/runners run_all`
- [x] **A2.18** Check execution time (<1 second)
- [x] **A2.19** Mark TASK 2 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 3-4 hours

---

## 🤖 Phase 3: AI Tactical Decision Tests (TASK 3)

**Priority:** HIGH
**Source File:** `tests/unit/test_ai_tactical_decision.lua` (11 tests)
**Target File:** `tests2/ai/tactical_decision_test.lua`
**Est. Time:** 4-5 hours

### Development

- [x] **A3.1** Create `tests2/ai/tactical_decision_test.lua`
- [x] **A3.2** Set up HierarchicalSuite with modulePath
- [x] **A3.3** Create mock AIDecisionSystem if needed
- [x] **A3.4** Implement "Initialization" group
  - [x] System availability check
  - [x] Function availability

- [x] **A3.5** Implement "Unit Management" group
  - [x] Initialize unit
  - [x] Get/set behavior
  - [x] Remove unit

- [x] **A3.6** Implement "Behavior Modes" group
  - [x] All 6 behavior modes: AGGRESSIVE, DEFENSIVE, SUPPORT, FLANKING, SUPPRESSIVE, RETREAT
  - [x] Behavior assignment

- [x] **A3.7** Implement "Behavior Switching" group
  - [x] Low HP triggers RETREAT
  - [x] High HP switches from RETREAT
  - [x] Dynamic behavior switching

- [x] **A3.8** Implement "Threat Assessment" group
  - [x] Threat evaluation function
  - [x] Distance factors
  - [x] Health factors

- [x] **A3.9** Implement "Target Selection" group
  - [x] Target selection with priority
  - [x] AGGRESSIVE = closest
  - [x] Different priority per behavior

- [x] **A3.10** Implement "Action Evaluation" group
  - [x] Action evaluation function
  - [x] Action scoring
  - [x] Multiple action options

- [x] **A3.11** Implement "Best Action" group
  - [x] Select best action
  - [x] Sort by score
  - [x] Handle empty actions

- [x] **A3.12** Implement "Retreat Logic" group
  - [x] Low HP triggers retreat
  - [x] Retreat action evaluation

- [x] **A3.13** Implement "State Management" group
  - [x] getAllAIStates()
  - [x] State tracking
  - [x] State consistency

- [x] **A3.14** Implement "Decision Visualization" group
  - [x] Visualization function
  - [x] Visualization data structure

### Integration

- [x] **A3.15** Add to `tests2/ai/init.lua`
- [x] **A3.16** Add routing to `tests2/main.lua`
- [x] **A3.17** Test: `lovec tests2 run ai/tactical_decision_test`
- [x] **A3.18** Verify all tests pass
- [x] **A3.19** Update `tests2/README.md` with AI Tactical Decision section

### Validation

- [x] **A3.20** Run full suite: `lovec tests2/runners run_all`
- [x] **A3.21** Check execution time (<1 second)
- [x] **A3.22** Mark TASK 3 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 4-5 hours

---

## 🎯 Phase 4: Range & Accuracy Tests (TASK 4)

**Priority:** MEDIUM
**Source File:** `tests/battle/test_range_accuracy.lua` (4 systems)
**Target File:** `tests2/battlescape/range_accuracy_test.lua`
**Est. Time:** 3-4 hours

### Development

- [x] **A4.1** Create `tests2/battlescape/range_accuracy_test.lua`
- [x] **A4.2** Set up HierarchicalSuite with modulePath
- [x] **A4.3** Create mocks: RangeSystem, AccuracySystem, WeaponSystem, ShootingSystem
- [x] **A4.4** Implement "Range Calculation" group
  - [x] Distance calculation (axial coords)
  - [x] Distance calculation (offset coords)
  - [x] Range zones: optimal, effective, long, out_of_range
  - [x] In-range checks

- [x] **A4.5** Implement "Accuracy System" group
  - [x] Accuracy zones (4 zones)
  - [x] Effective accuracy calculation
  - [x] Accuracy degradation curve
  - [x] Zone descriptions

- [x] **A4.6** Implement "Weapon System" group
  - [x] Weapon properties loading
  - [x] Pistol properties (range, damage, accuracy)
  - [x] Rifle properties
  - [x] Invalid weapon handling

- [x] **A4.7** Implement "Shooting Logic" group
  - [x] Shooting info retrieval
  - [x] Can shoot checks
  - [x] Accuracy at range
  - [x] Actual shooting results

### Integration

- [x] **A4.8** Add to `tests2/battlescape/init.lua`
- [x] **A4.9** Add routing to `tests2/main.lua`
- [x] **A4.10** Test: `lovec tests2 run battlescape/range_accuracy_test`
- [x] **A4.11** Verify all tests pass
- [x] **A4.12** Update `tests2/README.md` with Range & Accuracy section

### Validation

- [x] **A4.13** Run full suite: `lovec tests2/runners run_all`
- [x] **A4.14** Check execution time (<1 second)
- [x] **A4.15** Mark TASK 4 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 3-4 hours

---

## 🔧 Phase 5: Mod System Tests (TASK 5)

**Priority:** MEDIUM
**Source File:** `tests/systems/test_mod_system.lua` (8 groups)
**Target File:** `tests2/core/mod_system_test.lua`
**Est. Time:** 3-4 hours

### Development

- [x] **A5.1** Create `tests2/core/mod_system_test.lua`
- [x] **A5.2** Set up HierarchicalSuite with modulePath
- [x] **A5.3** Create mocks: ModManager, TOML, DataLoader
- [x] **A5.4** Implement "ModManager" group
  - [x] ModManager loading
  - [x] Load terrain types
  - [x] Load mapblocks
  - [x] Validate mod structure
  - [x] Content path resolution
  - [x] Mod discovery

- [x] **A5.5** Implement "TOML Parsing" group
  - [x] TOML library availability
  - [x] Load mod.toml
  - [x] Parse terrain data

- [x] **A5.6** Implement "Data Loading" group
  - [x] DataLoader availability
  - [x] TOML validation

- [x] **A5.7** Implement "Asset System" group
  - [x] Asset system availability
  - [x] Placeholder retrieval

- [x] **A5.8** Implement "Mod Switching" group
  - [x] Switch to same mod
  - [x] Invalid mod ID handling
  - [x] Mod list consistency

- [x] **A5.9** Implement "Dependencies" group
  - [x] Validate mod structure
  - [x] Check required fields
  - [x] Content path validation
  - [x] TOML accessibility

- [x] **A5.10** Implement "Content Resolution" group
  - [x] Terrain type resolution
  - [x] Weapon data resolution
  - [x] Unit class resolution

- [x] **A5.11** Implement "Error Handling" group
  - [x] Invalid mod ID
  - [x] No active mod
  - [x] Invalid TOML files

### Integration

- [x] **A5.12** Add to `tests2/core/init.lua`
- [x] **A5.13** Add routing to `tests2/main.lua`
- [x] **A5.14** Test: `lovec tests2 run core/mod_system_test`
- [x] **A5.15** Verify all tests pass
- [x] **A5.16** Update `tests2/README.md` with Mod System section

### Validation

- [x] **A5.17** Run full suite: `lovec tests2/runners run_all`
- [x] **A5.18** Check execution time (<1 second)
- [x] **A5.19** Mark TASK 5 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 3-4 hours

---

## 📊 Phase 6: Performance Tests (TASK 6)

**Priority:** LOW
**Source File:** `tests/performance/test_game_performance.lua` (7 benchmarks)
**Target File:** `tests2/performance/game_performance_test.lua`
**Est. Time:** 2-3 hours

### Development

- [x] **A6.1** Create `tests2/performance/game_performance_test.lua`
- [x] **A6.2** Set up HierarchicalSuite with modulePath
- [x] **A6.3** Implement "Pathfinding Benchmarks" group
  - [x] Short paths (10 tiles)
  - [x] Medium paths (50 tiles)
  - [x] Long paths (100 tiles)

- [x] **A6.4** Implement "Hex Math Benchmarks" group
  - [x] Hex to pixel conversion
  - [x] Pixel to hex conversion
  - [x] Hex distance calculation

- [x] **A6.5** Implement "Unit Management Benchmarks" group
  - [x] Unit iteration
  - [x] Unit filtering
  - [x] Stat calculation

- [x] **A6.6** Implement "Data Structure Benchmarks" group
  - [x] Array insertion
  - [x] Table lookup
  - [x] Table iteration
  - [x] Array iteration

- [x] **A6.7** Implement "String Operation Benchmarks" group
  - [x] String concatenation
  - [x] Table concat
  - [x] String format

- [x] **A6.8** Implement "Collision Detection Benchmarks" group
  - [x] Point-circle collision
  - [x] Circle-circle collision

- [x] **A6.9** Implement "Memory Allocation Benchmarks" group
  - [x] Table allocation
  - [x] Memory collection

### Integration

- [x] **A6.10** Add to `tests2/performance/init.lua`
- [x] **A6.11** Add routing to `tests2/main.lua`
- [x] **A6.12** Test: `lovec tests2 run performance/game_performance_test`
- [x] **A6.13** Verify benchmarks run
- [x] **A6.14** Update `tests2/README.md` with Performance section

### Validation

- [x] **A6.15** Run full suite: `lovec tests2/runners run_all`
- [x] **A6.16** Check execution time (<1 second)
- [x] **A6.17** Mark TASK 6 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 2-3 hours

---

## 🌍 Phase 7: Phase 2 World Generation Tests (TASK 7)

**Priority:** LOW
**Source File:** `tests/geoscape/test_phase2_world_generation.lua` (22 tests)
**Target File:** `tests2/geoscape/world_generation_test.lua`
**Est. Time:** 3-4 hours

### Development

- [x] **A7.1** Create/enhance `tests2/geoscape/world_generation_test.lua`
- [x] **A7.2** Set up HierarchicalSuite with modulePath
- [x] **A7.3** Create mocks: WorldMap, BiomeSystem, ProceduralGenerator, LocationSystem
- [x] **A7.4** Implement "WorldMap" group
  - [x] World creation
  - [x] Province get/set
  - [x] Out of bounds
  - [x] Neighbor queries
  - [x] Distance calculation

- [x] **A7.5** Implement "BiomeSystem" group
  - [x] Generation speed
  - [x] Biome distribution
  - [x] Biome properties
  - [x] Deterministic generation (same seed)
  - [x] Different seeds

- [x] **A7.6** Implement "ProceduralGenerator" group
  - [x] Generation completion
  - [x] Valid world generation
  - [x] All provinces initialized
  - [x] Resources distributed
  - [x] Alien bases generated

- [x] **A7.7** Implement "LocationSystem" group
  - [x] Location system initialization
  - [x] Region generation
  - [x] City placement
  - [x] Capital placement
  - [x] Province assignment

- [x] **A7.8** Implement "GeoMap Integration" group
  - [x] GeoMap creation
  - [x] Time advancement

### Integration

- [x] **A7.9** Add to `tests2/geoscape/init.lua`
- [x] **A7.10** Add routing to `tests2/main.lua`
- [x] **A7.11** Test: `lovec tests2 run geoscape/world_generation_test`
- [x] **A7.12** Verify all tests pass
- [x] **A7.13** Update `tests2/README.md` with World Generation section

### Validation

- [x] **A7.14** Run full suite: `lovec tests2/runners run_all`
- [x] **A7.15** Check execution time (<1 second)
- [x] **A7.16** Mark TASK 7 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 3-4 hours

---

## ⚡ Phase 8: Phase 2 Optimization Tests (TASK 8)

**Priority:** LOW
**Source File:** `tests/systems/test_phase2.lua` (5 groups)
**Target File:** `tests2/performance/phase2_optimization_test.lua`
**Est. Time:** 3-4 hours

### Development

- [x] **A8.1** Create `tests2/performance/phase2_optimization_test.lua`
- [x] **A8.2** Set up HierarchicalSuite with modulePath
- [x] **A8.3** Create mocks: Battlefield, Unit, LOSOptimized
- [x] **A8.4** Implement "Battlefield Generation" group
  - [x] Tiny (20x20)
  - [x] Small (30x30)
  - [x] Medium (60x60)
  - [x] Large (90x90)
  - [x] Huge (120x120)
  - [x] Massive (150x150)

- [x] **A8.5** Implement "Dirty Flag System" group
  - [x] Initial dirty state
  - [x] Clean all units
  - [x] Dirty after move

- [x] **A8.6** Implement "Visibility Caching" group
  - [x] All units dirty (first update)
  - [x] Partial dirty (moved units)
  - [x] Performance improvement

- [x] **A8.7** Implement "Cache Performance" group
  - [x] Cache warmup (10 iterations)
  - [x] Hit rate tracking
  - [x] Cache statistics

- [x] **A8.8** Implement "Memory Efficiency" group
  - [x] Battlefield memory usage
  - [x] Cache memory usage
  - [x] Total memory usage

### Integration

- [x] **A8.9** Add to `tests2/performance/init.lua`
- [x] **A8.10** Add routing to `tests2/main.lua`
- [x] **A8.11** Test: `lovec tests2 run performance/phase2_optimization_test`
- [x] **A8.12** Verify benchmarks run
- [x] **A8.13** Update `tests2/README.md` with Phase 2 Optimization section

### Validation

- [x] **A8.14** Run full suite: `lovec tests2/runners run_all`
- [x] **A8.15** Check execution time (<1 second)
- [x] **A8.16** Mark TASK 8 complete

**Status:** 🟢 COMPLETE
**Est. Time:** 3-4 hours

---

## 📚 Phase 9: Documentation & Finalization

**Priority:** HIGH
**Est. Time:** 2-3 hours

### Documentation

- [ ] **A9.1** Update `tests2/README.md` with complete migration summary
- [ ] **A9.2** Create `tests2/MIGRATION_GUIDE.md` (migration patterns)
- [ ] **A9.3** Update subsystem READMEs if needed
- [ ] **A9.4** Document new test coverage statistics
- [ ] **A9.5** Add migration completion notes

### Framework Updates

- [ ] **A9.6** Verify all init.lua files updated
- [ ] **A9.7** Verify main.lua routing complete
- [ ] **A9.8** Test: `lovec tests2/runners run_all`
- [ ] **A9.9** Verify <1 second execution

### Final Validation

- [ ] **A9.10** Run each subsystem:
  - [ ] `lovec tests2 run core/audio_system_test`
  - [ ] `lovec tests2 run basescape/facility_system_test`
  - [ ] `lovec tests2 run ai/tactical_decision_test`
  - [ ] `lovec tests2 run battlescape/range_accuracy_test`
  - [ ] `lovec tests2 run core/mod_system_test`
  - [ ] `lovec tests2 run performance/game_performance_test`
  - [ ] `lovec tests2 run geoscape/world_generation_test`
  - [ ] `lovec tests2 run performance/phase2_optimization_test`

- [ ] **A9.11** Run full suite: `lovec tests2/runners run_all`
- [ ] **A9.12** Check all tests pass
- [ ] **A9.13** Verify no regressions

### Cleanup & Closeout

- [ ] **A9.14** Mark legacy `tests/` folder for future removal
- [ ] **A9.15** Create pull request with migration
- [ ] **A9.16** Document in project notes
- [ ] **A9.17** Merge to main branch

**Status:** ⏳ Pending
**Est. Time:** 2-3 hours

---

## 📊 Progress Tracking

### Overall Progress
- [x] Phase 0: Preparation (100%) - Planning complete
- [x] Phase 1: Audio System (100%) - 17/17 tasks complete
- [x] Phase 2: Facility System (100%) - 19/19 tasks complete
- [x] Phase 3: AI Tactical Decision (100%) - 22/22 tasks complete
- [x] Phase 4: Range & Accuracy (100%) - 15/15 tasks complete
- [x] Phase 5: Mod System (100%) - 19/19 tasks complete
- [x] Phase 6: Performance Tests (100%) - 17/17 tasks complete
- [x] Phase 7: Phase 2 World Generation (100%) - 16/16 tasks complete
- [x] Phase 8: Phase 2 Optimization (100%) - 16/16 tasks complete
- [ ] Phase 9: Documentation (0%) - 17 tasks pending

**Total Progress: 141/158 tasks complete (89.2%)**

### Time Tracking
- Estimated Total: 25-35 hours
- Actual Hours: ~18 hours completed so far
- Start Date: October 26, 2025
- Target End Date: November 2, 2025
- **Remaining Work:** 2 tasks (Range & Accuracy, Mod System) + Documentation

---

## 🎯 Success Metrics

✅ **Test Count:** 62 legacy tests migrated (50 completed, 12 remaining)
✅ **New Files:** 6 new test files created (2 remaining)
✅ **Coverage:** 80.6% of legacy tests migrated
✅ **Standards:** All completed tests follow tests2/ patterns
✅ **Performance:** Suite runs in <1 second
✅ **Framework:** Most configs updated
✅ **Validation:** Completed tests pass

---

## 📋 Remaining Tasks

### Immediate Priority (High Impact)
1. **TASK 4: Range & Accuracy Tests** - 15 tasks remaining
2. **TASK 5: Mod System Tests** - 19 tasks remaining

### Finalization (After Migration Complete)
3. **TASK 9: Documentation & Finalization** - 17 tasks remaining

---

**Created:** October 26, 2025
**Status:** 84.3% Complete - Core Migration Done
**Next Action:** Complete TASK 4 (Range & Accuracy) or TASK 5 (Mod System)
