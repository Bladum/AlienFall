--- Craft.lua
-- Individual craft entity for Alien Fall
-- Represents a specific aircraft/vehicle instance with stats, equipment, and operational state

-- GROK: Craft represents individual aircraft instances with equipment, experience, and mission state
-- GROK: Used by CraftService for managing craft lifecycle, equipment, and operations
-- GROK: Key methods: equipItem(), calculateStats(), gainExperience(), isOperational()
-- GROK: Handles craft-specific state including damage, fuel, location, and mission assignments

local class = require 'lib.Middleclass'
local CraftEnergyPool = require 'crafts.CraftEnergyPool'

--- Craft class representing an individual aircraft/vehicle
-- @type Craft
Craft = class('Craft')

--- Create a new Craft instance
-- @param data Craft initialization data
-- @param craftClass The craft class template
-- @param registry Service registry for accessing other systems
-- @return Craft instance
function Craft:initialize(data, craftClass, registry)
    self.id = data.id
    self.name = data.name or data.id
    self.craftClass = craftClass
    self.registry = registry

    -- Basic properties
    self.baseId = data.baseId or "unknown"
    self.status = data.status or "hangar" -- hangar, en_route, intercepting, returning, destroyed
    self.condition = data.condition or 100 -- health percentage

    -- Experience and progression
    self.experience = data.experience or 0
    self.level = data.level or 1
    self.missions_completed = data.missions_completed or 0
    self.successful_missions = data.successful_missions or 0
    self.damage_repairs = data.damage_repairs or 0

    -- Equipment and loadout
    self.equipment = data.equipment or {
        weapons = {},
        addons = {},
        cargo = {}
    }

    -- Operational state
    self.fuel = data.fuel or craftClass:getStat("fuel_capacity") or 100
    self.energyPool = CraftEnergyPool(craftClass:getStat("energy_pool") or 100, 0.7)

    -- Location and movement
    self.position = data.position or {x = 0, y = 0}
    self.heading = data.heading or 0
    self.speed = data.speed or 0

    -- Calculate derived stats
    self:_calculateDerivedStats()

    -- Validate initial state
    self:_validate()
end

--- Calculate derived statistics based on class, level, and equipment
function Craft:_calculateDerivedStats()
    -- Start with base class stats
    self.stats = {
        speed = self.craftClass:getCapability("speed") or 1,
        armor = self.craftClass:getCapability("armor") or 1,
        fuel_capacity = self.craftClass:getStat("fuel_capacity") or 100,
        fuel_efficiency = self.craftClass:getStat("fuel_efficiency") or 1.0,
        range = self.craftClass:getStat("max_range") or 1000,
        unit_capacity = self.craftClass:getStat("unit_capacity") or 8,
        weapon_slots = self.craftClass:getStat("weapon_slots") or 2,
        addon_slots = self.craftClass:getStat("addon_slots") or 1,
        cargo_capacity = self.craftClass:getStat("cargo_capacity") or 50,
        radar_range = self.craftClass:getStat("radar_range") or 0,
        stealth_modifier = self.craftClass:getStat("stealth_modifier") or 0,
        energy_pool = self.craftClass:getStat("energy_pool") or 100
    }

    -- Apply level modifiers (if we have level data)
    if self.registry then
        local levelService = self.registry:getService('craftLevelService')
        if levelService then
            local levelData = levelService:getLevelData(self.level)
            if levelData then
                for stat, modifier in pairs(levelData.capabilities or {}) do
                    if self.stats[stat] then
                        self.stats[stat] = self.stats[stat] * modifier
                    end
                end
            end
        end
    end

    -- Apply equipment modifiers
    self:_applyEquipmentModifiers()
end

