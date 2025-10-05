# Battle Grid

## Overview
The battle grid is the unified 2D spatial representation created by linking all map tiles into a single massive array. This enormous grid (up to 105x105 tiles) serves as the foundation for all tactical gameplay, providing the coordinate system for unit movement, combat calculations, and environmental interactions.

## Mechanics
- Massive 2D array structure (up to 105x105 tiles)
- Coordinate system for all game calculations
- Terrain and object integration
- Pathfinding foundation
- Line of sight and fire computations
- Unit and effect positioning

## Examples
| Grid Size | Use Case | Tile Count | Memory Impact |
|-----------|----------|------------|---------------|
| 35x35 | Small skirmish | 1,225 | Low |
| 70x70 | Standard battle | 4,900 | Medium |
| 105x105 | Large engagement | 11,025 | High |

## References
- XCOM: Battlescape grid system
- Civilization VI - Hex/tile-based maps
- See also: Battle Tile, Map Grid, Map Generator