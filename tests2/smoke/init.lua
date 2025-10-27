-- ─────────────────────────────────────────────────────────────────────────
-- SMOKE TEST REGISTRATION
-- ─────────────────────────────────────────────────────────────────────────
-- Registers all smoke tests for the test suite
-- Purpose: Quick validation that core systems work
-- Runtime: <500ms execution

return {
    "tests2.smoke.core_systems_smoke_test",
    "tests2.smoke.gameplay_loop_smoke_test",
    "tests2.smoke.asset_loading_smoke_test",
    "tests2.smoke.persistence_smoke_test",
    "tests2.smoke.ui_smoke_test"
}
