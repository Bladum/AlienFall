# Pathfinding AI

## Goal / Purpose

The Pathfinding AI folder contains advanced pathfinding algorithms and tactical movement systems. This includes A* pathfinding, tactical movement considering cover and threats, and strategic route planning for both tactical combat and strategic movement.

## Content

- `pathfinding.lua` - General A* pathfinding algorithm implementation
- `tactical_pathfinding.lua` - Combat-aware pathfinding considering cover, visibility, and threat zones

## Features

- **A* Pathfinding**: Efficient shortest-path finding algorithm
- **Tactical Movement**: Path planning that considers:
  - Cover positions and defensive terrain
  - Visible enemy fire lanes and threat zones
  - Action point (TU) limitations
  - Movement speed and unit type
- **Cost Heuristics**: Dynamic cost calculations based on:
  - Terrain type and movement cost
  - Visibility and exposure risk
  - Defensive value (cover)
  - Threat proximity
- **Obstacle Avoidance**: Pathfinding around units, walls, and terrain
- **Multi-Target Pathing**: Find paths to multiple destinations
- **Cache Optimization**: Store frequently used paths for performance

## Integrations with Other Systems

### Battlescape
- Used for unit movement during tactical combat
- Integrates with `engine/battlescape/combat/` for combat resolution
- Works with `engine/battlescape/entities/` for unit placement
- Connected to line-of-sight and visibility systems

### AI Decision System
- Provides movement options for `engine/ai/tactical/decision_system.lua`
- Evaluates threat zones for AI unit positioning
- Supports flanking and tactical positioning

### Map Systems
- Reads from `engine/battlescape/map/` for terrain data
- Uses tileset information for movement costs
- Respects obstacle and collision data

### Performance Optimization
- Part of core spatial queries and optimization
- Uses spatial hashing from `engine/core/spatial_hash.lua`
- Contributes to frame-time budgeting

## See Also

- [AI Systems README](../README.md) - Main AI systems overview
- [Battlescape README](../../battlescape/README.md) - Tactical combat system
- [Map Systems README](../../battlescape/map/README.md) - Terrain and map data
- [Combat Systems README](../../battlescape/combat/README.md) - Combat resolution
