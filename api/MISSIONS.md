# Missions API Documentation

## Overview

The Missions system defines all available mission types, objectives, difficulty scaling, and tactical scenarios that drive the campaign gameplay. This comprehensive API handles mission templates, generation, deployment, rewards, and progression. Missions form the core of strategic decision-making where players balance risk vs. reward, choose squad composition, and engage in tactical combat across diverse scenarios.

**Key Responsibilities:**
- Mission type definitions and templates
- Objective system (rescue, assault, defense, research, interception)
- Difficulty scaling and dynamic balancing
- Enemy composition and deployment
- Map generation and tactical scenarios
- Reward calculation and progression
- Mission completion tracking and branching

**Integration Points:**
- Geoscape for mission placement and deployment
- Battlescape for tactical execution
- Units & Classes for squad composition validation
- Economy for reward calculations
- Politics for faction impact
- Analytics for mission statistics

---

## Implementation Status

### ✅ Implemented (in engine/missions/)
- Mission definition and template system
- Mission generation from templates
- Objective system (rescue, assault, defense)
- Difficulty scaling and enemy composition
- Map generation and tactical scenarios
- Reward calculation system
- Mission completion tracking

### 🚧 Partially Implemented
- Dynamic mission branching
- Consequence system
- Advanced mission events

### 📋 Planned
- Procedural mission generation
- Campaign mission chains
- Multi-objective missions

---

## Architecture

### Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     MISSIONS SYSTEM                           │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  Mission Templates ──┐                                         │
│  (TOML)              ├──> Mission Loader ──> Geoscape View    │
│  Mission Types ──────┤                                         │
│                      └──> Difficulty Calc ──> Scaling Engine  │
│                                                                │
│  Squad Config ─────> Squad Validator ──> Deployment System    │
│  Unit Types ────────> Composition Check                       │
│                                                               │
│  Battle Result ────> Reward Calculator ──> Economy Impact     │
│  Objectives ───────> Achievement Tracker ──> Progression     │
│                                                                │
│  Map Template ─────> Map Generator ──> Battlescape Init      │
│  Tileset Data ─────> Obstacle Placement ──> Environment      │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

### System Components

1. **Mission Template Manager** - Defines mission types and base configurations
2. **Mission Generator** - Creates specific mission instances from templates
3. **Difficulty Scaling Engine** - Adjusts enemy count, types, and resources
4. **Squad Validator** - Ensures valid squad composition and size
5. **Reward Calculator** - Computes credits, tech points, and reputation
6. **Objective Tracker** - Monitors mission objectives and completion
7. **Map Generator** - Creates tactical battlescape from mission template

---

## Core Entities

### Mission Entity

```lua
-- Mission definition (from DataLoader.mission.get(missionId))
{
    id = "mission_rescue_scientists",          -- Unique identifier
    name = "Rescue Scientists",                -- Display name
    mission_type = "rescue",                   -- rescue|assault|defend|research|intercept
    description = "Rescue kidnapped scientists from alien research facility",
    location = "Europe",                       -- Deployment region
    difficulty = "hard",                       -- Easy|Normal|Hard|Impossible
    reward_credits = 2000,                     -- Base credit reward
    reward_technology_points = 150,            -- Research points
    reward_reputation = {20, -10},             -- [allies, enemies]
    min_squad_size = 4,                        -- Minimum squad
    max_squad_size = 6,                        -- Maximum squad
    recommended_squad_size = 5,                -- Suggested squad
    enemy_types = {"sectoid", "sectoid_commander"},
    enemy_count_min = 8,                       -- Min enemies
    enemy_count_max = 12,                      -- Max enemies
    map_type = "alien_base_interior",          -- Map template
    objectives = {
        {type = "rescue", target = "scientists", count = 3},
        {type = "eliminate", target = "commander", optional = false}
    },
    time_limit_turns = 30                      -- Turn limit (nil = no limit)
}
```

**Functions:**

```lua
DataLoader.mission.get(missionId) -> table
-- Get complete mission definition by ID
-- Returns: Mission table with all properties
-- Throws: Error if mission not found

DataLoader.mission.getAllIds() -> table
-- Get list of all available mission IDs
-- Returns: Array of string mission IDs

DataLoader.mission.getByType(missionType) -> table
-- Get all missions of specific type
-- Returns: Array of mission tables
-- Parameters: missionType = "rescue"|"assault"|"defend"|"research"|"intercept"

DataLoader.mission.getDifficultyRange(minDifficulty, maxDifficulty) -> table
-- Get missions within difficulty range
-- Returns: Array of mission tables
-- Parameters: Difficulty values 1-5 (Easy to Impossible)
```

### Mission Instance Entity

```lua
-- Active mission instance (runtime state)
{
    id = "mission_instance_001",
    template_id = "mission_rescue_scientists",
    status = "active",                         -- active|completed|failed|abandoned
    location = "Europe/Research_Facility",
    deployed_squad = {"unit_001", "unit_002", "unit_003", "unit_004"},
    objectives_completed = {
        {id = "obj_rescue_1", completed = true, value = 1},
        {id = "obj_rescue_2", completed = false, value = 0}
    },
    reward_multiplier = 1.25,                  -- Based on difficulty mods
    time_elapsed_turns = 18,
    enemies_encountered = 12,
    enemies_eliminated = 7,
    squad_status = "3 healthy, 1 wounded"
}
```

**Functions:**

