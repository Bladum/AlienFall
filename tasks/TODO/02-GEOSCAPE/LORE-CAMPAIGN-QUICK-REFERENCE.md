# Lore & Campaign System - Quick Reference

**Task ID:** TASK-026  
**Status:** TODO  
**Priority:** Critical  
**Time Estimate:** 142 hours (18 days)  
**Dependencies:** TASK-025 Phases 1-3 (Core, Calendar, Geographic)

---

## System Overview

The **Lore & Campaign System** drives dynamic gameplay progression through:

- **Factions**: Enemy groups with unique identity, research trees
- **Campaigns**: Escalating threat (2→10 campaigns/month over 2 years)
- **Missions**: Site (static), UFO (mobile), Base (permanent)
- **Quests**: Conditional objectives with rewards/penalties
- **Events**: Random monthly occurrences (3-5/month)
- **Scripts**: Dynamic behaviors (UFO movement, base growth)

---

## Core Mechanics

### Campaign Escalation Formula
```lua
campaignsPerMonth = 2 + (currentQuarter - 1)
```

**Progression:**
- **Year 1 Q1:** 2 campaigns/month
- **Year 1 Q2:** 3 campaigns/month
- **Year 1 Q3:** 4 campaigns/month
- **Year 1 Q4:** 5 campaigns/month
- **Year 2 Q1:** 6 campaigns/month (quarter 5)
- **Year 2 Q2:** 7 campaigns/month
- **Year 2 Q3:** 8 campaigns/month
- **Year 2 Q4:** 9 campaigns/month
- **Year 3+:** 10+ campaigns/month

### Faction System
```lua
Faction = {
    id = "sectoid_collective",
    name = "Sectoid Collective",
    relations = 0, -- -2 (hostile) to +2 (allied)
    
    researchTree = {
        "sectoid_autopsy",
        "sectoid_interrogation",
        "sectoid_commander_capture",
        "sectoid_homeworld_location",
        "sectoid_peace_treaty" -- Final = disable campaigns
    },
    
    units = {"sectoid_soldier", "sectoid_leader"},
    items = {"plasma_pistol", "sectoid_corpse"},
    
    disabledCampaigns = {} -- Via research
}
```

**Relations Impact:**
- **-2 (Hostile):** High mission frequency, base assaults triggered
- **-1 (Unfriendly):** Normal mission frequency
- **0 (Neutral):** Reduced mission frequency
- **+1, +2 (Friendly/Allied):** Minimal missions (rare)

### Mission Types

#### Mission Site (Static)
- **Duration:** 7 days default
- **Behavior:** Waits in province until intercepted
- **Expiration:** Removed if not picked up, applies score penalty
- **Example:** Abduction site, terror site, crash site

#### Mission UFO (Mobile)
- **Behavior:** Follows daily movement script
- **Script Actions:** Move province, land, takeoff, wait, exit
- **Example:** Scout patrol, supply UFO, infiltrator

```lua
UFOScript = {
    steps = {
        {action = "move", targetProvince = "province_043", delay = 1},
        {action = "land", duration = 3},
        {action = "takeoff"},
        {action = "exit"}
    }
}
```

#### Mission Base (Permanent)
- **Behavior:** Grows weekly via script
- **Growth Stages:** Level 1 → Level 2 → Level 3 (max)
- **Spawning:** Creates missions based on level
- **Removal:** Only destroyed by player assault

```lua
BaseScript = {
    stages = {
        {level = 1, weeksToNextLevel = 4, missionTemplates = {"patrol"}},
        {level = 2, weeksToNextLevel = 6, missionTemplates = {"patrol", "abduction"}},
        {level = 3, weeksToNextLevel = -1, missionTemplates = {"patrol", "abduction", "terror"}}
    }
}
```

### Campaign System
```lua
Campaign = {
    id = "campaign_001",
    templateId = "sectoid_scout_wave",
    factionId = "sectoid_collective",
    active = true,
    disabled = false, -- Via research
    
    spawnFrequency = "weekly", -- OR delay in days
    missionScript = {
        type = "sequence", -- OR "random", "weighted"
        missions = {
            {template = "sectoid_abduction", weight = 50},
            {template = "sectoid_patrol_ufo", weight = 30}
        }
    },
    
    targetRegions = ["north_america", "europe"]
}
```

