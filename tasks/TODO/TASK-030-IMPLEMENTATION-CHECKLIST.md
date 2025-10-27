# Test Suite Enhancement - Implementation Checklist

**Document:** Phase-by-phase implementation checklist
**Created:** October 27, 2025
**Total Tasks:** 350+ checkboxes
**Effort:** 107 hours

---

## PHASE 1: SMOKE TESTS (15 hours)

### 1.1 Framework & Infrastructure (5 hours)

#### Create Test Framework
- [ ] Create `tests2/smoke/init.lua` with test registration
- [ ] Create `tests2/smoke/README.md` with documentation
- [ ] Add smoke test type support to HierarchicalSuite
- [ ] Update `tests2/framework/hierarchy_reporter.lua` for smoke tests
- [ ] Create smoke test helpers in `tests2/utils/test_helpers.lua`

#### Update HierarchicalSuite
- [ ] Add `type = "smoke"` support
- [ ] Add smoke test filtering to runners
- [ ] Add smoke test section to reporting
- [ ] Add performance tracking for smoke tests

### 1.2 Core System Smoke Tests (3 hours)

#### File: `tests2/smoke/core_systems_smoke_test.lua`

- [ ] Test 1.1: StateManager initializes
  - [ ] Create suite
  - [ ] Implement test
  - [ ] Verify passes

- [ ] Test 1.2: Core modules load
  - [ ] Implement test
  - [ ] Mock required modules
  - [ ] Verify passes

- [ ] Test 1.3: State transitions work
  - [ ] Implement test
  - [ ] Test state changes
  - [ ] Verify passes

- [ ] Test 1.4: Error handling works
  - [ ] Implement test
  - [ ] Test error catches
  - [ ] Verify passes

- [ ] Test 1.5: Module dependencies resolve
  - [ ] Implement test
  - [ ] Check all requires work
  - [ ] Verify passes

### 1.3 Gameplay Loop Smoke Tests (2 hours)

#### File: `tests2/smoke/gameplay_loop_smoke_test.lua`

- [ ] Test 2.1: Geoscape loads
- [ ] Test 2.2: Battlescape loads
- [ ] Test 2.3: Return to geoscape works
- [ ] Test 2.4: Campaign starts
- [ ] Test 2.5: Turn completion works
- [ ] Test 2.6: Game saves state

### 1.4 Asset Loading Smoke Tests (2 hours)

#### File: `tests2/smoke/asset_loading_smoke_test.lua`

- [ ] Test 3.1: All sprites load (no missing files)
- [ ] Test 3.2: All audio files load
- [ ] Test 3.3: UI assets available
- [ ] Test 3.4: No "file not found" errors

### 1.5 Persistence Smoke Tests (2 hours)

#### File: `tests2/smoke/persistence_smoke_test.lua`

- [ ] Test 4.1: Save game creates file
- [ ] Test 4.2: Load game reads file
- [ ] Test 4.3: State matches after load
- [ ] Test 4.4: Multiple save slots work

### 1.6 UI Smoke Tests (1 hour)

#### File: `tests2/smoke/ui_smoke_test.lua`

- [ ] Test 5.1: Main menu renders
- [ ] Test 5.2: Buttons respond to clicks
- [ ] Test 5.3: No layout errors

### 1.7 Smoke Test Runner (1 hour)

#### Create: `tests2/runners/run_smoke.lua`

- [ ] Create master smoke runner
- [ ] Add filtering logic
- [ ] Add performance reporting
- [ ] Test runner works

#### Create: `run_smoke.bat`

- [ ] Create Windows batch file
- [ ] Test batch execution

#### Update: `tests2/main.lua`

- [ ] Add smoke test routing
- [ ] Verify routing works

### 1.8 Documentation (1 hour)

- [ ] Write `tests2/smoke/README.md`
  - [ ] Overview
  - [ ] How to run
  - [ ] How to write
  - [ ] Examples
  - [ ] Troubleshooting

- [ ] Update `tests2/README.md`
  - [ ] Add smoke test section
  - [ ] Add smoke test commands
  - [ ] Add links to guide

### 1.9 Testing & Validation (1 hour)

- [ ] Run all smoke tests: `lovec "tests2/runners" run_smoke`
  - [ ] Expect: 22/22 tests pass
  - [ ] Expect: <500ms execution
  - [ ] Verify: No errors

- [ ] Run batch file: `run_smoke.bat`
  - [ ] Verify: Output correct
  - [ ] Verify: Returns exit code 0

- [ ] Verify console output
  - [ ] All tests visible
  - [ ] Timing accurate
  - [ ] No warnings

**Phase 1 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 2: REGRESSION TESTS (12 hours)

### 2.1 Regression Framework (4 hours)

