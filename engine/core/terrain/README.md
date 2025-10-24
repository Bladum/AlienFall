# Core Terrain

## Goal / Purpose
Manages terrain system data and utilities including terrain types, properties, movement costs, and visual representations for both battlescape and geoscape.

## Content
- **Terrain definitions** - Terrain type specifications
- **Terrain properties** - Movement costs, cover values, difficulty
- **Terrain rendering** - Visual representation data
- **Terrain types** - Categories and classifications
- **Terrain interactions** - Environmental effects and rules
- **Height/elevation data** - Multi-level terrain support

## Features
- Modular terrain definitions
- Configurable properties
- Multiple terrain types
- Elevation support
- Performance optimization

## Integrations with Other Folders / Systems
- **engine/battlescape/battlefield** - Battlescape terrain
- **engine/battlescape/rendering** - Terrain visualization
- **engine/geoscape/geography** - Geoscape terrain
- **engine/core/pathfinding.lua** - Terrain costs in pathfinding
- **engine/core/data** - Terrain configuration
- **mods/core/tilesets** - Tileset terrain data
