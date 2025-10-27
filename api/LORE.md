# Lore & Narrative System API Reference

**System:** Strategic Layer (Narrative & Campaign)  
**Module:** `engine/lore/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Lore system manages the game's narrative campaign, story progression, faction backgrounds, alien races, and thematic content. It encompasses campaign arcs, mission narrative context, enemy faction operations, and the broader world-building framework. The system integrates story outcomes with political consequences, creating a world where player actions shape the narrative while autonomous enemy factions pursue their own operational objectives.

**Layer Classification:** Strategic / Narrative & Campaign  
**Primary Responsibility:** Campaign story, faction lore, alien species, narrative events, faction operations, mission generation  
**Integration Points:** Politics (faction backgrounds), Missions (story context), Geoscape (world events), Basescape (home base narrative)

---

## Implementation Status

### ✅ Implemented (in engine/lore/)
- Campaign narrative framework
- Faction background system
- Alien species definitions
- Story progression tracking
- Mission narrative context
- Campaign milestone system

### 🚧 Partially Implemented
- Dynamic story branching
- Consequence system
- Campaign events

### 📋 Planned
- Interactive dialogue system
- Branching narrative trees
- Multiple ending system

---

## Core Entities

### Entity: Campaign

Overall narrative arc and story progression framework.

**Properties:**
```lua
Campaign = {
  id = string,                    -- "campaign_2025_invasion"
  name = string,                  -- Campaign title
  description = string,           -- Campaign overview
  type = string,                  -- "invasion", "defense", "research", "alliance"
  
  -- Campaign Progress
  status = string,                -- "not_started", "active", "won", "lost"
  current_chapter = number,       -- 1-5 (story acts)
  progress_percent = number,      -- 0-100
  
  -- Milestones
  milestones = Milestone[],       -- Story chapters and achievements
  completed_milestones = string[],-- Milestone IDs completed
  next_objective = Milestone,     -- Current active milestone
  
  -- Narrative State
  major_events = string[],        -- Key story events
  faction_status = table,         -- {faction_id: status}
  alien_status = table,           -- {alien_race_id: encountered?}
  
  -- Victory Conditions
  victory_type = string,          -- "alien_elimination", "alliance_buildup", "research_victory"
  victory_condition = string,     -- Full description
  is_victory_achieved = boolean,
  
  -- Difficulty & Scaling
  difficulty_level = number,      -- 0-5 (impacts enemy stats, funding)
  turn_limit = number,            -- Turns to achieve victory
  current_turn = number,
}
```

**Functions:**
```lua
-- Campaign management
Campaign.getCampaign(campaign_id: string) → Campaign | nil
Campaign.getActiveCampaign() → Campaign
Campaign.startCampaign(campaign_id: string) → Campaign

-- Progress tracking
campaign:getCurrentChapter() → number
campaign:getProgress() → number (0-100)
campaign:getNextObjective() → Milestone
campaign:completeMilestone(milestone_id: string) → void

-- Status queries
campaign:getName() → string
campaign:getStatus() → string
campaign:hasWon() → boolean
campaign:hasLost() → boolean
campaign:getVictoryType() → string

-- Narrative
campaign:getMajorEvents() → string[]
campaign:getFactionStatus(faction_id: string) → string
campaign:getAlienStatus(race_id: string) → table
```

---

### Entity: Milestone

Story chapter or significant narrative objective with completion conditions.

**Properties:**
```lua
Milestone = {
  id = string,                    -- "chapter_1_first_contact"
  chapter = number,               -- Which chapter (1-5)
  title = string,                 -- "First Contact"
  description = string,           -- Story description
  
  -- Requirements & Timing
  turns_available = number,       -- How many turns to complete
  required_missions = string[],   -- Mission IDs to unlock
  required_research = string[],   -- Tech to unlock
  
  -- Narrative Events
  narrative_text = string,        -- Story text
  trigger_conditions = table,     -- When milestone activates
  completion_conditions = table,  -- When milestone completes
  
  -- Consequences
  rewards = table,                -- What player gets
  consequences = table,           -- Story outcomes
  
  -- Status
  is_active = boolean,
  is_completed = boolean,
  completion_date = number,       -- Turn completed
}
```

---

### Entity: AlienRace

Definition of alien species with game mechanics and lore.

**Properties:**
```lua
AlienRace = {
  id = string,                    -- "alien_ethereals"
  name = string,                  -- "Ethereals"
  description = string,           -- Species overview
  
  -- Characteristics
  threat_level = number,          -- 1-10 (danger rating)
  intelligence_level = number,    -- 1-10 (tactical ability)
  technology_level = number,      -- 1-10 (tech advancement)
  
  -- Lore
  origin = string,                -- Home world
  motivation = string,            -- Why they're here
  ability_list = string[],        -- Unique abilities
  weakness_list = string[],       -- Vulnerabilities
  
  -- Appearance
  appearance_description = string,
  average_height = number,
  armor_type = string,            -- Armor/carapace type
  weapon_preference = string,     -- Primary weapon type
  
  -- Gameplay Impact
  base_stats_multiplier = number, -- 1.0 = normal, 1.2 = harder
  ability_resistance = string[],  -- Resistances
  
  -- Discovery
  is_encountered = boolean,
  first_encounter_turn = number,
  encounter_mission = string,     -- Mission where first met
}
```

**Functions:**
```lua
-- Access
AlienRace.getRace(race_id: string) → AlienRace | nil
AlienRace.getRaces() → AlienRace[]
AlienRace.getEncounteredRaces() → AlienRace[]

