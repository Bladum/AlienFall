---LandingZoneSelector - Select appropriate landing zones from MapBlocks
---
---Algorithm to select MapBlocks as landing zones based on:
---  - Map size (determines zone count)
---  - Spatial distribution
---  - Edge/corner preference
---  - Spawn point generation
---
---@module battlescape.logic.landing_zone_selector
---@author AlienFall Development Team

local LandingZone = require("battlescape.logic.landing_zone")

local LandingZoneSelector = {}

---Select landing zones for a map
---@param gridSize number Grid dimensions (4-7)
---@param mapSize string Map size string (small, medium, large, huge)
---@return table zones Array of selected LandingZone instances
function LandingZoneSelector.selectZones(gridSize, mapSize)
    local zoneCount = LandingZoneSelector._getZoneCount(mapSize)
    
    print(string.format("[LandingZoneSelector] Selecting %d zones for %dx%d grid", 
        zoneCount, gridSize, gridSize))
    
    local zones = {}
    local candidates = LandingZoneSelector._generateCandidates(gridSize)
    
    -- Select spatially distributed zones
    local selected = LandingZoneSelector._selectDistributed(candidates, zoneCount, gridSize)
    
    for i, index in ipairs(selected) do
        local zone = LandingZone.new({
            id = "lz_" .. tostring(i),
            mapBlockIndex = index,
            gridPosition = LandingZoneSelector._indexToGridPos(index, gridSize),
            spawnPoints = LandingZoneSelector._generateSpawnPoints(),
        })
        table.insert(zones, zone)
    end
    
    return zones
end

---Get zone count based on map size
---@param mapSize string Map size
---@return number count Zone count (1-4)
function LandingZoneSelector._getZoneCount(mapSize)
    if mapSize == "small" then return 1
    elseif mapSize == "medium" then return 2
    elseif mapSize == "large" then return 3
    elseif mapSize == "huge" then return 4
    else return 1 end
end

---Generate candidate MapBlock indices (prefer edges/corners)
---@param gridSize number Grid dimensions
---@return table candidates Array of candidate block indices
function LandingZoneSelector._generateCandidates(gridSize)
    local candidates = {}
    
    -- Prioritize corners and edges
    local weight = 100
    
    -- Corners (highest priority)
    local corners = {0, gridSize - 1, gridSize * (gridSize - 1), gridSize * gridSize - 1}
    
    for _, idx in ipairs(corners) do
        table.insert(candidates, {index = idx, weight = weight})
        weight = weight - 1
    end
    
    -- Edges
    for i = 1, gridSize - 2 do
        -- Top edge
        table.insert(candidates, {index = i, weight = weight})
        weight = weight - 1
        
        -- Bottom edge
        table.insert(candidates, {index = gridSize * (gridSize - 1) + i, weight = weight})
        weight = weight - 1
        
        -- Left edge
        table.insert(candidates, {index = i * gridSize, weight = weight})
        weight = weight - 1
        
        -- Right edge
        table.insert(candidates, {index = i * gridSize + (gridSize - 1), weight = weight})
        weight = weight - 1
    end
    
    return candidates
end

---Select spatially distributed zones from candidates
---@param candidates table Array of candidate data
---@param count number Zones to select
---@param gridSize number Grid dimensions
---@return table selected Array of selected block indices
function LandingZoneSelector._selectDistributed(candidates, count, gridSize)
    local selected = {}
    local maxDistance = gridSize * 1.5
    
    for _, candidate in ipairs(candidates) do
        if #selected >= count then
            break
        end
        
        -- Check distance to already selected zones
        local isFar = true
        for _, selectedIdx in ipairs(selected) do
            local dist = LandingZoneSelector._gridDistance(
                candidate.index, selectedIdx, gridSize)
            
            if dist < maxDistance then
                isFar = false
                break
            end
        end
        
        if isFar or #selected == 0 then
            table.insert(selected, candidate.index)
        end
    end
    
    return selected
end

---Convert block index to grid position
---@param index number Block index (0-indexed)
---@param gridSize number Grid dimensions
---@return table position Grid position {x, y}
function LandingZoneSelector._indexToGridPos(index, gridSize)
    local y = math.floor(index / gridSize)
    local x = index % gridSize
    return {x = x, y = y}
end

---Calculate grid distance between two blocks
---@param idx1 number First block index
---@param idx2 number Second block index
---@param gridSize number Grid dimensions
---@return number distance Manhattan distance
function LandingZoneSelector._gridDistance(idx1, idx2, gridSize)
    local pos1 = LandingZoneSelector._indexToGridPos(idx1, gridSize)
    local pos2 = LandingZoneSelector._indexToGridPos(idx2, gridSize)
    
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

---Generate spawn points within a MapBlock
---@return table spawnPoints Array of spawn point positions {x, y}
function LandingZoneSelector._generateSpawnPoints()
    -- MapBlocks are 15×15 tiles, place spawn points around edges
    local spawnPoints = {
        {x = 0, y = 7},    -- Left edge
        {x = 2, y = 0},    -- Top left
        {x = 7, y = 0},    -- Top center
        {x = 12, y = 0},   -- Top right
        {x = 14, y = 7},   -- Right edge
    }
    return spawnPoints
end

return LandingZoneSelector
