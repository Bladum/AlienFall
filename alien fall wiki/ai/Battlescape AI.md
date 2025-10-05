# Battlescape AI

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Utility-Based Decision Framework](#utility-based-decision-framework)
  - [AI Personality System](#ai-personality-system)
  - [Tactical Awareness and Threat Assessment](#tactical-awareness-and-threat-assessment)
  - [Combat Action Selection](#combat-action-selection)
  - [Group Coordination and Tactics](#group-coordination-and-tactics)
  - [Deterministic Processing and Moddability](#deterministic-processing-and-moddability)
- [Examples](#examples)
  - [Utility Scoring in Action](#utility-scoring-in-action)
  - [Personality-Driven Behavior](#personality-driven-behavior)
  - [Group Coordination Scenarios](#group-coordination-scenarios)
  - [Threat Assessment and Adaptation](#threat-assessment-and-adaptation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battlescape AI system implements a sophisticated tactical artificial intelligence framework that governs unit behavior during ground combat missions. This deterministic, utility-based decision system creates intelligent and adaptive opponents that respond dynamically to player actions while maintaining consistent, testable behavior through seeded randomization. The AI prioritizes tactical credibility, emergent group coordination, and moddable personality systems to ensure challenging yet fair combat encounters.

The system distinguishes itself through its commitment to explainable decision-making, where every action selection follows transparent scoring heuristics rather than opaque machine learning algorithms. This approach enables designers to tune behavior directly, modders to create custom AI personalities, and players to learn and counter AI tactics predictably. The result is tactical combat that feels varied and intelligent while remaining reproducible for testing and balancing.

## Mechanics

### Utility-Based Decision Framework
The core decision-making process evaluates all feasible actions through a weighted scoring system that considers multiple tactical factors:
- Survival Assessment: Evaluates personal risk, health status, and exposure to enemy fire
- Lethality Potential: Calculates expected damage output and target vulnerability
- Tactical Positioning: Assesses cover quality, flanking opportunities, and terrain advantages
- Strategic Objectives: Considers mission goals, area control, and long-term positioning
- Group Coordination: Accounts for team support, formation maintenance, and combined actions

Each action receives a composite utility score, with the highest-scoring option selected for execution. Ties resolve through deterministic seeded randomization to prevent predictable repetition.

### AI Personality System
Configurable personality profiles create behavioral variation across different unit types and difficulty levels:
- Aggressive Personalities: High offensive weighting, accepting greater personal risk for damage potential
- Cautious Personalities: Prioritize self-preservation and defensive positioning over aggressive actions
- Balanced Personalities: Moderate risk tolerance with flexible adaptation to combat situations
- Specialized Personalities: Unit-specific traits like sniper patience, heavy weapon suppression focus, or berserker recklessness

Personalities modify scoring weights and thresholds, enabling diverse tactical behaviors without complex programming.

### Tactical Awareness and Threat Assessment
The AI maintains real-time battlefield awareness to inform decision-making:
- Enemy Tracking: Identifies visible threats with distance, weapon capabilities, and positioning analysis
- Opportunity Recognition: Detects flanking routes, overwatch positions, and enemy vulnerabilities
- Cover Evaluation: Assesses protection quality and movement paths to defensive positions
- Group Dynamics: Monitors team positioning, casualty status, and coordination opportunities

### Combat Action Selection
The system generates and evaluates tactical actions based on unit capabilities and situation:
- Movement Decisions: Pathfinding to optimal positions considering cover, flanking, and group formation
- Attack Targeting: Prioritizes high-threat or vulnerable enemies based on weapon effectiveness
- Ability Usage: Considers cooldowns, resource costs, and tactical advantages of special actions
- Defensive Actions: Evaluates overwatch positioning, suppression fire, and retreat options

### Group Coordination and Tactics
Multi-unit coordination creates emergent tactical behaviors:
- Formation Maintenance: Units maintain optimal spacing and mutual support relationships
- Focus Fire: Coordinated attacks on priority targets for efficient threat elimination
- Area Control: Group positioning to dominate key terrain and contain enemy movement
- Supporting Actions: Designated units provide covering fire for maneuvering elements

### Deterministic Processing and Moddability
All AI decisions incorporate seeded randomness for reproducible outcomes:
- Seeded Randomization: Ensures identical behavior across play sessions for testing reliability
- Telemetry Logging: Records decision factors and outcomes for balancing and debugging
- Data-Driven Configuration: Personality weights and scoring formulas exposed as moddable data
- Performance Optimization: Efficient algorithms limit computational overhead in real-time combat

## Examples

### Utility Scoring in Action
A Muton berserker unit evaluates three action candidates: charge an exposed soldier (high damage potential but risky), take cover behind nearby wreckage (safe but low impact), or use intimidating roar on clustered enemies (area control effect). The aggressive personality weights offensive actions highly, resulting in the charge being selected despite 40% casualty risk, as the expected damage output and positioning advantage outweigh survival concerns.

### Personality-Driven Behavior
A cautious Chryssalid personality prioritizes ambush positioning, waiting in cover for isolated targets rather than engaging groups. When wounded, it retreats to safe terrain while maintaining threat to nearby units. In contrast, an aggressive personality would pursue wounded targets aggressively, accepting counter-fire risks for guaranteed kills.

### Group Coordination Scenarios
Four Sectoid units coordinate a pincer movement: two units provide suppressive fire from elevated positions while the others flank the player's defensive line. The AI evaluates combined utility, ensuring the suppressing units maintain line-of-sight to their targets while the flanking elements reach optimal firing positions without exposing themselves unnecessarily.

### Threat Assessment and Adaptation
Upon detecting a sniper unit in overwatch position, AI units collectively shift to covered movement, prioritizing terrain that breaks line-of-sight. The system recalculates utilities in real-time, with previously high-scoring direct assaults now receiving negative modifiers due to increased vulnerability.

## Related Wiki Pages

- [Battlescape.md](../battlescape/Battlescape.md) - Main tactical combat system and AI integration.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Action selection and execution mechanics.
- [Morale.md](../battlescape/Morale.md) - AI behavioral modifiers and panic systems.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - AI goal prioritization and mission completion.
- [Panic.md](../battlescape/Panic.md) - AI breakdown and routing behavior.
- [Technical Architecture.md](../architecture.md) - AI system implementation and data structures.
- [Units.md](../units/Units.md) - Unit capabilities and AI personality assignments.
- [Psionics.md](../battlescape/Psionics.md) - AI psionic ability usage.
- [Squad Autopromotion.md](../battlescape/Squad%20Autopromotion.md) - AI leadership and command systems.

## References to Existing Games and Mechanics

- **XCOM Series**: AI tactical behavior and unit decision-making systems
- **Civilization**: AI strategic decision-making and personality systems
- **StarCraft**: AI unit control and micro-management tactics
- **Command & Conquer**: AI base management and tactical unit deployment
- **Total War**: AI battlefield tactics and army coordination
- **MechWarrior**: AI piloting and mech combat behavior
- **Freespace**: AI ship control and formation flying
- **Wing Commander**: AI dogfighting and tactical aerial combat
- **Homeworld**: AI fleet coordination and ship behavior
- **Master of Orion**: AI strategic decision-making and resource allocation

