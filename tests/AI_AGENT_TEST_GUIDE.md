# AI Agent Guide: Adding and Running Tests

**For: GitHub Copilot, AI Assistants, and Autonomous Agents**

## 🎯 Quick Start

### To Run Tests
```bash
# Run all tests
lovec tests/runners

# Run specific category
cd tests/runners
lovec . [category]
# Categories: core, combat, basescape, geoscape, performance, all

# Run single test
lua tests/unit/test_[system].lua
```

### To Add New Tests
1. Create test file: `tests/unit/test_[system].lua`
2. Use mock data: `require("mock.[category]")`
3. Add to selective runner: `tests/runners/run_selective_tests.lua`
4. Document in README: `tests/README.md`

---

## 📁 Test File Structure

### Template for New Test File
```lua
---Test Suite for [System Name]
---Brief description of what this tests

-- Load dependencies
local [System] = require("engine.[path].[system]")
local Mock[Type] = require("mock.[type]")

local Test[System] = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper: Run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper: Assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: [Test Name]
function Test[System].test[Feature]()
    -- Arrange: Set up test data
    local testData = Mock[Type].get[Item]()
    
    -- Act: Execute the function
    local result = [System].[function](testData)
    
    -- Assert: Verify results
    assert(result ~= nil, "Result should not be nil")
    assert(result.value == expected, "Value should match expected")
end

-- Run all tests
function Test[System].runAll()
    print("\n=== Running [System] Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("[Test Name]", Test[System].test[Feature])
    -- Add more tests...
    
    -- Print results
    print("\n=== Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All tests passed!")
    end
    
    return testsPassed, testsFailed
end

return Test[System]
```

---

## 🎭 Using Mock Data

### Available Mock Modules
```lua
-- Units & Combat
local MockUnits = require("mock.units")
local soldier = MockUnits.getSoldier("John", "ASSAULT")
local enemy = MockUnits.getEnemy("SECTOID")
local squad = MockUnits.generateSquad(6)

-- Equipment
local MockItems = require("mock.items")
local rifle = MockItems.getWeapon("RIFLE")
local armor = MockItems.getArmor("KEVLAR")
local loadout = MockItems.generateLoadout("SNIPER")

-- Base Management
local MockFacilities = require("mock.facilities")
local base = MockFacilities.getStarterBase()
local lab = MockFacilities.getFacility("LABORATORY", 3, 3)

-- Economy
local MockEconomy = require("mock.economy")
local finances = MockEconomy.getFinances()
local research = MockEconomy.getResearchProject("LASER_WEAPONS")

-- Geoscape
local MockGeoscape = require("mock.geoscape")
local world = MockGeoscape.getWorld()
local ufo = MockGeoscape.getUFO("SCOUT")

-- Tactical Combat
local MockBattlescape = require("mock.battlescape")
local battlefield = MockBattlescape.getBattlefield(40, 40, "urban")
local scenario = MockBattlescape.getCombatScenario("balanced")
```

### Creating New Mock Generators

When adding to existing mock files:
```lua
---Generate [description]
---@param param1 type Description
---@return table Data structure
function Mock[Type].get[Item](param1)
    return {
        -- All required fields
        id = "unique_id",
        name = "Descriptive Name",
        
        -- Nested structures
        stats = {
            value1 = 50,
            value2 = 75
        },
        
        -- Optional fields with defaults
        optional = param1 or "default"
    }
end
```

---

## 📝 Test Writing Guidelines

### 1. Test Naming Convention
```lua
-- File: test_[system]_[subsystem].lua
-- Function: test[Feature][Scenario]

function TestCombat.testBasicAttackHit()        -- Basic scenario
function TestCombat.testAttackWithCoverMiss()   -- Edge case
function TestCombat.testCriticalHitDamage()     -- Special case
```

