# Test Framework Architecture Design

**Version:** 2.0
**Last Updated:** October 24, 2025
**Status:** Complete

---

## Overview

The new testing framework provides a hierarchical, modular test organization system with multiple execution levels, comprehensive code coverage analysis, and detailed reporting capabilities.

---

## Architecture Components

### 1. Test Registry
**Purpose**: Central storage and discovery of all tests
**Location**: `tests/framework/test_registry.lua`

- Hierarchical storage (root → module → file → test)
- Dynamic test registration
- Metadata tracking (test name, description, fixtures)
- Module discovery and scanning
- Test filtering and selection

### 2. Test Executor
**Purpose**: Execute tests at multiple levels
**Location**: `tests/framework/test_executor.lua`

Execution modes:
- Full suite (all tests)
- Module level (e.g., battlescape module)
- File level (e.g., all tests for combat system)
- Specific test (single test by name)
- Tag-based (tests tagged with keywords)

### 3. Assertion Library
**Purpose**: Provide comprehensive testing assertions
**Location**: `tests/framework/assertions.lua`

- 20+ built-in assertions
- Descriptive error messages
- Custom assertion support
- Assert stack traces

### 4. Test Case Base
**Purpose**: Base class for all tests
**Location**: `tests/framework/test_case.lua`

Features:
- Setup/teardown fixtures (per-test, per-suite)
- Before/after hooks
- Test grouping/suites
- Assertion tracking

### 5. Code Coverage System
**Purpose**: Track and report code coverage
**Location**: `tests/framework/coverage_analyzer.lua`

Metrics:
- Line coverage by file/module
- Function coverage
- Branch coverage (if/else)
- Coverage reports (HTML, JSON, text)

### 6. Report Generator
**Purpose**: Generate test and coverage reports
**Location**: `tests/framework/report_generator.lua`

Report types:
- Text summary (console)
- JSON structured data
- HTML interactive reports
- Coverage reports with highlights

---

## Hierarchical Structure

### Registry Organization

```
TestRegistry
├── battlescape (module)
│   ├── combat (sub-module)
│   │   ├── test_file_1
│   │   │   ├── test_1
│   │   │   └── test_2
│   │   └── test_file_2
│   │       └── test_3
│   └── rendering (sub-module)
│       └── test_file_3
│           └── test_4
├── geoscape (module)
│   └── ...
└── core (module)
    └── ...
```

### Execution Flow

```
Input: Execution Mode
    ↓
Discover Tests (via Registry)
    ↓
Load Test Modules
    ↓
Apply Filters (if specified)
    ↓
For Each Test:
  - Run Setup Fixtures
  - Execute Test
  - Record Results
  - Run Teardown Fixtures
  - Capture Assertions
    ↓
Generate Coverage Data (if enabled)
    ↓
Generate Reports
    ↓
Output Results
```

---

## Test Case Format

### Old Format (Legacy)

```lua
function test_something()
  -- test code
end

function runAll()
  test_something()
end
```

### New Format (Recommended)

```lua
local TestSuite = require "tests.framework.test_suite"
local suite = TestSuite:new("MyModule")

suite:test("should do something", function()
  local result = functionUnderTest()
  assertEqual(result, expected_value)
end)

suite:describe("feature group", function()
  suite:test("test 1", function()
    -- test
  end)

  suite:test("test 2", function()
    -- test
  end)
end)

return suite
```

---

## Coverage Analysis

### Coverage Tracking

Uses Lua `debug.sethook()` to track:
- Which lines are executed
- Which functions are called
- Which branches are taken

### Coverage Metrics

```
Line Coverage: 87.3% (245/281 lines)
Function Coverage: 92.1% (58/63 functions)
Branch Coverage: 78.5% (31/39 branches)

By Module:
- battlescape: 89.2%
- geoscape: 85.1%
- core: 91.3%
- utils: 76.4%

Uncovered Lines:
- engine/battlescape/combat/abilities.lua:42-45 (error handling)
- engine/geoscape/logic/world.lua:128-135 (rare case)
```

---

## Execution Levels

### 1. Full Suite
```bash
lovec tests/runners/main.lua
```
Runs all tests, generates full report, code coverage.

### 2. Module
```bash
lovec tests/runners/main.lua battlescape
```
Runs all tests in battlescape module (combat, rendering, etc.)

### 3. File
```bash
lovec tests/runners/main.lua battlescape combat
```
Runs all tests for a specific file (combat system)

### 4. Specific Test
```bash
lovec tests/runners/main.lua battlescape combat test_damage_calculation
```
Runs a specific test by name

### 5. By Tag
```bash
lovec tests/runners/main.lua --tag regression
```
Runs all tests tagged with "regression"

---

## Helper Methods

### Test Suite API

```lua
local suite = TestSuite:new("ModuleName")

-- Register test
suite:test("test name", function()
  -- test code
end)

-- Describe block for grouping
suite:describe("feature", function()
  suite:test("test 1", function() end)
  suite:test("test 2", function() end)
end)

-- Fixtures
suite:before(function() end)        -- Before all tests
suite:after(function() end)         -- After all tests
suite:beforeEach(function() end)    -- Before each test
suite:afterEach(function() end)     -- After each test

-- Tag test
suite:test("test", {tag = "regression"}, function() end)

-- Skip test
suite:skip("test name", function() end)

-- Run suite
suite:run()

return suite
```

### Assertion API

```lua
assertEqual(actual, expected, message)
assertNotEqual(actual, expected, message)
assertTrue(condition, message)
assertFalse(condition, message)
assertIsNil(value, message)
assertIsNotNil(value, message)
assertIsTable(value, message)
assertIsFunction(value, message)
assertIsString(value, message)
assertIsNumber(value, message)
assertContains(table, value, message)
assertNotContains(table, value, message)
assertTableEquals(table1, table2, message)
assertGreater(a, b, message)
assertLess(a, b, message)
assertMatches(string, pattern, message)
assertThrows(function, expectedError, message)
assertDoesNotThrow(function, message)
```

