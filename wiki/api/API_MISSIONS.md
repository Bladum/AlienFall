# API: Missions & Objectives

**Version**: 1.0  
**Last Updated**: October 21, 2025  
**Purpose**: Complete reference for mission types, objectives, difficulty scaling, and tactical scenario design  
**Audience**: Campaign designers, TOML modders, Lua developers  

---

## Quick Start: Lua Developer

### Get All Missions

```lua
local DataLoader = require("engine.core.data_loader")
local missions = DataLoader.mission.getAllIds()

for _, missionId in ipairs(missions) do
    local mission = DataLoader.mission.get(missionId)
    print(mission.name .. ": " .. mission.mission_type .. " (Difficulty: " .. mission.difficulty .. ")")
end
```

### Get Missions by Type

```lua
local function getMissionsByType(missionType)
    local allMissions = DataLoader.mission.getAllIds()
    local results = {}
    
    for _, missionId in ipairs(allMissions) do
        local mission = DataLoader.mission.get(missionId)
        if mission.mission_type == missionType then
            table.insert(results, mission)
        end
    end
    
    return results
end

local rescueMissions = getMissionsByType("rescue")
```

### Get Active Missions

```lua
local function getActiveMissions(geoscapeState)
    local missions = {}
    
    for _, missionId in ipairs(geoscapeState.active_mission_ids) do
        table.insert(missions, DataLoader.mission.get(missionId))
    end
    
    return missions
end
```

---

## Quick Start: TOML Modder

### Create a Rescue Mission

```toml
[[mission]]
id = "mission_rescue_scientists"
name = "Rescue Scientists"
mission_type = "rescue"
description = "Rescue kidnapped scientists from alien research facility"
location = "Europe"
difficulty = "hard"
reward_credits = 2000
reward_technology_points = 150
reward_reputation = [20, -10]  # [friends, enemies]
min_squad_size = 4
max_squad_size = 6
recommended_squad_size = 5
enemy_types = ["sectoid", "sectoid_commander"]
enemy_count_min = 8
enemy_count_max = 12
map_type = "alien_base_interior"
turn_limit = 30
objectives = ["rescue_all_scientists", "eliminate_enemies"]
```

### Create a Classic UFO Recovery Mission

```toml
[[mission]]
id = "mission_ufo_recovery"
name = "UFO Recovery"
mission_type = "ufo_recovery"
description = "Secure downed UFO for research and salvage"
difficulty = "medium"
reward_credits = 3000
reward_alien_artifacts = 5
enemy_types = ["floater", "sectoid"]
enemy_count_min = 6
enemy_count_max = 10
recommended_squad_size = 6
```

---

## Mission System

### Mission Schema

**File Location**: `mods/[modname]/content/rules/missions/missions.toml`

```toml
[[mission]]
id = "string - unique identifier (e.g., 'mission_terror_attack')"
name = "string - human-readable mission name"
mission_type = "enum - reconnaissance|terror|abduction|ufo_recovery|rescue|defense|investigation|sabotage"
description = "string - mission briefing text"
location = "string - geoscape location where mission occurs"
difficulty = "enum - trivial|easy|medium|hard|impossible"
player_difficulty_offset = "integer - difficulty adjustment (-2 to +2)"
reward_credits = "integer - credits earned on success (500-5000)"
reward_technology_points = "integer - research points earned (50-500)"
reward_reputation = ["array - [friends_modifier, enemies_modifier]"]
reward_alien_artifacts = "integer - alien artifacts earned (0-10)"
reward_xp_multiplier = "float - squad XP multiplier (0.5-2.0)"
min_squad_size = "integer - minimum soldiers (1-8)"
max_squad_size = "integer - maximum soldiers (3-12)"
recommended_squad_size = "integer - suggested squad size (3-8)"
enemy_types = ["array - alien types that appear"]
enemy_count_min = "integer - minimum enemies (2-30)"
enemy_count_max = "integer - maximum enemies (4-50)"
map_type = "enum - city|farm|industrial|forest|alien_base|crash_site"
terrain_difficulty = "enum - flat|hilly|dense"
turn_limit = "integer - tactical turn limit (0=unlimited, usually 20-40)"
objectives = ["array - objective ids to complete"]
required_technology = "string - technology that must be researched (optional)"
one_time_only = "boolean - can mission only be played once"
repeatable = "boolean - can mission be replayed"
min_campaign_month = "integer - earliest month available (1-24)"
max_campaign_month = "integer - latest month available (1-36)"
hidden = "boolean - not visible until triggered"
trigger_condition = "string - condition for mission to appear (optional)"

[mission.civilian_presence]
min_civilians = "integer - minimum civilian count (0-50)"
max_civilians = "integer - maximum civilian count (0-100)"

[mission.environmental_hazard]
hazard_type = "enum - fire|radiation|poison_gas|none"
hazard_intensity = "enum - mild|moderate|severe"
hazard_coverage = "integer - percentage of map affected (0-100)"
```

