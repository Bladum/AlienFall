# Tests2 Folder - Hierarchical Test Suite

**Purpose:** Store comprehensive test suite validating all engine code  
**Audience:** Developers, QA engineers, CI/CD systems  
**Format:** Lua test files using HierarchicalSuite framework

---

## What Goes in tests2/

### Structure
```
tests2/
├── README.md                    Testing documentation
├── QUICK_REFERENCE.md          Quick command reference
├── HIERARCHY_SPEC.md           3-level hierarchy specification
│
├── framework/                   Test framework core
│   ├── hierarchical_suite.lua  Main test framework
│   ├── test_discovery.lua      Find all test files
│   ├── coverage_analyzer.lua   Calculate coverage
│   └── assertions.lua          Assertion helpers
│
├── runners/                     Test execution
│   ├── run_all.lua             Run entire suite
│   ├── run_subsystem.lua       Run one subsystem
│   ├── run_single_test.lua     Run one test file
│   └── run_coverage.lua        Coverage analysis
│
├── generators/                  Test generation tools
│   ├── scaffold_module_tests.lua   Generate test stubs
│   └── analyze_engine_structure.lua Find untested code
│
├── core/                        Core systems tests
│   ├── state_manager_test.lua
│   ├── event_bus_test.lua
│   └── entity_factory_test.lua
│
├── battlescape/                 Tactical combat tests
│   ├── battle_test.lua
│   ├── unit_test.lua
│   ├── combat_test.lua
│   └── ai_test.lua
│
├── geoscape/                    World map tests
│   ├── world_test.lua
│   ├── base_test.lua
│   └── mission_generator_test.lua
│
├── economy/                     Economic systems tests
│   ├── market_test.lua
│   ├── research_test.lua
│   └── manufacturing_test.lua
│
└── reports/                     Generated reports
    ├── coverage_matrix.json    Coverage data
    └── hierarchy_report.txt    Test hierarchy
```

---

## Core Principle: 3-Level Hierarchy

**Tests organized in three levels for clarity and coverage tracking:**

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

**Example:**
```
Module: battlescape/units/unit.lua (85% coverage)
├─ File: tests2/battlescape/unit_test.lua (25 tests)
│   ├─ Method: new() - 3 scenarios
│   │   ├─ Creates valid unit (happy path)
│   │   ├─ Rejects invalid ID (error case)
│   │   └─ Handles nil name (edge case)
│   ├─ Method: gainExperience() - 4 scenarios
│   │   ├─ Adds positive XP (happy path)
│   │   ├─ Rejects negative XP (error case)
│   │   ├─ Handles zero XP (edge case)
│   │   └─ Triggers promotion (integration)
│   └─ Method: promote() - 3 scenarios
│       ├─ Increases rank and stats (happy path)
│       ├─ Rejects when not eligible (error case)
│       └─ Rejects at max rank (edge case)
```

**Key Metrics:**
- Target: >75% module coverage
- Minimum: 3 scenarios per method
- Performance: Full suite <1 second

---

## Content Guidelines

### What Belongs Here
- ✅ Unit tests (test individual functions)
- ✅ Integration tests (test system interactions)
- ✅ Test framework code
- ✅ Test runners and reporters
- ✅ Test generators/scaffolders
- ✅ Coverage analysis tools
- ✅ Test fixtures and mocks

### What Does NOT Belong Here
- ❌ Game code - goes in engine/
- ❌ Game content - goes in mods/
- ❌ Design specs - goes in design/
- ❌ API contracts - goes in api/
- ❌ Production tools - goes in tools/

---

## Test File Structure

### Basic Test File Pattern

```lua
-- tests2/battlescape/unit_test.lua

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Unit = require("engine.battlescape.units.unit")

-- Create suite
local suite = HierarchicalSuite.new("Unit", "tests2/battlescape/unit_test.lua")

-- ============================================================
-- Tests for: new()
-- ============================================================

-- SCENARIO 1: Happy Path
suite:testMethod("new", "Creates unit with valid parameters", function()
    local unit = Unit.new("rookie", "Test Soldier", 1)
    
    suite:assert(unit ~= nil, "Should create unit instance")
    suite:assert(unit.id == "rookie", "Should set ID correctly")
    suite:assert(unit.name == "Test Soldier", "Should set name correctly")
    suite:assert(unit.rank == 1, "Should set rank correctly")
end)

-- SCENARIO 2: Error Case
suite:testMethod("new", "Rejects invalid ID type", function()
    local ok, err = pcall(function()
        Unit.new(123, "Test", 1)  -- ID should be string
    end)
    
    suite:assert(ok == false, "Should reject invalid ID type")
end)

-- SCENARIO 3: Edge Case
suite:testMethod("new", "Handles empty name", function()
    local unit = Unit.new("rookie", "", 1)
    
    suite:assert(unit ~= nil, "Should create unit even with empty name")
    suite:assert(unit.name == "", "Should preserve empty name")
end)

-- ============================================================
-- Tests for: gainExperience()
-- ============================================================

suite:testMethod("gainExperience", "Adds positive XP correctly", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(50)
    
    suite:assert(unit.experience == 150, "Should add XP: 100 + 50 = 150")
end)

suite:testMethod("gainExperience", "Rejects negative XP", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 100
    
    unit:gainExperience(-50)
    
    suite:assert(unit.experience == 100, "Should not change with negative XP")
end)

return suite
```

