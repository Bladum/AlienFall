-- ─────────────────────────────────────────────────────────────────────────
-- API CONTRACT TEST REGISTRATION (by-type structure - linked to tests2/api_contract/)
-- ─────────────────────────────────────────────────────────────────────────
-- Links to API contract tests from tests2/api_contract/ directory
-- Purpose: Verify API interfaces and contracts
-- Runtime: <3 seconds execution
-- Location: tests2/by-type/contract/ (links to tests2/api_contract/)
--
-- API Contract tests verify that interfaces between systems are maintained.
-- They test method signatures, return values, and API invariants to ensure
-- systems can interact correctly regardless of internal implementation changes.

return require("tests2.api_contract")
