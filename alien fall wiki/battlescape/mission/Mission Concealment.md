# Concealment

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Stealth Budget and Accumulation Model](#stealth-budget-and-accumulation-model)
  - [Cost Categories and Equipment Integration](#cost-categories-and-equipment-integration)
  - [Detection and Alert System](#detection-and-alert-system)
  - [Movement Mode Integration](#movement-mode-integration)
  - [Equipment and Consumable Systems](#equipment-and-consumable-systems)
  - [Mission Integration and Consequences](#mission-integration-and-consequences)
  - [Stateful and Temporal Models](#stateful-and-temporal-models)
  - [Interactions with Moral Systems](#interactions-with-moral-systems)
- [Examples](#examples)
  - [Urban VIP Extraction Mission](#urban-vip-extraction-mission)
  - [Ambush with Heavy Weapons](#ambush-with-heavy-weapons)
  - [Temporal Heat Management](#temporal-heat-management)
  - [Diversion Tactics](#diversion-tactics)
  - [Equipment Toggle Management](#equipment-toggle-management)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Concealment system treats stealth as a deterministic, tuneable mission resource where actions, equipment, and movement accumulate signature points toward configurable thresholds. Missions declare stealth budgets with graduated consequences from soft alerts to mission failure, supporting temporal stealth windows and deterministic responses. All accumulation, detection checks, and revealed consequences are seeded and provenance-logged for reproducible testing, balancing, and multiplayer synchronization. The system integrates with movement modes, equipment toggles, and detection radii while maintaining independence from moral metrics.

Design goals include treating stealth as a tuneable resource for different mission types, keeping moral metrics (Karma, Fame, Score) independent from detection mechanics, and making all aspects data-driven and deterministic with seeded stochastic checks.

## Mechanics

### Stealth Budget and Accumulation Model
- Mission Stealth Budget: Each stealth mission declares an integer stealth_budget; accumulated signature points trigger escalation or failure when exceeding this threshold
- Signature Accumulation: Items, vehicles, weapons, and actions contribute stealth costs (passive on-carry, active when used, per-turn for powered equipment)
- Temporal Heat Model: Optional signature heat that increases with actions and decays over time, allowing brief noisy surges followed by cooldown periods
- Detection Meters: Local detection values per enemy/pod that trigger alerts when exceeding thresholds, consuming stealth budget without full map reveal
- UI Display: Concealment bar showing remaining stealth points with tooltips previewing predicted costs

### Cost Categories and Equipment Integration
- Passive Costs: Ongoing signature while equipped/carried (heavy weapons, visible armor, large vehicles)
- Active Costs: Applied when using items (firing weapons, landing craft, activating modules)
- Movement Costs: Per-tile detection contribution based on movement mode (stealth, normal, sprint)
- Equipment Modifiers: Stealth bonuses (negative values) from specialized gear, ECM modules, and concealment items
- Item Distinction: Separate passive carry penalties from active use penalties (carrying heavy launcher has small passive cost, firing has large active cost)

### Detection and Alert System
- Local Detection Meters: Actions increase per-enemy detection values; threshold breaches trigger alerts and alert propagation
- Graduated Consequences: Soft thresholds cause investigations/patrols; hard thresholds trigger mission failure or escalation
- Alert Propagation: Revealed units may alert nearby allies based on configurable propagation rules
- Temporal Windows: Decay and suppression mechanics allow brief exposure followed by cooldown periods

### Movement Mode Integration
- Stealth Movement: Higher AP cost with reduced detection contribution per tile
- Normal Movement: Standard AP/visibility behavior
- Sprint/Charge: Large detection cost per tile with increased local detection trigger chance
- Movement Modifiers: Configurable AP multipliers and detection cost per tile for each mode

### Equipment and Consumable Systems
- Toggleable Equipment: ECM modules, stealth suits with per-turn costs and detection reductions
- Consumable Tools: Smoke, distraction devices, ECM pulses that temporarily reduce local detection
- Deployable Objects: Camouflage nets, decoys with placement costs and local detection modifiers
- Equipment Examples: Stealth armor (-30 points while worn, -2 AP penalty), thermal masking (-20 points, 60% thermal detection reduction)

### Mission Integration and Consequences
- Mission Outcomes: Stealth budget exhaustion triggers configurable results (failure, extraction, escalation)
- Moral Independence: Karma, Fame, and Score systems remain separate from detection mechanics
- Delayed Revelations: Some detection events may trigger delayed public consequences affecting monthly reports
- Rewards: Completing stealth objectives without detection can grant bonus Fame or special rewards

### Stateful and Temporal Models
- Signature Heat: Optional model where signature increases with actions and decays over time, allowing brief surges followed by cooldown
- Temporal Budgets: Missions can impose maximum signature allowed within time windows to enable short noisy actions
- Decay Rates: Configurable signature decay per turn for heat management

### Interactions with Moral Systems
- Karma: Applied immediately based on action morality, independent of detection (executing captive applies penalty even if unseen)
- Fame: Increases with significant actions; further increases if actions are revealed through detection or media
- Score: Changes when civilian/economic impact is noticed by external actors; stealth breaches may trigger delayed revelations

## Examples

### Urban VIP Extraction Mission
- Stealth Budget: 200 points
- Transport Landing: 300 points (exceeds budget, cannot land undetected)
- Silenced Pistol: Passive -5 points, Fire +20 points
- ECM Device: Active -10 points per turn, reduces local detection by 40%
- Tactical Choice: Ground insertion with silenced weapons and ECM support

### Ambush with Heavy Weapons
- Heavy Launcher: Passive +50 points while carried
- Launcher Fire: +200 points when fired
- Mission Planning: Holster launcher during approach, accept escalation after firing
- Extraction Strategy: Plan low-signature exfiltration or accept combat escalation

### Temporal Heat Management
- Demolition Action: +150 signature points for door breach
- Cooldown Period: ECM activation allows signature decay below threshold within 3 turns
- Heat Model: Max signature 500 points, decay rate 50 points per turn
- Tactical Window: Brief noisy action followed by covered cooldown period

### Diversion Tactics
- Crowd Distractor: +25 points to deploy at remote location
- Effect: Draws patrols away, reducing local detection near objective
- Heavy Action: Later demolition becomes less likely to trigger alerts
- Resource Trade-off: Small signature cost enables larger subsequent actions

### Equipment Toggle Management
- Stealth Armor: -30 points while worn, -2 AP penalty
- Thermal Masking: -20 points, reduces thermal detection by 60%
- Combined Effect: -50 total stealth bonus with -2 AP movement penalty
- Activation Cost: No per-turn cost, passive while equipped

## Related Wiki Pages

Concealment mechanics are central to stealth gameplay and interact with many systems:

- **Action - Sneaking.md**: Primary stealth action that uses concealment mechanics.
- **Lighting & Fog of War.md**: Environmental lighting that affects concealment effectiveness.
- **Line of sight.md**: Visibility calculations that concealment modifies.
- **Action - Overwatch.md**: Concealment affects overwatch detection and trigger chances.
- **Morale.md**: Concealment can influence unit morale and bravery.
- **Panic.md**: Failed concealment may trigger panic responses.
- **Battle Day & Night.md**: Time of day affects base concealment levels.
- **Smoke & Fire.md**: Environmental obscurants that enhance concealment.

## References to Existing Games and Mechanics

The Concealment system draws from stealth and detection mechanics in tactical games:

- **X-COM series (1994-2016)**: Detection meters and alert levels for stealth gameplay.
- **XCOM 2 (2016)**: Advanced concealment with pod detection and alert phases.
- **Metal Gear Solid series (1998-2015)**: Alert phases and detection meters.
- **Thief series (1998-2014)**: Light/shadow based stealth with detection systems.
- **Deus Ex series (2000-2017)**: Security systems and detection mechanics.
- **Hitman series (2000-2023)**: Notoriety and detection systems.
- **Commandos series (1998-2006)**: Stealth mechanics with detection cones and alerts.