```lua
Mission.create(template, difficulty) -> table
-- Create new mission instance from template
-- Returns: Active mission instance table
-- Applies difficulty scaling to enemy count/types

Mission.complete(missionInstance, results) -> (boolean, number)
-- Mark mission as complete with results
-- Returns: (success, final_reward_amount)
-- Modifies: Calculates rewards, updates player stats

Mission.getObjectives(missionInstance) -> table
-- Get current objectives for mission
-- Returns: Array of objective tables with completion status
```

### Objective Entity

```lua
-- Objective definition
{
    id = "obj_rescue_1",
    type = "rescue",                           -- rescue|eliminate|defend|investigate|collect
    target = "scientist_01",                   -- Target identifier
    description = "Rescue Dr. Sarah Chen",
    optional = false,                          -- Optional objectives give bonus
    bonus_reward = 500,                        -- Bonus for completing optional
    location = {x = 15, y = 12},              -- Map coordinates (if fixed)
    time_limit_turns = 20                      -- Turn limit for objective (if any)
}
```

**Functions:**

```lua
Objective.checkCompletion(objective, missionState) -> boolean
-- Check if objective is complete
-- Returns: Boolean completion status

Objective.getProgress(objective, missionState) -> number
-- Get progress toward objective (0-100)
-- Returns: Percentage complete

Objective.getBonusReward(objective, completionTime) -> number
-- Calculate bonus reward based on completion speed
-- Returns: Bonus credit amount
```

---

## Integration Examples

### Example 1: Load and Display Available Missions

```lua
local DataLoader = require("engine.core.data_loader")
local allMissions = DataLoader.mission.getAllIds()

print("[MISSIONS] Total Available: " .. #allMissions .. " missions")

local byType = {}
for _, missionId in ipairs(allMissions) do
    local mission = DataLoader.mission.get(missionId)
    if not byType[mission.mission_type] then
        byType[mission.mission_type] = 0
    end
    byType[mission.mission_type] = byType[mission.mission_type] + 1
end

for mtype, count in pairs(byType) do
    print("[MISSIONS] Type '" .. mtype .. "': " .. count .. " available")
end

-- Console Output:
-- [MISSIONS] Total Available: 28 missions
-- [MISSIONS] Type 'rescue': 6 available
-- [MISSIONS] Type 'assault': 8 available
-- [MISSIONS] Type 'defend': 5 available
-- [MISSIONS] Type 'research': 5 available
-- [MISSIONS] Type 'intercept': 4 available
```

### Example 2: Create Mission Instance with Difficulty Scaling

```lua
local Mission = require("engine.geoscape.mission")
local DataLoader = require("engine.core.data_loader")

-- Load template
local template = DataLoader.mission.get("mission_rescue_scientists")

-- Create instance with scaling
local difficulty = 3  -- Hard (1-5 scale)
local instance = Mission.create(template, difficulty)

print("[MISSION] Instance: " .. instance.id)
print("[MISSION] Template: " .. instance.template_id)
print("[MISSION] Enemies: " .. #instance.enemies .. " deployed")
print("[MISSION] Squad Capacity: " .. instance.max_squad_size)
print("[MISSION] Reward Multiplier: " .. instance.reward_multiplier .. "x")

-- Console Output:
-- [MISSION] Instance: mission_instance_2581
-- [MISSION] Template: mission_rescue_scientists
-- [MISSION] Enemies: 11 deployed
-- [MISSION] Squad Capacity: 6
-- [MISSION] Reward Multiplier: 1.25x (Hard difficulty bonus)
```

### Example 3: Deploy Squad to Mission

```lua
local Geoscape = require("engine.geoscape.geoscape")
local Mission = require("engine.geoscape.mission")
local base = { id = "base_main", units = {...} }

-- Get active mission
local mission = Geoscape.getActiveMission("mission_instance_2581")

-- Assemble squad
local squad = { base.units[1], base.units[3], base.units[5], base.units[7] }

print("[DEPLOYMENT] Deploying " .. #squad .. " units to mission")
for i, unit in ipairs(squad) do
    print("[DEPLOYMENT] Unit " .. i .. ": " .. unit.name .. " (" .. unit.class .. ")")
end

-- Deploy to battlescape
local success, battlestate = Mission.deploySquad(mission, squad)

if success then
    print("[DEPLOYMENT] Squad deployed. Objectives: " .. #mission.objectives)
else
    print("[DEPLOYMENT] Failed to deploy squad")
end

-- Console Output:
-- [DEPLOYMENT] Deploying 4 units to mission
-- [DEPLOYMENT] Unit 1: Major John Smith (Assault)
-- [DEPLOYMENT] Unit 2: Sergeant Jane Doe (Sniper)
-- [DEPLOYMENT] Unit 3: Captain Tom Wilson (Heavy)
-- [DEPLOYMENT] Unit 4: Officer Mike Johnson (Support)
-- [DEPLOYMENT] Squad deployed. Objectives: 2
```

### Example 4: Track Mission Objectives

```lua
local Mission = require("engine.geoscape.mission")

local mission = { id = "mission_instance_2581", objectives = {...} }

print("[OBJECTIVES] Active: " .. #mission.objectives)
for i, obj in ipairs(mission.objectives) do
    local progress = Mission.getObjectives(mission)[i].progress or 0
    print("[OBJ " .. i .. "] " .. obj.type .. ": " .. obj.description .. 
          " (" .. progress .. "%)")
end

-- Later in battle...
print("\n[UPDATE] Objectives progress after combat:")
for i, obj in ipairs(mission.objectives) do
    local complete = Mission.checkCompletion(obj, mission)
    if complete then
        print("[OBJ " .. i .. "] ✓ COMPLETE: " .. obj.description)
    else
        print("[OBJ " .. i .. "] ○ IN PROGRESS: " .. obj.description)
    end
end

-- Console Output:
-- [OBJECTIVES] Active: 2
-- [OBJ 1] rescue: Rescue Dr. Sarah Chen (0%)
-- [OBJ 2] eliminate: Eliminate Sectoid Commander (0%)
--
-- [UPDATE] Objectives progress after combat:
-- [OBJ 1] ○ IN PROGRESS: Rescue Dr. Sarah Chen
-- [OBJ 2] ✓ COMPLETE: Eliminate Sectoid Commander
```

