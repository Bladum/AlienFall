--- Province.lua
-- Province system for Alien Fall
-- Single location on world map with connections, biome, and economic properties

-- GROK: Province represents atomic spatial anchor for bases, missions, and events on geoscape
-- GROK: Manages connections, biome assignment, economic data, and mission hosting
-- GROK: Key methods: getCoordinates(), getAdjacencies(), canHostBase(), addMission()
-- GROK: Handles spatial mathematics, detection integration, and event targeting

local class = require 'lib.Middleclass'

Province = class('Province')

--- Initialize a new province
-- @param data The TOML data for this province
function Province:initialize(data)
    self.id = data.id
    self.name = data.name or "Unknown Province"
    self.description = data.description or ""

    -- Identity and location
    self.world_id = data.world_id
    self.coordinates = data.coordinates or {0, 0}  -- {x, y} in pixels
    self.longitude = data.longitude or 0  -- For illumination calculations

    -- Geographic properties
    self.biome_id = data.biome_id
    self.is_water = data.is_water or false
    self.terrain_modifier = data.terrain_modifier or 1.0

    -- Economic data
    self.economy_value = data.economy_value or 50
    self.population = data.population or 0

    -- Political organization
    self.region_id = data.region_id
    self.country_id = data.country_id

    -- Adjacency and connections
    self.adjacencies = data.adjacencies or {}  -- List of connected province IDs
    self.connection_costs = data.connection_costs or {}  -- Travel costs to adjacent provinces

    -- Control and ownership
    self.controlled_by = data.controlled_by or "neutral"  -- "neutral", "player", "alien"
    self.base_present = data.base_present or false
    self.alien_activity = data.alien_activity or 0.5

    -- Mission hosting
    self.active_missions = {}  -- mission_id -> mission_data
    self.max_concurrent_missions = data.max_concurrent_missions or 3

    -- Tags and properties
    self.tags = data.tags or {}

    -- World reference
    self.world = nil

    -- Event bus
    self.event_bus = nil

    -- Validate data
    self:_validate()
end

