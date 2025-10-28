# Compliance Tests (Phase 4)

**Status:** Complete and Ready
**Test Count:** 44 tests across 6 modules
**Runtime:** ~5 seconds
**Purpose:** Verify game rules, constraints, and business logic compliance

## Overview

Compliance tests ensure that the game adheres to its design rules, constraints, and business logic. They verify:

- **Game Rules:** Difficulty modifiers, campaign rules, victory conditions
- **Configuration:** Setting constraints, valid values, defaults
- **Business Logic:** State transitions, turn sequencing, game flow
- **Data Integrity:** Save consistency, state validation, relationships
- **Balance:** Economy scaling, difficulty progression, fairness
- **Constraints:** Resource limits, unit caps, facility restrictions

## Test Modules

### 1. Game Rules Compliance (8 tests)
- Difficulty modifiers apply correctly
- Campaign rules are enforced
- Victory conditions work properly
- Ironman mode restrictions are enforced

**File:** `game_rules_compliance_test.lua`

### 2. Configuration Constraints (7 tests)
- Volume settings stay in valid range
- Resolution settings are valid
- Game speed multiplier is reasonable
- Configuration defaults are set

**File:** `configuration_constraints_test.lua`

### 3. Business Logic Compliance (8 tests)
- State transitions are valid
- Turn sequence is correct
- No phases can be skipped
- Game end conditions work

**File:** `business_logic_compliance_test.lua`

### 4. Data Integrity Compliance (7 tests)
- Save data contains required fields
- Critical fields are never nil
- Save version matches game version
- Game state relationships are valid

**File:** `data_integrity_compliance_test.lua`

### 5. Balance Verification (7 tests)
- Economy is balanced
- Unit costs scale with value
- Difficulty scaling is fair
- Player always has chance to win

**File:** `balance_verification_test.lua`

### 6. Constraint Validation (7 tests)
- Resource limits are enforced
- Unit squad constraints work
- Facility constraints are respected
- Inventory space is limited

**File:** `constraint_validation_test.lua`

## Running Tests

### Run All Compliance Tests
```bash
run_compliance.bat
```

Or:
```bash
lovec tests2/runners run_compliance
```

### Run via Love2D with Console
```bash
lovec "tests2/runners" "run_compliance"
```

## Test Results

Expected output:
```
════════════════════════════════════════════════════════════════════════
AlienFall Test Suite 2 - COMPLIANCE TESTS (Game Rules & Constraints)
════════════════════════════════════════════════════════════════════════

[RUNNER] Loading compliance test suite...
[RUNNER] Found 6 test modules

────────────────────────────────────────────────────────────────────────
COMPLIANCE TEST SUMMARY
────────────────────────────────────────────────────────────────────────
Total:  44
Passed: 44
Failed: 0
────────────────────────────────────────────────────────────────────────

✓ ALL COMPLIANCE TESTS PASSED (Game rules enforced)
```

## Integration with Test Suite

The compliance tests are part of the Phase 4 expansion of the test suite:

- **Phase 1:** Smoke Tests (22 tests) ✓
- **Phase 2:** Regression Tests (38 tests) ✓
- **Phase 3:** API Contract Tests (45 tests) ✓
- **Phase 4:** Compliance Tests (44 tests) ← NEW
- **Phase 5:** Security Tests (44 tests) - Coming next
- **Phase 6+:** Additional test types (150+ tests) - Planned

## Running Full Test Suite

To run all tests including compliance:

```bash
# Run all phases
lovec tests2/by-type
```

Or run individual phases:
```bash
run_smoke.bat
run_regression.bat
run_api_contract.bat
run_compliance.bat           # NEW
```

## Test Coverage

| Category | Tests | Coverage |
|----------|-------|----------|
| Game Rules | 8 | Difficulty, campaign flow, victory |
| Configuration | 7 | Settings, defaults, constraints |
| Business Logic | 8 | State, turns, game flow |
| Data Integrity | 7 | Saves, relationships, validation |
| Balance | 7 | Economy, scaling, fairness |
| Constraints | 7 | Resources, units, facilities |
| **TOTAL** | **44** | **Complete** |

## Development Notes

### Adding New Compliance Tests

To add new compliance tests:

1. Open appropriate test module (e.g., `game_rules_compliance_test.lua`)
2. Add test to existing group or create new group
3. Use `Suite:testMethod()` with:
   - `testCase = "compliance"` or specific type
   - `type = "compliance"`
4. Update test count in this README
5. Commit and run full suite

### Test Naming Convention

- Module files: `*_compliance_test.lua`
- Test methods: `GameRules:method` or `Config:setting` format
- Groups: Logical categories (e.g., "Game Rules", "Balance")

### Helper Functions

All tests use `Helpers` from `tests2.utils.test_helpers`:

```lua
Helpers.assertTrue(condition, "message")
Helpers.assertFalse(condition, "message")
Helpers.assertEqual(actual, expected, "message")
Helpers.assertNotEqual(actual, expected, "message")
Helpers.assertNotNil(value, "message")
```

## Next Steps

- **Phase 5:** Security Tests (input validation, access control, data protection)
- **Phase 6:** Property-Based Tests (edge cases, fuzzing)
- **Phase 7:** Quality Gate Tests (standards, best practices)

---

**Created by:** Test Suite Enhancement (Phase 4)
**Last Updated:** October 27, 2025
**Maintained by:** Quality Assurance Team
