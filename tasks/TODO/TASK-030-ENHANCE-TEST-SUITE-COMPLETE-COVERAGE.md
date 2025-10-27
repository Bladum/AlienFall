# Task: ENHANCE TEST SUITE - Complete Coverage (Smoke, Regression, API, Compliance, Security, Property, Quality)

**Status:** TODO
**Priority:** High
**Created:** October 27, 2025
**Completed:** N/A
**Assigned To:** Development Team

---

## Overview

Enhance the existing test suite (tests2/) with missing critical test categories to achieve production-grade test coverage. Current test suite has 2,493 tests focused on functional, integration, and performance testing, but lacks smoke, regression, API, compliance, security, property-based, and quality tests.

**Current State:**
- ✅ 2,493 total tests across 11 subsystems
- ✅ Functional tests: 3,003 instances
- ✅ Integration tests: 11 instances
- ✅ Performance tests: 41 instances
- ✅ Error handling: 11 instances
- ✅ Edge cases: 8 instances
- ✅ Validation: 2 instances
- ❌ Smoke tests: 0
- ❌ Regression tests: 0
- ❌ API contract tests: 0
- ❌ Compliance tests: 0
- ❌ Security tests: 0
- ❌ Property-based tests: 0
- ❌ Quality gate tests: 0

---

## Purpose

**Why is this necessary?**
1. **Risk Management:** Smoke tests catch critical failures immediately
2. **Stability:** Regression tests prevent features from breaking during updates
3. **API Contracts:** Ensure external APIs remain backward compatible
4. **Compliance:** Validate against design specifications and data persistence rules
5. **Security:** Prevent unauthorized access, injection attacks, data leaks
6. **Reliability:** Property-based tests find edge cases humans miss
7. **Quality Gates:** Automated enforcement of code quality standards

**Business Impact:**
- Reduce production bugs by 40-60%
- Faster development cycles (CI/CD confidence)
- Lower regression bug rates
- Compliance audit readiness
- Security vulnerability detection

---

## Requirements

### Functional Requirements

#### Phase 1: Smoke Tests (Foundation)
- [ ] Verify core systems start without crashes
- [ ] Validate basic gameplay loop (geoscape → battlescape → return)
- [ ] Check asset loading (no missing sprites/audio)
- [ ] Ensure save/load system works
- [ ] Verify UI responds to input

#### Phase 2: Regression Tests (Stability)
- [ ] Prevent reintroduction of fixed bugs
- [ ] Validate feature stability across versions
- [ ] Track historical bugs that re-appear
- [ ] Create regression test database
- [ ] Link to GitHub issues/commits

#### Phase 3: API Contract Tests (Interfaces)
- [ ] Validate TOML configuration schemas
- [ ] Verify mod API signatures match documentation
- [ ] Check serialization/deserialization contracts
- [ ] Validate network protocol messages (if applicable)
- [ ] Test backward compatibility

#### Phase 4: Compliance Tests (Rules)
- [ ] Verify game balance parameters (cost, damage, health ranges)
- [ ] Validate data persistence layer
- [ ] Check localization keys exist
- [ ] Ensure mod restrictions are enforced
- [ ] Verify faction reputation rules

#### Phase 5: Security Tests (Protection)
- [ ] Prevent save file tampering (data validation)
- [ ] SQL injection prevention (TOML parsing)
- [ ] Access control (admin-only features)
- [ ] Mod sandbox restrictions
- [ ] Input sanitization

#### Phase 6: Property-Based Tests (Robustness)
- [ ] Generate random valid game states
- [ ] Test invariants hold across operations
- [ ] Find edge cases in procedural generation
- [ ] Validate mathematical properties (hex math)
- [ ] Stress test data structures

#### Phase 7: Quality Gate Tests (Standards)
- [ ] Enforce code style/naming conventions
- [ ] Verify test coverage thresholds
- [ ] Check documentation completeness
- [ ] Validate performance benchmarks
- [ ] Ensure no deprecated API usage

### Technical Requirements
- [ ] Extend HierarchicalSuite framework with new test types
- [ ] Create smoke test runner (`tests2/runners/run_smoke.lua`)
- [ ] Create regression test database (`tests2/regression/database.lua`)
- [ ] Create API contract validator (`tests2/framework/api_contract_validator.lua`)
- [ ] Create compliance checker (`tests2/framework/compliance_checker.lua`)
- [ ] Create security auditor (`tests2/framework/security_auditor.lua`)
- [ ] Create property generator (`tests2/framework/property_generator.lua`)
- [ ] Create quality gate checker (`tests2/framework/quality_gate_checker.lua`)
- [ ] Update test_helpers.lua with new assertion types
- [ ] Create comprehensive documentation
- [ ] Integrate with VS Code tasks

