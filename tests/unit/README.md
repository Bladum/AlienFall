# tests/unit - Unit Tests

**Purpose:** Test individual functions and components in isolation

**Content:** 31 Lua test files covering core engine modules

**Features:**
- Function-level testing without external dependencies
- Fast execution for rapid feedback
- Mock data integration for isolated testing
- Coverage of critical game systems

## Overview

The Unit folder contains unit test suites for individual components and functions. These tests verify basic functionality of isolated code components without external dependencies.

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
