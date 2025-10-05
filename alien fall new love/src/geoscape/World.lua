--- World.lua
-- World system for Alien Fall
-- Manages single world with provinces, countries, regions and local updates

-- GROK: World manages single planetary system with provinces, countries, regions and isolated state
-- GROK: Handles local updates from universe, maintains world-specific rules and configurations
-- GROK: Key methods: addProvince(), getProvince(), advanceTime(), getStatistics()
-- GROK: Supports world scaling, tile maps, illumination cycles, and mission integration

local class = require 'lib.Middleclass'

World = class('World')

--- Initialize a new world
-- @param data The TOML data for this world
function World:initialize(data)
    self.id = data.id
    self.name = data.name or "Unknown World"
    self.description = data.description or ""

    -- World configuration and scaling
    self.config = data.config or {}
    self.scale = data.scale or {}

    -- Background and visual assets
    self.background = data.background or {}
    self.visual = data.visual or {}

    -- Geographic data
    self.provinces = {}  -- province_id -> Province instance
    self.countries = {}  -- country_id -> Country instance
    self.regions = {}    -- region_id -> Region instance
    self.portals = {}    -- portal_id -> Portal instance

    -- Globe tile map for pathfinding
    self.tile_map = data.tile_map or {}

    -- Time and illumination
    self.local_time = data.local_time or 0
    self.rotation_period = self.config.rotation_period or 24  -- hours
    self.current_rotation = data.current_rotation or 0

    -- Mission and activity data
    self.missions = {}  -- active missions
    self.campaigns = {} -- active campaigns

    -- Universe reference
    self.universe = nil

    -- Event bus
    self.event_bus = nil

    -- Detection system for mission detection mechanics
    self.detection_system = nil

    -- Validate data
    self:_validate()
end

--- Validate the world data
function World:_validate()
    assert(self.id, "World must have an id")
    assert(self.name, "World must have a name")
end

--- Set the universe reference
-- @param universe The Universe instance
function World:setUniverse(universe)
    self.universe = universe
    self.event_bus = universe.event_bus
end

--- Set the event bus
-- @param event_bus The event bus instance
function World:setEventBus(event_bus)
    self.event_bus = event_bus
end

--- Set the detection system
-- @param detection_system The DetectionSystem instance
function World:setDetectionSystem(detection_system)
    self.detection_system = detection_system
end

--- Add a province to the world
-- @param province The Province instance to add
function World:addProvince(province)
    assert(province.id, "Province must have an id")
    self.provinces[province.id] = province
    province:setWorld(self)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("world:province_added", {
            world_id = self.id,
            province_id = province.id
        })
    end
end

--- Add a country to the world
-- @param country The Country instance to add
function World:addCountry(country)
    assert(country.id, "Country must have an id")
    self.countries[country.id] = country
    country:setWorld(self)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("world:country_added", {
            world_id = self.id,
            country_id = country.id
        })
    end
end

--- Add a region to the world
-- @param region The Region instance to add
function World:addRegion(region)
    assert(region.id, "Region must have an id")
    self.regions[region.id] = region
    region:setWorld(self)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("world:region_added", {
            world_id = self.id,
            region_id = region.id
        })
    end
end

--- Add a portal to the world
-- @param portal The Portal instance to add
function World:addPortal(portal)
    assert(portal.id, "Portal must have an id")
    self.portals[portal.id] = portal

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("world:portal_added", {
            world_id = self.id,
            portal_id = portal.id
        })
    end
end

--- Get a province by ID
-- @param province_id The province ID
-- @return Province instance or nil
function World:getProvince(province_id)
    return self.provinces[province_id]
end

--- Get a country by ID
-- @param country_id The country ID
-- @return Country instance or nil
function World:getCountry(country_id)
    return self.countries[country_id]
end

--- Get a region by ID
-- @param region_id The region ID
-- @return Region instance or nil
function World:getRegion(region_id)
    return self.regions[region_id]
end

--- Get a portal by ID
-- @param portal_id The portal ID
-- @return Portal instance or nil
function World:getPortal(portal_id)
    return self.portals[portal_id]
end

--- Get all provinces
-- @return Table of province instances
function World:getProvinces()
    return self.provinces
end

--- Get all countries
-- @return Table of country instances
function World:getCountries()
    return self.countries
end

--- Get all regions
-- @return Table of region instances
function World:getRegions()
    return self.regions
end

--- Get provinces in a specific region
-- @param region_id The region ID
-- @return Array of province instances
function World:getProvincesInRegion(region_id)
    local result = {}
    for _, province in pairs(self.provinces) do
        if province.region_id == region_id then
            table.insert(result, province)
        end
    end
    return result
end

--- Get provinces in a specific country
-- @param country_id The country ID
-- @return Array of province instances
function World:getProvincesInCountry(country_id)
    local result = {}
    for _, province in pairs(self.provinces) do
        if province.country_id == country_id then
            table.insert(result, province)
        end
    end
    return result
end

