--- MissionSiteGenerator.lua
-- Mission site generation system for Alien Fall
-- Generates tactical mission sites based on UFO activity and world state

-- GROK: MissionSiteGenerator creates mission sites from UFO crashes, landings, and alien activity
-- GROK: Selects appropriate provinces, biomes, and terrain for tactical missions
-- GROK: Key methods: generateCrashSite(), generateLandingSite(), generateTerrorSite()
-- GROK: Links geoscape events to battlescape mission parameters

local class = require 'lib.Middleclass'

MissionSiteGenerator = class('MissionSiteGenerator')

--- Mission site types
MissionSiteGenerator.SiteType = {
    CRASH_SITE = "crash_site",
    LANDING_SITE = "landing_site",
    TERROR_SITE = "terror_site",
    ABDUCTION_SITE = "abduction_site",
    INFILTRATION_SITE = "infiltration_site",
    ALIEN_BASE = "alien_base",
    SUPPLY_SHIP = "supply_ship"
}

--- Initialize mission site generator
-- @param rng Random number generator
-- @param config Generator configuration
function MissionSiteGenerator:initialize(rng, config)
    self.rng = rng or love.math.newRandomGenerator()
    self.config = config or {}
    
    -- Site generation parameters
    self.min_distance_from_base = self.config.min_distance_from_base or 100
    self.max_sites_per_province = self.config.max_sites_per_province or 3
    
    -- Active mission sites
    self.active_sites = {}
    
    -- Event bus
    self.event_bus = nil
    
    -- World reference
    self.world = nil
    
    -- Telemetry
    self.telemetry = nil
end

--- Set world reference
-- @param world The World instance
function MissionSiteGenerator:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Set event bus
-- @param event_bus The event bus instance
function MissionSiteGenerator:setEventBus(event_bus)
    self.event_bus = event_bus
end

--- Set telemetry
-- @param telemetry The telemetry service
function MissionSiteGenerator:setTelemetry(telemetry)
    self.telemetry = telemetry
end

--- Generate crash site mission from UFO
-- @param ufo The crashed UFO
-- @return Mission site data
function MissionSiteGenerator:generateCrashSite(ufo)
    local province = self:_findNearestProvince(ufo.coordinates)
    
    if not province then
        return nil
    end
    
    local site = {
        id = self:_generateSiteId(),
        type = MissionSiteGenerator.SiteType.CRASH_SITE,
        ufo_id = ufo.id,
        ufo_type = ufo.type,
        ufo_size = ufo.size,
        province_id = province.id,
        world_id = self.world.id,
        coordinates = ufo.coordinates,
        biome_id = province.biome_id,
        terrain_type = self:_selectTerrainType(province),
        difficulty = self:_calculateDifficulty(ufo),
        expiry_time = os.time() + 86400,  -- 24 hours
        rewards = self:_calculateRewards(ufo, 1.5),  -- 1.5x for crash site
        enemy_count = self:_calculateEnemyCount(ufo, 0.7),  -- 70% crew survive
        map_size = self:_selectMapSize(ufo.size),
        time_limit = self:_calculateTimeLimit(MissionSiteGenerator.SiteType.CRASH_SITE),
        environment_effects = self:_getEnvironmentEffects(province),
        created_at = os.time()
    }
    
    table.insert(self.active_sites, site)
    
    if self.event_bus then
        self.event_bus:publish("mission:site_created", site)
    end
    
    if self.telemetry then
        self.telemetry:record("mission_site_generated", {
            type = site.type,
            difficulty = site.difficulty,
            province_id = province.id
        })
    end
    
    return site
end

--- Generate landing site mission from UFO
-- @param ufo The landed UFO
-- @return Mission site data
function MissionSiteGenerator:generateLandingSite(ufo)
    local province = self:_findNearestProvince(ufo.coordinates)
    
    if not province then
        return nil
    end
    
    local site = {
        id = self:_generateSiteId(),
        type = MissionSiteGenerator.SiteType.LANDING_SITE,
        ufo_id = ufo.id,
        ufo_type = ufo.type,
        ufo_size = ufo.size,
        province_id = province.id,
        world_id = self.world.id,
        coordinates = ufo.coordinates,
        biome_id = province.biome_id,
        terrain_type = self:_selectTerrainType(province),
        difficulty = self:_calculateDifficulty(ufo),
        expiry_time = os.time() + 43200,  -- 12 hours
        rewards = self:_calculateRewards(ufo, 2.0),  -- 2x for landing site (intact UFO)
        enemy_count = self:_calculateEnemyCount(ufo, 1.0),  -- Full crew
        map_size = self:_selectMapSize(ufo.size),
        time_limit = self:_calculateTimeLimit(MissionSiteGenerator.SiteType.LANDING_SITE),
        environment_effects = self:_getEnvironmentEffects(province),
        ufo_intact = true,
        created_at = os.time()
    }
    
    table.insert(self.active_sites, site)
    
    if self.event_bus then
        self.event_bus:publish("mission:site_created", site)
    end
    
    if self.telemetry then
        self.telemetry:record("mission_site_generated", {
            type = site.type,
            difficulty = site.difficulty,
            province_id = province.id
        })
    end
    
    return site
