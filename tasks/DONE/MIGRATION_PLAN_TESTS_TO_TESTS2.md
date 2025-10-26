# Test Migration Plan: tests/ → tests2/

**Project:** AlienFall
**Status:** Planning Phase
**Date:** October 26, 2025
**Objective:** Migrate missing test coverage from legacy `tests/` folder to modern `tests2/` folder using HierarchicalSuite framework and best practices.

---

## 📊 Executive Summary

The legacy `tests/` folder contains 155 Lua files with valuable test coverage that doesn't exist in `tests2/` (197 files, modern framework). This plan outlines a structured migration strategy that:

- ✅ **Preserves coverage** - No functionality lost
- ✅ **Uses best practices** - Follows tests2/ standards and patterns
- ✅ **Implements incrementally** - One subsystem at a time
- ✅ **Updates documentation** - Framework configs and READMEs
- ✅ **Maintains quality** - Uses HierarchicalSuite framework and test helpers

---

## 🎯 Migration Strategy

### Phase 1: Planning & Preparation (Week 1)
- ✅ Analyze coverage gaps (COMPLETED)
- ✅ Create migration plan (THIS DOCUMENT)
- ⏳ Set up development branch
- ⏳ Create migration task checklist

### Phase 2: Audio System (Week 1-2)
- Highest priority (zero coverage in tests2)
- Relatively isolated system
- 7 tests from `test_audio_system.lua`

### Phase 3: Facility System (Week 2)
- High priority (mock-only in tests2)
- Basescape subsystem
- 11 tests from `test_facility_system.lua`

### Phase 4: AI Tactical Decision (Week 2-3)
- High priority (very detailed)
- Core AI subsystem
- 11 tests from `test_ai_tactical_decision.lua`

### Phase 5: Range & Accuracy System (Week 3)
- Medium priority (some overlap)
- Battlescape subsystem
- 4 subsystems (Range, Accuracy, Weapon, Shooting)

### Phase 6: Mod System (Week 3-4)
- Medium priority
- Core subsystem
- 8 test groups from `test_mod_system.lua`

### Phase 7: Performance Tests (Week 4)
- Low priority (benchmarking)
- Utility tests
- 6 tests from `test_game_performance.lua`

### Phase 8: Phase 2 Tests (Week 4)
- Low priority (benchmarking)
- Specialized tests
- 2 test files from `/geoscape` and `/systems`

---

## 📝 Migration Template

### File Structure
```
tests2/{subsystem}/{feature}_test.lua
```

### Naming Convention
- Follow existing pattern: `{system}_{functionality}_test.lua`
- Examples: `audio_system_test.lua`, `facility_system_test.lua`, `ai_tactical_decision_test.lua`

### Standard Template
```lua
-- ─────────────────────────────────────────────────────────────────────────
-- TEST: {Feature Name}
-- FILE: tests2/{subsystem}/{feature}_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.{path}.{module}
-- Covers {coverage description}
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Mock/require real module here
local ModuleUnderTest = {...}

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.{path}.{module}",
    fileName = "{module}.lua",
    description = "{Description of what's tested}"
})

-- Module-level setup
Suite:before(function()
    print("[{ModuleName}] Setting up test suite")
    -- Setup code
end)

Suite:after(function()
    print("[{ModuleName}] Cleaning up after tests")
    -- Cleanup code
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: {Category Name}
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("{Category Name}", function()
    local shared = {}

    Suite:beforeEach(function()
        -- Per-test setup
    end)

    Suite:afterEach(function()
        -- Per-test cleanup
    end)

    Suite:testMethod("{Class}:{method}", {
        description = "What this tests",
        testCase = "happy_path",
        type = "functional"
    }, function()
        -- Test implementation
        Helpers.assertEqual(actual, expected, "Error message")
    end)

    Suite:testMethod("{Class}:{method}", {
        description = "Handles error condition",
        testCase = "error_handling",
        type = "error_handling"
    }, function()
        Helpers.assertThrows(function()
            -- Code that should throw
        end, "Expected error message")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP N: {More Categories}
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("{Category Name}", function()
    -- More tests
end)

return Suite
```