### Example 5: Complete Mission and Calculate Rewards

```lua
local Mission = require("engine.geoscape.mission")
local base = { id = "base_main", credits = 5000 }

-- Mission results
local missionInstance = {id = "mission_instance_2581", status = "active"}
local battleResults = {
    casualties = 1,
    time_turns = 22,
    objectives_completed = 1,
    bonus_objectives_completed = 0
}

-- Calculate rewards
local success, totalReward = Mission.complete(missionInstance, battleResults)

if success then
    print("[MISSION COMPLETE]")
    print("[REWARD] Credits: +$" .. totalReward)
    print("[REWARD] Tech Points: +150")
    print("[REWARD] Reputation: Allies +20, Enemies -10")
    print("[REWARD] Status: " .. missionInstance.status)
    
    base.credits = base.credits + totalReward
    print("[BASE] Total Credits: $" .. base.credits)
else
    print("[MISSION FAILED] Cannot complete mission")
end

-- Console Output:
-- [MISSION COMPLETE]
-- [REWARD] Credits: +$2500 (base 2000 × 1.25 multiplier)
-- [REWARD] Tech Points: +150
-- [REWARD] Reputation: Allies +20, Enemies -10
-- [REWARD] Status: completed
-- [BASE] Total Credits: $7500
```

---

## Mission Types & Mechanics

### Mission Type Classification

#### Rescue Missions
**Objective**: Extract friendly units/civilians from enemy territory.
- **Squad Focus**: Quick extraction, defensive positioning
- **Difficulty Scaling**: +15% per difficulty level
- **Victory Condition**: Extract all targets to designated extraction point
- **Time Pressure**: 20-30 turn limit typical
- **Rewards**: Base 2000 credits, +500 per civilian saved
- **Tactical Depth**: Multiple entry routes, civilian pathfinding, escort mechanics

**Mechanics:**
```lua
rescue_config = {
  civilians_per_objective = 3,
  civilian_speed_penalty = -2,           -- Civilians move slower
  extraction_distance = 15,              -- Must reach extraction point
  reward_per_civilian = 500,
  fail_condition_civilian_killed = true,
  time_limit = 25                        -- Turns
}
```

#### Assault Missions
**Objective**: Destroy enemy installations, eliminate high-value targets.
- **Squad Focus**: Offensive capability, firepower
- **Difficulty Scaling**: +25% enemy forces per difficulty
- **Victory Condition**: All primary objectives destroyed
- **Environmental Hazards**: Reinforcements, alarm systems, traps
- **Rewards**: Base 3000 credits, +1000 per objective
- **Tactical Depth**: Objective prioritization, reinforcement waves

**Mechanics:**
```lua
assault_config = {
  primary_objectives = 2-4,
  reinforcement_waves = 1-3,
  reinforcement_delay = 3-5,             -- Turns until reinforcements
  reinforcement_size = 4-8,              -- Units per wave
  objective_health = 50-100,
  reward_per_objective = 1000,
  fail_condition_time_limit = true,
  time_limit = 30
}
```

#### Defense Missions
**Objective**: Defend base/location against waves of attacking enemies.
- **Squad Focus**: Positional defense, area control
- **Difficulty Scaling**: +20% enemy waves per difficulty
- **Victory Condition**: Survive N turns / eliminate all waves
- **Environment**: Pre-positioned defenses (turrets, sandbags)
- **Rewards**: Base 2500 credits, +300 per wave survived
- **Tactical Depth**: Fortification placement, wave management

**Mechanics:**
```lua
defense_config = {
  waves = 3-6,
  wave_delay = 4-6,                      -- Turns between waves
  wave_size = 4-8,                       -- Units per wave
  turn_limit = 30-40,
  reward_per_wave = 300,
  starting_defenses = true,              -- Turrets, walls, etc.
  reinforcement_option = true,           -- Can call air support
  fail_condition_base_destroyed = true
}
```

#### Interception Missions
**Objective**: Intercept UFO/alien craft in aerial combat.
- **Squad Focus**: Pilot skills, aircraft combat
- **Difficulty Scaling**: +30% enemy fighter capability
- **Victory Condition**: Destroy UFO or force retreat
- **Environment**: Aerial combat zone, limited fuel
- **Rewards**: Base 1500 credits, +2000 if UFO captured
- **Tactical Depth**: Fuel management, dogfighting tactics

**Mechanics:**
```lua
interception_config = {
  ufo_type = "fighter|transport|battleship",
  ufo_health = 50-200,
  max_rounds = 10,                       -- Combat rounds
  fuel_consumption = 1,                  -- Per round
  player_fuel = 10,
  ufo_fuel = 8-12,
  reward_ufo_destroyed = 1500,
  reward_ufo_captured = 2000,
  reward_escaped = 500                   -- If UFO escapes
}
```

