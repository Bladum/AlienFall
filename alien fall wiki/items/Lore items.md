# Lore Items

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Item Acquisition and Storage](#item-acquisition-and-storage)
  - [Research Gating](#research-gating)
  - [Narrative Integration](#narrative-integration)
  - [Item States](#item-states)
  - [Provenance Tracking](#provenance-tracking)
  - [Acquisition Methods](#acquisition-methods)
  - [Consumption Rules](#consumption-rules)
  - [Context-Aware Descriptions](#context-aware-descriptions)
  - [Transfer and Trading](#transfer-and-trading)
  - [Warning Systems](#warning-systems)
- [Examples](#examples)
  - [Research Unlocking](#research-unlocking)
    - [Alien Datapad Research Chain](#alien-datapad-research-chain)
    - [Sectoid Commander Brain](#sectoid-commander-brain)
  - [Narrative Branching](#narrative-branching)
    - [Psionic Research Path](#psionic-research-path)
    - [Ancient Technology Path](#ancient-technology-path)
  - [Collection Patterns](#collection-patterns)
    - [Comprehensive Campaign Collection](#comprehensive-campaign-collection)
    - [Specialized Collection Focus](#specialized-collection-focus)
  - [Item Warnings](#item-warnings)
    - [Research Blocking Sale](#research-blocking-sale)
    - [Narrative Impact Consumption](#narrative-impact-consumption)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Lore Items system implements collectible artifacts, records, and environmental clues that serve as worldbuilding elements, exploration rewards, and research enablers. These items reward thorough investigation while providing optional narrative depth and strategic information that can alter player understanding and research availability. The system emphasizes discoverability without gating core progression, using deterministic provenance tracking to ensure reproducible campaign outcomes and modder-friendly design. Lore items encode worldbuilding and player-facing storytelling through collectible artifacts, records and environmental clues. They serve to reward exploration, provide optional narrative depth, and gate information that can alter player strategies or understanding of factions.

### Key Design Principles

- Exploration Rewards: Items reward thorough mission investigation and environmental interaction
- Optional Narrative Depth: Lore enhances worldbuilding without becoming mandatory
- Research Gating: Items unlock advanced technologies and strategic capabilities
- Deterministic Provenance: Complete audit trail for debugging and replayability
- Data-Driven Configuration: All item properties and relationships defined in configuration files
- Context-Aware Presentation: Dynamic descriptions based on player faction and campaign state

## Mechanics

### Item Acquisition and Storage

Collection and management of lore artifacts:

- Base Storage: Items kept in central base inventory, not occupying unit equipment slots
- Acquisition Methods: Mission rewards, UFO recovery, ground surveys, purchases, quest completion
- Persistent Objects: Items remain in campaign until consumed by scripted events
- No Equipment Use: Cannot be equipped, used in combat, or sold under normal circumstances
- Scripted Overrides: Special events may permit sale, trade, or sacrifice

### Research Gating

Prerequisites for advanced research projects:

- Required Possessions: Specific lore items must be present to start research
- Reservation System: Items may be reserved for research without immediate consumption
- Consumption Options: Research may consume items permanently or allow continued possession
- Unlock Notifications: Clear indication of research availability when prerequisites met
- Progression Gating: Creates meaningful research arcs and technological advancement paths

### Narrative Integration

Storytelling and worldbuilding enhancement:

- Context-Aware Descriptions: Dynamic text based on player faction and campaign state
- Narrative Triggers: Item acquisition can trigger story events and character interactions
- Relationship Mapping: Items linked to characters, locations, and events for provenance
- Faction Perspectives: Different descriptions based on player faction alignment
- Optional Depth: Lore enhances but doesn't require engagement

### Item States

Lifecycle management for collected items:

- Stored: Available in base inventory for research and narrative purposes
- Reserved: Temporarily unavailable due to research requirements
- Consumed: Permanently used up in research or narrative events
- Transferred: Moved to different locations or external storage
- State Transitions: Clear rules for when and how items change states

### Provenance Tracking

Complete collection and usage audit trail:

- Acquisition Metadata: Source mission, location, timestamp, and collection method
- Seed Preservation: RNG seeds for deterministic replay and debugging
- Usage History: Complete record of research consumption and narrative triggers
- Relationship Links: Connections to related items, characters, and events
- Debug Support: Sufficient data for reproducing specific campaign states

### Acquisition Methods

How players obtain lore items:

- Mission Rewards: Awarded for completing objectives or thorough investigation
- UFO Recovery: Salvaged from crashed or destroyed alien craft
- Ground Surveys: Discovered through environmental exploration
- Purchase: Acquired through special vendors or black market contacts
- Quest Completion: Earned through narrative or side mission progression
- Random Discovery: Chance-based finds during normal gameplay

### Consumption Rules

When and how items are permanently used:

- Research Consumption: Items destroyed or transformed during scientific study
- Narrative Sacrifice: Items given up as part of story choices or rituals
- Event Triggers: Items consumed to unlock specific campaign events
- Warning Systems: Clear alerts before irreversible consumption
- Consequence Communication: Explicit display of what will be lost

### Context-Aware Descriptions

Dynamic presentation based on campaign state:

- Faction-Specific Text: Different descriptions for X-COM vs alien perspectives
- Research Status Hints: Indication of unlocked or blocked research projects
- Related Item Status: Information about connected artifacts and specimens
- Campaign Integration: References to current story events and character knowledge
- Progressive Revelation: More detailed information as campaign advances

### Transfer and Trading

Item movement and exchange mechanics:

- Location Transfer: Items moved between bases or storage facilities
- Trading Restrictions: Normal trading blocked, special events may permit
- Sale Warnings: Alerts about research and narrative impacts of selling
- Value Assessment: Credit values for items that can be sold
- Consequence Tracking: Record of what opportunities are lost through transfer

### Warning Systems

Protection against unintended item loss:

- Research Impact Alerts: Notification when selling would block research
- Narrative Consequence Warnings: Information about story branches affected
- Irreversible Action Confirmation: Explicit acknowledgment required for permanent changes
- Opportunity Cost Display: Clear indication of what benefits will be lost
- Recovery Options: Information about whether lost items can be reacquired

## Examples

### Research Unlocking

#### Alien Datapad Research Chain
- Acquisition: Recovered from UFO command deck during crash site investigation
- Research Unlocks: Alien Communications, UFO Navigation systems
- Consumption: Datapad reserved but not consumed during research
- Follow-on Items: Enables recovery of related communication equipment
- Strategic Impact: Allows interception of alien transmissions and improved mission planning

#### Sectoid Commander Brain
- Acquisition: Salvaged from elite alien commander during assault mission
- Research Unlocks: Advanced Psionics, Sectoid Hierarchy understanding
- Consumption: Brain destroyed during psionic research process
- Narrative Trigger: Reveals psionic threat level, increases alien aggression
- Strategic Impact: Enables development of psionic countermeasures and abilities

### Narrative Branching

#### Psionic Research Path
- Key Item: Sectoid Commander Brain
- Branch Options: Embrace psionic research vs focus on conventional weapons
- Consequences: Psionic path unlocks mental abilities but increases alien hostility
- Related Items: Psionic artifacts, mental training devices
- Campaign Impact: Fundamental change in available technologies and tactics

#### Ancient Technology Path
- Key Item: Ancient Alien Artifact
- Branch Options: Investigate ancient technology vs focus on current threats
- Consequences: Ancient research attracts powerful guardians but provides advanced capabilities
- Related Items: Ancient texts, dimensional crystals
- Campaign Impact: Alternative technology tree with unique strategic options

### Collection Patterns

#### Comprehensive Campaign Collection
- Early Game: Alien datapad, basic specimens (UFO crash sites)
- Mid Game: Specialized items (sectoid brains, muton specimens)
- Late Game: Rare artifacts (Omega Device, ancient relics)
- Collection Rate: 2-3 items per major mission with thorough investigation
- Research Pacing: Items unlock research trees that take 5-10 turns to complete

#### Specialized Collection Focus
- Technology Focus: Prioritize electronic and mechanical alien artifacts
- Biological Focus: Collect specimens and biological samples
- Psionic Focus: Seek items related to mental and psychic phenomena
- Ancient Focus: Search for relics from alien prehistory
- Trade-off Decisions: Limited inventory space forces strategic collection priorities

### Item Warnings

#### Research Blocking Sale
- Item: Alien Datapad
- Sale Value: 0 credits (priceless research value)
- Warning: "Selling this item will prevent starting Alien Communications research"
- Consequences: Blocks entire communication technology tree
- Player Choice: Keep for research vs immediate but minimal financial gain

#### Narrative Impact Consumption
- Item: Omega Device
- Consumption Trigger: Final mission activation
- Warning: "Using this device will end the current campaign arc"
- Consequences: Triggers final confrontation, prevents alternative endings
- Player Choice: Use for immediate power vs preserve for different resolution

## Related Wiki Pages

- [Special items.md](../items/Special%20items.md) - Special lore items and artifacts
- [Research tree.md](../economy/Research%20tree.md) - Research unlocking mechanics
- [Faction.md](../lore/Faction.md) - Faction lore and background
- [Mission.md](../lore/Mission.md) - Mission-related lore items
- [Economy.md](../economy/Economy.md) - Item trading and value systems
- [Basescape.md](../basescape/Basescape.md) - Item storage and management
- [AI.md](../ai/AI.md) - AI interpretation of lore items
- [Pedia.md](../pedia/Pedia.md) - Lore documentation and codex

## References to Existing Games and Mechanics

- **Mass Effect Series**: Codex entries and lore artifacts
- **Dragon Age Series**: Lore items and world codex
- **Fallout Series**: Holotapes, notes, and terminal entries
- **The Elder Scrolls Series**: Books and lore documents
- **The Witcher Series**: Books and lore collections
- **Deus Ex Series**: Datapads and email systems
- **System Shock Series**: Audio logs and computer terminals
- **Half-Life Series**: Documents and research notes
- **BioShock Series**: Audio diaries and recordings
- **Metro Series**: Notes, journals, and environmental lore

