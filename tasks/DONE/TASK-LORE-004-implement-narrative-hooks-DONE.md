# Narrative Hooks System - Implementation Complete

**Status:** DONE ✅  
**Completed:** October 16, 2025

## Overview

Implemented comprehensive narrative hooks system for dynamic storytelling throughout the game campaign. Delivers lore, strategic information, and world events through gameplay triggers.

## System Architecture

### Core System (`engine/lore/narrative_hooks.lua`)
The `NarrativeHooks` class manages all narrative delivery in the game:
- 250+ lines of production code
- Event triggering based on game state
- Encyclopedia integration for discovered lore
- Narrative thread tracking
- Save/load persistence

**Key Components:**
1. **Event Loading** - Import narrative events from mod TOML files
2. **Event Triggering** - Fire narratives on game events
3. **Encyclopedia** - Discover and read lore entries
4. **Effect Application** - Modify game state on narrative events
5. **Narrative Tracking** - Track active story threads

### Content System (`mods/core/lore/narrative/narrative_events.toml`)
Comprehensive narrative content with 10+ core story beats including:
- Technology discoveries (Laser, Plasma, Power Armor research)
- Alien intelligence (Sectoid psychology, Ethereal threat, Muton analysis)
- Mission narratives (Terror mission success, UFO recovery)
- Campaign phases (First Contact, War Escalation)

## Hook Types

### 1. Research Completion Hooks
Triggered when player completes technology research

**Example:** `narrative_laser_research`
- Triggered by: `research_laser_weapons` completion
- Unlocks: Plasma research, Power research
- Effects: Funding +500, Panic -10, new research paths

### 2. Interrogation Hooks
Triggered after successfully interrogating captured aliens

**Example:** `narrative_sectoid_weakness`
- Triggered by: Sectoid interrogation
- Unlocks: Psionic defense research, Sectoid defection option
- Effects: Strategic intel revealed, new countermeasure options

### 3. Mission Outcome Hooks
Triggered on mission success or failure

**Example:** `narrative_terror_mission_success`
- Triggered by: Terror mission victory
- Effects: Funding +1000, Panic -25, morale boost
- Encyclopedia: Record heroic defense

### 4. Phase Transition Hooks
Triggered when entering new campaign phase

**Example:** `narrative_phase_one_start`
- Triggered by: Transition to Phase 1
- Effects: Panic +50, Funding +5000
- Narrative: World has learned about aliens

### 5. Diplomatic Hooks
Triggered by country relations and events

**Design:** Infrastructure for country/faction diplomatic events

### 6. Facility Completion Hooks
Triggered when player completes major facilities

**Example:** `narrative_base_established`
- Triggered by: Main base completion
- Effects: Strategic information unlocked
- Narrative: Base operational and functional

## TOML Structure

### Narrative Event Definition
```toml
[[narrative_hook]]
id = "unique_event_id"
title = "Human-Readable Title"
trigger_type = "research_complete|interrogation_complete|mission_success|mission_failure|phase_transition|diplomatic_event|facility_complete"
trigger_id = "id_of_triggering_element"  # research_id, alien_type, mission_id, phase_number, etc.
description = "Short description"
lore_entry = """
Multi-line lore text displayed to player.
Can contain multiple paragraphs.
Should be 2-4 sentences per line.
"""
encyclopedia_category = "technology|lore|factions|missions|campaign|operations"
priority = 50  # Higher = more important (0-100)
unlocks = ["other_narrative_id"]  # Other narratives this unlocks
effects = {
    unlock_research = ["research_id"],
    funding_change = 1000,
    panic_change = -10,
    strategic_intel = "description",
}
```

## Narrative Events (Phase 0-1 Content)

### Research Discoveries (4 events)
| Event | Trigger | Category | Priority |
|-------|---------|----------|----------|
| Laser Technology Breakthrough | Laser research complete | Technology | 90 |
| Alien Plasma Mastery | Plasma research complete | Technology | 95 |
| Power Armor Development | Power armor research complete | Technology | 85 |
| Alien Biology Analysis | Alien biology research | Lore | 100 |

### Alien Intelligence (3 events)
| Event | Trigger | Category | Priority |
|-------|---------|----------|----------|
| Ethereal Hypothesis | Alien hierarchy research | Lore | 99 |
| Sectoid Weakness | Sectoid interrogation | Factions | 90 |
| Muton Warrior Analysis | Muton interrogation | Factions | 85 |

### Mission Narratives (2 events)
| Event | Trigger | Category | Priority |
|-------|---------|----------|----------|
| Heroic Defense | Terror mission success | Missions | 70 |
| Recovered UFO Technology | UFO crash recovery | Technology | 95 |

### Campaign Phases (2 events)
| Event | Trigger | Category | Priority |
|-------|---------|----------|----------|
| First Contact Protocol | Phase 1 transition | Campaign | 100 |
| War Escalation | Phase 2 transition | Campaign | 99 |

### Facility Narrative (1 event)
| Event | Trigger | Category | Priority |
|-------|---------|----------|----------|
| Operational Base Secured | Main base complete | Operations | 80 |

**Total:** 12 core narrative events

## Integration Points

### With Research System
- Research completion triggers lore discovery
- Interrogation intel reveals related research paths
- Encyclopedia categorizes technology discoveries

### With Campaign System
- Phase transitions trigger major story beats
- Campaign milestones unlock new narrative threads
- Mission outcomes advance story progression

### With AI & Factions
- Alien weaknesses discovered through research
- Interrogations reveal faction hierarchy and tactics
- Strategic information affects AI opponent behavior