--- Validate the province data
function Province:_validate()
    assert(self.id, "Province must have an id")
    assert(self.name, "Province must have a name")
    assert(self.coordinates and #self.coordinates == 2, "Province must have valid coordinates [x, y]")
end

--- Set the world reference
-- @param world The World instance
function Province:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Get province coordinates
-- @return x, y coordinates in pixels
function Province:getCoordinates()
    return self.coordinates[1], self.coordinates[2]
end

--- Get province longitude
-- @return Longitude in degrees
function Province:getLongitude()
    return self.longitude
end

--- Get adjacent provinces
-- @return Array of adjacent province IDs
function Province:getAdjacencies()
    return self.adjacencies
end

--- Check if this province is adjacent to another
-- @param province_id The other province ID
-- @return true if adjacent
function Province:isAdjacentTo(province_id)
    for _, adjacent_id in ipairs(self.adjacencies) do
        if adjacent_id == province_id then
            return true
        end
    end
    return false
end

--- Get travel cost to adjacent province
-- @param province_id The destination province ID
-- @return Travel cost or nil if not adjacent
function Province:getTravelCostTo(province_id)
    return self.connection_costs[province_id]
end

--- Get biome information
-- @return Biome ID
function Province:getBiomeId()
    return self.biome_id
end

--- Get economic value
-- @return Economic value
function Province:getEconomyValue()
    return self.economy_value
end

--- Get population
-- @return Population count
function Province:getPopulation()
    return self.population
end

--- Get region ID
-- @return Region ID
function Province:getRegionId()
    return self.region_id
end

--- Get country ID
-- @return Country ID
function Province:getCountryId()
    return self.country_id
end

--- Check if province can host a base
-- @return true if can host base
function Province:canHostBase()
    return not self.base_present and not self.is_water
end

--- Check if province is controlled by player
-- @return true if player controlled
function Province:isPlayerControlled()
    return self.controlled_by == "player"
end

--- Check if province is controlled by aliens
-- @return true if alien controlled
function Province:isAlienControlled()
    return self.controlled_by == "alien"
end

--- Set control of province
-- @param controller "neutral", "player", or "alien"
function Province:setControl(controller)
    local old_control = self.controlled_by
    self.controlled_by = controller

    -- Publish event if control changed
    if self.event_bus and old_control ~= controller then
        self.event_bus:publish("province:control_changed", {
            province_id = self.id,
            old_control = old_control,
            new_control = controller
        })
    end
end

--- Get alien activity level
-- @return Activity level (0.0 to 1.0)
function Province:getAlienActivity()
    return self.alien_activity
end

--- Set alien activity level
-- @param activity New activity level
function Province:setAlienActivity(activity)
    self.alien_activity = math.max(0, math.min(1, activity))
end

--- Check if province has a specific tag
-- @param tag The tag to check
-- @return true if has tag
function Province:hasTag(tag)
    for _, province_tag in ipairs(self.tags) do
        if province_tag == tag then
            return true
        end
    end
    return false
end

--- Add a mission to this province
-- @param mission_data The mission data
-- @return true if added successfully, false if at capacity
function Province:addMission(mission_data)
    if self:getActiveMissionCount() >= self.max_concurrent_missions then
        return false
    end

    local mission_id = mission_data.id
    self.active_missions[mission_id] = mission_data

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("province:mission_added", {
            province_id = self.id,
            mission_id = mission_id
        })
    end

    return true
end

--- Remove a mission from this province
-- @param mission_id The mission ID to remove
function Province:removeMission(mission_id)
    if self.active_missions[mission_id] then
        self.active_missions[mission_id] = nil

        -- Publish event
        if self.event_bus then
            self.event_bus:publish("province:mission_removed", {
                province_id = self.id,
                mission_id = mission_id
            })
        end
    end
end

--- Get active missions
-- @return Table of active mission data
function Province:getActiveMissions()
    return self.active_missions
end

--- Check if province can accept a new mission
-- @return true if at or below mission capacity
function Province:canAcceptMission()
    return self:getActiveMissionCount() <= self.max_concurrent_missions
end

--- Get visible missions (detected missions with cover <= 0)
-- @return Table of visible mission data
function Province:getVisibleMissions()
    local visible = {}
    for mission_id, mission in pairs(self.active_missions) do
        if mission:isDetected() then
            visible[mission_id] = mission
        end
    end
    return visible
end

--- Get number of visible missions
-- @return Number of visible missions
function Province:getVisibleMissionCount()
    local count = 0
    for _, mission in pairs(self.active_missions) do
        if mission:isDetected() then
            count = count + 1
        end
    end
    return count
end

--- Get number of active missions
-- @return Number of active missions
function Province:getActiveMissionCount()
    local count = 0
    for _ in pairs(self.active_missions) do
        count = count + 1
    end
    return count
end

--- Advance time for this province
-- @param days Number of days to advance
function Province:advanceTime(days)
    -- Update alien activity (simple simulation)
    local activity_change = (math.random() - 0.5) * 0.1 * days
    self:setAlienActivity(self.alien_activity + activity_change)

    -- Potentially spawn new missions based on alien activity
    self:_checkMissionSpawn(days)

    -- Process mission timers
    self:_updateMissions(days)
end

--- Check if new missions should be spawned
-- @param days Days passed
function Province:_checkMissionSpawn(days)
    -- Only spawn missions if below capacity
    if not self:canAcceptMission() then
        return
    end

    -- Mission spawn chance based on alien activity
    local spawn_chance = self.alien_activity * 0.01 * days  -- 1% base chance per day at max activity

    -- Additional modifiers
    if self.controlled_by == "alien" then
        spawn_chance = spawn_chance * 2.0  -- Double chance in alien-controlled provinces
    elseif self.controlled_by == "player" then
        spawn_chance = spawn_chance * 0.5  -- Half chance in player-controlled provinces
    end

    -- Random check
    if math.random() < spawn_chance then
        self:_spawnRandomMission()
    end
end

--- Spawn a random mission in this province
function Province:_spawnRandomMission()
    -- This is a placeholder - in a real implementation, this would select from
    -- mission templates based on province characteristics, alien activity, etc.

    local mission_templates = {
        {
            id = "alien_scout_" .. self.id .. "_" .. os.time(),
            name = "Alien Scout Activity",
            type = "recon",
            difficulty = "easy",
            duration = 24,
            initial_cover = 80,
            armor = 10,
            objectives = { primary = "Investigate alien scout activity" },
            rewards = { experience = 50 }
        },
        {
            id = "ufo_crash_" .. self.id .. "_" .. os.time(),
            name = "UFO Crash Site",
            type = "recovery",
            difficulty = "medium",
            duration = 48,
            initial_cover = 60,
            armor = 5,
            objectives = { primary = "Recover alien technology from crash site" },
            rewards = { experience = 100, technology = 25 }
        },
        {
            id = "alien_base_" .. self.id .. "_" .. os.time(),
            name = "Alien Base Construction",
            type = "assault",
            difficulty = "hard",
            duration = 72,
            initial_cover = 40,
            armor = 20,
            objectives = { primary = "Destroy alien base under construction" },
            rewards = { experience = 200, technology = 50 }
        }
    }

    -- Select random mission template
    local template = mission_templates[math.random(#mission_templates)]

    -- Create mission instance
    local Mission = require "lore.Mission"
    local mission = Mission.new(template)

    -- Add to province
    if self:addMission(mission) then
        -- Publish mission spawned event
        if self.event_bus then
            self.event_bus:publish("province:mission_spawned", {
                province_id = self.id,
                mission_id = mission.id,
                mission_type = mission.type
            })
        end
    end
end

--- Update active missions
-- @param days Days passed
function Province:_updateMissions(days)
    for mission_id, mission_data in pairs(self.active_missions) do
        if mission_data.expiry_time then
            mission_data.expiry_time = mission_data.expiry_time - days
            if mission_data.expiry_time <= 0 then
                self:removeMission(mission_id)
            end
        end
    end
end

--- Calculate detection range from this province
-- @param detection_strength Base detection strength
-- @return Effective detection range
function Province:calculateDetectionRange(detection_strength)
    -- Apply province modifiers
    local modifier = 1.0

    if self.is_water then
        modifier = modifier * 0.8  -- Water reduces detection
    end

    if self:hasTag("urban") then
        modifier = modifier * 1.2  -- Urban areas improve detection
    end

    if self:hasTag("mountainous") then
        modifier = modifier * 1.1  -- Mountains improve detection
    end

    return detection_strength * modifier
end

--- Get display information for UI
-- @return Table with display data
function Province:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        coordinates = self.coordinates,
        biome_id = self.biome_id,
        economy_value = self.economy_value,
        population = self.population,
        region_id = self.region_id,
        country_id = self.country_id,
        controlled_by = self.controlled_by,
        base_present = self.base_present,
        alien_activity = self.alien_activity,
        active_missions = self:getActiveMissionCount(),
        max_missions = self.max_concurrent_missions,
        tags = self.tags
    }
end

--- Get strategic value for AI calculations
-- @return Strategic value score
function Province:getStrategicValue()
    local value = self.economy_value

    -- Add population bonus
    value = value + (self.population / 1000)

    -- Add base presence bonus
    if self.base_present then
        value = value * 1.5
    end

    -- Add adjacency bonus
    value = value * (1 + #self.adjacencies * 0.1)

    -- Apply alien activity modifier
    value = value * (1 + self.alien_activity)

    return value
end

--- Convert to string representation
-- @return String representation
function Province:__tostring()
    return string.format("Province{id='%s', name='%s', coords=(%d,%d), biome='%s', control='%s'}",
                        self.id, self.name, self.coordinates[1], self.coordinates[2],
                        self.biome_id or "none", self.controlled_by)
end

return Province
