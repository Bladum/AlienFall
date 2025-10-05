# Battlefield Sight and Sense System

## Overview
The Battlefield Sight and Sense System determines how units perceive their environment during tactical combat, incorporating directional sight, omnidirectional sensing, and cover mechanics. This system creates fog-of-war effects and tactical depth by limiting visibility based on unit facing, environmental conditions, and protective elements. It integrates with the Battle Turn System to reveal map areas as units move and act.

## Mechanics
- **Sight**: Units can see tiles in a 90-degree cone in their facing direction, extending N tiles; affected by day/night cycles reducing visibility at night.
- **Sense**: Provides omnidirectional detection of 2-3 tiles around the unit, unaffected by time of day, useful for detecting hidden enemies.
- **Cover**: Reduces enemy sight and sense effectiveness; can be natural (terrain) or artificial (armor, items).
- **Integration**: Sight reveals map tiles during movement; sense helps in close-quarters detection.

## Examples

Visibility Ranges Table:

| Condition | Sight Range | Sense Range | Cover Effectiveness |
|-----------|-------------|-------------|---------------------|
| Daytime | 5-8 tiles | 2-3 tiles | Moderate |
| Nighttime | 2-4 tiles | 2-3 tiles | High |
| Urban Terrain | Reduced by buildings | Unaffected | High |

Diagram: Unit facing north sees cone of tiles ahead; sense detects circle around; cover blocks lines of sight.

## References
- **XCOM Series**: Cone-of-sight vision with cover mechanics and night penalties.
- **Silent Storm**: Detailed line-of-sight and cover systems.
- **Jagged Alliance**: Fog of war with directional visibility.