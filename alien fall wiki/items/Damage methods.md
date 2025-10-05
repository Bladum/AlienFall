# Damage Methods

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Point Component](#point-component)
  - [Area Component](#area-component)
  - [Ray Propagation](#ray-propagation)
  - [Result Composition](#result-composition)
  - [Design Knobs](#design-knobs)
  - [Performance Considerations](#performance-considerations)
- [Examples](#examples)
  - [Point Damage Example](#point-damage-example)
  - [Area Damage Example](#area-damage-example)
  - [Combined Damage Example](#combined-damage-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Damage Methods convert weapon and ability specifications into deterministic, auditable per-tile raw damage maps that downstream systems transform into game effects in Alien Fall. They handle low-level numeric calculations including point/impact contributions, radial area falloff, ray propagation, and structure absorption. All randomness uses seeded generators with recorded provenance to ensure reproducible replays and reliable telemetry. The system remains intentionally simple and data-driven, allowing designers to author new weapons and area effects without code changes while maintaining complete auditability.

## Mechanics

### Point Component

Single-tile direct-hit contribution applied exclusively to the impact tile:

- Purpose: Direct-hit contribution applied only to the aimed/impact tile
- Resolution Rule: When base_point > 0, calculate POINT_actual using seeded uniform random sampling within variance range, otherwise skip point component entirely
- Contribution: POINT_actual added solely to center tile's raw_damage with complete provenance tracking

### Area Component

Radial area-of-effect damage with deterministic falloff:

- Specification: Compact Power[:DropOff] format where both values are integers, with DropOff defaulting to constant damage when omitted
- Radius Calculation: Effective radius determined by Power/DropOff ratio or maximum configured radius, clamped to design limits
- Per-Tile Base Value: Damage_area(d) = max(0, Power - DropOff × d) for integer distances within radius

### Ray Propagation

Deterministic ray tracing with structure interaction:

- Raycasting: Deterministic ray tracing from center to each candidate tile with configurable resolution and sampling density
- Structure Absorption: Each ray crossing structure subtracts tile's structureAbsorb from RemainingPower, stopping ray when depleted
- Multi-Ray Handling: Deterministic combiner policies (sum, first-hit, maximum, average) for tiles reached by multiple rays with explicit policy recording
- Early Exit: Rays terminate when RemainingPower drops below threshold, documented and data-driven for performance

### Result Composition

Per-tile damage calculation and provenance tracking:

- Per-Tile Calculation: raw_damage = (POINT_actual if center tile) + (resolved AREA contributions per combiner policy)
- Provenance Map: Each tile entry includes point contribution, area contribution, absorbed amount, ray traces, and per-step RemainingPower
- Downstream Integration: Raw damage map feeds into type multipliers, armor mitigation, and stat distribution systems

### Design Knobs

Configurable parameters for authoring flexibility:

- Configuration Parameters: MaxAoERadius, default DropOff semantics, structureAbsorb per material, ray combiner policy, sampling density, rounding rules
- Authoring Flexibility: Data-driven tuning allowing designers to modify behavior without code changes
- Policy Selection: Configurable ray combiner and sampling strategies for different weapon archetypes

### Performance Considerations

Optimization strategies maintaining determinism:

- Optimization Strategies: Grid masks, precomputed visibility cones, early culling while preserving deterministic ordering
- Early Exit Rules: Data-driven thresholds for ray termination when RemainingPower becomes negligible
- Deterministic Ordering: All optimizations maintain reproducible tie-breaking and processing sequences

## Examples

### Point Damage Example
Weapon Configuration: base_point = 10
Variance Application: Seeded U(0.5, 1.5) = 0.8
Result: POINT_actual = round(10 × 0.8) = 8 applied to center tile only

### Area Damage Example
Weapon Configuration: Power = 12, DropOff = 3
Radius Calculation: R = floor(12/3) = 4
Damage Distribution: Distance 0 = 12, 1 = 9, 2 = 6, 3 = 3, 4 = 0
Structure Impact: Wall with structureAbsorb = 5 reduces distance 2 damage from 6 to 1, blocking further propagation on affected ray

### Combined Damage Example
Weapon Configuration: base_point = 15, area_power = 10, area_dropoff = 2
Center Tile: POINT_actual (7-22) + area_damage(0) (10) = 17-32 total damage
Adjacent Tiles: area_damage(1) (8) each
Extended Range: area_damage(2) (6) through area_damage(5) (0) with structure absorption reducing distant contributions

## Related Wiki Pages

- [Damage types.md](../items/Damage%20types.md) - Damage type classifications and effects
- [Damage model.md](../items/Damage%20model.md) - Damage calculation frameworks
- [Damage calculations.md](../items/Damage%20calculations.md) - Calculation systems and formulas
- [Wounds.md](../battlescape/Wounds.md) - Damage application and wound systems
- [Battle tile.md](../battlescape/Battle%20tile.md) - Tile-based damage effects
- [Weapon modes.md](../items/Weapon%20modes.md) - Weapon system integrations
- [Units.md](../units/Units.md) - Unit damage and resilience systems
- [AI.md](../ai/AI.md) - AI targeting and damage optimization
- [Technical.md](../technical/Technical.md) - Performance and technical considerations
- [Modding.md](../technical/Modding.md) - Custom damage method creation

## References to Existing Games and Mechanics

- **X-COM Series**: Damage calculations and armor penetration
- **Fire Emblem Series**: Weapon triangle and damage modifiers
- **Final Fantasy Tactics**: Damage formulas and elemental systems
- **Advance Wars**: Damage charts and terrain modifiers
- **Tactics Ogre**: Damage systems and critical hits
- **Disgaea Series**: Damage calculations and stat modifiers
- **Persona Series**: Damage types and elemental affinities
- **Mass Effect Series**: Damage systems and shield mechanics
- **Dragon Age Series**: Damage mechanics and resistance systems
- **Fallout Series**: Damage calculations and armor systems

