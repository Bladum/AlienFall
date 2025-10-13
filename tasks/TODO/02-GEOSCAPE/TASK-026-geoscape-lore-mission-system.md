# Task: Geoscape Lore & Mission System - Campaigns, Factions, Events

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

**Dependencies:** TASK-025 (Geoscape Master Implementation) - Phases 1-4 must be complete

---

## Overview

Complete implementation of the **dynamic mission generation system** that drives gameplay progression through factions, campaigns, missions, quests, and events. This system creates a living, reactive strategic layer where enemy factions escalate their activities over time, missions spawn dynamically, and player actions affect the world state.

This is the **narrative and progression engine** of the game, transforming the static Geoscape into a dynamic strategic challenge.

---

## Purpose

The Lore & Mission System provides:

1. **Dynamic Threat Escalation**: Missions increase from 2/month to 10/month over 2 years
2. **Faction-Based Narrative**: Each faction has unique lore, units, research, and missions
3. **Strategic Progression**: Player researches faction tech to disable their campaigns
4. **Mission Variety**: Sites (static), UFOs (moving), Bases (permanent + spawning)
5. **Campaign Scripts**: Weekly/delayed mission spawning per faction
6. **Quest System**: Flexible conditions, rewards, and penalties
7. **Random Events**: Monthly events affecting resources, relations, missions
8. **Relation-Based Difficulty**: Faction relations (-2 to +2) affect mission frequency/difficulty

Without this system, the Geoscape would be static with no strategic progression or narrative depth.

---

## Requirements

### Functional Requirements

#### Calendar Integration
- [ ] **Mission Spawning**: Every 1st day of month, randomly generate new campaigns
- [ ] **Escalation**: Start with 2 campaigns/month (Q1), increase by 1 per quarter
- [ ] **Max Campaigns**: Cap at 10/month after 2 years (8 quarters)
- [ ] **Tech Disabling**: Player can reduce campaigns via faction research progress

#### Faction System
- [ ] **Faction Entity**: Core lore element describing enemy groups/races
- [ ] **Unique Identity**: Each faction has lore, units, items, research tree
- [ ] **Mission Ownership**: All missions belong to a faction
- [ ] **Research Progression**: Player researches faction tech to unlock countermeasures
- [ ] **Final Research**: Disables faction's campaigns/missions permanently
- [ ] **Relations System**: -2 to +2 scale affecting mission frequency/difficulty
- [ ] **Hostile Actions**: Relation -2 triggers special missions (e.g., base assault)

#### Mission System
- [ ] **Mission Types**:
  - **Site**: Static mission waiting to be picked up
  - **UFO**: Moving mission with scripted movement
  - **Base**: Permanent mission that spawns more missions
- [ ] **Province Placement**: Missions exist within provinces
- [ ] **Scoring**: Missions score points against player if not intercepted
- [ ] **Detection**: Radar system reveals missions to player
- [ ] **Expiration**: Missions expire after time limit

#### Campaign System
- [ ] **Campaign Entity**: Script-based mission spawner per faction
- [ ] **Spawning Schedule**: Once per week OR with custom delay
- [ ] **Mission Scripts**: Campaign defines what missions to spawn and when
- [ ] **Tech Disabling**: Campaigns disabled by player research progress
- [ ] **Faction-Specific**: Every campaign belongs to a faction

#### Quest System
- [ ] **Quest Entity**: Flexible condition-based objectives
- [ ] **Conditions**: Check world state (missions completed, tech researched, etc.)
- [ ] **Rewards**: Money, items, tech, relations, faction progress
- [ ] **Penalties**: Negative consequences if conditions not met
- [ ] **Flexible Scripting**: Support complex condition logic

#### Event System
- [ ] **Random Events**: Few per month, not linked to campaigns
- [ ] **Resource Effects**: Modify money, fuel, items
- [ ] **Relation Effects**: Change country or faction relations
- [ ] **Mission Creation**: Events can spawn one-off missions
- [ ] **No Campaign Link**: Independent of faction campaign system

#### Mission Scripts
- [ ] **UFO Script**: Daily updates for UFO movement
  - Move between provinces
  - Land in province
  - Take off
  - Change region
  - Patrol patterns
- [ ] **Base Script**: Growth and spawning logic
  - Base expansion over time
  - Spawn missions from base
  - Increase threat level
  - Trigger special missions

### Technical Requirements
- [ ] **Data-Driven**: All factions, campaigns, missions defined in TOML files
- [ ] **Script Engine**: Lua-based scripting for campaigns, UFO behavior, base growth
- [ ] **Event Queue**: Priority queue for scheduled events (campaign spawns, UFO updates)
- [ ] **State Persistence**: Save/load faction progress, campaign status, active missions
- [ ] **Performance**: Handle 50+ active missions, 20+ campaigns, 10+ factions
- [ ] **Integration**: Works with Calendar (TASK-025 Phase 2) and Travel System (Phase 4)

### Acceptance Criteria
- [ ] Campaigns spawn on 1st of month with escalation (2 → 10 over 8 quarters)
- [ ] Each faction has unique lore, units, research tree
- [ ] Player can research faction tech to disable campaigns
- [ ] Missions spawn via campaign scripts (weekly/delayed)
- [ ] UFO missions move between provinces via scripts
- [ ] Base missions spawn additional missions over time
- [ ] Quest system supports complex conditions and rewards/penalties
- [ ] Random events trigger monthly with resource/relation effects
- [ ] Faction relations affect mission frequency and difficulty
- [ ] Relation -2 triggers special hostile missions (base assault)
- [ ] All systems integrate with Geoscape calendar and province system

---

## Plan

### Phase 1: Core Data Structures (16 hours)

