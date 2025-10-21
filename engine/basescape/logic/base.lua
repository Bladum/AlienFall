---Base - Base Instance
---
---Represents a player base with facilities, capacity management, and services.
---Main interface for basescape operations.
---
---Features:
---  - 5×5 facility grid
---  - Facility management (add, remove, query)
---  - Capacity aggregation
---  - Service management
---  - Construction management
---  - Finance integration
---
---@module basescape.logic.base
---@author AlienFall Development Team

local BaseGrid = require("basescape.logic.base_grid")
local Facility = require("basescape.logic.facility")
local CapacityManager = require("basescape.logic.capacity_manager")
local FacilityRegistry = require("basescape.logic.facility_registry")

local Base = {}
Base.__index = Base

---Create new base
---@param config table Base configuration
---@return Base base New base instance
function Base.new(config)
    local self = setmetatable({}, Base)
    
    -- Identity
    self.id = config.id or error("Base requires id")
    self.name = config.name or self.id
    self.description = config.description or ""
    
    -- Location
    self.provinceId = config.provinceId or error("Base requires provinceId")
    self.regionId = config.regionId or nil
    
    -- Infrastructure
    self.grid = BaseGrid.new(self.id)
    self.capacityManager = CapacityManager.new(self.id)
    self.capacityManager:setGrid(self.grid)
    
    -- Services
    self.services = {}  -- Set of service tags available
    
    -- Finance
    self.credits = config.credits or 0
    self.monthlyMaintenance = 0
    
    -- Metadata
    self.foundedDate = config.foundedDate or 0
    self.isVisible = config.isVisible or false  -- To geoscape
    self.defenders = config.defenders or {}  -- Unit IDs assigned to defend base
    
    return self
end

---Build HQ at center (called on base creation)
---@return boolean success True if HQ created
function Base:buildHQ()
    local hqType = FacilityRegistry.get("hq")
    if not hqType then
        print("[Base] ERROR: HQ facility type not found")
        return false
    end
    
    local hq = Facility.new({
        id = self.id .. "_hq",
        typeId = "hq",
        baseId = self.id,
        type = hqType,
        gridX = 2,
        gridY = 2,
        state = Facility.STATE.OPERATIONAL,
        health = hqType.health,
        maxHealth = hqType.health,
        armor = hqType.armor,
        totalDaysToBuild = 0,
    })
    
    local success, _ = self.grid:placeFacility(hq, 2, 2)
    if success then
        hq.constructionProgress = 1.0
        hq.daysBuilt = 0
        self:recalculateCapacities()
        print(string.format("[Base] HQ created at center (2,2)"))
        return true
    else
        print("[Base] ERROR: Failed to place HQ")
        return false
    end
end

---Start construction of a facility
---@param facilityTypeId string Facility type ID
---@param gridX number Grid X coordinate
---@param gridY number Grid Y coordinate
---@return Facility|nil facility Created facility or nil
function Base:startConstruction(facilityTypeId, gridX, gridY)
    local facilityType = FacilityRegistry.get(facilityTypeId)
    if not facilityType then
        print(string.format("[Base] ERROR: Facility type not found: %s", facilityTypeId))
        return nil
    end
    
    -- Validate prerequisites
    local valid, reason = self:canBuildFacility(facilityTypeId, gridX, gridY)
    if not valid then
        print(string.format("[Base] Cannot build %s: %s", facilityTypeId, reason))
        return nil
    end
    
    -- Check funds
    local buildCost = facilityType.buildCost.credits or 0
    if self.credits < buildCost then
        print(string.format("[Base] Insufficient credits: need %d, have %d", buildCost, self.credits))
        return nil
    end
    
    -- Deduct cost
    self.credits = self.credits - buildCost
    
    -- Create facility
    local facility = Facility.new({
        id = self.id .. "_fac_" .. facilityTypeId .. "_" .. gridX .. "_" .. gridY,
        typeId = facilityTypeId,
        baseId = self.id,
        type = facilityType,
        gridX = gridX,
        gridY = gridY,
        state = Facility.STATE.CONSTRUCTING,
        health = facilityType.health,
        maxHealth = facilityType.health,
        armor = facilityType.armor,
        totalDaysToBuild = facilityType.buildTime,
    })
    
    -- Place on grid
    local success, _ = self.grid:placeFacility(facility, gridX, gridY)
    if success then
        print(string.format("[Base] Started construction: %s at (%d,%d)", facilityTypeId, gridX, gridY))
        return facility
    else
        print("[Base] ERROR: Failed to place facility on grid")
        return nil
    end
end

