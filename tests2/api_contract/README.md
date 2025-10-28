<!-- ──────────────────────────────────────────────────────────────────────────
API CONTRACT TEST SUITE DOCUMENTATION
────────────────────────────────────────────────────────────────────────── -->

# API Contract Tests - Interface Verification Suite

## Overview

API Contract tests verify that **system interfaces remain stable and backwards compatible**. They test the contracts that modules promise - the expected input/output formats, method signatures, and data structures.

**Purpose:** Ensure API stability and backward compatibility (< 3 seconds)
**Scope:** Engine, Geoscape, Battlescape, Basescape, Systems, Persistence
**Count:** 45 tests
**Execution Time:** < 3 seconds

## Test Categories

### 1. Engine API Contracts (8 tests)
Core engine interface verification.

- **Engine:initializeContract** - Initialization returns correct structure
- **Engine:stateManagerContract** - State objects have consistent schema
- **Engine:moduleInterfaceContract** - All modules provide required methods
- **Engine:eventSystemContract** - Event callbacks have consistent signatures
- **Engine:configSchemaContract** - Configuration object schema
- **Engine:errorHandlingContract** - Error objects provide required fields
- **Engine:dependencyInjectionContract** - DI system resolves consistently
- **Engine:metricsInterfaceContract** - Performance metrics structure

### 2. Geoscape API Contracts (7 tests)
Geoscape layer interface verification.

- **Geoscape:worldMapContract** - World map location data schema
- **Geoscape:craftObjectContract** - Craft object interface methods
- **Geoscape:missionDataContract** - Mission data structure
- **Geoscape:interceptAPIContract** - Intercept response format
- **Geoscape:deploymentAPIContract** - Deployment object interface
- **Geoscape:researchAPIContract** - Research project structure
- **Geoscape:baseManagementAPIContract** - Base object interface

### 3. Battlescape API Contracts (8 tests)
Battlescape layer interface verification.

- **Battlescape:mapStructureContract** - Map dimensions and terrain
- **Battlescape:unitObjectContract** - Unit interface methods
- **Battlescape:combatActionContract** - Combat action result format
- **Battlescape:turnSystemContract** - Turn/phase management
- **Battlescape:lineOfSightContract** - LoS checking API
- **Battlescape:inventorySystemContract** - Equipment management
- **Battlescape:animationSystemContract** - Animation object interface
- **Battlescape:damageCalculationContract** - Damage calculation results

### 4. Basescape API Contracts (7 tests)
Basescape layer interface verification.

- **Basescape:baseStructureContract** - Base object structure
- **Basescape:facilityObjectContract** - Facility interface methods
- **Basescape:storageSystemContract** - Storage inventory management
- **Basescape:personnelManagementContract** - Soldier management interface
- **Basescape:craftManagementContract** - Vessel management interface
- **Basescape:researchQueueContract** - Research queue management
- **Basescape:manufacturingSystemContract** - Production queue API

### 5. System API Contracts (8 tests)
Core system interface verification.

- **System:audioSystemContract** - Audio playback control
- **System:inputSystemContract** - Input handling and key bindings
- **System:renderingSystemContract** - Rendering operations
- **System:timeSystemContract** - Delta time and timing
- **System:localizationSystemContract** - Translation interface
- **System:analyticsSystemContract** - Event tracking
- **System:configurationSystemContract** - Settings management
- **System:debugSystemContract** - Logging and profiling

### 6. Persistence API Contracts (7 tests)
Save/load system interface verification.

- **Persistence:saveFileStructureContract** - Save file metadata
- **Persistence:saveManagerContract** - Save/load interface
- **Persistence:serializationContract** - Serialization output format
- **Persistence:restorationContract** - State restoration accuracy
- **Persistence:multipleSaveSlotsContract** - Multi-slot support
- **Persistence:quicksaveContract** - Quicksave/autosave interface
- **Persistence:compatibilityCheckContract** - Version validation

---

## Running API Contract Tests

### Option 1: Batch File (Recommended for Windows)
```bash
run_api_contract.bat
```

### Option 2: Command Line
```bash
lovec "tests2/runners" "run_api_contract"
```

### Option 3: Via Test Framework
```bash
lovec "tests2/runners"  # Main test runner will include API tests
```

## Expected Results

**Success:** All 45 tests pass
```
API Contract Test Summary
═════════════════════════════════════════════════════════════════════════
Total:  45
Passed: 45
Failed: 0
═════════════════════════════════════════════════════════════════════════

✓ ALL API CONTRACTS VERIFIED (Interfaces stable)
```

