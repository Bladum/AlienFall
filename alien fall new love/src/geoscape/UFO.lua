--- UFO.lua
-- UFO entity for Alien Fall
-- Represents alien spacecraft on the geoscape

-- GROK: UFO represents alien spacecraft with movement, detection, and interception mechanics
-- GROK: Tracks position, speed, destination, mission type, and detection status
-- GROK: Key methods: update(), setDestination(), isDetected(), intercept()
-- GROK: Supports mission types: scout, abduction, terror, infiltration, supply

local class = require 'lib.Middleclass'

UFO = class('UFO')

--- UFO mission types
UFO.MissionType = {
    SCOUT = "scout",
    ABDUCTION = "abduction",
    TERROR = "terror",
    INFILTRATION = "infiltration",
    SUPPLY = "supply",
    BATTLESHIP = "battleship"
}

--- UFO states
UFO.State = {
    FLYING = "flying",
    LANDED = "landed",
    CRASHED = "crashed",
    DESTROYED = "destroyed",
    RETREATING = "retreating"
}

--- UFO sizes
UFO.Size = {
    SMALL = "small",        -- Scout, very fast
    MEDIUM = "medium",      -- Fighter, balanced
    LARGE = "large",        -- Abductor, slower
    VERY_LARGE = "very_large"  -- Battleship, slowest
}

--- Initialize a new UFO
-- @param data The UFO data
function UFO:initialize(data)
    self.id = data.id or ("ufo_" .. tostring(math.random(100000, 999999)))
    self.type = data.type or UFO.MissionType.SCOUT
    self.size = data.size or UFO.Size.SMALL
    
    -- Position and movement
    self.world_id = data.world_id
    self.coordinates = data.coordinates or {0, 0}  -- {x, y}
    self.altitude = data.altitude or 10000  -- meters
    self.heading = data.heading or 0  -- degrees
    self.speed = data.speed or self:_calculateSpeed()
    
    -- Destination and route
    self.destination = data.destination  -- {x, y} or province_id
    self.waypoints = data.waypoints or {}
    self.current_waypoint_index = 1
    
    -- Mission parameters
    self.mission_id = data.mission_id
    self.mission_timer = data.mission_timer or 0
    self.mission_duration = data.mission_duration or 3600  -- seconds
    
    -- State
    self.state = data.state or UFO.State.FLYING
    self.detected = data.detected or false
    self.detection_time = nil
    self.tracked = data.tracked or false
    
    -- Combat stats
    self.max_health = data.max_health or self:_calculateHealth()
    self.current_health = data.current_health or self.max_health
    self.armor = data.armor or self:_calculateArmor()
    self.weapon_power = data.weapon_power or self:_calculateWeaponPower()
    self.evasion = data.evasion or self:_calculateEvasion()
    
    -- Detection resistance
    self.stealth_rating = data.stealth_rating or self:_calculateStealth()
    
    -- Interception data
    self.intercepting_crafts = {}  -- craft_id -> craft reference
    self.in_combat = false
    
    -- Loot and rewards
    self.recovery_value = data.recovery_value or self:_calculateRecoveryValue()
    self.crew_count = data.crew_count or self:_calculateCrewCount()
    
    -- Event bus
    self.event_bus = nil
    
    -- World reference
    self.world = nil
end

--- Set the world reference
-- @param world The World instance
function UFO:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Set event bus
-- @param event_bus The event bus instance
function UFO:setEventBus(event_bus)
    self.event_bus = event_bus
end

--- Update UFO state
-- @param deltaTime Time elapsed in seconds
function UFO:update(deltaTime)
    if self.state == UFO.State.DESTROYED then
        return
    end
    
    -- Update mission timer
    self.mission_timer = self.mission_timer + deltaTime
    
    -- Update position if flying
    if self.state == UFO.State.FLYING or self.state == UFO.State.RETREATING then
        self:_updateMovement(deltaTime)
    end
    
    -- Check mission completion
    if self.state == UFO.State.LANDED and self.mission_timer >= self.mission_duration then
        self:completeMission()
    end
    
    -- Update interception combat
    if self.in_combat then
        self:_updateCombat(deltaTime)
    end
end

--- Update UFO movement
-- @param deltaTime Time elapsed in seconds
function UFO:_updateMovement(deltaTime)
    if not self.destination then
        return
    end
    
    local dx = self.destination[1] - self.coordinates[1]
    local dy = self.destination[2] - self.coordinates[2]
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Check if reached destination
    if distance < 10 then  -- Within 10 pixels
        self:reachDestination()
        return
    end
    
    -- Calculate new position
    local move_distance = self.speed * deltaTime
    local ratio = math.min(move_distance / distance, 1.0)
    
    self.coordinates[1] = self.coordinates[1] + dx * ratio
    self.coordinates[2] = self.coordinates[2] + dy * ratio
    
    -- Update heading
    self.heading = math.deg(math.atan2(dy, dx))
