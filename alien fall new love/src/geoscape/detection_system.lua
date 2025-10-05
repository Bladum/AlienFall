--- DetectionSystem.lua
-- Detection system service for Alien Fall geoscape system
-- Handles sensor coverage, detection mechanics, and surveillance systems

local class = require 'lib.Middleclass'

DetectionSystem = class('DetectionSystem')

--- Initialize a new DetectionSystem instance
-- @param registry Service registry for accessing other systems
-- @return DetectionSystem instance
function DetectionSystem:initialize(registry)
    self.registry = registry

    -- Detection sources (radars, satellites, etc.)
    self.detection_sources = {}  -- source_id -> source_data

    -- Coverage cache
    self.coverage_cache = {}  -- province_id -> coverage_data
    self.cache_valid = false

    -- Detection state
    self.detected_missions = {}  -- mission_id -> detection_data

    -- Sensor types and their properties
    self.sensor_types = {
        radar = {
            range_km = 500,
            accuracy = 0.8,
            environmental_modifier = 1.2,
            power_cost = 10
        },
        satellite = {
            range_km = 2000,
            accuracy = 0.6,
            environmental_modifier = 1.5,
            power_cost = 25
        },
        visual = {
            range_km = 50,
            accuracy = 0.9,
            environmental_modifier = 0.8,
            power_cost = 2
        },
        seismic = {
            range_km = 300,
            accuracy = 0.7,
            environmental_modifier = 2.0,
            power_cost = 8
        }
    }

    -- Register with service registry
    if registry then
        registry:registerService('detectionSystem', self)
    end
end

--- Add a detection source
-- @param source_id Unique identifier for the source
-- @param source_data Source configuration
function DetectionSystem:addDetectionSource(source_id, source_data)
    self.detection_sources[source_id] = {
        id = source_id,
        type = source_data.type or "radar",
        position = source_data.position or {0, 0},
        range_km = source_data.range_km or self.sensor_types[source_data.type or "radar"].range_km,
        accuracy = source_data.accuracy or self.sensor_types[source_data.type or "radar"].accuracy,
        active = source_data.active ~= false,
        province_id = source_data.province_id,
        base_id = source_data.base_id
    }

    self.cache_valid = false
end

--- Remove a detection source
-- @param source_id Source to remove
function DetectionSystem:removeDetectionSource(source_id)
    self.detection_sources[source_id] = nil
    self.cache_valid = false
end

--- Get all detection sources
-- @return Table of source_id -> source_data
function DetectionSystem:getDetectionSources()
    return self.detection_sources
end

--- Calculate detection coverage for all provinces
-- @return Table of province_id -> coverage_data
function DetectionSystem:calculateCoverage()
    if self.cache_valid then
        return self.coverage_cache
    end

    local worldModel = self.registry:getService('worldModel')
    if not worldModel then return {} end

    local provinces = worldModel:getAllProvinces()
    local coverage = {}

    for province_id, province in pairs(provinces) do
        coverage[province_id] = self:_calculateProvinceCoverage(province)
    end

    self.coverage_cache = coverage
    self.cache_valid = true

    return coverage
end

--- Calculate coverage for a specific province
-- @param province Province instance
-- @return Coverage data table
function DetectionSystem:_calculateProvinceCoverage(province)
    local coverage = {
        total_coverage = 0,
        sources = {},
        effective_range = 0,
        detection_chance = 0,
        accuracy = 0
    }

    local province_x, province_y = unpack(province.coordinates)

    for source_id, source in pairs(self.detection_sources) do
        if source.active then
            local distance = self:_calculateDistance(province_x, province_y, source.position[1], source.position[2])
            local range_km = self:_convertPixelsToKm(distance, province.world_id)

            if range_km <= source.range_km then
                -- Calculate coverage contribution
                local coverage_factor = 1.0 - (range_km / source.range_km)
                local environmental_modifier = self:_getEnvironmentalModifier(source.type, province)
                local effective_coverage = coverage_factor * environmental_modifier

                if effective_coverage > 0 then
                    table.insert(coverage.sources, {
                        source_id = source_id,
                        distance_km = range_km,
                        coverage_factor = effective_coverage,
                        accuracy = source.accuracy
                    })

                    coverage.total_coverage = coverage.total_coverage + effective_coverage
                end
            end
        end
    end

    -- Normalize and calculate final metrics
    coverage.total_coverage = math.min(1.0, coverage.total_coverage)
    coverage.detection_chance = coverage.total_coverage * 0.9  -- 90% max detection chance

    -- Calculate weighted accuracy
    if #coverage.sources > 0 then
        local total_weight = 0
        local weighted_accuracy = 0

        for _, source_data in ipairs(coverage.sources) do
            local weight = source_data.coverage_factor
            total_weight = total_weight + weight
            weighted_accuracy = weighted_accuracy + (source_data.accuracy * weight)
        end

        coverage.accuracy = weighted_accuracy / total_weight
    end

    return coverage
