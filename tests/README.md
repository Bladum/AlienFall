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

### Quick Start

```bash
# Run ALL tests (recommended)
lovec tests/runners

# Or use Windows batch file
run_tests.bat
```

### Selective Test Runner ✨ UPDATED

Run specific test categories:

```bash
# Run specific category
cd tests/runners
lovec . [category]

# Available categories:
# - core         Core systems (6 files, 63 tests)
# - combat       Combat systems (6 files, 64 tests)
# - basescape    Base management (2 files, 21 tests)
# - geoscape     Geoscape & World (1 file, 10 tests)
# - economy      Economy & Research (1 file, 19 tests) ✨ NEW
# - politics     Politics & Karma (1 file, 19 tests) ✨ NEW
# - widgets      UI Widgets (2 files, 37 tests) ✨ NEW
# - maps         Map Generation (1 file, 12 tests) ✨ NEW
# - tutorial     Tutorial System (1 file, 7 tests) ✨ NEW
# - ai           AI Systems (1 file, 11 tests) ✨ NEW
# - performance  Performance benchmarks (1 file, 7 benchmarks)
# - all          All tests (default)

# Examples:
cd tests/runners && lovec . core
cd tests/runners && lovec . combat
cd tests/runners && lovec . widgets
cd tests/runners && lovec . economy
cd tests/runners && lovec . politics

# Get help
cd tests/runners && lovec . help
```

### Comprehensive Test Runner

Run all tests at once:

```bash
# From project root
lovec tests/runners

# Or run the all-tests script directly
lovec tests/runners/run_all_tests.lua
```

This will run:
- All unit tests (149 test cases) ✨ UPDATED
- All integration tests (30 scenarios) ✨ UPDATED
- All widget tests (37 test cases) ✨ NEW
- Performance benchmarks (7 categories)
- Display summary and results

**Total: 205+ tests across 25 files** ✨ UPDATED

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

### Unit Tests (`unit/`) ✨ UPDATED
Individual module tests with assertions and validation. **Total: 149 test cases**

**Core Systems (63 tests):**
- `test_state_manager.lua` - State transitions, screen management, push/pop stack (6 tests)
- `test_audio_system.lua` - Audio loading, volume control, category management (7 tests)
- `test_data_loader.lua` - Data loading, validation, caching, serialization (8 tests)
- `test_spatial_hash.lua` - Spatial partitioning, query performance, dynamic updates (11 tests)
- `test_save_system.lua` - Save/load, serialization, versioning, validation (10 tests)
- `test_mod_manager.lua` - Mod loading, priorities, conflicts, hooks (11 tests)

**Combat Systems (64 tests):**
- `test_pathfinding.lua` - A* pathfinding, obstacles, edge cases, large grids (10 tests)
- `test_hex_math.lua` - Hex coordinate systems, distance, neighbors, line interpolation (15 tests)
- `test_movement_system.lua` - Movement costs, TU consumption, terrain modifiers (12 tests)
- `test_accuracy_system.lua` - Hit calculation, cover bonuses, range penalties (11 tests)

**Base Management (21 tests):**
- `test_facility_system.lua` - Base management, construction, capacity calculations (11 tests)

**Geoscape (10 tests):**
- `test_world_system.lua` - World generation, hex coordinates, provinces, day/night (10 tests)

**Economy Systems (19 tests):** ✨ NEW
- `test_research_system.lua` - Research projects, tech tree, prerequisites, unlocks (19 tests)

**Politics Systems (19 tests):** ✨ NEW
- `test_karma_system.lua` - Karma tracking, levels, effects, black market access (19 tests)

**Run Categories:**
```bash
cd tests/runners && lovec . core
cd tests/runners && lovec . combat
cd tests/runners && lovec . economy
cd tests/runners && lovec . politics
```

### Widget Tests (`widgets/`) ✨ NEW
Tests for UI widget components with grid alignment verification. **Total: 37 tests**

**New Tests:**
- `test_base_widget.lua` - Grid snapping, position/size, states, parent-child (21 tests)
- `test_button.lua` - Click events, hover states, text management, enable/disable (16 tests)

**Run Category:**
```bash
cd tests/runners && lovec . widgets
```

### Integration Tests (`integration/`) ✨ UPDATED
Tests that verify multiple systems working together. **Total: 30 scenarios**

**Tests:**
- `test_combat_integration.lua` - Full combat flow with units, weapons, damage, grenades (10 scenarios)
- `test_base_integration.lua` - Complete base management workflows, construction, research (10 scenarios)
- `test_battlescape_workflow.lua` - Tactical combat deployment and mission flow (10 scenarios)
- `test_mapblock_integration.lua` - MapBlock system integration
- `test_phase2.lua` - Phase 2 integration tests

**Run Categories:**
```bash
cd tests/runners && lovec . combat
cd tests/runners && lovec . basescape
```

### Performance Tests (`performance/`) ✨ UPDATED
Benchmarks and performance profiling tests. **Total: 7 benchmark categories**

**Tests:**
- `test_game_performance.lua` - Comprehensive performance benchmarks:
  - Pathfinding algorithms (short, medium, long paths)
  - Hex math operations (conversions, distance calculations)
  - Unit management (100 units, filtering, stat calculations)
  - Data structures (arrays, tables, lookups, iteration)
  - String operations (concatenation, formatting)
  - Collision detection (point-circle, circle-circle)
  - Memory allocation and garbage collection

**Run Category:**
```bash
lovec tests/runners/run_selective_tests.lua performance
```

### Test Runners (`runners/`)
All `run_*.lua` files that can be executed directly with Love2D.

**New Runners:**
- `run_all_tests.lua` - Comprehensive test suite runner (all tests)
- `run_selective_tests.lua` - ⭐ **Selective category runner** (run by category)
- `main.lua` + `conf.lua` - Standalone Love2D test application

**Existing Runners:**
- Various specialized test runners for specific systems

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
