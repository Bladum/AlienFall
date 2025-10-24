# Task: Validate Entire Mod Against GAME_API.toml

**Status:** TODO
**Priority:** High
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

**Dependencies:** TASK-001 (GAME_API.toml must exist first)

---

## Overview

Create automated validator that loads EVERY TOML file from a mod folder and validates it against the GAME_API.toml schema. Validates structure, location, file naming, and content types/values.

---

## Purpose

**Why this is needed:**
- Mod creators make mistakes in TOML files
- Typos in field names cause silent failures
- Wrong data types crash the game
- Missing required fields cause errors at runtime
- Files in wrong locations never get loaded
- Invalid references break game systems
- No way to catch errors before running game

**What problem it solves:**
- Catches ALL TOML errors before game runs
- Validates file structure matches API
- Validates file location matches API expectations
- Validates file naming conventions
- Validates content types (string vs int vs enum)
- Validates enum values are valid
- Validates numeric constraints (min/max)
- Generates detailed error reports
- Enables CI/CD validation

---

## Requirements

### Functional Requirements
- [ ] Load and parse GAME_API.toml schema
- [ ] Recursively scan mod folder for ALL .toml files
- [ ] Determine which API section each file should validate against
- [ ] Validate file location matches expected path pattern
- [ ] Validate file name matches conventions
- [ ] Validate TOML file structure is valid
- [ ] Validate all required fields are present
- [ ] Validate field types match schema (string, int, float, bool, array, table)
- [ ] Validate enum fields only use valid values
- [ ] Validate numeric fields respect min/max constraints
- [ ] Validate references point to valid entity IDs
- [ ] Generate detailed error report with line numbers
- [ ] Generate warning report for deprecated fields
- [ ] Generate summary statistics (files checked, errors found, warnings)
- [ ] Support validation of single file or entire mod
- [ ] Exit with error code if validation fails (for CI/CD)

### Technical Requirements
- [ ] Written in Lua (integrate with Love2D ecosystem)
- [ ] Use existing TOML parser from engine
- [ ] Can run standalone: `lovec tools/validators/validate_mod.lua mods/core`
- [ ] Can run from engine (optional integration)
- [ ] Clear console output with colors if supported
- [ ] JSON output mode for machine parsing
- [ ] Verbose mode for detailed debugging
- [ ] Must validate ALL mod folders: `mods/core`, `mods/examples`, etc.

### Acceptance Criteria
- [ ] Validator script exists and is executable
- [ ] Can validate entire mod folder
- [ ] Can validate single TOML file
- [ ] Catches all type mismatches
- [ ] Catches all missing required fields
- [ ] Catches all invalid enum values
- [ ] Catches all file location errors
- [ ] Catches all file naming errors
- [ ] Reports include file path, line number, error message
- [ ] Returns exit code 0 if valid, non-zero if errors
- [ ] Generates human-readable report
- [ ] Generates machine-readable report (JSON mode)
- [ ] Documentation exists on how to use validator

---

## Plan

### Step 1: Create Validator Script Structure
**Description:** Set up basic validator script with command-line interface

**Files to create:**
- `tools/validators/validate_mod.lua` - main validator script
- `tools/validators/lib/schema_loader.lua` - loads GAME_API.toml
- `tools/validators/lib/file_scanner.lua` - scans mod folders
- `tools/validators/lib/type_validator.lua` - validates types
- `tools/validators/lib/report_generator.lua` - generates reports
- `tools/validators/README.md` - documentation

**Script interface:**
```bash
# Validate entire mod
lovec tools/validators/validate_mod.lua mods/core

# Validate single file
lovec tools/validators/validate_mod.lua mods/core/rules/units/soldier.toml

# Verbose mode
lovec tools/validators/validate_mod.lua mods/core --verbose

# JSON output
lovec tools/validators/validate_mod.lua mods/core --json

# Check specific category only
lovec tools/validators/validate_mod.lua mods/core --category units
```

**Estimated time:** 2-3 hours

---

