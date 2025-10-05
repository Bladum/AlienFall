# Team Auto Promotion

## Overview
Team auto promotion automatically generates balanced enemy teams by promoting units within faction and mission constraints. It uses experience points as a budget to upgrade units from their base classes, ensuring appropriate challenge levels. This system creates varied and tactical enemy compositions that scale with mission difficulty and player progression.

## Mechanics
- Faction determines available unit classes for the mission
- Team power represents total experience points budget
- Team size sets maximum number of enemy units
- Team level caps maximum unit advancement level
- Random unit creation and promotion using class-specific advancement paths
- Experience distributed until budget depleted or limits reached
- Default inventories assigned based on promoted classes

## Examples
| Mission Difficulty | Team Power | Team Size | Team Level | Result |
|-------------------|------------|-----------|------------|--------|
| Easy | 500 XP | 4 units | 2 | Basic aliens with minimal upgrades |
| Medium | 1200 XP | 6 units | 4 | Mixed classes with moderate promotion |
| Hard | 2500 XP | 8 units | 6 | Elite units with advanced abilities |

## References
- XCOM: Enemy Within - Alien rank progression
- Civilization VI - Unit experience and promotion
- See also: Units, Mission Deployment, Promotion