<!-- ──────────────────────────────────────────────────────────────────────────
REGRESSION TEST SUITE DOCUMENTATION
────────────────────────────────────────────────────────────────────────── -->

# Regression Tests - Bug Prevention Suite

## Overview

Regression tests verify that **previously discovered bugs don't resurface**. They test edge cases, boundary conditions, and known problem areas that could regress if code changes aren't careful.

**Purpose:** Prevent bugs from reoccurring (< 2 seconds)
**Scope:** Edge cases, boundary conditions, balance/economy, performance
**Count:** 38 tests
**Execution Time:** < 2 seconds

## Test Categories

### 1. Core System Regressions (8 tests)
Tests for edge cases in core system behavior.

- **Engine:nullStateTransition** - Null state handling
- **Engine:moduleLoadingOrder** - Module dependency order
- **Engine:rapidStateChanges** - State integrity under rapid changes
- **Engine:errorRecovery** - Error handling and recovery
- **Engine:resourceCleanup** - Resource deallocation on shutdown
- **Engine:concurrentStateAccess** - Race condition prevention
- **Engine:nestedStateTransitions** - Stack-based state management
- **Engine:memoryLeakPrevention** - Memory leak detection

### 2. Gameplay Regressions (8 tests)
Tests for edge cases in game flow and progression.

- **Campaign:turnCounterOverflow** - Large number handling
- **Campaign:negativeFundsHandling** - Negative value clamping
- **Campaign:missionStateConsistency** - Mission state tracking
- **Campaign:simultaneousMissions** - Multiple concurrent missions
- **Campaign:researchTechTree** - Dependency ordering
- **Campaign:baseConstructionQueue** - Queue management
- **Campaign:alienActivityEscalation** - Difficulty scaling
- **Campaign:timeTransitions** - Month/year boundaries

### 3. Combat Regressions (8 tests)
Tests for edge cases in battlescape combat.

- **Combat:hitChanceCalculation** - Probability bounds (0-100%)
- **Combat:armorCalculation** - Damage reduction underflow
- **Combat:turnOrderConsistency** - Initiative tracking
- **Combat:movementPointExhaustion** - Movement limit enforcement
- **Combat:friendlyFirePrevention** - Team validation
- **Combat:lineOfSight** - Obstacle detection
- **Combat:actionPointManagement** - Action point reset
- **Combat:criticalHitProbability** - Crit chance bounds

### 4. UI/UX Regressions (6 tests)
Tests for edge cases in user interface.

- **UI:buttonClickHandling** - Click deduplication
- **UI:focusManagement** - Focus transfer and overlay handling
- **UI:tooltipDisplay** - Tooltip positioning and overlap
- **UI:scrollConsistency** - Scroll position persistence
- **UI:textInputBuffer** - Text corruption prevention
- **UI:panelScaling** - Resolution scaling

### 5. Economy Regressions (5 tests)
Tests for financial and balance system edge cases.

- **Economy:currencyPrecision** - Floating point accuracy
- **Economy:largeTransactions** - Large number handling
- **Economy:incomeExpenseBalance** - Income/expense tracking
- **Economy:buildingCosts** - Construction cost calculation
- **Economy:maintenanceCosts** - Facility maintenance accuracy

### 6. Performance Regressions (3 tests)
Tests for performance degradation detection.

- **Performance:frameTimeSpikeDetection** - Frame time monitoring
- **Performance:memoryGrowthTrend** - Memory leak detection
- **Performance:batchRenderingEfficiency** - Rendering optimization

---

## Running Regression Tests

### Option 1: Batch File (Recommended for Windows)
```bash
run_regression.bat
```

### Option 2: Command Line
```bash
lovec "tests2/runners" "run_regression"
```

### Option 3: Via Test Framework
```bash
lovec "tests2/runners"  # Main test runner will include regression tests
```

## Expected Results

**Success:** All 38 tests pass
```
Regression Test Summary
═════════════════════════════════════════════════════════════════════════
Total:  38
Passed: 38
Failed: 0
═════════════════════════════════════════════════════════════════════════

✓ ALL REGRESSION TESTS PASSED (No bugs detected)
```

**Failure:** If tests fail, check the specific test output to identify the regression.

## File Structure

```
tests2/
├── regression/                        (Phase 2 - Regression Tests)
│   ├── init.lua                      (Test registration)
│   ├── core_regression_test.lua      (8 tests)
│   ├── gameplay_regression_test.lua  (8 tests)
│   ├── combat_regression_test.lua    (8 tests)
│   ├── ui_regression_test.lua        (6 tests)
│   ├── economy_regression_test.lua   (5 tests)
│   ├── performance_regression_test.lua (3 tests)
│   └── README.md                     (This file)
└── runners/
    └── run_regression.lua            (Regression test runner)
```

## Test Framework

All regression tests use **HierarchicalSuite** with the `type = "regression"` marker:

```lua
Suite:testMethod("ModuleName:bugName", {
    description = "What bug this prevents",
    testCase = "edge_case|validation|stress|error_handling|cleanup",
    type = "regression"
}, function()
    -- Test code using Helpers assertions
end)
```

## When Regression Tests Fail

1. **Identify which test failed** - Console output shows test name
2. **Understand what bug it's preventing** - Check description
3. **Find the code change that caused it** - Likely recent commit
4. **Fix the regression** - Either fix the code or update the test
5. **Re-run regression tests** - Verify fix works

## Bug Tracking Integration

Each regression test should correspond to:
- A bug report or issue number
- Original symptoms observed
- Root cause analysis
- Prevention strategy

Example:
```lua
-- REGRESSION-042: Turn counter overflow at max int
-- Original Issue: Game crashed when turn reached 2,147,483,647
-- Fix: Use larger integer type for turn counter
-- Test: Verify counter can exceed 999,999
Suite:testMethod("Campaign:turnCounterOverflow", { ... })
```

## Common Regression Patterns

**Type: Boundary Overflow**
- Values exceeding max/min bounds
- Integer overflow/underflow
- String buffer overflows

**Type: State Corruption**
- Rapid state changes
- Concurrent modifications
- Incomplete cleanup

**Type: Resource Leaks**
- Memory not freed
- File handles not closed
- Event listeners not removed

**Type: Calculation Errors**
- Floating point precision
- Off-by-one errors
- Incorrect formulas

## Integration with Full Test Suite

Regression tests are:
- ✅ Run as part of the full test suite
- ✅ Run independently for quick feedback
- ✅ Integrated into CI/CD pipeline
- ✅ Fast enough to run on every code change

## Next Steps

After Phase 2 completion:
- Phase 3: API Contract Tests (45 tests)
- Phase 4: Compliance Tests (44 tests)
- Phase 5: Security Tests (44 tests)
- Phase 6: Property-Based Tests (55 tests)
- Phase 7: Quality Gate Tests (34 tests)

Total target: 282 new tests across 7 categories

---

## Summary

Phase 2 adds **38 regression tests** across 6 categories to catch bugs from:
- Core system edge cases
- Gameplay flow problems
- Combat system issues
- UI/UX glitches
- Economy/balance problems
- Performance degradation

All tests use standardized HierarchicalSuite framework and integrate seamlessly with existing test infrastructure.
