# 🔧 Framework Documentation

**Tests2 Core Framework Components**

---

## 📦 Components

### 1. HierarchicalSuite (hierarchical_suite.lua)

Base class for organizing tests with 3-level hierarchy.

**Responsibility:** Organize and execute tests with clear hierarchy

**Key Methods:**

```lua
local suite = HierarchicalSuite:new({
  modulePath = "engine.core.state_manager",
  description = "State management tests"
})

suite:before(fn)         -- Setup before all tests
suite:after(fn)          -- Teardown after all tests
suite:beforeEach(fn)     -- Setup before each test
suite:afterEach(fn)      -- Teardown before each test

suite:group(name, fn)    -- Group tests for organization

suite:testMethod(name, config, fn)  -- Define test for method
suite:test(name, fn)     -- Simple test (alias)
suite:skip(name, fn)     -- Skip test

suite:run()              -- Execute all tests

suite:getResults()       -- Get test results
suite:getCoverage()      -- Get coverage data
```

**Example:**

```lua
local suite = HierarchicalSuite:new({
  modulePath = "engine.core.state_manager",
  description = "State management tests"
})

suite:group("Initialization", function()
  suite:testMethod("StateManager:new", {
    description = "Creates instance",
    testCase = "happy_path"
  }, function()
    local mgr = StateManager:new()
    assert(mgr ~= nil)
  end)
end)

suite:run()
```

---

### 2. CoverageCalculator (coverage_calculator.lua)

Tracks test coverage across 3 levels: module, file, method.

**Responsibility:** Calculate and track coverage metrics

**Key Methods:**

```lua
local calc = CoverageCalculator:new()

-- LEVEL 1: Module
calc:registerModule(modulePath, totalFunctions)
calc:markFunctionTested(modulePath, functionName)
calc:getModuleCoverage(modulePath)           -- {percentage, total, tested, status}
calc:getAllModulesCoverage()                 -- sorted list

-- LEVEL 2: File
calc:registerFile(filePath, modulePath)
calc:updateFileResults(filePath, passed, failed, skipped, duration)
calc:getFileCoverage(filePath)               -- {passRate, total, passed, failed, status}

-- LEVEL 3: Method
calc:registerMethodTest(modulePath, methodName, testCase, passed)
calc:getMethodCoverage(modulePath, methodName)      -- {coverage, total, passed, testCases}
calc:getModuleMethodsCoverage(modulePath)           -- all methods for module

-- Overall
calc:getProjectCoverage()                   -- {percentage, modules_total, functions_tested}
calc:toJSON()                               -- export as JSON
```

**Example:**

```lua
local calc = CoverageCalculator:new()

-- Register module with 10 functions
calc:registerModule("engine.core.state_manager", 10)

-- Mark 7 as tested
calc:markFunctionTested("engine.core.state_manager", "StateManager:new")
calc:markFunctionTested("engine.core.state_manager", "StateManager:setState")
-- ... 5 more

-- Get coverage: 70%
local cov = calc:getModuleCoverage("engine.core.state_manager")
print(cov.percentage)  -- 70
```

---

### 3. HierarchyReporter (hierarchy_reporter.lua)

Generates comprehensive reports at all 3 levels.

**Responsibility:** Format and display coverage data

**Key Methods:**

```lua
local reporter = HierarchyReporter:new(coverage)

-- Individual reports
reporter:reportModules()                    -- LEVEL 1: Module coverage
reporter:reportFiles()                      -- LEVEL 2: File results
reporter:reportMethodsForModule(modulePath) -- LEVEL 3: Method coverage

-- Comprehensive report
reporter:reportHierarchy()                  -- All 3 levels combined

-- Export formats
reporter:toText()                           -- Plain text format
reporter:toJSON()                           -- JSON format
```

**Example:**

```lua
local reporter = HierarchyReporter:new(calc)
reporter:reportHierarchy()

-- Output:
-- ═══════════════════════════════════════════
-- HIERARCHICAL TEST COVERAGE REPORT
-- ═══════════════════════════════════════════
-- MODULE COVERAGE:
--   engine.core.state_manager [████████░░] 75%
-- ...
```

---

## 🔗 Data Flow

```
1. Define Tests
   └─ HierarchicalSuite.testMethod()

2. Execute Tests
   └─ HierarchicalSuite.run()
   └─ Calls each test function
   └─ Collects results

3. Track Coverage
   └─ CoverageCalculator:registerMethodTest()
   └─ CoverageCalculator:updateFileResults()
   └─ Aggregates coverage data

4. Generate Reports
   └─ HierarchyReporter.reportHierarchy()
   └─ Displays coverage at 3 levels
   └─ Identifies gaps
```

---

## 📊 Report Levels

### Level 1: Module Coverage

```
Answers: "What % of functions in this module are tested?"

engine.core.state_manager [████████░░] 75% (7/10 functions)
```

### Level 2: File Test Results

```
Answers: "What % of tests in this file passed?"

tests2/core/state_manager_test.lua: 14/15 passed (93%)
```

### Level 3: Method Coverage

```
Answers: "What test cases does this method have?"

StateManager:new ✓ 100% (3/3 test cases)
  ✓ happy_path
  ✓ error_handling
  ✓ edge_case
```

---

## 🎯 Integration Points

### With HierarchicalSuite

```lua
-- Suite collects test results
local suite = HierarchicalSuite:new(...)
suite:run()                          -- Tests execute
local results = suite:getResults()   -- Get results
local coverage = suite:getCoverage() -- Get coverage data
```

### With CoverageCalculator

