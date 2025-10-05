--- CraftService.lua
-- Craft service for managing craft instances, operations, and lifecycle
-- Provides high-level interface for craft management across the game

-- GROK: CraftService provides high-level craft management following economy service patterns
-- GROK: Manages craft creation, assignment, operations, and integrates with other systems
-- GROK: Key methods: createCraft(), assignCraftToMission(), updateCrafts(), getCraftStatus()
-- GROK: Coordinates CraftManager, CraftClass, and ItemCraft services for complete craft operations

local class = require 'lib.Middleclass'
local CraftManager = require 'crafts.CraftManager'

--- CraftService class
-- @type CraftService
CraftService = class('CraftService')

--- Create a new CraftService instance
-- @param registry Service registry for accessing other systems
-- @return CraftService instance
function CraftService:initialize(registry)
    self.registry = registry

    -- Initialize craft manager
    self.manager = CraftManager:new({
        maxCraftsPerBase = 20,
        maintenanceInterval = 24,
        repairRate = 10,
        fuelConsumptionRate = 1.0
    })

    -- Data caches
    self.craftClasses = {} -- class_id -> CraftClass
    self.craftItems = {} -- item_id -> ItemCraft
    self.craftLevels = {} -- level -> CraftLevel

    -- Load craft data
    self:_loadCraftData()

    -- Register with service registry
    if registry then
        registry:registerService('craftService', self)
    end
end

--- Load craft-related data from data files
function CraftService:_loadCraftData()
    -- Load craft classes
    self:_loadCraftClasses()

    -- Load craft items
    self:_loadCraftItems()

    -- Load craft levels
    self:_loadCraftLevels()
end

--- Load craft classes from data
function CraftService:_loadCraftClasses()
    if not self.registry then return end

    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    -- Load craft classes
    local craftClasses = dataRegistry:getData('crafts', 'craft_class') or {}
    for _, classData in ipairs(craftClasses) do
        local craftClass = require('crafts.CraftClass'):new(classData)
        self.craftClasses[craftClass.id] = craftClass
    end
end

--- Load craft items from data
function CraftService:_loadCraftItems()
    if not self.registry then return end

    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    -- Load craft items
    local craftItems = dataRegistry:getData('crafts', 'craft_items') or {}
    for _, itemData in ipairs(craftItems) do
        local craftItem = require('crafts.ItemCraft'):new(itemData)
        self.craftItems[craftItem.id] = craftItem
    end
end

--- Load craft levels from data
function CraftService:_loadCraftLevels()
    if not self.registry then return end

    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    -- Load craft levels
    local craftLevels = dataRegistry:getData('crafts', 'craft_levels') or {}
    for _, levelData in ipairs(craftLevels) do
        local craftLevel = require('crafts.CraftLevel'):new(levelData)
        self.craftLevels[levelData.level] = craftLevel
    end
end

--- Get craft class by ID
-- @param classId The craft class ID
-- @return CraftClass instance or nil
function CraftService:getCraftClass(classId)
    return self.craftClasses[classId]
end

--- Get all craft classes
-- @return Table of craft classes (id -> class)
function CraftService:getAllCraftClasses()
    return self.craftClasses
end

--- Get craft classes available for construction
-- @param availableResearch Table of completed research
-- @param availableFacilities Table of available facilities
-- @return Array of available craft classes
function CraftService:getAvailableCraftClasses(availableResearch, availableFacilities)
    local available = {}

    for _, craftClass in pairs(self.craftClasses) do
        if craftClass:meetsRequirements(availableResearch, availableFacilities) then
            table.insert(available, craftClass)
        end
    end

    return available
end

--- Get craft item by ID
-- @param itemId The craft item ID
-- @return ItemCraft instance or nil
function CraftService:getCraftItem(itemId)
    return self.craftItems[itemId]
end

--- Get all craft items
-- @return Table of craft items (id -> item)
function CraftService:getAllCraftItems()
    return self.craftItems
end

