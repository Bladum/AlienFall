--- WorldModel.lua
-- World model service for Alien Fall geoscape system
-- Manages worlds, provinces, and their interactions

local class = require 'lib.Middleclass'
local World = require 'geoscape.World'
local Province = require 'geoscape.Province'
local Region = require 'geoscape.Region'
local Portal = require 'geoscape.Portal'

WorldModel = class('WorldModel')

--- Initialize a new WorldModel instance
-- @param registry Service registry for accessing other systems
-- @return WorldModel instance
function WorldModel:initialize(registry)
    self.registry = registry

    -- World storage
    self.worlds = {}  -- world_id -> World instance
    self.provinces = {}  -- province_id -> Province instance
    self.regions = {}  -- region_id -> Region instance
    self.portals = {}  -- portal_id -> Portal instance

    -- Current world
    self.current_world_id = nil

    -- Load data
    self:_loadWorldData()
    self:_loadProvinceData()
    self:_loadRegionData()
    self:_loadPortalData()

    -- Register with service registry
    if registry then
        registry:registerService('worldModel', self)
    end
end

--- Load world data from TOML files
function WorldModel:_loadWorldData()
    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    local world_data = dataRegistry:getData('geoscape/worlds')
    if not world_data then return end

    for world_id, data in pairs(world_data) do
        local world = World:new(data)
        self.worlds[world_id] = world
    end
end

--- Load province data from TOML files
function WorldModel:_loadProvinceData()
    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    local province_data = dataRegistry:getData('geoscape/provinces')
    if not province_data then return end

    for province_id, data in pairs(province_data) do
        local province = Province:new(data)
        self.provinces[province_id] = province

        -- Add to world if it exists
        if data.world_id and self.worlds[data.world_id] then
            self.worlds[data.world_id]:addProvince(province)
        end
    end
end

--- Load region data from TOML files
function WorldModel:_loadRegionData()
    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    local region_data = dataRegistry:getData('geoscape/regions')
    if not region_data then return end

    for region_id, data in pairs(region_data) do
        local region = Region:new(data)
        self.regions[region_id] = region
    end
end

--- Load portal data from TOML files
function WorldModel:_loadPortalData()
    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    local portal_data = dataRegistry:getData('geoscape/portals')
    if not portal_data then return end

    for portal_id, data in pairs(portal_data) do
        local portal = Portal:new(data)
        self.portals[portal_id] = portal

        -- Add to world if it exists
        if data.world_id and self.worlds[data.world_id] then
            self.worlds[data.world_id]:addPortal(portal)
        end
    end
end

--- Get a world by ID
-- @param world_id The world identifier
-- @return World instance or nil
function WorldModel:getWorld(world_id)
    return self.worlds[world_id]
end

--- Get all worlds
-- @return Table of world_id -> World instance
function WorldModel:getAllWorlds()
    return self.worlds
end

--- Get the current world
-- @return Current World instance or nil
function WorldModel:getCurrentWorld()
    return self.current_world_id and self.worlds[self.current_world_id]
end

--- Set the current world
-- @param world_id The world to set as current
function WorldModel:setCurrentWorld(world_id)
    if self.worlds[world_id] then
        self.current_world_id = world_id
    end
end

--- Get a province by ID
-- @param province_id The province identifier
-- @return Province instance or nil
function WorldModel:getProvince(province_id)
    return self.provinces[province_id]
end

--- Get all provinces
-- @return Table of province_id -> Province instance
function WorldModel:getAllProvinces()
    return self.provinces
end

--- Get provinces for a specific world
-- @param world_id The world identifier
-- @return Table of province_id -> Province instance
function WorldModel:getProvincesForWorld(world_id)
    local result = {}
    for province_id, province in pairs(self.provinces) do
        if province.world_id == world_id then
            result[province_id] = province
        end
    end
    return result
end

--- Get a region by ID
-- @param region_id The region identifier
-- @return Region instance or nil
function WorldModel:getRegion(region_id)
    return self.regions[region_id]
end

--- Get all regions
-- @return Table of region_id -> Region instance
function WorldModel:getAllRegions()
    return self.regions
end

--- Get a portal by ID
-- @param portal_id The portal identifier
-- @return Portal instance or nil
function WorldModel:getPortal(portal_id)
    return self.portals[portal_id]
end

--- Get all portals
-- @return Table of portal_id -> Portal instance
function WorldModel:getAllPortals()
    return self.portals
end

