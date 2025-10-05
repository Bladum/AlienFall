# Research Entry

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Global Progress Framework](#global-progress-framework)
  - [Local Requirements](#local-requirements)
  - [Reservation and Resource Management](#reservation-and-resource-management)
  - [Completion Effects and Branching](#completion-effects-and-branching)
  - [Artifact Analysis System](#artifact-analysis-system)
  - [Research Types and Applications](#research-types-and-applications)
  - [Determinism and Modding](#determinism-and-modding)
- [Examples](#examples)
  - [Global Progress Examples](#global-progress-examples)
  - [Local Requirements Cases](#local-requirements-cases)
  - [Completion Effects Examples](#completion-effects-examples)
  - [Artifact Analysis Progressions](#artifact-analysis-progressions)
  - [Research Type Applications](#research-type-applications)
  - [Determinism and Modding Cases](#determinism-and-modding-cases)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Research entries represent the atomic units of technological and scientific advancement in Alien Fall. Each entry defines a discrete research project that consumes global research capacity and produces specific game effects upon completion. The system supports deterministic seeded randomization for reproducible outcomes, extensive modding through data-driven configuration, and complex prerequisite networks that create meaningful technology trees.

The research entry framework enables:
- Global Progress Accumulation: Research capacity distributed across multiple bases contributing to shared technological goals
- Local Resource Management: Individual bases handle resource reservation and facility requirements for research initiation
- Artifact Analysis Progression: Multi-stage analysis of recovered alien technology with graduated capability unlocks
- Branching Technology Trees: Mutually exclusive research pathways creating strategic technology choices
- Deterministic Outcomes: Seeded randomization ensures reproducible research results and testing scenarios

## Mechanics

### Global Progress Framework

Research entries consume global research capacity measured in man-hours or science points. Each entry defines a base cost that gets seeded to a 75-125% range for campaign-specific variation. Progress accumulates across all contributing bases, with partial completion preserved across saves and game sessions. Multiple bases can simultaneously work on the same research entry, with their combined capacity determining completion speed.

### Local Requirements

Research entries can specify local prerequisites that must be satisfied at the initiating base:
- Facility Prerequisites: Specific services or facilities with minimum capacity levels
- Resource Requirements: Stored items, units, or resources that get reserved during research
- Narrative Conditions: Quest completion flags or story state requirements
- Personnel Dependencies: Staff with specific traits or specialist qualifications
- Negative Prerequisites: Other research entries that must NOT be completed
- Multi-Condition Logic: Complex boolean combinations of prerequisites

### Reservation and Resource Management

When research begins, required inputs get reserved at the local base to prevent their use elsewhere. Cancellation policies determine resource refund behavior, while capacity allocation rules govern how research capacity gets distributed across concurrent projects. The system provides UI feedback on requirement satisfaction status and supports strategic resource optimization across multiple research initiatives.

### Completion Effects and Branching

Research completion triggers various game effects:
- Manufacturing Unlocks: New recipes for facilities, items, or services become available
- Supplier Access: Marketplace suppliers get unlocked or blocked based on technological progress
- Reward Systems: One-time item grants or global modifiers get applied
- World Changes: New portals open or quests initiate in response to discoveries
- Entry Spawning: Seeded selection from pools of potential follow-up research entries
- Pathway Control: Mutually exclusive branches get permanently locked, forcing technology choices

### Artifact Analysis System

Recovered alien artifacts progress through staged analysis states:
- Initial Recovery: Artifact becomes available for research
- Specification Knowledge: Technical details get revealed through analysis
- Equipment Permission: Units can equip or utilize the artifact
- Manufacturing Capability: Production recipes become available for replication

The system supports different analysis quality levels, with live specimens providing deeper unlocks than deceased ones. Research can enable artifact decomposition recipes and marketplace integration for purchasing related technologies.

### Research Types and Applications

Different research entry types serve various gameplay purposes:
- Technical Research: Unlocks new systems, items, and production capabilities
- Experimental Research: Repeatable projects providing incremental efficiency improvements
- Lore Research: Narrative entries revealing alien civilization history and story branches
- Discovery Research: Analysis projects that spawn new research opportunities
- Branching Research: Mutually exclusive technology pathways requiring strategic choices
- Milestone Research: Campaign progress markers unlocking new game phases

### Determinism and Modding

The research system uses seeded randomization for stochastic elements like cost variation and entry spawning. All parameters get defined in external configuration files supporting extensive modding. Hook systems (on_start, on_tick, on_complete) enable integration with other game systems. Comprehensive telemetry tracks research progress for debugging and performance analysis, while seeded scenarios support balance validation and testing.

## Examples

### Global Progress Examples
- Laser Technology: Base cost 1500 man-hours, seeded to 1125-1875 range, requires completed basic electronics research
- Plasma Technology: Base cost 2000 man-hours, seeded to 1500-2500 range, requires alien alloys resource
- Psionic Research: Base cost 1500 man-hours, seeded to 1125-1875 range, requires live captive specimen
- Advanced Composites: Base cost 1800 man-hours, seeded to 1350-2250 range, requires completed basic materials research
- UFO Reverse Engineering: Base cost 2500 man-hours, seeded to 1875-3125 range, requires intact UFO recovery

### Local Requirements Cases
- Facility Prerequisites: Research lab with research_capacity ≥ 5 required for advanced projects
- Resource Requirements: 10 alien alloys needed for materials research, reserved during project
- Narrative Conditions: Completed "First Contact" quest required for alien technology research
- Personnel Dependencies: Scientist with "Xenobiology" trait required for biological research
- Negative Prerequisites: "Basic Xenology" must NOT be completed for alternative research path
- Multi-Condition Logic: Research requires both facility AND resource prerequisites satisfied

### Completion Effects Examples
- Manufacturing Unlocks: Alien alloy armor recipes unlocked, enabling workshop production
- Supplier Access: Hyperion Advanced supplier unlocked for marketplace plasma weapons
- Reward Grants: Unique alien artifact added to base inventory upon completion
- World Changes: New portal opened in random province, creating new mission opportunities
- Entry Spawning: Two child research entries selected from pool of 5 possible follow-ups
- Pathway Blocking: Alternative research branch permanently locked, forcing technology choices

### Artifact Analysis Progressions
- Laser Rifle Development: Artifact → Analyzed (specs revealed) → Usable (equip permission) → Manufacturable (workshop recipe)
- Plasma Weapon Evolution: Initial artifact state → specification knowledge → equipment integration → production capability
- Alien Armor Progression: Recovered suit → analysis completion → unit equip permission → manufacturing unlock
- Psionic Device Stages: Captured device → technical analysis → operational understanding → reproduction capability
- UFO Component Analysis: Recovered part → specification reveal → integration research → manufacturing recipe
- Biological Specimen Study: Live capture → autopsy research → capability analysis → application development

### Research Type Applications
- Technical Research: Unlocks laser weapon systems, enabling new combat capabilities
- Experimental Research: Repeatable project providing 10% efficiency improvement per completion
- Lore Research: Narrative entry revealing alien civilization history, unlocking story branches
- Discovery Research: First plasma weapon recovery spawns related research opportunities
- Branching Research: Choose between weapon specialization or armor development pathways
- Milestone Research: Campaign progress marker unlocking new game phases and challenges

### Determinism and Modding Cases
- Seeded Cost Variation: Base 1000 cost seeded to 850 for specific campaign reproducibility
- Hook Integration: on_complete event triggers automated base facility construction
- Telemetry Tracking: Research progress logged for performance analysis and debugging
- Configuration Flexibility: All parameters adjustable through external TOML files
- Mod Compatibility: Custom research entries with unique prerequisites and effects
- Testing Scenarios: Seeded research completion sequences for balance validation

## Related Wiki Pages

- [Research](basescape/Research.md) - Main research system and laboratory management
- [Manufacturing](economy/Manufacturing.md) - Technology unlocks for production recipes
- [Suppliers](economy/Suppliers.md) - Research-gated supplier access
- [Finance](finance/Finance.md) - Research costs and budget allocation
- [Facilities](basescape/Facilities.md) - Laboratory facilities and research capacity
- [Capacities](basescape/Capacities.md) - Research throughput limits
- [Craft Items](crafts/Craft item.md) - Technology requirements for equipment
- [Units](units/Units.md) - Research requirements for personnel training
- [Technical Architecture](architecture.md) - Research system data structures
- [Lore](lore/Lore.md) - Research discoveries and alien technology

## References to Existing Games and Mechanics

- **XCOM Series**: Research system and technology tree progression
- **Civilization**: Technology research and advancement mechanics
- **Master of Orion**: Research and technological development systems
- **Homeworld**: Technology research and ship advancement
- **StarCraft**: Technology research and unit upgrades
- **Command & Conquer**: Research systems and technological progression
- **Total War**: Technology research and civilization advancement
- **Crusader Kings**: Innovation system and technological development
- **Europa Universalis**: Technology research and scientific advancement
- **Stellaris**: Research system and technological discovery