--- Get craft items compatible with a craft type
-- @param craftType The craft type
-- @param availableResearch Table of completed research
-- @return Array of compatible items
function CraftService:getCompatibleItems(craftType, availableResearch)
    local compatible = {}

    for _, item in pairs(self.craftItems) do
        if item:isCompatibleWithCraftType(craftType) and
           item:meetsResearchRequirements(availableResearch) then
            table.insert(compatible, item)
        end
    end

    return compatible
end

--- Get craft level data
-- @param level The level number
-- @return CraftLevel instance or nil
function CraftService:getCraftLevel(level)
    return self.craftLevels[level]
end

--- Create a new craft
-- @param craftData Craft initialization data
-- @param classId The craft class ID
-- @param baseId The base to assign to
-- @return Craft instance or nil on failure
function CraftService:createCraft(craftData, classId, baseId)
    local craftClass = self:getCraftClass(classId)
    if not craftClass then
        return nil, "Craft class not found"
    end

    -- Create the craft
    local craft, error = self.manager:createCraft(craftData, craftClass, baseId, self.registry)

    if craft then
        -- Craft created successfully
    end

    return craft, error
end

--- Destroy a craft
-- @param craftId The craft ID
-- @return true if destroyed successfully
function CraftService:destroyCraft(craftId)
    local success = self.manager:destroyCraft(craftId)

    if success then
        -- Craft destroyed successfully
    end

    return success
end

--- Assign craft to a mission
-- @param craftId The craft ID
-- @param missionId The mission ID
-- @param destination Mission destination
-- @return true if assigned successfully
function CraftService:assignCraftToMission(craftId, missionId, destination)
    local craft = self.manager:getCraft(craftId)
    if not craft then
        return false, "Craft not found"
    end

    if not craft:isOperational() then
        return false, "Craft is not operational"
    end

    -- Assign to mission
    craft:assignToMission(missionId, destination)

    return true
end

--- Complete craft mission
-- @param craftId The craft ID
-- @param successful Whether mission was successful
-- @param xpReward Experience reward amount
-- @return true if completed successfully
function CraftService:completeCraftMission(craftId, successful, xpReward)
    local craft = self.manager:getCraft(craftId)
    if not craft then
        return false, "Craft not found"
    end

    -- Complete mission
    craft:completeMission(successful)

    -- Award experience
    if xpReward and xpReward > 0 then
        craft:gainExperience(xpReward, successful)
    end

    return true
end

--- Equip item on craft
-- @param craftId The craft ID
-- @param itemId The item ID
-- @param slotType The slot type (weapons, addons)
-- @param slotIndex The slot index
-- @return true if equipped successfully
function CraftService:equipItemOnCraft(craftId, itemId, slotType, slotIndex)
    local craft = self.manager:getCraft(craftId)
    if not craft then
        return false, "Craft not found"
    end

    local success, error = craft:equipItem(itemId, slotType, slotIndex)

    return success, error
end

--- Unequip item from craft
-- @param craftId The craft ID
-- @param slotType The slot type
-- @param slotIndex The slot index
-- @return The unequipped item ID or nil
function CraftService:unequipItemFromCraft(craftId, slotType, slotIndex)
    local craft = self.manager:getCraft(craftId)
    if not craft then
        return nil, "Craft not found"
    end

    local itemId = craft:unequipItem(slotType, slotIndex)

    return itemId
end

--- Transfer craft between bases
-- @param craftId The craft ID
-- @param targetBaseId The destination base ID
-- @return true if transfer initiated
function CraftService:transferCraft(craftId, targetBaseId)
    -- Calculate transfer time (simplified - would use geoscape distance)
    local transferTime = 6 -- 6 hours default

    local success = self.manager:transferCraft(craftId, targetBaseId, transferTime)

    return success
end

--- Get craft by ID
-- @param craftId The craft ID
-- @return Craft instance or nil
function CraftService:getCraft(craftId)
    return self.manager:getCraft(craftId)
end

--- Get all crafts
-- @return Table of all crafts (id -> craft)
function CraftService:getAllCrafts()
    return self.manager:getAllCrafts()
end

--- Get crafts at base
-- @param baseId The base ID
-- @return Array of craft instances
function CraftService:getCraftsAtBase(baseId)
    return self.manager:getCraftsAtBase(baseId)
