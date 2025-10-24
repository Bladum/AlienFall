# Test Suites: Geoscape

## Goal / Purpose

The Geoscape folder contains all test suites for geoscape strategic systems. These tests verify world map, mission generation, campaign progression, and all strategic layer features.

## Content

- Test files for geoscape systems
- World generation tests
- Mission generation tests
- Campaign progression tests
- Integration tests for geoscape

## Features

- **Strategic Testing**: Test strategic layer systems
- **Unit Tests**: Individual component testing
- **Integration Tests**: System interaction verification
- **Campaign Flow**: Test campaign progression
- **Procedural Generation**: Test world generation

## Test Categories

- **World Map**: Hex grid and geography
- **Mission Generation**: Mission creation and distribution
- **Campaign Progression**: Phase transitions and events
- **Economic Systems**: Resource management
- **Diplomatic Systems**: Faction relationships
- **Scheduling**: Time and turn management

## Running Tests

```bash
lovec tests/runners geoscape
```

## See Also

- [Tests README](../README.md) - Testing overview
- [Test Development Guide](../TEST_DEVELOPMENT_GUIDE.md) - How to write tests
- [Geoscape System](../../engine/geoscape/README.md) - System implementation