#### Investigation Missions
**Objective**: Gather intelligence, collect data, investigate anomaly.
- **Squad Focus**: Stealth, reconnaissance
- **Difficulty Scaling**: +10% enemy awareness
- **Victory Condition**: Collect all data/reach objective
- **Environment**: Civilian areas, research facilities
- **Rewards**: Base 1000 credits, +500 per data point
- **Tactical Depth**: Stealth mechanics, non-lethal options

**Mechanics:**
```lua
investigation_config = {
  data_points = 3-5,
  stealth_required = true,
  civilian_casualty_penalty = -500,
  noise_level_tracking = true,
  alarm_system = true,
  objective_types = {"terminal", "artifact", "documents"},
  reward_per_data = 500,
  fail_condition_detected = false        -- Can still complete if found
}
```

---

## Difficulty Scaling System

### Difficulty Levels & Modifiers

| Difficulty | Squad Size | Enemy Count | Enemy Quality | Time Limit | Rewards | Fail Condition |
|---|---|---|---|---|---|---|
| **Easy** | 75% | 50% | Basic units | +50% | 0.75x | Standard |
| **Normal** | 100% | 100% | Standard mix | Normal | 1.0x | Standard |
| **Hard** | 125% | 150% | Elite units | -25% | 1.5x | Tough |
| **Impossible** | 150% | 200% | Max elite | -50% | 2.0x | Strict |

**Scaling Formula:**
```lua
function calculateDifficulty(baseMission, difficultyLevel)
  local modifiers = {
    easy = {enemy_count = 0.5, quality = 0.7, time = 1.5, reward = 0.75},
    normal = {enemy_count = 1.0, quality = 1.0, time = 1.0, reward = 1.0},
    hard = {enemy_count = 1.5, quality = 1.3, time = 0.75, reward = 1.5},
    impossible = {enemy_count = 2.0, quality = 1.6, time = 0.5, reward = 2.0}
  }
  
  local mod = modifiers[difficultyLevel]
  return {
    enemy_count = math.floor(baseMission.enemy_count * mod.enemy_count),
    reward_multiplier = mod.reward,
    time_limit = math.floor(baseMission.time_limit * mod.time)
  }
end
```

### Enemy Composition by Difficulty

**Easy:**
- 60% Basic Sectoids, 40% Light infantry
- Limited equipment (basic weapons)
- No psychic abilities
- Low coordination

**Normal:**
- 40% Sectoids, 40% Sectoid Commanders, 20% Specialists
- Standard equipment
- Basic psychic abilities
- Moderate tactics

**Hard:**
- 30% Sectoids, 30% Commanders, 20% Specialists, 20% Elite
- Advanced equipment (plasma weapons)
- Enhanced psychic abilities
- Advanced tactics, reinforcements

**Impossible:**
- 20% Sectoids, 40% Commanders, 20% Specialists, 20% Elite
- Best equipment (plasma, explosives)
- Powerful psychic abilities
- Expert tactics, multiple reinforcement waves, allies

---

## Mission Generation System

### Generation Pipeline

**Step 1: Select Mission Type**
- Weight by game progression
- Bias toward country/faction preferences
- Consider threat level in region

**Step 2: Choose Location**
- Filter by country relations
- Check base radar coverage
- Consider strategic value

**Step 3: Select Enemy Faction**
- Primary faction for region
- Allied faction support (if applicable)
- Faction preference for mission type

**Step 4: Apply Difficulty Scaling**
- Base difficulty: Region average
- Adjustment: Faction strength
- Player organization level modifier

**Step 5: Generate Map**
- Select biome appropriate for location
- Choose mission-specific layout
- Apply randomization (rotation, terrain swap)

**Step 6: Place Objectives**
- Distribute across map
- Avoid clustering
- Ensure accessibility

**Step 7: Deploy Squad**
- Select enemy types per faction
- Distribute by difficulty
- Position strategically

**Step 8: Calculate Rewards**
- Base reward by mission type
- Difficulty multiplier
- Optional objective bonuses

### Mission Spawn Rate

```lua
mission_spawn_config = {
  base_spawn_rate = 1.0,                 -- Missions per turn
  min_missions_active = 1,               -- Always at least 1
  max_missions_active = 5,               -- Never more than 5
  spawn_probability_increase = 0.1,      -- Per turn without mission
  spawn_probability_decrease = 0.2,      -- Per turn with active mission
  
  -- Regional variation
  high_threat_regions = 2.0,             -- 2x spawn rate
  neutral_regions = 1.0,
  protected_regions = 0.5,               -- 0.5x spawn rate
}
```

---

## Reward System

### Reward Calculation

**Base Rewards by Type:**
```lua
base_rewards = {
  rescue = 2000,
  assault = 3000,
  defense = 2500,
  intercept = 1500,
  investigate = 1000
}
```

**Multipliers:**
```lua
function calculateTotalReward(mission, results)
  local base = base_rewards[mission.type]
  local difficulty_mult = {easy = 0.75, normal = 1.0, hard = 1.5, impossible = 2.0}
  local performance_mult = 1.0
  
  -- Time bonus: Complete in <50% of time limit
  if results.time_taken < mission.time_limit * 0.5 then
    performance_mult = performance_mult * 1.25
  end
  
  -- Casualty penalty: -10% per unit lost
  performance_mult = performance_mult * (1.0 - 0.1 * results.units_lost)
  
  -- Objective completion bonus: +20% per optional objective
  performance_mult = performance_mult * (1.0 + 0.2 * results.optional_completed)
  
  local total = base * difficulty_mult[mission.difficulty] * performance_mult
  return math.floor(total)
end
```

