--- Biome Class
-- Represents environmental biome types for world generation and mission creation
--
-- @classmod engine.world.Biome

local Biome = {}
Biome.__index = Biome

--- Create a new biome instance
-- @param data Biome data from TOML configuration
-- @return Biome instance
function Biome.new(data)
    local self = setmetatable({}, Biome)

    -- Basic biome properties
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""
    self.type = data.type or "natural"

    -- Properties from test data (for compatibility)
    self.properties = data.properties or {}

    -- Environmental properties
    self.environment = data.environment or {}
    self.temperature = self.properties.temperature or self.environment.temperature or 20
    self.humidity = self.environment.humidity or 50
    self.visibility = self.properties.visibility or self.environment.visibility or 1.0
    self.cover_density = self.environment.cover_density or 0.5

    -- Terrain properties
    self.terrain = data.terrain or {}
    self.movement_cost = self.terrain.movement_cost or 1.0
    self.elevation_range = self.terrain.elevation_range or {0, 100}
    self.surface_type = self.terrain.surface_type or "ground"

    -- Terrain selection (weighted list for mission generation)
    self.terrain_weights = data.terrain_weights or {}
    self.economy_urban_bonus = data.economy_urban_bonus or 0.25  -- Bonus chance for urban terrains in high-economy provinces
    self.economy_threshold = data.economy_threshold or 70  -- Economy value threshold for urban bonus

    -- Encounter properties
    self.encounter = data.encounter or {}
    self.spawn_multiplier = self.encounter.spawn_multiplier or 1.0
    self.alien_activity = self.properties.alien_activity or self.encounter.alien_activity or 0.5
    self.civilian_density = self.encounter.civilian_density or 0.3

    -- Set properties from test data
    self.population_density = self.properties.population_density or self.civilian_density
    self.infrastructure_level = self.properties.infrastructure_level or 0.5

    -- Economy properties
    self.economy = data.economy or {}

    -- Mission filtering
    self.mission_tags = data.mission_tags or {}  -- Tags that enable/disable mission types
    self.allowed_missions = data.allowed_missions or {}  -- Explicitly allowed mission types
    self.blocked_missions = data.blocked_missions or {}  -- Explicitly blocked mission types

    -- Visual properties
    self.visual = data.visual or {}
    self.color_scheme = self.visual.color_scheme or "default"
    self.texture_pattern = self.visual.texture_pattern or "default"
    self.lighting = self.visual.lighting or "natural"

    -- World-specific properties
    self.world_specific = data.world_specific or false
    self.required_world_type = data.required_world_type  -- World type this biome is specific to

    return self
end

--- Get environmental conditions for this biome
-- @return Table with environmental data
function Biome:get_environmental_conditions()
    return {
        temperature = self.temperature,
        humidity = self.humidity,
        visibility = self.visibility,
        cover_density = self.cover_density
    }
end

--- Get terrain properties for this biome
-- @return Table with terrain data
function Biome:get_terrain_properties()
    return {
        movement_cost = self.movement_cost,
        elevation_min = self.elevation_range[1],
        elevation_max = self.elevation_range[2],
        surface_type = self.surface_type
    }
end

--- Get encounter modifiers for this biome
-- @return Table with encounter data
function Biome:get_encounter_modifiers()
    return {
        spawn_multiplier = self.spawn_multiplier,
        alien_activity = self.alien_activity,
        civilian_density = self.civilian_density
    }
end

--- Get visual properties for this biome
-- @return Table with visual data
function Biome:get_visual_properties()
    return {
        color_scheme = self.color_scheme,
        texture_pattern = self.texture_pattern,
        lighting = self.lighting
    }
end

