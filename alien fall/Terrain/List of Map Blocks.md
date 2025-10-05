# List of Map Blocks

## Overview
The List of Map Blocks defines which prefabricated terrain sections can be used during procedural map generation for specific terrain types. This system ensures thematic consistency and provides the building blocks for creating diverse, strategically interesting battlefields.

## Mechanics
- **Terrain Association**: Each terrain type has associated block types
- **Procedural Selection**: Map generator chooses appropriate blocks based on biome
- **Connectivity Rules**: Blocks must connect seamlessly for navigation
- **Density Control**: Ensures balanced cover and open areas
- **Mod Extensibility**: New blocks can be added through mods
- **Performance Optimization**: Pre-calculated block combinations

## Examples
| Terrain Type | Block Types | Strategic Purpose |
|--------------|-------------|-------------------|
| Urban | Buildings, Streets, Alleys | Verticality, cover variety |
| Forest | Tree clusters, Clearings, Streams | Concealment, movement channels |
| Desert | Dunes, Rock formations, Canyons | Long sight lines, ambush spots |
| Industrial | Factories, Pipes, Storage tanks | Complex cover, hazardous areas |
| Rural | Farms, Roads, Hills | Open spaces, elevation changes |

## References
- XCOM: Terrain variety in generated maps
- Procedural generation systems
- See Map Block for individual block mechanics
- See Map Generator for assembly process