#### Step 1.1: Faction System (6 hours)
**Description:** Core faction entity with lore, units, research, relations  
**Files to create:**
- `engine/geoscape/logic/faction.lua`
- `engine/data/factions.toml`
- `engine/geoscape/tests/test_faction.lua`

**Faction Structure:**
```lua
Faction = {
    id = "sectoids",
    name = "Sectoid Empire",
    description = "Alien race focused on psionic warfare",
    lore = "Long description of faction background...",
    
    -- Gameplay data
    relations = 0, -- -2 to +2
    disabled = false, -- Set to true when final research complete
    
    -- Content references
    unitIds = {"sectoid_soldier", "sectoid_commander"},
    itemIds = {"plasma_pistol", "mind_probe"},
    researchTreeId = "sectoid_research",
    
    -- Mission configuration
    baseMissionFrequency = 2, -- Base missions per month
    relationModifiers = {
        [-2] = 2.0, -- 2x missions at hostile
        [-1] = 1.5,
        [0] = 1.0,
        [1] = 0.7,
        [2] = 0.4  -- 60% fewer missions at allied
    },
    
    -- Special missions
    specialMissions = {
        baseAssault = {
            requiredRelation = -2,
            chance = 0.3 -- 30% chance per month at -2 relation
        }
    }
}
```

**Functions:**
```lua
Faction:updateRelations(delta) -- Change relations by delta
Faction:getMissionFrequency() -- Get adjusted frequency based on relations
Faction:canSpawnSpecialMission(missionType) -- Check special mission conditions
Faction:disable() -- Disable faction (final research complete)
Faction:isDisabled() -- Check if faction disabled
```

**TOML Structure:**
```toml
[[faction]]
id = "sectoids"
name = "Sectoid Empire"
description = "Alien race focused on psionic warfare"
lore = """
The Sectoids are a highly intelligent alien race...
"""

relations = 0
disabled = false

unitIds = ["sectoid_soldier", "sectoid_commander"]
itemIds = ["plasma_pistol", "mind_probe"]
researchTreeId = "sectoid_research"

baseMissionFrequency = 2

[faction.relationModifiers]
"-2" = 2.0
"-1" = 1.5
"0" = 1.0
"1" = 0.7
"2" = 0.4

[[faction.specialMissions]]
type = "baseAssault"
requiredRelation = -2
chance = 0.3
```

**Estimated time:** 6 hours

---

#### Step 1.2: Mission Types (6 hours)
**Description:** Core mission entities (Site, UFO, Base)  
**Files to create:**
- `engine/geoscape/logic/mission.lua`
- `engine/geoscape/logic/mission_site.lua`
- `engine/geoscape/logic/mission_ufo.lua`
- `engine/geoscape/logic/mission_base.lua`

**Base Mission Structure:**
```lua
Mission = {
    id = "mission_001",
    type = "site", -- "site", "ufo", "base"
    factionId = "sectoids",
    provinceId = "province_042",
    
    -- Timing
    spawnTurn = 100,
    expirationTurn = 130, -- nil for permanent
    
    -- Detection
    detected = false,
    detectionDifficulty = 50, -- Radar check difficulty
    
    -- Scoring
    scoreValue = 10, -- Points against player if not intercepted
    scored = false,
    
    -- Interception data
    intercepted = false,
    battlescapeData = {}, -- Data for battlescape generation
}
```

**Mission Site (Static):**
```lua
MissionSite = Mission + {
    siteType = "crash_site", -- "crash_site", "terror_site", "supply_ship"
    terrainType = "urban",
    duration = 30, -- Turns before expiration
}
```

**Mission UFO (Moving):**
```lua
MissionUFO = Mission + {
    ufoType = "scout", -- "scout", "fighter", "battleship"
    scriptId = "scout_patrol_01",
    currentScriptStep = 1,
    
    -- Movement
    targetProvinceId = nil, -- Where UFO is moving to
    movementSpeed = 2, -- Provinces per turn
    landed = false,
    
    -- Combat
    hp = 100,
    maxHp = 100,
    destroyed = false,
}
```

**Mission Base (Permanent):**
```lua
MissionBase = Mission + {
    baseType = "small_base", -- "small_base", "large_base"
    scriptId = "base_growth_standard",
    
    -- Growth
    growthLevel = 1, -- 1-5
    growthTurns = 0, -- Turns since last growth
    growthInterval = 60, -- Turns between growth levels
    
    -- Spawning
    spawnedMissions = {}, -- IDs of missions spawned by this base
    spawnInterval = 14, -- Turns between spawns (2 weeks)
    lastSpawnTurn = 100,
    
    -- Combat
    hp = 500,
    maxHp = 500,
    destroyed = false,
}
```

**Functions:**
```lua
Mission:update(turn) -- Update mission state
Mission:detect(radarPower) -- Try to detect mission
Mission:scoreAgainstPlayer() -- Score points if not intercepted
Mission:expire() -- Remove mission after expiration

MissionUFO:updateScript(turn) -- Execute UFO script step
MissionUFO:moveTo(provinceId) -- Move to target province
MissionUFO:land() -- Land in current province
MissionUFO:takeOff() -- Take off from province

MissionBase:grow(turn) -- Increase growth level
MissionBase:spawnMission(turn) -- Create new mission from base
MissionBase:shouldSpawn(turn) -- Check if ready to spawn
```

**Estimated time:** 6 hours

---

#### Step 1.3: Campaign System (4 hours)
**Description:** Campaign entity with mission spawning scripts  
**Files to create:**
- `engine/geoscape/logic/campaign.lua`
- `engine/data/campaigns.toml`

