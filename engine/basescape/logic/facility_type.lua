---FacilityType - Facility Type Definition
---
---Defines facility type properties, capacities, costs, prerequisites, services.
---FacilityTypes are templates that facilities are created from.
---
---Features:
---  - Construction cost and time
---  - Capacity contributions
---  - Service provision/requirements
---  - Tech/facility prerequisites
---  - Maintenance costs
---  - Defense properties
---  - Special properties (max per base, etc.)
---
---@module basescape.logic.facility_type
---@author AlienFall Development Team

local FacilityType = {}
FacilityType.__index = FacilityType

---Create a new facility type definition
---@param config table Facility type configuration
---@return FacilityType type New facility type
function FacilityType.new(config)
    local self = setmetatable({}, FacilityType)
    
    -- Identity
    self.id = config.id or error("Facility type requires id")
    self.name = config.name or self.id
    self.description = config.description or ""
    
    -- Construction
    self.buildTime = config.buildTime or 14  -- Days
    self.buildCost = config.buildCost or {credits = 10000}  -- {credits, resources}
    self.buildResources = config.buildResources or {}
    
    -- Prerequisites
    self.requiredTech = config.requiredTech or {}
    self.requiredFacilities = config.requiredFacilities or {}
    
    -- Grid properties
    self.size = config.size or {width = 1, height = 1}
    
    -- Capacity contributions
    self.capacities = config.capacities or {
        item_storage = 0,
        unit_quarters = 0,
        craft_hangars = 0,
        research_capacity = 0,
        manufacturing_capacity = 0,
        defense_capacity = 0,
        prisoner_capacity = 0,
        healing_throughput = 0,
        sanity_recovery_throughput = 0,
        craft_repair_throughput = 0,
        training_throughput = 0,
        radar_range = 0,
    }
    
    -- Services
    self.servicesProvided = config.servicesProvided or {}
    self.servicesRequired = config.servicesRequired or {}
    
    -- Operations
    self.maintenanceCost = config.maintenanceCost or 1000  -- Monthly credits
    self.powerConsumption = config.powerConsumption or 0
    self.staffingRequired = config.staffingRequired or {}
    
    -- Defense
    self.health = config.health or 50
    self.armor = config.armor or 0
    self.mapBlock = config.mapBlock or nil  -- Map block ID for battlescape
    self.defenseUnits = config.defenseUnits or {}  -- Unit types provided
    
    -- Special
    self.maxPerBase = config.maxPerBase or nil  -- nil = unlimited
    self.specialFlags = config.specialFlags or {}
    self.category = config.category or "general"
    self.icon = config.icon or nil
    
    return self
end

---Get capacity contribution
---@param capacityType string Capacity type name
---@return number amount Amount provided by this facility type
function FacilityType:getCapacity(capacityType)
    return self.capacities[capacityType] or 0
end

---Check if this type provides a service
---@param serviceTag string Service tag
---@return boolean True if provided
function FacilityType:providesService(serviceTag)
    for _, service in ipairs(self.servicesProvided) do
        if service == serviceTag then
            return true
        end
    end
    return false
end

---Check if this type requires a service
---@param serviceTag string Service tag
---@return boolean True if required
function FacilityType:requiresService(serviceTag)
    for _, service in ipairs(self.servicesRequired) do
        if service == serviceTag then
            return true
        end
    end
    return false
end

---Check if type has tech requirement
---@param techId string Technology ID
---@return boolean True if required
function FacilityType:requiresTech(techId)
    for _, tech in ipairs(self.requiredTech) do
        if tech == techId then
            return true
        end
    end
    return false
end

---Check if type requires another facility type
---@param facilityTypeId string Facility type ID
---@return boolean True if required
function FacilityType:requiresFacility(facilityTypeId)
    for _, facility in ipairs(self.requiredFacilities) do
        if facility == facilityTypeId then
            return true
        end
    end
    return false
end

---Check if facility can fit in grid cell
---@param gridX number Grid X coordinate
---@param gridY number Grid Y coordinate
---@return boolean True if can fit
function FacilityType:canFitAt(gridX, gridY)
    -- Check if coordinates are valid for size
    local maxX = gridX + self.size.width - 1
    local maxY = gridY + self.size.height - 1
    
    -- Assuming 5×5 grid (indices 0-4)
    return maxX < 5 and maxY < 5
end

---Format facility type for debugging
---@return string formatted Formatted string
function FacilityType:__tostring()
    return string.format("FacilityType[%s: %s]", self.id, self.name)
end

return FacilityType




