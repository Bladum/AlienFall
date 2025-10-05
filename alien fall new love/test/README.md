# Alien Fall Test Suite

This directory contains the comprehensive test suite for the Alien Fall game engine, designed to work similarly to pytest for Python.

## Overview

The test suite uses a custom lightweight testing framework designed to work with Love2D. It provides unit tests for all major components including data loading, service management, and mod system functionality.

## Directory Structure

```
test/
├── test_framework.lua       # Core testing framework (assertions, test runner)
├── test_runner.lua          # Test discovery and execution
├── test_utilities.lua       # Test utilities and helper functions
├── test_toml_loader.lua     # TOML parser tests
├── test_data_registry.lua   # Data registry tests
├── test_service_registry.lua # Service registry tests
├── test_data_loading.lua    # Data loading integration tests
├── test_mod_structure.lua   # Mod structure validation tests
└── README.md               # This file
```

## Running Tests (pytest-style)

### Run All Tests
```bash
# From VS Code: Ctrl+Shift+T or Command Palette → Tasks: Run Task → Run Lua Tests
love . --test
```

### Run Specific Test File
```bash
# From VS Code: Ctrl+Shift+R or Command Palette → Tasks: Run Task → Run Specific Test File
love . --test-file test.test_toml_loader
```

### Watch Mode (Continuous Testing)
```bash
# From VS Code: Command Palette → Tasks: Run Task → Run Lua Tests (Watch Mode)
love . --test-watch
```

### Keyboard Shortcuts
- `Ctrl+Shift+T`: Run all tests
- `Ctrl+Shift+R`: Run specific test file
- `F5`: Run game (normal mode)
- `Shift+F5`: Run game (debug mode)

## Writing Tests

### Test Structure
Each test file follows this pattern:

```lua
local test_framework = require "test_framework"

local my_tests = {}

function my_tests.run()
    test_framework.run_suite("My Component", {
        test_basic_functionality = my_tests.test_basic_functionality,
        test_edge_cases = my_tests.test_edge_cases,
        test_error_handling = my_tests.test_error_handling
    })
end

function my_tests.test_basic_functionality()
    local result = my_function("input")
    test_framework.assert_equal(result, "expected_output")
end

function my_tests.test_edge_cases()
    test_framework.assert_true(some_condition())
    test_framework.assert_not_nil(some_value)
end

function my_tests.test_error_handling()
    local success, err = pcall(function() error_function() end)
    test_framework.assert_false(success)
    test_framework.assert_not_nil(err)
end

return my_tests
```

### Available Assertions

- `assert_equal(actual, expected, message)` - Check equality
- `assert_true(value, message)` - Check boolean true
- `assert_false(value, message)` - Check boolean false
- `assert_nil(value, message)` - Check for nil
- `assert_not_nil(value, message)` - Check for non-nil
- `assert_table_equal(actual, expected, message)` - Deep table comparison

### Test Discovery

Tests are automatically discovered by:
1. Scanning the `test/` directory for files matching `test_*.lua`
2. Loading modules with `require "test.module_name"`
3. Calling the `run()` method on each test module

### Test Output

```
Alien Fall Test Runner
======================

=== Running Test Suite: TOML Loader ===
[PASS] TOML Loader.test_basic_parsing
[PASS] TOML Loader.test_array_parsing
[FAIL] TOML Loader.test_error_handling: Expected true, got false

=== Running Test Suite: Data Registry ===
[PASS] Data Registry.test_catalog_registration
[PASS] Data Registry.test_mod_isolation

=== Test Results ===
Total: 5
Passed: 4
Failed: 1

Failures:
  TOML Loader.test_error_handling: Expected true, got false
```

## VS Code Integration

### Tasks
- **Run Lua Tests**: Runs all tests once
- **Run Lua Tests (Watch Mode)**: Runs tests and watches for changes
- **Run Specific Test File**: Prompts to select which test file to run

### Settings
The VS Code workspace is configured with:
- Lua language server support for Love2D
- Custom test task integration
- Keyboard shortcuts for common operations
- Proper Love2D globals recognition

## Best Practices

### Test Organization
- One test file per major component
- Descriptive test names that explain what they're testing
- Group related tests in suites
- Use clear assertion messages

### Test Isolation
- Each test should be independent
- Clean up any global state between tests
- Use factories for test data creation

### Performance
- Keep tests fast (target < 100ms per test)
- Use mocks/stubs for slow operations
- Parallel test execution where possible

## Continuous Integration

The test suite is designed to work with CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Tests
  run: |
    ./love-11.5-win64/lovec.exe . --test
  env:
    LOVE_TEST_MODE: true
```

Exit codes:
- `0`: All tests passed
- `1`: Some tests failed

## Writing Tests

### Test Structure
Each test file follows this pattern:

```lua
local test_framework = require "test_framework"

local my_tests = {}

function my_tests.run()
    test_framework.run_suite("My Component", {
        test_feature_one = my_tests.test_feature_one,
        test_feature_two = my_tests.test_feature_two
    })
end

function my_tests.test_feature_one()
    -- Test implementation
    test_framework.assert_equal(actual, expected)
end

return my_tests
```

### Available Assertions

- `assert_equal(actual, expected, message)` - Check equality
- `assert_true(value, message)` - Check boolean true
- `assert_false(value, message)` - Check boolean false
- `assert_nil(value, message)` - Check nil value
- `assert_not_nil(value, message)` - Check non-nil value
- `assert_table_equal(actual, expected, message)` - Check table equality

### Test Organization

1. **Unit Tests**: Test individual functions/classes
2. **Integration Tests**: Test component interactions
3. **Data Tests**: Test data loading and validation
4. **Mod Tests**: Test mod loading and integration

## Test Coverage

### Current Test Suites

- **TOML Loader**: Complete TOML 1.0 parsing functionality
- **Data Registry**: Catalog management and data retrieval
- **Service Registry**: Service initialization and dependency injection
- **Data Loading**: Mod data loading and integration
- **Utilities**: Helper functions and test data generation

### Adding New Tests

1. Create a new test file: `test_<component>.lua`
2. Implement the `run()` function that calls `test_framework.run_suite()`
3. Add individual test functions
4. Update `test_runner.lua` to include the new test file
5. Run tests to verify they pass

## Test Data

Test utilities provide sample data generation:

```lua
local test_utils = require "test.test_utilities"
local sample_mod = test_utils.create_sample_mod_config()
local sample_units = test_utils.create_sample_unit_data()
```

## Continuous Integration

The test runner returns appropriate exit codes for CI/CD:
- `0`: All tests passed
- `1`: Some tests failed

## Best Practices

1. **Descriptive Names**: Use clear, descriptive test names
2. **Single Responsibility**: Each test should verify one thing
3. **Independent Tests**: Tests should not depend on each other
4. **Fast Execution**: Keep tests fast to run frequently
5. **Clear Assertions**: Use meaningful assertion messages
6. **Test Edge Cases**: Include boundary conditions and error cases

## Future Enhancements

- Automatic test discovery
- Code coverage reporting
- Performance benchmarking
- Integration with CI/CD pipelines
- GUI test runner for Love2D