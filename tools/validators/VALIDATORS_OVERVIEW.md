# Validators - Comprehensive Mod Validation Tools

**Status:** ✅ Complete
**Version:** 1.0.0
**Purpose:** Complete mod validation system with multiple specialized validators

---

## Overview

The validators package provides comprehensive mod validation tools for AlienFall. It includes:

1. **API Validator** - Validates TOML structure against GAME_API.toml
2. **Content Validator** - Validates internal consistency and references
3. **Report Generator** - Generates detailed validation reports

Together, they ensure mod quality and catch errors before gameplay.

---

## Directory Structure

```
tools/validators/
├── README.md                          ← Main documentation
├── CONTENT_VALIDATOR_GUIDE.md         ← Content validator docs
├── validate_mod.lua                   ← API validator (main entry)
├── validate_content.lua               ← Content validator (main entry)
│
└── lib/                               ← Validator libraries
    ├── schema_loader.lua              # Loads GAME_API.toml schema
    ├── file_scanner.lua               # Scans mod files
    ├── type_validator.lua             # Validates field types
    ├── content_loader.lua             # Loads mod content
    ├── reference_validator.lua        # Validates entity references
    ├── asset_validator.lua            # Validates asset files
    ├── tech_tree_validator.lua        # Validates research tree
    ├── balance_validator.lua          # Sanity checks
    └── report_generator.lua           # Generates reports
```

---

## Validators Overview

### 1. API Validator (`validate_mod.lua`)

**Purpose:** Validates TOML file structure against GAME_API.toml schema

**Checks:**
- ✅ TOML syntax is valid
- ✅ Files in correct locations
- ✅ Required fields present
- ✅ Field types correct
- ✅ Enum values valid
- ✅ Numeric values in valid ranges
- ✅ Patterns match (e.g., ID format)

**Usage:**
```bash
lovec tools/validators/validate_mod.lua mods/core [options]
```

**Options:**
- `--verbose` - Show all files
- `--json` - JSON output
- `--category` - Validate specific category
- `--schema` - Custom schema file
- `--output` - Save report to file

**Exit Codes:**
- `0` - All valid
- `1` - Errors found

### 2. Content Validator (`validate_content.lua`)

**Purpose:** Validates mod content internal consistency

**Checks:**
- ✅ Entity references exist
- ✅ Asset files exist
- ✅ Tech tree valid (no circular dependencies)
- ✅ No orphaned content
- ✅ Balance sanity (no zero damage, etc.)

**Usage:**
```bash
lovec tools/validators/validate_content.lua mods/core [options]
```

**Options:**
- `--verbose` - Show detailed output
- `--json` - JSON output
- `--skip-assets` - Skip file checks
- `--only-assets` - Only file checks
- `--category` - Validate specific category
- `--output` - Save report to file

**Exit Codes:**
- `0` - All valid
- `1` - Errors found

---

## Validation Workflow

### Complete Validation (Recommended)

Run both validators for complete verification:

```bash
#!/bin/bash
MOD="mods/core"

echo "Step 1: API Validation (structure)"
lovec tools/validators/validate_mod.lua "$MOD"
if [ $? -ne 0 ]; then
  echo "❌ API validation failed"
  exit 1
fi

echo ""
echo "Step 2: Content Validation (consistency)"
lovec tools/validators/validate_content.lua "$MOD"
if [ $? -ne 0 ]; then
  echo "❌ Content validation failed"
  exit 1
fi

echo ""
echo "✅ All validations passed"
```

### Quick Validation

For rapid iteration, use specific categories:

```bash
# Only validate units
lovec tools/validators/validate_mod.lua mods/core --category units
lovec tools/validators/validate_content.lua mods/core --category units
```

### CI/CD Integration

Generate machine-readable JSON output:

```bash
# API validation
lovec tools/validators/validate_mod.lua mods/core --json > api_validation.json

# Content validation
lovec tools/validators/validate_content.lua mods/core --json > content_validation.json

# Check results
jq '.summary' api_validation.json
```

---

## Library Modules

### schema_loader.lua

Loads GAME_API.toml schema and provides lookup functions.

