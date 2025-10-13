# Geoscape Lore & Mission System - Quick Reference

**Task ID:** TASK-026  
**Status:** TODO  
**Priority:** Critical  
**Time Estimate:** 100 hours (12-13 days)  
**Dependencies:** TASK-025 (Geoscape) Phases 1-4

---

## System Overview

The **Lore & Mission System** is the dynamic campaign engine that creates escalating threats, faction-based progression, and narrative depth for the Geoscape strategic layer.

### Core Components

1. **Factions**: Enemy groups with unique lore, units, research trees
2. **Campaigns**: Script-based mission spawners (weekly/delayed)
3. **Missions**: Site (static), UFO (moving), Base (permanent)
4. **Scripts**: Lua-based UFO movement and base growth behaviors
5. **Quests**: Flexible condition-based objectives
6. **Events**: Random monthly world events

---

## Core Mechanics

### Escalation System

**Campaign Spawning:**
- Starts: **2 campaigns/month** (Quarter 1)
- Increases: **+1 campaign/month per quarter**
- Max: **10 campaigns/month** (Quarter 9+, ~2 years)
- Trigger: **1st day of each month**

**Formula:**
```lua
campaignsPerMonth = min(
    2 + (quarter - 1),
    10
)
```

**Timeline:**
```
Q1 (Months 1-3):   2 campaigns/month
Q2 (Months 4-6):   3 campaigns/month
Q3 (Months 7-9):   4 campaigns/month
Q4 (Months 10-12): 5 campaigns/month
Q5 (Months 13-15): 6 campaigns/month
Q6 (Months 16-18): 7 campaigns/month
Q7 (Months 19-21): 8 campaigns/month
Q8 (Months 22-24): 9 campaigns/month
Q9+ (Months 25+):  10 campaigns/month (capped)
```

### Faction System

**Faction Structure:**
```lua
Faction = {
    id = "sectoids",
    name = "Sectoid Empire",
    lore = "Background story...",
    relations = 0, -- -2 to +2
    disabled = false,
    
    -- Content
    unitIds = {"sectoid_soldier", "sectoid_commander"},
    itemIds = {"plasma_pistol", "mind_probe"},
    researchTreeId = "sectoid_research",
    
    -- Missions
    baseMissionFrequency = 2, -- Per month
    relationModifiers = {
        [-2] = 2.0,  -- 2x missions at hostile
        [-1] = 1.5,
        [0] = 1.0,
        [1] = 0.7,
        [2] = 0.4    -- 60% fewer at allied
    }
}
```

**Relations Impact:**
- **-2 (Hostile)**: 2x missions, special missions (base assault)
- **-1 (Unfriendly)**: 1.5x missions
- **0 (Neutral)**: Normal mission frequency
- **+1 (Friendly)**: 0.7x missions
- **+2 (Allied)**: 0.4x missions

**Faction Disabling:**
- Player researches faction tech tree
- Final research disables faction permanently
- All faction campaigns removed
- All faction missions removed
- No new missions spawn for that faction

---

## Mission Types

### 1. Mission Site (Static)

**Characteristics:**
- Spawns in province and stays fixed
- Player must intercept before expiration
- Scores points against player if missed
- Examples: Crash site, terror site, supply ship

**Structure:**
```lua
MissionSite = {
    type = "site",
    siteType = "crash_site",
    provinceId = "province_042",
    spawnTurn = 100,
    expirationTurn = 130, -- 30 turns duration
    scoreValue = 10,
    detected = false
}
```

### 2. Mission UFO (Moving)

**Characteristics:**
- Moves between provinces via script
- Can land, patrol, attack bases
- Executes daily script steps
- Can be intercepted in air or on ground

**Structure:**
```lua
MissionUFO = {
    type = "ufo",
    ufoType = "scout",
    scriptId = "scout_patrol_01",
    currentScriptStep = 1,
    provinceId = "province_042",
    targetProvinceId = "province_043",
    landed = false,
    hp = 100,
    destroyed = false
}
```