### Acceptance Criteria
- [ ] All 7 test type categories implemented
- [ ] Framework extensions work seamlessly with HierarchicalSuite
- [ ] Documentation complete with examples for each test type
- [ ] All tests pass (0 failures)
- [ ] Performance remains <1 second for quick smoke tests
- [ ] Full suite runs in <5 seconds
- [ ] CI/CD integration ready (batch files created)
- [ ] No regressions in existing 2,493 tests

---

## Plan

### PHASE 1: SMOKE TESTS (15 hours)

**Goal:** Quick validation that core systems work

#### Step 1.1: Create Smoke Test Framework
**Description:** Create smoke test infrastructure and helpers
**Files to create:**
- `tests2/smoke/init.lua` - Smoke test registration
- `tests2/smoke/core_systems_smoke_test.lua` - Core system smoke tests
- `tests2/smoke/gameplay_loop_smoke_test.lua` - Gameplay loop smoke tests
- `tests2/smoke/asset_loading_smoke_test.lua` - Asset loading smoke tests
- `tests2/smoke/persistence_smoke_test.lua` - Save/load smoke tests
- `tests2/smoke/ui_smoke_test.lua` - UI interaction smoke tests
- `tests2/smoke/README.md` - Documentation

**Tests to create:**
1. **Core Systems Smoke Tests (5 tests)**
   - StateManager initializes without crash
   - Core modules load successfully
   - Basic state transitions work
   - Error handling doesn't crash
   - Module interdependencies resolve

2. **Gameplay Loop Smoke Tests (6 tests)**
   - Geoscape loads
   - Battlescape loads
   - Return to geoscape works
   - Campaign starts
   - Turn completion works
   - Game saves state

3. **Asset Loading Smoke Tests (4 tests)**
   - All sprites load
   - All audio files load
   - UI assets available
   - No "file not found" errors

4. **Persistence Smoke Tests (4 tests)**
   - Save game creates file
   - Load game reads file
   - State matches after load
   - Multiple save slots work

5. **UI Smoke Tests (3 tests)**
   - Main menu renders
   - Buttons respond to clicks
   - No layout errors

**Estimated time:** 5 hours

#### Step 1.2: Create Smoke Test Runner
**Description:** Create runner to execute smoke tests quickly
**Files to create:**
- `tests2/runners/run_smoke.lua` - Smoke test runner
- `run_smoke.bat` - Windows batch file
- Update `tests2/main.lua` with smoke test routing

**Test execution patterns:**
```bash
lovec "tests2/runners" run_smoke          # All smoke tests
lovec "tests2/runners" run_smoke core     # Specific subsystem
lovec "tests2/runners" run_smoke fast     # Fast subset (30 tests, <500ms)
```

**Estimated time:** 3 hours

#### Step 1.3: Extend HierarchicalSuite for Smoke Tests
**Description:** Add smoke test metadata and reporting
**Files to modify:**
- `tests2/framework/hierarchical_suite.lua` - Add `type = "smoke"` support
- `tests2/framework/hierarchy_reporter.lua` - Add smoke test reporting

**Features:**
- Mark tests as `type = "smoke"` for quick validation
- Filter and run only smoke tests
- Report smoke test results separately
- Track smoke test runtime

**Estimated time:** 4 hours

#### Step 1.4: Documentation & Integration
**Description:** Document smoke tests and integrate with build system
**Files to create:**
- `tests2/smoke/README.md` - How to write/run smoke tests
- Update `tests2/README.md` with smoke test section

**Files to modify:**
- `.github/workflows/ci.yml` - Add smoke test stage
- Create VS Code task for smoke tests

**Estimated time:** 3 hours

---

### PHASE 2: REGRESSION TESTS (12 hours)

**Goal:** Track and prevent reintroduction of fixed bugs

#### Step 2.1: Create Regression Test Database
**Description:** Build system to track known bugs and create regression tests
**Files to create:**
- `tests2/regression/database.lua` - Regression database
- `tests2/regression/bug_tracker.lua` - Bug entry system
- `tests2/regression/init.lua` - Regression suite registration

**Database structure:**
```lua
{
  {
    bug_id = "BUG-001",
    title = "Units fall through floor in battlescape",
    severity = "critical",
    fixed_by = "COMMIT_HASH",
    test_case = function() ... end,
    tags = {"battlescape", "pathfinding"}
  },
  -- ... more bugs
}
```

**Estimated time:** 4 hours

#### Step 2.2: Implement Regression Test Cases
**Description:** Create regression tests for common bugs
**Files to create:**
- `tests2/regression/battlescape_regressions_test.lua` (10 tests)
- `tests2/regression/geoscape_regressions_test.lua` (8 tests)
- `tests2/regression/basescape_regressions_test.lua` (8 tests)
- `tests2/regression/economy_regressions_test.lua` (6 tests)
- `tests2/regression/save_load_regressions_test.lua` (6 tests)

