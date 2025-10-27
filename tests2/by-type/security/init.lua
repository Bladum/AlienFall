-- ─────────────────────────────────────────────────────────────────────────
-- SECURITY TEST REGISTRATION (by-type structure)
-- ─────────────────────────────────────────────────────────────────────────
-- Registers all security test modules
-- Purpose: Verify input validation, access control, data protection
-- Runtime: <5 seconds execution
-- Location: tests2/by-type/security/
--
-- Security tests verify that the game is resistant to common attacks,
-- malicious input, unauthorized access, and data corruption. They test
-- validation, authentication, encryption, and integrity verification.

return {
    "tests2.by_type.security.input_validation_security_test",
    "tests2.by_type.security.access_control_security_test",
    "tests2.by_type.security.data_protection_security_test",
    "tests2.by_type.security.injection_prevention_security_test",
    "tests2.by_type.security.authentication_security_test",
    "tests2.by_type.security.integrity_verification_security_test"
}
