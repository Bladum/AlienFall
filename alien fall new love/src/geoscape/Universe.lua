--- Universe.lua
-- Universe system for Alien Fall
-- Manages worlds, inter-world travel, technology requirements, and campaign management

-- GROK: Universe manages multiple worlds with isolated state, handles inter-world travel technology requirements,
-- GROK: coordinates calendar ticks across all worlds, and manages campaign progression at universe level
-- GROK: Key methods: addWorld(), canTravelBetweenWorlds(), advanceTime(), getCampaigns()
-- GROK: Handles world isolation, travel prerequisites, and cross-world event coordination

local class = require 'lib.Middleclass'

Universe = class('Universe')

--- Initialize a new universe
-- @param data The TOML data for this universe
function Universe:initialize(data)
    self.id = data.id or "universe_1"
    self.name = data.name or "Default Universe"
    self.description = data.description or ""

    -- World management
    self.worlds = {}  -- world_id -> World instance
    self.world_order = {}  -- ordered list of world IDs

    -- Travel technology requirements
    self.travel_requirements = data.travel_requirements or {}

    -- Campaign management
    self.campaigns = data.campaigns or {}
    self.active_campaigns = {}

    -- Time management
    self.current_time = data.current_time or 0
    self.time_system = nil  -- Will be set by external system

    -- Event bus for communication
    self.event_bus = nil

    -- Validate data
    self:_validate()
end

--- Validate the universe data
function Universe:_validate()
    assert(self.id, "Universe must have an id")
    assert(self.name, "Universe must have a name")
end

--- Set the event bus for communication
-- @param event_bus The event bus instance
function Universe:setEventBus(event_bus)
    self.event_bus = event_bus
end

--- Set the time system
-- @param time_system The time system instance
function Universe:setTimeSystem(time_system)
    self.time_system = time_system
end

--- Add a world to the universe
-- @param world The World instance to add
function Universe:addWorld(world)
    assert(world.id, "World must have an id")
    self.worlds[world.id] = world
    table.insert(self.world_order, world.id)

    -- Set universe reference in world
    world:setUniverse(self)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("universe:world_added", {
            universe_id = self.id,
            world_id = world.id
        })
    end
end

--- Remove a world from the universe
-- @param world_id The ID of the world to remove
function Universe:removeWorld(world_id)
    if self.worlds[world_id] then
        self.worlds[world_id] = nil

        -- Remove from order list
        for i, id in ipairs(self.world_order) do
            if id == world_id then
                table.remove(self.world_order, i)
                break
            end
        end

        -- Publish event
        if self.event_bus then
            self.event_bus:publish("universe:world_removed", {
                universe_id = self.id,
                world_id = world_id
            })
        end
    end
end

--- Get a world by ID
-- @param world_id The world ID
-- @return World instance or nil
function Universe:getWorld(world_id)
    return self.worlds[world_id]
end

--- Get all worlds
-- @return Table of world instances
function Universe:getWorlds()
    local result = {}
    for _, world_id in ipairs(self.world_order) do
        result[world_id] = self.worlds[world_id]
    end
    return result
end

--- Get worlds in order
-- @return Ordered array of world instances
function Universe:getWorldsOrdered()
    local result = {}
    for _, world_id in ipairs(self.world_order) do
        table.insert(result, self.worlds[world_id])
    end
    return result
end

--- Check if travel between two worlds is possible
-- @param from_world_id Source world ID
-- @param to_world_id Destination world ID
-- @param available_tech Table of completed research {tech_id = true}
-- @return true if travel is possible, false otherwise
function Universe:canTravelBetweenWorlds(from_world_id, to_world_id, available_tech)
    -- Same world travel is always possible
    if from_world_id == to_world_id then
        return true
    end

    local from_world = self.worlds[from_world_id]
    local to_world = self.worlds[to_world_id]

    if not from_world or not to_world then
        return false
    end

    -- Check travel requirements
    local requirements = self:getTravelRequirements(from_world_id, to_world_id)
    if not requirements then
        return false
    end

    -- Check technology requirements
    if requirements.research then
        for _, tech_id in ipairs(requirements.research) do
            if not available_tech[tech_id] then
                return false
            end
        end
    end

    return true
end

--- Get travel requirements between two worlds
-- @param from_world_id Source world ID
-- @param to_world_id Destination world ID
-- @return Travel requirements table or nil if no requirements defined
function Universe:getTravelRequirements(from_world_id, to_world_id)
    local key = from_world_id .. "_to_" .. to_world_id
    return self.travel_requirements[key]