**Campaign Structure:**
```lua
Campaign = {
    id = "campaign_sectoid_recon_001",
    factionId = "sectoids",
    scriptId = "sectoid_recon_wave",
    
    -- Status
    active = true,
    disabled = false, -- Disabled by tech research
    startTurn = 100,
    endTurn = nil, -- nil = indefinite
    
    -- Spawning
    spawnInterval = 7, -- Turns between spawns (1 week)
    lastSpawnTurn = 100,
    spawnDelay = 0, -- Additional delay
    
    -- Mission generation
    missionTypes = {"ufo", "site"},
    missionScripts = {
        "scout_patrol_01",
        "fighter_intercept_01"
    },
    
    -- Targeting
    targetRegions = {"north_america", "europe"},
    targetBiomes = {"urban", "temperate"},
    
    -- Difficulty scaling
    difficultyScaling = true,
    baseDifficulty = 1.0,
    
    -- Progress
    missionsSpawned = 0,
    maxMissions = nil, -- nil = unlimited
}
```

**Functions:**
```lua
Campaign:shouldSpawn(turn) -- Check if ready to spawn mission
Campaign:spawnMission(world) -- Generate and place mission
Campaign:disable() -- Disable campaign via tech research
Campaign:updateDifficulty(turn) -- Scale difficulty over time
```

**TOML Structure:**
```toml
[[campaign]]
id = "campaign_sectoid_recon_001"
factionId = "sectoids"
scriptId = "sectoid_recon_wave"

active = true
spawnInterval = 7
spawnDelay = 0

missionTypes = ["ufo", "site"]
missionScripts = ["scout_patrol_01", "fighter_intercept_01"]

targetRegions = ["north_america", "europe"]
targetBiomes = ["urban", "temperate"]

difficultyScaling = true
baseDifficulty = 1.0
```

**Estimated time:** 4 hours

---

### Phase 2: Mission Scripting System (18 hours)

#### Step 2.1: Script Engine (8 hours)
**Description:** Lua-based scripting engine for UFO and Base behaviors  
**Files to create:**
- `engine/geoscape/systems/script_engine.lua`
- `engine/geoscape/logic/mission_script.lua`
- `engine/data/scripts/ufo_scripts.lua`
- `engine/data/scripts/base_scripts.lua`

**Script Engine:**
```lua
ScriptEngine = {
    scripts = {}, -- scriptId → script table
    activeScripts = {}, -- missionId → script state
}

-- Script structure
Script = {
    id = "scout_patrol_01",
    type = "ufo", -- "ufo" or "base"
    steps = {
        {action = "moveTo", params = {region = "north_america"}},
        {action = "patrol", params = {provinces = 5, turns = 14}},
        {action = "land", params = {biome = "urban", duration = 7}},
        {action = "takeOff", params = {}},
        {action = "moveTo", params = {region = "europe"}},
        {action = "returnToBase", params = {}},
    },
    loop = false,
}
```

**UFO Script Actions:**
- `moveTo`: Move to region/province
- `patrol`: Patrol N provinces for T turns
- `land`: Land in province (filtered by biome) for duration
- `takeOff`: Take off from landed state
- `attack`: Attack player base/craft
- `returnToBase`: Return to faction base and despawn
- `wait`: Wait for N turns
- `changeRegion`: Move to different region

**Base Script Actions:**
- `grow`: Increase growth level
- `spawnMission`: Spawn specific mission type
- `upgradeDefenses`: Increase HP
- `expandRadius`: Increase spawn radius
- `wait`: Wait for N turns

**Script Execution:**
```lua
ScriptEngine:loadScript(scriptId) -- Load script from file
ScriptEngine:startScript(missionId, scriptId) -- Start script for mission
ScriptEngine:updateScript(missionId, turn) -- Execute next step
ScriptEngine:stopScript(missionId) -- Stop script execution
```

**Example UFO Script:**
```lua
-- data/scripts/ufo_scripts.lua
return {
    scout_patrol_01 = {
        id = "scout_patrol_01",
        type = "ufo",
        steps = {
            {action = "moveTo", params = {provinceId = "province_042"}},
            {action = "patrol", params = {radius = 3, turns = 14}},
            {action = "land", params = {biome = "urban", duration = 7}},
            {action = "takeOff"},
            {action = "moveTo", params = {provinceId = "province_001"}},
            {action = "returnToBase"},
        },
        loop = false,
    },
    
    fighter_intercept_01 = {
        id = "fighter_intercept_01",
        type = "ufo",
        steps = {
            {action = "moveTo", params = {targetType = "playerBase"}},
            {action = "attack", params = {duration = 3}},
            {action = "returnToBase"},
        },
        loop = false,
    }
}
```

**Example Base Script:**
```lua
-- data/scripts/base_scripts.lua
return {
    base_growth_standard = {
        id = "base_growth_standard",
        type = "base",
        steps = {
            {action = "wait", params = {turns = 60}},
            {action = "grow"},
            {action = "spawnMission", params = {type = "ufo", script = "scout_patrol_01"}},
            {action = "wait", params = {turns = 14}},
            {action = "spawnMission", params = {type = "site", script = "supply_drop"}},
            {action = "wait", params = {turns = 60}},
            {action = "grow"},
            {action = "upgradeDefenses", params = {hpBonus = 200}},
        },
        loop = true, -- Repeat after all steps
    }
}
```

**Estimated time:** 8 hours

---

#### Step 2.2: Campaign Spawning Logic (6 hours)
**Description:** Monthly campaign generation with escalation  
**Files to create:**
- `engine/geoscape/systems/campaign_manager.lua`
- `engine/geoscape/tests/test_campaign_manager.lua`

