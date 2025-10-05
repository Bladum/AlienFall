# Squad Autopromotion

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Template Input Structure](#template-input-structure)
  - [Class Promotion Framework](#class-promotion-framework)
  - [XP Allocation Policies](#xp-allocation-policies)
  - [Promotion Execution Loop](#promotion-execution-loop)
  - [Inventory Assignment System](#inventory-assignment-system)
  - [Constraint Enforcement](#constraint-enforcement)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [Leader-Biased Squad Construction](#leader-biased-squad-construction)
  - [Progressive Spend Distribution](#progressive-spend-distribution)
  - [Constraint Enforcement Scenario](#constraint-enforcement-scenario)
  - [Insufficient XP Fallback](#insufficient-xp-fallback)
  - [Zero-Weight Class Handling](#zero-weight-class-handling)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Squad Autopromotion converts compact enemy templates and XP budgets into complete, mission-ready squads automatically. Designers specify faction, unit count, promotion trees, and inventory tables while the system allocates XP to promote units, assign roles, and sample equipment matching mission difficulty. Promotion and inventory sampling use seeded randomness for reproducible outcomes with comprehensive provenance logging enabling balance analysis and debugging. Allocation policies (even split, leader-bias, progressive spend) shape XP distribution to create natural leader emergence and specialist development.

## Mechanics

### Template Input Structure
- Core Parameters: Unit count (N), total XP budget, faction identifier, deployment constraints
- Optional Modifiers: Mission difficulty scaling, leader-to-soldier ratios, forced role requirements
- RNG Foundation: Deterministic seed ensuring identical results for identical inputs
- Constraint Framework: Minimum/maximum per-class limits, guaranteed specialist slots

### Class Promotion Framework
- Base Instantiation: N units created at rank 0 using faction's base class
- Successor Selection: Weighted random choice from eligible promotion paths
- Affordability Checks: XP cost validation before promotion application
- Zero-Weight Exclusion: Classes with zero autopromo_weight ineligible for selection
- Fallback Policies: Deterministic alternatives when desired promotions unaffordable

### XP Allocation Policies
- Even Split: Equal XP distribution across all units, independent promotion loops
- Leader-Bias: Reserved leader slots with larger XP share, remaining distributed to soldiers
- Progressive Spend: Global iteration biasing toward lower-rank units for natural emergence
- Weighted Unit Selection: Rank-based weight modifiers favoring higher-rank formation
- Hybrid Approaches: Combining forced reservations with progressive distribution

### Promotion Execution Loop
- Termination Conditions: XP exhaustion, no promotable successors, rank cap reached
- Beneficiary Selection: Policy-driven unit choice for each promotion cycle
- Successor Sampling: Weighted selection from current class promotion paths
- XP Deduction: Cost subtraction from remaining budget after successful promotion
- Provenance Tracking: Complete audit trail of each promotion step and decision

### Inventory Assignment System
- Post-Promotion Sampling: Equipment assigned after final class determination
- Weighted Slot Draws: Seeded random selection from class-specific item tables
- Compatibility Validation: Strength requirements, class restrictions, rank thresholds
- Fallback Handling: Next-weighted candidate selection on incompatibility
- Rank-Based Unlocks: Higher ranks enabling access to superior equipment tiers

### Constraint Enforcement
- Class Distribution Limits: Minimum and maximum counts per unit type
- Forced Role Assignment: Guaranteed specialist positions with reserved XP subpools
- Post-Processing Adjustments: Unit conversion to satisfy distribution requirements
- Fallback Conversions: Automatic class changes when limits exceeded
- Validation Checks: Final composition verification against all constraints

### Determinism and Provenance
- Seeded RNG Streams: Named streams for distinct decision domains (unit selection, class choice, inventory)
- Hash-Based Seeds: Stable derivations preserving replay parity and multiplayer lockstep
- Complete Logging: Seeds, per-step choices, remaining budget, and final composition
- Replay Capability: Exact squad reconstruction from recorded seed and provenance
- Telemetry Integration: Statistical data collection for balance analysis and tuning

## Examples

### Leader-Biased Squad Construction
- Template Input: 10 units, 4000 XP budget, 1:4 leader ratio, alien faction
- Leader Reservation: 2 slots reserved (ceil(10 × 1/5) = 2)
- XP Allocation: 1600 XP to leaders (40% share), 2400 XP to 8 soldiers (300 XP each)
- Promotion Results: Leaders achieve rank 2-3, soldiers reach rank 0-2
- Inventory Sampling: High-rank units access superior weapon tiers
- Final Composition: 2 specialized leaders + 8 moderately enhanced soldiers

### Progressive Spend Distribution
- Allocation Approach: Equal base allocation with dynamic global distribution
- Selection Bias: Lower-rank units prioritized for promotion opportunities
- Emergent Leadership: Natural rank disparities through iterative selection
- Flexible Composition: No predetermined role reservations
- Result Pattern: Gradual rank progression creating organic squad hierarchy

### Constraint Enforcement Scenario
- Template Constraints: Maximum 1 commander, minimum 1 basic unit, forced medic slot
- System Actions: Automatic class conversions to satisfy limits
- Medic Guarantee: Reserved XP ensuring medic promotion affordability
- Commander Cap: Excess commanders converted to alternative classes
- Validation: Final squad composition meeting all specified requirements

### Insufficient XP Fallback
- Budget Shortage: Desired promotion exceeds remaining XP
- Fallback Options: Next-cheapest successor selection or inventory upgrade conversion
- Deterministic Choice: Seeded random selection from affordable alternatives
- Budget Preservation: Leftover XP logged for telemetry analysis
- Composition Adaptation: Squad generation continuing with available resources

### Zero-Weight Class Handling
- Configuration: Sectoid class with autopromo_weight = 0
- Selection Exclusion: Class ineligible for promotion sampling
- Template Availability: Still usable as explicit base class placement
- Designer Control: Intentional prevention of automatic advancement
- Manual Override: Direct template specification bypassing weight restrictions

## Related Wiki Pages

- [Units.md](../units/Units.md) - Unit classes and promotion trees.
- [Experience.md](../battlescape/Experience.md) - XP allocation and promotion costs.
- [Morale.md](../battlescape/Morale.md) - Promotions can affect morale.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Promoted units have different actions.
- [Inventory.md](../items/Inventory.md) - Equipment assignment based on promotion.
- [AI Battlescape.md](../ai/Battlescape%20AI.md) - AI considers promoted units.
- [Stats.md](../units/Stats.md) - Stat changes from promotions.
- [Traits.md](../units/Traits.md) - Traits gained through promotion.
- [Classes.md](../units/Classes.md) - Unit classes and roles.
- [Factions.md](../units/Factions.md) - Faction-specific promotions.

## References to Existing Games and Mechanics

- X-COM series: Unit promotions and class advancements through experience.
- Fire Emblem series: Class promotion systems with XP and stat changes.
- Advance Wars: CO powers and unit upgrades.
- Civilization series: Unit promotions and experience.
- Warhammer 40k: Squad compositions with specialists.
- Dungeons & Dragons: Character level-ups and class changes.
- Final Fantasy Tactics: Job systems and promotion.
- Tactics Ogre: Class change mechanics.

