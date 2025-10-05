# Throwing

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Throwable Item Classification](#throwable-item-classification)
  - [Range Calculation System](#range-calculation-system)
  - [Accuracy and Dispersion](#accuracy-and-dispersion)
  - [Damage and Effect Resolution](#damage-and-effect-resolution)
  - [Arming and Fuse Models](#arming-and-fuse-models)
  - [Mine and Proximity Systems](#mine-and-proximity-systems)
  - [Determinism and Seeding](#determinism-and-seeding)
- [Examples](#examples)
  - [Instant Fragmentation Grenade](#instant-fragmentation-grenade)
  - [Timed Smoke Grenade](#timed-smoke-grenade)
  - [Proximity Mine Deployment](#proximity-mine-deployment)
  - [Failed Sensor Placement](#failed-sensor-placement)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Throwing implements deterministic throwable mechanics for grenades, flares, mines, and projectile devices as weapon-like actions where range scales with unit Strength and item weight while accuracy uses the standard Aim domain. Designers can tune range formulas, dispersion, fuses, and object-placement fallbacks in data to provide predictable risk/reward choices for denial, breaching, and support roles. All randomness (aim rolls, miss dispersion) is mission-seed driven for replay and multiplayer reproducibility. Throwables may deal POINT/AREA damage or spawn persistent OBJECTs with comprehensive provenance logging.

## Mechanics

### Throwable Item Classification
- Explicit Definition: Only items marked as throwables can be thrown in-mission
- Weapon-Like Records: Include weight, damage specs, fuse/arm fields, and OBJECT templates
- Consumption Rules: Single use, stack decrement, charges, or energy consumption
- Lifecycle Management: AP cost and item expenditure on successful throw
- Data-Driven Configuration: All properties defined in external configuration files

### Range Calculation System
- Strength-Weight Formula: ThrowRange = floor(BaseRangeFactor × Strength / max(1, ItemWeight))
- Aerodynamic Multipliers: Optional per-item range modifiers for design balance
- Clamp Boundaries: Enforced minimum and maximum range limits
- Tuning Knobs: BaseRangeFactor, Min/MaxRange, and per-item multipliers exposed
- Tradeoff Design: Heavier devices require greater Strength for equivalent range

### Accuracy and Dispersion
- Aim Stat Integration: Uses unit's Aim stat in standard accuracy calculations
- Precision Pipeline: Nominal precision value with contextual modifiers
- Miss Dispersion: Impact tile selection when precision insufficient
- Impact Centering: Chosen tile becomes center for damage or OBJECT placement
- UI Preview: Computed range, dispersion, and probable impact area display

### Damage and Effect Resolution
- Standard Pipeline: Impact tile → POINT/AREA damage → type multipliers → armor → distribution
- Non-Damage Effects: Flares, sensors, traps spawn OBJECTs with activation rules
- Terrain Blocking: OBJECT placement may fail with configurable fallback behavior
- Structure Absorption: AREA effects follow standard propagation and absorption rules
- Deterministic Outcomes: All effects reproducible from mission seed

### Arming and Fuse Models
- Instant Arming: Detonates on impact or immediate use
- Timed Fuse: Detonates after specified number of turns
- Delayed/Armed: Places device that activates after delay and responds to triggers
- Tactical Flexibility: Enables throw-and-retreat vs immediate blast strategies
- Data-Driven Timing: Explicit fuse and arming delay fields

### Mine and Proximity Systems
- OBJECT-Based Implementation: Placed as persistent objects with trigger rules
- Arming Delays: Turns until device becomes active with visible indicators
- Trigger Sensors: Configurable radius, line of sight, or contact activation
- Trigger Behaviors: Explode, alert, spawn hazard, or other effects
- Friendly Filtering: Configurable friend/foe exception handling

### Determinism and Seeding
- Mission Seed Foundation: All randomness seeded for identical input reproducibility
- Named RNG Streams: Distinct streams for throw simulation, miss dispersion, obstruction
- Multiplayer Parity: Lockstep behavior across network play
- Replay Capability: Complete reconstruction from logged provenance
- Balance Testing: Seeded preview tools for reproducible testing

## Examples

### Instant Fragmentation Grenade
- Item Profile: Light grenade, weight = 0.5, instant arming, AREA damage radius = 2
- Range Calculation: Strength 5, BaseRangeFactor 3 → ThrowRange = floor(3 × 5 / 0.5) = 30 tiles
- Accuracy Resolution: Aim roll determines impact dispersion within 2-tile radius
- Effect Application: AREA damage with structure absorption and ray propagation
- Consumption: Single use, expended on throw

### Timed Smoke Grenade
- Fuse Configuration: Timed fuse = 1 turn, smoke emission on expiration
- Tactical Sequence: Throw into position, retreat with remaining AP, smoke appears next turn
- Area Denial: Creates persistent visibility obstruction for multiple turns
- Predictable Timing: Exact turn-based activation for strategic planning
- Resource Management: AP investment for future positioning advantage

### Proximity Mine Deployment
- Arming Profile: Arming delay = 2 turns, 1-tile proximity trigger
- Placement Logic: OBJECT placement with fallback to nearest valid tile
- Trigger Conditions: Proximity detection ignoring friendly units
- Activation Visibility: Clear arming countdown and active state indicators
- Strategic Denial: Creates persistent threat zone for enemy movement

### Failed Sensor Placement
- Terrain Conflict: Thrown at obstructed wall tile, placement blocked
- Fallback Behavior: Data-configured response (nearest tile or action failure)
- Consumption Rules: Item may be consumed even on placement failure
- Designer Control: Configurable behavior prevents exploitation
- Predictable Outcomes: Deterministic fallback ensures consistent behavior

## Related Wiki Pages

- [Grenades.md](../battlescape/Grenades.md) - Throwing grenades.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Accuracy for throwing.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Throwing as an action.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Throwing smoke grenades.
- [Mines.md](../battlescape/Mines.md) - Throwing mines.
- [Stats.md](../units/Stats.md) - Strength affects range.
- [Inventory.md](../items/Inventory.md) - Throwable items.
- [Movement.md](../battlescape/Movement.md) - Positioning for throws.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - LoS for targeting.
- [Terrain damage.md](../battlescape/Terrain%20damage.md) - Explosives damage terrain.

## References to Existing Games and Mechanics

- X-COM series: Grenade throwing mechanics.
- Dungeons & Dragons: Thrown weapons and explosives.
- Fire Emblem: Javelins and thrown items.
- Advance Wars: Grenade and missile units.
- Rainbow Six Siege: Grenade throwing.
- Counter-Strike: Grenade throws.
- Call of Duty: Grenade physics.
- Unreal Tournament: Thrown weapons.