end

--- Get operational crafts at base
-- @param baseId The base ID
-- @return Array of operational craft instances
function CraftService:getOperationalCraftsAtBase(baseId)
    return self.manager:getOperationalCraftsAtBase(baseId)
end

--- Get crafts available for mission
-- @param baseId The base ID
-- @param missionType The mission type
-- @return Array of available craft instances
function CraftService:getAvailableCraftsForMission(baseId, missionType)
    return self.manager:getAvailableCraftsForMission(baseId, missionType)
end

--- Update craft systems (maintenance, transfers, etc.)
-- @param hoursElapsed Hours since last update
function CraftService:updateCrafts(hoursElapsed)
    self.manager:updateMaintenance(hoursElapsed)
end

--- Get craft service statistics
-- @return Statistics table
function CraftService:getStats()
    return self.manager:getStats()
end

--- Get craft status summary
-- @param craftId The craft ID
-- @return Status table or nil
function CraftService:getCraftStatus(craftId)
    local craft = self:getCraft(craftId)
    if not craft then return nil end

    return craft:getStatus()
end

--- Get craft combat stats
-- @param craftId The craft ID
-- @return Combat stats table or nil
function CraftService:getCraftCombatStats(craftId)
    local craft = self:getCraft(craftId)
    if not craft then return nil end

    return craft:getCombatStats()
end

--- Get craft fuel status
-- @param craftId The craft ID
-- @return Fuel status table or nil
function CraftService:getCraftFuelStatus(craftId)
    local craft = self:getCraft(craftId)
    if not craft then return nil end

    return {
        current_fuel = craft:getFuel(),
        max_fuel = craft:getFuelCapacity(),
        fuel_efficiency = craft:getFuelEfficiency(),
        operational_range = craft:getOperationalRange(),
        max_range = craft:getMaxRange(),
        is_low_fuel = craft:getFuel() < (craft:getFuelCapacity() * 0.25)
    }
end

--- Refuel craft at base
-- @param craftId The craft ID
-- @param amount Amount of fuel to add (optional, fills to capacity)
-- @return success, fuel_added, cost
function CraftService:refuelCraft(craftId, amount)
    local craft = self:getCraft(craftId)
    if not craft then
        return false, 0, 0, "Craft not found"
    end

    -- Check if craft is at a base
    if not craft.baseId then
        return false, 0, 0, "Craft not at base"
    end

    -- Calculate fuel to add
    local maxFuel = craft:getFuelCapacity()
    local currentFuel = craft:getFuel()
    local fuelToAdd = amount or (maxFuel - currentFuel)
    fuelToAdd = math.min(fuelToAdd, maxFuel - currentFuel)

    if fuelToAdd <= 0 then
        return false, 0, 0, "Craft already at full fuel"
    end

    -- Calculate cost (fuel costs money)
    local fuelCostPerUnit = 10 -- Configurable fuel cost
    local totalCost = fuelToAdd * fuelCostPerUnit

    -- Check if base has enough money (via economy service)
    local economyService = self.registry and self.registry:getService('economyService')
    if economyService then
        local baseFunds = economyService:getBaseFunds(craft.baseId)
        if baseFunds < totalCost then
            return false, 0, 0, "Insufficient funds"
        end

        -- Deduct cost
        economyService:spendFunds(craft.baseId, totalCost, "Craft refueling")
    end

    -- Add fuel to craft
    local actualFuelAdded = craft:refuel(fuelToAdd)

    return true, actualFuelAdded, totalCost
end

