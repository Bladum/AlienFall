# Energy Pool System

## Overview
The Energy Pool System manages the stamina and resource reserves for both units in battlescape and crafts in interception missions, representing physical endurance, fuel, and operational capacity. It regenerates slowly over time but can be depleted by intensive actions, forcing strategic resource management. This system integrates with the Action Point System, limiting actions when energy is low, and fully restores after battles.

## Mechanics
- **Energy Uses**: Supports stamina for units, fuel and ammo for crafts, and general endurance for sustained operations.
- **Regeneration**: Recovers at 1/3 of max energy per turn; full restoration occurs after battle.
- **Base Values**: Human units range 6-12; crafts range 60-120; enhanced by equipment.
- **Action Costs**: Movement typically costs 0 (walking) or 1 (running); weapon modes vary (e.g., burst fire costs more).
- **Depletion Effects**: Low energy prevents energy-consuming actions, impacting AP usage.
- **Enhancements**: Items and upgrades significantly boost energy pools.

## Examples

Energy Consumption Table:

| Action | Energy Cost | Unit Type |
|--------|-------------|-----------|
| Walk | 0 | Human |
| Run | 1 | Human |
| Fire (single shot) | 1 | Human |
| Fire (burst) | 3 | Human |
| Maneuver | 2 | Craft |
| Engage | 5 | Craft |

Scenario: A soldier starts with 10 energy. After running (1), firing burst (3), total 4 spent, leaving 6. Next turn regenerates ~3, back to 9.

## References
- **XCOM Series**: Time units for actions, with fatigue mechanics.
- **MechWarrior**: Heat and energy management for mechs.
- **Battletech**: Resource pools for movement and combat.