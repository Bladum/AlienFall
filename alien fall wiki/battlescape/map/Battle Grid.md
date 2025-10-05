# Battle Grid System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Structure](#core-structure)
  - [Grid Conversion Process](#grid-conversion-process)
  - [Grid Systems](#grid-systems)
  - [Performance Optimization](#performance-optimization)
- [Examples](#examples)
  - [Urban Combat Grid](#urban-combat-grid)
  - [Rural Terrain Grid](#rural-terrain-grid)
  - [Indoor Facility Grid](#indoor-facility-grid)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battle Grid System implements the detailed 2D array of Battle Tiles that forms the playable tactical battlefield, converted from the Map Grid through a deterministic expansion process. It represents the interactive game world where all tactical combat occurs, combining static terrain properties with dynamic game state including unit occupancy, environmental effects, and fog of war. The system ensures efficient performance across variable grid sizes while maintaining real-time tactical gameplay.

The grid serves as the foundation for all tactical interactions, providing the spatial framework that determines movement possibilities, line of sight calculations, area effects, and strategic positioning. Data-driven tile definitions and optimized algorithms enable extensive modding support while maintaining consistent gameplay mechanics across different mission types and terrain configurations.

## Mechanics

### Core Structure
Fundamental organization of the tactical battlefield grid.

#### Tile Array
Two-dimensional grid of Battle Tiles forming the playable area.

**Grid Properties:**
- **Dimensions**: Variable size (60×60 to 105×105 tiles) based on Battle Size
- **Tile Resolution**: 20×20 pixels per tile for grid-aligned positioning
- **Total Area**: 1200×1200 to 2100×2100 pixels of tactical space
- **Coordinate System**: Integer coordinates from (0,0) at top-left

#### Battle Tile Composition
Each grid position contains a complete Battle Tile with comprehensive game state.

**Tile Components:**
- **Terrain Base**: Static properties inherited from Map Tile conversion
- **Unit Occupant**: Single unit that may occupy the tile or null state
- **Environmental Effects**: Smoke, fire, weather impacts with intensity levels
- **Interactive Objects**: Deployables, hazards, mission-critical objects
- **Fog of War State**: Per-faction visibility tracking for asymmetric information

### Grid Conversion Process
Deterministic transformation from abstract Map Grid to interactive battlefield.

#### Map Grid to Battle Grid
Systematic conversion of Map Blocks into detailed tactical terrain.

**Conversion Steps:**
1. **Block Expansion**: Convert each 15×15 Map Block to individual Battle Tiles
2. **Property Inheritance**: Transfer terrain characteristics and blocking rules
3. **State Initialization**: Set up dynamic state containers for each tile
4. **Entity Integration**: Place units, objects, and environmental effects

#### Dynamic State Addition
Enhancement of static terrain with interactive gameplay elements.

**State Layers:**
- **Occupancy**: Unit positioning and collision detection
- **Effects**: Active environmental conditions with propagation rules
- **Visibility**: Fog of war and line-of-sight calculations per faction
- **Interaction**: Usable objects, triggers, and mission elements

### Grid Systems
Core tactical systems operating on the battle grid foundation.

#### Pathfinding Integration
Movement calculations and navigation across the battle grid.

**Pathfinding Features:**
- **Terrain Costs**: Variable movement costs per tile type and unit capabilities
- **Dynamic Obstacles**: Moving units and temporary environmental blockages
- **Optimization**: Hierarchical algorithms for large grid performance
- **Special Movement**: Flying, climbing, and unit-specific traversal rules

#### Line of Sight Calculations
Visibility determination between grid positions for tactical awareness.

**Sight Mechanics:**
- **Tile-based Resolution**: Direct line calculations between tile centers
- **Blocking Terrain**: Walls, elevation, and obstacles interrupt sight lines
- **Environmental Effects**: Smoke, weather, and lighting reduce visibility
- **Height Differences**: Elevation changes affect line-of-sight ranges

#### Area of Effect Resolution
Combat effects applied across multiple grid positions.

**Effect Types:**
- **Explosions**: Radial damage patterns from center point with falloff
- **Area Attacks**: Cone, line, or burst patterns for tactical weapons
- **Environmental Spread**: Fire propagation, smoke dispersion, hazard expansion
- **Chain Reactions**: Primary effects triggering secondary environmental changes

### Performance Optimization
Technical systems for efficient handling of extensive battlefields.

#### Large Grid Management
Efficient processing of variable-sized tactical environments.

**Optimization Techniques:**
- **Spatial Partitioning**: Divide grid into manageable chunks for processing
- **Lazy Evaluation**: Calculate expensive properties on demand
- **Memory Pooling**: Reuse tile objects and effect structures efficiently
- **Rendering Culling**: Process only visible portions of large battlefields

#### Real-time Updates
Maintaining performance during active tactical combat.

**Update Strategies:**
- **Incremental Changes**: Update only tiles affected by specific actions
- **Batch Operations**: Group similar calculations and state changes
- **Asynchronous Processing**: Background effect propagation and AI calculations
- **Cache Management**: Store frequently accessed pathfinding and visibility data

## Examples

### Urban Combat Grid
Dense city environment with mixed terrain and cover opportunities.

**Grid Characteristics:**
- **Dimensions**: 75×75 tiles (5625 total tactical positions)
- **Terrain Mix**: 40% open streets, 35% building interiors, 25% rubble and debris
- **Cover Distribution**: High concentration of hard cover from walls and vehicles
- **Line of Sight**: Complex blocking patterns from urban structures
- **Movement**: Varied costs from clear streets to obstructed alleys

**Tactical Implications:**
- **Positioning**: Critical use of elevation and building control
- **Mobility**: Limited by narrow streets and structural barriers
- **Visibility**: Frequent line-of-sight breaks requiring careful advancement

### Rural Terrain Grid
Open battlefield with natural features and elevation changes.

**Grid Characteristics:**
- **Dimensions**: 90×90 tiles (8100 total tactical positions)
- **Terrain Mix**: 60% open ground, 25% wooded areas, 15% elevation features
- **Cover Distribution**: Scattered soft cover from trees and low obstacles
- **Line of Sight**: Long ranges with occasional blocking from hills and forests
- **Movement**: Generally open with some difficult terrain penalties

**Tactical Implications:**
- **Positioning**: Elevation provides significant defensive advantages
- **Mobility**: High mobility across open spaces with flanking opportunities
- **Visibility**: Long sight lines enable coordinated fire and movement

### Indoor Facility Grid
Confined environment with structural complexity and limited visibility.

**Grid Characteristics:**
- **Dimensions**: 60×60 tiles (3600 total tactical positions)
- **Terrain Mix**: 50% corridors and rooms, 30% structural walls, 20% open areas
- **Cover Distribution**: Abundant hard cover from walls and furniture
- **Line of Sight**: Severely restricted by walls and doorways
- **Movement**: Channelled through corridors with bottleneck control points

**Tactical Implications:**
- **Positioning**: Doorway and corner control critical for room clearing
- **Mobility**: Limited by structural constraints and choke points
- **Visibility**: Very short engagement ranges requiring close-quarters tactics

## Related Wiki Pages

Battle Grid forms the tactical foundation for all battlescape systems:

- **Battlefield.md**: Complete tactical environment containing the battle grid
- **Battle Tile.md**: Individual grid cells with terrain and state properties
- **Map Grid.md**: Source structure converted into battle grid
- **Battle Size.md**: Determines grid dimensions and scale parameters
- **Pathfinding**: Movement calculations across grid positions
- **Line of Sight**: Visibility calculations between grid coordinates
- **Area Effects**: Explosions and environmental effects on grid
- **Fog of War**: Visibility state management per grid position
- **Unit Movement**: Position updates and collision detection
- **AI Systems** (ai/): Pathfinding and positioning for computer-controlled units

## References to Existing Games and Mechanics

The Battle Grid system draws from grid-based tactical gameplay:

- **X-COM series (1994-2016)**: Turn-based tactical combat on tile-based grids
- **Fire Emblem series (1990-2023)**: Grid-based movement and positioning
- **Tactical RPGs**: Grid systems in games like Final Fantasy Tactics
- **Tabletop Wargames**: Hex and square grid movement systems
- **Real-time Strategy**: Grid-based pathfinding in Commandos series
- **Roguelikes**: Grid-based dungeon crawling in Dwarf Fortress
- **Tower Defense**: Grid positioning and pathfinding mechanics