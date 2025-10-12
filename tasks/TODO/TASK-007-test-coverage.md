# Task: Test Coverage Improvement

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Expand test coverage for GUI widgets, mod loader, mod manager, battlescape, and supporting classes. Create comprehensive test suites to ensure reliability and catch regressions.

---

## Purpose

Improve code quality and maintainability through comprehensive testing. Enable confident refactoring and feature additions. Catch bugs early in development cycle.

---

## Requirements

### Functional Requirements
- [ ] Test coverage for all widget types
- [ ] Test coverage for mod loading system
- [ ] Test coverage for battlescape core systems
- [ ] Test coverage for supporting classes (Unit, Team, etc.)
- [ ] Integration tests for complete workflows
- [ ] Performance regression tests

### Technical Requirements
- [ ] Tests use Love2D testing framework
- [ ] Tests are automated and repeatable
- [ ] Mock data used where appropriate
- [ ] Tests run in CI-friendly manner
- [ ] Test reports generated
- [ ] Coverage metrics tracked

### Acceptance Criteria
- [ ] 80%+ coverage for widgets
- [ ] 90%+ coverage for mod system
- [ ] 70%+ coverage for battlescape
- [ ] All tests pass
- [ ] Test suite runs in <30 seconds
- [ ] No false positives/negatives
- [ ] Tests documented

---

## Plan

### Step 1: Audit Current Test Coverage
**Description:** Analyze existing tests and identify gaps  
**Files to analyze:**
- `engine/widgets/tests/`
- `engine/tests/`
- All modules that need testing

**Estimated time:** 1 hour

### Step 2: Widget Test Suite Expansion
**Description:** Create/expand tests for all widgets  
**Files to create/modify:**
- Test file for each widget in `engine/widgets/tests/`
- Minimum 10 test cases per widget

**Test categories:**
- Constructor tests
- Grid alignment tests
- Event handling tests
- Theme application tests
- State management tests
- Edge case tests

**Estimated time:** 4 hours

### Step 3: Mod System Test Suite
**Description:** Comprehensive tests for mod loading  
**Files to create:**
- `engine/tests/test_mod_manager.lua`
- `engine/tests/test_data_loader.lua`
- `engine/tests/test_mod_loading.lua`

**Test categories:**
- Mod discovery
- TOML parsing
- Content path resolution
- Active mod setting
- Multi-mod loading
- Error handling

**Estimated time:** 2 hours

### Step 4: Battlescape Test Suite
**Description:** Tests for battlescape systems  
**Files to create/modify:**
- `engine/tests/test_battlescape.lua`
- `engine/tests/test_unit.lua`
- `engine/tests/test_team.lua`
- `engine/tests/test_action_system.lua`

**Test categories:**
- Unit creation and management
- Team operations
- Action execution
- Turn management
- Pathfinding
- Line of sight
- Map generation

**Estimated time:** 3 hours

### Step 5: Integration Test Suite
**Description:** End-to-end workflow tests  
**Files to create:**
- `engine/tests/test_integration.lua`

**Test scenarios:**
- Full game startup
- Mod loading → asset loading → battlescape
- Complete tactical turn
- Save/load workflow
- Map editor workflow

**Estimated time:** 2 hours

### Step 6: Performance Regression Tests
**Description:** Ensure optimizations don't regress  
**Files to create:**
- `engine/tests/test_performance_regression.lua`

**Benchmarks:**
- Battlescape initialization time
- LOS calculation performance
- Pathfinding performance
- Rendering FPS
- Memory usage

**Estimated time:** 1.5 hours

### Step 7: Test Runner Enhancement
**Description:** Improve test runner with reporting  
**Files to modify:**
- `engine/tests/test_runner.lua`

**Features:**
- Color-coded output
- Progress indicators
- Detailed failure reports
- Coverage metrics
- Performance timing
- JSON report output

**Estimated time:** 2 hours

### Step 8: Documentation and CI Setup
**Description:** Document testing and prepare for CI  
**Files to create/modify:**
- `wiki/TESTING.md` (comprehensive guide)
- `engine/tests/README.md`
- CI configuration (future)

**Estimated time:** 1 hour

---

## Implementation Details

