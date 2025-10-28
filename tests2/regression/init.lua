-- ─────────────────────────────────────────────────────────────────────────
-- REGRESSION TEST REGISTRATION
-- ─────────────────────────────────────────────────────────────────────────
-- Registers all regression test modules for bug prevention
-- Purpose: Verify known bugs don't regress
-- Runtime: <2 seconds execution

return {
    "tests2.regression.core_regression_test",
    "tests2.regression.gameplay_regression_test",
    "tests2.regression.combat_regression_test",
    "tests2.regression.ui_regression_test",
    "tests2.regression.economy_regression_test",
    "tests2.regression.performance_regression_test"
}
