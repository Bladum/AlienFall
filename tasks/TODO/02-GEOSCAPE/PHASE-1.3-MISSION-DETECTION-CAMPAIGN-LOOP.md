# PHASE 1.3: Mission Detection & Campaign Loop Implementation
## Strategic Campaign Management System - Week 3

**Phase:** 1 (Foundation Systems)  
**Week:** 3  
**Priority:** CRITICAL  
**Status:** TODO  
**Estimated Time:** 45 hours  
**Created:** October 15, 2025  
**Dependencies:** Phase 1.1 (Calendar, World Map) + Phase 1.2 (Map Generation)  
**Enables:** Complete gameplay loop

---

## 🎯 Overview

Implement the core campaign gameplay loop: Daily mission detection → Mission spawning → Player deployment → Battle completion → Campaign state update. This creates the "meta-game" progression that drives strategic decisions and consequences.

**Core Deliverable:** Players experience:
1. Time advances day-by-day on the Geoscape calendar
2. Missions spawn randomly in provinces (based on province type, game state, difficulty)
3. Missions display with urgency (time limit to deploy)
4. Player can select and deploy to any mission
5. After battle, results affect campaign state (score, relations, threats, etc.)
6. Campaign progresses toward strategic objectives

### Why This Phase?
- Completes the strategic layer gameplay loop
- Enables dynamic campaign experience
- Creates replayability (different missions each playthrough)
- Connects all three layers (Strategic → Tactical → Results → Strategic)

---

## 📋 Technical Requirements

### 1. Mission Detection System (12 hours)

#### 1.1 Daily Mission Generation
**Objective:** Each in-game day, check each province for mission spawning

**Algorithm:**
- Each province has a base mission spawn probability (2-5% per day)
- Probability increases with difficulty setting
- Different biomes have different mission types available
- Probability increases when threats accumulate

**Implementation:**
- Create: `engine/geoscape/mission_detection.lua`
- Create: `mods/core/data/mission_probabilities.toml`
- Reference: `engine/core/calendar.lua` (daily events)

**Data Structure (TOML):**
```toml
[mission_spawn_probabilities]

# Base probabilities (per day, per province)
difficulty_easy = 0.02      # 2% per province per day
difficulty_normal = 0.035   # 3.5%
difficulty_hard = 0.05      # 5%
difficulty_ironman = 0.06   # 6%

# Biome-specific modifiers
[biome_mission_modifiers]
temperate = 1.0    # Base rate
desert = 0.8       # Fewer missions
jungle = 0.7       # Remote, fewer contacts
tundra = 0.6       # Isolated
urban = 1.5        # High population = more activity
ocean = 0.1        # Almost no missions

# Mission types available per biome
[biome_mission_types]
temperate = ["site_investigation", "ufo_crash", "base_defense", "terror_mission"]
desert = ["ufo_crash", "site_investigation"]
jungle = ["base_defense", "terror_mission"]
tundra = ["ufo_crash"]
urban = ["terror_mission", "base_defense"]
ocean = []
```

**Algorithm:**
```lua
function MissionDetection:check_daily_missions(province)
    -- Called once per day per province by calendar system
    
    local base_prob = self:get_base_probability(self.difficulty)
    local biome_mod = self:get_biome_modifier(province.biome)
    local threat_mod = self:get_threat_modifier(province)  -- Increases if already threatened
    
    local final_prob = base_prob * biome_mod * threat_mod
    
    if math.random() < final_prob then
        -- Mission spawns!
        local mission_type = self:select_mission_type(province)
        local mission = self:create_mission(province, mission_type)
        
        self:add_mission_to_province(province, mission)
        self:notify_player("New mission in " .. province.name)
    end
end
```

**Tests:**
- Verify probability calculations
- Test mission spawning over 100+ simulated days
- Verify correct biome-to-mission mapping
- Test that missions spawn on expected timescale

#### 1.2 Mission Expiration
**Objective:** Missions age and disappear if not tackled

