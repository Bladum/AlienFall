# Hierarchical Testing System
**Pattern: Multi-Level Test Organization with Coverage Tracking**

**Purpose:** Enable fast, comprehensive testing with clear coverage metrics at multiple granularities  
**Problem Solved:** Slow test suites, unclear coverage, flat test organization, no progression tracking  
**Universal Pattern:** Applicable to any codebase requiring systematic quality assurance

---

## 🎯 Core Concept

**Principle:** Tests organized in 3 hierarchical levels - Module coverage → File tests → Method tests.

```
LEVEL 1: MODULE COVERAGE (Percentage)
├─ What % of functions are tested?
│
└─> LEVEL 2: FILE TESTS (Count)
    ├─ How many tests per file?
    ├─ How many pass/fail?
    │
    └─> LEVEL 3: METHOD TESTS (Scenarios)
        ├─ Happy path (normal operation)
        ├─ Error cases (invalid inputs)
        └─ Edge cases (boundaries)
```

**Key Rule:** Target 75%+ module coverage, each function tested with 3+ scenarios, full suite <1 second.

---

## 📊 The Three Levels Explained

### Level 1: Module Coverage Analysis

**Purpose:** Measure what percentage of a module's functions have tests

**Calculation:**
```
Module Coverage = (Tested Functions / Total Functions) × 100%

Example:
engine/battlescape/units/unit.lua
- Total functions: 20
- Tested functions: 17
- Coverage: 85% ✓ (Target: >75%)
```

**Report Format:**
```
Module: core/state_manager
Coverage: 85% (17/20 functions tested)
Status: ✓ GOOD (>75% target)

Untested functions:
- _internalHelper()      [private, low priority]
- _debugPrint()          [debug only]
- deprecatedMethod()     [marked for removal]

Recommended action: Add tests for public untested functions
```

**Input:** Source code analysis + test suite results  
**Output:** Coverage percentage per module  
**Validation:** Coverage >75% considered healthy

**Why This Level:**
- Gives high-level view of test health
- Identifies completely untested modules
- Tracks progress over time
- Easy to communicate to stakeholders

---

### Level 2: File Test Organization

**Purpose:** Group tests by file, track pass/fail counts per file

**Structure:**
```lua
-- File: tests2/battlescape/unit_test.lua
-- Maps to: engine/battlescape/units/unit.lua

Tests: 25 total
Passed: 25
Failed: 0
Success Rate: 100%
Execution Time: 45ms
Last Run: 2025-10-27 14:30:15
```

**Report Format:**
```
Subsystem: battlescape
│
├─ unit_test.lua
│  Tests: 25, Passed: 25, Failed: 0, Time: 45ms ✓
│
├─ battle_test.lua
│  Tests: 20, Passed: 19, Failed: 1, Time: 38ms ✗
│  Failed: "Battle:resolveCombat - Handles ties correctly"
│
├─ hex_grid_test.lua
│  Tests: 18, Passed: 18, Failed: 0, Time: 22ms ✓
│
└─ Summary: 63 tests, 62 passed (98.4%), 1 failed, Total: 105ms

Action Required: Fix battle_test.lua failure
```

**Input:** Test execution results  
**Output:** Per-file test statistics  
**Validation:** All tests should pass before commit

**Why This Level:**
- Groups related tests together
- Identifies problematic test files
- Tracks test execution time
- Natural organization (one test file per source file)

---

### Level 3: Method Test Scenarios

**Purpose:** Test individual methods comprehensively with multiple scenarios

**Pattern:** Each public method tested with:
1. **Happy Path** - Normal, expected operation
2. **Error Cases** - Invalid inputs, boundary violations, error conditions
3. **Edge Cases** - Boundary conditions, special values, corner cases

