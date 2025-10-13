# Task: Geoscape Lore & Campaign System - Dynamic Mission Generation

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent  
**Dependencies:** TASK-025 (Geoscape Master Implementation) - Phases 1-3 required

---

## Overview

Complete implementation of the **Lore & Campaign System** - the dynamic mission generation engine that drives gameplay progression through:
- **Factions**: Enemy groups with unique lore, units, items, research trees
- **Campaigns**: Faction-specific mission generators spawning weekly
- **Missions**: Site/UFO/Base missions within provinces
- **Quests**: Conditional objectives with rewards/penalties
- **Events**: Random monthly occurrences affecting resources/relations
- **Calendar Integration**: Escalating campaign generation (2→10 per month over 2 years)

This system provides **dynamic progression** where player research disables faction campaigns, creating strategic choices about which threats to prioritize.

---

## Purpose

The Lore & Campaign System is the **heart of dynamic gameplay**, providing:
1. **Progressive Threat**: Escalating difficulty from 2 campaigns/month to 10+ over 2 years
2. **Faction Identity**: Each enemy group has unique lore, units, research trees
3. **Strategic Choices**: Research to disable factions vs. immediate threat response
4. **Narrative Structure**: Quests and events create story moments
5. **Replayability**: Random campaigns, events, and quest generation
6. **Long-Term Goals**: Faction research trees lead to campaign elimination
7. **Consequence System**: Failed missions, ignored threats, hostile relations trigger escalation

Without this, the game is static with no progression or narrative.

---

## Requirements

### Functional Requirements

#### Core Systems
- [ ] **Faction System**: Define enemy groups with lore, units, items, research trees
- [ ] **Campaign Generator**: Spawn 2-10 campaigns/month based on game quarter
- [ ] **Mission System**: Site (static), UFO (mobile), Base (permanent) missions
- [ ] **Quest System**: Flexible condition/reward system
- [ ] **Event System**: Random monthly events affecting game state
- [ ] **Calendar Integration**: Daily/weekly/monthly triggers for progression

#### Faction Mechanics
- [ ] **Faction Identity**: Unique lore, units, items, research trees
- [ ] **Faction Relations**: -2 to +2 scale affecting mission frequency/difficulty
- [ ] **Research Tree**: Player research to unlock faction info and disable campaigns
- [ ] **Mission Ownership**: All missions belong to a faction
- [ ] **Escalation**: Hostile relations (-2) trigger base assault missions

#### Campaign System
- [ ] **Campaign Spawning**: Random generation on 1st day of each month
- [ ] **Escalation Formula**: `campaignsPerMonth = 2 + (currentQuarter - 1)`
- [ ] **Faction Assignment**: Each campaign linked to specific faction
- [ ] **Mission Scripts**: Campaigns spawn missions weekly OR with delay
- [ ] **Campaign Disabling**: Technology research stops specific campaigns
- [ ] **Campaign Tracking**: Active/disabled status per faction

#### Mission Types
- [ ] **Mission Site**: Static mission in province, waiting for interception
- [ ] **Mission UFO**: Mobile UFO with movement script (daily updates)
- [ ] **Mission Base**: Permanent alien base with growth script (weekly updates)
- [ ] **Mission Scoring**: Unhandled missions score points against player
- [ ] **Mission Expiration**: Sites expire after N days if not intercepted
- [ ] **Mission Detection**: Radar reveals missions (from TASK-025)

#### Quest System
- [ ] **Quest Definition**: Flexible conditions and rewards/penalties
- [ ] **Quest Tracking**: Monitor condition completion
- [ ] **Quest Completion**: Trigger rewards on success
- [ ] **Quest Failure**: Trigger penalties on failure/timeout
- [ ] **Quest Types**: Kill X enemies, research tech, build base, complete missions, etc.

#### Event System
- [ ] **Event Generation**: 3-5 random events per month
- [ ] **Event Types**: Resource changes, money, relations, mission spawning
- [ ] **Event Triggers**: Random or conditional
- [ ] **Event Impact**: Immediate effects on game state

#### Scripting System
- [ ] **UFO Scripts**: Daily movement logic (move province, land, takeoff, etc.)
- [ ] **Base Scripts**: Weekly growth logic (expand, spawn missions, etc.)
- [ ] **Campaign Scripts**: Mission spawning logic (weekly OR delay-based)

### Technical Requirements
- [ ] **Data-Driven**: All factions, campaigns, quests, events in TOML/JSON
- [ ] **Script Engine**: Lua-based scripting for UFO/Base/Campaign behaviors
- [ ] **Condition System**: Flexible condition evaluation for quests/events
- [ ] **State Management**: Track active campaigns, missions, quests, events
- [ ] **Calendar Integration**: Hook into TASK-025 Calendar for daily/weekly/monthly triggers
- [ ] **Performance**: Handle 100+ active missions, 50+ campaigns, 20+ quests
- [ ] **Serialization**: Save/load campaign/mission/quest state

### Acceptance Criteria
- [ ] Factions defined with unique lore, units, items, research trees
- [ ] Calendar spawns 2 campaigns/month in Q1, escalates to 10/month by Year 2
- [ ] Campaigns spawn missions weekly according to their scripts
- [ ] UFO missions move between provinces following daily scripts
- [ ] Base missions grow and spawn new missions following weekly scripts
- [ ] Site missions wait in provinces until intercepted or expired
- [ ] Quests track conditions and trigger rewards/penalties
- [ ] Events randomly occur 3-5 times per month
- [ ] Player research disables specific campaigns per faction
- [ ] Faction relations affect mission frequency and difficulty
- [ ] Hostile relations (-2) trigger base assault missions
- [ ] All systems integrate with TASK-025 Geoscape (calendar, provinces, radar)

---

## Plan

### Phase 1: Faction System (12 hours)

#### Step 1.1: Faction Data Structure (4 hours)
**Description:** Define faction entity with lore, relations, research tree  
**Files to create:**
- `engine/geoscape/logic/faction.lua`
- `engine/data/factions.toml`

