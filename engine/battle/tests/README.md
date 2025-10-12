# Tests

Test suites for battle system validation and quality assurance.

## Overview

The tests folder contains automated test suites that validate battle system functionality. Tests cover unit movement, combat mechanics, system integration, and performance benchmarks to ensure code quality and prevent regressions.

## Files

### test_all_systems.lua
Comprehensive test suite covering all battle systems. Tests integration between movement, vision, combat, and environmental systems.

### test_ecs_components.lua
Entity Component System validation tests. Verifies component interactions, entity creation, and ECS architecture correctness.

## Usage

Run tests from the command line:

```bash
# Run all battle tests
love engine --test battle

# Run specific test suite
love engine --test battle test_ecs_components
```

## Test Categories

- **Unit Tests**: Individual system functionality
- **Integration Tests**: System interactions and data flow
- **Performance Tests**: Benchmarking and optimization validation
- **Regression Tests**: Prevent reintroduction of fixed bugs

## Architecture

- **Test Framework**: Custom test runner with assertions
- **Mock Objects**: Simulated battle state for isolated testing
- **Performance Metrics**: Timing and memory usage tracking
- **Automated CI**: Tests run on code changes

## Dependencies

- **Battle Systems**: All systems under test
- **Test Framework**: Assertion and reporting utilities
- **Mock Data**: Test fixtures and mock objects