---

## Running Tests

### Run All Tests
```bash
lovec tests2/runners run_all

# Or use batch file:
run\run_tests2_all.bat

# Output:
Running all tests...

Level 1: Module Coverage
  core/state_manager: 85% ✓
  battlescape/unit: 87% ✓
  
Level 2: File Results
  core/
    state_manager_test.lua: 20/20 ✓
  battlescape/
    unit_test.lua: 25/25 ✓
    
Summary: 2493 tests, 2493 passed, 0 failed
Time: 0.847s ✓
```

### Run Subsystem Tests
```bash
lovec tests2/runners run_subsystem battlescape

# Or:
run\run_tests2_subsystem.bat battlescape

# Output:
Running battlescape tests...
  unit_test.lua: 25/25 ✓
  battle_test.lua: 20/20 ✓
  combat_test.lua: 18/18 ✓
  
Total: 63/63 ✓
```

### Run Single Test File
```bash
lovec tests2/runners run_single_test battlescape/unit_test

# Or:
run\run_tests2_single.bat battlescape/unit_test

# Output:
Running unit_test.lua...
✓ new - Creates unit with valid parameters
✓ new - Rejects invalid ID type
✓ gainExperience - Adds positive XP correctly
...
25/25 tests passed
```

---

## Test Patterns

### Pattern 1: Happy Path Test
```lua
suite:testMethod("functionName", "Does expected behavior correctly", function()
    -- Arrange: Set up test data
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 100
    
    -- Act: Perform the operation
    unit:gainExperience(50)
    
    -- Assert: Verify result
    suite:assert(unit.experience == 150, "XP should increase to 150")
end)
```

### Pattern 2: Error Case Test
```lua
suite:testMethod("functionName", "Rejects invalid input", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 100
    
    -- Should not throw, but should not modify
    unit:gainExperience(-50)
    
    suite:assert(unit.experience == 100, "Should ignore negative XP")
end)
```

### Pattern 3: Edge Case Test
```lua
suite:testMethod("functionName", "Handles boundary condition", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 0
    
    unit:gainExperience(0)
    
    suite:assert(unit.experience == 0, "Zero XP should not error")
end)
```

### Pattern 4: Integration Test
```lua
suite:testMethod("functionName", "Integrates with other systems", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 95
    unit.can_promote = false
    
    unit:gainExperience(5)  -- Reaches 100 XP
    
    suite:assert(unit.experience == 100, "XP should reach threshold")
    suite:assert(unit.can_promote == true, "Should trigger promotion flag")
end)
```

---

## Integration with Other Folders

### engine/ → tests2/
Every public function in engine should have tests:
- **Engine:** `function Unit:gainExperience(amount)`
- **Tests:** `tests2/battlescape/unit_test.lua` with 3+ scenarios

### api/ → tests2/
Tests verify API contract compliance:
- **API:** Defines behavior and validation rules
- **Tests:** Verify implementation matches contract

### design/ → tests2/
Tests validate design requirements:
- **Design:** "Units gain 5 XP per kill"
- **Tests:** Verify XP gain is exactly 5

### tests2/ → CI/CD
Tests run automatically on every commit:
- Pre-commit hook runs relevant tests
- CI/CD runs full suite
- Deployment blocked if tests fail

---

## Test Generation

### Generate Test Stubs
```bash
lua tests2/generators/scaffold_module_tests.lua engine/battlescape/units/unit.lua

# Analyzes unit.lua for public functions
# Generates tests2/battlescape/unit_test.lua with stubs

# Output:
Generated: tests2/battlescape/unit_test.lua
Found 8 public functions
Created 24 test stubs (3 scenarios each)
TODO: Implement test logic
```

### Find Untested Code
```bash
lua tests2/generators/analyze_engine_structure.lua

# Output:
Module Coverage Analysis

Untested modules:
  economy/market.lua: 0% (0/15 functions)
  politics/diplomacy.lua: 0% (0/12 functions)

Low coverage (<75%):
  battlescape/ai.lua: 68% (15/22 functions)
  geoscape/world.lua: 72% (18/25 functions)

Action: Run scaffold_module_tests.lua for untested modules
```

---

## Coverage Analysis

