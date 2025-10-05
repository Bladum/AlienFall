--- Region.lua
-- Region system for Alien Fall
-- Groups provinces for narrative control, spawn weighting, and strategic gameplay

-- GROK: Region establishes hierarchical organization grouping provinces for spawn weighting and narrative
-- GROK: Manages faction preferences, mission filtering, and regional telemetry
-- GROK: Key methods: getProvinceIds(), adjustSpawnWeight(), getFactionPreference()
-- GROK: Handles region-scoped events, reports, and multiplayer scoring

local class = require 'lib.Middleclass'

Region = class('Region')

--- Initialize a new region
-- @param data The TOML data for this region
function Region:initialize(data)
    self.id = data.id
    self.name = data.name or "Unknown Region"
    self.description = data.description or ""

    -- Geographic composition
    self.province_ids = data.province_ids or {}

    -- Metadata
    self.classification = data.classification or {}  -- Tags like "Arctic", "Coastal", "Urban"
    self.world_id = data.world_id

    -- Spawn weighting system
    self.base_spawn_weight = data.base_spawn_weight or 1.0
    self.current_spawn_weight = self.base_spawn_weight
    self.spawn_modifiers = {}  -- Temporary modifiers

    -- Faction preferences
    self.faction_preferences = data.faction_preferences or {}

    -- Mission filtering
    self.allowed_mission_types = data.allowed_mission_types or data.allowed_missions or {}
    self.blocked_mission_types = data.blocked_mission_types or data.blocked_missions or {}

    -- Regional telemetry
    self.incident_count = 0
    self.resource_yield = 0
    self.public_score = 0

    -- World reference
    self.world = nil

    -- Event bus
    self.event_bus = nil

    -- Validate data
    self:_validate()
end

--- Validate the region data
function Region:_validate()
    assert(self.id, "Region must have an id")
    assert(self.name, "Region must have a name")
end

--- Set the world reference
-- @param world The World instance
function Region:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Add a province to this region
-- @param province The Province instance to add
function Region:addProvince(province)
    -- Add to province_ids if not already present
    local already_present = false
    for _, id in ipairs(self.province_ids) do
        if id == province.id then
            already_present = true
            break
        end
    end
    
    if not already_present then
        table.insert(self.province_ids, province.id)
    end
end

--- Get province IDs in this region
-- @return Array of province IDs
function Region:getProvinceIds()
    return self.province_ids
end

--- Get provinces in this region
-- @return Array of Province instances
function Region:getProvinces()
    if not self.world then
        return {}
    end

    local provinces = {}
    for _, province_id in ipairs(self.province_ids) do
        local province = self.world:getProvince(province_id)
        if province then
            table.insert(provinces, province)
        end
    end
    return provinces
end

--- Check if region contains a province
-- @param province_id The province ID to check
-- @return true if region contains the province
function Region:containsProvince(province_id)
    for _, id in ipairs(self.province_ids) do
        if id == province_id then
            return true
        end
    end
    return false
end

--- Get region classification tags
-- @return Array of classification tags
function Region:getClassification()
    return self.classification
end

--- Check if region has a specific classification
-- @param classification The classification to check
-- @return true if has classification
function Region:hasClassification(classification)
    for _, tag in ipairs(self.classification) do
        if tag == classification then
            return true
        end
    end
    return false
end

--- Get current spawn weight
-- @return Current spawn weight
function Region:getSpawnWeight()
    local weight = self.base_spawn_weight

    -- Apply temporary modifiers
    for _, modifier in pairs(self.spawn_modifiers) do
        weight = weight * modifier
    end

    return weight
end

--- Adjust spawn weight with a temporary modifier
-- @param modifier_id Unique ID for the modifier
-- @param multiplier Weight multiplier
-- @param duration Duration in days (nil for permanent)
function Region:adjustSpawnWeight(modifier_id, multiplier, duration)
    self.spawn_modifiers[modifier_id] = multiplier

    if duration then
        -- Schedule removal after duration
        self:_scheduleModifierRemoval(modifier_id, duration)
    end

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("region:spawn_weight_changed", {
            region_id = self.id,
            modifier_id = modifier_id,
            new_weight = self:getSpawnWeight()
        })
    end
end

--- Remove a spawn weight modifier
-- @param modifier_id The modifier ID to remove
function Region:removeSpawnWeightModifier(modifier_id)
    if self.spawn_modifiers[modifier_id] then
        self.spawn_modifiers[modifier_id] = nil

        -- Publish event
        if self.event_bus then
            self.event_bus:publish("region:spawn_weight_changed", {
                region_id = self.id,
                modifier_id = modifier_id,
                new_weight = self:getSpawnWeight()
            })
        end
    end
end

--- Schedule removal of a modifier
-- @param modifier_id The modifier ID
-- @param duration Duration in days
function Region:_scheduleModifierRemoval(modifier_id, duration)
    -- This would integrate with a timer system
    -- For now, we'll handle it in advanceTime
    self.spawn_modifiers[modifier_id .. "_timer"] = duration
end

--- Get faction preference for a specific faction
-- @param faction_id The faction ID
-- @return Preference multiplier (default 1.0)
function Region:getFactionPreference(faction_id)
    return self.faction_preferences[faction_id] or 1.0
