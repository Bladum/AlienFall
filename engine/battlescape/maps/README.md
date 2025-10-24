# Battlescape Maps

## Goal / Purpose
Storage and management of battle map definitions, procedurally generated maps, and custom map content for different mission types and locations.

## Content
- **Map definitions** - Map metadata and configurations
- **Tileset references** - Links to visual tilesets
- **Spawn points** - Unit spawn locations and configurations
- **Objective markers** - Objective locations and conditions
- **Legacy maps** - Old map formats and migrations
- **Generated maps** - Procedurally created maps cache

## Features
- Map definition format
- Multiple terrain support
- Spawn configuration
- Objective definition
- Migration tools for legacy maps
- Modular map organization

## Integrations with Other Folders / Systems
- **engine/battlescape/map** - Map data structures
- **engine/battlescape/mission_map_generator.lua** - Map generation
- **engine/battlescape/rendering** - Map visualization
- **engine/mods/tilesets** - Tileset definitions
- **mods/core/mapblocks** - Map block definitions
- **mods/core/mapscripts** - Map scripting
