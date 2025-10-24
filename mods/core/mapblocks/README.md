# Core Mod: Map Blocks

## Goal / Purpose

The Mapblocks folder contains individual map block definitions used in tactical battlescape map generation. Mapblocks are pre-built terrain sections that are combined to create complete battlescape missions.

## Content

- Mapblock configuration files (.toml)
- Terrain layout definitions
- Spawn point configurations
- Objective marker positions
- Environmental features and props

## Features

- **Modular Map Design**: Pre-built sections for map composition
- **Terrain Variety**: Different environment types
- **Spawn Configuration**: Enemy and player starting positions
- **Objective Markers**: Mission objectives and interactable locations
- **Environmental Props**: Buildings, trees, rocks, vehicles
- **Tactical Zones**: Cover, high ground, corridors
- **Performance Optimization**: Efficiently composed maps

## Integrations with Other Systems

### Map Generation
- Mapblocks composed by `engine/battlescape/mission_map_generator.lua`
- Random selection creates unique maps
- Tileset references for rendering

### Battlescape
- Map composition for tactical combat
- Spawn point definitions for units
- Objective placement for mission success

### Procedural Generation
- Used by mission generation system
- Configurable in `generation/map_generation.toml`
- Weighted selection for variety

### Tileset System
- References tiles from `mods/core/tilesets/`
- Each mapblock has tileset mapping
- Supports multiple tilesets per block

### Design Specifications
- Map design principles in `design/mechanics/Battlescape.md`
- Tactical layout guidelines in `design/mechanics/`

## Mapblock Types

- **Urban**: City blocks, buildings, streets
- **Rural**: Farms, open fields, sparse terrain
- **Industrial**: Warehouses, factories, vehicles
- **Alien**: UFO interiors, dimensional rifts
- **Special**: Unique mission-specific locations

## Creating Mapblocks

1. Define terrain layout in TOML
2. Specify spawn points for units
3. Mark objective locations
4. Add environmental features
5. Map to appropriate tileset
6. Test for tactical balance
7. Document in README

## See Also

- [Core Mod README](../README.md) - Core content overview
- [Map Generation](../generation/README.md) - Generation configuration
- [Mapscripts](../mapscripts/README.md) - Mission templates
- [Tilesets](../tilesets/README.md) - Visual assets
- [Battlescape Design](../../design/mechanics/Battlescape.md) - Tactical design
- [Battlescape API](../../api/BATTLESCAPE.md) - Map system interface
