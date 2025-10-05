# Damage Types

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Damage Type Classification](#damage-type-classification)
  - [Type Multiplier Application](#type-multiplier-application)
  - [Fallback Handling](#fallback-handling)
  - [Advanced Type Effects](#advanced-type-effects)
  - [Unit Resistance Mapping](#unit-resistance-mapping)
- [Examples](#examples)
  - [Basic Type Multipliers](#basic-type-multipliers)
  - [Vulnerability Exploitation](#vulnerability-exploitation)
  - [Tactical Counterplay](#tactical-counterplay)
  - [Advanced Effects](#advanced-effects)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Damage Types system implements a deterministic multiplier stage in the damage pipeline that modifies weapon damage based on type interactions with target resistances in Alien Fall. Each weapon specifies a primary damage type, and each target unit maintains a resistance mapping that scales incoming damage. The system supports advanced type-specific effects while maintaining complete data-driven configuration and provenance tracking for balancing and debugging.

## Mechanics

### Damage Type Classification

Comprehensive damage type system covering various damage delivery methods:

- Kinetic: Physical impact damage, interacts strongly with armor
- Explosive: Combined point and area blast effects with radial falloff
- Laser: Energy damage with potential armor bypass characteristics
- Plasma: Damage plus heat/burn secondary effects
- Psionic: Mental disruption, often bypasses physical armor
- Bio: Delayed damage and debuff effects
- Acid: Corrosive damage with armor reduction capabilities
- EMP: Electronic systems disruption
- Stun: Pure incapacitation effects
- Smoke: Vision and breathing impairment
- Fire: Burn damage with spread potential
- Warp: Reality-warping damage effects

### Type Multiplier Application

Core damage scaling mechanism:

- Weapon Type Declaration: Each weapon specifies one primary damage type
- Target Resistance Lookup: Unit maintains mapping of type to multiplier percentage
- Scaling Formula: scaled_damage = raw_damage × (multiplier / 100)
- No Additional RNG: Pure arithmetic scaling, randomness handled elsewhere
- Pipeline Position: Applied after damage generation, before armor mitigation

### Fallback Handling

Ensuring robust operation when type data is incomplete:

- Default Multiplier: Configurable fallback (typically 100% - neutral)
- Missing Type Handling: Automatic fallback when target lacks type entry
- Provenance Recording: Clear indication when fallbacks are used
- Configuration Control: Fallback values set in data files
- Error Prevention: No failures from incomplete resistance mappings

### Advanced Type Effects

Type-specific secondary effects and interactions:

- Acid Effects: Armor reduction plus damage over time
- EMP Effects: System disruption for mechanical targets
- Plasma Effects: Heat damage and burn effects
- Fire Effects: Spread mechanics and morale penalties
- Warp Effects: Reality distortion and armor ignoring
- Effect Configuration: All effects parameters data-driven

### Unit Resistance Mapping

Target vulnerability definitions:

- Per-Unit Type: Different resistances by unit classification
- Percentage Values: 100 = neutral, >100 = vulnerability, <100 = resistance, 0 = immune
- Type Coverage: Comprehensive mapping for all supported damage types
- Faction Variations: Different resistance profiles by faction/civilization
- Dynamic Modification: Runtime resistance changes through effects

## Examples

### Basic Type Multipliers

Kinetic Rifle vs Human Soldier
- Weapon: Kinetic type
- Target: Human (100% kinetic resistance)
- Calculation: 10 damage × 1.0 = 10 damage

Kinetic Rifle vs Armored Mech
- Weapon: Kinetic type
- Target: Mechanical (50% kinetic resistance)
- Calculation: 10 damage × 0.5 = 5 damage

### Vulnerability Exploitation

EMP vs Robotic Turret
- Weapon: EMP type
- Target: Mechanical (200% EMP vulnerability)
- Calculation: 8 damage × 2.0 = 16 damage
- Tactical Use: Disable electronics before follow-up attacks

Explosive Grenade in Enclosed Room
- Weapon: Explosive type
- Target: Interior units (125% explosive vulnerability)
- Structure: Thick walls reduce propagation
- Calculation: 12 damage × 1.25 = 15 damage to interior targets

### Tactical Counterplay

Acid vs Heavy Armor
- Weapon: Acid type (corrosive)
- Target: Armored unit (80% acid resistance)
- Effects: Armor reduction + damage over time
- Calculation: 6 damage × 0.8 = 4.8 damage + armor debuff

Psionic vs Biological Target
- Weapon: Psionic type
- Target: Human (150% psionic vulnerability)
- Effects: Mental disruption, armor bypass
- Calculation: 4 damage × 1.5 = 6 damage to morale/stun

### Advanced Effects

Plasma Weapon Chain Reaction
- Primary: Plasma damage with heat effect
- Secondary: Burn damage over time
- Target: Multiple units in area
- Effects: Heat spread and morale penalties

Warp Weapon Reality Distortion
- Primary: High damage with armor ignoring
- Secondary: System disruption effects
- Target: Any unit type
- Effects: Bypasses conventional defenses

## Related Wiki Pages

- [Damage model.md](../items/Damage%20model.md) - How damage types are applied to stats
- [Damage calculations.md](../items/Damage%20calculations.md) - Type-based damage computation
- [Unit items.md](../items/Unit%20items.md) - Equipment with damage type effects
- [Weapon modes.md](../items/Weapon%20modes.md) - Weapon damage type modes
- [Wounds.md](../units/Wounds.md) - Wound types and effects
- [Battlescape.md](../battlescape/Battlescape.md) - Combat damage type interactions
- [Units.md](../units/Units.md) - Unit resistance mappings
- [AI.md](../ai/AI.md) - AI damage type selection logic

## References to Existing Games and Mechanics

- **Final Fantasy Series**: Elemental damage types and weaknesses
- **Pokémon Series**: Type effectiveness and resistance systems
- **Monster Hunter Series**: Elemental damage and monster weaknesses
- **Dark Souls Series**: Status effects and damage type interactions
- **XCOM Series**: Alien weapon types and armor interactions
- **Warhammer 40k**: Damage types and armor save mechanics
- **Dungeons & Dragons**: Damage types and creature resistances
- **GURPS**: Comprehensive damage type classifications
- **BattleTech**: Weapon types and armor penetration
- **MechWarrior Series**: Damage types and component effects

