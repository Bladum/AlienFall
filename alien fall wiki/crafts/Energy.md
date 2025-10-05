# Craft Energy System

> **📖 Master Reference:** For a comprehensive overview of energy mechanics across all game systems, see [Energy Systems](../core/Energy_Systems.md). This document focuses specifically on craft-level energy mechanics in air combat (operational layer).

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Energy Pool System](#energy-pool-system)
  - [Action Cost Mechanics](#action-cost-mechanics)
  - [Consumption Categories](#consumption-categories)
  - [Replenishment and Regeneration](#replenishment-and-regeneration)
  - [Energy Starvation Effects](#energy-starvation-effects)
- [Examples](#examples)
  - [Basic Energy Management](#basic-energy-management)
  - [Strategic Combat Scenarios](#strategic-combat-scenarios)
    - [Aggressive Assault Pattern](#aggressive-assault-pattern)
    - [Conservative Defense Pattern](#conservative-defense-pattern)
    - [Energy Starvation Crisis](#energy-starvation-crisis)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft energy system manages per-craft resource pools that gate powered actions, weapon firing, and tactical maneuvers during interception engagements. Operating independently from Action Points (AP), fuel systems, and movement systems, energy creates strategic separation between immediate tactical capabilities and sustained operational endurance. Energy costs for interception are included in item purchase costs, eliminating rearming requirements and creating direct trade-offs between equipment power and financial investment.

Energy mechanics are fully data-driven and deterministic, with seeded random elements ensuring reproducible outcomes. The system supports extensive modding while maintaining clear strategic depth through resource scarcity and regeneration mechanics.

## Mechanics

### Energy Pool System

Each craft maintains an independent energy pool with defined capacity and recovery characteristics:

- **Maximum Energy**: Total EP = Craft Base EP + Weapon Slot 1 EP + Weapon Slot 2 EP + Addon EP
- **Current Energy**: Available energy reserves, clamped at zero minimum (never negative)
- **Regeneration Rate**: Total regen per turn = Craft Base Regen + equipment regen bonuses
- **Typical Craft Values**: Similar to units - 6-12 base EP with 2-4 base regen per turn
- **Weapon Contributions**: Light weapons +5-10 EP, heavy weapons +15-25 EP with +1/+2 regen
- **NO AMMUNITION SYSTEM**: All energy costs included in item purchase prices - no rearming or reload mechanics
- **Always Ready**: Crafts fully restore energy when returning to base between missions

### Action Cost Mechanics

Energy consumption gates all powered craft actions with explicit resource requirements:

- Pre-Action Validation: System verifies sufficient energy before allowing action initiation
- Cost Declaration: Each action specifies explicit energy requirements in data
- Consumption Timing: Energy deducted at action resolution, not initiation
- Failure Handling: Insufficient energy blocks actions with clear feedback

### Consumption Categories

Energy costs are categorized by action type with distinct strategic implications:

- Movement Costs: Energy expenditure for position changes and evasive maneuvers
- Weapon Firing: Per-shot costs for all weapon systems, separate from cooldowns
- Special Actions: Increased costs for advanced tactical maneuvers and abilities
- System Operations: Energy drain for active equipment and sustained capabilities

### Replenishment and Regeneration

Energy recovery occurs through structured mechanisms with strategic timing:

- Turn-Based Regeneration: Automatic recovery at end of craft's turn based on regeneration rate
- Base Resupply: Full energy restoration when returning to base between missions
- Equipment Bonuses: Items providing additional regeneration or capacity modifiers
- Field Recovery: Limited regeneration through crew actions or emergency systems
- No Rearming Required: Energy costs included in item prices, crafts always ready for combat

### Energy Starvation Effects

Depleted energy creates severe tactical limitations and risk:

- Weapon Lockout: Craft cannot fire weapons when energy is exhausted
- Movement Restrictions: Reduced mobility and maneuverability options
- Strategic Withdrawal: Forced retreat or repositioning when energy depleted
- Recovery Requirements: Return to base or extended regeneration periods needed

## Examples

### Basic Energy Management
A Skyranger-class craft with 100 maximum energy and 20 regeneration per turn:
- Fires primary weapon (15 energy cost) → 85 energy remaining
- Executes evasive maneuver (10 energy cost) → 75 energy remaining
- Turn ends with regeneration → 95 energy available for next turn

### Strategic Combat Scenarios

#### Aggressive Assault Pattern
Craft burns energy rapidly for continuous weapon fire and aggressive positioning, maximizing damage output but risking energy starvation mid-engagement. Requires careful monitoring to avoid being caught with depleted reserves during critical moments.

#### Conservative Defense Pattern
Craft conserves energy for sustained operations, using minimal weapon fire and defensive positioning. Preserves energy for counter-attacks and extended engagements, trading immediate damage for operational endurance.

#### Energy Starvation Crisis
Craft with depleted energy cannot engage targets effectively, forcing retreat maneuvers or repositioning to safer locations. Creates high-stakes decisions about when to commit remaining energy reserves versus withdrawing to regenerate.

## Related Wiki Pages

- [Stats.md](../crafts/Stats.md) - Energy pool capacities and regeneration rates
- [Items.md](../crafts/Items.md) - Energy weapons and power systems
- **[Energy Systems (Core)](../core/Energy_Systems.md)** - Complete energy system overview across all game layers
- [Unit Energy](../units/Energy.md) - Tactical-layer energy mechanics for ground units
- [Interception.md](../interception/Overview.md) - Combat energy consumption mechanics
- [Air Battle.md](../interception/Air%20Battle.md) - Tactical energy management in dogfights
- [Battlescape.md](../battlescape/Battlescape.md) - Ground combat energy systems
- [Technical Architecture.md](../architecture.md) - Energy system data structures
- [Craft Operations.md](../geoscape/Craft%20Operations.md) - Energy regeneration between missions
- [Finance.md](../finance/Finance.md) - Energy weapon costs and maintenance
- [Research.md](../basescape/Research.md) - Energy technology development
- [Manufacturing.md](../economy/Manufacturing.md) - Energy system production

## References to Existing Games and Mechanics

- **XCOM Series**: Overwatch energy costs and action point management
- **MechWarrior**: Heat buildup and cooling system mechanics
- **Battletech**: Energy weapon heat generation and dissipation
- **Starfleet Command**: Shield energy management and weapon power requirements
- **Homeworld**: Ship energy systems and power allocation
- **Freespace**: Weapon energy costs and capacitor management
- **Wing Commander**: Afterburner energy consumption and tactical pacing
- **Star Control**: Energy management and resource allocation systems
- **Master of Orion**: Ship power systems and energy weapon mechanics
- **Civilization**: Unit movement energy and action point systems