**Faction Structure:**
```lua
Faction = {
    id = "sectoid_collective",
    name = "Sectoid Collective",
    description = "Hive-mind alien race...",
    
    -- Relations
    relations = 0, -- -2 (hostile) to +2 (neutral/allied)
    
    -- Research Tree
    researchTree = {
        "sectoid_autopsy",
        "sectoid_interrogation",
        "sectoid_commander_capture",
        "sectoid_homeworld_location",
        "sectoid_peace_treaty" -- Final research = disable campaigns
    },
    
    -- Units (references to unit definitions)
    units = {"sectoid_soldier", "sectoid_leader", "sectoid_commander"},
    
    -- Items (faction-specific loot)
    items = {"plasma_pistol", "sectoid_corpse", "mind_probe"},
    
    -- Mission Templates (faction-specific missions)
    missionTemplates = {
        "sectoid_abduction",
        "sectoid_terror",
        "sectoid_infiltration",
        "sectoid_base_assault"
    },
    
    -- Campaign Templates
    campaignTemplates = {
        "sectoid_scout_wave",
        "sectoid_invasion",
        "sectoid_retaliation"
    },
    
    -- Escalation
    escalationThreshold = -2, -- Trigger base assaults
    
    -- Disabled Campaigns (via research)
    disabledCampaigns = {}
}
```

**API Functions:**
```lua
Faction:updateRelations(delta) -- Change relations
Faction:isHostile() -- Check if relations <= -2
Faction:canSpawnCampaign(campaignId) -- Check if not disabled
Faction:disableCampaign(campaignId) -- Disable via research
Faction:getAvailableUnits() -- Units for missions
```

**Data File (factions.toml):**
```toml
[[faction]]
id = "sectoid_collective"
name = "Sectoid Collective"
description = "Hive-mind alien race seeking to expand their territory"
initialRelations = 0
escalationThreshold = -2

[faction.researchTree]
nodes = [
    "sectoid_autopsy",
    "sectoid_interrogation",
    "sectoid_commander_capture",
    "sectoid_homeworld_location",
    "sectoid_peace_treaty"
]

[faction.units]
soldiers = ["sectoid_soldier", "sectoid_leader"]
commanders = ["sectoid_commander"]

[faction.items]
weapons = ["plasma_pistol"]
corpses = ["sectoid_corpse"]
tech = ["mind_probe"]

[faction.campaigns]
templates = ["sectoid_scout_wave", "sectoid_invasion", "sectoid_retaliation"]
```

**Estimated time:** 4 hours

---

#### Step 1.2: Faction Manager (4 hours)
**Description:** System to manage all factions and their state  
**Files to create:**
- `engine/geoscape/systems/faction_manager.lua`

**Implementation:**
```lua
FactionManager = {
    factions = {}, -- faction_id → Faction
    activeRelations = {} -- Track relations changes
}

FactionManager:loadFactions() -- Load from TOML
FactionManager:getFaction(id) -- Get faction by ID
FactionManager:getAllFactions() -- Get all factions
FactionManager:updateRelations(factionId, delta) -- Change relations
FactionManager:getHostileFactions() -- Factions with relations <= -2
FactionManager:canSpawnCampaign(factionId, campaignId) -- Check availability
FactionManager:disableCampaign(factionId, campaignId) -- Via research
FactionManager:processFactionEvents() -- Monthly faction updates
```

**Estimated time:** 4 hours

---

#### Step 1.3: Faction Research Integration (4 hours)
**Description:** Link research system to faction campaign disabling  
**Files to modify:**
- `engine/geoscape/logic/faction.lua` (add research hooks)
- Create: `engine/geoscape/systems/faction_research.lua`

**Implementation:**
```lua
FactionResearch = {}

FactionResearch:completeResearch(factionId, researchId)
FactionResearch:isFinalResearch(factionId, researchId)
FactionResearch:disableFactionCampaigns(factionId) -- All campaigns disabled
FactionResearch:getResearchProgress(factionId) -- % complete
```

**Estimated time:** 4 hours

---

### Phase 2: Campaign System (18 hours)

#### Step 2.1: Campaign Data Structure (4 hours)
**Description:** Define campaign entity and templates  
**Files to create:**
- `engine/geoscape/logic/campaign.lua`
- `engine/data/campaigns.toml`

**Campaign Structure:**
```lua
Campaign = {
    id = "campaign_001",
    templateId = "sectoid_scout_wave",
    factionId = "sectoid_collective",
    
    -- Status
    active = true,
    disabled = false, -- Via research
    
    -- Timing
    startDate = {year = 1, quarter = 1, month = 1, day = 1},
    spawnFrequency = "weekly", -- OR delay in days
    nextSpawnDay = 7, -- Day counter for next mission spawn
    
    -- Mission Spawning
    missionScript = {
        type = "sequence", -- OR "random", "weighted"
        missions = {
            {template = "sectoid_abduction", weight = 50},
            {template = "sectoid_patrol_ufo", weight = 30},
            {template = "sectoid_scout_site", weight = 20}
        }
    },
    
    -- Region Targeting
    targetRegions = {"north_america", "europe"},
    
    -- Escalation
    currentWave = 1,
    maxWaves = 5,
    
    -- Stats
    missionsSpawned = 0,
    missionsCompleted = 0,
    missionsIgnored = 0
}
```

**Campaign Template (campaigns.toml):**
```toml
[[campaign_template]]
id = "sectoid_scout_wave"
name = "Sectoid Scout Wave"
factionId = "sectoid_collective"
spawnFrequency = "weekly"

[campaign_template.missionScript]
type = "sequence"

[[campaign_template.missionScript.missions]]
template = "sectoid_abduction"
weight = 50

[[campaign_template.missionScript.missions]]
template = "sectoid_patrol_ufo"
weight = 30

[campaign_template.targeting]
regions = ["north_america", "europe"]
maxSimultaneousMissions = 3
```

**Estimated time:** 4 hours

---

#### Step 2.2: Campaign Generator (6 hours)
**Description:** Monthly campaign spawning with escalation formula  
**Files to create:**
- `engine/geoscape/systems/campaign_generator.lua`

