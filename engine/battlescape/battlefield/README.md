# Battlescape Battlefield

## Goal / Purpose
Manages the physical battle environment including the map grid, terrain, unit positioning, line of sight, field of view, and environmental interactions during combat.

## Content
- **Map grid** - Grid-based position system for units
- **Terrain system** - Terrain types and properties
- **Height levels** - Z-axis height management
- **Unit positioning** - Unit location and occupation tracking
- **Line of sight (LoS)** - Visibility calculation
- **Field of view (FoV)** - Player and unit vision ranges
- **Environmental objects** - Cover, obstacles, destructibles
- **Fog of war** - Hidden information management

## Features
- Grid-based positioning system
- Real-time LoS/FoV calculations
- Multi-level elevation support
- Cover and obstacle system
- Vision-based information hiding
- Procedural terrain generation

## Integrations with Other Folders / Systems
- **engine/battlescape/map** - Map data and generation
- **engine/battlescape/rendering** - Battlefield visualization
- **engine/battlescape/entities** - Unit positioning
- **engine/battlescape/combat** - Cover calculations for combat
- **engine/battlescape/systems** - Battlefield state management
- **engine/core/spatial_hash.lua** - Efficient spatial queries
- **engine/battlescape/battle** - Battle state
