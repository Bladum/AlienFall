# Task: New Testing Framework Construction

**Status:** TODO
**Priority:** Critical
**Created:** October 24, 2025
**Assigned To:** Development Team

---

## Overview

Design and build a new, highly granular testing structure with hierarchical organization, comprehensive execution mechanisms, and code coverage support. Replace the current flat test structure with a nested, module-organized testing framework enabling tests at multiple execution levels.

---

## Purpose

The current test structure is relatively flat with limited granularity. The new framework needs to support:
- Granular testing at file level
- Modular test organization
- Multiple execution modes (full suite, module, file, specific test)
- Code coverage analysis
- Clear test organization and documentation
- Automated test discovery and execution

---

## Requirements

### Functional Requirements
- [x] Hierarchical test structure (root → module → file → test)
- [x] Test discovery and registration system
- [x] Execute full test suite
- [x] Execute module-level tests
- [x] Execute file-level tests (all tests for a source file)
- [x] Execute specific test or group
- [x] Code coverage analysis (enabled/disabled)
- [x] Detailed test reports with statistics
- [x] Clear failure messages with stack traces
- [x] README documentation for every folder

### Technical Requirements
- [x] Lua-based test framework
- [x] No external dependencies (except Love2D)
- [x] Support for setup/teardown fixtures
- [x] Assertion library with descriptive errors
- [x] Mock data framework integration
- [x] Performance benchmarking support
- [x] Cross-platform (Windows, Mac, Linux)

### Acceptance Criteria
- [x] All 200+ existing tests migrate to new framework
- [x] New framework structure documentation complete
- [x] Helper methods for all execution levels
- [x] Code coverage reports generated correctly
- [x] Test execution time < 5 seconds (full suite)
- [x] 100% backward compatibility with existing tests
- [x] Comprehensive test documentation

---

## Plan

### Phase 1: Framework Architecture Design (6 hours)
**Description:** Design new test framework architecture
**Files to create/modify:**
- `docs/testing/TEST_FRAMEWORK_DESIGN.md` - Framework architecture
- `docs/testing/FRAMEWORK_SPECIFICATION.md` - Detailed specification
- Create framework design documents

**Key tasks:**
- Design hierarchical test registry
- Design test discovery mechanism
- Design test execution engine
- Design code coverage system
- Design assertion library
- Create architectural diagrams
- Document all design decisions

**Architecture Components:**
1. **Test Registry:** Stores all tests with hierarchy
2. **Test Executor:** Runs tests at various levels
3. **Assertion Library:** Provides test assertions
4. **Report Generator:** Creates test reports
5. **Coverage Analyzer:** Tracks code coverage
6. **Mock Framework:** Provides mock data

**Estimated time:** 6 hours

### Phase 2: Core Framework Implementation (12 hours)
**Description:** Implement core test framework functionality
**Files to create/modify:**
- `tests/framework/test_registry.lua` - Test discovery and registration
- `tests/framework/test_executor.lua` - Test execution engine
- `tests/framework/assertions.lua` - Assertion library
- `tests/framework/test_case.lua` - Base test case class
- `tests/framework/test_suite.lua` - Test suite grouping
- `tests/framework/fixtures.lua` - Setup/teardown support
- `tests/framework/report_generator.lua` - Report generation
- `tests/framework/README.md` - Framework documentation

**Key tasks:**
- Implement test registry with hierarchical organization
- Implement test executor with multiple execution modes
- Implement comprehensive assertion library (20+ assertions)
- Implement test fixtures (setup, teardown, beforeEach, afterEach)
- Implement report generation (text, JSON formats)
- Implement error handling and stack traces
- Implement parallel test execution (optional)

