# Lore System

Narrative, story arcs, and campaign progression systems providing context and storytelling for AlienFall operations.

## Overview

The Lore system provides narrative depth and campaign progression:
- Campaign phases with thematic progression (Shadow War → First Contact → Deep War → Dimensional War)
- Alien faction lore arcs with research paths
- Technology history and progression narrative
- Narrative events and story hooks
- Alien intelligence and motivation exposition
- Character development and relationships

## Features

### Campaign Phases

**Phase 0: Shadow War (1996-1999)**
- Initial contact with alien infiltrators
- Government agencies investigating paranormal activity
- First armed confrontations with alien forces
- Establishment of XCOM as covert military organization
- Introduction to conventional warfare against aliens

**Phase 1: First Contact (1999-2000)**
- Public revelation of alien presence
- Open warfare begins on multiple fronts
- Development of laser and plasma weapons
- Discovery of alien military hierarchy
- Mobilization of global military forces

**Phase 2: Deep War (2000-2003)**
- Strategic alien invasion escalates
- Introduction of advanced alien forces
- Development of gauss and sonic weapons
- Exploration of alien command structure
- Turning point in human-alien conflict

**Phase 3: Dimensional War (2003-2004)**
- Final confrontation with alien leadership
- Discovery of dimensional rifts
- Development of dimensional armor and weapons
- Climactic battle for humanity's survival
- Campaign conclusion and victory/defeat conditions

### Faction System

Each alien faction has unique characteristics:

**Faction Attributes:**
- **Lore Arc**: Multi-stage narrative progression
- **Research Path**: Faction-specific technology progression
- **Mission Pattern**: Preferred mission types and tactics
- **Weaknesses**: Strategic vulnerabilities
- **Strengths**: Combat advantages
- **Strategic Goals**: Campaign objectives

**Example Factions:**
- Sectoids: Initial reconnaissance forces with telepathic abilities
- Mutons: Heavy combat units with advanced tactics
- Ethereals: Leadership caste with powerful psionics
- Aliens of Unknown Classification: Experimental forces

### Narrative Events

Story-driven events that advance campaign narrative:

**Event Types:**
- **Discovery Events**: Research completions revealing new information
- **Encounter Events**: First contact with new alien faction
- **Mission Events**: Story-relevant battlefield events
- **Character Events**: Personnel interactions and development
- **Strategic Events**: Global situation changes
- **Climactic Events**: Campaign milestone moments

### Technology Lore

Each technology has narrative context:

**Technology Info:**
- **Phase**: Campaign phase introduction
- **Historical Context**: Real-world inspiration or fictional backstory
- **Scientific Explanation**: How the technology works
- **Strategic Impact**: Effect on war progression
- **Alien Origin**: Technologies reverse-engineered from aliens
- **Prerequisites**: Knowledge requirements for development

### Character Development

Named characters and relationships:

**Character Attributes:**
- **Background**: Personal history and motivation
- **Rank**: Military hierarchy position
- **Skills**: Combat and specialist abilities
- **Relationships**: Connections to other characters
- **Arc**: Personal story progression
- **Fate**: Character survival and outcomes

## Architecture

```
lore/
├── campaign/
│   ├── campaign_manager.lua     # Campaign progression coordinator
│   ├── phase_system.lua         # Campaign phase management
│   └── campaign_data.lua        # Campaign state persistence
├── factions/
│   ├── faction_system.lua       # Faction management
│   ├── faction_lore_arc.lua     # Faction narrative progression
│   └── faction_behavior.lua     # Faction strategic AI
├── narrative/
│   ├── narrative_system.lua     # Event trigger and delivery
│   ├── narrative_events.lua     # Event definitions
│   ├── story_hooks.lua          # Interactive story elements
│   └── dialogue_system.lua      # Character dialogue
├── technology/
│   ├── technology_lore.lua      # Tech narrative info
│   └── research_narrative.lua   # Research story progression
└── characters/
    ├── character_system.lua     # Character management
    ├── relationships.lua        # Character relationship tracking
    └── character_arcs.lua       # Personal story progression
```

