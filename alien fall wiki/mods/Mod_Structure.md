# Mod Structure

> **Purpose:** Complete specification of mod directory structure, file organization, and manifest format for Alien Fall mods.

---

## Overview

A well-structured mod is easier to maintain, debug, and share. This guide defines the canonical mod structure used by Alien Fall and explains each component's purpose.

---

## Standard Mod Structure

### Complete Directory Layout

```
mods/your_mod_id/
├── mod.toml                    # REQUIRED: Mod manifest
├── README.md                   # RECOMMENDED: User documentation
├── CHANGELOG.md                # RECOMMENDED: Version history
├── LICENSE.txt                 # RECOMMENDED: License information
│
├── data/                       # Game data files (TOML)
│   ├── weapons/
│   ├── units/
│   ├── missions/
│   ├── research/
│   ├── facilities/
│   ├── items/
│   └── factions/
│
├── assets/                     # Visual and audio assets
│   ├── sprites/
│   │   ├── weapons/
│   │   ├── units/
│   │   ├── ui/
│   │   └── effects/
│   ├── audio/
│   │   ├── weapons/
│   │   ├── music/
│   │   └── ambient/
│   └── fonts/
│
├── scripts/                    # Lua code
│   ├── init.lua               # Mod initialization
│   ├── systems/               # Custom game systems
│   ├── widgets/               # Custom UI widgets
│   └── utilities/             # Helper functions
│
├── locale/                     # Localization files
│   ├── en_US.toml
│   ├── es_ES.toml
│   ├── fr_FR.toml
│   ├── de_DE.toml
│   └── ja_JP.toml
│
├── maps/                       # Custom tactical maps
│   ├── blocks/                # Map building blocks
│   └── scripts/               # Map assembly scripts
│
├── config/                     # Mod configuration
│   ├── settings.toml          # User-adjustable settings
│   └── balance.toml           # Balance tuning values
│
└── tests/                      # Automated tests (optional)
    ├── test_weapons.lua
    ├── test_missions.lua
    └── test_framework.lua
```

---

## Required Files

### mod.toml (Manifest)

**Location:** `mods/your_mod_id/mod.toml`  
**Required:** YES  
**Purpose:** Defines mod metadata, dependencies, and load configuration

**Full Specification:**

```toml
# ============================================================================
# MOD MANIFEST SPECIFICATION
# ============================================================================

[mod]
# --- REQUIRED FIELDS ---
id = "your_mod_id"              # Unique identifier (lowercase, no spaces)
name = "Your Mod Display Name"  # Human-readable name
version = "1.0.0"               # Semantic version (MAJOR.MINOR.PATCH)
author = "Your Name"            # Creator name or team
description = "Brief description of what your mod does (1-2 sentences)"

# --- OPTIONAL FIELDS ---
homepage = "https://github.com/yourname/your_mod"
license = "MIT"                 # MIT, GPL-3.0, CC-BY-4.0, etc.
icon = "assets/mod_icon.png"    # 64x64 icon for mod manager

# ============================================================================
# COMPATIBILITY SETTINGS
# ============================================================================

[mod.compatibility]
# Minimum game version required
game_version = ">=0.5.0"        # Semantic version comparison

# Mods that MUST be installed for this mod to work
dependencies = [
    "core_framework:>=1.0.0",
    "advanced_weapons:^2.1.0"
]

# Mods that enhance this mod but aren't required
optional_dependencies = [
    "sound_pack",
    "hd_textures"
]

# Mods that conflict with this one
conflicts = [
    "weapon_overhaul",
    "legacy_combat_mod"
]

# ============================================================================
# LOAD CONFIGURATION
# ============================================================================

[mod.load]
# Load priority (0-100, default 50)
# Lower numbers load first
# 0-25: Framework/library mods
# 26-50: Content mods (default)
# 51-75: Balance/overhaul mods
# 76-100: Compatibility patches
priority = 50

# Content merge strategy
# "patch" - Modify specific fields only (default)
# "merge" - Combine with existing content
# "replace" - Completely override
content_strategy = "patch"

# Enable development features
dev_mode = false

# ============================================================================
# METADATA
# ============================================================================

[mod.metadata]
# Categorization tags for mod browser
tags = [
    "weapons",
    "units",
    "missions",
    "balance",
    "overhaul",
    "quality-of-life"
]

# Support contacts
support_url = "https://github.com/yourname/your_mod/issues"
discord = "https://discord.gg/your-server"

# Mod maturity
# "alpha" - Early development, breaking changes expected
# "beta" - Feature complete, testing phase
# "stable" - Production ready
# "deprecated" - No longer maintained
status = "stable"

# ============================================================================
# CONTENT DECLARATIONS (Optional but recommended)
# ============================================================================

[mod.content]
# Declare what content types your mod provides
# Helps with conflict detection and load optimization
weapons = true
units = true
missions = true
research = false
facilities = false
```