**Assertions to include:**
- assertEqual(actual, expected, message)
- assertNotEqual(actual, expected, message)
- assertTrue(condition, message)
- assertFalse(condition, message)
- assertIsNil(value, message)
- assertIsNotNil(value, message)
- assertIsTable(value, message)
- assertIsFunction(value, message)
- assertIsString(value, message)
- assertIsNumber(value, message)
- assertContains(table, value, message)
- assertNotContains(table, value, message)
- assertTableEquals(table1, table2, message)
- assertGreater(a, b, message)
- assertLess(a, b, message)
- assertMatches(string, pattern, message)
- assertThrows(function, expectedError, message)
- assertDoesNotThrow(function, message)

**Estimated time:** 12 hours

### Phase 3: Test Organization & Structure (8 hours)
**Description:** Reorganize existing tests into new hierarchical structure
**Files to create/modify:**
- Migrate all tests from `tests/` to new structure
- Create README.md in every test folder (50+ files)
- `tests/README.md` - Master test documentation
- `docs/testing/TEST_ORGANIZATION.md` - Organization guide

**New Test Structure:**
```
tests/
├── README.md
├── framework/                     -- Test framework itself
│   ├── README.md
│   ├── test_registry.lua
│   ├── test_executor.lua
│   ├── assertions.lua
│   └── ...
├── unit/                          -- Unit tests
│   ├── README.md
│   ├── battlescape/
│   │   ├── README.md
│   │   ├── combat/
│   │   │   ├── README.md
│   │   │   ├── test_damage_system.lua
│   │   │   ├── test_abilities.lua
│   │   │   └── ...
│   │   ├── rendering/
│   │   │   ├── README.md
│   │   │   ├── test_hex_renderer.lua
│   │   │   └── ...
│   │   └── ...
│   ├── geoscape/
│   │   ├── README.md
│   │   ├── systems/
│   │   │   ├── README.md
│   │   │   ├── test_calendar.lua
│   │   │   └── ...
│   │   └── ...
│   ├── core/
│   │   ├── README.md
│   │   ├── test_state_manager.lua
│   │   ├── test_data_loader.lua
│   │   └── ...
│   └── ...
├── integration/                   -- Integration tests
│   ├── README.md
│   ├── test_geoscape_battlescape.lua
│   ├── test_campaign_integration.lua
│   └── ...
├── performance/                   -- Performance benchmarks
│   ├── README.md
│   ├── test_rendering_performance.lua
│   ├── test_pathfinding_performance.lua
│   └── ...
├── mock/                          -- Mock data
│   ├── README.md
│   ├── mock_units.lua
│   ├── mock_missions.lua
│   └── ...
└── runners/                       -- Test execution scripts
    ├── README.md
    ├── run_all.lua
    ├── run_module.lua
    ├── run_file.lua
    └── run_specific.lua
```

**Each test folder needs:**
- README.md describing tests in that folder
- Clear naming convention for test files (test_*.lua)
- Consistent structure across all test folders

**Estimated time:** 8 hours

