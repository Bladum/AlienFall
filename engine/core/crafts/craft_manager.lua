--- Craft Management System - Fleet management and operations
---
--- Manages player crafts including deployment, fuel tracking, maintenance,
--- crew assignments, and operational status. Coordinates craft operations
--- across geoscape missions and interception events.
---
--- Key Responsibilities:
--- - Fleet inventory and status tracking
--- - Craft deployment and travel management
--- - Fuel consumption and refueling
--- - Maintenance and repair scheduling
--- - Crew assignments and loadouts
--- - Craft upgrades and equipment
---
--- Usage:
---   local CraftManager = require("engine.core.crafts.craft_manager")
---   local manager = CraftManager:new()
---   manager:addCraft(craftData)
---   manager:deployCraft("craft_1", pathProvinces)
---   manager:refuelCraft("craft_1")
---
--- @module engine.core.crafts.craft_manager
--- @author AlienFall Development Team

local CraftManager = {}
CraftManager.__index = CraftManager

--- Initialize Craft Manager
---@return table CraftManager instance
function CraftManager:new()
    local self = setmetatable({}, CraftManager)
    
    self.crafts = {}  -- {id = Craft instance}
    self.nextId = 1
    self.hangarCapacity = 10  -- Max crafts per base
    self.deployedCrafts = {}  -- {id = Craft} - deployed crafts
    self.maintenanceQueue = {}  -- Crafts needing maintenance
    self.fuelReserve = 100000  -- Global fuel reserves
    
    print("[CraftManager] Initialized")
    
    return self
end

--- Add craft to fleet
---@param craftData table Craft data
---@return table Craft instance
function CraftManager:addCraft(craftData)
    craftData.id = "craft_" .. self.nextId
    self.nextId = self.nextId + 1
    
    local craft = {
        id = craftData.id,
        name = craftData.name or ("Craft " .. craftData.id),
        type = craftData.type or "interceptor",
        baseId = craftData.baseId,
        
        -- Status
        health = craftData.health or 100,
        maxHealth = craftData.maxHealth or 100,
        fuel = craftData.fuelCapacity or 100,
        fuelCapacity = craftData.fuelCapacity or 100,
        
        -- Stats
        speed = craftData.speed or 1.0,
        range = craftData.range or 10,
        armor = craftData.armor or 5,
        
        -- Loadout
        crew = {},  -- {unit_id, ...}
        equipment = {},  -- {item_id, ...}
        weapons = {},  -- {weapon_id, ...}
        
        -- Status
        isDeployed = false,
        isInMaintenance = false,
        canIntercept = true,
        missionAssigned = nil,
        
        -- Travel
        currentProvince = nil,
        targetProvince = nil,
        pathToTarget = {},
        travelProgress = 0
    }
    
    self.crafts[craft.id] = craft
    
    print(string.format("[CraftManager] Added craft: %s (%s) - ID: %s",
        craft.name, craft.type, craft.id))
    
    return craft
end

--- Get craft by ID
---@param craftId string Craft ID
---@return table? Craft or nil
function CraftManager:getCraft(craftId)
    return self.crafts[craftId]
end

--- Get all crafts
---@return table List of crafts
function CraftManager:getAllCrafts()
    local all = {}
    for _, craft in pairs(self.crafts) do
        table.insert(all, craft)
    end
    return all
end

--- Get crafts by type
---@param craftType string Craft type (interceptor, transport, scout)
---@return table List of crafts
function CraftManager:getCraftsByType(craftType)
    local result = {}
    for _, craft in pairs(self.crafts) do
        if craft.type == craftType then
            table.insert(result, craft)
        end
    end
    return result
end

--- Get active crafts (not in maintenance)
---@return table List of active crafts
function CraftManager:getActiveCrafts()
    local result = {}
    for _, craft in pairs(self.crafts) do
        if not craft.isInMaintenance then
            table.insert(result, craft)
        end
    end
    return result
end

--- Get deployed crafts
---@return table List of deployed crafts
function CraftManager:getDeployedCrafts()
    local result = {}
    for _, craft in pairs(self.crafts) do
        if craft.isDeployed then
            table.insert(result, craft)
        end
    end
    return result