### With UI/Display System
- Encyclopedia UI displays discovered lore entries
- Narrative notifications alert player to new story beats
- Encyclopedia browsing reveals game lore progressively

### With Difficulty System
- Narrative can adjust based on player success
- Discovery rates affected by progression speed
- Strategic information reveals based on player advancement

## Encyclopedia System

### Categories
- **Technology**: Weapons, armor, research discoveries
- **Lore**: Historical events, alien origins, universe background
- **Factions**: Alien faction behaviors, hierarchy, psychology
- **Missions**: Notable operations and their outcomes
- **Campaign**: Global events and phase transitions
- **Operations**: Base and organizational developments

### Encyclopedia Entry Example
```lua
{
    id = "narrative_laser_research",
    title = "Laser Technology Breakthrough",
    category = "technology",
    content = "Our scientists have successfully...",
    date_discovered = "2025-10-16",
}
```

### Encyclopedia Features
- Discover entries through gameplay
- Browse by category
- Search by keyword
- Track discovery date
- Progressive revelation of world lore

## Narrative Effects

### Game State Modifications
- **unlock_research**: New research options available
- **funding_change**: Gain/lose funding based on narrative
- **panic_change**: Global panic increases or decreases
- **strategic_intel**: New information about enemies/strategy

### Example Effect Application
```lua
-- Research unlocks
effects.unlock_research = ["research_plasma_weapons"]
-- Allows manufacturing plasma weapons immediately

-- Funding changes
effects.funding_change = 1000
-- Adds 1000 funding to organization

-- Panic modification
effects.panic_change = -10
-- Reduces global panic by 10 points

-- Strategic intelligence
effects.strategic_intel = "alien_command_structure"
-- Reveals info about how aliens are organized
```

## Files Created

| File | Content | Events |
|------|---------|--------|
| `engine/lore/narrative_hooks.lua` | Core narrative system | System implementation |
| `mods/core/lore/narrative/narrative_events.toml` | Phase 0-1 narrative content | 12 story events |

**Total:** 250 lines of Lua + 300+ lines of TOML content

## Usage Examples

### Loading Narrative Content
```lua
local NarrativeHooks = require("lore.narrative_hooks")
local narrative = NarrativeHooks:new()

-- Load from mod
local eventData = gameData.narrative_events
for id, data in pairs(eventData) do
    narrative:loadEvent(id, data)
end
```

### Triggering Narrative Events
```lua
-- Research completion triggers narrative
narrative:onResearchComplete("research_laser_weapons", gameState)

-- Interrogation triggers narrative
narrative:onInterrogation("sectoid_soldier", "Intelligence revealed", gameState)

-- Mission success
narrative:onMissionComplete("terror_mission_alpha", "success", gameState)

-- Phase transition
narrative:onPhaseTransition(2, gameState)
```

### Encyclopedia Access
```lua
-- Get all discovered lore
local entries = narrative:getEncyclopediaEntries()

-- Get entries by category
local tech = narrative:getEncyclopediaEntries("technology")
local lore = narrative:getEncyclopediaEntries("lore")

-- Check discovery count
local discovered = narrative:getDiscoveredCount()
```

### Checking Active Narratives
```lua
-- Check if narrative thread is active
if narrative:isNarrativeActive("narrative_ethereal_threat") then
    -- Player has discovered the Ethereal threat
    -- Can trigger new missions or options
end

-- Get all active narrative threads
local threads = narrative:getActiveNarrative()
```

## Design Philosophy

### Progressive Revelation
- Players discover world lore through gameplay
- Information unlocked naturally by progression
- Narrative builds on previous discoveries
- Strategic information advances understanding

### Consequence Feedback
- Player actions have narrative consequences
- Mission outcomes trigger appropriate narratives
- Research discoveries drive story forward
- Intelligence gathering reveals threats and opportunities

### World Coherence
- Narrative explains game mechanics
- Lore entries provide context for content
- Strategic information affects player decisions
- Encyclopedia creates unified game world

## Future Development

### Additional Narrative Content
1. **Phase 2-3 narratives** - Advanced alien technology discovery
2. **Faction-specific narratives** - Each alien faction has story arc
3. **Country relationships** - Diplomatic narrative arcs
4. **Character narratives** - Individual soldier stories
5. **Base development** - Facility-specific story beats
6. **Research failures** - Negative narratives from failed research

### Enhanced Narrative System
1. **Branching narratives** - Player choices affect story
2. **Conditional narratives** - Different narratives based on difficulty/choices
3. **Narrative consequences** - Long-term effects of story choices
4. **Character progression** - Soldier stories and development
5. **Dynamic narrative** - Story adjusts based on player performance

### UI/Display Enhancements
1. **Notification system** - Non-intrusive narrative popups
2. **Encyclopedia UI** - Full browsable lore database
3. **Timeline view** - See game events chronologically
4. **Narrative replay** - Review discovered lore

## Next Steps

1. ✅ Create narrative hooks system (Lua)
2. ✅ Create Phase 0-1 narrative content (TOML)
3. Integrate with UI for display
4. Create Phase 2-3 narrative content
5. Implement encyclopedia UI
6. Add branching narrative options
7. Create modding guide for custom narratives
8. Implement narrative consequences system
9. Add condition-based narrative variants
10. Create narrative testing suite

## Notes

All narrative follows consistent design:
- Clear cause-and-effect (trigger → event)
- Meaningful effects on game state
- Encyclopedia integration for lore discovery
- Modifiable through TOML for easy expansion
- Support for complex narrative chains through unlocks

Narrative system is designed for:
- Complete moddability
- Easy narrative expansion
- Multiple languages/localization
- Performance optimization (lazy loading)
- Save/load persistence
