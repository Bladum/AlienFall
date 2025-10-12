# Tests

Test suite for XCOM Simple game systems.

## Overview

The tests directory contains unit tests, integration tests, and validation scripts for all game systems.

## Test Categories

### Unit Tests
Individual component testing:
- **run_tests.lua**: Main test runner
- **test_battle_systems.lua**: Battle mechanics validation
- **test_mapblock_integration.lua**: Map block system tests
- **test_performance.lua**: Performance benchmarking
- **test_phase2.lua**: Phase 2 feature tests

### Battle Tests
Tactical combat system validation:
- **battle/test_all_systems.lua**: Complete battle system test
- **battle/test_ecs_components.lua**: Entity component tests

### System Tests
Core system validation:
- **systems/test_*.lua**: Individual system tests

## Usage

```bash
# Run all tests
lua test_runner.lua

# Run specific test suite
lua tests/test_battle_systems.lua

# Run with Love2D console
lovec engine --test
```

## Test Structure

Each test file follows this pattern:
```lua
local TestSuite = {}

function TestSuite:test_name()
    -- Setup
    local result = testedFunction(input)
    
    -- Assert
    assert(result == expected, "Test failed: " .. tostring(result))
end

return TestSuite
```

## Test Coverage

- **Battle Systems**: Turn management, unit selection, camera
- **Map Generation**: Procedural terrain and validation
- **UI Widgets**: Component functionality and theming
- **Data Loading**: Configuration and mod loading
- **Performance**: Frame rate and memory usage

## Continuous Integration

Tests run automatically:
- **Pre-commit**: All tests must pass
- **Build Process**: Integration test validation
- **Release**: Full test suite execution

## Dependencies

- **Test Framework**: Custom assertion library
- **Mock Data**: Test fixtures and mock objects
- **Game Systems**: All tested components
- **Love2D**: Runtime environment for integration tests