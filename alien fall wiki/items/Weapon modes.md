# Weapon Modes

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Mode Categories](#mode-categories)
  - [Percentage Multipliers](#percentage-multipliers)
  - [Energy Consumption Models](#energy-consumption-models)
  - [Mode Gating and Requirements](#mode-gating-and-requirements)
  - [Attack Resolution](#attack-resolution)
  - [Deterministic Behavior](#deterministic-behavior)
- [Examples](#examples)
  - [Single Shot Modes](#single-shot-modes)
  - [Burst Fire Modes](#burst-fire-modes)
  - [Precision Modes](#precision-modes)
  - [Suppression Modes](#suppression-modes)
  - [Mode Comparison](#mode-comparison)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Weapon modes provide tactical flexibility by modifying weapon performance through percentage-based multipliers in Alien Fall. Each weapon can access multiple firing modes that trade off between accuracy, rate of fire, resource consumption, and effectiveness. Modes are globally defined data records that weapons reference, allowing players to choose firing behavior per attack. The system creates meaningful tactical decisions while maintaining deterministic outcomes through seeded randomization.

## Mechanics

### Mode Categories

Weapon modes are organized by tactical purpose and firing behavior patterns:

- Single Shot: Individual, carefully aimed shots with high precision
- Burst Fire: Multiple rapid shots with reduced individual accuracy
- Precision: High-investment modes prioritizing accuracy and damage
- Suppression: Area control modes emphasizing volume of fire over precision

### Percentage Multipliers

All weapon parameters are modified through consistent percentage multipliers applied to base weapon values:

- AP Cost: Action point investment required for the mode
- Energy Cost: Resource consumption per shot or per attack
- Range: Effective engagement distance modification
- Accuracy: Hit probability percentage adjustment
- Damage: Base damage output scaling
- Shots: Number of projectiles fired per attack

### Energy Consumption Models

Two distinct energy consumption patterns provide different tactical tradeoffs:

- Total Consumption: Fixed energy cost regardless of shots fired
- Per-Shot Consumption: Energy cost scales with number of projectiles
- Resource Planning: Preview total costs before committing to attacks
- Sustainability: Different modes support different engagement durations

### Mode Gating and Requirements

Advanced modes require research, equipment, or training prerequisites:

- Research Requirements: Technological unlocks for advanced firing modes
- Equipment Dependencies: Special weapons or attachments enabling modes
- Class Restrictions: Role-based access to specialized firing techniques
- Weapon Tag Requirements: Specific weapon characteristics needed for modes

### Attack Resolution

Multi-shot attacks resolve deterministically with individual hit and damage calculations:

- Sequential Resolution: Each shot calculated independently with unique seeds
- Hit Determination: Accuracy-based probability with deterministic rolls
- Damage Calculation: Base damage with variance and critical hit multipliers
- Resource Consumption: Costs deducted before resolution begins
- Aggregate Results: Combined damage and casualty tracking

### Deterministic Behavior

All random elements use mission-seeded deterministic generation for reproducible outcomes:

- Mission Seeding: Consistent results from identical initial conditions
- Per-Shot Seeds: Unique deterministic values for each projectile
- Provenance Tracking: Complete audit trail of all resolution steps
- Testing Support: Predictable outcomes for balance verification

## Examples

### Single Shot Modes

Snap Shot
- AP Cost: 100% (standard action)
- Energy: 100% (normal consumption)
- Accuracy: 100% (baseline probability)
- Damage: 100% (standard output)
- Tactical Use: Default balanced option for general engagements

Aimed Shot
- AP Cost: 175% (significant time investment)
- Energy: 150% (increased resource use)
- Accuracy: 150% (precision bonus)
- Damage: 100% (standard damage)
- Tactical Use: High-value targets requiring guaranteed hits

### Burst Fire Modes

3-Round Burst
- AP Cost: 125% (moderate time investment)
- Energy: 120% (per-shot consumption)
- Shots: 300% (3 projectiles)
- Accuracy: 85% (reduced per-shot precision)
- Tactical Use: Suppressive fire against groups with hit probability tradeoffs

Full Auto
- AP Cost: 150% (major time commitment)
- Energy: 200% (high total consumption)
- Shots: 500% (5 projectiles)
- Accuracy: 70% (significant precision loss)
- Tactical Use: Area saturation against clustered enemies

### Precision Modes

Sniper Mode
- AP Cost: 200% (careful aiming process)
- Energy: 180% (precision equipment drain)
- Range: 125% (extended effective distance)
- Accuracy: 160% (extreme precision)
- Tactical Use: Long-range elimination of priority targets

Called Shot
- AP Cost: 175% (targeted aiming)
- Energy: 140% (focused concentration)
- Accuracy: 140% (improved precision)
- Damage: 120% (focused power)
- Tactical Use: Surgical strikes on specific enemy weaknesses

### Suppression Modes

Spray and Pray
- AP Cost: 100% (quick trigger pull)
- Energy: 150% (rapid consumption)
- Shots: 400% (4 projectiles)
- Accuracy: 60% (poor individual precision)
- Tactical Use: Force enemy heads down, create reaction opportunities

Grazing Fire
- AP Cost: 130% (controlled sweeping)
- Energy: 110% (efficient consumption)
- Shots: 250% (2-3 projectiles)
- Accuracy: 75% (moderate precision loss)
- Tactical Use: Controlled suppression with better accuracy than full auto

### Mode Comparison

Weapon Base Stats: AP=2, Energy=8, Accuracy=60%, Damage=10, Shots=1, Range=30

Aimed Shot Calculation
- Effective AP: ceil(2 × 1.75) = 4
- Effective Energy: ceil(8 × 1.5) = 12
- Per-Shot Accuracy: 60% × 150% = 90%
- Per-Shot Damage: 10 × 100% = 10
- Shots: round(1 × 100%) = 1

Auto Fire Calculation
- Effective AP: ceil(2 × 1.25) = 3
- Shots: round(1 × 300%) = 3
- Per-Shot Accuracy: 60% × 50% = 30%
- Per-Shot Damage: 10 × 100% = 10
- Max Range: floor(30 × 80%) = 24
- Effective Energy: Depends on per-shot flag (10 total or 30 per shot)

## Related Wiki Pages

- [Unit items.md](../items/Unit%20items.md) - Weapon equipment and loadouts
- [Damage types.md](../items/Damage%20types.md) - Damage type interactions with modes
- [Damage model.md](../items/Damage%20model.md) - How weapon modes affect damage distribution
- [Item Action Economy.md](../items/Item%20Action%20Economy.md) - Mode action costs and limitations
- [Battlescape.md](../battlescape/Battlescape.md) - Combat weapon mode usage
- [Units.md](../units/Units.md) - Unit weapon proficiency and modes
- [AI.md](../ai/AI.md) - AI weapon mode selection
- [Crafts.md](../crafts/Crafts.md) - Craft weapon systems and modes

## References to Existing Games and Mechanics

- **XCOM Series**: Weapon upgrades and firing modes
- **Halo Series**: Weapon firing modes and attachments
- **Call of Duty Series**: Weapon customization and firing modes
- **Battlefield Series**: Weapon attachments and mode selection
- **Gears of War Series**: Weapon modes and special firing options
- **Mass Effect Series**: Weapon modes and upgrade systems
- **Borderlands Series**: Weapon modes and elemental effects
- **Destiny Series**: Weapon modes and perk systems
- **Warframe**: Weapon modes and mod customization
- **Overwatch**: Hero weapon modes and abilities

