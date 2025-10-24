# Test Suites: Battlescape

## Goal / Purpose

The Battlescape folder contains all test suites for battlescape tactical combat systems. These tests verify map generation, unit behavior, combat resolution, and all tactical gameplay features.

## Content

- Test files for battlescape systems
- Map generation tests
- Combat system tests
- Unit behavior tests
- Integration tests for battlescape

## Features

- **Comprehensive Coverage**: Test all battlescape systems
- **Unit Tests**: Individual component testing
- **Integration Tests**: System interaction verification
- **Performance Tests**: Ensure tactical systems run efficiently
- **Regression Tests**: Catch breaking changes

## Test Categories

- **Map Generation**: Procedural map creation
- **Line of Sight**: Visibility calculations
- **Pathfinding**: Unit movement algorithms
- **Combat System**: Damage, accuracy, effects
- **AI Behavior**: Enemy unit decisions
- **Entity System**: ECS component management

## Running Tests

```bash
lovec tests/runners battlescape
```

## See Also

- [Tests README](../README.md) - Testing overview
- [Test Development Guide](../TEST_DEVELOPMENT_GUIDE.md) - How to write tests
- [Battlescape System](../../engine/battlescape/README.md) - System implementation