#### Create: `tests2/regression/database.lua`

- [ ] Create regression database structure
- [ ] Implement bug entry system
- [ ] Add bug query functions
- [ ] Add tag/category support
- [ ] Document database format

#### Create: `tests2/regression/bug_tracker.lua`

- [ ] Implement bug tracker
- [ ] Add severity levels (critical, high, medium, low)
- [ ] Add status tracking (fixed, regressed, pending)
- [ ] Link to commits/issues
- [ ] Auto-generate test cases from bugs

#### Create: `tests2/regression/init.lua`

- [ ] Register regression tests
- [ ] Load database
- [ ] Initialize test suite

#### Create: `tests2/regression/README.md`

- [ ] Write comprehensive guide
- [ ] Document database schema
- [ ] Provide examples
- [ ] Link to bug database

### 2.2 Battlescape Regression Tests (2 hours)

#### File: `tests2/regression/battlescape_regressions_test.lua`

- [ ] Test 1: Units don't fall through floor
- [ ] Test 2: UFO interception doesn't crash
- [ ] Test 3: LOS/FOW calculations correct
- [ ] Test 4: Squad formation valid
- [ ] Test 5: Pathfinding always terminates
- [ ] Test 6: Weapon accuracy bounded [0, 100]
- [ ] Test 7: Damage calculations non-negative
- [ ] Test 8: Tactical objectives clear
- [ ] Test 9: Environmental effects apply
- [ ] Test 10: Combat log records all actions

### 2.3 Geoscape Regression Tests (1.5 hours)

#### File: `tests2/regression/geoscape_regressions_test.lua`

- [ ] Test 1: UFO tracking accurate
- [ ] Test 2: Mission generation valid
- [ ] Test 3: Campaign progression works
- [ ] Test 4: World state consistent
- [ ] Test 5: Craft interception works
- [ ] Test 6: Terror level updates
- [ ] Test 7: Faction relations valid
- [ ] Test 8: Portal system stable

### 2.4 Basescape Regression Tests (1.5 hours)

#### File: `tests2/regression/basescape_regressions_test.lua`

- [ ] Test 1: Facility construction works
- [ ] Test 2: Storage doesn't overflow
- [ ] Test 3: Craft inventory accurate
- [ ] Test 4: Research queue valid
- [ ] Test 5: Manufacturing completes
- [ ] Test 6: Staff assignment works
- [ ] Test 7: Base defense activates
- [ ] Test 8: Personnel stats valid

### 2.5 Economy Regression Tests (1 hour)

#### File: `tests2/regression/economy_regressions_test.lua`

- [ ] Test 1: Market prices non-negative
- [ ] Test 2: Resource totals conserved
- [ ] Test 3: Income calculations accurate
- [ ] Test 4: Expense tracking works
- [ ] Test 5: Trading completes
- [ ] Test 6: Financial reports accurate

### 2.6 Save/Load Regression Tests (1 hour)

#### File: `tests2/regression/save_load_regressions_test.lua`

- [ ] Test 1: Save file doesn't corrupt
- [ ] Test 2: Load restores state exactly
- [ ] Test 3: Multiple save slots work
- [ ] Test 4: Save/load on rapid succession
- [ ] Test 5: Checksum validates integrity
- [ ] Test 6: Version compatibility checked

### 2.7 Regression Test Runner (1 hour)

#### Create: `tests2/runners/run_regressions.lua`

- [ ] Create regression runner
- [ ] Load database
- [ ] Execute all regression tests
- [ ] Report results
- [ ] Track regressed bugs

#### Create: `run_regressions.bat`

- [ ] Windows batch file
- [ ] Test execution

#### Update: `tests2/main.lua`

- [ ] Add regression routing

### 2.8 Documentation (1 hour)

- [ ] Document regression tests
- [ ] Provide bug database examples
- [ ] Create regression test guide

### 2.9 Testing & Validation (1 hour)

- [ ] Run regressions: `lovec "tests2/runners" run_regressions`
  - [ ] Expect: 38/38 pass
  - [ ] Expect: <2s execution

- [ ] Run batch: `run_regressions.bat`

- [ ] Verify all subsystems covered

**Phase 2 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 3: API CONTRACT TESTS (10 hours)

### 3.1 API Validator Framework (3 hours)

#### Create: `tests2/framework/api_contract_validator.lua`

- [ ] Implement schema validator
- [ ] Add type checking
- [ ] Add required field validation
- [ ] Add enum validation
- [ ] Add range validation
- [ ] Add backward compatibility checking

#### Create: `tests2/framework/schema_validator.lua`

- [ ] Load GAME_API.toml schema
- [ ] Validate against schema
- [ ] Generate validation errors
- [ ] Suggest fixes

