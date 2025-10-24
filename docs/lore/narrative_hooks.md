# Narrative Hooks System - Dynamic Storytelling

**Status:** Implementation Complete
**Last Updated:** October 23, 2025
**Version:** 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
3. [Hook Types](#hook-types)
4. [Narrative Event Structure](#narrative-event-structure)
5. [Integration Points](#integration-points)
6. [Narrative Chains](#narrative-chains)
7. [Encyclopedia System](#encyclopedia-system)
8. [Best Practices](#best-practices)
9. [Modding Guide](#modding-guide)

---

## Overview

The Narrative Hooks system delivers dynamic storytelling through research discoveries, alien interrogations, mission outcomes, and diplomatic events. It transforms gameplay moments into narrative beats that drive the campaign forward, build the AlienFall universe, and affect strategic gameplay through lore revelations.

### System Goals

1. **Reveal Lore Dynamically** - Lore entries appear through gameplay, not cutscenes
2. **Gate Information** - Information revealed only when gameplay-appropriate
3. **Create Consequences** - Choices affect campaign narrative and available paths
4. **Build Encyclopedia** - Players build lore database through discovery
5. **Emotional Investment** - Narrative makes players care about mission outcomes

### Key Features

- **50+ Narrative Events** - Across 4 campaign phases
- **Multiple Trigger Types** - Research, interrogation, missions, diplomacy, phase transitions
- **Encyclopedia Building** - Discovered lore categorized and accessible
- **Branching Narratives** - Events unlock follow-up narrative chains
- **Persistent State** - Tracked in save files for continuity

---

## Core Concepts

### Narrative Hook

A discrete story moment triggered by specific game events.

**Properties:**
- `id` - Unique identifier (e.g., "narrative_laser_research")
- `title` - Display title shown to player
- `trigger_type` - What event triggers this (research, interrogation, mission, etc.)
- `trigger_id` - Specific item that triggers (e.g., "research_laser_weapons")
- `description` - Short summary
- `lore_entry` - Full lore text (displayed when triggered)
- `unlocks` - Follow-up narrative hooks unlocked
- `effects` - Game effects (research unlocks, funding changes, panic changes)
- `priority` - Display priority (1-100, higher = more important)

### Narrative Chain

Series of related hooks forming a story arc.

**Example Chain:**
1. "Alien Biology Analysis" (triggered by research completion)
   ↓ Unlocks
2. "Ethereal Hypothesis" (triggered when unlock becomes available)
   ↓ Unlocks
3. "Psionic Research Initiative" (triggered when conditions met)
   ↓ Unlocks
4. "Ethereal Countermeasures" (late-game hook)

### Encyclopedia Entry

Persistent lore entry added to in-game encyclopedia when hook triggers.

**Properties:**
- Entry title and category
- Discovery date
- Full lore text
- Related research/facilities (hyperlinks)

---

## Hook Types

### 1. Research Completion Hooks

**Trigger:** Research project completes
**Purpose:** Explain implications of technological breakthrough
**Example:** "Laser Technology Breakthrough" → discovered laser research unlocks plasma path

```toml
[[narrative_hook]]
id = "narrative_laser_research"
title = "Laser Technology Breakthrough"
trigger_type = "research_complete"
trigger_id = "research_laser_weapons"
lore_entry = """Our scientists have successfully reverse-engineered laser weapons..."""
unlocks = ["narrative_plasma_research", "narrative_power_research"]
effects = { unlock_research = ["research_advanced_systems"], funding_change = 500 }
```

**Common Research Hooks:**
- Weapon technology breakthroughs (laser, plasma, gauss, particle beam)
- Armor advancement milestones
- Vehicle/facility unlocks
- Alien understanding (biology, behavior, hierarchy)

### 2. Interrogation Hooks

**Trigger:** Successful interrogation of alien unit
**Purpose:** Reveal alien psychology, strategy, or lore
**Example:** "Sectoid Psychological Vulnerability" → reveals slaves under Ethereal control

```toml
[[narrative_hook]]
id = "narrative_sectoid_weakness"
title = "Sectoid Psychological Vulnerability"
trigger_type = "interrogation_complete"
trigger_id = "sectoid_soldier"
lore_entry = """Through interrogation, we discover Sectoids are enslaved by psychic control..."""
effects = { strategic_intel = "sectoid_psychology", unlock_research = ["research_psionic_defense"] }
```

**Common Interrogation Hooks:**
- Individual alien species psychology
- Command structure revelations
- Technological explanations
- Cultural/biological insights

### 3. Mission Outcome Hooks

**Trigger:** Mission completed (success or failure)
**Purpose:** Reflect mission consequences in campaign narrative
**Example:** "Heroic Defense" → successful terror mission raises morale

```toml
[[narrative_hook]]
id = "narrative_terror_mission_success"
title = "Heroic Defense"
trigger_type = "mission_success"
trigger_id = "terror_mission_alpha"
lore_entry = """Our forces successfully protected civilians..."""
effects = { funding_change = 1000, panic_change = -25 }
```

**Common Mission Hooks:**
- Terror mission success/failure
- UFO crash recovery
- Alien base assault results
- Milestone mission completion

### 4. Phase Transition Hooks

**Trigger:** Entering new campaign phase
**Purpose:** Major narrative turning points
**Example:** "First Contact Protocol Activated" → moves from Phase 0 to Phase 1

```toml
[[narrative_hook]]
id = "narrative_phase_one_start"
title = "First Contact Protocol Activated"
trigger_type = "phase_transition"
trigger_id = "phase_1"
lore_entry = """The time for covert operations has ended..."""
effects = { panic_change = 50, funding_change = 5000 }
```

**Phase Transition Hooks:**
- Phase 0→1: First alien contact revealed
- Phase 1→2: Aquatic threat discovered
- Phase 2→3: Dimensional breaches begin
- Phase 3: Endgame final assault

### 5. Diplomatic Hooks

**Trigger:** Faction/country diplomatic event
**Purpose:** Show political consequences of player actions
**Example:** "Political Support Grows" → after terror mission success

```toml
[[narrative_hook]]
id = "narrative_diplomatic_boost"
title = "Political Support Grows"
trigger_type = "diplomatic_event"
trigger_id = "country_usa_support"
lore_entry = """International support for our organization increases..."""
effects = { funding_change = 2000 }
```

**Common Diplomatic Hooks:**
- Funding approval from nations
- Faction relationship changes
- Political crisis responses
- Trade agreement negotiations

### 6. Discovery Hooks

**Trigger:** Facility built, artifact found, location explored
**Purpose:** Reveal world-building lore through exploration
**Example:** "Eldritc Artifact Discovered" → supernatural artifact lore reveal

```toml
[[narrative_hook]]
id = "narrative_artifact_discovery"
title = "Eldritch Artifact Discovered"
trigger_type = "discovery"
trigger_id = "artifact_nexus_core"
lore_entry = """An ancient artifact of unknown origin reveals hints of interdimensional access..."""
effects = { unlock_research = ["research_dimensional_theory"] }
```

---

## Narrative Event Structure

### Complete Event Definition

```toml
[[narrative_hook]]
# Unique identifier (required)
id = "narrative_laser_research"

# Display title (required)
title = "Laser Technology Breakthrough"

# Trigger configuration (required)
trigger_type = "research_complete"           # Hook type
trigger_id = "research_laser_weapons"        # Specific trigger

# Metadata (optional but recommended)
description = "Discovery of laser weapon technology"  # Short summary
encyclopedia_category = "technology"          # For organization
priority = 90                                 # Display priority (1-100)

# Narrative content (required for player-facing hooks)
lore_entry = """Full lore text displayed to player when triggered.
Can be multiple paragraphs. Contains discoveries, dialogue, or world-building."""

# Follow-up narratives (optional)
unlocks = ["narrative_plasma_research", "narrative_power_research"]

# Game effects (optional)
[narrative_hook.effects]
unlock_research = ["research_advanced_systems"]  # Tech unlocks
funding_change = 500                            # Funding delta
panic_change = -15                              # Panic delta (negative = relief)
strategic_intel = "alien_propulsion"            # Intelligence revealed
morale_change = 10                              # Troop morale delta
```

### Encyclopedia Categories

Organize lore for player discovery:

- **technology** - Weapon/armor/vehicle discoveries
- **lore** - World history and mythology
- **factions** - Human and alien organizations
- **species** - Alien species information
- **missions** - Notable battle records
- **operations** - Campaign milestone events
- **politics** - Diplomatic developments
- **general** - Miscellaneous discoveries

---

## Integration Points

### How Narrative Hooks Connect to Game Systems

#### Research System
When research completes:
```lua
ResearchManager.completeResearch(tech_id)
-- Should call:
NarrativeHooks:onResearchComplete(tech_id, gameState)
```

#### Interrogation System
When alien is interrogated:
```lua
InterrogationSystem.complete(alien_unit, intel_result)
-- Should call:
NarrativeHooks:onInterrogation(alien_type, intel, gameState)
```

#### Mission System
When mission resolves:
```lua
MissionSystem.complete(mission, outcome)
-- Should call:
NarrativeHooks:onMissionComplete(mission_id, outcome, gameState)
```

#### Campaign System
When campaign phase transitions:
```lua
CampaignManager.setPhase(newPhase)
-- Should call:
NarrativeHooks:onPhaseTransition(newPhase, gameState)
```

#### Facility System
When facility construction completes:
```lua
FacilitySystem.finishConstruction(facility)
-- Should call:
NarrativeHooks:onFacilityBuilt(facility_type)
```

---

## Narrative Chains

### Example Chain: Psionic Revelation

**Phase 1 - Early Game:**

1. **"Alien Biology Analysis"** (trigger: alien autopsy research)
   - Reveals Sectoid DNA is artificially engineered
   - Unlocks: "Ethereal Hypothesis"
   - Effect: +20 panic (disturbing discovery)

2. **"Ethereal Hypothesis"** (trigger: alien hierarchy research)
   - Reveals Ethereals control aliens psychically
   - Unlocks: "Sectoid Psychological Vulnerability", "Psionic Research Initiative"
   - Effect: unlock psionic research line

3. **"Sectoid Psychological Vulnerability"** (trigger: sectoid interrogation)
   - Reveals Sectoids are enslaved, controllable
   - Unlocks: "Sectoid Defection Possible", "Psionic Defense"
   - Effect: unlock psionic defense research

**Phase 2 - Mid Game:**

4. **"Psionic Training Protocol"** (trigger: psionic research complete)
   - First humans develop psionic abilities
   - Unlocks: "Ethereal Contact Theory"
   - Effect: unlock psionic soldiers

5. **"Ethereal Contact Theory"** (trigger: psionic soldiers achieve high level)
   - Theorizes direct contact with Ethereals possible
   - Unlocks: "Ethereal Capture Initiative"
   - Effect: +research priority for ethereal capture

**Phase 3 - Late Game:**

6. **"Ethereal Capture Success"** (trigger: ethereal unit captured)
   - Player successfully interrogates Ethereal master
   - Reveals dimensional gateway secrets
   - Unlocks: "Dimensional Theory", "Nexus Assault Plan"
   - Effect: unlock endgame content

### Strategic Impact

Players see that capturing different enemy types reveals different knowledge paths, making capture missions feel strategically meaningful beyond combat benefits.

---

## Encyclopedia System

### How Encyclopedia Works

1. **Hook Triggers** → Encyclopedia entry created
2. **Entry Added** → Category organized, date stamped
3. **Player Views** → Can browse discovered lore at any time
4. **Accumulation** → Over campaign, player builds complete lore database

### Encyclopedia Categories (Gameplay)

**Technology Category:**
- Weapon discoveries (laser, plasma, gauss)
- Armor breakthroughs
- Vehicle tech unlocks
- Facility innovations

**Species Category:**
- Sectoid Biology & Behavior
- Muton Tactics & Strength
- Ethereal Psychology & Powers
- Aquatic Species Adaptations
- Dimensional Beings

**Lore Category:**
- Ancient civilizations
- Interdimensional threats
- Alien civilization
- Reticulan Cabal mysteries
- Prophecies and warnings

**Factions Category:**
- Government responses
- Corporate involvement
- Black market operations
- Underground movements

---

## Best Practices

### Writing Good Narrative Hooks

1. **Match Tone to Content**
   - Technology discoveries: Technical, explanatory
   - Interrogations: Psychological, personal
   - Combat outcomes: Dramatic, consequential
   - Lore entries: World-building, mythic

2. **Show, Don't Tell**
   - ❌ "This research makes soldiers stronger"
   - ✅ "Combat reports indicate significantly improved survival rates. Soldiers report increased confidence and capability."

3. **Create Consequences**
   - Make lore discoveries affect gameplay
   - Link discoveries to future research paths
   - Use panic/morale changes to show impact

4. **Build Narrative Tension**
   - Early game: Confusion and unknowns
   - Mid game: Revelations and escalation
   - Late game: Existential threats and heroism

### Implementing Narrative Hooks

1. **Define Trigger Conditions**
   - When should this hook fire?
   - What prerequisites must be met?
   - Should it fire only once or multiple times?

2. **Create Meaningful Lore**
   - 2-5 sentences per entry (readable but substantive)
   - Reference previous discoveries
   - Suggest implications for future

3. **Link to Effects**
   - Research unlocks should make sense
   - Panic/funding changes should match narrative tone
   - Strategic intel should guide player decisions

4. **Test Narrative Flow**
   - Verify chain of discoveries makes sense
   - Ensure ordering is logical
   - Confirm unlocks feel earned

---

## Modding Guide

### Adding New Narrative Events

#### 1. Create Event Definition in TOML

```toml
[[narrative_hook]]
id = "narrative_custom_discovery"
title = "Custom Discovery Title"
trigger_type = "research_complete"          # or: interrogation_complete, mission_success, etc.
trigger_id = "research_custom_tech"
description = "Brief description for debug"
encyclopedia_category = "technology"
priority = 80

lore_entry = """Multi-paragraph lore text that appears when event triggers.
This is what the player sees. Write it in an engaging, world-building style.
Can reference previous discoveries or create questions."""

unlocks = ["narrative_follow_up_event"]
[narrative_hook.effects]
unlock_research = ["research_next_tech"]
funding_change = 500
panic_change = -10
```

#### 2. Add to Appropriate Phase File

- `mods/core/lore/narrative/narrative_events_phase0.toml` - Phase 0 events
- `mods/core/lore/narrative/narrative_events_phase1.toml` - Phase 1 events
- `mods/core/lore/narrative/narrative_events_phase2.toml` - Phase 2 events
- `mods/core/lore/narrative/narrative_events_phase3.toml` - Phase 3 events

Or add to `mods/core/lore/narrative/narrative_events.toml` for universal events.

#### 3. Integrate with Game System

If trigger is custom type:

```lua
-- In relevant game system
local NarrativeHooks = require("engine.lore.narrative_hooks")

-- When condition is met:
NarrativeHooks:onCustomEvent(custom_id, custom_data)
```

#### 4. Update Documentation

Add entry to appropriate mod documentation noting:
- Event ID and title
- What triggers it
- What it unlocks
- Any special conditions

### Trigger Type Reference

| Trigger Type | Called When | Example |
|---|---|---|
| `research_complete` | Research technology finishes | `research_laser_weapons` |
| `interrogation_complete` | Alien interrogation succeeds | `sectoid_soldier` |
| `autopsy_complete` | Alien autopsy finishes | `ethereal_master` |
| `mission_success` | Mission completes successfully | `terror_mission_alpha` |
| `mission_failure` | Mission fails | `ufo_assault_failed` |
| `phase_transition` | Campaign phase changes | `phase_2` |
| `diplomatic_event` | Faction/country event | `usa_funding_increase` |
| `facility_built` | Base facility completes | `research_lab` |
| `ufo_crash` | UFO crashes | `ufo_scout_ship` |
| `unit_captured` | Alien unit captured | `muton_commander` |
| `discovery` | Artifact/location discovered | `ancient_artifact` |

### Common Trigger IDs

**Research Triggers:**
- `research_laser_weapons`, `research_plasma_weapons`, `research_gauss_technology`
- `research_alien_biology`, `research_alien_hierarchy`, `research_ethereal_autopsy`
- `research_psionic_defense`, `research_dimensional_theory`

**Interrogation Triggers:**
- `sectoid_soldier`, `muton_commander`, `ethereal_master`
- `reticulan_cabal_member`, `aquatic_species_leader`

**Mission Triggers:**
- `terror_mission_*`, `ufo_crash_recovery`, `alien_base_assault`
- `deep_sea_infiltration`, `dimensional_breach_containment`

**Phase Triggers:**
- `phase_1` (First Contact), `phase_2` (Deep War)
- `phase_3` (Dimensional War), `endgame`

---

## Configuration Examples

### Example 1: Technology Chain

```toml
# Research -> Lore -> Research chain

[[narrative_hook]]
id = "narrative_gauss_research"
title = "Gauss Technology Mastery"
trigger_type = "research_complete"
trigger_id = "research_gauss_technology"
lore_entry = """Our engineers have developed electromagnetic rail technology..."""
unlocks = ["narrative_hypervelocity_weapons"]
effects = { unlock_research = ["research_hypersonic_weapons"], funding_change = 750 }

[[narrative_hook]]
id = "narrative_hypervelocity_weapons"
title = "Hypervelocity Ammunition Theory"
trigger_type = "discovery"
trigger_id = "gauss_ammunition_concept"
lore_entry = """Early gauss testing reveals potential for extreme velocity projectiles..."""
effects = { unlock_research = ["research_advanced_gauss"] }
```

### Example 2: Interrogation Discovery

```toml
[[narrative_hook]]
id = "narrative_muton_strength"
title = "Muton Physiology Study"
trigger_type = "interrogation_complete"
trigger_id = "muton_commander"
lore_entry = """Interrogation of captured Muton commander reveals genetic enhancement details..."""
effects = { strategic_intel = "muton_tactics", panic_change = 15 }
unlocks = ["narrative_genetic_modification_concern"]
```

### Example 3: Story Consequence

```toml
[[narrative_hook]]
id = "narrative_terror_response"
title = "Public Outcry"
trigger_type = "mission_failure"
trigger_id = "terror_mission_alpha"
lore_entry = """Failure to prevent alien attack leads to massive civilian casualties..."""
effects = { panic_change = 40, funding_change = -1000 }
```

---

## Conclusion

The Narrative Hooks system transforms AlienFall from pure strategy game into immersive science fiction campaign. By linking discoveries to gameplay moments, the system makes every research completion, interrogation, and mission feel narratively significant. Players build lore database through play, creating personalized story of their campaign.

**Key Design Philosophy:** Narrative should emerge from gameplay, never interrupt it. Lore appears when earned, not when forced.
