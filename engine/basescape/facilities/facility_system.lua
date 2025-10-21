---Basescape Facility System - Base Construction and Management
---
---Manages base construction, facilities, capacity tracking, and services on a 5×5 grid.
---The headquarters facility is mandatory and always present at the center (2,2). Players
---construct additional facilities to expand storage, research, manufacturing, defense,
---and utility capabilities. Facilities can be damaged during base defense missions.
---
---Grid System:
---  - 5×5 grid (25 total positions, 0-indexed: 0-4)
---  - Headquarters locked at center position (2, 2)
---  - 24 buildable positions available
---  - Each position holds one facility or is empty
---
---Facility Lifecycle:
---  1. EMPTY: No facility present
---  2. CONSTRUCTION: Building in progress (takes multiple days)
---  3. OPERATIONAL: Fully functional
---  4. DAMAGED: Reduced capacity/functionality
---  5. DESTROYED: Must be rebuilt
---
---Key Capacities:
---  - personnel: Living quarters for soldiers/staff
---  - storage: Item and equipment storage
---  - research: Laboratory capacity for projects
---  - manufacturing: Workshop capacity for production
---  - hangar: Craft storage slots
---
---Key Exports:
---  - FacilitySystem.new(): Creates facility system instance
---  - startConstruction(x, y, facilityTypeId): Begins building
---  - updateConstruction(day): Progresses construction
---  - getFacility(x, y): Returns facility at position
---  - getCapacity(capacityType): Returns total capacity
---  - getServices(): Returns active services (radar, medical, training)
---
---Dependencies:
---  - basescape.facilities.facility_types: Facility definitions
---
---@module basescape.facilities.facility_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FacilitySystem = require("basescape.facilities.facility_system")
---  local base = FacilitySystem.new()
---  base:startConstruction(0, 0, "laboratory")
---  base:updateConstruction(currentDay)
---
---@see basescape.facilities.facility_types For facility definitions

local FacilitySystem = {}
FacilitySystem.__index = FacilitySystem

--- Grid dimensions
FacilitySystem.GRID_SIZE = 5
FacilitySystem.HQ_POSITION = {x = 2, y = 2} -- Center of 5x5 grid (0-indexed: 0-4)

--- Facility status
FacilitySystem.STATUS = {
    EMPTY = "empty",
    CONSTRUCTION = "construction",
    OPERATIONAL = "operational",
    DAMAGED = "damaged",
    DESTROYED = "destroyed"
}

--- Create new facility system for a base
-- @param baseId string Base identifier
-- @return table New FacilitySystem instance
function FacilitySystem.new(baseId)
    local self = setmetatable({}, FacilitySystem)
    
    self.baseId = baseId
    self.grid = {}               -- [x][y] = facility instance
    self.constructionQueue = {}  -- Array of construction orders
    self.facilities = {}         -- All facility instances
    self.capacities = {}         -- Aggregated capacities
    self.services = {}           -- Available services
    
    -- Initialize grid
    for x = 0, FacilitySystem.GRID_SIZE - 1 do
        self.grid[x] = {}
        for y = 0, FacilitySystem.GRID_SIZE - 1 do
            self.grid[x][y] = {
                status = FacilitySystem.STATUS.EMPTY,
                facility = nil
            }
        end
    end
    
    -- Create mandatory HQ
    self:buildMandatoryHQ()
    
    print(string.format("[FacilitySystem] Initialized for base '%s' with HQ at (%d,%d)", 
          baseId, FacilitySystem.HQ_POSITION.x, FacilitySystem.HQ_POSITION.y))
    
    return self
end

--- Build mandatory HQ facility
function FacilitySystem:buildMandatoryHQ()
    local hqFacility = {
        id = "hq_" .. self.baseId,
        typeId = "headquarters",
        name = "Headquarters",
        x = FacilitySystem.HQ_POSITION.x,
        y = FacilitySystem.HQ_POSITION.y,
        status = FacilitySystem.STATUS.OPERATIONAL,
        health = 100,
        maxHealth = 100,
        armor = 20,
        buildProgress = 100,
        capacities = {
            units = 10,
            items = 100,
            crafts = 1
        },
        services = {
            provides = {"power", "command"},
            requires = {}
        },
        maintenance = 10000 -- Monthly cost
    }
    
    self.grid[hqFacility.x][hqFacility.y] = {
        status = FacilitySystem.STATUS.OPERATIONAL,
        facility = hqFacility
    }
    
    table.insert(self.facilities, hqFacility)
    self:recalculateCapacities()
    
    print("[FacilitySystem] Built mandatory HQ facility")
