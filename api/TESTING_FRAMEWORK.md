# Enhanced Hierarchical Testing Framework

**Status:** ✅ IMPLEMENTED
**Framework Type:** Hierarchical test organization, discovery, and reporting
**Test Categories:** Unit, Integration, System, Performance, Acceptance
**Coverage Tracking:** Available with `TEST_COVERAGE=1`

---

## Overview

The Enhanced Hierarchical Testing Framework provides:
- **Test Organization:** 5-tier hierarchy (unit, integration, system, performance, acceptance)
- **Test Discovery:** Automatic test registration and categorization
- **Advanced Reporting:** Detailed test results with statistics and performance metrics
- **Coverage Tracking:** Optional code coverage analysis
- **Assertion Helpers:** Comprehensive assertions for test validation
- **Performance Analysis:** Slowest test identification and tracking

---

## Architecture

### Framework Structure

```
TestFramework (core)
├── Test Registry
│   ├── Suite management
│   ├── Test registration
│   └── Result tracking
├── Test Hierarchy
│   ├── Unit tests
│   ├── Integration tests
│   ├── System tests
│   ├── Performance tests
│   └── Acceptance tests
├── Statistics
│   ├── Category breakdown
│   ├── Module coverage
│   ├── Slowest tests
│   └── Failure analysis
└── Reporting
    ├── Console output
    ├── Performance metrics
    ├── Coverage report
    └── Failure summary
```

### Test Hierarchy

#### Unit Tests (`tests/unit/`)
- **Purpose:** Test individual functions and modules
- **Scope:** Single module, no external dependencies
- **Speed:** Very fast (< 100ms per test)
- **Example:** Testing individual functions in isolation

#### Integration Tests (`tests/integration/`)
- **Purpose:** Test system interactions and data flow
- **Scope:** Multiple modules working together
- **Speed:** Fast (< 1s per test)
- **Example:** Testing module communication

#### System Tests (`tests/battlescape/`, `tests/geoscape/`)
- **Purpose:** Test complete game systems
- **Scope:** Full system with all dependencies
- **Speed:** Moderate (< 5s per test)
- **Example:** Testing entire battle resolution

#### Performance Tests (`tests/performance/`)
- **Purpose:** Benchmark critical systems
- **Scope:** Performance characteristics and optimization
- **Speed:** Variable (can be longer)
- **Example:** Testing memory usage under load

#### Acceptance Tests (`tests/acceptance/`)
- **Purpose:** Test user-facing functionality
- **Scope:** Game features as user sees them
- **Speed:** Slow (> 5s per test)
- **Example:** Testing complete gameplay scenarios

---

## API Reference

### Core Framework Functions

#### Initialization

```lua
TestFramework.init()
```
Initialize the test framework. Must be called before registering tests.

**Configuration:**
```lua
TestFramework.config.verbose = true              -- Detailed output
TestFramework.config.strict_mode = false         -- Strict assertions
TestFramework.config.coverage_enabled = true     -- Coverage tracking
TestFramework.config.output_format = "console"   -- Output format
TestFramework.config.max_parallel_tests = 4      -- Parallel execution
```

#### Test Registration

```lua
TestFramework.registerSuite(name, category, tests)
```
Register a test suite.

**Parameters:**
- `name` (string): Suite name
- `category` (string): One of: unit, integration, system, performance, acceptance
- `tests` (table): Array of test definitions

**Returns:** Suite object

**Example:**
```lua
TestFramework.registerSuite("Math Operations", "unit", {
    {name = "addition", func = testAddition},
    {name = "subtraction", func = testSubtraction},
})
```

#### Running Tests

```lua
TestFramework.runAll()
```
Run all registered tests.

```lua
TestFramework.runCategory(category)
```
Run tests in a specific category.

**Parameters:**
- `category` (string): Category to run

**Returns:** Array of suite results

```lua
TestFramework.runSuite(suite_name)
```
Run a specific test suite.

**Parameters:**
- `suite_name` (string): Suite to run

**Returns:** Suite result object

```lua
TestFramework.runTest(test, suite_name)
```
Run a single test.

**Parameters:**
- `test` (table): Test definition
- `suite_name` (string): Parent suite name

**Returns:** Test result object

#### Reporting

```lua
TestFramework.generateReport()
```
Generate comprehensive test report.

**Returns:**
```lua
{
    total = number,         -- Total tests
    passed = number,        -- Passed tests
    failed = number,        -- Failed tests
    skipped = number,       -- Skipped tests
    duration = number,      -- Total duration in seconds
}
```

#### Results Retrieval

```lua
TestFramework.getResults()
```
Get all test results.

```lua
TestFramework.getSuiteResults(suite_name)
```
Get results for a specific suite.

```lua
TestFramework.getFailedTests()
```
Get all failed tests with errors.

---

### Assertion Functions

#### Basic Assertions

```lua
TestFramework.assert(condition, message)
```
Assert that condition is true.

```lua
TestFramework.assertEqual(actual, expected, message)
```
Assert that actual equals expected.

```lua
TestFramework.assertNotNil(value, message)
```
Assert that value is not nil.