**Example Structure:**
```lua
-- Testing: Unit:gainExperience(amount)

-- SCENARIO 1: Happy Path
suite:testMethod("gainExperience", "Adds positive XP correctly", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(50)
    
    suite:assert(unit.experience == 150, "XP should increase from 100 to 150")
end)

-- SCENARIO 2: Error Case - Negative Input
suite:testMethod("gainExperience", "Rejects negative XP", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(-50)
    
    suite:assert(unit.experience == 100, "XP should not change with negative input")
end)

-- SCENARIO 3: Error Case - Invalid Type
suite:testMethod("gainExperience", "Rejects non-numeric input", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience("invalid")
    
    suite:assert(unit.experience == 100, "XP should not change with invalid type")
end)

-- SCENARIO 4: Edge Case - Zero
suite:testMethod("gainExperience", "Handles zero XP correctly", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(0)
    
    suite:assert(unit.experience == 100, "Zero XP should not error")
end)

-- SCENARIO 5: Edge Case - Large Number
suite:testMethod("gainExperience", "Handles very large XP values", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(999999)
    
    suite:assert(unit.experience == 1000099, "Should handle large values")
end)

-- SCENARIO 6: Integration - Triggers Promotion
suite:testMethod("gainExperience", "Triggers promotion at threshold", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 95
    unit.can_promote = false
    
    unit:gainExperience(5)  -- Reaches exactly 100 XP
    
    suite:assert(unit.experience == 100, "XP should be 100")
    suite:assert(unit.can_promote == true, "Should be eligible for promotion")
end)
```

**Input:** Method signature and specification  
**Output:** Comprehensive test coverage  
**Validation:** Minimum 3 scenarios per method (happy + error + edge)

**Why This Level:**
- Catches bugs at the most granular level
- Documents expected behavior
- Provides regression protection
- Enables confident refactoring

---

## 🏗️ System Architecture

### Component 1: Test Framework

**Purpose:** Provide hierarchical test structure and reporting

**Location:** `tests2/framework/hierarchical_suite.lua`

**Core Structure:**
```lua
local HierarchicalSuite = {}
HierarchicalSuite.__index = HierarchicalSuite

function HierarchicalSuite.new(module_name, file_path)
    local suite = {
        module_name = module_name,      -- e.g., "Unit"
        file_path = file_path,          -- e.g., "tests2/battlescape/unit_test.lua"
        tests = {},                      -- All test definitions
        methods = {},                    -- Track which methods tested
        pass_count = 0,
        fail_count = 0,
        errors = {}
    }
    return setmetatable(suite, HierarchicalSuite)
end

function HierarchicalSuite:testMethod(method_name, description, test_func)
    -- Track that this method is being tested (Level 1: Coverage)
    self.methods[method_name] = self.methods[method_name] or {}
    table.insert(self.methods[method_name], description)
    
    -- Store test definition (Level 3: Scenario)
    table.insert(self.tests, {
        method = method_name,
        description = description,
        func = test_func,
        file = self.file_path
    })
end

function HierarchicalSuite:assert(condition, message)
    if not condition then
        error(message or "Assertion failed", 2)
    end
end

function HierarchicalSuite:run()
    local start_time = os.clock()
    
    for _, test in ipairs(self.tests) do
        local test_start = os.clock()
        local ok, err = pcall(test.func)
        local test_time = (os.clock() - test_start) * 1000  -- Convert to ms
        
        if ok then
            self.pass_count = self.pass_count + 1
        else
            self.fail_count = self.fail_count + 1
            table.insert(self.errors, {
                method = test.method,
                description = test.description,
                error = err,
                time = test_time
            })
        end
    end
    
    local total_time = (os.clock() - start_time) * 1000
    
    return {
        module = self.module_name,
        file = self.file_path,
        total = #self.tests,
        passed = self.pass_count,
        failed = self.fail_count,
        errors = self.errors,
        methods_tested = self.methods,
        time_ms = total_time
    }
end

return HierarchicalSuite
```

**Pattern:** Suite → Method → Scenario organization

---

### Component 2: Test Runner

**Purpose:** Execute tests and generate hierarchical reports

**Location:** `tests2/runners/run_all.lua`

