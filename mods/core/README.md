# Core Mod - AlienFall Production Content

**Status:** ✅ Production-Ready
**Version:** 1.0.0
**Purpose:** Official complete, balanced game content

---

## Overview

The core mod is the official production mod for AlienFall. It contains all the complete, balanced, and quality-assured content for a full gameplay experience.

### Features

✅ **Complete Content:** All unit types, weapons, research, missions  
✅ **Balanced:** Thoroughly tested and balanced for enjoyable gameplay  
✅ **LORE Compliant:** All content matches the game story and universe  
✅ **High Quality:** Professional sprites, audio, and documentation  
✅ **Production-Ready:** Used by default in the game  

### What's Included

- 50+ unit types (soldiers, aliens, civilians)
- 100+ items and weapons
- 30+ research technologies
- 15+ faction definitions
- Campaign progression system
- Complete world map (geoscape)
- Economy and marketplace
- 20+ mission types
- All artwork and audio assets

---

## Directory Structure

```
mods/core/
├── mod.toml                    ← Mod metadata
├── README.md                   ← This file
├── rules/                      ← Game rules and definitions
│   ├── units/                 # Unit type definitions
│   │   ├── soldiers/          # Player units
│   │   ├── aliens/            # Enemy units
│   │   └── civilians/         # Non-combatants
│   ├── items/                 # Item definitions
│   │   ├── weapons/           # Weapons (ballistic, laser, plasma)
│   │   ├── armor/             # Armor types
│   │   ├── equipment/         # Grenades, scanners, etc.
│   │   └── ammunition/        # Ammo types
│   ├── facilities/            # Base facilities
│   │   ├── hangars/           # Aircraft storage
│   │   ├── labs/              # Research facilities
│   │   ├── factories/         # Manufacturing
│   │   └── utilities/         # Power, storage, etc.
│   ├── crafts/                # Aircraft definitions
│   ├── research/              # Technology tree
│   ├── manufacturing/         # Production recipes
│   ├── missions/              # Mission definitions
│   ├── aliens/                # Alien species
│   ├── regions/               # World regions
│   ├── countries/             # Country definitions
│   └── economy/               # Economy definitions
├── campaigns/                 # Campaign phase definitions
├── factions/                  # Faction definitions
├── technology/                # Research tree organization
├── narrative/                 # Story events and dialogue
├── geoscape/                  # World map definitions
├── economy/                   # Economic data
├── tilesets/                  # Pixel art tilesets
├── mapblocks/                 # Procedural map blocks
├── mapscripts/                # Map generation scripts
├── assets/                    # Game assets
│   ├── sprites/               # Character sprites
│   ├── items/                 # Item icons
│   ├── ui/                    # UI graphics
│   ├── audio/                 # Sound effects
│   │   ├── weapons/
│   │   ├── explosions/
│   │   └── music/
│   └── fonts/                 # Custom fonts
└── lore/                      # Story content and background

```

## Content Organization

### Units

**Soldiers (Player Units)**
- Rookies: Basic trainees
- Experienced: Field-tested soldiers
- Specialists: Advanced soldiers with perks
- Classes: Soldiers, Heavies, Scouts, Medics

**Aliens (Enemy Units)**
- Early Game: Sectoids, Floaters
- Mid Game: Mutons, Snakemen
- Late Game: Chryssalids, Ethereals

**Civilians**
- Non-combatants for terror missions
- Diverse representations

### Items & Equipment

**Weapons**
- Ballistic (early): Rifles, pistols, shotguns
- Laser (mid): Laser rifle, cannon, pistol
- Plasma (late): Plasma rifle, heavy plasma

**Armor**
- Progression: Jumpsuit → Personal Armor → Power Armor → Flying Armor

**Equipment**
- Grenades, medkits, motion scanners, etc.

### Research Tech Tree

**Early Game**
- Ballistic weapon improvements
- Basic armor research
- Basic facilities

**Mid Game**
- Laser weapons
- Advanced armor
- Alien artifact research

**Late Game**
- Plasma weapons
- Power armor
- Alien technology integration

### Missions

- UFO Crashes
- Terror Attacks
- Research Sites
- Alien Bases
- Interrogations

---

## Design Philosophy

### LORE Compliance

All content fits the AlienFall universe and story. Every unit, weapon, and technology has a place in the narrative.

### Balance

Content is balanced for:
- Engaging gameplay
- Progression through game phases
- Multiple viable strategies
- Challenge and difficulty

### Quality

- Professional artwork and audio
- Consistent tone and style
- Comprehensive documentation
- Well-tested and validated

### Modularity