```lua
-- Manually track coverage
local calc = CoverageCalculator:new()
calc:registerModule("engine.core.state_manager", 10)

-- After tests run:
for _, test in ipairs(suite:getTests()) do
  if test.status == "passed" then
    calc:markFunctionTested(suite.modulePath, test.methodName)
  end
end
```

### With HierarchyReporter

```lua
-- Generate reports from coverage data
local reporter = HierarchyReporter:new(calc)
reporter:reportHierarchy()

-- Or export data
local jsonData = reporter:toJSON()
love.filesystem.write("reports/coverage.json", jsonData)
```

---

## 🏗️ Best Practices

### 1. Setup/Teardown Pattern

```lua
suite:before(function()
  -- Module-level initialization
  -- Run ONCE before all tests
end)

suite:beforeEach(function()
  -- Per-test initialization
  -- Run before EACH test
  local testData = {}
end)

suite:testMethod(..., function()
  -- Test code
  -- Can use testData
end)

suite:afterEach(function()
  -- Per-test cleanup
  -- Run after EACH test
end)

suite:after(function()
  -- Module-level cleanup
  -- Run ONCE after all tests
end)
```

### 2. Test Organization

```lua
-- Organize by functionality
suite:group("Initialization", function() ... end)
suite:group("State Updates", function() ... end)
suite:group("Persistence", function() ... end)

-- Each group tests related methods
-- Makes reports more readable
```

### 3. Test Naming

```lua
-- Method name: ClassName:methodName
suite:testMethod("StateManager:new", ...)

-- Test case: happy_path, error_handling, edge_case
testCase = "happy_path"

-- Description: human-readable
description = "Creates new state manager instance"
```

### 4. Assertion Patterns

```lua
-- Use descriptive messages
assert(value ~= nil, "Value should not be nil")

-- Use helpers
Helpers.assertEqual(actual, expected, "Error message")
Helpers.assertThrows(fn, errorPattern, "Should throw")

-- Multiple assertions per test are OK if testing one thing
assert(counter ~= nil)
assert(counter.value == 0)
assert(type(counter) == "table")
```

---

## 🐛 Debugging

### Print Debug Output

```lua
suite:testMethod("Method:name", {...}, function()
  print("[DEBUG] Value is: " .. tostring(value))
  assert(condition)
end)
```

### Get Results Details

```lua
local results = suite:getResults()
print("Passed: " .. results.passed)
print("Failed: " .. results.failed)

for _, err in ipairs(results.errors) do
  print("Error in " .. err.test .. ": " .. err.error)
end
```

### Export Coverage for Analysis

```lua
local reporter = HierarchyReporter:new(calc)
local json = reporter:toJSON()

local file = io.open("reports/coverage.json", "w")
file:write(json)
file:close()
```

---

## 📝 API Reference

### HierarchicalSuite

| Method | Signature | Returns |
|--------|-----------|---------|
| new | `HierarchicalSuite:new(config)` | HierarchicalSuite |
| before | `suite:before(fn)` | nil |
| after | `suite:after(fn)` | nil |
| beforeEach | `suite:beforeEach(fn)` | nil |
| afterEach | `suite:afterEach(fn)` | nil |
| group | `suite:group(name, fn)` | nil |
| testMethod | `suite:testMethod(name, config, fn)` | nil |
| test | `suite:test(name, fn)` | nil |
| skip | `suite:skip(name, fn)` | nil |
| run | `suite:run()` | boolean (success) |
| getResults | `suite:getResults()` | table |
| getCoverage | `suite:getCoverage()` | table |
| getTests | `suite:getTests()` | table[] |
| getMethodTests | `suite:getMethodTests(methodName)` | table[] |

### CoverageCalculator

| Method | Signature | Returns |
|--------|-----------|---------|
| new | `CoverageCalculator:new()` | CoverageCalculator |
| registerModule | `calc:registerModule(path, count)` | nil |
| markFunctionTested | `calc:markFunctionTested(path, name)` | nil |
| getModuleCoverage | `calc:getModuleCoverage(path)` | table |
| getAllModulesCoverage | `calc:getAllModulesCoverage()` | table[] |
| registerFile | `calc:registerFile(path, module)` | nil |
| updateFileResults | `calc:updateFileResults(path, p, f, s, d)` | nil |
| getFileCoverage | `calc:getFileCoverage(path)` | table |
| registerMethodTest | `calc:registerMethodTest(mod, method, case, pass)` | nil |
| getMethodCoverage | `calc:getMethodCoverage(mod, method)` | table |
| getModuleMethodsCoverage | `calc:getModuleMethodsCoverage(mod)` | table[] |
| getProjectCoverage | `calc:getProjectCoverage()` | table |
| toJSON | `calc:toJSON()` | table |

### HierarchyReporter

| Method | Signature | Returns |
|--------|-----------|---------|
| new | `HierarchyReporter:new(coverage)` | HierarchyReporter |
| reportModules | `reporter:reportModules()` | nil (prints) |
| reportFiles | `reporter:reportFiles()` | nil (prints) |
| reportMethodsForModule | `reporter:reportMethodsForModule(path)` | nil (prints) |
| reportHierarchy | `reporter:reportHierarchy()` | nil (prints) |
| toText | `reporter:toText()` | string |
| toJSON | `reporter:toJSON()` | table |

---

## 🔗 Related

- `../README.md` - Usage guide
- `../HIERARCHY_SPEC.md` - Specification
- `../utils/test_helpers.lua` - Helper functions
- `../core/example_counter_test.lua` - Example test

---

*Framework documentation for hierarchical test system*
*3 Levels: Module → File → Method*