### Step 2: Implement Schema Loader
**Description:** Load and parse GAME_API.toml into usable format

**File:** `tools/validators/lib/schema_loader.lua`

**Functions needed:**
```lua
-- Load GAME_API.toml and return schema table
function SchemaLoader.load(schemaPath)
  -- Parse TOML file
  -- Build lookup tables for fast access
  -- Return schema object
end

-- Get API definition for specific entity type
function SchemaLoader.getDefinition(schema, entityType)
  -- Return api.units, api.items, etc.
end

-- Check if field is required
function SchemaLoader.isRequired(definition, fieldPath)
  -- Check required flag
end

-- Get field type
function SchemaLoader.getFieldType(definition, fieldPath)
  -- Return type: string, integer, float, boolean, enum, array, table, reference
end

-- Get enum valid values
function SchemaLoader.getEnumValues(definition, fieldPath)
  -- Return array of valid values
end

-- Get numeric constraints
function SchemaLoader.getConstraints(definition, fieldPath)
  -- Return min, max, default
end
```

**Estimated time:** 3-4 hours

---

### Step 3: Implement File Scanner
**Description:** Scan mod folder and categorize TOML files

**File:** `tools/validators/lib/file_scanner.lua`

**Functions needed:**
```lua
-- Recursively find all .toml files in mod folder
function FileScanner.scanMod(modPath)
  -- Return array of file paths
end

-- Determine which API section file belongs to based on path
function FileScanner.categorizeFile(filePath, modPath)
  -- mods/*/rules/units/*.toml -> "units"
  -- mods/*/rules/items/*.toml -> "items"
  -- mods/*/rules/crafts/*.toml -> "crafts"
  -- etc.
  -- Return category string or nil if unknown
end

-- Validate file location matches API expectations
function FileScanner.validateLocation(filePath, modPath, category, schema)
  -- Check if file is in correct folder
  -- Return errors array
end

-- Validate file naming convention
function FileScanner.validateNaming(filePath, category, schema)
  -- Check naming rules (snake_case, no spaces, etc.)
  -- Return errors array
end
```

**Logic for categorization:**
```lua
local pathMappings = {
  ["rules/units/"] = "units",
  ["rules/items/"] = "items",
  ["rules/weapons/"] = "weapons",
  ["rules/armor/"] = "armor",
  ["rules/crafts/"] = "crafts",
  ["rules/facilities/"] = "facilities",
  ["rules/research/"] = "research",
  ["rules/manufacturing/"] = "manufacturing",
  ["rules/missions/"] = "missions",
  ["rules/ufos/"] = "ufos",
  ["rules/aliens/"] = "aliens",
  ["rules/regions/"] = "regions",
  ["rules/countries/"] = "countries",
  ["rules/events/"] = "events",
  ["rules/pilots/"] = "pilots",
  ["rules/perks/"] = "perks",
  ["rules/tilesets/"] = "tilesets",
  ["rules/mapblocks/"] = "mapblocks",
  -- etc.
}
```

**Estimated time:** 3-4 hours

---

### Step 4: Implement Type Validator
**Description:** Validate TOML content against schema types

**File:** `tools/validators/lib/type_validator.lua`

**Functions needed:**
```lua
-- Validate entire TOML file against schema definition
function TypeValidator.validate(tomlData, definition, filePath)
  -- Returns array of errors and warnings
end

-- Check if all required fields are present
function TypeValidator.checkRequired(tomlData, definition)
  -- Return array of missing field errors
end

-- Validate field type matches schema
function TypeValidator.validateType(value, expectedType, fieldPath)
  -- Check if value is correct type
  -- Return error or nil
end

-- Validate enum value
function TypeValidator.validateEnum(value, validValues, fieldPath)
  -- Check if value is in valid set
  -- Return error or nil
end

-- Validate numeric constraints
function TypeValidator.validateNumeric(value, min, max, fieldPath)
  -- Check if number is in range
  -- Return error or nil
end

-- Validate reference exists (advanced - may need entity registry)
function TypeValidator.validateReference(value, referencedType, fieldPath)
  -- Check if referenced ID exists
  -- For now, just check format, actual existence check is future enhancement
  -- Return warning or error
end

-- Validate nested table/array structures
function TypeValidator.validateNested(value, definition, fieldPath)
  -- Recursively validate nested structures
  -- Return array of errors
end
```

