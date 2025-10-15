# Test Development Guide

A guide for creating new tests in the XCOM Simple project.

## Table of Contents

1. [Test Structure](#test-structure)
2. [Creating Mock Data](#creating-mock-data)
3. [Writing Unit Tests](#writing-unit-tests)
4. [Writing Integration Tests](#writing-integration-tests)
5. [Writing Performance Tests](#writing-performance-tests)
6. [Best Practices](#best-practices)
7. [Running and Debugging](#running-and-debugging)

---

## Test Structure

All tests follow this directory structure:

```
tests/
├── unit/                   # Isolated module tests
├── integration/            # Multi-system workflow tests
├── performance/            # Benchmark tests
├── runners/                # Test execution scripts
├── mock/                   # Mock data (moved from root)
│   ├── units.lua           # Mock unit/soldier data
│   ├── items.lua           # Mock equipment data
│   ├── facilities.lua      # Mock base data
│   ├── economy.lua         # Mock economic data
│   ├── geoscape.lua        # Mock world/mission data
│   └── README.md
└── README.md
```

---

## Creating Mock Data

### When to Create Mock Data

Create mock data when:
- Tests need consistent, reusable test data
- Multiple tests need the same type of data
- Data generation logic is complex

### Mock Data Template

```lua
-- tests/mock/new_system.lua
-- Mock data for [System Name]

local MockSystem = {}

-- Simple generator
function MockSystem.getItem(itemType)
    itemType = itemType or "DEFAULT"
    
    return {
        id = "item_" .. math.random(1000, 9999),
        type = itemType,
        name = "Test " .. itemType,
        -- Add relevant properties
    }
end

-- Batch generator
function MockSystem.generateItems(count)
    count = count or 10
    local items = {}
    
    for i = 1, count do
        table.insert(items, MockSystem.getItem())
    end
    
    return items
end

-- Specialized generators
function MockSystem.getComplexItem(config)
    local item = MockSystem.getItem()
    
    -- Apply custom configuration
    for k, v in pairs(config or {}) do
        item[k] = v
    end
    
    return item
end

return MockSystem
```

### Mock Data Best Practices

1. **Use Descriptive Names** - `getSoldier()`, not `get()`
2. **Provide Defaults** - All parameters should be optional
3. **Return Tables** - Always return Lua tables
4. **Be Deterministic** - Same inputs = same outputs (when possible)
5. **Document API** - Add function comments
6. **Keep It Simple** - Mock data shouldn't have complex logic

---

## Writing Unit Tests

### Unit Test Template

```lua
-- tests/unit/test_my_system.lua
-- Unit tests for MySystem module

local MySystemTest = {}

-- Helper function for setup
local function setup()
    local MySystem = require("path.to.my_system")
    return MySystem
end

-- Test basic functionality
function MySystemTest.testBasicFeature()
    local MySystem = setup()
    
    -- Arrange
    local input = "test"
    
    -- Act
    local result = MySystem.doSomething(input)
    
    -- Assert
    assert(result ~= nil, "Result should not be nil")
    assert(result == "expected", "Result should be 'expected'")
    
    print("✓ testBasicFeature passed")
end

-- Test edge cases
function MySystemTest.testEdgeCase()
    local MySystem = setup()
    
    -- Test with nil
    local result = MySystem.doSomething(nil)
    assert(result ~= nil, "Should handle nil input")
    
    -- Test with empty string
    result = MySystem.doSomething("")
    assert(result ~= nil, "Should handle empty string")
    
    print("✓ testEdgeCase passed")
end

-- Test error handling
function MySystemTest.testErrorHandling()
    local MySystem = setup()
    
    local success, err = pcall(function()
        MySystem.doSomething("invalid")
    end)
    
    assert(not success or err == nil, "Should handle errors gracefully")
    
    print("✓ testErrorHandling passed")
end

-- Run all tests
function MySystemTest.runAll()
    print("\n=== MySystem Tests ===")
    
    MySystemTest.testBasicFeature()
    MySystemTest.testEdgeCase()
    MySystemTest.testErrorHandling()
    
    print("✓ All MySystem tests passed!\n")
end

return MySystemTest
```

### Unit Test Best Practices

1. **Test One Thing** - Each test function tests one behavior
2. **Use Clear Names** - `testCalculateDamage`, not `test1`
3. **Arrange-Act-Assert** - Structure tests clearly
4. **Test Edge Cases** - Nil, empty, negative, max values
5. **Use Assertions** - Always assert expected results
6. **Print Success** - Indicate when tests pass
7. **Handle Errors** - Use pcall for error testing

---

## Writing Integration Tests

### Integration Test Template

```lua
-- tests/integration/test_system_integration.lua
-- Integration tests for [System] workflows

local SystemIntegrationTest = {}

-- Test setup with multiple systems
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    
    local System1 = require("path.to.system1")
    local System2 = require("path.to.system2")
    local MockData = require("tests.mock.data")
    
    return System1, System2, MockData
end

-- Test complete workflow
function SystemIntegrationTest.testCompleteWorkflow()
    local System1, System2, MockData = setup()
    
    -- Create test data
    local data = MockData.getData()
    
    -- Step 1: Process with System1
    local intermediate = System1.process(data)
    assert(intermediate ~= nil, "Step 1 failed")
    
    -- Step 2: Process with System2
    local final = System2.process(intermediate)
    assert(final ~= nil, "Step 2 failed")
    
    -- Verify end-to-end result
    assert(final.status == "complete", "Workflow not completed")
    
    print("✓ testCompleteWorkflow passed")
end

-- Test system interaction
function SystemIntegrationTest.testSystemInteraction()
    local System1, System2 = setup()
    
    -- Initialize both systems
    System1.init()
    System2.init()
    
    -- Verify they can communicate
    System1.sendMessage("test")
    local received = System2.getMessage()
    
    assert(received == "test", "Systems not communicating")
    
    print("✓ testSystemInteraction passed")
end

-- Run all integration tests
function SystemIntegrationTest.runAll()
    print("\n=== System Integration Tests ===")
    
    SystemIntegrationTest.testCompleteWorkflow()
    SystemIntegrationTest.testSystemInteraction()
    
    print("✓ All integration tests passed!\n")
end

return SystemIntegrationTest
```

### Integration Test Best Practices

1. **Test Real Workflows** - Simulate actual game scenarios
2. **Use Mock Data** - Consistent, controlled test data
3. **Test Dependencies** - Verify system interactions
4. **Check End Results** - Test complete workflows, not just parts
5. **Clean Up** - Reset state between tests if needed

---

## Writing Performance Tests

### Performance Test Template

```lua
-- tests/performance/test_system_performance.lua
-- Performance benchmarks for [System]

local PerformanceTest = {}

-- Benchmark helper
local function benchmark(name, iterations, func)
    local startTime = os.clock()
    
    for i = 1, iterations do
        func()
    end
    
    local endTime = os.clock()
    local totalTime = endTime - startTime
    local avgTime = totalTime / iterations
    
    print(string.format("  %s: %.4fs total, %.6fs avg (%d iterations)", 
          name, totalTime, avgTime, iterations))
    
    return totalTime, avgTime
end

-- Test fast operations
function PerformanceTest.testFastOperation()
    print("\n=== Fast Operation Performance ===")
    
    local MySystem = require("path.to.my_system")
    
    benchmark("Fast operation", 10000, function()
        MySystem.fastFunction()
    end)
    
    print("✓ Fast operation benchmark completed")
end

-- Test slow operations
function PerformanceTest.testSlowOperation()
    print("\n=== Slow Operation Performance ===")
    
    local MySystem = require("path.to.my_system")
    
    benchmark("Slow operation", 100, function()
        MySystem.slowFunction()
    end)
    
    print("✓ Slow operation benchmark completed")
end

-- Test with varying data sizes
function PerformanceTest.testScaling()
    print("\n=== Scaling Performance ===")
    
    local MySystem = require("path.to.my_system")
    
    for size = 10, 1000, 100 do
        local data = {}
        for i = 1, size do
            table.insert(data, i)
        end
        
        local time = benchmark(
            string.format("Size %d", size), 
            100, 
            function()
                MySystem.processData(data)
            end
        )
    end
    
    print("✓ Scaling benchmark completed")
end

-- Run all benchmarks
function PerformanceTest.runAll()
    print("\n" .. string.rep("=", 60))
    print("PERFORMANCE TESTS")
    print(string.rep("=", 60))
    
    PerformanceTest.testFastOperation()
    PerformanceTest.testSlowOperation()
    PerformanceTest.testScaling()
    
    print("\n✓ All performance tests completed!\n")
end

return PerformanceTest
```

### Performance Test Best Practices

1. **Use High Iterations** - Get accurate averages
2. **Test Realistic Data** - Use expected data sizes
3. **Test Scaling** - Verify O(n) behavior
4. **Measure Time** - Use os.clock() for precision
5. **Report Clearly** - Show total, average, iterations
6. **Test Extremes** - Small and large data sets

---

## Best Practices

### General Testing

1. **Test Early, Test Often** - Write tests as you code
2. **Keep Tests Fast** - Fast tests get run more often
3. **Make Tests Readable** - Clear, documented test code
4. **One Assert Per Test** - Or related group of asserts
5. **No Side Effects** - Tests shouldn't affect each other
6. **Use Descriptive Messages** - Assert messages explain failures

### Assertion Best Practices

```lua
-- Good assertions
assert(result ~= nil, "Result should not be nil")
assert(result == 42, "Expected 42, got " .. tostring(result))
assert(#list > 0, "List should not be empty")

-- Bad assertions
assert(result) -- No message
assert(x) -- Unclear what's being tested
```

### Test Organization

```lua
-- Group related tests
local MyTests = {}

function MyTests.testFeatureA_BasicCase()
    -- Test basic case of Feature A
end

function MyTests.testFeatureA_EdgeCase()
    -- Test edge case of Feature A
end

function MyTests.testFeatureB_BasicCase()
    -- Test basic case of Feature B
end

-- Clear naming convention
```

---

## Running and Debugging

### Running All Tests

```bash
# Run comprehensive test suite
lovec tests/runners

# Or with batch file
run_tests.bat
```

### Running Individual Tests

```bash
# Run specific test file
lua tests/unit/test_my_system.lua

# Run with Love2D
lovec tests/runners/run_my_test.lua
```

### Debugging Failed Tests

1. **Read Error Messages** - Assertion messages tell you what failed
2. **Add Print Statements** - Debug with print() calls
3. **Test Isolation** - Comment out other tests
4. **Check Mock Data** - Verify test data is correct
5. **Use REPL** - Test functions interactively

### Test Output

```
=== MySystem Tests ===
✓ testBasicFeature passed
✓ testEdgeCase passed
✗ testErrorHandling failed
  Error: Expected true, got false
  
SUMMARY: 2/3 passed (66.7%)
```

---

## Adding New Tests to Test Suite

### Step 1: Create Test File

```bash
# Create new test file
tests/unit/test_new_system.lua
```

### Step 2: Write Tests

```lua
local NewSystemTest = {}

function NewSystemTest.testSomething()
    -- Test code here
    print("✓ testSomething passed")
end

function NewSystemTest.runAll()
    print("\n=== NewSystem Tests ===")
    NewSystemTest.testSomething()
    print("✓ All NewSystem tests passed!\n")
end

return NewSystemTest
```

### Step 3: Add to Test Runner

Edit `tests/runners/run_all_tests.lua`:

```lua
local unitTests = {
    -- ... existing tests ...
    {"New System", "tests.unit.test_new_system"}
}
```

### Step 4: Run and Verify

```bash
lovec tests/runners
```

---

## Examples

### Example: Testing a Combat Function

```lua
function CombatTest.testDamageCalculation()
    local MockUnits = require("tests.mock.units")
    local MockItems = require("tests.mock.items")
    
    -- Create attacker with weapon
    local attacker = MockUnits.getSoldier("Attacker", "ASSAULT")
    attacker.weapon = MockItems.getWeapon("RIFLE")
    
    -- Create target
    local target = MockUnits.getEnemy("SECTOID")
    
    -- Calculate expected damage
    local expectedDamage = attacker.weapon.damage
    
    -- Perform attack
    local actualDamage = CombatSystem.calculateDamage(attacker, target)
    
    -- Verify
    assert(actualDamage == expectedDamage, 
           "Damage mismatch: expected " .. expectedDamage .. 
           ", got " .. actualDamage)
    
    print("✓ testDamageCalculation passed")
end
```

### Example: Testing State Changes

```lua
function StateTest.testStateTransition()
    local StateManager = require("core.state_manager")
    local MockState = require("tests.helpers.mock_state")
    
    -- Register states
    local state1 = MockState.new("State1")
    local state2 = MockState.new("State2")
    StateManager.register("state1", state1)
    StateManager.register("state2", state2)
    
    -- Initial state
    StateManager.switch("state1")
    assert(StateManager.current == state1, "Wrong initial state")
    
    -- Transition
    StateManager.switch("state2")
    assert(StateManager.current == state2, "Transition failed")
    assert(state1.exited, "Old state not exited")
    assert(state2.entered, "New state not entered")
    
    print("✓ testStateTransition passed")
end
```

---

## Quick Reference

### Test File Locations
- Unit tests: `tests/unit/test_*.lua`
- Integration tests: `tests/integration/test_*_integration.lua`
- Performance tests: `tests/performance/test_*_performance.lua`
- Mock data: `tests/mock/*.lua`

### Test Runner Commands
```bash
lovec tests/runners              # Run all tests
lua tests/unit/test_*.lua        # Run specific unit test
lovec tests/runners/run_*.lua    # Run specific test runner
```

### Common Patterns
```lua
-- Setup
local System = require("path.to.system")

-- Test
local result = System.function(input)

-- Assert
assert(condition, "Error message")

-- Cleanup (if needed)
System.cleanup()
```

---

**Remember:** Good tests make good code. Test early, test often, and keep your tests clean and maintainable!