**System:**
- Each mission has a time limit (1-7 days depending on urgency)
- If not deployed to within time limit, mission expires
- Expiration has consequences (casualties, funding loss, relations penalty)

**Implementation:**
- Modify: `engine/geoscape/mission_detection.lua` (add expiration logic)
- Create: `mods/core/data/mission_templates.toml` (mission urgency)

**Algorithm:**
```lua
function MissionDetection:update_missions(days_passed)
    for province_id, missions in pairs(self.active_missions) do
        for i=#missions,1,-1 do
            local mission = missions[i]
            mission.time_remaining = mission.time_remaining - days_passed
            
            if mission.time_remaining <= 0 then
                -- Mission expires
                self:expire_mission(mission)
                table.remove(missions, i)
            elseif mission.time_remaining <= 1 then
                -- Urgent!
                mission.urgency = "critical"
            end
        end
    end
end

function MissionDetection:expire_mission(mission)
    print("[Mission] Mission expired: " .. mission.type)
    
    -- Consequences
    if mission.type == "terror_mission" then
        -- Civilians died
        self:add_casualties(mission.province, 500)
        self:add_panic(mission.province, 0.2)
        self:reduce_funding(50000)
    elseif mission.type == "base_defense" then
        -- Base attacked?
        local defended = self:check_base_defended(mission.target_base)
        if not defended then
            self:damage_base(mission.target_base, 0.3)
        end
    end
    
    self:update_campaign_state()
end
```

**Tests:**
- Verify expiration timing
- Test consequences for each mission type
- Test UI updates when mission expires

---

### 2. Mission Type System (10 hours)

#### 2.1 Mission Type Definitions
**Objective:** Define all mission types with objectives, rewards, and difficulty modifiers

**Mission Types:**

1. **Site Investigation**
   - Investigate alien/unknown activity
   - Objective: Find and eliminate threat
   - Duration: 1-3 days
   - Difficulty: Low-Medium
   - Rewards: Research, Artifacts, Funding
   - Consequence if failed: Threat escalates

2. **UFO Crash Recovery**
   - Recover downed UFO technology
   - Objective: Secure the crash site
   - Duration: 2-4 days (high urgency)
   - Difficulty: Medium-High
   - Rewards: Advanced Technology, Artifacts, Alien Bodies
   - Consequence: Other factions may interfere

3. **Base Defense**
   - Defend against alien assault on player base
   - Objective: Repel enemy
   - Duration: Immediate (0-1 day)
   - Difficulty: Medium-Hard
   - Rewards: None (failure = base damage)
   - Consequence: Damage structures if failed

4. **Terror Mission**
   - Alien assault on civilian population
   - Objective: Eliminate aliens, protect civilians
   - Duration: 1-2 days (high urgency)
   - Difficulty: Low-Medium
   - Rewards: Funding, Relations boost, Artifacts
   - Consequence: Casualties, panic if failed

5. **Research Expedition**
   - Investigate anomaly or artifact site
   - Objective: Collect samples, learn, escape
   - Duration: 2-3 days
   - Difficulty: Low
   - Rewards: Research points, Artifacts
   - Consequence: Alien reinforcements if prolonged

**Data Structure (TOML):**
```toml
[mission_type_site_investigation]
name = "Site Investigation"
description = "Investigate unknown activity in {province}"
urgency_level = 2  # 1-5, 5 is most urgent
time_limit = 3     # Days
squad_size_min = 4
squad_size_max = 8
difficulty_mod_easy = 0.8
difficulty_mod_normal = 1.0
difficulty_mod_hard = 1.2
enemy_squad_size = 3
rewards = {
    research = 200,
    artifacts = 1,
    funding = 15000,
    xp = 500
}
consequences_success = "Threat eliminated"
consequences_failure = "Threat escalates in region"

[mission_type_ufo_crash]
name = "UFO Crash Recovery"
urgency_level = 4
time_limit = 2
squad_size_min = 6
squad_size_max = 10
difficulty_mod_easy = 1.0
difficulty_mod_normal = 1.2
difficulty_mod_hard = 1.5
enemy_squad_size = 5
rewards = {
    research = 400,
    artifacts = 3,
    alien_bodies = 2,
    funding = 50000
}

# ... more mission types ...
```

