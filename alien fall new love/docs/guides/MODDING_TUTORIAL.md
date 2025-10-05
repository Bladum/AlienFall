# Alien Fall Modding Tutorial

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Difficulty:** Beginner to Advanced

---

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Mod Structure](#mod-structure)
4. [Creating Your First Mod](#creating-your-first-mod)
5. [Content Types](#content-types)
6. [Advanced Modding](#advanced-modding)
7. [Mod Hooks](#mod-hooks)
8. [Testing Your Mod](#testing-your-mod)
9. [Publishing](#publishing)
10. [Troubleshooting](#troubleshooting)

---

## Introduction

Welcome to Alien Fall modding! This tutorial will guide you through creating custom content for the game, from simple weapon additions to complete overhaul mods.

Alien Fall's modding system is heavily inspired by **OpenXCOM**, the open-source reimplementation of the original X-COM: UFO Defense. If you're familiar with OpenXCOM's ruleset system, you'll find many similarities here, with improvements for modern game development.

### What Can You Mod?

- **Units**: Create new soldier classes, aliens, and enemies
- **Items**: Add weapons, armor, equipment, and consumables
- **Missions**: Design custom mission types and objectives
- **Facilities**: Build new base structures and services
- **Research**: Define new tech trees and discoveries
- **Geoscape**: Add provinces, countries, regions, and biomes
- **Battlescape**: Create custom terrains, tilesets, and maps
- **Economy**: Add suppliers, marketplace items, and manufacturing
- **Lore**: Write factions, campaigns, events, and story content
- **Hooks**: Inject custom Lua code into game systems

### OpenXCOM vs Alien Fall Modding

If you're coming from OpenXCOM modding, here are the key differences:

| Feature | OpenXCOM | Alien Fall |
|---------|----------|------------|
| **Data Format** | YAML rulesets | TOML files |
| **Scripting** | Limited (YAML only) | Full Lua scripting with hooks |
| **Mod Structure** | Flat file structure | Organized by content type |
| **Dependencies** | Load order only | Explicit dependency graph |
| **Asset Loading** | Manual paths | Automatic discovery |
| **Validation** | Runtime errors | Pre-flight validation |
| **Hot Reload** | Requires restart | Console command `/reload_mods` |

**Why TOML instead of YAML?**
- Simpler, more readable syntax
- Better error messages
- Native Lua parsing support
- Stricter specification (less ambiguity)

**Example Comparison:**

OpenXCOM (YAML):
```yaml
items:
  - type: STR_PLASMA_RIFLE
    size: 0.2
    costSell: 126000
    weight: 8
    bigSprite: 6
    fireSound: 7
    accuracyAuto: 56
    tuAuto: 35
    battleType: 1
```

Alien Fall (TOML):
```toml
[[item]]
id = "plasma_rifle"
name = "Plasma Rifle"
type = "weapon"

[item.physical]
size = 0.2
weight = 8
sprite = "assets/items/plasma_rifle.png"

[item.costs]
sell_price = 126000

[item.combat]
accuracy_auto = 56
time_units_auto = 35
fire_sound = "plasma_shot"
```

### Prerequisites

- Basic understanding of TOML file format ([TOML spec](https://toml.io/))
- Text editor (VS Code recommended with TOML extension)
- Alien Fall installed and working
- Optional: Familiarity with Lua for advanced modding

---

## Getting Started

### Required Tools

1. **Text Editor**: [VS Code](https://code.visualstudio.com/) with TOML extension
2. **Image Editor**: For creating custom sprites (GIMP, Aseprite, etc.)
3. **TOML Validator**: Online tools or VS Code extensions

### Recommended Resources

- [TOML Specification](https://toml.io/)
- [Alien Fall API Documentation](API_DOCUMENTATION.md)
- [Lua Style Guide](LUA_STYLE_GUIDE.md)
- [Love2D Documentation](https://love2d.org/wiki/Main_Page)

---

## Mod Structure

### Directory Layout

Every mod follows this structure:

```
my_mod/
├── main.toml           # Mod manifest (required)
├── README.md           # Mod documentation (recommended)
├── assets/             # Images, sounds, fonts
│   ├── sprites/
│   ├── sounds/
│   └── fonts/
├── config/             # Configuration files
│   ├── assets.toml     # Asset definitions
│   └── logging.toml    # Logging configuration
├── data/               # Game content data
│   ├── units/          # Unit definitions
│   ├── items/          # Item definitions
│   ├── battle/         # Battlescape content
│   ├── base/           # Basescape content
│   ├── geo/            # Geoscape content
│   ├── economy/        # Economy content
│   └── lore/           # Story/lore content
├── scripts/            # Lua hook scripts
│   └── init.lua
└── locale/             # Translations (optional)
    ├── en.toml
    └── es.toml
```

### The `main.toml` Manifest

The manifest file tells the game about your mod:

```toml
[mod]
id = "my_awesome_mod"              # Unique identifier (lowercase, underscores)
name = "My Awesome Mod"            # Display name
version = "1.0.0"                  # Semantic versioning
author = "Your Name"                # Mod creator
description = "Adds cool stuff!"    # Short description

[dependencies]
# Mods that must be loaded before this one
required_mods = []
# Optional mods that enhance this mod if present
optional_mods = []
# Lua hook files
hooks = ["scripts/init.lua"]
# Script directories
scripts = ["scripts/"]

[content]
# Paths to content files (relative to mod root)
units = ["data/units/soldiers.toml"]
items = ["data/items/weapons.toml"]
# ... more content types ...

[metadata]
website = "https://github.com/yourname/my-mod"
license = "MIT"
tags = ["units", "weapons", "balance"]
```

---

## Creating Your First Mod

### Step 1: Create Mod Directory

1. Navigate to `Alien Fall/mods/`
2. Create a new folder: `tutorial_weapon_mod/`

### Step 2: Create Manifest

Create `tutorial_weapon_mod/main.toml`:

```toml
[mod]
id = "tutorial_weapon_mod"
name = "Tutorial: Custom Weapon"
version = "1.0.0"
author = "Modding Tutorial"
description = "Tutorial mod that adds a custom plasma rifle"

[content]
item_unit = ["data/items/weapons.toml"]
```

### Step 3: Create Weapon Data

Create `tutorial_weapon_mod/data/items/weapons.toml`:

```toml
[[item_unit_weapon]]
id = "tutorial_plasma_rifle"
name = "Tutorial Plasma Rifle"
description = "An experimental plasma weapon with high accuracy."

[item_unit_weapon.stats]
damage = 35
accuracy = 85
range = 20
action_points = 3
ammo_capacity = 12

[item_unit_weapon.attributes]
weapon_type = "rifle"
damage_type = "plasma"
two_handed = true
weight = 4.5

[item_unit_weapon.sprites]
inventory = "assets/sprites/tutorial_plasma_rifle.png"
battlefield = "assets/sprites/tutorial_plasma_rifle_hand.png"

[item_unit_weapon.sounds]
fire = "assets/sounds/plasma_shot.ogg"
reload = "assets/sounds/plasma_reload.ogg"

[item_unit_weapon.requirements]
research = []              # No research required
manufacture_cost = 5000     # Cost to manufacture
manufacture_time = 10       # Days to manufacture

[item_unit_weapon.tags]
tags = ["plasma", "rifle", "experimental", "human"]
```

### Step 4: Add Assets (Optional)

If you have custom sprites/sounds:

1. Create `tutorial_weapon_mod/assets/sprites/`
2. Add your `tutorial_plasma_rifle.png` (32x32 pixels recommended)
3. Add your sound effects in `assets/sounds/`

### Step 5: Test Your Mod

1. Launch Alien Fall
2. Check console for mod loading messages
3. Verify weapon appears in game

---

## Content Types

### Units

Add custom soldier classes or alien types.

**File:** `data/units/unit_classes.toml`

```toml
[[unit_class]]
id = "tutorial_sniper"
name = "Elite Sniper"
description = "Long-range specialist with high accuracy."

[unit_class.base_stats]
health = 80
time_units = 55
stamina = 60
reactions = 75
firing_accuracy = 90
throwing_accuracy = 60
strength = 50
bravery = 70
psionic_strength = 0
psionic_skill = 0

[unit_class.progression]
# Stats gained per rank
health_per_rank = 5
firing_accuracy_per_rank = 3
reactions_per_rank = 2

[unit_class.equipment]
# Starting equipment
default_weapon = "tutorial_plasma_rifle"
default_armor = "tactical_vest"
default_items = ["medkit", "grenade"]

[unit_class.restrictions]
# What this unit can use
allowed_weapon_types = ["rifle", "pistol", "sniper"]
allowed_armor_types = ["light", "medium"]

[unit_class.costs]
hire_cost = 50000
monthly_salary = 5000
training_days = 14
```

### Missions

Define custom mission types.

**File:** `data/lore/mission/custom_missions.toml`

```toml
[[mission]]
id = "tutorial_rescue"
name = "Rescue Operation"
description = "Extract civilians from hostile territory."

[mission.parameters]
mission_type = "rescue"
difficulty = "medium"
max_turns = 20
civilians = 4
enemies_min = 6
enemies_max = 12

[mission.rewards]
credits = 10000
fame = 50
karma = 25
research_breakthrough_chance = 0.1

[mission.failure_penalties]
karma_loss = 30
fame_loss = 20
country_panic = 15

[mission.spawn_rules]
# Enemy spawn weights
enemy_types = [
    {id = "sectoid", weight = 0.4},
    {id = "floater", weight = 0.3},
    {id = "muton", weight = 0.3}
]

[mission.map_generation]
terrain_type = "urban"
map_size = "medium"        # small, medium, large
blocks = ["urban_streets", "buildings", "park"]
```

### Facilities

Create new base buildings.

**File:** `data/base/base_facilities.toml`

```toml
[[facility]]
id = "tutorial_training_center"
name = "Advanced Training Center"
description = "Accelerates soldier training and skill development."

[facility.stats]
build_cost = 500000
build_time_days = 20
maintenance_cost_monthly = 10000
power_consumption = 5
capacity = 30              # Max trainees

[facility.size]
width = 2                  # Grid cells
height = 2

[facility.requirements]
research = ["advanced_tactics"]
dependencies = ["barracks"]  # Must have barracks first

[facility.benefits]
training_speed_multiplier = 2.0
skill_gain_multiplier = 1.5
morale_boost = 10

[facility.sprite]
icon = "assets/sprites/training_center.png"
blueprint = "assets/sprites/training_center_blueprint.png"
```

### Research

Define technology trees.

**File:** `data/economy/research.toml`

```toml
[[research]]
id = "tutorial_plasma_tech"
name = "Plasma Weapons Technology"
description = "Unlock the secrets of alien plasma weaponry."

[research.requirements]
# Prerequisites
required_research = ["alien_materials", "energy_weapons"]
required_items = ["alien_plasma_rifle"]  # Need one to research
required_autopsies = []

[research.costs]
research_points = 500
scientist_hours = 1000
credits = 100000

[research.unlocks]
# What this research enables
items = ["tutorial_plasma_rifle", "plasma_pistol"]
facilities = ["plasma_foundry"]
missions = []
pedia_entries = ["plasma_tech_entry"]

[research.effects]
# Global bonuses
global_damage_bonus = {plasma = 0.1}  # +10% plasma damage
```

### Battlescape Content

Create custom terrain and map blocks.

**File:** `data/battle/terrains.toml`

```toml
[[terrain]]
id = "tutorial_jungle"
name = "Dense Jungle"
description = "Thick vegetation provides cover but limits visibility."

[terrain.properties]
movement_cost_multiplier = 1.5  # Slower movement
visibility_reduction = 0.3       # 30% less visibility
flammable = true
cover_value = 40                 # Cover strength

[terrain.environmental_effects]
ambient_sounds = ["jungle_ambient"]
particle_effects = ["leaves_falling"]
lighting = {tint = [0.7, 0.9, 0.7]}  # Green tint

[terrain.spawns]
# What can spawn on this terrain
vegetation = ["tree", "bush", "tall_grass"]
obstacles = ["fallen_log", "rocks"]
wildlife = ["snake", "bird"]
```

### Research Trees (OpenXCOM-Style)

Design complex technology trees with dependencies, similar to OpenXCOM's research system.

**File:** `data/economy/research_tree.toml`

```toml
# Basic alien technology research
[[research]]
id = "alien_materials"
name = "Alien Materials Analysis"
description = "Study the composition of alien alloys and materials."

[research.requirements]
# No prerequisites - available at game start
required_items = ["alien_alloy_fragment"]
required_count = 1

[research.costs]
research_points = 200
scientist_hours = 400
credits = 50000

[research.unlocks]
items = []
research = ["alien_alloys", "alien_electronics"]  # Unlocks further research
manufacturing = []

# Intermediate research - requires alien_materials
[[research]]
id = "alien_alloys"
name = "Alien Alloy Production"
description = "Learn to manufacture alien alloys for armor and craft construction."

[research.requirements]
required_research = ["alien_materials"]  # Prerequisite
required_items = []

[research.costs]
research_points = 400
scientist_hours = 800
credits = 150000

[research.unlocks]
manufacturing = ["alloy_armor", "alloy_craft_hull"]
facilities = ["alloy_foundry"]

# Parallel research branch
[[research]]
id = "alien_electronics"
name = "Alien Electronics"
description = "Reverse-engineer alien computer systems and power sources."

[research.requirements]
required_research = ["alien_materials"]
required_items = ["alien_computer"]
required_count = 1

[research.costs]
research_points = 350
scientist_hours = 700
credits = 100000

[research.unlocks]
items = ["motion_scanner"]
research = ["alien_navigation", "plasma_weapons"]

# Advanced research - requires multiple prerequisites (OpenXCOM-style tech tree)
[[research]]
id = "plasma_weapons"
name = "Plasma Weapon Technology"
description = "Unlock the secrets of plasma-based weaponry."

[research.requirements]
required_research = ["alien_electronics", "alien_power_source"]
required_items = ["alien_plasma_rifle"]
required_autopsies = ["sectoid"]  # OpenXCOM-style alien autopsy requirement

[research.costs]
research_points = 600
scientist_hours = 1200
credits = 250000

[research.unlocks]
items = ["plasma_rifle", "plasma_pistol", "heavy_plasma"]
manufacturing = ["plasma_clip"]

# Victory condition research (like OpenXCOM's final missions)
[[research]]
id = "alien_base_location"
name = "Alien Base Location"
description = "Discover the location of the alien command base."

[research.requirements]
required_research = ["alien_navigation", "alien_communications"]
required_items = ["alien_commander_corpse"]  # Special drop
required_missions = ["ufo_battleship_assault"]  # Must complete mission type

[research.costs]
research_points = 1000
scientist_hours = 2000
credits = 500000

[research.unlocks]
missions = ["alien_base_assault"]  # Final mission unlocked

[research.effects]
# Global gameplay changes
victory_progress = 50  # 50% toward victory condition
```

### Manufacturing System (OpenXCOM-Style)

Create items through manufacturing, similar to OpenXCOM's workshop system.

**File:** `data/economy/manufacturing.toml`

```toml
[[manufacturing]]
id = "alloy_armor"
name = "Alloy Armor"
category = "armor"

[manufacturing.requirements]
research = ["alien_alloys"]
facility = "workshop"  # Requires workshop

[manufacturing.costs]
engineer_hours = 500
credits = 75000

[manufacturing.materials]
alien_alloy = 5
steel_plate = 10
electronics = 3

[manufacturing.output]
quantity = 1
sell_value = 150000

# OpenXCOM-style ammunition manufacturing
[[manufacturing]]
id = "plasma_clip"
name = "Plasma Clip"
category = "ammunition"

[manufacturing.requirements]
research = ["plasma_weapons"]
facility = "workshop"

[manufacturing.costs]
engineer_hours = 80
credits = 5000

[manufacturing.materials]
alien_power_cell = 1
elerium = 2

[manufacturing.output]
quantity = 1
sell_value = 12000

# Craft manufacturing (like OpenXCOM's Avenger, Firestorm)
[[manufacturing]]
id = "interceptor_mk2"
name = "Advanced Interceptor"
category = "craft"

[manufacturing.requirements]
research = ["advanced_avionics", "alien_propulsion"]
facility = "advanced_hangar"

[manufacturing.costs]
engineer_hours = 5000
credits = 2000000

[manufacturing.materials]
alien_alloy = 50
elerium = 20
advanced_electronics = 30
jet_engine = 2

[manufacturing.output]
quantity = 1
sell_value = 4000000
```

---

## Advanced Modding

### Using Lua Hooks

Hooks let you inject custom Lua code into game systems.

**File:** `scripts/init.lua`

```lua
--- Tutorial Mod Hooks
-- Demonstrates custom Lua logic

local TutorialMod = {}

---Called when damage is calculated
function TutorialMod:damage_calculated(damage, attacker, defender)
    -- Double damage if attacker using tutorial weapon
    if attacker.weapon and attacker.weapon.id == "tutorial_plasma_rifle" then
        print("Tutorial weapon bonus damage!")
        return damage * 2
    end
    return damage
end

---Called when a unit is created
function TutorialMod:unit_created(unit)
    -- Give all snipers a bonus to accuracy
    if unit.class == "tutorial_sniper" then
        unit.firing_accuracy = unit.firing_accuracy + 10
        print("Sniper accuracy bonus applied!")
    end
    return unit
end

---Called when a mission is generated
function TutorialMod:mission_generated(mission)
    -- Add extra enemies to tutorial rescue missions
    if mission.id == "tutorial_rescue" then
        mission.enemies_min = mission.enemies_min + 2
        mission.enemies_max = mission.enemies_max + 3
        print("Rescue mission difficulty increased!")
    end
    return mission
end

---Called every game turn
function TutorialMod:turn_started(turn_data)
    -- Custom logic each turn
    if turn_data.turn_number % 10 == 0 then
        print("10 turns have passed!")
    end
end

---Called when research completes
function TutorialMod:research_completed(research_id, base_id)
    -- Custom completion rewards
    if research_id == "tutorial_plasma_tech" then
        print("Plasma tech unlocked! Bonus credits awarded.")
        local finance = game:getService("finance")
        finance:addCredits(50000)
    end
end

return TutorialMod
```

### Data Validation

Validate your TOML files before testing:

**File:** `scripts/validate.lua`

```lua
local Validator = {}

function Validator.validate_weapon(weapon_data)
    assert(weapon_data.id, "Weapon must have an ID")
    assert(weapon_data.name, "Weapon must have a name")
    assert(weapon_data.stats, "Weapon must have stats")
    assert(weapon_data.stats.damage > 0, "Damage must be positive")
    assert(weapon_data.stats.accuracy >= 0 and weapon_data.stats.accuracy <= 100, 
           "Accuracy must be 0-100")
    return true
end

return Validator
```

### Custom Assets

#### Sprite Guidelines

- **Format**: PNG with transparency
- **Size**: Power of 2 (32x32, 64x64, 128x128)
- **Style**: Pixel art matching game aesthetic
- **Palette**: Limited colors (16-32 colors recommended)

#### Sound Guidelines

- **Format**: OGG Vorbis
- **Sample Rate**: 44100 Hz
- **Channels**: Mono or Stereo
- **Duration**: Keep sounds short (<2 seconds for effects)

---

## Mod Hooks Reference

### Available Hooks

| Hook Name | Parameters | Return | Description |
|-----------|------------|--------|-------------|
| `unit_created` | unit | Modified unit | Called when unit spawns |
| `unit_damaged` | unit, damage | Modified damage | Before damage applied |
| `unit_died` | unit, killer | None | When unit dies |
| `damage_calculated` | damage, attacker, defender | Modified damage | Damage calculation |
| `turn_started` | turn_data | None | Start of each turn |
| `turn_ended` | turn_data | None | End of each turn |
| `mission_generated` | mission | Modified mission | Mission creation |
| `mission_completed` | mission, result | None | Mission finish |
| `research_completed` | research_id, base_id | None | Research done |
| `item_manufactured` | item_id, quantity | None | Manufacturing done |
| `facility_built` | facility_id, base_id | None | Building completed |

### Hook Example: Critical Hits

```lua
function MyMod:damage_calculated(damage, attacker, defender)
    -- 10% chance for critical hit
    local rng = game:getService("rng")
    local roll = rng:random(1, 100)
    
    if roll <= 10 then
        print("CRITICAL HIT!")
        return damage * 2
    end
    
    return damage
end
```

---

## Testing Your Mod

### Debug Mode

Enable debug logging in your mod:

**File:** `config/logging.toml`

```toml
[logging]
enabled = true
level = "DEBUG"
output = "console"
log_file = "logs/tutorial_mod.log"

[logging.categories]
combat = "DEBUG"
missions = "INFO"
units = "DEBUG"
```

### Console Commands

While testing, use console commands:

```
/reload_mods          # Reload all mods
/list_mods            # Show loaded mods
/mod_info my_mod      # Show mod details
/validate_mod my_mod  # Check mod structure
```

### Common Issues

**Mod not loading?**
- Check `main.toml` syntax
- Verify mod ID is unique
- Check console for error messages

**Content not appearing?**
- Verify file paths in `main.toml`
- Check TOML syntax in content files
- Ensure IDs are unique

**Crashes on load?**
- Check for missing required fields
- Validate all file paths exist
- Check for circular dependencies

---

## Publishing

### Preparing for Release

1. **Complete README.md**
   - Installation instructions
   - Features list
   - Compatibility information
   - Known issues
   - Credits

2. **Version Your Mod**
   - Use semantic versioning (1.0.0)
   - Document changes in CHANGELOG.md

3. **Test Thoroughly**
   - Fresh install test
   - Compatibility with other mods
   - Performance testing

4. **Package Your Mod**
   ```
   tutorial_weapon_mod_v1.0.0.zip
   ├── tutorial_weapon_mod/
   │   ├── main.toml
   │   ├── README.md
   │   ├── CHANGELOG.md
   │   └── ... (all mod files)
   ```

### Where to Publish

- GitHub (recommended for open source)
- Mod sharing platforms
- Game community forums
- Discord channels

---

## Troubleshooting

### Error Messages

#### "Mod ID already registered"
**Problem:** Two mods have the same ID  
**Solution:** Change your mod ID to be unique

#### "Failed to load TOML file"
**Problem:** TOML syntax error  
**Solution:** Use TOML validator, check for typos

#### "Missing required field"
**Problem:** Content missing mandatory fields  
**Solution:** Check field requirements in API docs

#### "Circular dependency detected"
**Problem:** Mods depend on each other  
**Solution:** Remove circular dependencies

### Performance Issues

**Mod causes lag?**
- Optimize Lua hooks (avoid heavy calculations)
- Reduce asset sizes
- Cache expensive operations
- Profile with built-in profiler

**High memory usage?**
- Compress images
- Limit asset preloading
- Clean up resources in hooks

---

## Advanced Topics

### Multi-World Support

Mods can add content to specific worlds:

```toml
[[province]]
id = "tutorial_province"
name = "Tutorial Region"
world = "earth"  # Only appears on Earth

[[province]]
id = "tutorial_mars_province"
name = "Mars Settlement"
world = "mars"   # Only appears on Mars
```

### Localization

Support multiple languages:

**File:** `locale/en.toml`
```toml
[strings]
tutorial_weapon_name = "Tutorial Plasma Rifle"
tutorial_weapon_desc = "An experimental plasma weapon."
```

**File:** `locale/es.toml`
```toml
[strings]
tutorial_weapon_name = "Rifle de Plasma Tutorial"
tutorial_weapon_desc = "Un arma de plasma experimental."
```

### Mod Compatibility

Declare compatibility with other mods:

```toml
[dependencies]
required_mods = []
optional_mods = ["long_war_mod"]  # Enhances if present
conflicts = ["incompatible_mod"]  # Can't load together

[compatibility]
mod_priorities = ["long_war_mod"]  # Load after this mod
```

---

## Resources

### Documentation
- [API Documentation](API_DOCUMENTATION.md)
- [Lua Style Guide](LUA_STYLE_GUIDE.md)
- [TOML Specification](https://toml.io/)

### Community
- [Discord Server](https://discord.gg/alienfall)
- [GitHub Repository](https://github.com/alienfall/game)
- [Modding Forums](https://forums.alienfall.com/modding)

### Tools
- [VS Code](https://code.visualstudio.com/)
- [TOML Extension](https://marketplace.visualstudio.com/items?itemName=be5invis.toml)
- [Aseprite](https://www.aseprite.org/) - Pixel art editor
- [Audacity](https://www.audacityteam.org/) - Audio editing

---

## Example Mods

Study these example mods for reference:

1. **example_mod** - Comprehensive example with all content types
2. **unit_expansion** - Custom unit classes and progression
3. **economy_expansion_mod** - Research and manufacturing
4. **craft_expansion_mod** - Custom vehicles and interception

---

## Conclusion

You now have the knowledge to create awesome Alien Fall mods! Start small, test often, and gradually expand your mod's scope. The modding community is here to help!

**Happy Modding!** 🎮✨

---

**Tutorial Version:** 1.0  
**Last Updated:** September 30, 2025  
**Feedback:** Submit issues or suggestions on GitHub