#### Create: `tests2/api/init.lua`

- [ ] Register API tests

### 3.2 Units API Tests (1 hour)

#### File: `tests2/api/units_api_test.lua`

- [ ] Test 1: Unit schema validates
- [ ] Test 2: Required fields present
- [ ] Test 3: Stats in valid ranges
- [ ] Test 4: Equipment references valid
- [ ] Test 5: Rank progression valid
- [ ] Test 6: Special abilities defined
- [ ] Test 7: Armor types valid
- [ ] Test 8: Health non-negative

### 3.3 Weapons API Tests (1 hour)

#### File: `tests2/api/weapons_api_test.lua`

- [ ] Test 1: Weapon schema valid
- [ ] Test 2: Damage type enum valid
- [ ] Test 3: Accuracy in [0, 100]
- [ ] Test 4: Range non-negative
- [ ] Test 5: Magazine size positive
- [ ] Test 6: Cost non-negative

### 3.4 Facilities API Tests (1 hour)

#### File: `tests2/api/facilities_api_test.lua`

- [ ] Test 1: Facility schema valid
- [ ] Test 2: Construction cost positive
- [ ] Test 3: Maintenance cost valid
- [ ] Test 4: Capacity non-negative
- [ ] Test 5: Storage dimensions valid
- [ ] Test 6: Prerequisites satisfied
- [ ] Test 7: Effects defined

### 3.5 Crafts API Tests (1 hour)

#### File: `tests2/api/crafts_api_test.lua`

- [ ] Test 1: Craft schema valid
- [ ] Test 2: Capacity non-negative
- [ ] Test 3: Speed range valid
- [ ] Test 4: Fuel consumption valid
- [ ] Test 5: Equipment slot counts valid
- [ ] Test 6: Weapons compatible

### 3.6 Mod API Tests (1 hour)

#### File: `tests2/api/mod_api_test.lua`

- [ ] Test 1: Mod manifest valid
- [ ] Test 2: Required fields present
- [ ] Test 3: Version format valid
- [ ] Test 4: Dependencies satisfiable
- [ ] Test 5: Content types recognized
- [ ] Test 6: Data refs valid
- [ ] Test 7: Hooks registered
- [ ] Test 8: Permissions defined
- [ ] Test 9: License specified
- [ ] Test 10: Metadata complete

### 3.7 Backward Compatibility Tests (0.5 hours)

#### File: `tests2/api/backward_compatibility_test.lua`

- [ ] Test 1: Old unit format loads
- [ ] Test 2: Old weapon stats convert
- [ ] Test 3: Old mod format works
- [ ] Test 4: Version fallback works
- [ ] Test 5: Migration functions work
- [ ] Test 6: No data loss on upgrade
- [ ] Test 7: Deprecated APIs work
- [ ] Test 8: Warnings issued

### 3.8 API Test Runner (0.5 hours)

#### Create: `tests2/runners/run_api_tests.lua`

- [ ] Create API test runner
- [ ] Test each API category
- [ ] Report contract violations

#### Update: `tests2/main.lua`

- [ ] Add API routing

### 3.9 Documentation (1 hour)

- [ ] Create `tests2/api/README.md`
- [ ] Document schema requirements
- [ ] Provide API test examples

### 3.10 Testing & Validation (0.5 hours)

- [ ] Run API tests: `lovec "tests2/runners" run_single_test api`
  - [ ] Expect: 45/45 pass
  - [ ] Expect: <1s execution

**Phase 3 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 4: COMPLIANCE TESTS (10 hours)

### 4.1 Compliance Checker Framework (3 hours)

#### Create: `tests2/framework/compliance_checker.lua`

- [ ] Implement compliance engine
- [ ] Add rule validation
- [ ] Add data integrity checking
- [ ] Add policy enforcement
- [ ] Add reporting

#### Create: `tests2/compliance/init.lua`

- [ ] Register compliance tests

### 4.2 Game Balance Tests (2 hours)

#### File: `tests2/compliance/game_balance_test.lua`

- [ ] Test 1: Unit damage in [5, 150]
- [ ] Test 2: Unit health in [10, 500]
- [ ] Test 3: Unit TU in [0, 100]
- [ ] Test 4: Weapon damage in [1, 100]
- [ ] Test 5: Weapon accuracy in [0, 100]
- [ ] Test 6: Armor protection in [0, 50]
- [ ] Test 7: Research cost positive
- [ ] Test 8: Manufacturing cost positive
- [ ] Test 9: Facility cost positive
- [ ] Test 10: Market prices reasonable
- [ ] Test 11: Salary ranges valid
- [ ] Test 12: Terror increases bounded

### 4.3 Data Integrity Tests (1.5 hours)