**Example UFO Script:**
```lua
scout_patrol_01 = {
    steps = {
        {action = "moveTo", params = {provinceId = "province_042"}},
        {action = "patrol", params = {radius = 3, turns = 14}},
        {action = "land", params = {biome = "urban", duration = 7}},
        {action = "takeOff"},
        {action = "returnToBase"}
    }
}
```

### 3. Mission Base (Permanent)

**Characteristics:**
- Permanent mission until destroyed
- Grows over time (5 growth levels)
- Spawns additional missions periodically
- Executes daily script for growth

**Structure:**
```lua
MissionBase = {
    type = "base",
    baseType = "small_base",
    scriptId = "base_growth_standard",
    provinceId = "province_042",
    growthLevel = 1, -- 1-5
    growthInterval = 60, -- Turns between growth
    spawnInterval = 14, -- Turns between mission spawns
    lastSpawnTurn = 100,
    hp = 500,
    destroyed = false
}
```

**Example Base Script:**
```lua
base_growth_standard = {
    steps = {
        {action = "wait", params = {turns = 60}},
        {action = "grow"},
        {action = "spawnMission", params = {type = "ufo", script = "scout_patrol_01"}},
        {action = "wait", params = {turns = 14}},
        {action = "spawnMission", params = {type = "site"}},
        {action = "wait", params = {turns = 60}},
        {action = "grow"},
        {action = "upgradeDefenses", params = {hpBonus = 200}}
    },
    loop = true
}
```

---

## Campaign System

**Campaign Structure:**
```lua
Campaign = {
    id = "campaign_sectoid_recon_001",
    factionId = "sectoids",
    scriptId = "sectoid_recon_wave",
    active = true,
    disabled = false,
    
    spawnInterval = 7, -- Turns (1 week)
    lastSpawnTurn = 100,
    
    missionTypes = {"ufo", "site"},
    missionScripts = {"scout_patrol_01", "fighter_intercept_01"},
    
    targetRegions = {"north_america", "europe"},
    targetBiomes = {"urban", "temperate"}
}
```

**Campaign Lifecycle:**
1. **Spawn**: Randomly generated on 1st of month
2. **Active**: Spawns missions weekly or on delay
3. **Disabled**: Removed via faction research progress
4. **Expired**: Optional end turn (most are indefinite)

**Mission Spawning:**
- Campaigns spawn missions weekly (7 turns)
- Or custom delay per campaign
- Selects random mission type from `missionTypes`
- Selects random script from `missionScripts`
- Places in random province matching `targetRegions`/`targetBiomes`

---

## Quest System

**Quest Structure:**
```lua
Quest = {
    id = "quest_research_plasma",
    name = "Plasma Weapons Research",
    active = false,
    completed = false,
    failed = false,
    
    deadlineTurns = 90, -- 3 months
    
    conditions = {
        {type = "researchComplete", params = {researchId = "plasma_weapons"}},
        {type = "missionsCompleted", params = {count = 5, factionId = "sectoids"}}
    },
    conditionLogic = "AND", -- "AND" or "OR"
    
    rewards = {
        {type = "money", params = {amount = 50000}},
        {type = "item", params = {itemId = "plasma_rifle", count = 3}}
    },
    
    penalties = {
        {type = "money", params = {amount = -20000}},
        {type = "countryRelation", params = {countryId = "usa", delta = -1}}
    }
}
```

**Condition Types:**
- `researchComplete`: Check research done
- `missionsCompleted`: Check mission count
- `basesBuilt`: Check base count
- `craftDeployed`: Check deployments
- `itemCrafted`: Check item crafted
- `enemyKilled`: Check kill count
- `beforeTurn`: Time limit
- `factionRelation`: Check relations
- `resourceAmount`: Check money/fuel/items