end

--- Deploy craft to target
---@param craftId string Craft ID
---@param targetProvince string Target province ID
---@param path table? Planned path (optional)
---@return boolean Success
function CraftManager:deployCraft(craftId, targetProvince, path)
    local craft = self:getCraft(craftId)
    if not craft then
        print("[CraftManager] ERROR: Craft not found: " .. craftId)
        return false
    end
    
    if craft.isInMaintenance then
        print("[CraftManager] ERROR: Craft in maintenance: " .. craft.name)
        return false
    end
    
    if craft.fuel < 10 then
        print("[CraftManager] ERROR: Insufficient fuel: " .. craft.name)
        return false
    end
    
    craft.isDeployed = true
    craft.targetProvince = targetProvince
    craft.pathToTarget = path or {targetProvince}
    craft.travelProgress = 0
    
    print(string.format("[CraftManager] Deployed %s to %s", craft.name, targetProvince))
    
    return true
end

--- Recall deployed craft to base
---@param craftId string Craft ID
---@return boolean Success
function CraftManager:recallCraft(craftId)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    if not craft.isDeployed then
        return false
    end
    
    craft.isDeployed = false
    craft.targetProvince = nil
    craft.pathToTarget = {}
    
    print(string.format("[CraftManager] Recalled %s to base", craft.name))
    
    return true
end

