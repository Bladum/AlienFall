# Battle Field

## Overview
The battle field represents the complete tactical environment where combat occurs, encompassing the battle grid with all units, factions, squads, and environmental effects. It manages fog of war, smoke, fire, and AI behavior while serving as the central hub for all battlescape calculations and interactions.

## Mechanics
- Battle grid management with unit positioning
- Faction and squad tracking
- Fog of war calculation and updates
- Environmental effects (smoke, fire) propagation
- AI decision-making and pathfinding
- Line of sight and line of fire computations
- Turn-based action resolution

## Examples
| Component | Function | Data Tracked | Update Frequency |
|-----------|----------|--------------|------------------|
| Unit Positions | Combat locations | X,Y coordinates, elevation | Per action |
| Fog of War | Visibility | Explored tiles, current LOS | Per turn |
| Environmental Effects | Hazard areas | Smoke clouds, fire spread | Per turn |
| AI State | Enemy behavior | Squad formations, objectives | Per turn |

## References
- XCOM: Battlescape management
- Fire Emblem - Tactical map systems
- See also: Battle Grid, Battle Tile, Map Generator