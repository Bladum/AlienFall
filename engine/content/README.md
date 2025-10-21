# Content Folder - Game Data Definitions

This folder contains all **game content** - data-driven definitions of game entities and items that players interact with. This is separate from **core engine code** and enables a clear separation of concerns between game mechanics and game content.

## Folder Structure

```
content/
├── crafts/           # Aircraft/spacecraft definitions
├── items/            # Equipment, weapons, armor
├── units/            # Soldiers, aliens, characters
└── README.md         # This file
```

## Overview

### crafts/
- **Purpose**: Define all player and alien craft/spacecraft
- **Contains**: craft types, armor values, weapon slots, speed
- **Example**: Avenger interceptor, UFO types
- **Usage**: `local Craft = require("content.crafts.craft")`

### items/
- **Purpose**: Define all equipment players can research, manufacture, and equip
- **Contains**: weapons, armor, grenades, medical items, special equipment
- **Example**: Laser rifle, combat armor, first aid kit
- **Usage**: `local Items = require("content.items.items")`

### units/
- **Purpose**: Define all unit types (soldiers, aliens, etc.)
- **Contains**: soldier classes, alien types, stats, inventory slots
- **Example**: Assault trooper, alien terror unit, sectoid
- **Usage**: `local Units = require("content.units.units")`

## Architecture Notes

- **Data-Driven Design**: Content is loaded once and referenced throughout the game
- **Mod-Friendly**: Content can be extended by mods without modifying core code
- **Serialization**: All content is loadable from TOML configuration files in `mods/`
- **Cache**: Content is cached after first load for performance

## Using Content

All content is loaded and managed by the **core.data_loader** system:

```lua
-- Load content via data loader
local DataLoader = require("core.data_loader")
DataLoader.loadAllContent()

-- Access content
local craftData = DataLoader.getCraft("avenger")
local itemData = DataLoader.getItem("laser_rifle")
local unitData = DataLoader.getUnit("assault")
```

## Adding New Content

1. Create TOML file in `mods/core/` (e.g., `weapons.toml`)
2. Define content in TOML format
3. Restart game or use mod manager reload
4. Content automatically accessible via DataLoader

Example TOML:
```toml
[[items]]
id = "plasma_rifle"
name = "Plasma Rifle"
damage = 85
cost = 5000
```

## See Also

- `wiki/FAQ.md` - Game mechanics and content questions
- `wiki/API.md` - Content API reference
- `mods/README.md` - Mod system documentation
- `core/data_loader.lua` - Content loading system
