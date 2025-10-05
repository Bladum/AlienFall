# Battle Side System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Side Model and Unit Association](#side-model-and-unit-association)
  - [Hostility and Relationship Framework](#hostility-and-relationship-framework)
  - [AI Behavior and Decision Systems](#ai-behavior-and-decision-systems)
  - [Objectives and Mission Integration](#objectives-and-mission-integration)
  - [Modding and Configuration Support](#modding-and-configuration-support)
- [Examples](#examples)
  - [Standard Assault Mission](#standard-assault-mission)
  - [Civilian Protection Scenario](#civilian-protection-scenario)
  - [Coalition Warfare Scenario](#coalition-warfare-scenario)
  - [Neutral Behavior Modification](#neutral-behavior-modification)
  - [Deterministic Target Selection](#deterministic-target-selection)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Battle Side System implements first-class simulation objects that encapsulate participants, objectives, and deterministic hostility relationships in tactical engagements. Four core sides (Player, Enemy, Ally, Neutral) provide the foundation for all targeting, AI behavior, and mission resolution mechanics. Data-driven hostility matrices, AI priority tables, and seeded random tie-breakers ensure reproducible decisions for replay consistency, testing, and multiplayer parity.

The system enables complex mission dynamics through configurable relationships and objectives, supporting everything from simple assault missions to intricate coalition warfare scenarios. Comprehensive provenance tracking allows designers to analyze AI decision-making and balance side interactions effectively.

## Mechanics

### Side Model and Unit Association
Core framework for faction organization:
- Four Canonical Sides: Player, Enemy, Ally, and Neutral sides exist as persistent simulation objects
- Unit Membership: Every unit belongs to exactly one side, determining targeting and behavioral rules
- Empty Side Support: Sides may contain no units but retain objectives and relationship definitions
- Side Persistence: Side objects maintain state throughout mission duration regardless of unit losses

### Hostility and Relationship Framework
Deterministic friend/foe determination system:
- Hostility Matrix: Data-driven relationship definitions between all side combinations
- Friend/Foe Resolution: Deterministic lookups for targeting and interaction permissions
- Dynamic Overrides: Mission-specific modifications to default hostility settings
- Relationship Asymmetry: Different sides can have asymmetric hostility relationships

### AI Behavior and Decision Systems
Side-specific artificial intelligence profiles:
- Behavioral Profiles: Distinct AI characteristics and priority systems for each side
- Priority-Based Evaluation: Weighted decision-making systems for target selection and actions
- Deterministic Resolution: Seeded random number generation for consistent AI behavior
- Side-Specific Goals: Independent objective pursuit and tactical decision-making

### Objectives and Mission Integration
Independent goal systems for each faction:
- Side Objectives: Separate objective sets and completion conditions for each side
- Mission Resolution: Objective states contribute to overall mission end conditions
- Default Templates: Standardized objective configurations for Ally and Neutral sides
- Objective Progression: Independent tracking of goal completion and failure states

### Modding and Configuration Support
Extensible system for custom content creation:
- Data-Driven Design: All side definitions, matrices, and behaviors configured through TOML files
- Modding Hooks: Comprehensive interfaces for custom sides and behavioral modifications
- Provenance Tracking: Complete logging of side decisions and objective progression
- Configuration Validation: Automated checking of side relationships and objective consistency

## Examples

### Standard Assault Mission
Classic tactical engagement with clear faction roles:
- Enemy Objective: Assault and capture base facility through elimination of defenders
- Enemy Behavior: Aggressive attacks against Player and Ally sides with mission-focused tactics
- Ally Behavior: Defensive coordination with Player units, protection of Neutral civilians
- Neutral Behavior: Survival-focused actions including fleeing combat zones and seeking cover
- Mission Resolution: Enemy victory through facility capture, Player victory through enemy elimination

### Civilian Protection Scenario
Complex mission with multiple stakeholder interests:
- Neutral Units: Civilian NPCs spawn throughout mission area with independent objectives
- Ally Priority: AI configured to intercept Enemy threats to civilians before engaging other targets
- Mission Success: Civilian survival contributes to victory conditions and salvage rewards
- Tactical Complexity: Player must balance combat objectives with civilian protection requirements
- Failure Consequences: Civilian casualties affect mission outcome and reputation

### Coalition Warfare Scenario
Multi-faction cooperation and coordination:
- Multiple Allies: Local militia units and allied faction reinforcements
- Coordinated Objectives: Shared defense priorities and synchronized attack patterns
- Complex Relationships: Different hostility levels between various faction combinations
- Communication Challenges: Coordination requirements between Player and allied AI units
- Strategic Depth: Alliance management affects mission difficulty and available support

### Neutral Behavior Modification
Configuration changes affecting non-combatant behavior:
- Mod Configuration: TOML modifications increase Neutral flee thresholds and reduce engagement willingness
- Behavioral Impact: Civilians become more skittish and evacuate combat areas earlier
- Tactical Effect: Reduced civilian interference in combat zones and clearer engagement areas
- Balance Implications: Easier combat flow balanced against reduced environmental complexity
- Player Adaptation: Different tactical approaches required for modified neutral behavior

### Deterministic Target Selection
Reproducible AI decision-making process:
- Equal Priority Targets: Multiple enemy units with identical priority scores for engagement
- Tie-Breaker System: Seeded random selection ensures consistent choice across different playthroughs
- Provenance Documentation: Complete logging of selection criteria, candidate evaluation, and random seed usage
- Replay Consistency: Identical mission seeds produce identical AI targeting decisions
- Balance Analysis: Detailed decision logs enable AI behavior tuning and performance evaluation

## Related Wiki Pages

- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI using side relationships for decisions.
- [Geoscape AI.md](../ai/Geoscape%20AI.md) - Strategic AI considering side relationships.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Objectives depending on side relationships.
- [Enemy deployments.md](../battlescape/Enemy%20deployments.md) - Side positioning on the map.
- [Morale.md](../battlescape/Morale.md) - Morale differing between sides.
- [Panic.md](../battlescape/Panic.md) - Panic affecting different sides.
- [Units.md](../units/Units.md) - Units belonging to sides.
- [Lore.md](../lore/Lore.md) - Faction backgrounds.
- [Battle map.md](../battlescape/Battle%20map.md) - Map affecting side deployments.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Actions varying by side.

## References to Existing Games and Mechanics

The Battle Side system draws from faction mechanics in games:

- **X-COM series (1994-2016)**: Human vs alien distinctions.
- **XCOM 2 (2016)**: Multiple factions with alliances.
- **Civilization series (1991-2021)**: Diplomatic relationships.
- **Total War series (2000-2022)**: Faction alliances and rivalries.
- **Fire Emblem series (1990-2023)**: Allies, enemies, neutrals.
- **Advance Wars series (2001-2018)**: Faction loyalties.
- **Jagged Alliance series (1994-2014)**: Mercenary allegiances.
- **Warcraft series (1994-2023)**: Horde vs Alliance factions.

