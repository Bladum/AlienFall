# Content Validator - User Guide

**Status:** ✅ Complete
**Version:** 1.0.0
**Purpose:** Validate mod content for internal consistency and integrity

---

## Overview

The content validator checks if all references within a mod point to existing entities and if all referenced asset files actually exist. It complements the schema validator (`validate_mod.lua`) by checking consistency across entities rather than individual entity structure.

### What It Validates

✅ **Entity References:** Units → Items, Research → Techs, etc.
✅ **Cross-category References:** All links between entity types
✅ **Asset Files:** Sprite images, audio files, maps, etc. actually exist
✅ **Tech Tree Structure:** No circular dependencies, no orphaned techs
✅ **Balance Sanity:** Suspicious values (zero damage, negative health, etc.)

### What It Doesn't Validate

- ❌ TOML syntax or structure (use `validate_mod.lua` for this)
- ❌ Field types or required fields (use `validate_mod.lua`)
- ❌ Mod compatibility or conflicts with other mods
- ❌ Gameplay balance (only sanity checks for obviously wrong values)

### Difference from API Validator

| Aspect | API Validator (`validate_mod.lua`) | Content Validator (`validate_content.lua`) |
|--------|-----|-----|
| **Checks** | Individual entity structure | References between entities |
| **Validates Against** | GAME_API.toml schema | Mod content itself |
| **Error Example** | "Field 'damage' type is wrong" | "Unit requires non-existent tech" |

---

## Basic Usage

### Run Content Validator on Entire Mod

```bash
lovec tools/validators/validate_content.lua mods/core
```

### Output Example

```
======================================================================
Content Validator - Checking Mod Internal Consistency
======================================================================

Mod Path: mods/core

Loading mod content...
Loaded 127 entities

Validating entity references...
  Found 0 reference errors
Validating asset files...
  Found 2 missing assets
Validating tech tree...
  Found 1 circular dependency, 0 warnings
Running balance sanity checks...
  Found 5 balance warnings

======================================================================
VALIDATION SUMMARY
======================================================================

Total entities checked: 127
Total errors found: 3
Total warnings found: 5

======================================================================
ERRORS (3)
======================================================================

MISSING_ASSET (2 errors)
  1. Referenced asset file does not exist: assets/sprites/alien_elite.png
     Entity: alien_elite_soldier
     Field: sprite

CIRCULAR_DEPENDENCY (1 error)
  1. Circular dependency detected: laser_weapons -> advanced_energy -> laser_weapons

======================================================================
✅ CONTENT VALIDATION PASSED
⚠️  5 warning(s) found (review recommended)
======================================================================
```

---

## Command-Line Options

### `--verbose` - Show detailed output

```bash
lovec tools/validators/validate_content.lua mods/core --verbose
```

Shows all warnings and more detailed error information.

### `--json` - JSON output

```bash
lovec tools/validators/validate_content.lua mods/core --json
```

Outputs machine-readable JSON for CI/CD integration.

### `--markdown` - Markdown output

```bash
lovec tools/validators/validate_content.lua mods/core --markdown
```

Generates markdown-formatted report.

### `--skip-assets` - Skip asset validation

```bash
lovec tools/validators/validate_content.lua mods/core --skip-assets
```

Only validate references, skip checking if asset files exist.

### `--only-assets` - Only validate assets

```bash
lovec tools/validators/validate_content.lua mods/core --only-assets
```

Only check if referenced asset files exist, skip other checks.

### `--category <name>` - Validate specific category

```bash
lovec tools/validators/validate_content.lua mods/core --category research
```

Only validate specific entity categories.

### `--output <file>` - Save report

```bash
lovec tools/validators/validate_content.lua mods/core --output report.txt
```

Writes report to file instead of console.

---

## Validation Categories

### Reference Validation

Checks that all entity references point to existing entities:

| Entity Type | Checks |
|---|---|
| **Units** | race, armor, starting_equipment, required_tech, default_weapon |
| **Items** | required_tech, ammo reference, craft |
| **Research** | prerequisites, unlocked_items, unlocked_units |
| **Manufacturing** | produced_item, required_items, required_tech |
| **Facilities** | required_tech, required_items |
| **Missions** | map, alien_units, loot_items |
| **Crafts** | weapons, equipment |
| **Aliens** | weapon, armor |

### Asset Validation

Checks that referenced files exist:

| Asset Type | Extensions | Example |
|---|---|---|
| **Sprites** | .png, .jpg, .jpeg | `assets/sprites/soldier.png` |
| **Audio** | .ogg, .wav, .mp3, .flac | `assets/audio/rifle_fire.ogg` |
| **Maps** | .map, .lua | `assets/maps/test_map.lua` |
| **Tilesets** | .png | `assets/tilesets/terrain.png` |
| **Models** | .obj, .fbx, .gltf | `assets/models/unit.obj` |
| **Fonts** | .ttf, .otf | `assets/fonts/font.ttf` |

### Tech Tree Validation

Checks research technology tree structure:

- **No Circular Dependencies:** Tech A → Tech B → Tech A is invalid
- **No Orphaned Techs:** All techs must be reachable from starting techs
- **Valid Prerequisites:** All required techs must exist in mod

**Example Circular Dependency (ERROR):**
```toml
# laser_weapons.toml
requires = ["advanced_energy"]

# advanced_energy.toml
requires = ["laser_weapons"]  # Circle!
```

### Balance Validation

Sanity checks for obviously wrong values (warnings only):