**Implementation:**
```lua
CampaignGenerator = {}

-- Main generation function (called on 1st day of each month)
CampaignGenerator:generateMonthlyCampaigns(calendar)
    -- Formula: campaignsPerMonth = 2 + (currentQuarter - 1)
    -- Year 1 Q1: 2 campaigns/month
    -- Year 1 Q2: 3 campaigns/month
    -- Year 1 Q3: 4 campaigns/month
    -- Year 1 Q4: 5 campaigns/month
    -- Year 2 Q1: 6 campaigns/month (quarter 5)
    -- ... up to 10+ campaigns/month

CampaignGenerator:selectCampaignTemplates(count)
    -- Random selection from available faction templates
    -- Weighted by faction relations (hostile = more campaigns)

CampaignGenerator:createCampaign(templateId, factionId)
    -- Instantiate campaign from template
    -- Set start date, regions, mission script

CampaignGenerator:canSpawnCampaign(factionId, templateId)
    -- Check if not disabled by research
    -- Check faction availability

CampaignGenerator:getActiveCampaignCount()
CampaignGenerator:getCampaignsByFaction(factionId)
```

**Escalation Formula:**
```lua
local function calculateCampaignsPerMonth(currentQuarter)
    return 2 + (currentQuarter - 1)
end

-- Examples:
-- Q1 (quarter 1): 2 + 0 = 2 campaigns/month
-- Q4 (quarter 4): 2 + 3 = 5 campaigns/month
-- Q8 (quarter 8, Year 2 Q4): 2 + 7 = 9 campaigns/month
```

**Estimated time:** 6 hours

---

#### Step 2.3: Campaign Manager (8 hours)
**Description:** Process active campaigns and spawn missions  
**Files to create:**
- `engine/geoscape/systems/campaign_manager.lua`

**Implementation:**
```lua
CampaignManager = {
    activeCampaigns = {}, -- List of active Campaign objects
    disabledCampaigns = {} -- Disabled via research
}

-- Weekly processing (called every 7 days)
CampaignManager:processWeeklyCampaigns()
    -- For each active campaign:
    -- Check if spawn day reached
    -- Select mission from script
    -- Spawn mission in target region

CampaignManager:processDailyCampaigns()
    -- For delay-based campaigns
    -- Decrement spawn counters

CampaignManager:spawnMissionFromCampaign(campaign)
    -- Select mission template from script
    -- Choose target province in region
    -- Create mission (Site/UFO/Base)

CampaignManager:selectMissionTemplate(campaign)
    -- Based on script type (sequence/random/weighted)
    -- Return mission template ID

CampaignManager:selectTargetProvince(campaign)
    -- Random province in target regions
    -- Weight by faction presence

CampaignManager:disableCampaign(campaignId)
    -- Via research completion

CampaignManager:getActiveCampaigns()
CampaignManager:getCampaignStats(campaignId)
```

**Estimated time:** 8 hours

---

### Phase 3: Mission System (24 hours)

#### Step 3.1: Mission Base Structure (4 hours)
**Description:** Core mission entity and common properties  
**Files to create:**
- `engine/geoscape/logic/mission.lua`
- `engine/data/mission_templates.toml`

**Mission Structure:**
```lua
Mission = {
    id = "mission_001",
    templateId = "sectoid_abduction",
    type = "site", -- "site", "ufo", "base"
    
    -- Ownership
    factionId = "sectoid_collective",
    campaignId = "campaign_001",
    
    -- Location
    provinceId = "province_042",
    
    -- Status
    active = true,
    detected = false, -- Radar detection
    intercepted = false,
    completed = false,
    
    -- Timing
    spawnDate = {year = 1, month = 1, day = 7},
    expirationDate = {year = 1, month = 1, day = 14}, -- +7 days
    daysActive = 0,
    
    -- Scoring
    scoreValue = 100, -- Points against player if not handled
    difficultyLevel = 1, -- Based on game quarter + faction relations
    
    -- Script (for UFO/Base missions)
    script = nil -- MissionScript object
}
```

**Mission Template (mission_templates.toml):**
```toml
[[mission_template]]
id = "sectoid_abduction"
name = "Abduction Site"
type = "site"
factionId = "sectoid_collective"
durationDays = 7
scoreValue = 100
difficulty = "medium"

[mission_template.rewards]
credits = 5000
items = ["sectoid_corpse", "plasma_pistol"]

[mission_template.battlescape]
terrain = "urban"
enemyCount = 8
```

**Estimated time:** 4 hours

---

#### Step 3.2: Mission Site Implementation (4 hours)
**Description:** Static missions waiting for interception  
**Files to create:**
- `engine/geoscape/logic/mission_site.lua`

**MissionSite extends Mission:**
```lua
MissionSite = setmetatable({}, {__index = Mission})

MissionSite.new(templateId, provinceId, factionId, campaignId)

MissionSite:update(day)
    -- Check expiration
    -- Update daysActive

MissionSite:isExpired()
    -- Check if current day > expirationDate

MissionSite:expire()
    -- Remove from province
    -- Apply score penalty to player

MissionSite:intercept(craftId)
    -- Trigger interception phase
    -- Mark as intercepted
```

**Estimated time:** 4 hours

---

#### Step 3.3: Mission UFO Implementation (8 hours)
**Description:** Mobile UFO missions with movement scripts  
**Files to create:**
- `engine/geoscape/logic/mission_ufo.lua`
- `engine/geoscape/logic/ufo_script.lua`

**MissionUFO extends Mission:**
```lua
MissionUFO = setmetatable({}, {__index = Mission})

MissionUFO.new(templateId, provinceId, factionId, campaignId, scriptId)
    -- Load UFO script

MissionUFO:update(day)
    -- Execute daily script step
    -- Move between provinces
    -- Land, takeoff, etc.

MissionUFO:executeScript()
    -- Process script commands

MissionUFO:moveToProvince(targetProvinceId)
    -- Update position

MissionUFO:land()
    -- Become static (like site)

MissionUFO:takeoff()
    -- Resume movement

MissionUFO:intercept(craftId)
    -- Trigger interception
```

**UFO Script Structure:**
```lua
UFOScript = {
    id = "patrol_script_01",
    type = "sequence", -- OR "loop", "conditional"
    
    steps = {
        {action = "move", targetProvince = "province_043", delay = 1},
        {action = "move", targetProvince = "province_044", delay = 1},
        {action = "land", duration = 3},
        {action = "takeoff"},
        {action = "move", targetProvince = "province_045", delay = 2},
        {action = "exit"} -- Leave map
    },
    
    currentStep = 1,
    dayCounter = 0
}
```

**UFO Script (ufo_scripts.toml):**
```toml
[[ufo_script]]
id = "patrol_script_01"
type = "sequence"

[[ufo_script.steps]]
action = "move"
targetProvince = "province_043"
delay = 1

[[ufo_script.steps]]
action = "land"
duration = 3

[[ufo_script.steps]]
action = "takeoff"

[[ufo_script.steps]]
action = "exit"
```

