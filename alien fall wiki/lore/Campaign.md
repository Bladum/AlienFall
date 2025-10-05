# Campaign

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Campaign Activation](#campaign-activation)
  - [Campaign Composition](#campaign-composition)
  - [Wave System](#wave-system)
  - [Scheduling Semantics](#scheduling-semantics)
  - [Lifecycle Management](#lifecycle-management)
  - [Deterministic Behavior](#deterministic-behavior)
- [Examples](#examples)
  - [Scouting Campaign](#scouting-campaign)
  - [Escort Cluster](#escort-cluster)
  - [Staggered Base Pressure](#staggered-base-pressure)
  - [Grouped Mixed Waves](#grouped-mixed-waves)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Campaigns serve as high-level narrative structures that sequence missions, events, and player challenges over time in Alien Fall. They define victory conditions, create emergent stories, and provide pacing for long-term strategic gameplay. Data-driven and seeded for deterministic behavior, campaigns instantiate at monthly boundaries and schedule ordered waves of mission spawns that persist across days or months. Players experience campaigns indirectly through the missions they generate on the geoscape, creating a sense of escalating alien activity and strategic pressure. This system creates the backbone of long-term gameplay, ensuring that each playthrough feels like a coherent narrative arc rather than disconnected random events.

### Key Design Principles

- High-Level Sequencing: Orchestrates missions and events into meaningful narrative arcs
- Data-Driven Design: All campaign parameters defined in external configuration files
- Deterministic Execution: Seeded randomization ensures reproducible campaign outcomes
- Emergent Storytelling: Procedural generation creates coherent stories from simple rules
- Strategic Pacing: Long-term gameplay structured around campaign milestones
- Invisible Direction: Players experience campaigns through mission consequences

## Mechanics

### Campaign Activation

Campaigns activate through monthly sampling with constrained selection:

- Monthly Sampling: Calendar triggers campaign selection at month boundaries
- Candidate Pool: Available templates filtered by faction and region compatibility
- Slot Limits: Maximum campaigns per month prevent system overload
- Weighted Selection: Templates chosen based on faction and region priorities
- Instance Creation: Each campaign receives unique seeded identifier for deterministic behavior

### Campaign Composition

Campaigns defined through comprehensive template data structures:

- Faction Ownership: Each campaign belongs to specific alien faction with consistent behavior
- Regional Targeting: Geographic constraints for mission placement and strategic focus
- Duration Limits: Maximum campaign lifespan in days prevents infinite escalation
- Conditional Gating: Prerequisites for campaign activation (research, story progress)
- Weighting System: Base and multiplier values for selection probability

### Wave System

Waves group related mission spawns with timing and placement constraints:

- Mission Grouping: Multiple missions spawned simultaneously for coordinated operations
- Type Distribution: UFO, site, and base mission mixtures for varied encounters
- Regional Clustering: Missions constrained to specific areas for focused pressure
- Escort Support: Additional missions providing protection for high-value targets
- Conditional Execution: Requirements for wave activation based on campaign progress

### Scheduling Semantics

Flexible timing system supports various campaign pacing patterns:

- Start Delays: Initial delay before first wave activation for narrative synchronization
- Inter-Wave Delays: Days between consecutive waves controlling escalation pace
- Explicit Spawn Days: Specific calendar dates for mission appearance and predictability
- Multi-Month Campaigns: Waves spanning extended time periods for long-term threats
- Zero-Delay Waves: Multiple waves processed in single day for intense pressure

### Lifecycle Management

Campaign progression with completion and termination conditions:

- Progress Tracking: Current wave index and spawned mission history for state management
- Completion Criteria: All waves processed or strategic objectives achieved
- Termination Conditions: Research completion, story progression, or player success
- State Management: Active, paused, completed, or failed states with proper transitions
- Resource Cleanup: Proper disposal of completed campaigns to prevent memory leaks

### Deterministic Behavior

All campaign mechanics use seeded randomization for reproducible outcomes:

- World Seeding: Master seed ensures consistent campaign selection across sessions
- Instance Seeding: Unique seeds for individual campaign behavior and mission generation
- Named RNG Streams: Separate random streams for different decisions prevent cross-contamination
- Provenance Logging: Complete audit trail of all campaign events for debugging and analysis
- Replay Capability: Exact reproduction of campaign sequences for testing and balance

## Examples

### Scouting Campaign

Simple Reconnaissance Pattern
- Monthly selection activates scouting campaign for specific faction
- Wave 1: Single scout UFO spawns immediately (0-day start delay)
- 3-day inter-wave delay creates predictable timing
- Wave 2: Additional scout UFO and small site in same region
- Creates manageable reconnaissance pressure with clear escalation

Explicit Timing Schedule
- Template specifies spawn days: 5, 15, and 25 of the month
- Three scout UFO missions at predetermined intervals
- Player can anticipate and prepare interception strategies
- Creates manageable, predictable threat pattern for strategic planning

### Escort Cluster

Protected Convoy
- Single wave spawns large UFO with 2-3 escort craft
- All missions constrained to same province for tactical focus
- Creates high-value protected target requiring coordinated response
- Tests player's ability to handle multiple simultaneous threats
- Requires strategic resource allocation and interception planning

Regional Focus
- Escort cluster appears in high-value province
- Concentrated alien presence creates localized strategic pressure
- Forces player to prioritize responses in critical areas
- Creates pressure points that affect regional mission availability

### Staggered Base Pressure

Extended Escalation
- Multi-wave campaign spanning 30-60 days for long-term threat
- Early waves: Scout UFOs and harassment raids for initial pressure
- Mid-campaign: Landing missions and supply operations for escalation
- Late waves: Base construction and defensive emplacements for climax
- Progressive difficulty increase allows player preparation time

Adaptive Pressure
- Initial waves test player detection and response capabilities
- Later waves escalate based on player success/failure patterns
- Creates narrative of growing alien presence and strategic challenge
- Allows time for technological advancement and countermeasure development

### Grouped Mixed Waves

Coordinated Operations
- Single wave spawns UFO, site mission, and convoy raid simultaneously
- All missions targeted at same region for complex multi-mission scenarios
- Creates tactical challenges requiring prioritization and resource management
- Tests player's ability to handle diverse threats in concentrated area
- Emergent interactions between different mission types

Thematic Consistency
- Mixed waves maintain faction-specific behavior patterns and tactics
- Escort relationships preserved across mission types for coherent operations
- Provenance tracking maintains connection between related missions
- Creates coherent operational narratives with strategic depth

## Related Wiki Pages

- [Calendar.md](../lore/Calendar.md) - Campaign timing and scheduling
- [Mission.md](../lore/Mission.md) - Campaign mission generation
- [Event.md](../lore/Event.md) - Campaign event triggers
- [Faction.md](../lore/Faction.md) - Faction-specific campaigns
- [Geoscape.md](../geoscape/Geoscape.md) - Campaign geoscape effects
- [UFO Script.md](../lore/UFO%20Script.md) - UFO campaign activities
- [Quest.md](../lore/Quest.md) - Campaign quest progression
- [Enemy Base script.md](../lore/Enemy%20Base%20script.md) - Base assault campaigns

## References to Existing Games and Mechanics

- **XCOM Series**: Alien invasion campaign progression
- **Total War Series**: Campaign maps and strategic progression
- **Civilization Series**: Civilization advancement and victory conditions
- **Crusader Kings Series**: Dynasty and realm management campaigns
- **Europa Universalis Series**: Nation-building and expansion campaigns
- **Fire Emblem Series**: Story-driven campaign progression
- **Final Fantasy Series**: Epic story campaign structures
- **BattleTech**: Mercenary campaign and contract systems
- **MechWarrior Series**: Mercenary company campaign management
- **Warhammer 40k**: Crusade and narrative campaign systems

