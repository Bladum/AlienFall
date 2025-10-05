# XCOM Design Patterns for Alien Fall

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Target Audience:** Game Designers, Developers

---

## Table of Contents

1. [Introduction](#introduction)
2. [Strategic Layer (Geoscape)](#strategic-layer-geoscape)
3. [Tactical Layer (Battlescape)](#tactical-layer-battlescape)
4. [Research & Technology](#research--technology)
5. [Base Management](#base-management)
6. [Resource Economy](#resource-economy)
7. [Mission Generation](#mission-generation)
8. [Difficulty Scaling](#difficulty-scaling)
9. [Permanent Consequences](#permanent-consequences)
10. [OpenXCOM Implementation Details](#openxcom-implementation-details)

---

## Introduction

This guide documents the core design patterns from the XCOM series (especially the original X-COM: UFO Defense and OpenXCOM) and how they apply to Alien Fall's architecture.

### Why XCOM?

The XCOM formula provides:
- **Strategic Depth**: Multiple interconnected systems that create emergent gameplay
- **Tension Management**: Constant trade-offs between competing priorities
- **Player Agency**: Meaningful choices with long-term consequences
- **Asymmetric Warfare**: Underdog player fighting superior enemy forces
- **Progressive Escalation**: Difficulty and stakes increase over time

### Core Pillars

1. **Two-Layer Structure**: Strategic (Geoscape) and Tactical (Battlescape) layers
2. **Permanent Progression**: Research, base building, soldier development
3. **Resource Scarcity**: Never enough money, time, or personnel
4. **Risk/Reward**: High-risk missions offer better rewards
5. **Emergent Narrative**: Player creates their own stories through gameplay

---

## Strategic Layer (Geoscape)

### Time Management

**Pattern**: Real-time with pause, time dilation controls

```lua
-- Time progression system
local GeoscapeTime = {}

function GeoscapeTime:update(dt)
    if self.paused then
        return
    end
    
    -- Apply time multiplier (1x, 5x, 30x speed)
    local adjusted_dt = dt * self.time_multiplier
    
    self.current_time = self.current_time + adjusted_dt
    
    -- Check for timed events
    self:processTimeEvents(adjusted_dt)
end

-- XCOM pattern: Events trigger at specific game times
function GeoscapeTime:scheduleEvent(event_time, callback)
    table.insert(self.scheduled_events, {
        time = event_time,
        callback = callback
    })
end
```

**Design Notes:**
- Player can pause at any time to make decisions
- Speed controls let player skip boring periods
- Critical events auto-pause (UFO detected, base attacked)
- Creates tension: time passes whether you're ready or not

### Global Threat System

**Pattern**: Hidden "alien activity" score drives escalation

```lua
-- OpenXCOM-style threat escalation
local ThreatManager = {}

function ThreatManager:initialize()
    self.alien_activity = 0  -- Hidden score
    self.escalation_level = 1  -- Current threat tier
    self.monthly_activity = 0
end

function ThreatManager:increaseThreat(amount, reason)
    self.alien_activity = self.alien_activity + amount
    self.monthly_activity = self.monthly_activity + amount
    
    -- Check for escalation thresholds
    if self.alien_activity >= self:getEscalationThreshold() then
        self:escalate()
    end
end

function ThreatManager:escalate()
    self.escalation_level = self.escalation_level + 1
    
    -- XCOM pattern: More dangerous enemies appear
    self:unlockAlienType("muton")
    self:increaseMissionFrequency(1.5)
    self:enableNewMissionType("base_assault")
end

function ThreatManager:monthlyReport()
    -- XCOM pattern: Monthly performance review
    local score = self:calculateMonthlyScore()
    
    if score < THREAT_THRESHOLD then
        -- Player is losing the war
        self:triggerCountryDefection()
    end
    
    self.monthly_activity = 0
end
```

**Design Notes:**
- Invisible score tracks overall alien success
- Player actions reduce score (shoot down UFOs, complete missions)
- Alien actions increase score (successful terror attacks, undetected missions)
- Creates urgency: do nothing and you lose

### Interception Mechanics

**Pattern**: Simplified air combat before ground missions

```lua
-- XCOM-style UFO interception
local InterceptionSystem = {}

function InterceptionSystem:intercept(craft, ufo)
    -- XCOM pattern: Range and speed determine engagement
    local distance = self:calculateDistance(craft.position, ufo.position)
    
    if distance > craft.radar_range then
        return "out_of_range"
    end
    
    if craft.speed < ufo.speed then
        return "too_slow"  -- UFO escapes
    end
    
    -- Enter simplified combat minigame
    local result = self:resolveAirCombat(craft, ufo)
    
    if result == "ufo_destroyed" then
        return "destroyed"
    elseif result == "ufo_crashed" then
        -- XCOM pattern: Generate crash site mission
        self:createCrashSiteMission(ufo)
        return "crashed"
    elseif result == "craft_damaged" then
        craft:returnToBase()
        return "retreated"
    end
end
```

**Design Notes:**
- Prevents every UFO from becoming ground mission
- Craft loadout matters (weapons, armor)
- Risk/reward: dangerous UFOs drop better loot
- Strategic decisions: which base launches interceptors?

### Detection and Radar

**Pattern**: Fog of war over strategic map

```lua
-- Detection coverage system (OpenXCOM-style)
local DetectionSystem = {}

function DetectionSystem:calculateCoverage(bases)
    local coverage_map = {}
    
    for _, base in ipairs(bases) do
        -- Each radar facility extends detection range
        for _, facility in ipairs(base.facilities) do
            if facility.type == "radar" then
                local range = facility.detection_range
                self:addCoverageCircle(coverage_map, base.position, range)
            end
        end
    end
    
    return coverage_map
end

function DetectionSystem:detectUFO(ufo_position, coverage_map)
    -- XCOM pattern: UFOs only visible in radar coverage
    if not self:isInCoverage(ufo_position, coverage_map) then
        return nil  -- UFO passes undetected
    end
    
    -- Detection chance based on UFO size
    local detection_roll = math.random(1, 100)
    if detection_roll > ufo.detection_difficulty then
        return ufo  -- Successfully detected
    end
    
    return nil
end
```

**Design Notes:**
- Building more radar stations extends coverage
- Gap in coverage = missed UFO activity
- Strategic base placement crucial
- Creates "unknown" regions on map

---

## Tactical Layer (Battlescape)

### Action Point System

**Pattern**: Time units determine actions per turn

```lua
-- XCOM action point system
local ActionPointSystem = {}

function ActionPointSystem:canPerformAction(unit, action)
    local cost = self:getActionCost(action, unit)
    
    if unit.time_units < cost then
        return false, "not_enough_time_units"
    end
    
    -- XCOM pattern: Reserve time units for reactions
    if unit.reserved_fire > 0 and (unit.time_units - cost) < unit.reserved_fire then
        return false, "reserved_for_reaction"
    end
    
    return true
end

function ActionPointSystem:getActionCost(action, unit)
    local base_cost = ACTION_COSTS[action]
    
    -- XCOM pattern: TU costs modified by soldier stats
    if action == "fire_weapon" then
        -- Better accuracy = faster shots
        base_cost = base_cost * (100 / unit.firing_accuracy)
    elseif action == "throw_grenade" then
        base_cost = base_cost * (100 / unit.throwing_accuracy)
    elseif action == "move" then
        -- Strength affects movement cost
        base_cost = base_cost * (100 / unit.strength)
    end
    
    return math.floor(base_cost)
end

function ActionPointSystem:endTurn(unit)
    -- XCOM pattern: Unused TUs can convert to morale
    if unit.time_units > 0 then
        unit.morale = math.min(100, unit.morale + (unit.time_units / 10))
    end
    
    unit.time_units = unit.max_time_units  -- Refresh for next turn
end
```

**Design Notes:**
- Every action has TU cost
- Higher stats = more actions per turn
- Encourages strategic movement (save TUs for shooting)
- Can reserve TUs for reaction fire

### Reaction Fire (Overwatch)

**Pattern**: Automatic shots when enemies move

```lua
-- XCOM-style reaction fire system
local ReactionSystem = {}

function ReactionSystem:checkReaction(moving_unit, observing_unit)
    -- Can't react if no TUs reserved
    if observing_unit.reserved_fire == 0 then
        return nil
    end
    
    if not self:canSee(observing_unit, moving_unit) then
        return nil
    end
    
    -- XCOM pattern: Reaction stat vs mover's reactions
    local reaction_roll = math.random(1, 100)
    local observer_chance = observing_unit.reactions
    local mover_dodge = moving_unit.reactions / 2
    
    if reaction_roll < (observer_chance - mover_dodge) then
        -- Trigger reaction shot
        return self:performReactionShot(observing_unit, moving_unit)
    end
    
    return nil
end

function ReactionSystem:performReactionShot(shooter, target)
    -- Spend reserved TUs
    shooter.time_units = shooter.time_units - shooter.reserved_fire
    shooter.reserved_fire = 0
    
    -- Fire at target with accuracy penalty
    local hit_chance = self:calculateHitChance(shooter, target) * 0.7
    return self:resolveShot(shooter, target, hit_chance)
end
```

**Design Notes:**
- Punishes reckless movement
- High-reaction soldiers control space
- Must decide: use TUs now or save for reactions
- Creates overwatch positioning tactics

### Fog of War and Line of Sight

**Pattern**: Only visible tiles can be targeted

```lua
-- XCOM line-of-sight system
local LineOfSight = {}

function LineOfSight:calculateVisibility(unit, battlefield)
    local visible_tiles = {}
    local vision_range = unit.vision_range
    
    -- XCOM pattern: Vision range affected by time of day
    if battlefield.is_night then
        vision_range = math.floor(vision_range * 0.5)
    end
    
    -- Cast rays from unit to all tiles in range
    for dx = -vision_range, vision_range do
        for dy = -vision_range, vision_range do
            local target_x = unit.x + dx
            local target_y = unit.y + dy
            
            if self:hasLOS(unit.x, unit.y, target_x, target_y, battlefield) then
                table.insert(visible_tiles, {x = target_x, y = target_y})
            end
        end
    end
    
    return visible_tiles
end

function LineOfSight:hasLOS(x1, y1, x2, y2, battlefield)
    -- Bresenham's line algorithm
    local tiles = self:getTilesInLine(x1, y1, x2, y2)
    
    for _, tile in ipairs(tiles) do
        local terrain = battlefield:getTile(tile.x, tile.y)
        
        -- XCOM pattern: Different terrain blocks LOS differently
        if terrain.blocks_vision then
            return false
        end
        
        -- Partial cover reduces vision but doesn't block
        if terrain.cover_value > 50 and math.random() < 0.5 then
            return false
        end
    end
    
    return true
end
```

**Design Notes:**
- Can only shoot what you can see
- Night missions drastically reduce vision
- Terrain affects visibility
- Smoke and fire create dynamic vision blockers

### Cover System

**Pattern**: Terrain provides damage reduction

```lua
-- XCOM cover mechanics
local CoverSystem = {}

function CoverSystem:getCoverValue(unit, attacker, battlefield)
    local tile = battlefield:getTile(unit.x, unit.y)
    local cover = 0
    
    -- XCOM pattern: Direction matters for cover
    local attack_direction = self:getDirection(attacker, unit)
    
    if attack_direction == "north" and tile.cover_north then
        cover = tile.cover_north
    elseif attack_direction == "east" and tile.cover_east then
        cover = tile.cover_east
    -- ... check all directions
    end
    
    -- XCOM pattern: Stance affects cover
    if unit.stance == "crouched" then
        cover = cover + 20
    elseif unit.stance == "prone" then
        cover = cover + 40
    end
    
    return math.min(100, cover)
end

function CoverSystem:applyCoverToHitChance(base_chance, cover_value)
    -- XCOM formula: Cover reduces hit chance
    return base_chance * (1 - (cover_value / 100))
end

function CoverSystem:applyCoverToDamage(damage, cover_value)
    -- High cover can also reduce damage on hits
    if cover_value >= 75 then
        damage = math.floor(damage * 0.7)
    elseif cover_value >= 50 then
        damage = math.floor(damage * 0.85)
    end
    
    return damage
end
```

**Design Notes:**
- Half cover: ~30-50% protection
- Full cover: ~60-90% protection
- Direction matters (flanking negates cover)
- Can be destroyed by explosives

### Morale and Panic

**Pattern**: Psychological warfare affects unit behavior

```lua
-- XCOM morale system
local MoraleSystem = {}

function MoraleSystem:initialize(unit)
    unit.morale = unit.base_bravery or 50
    unit.panicked = false
    unit.berserk = false
end

function MoraleSystem:applyMoraleEvent(unit, event_type, severity)
    local morale_change = 0
    
    -- XCOM pattern: Different events affect morale
    if event_type == "ally_killed" then
        morale_change = -20 * (severity or 1)
    elseif event_type == "wounded" then
        morale_change = -10
    elseif event_type == "enemy_killed" then
        morale_change = 5
    elseif event_type == "saw_dead_body" then
        morale_change = -5
    elseif event_type == "psionic_attack" then
        morale_change = -30
    end
    
    unit.morale = math.max(0, math.min(100, unit.morale + morale_change))
    
    -- XCOM pattern: Low morale triggers panic checks
    if unit.morale < 40 then
        self:checkPanic(unit)
    end
end

function MoraleSystem:checkPanic(unit)
    local panic_roll = math.random(1, 100)
    
    if panic_roll > unit.morale then
        -- Unit panics!
        local panic_type = math.random(1, 3)
        
        if panic_type == 1 then
            -- Berserk: Fire wildly at friend or foe
            unit.berserk = true
            self:performBerserkAction(unit)
        elseif panic_type == 2 then
            -- Freeze: Can't act this turn
            unit.panicked = true
            unit.time_units = 0
        else
            -- Flee: Run toward extraction
            unit.panicked = true
            self:fleeToExtraction(unit)
        end
    end
end
```

**Design Notes:**
- Weak-willed soldiers panic under pressure
- High-bravery veterans stay cool
- Creates unpredictable moments
- Risk of friendly fire when panicked

---

## Research & Technology

### Tech Tree Structure

**Pattern**: Gated progression through research dependencies

```lua
-- OpenXCOM-style research tree
local ResearchTree = {}

function ResearchTree:canResearch(research_id, player_state)
    local research = RESEARCH_DATABASE[research_id]
    
    -- Check prerequisites
    for _, prerequisite in ipairs(research.required_research or {}) do
        if not player_state.completed_research[prerequisite] then
            return false, "missing_prerequisite"
        end
    end
    
    -- XCOM pattern: Need physical items to research
    for _, item_requirement in ipairs(research.required_items or {}) do
        local count = player_state.inventory[item_requirement.id] or 0
        if count < item_requirement.count then
            return false, "missing_item"
        end
    end
    
    -- XCOM pattern: Need alien autopsies
    for _, autopsy in ipairs(research.required_autopsies or {}) do
        if not player_state.completed_autopsies[autopsy] then
            return false, "missing_autopsy"
        end
    end
    
    return true
end

function ResearchTree:completeResearch(research_id, player_state)
    local research = RESEARCH_DATABASE[research_id]
    
    player_state.completed_research[research_id] = true
    
    -- XCOM pattern: Unlock new content
    for _, item_id in ipairs(research.unlocks_items or {}) do
        player_state.available_items[item_id] = true
    end
    
    for _, research_id in ipairs(research.unlocks_research or {}) do
        -- Make new research visible
        player_state.available_research[research_id] = true
    end
    
    for _, facility_id in ipairs(research.unlocks_facilities or {}) do
        player_state.available_facilities[facility_id] = true
    end
    
    -- XCOM pattern: Some research provides passive bonuses
    if research.global_effects then
        self:applyGlobalEffects(research.global_effects, player_state)
    end
end
```

**Design Principles:**
- Early research: Alien biology, basic weapons
- Mid-game: Improved armor, specialized weapons
- Late-game: Psionics, alien base locations
- Victory condition: Ultimate research goal

### Alien Autopsy System

**Pattern**: Capture and study alien species

```lua
-- XCOM autopsy system
local AutopsySystem = {}

function AutopsySystem:captureAlien(alien_type, alive)
    if alive then
        -- Live capture worth more
        return {
            type = "live_capture",
            alien_type = alien_type,
            research_value = 300,
            sell_value = 50000
        }
    else
        -- Dead alien for autopsy
        return {
            type = "corpse",
            alien_type = alien_type,
            research_value = 100,
            sell_value = 5000
        }
    end
end

function AutopsySystem:performAutopsy(alien_type, scientists)
    local research_time = BASE_AUTOPSY_TIME / scientists
    
    -- XCOM pattern: Autopsy unlocks alien-specific knowledge
    return {
        research_id = "autopsy_" .. alien_type,
        completion_time = research_time,
        unlocks = {
            weaknesses = true,  -- Learn alien vulnerabilities
            psionic_potential = alien_type == "sectoid",
            interrogation = true  -- Can interrogate live specimen
        }
    }
end
```

---

## Base Management

### Facility Construction

**Pattern**: Tetris-like base building with adjacency bonuses

```lua
-- XCOM base building system
local BaseBuilder = {}

function BaseBuilder:canBuildFacility(base, facility_type, x, y)
    local facility = FACILITY_DATABASE[facility_type]
    
    -- Check if space is available
    for dx = 0, facility.width - 1 do
        for dy = 0, facility.height - 1 do
            if not base:isTileEmpty(x + dx, y + dy) then
                return false, "space_occupied"
            end
        end
    end
    
    -- XCOM pattern: Must connect to existing facilities
    if not self:isConnectedToBase(base, x, y, facility.width, facility.height) then
        return false, "not_connected"
    end
    
    -- Check prerequisites
    if facility.requires_facility then
        if not base:hasFacility(facility.requires_facility) then
            return false, "missing_prerequisite_facility"
        end
    end
    
    return true
end

function BaseBuilder:buildFacility(base, facility_type, x, y)
    local facility = {
        type = facility_type,
        x = x,
        y = y,
        construction_remaining = FACILITY_DATABASE[facility_type].build_days
    }
    
    base:addFacility(facility)
    base:spendCredits(FACILITY_DATABASE[facility_type].cost)
    
    return facility
end

function BaseBuilder:getAdjacentBonuses(base, facility)
    -- XCOM pattern: Some facilities benefit from adjacency
    local bonuses = {}
    
    if facility.type == "laboratory" then
        -- Labs adjacent to other labs get bonus
        local adjacent_labs = self:countAdjacentFacilities(base, facility, "laboratory")
        bonuses.research_speed = 1 + (adjacent_labs * 0.1)
    elseif facility.type == "workshop" then
        -- Workshops benefit from adjacency
        local adjacent_workshops = self:countAdjacentFacilities(base, facility, "workshop")
        bonuses.production_speed = 1 + (adjacent_workshops * 0.1)
    end
    
    return bonuses
end
```

### Personnel Management

**Pattern**: Hire, train, and manage soldiers and staff

```lua
-- XCOM personnel system
local PersonnelManager = {}

function PersonnelManager:hireSoldier()
    -- XCOM pattern: Randomized starting stats
    local soldier = {
        id = generate_id(),
        name = self:generateName(),
        rank = "rookie",
        
        -- Stats vary by 50-70
        time_units = math.random(50, 70),
        stamina = math.random(50, 70),
        health = math.random(25, 35),
        bravery = math.random(10, 60),  -- Wide variance in bravery
        reactions = math.random(30, 60),
        firing_accuracy = math.random(40, 70),
        throwing_accuracy = math.random(50, 80),
        strength = math.random(20, 40),
        psionic_strength = math.random(0, 100),  -- Hidden until trained
        psionic_skill = 0,
        
        -- XCOM pattern: Stats improve through use
        missions_completed = 0,
        kills = 0,
        wounds = 0,
    }
    
    return soldier
end

function PersonnelManager:promoteSlendier(soldier)
    -- XCOM pattern: Rank based on missions/kills
    if soldier.missions_completed >= 10 and soldier.kills >= 5 then
        soldier.rank = "squaddie"
    elseif soldier.missions_completed >= 25 and soldier.kills >= 15 then
        soldier.rank = "sergeant"
    elseif soldier.missions_completed >= 50 and soldier.kills >= 30 then
        soldier.rank = "captain"
    elseif soldier.missions_completed >= 100 and soldier.kills >= 60 then
        soldier.rank = "colonel"
    end
    
    -- Higher rank = better stats
    soldier.time_units = soldier.time_units + 2
    soldier.bravery = math.min(100, soldier.bravery + 10)
end
```

---

## Resource Economy

### Monthly Funding

**Pattern**: Council nations provide funding based on performance

```lua
-- XCOM funding system
local FundingSystem = {}

function FundingSystem:calculateMonthlyFunding(player_state, world_state)
    local total_funding = 0
    
    for _, country in ipairs(world_state.countries) do
        -- XCOM pattern: Funding based on country satisfaction
        local base_funding = country.base_funding
        local satisfaction_modifier = country.satisfaction / 100
        
        local funding = base_funding * satisfaction_modifier
        total_funding = total_funding + funding
        
        -- XCOM pattern: Countries can leave council
        if country.satisfaction < 20 then
            self:countryDefects(country)
        end
    end
    
    return total_funding
end

function FundingSystem:modifyCountrySatisfaction(country, event_type, location)
    local satisfaction_change = 0
    
    -- XCOM pattern: Events affect nearby countries more
    local distance_factor = self:getDistanceFactor(country, location)
    
    if event_type == "terror_mission_success" then
        satisfaction_change = 20 * distance_factor
    elseif event_type == "terror_mission_failure" then
        satisfaction_change = -30 * distance_factor
    elseif event_type == "ufo_shot_down" then
        satisfaction_change = 5 * distance_factor
    elseif event_type == "base_built_in_country" then
        satisfaction_change = 10
    end
    
    country.satisfaction = math.max(0, math.min(100, 
        country.satisfaction + satisfaction_change))
end
```

### Manufacturing Economy

**Pattern**: Convert resources into usable items

```lua
-- XCOM manufacturing system
local ManufacturingSystem = {}

function ManufacturingSystem:startProject(base, project_id)
    local project = MANUFACTURING_DATABASE[project_id]
    
    -- Check resources
    for resource, amount in pairs(project.required_resources) do
        if base.storage[resource] < amount then
            return nil, "insufficient_resources"
        end
    end
    
    -- Check engineers
    if base.available_engineers < project.required_engineers then
        return nil, "insufficient_engineers"
    end
    
    -- Allocate engineers
    base.available_engineers = base.available_engineers - project.required_engineers
    
    -- Start production
    local production = {
        project_id = project_id,
        hours_remaining = project.engineer_hours,
        engineers_assigned = project.required_engineers
    }
    
    table.insert(base.active_production, production)
    
    return production
end

function ManufacturingSystem:updateProduction(base, hours_elapsed)
    for i = #base.active_production, 1, -1 do
        local production = base.active_production[i]
        
        -- XCOM pattern: More engineers = faster production (with diminishing returns)
        local work_done = hours_elapsed * production.engineers_assigned
        production.hours_remaining = production.hours_remaining - work_done
        
        if production.hours_remaining <= 0 then
            -- Production complete
            self:completeProduction(base, production)
            table.remove(base.active_production, i)
        end
    end
end
```

---

## Mission Generation

### Alien Activity Simulation

**Pattern**: UFOs have actual purposes, not just spawns

```lua
-- XCOM UFO activity system
local UFOActivitySystem = {}

function UFOActivitySystem:generateMission()
    local mission_type = self:selectMissionType()
    
    -- XCOM pattern: UFOs follow scripted mission profiles
    if mission_type == "research" then
        return {
            phases = {
                {type = "flyby", duration = 300},  -- Scout area
                {type = "patrol", duration = 600},  -- Circle region
                {type = "return", duration = 300}   -- Leave
            }
        }
    elseif mission_type == "harvest" then
        return {
            phases = {
                {type = "flyby", duration = 200},
                {type = "land", duration = 1800},  -- Long ground mission
                {type = "return", duration = 200}
            }
        }
    elseif mission_type == "terror" then
        return {
            phases = {
                {type = "direct_land", duration = 0},  -- Immediate landing
                {type = "terror_attack", duration = 3600},  -- 1 hour attack
                {type = "return", duration = 300}
            }
        }
    elseif mission_type == "infiltration" then
        return {
            phases = {
                {type = "sneak_land", duration = 0},
                {type = "infiltrate", duration = 7200},  -- 2 hours hidden
                {type = "establish_base", duration = 0}  -- Permanent base
            }
        }
    end
end
```

### Dynamic Mission Difficulty

**Pattern**: Mission difficulty scales with multiple factors

```lua
-- XCOM mission difficulty system
local MissionDifficulty = {}

function MissionDifficulty:calculate(mission_type, location, game_month)
    local difficulty = {
        base_difficulty = MISSION_TYPES[mission_type].base_difficulty,
        enemy_count = 0,
        enemy_types = {},
        equipment_level = 0
    }
    
    -- XCOM pattern: Difficulty increases over time
    local time_multiplier = 1 + (game_month / 12) * 0.5
    
    -- XCOM pattern: Location affects difficulty
    local location_factor = location.alien_activity / 100
    
    -- Calculate enemy count
    difficulty.enemy_count = math.floor(
        difficulty.base_difficulty.min_enemies * time_multiplier * location_factor
    )
    
    -- XCOM pattern: Later enemies replace earlier ones
    if game_month < 3 then
        difficulty.enemy_types = {"sectoid", "floater"}
    elseif game_month < 6 then
        difficulty.enemy_types = {"sectoid", "floater", "snakeman"}
    elseif game_month < 9 then
        difficulty.enemy_types = {"floater", "snakeman", "muton"}
    else
        difficulty.enemy_types = {"muton", "ethereal", "chryssalid"}
    end
    
    -- Equipment level improves over time
    difficulty.equipment_level = math.min(3, math.floor(game_month / 4))
    
    return difficulty
end
```

---

## Difficulty Scaling

### Player Skill Adaptation

**Pattern**: Game difficulty responds to player performance

```lua
-- Adaptive difficulty system (modern XCOM)
local AdaptiveDifficulty = {}

function AdaptiveDifficulty:initialize()
    self.player_performance = {
        missions_succeeded = 0,
        missions_failed = 0,
        soldiers_lost = 0,
        average_mission_completion_time = 0
    }
    self.difficulty_modifier = 1.0
end

function AdaptiveDifficulty:updateAfterMission(mission_result)
    if mission_result.success then
        self.player_performance.missions_succeeded = 
            self.player_performance.missions_succeeded + 1
    else
        self.player_performance.missions_failed = 
            self.player_performance.missions_failed + 1
    end
    
    -- Calculate win rate
    local total = self.player_performance.missions_succeeded + 
                  self.player_performance.missions_failed
    local win_rate = self.player_performance.missions_succeeded / total
    
    -- Adjust difficulty
    if win_rate > 0.8 then
        -- Player doing too well
        self.difficulty_modifier = math.min(1.5, self.difficulty_modifier + 0.05)
    elseif win_rate < 0.4 then
        -- Player struggling
        self.difficulty_modifier = math.max(0.7, self.difficulty_modifier - 0.05)
    end
end

function AdaptiveDifficulty:applyModifier(base_value)
    return math.floor(base_value * self.difficulty_modifier)
end
```

---

## Permanent Consequences

### Permadeath

**Pattern**: Dead soldiers stay dead

```lua
-- XCOM permadeath system
local PermaDeathSystem = {}

function PermaDeathSystem:handleSoldierDeath(soldier, base)
    -- Remove from active roster
    for i, active_soldier in ipairs(base.soldiers) do
        if active_soldier.id == soldier.id then
            table.remove(base.soldiers, i)
            break
        end
    end
    
    -- Add to memorial
    table.insert(base.memorial, {
        name = soldier.name,
        rank = soldier.rank,
        missions_completed = soldier.missions_completed,
        kills = soldier.kills,
        date_of_death = game_state.current_date,
        cause_of_death = soldier.last_damage_source
    })
    
    -- XCOM pattern: Death affects morale
    for _, other_soldier in ipairs(base.soldiers) do
        other_soldier.morale = math.max(0, other_soldier.morale - 10)
    end
    
    -- XCOM pattern: Lose carried equipment permanently
    -- (unless mission successful and body recovered)
    if not soldier.body_recovered then
        soldier.equipment = {}  -- Lost forever
    end
end
```

### Campaign Failure Conditions

**Pattern**: Multiple ways to lose the game

```lua
-- XCOM loss conditions
local CampaignManager = {}

function CampaignManager:checkDefeatConditions(game_state)
    -- Loss Condition 1: Financial collapse
    if game_state.credits < -1000000 then
        return "bankruptcy", "XCOM has run out of funding"
    end
    
    -- Loss Condition 2: Council dissolves
    local active_countries = 0
    for _, country in ipairs(game_state.countries) do
        if country.in_council then
            active_countries = active_countries + 1
        end
    end
    
    if active_countries < 4 then
        return "no_support", "Too many countries have left the council"
    end
    
    -- Loss Condition 3: All bases destroyed
    if #game_state.bases == 0 then
        return "total_defeat", "All XCOM bases have been destroyed"
    end
    
    -- Loss Condition 4: Time limit (optional)
    if game_state.campaign_months > 24 and not game_state.final_mission_unlocked then
        return "time_limit", "Failed to stop alien invasion in time"
    end
    
    return nil
end
```

---

## OpenXCOM Implementation Details

### Ruleset System

OpenXCOM uses YAML-based rulesets that define all game content. Here's how Alien Fall improves on this:

```toml
# OpenXCOM uses YAML, Alien Fall uses TOML
# This is more readable and less error-prone

[[item]]
id = "plasma_rifle"
name = "Plasma Rifle"
type = "weapon"

[item.physical]
size = 0.2
weight = 8
sprite_index = 6

[item.combat]
damage = 80
accuracy_auto = 56
time_units_auto = 35
fire_sound = "plasma_shot"
damage_type = "plasma"

[item.ammo]
clip_size = 25
ammo_type = "plasma_clip"
reload_time = 15
```

### Save File Compatibility

OpenXCOM maintains save compatibility across versions. Alien Fall follows similar principles:

```lua
-- Version-aware save system
local SaveSystem = {}

function SaveSystem:save(game_state)
    local save_data = {
        version = GAME_VERSION,
        timestamp = os.time(),
        game_state = game_state
    }
    
    -- Serialize to JSON
    local json = json.encode(save_data)
    love.filesystem.write("save/slot1.json", json)
end

function SaveSystem:load(filename)
    local contents = love.filesystem.read(filename)
    local save_data = json.decode(contents)
    
    -- OpenXCOM pattern: Migrate old saves
    if save_data.version ~= GAME_VERSION then
        save_data = self:migrateSave(save_data)
    end
    
    return save_data.game_state
end

function SaveSystem:migrateSave(save_data)
    -- Handle version differences
    if save_data.version == "0.1.0" and GAME_VERSION == "0.2.0" then
        -- Add new fields with defaults
        save_data.game_state.new_feature = default_value
    end
    
    return save_data
end
```

---

## References

### Official XCOM Resources

- Original X-COM: UFO Defense (1994)
- XCOM: Enemy Unknown (2012)
- XCOM 2 (2016)

### OpenXCOM Resources

- [OpenXCOM GitHub](https://github.com/OpenXcom/OpenXcom)
- [OpenXCOM Wiki](https://www.ufopaedia.org/index.php/OpenXcom)
- [OpenXCOM Modding Guide](https://www.ufopaedia.org/index.php/Modding)
- [OpenXCOM Ruleset Reference](https://www.ufopaedia.org/index.php/Ruleset_Reference)

### Design Analysis

- [XCOM's Brilliant Formula](https://www.gamedeveloper.com/design/analyzing-xcom-s-design)
- [The Design of XCOM](https://www.youtube.com/watch?v=O6dtu6pR_wE)
- [Turn-Based Strategy Mechanics](https://www.gamedeveloper.com/design/turn-based-strategy-design-patterns)

---

**Tags:** `#xcom` `#design-patterns` `#strategy` `#turn-based` `#openxcom` `#game-design`