**Tests:**
- Verify all mission types have valid definitions
- Test mission difficulty calculation
- Test reward calculation

#### 2.2 Mission Generation
**Objective:** Create individual mission instances from templates

**Process:**
1. Select mission type for province
2. Generate specific mission details (enemy composition, difficulty scaling)
3. Calculate time limit and urgency
4. Store mission in active mission list

**Implementation:**
- Create: `engine/geoscape/mission_factory.lua`
- Reference: `docs/balance/GAME_NUMBERS.md` (balance values)

**Algorithm:**
```lua
function MissionFactory:create_mission(province, mission_type_key)
    local template = self:load_template(mission_type_key)
    
    local mission = {
        id = uuid.generate(),
        type = mission_type_key,
        province = province,
        biome = province.biome,
        created_turn = current_calendar.turn,
        time_limit = template.time_limit,
        time_remaining = template.time_limit,
        urgency = self:calculate_urgency(template.urgency_level),
        
        -- Squad composition
        player_squad_size = random_range(template.squad_size_min, template.squad_size_max),
        enemy_count = template.enemy_squad_size + random_range(-1, 1),
        
        -- Difficulty
        difficulty_scale = self:calculate_difficulty(template.difficulty_mod_easy),
        
        -- Rewards
        rewards = self:scale_rewards(template.rewards),
        
        -- State
        status = "active",
        deployed = false,
    }
    
    return mission
end

function MissionFactory:calculate_urgency(base_urgency)
    -- Urgency 1-5 scale
    -- 1 = can wait weeks
    -- 5 = immediate threat
    return base_urgency
end
```

**Tests:**
- Verify mission instance generation
- Test difficulty scaling
- Test reward calculation
- Test squad composition randomness

---

### 3. Campaign State Tracking (10 hours)

#### 3.1 Campaign Metrics
**Objective:** Track campaign progress and consequences

**Metrics:**
- **Score:** Total points from missions, research, etc.
- **Funding:** Player budget (depletes over time, increases with missions)
- **Panic:** Global panic level (0-100, if >80 world may turn against you)
- **Casualties:** Civilian casualties tracked by region
- **Alien Threat:** Overall threat level based on UFO activity
- **Research Points:** Accumulated from missions
- **Technology Level:** Current tech tier (ballistic → laser → plasma, etc.)
- **Base Damage:** Structural integrity of player bases
- **Relations:** Relationship with countries/factions (-100 to +100)
- **Artifacts Collected:** Technology samples for reverse engineering

**Implementation:**
- Create: `engine/geoscape/campaign_manager.lua`
- Create: `mods/core/data/campaign_state.toml` (initial state)

**Data Structure:**
```lua
campaign_state = {
    turn = 0,
    difficulty = "normal",
    
    -- Metrics
    score = 0,
    funding = 1000000,           -- Start with 1M
    panic = 0.2,                 -- 20% global panic
    total_casualties = 0,
    total_research = 0,
    technology_level = 1,        -- Tier 1 (ballistic)
    threat_level = 0.3,          -- 30% threat
    
    -- Regional data
    panic_by_region = {},        -- province_id → 0-100
    casualties_by_region = {},   -- province_id → count
    relations_by_country = {},   -- country_id → -100 to 100
    
    -- Base info
    bases = {},                  -- List of player bases
    crafts = {},                 -- List of player crafts
    
    -- Research
    research_tree = {},          -- { tech_id → {progress, completed} }
    
    -- History
    missions_completed = 0,
    missions_failed = 0,
    aliens_killed = 0,
}
```