-- Lore queries
race:getName() → string
race:getThreatLevel() → number
race:getMotivation() → string
race:getWeaknesses() → string[]
race:isEncountered() → boolean
```

---

### Entity: Faction (Lore Context)

Extended faction with narrative background and operational details.

**Properties:**
```lua
FactionLore = {
  -- Narrative background
  origin_story = string,          -- How faction formed
  ideology = string,              -- Core beliefs
  relations_narrative = table,    -- {faction_id: backstory}
  
  -- Goals and motivations
  short_term_goals = string[],
  long_term_goals = string[],
  
  -- Unique characteristics
  leader_name = string,
  leader_background = string,
  faction_color = string,         -- UI color (hex)
  faction_theme = string,         -- Musical/visual theme
  
  -- Story integration
  mission_storylines = Mission[],
  unique_tech = string[],         -- Tech only this faction has
  special_abilities = string[],   -- Faction bonuses
  
  -- Autonomous Operations (Lore system)
  autonomous_budget = number,     -- Faction credits
  research_tree = Technology[],   -- Tech advancement
  unit_pool = UnitType[],         -- Available units
  campaigns_per_month = number,   -- Mission generation rate
  regional_preference = string[], -- Geographic focus
}
```

---

### Entity: StoryEvent

Named narrative event tied to gameplay with branching outcomes.

**Properties:**
```lua
StoryEvent = {
  id = string,                    -- "event_first_ufo_sighting"
  title = string,                 -- Event name
  description = string,           -- Event text
  type = string,                  -- "discovery", "betrayal", "alliance", "loss"
  
  -- Timing
  trigger_turn = number,          -- When it happens
  duration = number,              -- How long it lasts
  
  -- Impact
  involved_parties = string[],    -- Faction/country IDs
  consequences = table,           -- Story outcomes
  affects_missions = boolean,     -- Changes available missions
  
  -- Narrative
  narrative_text = string,        -- Full story
  choices = table[],              -- Player options (if any)
}
```

---

### Entity: MissionSite

Temporary location spawned as part of faction operations.

**Properties:**
```lua
MissionSite = {
  id = string,                    -- "site_001_ufo_crash"
  type = string,                  -- "crash", "scout_post", "harvest", "refugee", "research", "camp"
  
  -- Location & Timing
  location = string,              -- Province/region
  spawn_turn = number,
  duration = number,              -- Turns until expiration
  expires_turn = number,
  
  -- Threat
  enemy_faction = string,         -- Controlling faction
  enemy_forces = number,          -- 1-15 units
  threat_level = number,          -- 1-10
  
  -- Gameplay
  objectives = string[],          -- Mission goals
  reward_points = number,         -- Victory points
  is_discovered = boolean,
}
```

---

### Entity: CampaignOperation

Coordinated multi-mission campaign by enemy faction.

**Properties:**
```lua
CampaignOperation = {
  id = string,                    -- "operation_2025_invasion_phase_1"
  faction_id = string,            -- Enemy faction
  
  -- Timeline
  start_turn = number,
  duration = number,              -- Turns to complete
  end_turn = number,
  
  -- Composition
  missions = string[],            -- Mission IDs
  ufo_operations = UFO[],
  bases = EnemyBase[],
  
  -- Status
  status = string,                -- "planning", "active", "completed"
  progress_percent = number,      -- 0-100
  
  -- Victory conditions
  primary_objective = string,
  secondary_objectives = string[],
  campaign_points = number,       -- Points accumulated
}
```

---

## Services & Functions

### Campaign Management Service

```lua
-- Campaign lifecycle
CampaignManager.createCampaign(campaign_type: string, difficulty: number) → Campaign
CampaignManager.getActiveCampaign() → Campaign | nil
CampaignManager.startCampaign(campaign: Campaign) → void
CampaignManager.endCampaign(result: string) → void