**Process:**
```lua
-- 1. Discover all test files
local TestDiscovery = require("tests2.framework.test_discovery")
local test_files = TestDiscovery:findAllTests("tests2/")

print("Discovered " .. #test_files .. " test files")

-- 2. Run each test file (Level 2: File Tests)
local all_results = {}
local total_pass = 0
local total_fail = 0
local total_time = 0

for _, file_path in ipairs(test_files) do
    local suite = require(file_path)
    local results = suite:run()
    
    all_results[file_path] = results
    total_pass = total_pass + results.passed
    total_fail = total_fail + results.failed
    total_time = total_time + results.time_ms
end

-- 3. Generate Level 1 report: Module Coverage
local CoverageAnalyzer = require("tests2.framework.coverage_analyzer")
local coverage = CoverageAnalyzer:analyze("engine/", all_results)

print("\n" .. string.rep("=", 70))
print("LEVEL 1: MODULE COVERAGE")
print(string.rep("=", 70))

for module, cov in pairs(coverage) do
    local status = cov.percentage >= 75 and "✓" or "✗"
    print(string.format("%s %s: %.1f%% (%d/%d functions)",
        status, module, cov.percentage, cov.tested, cov.total))
end

-- 4. Generate Level 2 report: File Test Results
print("\n" .. string.rep("=", 70))
print("LEVEL 2: FILE TEST RESULTS")
print(string.rep("=", 70))

local subsystems = {}
for file, results in pairs(all_results) do
    local subsystem = file:match("tests2/([^/]+)/")
    subsystems[subsystem] = subsystems[subsystem] or {}
    table.insert(subsystems[subsystem], results)
end

for subsystem, files in pairs(subsystems) do
    print("\n" .. subsystem .. "/")
    for _, results in ipairs(files) do
        local status = results.failed == 0 and "✓" or "✗"
        print(string.format("  %s %s: %d tests, %d passed, %d failed (%.0fms)",
            status,
            results.file:match("[^/]+$"),
            results.total,
            results.passed,
            results.failed,
            results.time_ms))
    end
end

-- 5. Generate Level 3 report: Failed Test Details
if total_fail > 0 then
    print("\n" .. string.rep("=", 70))
    print("LEVEL 3: FAILED TEST DETAILS")
    print(string.rep("=", 70))
    
    for file, results in pairs(all_results) do
        if #results.errors > 0 then
            print("\n" .. file)
            for _, error_info in ipairs(results.errors) do
                print(string.format("  ✗ %s: %s",
                    error_info.method,
                    error_info.description))
                print(string.format("    Error: %s", error_info.error))
            end
        end
    end
end

-- 6. Summary
print("\n" .. string.rep("=", 70))
print("SUMMARY")
print(string.rep("=", 70))
print(string.format("Total Tests: %d", total_pass + total_fail))
print(string.format("Passed: %d (%.1f%%)", total_pass, (total_pass / (total_pass + total_fail)) * 100))
print(string.format("Failed: %d", total_fail))
print(string.format("Execution Time: %.0fms", total_time))
print(string.rep("=", 70))

-- 7. Exit with appropriate status code
local success = total_fail == 0
os.exit(success and 0 or 1)
```

**Input:** Test files  
**Output:** Hierarchical report with 3 levels  
**Performance:** Full suite must complete in <1 second

---

### Component 3: Coverage Analyzer

**Purpose:** Calculate module-level coverage (Level 1)

**Location:** `tests2/framework/coverage_analyzer.lua`

**Algorithm:**
```lua
local CoverageAnalyzer = {}

function CoverageAnalyzer:analyze(source_dir, test_results)
    local coverage = {}
    
    -- 1. Scan source files to find all functions
    for _, source_file in ipairs(self:findLuaFiles(source_dir)) do
        local functions = self:extractFunctions(source_file)
        
        -- 2. Determine which functions have tests
        local tested_functions = {}
        for _, results in pairs(test_results) do
            for method_name, scenarios in pairs(results.methods_tested) do
                if functions[method_name] then
                    tested_functions[method_name] = true
                end
            end
        end
        
        -- 3. Calculate coverage percentage
        local total = 0
        local tested = 0
        for func_name, _ in pairs(functions) do
            total = total + 1
            if tested_functions[func_name] then
                tested = tested + 1
            end
        end
        
        local percentage = total > 0 and (tested / total) * 100 or 0
        
        coverage[source_file] = {
            total = total,
            tested = tested,
            percentage = percentage,
            untested = self:getUntestedFunctions(functions, tested_functions)
        }
    end
    
    return coverage
end

function CoverageAnalyzer:extractFunctions(file_path)
    -- Parse Lua file to find function definitions
    local content = love.filesystem.read(file_path)
    local functions = {}
    
    -- Match: function ClassName:methodName(
    for method in content:gmatch("function%s+[%w_]+:([%w_]+)%(") do
        functions[method] = true
    end
    
    -- Match: function ClassName.methodName(
    for method in content:gmatch("function%s+[%w_]+%.([%w_]+)%(") do
        functions[method] = true
    end
    
    return functions
end

function CoverageAnalyzer:getUntestedFunctions(all_functions, tested_functions)
    local untested = {}
    for func_name, _ in pairs(all_functions) do
        if not tested_functions[func_name] then
            table.insert(untested, func_name)
        end
    end
    return untested
end

return CoverageAnalyzer
```

