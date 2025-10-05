# Damage Model

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Damage Distribution](#damage-distribution)
  - [Stat Processing Pipeline](#stat-processing-pipeline)
  - [Per-Target Multipliers](#per-target-multipliers)
  - [Stat Caps and Constraints](#stat-caps-and-constraints)
  - [Overflow Handling](#overflow-handling)
  - [Resolution Order](#resolution-order)
- [Examples](#examples)
  - [Simple Two-Stat Distribution](#simple-two-stat-distribution)
  - [Multi-Stat Complex Distribution](#multi-stat-complex-distribution)
  - [Overflow with Spill](#overflow-with-spill)
  - [Unit-Type Multipliers](#unit-type-multipliers)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Damage Model system converts residual damage values into concrete unit stat changes by distributing numeric damage across multiple stat channels (Health, Stun, Morale, Energy, Action Points, etc.) in Alien Fall. It serves as the final mapping stage in the damage pipeline, taking the numeric remainder after upstream processing and applying percentage-based splits, per-target multipliers, rounding rules, and stat constraints to produce auditable stat deltas. The system ensures deterministic, transparent conversion of raw damage into game state modifications.

## Mechanics

### Damage Distribution

Converting residual damage into stat-specific allocations:

- Distribution Vector: Percentage allocation across target stats with automatic normalization if percentages don't sum to 100%
- Per-Stat Calculation: Raw contribution = residual_damage × (percentage / 100)
- Complete Consumption: All residual damage distributed to stat channels
- Provenance Recording: Original percentages and normalization factors tracked

### Stat Processing Pipeline

Sequential processing for each stat channel:

- Raw Contribution: Base damage allocation to stat
- Multiplier Application: Unit-specific damage modifiers applied
- Rounding: Configurable decimal handling (round, floor, ceil)
- Cap Application: Stat minimum/maximum constraints enforced
- Overflow Handling: Excess damage routing according to configured policies
- State Application: Final stat modification applied

### Per-Target Multipliers

Unit-specific damage modification system:

- Unit Type Multipliers: Base modifications by unit classification
- Trait-Based Adjustments: Additional modifiers from unit traits
- Status Effect Modifiers: Temporary changes from active effects
- Multiplier Stacking: Sequential application with complete provenance tracking
- Source Attribution: Clear recording of all multiplier origins

### Stat Caps and Constraints

Stat value boundaries and validation:

- Minimum Values: Floor limits (typically 0 for most stats)
- Maximum Values: Ceiling limits varying by stat type
- Operation Types: Add, subtract, or modify operations supported
- Cap Enforcement: Automatic clamping to valid ranges
- Overflow Detection: Identification of damage exceeding constraints

### Overflow Handling

Managing damage exceeding stat limits:

- Clamp Policy: Discard excess, cap at maximum (default behavior)
- Spill-to Policy: Route excess to secondary stat with continued processing
- Spill Chain: Multi-level overflow routing for complex distributions
- Spill Processing: Excess treated as new damage input to target stat
- Policy Configuration: Data-driven overflow behaviors with explicit routing

### Resolution Order

Stat processing sequence for consistent interactions:

- Canonical Order: Health → Stun → Energy → Morale → Action Points → Sight/Sense/Cover
- Dependency Management: Critical stats processed before secondary effects
- Interaction Prevention: Predictable order prevents ambiguous interactions
- Configurable Override: Custom ordering available for specific damage types
- Order Documentation: Clear specification of processing sequence

## Examples

### Simple Two-Stat Distribution
Distribution: {health: 80, morale: 20}
Residual Damage: 10
Calculations:
- Health: 10 × 0.80 = 8 → unit.Health -= 8
- Morale: 10 × 0.20 = 2 → unit.Morale -= 2

### Multi-Stat Complex Distribution
Distribution: {health: 50, stun: 20, energy: 15, ap: 10, cover: 5}
Residual Damage: 8
Unit Multipliers: Mechanical units {stun: 0.5}
Stat Caps: AP [0, 4]
Calculations:
- Health: 8 × 0.50 = 4 → unit.Health -= 4
- Stun: 8 × 0.20 = 1.6 × 0.5 = 0.8 → round to 1 → unit.Stun += 1
- Energy: 8 × 0.15 = 1.2 → round to 1 → unit.Energy -= 1
- AP: 8 × 0.10 = 0.8 → round to 1 → cap to 4 → unit.AP -= 1
- Cover: 8 × 0.05 = 0.4 → apply fractional reduction

### Overflow with Spill
Distribution: {ap: 90, health: 10}
Residual Damage: 10
Stat Caps: AP max = 4
Overflow Policy: spill_to:health
Calculations:
- AP: 10 × 0.90 = 9 → cap at 4, spill 5 to health
- Health: 10 × 0.10 = 1 + spilled 5 = 6 → unit.Health -= 6

### Unit-Type Multipliers
Distribution: {health: 70, stun: 30}
Residual Damage: 10
Target: Armored unit with {health: 0.8} multiplier
Calculations:
- Health: 10 × 0.70 = 7 × 0.8 = 5.6 → round to 6 → unit.Health -= 6
- Stun: 10 × 0.30 = 3 → unit.Stun += 3

## Related Wiki Pages

- [Damage types.md](../items/Damage%20types.md) - Different types of damage and their effects.
- [Damage calculations.md](../items/Damage%20calculations.md) - How damage values are computed.
- [Unit items.md](../items/Unit%20items.md) - Equipment that modifies damage.
- [Weapon modes.md](../items/Weapon%20modes.md) - Weapon damage delivery modes.
- [Wounds.md](../units/Wounds.md) - Wound system integration.
- [Battlescape.md](../battlescape/Battlescape.md) - Combat damage context.
- [Units.md](../units/Units.md) - Unit stats affected by damage.
- [AI.md](../ai/AI.md) - AI damage evaluation and response.

## References to Existing Games and Mechanics

- **XCOM Series**: Damage and armor penetration systems
- **Fire Emblem Series**: Weapon triangle and damage calculations
- **Final Fantasy Series**: Elemental damage types and resistances
- **Dark Souls Series**: Poise and damage interruption systems
- **Monster Hunter Series**: Elemental damage types and weaknesses
- **Warhammer 40k**: Armor saves and wound allocation
- **GURPS**: Hit locations and damage distribution
- **Dungeons & Dragons**: Damage types and resistance mechanics
- **BattleTech**: Armor and internal structure damage
- **MechWarrior Series**: Component-based damage systems