--- Update craft travel progress
---@param craftId string Craft ID
---@param deltaTime number Time elapsed
---@return boolean Reached destination
function CraftManager:updateCraftTravel(craftId, deltaTime)
    local craft = self:getCraft(craftId)
    if not craft or not craft.isDeployed then
        return false
    end
    
    -- Consume fuel during travel
    local fuelPerSecond = 0.1
    craft.fuel = craft.fuel - (fuelPerSecond * deltaTime)
    
    -- Update progress
    craft.travelProgress = craft.travelProgress + (craft.speed * deltaTime)
    
    -- Check if reached destination
    if craft.travelProgress >= 1.0 then
        craft.travelProgress = 0
        if craft.pathToTarget and #craft.pathToTarget > 0 then
            craft.currentProvince = craft.pathToTarget[#craft.pathToTarget]
        end
        
        if craft.currentProvince == craft.targetProvince then
            craft.isDeployed = false
            print(string.format("[CraftManager] %s reached destination", craft.name))
            return true
        end
    end
    
    return false
end

--- Refuel craft
---@param craftId string Craft ID
---@param amount number? Amount to refuel (nil = full)
---@return boolean Success
function CraftManager:refuelCraft(craftId, amount)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    if amount then
        amount = math.min(amount, self.fuelReserve)
        craft.fuel = math.min(craft.fuel + amount, craft.fuelCapacity)
        self.fuelReserve = self.fuelReserve - amount
    else
        local needed = craft.fuelCapacity - craft.fuel
        needed = math.min(needed, self.fuelReserve)
        craft.fuel = craft.fuel + needed
        self.fuelReserve = self.fuelReserve - needed
    end
    
    print(string.format("[CraftManager] Refueled %s | Fuel: %.1f/%.1f | Reserve: %.1f",
        craft.name, craft.fuel, craft.fuelCapacity, self.fuelReserve))
    
    return true
end

--- Schedule maintenance on craft
---@param craftId string Craft ID
---@return boolean Success
function CraftManager:maintenanceCraft(craftId)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    if craft.isDeployed then
        print("[CraftManager] ERROR: Cannot maintain deployed craft")
        return false
    end
    
    craft.isInMaintenance = true
    table.insert(self.maintenanceQueue, craftId)
    
    print(string.format("[CraftManager] Scheduled maintenance: %s", craft.name))
    
    return true
end

--- Complete maintenance on craft
---@param craftId string Craft ID
---@return boolean Success
function CraftManager:completeMaintenance(craftId)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    craft.isInMaintenance = false
    craft.health = craft.maxHealth
    
    -- Remove from maintenance queue
    for i, id in ipairs(self.maintenanceQueue) do
        if id == craftId then
            table.remove(self.maintenanceQueue, i)
            break
        end
    end
    
    print(string.format("[CraftManager] Completed maintenance: %s", craft.name))
    
    return true
end

--- Damage craft
---@param craftId string Craft ID
---@param damage number Damage amount
---@return boolean Success
function CraftManager:damageCraft(craftId, damage)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    craft.health = math.max(0, craft.health - damage)
    
    if craft.health <= 0 then
        print(string.format("[CraftManager] %s destroyed!", craft.name))
        craft.canIntercept = false
    else
        print(string.format("[CraftManager] %s damaged | Health: %.1f%%",
            craft.name, (craft.health / craft.maxHealth) * 100))
    end
    
    return true
end

--- Assign crew to craft
---@param craftId string Craft ID
---@param unitId string Unit ID
---@return boolean Success
function CraftManager:assignCrew(craftId, unitId)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    if #craft.crew >= 6 then  -- Max crew size
        print("[CraftManager] ERROR: Craft crew is full")
        return false
    end
    
    table.insert(craft.crew, unitId)
    print(string.format("[CraftManager] Assigned crew to %s | Total: %d",
        craft.name, #craft.crew))
    
    return true
end

--- Remove crew from craft
---@param craftId string Craft ID
---@param unitId string Unit ID
---@return boolean Success
function CraftManager:removeCrew(craftId, unitId)
    local craft = self:getCraft(craftId)
    if not craft then
        return false
    end
    
    for i, id in ipairs(craft.crew) do
        if id == unitId then
            table.remove(craft.crew, i)
            print(string.format("[CraftManager] Removed crew from %s | Total: %d",
                craft.name, #craft.crew))
            return true
        end
    end
    
    return false
end

--- Get craft status
---@param craftId string Craft ID
---@return table? Status info or nil
function CraftManager:getCraftStatus(craftId)
    local craft = self:getCraft(craftId)
    if not craft then
        return {status = "not_found"}
    end
    
    return {
        id = craft.id,
        name = craft.name,
        type = craft.type,
        health = craft.health,
        maxHealth = craft.maxHealth,
        healthPercent = (craft.health / craft.maxHealth) * 100,
        fuel = craft.fuel,
        fuelCapacity = craft.fuelCapacity,
        fuelPercent = (craft.fuel / craft.fuelCapacity) * 100,
        isDeployed = craft.isDeployed,
        isInMaintenance = craft.isInMaintenance,
        crewCount = #craft.crew,
        equipmentCount = #craft.equipment,
        canIntercept = craft.canIntercept
    }
end

--- Get fleet status
---@return table Fleet status
function CraftManager:getFleetStatus()
    local total = 0
    local active = 0
    local deployed = 0
    local inMaintenance = 0
    
    for _, craft in pairs(self.crafts) do
        total = total + 1
        if not craft.isInMaintenance then
            active = active + 1
        end
        if craft.isDeployed then
            deployed = deployed + 1
        end
        if craft.isInMaintenance then
            inMaintenance = inMaintenance + 1
        end
    end
    
    return {
        totalCrafts = total,
        activeCrafts = active,
        deployedCrafts = deployed,
        maintenanceCrafts = inMaintenance,
        fuelReserve = self.fuelReserve
    }
end

--- Get fleet status string
---@return string Status report
function CraftManager:getStatus()
    local status = self:getFleetStatus()
    
    local report = string.format(
        "Fleet Status:\n" ..
        "  Total Crafts: %d\n" ..
        "  Active: %d | Deployed: %d | Maintenance: %d\n" ..
        "  Fuel Reserve: %.1f",
        status.totalCrafts,
        status.activeCrafts,
        status.deployedCrafts,
        status.maintenanceCrafts,
        status.fuelReserve
    )
    
    return report
end

--- Serialize for save/load
---@return table Serialized data
function CraftManager:serialize()
    return {
        crafts = self.crafts,
        nextId = self.nextId,
        fuelReserve = self.fuelReserve,
        maintenanceQueue = self.maintenanceQueue
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function CraftManager:deserialize(data)
    self.crafts = data.crafts
    self.nextId = data.nextId
    self.fuelReserve = data.fuelReserve
    self.maintenanceQueue = data.maintenanceQueue
    print("[CraftManager] Deserialized from save")
end

return CraftManager
