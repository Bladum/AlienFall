# Task: Cleanup and Organize All Mods

**Status:** TODO
**Priority:** High
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

**Dependencies:**
- TASK-001 (GAME_API.toml must exist)
- TASK-002 (validation tools must exist)
- TASK-003 (mock data generator must exist)

---

## Overview

Cleanup and reorganize all mod folders to create a clear, purpose-driven mod structure. Create five distinct mods: messy_mod (deliberately broken for testing), synth_mod (synthetic data covering all API), core (production content), legacy (reference), and minimal_mod (bare minimum to run game).

---

## Purpose

**Why this is needed:**
- Current mod content is disorganized
- Mixed quality content
- Hard to test validators
- No complete API coverage test
- No minimal test case
- Legacy content clutters main mod
- Unclear which mod to use for what purpose

**What problem it solves:**
- Clear mod purposes
- Test mod for validators (deliberately broken)
- Synthetic mod for API coverage testing
- Clean production mod with quality content
- Legacy mod for historical reference
- Minimal mod for quick testing
- Better mod organization

---

## Requirements

### Functional Requirements

#### messy_mod (Test/Broken Mod)
- [ ] Deliberately broken in multiple ways
- [ ] API validation errors (wrong types, missing fields)
- [ ] Content validation errors (broken references)
- [ ] Missing asset files
- [ ] Circular tech dependencies
- [ ] Orphaned content
- [ ] Balance issues (zero damage weapons, etc.)
- [ ] File location errors
- [ ] File naming errors
- [ ] Must fail ALL validators
- [ ] Comprehensive test coverage for validators

#### synth_mod (Synthetic/Generated Mod)
- [ ] Generated from GAME_API.toml (TASK-003)
- [ ] 100% API coverage
- [ ] All entity types present
- [ ] All field types used
- [ ] All enum values tested
- [ ] Valid structure
- [ ] Valid references
- [ ] Pass all validators
- [ ] Not balanced for gameplay
- [ ] Clear auto-generated labels

#### core (Production Mod)
- [ ] Clean, quality content only
- [ ] Matches LORE and story
- [ ] Balanced for gameplay
- [ ] Complete for full game experience
- [ ] Pass all validators
- [ ] Well-organized
- [ ] Comprehensive documentation
- [ ] Production-ready

#### legacy (Reference Mod)
- [ ] Archive of old content
- [ ] Historical reference only
- [ ] Not loaded by default
- [ ] Not guaranteed to work
- [ ] Documentation explains purpose
- [ ] Organized by creation date

#### minimal_mod (Bare Minimum Mod)
- [ ] Absolute minimum to run game
- [ ] One of each required entity type
- [ ] Fast to load
- [ ] For quick testing
- [ ] Pass all validators
- [ ] Minimal content only

### Technical Requirements
- [ ] Each mod in separate folder
- [ ] Each mod has mod.toml metadata
- [ ] Each mod has README.md
- [ ] Proper folder structure (rules/, assets/)
- [ ] All mods validate correctly (except messy_mod)
- [ ] Clear documentation

### Acceptance Criteria
- [ ] All five mods exist
- [ ] Each mod serves clear purpose
- [ ] messy_mod breaks validators as intended
- [ ] synth_mod covers 100% of API
- [ ] core mod is production-ready
- [ ] legacy mod archived properly
- [ ] minimal_mod runs game
- [ ] Documentation explains each mod
- [ ] Team approves mod structure

---

## Plan

### Step 1: Audit Current Mod Content
**Description:** Survey all existing mod content

**Current state:**
```
mods/
├── core/              -- Main mod, mixed quality
├── examples/          -- Some example content
└── (possibly others)
```

**Analysis needed:**
- List all entities in core mod
- Categorize by quality (good, fixable, remove)
- Identify LORE-appropriate content
- Identify balanced content
- Identify incomplete content
- Identify legacy/test content

**Tool to create:** `tools/mods/audit_mod_content.lua`

**Output:** `temp/mod_content_audit.md`

