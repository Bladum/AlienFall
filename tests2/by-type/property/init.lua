-- ─────────────────────────────────────────────────────────────────────────
-- PROPERTY-BASED TEST REGISTRATION (by-type structure)
-- ─────────────────────────────────────────────────────────────────────────
-- Registers all property-based test modules
-- Purpose: Test edge cases, boundary conditions, and data mutations
-- Runtime: <8 seconds execution
-- Location: tests2/by-type/property/
--
-- Property-based tests verify that game systems behave correctly under
-- extreme conditions, edge cases, and unexpected inputs. They test boundary
-- values, state invariants, recovery scenarios, and stress conditions.

return {
    "tests2.by_type.property.boundary_conditions_test",
    "tests2.by_type.property.edge_cases_test",
    "tests2.by_type.property.data_mutations_test",
    "tests2.by_type.property.state_invariants_test",
    "tests2.by_type.property.recovery_scenarios_test",
    "tests2.by_type.property.stress_conditions_test",
    "tests2.by_type.property.combinatorial_test"
}
