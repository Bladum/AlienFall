---Facility - Facility Instance
---
---Represents a facility instance at a base. Each facility is placed on the base grid
---and contributes capacities and services. Facilities can be constructed, damaged,
---destroyed, and repaired.
---
---Features:
---  - Grid placement and state tracking
---  - Construction progress tracking
---  - Health and damage system
---  - Service provision/requirement
---  - Capacity calculation
---  - Connection state (linked to HQ)
---
---@module basescape.logic.facility
---@author AlienFall Development Team

local Facility = {}
Facility.__index = Facility

---States
Facility.STATE = {
    CONSTRUCTING = "constructing",
    OPERATIONAL = "operational",
    DAMAGED = "damaged",
    DESTROYED = "destroyed",
    OFFLINE = "offline",
}

---Create a new facility instance
---@param config table Facility configuration
---@return Facility facility New facility instance
function Facility.new(config)
    local self = setmetatable({}, Facility)
    
    -- Identity
    self.id = config.id or error("Facility requires id")
    self.typeId = config.typeId or error("Facility requires typeId")
    self.baseId = config.baseId or error("Facility requires baseId")
    
    -- Type reference (set by registry)
    self.type = config.type or nil
    
    -- Grid position
    self.gridX = config.gridX or error("Facility requires gridX")
    self.gridY = config.gridY or error("Facility requires gridY")
    
    -- State
    self.state = config.state or self.STATE.CONSTRUCTING
    self.constructionProgress = config.constructionProgress or 0
    self.daysBuilt = config.daysBuilt or 0
    self.totalDaysToBuild = config.totalDaysToBuild or 14
    
    -- Health
    self.health = config.health or 100
    self.maxHealth = config.maxHealth or 100
    self.armor = config.armor or 10
    
    -- Operations
    self.isConnected = config.isConnected or false
    self.isPowered = config.isPowered or false
    self.efficiency = config.efficiency or 1.0
    self.offlineReason = config.offlineReason or nil
    
    -- Dates
    self.constructedDate = config.constructedDate or nil
    self.destroyedDate = config.destroyedDate or nil
    
    return self
end

---Progress construction by one day
---@return boolean completed True if construction completed
function Facility:progressConstruction()
    if self.state ~= self.STATE.CONSTRUCTING then
        return false
    end
    
    self.daysBuilt = self.daysBuilt + 1
    self.constructionProgress = self.daysBuilt / self.totalDaysToBuild
    
    if self.daysBuilt >= self.totalDaysToBuild then
        self:complete()
        return true
    end
    
    return false
end

---Complete construction
function Facility:complete()
    self.state = self.STATE.OPERATIONAL
    self.constructionProgress = 1.0
    print(string.format("[Facility] %s construction complete at (%d,%d)", self.typeId, self.gridX, self.gridY))
end

---Take damage to the facility
---@param damage number Damage amount
function Facility:takeDamage(damage)
    if self.state == self.STATE.DESTROYED then
        return
    end
    
    -- Apply armor reduction
    local actualDamage = math.max(1, damage - self.armor)
    self.health = self.health - actualDamage
    
    if self.health <= 0 then
        self:destroy()
    elseif self.health < self.maxHealth * 0.5 then
        self:damage()
    end
    
    print(string.format("[Facility] %s took %d damage, health: %d/%d", 
        self.typeId, actualDamage, self.health, self.maxHealth))
end

---Mark facility as damaged (50% efficiency)
function Facility:damage()
    if self.state == self.STATE.DAMAGED then
        return
    end
    
    self.state = self.STATE.DAMAGED
    self.efficiency = 0.5
    print(string.format("[Facility] %s damaged, efficiency reduced to 50%%", self.typeId))
end

---Destroy facility completely
function Facility:destroy()
    self.state = self.STATE.DESTROYED
    self.efficiency = 0.0
    self.isConnected = false
    self.isPowered = false
    print(string.format("[Facility] %s DESTROYED", self.typeId))
end

---Repair facility
function Facility:repair()
    if self.state == self.STATE.OPERATIONAL then
        return false
    end
    
    self.health = self.maxHealth
    self.state = self.STATE.OPERATIONAL
    self.efficiency = 1.0
    self.offlineReason = nil
    print(string.format("[Facility] %s repaired", self.typeId))
    return true
end

---Set facility offline with reason
---@param reason string Reason for being offline
function Facility:setOffline(reason)
    self.state = self.STATE.OFFLINE
    self.offlineReason = reason
    self.efficiency = 0.0
    print(string.format("[Facility] %s offline: %s", self.typeId, reason))
end

---Check if facility is operational (can provide services/capacities)
---@return boolean True if operational
function Facility:isOperational()
    return self.state == self.STATE.OPERATIONAL and self.efficiency > 0
end

---Get effective capacity with efficiency multiplier
---@param capacityType string Capacity type
---@return number capacity Effective capacity
function Facility:getEffectiveCapacity(capacityType)
    if not self:isOperational() or not self.type then
        return 0
    end
    
    local baseCapacity = self.type:getCapacity(capacityType) or 0
    return baseCapacity * self.efficiency
end

---Get all capacities with efficiency applied
---@return table capacities Effective capacities
function Facility:getEffectiveCapacities()
    if not self:isOperational() or not self.type then
        return {}
    end
    
    local result = {}
    for capacityType, amount in pairs(self.type.capacities) do
        result[capacityType] = amount * self.efficiency
    end
    return result
end

---Check if facility provides service
---@param serviceTag string Service tag
---@return boolean True if operational and provides service
function Facility:providesService(serviceTag)
    return self:isOperational() and self.type and self.type:providesService(serviceTag)
end

---Check if facility requires service
---@param serviceTag string Service tag
---@return boolean True if requires service
function Facility:requiresService(serviceTag)
    return self.type and self.type:requiresService(serviceTag)
end

---Get construction progress percentage
---@return number progress 0-100
function Facility:getConstructionPercent()
    if self.state == self.STATE.CONSTRUCTING then
        return math.floor(self.constructionProgress * 100)
    elseif self.state == self.STATE.OPERATIONAL then
        return 100
    else
        return 0
    end
end

---Get display status
---@return string status Current status
function Facility:getStatus()
    if self.state == self.STATE.CONSTRUCTING then
        return string.format("Building: %d/%d days", self.daysBuilt, self.totalDaysToBuild)
    elseif self.state == self.STATE.DAMAGED then
        return string.format("Damaged: %d/%d HP", self.health, self.maxHealth)
    elseif self.state == self.STATE.DESTROYED then
        return "Destroyed"
    elseif self.state == self.STATE.OFFLINE then
        return "Offline: " .. (self.offlineReason or "Unknown")
    else
        return "Operational"
    end
end

---Format facility for debugging
---@return string formatted Formatted string
function Facility:__tostring()
    return string.format("Facility[%s@(%d,%d): %s]", 
        self.typeId, self.gridX, self.gridY, self:getStatus())
end

return Facility