**Format:**
```markdown
# Mod Content Audit

## Current Mods

### mods/core/

#### Units (42 entities)
**Quality:**
- Excellent (12): soldier, heavy, scout, medic, ...
- Good (15): alien_trooper, alien_leader, ...
- Needs work (8): civilian_1, civilian_2, ...
- Legacy/Remove (7): test_unit, debug_soldier, ...

**LORE Compliance:**
- Compliant (30): Fits game story
- Non-compliant (12): Doesn't match lore

**Balance:**
- Balanced (25): Reasonable stats
- Unbalanced (10): OP or useless
- Untested (7): No gameplay data

#### Items (68 entities)
... (similar analysis)

#### Research (35 entities)
... (similar analysis)

... (continue for all categories)

## Recommendations

### Keep in core
- soldier, heavy, scout, medic (well-designed, balanced)
- laser_rifle, plasma_rifle (core weapons)
- ... (list all)

### Move to legacy
- test_unit, debug_soldier (test content)
- old_weapon_v1 (superseded)
- ... (list all)

### Remove entirely
- broken_entity_1 (incomplete)
- ... (list all)

### Needs rework
- civilian_1 (lacks stats)
- ... (list all)
```

**Estimated time:** 6-8 hours

---

### Step 2: Create messy_mod (Broken Test Mod)
**Description:** Create deliberately broken mod for validator testing

**Process:**
1. Create mod structure
2. Add various types of errors
3. Document each error type
4. Verify validators catch errors

**Errors to include:**

**API Validation Errors:**
- Wrong field types (string instead of integer)
- Missing required fields
- Invalid enum values
- Out-of-range numeric values
- Unknown fields
- Malformed TOML syntax

