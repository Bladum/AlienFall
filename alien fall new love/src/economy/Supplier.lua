--- Supplier.lua
-- Supplier system for Alien Fall marketplace
-- Defines supplier entities that provide marketplace items

-- GROK: Supplier represents marketplace vendors with availability, pricing, and requirements
-- GROK: Used by economy_system for dynamic marketplace and trade mechanics
-- GROK: Key methods: calculatePrice(), meetsRequirements(), isAvailableAtTechLevel()
-- GROK: Handles supplier reliability, markup rates, and access restrictions

local class = require 'lib.Middleclass'

Supplier = class('Supplier')

--- Initialize a new supplier
-- @param data The TOML data for this supplier
function Supplier:initialize(data)
    self.id = data.id
    self.name = data.name
    self.type = data.type
    self.faction = data.faction or "neutral"

    -- Location information
    self.location = data.location or {}

    -- Inventory information
    self.inventory = data.inventory or {}

    -- Availability settings
    self.availability = data.availability or {}

    -- Pricing information
    self.pricing = data.pricing or {}

    -- Requirements to access this supplier
    self.requirements = data.requirements or {}

    -- Description
    self.description = data.description or {}

    -- Validate data
    self:_validate()
end

--- Validate the supplier data
function Supplier:_validate()
    assert(self.id, "Supplier must have an id")
    assert(self.name, "Supplier must have a name")
    assert(self.type, "Supplier must have a type")

    -- Validate location
    if self.location.coordinates then
        assert(#self.location.coordinates == 2, "Coordinates must be [latitude, longitude]")
    end

    -- Validate availability
    if self.availability.base_chance then
        assert(self.availability.base_chance >= 0 and self.availability.base_chance <= 1,
               "Base chance must be between 0 and 1")
    end

    if self.availability.tech_level_range then
        assert(#self.availability.tech_level_range == 2,
               "Tech level range must be [min, max]")
    end

    -- Validate pricing
    if self.pricing.markup then
        assert(self.pricing.markup >= 0, "Markup must be non-negative")
    end
end

--- Get the supplier's location coordinates
-- @return Table {latitude, longitude} or nil
function Supplier:getCoordinates()
    return self.location.coordinates
end

--- Get the supplier's region
-- @return Region name or nil
function Supplier:getRegion()
    return self.location.region
end

--- Get the categories this supplier provides
-- @return Array of category strings
function Supplier:getCategories()
    return self.inventory.categories or {}
end

--- Check if this supplier provides items in a specific category
-- @param category The category to check
-- @return true if the supplier provides this category
function Supplier:providesCategory(category)
    local categories = self:getCategories()
    for _, cat in ipairs(categories) do
        if cat == category then
            return true
        end
    end
    return false
end

--- Get the rarity modifier for this supplier
-- @return Rarity modifier (default 1.0)
function Supplier:getRarityModifier()
    return self.inventory.rarity_modifier or 1.0
end

--- Get the base availability chance
-- @return Chance between 0 and 1 (default 1.0)
function Supplier:getBaseAvailability()
    return self.availability.base_chance or 1.0
end

--- Get the tech level range this supplier operates in
-- @return Table {min_level, max_level} or nil
function Supplier:getTechLevelRange()
    return self.availability.tech_level_range
end

--- Check if this supplier is available at a given tech level
-- @param techLevel The current tech level
-- @return true if available
function Supplier:isAvailableAtTechLevel(techLevel)
    local range = self:getTechLevelRange()
    if not range then return true end
    return techLevel >= range[1] and techLevel <= range[2]
end

--- Get the reliability rating
-- @return Reliability between 0 and 1 (default 1.0)
function Supplier:getReliability()
    return self.availability.reliability or 1.0
end

--- Get the markup percentage
-- @return Markup multiplier (default 1.0)
function Supplier:getMarkup()
    return self.pricing.markup or 1.0
end

--- Get the bulk discount threshold
-- @return Number of items needed for bulk discount (default 1)
function Supplier:getBulkDiscountThreshold()
    return self.pricing.bulk_discount_threshold or 1
end

--- Get the bulk discount rate
-- @return Discount rate (default 0.0)
function Supplier:getBulkDiscountRate()
    return self.pricing.bulk_discount_rate or 0.0
end

--- Calculate price for a given quantity
-- @param basePrice The base price of the item
-- @param quantity The quantity being purchased
-- @return The final price
function Supplier:calculatePrice(basePrice, quantity)
    local markup = self:getMarkup()
    local price = basePrice * markup

    -- Apply bulk discount if applicable
    if quantity >= self:getBulkDiscountThreshold() then
        local discount = self:getBulkDiscountRate()
        price = price * (1.0 - discount)
    end

    return math.floor(price + 0.5)  -- Round to nearest integer
end

--- Get the reputation requirement
-- @return Required reputation level (default 0)
function Supplier:getReputationRequirement()
    return self.requirements.reputation or 0
end

--- Get the required contacts
-- @return Array of required contact types
function Supplier:getRequiredContacts()
    return self.requirements.contacts or {}
end

--- Check if the player meets the requirements for this supplier
-- @param playerReputation The player's reputation level
-- @param playerContacts Table of player contacts {contact_type = true}
-- @return true if requirements met
function Supplier:meetsRequirements(playerReputation, playerContacts)
    -- Check reputation
    if playerReputation < self:getReputationRequirement() then
        return false
    end

    -- Check contacts
    local required = self:getRequiredContacts()
    for _, contact in ipairs(required) do
        if not playerContacts[contact] then
            return false
        end
    end

    return true
end

--- Get the short description
-- @return Short description string
function Supplier:getShortDescription()
    return self.description.short or self.name
end

--- Get the long description
-- @return Long description string
function Supplier:getLongDescription()
    return self.description.long or self:getShortDescription()
end

--- Get availability status description
-- @param currentTechLevel Current player tech level
-- @param playerReputation Current player reputation
-- @param playerContacts Current player contacts
-- @return String describing availability status
function Supplier:getAvailabilityStatus(currentTechLevel, playerReputation, playerContacts)
    if not self:isAvailableAtTechLevel(currentTechLevel) then
        local range = self:getTechLevelRange()
        return string.format("Requires tech level %d-%d", range[1], range[2])
    end

    if not self:meetsRequirements(playerReputation, playerContacts) then
        return "Requirements not met"
    end

    local chance = self:getBaseAvailability()
    if chance >= 0.9 then
        return "Always available"
    elseif chance >= 0.7 then
        return "Usually available"
    elseif chance >= 0.5 then
        return "Sometimes available"
    else
        return "Rarely available"
    end
end

--- Convert to string representation
-- @return String representation
function Supplier:__tostring()
    return string.format("Supplier{id='%s', name='%s', type='%s', faction='%s'}",
                        self.id, self.name, self.type, self.faction)
end

return Supplier