#### File: `tests2/compliance/data_integrity_test.lua`

- [ ] Test 1: Save file checksum valid
- [ ] Test 2: All data typed correctly
- [ ] Test 3: No nil values in critical fields
- [ ] Test 4: IDs are unique
- [ ] Test 5: Foreign keys valid
- [ ] Test 6: Timestamps consistent
- [ ] Test 7: Enum values valid
- [ ] Test 8: No circular references
- [ ] Test 9: Serialization reversible
- [ ] Test 10: Compression integrity

### 4.4 Localization Tests (1 hour)

#### File: `tests2/compliance/localization_compliance_test.lua`

- [ ] Test 1: All UI strings have keys
- [ ] Test 2: All strings translated (EN)
- [ ] Test 3: All strings translated (Other langs)
- [ ] Test 4: No hardcoded text
- [ ] Test 5: String parameters match
- [ ] Test 6: No truncation in UI
- [ ] Test 7: RTL languages work
- [ ] Test 8: Special characters render

### 4.5 Mod Policy Tests (1 hour)

#### File: `tests2/compliance/mod_policy_test.lua`

- [ ] Test 1: No adult content
- [ ] Test 2: No hate speech
- [ ] Test 3: No copyright violations
- [ ] Test 4: License specified
- [ ] Test 5: Creator attributed
- [ ] Test 6: Compatibility noted

### 4.6 Faction Rules Tests (1 hour)

#### File: `tests2/compliance/faction_rules_test.lua`

- [ ] Test 1: Reputation in [-100, 100]
- [ ] Test 2: Allegiance valid
- [ ] Test 3: Relations consistent
- [ ] Test 4: Faction diplomacy valid
- [ ] Test 5: Faction warfare rules work
- [ ] Test 6: Faction events valid
- [ ] Test 7: Faction perks valid
- [ ] Test 8: Faction restrictions enforced

### 4.7 Documentation (0.5 hours)

- [ ] Create `tests2/compliance/README.md`

### 4.8 Testing & Validation (0.5 hours)

- [ ] Run compliance tests
  - [ ] Expect: 44/44 pass
  - [ ] Expect: <2s execution

**Phase 4 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 5: SECURITY TESTS (12 hours)

### 5.1 Security Framework (3 hours)

#### Create: `tests2/framework/security_auditor.lua`

- [ ] Implement security auditor
- [ ] Add input validation testing
- [ ] Add access control testing
- [ ] Add tampering detection
- [ ] Add sandbox enforcement

#### Create: `tests2/security/init.lua`

- [ ] Register security tests

### 5.2 Input Validation Tests (2 hours)

#### File: `tests2/security/input_validation_test.lua`

- [ ] Test 1: Special chars don't crash
- [ ] Test 2: Long strings bounded
- [ ] Test 3: SQL injection blocked
- [ ] Test 4: Script injection blocked
- [ ] Test 5: Path traversal blocked
- [ ] Test 6: Format string safe
- [ ] Test 7: Buffer overflow impossible
- [ ] Test 8: Null bytes handled
- [ ] Test 9: Unicode attacks blocked
- [ ] Test 10: Regex DoS prevented
- [ ] Test 11: Type coercion safe
- [ ] Test 12: Number range checked

### 5.3 Access Control Tests (1.5 hours)

#### File: `tests2/security/access_control_test.lua`

- [ ] Test 1: Admin commands require auth
- [ ] Test 2: User can't access admin area
- [ ] Test 3: Mod can't access private APIs
- [ ] Test 4: Cheats require password
- [ ] Test 5: Save file permissions correct
- [ ] Test 6: Config file protected
- [ ] Test 7: Debug mode requires flag
- [ ] Test 8: API keys validated
- [ ] Test 9: CORS headers correct
- [ ] Test 10: Token validation works

### 5.4 Save File Integrity Tests (1 hour)

#### File: `tests2/security/save_file_integrity_test.lua`

- [ ] Test 1: Checksum detects modification
- [ ] Test 2: Signature validates origin
- [ ] Test 3: Version checked
- [ ] Test 4: Timestamp verified
- [ ] Test 5: No tampering possible
- [ ] Test 6: Encryption works
- [ ] Test 7: Decryption authenticated
- [ ] Test 8: Salt prevents dict attacks

### 5.5 Mod Sandbox Tests (1 hour)

#### File: `tests2/security/mod_sandbox_test.lua`

- [ ] Test 1: Mod can't access file system
- [ ] Test 2: Mod can't access network
- [ ] Test 3: Mod can't call OS functions
- [ ] Test 4: Mod can't modify engine
- [ ] Test 5: Mod can't read other saves
- [ ] Test 6: Mod can't access private data
- [ ] Test 7: Mod memory isolated
- [ ] Test 8: Mod permissions enforced