**Content Validation Errors:**
- Broken references (unit requires non-existent tech)
- Missing asset files (sprite references that don't exist)
- Circular tech dependencies
- Orphaned entities (unreachable tech)

**File Organization Errors:**
- Files in wrong folders
- Incorrect file naming

**Balance Issues:**
- Zero damage weapons
- Zero health units
- Negative costs
- Instant research (0 time)

**Folder structure:**
```
mods/messy_mod/
├── mod.toml
├── README.md
├── ERROR_LIST.md (documents all errors)
├── rules/
│   ├── units/
│   │   ├── wrong_type.toml (type field is number instead of enum)
│   │   ├── missing_required.toml (missing 'name' field)
│   │   ├── invalid_enum.toml (type = "soilder" instead of "soldier")
│   │   ├── broken_reference.toml (requires "tech_doesnt_exist")
│   │   └── zero_health.toml (health = 0)
│   ├── items/
│   │   ├── wrong_location.toml (should be in weapons/)
│   │   ├── zero_damage.toml (damage = 0)
│   │   └── missing_asset.toml (sprite = "sprite_doesnt_exist.png")
│   ├── research/
│   │   ├── circular_dep_1.toml (requires circular_dep_2)
│   │   ├── circular_dep_2.toml (requires circular_dep_1)
│   │   └── instant_research.toml (time = 0)
│   └── (other categories with various errors)
└── assets/
    └── (deliberately missing some referenced files)
```

**ERROR_LIST.md:**
```markdown
# messy_mod Error Catalog

This mod is DELIBERATELY BROKEN for testing validators.

## Purpose
Test that validators catch all error types.

## Errors by Category

### API Validation Errors

1. `units/wrong_type.toml`
   - **Error:** Field 'type' is integer instead of string
   - **Expected:** API validator error on type mismatch

2. `units/missing_required.toml`
   - **Error:** Missing required field 'name'
   - **Expected:** API validator error on missing field

3. `units/invalid_enum.toml`
   - **Error:** Invalid enum value 'soilder' (typo)
   - **Expected:** API validator error on invalid enum

... (document all errors)

## Expected Validator Results

### API Validator (TASK-002)
Should find: X errors
- Type mismatches: 5
- Missing required fields: 3
- Invalid enums: 4
- Out of range values: 2

### Content Validator (TASK-004)
Should find: Y errors
- Broken references: 6
- Missing assets: 4
- Circular dependencies: 2
- Orphaned content: 3

## Usage

```bash
# Test API validator
lovec tools/validators/validate_mod.lua mods/messy_mod
# Expected: X errors found

# Test content validator
lovec tools/validators/validate_content.lua mods/messy_mod
# Expected: Y errors found
```
```

**Estimated time:** 8-10 hours

---

### Step 3: Generate synth_mod (Synthetic Mod)
**Description:** Use mock data generator to create complete API coverage mod

**Process:**
```bash
# Run generator with coverage strategy
lovec tools/generators/generate_mock_data.lua \
  --output mods/synth_mod \
  --strategy coverage \
  --seed 12345
```

**Enhancements:**
- Add comprehensive README.md
- Document that it's auto-generated
- Explain coverage goals
- Add generation metadata
- Validate it passes all validators

**README.md:**
```markdown
# synth_mod - Synthetic Data Mod

## Purpose

This mod is AUTO-GENERATED to provide 100% coverage of the GAME API.

**NOT for gameplay** - content is synthetic, not balanced.

## Generation Details

- **Generated:** 2025-10-24
- **Generator Version:** 1.0.0
- **Strategy:** Coverage (all API definitions)
- **Seed:** 12345 (reproducible)

## Contents

Complete coverage of all API entity types:
- Units: 20 entities (soldiers, aliens, civilians)
- Items: 30 entities (weapons, armor, equipment)
- Research: 40 entities (tech tree coverage)
- Facilities: 12 entities (all facility types)
- Missions: 15 entities (all mission types)
- Crafts: 10 entities (interceptors, transports)
- ... (complete list)

## Purpose

Used for:
- API validation testing
- Integration tests
- Ensuring engine handles all API definitions
- Example data for mod creators

## Validation

This mod MUST pass all validators:

```bash
# API validation
lovec tools/validators/validate_mod.lua mods/synth_mod
# Expected: ✅ PASS

# Content validation
lovec tools/validators/validate_content.lua mods/synth_mod
# Expected: ✅ PASS
```

## Regeneration

To regenerate this mod:

```bash
lovec tools/generators/generate_mock_data.lua \
  --output mods/synth_mod \
  --strategy coverage \
  --seed 12345
```
```

**Estimated time:** 3-4 hours (mostly validation and documentation)

---

### Step 4: Cleanup core Mod
**Description:** Create clean, production-ready core mod

**Process:**

1. **Load audit results** from Step 1
2. **Keep high-quality content:**
   - Well-designed entities
   - LORE-compliant
   - Balanced for gameplay
   - Complete and tested

3. **Remove/move:**
   - Test/debug content → delete or move to legacy
   - Unbalanced content → rework or remove
   - Non-LORE content → remove
   - Incomplete content → finish or remove
   - Legacy content → move to legacy mod

4. **Rework content:**
   - Fix balance issues
   - Complete incomplete entities
   - Update to match current LORE
   - Ensure internal consistency

5. **Organize:**
   - Proper folder structure
   - Consistent naming
   - Complete asset coverage
   - Documentation

**Target core mod structure:**
```
mods/core/
├── mod.toml
├── README.md
├── CONTENT_GUIDE.md (explains design philosophy)
├── rules/
│   ├── units/
│   │   ├── soldiers/
│   │   │   ├── soldier.toml
│   │   │   ├── heavy.toml
│   │   │   ├── scout.toml
│   │   │   └── medic.toml
│   │   ├── aliens/
│   │   │   ├── sectoid.toml
│   │   │   ├── muton.toml
│   │   │   └── ethereal.toml
│   │   └── civilians/
│   │       ├── civilian_male.toml
│   │       └── civilian_female.toml
│   ├── items/
│   │   ├── weapons/
│   │   │   ├── ballistic/
│   │   │   ├── laser/
│   │   │   └── plasma/
│   │   ├── armor/
│   │   └── equipment/
│   ├── research/
│   │   ├── early_game/
│   │   ├── mid_game/
│   │   └── late_game/
│   ├── facilities/
│   ├── crafts/
│   ├── missions/
│   ├── regions/
│   └── (other categories)
└── assets/
    ├── sprites/
    │   ├── units/
    │   ├── items/
    │   └── ui/
    ├── sounds/
    └── music/
```

**CONTENT_GUIDE.md:**
```markdown
# Core Mod Content Guide

## Design Philosophy

The core mod provides the complete, canonical AlienFall experience.

## Content Principles

1. **LORE Compliant:** All content fits the game story and universe
2. **Balanced:** Tested and balanced for enjoyable gameplay
3. **Complete:** No incomplete or placeholder content
4. **Polished:** High quality in all aspects
5. **Cohesive:** All content works together

## Content Organization

### Units

**Soldiers:**
- Rookies → Veterans → Elites progression
- Four classes: Soldier, Heavy, Scout, Medic
- Specialization through perks

**Aliens:**
- Three tiers matching game progression
- Early: Sectoids, Floaters
- Mid: Mutons, Snakemen
- Late: Chryssalids, Ethereals

**Civilians:**
- Non-combatants for terror missions
- Diverse representations

### Items

**Weapons:**
- Ballistic (early game): Rifles, pistols, shotguns
- Laser (mid game): Laser rifle, laser cannon
- Plasma (late game): Plasma rifle, heavy plasma

**Armor:**
- Progression: Jumpsuit → Personal Armor → Power Armor → Flying Armor

**Equipment:**
- Grenades, medkits, motion scanners, etc.

### Research

**Tech Tree:**
- Linear early game (tutorial)
- Branching mid game (player choice)
- Converging late game (final push)

**Prerequisites:**
- Clear prerequisites
- No circular dependencies
- Logical unlock progression

### Balance

All content is balanced using:
- Playtesting data
- Analytics feedback
- Community feedback
- Mathematical modeling

## Maintenance

This mod is actively maintained. Report issues:
- GitHub Issues
- Discord: #mod-core
```

**Estimated time:** 15-20 hours (cleanup, rework, validation)

---

### Step 5: Create legacy Mod
**Description:** Archive old/historical content

**Process:**
1. Collect all legacy content from audit
2. Organize by creation date or version
3. Document each item
4. Disable by default

**Structure:**
```
mods/legacy/
├── mod.toml (disabled by default)
├── README.md
├── ARCHIVE_INDEX.md
├── rules/
│   ├── v0.1_content/
│   │   ├── README.md (what was in v0.1)
│   │   └── (old entities)
│   ├── v0.2_content/
│   ├── deprecated/
│   │   ├── old_weapon_system/ (superseded)
│   │   └── old_unit_stats/ (changed)
│   └── experimental/
│       └── (experiments, tests)
└── assets/
    └── (old assets)
```

**README.md:**
```markdown
# legacy - Historical Archive Mod

## Purpose

This mod contains historical content for reference only.

**WARNING:** Content may not work with current game version.

## Contents

### Version Archives
- `v0.1_content/` - Original game content
- `v0.2_content/` - Second version content
- ... (chronological)

### Deprecated Systems
- `deprecated/old_weapon_system/` - Original weapon mechanics (superseded)
- `deprecated/old_unit_stats/` - Old stat system (changed in v0.5)

### Experimental
- `experimental/` - Tests and experiments (never released)

## Why Keep This?

- Historical reference
- Understanding design evolution
- Source for ideas
- Nostalgia

## Usage

**Do NOT enable this mod for gameplay.**

To browse content:
```bash
# Navigate and read files manually
cd mods/legacy/rules/
```

## Migration to Current

If you want to bring back old content:
1. Review current GAME_API
2. Update entity to match API
3. Rebalance for current game
4. Test thoroughly
5. Add to core mod
```

**ARCHIVE_INDEX.md:**
```markdown
# Legacy Mod Archive Index

## v0.1 Content (2023-01)

### Units
- `soldier_v1.toml` - Original soldier stats
  - Replaced by: `core/rules/units/soldiers/soldier.toml`
  - Changes: Stat system overhaul

... (detailed index)

## Deprecated Systems

### Old Weapon System (deprecated 2023-06)
- Files: `old_weapon_system/*.toml`
- Reason: Replaced with new damage calculation
- Migration guide: See `docs/weapon_system_migration.md`

... (continue)
```

**Estimated time:** 6-8 hours

---

### Step 6: Create minimal_mod
**Description:** Bare minimum content to run game

**Purpose:**
- Quick testing
- Fast load times
- Debugging
- Minimal complexity

**Content:**
- 1 soldier type
- 1 alien type
- 1 weapon
- 1 armor
- 1 craft
- 1 facility (hangar)
- 1 mission type
- 1 region
- 1 research project
- Minimal starting conditions

**Structure:**
```
mods/minimal_mod/
├── mod.toml
├── README.md
├── rules/
│   ├── units/
│   │   ├── soldier.toml (basic soldier)
│   │   └── alien.toml (basic alien)
│   ├── items/
│   │   ├── rifle.toml (basic weapon)
│   │   └── jumpsuit.toml (basic armor)
│   ├── crafts/
│   │   └── interceptor.toml (basic craft)
│   ├── facilities/
│   │   └── hangar.toml (required facility)
│   ├── missions/
│   │   └── ufo_crash.toml (basic mission)
│   ├── regions/
│   │   └── north_america.toml (one region)
│   ├── research/
│   │   └── laser_weapons.toml (one tech)
│   └── starting/
│       └── new_game.toml (minimal start)
└── assets/
    └── (minimal required assets)
```

**README.md:**
```markdown
# minimal_mod - Bare Minimum Game Content

## Purpose

Absolute minimum content required to run the game.

**Use for:**
- Quick testing
- Fast loading
- Debugging
- Engine development

**DO NOT use for actual gameplay** - extremely limited content.

## Contents

### Units
- 1 Soldier type
- 1 Alien type

### Items
- 1 Rifle (basic weapon)
- 1 Jumpsuit (basic armor)

### Facilities
- 1 Hangar (required)

### Missions
- 1 UFO Crash mission

### Research
- 1 Laser Weapons tech

### Starting Conditions
- 1 Base
- 4 Soldiers
- 1 Interceptor
- Basic equipment

## Load Time

< 1 second (vs 5-10 seconds for full core mod)

## Usage

Enable this mod when:
- Testing engine changes
- Debugging issues
- Need fast iteration
- Don't need full game content

## Validation

```bash
lovec tools/validators/validate_mod.lua mods/minimal_mod
# Expected: ✅ PASS

lovec tools/validators/validate_content.lua mods/minimal_mod
# Expected: ✅ PASS
```
```

**Estimated time:** 4-6 hours

---

### Step 7: Create Mod Metadata Files
**Description:** Create mod.toml for each mod

**Template:**
```toml
# Mod metadata

[mod]
id = "mod_name"
name = "Mod Display Name"
version = "1.0.0"
author = "Author Name"
description = "Brief description of mod purpose"

[dependencies]
# List required mods (if any)
# Example: core = ">=1.0.0"

[load_order]
priority = 0  # 0 = core/first, higher numbers load later

[compatibility]
game_version = ">=1.0.0"

[tags]
# Categories/tags for mod
tags = ["core", "content", "complete"]
```

**Per-mod metadata:**

**messy_mod:**
```toml
[mod]
id = "messy_mod"
name = "Messy Mod (Test/Broken)"
version = "1.0.0"
author = "AlienFall Team"
description = "Deliberately broken mod for testing validators. DO NOT USE FOR GAMEPLAY."

[load_order]
priority = 999  # Never load in normal game

[tags]
tags = ["test", "broken", "validators"]
```

**synth_mod:**
```toml
[mod]
id = "synth_mod"
name = "Synthetic Data Mod"
version = "1.0.0"
author = "AlienFall Team (Auto-generated)"
description = "Auto-generated mod with 100% API coverage. For testing only, not balanced for gameplay."

[load_order]
priority = 50

[tags]
tags = ["test", "synthetic", "api-coverage"]
```

**core:**
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
tags = ["core", "official", "complete", "balanced"]
```

**legacy:**
```toml
[mod]
id = "legacy"
name = "Legacy Archive"
version = "1.0.0"
author = "AlienFall Team"
description = "Historical archive of old content. For reference only."

[mod]
enabled = false  # Disabled by default

[load_order]
priority = 999  # Load last (if enabled)

[tags]
tags = ["archive", "reference", "historical"]
```

**minimal_mod:**
```toml
[mod]
id = "minimal_mod"
name = "Minimal Content"
version = "1.0.0"
author = "AlienFall Team"
description = "Bare minimum content to run game. For testing and debugging."

[load_order]
priority = 0

[tags]
tags = ["minimal", "test", "debug"]
```

**Estimated time:** 2-3 hours

---

### Step 8: Validate All Mods
**Description:** Run validators on all mods

**Validation matrix:**

| Mod | API Validator | Content Validator | Expected Result |
|-----|--------------|-------------------|----------------|
| messy_mod | ❌ FAIL | ❌ FAIL | Intentional errors found |
| synth_mod | ✅ PASS | ✅ PASS | All valid |
| core | ✅ PASS | ✅ PASS | All valid |
| legacy | ⚠️ SKIP | ⚠️ SKIP | Disabled, not validated |
| minimal_mod | ✅ PASS | ✅ PASS | All valid |

**Scripts to run:**
```bash
# Validate messy_mod (should FAIL)
lovec tools/validators/validate_mod.lua mods/messy_mod
lovec tools/validators/validate_content.lua mods/messy_mod

# Validate synth_mod (should PASS)
lovec tools/validators/validate_mod.lua mods/synth_mod
lovec tools/validators/validate_content.lua mods/synth_mod

# Validate core (should PASS)
lovec tools/validators/validate_mod.lua mods/core
lovec tools/validators/validate_content.lua mods/core

# Validate minimal_mod (should PASS)
lovec tools/validators/validate_mod.lua mods/minimal_mod
lovec tools/validators/validate_content.lua mods/minimal_mod
```

**Fix any unexpected failures in valid mods**

**Estimated time:** 4-5 hours

---

### Step 9: Test Each Mod in Game
**Description:** Load and test each mod

**Test scenarios:**

**minimal_mod:**
```bash
# Load game with only minimal_mod
# Config: mods = ["minimal_mod"]
lovec engine

# Verify:
- Game launches
- Geoscape loads
- Can enter basescape
- Can launch mission
- Battlescape loads
- Basic combat works
```

**core:**
```bash
# Load game with core mod
# Config: mods = ["core"]
lovec engine

# Verify:
- Full game loads
- All systems work
- Can play through full campaign
- No errors in console
```

**synth_mod:**
```bash
# Load game with synth_mod
# Config: mods = ["synth_mod"]
lovec engine

# Verify:
- Game loads
- All entities load
- No crashes
- (gameplay may be unbalanced, that's OK)
```

**messy_mod:**
```bash
# Attempt to load messy_mod
# Config: mods = ["messy_mod"]
lovec engine

# Expected:
- Validators prevent loading
- Errors displayed
- Game doesn't crash, just refuses to load mod
```

**Estimated time:** 6-8 hours

---

### Step 10: Update Documentation
**Description:** Document mod structure and purposes

**Files to create/update:**

**mods/README.md:**
```markdown
# Mods Directory

## Available Mods

### core
**Purpose:** Production content mod
**Status:** ✅ Maintained, balanced, complete
**Usage:** Default mod for gameplay

[Documentation](core/README.md)

### minimal_mod
**Purpose:** Bare minimum for testing
**Status:** ✅ Maintained, valid
**Usage:** Quick testing, debugging

[Documentation](minimal_mod/README.md)

### synth_mod
**Purpose:** Synthetic API coverage
**Status:** ✅ Auto-generated, valid
**Usage:** Testing, API validation

[Documentation](synth_mod/README.md)

### messy_mod
**Purpose:** Validator testing
**Status:** ❌ Deliberately broken
**Usage:** Testing validators only

[Documentation](messy_mod/README.md)

### legacy
**Purpose:** Historical archive
**Status:** ⚠️ Disabled, unmaintained
**Usage:** Reference only

[Documentation](legacy/README.md)

## Mod Loading

Mods are loaded based on priority in mod.toml:
1. `core` (priority 0)
2. `minimal_mod` (priority 0)
3. `synth_mod` (priority 50)
4. `legacy` (disabled)
5. `messy_mod` (priority 999, for testing only)

## Creating New Mods

See: [Modding Guide](../api/MODDING_GUIDE.md)

## Validating Mods

```bash
# API validation
lovec tools/validators/validate_mod.lua mods/your_mod

# Content validation
lovec tools/validators/validate_content.lua mods/your_mod
```
```

**Update main README.md:**
Add section explaining mod structure

**Estimated time:** 2-3 hours

---

## Implementation Details

### Architecture

**Five-Mod Structure:**
```
mods/
├── README.md (index and guide)
├── core/ (production mod)
│   ├── mod.toml
│   ├── README.md
│   ├── CONTENT_GUIDE.md
│   ├── rules/ (clean, organized content)
│   └── assets/
├── minimal_mod/ (bare minimum)
│   ├── mod.toml
│   ├── README.md
│   ├── rules/ (1 of each required type)
│   └── assets/
├── synth_mod/ (synthetic/generated)
│   ├── mod.toml
│   ├── README.md
│   ├── GENERATION_INFO.md
│   ├── rules/ (100% API coverage)
│   └── assets/
├── messy_mod/ (broken/test)
│   ├── mod.toml
│   ├── README.md
│   ├── ERROR_LIST.md
│   ├── rules/ (deliberately broken)
│   └── assets/ (some missing)
└── legacy/ (archive)
    ├── mod.toml (disabled)
    ├── README.md
    ├── ARCHIVE_INDEX.md
    ├── rules/ (old content)
    └── assets/
```

### Key Components

**Audit Tool:** Surveys current content
**Cleanup Process:** Manual review and organization
**Generator:** Creates synth_mod (TASK-003)
**Validators:** Verify mod validity (TASK-002, TASK-004)
**Testing:** Verify mods load and work

### Dependencies

- TASK-001 (GAME_API.toml)
- TASK-002 (API validator)
- TASK-003 (mock data generator)
- TASK-004 (content validator)

---

## Testing Strategy

### Validation Testing
- [ ] messy_mod fails validators (intentional)
- [ ] synth_mod passes all validators
- [ ] core passes all validators
- [ ] minimal_mod passes all validators

### Game Testing
- [ ] minimal_mod runs game
- [ ] core provides full experience
- [ ] synth_mod loads without crashes
- [ ] messy_mod prevented from loading

### Documentation Testing
- [ ] Each mod's README clear
- [ ] Purposes understood
- [ ] Usage instructions correct

---

## Documentation Updates

### Files to Create
- [ ] `mods/README.md` - mod index
- [ ] `mods/messy_mod/` - complete broken mod
- [ ] `mods/synth_mod/` - generated mod (via TASK-003)
- [ ] `mods/minimal_mod/` - bare minimum mod
- [ ] `mods/legacy/` - archive mod
- [ ] Each mod's README.md and metadata

### Files to Update
- [ ] `mods/core/` - cleanup and organize
- [ ] `README.md` - update mod structure section
- [ ] `api/MODDING_GUIDE.md` - reference new structure

---

## Notes

**Mod Purposes Summary:**

| Mod | Purpose | Validated | Maintained | For Gameplay |
|-----|---------|-----------|------------|--------------|
| core | Production content | ✅ Yes | ✅ Yes | ✅ Yes |
| minimal_mod | Quick testing | ✅ Yes | ✅ Yes | ❌ No |
| synth_mod | API coverage | ✅ Yes | ✅ Auto | ❌ No |
| messy_mod | Validator testing | ❌ No (intentional) | ✅ Yes | ❌ No |
| legacy | Historical reference | ⚠️ Skip | ❌ No | ❌ No |

**Critical Success Factors:**
1. Clear mod purposes
2. messy_mod actually breaks validators
3. synth_mod covers 100% of API
4. core mod is production-ready
5. Documentation is clear

---

## Blockers

**Must have:**
- [ ] TASK-001 completed (GAME_API.toml)
- [ ] TASK-002 completed (validators)
- [ ] TASK-003 completed (generator)
- [ ] Current mod content accessible

**Potential issues:**
- Core mod cleanup is time-consuming
- Determining what to keep vs archive
- Balance adjustments needed
- Content might not match LORE

---

## Review Checklist

- [ ] All five mods exist
- [ ] Each mod has clear purpose
- [ ] messy_mod breaks validators correctly
- [ ] synth_mod covers 100% API
- [ ] core mod is clean and balanced
- [ ] minimal_mod runs game
- [ ] legacy mod archived properly
- [ ] All metadata files correct
- [ ] All READMEs complete
- [ ] Validation matrix correct
- [ ] Game testing successful
- [ ] Documentation complete

---

## Success Criteria

**Task is DONE when:**
1. All five mods exist with clear purposes
2. messy_mod fails validators (intentional)
3. synth_mod passes all validators
4. core mod passes all validators
5. minimal_mod passes all validators
6. core mod is production-ready
7. Each mod loads in game correctly
8. Documentation explains structure
9. Team approves organization
10. Validation testing successful

**This enables:**
- Better testing of validators
- Complete API coverage testing
- Clean production mod
- Fast testing with minimal_mod
- Historical reference with legacy
