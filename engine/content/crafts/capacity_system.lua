--- Craft Capacity Distribution System
--- 
--- Manages 3-tier capacity system for crafts:
--- - PILOT tier: Actual pilot slots (1-6)
--- - CREW tier: Combat troops, engineers, gunners
--- - CARGO tier: Supplies, ammunition, equipment
---
--- Capacity validation, allocation, and utilization tracking.
---
--- @module engine.content.crafts.capacity_system
--- @author AlienFall Development Team

local CapacitySystem = {}
CapacitySystem.__index = CapacitySystem

--- Capacity tier definitions
CapacitySystem.TIERS = {
    PILOT = "pilot",      -- Actual pilots (required for craft operation)
    CREW = "crew",        -- Combat troops and support staff
    CARGO = "cargo"       -- Supplies, ammo, equipment (kg)
}

--- Capacity configurations by craft type
CapacitySystem.CAPACITIES = {
    interceptor = {pilot = 1, crew = 1, cargo = 10},
    transport = {pilot = 1, crew = 10, cargo = 50},
    scout = {pilot = 1, crew = 2, cargo = 20},
    bomber = {pilot = 2, crew = 3, cargo = 100},
    sentinel = {pilot = 2, crew = 5, cargo = 75}
}

--- Initialize craft capacity
---@param craft table Craft instance
---@param craftType string Craft type
---@return table Craft with capacity initialized
function CapacitySystem:initializeCapacity(craft, craftType)
    local capacity = self.CAPACITIES[craftType] or self.CAPACITIES.interceptor
    
    craft.capacity = {
        -- Maximum capacity per tier
        max = {
            pilot = capacity.pilot,
            crew = capacity.crew,
            cargo = capacity.cargo
        },
        -- Current usage per tier
        current = {
            pilot = 0,
            crew = 0,
            cargo = 0
        },
        -- Allocated slots/weight per tier
        allocated = {
            pilot = {},      -- {pilot_id, ...}
            crew = {},       -- {unit_id, ...}
            cargo = {}       -- {item_id = quantity, ...}
        }
    }
    
    print(string.format("[CapacitySystem] Initialized capacity for %s: P:%d C:%d G:%d kg",
        craftType, capacity.pilot, capacity.crew, capacity.cargo))
    
    return craft
end

--- Add pilot to capacity tier
---@param craft table Craft instance
---@param pilotId string Pilot unit ID
---@return boolean Success
function CapacitySystem:addPilot(craft, pilotId)
    if not craft or not craft.capacity then
        return false
    end
    
    if craft.capacity.current.pilot >= craft.capacity.max.pilot then
        print(string.format("[CapacitySystem] ERROR: Pilot slots full (%d/%d)",
            craft.capacity.current.pilot, craft.capacity.max.pilot))
        return false
    end
    
    table.insert(craft.capacity.allocated.pilot, pilotId)
    craft.capacity.current.pilot = craft.capacity.current.pilot + 1
    
    return true
end

--- Remove pilot from capacity tier
---@param craft table Craft instance
---@param pilotId string Pilot unit ID
---@return boolean Success
function CapacitySystem:removePilot(craft, pilotId)
    if not craft or not craft.capacity then
        return false
    end
    
    for i, id in ipairs(craft.capacity.allocated.pilot) do
        if id == pilotId then
            table.remove(craft.capacity.allocated.pilot, i)
            craft.capacity.current.pilot = craft.capacity.current.pilot - 1
            return true
        end
    end
    
    return false
end

--- Add crew to capacity tier
---@param craft table Craft instance
---@param unitId string Unit ID
---@return boolean Success
function CapacitySystem:addCrew(craft, unitId)
    if not craft or not craft.capacity then
        return false
    end
    
    if craft.capacity.current.crew >= craft.capacity.max.crew then
        print(string.format("[CapacitySystem] ERROR: Crew slots full (%d/%d)",
            craft.capacity.current.crew, craft.capacity.max.crew))
        return false
    end
    
    table.insert(craft.capacity.allocated.crew, unitId)
    craft.capacity.current.crew = craft.capacity.current.crew + 1
    
    return true
end

--- Remove crew from capacity tier
---@param craft table Craft instance
---@param unitId string Unit ID
---@return boolean Success
function CapacitySystem:removeCrew(craft, unitId)
    if not craft or not craft.capacity then
        return false
    end
    
    for i, id in ipairs(craft.capacity.allocated.crew) do
        if id == unitId then
            table.remove(craft.capacity.allocated.crew, i)
            craft.capacity.current.crew = craft.capacity.current.crew - 1
            return true
        end
    end
    
    return false
