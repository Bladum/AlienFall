# Mods - Organizing Five Distinct Mods

**Status:** In Progress
**Created:** 2025-10-24

---

## Overview

This directory contains five distinct mods for AlienFall, each serving a specific purpose:

1. **core** - Production mod with complete, balanced game content
2. **messy_mod** - Deliberately broken for testing validators
3. **synth_mod** - Auto-generated with complete API coverage
4. **legacy** - Archived historical content for reference
5. **minimal_mod** - Bare minimum content for quick testing

---

## Mod Directory Structure

```
mods/
├── core/              ✅ Production mod (complete, balanced)
│   ├── mod.toml
│   ├── README.md
│   ├── rules/
│   ├── assets/
│   └── ...
│
├── messy_mod/         🔴 Test/broken mod (for validator testing)
│   ├── mod.toml
│   ├── README.md
│   ├── ERROR_LIST.md
│   ├── rules/
│   └── assets/
│
├── synth_mod/         🤖 Synthetic/generated mod (100% API coverage)
│   ├── mod.toml
│   ├── README.md
│   ├── rules/
│   └── assets/
│
├── legacy/            📦 Archive/reference mod (disabled by default)
│   ├── mod.toml
│   ├── README.md
│   ├── ARCHIVE_INDEX.md
│   └── rules/
│
├── minimal_mod/       ⚡ Bare minimum mod (fast testing)
│   ├── mod.toml
│   ├── README.md
│   ├── rules/
│   └── assets/
│
└── README.md          ← This file
```

---

## Mod Purposes

### core - Production Mod ✅

**Purpose:** Complete, production-ready game content

**Content:**
- All unit types (soldiers, aliens, civilians)
- All item/weapon types
- Complete research tree
- Balanced for enjoyable gameplay
- High-quality sprites and audio
- Well-documented and maintained

**Usage:**
- Default mod for normal gameplay
- Reference for mod creators
- Template for custom mods

**Location:** `mods/core/`

### messy_mod - Broken Test Mod 🔴

**Purpose:** Deliberately broken to test validators

**Errors Include:**
- Wrong field types
- Missing required fields
- Invalid enum values
- Broken entity references
- Missing asset files
- Circular tech dependencies
- Out-of-range values
- Malformed TOML

**Usage:**
- Test API validator (validate_mod.lua)
- Test content validator (validate_content.lua)
- Verify validators catch errors

**Location:** `mods/messy_mod/`

### synth_mod - Synthetic Mod 🤖

**Purpose:** Auto-generated complete API coverage

**Content:**
- All entity types from GAME_API
- All field types and enum values
- Valid structure and references
- Not balanced for gameplay
- Clear synthetic labels

**Usage:**
- Integration testing
- Ensure engine handles all API definitions
- Example data for mod creators
- API coverage verification

**Location:** `mods/synth_mod/`

### legacy - Archive Mod 📦

**Purpose:** Historical reference and old content

**Content:**
- Version 0.1 content (original)
- Deprecated systems
- Experimental content
- Old balance data

**Usage:**
- Historical reference only
- Understanding design evolution
- Disabled by default in game

**Location:** `mods/legacy/`

### minimal_mod - Bare Minimum Mod ⚡

**Purpose:** Absolute minimum to run game

**Content:**
- 1 soldier unit type
- 1 alien unit type
- 1 weapon
- 1 armor
- 1 craft
- 1 facility
- 1 mission type
- 1 research project

**Usage:**
- Quick testing
- Fast loading
- Debugging
- Engine development

**Location:** `mods/minimal_mod/`

---

## Migration Status

### Current State

- `core/` → Will become **core** mod (production)
- `examples/complete/` → Merge into **core**
- `examples/minimal/` → Become **minimal_mod**
- `new/` → Content for **core** or **synth_mod**

### Next Steps

1. ✅ Audit current content
2. ⏳ Create **minimal_mod** from examples/minimal/
3. ⏳ Consolidate **core** mod
4. ⏳ Create **messy_mod** (broken test mod)
5. ⏳ Generate **synth_mod** (auto-generated)
6. ⏳ Create **legacy** mod (archive)
7. ⏳ Validate all mods
8. ⏳ Update documentation

---

## Mod Metadata (mod.toml)

Each mod must have a `mod.toml` file:

```toml
[mod]
id = "core"
name = "AlienFall Core Content"
version = "1.0.0"
author = "AlienFall Team"
description = "Official core content mod. Complete, balanced gameplay experience."

[load_order]
priority = 0  # Load first

[compatibility]
game_version = ">=1.0.0"

[tags]
tags = ["official", "complete", "balanced"]
```

---

## Validation

All mods (except legacy) should pass validation:

```bash
# API validation
lovec tools/validators/validate_mod.lua mods/core

# Content validation
lovec tools/validators/validate_content.lua mods/core

# Both should pass
```

---

## Using Mods

### Load Specific Mod

The game loads the **core** mod by default. To use different mods, edit game config or mod manager.

### Enable/Disable Mods

Edit `mod.toml`:

```toml
[mod]
enabled = true   # Enabled
enabled = false  # Disabled
```

### Load Order

Mods load by priority (lower numbers first):

```
legacy:           priority = 999 (last, optional)
synth_mod:        priority = 50  (test)
core:             priority = 0   (first)
minimal_mod:      priority = 0   (first alternative)
messy_mod:        priority = 999 (never load)
```

---

## Documentation

Each mod has its own documentation:

| Mod | README | Purpose |
|-----|--------|---------|
| **core** | `core/README.md` | Production content guide |
| **messy_mod** | `messy_mod/README.md` + `ERROR_LIST.md` | Validator test guide |
| **synth_mod** | `synth_mod/README.md` | Generation info |
| **legacy** | `legacy/README.md` + `ARCHIVE_INDEX.md` | Archive index |
| **minimal_mod** | `minimal_mod/README.md` | Minimal content guide |

---

## Maintenance

### Update Core Mod

When adding new content:

1. Create TOML file in `mods/core/rules/[category]/`
2. Run validators
3. Add asset files to `mods/core/assets/`
4. Update `core/README.md` if needed

### Update Synth Mod

Regenerate when API changes:

```bash
lovec tools/generators/generate_mock_data.lua \
  --output mods/synth_mod \
  --coverage \
  --seed 12345
```

### Archive Old Content

Move old content to legacy:

1. Move TOML files to `mods/legacy/rules/v[version]_content/`
2. Document in `legacy/ARCHIVE_INDEX.md`
3. Disable legacy mod by default

---

## Quick Reference

```bash
# Validate core mod
lovec tools/validators/validate_mod.lua mods/core
lovec tools/validators/validate_content.lua mods/core

# Run game with core mod
lovec engine

# List all mods
ls -la mods/

# Check mod structure
tree mods/core/rules/

# Validate all mods
for mod in mods/*/; do
  echo "Validating $mod..."
  lovec tools/validators/validate_mod.lua "$mod"
done
```

---

## Related Files

- `api/GAME_API.toml` - Schema for all mods
- `api/MODDING_GUIDE.md` - How to create mods
- `tools/validators/validate_mod.lua` - API validator
- `tools/validators/validate_content.lua` - Content validator
- `docs/IDE_SETUP.md` - Setup for mod development

---

**Status:** Initial organization complete, implementing individual mods next