**Input:** Source code + test results  
**Output:** Coverage metrics per module  
**Report:** List of untested functions

---

### Component 4: Test Scaffolder

**Purpose:** Generate test stubs for untested code

**Location:** `tests2/generators/scaffold_module_tests.lua`

**Process:**
```lua
local TestScaffolder = {}

function TestScaffolder:generate(source_file)
    print("Scaffolding tests for: " .. source_file)
    
    -- 1. Parse source file for public functions
    local functions = self:extractPublicFunctions(source_file)
    print("Found " .. #functions .. " public functions")
    
    -- 2. Determine test file path
    local test_file = self:getTestPath(source_file)
    
    -- 3. Check if test file already exists
    if love.filesystem.getInfo(test_file) then
        print("Warning: Test file already exists. Skipping generation.")
        return nil
    end
    
    -- 4. Generate test content
    local content = self:generateTestFile(source_file, functions)
    
    -- 5. Write test file
    love.filesystem.write(test_file, content)
    
    print("Generated: " .. test_file)
    print("TODO: Implement " .. (#functions * 3) .. " test scenarios")
    print("  - " .. #functions .. " happy path tests")
    print("  - " .. #functions .. " error case tests")
    print("  - " .. #functions .. " edge case tests")
    
    return test_file
end

function TestScaffolder:generateTestFile(source_file, functions)
    local module_path = self:getModulePath(source_file)
    local module_name = self:getModuleName(source_file)
    local test_path = self:getTestPath(source_file)
    
    local content = string.format([[
-- Auto-generated test scaffold for %s
-- Generated: %s
-- TODO: Implement test scenarios (remove this comment when done)

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local %s = require("%s")

local suite = HierarchicalSuite.new("%s", "%s")

]], source_file, os.date("%Y-%m-%d"), module_name, module_path, module_name, test_path)
    
    -- Generate test stubs for each function
    for _, func in ipairs(functions) do
        content = content .. self:generateFunctionTestStubs(func)
    end
    
    content = content .. "\nreturn suite\n"
    
    return content
end

function TestScaffolder:generateFunctionTestStubs(func)
    return string.format([[

-- ============================================================
-- Tests for: %s
-- ============================================================

-- SCENARIO 1: Happy Path
suite:testMethod("%s", "TODO: Test normal operation", function()
    -- TODO: Implement happy path test
    -- 1. Create instance
    -- 2. Call %s() with valid inputs
    -- 3. Assert expected behavior
    suite:assert(false, "Test not implemented")
end)

-- SCENARIO 2: Error Case
suite:testMethod("%s", "TODO: Test error handling", function()
    -- TODO: Implement error case test
    -- 1. Call %s() with invalid inputs (nil, wrong type, out of range)
    -- 2. Assert error is handled gracefully
    suite:assert(false, "Test not implemented")
end)

-- SCENARIO 3: Edge Case
suite:testMethod("%s", "TODO: Test boundary conditions", function()
    -- TODO: Implement edge case test
    -- 1. Call %s() with edge values (0, max, empty, etc.)
    -- 2. Assert correct behavior at boundaries
    suite:assert(false, "Test not implemented")
end)

]], func.name, func.name, func.name, func.name, func.name, func.name, func.name)
end

return TestScaffolder
```

**Input:** Source file path  
**Output:** Test file with stubs for all public functions  
**Usage:** `lua tests2/generators/scaffold_module_tests.lua engine/unit.lua`

---

## 🔄 Development Workflow

### Workflow 1: Test-Driven Development (TDD)

```
1. Write Test First
   tests2/battlescape/unit_test.lua
   └─ suite:testMethod("gainExperience", "Adds XP correctly", ...)

2. Run Test (Should Fail)
   lovec tests2/runners run_single_test battlescape/unit_test
   └─ ✗ FAIL: Method gainExperience() doesn't exist yet

3. Write Minimal Implementation
   engine/battlescape/units/unit.lua
   └─ function Unit:gainExperience(amount)
        self.experience = self.experience + amount
      end

4. Run Test (Should Pass)
   lovec tests2/runners run_single_test battlescape/unit_test
   └─ ✓ PASS: gainExperience adds XP correctly

5. Refactor
   Improve implementation while keeping tests green

6. Add More Scenarios
   Add error cases and edge cases
```

---

### Workflow 2: Legacy Code Testing