**Campaign Manager:**
```lua
CampaignManager = {
    campaigns = {}, -- Active campaigns
    campaignQueue = {}, -- Scheduled campaigns
    
    -- Escalation
    baseCampaignsPerMonth = 2,
    escalationRate = 1, -- +1 per quarter
    maxCampaignsPerMonth = 10,
    
    -- State
    currentQuarter = 1,
    campaignsThisMonth = 0,
}
```

**Functions:**
```lua
CampaignManager:initialize(world)
CampaignManager:update(turn, calendar)
CampaignManager:spawnCampaigns(turn) -- Called on 1st of month
CampaignManager:calculateCampaignLimit(quarter) -- 2 + (quarter - 1)
CampaignManager:selectRandomCampaigns(factions) -- Pick campaigns from pool
CampaignManager:disableCampaign(campaignId) -- Disable via tech research
CampaignManager:updateActiveCampaigns(turn) -- Spawn missions from campaigns
```

**Spawning Algorithm:**
```lua
function CampaignManager:spawnCampaigns(turn, calendar)
    -- Only on 1st of month
    if calendar:getDayOfMonth() ~= 1 then return end
    
    -- Calculate limit based on quarter
    local quarter = calendar:getQuarter()
    local limit = math.min(
        self.baseCampaignsPerMonth + (quarter - 1) * self.escalationRate,
        self.maxCampaignsPerMonth
    )
    
    -- Adjust for tech progress (faction disabling)
    local enabledFactions = self:getEnabledFactions()
    if #enabledFactions == 0 then return end
    
    -- Spawn campaigns
    for i = 1, limit do
        local faction = self:selectRandomFaction(enabledFactions)
        local campaign = self:createCampaign(faction, turn)
        table.insert(self.campaigns, campaign)
        print("[CampaignManager] Spawned campaign: " .. campaign.id)
    end
    
    self.campaignsThisMonth = limit
end
```

**Estimated time:** 6 hours

---

#### Step 2.3: Mission Update System (4 hours)
**Description:** Daily mission updates for UFOs and bases  
**Files to create:**
- `engine/geoscape/systems/mission_manager.lua`

**Mission Manager:**
```lua
MissionManager = {
    missions = {}, -- All active missions
    ufoScripts = {}, -- UFO script states
    baseScripts = {}, -- Base script states
}
```

**Functions:**
```lua
MissionManager:update(turn) -- Update all missions
MissionManager:updateUFOs(turn) -- Update UFO scripts (daily)
MissionManager:updateBases(turn) -- Update base scripts (daily)
MissionManager:updateSites(turn) -- Check site expirations
MissionManager:detectMissions(crafts) -- Radar detection
MissionManager:scoreMissions(turn) -- Score unintercepted missions
MissionManager:expireMissions(turn) -- Remove expired missions
```

**Daily Update Sequence:**
```lua
function MissionManager:update(turn)
    -- 1. Update UFO scripts
    for _, mission in ipairs(self:getMissionsByType("ufo")) do
        if not mission.intercepted then
            ScriptEngine:updateScript(mission.id, turn)
        end
    end
    
    -- 2. Update base scripts
    for _, mission in ipairs(self:getMissionsByType("base")) do
        if not mission.destroyed then
            ScriptEngine:updateScript(mission.id, turn)
            
            -- Check if base should spawn mission
            if mission:shouldSpawn(turn) then
                local newMission = mission:spawnMission(turn)
                self:addMission(newMission)
            end
        end
    end
    
    -- 3. Check site expirations
    for _, mission in ipairs(self:getMissionsByType("site")) do
        if mission:isExpired(turn) then
            if not mission.intercepted then
                mission:scoreAgainstPlayer()
            end
            self:removeMission(mission.id)
        end
    end
end
```

**Estimated time:** 4 hours

---

### Phase 3: Quest & Event Systems (14 hours)

#### Step 3.1: Quest System (8 hours)
**Description:** Flexible condition-based quest system  
**Files to create:**
- `engine/geoscape/logic/quest.lua`
- `engine/geoscape/systems/quest_manager.lua`
- `engine/data/quests.toml`

**Quest Structure:**
```lua
Quest = {
    id = "quest_research_plasma",
    name = "Plasma Weapons Research",
    description = "Research plasma weapons technology to gain an edge",
    
    -- Status
    active = false,
    completed = false,
    failed = false,
    
    -- Timing
    startTurn = nil,
    deadlineTurns = 90, -- 3 months
    expirationTurn = nil,
    
    -- Conditions
    conditions = {
        {type = "researchComplete", params = {researchId = "plasma_weapons"}},
        {type = "missionsCompleted", params = {count = 5, factionId = "sectoids"}},
        {type = "beforeTurn", params = {turn = 190}},
    },
    conditionLogic = "AND", -- "AND" or "OR"
    
    -- Rewards
    rewards = {
        {type = "money", params = {amount = 50000}},
        {type = "item", params = {itemId = "plasma_rifle", count = 3}},
        {type = "research", params = {researchId = "advanced_plasma"}},
        {type = "factionRelation", params = {factionId = "sectoids", delta = 1}},
    },
    
    -- Penalties
    penalties = {
        {type = "money", params = {amount = -20000}},
        {type = "countryRelation", params = {countryId = "usa", delta = -1}},
    },
}
```

**Condition Types:**
- `researchComplete`: Check if research completed
- `missionsCompleted`: Check mission count (filtered by faction/type)
- `basesBuilt`: Check base count
- `craftDeployed`: Check craft deployment count
- `itemCrafted`: Check if item crafted
- `enemyKilled`: Check enemy kill count
- `beforeTurn`: Must complete before turn N
- `factionRelation`: Check faction relation level
- `countryRelation`: Check country relation level
- `resourceAmount`: Check money/fuel/item quantity