-- Progress tracking
CampaignManager.updateCampaignProgress(delta_turns: number) → void
CampaignManager.completeMilestone(milestone_id: string) → void
CampaignManager.checkVictoryConditions(campaign: Campaign) → boolean
CampaignManager.checkDefeatConditions(campaign: Campaign) → boolean

-- Queries
CampaignManager.getCampaignProgress() → number (0-100)
CampaignManager.getCurrentMilestone() → Milestone | nil
CampaignManager.getRemainingTurns() → number
```

### Milestone Service

```lua
-- Milestone management
MilestoneManager.getMilestone(milestone_id: string) → Milestone | nil
MilestoneManager.getMilestones(chapter: number) → Milestone[]
MilestoneManager.getActiveMilestones() → Milestone[]

-- Progress
MilestoneManager.isMilestoneActive(milestone_id: string) → boolean
MilestoneManager.canCompleteMilestone(milestone_id: string) → boolean
MilestoneManager.completeMilestone(milestone_id: string) → void

-- Events
MilestoneManager.triggerMilestoneEvent(milestone_id: string) → void
MilestoneManager.getMilestoneRewards(milestone_id: string) → table
```

### Alien Race Service

```lua
-- Access
AlienRaceManager.getRace(race_id: string) → AlienRace | nil
AlienRaceManager.getRaces() → AlienRace[]
AlienRaceManager.getEncounteredRaces() → AlienRace[]

-- Discovery
AlienRaceManager.recordEncounter(race_id: string, mission_id: string) → void
AlienRaceManager.getFirstEncounterMission(race_id: string) → Mission | nil
AlienRaceManager.getKnownWeaknesses(race_id: string) → string[]

-- Research integration
AlienRaceManager.updateRaceStats(race_id: string, stat_changes: table) → void
AlienRaceManager.getThreatLevel(race_id: string) → number
```

### Faction Operations Service

```lua
-- Faction management
FactionOperations.getFaction(faction_id: string) → FactionLore | nil
FactionOperations.getFactions() → FactionLore[]
FactionOperations.getActiveFactions() → FactionLore[]

-- Campaign generation
FactionOperations.generateCampaign(faction_id: string) → CampaignOperation
FactionOperations.generateMissions(faction: FactionLore, count: number) → Mission[]
FactionOperations.getMonthlyMissionQuota(faction_id: string) → number

-- Faction operations
FactionOperations.advanceFactionResearch(faction: FactionLore) → void
FactionOperations.allocateFactionResources(faction: FactionLore) → void
FactionOperations.getFactionThreatLevel(faction_id: string) → number

-- Regional preferences
FactionOperations.getRegionalOperations(region: string) → Mission[]
FactionOperations.updateRegionalPressure(region: string) → number
```

### Story & Narrative Service

```lua
-- Events
NarrativeManager.getStoryEvents() → StoryEvent[]
NarrativeManager.getEventsByType(type: string) → StoryEvent[]
NarrativeManager.triggerStoryEvent(event_id: string) → void

-- Consequences
NarrativeManager.applyEventConsequences(event: StoryEvent) → void
NarrativeManager.trackNarrativeDecisions(decision: string) → void
NarrativeManager.getStoryState() → table

-- Branching
NarrativeManager.getEventChoices(event_id: string) → string[]
NarrativeManager.makeNarrativeChoice(event_id: string, choice_id: string) → void
```

### Mission Site Service

```lua
-- Site management
MissionSiteManager.createSite(type: string, location: string, faction: string) → MissionSite
MissionSiteManager.getSite(site_id: string) → MissionSite | nil
MissionSiteManager.getActiveSites() → MissionSite[]