**Type checking logic:**
```lua
local function checkType(value, expectedType)
  if expectedType == "string" then
    return type(value) == "string"
  elseif expectedType == "integer" then
    return type(value) == "number" and math.floor(value) == value
  elseif expectedType == "float" then
    return type(value) == "number"
  elseif expectedType == "boolean" then
    return type(value) == "boolean"
  elseif expectedType == "array" then
    return type(value) == "table" and #value > 0
  elseif expectedType == "table" then
    return type(value) == "table"
  end
  return false
end
```

**Estimated time:** 5-6 hours

---

### Step 5: Implement Report Generator
**Description:** Generate human-readable and machine-readable reports

**File:** `tools/validators/lib/report_generator.lua`

**Report structure:**
```lua
local report = {
  summary = {
    filesChecked = 0,
    filesValid = 0,
    filesWithErrors = 0,
    filesWithWarnings = 0,
    totalErrors = 0,
    totalWarnings = 0,
  },
  files = {
    {
      path = "mods/core/rules/units/soldier.toml",
      category = "units",
      valid = false,
      errors = {
        { line = 10, field = "stats.health", message = "Expected integer, got string" },
        { line = 15, field = "type", message = "Invalid enum value 'soilder', valid values: soldier, alien, civilian" },
      },
      warnings = {
        { line = 20, field = "old_stat", message = "Deprecated field, use 'new_stat' instead" },
      },
    },
    -- ... more files
  },
}
```

**Functions needed:**
```lua
-- Generate console report with colors
function ReportGenerator.console(report, verbose)
  -- Print summary
  -- Print errors grouped by file
  -- Use colors: red for errors, yellow for warnings, green for success
end

-- Generate JSON report
function ReportGenerator.json(report)
  -- Return JSON string
end

-- Generate markdown report
function ReportGenerator.markdown(report)
  -- For documentation/CI artifacts
  -- Return markdown string
end
```

**Console output format:**
```
Validating Mod: mods/core
=========================

Scanning files... 45 TOML files found

Validating: rules/units/soldier.toml
  ✓ Location: OK
  ✓ Naming: OK
  ✗ ERROR [line 10, field stats.health]: Expected integer, got string "100"
  ✗ ERROR [line 15, field type]: Invalid enum value 'soilder', valid: soldier, alien, civilian
  ⚠ WARNING [line 20, field old_stat]: Deprecated, use 'new_stat'

Validating: rules/items/laser_rifle.toml
  ✓ All checks passed

... (more files)

Summary:
========
Files checked: 45
Valid: 42
With errors: 3
With warnings: 5
Total errors: 7
Total warnings: 8

❌ VALIDATION FAILED - 7 errors found
```

**Estimated time:** 3-4 hours

---

### Step 6: Implement Main Validator Logic
**Description:** Tie all components together in main script

**File:** `tools/validators/validate_mod.lua`

