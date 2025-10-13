# Testing Guide

This guide covers the comprehensive testing framework for the XCOM Simple / AlienFall project.

## Overview

The project uses a multi-layered testing approach with automated test suites covering widgets, mod systems, battlescape mechanics, and performance regression testing.

## Test Structure

```
engine/tests/
├── test_runner.lua          # Main test orchestrator
├── systems/
│   ├── test_mod_system.lua      # Mod loading and validation
│   ├── test_performance.lua     # Performance benchmarks
│   └── test_phase2.lua          # Phase 2 specific tests
├── battle/
│   └── test_battlescape_systems.lua  # Battlescape core systems
└── widgets/
    ├── tests/
    │   ├── widget_test_framework.lua
    │   ├── test_all_widgets.lua
    │   └── test_[widget].lua
    └── mock_data.lua
```

## Test Categories

### 1. Unit Tests
- **Scope**: Individual functions and methods
- **Framework**: Custom assertion library
- **Coverage**: 70% of total tests
- **Execution**: Fast (< 100ms per test)

### 2. Integration Tests
- **Scope**: Component interactions
- **Coverage**: Mod loading, battlescape initialization
- **Execution**: Medium speed (100ms - 1s per test)

### 3. Performance Tests
- **Scope**: Benchmarks and regression detection
- **Metrics**: Execution time, memory usage, FPS
- **Execution**: Variable (seconds to minutes)

## Running Tests

### From Game Menu
1. Launch the game with `lovec .`
2. Navigate to **Tests Menu**
3. Click **"RUN ALL TESTS"**
4. View results in console output

### Individual Test Suites
- **Widget Tests**: Tests → Run All Tests (includes widgets)
- **Mod System Tests**: Tests → Run All Tests (includes mod system)
- **Battlescape Tests**: Tests → Run All Tests (includes battlescape)
- **Performance Tests**: Tests → Performance Tests

### Console Output
```
[TestRunner] Starting test suite: widgets
[TestRunner] Running: test_button_creation... PASS (2ms)
[TestRunner] Running: test_button_click... PASS (1ms)
[TestRunner] Suite widgets: 3/3 passed (4ms total)
```

## Test Coverage

### Current Metrics (October 12, 2025)
- **Widgets**: 100% (33/33 widgets tested)
- **Mod System**: ~90% (28/31 functions tested)
- **Battlescape**: ~72% (18/25 functions tested)
- **Overall**: ~87% (79/91 functions tested)

### Coverage Areas

#### Widget System
- ✅ All 33 widget types tested
- ✅ Grid alignment validation
- ✅ Theme application
- ✅ Input handling
- ✅ State management

#### Mod System
- ✅ Mod discovery and scanning
- ✅ TOML parsing validation
- ✅ Content path resolution
- ✅ Active mod switching
- ✅ Error handling
- ✅ Multi-mod scenarios

#### Battlescape System
- ✅ Pathfinding algorithms
- ✅ Line-of-sight calculations
- ✅ Action point management
- ✅ Battlefield coordinate conversion
- ✅ Unit movement validation

## Writing Tests

### Test File Template
```lua
local TestFramework = require("widgets.tests.widget_test_framework")

local MyTests = {}

function MyTests.test_feature()
    TestFramework.runTest("Feature description", function()
        -- Arrange
        local component = MyComponent.new()

        -- Act
        local result = component:method()

        -- Assert
        TestFramework.assertEqual(result, expected, "Result should match expected value")
    end)
end

function MyTests.runAll()
    print("Running MyTests...")

    local success, err = pcall(MyTests.test_feature)
    if not success then
        print("Test failed: " .. err)
    end

    TestFramework.printSummary()
end

return MyTests
```

### Assertion Methods
- `assertEqual(a, b, message)` - Check equality
- `assertNotEqual(a, b, message)` - Check inequality
- `assertNotNil(value, message)` - Check not nil
- `assertNil(value, message)` - Check nil
- `assert(value, message)` - Check truthy
- `assertNot(value, message)` - Check falsy

### Mock Data
Use `widgets.mock_data` for test fixtures:
```lua
local mockData = require("widgets.mock_data")
local testUnits = mockData.generateUnits(5)
```