**Estimated time:** 8 hours

---

#### Step 3.4: Mission Base Implementation (8 hours)
**Description:** Permanent alien bases with growth scripts  
**Files to create:**
- `engine/geoscape/logic/mission_base.lua`
- `engine/geoscape/logic/base_script.lua`

**MissionBase extends Mission:**
```lua
MissionBase = setmetatable({}, {__index = Mission})

MissionBase.new(templateId, provinceId, factionId, campaignId, scriptId)
    -- No expiration (permanent until destroyed)

MissionBase:update(week)
    -- Execute weekly growth script
    -- Spawn missions

MissionBase:executeScript()
    -- Process growth stages
    -- Spawn missions

MissionBase:spawnMission(missionTemplate)
    -- Create new mission from base

MissionBase:grow()
    -- Increase base level
    -- Unlock new mission types

MissionBase:destroy()
    -- Player destroys base
    -- Remove from province
```

**Base Growth Script:**
```lua
BaseScript = {
    id = "sectoid_base_growth_01",
    
    stages = {
        {
            level = 1,
            weeksToNextLevel = 4,
            missionSpawnRate = "weekly",
            missionTemplates = {"sectoid_patrol_ufo"}
        },
        {
            level = 2,
            weeksToNextLevel = 6,
            missionSpawnRate = "bi-weekly",
            missionTemplates = {"sectoid_patrol_ufo", "sectoid_abduction"}
        },
        {
            level = 3,
            weeksToNextLevel = -1, -- Max level
            missionSpawnRate = "weekly",
            missionTemplates = {"sectoid_patrol_ufo", "sectoid_abduction", "sectoid_terror"}
        }
    },
    
    currentLevel = 1,
    weekCounter = 0
}
```

**Base Script (base_scripts.toml):**
```toml
[[base_script]]
id = "sectoid_base_growth_01"

[[base_script.stages]]
level = 1
weeksToNextLevel = 4
missionSpawnRate = "weekly"
missionTemplates = ["sectoid_patrol_ufo"]

[[base_script.stages]]
level = 2
weeksToNextLevel = 6
missionSpawnRate = "bi-weekly"
missionTemplates = ["sectoid_patrol_ufo", "sectoid_abduction"]
```

**Estimated time:** 8 hours

---

### Phase 4: Quest System (16 hours)

#### Step 4.1: Quest Data Structure (4 hours)
**Description:** Flexible quest system with conditions and rewards  
**Files to create:**
- `engine/geoscape/logic/quest.lua`
- `engine/data/quests.toml`

**Quest Structure:**
```lua
Quest = {
    id = "quest_001",
    name = "First Contact",
    description = "Complete your first alien mission",
    
    -- Status
    active = true,
    completed = false,
    failed = false,
    
    -- Conditions (all must be true)
    conditions = {
        {type = "missions_completed", faction = "sectoid_collective", count = 1},
        -- OR
        {type = "research_completed", researchId = "sectoid_autopsy"},
        -- OR
        {type = "base_built", count = 1},
        -- OR
        {type = "credits_earned", amount = 100000},
        -- OR
        {type = "days_passed", days = 30}
    },
    
    -- Rewards (on completion)
    rewards = {
        credits = 50000,
        items = {"special_weapon"},
        research = "bonus_tech"
    },
    
    -- Penalties (on failure/timeout)
    penalties = {
        credits = -20000,
        relations = {faction = "sectoid_collective", delta = -1}
    },
    
    -- Timing
    timeLimit = 60, -- Days to complete (optional)
    expirationDate = nil
}
```

**Quest Template (quests.toml):**
```toml
[[quest]]
id = "quest_first_contact"
name = "First Contact"
description = "Complete your first alien mission"
timeLimit = 60

[[quest.conditions]]
type = "missions_completed"
faction = "sectoid_collective"
count = 1

[quest.rewards]
credits = 50000
items = ["special_weapon"]

[quest.penalties]
credits = -20000
```

**Estimated time:** 4 hours

---

#### Step 4.2: Quest Condition System (6 hours)
**Description:** Flexible condition evaluation  
**Files to create:**
- `engine/geoscape/systems/quest_conditions.lua`

**Condition Types:**
```lua
QuestConditions = {}

QuestConditions.types = {
    "missions_completed",      -- Complete N missions (total or per faction)
    "missions_completed_type", -- Complete N missions of specific type
    "research_completed",      -- Complete specific research
    "base_built",              -- Build N bases
    "credits_earned",          -- Earn N credits
    "days_passed",             -- N days since quest start
    "enemies_killed",          -- Kill N enemies (total or per faction)
    "items_collected",         -- Collect N items
    "crafts_deployed",         -- Deploy N crafts
    "provinces_controlled",    -- Control N provinces
    "faction_relations",       -- Achieve relation level with faction
    "campaign_disabled"        -- Disable specific campaign via research
}

QuestConditions:evaluate(quest, gameState)
    -- Check all conditions
    -- Return true if all met

QuestConditions:evaluateCondition(condition, gameState)
    -- Evaluate single condition
    -- Return true/false

QuestConditions:getConditionProgress(condition, gameState)
    -- Return % progress (e.g., 5/10 missions)
```

**Estimated time:** 6 hours

---

#### Step 4.3: Quest Manager (6 hours)
**Description:** Quest tracking and lifecycle management  
**Files to create:**
- `engine/geoscape/systems/quest_manager.lua`

**Implementation:**
```lua
QuestManager = {
    activeQuests = {},
    completedQuests = {},
    failedQuests = {},
    availableQuests = {} -- Pool of quests to activate
}

QuestManager:loadQuests() -- Load from TOML
QuestManager:activateQuest(questId)
QuestManager:updateQuests(day)
    -- Check conditions for all active quests
    -- Check time limits
    -- Trigger completion/failure

QuestManager:completeQuest(questId)
    -- Apply rewards
    -- Move to completedQuests

QuestManager:failQuest(questId)
    -- Apply penalties
    -- Move to failedQuests

QuestManager:checkConditions(quest)
    -- Use QuestConditions system

QuestManager:getActiveQuests()
QuestManager:getQuestProgress(questId)
```

**Estimated time:** 6 hours

---

