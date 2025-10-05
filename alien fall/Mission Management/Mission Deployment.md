# Mission Deployment

## Overview
Mission deployment handles the automatic generation of enemy teams based on unit classes with randomized equipment loadouts. Each enemy unit class has predefined inventory templates that determine what items they carry into battle. This system ensures varied and balanced encounters while respecting technological constraints established during mission generation.

## Mechanics
- Enemy teams built from available unit classes
- Each class has default inventory with weighted random selection
- Multiple items possible per unit, not single equipment slots
- Technology limitations applied before deployment phase
- Loadouts handle complete unit equipment setup
- Randomization provides replayability and unpredictability

## Examples
| Unit Class | Primary Weapon | Secondary Items | Rarity Weight |
|------------|----------------|-----------------|---------------|
| Assault Alien | Plasma Rifle | Grenade, Medkit | Common (40%) |
| Sniper Alien | Beam Sniper | Camo Module, Energy Pack | Uncommon (25%) |
| Heavy Alien | Heavy Cannon | Shield Generator, Ammo Drum | Rare (15%) |
| Scout Alien | Light Pistol | Motion Scanner, Stealth Suit | Rare (10%) |

## References
- XCOM: Enemy Within - Alien deployment patterns
- Civilization VI - Unit composition randomization
- See also: Units, Items, Mission Planning