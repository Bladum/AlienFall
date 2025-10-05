# Map Block

## Overview
Map blocks are modular 15x15 (or multiples) sections of map tiles that serve as the core building elements for procedural map generation. Defined in external text files and grouped by terrain type, they contain specific gameplay features and can be rotated or mirrored during generation to create varied layouts.

## Mechanics
- Modular 15x15 tile sections (can be 45x15, etc.)
- Terrain-based grouping and categorization
- Rotational and mirroring transformations
- Prefab reuse for consistent elements
- Single-layer design (no multi-floor like XCOM)
- External text file definitions

## Examples
| Block Type | Size | Terrain Features | Gameplay Elements |
|------------|------|------------------|-------------------|
| Urban Street | 15x15 | Roads, buildings | Cover, chokepoints |
| Forest Clearing | 15x15 | Trees, underbrush | Concealment, rough terrain |
| Industrial Complex | 45x15 | Factories, machinery | Complex cover, hazards |

## References
- XCOM: Map block generation
- Dwarf Fortress - Modular world generation
- See also: Map Prefab, Map Script, Map Generator