--- Black Market Class
-- Manages black market transactions with reputation penalties and restricted goods
--
-- @classmod economy.BlackMarket

local class = require 'lib.Middleclass'

BlackMarket = class('BlackMarket')

--- Create a new black market instance
-- @param registry Service registry for accessing other systems
-- @param transfer_manager TransferManager instance for handling deliveries
-- @return BlackMarket instance
function BlackMarket:initialize(registry, transfer_manager)
    self.registry = registry
    self.transfer_manager = transfer_manager
    self.logger = registry and registry:logger() or nil
    self.event_bus = registry and registry:eventBus() or nil

    -- Black market state
    self.unlocked = false
    self.suppliers = {}        -- Available black market suppliers
    self.listings = {}         -- Current market listings
    self.contacts = {}         -- Established black market contacts

    -- Configuration
    self.price_multiplier = 1.5  -- Default 50% markup
    self.restock_days = 30       -- Monthly restock cycle

    -- Load black market data
    self:load_black_market_data()
end

--- Load black market configuration and supplier data
function BlackMarket:load_black_market_data()
    local data_registry = self.registry and self.registry:resolve("data_registry")
    if not data_registry then
        if self.logger then
            self.logger:warn("BlackMarket", "No data registry available")
        end
        return
    end

    -- Load black market configuration
    local config = data_registry:get("black_market") or {}
    self.price_multiplier = config.price_multiplier or 1.5
    self.restock_days = config.restock_days or 30
    self.unlock_requirements = config.unlock_requirements or {}

    -- Load supplier data
    local suppliers = data_registry:get("black_market_suppliers") or {}
    for _, supplier_data in ipairs(suppliers) do
        self:add_supplier(supplier_data)
    end

    if self.logger then
        self.logger:info("BlackMarket", string.format("Loaded %d suppliers", #suppliers))
    end
end

--- Add a black market supplier
-- @param supplier_data Supplier configuration data
function BlackMarket:add_supplier(supplier_data)
    local supplier = {
        id = supplier_data.id,
        name = supplier_data.name,
        region = supplier_data.region,
        contacts = supplier_data.contacts or {},
        reputation_required = supplier_data.reputation_required or 0,
        unlocked = false,
        listings = supplier_data.listings or {}
    }

    self.suppliers[supplier.id] = supplier

    -- Check if supplier should be unlocked
    self:check_supplier_unlock(supplier)
end

--- Check if a supplier should be unlocked based on current game state
-- @param supplier Supplier to check
function BlackMarket:check_supplier_unlock(supplier)
    -- Check reputation requirements
    if supplier.reputation_required > 0 then
        local reputation = self:get_current_reputation()
        if reputation < supplier.reputation_required then
            return false
        end
    end

    -- Check research requirements
    if supplier.research_required then
        local research_tree = self.registry and self.registry:resolve("research_tree")
        if research_tree then
            for _, research_id in ipairs(supplier.research_required) do
                if not research_tree:is_completed(research_id) then
                    return false
                end
            end
        end
    end

    -- Check contact requirements
    if supplier.contacts_required then
        for _, contact_id in ipairs(supplier.contacts_required) do
            if not self.contacts[contact_id] then
                return false
            end
        end
    end

    supplier.unlocked = true
    if self.logger then
        self.logger:info("BlackMarket", string.format("Supplier %s unlocked", supplier.id))
    end

    return true
end

--- Check if black market is unlocked for the player
-- @return boolean True if unlocked
function BlackMarket:is_unlocked()
    if self.unlocked then
        return true
    end

    -- Check unlock requirements
    for _, requirement in ipairs(self.unlock_requirements) do
        if requirement.type == "research" then
            local research_tree = self.registry and self.registry:resolve("research_tree")
            if research_tree and not research_tree:is_completed(requirement.id) then
                return false
            end
        elseif requirement.type == "reputation" then
            local reputation = self:get_current_reputation()
            if reputation < requirement.threshold then
                return false
            end
        elseif requirement.type == "narrative" then
            -- Check narrative flags (would need narrative system integration)
            if not self:check_narrative_flag(requirement.flag) then
                return false
            end
        end
    end

    self.unlocked = true
    if self.logger then
        self.logger:info("BlackMarket", "Black market unlocked for player")
    end

    -- Publish unlock event
    if self.event_bus then
        self.event_bus:publish("black_market:unlocked", {})
    end

    return true
end

--- Get current player reputation
-- @return number Current reputation score
function BlackMarket:get_current_reputation()
    -- This would integrate with a reputation/fame system
    -- For now, return a default value
    return 0
end

--- Check narrative flag (placeholder for narrative system integration)
-- @param flag Flag to check
-- @return boolean True if flag is set
function BlackMarket:check_narrative_flag(flag)
    -- Placeholder - would integrate with narrative system
    return false
end

--- Get available black market listings
-- @return table Array of available listings
function BlackMarket:get_listings()
    if not self:is_unlocked() then
        return {}
    end

    local available_listings = {}

    for _, supplier in pairs(self.suppliers) do
        if supplier.unlocked then
            for _, listing in ipairs(supplier.listings) do
                if self:check_listing_requirements(listing) then
                    -- Apply black market pricing
                    local market_listing = {
                        id = listing.id,
                        name = listing.name,
                        type = listing.type,
                        supplier_id = supplier and supplier.id or "unknown",
                        supplier_name = supplier and supplier.name or "Unknown Supplier",
                        base_price = listing.price or 0,
                        price = math.floor((listing.price or 0) * self.price_multiplier),
                        delivery_time = listing.delivery_time or 3,
                        stock = listing.stock or 1,
                        consequences = listing.consequences or {},
                        requirements = listing.requirements or {},
                        description = listing.description or ""
                    }
                    table.insert(available_listings, market_listing)
                end
            end
        end
    end

    return available_listings
end

--- Check if a listing meets all requirements
-- @param listing Listing to check
-- @return boolean True if requirements met
function BlackMarket:check_listing_requirements(listing)
    if not listing.requirements then
        return true
    end

    for _, requirement in ipairs(listing.requirements) do
        if requirement.type == "research" then
            local research_tree = self.registry and self.registry:resolve("research_tree")
            if research_tree and not research_tree:is_completed(requirement.id) then
                return false
            end
        elseif requirement.type == "contact" then
            if not self.contacts[requirement.id] then
                return false
            end
        elseif requirement.type == "reputation" then
            local reputation = self:get_current_reputation()
            if reputation < requirement.threshold then
                return false
            end
        end
    end

    return true
end

--- Purchase an item from the black market
-- @param listing_id ID of the listing to purchase
-- @param destination_base_id ID of destination base
-- @return boolean Success status
-- @return string Error message if failed
function BlackMarket:purchase(listing_id, destination_base_id)
    if not self:is_unlocked() then
        return false, "Black market not unlocked"
    end

    -- Find the listing
    local listing = nil
    local supplier = nil
    for _, s in pairs(self.suppliers) do
        if s.unlocked then
            for _, l in ipairs(s.listings) do
                if l.id == listing_id then
                    listing = l
                    supplier = s
                    break
                end
            end
            if listing then break end
        end
    end

    if not listing then
        return false, "Listing not found or unavailable"
    end

    -- Check requirements
    if not self:check_listing_requirements(listing) then
        return false, "Requirements not met"
    end

    -- Check if player can afford it
    local finance_system = self.registry and self.registry:resolve("finance")
    if finance_system and not finance_system:can_afford(listing.price) then
        return false, "Insufficient funds"
    end

    -- Apply consequences before purchase
    if not self:apply_consequences(listing.consequences or {}) then
        return false, "Unable to apply consequences"
    end

    -- Deduct funds
    if finance_system then
        finance_system:deduct_funds(listing.price)
    end

    -- Create transfer for delivery
    if self.transfer_manager then
        local transfer_payload = {
            {
                type = listing.type,
                id = listing.item_id,
                quantity = listing.quantity or 1
            }
        }

        local success, error_msg = self.transfer_manager:create_transfer(
            "void",  -- Black market origin
            destination_base_id,
            transfer_payload,
            {
                priority = "normal",
                delivery_time = listing.delivery_time or 3,
                source = "black_market",
                supplier_id = supplier.id,
                listing_id = listing_id
            }
        )

        if not success then
            return false, "Transfer creation failed: " .. error_msg
        end
    end

    -- Publish purchase event
    if self.event_bus then
        self.event_bus:publish("black_market:purchase", {
            listing_id = listing_id,
            supplier_id = supplier.id,
            price = listing.price,
            consequences = listing.consequences
        })
    end

    if self.logger then
        self.logger:info("BlackMarket", string.format("Purchased %s from %s for %d credits",
            listing_id, supplier and supplier.id or "unknown", listing.price or 0))
    end

    return true
end

--- Apply consequences of a black market transaction
-- @param consequences Array of consequence objects
-- @return boolean Success status
function BlackMarket:apply_consequences(consequences)
    for _, consequence in ipairs(consequences) do
        if consequence.type == "reputation" then
            -- Apply reputation penalty
            self:apply_reputation_penalty(consequence.value)
        elseif consequence.type == "diplomacy" then
            -- Apply diplomatic penalty
            self:apply_diplomacy_penalty(consequence.country, consequence.value)
        elseif consequence.type == "karma" then
            -- Apply karma penalty
            self:apply_karma_penalty(consequence.value)
        end
    end
    return true
end

--- Apply reputation penalty
-- @param penalty Amount to subtract from reputation
function BlackMarket:apply_reputation_penalty(penalty)
    -- Placeholder - would integrate with reputation system
    if self.logger then
        self.logger:info("BlackMarket", string.format("Applied reputation penalty: -%d", penalty))
    end
end

--- Apply diplomacy penalty
-- @param country Country to affect
-- @param penalty Amount to subtract from diplomatic relations
function BlackMarket:apply_diplomacy_penalty(country, penalty)
    -- Placeholder - would integrate with diplomacy system
    if self.logger then
        self.logger:info("BlackMarket", string.format("Applied diplomacy penalty to %s: -%d", country, penalty))
    end
end

--- Apply karma penalty
-- @param penalty Amount to subtract from karma
function BlackMarket:apply_karma_penalty(penalty)
    -- Placeholder - would integrate with karma/morality system
    if self.logger then
        self.logger:info("BlackMarket", string.format("Applied karma penalty: -%d", penalty))
    end
end

--- Sell an item on the black market
-- @param item_id ID of item to sell
-- @param quantity Quantity to sell
-- @param base_id Base where item is located
-- @return boolean Success status
-- @return string Error message if failed
function BlackMarket:sell(item_id, quantity, base_id)
    if not self:is_unlocked() then
        return false, "Black market not unlocked"
    end

    -- Find available buyer and price
    local buyer, price, consequences = self:find_buyer(item_id, quantity)

    if not buyer then
        return false, "No buyer available for this item"
    end

    -- Check if item is available in base
    local base_manager = self.registry and self.registry:resolve("base_manager")
    if base_manager and not base_manager:has_item(base_id, item_id, quantity) then
        return false, "Insufficient item quantity in base"
    end

    -- Apply consequences before sale
    if not self:apply_consequences(consequences) then
        return false, "Unable to apply consequences"
    end

    -- Remove item from base
    if base_manager then
        base_manager:remove_item(base_id, item_id, quantity)
    end

    -- Add funds
    local finance_system = self.registry and self.registry:resolve("finance")
    if finance_system then
        finance_system:add_funds(price)
    end

    -- Publish sale event
    if self.event_bus then
        self.event_bus:publish("black_market:sale", {
            item_id = item_id,
            quantity = quantity,
            buyer_id = buyer.id,
            price = price,
            consequences = consequences
        })
    end

    if self.logger then
        self.logger:info("BlackMarket", string.format("Sold %d x %s to %s for %d credits",
            quantity, item_id, buyer.id, price))
    end

    return true
end

--- Find a buyer for an item on the black market
-- @param item_id ID of item to sell
-- @param quantity Quantity available
-- @return table Buyer info, price, consequences
function BlackMarket:find_buyer(item_id, quantity)
    -- Placeholder logic - would check available black market buyers
    -- For now, return a generic buyer with reduced price
    local buyer = {
        id = "shadow_broker",
        name = "Shadow Broker"
    }

    local base_price = self:get_item_base_value(item_id)
    local price = math.floor(base_price * 0.6 * quantity)  -- 60% of base value

    local consequences = {
        {type = "karma", value = -5},
        {type = "reputation", value = -2}
    }

    return buyer, price, consequences
end

--- Get base value of an item
-- @param item_id ID of item
-- @return number Base value in credits
function BlackMarket:get_item_base_value(item_id)
    -- Placeholder - would look up item value from data
    return 100  -- Default value
end

--- Establish contact with a black market supplier
-- @param contact_id ID of contact to establish
function BlackMarket:establish_contact(contact_id)
    self.contacts[contact_id] = true

    -- Check if any suppliers are now unlocked
    for _, supplier in pairs(self.suppliers) do
        if not supplier.unlocked then
            self:check_supplier_unlock(supplier)
        end
    end

    if self.logger then
        self.logger:info("BlackMarket", string.format("Established contact: %s", contact_id))
    end
end

--- Update black market state (called daily)
function BlackMarket:update()
    -- Restock suppliers periodically
    -- This would be called by the daily update system
end

return BlackMarket
