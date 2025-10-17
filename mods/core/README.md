# Core Mod - AlienFall Content

This directory contains the core content definitions for AlienFall, structured as a loadable mod.

## Directory Structure

```
mods/core/
├── rules/                    # Game rules and definitions
│   ├── units/               # Unit type definitions (soldiers, aliens, civilians)
│   ├── items/               # Item definitions (weapons, armour, ammo)
│   ├── facilities/          # Base facility definitions
│   └── missions/            # Mission type definitions
├── campaigns/               # Campaign phase definitions and timelines
├── factions/                # Faction definitions with units and tech trees
├── technology/              # Technology research trees
├── narrative/               # Story events and narrative elements
├── geoscape/                # Geoscape (world map) definitions
├── economy/                 # Economic system data (funding, marketplace)
├── tilesets/                # Pixel art tilesets
├── mapblocks/               # Procedural map block definitions
├── mapscripts/              # Map generation scripts
└── mod.toml                 # Mod configuration file
```

## Content Types

### Rules
- **units/**: Soldier, alien, and civilian unit definitions with stats
- **items/**: Weapons, armour, ammunition, and equipment
- **facilities/**: Base facilities, research labs, manufacturing plants
- **missions/**: Mission types and configurations

### Campaigns & Factions
- **campaigns/**: Campaign phase definitions (Shadow War, Sky War, Deep War, Dimensional War)
- **factions/**: 15+ faction definitions with units, tech, and characteristics

### Systems
- **technology/**: Research tree definitions and tech progression
- **narrative/**: Story events, briefings, and dialogue
- **geoscape/**: Countries, regions, funding sources, and world events
- **economy/**: Marketplace items, pricing, and economic rules

## Loading Content

All content in this mod is loaded through `engine/core/data_loader.lua` during game initialization:

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

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