end

--- Set faction preference
-- @param faction_id The faction ID
-- @param preference Preference multiplier
function Region:setFactionPreference(faction_id, preference)
    self.faction_preferences[faction_id] = preference
end

--- Check if mission type is allowed in this region
-- @param mission_type The mission type to check
-- @return true if allowed
function Region:isMissionTypeAllowed(mission_type)
    -- Check blocked list first
    for _, blocked in ipairs(self.blocked_mission_types) do
        if blocked == mission_type then
            return false
        end
    end

    -- If allowed list is specified, check it
    if #self.allowed_mission_types > 0 then
        for _, allowed in ipairs(self.allowed_mission_types) do
            if allowed == mission_type then
                return true
            end
        end
        return false
    end

    -- No restrictions
    return true
end

--- Alias for isMissionTypeAllowed (for test compatibility)
-- @param mission_type The mission type to check
-- @return true if allowed
function Region:isMissionAllowed(mission_type)
    return self:isMissionTypeAllowed(mission_type)
end

--- Get regional telemetry data
-- @return Table with telemetry data
function Region:getTelemetry()
    return {
        incident_count = self.incident_count,
        resource_yield = self.resource_yield,
        public_score = self.public_score,
        province_count = #self.province_ids,
        spawn_weight = self:getSpawnWeight()
    }
end

--- Record an incident in this region
-- @param incident_type Type of incident
function Region:recordIncident(incident_type)
    self.incident_count = self.incident_count + 1

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("region:incident_recorded", {
            region_id = self.id,
            incident_type = incident_type,
            total_incidents = self.incident_count
        })
    end
end

--- Record resource yield
-- @param amount Amount of resources yielded
function Region:recordResourceYield(amount)
    self.resource_yield = self.resource_yield + amount
end

--- Update public score
-- @param score_change Change in public score
function Region:updatePublicScore(score_change)
    self.public_score = self.public_score + score_change
end

--- Get aggregated statistics for the region
-- @return Table with aggregated statistics
function Region:getAggregatedStatistics()
    local provinces = self:getProvinces()
    local stats = {
        total_provinces = #provinces,
        total_economy = 0,
        total_population = 0,
        average_alien_activity = 0,
        player_controlled_provinces = 0,
        alien_controlled_provinces = 0,
        bases_present = 0,
        active_missions = 0
    }

    for _, province in ipairs(provinces) do
        stats.total_economy = stats.total_economy + province:getEconomyValue()
        stats.total_population = stats.total_population + province:getPopulation()
        stats.average_alien_activity = stats.average_alien_activity + province:getAlienActivity()

        if province:isPlayerControlled() then
            stats.player_controlled_provinces = stats.player_controlled_provinces + 1
        elseif province:isAlienControlled() then
            stats.alien_controlled_provinces = stats.alien_controlled_provinces + 1
        end

        if province.base_present then
            stats.bases_present = stats.bases_present + 1
        end

        stats.active_missions = stats.active_missions + province:getActiveMissionCount()
    end

    if stats.total_provinces > 0 then
        stats.average_alien_activity = stats.average_alien_activity / stats.total_provinces
    end

    return stats
end

--- Advance time for this region
-- @param days Number of days to advance
function Region:advanceTime(days)
    -- Process temporary modifier timers
    self:_updateModifierTimers(days)

    -- Update regional activity
    self:_updateRegionalActivity(days)
end

--- Update temporary modifier timers
-- @param days Days passed
function Region:_updateModifierTimers(days)
    local to_remove = {}

    for modifier_id, timer in pairs(self.spawn_modifiers) do
        if string.find(modifier_id, "_timer$") then
            local base_id = string.gsub(modifier_id, "_timer$", "")
            self.spawn_modifiers[modifier_id] = timer - days

            if self.spawn_modifiers[modifier_id] <= 0 then
                table.insert(to_remove, base_id)
                self.spawn_modifiers[modifier_id] = nil
            end
        end
    end

    -- Remove expired modifiers
    for _, modifier_id in ipairs(to_remove) do
        self:removeSpawnWeightModifier(modifier_id)
    end
end

--- Update regional activity
-- @param days Days passed
function Region:_updateRegionalActivity(days)
    -- Simple activity simulation
    local activity_change = (math.random() - 0.5) * 0.05 * days
    local provinces = self:getProvinces()

    for _, province in ipairs(provinces) do
        local new_activity = province:getAlienActivity() + activity_change
        province:setAlienActivity(new_activity)
    end
end

--- Get display information for UI
-- @return Table with display data
function Region:getDisplayInfo()
    local stats = self:getAggregatedStatistics()

    return {
        id = self.id,
        name = self.name,
        description = self.description,
        province_count = #self.province_ids,
        classification = self.classification,
        spawn_weight = self:getSpawnWeight(),
        telemetry = self:getTelemetry(),
        statistics = stats
    }
end

--- Convert to string representation
-- @return String representation
function Region:__tostring()
    return string.format("Region{id='%s', name='%s', provinces=%d, spawn_weight=%.2f}",
                        self.id, self.name, #self.province_ids, self:getSpawnWeight())
end

return Region
