# Tileset

## Overview
Tilesets are collections of PNG image files (sprite atlases) that provide visual representations for map tiles. Each tileset contains multiple graphic variations for terrain types, allowing for visual diversity while maintaining consistent gameplay properties through 12x12 or 24x24 pixel tiles.

## Mechanics
- PNG sprite atlas format
- 12x12 pixel base size (24x24 for retina)
- Single character mapping to graphics
- Random graphic selection for variety
- Terrain type to tileset association
- Memory-efficient texture management

## Examples
| Terrain Type | Tileset File | Tile Variations | Pixel Size |
|--------------|--------------|-----------------|------------|
| Grass | grass_tiles.png | 8 variants | 12x12 |
| Urban | urban_tiles.png | 12 variants | 12x12 |
| Forest | forest_tiles.png | 6 variants | 24x24 |

## References
- Love2D: Sprite and texture management
- XCOM: Tile-based graphics
- See also: Map Tile, Map Prefab, Graphics