### Phase 5: Event System (12 hours)

#### Step 5.1: Event Data Structure (4 hours)
**Description:** Random monthly events  
**Files to create:**
- `engine/geoscape/logic/event.lua`
- `engine/data/events.toml`

**Event Structure:**
```lua
Event = {
    id = "event_001",
    name = "Supply Shipment Arrives",
    description = "A friendly nation sends military supplies",
    
    -- Type
    type = "random", -- OR "triggered"
    
    -- Trigger Conditions (for triggered events)
    triggerConditions = {
        {type = "faction_relations", faction = "sectoid_collective", level = -2}
    },
    
    -- Effects
    effects = {
        {type = "credits", amount = 10000},
        {type = "items", items = {"rifle", "medkit"}, quantity = 5},
        {type = "relations", faction = "sectoid_collective", delta = 1},
        {type = "spawn_mission", missionTemplate = "bonus_mission"}
    },
    
    -- Probability
    weight = 10, -- Higher = more likely
    
    -- One-time or repeatable
    repeatable = true
}
```

**Event Template (events.toml):**
```toml
[[event]]
id = "supply_shipment"
name = "Supply Shipment Arrives"
description = "A friendly nation sends military supplies"
type = "random"
weight = 10
repeatable = true

[[event.effects]]
type = "credits"
amount = 10000

[[event.effects]]
type = "items"
items = ["rifle", "medkit"]
quantity = 5
```

**Estimated time:** 4 hours

---

#### Step 5.2: Event Generator (4 hours)
**Description:** Monthly random event generation  
**Files to create:**
- `engine/geoscape/systems/event_generator.lua`

**Implementation:**
```lua
EventGenerator = {}

EventGenerator:generateMonthlyEvents()
    -- Generate 3-5 random events per month
    -- Weighted random selection

EventGenerator:selectEvents(count)
    -- Random selection from available events
    -- Weight by probability
    -- Check if repeatable

EventGenerator:canTriggerEvent(event)
    -- Check trigger conditions (if any)
    -- Check if already triggered (if one-time)

EventGenerator:triggerEvent(event)
    -- Apply effects
    -- Log event
```

**Estimated time:** 4 hours

---

#### Step 5.3: Event Manager (4 hours)
**Description:** Process and apply event effects  
**Files to create:**
- `engine/geoscape/systems/event_manager.lua`

**Implementation:**
```lua
EventManager = {
    triggeredEvents = {}, -- Events this month
    eventHistory = {} -- All past events
}

EventManager:processMonthlyEvents()
    -- Generate 3-5 events
    -- Trigger each event

EventManager:applyEventEffects(event)
    -- Apply all effects
    -- Credits, items, relations, missions, etc.

EventManager:applyEffect(effect)
    -- Handle single effect

EventManager:getMonthlyEvents()
EventManager:getEventHistory()
```

**Effect Types:**
```lua
EventManager.effectTypes = {
    "credits",              -- Modify player credits
    "items",                -- Add items to storage
    "relations",            -- Change faction relations
    "spawn_mission",        -- Create special mission
    "spawn_campaign",       -- Create special campaign
    "research_progress",    -- Bonus research points
    "base_damage",          -- Damage player base
    "craft_damage",         -- Damage player craft
    "province_event"        -- Province-specific effect
}
```

**Estimated time:** 4 hours

---

### Phase 6: Calendar Integration (10 hours)

#### Step 6.1: Calendar Hooks (4 hours)
**Description:** Integrate lore systems with TASK-025 Calendar  
**Files to modify:**
- `engine/geoscape/systems/calendar.lua` (add hooks)
- `engine/geoscape/systems/turn_processor.lua` (add lore processing)

**Calendar Hooks:**
```lua
Calendar.hooks = {
    onDayStart = {},    -- Daily triggers
    onWeekStart = {},   -- Weekly triggers
    onMonthStart = {},  -- Monthly triggers
    onQuarterStart = {} -- Quarterly triggers
}

Calendar:registerHook(hookType, callback)
Calendar:triggerHook(hookType, day)
```

**Turn Processor Integration:**
```lua
-- In turn_processor.lua:endTurn()

-- Daily Processing
if day % 1 == 0 then
    MissionManager:processDailyMissions() -- UFO scripts
    CampaignManager:processDailyCampaigns()
end

-- Weekly Processing
if day % 7 == 0 then
    MissionManager:processWeeklyMissions() -- Base scripts
    CampaignManager:processWeeklyCampaigns() -- Spawn missions
end

-- Monthly Processing
if dayOfMonth == 1 then
    CampaignGenerator:generateMonthlyCampaigns(calendar)
    EventGenerator:generateMonthlyEvents()
    FactionManager:processFactionEvents()
    QuestManager:updateQuests(day)
end
```

**Estimated time:** 4 hours

---

#### Step 6.2: Mission Manager (6 hours)
**Description:** Central mission processing system  
**Files to create:**
- `engine/geoscape/systems/mission_manager.lua`

**Implementation:**
```lua
MissionManager = {
    activeMissions = {}, -- All active missions
    missionsBySite = {}, -- Site missions
    missionsByUFO = {},  -- UFO missions
    missionsByBase = {}  -- Base missions
}

MissionManager:addMission(mission)
MissionManager:removeMission(missionId)

-- Daily Processing
MissionManager:processDailyMissions()
    -- For each UFO mission: execute daily script
    -- For each site mission: check expiration
    -- Update all mission counters

-- Weekly Processing
MissionManager:processWeeklyMissions()
    -- For each base mission: execute weekly script
    -- Spawn missions from bases

MissionManager:updateMission(mission, day)
MissionManager:expireMission(missionId)
    -- Apply score penalty
    -- Remove from province

MissionManager:getMissionsInProvince(provinceId)
MissionManager:getActiveMissionCount()
MissionManager:getMissionsByFaction(factionId)
```

**Estimated time:** 6 hours

---

### Phase 7: Scripting Engine (14 hours)

#### Step 7.1: Script Parser (4 hours)
**Description:** Parse and load scripts from TOML/JSON  
**Files to create:**
- `engine/geoscape/systems/script_parser.lua`

