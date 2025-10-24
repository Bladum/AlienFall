# Core Mod: Tilesets

## Goal / Purpose

The Tilesets folder contains visual tile definitions and sprite sheets for all battlescape environments. Tilesets define the graphics, terrain properties, and collisions for different map environments.

## Content

- **_common/** - Shared tiles used across all environments
- **city/** - Urban environment tiles
- **farmland/** - Rural and agricultural tiles
- **furnitures/** - Indoor props and furniture
- **ufo_ship/** - Alien spacecraft interior tiles
- **weapons/** - Weapon and equipment visual definitions

## Features

- **Sprite Sheets**: Organized visual assets
- **Terrain Types**: Different ground surface definitions
- **Collisions**: Walkable vs. blocked areas
- **Cover & Height**: Tactical information
- **Animations**: Multi-frame tile animations
- **Environmental Hazards**: Radiation, fire, etc.
- **Interactable Objects**: Doors, switches, objectives

## Integrations with Other Systems

### Battlescape Rendering
- Used by `engine/battlescape/rendering/` for map display
- Sprite selection for different environments
- Animation management

### Map Generation
- Mapblocks reference tilesets
- Tileset determines environment visuals
- Terrain properties from tileset

### Pathfinding & Collision
- Collision data from tilesets
- Walkability and cover information
- Height-based tactical advantages

### Mission System
- Mission types use different tilesets
- Terrain affects mission difficulty
- Environment-specific challenges

### Procedural Generation
- Tileset selection in generation config
- Environment variety
- Biome-based tileset choices

### Design Specifications
- Tileset design in `design/mechanics/Assets.md`
- Environment design in `design/mechanics/`

## Tileset Organization

Each tileset directory contains:
- Sprite sheet images
- Configuration files defining tile properties
- Animation definitions
- Collision map data
- Metadata and documentation

## Creating Tilesets

1. Prepare sprite art (24×24 pixel base)
2. Organize into sheets
3. Define tile properties (walkable, cover, height)
4. Create collision/pathfinding data
5. Configure animations
6. Test in-game
7. Document in README

## See Also

- [Core Mod README](../README.md) - Core content overview
- [Mapblocks](../mapblocks/README.md) - Map composition
- [Assets API](../../api/ASSETS.md) - Asset system interface
- [Design Assets](../../design/mechanics/Assets.md) - Asset design specs
- [Battlescape Rendering](../../engine/battlescape/rendering/README.md) - Rendering system
