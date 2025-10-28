# Test Suite - Automated Testing Framework

**Purpose:** Comprehensive automated testing for all engine systems  
**Audience:** Developers, QA engineers, AI agents  
**Status:** Active development  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Test Statistics](#test-statistics)
- [Quick Start](#quick-start)
- [Test Framework](#test-framework)
- [Coverage System](#coverage-system)
- [How to Use](#how-to-use)
- [How to Contribute](#how-to-contribute)
- [AI Agent Instructions](#ai-agent-instructions)
- [Good Practices](#good-practices)
- [Quick Reference](#quick-reference)

---

## Overview

The `tests2/` folder contains the **complete automated test suite** for AlienFall with **2,493+ tests** covering all engine functionality in **<1 second** execution time.

**Core Purpose:**
- Verify engine functionality
- Prevent regressions
- Document expected behavior
- Enable confident refactoring
- Support continuous integration

**Performance:** 2,493+ tests in <1 second ⚡

---

## Folder Structure

```
tests2/
├── README.md                          ← This file
├── main.lua                           ← Test runner entry point
├── conf.lua                           ← Love2D configuration
│
├── framework/                         ← Test Framework (3 files)
│   ├── hierarchical_suite.lua        ← Core test framework
│   ├── coverage_calculator.lua       ← 3-level coverage tracking
│   └── hierarchy_reporter.lua        ← Report generation
│
├── runners/                           ← Test Execution Scripts
│   ├── run_all.lua                   ← Run all 2,493 tests
│   ├── run_subsystem.lua             ← Run specific subsystem
│   └── run_single_test.lua           ← Run single test file
│
├── generators/                        ← Test Generation Tools
│   ├── scaffold_module_tests.lua     ← Generate test templates
│   └── analyze_engine_structure.lua  ← Scan engine for coverage
│
├── Subsystem Tests (11 categories)
│   ├── core/                         ← Core engine tests (~30 files, 300+ tests)
│   ├── geoscape/                     ← Strategic layer (~26 files, 260+ tests)
│   ├── battlescape/                  ← Tactical combat (~20 files, 200+ tests)
│   ├── basescape/                    ← Base management (~14 files, 140+ tests)
│   ├── economy/                      ← Economic systems (~18 files, 180+ tests)
│   ├── politics/                     ← Political systems (~15 files, 150+ tests)
│   ├── lore/                         ← Narrative systems (~10 files, 100+ tests)
│   ├── ai/                           ← AI systems (~7 files, 70+ tests)
│   ├── audio/                        ← Audio systems
│   ├── utils/                        ← Utility functions
│   └── mods/                         ← Mod system tests
│
├── By Type Tests
│   ├── integration/                  ← Integration tests
│   ├── performance/                  ← Performance tests
│   ├── regression/                   ← Regression tests
│   ├── smoke/                        ← Smoke tests
│   └── api_contract/                 ← API contract tests
│
├── reports/                           ← Auto-Generated Reports
│   ├── coverage_matrix.json          ← Coverage data
│   └── hierarchy_report.txt          ← Hierarchical report
│
└── utils/                             ← Test Utilities
    └── test_helpers.lua              ← Helper functions
```

**Total:** 150+ test files, 2,493+ tests, ~37,000+ lines of test code

---

## Key Features

- **Fast Execution:** All 2,493+ tests run in <1 second
- **Hierarchical Structure:** Organized by subsystem (11 categories)
- **3-Level Coverage:** Module → File → Method tracking
- **Auto-Generated Reports:** Coverage matrix, hierarchy reports
- **Easy to Run:** Batch files, console commands, runners
- **Test Generators:** Auto-scaffold tests from engine code
- **Rich Assertions:** Comprehensive assertion library
- **Mocking Support:** Mock game systems for isolated testing

---

## Test Statistics

| Metric | Value |
|--------|-------|
| **Total Tests** | 2,493+ |
| **Test Files** | 150+ |
| **Subsystems** | 11 |
| **Lines of Code** | ~37,000+ |
| **Execution Time** | <1 second |
| **Pass Rate** | 100% ✅ |
| **Coverage Target** | 75%+ |

### Coverage by Subsystem

| Subsystem | Files | Tests | Status |
|-----------|-------|-------|--------|
| **core** | 30 | ~300+ | ✅ State, events, systems |
| **geoscape** | 26 | ~260+ | ✅ Strategy, campaigns, world |
| **battlescape** | 20 | ~200+ | ✅ Combat, tactics, movement |
| **basescape** | 14 | ~140+ | ✅ Facilities, management |
| **economy** | 18 | ~180+ | ✅ Production, trade, finance |
| **politics** | 15 | ~150+ | ✅ Factions, diplomacy |
| **lore** | 10 | ~100+ | ✅ Narrative, story |
| **ai** | 7 | ~70+ | ✅ Planning, decisions |
| **framework** | 3 | ~30+ | ✅ Test infrastructure |
| **generators** | 1 | ~10+ | ✅ Generation tools |
| **utils** | 1 | ~10+ | ✅ Common utilities |

---

## Quick Start

### Run All Tests

```bash
# Windows
lovec "tests2/runners" run_all
# or
run\run_tests2_all.bat

# Linux/Mac
love tests2/runners/run_all.lua
```

**Output:**
```
════════════════════════════════════════════════════
AlienFall Test Suite 2 - MASTER RUNNER
════════════════════════════════════════════════════
[RUNNER] Loading tests from core/ ...
  ✓ StateManager tests (30 tests)
[RUNNER] Loading tests from geoscape/ ...
  ✓ WorldManager tests (26 tests)
... (9 more subsystems)
════════════════════════════════════════════════════
TEST SUMMARY
════════════════════════════════════════════════════
Total Tests:   2493
Passed:        2493
Failed:        0
Pass Rate:     100.0%
Duration:      0.856s
════════════════════════════════════════════════════
```

### Run Specific Subsystem

```bash
# Core subsystem
lovec "tests2/runners" run_subsystem core

# Battlescape subsystem
lovec "tests2/runners" run_subsystem battlescape

# Economy subsystem
lovec "tests2/runners" run_subsystem economy
```

### Run Single Test

```bash
# Specific test file
lovec "tests2/runners" run_single_test core/state_manager_test

# Another example
lovec "tests2/runners" run_single_test battlescape/combat_test
```

---

## Test Framework

### HierarchicalSuite

All tests use the **HierarchicalSuite** framework:

```lua
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local MyModule = require("engine.subsystem.my_module")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.subsystem.my_module",
    description = "My module tests"
})

-- Setup/Teardown
Suite:before(function()
    -- Runs before all tests
end)

Suite:after(function()
    -- Runs after all tests
end)

Suite:beforeEach(function()
    -- Runs before each test
end)

Suite:afterEach(function()
    -- Runs after each test
end)

-- Group tests
Suite:group("Initialization", function()
    Suite:testMethod("MyModule:new", {
        description = "Creates instance",
        testCase = "happy_path"
    }, function()
        local instance = MyModule.new()
        assert(instance ~= nil)
    end)
    
    Suite:testMethod("MyModule:new", {
        description = "Throws on invalid config",
        testCase = "error_handling"
    }, function()
        assert(pcall(function()
            MyModule.new({invalid = true})
        end) == false)
    end)
end)

-- Run and return
local success = Suite:run()
return Suite
```

### Test Case Types

| Type | Purpose | Example |
|------|---------|---------|
| `happy_path` | Normal behavior | Valid inputs, expected outputs |
| `error_handling` | Error cases | Invalid inputs, exceptions |
| `edge_case` | Boundary conditions | Min/max values, empty data |
| `validation` | Input validation | Type checking, constraints |

---

## Coverage System

### 3-Level Coverage Tracking

**Level 1: Module Coverage**
- Which modules have tests?
- What % of functions are tested?

**Level 2: File Coverage**
- How many tests in each file?
- What's the pass rate?

**Level 3: Method Coverage**
- Which test cases exist for each method?
- Are all paths tested?

### Using Coverage Calculator

```lua
local CoverageCalculator = require("tests2.framework.coverage_calculator")
local calc = CoverageCalculator:new()

-- Register module
calc:registerModule("engine.core.state_manager", 10)

-- Mark functions tested
calc:markFunctionTested("engine.core.state_manager", "StateManager:new")
calc:markFunctionTested("engine.core.state_manager", "StateManager:setState")

-- Get coverage
local moduleCov = calc:getModuleCoverage("engine.core.state_manager")
print(moduleCov.percentage)  -- 20% (2 out of 10 functions)
```

### Coverage Reports

```bash
# Generate coverage report
lovec "tests2/runners" run_all

# Check reports/
cat tests2/reports/coverage_matrix.json
cat tests2/reports/hierarchy_report.txt
```

---

## How to Use

### For Developers

**Running Tests:**
```bash
# After making changes
lovec "tests2/runners" run_subsystem [your_subsystem]

# Before committing
lovec "tests2/runners" run_all
```

**Writing Tests:**
1. Create test file: `tests2/[subsystem]/[feature]_test.lua`
2. Use HierarchicalSuite framework
3. Test happy path + error cases + edge cases
4. Run test: `lovec "tests2/runners" run_single_test [subsystem]/[feature]_test`

**Example Test File:**
```lua
local Suite = require("tests2.framework.hierarchical_suite")
local StateManager = require("engine.core.state_manager")

local Suite = Suite:new({
    modulePath = "engine.core.state_manager",
    description = "State management"
})

Suite:group("Initialization", function()
    Suite:testMethod("StateManager:new", {
        description = "Creates instance"
    }, function()
        local mgr = StateManager.new()
        assert(mgr ~= nil)
    end)
end)

return Suite
```

### For QA Engineers

**Test Execution:**
```bash
# Full regression
lovec "tests2/runners" run_all

# Smoke tests
lovec "tests2/runners" run_subsystem smoke

# Performance tests
lovec "tests2/runners" run_subsystem performance
```

**Checking Coverage:**
```bash
# View coverage report
cat tests2/reports/coverage_matrix.json
```

### For AI Agents

See [AI Agent Instructions](#ai-agent-instructions) below.

---

## How to Contribute

### Adding New Tests

1. **Identify what to test:**
   - New engine module? Create test file
   - Bug fix? Add regression test
   - New feature? Add feature tests

2. **Create test file:**
   ```bash
   # Use generator (recommended)
   lovec "tests2/generators" scaffold_module_tests engine/subsystem/my_module.lua
   
   # Or create manually
   touch tests2/subsystem/my_module_test.lua
   ```

3. **Write tests:**
   - Use HierarchicalSuite framework
   - Test happy path first
   - Add error handling tests
   - Add edge case tests

4. **Run tests:**
   ```bash
   lovec "tests2/runners" run_single_test subsystem/my_module_test
   ```

5. **Verify coverage:**
   - Check reports/coverage_matrix.json
   - Aim for 75%+ coverage

### Test Guidelines

- **One test file per module**
- **Happy path + 2+ error cases minimum**
- **Keep tests fast (<10ms per test)**
- **No dependencies between tests**
- **Use descriptive test names**
- **Document expected behavior**

---

## AI Agent Instructions

### When to Run Tests

| Scenario | Action |
|----------|--------|
| After modifying engine | Run affected subsystem tests |
| Before committing | Run full suite |
| After bug fix | Run regression tests |
| After refactoring | Run full suite |
| Creating new feature | Write tests first (TDD) |

### Test-First Workflow

```
User asks to implement feature
    ↓
1. Create test file first (TDD)
    ↓
2. Write failing tests (red)
    ↓
3. Implement feature (green)
    ↓
4. Refactor (refactor)
    ↓
5. Run tests to verify
    ↓
6. All tests pass → Success!
```

### Using Test Generators

```bash
# Scan engine for untested modules
lovec "tests2/generators" analyze_engine_structure

# Generate test template for module
lovec "tests2/generators" scaffold_module_tests engine/core/my_module.lua

# This creates: tests2/core/my_module_test.lua with placeholders
```

### Common AI Tasks

| Task | Steps |
|------|-------|
| **Add test for module** | 1. Run generator<br>2. Fill placeholders<br>3. Run test<br>4. Verify coverage |
| **Fix failing test** | 1. Read test failure<br>2. Fix code or test<br>3. Re-run<br>4. Verify pass |
| **Improve coverage** | 1. Check coverage report<br>2. Find untested functions<br>3. Add tests<br>4. Verify coverage |

---

## Good Practices

### ✅ Testing

- Write tests alongside code
- Test happy path first, then errors
- Keep tests fast (<10ms each)
- Use descriptive test names
- Test one thing per test
- Avoid test interdependencies

### ✅ Coverage

- Aim for 75%+ coverage
- Focus on critical paths
- Test error handling
- Test edge cases
- Document untestable code

### ✅ Organization

- One test file per module
- Group related tests
- Use consistent naming
- Keep tests near what they test

---

## Quick Reference

### Essential Commands

```bash
# Run all tests
lovec "tests2/runners" run_all

# Run subsystem
lovec "tests2/runners" run_subsystem core

# Run single test
lovec "tests2/runners" run_single_test core/state_manager_test

# Generate test template
lovec "tests2/generators" scaffold_module_tests engine/core/my_module.lua

# Analyze coverage
cat tests2/reports/coverage_matrix.json
```

### Test File Template

```lua
local Suite = require("tests2.framework.hierarchical_suite")
local Module = require("engine.subsystem.module")

local Suite = Suite:new({
    modulePath = "engine.subsystem.module",
    description = "Module description"
})

Suite:group("Group Name", function()
    Suite:testMethod("Module:method", {
        description = "What it tests",
        testCase = "happy_path"
    }, function()
        -- Test code
        assert(condition)
    end)
end)

return Suite
```

### Related Documentation

- **Engine:** [engine/README.md](../engine/README.md) - What tests verify
- **Docs:** [docs/instructions/🧪 Testing.instructions.md](../docs/instructions/🧪%20Testing.instructions.md) - Testing best practices
- **Framework:** [tests2/framework/README.md](framework/README.md) - Framework details
- **Generators:** [tests2/generators/README.md](generators/README.md) - Generator tools

---

**Last Updated:** 2025-10-28  
**Test Count:** 2,493+ tests in <1 second  
**Status:** Production Ready ✅  
**Questions:** See framework docs or ask in Discord