end

--- Generate terror site mission
-- @param province Province where terror occurs
-- @param alien_force_size Size of alien force
-- @return Mission site data
function MissionSiteGenerator:generateTerrorSite(province, alien_force_size)
    local site = {
        id = self:_generateSiteId(),
        type = MissionSiteGenerator.SiteType.TERROR_SITE,
        province_id = province.id,
        world_id = self.world.id,
        coordinates = province.coordinates,
        biome_id = province.biome_id,
        terrain_type = "urban",  -- Terror sites are always urban
        difficulty = 3 + math.floor(alien_force_size / 10),
        expiry_time = os.time() + 21600,  -- 6 hours (urgent!)
        rewards = {
            money = 50000 + alien_force_size * 1000,
            materials = alien_force_size * 5,
            fame = 100,
            country_score = 50
        },
        enemy_count = alien_force_size,
        civilian_count = self.rng:random(10, 30),
        map_size = "large",
        time_limit = 50,  -- 50 turns
        environment_effects = {
            visibility = "high",
            cover = "abundant",
            hazards = {"fire", "panic"}
        },
        objectives = {
            primary = "eliminate_all_aliens",
            secondary = "save_civilians"
        },
        created_at = os.time()
    }
    
    table.insert(self.active_sites, site)
    
    if self.event_bus then
        self.event_bus:publish("mission:site_created", site)
        self.event_bus:publish("mission:terror_alert", {
            province_id = province.id,
            site_id = site.id
        })
    end
    
    if self.telemetry then
        self.telemetry:record("mission_site_generated", {
            type = site.type,
            difficulty = site.difficulty,
            province_id = province.id,
            urgent = true
        })
    end
    
    return site
end

--- Generate abduction site mission
-- @param province Province where abduction occurs
-- @param ufo UFO performing abduction
-- @return Mission site data
function MissionSiteGenerator:generateAbductionSite(province, ufo)
    local site = {
        id = self:_generateSiteId(),
        type = MissionSiteGenerator.SiteType.ABDUCTION_SITE,
        ufo_id = ufo.id,
        province_id = province.id,
        world_id = self.world.id,
        coordinates = ufo.coordinates,
        biome_id = province.biome_id,
        terrain_type = self:_selectTerrainType(province),
        difficulty = self:_calculateDifficulty(ufo),
        expiry_time = os.time() + 14400,  -- 4 hours
        rewards = self:_calculateRewards(ufo, 1.3),
        enemy_count = self:_calculateEnemyCount(ufo, 0.8),  -- Some crew on UFO
        civilian_count = self.rng:random(5, 15),
        map_size = self:_selectMapSize(ufo.size),
        time_limit = self:_calculateTimeLimit(MissionSiteGenerator.SiteType.ABDUCTION_SITE),
        environment_effects = self:_getEnvironmentEffects(province),
        objectives = {
            primary = "eliminate_aliens",
            secondary = "rescue_civilians"
        },
        created_at = os.time()
    }
    
    table.insert(self.active_sites, site)
    
    if self.event_bus then
        self.event_bus:publish("mission:site_created", site)
    end
    
    return site
end

--- Find nearest province to coordinates
-- @param coordinates {x, y}
-- @return Province instance or nil
function MissionSiteGenerator:_findNearestProvince(coordinates)
    if not self.world then
        return nil
    end
    
    local nearest_province = nil
    local min_distance = math.huge
    
    for _, province in pairs(self.world.provinces) do
        local dx = coordinates[1] - province.coordinates[1]
        local dy = coordinates[2] - province.coordinates[2]
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < min_distance then
            min_distance = distance
            nearest_province = province
        end
    end
    
    return nearest_province
end