**Sample Regression Tests:**
1. "Units don't fall through floor" (Battlescape)
2. "UFO interception doesn't crash" (Geoscape)
3. "Facility construction works after cancel" (Basescape)
4. "Market prices don't go negative" (Economy)
5. "Save file corrupts on rapid load/save" (Persistence)

**Total: 38 regression tests**

**Estimated time:** 6 hours

#### Step 2.3: Create Regression Test Runner
**Description:** Runner to execute regression tests before release
**Files to create:**
- `tests2/runners/run_regressions.lua`
- `run_regressions.bat`
- Update `tests2/main.lua`

**Estimated time:** 2 hours

---

### PHASE 3: API CONTRACT TESTS (10 hours)

**Goal:** Ensure mod APIs and configuration schemas are valid

#### Step 3.1: Create API Contract Validator
**Description:** Validate TOML schemas and mod API signatures
**Files to create:**
- `tests2/framework/api_contract_validator.lua` - Contract validation
- `tests2/framework/schema_validator.lua` - Schema checking
- `tests2/api/init.lua` - API test registration

**Validators:**
- TOML schema validation (GAME_API.toml compliance)
- Function signature matching
- Data type validation
- Required field checking
- Backward compatibility checking

**Estimated time:** 4 hours

#### Step 3.2: Implement API Contract Tests
**Description:** Create contract tests for main APIs
**Files to create:**
- `tests2/api/units_api_test.lua` (8 tests)
- `tests2/api/weapons_api_test.lua` (6 tests)
- `tests2/api/facilities_api_test.lua` (7 tests)
- `tests2/api/crafts_api_test.lua` (6 tests)
- `tests2/api/mod_api_test.lua` (10 tests)

**Sample Contract Tests:**
1. Unit schema validates required fields
2. Weapon damage type matches enum values
3. Facility construction cost is positive
4. Craft capacity values are non-negative
5. Mod API function signatures match documentation

**Total: 37 API contract tests**

**Estimated time:** 4 hours

#### Step 3.3: Backward Compatibility Tests
**Description:** Ensure new versions don't break mod compatibility
**Files to create:**
- `tests2/api/backward_compatibility_test.lua` (8 tests)

**Estimated time:** 2 hours

---

### PHASE 4: COMPLIANCE TESTS (10 hours)

**Goal:** Enforce game rules and data integrity

#### Step 4.1: Create Compliance Checker Framework
**Description:** Build system to validate game rules
**Files to create:**
- `tests2/framework/compliance_checker.lua` - Compliance engine
- `tests2/compliance/init.lua` - Registration

**Compliance Rules:**
- Game balance (damage ranges, costs, health)
- Data persistence (save file integrity)
- Localization (all UI strings translated)
- Mod restrictions (content policy)
- Faction rules (reputation, allegiance)

**Estimated time:** 3 hours

#### Step 4.2: Implement Compliance Tests
**Description:** Create tests for game rules
**Files to create:**
- `tests2/compliance/game_balance_test.lua` (12 tests)
- `tests2/compliance/data_integrity_test.lua` (10 tests)
- `tests2/compliance/localization_compliance_test.lua` (8 tests)
- `tests2/compliance/mod_policy_test.lua` (6 tests)
- `tests2/compliance/faction_rules_test.lua` (8 tests)

**Sample Compliance Tests:**
1. Unit damage within 5-150 range
2. Save file passes checksum validation
3. All UI strings have translations
4. Mod content doesn't violate policies
5. Faction reputation stays in [-100, 100] range

**Total: 44 compliance tests**

**Estimated time:** 5 hours

#### Step 4.3: Compliance Reporting
**Description:** Report compliance violations
**Files to create:**
- `tests2/framework/compliance_reporter.lua`

**Estimated time:** 2 hours

---

### PHASE 5: SECURITY TESTS (12 hours)

**Goal:** Prevent exploits and unauthorized access

#### Step 5.1: Create Security Auditor Framework
**Description:** Build security testing infrastructure
**Files to create:**
- `tests2/framework/security_auditor.lua` - Security engine
- `tests2/security/init.lua` - Registration

**Security Categories:**
- Input validation (no buffer overflow)
- Data access control (auth checks)
- Serialization safety (no code injection)
- Save file integrity (tampering detection)
- API security (rate limiting, validation)

**Estimated time:** 4 hours

#### Step 5.2: Implement Security Tests
**Description:** Create security-focused tests
**Files to create:**
- `tests2/security/input_validation_test.lua` (12 tests)
- `tests2/security/access_control_test.lua` (10 tests)
- `tests2/security/save_file_integrity_test.lua` (8 tests)
- `tests2/security/mod_sandbox_test.lua` (8 tests)
- `tests2/security/api_security_test.lua` (6 tests)

