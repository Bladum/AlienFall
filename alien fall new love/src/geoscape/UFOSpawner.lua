--- UFOSpawner.lua
-- UFO spawning and mission generation system
-- Creates UFO missions based on alien activity level and game progression

-- GROK: UFOSpawner generates UFO missions with appropriate difficulty and frequency
-- GROK: Uses weighted random selection for mission types and sizes
-- GROK: Key methods: spawnUFO(), calculateSpawnRate(), selectMissionType()
-- GROK: Integrates with alien activity escalation and strategic AI

local class = require 'lib.Middleclass'
local UFO = require 'geoscape.UFO'

UFOSpawner = class('UFOSpawner')

--- Initialize UFO spawner
-- @param rng Random number generator
-- @param config Spawner configuration
function UFOSpawner:initialize(rng, config)
    self.rng = rng or love.math.newRandomGenerator()
    self.config = config or {}
    
    -- Spawn parameters
    self.base_spawn_rate = self.config.base_spawn_rate or 0.1  -- UFOs per hour
    self.spawn_rate_multiplier = 1.0
    self.alien_activity_level = self.config.alien_activity_level or 1.0
    
    -- Mission type weights (adjusted by alien activity)
    self.mission_weights = {
        scout = 40,
        abduction = 25,
        terror = 10,
        infiltration = 15,
        supply = 8,
        battleship = 2
    }
    
    -- Size distribution weights
    self.size_weights = {
        small = 50,
        medium = 30,
        large = 15,
        very_large = 5
    }
    
    -- Active UFOs tracking
    self.active_ufos = {}
    self.max_concurrent_ufos = self.config.max_concurrent_ufos or 10
    
    -- Spawn timer
    self.spawn_timer = 0
    self.next_spawn_time = self:_calculateNextSpawnTime()
    
    -- Event bus
    self.event_bus = nil
    
    -- Telemetry
    self.telemetry = nil
    
    -- World reference
    self.world = nil
end

--- Set world reference
-- @param world The World instance
function UFOSpawner:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Set event bus
-- @param event_bus The event bus instance
function UFOSpawner:setEventBus(event_bus)
    self.event_bus = event_bus
end

--- Set telemetry
-- @param telemetry The telemetry service
function UFOSpawner:setTelemetry(telemetry)
    self.telemetry = telemetry
end

--- Update spawner
-- @param deltaTime Time elapsed in seconds
function UFOSpawner:update(deltaTime)
    self.spawn_timer = self.spawn_timer + deltaTime
    
    -- Check if it's time to spawn
    if self.spawn_timer >= self.next_spawn_time then
        self:_attemptSpawn()
        self.spawn_timer = 0
        self.next_spawn_time = self:_calculateNextSpawnTime()
    end
    
    -- Update active UFOs
    self:_updateActiveUFOs(deltaTime)
end

--- Attempt to spawn a UFO
function UFOSpawner:_attemptSpawn()
    -- Check if we can spawn more UFOs
    if #self.active_ufos >= self.max_concurrent_ufos then
        return
    end
    
    -- Spawn UFO
    local ufo = self:spawnUFO()
    
    if ufo then
        table.insert(self.active_ufos, ufo)
        
        if self.telemetry then
            self.telemetry:record("ufo_spawned", {
                type = ufo.type,
                size = ufo.size,
                activity_level = self.alien_activity_level
            })
        end
    end
end

--- Spawn a UFO with random parameters
-- @return UFO instance or nil
function UFOSpawner:spawnUFO()
    if not self.world then
        return nil
    end
    
    -- Select mission type and size
    local mission_type = self:selectMissionType()
    local size = self:selectSize()
    
    -- Generate spawn position (edge of map)
    local spawn_pos = self:_generateSpawnPosition()
    
    -- Generate destination (random province)
    local destination = self:_selectDestination()
    
    -- Create UFO
    local ufo_data = {
        id = self:_generateUFOId(),
        type = mission_type,
        size = size,
        world_id = self.world.id,
        coordinates = spawn_pos,
        destination = destination,
        mission_duration = self:_calculateMissionDuration(mission_type)
    }
    
    local ufo = UFO:new(ufo_data)
    ufo:setWorld(self.world)
    
    -- Publish spawn event
    if self.event_bus then
        self.event_bus:publish("ufo:spawned", {
            ufo_id = ufo.id,
            type = mission_type,
            size = size,
            coordinates = spawn_pos
        })
    end
    
    return ufo
end

--- Select mission type using weighted random selection
-- @return Mission type string
function UFOSpawner:selectMissionType()
    local total_weight = 0
    for _, weight in pairs(self.mission_weights) do
        total_weight = total_weight + weight
    end
    
    local random_value = self.rng:random() * total_weight
    local cumulative = 0
    
    for mission_type, weight in pairs(self.mission_weights) do
        cumulative = cumulative + weight
        if random_value <= cumulative then
            return mission_type
        end
    end
    
    return "scout"  -- Fallback
