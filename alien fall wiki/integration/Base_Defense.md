# Base Defense

## Table of Contents
- [Overview](#overview)
- [Defense Workflow](#defense-workflow)
- [Related Wiki Pages](#related-wiki-pages)

## Overview

The Base Defense integration document describes the complete workflow when alien forces attack a player base, coordinating facility damage, defender deployment, battlescape generation from base layout, and post-battle reconstruction through integrated systems spanning geoscape alerts, facility mechanics, unit deployment, and economy recovery.  
**Related Systems:** Geoscape Detection, Interception, Basescape, Battlescape

---

## Purpose

This document describes the **complete base defense system**, linking detection, interception, facility placement, and tactical defense. Understanding this flow is essential for defensive strategy and base vulnerability.

**Key Insight:** Base defense is a 4-stage process: Detection → Interception → Facility Defense → Battlescape Combat.

---

## Overview

### Four-Stage Defense

```
┌─────────────┐
│ DETECTION   │ ← Base sensors detect incoming threat
└──────┬──────┘
       │ Alert: Enemy approaching
       ↓
┌─────────────┐
│INTERCEPTION │ ← Launch crafts to intercept
└──────┬──────┘
       │ If interception fails...
       ↓
┌─────────────┐
│BASE DEFENSE │ ← Facility defenses engage
└──────┬──────┘
       │ If breach occurs...
       ↓
┌─────────────┐
│BATTLESCAPE  │ ← Ground combat in base
└─────────────┘
```

---

## Stage 1: Threat Detection

### Base Sensors

**Detection Range:**
```lua
function calculate_base_detection_range(base)
    local total_range = 0
    
    for _, facility in ipairs(base.facilities) do
        if facility.type == "radar" or facility.type == "hyperwave_decoder" then
            total_range = math.max(total_range, facility.detection_range * facility.efficiency)
        end
    end
    
    return total_range
end
```

**Sensor Types:**
```lua
sensor_types = {
    radar = {
        range = 500,      -- km
        detection_chance = 0.8,
        cost = 100000
    },
    hyperwave_decoder = {
        range = 1500,     -- km
        detection_chance = 0.95,
        cost = 500000,
        requires_research = "Hyperwave Decoder"
    }
}
```

### Incoming Threat Detection

**Threat Assessment:**
```lua
function check_base_threat(base, world)
    local detection_range = calculate_base_detection_range(base)
    
    for _, ufo in ipairs(world.ufos) do
        local distance = calculate_distance(base.location, ufo.location)
        
        if distance <= detection_range then
            -- Check if targeting this base
            if ufo.target and ufo.target.id == base.id then
                local time_to_arrival = distance / ufo.speed
                
                trigger_base_defense_alert(base, ufo, time_to_arrival)
            end
        end
    end
end
```

**Alert System:**
```lua
function trigger_base_defense_alert(base, ufo, eta)
    local alert = {
        type = "base_attack",
        priority = "critical",
        base = base,
        attacker = ufo,
        eta = world.current_time + eta,
        message = string.format("BASE UNDER ATTACK! %s approaching %s. ETA: %s",
            ufo.type, base.name, format_time(eta))
    }
    
    add_alert(world.alerts, alert)
    pause_game()
    play_alert_sound("critical")
    
    -- Auto-scramble ready crafts
    auto_scramble_defense(base, ufo)
end
```

---

## Stage 2: Interception Phase

### Scramble Defense Crafts

**Automatic Scramble:**
```lua
function auto_scramble_defense(base, incoming_ufo)
    local ready_crafts = get_ready_crafts(base)
    
    for _, craft in ipairs(ready_crafts) do
        if craft.status == "ready" then
            -- Create intercept mission
            local mission = {
                type = "base_defense_intercept",
                location = incoming_ufo.location,
                target = incoming_ufo,
                priority = "critical"
            }
            
            deploy_craft(craft, mission)
            log_event("Scrambling " .. craft.name .. " to defend " .. base.name)
        end
    end
    
    if #ready_crafts == 0 then
        show_warning("No crafts available to defend " .. base.name .. "!")
    end
end
```

**Manual Override:**
```lua
function manual_defense_assignment(base, incoming_ufo)
    -- Show UI for craft selection
    local ui_data = {
        base = base,
        threat = incoming_ufo,
        available_crafts = get_all_crafts(base),
        recommended_count = calculate_recommended_craft_count(incoming_ufo)
    }
    
    show_screen("base_defense_assignment", ui_data)
end
```

### Air Combat

**Interception Success:**
```lua
function on_base_defense_interception_victory(craft, ufo, base)
    ufo.state = "crashed"
    
    -- Base safe
    remove_alert_by_type(world.alerts, "base_attack", base)
    notify_player("Threat to " .. base.name .. " eliminated!")
    
    -- Create crash site mission
    local crash_mission = create_ufo_crash_mission(ufo.location)
    add_mission(world.missions, crash_mission)
end
```

**Interception Failure:**
```lua
function on_base_defense_interception_failure(craft, ufo, base)
    -- UFO proceeds to base
    notify_player("Interception failed! UFO approaching " .. base.name)
    
    -- Calculate time to base arrival
    local distance = calculate_distance(ufo.location, base.location)
    local eta = world.current_time + (distance / ufo.speed)
    
    update_alert(world.alerts, "base_attack", {
        phase = "facility_defense",
        eta = eta
    })
    
    -- Prepare facility defenses
    prepare_base_defenses(base, ufo, eta)
end
```

---

## Stage 3: Facility Defense

### Base Defense Facilities

**Defense Turrets:**
```lua
defense_facilities = {
    laser_defense = {
        damage = 50,
        range = 2000,  -- meters
        fire_rate = 2,  -- shots per round
        accuracy = 0.8,
        cost = 200000,
        power_consumption = 30
    },
    plasma_defense = {
        damage = 100,
        range = 3000,
        fire_rate = 1,
        accuracy = 0.9,
        cost = 500000,
        power_consumption = 50,
        requires_research = "Plasma Weapons"
    },
    missile_defense = {
        damage = 150,
        range = 5000,
        fire_rate = 0.5,
        accuracy = 0.95,
        cost = 800000,
        power_consumption = 40,
        requires_research = "Guided Missiles"
    }
}
```

**Facility Placement Strategy:**
```lua
-- Defense facilities should be placed:
-- 1. At base perimeter (first line of defense)
-- 2. Protecting critical facilities (Power, Command Center)
-- 3. Covering multiple approach vectors

optimal_defense_positions = {
    "Corners of base (maximum coverage)",
    "Adjacent to hangar (protect crafts)",
    "Near command center (protect core)",
    "At access lifts (chokepoints)"
}
```

### Defense Engagement

**Facility Defense Round:**
```lua
function execute_facility_defense_round(base, ufo)
    local defense_facilities = get_defense_facilities(base)
    local total_damage = 0
    
    for _, facility in ipairs(defense_facilities) do
        if facility.operational and facility.powered then
            -- Calculate hit chance
            local distance = calculate_ufo_distance_to_base(ufo, base)
            local hit_chance = facility.accuracy * (1 - distance / facility.range)
            
            for shot = 1, facility.fire_rate do
                if roll_chance(hit_chance) then
                    local damage = facility.damage
                    total_damage = total_damage + damage
                    
                    log_event(facility.name .. " hit UFO for " .. damage .. " damage")
                end
            end
        end
    end
    
    -- Apply damage to UFO
    ufo.health = ufo.health - total_damage
    
    if ufo.health <= 0 then
        on_ufo_destroyed_by_base_defense(base, ufo)
    else
        -- UFO continues approach
        on_ufo_survives_base_defense(base, ufo)
    end
end
```

**Defense Success:**
```lua
function on_ufo_destroyed_by_base_defense(base, ufo)
    ufo.state = "crashed"
    
    notify_player("UFO destroyed by base defenses at " .. base.name .. "!")
    remove_alert_by_type(world.alerts, "base_attack", base)
    
    -- Create nearby crash site
    local crash_location = base.location + random_offset(50)  -- 50km offset
    create_ufo_crash_mission(crash_location)
end
```

**Defense Breach:**
```lua
function on_ufo_survives_base_defense(base, ufo)
    -- UFO lands at base
    ufo.state = "landed"
    ufo.location = base.location
    
    notify_player("BASE BREACH! Alien ground assault imminent at " .. base.name)
    
    update_alert(world.alerts, "base_attack", {
        phase = "ground_assault",
        immediate = true
    })
    
    -- Force immediate battlescape
    initiate_base_defense_battlescape(base, ufo)
end
```

---

## Stage 4: Battlescape Combat

### Battle Map Generation

**Base Layout to Battlescape:**
```lua
function generate_base_defense_map(base)
    local map = create_empty_battle_map(32, 24)
    
    -- Convert facility layout to battle tiles
    for _, facility in ipairs(base.facilities) do
        local battle_tiles = facility_to_battle_tiles(facility)
        place_tiles_on_map(map, battle_tiles, facility.position)
    end
    
    -- Add access lift (entry point for aliens)
    place_access_lift(map, base.access_lift_position)
    
    -- Add corridors between facilities
    generate_base_corridors(map, base)
    
    return map
end
```

**Facility Conversion:**
```lua
function facility_to_battle_tiles(facility)
    local tiles = {}
    
    -- Each facility is 2×2 or larger
    local width = facility.size.width
    local height = facility.size.height
    
    for y = 1, height do
        for x = 1, width do
            local tile = {
                x = x,
                y = y,
                type = "floor",
                facility = facility.type,
                destructible = false
            }
            
            -- Add walls at perimeter
            if x == 1 or x == width or y == 1 or y == height then
                tile.type = "wall"
                tile.health = 200
                tile.destructible = true
            end
            
            -- Add facility-specific objects
            if facility.type == "power_generator" then
                if x == math.floor(width/2) and y == math.floor(height/2) then
                    tile.object = "generator"
                    tile.destructible = true
                    tile.health = 500
                end
            end
            
            table.insert(tiles, tile)
        end
    end
    
    return tiles
end
```

### Unit Deployment

**Player Deployment:**
```lua
function deploy_base_defenders(base, map)
    local defenders = {}
    
    -- Deploy soldiers from barracks
    local available_soldiers = get_base_soldiers(base)
    local spawn_points = find_spawn_points_in_base(map, "command_center")
    
    for i, soldier in ipairs(available_soldiers) do
        if i <= #spawn_points then
            local unit = create_battle_unit(soldier, spawn_points[i])
            table.insert(defenders, unit)
        end
    end
    
    -- Add base personnel as civilians (non-combatants)
    local personnel_spawns = find_spawn_points_in_base(map, "living_quarters")
    for i = 1, base.staff_count do
        if i <= #personnel_spawns then
            local civilian = create_civilian_unit(personnel_spawns[i])
            table.insert(defenders, civilian)
        end
    end
    
    return defenders
end
```

**Alien Deployment:**
```lua
function deploy_base_attackers(ufo, map)
    local attackers = {}
    
    -- Aliens spawn at access lift
    local spawn_points = find_spawn_points_in_base(map, "access_lift")
    
    -- Number of aliens based on UFO size
    local alien_count = calculate_alien_count(ufo.type)
    
    for i = 1, alien_count do
        if i <= #spawn_points then
            local alien_type = select_alien_type(ufo.threat_level)
            local alien = create_alien_unit(alien_type, spawn_points[i])
            table.insert(attackers, alien)
        end
    end
    
    return attackers
end
```

### Victory Conditions

**Player Victory:**
```lua
function on_base_defense_victory(battle, base)
    -- All aliens eliminated
    notify_player("Base defense successful! " .. base.name .. " is secure.")
    
    -- Calculate casualties
    local casualties = count_casualties(battle.player_units)
    local facility_damage = calculate_facility_damage(battle.map, base)
    
    -- Apply consequences
    for _, casualty in ipairs(casualties) do
        remove_soldier(base, casualty.soldier)
    end
    
    for facility_id, damage in pairs(facility_damage) do
        local facility = find_facility(base, facility_id)
        facility.health = facility.health - damage
        if facility.health <= 0 then
            destroy_facility(base, facility)
        end
    end
    
    -- Award experience
    for _, unit in ipairs(battle.player_units) do
        if unit.alive then
            award_experience(unit.soldier, 100)  -- Bonus XP for base defense
        end
    end
    
    remove_alert_by_type(world.alerts, "base_attack", base)
end
```

**Player Defeat:**
```lua
function on_base_defense_defeat(battle, base)
    -- All defenders eliminated
    notify_player("BASE LOST! " .. base.name .. " has been overrun by aliens!")
    
    -- Base is destroyed/captured
    base.status = "lost"
    base.operational = false
    
    -- All personnel killed
    for _, soldier in ipairs(base.soldiers) do
        remove_soldier(base, soldier)
    end
    
    -- Facilities destroyed
    for _, facility in ipairs(base.facilities) do
        facility.health = 0
        facility.operational = false
    end
    
    -- Can attempt recovery mission later
    create_base_recovery_mission(base)
    
    -- Severe strategic consequences
    lose_regional_support(base.region)
end
```

### Facility Destruction

**Critical Facility Loss:**
```lua
function on_facility_destroyed_in_combat(facility, base)
    facility.health = 0
    facility.operational = false
    
    -- Consequences based on facility type
    if facility.type == "power_generator" then
        -- Power loss affects all facilities
        disable_powered_facilities(base)
        show_alert("Power generator destroyed! Base systems offline!")
    elseif facility.type == "command_center" then
        -- Lose base coordination
        show_alert("Command center destroyed! Base coordination lost!")
        apply_penalty(base, "no_coordination")
    elseif facility.type == "hangar" then
        -- Destroy craft in hangar
        local craft = find_craft_in_hangar(base, facility)
        if craft then
            destroy_craft(craft)
        end
        show_alert("Hangar destroyed! Craft lost!")
    end
    
    -- Facility requires reconstruction
    facility.requires_rebuild = true
end
```

---

## Base Vulnerability

### Threat Assessment

**Base Attractiveness to Aliens:**
```lua
function calculate_base_threat_level(base)
    local threat = 0
    
    -- Factors that attract alien attention
    threat = threat + (base.radar_range / 100)  -- High-range radar = visible
    threat = threat + (#base.crafts * 10)       -- Active crafts = threat
    threat = threat + (base.successful_missions * 5)  -- Success attracts retaliation
    threat = threat + (base.alien_prisoners * 20)  -- Holding prisoners
    
    -- Factors that deter aliens
    threat = threat - (count_defense_facilities(base) * 10)  -- Strong defenses
    
    return math.max(0, threat)
end
```

**Alien Base Assault Trigger:**
```lua
function check_base_assault_trigger(world)
    for _, base in ipairs(world.bases) do
        local threat_level = calculate_base_threat_level(base)
        
        if threat_level > 100 then
            -- High chance of assault
            if roll_chance(0.1) then  -- 10% per day
                spawn_base_assault_ufo(world, base)
            end
        end
    end
end

function spawn_base_assault_ufo(world, target_base)
    local ufo = {
        type = "battleship",  -- Large assault craft
        health = 500,
        speed = 1500,
        target = target_base,
        mission_type = "base_assault",
        threat_level = 8
    }
    
    -- Spawn near base
    ufo.location = target_base.location + random_offset(1000)
    
    table.insert(world.ufos, ufo)
    log_event("Alien base assault force detected heading for " .. target_base.name)
end
```

---

## Defense Strategy

### Optimal Base Layout

**Defensive Positioning:**
```
┌─────────────────────┐
│ [D] [R] [R] [D]     │  D = Defense Turret
│                     │  R = Radar
│ [H] [C] [P] [H]     │  H = Hangar
│                     │  C = Command Center
│ [L] [B] [W] [S]     │  P = Power Generator
│                     │  L = Laboratory
│ [D] [A] [A] [D]     │  B = Barracks
└─────────────────────┘  W = Workshop
         ↑               S = Stores
    Access Lift          A = Access Lift
```

**Defense Priorities:**
1. **Perimeter Defense:** Place turrets at corners for maximum coverage
2. **Critical Facility Protection:** Defend Power, Command, Hangar
3. **Chokepoint Control:** Control access lifts and corridors
4. **Redundancy:** Multiple power generators and defense turrets

### Pre-Battle Preparation

**Readiness Checklist:**
```lua
base_defense_readiness = {
    defense_turrets = 4,        -- Minimum 4 turrets
    ready_crafts = 2,           -- At least 2 interceptors ready
    trained_soldiers = 8,       -- 8+ soldiers at base
    powered_defenses = true,    -- Power generators operational
    redundant_power = true,     -- Backup power available
    stored_ammo = 500,          -- Sufficient ammunition
    med_bay_operational = true  -- Medical facility for casualties
}
```

**Alert Levels:**
```lua
function set_base_alert_level(base, level)
    base.alert_level = level
    
    if level == "green" then
        -- Normal operations
    elseif level == "yellow" then
        -- Increased readiness
        ready_all_crafts(base)
        alert_soldiers(base)
    elseif level == "red" then
        -- Imminent threat
        ready_all_crafts(base)
        deploy_soldiers_to_positions(base)
        charge_defense_turrets(base)
    end
end
```

---

## Cross-References

**Related Systems:**
- [Detection System](../geoscape/Detection.md) - Sensor mechanics
- [Interception](../interception/Air_Battle.md) - Air combat
- [Basescape](../basescape/README.md) - Base facilities and layout
- [Battlescape](../battlescape/README.md) - Ground combat
- [Mission Lifecycle](Mission_Lifecycle.md) - Mission resolution
- [Craft Lifecycle](Craft_Lifecycle.md) - Craft deployment

**Implementation Files:**
- `src/basescape/base_defense.lua` - Base defense system
- `src/geoscape/threat_detection.lua` - Incoming threat detection
- `src/basescape/facility_defenses.lua` - Turret systems
- `src/battlescape/base_defense_map.lua` - Base layout to battlescape conversion

---

## Version History

- **v1.0 (2025-09-30):** Initial integration document defining complete base defense system