---

## 🔧 Task Breakdown by Subsystem

### TASK 1: Audio System Tests (HIGH PRIORITY)
**Source:** `tests/unit/test_audio_system.lua`
**Target:** `tests2/core/audio_system_test.lua`
**Complexity:** Low
**Estimated Time:** 2-3 hours

#### Tests to Migrate:
1. **AudioSystemTest.testCreate** → AudioSystem initialization
2. **AudioSystemTest.testVolume** → Volume setting/getting
3. **AudioSystemTest.testCategories** → Category management (master, music, sfx, ui, ambient)
4. **AudioSystemTest.testMute** → Muting functionality
5. **AudioSystemTest.testUpdate** → Update cycle
6. **AudioSystemTest.testInvalidCategory** → Error handling
7. **AudioSystemTest.testVolumeMixing** → Volume calculation

#### Implementation Steps:
```
1. Create tests2/core/audio_system_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.core.audio.audio_system"
3. Create group: "Initialization" - test creation
4. Create group: "Volume Control" - test setVolume, getVolume
5. Create group: "Categories" - test category management
6. Create group: "Muting" - test mute/unmute
7. Create group: "Volume Mixing" - test effective volume calculation
8. Create group: "Error Handling" - test invalid categories
9. Add to tests2/core/init.lua
10. Update tests2/README.md - add Audio System section
11. Run: lovec tests2 run core/audio_system_test
```

#### Key Implementation Notes:
- Use mock AudioSystem (can require real if available)
- Test category names: master, music, sfx, ui, ambient
- Volume range validation: 0.0 to 1.0
- Volume mixing formula: effective = master * category * ...

---

### TASK 2: Facility System Tests (HIGH PRIORITY)
**Source:** `tests/unit/test_facility_system.lua`
**Target:** `tests2/basescape/facility_system_test.lua`
**Complexity:** Medium
**Estimated Time:** 3-4 hours

#### Tests to Migrate:
1. **FacilitySystemTest.testCreate** → System initialization
2. **FacilitySystemTest.testBuildHQ** → Mandatory HQ construction
3. **FacilitySystemTest.testValidPosition** → Position validation
4. **FacilitySystemTest.testConstruction** → Construction start
5. **FacilitySystemTest.testConstructionCompletion** → Construction finish
6. **FacilitySystemTest.testDailyConstruction** → Daily updates
7. **FacilitySystemTest.testCapacityCalculation** → Capacity recalculation
8. **FacilitySystemTest.testDamage** → Damage system
9. **FacilitySystemTest.testServices** → Service availability
10. **FacilitySystemTest.testMaintenance** → Maintenance costs
11. **FacilitySystemTest.testOperationalFacilities** → Operational status

#### Implementation Steps:
```
1. Create tests2/basescape/facility_system_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.basescape.facilities.facility_system"
3. Create group: "Initialization" - test creation, HQ setup
4. Create group: "Position Validation" - test valid/invalid positions
5. Create group: "Construction" - test construction lifecycle
6. Create group: "Capacity Management" - test capacity calculations
7. Create group: "Damage & Status" - test damage, operational status
8. Create group: "Services" - test service availability
9. Create group: "Maintenance" - test maintenance costs
10. Add to tests2/basescape/init.lua
11. Update tests2/README.md - add Facility System section
12. Run: lovec tests2 run basescape/facility_system_test
```

#### Key Implementation Notes:
- HQ at position (2, 2) is mandatory first facility
- Facility types: ACCESS_LIFT, LIVING_QUARTERS, LABORATORY, etc.
- Services: RESEARCH, TRAINING, ACCOMMODATION, etc.
- Base grid: 10x10 positions
- Facility status: operational, damaged, destroyed, under_construction

---

### TASK 3: AI Tactical Decision Tests (HIGH PRIORITY)
**Source:** `tests/unit/test_ai_tactical_decision.lua`
**Target:** `tests2/ai/tactical_decision_test.lua`
**Complexity:** Medium-High
**Estimated Time:** 4-5 hours