### Mission Types

| Type | Purpose | Rewards | Difficulty | Turn Limit |
|------|---------|---------|-----------|-----------|
| **reconnaissance** | Scout alien activity | Low credits, intel | Easy-Medium | Unlimited |
| **terror** | Stop alien terror attack | Medium credits, reputation | Medium-Hard | 30 turns |
| **abduction** | Rescue abductees | High credits, reputation | Medium | 25 turns |
| **ufo_recovery** | Secure crashed UFO | High credits, artifacts | Medium-Hard | 20 turns |
| **rescue** | Rescue hostages | Medium credits, reputation | Hard | 30 turns |
| **defense** | Defend base from attack | Medium credits, XP | Medium | Unlimited |
| **investigation** | Investigate alien facility | Medium credits, intel | Hard | Unlimited |
| **sabotage** | Destroy alien structure | High credits, progress | Hard | 25 turns |

### Difficulty Tiers

| Tier | Name | Enemy Power | Rewards | XP Multiplier |
|------|------|-----------|---------|---|
| **1** | Trivial | 50% | 50% | 0.5x |
| **2** | Easy | 75% | 75% | 0.75x |
| **3** | Medium | 100% | 100% | 1.0x |
| **4** | Hard | 125% | 125% | 1.25x |
| **5** | Impossible | 150% | 150% | 1.5x |

---

## Mission Examples

### Reconnaissance Mission

```toml
[[mission]]
id = "mission_scout_activity"
name = "Scout Activity"
mission_type = "reconnaissance"
description = "Investigate suspicious activity reported in rural area. Engage only if necessary."
location = "North America"
difficulty = "easy"
reward_credits = 500
reward_technology_points = 50
reward_reputation = [10, 5]
min_squad_size = 2
recommended_squad_size = 4
max_squad_size = 6
enemy_types = ["sectoid", "sectoid_elite"]
enemy_count_min = 3
enemy_count_max = 6
map_type = "farm"
terrain_difficulty = "flat"
turn_limit = 0  # Unlimited
objectives = ["scout_area", "report_findings"]

[mission.civilian_presence]
min_civilians = 0
max_civilians = 5
```

### Terror Attack Mission

```toml
[[mission]]
id = "mission_terror_attack_city"
name = "Terror Attack - City Center"
mission_type = "terror"
description = "Alien forces attacking city center! Civilians under fire! All units respond immediately!"
difficulty = "hard"
reward_credits = 2000
reward_technology_points = 200
reward_reputation = [50, -20]
reward_xp_multiplier = 1.5
min_squad_size = 4
recommended_squad_size = 6
max_squad_size = 8
enemy_types = ["floater", "floater_elite", "sectoid_commander"]
enemy_count_min = 10
enemy_count_max = 15
map_type = "city"
terrain_difficulty = "dense"
turn_limit = 30
objectives = ["eliminate_all_enemies", "protect_civilians"]

[mission.civilian_presence]
min_civilians = 10
max_civilians = 30
```

### UFO Recovery Mission

```toml
[[mission]]
id = "mission_ufo_recovery_large"
name = "Large UFO Recovery"
mission_type = "ufo_recovery"
description = "Large UFO crashed 5 miles from base. Secure for analysis and salvage."
difficulty = "hard"
reward_credits = 3500
reward_alien_artifacts = 8
reward_technology_points = 300
reward_reputation = [30, -15]
min_squad_size = 5
recommended_squad_size = 6
max_squad_size = 8
enemy_types = ["sectoid", "sectoid_commander", "muton"]
enemy_count_min = 12
enemy_count_max = 18
map_type = "crash_site"
terrain_difficulty = "hilly"
turn_limit = 25
objectives = ["secure_ufo", "eliminate_enemies"]
reward_xp_multiplier = 1.3
```

### Rescue Mission

