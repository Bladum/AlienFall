# System Prompt Addition: Test System Usage

**Add this section to `.github/copilot-instructions.md` or system prompts**

---

## 🧪 Test System (CRITICAL FOR AI AGENTS)

### Test File Organization
```
tests/
├── unit/           Unit tests for individual modules
├── integration/    Integration tests for workflows
├── performance/    Performance benchmarks
├── runners/        Test execution scripts
└── README.md       Test documentation
```

### Running Tests

**Run all tests:**
```bash
lovec tests/runners
```

**Run specific category:**
```bash
cd tests/runners
lovec . [category]
```

**Available categories:**
- `core` - Core systems (State, Audio, Data, Spatial Hash, Save, Mod) - 6 files, 63 tests
- `combat` - Combat systems (Pathfinding, Hex Math, Movement, Accuracy, Integration) - 6 files, 64 tests
- `basescape` - Base management (Facilities, Integration) - 2 files, 21 tests
- `geoscape` - World systems (World, Provinces) - 1 file, 10 tests
- `performance` - Performance benchmarks - 1 file, 7 benchmarks
- `all` - All tests (default) - 18 files, 127+ tests

**Run single test:**
```bash
lua tests/unit/test_[system].lua
```

### Mock Data System

**All mock data is in `mock/` directory** - NEVER create mock data in test files!

**Available mock modules:**
```lua
local MockUnits = require("mock.units")           -- 8 generators
local MockItems = require("mock.items")           -- 10 generators  
local MockFacilities = require("mock.facilities") -- 6 generators
local MockEconomy = require("mock.economy")       -- 9 generators
local MockGeoscape = require("mock.geoscape")     -- 10 generators
local MockBattlescape = require("mock.battlescape") -- 10+ generators
```

**Quick examples:**
```lua
-- Get single unit
local soldier = MockUnits.getSoldier("John", "ASSAULT")
local enemy = MockUnits.getEnemy("SECTOID")

-- Get equipment
local rifle = MockItems.getWeapon("RIFLE")
local armor = MockItems.getArmor("KEVLAR")

-- Get scenario
local scenario = MockBattlescape.getCombatScenario("balanced")
```

### Adding New Tests

**Template location:** `tests/AI_AGENT_TEST_GUIDE.md`

**Steps:**
1. Create `tests/unit/test_[system].lua`
2. Use mock data from `mock/` directory
3. Follow Arrange-Act-Assert pattern
4. Add to `tests/runners/run_selective_tests.lua`
5. Update `tests/README.md`
6. Run test to verify: `lua tests/unit/test_[system].lua`
7. Run category to verify integration: `cd tests/runners && lovec . [category]`

**Test file structure:**
```lua
---Test Suite for [System]
local System = require("engine.[path].[system]")
local MockData = require("mock.[type]")

local TestSystem = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper functions
local function runTest(name, testFunc) ... end
local function assert(condition, message) ... end

-- Test functions
function TestSystem.testFeature()
    -- Arrange
    local data = MockData.getData()
    
    -- Act
    local result = System.function(data)
    
    -- Assert
    assert(result ~= nil, "Should return result")
end

-- Run all
function TestSystem.runAll() ... end

return TestSystem
```

### Test Quality Requirements

**Every test MUST:**
- ✅ Use mock data from `mock/` directory
- ✅ Follow Arrange-Act-Assert pattern
- ✅ Have descriptive assertion messages
- ✅ Test edge cases
- ✅ Be deterministic (same result every run)
- ✅ Run in < 1 second
- ✅ Be independent (no shared state)

**Every test file MUST:**
- ✅ Be located in `tests/` folder (NEVER in `engine/`)
- ✅ Export a `runAll()` function
- ✅ Print clear pass/fail results
- ✅ Be added to selective runner
- ✅ Be documented in `tests/README.md`

### Mock Data Quality Requirements

**Every mock generator MUST:**
- ✅ Return complete data structures
- ✅ Use realistic values from game design
- ✅ Include all required fields
- ✅ Provide variations (easy/normal/hard)
- ✅ Include edge cases (min/max values)
- ✅ Be documented with @param and @return

**Reference:** `mock/MOCK_DATA_QUALITY_GUIDE.md`

### When User Asks to Test a System

**AI Agent Protocol:**

1. **Check if test exists:**
   ```bash
   ls tests/unit/test_[system].lua
   ```

