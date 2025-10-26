# Test Migration Checklist

**Project:** AlienFall
**Objective:** Migrate missing tests from `tests/` to `tests2/` folder
**Plan Reference:** `/tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md`
**Status:** Ready to Begin
**Start Date:** [TBD]
**Target Completion:** [TBD]

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

- [ ] **A1.1** Create `tests2/core/audio_system_test.lua`
- [ ] **A1.2** Set up HierarchicalSuite with modulePath
- [ ] **A1.3** Create mock AudioSystem if needed
- [ ] **A1.4** Implement "Initialization" group
  - [ ] AudioSystem:new() - creation test

- [ ] **A1.5** Implement "Volume Control" group
  - [ ] setVolume/getVolume - setter/getter
  - [ ] Volume clamping - 0.0 to 1.0

- [ ] **A1.6** Implement "Categories" group
  - [ ] Test all categories: master, music, sfx, ui, ambient
  - [ ] Invalid category handling

- [ ] **A1.7** Implement "Muting" group
  - [ ] Mute functionality
  - [ ] Unmute functionality

- [ ] **A1.8** Implement "Update Cycle" group
  - [ ] Update method without crashing

- [ ] **A1.9** Implement "Volume Mixing" group
  - [ ] Effective volume calculation

### Integration

- [ ] **A1.10** Add to `tests2/core/init.lua`
- [ ] **A1.11** Add routing to `tests2/main.lua`
- [ ] **A1.12** Test: `lovec tests2 run core/audio_system_test`
- [ ] **A1.13** Verify all tests pass
- [ ] **A1.14** Update `tests2/README.md` with Audio System section

### Validation

- [ ] **A1.15** Run full suite: `lovec tests2/runners run_all`
- [ ] **A1.16** Check execution time (<1 second)
- [ ] **A1.17** Mark TASK 1 complete

**Status:** ⏳ Pending
**Est. Time:** 2-3 hours

---

## 🏢 Phase 2: Facility System Tests (TASK 2)

**Priority:** HIGH
**Source File:** `tests/unit/test_facility_system.lua` (11 tests)
**Target File:** `tests2/basescape/facility_system_test.lua`
**Est. Time:** 3-4 hours

### Development

- [ ] **A2.1** Create `tests2/basescape/facility_system_test.lua`
- [ ] **A2.2** Set up HierarchicalSuite with modulePath
- [ ] **A2.3** Create mock FacilitySystem if needed
- [ ] **A2.4** Implement "Initialization" group
  - [ ] FacilitySystem:new() - creation
  - [ ] Default values check

- [ ] **A2.5** Implement "Base Setup" group
  - [ ] buildMandatoryHQ() - HQ construction
  - [ ] HQ at position (2, 2)

- [ ] **A2.6** Implement "Position Validation" group
  - [ ] Valid positions
  - [ ] Occupied positions
  - [ ] Out of bounds handling

- [ ] **A2.7** Implement "Construction Lifecycle" group
  - [ ] Start construction
  - [ ] Complete construction
  - [ ] Daily construction updates
  - [ ] Construction queue management

- [ ] **A2.8** Implement "Capacity Management" group
  - [ ] Capacity calculation
  - [ ] Capacity updates on construction

- [ ] **A2.9** Implement "Damage & Status" group
  - [ ] Damage application
  - [ ] Destruction
  - [ ] Operational status tracking

- [ ] **A2.10** Implement "Services" group
  - [ ] Service availability
  - [ ] Service types: RESEARCH, TRAINING, etc.

- [ ] **A2.11** Implement "Maintenance" group
  - [ ] Monthly maintenance calculation
  - [ ] Maintenance changes on construction

### Integration

- [ ] **A2.12** Add to `tests2/basescape/init.lua`
- [ ] **A2.13** Add routing to `tests2/main.lua`
- [ ] **A2.14** Test: `lovec tests2 run basescape/facility_system_test`
- [ ] **A2.15** Verify all tests pass
- [ ] **A2.16** Update `tests2/README.md` with Facility System section

### Validation