--- Get portals for a specific world
-- @param world_id The world identifier
-- @return Table of portal_id -> Portal instance
function WorldModel:getPortalsForWorld(world_id)
    local result = {}
    for portal_id, portal in pairs(self.portals) do
        if portal.world_id == world_id then
            result[portal_id] = portal
        end
    end
    return result
end

--- Find provinces within a certain distance of coordinates
-- @param center_x Center X coordinate
-- @param center_y Center Y coordinate
-- @param max_distance Maximum distance in pixels
-- @param world_id Optional world filter
-- @return Table of province_id -> Province instance within range
function WorldModel:findProvincesInRange(center_x, center_y, max_distance, world_id)
    local result = {}
    local max_distance_squared = max_distance * max_distance

    for province_id, province in pairs(self.provinces) do
        if not world_id or province.world_id == world_id then
            local dx = province.coordinates[1] - center_x
            local dy = province.coordinates[2] - center_y
            local distance_squared = dx * dx + dy * dy

            if distance_squared <= max_distance_squared then
                result[province_id] = province
            end
        end
    end

    return result
end

--- Find the nearest province to coordinates
-- @param x X coordinate
-- @param y Y coordinate
-- @param world_id Optional world filter
-- @return Nearest Province instance and distance, or nil
function WorldModel:findNearestProvince(x, y, world_id)
    local nearest = nil
    local min_distance_squared = math.huge

    for province_id, province in pairs(self.provinces) do
        if not world_id or province.world_id == world_id then
            local dx = province.coordinates[1] - x
            local dy = province.coordinates[2] - y
            local distance_squared = dx * dx + dy * dy

            if distance_squared < min_distance_squared then
                min_distance_squared = distance_squared
                nearest = province
            end
        end
    end

    if nearest then
        return nearest, math.sqrt(min_distance_squared)
    end

    return nil, nil
end

--- Get provinces that can host a base
-- @param world_id Optional world filter
-- @return Table of province_id -> Province instance that can host bases
function WorldModel:getBaseHostableProvinces(world_id)
    local result = {}

    for province_id, province in pairs(self.provinces) do
        if (not world_id or province.world_id == world_id) and
           province:canHostBase() then
            result[province_id] = province
        end
    end

    return result
end

--- Get provinces with active missions
-- @param world_id Optional world filter
-- @return Table of province_id -> Province instance with active missions
function WorldModel:getProvincesWithMissions(world_id)
    local result = {}

    for province_id, province in pairs(self.provinces) do
        if (not world_id or province.world_id == world_id) and
           next(province.active_missions) then
            result[province_id] = province
        end
    end

    return result
end

--- Calculate distance between two provinces
-- @param province1 First province (instance or ID)
-- @param province2 Second province (instance or ID)
-- @return Distance in pixels, or nil if provinces not found
function WorldModel:getDistanceBetweenProvinces(province1, province2)
    if type(province1) == "string" then
        province1 = self:getProvince(province1)
    end
    if type(province2) == "string" then
        province2 = self:getProvince(province2)
    end

    if not province1 or not province2 then
        return nil
    end

    local dx = province1.coordinates[1] - province2.coordinates[1]
    local dy = province1.coordinates[2] - province2.coordinates[2]
    return math.sqrt(dx * dx + dy * dy)
end

--- Get world statistics
-- @param world_id Optional specific world, or current world if nil
-- @return Table with world statistics
function WorldModel:getWorldStatistics(world_id)
    world_id = world_id or self.current_world_id
    local world = self:getWorld(world_id)
    if not world then return {} end

    local provinces = self:getProvincesForWorld(world_id)
    local portals = self:getPortalsForWorld(world_id)

    local stats = {
        total_provinces = 0,
        player_controlled_provinces = 0,
        alien_controlled_provinces = 0,
        neutral_provinces = 0,
        provinces_with_bases = 0,
        active_missions = 0,
        active_portals = 0,
        total_population = 0,
        total_economy = 0
    }

    for _, province in pairs(provinces) do
        stats.total_provinces = stats.total_provinces + 1
        stats.total_population = stats.total_population + province.population
        stats.total_economy = stats.total_economy + province.economy_value

        if province.controlled_by == "player" then
            stats.player_controlled_provinces = stats.player_controlled_provinces + 1
        elseif province.controlled_by == "alien" then
            stats.alien_controlled_provinces = stats.alien_controlled_provinces + 1
        else
            stats.neutral_provinces = stats.neutral_provinces + 1
        end

        if province.base_present then
            stats.provinces_with_bases = stats.provinces_with_bases + 1
        end

        if next(province.active_missions) then
            stats.active_missions = stats.active_missions + 1
        end
    end

    stats.active_portals = #portals

    return stats
end

return WorldModel