```
1. Identify Untested Module
   lua tools/generators/analyze_engine_structure.lua
   └─ engine/battlescape/unit.lua: 0% coverage (0/20 functions)

2. Generate Test Scaffold
   lua tools/generators/scaffold_module_tests.lua engine/battlescape/unit.lua
   └─ Created: tests2/battlescape/unit_test.lua with 60 TODOs

3. Implement Tests Incrementally
   Start with critical/complex functions first
   
4. Track Progress
   lovec tests2/runners run_subsystem battlescape
   └─ Coverage increasing: 0% → 25% → 50% → 75%

5. Refactor with Confidence
   Once covered, improve implementation safely
```

---

### Workflow 3: Continuous Integration

```
.github/workflows/tests.yml:

name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Install Love2D
        run: sudo apt-get install love
      
      - name: Run Full Test Suite
        run: lovec tests2/runners run_all
      
      - name: Check Coverage
        run: |
          coverage=$(lovec tests2/runners run_coverage | grep "Overall:" | awk '{print $2}')
          if [ ${coverage%\%} -lt 75 ]; then
            echo "Coverage $coverage is below 75% threshold"
            exit 1
          fi
      
      - name: Check Performance
        run: |
          time=$(lovec tests2/runners run_all | grep "Total Time:" | awk '{print $3}')
          if [ ${time%ms} -gt 1000 ]; then
            echo "Test suite took ${time} - exceeds 1000ms limit"
            exit 1
          fi
```

---

## ✅ Validation Rules

### Rule 1: Coverage Threshold

**Check:** Module coverage >75%

```bash
lovec tests2/runners run_coverage

# Output:
Module Coverage Report
core/state_manager: 85% ✓
core/event_bus: 92% ✓
battlescape/unit: 68% ✗ (below 75% threshold)

Action: Add tests to battlescape/unit
```

**Enforcement:** CI/CD fails if any module <75%

---

### Rule 2: Test Completeness

**Check:** Each function has minimum 3 test scenarios

```bash
lua tools/validators/test_completeness.lua tests2/

# Analysis:
gainExperience: 4 scenarios ✓ (happy, error, 2x edge)
promote: 2 scenarios ✗ (need 3+)
  Missing: Edge case tests

Action: Add edge case tests for promote()
```

---

### Rule 3: Performance Requirement

**Check:** Full suite <1 second

```bash
lovec tests2/runners run_all

# Output:
Total: 2493 tests
Time: 0.847s ✓ (under 1s limit)
```

**Violations:**
- Individual test >10ms
- Full suite >1000ms
- Tests doing I/O (file, network)

**Fix:** Mock I/O operations, avoid sleep(), optimize algorithms

---

### Rule 4: Test Independence

**Check:** Tests don't depend on each other

```bash
# Run in random order
lovec tests2/runners run_random_order

# If results differ from normal run:
# ✗ Tests have shared state!
```

**Common Issues:**
- Shared mock objects
- Global state modification
- Test order dependency

**Fix:** Fresh instance per test, clean up after each test

---

## 🚫 Anti-Patterns

### Anti-Pattern 1: Testing Implementation Details

**WRONG:**
```lua
suite:testMethod("gainExperience", "Uses correct variable name", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit:gainExperience(50)
    
    -- Testing internal variable name!
    suite:assert(unit._xp ~= nil, "Should have _xp variable")
end)
```

**RIGHT:**
```lua
suite:testMethod("gainExperience", "Increases experience correctly", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(50)
    
    -- Testing behavior, not implementation
    suite:assert(unit.experience == 150, "Experience should increase")
end)
```

**Why:** Testing implementation prevents refactoring. Test behavior instead.

---

### Anti-Pattern 2: Shared State Between Tests

**WRONG:**
```lua
local shared_unit = Unit.new("soldier", "Test", 1)  -- Shared!

suite:testMethod("method1", "Test 1", function()
    shared_unit.experience = 100  -- Modifies shared state
end)

suite:testMethod("method2", "Test 2", function()
    -- Depends on method1 running first!
    suite:assert(shared_unit.experience == 100)
end)
```

**RIGHT:**
```lua
suite:testMethod("method1", "Test 1", function()
    local unit = Unit.new("soldier", "Test", 1)  -- Fresh instance
    unit.experience = 100
    -- Test completes, unit goes out of scope
end)

suite:testMethod("method2", "Test 2", function()
    local unit = Unit.new("soldier", "Test", 1)  -- Fresh instance
    unit.experience = 50
    -- Independent of method1
end)
```