end

--- Add cargo to capacity tier
---@param craft table Craft instance
---@param itemId string Item ID
---@param weight number Weight in kg
---@param quantity number Number of items
---@return boolean Success
function CapacitySystem:addCargo(craft, itemId, weight, quantity)
    quantity = quantity or 1
    
    if not craft or not craft.capacity then
        return false
    end
    
    local totalWeight = (weight or 1) * quantity
    
    if craft.capacity.current.cargo + totalWeight > craft.capacity.max.cargo then
        print(string.format("[CapacitySystem] ERROR: Cargo weight exceeds capacity (%d+%d > %d kg)",
            craft.capacity.current.cargo, totalWeight, craft.capacity.max.cargo))
        return false
    end
    
    craft.capacity.allocated.cargo[itemId] = (craft.capacity.allocated.cargo[itemId] or 0) + quantity
    craft.capacity.current.cargo = craft.capacity.current.cargo + totalWeight
    
    return true
end

--- Remove cargo from capacity tier
---@param craft table Craft instance
---@param itemId string Item ID
---@param weight number Weight in kg
---@param quantity number Number of items to remove
---@return boolean Success
function CapacitySystem:removeCargo(craft, itemId, weight, quantity)
    quantity = quantity or 1
    
    if not craft or not craft.capacity then
        return false
    end
    
    local current = craft.capacity.allocated.cargo[itemId] or 0
    if current < quantity then
        return false
    end
    
    local totalWeight = (weight or 1) * quantity
    craft.capacity.allocated.cargo[itemId] = current - quantity
    craft.capacity.current.cargo = math.max(0, craft.capacity.current.cargo - totalWeight)
    
    if craft.capacity.allocated.cargo[itemId] <= 0 then
        craft.capacity.allocated.cargo[itemId] = nil
    end
    
    return true
end

--- Get capacity utilization percentages
---@param craft table Craft instance
---@return table {pilot_pct, crew_pct, cargo_pct}
function CapacitySystem:getUtilization(craft)
    if not craft or not craft.capacity then
        return {pilot_pct = 0, crew_pct = 0, cargo_pct = 0}
    end
    
    return {
        pilot_pct = (craft.capacity.current.pilot / craft.capacity.max.pilot) * 100,
        crew_pct = (craft.capacity.current.crew / craft.capacity.max.crew) * 100,
        cargo_pct = (craft.capacity.current.cargo / craft.capacity.max.cargo) * 100
    }
end

--- Check if craft is full
---@param craft table Craft instance
---@return boolean Full
function CapacitySystem:isFull(craft)
    if not craft or not craft.capacity then
        return false
    end
    
    return craft.capacity.current.pilot >= craft.capacity.max.pilot and
           craft.capacity.current.crew >= craft.capacity.max.crew and
           craft.capacity.current.cargo >= craft.capacity.max.cargo
end

--- Get available capacity for tier
---@param craft table Craft instance
---@param tier string Tier name ("pilot", "crew", "cargo")
---@return number Available slots/weight
function CapacitySystem:getAvailable(craft, tier)
    if not craft or not craft.capacity then
        return 0
    end
    
    return craft.capacity.max[tier] - craft.capacity.current[tier]
end

--- Get pilots assigned to craft
---@param craft table Craft instance
---@return table Pilot IDs
function CapacitySystem:getPilots(craft)
    if not craft or not craft.capacity then
        return {}
    end
    
    return craft.capacity.allocated.pilot
end

--- Get crew assigned to craft
---@param craft table Craft instance
---@return table Unit IDs
function CapacitySystem:getCrew(craft)
    if not craft or not craft.capacity then
        return {}
    end
    
    return craft.capacity.allocated.crew
end

--- Get cargo manifest
---@param craft table Craft instance
---@return table Cargo items {item_id = quantity, ...}
function CapacitySystem:getCargo(craft)
    if not craft or not craft.capacity then
        return {}
    end
    
    return craft.capacity.allocated.cargo
end

--- Format capacity for display
---@param craft table Craft instance
---@return string Formatted string
function CapacitySystem:formatCapacity(craft)
    if not craft or not craft.capacity then
        return "No capacity data"
    end
    
    return string.format("Pilots: %d/%d | Crew: %d/%d | Cargo: %d/%d kg",
        craft.capacity.current.pilot, craft.capacity.max.pilot,
        craft.capacity.current.crew, craft.capacity.max.crew,
        craft.capacity.current.cargo, craft.capacity.max.cargo)
end

return CapacitySystem