#### Tests to Migrate:
1. **testAIInitialization** → System availability
2. **testAIUnitInitialization** → Unit setup and state
3. **testBehaviorConfiguration** → Behavior modes
4. **testBehaviorSwitching** → Dynamic behavior changes
5. **testThreatEvaluation** → Threat calculation
6. **testTargetSelection** → Target prioritization
7. **testActionEvaluation** → Action scoring
8. **testBestActionSelection** → Best action picking
9. **testRetreatBehavior** → Low HP behavior
10. **testAIStateManagement** → State tracking
11. **testDecisionVisualization** → Debug visualization

#### Implementation Steps:
```
1. Create tests2/ai/tactical_decision_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.ai.tactical.decision_system"
3. Create group: "Initialization" - test system setup
4. Create group: "Unit Management" - test unit initialization
5. Create group: "Behavior Modes" - test all behavior types
6. Create group: "Behavior Switching" - test mode transitions
7. Create group: "Threat Assessment" - test threat calculations
8. Create group: "Target Selection" - test target prioritization
9. Create group: "Action Evaluation" - test action scoring
10. Create group: "Retreat Logic" - test low HP behavior
11. Create group: "State Management" - test state tracking
12. Add to tests2/ai/init.lua
13. Update tests2/README.md - add AI Tactical Decision section
14. Run: lovec tests2 run ai/tactical_decision_test
```

#### Key Implementation Notes:
- Behavior modes: AGGRESSIVE, DEFENSIVE, SUPPORT, FLANKING, SUPPRESSIVE, RETREAT
- Threat factors: distance, enemy HP, enemy damage, friendlies nearby
- Action types: SHOOT, MOVE, OVERWATCH, RETREAT, SUPPORT
- Low HP threshold: 15% → triggers RETREAT
- Target priority by behavior: AGGRESSIVE=CLOSEST, DEFENSIVE=WEAKEST, etc.

---

### TASK 4: Range & Accuracy Tests (MEDIUM PRIORITY)
**Source:** `tests/battle/test_range_accuracy.lua`
**Target:** `tests2/battlescape/range_accuracy_test.lua`
**Complexity:** Medium
**Estimated Time:** 3-4 hours

#### Tests to Migrate:
1. **testRangeSystem** → Distance calculations, range zones
2. **testAccuracySystem** → Accuracy zones, calculations
3. **testWeaponSystem** → Weapon properties
4. **testShootingSystem** → Complete shooting logic

#### Implementation Steps:
```
1. Create tests2/battlescape/range_accuracy_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.battlescape.combat.range_system"
3. Create group: "Range Calculation" - test distance, zones
4. Create group: "Accuracy System" - test accuracy calculations
5. Create group: "Weapon System" - test weapon properties
6. Create group: "Shooting Logic" - test complete shooting
7. Add to tests2/battlescape/init.lua
8. Update tests2/README.md - add Range & Accuracy section
9. Run: lovec tests2 run battlescape/range_accuracy_test
```

#### Key Implementation Notes:
- Range zones: optimal (0-75%), effective (75-100%), long (100-125%), out_of_range (>125%)
- Accuracy curve: 100% → 50% → 0% based on range
- Weapons: pistol (12 tiles), rifle (20 tiles), etc.
- Distance: Manhattan or Axial hexagon distance

---

### TASK 5: Mod System Tests (MEDIUM PRIORITY)
**Source:** `tests/systems/test_mod_system.lua`
**Target:** `tests2/core/mod_system_test.lua`
**Complexity:** Medium
**Estimated Time:** 3-4 hours

#### Tests to Migrate:
1. **testModManager** → ModManager functionality (6 tests)
2. **testTOMLParsing** → TOML parsing (3 tests)
3. **testErrorHandling** → Error conditions (3 tests)
4. **testDataLoader** → Data loading (2 tests)
5. **testAssetSystem** → Asset access (2 tests)
6. **testModSwitching** → Mod switching (3 tests)
7. **testModDependencies** → Dependencies (3 tests)
8. **testContentResolution** → Content paths (3 tests)

