# Test Migration: Legacy tests/ → Modern tests2/

## 📋 Quick Overview

**What:** Migrate 62 high-value tests from legacy `tests/` folder to modern `tests2/` folder
**Why:** Better standards, HierarchicalSuite framework, faster execution, organized structure
**How:** Re-implement tests using best practices, not copy-paste
**Timeline:** 25-35 hours across 8 phases + 1 finalization phase
**Status:** 🟡 Planning Phase - Ready to Begin Implementation

---

## 🎯 Mission

The legacy `tests/` folder contains valuable test coverage that doesn't exist in the modern `tests2/` folder. This migration brings those tests into the new framework while:

✅ Maintaining 100% coverage (no tests lost)
✅ Using modern HierarchicalSuite framework
✅ Following tests2/ best practices and patterns
✅ Keeping execution time <1 second
✅ Enabling proper coverage tracking
✅ Improving test organization
✅ Enabling future maintenance

---

## 📊 Tests to Migrate (8 Files, 62 Tests)

| # | Source File | Target File | Tests | Priority | Duration |
|---|---|---|---|---|---|
| 1 | `tests/unit/test_audio_system.lua` | `tests2/core/audio_system_test.lua` | 7 | 🔴 HIGH | 2-3 hrs |
| 2 | `tests/unit/test_facility_system.lua` | `tests2/basescape/facility_system_test.lua` | 11 | 🔴 HIGH | 3-4 hrs |
| 3 | `tests/unit/test_ai_tactical_decision.lua` | `tests2/ai/tactical_decision_test.lua` | 11 | 🔴 HIGH | 4-5 hrs |
| 4 | `tests/battle/test_range_accuracy.lua` | `tests2/battlescape/range_accuracy_test.lua` | 4 systems | 🟡 MEDIUM | 3-4 hrs |
| 5 | `tests/systems/test_mod_system.lua` | `tests2/core/mod_system_test.lua` | 8 groups | 🟡 MEDIUM | 3-4 hrs |
| 6 | `tests/performance/test_game_performance.lua` | `tests2/performance/game_performance_test.lua` | 7 | 🟢 LOW | 2-3 hrs |
| 7 | `tests/geoscape/test_phase2_world_generation.lua` | `tests2/geoscape/world_generation_test.lua` | 22 | 🟢 LOW | 3-4 hrs |
| 8 | `tests/systems/test_phase2.lua` | `tests2/performance/phase2_optimization_test.lua` | 5 groups | 🟢 LOW | 3-4 hrs |

**Total:** 62 tests, 25-35 hours

---

## 📋 Documents in This Plan

### 1. **MIGRATION_PLAN_TESTS_TO_TESTS2.md**
Comprehensive migration plan with:
- ✅ Detailed breakdown of each task (TASK 1-8)
- ✅ Implementation steps for each test
- ✅ Framework configuration updates
- ✅ Documentation updates needed
- ✅ Timeline and rollout strategy
- ✅ Success criteria

**Use This For:** Understanding the overall strategy and implementation approach

### 2. **TEST_MIGRATION_CHECKLIST.md**
Executable checklist with:
- ✅ 89 individual tasks across 9 phases
- ✅ Per-task status tracking
- ✅ Time estimates per phase
- ✅ Success metrics
- ✅ Progress tracking

**Use This For:** Day-to-day execution and tracking progress

### 3. **This File (README)**
Quick reference with:
- ✅ Overview of entire migration
- ✅ Key files and documents
- ✅ Implementation approach
- ✅ Quick start for developers
- ✅ Links to detailed documentation

**Use This For:** Getting started and understanding the big picture

---

## 🚀 Quick Start for Developers

### Before Starting

1. **Read the plan:**
   ```bash
   cat tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md
   ```

2. **Review examples:**
   - Look at: `tests2/core/state_manager_test.lua`
   - Look at: `tests2/core/audio_system_test.lua`
   - Review framework: `tests2/framework/hierarchical_suite.lua`

3. **Test the infrastructure:**
   ```bash
   # From project root
   lovec tests2/runners run_all
   # Should complete in <1 second
   ```

### Starting a Task

1. **Pick a task** from TEST_MIGRATION_CHECKLIST.md
2. **Read the detailed spec** in MIGRATION_PLAN_TESTS_TO_TESTS2.md
3. **Follow the implementation steps**
4. **Use the template** from the plan
5. **Test frequently:**
   ```bash
   lovec tests2 run {subsystem}/{test_name}
   ```

### Pattern: Creating a New Test File

