--- PurchaseEntry.lua
-- Marketplace purchase entry system for Alien Fall
-- Defines items available for purchase with supplier dependencies

-- GROK: PurchaseEntry represents marketplace items with costs, requirements, and stats
-- GROK: Used by economy system for player purchasing mechanics
-- GROK: Validates TOML data on initialization, provides cost checking methods
-- GROK: Key methods: canAfford(), getCostString(), meetsTechRequirement()

local class = require 'lib.Middleclass'

PurchaseEntry = class('PurchaseEntry')

--- Initialize a new purchase entry
-- @param data The TOML data for this entry
function PurchaseEntry:initialize(data)
    self.id = data.id
    self.name = data.name
    self.type = data.type
    self.category = data.category

    -- Cost information
    self.cost = data.cost or {}

    -- Requirements
    self.requirements = data.requirements or {}

    -- Item stats
    self.stats = data.stats or {}

    -- Description
    self.description = data.description or {}

    -- Validate data
    self:_validate()
end

--- Validate the purchase entry data
function PurchaseEntry:_validate()
    assert(self.id, "Purchase entry must have an id")
    assert(self.name, "Purchase entry must have a name")
    assert(self.type, "Purchase entry must have a type")
    assert(self.category, "Purchase entry must have a category")

    -- Validate cost structure
    if self.cost.credits then
        assert(type(self.cost.credits) == "number" and self.cost.credits >= 0,
               "Credits cost must be a non-negative number")
    end

    if self.cost.resources then
        for resource, amount in pairs(self.cost.resources) do
            assert(type(amount) == "number" and amount >= 0,
                   string.format("Resource cost for %s must be a non-negative number", resource))
        end
    end

    -- Validate requirements
    if self.requirements.suppliers then
        assert(type(self.requirements.suppliers) == "table",
               "Suppliers requirement must be an array")
    end

    if self.requirements.tech_level then
        assert(type(self.requirements.tech_level) == "number" and self.requirements.tech_level > 0,
               "Tech level requirement must be a positive number")
    end
end

--- Get the credit cost of this item
-- @return The credit cost (0 if not specified)
function PurchaseEntry:getCreditCost()
    return self.cost.credits or 0
end

--- Get the resource costs
-- @return Table of resource costs {resource_name = amount}
function PurchaseEntry:getResourceCosts()
    return self.cost.resources or {}
end

--- Get the total cost as a formatted string
-- @return String representation of the cost
function PurchaseEntry:getCostString()
    local costs = {}

    local credits = self:getCreditCost()
    if credits > 0 then
        table.insert(costs, string.format("%d credits", credits))
    end

    local resources = self:getResourceCosts()
    for resource, amount in pairs(resources) do
        table.insert(costs, string.format("%d %s", amount, resource))
    end

    if #costs == 0 then
        return "Free"
    end

    return table.concat(costs, ", ")
end

--- Check if the player can afford this item
-- @param playerCredits Current player credits
-- @param playerResources Table of player resources {resource_name = amount}
-- @return true if affordable, false otherwise
function PurchaseEntry:canAfford(playerCredits, playerResources)
    -- Check credits
    if self:getCreditCost() > playerCredits then
        return false
    end

    -- Check resources
    local required = self:getResourceCosts()
    for resource, amount in pairs(required) do
        local available = playerResources[resource] or 0
        if available < amount then
            return false
        end
    end

    return true
end

--- Get the required suppliers for this item
-- @return Array of supplier IDs
function PurchaseEntry:getRequiredSuppliers()
    return self.requirements.suppliers or {}
end

--- Check if a supplier can provide this item
-- @param supplierId The supplier ID to check
-- @return true if the supplier can provide this item
function PurchaseEntry:canBeProvidedBy(supplierId)
    local suppliers = self:getRequiredSuppliers()
    if #suppliers == 0 then return true end  -- No specific suppliers required

    for _, supplier in ipairs(suppliers) do
        if supplier == supplierId then
            return true
        end
    end
    return false
end

--- Get the tech level requirement
-- @return The required tech level (1 if not specified)
function PurchaseEntry:getTechLevelRequirement()
    return self.requirements.tech_level or 1
end

--- Check if the player's tech level meets the requirement
-- @param playerTechLevel The player's current tech level
-- @return true if requirement met
function PurchaseEntry:meetsTechRequirement(playerTechLevel)
    return playerTechLevel >= self:getTechLevelRequirement()
end

--- Get a specific stat value
-- @param stat The stat name
-- @return The stat value or nil if not defined
function PurchaseEntry:getStat(stat)
    return self.stats[stat]
end

--- Get all stats
-- @return Table of all stats
function PurchaseEntry:getStats()
    return self.stats
end

--- Get the short description
-- @return Short description string
function PurchaseEntry:getShortDescription()
    return self.description.short or self.name
end

--- Get the long description
-- @return Long description string
function PurchaseEntry:getLongDescription()
    return self.description.long or self:getShortDescription()
end

--- Check if this item matches a category filter
-- @param category The category to check
-- @return true if matches
function PurchaseEntry:matchesCategory(category)
    return self.category == category
end

--- Check if this item matches a type filter
-- @param itemType The type to check
-- @return true if matches
function PurchaseEntry:matchesType(itemType)
    return self.type == itemType
end

--- Get a formatted display string for UI
-- @return String for display in marketplace
function PurchaseEntry:getDisplayString()
    local display = string.format("%s (%s)", self.name, self.category)
    local cost = self:getCostString()
    if cost ~= "Free" then
        display = display .. " - " .. cost
    end
    return display
end

--- Convert to string representation
-- @return String representation
function PurchaseEntry:__tostring()
    return string.format("PurchaseEntry{id='%s', name='%s', type='%s', category='%s'}",
                        self.id, self.name, self.type, self.category)
end

return PurchaseEntry