```lua
TestFramework.assertType(value, expected_type, message)
```
Assert that value is of expected type.

**Example Usage:**
```lua
function testMathOperations()
    local result = 2 + 2
    TestFramework.assertEqual(result, 4, "Addition failed")
    TestFramework.assert(result > 0, "Result should be positive")
end
```

---

## Test Development Guide

### Writing a Test Suite

#### Step 1: Create Test File

```lua
-- tests/unit/my_module_test.lua

local MyModule = require("engine.my_system.my_module")
local TestFramework = require("engine.core.test_framework")

local TestSuite = {}

-- Setup executed before each test
function TestSuite.setup()
    -- Initialize test state
end

-- Teardown executed after each test
function TestSuite.teardown()
    -- Clean up after test
end

-- Individual test functions
function TestSuite.test_basic_functionality()
    local result = MyModule.doSomething()
    TestFramework.assertEqual(result, expected, "Basic test failed")
end

function TestSuite.test_error_handling()
    local ok, err = pcall(MyModule.invalidCall)
    TestFramework.assert(not ok, "Should have thrown error")
end

return TestSuite
```

#### Step 2: Register Tests

```lua
-- In test runner or initialization
TestFramework.registerSuite("My Module", "unit", {
    {name = "basic_functionality", func = TestSuite.test_basic_functionality},
    {name = "error_handling", func = TestSuite.test_error_handling},
})
```

#### Step 3: Run Tests

```lua
local results = TestFramework.runSuite("My Module")
print("Tests passed: " .. results.passed .. "/" .. results.total)
```

### Best Practices

**✅ Do:**
- Test one thing per test
- Use descriptive test names (`test_should_calculate_damage_correctly`)
- Set up and tear down properly
- Test both success and failure paths
- Use clear assertions with messages
- Document complex test logic
- Test edge cases and boundaries
- Keep tests fast and isolated

**❌ Don't:**
- Test multiple things per test
- Use vague test names (`test_stuff`)
- Skip setup/teardown
- Only test happy path
- Make tests dependent on each other
- Write slow or complex tests
- Test implementation details
- Ignore error conditions

### Test Naming Conventions

Use descriptive names that indicate what is being tested:

```lua
TestFramework.registerSuite("Unit Math Operations", "unit", {
    {name = "test_addition_with_positive_numbers", func = ...},
    {name = "test_subtraction_with_negative_result", func = ...},
    {name = "test_division_by_zero_throws_error", func = ...},
})
```

### Test Organization

Organize by system and layer:

```
tests/
├── unit/                    -- Individual function tests
│   ├── test_math_utils.lua
│   ├── test_array_utils.lua
│   └── test_string_utils.lua
├── integration/             -- Multi-module tests
│   ├── test_combat_flow.lua
│   ├── test_base_flow.lua
│   └── test_economy_flow.lua
├── system/                  -- Full system tests
│   ├── battlescape/
│   ├── geoscape/
│   └── basescape/
├── performance/             -- Benchmark tests
│   ├── test_rendering_perf.lua
│   └── test_ai_perf.lua
└── acceptance/              -- User scenario tests
    ├── test_complete_battle.lua
    └── test_campaign_flow.lua
```

---

## Running Tests

### From Command Line

```bash
# Run all tests
lovec tests/runners/hierarchical_runner.lua

# Run specific category
lovec tests/runners/hierarchical_runner.lua unit
lovec tests/runners/hierarchical_runner.lua integration
lovec tests/runners/hierarchical_runner.lua system
lovec tests/runners/hierarchical_runner.lua performance
```

### With Coverage Tracking

```bash
# Windows PowerShell
$env:TEST_COVERAGE=1; & 'C:\Program Files\LOVE\lovec.exe' tests/runners/hierarchical_runner.lua

# Windows Command Prompt
set TEST_COVERAGE=1 && "C:\Program Files\LOVE\lovec.exe" tests/runners/hierarchical_runner.lua
```

### In Test Suite

```lua
local TestFramework = require("engine.core.test_framework")

TestFramework.init()
TestFramework.registerSuite("My Tests", "unit", {...})
TestFramework.runAll()
local report = TestFramework.generateReport()
```

---

## Output and Reporting

### Console Output Example

```
======================================================================
TEST FRAMEWORK INITIALIZATION
======================================================================

✓ Verbose mode: ON
✓ Strict mode: OFF
✓ Coverage tracking: DISABLED
✓ Output format: console
✓ Max parallel tests: 4

----------------------------------------------------------------------

Running suite: State Manager (unit)
----------------------------------------------------------------------
  ✓ test_initialization
  ✓ test_state_transitions
  ✓ test_error_handling
  ✗ test_edge_cases
    Error: Assertion failed: Should handle nil state

Suite result: 3/4 passed (75.0%) in 0.045s

======================================================================
TEST REPORT
======================================================================

Total Tests: 42
  ✓ Passed: 40 (95.2%)
  ✗ Failed: 2 (4.8%)
  ⊘ Skipped: 0 (0.0%)

Execution Time: 2.341 seconds

----------------------------------------------------------------------
SLOWEST TESTS (Top 10)
----------------------------------------------------------------------
 1. 0.523s - integration::test_combat_resolution
 2. 0.387s - system::test_battle_completion
 3. 0.156s - performance::test_ai_pathfinding
...

----------------------------------------------------------------------
RESULTS BY CATEGORY
----------------------------------------------------------------------
  unit: 20/20 passed (100%)
  integration: 12/14 passed (85.7%)
  system: 8/8 passed (100%)
  performance: 4/4 passed (100%)
  acceptance: 0/0 passed

======================================================================
```