**Quest Lifecycle:**
1. **Activate**: Quest becomes active
2. **Check**: Conditions evaluated every turn
3. **Complete**: Rewards granted, quest marked done
4. **Fail**: Penalties applied if deadline missed

---

## Event System

**Event Structure:**
```lua
Event = {
    id = "event_funding_boost",
    name = "Additional Funding",
    weight = 10, -- Chance weight
    cooldown = 60, -- Turns before re-trigger
    
    requirements = {
        minTurn = 30,
        requiredRelation = {countryId = "usa", min = 0}
    },
    
    effects = {
        {type = "money", params = {amount = 30000}},
        {type = "message", params = {text = "You received $30,000!"}}
    }
}
```

**Event Types:**
- **Resource**: Money, fuel, items
- **Relation**: Country/faction relations
- **Mission**: Spawn one-off mission
- **Tech**: Unlock research
- **Disaster**: Lose resources, damage bases
- **Political**: Country ownership changes

**Event Triggering:**
- Triggers on **15th of each month** (mid-month)
- **3 events per month** (configurable)
- Weighted random selection
- Cooldown prevents re-triggering
- Requirements must be met

---

## Script Actions Reference

### UFO Script Actions

| Action | Params | Description |
|--------|--------|-------------|
| `moveTo` | `provinceId` or `region` | Move to target province/region |
| `patrol` | `radius`, `turns` | Patrol N provinces for T turns |
| `land` | `biome`, `duration` | Land in province (filtered by biome) |
| `takeOff` | - | Take off from landed state |
| `attack` | `targetType`, `duration` | Attack player base/craft |
| `returnToBase` | - | Return to faction base and despawn |
| `wait` | `turns` | Wait for N turns |
| `changeRegion` | `region` | Move to different region |

### Base Script Actions

| Action | Params | Description |
|--------|--------|-------------|
| `grow` | - | Increase growth level (1→2→3→4→5) |
| `spawnMission` | `type`, `script` | Spawn mission (UFO/Site) |
| `upgradeDefenses` | `hpBonus` | Increase base HP |
| `expandRadius` | `radius` | Increase spawn radius |
| `wait` | `turns` | Wait for N turns |

---

## Turn Processing Integration

**Extended Turn Processor:**
```lua
function TurnProcessor:endTurn()
    -- 1-3. Existing: Calendar, day/night, craft reset
    
    -- 4. Update missions (daily)
    MissionManager:update(turn)
    
    -- 5. Update campaigns (weekly)
    CampaignManager:updateActiveCampaigns(turn)
    
    -- 6. Monthly triggers (1st of month)
    if day == 1 then
        CampaignManager:spawnCampaigns(turn, Calendar)
        -- Update country funding
    end
    
    -- 7. Mid-month events (15th)
    if day == 15 then
        EventManager:update(turn, Calendar)
    end
    
    -- 8. Update quests
    QuestManager:update(turn, World)
    
    -- 9-12. Existing: Economy, region events, save
end
```

---

## Data File Structures

### Faction TOML

```toml
[[faction]]
id = "sectoids"
name = "Sectoid Empire"
lore = "Background story..."

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

### Campaign TOML

```toml
[[campaign]]
id = "campaign_sectoid_recon_001"
factionId = "sectoids"
scriptId = "sectoid_recon_wave"

spawnInterval = 7
missionTypes = ["ufo", "site"]
missionScripts = ["scout_patrol_01", "fighter_intercept_01"]

targetRegions = ["north_america", "europe"]
targetBiomes = ["urban", "temperate"]

difficultyScaling = true
baseDifficulty = 1.0
```

### Quest TOML

```toml
[[quest]]
id = "quest_research_plasma"
name = "Plasma Weapons Research"
deadlineTurns = 90
conditionLogic = "AND"

[[quest.conditions]]
type = "researchComplete"
researchId = "plasma_weapons"