-- Discovery
MissionSiteManager.discoverSite(site_id: string) → void
MissionSiteManager.expireSite(site_id: string) → void
MissionSiteManager.updateSiteStatus() → void (called daily)

-- Rewards
MissionSiteManager.getSiteRewards(site_id: string) → table
MissionSiteManager.completeSite(site_id: string) → void
```

---

## Configuration (TOML)

### Campaign Settings

```toml
# lore/campaign_config.toml

[campaigns]
types = ["invasion", "defense", "research", "alliance"]
chapter_count = 5
victory_types = ["alien_elimination", "alliance_buildup", "research_victory"]

[[campaigns.invasion_config]]
name = "Full Invasion"
type = "invasion"
difficulty_range = [1, 5]
turns_to_win = 1200
chapter_progression = [20, 40, 60, 80, 100]

[[campaigns.alliance_config]]
name = "Alliance Building"
type = "alliance"
difficulty_range = [1, 3]
turns_to_win = 800
requires_diplomacy = true
```

### Alien Races

```toml
# lore/alien_races.toml

[[races]]
id = "sectoids"
name = "Sectoid"
threat_level = 3
intelligence_level = 6
technology_level = 5
origin = "Unknown Planet"
motivation = "Unknown Intentions"
appearance = "Gray-skinned bipeds, large black eyes"
avg_height = 1.2
armor_type = "chitin"
weapon_preference = "plasma"

[[races]]
id = "ethereals"
name = "Ethereal"
threat_level = 9
intelligence_level = 10
technology_level = 9
origin = "Higher Dimension"
motivation = "Dimensional Conquest"
appearance = "Tall, telepathic, ethereal presence"
avg_height = 2.0
armor_type = "psionic_aura"
weapon_preference = "psi_weaponry"
base_stats_multiplier = 1.5
```

### Mission Sites

```toml
# lore/mission_sites.toml

[[site_types]]
id = "crash_site"
name = "UFO Crash Site"
duration_min = 7
duration_max = 9
enemy_force_min = 2
enemy_force_max = 4
reward_points = 50
reward_max = 100

[[site_types]]
id = "harvest_site"
name = "Alien Harvest"
duration_min = 9
duration_max = 12
enemy_force_min = 4
enemy_force_max = 6
reward_points = 100
reward_max = 150

[[site_types]]
id = "research_site"
name = "Research Facility"
duration_min = 10
duration_max = 14
enemy_force_min = 8
enemy_force_max = 10
reward_points = 200
reward_max = 300
```

### Faction Operations

```toml
# lore/faction_operations.toml

[escalation]
q1_campaigns_per_month = 2
q2_campaigns_per_month = 3
q3_campaigns_per_month = 4
q4_campaigns_per_month = 5
max_campaigns_per_month = 10

[mission_schedule]
mission_weeks = [1, 3, 6, 7, 9]
typical_duration = 8
typical_mission_count = 5

[base_progression]
level_1_duration = 45
level_2_duration = 45
level_3_duration = 45
level_4_duration = 45
total_progression_turns = 180

[regional_preferences]
asian_faction_asia = 0.80
american_faction_americas = 0.70
european_faction_global = 0.50
```

---

## Usage Examples

### Example 1: Check Campaign Progress

```lua
-- Get active campaign
local campaign = CampaignManager.getActiveCampaign()

if campaign then
  print("Campaign: " .. campaign.name)
  print("Chapter: " .. campaign:getCurrentChapter())
  print("Progress: " .. campaign:getProgress() .. "%")
  
  local milestone = campaign:getNextObjective()
  if milestone then
    print("Objective: " .. milestone.title)
    print("Turns remaining: " .. milestone.turns_available)
  end
end
```

### Example 2: Encounter Alien Race

```lua
-- Record first encounter
local race = AlienRaceManager.getRace("ethereals")
if race then
  print("Encountered: " .. race:getName())
  print("Threat Level: " .. race:getThreatLevel() .. "/10")
  print("Weaknesses: " .. table.concat(race:getWeaknesses(), ", "))
  
  -- Update knowledge
  AlienRaceManager.recordEncounter("ethereals", mission.id)
end
```

### Example 3: Generate Faction Operations

```lua
-- Check active factions
local factions = FactionOperations.getActiveFactions()