--- Apply equipment modifiers to stats
function Craft:_applyEquipmentModifiers()
    -- Reset equipment bonuses
    self.equipmentBonuses = {
        speed = 0,
        armor = 0,
        radar_range = 0,
        stealth_modifier = 0,
        energy_pool = 0
    }

    -- Apply weapon modifiers
    for _, weaponId in ipairs(self.equipment.weapons or {}) do
        local weaponData = self:_getItemData(weaponId)
        if weaponData and weaponData.stats then
            for stat, bonus in pairs(weaponData.stats) do
                if self.equipmentBonuses[stat] then
                    self.equipmentBonuses[stat] = self.equipmentBonuses[stat] + bonus
                end
            end
        end
    end

    -- Apply addon modifiers
    for _, addonId in ipairs(self.equipment.addons or {}) do
        local addonData = self:_getItemData(addonId)
        if addonData and addonData.stats then
            for stat, bonus in pairs(addonData.stats) do
                if self.equipmentBonuses[stat] then
                    self.equipmentBonuses[stat] = self.equipmentBonuses[stat] + bonus
                end
            end
        end
    end

    -- Apply bonuses to final stats
    for stat, bonus in pairs(self.equipmentBonuses) do
        if self.stats[stat] then
            self.stats[stat] = self.stats[stat] + bonus
        end
    end
end

--- Get item data from registry
-- @param itemId The item ID to look up
-- @return Item data or nil
function Craft:_getItemData(itemId)
    if not self.registry then return nil end
    local itemService = self.registry:getService('itemService')
    if itemService then
        return itemService:getItem(itemId)
    end
    return nil
end

--- Validate craft state
function Craft:_validate()
    assert(self.id, "Craft must have an id")
    assert(self.craftClass, "Craft must have a craft class")
    assert(self.condition >= 0 and self.condition <= 100, "Condition must be between 0 and 100")
    assert(self.fuel >= 0, "Fuel cannot be negative")
end

--- Equip an item in the specified slot
-- @param itemId The item to equip
-- @param slotType The slot type (weapons, addons, cargo)
-- @param slotIndex The slot index (optional)
-- @return true if equipped successfully
function Craft:equipItem(itemId, slotType, slotIndex)
    -- Validate slot type
    if not self.equipment[slotType] then
        return false, "Invalid slot type"
    end

    -- Check if item is compatible
    local itemData = self:_getItemData(itemId)
    if not itemData then
        return false, "Item not found"
    end

    -- Check compatibility with craft type
    if not itemData:isCompatibleWithCraftType(self.craftClass.type) then
        return false, "Item not compatible with craft type"
    end

    -- Check slot capacity
    local maxSlots = self.stats[slotType .. "_slots"] or 0
    if #self.equipment[slotType] >= maxSlots then
        return false, "No available slots"
    end

    -- Equip the item
    if slotIndex then
        self.equipment[slotType][slotIndex] = itemId
    else
        table.insert(self.equipment[slotType], itemId)
    end

    -- Recalculate stats
    self:_calculateDerivedStats()

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:equipment_changed', {
            craftId = self.id,
            itemId = itemId,
            slotType = slotType
        })
    end

    return true
end

--- Unequip an item from the specified slot
-- @param slotType The slot type
-- @param slotIndex The slot index
-- @return The unequipped item ID or nil
function Craft:unequipItem(slotType, slotIndex)
    if not self.equipment[slotType] or not self.equipment[slotType][slotIndex] then
        return nil
    end

    local itemId = self.equipment[slotType][slotIndex]
    table.remove(self.equipment[slotType], slotIndex)

    -- Recalculate stats
    self:_calculateDerivedStats()

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:equipment_changed', {
            craftId = self.id,
            itemId = nil,
            slotType = slotType
        })
    end

    return itemId
end

--- Gain experience from mission completion
-- @param xpAmount Amount of experience gained
-- @param missionSuccessful Whether the mission was successful
function Craft:gainExperience(xpAmount, missionSuccessful)
    self.experience = self.experience + xpAmount
    self.missions_completed = self.missions_completed + 1

    if missionSuccessful then
        self.successful_missions = self.successful_missions + 1
    end

    -- Check for level up
    self:_checkLevelUp()

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:experience_gained', {
            craftId = self.id,
            xpGained = xpAmount,
            newTotal = self.experience,
            newLevel = self.level
        })
    end
end

--- Check if craft should level up
function Craft:_checkLevelUp()
    if not self.registry then return end

    local levelService = self.registry:getService('craftLevelService')
    if not levelService then return end

    local nextLevel = self.level + 1
    local levelData = levelService:getLevelData(nextLevel)

    if levelData and self.experience >= levelData.experience_required then
        self.level = nextLevel
        self:_calculateDerivedStats()

        -- Emit level up event
        if self.registry.eventBus then
            self.registry.eventBus:emit('craft:level_up', {
                craftId = self.id,
                newLevel = self.level
            })
        end
    end
