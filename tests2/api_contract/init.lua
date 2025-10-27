-- ─────────────────────────────────────────────────────────────────────────
-- API CONTRACT TEST REGISTRATION
-- ─────────────────────────────────────────────────────────────────────────
-- Registers all API contract test modules
-- Purpose: Verify API interfaces and contracts
-- Runtime: <3 seconds execution

return {
    "tests2.api_contract.engine_api_contract_test",
    "tests2.api_contract.geoscape_api_contract_test",
    "tests2.api_contract.battlescape_api_contract_test",
    "tests2.api_contract.basescape_api_contract_test",
    "tests2.api_contract.system_api_contract_test",
    "tests2.api_contract.persistence_api_contract_test"
}