**Key Functions:**
```lua
local schema = SchemaLoader.loadSchema(schemaPath)
local definition = SchemaLoader.getDefinition(schema, "units")
local field = SchemaLoader.getField(schema, "units", "health")
```

### file_scanner.lua

Scans directories for TOML files.

**Key Functions:**
```lua
local files = FileScanner.scanModDirectory(modPath)
local files = FileScanner.scanCategory(modPath, "units")
```

### type_validator.lua

Validates field types and values against schema.

**Key Functions:**
```lua
local errors = TypeValidator.validate(data, definition)
local valid = TypeValidator.isValidType(value, expectedType)
local valid = TypeValidator.isInRange(value, min, max)
```

### content_loader.lua

Loads all mod TOML files into memory.

**Key Functions:**
```lua
local mod = ContentLoader.loadMod(modPath)
local index = ContentLoader.buildIndex(mod)
local entity = ContentLoader.getEntity(mod, category, id)
```

### reference_validator.lua

Validates entity references across categories.

**Key Functions:**
```lua
local errors = ReferenceValidator.validate(mod, index)
local errors = ReferenceValidator.validateUnits(units, index)
```

### asset_validator.lua

Validates referenced asset files exist.

**Key Functions:**
```lua
local errors = AssetValidator.validate(mod, modPath)
local errors = AssetValidator.checkEntityAssets(entity, modPath)
```

### tech_tree_validator.lua

Validates research tech tree structure.

**Key Functions:**
```lua
local errors, warnings = TechTreeValidator.validate(research, index)
local cycles = TechTreeValidator.findCircularDependencies(graph, research)
```

### balance_validator.lua

Performs sanity checks on values.

**Key Functions:**
```lua
local warnings = BalanceValidator.validate(mod)
local warnings = BalanceValidator.validateUnits(units)
```

### report_generator.lua

Generates validation reports in various formats.

**Key Functions:**
```lua
ReportGenerator.console(report, verbose)
local json = ReportGenerator.json(report)
local markdown = ReportGenerator.markdown(report)
```

---

## Common Workflows

### Workflow 1: Add New Content

1. Create TOML file
2. Run validators:
   ```bash
   lovec tools/validators/validate_mod.lua mods/core --verbose
   lovec tools/validators/validate_content.lua mods/core --verbose
   ```
3. Fix any errors
4. Test in game

### Workflow 2: Fix Broken References

1. Run content validator to find errors:
   ```bash
   lovec tools/validators/validate_content.lua mods/core --verbose
   ```
2. Check error messages for what's missing
3. Add missing entity or fix reference
4. Re-run validator

### Workflow 3: Balance Review

1. Run content validator to get balance warnings:
   ```bash
   lovec tools/validators/validate_content.lua mods/core --verbose
   ```
2. Review warnings for suspicious values
3. Adjust stats if needed
4. Test in game

---

## Error Categories

### API Validation Errors

| Error | Meaning | Fix |
|-------|---------|-----|
| "Type mismatch" | Field type wrong | Use correct type (int, string, etc.) |
| "Missing required" | Required field absent | Add the field |
| "Invalid enum" | Enum value not valid | Check GAME_API for valid values |
| "Out of range" | Value outside min/max | Use value within range |
| "Pattern mismatch" | String doesn't match pattern | Use correct format (e.g., snake_case for IDs) |

### Content Validation Errors

| Error | Meaning | Fix |
|-------|---------|-----|
| "Non-existent reference" | Entity ID not found | Create the referenced entity |
| "Missing asset file" | Sprite/audio file missing | Create or add file |
| "Circular dependency" | Tech requires itself indirectly | Remove one requirement |
| "Orphaned tech" | Tech unreachable | Link to existing tree |
| "Zero damage" | Weapon has 0 damage | Set damage > 0 |

---

## Performance Tips

### Speed Up Validation

```bash
# Skip slow asset checking
lovec tools/validators/validate_content.lua mods/core --skip-assets

# Check only specific category
lovec tools/validators/validate_content.lua mods/core --category units

# Run in parallel for multiple mods
for mod in mods/*/; do
  lovec tools/validators/validate_mod.lua "$mod" &
done
wait
```

