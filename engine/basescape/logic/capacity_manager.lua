---CapacityManager - Capacity Aggregation and Tracking
---
---Aggregates capacities from all operational facilities in a base and tracks usage.
---Provides methods to check and allocate capacities.
---
---Features:
---  - Aggregate capacities from facilities
---  - Track usage per capacity type
---  - Check availability
---  - Allocate/deallocate capacity
---
---Capacity Types:
---  - item_storage: Item inventory slots
---  - unit_quarters: Personnel housing slots
---  - craft_hangars: Craft storage slots
---  - research_capacity: Concurrent research projects
---  - manufacturing_capacity: Concurrent manufacturing projects
---  - defense_capacity: Defense strength for base defense missions
---  - prisoner_capacity: Alien prisoner cells
---  - healing_throughput: Personnel healing capacity (units per day)
---  - sanity_recovery_throughput: Sanity recovery capacity (units per day)
---  - craft_repair_throughput: Craft repair capacity (units per day)
---  - training_throughput: Training capacity (units per day)
---  - radar_range: Radar detection range (km, max is sum of all)
---
---@module basescape.logic.capacity_manager
---@author AlienFall Development Team

local CapacityManager = {}
CapacityManager.__index = CapacityManager

---Capacity type definitions
CapacityManager.CAPACITY_TYPES = {
    "item_storage",
    "unit_quarters",
    "craft_hangars",
    "research_capacity",
    "manufacturing_capacity",
    "defense_capacity",
    "prisoner_capacity",
    "healing_throughput",
    "sanity_recovery_throughput",
    "craft_repair_throughput",
    "training_throughput",
    "radar_range",
}

---Create new capacity manager for a base
---@param baseId string Base identifier
---@return CapacityManager manager New manager
function CapacityManager.new(baseId)
    local self = setmetatable({}, CapacityManager)
    
    self.baseId = baseId
    self.grid = nil  -- Set by caller
    
    -- Aggregated capacities
    self.capacities = {}
    self:_initCapacities()
    
    -- Usage tracking
    self.usage = {}
    self:_initUsage()
    
    return self
end

---Initialize capacity table
function CapacityManager:_initCapacities()
    for _, capType in ipairs(CapacityManager.CAPACITY_TYPES) do
        self.capacities[capType] = 0
    end
end

---Initialize usage table
function CapacityManager:_initUsage()
    for _, capType in ipairs(CapacityManager.CAPACITY_TYPES) do
        self.usage[capType] = 0
    end
end

---Set grid reference and recalculate
---@param grid table BaseGrid instance
function CapacityManager:setGrid(grid)
    self.grid = grid
    self:recalculate()
end

---Recalculate total capacities from all operational facilities
function CapacityManager:recalculate()
    if not self.grid then
        return
    end
    
    -- Reset capacities
    self:_initCapacities()
    
    -- Sum from all operational facilities
    for _, facility in ipairs(self.grid:getAllFacilities()) do
        if facility:isOperational() then
            local effectiveCaps = facility:getEffectiveCapacities()
            for capType, amount in pairs(effectiveCaps) do
                self.capacities[capType] = (self.capacities[capType] or 0) + amount
            end
        end
    end
    
    print(string.format("[CapacityManager] Recalculated for %s", self.baseId))
end

---Get total capacity for a type
---@param capacityType string Capacity type
---@return number capacity Total capacity
function CapacityManager:getCapacity(capacityType)
    return self.capacities[capacityType] or 0
end

---Get usage for a type
---@param capacityType string Capacity type
---@return number usage Current usage
function CapacityManager:getUsage(capacityType)
    return self.usage[capacityType] or 0
end

---Get available capacity for a type
---@param capacityType string Capacity type
---@return number available Available capacity
function CapacityManager:getAvailable(capacityType)
    return math.max(0, self:getCapacity(capacityType) - self:getUsage(capacityType))
end

---Check if can allocate capacity
---@param capacityType string Capacity type
---@param amount number Amount to allocate
---@return boolean canAllocate True if enough capacity
function CapacityManager:canAllocate(capacityType, amount)
    return self:getAvailable(capacityType) >= amount
end

---Allocate capacity
---@param capacityType string Capacity type
---@param amount number Amount to allocate
---@return boolean success True if allocated
function CapacityManager:allocate(capacityType, amount)
    if self:canAllocate(capacityType, amount) then
        self.usage[capacityType] = self.usage[capacityType] + amount
        print(string.format("[CapacityManager] Allocated %d to %s (usage: %d/%d)", 
            amount, capacityType, self.usage[capacityType], self.capacities[capacityType]))
        return true
    else
        print(string.format("[CapacityManager] Cannot allocate %d to %s (available: %d)", 
            amount, capacityType, self:getAvailable(capacityType)))
        return false
    end
end

---Deallocate capacity
---@param capacityType string Capacity type
---@param amount number Amount to deallocate
---@return boolean success True if deallocated
function CapacityManager:deallocate(capacityType, amount)
    local current = self.usage[capacityType]
    if current >= amount then
        self.usage[capacityType] = current - amount
        print(string.format("[CapacityManager] Deallocated %d from %s (usage: %d/%d)", 
            amount, capacityType, self.usage[capacityType], self.capacities[capacityType]))
        return true
    else
        print(string.format("[CapacityManager] Cannot deallocate %d from %s (current: %d)", 
            amount, capacityType, current))
        return false
    end
end

---Get percentage used for a capacity type
---@param capacityType string Capacity type
---@return number percent 0-100
function CapacityManager:getUsagePercent(capacityType)
    local cap = self:getCapacity(capacityType)
    if cap == 0 then
        return 0
    end
    return math.min(100, (self:getUsage(capacityType) / cap) * 100)
end

---Print debug info
function CapacityManager:printDebug()
    print(string.format("\n[CapacityManager %s] Capacity Report:", self.baseId))
    
    for _, capType in ipairs(CapacityManager.CAPACITY_TYPES) do
        local cap = self:getCapacity(capType)
        local used = self:getUsage(capType)
        local available = self:getAvailable(capType)
        local percent = self:getUsagePercent(capType)
        
        if cap > 0 then
            print(string.format("  %-30s: %5d/%5d (used: %5d, avail: %5d) [%3d%%]",
                capType, used, cap, used, available, percent))
        end
    end
end

---Get all capacities as table
---@return table capacities Table of capacity_type -> available
function CapacityManager:getAllAvailable()
    local result = {}
    for _, capType in ipairs(CapacityManager.CAPACITY_TYPES) do
        result[capType] = self:getAvailable(capType)
    end
    return result
end

return CapacityManager