end

--- Set travel requirements between two worlds
-- @param from_world_id Source world ID
-- @param to_world_id Destination world ID
-- @param requirements Requirements table
function Universe:setTravelRequirements(from_world_id, to_world_id, requirements)
    local key = from_world_id .. "_to_" .. to_world_id
    self.travel_requirements[key] = requirements
end

--- Advance time for all worlds
-- @param days Number of days to advance
function Universe:advanceTime(days)
    self.current_time = self.current_time + days

    -- Advance time on all worlds
    for _, world in pairs(self.worlds) do
        world:advanceTime(days)
    end

    -- Process universe-level campaigns
    self:_processCampaigns(days)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("universe:time_advanced", {
            universe_id = self.id,
            days = days,
            new_time = self.current_time
        })
    end
end

--- Process universe-level campaigns
-- @param days Number of days passed
function Universe:_processCampaigns(days)
    -- Check for new campaigns to activate
    for campaign_id, campaign_data in pairs(self.campaigns) do
        if not self.active_campaigns[campaign_id] then
            if self:_shouldActivateCampaign(campaign_data, self.current_time) then
                self.active_campaigns[campaign_id] = campaign_data
                self:_distributeCampaignToWorlds(campaign_data)

                if self.event_bus then
                    self.event_bus:publish("universe:campaign_activated", {
                        universe_id = self.id,
                        campaign_id = campaign_id
                    })
                end
            end
        end
    end

    -- Update active campaigns
    for campaign_id, campaign_data in pairs(self.active_campaigns) do
        if self:_shouldDeactivateCampaign(campaign_data, self.current_time) then
            self.active_campaigns[campaign_id] = nil

            if self.event_bus then
                self.event_bus:publish("universe:campaign_deactivated", {
                    universe_id = self.id,
                    campaign_id = campaign_id
                })
            end
        end
    end
end

--- Check if a campaign should be activated
-- @param campaign_data Campaign configuration
-- @param current_time Current universe time
-- @return true if should activate
function Universe:_shouldActivateCampaign(campaign_data, current_time)
    if not campaign_data.activation_time then
        return false
    end
    return current_time >= campaign_data.activation_time
end

--- Check if a campaign should be deactivated
-- @param campaign_data Campaign configuration
-- @param current_time Current universe time
-- @return true if should deactivate
function Universe:_shouldDeactivateCampaign(campaign_data, current_time)
    if not campaign_data.deactivation_time then
        return false
    end
    return current_time >= campaign_data.deactivation_time
end

--- Distribute campaign to appropriate worlds
-- @param campaign_data Campaign configuration
function Universe:_distributeCampaignToWorlds(campaign_data)
    for _, world in pairs(self.worlds) do
        if self:_worldMatchesCampaign(world, campaign_data) then
            world:addCampaign(campaign_data)
        end
    end
end

--- Check if a world matches campaign criteria
-- @param world World instance
-- @param campaign_data Campaign configuration
-- @return true if matches
function Universe:_worldMatchesCampaign(world, campaign_data)
    -- Check world requirements
    if campaign_data.required_worlds then
        local world_found = false
        for _, required_world_id in ipairs(campaign_data.required_worlds) do
            if world.id == required_world_id then
                world_found = true
                break
            end
        end
        if not world_found then
            return false
        end
    end

    return true
end

--- Get active campaigns
-- @return Table of active campaign data
function Universe:getActiveCampaigns()
    return self.active_campaigns
end

--- Get current universe time
-- @return Current time in days
function Universe:getCurrentTime()
    return self.current_time
end

--- Get universe statistics
-- @return Table with universe statistics
function Universe:getStatistics()
    local stats = {
        total_worlds = #self.world_order,
        active_campaigns = 0,
        total_provinces = 0,
        total_countries = 0,
        total_regions = 0
    }

    for _, campaign_data in pairs(self.active_campaigns) do
        stats.active_campaigns = stats.active_campaigns + 1
    end

    for _, world in pairs(self.worlds) do
        local world_stats = world:getStatistics()
        stats.total_provinces = stats.total_provinces + (world_stats.provinces or 0)
        stats.total_countries = stats.total_countries + (world_stats.countries or 0)
        stats.total_regions = stats.total_regions + (world_stats.regions or 0)
    end

    return stats
end

--- Convert to string representation
-- @return String representation
function Universe:__tostring()
    return string.format("Universe{id='%s', name='%s', worlds=%d, time=%d}",
                        self.id, self.name, #self.world_order, self.current_time)
end

return Universe
