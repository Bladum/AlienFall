# Battlescape Map

## Goal / Purpose
Manages map data structures, procedural generation algorithms, terrain data, and pathfinding infrastructure for battlescape combat maps.

## Content
- **Map structure** - Grid representation and data layout
- **Terrain system** - Terrain types and properties
- **Pathfinding** - A* and tactical pathfinding
- **Visibility maps** - Pre-calculated visibility data
- **Map validation** - Map integrity checking
- **Map serialization** - Saving and loading maps

## Features
- Efficient map data structures
- Fast pathfinding algorithms
- Visibility pre-calculation
- Map validation tools
- Serialization support
- Mod-compatible map format

## Integrations with Other Folders / Systems
- **engine/battlescape/battlefield** - Map usage in battles
- **engine/battlescape/rendering** - Map visualization
- **engine/core/pathfinding.lua** - Pathfinding algorithms
- **engine/battlescape/maps** - Map storage and definitions
- **engine/battlescape/mapscripts** - Map scripting system
- **engine/core/spatial_hash.lua** - Spatial queries