**Why:** Shared state creates brittle tests that break when run in different orders.

---

### Anti-Pattern 3: Slow Tests

**WRONG:**
```lua
suite:testMethod("save", "Saves to disk", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit:save("test_save.dat")  -- Disk I/O is SLOW!
    
    love.timer.sleep(0.1)  -- Waiting is SLOW!
    
    local loaded = Unit:load("test_save.dat")
    suite:assert(loaded.name == "Test")
end)
```

**RIGHT:**
```lua
suite:testMethod("save", "Generates correct save data", function()
    local unit = Unit.new("soldier", "Test", 1)
    
    -- Test data structure, not I/O
    local data = unit:getSaveData()
    
    suite:assert(data.name == "Test")
    suite:assert(data.experience ~= nil)
    -- No I/O, runs in <1ms
end)
```

**Why:** Slow tests kill productivity. Mock I/O and external dependencies.

---

### Anti-Pattern 4: Vague Test Names

**WRONG:**
```lua
suite:testMethod("gainExperience", "Test 1", function() ... end)
suite:testMethod("gainExperience", "Test 2", function() ... end)
suite:testMethod("gainExperience", "Test 3", function() ... end)
```

**RIGHT:**
```lua
suite:testMethod("gainExperience", "Adds positive XP correctly", function() ...)
suite:testMethod("gainExperience", "Rejects negative XP", function() ...)
suite:testMethod("gainExperience", "Triggers promotion at threshold", function() ...)
```

**Why:** Test names document what's being tested. Clear names aid debugging.

---

### Anti-Pattern 5: One Giant Test

**WRONG:**
```lua
suite:testMethod("unit", "Tests everything about units", function()
    local unit = Unit.new("soldier", "Test", 1)
    
    -- Tests 20 different things in one test!
    unit:gainExperience(50)
    suite:assert(unit.experience == 50)
    
    unit:promote()
    suite:assert(unit.rank == 2)
    
    unit:takeDamage(10)
    suite:assert(unit.health == 90)
    
    -- ... 50 more assertions
end)
```

**RIGHT:**
```lua
suite:testMethod("gainExperience", "Adds XP correctly", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit:gainExperience(50)
    suite:assert(unit.experience == 50)
end)

suite:testMethod("promote", "Increases rank", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.can_promote = true
    unit:promote()
    suite:assert(unit.rank == 2)
end)

suite:testMethod("takeDamage", "Reduces health", function()
    local unit = Unit.new("soldier", "Test", 1)
    unit.health = 100
    unit:takeDamage(10)
    suite:assert(unit.health == 90)
end)
```

**Why:** Small focused tests pinpoint failures. When one test fails, you know exactly what broke.

---

## 🔧 Tools for Testing System

### Tool 1: Test Runner (Multiple Modes)

```bash
# Run all tests
lovec tests2/runners run_all

# Run subsystem tests
lovec tests2/runners run_subsystem battlescape

# Run single test file
lovec tests2/runners run_single_test battlescape/unit_test

# Run with coverage analysis
lovec tests2/runners run_coverage

# Run in random order (detect dependencies)
lovec tests2/runners run_random_order

# Run only failed tests from last run
lovec tests2/runners run_failed

# Run continuously (watch mode)
lovec tests2/runners run_watch
```

---

### Tool 2: Test Scaffolder

```bash
# Generate test stub for module
lua tools/generators/scaffold_module_tests.lua engine/battlescape/unit.lua

# Output: tests2/battlescape/unit_test.lua
# Contains TODO stubs for all public functions

# Example output:
# Generated: tests2/battlescape/unit_test.lua
# TODO: Implement 60 test scenarios:
#   - 20 happy path tests
#   - 20 error case tests
#   - 20 edge case tests
```

---

### Tool 3: Coverage Analyzer

```bash
# Analyze coverage for entire project
lua tools/generators/analyze_engine_structure.lua

# Output:
# Module Coverage Analysis
# 
# ✓ core/state_manager: 85% (17/20)
# ✓ core/event_bus: 92% (23/25)
# ✗ battlescape/unit: 68% (15/22) - BELOW THRESHOLD
# ✗ geoscape/base: 45% (9/20) - BELOW THRESHOLD
# 
# Untested modules:
# - economy/market.lua: 0% (0/15)
# - politics/diplomacy.lua: 0% (0/12)
# 
# Overall: 71% (64/89 functions)
# 
# Action: Add tests to modules below 75%
```

