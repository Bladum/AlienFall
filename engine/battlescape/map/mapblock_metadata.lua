---MapBlockMetadata - Metadata for MapBlocks in deployment
---
---Tracks objective information for each MapBlock:
---  - Objective type (defend, capture, none)
---  - Whether it's a landing zone or objective location
---  - Spawn points for units
---  - Environmental/difficulty data
---
---@module battlescape.map.mapblock_metadata
---@author AlienFall Development Team

local MapBlockMetadata = {}

-- Objective type constants
MapBlockMetadata.OBJECTIVE_TYPES = {
    NONE = "none",
    DEFEND = "defend",             -- Must protect/survive here
    CAPTURE = "capture",           -- Must take control here
    CRITICAL = "critical",         -- VIP/high-value target
}

---Create metadata for a MapBlock
---@param data table MapBlock metadata {mapBlockId, objectiveType, spawnPoints}
---@return table MapBlockMetadata instance
function MapBlockMetadata.new(data)
    local objType = data.objectiveType or MapBlockMetadata.OBJECTIVE_TYPES.NONE
    
    -- Validate objective type
    local validType = false
    for _, vType in pairs(MapBlockMetadata.OBJECTIVE_TYPES) do
        if vType == objType then
            validType = true
            break
        end
    end
    
    if not validType then
        print("[ERROR] Invalid objective type: " .. tostring(objType))
        objType = MapBlockMetadata.OBJECTIVE_TYPES.NONE
    end
    
    return {
        mapBlockId = data.mapBlockId or "block_unknown",
        objectiveType = objType,
        isObjectiveBlock = (objType ~= MapBlockMetadata.OBJECTIVE_TYPES.NONE),
        isLandingZone = data.isLandingZone or false,
        spawnPoints = data.spawnPoints or {},        -- Array of {x, y} positions
        environment = data.environment or "generic",  -- terrain type
        difficulty = data.difficulty or "normal",     -- encounter difficulty
    }
end

---Set objective type for this MapBlock
---@param metadata table The MapBlock metadata
---@param objType string Objective type (from OBJECTIVE_TYPES)
---@return boolean success True if set
---@return string? error Error message if invalid
function MapBlockMetadata.setObjective(metadata, objType)
    -- Validate type
    for _, vType in pairs(MapBlockMetadata.OBJECTIVE_TYPES) do
        if vType == objType then
            metadata.objectiveType = objType
            metadata.isObjectiveBlock = (objType ~= MapBlockMetadata.OBJECTIVE_TYPES.NONE)
            return true
        end
    end
    
    return false, "Invalid objective type: " .. tostring(objType)
end

---Add a spawn point to this MapBlock
---@param metadata table The MapBlock metadata
---@param x number X coordinate (tile position)
---@param y number Y coordinate (tile position)
function MapBlockMetadata.addSpawnPoint(metadata, x, y)
    table.insert(metadata.spawnPoints, {x = x, y = y})
end

---Get all spawn points
---@param metadata table The MapBlock metadata
---@return table spawnPoints Array of {x, y} positions
function MapBlockMetadata.getSpawnPoints(metadata)
    return metadata.spawnPoints
end

---Check if this MapBlock has any spawn points defined
---@param metadata table The MapBlock metadata
---@return boolean hasSpawns True if spawn points exist
function MapBlockMetadata.hasSpawnPoints(metadata)
    return #metadata.spawnPoints > 0
end

---Get spawn point for a unit (round-robin)
---@param metadata table The MapBlock metadata
---@param unitIndex number Index of unit
---@return table? spawnPoint Single {x, y} position or nil
function MapBlockMetadata.getSpawnPoint(metadata, unitIndex)
    if #metadata.spawnPoints == 0 then
        return nil
    end
    
    -- Round-robin distribute units across spawn points
    local spawnIndex = ((unitIndex - 1) % #metadata.spawnPoints) + 1
    return metadata.spawnPoints[spawnIndex]
end

---Set environment type
---@param metadata table The MapBlock metadata
---@param env string Environment name (generic, urban, desert, forest, etc)
function MapBlockMetadata.setEnvironment(metadata, env)
    metadata.environment = env or "generic"
end

---Set difficulty level
---@param metadata table The MapBlock metadata
---@param difficulty string Difficulty level (easy, normal, hard, expert)
function MapBlockMetadata.setDifficulty(metadata, difficulty)
    metadata.difficulty = difficulty or "normal"
end

---Get metadata summary
---@param metadata table The MapBlock metadata
---@return string summary Human-readable summary
function MapBlockMetadata.getSummary(metadata)
    local objStr = (metadata.isObjectiveBlock) and 
                   ("Objective: " .. metadata.objectiveType) or 
                   "No objective"
    
    return string.format(
        "MapBlock %s: %s, %d spawns, Env: %s, Diff: %s",
        metadata.mapBlockId,
        objStr,
        #metadata.spawnPoints,
        metadata.environment,
        metadata.difficulty
    )
end

---Check if metadata is valid for use
---@param metadata table The MapBlock metadata
---@return boolean valid True if valid
---@return string? error Error message if invalid
function MapBlockMetadata.isValid(metadata)
    if not metadata.mapBlockId then
        return false, "No MapBlock ID"
    end
    
    if metadata.isObjectiveBlock and #metadata.spawnPoints == 0 then
        return false, "Objective blocks must have spawn points"
    end
    
    return true
end

return MapBlockMetadata