**Sample Security Tests:**
1. Special characters don't crash string parsing
2. Admin-only commands require password
3. Save file modification detected
4. Mod can't access private engine APIs
5. API rate limiting works
6. SQL injection attempts are sanitized
7. XSS attempts in names are escaped
8. Mod can't read save files from other users

**Total: 44 security tests**

**Estimated time:** 7 hours

#### Step 5.3: Security Reporting & Remediation
**Description:** Report security issues with severity levels
**Files to create:**
- `tests2/framework/security_reporter.lua`

**Estimated time:** 1 hour

---

### PHASE 6: PROPERTY-BASED TESTS (14 hours)

**Goal:** Find edge cases through generative testing

#### Step 6.1: Create Property Generator Framework
**Description:** Build property-based testing infrastructure
**Files to create:**
- `tests2/framework/property_generator.lua` - Random data generation
- `tests2/framework/property_tester.lua` - Property validation engine
- `tests2/properties/init.lua` - Registration

**Generators:**
- Random valid game states
- Random map layouts
- Random unit configurations
- Random market prices
- Random faction alignments

**Properties to validate:**
- State invariants (no negative resources)
- Mathematical properties (hex distance properties)
- Ordering properties (sorted lists stay sorted)
- Idempotence (apply twice = apply once)

**Estimated time:** 5 hours

#### Step 6.2: Implement Property Tests
**Description:** Create property-based test suites
**Files to create:**
- `tests2/properties/battle_properties_test.lua` (15 tests)
- `tests2/properties/economy_properties_test.lua` (12 tests)
- `tests2/properties/procedural_generation_properties_test.lua` (10 tests)
- `tests2/properties/pathfinding_properties_test.lua` (8 tests)
- `tests2/properties/math_properties_test.lua` (10 tests)

**Sample Property Tests:**
1. For any two hex positions, distance is symmetric: dist(A,B) == dist(B,A)
2. For any generated map, pathfinding always terminates
3. For any random unit configuration, unit pool is valid
4. For any market operations, total resources conserved
5. For any faction state, reputation stays [-100, 100]
6. For any unit progression, stats increase monotonically
7. For any procedural map, no inaccessible areas

**Total: 55 property-based tests**

**Estimated time:** 7 hours

#### Step 6.3: Property Shrinking & Reporting
**Description:** Minimize failing test cases
**Files to create:**
- `tests2/framework/property_shrinker.lua` - Find minimal failing example
- `tests2/framework/property_reporter.lua` - Report findings

**Estimated time:** 2 hours

---

### PHASE 7: QUALITY GATE TESTS (10 hours)

**Goal:** Enforce code quality standards

#### Step 7.1: Create Quality Gate Checker
**Description:** Build automated quality enforcement
**Files to create:**
- `tests2/framework/quality_gate_checker.lua` - Quality engine
- `tests2/quality/init.lua` - Registration

**Quality Checks:**
- Code style (naming conventions)
- Test coverage (>70% per module)
- Documentation completeness
- Performance benchmarks
- API stability (no breaking changes)
- Deprecated API usage
- Comment quality

**Estimated time:** 3 hours

#### Step 7.2: Implement Quality Gate Tests
**Description:** Create quality validation tests
**Files to create:**
- `tests2/quality/code_style_test.lua` (8 tests)
- `tests2/quality/coverage_threshold_test.lua` (6 tests)
- `tests2/quality/documentation_test.lua` (6 tests)
- `tests2/quality/performance_benchmark_test.lua` (8 tests)
- `tests2/quality/api_stability_test.lua` (6 tests)

**Sample Quality Gate Tests:**
1. All functions start with lowercase/class_lowercase naming
2. Test coverage is >70% for core modules
3. All public functions have doc comments
4. No function takes >500ms to execute
5. Performance doesn't degrade >5% from baseline
6. No use of deprecated APIs
7. No unused variables
8. No commented-out code blocks

**Total: 34 quality gate tests**

**Estimated time:** 5 hours

#### Step 7.3: Quality Reporting & CI Integration
**Description:** Generate quality reports
**Files to create:**
- `tests2/framework/quality_reporter.lua`
- `tests2/reports/quality_report.md` (auto-generated)

**Estimated time:** 2 hours

---

### PHASE 8: FRAMEWORK EXTENSIONS & INTEGRATION (8 hours)

#### Step 8.1: Extend HierarchicalSuite
**Description:** Add support for new test types
**Files to modify:**
- `tests2/framework/hierarchical_suite.lua` - Add metadata support
- `tests2/framework/assertions.lua` - Add assertion types for each category
- `tests2/framework/hierarchy_reporter.lua` - Add category-specific reporting