### Phase 4: Execution Mechanisms (7 hours)
**Description:** Implement test execution at multiple levels
**Files to create/modify:**
- `tests/runners/run_all.lua` - Execute entire test suite
- `tests/runners/run_module.lua` - Execute module tests (e.g., battlescape)
- `tests/runners/run_file.lua` - Execute file tests (e.g., battlescape/combat/*)
- `tests/runners/run_specific.lua` - Execute specific test
- `tests/runners/test_runner.lua` - Main test runner engine
- Helper scripts for integration with CI/CD
- Command-line interface for test selection

**Key tasks:**
- Implement test discovery mechanism
- Implement command-line argument parsing
- Implement module-level filtering
- Implement file-level filtering
- Implement specific test selection
- Implement test grouping by type (unit, integration, performance)
- Create helper methods for common test patterns

**Execution Examples:**
```bash
# Run all tests
lovec tests/runners/run_all.lua

# Run battlescape module tests
lovec tests/runners/run_module.lua battlescape

# Run battlescape/combat tests
lovec tests/runners/run_file.lua battlescape combat

# Run specific test
lovec tests/runners/run_specific.lua battlescape combat damage_system test_critical_hit

# Run with coverage
TEST_COVERAGE=1 lovec tests/runners/run_all.lua

# Run performance tests only
lovec tests/runners/run_specific.lua performance
```

**Estimated time:** 7 hours

### Phase 5: Code Coverage Implementation (6 hours)
**Description:** Implement code coverage analysis
**Files to create/modify:**
- `tests/framework/coverage_analyzer.lua` - Coverage tracking
- `tests/framework/coverage_report.lua` - Report generation
- `tests/runners/coverage_runner.lua` - Runner with coverage
- `docs/testing/COVERAGE_GUIDE.md` - Coverage documentation

**Key tasks:**
- Implement debug.hook() for coverage tracking
- Track which lines are executed
- Calculate coverage percentages per file/module/total
- Generate coverage reports in multiple formats
- Identify uncovered code paths
- Support filtering coverage by module
- Create HTML coverage reports

**Coverage Metrics:**
- Line coverage percentage
- Function coverage percentage
- Branch coverage (if/else paths)
- Coverage by module
- Coverage by file
- Uncovered lines highlighted

**Estimated time:** 6 hours

### Phase 6: Documentation & Helper Methods (6 hours)
**Description:** Create comprehensive documentation and helper methods
**Files to create/modify:**
- `docs/testing/TEST_FRAMEWORK_GUIDE.md` - Complete framework guide
- `docs/testing/WRITING_TESTS.md` - How to write tests
- `docs/testing/ASSERTION_REFERENCE.md` - Assertion library reference
- `tests/framework/test_helpers.lua` - Helper methods
- `docs/testing/EXAMPLES.md` - Test examples

**Helper Methods:**
```lua
-- Create test suite
local suite = TestSuite:new("Module Name")

-- Add test to suite
suite:test("test name", function()
  -- test body
end)

-- Test with setup/teardown
suite:test("test with fixtures", function()
  -- setup
  local obj = createObject()

  -- test
  assert_equals(obj:method(), expected)

  -- teardown happens automatically
end)

-- Group related tests
suite:describe("feature group", function()
  suite:test("test 1", function() end)
  suite:test("test 2", function() end)
end)

-- Run tests
suite:run()
```

**Estimated time:** 6 hours

### Phase 7: Migration & Validation (8 hours)
**Description:** Migrate all existing tests and validate
**Files to create/modify:**
- Migrate all 200+ existing tests to new structure
- `tests/MIGRATION_GUIDE.md` - Migration documentation
- `tests/migration_status.md` - Migration tracking
- Verify all tests still pass

**Key tasks:**
- Audit existing test structure (200+ tests)
- Map tests to new organizational structure
- Migrate tests to new framework
- Verify all tests still pass
- Fix any compatibility issues
- Update test documentation
- Update CI/CD configuration

**Estimated time:** 8 hours

### Phase 8: Testing & Documentation (7 hours)
**Description:** Test the framework itself and create final documentation
**Files to create/modify:**
- `tests/framework/test_framework_itself.lua` - Test the test framework
- `docs/testing/QUICK_START.md` - Quick start guide
- `docs/testing/FAQ.md` - Frequently asked questions
- `docs/testing/TROUBLESHOOTING.md` - Troubleshooting guide

**Key tasks:**
- Test test registry functionality
- Test test executor functionality
- Test assertion library thoroughly
- Test coverage analysis accuracy
- Test all execution modes
- Verify backward compatibility
- Create quick-start guide
- Create troubleshooting guide

**Estimated time:** 7 hours

---

## Implementation Details

### Test Registry Structure

```lua
-- Registry keeps tests organized hierarchically
TestRegistry = {
  battlescape = {
    combat = {
      damage_system = {
        "test_critical_hit",
        "test_armor_reduction",
        ...
      }
    }
  }
}
```

### Test Case Format

```lua
local suite = TestSuite:new("DamageSystem")

suite:before(function()
  -- Runs once before all tests in suite
end)

suite:after(function()
  -- Runs once after all tests in suite
end)

suite:beforeEach(function()
  -- Runs before each test
end)

suite:afterEach(function()
  -- Runs after each test
end)

suite:test("critical hit increases damage", function()
  local unit = createMockUnit({isCriticalHit = true})
  local damage = calculateDamage(unit)
  assertEqual(damage, 150, "Critical hit damage should be 150%")
end)

suite:test("armor reduces damage", function()
  local attacker = createMockUnit()
  local defender = createMockUnit({armor = 50})
  local damage = calculateDamage(attacker, defender)
  assertEqual(damage, 50, "50 armor should reduce damage by 50")
end)

return suite
```

### Test Execution Flow

```
User Input (lovec tests/runners/run_module.lua battlescape)
        ↓
Test Registry discovers all battlescape tests
        ↓
Test Executor loads discovered tests
        ↓
For each test:
  - Run beforeEach
  - Run test function
  - Run afterEach
  - Capture result (pass/fail/error)
        ↓
Generate Report
        ↓
Display Results
        ↓
Return exit code (0 for success, 1 for failure)
```

---

## Testing Strategy

### Framework Self-Testing
- Test the test registry (can register/retrieve tests)
- Test the test executor (executes tests correctly)
- Test the assertion library (all assertions work)
- Test coverage analysis (accurately tracks coverage)
- Test report generation (reports are accurate)

### Backward Compatibility
- Verify all 200+ existing tests still pass
- Verify test APIs are compatible
- Verify execution modes work as before
- Verify reports generate successfully

### Performance
- Full test suite completes in < 5 seconds
- Large modules (battlescape) in < 2 seconds
- Individual file tests in < 500ms
- Coverage analysis adds < 2x overhead

---

## Notes

- Framework is **standalone** and self-contained
- **No external dependencies** beyond Love2D
- **Backward compatible** with existing test format
- **Extensible** for future test types
- **Performance-optimized** for quick feedback

---

## Blockers

None identified.

---

## Review Checklist

- [ ] Framework design complete and documented
- [ ] Core framework implementation complete
- [ ] Test organization structure created
- [ ] All execution mechanisms implemented
- [ ] Code coverage implementation working
- [ ] Documentation complete and comprehensive
- [ ] All 200+ tests migrated to new structure
- [ ] All tests passing with new framework
- [ ] Performance benchmarks within targets
- [ ] Coverage analysis accurate
- [ ] Helper methods documented
- [ ] Quick-start guide created
- [ ] FAQ documentation complete
- [ ] Backward compatibility verified

---

## Post-Completion

### What Worked Well
- Hierarchical organization makes tests easy to find
- Multiple execution levels provide flexibility
- Code coverage enables quality tracking
- Comprehensive assertions reduce boilerplate

### What Could Be Improved
- Consider adding parallel test execution
- Consider adding watch mode for development
- Consider adding snapshot testing for UI
- Consider adding mutation testing

### Lessons Learned
- Granular organization helps with test maintenance
- Clear documentation reduces test writing time
- Coverage analysis identifies dead code
- Helper methods reduce test boilerplate

---

## Time Estimate Summary

| Phase | Duration | Total |
|-------|----------|-------|
| 1. Framework Design | 6h | 6h |
| 2. Core Framework | 12h | 18h |
| 3. Organization | 8h | 26h |
| 4. Execution Mechanisms | 7h | 33h |
| 5. Coverage Implementation | 6h | 39h |
| 6. Documentation | 6h | 45h |
| 7. Migration & Validation | 8h | 53h |
| 8. Testing & Docs | 7h | 60h |
| **Total** | **60h** | **60h** |

**Estimated Total Time: 60 hours (8 days at 8h/day)**