end

--- Take damage from combat
-- @param damage Amount of damage taken
-- @param damageType Type of damage (optional)
function Craft:takeDamage(damage, damageType)
    -- Apply armor reduction
    local actualDamage = damage * (1.0 / self.stats.armor)
    self.condition = math.max(0, self.condition - actualDamage)

    -- Check for destruction
    if self.condition <= 0 then
        self.status = "destroyed"
        self.damage_repairs = self.damage_repairs + 1
    end

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:damaged', {
            craftId = self.id,
            damage = actualDamage,
            newCondition = self.condition,
            destroyed = self.condition <= 0
        })
    end
end

--- Repair craft damage
-- @param repairAmount Amount to repair (0-100)
function Craft:repair(repairAmount)
    if self.status == "destroyed" then
        self.condition = math.min(100, repairAmount)
        if self.condition > 0 then
            self.status = "hangar"
        end
    else
        self.condition = math.min(100, self.condition + repairAmount)
    end

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:repaired', {
            craftId = self.id,
            repairAmount = repairAmount,
            newCondition = self.condition
        })
    end
end

--- Get current fuel level
function Craft:getFuel()
    return self.fuel
end

--- Get maximum fuel capacity
function Craft:getFuelCapacity()
    return self.stats.fuel_capacity
end

--- Get fuel efficiency modifier
function Craft:getFuelEfficiency()
    return self.stats.fuel_efficiency
end

--- Get maximum operational range
function Craft:getMaxRange()
    return self.stats.range
end

--- Calculate fuel consumption for a given distance
-- @param distance The distance to travel
-- @param speed The speed at which to travel (optional, uses current speed)
-- @return fuel_consumed The amount of fuel that would be consumed
function Craft:calculateFuelConsumption(distance, speed)
    speed = speed or self.speed
    if speed <= 0 then return 0 end

    -- Base consumption = distance / fuel_efficiency
    -- Speed modifier = speed^2 / 100 (faster = more fuel)
    local baseConsumption = distance / self.stats.fuel_efficiency
    local speedModifier = (speed * speed) / 100
    local totalConsumption = baseConsumption * speedModifier

    return math.max(1, math.floor(totalConsumption))
end

--- Check if craft has enough fuel for a given distance
-- @param distance The distance to check
-- @param speed The speed at which to travel (optional, uses current speed)
-- @return can_travel True if craft has enough fuel
-- @return fuel_needed The fuel that would be consumed
function Craft:canTravelDistance(distance, speed)
    local fuelNeeded = self:calculateFuelConsumption(distance, speed)
    return self.fuel >= fuelNeeded, fuelNeeded
end

--- Consume fuel for movement
-- @param distance The distance traveled
-- @param speed The speed at which traveled (optional, uses current speed)
-- @return fuel_consumed The actual fuel consumed
-- @return success True if movement was possible
function Craft:consumeFuelForMovement(distance, speed)
    local fuelNeeded = self:calculateFuelConsumption(distance, speed)
    if self.fuel >= fuelNeeded then
        self.fuel = self.fuel - fuelNeeded
        return fuelNeeded, true
    else
        return 0, false
    end
end

--- Refuel the craft
-- @param amount The amount of fuel to add (optional, fills to capacity)
-- @return fuel_added The actual fuel added
function Craft:refuel(amount)
    local maxFuel = self.stats.fuel_capacity
    local currentFuel = self.fuel
    local fuelToAdd = amount or (maxFuel - currentFuel)

    fuelToAdd = math.min(fuelToAdd, maxFuel - currentFuel)
    self.fuel = self.fuel + fuelToAdd

    return fuelToAdd
end

--- Calculate operational range at current fuel level
-- @param speed The speed to calculate range for (optional, uses current speed)
-- @return range The operational range in distance units
function Craft:getOperationalRange(speed)
    speed = speed or self.speed
    if speed <= 0 then return 0 end

    -- Range = fuel * fuel_efficiency / speed_modifier
    local speedModifier = (speed * speed) / 100
    local range = (self.fuel * self.stats.fuel_efficiency) / speedModifier

    return math.floor(range)
end