**Quest Manager:**
```lua
QuestManager = {
    activeQuests = {},
    completedQuests = {},
    failedQuests = {},
}

QuestManager:update(turn, world) -- Check quest conditions
QuestManager:activateQuest(questId, turn) -- Start quest
QuestManager:checkConditions(quest, world) -- Evaluate conditions
QuestManager:completeQuest(questId) -- Grant rewards
QuestManager:failQuest(questId) -- Apply penalties
```

**TOML Structure:**
```toml
[[quest]]
id = "quest_research_plasma"
name = "Plasma Weapons Research"
description = "Research plasma weapons technology to gain an edge"

deadlineTurns = 90
conditionLogic = "AND"

[[quest.conditions]]
type = "researchComplete"
researchId = "plasma_weapons"

[[quest.conditions]]
type = "missionsCompleted"
count = 5
factionId = "sectoids"

[[quest.rewards]]
type = "money"
amount = 50000

[[quest.rewards]]
type = "item"
itemId = "plasma_rifle"
count = 3

[[quest.penalties]]
type = "money"
amount = -20000
```

**Estimated time:** 8 hours

---

#### Step 3.2: Event System (6 hours)
**Description:** Random monthly events affecting world state  
**Files to create:**
- `engine/geoscape/logic/event.lua`
- `engine/geoscape/systems/event_manager.lua`
- `engine/data/events.toml`

**Event Structure:**
```lua
Event = {
    id = "event_funding_boost",
    name = "Additional Funding",
    description = "A wealthy donor has provided additional funds",
    
    -- Frequency
    weight = 10, -- Chance weight (higher = more common)
    cooldown = 60, -- Turns before can trigger again
    lastTriggered = nil,
    
    -- Requirements
    requirements = {
        minTurn = 30, -- Don't trigger before turn 30
        maxTurn = nil,
        minQuarter = 1,
        requiredRelation = {countryId = "usa", min = 0}, -- Optional
    },
    
    -- Effects
    effects = {
        {type = "money", params = {amount = 30000}},
        {type = "message", params = {text = "You received $30,000!"}},
    },
}
```

**Event Types:**
- **Resource Events**: Money, fuel, items
- **Relation Events**: Country/faction relation changes
- **Mission Events**: Spawn one-off mission
- **Tech Events**: Unlock research or tech
- **Disaster Events**: Lose resources, damage bases
- **Political Events**: Country ownership changes

**Event Manager:**
```lua
EventManager = {
    events = {}, -- All possible events
    eventHistory = {}, -- Triggered events with cooldowns
    eventsPerMonth = 3, -- Target events per month
}

EventManager:update(turn, calendar) -- Trigger monthly events
EventManager:triggerRandomEvents(turn) -- Select and execute events
EventManager:selectEvent(availableEvents) -- Weighted random selection
EventManager:executeEvent(event, world) -- Apply event effects
EventManager:checkRequirements(event, world) -- Validate event can trigger
```

**Monthly Event Triggering:**
```lua
function EventManager:update(turn, calendar)
    -- Trigger on 15th of month (mid-month)
    if calendar:getDayOfMonth() ~= 15 then return end
    
    -- Get available events (not on cooldown, meet requirements)
    local available = self:getAvailableEvents(turn, calendar)
    if #available == 0 then return end
    
    -- Trigger N events
    for i = 1, self.eventsPerMonth do
        local event = self:selectEvent(available)
        if event then
            self:executeEvent(event, turn)
            event.lastTriggered = turn
            
            -- Remove from available list
            for j, e in ipairs(available) do
                if e.id == event.id then
                    table.remove(available, j)
                    break
                end
            end
        end
    end
end
```

**TOML Structure:**
```toml
[[event]]
id = "event_funding_boost"
name = "Additional Funding"
description = "A wealthy donor has provided additional funds"

weight = 10
cooldown = 60
minTurn = 30

[[event.effects]]
type = "money"
amount = 30000

[[event.effects]]
type = "message"
text = "You received $30,000 in additional funding!"

[[event]]
id = "event_alien_terror"
name = "Terror Attack"
description = "Aliens have launched a terror attack!"

weight = 5
cooldown = 90

[[event.effects]]
type = "mission"
missionType = "terror_site"
provinceId = "random"
factionId = "sectoids"

[[event.effects]]
type = "countryRelation"
countryId = "random"
delta = -1
```

**Estimated time:** 6 hours

---

### Phase 4: Integration & Turn Processing (12 hours)

#### Step 4.1: Turn Processor Integration (6 hours)
**Description:** Integrate lore systems into turn processing  
**Files to modify:**
- `engine/geoscape/systems/turn_processor.lua` (from TASK-025)

**Extended Turn Processing:**
```lua
function TurnProcessor:endTurn()
    local turn = Calendar:getCurrentTurn()
    local day = Calendar:getDayOfMonth()
    
    -- 1. Advance calendar
    Calendar:advanceTurn()
    
    -- 2. Update day/night cycle
    DayNightCycle:update(turn)
    
    -- 3. Reset craft travel points
    self:resetCraftTravelPoints()
    
    -- NEW: 4. Update missions (daily)
    MissionManager:update(turn)
    
    -- NEW: 5. Update campaigns (weekly or on schedule)
    CampaignManager:updateActiveCampaigns(turn)
    
    -- 6. Process missions (spawn/expiration)
    -- (Now handled by CampaignManager and MissionManager)
    
    -- NEW: 7. Monthly triggers
    if day == 1 then
        -- Spawn new campaigns (escalating)
        CampaignManager:spawnCampaigns(turn, Calendar)
        
        -- Update country funding
        self:updateCountryFunding()
    end
    
    -- NEW: 8. Mid-month events
    if day == 15 then
        EventManager:update(turn, Calendar)
    end
    
    -- NEW: 9. Update quests
    QuestManager:update(turn, World)
    
    -- 10. Process economy updates
    self:processEconomy()
    
    -- 11. Trigger region events
    self:triggerRegionEvents()
    
    -- 12. Save game state
    self:saveGameState()
    
    print("[TurnProcessor] Turn " .. turn .. " complete")
end
```