--- Calculate mission fuel requirements
-- @param craftId The craft ID
-- @param missionData Mission data with distance, speed, duration
-- @return requirements Table with fuel_needed, range_sufficient, operational_costs
function CraftService:calculateMissionFuelRequirements(craftId, missionData)
    local craft = self:getCraft(craftId)
    if not craft then return nil end

    local distance = missionData.distance or 0
    local speed = missionData.speed or craft.speed
    local missionType = missionData.type or "patrol"
    local duration = missionData.duration or 1

    -- Calculate fuel consumption
    local fuelNeeded = craft:calculateFuelConsumption(distance, speed)
    local hasEnoughFuel, _ = craft:canTravelDistance(distance, speed)

    -- Calculate operational costs
    local operationalCosts = craft:calculateOperationalCosts(missionType, duration)

    -- Add fuel cost to operational costs
    operationalCosts.fuel_cost = operationalCosts.fuel_cost + fuelNeeded

    return {
        fuel_needed = fuelNeeded,
        range_sufficient = hasEnoughFuel,
        operational_costs = operationalCosts,
        total_cost = operationalCosts.total_cost,
        can_execute = hasEnoughFuel
    }
end

--- Execute craft movement with fuel consumption
-- @param craftId The craft ID
-- @param distance Distance to travel
-- @param speed Speed of travel
-- @return success, fuel_consumed, reached_destination
function CraftService:executeCraftMovement(craftId, distance, speed)
    local craft = self:getCraft(craftId)
    if not craft then
        return false, 0, false, "Craft not found"
    end

    -- Check if operational
    local isOperational, reason = craft:isOperational()
    if not isOperational then
        return false, 0, false, reason
    end

    -- Check fuel
    local canTravel, fuelNeeded = craft:canTravelDistance(distance, speed)
    if not canTravel then
        return false, 0, false, "Insufficient fuel"
    end

    -- Consume fuel
    local fuelConsumed, success = craft:consumeFuelForMovement(distance, speed)

    if success then
        -- Update craft position (simplified - would integrate with geoscape)
        -- craft.position = calculateNewPosition(craft.position, distance, heading)

        return true, fuelConsumed, true
    else
        return false, 0, false, "Fuel consumption failed"
    end
end

--- Get crafts with low fuel at base
-- @param baseId The base ID
-- @return Array of craft IDs with low fuel
function CraftService:getCraftsWithLowFuel(baseId)
    local crafts = self:getCraftsAtBase(baseId)
    local lowFuelCrafts = {}

    for _, craft in ipairs(crafts) do
        local fuelStatus = self:getCraftFuelStatus(craft.id)
        if fuelStatus and fuelStatus.is_low_fuel then
            table.insert(lowFuelCrafts, craft.id)
        end
    end

    return lowFuelCrafts
end

--- Get fuel consumption statistics for base
-- @param baseId The base ID
-- @param days Number of days to analyze
-- @return Statistics table with consumption data
function CraftService:getFuelConsumptionStats(baseId, days)
    days = days or 30
    local crafts = self:getCraftsAtBase(baseId)

    local totalConsumption = 0
    local totalCost = 0
    local fuelCostPerUnit = 10

    -- This would track historical consumption data
    -- For now, return basic stats
    for _, craft in ipairs(crafts) do
        -- Estimate based on craft type and typical usage
        local dailyConsumption = craft:getFuelCapacity() * 0.1 -- 10% daily average
        totalConsumption = totalConsumption + (dailyConsumption * days)
    end

    totalCost = totalConsumption * fuelCostPerUnit

    return {
        period_days = days,
        total_fuel_consumed = totalConsumption,
        total_cost = totalCost,
        average_daily_consumption = totalConsumption / days,
        crafts_analyzed = #crafts
    }
end

--- Save craft service state
-- @return Serializable state data
function CraftService:saveState()
    return {
        manager = self.manager:saveState(),
        craftClasses = self.craftClasses,
        craftItems = self.craftItems,
        craftLevels = self.craftLevels
    }
end

--- Load craft service state
-- @param state Saved state data
function CraftService:loadState(state)
    if state.manager then
        self.manager:loadState(state.manager, self.registry)
    end

    self.craftClasses = state.craftClasses or {}
    self.craftItems = state.craftItems or {}
    self.craftLevels = state.craftLevels or {}
end

--- Convert to string representation
-- @return String representation
function CraftService:__tostring()
    return string.format("CraftService{classes=%d, items=%d, crafts=%s}",
                        #self.craftClasses, #self.craftItems, tostring(self.manager))
end

return CraftService