#### Implementation Steps:
```
1. Create tests2/core/mod_system_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.core.mod_manager"
3. Create group: "ModManager" - test mod loading
4. Create group: "TOML Parsing" - test TOML loading
5. Create group: "Data Loading" - test data loader
6. Create group: "Asset System" - test assets
7. Create group: "Mod Switching" - test mod switching
8. Create group: "Dependencies" - test mod validation
9. Create group: "Content Resolution" - test path resolution
10. Create group: "Error Handling" - test error cases
11. Add to tests2/core/init.lua (or create if missing)
12. Update tests2/README.md - add Mod System section
13. Run: lovec tests2 run core/mod_system_test
```

#### Key Implementation Notes:
- Mod structure: mod.toml with id, name, version
- Content sections: rules/battle/terrain.toml, rules/item/weapons.toml, etc.
- TOML sections: terrain, weapons, units, items, etc.
- Error cases: invalid mod ID, missing files, invalid TOML

---

### TASK 6: Performance Tests (LOW PRIORITY)
**Source:** `tests/performance/test_game_performance.lua`
**Target:** `tests2/performance/game_performance_test.lua`
**Complexity:** Low
**Estimated Time:** 2-3 hours

#### Tests to Migrate:
1. **testPathfinding** → Pathfinding performance (3 benchmarks)
2. **testHexMath** → Hex math performance (3 benchmarks)
3. **testUnitManagement** → Unit management performance (3 benchmarks)
4. **testDataStructures** → Data structure performance (4 benchmarks)
5. **testStringOperations** → String performance (3 benchmarks)
6. **testCollisionDetection** → Collision performance (2 benchmarks)
7. **testMemoryAllocation** → Memory allocation (1 test)

#### Implementation Steps:
```
1. Create tests2/performance/game_performance_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.utils.performance"
3. Create group: "Pathfinding" - benchmark pathfinding
4. Create group: "Hex Math" - benchmark hex calculations
5. Create group: "Unit Management" - benchmark unit operations
6. Create group: "Data Structures" - benchmark table operations
7. Create group: "String Operations" - benchmark strings
8. Create group: "Collision Detection" - benchmark collisions
9. Create group: "Memory Allocation" - test memory usage
10. Add to tests2/performance/init.lua
11. Update tests2/README.md - add Performance section
12. Run: lovec tests2 run performance/game_performance_test
```

#### Key Implementation Notes:
- Use `love.timer.getTime()` for benchmarking (or `os.clock()`)
- Record min/max/average times
- Set performance thresholds
- Format: "Metric: Xms total, Yms avg"

---

### TASK 7: Phase 2 World Generation Tests (LOW PRIORITY)
**Source:** `tests/geoscape/test_phase2_world_generation.lua`
**Target:** `tests2/geoscape/world_generation_test.lua`
**Complexity:** Medium
**Estimated Time:** 3-4 hours

#### Tests to Migrate:
1. **WorldMap Tests** - 5 tests
2. **BiomeSystem Tests** - 5 tests
3. **ProceduralGenerator Tests** - 5 tests
4. **LocationSystem Tests** - 5 tests
5. **GeoMap Wrapper Tests** - 2 tests

#### Implementation Steps:
```
1. Create tests2/geoscape/world_generation_test.lua (or enhance existing)
2. Set up HierarchicalSuite with modulePath = "engine.geoscape.world"
3. Create group: "WorldMap" - test world initialization
4. Create group: "BiomeSystem" - test biome generation
5. Create group: "ProceduralGenerator" - test full generation
6. Create group: "LocationSystem" - test city/region placement
7. Create group: "GeoMap Integration" - test wrapper
8. Add to tests2/geoscape/init.lua
9. Update tests2/README.md - add World Generation section
10. Run: lovec tests2 run geoscape/world_generation_test
```