**Reward Types:**
- **Credits**: Direct income, variable by mission
- **Technology Points**: Research acceleration, faction-dependent
- **Reputation**: Country/faction relationship changes
- **Salvage**: Equipment drops, alien artifacts
- **Experience**: Unit XP, skill advancement
- **Special Rewards**: Rare tech, unique items, story progression

### Difficulty-Based Rewards

| Difficulty | Credits | Tech Points | Reputation |
|---|---|---|---|
| Easy | 1500 | 50 | +5 |
| Normal | 2000 | 100 | +10 |
| Hard | 3000 | 200 | +20 |
| Impossible | 4000 | 400 | +40 |

---

## Mission Failure & Consequences

### Failure Conditions

**Mission Failure Triggers:**
- Squad eliminated (all units KIA or fled)
- Primary objectives failed
- Time limit exceeded (if applicable)
- Critical NPC killed (rescue missions)
- Base destroyed (defense missions)

**Failure Consequences:**
```lua
failure_consequences = {
  country_relations = -20,               -- -20 with funding nation
  reputation_loss = -15,                 -- Faction standing
  credit_penalty = -500,                 -- No payment
  morale_penalty = -5,                   -- All surviving units
  mission_replay_wait = 3,               -- Turns until retry available
  survivor_recovery = 14                 -- Days injured units recover
}
```

### Partial Success

Some missions can result in partial success:
- **Incomplete Extraction**: Rescue 2 of 3 civilians = 50% reward
- **Primary Success, Optional Fail**: Destroy main target but secondary destroyed = 80% reward
- **Defensive Victory, Casualties**: Defend base but lose structures = 60% reward

---

## Mission Branching & Events

### Dynamic Mission Events

**Random Events During Mission:**
- Reinforcement arrival (earlier than expected)
- Environmental hazard (fire, toxic gas)
- Civilian emergence (unexpected rescue)
- Equipment malfunction (weapon jam, armor damage)
- Morale event (unit panic, rally moment)

**Probability by Mission Type:**
```lua
event_probabilities = {
  rescue = {reinforcement = 0.3, civilian = 0.4, hazard = 0.2},
  assault = {reinforcement = 0.5, hazard = 0.3, malfunction = 0.2},
  defense = {reinforcement = 1.0, hazard = 0.4, event = 0.2},
  intercept = {malfunction = 0.3, hazard = 0.2},
  investigate = {discovery = 0.4, encounter = 0.3, hazard = 0.1}
}
```

### Post-Mission Consequences

**Story Branching:**
- Mission outcome affects future mission generation
- Failed rescue → More kidnapping missions
- Successful assault → Reduced enemy activity in region
- Discovery on investigation → Unlock new mission chains

---

## TOML Mission Configuration

### Mission Template Example

```toml
# missions/rescue_scientists.toml

[mission]
id = "rescue_scientists"
name = "Rescue Scientists"
description = "Rescue kidnapped scientists from alien research facility"
type = "rescue"
difficulty_base = 2  # Normal

[objectives]
[[objectives.primary]]
type = "rescue"
target = "scientists"
count = 3
description = "Rescue all scientists"

[[objectives.optional]]
type = "eliminate"
target = "commander"
count = 1
bonus_reward = 500

[deployment]
enemy_type = "sectoid"
enemy_count_min = 8
enemy_count_max = 12
reinforcement_waves = 1
reinforcement_delay = 5
squad_size_recommended = 5

[rewards]
credits_base = 2000
tech_points = 150
reputation_delta = 20
per_objective_bonus = 500

[map]
type = "alien_base_interior"
biome_types = ["urban", "alien"]
size = "medium"
time_limit_turns = 25
```

---

## Performance Considerations

**Optimization Strategies:**
- Cache all mission templates on startup to avoid repeated TOML parsing
- Use mission ID lookups instead of linear search through all missions
- Batch calculate difficulty scaling once per mission creation, not per enemy
- Pre-calculate reward tables during initialization
- Store objective states in efficient lookup table (ID -> completion status)
- Use bitflags for multiple boolean objective flags

**Best Practices:**
- Load all mission data once at game start, reference by ID
- Cache difficulty scaling calculations per mission difficulty level
- Update objective progress only when significant changes occur
- Batch objective completion checks instead of checking individually
- Pre-render mission briefings to avoid runtime calculation

**Performance Impact:**
- Mission lookup: < 1ms (indexed by ID)
- Difficulty scaling: < 3ms per mission instance
- Objective tracking: < 2ms per update
- Reward calculation: < 5ms for all objectives
- Squad validation: < 2ms for standard squad sizes

---

## Procedural Generation System

### Mission Generation Algorithm

The procedural generation system creates unique mission instances by layering randomization with constraints, ensuring tactical variety while maintaining gameplay balance.

**Generation Step 1: Mission Type Selection**

```lua
function selectMissionType(geoscape_state, region)
  local available_types = {"rescue", "assault", "defend", "intercept", "investigate"}
  local weights = {
    rescue = 1.0,
    assault = 1.2,
    defend = 0.8,
    intercept = 1.1,
    investigate = 0.6
  }
  
  -- Adjust weights by game state
  if geoscape_state.active_rescue_count > 3 then
    weights.rescue = weights.rescue * 0.5  -- Reduce repeat types
  end
  if region.threat_level > 0.7 then
    weights.assault = weights.assault * 1.5  -- More combat in hot zones
  end
  
  -- Weighted random selection
  local selected = weightedRandom(available_types, weights)
  return selected
end
```

**Generation Step 2: Location Selection**