---

### Tool 4: Test Validator

```bash
# Check test quality
lua tools/validators/test_quality.lua tests2/

# Checks:
# ✓ Test independence (can run in any order)
# ✓ Test completeness (3+ scenarios per function)
# ✓ Test performance (<10ms per test)
# ✗ Test naming (5 tests with vague names)
# ✗ Shared state detected (3 test files)
# 
# Issues found:
# 1. tests2/battlescape/unit_test.lua
#    - Shared variable: shared_unit (line 10)
#    - Action: Use fresh instance per test
# 
# 2. tests2/geoscape/base_test.lua
#    - Vague names: "Test 1", "Test 2", "Test 3"
#    - Action: Use descriptive names
```

---

## 📊 System Health Metrics

### Metric 1: Coverage

**Targets:**
```
Overall coverage: >80%
Per-module coverage: >75%
Critical modules (core, battle): >90%
New code coverage: 100% (no uncovered new functions)
```

**Tracking:**
```bash
# Generate coverage trend report
lua tools/reports/coverage_trend.lua

# Output:
Coverage Trend (Last 30 days)
2025-09-27: 68%
2025-10-04: 71%
2025-10-11: 74%
2025-10-18: 77%
2025-10-25: 80% ✓ (reached target!)

Trend: +12% over 30 days
```

---

### Metric 2: Test Quality

**Targets:**
```
Tests per function: >3 average
Happy path coverage: 100%
Error case coverage: >80%
Edge case coverage: >70%
```

**Tracking:**
```bash
# Analyze test completeness
lua tools/reports/test_quality.lua

# Output:
Test Quality Report

Scenario Distribution:
- Happy path: 2493 tests (100%) ✓
- Error cases: 2015 tests (81%) ✓
- Edge cases: 1746 tests (70%) ✓

Average scenarios per function: 3.8 ✓

Functions with <3 scenarios: 45 (18%)
Action: Add tests to under-tested functions
```

---

### Metric 3: Performance

**Targets:**
```
Full suite execution: <1 second
Average test time: <0.4ms
Slowest test: <10ms
Suite growth rate: Linear with codebase
```

**Tracking:**
```bash
# Performance report
lua tools/reports/test_performance.lua

# Output:
Test Performance Report

Total tests: 2493
Total time: 847ms ✓ (under 1s)
Average: 0.34ms per test ✓

Slowest tests:
1. battlescape/pathfinding_test:findPath - 8.2ms ✓
2. geoscape/research_test:completeTree - 7.9ms ✓
3. economy/market_test:simulation - 6.1ms ✓

All tests under 10ms threshold ✓
```

---

### Metric 4: Reliability

**Targets:**
```
Test pass rate: 100%
Flaky tests: 0
False positives: 0
False negatives: 0
```

**Tracking:**
```bash
# Run tests 100 times to detect flakiness
lua tools/validators/test_stability.lua

# Output:
Stability Analysis (100 runs)

Consistent results: 2493/2493 tests (100%) ✓
Flaky tests detected: 0 ✓

All tests are stable and reliable.
```

---

## 🌍 Universal Adaptation

### Pattern in Different Languages

**Python (pytest):**
```python
# Hierarchical structure still applies

# Level 1: Module coverage
pytest --cov=src --cov-report=term-missing

# Level 2: File organization
# tests/battlescape/test_unit.py maps to src/battlescape/unit.py

# Level 3: Method scenarios
def test_gain_experience_adds_correctly():  # Happy path
def test_gain_experience_rejects_negative():  # Error case
def test_gain_experience_handles_zero():  # Edge case
```

**JavaScript (Jest):**
```javascript
// Level 1: Coverage tracking
jest --coverage --coverageThreshold='{"global":{"functions":75}}'

// Level 2: File organization  
// tests/battlescape/unit.test.js → src/battlescape/unit.js

// Level 3: Scenarios
describe('gainExperience', () => {
  it('adds positive XP correctly', () => {});  // Happy
  it('rejects negative XP', () => {});  // Error
  it('triggers promotion at threshold', () => {});  // Edge
});
```

**Java (JUnit):**
```java
// Level 1: JaCoCo coverage
mvn test jacoco:report

// Level 2: File organization
// src/test/java/battlescape/UnitTest.java

// Level 3: Scenarios
@Test
public void gainExperience_addsCorrectly() {}  // Happy path

@Test
public void gainExperience_rejectsNegative() {}  // Error case

@Test
public void gainExperience_handlesZero() {}  // Edge case
```