**Features:**
- `type = "smoke" | "regression" | "api" | "compliance" | "security" | "property" | "quality"`
- Category-specific filtering
- Category-specific reporting
- Combined coverage analysis

**Estimated time:** 3 hours

#### Step 8.2: Create Master Test Runner
**Description:** Unified runner for all test types
**Files to create:**
- `tests2/runners/run_all_enhanced.lua` - Master runner
- `run_all_enhanced.bat` - Windows batch

**Runner modes:**
```bash
lovec tests2/runners run_all_enhanced                # All tests (all categories)
lovec tests2/runners run_all_enhanced quick          # Quick smoke subset
lovec tests2/runners run_all_enhanced pre_release    # Smoke + Regression + Quality
lovec tests2/runners run_all_enhanced full_audit     # Everything (full security/compliance)
lovec tests2/runners run_all_enhanced --report       # With HTML report
```

**Estimated time:** 3 hours

#### Step 8.3: VS Code Integration
**Description:** Add VS Code tasks for new test types
**Files to create:**
- Update `.vscode/tasks.json` with new tasks

**Tasks:**
- 🚬 SMOKE: Quick Tests (30 tests)
- 🔄 REGRESSION: Historical Bug Tests
- 📋 API: Contract Validation Tests
- ✅ COMPLIANCE: Rules & Balance Tests
- 🔒 SECURITY: Security Audit Tests
- 🎲 PROPERTY: Edge Case Tests
- ⭐ QUALITY: Code Quality Tests
- 🏆 FULL SUITE: All Enhanced Tests

**Estimated time:** 2 hours

---

### PHASE 9: DOCUMENTATION (6 hours)

#### Step 9.1: Framework Documentation
**Description:** Document new frameworks and APIs
**Files to create:**
- `tests2/smoke/README.md`
- `tests2/regression/README.md`
- `tests2/api/README.md`
- `tests2/compliance/README.md`
- `tests2/security/README.md`
- `tests2/properties/README.md`
- `tests2/quality/README.md`

**Content per file:**
1. Overview and purpose
2. How to run tests
3. How to write tests (examples)
4. Key assertions/helpers
5. Common patterns
6. Troubleshooting

**Estimated time:** 3 hours

#### Step 9.2: Main Test Suite Documentation
**Description:** Update comprehensive documentation
**Files to modify:**
- `tests2/README.md` - Add sections for each test type
- `tests2/framework/README.md` - Document framework extensions
- `tests2/utils/test_helpers.lua` - Document new assertions

**Sections:**
- Test Type Guide (choose which type to write)
- Running Specific Test Categories
- Test Type Selection Matrix
- Performance Characteristics
- CI/CD Integration

**Estimated time:** 2 hours

#### Step 9.3: Developer Guide
**Description:** Create guide for writing tests
**Files to create:**
- `docs/TESTING_GUIDE_ENHANCED.md` - Complete testing guide

**Content:**
1. Test hierarchy (choose category)
2. Test type selection flowchart
3. Writing each test type (7 examples)
4. Best practices
5. Common mistakes
6. Performance tips
7. Security considerations

**Estimated time:** 1 hour

---

### PHASE 10: TESTING & VALIDATION (10 hours)

#### Step 10.1: Validate All New Tests Pass
**Description:** Ensure no test failures in new suite
**Tasks:**
- [ ] Run all smoke tests - expect 0 failures
- [ ] Run all regression tests - expect 0 failures
- [ ] Run all API tests - expect 0 failures
- [ ] Run all compliance tests - expect 0 failures
- [ ] Run all security tests - expect 0 failures
- [ ] Run all property tests - expect 0 failures (may need shrinking)
- [ ] Run all quality tests - expect 0 failures
- [ ] Run full suite - expect 0 failures

**Estimated time:** 3 hours

#### Step 10.2: Validate Performance
**Description:** Ensure test performance targets
**Performance Targets:**
- Smoke tests: <500ms
- Regression tests: <2 seconds
- API tests: <1 second
- Compliance tests: <2 seconds
- Security tests: <2 seconds
- Property tests: <5 seconds (with 100 iterations per property)
- Quality tests: <1 second
- Full suite: <15 seconds

**Estimated time:** 3 hours

#### Step 10.3: Integration Testing
**Description:** Test new runners and VS Code tasks
**Tasks:**
- [ ] Run `run_smoke.bat` - verify output
- [ ] Run `run_regressions.bat` - verify output
- [ ] Run all VS Code tasks - verify they work
- [ ] Test report generation - verify formats
- [ ] Test CI/CD integration - verify automation

**Estimated time:** 2 hours

#### Step 10.4: Documentation Review
**Description:** Verify all documentation is complete and accurate
**Tasks:**
- [ ] Review all README files
- [ ] Review code comments
- [ ] Verify code examples run
- [ ] Check for typos and clarity
- [ ] Verify screenshots/diagrams if any

