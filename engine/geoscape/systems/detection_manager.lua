--[[
    Detection Manager
    Manages radar scanning from bases and crafts to detect hidden missions.
    
    Core Responsibilities:
    - Perform daily radar scans from all player bases
    - Perform daily radar scans from all player crafts
    - Calculate radar power and range from facilities/equipment
    - Reduce mission cover based on radar effectiveness
    - Track detection events
    
    Radar Mechanics:
    - Each base/craft has radar power and range
    - Radar effectiveness decreases with distance
    - Cover reduction = radar power × distance effectiveness
    - When mission cover reaches 0, it's detected
    
    Base Radar Types:
    - Small Radar: Power 20, Range 5 provinces
    - Large Radar: Power 50, Range 10 provinces
    - Hyperwave Decoder: Power 100, Range 20 provinces
    
    Craft Radar Types:
    - Basic Radar: Power 10, Range 3 provinces
    - Advanced Radar: Power 25, Range 7 provinces
]]

local DetectionManager = {}

--[[
    Initialize detection manager
]]
function DetectionManager:init()
    print("[Detection] Initializing Detection Manager...")
    
    self.scanHistory = {}  -- Track scan results by day
    self.totalScansPerformed = 0
    self.totalMissionsDetected = 0
    self.debugMode = false
    
    print("[Detection] Detection Manager ready")
end

