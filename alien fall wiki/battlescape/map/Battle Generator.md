# Battle Map Generation System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Input Gathering and Initialization](#input-gathering-and-initialization)
  - [Map Block Pool Resolution](#map-block-pool-resolution)
  - [Map Script Execution](#map-script-execution)
  - [Block to Tile Expansion](#block-to-tile-expansion)
  - [AI and Navigation Preprocessing](#ai-and-navigation-preprocessing)
  - [Spawn and Faction Placement](#spawn-and-faction-placement)
  - [Player Deployment Zones](#player-deployment-zones)
  - [Fog of War and Visibility](#fog-of-war-and-visibility)
  - [Pre-Battle Effects](#pre-battle-effects)
  - [Environmental Effects Integration](#environmental-effects-integration)
  - [Final Validation and Output](#final-validation-and-output)
- [Examples](#examples)
  - [Block Grid Sizing Configuration](#block-grid-sizing-configuration)
  - [Block Expansion and Integration](#block-expansion-and-integration)
  - [Tile Replacement Scenario](#tile-replacement-scenario)
  - [Spawn Fallback Sequence](#spawn-fallback-sequence)
  - [Pre-Battle Damage Application](#pre-battle-damage-application)
  - [Complex Map Scenarios](#complex-map-scenarios)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battle Map Generation System creates deterministic, modular tactical battlefields through a data-driven pipeline that assembles reusable Map Blocks into complete mission environments. Using mission seeds for reproducible outcomes, the system combines terrain rules, generation scripts, and modular components to produce validated maps with comprehensive provenance tracking. The modular approach enables extensive modding support while maintaining design control through high-level constraints and anchor-based systems.

The Battle Map Generator is a deterministic, data-driven pipeline that composes tactical maps from terrain rules, Map Scripts and a pool of reusable Map Blocks. Given a mission seed it assembles a block grid, expands prefabs into tiles, places spawns and AI nodes, runs reachability checks and emits a provenance-rich map object ready for simulation. Designers express high-level constraints and anchors in data while the generator enforces seam-safe stitching and reproducible previews for testing, modding and multiplayer parity.

The Map Generator loads the Map Script, executes its steps, and builds the terrain layout—a 2D array of Map Blocks. This creates the high-level map. Next, it generates the Battlefield: a 2D array of Battle Tiles. Each Map Block in the layout is processed, extracting its tile elements. Each element converts to a Battle Tile (containing tile element + unit + fog of war + smoke/fire + objects), forming the 2D battlefield array.

Maps serve as the foundational layer for all tactical systems, providing terrain data for movement, line-of-sight calculations, environmental effects, and AI decision-making. The deterministic generation ensures consistent experiences for testing, multiplayer parity, and balance analysis.

## Mechanics

### Input Gathering and Initialization
- Mission Context: Biome, mission type, mission flags (crashed/assault/timed)
- Terrain Definition: Tile set, allowed blocks and default scripts
- Map Script Selection: Chosen script and mission parameters (difficulty, modifiers)
- Generation Seed: Composed from worldSeed, missionSeed, scriptId, placementIndex

### Map Block Pool Resolution
- Block Filtering: Produce filtered list of blocks with metadata (tags, sizes, weights, limits)
- Terrain and Mission Filters: Apply biome and mission-specific restrictions
- Metadata Inclusion: Tags/groups, footprint sizes, weight/rarity, rotation flags, seam tags, anchors

### Map Script Execution
- Recipe-Based Processing: Run ordered script steps for block placement and configuration
- Step Capabilities: Place anchored blocks, linear features, spawn groups, conditional branching
- Grid Assembly: Create block grid, place multi-tile footprints with validation
- Fallback Handling: Retry failed placements with alternates or script-defined fallbacks
- Weighted Filling: Fill remaining slots with random blocks honoring limits and exclusions

### Block to Tile Expansion
- Prefab Expansion: Convert block prefabs to tile grid (N×15 tiles per block)
- Tile Copying: Transfer tile types with correct orientation
- Provenance Annotation: Record block_id, local coordinates, anchor references per tile
- Post-Processing: Apply scripted replacements, props, anchors, and decorative changes

### AI and Navigation Preprocessing
- Node Generation: Create navigation nodes from anchors and walkable areas
- Connectivity Graph: Build deterministic path distances and LOS adjacency
- Precomputation: Coarse path distances and accessibility for AI planning
- Runtime Refinement: Allow fine-grained recalculation during simulation

### Spawn and Faction Placement
- Enemy Placement: Use block/anchor markers and mission deployment rules
- Ally/Civilian Spawns: Script instructions or seeded random selection
- Validation: Check walkability and occupancy with fallback rules
- Deterministic Assignment: Seeded placement for reproducible outcomes

### Player Deployment Zones
- Zone Identification: Tagged/scripted blocks or edges for deployment
- Multiple Options: Generate multiple distinct placements for mission preparation
- Validation: Ensure spacing and safe paths to objectives
- UI Integration: Support mission preparation deployment selection

### Fog of War and Visibility
- Initial Computation: Determine visibility from deployment positions and starting conditions
- Seeded Evaluation: Deterministic partial knowledge and exploration states
- Lighting Integration: Account for time-of-day and environmental lighting
- Sensor Effects: Include starting detection and surveillance capabilities

### Pre-Battle Effects
- Mission Flagging: Apply damage/effects for crashed, sabotaged, or special missions
- Anchored Effects: Place explosions, fires, hazards at scripted or seeded locations
- Secondary Processing: Handle smoke, blocked doors, and environmental changes
- AI Recalculation: Update navigation and connectivity for affected areas

### Environmental Effects Integration
Dynamic map modifications and hazard systems:
- Explosion Propagation: Damage spread across tiles using material absorption and blocking
- Effect Layer Management: Transient overlays for smoke, fire, and contamination
- Terrain Modification: Destructible elements that change map state during gameplay
- Fog of War Dynamics: Per-faction visibility tracking and exploration state
- Material Interactions: Realistic responses to damage and environmental conditions

### Final Validation and Output
- Reachability Checks: Ensure valid paths from deployment zones to objectives
- Fallback Regeneration: Limited substitutions or alternate script branches on failure
- Provenance Logging: Complete audit trail of generation process and decisions
- Map Object Creation: Emit complete battle map with tiles, AI graph, spawns, deployment zones

## Examples

### Block Grid Sizing Configuration
Scalable map construction based on mission requirements:
- Mission Scale: Medium mission requiring 5×5 block grid layout
- Block Dimensions: Standard 15×15 tile blocks for modular construction
- Final Map Size: 75×75 tile battlefield (5 × 15 = 75 in each dimension)
- Memory Considerations: Efficient storage of tile data
- Performance Optimization: Aggregated views for fast system queries

### Block Expansion and Integration
Detailed process of converting prefabs to global map:
- Block Placement: 30×30 hangar block positioned at grid coordinates (1,2) with 90° rotation
- Tile Transfer: Copies tile types to global coordinate system
- Provenance Recording: Tracks block ID and local coordinates for each transferred tile
- Anchor Resolution: Identifies connection points for adjacent block stitching
- Layer Merging: Combines overlapping elements with priority rules

### Tile Replacement Scenario
Dynamic map modification during gameplay:
- Trigger Condition: Wreck anchor in hangar block requires breach modification
- Replacement Execution: Standard wall tile changed to "breach" variant with damage effects
- Additional Effects: Scorch props spawned with deterministic placement coordinates
- Provenance Logging: Records modification source and timing for replay reconstruction
- System Updates: Refreshes aggregated views for pathfinding and line-of-sight calculations

### Spawn Fallback Sequence
Robust unit placement with multiple contingency options:
- Primary Attempt: Enemy anchor tile blocked by unexpected environmental prop
- Secondary Option: Nearest valid anchor tile within the same block boundary
- Tertiary Solution: Zonal spawn rule covering entire block area with random distribution
- Validation Checks: Ensures line-of-sight, movement accessibility, and tactical positioning
- Balance Preservation: Maintains mission difficulty and strategic options

### Pre-Battle Damage Application
Mission-specific environmental setup:
- Mission Context: Crashed aircraft scenario requiring destruction effects
- Explosion Pattern: 3-5 seeded explosions clustered around wreck anchor point
- Secondary Effects: Doors jammed, smoke clouds spawned, AI navigation paths recalculated
- Deterministic Placement: Seeded random distribution ensuring reproducible scenarios
- Mission Integration: Effects support specific objectives and tactical challenges

### Complex Map Scenarios
Diverse battlefield environments for varied gameplay:
- Urban Combat: City blocks with streets, buildings, alleyways, and verticality
- Forest Clearing: Woodland terrain with clearings, dense forest areas, and natural cover
- Industrial Complex: Factories and warehouses with machinery, obstacles, and hazards
- Rural Farmstead: Open fields with barns, fences, natural cover, and agricultural features
- Coastal Landing: Beach areas with shipwrecks, defensive positions, and amphibious challenges

## Related Wiki Pages

- [Battle Tile.md](../battlescape/Battle%20tile.md) - Tiles making up the map grid and terrain.
- [Map blocks.md](../battlescape/Map%20blocks.md) - Modular components for map sections.
- [Map scripts.md](../battlescape/Map%20scripts.md) - Scripting for dynamic map behavior.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height systems affecting layout.
- [Battle size.md](../battlescape/Battle%20size.md) - Map dimensions based on parameters.
- [Biome.md](../geoscape/Biome.md) - Influences map themes.
- [Terrain.md](../geoscape/Terrain.md) - Terrain rules.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI navigating the map.
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Visibility on the map.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Visibility calculations.
- [Enemy deployments.md](../battlescape/Enemy%20deployments.md) - Spawn locations and faction placement.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Objectives influencing parameters.

## References to Existing Games and Mechanics

The Battle Map system draws from tactical map design in games:

- **X-COM series (1994-2016)**: Grid-based battlefields with varied terrain.
- **XCOM 2 (2016)**: Dynamic maps with verticality and destructible cover.
- **Jagged Alliance series (1994-2014)**: Detailed tactical maps with interiors.
- **Fire Emblem series (1990-2023)**: Grid-based maps with elevation.
- **Advance Wars series (2001-2018)**: Tactical maps with terrain effects.
- **Total War series (2000-2022)**: Large-scale battle maps.
- **Civilization series (1991-2021)**: Strategic map systems.
- **BattleTech (1984-2024)**: Hex-based tactical maps.
- **Into the Breach (2018)**: Procedural tactical maps.
- **Dwarf Fortress (2006)**: Complex procedural world generation.