### 5.6 API Security Tests (1 hour)

#### File: `tests2/security/api_security_test.lua`

- [ ] Test 1: Rate limiting works
- [ ] Test 2: DDoS prevention active
- [ ] Test 3: API keys required
- [ ] Test 4: Input validated
- [ ] Test 5: Output sanitized
- [ ] Test 6: Error messages safe
- [ ] Test 7: Timeout enforced

### 5.7 Documentation (0.5 hours)

- [ ] Create `tests2/security/README.md`

### 5.8 Testing & Validation (1 hour)

- [ ] Run security tests
  - [ ] Expect: 44/44 pass
  - [ ] Expect: <2s execution

**Phase 5 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 6: PROPERTY-BASED TESTS (14 hours)

### 6.1 Property Framework (4 hours)

#### Create: `tests2/framework/property_generator.lua`

- [ ] Random game state generator
- [ ] Random map generator
- [ ] Random unit generator
- [ ] Random market generator
- [ ] Random faction generator
- [ ] Constraint validation

#### Create: `tests2/framework/property_tester.lua`

- [ ] Property validator
- [ ] Invariant checker
- [ ] Statistics tracking
- [ ] Shrinking engine

#### Create: `tests2/properties/init.lua`

- [ ] Register property tests

### 6.2 Battle Properties (2 hours)

#### File: `tests2/properties/battle_properties_test.lua`

- [ ] Property 1: Distance symmetric
- [ ] Property 2: Pathfinding terminates
- [ ] Property 3: Valid unit pool always
- [ ] Property 4: Health never negative
- [ ] Property 5: Ammo always valid
- [ ] Property 6: Accuracy bounded
- [ ] Property 7: Damage non-negative
- [ ] Property 8: Turn order deterministic
- [ ] Property 9: LOS consistent
- [ ] Property 10: Cover always valid
- [ ] Property 11: Targeting always valid
- [ ] Property 12: Squad formation valid
- [ ] Property 13: Morale bounded
- [ ] Property 14: Wounds traceable
- [ ] Property 15: Equipment always valid

### 6.3 Economy Properties (2 hours)

#### File: `tests2/properties/economy_properties_test.lua`

- [ ] Property 1: Resources conserved
- [ ] Property 2: Prices non-negative
- [ ] Property 3: Market balanced
- [ ] Property 4: Production valid
- [ ] Property 5: Demand exists
- [ ] Property 6: Supply available
- [ ] Property 7: Money conserved
- [ ] Property 8: Accounts reconcile
- [ ] Property 9: Transactions atomic
- [ ] Property 10: Prices not manipulable
- [ ] Property 11: Discounts bounded
- [ ] Property 12: Taxes fair

### 6.4 Procedural Generation Properties (2 hours)

#### File: `tests2/properties/procedural_generation_properties_test.lua`

- [ ] Property 1: Maps accessible
- [ ] Property 2: Maps balanced
- [ ] Property 3: Terrain valid
- [ ] Property 4: Cover distributed
- [ ] Property 5: Objectives reachable
- [ ] Property 6: Diverse biomes
- [ ] Property 7: UFO spawns valid
- [ ] Property 8: Resources distributed
- [ ] Property 9: Terrain tile types valid
- [ ] Property 10: Water/lava bounded

### 6.5 Pathfinding Properties (1.5 hours)

#### File: `tests2/properties/pathfinding_properties_test.lua`

- [ ] Property 1: Shortest path found
- [ ] Property 2: Path always valid
- [ ] Property 3: No blocked paths
- [ ] Property 4: Movement cost correct
- [ ] Property 5: Obstacle respected
- [ ] Property 6: Diagonal movement valid
- [ ] Property 7: AP calculated right
- [ ] Property 8: Pathing deterministic

### 6.6 Math Properties (1.5 hours)

#### File: `tests2/properties/math_properties_test.lua`

- [ ] Property 1: Hex distance properties
- [ ] Property 2: Angle calculations correct
- [ ] Property 3: Vector math consistent
- [ ] Property 4: Random bounded
- [ ] Property 5: Probability valid
- [ ] Property 6: Sorting stable
- [ ] Property 7: Hash consistent
- [ ] Property 8: Rounding errors bounded
- [ ] Property 9: Floating point safe
- [ ] Property 10: Matrix operations valid

### 6.7 Documentation (1 hour)

- [ ] Create `tests2/properties/README.md`

### 6.8 Testing & Validation (1 hour)

- [ ] Run property tests (100 iterations each)
  - [ ] Expect: 55/55 pass
  - [ ] Expect: <5s execution
  - [ ] Check shrinking works

**Phase 6 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 7: QUALITY GATE TESTS (10 hours)