#### Key Implementation Notes:
- World size: 80x40 provinces typical
- Biomes: water, urban, desert, forest, arctic
- Deterministic generation (seeded)
- Provinces per world: 3,200 (80x40)

---

### TASK 8: Phase 2 Additional Tests (LOW PRIORITY)
**Source:** `tests/systems/test_phase2.lua`
**Target:** `tests2/performance/phase2_optimization_test.lua`
**Complexity:** Medium
**Estimated Time:** 3-4 hours

#### Tests to Migrate:
1. **testBattlefieldGeneration** → Battlefield performance (6 sizes)
2. **testDirtyFlagSystem** → Dirty flag verification (3 tests)
3. **testVisibilityWithDirtyFlags** → Visibility + caching (2 tests)
4. **testCacheWarmup** → Cache performance (10 iterations)
5. **testMemoryEfficiency** → Memory usage (1 test)

#### Implementation Steps:
```
1. Create tests2/performance/phase2_optimization_test.lua
2. Set up HierarchicalSuite with modulePath = "engine.battlescape.optimization"
3. Create group: "Battlefield Generation" - benchmark generation
4. Create group: "Dirty Flag System" - verify optimization
5. Create group: "Visibility Caching" - test cached visibility
6. Create group: "Cache Performance" - benchmark cache
7. Create group: "Memory Efficiency" - test memory usage
8. Add to tests2/performance/init.lua
9. Update tests2/README.md - add Phase 2 Optimization section
10. Run: lovec tests2 run performance/phase2_optimization_test
```

#### Key Implementation Notes:
- Battlefield sizes: Tiny (20x20) to Massive (150x150)
- Dirty flag system tracks dirty state per unit
- Cache hit rate target: >80%
- Memory target: <5MB for 120x120 battlefield

---

## 📋 Framework Configuration Updates

### 1. Update `tests2/core/init.lua`
Add new test modules:
```lua
audio.audio_system = require("tests2.core.audio_system_test")
-- (new)
mod_system = require("tests2.core.mod_system_test")
```

### 2. Update `tests2/basescape/init.lua`
Ensure facility system is included:
```lua
facility_system = require("tests2.basescape.facility_system_test")
```

### 3. Update `tests2/ai/init.lua`
Add tactical decision tests:
```lua
tactical_decision = require("tests2.ai.tactical_decision_test")
```

### 4. Update `tests2/battlescape/init.lua`
Add range/accuracy tests:
```lua
range_accuracy = require("tests2.battlescape.range_accuracy_test")
```

### 5. Update `tests2/performance/init.lua`
Add performance tests:
```lua
game_performance = require("tests2.performance.game_performance_test")
phase2_optimization = require("tests2.performance.phase2_optimization_test")
```

### 6. Update `tests2/geoscape/init.lua`
Enhance world generation tests:
```lua
world_generation = require("tests2.geoscape.world_generation_test")
```

### 7. Update `tests2/main.lua`
Add routing for new tests in `runTests()` function:
```lua
elseif testPath == "audio" then
    modulePath = "tests2.core.audio_system_test"
elseif testPath == "mod_system" then
    modulePath = "tests2.core.mod_system_test"
elseif testPath == "facility_system" then
    modulePath = "tests2.basescape.facility_system_test"
elseif testPath == "tactical_decision" then
    modulePath = "tests2.ai.tactical_decision_test"
elseif testPath == "range_accuracy" then
    modulePath = "tests2.battlescape.range_accuracy_test"
-- ... etc
```

---

## 📖 Documentation Updates

### 1. Update `tests2/README.md`

Add new subsystem sections:

```markdown
## 📊 Test Coverage by Subsystem (Updated)

| Subsystem | Files | Tests | Status |
|-----------|-------|-------|--------|
| **core** | 30+ | 300+ | ✅ Added: audio, mod_system |
| **geoscape** | 27 | 270+ | ✅ Added: world_generation |
| **battlescape** | 21 | 210+ | ✅ Added: range_accuracy |
| **basescape** | 15 | 150+ | ✅ Enhanced: facility_system |
| **economy** | 18 | 180+ | ✅ Complete |
| **politics** | 15 | 150+ | ✅ Complete |
| **lore** | 10 | 100+ | ✅ Complete |
| **ai** | 8 | 80+ | ✅ Added: tactical_decision |
| **performance** | 3 | 30+ | ✅ Added: game_performance, phase2_optimization |
| **framework** | 3 | 30+ | ✅ Complete |
| **generators** | 1 | 10+ | ✅ Complete |
| **utils** | 1 | 10+ | ✅ Complete |
| **TOTAL** | **152** | **1,520+** | **✅ Migration Complete** |
```

### 2. Add Migration Summary to `tests2/README.md`

```markdown
## 🔄 Migration from Legacy tests/ Folder

**Date Completed:** [TBD]
**Tests Migrated:** 62 tests from legacy folder
**New Test Files:** 8 new test files
**Total Coverage Addition:** +62 tests

### Tests Migrated From:
- ✅ `tests/unit/test_audio_system.lua` → `tests2/core/audio_system_test.lua` (7 tests)
- ✅ `tests/unit/test_facility_system.lua` → `tests2/basescape/facility_system_test.lua` (11 tests)
- ✅ `tests/unit/test_ai_tactical_decision.lua` → `tests2/ai/tactical_decision_test.lua` (11 tests)
- ✅ `tests/battle/test_range_accuracy.lua` → `tests2/battlescape/range_accuracy_test.lua` (4 systems)
- ✅ `tests/systems/test_mod_system.lua` → `tests2/core/mod_system_test.lua` (8 groups)
- ✅ `tests/performance/test_game_performance.lua` → `tests2/performance/game_performance_test.lua` (7 benchmarks)
- ✅ `tests/geoscape/test_phase2_world_generation.lua` → `tests2/geoscape/world_generation_test.lua` (22 tests)
- ✅ `tests/systems/test_phase2.lua` → `tests2/performance/phase2_optimization_test.lua` (5 groups)
```

### 3. Create `tests2/MIGRATION_GUIDE.md`

Document migration patterns for future reference:
```markdown
# Migration Guide: tests/ → tests2/

## Overview
This document describes how tests were migrated from the legacy `tests/` folder
to the modern `tests2/` folder using HierarchicalSuite framework.

## Key Differences

### Old Pattern (tests/)
- Manual test runners
- Basic assertions
- Flat test structure
- Limited error handling

### New Pattern (tests2/)
- HierarchicalSuite framework
- Comprehensive helpers
- Organized by groups
- Structured error cases
- 3-level coverage tracking

## Migration Pattern

### Step 1: Identify Test Cases
Old tests often have functions like:
- `testCreate()` → Group "Initialization"
- `testVolume()` → Group "Volume Control"
- `testError()` → testCase = "error_handling"

### Step 2: Organize Into Groups
Group related tests together:
```lua
Suite:group("Initialization", function()
  Suite:testMethod(...) end
  Suite:testMethod(...) end
end)
```

### Step 3: Use Helpers
Replace manual assertions with helpers:
```lua
Helpers.assertEqual(actual, expected, "message")
Helpers.assertThrows(fn, "error message")
Helpers.assertNoThrow(fn)
```

## Examples
- See: tests2/core/audio_system_test.lua
- See: tests2/basescape/facility_system_test.lua
- See: tests2/ai/tactical_decision_test.lua
```

---

## 🚀 Execution Timeline

| Phase | Subsystem | Duration | Target Date |
|-------|-----------|----------|------------|
| 1 | Planning & Prep | 1 day | Oct 27 |
| 2 | Audio System | 2-3 hrs | Oct 27 |
| 3 | Facility System | 3-4 hrs | Oct 28 |
| 4 | AI Tactical Decision | 4-5 hrs | Oct 29 |
| 5 | Range & Accuracy | 3-4 hrs | Oct 30 |
| 6 | Mod System | 3-4 hrs | Oct 31 |
| 7 | Performance Tests | 2-3 hrs | Nov 1 |
| 8 | Phase 2 Tests | 3-4 hrs | Nov 2 |
| 9 | Documentation & Cleanup | 2-3 hrs | Nov 3 |

