# Enemy Base Script

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Base Existence and Ownership](#base-existence-and-ownership)
  - [Level Progression](#level-progression)
  - [Mission Spawning](#mission-spawning)
  - [Detection and Cover](#detection-and-cover)
  - [Strategic Effects](#strategic-effects)
  - [Battlescape Assault](#battlescape-assault)
  - [Salvage and Destruction](#salvage-and-destruction)
  - [Deterministic Behavior](#deterministic-behavior)
- [Examples](#examples)
  - [Level Progression Example](#level-progression-example)
  - [Spawn Pool Usage](#spawn-pool-usage)
  - [Two-Tier Assault](#two-tier-assault)
  - [Strategic Consequences](#strategic-consequences)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Enemy Base Scripts govern persistent alien installations that serve as long-term regional threats and mission generators in Alien Fall. These bases exist indefinitely until destroyed through ground assault, progressively escalating in capability while applying strategic pressure. Each base follows faction-specific behavior patterns defined through data-driven templates, creating varied tactical challenges and reward opportunities. Bases represent entrenched alien presence that requires significant player investment to eliminate, offering high-risk, high-reward strategic decisions. This system creates ongoing regional pressure that forces players to prioritize threats and allocate resources effectively.

### Key Design Principles

- Persistent Threats: Long-term strategic challenges requiring committed player response
- Progressive Escalation: Growing capability and threat level over time
- Regional Pressure: Localized strategic effects influencing player operations
- Faction-Specific Behavior: Unique characteristics based on controlling alien faction
- Data-Driven Design: All base parameters defined in external configuration files
- Deterministic Execution: Seeded randomization ensuring reproducible outcomes

## Mechanics

### Base Existence and Ownership

Bases establish permanent alien presence with faction-specific characteristics:

- Persistent Presence: Bases remain active until destroyed by ground assault operations
- Faction Ownership: Each base belongs to specific alien faction with consistent behavior patterns
- Regional Containment: Bases operate within single province boundaries for focused pressure
- Coexistence: Multiple bases can exist simultaneously in same province from different factions
- Mission Inheritance: Spawned missions use faction's templates, unit pools, and behavioral patterns

### Level Progression

Bases grow in capability over time through structured advancement:

- Integer Levels: Progression from 1 to 4 (configurable maximum) with clear capability tiers
- Growth Timers: Configurable months required per level advancement (data-driven)
- Footprint Scaling: Map size increases with level (40x40 to 70x70 tiles) for tactical complexity
- Capability Enhancement: Higher levels spawn tougher missions and larger underground complexes
- Deterministic Advancement: Seeded growth timing ensuring reproducible progression across playthroughs

### Mission Spawning

Bases generate ongoing mission threats through monthly spawn cycles:

- Monthly Cycles: Regular mission generation triggered at calendar month boundaries
- Level-Based Volume: Higher levels spawn more frequent and challenging missions
- Weighted Pools: Mission types selected from level-appropriate distributions with configurable weights
- Cooldown Management: Type-specific delays prevent mission spam and maintain strategic pacing
- Regional Focus: Missions concentrated in base's province creating localized pressure

### Detection and Cover

Bases employ concealment mechanics to avoid premature discovery:

- High Initial Cover: Bases start with maximum concealment making them difficult to detect
- Gradual Decay: Daily cover reduction makes detection increasingly likely over time
- Sensor Requirements: Some bases require specific detection technologies or research unlocks
- Tag-Based Hiding: Underground, portal, aquatic bases need specialized sensors for discovery
- Data-Driven Parameters: All detection values configurable per template for modding support

### Strategic Effects

Active bases impose ongoing penalties on regional operations:

- Score Penalties: Daily score reduction scaled by base level affecting overall performance
- Economic Impact: Reduced regional economy and supplier availability in affected areas
- Spawn Weight Modification: Increased local mission generation rates creating pressure clusters
- Infrastructure Blocking: Disrupted transportation and communication networks
- Persistent Modifiers: Effects continue until base destruction, requiring strategic prioritization

### Battlescape Assault

Base assaults feature multi-level tactical complexity with distinct phases:

- Two-Tier Structure: Surface perimeter defense followed by underground complex assault
- Deterministic Generation: Seeded terrain and objective placement ensuring fair, reproducible encounters
- Connectivity Logic: Logical progression between assault phases with tactical choke points
- Reinforcement Rules: Dynamic unit deployment during battle based on assault progress
- Victory Conditions: Multiple completion criteria per level allowing varied tactical approaches

### Salvage and Destruction

Successful assaults yield substantial rewards scaled by base characteristics:

- Level-Scaled Rewards: Higher level bases provide better salvage quantities and quality
- Faction-Specific Loot: Unique items and technologies based on controlling alien faction
- Salvage Tables: Data-driven reward distributions with provenance tracking for reproducibility
- Provenance Tracking: Complete audit trail of reward generation for debugging and balance analysis
- Post-Assault Cleanup: Strategic effect removal and base elimination with regional benefit restoration

### Deterministic Behavior

All base mechanics use seeded systems for consistent, replayable outcomes:

- World Seeding: Master seed ensures reproducible base behavior across sessions and platforms
- Instance Seeding: Unique seeds for individual base progression and mission generation
- Named RNG Streams: Separate randomization streams for different systems preventing cross-contamination
- Provenance Logging: Complete record of all base events and decisions for debugging and analysis
- Replay Capability: Exact reproduction of base lifecycles for testing, balance, and player support

## Examples

### Level Progression Example

Growth Timeline
- Level 1 base establishes with 40x40 tile footprint and basic reconnaissance capabilities
- After 3 months (90 days), advances to level 2 (50x50 footprint) with enhanced capabilities
- Level 2 adds supply convoy missions to spawn pool, increasing economic pressure
- After additional 4 months, reaches level 3 (60x60 footprint) with construction attempts
- Level 3 introduces limited build-forward operations and defensive emplacements
- After 5 months, achieves level 4 (70x70 footprint) with maximum threat capabilities

Capability Escalation
- Level 1: Basic reconnaissance and light raiding operations
- Level 2: Supply operations and craft hunting with increased mission frequency
- Level 3: Forward base construction attempts and sabotage operations
- Level 4: Maximum threat with all mission types, strategic effects, and terror operations

### Spawn Pool Usage

Monthly Generation Cycle
- Level 3 base processes monthly spawn script at calendar boundary
- Available missions: Craft-hunt (high priority), Supply convoy, Recon mission, Build-forward
- Deterministic selection produces: 1 craft-hunt, 1 supply convoy, 1 recon mission
- Cooldown tracking prevents immediate re-spawning of same mission types
- Mission placement constrained to base province for focused regional pressure

Escalation Pressure
- Early levels focus on scouting and resource gathering to establish presence
- Mid-levels add direct threats to player assets and economic operations
- High levels introduce base expansion, terror operations, and maximum strategic pressure
- Creates progressive difficulty curve requiring escalating player countermeasures

### Two-Tier Assault

Surface Defense Phase
- Assault begins with perimeter clearing objectives and defensive positions
- Enemy defenses include patrols, guard posts, and tactical fortifications
- Surface terrain provides cover, elevation, and positioning advantages
- Primary goal: Establish breach point or access for underground penetration

Underground Complex
- Interior level features base core, research facilities, and critical systems
- Connected rooms with defensive choke points and tactical bottlenecks
- Alien technology installations and experimental equipment
- Final objective: Destroy or capture central control system to eliminate base

### Strategic Consequences

Regional Pressure
- Level 4 base applies significant daily score penalties to affected nation
- Reduces local supplier effectiveness by 30% impacting economic operations
- Increases mission spawn rates in surrounding provinces creating pressure clusters
- Blocks key transportation routes affecting logistics and supply chains

Removal Benefits
- Base destruction eliminates all strategic penalties and regional pressure
- Provides substantial salvage including rare faction-specific items and technologies
- Opens province for player base construction and strategic expansion
- Reduces overall regional threat level and improves economic recovery

## Related Wiki Pages

- [Faction.md](../lore/Faction.md) - Base faction ownership and behavior
- [Mission.md](../lore/Mission.md) - Base mission spawning patterns
- [Campaign.md](../lore/Campaign.md) - Base campaign integration
- [Battlescape.md](../battlescape/Battlescape.md) - Base assault battle mechanics
- [Geoscape.md](../geoscape/Geoscape.md) - Base geoscape presence and detection
- [UFO Script.md](../lore/UFO%20Script.md) - Base UFO support and defense
- [Quest.md](../lore/Quest.md) - Base destruction quest objectives
- [Calendar.md](../lore/Calendar.md) - Base progression and escalation timing

## References to Existing Games and Mechanics

- **XCOM Series**: Alien base assaults and strategic installations
- **Commandos Series**: Enemy base infiltration and sabotage
- **Metal Gear Solid Series**: Enemy military installations
- **Rainbow Six Series**: Terrorist base operations
- **Ghost Recon Series**: Enemy compound assaults
- **Battlefield Series**: Enemy stronghold capture mechanics
- **Call of Duty Series**: Enemy base raids and operations
- **Tom Clancy's The Division**: Enemy safehouse systems
- **Splinter Cell Series**: Shadow site infiltration
- **Deus Ex Series**: Enemy facility infiltration and sabotage