### 7.1 Quality Framework (2 hours)

#### Create: `tests2/framework/quality_gate_checker.lua`

- [ ] Code style checker
- [ ] Coverage analyzer
- [ ] Documentation validator
- [ ] Performance profiler
- [ ] API stability checker

#### Create: `tests2/quality/init.lua`

- [ ] Register quality tests

### 7.2 Code Style Tests (1.5 hours)

#### File: `tests2/quality/code_style_test.lua`

- [ ] Test 1: Function names lowercase
- [ ] Test 2: Class names PascalCase
- [ ] Test 3: Constants UPPER_CASE
- [ ] Test 4: No unused variables
- [ ] Test 5: No global variables
- [ ] Test 6: Comments meaningful
- [ ] Test 7: Indentation consistent
- [ ] Test 8: Line length bounded

### 7.3 Coverage Threshold Tests (1 hour)

#### File: `tests2/quality/coverage_threshold_test.lua`

- [ ] Test 1: Core modules >70% coverage
- [ ] Test 2: Battle systems >70%
- [ ] Test 3: Geoscape >70%
- [ ] Test 4: Basescape >70%
- [ ] Test 5: Economy >70%
- [ ] Test 6: No module <50%

### 7.4 Documentation Tests (1 hour)

#### File: `tests2/quality/documentation_test.lua`

- [ ] Test 1: Public functions documented
- [ ] Test 2: Complex logic has comments
- [ ] Test 3: Files have headers
- [ ] Test 4: Parameters documented
- [ ] Test 5: Return values documented
- [ ] Test 6: Examples provided

### 7.5 Performance Benchmark Tests (1.5 hours)

#### File: `tests2/quality/performance_benchmark_test.lua`

- [ ] Test 1: Frame rate >30 FPS
- [ ] Test 2: Load time <2s
- [ ] Test 3: Save time <1s
- [ ] Test 4: A* pathfinding <100ms
- [ ] Test 5: Combat resolution <500ms
- [ ] Test 6: No memory leaks
- [ ] Test 7: GC pauses <100ms
- [ ] Test 8: API response <50ms

### 7.6 API Stability Tests (1 hour)

#### File: `tests2/quality/api_stability_test.lua`

- [ ] Test 1: No breaking API changes
- [ ] Test 2: Version bumped correctly
- [ ] Test 3: Deprecation warnings present
- [ ] Test 4: Migration path documented
- [ ] Test 5: Backward compatibility
- [ ] Test 6: No removed functions

### 7.7 Documentation (0.5 hours)

- [ ] Create `tests2/quality/README.md`

### 7.8 Testing & Validation (1 hour)

- [ ] Run quality tests
  - [ ] Expect: 34/34 pass
  - [ ] Expect: <1s execution

**Phase 7 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 8: FRAMEWORK INTEGRATION (8 hours)

### 8.1 HierarchicalSuite Extensions (3 hours)

- [ ] Modify `tests2/framework/hierarchical_suite.lua`
  - [ ] Add `type` field support for all 7 categories
  - [ ] Add filtering by type
  - [ ] Add category-specific output
  - [ ] Add metadata tracking
  - [ ] Verify backward compatibility

- [ ] Update `tests2/framework/assertions.lua`
  - [ ] Add security-specific assertions
  - [ ] Add property test assertions
  - [ ] Add performance assertions
  - [ ] Add compliance assertions

- [ ] Update `tests2/framework/hierarchy_reporter.lua`
  - [ ] Add per-category reporting
  - [ ] Add statistics by type
  - [ ] Add warnings for gaps
  - [ ] Generate category summaries

### 8.2 Master Test Runner (2 hours)

#### Create: `tests2/runners/run_all_enhanced.lua`

- [ ] Create master runner
- [ ] Add runner modes:
  - [ ] `all` - All 282 tests
  - [ ] `quick` - Smoke only (22 tests)
  - [ ] `pre_release` - Smoke + Regression + Quality
  - [ ] `full_audit` - Everything
  - [ ] `--report` - Generate HTML report
- [ ] Test runner works for each mode

#### Update: `tests2/main.lua`

- [ ] Add master runner routing
- [ ] Verify all modes work
- [ ] Test filtering logic

### 8.3 Batch Files (1 hour)

- [ ] Create/verify `run_smoke.bat`
- [ ] Create/verify `run_regressions.bat`
- [ ] Create/verify `run_api_tests.bat`
- [ ] Create/verify `run_compliance.bat`
- [ ] Create/verify `run_security.bat`
- [ ] Create/verify `run_properties.bat`
- [ ] Create/verify `run_quality.bat`
- [ ] Create/verify `run_all_enhanced.bat`
- [ ] Test each batch file