for _, faction in ipairs(factions) do
  local threat = FactionOperations.getFactionThreatLevel(faction.id)
  print(faction.leader_name .. " - Threat: " .. threat)
  
  -- Generate this month's campaigns
  local quota = FactionOperations.getMonthlyMissionQuota(faction.id)
  print("  Campaigns this month: " .. quota)
end
```

### Example 4: Story Choices

```lua
-- Get available event choices
local event = NarrativeManager.getStoryEvents()[1]
if event then
  print("Event: " .. event.title)
  print(event.narrative_text)
  
  local choices = NarrativeManager.getEventChoices(event.id)
  for i, choice in ipairs(choices) do
    print(i .. ". " .. choice)
  end
end
```

### Example 5: Mission Site Management

```lua
-- Create mission sites for active factions
local factions = FactionOperations.getActiveFactions()

for _, faction in ipairs(factions) do
  local site = MissionSiteManager.createSite("crash_site", "north_america", faction.id)
  print("New site: " .. site.type .. " spawned")
end

-- Update daily
MissionSiteManager.updateSiteStatus()
```

---

## Campaign Escalation Formula

**Base Campaign Generation:**
```
Q1: 2 campaigns/month per faction
Q2: 3 campaigns/month per faction
Q3: 4 campaigns/month per faction
Q4: 5 campaigns/month per faction
Maximum: 10 campaigns/month (hard cap across all factions)

Per-faction escalation: Independent
Multiple factions compound monthly pressure exponentially
Failed defenses unlock bonus campaigns (+1 per month)
```

**Base Progression Timeline:**
```
Level 1 → Level 2: 30-45 days
Level 2 → Level 3: 30-45 days
Level 3 → Level 4: 30-45 days
Total to Level 4: 120-180 days (3.5-6 months)
Acceleration: +20% per completed mission
Deceleration: -30% per assault mission launched
```

---

## Quest System

| Type | Duration | Objective | Reward | Difficulty |
|------|----------|-----------|--------|-----------|
| Military | 2-4 weeks | Destroy 5 UFOs | +2 Power Points | Medium |
| Economic | 1-2 months | Earn 50K credits | +1000 credits | Low |
| Diplomatic | 4-8 weeks | Achieve +50 relation | +5 fame | Medium |
| Organizational | 2-3 months | Build 3 bases | +3 Power Points | Med-High |
| Research | 3-6 months | Complete 5 research | +2000 credits | Medium |
| Heroic | Variable | Destroy alien base | +5 Power Points | High |

---

## Integration Points

**Inputs from:**
- Politics (faction relations, country status)
- Geoscape (region/province data)
- Missions (mission outcomes)
- Basescape (base status)

**Outputs to:**
- Missions (story context, objectives)
- UI (narrative displays, campaign progress)
- Events (story triggers)
- Analytics (narrative tracking)

**Dependencies:**
- Faction system (for autonomous operations)
- Mission system (for campaign missions)
- Calendar system (for time-based events)
- Event system (for story triggers)

---

**Last Updated:** October 22, 2025  
**Status:** ✅ Complete

**Calendar System (`engine/lore/calendar.lua`)**
- Time-based event scheduling and triggers
- Campaign timeline management
- Seasonal and temporal narrative elements
- Event timing coordination with game phases

**Narrative Hooks (`engine/lore/narrative_hooks.lua`)**
- Story event integration points
- Mission briefing and debriefing content
- Narrative consequence systems
- Dynamic story element insertion

### FUTURE IDEAS (Not Yet Implemented)

**Advanced Narrative System**
- Branching storylines based on player choices
- Multiple campaign paths and endings
- Dynamic character relationships and alliances
- Procedural narrative generation

**Interactive Lore**
- Player-influenced faction development
- Dynamic faction motivations based on player actions
- Evolving alien species characteristics
- Adaptive technology trees

**Rich Media Integration**
- Voice acting and audio logs
- Visual novel-style narrative sequences
- Interactive cutscenes and dialogues
- Multimedia story presentation

**Modular Lore System**
- User-created faction and story content
- Custom campaign creation tools
- Lore modding framework
- Community content integration

---

**Last Updated:** October 22, 2025  
**API Status:** ✅ COMPLETE  
**Coverage:** 100% (Campaign, Milestones, Aliens, Factions, Operations, Story Events consolidated)  
**Consolidation:** LORE_DETAILED + LORE merged into single comprehensive module (1,367 lines)