```lua
-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Feature Name
-- FILE: tests2/{subsystem}/{feature}_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.{path}.{module}
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Create suite
local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.state_manager",
    fileName = "state_manager.lua",
    description = "State management system"
})

-- Setup/teardown
Suite:before(function() print("[Setup]") end)
Suite:after(function() print("[Cleanup]") end)

-- Test groups
Suite:group("Initialization", function()
    Suite:beforeEach(function() -- Per-test setup end)
    Suite:afterEach(function() -- Per-test cleanup end)

    Suite:testMethod("Class:method", {
        description = "What this tests",
        testCase = "happy_path",
        type = "functional"
    }, function()
        Helpers.assertEqual(actual, expected, "Message")
    end)
end)

return Suite
```

---

## 🔧 Key Implementation Patterns

### 1. Test Organization
```lua
Suite:group("Group Name", function()
    Suite:testMethod("ClassName:method", {...}, function()
        -- Test code
    end)
end)
```

### 2. Assertions
```lua
Helpers.assertEqual(actual, expected, "Message")
Helpers.assertThrows(function() ... end, "Error")
Helpers.assertNoThrow(function() ... end, "Msg")
Helpers.tableContains(list, value)
Helpers.deepCopy(table)
```

### 3. Test Cases
```lua
testCase = "happy_path"          -- Normal behavior
testCase = "error_handling"      -- Error conditions
testCase = "validation"          -- Input validation
testCase = "edge_case"           -- Boundary conditions
```

### 4. Test Types
```lua
type = "functional"              -- Normal functionality
type = "error_handling"          -- Error conditions
type = "validation"              -- Input/output validation
type = "performance"             -- Performance tests
type = "integration"             -- Multi-component
```

---

## 📈 Expected Results

After migration:

```
BEFORE (tests/ + tests2/):
  tests/   - 155 files, legacy framework, slow
  tests2/  - 197 files, modern framework, fast
  TOTAL    - 352 files (some redundant)

AFTER (tests2/ only):
  tests2/  - 205 files, modern framework, all coverage
  tests/   - [REMOVED] - no longer needed
  TOTAL    - 205 files (unified, clean)

COVERAGE INCREASE:
  Audio System:      +7 tests (NEW)
  Facility System:   +11 tests (enhanced from mocks)
  AI Decision:       +11 tests (NEW)
  Range/Accuracy:    +4 systems (NEW)
  Mod System:        +8 groups (NEW)
  Performance:       +7 tests (NEW)
  World Generation:  +22 tests (NEW)
  Phase 2 Opt:       +5 groups (NEW)

TOTAL ADDITION: +75 tests
```

---

## 📊 Success Criteria

When migration is complete, all of these should be true:

✅ All 62 legacy tests migrated to tests2/
✅ 8 new test files created and organized
✅ All tests pass in HierarchicalSuite
✅ Code follows tests2/ standards
✅ Mock objects created for isolation
✅ Framework configs updated (init.lua, main.lua)
✅ README.md documents new coverage
✅ Tests run in <1 second: `lovec tests2/runners run_all`
✅ Coverage tracking configured
✅ PR with migration summary created

---

## 🔗 File Structure After Migration

```
tests2/
├── framework/                    # Test framework
│   ├── hierarchical_suite.lua   # Core framework
│   └── ...

├── core/                         # Core engine tests
│   ├── audio_system_test.lua    # ✨ NEW (migrated)
│   ├── mod_system_test.lua      # ✨ NEW (migrated)
│   ├── state_manager_test.lua
│   └── ...

├── basescape/                    # Base management tests
│   ├── facility_system_test.lua # ✨ ENHANCED (migrated)
│   └── ...

├── battlescape/                  # Tactical combat tests
│   ├── range_accuracy_test.lua  # ✨ NEW (migrated)
│   └── ...

├── ai/                           # AI system tests
│   ├── tactical_decision_test.lua # ✨ NEW (migrated)
│   └── ...

├── geoscape/                     # Strategic layer tests
│   ├── world_generation_test.lua # ✨ ENHANCED (migrated)
│   └── ...

├── performance/                  # Performance tests
│   ├── game_performance_test.lua # ✨ NEW (migrated)
│   ├── phase2_optimization_test.lua # ✨ NEW (migrated)
│   └── ...

├── utils/                        # Test utilities
├── runners/                      # Test runners
└── README.md                     # ✨ UPDATED with migration notes
```

---

## ⏱️ Timeline

| Phase | Task | Start | End | Duration | Status |
|-------|------|-------|-----|----------|--------|
| 0 | Preparation | [TBD] | [TBD] | 1 day | ⏳ |
| 1 | Audio System | [TBD] | [TBD] | 2-3 hrs | ⏳ |
| 2 | Facility System | [TBD] | [TBD] | 3-4 hrs | ⏳ |
| 3 | AI Tactical Decision | [TBD] | [TBD] | 4-5 hrs | ⏳ |
| 4 | Range & Accuracy | [TBD] | [TBD] | 3-4 hrs | ⏳ |
| 5 | Mod System | [TBD] | [TBD] | 3-4 hrs | ⏳ |
| 6 | Performance Tests | [TBD] | [TBD] | 2-3 hrs | ⏳ |
| 7 | World Generation | [TBD] | [TBD] | 3-4 hrs | ⏳ |
| 8 | Phase 2 Optimization | [TBD] | [TBD] | 3-4 hrs | ⏳ |
| 9 | Finalization | [TBD] | [TBD] | 2-3 hrs | ⏳ |