**Tests:**
- Verify campaign state initialization
- Test state updates after missions
- Test metric bounds (funding ≥0, panic 0-100, etc.)

#### 3.2 Mission Completion & Results
**Objective:** Update campaign state based on mission outcome

**Process:**
1. Player completes or fails mission
2. System calculates results (casualties, rewards, etc.)
3. Update campaign metrics
4. Store mission in history
5. Notify player of changes

**Implementation:**
- Create: `engine/geoscape/mission_completion_system.lua`

**Algorithm:**
```lua
function MissionCompletion:process_mission_result(mission, battle_result)
    print("[Campaign] Processing mission result: " .. mission.type)
    
    if battle_result.victory then
        self:on_mission_success(mission, battle_result)
    else
        self:on_mission_failure(mission, battle_result)
    end
    
    self:update_campaign_metrics(mission, battle_result)
    self:notify_player_of_changes(mission, battle_result)
end

function MissionCompletion:on_mission_success(mission, battle_result)
    print("[Campaign] Mission successful: " .. mission.type)
    
    local campaign = self.campaign_state
    
    -- Award points and research
    campaign.score = campaign.score + battle_result.xp
    campaign.total_research = campaign.total_research + mission.rewards.research
    
    -- Funding varies by mission type
    if mission.type == "terror_mission" then
        campaign.funding = campaign.funding + mission.rewards.funding
        campaign:reduce_panic(0.1)  -- Panic down
        campaign:improve_relations(20)
    elseif mission.type == "ufo_crash" then
        campaign.funding = campaign.funding + mission.rewards.funding
        campaign:add_artifacts(mission.rewards.artifacts)
        campaign:add_alien_bodies(mission.rewards.alien_bodies)
    end
    
    -- Casualties
    campaign.total_casualties = campaign.total_casualties + battle_result.civilian_casualties
    
    -- Update mission history
    table.insert(campaign.mission_history, {
        type = mission.type,
        province = mission.province.name,
        result = "success",
        turn = campaign.turn,
    })
    
    campaign.missions_completed = campaign.missions_completed + 1
end

function MissionCompletion:on_mission_failure(mission, battle_result)
    print("[Campaign] Mission failed: " .. mission.type)
    
    local campaign = self.campaign_state
    
    -- Consequences vary by mission type
    if mission.type == "terror_mission" then
        campaign.total_casualties = campaign.total_casualties + (1000 + battle_result.civilian_casualties)
        campaign:increase_panic(0.2)
        campaign:reduce_relations(30)
        campaign.funding = campaign.funding - 50000
    elseif mission.type == "ufo_crash" then
        campaign:increase_threat(0.3)
        campaign.funding = campaign.funding - 30000
    elseif mission.type == "base_defense" then
        campaign:damage_base(mission.target_base, 0.4)
    end
    
    campaign.missions_failed = campaign.missions_failed + 1
end

function MissionCompletion:update_campaign_metrics(mission, battle_result)
    -- Recalculate global threat level, panic, etc.
    -- based on current mission history
    self:recalculate_metrics()
end
```

**Tests:**
- Test success scenarios (check rewards applied)
- Test failure scenarios (check consequences)
- Test state consistency after mission
- Test multiple mission sequences

---

### 4. Campaign Loop Integration (13 hours)

#### 4.1 Daily Turn Progression
**Objective:** Advance campaign state each day

**Process:**
1. Calendar advances (1 day)
2. Mission detection checks each province
3. New missions appear
4. Mission timers decrement
5. Expired missions are processed
6. Campaign metrics updated
7. UI refreshed

**Implementation:**
- Modify: `engine/core/calendar.lua` (add campaign callbacks)
- Create: `engine/geoscape/campaign_loop.lua` (orchestrator)

