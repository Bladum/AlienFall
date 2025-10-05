# Battle Tile

## Overview
A battle tile is the fundamental unit of the battle grid, containing terrain information, objects, occupying units, and environmental effects. Each tile serves as the basic element for all spatial calculations including pathfinding, line of sight, and line of fire, representing approximately 1-2 meters of physical space.

## Mechanics
- Terrain type (floor/wall properties)
- Object placement and interactions
- Unit occupation and stacking
- Environmental effects (smoke, fire, fog)
- Elevation and height differences
- Cover and concealment calculations

## Examples
| Tile Type | Properties | Movement Cost | Cover Value |
|-----------|------------|---------------|-------------|
| Open Ground | Floor, no cover | 1 | None |
| Low Wall | Partial cover | 2 | 25% |
| High Wall | Full cover | Impassable | 75% |
| Rough Terrain | Difficult ground | 3 | None |

## References
- XCOM: Tile-based battlescape
- Into the Breach - Grid-based combat
- See also: Map Tile, Battle Grid, Line of Sight