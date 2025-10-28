# Mods Folder - Game Content & Configuration

**Purpose:** Store game content separate from code (data-driven design)  
**Audience:** Content creators, designers, modders, players  
**Format:** TOML configuration files + asset files (PNG, OGG)

---

## What Goes in mods/

### Structure
```
mods/
├── core/                        Base game content (always loaded first)
│   ├── mod.toml                Mod metadata
│   ├── rules/                  TOML configurations
│   │   ├── units/              Unit definitions
│   │   │   ├── soldiers.toml   Player units
│   │   │   └── aliens.toml     Enemy units
│   │   ├── items/              Item definitions
│   │   │   ├── weapons.toml    Weapons
│   │   │   ├── armor.toml      Armor
│   │   │   └── equipment.toml  Equipment
│   │   ├── facilities/         Base facilities
│   │   ├── crafts/             Aircraft/vehicles
│   │   ├── research/           Research projects
│   │   ├── missions/           Mission types
│   │   ├── countries/          Geoscape countries
│   │   └── ...                 Other content types
│   └── assets/                 Asset files
│       ├── units/              Unit sprites (PNG)
│       ├── items/              Item icons (PNG)
│       ├── ui/                 UI elements (PNG)
│       └── sounds/             Sound effects (OGG)
│
├── minimal_mod/                 Template for new mods
│   ├── mod.toml                Example metadata
│   ├── rules/                  Example TOML
│   └── assets/                 Example assets
│
└── examples/                    Example mods
    ├── custom_faction/         How to add faction
    ├── weapon_pack/            How to add weapons
    └── ...                     More examples
```

---

## Core Principle: Separation of Code and Data

**Engine defines HOW. Mods define WHAT.**

```
Engine (HOW - in engine/):
  function Unit:new(id, name, rank)
  function Unit:gainExperience(amount)
  function Unit:promote()

Mods (WHAT - in mods/):
  [unit.rookie_soldier]
  id = "rookie_soldier"
  name = "Rookie Soldier"
  strength = 8
  health = 90
  xp_to_next_rank = 100
```

**Benefits:**
- Content changes without code recompilation
- Non-programmers can create content
- Modding support built-in
- Easy balance adjustments
- Hot-reload during development

---

## Content Guidelines

### What Belongs Here
- ✅ Entity definitions (units, items, crafts, etc.)
- ✅ Balance values (stats, costs, requirements)
- ✅ Asset files (sprites, sounds, data)
- ✅ Configuration (starting resources, difficulty settings)
- ✅ Game content (levels, missions, dialogues)
- ✅ Mod metadata (dependencies, version, author)

### What Does NOT Belong Here
- ❌ Game logic code - goes in engine/
- ❌ API contracts - goes in api/
- ❌ Design rationale - goes in design/
- ❌ Tests - goes in tests2/
- ❌ Tools - goes in tools/

---

## Mod Structure

### Mod Metadata (mod.toml)

```toml
[mod]
id = "my_custom_mod"                    # Unique ID (lowercase_with_underscores)
name = "My Custom Mod"                  # Display name
version = "1.0.0"                       # Semantic versioning (major.minor.patch)
author = "Your Name"                    # Creator
description = "Adds custom units and weapons to the game"
license = "MIT"                         # License (optional)

# Dependencies (load order)
dependencies = ["core"]                 # Requires core mod
conflicts = []                          # Incompatible mods (optional)
engine_version = "0.1.0"               # Minimum engine version

# Content flags (what this mod changes)
[mod.content]
units = true                           # Contains unit definitions
items = true                           # Contains item definitions
facilities = false                     # No facility changes
crafts = false                         # No craft changes
missions = false                       # No mission changes
research = false                       # No research changes
countries = false                      # No country changes
```

**Purpose:**
- Identify mod uniquely
- Declare dependencies (load order)
- Specify engine compatibility
- Document what content is included

---

### Content Definition (TOML Files)

```toml
# mods/core/rules/units/soldiers.toml

# Basic soldier unit
[unit.rookie_soldier]
id = "rookie_soldier"
name = "Rookie Soldier"

# Stats (from design/mechanics/Units.md)
strength = 8
dexterity = 7
constitution = 9

# Health
health = 90

# Progression (from design)
experience = 0
xp_to_next_rank = 100
rank = 1

# Equipment
starting_weapon = "rifle_basic"
starting_armor = "armor_basic"

# Visuals
sprite = "units/rookie_soldier.png"
portrait = "portraits/rookie_soldier.png"

# Advanced soldier
[unit.veteran_soldier]
id = "veteran_soldier"
name = "Veteran Soldier"

strength = 12
dexterity = 10
constitution = 11

health = 120

experience = 250
xp_to_next_rank = 100
rank = 3

starting_weapon = "rifle_advanced"
starting_armor = "armor_advanced"

sprite = "units/veteran_soldier.png"
portrait = "portraits/veteran_soldier.png"
```