**Algorithm:**
```lua
function CampaignLoop:advance_day()
    print("[Campaign] Advancing to day " .. (self.calendar.turn + 1))
    
    -- Advance calendar
    self.calendar:advance_day()
    
    -- Check for new missions in each province
    for province_id, province in pairs(self.world.provinces) do
        self.mission_detection:check_daily_missions(province)
    end
    
    -- Update existing missions (decrement timers, expire old ones)
    self.mission_detection:update_missions(1)
    
    -- Update campaign metrics
    self:recalculate_threat()
    self:recalculate_panic()
    
    -- Update AI (alien director)
    self.alien_director:update(self.calendar)
    
    -- Notify UI to refresh
    self.ui:refresh_geoscape_display()
    
    print("[Campaign] Day complete")
end
```

**Tests:**
- Simulate 30 in-game days
- Verify missions spawn and expire
- Verify metrics update correctly
- Verify no state corruption

#### 4.2 Mission Selection & Deployment
**Objective:** Player interface to select and deploy to missions

**UI Flow:**
1. Player clicks province or mission list
2. Show available missions for that province
3. Player selects mission
4. Show mission briefing (objectives, rewards, difficulty, time limit)
5. Player clicks "Deploy" or "Decline"
6. If deploy: transition to battlescape with generated map
7. If decline: mission remains available (but timer continues)

**Implementation:**
- Create: `engine/ui/mission_briefing.lua`
- Modify: `engine/geoscape/geoscape_scene.lua` (mission interaction)

**Code:**
```lua
function GeoScapeScene:on_mission_selected(mission)
    -- Display briefing
    self.mission_briefing:show(mission)
end

function MissionBriefing:on_deploy_clicked(mission)
    print("[Mission] Deploying to: " .. mission.type)
    
    -- Validate deployment
    if not self:validate_deployment(mission) then
        return false
    end
    
    -- Mark mission as deployed
    mission.deployed = true
    
    -- Generate map for this mission
    local map = self.map_generator:generate(
        mission.biome,
        mission.type,
        mission.difficulty_scale
    )
    
    -- Transition to battlescape
    self.state_manager:transition("battlescape", {
        map = map,
        mission = mission,
        campaign = self.campaign_state,
    })
    
    return true
end
```

**Tests:**
- Test mission briefing display
- Test deploy validation
- Test transition to battlescape
- Test mission state updates

---

### 5. Alien Director Integration (10 hours)

#### 5.1 Threat Generation
**Objective:** Alien Director sets mission difficulty and frequency

**System:**
- Alien Director manages overall threat level
- Higher threat → more missions, harder enemies
- Difficulty scales with player progress
- Creates adaptive difficulty

**Implementation:**
- Reference: `docs/ai/` (strategic AI patterns)
- Create: `engine/ai/strategic/alien_director.lua` (if not exists)
- Modify: `engine/geoscape/mission_detection.lua` (use threat to adjust generation)

**Algorithm:**
```lua
function AlienDirector:calculate_threat_level(campaign)
    local base_threat = {
        easy = 0.2,
        normal = 0.4,
        hard = 0.6,
        ironman = 0.8,
    }[campaign.difficulty]
    
    -- Increase threat based on time
    local time_factor = (campaign.turn / 365) * 0.3  -- +30% per year
    
    -- Decrease threat if player is winning
    local performance_factor = campaign.missions_completed / math.max(1, campaign.missions_failed)
    if performance_factor > 2.0 then
        performance_factor = 0.7  -- Threat increases if player is winning
    else
        performance_factor = 1.2  -- Threat decreases if losing
    end
    
    return math.min(1.0, base_threat * (1 + time_factor) * performance_factor)
end

function AlienDirector:update(calendar, campaign)
    -- Recalculate threat each day
    local new_threat = self:calculate_threat_level(campaign)
    
    -- Smoothly transition to new threat level
    self.current_threat = self.current_threat * 0.9 + new_threat * 0.1
    
    -- Adjust mission generation rates
    self.mission_generation_rate = self.current_threat * 0.05  -- 0-5% per province
    
    print("[AlienDirector] Threat: " .. string.format("%.1f", self.current_threat * 100) .. "%")
end
```