**Main logic:**
```lua
-- Parse command line arguments
local args = parseArgs(arg)

-- Load schema
local schema = SchemaLoader.load("api/GAME_API.toml")

-- Scan mod folder
local files = FileScanner.scanMod(args.modPath)

-- Initialize report
local report = {
  summary = { filesChecked = 0, totalErrors = 0, totalWarnings = 0 },
  files = {},
}

-- Validate each file
for _, filePath in ipairs(files) do
  local category = FileScanner.categorizeFile(filePath, args.modPath)

  if not category then
    -- Unknown file location
    addError(report, filePath, nil, nil, "File location not recognized by API")
  else
    local definition = SchemaLoader.getDefinition(schema, category)

    -- Check location and naming
    local locationErrors = FileScanner.validateLocation(filePath, args.modPath, category, schema)
    local namingErrors = FileScanner.validateNaming(filePath, category, schema)

    -- Load and parse TOML
    local tomlData, parseError = loadTOML(filePath)

    if parseError then
      addError(report, filePath, nil, nil, "TOML parse error: " .. parseError)
    else
      -- Validate content
      local errors, warnings = TypeValidator.validate(tomlData, definition, filePath)

      -- Collect all errors/warnings
      addFileResults(report, filePath, category, locationErrors, namingErrors, errors, warnings)
    end
  end

  report.summary.filesChecked = report.summary.filesChecked + 1
end

-- Generate report
if args.json then
  print(ReportGenerator.json(report))
else
  ReportGenerator.console(report, args.verbose)
end

-- Exit with appropriate code
if report.summary.totalErrors > 0 then
  os.exit(1)
else
  os.exit(0)
end
```

**Estimated time:** 3-4 hours

---

### Step 7: Add VS Code Task Integration
**Description:** Add task to .vscode/tasks.json for easy execution

**Task definition:**
```json
{
  "label": "🔍 VALIDATE: Core Mod",
  "type": "shell",
  "command": "C:\\Program Files\\LOVE\\lovec.exe",
  "args": [
    "tools/validators/validate_mod.lua",
    "mods/core"
  ],
  "group": "test",
  "presentation": {
    "reveal": "always",
    "panel": "new"
  }
}
```

**Add tasks for:**
- Validate core mod
- Validate all mods
- Validate single file (with input prompt)

**Estimated time:** 1 hour

---

### Step 8: Create Documentation
**Description:** Document how to use validator

**File:** `tools/validators/README.md`

**Content must cover:**
- What the validator does
- How to run it (command line examples)
- Command line options (--verbose, --json, --category)
- How to interpret results
- Common errors and how to fix them
- Integration with CI/CD
- Integration with VS Code tasks
- How to add validation for new entity types

**Examples needed:**
```bash
# Basic usage
lovec tools/validators/validate_mod.lua mods/core

# Validate specific category
lovec tools/validators/validate_mod.lua mods/core --category units

# Get JSON output for CI
lovec tools/validators/validate_mod.lua mods/core --json > validation_report.json

# Validate single file
lovec tools/validators/validate_mod.lua mods/core/rules/units/soldier.toml
```

**Estimated time:** 2 hours

---

### Step 9: Testing and Validation
**Description:** Test validator with various scenarios

**Test scenarios:**
- [ ] Valid mod passes validation
- [ ] Invalid field type triggers error
- [ ] Missing required field triggers error
- [ ] Invalid enum value triggers error
- [ ] Numeric out of range triggers error
- [ ] File in wrong location triggers error
- [ ] Invalid file name triggers error
- [ ] Deprecated field triggers warning
- [ ] TOML syntax error triggers error
- [ ] Unknown category triggers error
- [ ] Empty mod folder handled gracefully
- [ ] Non-existent mod path handled gracefully

**Create test fixtures:**
- `tests/fixtures/mods/valid_mod/` - perfect mod for testing
- `tests/fixtures/mods/invalid_mod/` - deliberately broken mod

**Estimated time:** 4-5 hours

---

## Implementation Details

### Architecture

**Modular Design:**
```
validate_mod.lua (main entry point)
├── lib/schema_loader.lua (loads GAME_API.toml)
├── lib/file_scanner.lua (finds and categorizes files)
├── lib/type_validator.lua (validates types and values)
└── lib/report_generator.lua (formats output)
```

**Validation Flow:**
1. Load schema from GAME_API.toml
2. Scan mod folder for .toml files
3. For each file:
   - Determine category (units, items, etc.)
   - Validate file location
   - Validate file name
   - Parse TOML
   - Validate structure
   - Validate types
   - Validate values
   - Collect errors/warnings
4. Generate report
5. Exit with status code

**Error Collection:**
- Errors array per file
- Each error has: line number, field path, message
- Warnings array per file
- Summary statistics