---

## Report Structure

### Test Report

```
Test Execution Report
====================

Configuration:
- Framework Version: 2.0
- Execution Date: 2025-10-24 15:32:00
- Execution Mode: full
- Coverage Enabled: yes

Summary:
- Total Tests: 287
- Passed: 279 (97.2%)
- Failed: 6 (2.1%)
- Skipped: 2 (0.7%)
- Duration: 3.24 seconds

By Module:
- battlescape: 89/92 passed (96.7%)
- geoscape: 124/128 passed (96.9%)
- core: 56/58 passed (96.6%)
- unit: 10/11 passed (90.9%)

Failed Tests:
1. battlescape > combat > test_critical_hit_calculation
   Error: Expected 150, got 140
   File: engine/battlescape/combat/abilities.lua:42
   Stack: test_abilities.lua:127

2. geoscape > world > test_resource_generation
   Error: Resource count mismatch
   File: engine/geoscape/logic/world.lua:89
   Stack: test_world.lua:203

[... more failed tests ...]

Code Coverage:
- Line Coverage: 87.3%
- Function Coverage: 92.1%
- Branch Coverage: 78.5%

Uncovered Lines:
- engine/battlescape/rendering/view_3d.lua:45-52 (error handling)
- engine/geoscape/ai/decision_maker.lua:128-135 (rare case)
```

### Coverage Report

```html
<html>
<head><title>Code Coverage Report</title></head>
<body>

<h1>Code Coverage Analysis</h1>

<table>
  <tr>
    <th>Module</th>
    <th>Lines</th>
    <th>Coverage</th>
  </tr>
  <tr class="highlight">
    <td>battlescape</td>
    <td>245/281</td>
    <td style="background: #90EE90">87.2%</td>
  </tr>
  <!-- ... -->
</table>

<h2>Uncovered Code Paths</h2>
<pre>
engine/battlescape/combat/abilities.lua:42-45
  if errorCondition then
    -- This error case is not tested
    ...
  end
</pre>

</body>
</html>
```

---

## Integration Points

### With Game Engine

The test framework integrates with the game engine through:

1. **Module Loading**: Uses Love2D's require() for test discovery
2. **State Access**: Tests can query/modify game state
3. **Rendering**: Can capture screenshots for UI tests
4. **Input Simulation**: Can simulate player input for integration tests

### With CI/CD

- Generate JSON reports for tool parsing
- Return exit codes (0 = success, 1 = failure)
- Support command-line arguments for test selection
- Enable performance benchmarking

### With Mock Framework

Tests use mock data from `tests/mock/` for:
- Unit test data
- Fixture creation
- Database simulation

---

## Configuration

### Config File: `tests/framework/config.lua`

```lua
return {
  -- Coverage
  coverage_enabled = os.getenv("TEST_COVERAGE") == "1",
  coverage_format = "json",  -- json, html, text

  -- Performance
  timeout_seconds = 30,
  max_failures_before_stop = 0,  -- 0 = no limit

  -- Reporting
  report_format = {"text", "json", "html"},
  report_dir = "tests/reports",

  -- Filtering
  exclude_tags = {"slow", "wip"},

  -- Parallel execution (false for now)
  parallel_execution = false,
}
```

---

## File Organization

```
tests/
├── framework/                    -- Framework implementation
│   ├── config.lua               -- Configuration
│   ├── test_registry.lua        -- Test discovery and registry
│   ├── test_executor.lua        -- Test execution engine
│   ├── test_case.lua            -- Base test case class
│   ├── test_suite.lua           -- Test suite grouping
│   ├── assertions.lua           -- Assertion library
│   ├── fixtures.lua             -- Setup/teardown fixtures
│   ├── coverage_analyzer.lua    -- Code coverage tracking
│   ├── report_generator.lua     -- Report generation
│   ├── test_helpers.lua         -- Helper methods
│   └── README.md                -- Framework documentation
│
├── runners/                      -- Test runners
│   ├── main.lua                 -- Main entry point
│   ├── run_all.lua              -- Run all tests
│   ├── run_module.lua           -- Run by module
│   ├── run_file.lua             -- Run by file
│   ├── run_specific.lua         -- Run specific test
│   └── README.md                -- Runner documentation
│
├── unit/                        -- Unit tests (organized by module)
├── integration/                 -- Integration tests
├── performance/                 -- Performance benchmarks
├── mock/                        -- Mock data
└── README.md                    -- Master test documentation
```

---

## Design Principles

1. **Hierarchical**: Tests organized by module/file/test
2. **Flexible**: Multiple execution modes and filtering
3. **Discoverable**: Automatic test discovery
4. **Measurable**: Code coverage tracking
5. **Informative**: Detailed reports and stack traces
6. **Backward Compatible**: Works with existing tests
7. **Extensible**: Can add new assertions/reporters
8. **Fast**: Minimal overhead during execution

---

## Backwards Compatibility

The new framework supports the old test format:

```lua
-- Old format still works
function test_something()
  assert(condition)
end

function runAll()
  test_something()
end
```

But new tests should use the recommended format.

---

## Next Steps

1. Implement core framework components (Phase 2)
2. Organize tests into hierarchical structure (Phase 3)
3. Implement multiple execution modes (Phase 4)
4. Implement code coverage (Phase 5)
5. Create documentation and helpers (Phase 6)
6. Migrate existing tests (Phase 7)
7. Test framework itself (Phase 8)
