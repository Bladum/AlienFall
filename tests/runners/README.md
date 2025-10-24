# Test Runners

## Goal / Purpose

The Runners folder contains test runner scripts and utilities that execute the test suites. These scripts launch different test categories and provide test execution infrastructure.

## Content

- Main test runner (`run_tests.lua`)
- Category-specific runners
- Test configuration and setup
- Test utilities and helpers
- Quick test runners

## Features

- **Test Execution**: Run tests across categories
- **Selective Testing**: Run specific test suites
- **Coverage Reporting**: Generate test coverage
- **Result Formatting**: Clear test output
- **Continuous Integration**: CI/CD integration support

## Running Tests

```bash
# Run all tests
lovec tests/runners

# Run specific suite
lovec tests/runners battlescape

# Run with coverage
$env:TEST_COVERAGE=1; lovec tests/runners
```

## Available Test Suites

- `battlescape` - Tactical combat tests
- `geoscape` - Strategic layer tests
- `basescape` - Base management tests
- `unit` - Unit/component tests
- `systems` - System tests
- `integration` - Integration tests
- `battle` - Battle system tests
- `widgets` - UI widget tests
- `performance` - Performance tests

## Test Configuration

Test runners use configuration:
- Test discovery patterns
- Execution timeout
- Coverage settings
- Output formatting
- Mock data loading

## See Also

- [Tests README](../README.md) - Testing overview
- [Test Development Guide](../TEST_DEVELOPMENT_GUIDE.md) - How to write tests
- [AI Agent Test Guide](../AI_AGENT_TEST_GUIDE.md) - AI testing guide
