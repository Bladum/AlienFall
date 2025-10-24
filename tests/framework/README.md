# Test Framework Documentation

**Version:** 2.0
**Status:** Phase 2-3 Complete
**Last Updated:** October 24, 2025

---

## Quick Start

### Basic Test Structure

```lua
local TestSuite = require("tests.framework.test_suite")
local Assertions = require("tests.framework.assertions")

-- Create test suite
local suite = TestSuite:new("My Module")

-- Add tests
suite:test("should do something", function()
    local result = functionUnderTest()
    Assertions.assertEqual(result, expected)
end)

suite:test("should handle errors", function()
    Assertions.assertThrows(function()
        functionThatFails()
    end)
end)

-- Return suite for registration
return suite
```

### Running Tests

```bash
# All tests
lovec tests/runners/main.lua

# Specific module
lovec tests/runners/main.lua battlescape

# Specific file
lovec tests/runners/main.lua battlescape combat

# Specific test
lovec tests/runners/main.lua specific "test name"

# By tag
lovec tests/runners/main.lua --tag regression

# With coverage
TEST_COVERAGE=1 lovec tests/runners/main.lua
```

---

## Framework Components

### 1. Assertions (`tests/framework/assertions.lua`)

Comprehensive assertion library with 20+ assertions:

```lua
local Assertions = require("tests.framework.assertions")

-- Equality
Assertions.assertEqual(actual, expected, message)
Assertions.assertNotEqual(actual, expected, message)

-- Boolean
Assertions.assertTrue(condition, message)
Assertions.assertFalse(condition, message)

-- Nil checks
Assertions.assertIsNil(value, message)
Assertions.assertIsNotNil(value, message)

-- Type checks
Assertions.assertIsTable(value, message)
Assertions.assertIsFunction(value, message)
Assertions.assertIsString(value, message)
Assertions.assertIsNumber(value, message)

-- Comparisons
Assertions.assertGreater(a, b, message)
Assertions.assertLess(a, b, message)
Assertions.assertGreaterOrEqual(a, b, message)
Assertions.assertLessOrEqual(a, b, message)
Assertions.assertInRange(value, min, max, message)

-- Table operations
Assertions.assertContains(table, value, message)
Assertions.assertNotContains(table, value, message)
Assertions.assertTableEquals(table1, table2, message)
Assertions.assertHasKey(table, key, message)
Assertions.assertNotHasKey(table, key, message)

-- String matching
Assertions.assertMatches(string, pattern, message)

-- Function execution
Assertions.assertThrows(fn, expectedError, message)
Assertions.assertDoesNotThrow(fn, message)

-- Get statistics
local stats = Assertions.getStats()
-- {total = 45, failures = 2, passed = 43}
```

### 2. TestSuite (`tests/framework/test_suite.lua`)

Base class for organizing tests:

```lua
local TestSuite = require("tests.framework.test_suite")

local suite = TestSuite:new("Module Name")

-- Add test
suite:test("test name", function()
    -- test code
end)

-- Skip test
suite:skip("slow test", function()
    -- skipped
end)

-- Tag test (for filtering)
suite:test("test", {tag = "regression"}, function()
    -- test code
end)

-- Setup/teardown
suite:before(function()
    -- Runs once before all tests
end)

suite:after(function()
    -- Runs once after all tests
end)

suite:beforeEach(function()
    -- Runs before each test
end)

suite:afterEach(function()
    -- Runs after each test
end)

-- Describe groups (for organization)
suite:describe("Feature Group", function()
    suite:test("test 1", function() end)
    suite:test("test 2", function() end)
end)

-- Run suite
local success = suite:run()

-- Get results
local results = suite:getResults()
-- {passed = 10, failed = 1, skipped = 2, errors = {...}}
```

### 3. TestRegistry (`tests/framework/test_registry.lua`)

Discovers and manages all tests hierarchically:

```lua
local TestRegistry = require("tests.framework.test_registry")

-- Register a suite
TestRegistry.register("tests.unit.battlescape.combat.test_damage", suite)

-- Get all tests
local all = TestRegistry.getAll()

-- Get by category
local unit = TestRegistry.getByCategory("unit")

-- Get by module
local battlescape = TestRegistry.getByModule("battlescape")

-- Get by file
local damage = TestRegistry.getByFile("test_damage")

-- Discover tests in directory
local files = TestRegistry.discoverTests("tests/unit")

-- Get test count
local count = TestRegistry.count()

-- Print structure
TestRegistry.printStructure()
```

### 4. TestExecutor (`tests/framework/test_executor.lua`)

Executes tests with multiple modes:

```lua
local TestExecutor = require("tests.framework.test_executor")

-- Execute all tests
TestExecutor.executeAll({coverage = true})

-- Execute module
TestExecutor.executeModule("battlescape")

-- Execute file
TestExecutor.executeFile("test_damage")

-- Execute specific test
TestExecutor.executeTest("test_name")

-- Execute by tag
TestExecutor.executeByTag("regression")

-- Custom options
TestExecutor.execute({
    mode = "module",           -- all, module, file, specific
    module = "battlescape",
    coverage = true,
    outputFormat = "html"      -- text, json, html
})
```

### 5. ReportGenerator (`tests/framework/report_generator.lua`)

Generates test reports:

```lua
local ReportGenerator = require("tests.framework.report_generator")

-- Generate report (printed to console)
local report = ReportGenerator.generateReport(results, "text")

-- Write report to file
ReportGenerator.writeReport(results, "json", "tests/reports/report.json")
ReportGenerator.writeReport(results, "html", "tests/reports/report.html")
```

---

## File Organization

```
tests/
├── framework/
│   ├── assertions.lua           ✓ COMPLETE
│   ├── test_suite.lua           ✓ COMPLETE
│   ├── test_registry.lua        ✓ COMPLETE
│   ├── test_executor.lua        ✓ COMPLETE
│   ├── report_generator.lua     ✓ COMPLETE
│   ├── coverage_analyzer.lua    (TODO)
│   ├── test_helpers.lua         (TODO)
│   └── README.md                ✓ THIS FILE
│
├── runners/
│   ├── main.lua                 (use new framework)
│   ├── run_all.lua              (TODO)
│   ├── run_module.lua           (TODO)
│   └── README.md                (TODO)
│
├── unit/                        (organize by module)
├── integration/                 (organize by module)
├── performance/                 (organize by module)
├── mock/                        (mock data)
└── README.md                    (master documentation)
```

---

## Usage Examples

### Example 1: Simple Unit Test

```lua
-- tests/unit/battlescape/combat/test_damage.lua
local TestSuite = require("tests.framework.test_suite")
local Assertions = require("tests.framework.assertions")
local Combat = require("engine.battlescape.combat.combat_system")

local suite = TestSuite:new("Combat Damage System")

suite:beforeEach(function()
    -- Setup for each test
end)

suite:test("calculates damage correctly", function()
    local unit = createMockUnit({strength = 10})
    local damage = Combat.calculateDamage(unit, {defense = 5})
    Assertions.assertEqual(damage, 5)  -- 10 - 5
end)

suite:test("critical hit doubles damage", function()
    local unit = createMockUnit({strength = 10, criticalChance = 1.0})
    local damage = Combat.calculateDamage(unit, {defense = 0})
    Assertions.assertEqual(damage, 20)  -- 10 * 2
end)

suite:test("damage cannot be negative", function()
    local unit = createMockUnit({strength = 5})
    local damage = Combat.calculateDamage(unit, {defense = 10})
    Assertions.assertGreaterOrEqual(damage, 0)
end)

return suite
```

### Example 2: Integration Test with Fixtures