**Estimated time:** 6 hours

---

#### Step 4.2: Faction Research Integration (6 hours)
**Description:** Link research system to faction disabling  
**Files to create:**
- `engine/geoscape/systems/faction_research.lua`

**Faction Research:**
```lua
FactionResearch = {
    factionId = "sectoids",
    researchTree = {
        "sectoid_autopsy",
        "sectoid_commander_autopsy",
        "psionic_weapons",
        "mind_shield",
        "final_sectoid_countermeasure", -- Final research
    },
    completedResearch = {},
    finalResearchId = "final_sectoid_countermeasure",
}

FactionResearch:completeResearch(researchId)
FactionResearch:isFinalResearchComplete()
FactionResearch:disableFaction() -- Disable all campaigns
FactionResearch:getProgress() -- Return completion percentage
```

**Research Completion Handler:**
```lua
function FactionResearch:completeResearch(researchId, faction)
    table.insert(self.completedResearch, researchId)
    
    print("[FactionResearch] Completed: " .. researchId)
    
    -- Check if final research
    if researchId == self.finalResearchId then
        print("[FactionResearch] Final research complete! Disabling faction: " .. faction.id)
        
        -- Disable faction
        faction:disable()
        
        -- Disable all faction campaigns
        CampaignManager:disableFactionCampaigns(faction.id)
        
        -- Remove all faction missions
        MissionManager:removeFactionMissions(faction.id)
        
        -- Notify player
        UIManager:showMessage("You have defeated the " .. faction.name .. "!")
    end
end
```

**Estimated time:** 6 hours

---

### Phase 5: UI & Visualization (16 hours)

#### Step 5.1: Mission Display UI (6 hours)
**Description:** Display missions on world map and in panels  
**Files to create:**
- `engine/geoscape/ui/mission_panel.lua`
- `engine/geoscape/rendering/mission_renderer.lua`

**Mission Panel:**
```lua
MissionPanel = {
    position = {x = 24*35, y = 24*1}, -- Grid-snapped
    size = {width = 24*5, height = 24*28},
    
    missions = {}, -- Missions in selected province
    selectedMission = nil,
}

MissionPanel:update(provinceId)
MissionPanel:draw()
MissionPanel:showMissionDetails(mission)
```

**Mission Renderer:**
- Render mission icons on world map
- Different colors for mission types:
  - Site: Yellow triangle
  - UFO: Red circle (moving)
  - Base: Dark red square (permanent)
- Pulse animation for undetected missions
- Highlight intercepted missions

**Grid Snapping:** All UI elements must snap to 24×24 pixel grid

**Estimated time:** 6 hours

---

#### Step 5.2: Faction & Campaign UI (6 hours)
**Description:** Display faction status and active campaigns  
**Files to create:**
- `engine/geoscape/ui/faction_panel.lua`
- `engine/geoscape/ui/campaign_panel.lua`

**Faction Panel:**
```lua
FactionPanel = {
    position = {x = 24*1, y = 24*20}, -- Grid-snapped
    size = {width = 24*8, height = 24*9},
    
    factions = {}, -- All factions
    selectedFaction = nil,
}

-- Display:
-- - Faction name and icon
-- - Relations (-2 to +2) with color bar
-- - Research progress bar
-- - Disabled status (grayed out)
-- - Active campaigns count
```

**Campaign Panel:**
```lua
CampaignPanel = {
    position = {x = 24*10, y = 24*20}, -- Grid-snapped
    size = {width = 24*10, height = 24*9},
    
    campaigns = {}, -- Active campaigns this month
}

-- Display:
-- - Campaign list (max 10)
-- - Faction icon
-- - Next spawn time
-- - Missions spawned count
-- - Disabled campaigns (grayed out)
```

**Grid Snapping:** All UI elements must snap to 24×24 pixel grid

**Estimated time:** 6 hours

---

#### Step 5.3: Quest & Event Notifications (4 hours)
**Description:** Display quest progress and event notifications  
**Files to create:**
- `engine/geoscape/ui/quest_panel.lua`
- `engine/geoscape/ui/event_notification.lua`

**Quest Panel:**
```lua
QuestPanel = {
    position = {x = 24*1, y = 24*1}, -- Grid-snapped
    size = {width = 24*8, height = 24*9},
    
    activeQuests = {},
    selectedQuest = nil,
}

-- Display:
-- - Quest name
-- - Progress bars for conditions
-- - Time remaining (turns)
-- - Rewards/penalties preview
```

**Event Notification:**
```lua
EventNotification = {
    position = {x = 24*15, y = 24*10}, -- Grid-snapped (center)
    size = {width = 24*10, height = 24*6},
    
    event = nil, -- Current event to display
    displayDuration = 180, -- Frames (3 seconds)
}

-- Display:
-- - Event name and description
-- - Icon
-- - Effects applied
-- - Auto-dismiss after duration
```

**Grid Snapping:** All UI elements must snap to 24×24 pixel grid

**Estimated time:** 4 hours

---

### Phase 6: Testing & Polish (14 hours)

#### Step 6.1: Unit Tests (6 hours)
**Description:** Comprehensive unit tests for all systems  
**Files to create:**
- `engine/geoscape/tests/test_faction.lua`
- `engine/geoscape/tests/test_mission.lua`
- `engine/geoscape/tests/test_campaign_manager.lua`
- `engine/geoscape/tests/test_quest_manager.lua`
- `engine/geoscape/tests/test_event_manager.lua`
- `engine/geoscape/tests/test_script_engine.lua`

