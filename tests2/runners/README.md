# tests2/runners - Test Execution Scripts

**Purpose:** Provide test runner infrastructure for execution

**Content:** Runner scripts for test execution

**Features:**
- Master runner for all tests
- Subsystem-specific runners
- Single test file runners
- Result aggregation

## Runners

- **run_all.lua** - Execute all test suites
- **run_subsystem.lua** - Run specific subsystem
- **run_single_test.lua** - Run individual test file
- **init.lua** - Runner module loader

## Usage

```bash
# Run all tests
lovec tests2/runners run_all

# Run specific subsystem
lovec tests2/runners run_subsystem core
lovec tests2/runners run_subsystem battlescape

# Run single test
lovec tests2/runners run_single_test core/state_manager_test
```

## Statistics

- **Runner Scripts**: 3 main runners
- **Status**: Production Ready

---

**Status**: ✅ Functional
**Last Updated**: October 2025