**Validation:** Must match schema in `api/GAME_API.toml`

---

### Asset Files

**Sprites:**
```
mods/core/assets/units/rookie_soldier.png
- Format: PNG with transparency
- Size: 24x24 pixels
- Palette: Consistent with game style
```

**Sounds:**
```
mods/core/assets/sounds/rifle_shot.ogg
- Format: OGG Vorbis
- Sample rate: 44100 Hz
- Channels: Mono or Stereo
- Length: <5 seconds for SFX
```

**Validation:** Assets referenced in TOML must exist

---

## Mod Loading System

### Load Order

```
1. Discover all mods in mods/ folder
   └─ Scan for mod.toml files

2. Build dependency graph
   └─ Read dependencies from each mod.toml

3. Topological sort (determine load order)
   └─ Core always first, then resolve dependencies

4. Load in order
   ├─ Parse TOML files
   ├─ Validate against schema
   ├─ Register in ContentRegistry
   └─ Load assets into memory

5. Apply overrides
   └─ Later mods override earlier mods (per-field)
```

**Example Load Order:**
```
1. core (no dependencies)
2. faction_expansion (depends on: core)
3. weapon_pack (depends on: core)
4. balance_mod (depends on: core, faction_expansion)
```

---

### Mod Override Behavior

**Per-Field Override (Granular):**

```toml
# core mod defines:
[unit.rookie_soldier]
strength = 8
health = 90
sprite = "units/rookie.png"

# balance_mod overrides only strength:
[unit.rookie_soldier]
strength = 10

# Result after loading both:
[unit.rookie_soldier]
strength = 10              ← From balance_mod (overridden)
health = 90                ← From core (not overridden)
sprite = "units/rookie.png" ← From core (not overridden)
```

**Why Per-Field:**
- Mods can tweak specific values
- Don't need to redefine entire entity
- Multiple mods can modify same entity
- Load order determines priority

---

## Creating a New Mod

### Step-by-Step Guide

**Step 1: Copy Template**
```bash
cd mods/
cp -r minimal_mod/ my_custom_mod/
cd my_custom_mod/
```

**Step 2: Edit Metadata**
```toml
# my_custom_mod/mod.toml

[mod]
id = "my_custom_mod"               # Change to unique ID
name = "My Custom Mod"             # Change to your mod name
version = "1.0.0"
author = "Your Name"               # Add your name
description = "Adds custom units"  # Describe your mod
dependencies = ["core"]            # Usually depends on core

[mod.content]
units = true                       # Enable content types you're adding
items = false
```

**Step 3: Create Content**
```toml
# my_custom_mod/rules/units/my_units.toml

[unit.elite_soldier]
id = "elite_soldier"
name = "Elite Soldier"
strength = 12
health = 120
# ... (follow schema from api/GAME_API.toml)
```

**Step 4: Add Assets**
```
my_custom_mod/assets/units/elite_soldier.png
- Create 24x24 pixel sprite
- Follow game art style
- PNG with transparency
```

**Step 5: Validate**
```bash
lua tools/validators/toml_validator.lua mods/my_custom_mod/ api/GAME_API.toml

# Output:
✓ unit.elite_soldier - All fields valid
✓ All assets exist
✓ Mod ready to load
```

**Step 6: Test**
```bash
lovec engine/

# Engine will auto-discover and load your mod
# Check console for loading messages
```

---

## Integration with Other Folders

### design/ → mods/
Design specs become content:
- **Design:** "Rookie soldiers have 8 strength, 90 health"
- **Mods:** TOML defines exactly these values

### api/ → mods/
Schema validates content:
- **API:** Defines unit structure and ranges
- **Mods:** TOML must match schema exactly

### engine/ → mods/
Engine loads and uses content:
- **Engine:** Calls `ContentRegistry:get("unit", "rookie")`
- **Mods:** Provides data for that unit

### mods/ → tests2/
Content used in integration tests:
- **Mods:** Defines test_unit with known values
- **Tests:** Uses test_unit for predictable testing

---

## Validation

### Mod Quality Checklist

- [ ] mod.toml complete and valid
- [ ] All TOML validates against schema
- [ ] All referenced assets exist
- [ ] Assets correct format/size
- [ ] No broken entity references
- [ ] Dependencies declared correctly
- [ ] No circular dependencies
- [ ] Tested in-game (loads and works)
- [ ] Documentation/README included
- [ ] Version number follows semantic versioning

---

## Tools

