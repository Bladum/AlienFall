<!-- ──────────────────────────────────────────────────────────────────────────
SMOKE TEST SUITE DOCUMENTATION
────────────────────────────────────────────────────────────────────────── -->

# Smoke Tests - Quick Validation Suite

## Overview

Smoke tests are **quick validation tests** that verify core systems initialize and basic functionality works without critical errors. They run in parallel with the full test suite to provide rapid feedback during development.

**Purpose:** Catch obvious breaks quickly (< 500ms)
**Scope:** Core initialization, basic gameplay loop, asset loading, persistence, UI
**Count:** 22 tests
**Execution Time:** < 500ms

## Test Categories

### 1. Core Systems Initialization (5 tests)
Tests that the game engine initializes correctly and core modules load.

- **Engine:initialize** - Game state initializes without error
- **Engine:loadCoreModules** - All core modules load successfully
- **StateManager:setState** - State transitions work
- **Engine:errorHandling** - Errors are caught and handled
- **Engine:resolveDependencies** - Module dependencies resolve correctly

### 2. Gameplay Loop (6 tests)
Tests the basic gameplay loop from geoscape through battlescape and back.

- **Geoscape:load** - Geoscape loads without error
- **Battlescape:load** - Battlescape loads and map generates
- **Gameplay:returnToGeoscape** - Transition back to geoscape works
- **Campaign:start** - Campaign initializes correctly
- **TurnManager:completeTurn** - Turn counter advances
- **SaveSystem:saveGame** - Game state can be serialized

### 3. Asset Loading (4 tests)
Tests that all required assets load without file-not-found errors.

- **AssetManager:loadSprites** - All sprite categories load
- **AssetManager:loadAudio** - All audio files load
- **AssetManager:loadUI** - UI assets are available
- **AssetManager:validateAssets** - No missing asset files

### 4. Persistence (4 tests)
Tests the save/load system works correctly.

- **SaveManager:saveGame** - Save files are created correctly
- **SaveManager:loadGame** - Game state is restored from save
- **SaveManager:multipleSaveSlots** - Multiple save slots work independently
- **SaveManager:rapidSaveLoad** - Rapid save/load cycles don't corrupt state

### 5. UI System (3 tests)
Tests that UI renders and responds to interaction.

- **UIManager:renderMainMenu** - Main menu renders without errors
- **UIManager:buttonInteraction** - Buttons respond to input
- **UIManager:validateLayout** - UI layout has no overlaps or gaps

## Running Smoke Tests

### Option 1: Batch File (Windows)
```bash
run_smoke.bat
```

### Option 2: Command Line
```bash
lovec "tests2/runners" "run_smoke"
```

### Option 3: VS Code Task
```
Ctrl+Shift+P > Run Task > Smoke Tests
```

## Expected Results

**Success:** All 22 tests pass
```
Smoke Test Summary
═════════════════════════════════════════════════════════════════════════
Total:  22
Passed: 22
Failed: 0
═════════════════════════════════════════════════════════════════════════

✓ ALL SMOKE TESTS PASSED
```

**Failure:** If any test fails, check the console output for which test failed and why.

## File Structure

```
tests2/
├── smoke/                         (Phase 1 - Smoke Tests)
│   ├── init.lua                  (Test registration)
│   ├── core_systems_smoke_test.lua (5 tests)
│   ├── gameplay_loop_smoke_test.lua (6 tests)
│   ├── asset_loading_smoke_test.lua (4 tests)
│   ├── persistence_smoke_test.lua (4 tests)
│   ├── ui_smoke_test.lua         (3 tests)
│   └── README.md                 (This file)
└── runners/
    └── run_smoke.lua             (Smoke test runner)
```

## Test Framework

All smoke tests use the **HierarchicalSuite** framework with the `type = "smoke"` marker:

```lua
Suite:testMethod("ModuleName:action", {
    description = "What this test validates",
    testCase = "happy_path|validation|stress",
    type = "smoke"
}, function()
    -- Test code using Helpers assertions
end)
```

## When Smoke Tests Fail

1. **Check console output** - Error message indicates which test failed
2. **Review test file** - Look at the specific test method
3. **Check engine code** - The module being tested may have a bug
4. **Run with debugger** - Use `lovec "engine"` to debug the engine

## Integration with Full Test Suite

Smoke tests are:
- ✅ Run as part of the full test suite
- ✅ Run independently for quick feedback
- ✅ Integrated into CI/CD pipeline
- ✅ Fast enough to run on every code change

## Next Steps

After Phase 1 completion:
- Phase 2: Regression Tests (38 tests)
- Phase 3: API Contract Tests (45 tests)
- Phase 4: Compliance Tests (44 tests)
- Phase 5-10: Security, Property-Based, Quality Gate tests

Total target: 282 new tests across 7 categories
