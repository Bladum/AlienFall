# Faction

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Faction Identity](#faction-identity)
  - [Faction Ownership and Missions](#faction-ownership-and-missions)
  - [Faction Relationship to Player](#faction-relationship-to-player)
  - [Faction Progression and Deactivation](#faction-progression-and-deactivation)
  - [Faction Scoring and Telemetry](#faction-scoring-and-telemetry)
  - [Faction Composition and Variety](#faction-composition-and-variety)
  - [Faction Relationship to Other Systems](#faction-relationship-to-other-systems)
  - [Faction Authoring Guidance](#faction-authoring-guidance)
- [Examples](#examples)
  - [Sectoid Directorate Faction](#sectoid-directorate-faction)
  - [Midwest Insurgents Faction](#midwest-insurgents-faction)
  - [Shadow Brokers Faction](#shadow-brokers-faction)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Factions represent persistent narrative actors within the campaign that generate missions and shape regional pressure. Each faction encapsulates a coherent adversary with its own spawn pools, rewards, and end conditions. Factions drive long-term story arcs and deterministic mission generation tied to campaign seeds. Resolving a faction disables its future spawns and yields narrative rewards. Faction definitions are data-driven for easy tuning and modding, allowing designers to control pacing through configurable preferred regions, mission templates, and spawn weights.

The faction system serves as a director mechanism that creates sustained strategic pressure while maintaining narrative coherence. Factions operate independently but can be linked to suppliers or countries for additional context, providing flexible storytelling tools for campaign design.

### Key Design Principles

- Narrative Coherence: Each faction represents a unified adversarial story arc
- Regional Pressure: Geographic preferences creating localized strategic challenges
- Deterministic Generation: Seeded randomization ensuring reproducible mission spawning
- Data-Driven Design: All faction parameters defined in external TOML configuration files
- Strategic Resolution: Clear end conditions with meaningful rewards and consequences
- Modding Support: Extensive customization through template-based authoring

## Mechanics

### Faction Identity

Single Narrative Actor: Each faction represents one cohesive adversarial group whose story arc players must progress through, distinct from taxonomic race classifications.

Race Association: Factions are linked to races for authoring clarity, but race and faction remain separate concepts - race is biological classification while faction is operational narrative entity.

Unique Operational Profile: Every faction maintains distinct spawn pools, regional preferences, and mission templates that define its strategic behavior.

Data-Driven Definition: Factions are authored in TOML with minimum required fields including identifier, race association, preferred regions, mission templates, rewards, end conditions, and score aggregation tags.

### Faction Ownership and Missions

Mission Exclusivity: Factions own all missions they spawn, with mixed-crew missions (units from multiple factions/races) requiring explicit designer approval as exceptions.

Regional Bias: Factions have preferred spawn regions with configurable weight modifiers that influence mission placement probabilities.

Deterministic Behavior: All faction stochastic choices use seeded random number generation derived from campaign seeds to ensure reproducible mission generation.

Regional Weighting: Spawn weights are region-biased and configured in data, allowing designers to control faction geographic distribution.

### Faction Relationship to Player

Hostile Adversary: Factions are always treated as operational adversaries requiring confrontation and neutralization.

Separate Moral Tracking: Player perception and reputation (Karma, Fame) are tracked independently from faction diplomatic relations.

No Dynamic Relationships: Factions maintain fixed hostile status without negotiation or alliance mechanics.

Confrontation Focus: Player interactions with factions center on combat, sabotage, and strategic countermeasures.

### Faction Progression and Deactivation

Narrative Advancement: Faction progression occurs through mission completion, research advancement, and quest fulfillment, updating narrative state.

Resolution Conditions: Factions deactivate when final missions or required research are completed, permanently disabling their mission generation.

Reward Distribution: Successful faction resolution yields score, research unlocks, items, and narrative advancements.

State Persistence: Faction progress state tracks completed missions, research, and quests toward end condition fulfillment.

### Faction Scoring and Telemetry

Aggregatable Metrics: Score and telemetry data can be grouped by faction, province, and country for reporting and funding calculations.

Provenance Logging: Faction events and spawn activities are logged with faction identifiers, campaign seeds, and spawned mission references.

Deterministic Tracking: All faction decisions include provenance metadata for debugging and reproducible analytics.

Performance Analytics: Faction-based telemetry enables designer analysis of spawn patterns and player engagement.

### Faction Composition and Variety

Human Faction Pattern: Human factions typically own unique unit pools and bespoke mission templates for distinctive operational profiles.

Alien Faction Pattern: Single races can be represented by multiple factions, each with unique templates and unit pools for varied threat presentation.

Inter-Faction Cooperation: Narrative cooperation between factions is expressed through descriptive text and coordinated templates, not shared simulation state.

Template Coordination: Factions can reference shared mission templates while maintaining independent spawn logic.

### Faction Relationship to Other Systems

Regional Independence: Factions operate by region but remain independent from country and supplier systems.

Optional Linkages: Factions can be explicitly tied to suppliers (for black ops) or countries (for narrative reasons) through data declarations.

Shared Metadata: Factions use common biome, economy, and base metadata for regional filtering and targeting.

Interface Boundaries: Faction ties to external systems require explicit data declarations to avoid implicit assumptions.

### Faction Authoring Guidance

Data-Driven Design: All faction parameters are exposed in TOML for tuning without code changes, including spawn weights, preferred regions, unit pool identifiers, and end condition rules.

Explicit Exception Marking: Mixed-crew missions are marked as designer-driven exceptions to maintain faction ownership clarity.

Provenance Emission: Faction systems emit clear provenance for decisions including seeds, faction identifiers, and chosen template references.

Small Explicit Knobs: Faction configuration uses clear, tunable numeric values for spawn weights, regional preferences, and cooldown periods.

## Examples

### Sectoid Directorate Faction
Race Association: Sectoid command structure
Operational Focus: Coastal region scouting and psi-harassment missions
Resolution Trigger: Completion of final story node disables campaign spawns
Design Purpose: Represents coordinated alien intelligence operations with regional specialization

### Midwest Insurgents Faction
Race Association: Human insurgent group
Operational Focus: Terror strikes and convoy raids within defined regional boundaries
Unique Assets: Exclusive insurgent unit pools and specialized mission templates
Design Purpose: Models human resistance movements with localized operational areas

### Shadow Brokers Faction
Race Association: Human black market operatives
Special Condition: Appearance gated by Black Market supplier unlock
Operational Focus: Covert supply raids in supplier-aligned regions
Design Purpose: Represents criminal underworld elements with conditional activation

## Related Wiki Pages

- [Campaign.md](../lore/Campaign.md) - Faction campaign integration.
- [Mission.md](../lore/Mission.md) - Faction mission generation.
- [Event.md](../lore/Event.md) - Faction event triggers.
- [Calendar.md](../lore/Calendar.md) - Faction activity timing.
- [Geoscape.md](../geoscape/Geoscape.md) - Faction geoscape presence.
- [UFO Script.md](../lore/UFO%20Script.md) - Alien faction UFO activities.
- [Enemy Base script.md](../lore/Enemy%20Base%20script.md) - Faction base operations.
- [Quest.md](../lore/Quest.md) - Faction quest progression.

## References to Existing Games and Mechanics

- **XCOM Series**: Alien factions and invasion forces
- **Total War Series**: Faction warfare and diplomacy
- **Civilization Series**: Civilizations and leader personalities
- **Crusader Kings Series**: Noble houses and family alliances
- **Europa Universalis Series**: Nations and diplomatic relations
- **Stellaris**: Alien empires and galactic politics
- **Hearts of Iron Series**: Nations and ideological alliances
- **Victoria Series**: Countries and political ideologies
- **BattleTech**: Noble houses and faction warfare
- **Warhammer 40k**: Factions and army compositions