--- Calculate operational costs for a mission
-- @param missionType The type of mission ("patrol", "intercept", "transfer", "strike")
-- @param duration The mission duration in hours
-- @return costs Table with fuel_cost, maintenance_cost, total_cost
function Craft:calculateOperationalCosts(missionType, duration)
    duration = duration or 1

    -- Base fuel consumption per hour based on mission type
    local fuelPerHour = {
        patrol = 2,
        intercept = 5,
        transfer = 3,
        strike = 8
    }

    local baseFuelCost = fuelPerHour[missionType] or 2
    local fuelCost = baseFuelCost * duration

    -- Maintenance cost (percentage of craft value per hour)
    local craftValue = self.craftClass:getStat("cost") or 1000
    local maintenanceRate = 0.01 -- 1% of craft value per hour
    local maintenanceCost = craftValue * maintenanceRate * duration

    -- Equipment maintenance for weapons and addons
    local equipmentCost = 0
    for _, weapon in ipairs(self.weapons) do
        equipmentCost = equipmentCost + (weapon:getMaintenanceCost() * duration)
    end
    for _, addon in ipairs(self.addons) do
        equipmentCost = equipmentCost + (addon:getMaintenanceCost() * duration)
    end

    local totalCost = fuelCost + maintenanceCost + equipmentCost

    return {
        fuel_cost = fuelCost,
        maintenance_cost = maintenanceCost,
        equipment_cost = equipmentCost,
        total_cost = totalCost
    }
end

--- Check if craft is operational (has fuel, not damaged, etc.)
-- @return is_operational True if craft can operate
-- @return reason String explaining why if not operational
function Craft:isOperational()
    if self.fuel <= 0 then
        return false, "Out of fuel"
    end

    if self.health <= 0 then
        return false, "Destroyed"
    end

    if self.status == "damaged" then
        return false, "Under repair"
    end

    return true, nil
end

--- Assign craft to a mission
-- @param missionId The mission ID
-- @param destination Destination coordinates
function Craft:assignToMission(missionId, destination)
    self.currentMission = missionId
    self.destination = destination
    self.status = "en_route"

    -- Calculate ETA based on distance and speed
    local distance = self:_calculateDistance(destination)
    self.eta = distance / self.stats.speed

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:mission_assigned', {
            craftId = self.id,
            missionId = missionId,
            destination = destination,
            eta = self.eta
        })
    end
end

--- Complete current mission
-- @param successful Whether mission was successful
function Craft:completeMission(successful)
    if self.currentMission then
        self:gainExperience(10, successful) -- Base XP reward
        self.currentMission = nil
        self.destination = nil
        self.eta = nil
        self.status = "returning"
    end

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:mission_completed', {
            craftId = self.id,
            successful = successful
        })
    end
end

--- Return to base
function Craft:returnToBase()
    self.status = "hangar"
    self.position = {x = 0, y = 0} -- Reset to base position

    -- Emit event
    if self.registry and self.registry.eventBus then
        self.registry.eventBus:emit('craft:returned_to_base', {
            craftId = self.id
        })
    end
end

--- Calculate distance to destination
-- @param destination Target coordinates
-- @return Distance in game units
function Craft:_calculateDistance(destination)
    local dx = destination.x - self.position.x
    local dy = destination.y - self.position.y
    return math.sqrt(dx * dx + dy * dy)
end

--- Get craft status summary
-- @return Status table
function Craft:getStatus()
    return {
        id = self.id,
        name = self.name,
        status = self.status,
        condition = self.condition,
        fuel = self.fuel,
        fuel_capacity = self.stats.fuel_capacity,
        level = self.level,
        experience = self.experience,
        missions_completed = self.missions_completed,
        current_mission = self.currentMission,
        eta = self.eta,
        operational = self:isOperational()
    }
end

--- Get craft combat stats
-- @return Combat stats table
function Craft:getCombatStats()
    return {
        speed = self.stats.speed,
        armor = self.stats.armor,
        weapon_slots = self.stats.weapon_slots,
        addon_slots = self.stats.addon_slots,
        energy_pool = self.energyPool:getEnergyStatus(),
        weapons = self.equipment.weapons,
        addons = self.equipment.addons
    }
end

--- Convert to string representation
-- @return String representation
function Craft:__tostring()
    return string.format("Craft{id='%s', name='%s', class='%s', status='%s', condition=%d%%}",
                        self.id, self.name, self.craftClass.name, self.status, self.condition)
end

return Craft