end

--- Reach destination
function UFO:reachDestination()
    -- Check if there are more waypoints
    if #self.waypoints > 0 and self.current_waypoint_index <= #self.waypoints then
        self.destination = self.waypoints[self.current_waypoint_index]
        self.current_waypoint_index = self.current_waypoint_index + 1
    else
        -- Land at destination
        self:land()
    end
end

--- Land the UFO
function UFO:land()
    self.state = UFO.State.LANDED
    self.mission_timer = 0
    
    if self.event_bus then
        self.event_bus:publish("ufo:landed", {
            ufo_id = self.id,
            coordinates = self.coordinates,
            world_id = self.world_id
        })
    end
end

--- Complete UFO mission
function UFO:completeMission()
    -- Take off and retreat
    self.state = UFO.State.RETREATING
    self.destination = nil  -- Leave map
    
    if self.event_bus then
        self.event_bus:publish("ufo:mission_complete", {
            ufo_id = self.id,
            type = self.type,
            world_id = self.world_id
        })
    end
end

--- Set destination
-- @param destination Destination coordinates {x, y} or province_id
function UFO:setDestination(destination)
    self.destination = destination
end

--- Set waypoints
-- @param waypoints Array of waypoint coordinates
function UFO:setWaypoints(waypoints)
    self.waypoints = waypoints
    self.current_waypoint_index = 1
end

--- Mark UFO as detected
function UFO:detect()
    if not self.detected then
        self.detected = true
        self.detection_time = self.mission_timer
        
        if self.event_bus then
            self.event_bus:publish("ufo:detected", {
                ufo_id = self.id,
                type = self.type,
                size = self.size,
                coordinates = self.coordinates,
                world_id = self.world_id
            })
        end
    end
end

--- Mark UFO as tracked
function UFO:track()
    self.tracked = true
end

--- Untrack UFO (lost radar contact)
function UFO:untrack()
    self.tracked = false
end

--- Check if UFO is detected
-- @return true if detected
function UFO:isDetected()
    return self.detected
end

--- Check if UFO is tracked
-- @return true if tracked
function UFO:isTracked()
    return self.tracked
end

--- Intercept UFO with craft
-- @param craft The intercepting craft
function UFO:intercept(craft)
    self.intercepting_crafts[craft.id] = craft
    self.in_combat = true
    
    if self.event_bus then
        self.event_bus:publish("ufo:intercepted", {
            ufo_id = self.id,
            craft_id = craft.id,
            coordinates = self.coordinates
        })
    end
end

--- Remove intercepting craft
-- @param craft_id The craft ID
function UFO:removeInterceptor(craft_id)
    self.intercepting_crafts[craft_id] = nil
    
    if self:_countInterceptors() == 0 then
        self.in_combat = false
    end
end

--- Count active interceptors
-- @return Number of interceptors
function UFO:_countInterceptors()
    local count = 0
    for _ in pairs(self.intercepting_crafts) do
        count = count + 1
    end
    return count
end

--- Update combat with interceptors
-- @param deltaTime Time elapsed in seconds
function UFO:_updateCombat(deltaTime)
    -- Simple combat resolution: exchange damage
    for craft_id, craft in pairs(self.intercepting_crafts) do
        -- UFO takes damage from craft
        local damage = craft:getWeaponPower() * deltaTime * 0.1
        self:takeDamage(damage)
        
        -- Craft takes damage from UFO
        local ufo_damage = self.weapon_power * deltaTime * 0.1
        craft:takeDamage(ufo_damage)
        
        -- Check if craft is destroyed
        if craft:isDestroyed() then
            self:removeInterceptor(craft_id)
        end
    end
    
    -- Check if UFO should retreat
    if self.current_health < self.max_health * 0.3 then
        self:retreat()
    end
end

--- Take damage
-- @param damage Amount of damage
function UFO:takeDamage(damage)
    local actual_damage = math.max(0, damage - self.armor)
    self.current_health = math.max(0, self.current_health - actual_damage)
    
    if self.current_health <= 0 then
        self:destroy()
    end
end

--- Destroy UFO
function UFO:destroy()
    self.state = UFO.State.DESTROYED
    self.in_combat = false
    
    if self.event_bus then
        self.event_bus:publish("ufo:destroyed", {
            ufo_id = self.id,
            coordinates = self.coordinates,
            recovery_value = self.recovery_value,
            crew_count = self.crew_count
        })
    end
end

