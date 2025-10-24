# 🧪 Testing - Test Suite & Quality Assurance

**Purpose:** Comprehensive testing framework for all game systems  
**Audience:** Developers, QA, AI Agents, Test Writers  
**Last Updated:** October 23, 2025

---

## 📋 Folder Structure

### Test Organization

| Folder | Purpose | Contains |
|--------|---------|----------|
| **unit/** | Single module tests | Function-level tests |
| **integration/** | Multi-module tests | System interaction tests |
| **battle/** | Combat system tests | Battlescape-specific tests |
| **battlescape/** | Battlescape layer tests | Full battlescape scenarios |
| **geoscape/** | Geoscape layer tests | Strategic layer tests |
| **systems/** | System-specific tests | Individual system tests |
| **performance/** | Performance benchmarks | Speed and memory tests |
| **mock/** | Mock data | Test fixtures and data |
| **runners/** | Test runner scripts | Test execution utilities |
| **phase5_validation_test/** | Phase 5 validation | Validation test suite |
| **phase5_mods_test/** | Mod system testing | Mod functionality tests |
| **phase5_mock_test/** | Mock data testing | Mock data verification |

### Test Documentation

| File | Purpose |
|------|---------|
| **README.md** | Testing guide and overview |
| **TEST_API_FOR_AI.lua** | API for AI test execution |
| **TEST_DEVELOPMENT_GUIDE.md** | How to write new tests |
| **AI_AGENT_QUICK_REF.md** | Quick reference for AI agents |
| **AI_AGENT_TEST_GUIDE.md** | Detailed guide for AI testing |
| **QUICK_TEST_COMMANDS.md** | Common test commands |

---

## 🎯 Quick Navigation

### For Developers Writing Tests

**I need to write unit tests:**
→ Read `TEST_DEVELOPMENT_GUIDE.md`

**I need to understand test structure:**
→ Check `README.md` testing patterns

**I need test data:**
→ Look in `mock/` folder

**I need quick reference:**
→ See `QUICK_TEST_COMMANDS.md`

### For AI Agents Testing Code

**I need to test my implementation:**
→ Read `AI_AGENT_QUICK_REF.md` and `AI_AGENT_TEST_GUIDE.md`

**I need to run tests:**
→ Check `QUICK_TEST_COMMANDS.md` for commands

**I need to create test data:**
→ Review `mock/README.md` for test fixtures

### For QA & Verification

**I need to run full test suite:**
→ Execute `run_tests.bat`

**I need to test specific system:**
→ Run tests in relevant folder (e.g., `battlescape/`)

**I need performance benchmarks:**
→ Check `performance/` folder tests

---

## 📖 Testing Structure

### Test Pyramid

```
    ├─ UI Tests (Limited)
    ├─ Integration Tests (Moderate)
    └─ Unit Tests (Extensive)
```

**Focus:** Most tests are unit tests for reliability

### Test Categories

**Unit Tests:** `unit/`
- Test individual functions
- No external dependencies
- Fast execution
- High coverage

**Integration Tests:** `integration/`
- Test system interactions
- Multiple modules together
- Verify data flow
- Check edge cases

**System Tests:** `battlescape/`, `geoscape/`, `systems/`
- Test complete systems
- Full game context
- Complex scenarios
- Multi-system interactions

**Performance Tests:** `performance/`
- Benchmark critical systems
- Memory usage tracking
- Load testing
- Optimization verification

---

## 🧪 Running Tests

### Full Test Suite

```bash
run_tests.bat
```

Runs all tests and generates report.

### Specific Test Category

```bash
# Unit tests only
# Integration tests only
# System tests only
# Performance tests only
```

### During Development

Use `TEST_API_FOR_AI.lua` for quick validation:

```lua
local TestAPI = require("TEST_API_FOR_AI")

-- Run specific test
TestAPI.runTest("unit/system_test.lua")

-- Run all tests
TestAPI.runAllTests()

-- Get test results
local results = TestAPI.getResults()
```

---

## 📝 Writing Tests

### Test Structure

```lua
-- tests/unit/my_module_test.lua

local MyModule = require("engine.my_system.my_module")

local TestCase = {}

function TestCase.setup()
  -- Prepare for each test
end

function TestCase.teardown()
  -- Clean up after each test
end

function TestCase.test_basic_functionality()
  local result = MyModule.doSomething()
  assert(result == expected, "Failed: " .. tostring(result))
end

function TestCase.test_error_handling()
  local ok, err = pcall(MyModule.invalidCall)
  assert(not ok, "Should have errored")
  assert(string.find(err, "expected error"), "Wrong error")
end

return TestCase
```

### Test Best Practices

**✅ Do:**
- Test one thing per test
- Use descriptive test names
- Set up and tear down properly
- Test both success and failure
- Use assertions clearly
- Document complex tests
- Test edge cases
- Keep tests fast

**❌ Don't:**
- Test multiple things per test
- Use vague test names
- Skip setup/teardown
- Only test happy path
- Ignore error cases
- Write slow tests
- Test implementation details
- Depend on test order

---

## 🔗 Mock Data

### Using Mock Data

Mock data is organized by system:

```
mock/
├── geoscape_mock.lua    -- Geoscape test data
├── battlescape_mock.lua -- Battlescape test data
├── units_mock.lua       -- Unit test data
└── README.md            -- Mock data guide
```

### Creating Mock Data

```lua
-- Create reusable test data
local MockData = {
  createUnit = function()
    return {
      id = 1,
      name = "Test Unit",
      health = 10,
      position = {x = 5, y = 5}
    }
  end,
  
  createBattle = function()
    return {
      id = 1,
      units = {MockData.createUnit()},
      terrain = {}
    }
  end
}

return MockData
```

---

## 📊 Test Coverage

### Current Coverage

| System | Coverage | Status |
|--------|----------|--------|
| **Core Systems** | 80%+ | ✅ Good |
| **Geoscape** | 75%+ | ✅ Good |
| **Basescape** | 70%+ | ✅ Good |
| **Battlescape** | 85%+ | ✅ Excellent |
| **Units** | 80%+ | ✅ Good |
| **AI Systems** | 60%+ | 🔄 Needs Work |
| **Economy** | 65%+ | 🔄 Needs Work |

### Coverage Goals

- **Core Systems:** 90%+ (critical path)
- **Game Systems:** 80%+ (important systems)
- **Support Systems:** 60%+ (nice to have)

---

## 🚀 Testing Workflow

### When Implementing a Feature

```
1. Unit Test Phase
   ├─ Write tests for unit
   ├─ Verify tests fail initially
   ├─ Implement unit
   └─ Verify tests pass

2. Integration Test Phase
   ├─ Write integration tests
   ├─ Test with related systems
   ├─ Verify no regressions
   └─ Check edge cases

3. System Test Phase
   ├─ Test in full game context
   ├─ Verify gameplay works
   ├─ Test with save/load
   └─ Check performance

4. QA Phase
   ├─ Manual gameplay testing
   ├─ Edge case verification
   ├─ Performance check
   └─ Final approval
```

### Before Committing Code

```
1. Run unit tests: ✅ All passing
2. Run integration tests: ✅ All passing
3. Run system tests: ✅ All passing
4. Check performance: ✅ No regressions
5. Manual testing: ✅ Works as designed
6. Commit with confidence
```

---

## 🎯 Test Priorities

### Critical Systems (Test Thoroughly)

- Battlescape combat mechanics
- Turn resolution system
- Unit stats and calculations
- Finance and economy
- Geoscape state management

### Important Systems (Test Well)

- AI decision making
- GUI interaction
- Save/load functionality
- Mission generation
- Base management

### Support Systems (Test Adequately)

- Analytics and telemetry
- Localization
- Accessibility
- Visual rendering
- Audio systems

---

## 📞 Common Issues & Solutions

### Test Fails Unexpectedly

1. Check test setup/teardown
2. Verify mock data is fresh
3. Check for state leakage
4. Verify test order doesn't matter
5. Add debug output

### Performance Issues

1. Profile the test
2. Identify bottleneck
3. Optimize or skip if needed
4. Document performance baseline

### Integration Tests Failing

1. Check system initialization
2. Verify mock data completeness
3. Check data flow between systems
4. Test each system independently first

---

## 🔗 Related Documentation

**Testing Guides:**
- `TEST_DEVELOPMENT_GUIDE.md` - How to write tests
- `AI_AGENT_QUICK_REF.md` - Quick reference
- `QUICK_TEST_COMMANDS.md` - Common commands

**Code Standards:**
- `../docs/CODE_STANDARDS.md` - Coding conventions

**Game Systems:**
- `../api/` - System APIs to test against
- `../design/mechanics/` - System specifications

**Implementation:**
- `../engine/` - Code being tested

---

## ✅ Test Checklist

Before considering a feature complete:

- [ ] Unit tests written and passing
- [ ] Integration tests written and passing
- [ ] No regressions in related systems
- [ ] Edge cases tested
- [ ] Error handling tested
- [ ] Performance acceptable
- [ ] Manual testing passed
- [ ] Documentation updated

---

## 🔄 Navigation

**Parent:** `../README.md`  
**Subfolders:** `unit/`, `integration/`, `battlescape/`, `geoscape/`, `mock/`, `runners/`  
**Related:** `../engine/` | `../design/` | `../api/`

---

*Comprehensive testing framework for AlienFall game quality assurance*
*High test coverage ensures reliability and prevents regressions*