end

--- Start facility construction
-- @param typeId string Facility type identifier
-- @param x number Grid X coordinate (0-4)
-- @param y number Grid Y coordinate (0-4)
-- @param definition table Facility type definition
-- @return boolean True if construction started
function FacilitySystem:startConstruction(typeId, x, y, definition)
    -- Validate position
    if not self:isValidPosition(x, y) then
        print(string.format("[FacilitySystem] Invalid position: (%d,%d)", x, y))
        return false
    end
    
    -- Check if slot is empty
    if self.grid[x][y].status ~= FacilitySystem.STATUS.EMPTY then
        print(string.format("[FacilitySystem] Position (%d,%d) is not empty", x, y))
        return false
    end
    
    -- Create construction order
    local order = {
        id = "construction_" .. os.time() .. "_" .. math.random(1000, 9999),
        typeId = typeId,
        name = definition.name,
        x = x,
        y = y,
        buildTime = definition.buildTime or 7,  -- Days
        buildProgress = 0,
        cost = definition.cost or {},
        definition = definition
    }
    
    -- Mark grid slot as under construction
    self.grid[x][y].status = FacilitySystem.STATUS.CONSTRUCTION
    self.grid[x][y].facility = order
    
    table.insert(self.constructionQueue, order)
    
    print(string.format("[FacilitySystem] Started construction of '%s' at (%d,%d), %d days",
          definition.name, x, y, order.buildTime))
    
    return true
end

