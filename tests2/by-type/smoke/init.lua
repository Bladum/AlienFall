-- ─────────────────────────────────────────────────────────────────────────
-- SMOKE TEST REGISTRATION (by-type structure - linked to tests2/smoke/)
-- ─────────────────────────────────────────────────────────────────────────
-- Links to smoke tests from tests2/smoke/ directory
-- Purpose: Quick validation that core systems work
-- Runtime: <500ms execution
-- Location: tests2/by-type/smoke/ (links to tests2/smoke/)
--
-- This is a registry that links to the actual smoke tests.
-- Smoke tests validate that essential systems are functional without
-- deep testing. They should be fast (<100ms each) and test primary paths.

return require("tests2.smoke")
