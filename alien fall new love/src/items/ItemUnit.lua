--- ItemUnit Class
-- Base class for items that can be equipped by units
--
-- @classmod domain.items.ItemUnit

local class = require 'lib.Middleclass'
local Item = require 'items.Item'

ItemUnit = class('ItemUnit', Item)

--- Equipment slots
ItemUnit.SLOT_HEAD = "head"
ItemUnit.SLOT_TORSO = "torso"
ItemUnit.SLOT_ARMS = "arms"
ItemUnit.SLOT_LEGS = "legs"
ItemUnit.SLOT_PRIMARY = "primary"
ItemUnit.SLOT_SECONDARY = "secondary"
ItemUnit.SLOT_UTILITY = "utility"

--- Create a new unit item instance
-- @param data Unit item data from TOML configuration
-- @return ItemUnit instance
function ItemUnit:initialize(data)
    -- Initialize parent class
    Item.initialize(self, data)

    -- Set category
    self.category = Item.CATEGORY_UNIT

    -- Equipment properties
    self.slot = data.slot or ItemUnit.SLOT_UTILITY
    self.compatible_races = data.compatible_races or {}
    self.required_level = data.required_level or 1

    -- Stats and modifiers
    self.stats = data.stats or {}
    self.bonuses = data.bonuses or {}
    self.penalties = data.penalties or {}

    -- Durability
    self.durability = data.durability or {}
    self.max_durability = self.durability.max or 100
    self.current_durability = self.durability.current or self.max_durability

    -- Energy/Ammo requirements
    self.energy_cost = data.energy_cost or 0
    self.ammo_type = data.ammo_type
    self.ammo_capacity = data.ammo_capacity or 0
    self.current_ammo = data.current_ammo or self.ammo_capacity
end

--- Get the equipment slot
-- @return string Equipment slot
function ItemUnit:getSlot()
    return self.slot
end

--- Check if item is compatible with a race
-- @param race_id Race identifier
-- @return boolean Whether compatible
function ItemUnit:isCompatibleWith(race_id)
    if #self.compatible_races == 0 then
        return true  -- No restrictions
    end

    for _, compatible_race in ipairs(self.compatible_races) do
        if compatible_race == race_id then
            return true
        end
    end
    return false
end

--- Get item stats
-- @return table Stats table
function ItemUnit:getStats()
    return self.stats
end

--- Get item bonuses
-- @return table Bonuses table
function ItemUnit:getBonuses()
    return self.bonuses
end

--- Get item penalties
-- @return table Penalties table
function ItemUnit:getPenalties()
    return self.penalties
end

--- Get current durability
-- @return number Current durability
function ItemUnit:getCurrentDurability()
    return self.current_durability
end

--- Get max durability
-- @return number Maximum durability
function ItemUnit:getMaxDurability()
    return self.max_durability
end

--- Set current durability
-- @param durability New durability value
function ItemUnit:setDurability(durability)
    self.current_durability = math.max(0, math.min(self.max_durability, durability))
end

--- Repair item durability
-- @param amount Amount to repair
-- @return number Actual amount repaired
function ItemUnit:repair(amount)
    local old_durability = self.current_durability
    self:setDurability(self.current_durability + amount)
    return self.current_durability - old_durability
end

--- Damage item durability
-- @param amount Amount of damage
-- @return number Actual damage taken
function ItemUnit:damage(amount)
    local old_durability = self.current_durability
    self:setDurability(self.current_durability - amount)
    return old_durability - self.current_durability
end

--- Check if item is broken
-- @return boolean Whether item is broken
function ItemUnit:isBroken()
    return self.current_durability <= 0
end

--- Get durability percentage
-- @return number Durability as percentage (0-1)
function ItemUnit:getDurabilityPercentage()
    return self.current_durability / self.max_durability
end

--- Check if item is equippable
-- @return boolean Whether item can be equipped (true for unit items)
function ItemUnit:isEquippable()
    return true
end

--- Get energy cost per use
-- @return number Energy cost
function ItemUnit:getEnergyCost()
    return self.energy_cost
end

--- Get ammo type
-- @return string Ammo type or nil
function ItemUnit:getAmmoType()
    return self.ammo_type
end

--- Get current ammo
-- @return number Current ammo count
function ItemUnit:getCurrentAmmo()
    return self.current_ammo
end

--- Get max ammo capacity
-- @return number Maximum ammo capacity
function ItemUnit:getAmmoCapacity()
    return self.ammo_capacity
end

--- Consume ammo
-- @param amount Amount to consume
-- @return number Actual amount consumed
function ItemUnit:consumeAmmo(amount)
    if not self.ammo_type then
        return 0
    end

    local consumed = math.min(amount, self.current_ammo)
    self.current_ammo = self.current_ammo - consumed
    return consumed
end

--- Reload ammo
-- @param amount Amount to reload
-- @return number Actual amount reloaded
function ItemUnit:reload(amount)
    if not self.ammo_type then
        return 0
    end

    local needed = self.ammo_capacity - self.current_ammo
    local reloaded = math.min(amount, needed)
    self.current_ammo = self.current_ammo + reloaded
    return reloaded
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemUnit:getData()
    local data = Item.getData(self)

    -- Add unit-specific data
    data.slot = self.slot
    data.compatible_races = self.compatible_races
    data.required_level = self.required_level
    data.stats = self.stats
    data.bonuses = self.bonuses
    data.penalties = self.penalties
    data.durability = {
        max = self.max_durability,
        current = self.current_durability
    }
    data.energy_cost = self.energy_cost
    data.ammo_type = self.ammo_type
    data.ammo_capacity = self.ammo_capacity
    data.current_ammo = self.current_ammo

    return data
end

return ItemUnit