--- Process daily construction progress
function FacilitySystem:processDailyConstruction()
    if #self.constructionQueue == 0 then
        return
    end
    
    print(string.format("[FacilitySystem] Processing daily construction for %d projects", 
          #self.constructionQueue))
    
    for i = #self.constructionQueue, 1, -1 do
        local order = self.constructionQueue[i]
        order.buildProgress = order.buildProgress + 1
        
        print(string.format("[FacilitySystem] '%s' progress: %d/%d days",
              order.name, order.buildProgress, order.buildTime))
        
        -- Check for completion
        if order.buildProgress >= order.buildTime then
            self:completeConstruction(order)
            table.remove(self.constructionQueue, i)
        end
    end
end

--- Complete facility construction
-- @param order table Construction order
function FacilitySystem:completeConstruction(order)
    local def = order.definition
    
    -- Create operational facility
    local facility = {
        id = order.id:gsub("construction_", "facility_"),
        typeId = order.typeId,
        name = order.name,
        x = order.x,
        y = order.y,
        status = FacilitySystem.STATUS.OPERATIONAL,
        health = def.maxHealth or 100,
        maxHealth = def.maxHealth or 100,
        armor = def.armor or 0,
        buildProgress = 100,
        capacities = def.capacities or {},
        services = def.services or {provides = {}, requires = {}},
        maintenance = def.maintenance or 0
    }
    
    -- Update grid
    self.grid[facility.x][facility.y] = {
        status = FacilitySystem.STATUS.OPERATIONAL,
        facility = facility
    }
    
    table.insert(self.facilities, facility)
    self:recalculateCapacities()
    
    print(string.format("[FacilitySystem] CONSTRUCTION COMPLETE: '%s' at (%d,%d)",
          facility.name, facility.x, facility.y))
end

--- Recalculate total capacities from all operational facilities
function FacilitySystem:recalculateCapacities()
    -- Reset capacities
    self.capacities = {
        units = 0,
        items = 0,
        crafts = 0,
        researchProjects = 0,
        manufacturingProjects = 0,
        defense = 0,
        prisoners = 0,
        healing = 0,
        sanityRecovery = 0,
        craftRepair = 0,
        training = 0,
        radarRange = 0
    }
    
    self.services = {
        provides = {},
        requires = {}
    }
    
    -- Aggregate from operational facilities
    for _, facility in ipairs(self.facilities) do
        if facility.status == FacilitySystem.STATUS.OPERATIONAL then
            -- Add capacities
            for key, value in pairs(facility.capacities) do
                self.capacities[key] = (self.capacities[key] or 0) + value
            end
            
            -- Collect services
            if facility.services then
                for _, service in ipairs(facility.services.provides or {}) do
                    self.services.provides[service] = true
                end
                for _, service in ipairs(facility.services.requires or {}) do
                    self.services.requires[service] = true
                end
            end
        end
    end
    
    print("[FacilitySystem] Recalculated capacities:")
    for key, value in pairs(self.capacities) do
        if value > 0 then
            print(string.format("  %s: %d", key, value))
        end
    end
end

--- Check if position is valid
-- @param x number Grid X coordinate
-- @param y number Grid Y coordinate
-- @return boolean True if valid
function FacilitySystem:isValidPosition(x, y)
    return x >= 0 and x < FacilitySystem.GRID_SIZE and 
           y >= 0 and y < FacilitySystem.GRID_SIZE
end

--- Get facility at position
-- @param x number Grid X coordinate
-- @param y number Grid Y coordinate
-- @return table|nil Facility or nil
function FacilitySystem:getFacilityAt(x, y)
    if not self:isValidPosition(x, y) then
        return nil
    end
    
    return self.grid[x][y].facility
end

--- Check if service is available
-- @param service string Service name (e.g., "power", "fuel")
-- @return boolean True if service is provided
function FacilitySystem:hasService(service)
    return self.services.provides[service] == true
end

--- Get total capacity of a type
-- @param capacityType string Capacity type (e.g., "units", "items")
-- @return number Total capacity
function FacilitySystem:getCapacity(capacityType)
    return self.capacities[capacityType] or 0
end

--- Calculate monthly maintenance cost
-- @return number Total monthly maintenance
function FacilitySystem:getMonthlyMaintenance()
    local total = 0
    
    for _, facility in ipairs(self.facilities) do
        if facility.status == FacilitySystem.STATUS.OPERATIONAL then
            total = total + (facility.maintenance or 0)
        end
    end
    
    return total
end

--- Damage facility
-- @param x number Grid X coordinate
-- @param y number Grid Y coordinate
-- @param damage number Damage amount
function FacilitySystem:damageFacility(x, y, damage)
    local cell = self.grid[x][y]
    local facility = cell.facility
    
    if not facility or facility.status ~= FacilitySystem.STATUS.OPERATIONAL then
        return
    end
    
    -- Apply armor reduction
    local actualDamage = math.max(0, damage - facility.armor)
    facility.health = math.max(0, facility.health - actualDamage)
    
    print(string.format("[FacilitySystem] Facility '%s' took %d damage (-%d armor), health: %d/%d",
          facility.name, actualDamage, facility.armor, facility.health, facility.maxHealth))
    
    -- Check for destruction
    if facility.health <= 0 then
        facility.status = FacilitySystem.STATUS.DESTROYED
        cell.status = FacilitySystem.STATUS.DESTROYED
        self:recalculateCapacities()
        
        print(string.format("[FacilitySystem] Facility '%s' DESTROYED", facility.name))
    elseif facility.health < facility.maxHealth * 0.5 then
        facility.status = FacilitySystem.STATUS.DAMAGED
        cell.status = FacilitySystem.STATUS.DAMAGED
        self:recalculateCapacities()
        
        print(string.format("[FacilitySystem] Facility '%s' DAMAGED", facility.name))
    end
end

--- Get all operational facilities
-- @return table Array of facilities
function FacilitySystem:getOperationalFacilities()
    local operational = {}
    
    for _, facility in ipairs(self.facilities) do
        if facility.status == FacilitySystem.STATUS.OPERATIONAL then
            table.insert(operational, facility)
        end
    end
    
    return operational
end

--- Get construction queue
-- @return table Array of construction orders
function FacilitySystem:getConstructionQueue()
    return self.constructionQueue
end

return FacilitySystem

























