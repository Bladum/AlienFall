-- ─────────────────────────────────────────────────────────────────────────
-- COMPLIANCE TEST REGISTRATION (by-type structure)
-- ─────────────────────────────────────────────────────────────────────────
-- Registers all compliance test modules
-- Purpose: Verify game rules, constraints, and business logic compliance
-- Runtime: <5 seconds execution
-- Location: tests2/by-type/compliance/
--
-- Compliance tests ensure that the game adheres to its rules, constraints,
-- and business logic. They verify difficulty parameters, unit caps, resource
-- limits, victory conditions, and other game design rules are enforced.

return {
    "tests2.by_type.compliance.game_rules_compliance_test",
    "tests2.by_type.compliance.configuration_constraints_test",
    "tests2.by_type.compliance.business_logic_compliance_test",
    "tests2.by_type.compliance.data_integrity_compliance_test",
    "tests2.by_type.compliance.balance_verification_test",
    "tests2.by_type.compliance.constraint_validation_test"
}