- [ ] **A2.17** Run full suite: `lovec tests2/runners run_all`
- [ ] **A2.18** Check execution time (<1 second)
- [ ] **A2.19** Mark TASK 2 complete

**Status:** ⏳ Pending
**Est. Time:** 3-4 hours

---

## 🤖 Phase 3: AI Tactical Decision Tests (TASK 3)

**Priority:** HIGH
**Source File:** `tests/unit/test_ai_tactical_decision.lua` (11 tests)
**Target File:** `tests2/ai/tactical_decision_test.lua`
**Est. Time:** 4-5 hours

### Development

- [ ] **A3.1** Create `tests2/ai/tactical_decision_test.lua`
- [ ] **A3.2** Set up HierarchicalSuite with modulePath
- [ ] **A3.3** Create mock AIDecisionSystem if needed
- [ ] **A3.4** Implement "Initialization" group
  - [ ] System availability check
  - [ ] Function availability

- [ ] **A3.5** Implement "Unit Management" group
  - [ ] Initialize unit
  - [ ] Get/set behavior
  - [ ] Remove unit

- [ ] **A3.6** Implement "Behavior Modes" group
  - [ ] All 6 behavior modes: AGGRESSIVE, DEFENSIVE, SUPPORT, FLANKING, SUPPRESSIVE, RETREAT
  - [ ] Behavior assignment

- [ ] **A3.7** Implement "Behavior Switching" group
  - [ ] Low HP triggers RETREAT
  - [ ] High HP switches from RETREAT
  - [ ] Dynamic behavior switching

- [ ] **A3.8** Implement "Threat Assessment" group
  - [ ] Threat evaluation function
  - [ ] Distance factors
  - [ ] Health factors

- [ ] **A3.9** Implement "Target Selection" group
  - [ ] Target selection with priority
  - [ ] AGGRESSIVE = closest
  - [ ] Different priority per behavior

- [ ] **A3.10** Implement "Action Evaluation" group
  - [ ] Action evaluation function
  - [ ] Action scoring
  - [ ] Multiple action options

- [ ] **A3.11** Implement "Best Action" group
  - [ ] Select best action
  - [ ] Sort by score
  - [ ] Handle empty actions

- [ ] **A3.12** Implement "Retreat Logic" group
  - [ ] Low HP triggers retreat
  - [ ] Retreat action evaluation

- [ ] **A3.13** Implement "State Management" group
  - [ ] getAllAIStates()
  - [ ] State tracking
  - [ ] State consistency

- [ ] **A3.14** Implement "Decision Visualization" group
  - [ ] Visualization function
  - [ ] Visualization data structure

### Integration

- [ ] **A3.15** Add to `tests2/ai/init.lua`
- [ ] **A3.16** Add routing to `tests2/main.lua`
- [ ] **A3.17** Test: `lovec tests2 run ai/tactical_decision_test`
- [ ] **A3.18** Verify all tests pass
- [ ] **A3.19** Update `tests2/README.md` with AI Tactical Decision section

### Validation

- [ ] **A3.20** Run full suite: `lovec tests2/runners run_all`
- [ ] **A3.21** Check execution time (<1 second)
- [ ] **A3.22** Mark TASK 3 complete

**Status:** ⏳ Pending
**Est. Time:** 4-5 hours

---

## 🎯 Phase 4: Range & Accuracy Tests (TASK 4)

**Priority:** MEDIUM
**Source File:** `tests/battle/test_range_accuracy.lua` (4 systems)
**Target File:** `tests2/battlescape/range_accuracy_test.lua`
**Est. Time:** 3-4 hours

### Development

- [ ] **A4.1** Create `tests2/battlescape/range_accuracy_test.lua`
- [ ] **A4.2** Set up HierarchicalSuite with modulePath
- [ ] **A4.3** Create mocks: RangeSystem, AccuracySystem, WeaponSystem, ShootingSystem
- [ ] **A4.4** Implement "Range Calculation" group
  - [ ] Distance calculation (axial coords)
  - [ ] Distance calculation (offset coords)
  - [ ] Range zones: optimal, effective, long, out_of_range
  - [ ] In-range checks

