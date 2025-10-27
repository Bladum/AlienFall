-- ─────────────────────────────────────────────────────────────────────────
-- REGRESSION TEST REGISTRATION (by-type structure - linked to tests2/regression/)
-- ─────────────────────────────────────────────────────────────────────────
-- Links to regression tests from tests2/regression/ directory
-- Purpose: Verify known bugs don't regress
-- Runtime: <2 seconds execution
-- Location: tests2/by-type/regression/ (links to tests2/regression/)
--
-- Regression tests ensure that previously fixed bugs do not reoccur.
-- They cover specific scenarios that previously failed and should remain fixed.

return require("tests2.regression")
