# Terrain Damage

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Damage Resolution Priority](#damage-resolution-priority)
  - [Damage Calculation Framework](#damage-calculation-framework)
  - [Material and Terrain Properties](#material-and-terrain-properties)
  - [Ray Propagation System](#ray-propagation-system)
  - [Multi-Target Tile Distribution](#multi-target-tile-distribution)
  - [Provenance and Determinism](#provenance-and-determinism)
- [Examples](#examples)
  - [Weapon POINT Damage Samples](#weapon-point-damage-samples)
  - [Frag Grenade AREA Falloff](#frag-grenade-area-falloff)
  - [Structure Absorption Scenario](#structure-absorption-scenario)
  - [Multi-Object Tile Damage](#multi-object-tile-damage)
  - [Provenance Logging Example](#provenance-logging-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Terrain damage applies the same deterministic damage pipeline used for units to tiles, structures, and props with predictable explosive and structural interactions. The system separates POINT (seeded single-tile variability) and AREA (deterministic radial falloff with ray-based attenuation) methods for clear authoring control. Material tables, flat armor, and structure absorption are fully data-driven, enabling breach behaviors, rubble conversion, and propagation effects. Complete per-tile provenance and seeded calculations ensure reproducible destructive sequences for testing, multiplayer sync, and debugging.

## Mechanics

### Damage Resolution Priority
- Single Hit Processing: POINT component applied first to impact tile's highest-priority target
- Target Hierarchy: Unit → structural → prop → tile (configurable hit priority)
- POINT Absorption: If target fully absorbs POINT damage, no spillover to other targets
- AREA Application: Applied to all affected tiles including impact tile
- Multi-Target Handling: AREA affects all targets on tile independently

### Damage Calculation Framework
- POINT Randomness: Seeded calculation with actualPoint = round(basePoint × U(0.5, 1.5))
- AREA Falloff: R = floor(Power / DropOff) when DropOff > 0
- Distance Attenuation: Damage_at_distance(d) = max(0, Power − DropOff × d) for 0 ≤ d ≤ R
- Constant AREA: When DropOff = 0, Power applied within MaxAoERadius
- Type Multipliers: postType = floor(damage × (typeMultiplier / 100))
- Armor Application: final = max(0, postType − flatArmor)

### Material and Terrain Properties
- Flat Armor: Integer armor value subtracted after type multipliers
- Structure Absorption: Power reduction for ray propagation through materials
- Material Tags: Metal, wood, stone, organic, etc. with associated properties
- Tileset-Specific: Material properties configurable per tileset and world
- Dynamic State: Armor and absorption values change after destruction
- Hit Priority: Deterministic per-tile object lists ordered by processing priority
- HP Pools: Separate health pools for props and structural elements

### Ray Propagation System
- Deterministic Raycasts: Rays cast from explosion center to affected tiles
- Power Absorption: Crossing blocking tiles subtracts structureAbsorb from remaining power
- Ray Termination: Rays end when remaining power ≤ 0
- Partial Occlusion: Produces realistic absorption and shielding effects
- Performance Optimization: Short-circuit when power drops below threshold

### Multi-Target Tile Distribution
- Independent Processing: Each target receives damage scaled by typeMultiplier and reduced by flatArmor
- Destruction Conversion: Destroyed props convert to rubble with new armor/hitPriority values
- State Transitions: Deterministic geometry changes (window → broken glass rubble)
- HP Pool Separation: Distinct health pools for props and structural elements
- Persistent Changes: Terrain modifications affect subsequent cover and navigation

### Provenance and Determinism
- Seeded RNG: Mission/attack seed ensures identical outcomes
- POINT Variability: Seeded randomness for single-tile damage
- AREA Determinism: Predictable falloff and propagation
- Complete Logging: Per-tile provenance with point/area values, absorption, rays
- Replay Support: Exact reconstruction from logged data

## Examples

### Weapon POINT Damage Samples
- Pistol: basePoint = 5 → actual = 3-7 (seeded random range)
- Sniper Rifle: basePoint = 8 → actual = 4-12
- Plasma Pistol: basePoint = 11 → actual = 6-16
- Heavy Plasma: basePoint = 22 → actual = 12-32

### Frag Grenade AREA Falloff
- Specification: "0/12:2" (POINT/Power:DropOff)
- Calculation: Power = 12, DropOff = 2 → R = floor(12/2) = 6
- Damage Pattern: Distance 0: 12, 1: 10, 2: 8, 3: 6, 4: 4, 5: 2

### Structure Absorption Scenario
- Explosion Setup: Grenade adjacent to thick wall (structureAbsorb = 5)
- Ray Propagation: Rays crossing wall subtract 5 power per crossing
- Attenuation Effect: Downstream tiles receive reduced or zero AREA damage
- Shielding Behavior: Walls provide realistic blast protection

### Multi-Object Tile Damage
- Tile Contents: Civilian unit and wooden crate
- AREA Application: Damage applied independently to both targets
- Individual Resolution: Each receives typeMultiplier scaling and flatArmor reduction
- Destruction Handling: Crate converts to rubble with new armor properties
- Persistent Effects: Changed terrain affects future combat positioning

### Provenance Logging Example
- Attack Record: { tileId: 42, point: 8, area: 10, absorbed: 5, final: 3 }
- Ray Trace: { rayId: 1, path: [...], remaining: 2, absorbedPerStep: [...] }
- Debug Support: Complete audit trail for replay and analysis

## Related Wiki Pages

- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Terrain changes affect elevation.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Fire causes terrain damage.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Actions that cause terrain damage.
- [Grenades.md](../battlescape/Grenades.md) - Explosives damage terrain.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Destroyed terrain affects LoS.
- [Movement.md](../battlescape/Movement.md) - Terrain changes affect movement.
- [Cover.md](../battlescape/Cover.md) - Destroyed cover changes tactics.
- [Battle Map.md](../battlescape/Battle%20Map.md) - Terrain layout and destruction.
- [Structures.md](../battlescape/Structures.md) - Building damage.
- [Props.md](../battlescape/Props.md) - Object destruction.

## References to Existing Games and Mechanics

- X-COM series: Terrain destruction from explosives and plasma.
- Advance Wars: Terrain changes from battles.
- Fire Emblem: Destructible terrain and structures.
- Command & Conquer: Terrain deformation.
- Battlefield series: Environmental destruction.
- Call of Duty: Destructible environments.
- Half-Life: Physics-based destruction.
- Unreal Tournament: Environmental hazards.