### Key Components

**SchemaLoader:** Parses GAME_API.toml and provides query interface
**FileScanner:** Finds files and determines their purpose
**TypeValidator:** Core validation logic for types and values
**ReportGenerator:** Formats output for humans and machines

### Dependencies

- TOML parser (from engine or lib)
- Filesystem access (love.filesystem or io)
- JSON encoder for JSON output mode
- GAME_API.toml must exist (TASK-001)

---

## Testing Strategy

### Unit Tests
Create tests for each component:

**test_schema_loader.lua:**
- Test loading valid schema
- Test loading invalid schema
- Test querying definitions
- Test getting field types

**test_file_scanner.lua:**
- Test scanning mod folder
- Test categorizing files
- Test validating locations
- Test validating names

**test_type_validator.lua:**
- Test type checking (all types)
- Test enum validation
- Test numeric constraints
- Test required field checking
- Test nested structure validation

**test_report_generator.lua:**
- Test console output
- Test JSON output
- Test markdown output

### Integration Tests

**test_validator_integration.lua:**
- Create fixture mods (valid and invalid)
- Run validator on fixtures
- Assert correct errors found
- Assert correct warnings found
- Assert summary statistics correct

### Manual Testing

1. Run on `mods/core` - should pass (after fixing any issues)
2. Deliberately break a TOML file - should catch error
3. Move file to wrong folder - should catch location error
4. Use invalid enum value - should catch enum error
5. Test all command line options

---

## Documentation Updates

### Files to Create
- [ ] `tools/validators/validate_mod.lua` - main script
- [ ] `tools/validators/lib/*.lua` - library modules
- [ ] `tools/validators/README.md` - usage documentation
- [ ] `tests/validators/` - test suite

### Files to Update
- [ ] `tools/README.md` - add validator to tools list
- [ ] `.vscode/tasks.json` - add validation tasks
- [ ] `api/MODDING_GUIDE.md` - mention validation tool
- [ ] `.github/copilot-instructions.md` - add validator to workflow

---

## Notes

**Performance Considerations:**
- Large mods may have hundreds of TOML files
- Need to validate efficiently
- Consider caching schema lookups
- Consider parallel validation (future enhancement)

**Error Quality:**
- Error messages must be clear and actionable
- Include line numbers when possible
- Suggest fixes when obvious
- Group related errors

**Extensibility:**
- Easy to add new validation rules
- Easy to add new entity types
- Easy to customize for different mod structures

**Future Enhancements:**
- Validate cross-references (unit requires tech that exists)
- Validate asset references (sprite files exist)
- Validate numeric balance (no obvious broken values)
- Auto-fix mode (fix simple errors automatically)
- Watch mode (continuously validate during development)
- IDE integration (real-time validation in editor)

---

## Blockers

**Must have before starting:**
- [ ] TASK-001 completed (GAME_API.toml exists)
- [ ] TOML parser available
- [ ] Test fixtures prepared

**Potential issues:**
- GAME_API.toml might not be complete
- TOML parser might have limitations
- Some validation rules might be complex to implement
- Error reporting line numbers might be difficult with TOML parser

---

## Review Checklist

- [ ] All validation rules implemented
- [ ] All error types tested
- [ ] Clear error messages
- [ ] Documentation complete
- [ ] VS Code tasks added
- [ ] Exit codes correct for CI/CD
- [ ] JSON output format is stable
- [ ] Performance acceptable for large mods
- [ ] Code follows Lua best practices
- [ ] No globals, proper error handling

---

## Success Criteria

**Task is DONE when:**
1. Validator script exists and runs
2. Can validate entire mod folder
3. Can validate single file
4. Catches all required error types
5. Generates clear reports
6. Returns correct exit codes
7. VS Code tasks work
8. Documentation is complete
9. Tests pass
10. Manual validation on mods/core succeeds

**This enables:**
- CI/CD validation of mods
- Faster mod development (catch errors early)
- Better mod quality
- Foundation for auto-fix tools
- Foundation for IDE integration
