# Map Tile

## Overview
Map tiles are the individual terrain elements that make up map blocks, represented by single characters in definition files. Each tile defines movement properties, visibility characteristics, and environmental effects, representing approximately 1-2 meters of physical space with potential elevation differences.

## Mechanics
- Floor/wall movement properties
- Line of sight and fire blocking
- Elevation levels (high/low ground)
- Character representation in map files
- Common stats for similar elements
- Variable graphics from tilesets

## Examples
| Tile Character | Type | Properties | Movement |
|----------------|------|------------|----------|
| . | Open ground | No cover, clear LOS | 1 AP |
| # | Wall | Blocks movement/LOS | Impassable |
| ^ | High ground | Elevation bonus | 1 AP (elevated) |
| ~ | Rough terrain | Partial cover | 2 AP |

## References
- XCOM: Tile-based terrain
- Dwarf Fortress - ASCII tile representation
- See also: Battle Tile, Tileset, Map Prefab