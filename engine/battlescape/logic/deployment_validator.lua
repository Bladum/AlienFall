---DeploymentValidator - Validation logic for deployment configurations
---
---Ensures deployment configurations are valid before transitioning to battlescape:
---  - All units are assigned
---  - Landing zones have capacity for assigned units
---  - No landing zones on objective blocks
---  - Spawn points are defined
---  - Unit roster is complete
---
---@module battlescape.logic.deployment_validator
---@author AlienFall Development Team

local DeploymentValidator = {}

-- Validation error codes
DeploymentValidator.ERROR_CODES = {
    UNITS_UNASSIGNED = "units_unassigned",
    MISSING_UNITS = "missing_units",
    LZ_CAPACITY_EXCEEDED = "lz_capacity_exceeded",
    LZ_ON_OBJECTIVE = "lz_on_objective",
    NO_SPAWN_POINTS = "no_spawn_points",
    INVALID_CONFIG = "invalid_config",
    DEPLOYMENT_INCOMPLETE = "deployment_incomplete",
}

---Validate a complete deployment configuration
---@param config table DeploymentConfig instance
---@return boolean valid True if valid
---@return table errors Array of error tables {code, message, details}
function DeploymentValidator.validate(config)
    if not config then
        return false, {{
            code = DeploymentValidator.ERROR_CODES.INVALID_CONFIG,
            message = "Configuration is nil",
            details = {}
        }}
    end
    
    local errors = {}
    
    -- Check 1: All units are assigned
    local assignmentErrors = DeploymentValidator:_checkUnitAssignments(config)
    for _, err in ipairs(assignmentErrors) do
        table.insert(errors, err)
    end
    
    -- Check 2: Landing zones have proper capacity
    local capacityErrors = DeploymentValidator:_checkLZCapacity(config)
    for _, err in ipairs(capacityErrors) do
        table.insert(errors, err)
    end
    
    -- Check 3: Landing zones not on objectives
    local objectiveErrors = DeploymentValidator:_checkObjectivePlacement(config)
    for _, err in ipairs(objectiveErrors) do
        table.insert(errors, err)
    end
    
    -- Check 4: Spawn points defined
    local spawnErrors = DeploymentValidator:_checkSpawnPoints(config)
    for _, err in ipairs(spawnErrors) do
        table.insert(errors, err)
    end
    
    local isValid = #errors == 0
    
    if isValid then
        print("[DeploymentValidator] ✓ Configuration is VALID")
    else
        print(string.format("[DeploymentValidator] ✗ Configuration has %d error(s)", #errors))
        for i, err in ipairs(errors) do
            print(string.format("  %d. %s: %s", i, err.code, err.message))
        end
    end
    
    return isValid, errors
end

---Check all units are assigned to landing zones
---@param config table DeploymentConfig instance
---@return table errors Array of error tables
function DeploymentValidator:_checkUnitAssignments(config)
    local errors = {}
    
    if not config.availableUnits or #config.availableUnits == 0 then
        table.insert(errors, {
            code = DeploymentValidator.ERROR_CODES.MISSING_UNITS,
            message = "No units available for deployment",
            details = {unitCount = 0}
        })
        return errors
    end
    
    local unassignedUnits = {}
    for _, unit in ipairs(config.availableUnits) do
        local unitId = unit.id or unit
        if not config.deployment[unitId] then
            table.insert(unassignedUnits, unitId)
        end
    end
    
    if #unassignedUnits > 0 then
        table.insert(errors, {
            code = DeploymentValidator.ERROR_CODES.UNITS_UNASSIGNED,
            message = string.format("%d units are not assigned to landing zones", #unassignedUnits),
            details = {
                unassignedUnits = unassignedUnits,
                totalUnits = #config.availableUnits,
                assignedUnits = #config.availableUnits - #unassignedUnits
            }
        })
    end
    
    return errors
end

---Check landing zone capacity is not exceeded
---@param config table DeploymentConfig instance
---@return table errors Array of error tables
function DeploymentValidator:_checkLZCapacity(config)
    local errors = {}
    
    if not config.landingZones then
        return errors
    end
    
    for _, lz in ipairs(config.landingZones) do
        local unitCount = #lz.assignedUnits
        local capacity = lz.capacity or 3
        
        if unitCount > capacity then
            table.insert(errors, {
                code = DeploymentValidator.ERROR_CODES.LZ_CAPACITY_EXCEEDED,
                message = string.format(
                    "Landing zone %s exceeds capacity (%d > %d)",
                    lz.id, unitCount, capacity
                ),
                details = {
                    lzId = lz.id,
                    unitCount = unitCount,
                    capacity = capacity
                }
            })
        end
    end
    
    return errors
end

---Check landing zones are not placed on objective blocks
---@param config table DeploymentConfig instance
---@return table errors Array of error tables
function DeploymentValidator:_checkObjectivePlacement(config)
    local errors = {}
    
    if not config.landingZones or not config.objectiveBlocks then
        return errors
    end
    
    -- Build set of objective block indices
    local objectiveIndices = {}
    for _, objBlock in ipairs(config.objectiveBlocks) do
        objectiveIndices[objBlock.mapBlockIndex or objBlock.id] = true
    end
    
    -- Check each landing zone
    for _, lz in ipairs(config.landingZones) do
        local blockIdx = lz.mapBlockIndex
        
        if objectiveIndices[blockIdx] then
            table.insert(errors, {
                code = DeploymentValidator.ERROR_CODES.LZ_ON_OBJECTIVE,
                message = string.format(
                    "Landing zone %s is placed on objective block %d",
                    lz.id, blockIdx
                ),
                details = {
                    lzId = lz.id,
                    blockIndex = blockIdx
                }
            })
        end
    end
    
    return errors
end

---Check spawn points are defined for landing zones
---@param config table DeploymentConfig instance
---@return table errors Array of error tables
function DeploymentValidator:_checkSpawnPoints(config)
    local errors = {}
    
    if not config.landingZones then
        return errors
    end
    
    for _, lz in ipairs(config.landingZones) do
        if not lz.spawnPoints or #lz.spawnPoints == 0 then
            table.insert(errors, {
                code = DeploymentValidator.ERROR_CODES.NO_SPAWN_POINTS,
                message = string.format(
                    "Landing zone %s has no spawn points defined",
                    lz.id
                ),
                details = {
                    lzId = lz.id,
                    spawnPointCount = lz.spawnPoints and #lz.spawnPoints or 0
                }
            })
        end
    end
    
    return errors
end

---Validate a single unit assignment
---@param config table DeploymentConfig instance
---@param unitId string Unit ID
---@return boolean valid True if valid
---@return string? error Error message if invalid
function DeploymentValidator:validateUnitAssignment(config, unitId)
    if not config.deployment[unitId] then
        return false, "Unit not assigned"
    end
    
    local lzId = config.deployment[unitId]
    local lz = nil
    
    for _, zone in ipairs(config.landingZones or {}) do
        if zone.id == lzId then
            lz = zone
            break
        end
    end
    
    if not lz then
        return false, "Landing zone not found: " .. lzId
    end
    
    -- Check if unit is in the zone
    local found = false
    for _, assignedId in ipairs(lz.assignedUnits) do
        if assignedId == unitId then
            found = true
            break
        end
    end
    
    if not found then
        return false, "Unit not in assigned landing zone"
    end
    
    return true
end

---Get validation error summary
---@param errors table Array of error tables
---@return string summary Human-readable summary
function DeploymentValidator:getSummary(errors)
    if #errors == 0 then
        return "✓ Configuration is valid"
    end
    
    local lines = {string.format("✗ %d validation error(s):", #errors)}
    
    for i, err in ipairs(errors) do
        table.insert(lines, string.format(
            "  %d. %s: %s",
            i, err.code, err.message
        ))
    end
    
    return table.concat(lines, "\n")
end

---Log validation results
---@param config table DeploymentConfig instance
---@param valid boolean Whether validation passed
---@param errors table Array of errors (if any)
function DeploymentValidator:logResults(config, valid, errors)
    print("\n" .. string.rep("=", 60))
    print("DEPLOYMENT VALIDATION RESULTS")
    print(string.rep("=", 60))
    
    print(string.format("Mission: %s", config.missionId or "unknown"))
    print(string.format("Map Size: %s (%dx%d)", 
        config.mapSize, 
        config.mapBlockGrid, 
        config.mapBlockGrid
    ))
    
    print(string.format("\nUnits: %d total, %d assigned",
        #config.availableUnits,
        #config.deployment or 0
    ))
    
    print(string.format("Landing Zones: %d", #config.landingZones))
    
    if valid then
        print("\n✓ VALIDATION PASSED - Ready for deployment!")
    else
        print(string.format("\n✗ VALIDATION FAILED - %d error(s):", #errors))
        for i, err in ipairs(errors) do
            print(string.format("\n  [%d] %s", i, err.code))
            print(string.format("      %s", err.message))
        end
    end
    
    print("\n" .. string.rep("=", 60) .. "\n")
end

return DeploymentValidator