### TOML Validator
```bash
lua tools/validators/toml_validator.lua mods/my_mod/ api/GAME_API.toml

# Checks:
# - TOML syntax valid
# - Types match schema
# - Values in ranges
# - Required fields present
# - Patterns match
```

### Asset Validator
```bash
lua tools/validators/asset_validator.lua mods/my_mod/

# Checks:
# - All referenced files exist
# - Correct formats (PNG, OGG)
# - Correct dimensions (24x24 for units)
# - No orphaned assets
```

### Content Validator
```bash
lua tools/validators/content_validator.lua mods/my_mod/

# Checks:
# - Entity references valid (starting_weapon exists?)
# - No circular dependencies (research → research loop)
# - Logical consistency (strength not negative)
```

### Mod Packager
```bash
lua tools/mod/package.lua my_custom_mod

# Creates:
# - my_custom_mod_v1.0.0.zip
# - Includes all TOML and assets
# - Excludes development files
# - Ready for distribution
```

---

## Best Practices

### 1. Use Unique IDs
```toml
# BAD: Generic ID
[unit.soldier]
id = "soldier"

# GOOD: Prefix with mod name
[unit.mymod_elite_soldier]
id = "mymod_elite_soldier"
```

### 2. Follow Core Conventions
```toml
# Study core mod structure
# Match naming patterns
# Use similar value ranges
# Consistent style
```

### 3. Document Your Mod
```markdown
# my_custom_mod/README.md

# My Custom Mod

Adds elite soldiers to the game.

## Features
- 3 new soldier types
- Improved stats for late game
- Custom sprites

## Installation
1. Extract to mods/ folder
2. Ensure core mod present
3. Launch game

## Balance
Elite soldiers are strong but expensive.
```

### 4. Test Thoroughly
```
- Load mod (check console for errors)
- Verify content appears in-game
- Test with core mod only first
- Test with other popular mods
- Check for conflicts
```

### 5. Version Properly
```
1.0.0 - Initial release
1.1.0 - Added new soldier type (minor = new features)
1.1.1 - Fixed sprite bug (patch = bug fixes)
2.0.0 - Changed balance significantly (major = breaking changes)
```

### 6. Handle Dependencies
```toml
# Declare ALL dependencies
dependencies = ["core", "faction_expansion"]

# If your mod needs another mod to work, declare it!
```

---

## Common Patterns

### Pattern 1: Balance Mod
```toml
# balance_tweaks/mod.toml
[mod]
id = "balance_tweaks"
dependencies = ["core"]

# balance_tweaks/rules/units/rebalance.toml
[unit.rookie_soldier]
strength = 10  # Buffed from 8

[unit.veteran_soldier]  
strength = 14  # Buffed from 12
```

### Pattern 2: Content Addition
```toml
# new_faction/mod.toml
[mod]
id = "new_faction"
dependencies = ["core"]

# new_faction/rules/units/faction_units.toml
[unit.faction_warrior]
id = "faction_warrior"
name = "Faction Warrior"
# ... (completely new unit)
```

### Pattern 3: Asset Replacement
```toml
# hd_graphics/mod.toml
[mod]
id = "hd_graphics"
dependencies = ["core"]

# hd_graphics/rules/units/graphics.toml
[unit.rookie_soldier]
sprite = "units/hd_rookie.png"  # Replaces default sprite
# (Only override sprite field)
```

---

## Troubleshooting

### Mod Won't Load
```
Check:
1. mod.toml exists and valid?
2. ID unique (no conflicts)?
3. Dependencies installed?
4. Engine version compatible?
5. Console shows error messages?
```

### Content Not Appearing
```
Check:
1. TOML syntax valid?
2. Entity IDs unique?
3. Content flags set in mod.toml?
4. Loaded after dependencies?
5. Run toml_validator.lua
```

### Assets Missing
```
Check:
1. File paths correct (case-sensitive)?
2. Files in assets/ folder?
3. Correct format (PNG, OGG)?
4. Referenced in TOML?
5. Run asset_validator.lua
```

---

## Maintenance

**On Game Update:**
- Check engine_version compatibility
- Test mod still loads
- Verify content still works
- Update if API changed

**Monthly:**
- Review for outdated content
- Check for reported issues
- Update version if changes made

**Per Release:**
- Test with latest game version
- Update README/documentation
- Package and distribute

---

**See:** mods/README.md and api/MODDING_GUIDE.md

**Related:**
- [modules/02_API_FOLDER.md](02_API_FOLDER.md) - Schema mods validate against
- [modules/04_ENGINE_FOLDER.md](04_ENGINE_FOLDER.md) - Engine loading mods
- [systems/03_DATA_DRIVEN_CONTENT_SYSTEM.md](../systems/03_DATA_DRIVEN_CONTENT_SYSTEM.md) - System pattern