### 8.4 VS Code Task Integration (2 hours)

#### Update: `.vscode/tasks.json`

- [ ] Add task: 🚬 SMOKE: Quick Tests
- [ ] Add task: 🔄 REGRESSION: Historical Bug Tests
- [ ] Add task: 📋 API: Contract Validation Tests
- [ ] Add task: ✅ COMPLIANCE: Rules & Balance Tests
- [ ] Add task: 🔒 SECURITY: Security Audit Tests
- [ ] Add task: 🎲 PROPERTY: Edge Case Tests
- [ ] Add task: ⭐ QUALITY: Code Quality Tests
- [ ] Add task: 🏆 FULL SUITE: All Enhanced Tests

- [ ] Test each task from VS Code
- [ ] Verify output formatting
- [ ] Check error handling

**Phase 8 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 9: DOCUMENTATION (6 hours)

### 9.1 Category Guides (3 hours)

- [ ] Update `tests2/smoke/README.md` (✓ Smoke)
- [ ] Update `tests2/regression/README.md` (✓ Regression)
- [ ] Update `tests2/api/README.md` (✓ API)
- [ ] Update `tests2/compliance/README.md` (✓ Compliance)
- [ ] Update `tests2/security/README.md` (✓ Security)
- [ ] Update `tests2/properties/README.md` (✓ Property)
- [ ] Update `tests2/quality/README.md` (✓ Quality)

Each guide should include:
- [ ] Overview & purpose
- [ ] How to run tests
- [ ] How to write tests
- [ ] Code examples
- [ ] Common patterns
- [ ] Troubleshooting
- [ ] Performance notes

### 9.2 Main Test Guide (1.5 hours)

#### Update: `tests2/README.md`

- [ ] Add "Test Categories" section
- [ ] Add quick reference table
- [ ] Add test type selection guide
- [ ] Add running all 7 categories
- [ ] Add links to each category
- [ ] Add performance characteristics
- [ ] Add troubleshooting

### 9.3 Framework Documentation (1 hour)

#### Create: `tests2/framework/README.md`

- [ ] Document framework extensions
- [ ] Explain type system
- [ ] Provide runner info
- [ ] List new APIs

#### Update: `tests2/utils/test_helpers.lua`

- [ ] Document all helpers
- [ ] Document new assertions
- [ ] Provide examples

### 9.4 Developer Guide (0.5 hours)

#### Create: `docs/TESTING_GUIDE_ENHANCED.md`

- [ ] Comprehensive testing guide
- [ ] Test hierarchy flowchart
- [ ] When to use each type
- [ ] Writing examples for each
- [ ] Best practices
- [ ] Performance tips
- [ ] Security considerations

**Phase 9 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## PHASE 10: TESTING & VALIDATION (10 hours)

### 10.1 Individual Category Validation (4 hours)

#### Smoke Tests
- [ ] Run: `lovec "tests2/runners" run_smoke`
- [ ] Verify: 22/22 pass
- [ ] Verify: <500ms execution
- [ ] Verify: No warnings

#### Regression Tests
- [ ] Run: `lovec "tests2/runners" run_regressions`
- [ ] Verify: 38/38 pass
- [ ] Verify: <2s execution

#### API Contract Tests
- [ ] Run API tests
- [ ] Verify: 45/45 pass
- [ ] Verify: <1s execution

#### Compliance Tests
- [ ] Run compliance tests
- [ ] Verify: 44/44 pass
- [ ] Verify: <2s execution

#### Security Tests
- [ ] Run security tests
- [ ] Verify: 44/44 pass
- [ ] Verify: <2s execution

#### Property Tests
- [ ] Run property tests (100 iterations)
- [ ] Verify: 55/55 pass
- [ ] Verify: <5s execution
- [ ] Verify: Shrinking works

#### Quality Gate Tests
- [ ] Run quality tests
- [ ] Verify: 34/34 pass
- [ ] Verify: <1s execution

### 10.2 Integration Validation (2 hours)

- [ ] Run full enhanced suite
  - [ ] `lovec "tests2/runners" run_all_enhanced`
  - [ ] Expect: 282/282 new tests pass
  - [ ] Expect: No test conflicts
  - [ ] Expect: <15s total execution

- [ ] Run with existing tests
  - [ ] Verify: 2,493 existing tests still pass
  - [ ] Verify: No regressions
  - [ ] Total: 2,775 tests pass

- [ ] Test quick mode
  - [ ] `lovec "tests2/runners" run_all_enhanced quick`
  - [ ] Expect: ~50 tests
  - [ ] Expect: <3s execution

- [ ] Test pre-release mode
  - [ ] Expect: Smoke + Regression + Quality
  - [ ] Expect: ~94 tests
  - [ ] Expect: <4s execution