**Tests:**
- Verify threat increases over time
- Verify threat responds to player performance
- Test difficulty scaling

---

## 🔄 Integration Points

### With Phase 1.1 (Geoscape Core)
- Uses: Hex world map, provinces, calendar
- Calls: Calendar advance triggers mission detection
- Provides: Active missions for UI display

### With Phase 1.2 (Map Generation)
- Calls: Map generator with mission params
- Receives: Generated tactical map
- Transitions: To battlescape with map

### With Battlescape
- Sends: Mission definition + generated map
- Receives: Battle results (victory/failure)
- Processes: Results and updates campaign state

---

## 📊 Testing Strategy

### Unit Tests
```lua
-- tests/geoscape/test_mission_detection.lua
function test_mission_spawn_probability()
    local detection = MissionDetection.new("normal")
    
    -- Simulate 1000 days in temperate province
    local spawn_count = 0
    local province = {biome="temperate"}
    
    for i=1,1000 do
        if math.random() < 0.035 * 1.0 then
            spawn_count = spawn_count + 1
        end
    end
    
    -- Should spawn ~35 missions (3.5%)
    assert(spawn_count > 30 and spawn_count < 40, "Spawn count: " .. spawn_count)
end

function test_mission_expiration()
    local mission = MissionFactory:create_mission(province, "site_investigation")
    assert(mission.time_remaining == 3)
    
    -- Simulate 4 days
    for i=1,4 do
        mission.time_remaining = mission.time_remaining - 1
    end
    
    assert(mission.time_remaining == -1, "Mission should expire")
end

-- tests/geoscape/test_campaign_state.lua
function test_mission_success_reward()
    local campaign = CampaignState.new()
    local initial_score = campaign.score
    
    local result = {
        victory = true,
        xp = 500,
        civilian_casualties = 0,
    }
    
    MissionCompletion:process_mission_result(mission, result)
    
    assert(campaign.score == initial_score + 500, "Score should increase")
    assert(campaign.missions_completed == 1, "Completed count should increase")
end
```

### Integration Tests
```lua
-- tests/integration/test_campaign_loop.lua
function test_full_campaign_cycle()
    local campaign = CampaignManager.new()
    
    -- Simulate 30 days
    for day=1,30 do
        campaign:advance_day()
        assert(campaign.calendar.turn == day, "Day " .. day)
    end
    
    -- Check that missions spawned
    assert(campaign:count_total_missions() > 0, "Missions should spawn")
    
    -- Check that some missions expired
    local active_count = campaign:count_active_missions()
    assert(active_count < campaign:count_total_missions(), "Some missions should expire")
end

function test_mission_deployment_to_battle()
    local campaign = CampaignManager.new()
    
    -- Find first available mission
    local mission = campaign:get_first_active_mission()
    assert(mission, "Should have at least one mission")
    
    -- Deploy to mission
    local battle_map = campaign:deploy_to_mission(mission)
    assert(battle_map, "Should generate map")
    assert(#battle_map.player_units > 0, "Map should have player units")
end
```

### Manual Testing
```
1. Run game: lovec "engine"
2. In Geoscape, click "Next Turn" repeatedly
3. Verify:
   - [ ] Calendar advances (date shows)
   - [ ] Missions appear in provinces
   - [ ] Mission list shows with details
   - [ ] Can click mission to see briefing
   - [ ] Can deploy to mission
   - [ ] Transitions to battlescape
   - [ ] Battlescape shows generated map
   - [ ] Units are positioned
   - [ ] Console shows no errors

4. Play ~5 turns and verify:
   - [ ] Variety in mission types
   - [ ] Missions disappear if time expires
   - [ ] Campaign score increases
   - [ ] Difficulty increases over time
```

---

## 📦 Deliverables