--- Crash UFO (forced landing)
function UFO:crash()
    self.state = UFO.State.CRASHED
    self.in_combat = false
    
    if self.event_bus then
        self.event_bus:publish("ufo:crashed", {
            ufo_id = self.id,
            coordinates = self.coordinates,
            recovery_value = self.recovery_value * 1.5,  -- More loot from crashed UFO
            crew_count = math.floor(self.crew_count * 0.7)  -- Some crew survive
        })
    end
end

--- Retreat from combat
function UFO:retreat()
    if self.state ~= UFO.State.RETREATING then
        self.state = UFO.State.RETREATING
        self.destination = nil  -- Leave map
        self.in_combat = false
        
        -- Clear interceptors
        self.intercepting_crafts = {}
        
        if self.event_bus then
            self.event_bus:publish("ufo:retreating", {
                ufo_id = self.id,
                coordinates = self.coordinates
            })
        end
    end
end

--- Calculate speed based on size
-- @return Speed in pixels per second
function UFO:_calculateSpeed()
    local speed_table = {
        [UFO.Size.SMALL] = 100,
        [UFO.Size.MEDIUM] = 70,
        [UFO.Size.LARGE] = 50,
        [UFO.Size.VERY_LARGE] = 30
    }
    return speed_table[self.size] or 50
end

--- Calculate health based on size
-- @return Max health
function UFO:_calculateHealth()
    local health_table = {
        [UFO.Size.SMALL] = 100,
        [UFO.Size.MEDIUM] = 200,
        [UFO.Size.LARGE] = 400,
        [UFO.Size.VERY_LARGE] = 800
    }
    return health_table[self.size] or 200
end

--- Calculate armor based on size
-- @return Armor value
function UFO:_calculateArmor()
    local armor_table = {
        [UFO.Size.SMALL] = 5,
        [UFO.Size.MEDIUM] = 10,
        [UFO.Size.LARGE] = 20,
        [UFO.Size.VERY_LARGE] = 40
    }
    return armor_table[self.size] or 10
end

--- Calculate weapon power based on size
-- @return Weapon power
function UFO:_calculateWeaponPower()
    local weapon_table = {
        [UFO.Size.SMALL] = 10,
        [UFO.Size.MEDIUM] = 20,
        [UFO.Size.LARGE] = 35,
        [UFO.Size.VERY_LARGE] = 60
    }
    return weapon_table[self.size] or 20
end

--- Calculate evasion based on size
-- @return Evasion value (0-100)
function UFO:_calculateEvasion()
    local evasion_table = {
        [UFO.Size.SMALL] = 50,
        [UFO.Size.MEDIUM] = 30,
        [UFO.Size.LARGE] = 15,
        [UFO.Size.VERY_LARGE] = 5
    }
    return evasion_table[self.size] or 20
end

--- Calculate stealth rating based on type
-- @return Stealth rating (0-100)
function UFO:_calculateStealth()
    local stealth_table = {
        [UFO.MissionType.SCOUT] = 60,
        [UFO.MissionType.ABDUCTION] = 40,
        [UFO.MissionType.TERROR] = 20,
        [UFO.MissionType.INFILTRATION] = 80,
        [UFO.MissionType.SUPPLY] = 30,
        [UFO.MissionType.BATTLESHIP] = 10
    }
    return stealth_table[self.type] or 30
end

--- Calculate recovery value based on size
-- @return Recovery value in credits
function UFO:_calculateRecoveryValue()
    local value_table = {
        [UFO.Size.SMALL] = 10000,
        [UFO.Size.MEDIUM] = 25000,
        [UFO.Size.LARGE] = 50000,
        [UFO.Size.VERY_LARGE] = 100000
    }
    return value_table[self.size] or 25000
end

--- Calculate crew count based on size
-- @return Crew count
function UFO:_calculateCrewCount()
    local crew_table = {
        [UFO.Size.SMALL] = 3,
        [UFO.Size.MEDIUM] = 6,
        [UFO.Size.LARGE] = 12,
        [UFO.Size.VERY_LARGE] = 20
    }
    return crew_table[self.size] or 6
end

--- Get UFO state summary
-- @return Table with UFO state
function UFO:getState()
    return {
        id = self.id,
        type = self.type,
        size = self.size,
        coordinates = self.coordinates,
        altitude = self.altitude,
        heading = self.heading,
        speed = self.speed,
        state = self.state,
        detected = self.detected,
        tracked = self.tracked,
        health_percent = (self.current_health / self.max_health) * 100,
        in_combat = self.in_combat,
        interceptor_count = self:_countInterceptors()
    }
end

--- Convert to string representation
-- @return String representation
function UFO:__tostring()
    return string.format("UFO{id='%s', type='%s', size='%s', state='%s', detected=%s}",
                        self.id, self.type, self.size, self.state, tostring(self.detected))
end

return UFO
