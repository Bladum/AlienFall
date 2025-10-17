---DeploymentConfig - Mission deployment configuration
---
---Stores deployment information for a mission:
---  - Map size and structure
---  - Landing zones with spawn points
---  - Objective block locations
---  - Unit assignments to landing zones
---
---@module battlescape.logic.deployment_config
---@author AlienFall Development Team

local LandingZone = require("battlescape.logic.landing_zone")

local DeploymentConfig = {}

---Create a new deployment configuration
---@param data table Deployment data {missionId, mapSize, mapBlockGrid}
---@return table DeploymentConfig instance
function DeploymentConfig.new(data)
    return {
        missionId = data.missionId or "mission_unknown",
        mapSize = data.mapSize or "medium",  -- small, medium, large, huge
        mapBlockGrid = data.mapBlockGrid or 5,  -- 4-7 (grid dimensions)
        
        landingZones = data.landingZones or {},  -- Array of LandingZone
        objectiveBlocks = data.objectiveBlocks or {},  -- Array of objective metadata
        
        -- Unit roster
        availableUnits = data.availableUnits or {},
        deployedUnits = {},  -- Map: unit_id -> landing_zone_id
        
        -- State
        isComplete = data.isComplete or false,
    }
end

---Add landing zone
---@param config table The deployment config
---@param zone table LandingZone instance
function DeploymentConfig.addLandingZone(config, zone)
    table.insert(config.landingZones, zone)
end

---Add objective block
---@param config table The deployment config
---@param blockData table Objective block data {mapBlockIndex, objectiveType, position}
function DeploymentConfig.addObjectiveBlock(config, blockData)
    table.insert(config.objectiveBlocks, blockData)
end

---Assign unit to landing zone
---@param config table The deployment config
---@param unitId string Unit ID
---@param zoneId string Landing zone ID
---@return boolean success True if assigned
---@return string? error Error message if failed
function DeploymentConfig.assignUnitToZone(config, unitId, zoneId)
    -- Find landing zone
    local zone = nil
    for _, z in ipairs(config.landingZones) do
        if z.id == zoneId then
            zone = z
            break
        end
    end
    
    if not zone then
        return false, "Unknown landing zone: " .. zoneId
    end
    
    -- Add unit to zone
    LandingZone.addUnit(zone, unitId)
    config.deployedUnits[unitId] = zoneId
    
    return true, nil
end

---Remove unit from landing zone
---@param config table The deployment config
---@param unitId string Unit ID
---@return boolean success True if removed
function DeploymentConfig.removeUnitFromZone(config, unitId)
    local zoneId = config.deployedUnits[unitId]
    if not zoneId then
        return false
    end
    
    -- Find and remove from zone
    for _, zone in ipairs(config.landingZones) do
        if zone.id == zoneId then
            LandingZone.removeUnit(zone, unitId)
            config.deployedUnits[unitId] = nil
            return true
        end
    end
    
    return false
end

---Check if deployment is valid (all zones have units)
---@param config table The deployment config
---@return boolean valid True if valid
---@return string? error Error message if invalid
function DeploymentConfig.isValid(config)
    -- Check all zones have at least one unit
    for _, zone in ipairs(config.landingZones) do
        if LandingZone.isEmpty(zone) then
            return false, "Landing zone " .. zone.id .. " has no units"
        end
    end
    
    return true, nil
end

---Get all landing zones
---@param config table The deployment config
---@return table zones Array of LandingZone instances
function DeploymentConfig.getLandingZones(config)
    return config.landingZones
end

---Get objective blocks
---@param config table The deployment config
---@return table objectives Array of objective block data
function DeploymentConfig.getObjectiveBlocks(config)
    return config.objectiveBlocks
end

---Get landing zone by ID
---@param config table The deployment config
---@param zoneId string Landing zone ID
---@return table? zone LandingZone instance or nil
function DeploymentConfig.getLandingZone(config, zoneId)
    for _, zone in ipairs(config.landingZones) do
        if zone.id == zoneId then
            return zone
        end
    end
    return nil
end

---Get units in a landing zone
---@param config table The deployment config
---@param zoneId string Landing zone ID
---@return table unitIds Array of unit IDs
function DeploymentConfig.getUnitsInZone(config, zoneId)
    local zone = DeploymentConfig.getLandingZone(config, zoneId)
    if not zone then
        return {}
    end
    return LandingZone.getAssignedUnits(zone)
end

---Print deployment summary
---@param config table The deployment config
function DeploymentConfig.printSummary(config)
    print(string.format("\n[DeploymentConfig] Mission %s", config.missionId))
    print("====================================")
    print(string.format("  Map Size: %s (%dx%d blocks)", config.mapSize, 
        config.mapBlockGrid, config.mapBlockGrid))
    print(string.format("  Landing Zones: %d", #config.landingZones))
    
    for _, zone in ipairs(config.landingZones) do
        print(string.format("    %s: %d units, %d spawn points", 
            zone.id, #zone.assignedUnits, #zone.spawnPoints))
    end
    
    print(string.format("  Objective Blocks: %d", #config.objectiveBlocks))
    print("====================================\n")
end

return DeploymentConfig