**Implementation:**
```lua
ScriptParser = {}

ScriptParser:loadUFOScript(scriptId)
    -- Load from ufo_scripts.toml
    -- Parse steps
    -- Return UFOScript object

ScriptParser:loadBaseScript(scriptId)
    -- Load from base_scripts.toml
    -- Parse stages
    -- Return BaseScript object

ScriptParser:loadCampaignScript(scriptId)
    -- Load from campaign_templates.toml
    -- Parse mission spawning logic
    -- Return CampaignScript object

ScriptParser:validateScript(script)
    -- Check for errors
    -- Validate step/stage structure
```

**Estimated time:** 4 hours

---

#### Step 7.2: Script Executor (6 hours)
**Description:** Execute scripts (UFO movement, base growth, campaign spawning)  
**Files to create:**
- `engine/geoscape/systems/script_executor.lua`

**Implementation:**
```lua
ScriptExecutor = {}

-- UFO Script Execution
ScriptExecutor:executeUFOScript(ufoMission, day)
    -- Get current step
    -- Execute action (move, land, takeoff, exit)
    -- Advance to next step

ScriptExecutor:executeUFOAction(action, ufoMission)
    -- Handle action types:
    -- "move" → moveToProvince()
    -- "land" → land()
    -- "takeoff" → takeoff()
    -- "wait" → delay counter
    -- "exit" → remove mission

-- Base Script Execution
ScriptExecutor:executeBaseScript(baseMission, week)
    -- Get current stage
    -- Check growth timer
    -- Spawn missions
    -- Advance to next stage

ScriptExecutor:executeBaseGrowth(baseMission)
    -- Increase level
    -- Unlock new mission types

-- Campaign Script Execution
ScriptExecutor:executeCampaignScript(campaign, week)
    -- Check spawn frequency
    -- Select mission template
    -- Spawn mission in target region
```

**Estimated time:** 6 hours

---

#### Step 7.3: Script Debugging Tools (4 hours)
**Description:** Tools to debug and visualize script execution  
**Files to create:**
- `engine/geoscape/systems/script_debugger.lua`

**Implementation:**
```lua
ScriptDebugger = {}

ScriptDebugger:logScriptExecution(script, step, action)
    -- Print script execution to console
    print("[Script] " .. script.id .. " - Step " .. step .. ": " .. action)

ScriptDebugger:visualizeUFOPath(ufoMission)
    -- Show UFO path on map (debug mode)

ScriptDebugger:showBaseGrowth(baseMission)
    -- Display base growth timeline

ScriptDebugger:dumpScript(script)
    -- Print full script structure
```

**Estimated time:** 4 hours

---

### Phase 8: UI Implementation (16 hours)

#### Step 8.1: Campaign Panel (4 hours)
**Description:** Display active campaigns  
**Files to create:**
- `engine/geoscape/ui/campaign_panel.lua`

**Display:**
- List of active campaigns
- Faction ownership
- Missions spawned
- Campaign progress (wave X of Y)
- Disabled campaigns (via research)

**Grid Snapping:** All UI at 24×24 pixel grid

**Estimated time:** 4 hours

---

#### Step 8.2: Quest Panel (4 hours)
**Description:** Display active quests with progress  
**Files to create:**
- `engine/geoscape/ui/quest_panel.lua`

**Display:**
- Active quests list
- Quest conditions with progress bars
- Time remaining (if applicable)
- Rewards preview
- Completion status

**Grid Snapping:** All UI at 24×24 pixel grid

**Estimated time:** 4 hours

---

#### Step 8.3: Event Log (4 hours)
**Description:** Display recent events  
**Files to create:**
- `engine/geoscape/ui/event_log.lua`

**Display:**
- Last 10 events
- Event descriptions
- Effects applied
- Timestamp

**Grid Snapping:** All UI at 24×24 pixel grid

**Estimated time:** 4 hours

---

#### Step 8.4: Faction Info Panel (4 hours)
**Description:** Display faction details and research progress  
**Files to create:**
- `engine/geoscape/ui/faction_panel.lua`

**Display:**
- Faction name, lore
- Relations (-2 to +2)
- Research tree progress
- Active campaigns
- Mission statistics

**Grid Snapping:** All UI at 24×24 pixel grid

**Estimated time:** 4 hours

---

### Phase 9: Integration & Testing (12 hours)

#### Step 9.1: Integration with TASK-025 (4 hours)
**Description:** Connect lore systems to Geoscape  
**Files to modify:**
- `engine/geoscape/init.lua`
- `engine/geoscape/systems/turn_processor.lua`

**Integration Points:**
- Calendar hooks for daily/weekly/monthly processing
- Province mission tracking
- Radar detection of missions
- Craft interception of missions

**Estimated time:** 4 hours

---

#### Step 9.2: Testing Suite (4 hours)
**Description:** Comprehensive tests for all systems  
**Files to create:**
- `engine/geoscape/tests/test_faction.lua`
- `engine/geoscape/tests/test_campaign.lua`
- `engine/geoscape/tests/test_mission.lua`
- `engine/geoscape/tests/test_quest.lua`
- `engine/geoscape/tests/test_event.lua`

**Test Cases:**
- Campaign generation escalation formula
- Mission spawning from campaigns
- UFO script execution
- Base growth script
- Quest condition evaluation
- Event generation and effects
- Faction research disabling campaigns

**Estimated time:** 4 hours

---

#### Step 9.3: Manual Testing & Debugging (4 hours)
**Description:** Play through full campaign cycle  
**Manual Test:**
1. Start new game
2. Verify 2 campaigns spawn in Q1
3. Advance to Q2, verify 3 campaigns spawn
4. Let campaigns spawn missions weekly
5. Test UFO movement between provinces
6. Build base, verify growth script
7. Complete quests
8. Trigger events
9. Research faction tech to disable campaigns
10. Verify escalation continues until 10+ campaigns/month

**Run with:** `lovec "engine"` (console enabled)

**Estimated time:** 4 hours

---

### Phase 10: Documentation (8 hours)

#### Step 10.1: API Documentation (3 hours)
**Files to update:**
- `wiki/API.md`

**Document:**
- Faction, Campaign, Mission (Site/UFO/Base)
- Quest, Event
- FactionManager, CampaignGenerator, CampaignManager
- MissionManager, QuestManager, EventManager
- ScriptParser, ScriptExecutor
- All public functions with parameters/returns

**Estimated time:** 3 hours

---

#### Step 10.2: Data File Documentation (3 hours)
**Files to create:**
- `wiki/LORE_SYSTEM_GUIDE.md`