[[quest.rewards]]
type = "money"
amount = 50000

[[quest.penalties]]
type = "money"
amount = -20000
```

### Event TOML

```toml
[[event]]
id = "event_funding_boost"
name = "Additional Funding"
weight = 10
cooldown = 60

[[event.effects]]
type = "money"
amount = 30000
```

---

## Implementation Phases

| Phase | Description | Time |
|-------|-------------|------|
| **1** | Core Data Structures | 16h |
| **2** | Mission Scripting System | 18h |
| **3** | Quest & Event Systems | 14h |
| **4** | Integration & Turn Processing | 12h |
| **5** | UI & Visualization | 16h |
| **6** | Testing & Polish | 14h |
| **7** | Documentation | 10h |
| **Total** | **100 hours** |

---

## Key APIs

### Faction

```lua
Faction:updateRelations(delta)
Faction:getMissionFrequency()
Faction:canSpawnSpecialMission(type)
Faction:disable()
Faction:isDisabled()
```

### Mission

```lua
Mission:update(turn)
Mission:detect(radarPower)
Mission:scoreAgainstPlayer()
Mission:expire()

MissionUFO:updateScript(turn)
MissionUFO:moveTo(provinceId)
MissionUFO:land()
MissionUFO:takeOff()

MissionBase:grow(turn)
MissionBase:spawnMission(turn)
MissionBase:shouldSpawn(turn)
```

### Campaign

```lua
Campaign:shouldSpawn(turn)
Campaign:spawnMission(world)
Campaign:disable()
Campaign:updateDifficulty(turn)
```

### Script Engine

```lua
ScriptEngine:loadScript(scriptId)
ScriptEngine:startScript(missionId, scriptId)
ScriptEngine:updateScript(missionId, turn)
ScriptEngine:stopScript(missionId)
```

### Quest

```lua
QuestManager:update(turn, world)
QuestManager:activateQuest(questId, turn)
QuestManager:checkConditions(quest, world)
QuestManager:completeQuest(questId)
QuestManager:failQuest(questId)
```

### Event

```lua
EventManager:update(turn, calendar)
EventManager:triggerRandomEvents(turn)
EventManager:selectEvent(availableEvents)
EventManager:executeEvent(event, world)
```

---

## Debug Commands

```lua
-- List active campaigns
print("[Debug] Active campaigns: " .. #CampaignManager.campaigns)
CampaignManager:printActiveCampaigns()

-- List active missions
print("[Debug] Active missions: " .. #MissionManager.missions)
MissionManager:printActiveMissions()

-- Trigger campaign spawn (testing)
CampaignManager:spawnCampaigns(turn, Calendar)

-- Trigger event (testing)
EventManager:triggerEvent("event_funding_boost", turn)

-- Complete faction research (testing)
FactionResearch:completeResearch("final_sectoid_countermeasure", faction)

-- Check quest progress
QuestManager:printQuestProgress("quest_research_plasma")
```

---

## Performance Notes

- Cache active missions by type (Site/UFO/Base)
- Limit script updates to active missions only
- Use spatial hash for mission detection
- Lazy-load quest conditions
- Event pool caching

---

## Testing Checklist

- [ ] Campaigns spawn on 1st of month
- [ ] Escalation: 2 → 10 over 8 quarters
- [ ] Factions have unique lore/units/research
- [ ] Mission types work (Site/UFO/Base)
- [ ] UFO scripts move provinces
- [ ] Base scripts spawn missions
- [ ] Quests activate and check conditions
- [ ] Rewards granted on quest completion
- [ ] Penalties applied on quest failure
- [ ] Events trigger on 15th of month
- [ ] Event cooldowns work
- [ ] Faction relations affect mission frequency
- [ ] Final research disables faction
- [ ] No console errors

---

**Full Task Document:** [TASK-026-geoscape-lore-mission-system.md](TASK-026-geoscape-lore-mission-system.md)
