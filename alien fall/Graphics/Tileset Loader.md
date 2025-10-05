# Tileset Loader

## Overview
The tileset loader manages tile-based graphics assets for terrain, units, and UI elements. Supporting pixel art scaling and animation, it ensures consistent visual style across all game graphics while providing efficient rendering performance.

## Mechanics
- PNG tileset loading and parsing
- Pixel art scaling (12x12 to 24x24 pixels)
- Animation frame management
- Texture atlas optimization
- Memory-efficient asset management
- Cross-resolution compatibility

## Examples
| Asset Type | Tile Size | Animation Frames | Usage |
|------------|-----------|------------------|-------|
| Terrain Tiles | 12x12 | 1-4 (water) | Map backgrounds |
| Unit Sprites | 24x24 | 8 (walking) | Character graphics |
| UI Elements | 12x12 | 1-2 (buttons) | Interface components |
| Effects | 12x12 | 6 (explosion) | Visual feedback |

## References
- Love2D: Image and texture handling
- Classic RPGs - Tileset systems
- See also: Tileset, Animations, Shaders