**Total Estimated Time:** 25-35 hours of development

---

## ✅ Success Criteria

- ✅ All 62 tests successfully migrated
- ✅ All new tests pass in HierarchicalSuite
- ✅ Code follows tests2/ standards and patterns
- ✅ Mock objects created for isolated testing
- ✅ Framework configs updated (init.lua, main.lua)
- ✅ README.md documents new coverage
- ✅ Tests run successfully: `lovec tests2/runners run_all`
- ✅ <1 second full suite execution maintained
- ✅ Coverage tracking properly configured
- ✅ Legacy tests/ folder identified for removal after validation

---

## 📋 Rollout Checklist

### Pre-Migration
- [ ] Create development branch: `test-migration`
- [ ] Create migration task checklist
- [ ] Set up test environment

### Migration Phase
- [ ] Audio System Tests (TASK 1)
  - [ ] Create file
  - [ ] Implement groups
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run core/audio_system_test`
  - [ ] Update README.md

- [ ] Facility System Tests (TASK 2)
  - [ ] Create file
  - [ ] Implement groups
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run basescape/facility_system_test`
  - [ ] Update README.md

- [ ] AI Tactical Decision (TASK 3)
  - [ ] Create file
  - [ ] Implement groups
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run ai/tactical_decision_test`
  - [ ] Update README.md

- [ ] Range & Accuracy Tests (TASK 4)
  - [ ] Create file
  - [ ] Implement groups
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run battlescape/range_accuracy_test`
  - [ ] Update README.md

- [ ] Mod System Tests (TASK 5)
  - [ ] Create file
  - [ ] Implement groups
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run core/mod_system_test`
  - [ ] Update README.md

- [ ] Performance Tests (TASK 6)
  - [ ] Create file
  - [ ] Implement benchmarks
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run performance/game_performance_test`
  - [ ] Update README.md

- [ ] Phase 2 World Generation (TASK 7)
  - [ ] Create/enhance file
  - [ ] Implement groups
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run geoscape/world_generation_test`
  - [ ] Update README.md

- [ ] Phase 2 Optimization Tests (TASK 8)
  - [ ] Create file
  - [ ] Implement benchmarks
  - [ ] Add to init.lua
  - [ ] Test: `lovec tests2 run performance/phase2_optimization_test`
  - [ ] Update README.md

### Post-Migration
- [ ] Run full suite: `lovec tests2/runners run_all`
- [ ] Verify all new tests pass
- [ ] Update main.lua routing
- [ ] Final documentation review
- [ ] Create PR with migration summary
- [ ] Mark tests/ folder for removal
- [ ] Update project documentation

---

## 🔗 References

**Source Tests:**
- `/tests/unit/test_audio_system.lua`
- `/tests/unit/test_facility_system.lua`
- `/tests/unit/test_ai_tactical_decision.lua`
- `/tests/battle/test_range_accuracy.lua`
- `/tests/systems/test_mod_system.lua`
- `/tests/performance/test_game_performance.lua`
- `/tests/geoscape/test_phase2_world_generation.lua`
- `/tests/systems/test_phase2.lua`

**Framework References:**
- `/tests2/framework/hierarchical_suite.lua` - Core framework
- `/tests2/utils/test_helpers.lua` - Test utilities
- `/tests2/core/state_manager_test.lua` - Example implementation
- `/tests2/README.md` - Framework documentation

---

## 📝 Notes

- Migration uses re-implementation, not copy-paste
- All tests follow HierarchicalSuite patterns
- Mock objects provided for isolated testing
- Tests maintain <1 second execution target
- Coverage tracking enabled for all 3 levels
- Documentation kept current throughout

---

**Created:** October 26, 2025
**Status:** Ready for Implementation
**Next Step:** Begin TASK 1 (Audio System Tests)