**Campaign Spawning:**
- **Monthly:** New campaigns generated on 1st day of month
- **Weekly:** Active campaigns spawn missions every 7 days
- **Disabling:** Faction research completion stops campaigns

### Quest System
```lua
Quest = {
    id = "quest_001",
    name = "First Contact",
    conditions = {
        {type = "missions_completed", faction = "sectoid_collective", count = 1}
    },
    rewards = {
        credits = 50000,
        items = ["special_weapon"]
    },
    penalties = {
        credits = -20000
    },
    timeLimit = 60 -- Days
}
```

**Condition Types:**
- `missions_completed` - Complete N missions
- `research_completed` - Complete specific research
- `base_built` - Build N bases
- `credits_earned` - Earn N credits
- `days_passed` - N days elapsed
- `enemies_killed` - Kill N enemies
- `faction_relations` - Achieve relation level
- `campaign_disabled` - Disable campaign via research

### Event System
```lua
Event = {
    id = "supply_shipment",
    name = "Supply Shipment Arrives",
    type = "random", -- OR "triggered"
    effects = {
        {type = "credits", amount = 10000},
        {type = "items", items = ["rifle"], quantity = 5},
        {type = "relations", faction = "sectoid_collective", delta = 1}
    },
    weight = 10 -- Probability weight
}
```

**Event Frequency:** 3-5 random events per month

**Effect Types:**
- `credits` - Modify player credits
- `items` - Add items to storage
- `relations` - Change faction relations
- `spawn_mission` - Create special mission
- `research_progress` - Bonus research points
- `base_damage` - Damage player base
- `craft_damage` - Damage player craft

---

## Calendar Integration

### Daily Hooks (Every Day)
```lua
-- UFO script execution
MissionManager:processDailyMissions()

-- Campaign delay counters
CampaignManager:processDailyCampaigns()

-- Site mission expiration checks
MissionManager:checkExpirations()
```

### Weekly Hooks (Every 7 Days)
```lua
-- Base growth scripts
MissionManager:processWeeklyMissions()

-- Campaign mission spawning
CampaignManager:processWeeklyCampaigns()
```

### Monthly Hooks (1st Day of Month)
```lua
-- Campaign generation with escalation
CampaignGenerator:generateMonthlyCampaigns(calendar)

-- Event generation (3-5 events)
EventGenerator:generateMonthlyEvents()

-- Faction updates
FactionManager:processFactionEvents()

-- Quest updates
QuestManager:updateQuests(day)
```

---

## Key APIs

### Faction API
```lua
Faction:updateRelations(delta) -- Change relations
Faction:isHostile() -- Check if relations <= -2
Faction:canSpawnCampaign(campaignId) -- Check if not disabled
Faction:disableCampaign(campaignId) -- Disable via research
Faction:getAvailableUnits() -- Get faction units
```

### Campaign API
```lua
CampaignGenerator:generateMonthlyCampaigns(calendar)
CampaignGenerator:calculateCampaignsPerMonth(quarter)
CampaignManager:processWeeklyCampaigns()
CampaignManager:spawnMissionFromCampaign(campaign)
CampaignManager:disableCampaign(campaignId)
```

### Mission API
```lua
MissionManager:processDailyMissions() -- UFO scripts
MissionManager:processWeeklyMissions() -- Base scripts
MissionSite:expire() -- Handle expiration
MissionUFO:executeScript() -- Execute daily script
MissionBase:grow() -- Increase level
```

### Quest API
```lua
QuestManager:updateQuests(day) -- Check conditions
QuestManager:completeQuest(questId) -- Apply rewards
QuestManager:failQuest(questId) -- Apply penalties
QuestConditions:evaluate(quest, gameState) -- Check all conditions
QuestConditions:getConditionProgress(condition, gameState)
```

### Event API
```lua
EventGenerator:generateMonthlyEvents() -- Create 3-5 events
EventManager:applyEventEffects(event) -- Execute effects
EventManager:getMonthlyEvents()
```

---

## Data File Examples

### Faction Definition (factions.toml)
```toml
[[faction]]
id = "sectoid_collective"
name = "Sectoid Collective"
description = "Hive-mind alien race"
initialRelations = 0
escalationThreshold = -2

[faction.researchTree]
nodes = [
    "sectoid_autopsy",
    "sectoid_interrogation",
    "sectoid_peace_treaty"
]

[faction.units]
soldiers = ["sectoid_soldier"]
commanders = ["sectoid_commander"]
```

