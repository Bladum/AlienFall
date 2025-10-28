# Mod Validator - User Guide

**Status:** ✅ Complete
**Version:** 1.0.0
**Purpose:** Automatically validate mod TOML files against GAME_API.toml schema

---

## Overview

The mod validator is an automated tool that checks every TOML file in your mod against the official GAME_API.toml schema. It catches errors before your mod ever runs in the game.

### What It Validates

✅ **File Organization:** Ensures files are in correct locations
✅ **File Naming:** Validates filename conventions
✅ **TOML Syntax:** Checks for valid TOML format
✅ **Required Fields:** Ensures all mandatory fields are present
✅ **Field Types:** Validates each field has correct data type
✅ **Enum Values:** Checks that enum fields use only valid values
✅ **Numeric Constraints:** Verifies numbers are within min/max ranges
✅ **Field Patterns:** Validates strings match required patterns
✅ **Unknown Fields:** Warns about fields not in schema

### What It Doesn't Validate

- ❌ Cross-references (does your weapon actually exist?)
- ❌ Asset files (do sprite files exist?)
- ❌ Game balance (is damage value too high?)
- ❌ Mod compatibility (conflicts with other mods)

---

## Installation

The validator is included in `tools/validators/`. No additional installation needed.

**Requirements:**
- Love2D 12.0+ with Lua TOML support
- `api/GAME_API.toml` schema file (required)

---

## Basic Usage

### Run Validator on Entire Mod

```bash
lovec tools/validators/validate_mod.lua mods/core
```

This validates all `.toml` files in the `mods/core` folder against the schema.

### Output

```
=== Mod Validation Report ===

Summary:
  Files checked: 45
  Files valid: 42
  Files with errors: 3
  Files with warnings: 5
  Total errors: 7
  Total warnings: 8

Details:

✓ mods/core/rules/units/soldiers.toml
    All checks passed

✗ mods/core/rules/items/laser_rifle.toml
    ERROR [damage]: Type mismatch: expected integer, got string
    ERROR [fire_rate]: Value 0.05 is below minimum 0.5

✓ mods/core/rules/crafts/skyranger.toml
    All checks passed

=== Result ===
❌ VALIDATION FAILED - 7 error(s) found
```

---

## Command-Line Options

### `--verbose` - Show all files

```bash
lovec tools/validators/validate_mod.lua mods/core --verbose
```

Shows results for every file, including those that passed validation.

### `--json` - JSON output

```bash
lovec tools/validators/validate_mod.lua mods/core --json
```

Outputs machine-readable JSON for integration with other tools or CI/CD:

```json
{
  "summary": {
    "filesChecked": 45,
    "filesValid": 42,
    "filesWithErrors": 3,
    "filesWithWarnings": 5,
    "totalErrors": 7,
    "totalWarnings": 8
  },
  "files": [
    {
      "path": "mods/core/rules/items/laser_rifle.toml",
      "category": "items",
      "valid": false,
      "errors": [
        {
          "field": "damage",
          "message": "Type mismatch: expected integer, got string"
        }
      ]
    }
  ]
}
```

### `--markdown` - Markdown report

```bash
lovec tools/validators/validate_mod.lua mods/core --markdown
```

Generates markdown report suitable for documentation or CI artifacts.

### `--category <name>` - Validate specific type

```bash
lovec tools/validators/validate_mod.lua mods/core --category units
```

Only validate files in a specific category. Valid categories:
- `units` - Unit definitions
- `items` - Items and equipment
- `crafts` - Aircraft definitions
- `facilities` - Base facilities
- `research` - Research projects
- `manufacturing` - Production recipes
- `missions` - Mission definitions
- `aliens` - Alien species
- `geoscape` - World map regions
- `economy` - Economic data
- `lore` - Lore entries

### `--schema <path>` - Custom schema path

```bash
lovec tools/validators/validate_mod.lua mods/core --schema custom_schema.toml
```

Uses a different schema file instead of `api/GAME_API.toml`.

### `--output <file>` - Save report

```bash
lovec tools/validators/validate_mod.lua mods/core --output validation_report.json
```

Writes report to file instead of console.

---

## Common Errors and Fixes

### "Type mismatch: expected integer, got string"

**Problem:** You used quotes around a number.

**Wrong:**
```toml
damage = "25"
```

**Fix:** Remove quotes for numbers.
```toml
damage = 25
```

### "Invalid enum value 'soilder', valid: soldier, alien, civilian"

**Problem:** Typo in enum value.

**Wrong:**
```toml
unit_type = "soilder"
```

**Fix:** Check spelling in GAME_API.toml for valid values.
```toml
unit_type = "soldier"
```

### "Value 5.5 is below minimum 1"

**Problem:** Field value violates min/max constraint.

**Wrong:**
```toml
tier = 0  # minimum is 1
```

**Fix:** Use a valid value within range.
```toml
tier = 1  # valid: 1-5
```

### "Required field missing: id"

**Problem:** You didn't include a required field.

**Wrong:**
```toml
[[unit_class]]
name = "Rifleman"
# missing id!
```

**Fix:** Add the required field.
```toml
[[unit_class]]
id = "rifleman"
name = "Rifleman"
```

### "Filename does not match required pattern"

**Problem:** Filename doesn't follow naming conventions.