**Failure:** API contract failure indicates a breaking change was introduced.

## File Structure

```
tests2/
├── api_contract/                          (Phase 3 - API Contract Tests)
│   ├── init.lua                          (Test registration)
│   ├── engine_api_contract_test.lua      (8 tests)
│   ├── geoscape_api_contract_test.lua    (7 tests)
│   ├── battlescape_api_contract_test.lua (8 tests)
│   ├── basescape_api_contract_test.lua   (7 tests)
│   ├── system_api_contract_test.lua      (8 tests)
│   ├── persistence_api_contract_test.lua (7 tests)
│   └── README.md                         (This file)
└── runners/
    └── run_api_contract.lua              (API contract test runner)
```

## Test Framework

All API contract tests use **HierarchicalSuite** with the `type = "api"` marker:

```lua
Suite:testMethod("Module:contractName", {
    description = "What API contract this verifies",
    testCase = "contract",
    type = "api"
}, function()
    -- Test code validating API structure
end)
```

## API Contract Testing Patterns

### Pattern 1: Method Signature Verification
```lua
-- Verify object has required methods with correct types
local object = createUnit("Soldier", 0, 0)
Helpers.assertTrue(type(object.move) == "function", "move must be function")
Helpers.assertTrue(type(object.attack) == "function", "attack must be function")
```

### Pattern 2: Return Value Schema
```lua
-- Verify methods return objects with expected structure
local result = saveManager:save(1, gameState)
Helpers.assertTrue(result.success ~= nil, "Must have success field")
Helpers.assertTrue(result.timestamp ~= nil, "Must have timestamp")
```

### Pattern 3: Data Structure Consistency
```lua
-- Verify objects maintain consistent structure
local base = {
    id = 1,
    name = "Main Base",
    location = {x = 50, y = 50}
}
Helpers.assertTrue(base.location ~= nil, "Must have location field")
Helpers.assertTrue(base.location.x ~= nil, "Location must have x")
```

## When API Contract Tests Fail

**Action:** Do NOT merge code that breaks API contracts

1. **Identify the breaking change** - Review recent commits
2. **Decide on approach:**
   - **Option A:** Fix the code to restore the API
   - **Option B:** Update the API intentionally and increment version
3. **If intentional change:**
   - Update all dependent code
   - Document the breaking change
   - Increment major version number
   - Update this contract test to match new API

## API Versioning Strategy

When APIs change:

**Backward Compatible (Minor Version):**
- Adding new optional parameters
- Adding new methods to objects
- Expanding return value structure

**Breaking Change (Major Version):**
- Removing methods
- Changing method signatures
- Removing required fields
- Changing return value type

Example:
```lua
-- Version 1.0.0 - Original API
function craft:moveTo(x, y) end

-- Version 1.1.0 - Backward compatible (added optional parameter)
function craft:moveTo(x, y, speed) end

-- Version 2.0.0 - Breaking change (changed signature)
function craft:move(x, y, options) end  -- Old moveTo removed
```

## Integration with Full Test Suite

API Contract tests are:
- ✅ Run as part of the full test suite
- ✅ Run independently for quick interface verification
- ✅ Integrated into CI/CD pipeline
- ✅ Fast enough to run on every code change

## Common API Issues Caught

**Issue Type 1: Method Signature Change**
- Functions added or removed
- Parameter count changed
- Parameter types changed
- Return value structure changed

**Issue Type 2: Object Structure Change**
- Required fields removed
- Field types changed
- Object structure reorganized

**Issue Type 3: Behavior Change**
- Return values changed
- Side effects altered
- Error handling changed

## Best Practices for API Stability

1. **Test APIs before release** - Run API contract tests before merging
2. **Document API changes** - Keep changelog of API modifications
3. **Use semantic versioning** - Follow version numbering conventions
4. **Provide migration paths** - For breaking changes, document upgrade path
5. **Maintain backward compatibility** - When possible, support old APIs

## Next Steps

After Phase 3 completion:
- Phase 4: Compliance Tests (44 tests)
- Phase 5: Security Tests (44 tests)
- Phase 6: Property-Based Tests (55 tests)
- Phase 7: Quality Gate Tests (34 tests)

Total target: 282 new tests across 7 categories

---

## Summary

Phase 3 adds **45 API contract tests** across 6 layers to verify:
- Engine core API stability
- Geoscape interface consistency
- Battlescape combat API
- Basescape management API
- System utilities interface
- Persistence save/load API

All tests ensure backward compatibility and detect breaking changes early in development.