```toml
[[mission]]
id = "mission_rescue_hostages"
name = "Rescue Hostages"
mission_type = "rescue"
description = "Intel suggests abducted civilians are being held in alien facility. Extract before execution."
difficulty = "hard"
reward_credits = 2500
reward_technology_points = 250
reward_reputation = [40, -10]
min_squad_size = 4
recommended_squad_size = 5
max_squad_size = 6
enemy_types = ["sectoid", "muton"]
enemy_count_min = 8
enemy_count_max = 12
map_type = "alien_base"
terrain_difficulty = "dense"
turn_limit = 30
objectives = ["rescue_all_hostages", "extract_to_exit"]

[mission.civilian_presence]
min_civilians = 5
max_civilians = 10
```

### Sabotage Mission

```toml
[[mission]]
id = "mission_destroy_reactor"
name = "Destroy Alien Reactor"
mission_type = "sabotage"
description = "Infiltrate alien facility and destroy power reactor to disable defense systems."
difficulty = "impossible"
reward_credits = 5000
reward_technology_points = 500
reward_reputation = [50, -30]
reward_xp_multiplier = 2.0
min_squad_size = 6
recommended_squad_size = 8
max_squad_size = 10
enemy_types = ["sectoid_commander", "muton", "ethereal"]
enemy_count_min = 15
enemy_count_max = 25
map_type = "alien_base_interior"
terrain_difficulty = "dense"
turn_limit = 20
objectives = ["locate_reactor", "plant_explosives", "extract"]
required_technology = "tech_alien_bases"
```

---

## Objectives System

### Objective Schema

**File Location**: `mods/[modname]/content/rules/missions/objectives.toml`

```toml
[[objective]]
id = "string - unique identifier (e.g., 'eliminate_all_enemies')"
name = "string - objective name"
type = "enum - eliminate|rescue|protect|escape|reach|investigate|defend|sabotage"
description = "string - objective description"
required = "boolean - must complete to succeed"
optional = "boolean - bonus/alt objective"
primary = "boolean - primary objective shown in HUD"
victory_condition = "boolean - completes mission on success"
failure_condition = "boolean - fails mission if not completed"
completion_value = "integer - for progress-based objectives"
location_hint = "string - hint about where to complete objective"

[objective.rewards]
bonus_credits = "integer - extra credits if completed"
bonus_xp = "integer - extra XP multiplier"
bonus_reputation = ["array - reputation changes"]
```

### Common Objectives

```toml
[[objective]]
id = "eliminate_all_enemies"
name = "Eliminate All Enemies"
type = "eliminate"
description = "Eliminate all hostile aliens"
required = true
primary = true
victory_condition = true

[[objective]]
id = "eliminate_leader"
name = "Eliminate Alien Leader"
type = "eliminate"
description = "Target priority: Eliminate alien commander"
required = false
optional = true
primary = false

[[objective]]
id = "rescue_all_hostages"
name = "Rescue All Hostages"
type = "rescue"
description = "Locate and rescue all abducted civilians"
required = true
primary = true
victory_condition = false  # Must also escape
failure_condition = true   # Failure if any hostage dies

[objective.rewards]
bonus_xp = 0.5

[[objective]]
id = "protect_civilians"
name = "Protect Civilians"
type = "protect"
description = "Keep civilian casualties to minimum"
required = false
optional = true
primary = false

[objective.rewards]
bonus_reputation = [50, -10]

[[objective]]
id = "secure_ufo"
name = "Secure UFO"
type = "reach"
description = "Reach UFO and mark for extraction"
required = true
primary = true
victory_condition = true

[[objective]]
id = "escape_map"
name = "Escape Map"
type = "escape"
description = "Reach extraction point and evacuate"
required = true
primary = true
victory_condition = true

[[objective]]
id = "investigate_site"
name = "Investigate Area"
type = "investigate"
description = "Explore and gather intelligence"
required = true
primary = true
location_hint = "Check entire map systematically"

[[objective]]
id = "destroy_reactor"
name = "Destroy Reactor"
type = "sabotage"
description = "Plant explosives on alien reactor"
required = true
primary = true
victory_condition = true
```

---

## Difficulty Scaling System

### Lua: Dynamic Difficulty Calculation