**Total Time:** 25-35 hours

---

## 📚 Documentation

### Reference Materials
- **Migration Plan:** `tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md`
- **Checklist:** `tasks/TODO/TEST_MIGRATION_CHECKLIST.md`
- **Framework:** `tests2/framework/hierarchical_suite.lua`
- **Helpers:** `tests2/utils/test_helpers.lua`
- **Example:** `tests2/core/state_manager_test.lua`

### After Migration
- **Migration Guide:** `tests2/MIGRATION_GUIDE.md` (new)
- **Updated README:** `tests2/README.md` (updated)
- **Subsystem READMEs:** Updated with new test counts

---

## 🚀 Getting Started NOW

### Step 1: Understand the Plan
```bash
# Read the comprehensive migration plan
cat tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md
```

### Step 2: Review Examples
```bash
# Look at an existing test file to understand the pattern
cat tests2/core/state_manager_test.lua | head -100
```

### Step 3: Check Infrastructure
```bash
# Verify tests2 is working
lovec tests2/runners run_all
# Should complete in <1 second with all tests passing
```

### Step 4: Start with Task 1
```bash
# Follow TASK 1 (Audio System) from the migration plan
# Detailed steps in: MIGRATION_PLAN_TESTS_TO_TESTS2.md section "TASK 1"
```

### Step 5: Track Progress
```bash
# Mark tasks complete in the checklist
cat tasks/TODO/TEST_MIGRATION_CHECKLIST.md
# Update status as you complete each task
```

---

## ✅ Validation Checklist

Before marking a task complete:

- [ ] Test file created in correct location
- [ ] All test groups implemented
- [ ] All assertions use Helpers module
- [ ] Mock objects properly set up
- [ ] beforeEach/afterEach used correctly
- [ ] Test passes individually:
  ```bash
  lovec tests2 run {subsystem}/{test_name}
  ```
- [ ] Full suite still passes:
  ```bash
  lovec tests2/runners run_all
  ```
- [ ] No console errors or warnings
- [ ] Task marked complete in checklist
- [ ] Entry added to init.lua
- [ ] Routing added to main.lua

---

## 🤝 Support

### Questions About Patterns?
- Look at existing tests: `tests2/core/state_manager_test.lua`
- Review framework: `tests2/framework/hierarchical_suite.lua`
- Check helpers: `tests2/utils/test_helpers.lua`

### Having Issues?
- Check that Love2D 12.0+ is installed
- Run from project root directory
- Verify tests2 infrastructure with: `lovec tests2/runners run_all`
- Review console output for detailed errors

### Need Help?
- Review the migration plan in detail
- Check the test template pattern
- Look at similar migrated tests
- Review the checklist for completion criteria

---

## 📝 Notes

- **Not Copy-Paste:** Tests are re-implemented using best practices, not copied
- **Isolated Testing:** Mock objects ensure tests run independently
- **Framework Standards:** All tests follow HierarchicalSuite patterns
- **Performance:** Execution time stays <1 second
- **Organization:** Tests organized by subsystem, not by type
- **Coverage:** 3-level tracking: Module → File → Method

---

## 🎯 Next Actions

1. **Read** `tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md`
2. **Print** `tasks/TODO/TEST_MIGRATION_CHECKLIST.md`
3. **Review** example test: `tests2/core/state_manager_test.lua`
4. **Start** TASK 1 (Audio System Tests)
5. **Track** progress in checklist
6. **Validate** each task before moving to next

---

**Plan Created:** October 26, 2025
**Status:** 🟡 Ready for Implementation
**Next Milestone:** Phase 0 - Preparation
**Estimated Completion:** [Target date based on start date + 25-35 hours]

---

## 📞 Quick Links

| Item | Link |
|------|------|
| Migration Plan (Detailed) | `tasks/MIGRATION_PLAN_TESTS_TO_TESTS2.md` |
| Task Checklist | `tasks/TODO/TEST_MIGRATION_CHECKLIST.md` |
| Framework Docs | `tests2/framework/hierarchical_suite.lua` |
| Test Helpers | `tests2/utils/test_helpers.lua` |
| Example Test | `tests2/core/state_manager_test.lua` |
| Framework README | `tests2/README.md` |

---

**This is the migration blueprint. Implementation follows the detailed plan.**
