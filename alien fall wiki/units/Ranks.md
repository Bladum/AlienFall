# Ranks

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Rank Definition and Range](#rank-definition-and-range)
  - [Relationship to Classes and Progression](#relationship-to-classes-and-progression)
  - [Promotion Cost and Prerequisites](#promotion-cost-and-prerequisites)
  - [Default Values and Overrides](#default-values-and-overrides)
  - [Command Authority and Leadership](#command-authority-and-leadership)
  - [UI Integration and Display](#ui-integration-and-display)
  - [Data-Driven Design and Modding](#data-driven-design-and-modding)
- [Examples](#examples)
  - [Basic Rank Progression](#basic-rank-progression)
  - [XP Cost Calculation](#xp-cost-calculation)
  - [Prerequisite Validation](#prerequisite-validation)
  - [Command Authority Application](#command-authority-application)
  - [Leadership Bonus Effects](#leadership-bonus-effects)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Ranks system provides a compact numeric representation of unit progression, summarizing promotion steps from base class while serving as a design convenience for UI, filtering, and default balancing. Ranks increment with each promotion and offer lightweight indexing for large class sets, but all concrete gameplay values remain authoritative from the unit's current class definition. The system supports configurable ranges (typically 0-5), data-driven mappings, and comprehensive modding while maintaining deterministic behavior.

Ranks provide default values for salaries, scores, and other tuning hooks, but class-specific overrides always take precedence. They enable quick roster filtering and progression cues while ensuring precise stats come from class entries. Promotion requires meeting XP thresholds, facility prerequisites, and health requirements, with all mechanics fully seeded for reproducible outcomes.

## Mechanics
### Rank Definition and Range
Ranks are integers within configurable bounds, defaulting to 0-5 representing recruit to grandmaster levels. Each promotion increments rank by exactly one, with no skipping allowed. Rank represents promotion tree depth from base class, providing objective progression measurement independent of specific advancement paths.

### Relationship to Classes and Progression
While ranks summarize advancement, classes remain the definitive source for unit capabilities. Promotion replaces the unit's class with a successor, incrementing rank while all stat and ability changes derive from the new class definition. Rank provides fallback defaults for salaries and scores, but class values always supersede rank defaults.

### Promotion Cost and Prerequisites
XP requirements follow rank-based templates with progressive costs for higher levels, modified by intelligence traits. Prerequisites include facility access, research unlocks, health status, and mission experience thresholds. Classes can override default rank costs, and all requirements must be met before promotion eligibility.

### Default Values and Overrides
Ranks provide convenient defaults for salaries, scores, and command authority. Salary multipliers increase with rank, command authority expands leadership capabilities, and scores reflect unit investment value. However, class-specific or per-unit overrides always take precedence over rank defaults.

### Command Authority and Leadership
Higher ranks grant increasing command authority, determining squad size limits, order complexity, and subordinate management. Leadership bonuses aggregate across squad members, improving morale, initiative, and recovery rates. Command relationships maintain proper hierarchy with rank-based superior/subordinate validation.

### UI Integration and Display
Ranks appear throughout interfaces with visual indicators, progress bars, and filter options. Promotion previews show upcoming rank details, requirements status, and benefit previews. Tooltips provide detailed rank information, and roster organization uses rank categories for efficient navigation.

### Data-Driven Design and Modding
All rank mappings, costs, prerequisites, and benefits are stored in configuration files. New ranks can be added, existing ones modified, and custom prerequisites or benefits implemented without code changes. The system provides comprehensive APIs for extension and integration.

## Examples
### Basic Rank Progression
Recruit (rank 0) with sufficient XP promotes to Private (rank 1), gaining +5 accuracy, +10 morale, basic training ability, 20% salary increase, and authority to command recruits. The promotion requires meeting facility and health prerequisites.

### XP Cost Calculation
Corporal promotion requires 100 XP base cost, reduced to 75 XP for smart trait units or increased to 125 XP for stupid trait units. Sniper class overrides set promotion cost to 120 XP regardless of traits.

### Prerequisite Validation
Sergeant rank requires 5 completed missions, 10 enemy kills, and 30 days service. A unit with adequate XP remains ineligible until mission count reaches threshold, with UI clearly displaying unmet requirements.

### Command Authority Application
Sergeant (authority level 3) can command up to 4 privates but cannot command corporals. Squad leadership combines sergeant +15 bonus with private +0 bonuses for total +15 leadership, improving squad morale by 10% and initiative by 8%.

### Leadership Bonus Effects
Squad with captain (+25 leadership), sergeant (+15), and two privates (+0) receives +40 total leadership bonus, providing 20% morale improvement, 15% initiative increase, and 10% faster recovery rates.

## Related Wiki Pages

- [Classes.md](../units/Classes.md) - Class progression and specialization
- [Promotion.md](../units/Promotion.md) - Rank advancement mechanics
- [Experience.md](../units/Experience.md) - Experience requirements for ranks
- [Finance.md](../finance/Finance.md) - Salary costs and rank bonuses
- [Geoscape.md](../geoscape/Geoscape.md) - Command authority and leadership
- [Basescape.md](../basescape/Basescape.md) - Leadership bonuses and effects
- [Units.md](../units/Units.md) - Unit progression and stat growth
- [AI.md](../ai/AI.md) - Mission generation and difficulty scaling
- [Modding.md](../technical/Modding.md) - Custom rank system modding
- [SaveSystem.md](../technical/SaveSystem.md) - Rank persistence and tracking

## References to Existing Games and Mechanics

- **X-COM Series**: Rank progression and command structure
- **Fire Emblem Series**: Level and rank advancement system
- **Final Fantasy Tactics**: Job level and progression mechanics
- **Advance Wars**: CO level and power progression
- **Tactics Ogre**: Character level and advancement system
- **Disgaea Series**: Level progression and stat growth
- **Persona Series**: Level progression and ability unlocks
- **Mass Effect Series**: Level system and paragon/renegade ranks
- **Dragon Age Series**: Level advancement and specialization
- **Fallout Series**: Level progression and perk system

