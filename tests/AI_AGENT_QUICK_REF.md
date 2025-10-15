# AI Agent Test System Quick Reference

## 🚀 Running Tests

### Run All Tests
```bash
lovec tests/runners
# or
run_tests.bat
```

### Run by Category
```bash
lovec tests/runners/run_selective_tests.lua [category]

Categories:
  core        - Core systems (State, Audio, Data)
  basescape   - Base management
  geoscape    - World systems
  combat      - Combat & pathfinding
  performance - Benchmarks
  all         - All tests
```

### Examples
```bash
lovec tests/runners/run_selective_tests.lua core
lovec tests/runners/run_selective_tests.lua combat
lovec tests/runners/run_selective_tests.lua help
```

## 📊 Test Statistics

- **Mock Data Files:** 5 files, 52 generators
- **Unit Tests:** 6 files, 48 test cases
- **Integration Tests:** 2 files, 20 scenarios
- **Performance Tests:** 1 file, 7 benchmarks
- **Total:** 9 test files, 75+ test cases

## 📦 Mock Data Quick Access

```lua
-- Units & Combat
local MockUnits = require("mock.units")
local soldier = MockUnits.getSoldier("John", "ASSAULT")
local squad = MockUnits.generateSquad(6)
local enemy = MockUnits.getEnemy("SECTOID")

-- Equipment
local MockItems = require("mock.items")
local rifle = MockItems.getWeapon("RIFLE")
local armor = MockItems.getArmor("KEVLAR")
local loadout = MockItems.generateLoadout("ASSAULT")

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
local world = MockGeoscape.getWorld({width = 80, height = 60})
local ufo = MockGeoscape.getUFO("SCOUT")
```

## 🎯 When User Asks...

### "Run all tests"
```bash
lovec tests/runners
```

### "Run combat tests"
```bash
lovec tests/runners/run_selective_tests.lua combat
```

### "Run performance tests"
```bash
lovec tests/runners/run_selective_tests.lua performance
```

### "What tests exist?"
- **Core:** State Manager, Audio, Data Loader
- **Base:** Facility System, Base Integration
- **World:** World System, Geoscape
- **Combat:** Pathfinding, Combat Integration
- **Performance:** Game Performance Benchmarks

### "Show test categories"
```bash
lovec tests/runners/run_selective_tests.lua help
```

## 📝 Test File Locations

```
tests/
├── unit/
│   ├── test_state_manager.lua      (6 tests)
│   ├── test_audio_system.lua       (7 tests)
│   ├── test_data_loader.lua        (8 tests)
│   ├── test_facility_system.lua    (11 tests)
│   ├── test_world_system.lua       (10 tests)
│   └── test_pathfinding.lua        (10 tests)
├── integration/
│   ├── test_combat_integration.lua (10 scenarios)
│   └── test_base_integration.lua   (10 scenarios)
├── performance/
│   └── test_game_performance.lua   (7 benchmarks)
└── runners/
    ├── run_all_tests.lua           (all tests)
    ├── run_selective_tests.lua     (by category)
    └── main.lua                    (Love2D app)
```

## 🔍 Finding Information

- **Test API:** `tests/TEST_API_FOR_AI.lua`
- **Coverage Report:** `TEST_COVERAGE_REPORT.md`
- **Development Guide:** `tests/TEST_DEVELOPMENT_GUIDE.md`
- **Test README:** `tests/README.md`
- **Mock Data README:** `mock/README.md`

## ⚡ Quick Commands

```bash
# Run all tests
lovec tests/runners

# Run specific category
lovec tests/runners/run_selective_tests.lua core

# Get help
lovec tests/runners/run_selective_tests.lua help

# Run single test (headless)
lua tests/unit/test_state_manager.lua

# Windows shortcut
run_tests.bat
```

## 🎨 Test Output Format

**Success:**
```
✓ testFeature passed
✓ All tests passed!
Total: 10, Passed: 10 (100%)
```

**Failure:**
```
✗ testFeature failed
  Error: Expected 42, got 41
Total: 10, Passed: 9 (90%), Failed: 1 (10%)
```

## 📚 Documentation Files

1. **TEST_API_FOR_AI.lua** - Complete API reference for AI agents
2. **TEST_COVERAGE_REPORT.md** - Visual coverage report
3. **TEST_SUITE_SUMMARY.md** - Detailed test documentation
4. **TEST_DEVELOPMENT_GUIDE.md** - Writing new tests
5. **tests/README.md** - Test system overview
6. **mock/README.md** - Mock data API

## 🤖 AI Agent Protocol

### When asked to run tests:
1. Identify category (all, core, combat, etc.)
2. Use selective runner: `lovec tests/runners/run_selective_tests.lua [category]`
3. Check console output for results
4. Report pass/fail status

### When asked about test coverage:
- Reference TEST_COVERAGE_REPORT.md
- List: 48 unit tests, 20 integration, 7 benchmarks
- Coverage: Core, Base, Combat, Geoscape, Performance

### When asked to write tests:
1. Check TEST_DEVELOPMENT_GUIDE.md for templates
2. Use mock data from `mock/` directory
3. Follow naming convention: `test_[system_name].lua`
4. Add to selective runner registry

### When debugging test failures:
1. Run specific category to isolate
2. Check error messages in output
3. Verify mock data is correct
4. Test individual modules

---

**Quick Tip:** The selective test runner (`run_selective_tests.lua`) is the most flexible way to run tests. Use it for targeted testing during development!
