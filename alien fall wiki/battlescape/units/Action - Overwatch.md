# Overwatch Action System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Overwatch State Management](#overwatch-state-management)
  - [Trigger Detection and Conditions](#trigger-detection-and-conditions)
  - [Reaction Resolution Pipeline](#reaction-resolution-pipeline)
  - [Multiple Reaction Coordination](#multiple-reaction-coordination)
  - [Persistence and Cancellation](#persistence-and-cancellation)
  - [Advanced Overwatch Features](#advanced-overwatch-features)
- [Examples](#examples)
  - [Standard Door Ambush](#standard-door-ambush)
  - [Crossfire and Priority Ordering](#crossfire-and-priority-ordering)
  - [Sense-Triggered Reaction](#sense-triggered-reaction)
  - [Implicit Cancellation Scenario](#implicit-cancellation-scenario)
  - [Complex Tactical Scenarios](#complex-tactical-scenarios)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Overwatch Action System implements a deterministic defensive framework that reserves a unit's ability to resolve reactive shots during enemy turns. This data-driven system allows designers to tune entry costs, reserved Action Points, trigger conditions, and per-turn limits to create effective area denial and risk management mechanics. Reactions utilize the same line-of-fire and damage pipelines as active shots, with mission-seeded random number generation ensuring reproducible outcomes and multiplayer parity.

The system rewards tactical positioning by creating meaningful movement choices under threat, while deterministic resolution ordering and comprehensive provenance logging enable designers to reproduce and tune complex crossfire interactions. Overwatch transforms static defense into dynamic area control, forcing enemies to make difficult decisions about movement and positioning.

## Mechanics

### Overwatch State Management
Core system for entering and maintaining defensive readiness:
- Entry Cost: Configurable Action Point cost to enter overwatch state (default: 1 AP)
- Reserved AP: AP amount set aside for reaction resolution (default: 2 AP)
- State Duration: Overwatch persists until cancelled, expired, or unit becomes incapacitated
- Weapon Selection: Specific weapon designated for overwatch reactions
- Trigger Configuration: Sight-based, sense-based, or combined detection modes
- Facing Constraints: Optional directional limitations for reaction eligibility

### Trigger Detection and Conditions
Mechanisms for identifying enemy actions that initiate reactions:
- Movement Triggers: Enemy movement within line-of-fire activates overwatch
- Action-Based Triggers: Specific enemy actions can initiate reactions
- Line-of-Sight Requirements: Visual detection for standard overwatch engagement
- Sense-Based Triggers: Sound and motion detection with accuracy penalties
- Range Limitations: Maximum detection distance for overwatch coverage
- Angular Restrictions: Facing cones limiting reaction eligibility

### Reaction Resolution Pipeline
Deterministic process for calculating and resolving overwatch attacks:
- Hit Chance Calculation: Base aim × weapon accuracy × environmental modifiers
- Movement Penalties: Reduced accuracy against moving targets
- Stance Modifiers: Bonuses/penalties based on target defensive posture
- Range Falloff: Distance-based accuracy degradation using standard range bands
- Visibility Effects: Environmental factors affecting detection and accuracy
- Cover Integration: Defensive positioning modifiers from cover and crouch

### Multiple Reaction Coordination
Handling complex scenarios with multiple simultaneous reactions:
- Priority Ordering: Distance-based then threat-based reaction sequence
- Per-Turn Limits: Maximum reactions per overwatch unit per turn (default: 1)
- Resource Consumption: AP and ammunition costs for each resolved reaction
- Deterministic Resolution: Consistent ordering for reproducible outcomes
- Crossfire Management: Coordinating multiple reactions against single or multiple targets
- Resource Pooling: Shared reaction budgets across coordinated units

### Persistence and Cancellation
Controls for overwatch duration and termination:
- Turn-Based Duration: Overwatch expires after configurable number of turns
- Implicit Cancellation: Certain actions automatically clear overwatch state
- Explicit Cancellation: AP cost to manually exit overwatch readiness
- Status-Based Clearing: Incapacitation, suppression, or stun ends overwatch
- Movement Cancellation: Unit movement automatically clears overwatch state
- Action Interference: Specific actions that break overwatch concentration

### Advanced Overwatch Features
Extended capabilities for tactical depth:
- Sense Triggers: Non-visual detection with configurable accuracy penalties
- Area Denial: Strategic positioning to control movement corridors and chokepoints
- Crossfire Tactics: Coordinating multiple overwatch units for interlocking fields of fire
- Suppression Effects: Reactions that reduce enemy effectiveness and morale
- Provenance Analysis: Detailed tracking for balance tuning and debugging
- Mod Integration: Custom reaction types, trigger conditions, and special abilities

## Examples

### Standard Door Ambush
Squad positions troopers on overwatch covering a doorway entrance. When an alien unit moves through the doorway, the nearest overwatching units trigger reactions in deterministic priority order. Only allowed reactions consume reserved AP and resolve, subject to per-turn limits and resource availability.

### Crossfire and Priority Ordering
Multiple enemy units enter an overwatch-controlled lane simultaneously. Reactions resolve in deterministic order based on distance to overwatch units, then by unit identification. This creates predictable interlocking fields of fire and enables tactical baiting strategies.

### Sense-Triggered Reaction
Enemy unit creates noise while moving in darkness, triggering sound-based detection. Nearby overwatch units with sense mode enabled resolve reactions with reduced accuracy according to sense penalty rules, consuming reserved AP and ammunition.

### Implicit Cancellation Scenario
Unit enters overwatch then performs reload action, automatically clearing overwatch state according to configurable implicit cancellation rules. This prevents indefinite overwatch maintenance and creates resource management decisions.

### Complex Tactical Scenarios
- Urban Combat: Buildings and streets create natural overwatch positions with multiple engagement angles
- Forest Patrol: Limited visibility requires sense-based overwatch with environmental penalties
- Building Clearance: Room-to-room overwatch coverage patterns for systematic area control
- Convoy Escort: Vehicle-based overwatch providing mobile defensive coverage
- Defensive Perimeter: Coordinated overwatch arcs creating comprehensive area defense

## Related Wiki Pages

- [Unit actions.md](../battlescape/Unit%20actions.md) - Overwatch as an action type with AP costs and state management.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Detection ranges and visual requirements for triggers.
- [Line of Fire.md](../battlescape/Line%20of%20Fire.md) - Firing path validation for reactions and coverage.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Hit chance calculations with movement penalties for reactions.
- [Morale.md](../battlescape/Morale.md) - Morale states affecting or affected by overwatch reactions.
- [Panic.md](../battlescape/Panic.md) - Failed overwatch potentially triggering panic responses.
- [Concealment.md](../battlescape/Concealment.md) - Stealth mechanics interacting with overwatch detection.
- [Action - Movement.md](../battlescape/Action%20-%20Movement.md) - Enemy movement triggering overwatch and affecting accuracy.
- [Action - Suppressive fire.md](../battlescape/Action%20-%20Suppressive%20fire.md) - Suppression effects from overwatch reactions.
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Environmental conditions impacting detection.
- [Energy.md](../units/Energy.md) - AP system for overwatch entry and reactions.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI decision-making around overwatch threats.

## References to Existing Games and Mechanics

The Overwatch Action System draws from reactive defense in tactical and strategy games:

- **X-COM series (1994-2016)**: Units reacting to enemy movement with defensive shots.
- **XCOM 2 (2016)**: Advanced overwatch with multiple trigger types and area control.
- **MechWarrior series (1989-2024)**: Guard actions for reactive defense during enemy turns.
- **Warhammer 40k: Dawn of War (2004-2016)**: Overwatch in turn-based combat with reaction shots.
- **Tom Clancy's Rainbow Six Siege (2015)**: Drones and traps providing detection and reaction.
- **Battlefield series (2002-2021)**: Suppression through defensive positioning.
- **Gears of War series (2006-2019)**: Active reload and cover-based reaction mechanics.
- **Doom (2016)**: Glory kills and reactive combat elements.

