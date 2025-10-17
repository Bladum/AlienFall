---LandingZone - Landing zone for unit deployment
---
---Represents a landing zone on a battle map where units can spawn.
---Multiple landing zones based on map size (1-4 zones).
---
---@module battlescape.logic.landing_zone
---@author AlienFall Development Team

local LandingZone = {}

---Create a new landing zone
---@param data table Landing zone data {id, mapBlockIndex, gridPosition, spawnPoints}
---@return table LandingZone instance
function LandingZone.new(data)
    return {
        id = data.id or "lz_" .. tostring(math.random(1000, 9999)),
        mapBlockIndex = data.mapBlockIndex or 0,
        gridPosition = data.gridPosition or {x = 0, y = 0},
        spawnPoints = data.spawnPoints or {},  -- Array of {x, y} tile positions
        assignedUnits = data.assignedUnits or {},  -- Unit IDs assigned to this zone
        isActive = data.isActive ~= false,
    }
end

---Add unit to landing zone
---@param zone table The landing zone
---@param unitId string Unit ID
---@return boolean success True if added
function LandingZone.addUnit(zone, unitId)
    table.insert(zone.assignedUnits, unitId)
    return true
end

---Remove unit from landing zone
---@param zone table The landing zone
---@param unitId string Unit ID
---@return boolean success True if removed
function LandingZone.removeUnit(zone, unitId)
    for i, id in ipairs(zone.assignedUnits) do
        if id == unitId then
            table.remove(zone.assignedUnits, i)
            return true
        end
    end
    return false
end

---Get spawn point for a unit (round-robin)
---@param zone table The landing zone
---@param unitIndex number Index of unit in zone's assigned units
---@return table? spawnPoint Tile position {x, y} or nil if no spawn points
function LandingZone.getSpawnPoint(zone, unitIndex)
    if #zone.spawnPoints == 0 then
        return nil
    end
    
    -- Round-robin distribute units across spawn points
    local spawnIndex = ((unitIndex - 1) % #zone.spawnPoints) + 1
    return zone.spawnPoints[spawnIndex]
end

---Get all assigned units
---@param zone table The landing zone
---@return table unitIds Array of assigned unit IDs
function LandingZone.getAssignedUnits(zone)
    return zone.assignedUnits
end

---Check if zone is empty
---@param zone table The landing zone
---@return boolean empty True if no units assigned
function LandingZone.isEmpty(zone)
    return #zone.assignedUnits == 0
end

---Get landing zone info
---@param zone table The landing zone
---@return string info Human-readable info
function LandingZone.getInfo(zone)
    return string.format("Landing Zone %s: %d units, %d spawn points", 
        zone.id, #zone.assignedUnits, #zone.spawnPoints)
end

return LandingZone