**Contents:**
- How to create factions
- How to define campaigns
- How to create mission templates
- How to write UFO/Base scripts
- How to define quests
- How to create events
- Campaign escalation formula
- Research tree structure

**Estimated time:** 3 hours

---

#### Step 10.3: FAQ Updates (2 hours)
**Files to update:**
- `wiki/FAQ.md`

**Add Sections:**
- "How does the campaign system work?"
- "How do I disable faction campaigns?"
- "What are quests and events?"
- "How does mission escalation work?"
- "How do UFO scripts work?"
- "How do alien bases grow?"

**Estimated time:** 2 hours

---

## Total Time Estimate

| Phase | Hours |
|-------|-------|
| Phase 1: Faction System | 12h |
| Phase 2: Campaign System | 18h |
| Phase 3: Mission System | 24h |
| Phase 4: Quest System | 16h |
| Phase 5: Event System | 12h |
| Phase 6: Calendar Integration | 10h |
| Phase 7: Scripting Engine | 14h |
| Phase 8: UI Implementation | 16h |
| Phase 9: Integration & Testing | 12h |
| Phase 10: Documentation | 8h |
| **Total** | **142 hours** |

**Estimated Duration:** 18 days (8 hours/day) or 3.5-4 weeks

---

## Implementation Details

### Architecture

**Pattern:** Event-driven system with calendar hooks
- **Logic Layer**: Faction, Campaign, Mission, Quest, Event entities
- **Systems Layer**: Managers for each entity type, generators, executors
- **Scripting Layer**: Script parser and executor for dynamic behaviors
- **Integration Layer**: Calendar hooks, turn processor, state management

**Data Flow:**
```
Calendar → Turn Processor → Daily/Weekly/Monthly Hooks
                                      ↓
    ┌─────────────────────────────────┼─────────────────────────────────┐
    ▼                                 ▼                                 ▼
Daily: UFO Scripts              Weekly: Base Scripts           Monthly: Campaign Gen
       Campaign Delays                 Campaign Spawning               Event Gen
       Mission Expiration                                              Faction Updates
```

### Key Components

#### 1. Faction System
- **Purpose:** Define enemy groups with unique identity
- **Research:** Progressive unlocking leading to campaign elimination
- **Relations:** Affect mission frequency and difficulty

#### 2. Campaign Generator
- **Purpose:** Monthly escalation of threats
- **Formula:** `2 + (quarter - 1)` campaigns per month
- **Disabling:** Research completion stops specific campaigns

#### 3. Mission System
- **Site:** Static, expires after N days
- **UFO:** Mobile, follows daily script
- **Base:** Permanent, grows weekly, spawns missions

#### 4. Quest System
- **Purpose:** Directed objectives with rewards/penalties
- **Conditions:** Flexible evaluation system
- **Tracking:** Progress monitoring and completion

#### 5. Event System
- **Purpose:** Random occurrences adding variety
- **Effects:** Credits, items, relations, missions
- **Frequency:** 3-5 per month

#### 6. Scripting Engine
- **Purpose:** Dynamic behavior for UFOs, bases, campaigns
- **Types:** UFO movement, base growth, campaign spawning
- **Executor:** Daily/weekly processing

### Dependencies

**Internal (TASK-025 Geoscape):**
- `geoscape/systems/calendar.lua` - Daily/weekly/monthly triggers
- `geoscape/logic/province.lua` - Mission placement
- `geoscape/systems/radar_system.lua` - Mission detection
- `geoscape/logic/world.lua` - Province graph for UFO movement

**External:**
- Love2D for rendering
- TOML parser for data files
- `core/state_manager.lua` - State management

**Data Files:**
- `data/factions.toml` - Faction definitions
- `data/campaigns.toml` - Campaign templates
- `data/mission_templates.toml` - Mission definitions
- `data/ufo_scripts.toml` - UFO movement scripts
- `data/base_scripts.toml` - Base growth scripts
- `data/quests.toml` - Quest definitions
- `data/events.toml` - Event definitions

---

## Testing Strategy

### Unit Tests

#### Faction Tests
- Test relations update
- Test research tree completion
- Test campaign disabling

#### Campaign Tests
- Test escalation formula (2→10 campaigns/month)
- Test campaign spawning
- Test mission script selection

#### Mission Tests
- Test site expiration
- Test UFO script execution (move, land, takeoff)
- Test base growth stages
- Test mission scoring

#### Quest Tests
- Test condition evaluation (all types)
- Test quest completion/failure
- Test reward/penalty application

#### Event Tests
- Test random selection
- Test effect application (all types)

### Integration Tests

#### Calendar Integration
- Test daily hooks (UFO scripts)
- Test weekly hooks (base scripts, campaign spawning)
- Test monthly hooks (campaign generation, events)

#### Full Campaign Cycle
- Generate campaigns in Q1 (expect 2)
- Advance to Q2 (expect 3)
- Continue to Year 2 (expect 6+ campaigns)
- Verify missions spawn weekly
- Verify UFOs move between provinces
- Verify bases grow and spawn missions

#### Research Disabling
- Complete faction research tree
- Verify campaigns disabled
- Verify no new campaigns spawn for that faction

### Manual Testing Steps

1. **Run game:** `lovec "engine"`
2. **Start new game** at Year 1, Quarter 1, Month 1
3. **Check campaign generation:**
   - Verify 2 campaigns spawn on Day 1
   - Advance to Q2, verify 3 campaigns spawn
4. **Monitor mission spawning:**
   - Verify missions spawn weekly from campaigns
   - Check UFO missions move between provinces
   - Check site missions expire after 7 days
5. **Test alien base:**
   - Let base mission grow for 4 weeks
   - Verify level 2 reached
   - Verify new mission types unlock
6. **Complete quests:**
   - Check quest conditions
   - Complete objectives
   - Verify rewards applied
7. **Trigger events:**
   - Advance to new month
   - Check 3-5 events generated
   - Verify effects applied
8. **Research faction:**
   - Complete faction research tree
   - Verify campaigns disabled
   - Check no new campaigns for that faction
9. **Long-term test:**
   - Advance to Year 2
   - Verify 6+ campaigns/month
   - Continue to 10+ campaigns/month

### Expected Results

