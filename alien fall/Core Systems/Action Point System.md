# Action Point System

## Overview
The Action Point (AP) system is a unified turn-based action budget that governs all decisions for units in tactical battlescape combat and crafts in operational interception missions. It provides a standardized way to balance unit capabilities, ensuring that players must strategically allocate limited actions each turn. This system integrates closely with the Movement Point system and Energy Pool system to create cohesive gameplay mechanics.

## Mechanics
- **AP Budget**: Each unit or craft starts with 4 AP per turn, representing their base action capacity.
- **Action Costs**: Common actions include moving (costs vary), firing weapons, using items, overwatching, resting, or crouching, each consuming AP.
- **Movement Integration**: Movement consumes both AP and MP simultaneously, linked through unit speed (MP = speed × AP).
- **Reset Mechanism**: AP fully resets at the start of each turn.
- **Modifiers**: AP can be reduced below 4 due to negative states like low morale, wounds, or sanity issues; conversely, special effects like berserk can increase AP above 4.
- **Energy Pool Link**: Actions requiring energy draw from the Energy Pool system, potentially limiting AP usage if energy is depleted.

## Examples

| Action Type | AP Cost | Notes |
|-------------|---------|-------|
| Move (normal terrain) | 1-2 | Consumes MP as well |
| Fire weapon (standard) | 1 | May vary by weapon mode |
| Use item | 1-2 | Depends on item complexity |
| Overwatch | 1 | Enables reaction fire |
| Rest | 1 | Regenerates energy |
| Crouch | 1 | Improves cover |

In a battlescape scenario, a soldier with 4 AP might move 2 tiles (2 AP), fire their weapon (1 AP), and crouch (1 AP), leaving no AP for further actions that turn.

## References
- **XCOM Series**: Action points limit unit actions per turn, requiring tactical decision-making.
- **Civilization VI**: Unit actions are limited by movement points and action economy.
- **Fire Emblem**: Turn-based action limits with movement and attack phases.