```lua
local function calculateMissionDifficulty(mission, campaignMonth, playerPerformance)
    local baseDifficulty = mission.difficulty
    
    -- Campaign progression scaling
    local progressionScale = {
        trivial = 0.5,
        easy = 0.75,
        medium = 1.0,
        hard = 1.25,
        impossible = 1.5,
    }
    
    local basePower = progressionScale[baseDifficulty] or 1.0
    
    -- Month-based scaling (difficulty increases over time)
    local monthScaling = 1.0 + (campaignMonth * 0.05)  -- +5% per month
    
    -- Player performance scaling
    local performanceScale = 1.0
    if playerPerformance.loss_rate > 0.3 then  -- Losing many soldiers
        performanceScale = 0.8  -- Make it easier
    elseif playerPerformance.loss_rate < 0.05 then  -- Winning easily
        performanceScale = 1.2  -- Make it harder
    end
    
    -- Apply offset
    local offset = mission.player_difficulty_offset or 0
    
    local finalDifficulty = basePower * monthScaling * performanceScale * (1.0 + (offset * 0.15))
    
    return math.max(0.3, math.min(2.0, finalDifficulty))
end
```

### Enemy Count Scaling

```lua
local function calculateEnemyCount(mission, difficulty)
    local minEnemies = mission.enemy_count_min
    local maxEnemies = mission.enemy_count_max
    
    -- Scale based on difficulty (0.5x to 2.0x)
    local difficultyScale = 0.5 + (difficulty * 0.5)
    
    local scaledMin = math.ceil(minEnemies * difficultyScale)
    local scaledMax = math.ceil(maxEnemies * difficultyScale)
    
    return math.random(scaledMin, scaledMax)
end
```

### Reward Scaling

```lua
local function calculateRewards(mission, difficulty, soldierPerformance)
    -- Base rewards
    local credits = mission.reward_credits
    local techPoints = mission.reward_technology_points
    local xpMult = mission.reward_xp_multiplier or 1.0
    
    -- Difficulty multiplier
    local diffScale = 0.5 + (difficulty * 0.5)
    
    -- Performance multiplier
    local perfScale = 1.0 + (soldierPerformance.accuracy_percent / 100)
    
    return {
        credits = math.floor(credits * diffScale),
        tech_points = math.floor(techPoints * diffScale),
        xp_multiplier = xpMult * perfScale,
    }
end
```

---

## Campaign Integration

### Mission Chains

```toml
# Initial reconnaissance leads to terror attack
[[mission]]
id = "mission_initial_recon"
name = "Initial Reconnaissance"
mission_type = "reconnaissance"
difficulty = "easy"
trigger_condition = "campaign_month == 1"
reward_technology_points = 100

[[mission]]
id = "mission_first_terror"
name = "First Terror Attack"
mission_type = "terror"
difficulty = "medium"
min_campaign_month = 2
max_campaign_month = 3
trigger_condition = "mission_initial_recon_completed"
```

### Progressive Difficulty

```toml
# Early game: Easy to medium
[[mission]]
id = "mission_month_1_ufo"
name = "Month 1 UFO"
mission_type = "ufo_recovery"
difficulty = "easy"
min_campaign_month = 1
max_campaign_month = 1

# Mid game: Medium to hard
[[mission]]
id = "mission_month_6_ufo"
name = "Month 6 UFO"
mission_type = "ufo_recovery"
difficulty = "hard"
min_campaign_month = 6
max_campaign_month = 8

# Late game: Hard to impossible
[[mission]]
id = "mission_month_12_ufo"
name = "Month 12 UFO"
mission_type = "ufo_recovery"
difficulty = "impossible"
min_campaign_month = 12
max_campaign_month = 24
```

---

## Map Generation

### Map Type Selection

| Map Type | Size | Terrain | Aliens | Civs |
|----------|------|---------|--------|------|
| **City** | Large | Dense buildings | High | Very High |
| **Farm** | Large | Open fields | Low | Medium |
| **Industrial** | Medium | Factory/warehouse | Medium | Medium |
| **Forest** | Large | Dense trees | Medium | Low |
| **Crash Site** | Medium | Wreckage | Medium | Low |
| **Alien Base** | Large | Structural | High | None |

### Map Generation Lua

