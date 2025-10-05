# Armor Piercing

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Armor System](#armor-system)
  - [Armor Piercing](#armor-piercing)
  - [Damage Mitigation](#damage-mitigation)
  - [Damage Pipeline](#damage-pipeline)
- [Examples](#examples)
  - [Weapon Examples](#weapon-examples)
  - [Combat Scenarios](#combat-scenarios)
  - [Armor Types](#armor-types)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Armor Piercing system implements a straightforward damage mitigation framework where armor provides flat damage reduction that can be overcome by armor-piercing capabilities in Alien Fall. Armor functions as a static defensive value that reduces incoming damage through simple subtraction, while weapons can declare armor-piercing values to reduce or bypass this protection. The system creates tactical choices between weapons with high damage output versus those with superior armor penetration, while maintaining deterministic, easy-to-understand mechanics.

## Mechanics

### Armor System

Static defensive values on units and structures:

- Flat Reduction: Armor subtracts fixed amount from incoming damage
- No Percentage: Integer values only, no percentage-based mitigation
- Unit Variety: Different unit types have appropriate armor values
- Static Defense: Armor values don't change during missions
- Balance Tool: Armor creates differentiation between unit types

### Armor Piercing

Weapon capability to reduce armor effectiveness:

- AP Values: Weapons declare armor-piercing ratings
- Armor Reduction: AP subtracts from target's armor value
- Minimum Zero: Effective armor cannot go below zero
- Weapon Choice: High AP vs high damage trade-offs
- Specialization: Different weapons for different armor types

### Damage Mitigation

How armor affects incoming damage:

- Subtraction Only: Flat reduction from damage total
- Post-Type: Applied after damage type multipliers
- Pre-Distribution: Occurs before damage allocation to health pools
- Minimum Damage: Some damage always gets through
- Predictable Results: Clear damage calculations for players

### Damage Pipeline

Integration with overall damage resolution:

- Base Damage: Weapon's raw damage output
- Type Multipliers: Damage type modifiers applied
- Armor Mitigation: Effective armor subtraction
- Distribution: Remaining damage allocated to health/stun/etc.
- Provenance: Complete calculation tracking for debugging

## Examples

### Weapon Examples

Assault Rifle
- Base Damage: 8
- Damage Type: Ballistic
- Armor Piercing: 2
- Range: 25
- Description: Standard infantry weapon with moderate penetration

Heavy AP Round
- Base Damage: 10
- Damage Type: Ballistic
- Armor Piercing: 12
- Range: 20
- Description: Specialized anti-armor ammunition with high penetration

Acid Thrower
- Base Damage: 6
- Damage Type: Corrosive
- Armor Piercing: 8
- Range: 8
- Description: Corrosive weapon that degrades armor effectiveness

### Combat Scenarios

Rifle vs Light Armor
- Weapon: Rifle (Damage = 8, AP = 2)
- Target: Light Armor = 5
- Calculation: effective_armor = max(0, 5 - 2) = 3
- Final Damage: max(0, 8 - 3) = 5

High-AP Weapon Bypass
- Weapon: Heavy AP round (Damage = 10, AP = 12)
- Target: Heavy Armor = 8
- Calculation: effective_armor = max(0, 8 - 12) = 0
- Final Damage: max(0, 10 - 0) = 10

Corrosive Effects
- Weapon: Acid thrower (Damage = 6, AP = 8, corrosive type)
- Target: Armored unit (Armor = 10)
- Calculation: effective_armor = max(0, 10 - 8) = 2
- Final Damage: max(0, 6 - 2) = 4 + corrosive debuff effects

### Armor Types (XCOM/5 Scaling)

**CRITICAL NOTE**: All armor values use XCOM/5 scaling for consistency with unit stats and weapon damage.

Coveralls / Civilian Clothing
- Armor Value: 1
- Weight: 1 mass
- Effectiveness: Minimal protection, better than nothing
- Typical Units: Civilians, unarmored troops

Shield (addon item)
- Armor Value: +4 bonus
- Weight: 2 mass
- Effectiveness: Significant defense boost when wielded
- Note: May be secondary item or armor addon

Armored Suit / Light Combat Armor
- Armor Value: 4
- Weight: 4 mass
- Effectiveness: Good vs small arms, some heavy weapon protection
- Typical Units: Basic soldiers, scouts, light infantry

Personal Armor / Medium Combat Armor
- Armor Value: 8
- Weight: 8 mass
- Effectiveness: Strong protection vs most weapons, still vulnerable to heavy AP
- Typical Units: Veteran infantry, alien soldiers

Power Armor / Heavy Combat Armor
- Armor Value: 18
- Weight: 12 mass (power-assisted)
- Effectiveness: Excellent protection, resists most small arms completely
- Typical Units: Elite troops, special forces, alien commanders

Tank Armor / Vehicle Plating
- Armor Value: 24
- Weight: N/A (vehicle only)
- Effectiveness: Resistant to all but specialized anti-armor weapons
- Typical Units: Tanks, armored vehicles, heavy mechs

## Related Wiki Pages

- [Damage calculations.md](../items/Damage%20calculations.md) - How armor piercing affects damage pipeline
- [Damage types.md](../items/Damage%20types.md) - Armor piercing as damage type
- [Unit items.md](../items/Unit%20items.md) - Armor piercing weapons and equipment
- [Weapon modes.md](../items/Weapon%20modes.md) - Armor piercing weapon modes
- [Units.md](../units/Units.md) - Unit armor values and protection
- [Battlescape.md](../battlescape/Battlescape.md) - Combat armor mechanics
- [AI.md](../ai/AI.md) - AI armor piercing weapon selection
- [Research tree.md](../economy/Research%20tree.md) - Armor piercing technology research

## References to Existing Games and Mechanics

- **XCOM Series**: Armor piercing weapons and alien armor
- **Warhammer 40k**: Armor penetration and damage tables
- **BattleTech**: Armor and internal structure damage systems
- **MechWarrior Series**: Armor penetration and critical hits
- **Warhammer Fantasy**: Armor saves and weapon penetration
- **Dungeons & Dragons**: Armor class and piercing damage types
- **GURPS**: Armor and penetration mechanics
- **Dark Souls Series**: Armor and weapon damage types
- **Monster Hunter Series**: Armor and weapon sharpness systems
- **Final Fantasy Series**: Armor and piercing weapon mechanics