### Test Structure
```lua
-- Test file template
local TestCase = {}

function TestCase.setup()
    -- Setup before each test
end

function TestCase.teardown()
    -- Cleanup after each test
end

function TestCase.test_description()
    -- Arrange
    local widget = Widget.new(0, 0, 96, 48)
    
    -- Act
    widget:update(0.016)
    
    -- Assert
    assert(widget.x == 0, "X position should be 0")
    assert(widget.y == 0, "Y position should be 0")
end

return TestCase
```

### Mock Data Strategy
Use `widgets.mock_data` for:
- Sample units
- Sample terrain
- Sample maps
- Sample items

### Test Categories

#### Unit Tests (Isolated)
- Test individual functions
- Mock external dependencies
- Fast execution
- No file I/O

#### Integration Tests
- Test component interactions
- Use real dependencies
- May involve file I/O
- Test complete workflows

#### Performance Tests
- Measure execution time
- Check memory usage
- Compare against baselines
- Detect regressions

### Key Components

**Enhanced Test Runner:**
```lua
local TestRunner = {
    suites = {},
    results = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {}
    },
    timing = {}
}

function TestRunner.runSuite(name, suite)
    -- Run all tests in suite
    -- Collect results
    -- Report findings
end

function TestRunner.generateReport()
    -- Output detailed results
    -- Save to temp directory
end
```

### Coverage Tracking
```lua
local Coverage = {
    files = {},
    lines = {}
}

function Coverage.track(file, line)
    -- Track which lines execute during tests
end

function Coverage.report()
    -- Calculate coverage percentage
    -- Generate report
end
```

### Dependencies
- Love2D testing framework
- Mock data generator
- Assertion library
- Test report generator

---

## Testing Strategy

### Test Pyramid
- **70% Unit Tests:** Fast, isolated, many
- **20% Integration Tests:** Component interactions
- **10% E2E Tests:** Full workflows

### Critical Areas
- **Mod Loading:** Must work 100%
- **Battlescape Core:** High complexity
- **Widget System:** User-facing
- **LOS/Pathfinding:** Performance critical

### Test Data
- Use mock data for speed
- Create test fixtures
- Store test maps in `engine/tests/fixtures/`

### Continuous Testing
- Run tests before commits
- Run tests in CI pipeline
- Nightly performance tests
- Weekly full regression

---

## How to Run/Debug

### Running All Tests
```bash
lovec "engine" --test
# Or from menu: Tests → Run All Tests
```

### Running Specific Suite
```lua
-- In tests_menu.lua
TestRunner.runSuite("widgets", require("widgets.tests.test_button"))
```

### Running Single Test
```lua
local test = require("widgets.tests.test_button")
test.test_button_creation()
```

### Debugging Failed Tests
- Check console for assertion failures
- Use `print()` in tests to trace execution
- Run single test in isolation
- Check mock data setup
- Verify test environment

### Console Output
```
[TestRunner] Starting test suite: widgets
[TestRunner] Running: test_button_creation... PASS (2ms)
[TestRunner] Running: test_button_click... PASS (1ms)
[TestRunner] Running: test_button_disabled... PASS (1ms)
[TestRunner] Suite widgets: 3/3 passed (4ms total)

=== Test Summary ===
Total: 45 tests
Passed: 43 (95.6%)
Failed: 2 (4.4%)
Skipped: 0
Time: 234ms
```

### Test Reports
Save reports to:
```lua
local tempDir = os.getenv("TEMP")
local reportPath = tempDir .. "\\test_report.json"
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `wiki/TESTING.md` - Comprehensive testing guide
- [ ] `wiki/DEVELOPMENT.md` - Add testing to workflow
- [ ] `engine/tests/README.md` - How to write tests
- [ ] `wiki/API.md` - Note tested components

---

## Notes

- Consider using LuaCov for coverage analysis
- May want to add screenshot comparison tests
- Could add fuzzing for robustness
- Think about property-based testing

---

## Blockers

None. Test infrastructure already exists.

---

## Review Checklist

- [ ] Tests cover critical functionality
- [ ] All tests pass reliably
- [ ] No flaky tests
- [ ] Tests run quickly (<30s)
- [ ] Mock data used appropriately
- [ ] Test reports generated
- [ ] Coverage metrics calculated
- [ ] Documentation complete
- [ ] Test runner enhanced
- [ ] Console output clear

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