```lua
function selectMissionLocation(mission_type, geoscape_state)
  local candidates = {}
  
  -- Filter provinces by criteria
  for _, province in ipairs(geoscape_state.provinces) do
    local score = 0
    
    -- Base mission appropriateness
    score = score + getMissionTypeSuitability(mission_type, province.biome)
    
    -- Strategic value (higher = more likely)
    score = score + (province.threat_level * 0.3)
    
    -- Country funding bonus
    local owner = getCountryOwner(province)
    score = score + (getFundingLevel(owner) * 0.2)
    
    -- Already has active mission penalty
    if hasActiveMission(province) then
      score = score * 0.5
    end
    
    if score > 0 then
      table.insert(candidates, {province = province, score = score})
    end
  end
  
  -- Select highest weighted
  table.sort(candidates, function(a,b) return a.score > b.score end)
  return candidates[1].province
end
```

**Generation Step 3: Difficulty Calculation**

```lua
function calculateMissionDifficulty(mission_template, geoscape_state, difficulty_setting)
  local base_difficulty = mission_template.difficulty_base or 2
  
  -- Player organization level modifier (-1 to +1)
  local org_modifier = (geoscape_state.organization_level - 3) * 0.2
  
  -- Regional threat modifier (0-2x)
  local threat_mult = geoscape_state.active_region.threat_level
  
  -- Weighted by player performance (wins vs losses)
  local win_rate = geoscape_state.mission_wins / 
                   math.max(1, geoscape_state.mission_wins + geoscape_state.mission_losses)
  local performance_modifier = (1.0 - win_rate) * 0.3  -- Up to +0.3 if losing
  
  -- Difficulty setting (0.75 to 2.0 for easy/hard)
  local difficulty_scales = {
    easy = 0.75,
    normal = 1.0,
    hard = 1.5,
    impossible = 2.0
  }
  
  local final_difficulty = 
    (base_difficulty + org_modifier + performance_modifier) * 
    difficulty_scales[difficulty_setting] * 
    threat_mult
  
  return math.clamp(final_difficulty, 1, 5)  -- Clamp to valid range
end
```

**Generation Step 4: Enemy Composition**

```lua
function generateEnemyComposition(mission_type, final_difficulty, region_faction)
  local base_count = mission_templates[mission_type].enemy_count_min
  
  -- Difficulty scaling: +25% per difficulty level above base
  local count_modifier = 1.0 + (final_difficulty - 2) * 0.25
  local enemy_count = math.floor(base_count * count_modifier)
  
  -- Quality tier selection (1=basic, 5=elite)
  local quality_tier = math.ceil(final_difficulty)
  
  -- Generate enemy types by faction and quality
  local enemies = {}
  local faction_roster = region_faction.available_units
  
  for i = 1, enemy_count do
    local enemy_type = selectEnemyByQuality(faction_roster, quality_tier, i)
    table.insert(enemies, {
      type = enemy_type,
      tier = quality_tier,
      index = i
    })
  end
  
  return enemies
end

function selectEnemyByQuality(roster, quality_tier, position)
  -- Higher quality units appear later (officers/leaders)
  local tier_distribution = {
    [1] = {basic = 0.9, elite = 0.1},          -- Easy: mostly basic
    [2] = {basic = 0.7, standard = 0.2, elite = 0.1},
    [3] = {basic = 0.4, standard = 0.4, elite = 0.2},
    [4] = {standard = 0.5, elite = 0.5},       -- Hard: no basic
    [5] = {elite = 1.0}                        -- Impossible: all elite
  }
  
  local dist = tier_distribution[quality_tier]
  local selected_tier = weightedRandom(
    {"basic", "standard", "elite"}, 
    {dist.basic or 0, dist.standard or 0, dist.elite or 0}
  )
  
  -- Pick specific unit from roster matching tier
  return selectRandomUnitOfTier(roster, selected_tier)
end
```

**Generation Step 5: Map & Objective Placement**

```lua
function generateMissionMap(mission_type, location_biome, difficulty)
  -- Select map template for biome
  local map_template = selectMapTemplate(mission_type, location_biome)
  
  -- Randomize map (rotation, mirroring, terrain swap)
  local variations = {
    rotation = math.random(0, 3) * 90,         -- 0, 90, 180, 270
    mirror_horizontal = math.random() > 0.5,
    terrain_density = 0.7 + math.random() * 0.3
  }
  
  local final_map = applyMapVariations(map_template, variations)
  
  -- Place objectives
  local objectives = {}
  for _, obj_template in ipairs(mission_type.objective_templates) do
    local placement = findObjectivePlacement(final_map, objectives)
    table.insert(objectives, {
      type = obj_template.type,
      location = placement,
      difficulty_factor = difficulty
    })
  end
  
  return {map = final_map, objectives = objectives}
end
```

**Generation Step 6: Reward Calculation**

```lua
function calculateMissionRewards(mission_type, difficulty, player_performance)
  local base_reward = mission_type.base_reward or 2000
  
  -- Difficulty multiplier (0.5 to 2.0)
  local difficulty_scales = {1, 0.75, 1.25, 1.75, 2.0}
  local difficulty_mult = difficulty_scales[math.ceil(difficulty)]
  
  -- Performance bonus (up to +50% for specific conditions)
  local performance_bonus = 1.0
  
  if player_performance.first_contact_elimination then
    performance_bonus = performance_bonus * 1.1  -- +10% for fast kills
  end
  if player_performance.minimal_casualties then
    performance_bonus = performance_bonus * 1.2  -- +20% for few losses
  end
  if player_performance.speedrun then
    performance_bonus = performance_bonus * 1.15 -- +15% for fast completion
  end
  
  local final_reward = base_reward * difficulty_mult * performance_bonus
  
  return {
    credits = math.floor(final_reward),
    tech_points = math.floor(final_reward * 0.08),
    reputation = math.floor(difficulty_mult * 10)
  }
end
```