## Performance Testing

### Benchmark Categories
- **LOS Calculations**: Shadow casting algorithm performance
- **Pathfinding**: A* algorithm with hex grid
- **Battlescape Init**: Map generation and unit placement
- **Rendering**: FPS and frame time consistency

### Running Benchmarks
```lua
local PerformanceTests = require("tests.test_performance")
PerformanceTests.runAll()
```

### Interpreting Results
```
LOS Performance Test (10 runs):
  Average: 2.34ms
  Min: 1.98ms
  Max: 3.12ms
  Memory: +0.12MB
```

## Test Reports

### JSON Report Generation
Tests automatically generate a JSON report saved to:
```
%TEMP%\test_report.json
```

### Report Contents
```json
{
  "timestamp": "2025-10-12 14:30:00",
  "summary": {
    "total_tests": 79,
    "passed": 77,
    "failed": 2,
    "skipped": 0,
    "success_rate": 97.5
  },
  "coverage": {
    "widgets": {"tested": 33, "total": 33, "percentage": 100.0},
    "mod_system": {"tested": 28, "total": 31, "percentage": 90.3},
    "battlescape": {"tested": 18, "total": 25, "percentage": 72.0},
    "overall": {"tested": 79, "total": 89, "percentage": 88.8}
  }
}
```

## Debugging Failed Tests

### Common Issues
1. **Nil Reference Errors**: Check object initialization
2. **Path Resolution**: Verify file paths and mod loading
3. **Grid Alignment**: Ensure coordinates are multiples of 24
4. **TOML Parsing**: Validate file syntax and structure

### Debug Techniques
```lua
-- Add debug prints
print("[DEBUG] Value: " .. tostring(value))

-- Check object state
for k,v in pairs(object) do
    print(k .. " = " .. tostring(v))
end

-- Test individual components
local component = MyComponent.new()
local result = component:method()
assert(result == expected)
```

## Continuous Integration

### Automated Testing
- Tests run on every build
- JSON reports generated for CI systems
- Coverage thresholds enforced
- Performance regression detection

### Quality Gates
- ✅ All tests pass
- ✅ Coverage > 85%
- ✅ No performance regressions
- ✅ Test execution < 30 seconds

## Best Practices

### Test Organization
- One test file per system/component
- Descriptive test names
- Setup/teardown for complex tests
- Mock external dependencies

### Test Data
- Use realistic test data
- Avoid hard-coded values
- Create test fixtures for complex objects
- Clean up after tests

### Performance
- Keep unit tests fast (< 100ms)
- Use appropriate data sizes
- Profile performance-critical code
- Monitor memory usage

### Maintenance
- Update tests when code changes
- Remove obsolete tests
- Document complex test scenarios
- Review test coverage regularly

## Troubleshooting

### Test Suite Won't Run
- Check Love2D console for errors
- Verify file paths in require statements
- Ensure all dependencies are loaded
- Check for syntax errors in test files

### Tests Failing Intermittently
- Check for race conditions
- Verify mock data consistency
- Look for global state pollution
- Add proper test isolation

### Performance Regressions
- Compare against baseline metrics
- Profile the failing code
- Check for N+1 query problems
- Review algorithm complexity

## Contributing

### Adding New Tests
1. Create test file in appropriate directory
2. Follow naming convention: `test_[component].lua`
3. Add to test runner if new suite
4. Update coverage calculations
5. Document in this guide

### Test Framework Extensions
- Add new assertion methods to `widget_test_framework.lua`
- Update mock data generators
- Enhance reporting features
- Add new performance benchmarks

## Resources

- **Test Framework**: `engine/widgets/tests/widget_test_framework.lua`
- **Mock Data**: `engine/widgets/mock_data.lua`
- **Performance Tests**: `engine/tests/systems/test_performance.lua`
- **Test Runner**: `engine/tests/test_runner.lua`

## Version History

- **v1.0** (October 12, 2025): Initial comprehensive testing framework
  - 79 tests across 4 categories
  - 88% overall coverage
  - JSON reporting and performance benchmarks
  - Integrated into main game menu