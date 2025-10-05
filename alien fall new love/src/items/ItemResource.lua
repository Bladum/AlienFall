--- ItemResource Class
-- Represents resource items with stack-based storage and conversion capabilities
--
-- @classmod domain.items.ItemResource

local class = require 'lib.Middleclass'
local Item = require 'items.Item'

ItemResource = class('ItemResource', Item)

--- Create a new resource item instance
-- @param data Resource data from TOML configuration
-- @return ItemResource instance
function ItemResource:initialize(data)
    -- Initialize parent class
    Item.initialize(self, data)

    -- Set category
    self.category = Item.CATEGORY_RESOURCE

    -- Resource attributes (override parent defaults)
    self.tier = data.tier or self.tier
    self.rarity = data.rarity or self.rarity
    self.value = data.value or self.value

    -- Storage and stacking
    self.stack_size = data.stack_size or 100
    self.max_stacks = data.max_stacks or 10
    self.weight_per_unit = data.weight_per_unit or 1.0

    -- Set weight based on quantity and weight per unit
    self.weight = (self.quantity * self.weight_per_unit)

    -- Economic properties
    self.base_price = data.base_price or 10
    self.market_dynamics = data.market_dynamics or {}
    self.scarcity_modifier = self.market_dynamics.scarcity_modifier or 1.0

    -- Conversion and processing
    self.conversion_recipes = data.conversion_recipes or {}
    self.processing_time = data.processing_time or 0
    self.efficiency_modifier = data.efficiency_modifier or 1.0

    -- State tracking
    self.stacks = {}  -- Array of {quantity, provenance, reserved}
    self.total_quantity = self.quantity
    self.reserved_quantity = 0

    -- Fuel integration (if applicable)
    self.fuel_properties = data.fuel_properties or {}
    self.is_fuel = self.fuel_properties.is_fuel or false
    self.fuel_efficiency = self.fuel_properties.efficiency or 1.0

    return self
end

--- Add quantity to resource storage
-- @param quantity Amount to add
-- @param provenance Source of the resource
-- @return boolean Success status
function ItemResource:addQuantity(quantity, provenance)
    local remaining = quantity
    local provenance_data = provenance or "unknown"

    -- Fill existing stacks first
    for _, stack in ipairs(self.stacks) do
        if stack.quantity < self.stack_size then
            local space = self.stack_size - stack.quantity
            local add_amount = math.min(remaining, space)
            stack.quantity = stack.quantity + add_amount
            remaining = remaining - add_amount

            if remaining <= 0 then break end
        end
    end

    -- Create new stacks if needed
    while remaining > 0 and #self.stacks < self.max_stacks do
        local add_amount = math.min(remaining, self.stack_size)
        table.insert(self.stacks, {
            quantity = add_amount,
            provenance = provenance_data,
            reserved = 0
        })
        remaining = remaining - add_amount
    end

    if remaining > 0 then
        return false, "Insufficient storage capacity"
    end

    self.total_quantity = self.total_quantity + quantity
    return true
end

--- Reserve quantity for future consumption
-- @param quantity Amount to reserve
-- @param consumer Consumer identifier
-- @return boolean Success status
function ItemResource:reserve(quantity, consumer)
    if self:getAvailableQuantity() < quantity then
        return false, "Insufficient available quantity"
    end

    -- Reserve from available stacks
    local remaining = quantity
    for _, stack in ipairs(self.stacks) do
        if remaining <= 0 then break end

        local available_in_stack = stack.quantity - stack.reserved
        if available_in_stack > 0 then
            local reserve_amount = math.min(remaining, available_in_stack)
            stack.reserved = stack.reserved + reserve_amount
            remaining = remaining - reserve_amount
        end
    end

    self.reserved_quantity = self.reserved_quantity + quantity
    return true
end