end

--- Calculate distance between two points
-- @param x1 First point X
-- @param y1 First point Y
-- @param x2 Second point X
-- @param y2 Second point Y
-- @return Distance in pixels
function DetectionSystem:_calculateDistance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

--- Convert pixel distance to kilometers
-- @param pixel_distance Distance in pixels
-- @param world_id World identifier
-- @return Distance in kilometers
function DetectionSystem:_convertPixelsToKm(pixel_distance, world_id)
    local worldModel = self.registry:getService('worldModel')
    if worldModel then
        local world = worldModel:getWorld(world_id)
        if world and world.config.pixel_to_km then
            return pixel_distance / world.config.pixel_to_km
        end
    end

    return pixel_distance / 25  -- Default conversion
end

--- Get environmental modifier for sensor type and province
-- @param sensor_type Type of sensor
-- @param province Province instance
-- @return Modifier value
function DetectionSystem:_getEnvironmentalModifier(sensor_type, province)
    local base_modifier = self.sensor_types[sensor_type].environmental_modifier or 1.0

    -- Province-specific modifiers
    if province.is_water and sensor_type == "radar" then
        base_modifier = base_modifier * 0.7  -- Radar less effective over water
    elseif province.biome_id == "mountain" and sensor_type == "visual" then
        base_modifier = base_modifier * 0.5  -- Visual detection reduced in mountains
    elseif province.biome_id == "desert" and sensor_type == "satellite" then
        base_modifier = base_modifier * 1.3  -- Satellites better in clear desert conditions
    elseif province.biome_id == "urban" and sensor_type == "seismic" then
        base_modifier = base_modifier * 0.3  -- Seismic sensors overwhelmed in cities
    end

    -- Time of day modifier (simplified)
    local time_modifier = self:_getTimeOfDayModifier(sensor_type)
    base_modifier = base_modifier * time_modifier

    return base_modifier
end

--- Get time of day modifier for sensor type
-- @param sensor_type Type of sensor
-- @return Time modifier
function DetectionSystem:_getTimeOfDayModifier(sensor_type)
    -- Simplified: assume some time-based variation
    -- In full implementation, this would check actual illumination
    if sensor_type == "visual" then
        return math.random() < 0.5 and 0.6 or 1.2  -- Visual worse at night
    elseif sensor_type == "satellite" then
        return 1.0  -- Satellites not affected by day/night
    else
        return 0.9 + math.random() * 0.2  -- Slight random variation
    end
end

--- Check if a mission can be detected
-- @param mission_id Mission to check
-- @return True if mission is detected
function DetectionSystem:checkMissionDetection(mission_id)
    local missionScheduler = self.registry:getService('missionScheduler')
    if not missionScheduler then return false end

    local mission = missionScheduler:getMission(mission_id)
    if not mission then return false end

    local worldModel = self.registry:getService('worldModel')
    if not worldModel then return false end

    local province = worldModel:getProvince(mission.province_id)
    if not province then return false end

    -- Get coverage for province
    local coverage = self:calculateCoverage()[province.id]
    if not coverage then return false end

    -- Check detection chance
    local detection_roll = math.random()
    local detected = detection_roll < coverage.detection_chance

    if detected then
        -- Record detection
        self.detected_missions[mission_id] = {
            detection_time = self:_getCurrentTime(),
            coverage = coverage,
            accuracy = coverage.accuracy
        }

        -- Emit event
        local eventBus = self.registry:getService('event_bus')
        if eventBus then
            eventBus:emit('geoscape:mission_detected', {
                mission = mission,
                province = province,
                coverage = coverage
            })
        end
    end

    return detected