**Estimated time:** 2 hours

---

## Implementation Details

### Architecture

#### Test Type Hierarchy
```
HierarchicalSuite (base)
├── Smoke Tests (fast validation)
├── Regression Tests (bug prevention)
├── API Contract Tests (interface validation)
├── Compliance Tests (rule enforcement)
├── Security Tests (protection validation)
├── Property Tests (invariant checking)
└── Quality Gate Tests (standards enforcement)
```

#### Framework Structure
```
tests2/framework/
├── hierarchical_suite.lua (extended)
├── assertions.lua (extended)
├── hierarchy_reporter.lua (extended)
├── smoke_tester.lua (new)
├── regression_tracker.lua (new)
├── api_contract_validator.lua (new)
├── compliance_checker.lua (new)
├── security_auditor.lua (new)
├── property_generator.lua (new)
├── quality_gate_checker.lua (new)
└── ...
```

#### Test Organization
```
tests2/
├── smoke/
│   ├── init.lua
│   ├── core_systems_smoke_test.lua
│   ├── gameplay_loop_smoke_test.lua
│   ├── asset_loading_smoke_test.lua
│   ├── persistence_smoke_test.lua
│   ├── ui_smoke_test.lua
│   └── README.md
├── regression/
│   ├── init.lua
│   ├── database.lua
│   ├── battlescape_regressions_test.lua
│   ├── geoscape_regressions_test.lua
│   ├── basescape_regressions_test.lua
│   ├── economy_regressions_test.lua
│   ├── save_load_regressions_test.lua
│   └── README.md
├── api/
│   ├── init.lua
│   ├── units_api_test.lua
│   ├── weapons_api_test.lua
│   ├── facilities_api_test.lua
│   ├── crafts_api_test.lua
│   ├── mod_api_test.lua
│   ├── backward_compatibility_test.lua
│   └── README.md
├── compliance/
│   ├── init.lua
│   ├── game_balance_test.lua
│   ├── data_integrity_test.lua
│   ├── localization_compliance_test.lua
│   ├── mod_policy_test.lua
│   ├── faction_rules_test.lua
│   └── README.md
├── security/
│   ├── init.lua
│   ├── input_validation_test.lua
│   ├── access_control_test.lua
│   ├── save_file_integrity_test.lua
│   ├── mod_sandbox_test.lua
│   ├── api_security_test.lua
│   └── README.md
├── properties/
│   ├── init.lua
│   ├── battle_properties_test.lua
│   ├── economy_properties_test.lua
│   ├── procedural_generation_properties_test.lua
│   ├── pathfinding_properties_test.lua
│   ├── math_properties_test.lua
│   └── README.md
├── quality/
│   ├── init.lua
│   ├── code_style_test.lua
│   ├── coverage_threshold_test.lua
│   ├── documentation_test.lua
│   ├── performance_benchmark_test.lua
│   ├── api_stability_test.lua
│   └── README.md
└── ...
```

### Key Components

**1. Test Type System**
- Each test marked with `type = "smoke" | "regression" | "api" | "compliance" | "security" | "property" | "quality"`
- Runners filter by type
- Reporters generate type-specific output

**2. Regression Database**
- Tracks known bugs
- Links to commits/issues
- Auto-creates test cases
- Prevents re-introduction

**3. Property Generator**
- Creates random valid game states
- Validates invariants
- Shrinks failing cases
- Reports minimal examples

**4. Security Auditor**
- Input fuzzing
- Access control checks
- Serialization safety
- Tampering detection

**5. Quality Gate Enforcer**
- Code style checking
- Coverage tracking
- Performance monitoring
- API stability checking

### Dependencies

**Framework:**
- HierarchicalSuite (already exists)
- Lua 5.1+ (already available)
- Love2D 12.0+ (already available)

**External:**
- None (self-contained)

**Internal:**
- `tests2/framework/hierarchical_suite.lua`
- `tests2/utils/test_helpers.lua`
- `engine/` modules for testing

---

## Testing Strategy

### Unit Tests (Per Category)

**Smoke Tests (22 total):**
- Core systems init (5)
- Gameplay loop (6)
- Asset loading (4)
- Persistence (4)
- UI interaction (3)

**Regression Tests (38 total):**
- Battlescape (10)
- Geoscape (8)
- Basescape (8)
- Economy (6)
- Save/load (6)

**API Contract Tests (45 total):**
- Units API (8)
- Weapons API (6)
- Facilities API (7)
- Crafts API (6)
- Mod API (10)
- Backward compatibility (8)

**Compliance Tests (44 total):**
- Game balance (12)
- Data integrity (10)
- Localization (8)
- Mod policy (6)
- Faction rules (8)