### 2. Arrange-Act-Assert Pattern
```lua
function TestSystem.testFeature()
    -- ARRANGE: Set up test data
    local unit = MockUnits.getSoldier("John", "ASSAULT")
    local target = MockUnits.getEnemy("SECTOID")
    
    -- ACT: Execute the function
    local result = CombatSystem.attack(unit, target)
    
    -- ASSERT: Verify results
    assert(result ~= nil, "Attack should return result")
    assert(result.hit == true or result.hit == false, "Result should have hit boolean")
    if result.hit then
        assert(result.damage > 0, "Hit should cause damage")
    end
end
```

### 3. Test Edge Cases
```lua
-- Normal case
testNormalMovement()

-- Edge cases
testZeroDistanceMovement()
testMaxRangeMovement()
testInsufficientTU()
testMovementThroughObstacle()
testMovementOutOfBounds()
```

### 4. Use Descriptive Assertions
```lua
-- Bad
assert(x == 5)

-- Good
assert(x == 5, string.format("Expected x=5, got x=%d", x))
```

---

## 🔄 Adding Tests to Selective Runner

Edit `tests/runners/run_selective_tests.lua`:

```lua
-- Find the appropriate category
categories = {
    core = {
        name = "Core Systems",
        tests = {
            {"State Manager", "tests.unit.test_state_manager"},
            {"Your New Test", "tests.unit.test_your_system"}, -- ADD HERE
        }
    },
    -- ...
}
```

---

## 📊 Test Coverage Checklist

When adding tests for a new system:

- [ ] **Happy path**: Normal, expected usage
- [ ] **Edge cases**: Boundary values, limits
- [ ] **Error cases**: Invalid input, missing data
- [ ] **Performance**: Speed, memory usage
- [ ] **Integration**: Works with other systems
- [ ] **Mock data**: Realistic test data created
- [ ] **Documentation**: Test file documented
- [ ] **Runner updated**: Added to selective runner

---

## 🎯 Common Test Patterns

### Pattern 1: State Verification
```lua
function TestSystem.testStateChange()
    local obj = System.new()
    assert(obj.state == "INITIAL", "Should start in INITIAL state")
    
    obj:transition("ACTIVE")
    assert(obj.state == "ACTIVE", "Should transition to ACTIVE")
    
    obj:transition("COMPLETE")
    assert(obj.state == "COMPLETE", "Should transition to COMPLETE")
end
```

### Pattern 2: Data Transformation
```lua
function TestSystem.testDataTransform()
    local input = MockData.getInput()
    local expected = MockData.getExpectedOutput()
    
    local result = System.transform(input)
    
    assert(result.field1 == expected.field1, "Field1 should match")
    assert(result.field2 == expected.field2, "Field2 should match")
end
```

### Pattern 3: Collection Operations
```lua
function TestSystem.testCollectionFilter()
    local units = MockUnits.generateSquad(10)
    
    local wounded = System.filterWounded(units)
    
    assert(#wounded <= #units, "Filtered list should be <= original")
    for _, unit in ipairs(wounded) do
        assert(unit.isWounded, "All filtered units should be wounded")
    end
end
```

### Pattern 4: Performance Testing
```lua
function TestSystem.testPerformance()
    local startTime = os.clock()
    
    -- Perform operation 1000 times
    for i = 1, 1000 do
        System.operation(testData)
    end
    
    local elapsed = os.clock() - startTime
    
    assert(elapsed < 1.0, string.format("Should complete in < 1s, took %.3fs", elapsed))
    print(string.format("[Performance] 1000 operations: %.3fs", elapsed))
end
```

---

## 🚀 Workflow: Adding a New Test

### Step-by-Step Process

1. **Identify System to Test**
   ```bash
   # Find the system file
   ls engine/[subsystem]/[system].lua
   ```

2. **Create Test File**
   ```bash
   # Copy template or create new
   code tests/unit/test_[system].lua
   ```

3. **Create/Use Mock Data**
   ```lua
   -- In test file
   local MockData = require("mock.[type]")
   local testData = MockData.get[Item]()
   ```