- [ ] **A4.5** Implement "Accuracy System" group
  - [ ] Accuracy zones (4 zones)
  - [ ] Effective accuracy calculation
  - [ ] Accuracy degradation curve
  - [ ] Zone descriptions

- [ ] **A4.6** Implement "Weapon System" group
  - [ ] Weapon properties loading
  - [ ] Pistol properties (range, damage, accuracy)
  - [ ] Rifle properties
  - [ ] Invalid weapon handling

- [ ] **A4.7** Implement "Shooting Logic" group
  - [ ] Shooting info retrieval
  - [ ] Can shoot checks
  - [ ] Accuracy at range
  - [ ] Actual shooting results

### Integration

- [ ] **A4.8** Add to `tests2/battlescape/init.lua`
- [ ] **A4.9** Add routing to `tests2/main.lua`
- [ ] **A4.10** Test: `lovec tests2 run battlescape/range_accuracy_test`
- [ ] **A4.11** Verify all tests pass
- [ ] **A4.12** Update `tests2/README.md` with Range & Accuracy section

### Validation

- [ ] **A4.13** Run full suite: `lovec tests2/runners run_all`
- [ ] **A4.14** Check execution time (<1 second)
- [ ] **A4.15** Mark TASK 4 complete

**Status:** ⏳ Pending
**Est. Time:** 3-4 hours

---

## 🔧 Phase 5: Mod System Tests (TASK 5)

**Priority:** MEDIUM
**Source File:** `tests/systems/test_mod_system.lua` (8 groups)
**Target File:** `tests2/core/mod_system_test.lua`
**Est. Time:** 3-4 hours

### Development

- [ ] **A5.1** Create `tests2/core/mod_system_test.lua`
- [ ] **A5.2** Set up HierarchicalSuite with modulePath
- [ ] **A5.3** Create mocks: ModManager, TOML, DataLoader
- [ ] **A5.4** Implement "ModManager" group
  - [ ] ModManager loading
  - [ ] Load terrain types
  - [ ] Load mapblocks
  - [ ] Validate mod structure
  - [ ] Content path resolution
  - [ ] Mod discovery

- [ ] **A5.5** Implement "TOML Parsing" group
  - [ ] TOML library availability
  - [ ] Load mod.toml
  - [ ] Parse terrain data

- [ ] **A5.6** Implement "Data Loading" group
  - [ ] DataLoader availability
  - [ ] TOML validation

- [ ] **A5.7** Implement "Asset System" group
  - [ ] Asset system availability
  - [ ] Placeholder retrieval

- [ ] **A5.8** Implement "Mod Switching" group
  - [ ] Switch to same mod
  - [ ] Invalid mod ID handling
  - [ ] Mod list consistency

- [ ] **A5.9** Implement "Dependencies" group
  - [ ] Validate mod structure
  - [ ] Check required fields
  - [ ] Content path validation
  - [ ] TOML accessibility

- [ ] **A5.10** Implement "Content Resolution" group
  - [ ] Terrain type resolution
  - [ ] Weapon data resolution
  - [ ] Unit class resolution

- [ ] **A5.11** Implement "Error Handling" group
  - [ ] Invalid mod ID
  - [ ] No active mod
  - [ ] Invalid TOML files

### Integration

- [ ] **A5.12** Add to `tests2/core/init.lua`
- [ ] **A5.13** Add routing to `tests2/main.lua`
- [ ] **A5.14** Test: `lovec tests2 run core/mod_system_test`
- [ ] **A5.15** Verify all tests pass
- [ ] **A5.16** Update `tests2/README.md` with Mod System section

### Validation

- [ ] **A5.17** Run full suite: `lovec tests2/runners run_all`
- [ ] **A5.18** Check execution time (<1 second)
- [ ] **A5.19** Mark TASK 5 complete

**Status:** ⏳ Pending
**Est. Time:** 3-4 hours

---

## 📊 Phase 6: Performance Tests (TASK 6)

