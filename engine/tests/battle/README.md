# Battle Tests

Tactical combat system test suite.

## Overview

The battle tests directory contains unit tests and integration tests for the tactical combat systems.

## Files

### test_battlescape_systems.lua
Comprehensive test suite for battlescape functionality.

### test_battle_systems.lua
Core battle system validation tests.

### test_mapblock_integration.lua
Map block system integration tests.

## Test Coverage

- **Turn Management**: Turn order and phase transitions
- **Unit Systems**: Unit creation, movement, and combat
- **Map Systems**: Terrain, line-of-sight, and pathfinding
- **Camera**: Viewport controls and positioning
- **Rendering**: Visual system correctness

## Usage

Run battle tests with the test runner:

```bash
lua tests/battle/test_battlescape_systems.lua
```

Or run all battle tests:

```lua
local TestRunner = require("tests.test_runner")
TestRunner:runBattleTests()
```

## Test Structure

Each test follows the pattern:

```lua
function TestBattlescape:test_unit_movement()
    -- Setup test scenario
    local unit = createTestUnit()
    local battlefield = createTestBattlefield()

    -- Execute test
    local success = battlefield:moveUnit(unit, targetPosition)

    -- Assert results
    assert(success, "Unit movement failed")
    assert(unit.position == targetPosition, "Unit not at target")
end
```

## Dependencies

- **Battle Systems**: All tactical combat components
- **Test Framework**: Assertion and mocking utilities
- **Mock Data**: Test fixtures and scenarios