4. **Write Tests**
   ```lua
   -- Follow template structure
   function TestSystem.test[Feature]()
       -- Arrange, Act, Assert
   end
   ```

5. **Run Test Locally**
   ```bash
   lua tests/unit/test_[system].lua
   ```

6. **Add to Selective Runner**
   ```lua
   -- Edit tests/runners/run_selective_tests.lua
   -- Add to appropriate category
   ```

7. **Update Documentation**
   ```markdown
   <!-- Edit tests/README.md -->
   - Added test_[system].lua (N tests)
   ```

8. **Run Full Test Suite**
   ```bash
   lovec tests/runners
   ```

---

## 📚 Documentation Requirements

### Test File Header
```lua
---Test Suite for [System Name]
---
---Tests [brief description of what system does]
---
---Test Coverage:
---  - Feature 1 (N tests)
---  - Feature 2 (N tests)
---  - Edge cases (N tests)
---  - Performance (N tests)
---
---Dependencies:
---  - engine.[path].[system]
---  - mock.[type]
---
---@module tests.unit.test_[system]
---@author [Your Name]
---@date 2025-10-15
```

### README Update
```markdown
## Unit Tests

### test_[system].lua (N tests)
Tests [system] functionality:
- Feature 1
- Feature 2
- Edge cases

**Run:** `lua tests/unit/test_[system].lua`
```

---

## 🔍 Debugging Tests

### Common Issues

**Issue: Module not found**
```lua
-- Check package.path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

-- Use correct require path
local System = require("engine.subsystem.system")  -- Not "subsystem.system"
```

**Issue: Mock data returns nil**
```lua
-- Check mock function exists
local MockUnits = require("mock.units")
print(MockUnits.getSoldier)  -- Should print function

-- Check parameters
local soldier = MockUnits.getSoldier("Name", "ASSAULT")  -- Correct params
```

**Issue: Test fails inconsistently**
```lua
-- Avoid global state
local function setupTest()
    -- Create fresh test data each time
    return MockData.getCleanData()
end

-- Don't rely on execution order
function TestSystem.testA()
    local data = setupTest()  -- Independent
end
```

---

## ⚡ Quick Reference Commands

```bash
# Run all tests
lovec tests/runners

# Run specific category
cd tests/runners && lovec . core
cd tests/runners && lovec . combat
cd tests/runners && lovec . basescape
cd tests/runners && lovec . geoscape
cd tests/runners && lovec . performance

# Run single test file
lua tests/unit/test_state_manager.lua
lua tests/unit/test_hex_math.lua
lua tests/unit/test_movement_system.lua

# Get help
cd tests/runners && lovec . help

# Run from Windows
run_tests.bat
```

---

## 📖 Additional Resources

- **Test API Reference**: `tests/TEST_API_FOR_AI.lua`
- **Mock Data Quality**: `tests/mock/MOCK_DATA_QUALITY_GUIDE.md`
- **Test Development**: `tests/TEST_DEVELOPMENT_GUIDE.md`
- **Coverage Report**: `COMPLETE_TEST_COVERAGE_REPORT.md`
- **Quick Reference**: `tests/AI_AGENT_QUICK_REF.md`

---

## 🎯 Success Criteria

A well-written test should:
✅ Test one specific feature/behavior  
✅ Be independent (no shared state)  
✅ Use descriptive names  
✅ Have clear assertions  
✅ Use mock data when appropriate  
✅ Run quickly (< 1 second per test)  
✅ Be deterministic (same result every time)  
✅ Include edge cases  
✅ Be documented  

---

**Remember**: Good tests make confident code changes possible! 🎯

When in doubt:
1. Look at existing tests for examples
2. Use mock data generators
3. Follow the Arrange-Act-Assert pattern
4. Test edge cases
5. Document what you're testing

**Test file locations**: All in `tests/` folder (never in `engine/`)  
**Mock data**: All in `tests/mock/` folder  
**Documentation**: Keep `tests/README.md` updated
