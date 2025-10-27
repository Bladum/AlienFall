# Security Tests (Phase 5)

**Status:** Complete and Ready
**Test Count:** 44 tests across 6 modules
**Runtime:** ~5 seconds
**Purpose:** Verify data protection, access control, and attack prevention

## Overview

Security tests ensure that the game is resistant to attacks, malicious input, unauthorized access, and data corruption. They verify:

- **Input Validation:** Range validation, type checking, malicious data rejection
- **Access Control:** Permission checking, role validation, authorization
- **Data Protection:** Encryption, secure storage, sensitive data hiding
- **Injection Prevention:** Lua injection, SQL injection, command injection
- **Authentication:** User verification, session management, token validation
- **Integrity Verification:** Checksum validation, tampering detection, signature checks

## Test Modules

### 1. Input Validation Security (8 tests)
- String input validation (code injection prevention)
- Numeric input validation (range/bounds checking)
- Type validation (enforce correct types)
- Sanitization of dangerous characters

**File:** `input_validation_security_test.lua`

### 2. Access Control Security (7 tests)
- Permission verification
- Role-based access control
- Player cannot modify enemy data
- Debug and cheat code restrictions
- File operation boundaries

**File:** `access_control_security_test.lua`

### 3. Data Protection Security (8 tests)
- Passwords never logged or stored as plaintext
- Save games have checksums
- Sensitive fields are protected
- Session tokens are encrypted
- Temporary data is cleared on exit

**File:** `data_protection_security_test.lua`

### 4. Injection Prevention Security (8 tests)
- Lua code injection prevention
- Command injection prevention
- File path traversal prevention
- Format string attack prevention
- SQL injection prevention
- Parameterized queries

**File:** `injection_prevention_security_test.lua`

### 5. Authentication Security (7 tests)
- User authentication for sensitive operations
- Session timeout on inactivity
- Tokens never contain passwords
- Token refresh mechanism
- Replay attack prevention
- Rate limiting on failed attempts

**File:** `authentication_security_test.lua`

### 6. Integrity Verification Security (6 tests)
- Checksum validation and verification
- Tampering detection
- Corrupted file detection
- Integrity seals on sensitive data
- Digital signature verification

**File:** `integrity_verification_security_test.lua`

## Running Tests

### Run All Security Tests
```bash
run_security.bat
```

Or:
```bash
lovec tests2/runners run_security
```

### Run via Love2D with Console
```bash
lovec "tests2/runners" "run_security"
```

## Test Results

Expected output:
```
════════════════════════════════════════════════════════════════════════
AlienFall Test Suite 2 - SECURITY TESTS (Protection & Access Control)
════════════════════════════════════════════════════════════════════════

[RUNNER] Loading security test suite...
[RUNNER] Found 6 test modules

────────────────────────────────────────────────────────────────────────
SECURITY TEST SUMMARY
────────────────────────────────────────────────────────────────────────
Total:  44
Passed: 44
Failed: 0
────────────────────────────────────────────────────────────────────────

✓ ALL SECURITY TESTS PASSED (Data protected)
```

## Integration with Test Suite

The security tests are part of Phase 5 expansion of the test suite:

- **Phase 1:** Smoke Tests (22 tests) ✓
- **Phase 2:** Regression Tests (38 tests) ✓
- **Phase 3:** API Contract Tests (45 tests) ✓
- **Phase 4:** Compliance Tests (44 tests) ✓
- **Phase 5:** Security Tests (44 tests) ← NEW
- **Phase 6+:** Additional test types (150+ tests) - Planned

## Running Full Test Suite

To run all tests including security:

```bash
# Run all phases
lovec tests2/by-type
```

Or run individual phases:
```bash
run_smoke.bat
run_regression.bat
run_api_contract.bat
run_compliance.bat
run_security.bat           # NEW
```

## Test Coverage

| Category | Tests | Coverage |
|----------|-------|----------|
| Input Validation | 8 | Range, type, injection |
| Access Control | 7 | Permissions, roles, boundaries |
| Data Protection | 8 | Encryption, storage, hiding |
| Injection Prevention | 8 | Lua, SQL, command, format |
| Authentication | 7 | User verify, session, token |
| Integrity | 6 | Checksum, tampering, seal |
| **TOTAL** | **44** | **Complete** |

## Security Best Practices Tested

### Input Validation
- All user input is validated for type and range
- Dangerous characters are sanitized
- File paths are restricted to allowed directories
- Numeric values have reasonable bounds

### Access Control
- Players cannot modify enemy or system data
- Admin functions require authentication
- Debug/cheat features are disabled in release builds
- File operations are sandboxed

### Data Protection
- Passwords are hashed, never stored as plaintext
- Sensitive data is encrypted at rest and in transit
- Session tokens are cryptographically secure
- Save files have integrity checksums

### Attack Prevention
- No use of `loadstring()` on user input
- No dynamic code generation from user data
- Parameterized queries for any database access
- Format strings only from system code
- OS command execution never from user input

### Authentication & Sessions
- Sessions timeout after inactivity
- Replay attacks are prevented with nonces
- Failed attempts are rate limited
- Tokens have expiration times

### Integrity Verification
- Save files validated with checksums
- Corrupted data is detected and rejected
- Game state changes are sealed
- Downloads are cryptographically signed

## Development Notes

### Adding New Security Tests

To add new security tests:

1. Open appropriate test module (e.g., `input_validation_security_test.lua`)
2. Add test to existing group or create new group
3. Use `Suite:testMethod()` with:
   - `testCase = "specific_attack_type"`
   - `type = "security"`
4. Update test count in this README
5. Commit and run full suite

### Test Naming Convention

- Module files: `*_security_test.lua`
- Test methods: `Security:method` or `Config:setting` format
- Groups: Attack types (e.g., "Lua Code Injection", "Access Control")

### Helper Functions

All tests use `Helpers` from `tests2.utils.test_helpers`:

```lua
Helpers.assertTrue(condition, "message")
Helpers.assertFalse(condition, "message")
Helpers.assertEqual(actual, expected, "message")
Helpers.assertNotEqual(actual, expected, "message")
Helpers.assertNotNil(value, "message")
Helpers.assertNil(value, "message")
```

## Security Considerations

This test suite addresses common game security issues:

1. **Cheat Prevention:** Validates game rules and state integrity
2. **Save File Protection:** Checksums and encryption
3. **User Input Safety:** Sanitization and validation
4. **Access Control:** Role-based permissions
5. **Data Confidentiality:** Encryption at rest and in transit
6. **Replay Prevention:** Nonces and timestamps
7. **Tamper Detection:** Integrity seals and signatures

## Next Steps

- **Phase 6:** Property-Based Tests (edge cases, fuzzing)
- **Phase 7:** Quality Gate Tests (standards, best practices)
- **Phase 8+:** Performance, stress, and integration tests

---

**Created by:** Test Suite Enhancement (Phase 5)
**Last Updated:** October 27, 2025
**Security Focus:** Data protection, access control, attack prevention
**Maintained by:** Quality Assurance & Security Team