Content is organized for:
- Easy modification
- Clear dependencies
- Extensibility
- Mod compatibility

---

## Validation

The core mod passes all validators:

```bash
# API validation (structure)
lovec tools/validators/validate_mod.lua mods/core

# Content validation (references)
lovec tools/validators/validate_content.lua mods/core

# Both should pass ✅
```

---

## Loading Content

Content is loaded automatically during game startup through the data loader system in `engine/core/data_loader.lua`.

### Load Order

1. Core mod metadata (mod.toml)
2. TOML rule files in order
3. Asset files
4. Validation and error checking
5. Integration into game systems

---

## Modifying Core Content

### Adding New Content

1. Create TOML file in appropriate folder: `rules/[category]/[name].toml`
2. Follow GAME_API.toml schema
3. Run validators:
   ```bash
   lovec tools/validators/validate_mod.lua mods/core
   lovec tools/validators/validate_content.lua mods/core
   ```
4. Test in game
5. Document changes in this README

### Updating Existing Content

1. Edit TOML file
2. Run validators to catch errors
3. Test changes in game
4. Verify no breaking references

### Adding Assets

1. Add sprite/audio file to `assets/[type]/`
2. Reference in TOML: `sprite = "assets/sprites/unit.png"`
3. Run content validator to check file exists

---

## File Examples

### Unit Definition

```toml
[unit]
id = "soldier"
name = "Soldier"
type = "soldier"
race = "human"
health = 65
accuracy = 70
time_units = 60
armor = "jumpsuit"
sprite = "assets/sprites/soldier.png"
```

### Weapon Definition

```toml
[item]
id = "rifle_standard"
name = "Rifle"
type = "weapon"
damage = 25
fire_rate = 1.0
accuracy = 70
ammo = "ammo_rifle"
requires = ["ballistic_weapons"]
```

### Research Definition

```toml
[research]
id = "laser_weapons"
name = "Laser Weapons"
time = 240
cost = 600
requires = ["alien_artifact_analysis"]
unlocks_items = ["laser_rifle", "laser_cannon"]
description = "Development of laser-based weaponry"
```

---

## Statistics

| Category | Count |
|----------|-------|
| Units | 50+ |
| Items/Weapons | 100+ |
| Research Techs | 30+ |
| Factions | 15+ |
| Facilities | 20+ |
| Crafts | 10+ |
| Missions | 20+ |
| Regions | 20+ |
| Audio Files | 100+ |
| Sprite Files | 200+ |

---

## Maintenance

The core mod is actively maintained by the AlienFall team. Report issues:
- GitHub Issues
- Discord: #mod-core
- Email: core@alienfall.dev

---

## Related Documentation

- **GAME_API:** `api/GAME_API.toml` - Complete API schema
- **Modding Guide:** `api/MODDING_GUIDE.md` - How to create mods
- **Validators:** `tools/validators/README.md` - Validation tools
- **IDE Setup:** `docs/IDE_SETUP.md` - Development environment

---

## Content Contributions

Interested in contributing to core mod content?

1. Follow design philosophy and balance principles
2. Test thoroughly with validators
3. Submit pull request with documentation
4. Core team reviews and approves
5. Content merged into core mod

---

**Load Time:** 3-5 seconds  
**Complexity:** Complete  
**Use Case:** Full Gameplay  
**Gameplay Ready:** ✅ Yes  
**Validator Compliant:** ✅ Yes  
**Production Status:** ✅ Production Ready

-- Access loaded content
local weapon = DataLoader.weapons.get("plasma_rifle")
local faction = DataLoader.factions.get("faction_sectoids")
local facility = DataLoader.facilities.get("command_center")
```

## Adding New Content

1. Create a TOML file in the appropriate directory
2. Follow the schema documented in `docs/mods/toml_schemas/`
3. Add loader function in `engine/core/data_loader.lua` if creating new content type
4. Restart the game to load new content

## File Formats

All content files use **TOML 1.0.0** format for readability and mod-ability.

See `docs/mods/toml_schemas/` for complete schema documentation.

## Example Usage

```toml
# mods/core/rules/units/soldiers.toml
[[unit]]
id = "soldier_rookie"
name = "Rookie Soldier"
type = "soldier"
faction = "xcom"
image = "units/soldier.png"

[unit.stats]
health = 30
armor = 0
will = 60
reaction = 50
```

## Related Documentation

- **API Reference**: `docs/API.md`
- **FAQ**: `docs/FAQ.md`
- **TOML Schemas**: `docs/mods/toml_schemas/`
- **Mod Development**: `docs/mods/modding_guide.md`