**Test Cases:**

**Faction Tests:**
- Relations update correctly (-2 to +2)
- Mission frequency adjusts based on relations
- Special missions trigger at relation -2
- Faction disabling works

**Mission Tests:**
- Site missions expire correctly
- UFO missions move via scripts
- Base missions spawn new missions
- Mission detection works

**Campaign Tests:**
- Campaigns spawn on 1st of month
- Escalation: 2 → 10 over 8 quarters
- Tech disabling removes campaigns
- Weekly spawning works

**Quest Tests:**
- Conditions evaluate correctly (AND/OR logic)
- Rewards granted on completion
- Penalties applied on failure
- Deadline tracking works

**Event Tests:**
- Events trigger monthly (15th)
- Cooldowns prevent re-triggering
- Requirements validated
- Effects applied correctly

**Script Tests:**
- UFO scripts execute steps
- Base scripts spawn missions
- Loop scripts repeat
- Script state persists

**Estimated time:** 6 hours

---

#### Step 6.2: Integration Testing (4 hours)
**Description:** Test full turn cycle with all systems  
**Files to create:**
- `engine/geoscape/tests/test_lore_integration.lua`

**Integration Test Scenarios:**

1. **Full Turn Cycle:**
   - Advance turn
   - Update missions (UFO movement, base spawning)
   - Update campaigns (weekly spawning)
   - Trigger monthly campaign spawning (1st)
   - Trigger monthly events (15th)
   - Update quests
   - Verify no errors

2. **Campaign Escalation:**
   - Start at Q1 with 2 campaigns/month
   - Advance 90 turns (Q2)
   - Verify 3 campaigns spawn
   - Advance to Q3, Q4, etc.
   - Verify escalation to 10/month by year 3

3. **Faction Disabling:**
   - Complete faction final research
   - Verify faction disabled
   - Verify campaigns removed
   - Verify missions removed

4. **Quest Completion:**
   - Activate quest
   - Meet conditions
   - Verify rewards granted
   - Verify quest marked complete

5. **Event Triggering:**
   - Advance to 15th of month
   - Verify 3 events trigger
   - Verify cooldowns work
   - Verify requirements checked

**Estimated time:** 4 hours

---

#### Step 6.3: Manual Testing & Polish (4 hours)
**Description:** Manual testing with Love2D console  
**Test checklist:**

- [ ] Run: `lovec "engine"`
- [ ] Navigate to Geoscape
- [ ] Advance to 1st of month
- [ ] Verify campaigns spawn (2 in Q1)
- [ ] Check mission icons on map
- [ ] Select mission, verify details panel
- [ ] Advance 7 turns, verify campaign spawns mission
- [ ] Select faction panel, verify relations display
- [ ] Advance to 15th, verify events trigger
- [ ] Check event notification display
- [ ] Activate quest, verify quest panel
- [ ] Complete quest conditions, verify rewards
- [ ] Advance to Q2, verify 3 campaigns spawn
- [ ] Complete faction research, verify disabling
- [ ] Verify no console errors/warnings

**Polish:**
- Smooth UI animations
- Clear mission/faction icons
- Intuitive quest progress display
- Event notifications readable
- Performance optimization (50+ missions)

**Estimated time:** 4 hours

---

### Phase 7: Documentation (10 hours)

#### Step 7.1: API Documentation (4 hours)
**Files to update:**
- `wiki/API.md`

**Add sections:**
- Faction API
- Mission API (Site, UFO, Base)
- Campaign API
- Quest API
- Event API
- Script Engine API
- Mission Manager API
- Campaign Manager API
- Quest Manager API
- Event Manager API

**Estimated time:** 4 hours

---

#### Step 7.2: Lore System Guide (4 hours)
**Files to create:**
- `wiki/LORE_SYSTEM_GUIDE.md`

**Contents:**
- Overview of lore systems
- How to create factions
- How to write mission scripts (UFO, base)
- How to define campaigns
- How to create quests
- How to add events
- Escalation mechanics
- Faction research and disabling
- Examples and best practices

**Estimated time:** 4 hours

---

#### Step 7.3: FAQ & Development Guide (2 hours)
**Files to update:**
- `wiki/FAQ.md`
- `wiki/DEVELOPMENT.md`

**FAQ Additions:**
- "How does mission spawning work?"
- "How do I disable a faction?"
- "What are campaigns?"
- "How does escalation work?"
- "How do quests work?"
- "What are random events?"

**Development Guide:**
- Adding new factions
- Creating mission scripts
- Defining campaigns
- Writing quest conditions
- Adding random events

**Estimated time:** 2 hours

---

## Total Time Estimate

| Phase | Hours |
|-------|-------|
| Phase 1: Core Data Structures | 16h |
| Phase 2: Mission Scripting System | 18h |
| Phase 3: Quest & Event Systems | 14h |
| Phase 4: Integration & Turn Processing | 12h |
| Phase 5: UI & Visualization | 16h |
| Phase 6: Testing & Polish | 14h |
| Phase 7: Documentation | 10h |
| **Total** | **100 hours** |

**Estimated Duration:** 12-13 days (8 hours/day) or 2.5-3 weeks

---

## Implementation Details

### Architecture

**Pattern:** Event-driven with script execution engine

**Components:**
1. **Faction System**: Core identity for enemy groups
2. **Mission System**: Three types (Site, UFO, Base) with distinct behaviors
3. **Campaign System**: Scriptable mission spawning per faction
4. **Script Engine**: Lua-based execution for UFO/base behaviors
5. **Quest System**: Flexible condition-based objectives
6. **Event System**: Random monthly world events
7. **Managers**: Campaign, Mission, Quest, Event managers
8. **Turn Integration**: Monthly/weekly/daily triggers