| Entity Type | Checks |
|---|---|
| **Units** | Health > 0, Time Units > 0, Armor >= 0 |
| **Weapons** | Damage > 0, Fire Rate > 0, Ammo Capacity > 0 |
| **Items** | Cost >= 0, Weight >= 0 |
| **Research** | Time > 0 (unless instant intended), Cost >= 0 |
| **Manufacturing** | Time > 0, Cost >= 0 |
| **Facilities** | Build Time >= 0, Capacities > 0 |

---

## Common Errors and Solutions

### "Referenced asset file does not exist"

**Problem:** Sprite/audio file referenced in entity doesn't exist.

**Solution:**
1. Check file path in TOML matches actual file location
2. Verify file is in correct asset folder
3. Check file extension is correct
4. Use forward slashes in path: `assets/sprites/unit.png`

**Example:**
```toml
# ❌ Wrong - file doesn't exist
sprite = "assets/sprites/missing_file.png"

# ✅ Correct - file exists
sprite = "assets/sprites/soldier_01.png"
```

### "Circular dependency detected"

**Problem:** Research prerequisites form a loop.

**Solution:**
1. Identify the cycle in error message
2. Remove one dependency to break cycle
3. Add intermediate techs if needed

**Example:**
```toml
# ❌ Circular
# laser_weapons requires advanced_energy
# advanced_energy requires laser_weapons

# ✅ Fixed - add intermediate tech
# laser_weapons requires early_energy
# advanced_energy requires laser_weapons
```

### "Non-existent reference"

**Problem:** Entity references another that doesn't exist.

**Solution:**
1. Check entity ID is correct (typo?)
2. Verify entity exists in correct category
3. Use correct entity ID format (snake_case)

**Example:**
```toml
# ❌ Wrong - typo
requires = ["soilder"]

# ✅ Correct
requires = ["soldier"]
```

### "Unit has zero or negative health"

**Problem:** Unit's health stat is <= 0.

**Solution:**
- Set health to positive value
- Check if this is debug unit that should be removed

**Example:**
```toml
# ❌ Wrong - will die instantly
health = 0

# ✅ Correct
health = 65
```

### "Weapon has zero damage"

**Problem:** Weapon's damage stat is 0.

**Solution:**
- Set damage to positive value
- Check if weapon is placeholder that should be removed

**Example:**
```toml
# ❌ Wrong - useless weapon
damage = 0

# ✅ Correct
damage = 25
```

---

## Using in CI/CD

### GitHub Actions Example

```yaml
- name: Validate Mod Content
  run: |
    lovec tools/validators/validate_content.lua mods/core --json > validation.json
    if [ $? -ne 0 ]; then
      echo "❌ Content validation failed"
      exit 1
    fi
    echo "✅ Content validation passed"
    
- name: Report Validation Results
  if: always()
  run: |
    cat validation.json | jq '.summary'
```

---

## Using in VS Code

### Add to .vscode/tasks.json

```json
{
  "label": "🔍 VALIDATE: Content - Core Mod",
  "type": "shell",
  "command": "C:\\Program Files\\LOVE\\lovec.exe",
  "args": [
    "tools/validators/validate_content.lua",
    "mods/core",
    "--verbose"
  ],
  "group": "test",
  "presentation": {
    "reveal": "always",
    "panel": "new"
  }
}
```

Run with: **Ctrl+Shift+P** → **Run Task** → **VALIDATE: Content - Core Mod**

---

## Troubleshooting

### "Failed to load mod"

**Problem:** Validator can't read TOML files.

**Fix:**
- Ensure mod path is correct: `mods/core` not `mods\core`
- Check TOML files use `.toml` extension (lowercase)
- Verify TOML syntax is valid

### No reference errors but game crashes

**Problem:** References seem valid but missing at runtime.

**Possible causes:**
- Asset file not loaded into mod
- Reference in nested structure not checked
- Typo in ID across files

### Asset validation finds false positives

**Problem:** Files exist but validator says they're missing.

**Fix:**
- Check relative paths use forward slashes: `assets/sprites/file.png`
- Verify file paths are relative to mod directory
- Ensure files aren't in ignored folders

---

## Performance

Typical validation times:

- **Small mod** (100 entities): < 1 second
- **Medium mod** (300 entities): 2-5 seconds
- **Large mod** (1000+ entities): 10-30 seconds

For large mods, use `--skip-assets` or `--category` to speed up validation:

```bash
# Skip slower asset checks
lovec tools/validators/validate_content.lua mods/core --skip-assets

# Check only specific category
lovec tools/validators/validate_content.lua mods/core --category units
```

---

## Running Both Validators

For complete mod validation, run both validators:

```bash
# 1. Check structure and syntax (API validator)
lovec tools/validators/validate_mod.lua mods/core

# 2. Check content consistency (Content validator)
lovec tools/validators/validate_content.lua mods/core

# Both pass = mod is ready
```

---

## Related Documentation

- **API Validator Guide:** See `tools/validators/README.md`
- **API Schema Guide:** `api/GAME_API_GUIDE.md`
- **Modding Guide:** `api/MODDING_GUIDE.md`
- **API Schema File:** `api/GAME_API.toml`

---

## Quick Reference

```bash
# Basic validation
lovec tools/validators/validate_content.lua mods/core

# Verbose output
lovec tools/validators/validate_content.lua mods/core --verbose

# JSON output for CI
lovec tools/validators/validate_content.lua mods/core --json

# Skip asset checking (faster)
lovec tools/validators/validate_content.lua mods/core --skip-assets

# Only check assets
lovec tools/validators/validate_content.lua mods/core --only-assets

# Check specific category
lovec tools/validators/validate_content.lua mods/core --category research

# Save report to file
lovec tools/validators/validate_content.lua mods/core --output report.txt

# Combine options
lovec tools/validators/validate_content.lua mods/core --verbose --json --output report.json
```
