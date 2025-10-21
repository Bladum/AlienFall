---Mission Deployment Screen
---
---Pre-battle deployment planning interface showing map overview, landing zones,
---and unit assignment. Players select landing zone, assign soldiers to craft,
---review mission objectives, and confirm deployment before entering battlescape.
---
---Key Features:
---  - Map overview with MapBlock layout
---  - Landing zone selection (1-4 zones based on map size)
---  - Unit assignment to craft/squad
---  - Equipment loadout verification
---  - Mission objective display
---  - Difficulty assessment
---  - Deployment confirmation
---
---Map Sizes and Landing Zones:
---  - Small (4×4 MapBlocks): 1 landing zone
---  - Medium (5×5 MapBlocks): 2 landing zones
---  - Large (6×6 MapBlocks): 3 landing zones
---  - Huge (7×7 MapBlocks): 4 landing zones
---
---Objective Types:
---  - None: Free exploration
---  - Defend: Protect objectives from enemies
---  - Capture: Take control of objectives
---  - Destroy: Eliminate specific targets
---  - Extraction: Reach extraction point
---
---Key Exports:
---  - DeploymentScreen.new(missionData): Creates deployment interface
---  - selectLandingZone(zoneIndex): Chooses deployment point
---  - assignUnits(squad): Assigns soldiers to mission
---  - confirmDeployment(): Starts battle in battlescape
---  - cancel(): Returns to geoscape
---
---Dependencies:
---  - battlescape.maps.mapblock_system: Map layout and objectives
---  - shared.units.units: Soldier roster and stats
---  - shared.crafts.craft: Transport craft details
---  - widgets.init: Deployment UI widgets
---
---@module scenes.deployment_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DeploymentScreen = require("scenes.deployment_screen")
---  local deploy = DeploymentScreen.new(missionData)
---  deploy:selectLandingZone(1)
---  deploy:assignUnits(playerSquad)
---  deploy:confirmDeployment()  -- Switches to battlescape
---
---@see scenes.battlescape_screen For tactical combat
---@see scenes.geoscape_screen For mission selection
---@see battlescape.maps.mapblock_system For map generation

local DeploymentScreen = {}
DeploymentScreen.__index = DeploymentScreen

--- Map size to landing zone count mapping
DeploymentScreen.LANDING_ZONES = {
    small = 1,   -- 4×4 MapBlocks
    medium = 2,  -- 5×5 MapBlocks
    large = 3,   -- 6×6 MapBlocks
    huge = 4     -- 7×7 MapBlocks
}

--- MapBlock objective types
DeploymentScreen.OBJECTIVE_TYPES = {
    NONE = "none",
    DEFEND = "defend",       -- Must protect
    CAPTURE = "capture",     -- Must take control
    CRITICAL = "critical",   -- High-value target
    ENTRY = "entry"          -- Landing zone
}

