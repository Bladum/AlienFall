--- Detection System
-- Handles mission detection mechanics using radar facilities
--
-- @classmod systems.DetectionSystem

local PerformanceCache = require("utils.performance_cache")

local DetectionSystem = {}
DetectionSystem.__index = DetectionSystem

--- Create a new DetectionSystem instance
-- @param config Configuration options
-- @return DetectionSystem instance
function DetectionSystem.new(config)
    local self = setmetatable({}, DetectionSystem)
    config = config or {}

    -- Dependencies
    self.base_manager = config.base_manager
    self.logger = config.logger
    self.telemetry = config.telemetry
    
    -- Performance cache
    self.cache = config.cache or PerformanceCache()
    self.current_day = 0

    return self
end

--- Perform daily detection update for all missions
-- @param missions Table of active missions {mission_id -> mission}
-- @param provinces Table of provinces for location-based detection
function DetectionSystem:updateDetection(missions, provinces)
    if not self.base_manager then
        if self.logger then
            self.logger:warn("DetectionSystem: No base_manager available")
        end
        return
    end

    -- Get all radar facilities
    local radar_facilities = self.base_manager:getRadarFacilities()

    -- Process each mission
    for mission_id, mission in pairs(missions) do
        if mission.status == "available" and not mission:isDetected() then
            local total_detection_power = self:calculateDetectionPowerForMission(
                mission, radar_facilities, provinces
            )

            if total_detection_power > 0 then
                local was_detected = mission:applyDetection(total_detection_power)

                if was_detected and self.logger then
                    self.logger:info(string.format(
                        "Mission %s detected! Cover reduced to %.1f",
                        mission_id, mission:getCurrentCover()
                    ))
                end
            end
        end
    end
end

--- Calculate total detection power applied to a mission
-- @param mission Mission instance
-- @param radar_facilities Table of radar facilities from all bases
-- @param provinces Table of provinces for location data
-- @return number Total detection power applied to this mission
function DetectionSystem:calculateDetectionPowerForMission(mission, radar_facilities, provinces)
    local total_power = 0

    -- Find mission's province
    local mission_province = nil
    for province_id, province in pairs(provinces) do
        if province.missions and province.missions[mission.id] then
            mission_province = province
            break
        end
    end

    if not mission_province then
        return 0  -- Mission not found in any province
    end

    -- Calculate detection from each radar facility
    for base_id, base_radars in pairs(radar_facilities) do
        for facility_id, radar in pairs(base_radars) do
            local detection_power = self:calculateRadarDetectionPower(
                radar, mission_province, mission
            )
            total_power = total_power + detection_power
        end
    end

    return total_power
end

--- Calculate detection power from a specific radar facility
-- @param radar Radar facility data {power, range, position}
-- @param province Province containing the mission
-- @param mission Mission being detected
-- @return number Detection power from this radar
function DetectionSystem:calculateRadarDetectionPower(radar, province, mission)
    -- Check cache first
    local radar_id = radar.id or 0
    local mission_id = mission.id or 0
    local cached_power = self.cache:getDetection(mission_id, radar_id, self.current_day)
    if cached_power then
        return cached_power
    end
    
    -- Calculate distance between radar and province center
    local radar_pos = radar.position
    local province_pos = province.position or {x = 0, y = 0}

    local distance = self:calculateDistance(radar_pos, province_pos)

    -- Check if within detection range
    if distance > radar.range then
        self.cache:cacheDetection(mission_id, radar_id, 0, self.current_day)
        return 0
    end

    -- Base detection power (could be modified by terrain, weather, etc.)
    local base_power = radar.power

    -- Distance falloff (linear for now, could be more complex)
    local range_factor = 1.0 - (distance / radar.range)
    local effective_power = base_power * range_factor

    -- Cache the result
    self.cache:cacheDetection(mission_id, radar_id, effective_power, self.current_day)

    return effective_power
end

--- Calculate distance between two positions
-- @param pos1 First position {x, y}
-- @param pos2 Second position {x, y}
-- @return number Distance between positions
function DetectionSystem:calculateDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Get detection status summary for all missions
-- @param missions Table of missions
-- @return Table with detection statistics
function DetectionSystem:getDetectionSummary(missions)
    local summary = {
        total_missions = 0,
        detected_missions = 0,
        average_cover = 0,
        missions_by_cover_range = {
            high = 0,    -- cover > 75
            medium = 0,  -- 25 < cover <= 75
            low = 0,     -- 0 < cover <= 25
            detected = 0 -- cover <= 0
        }
    }

    local total_cover = 0

    for mission_id, mission in pairs(missions) do
        summary.total_missions = summary.total_missions + 1
        total_cover = total_cover + mission:getCurrentCover()

        if mission:isDetected() then
            summary.detected_missions = summary.detected_missions + 1
            summary.missions_by_cover_range.detected =
                summary.missions_by_cover_range.detected + 1
        else
            local cover = mission:getCurrentCover()
            if cover > 75 then
                summary.missions_by_cover_range.high =
                    summary.missions_by_cover_range.high + 1
            elseif cover > 25 then
                summary.missions_by_cover_range.medium =
                    summary.missions_by_cover_range.medium + 1
            else
                summary.missions_by_cover_range.low =
                    summary.missions_by_cover_range.low + 1
            end
        end
    end

    if summary.total_missions > 0 then
        summary.average_cover = total_cover / summary.total_missions
    end

    return summary
end

--- Update current day (for cache invalidation)
-- @param day Current game day
function DetectionSystem:setCurrentDay(day)
    self.current_day = day
end

--- Invalidate detection cache (call when radar facilities change)
function DetectionSystem:invalidateCache()
    self.cache:invalidateDetectionCache()
end

--- Get cache statistics
-- @return Table with cache performance statistics
function DetectionSystem:getCacheStatistics()
    return self.cache:getStatistics()
end

return DetectionSystem