--[[
    Perform daily radar scans from all bases and crafts
    Called once per turn by Geoscape or CampaignManager
    
    @param campaignManager CampaignManager instance
    @param baseManager BaseManager instance (optional, for future integration)
    @param craftManager CraftManager instance (optional, for future integration)
    @return table Scan results with keys: scansPerformed, missionsDetected, newDetections
]]
function DetectionManager:performDailyScans(campaignManager, baseManager, craftManager)
    print("[Detection] Performing daily radar scans...")
    
    local results = {
        scansPerformed = 0,
        missionsDetected = 0,
        newDetections = {},
    }
    
    -- Get active missions
    local missions = campaignManager:getActiveMissions()
    if #missions == 0 then
        print("[Detection] No active missions to scan for")
        return results
    end
    
    -- For now, simulate scanning until BaseManager/CraftManager exist
    -- TODO: Replace with actual base/craft scanning when those systems are ready
    local mockBases = self:getMockBases()
    local mockCrafts = self:getMockCrafts()
    
    -- Scan from bases
    for _, base in ipairs(mockBases) do
        local detected = self:scanFromBase(base, missions, campaignManager.currentDay)
        results.scansPerformed = results.scansPerformed + 1
        results.missionsDetected = results.missionsDetected + detected.count
        
        for _, mission in ipairs(detected.missions) do
            table.insert(results.newDetections, mission)
        end
    end
    
    -- Scan from crafts
    for _, craft in ipairs(mockCrafts) do
        local detected = self:scanFromCraft(craft, missions, campaignManager.currentDay)
        results.scansPerformed = results.scansPerformed + 1
        results.missionsDetected = results.missionsDetected + detected.count
        
        for _, mission in ipairs(detected.missions) do
            table.insert(results.newDetections, mission)
        end
    end
    
    self.totalScansPerformed = self.totalScansPerformed + results.scansPerformed
    self.totalMissionsDetected = self.totalMissionsDetected + #results.newDetections
    
    print(string.format("[Detection] Scans: %d, New detections: %d", 
        results.scansPerformed, #results.newDetections))
    
    return results
end

--[[
    Scan for missions from a base
    
    @param base table Base with radar facilities
    @param missions table List of missions to scan
    @param currentDay number Current game day
    @return table Detection results {count, missions}
]]
function DetectionManager:scanFromBase(base, missions, currentDay)
    local radarPower = self:getBaseRadarPower(base)
    local radarRange = self:getBaseRadarRange(base)
    
    if radarPower == 0 or radarRange == 0 then
        return {count = 0, missions = {}}
    end
    
    if self.debugMode then
        print(string.format("[Detection] Base '%s': Power %d, Range %d", 
            base.name, radarPower, radarRange))
    end
    
    return self:performScan(base.position, radarPower, radarRange, missions, currentDay, "base")
end

--[[
    Scan for missions from a craft
    
    @param craft table Craft with radar equipment
    @param missions table List of missions to scan
    @param currentDay number Current game day
    @return table Detection results {count, missions}
]]
function DetectionManager:scanFromCraft(craft, missions, currentDay)
    local radarPower = self:getCraftRadarPower(craft)
    local radarRange = self:getCraftRadarRange(craft)
    
    if radarPower == 0 or radarRange == 0 then
        return {count = 0, missions = {}}
    end
    
    if self.debugMode then
        print(string.format("[Detection] Craft '%s': Power %d, Range %d", 
            craft.name, radarPower, radarRange))
    end
    
    return self:performScan(craft.position, radarPower, radarRange, missions, currentDay, "craft")
end

--[[
    Perform radar scan from a position
    
    @param scannerPosition table Position {x, y}
    @param radarPower number Radar power value
    @param radarRange number Maximum range in distance units
    @param missions table List of missions to scan
    @param currentDay number Current game day
    @param scannerType string "base" or "craft"
    @return table Detection results {count, missions}
]]
function DetectionManager:performScan(scannerPosition, radarPower, radarRange, missions, currentDay, scannerType)
    local detected = {
        count = 0,
        missions = {},
    }
    
    for _, mission in ipairs(missions) do
        -- Skip already detected missions
        if not mission.detected then
            -- Calculate distance to mission
            local distance = self:calculateDistance(scannerPosition, mission.position)
            
            -- Check if mission is in range
            if distance <= radarRange then
                -- Calculate cover reduction based on distance effectiveness
                local coverReduction = self:calculateCoverReduction(radarPower, distance, radarRange)
                
                -- Apply reduction to mission
                local previousCover = mission.coverValue
                mission:reduceCover(coverReduction)
                
                -- Check if mission was newly detected
                if mission.detected and previousCover > 0 then
                    detected.count = detected.count + 1
                    table.insert(detected.missions, mission)
                    
                    print(string.format("[Detection] %s detected mission '%s' at distance %.1f", 
                        scannerType, mission.name, distance))
                elseif self.debugMode and mission.coverValue < previousCover then
                    print(string.format("[Detection] Reduced cover of '%s' from %d to %d (distance %.1f)", 
                        mission.name, previousCover, mission.coverValue, distance))
                end
            end
        end
    end
    
    return detected
end

--[[
    Calculate distance between two positions
    
    @param pos1 table Position {x, y}
    @param pos2 table Position {x, y}
    @return number Distance
]]
function DetectionManager:calculateDistance(pos1, pos2)
    -- Simple Euclidean distance
    -- TODO: Replace with province graph pathfinding when World system exists
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

--[[
    Calculate cover reduction based on radar power and distance
    
    @param radarPower number Radar power
    @param distance number Distance to target
    @param maxRange number Maximum radar range
    @return number Cover reduction amount
]]
function DetectionManager:calculateCoverReduction(radarPower, distance, maxRange)
    -- Radar effectiveness decreases linearly with distance
    local effectiveness = 1.0 - (distance / maxRange)
    effectiveness = math.max(0, effectiveness)
    
    -- Cover reduction = power × effectiveness
    local reduction = radarPower * effectiveness
    
    return reduction
end

--[[
    Get total radar power from base facilities
    
    @param base table Base with facilities list
    @return number Total radar power
]]
function DetectionManager:getBaseRadarPower(base)
    local totalPower = 0
    
    if not base.facilities then
        return 0
    end
    
    -- Sum power from all radar facilities
    for _, facility in ipairs(base.facilities) do
        if facility.type == "radar_small" then
            totalPower = totalPower + 20
        elseif facility.type == "radar_large" then
            totalPower = totalPower + 50
        elseif facility.type == "radar_hyperwave" then
            totalPower = totalPower + 100
        end
    end
    
    return totalPower
end

--[[
    Get maximum radar range from base facilities
    
    @param base table Base with facilities list
    @return number Maximum radar range
]]
function DetectionManager:getBaseRadarRange(base)
    local maxRange = 0
    
    if not base.facilities then
        return 0
    end
    
    -- Take maximum range from all radar facilities
    for _, facility in ipairs(base.facilities) do
        if facility.type == "radar_small" then
            maxRange = math.max(maxRange, 5)  -- 5 distance units
        elseif facility.type == "radar_large" then
            maxRange = math.max(maxRange, 10)
        elseif facility.type == "radar_hyperwave" then
            maxRange = math.max(maxRange, 20)
        end
    end
    
    return maxRange
end

--[[
    Get total radar power from craft equipment
    
    @param craft table Craft with equipment list
    @return number Total radar power
]]
function DetectionManager:getCraftRadarPower(craft)
    local totalPower = 0
    
    if not craft.equipment then
        return 0
    end
    
    -- Sum power from radar equipment
    for _, item in ipairs(craft.equipment) do
        if item.type == "craft_radar_basic" then
            totalPower = totalPower + 10
        elseif item.type == "craft_radar_advanced" then
            totalPower = totalPower + 25
        end
    end
    
    return totalPower
end

--[[
    Get maximum radar range from craft equipment
    
    @param craft table Craft with equipment list
    @return number Maximum radar range
]]
function DetectionManager:getCraftRadarRange(craft)
    local maxRange = 0
    
    if not craft.equipment then
        return 0
    end
    
    -- Take maximum range from radar equipment
    for _, item in ipairs(craft.equipment) do
        if item.type == "craft_radar_basic" then
            maxRange = math.max(maxRange, 3)  -- 3 distance units
        elseif item.type == "craft_radar_advanced" then
            maxRange = math.max(maxRange, 7)
        end
    end
    
    return maxRange
end

--[[
    Get mock bases for testing until BaseManager exists
    TODO: Remove when BaseManager is implemented
    
    @return table List of mock bases
]]
function DetectionManager:getMockBases()
    return {
        {
            name = "HQ Base",
            position = {x = 50, y = 50},
            facilities = {
                {type = "radar_large"},
            },
        },
    }
end

--[[
    Get mock crafts for testing until CraftManager exists
    TODO: Remove when CraftManager is implemented
    
    @return table List of mock crafts
]]
function DetectionManager:getMockCrafts()
    return {
        {
            name = "Interceptor-1",
            position = {x = 60, y = 60},
            equipment = {
                {type = "craft_radar_basic"},
            },
        },
    }
end

--[[
    Get detection statistics
    
    @return table Statistics
]]
function DetectionManager:getStatistics()
    return {
        totalScansPerformed = self.totalScansPerformed,
        totalMissionsDetected = self.totalMissionsDetected,
    }
end

--[[
    Print detection status to console
]]
function DetectionManager:printStatus()
    local stats = self:getStatistics()
    print(string.format("[Detection] Total scans: %d, Total detections: %d", 
        stats.totalScansPerformed, stats.totalMissionsDetected))
end

--[[
    Draw radar coverage visualization (for Geoscape debug view)
    TODO: Implement when Geoscape rendering is integrated
    
    @param bases table List of bases
    @param crafts table List of crafts
]]
function DetectionManager:drawRadarCoverage(bases, crafts)
    if not self.debugMode then
        return
    end
    
    -- Draw base radar ranges
    love.graphics.setColor(0, 1, 0, 0.2)
    for _, base in ipairs(bases) do
        local range = self:getBaseRadarRange(base)
        if range > 0 then
            local x, y = base.position.x * 10, base.position.y * 10
            local radius = range * 10
            love.graphics.circle("fill", x, y, radius)
        end
    end
    
    -- Draw craft radar ranges
    love.graphics.setColor(0, 0, 1, 0.2)
    for _, craft in ipairs(crafts) do
        local range = self:getCraftRadarRange(craft)
        if range > 0 then
            local x, y = craft.position.x * 10, craft.position.y * 10
            local radius = range * 10
            love.graphics.circle("fill", x, y, radius)
        end
    end
end

return DetectionManager
