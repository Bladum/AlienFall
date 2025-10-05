# Battle Tile System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Tile Composition](#tile-composition)
  - [Runtime State Management](#runtime-state-management)
  - [Destructibility and Material Framework](#destructibility-and-material-framework)
  - [Explosion Propagation and Local Effects](#explosion-propagation-and-local-effects)
  - [Map Generation and Graphics](#map-generation-and-graphics)
  - [Integration and Provenance Systems](#integration-and-provenance-systems)
- [Examples](#examples)
  - [Wall Destruction Sequence](#wall-destruction-sequence)
  - [Wooden Floor Structural Failure](#wooden-floor-structural-failure)
  - [Concrete Wall Demolition](#concrete-wall-demolition)
  - [Glass Window Fragmentation](#glass-window-fragmentation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battle Tile System defines the atomic unit of tactical simulation: individual grid cells (referred to as "tiles") that encode terrain properties, blocking geometry, material characteristics, and provenance metadata. Each tile serves as a deterministic building block for the battlefield, containing information about movement, cover, destruction, and environmental effects. The system ensures reproducible outcomes through data-driven material definitions and seeded random processes.

Tiles form the foundation of all tactical interactions, providing the physical structure that determines movement possibilities, defensive positioning, damage propagation, and environmental effects. The modular design supports extensive modding while maintaining consistent gameplay mechanics across different mission types and terrain configurations.

**Naming Clarification**: To avoid confusion, we distinguish between:
- **Tile**: The individual grid cell or position on the battlefield (previously "battle tile").
- **Tile Type**: The terrain type assigned to a tile, defining its properties (previously "terrain tile").

The battlefield is a 2D array of Battle Tiles, such as 60x60, created by Map Scripts using Map Generators. Map Blocks (15x15 tiles) are assembled into larger maps (e.g., 4x4 to 7x7 blocks), with tiles filled based on block content.

A Battle Tile comprises tile element + unit + smoke/fire + objects + fog of war state.

## Mechanics

### Tile Composition
Each tile contains a single tile type that determines its core properties:
- **Tile Type**: Defines blocking behavior (move, sight, fire), material, and destructibility. No separate FLOOR/OBJECT distinction; tile types like WALL block movement, while GROUND does not.
- **Optional Unit**: A single unit may occupy the tile (typically on non-blocking types).
- **Optional Objects**: Mines, deployables, or other items.
- **Optional Effects**: Smoke, fire, or other environmental effects with intensity.
- **Fog of War Status**: Visibility per faction.

Tile types are highly destructible, transitioning through states (e.g., WALL → BROKEN WALL → DESTROYED WALL → GROUND) with changing properties.

### Runtime State Management
Dynamic tile state tracking during tactical engagements:
- Occupant Reference: Single unit occupying the tile or null state
- Object Inventory: Ordered list of world objects (mines, grenades, flares, corpses, deployables)
- Fog-of-War State: Per-side visibility tracking (one boolean per tactical faction)
- Environmental Effects: Active effects with intensity levels and duration tracking
- Material Properties: Current material characteristics and damage state
- Provenance Data: Origin information for debugging and replay reconstruction

### Destructibility and Material Framework
Comprehensive damage and destruction mechanics with sequential transitions:
- **Material Categories**: Wood, metal, concrete, etc., with resistance, damage multipliers, and transition thresholds.
- **Destruction Sequence**: Tiles transition through states (e.g., WALL → BROKEN WALL → DESTROYED WALL → GROUND), each with distinct properties (blocking, graphics).
- **Damage Resolution**: Threshold-based transitions; destroyed variants preserve gameplay tags but change visuals and blocking.
- **Secondary Effects**: Material-defined consequences like smoke, fire, or debris.

### Explosion Propagation and Local Effects
Deterministic damage spread and environmental consequences:
- Blocking and Attenuation: Tiles block or reduce explosion propagation based on material.
- Splash Damage: Reduced damage to neighbors based on obstacles.
- Secondary Propagation: Transitions can trigger additional effects.
- Seeded Randomness: All stochastic effects use seeds for reproducibility.

### Map Generation and Graphics
- **Map Blocks**: 15x15 tiles, built using single IDs (e.g., '*', 'k', '>') representing tile types.
- **Battlefield Assembly**: Map Scripts use generators to arrange blocks (4x4 to 7x7) into full maps, filling tiles accordingly.
- **Graphics Variation**: Each tile type has shared stats but can use multiple graphics for variety (e.g., wooden furniture with random visuals). Modders assign multiple graphics to single types.
- **Global Overrides**: Map Scripts can change graphics globally for specific tile types.

### Integration and Provenance Systems
Comprehensive tracking and modding support:
- Provenance Metadata: Origin information (map block ID, coordinates, prefab) for traceability.
- Data-Driven Design: Definitions in TOML for modding.
- Deterministic Behavior: Seeded processes for identical outcomes.
- Replay Support: Event logging for debugging.

## Examples

### Wall Destruction Sequence
Progressive destruction of a wall tile:
- **Intact WALL**: Blocks movement, sight, and fire.
- **Damaged to BROKEN WALL**: Still blocks movement but allows sight/fire through.
- **Further damaged to DESTROYED WALL**: Becomes floor-like, movable but with distinct graphics (e.g., rubble).
- **Heavily damaged to GROUND**: Fully traversable, graphics match normal ground but may differ.

### Wooden Floor Structural Failure
Destructible floor tile failure:
- Material: Wood with flammability.
- Damage Scenario: Heavy impact exceeding integrity.
- Result: Transitions to hole or compromised state, increasing movement cost or blocking heavy units.
- Secondary Effects: Potential fire spawning.
- Strategic Effect: Creates elevation opportunities or obstacles.

### Concrete Wall Demolition
High-resistance tile requiring significant force:
- Material: Concrete with high resistance.
- Damage Scenario: Large impacts eventually cause transition through states.
- Result: Wall to rubble floor, removing blocking.
- Strategic Impact: New paths and cover positions.

### Glass Window Fragmentation
Fragile tile with low integrity:
- Material: Glass with low threshold.
- Result: Shatters completely, removing blocking.
- Secondary Effects: Fragmentation to adjacent tiles.
- Visibility Impact: Immediate sight line changes.

## Related Wiki Pages

- [Battle map.md](../battlescape/Battle%20map.md) - Map composed of tiles.
- [Terrain damage.md](../battlescape/Terrain%20damage.md) - Damage affecting tiles.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Tile height properties.
- [Map blocks.md](../battlescape/Map%20blocks.md) - Tiles assembled into blocks.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Visibility depending on tiles.
- [Line of Fire.md](../battlescape/Line%20of%20Fire.md) - Firing paths interacting with tiles.
- [Action - Movement.md](../battlescape/Action%20-%20Movement.md) - Movement costs by tile types.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Effects modifying tiles.
- [Explosion propagation.md](../battlescape/Explosion%20propagation.md) - Damage spreading through tiles.
- [Material properties.md](../battlescape/Material%20properties.md) - Tile destruction mechanics.

## References to Existing Games and Mechanics

The Battle Tile system draws from destructible terrain in games:

- **X-COM series (1994-2016)**: Destructible walls, doors, floors.
- **XCOM 2 (2016)**: Advanced destructible terrain with rubble.
- **Jagged Alliance series (1994-2014)**: Tile-based destruction with materials.
- **Rainbow Six Siege (2015)**: Destructible walls and objects.
- **Battlefield series (2002-2021)**: Environmental destruction.
- **Call of Duty series (2007-2023)**: Destructible cover.
- **Far Cry series (2004-2021)**: Environmental destruction.
- **Half-Life series (1998-2020)**: Interactive environments.

