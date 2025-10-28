<!-- ──────────────────────────────────────────────────────────────────────────
TESTS2 FOLDER REORGANIZATION PLAN
────────────────────────────────────────────────────────────────────────── -->

# Tests2 Folder Structure Reorganization

**Date:** October 27, 2025
**Status:** Implementation Starting
**Goal:** Organize tests by TYPE rather than by system

---

## New Folder Structure

```
tests2/
├── by-type/                          ← NEW: Tests organized by type
│   ├── unit/                         (Unit tests - individual components)
│   ├── integration/                  (Integration tests - system interactions)
│   ├── smoke/                        (Phase 1: Quick validation - 22 tests)
│   ├── regression/                   (Phase 2: Bug prevention - 38 tests)
│   ├── contract/                     (Phase 3: API contracts - 45 tests)
│   ├── compliance/                   (Phase 4: Game rules - 44 tests)
│   ├── security/                     (Phase 5: Security - 44 tests)
│   ├── property/                     (Phase 6: Edge cases - 55 tests)
│   └── quality/                      (Phase 7: Standards - 34 tests)
│
├── framework/                        (Test infrastructure - existing)
│   ├── hierarchical_suite.lua
│   └── ...
│
├── utils/                            (Test utilities - existing)
│   ├── test_helpers.lua
│   └── ...
│
├── runners/                          (Test execution - existing)
│   ├── init.lua
│   ├── run_all.lua
│   ├── run_single_test.lua
│   ├── run_subsystem.lua
│   ├── run_smoke.lua                 (Phase 1 runner)
│   ├── run_regression.lua            (Phase 2 runner)
│   ├── run_api_contract.lua          (Phase 3 runner)
│   ├── run_compliance.lua            (Phase 4 runner - new)
│   ├── run_security.lua              (Phase 5 runner - new)
│   └── ...
│
├── mock/                             (Mock data - existing)
├── generators/                       (Data generators - existing)
├── reports/                          (Test reports - existing)
│
└── OLD STRUCTURE (for reference/transition):
    ├── smoke/                        (Phase 1 - move to by-type/smoke/)
    ├── regression/                   (Phase 2 - move to by-type/regression/)
    ├── api_contract/                 (Phase 3 - move to by-type/contract/)
    ├── (other existing folders)      (Keep for now, organize later)
```

---

## Migration Plan

### Phase 1: Smoke Tests (Already in place)
- ✅ Location: `tests2/smoke/`
- ✅ Move to: `tests2/by-type/smoke/`
- Tests: 22
- Files: 5 test modules + init + runner + README

### Phase 2: Regression Tests (Already in place)
- ✅ Location: `tests2/regression/`
- ✅ Move to: `tests2/by-type/regression/`
- Tests: 38
- Files: 6 test modules + init + runner + README

### Phase 3: API Contract Tests (Already in place)
- ✅ Location: `tests2/api_contract/`
- ✅ Move to: `tests2/by-type/contract/`
- Tests: 45
- Files: 6 test modules + init + runner + README

### Phase 4: Compliance Tests (NEW)
- 📍 Location: `tests2/by-type/compliance/`
- Status: To be implemented
- Tests: 44
- Categories: Game rules, configuration constraints, business logic

### Phase 5: Security Tests (NEW)
- 📍 Location: `tests2/by-type/security/`
- Status: To be implemented
- Tests: 44
- Categories: Input validation, access control, data protection

---

## Benefits of New Structure

### Before (By Phase/System)
```
tests2/
├── smoke/              (Quick tests)
├── regression/         (Bug tests)
├── api_contract/       (Interface tests)
├── core/               (Core system tests)
├── geoscape/           (Geoscape tests)
├── battlescape/        (Battlescape tests)
└── ...
```
**Problem:** Tests are scattered by system and phase
**Challenge:** Hard to find all regression tests or all unit tests

### After (By Type)
```
tests2/by-type/
├── unit/               (All unit tests)
├── integration/        (All integration tests)
├── smoke/              (All quick tests)
├── regression/         (All bug prevention tests)
├── contract/           (All API contracts)
├── compliance/         (All game rules tests)
├── security/           (All security tests)
├── property/           (All edge case tests)
└── quality/            (All quality gate tests)
```
**Benefit:** Easy to locate test types
**Advantage:** Run specific test categories
**Improvement:** Better CI/CD integration

---

## Running Tests After Reorganization

### By Test Type
```bash
# Run only unit tests
lovec "tests2/by-type/unit" "run_all"

# Run only smoke tests
run_smoke.bat

# Run only regression tests
run_regression.bat

# Run only API contract tests
run_api_contract.bat

# Run compliance tests (Phase 4)
run_compliance.bat

# Run security tests (Phase 5)
run_security.bat
```

### By Category Group
```bash
# Run fast validation (smoke + regression)
run_smoke.bat && run_regression.bat

# Run all Phase 1-3
run_all.bat

# Run all validation (all types)
lovec "tests2/by-type" "run_all"
```

---

## File Updates Required

### Update Module Paths
All test files need path updates:
```lua
-- OLD (in tests2/smoke/core_systems_smoke_test.lua)
local Suite = HierarchicalSuite:new({
    modulePath = "engine.core",
    fileName = "core_systems_smoke_test.lua",
})

-- NEW (in tests2/by-type/smoke/)
-- Paths stay same for test logic, only file location changes
```

### Update init.lua Files
```lua
-- OLD: tests2/smoke/init.lua
return {
    "tests2.smoke.core_systems_smoke_test",
    ...
}

-- NEW: tests2/by-type/smoke/init.lua
return {
    "tests2.by_type.smoke.core_systems_smoke_test",
    ...
}
```

### Update Runners
```lua
-- OLD: tests2/runners/run_smoke.lua
local smokeTests = require("tests2.smoke")

-- NEW: tests2/runners/run_smoke.lua
local smokeTests = require("tests2.by_type.smoke")
```

---

## Summary of Changes

**Directories Created:** 9
- tests2/by-type/ (root)
- tests2/by-type/unit/
- tests2/by-type/integration/
- tests2/by-type/smoke/
- tests2/by-type/regression/
- tests2/by-type/contract/
- tests2/by-type/compliance/
- tests2/by-type/security/
- tests2/by-type/property/
- tests2/by-type/quality/ (not created yet)

**Files to Migrate:**
- Phase 1: 7 files (5 tests + init + README)
- Phase 2: 8 files (6 tests + init + README)
- Phase 3: 8 files (6 tests + init + README)

**Files to Update:**
- 8 runners (path updates)
- 9+ init.lua files (module path updates)

---

## Implementation Timeline

**Step 1:** Create directory structure (Done ✅)
**Step 2:** Update Phase 1-3 files and move to new structure
**Step 3:** Implement Phase 4 (Compliance Tests) - 44 tests
**Step 4:** Implement Phase 5 (Security Tests) - 44 tests
**Step 5:** Verify all tests run correctly

---

## Next Actions

1. **Create updated init.lua files** for by-type directories
2. **Move Phase 1-3 tests** to new structure
3. **Update runner references** to new paths
4. **Create Phase 4 runners** and batch files
5. **Create Phase 5 runners** and batch files
6. **Test full suite** to verify new structure works
