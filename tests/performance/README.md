# Performance Tests

## Goal / Purpose

The Performance folder contains performance and optimization test suites. These tests measure system performance, identify bottlenecks, and ensure game systems run efficiently.

## Content

- Performance measurement tests
- Optimization validation tests
- Stress tests for systems
- Benchmark tests
- Memory profiling tests

## Features

- **Performance Metrics**: Measure execution time
- **Memory Usage**: Track memory consumption
- **Stress Testing**: Test under load
- **Regression Detection**: Catch performance regressions
- **Optimization Validation**: Verify improvements

## Test Categories

- **Rendering**: Frame rate and draw call performance
- **Pathfinding**: Path calculation efficiency
- **Combat Resolution**: Turn resolution speed
- **Map Generation**: Procedural generation performance
- **AI Decisions**: AI computation speed
- **Memory**: Memory usage and leaks

## Running Tests

```bash
lovec tests/runners performance
```

## Performance Standards

Target performance metrics:
- Frame rate: 60 FPS minimum
- Map generation: < 500ms
- Pathfinding: < 100ms
- Combat turn: < 200ms
- Memory: < 256MB for typical game state

## See Also

- [Tests README](../README.md) - Testing overview
- [Test Development Guide](../TEST_DEVELOPMENT_GUIDE.md) - How to write tests
- [Performance & Optimization Guides](.../.github/instructions/🚀%20Performance%20&%20Optimization.instructions.md) - Optimization guidelines