**Security Tests (44 total):**
- Input validation (12)
- Access control (10)
- Save integrity (8)
- Mod sandbox (8)
- API security (6)

**Property Tests (55 total):**
- Battle properties (15)
- Economy properties (12)
- Procedural generation (10)
- Pathfinding (8)
- Math properties (10)

**Quality Gate Tests (34 total):**
- Code style (8)
- Coverage thresholds (6)
- Documentation (6)
- Performance (8)
- API stability (6)

### Integration Tests

- Run all categories together
- Validate no conflicts
- Verify reporting works
- Check performance budget

### Manual Testing Steps

1. Run `lovec tests2/runners run_smoke` → All 22 smoke tests pass
2. Run `lovec tests2/runners run_regressions` → All 38 regression tests pass
3. Run `lovec tests2/runners run_api_contracts` → All 45 API tests pass
4. Run `lovec tests2/runners run_compliance` → All 44 compliance tests pass
5. Run `lovec tests2/runners run_security` → All 44 security tests pass
6. Run `lovec tests2/runners run_properties` → All 55 property tests pass
7. Run `lovec tests2/runners run_quality` → All 34 quality tests pass
8. Run `lovec tests2/runners run_all_enhanced` → All 282 tests pass (2,493 + 282 = 2,775 total)
9. Verify each VS Code task works
10. Verify batch files work
11. Verify reports generate

### Expected Results

**Test Counts:**
- Smoke: 22 tests (1 test per group)
- Regression: 38 tests (1-2 per bug category)
- API: 45 tests (API validation)
- Compliance: 44 tests (Rule validation)
- Security: 44 tests (Security validation)
- Property: 55 tests (Invariant testing)
- Quality: 34 tests (Standard enforcement)
- **New Total: 282 tests**
- **Grand Total: 2,775 tests (2,493 existing + 282 new)**

**Pass Rates:**
- All categories: 100% pass rate
- No test failures
- No flaky tests

**Performance:**
- Smoke: <500ms
- Regression: <2s
- API: <1s
- Compliance: <2s
- Security: <2s
- Property: <5s
- Quality: <1s
- Full suite: <15s

**Coverage:**
- Functional: 3,003+ instances
- Regression: 38+ instances (new)
- API: 45+ instances (new)
- Compliance: 44+ instances (new)
- Security: 44+ instances (new)
- Property: 55+ instances (new)
- Quality: 34+ instances (new)
- **Total: 3,263+ test instances**

---

## How to Run/Debug

### Running the Enhanced Test Suite

**Quick Smoke Tests (500ms):**
```bash
lovec "tests2/runners" run_smoke
# or
run_smoke.bat
```

**Regression Tests:**
```bash
lovec "tests2/runners" run_regressions
# or
run_regressions.bat
```

**All Enhanced Tests:**
```bash
lovec "tests2/runners" run_all_enhanced
# or
run_all_enhanced.bat
```

**Quick Mode (pre-release):**
```bash
lovec "tests2/runners" run_all_enhanced quick
# Runs: Smoke + Regression + Quality (50 tests, ~3s)
```

**Full Audit Mode:**
```bash
lovec "tests2/runners" run_all_enhanced full_audit
# Runs: All 282 tests + reports (~15s)
```

**With Reports:**
```bash
lovec "tests2/runners" run_all_enhanced --report
# Generates HTML report in tests2/reports/
```

### VS Code Tasks

From Command Palette (Ctrl+Shift+P):
- `Tasks: Run Task` → Select any of:
  - 🚬 SMOKE: Quick Tests
  - 🔄 REGRESSION: Historical Bug Tests
  - 📋 API: Contract Validation
  - ✅ COMPLIANCE: Rules & Balance
  - 🔒 SECURITY: Security Audit
  - 🎲 PROPERTY: Edge Cases
  - ⭐ QUALITY: Code Quality
  - 🏆 FULL SUITE: All Enhanced

### Debugging New Tests

**Enable Debug Output:**
```lua
local Suite = require("tests2.framework.hierarchical_suite")

Suite:group("My Tests", function()
  Suite:testMethod("Test:method", {
    type = "smoke",  -- Add this
    testCase = "debug"
  }, function()
    print("[DEBUG] Starting test")
    assert(true)
    print("[DEBUG] Test passed")
  end)
end)
```

**Run Single Test File:**
```bash
lovec "tests2/runners" run_single_test smoke/core_systems_smoke_test
```

**Check Console Output:**
- Love2D console is enabled in `conf.lua`
- All test output goes to console
- Errors appear with stack traces

### Performance Profiling

**Measure Test Execution:**
```lua
local Helpers = require("tests2.utils.test_helpers")

local timer = Helpers.measureTime(function()
  -- test code
end, 100)  -- Run 100 times

print("Average: " .. timer.average .. "ms")
```