**Data Flow:**
```
Calendar Turn → Turn Processor
    ↓
Campaign Manager (monthly spawning)
    ↓
Campaign Scripts (weekly mission spawning)
    ↓
Mission Manager (daily updates)
    ↓
Script Engine (UFO movement, base growth)
    ↓
World State Update
```

### Key Design Decisions

1. **Script Engine**: Lua-based for flexibility and modding support
2. **Turn-Based**: All updates triggered by turn advancement, not real-time
3. **Escalation**: Linear growth (2 → 10) over 8 quarters
4. **Faction Disabling**: Final research removes all faction content
5. **Quest Flexibility**: Support AND/OR logic for complex conditions
6. **Event Independence**: Events not tied to campaigns for variety
7. **Grid-Snapped UI**: All UI at 24×24 pixel grid for consistency

### Dependencies

**Internal (TASK-025 Geoscape):**
- Calendar system (Phase 2) - Required for turn-based spawning
- Province system (Phase 1) - Required for mission placement
- World data (Phase 1) - Required for region/biome targeting
- Turn processor (Phase 8) - Extended for lore systems

**External:**
- Research system (Basescape) - For faction disabling
- Combat system (Battlescape) - For mission interception
- UI widgets (from widget system) - For panels and displays

---

## Testing Strategy

### Unit Tests
- Faction relations and mission frequency
- Mission type behaviors (Site, UFO, Base)
- Campaign spawning and escalation
- Quest condition evaluation (AND/OR)
- Event triggering and cooldowns
- Script engine execution

### Integration Tests
- Full turn cycle with all systems
- Campaign escalation over 8 quarters
- Faction disabling via research
- Quest completion flow
- Event triggering on 15th of month

### Manual Tests
1. Run: `lovec "engine"`
2. Advance to 1st of month → Verify campaigns spawn
3. Check mission icons on map
4. Advance 7 turns → Verify weekly mission spawning
5. Advance to 15th → Verify events trigger
6. Complete quest conditions → Verify rewards
7. Advance to Q2 → Verify 3 campaigns spawn
8. Complete final research → Verify faction disabled

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
print("[CampaignManager] Spawned campaign: " .. campaignId)
print("[MissionManager] UFO moved to province: " .. provinceId)
print("[QuestManager] Quest completed: " .. questId)
print("[EventManager] Event triggered: " .. eventId)
print("[ScriptEngine] Executing step: " .. action)
```

**Debug Commands:**
```lua
-- List active campaigns
CampaignManager:printActiveCampaigns()

-- List active missions
MissionManager:printActiveMissions()

-- Check quest progress
QuestManager:printQuestProgress(questId)

-- Trigger event manually (testing)
EventManager:triggerEvent(eventId, turn)

-- Complete research (testing)
FactionResearch:completeResearch(researchId, faction)
```

**Debug Keys:**
- **F1**: Show debug info (campaigns, missions, quests)
- **F2**: Toggle mission visualization
- **F3**: Show faction status
- **F9**: Toggle hex grid overlay

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add Lore System APIs
- [x] `wiki/FAQ.md` - Add Lore System FAQ
- [x] `wiki/DEVELOPMENT.md` - Add faction/campaign creation guide
- [ ] `wiki/LORE_SYSTEM_GUIDE.md` - Create comprehensive guide

---

## Notes

### Escalation Formula
```lua
campaignsPerMonth = min(
    baseCampaigns + (quarter - 1) * escalationRate,
    maxCampaigns
)

-- Examples:
Q1: 2 + (1-1)*1 = 2
Q2: 2 + (2-1)*1 = 3
Q3: 2 + (3-1)*1 = 4
Q4: 2 + (4-1)*1 = 5
Q5: 2 + (5-1)*1 = 6
Q6: 2 + (6-1)*1 = 7
Q7: 2 + (7-1)*1 = 8
Q8: 2 + (8-1)*1 = 9
Q9: 2 + (9-1)*1 = 10 (capped)
```

### Faction Disabling Impact
- All faction campaigns removed
- All faction missions removed
- Faction marked as disabled
- No new missions spawn for that faction
- Reduces total campaigns per month

### Performance Considerations
- Cache active missions by type (Site/UFO/Base)
- Limit script updates to active (non-intercepted) missions
- Use spatial hash for mission detection
- Lazy-load quest conditions (only check active quests)
- Event pool caching (pre-filter available events)

---

## Blockers

### Prerequisites
- **TASK-025 Phases 1-4**: Calendar, Province, World, Travel systems must be complete
- **Research System**: Needed for faction disabling (Basescape task)
- **UI Widgets**: Needed for panels and displays (Phase 7)

### External Dependencies
- **Combat System**: Needed for mission interception outcomes
- **Basescape**: Research tree integration

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] All UI elements snap to 24×24 pixel grid
- [ ] Faction system complete with relations
- [ ] Mission types (Site, UFO, Base) implemented
- [ ] Campaign spawning works with escalation
- [ ] Script engine executes UFO/base behaviors
- [ ] Quest system flexible with AND/OR conditions
- [ ] Events trigger monthly with cooldowns
- [ ] Turn processor integration complete
- [ ] Faction research disabling works
- [ ] All systems use `print()` for debug output
- [ ] API documentation complete
- [ ] Lore system guide written
- [ ] All tests pass
- [ ] No console errors when running with `lovec "engine"`

---

## What Worked Well

*(To be filled after completion)*

---

## Lessons Learned

*(To be filled after completion)*

---

**End of Task Document**