- [ ] Test full audit mode
  - [ ] `lovec "tests2/runners" run_all_enhanced full_audit`
  - [ ] Expect: All 282 tests
  - [ ] Expect: Reports generated

### 10.3 Performance Validation (2 hours)

- [ ] Smoke tests: <500ms ✓
- [ ] Regression tests: <2s ✓
- [ ] API tests: <1s ✓
- [ ] Compliance tests: <2s ✓
- [ ] Security tests: <2s ✓
- [ ] Property tests: <5s ✓
- [ ] Quality tests: <1s ✓
- [ ] Full suite: <15s ✓

- [ ] No memory leaks
- [ ] No test flakiness
- [ ] Consistent timing

### 10.4 Integration Testing (1 hour)

- [ ] Test all batch files
  - [ ] `run_smoke.bat` ✓
  - [ ] `run_regressions.bat` ✓
  - [ ] `run_api_tests.bat` ✓
  - [ ] `run_compliance.bat` ✓
  - [ ] `run_security.bat` ✓
  - [ ] `run_properties.bat` ✓
  - [ ] `run_quality.bat` ✓
  - [ ] `run_all_enhanced.bat` ✓

- [ ] Test all VS Code tasks
  - [ ] Smoke task works
  - [ ] Regression task works
  - [ ] API task works
  - [ ] Compliance task works
  - [ ] Security task works
  - [ ] Property task works
  - [ ] Quality task works
  - [ ] Full suite task works

- [ ] Report generation
  - [ ] HTML reports generated
  - [ ] JSON reports valid
  - [ ] Text reports readable

### 10.5 Documentation Review (1 hour)

- [ ] Review all README files
  - [ ] `tests2/smoke/README.md` ✓
  - [ ] `tests2/regression/README.md` ✓
  - [ ] `tests2/api/README.md` ✓
  - [ ] `tests2/compliance/README.md` ✓
  - [ ] `tests2/security/README.md` ✓
  - [ ] `tests2/properties/README.md` ✓
  - [ ] `tests2/quality/README.md` ✓
  - [ ] `tests2/README.md` ✓

- [ ] Review code examples
  - [ ] All examples runnable
  - [ ] All examples correct
  - [ ] Clear and helpful

- [ ] Proofread
  - [ ] No typos
  - [ ] Consistent terminology
  - [ ] Proper formatting

### 10.6 Final Validation (1 hour)

- [ ] All 350+ checklist items complete ✓
- [ ] Zero test failures (282/282) ✓
- [ ] Zero regressions (2,493/2,493) ✓
- [ ] Performance targets met ✓
- [ ] Documentation complete ✓
- [ ] No console warnings ✓
- [ ] Ready for production ✓

**Phase 10 Status:** ☐ TODO | ☐ IN_PROGRESS | ☐ TESTING | ☐ COMPLETE

---

## COMPLETION CHECKLIST

### Core Implementation
- [ ] Phase 1: Smoke Tests (22 tests)
- [ ] Phase 2: Regression Tests (38 tests)
- [ ] Phase 3: API Contract Tests (45 tests)
- [ ] Phase 4: Compliance Tests (44 tests)
- [ ] Phase 5: Security Tests (44 tests)
- [ ] Phase 6: Property Tests (55 tests)
- [ ] Phase 7: Quality Gate Tests (34 tests)

### Framework & Tools
- [ ] Phase 8: HierarchicalSuite extensions
- [ ] Phase 8: Master test runner
- [ ] Phase 8: Batch files (8 created)
- [ ] Phase 8: VS Code tasks (8 added)

### Documentation
- [ ] Phase 9: 7 category guides
- [ ] Phase 9: Main test guide
- [ ] Phase 9: Framework documentation
- [ ] Phase 9: Developer guide

### Validation
- [ ] Phase 10: All 282 tests pass
- [ ] Phase 10: Performance targets met
- [ ] Phase 10: Integration complete
- [ ] Phase 10: Documentation reviewed
- [ ] Phase 10: No regressions

---

## SUMMARY

| Item | Count | Status |
|------|-------|--------|
| Test Categories | 13 | ☐ TODO |
| New Test Files | 60+ | ☐ TODO |
| New Tests | 282 | ☐ TODO |
| Batch Files | 8 | ☐ TODO |
| VS Code Tasks | 8 | ☐ TODO |
| Documentation Files | 8 | ☐ TODO |
| Total Hours | 107h | ☐ TODO |
| **Overall Status** | | ☐ TODO |

---

**Created:** October 27, 2025
**Total Checkboxes:** 350+
**Status:** Ready for implementation

Use this checklist to track progress through all 10 phases of the test suite enhancement project.