--- Select a terrain type for mission generation
-- @param province_economy The economy value of the province (affects urban bonus)
-- @param seed Random seed for deterministic selection
-- @return Selected terrain ID
function Biome:selectTerrain(province_economy, seed)
    math.randomseed(seed or os.time())

    -- Create weighted terrain list
    local terrains = {}
    local total_weight = 0

    for terrain_id, base_weight in pairs(self.terrain_weights) do
        local weight = base_weight

        -- Apply economy-driven urban bonus
        if province_economy and province_economy >= self.economy_threshold then
            if self:_isUrbanTerrain(terrain_id) then
                weight = weight * (1 + self.economy_urban_bonus)
            end
        end

        if weight > 0 then
            table.insert(terrains, {id = terrain_id, weight = weight})
            total_weight = total_weight + weight
        end
    end

    if total_weight <= 0 or #terrains == 0 then
        return "default_terrain"  -- Fallback
    end

    -- Weighted random selection
    local roll = math.random() * total_weight
    local cumulative = 0

    for _, terrain in ipairs(terrains) do
        cumulative = cumulative + terrain.weight
        if roll <= cumulative then
            return terrain.id
        end
    end

    return terrains[#terrains].id  -- Fallback to last terrain
end

--- Check if a terrain is considered "urban"
-- @param terrain_id The terrain ID to check
-- @return true if urban terrain
function Biome:_isUrbanTerrain(terrain_id)
    -- This would be configured in data, but for now use naming convention
    local urban_keywords = {"city", "urban", "village", "town", "suburb"}
    local lower_id = string.lower(terrain_id)

    for _, keyword in ipairs(urban_keywords) do
        if string.find(lower_id, keyword) then
            return true
        end
    end

    return false
end

--- Check if a mission type is allowed in this biome
-- @param mission_type The mission type to check
-- @return true if allowed
function Biome:isMissionAllowed(mission_type)
    -- Check blocked list first
    for _, blocked in ipairs(self.blocked_missions) do
        if blocked == mission_type then
            return false
        end
    end

    -- Check allowed list if specified
    if #self.allowed_missions > 0 then
        for _, allowed in ipairs(self.allowed_missions) do
            if allowed == mission_type then
                return true
            end
        end
        return false
    end

    -- Check mission tags
    for _, tag in ipairs(self.mission_tags) do
        if self:_missionTypeMatchesTag(mission_type, tag) then
            return true
        end
    end

    -- Default to allowed if no restrictions
    return #self.mission_tags == 0
end

--- Check if mission type matches a biome tag
-- @param mission_type The mission type
-- @param biome_tag The biome tag
-- @return true if matches
function Biome:_missionTypeMatchesTag(mission_type, biome_tag)
    -- Simple tag matching - could be more sophisticated
    local mission_lower = string.lower(mission_type)
    local tag_lower = string.lower(biome_tag)

    -- Direct match
    if mission_lower == tag_lower then
        return true
    end

    -- Tag-based matching
    if biome_tag == "ocean" and string.find(mission_lower, "naval") then
        return true
    elseif biome_tag == "urban" and string.find(mission_lower, "city") then
        return true
    elseif biome_tag == "arctic" and string.find(mission_lower, "cold") then
        return true
    end

    return false
end

--- Check if this biome is suitable for a given temperature range
-- @param min_temp Minimum temperature
-- @param max_temp Maximum temperature
-- @return true if suitable, false otherwise
function Biome:is_temperature_suitable(min_temp, max_temp)
    return self.temperature >= min_temp and self.temperature <= max_temp
end

--- Check if this biome is world-specific
-- @return true if world-specific
function Biome:isWorldSpecific()
    return self.world_specific
end

--- Check if this biome is suitable for a world type
-- @param world_type The world type to check
-- @return true if suitable
function Biome:isSuitableForWorld(world_type)
    if not self.world_specific then
        return true  -- Not world-specific, suitable for all
    end

    return self.required_world_type == world_type
end

--- Calculate movement cost modifier for a unit in this biome
-- @param unit_type The type of unit (infantry, vehicle, etc.)
-- @return Movement cost multiplier
function Biome:get_movement_modifier(unit_type)
    local base_modifier = self.movement_cost

    -- Apply unit-specific modifiers
    if unit_type == "vehicle" and self.surface_type == "sand" then
        base_modifier = base_modifier * 1.5  -- Vehicles struggle in sand
    elseif unit_type == "infantry" and self.surface_type == "forest" then
        base_modifier = base_modifier * 1.2  -- Infantry slowed by dense vegetation
    elseif unit_type == "ship" and self.surface_type ~= "water" then
        base_modifier = base_modifier * 100  -- Ships can't move on land
    end

    return base_modifier
end

--- Get cover bonus provided by this biome
-- @return Cover bonus value (0.0 to 1.0)
function Biome:get_cover_bonus()
    return self.cover_density
end

--- Get visibility modifier for this biome
-- @param time_of_day Current time of day (day, night, dusk)
-- @return Visibility multiplier
function Biome:get_visibility_modifier(time_of_day)
    local base_visibility = self.visibility

    -- Apply time-based modifiers
    if time_of_day == "night" then
        if self.lighting == "artificial" then
            base_visibility = base_visibility * 0.8  -- Urban areas have some light
        else
            base_visibility = base_visibility * 0.3  -- Natural darkness
        end
    elseif time_of_day == "dusk" then
        base_visibility = base_visibility * 0.7
    end

    return math.max(0.1, math.min(1.0, base_visibility))
end

--- Get display information for UI
-- @return Table with display data
function Biome:get_display_info()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        type = self.type,
        temperature = self.temperature,
        humidity = self.humidity,
        movement_cost = self.movement_cost,
        cover_density = self.cover_density,
        world_specific = self.world_specific,
        terrain_count = self:_countTerrains()
    }