### Run Coverage Report
```bash
lovec tests2/runners run_coverage

# Output:
Module Coverage Report

core/
  state_manager.lua: 85% (17/20 functions) ✓
  event_bus.lua: 92% (23/25 functions) ✓
  
battlescape/
  unit.lua: 87% (20/23 functions) ✓
  battle.lua: 78% (18/23 functions) ✓
  
Overall: 82% (145/177 functions) ✓

Untested functions:
  - battle.lua: _internalHelper() (private)
  - unit.lua: _debugPrint() (debug only)
```

---

## Validation

### Test Quality Checklist

- [ ] All public functions have tests (coverage >75%)
- [ ] Each function tested with 3+ scenarios
- [ ] Happy path covered (normal operation)
- [ ] Error cases covered (invalid inputs)
- [ ] Edge cases covered (boundaries)
- [ ] Tests are fast (<10ms each)
- [ ] Tests are independent (no shared state)
- [ ] Test names are descriptive
- [ ] Assertions have clear messages
- [ ] Full suite runs in <1 second

---

## Tools

### Test Runner
```bash
# Multiple modes available:
lovec tests2/runners run_all              # All tests
lovec tests2/runners run_subsystem core   # One subsystem
lovec tests2/runners run_single_test core/state_manager_test  # One file
lovec tests2/runners run_coverage         # Coverage analysis
lovec tests2/runners run_failed           # Only failed tests from last run
```

### Test Generator
```bash
lua tests2/generators/scaffold_module_tests.lua <engine_file>
# Generates test stubs for all public functions
```

### Coverage Analyzer
```bash
lua tests2/generators/analyze_engine_structure.lua
# Finds untested modules and low coverage areas
```

---

## Best Practices

### 1. Test One Thing Per Test
```lua
-- GOOD: Focused test
suite:testMethod("gainExperience", "Adds XP correctly", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit.experience = 100
    unit:gainExperience(50)
    suite:assert(unit.experience == 150)
end)

-- BAD: Tests multiple things
suite:testMethod("unit", "Does everything", function()
    local unit = Unit.new("rookie", "Test", 1)
    unit:gainExperience(50)
    unit:promote()
    unit:takeDamage(10)
    -- Too much in one test!
end)
```

### 2. Use Descriptive Test Names
```lua
-- GOOD: Clear what's being tested
suite:testMethod("gainExperience", "Adds positive XP correctly", ...)
suite:testMethod("gainExperience", "Rejects negative XP", ...)

-- BAD: Vague names
suite:testMethod("gainExperience", "Test 1", ...)
suite:testMethod("gainExperience", "Test 2", ...)
```

### 3. Keep Tests Fast
```lua
-- GOOD: No I/O, pure logic
suite:testMethod("save", "Generates correct save data", function()
    local unit = Unit.new("rookie", "Test", 1)
    local data = unit:getSaveData()  -- Pure data structure
    suite:assert(data.name == "Test")
end)

-- BAD: Slow I/O operations
suite:testMethod("save", "Saves to disk", function()
    unit:saveToDisk("test.dat")  -- File I/O is SLOW!
    love.timer.sleep(0.1)  -- Never sleep in tests!
end)
```

### 4. Test Independence
```lua
-- GOOD: Fresh instance per test
suite:testMethod("test1", ..., function()
    local unit = Unit.new("rookie", "Test", 1)
    -- Test uses its own instance
end)

suite:testMethod("test2", ..., function()
    local unit = Unit.new("rookie", "Test", 1)
    -- Independent of test1
end)

-- BAD: Shared state
local shared_unit = Unit.new("rookie", "Test", 1)

suite:testMethod("test1", ..., function()
    shared_unit.experience = 100  -- Modifies shared!
end)

suite:testMethod("test2", ..., function()
    -- Depends on test1 running first!
end)
```

### 5. Clear Assertion Messages
```lua
-- GOOD: Message explains what should be true
suite:assert(unit.experience == 150, "XP should be 100 + 50 = 150")

-- BAD: No message or vague message
suite:assert(unit.experience == 150)
suite:assert(unit.experience == 150, "Failed")
```

---

## Maintenance

**On Code Change:**
- Run affected tests
- Update tests if behavior changed
- Add tests for new functions
- Verify coverage maintained

**Daily:**
- Run full test suite before committing
- Fix any failures immediately
- Review test output for warnings

**Weekly:**
- Check coverage report
- Add tests for low-coverage modules
- Review and improve slow tests

**Per Release:**
- Full test suite must pass
- Coverage >75% all modules
- No flaky tests
- Performance <1s maintained

---

**See:** tests2/README.md and tests2/QUICK_REFERENCE.md

**Related:**
- [modules/04_ENGINE_FOLDER.md](04_ENGINE_FOLDER.md) - Code being tested
- [systems/04_HIERARCHICAL_TESTING_SYSTEM.md](../systems/04_HIERARCHICAL_TESTING_SYSTEM.md) - Testing system pattern