---Check if can build a facility
---@param facilityTypeId string Facility type ID
---@param gridX number Grid X coordinate
---@param gridY number Grid Y coordinate
---@return boolean canBuild True if can build
---@return string? error Error message if cannot build
function Base:canBuildFacility(facilityTypeId, gridX, gridY)
    local facilityType = FacilityRegistry.get(facilityTypeId)
    if not facilityType then
        return false, "Unknown facility type"
    end
    
    -- Check coordinates valid
    if not self.grid:isInBounds(gridX, gridY) then
        return false, "Coordinates out of bounds"
    end
    
    -- Check cell available
    if not self.grid:isCellAvailable(gridX, gridY) then
        return false, "Cell already occupied"
    end
    
    -- Check tech prerequisites
    for _, techId in ipairs(facilityType.requiredTech) do
        -- TODO: Check research system
        -- if not researchSystem:hasCompleted(techId) then
        --     return false, "Missing tech: " .. techId
        -- end
    end
    
    -- Check facility prerequisites
    local existingFacilityTypes = {}
    for _, facility in ipairs(self.grid:getAllFacilities()) do
        existingFacilityTypes[facility.typeId] = true
    end
    
    for _, requiredFacility in ipairs(facilityType.requiredFacilities) do
        if not existingFacilityTypes[requiredFacility] then
            return false, "Missing prerequisite facility: " .. requiredFacility
        end
    end
    
    -- Check max per base
    if facilityType.maxPerBase then
        local count = #self.grid:getFacilitiesByType(facilityTypeId)
        if count >= facilityType.maxPerBase then
            return false, "Already at maximum: " .. facilityType.maxPerBase
        end
    end
    
    return true
end

---Progress construction by one day (called by calendar)
function Base:progressConstructionDay()
    for _, facility in ipairs(self.grid:getAllFacilities()) do
        if facility.state == Facility.STATE.CONSTRUCTING then
            if facility:progressConstruction() then
                self:recalculateCapacities()
            end
        end
    end
end

---Recalculate all base capacities and services
function Base:recalculateCapacities()
    self.capacityManager:recalculate()
    self:recalculateServices()
    self:recalculateMaintenance()
end

---Recalculate available services
function Base:recalculateServices()
    self.services = {}
    
    for _, facility in ipairs(self.grid:getAllFacilities()) do
        if facility:isOperational() then
            for _, service in ipairs(facility.type.servicesProvided) do
                self.services[service] = true
            end
        end
    end
    
    -- Check service requirements
    for _, facility in ipairs(self.grid:getAllFacilities()) do
        if facility.type then
            for _, requiredService in ipairs(facility.type.servicesRequired) do
                if not self.services[requiredService] then
                    facility:setOffline("Missing service: " .. requiredService)
                end
            end
        end
    end
    
    print(string.format("[Base] Services available: %d", self:getServiceCount()))
end

---Recalculate maintenance costs
function Base:recalculateMaintenance()
    self.monthlyMaintenance = 0
    
    for _, facility in ipairs(self.grid:getAllFacilities()) do
        if facility.state == Facility.STATE.OPERATIONAL then
            self.monthlyMaintenance = self.monthlyMaintenance + facility.type.maintenanceCost
        end
    end
    
    print(string.format("[Base] Monthly maintenance: %d credits", self.monthlyMaintenance))
end

---Deduct monthly maintenance costs
---@return boolean success True if could afford
function Base:deductMonthlyMaintenance()
    if self.credits >= self.monthlyMaintenance then
        self.credits = self.credits - self.monthlyMaintenance
        return true
    else
        print(string.format("[Base] ALERT: Cannot afford maintenance (%d needed, %d available)",
            self.monthlyMaintenance, self.credits))
        -- TODO: Facilities should go offline due to lack of maintenance
        return false
    end
end

---Get service count
---@return number count Services available
function Base:getServiceCount()
    local count = 0
    for _ in pairs(self.services) do
        count = count + 1
    end
    return count
end

---Check if service available
---@param serviceTag string Service tag
---@return boolean available True if available
function Base:hasService(serviceTag)
    return self.services[serviceTag] == true
end

---Get all facilities
---@return table facilities Array of facilities
function Base:getAllFacilities()
    return self.grid:getAllFacilities()
end

---Get facility count
---@return number count Total facilities
function Base:getFacilityCount()
    return self.grid:getFacilityCount()
end

---Get operational facility count
---@return number count Operational facilities
function Base:getOperationalCount()
    return self.grid:getOperationalCount()
end

---Print debug information
function Base:printDebug()
    print(string.format("\n=== Base: %s ===", self.name))
    print(string.format("Province: %s, Region: %s", self.provinceId, self.regionId or "N/A"))
    print(string.format("Credits: %d, Maintenance: %d/month", self.credits, self.monthlyMaintenance))
    print(string.format("Facilities: %d total, %d operational", self:getFacilityCount(), self:getOperationalCount()))
    
    self.grid:printDebug()
    self.capacityManager:printDebug()
end

return Base



