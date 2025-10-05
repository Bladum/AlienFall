# Mission Lifecycle

## Table of Contents
- [Overview](#overview)
- [Lifecycle Phases](#lifecycle-phases)
- [Related Wiki Pages](#related-wiki-pages)

## Overview

The Mission Lifecycle integration document describes the complete workflow from mission generation through deployment, tactical resolution, and post-mission processing in Alien Fall, coordinating interactions between geoscape detection, interception mechanics, battlescape combat, and economy systems.  
**Related Systems:** Geoscape, Detection, Interception, Battlescape, AI

---

## Purpose

This document describes the **complete lifecycle** of a mission in AlienFall, from initial detection through resolution. Understanding this flow is essential for game design, AI behavior, and player decision-making.

**Key Insight:** Missions follow a deterministic 5-phase lifecycle: Detection → Generation → Travel → Interception → Battlescape Resolution.

---

## Lifecycle Overview

### Five-Phase Process

```
┌─────────────┐
│ DETECTION   │ ← Geoscape sensors detect alien activity
└──────┬──────┘
       │ Alert generated
       ↓
┌─────────────┐
│ GENERATION  │ ← Mission parameters created
└──────┬──────┘
       │ Mission spawned
       ↓
┌─────────────┐
│   TRAVEL    │ ← Player craft en route
└──────┬──────┘
       │ Arrival/Interception
       ↓
┌─────────────┐
│INTERCEPTION │ ← Optional air combat (UFO missions)
└──────┬──────┘
       │ Ground phase
       ↓
┌─────────────┐
│BATTLESCAPE  │ ← Tactical ground combat
└─────────────┘
```

### Phase Summary

| Phase | Duration | Player Control | Outcome |
|-------|----------|----------------|---------|
| **Detection** | Instant | None (automatic) | Alert notification |
| **Generation** | Instant | None (automatic) | Mission created |
| **Travel** | Minutes to hours | Craft assignment | Arrival or timeout |
| **Interception** | 30-second rounds | Tactical commands | Victory, retreat, or defeat |
| **Battlescape** | 6-second turns | Full tactical control | Victory, retreat, or defeat |

---

## Phase 1: Detection

### Detection Triggers

**Sensor System:**
```lua
function check_detection(world, time_tick)
    for _, base in ipairs(world.bases) do
        for _, sensor in ipairs(base.sensors) do
            local detection_range = sensor.range * sensor.efficiency
            
            -- Check for alien activity in range
            for _, alien_object in ipairs(world.alien_objects) do
                local distance = calculate_distance(base.location, alien_object.location)
                
                if distance <= detection_range then
                    local detection_chance = calculate_detection_chance(sensor, alien_object, distance)
                    
                    if roll_detection(detection_chance) then
                        trigger_detection(alien_object, base, time_tick)
                    end
                end
            end
        end
    end
end
```

**Detection Chance Formula:**
```
Detection Chance = Base_Chance × (1 - Distance / Max_Range) × Stealth_Modifier

Where:
- Base_Chance = 0.8 (80% at point-blank range)
- Distance = kilometers between sensor and target
- Max_Range = sensor detection range
- Stealth_Modifier = 1.0 / target.stealth_rating
```

**Example:**
```
Radar: 500km range, efficiency 1.0
UFO: 300km away, stealth 0.8

Detection Chance = 0.8 × (1 - 300/500) × (1.0/0.8)
                 = 0.8 × 0.4 × 1.25
                 = 0.4 (40% chance per tick)
```

### Detection Events

**Alien Object Types:**
- **UFO (In Flight):** Moving alien craft
- **Landed UFO:** Stationary alien craft on ground
- **Alien Base:** Permanent alien installation
- **Terror Site:** Ongoing alien attack on civilians
- **Alien Activity:** Generic alien presence

**Detection Data:**
```lua
detection_event = {
    timestamp = world.current_time,
    detector_base = base,
    object_type = "ufo_small_scout",
    location = {x = 145, y = 67},
    estimated_size = "small",
    threat_level = "low",
    confidence = 0.75  -- 75% confidence in detection
}
```

### Alert System

**Player Notification:**
```lua
function trigger_detection(alien_object, detecting_base, time_tick)
    local alert = {
        type = "alien_detection",
        priority = calculate_priority(alien_object),
        message = string.format("Alien activity detected: %s near %s", 
            alien_object.type, detecting_base.name),
        location = alien_object.location,
        object = alien_object,
        time = time_tick,
        acknowledged = false
    }
    
    add_alert(world.alerts, alert)
    play_alert_sound(alert.priority)
    
    -- Auto-pause if high priority
    if alert.priority == "high" then
        pause_game()
    end
end
```

**Alert Priorities:**
- **Critical:** Base under attack, terror mission in progress
- **High:** UFO detected, alien base discovered
- **Medium:** Landed UFO, alien activity
- **Low:** Distant UFO, low-threat contact

### Output

```lua
phase1_output = {
    detection_event = detection_event,
    alert = alert,
    mission_candidate = true  -- Proceed to generation
}
```

---

## Phase 2: Mission Generation

### Mission Type Determination

**Type Selection Logic:**
```lua
function determine_mission_type(alien_object)
    if alien_object.type == "ufo" then
        if alien_object.state == "landed" then
            return "ufo_landing"
        else
            return "ufo_intercept"  -- Requires interception first
        end
    elseif alien_object.type == "terror_site" then
        return "terror_mission"
    elseif alien_object.type == "alien_base" then
        return "alien_base_assault"
    elseif alien_object.type == "supply_ship" then
        return "supply_raid"
    else
        return "investigation"
    end
end
```

**Mission Types:**
- **UFO Intercept:** Chase and shoot down flying UFO
- **UFO Landing:** Assault landed UFO before takeoff
- **UFO Crash:** Investigate crash site after shootdown
- **Terror Mission:** Stop alien attack on civilians
- **Alien Base Assault:** Destroy permanent alien base
- **Supply Raid:** Intercept alien supply operation
- **Investigation:** Explore alien activity site

### Mission Parameters

**Core Parameters:**
```lua
mission = {
    id = generate_mission_id(),
    type = mission_type,
    seed = derive_seed(campaign_seed, hash("mission:" .. mission_id)),
    location = alien_object.location,
    province = get_province_at_location(world, location.x, location.y),
    threat_level = alien_object.threat_level,
    time_limit = calculate_time_limit(mission_type),
    expiration = world.current_time + time_limit,
    state = "pending",
    alien_forces = nil,  -- Generated lazily on mission start
    rewards = nil        -- Calculated on completion
}
```

**Time Limits:**
```lua
time_limits = {
    ufo_intercept = nil,        -- No limit (UFO may flee)
    ufo_landing = 2,            -- 2 hours before takeoff
    ufo_crash = 24,             -- 24 hours before cleanup
    terror_mission = 4,         -- 4 hours before civilians massacred
    alien_base_assault = nil,   -- No limit (permanent)
    supply_raid = 6,            -- 6 hours before operation complete
    investigation = 12          -- 12 hours before trail goes cold
}
```

### Enemy Force Generation

**Force Composition (Lazy Generation):**
```lua
function generate_enemy_forces(mission)
    local enemy_seed = derive_seed(mission.seed, hash("enemies"))
    local rng = love.math.newRandomGenerator(enemy_seed)
    
    local threat_multiplier = mission.threat_level  -- 1-10 scale
    local base_count = 4 + rng:random(0, 2)  -- 4-6 aliens
    local total_count = math.floor(base_count * threat_multiplier)
    
    local forces = {}
    for i = 1, total_count do
        local alien_type = select_alien_type(mission.type, threat_multiplier, rng)
        table.insert(forces, create_alien(alien_type, enemy_seed + i))
    end
    
    mission.alien_forces = forces
end
```

**Alien Type Selection:**
```lua
function select_alien_type(mission_type, threat_level, rng)
    local pool = {
        {type = "sectoid", weight = 10, min_threat = 1},
        {type = "floater", weight = 8, min_threat = 2},
        {type = "snakeman", weight = 6, min_threat = 3},
        {type = "muton", weight = 4, min_threat = 5},
        {type = "chryssalid", weight = 3, min_threat = 6},
        {type = "ethereal", weight = 2, min_threat = 8}
    }
    
    -- Filter by threat level
    local valid_types = {}
    for _, entry in ipairs(pool) do
        if threat_level >= entry.min_threat then
            table.insert(valid_types, entry)
        end
    end
    
    -- Weighted random selection
    return weighted_random(valid_types, rng)
end
```

### Output

```lua
phase2_output = {
    mission = mission,
    alert_updated = true,
    awaiting_player_response = true
}
```

---

## Phase 3: Travel

### Craft Assignment

**Player Decision:**
```lua
function assign_craft_to_mission(mission, craft)
    mission.assigned_craft = craft
    mission.state = "traveling"
    
    craft.status = "en_route"
    craft.destination = mission.location
    craft.mission = mission
    
    -- Calculate travel time
    local distance = calculate_distance(craft.location, mission.location)
    local travel_time = distance / craft.speed
    mission.eta = world.current_time + travel_time
    
    log_event("Craft " .. craft.name .. " assigned to " .. mission.type)
end
```

**Travel Simulation:**
```lua
function update_travel(craft, dt)
    if craft.status ~= "en_route" then return end
    
    -- Move craft toward destination
    local distance_remaining = calculate_distance(craft.location, craft.destination)
    local distance_traveled = craft.speed * dt
    
    if distance_traveled >= distance_remaining then
        -- Arrival
        craft.location = craft.destination
        craft.status = "arrived"
        on_craft_arrival(craft, craft.mission)
    else
        -- Update position
        local direction = normalize(craft.destination - craft.location)
        craft.location = craft.location + direction * distance_traveled
    end
end
```

### Mission State Changes During Travel

**UFO State Changes:**
```lua
function update_mission_during_travel(mission, dt)
    if mission.type == "ufo_landing" then
        -- UFO may take off before arrival
        if world.current_time > mission.expiration then
            mission.state = "expired"
            notify_player("UFO has departed before interception")
            return_craft_to_base(mission.assigned_craft)
        end
    elseif mission.type == "ufo_intercept" then
        -- UFO may land during chase
        if check_ufo_landing_chance(mission.object, dt) then
            mission.type = "ufo_landing"
            mission.expiration = world.current_time + 2  -- 2 hour window
            notify_player("UFO has landed - ground assault possible")
        end
    end
end
```

**Player Recall:**
```lua
function recall_craft(craft)
    if craft.status == "en_route" then
        craft.status = "returning"
        craft.destination = craft.home_base.location
        craft.mission.state = "aborted"
        craft.mission = nil
    end
end
```

### Output

```lua
phase3_output = {
    craft_location = craft.location,
    eta = mission.eta,
    mission_state = "traveling",
    can_abort = true
}
```

---

## Phase 4: Interception

### Interception Trigger

**Arrival Conditions:**
```lua
function on_craft_arrival(craft, mission)
    if mission.type == "ufo_intercept" or 
       (mission.type == "ufo_landing" and mission.object.state == "flying") then
        -- Start air combat
        start_interception(craft, mission.object)
    else
        -- Skip to ground phase
        start_battlescape(craft, mission)
    end
end
```

**Interception Setup:**
```lua
function start_interception(player_craft, ufo)
    local interception = {
        player_craft = player_craft,
        enemy_craft = ufo,
        round = 0,
        distance = 1000,  -- meters, initial engagement range
        player_ap = 4,
        enemy_ap = 4,
        state = "active"
    }
    
    change_screen("interception", interception)
end
```

### Air Combat Resolution

**Round Structure:**
```lua
function process_interception_round(interception)
    interception.round = interception.round + 1
    
    -- Player phase
    interception.player_ap = 4
    while interception.player_ap > 0 and interception.state == "active" do
        local action = await_player_action(interception)
        execute_interception_action(interception, "player", action)
    end
    
    -- Enemy phase
    if interception.state == "active" then
        interception.enemy_ap = 4
        while interception.enemy_ap > 0 and interception.state == "active" do
            local action = ai_select_interception_action(interception)
            execute_interception_action(interception, "enemy", action)
        end
    end
    
    -- Check end conditions
    check_interception_end(interception)
end
```

**Combat Actions:**
```lua
interception_actions = {
    fire_weapon = {ap_cost = 2, effect = "damage"},
    move_closer = {ap_cost = 1, effect = "reduce_distance"},
    move_away = {ap_cost = 1, effect = "increase_distance"},
    evade = {ap_cost = 1, effect = "defense_bonus"},
    disengage = {ap_cost = 4, effect = "end_combat"}
}
```

### Interception Outcomes

**Victory:**
```lua
function on_interception_victory(interception, mission)
    local ufo = interception.enemy_craft
    
    if ufo.health <= 0 then
        -- UFO destroyed
        ufo.state = "crashed"
        mission.type = "ufo_crash"
        mission.location = ufo.location
        mission.expiration = world.current_time + 24  -- 24 hour window
        
        notify_player("UFO shot down! Crash site located.")
        
        -- Option to land for ground assault
        prompt_ground_mission(interception.player_craft, mission)
    end
end
```

**Defeat:**
```lua
function on_interception_defeat(interception, mission)
    local craft = interception.player_craft
    
    if craft.health <= 0 then
        craft.state = "destroyed"
        mission.state = "failed"
        
        notify_player("Craft destroyed in combat!")
        remove_craft(craft)
    end
end
```

**Disengagement:**
```lua
function on_interception_disengage(interception, mission)
    local craft = interception.player_craft
    
    craft.status = "returning"
    craft.destination = craft.home_base.location
    mission.state = "aborted"
    
    notify_player("Craft returning to base.")
end
```

### Output

```lua
phase4_output = {
    interception_result = "victory" | "defeat" | "disengage",
    craft_damage = craft.max_health - craft.health,
    ufo_state = ufo.state,
    proceed_to_ground = true | false
}
```

---

## Phase 5: Battlescape Resolution

### Ground Mission Start

**Transition to Tactical:**
```lua
function start_battlescape(craft, mission)
    -- Lazy-generate mission map if not already done
    if not mission.map then
        mission.map = generate_mission_map(world, mission)
        generate_enemy_forces(mission)
    end
    
    -- Create battle state
    local battle = {
        mission = mission,
        map = mission.map,
        turn = 0,
        player_units = deploy_player_units(craft, mission.map.spawns),
        enemy_units = deploy_enemy_units(mission.alien_forces, mission.map.enemy_spawns),
        civilians = deploy_civilians(mission),
        active_faction = "player",
        state = "active"
    }
    
    change_screen("battlescape", battle)
end
```

**Unit Deployment:**
```lua
function deploy_player_units(craft, spawn_zone)
    local units = {}
    for i, soldier in ipairs(craft.squad) do
        local spawn_pos = spawn_zone[i]
        local unit = create_battle_unit(soldier, spawn_pos)
        table.insert(units, unit)
    end
    return units
end
```

### Turn-Based Combat

**Turn Structure:**
```lua
function process_battle_turn(battle)
    battle.turn = battle.turn + 1
    
    if battle.active_faction == "player" then
        -- Player turn
        for _, unit in ipairs(battle.player_units) do
            if unit.alive then
                unit.ap = 4
                unit.energy_regen = calculate_energy_regen(unit)
                unit.energy = math.min(100, unit.energy + unit.energy_regen)
            end
        end
        
        -- Wait for player to end turn
        await_player_end_turn(battle)
        
        battle.active_faction = "alien"
    else
        -- Alien turn
        for _, unit in ipairs(battle.enemy_units) do
            if unit.alive then
                unit.ap = 4
                ai_execute_unit_turn(battle, unit)
            end
        end
        
        battle.active_faction = "player"
    end
    
    -- Check victory conditions
    check_battle_end(battle)
end
```

**Victory Conditions:**
```lua
function check_battle_end(battle)
    local player_alive = count_alive(battle.player_units)
    local enemy_alive = count_alive(battle.enemy_units)
    
    if enemy_alive == 0 then
        battle.state = "victory"
        on_battle_victory(battle)
    elseif player_alive == 0 then
        battle.state = "defeat"
        on_battle_defeat(battle)
    elseif battle.turn >= 50 then  -- Turn limit
        battle.state = "timeout"
        on_battle_timeout(battle)
    end
end
```

### Battle Outcomes

**Victory:**
```lua
function on_battle_victory(battle)
    local mission = battle.mission
    
    -- Calculate rewards
    local rewards = {
        money = calculate_mission_reward(mission),
        items = collect_battlefield_loot(battle),
        research = unlock_research_from_corpses(battle.enemy_units),
        experience = award_experience(battle.player_units)
    }
    
    mission.state = "completed"
    mission.result = "victory"
    mission.rewards = rewards
    
    apply_rewards(world, rewards)
    
    -- Return craft to base
    return_craft_to_base(mission.assigned_craft)
    
    show_mission_debrief(mission, rewards)
end
```

**Defeat:**
```lua
function on_battle_defeat(battle)
    local mission = battle.mission
    
    mission.state = "completed"
    mission.result = "defeat"
    
    -- Lost soldiers are permanently dead
    for _, unit in ipairs(battle.player_units) do
        if not unit.alive then
            remove_soldier(unit.soldier)
        end
    end
    
    -- Craft may be lost
    if battle.craft_destroyed then
        remove_craft(mission.assigned_craft)
    else
        return_craft_to_base(mission.assigned_craft)
    end
    
    show_mission_debrief(mission, nil)
end
```

**Player Retreat:**
```lua
function retreat_from_battle(battle)
    -- Must have at least one unit at evac zone
    local units_at_evac = count_units_at_zone(battle.player_units, battle.map.evac_zone)
    
    if units_at_evac > 0 then
        battle.state = "retreat"
        
        -- Only evacuated units survive
        for _, unit in ipairs(battle.player_units) do
            if not is_in_zone(unit, battle.map.evac_zone) then
                unit.alive = false
                remove_soldier(unit.soldier)
            end
        end
        
        return_craft_to_base(battle.mission.assigned_craft)
        show_mission_debrief(battle.mission, nil)
    end
end
```

### Output

```lua
phase5_output = {
    battle_result = "victory" | "defeat" | "retreat",
    casualties = killed_soldiers,
    rewards = rewards,
    mission_complete = true
}
```

---

## Mission State Machine

### State Diagram

```
        [PENDING]
            |
        Detection
            |
            v
      [GENERATED]
            |
      Craft Assigned
            |
            v
      [TRAVELING]
            |
      +-----+-----+
      |     |     |
   Arrive Abort Expire
      |     |     |
      v     v     v
  [ACTIVE][ABORTED][EXPIRED]
      |
  Interception?
      |
   +--+--+
   |     |
  Yes    No
   |     |
   v     v
[INTERCEPT][GROUND]
   |          |
Resolution Resolution
   |          |
   +----+-----+
        |
        v
   [COMPLETED]
```

### State Transitions

**State Definitions:**
```lua
mission_states = {
    "pending",      -- Detected, not yet generated
    "generated",    -- Mission created, awaiting assignment
    "traveling",    -- Craft en route
    "active",       -- Combat in progress
    "intercepting", -- Air combat phase
    "ground",       -- Tactical ground combat
    "completed",    -- Mission resolved
    "aborted",      -- Player withdrew
    "expired"       -- Time limit exceeded
}
```

**Transition Rules:**
```lua
function transition_mission_state(mission, new_state)
    local valid_transitions = {
        pending = {"generated"},
        generated = {"traveling", "expired"},
        traveling = {"active", "aborted", "expired"},
        active = {"intercepting", "ground"},
        intercepting = {"ground", "aborted", "completed"},
        ground = {"completed", "aborted"},
        completed = {},  -- Terminal state
        aborted = {},    -- Terminal state
        expired = {}     -- Terminal state
    }
    
    if contains(valid_transitions[mission.state], new_state) then
        mission.state = new_state
        on_mission_state_change(mission, new_state)
    else
        error("Invalid mission state transition: " .. mission.state .. " -> " .. new_state)
    end
end
```

---

## Time Management

### Time Pressure

**Active Timers:**
```lua
function update_mission_timers(world, dt)
    for _, mission in ipairs(world.active_missions) do
        if mission.expiration then
            if world.current_time >= mission.expiration then
                expire_mission(mission)
            else
                -- Warn player if running out of time
                local time_remaining = mission.expiration - world.current_time
                if time_remaining <= 1 then  -- Less than 1 hour
                    show_urgent_warning(mission)
                end
            end
        end
    end
end
```

**Time Conversion:**
```
Geoscape time: 5-minute ticks
Travel time: Real-time simulation (minutes to hours)
Interception: 30-second rounds
Battlescape: 6-second turns
```

---

## Mission Rewards

### Reward Calculation

**Base Rewards:**
```lua
function calculate_mission_reward(mission)
    local base_rewards = {
        terror_mission = 50000,
        ufo_crash = 30000,
        ufo_landing = 40000,
        alien_base_assault = 100000,
        supply_raid = 35000
    }
    
    local base = base_rewards[mission.type] or 20000
    local threat_multiplier = 1 + (mission.threat_level * 0.1)
    local speed_bonus = calculate_speed_bonus(mission)
    
    return base * threat_multiplier * speed_bonus
end
```

**Speed Bonus:**
```lua
function calculate_speed_bonus(mission)
    local time_taken = mission.completion_time - mission.generated_time
    local time_limit = mission.expiration - mission.generated_time
    
    if time_taken <= time_limit * 0.5 then
        return 1.5  -- 50% bonus for completing in first half
    elseif time_taken <= time_limit * 0.75 then
        return 1.2  -- 20% bonus
    else
        return 1.0  -- No bonus
    end
end
```

**Loot Collection:**
```lua
function collect_battlefield_loot(battle)
    local loot = {
        weapons = {},
        corpses = {},
        artifacts = {},
        materials = {}
    }
    
    -- Collect from dead aliens
    for _, alien in ipairs(battle.enemy_units) do
        if not alien.alive then
            table.insert(loot.corpses, alien.corpse_item)
            if alien.weapon then
                table.insert(loot.weapons, alien.weapon)
            end
        end
    end
    
    -- Collect from map objects
    for _, obj in ipairs(battle.map.loot_objects) do
        if obj.collected then
            table.insert(loot.artifacts, obj.item)
        end
    end
    
    return loot
end
```

---

## AI Behavior During Lifecycle

### Strategic AI Decisions

**UFO Behavior:**
```lua
function update_ufo_ai(ufo, world, dt)
    if ufo.state == "flying" then
        -- Check if should land
        if should_ufo_land(ufo, world) then
            land_ufo(ufo, world)
        end
        
        -- Check if should flee
        if is_threatened(ufo, world) and should_flee(ufo) then
            flee_to_hyperspace(ufo)
        end
        
        -- Normal patrol/mission behavior
        execute_ufo_mission(ufo, world, dt)
    elseif ufo.state == "landed" then
        -- Check if should take off
        if should_ufo_takeoff(ufo, world) then
            takeoff_ufo(ufo)
        end
    end
end
```

**Tactical AI:**
```lua
function ai_execute_unit_turn(battle, unit)
    local action_seed = derive_seed(battle.mission.seed, battle.turn * 1000 + unit.id)
    local rng = love.math.newRandomGenerator(action_seed)
    
    while unit.ap > 0 do
        -- Evaluate tactical situation
        local visible_enemies = get_visible_units(battle, unit, "player")
        
        if #visible_enemies > 0 then
            -- Combat behavior
            local action = select_combat_action(unit, visible_enemies, rng)
            execute_action(battle, unit, action)
        else
            -- Patrol/search behavior
            local action = select_patrol_action(unit, battle, rng)
            execute_action(battle, unit, action)
        end
    end
end
```

---

## Cross-References

**Related Systems:**
- [Detection System](../geoscape/Detection.md) - Sensor mechanics and detection formulas
- [Interception](../interception/Air_Battle.md) - Air combat mechanics
- [Battlescape](../battlescape/README.md) - Ground combat system
- [Time Systems](../core/Time_Systems.md) - Time scale conversions
- [Map Generation Pipeline](Map_Generation_Pipeline.md) - Battle map creation
- [AI System](../ai/README.md) - AI decision-making algorithms

**Implementation Files:**
- `src/systems/mission_manager.lua` - Mission lifecycle orchestration
- `src/geoscape/detection_system.lua` - Detection and alert generation
- `src/interception/air_combat.lua` - Interception phase
- `src/battlescape/battle_manager.lua` - Ground combat management
- `src/ai/strategic_ai.lua` - UFO behavior and mission AI

---

## Version History

- **v1.0 (2025-09-30):** Initial integration document defining complete mission lifecycle