---

## Statistics and Metrics

### Available Metrics

The framework tracks:

- **Count metrics:** Total, passed, failed, skipped tests
- **Performance metrics:** Duration per test and suite
- **Category breakdown:** Results by test category
- **Module coverage:** Which modules are tested
- **Slowest tests:** Longest-running tests for optimization
- **Failure patterns:** Which tests fail most often

### Accessing Metrics

```lua
local results = TestFramework.getResults()
print("Pass rate: " .. (results.passed / results.total_tests * 100) .. "%")

local failed = TestFramework.getFailedTests()
for _, test in ipairs(failed) do
    print("Failed: " .. test.suite .. "::" .. test.test)
    print("Error: " .. test.error)
end
```

---

## Integration with Existing Tests

### Migrating Existing Tests

To migrate existing tests to the new framework:

```lua
-- Old test structure
local TestOld = {}
function TestOld.runAll()
    -- Run tests
end
return TestOld

-- New test structure
local TestNew = {}
function TestNew.test_something()
    -- Individual test
end
return TestNew

-- In runner
local TestFramework = require("engine.core.test_framework")
TestFramework.registerSuite("My Tests", "unit", {
    {name = "test_something", func = TestNew.test_something},
})
```

### Compatibility Layer

The framework maintains compatibility with existing tests:
- Old `runAll()` functions still work
- Can be wrapped in new framework
- Gradual migration possible
- No breaking changes to existing test code

---

## Advanced Features

### Test Options

```lua
TestFramework.registerTest(suite_name, test_name, test_func, {
    skip = false,                   -- Skip this test
    timeout = 5000,                -- Timeout in milliseconds
    severity = "normal",            -- normal, critical, low
    tags = {"slow", "network"},    -- Test tags
    setup = setupFunction,          -- Setup function
    teardown = teardownFunction,    -- Teardown function
})
```

### Coverage Analysis

With `TEST_COVERAGE=1`:

```lua
local coverage = TestFramework.coverage
print("Modules tested: " .. #coverage.modules_tested)
print("Functions covered: " .. #coverage.functions_covered)
```

### Performance Optimization

Framework identifies slowest tests:

```lua
local results = TestFramework.stats.slowest_tests
for i, test in ipairs(results) do
    if i <= 10 then
        print(string.format("Test %d: %.3fs - %s", i, test.duration, test.name))
    end
end
```

---

## Configuration

### Framework Configuration

```lua
TestFramework.config = {
    verbose = true,              -- Detailed console output
    strict_mode = false,         -- Strict assertion checking
    coverage_enabled = false,    -- Code coverage tracking
    output_format = "console",   -- Output format (console, json, xml)
    max_parallel_tests = 4,      -- Maximum parallel test execution
}
```

### Environment Variables

```bash
TEST_COVERAGE=1     # Enable coverage tracking
TEST_VERBOSE=1      # Enable verbose output
TEST_STRICT=1       # Enable strict mode
```

---

## Troubleshooting

### Tests Not Registering

Check that:
- Test functions exist and are callable
- Suite name is correct
- Category is valid (unit, integration, system, performance, acceptance)
- TestFramework.init() was called first

### Tests Running Slowly

- Check for external I/O operations
- Profile with TEST_PROFILE=1
- Review slowest tests list
- Consider moving to performance category

### Coverage Not Collecting

- Set TEST_COVERAGE=1 environment variable
- Coverage tracking is disabled by default
- Check console for coverage data

---

## Performance Targets

| Test Type | Target Speed | Max Duration |
|-----------|--------------|--------------|
| Unit | < 100ms | 1s |
| Integration | < 1s | 5s |
| System | < 5s | 30s |
| Performance | variable | N/A |
| Acceptance | variable | N/A |

---

## See Also

- `tests/README.md` - General testing guide
- `tests/TEST_DEVELOPMENT_GUIDE.md` - Test writing guide
- `engine/core/test_framework.lua` - Framework source code
- `tests/runners/hierarchical_runner.lua` - Enhanced runner

---

## Summary

The Enhanced Hierarchical Testing Framework provides:

✅ **Organization:** 5-tier test hierarchy
✅ **Discovery:** Automatic test registration
✅ **Reporting:** Detailed statistics and metrics
✅ **Performance:** Slowest test identification
✅ **Coverage:** Optional code coverage tracking
✅ **Assertions:** Comprehensive helper functions
✅ **Integration:** Compatible with existing tests
✅ **Extensibility:** Easy to add new features

Ready for production use and continuous expansion!
