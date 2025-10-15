# Tests

All test files for the XCOM Simple project.

## Directory Structure

```
tests/
├── runners/          Test runners (run_*.lua files)
├── unit/             Unit tests for individual modules
├── integration/      Integration tests
├── performance/      Performance benchmarks
├── battlescape/      Battlescape-specific tests
├── battle/           Battle system tests
├── systems/          System tests
├── widgets/          Widget tests
└── README.md         This file
```

## Running Tests

### Test Runners

Test runners are standalone Love2D applications that can be run directly:

```bash
# From project root
lovec tests/runners/run_battlescape_test.lua
lovec tests/runners/run_map_generation_test.lua
lovec tests/runners/run_integration_test.lua
```

Note: Most test runners expect to be run from the project root directory so they can access engine code.

### Unit Tests

Unit tests are typically loaded and run by test runners:

```lua
local testModule = require("tests.unit.test_module_name")
testModule.runAll()
```

## Test Categories

### Test Runners (`runners/`)
All `run_*.lua` files that can be executed directly with Love2D.

### Unit Tests (`unit/`)
Individual module tests with assertions and validation.

### Integration Tests (`integration/`)
Tests that verify multiple systems working together.

### Performance Tests (`performance/`)
Benchmarks and performance profiling tests.

## Writing Tests

### Test Runner Template

```lua
-- tests/runners/run_my_test.lua
package.path = package.path .. ";../../engine/?.lua;../../engine/?/init.lua"

local MySystem = require("systems.my_system")

function love.load()
    print("=== My System Test ===")
    
    -- Run tests
    local result = MySystem.doSomething()
    assert(result == expected, "Test failed: expected " .. expected)
    
    print("✓ All tests passed!")
    love.event.quit(0)
end

function love.draw()
    love.graphics.print("Running tests...", 10, 10)
end
```

### Unit Test Template

```lua
-- tests/unit/test_my_module.lua
local TestSuite = {}

function TestSuite.testFeature()
    local result = myFunction(input)
    assert(result == expected, "Feature test failed")
end

function TestSuite.runAll()
    print("Running test suite...")
    TestSuite.testFeature()
    print("✓ All tests passed!")
end

return TestSuite
```

## Mock Data

Mock data for tests is located in the `mock/` folder at project root:

```lua
local MockUnits = require("mock.units")
local testUnit = MockUnits.getSoldier("Test", "ASSAULT")
```

See `mock/README.md` for more information.

## Best Practices

1. **Run from project root** - Tests expect to access engine code
2. **Use mock data** - Don't create test data inline, use mock/ folder
3. **Clean up** - Tests should not leave files or modify game state
4. **Fast execution** - Tests should run quickly (< 5 seconds each)
5. **Clear output** - Print clear pass/fail messages
6. **Exit cleanly** - Call `love.event.quit(0)` on success

## Troubleshooting

### "Module not found" errors
- Make sure you're running from project root
- Check package.path includes engine directory

### Asset loading fails
- Tests should use relative paths from project root
- Example: `"mods/core/tilesets/..."` not `"engine/mods/..."`

### Tests hang or don't exit
- Make sure to call `love.event.quit(0)` when tests complete
- Add timeout handling for long-running tests

---

**Note:** This folder was reorganized on October 14, 2025 to consolidate all test files from engine/ and project root into a single tests/ directory.