### Typical Times

- **Small mod** (100 files): < 1 second
- **Medium mod** (500 files): 2-5 seconds
- **Large mod** (1000+ files): 10-30 seconds

---

## VS Code Integration

### Add Tasks

```json
{
  "label": "🔍 VALIDATE: API - Core Mod",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/validators/validate_mod.lua", "mods/core"],
  "group": "test"
},
{
  "label": "🔍 VALIDATE: Content - Core Mod",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/validators/validate_content.lua", "mods/core"],
  "group": "test"
}
```

### Run Tasks

**Ctrl+Shift+P** → "Run Task" → select validator

---

## Advanced Usage

### Generate JSON Report

```bash
lovec tools/validators/validate_mod.lua mods/core --json > report.json
```

### Filter Results with jq

```bash
# Show only errors
cat report.json | jq '.files[] | select(.valid == false)'

# Show error summary
cat report.json | jq '.summary'

# Count errors by type
cat report.json | jq '.files[] | select(.valid == false) | .errors[].type' | sort | uniq -c
```

### Custom Validation Script

```lua
-- custom_validator.lua
local SchemaLoader = require("schema_loader")
local TypeValidator = require("type_validator")

local schema = SchemaLoader.loadSchema("api/GAME_API.toml")
local errors = {}

-- Your custom validation logic here

print("Found " .. #errors .. " errors")
```

---

## Troubleshooting

### Validators Won't Run

**Problem:** "Cannot find module" error

**Fix:**
- Ensure Love2D is installed: `lovec --version`
- Check file paths are correct
- Try absolute paths instead of relative

### Slow Validation

**Problem:** Validation takes too long

**Fix:**
- Skip asset checks: `--skip-assets`
- Validate specific category: `--category units`
- Check for large binary files that shouldn't be there

### Validators Disagree

**Problem:** API validator passes but content validator fails

**Fix:**
- This is normal - they check different things
- API checks structure, content checks references
- Both should pass for complete validation

---

## Creating Custom Validators

Template for custom validator:

```lua
#!/usr/bin/env lua
-- custom_validator.lua - Custom validation logic

package.path = "./tools/validators/lib/?.lua;" .. package.path

local ContentLoader = require("content_loader")
local ReportGenerator = require("report_generator")

-- Load mod
local mod = ContentLoader.loadMod("mods/core")
local index = ContentLoader.buildIndex(mod)

-- Your validation logic
local errors = {}
-- ... add errors ...

-- Generate report
local report = {
  summary = {
    totalErrors = #errors,
  },
  errors = errors,
}

ReportGenerator.console(report, true)
os.exit(#errors > 0 and 1 or 0)
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| README.md | Main validator documentation |
| CONTENT_VALIDATOR_GUIDE.md | Content validator guide |
| `api/GAME_API_GUIDE.md` | API schema documentation |
| `api/MODDING_GUIDE.md` | Modding guide |

---

## Related Resources

- **Mod Examples:** `mods/core/`, `mods/minimal_mod/`
- **Test Data:** `tests/fixtures/mods/`
- **Schema:** `api/GAME_API.toml`
- **IDE Setup:** `docs/IDE_SETUP.md`

---

## Quick Reference

```bash
# API validation only
lovec tools/validators/validate_mod.lua mods/core --verbose

# Content validation only
lovec tools/validators/validate_content.lua mods/core --verbose

# Both with JSON output
lovec tools/validators/validate_mod.lua mods/core --json > api.json
lovec tools/validators/validate_content.lua mods/core --json > content.json

# Validate all mods
for mod in mods/*/; do
  echo "Validating $mod..."
  lovec tools/validators/validate_mod.lua "$mod"
done

# Validate specific category
lovec tools/validators/validate_mod.lua mods/core --category units
lovec tools/validators/validate_content.lua mods/core --category research

# Save detailed report
lovec tools/validators/validate_mod.lua mods/core --verbose --output report.txt
```

---

**Last Updated:** October 24, 2025  
**Status:** Complete and Production-Ready  
**Maintainer:** AlienFall Team