end

--- Count available terrains
-- @return Number of terrains
function Biome:_countTerrains()
    local count = 0
    for _ in pairs(self.terrain_weights) do
        count = count + 1
    end
    return count
end

--- Get population density (alias for civilian_density for test compatibility)
-- @return Population density value
function Biome:getPopulationDensity()
    return self.population_density
end

--- Get infrastructure level
-- @return Infrastructure level value
function Biome:getInfrastructureLevel()
    return self.infrastructure_level
end

--- Get alien activity level
-- @return Alien activity value
function Biome:getAlienActivity()
    return self.alien_activity
end

--- Get terrain composition (alias for get_terrain_properties for test compatibility)
-- @return Table with terrain composition data
function Biome:getTerrainComposition()
    return {
        primary = self.terrain.primary,
        secondary = self.terrain.secondary,
        features = self.terrain.features or {}
    }
end

--- Generate random variation for this biome
-- @return Variation value between 0 and 1
function Biome:generateVariation()
    -- Use properties for variation calculation
    local base = self.properties.base_variation or 0.5
    local max_var = self.properties.max_variation or 0.2
    return base + (math.random() - 0.5) * max_var * 2
end

--- Get environmental effects (alias for get_environmental_conditions for test compatibility)
-- @return Table with environmental effects
function Biome:getEnvironmentalEffects()
    return {
        temperature = self.temperature,
        visibility = self.visibility,
        movement_penalty = self.properties.movement_penalty or self.environment.movement_penalty or 0.8,
        weather_events = self.environment.weather_events or {},
        environmental_hazards = self.environment.environmental_hazards or {}
    }
end

--- Generate resources for this biome
-- @param development_multiplier Development level multiplier
-- @return Table with generated resources
function Biome:generateResources(development_multiplier)
    development_multiplier = development_multiplier or 1.0
    local richness = self.properties.resource_richness or 0.8
    local base_yield = (self.economy.base_yield or 100) * richness
    return {
        minerals = base_yield * development_multiplier,
        rare_earths = base_yield * development_multiplier
    }
end

--- Get display information for UI
-- @return Table with display data
function Biome:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        population_density = self.population_density,
        infrastructure_level = self.infrastructure_level,
        alien_activity = self.alien_activity,
        terrain = self.terrain,
        economy = self.economy or {}
    }
end

--- Compare alien activity with another biome
-- @param other Another Biome instance
-- @return true if this biome has higher alien activity
function Biome:hasHigherAlienActivity(other)
    return self.alien_activity > other.alien_activity
end

--- Check if this biome equals another biome
-- @param other Another Biome instance
-- @return true if biomes are equal
function Biome:equals(other)
    return self.id == other.id and self.alien_activity == other.alien_activity
end

--- Trigger an environmental event
-- @param event_type Type of event to trigger
-- @return Event data table
function Biome:triggerEnvironmentalEvent(event_type)
    -- Publish event for test compatibility
    local event_data = {
        biome_id = self.id,
        event_type = event_type,
        timestamp = os.time()
    }
    if self.event_bus then
        self.event_bus:publish("biome:environmental_event", event_data)
    end
    -- Return event data for test compatibility
    return event_data
end

return Biome
