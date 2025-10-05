# Unit Items

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Equipment Slots](#equipment-slots)
  - [Item Categories](#item-categories)
  - [Tactical Roles](#tactical-roles)
  - [Loadout Management](#loadout-management)
  - [Energy-Based Resources](#energy-based-resources)
  - [Weight and Encumbrance](#weight-and-encumbrance)
  - [Role-Based Optimization](#role-based-optimization)
- [Examples](#examples)
  - [Rifleman Loadout](#rifleman-loadout)
  - [Medic Loadout](#medic-loadout)
  - [Sniper Loadout](#sniper-loadout)
  - [Energy Management](#energy-management)
  - [Weight Penalties](#weight-penalties)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Unit items represent the weapons, armor, and equipment that define a soldier's tactical capabilities and role specialization in Alien Fall. The system emphasizes meaningful loadout choices over complex inventory micromanagement, with each piece of equipment contributing to a unit's tactical identity. Items consume from a unified Energy pool rather than tracking individual ammunition, simplifying logistics while maintaining tactical depth through resource management.

The design focuses on role clarity and strategic tradeoffs, ensuring that equipment choices reinforce tactical archetypes while allowing personalization within defined constraints. This streamlined approach departs from granular item management of classic tactical games, prioritizing combat decisions over packing complexity.

## Mechanics

### Equipment Slots

Units have exactly three equipment slots with strict item type restrictions:

- **Weapon Slot 1**: Primary weapon (unit item type) providing main offensive capability
- **Weapon Slot 2**: Secondary weapon (unit item type) for backup or specialized function
- **Armor Slot**: Armor (unit item type) providing defensive protection

**CRITICAL**: Units have ONLY these 3 slots. NO ammunition clips, NO backpacks, NO grenades as separate items. All functionality must be integrated into weapons and armor. Grenades are weapon types, not separate inventory items.

### Item Categories

Equipment is organized by function and tactical purpose to ensure clear player expectations:

- Weapons: Offensive tools with range, damage, accuracy, and energy cost characteristics
- Equipment: Support and utility items providing special capabilities (medikits, scanners, grenades)
- Armor: Protective gear with weight costs, defensive benefits, and possible passive effects

### Tactical Roles

Predefined roles guide equipment selection and provide optimization recommendations:

- Rifleman: Versatile mid-range combat with balanced capabilities
- Medic: Healing and support focus with medical equipment
- Scout: Stealth and reconnaissance with light, mobile gear
- Heavy: High durability with powerful but slow equipment
- Sniper: Long-range precision with specialized weapons
- Support: Team utility with suppression and area control tools

### Loadout Management

Complete equipment kits are assembled with validation and compatibility checking:

- Slot Validation: Equipment must fit appropriate slots and meet role requirements
- Compatibility Checking: Items must not conflict with each other or unit restrictions
- Role Fit Scoring: Quantitative assessment of how well loadout matches intended role
- Mission Restrictions: Equipment may be limited based on mission parameters

### Energy-Based Resources

Unified energy pool replaces individual ammunition tracking for simplified resource management:

- **Base Unit Energy**: Typical unit has 6-12 EP base and base regen of 1/3 base energy (2-4 EP per turn)
- **Weapon Energy Contribution**: Basic weapons add 5-10 EP to pool with no regen bonus; heavy weapons add 15-25 EP with optional +1/+2 EP regen
- **Energy Pool Calculation**: Total EP = Unit Base EP + Weapon 1 EP + Weapon 2 EP + Armor EP bonuses
- **Regeneration**: Total regen per turn = Unit Base Regen + equipment regen bonuses
- **Energy Consumption**: All weapon usage draws from shared pool (pistol 1 EP, rifle 2-3 EP per shot)
- **Action Sequences**: Energy costs calculated for planned action combinations with previews
- **Post-Mission Restoration**: Energy fully replenished between engagements with automatic restoration

**NO AMMO CLIPS OR AMMO RACKS**: All energy management is built into the unit's base stats and equipped weapons/armor. Medikits may be used to transfer energy between units.

### Weight and Encumbrance

Equipment weight uses XCOM/5 scaling with strength determining carry capacity:

- **Capacity Calculation**: Carry capacity = unit Strength stat (6-12 for humans)
- **Item Weights** (XCOM/5 scale):
  - Pistol / Grenade launcher: 1 mass
  - Rifle / SMG: 2-3 mass
  - Light armor / Coveralls: 1-2 mass
  - Medium armor: 4 mass
  - Heavy armor: 8 mass
  - Heavy weapons (cannon, minigun): 10-15 mass (includes integrated "ammo" weight)
- **Binary Validation**: Total weight must not exceed capacity, or items cannot be equipped
- **No Penalties**: No movement, AP, or accuracy reductions - simply cannot equip overweight loadouts
- **Capacity Modifiers**: Traits, transformations, or special armor may change carrying capacity

### Role-Based Optimization

Intelligent recommendations help players assemble effective, role-appropriate equipment:

- Preferred Equipment: Role-specific item recommendations with scoring
- Fit Assessment: Quantitative evaluation of loadout effectiveness
- Alternative Suggestions: Backup options when preferred items unavailable
- Reasoning Display: Clear explanations for optimization recommendations

## Examples

### Rifleman Loadout

Standard Rifleman Kit
- Primary: Assault Rifle (weight 4, energy cost 3, range 20, damage 35)
- Secondary: Pistol (weight 1, energy cost 2, range 12, damage 25)
- Armor: Medium Body Armor (weight 3, armor rating 40)
- Total Weight: 8, Role Fit: 95%
- Tactical Focus: Versatile mid-range combat with good mobility

Heavy Rifleman Variant
- Primary: Light Machine Gun (weight 6, energy cost 4, range 18, damage 40)
- Secondary: Grenades (weight 2, energy cost 3, radius 3, damage 30)
- Armor: Heavy Body Armor (weight 5, armor rating 60)
- Total Weight: 13, Role Fit: 85%
- Tactical Focus: Sustained firepower with reduced mobility

### Medic Loadout

Field Medic Kit
- Primary: Submachine Gun (weight 3, energy cost 2, range 15, damage 28)
- Secondary: Medikit (weight 2, energy cost 5, healing 25 HP per wound)
- Armor: Light Body Armor (weight 2, armor rating 25)
- Total Weight: 7, Role Fit: 92%
- Tactical Focus: Combat capability with strong healing support

### Sniper Loadout

Precision Sniper Kit
- Primary: Sniper Rifle (weight 5, energy cost 5, range 35, damage 80)
- Secondary: Pistol (weight 1, energy cost 2, range 12, damage 25)
- Armor: Light Body Armor (weight 2, armor rating 25)
- Total Weight: 8, Role Fit: 96%
- Tactical Focus: Long-range precision with minimal encumbrance

### Energy Management

Conservative Energy Use
- Starting Energy: 20
- Single Shot: -3 energy (remaining 17)
- Move: -1 energy (remaining 16)
- Strategy: Sustainable pacing with energy reserves

Aggressive Energy Expenditure
- Starting Energy: 20
- Burst Fire: -6 energy (remaining 14)
- Grenade Throw: -3 energy (remaining 11)
- Sprint: -2 energy (remaining 9)
- Risk: High damage output but limited sustainability

### Weight Penalties

Optimal Weight Loadout
- Total Weight: 8, Limit: 10
- No Penalties: Full movement and accuracy
- Tactical Flexibility: Unrestricted positioning and actions

Heavy Loadout Penalties
- Total Weight: 13, Limit: 10
- Overage: 30% overweight
- Movement Penalty: -1 tile per move
- Accuracy Penalty: -15% to hit
- Tactical Impact: Reduced mobility and effectiveness

## Related Wiki Pages

- [Special items.md](../items/Special%20items.md) - Special unit equipment and abilities
- [Weapon modes.md](../items/Weapon%20modes.md) - Weapon functionality and modes
- [Damage types.md](../items/Damage%20types.md) - Weapon damage types and effects
- [Item Action Economy.md](../items/Item%20Action%20Economy.md) - Equipment usage costs
- [Units.md](../units/Units.md) - Unit equipment slots and roles
- [Battlescape.md](../battlescape/Battlescape.md) - Combat equipment usage
- [AI.md](../ai/AI.md) - AI loadout selection and tactics
- [Economy.md](../economy/Economy.md) - Equipment acquisition and costs

## References to Existing Games and Mechanics

- **XCOM Series**: Unit equipment and tactical loadouts
- **Fire Emblem Series**: Character equipment and class specialization
- **Final Fantasy Tactics**: Job-based equipment systems
- **Disgaea Series**: Equipment customization and enhancement
- **Into the Breach**: Mech equipment and pilot specialization
- **Gears Tactics**: Character loadouts and equipment choices
- **BattleTech**: Mech equipment and component systems
- **MechWarrior Series**: Mech loadouts and equipment management
- **Warhammer 40k**: Unit equipment and wargear systems
- **Dungeons & Dragons**: Character equipment and inventory management