- ✅ 2 campaigns spawn in Q1, escalate to 10+ by Year 2
- ✅ Campaigns spawn missions weekly
- ✅ UFO missions move between provinces daily
- ✅ Base missions grow and spawn missions weekly
- ✅ Site missions expire after N days
- ✅ Quests track conditions and trigger rewards
- ✅ Events occur 3-5 times per month
- ✅ Faction research disables campaigns
- ✅ Hostile relations trigger base assaults
- ✅ No console errors or warnings

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use VS Code task: **"Run XCOM Simple Game"**

### Debugging

**Console Output:**
```lua
print("[Faction] Sectoid relations: " .. faction.relations)
print("[Campaign] Generated " .. count .. " campaigns for month " .. month)
print("[Mission] UFO " .. missionId .. " moved to province " .. provinceId)
print("[Quest] Quest " .. questId .. " completed - Reward: " .. reward)
print("[Event] Event triggered: " .. event.name)
```

**Debug Keys:**
- **F1**: Show campaign/quest/event debug info
- **F9**: Toggle hex grid (for mission positions)
- **F10**: Force campaign generation (skip to next month)

**Script Debugging:**
```lua
-- Enable script logging
ScriptDebugger.enabled = true

-- View script execution
ScriptDebugger:visualizeUFOPath(ufoMission)
ScriptDebugger:dumpScript(script)
```

### Temporary Files
- All temp files MUST go to: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add lore system APIs
- [x] `wiki/FAQ.md` - Add lore system FAQ
- [x] `wiki/LORE_SYSTEM_GUIDE.md` - Create comprehensive guide
- [ ] Code comments - Add inline documentation

### API Documentation Structure

```markdown
## Lore & Campaign API

### Faction
- `Faction:updateRelations(delta)` - Change faction relations
- `Faction:isHostile()` - Check if hostile (≤ -2)
- `Faction:disableCampaign(campaignId)` - Disable via research

### Campaign
- `CampaignGenerator:generateMonthlyCampaigns(calendar)` - Monthly gen
- `CampaignManager:processWeeklyCampaigns()` - Spawn missions
- `CampaignManager:spawnMissionFromCampaign(campaign)` - Create mission

### Mission
- `MissionManager:processDailyMissions()` - UFO scripts
- `MissionManager:processWeeklyMissions()` - Base scripts
- `MissionSite:expire()` - Handle expiration
- `MissionUFO:executeScript()` - Move UFO
- `MissionBase:grow()` - Increase level

### Quest
- `QuestManager:updateQuests(day)` - Check conditions
- `QuestManager:completeQuest(questId)` - Apply rewards
- `QuestConditions:evaluate(quest, gameState)` - Check all conditions

### Event
- `EventGenerator:generateMonthlyEvents()` - Create 3-5 events
- `EventManager:applyEventEffects(event)` - Execute effects
```

---

## Notes

### Design Decisions

1. **Campaign Escalation Formula:**
   - Simple linear: `2 + (quarter - 1)`
   - Predictable progression
   - Caps naturally at 10-12 campaigns/month

2. **Faction Research:**
   - Progressive unlocking through research tree
   - Final research = disable all campaigns
   - Incentivizes research investment

3. **Mission Types:**
   - **Site:** Simple, expires quickly (7 days)
   - **UFO:** Dynamic movement adds challenge
   - **Base:** Permanent threat, grows over time

4. **Quest System:**
   - Flexible condition system supports any objective
   - Rewards/penalties drive player behavior
   - Time limits add urgency

5. **Event System:**
   - 3-5 per month keeps variety without spam
   - Random + triggered events for dynamic gameplay
   - Effects impact multiple game systems

### Performance Considerations

- **Mission Limit:** ~100 active missions max (manageable)
- **Campaign Tracking:** Cache active campaigns per faction
- **Script Execution:** Batch daily/weekly processing
- **Condition Evaluation:** Cache quest progress, only check on relevant changes

### Future Enhancements

- **Dynamic Faction Creation:** New factions appear mid-game
- **Faction Alliances:** Factions cooperate on campaigns
- **Nested Campaigns:** Meta-campaigns with sub-campaigns
- **Player-Created Quests:** Sandbox mode quest editor
- **Event Chains:** Events trigger follow-up events
- **Mission Chaining:** Missions lead to other missions
- **Base Siege:** Multi-wave defense of alien bases

---

## Blockers

### Prerequisites (from TASK-025)
- **Calendar System:** Must be implemented (TASK-025 Phase 2)
- **Province System:** Must exist for mission placement (TASK-025 Phase 1)
- **Radar System:** Must exist for mission detection (TASK-025 Phase 4)

### External Dependencies
- **Faction Data:** Need faction definitions (can start with 3-5 factions)
- **Mission Templates:** Need at least 10-20 mission templates
- **Research System:** Need research tree structure (can be stubbed)

### Technical Risks
- **Script Complexity:** UFO/Base scripts may become complex
- **Performance:** 100+ missions + 50+ campaigns may impact performance
- **Quest Conditions:** Flexible system may be hard to balance
- **Event Randomness:** Need good RNG to avoid repetitive events

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] All UI elements snap to 24×24 pixel grid
- [ ] Campaign escalation formula tested (2→10 campaigns)
- [ ] UFO scripts execute daily correctly
- [ ] Base scripts execute weekly correctly
- [ ] Quest conditions evaluate properly
- [ ] Events generate 3-5 per month
- [ ] Faction research disables campaigns
- [ ] All systems use `print()` for debug output
- [ ] No temporary files in project directories
- [ ] API documentation complete
- [ ] FAQ updated with lore system info
- [ ] All tests pass
- [ ] No console errors when running with `lovec "engine"`

---

## What Worked Well

*(To be filled after completion)*

---

## Lessons Learned

*(To be filled after completion)*

---

## Integration with TASK-025

### Calendar Dependency
This task requires TASK-025 Phase 2 (Calendar System) to be completed first.

**Integration Points:**
- Calendar hooks for daily/weekly/monthly processing
- Turn processor calls lore system managers
- Province system tracks missions
- Radar system detects missions

### Recommended Implementation Order
1. Complete TASK-025 Phases 1-3 (Core, Calendar, Geographic)
2. Start TASK-026 Phase 1 (Factions)
3. Complete TASK-026 Phase 2-3 (Campaigns, Missions)
4. Continue parallel development of both tasks
5. Integrate in TASK-026 Phase 6 (Calendar Integration)

---

**End of Task Document**