```lua
-- tests/integration/test_geoscape_missions.lua
local TestSuite = require("tests.framework.test_suite")
local Assertions = require("tests.framework.assertions")

local suite = TestSuite:new("Geoscape Mission Integration")

local game, mission

suite:beforeEach(function()
    -- Setup game state
    game = createMockGame()
    mission = game:createMission("alien_invasion")
end)

suite:afterEach(function()
    -- Cleanup
    if game then
        game:shutdown()
    end
end)

suite:test("mission generates with correct properties", function()
    Assertions.assertIsNotNil(mission)
    Assertions.assertEqual(mission:getStatus(), "pending")
    Assertions.assertGreater(mission:getEnemyCount(), 0)
end)

suite:test("mission updates state transitions correctly", function()
    mission:start()
    Assertions.assertEqual(mission:getStatus(), "active")

    mission:complete()
    Assertions.assertEqual(mission:getStatus(), "complete")
end)

return suite
```

### Example 3: Error Handling Test

```lua
-- tests/unit/core/test_state_manager.lua
local TestSuite = require("tests.framework.test_suite")
local Assertions = require("tests.framework.assertions")
local StateManager = require("engine.core.state_manager")

local suite = TestSuite:new("State Manager")

suite:test("invalid state transition throws error", function()
    local manager = StateManager:new()
    manager:setState("battlescape")

    Assertions.assertThrows(function()
        manager:setState("invalid_state")
    end, "invalid state")
end)

suite:test("state change triggers callbacks", function()
    local manager = StateManager:new()
    local callbackCalled = false

    manager:onStateChange(function(newState)
        callbackCalled = true
    end)

    manager:setState("geoscape")
    Assertions.assertTrue(callbackCalled)
end)

return suite
```

---

## Test Organization

### By Category

- **unit/**: Individual system/module tests
  - `unit/battlescape/combat/test_damage.lua`
  - `unit/geoscape/world/test_generation.lua`
  - `unit/core/test_state_manager.lua`

- **integration/**: Cross-system tests
  - `integration/test_geoscape_battlescape.lua`
  - `integration/test_campaign_flow.lua`

- **performance/**: Benchmarks
  - `performance/test_rendering_performance.lua`
  - `performance/test_pathfinding_speed.lua`

### Naming Convention

- File: `test_*.lua` (e.g., `test_damage_system.lua`)
- Suite: Descriptive name (e.g., "Combat Damage System")
- Test: Starts with "should" or "test" (e.g., "should calculate damage")

---

## Best Practices

1. **One suite per file**: Keep test files focused
2. **Clear names**: Make test names describe what they test
3. **Small scope**: Each test should test one thing
4. **Use fixtures**: Setup/teardown for consistent state
5. **Mock dependencies**: Isolate what you're testing
6. **Good error messages**: Help debugging with clear assertions
7. **Tag related tests**: Group by feature/regression/slow/etc
8. **Keep tests fast**: Most tests should run in < 100ms

---

## Troubleshooting

### Test not found

Check the file path and module name match the registry structure.

### Fixture not running

Ensure you're using `beforeEach`/`afterEach` for per-test setup.

### Assertion error unclear

Add a descriptive message as the last parameter to assertions.

### Tests slow

- Check for expensive operations in setUp/tearDown
- Use mocks instead of real objects
- Consider using `skip` for slow tests

---

## Next Steps

1. ✓ Phase 1: Framework Design
2. ✓ Phase 2: Core Implementation (assertions, suite, registry, executor)
3. (TODO) Phase 3: Organize existing tests
4. (TODO) Phase 4: Multiple execution modes
5. (TODO) Phase 5: Code coverage
6. (TODO) Phase 6: Documentation & helpers
7. (TODO) Phase 7: Migration
8. (TODO) Phase 8: Self-testing

---

## Files

- `assertions.lua` - 20+ assertions with descriptive messages
- `test_suite.lua` - Base class for tests with fixtures
- `test_registry.lua` - Hierarchical test discovery
- `test_executor.lua` - Execute tests with filters
- `report_generator.lua` - Generate reports (text/JSON/HTML)
- `coverage_analyzer.lua` - (TODO) Code coverage tracking
- `test_helpers.lua` - (TODO) Common helper methods