**Priority:** LOW
**Source File:** `tests/performance/test_game_performance.lua` (7 benchmarks)
**Target File:** `tests2/performance/game_performance_test.lua`
**Est. Time:** 2-3 hours

### Development

- [ ] **A6.1** Create `tests2/performance/game_performance_test.lua`
- [ ] **A6.2** Set up HierarchicalSuite with modulePath
- [ ] **A6.3** Implement "Pathfinding Benchmarks" group
  - [ ] Short paths (10 tiles)
  - [ ] Medium paths (50 tiles)
  - [ ] Long paths (100 tiles)

- [ ] **A6.4** Implement "Hex Math Benchmarks" group
  - [ ] Hex to pixel conversion
  - [ ] Pixel to hex conversion
  - [ ] Hex distance calculation

- [ ] **A6.5** Implement "Unit Management Benchmarks" group
  - [ ] Unit iteration
  - [ ] Unit filtering
  - [ ] Stat calculation

- [ ] **A6.6** Implement "Data Structure Benchmarks" group
  - [ ] Array insertion
  - [ ] Table lookup
  - [ ] Table iteration
  - [ ] Array iteration

- [ ] **A6.7** Implement "String Operation Benchmarks" group
  - [ ] String concatenation
  - [ ] Table concat
  - [ ] String format

- [ ] **A6.8** Implement "Collision Detection Benchmarks" group
  - [ ] Point-circle collision
  - [ ] Circle-circle collision

- [ ] **A6.9** Implement "Memory Allocation Benchmarks" group
  - [ ] Table allocation
  - [ ] Memory collection

### Integration

- [ ] **A6.10** Add to `tests2/performance/init.lua`
- [ ] **A6.11** Add routing to `tests2/main.lua`
- [ ] **A6.12** Test: `lovec tests2 run performance/game_performance_test`
- [ ] **A6.13** Verify benchmarks run
- [ ] **A6.14** Update `tests2/README.md` with Performance section

### Validation

- [ ] **A6.15** Run full suite: `lovec tests2/runners run_all`
- [ ] **A6.16** Check execution time (<1 second)
- [ ] **A6.17** Mark TASK 6 complete

**Status:** ⏳ Pending
**Est. Time:** 2-3 hours

---

## 🌍 Phase 7: Phase 2 World Generation Tests (TASK 7)

**Priority:** LOW
**Source File:** `tests/geoscape/test_phase2_world_generation.lua` (22 tests)
**Target File:** `tests2/geoscape/world_generation_test.lua`
**Est. Time:** 3-4 hours

### Development

- [ ] **A7.1** Create/enhance `tests2/geoscape/world_generation_test.lua`
- [ ] **A7.2** Set up HierarchicalSuite with modulePath
- [ ] **A7.3** Create mocks: WorldMap, BiomeSystem, ProceduralGenerator, LocationSystem
- [ ] **A7.4** Implement "WorldMap" group
  - [ ] World creation
  - [ ] Province get/set
  - [ ] Out of bounds
  - [ ] Neighbor queries
  - [ ] Distance calculation

- [ ] **A7.5** Implement "BiomeSystem" group
  - [ ] Generation speed
  - [ ] Biome distribution
  - [ ] Biome properties
  - [ ] Deterministic generation (same seed)
  - [ ] Different seeds

- [ ] **A7.6** Implement "ProceduralGenerator" group
  - [ ] Generation completion
  - [ ] Valid world generation
  - [ ] All provinces initialized
  - [ ] Resources distributed
  - [ ] Alien bases generated

- [ ] **A7.7** Implement "LocationSystem" group
  - [ ] Location system initialization
  - [ ] Region generation
  - [ ] City placement
  - [ ] Capital placement
  - [ ] Province assignment

- [ ] **A7.8** Implement "GeoMap Integration" group
  - [ ] GeoMap creation
  - [ ] Time advancement

### Integration

