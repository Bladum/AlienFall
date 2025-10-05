# Terrain Elevation

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Elevation Types](#elevation-types)
  - [Movement Effects](#movement-effects)
  - [Visual Representation](#visual-representation)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [High Floor Movement](#high-floor-movement)
  - [Elevation Change Penalties](#elevation-change-penalties)
  - [Strategic Positioning](#strategic-positioning)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Terrain elevation provides simple vertical differentiation on otherwise flat battlefields through high and low floor variations. Battle tiles maintain a single layer system where floors and walls exist at one level, with elevation changes represented solely through normal and high floor tiles. High floors appear as slightly lighter colored tiles and may impose movement restrictions or costs when transitioning between elevation levels. This minimal elevation system creates basic tactical positioning without complex multi-layer mechanics.

## Mechanics

### Elevation Types
Battlefield elevation uses a simple two-tier system.

**Floor Types:**
- **Normal Floor**: Standard ground level tiles with no elevation modifiers
- **High Floor**: Elevated floor tiles appearing slightly lighter in color
- **Walls**: Vertical barriers that block movement and line of sight
- **Water**: Floor variation that may block or impede movement

**Elevation Properties:**
- Single Layer: All tiles exist on one horizontal plane
- Visual Distinction: High floors use lighter color palette
- Movement Impact: Optional restrictions on elevation transitions
- No Stacking: Tiles cannot occupy multiple elevation levels

### Movement Effects
Elevation changes may affect unit movement between tiles.

**Transition Rules:**
- **Same Elevation**: Normal movement costs between matching floor types
- **Elevation Change**: Potential movement restrictions or increased costs
- **Blocked Transitions**: Units cannot move between incompatible elevations
- **Directional Freedom**: Movement possible in all directions regardless of elevation

**Cost Modifiers:**
- **High Floor Access**: May require additional action points to reach
- **Elevation Penalty**: Increased movement cost for changing levels
- **Terrain Interaction**: Elevation effects combine with other tile properties
- **Unit Independence**: Movement effects apply regardless of unit type

### Visual Representation
Elevation differences appear through simple visual cues.

**Display Elements:**
- **Color Variation**: High floors use lighter color than normal floors
- **Tile Consistency**: All tiles maintain standard grid alignment
- **No Height Rendering**: No 3D elevation or perspective effects
- **Clear Distinction**: Visual difference immediately apparent to players

**UI Integration:**
- **Path Preview**: Movement paths show elevation change costs
- **Tile Highlighting**: High floors highlighted during unit selection
- **Tooltip Information**: Elevation effects displayed on tile inspection
- **Strategic Overlay**: Optional elevation layer in tactical view

### Determinism and Provenance
Elevation effects use deterministic calculations for consistent gameplay.

**Predictable Effects:**
- **Fixed Costs**: Elevation movement penalties use static values
- **No Random Elements**: All elevation effects are rule-based
- **State Tracking**: Current elevation state maintained per tile
- **Transition Logging**: All elevation changes recorded for debugging

**Provenance Requirements:**
- **Movement Tracking**: Elevation-based movement costs logged
- **State Changes**: Tile elevation modifications documented
- **Effect Calculation**: All elevation modifiers traceable
- **Balance Analysis**: Elevation impact data available for tuning

## Examples

### High Floor Movement
Unit attempts to move from normal floor to adjacent high floor tile. If elevation change penalty active, movement costs +1 AP. High floor appears lighter gray, providing clear visual distinction. Unit successfully moves but spends additional action point for elevation transition.

### Elevation Change Penalties
Squad advances through mixed terrain with normal and high floor tiles. Movement between same elevation types costs 1 AP per tile. Changing from normal to high floor costs 2 AP total. Pathfinding algorithm calculates most efficient route considering elevation penalties.

### Strategic Positioning
Defensive unit positions on high floor overlooking normal floor approaches. High ground provides no combat bonuses, only visual distinction. Attacking units must pay elevation change cost to engage. No line of sight or accuracy modifiers from elevation difference.

## Data Structure

```toml
[elevation]
id = "high_floor"
name = "High Floor"
type = "floor"

[elevation.properties]
color_modifier = { r = 1.2, g = 1.2, b = 1.2 }  # 20% lighter
movement_cost = 2  # AP cost to enter from normal floor
blocks_movement = false
provides_cover = false

[elevation.transitions]
from_normal = { cost = 2, blocked = false }
from_high = { cost = 1, blocked = false }
diagonal_penalty = 0

[elevation.visual]
sprite_normal = "tiles/floor_normal.png"
sprite_high = "tiles/floor_high.png"
highlight_color = "yellow"

[elevation.metadata]
rarity = "common"
destructible = true
material = "concrete"
```

## Related Wiki Pages

- [Movement.md](../battlescape/Movement.md) - Elevation effects on movement costs
- [Line of sight.md](./Line%20of%20sight.md) - Elevation impact on visibility
- [Battle Map.md](../battlescape/Battle%20Map.md) - Map generation with elevation
- [Terrain damage.md](./Terrain%20damage.md) - Elevation changes from damage
- [Unit actions.md](../battlescape/Unit%20actions.md) - Actions considering elevation

## References to Existing Games and Mechanics

- X-COM series: Simple height advantages without complex elevation
- Fire Emblem series: Basic elevation bonuses
- Advance Wars: Terrain height affecting movement
- Civilization series: Hill movement penalties
- Jagged Alliance series: Floor level differentiation
- Fallout series: Minimal elevation systems