---

## Documentation Updates

### Files to Create/Update

- [ ] `tests2/smoke/README.md` - Smoke test guide
- [ ] `tests2/regression/README.md` - Regression test guide
- [ ] `tests2/api/README.md` - API test guide
- [ ] `tests2/compliance/README.md` - Compliance test guide
- [ ] `tests2/security/README.md` - Security test guide
- [ ] `tests2/properties/README.md` - Property test guide
- [ ] `tests2/quality/README.md` - Quality test guide
- [ ] `tests2/framework/README.md` - Framework extensions
- [ ] `tests2/README.md` - Main test guide (update with all categories)
- [ ] `docs/TESTING_GUIDE_ENHANCED.md` - Complete testing guide
- [ ] `docs/SECURITY_TESTING.md` - Security testing guide
- [ ] `docs/TEST_STRATEGY.md` - Overall test strategy

### Documentation Standard

Each README should include:
1. **Overview** - Purpose and scope
2. **Quick Start** - How to run tests
3. **Writing Tests** - Code examples
4. **Assertions** - Available assertions
5. **Helpers** - Utility functions
6. **Best Practices** - Common patterns
7. **Troubleshooting** - Common issues
8. **Examples** - Real test examples

---

## Notes

### Key Design Decisions

1. **Backward Compatible** - All existing tests continue to work unchanged
2. **Modular** - Each test category is independent
3. **Fast Feedback** - Smoke tests run in <500ms for quick validation
4. **Progressive** - Phases can be implemented independently
5. **Scalable** - Framework supports unlimited new test types

### Risk Mitigation

1. **Performance** - Property tests use configurable iteration counts
2. **Flakiness** - All tests deterministic (no time-based or random)
3. **Maintenance** - Clear separation of concerns
4. **Documentation** - Every test type has examples

### Future Enhancements

1. **Coverage Reports** - Generate SonarQube/Codecov reports
2. **Historical Tracking** - Track test metrics over time
3. **Mutation Testing** - Verify test quality
4. **AI-Generated Tests** - Auto-generate test cases
5. **Performance Benchmarking** - Track performance over commits

---

## Blockers

**None initially, but:**
- API schema must be finalized before API contract tests
- Security requirements must be documented before security tests
- Compliance rules must be documented before compliance tests

---

## Review Checklist

- [ ] All 7 test categories implemented
- [ ] Framework properly integrated with HierarchicalSuite
- [ ] No breaking changes to existing tests
- [ ] All new tests pass (282/282)
- [ ] Performance targets met
- [ ] Documentation complete
- [ ] VS Code tasks working
- [ ] Batch files created
- [ ] CI/CD ready
- [ ] Code reviewed
- [ ] No console warnings

---

## Post-Completion

### Success Metrics

- **Coverage:** 2,775 total tests (282 new test instances)
- **Execution:** <15 seconds full suite
- **Pass Rate:** 100% (all tests passing)
- **Regressions:** 0 test failures
- **Documentation:** 8 category guides + main guide

### What Worked Well

- [ ] TBD after implementation

### What Could Be Improved

- [ ] TBD after implementation

### Lessons Learned

- [ ] TBD after implementation

---

## Timeline Summary

| Phase | Duration | Total Hours |
|-------|----------|-------------|
| 1: Smoke Tests | 15h | 15h |
| 2: Regression Tests | 12h | 27h |
| 3: API Contract Tests | 10h | 37h |
| 4: Compliance Tests | 10h | 47h |
| 5: Security Tests | 12h | 59h |
| 6: Property Tests | 14h | 73h |
| 7: Quality Gate Tests | 10h | 83h |
| 8: Framework Integration | 8h | 91h |
| 9: Documentation | 6h | 97h |
| 10: Testing & Validation | 10h | 107h |
| **TOTAL** | **107 hours** | **107h** |

---

## References

### Test Type Definitions

- **Smoke Tests:** Quick validation that system starts and basic functionality works
- **Regression Tests:** Verify fixed bugs don't reappear
- **API Contract Tests:** Ensure interfaces match documented contracts
- **Compliance Tests:** Validate adherence to rules and specifications
- **Security Tests:** Prevent exploits, unauthorized access, data breaches
- **Property-Based Tests:** Verify mathematical and logical invariants hold
- **Quality Gate Tests:** Enforce code quality and standards

### Related Documentation

- `tests2/README.md` - Test suite overview
- `tests2/framework/hierarchical_suite.lua` - Framework source
- `api/GAME_API.toml` - Game API schema
- `api/MODDING_GUIDE.md` - Modding API documentation

---

**Task Created:** October 27, 2025
**Status:** TODO
**Next Step:** Phase 1 - Smoke Tests Implementation
