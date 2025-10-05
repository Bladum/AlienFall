--- ItemCraft Class
-- Base class for items that can be equipped on crafts
--
-- @classmod domain.items.ItemCraft

local class = require 'lib.Middleclass'
local Item = require 'items.Item'

ItemCraft = class('ItemCraft', Item)

--- Craft equipment slots
ItemCraft.SLOT_HULL = "hull"
ItemCraft.SLOT_ENGINE = "engine"
ItemCraft.SLOT_WEAPON = "weapon"
ItemCraft.SLOT_SHIELD = "shield"
ItemCraft.SLOT_SENSOR = "sensor"
ItemCraft.SLOT_UTILITY = "utility"

--- Create a new craft item instance
-- @param data Craft item data from TOML configuration
-- @return ItemCraft instance
function ItemCraft:initialize(data)
    -- Initialize parent class
    Item.initialize(self, data)

    -- Set category
    self.category = Item.CATEGORY_CRAFT

    -- Equipment properties
    self.slot = data.slot or ItemCraft.SLOT_UTILITY
    self.compatible_crafts = data.compatible_crafts or {}
    self.required_tech = data.required_tech or {}

    -- Stats and modifiers
    self.stats = data.stats or {}
    self.bonuses = data.bonuses or {}
    self.penalties = data.penalties or {}

    -- Durability and maintenance
    self.durability = data.durability or {}
    self.max_durability = self.durability.max or 100
    self.current_durability = self.durability.current or self.max_durability

    -- Energy and resource requirements
    self.energy_consumption = data.energy_consumption or 0
    self.maintenance_cost = data.maintenance_cost or 0
    self.operational_cost = data.operational_cost or 0

    -- Special properties
    self.range = data.range or 0
    self.accuracy = data.accuracy or 0
    self.damage = data.damage or 0
    self.defense = data.defense or 0
end

--- Get the equipment slot
-- @return string Equipment slot
function ItemCraft:getSlot()
    return self.slot
end

--- Check if item is compatible with a craft type
-- @param craft_type Craft type identifier
-- @return boolean Whether compatible
function ItemCraft:isCompatibleWith(craft_type)
    if #self.compatible_crafts == 0 then
        return true  -- No restrictions
    end

    for _, compatible_craft in ipairs(self.compatible_crafts) do
        if compatible_craft == craft_type then
            return true
        end
    end
    return false
end

--- Check if required technology is available
-- @param available_tech Table of available technologies
-- @return boolean Whether requirements are met
function ItemCraft:meetsTechRequirements(available_tech)
    for _, tech_id in ipairs(self.required_tech) do
        if not available_tech[tech_id] then
            return false
        end
    end
    return true
end

--- Get item stats
-- @return table Stats table
function ItemCraft:getStats()
    return self.stats
end

--- Get item bonuses
-- @return table Bonuses table
function ItemCraft:getBonuses()
    return self.bonuses
end

--- Get item penalties
-- @return table Penalties table
function ItemCraft:getPenalties()
    return self.penalties
end

--- Get current durability
-- @return number Current durability
function ItemCraft:getCurrentDurability()
    return self.current_durability
end

--- Get max durability
-- @return number Maximum durability
function ItemCraft:getMaxDurability()
    return self.max_durability
end

--- Set current durability
-- @param durability New durability value
function ItemCraft:setDurability(durability)
    self.current_durability = math.max(0, math.min(self.max_durability, durability))
end

--- Repair item durability
-- @param amount Amount to repair
-- @return number Actual amount repaired
function ItemCraft:repair(amount)
    local old_durability = self.current_durability
    self:setDurability(self.current_durability + amount)
    return self.current_durability - old_durability
end

--- Damage item durability
-- @param amount Amount of damage
-- @return number Actual damage taken
function ItemCraft:damage(amount)
    local old_durability = self.current_durability
    self:setDurability(self.current_durability - amount)
    return old_durability - self.current_durability
end

--- Check if item is broken
-- @return boolean Whether item is broken
function ItemCraft:isBroken()
    return self.current_durability <= 0
end

--- Get durability percentage
-- @return number Durability as percentage (0-1)
function ItemCraft:getDurabilityPercentage()
    return self.current_durability / self.max_durability
end

--- Check if item is equippable
-- @return boolean Whether item can be equipped (true for craft items)
function ItemCraft:isEquippable()
    return true
end

--- Get energy consumption per turn
-- @return number Energy consumption
function ItemCraft:getEnergyConsumption()
    return self.energy_consumption
end

--- Get maintenance cost per turn
-- @return number Maintenance cost
function ItemCraft:getMaintenanceCost()
    return self.maintenance_cost
end

--- Get operational cost per mission
-- @return number Operational cost
function ItemCraft:getOperationalCost()
    return self.operational_cost
end

--- Get weapon range (for weapons)
-- @return number Range value
function ItemCraft:getRange()
    return self.range
end

--- Get weapon accuracy (for weapons)
-- @return number Accuracy value
function ItemCraft:getAccuracy()
    return self.accuracy
end

--- Get weapon damage (for weapons)
-- @return number Damage value
function ItemCraft:getDamage()
    return self.damage
end

--- Get defense value (for shields/armor)
-- @return number Defense value
function ItemCraft:getDefense()
    return self.defense
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemCraft:getData()
    local data = Item.getData(self)

    -- Add craft-specific data
    data.slot = self.slot
    data.compatible_crafts = self.compatible_crafts
    data.required_tech = self.required_tech
    data.stats = self.stats
    data.bonuses = self.bonuses
    data.penalties = self.penalties
    data.durability = {
        max = self.max_durability,
        current = self.current_durability
    }
    data.energy_consumption = self.energy_consumption
    data.maintenance_cost = self.maintenance_cost
    data.operational_cost = self.operational_cost
    data.range = self.range
    data.accuracy = self.accuracy
    data.damage = self.damage
    data.defense = self.defense

    return data
end

return ItemCraft
