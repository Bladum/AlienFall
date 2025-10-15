# Quick Test Commands Reference

## 🚀 How to Run Tests

### Method 1: Run All Tests (Standalone Love2D App)
```bash
# From project root
lovec tests/runners
```
This runs `tests/runners/main.lua` which executes all registered tests.

### Method 2: Run Selective Tests
```bash
# From project root - run selective test runner as a standalone file
cd tests/runners
lovec . [category]

# Or specify full path
lovec tests/runners/run_selective_tests.lua [category]
```

**Available categories:**
- `core` - Core systems (6 test files)
- `basescape` - Base management (2 test files)
- `geoscape` - World systems (1 test file)
- `combat` - Combat systems (4 test files)
- `performance` - Performance benchmarks (1 test file)
- `all` - All tests (default)

### Method 3: Run Individual Test Files
```bash
# Unit tests
lua tests/unit/test_spatial_hash.lua
lua tests/unit/test_save_system.lua
lua tests/unit/test_accuracy_system.lua
lua tests/unit/test_mod_manager.lua

# Integration tests
lua tests/integration/test_battlescape_workflow.lua
lua tests/integration/test_combat_integration.lua
lua tests/integration/test_base_integration.lua

# Performance tests
lua tests/performance/test_game_performance.lua
```

### Method 4: Windows Batch File
```bash
run_tests.bat
```

## 📊 What Each Category Tests

### Core (6 tests, 60+ cases)
- **test_state_manager.lua** - State transitions and management
- **test_audio_system.lua** - Audio volume and categories
- **test_data_loader.lua** - Data loading and validation
- **test_spatial_hash.lua** ⭐ NEW - Spatial partitioning system
- **test_save_system.lua** ⭐ NEW - Save/load persistence
- **test_mod_manager.lua** ⭐ NEW - Mod loading system

**Run:** `cd tests/runners; lovec . core`

### Basescape (2 tests, 21 cases)
- **test_facility_system.lua** - Facility management
- **test_base_integration.lua** - Complete base workflows

**Run:** `cd tests/runners; lovec . basescape`

### Geoscape (1 test, 10 cases)
- **test_world_system.lua** - Hex grid and world systems

**Run:** `cd tests/runners; lovec . geoscape`

### Combat (4 tests, 40+ cases)
- **test_pathfinding.lua** - A* pathfinding
- **test_accuracy_system.lua** ⭐ NEW - Accuracy calculations
- **test_combat_integration.lua** - Combat workflows
- **test_battlescape_workflow.lua** ⭐ NEW - Tactical combat

**Run:** `cd tests/runners; lovec . combat`

### Performance (1 test, 7 benchmarks)
- **test_game_performance.lua** - Performance benchmarks

**Run:** `cd tests/runners; lovec . performance`

## 🎭 Mock Data Quick Reference

```lua
-- Load mock data modules
local MockUnits = require("mock.units")
local MockItems = require("mock.items")
local MockFacilities = require("mock.facilities")
local MockEconomy = require("mock.economy")
local MockGeoscape = require("mock.geoscape")
local MockBattlescape = require("mock.battlescape")  -- ⭐ NEW

-- Generate test data
local soldier = MockUnits.getSoldier("John", "ASSAULT")
local rifle = MockItems.getWeapon("RIFLE")
local base = MockFacilities.getStarterBase()
local finances = MockEconomy.getFinances()
local world = MockGeoscape.getWorld()
local battlefield = MockBattlescape.getBattlefield(40, 40, "urban")  -- ⭐ NEW
```

## 📝 Test Output Format

### Success
```
✓ testFeatureName passed
✓ All tests passed!
Total: 10, Passed: 10 (100%)
```

### Failure
```
✗ testFeatureName failed
  Error: Expected 42, got 41
Total: 10, Passed: 9 (90%), Failed: 1 (10%)

Failed tests:
  ✗ testFeatureName: Assertion failed: Expected 42, got 41
```

## 🔍 Troubleshooting

### "Cannot load game at path"
- Make sure you're in the correct directory
- Use `lovec .` when inside `tests/runners/`
- Or use full path: `lovec tests/runners/run_selective_tests.lua [category]`

### "Module not found"
- Check that `package.path` is set correctly
- Ensure you're running from project root or tests/runners directory

### "Function has no runAll()"
- Test module must export a `runAll()` function
- Check test file structure

## 📚 Documentation Files

- **tests/README.md** - Test system overview
- **tests/AI_AGENT_QUICK_REF.md** - Quick reference card
- **tests/TEST_API_FOR_AI.lua** - Complete API reference
- **tests/TEST_DEVELOPMENT_GUIDE.md** - How to write tests
- **mock/README.md** - Mock data API
- **COMPLETE_TEST_COVERAGE_REPORT.md** - Full coverage report
- **TEST_EXTENSION_SUMMARY.md** - Recent additions summary

## ⚡ Quick Test Workflow

```bash
# 1. Navigate to project root
cd c:\Users\tombl\Documents\Projects

# 2. Run specific category during development
cd tests/runners
lovec . combat

# 3. Run all tests before commit
cd tests/runners
lovec .

# 4. Check specific test file
cd ../..
lua tests/unit/test_spatial_hash.lua
```

## 🤖 For AI Agents

When asked to run tests:

1. **Identify category:** Determine which category (core, combat, etc.)
2. **Navigate:** `cd tests/runners`
3. **Execute:** `lovec . [category]`
4. **Report:** Check console output for pass/fail

When asked about mock data:

1. **Check mock/README.md** for available generators
2. **Use appropriate mock file** (units, items, facilities, economy, geoscape, battlescape)
3. **Call generator functions** with desired parameters

---

**Last Updated:** October 15, 2025  
**Test Suite Version:** 2.0  
**Total Tests:** 100+  
**Execution Time:** < 30 seconds