end

--- Select UFO size using weighted random selection
-- @return Size string
function UFOSpawner:selectSize()
    local total_weight = 0
    for _, weight in pairs(self.size_weights) do
        total_weight = total_weight + weight
    end
    
    local random_value = self.rng:random() * total_weight
    local cumulative = 0
    
    for size, weight in pairs(self.size_weights) do
        cumulative = cumulative + weight
        if random_value <= cumulative then
            return size
        end
    end
    
    return "medium"  -- Fallback
end

--- Generate spawn position at map edge
-- @return Coordinates {x, y}
function UFOSpawner:_generateSpawnPosition()
    local map_width = 800
    local map_height = 600
    
    -- Random edge: 0=top, 1=right, 2=bottom, 3=left
    local edge = self.rng:random(0, 3)
    
    if edge == 0 then  -- Top
        return {self.rng:random() * map_width, 0}
    elseif edge == 1 then  -- Right
        return {map_width, self.rng:random() * map_height}
    elseif edge == 2 then  -- Bottom
        return {self.rng:random() * map_width, map_height}
    else  -- Left
        return {0, self.rng:random() * map_height}
    end
end

--- Select random destination province
-- @return Coordinates {x, y}
function UFOSpawner:_selectDestination()
    if not self.world then
        return {400, 300}  -- Center of map
    end
    
    -- Get random province
    local province_count = 0
    for _ in pairs(self.world.provinces) do
        province_count = province_count + 1
    end
    
    if province_count == 0 then
        return {400, 300}
    end
    
    local target_index = self.rng:random(1, province_count)
    local current_index = 0
    
    for _, province in pairs(self.world.provinces) do
        current_index = current_index + 1
        if current_index == target_index then
            return province.coordinates
        end
    end
    
    return {400, 300}
end

--- Calculate mission duration based on type
-- @param mission_type Mission type
-- @return Duration in seconds
function UFOSpawner:_calculateMissionDuration(mission_type)
    local durations = {
        scout = 600,        -- 10 minutes
        abduction = 1800,   -- 30 minutes
        terror = 3600,      -- 1 hour
        infiltration = 7200, -- 2 hours
        supply = 1200,      -- 20 minutes
        battleship = 1800   -- 30 minutes
    }
    
    return durations[mission_type] or 1800
end

--- Calculate next spawn time
-- @return Time until next spawn in seconds
function UFOSpawner:_calculateNextSpawnTime()
    local base_interval = 3600 / self.base_spawn_rate  -- Seconds per spawn
    local adjusted_interval = base_interval / self.spawn_rate_multiplier
    
    -- Add random variance (±25%)
    local variance = adjusted_interval * 0.25
    local random_offset = (self.rng:random() - 0.5) * 2 * variance
    
    return math.max(300, adjusted_interval + random_offset)  -- Minimum 5 minutes
end

--- Generate unique UFO ID
-- @return UFO ID string
function UFOSpawner:_generateUFOId()
    return string.format("ufo_%d_%d", 
                        os.time(), 
                        self.rng:random(1000, 9999))
end

--- Update active UFOs
-- @param deltaTime Time elapsed in seconds
function UFOSpawner:_updateActiveUFOs(deltaTime)
    local i = 1
    while i <= #self.active_ufos do
        local ufo = self.active_ufos[i]
        ufo:update(deltaTime)
        
        -- Remove destroyed or retreated UFOs
        if ufo.state == UFO.State.DESTROYED or 
           (ufo.state == UFO.State.RETREATING and not ufo.destination) then
            table.remove(self.active_ufos, i)
        else
            i = i + 1
        end
    end
end

--- Set alien activity level
-- @param level Activity level (0.0 to 5.0+)
function UFOSpawner:setAlienActivityLevel(level)
    self.alien_activity_level = level
    self.spawn_rate_multiplier = 1.0 + (level - 1.0) * 0.5
    
    -- Adjust mission weights based on activity level
    if level >= 3.0 then
        self.mission_weights.battleship = 10
        self.mission_weights.terror = 20
    elseif level >= 2.0 then
        self.mission_weights.terror = 15
        self.mission_weights.infiltration = 20
    end
end

--- Get active UFO count
-- @return Number of active UFOs
function UFOSpawner:getActiveUFOCount()
    return #self.active_ufos
end

--- Get all active UFOs
-- @return Array of UFO instances
function UFOSpawner:getActiveUFOs()
    return self.active_ufos
end

--- Get spawner state
-- @return Table with spawner state
function UFOSpawner:getState()
    return {
        active_ufo_count = #self.active_ufos,
        max_concurrent = self.max_concurrent_ufos,
        alien_activity_level = self.alien_activity_level,
        spawn_rate_multiplier = self.spawn_rate_multiplier,
        next_spawn_in = self.next_spawn_time - self.spawn_timer
    }
end

return UFOSpawner