---

### Version Number Format

Follow **Semantic Versioning 2.0.0** ([semver.org](https://semver.org/)):

```
MAJOR.MINOR.PATCH

1.0.0   - Initial release
1.1.0   - Added new features (backward compatible)
1.1.1   - Bug fixes (backward compatible)
2.0.0   - Breaking changes (not backward compatible)
```

**Examples:**
- `1.0.0` - First stable release
- `1.2.3` - Version with features and patches
- `2.0.0-beta.1` - Pre-release version
- `1.5.0+build.123` - Build metadata

---

## Recommended Files

### README.md

**Location:** `mods/your_mod_id/README.md`  
**Format:** Markdown  
**Purpose:** User-facing documentation

**Template:**

```markdown
# Your Mod Name

Short description of your mod (1-2 sentences).

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

1. Download the latest release
2. Extract to `mods/` folder
3. Enable in mod manager
4. Restart game

## Requirements

- Alien Fall v0.5.0 or higher
- Required Mod A
- Required Mod B (optional)

## Configuration

Edit `config/settings.toml` to customize:
- Option 1: Description
- Option 2: Description

## Known Issues

- Issue 1 and workaround
- Issue 2 status

## Changelog

See [CHANGELOG.md](CHANGELOG.md)

## Credits

- Your Name - Lead Developer
- Contributor 1 - Art
- Contributor 2 - Testing

## License

MIT License - see [LICENSE.txt](LICENSE.txt)
```

---

### CHANGELOG.md

**Location:** `mods/your_mod_id/CHANGELOG.md`  
**Format:** Markdown  
**Purpose:** Version history tracking

**Template:**

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
### Added
- Feature in development

## [1.2.0] - 2025-10-01
### Added
- New plasma pistol variant
- Spanish localization
- Configuration options for damage scaling

### Changed
- Increased plasma rifle damage from 45 to 50
- Updated weapon icons to match game style

### Fixed
- Crash when equipping modded weapons in certain scenarios
- Localization keys not loading properly

## [1.1.0] - 2025-09-15
### Added
- Two new mission types
- Compatibility with Advanced Weapons mod

### Changed
- Rebalanced weapon stats based on community feedback

## [1.0.0] - 2025-09-01
### Added
- Initial release
- 5 new weapons
- Custom weapon effects
```

---

### LICENSE.txt

**Location:** `mods/your_mod_id/LICENSE.txt`  
**Purpose:** Legal protection and usage terms

**Common Licenses:**

#### MIT License (Permissive)
```
MIT License

Copyright (c) 2025 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy...
```

#### GPL-3.0 (Copyleft)
```
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2025 Your Name
This program is free software: you can redistribute it and/or modify...
```

#### Creative Commons BY-4.0 (Assets)
```
Creative Commons Attribution 4.0 International License

You are free to:
- Share, copy and redistribute the material
- Adapt, remix, transform, and build upon the material
```

**Choose based on your goals:**
- **MIT** - Most permissive, allows commercial use
- **GPL-3.0** - Requires derivatives to be open source
- **CC-BY-4.0** - Good for art/assets, requires attribution

---

## Data Directory Structure

### Purpose
Contains all game data in TOML format, organized by system.

### Organization

```
data/
├── weapons/              # Weapon definitions
│   ├── rifles.toml
│   ├── pistols.toml
│   ├── heavy_weapons.toml
│   └── melee.toml
│
├── units/                # Unit classes and stats
│   ├── soldiers.toml
│   ├── aliens.toml
│   └── civilians.toml
│
├── missions/             # Mission templates
│   ├── assault.toml
│   ├── defense.toml
│   └── special.toml
│
├── research/             # Research projects
│   ├── weapons_tech.toml
│   ├── armor_tech.toml
│   └── alien_biology.toml
│
├── facilities/           # Base facilities
│   └── buildings.toml
│
├── items/                # Non-weapon items
│   ├── armor.toml
│   ├── consumables.toml
│   └── resources.toml
│
├── factions/             # Faction definitions
│   └── alien_factions.toml
│
├── economies/            # Economic data
│   ├── costs.toml
│   └── manufacturing.toml
│
└── worlds/               # Geoscape world data
    ├── provinces.toml
    └── regions.toml
```

### Naming Conventions

**File Names:**
- lowercase with underscores: `plasma_weapons.toml`
- Descriptive and specific: `early_game_missions.toml`
- Avoid generic names: use `laser_rifles.toml` not `items.toml`

**IDs in Data:**
```toml
# Always prefix with mod ID to avoid conflicts
id = "mymod_plasma_rifle"     # GOOD
id = "plasma_rifle"            # BAD (might conflict)
```

---

## Assets Directory Structure

### Purpose
Contains visual and audio assets.

### Organization

```
assets/
├── sprites/              # Pixel art images
│   ├── weapons/         # 10x10 weapon sprites
│   │   ├── rifle_01.png
│   │   └── pistol_01.png
│   ├── units/           # Character sprites
│   │   ├── soldier_01.png
│   │   └── alien_01.png
│   ├── ui/              # UI elements
│   │   ├── icons/
│   │   └── panels/
│   ├── effects/         # Visual effects
│   │   ├── muzzle_flash.png
│   │   └── explosion.png
│   └── tiles/           # Map tiles
│       ├── floor_01.png
│       └── wall_01.png
│
├── audio/                # Sound files (OGG/WAV)
│   ├── weapons/
│   │   ├── rifle_fire.ogg
│   │   └── reload.ogg
│   ├── music/
│   │   └── combat_theme.ogg
│   ├── ambient/
│   │   └── base_ambience.ogg
│   └── ui/
│       ├── button_click.ogg
│       └── notification.ogg
│
└── fonts/                # Custom fonts (TTF)
    └── custom_font.ttf
```

### Asset Requirements

#### Sprite Specifications
- **Size:** 10×10 pixels (scaled 2× in-game = 20×20)
- **Format:** PNG with alpha channel
- **Color Depth:** 32-bit RGBA
- **Filtering:** Nearest-neighbor (pixel-perfect)
- **Naming:** lowercase_with_underscores.png

#### Audio Specifications
- **Format:** OGG Vorbis (preferred) or WAV
- **Sample Rate:** 44.1kHz
- **Channels:** Mono for SFX, Stereo for music
- **Bit Depth:** 16-bit
- **Volume:** Normalized to -3dB peak

#### Font Specifications
- **Format:** TrueType (.ttf) or OpenType (.otf)
- **License:** Ensure redistribution rights
- **Size:** Include multiple sizes if needed

---

## Scripts Directory Structure

### Purpose
Contains Lua code for custom functionality.

### Organization

```
scripts/
├── init.lua              # Mod initialization entry point
│
├── systems/              # Custom game systems
│   ├── weapon_system.lua
│   ├── ability_system.lua
│   └── effect_system.lua
│
├── widgets/              # Custom UI widgets
│   ├── custom_panel.lua
│   └── stat_display.lua
│
├── utilities/            # Helper functions
│   ├── math_utils.lua
│   ├── table_utils.lua
│   └── string_utils.lua
│
├── ai/                   # AI behaviors
│   ├── tactical_ai.lua
│   └── strategic_ai.lua
│
└── events/               # Event handlers
    ├── mission_events.lua
    └── combat_events.lua
```

### init.lua Template

**File:** `scripts/init.lua`

```lua
-- ============================================================================
-- MOD INITIALIZATION
-- ============================================================================

local ModName = {}

-- Mod API access
local modAPI = _G.modAPI

-- Mod configuration
ModName.config = {
    debug = false,
    version = "1.0.0"
}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function ModName:init()
    modAPI:log("[" .. ModName.config.version .. "] Initializing mod...")
    
    -- Load sub-modules
    self:loadSystems()
    self:loadWidgets()
    self:registerEvents()
    
    modAPI:log("Mod initialized successfully")
end

function ModName:loadSystems()
    -- Load custom systems
    local weaponSystem = modAPI:loadScript("mymod/scripts/systems/weapon_system.lua")
    weaponSystem:init()
end

function ModName:loadWidgets()
    -- Register custom widgets
    modAPI:registerWidget("mymod_custom_panel", 
        modAPI:loadScript("mymod/scripts/widgets/custom_panel.lua"))
end

function ModName:registerEvents()
    -- Subscribe to game events
    modAPI:subscribe("battlescape:mission_start", function(payload)
        self:onMissionStart(payload)
    end)
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

function ModName:onMissionStart(payload)
    if self.config.debug then
        modAPI:log("Mission started: " .. payload.mission_id)
    end
    
    -- Custom mission logic
end

-- ============================================================================
-- EXPORT
-- ============================================================================

-- Initialize on mod load
ModName:init()

return ModName
```

---

## Locale Directory Structure

### Purpose
Internationalization and localization support.

### Organization

```
locale/
├── en_US.toml           # English (United States) - Required default
├── en_GB.toml           # English (Great Britain)
├── es_ES.toml           # Spanish (Spain)
├── es_MX.toml           # Spanish (Mexico)
├── fr_FR.toml           # French (France)
├── de_DE.toml           # German (Germany)
├── it_IT.toml           # Italian (Italy)
├── ja_JP.toml           # Japanese (Japan)
├── ko_KR.toml           # Korean (Korea)
├── pt_BR.toml           # Portuguese (Brazil)
├── ru_RU.toml           # Russian (Russia)
└── zh_CN.toml           # Chinese (China, Simplified)
```

### Localization File Format

**File:** `locale/en_US.toml`

```toml
# ============================================================================
# ENGLISH (UNITED STATES) LOCALIZATION
# ============================================================================

[metadata]
language = "English"
region = "United States"
code = "en_US"
translators = ["Your Name"]

# ============================================================================
# WEAPONS
# ============================================================================

[weapons]
mymod_plasma_rifle_name = "Prototype Plasma Rifle"
mymod_plasma_rifle_desc = "An experimental energy weapon with devastating firepower."
mymod_plasma_rifle_flavor = "\"The future of warfare, today.\" - R&D Report #447"

mymod_plasma_pistol_name = "Plasma Pistol"
mymod_plasma_pistol_desc = "Compact plasma sidearm for close quarters combat."

# ============================================================================
# UNITS
# ============================================================================

[units]
mymod_elite_soldier_name = "Elite Soldier"
mymod_elite_soldier_desc = "Veteran operatives with superior training."

# ============================================================================
# MISSIONS
# ============================================================================

[missions]
mymod_extraction_name = "Extraction Mission"
mymod_extraction_desc = "Rescue operatives from hostile territory."
mymod_extraction_objective = "Extract all friendly units to the evac zone."

# ============================================================================
# UI
# ============================================================================

[ui]
mymod_settings_title = "Mod Settings"
mymod_enable_feature = "Enable Advanced Features"
mymod_difficulty_label = "Difficulty Multiplier"

[ui.tooltips]
mymod_plasma_rifle_tooltip = "High-tech energy weapon. Requires plasma ammunition."
```

---

## Maps Directory Structure

### Purpose
Custom tactical map blocks and assembly scripts.

### Organization

```
maps/
├── blocks/               # Map building blocks (15×15 tile grids)
│   ├── urban_block_01.txt
│   ├── urban_block_02.txt
│   ├── forest_block_01.txt
│   └── interior_block_01.txt
│
└── scripts/              # Map assembly scripts
    ├── urban_small.lua
    ├── forest_medium.lua
    └── base_defense.lua
```

### Map Block Format

**File:** `maps/blocks/urban_block_01.txt`

```
# 15x15 map block - Urban street corner
# . = floor, # = wall, D = door, W = window
# S = spawn point, C = cover (low)

###############
#.............#
#.C...........#
#.............#
W.............W
#.............#
#......C......#
#.............#
D.............D
#.............#
#.............#
#.S.........S.#
#.............#
###############
```

---

## Config Directory Structure

### Purpose
User-configurable mod settings.

### Organization

```
config/
├── settings.toml        # User-adjustable options
└── balance.toml         # Balance tuning values
```

### Settings File

**File:** `config/settings.toml`

```toml
# ============================================================================
# MOD SETTINGS
# User can edit these values to customize mod behavior
# ============================================================================

[gameplay]
damage_multiplier = 1.0      # Global damage scaling
accuracy_bonus = 0           # Flat accuracy modifier
enable_hardcore = false      # Hardcore mode toggle

[visual]
show_damage_numbers = true   # Floating damage text
particle_effects = true      # Enable particle FX
screen_shake = true          # Camera shake on impacts

[audio]
master_volume = 1.0          # 0.0 to 1.0
sfx_volume = 0.8
music_volume = 0.6

[debug]
enable_logging = false       # Console logging
show_fps = false             # FPS counter
show_hitboxes = false        # Debug visualization
```

---

## Tests Directory Structure

### Purpose
Automated testing for mod functionality.

### Organization

```
tests/
├── test_runner.lua          # Test execution framework
├── test_weapons.lua         # Weapon system tests
├── test_missions.lua        # Mission system tests
└── test_data_validation.lua # Data integrity tests
```

### Example Test

**File:** `tests/test_weapons.lua`

```lua
local test = require('test_framework')

test.describe("Plasma Rifle Tests", function()
    
    test.it("should load weapon data", function()
        local weapon = modAPI:getData("weapons/mymod_plasma_rifle")
        test.expect(weapon).to.exist()
        test.expect(weapon.id).to.equal("mymod_plasma_rifle")
    end)
    
    test.it("should have correct damage", function()
        local weapon = modAPI:getData("weapons/mymod_plasma_rifle")
        test.expect(weapon.stats.damage).to.equal(50)
    end)
    
    test.it("should require correct research", function()
        local weapon = modAPI:getData("weapons/mymod_plasma_rifle")
        test.expect(weapon.requirements.research).to.contain("plasma_weapons")
    end)
    
end)
```

---

## Size Recommendations

### Small Mod (< 1 MB)
- Simple data overrides
- Few new items/weapons
- No custom assets
- **Example:** Balance tweaks, stat modifications

### Medium Mod (1-10 MB)
- New content with custom sprites
- Multiple missions or units
- Some custom scripts
- **Example:** Weapon pack, mission expansion

### Large Mod (10-50 MB)
- Extensive new content
- Custom audio/music
- Complex scripting
- **Example:** Faction expansion, campaign addition

### Total Conversion (50+ MB)
- Complete game overhaul
- All custom assets
- New game systems
- **Example:** Historical conversion, total conversion mod

---

## Best Practices

### File Organization
1. **Group by function** - Keep related files together
2. **Use subdirectories** - Don't flatten everything
3. **Consistent naming** - lowercase_with_underscores
4. **Logical hierarchy** - Most important files at top level

### Performance
1. **Optimize assets** - Compress images, audio
2. **Lazy loading** - Don't load everything at startup
3. **Cache expensive operations** - Store computed values
4. **Batch operations** - Group similar tasks

### Maintainability
1. **Comment your code** - Explain complex logic
2. **Version control** - Use Git or similar
3. **Modular design** - Small, focused files
4. **Documentation** - Keep README updated

### Compatibility
1. **Unique IDs** - Always prefix with mod ID
2. **Declare dependencies** - Be explicit about requirements
3. **Test combinations** - Check with popular mods
4. **Handle conflicts** - Provide clear error messages

---

## Migration Checklist

### When Updating Game Version

- [ ] Update `game_version` in mod.toml
- [ ] Check for deprecated API calls
- [ ] Test all mod features
- [ ] Update CHANGELOG.md
- [ ] Bump mod version number
- [ ] Test with other mods
- [ ] Update README if needed

---

## Additional Resources

- **[Getting Started](Getting_Started.md)** - Quick tutorial
- **[API Reference](API_Reference.md)** - Complete API docs
- **[Data Formats](Data_Formats.md)** - TOML schemas
- **[Testing Guide](Testing_Your_Mod.md)** - QA best practices

---

## Tags
`#modding` `#structure` `#organization` `#manifest` `#best-practices`