### Code Files
- `engine/geoscape/mission_detection.lua` - Daily mission spawning
- `engine/geoscape/mission_factory.lua` - Mission instance creation
- `engine/geoscape/campaign_manager.lua` - Campaign state management
- `engine/geoscape/mission_completion_system.lua` - Results processing
- `engine/geoscape/campaign_loop.lua` - Daily advancement orchestrator
- `engine/ui/mission_briefing.lua` - Mission UI display
- Modify: `engine/core/calendar.lua` (add daily callbacks)
- Modify: `engine/geoscape/geoscape_scene.lua` (mission interaction)

### Data Files
- `mods/core/data/mission_probabilities.toml` - Spawn chance settings
- `mods/core/data/mission_templates.toml` - Mission type definitions
- `mods/core/data/campaign_state.toml` - Initial campaign state
- `mods/core/data/mission_consequences.toml` - Result modifiers

### Tests
- `tests/geoscape/test_mission_detection.lua`
- `tests/geoscape/test_mission_factory.lua`
- `tests/geoscape/test_campaign_state.lua`
- `tests/geoscape/test_mission_completion.lua`
- `tests/geoscape/test_campaign_loop.lua`
- `tests/integration/test_campaign_full_cycle.lua`

### Documentation
- Create: `docs/geoscape/campaign_system.md` - Campaign mechanics
- Create: `docs/geoscape/mission_types.md` - Mission reference
- Update: `docs/API.md` - Add campaign API

---

## 🎬 How to Run & Debug

### Console Commands
```lua
-- Create mission immediately (bypass RNG)
campaign:add_mission_to_province(province, "site_investigation")

-- Simulate 7 days of campaign
for day=1,7 do
    campaign:advance_day()
end
print("Turn: " .. campaign.calendar.turn)
print("Score: " .. campaign.score)
print("Active missions: " .. campaign:count_active_missions())

-- Manually complete a mission
campaign:process_mission_result(mission, {victory=true, xp=500})
```

### Expected Output
```
[Campaign] Advancing to day 1
[Campaign] Advancing to day 2
[Mission] New mission in North America: Site Investigation
[Campaign] Day complete
[Campaign] Advancing to day 3
[Campaign] Day complete
...
[Campaign] Mission expired: Site Investigation
[Campaign] Day complete
```

---

## ✅ Success Criteria

### Functional
- [x] Missions spawn daily in provinces
- [x] Missions have time limits and expire
- [x] Player can view mission briefing
- [x] Player can deploy to mission
- [x] Mission completion updates campaign state
- [x] Campaign metrics tracked and display
- [x] No data corruption after many days

### Gameplay
- [x] Campaign feels dynamic (different missions each day)
- [x] Player has meaningful choices (which mission to tackle)
- [x] Results have consequences (success/failure matter)
- [x] Difficulty scales appropriately

### Performance
- [x] Daily advancement <100ms
- [x] Mission display refreshes smoothly
- [x] No memory leaks after 100+ days

### Code Quality
- [x] All functions documented
- [x] Follows code standards
- [x] Unit tests pass
- [x] No console errors

---

## 📈 Milestone Validation

**Milestone:** Complete strategic layer gameplay loop

**Verification:**
1. Start game in Geoscape
2. Advance several days (missions appear)
3. Deploy to mission
4. Complete battle in Battlescape
5. Return to Geoscape, see results applied
6. Repeat: mission detection, deployment, battle
7. Verify campaign progresses over time

**Estimated Completion:** 45 hours (2.8 days at 16 hours/day)

**Total Phase 1:** 185 hours (80 + 60 + 45)

---

**Status:** TODO - Depends on Phase 1.1 & 1.2  
**Next Phase:** Phase 2 (Basescape Management)  
**Completes:** Foundation Systems (Phase 1)

---

*Part of MASTER-IMPLEMENTATION-PLAN.md*  
*Created: October 15, 2025*  
*Phase 1 Week 3 Foundation Task*
*Final week of Foundation Systems, enables all subsequent phases*