```lua
local function generateMissionMap(mission, difficulty)
    local map = {
        type = mission.map_type,
        difficulty = difficulty,
        width = 30,
        height = 30,
        entities = {},
        exit_point = nil,
        objectives = {},
    }
    
    -- Scale based on mission enemy count
    local enemyCount = calculateEnemyCount(mission, difficulty)
    map.enemy_count = enemyCount
    
    -- Place enemy spawn points
    local spawnPoints = generateSpawnPoints(map, enemyCount)
    
    -- Place objectives
    for _, objId in ipairs(mission.objectives) do
        local objective = DataLoader.objective.get(objId)
        local placement = generateObjectivePlacement(map, objective)
        table.insert(map.objectives, placement)
    end
    
    -- Place exit point
    map.exit_point = generateExitPoint(map)
    
    return map
end
```

---

## Mission Failure Conditions

### Automatic Mission Failure

- Squad completely eliminated (0 soldiers alive)
- Turn limit exceeded without completing objectives
- Failure condition met (e.g., VIP dies in rescue mission)
- All civilians killed in rescue mission
- No escape route available
- Time limit exceeded on timed missions

### Abort Mission

Player can abort mission if:
- Squad has action points to retreat
- Squad reaches extraction point
- Squad morale not broken

---

## Best Practices for Mission Design

### Difficulty Balancing

1. **Easy Missions** (XP: 0.5-0.75x)
   - 3-6 enemies
   - Basic alien types (sectoids, floaters)
   - 30+ turn limit
   - Clear objectives
   - Best for: New players, early campaign

2. **Medium Missions** (XP: 1.0x)
   - 6-12 enemies
   - Mixed alien types (sectoids, mutons, floaters)
   - 25-30 turn limit
   - Moderate complexity
   - Best for: Mid-campaign, balanced play

3. **Hard Missions** (XP: 1.25-1.5x)
   - 12-20 enemies
   - Advanced aliens (mutons, ethereals)
   - 20-25 turn limit
   - Complex objectives
   - Best for: Experienced players, late campaign

4. **Impossible Missions** (XP: 2.0x)
   - 20+ enemies
   - Elite aliens (ethereal commanders)
   - 15-20 turn limit
   - Multiple complex objectives
   - Best for: Challenge runs, veteran difficulty

### Objective Design

- Always have clear primary objective
- Limit secondary objectives to 2-3
- Make objectives achievable but challenging
- Provide multiple approaches to objectives
- Reward creative problem-solving

### Reward Balance

- Low difficulty = 500-1000 credits, 50-100 tech points
- Medium difficulty = 1500-2500 credits, 150-250 tech points
- Hard difficulty = 2500-4000 credits, 300-450 tech points
- Impossible difficulty = 4000+ credits, 500+ tech points

---

## Example: Custom Mission Creation

```toml
[[mission]]
id = "mission_custom_infiltration"
name = "Deep Infiltration"
mission_type = "investigation"
description = "Infiltrate alien research facility to gather data on their experimental weapons program"
location = "South America"
difficulty = "hard"
player_difficulty_offset = 1
reward_credits = 2800
reward_technology_points = 350
reward_reputation = [40, -25]
reward_xp_multiplier = 1.4
min_squad_size = 5
recommended_squad_size = 6
max_squad_size = 8
enemy_types = ["sectoid_commander", "muton", "muton_elite"]
enemy_count_min = 10
enemy_count_max = 18
map_type = "alien_base_interior"
terrain_difficulty = "dense"
turn_limit = 25
objectives = ["gather_data", "avoid_detection", "escape_facility"]
min_campaign_month = 8
required_technology = "tech_alien_detection"

[[objective]]
id = "gather_data"
name = "Gather Research Data"
type = "investigate"
description = "Locate and extract alien research files"
required = true
primary = true
victory_condition = false

[[objective]]
id = "avoid_detection"
name = "Minimize Casualties"
type = "protect"
description = "Lose fewer than 2 soldiers"
required = false
optional = true

[objective.rewards]
bonus_reputation = [30, 0]
bonus_xp = 0.3

[[objective]]
id = "escape_facility"
name = "Escape Facility"
type = "escape"
description = "Exit through ventilation system"
required = true
primary = true
victory_condition = true
```

---

## Related Documentation

- `API_SCHEMA_REFERENCE.md` - Core entity schemas
- `API_UNITS_AND_CLASSES.md` - Enemy unit types
- `wiki/systems/Battlescape.md` - Combat mechanics
- `wiki/systems/Geoscape.md` - Mission triggering
- `MOD_DEVELOPER_GUIDE.md` - Complete modding workflow

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Oct 21, 2025 | Initial documentation |