**Wrong:**
```
My-Cool-Item.toml
```

**Fix:** Use snake_case (lowercase with underscores).
```
my_cool_item.toml
```

---

## Validation Rules

### Field Naming (IDs)

All `id` fields must match this pattern: `^[a-z0-9_]+$`

- ✅ Valid: `rifle_standard`, `unit_class_1`, `x`
- ❌ Invalid: `Rifle-Standard`, `Unit.Class`, `unit class`

### Field Types

Each field has a specific type:

**string** - Text value
```toml
name = "Rifle"
```

**integer** - Whole number
```toml
damage = 25
armor = 10
```

**float** - Decimal number
```toml
fire_rate = 1.5
accuracy = 0.75
```

**boolean** - true/false
```toml
is_stackable = true
is_craftable = false
```

**enum** - One of a fixed set of values
```toml
unit_type = "soldier"  # must be: soldier, alien, civilian, etc.
```

**array** - List of values
```toml
abilities = ["run", "aim", "sneak"]
```

**table** - Nested object
```toml
[unit_class.stats]
health = 65
accuracy = 70
```

### Min/Max Constraints

Numeric fields have valid ranges:

```toml
damage = 25        # OK: in valid range
tier = 0           # ERROR: minimum is 1
armor = 9999999    # ERROR: maximum is 30
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
- name: Validate Mods
  run: |
    lovec tools/validators/validate_mod.lua mods/core --json > validation.json
    if [ $? -ne 0 ]; then
      echo "Mod validation failed"
      cat validation.json
      exit 1
    fi
```

### Local Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
lovec tools/validators/validate_mod.lua mods/core
if [ $? -ne 0 ]; then
  echo "Commit blocked: Mod validation failed"
  exit 1
fi
```

---

## Using in VS Code

### Add to tasks.json

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

Then run: **Ctrl+Shift+P** → **Run Task** → **VALIDATE: Core Mod**

---

## Understanding GAME_API.toml

The validator uses `api/GAME_API.toml` as its reference. Each entity type has a schema:

```toml
[api.units.unit_class.fields]
id = { type = "string", required = true, pattern = "^[a-z0-9_]+$", description = "..." }
damage = { type = "integer", required = true, min = 1, max = 150, description = "..." }
fire_rate = { type = "float", required = false, default = 1.0, min = 0.5, max = 3.0 }
unit_type = { type = "enum", required = true, values = ["soldier", "alien", "civilian"], description = "..." }
```

Field properties:

- **type** - Expected data type
- **required** - Must field always be present?
- **default** - Value if field is omitted
- **min/max** - Valid range for numbers
- **values** - Valid options for enums
- **pattern** - Regex validation for strings
- **references** - Foreign key to another entity

For complete schema documentation, see `api/GAME_API_GUIDE.md`.

---

## Troubleshooting

### "TOML parser not found"

**Problem:** Lua TOML library isn't installed.

**Fix:** Make sure you're running with `lovec` (Love2D) which includes TOML support.

```bash
# Correct
lovec tools/validators/validate_mod.lua mods/core

# Wrong - don't use plain lua
lua tools/validators/validate_mod.lua mods/core
```

### No files found

**Problem:** Validator couldn't find TOML files.

**Check:**
- Is mod path correct? `mods/core` not `mods\core`
- Are TOML files in `rules/` subdirectory?
- Do files have `.toml` extension (lowercase)?

### Validator hangs

**Problem:** Scanning very large mod or file system issue.

**Fix:** Validate specific category instead:
```bash
lovec tools/validators/validate_mod.lua mods/core --category units
```

---

## Performance

Typical validation times:

- **Small mod** (50-100 files): < 1 second
- **Medium mod** (200-500 files): 2-5 seconds
- **Large mod** (1000+ files): 10-30 seconds

---

## Reporting Issues

If validator gives false positives or misses errors:

1. Collect the validation report:
   ```bash
   lovec tools/validators/validate_mod.lua mods/core --json > report.json
   ```

2. Check the specific error message and TOML file

3. Compare with schema: `api/GAME_API.toml`

4. Report issue with the report.json attached

---

## Future Enhancements

Planned features not yet implemented:

- [ ] Cross-reference validation (units reference valid techs)
- [ ] Asset validation (sprite files exist)
- [ ] Balance checking (damage values reasonable)
- [ ] Auto-fix mode (automatically fix common errors)
- [ ] IDE real-time validation (live editor feedback)
- [ ] Performance profiling (identify slow loads)

---

## Related Documentation

- **Schema Guide:** `api/GAME_API_GUIDE.md`
- **Modding Guide:** `api/MODDING_GUIDE.md`
- **Schema File:** `api/GAME_API.toml`
- **Sync Guide:** `api/SYNCHRONIZATION_GUIDE.md`

---

## Quick Reference

```bash
# Validate everything
lovec tools/validators/validate_mod.lua mods/core

# Show all details
lovec tools/validators/validate_mod.lua mods/core --verbose

# JSON output for CI
lovec tools/validators/validate_mod.lua mods/core --json

# Only units
lovec tools/validators/validate_mod.lua mods/core --category units

# Save report
lovec tools/validators/validate_mod.lua mods/core --output report.json

# Custom schema
lovec tools/validators/validate_mod.lua mods/core --schema my_schema.toml
```
