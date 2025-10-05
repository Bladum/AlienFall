# Line of Fire

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Spatial and Coordinate System](#spatial-and-coordinate-system)
  - [Ray Traversal Algorithm](#ray-traversal-algorithm)
  - [Transmission and Blocking Models](#transmission-and-blocking-models)
  - [Planner Pipeline (Simulation)](#planner-pipeline-simulation)
  - [Miss Dispersion System](#miss-dispersion-system)
  - [Executor Pipeline (Firing)](#executor-pipeline-firing)
  - [Penetration and Special Cases](#penetration-and-special-cases)
  - [Determinism and Seeding](#determinism-and-seeding)
- [Examples](#examples)
  - [Corner Peek Mechanics](#corner-peek-mechanics)
  - [Window/Fence Interaction](#window/fence-interaction)
  - [Miss Dispersion at Range](#miss-dispersion-at-range)
  - [Penetration Through Cover](#penetration-through-cover)
  - [Large Map Preview Optimization](#large-map-preview-optimization)
  - [End-to-End Deterministic Example](#end-to-end-deterministic-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Line of Fire is a deterministic ray-tracing framework that converts continuous firing rays into ordered tile traversals with fractional blocking contributions. The system uses Amanatides algorithm with supercover rules to ensure stable inclusion of grazed tiles and provides predictable penetration, partial cover, and miss dispersion mechanics. All calculations use mission-seeded RNG streams for planner simulation, miss sampling, and per-tile obstruction rolls, ensuring reproducible outcomes for replays and multiplayer synchronization. Comprehensive provenance logging enables balance tuning, UI transparency, and QA validation.

## Mechanics

### Spatial and Coordinate System
- Tile Grid: 32-pixel square tiles using integer coordinates for high-level logic and performance optimization
- Continuous Geometry: Pixel coordinates for precise ray calculations, impact points, and geometric accuracy
- Performance Optimization: Primary operations in tile space with selective floating-point geometry for large maps
- Large Map Support: Efficient algorithms supporting 60x60+ tile battlefields with optimized traversal

### Ray Traversal Algorithm
- Amanatides & Woo: Fast voxel traversal providing ordered tiles with entry/exit parameters for precise calculations
- Supercover Rules: Deterministic inclusion of boundary-touching tiles with stable ordering to handle corner peeks
- Fraction Calculation: Per-tile ray fraction based on entry/exit parameters quantifying exposure through each tile
- Ordered Enumeration: Tiles processed in ray direction with precise intersection data for consistent evaluation

### Transmission and Blocking Models
- Exponential Model: Transmission_i = (1 - b_i)^fraction_i for natural continuous composition of multiple obstructions
- Linear Alternative: Effective blocking = base_block × fraction for simpler calculations when exponential complexity isn't needed
- Cumulative Transmission: Product of per-tile transmissions for total ray attenuation through the environment
- Material Integration: Base blocking values derived from tile material properties and environmental factors

### Planner Pipeline (Simulation)
- Target Conversion: Intended target tile converted to aim point coordinates for precise ray calculation
- Traversal Computation: Ordered tile list with fractions excluding shooter position to avoid self-obstruction
- Transmission Calculation: Cumulative attenuation using chosen blocking model for environmental impact
- Hit Chance Formula: Base accuracy × weapon modifiers × range × visibility × transmission × other factors
- Seeded Simulation: Mission-seeded RNG determines hit/miss outcomes with dispersion sampling for misses

### Miss Dispersion System
- Distance Scaling: Miss radius increases with target distance using clamped distance factor (0-1)
- Dispersion Radius: R_tiles = ceil(distance_factor × weapon_dispersion_scale) for controlled spread
- Deterministic Sampling: Seeded uniform sampling within circular/diamond radius around intended target
- Impact Candidate: Sampled tile center becomes execution target point for consistent miss behavior

### Executor Pipeline (Firing)
- Continuous Traversal: Pixel coordinates for precise impact determination and geometric accuracy
- Per-Tile Resolution: Sequential evaluation with blocking probability calculations for each traversed tile
- Impact Determination: Seeded rolls for each tile's obstruction probability determining projectile stopping
- Penetration Handling: Modified blocking values for armor-piercing projectiles allowing continued traversal
- Destructible Objects: State updates and continuation rules for penetrable barriers and environmental objects

### Penetration and Special Cases
- Projectile Penetration: Reduces effective blocking values for armor-piercing rounds through material absorption
- Structure Absorption: Separate absorption values for building penetration with realistic material differences
- Corner/Edge Grazing: Deterministic inclusion of boundary-touching tiles with proportional blocking effects
- Area Weapons: Explosion centers determined by traversal with radial propagation for explosive effects
- Performance Optimizations: Early exits at weapon range limits and transmission thresholds

### Determinism and Seeding
- Named RNG Streams: Separate seeds for simulation, misses, per-tile rolls, and damage ensuring isolated randomness
- Mission Seeding: Hash-based seed generation from mission seed, attacker ID, and action indices
- Reproducibility: Identical inputs produce identical outcomes across platforms and play sessions
- Multiplayer Synchronization: Deterministic results enabling fair network play and replay validation

## Examples

### Corner Peek Mechanics
- Grazing Shot: Ray touches grid boundary including both adjacent tiles through supercover rules
- Fraction Contribution: Small grazing tile contributes 0.1 fraction vs 0.8 for direct pass-through
- Blocking Effect: Grazing tile reduces transmission by 10% vs 60% for direct obstruction
- UI Display: Both tiles shown as contributors with proportional blocking percentages for transparency

### Window/Fence Interaction
- Window Properties: Base block chance 0.4, ray fraction 0.25 through window pane
- Transmission Impact: Window contributes (1-0.4)^0.25 ≈ 0.85 transmission multiplier
- Execution Roll: Seeded probability determines if window is struck and potentially destroyed
- Penetration Logic: Destroyed window allows continuation if weapon permits penetration through barriers

### Miss Dispersion at Range
- Long Range Shot: Distance factor = 0.9, weapon dispersion scale = 3
- Miss Radius: R_tiles = ceil(0.9 × 3) = 3 tiles from target center
- Seeded Sampling: Uniform selection within 3-tile radius around intended target
- Impact Resolution: Execution traverses to sampled tile with full blocking evaluation

### Penetration Through Cover
- Projectile Type: High-penetration round with 0.6 penetration factor
- Thin Obstacle: Base block 0.8 reduced to max(0, 0.8-0.6) = 0.2 effective blocking
- Multiple Barriers: Sequential penetration through multiple thin obstacles with accumulating effects
- Structure Limits: Building walls with separate absorption values preventing unrealistic penetration

### Large Map Preview Optimization
- UI Preview: First 30 tiles computed for approximate hit chance display without performance impact
- Lazy Evaluation: Full traversal computed only on shot confirmation for accurate results
- Performance Threshold: Transmission below 0.01 triggers early exit with near-zero chance
- Contributor Display: Top blocking tiles shown with fractions and material properties for decision making

### End-to-End Deterministic Example
- Identical Inputs: Same mission seed, attacker ID, action index, shot index, and map state
- Reproducible Results: Planner hit chance, miss sampling, per-tile rolls, and damage identical across runs
- Multiplayer Parity: Outcomes match perfectly for replay validation and network synchronization
- Debugging Support: Full provenance enables balance analysis and issue reproduction

## Related Wiki Pages

Line of fire calculations are fundamental to targeting and combat resolution:

- **Line of sight.md**: Related visibility calculations that often overlap with line of fire.
- **Accuracy at Range.md**: Hit chance calculations that depend on valid lines of fire.
- **Action - Overwatch.md**: Overwatch reactions that require valid lines of fire.
- **Action - Cover & Crouch.md**: Cover mechanics that affect line of fire blocking.
- **Terrain Elevation.md**: Height differences that influence line of fire paths.
- **Battle tile.md**: Individual tiles that can block or allow lines of fire.
- **Smoke & Fire.md**: Environmental effects that can obscure lines of fire.
- **Unit actions.md**: Actions like firing that require line of fire validation.

## References to Existing Games and Mechanics

The Line of Fire system draws from targeting and geometry mechanics in tactical games:

- **X-COM series (1994-2016)**: Line of sight and firing arc calculations for combat.
- **XCOM 2 (2016)**: Advanced line of sight with height and cover considerations.
- **Jagged Alliance series (1994-2014)**: Detailed line of sight and firing mechanics.
- **Fire Emblem series (1990-2023)**: Grid-based line of sight and targeting.
- **Advance Wars series (2001-2018)**: Line of sight and terrain affecting attacks.
- **Civilization series (1991-2021)**: Line of sight for ranged attacks.
- **Total War series (2000-2022)**: 3D line of sight calculations in battles.

