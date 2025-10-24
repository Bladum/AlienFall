# Modding API Reference

**Version:** 1.0.0
**Status:** Complete
**Last Updated:** October 24, 2025

---

## Quick Start: IDE Setup

**Recommended:** Use VS Code with TOML support for the best development experience.

### Setup (5 minutes)

1. Install VS Code: https://code.visualstudio.com/
2. Open this project: `code .`
3. Install recommended extensions (VS Code will prompt)
4. Done! Syntax highlighting and formatting now work

**Next:** See `docs/IDE_SETUP.md` for complete setup guide.

### Key Features

- ✅ **Syntax Highlighting:** Color-coded TOML files
- ✅ **Auto-Formatting:** Press **Shift+Alt+F** to format
- ✅ **Validation:** Run validators from VS Code tasks
- ✅ **Navigation:** Jump to definitions with **F12**

---

## Overview

AlienFall supports extensive modding through the mod system. Modders can create custom campaigns, factions, missions, and game content by leveraging the Mod Manager and content system.

---

## Mod Structure

All mods must follow this directory structure:

```
mods/my_mod/
├── mod.toml                  # Mod metadata (required)
├── campaign/                 # Campaign content
├── factions/                 # Faction definitions
├── missions/                 # Mission templates
├── rules/
│   ├── terrain.toml
│   ├── weapons.toml
│   ├── units.toml
│   └── ...
├── mapblocks/                # Map tile definitions
├── mapscripts/               # Map generation scripts
├── assets/                   # Images, sounds, fonts
│   ├── sprites/
│   ├── ui/
│   └── audio/
└── data/                     # Additional game data
    ├── technology.toml
    ├── economy.toml
    └── ...
```

---

## Mod Metadata (mod.toml)

Every mod must contain a `mod.toml` file defining its metadata:

```toml
[mod]
id = "my_custom_faction"
name = "Custom Faction Pack"
description = "Adds 3 new alien factions to the game"
version = "1.0.0"
author = "ModAuthor"
license = "CC-BY-4.0"

# Minimum game version required
min_game_version = "1.0.0"
max_game_version = "2.0.0"

# Load order (lower values load first)
load_order = 10

[paths]
# Define where content types are located
assets = "assets"
rules = "rules"
mapblocks = "mapblocks"
mapscripts = "mapscripts"
campaigns = "campaigns"
factions = "factions"
missions = "missions"
data = "data"

[settings]
# Enable/disable the mod
enabled = true

# Dependencies on other mods
[dependencies]
"base_game" = ">=1.0.0"
"faction_pack" = "1.0.0"
```

---

## API Reference

### ModManager API

**Module:** `engine/mods/mod_manager.lua`

#### ModManager.init()

Initializes the mod system and loads all available mods.

```lua
local ModManager = require("engine.mods.mod_manager")
ModManager.init()
```

#### ModManager.setActiveMod(modId)

Sets which mod should be used for content resolution.

```lua
ModManager.setActiveMod("core")
-- Returns: boolean (true if successful)
```

#### ModManager.getContentPath(contentType, subpath)

Resolves the full filesystem path to mod content.

```lua
local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
-- Returns: string (full file path)
```

**Content Types:**
- `assets` - Images, sprites, audio files
- `rules` - Game rule configurations
- `mapblocks` - Map tile definitions
- `mapscripts` - Map generation scripts
- `campaigns` - Campaign definitions
- `factions` - Faction definitions
- `missions` - Mission templates
- `data` - Other game data

#### ModManager.getActiveMod()

Returns the currently active mod configuration.

```lua
local activeMod = ModManager.getActiveMod()
print(activeMod.mod.name)  -- Prints mod name
-- Returns: table (mod configuration or nil)
```

#### ModManager.getLoadedMods()

Returns an array of all loaded mods.

```lua
local mods = ModManager.getLoadedMods()
for _, mod in ipairs(mods) do
    print(mod.mod.name)
end
```

#### ModManager.isModLoaded(modId)

Checks if a specific mod is loaded.

```lua
if ModManager.isModLoaded("core") then
    print("Core mod is available")
end
-- Returns: boolean
```

---

## Creating Custom Content

### Custom Factions

Create a faction definition file in `factions/my_faction.toml`:

```toml
[faction]
id = "insectoid"
name = "Insectoid Collective"
description = "Hive mind creatures from deep space"

# Units this faction uses
units = ["insectoid_worker", "insectoid_soldier", "insectoid_queen"]

# Base relations with other factions (-100 to 100)
[faction.relations]
human = -50
sectoid = 20

# Special traits
[faction.traits]
hive_mind = true
fast_reproduction = true

# Visual appearance
[faction.appearance]
color_r = 0.2
color_g = 0.8
color_b = 0.2
```

