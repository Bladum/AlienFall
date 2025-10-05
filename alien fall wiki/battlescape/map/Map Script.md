# Map Scripts
  - [Repair and Fallback Sequence](#repair-and-fallback-sequence)le of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Script Execution Model](#script-execution-model)
  - [Step Types and Actions](#step-types-and-actions)
  - [Placement and Modification Actions](#placement-and-modification-actions)
  - [Flag and Branching System](#flag-and-branching-system)
  - [Validation and Repair Framework](#validation-and-repair-framework)
- [Examples](#examples)
  - [Central Core Placement](#central-core-placement)
  - [Defensive Perimeter Construction](#defensive-perimeter-construction)
  - [Debris Scatter Distribution](#debris-scatter-distribution)
  - [Mission Craft Integration](#mission-craft-integration)
  - [Terrain Fill Completion](#terrain-fill-completion)
  - [Repair and Fallback Sequence](#repair-and-fallback-sequence)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)


## Overview

Map Scripts are declarative, deterministic recipes that guide the Map Generator in assembling Map Blocks, anchors, and post-processing effects. Scripts encode placement heuristics, fallbacks, and validation checks as ordered step sequences executed with the mission seed. Steps can read and set named flags for conditional logic, branching, and contextual outcomes. Every step emits structured provenance for seeded previews, deterministic debugging, and multiplayer synchronization. The system enables handcrafted set-pieces to coexist with procedural variety while maintaining reproducible outcomes.

## Mechanics

### Script Execution Model
- Step Sequence: Ordered execution of declarative placement and validation steps with predictable outcomes
- Deterministic Processing: All random choices use mission/world seed for reproducibility across sessions
- Bounded Retries: Limited placement attempts before fallback execution to prevent infinite loops
- Validation Checks: Post-execution verification of key invariants (reachability, connectivity, accessibility)
- Repair Logic: Automatic correction steps when validation fails, maintaining map usability

### Step Types and Actions
- Conditional Steps: Flag-based execution gating with must_be true/false conditions for branching logic
- Probabilistic Gates: Seeded chance values for optional step execution and variety generation
- Filter Operations: Block pool restriction by group, tags, size, and rotation permissions for targeted selection
- Selection Modes: Random, weighted, or best-fit block picking with instance limits for controlled distribution
- Placement Patterns: Single, line, outline, flood-fill, and fill-remaining placement strategies for diverse layouts

### Placement and Modification Actions
- Specific Block Insertion: Named block placement for mission-critical elements and handcrafted set-pieces
- Special Asset Addition: XCOM craft, UFO interiors, facility blocks with configurable parameters
- Rotation/Mirroring: Per-step orientation transformation controls for layout variety
- Replacement Operations: Block swapping based on filter criteria for dynamic map modification
- Anchor/Objective Management: Named anchor placement and objective instantiation for mission structure

### Flag and Branching System
- Flag Setting: Steps set named flags with boolean or contextual values for state tracking
- Conditional Branching: Flag-based execution paths and alternative step sequences for adaptive generation
- Context Preservation: Flags carry block IDs, coordinates, and metadata for dependent steps
- Success/Failure Tracking: Flag metadata for validation and repair decision-making processes

### Validation and Repair Framework
- Invariant Checking: Reachability, connectivity, and placement requirement validation for playable maps
- Repair Steps: Automatic correction actions (corridor expansion, block replacement) for failed validation
- Fallback Scripts: Simpler script variants when primary generation fails, ensuring map completion
- Graceful Degradation: Progressive simplification when constraints are unsatisfiable for robustness

## Examples

### Central Core Placement
- Filter Criteria: Group=core_room, min_size=3x3 for appropriate central structures
- Selection Mode: Best-fit, count=1 to select optimal core block
- Placement Pattern: Single at map center for focal positioning
- Flag Setting: HAS_CORE=true to enable dependent perimeter construction
- Validation: Core accessibility confirmed for mission progression

### Defensive Perimeter Construction
- Conditional Execution: Requires HAS_CORE flag for logical dependency
- Probability Gate: 90% chance of execution for optional defensive enhancement
- Placement Pattern: Outline around central core for protective positioning
- Block Source: Group=perimeter blocks for defensive terrain
- Instance Limit: Maximum 8 perimeter blocks to prevent overcrowding

### Debris Scatter Distribution
- Filter Criteria: Tags=debris for environmental hazard blocks
- Placement Pattern: Flood-fill from core position for natural distribution
- Instance Count: 6 debris placements for tactical variety without obstruction
- Seeded Distribution: Deterministic positioning based on mission seed for reproducibility
- Connectivity: Debris doesn't block critical paths while providing cover opportunities

### Mission Craft Integration
- Special Asset Type: XCOM craft for player deployment vehicle
- Position Assignment: Reserved hangar block location for safe landing
- Anchor Requirements: Craft hardpoints and access points for functionality
- Validation: Craft accessibility and deployment clearance confirmed
- Flag Integration: CRAFT_PLACED flag for dependent mission steps

### Terrain Fill Completion
- Placement Pattern: Fill remaining empty grid slots for complete map coverage
- Block Pool: Terrain_common with weighted selection for natural variety
- Instance Caps: Respect per-map maximum occurrences for balance
- Seam Compatibility: Maintain connection integrity across all placements
- Performance Bounds: Limited to reasonable completion time for responsive generation

### Repair and Fallback Sequence
- Validation Check: Objective reachable from any deployment zone for mission viability
- Failure Response: Replace blocking blocks from fallback pool for path restoration
- Connectivity Repair: Expand corridors and add connection blocks for accessibility
- Re-validation: Confirm repair success and map playability
- Final Fallback: Simpler map script variant if repair fails, ensuring functional maps

## Related Wiki Pages

Map scripts control the procedural generation and modification of battlefields:

- **Battle Map generator.md**: The main system that executes map scripts.
- **Map blocks.md**: Blocks that scripts place and modify.
- **Map Node for AI.md**: Nodes that scripts may create or modify.
- **Battle map.md**: The final map that scripts help construct.
- **Mission objectives.md**: Objectives that may influence script execution.
- **Terrain damage.md**: Damage effects that scripts may apply.
- **Battle Tile.md**: Individual tiles that scripts can modify.
- **Geoscape systems** like **Biome.md** that provide context for script selection.

## References to Existing Games and Mechanics

The Map Scripts system draws from procedural content generation in games:

- **X-COM series (1994-2016)**: Mission generation with varied layouts and objectives.
- **XCOM 2 (2016)**: Dynamic map scripting with destructible environments.
- **Civilization series (1991-2021)**: Map generation scripts for varied terrain.
- **Total War series (2000-2022)**: Battlefield generation with varied elements.
- **Fire Emblem series (1990-2023)**: Map design with varied terrain and objectives.
- **Advance Wars series (2001-2018)**: Map construction with varied elements.
- **Jagged Alliance series (1994-2014)**: Procedural mission generation.

