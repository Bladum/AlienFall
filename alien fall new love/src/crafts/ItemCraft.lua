--- ItemCraft.lua
-- Craft-specific items for Alien Fall
-- Equipment and weapons designed for use by crafts/vehicles

-- GROK: ItemCraft represents equipment and weapons for aircraft/crafts
-- GROK: Used by craft_system and item_system for vehicle equipment management
-- GROK: Key methods: isCompatibleWithCraftType(), meetsResearchRequirements(), getDamage()
-- GROK: Handles craft-specific items with compatibility requirements and weapon stats

local class = require 'lib.Middleclass'

ItemCraft = class('ItemCraft')

--- Initialize a new craft item
-- @param data The TOML data for this item
function ItemCraft:initialize(data)
    self.id = data.id
    self.name = data.name
    self.type = data.type
    self.category = data.category

    -- Item stats
    self.stats = data.stats or {}

    -- Compatibility requirements
    self.requirements = data.requirements or {}

    -- Description
    self.description = data.description or {}

    -- Validate data
    self:_validate()
end

--- Validate the craft item data
function ItemCraft:_validate()
    assert(self.id, "Craft item must have an id")
    assert(self.name, "Craft item must have a name")
    assert(self.type, "Craft item must have a type")
    assert(self.category, "Craft item must have a category")
end

--- Get a specific stat value
-- @param stat The stat name
-- @return The stat value or nil if not defined
function ItemCraft:getStat(stat)
    return self.stats[stat]
end

--- Get all stats
-- @return Table of all stats
function ItemCraft:getStats()
    return self.stats
end

--- Get the craft types this item is compatible with
-- @return Array of compatible craft types
function ItemCraft:getCompatibleCraftTypes()
    return self.requirements.craft_type or {}
end

--- Check if this item is compatible with a given craft type
-- @param craftType The craft type to check
-- @return true if compatible
function ItemCraft:isCompatibleWithCraftType(craftType)
    local compatible = self:getCompatibleCraftTypes()
    if #compatible == 0 then return true end  -- No specific requirements

    for _, type in ipairs(compatible) do
        if type == craftType then
            return true
        end
    end
    return false
end

--- Get the research requirements for this item
-- @return Array of required research IDs
function ItemCraft:getResearchRequirements()
    return self.requirements.research or {}
end

--- Check if the player has the required research for this item
-- @param availableResearch Table of completed research {research_id = true}
-- @return true if requirements are met
function ItemCraft:meetsResearchRequirements(availableResearch)
    local required = self:getResearchRequirements()
    for _, researchId in ipairs(required) do
        if not availableResearch[researchId] then
            return false
        end
    end
    return true
end

--- Get the short description
-- @return Short description string
function ItemCraft:getShortDescription()
    return self.description.short or self.name
end

--- Get the long description
-- @return Long description string
function ItemCraft:getLongDescription()
    return self.description.long or self:getShortDescription()
end

--- Check if this item matches a category filter
-- @param category The category to check
-- @return true if matches
function ItemCraft:matchesCategory(category)
    return self.category == category
end

--- Check if this item matches a type filter
-- @param itemType The type to check
-- @return true if matches
function ItemCraft:matchesType(itemType)
    return self.type == itemType
end

--- Get the damage value (for weapons)
-- @return Damage value or 0 if not applicable
function ItemCraft:getDamage()
    return self.stats.damage or 0
end

--- Get the accuracy value (for weapons)
-- @return Accuracy value or 0 if not applicable
function ItemCraft:getAccuracy()
    return self.stats.accuracy or 0
end

--- Get the range value (for weapons)
-- @return Range value or 0 if not applicable
function ItemCraft:getRange()
    return self.stats.range or 0
end

--- Get the ammo capacity
-- @return Ammo capacity or 0 if not applicable
function ItemCraft:getAmmoCapacity()
    return self.stats.ammo or 0
end

--- Check if this is a weapon
-- @return true if this item is a weapon
function ItemCraft:isWeapon()
    return self.type == "weapon"
end

--- Check if this is equipment
-- @return true if this item is equipment
function ItemCraft:isEquipment()
    return self.type == "equipment"
end

--- Get a formatted display string for UI
-- @return String for display in craft equipment screens
function ItemCraft:getDisplayString()
    local display = string.format("%s (%s)", self.name, self.category)

    if self:isWeapon() then
        local damage = self:getDamage()
        local accuracy = self:getAccuracy()
        if damage > 0 then
            display = display .. string.format(" - %d dmg", damage)
        end
        if accuracy > 0 then
            display = display .. string.format(" - %d%% acc", accuracy)
        end
    end

    return display
end

--- Convert to string representation
-- @return String representation
function ItemCraft:__tostring()
    return string.format("ItemCraft{id='%s', name='%s', type='%s', category='%s'}",
                        self.id, self.name, self.type, self.category)
end

return ItemCraft