--- Consume reserved quantity
-- @param quantity Amount to consume
-- @param consumer Consumer identifier
-- @return boolean Success status
function ItemResource:consume(quantity, consumer)
    if self.reserved_quantity < quantity then
        return false, "Insufficient reserved quantity"
    end

    -- Consume from reserved stacks
    local remaining = quantity
    for i = #self.stacks, 1, -1 do  -- Consume from newest stacks first
        local stack = self.stacks[i]
        if remaining <= 0 then break end

        if stack.reserved > 0 then
            local consume_amount = math.min(remaining, stack.reserved)
            stack.reserved = stack.reserved - consume_amount
            stack.quantity = stack.quantity - consume_amount
            remaining = remaining - consume_amount

            -- Remove empty stacks
            if stack.quantity <= 0 then
                table.remove(self.stacks, i)
            end
        end
    end

    self.reserved_quantity = self.reserved_quantity - quantity
    self.total_quantity = self.total_quantity - quantity
    return true
end

--- Release reserved quantity
-- @param quantity Amount to release
-- @param consumer Consumer identifier
-- @return boolean Success status
function ItemResource:release(quantity, consumer)
    if self.reserved_quantity < quantity then
        return false, "Cannot release more than reserved"
    end

    -- Release reservations from stacks
    local remaining = quantity
    for _, stack in ipairs(self.stacks) do
        if remaining <= 0 then break end

        if stack.reserved > 0 then
            local release_amount = math.min(remaining, stack.reserved)
            stack.reserved = stack.reserved - release_amount
            remaining = remaining - release_amount
        end
    end

    self.reserved_quantity = self.reserved_quantity - quantity
    return true
end

--- Get available quantity (total - reserved)
-- @return number Available quantity
function ItemResource:getAvailableQuantity()
    return self.total_quantity - self.reserved_quantity
end

--- Get total quantity
-- @return number Total quantity
function ItemResource:getTotalQuantity()
    return self.total_quantity
end

--- Get reserved quantity
-- @return number Reserved quantity
function ItemResource:getReservedQuantity()
    return self.reserved_quantity
end

--- Get stack information
-- @return table Array of stack data
function ItemResource:getStackInfo()
    local stacks_copy = {}
    for _, stack in ipairs(self.stacks) do
        table.insert(stacks_copy, {
            quantity = stack.quantity,
            provenance = stack.provenance,
            reserved = stack.reserved,
            available = stack.quantity - stack.reserved
        })
    end
    return stacks_copy
end

--- Check if resource can be converted using a recipe
-- @param recipe_id Recipe identifier
-- @return boolean True if convertible
function ItemResource:canConvert(recipe_id)
    local recipe = self.conversion_recipes[recipe_id]
    return recipe ~= nil
end

--- Get conversion recipe
-- @param recipe_id Recipe identifier
-- @return table Recipe data or nil
function ItemResource:getConversionRecipe(recipe_id)
    return self.conversion_recipes[recipe_id]
end

--- Calculate current market price
-- @param market_conditions Current market state
-- @return number Current price
function ItemResource:getCurrentPrice(market_conditions)
    local price = self.base_price

    -- Apply scarcity modifier
    price = price * self.scarcity_modifier

    -- Apply market dynamics
    if market_conditions then
        if market_conditions.supply_demand_ratio then
            price = price * market_conditions.supply_demand_ratio
        end
        if market_conditions.global_scarcity then
            price = price * market_conditions.global_scarcity
        end
    end

    return math.max(1, math.floor(price))
end

--- Get fuel properties (if applicable)
-- @return table Fuel data or nil
function ItemResource:getFuelProperties()
    if not self.is_fuel then return nil end

    return {
        efficiency = self.fuel_efficiency,
        consumption_rate = self.fuel_properties.consumption_rate or 1.0,
        energy_density = self.fuel_properties.energy_density or 1.0
    }
end

--- Get display information for UI
-- @return table Display data
function ItemResource:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        category = self.category,
        tier = self.tier,
        rarity = self.rarity,
        total_quantity = self.total_quantity,
        available_quantity = self:getAvailableQuantity(),
        reserved_quantity = self.reserved_quantity,
        stack_count = #self.stacks,
        max_stacks = self.max_stacks,
        stack_size = self.stack_size,
        current_price = self:getCurrentPrice()
    }
end

--- Get storage requirements
-- @return table Storage data
function ItemResource:getStorageRequirements()
    return {
        weight_per_unit = self.weight_per_unit,
        total_weight = self.total_quantity * self.weight_per_unit,
        stack_size = self.stack_size,
        max_stacks = self.max_stacks,
        current_stacks = #self.stacks
    }
end

return ItemResource