--- Select terrain type based on province
-- @param province Province instance
-- @return Terrain type string
function MissionSiteGenerator:_selectTerrainType(province)
    if province.is_water then
        return "coastal"
    end
    
    local biome_terrains = {
        temperate = {"forest", "plains", "farmland"},
        tropical = {"jungle", "swamp", "plains"},
        arctic = {"snow", "ice", "tundra"},
        desert = {"desert", "rocky", "canyon"},
        forest = {"forest", "hills", "mountains"},
        mountain = {"mountains", "hills", "rocky"}
    }
    
    local terrains = biome_terrains[province.biome_id] or {"plains", "forest", "hills"}
    return terrains[self.rng:random(1, #terrains)]
end

--- Calculate mission difficulty
-- @param ufo UFO instance
-- @return Difficulty (1-5)
function MissionSiteGenerator:_calculateDifficulty(ufo)
    local size_difficulty = {
        small = 1,
        medium = 2,
        large = 3,
        very_large = 4
    }
    
    local base_difficulty = size_difficulty[ufo.size] or 2
    
    -- Add randomness
    local variance = self.rng:random(-1, 1)
    
    return math.max(1, math.min(5, base_difficulty + variance))
end

--- Calculate rewards
-- @param ufo UFO instance
-- @param multiplier Reward multiplier
-- @return Rewards table
function MissionSiteGenerator:_calculateRewards(ufo, multiplier)
    return {
        money = ufo.recovery_value * multiplier,
        materials = math.floor(ufo.crew_count * 10 * multiplier),
        alloys = math.floor(ufo.crew_count * 5 * multiplier),
        electronics = math.floor(ufo.crew_count * 3 * multiplier),
        fame = math.floor(20 * multiplier),
        country_score = math.floor(10 * multiplier)
    }
end

--- Calculate enemy count
-- @param ufo UFO instance
-- @param survival_rate Percentage of crew that survived
-- @return Enemy count
function MissionSiteGenerator:_calculateEnemyCount(ufo, survival_rate)
    return math.floor(ufo.crew_count * survival_rate)
end

--- Select map size
-- @param ufo_size UFO size
-- @return Map size string
function MissionSiteGenerator:_selectMapSize(ufo_size)
    local size_map = {
        small = "small",
        medium = "medium",
        large = "large",
        very_large = "very_large"
    }
    
    return size_map[ufo_size] or "medium"
end

--- Calculate time limit in turns
-- @param site_type Mission site type
-- @return Time limit in turns
function MissionSiteGenerator:_calculateTimeLimit(site_type)
    local limits = {
        crash_site = 30,
        landing_site = 40,
        terror_site = 50,
        abduction_site = 35,
        infiltration_site = 45,
        alien_base = 60,
        supply_ship = 40
    }
    
    return limits[site_type] or 30
end

--- Get environment effects for province
-- @param province Province instance
-- @return Environment effects table
function MissionSiteGenerator:_getEnvironmentEffects(province)
    local effects = {
        visibility = "normal",
        cover = "normal",
        hazards = {}
    }
    
    -- Biome-specific effects
    if province.biome_id == "arctic" then
        effects.hazards = {"cold", "ice"}
        effects.visibility = "reduced"
    elseif province.biome_id == "desert" then
        effects.hazards = {"heat"}
        effects.visibility = "high"
        effects.cover = "sparse"
    elseif province.biome_id == "tropical" then
        effects.hazards = {"disease"}
        effects.visibility = "reduced"
        effects.cover = "abundant"
    elseif province.biome_id == "forest" then
        effects.visibility = "reduced"
        effects.cover = "abundant"
    end
    
    return effects
end

--- Generate unique site ID
-- @return Site ID string
function MissionSiteGenerator:_generateSiteId()
    return string.format("site_%d_%d", 
                        os.time(), 
                        self.rng:random(1000, 9999))
end

--- Get active mission sites
-- @return Array of mission sites
function MissionSiteGenerator:getActiveSites()
    return self.active_sites
end

--- Remove expired sites
function MissionSiteGenerator:cleanupExpiredSites()
    local current_time = os.time()
    local i = 1
    
    while i <= #self.active_sites do
        local site = self.active_sites[i]
        
        if site.expiry_time and current_time >= site.expiry_time then
            table.remove(self.active_sites, i)
            
            if self.event_bus then
                self.event_bus:publish("mission:site_expired", {
                    site_id = site.id,
                    type = site.type
                })
            end
        else
            i = i + 1
        end
    end
end

--- Get site by ID
-- @param site_id Site ID
-- @return Mission site or nil
function MissionSiteGenerator:getSite(site_id)
    for _, site in ipairs(self.active_sites) do
        if site.id == site_id then
            return site
        end
    end
    return nil
end

--- Remove site (mission completed or cancelled)
-- @param site_id Site ID
function MissionSiteGenerator:removeSite(site_id)
    for i, site in ipairs(self.active_sites) do
        if site.id == site_id then
            table.remove(self.active_sites, i)
            
            if self.event_bus then
                self.event_bus:publish("mission:site_removed", {
                    site_id = site_id
                })
            end
            
            return true
        end
    end
    
    return false
end

--- Get generator state
-- @return Table with generator state
function MissionSiteGenerator:getState()
    return {
        active_site_count = #self.active_sites,
        sites_by_type = self:_countSitesByType()
    }
end

--- Count sites by type
-- @return Table with counts per type
function MissionSiteGenerator:_countSitesByType()
    local counts = {}
    
    for _, site in ipairs(self.active_sites) do
        counts[site.type] = (counts[site.type] or 0) + 1
    end
    
    return counts
end

return MissionSiteGenerator