### Custom Missions

Create a mission template in `missions/my_mission.toml`:

```toml
[mission]
id = "alien_harvesting"
name = "Alien Harvesting Operation"
description = "Aliens conducting mass abductions"
category = "combat"

# Mission objectives
objectives = ["protect_civilians", "eliminate_aliens"]

# Difficulty (1-10)
difficulty = 3

# Enemy composition
enemies_min = 8
enemies_max = 12

# Rewards for completion
[mission.rewards]
science_points = 300
money = 500
artifacts = 2

# Availability/probability
availability = "always"  # or "campaign_date" for date-based
probability = 0.15
```

### Custom Weapons

Create a weapon definition in `rules/weapons/my_weapon.toml`:

```toml
[[weapons]]
id = "plasma_rifle"
name = "Plasma Rifle"
description = "Advanced energy weapon"

# Stats
damage_base = 75
accuracy_base = 70
range_min = 10
range_max = 40
ammo_per_shot = 2
ammo_capacity = 60

# Properties
weapon_type = "rifle"
fire_mode = "semi"
weight = 8
cost = 500
```

---

## Mod Examples

### Example 1: Custom Faction Mod

**Folder structure:**
```
mods/insectoid_faction/
├── mod.toml
├── factions/
│   ├── insectoids.toml
│   ├── arachnids.toml
│   └── cyborgs.toml
└── rules/
    └── units.toml
```

**mod.toml:**
```toml
[mod]
id = "insectoid_faction"
name = "Insectoid Faction Expansion"
version = "1.0.0"

[paths]
factions = "factions"
rules = "rules"

[dependencies]
"base_game" = ">=1.0.0"
```

### Example 2: Custom Mission Pack

**Folder structure:**
```
mods/mission_expansion/
├── mod.toml
└── missions/
    ├── harvesting.toml
    ├── research.toml
    ├── terror.toml
    └── infiltration.toml
```

---

## Best Practices

### 1. Versioning

Use semantic versioning (MAJOR.MINOR.PATCH):
- `1.0.0` - Initial release
- `1.1.0` - New features, backwards compatible
- `2.0.0` - Breaking changes

### 2. Dependencies

Always specify minimum game version:
```toml
[mod]
min_game_version = "1.0.0"

[dependencies]
"base_game" = ">=1.0.0"
```

### 3. Testing

Before releasing your mod:
1. Test with core content only
2. Test with mod enabled/disabled
3. Test version compatibility
4. Test dependency resolution

### 4. Documentation

Include a README.md:
```markdown
# My Awesome Mod

## Description
What does your mod do?

## Features
- Feature 1
- Feature 2

## Installation
1. Place folder in mods/
2. Enable in-game

## Requirements
- Game version 1.0.0+
- Other mods...

## FAQ
- Common questions
```

### 5. Compatibility

- Don't modify core content
- Extend rather than replace
- Check version compatibility
- Document conflicts with other mods

---

## Troubleshooting

### Mod Not Loading

**Symptom:** Mod appears in list but isn't active

**Solution:**
1. Check `enabled = true` in mod.toml
2. Verify file paths in `[paths]` section
3. Check game console for errors

### Content Not Found

**Symptom:** Game can't find mod content

**Solution:**
1. Verify file paths match `mod.toml`
2. Check file exists in correct folder
3. Verify TOML syntax is valid

### Version Mismatch

**Symptom:** "Mod requires different game version"

**Solution:**
1. Check `min_game_version` in mod.toml
2. Update game or mod version
3. Verify version constraints in dependencies

---

## Advanced Topics

### Mod Load Order

Mods load in this order:
1. All mods sorted by `load_order` value
2. Lower values load first
3. Core mod always loads first (load_order=0)

```toml
[mod]
load_order = 10  # Default
```

### Dependency Resolution

Mod dependencies are checked at load time:
```toml
[dependencies]
"required_mod" = "1.0.0"        # Exact version
"other_mod" = ">=1.0.0"         # Minimum version
"third_mod" = ">=1.0.0,<2.0.0"  # Version range
```

### Mod Conflicts

If two mods define the same content:
1. First loaded mod's content is used
2. Warning printed to console
3. Game continues with first mod's content

---

## Resources

- **Game Version:** 1.0.0
- **API Version:** 1.0
- **Last Updated:** October 24, 2025

For questions or support, visit the AlienFall community forums.