**Key Insight:** 3-level hierarchy is universal across languages and frameworks.

---

## 🎯 Success Criteria

Testing system is working correctly when:

✅ **Fast:** Full suite runs in <1 second  
✅ **Comprehensive:** Coverage >75% per module  
✅ **Reliable:** All tests pass consistently before every commit  
✅ **Stable:** No flaky tests (results consistent across runs)  
✅ **Performant:** Individual tests run in <10ms (no I/O, no sleep)  
✅ **Automatic:** New code includes tests automatically (CI enforces)  
✅ **Actionable:** Test failures clearly indicate what broke  
✅ **Maintainable:** Test code is clean, well-organized, easy to update  

---

## 📝 Implementation Checklist

To implement this pattern in your project:

### Phase 1: Framework Setup
- [ ] Choose or create test framework supporting hierarchical organization
- [ ] Implement 3-level reporting (module, file, method)
- [ ] Set up test runner with multiple modes (all/subsystem/single)
- [ ] Configure CI/CD integration

### Phase 2: Coverage Infrastructure
- [ ] Build coverage analyzer (parse source, track tested functions)
- [ ] Set coverage targets (overall >80%, module >75%)
- [ ] Create coverage tracking dashboard
- [ ] Implement coverage enforcement in CI

### Phase 3: Test Generation
- [ ] Create test scaffolder (generate stubs from source)
- [ ] Document 3-scenario pattern (happy/error/edge)
- [ ] Train team on test patterns
- [ ] Generate tests for critical modules first

### Phase 4: Performance Optimization
- [ ] Establish <1s full suite requirement
- [ ] Identify and fix slow tests (I/O, sleep, etc.)
- [ ] Mock external dependencies
- [ ] Optimize test setup/teardown

### Phase 5: Quality Assurance
- [ ] Build test quality validator
- [ ] Check for test independence (run in random order)
- [ ] Detect and eliminate flaky tests
- [ ] Review and improve test naming

### Phase 6: Continuous Improvement
- [ ] Track metrics over time (coverage trends, performance)
- [ ] Regular retrospectives on test effectiveness
- [ ] Update framework based on team feedback
- [ ] Share successful patterns with team

---

## 🔗 Integration with Other Systems

### Integration with Pipeline (02_PIPELINE_ARCHITECTURE_SYSTEM)

Tests validate each pipeline stage:

**Stage 4 (Engine) → Stage 6 (Tests):**
- Every function in engine/ should have tests in tests2/
- Tests prove implementation meets API contracts
- Coverage analyzer ensures completeness

**Validation:**
```bash
# After implementing feature in engine/
lovec tests2/runners run_subsystem [subsystem]

# Must pass before proceeding to next stage
```

---

### Integration with Automation Tools (06_AUTOMATION_TOOLS_SYSTEM)

**Generators create tests:**
```bash
lua tools/generators/scaffold_module_tests.lua engine/new_module.lua
# Creates: tests2/new_module_test.lua with TODO stubs
```

**Validators check test quality:**
```bash
lua tools/validators/test_quality.lua tests2/
# Reports: independence, completeness, performance issues
```

---

### Integration with CI/CD

**Pre-commit Hook:**
```bash
# .git/hooks/pre-commit
lovec tests2/runners run_all
if [ $? -ne 0 ]; then
  echo "Tests failed - commit rejected"
  exit 1
fi
```

**Pull Request Checks:**
- All tests must pass
- Coverage must not decrease
- No new flaky tests
- Performance within limits

---

**Related Systems:**
- [01_SEPARATION_OF_CONCERNS_SYSTEM.md](01_SEPARATION_OF_CONCERNS_SYSTEM.md) - Tests validate separation
- [02_PIPELINE_ARCHITECTURE_SYSTEM.md](02_PIPELINE_ARCHITECTURE_SYSTEM.md) - Tests are Stage 6
- [06_AUTOMATION_TOOLS_SYSTEM.md](06_AUTOMATION_TOOLS_SYSTEM.md) - Generators and validators

**See:** modules/06_TESTS2_FOLDER.md for folder-specific usage

**Last Updated:** 2025-10-27  
**Pattern Maturity:** Production-Proven (2493+ tests in 0.847s)

