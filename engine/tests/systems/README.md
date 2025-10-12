# System Tests

Core system test suite.

## Overview

The system tests directory contains unit tests for core game systems and infrastructure.

## Files

### test_mod_system.lua
Mod loading and management system tests.

### test_performance.lua
Performance benchmarking and optimization tests.

### test_phase2.lua
Phase 2 feature and integration tests.

## Test Coverage

- **Mod System**: Loading, unloading, and conflict resolution
- **Performance**: Frame rate, memory usage, and bottlenecks
- **Integration**: Cross-system interactions and data flow
- **Edge Cases**: Error conditions and boundary testing

## Usage

Run system tests individually:

```bash
lua tests/systems/test_mod_system.lua
```

Or through the main test runner:

```lua
local TestRunner = require("tests.test_runner")
TestRunner:runSystemTests()
```

## Test Categories

### Unit Tests
- Individual function and method testing
- Mock dependencies and isolated testing
- Fast execution for continuous integration

### Integration Tests
- Multi-system interaction testing
- End-to-end workflow validation
- Realistic usage scenarios

### Performance Tests
- Benchmarking critical paths
- Memory leak detection
- Scalability testing

## Dependencies

- **Core Systems**: All engine systems under test
- **Test Framework**: Assertion and timing utilities
- **Mock Objects**: Test doubles for dependencies