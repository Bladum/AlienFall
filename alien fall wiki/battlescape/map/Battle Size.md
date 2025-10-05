# Battle Size System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Size Definition and Grid System](#size-definition-and-grid-system)
  - [Scaling Effects and Mission Impact](#scaling-effects-and-mission-impact)
  - [Performance and Optimization Framework](#performance-and-optimization-framework)
  - [Validation and Balance Systems](#validation-and-balance-systems)
- [Examples](#examples)
  - [Micro Scale Mission](#micro-scale-mission)
  - [Small Scale Mission](#small-scale-mission)
  - [Medium Scale Mission](#medium-scale-mission)
  - [Large Scale Mission](#large-scale-mission)
  - [Huge Scale Mission](#huge-scale-mission)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battle Size System implements a high-level, data-driven control mechanism that determines tactical map scale through Map Block grid dimensions. By defining block assembly parameters, the system controls mission duration, encounter density, and strategic complexity without requiring low-level layout modifications. Seeded selection ensures reproducible map generation for consistent testing, preview systems, and multiplayer parity.

The system provides designers with a primary tuning knob for mission pacing, scaling everything from unit deployment budgets to objective density based on grid dimensions. This creates a spectrum of engagement experiences from quick skirmishes to epic confrontations while maintaining design consistency and balance.

## Mechanics

### Size Definition and Grid System
Core framework for map scale determination:
- Block Grid Dimensions: Battle size expressed as width×height block grid (e.g., 5×5 blocks)
- Tile Expansion: Each block converts to fixed tile dimensions during generation
- Deterministic Selection: Seeded random choice ensures reproducible map creation
- Mission Integration: Size selected based on mission type, difficulty, and province characteristics
- Configuration Flexibility: Data-driven size definitions support extensive modding

### Scaling Effects and Mission Impact
Comprehensive scaling across all tactical systems:
- Map Dimensions: Direct translation from block count to final tile dimensions
- Spawn Budgets: Unit deployment capacity scales with battle size and difficulty level
- Objective Density: Mission goals increase proportionally with battlefield area
- Deployment Zones: Multiple entry/exit points scale with map size and complexity
- Traversal Distances: Movement requirements increase with larger battlefields

### Performance and Optimization Framework
Technical considerations for large-scale battles:
- Memory Management: Optimized resource allocation for different battle sizes
- Pathfinding Systems: Hierarchical algorithms for extensive map navigation
- Rendering Efficiency: Chunked display systems for large-scale tactical environments
- Entity Processing: Efficient handling of increased unit counts in larger battles
- Load Balancing: Performance optimization based on size requirements

### Validation and Balance Systems
Automated checking for mission integrity:
- Reachability Verification: Ensures all objectives remain accessible at selected size
- Pacing Assessment: Mission duration scales appropriately with battlefield dimensions
- Difficulty Calibration: Spawn density and challenge level adjust dynamically
- Balance Validation: Automated testing of tactical fairness across size variations
- Preview Systems: Design tools for validating size-appropriate mission parameters

## Examples

### Micro Scale Mission
Compact tactical engagement for quick objectives:
- Block Grid: 3×3 blocks (9 total blocks providing focused battlefield)
- Tile Dimensions: 45×45 tiles (compact area for rapid resolution)
- Spawn Budget: 50% of medium battle (reduced unit count for quick engagement)
- Objectives: 1 primary objective (single-focus mission design)
- Expected Duration: 5 minutes (fast-paced tactical experience)
- Use Case: Small ambush, single-room objective, or reconnaissance mission
- Tactical Focus: Immediate action with limited maneuvering space

### Small Scale Mission
Standard tactical engagement with moderate complexity:
- Block Grid: 4×4 blocks (16 total blocks for balanced battlefield)
- Tile Dimensions: 60×60 tiles (manageable area for tactical decision-making)
- Spawn Budget: 75% of medium battle (moderate unit deployment capacity)
- Objectives: 2 objectives (dual-focus mission with secondary goals)
- Expected Duration: 8 minutes (standard mission pacing)
- Use Case: Standard UFO crash site investigation or facility breach
- Tactical Focus: Balanced exploration and combat with clear objectives

### Medium Scale Mission
Comprehensive tactical battlefield with full complexity:
- Block Grid: 5×5 blocks (25 total blocks for extensive battlefield)
- Tile Dimensions: 75×75 tiles (spacious area for strategic maneuvering)
- Spawn Budget: Base multiplier (1.0× standard deployment capacity)
- Objectives: 3 objectives (multi-focus mission with primary and secondary goals)
- Expected Duration: 12 minutes (extended tactical engagement)
- Use Case: Terror mission in small town or base assault operation
- Tactical Focus: Complex positioning, multiple objectives, and strategic depth

### Large Scale Mission
Expansive battlefield requiring coordinated operations:
- Block Grid: 6×6 blocks (36 total blocks for large-scale operations)
- Tile Dimensions: 90×90 tiles (extensive area requiring squad coordination)
- Spawn Budget: 125% of medium battle (increased unit deployment for scale)
- Objectives: 4 objectives (complex mission with multiple goal types)
- Expected Duration: 18 minutes (prolonged tactical campaign)
- Use Case: Assault on alien base facility or major defensive operation
- Tactical Focus: Large-unit coordination, area control, and extended operations

### Huge Scale Mission
Epic confrontation requiring full strategic commitment:
- Block Grid: 7×7 blocks (49 total blocks for maximum battlefield)
- Tile Dimensions: 105×105 tiles (vast area for comprehensive operations)
- Spawn Budget: 150% of medium battle (maximum unit deployment capacity)
- Objectives: 5 objectives (complex multi-phase mission structure)
- Expected Duration: 25 minutes (extended campaign-level engagement)
- Use Case: Final mission, major campaign climax, or planetary defense operation
- Tactical Focus: Full strategic commitment, multiple unit coordination, and epic scope

## Related Wiki Pages

Battle size scales all battlescape elements:

- **Battle map.md**: Map dimensions scaling with size.
- **Battle Map generator.md**: Generation adjusting to size.
- **Enemy deployments.md**: Enemy numbers scaling with size.
- **Mission objectives.md**: Objective complexity increasing with size.
- **Unit actions.md**: Action economy for larger battles.
- **Battlescape AI.md** (ai/): AI handling more units.
- **Performance systems**: Optimization for scales.
- **Mission Detection and Assignment.md** (interception/): Determining size.
- **Province.md** (geoscape/): Province affecting size.
- **Difficulty**: Scaling with size.

## References to Existing Games and Mechanics

The Battle Size system draws from scaling in games:

- **X-COM series (1994-2016)**: Mission scales from skirmishes to assaults.
- **XCOM 2 (2016)**: Dynamic sizes with varying numbers.
- **Total War series (2000-2022)**: Sizes from small to massive battles.
- **Civilization series (1991-2021)**: Combat scaling with numbers.
- **Fire Emblem series (1990-2023)**: Chapter sizes from small to large.
- **Advance Wars series (2001-2018)**: Map sizes affecting complexity.
- **Jagged Alliance series (1994-2014)**: Squad sizes and mission scales.
- **BattleTech (1984-2024)**: Lance sizes and battle scales.