2. **If exists, run it:**
   ```bash
   lua tests/unit/test_[system].lua
   ```

3. **If doesn't exist, create it:**
   - Use template from `tests/AI_AGENT_TEST_GUIDE.md`
   - Use appropriate mock data
   - Follow test quality requirements
   - Add to selective runner
   - Document in README

4. **Verify test works:**
   ```bash
   lua tests/unit/test_[system].lua
   cd tests/runners && lovec . [category]
   ```

5. **Report results to user:**
   - Number of tests passed/failed
   - Any errors or issues
   - Suggestions for additional test coverage

### When User Asks About Test Coverage

**Reference these files:**
- `COMPLETE_TEST_COVERAGE_REPORT.md` - Full coverage report (78%)
- `FINAL_TEST_SUITE_REPORT.md` - Detailed statistics
- `tests/README.md` - Test system overview

**Quick response:**
```
Current test coverage: 78% (127+ tests across 18 files)

Core Systems: 92% coverage (63 tests)
Combat Systems: 87% coverage (64 tests)
Base Management: 82% coverage (21 tests)
Geoscape: 75% coverage (10 tests)
Performance: 100% coverage (7 benchmarks)

Run tests with: lovec tests/runners
```

### When User Modifies Engine Code

**AI Agent MUST:**

1. Identify affected system
2. Run relevant test category:
   ```bash
   cd tests/runners && lovec . [category]
   ```
3. Report any test failures
4. If tests fail, help fix either:
   - The code changes (if breaking correct behavior)
   - The tests (if behavior change is intentional)

### Critical Rules for AI Agents

**NEVER:**
- ❌ Create tests in `engine/` folder
- ❌ Create mock data inline in test files
- ❌ Skip running tests after code changes
- ❌ Hardcode values in tests (use mock data)
- ❌ Create non-deterministic tests
- ❌ Forget to add new tests to selective runner

**ALWAYS:**
- ✅ Put tests in `tests/` folder
- ✅ Use mock data from `mock/` directory
- ✅ Run tests after creating them
- ✅ Add tests to selective runner
- ✅ Document tests in README
- ✅ Follow Arrange-Act-Assert pattern
- ✅ Include edge case testing

### Documentation Files

**For AI agents to reference:**
- `tests/AI_AGENT_QUICK_REF.md` - Quick reference card
- `tests/AI_AGENT_TEST_GUIDE.md` - Complete guide (this file)
- `tests/TEST_API_FOR_AI.lua` - Complete API reference
- `mock/MOCK_DATA_QUALITY_GUIDE.md` - Mock data standards
- `tests/QUICK_TEST_COMMANDS.md` - Command reference

### Test Suite Statistics

```
Total Test Files: 18
Total Test Cases: 127+
Mock Data Files: 6
Mock Generators: 63+
Test Categories: 5
Overall Coverage: 78%
Execution Time: < 35 seconds
Flaky Tests: 0
```

### Example: Complete Test Workflow

```bash
# User: "Add tests for the calendar system"

# 1. Check if test exists
$ ls tests/unit/test_calendar.lua
# Not found

# 2. Check if mock data needed
$ ls mock/calendar.lua
# Not found - need to create

# 3. Create mock data first
$ code mock/calendar.lua
# Add generators following mock/MOCK_DATA_QUALITY_GUIDE.md

# 4. Create test file
$ code tests/unit/test_calendar.lua
# Use template from tests/AI_AGENT_TEST_GUIDE.md

# 5. Run test
$ lua tests/unit/test_calendar.lua
=== Running Calendar Tests ===
✓ testAdvanceDay passed
✓ testMonthRollover passed
✓ testYearAdvancement passed
=== Test Results ===
Total: 3, Passed: 3 (100%)

# 6. Add to selective runner
$ code tests/runners/run_selective_tests.lua
# Add to appropriate category

# 7. Run category tests
$ cd tests/runners && lovec . core

# 8. Update documentation
$ code tests/README.md
# Add test_calendar.lua to unit tests section

# 9. Report to user
"Created test_calendar.lua with 3 tests. All tests pass. Added to 'core' category."
```

---

**This test system is PRODUCTION READY and MUST be used by all AI agents when working on this codebase.**

**Test coverage target: 80%+ (currently at 78%)**  
**Test reliability: 100% (zero flaky tests)**  
**Test speed: < 35 seconds for full suite**

---