--- Advance time on this world
-- @param days Number of days to advance
function World:advanceTime(days)
    self.local_time = self.local_time + days

    -- Update rotation for illumination
    self.current_rotation = (self.current_rotation + (days * 360 / self.rotation_period)) % 360

    -- Update all provinces
    for _, province in pairs(self.provinces) do
        province:advanceTime(days)
    end

    -- Update all countries
    for _, country in pairs(self.countries) do
        country:advanceTime(days)
    end

    -- Update all regions
    for _, region in pairs(self.regions) do
        region:advanceTime(days)
    end

    -- Update mission detection
    if self.detection_system then
        self.detection_system:updateDetection(self.missions, self.provinces)
    end

    -- Process world-specific events
    self:_processWorldEvents(days)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("world:time_advanced", {
            world_id = self.id,
            days = days,
            new_time = self.local_time
        })
    end
end

--- Process world-specific events
-- @param days Number of days passed
function World:_processWorldEvents(days)
    -- Handle world-specific campaign progression
    for campaign_id, campaign_data in pairs(self.campaigns) do
        -- Process campaign events based on local time
        self:_updateCampaign(campaign_id, campaign_data, days)
    end
end

--- Update a specific campaign
-- @param campaign_id The campaign ID
-- @param campaign_data The campaign data
-- @param days Days passed
function World:_updateCampaign(campaign_id, campaign_data, days)
    -- Campaign logic would be implemented here
    -- This is a placeholder for campaign progression mechanics
end

--- Add a campaign to this world
-- @param campaign_data The campaign configuration
function World:addCampaign(campaign_data)
    local campaign_id = campaign_data.id
    self.campaigns[campaign_id] = campaign_data

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("world:campaign_added", {
            world_id = self.id,
            campaign_id = campaign_id
        })
    end
end

--- Get pixel to kilometer conversion factor
-- @return Conversion factor (pixels per km)
function World:getPixelToKmRatio()
    return self.scale.pixel_to_km or 25  -- Default: 25 pixels = 1 km
end

--- Get world dimensions in pixels
-- @return width, height in pixels
function World:getDimensions()
    return self.visual.width or 1600, self.visual.height or 800
end

--- Get tile map dimensions
-- @return width, height in tiles
function World:getTileDimensions()
    return self.tile_map.width or 80, self.tile_map.height or 40
end

--- Convert pixel coordinates to tile coordinates
-- @param pixel_x X coordinate in pixels
-- @param pixel_y Y coordinate in pixels
-- @return tile_x, tile_y
function World:pixelToTile(pixel_x, pixel_y)
    local tile_width = self.tile_map.tile_width or 20
    local tile_height = self.tile_map.tile_height or 20

    local tile_x = math.floor(pixel_x / tile_width) + 1
    local tile_y = math.floor(pixel_y / tile_height) + 1

    return tile_x, tile_y
end

--- Convert tile coordinates to pixel coordinates
-- @param tile_x X coordinate in tiles
-- @param tile_y Y coordinate in tiles
-- @return pixel_x, pixel_y (center of tile)
function World:tileToPixel(tile_x, tile_y)
    local tile_width = self.tile_map.tile_width or 20
    local tile_height = self.tile_map.tile_height or 20

    local pixel_x = (tile_x - 1) * tile_width + tile_width / 2
    local pixel_y = (tile_y - 1) * tile_height + tile_height / 2

    return pixel_x, pixel_y
end

--- Get tile type at coordinates
-- @param tile_x X coordinate in tiles
-- @param tile_y Y coordinate in tiles
-- @return Tile type ("land", "water", "mountain", etc.)
function World:getTileType(tile_x, tile_y)
    if not self.tile_map.tiles then
        return "land"  -- Default
    end

    local tile_index = (tile_y - 1) * self.tile_map.width + tile_x
    return self.tile_map.tiles[tile_index] or "land"
end

--- Calculate distance between two provinces
-- @param province1 First province
-- @param province2 Second province
-- @param use_graph Use graph distance (true) or pixel distance (false)
-- @return Distance in appropriate units
function World:calculateDistance(province1, province2, use_graph)
    if use_graph then
        return self:calculateGraphDistance(province1, province2)
    else
        return self:calculatePixelDistance(province1, province2)
    end
end

--- Calculate pixel-based distance between provinces
-- @param province1 First province
-- @param province2 Second province
-- @return Distance in pixels
function World:calculatePixelDistance(province1, province2)
    local x1, y1 = province1:getCoordinates()
    local x2, y2 = province2:getCoordinates()

    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

--- Calculate graph-based distance between provinces
-- @param province1 First province
-- @param province2 Second province
-- @return Distance in graph units (simplified)
function World:calculateGraphDistance(province1, province2)
    -- This would implement proper pathfinding using the tile map
    -- For now, return pixel distance as approximation
    return self:calculatePixelDistance(province1, province2)
end

--- Get illumination at a province
-- @param province The province to check
-- @return Illumination level (0.0 to 1.0, where 1.0 is full daylight)
function World:getIlluminationAt(province)
    local longitude = province:getLongitude()

    -- Calculate day fraction based on rotation
    local day_fraction = (longitude + self.current_rotation) / 360
    day_fraction = day_fraction % 1

    -- Simple sinusoidal illumination
    local illumination = math.sin(day_fraction * 2 * math.pi)

    -- Clamp to [0, 1]
    return math.max(0, math.min(1, illumination))