### Campaign Template (campaigns.toml)
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
```

### UFO Script (ufo_scripts.toml)
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
action = "exit"
```

### Quest Definition (quests.toml)
```toml
[[quest]]
id = "first_contact"
name = "First Contact"
timeLimit = 60

[[quest.conditions]]
type = "missions_completed"
faction = "sectoid_collective"
count = 1

[quest.rewards]
credits = 50000
items = ["special_weapon"]
```

---

## Implementation Phases

### Phase 1: Faction System (12h)
- Faction data structure
- Faction manager
- Research integration

### Phase 2: Campaign System (18h)
- Campaign data structure
- Campaign generator with escalation formula
- Campaign manager with weekly processing

### Phase 3: Mission System (24h)
- Mission base structure
- Mission Site (static)
- Mission UFO (mobile with scripts)
- Mission Base (permanent with growth)

### Phase 4: Quest System (16h)
- Quest data structure
- Quest condition system
- Quest manager

### Phase 5: Event System (12h)
- Event data structure
- Event generator (3-5/month)
- Event manager with effect application

### Phase 6: Calendar Integration (10h)
- Calendar hooks (daily/weekly/monthly)
- Mission manager with processing
- Turn processor integration

### Phase 7: Scripting Engine (14h)
- Script parser (TOML loading)
- Script executor (UFO/Base/Campaign)
- Script debugger tools

### Phase 8: UI Implementation (16h)
- Campaign panel
- Quest panel
- Event log
- Faction info panel

### Phase 9: Integration & Testing (12h)
- Full system integration
- Test suite (unit + integration)
- Manual testing (full campaign cycle)

### Phase 10: Documentation (8h)
- API documentation
- Data file guide
- FAQ updates

---

## Testing Checklist

### Unit Tests
- [x] Campaign escalation formula (2→10)
- [x] Faction relations update
- [x] UFO script execution (all actions)
- [x] Base growth stages
- [x] Quest condition evaluation
- [x] Event random selection

### Integration Tests
- [ ] Full campaign cycle (Q1→Year 2)
- [ ] Mission spawning from campaigns
- [ ] UFO movement between provinces
- [ ] Base growth and mission spawning
- [ ] Quest completion/failure
- [ ] Event generation and effects
- [ ] Faction research disabling campaigns

### Manual Testing
1. Start new game at Year 1 Q1
2. Verify 2 campaigns spawn
3. Advance to Q2, verify 3 campaigns
4. Monitor mission spawning (weekly)
5. Test UFO movement scripts
6. Let alien base grow (4 weeks to level 2)
7. Complete quests
8. Trigger events (advance to new month)
9. Research faction tech, verify campaigns disabled
10. Continue to Year 2, verify 6+ campaigns/month

---

## Debug Commands

### Console Debugging
```lua
print("[Faction] " .. factionId .. " relations: " .. relations)
print("[Campaign] Generated " .. count .. " campaigns for month " .. month)
print("[Mission] UFO moved to province " .. provinceId)
print("[Quest] Quest completed: " .. questId)
print("[Event] Event triggered: " .. event.name)
```

### Debug Keys
- **F1:** Show campaign/quest/event debug info
- **F9:** Toggle hex grid (mission positions)
- **F10:** Force campaign generation (skip to next month)

### Script Debugging
```lua
ScriptDebugger.enabled = true
ScriptDebugger:visualizeUFOPath(ufoMission)
ScriptDebugger:dumpScript(script)
```

---

## Performance Notes

- **Mission Limit:** ~100 active missions (manageable)
- **Campaign Limit:** ~50 active campaigns (10/month × 5 factions)
- **Script Execution:** Batch daily/weekly processing
- **Condition Caching:** Cache quest progress

---

## Integration with TASK-025

### Required from TASK-025:
- ✅ Calendar System (Phase 2) - Daily/weekly/monthly hooks
- ✅ Province System (Phase 1) - Mission placement
- ✅ Radar System (Phase 4) - Mission detection

### Implementation Order:
1. Complete TASK-025 Phases 1-3 first
2. Start TASK-026 Phase 1 (Factions)
3. Develop TASK-026 Phases 2-5 in parallel with TASK-025
4. Integrate in TASK-026 Phase 6

---

**Full Task Document:** [TASK-026-geoscape-lore-campaign-system.md](TASK-026-geoscape-lore-campaign-system.md)