## Content Configuration

Lore content is defined through TOML files in `mods/core/`:

- `mods/core/lore/` - Campaign and faction lore
  - `campaigns.toml` - Campaign phase definitions
  - `campaign_events.toml` - Story events
- `mods/core/factions/` - Alien faction definitions
  - `sectoids.toml` - Sectoid faction profile
  - `mutons.toml` - Muton faction profile
  - `ethereals.toml` - Ethereal faction profile
- `mods/core/narrative/` - Narrative content
  - `narrative_events.toml` - Story events and triggers
  - `dialogue.toml` - Character dialogue
  - `story_hooks.toml` - Interactive narrative elements

## Campaign Progression

### Phase Transitions
- Automatically triggered by game time progression
- Can be advanced through research milestones
- Associated narrative events reveal new information
- New technologies and enemies unlock

### Phase Mechanics
Each phase introduces new gameplay elements:

**Phase 0 Mechanics:**
- Conventional weapons only
- Basic alien forces
- Small-scale operations
- Investigation missions

**Phase 1 Mechanics:**
- Laser weapons available
- Diverse alien units
- Global operations
- Combat escalation

**Phase 2 Mechanics:**
- Advanced weapons (Gauss, Sonic)
- Powerful alien forces
- Strategic depth increases
- High-stakes missions

**Phase 3 Mechanics:**
- Dimensional weapons
- Final alien forces
- Campaign climax missions
- Victory condition readiness

## Narrative System

### Event Triggers
- **Research Complete**: Narrative revelation upon tech discovery
- **First Contact**: New faction encountered
- **Mission Success/Failure**: Story reactions to battle outcomes
- **Time Milestone**: Campaign progression events
- **Reputation**: Narrative gates based on performance

### Event Delivery
- **Pop-up Messages**: Important story announcements
- **Character Dialogue**: Personnel conversations
- **Cinematics**: Animated story sequences
- **Mission Briefings**: Context for upcoming operations
- **After Action Reports**: Post-mission narrative reflections

## Faction Lore Arcs

Each faction has a multi-stage narrative:

**Faction Arc Structure:**
1. Initial appearance and characteristics
2. Strategic escalation and tactics
3. Revelation of purpose and goals
4. Confrontation and showdown
5. Aftermath and campaign impact

## Character System

### Character Types
- **Commanders**: Player-controlled leadership
- **Scientists**: Research and intelligence
- **Engineers**: Technical specialists
- **Soldiers**: Combat specialists
- **Allies**: External support and relationships

### Character Progression
- **Experience Gain**: Survive missions and complete objectives
- **Rank Promotion**: Advancement through military hierarchy
- **Skill Learning**: Acquire new combat abilities
- **Relationship Development**: Build connections with other characters
- **Personal Quests**: Character-specific missions and goals

## Themes and Tone

### Overall Tone
- **Sci-Fi Military**: Professional military operation against alien threat
- **Realism**: Consequences are significant and permanent
- **Heroism**: Player character agency and accomplishment
- **Tension**: Strategic pressure and resource scarcity
- **Mystery**: Gradual revelation of alien purpose

### Narrative Themes
- Humanity's resilience and adaptability
- Cost of warfare and sacrifice
- Scientific discovery and understanding
- Global cooperation and unity
- Hope against overwhelming odds

## Integration with Gameplay

### Story-Gameplay Integration
- Campaign phases gate content availability
- Narrative events provide mission context
- Faction lore affects AI behavior and tactics
- Character relationships affect morale
- Technology lore explains mechanical advantages

### Player Agency
- Decisions in missions affect story outcomes
- Faction priorities influence campaign direction
- Research choices determine technology availability
- Character relationships develop through gameplay
- Endings vary based on campaign performance

## Testing

Story content validation:

- Event trigger testing
- Campaign progression verification
- Faction behavior consistency
- Character relationship management
- Narrative coherence across phases