### Generation Parameters Table

| Parameter | Min | Default | Max | Description |
|---|---|---|---|---|
| Enemy Count Multiplier | 0.5x | 1.0x | 2.0x | Scales enemy squad size |
| Difficulty Variance | ±0 | ±0.3 | ±0.5 | Random variance in calculated difficulty |
| Objective Spread | 20% | 50% | 100% | How spread out objectives are on map |
| Reinforcement Probability | 0% | 30% | 80% | Chance reinforcements arrive mid-mission |
| Environmental Hazard Chance | 0% | 20% | 60% | Chance of random environmental events |
| Time Limit Variance | -50% | ±0% | +50% | Random adjustment to time limit |
| Reward Variance | ±10% | ±20% | ±50% | Random adjustment to reward amount |

### Constraints & Validation

**Generation must satisfy:**
1. Enemy count ≥ squad_size (never fewer enemies than squad can deploy)
2. Objectives are reachable (not blocked by impassable terrain)
3. Difficulty is within player tolerance (±1 of current org level)
4. Mission type is appropriate for region (no arctic rescue in desert)
5. Faction has units available (don't generate enemies that don't exist)
6. Time limit is achievable (at least 5 turns minimum)
7. Map size supports unit count (large maps for large fights)

---

## Temporal Mechanics

### Turn-Based Timing

**Mission Timing:**
- 1 turn = ~30 seconds of in-game time
- Typical mission: 15-30 turns (7.5-15 real-time minutes at normal speed)
- Time limit: 20-40 turns depending on mission type

**Time Pressure Scaling:**

```lua
function calculateTimeLimit(mission_type, difficulty, map_size)
  local base_time = mission_type.base_time_limit or 30
  
  -- Map size affects time (larger = more time)
  local size_factor = {
    small = 0.8,
    medium = 1.0,
    large = 1.2,
    huge = 1.4
  }
  
  -- Difficulty affects time (harder = less time)
  local difficulty_factor = (6 - difficulty) / 5  -- Range: 1.0 to 0.2
  
  -- Number of objectives (more = more time)
  local objective_factor = 1.0 + (#objectives * 0.1)
  
  local final_time = math.floor(
    base_time * 
    size_factor[map_size] * 
    difficulty_factor * 
    objective_factor
  )
  
  return math.max(15, final_time)  -- Minimum 15 turns
end
```

**Time-Based Bonuses:**

```lua
-- Completion time affects reward multiplier
time_bonus_thresholds = {
  ultra_fast = {turns = 0.33, multiplier = 1.5},    -- 1/3 time limit
  very_fast = {turns = 0.50, multiplier = 1.3},     -- 1/2 time limit
  fast = {turns = 0.75, multiplier = 1.1},          -- 3/4 time limit
  normal = {turns = 1.0, multiplier = 1.0},         -- At time limit
  time_exceeded = {turns = 1.0, multiplier = 0.5}   -- Over time
}
```

### Mission Deadline System

**Temporal Mechanics:**
- Some missions have hard time limits (UFO interception)
- Others have soft limits (rescue before reinforcements)
- Exceeding deadline triggers consequences (civilian death, base capture)

```lua
mission_deadline_config = {
  rescue = {
    limit_type = "soft",
    consequence = "civilian_death",
    consequence_delay = 5  -- Turns before consequence
  },
  intercept = {
    limit_type = "hard",
    consequence = "mission_fail",
    consequence_delay = 0   -- Immediate
  },
  defend = {
    limit_type = "soft",
    consequence = "structure_destroyed",
    consequence_delay = 3
  }
}
```

---

## Reward System Details

### Advanced Reward Formulas

**Base Reward Calculation:**
```lua
function calculateBaseReward(mission_type, difficulty)
  local mission_base_rewards = {
    rescue = 2000,
    assault = 3000,
    defend = 2500,
    intercept = 1500,
    investigate = 1000
  }
  
  local difficulty_multiplier = {
    [1] = 0.75,   -- Easy
    [2] = 1.0,    -- Normal
    [3] = 1.5,    -- Hard
    [4] = 2.0,    -- Impossible (clamped)
    [5] = 2.0
  }
  
  local base = mission_base_rewards[mission_type]
  local multiplier = difficulty_multiplier[math.ceil(difficulty)]
  
  return base * multiplier
end
```

**Performance Multipliers:**
```lua
function calculatePerformanceMultiplier(results)
  local multiplier = 1.0
  
  -- Casualty modifier: -10% per KIA, -5% per wounded
  multiplier = multiplier * (1.0 - results.units_kia * 0.1 - results.units_wounded * 0.05)
  
  -- Time bonus: Complete in < 50% of time
  if results.turns_taken < results.time_limit * 0.5 then
    multiplier = multiplier * 1.25
  end
  
  -- Objective completion: +20% per optional objective
  multiplier = multiplier * (1.0 + results.optional_completed * 0.2)
  
  -- Perfect mission: No casualties + all objectives
  if results.units_kia == 0 and results.objectives_failed == 0 then
    multiplier = multiplier * 1.5
  end
  
  return math.min(multiplier, 3.0)  -- Cap at 3x multiplier
end
```

