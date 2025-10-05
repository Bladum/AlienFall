# Company

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Company Levels](#company-levels)
  - [Progression Requirements](#progression-requirements)
  - [Level Effects](#level-effects)
  - [Milestone Tracking](#milestone-tracking)
- [System Integration](#system-integration)
  - [Research System Integration](#research-system-integration)
  - [Manufacturing System Integration](#manufacturing-system-integration)
  - [Diplomatic System Integration](#diplomatic-system-integration)
  - [Facility System Integration](#facility-system-integration)
  - [Mission System Integration](#mission-system-integration)
- [Examples](#examples)
  - [Early Game Progression (CA to CB)](#early-game-progression-ca-to-cb)
  - [Mid-Game Expansion (CB to CC)](#mid-game-expansion-cb-to-cc)
  - [Late Game Dominance (CD to CE)](#late-game-dominance-cd-to-ce)
  - [Milestone Achievement Examples](#milestone-achievement-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Company system represents the player's organizational progression and serves as the primary framework for unlocking advanced capabilities throughout the campaign. Company levels act as milestone achievements that gate access to facilities, equipment, diplomatic options, and strategic capabilities. This system provides structured growth that rewards campaign accomplishments with tangible gameplay improvements, creating a satisfying narrative of organizational expansion from a small covert operation to a global defense force.

Key design principles include:
- Milestone-Based Progression: Advancement through significant campaign achievements
- Data-Driven Unlocks: Configurable prerequisites and rewards for moddability
- Global Effects: Company level influences multiple game systems simultaneously
- Deterministic Application: Consistent and auditable progression effects
- Clear Player Feedback: Transparent requirements and benefits communication

## Mechanics

### Company Levels
Company progression is divided into discrete tiers, each representing a significant expansion of organizational capabilities and influence.

Level Structure:
- CA (Covert Actions): Starting level with basic operational capabilities
- CB (Covert Bureau): Expanded operations with laboratory and research access
- CC (Covert Command): Command-level operations with advanced interceptors and facilities
- CD (Covert Division): Divisional scale with psionic research and elite equipment
- CE (Covert Enclave): Elite enclave with ultimate technologies and global influence

Level Characteristics:
- Unique identifier and descriptive name
- Associated unlocks and capabilities
- Global modifiers affecting game systems
- Prerequisite achievements for advancement
- Visual and narrative representation

### Progression Requirements
Company advancement requires completion of significant campaign milestones that demonstrate organizational growth and capability.

Requirement Types:
- Research Breakthroughs: Completion of major technological discoveries
- Combat Achievements: Successful interception of advanced UFO threats
- Facility Construction: Establishment of key infrastructure
- Diplomatic Success: Formation of international alliances
- Funding Milestones: Achievement of financial stability thresholds

Progression Gates:
- Each level requires specific combinations of milestones
- Requirements become more complex at higher tiers
- Some milestones unlock multiple levels progressively
- Failed requirements provide clear feedback on remaining objectives

### Level Effects
Company levels provide global modifiers and unlocks that affect multiple game systems simultaneously.

Research Effects:
- Base research speed multipliers
- Access to advanced research topics
- Specialized laboratory capabilities
- Breakthrough probability modifiers

Manufacturing Effects:
- Production cost reductions
- Manufacturing speed improvements
- Access to advanced equipment categories
- Quality and reliability bonuses

Diplomatic Effects:
- Negotiation success bonuses
- Access to high-level diplomatic options
- International treaty capabilities
- Global influence modifiers

Operational Effects:
- Advanced facility construction permissions
- Elite equipment procurement access
- Specialized mission type availability
- Strategic capability expansions

### Milestone Tracking
The milestone system tracks campaign achievements that contribute to company progression and capability unlocks.

Milestone Categories:
- Combat Milestones: Interception victories, mission successes, threat eliminations
- Research Milestones: Technological breakthroughs, alien artifact analysis
- Infrastructure Milestones: Base construction, facility development
- Diplomatic Milestones: Alliance formations, treaty negotiations
- Economic Milestones: Funding achievements, resource management successes

Milestone Properties:
- Unique identifier and descriptive information
- Category classification for organization
- Trigger conditions for automatic completion
- Experience point rewards
- Company level unlock associations
- Optional hidden status for surprise reveals

## System Integration

### Research System Integration
Company levels directly influence research capabilities and available technologies.

Research Speed Modification:
- Base research rate multipliers applied globally
- Specialized research category bonuses
- Breakthrough probability adjustments
- Parallel research project capacity increases

Technology Access:
- Progressive unlocking of research topics
- Prerequisite technology requirements
- Specialized research facility access
- Advanced research methodology availability

### Manufacturing System Integration
Company progression affects production capabilities and equipment availability.

Production Efficiency:
- Manufacturing cost reduction modifiers
- Production speed improvements
- Quality control enhancements
- Bulk production capability unlocks

Equipment Access:
- Progressive equipment category unlocks
- Advanced weapon system availability
- Specialized vehicle procurement
- Elite unit equipment permissions

### Diplomatic System Integration
Organizational growth enables enhanced international relations capabilities.

Diplomatic Capabilities:
- Negotiation success probability bonuses
- Access to advanced diplomatic actions
- International treaty negotiation permissions
- Global influence projection abilities

Relationship Effects:
- Enhanced diplomatic relationship modifiers
- Crisis management capability improvements
- Alliance formation prerequisites
- International cooperation bonuses

### Facility System Integration
Company levels gate access to advanced base facilities and infrastructure.

Facility Unlocks:
- Progressive facility type availability
- Advanced laboratory construction permissions
- Specialized research center access
- Command and control facility capabilities

Capacity Bonuses:
- Existing facility capacity increases
- Efficiency improvements for unlocked facilities
- Specialized function enhancements
- Infrastructure synergy bonuses

### Mission System Integration
Organizational growth expands available mission types and strategic options.

Mission Availability:
- Advanced mission type unlocks
- Specialized operation permissions
- Strategic objective access
- Multi-phase operation capabilities

Operational Effects:
- Mission success probability modifiers
- Resource requirement adjustments
- Time limit extensions for complex operations
- Strategic planning capability enhancements

## Examples

### Early Game Progression (CA to CB)
Starting Level (CA - Covert Actions):
- Basic facilities: Hangar, Workshop
- Basic equipment: Standard interceptors
- Limited diplomatic options: Basic negotiations
- Research speed: Base level (1.0x)
- Manufacturing cost: Standard (1.0x)

First Advancement (CB - Covert Bureau):
- Unlocked by: First UFO interception + basic research completion
- New facilities: Laboratory, Radar Station
- New equipment: Advanced interceptors, basic fighters
- Enhanced diplomacy: Advanced negotiations
- Research speed: +10% bonus (1.1x)
- Manufacturing cost: -5% reduction (0.95x)

### Mid-Game Expansion (CB to CC)
Current Level (CB - Covert Bureau):
- Research focus: Alien material analysis
- Facility network: Basic laboratories operational
- Equipment roster: Mixed interceptor fleet
- Diplomatic standing: Regional influence established

Command Level Advancement (CC - Covert Command):
- Unlocked by: Major research breakthrough + multiple base construction
- New facilities: Command Center, Psionic Laboratory
- New equipment: Elite interceptors, heavy fighters
- Global diplomacy: International treaties
- Research speed: +20% bonus (1.2x)
- Manufacturing cost: -10% reduction (0.9x)

### Late Game Dominance (CD to CE)
Divisional Scale (CD - Covert Division):
- Advanced capabilities: Psionic research active
- Global operations: Multiple international bases
- Elite equipment: Plasma weapons, specialized interceptors
- Diplomatic network: Global alliances established

Elite Enclave (CE - Covert Enclave):
- Unlocked by: Ultimate research completion + maximum diplomatic success
- Ultimate facilities: Quantum research labs, dimensional gates
- Ultimate equipment: Quantum interceptors, antimatter weapons
- Galactic diplomacy: Interstellar contact capabilities
- Research speed: +50% bonus (1.5x)
- Manufacturing cost: -20% reduction (0.8x)

### Milestone Achievement Examples
First Contact Milestone:
- Category: Combat
- Trigger: Successful first UFO interception
- Rewards: 50 experience points
- Unlocks: Basic research acceleration
- Description: "Successfully intercept your first UFO"

Alien Materials Breakthrough:
- Category: Research
- Trigger: Completion of alien materials research
- Rewards: 100 experience points + level advancement
- Unlocks: Advanced laboratory construction
- Description: "Complete research on alien materials"

International Coalition:
- Category: Diplomatic
- Trigger: Formation of global alliance network
- Rewards: 200 experience points + diplomatic bonuses
- Unlocks: International treaty negotiations
- Description: "Establish diplomatic relations with all major nations"

## Related Wiki Pages

- [Basescape.md](../basescape/Basescape.md) - Base expansion and facility unlocks
- [Research tree.md](../economy/Research%20tree.md) - Research acceleration and technology access
- [Economy.md](../economy/Economy.md) - Manufacturing capabilities and production bonuses
- [Geoscape.md](../geoscape/Geoscape.md) - Diplomatic opportunities and strategic access
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission access and difficulty unlocks
- [Items.md](../items/Items.md) - Equipment procurement and advanced gear
- [Finance.md](../finance/Finance.md) - Economic benefits and funding increases
- [AI.md](../ai/AI.md) - Strategic response and difficulty scaling
- [Fame.md](../organization/Fame.md) - Reputation effects and media coverage
- [Policies.md](../organization/Policies.md) - Company policies and management options

## References to Existing Games and Mechanics

- **X-COM Series**: Organization growth and capability expansion
- **Civilization Series**: Civilization advancement and era progression
- **Crusader Kings III**: Dynasty progression and legacy building
- **Europa Universalis IV**: Nation development and administrative growth
- **Total War Series**: Faction progression and campaign advancement
- **Stellaris**: Empire expansion and technological progression
- **Victoria Series**: Country development and industrialization
- **Hearts of Iron Series**: Nation progression and military expansion
- **Supreme Commander**: Commander progression and army building
- **Company of Heroes**: Company advancement and reinforcement systems