- [ ] **A7.9** Add to `tests2/geoscape/init.lua`
- [ ] **A7.10** Add routing to `tests2/main.lua`
- [ ] **A7.11** Test: `lovec tests2 run geoscape/world_generation_test`
- [ ] **A7.12** Verify all tests pass
- [ ] **A7.13** Update `tests2/README.md` with World Generation section

### Validation

- [ ] **A7.14** Run full suite: `lovec tests2/runners run_all`
- [ ] **A7.15** Check execution time (<1 second)
- [ ] **A7.16** Mark TASK 7 complete

**Status:** ⏳ Pending
**Est. Time:** 3-4 hours

---

## ⚡ Phase 8: Phase 2 Optimization Tests (TASK 8)

**Priority:** LOW
**Source File:** `tests/systems/test_phase2.lua` (5 groups)
**Target File:** `tests2/performance/phase2_optimization_test.lua`
**Est. Time:** 3-4 hours

### Development

- [ ] **A8.1** Create `tests2/performance/phase2_optimization_test.lua`
- [ ] **A8.2** Set up HierarchicalSuite with modulePath
- [ ] **A8.3** Create mocks: Battlefield, Unit, LOSOptimized
- [ ] **A8.4** Implement "Battlefield Generation" group
  - [ ] Tiny (20x20)
  - [ ] Small (30x30)
  - [ ] Medium (60x60)
  - [ ] Large (90x90)
  - [ ] Huge (120x120)
  - [ ] Massive (150x150)

- [ ] **A8.5** Implement "Dirty Flag System" group
  - [ ] Initial dirty state
  - [ ] Clean all units
  - [ ] Dirty after move

- [ ] **A8.6** Implement "Visibility Caching" group
  - [ ] All units dirty (first update)
  - [ ] Partial dirty (moved units)
  - [ ] Performance improvement

- [ ] **A8.7** Implement "Cache Performance" group
  - [ ] Cache warmup (10 iterations)
  - [ ] Hit rate tracking
  - [ ] Cache statistics

- [ ] **A8.8** Implement "Memory Efficiency" group
  - [ ] Battlefield memory usage
  - [ ] Cache memory usage
  - [ ] Total memory usage

### Integration

- [ ] **A8.9** Add to `tests2/performance/init.lua`
- [ ] **A8.10** Add routing to `tests2/main.lua`
- [ ] **A8.11** Test: `lovec tests2 run performance/phase2_optimization_test`
- [ ] **A8.12** Verify benchmarks run
- [ ] **A8.13** Update `tests2/README.md` with Phase 2 Optimization section

### Validation

- [ ] **A8.14** Run full suite: `lovec tests2/runners run_all`
- [ ] **A8.15** Check execution time (<1 second)
- [ ] **A8.16** Mark TASK 8 complete

**Status:** ⏳ Pending
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
- [ ] Phase 0: Preparation (0%)
- [ ] Phase 1: Audio System (0%)
- [ ] Phase 2: Facility System (0%)
- [ ] Phase 3: AI Tactical Decision (0%)
- [ ] Phase 4: Range & Accuracy (0%)
- [ ] Phase 5: Mod System (0%)
- [ ] Phase 6: Performance Tests (0%)
- [ ] Phase 7: Phase 2 World Generation (0%)
- [ ] Phase 8: Phase 2 Optimization (0%)
- [ ] Phase 9: Documentation (0%)

**Total Progress: 0/89 tasks complete**

### Time Tracking
- Estimated Total: 25-35 hours
- Actual Hours: [TBD]
- Start Date: [TBD]
- Target End Date: [TBD]

---

## 🎯 Success Metrics

✅ **Test Count:** 62 legacy tests migrated
✅ **New Files:** 8 new test files created
✅ **Coverage:** 100% of legacy tests migrated
✅ **Standards:** All tests follow tests2/ patterns
✅ **Performance:** Suite runs in <1 second
✅ **Documentation:** Complete README and guides
✅ **Framework:** All configs updated
✅ **Validation:** All tests pass

---

**Created:** October 26, 2025
**Status:** Ready for Execution
**Next Action:** Start Phase 0 (Preparation)