**Final Reward Calculation:**
```lua
function calculateFinalReward(mission, results)
  local base_reward = calculateBaseReward(mission.type, mission.difficulty)
  local perf_multiplier = calculatePerformanceMultiplier(results)
  
  local final_credits = math.floor(base_reward * perf_multiplier)
  
  return {
    credits = final_credits,
    tech_points = math.floor(final_credits * 0.08),
    reputation = math.floor(final_credits * 0.005),
    salvage_multiplier = results.units_kia_count > 0 and 1.5 or 1.0
  }
end
```

**Reward Variation by Mission Type**

**Rescue Mission Rewards:**
```lua
rescue_rewards = {
  base_credits = 2000,
  per_civilian_rescued = 500,
  per_civilian_lost = -500,
  time_bonus_threshold = 0.66,  -- 2/3 of time limit
  tech_points = 150
}
```

**Assault Mission Rewards:**
```lua
assault_rewards = {
  base_credits = 3000,
  per_objective_destroyed = 1000,
  reinforcement_wave_bonus = 500,
  time_bonus_threshold = 0.5,
  tech_points = 200
}
```

**Defense Mission Rewards:**
```lua
defense_rewards = {
  base_credits = 2500,
  per_wave_survived = 300,
  per_structure_saved = 250,
  time_bonus_threshold = 1.0,   -- No time limit
  tech_points = 180
}
```

**Interception Rewards:**
```lua
intercept_rewards = {
  base_credits = 1500,
  ufo_destroyed = 1500,
  ufo_captured = 3000,
  ufo_escaped = 500,
  tech_points = 250  -- High for alien tech
}
```

---

## Mission Constraints & Rules

### Tactical Constraints

**Squad Size Limits:**
```lua
squad_constraints = {
  minimum_size = 1,                   -- At least 1 unit
  maximum_size = 12,                  -- Maximum deployment size
  
  by_mission_type = {
    rescue = {min = 2, max = 6},      -- Smaller squads for stealth
    assault = {min = 4, max = 12},    -- Large squads for firepower
    defend = {min = 2, max = 8},      -- Medium-large squads
    intercept = {min = 1, max = 2},   -- Single/dual pilot
    investigate = {min = 1, max = 4}  -- Small reconnaissance squads
  }
}
```

**Equipment Requirements:**
```lua
equipment_requirements = {
  rescue = {must_have = {"medikit"}},
  assault = {must_have = {"explosives"}},
  defend = {recommended = {"armor_upgrade", "ammo_supply"}},
  intercept = {must_have = {"aircraft"}},
  investigate = {recommended = {"scanner", "encryption_key"}}
}
```

### Environmental Constraints

**Biome-Mission Suitability:**
```lua
biome_suitability = {
  rescue = {forest = 1.0, desert = 1.2, urban = 1.5, tundra = 0.8},
  assault = {forest = 1.0, desert = 1.0, urban = 1.3, tundra = 1.1},
  defend = {forest = 1.0, desert = 1.1, urban = 1.4, tundra = 0.9},
  intercept = {any = 1.0},  -- All biomes equal for air combat
  investigate = {urban = 1.3, forest = 1.0, desert = 1.1}
}
```

**Map Size by Mission Type:**
```lua
map_size_constraints = {
  rescue = {prefer = "medium", range = "small-large"},
  assault = {prefer = "large", range = "medium-huge"},
  defend = {prefer = "medium", range = "small-large"},
  intercept = {prefer = "custom", range = "aerial_map_only"},
  investigate = {prefer = "small", range = "small-medium"}
}
```

---

## Configuration Examples

### Complete Mission Definition

```toml
[mission]
id = "advanced_rescue"
name = "Advanced Scientific Rescue"
type = "rescue"
biome_types = ["urban", "alien"]
difficulty_base = 3

[generation]
enemy_count_base = 10
enemy_count_difficulty_scale = 0.25  # +25% per difficulty
reinforcement_probability = 0.4
reinforcement_wave_delay = 5
environmental_hazard_chance = 0.2

[objectives]
[[objectives.primary]]
type = "rescue"
count = 3
civilians_move_speed = -2
extraction_distance = 15

[[objectives.optional]]
type = "eliminate"
target = "sectoid_commander"
bonus_reward = 500

[deployment]
squad_size_recommended = 5
squad_size_minimum = 3
squad_size_maximum = 8
equipment_required = ["medikit", "standard_ammo"]
equipment_recommended = ["advanced_armor", "smoke_grenades"]

[rewards]
credits_base = 2000
credits_difficulty_scale = 1.5
tech_points = 150
reputation_allies = 20
reputation_enemies = -10
per_objective_bonus = 500

[timing]
time_limit_base = 25
time_limit_difficulty_scale = -0.3  # Reduce time at higher difficulty
time_bonus_multiplier = 1.25        # 1.25x reward if <50% time used

[map]
type = "alien_base_interior"
size = "large"
# ... additional map configuration
```

---

**Last Updated:** October 22, 2025  
**Status:** ✅ Complete
- Dynamic events during missions (reinforcements, hazards)
- Story-driven mission chains
- Conditional mission outcomes
- Post-mission consequences

**TOML Configuration System**
- Complete mission template definitions
- Generation parameters and constraints
- Biome-specific mission suitability
- Environmental hazard configurations

**Temporal Mechanics**
- Turn-based timing with time pressure
- Mission deadlines and consequences
- Time-based reward bonuses
- Dynamic time limit calculations

**Advanced Analytics**
- Mission success rate tracking
- Performance metrics and efficiency calculations
- Historical mission data analysis
- Player progression insights

---

**API Version:** 1.0
**Last Updated:** October 21, 2025
**Status:** ✅ Production Ready