--- Create new deployment screen
-- @param missionData table Mission information
-- @return table New DeploymentScreen instance
function DeploymentScreen.new(missionData)
    local self = setmetatable({}, DeploymentScreen)
    
    self.missionData = missionData
    self.mapSize = missionData.mapSize or "medium"
    self.mapBlockGrid = self:getMapBlockGridSize(self.mapSize)
    
    self.landingZones = {}
    self.mapBlocks = {}
    self.availableUnits = {}
    self.deployment = {}      -- {landingZoneId = {unitIds}}
    
    -- Generate landing zones and objectives
    self:generateLandingZones()
    self:generateObjectiveMapBlocks()
    
    print(string.format("[DeploymentScreen] Initialized for %s map (%d×%d MapBlocks, %d landing zones)",
          self.mapSize, self.mapBlockGrid, self.mapBlockGrid, #self.landingZones))
    
    return self
end

--- Get MapBlock grid size from map size
-- @param mapSize string Map size name
-- @return number Grid dimension (4-7)
function DeploymentScreen:getMapBlockGridSize(mapSize)
    local sizes = {
        small = 4,
        medium = 5,
        large = 6,
        huge = 7
    }
    return sizes[mapSize] or 5
end

--- Generate landing zones based on map size
function DeploymentScreen:generateLandingZones()
    local numZones = DeploymentScreen.LANDING_ZONES[self.mapSize] or 2
    local grid = self.mapBlockGrid
    
    -- Define spawn edges (top, right, bottom, left)
    local edges = {
        {x = math.floor(grid / 2), y = 0, name = "North"},           -- Top
        {x = grid - 1, y = math.floor(grid / 2), name = "East"},    -- Right
        {x = math.floor(grid / 2), y = grid - 1, name = "South"},   -- Bottom
        {x = 0, y = math.floor(grid / 2), name = "West"}            -- Left
    }
    
    -- Create landing zones
    for i = 1, numZones do
        local edge = edges[i] or edges[1]
        local lz = {
            id = "lz_" .. i,
            name = "Landing Zone " .. edge.name,
            mapBlockX = edge.x,
            mapBlockY = edge.y,
            mapBlockIndex = edge.y * grid + edge.x,
            assignedUnits = {}
        }
        
        table.insert(self.landingZones, lz)
        self.deployment[lz.id] = {}
        
        print(string.format("[DeploymentScreen] Created landing zone '%s' at MapBlock (%d, %d)",
              lz.name, lz.mapBlockX, lz.mapBlockY))
    end
end

--- Generate objective MapBlocks
function DeploymentScreen:generateObjectiveMapBlocks()
    local grid = self.mapBlockGrid
    
    -- Initialize all MapBlocks
    for y = 0, grid - 1 do
        for x = 0, grid - 1 do
            local mapBlock = {
                x = x,
                y = y,
                index = y * grid + x,
                objective = DeploymentScreen.OBJECTIVE_TYPES.NONE
            }
            
            table.insert(self.mapBlocks, mapBlock)
        end
    end
    
    -- Mark landing zones
    for _, lz in ipairs(self.landingZones) do
        local mb = self.mapBlocks[lz.mapBlockIndex + 1] -- Lua 1-indexed
        if mb then
            mb.objective = DeploymentScreen.OBJECTIVE_TYPES.ENTRY
        end
    end
    
    -- Add mission objectives (center area typically)
    local centerX = math.floor(grid / 2)
    local centerY = math.floor(grid / 2)
    
    -- Add defend objective at center
    local centerIndex = centerY * grid + centerX + 1
    if self.mapBlocks[centerIndex] then
        self.mapBlocks[centerIndex].objective = DeploymentScreen.OBJECTIVE_TYPES.DEFEND
        print(string.format("[DeploymentScreen] Added DEFEND objective at center (%d, %d)",
              centerX, centerY))
    end
    
    -- Add capture objectives around center
    local capturePositions = {
        {x = centerX - 1, y = centerY},
        {x = centerX + 1, y = centerY}
    }
    
    for _, pos in ipairs(capturePositions) do
        if pos.x >= 0 and pos.x < grid and pos.y >= 0 and pos.y < grid then
            local idx = pos.y * grid + pos.x + 1
            if self.mapBlocks[idx] and self.mapBlocks[idx].objective == DeploymentScreen.OBJECTIVE_TYPES.NONE then
                self.mapBlocks[idx].objective = DeploymentScreen.OBJECTIVE_TYPES.CAPTURE
                print(string.format("[DeploymentScreen] Added CAPTURE objective at (%d, %d)",
                      pos.x, pos.y))
            end
        end
    end
end

--- Add available unit
-- @param unitData table Unit information
function DeploymentScreen:addAvailableUnit(unitData)
    table.insert(self.availableUnits, {
        id = unitData.id,
        name = unitData.name,
        class = unitData.class or "soldier",
        rank = unitData.rank or "rookie",
        assigned = false,
        assignedLZ = nil
    })
    
    print(string.format("[DeploymentScreen] Added available unit: %s (%s)",
          unitData.name, unitData.class))
end

--- Assign unit to landing zone
-- @param unitId string Unit identifier
-- @param landingZoneId string Landing zone identifier
-- @return boolean True if assigned successfully
function DeploymentScreen:assignUnit(unitId, landingZoneId)
    -- Find unit
    local unit = nil
    for _, u in ipairs(self.availableUnits) do
        if u.id == unitId then
            unit = u
            break
        end
    end
    
    if not unit then
        print("[DeploymentScreen] ERROR: Unit not found: " .. unitId)
        return false
    end
    
    -- Check if already assigned
    if unit.assigned then
        -- Unassign from previous LZ
        self:unassignUnit(unitId)
    end
    
    -- Assign to new LZ
    unit.assigned = true
    unit.assignedLZ = landingZoneId
    table.insert(self.deployment[landingZoneId], unitId)
    
    print(string.format("[DeploymentScreen] Assigned unit '%s' to %s",
          unit.name, landingZoneId))
    
    return true
end

--- Unassign unit from landing zone
-- @param unitId string Unit identifier
function DeploymentScreen:unassignUnit(unitId)
    local unit = nil
    for _, u in ipairs(self.availableUnits) do
        if u.id == unitId then
            unit = u
            break
        end
    end
    
    if not unit or not unit.assigned then
        return
    end
    
    -- Remove from deployment
    local lzId = unit.assignedLZ
    for i, id in ipairs(self.deployment[lzId]) do
        if id == unitId then
            table.remove(self.deployment[lzId], i)
            break
        end
    end
    
    unit.assigned = false
    unit.assignedLZ = nil
    
    print(string.format("[DeploymentScreen] Unassigned unit '%s'", unit.name))
end

--- Validate deployment (all landing zones have at least one unit)
-- @return boolean True if valid
-- @return string|nil Error message if invalid
function DeploymentScreen:validateDeployment()
    -- Check each landing zone has at least one unit
    for _, lz in ipairs(self.landingZones) do
        local units = self.deployment[lz.id]
        
        if not units or #units == 0 then
            return false, string.format("Landing Zone '%s' has no units assigned", lz.name)
        end
    end
    
    return true, nil
end

--- Get deployment configuration for battlescape
-- @return table Deployment config
function DeploymentScreen:getDeploymentConfig()
    return {
        mapSize = self.mapSize,
        mapBlockGrid = self.mapBlockGrid,
        landingZones = self.landingZones,
        deployment = self.deployment,
        objectives = self:getObjectiveMapBlocks()
    }
end

--- Get MapBlocks with objectives
-- @return table Array of objective MapBlocks
function DeploymentScreen:getObjectiveMapBlocks()
    local objectives = {}
    
    for _, mb in ipairs(self.mapBlocks) do
        if mb.objective ~= DeploymentScreen.OBJECTIVE_TYPES.NONE then
            table.insert(objectives, mb)
        end
    end
    
    return objectives
end

--- Render deployment screen (simplified for console output)
function DeploymentScreen:renderDebug()
    print("\n=== DEPLOYMENT SCREEN ===")
    print(string.format("Map: %s (%d×%d MapBlocks)", self.mapSize, self.mapBlockGrid, self.mapBlockGrid))
    
    print("\nLanding Zones:")
    for _, lz in ipairs(self.landingZones) do
        print(string.format("  %s - MapBlock (%d, %d) - %d units assigned",
              lz.name, lz.mapBlockX, lz.mapBlockY, #self.deployment[lz.id]))
        
        for _, unitId in ipairs(self.deployment[lz.id]) do
            for _, unit in ipairs(self.availableUnits) do
                if unit.id == unitId then
                    print(string.format("    - %s (%s)", unit.name, unit.class))
                    break
                end
            end
        end
    end
    
    print("\nObjectives:")
    for _, mb in ipairs(self.mapBlocks) do
        if mb.objective ~= DeploymentScreen.OBJECTIVE_TYPES.NONE then
            print(string.format("  MapBlock (%d, %d): %s",
                  mb.x, mb.y, mb.objective:upper()))
        end
    end
    
    print("\nUnassigned Units:")
    for _, unit in ipairs(self.availableUnits) do
        if not unit.assigned then
            print(string.format("  - %s (%s, %s)", unit.name, unit.class, unit.rank))
        end
    end
    
    local valid, error = self:validateDeployment()
    print(string.format("\nDeployment Valid: %s", valid and "YES" or "NO - " .. error))
    print("========================\n")
end

--- Auto-assign all units to landing zones (helper function)
function DeploymentScreen:autoAssignUnits()
    local lzIndex = 1
    
    for _, unit in ipairs(self.availableUnits) do
        if not unit.assigned then
            local lz = self.landingZones[lzIndex]
            self:assignUnit(unit.id, lz.id)
            
            -- Cycle through landing zones
            lzIndex = (lzIndex % #self.landingZones) + 1
        end
    end
    
    print("[DeploymentScreen] Auto-assigned all units to landing zones")
end

return DeploymentScreen

























