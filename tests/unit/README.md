# Unit Tests

## Goal / Purpose

The Unit folder contains unit test suites for individual components and functions. These tests verify basic functionality of isolated code components without dependencies.

## Content

- Unit test files for core systems
- Component testing
- Function testing
- Utility testing
- Mock-based testing

## Features

- **Unit Testing**: Test individual components
- **Isolation**: Test in isolation from dependencies
- **Coverage**: Comprehensive code coverage
- **Regression Prevention**: Catch component breaking changes
- **Documentation**: Tests document expected behavior

## Test Categories

- **Core Systems**: Core engine components
- **Utilities**: Utility function testing
- **Math**: Mathematical function testing
- **Data Structures**: Collection testing
- **State Management**: State machine testing
- **Configuration**: Config loading/parsing

## Writing Unit Tests

1. Test one component at a time
2. Use mock data for dependencies
3. Test both success and failure cases
4. Verify edge cases
5. Keep tests fast and simple

## Running Tests

```bash
lovec tests/runners unit
```

## See Also

- [Tests README](../README.md) - Testing overview
- [Test Development Guide](../TEST_DEVELOPMENT_GUIDE.md) - How to write tests
- [Mock Data](../mock/README.md) - Mock data system