end

--- Get current time of day
-- @param province The province to check
-- @return Time of day ("day", "dusk", "night")
function World:getTimeOfDayAt(province)
    local illumination = self:getIlluminationAt(province)

    if illumination > 0.7 then
        return "day"
    elseif illumination > 0.3 then
        return "dusk"
    else
        return "night"
    end
end

--- Get world statistics
-- @return Table with world statistics
function World:getStatistics()
    local stats = {
        provinces = 0,
        countries = 0,
        regions = 0,
        portals = 0,
        active_missions = 0,
        active_campaigns = 0
    }

    for _ in pairs(self.provinces) do stats.provinces = stats.provinces + 1 end
    for _ in pairs(self.countries) do stats.countries = stats.countries + 1 end
    for _ in pairs(self.regions) do stats.regions = stats.regions + 1 end
    for _ in pairs(self.portals) do stats.portals = stats.portals + 1 end
    for _ in pairs(self.campaigns) do stats.active_campaigns = stats.active_campaigns + 1 end

    -- Count active missions across all provinces
    for _, province in pairs(self.provinces) do
        stats.active_missions = stats.active_missions + province:getActiveMissionCount()
    end

    return stats
end

--- Calculate Euclidean distance between two provinces in kilometers
-- @param province1 First province
-- @param province2 Second province
-- @return Distance in kilometers
function World:getDistanceBetween(province1, province2)
    local x1, y1 = province1:getCoordinates()
    local x2, y2 = province2:getCoordinates()

    -- Calculate pixel distance
    local pixel_distance = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)

    -- Convert to kilometers using world scale
    local km_distance = pixel_distance * (self.scale.pixels_per_km or 0.025)  -- Default 25 pixels = 1 km

    return km_distance
end

--- Get provinces within radar range of a base
-- @param base_province The province containing the base
-- @param radar_range_km Radar range in kilometers
-- @return Array of provinces within range
function World:getProvincesInRadarRange(base_province, radar_range_km)
    local in_range = {}

    for _, province in pairs(self.provinces) do
        if province.id ~= base_province.id then
            local distance = self:getDistanceBetween(base_province, province)
            if distance <= radar_range_km then
                table.insert(in_range, {
                    province = province,
                    distance = distance
                })
            end
        end
    end

    -- Sort by distance
    table.sort(in_range, function(a, b) return a.distance < b.distance end)

    return in_range
end

--- Calculate craft operational range considering fuel and speed
-- @param craft The craft instance
-- @param base_province The base province
-- @param fuel_available Available fuel at base
-- @param speed_points_remaining Remaining speed points for the turn
-- @return Maximum range in kilometers, limiting factor ("fuel", "speed", or "range")
function World:getCraftOperationalRange(craft, base_province, fuel_available, speed_points_remaining)
    -- Get craft capabilities
    local max_range = craft:getMaxRange() or 1000  -- Default 1000km
    local fuel_efficiency = craft:getFuelEfficiency() or 0.5  -- Fuel units per km
    local speed_rating = craft:getSpeedRating() or 1

    -- Calculate fuel-limited range
    local fuel_range = fuel_available / fuel_efficiency

    -- Calculate speed-limited range (simplified - could be more complex)
    local speed_range = max_range * (speed_points_remaining / speed_rating)

    -- Find the limiting factor
    local actual_range = math.min(max_range, fuel_range, speed_range)

    local limiting_factor
    if actual_range == fuel_range then
        limiting_factor = "fuel"
    elseif actual_range == speed_range then
        limiting_factor = "speed"
    else
        limiting_factor = "range"
    end

    return actual_range, limiting_factor
end

--- Get provinces within craft operational range
-- @param craft The craft instance
-- @param base_province The base province
-- @param fuel_available Available fuel at base
-- @param speed_points_remaining Remaining speed points for the turn
-- @return Array of provinces within range, limiting factor
function World:getProvincesInCraftRange(craft, base_province, fuel_available, speed_points_remaining)
    local max_range, limiting_factor = self:getCraftOperationalRange(craft, base_province, fuel_available, speed_points_remaining)

    local in_range = {}

    for _, province in pairs(self.provinces) do
        if province.id ~= base_province.id then
            local distance = self:getDistanceBetween(base_province, province)
            if distance <= max_range then
                table.insert(in_range, {
                    province = province,
                    distance = distance
                })
            end
        end
    end

    -- Sort by distance
    table.sort(in_range, function(a, b) return a.distance < b.distance end)

    return in_range, limiting_factor
end

--- Convert to string representation
-- @return String representation
function World:__tostring()
    return string.format("World{id='%s', name='%s', provinces=%d, countries=%d, regions=%d}",
                        self.id, self.name,
                        self:getStatistics().provinces,
                        self:getStatistics().countries,
                        self:getStatistics().regions)
end

return World