end

--- Get detected missions
-- @return Table of mission_id -> detection_data
function DetectionSystem:getDetectedMissions()
    return self.detected_missions
end

--- Check if mission is detected
-- @param mission_id Mission to check
-- @return True if mission is currently detected
function DetectionSystem:isMissionDetected(mission_id)
    return self.detected_missions[mission_id] ~= nil
end

--- Get detection data for mission
-- @param mission_id Mission identifier
-- @return Detection data or nil
function DetectionSystem:getMissionDetectionData(mission_id)
    return self.detected_missions[mission_id]
end

--- Update detection for all active missions
function DetectionSystem:updateDetection()
    local missionScheduler = self.registry:getService('missionScheduler')
    if not missionScheduler then return end

    local active_missions = missionScheduler:getActiveMissions()

    for mission_id, mission in pairs(active_missions) do
        if not self:isMissionDetected(mission_id) then
            self:checkMissionDetection(mission_id)
        end
    end
end

--- Calculate interception feasibility for a craft at a province
-- @param craft_data Craft data
-- @param province Province instance
-- @param base_province Province where craft is based
-- @return Feasibility data
function DetectionSystem:calculateInterceptionFeasibility(craft_data, province, base_province)
    local feasibility = {
        can_intercept = false,
        range_ok = false,
        fuel_ok = false,
        detection_ok = false,
        estimated_time = 0,
        fuel_cost = 0
    }

    -- Check range
    local distance = self:_calculateDistance(
        province.coordinates[1], province.coordinates[2],
        base_province.coordinates[1], base_province.coordinates[2]
    )
    local distance_km = self:_convertPixelsToKm(distance, province.world_id)

    local craft_operations = self:_getCraftOperations(craft_data.type)
    feasibility.range_ok = distance_km <= (craft_operations.max_range_km or 1000)

    if not feasibility.range_ok then
        return feasibility
    end

    -- Calculate fuel cost
    local fuel_per_km = craft_operations.fuel_consumption_per_km or 1.0
    feasibility.fuel_cost = distance_km * fuel_per_km

    -- Check fuel availability (simplified)
    feasibility.fuel_ok = true  -- Would check actual fuel levels

    -- Check detection
    local coverage = self:calculateCoverage()[province.id]
    feasibility.detection_ok = coverage and coverage.total_coverage > 0.1

    -- Calculate time
    local speed_kmh = craft_operations.speed_kmh or 500
    feasibility.estimated_time = distance_km / speed_kmh

    -- Overall feasibility
    feasibility.can_intercept = feasibility.range_ok and feasibility.fuel_ok and feasibility.detection_ok

    return feasibility
end

--- Get craft operations data
-- @param craft_type Type of craft
-- @return Operations data
function DetectionSystem:_getCraftOperations(craft_type)
    -- Load from data registry
    local dataRegistry = self.registry:getService('dataRegistry')
    if dataRegistry then
        local operations_data = dataRegistry:getData('geoscape/craft_operations')
        if operations_data and operations_data[craft_type] then
            return operations_data[craft_type]
        end
    end

    -- Default values
    return {
        max_range_km = 1000,
        fuel_consumption_per_km = 1.0,
        speed_kmh = 500
    }
end

--- Get current time
-- @return Current time in seconds
function DetectionSystem:_getCurrentTime()
    local timeService = self.registry:getService('timeService')
    if timeService then
        return timeService:getCurrentTime().turn * 86400
    end
    return 0
end

--- Get coverage heatmap data for visualization
-- @return Table of province_id -> coverage level (0-1)
function DetectionSystem:getCoverageHeatmap()
    local coverage = self:calculateCoverage()
    local heatmap = {}

    for province_id, coverage_data in pairs(coverage) do
        heatmap[province_id] = coverage_data.total_coverage
    end

    return heatmap
end

--- Invalidate coverage cache (call when detection sources change)
function DetectionSystem:invalidateCache()
    self.cache_valid = false
end

return DetectionSystem
