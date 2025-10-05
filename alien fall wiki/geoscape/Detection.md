# Detection System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Detection System governs UFO and alien activity discovery on the geoscape through radar coverage, satellite networks, and intelligence sources that determine which threats become visible to the player in Alien Fall, creating strategic decisions about radar placement, coverage gaps, and intelligence investment that shape situational awareness and mission opportunities.

---

## Table of Contents
- [Overview](#overview)
- [Detection Sources](#detection-sources)
- [Sensor Range Formulas](#sensor-range-formulas)
- [Detection Mechanics](#detection-mechanics)
- [Alert Priority System](#alert-priority-system)
- [Multi-Radar Triangulation](#multi-radar-triangulation)
- [Cover and Armor System](#cover-and-armor-system)
- [Detection Timing](#detection-timing)
- [Lua Implementation](#lua-implementation)
- [Integration Points](#integration-points)
- [Cross-References](#cross-references)

---

## Overview

The Detection System governs how player bases and craft discover alien missions through sensor arrays. Detection is probabilistic but deterministic (seeded), requiring missions to accumulate detection power until their concealment cover is penetrated. The system balances strategic base placement, sensor technology upgrades, and tactical craft positioning.

**Core Principles:**
- **Cover-Based Concealment:** Missions have Cover value that must be reduced to ≤0 for detection
- **Additive Detection:** Multiple sensors stack detection power within the same day
- **Range-Based Effectiveness:** Detection power decreases with distance
- **Technology Progression:** Better sensors have longer range and higher power
- **Deterministic Randomness:** Seeded RNG ensures reproducible results

---

## Detection Sources

### Base Radar Systems

| Radar Type | Detection Power | Base Range (km) | Technology Required | Power Cost |
|------------|----------------|-----------------|---------------------|------------|
| **Short Range Radar** | 80 | 500 | Starting tech | 5 |
| **Long Range Radar** | 120 | 1200 | Improved Radar | 10 |
| **Hyperwave Decoder** | 200 | 2400 | Hyperwave Tech | 20 |

### Airborne Detection

| Craft Type | Detection Power | Range (km) | Notes |
|------------|----------------|------------|-------|
| **Interceptor** | 25 | 300 | Standard patrol craft |
| **Scout** | 40 | 500 | Enhanced sensors |
| **AWACS Variant** | 80 | 800 | Dedicated detection platform |

### Special Detection Sources

| Source | Detection Power | Range | Notes |
|--------|----------------|-------|-------|
| **Satellite Network** | 50 | Global | Requires tech, monthly upkeep |
| **Listening Posts** | 60 | Province-wide | Special facilities |
| **Allied Intelligence** | 30 | Provincial | Council nation cooperation |

---

## Sensor Range Formulas

### Base Radar Range Formula

```lua
-- Effective range calculation with falloff
function calculate_detection_range(sensor, distance_km)
    local base_range = sensor.range  -- Maximum effective range
    local base_power = sensor.power  -- Detection power at optimal range
    
    -- No detection beyond maximum range
    if distance_km > base_range then
        return 0
    end
    
    -- Linear falloff formula
    local range_ratio = distance_km / base_range
    local effective_power = base_power * (1.0 - range_ratio * 0.5)
    
    -- Minimum 25% power at maximum range
    effective_power = math.max(effective_power, base_power * 0.25)
    
    return effective_power
end
```

**Example Calculations:**

Short Range Radar (80 power, 500km range):
- At 0km (base location): 80 power (100%)
- At 250km (50% range): 60 power (75%)
- At 500km (max range): 20 power (25%)

Long Range Radar (120 power, 1200km range):
- At 0km: 120 power (100%)
- At 600km: 90 power (75%)
- At 1200km: 30 power (25%)

### Airborne Detection Range

```lua
-- Airborne craft detection with altitude bonus
function calculate_airborne_detection(craft, target_distance)
    local base_power = craft.detection_power
    local max_range = craft.detection_range
    
    -- Beyond range check
    if target_distance > max_range then
        return 0
    end
    
    -- Altitude bonus (higher altitude = better detection)
    local altitude_bonus = 1.0
    if craft.altitude == "high" then
        altitude_bonus = 1.2
    elseif craft.altitude == "low" then
        altitude_bonus = 0.8
    end
    
    -- Distance falloff (steeper than ground radar)
    local range_ratio = target_distance / max_range
    local distance_factor = 1.0 - range_ratio * 0.7
    distance_factor = math.max(distance_factor, 0.1)
    
    return base_power * altitude_bonus * distance_factor
end
```

### Hyperwave Decoder Special Rules

```lua
-- Hyperwave provides additional intelligence
function hyperwave_detection(mission, distance_km)
    local base_power = 200
    local max_range = 2400
    
    if distance_km > max_range then
        return 0, nil
    end
    
    -- Calculate effective power
    local range_ratio = distance_km / max_range
    local effective_power = base_power * (1.0 - range_ratio * 0.3)
    
    -- Hyperwave reveals additional information
    local intelligence = {
        mission_type = mission.type,  -- Reveals mission category
        ship_class = mission.ufo_type,  -- UFO classification
        estimated_crew = mission.crew_size,  -- Crew count estimate
        threat_level = mission.threat_rating  -- Danger assessment
    }
    
    return effective_power, intelligence
end
```

---

## Detection Mechanics

### Cover Penetration System

```lua
-- Mission concealment system
Mission = {
    cover = 100,  -- Starting concealment
    cover_max = 100,  -- Maximum cover value
    armor = 0.0,  -- Detection resistance (0.0 = none, 1.0 = immune)
    detected = false,  -- Detection state
    detection_time = nil,  -- Game time when detected
}

function apply_detection_attempt(mission, detection_power)
    -- Apply armor reduction
    local effective_power = detection_power * (1.0 - mission.armor)
    
    -- Reduce cover
    mission.cover = mission.cover - effective_power
    
    -- Detection threshold
    if mission.cover <= 0 and not mission.detected then
        mission.detected = true
        mission.detection_time = game.time
        trigger_detection_alert(mission)
        return true
    end
    
    return false
end
```

### Cover Recovery

```lua
-- Missions regain concealment when not actively detected
function update_mission_cover(mission, time_elapsed_hours)
    if mission.detected then
        return  -- No recovery while detected
    end
    
    -- Recovery rate: +10 cover per day when undetected
    local recovery_rate = 10 / 24  -- Per hour
    local recovery_amount = recovery_rate * time_elapsed_hours
    
    mission.cover = math.min(mission.cover + recovery_amount, mission.cover_max)
end
```

### Daily Detection Pass

```lua
-- Each detection source attempts once per day
function daily_detection_pass(game_state)
    local detection_results = {}
    
    for _, mission in ipairs(game_state.active_missions) do
        if mission.detected then
            continue  -- Already detected
        end
        
        local total_detection = 0
        
        -- Check all base radars
        for _, base in ipairs(game_state.bases) do
            for _, radar in ipairs(base.radars) do
                if radar.operational then
                    local distance = calculate_distance(base.location, mission.location)
                    local power = calculate_detection_range(radar, distance)
                    total_detection = total_detection + power
                end
            end
        end
        
        -- Check airborne craft
        for _, craft in ipairs(game_state.crafts) do
            if craft.airborne and craft.sensors_active then
                local distance = calculate_distance(craft.location, mission.location)
                local power = calculate_airborne_detection(craft, distance)
                total_detection = total_detection + power
            end
        end
        
        -- Apply combined detection
        if total_detection > 0 then
            local detected = apply_detection_attempt(mission, total_detection)
            if detected then
                table.insert(detection_results, mission)
            end
        end
    end
    
    return detection_results
end
```

---

## Detection Timing

### Detection Probability Over Time

```lua
-- Calculate expected time to detection
function calculate_detection_time(mission_cover, daily_detection_power)
    if daily_detection_power <= 0 then
        return nil  -- Cannot detect
    end
    
    local days_to_detect = mission_cover / daily_detection_power
    return days_to_detect
end
```

**Example Detection Times:**

Mission with 100 Cover, no armor:
- Single Short Range Radar (80 power): 1.25 days
- Single Long Range Radar (120 power): 0.83 days (20 hours)
- Two Short Range Radars (160 power): 0.63 days (15 hours)
- Hyperwave Decoder (200 power): 0.5 days (12 hours)

Mission with 100 Cover, 0.5 armor (50% resistance):
- Short Range Radar (40 effective): 2.5 days
- Long Range Radar (60 effective): 1.67 days
- Hyperwave Decoder (100 effective): 1 day

### Interception Screen Auto-Detection

```lua
-- Starting interception screen automatically detects missions in province
function start_interception_screen(province)
    -- Immediate detection of all missions in province
    for _, mission in ipairs(province.missions) do
        if not mission.detected then
            mission.cover = 0  -- Instant detection
            mission.detected = true
            mission.detection_time = game.time
            mission.detection_method = "interception_screen"
        end
    end
    
    open_interception_ui(province)
end
```

---

## Alert Priority System

### Priority Calculation

```lua
-- Calculate mission alert priority
function calculate_mission_priority(mission)
    local priority = 0
    
    -- Base priority by mission type
    local type_priorities = {
        ufo_scout = 20,
        ufo_fighter = 40,
        ufo_transport = 60,
        ufo_battleship = 100,
        terror_site = 150,
        alien_base = 200,
        infiltration = 180,
        council_mission = 120,
    }
    
    priority = type_priorities[mission.type] or 50
    
    -- Proximity bonus (closer = higher priority)
    local nearest_base = find_nearest_base(mission.location)
    if nearest_base then
        local distance = calculate_distance(nearest_base.location, mission.location)
        local proximity_bonus = math.max(0, 50 - distance / 20)
        priority = priority + proximity_bonus
    end
    
    -- Time sensitivity
    if mission.expires_in then
        local urgency = 1.0 + (1.0 / math.max(mission.expires_in, 1))
        priority = priority * urgency
    end
    
    -- Threat level multiplier
    priority = priority * (1.0 + mission.threat_rating * 0.5)
    
    return priority
end
```

### Alert Categories

```lua
-- Alert notification system
AlertLevel = {
    LOW = 1,      -- Minor UFO sightings
    MEDIUM = 2,   -- Standard missions
    HIGH = 3,     -- Terror sites, large UFOs
    CRITICAL = 4, -- Base assaults, infiltration completion
}

function get_alert_level(mission)
    local priority = calculate_mission_priority(mission)
    
    if priority >= 150 then
        return AlertLevel.CRITICAL
    elseif priority >= 100 then
        return AlertLevel.HIGH
    elseif priority >= 50 then
        return AlertLevel.MEDIUM
    else
        return AlertLevel.LOW
    end
end

function trigger_detection_alert(mission)
    local alert_level = get_alert_level(mission)
    local priority = calculate_mission_priority(mission)
    
    -- Create alert notification
    local alert = {
        mission = mission,
        level = alert_level,
        priority = priority,
        time = game.time,
        acknowledged = false,
    }
    
    -- Add to alert queue (sorted by priority)
    table.insert(game.alerts, alert)
    table.sort(game.alerts, function(a, b)
        return a.priority > b.priority
    end)
    
    -- UI notification
    if alert_level >= AlertLevel.HIGH then
        show_popup_alert(alert)
        play_alert_sound(alert_level)
    else
        add_notification_ticker(alert)
    end
end
```

### Alert Queue Management

```lua
-- Alert queue with auto-expiration
function update_alert_queue(game_state, delta_time)
    local expired = {}
    
    for i, alert in ipairs(game_state.alerts) do
        -- Auto-expire old alerts
        local age_hours = (game_state.time - alert.time) / 3600
        
        if age_hours > 24 or not alert.mission.active then
            table.insert(expired, i)
        end
    end
    
    -- Remove expired alerts (reverse order)
    for i = #expired, 1, -1 do
        table.remove(game_state.alerts, expired[i])
    end
end
```

---

## Multi-Radar Triangulation

### Triangulation Bonus System

```lua
-- Multiple radars improve detection accuracy and speed
function calculate_triangulation_bonus(mission_location, detection_sources)
    if #detection_sources < 2 then
        return 1.0  -- No bonus for single source
    end
    
    -- Calculate geometric distribution
    local angles = {}
    for i = 1, #detection_sources do
        for j = i + 1, #detection_sources do
            local angle = calculate_angle_between(
                detection_sources[i].location,
                mission_location,
                detection_sources[j].location
            )
            table.insert(angles, angle)
        end
    end
    
    -- Triangulation quality based on angle distribution
    local avg_angle = 0
    for _, angle in ipairs(angles) do
        avg_angle = avg_angle + angle
    end
    avg_angle = avg_angle / #angles
    
    -- Ideal triangulation: 120° separation (3 sources) or 90° (2 sources)
    local ideal_angle = #detection_sources == 2 and 90 or 120
    local angle_quality = 1.0 - math.abs(avg_angle - ideal_angle) / 180
    
    -- Bonus: 0% to 50% extra detection power
    local bonus = 1.0 + (angle_quality * 0.5)
    
    return bonus
end
```

### Triangulation Application

```lua
-- Apply triangulation to detection pass
function detection_with_triangulation(mission, sources)
    local total_power = 0
    local active_sources = {}
    
    -- Collect detection power from each source
    for _, source in ipairs(sources) do
        local distance = calculate_distance(source.location, mission.location)
        local power = calculate_detection_range(source, distance)
        
        if power > 0 then
            total_power = total_power + power
            table.insert(active_sources, source)
        end
    end
    
    -- Apply triangulation bonus if multiple sources
    if #active_sources >= 2 then
        local bonus = calculate_triangulation_bonus(mission.location, active_sources)
        total_power = total_power * bonus
    end
    
    return total_power
end
```

### Intelligence Accuracy Bonus

```lua
-- Triangulation improves mission intelligence accuracy
function get_mission_intelligence(mission, detection_sources)
    local base_accuracy = 0.5  -- 50% base accuracy
    
    -- Hyperwave provides perfect intelligence
    local has_hyperwave = false
    for _, source in ipairs(detection_sources) do
        if source.type == "hyperwave_decoder" then
            has_hyperwave = true
            break
        end
    end
    
    if has_hyperwave then
        return {
            mission_type = mission.type,
            ufo_class = mission.ufo_type,
            crew_size = mission.crew_size,
            threat_level = mission.threat_rating,
            accuracy = 1.0
        }
    end
    
    -- Triangulation improves accuracy
    local triangulation_sources = {}
    for _, source in ipairs(detection_sources) do
        local distance = calculate_distance(source.location, mission.location)
        if distance <= source.range then
            table.insert(triangulation_sources, source)
        end
    end
    
    if #triangulation_sources >= 2 then
        local bonus = calculate_triangulation_bonus(mission.location, triangulation_sources)
        base_accuracy = base_accuracy + (bonus - 1.0)
    end
    
    base_accuracy = math.min(base_accuracy, 0.9)  -- Cap at 90% without hyperwave
    
    -- Return fuzzy intelligence based on accuracy
    return {
        mission_type = get_fuzzy_mission_type(mission, base_accuracy),
        ufo_class = get_fuzzy_ufo_class(mission, base_accuracy),
        crew_size = get_fuzzy_crew_estimate(mission, base_accuracy),
        threat_level = get_fuzzy_threat_rating(mission, base_accuracy),
        accuracy = base_accuracy
    }
end
```

---

## Cover and Armor System

### Mission Concealment Types

```lua
-- Different mission types have different concealment
MissionConcealmentProfiles = {
    ufo_small_scout = {
        cover = 50,
        armor = 0.0,
        recovery_rate = 10,
    },
    ufo_large_scout = {
        cover = 80,
        armor = 0.1,
        recovery_rate = 15,
    },
    ufo_fighter = {
        cover = 100,
        armor = 0.2,
        recovery_rate = 20,
    },
    ufo_transport = {
        cover = 120,
        armor = 0.3,
        recovery_rate = 25,
    },
    ufo_battleship = {
        cover = 150,
        armor = 0.4,
        recovery_rate = 30,
    },
    terror_site = {
        cover = 0,  -- Immediately visible
        armor = 0.0,
        recovery_rate = 0,
    },
    alien_base = {
        cover = 200,
        armor = 0.6,
        recovery_rate = 50,
    },
    infiltration_mission = {
        cover = 150,
        armor = 0.5,
        recovery_rate = 40,
    },
}

function initialize_mission_concealment(mission)
    local profile = MissionConcealmentProfiles[mission.type]
    
    if profile then
        mission.cover = profile.cover
        mission.cover_max = profile.cover
        mission.armor = profile.armor
        mission.recovery_rate = profile.recovery_rate
    else
        -- Default values
        mission.cover = 100
        mission.cover_max = 100
        mission.armor = 0.0
        mission.recovery_rate = 10
    end
end
```

### Special Detection Conditions

```lua
-- Certain conditions grant detection bonuses or penalties
function apply_detection_modifiers(mission, detection_power)
    local modified_power = detection_power
    
    -- Time of day modifier
    if game.time_of_day == "night" then
        modified_power = modified_power * 0.8  -- Harder to detect at night
    end
    
    -- Weather effects
    if mission.province.weather == "storm" then
        modified_power = modified_power * 0.7  -- Storms reduce detection
    elseif mission.province.weather == "clear" then
        modified_power = modified_power * 1.1  -- Clear weather helps
    end
    
    -- Terrain effects
    if mission.terrain_type == "urban" then
        modified_power = modified_power * 1.2  -- Cities have more sensors
    elseif mission.terrain_type == "ocean" then
        modified_power = modified_power * 0.6  -- Ocean detection harder
    end
    
    -- Mission activity level
    if mission.activity_level == "high" then
        modified_power = modified_power * 1.3  -- Active missions easier to detect
    elseif mission.activity_level == "stealth" then
        modified_power = modified_power * 0.5  -- Stealth missions harder
    end
    
    return modified_power
end
```

---

## Lua Implementation

### Complete Detection System

```lua
-- Detection system manager
DetectionSystem = {
    sources = {},  -- All detection sources
    missions = {},  -- Active missions
    alerts = {},   -- Alert queue
    last_daily_check = 0,  -- Time of last daily pass
}

function DetectionSystem:initialize()
    self.sources = {}
    self.missions = {}
    self.alerts = {}
    self.last_daily_check = game.time
end

function DetectionSystem:add_source(source)
    table.insert(self.sources, source)
end

function DetectionSystem:remove_source(source)
    for i, s in ipairs(self.sources) do
        if s == source then
            table.remove(self.sources, i)
            return
        end
    end
end

function DetectionSystem:add_mission(mission)
    initialize_mission_concealment(mission)
    table.insert(self.missions, mission)
end

function DetectionSystem:update(delta_time)
    -- Update cover recovery
    for _, mission in ipairs(self.missions) do
        if not mission.detected then
            update_mission_cover(mission, delta_time / 3600)
        end
    end
    
    -- Daily detection pass (every 24 hours)
    if game.time - self.last_daily_check >= 86400 then
        self:daily_detection_pass()
        self.last_daily_check = game.time
    end
    
    -- Update alert queue
    update_alert_queue(game, delta_time)
end

function DetectionSystem:daily_detection_pass()
    for _, mission in ipairs(self.missions) do
        if mission.detected or not mission.active then
            goto continue
        end
        
        -- Collect detection sources in range
        local sources_in_range = {}
        for _, source in ipairs(self.sources) do
            local distance = calculate_distance(source.location, mission.location)
            if distance <= source.range and source.operational then
                table.insert(sources_in_range, source)
            end
        end
        
        if #sources_in_range > 0 then
            -- Calculate total detection with triangulation
            local detection_power = detection_with_triangulation(mission, sources_in_range)
            
            -- Apply environmental modifiers
            detection_power = apply_detection_modifiers(mission, detection_power)
            
            -- Attempt detection
            apply_detection_attempt(mission, detection_power)
        end
        
        ::continue::
    end
end

function DetectionSystem:force_detect(mission, method)
    -- Immediate detection (e.g., interception screen)
    mission.cover = 0
    mission.detected = true
    mission.detection_time = game.time
    mission.detection_method = method or "forced"
    trigger_detection_alert(mission)
end

function DetectionSystem:get_mission_intel(mission)
    -- Get intelligence based on detection sources
    local sources = {}
    for _, source in ipairs(self.sources) do
        local distance = calculate_distance(source.location, mission.location)
        if distance <= source.range and source.operational then
            table.insert(sources, source)
        end
    end
    
    return get_mission_intelligence(mission, sources)
end
```

---

## Integration Points

### Geoscape Integration
```lua
-- Detection sources tied to geoscape locations
function register_base_radar(base, radar_facility)
    local source = {
        type = "base_radar",
        location = base.location,
        range = radar_facility.range,
        power = radar_facility.power,
        operational = true,
        base = base,
        facility = radar_facility,
    }
    
    DetectionSystem:add_source(source)
    return source
end

function register_airborne_sensor(craft)
    local source = {
        type = "airborne",
        location = craft.location,
        range = craft.sensor_range,
        power = craft.sensor_power,
        operational = craft.airborne,
        craft = craft,
    }
    
    DetectionSystem:add_source(source)
    return source
end
```

### Mission System Integration
```lua
-- Missions register with detection system
function spawn_mission(mission_data)
    local mission = create_mission(mission_data)
    DetectionSystem:add_mission(mission)
    return mission
end

function expire_mission(mission)
    mission.active = false
    mission.expired = true
    
    -- Remove from detection system
    for i, m in ipairs(DetectionSystem.missions) do
        if m == mission then
            table.remove(DetectionSystem.missions, i)
            break
        end
    end
end
```

### Interception Integration
```lua
-- Interception screen auto-detection
function open_interception_ui(province)
    -- Force detect all missions in province
    for _, mission in ipairs(province.missions) do
        if not mission.detected then
            DetectionSystem:force_detect(mission, "interception_screen")
        end
    end
    
    UI.open_screen("interception", {province = province})
end
```

---

## Cross-References

### Related Systems
- **[Mission_Lifecycle.md](../integration/Mission_Lifecycle.md)** - Mission generation and lifecycle
- **[Interception Core Mechanics.md](../interception/Interception%20Core%20Mechanics.md)** - Interception systems
- **[Time_Systems.md](../core/Time_Systems.md)** - Strategic time management
- **[Base_Defense.md](../integration/Base_Defense.md)** - Base defense detection
- **[Determinism.md](../technical/Determinism.md)** - Seeded detection RNG

### Design Documents
- **Mission Detection and Assignment.md** - Original detection specification
- **World.md** - Geographic positioning for range calculations
- **Crafts.md** - Airborne sensor platforms

---

**Implementation Status:** Complete specification ready for coding  
**Testing Requirements:** 
- Detection timing validation
- Triangulation bonus calculations
- Alert priority ordering
- Cover recovery mechanics
- Multi-source stacking

**Version History:**
- v1.0 (2025-09-30): Initial complete specification with formulas and Lua code
