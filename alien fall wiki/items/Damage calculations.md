# Damage Calculations

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Damage Generation](#damage-generation)
  - [Type Multiplication](#type-multiplication)
  - [Armor Mitigation](#armor-mitigation)
  - [Channel Distribution](#channel-distribution)
  - [State Application](#state-application)
  - [Derived Effects](#derived-effects)
  - [Provenance Logging](#provenance-logging)
- [Examples](#examples)
  - [Cannon Shot Resolution](#cannon-shot-resolution)
  - [EMP Pulse Resolution](#emp-pulse-resolution)
  - [Indoor vs Outdoor Blast Propagation](#indoor-vs-outdoor-blast-propagation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Damage Calculations represents the authoritative, deterministic pipeline that transforms weapon effects into final game state modifications in Alien Fall. The system separates concerns between raw damage generation, type multipliers, armor penetration, channel routing, and state application to ensure each stage remains simple, data-driven, and verifiable. As the single source of truth for stat mutations, the pipeline records complete provenance using seeded randomness where required, enabling designers and QA to reproduce outcomes and balance confidently.

The damage calculation system serves as the canonical executor that produces inspectable, reproducible stat changes from weapon impact to final resolution, maintaining full auditability while supporting complex damage interactions.

## Mechanics

### Damage Generation

Weapon damage resolution computes point damage (direct hits) and area damage contributions using seeded randomness for variance and deterministic radial propagation for area effects:

- Per-Tile Damage Calculation: For each affected tile, combines point damage (if applicable) with area contributions that reach the tile through structure absorption and ray propagation
- Damage Breakdown Logging: Records per-tile contributions including point amounts, area distributions, ray paths, and absorbed damage for complete transparency

### Type Multiplication

Type-based damage scaling through weapon-target resistance interactions:

- Damage Type Lookup: Retrieves target resistance multipliers for weapon damage types, using configurable defaults when resistance data is missing
- Multiplier Application: Applies percentage-based multipliers to raw damage, computing typed damage with full precision tracking
- Multiplier Recording: Documents the applied multiplier value and resulting numeric damage for provenance and balancing analysis

### Armor Mitigation

Flat damage reduction through armor penetration mechanics:

- Effective Armor Calculation: Computes net armor after weapon penetration subtraction, ensuring non-negative armor values
- Damage Reduction: Subtracts effective armor from typed damage, producing residual damage for channel distribution
- Armor Recording: Logs effective armor values and post-mitigation damage for complete damage flow documentation

### Channel Distribution

Residual damage routing through stat channel allocation:

- Damage Model Application: Routes residual damage through weapon-specified distribution vectors defining health, stun, energy, morale, and other stat allocations
- Percentage Normalization: Adjusts distribution percentages to ensure they sum to 100% for proper damage allocation
- Channel Processing: For each stat channel, calculates raw channel damage, applies target-specific multipliers, implements rounding rules, and enforces stat caps with configurable overflow policies
- Resolution Ordering: Processes channels in canonical order (health → stun → energy → morale → AP → sight) to ensure deterministic interaction effects

### State Application

Final stat modifications and status generation:

- Stat Delta Application: Updates unit state with final channel damage deltas, modifying health, stun, morale, energy, and action point values
- Status Generation: Creates derived status effects based on damage application, including stun accumulation and morale changes
- State Persistence: Records per-channel intermediate and final values for complete provenance tracking

### Derived Effects

Post-damage threshold evaluations and stochastic effects:

- Threshold Evaluation: Performs deterministic checks for wounds, unconsciousness, death, morale failures, and panic triggers based on stat changes
- Seeded Randomness: Uses named, seeded RNG streams for stochastic effects like wound rolls while maintaining reproducibility
- Effect Recording: Documents all derived events (wounds, panic, death, object destruction) in the same provenance stream for complete audit trails

### Provenance Logging

Complete audit trail for reproducibility and analysis:

- Complete Audit Trail: Records weapon identification, mission context, attack seeds, per-tile damage breakdowns, type multipliers, effective armor, channel distributions, and derived events
- Reproducibility Support: Persists per-tile and per-unit breakdowns enabling replay reconstruction and telemetry analysis
- Deterministic Verification: Ensures identical inputs (seeds, map state, unit identifiers, action indices) produce identical outputs for testing and debugging

## Examples

### Cannon Shot Resolution
Weapon Configuration: Field cannon with 12 point damage, 6 area damage, explosive type, 3 armor piercing, 80% health/20% stun distribution
Target Profile: 6 flat armor, 75% explosive resistance, 10 health pool
Pipeline Execution:
- Damage Generation: 12 (point) + 6 (area) = 18 raw damage
- Type Multiplication: 18 × 0.75 = 13.5 typed damage
- Armor Mitigation: max(0, 6 - 3) = 3 effective armor, 13.5 - 3 = 10.5 residual damage
- Channel Distribution: 10.5 × 0.8 = 8.4 health damage, 10.5 × 0.2 = 2.1 stun damage
- State Application: Health reduced from 10 to 1.6, stun increased by 2.1
- Derived Effects: No wounds (health above 0), no stun threshold reached

### EMP Pulse Resolution
Weapon Configuration: EMP pulse with 0 point damage, 8 area damage, EMP type, 0 armor piercing, 60% stun/30% energy/10% systems distribution
Target Profile: 2 flat armor, 120% EMP vulnerability, 10 health pool, 8 energy pool
Pipeline Execution:
- Damage Generation: 0 (point) + 8 (area) = 8 raw damage
- Type Multiplication: 8 × 1.2 = 9.6 typed damage
- Armor Mitigation: max(0, 2 - 0) = 2 effective armor, 9.6 - 2 = 7.6 residual damage
- Channel Distribution: 7.6 × 0.6 = 4.56 stun, 7.6 × 0.3 = 2.28 energy, 7.6 × 0.1 = 0.76 systems
- State Application: Stun increased by 4.56, energy reduced from 8 to 5.72
- Derived Effects: Potential stun effects if unit stun threshold reached

### Indoor vs Outdoor Blast Propagation
Weapon Configuration: Grenade with 10 point damage, 8 area damage, 4 structure absorption per wall
Terrain Configuration: Thick walls (4 absorption), normal walls (2 absorption)
Propagation Results:
- Direct hit tile: 10 (point) + 8 (area) = 18 total damage
- Adjacent tile through thick wall: 8 - 4 = 4 area damage
- Corner tile through two walls: 8 - 4 - 2 = 2 area damage
- Distant tile through thick wall: 6 - 4 = 2 area damage (falloff applied before absorption)

## Related Wiki Pages

- [Damage model.md](../items/Damage%20model.md) - Damage distribution to unit stats.
- [Damage types.md](../items/Damage%20types.md) - Type-based damage multipliers.
- [Weapon modes.md](../items/Weapon%20modes.md) - Mode-based damage calculations.
- [Unit items.md](../items/Unit%20items.md) - Weapon damage values.
- [Wounds.md](../units/Wounds.md) - Wound calculation integration.
- [Battlescape.md](../battlescape/Battlescape.md) - Combat damage resolution.
- [Units.md](../units/Units.md) - Unit damage calculations.
- [AI.md](../ai/AI.md) - AI damage evaluation and targeting.

## References to Existing Games and Mechanics

- **XCOM Series**: Damage and armor penetration calculations
- **Fire Emblem Series**: Weapon triangle and damage calculations
- **Final Fantasy Series**: Elemental damage and resistance calculations
- **Dark Souls Series**: Damage and defense calculation systems
- **Monster Hunter Series**: Weapon damage and elemental calculations
- **Warhammer 40k**: Damage and armor save calculations
- **GURPS**: Hit location and damage calculation systems
- **Dungeons & Dragons**: Damage calculation and resistance mechanics
- **BattleTech**: Armor penetration and damage calculations
- **MechWarrior Series**: Component damage calculation systems

