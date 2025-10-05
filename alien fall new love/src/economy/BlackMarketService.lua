--- Black Market Service
-- Manages illicit trading with reputation penalties and restricted access
--
-- @classmod economy.BlackMarketService

-- GROK: BlackMarketService handles high-risk trading with deterministic consequences
-- GROK: Manages black market suppliers, premium pricing, and reputation penalties
-- GROK: Key methods: isUnlocked(), getAvailableListings(), purchaseItem(), applyPenalties()
-- GROK: Integrates with reputation, transfer, and supplier systems for restricted trading

local class = require 'lib.Middleclass'
local BlackMarket = require 'economy.BlackMarket'

--- BlackMarketService class
-- @type BlackMarketService
BlackMarketService = class('BlackMarketService')

--- Create a new BlackMarketService instance
-- @param registry Service registry for accessing other systems
-- @return BlackMarketService instance
function BlackMarketService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil

    -- Initialize black market
    self.blackMarket = BlackMarket:new(registry, nil) -- Transfer manager will be set later

    -- Register with service registry
    if registry then
        registry:registerService('blackMarketService', self)
    end
end

--- Set transfer manager reference
-- @param transferManager The TransferManager instance
function BlackMarketService:setTransferManager(transferManager)
    self.blackMarket.transfer_manager = transferManager
end

--- Check if black market is unlocked
-- @return boolean Whether the black market is available
function BlackMarketService:isUnlocked()
    return self.blackMarket:is_unlocked()
end

--- Get all available black market listings
-- @return table Array of available listings
function BlackMarketService:getAvailableListings()
    if not self:isUnlocked() then
        return {}
    end

    return self.blackMarket:get_available_listings()
end

--- Get available suppliers
-- @return table Array of available supplier data
function BlackMarketService:getAvailableSuppliers()
    if not self:isUnlocked() then
        return {}
    end

    local suppliers = {}
    for _, supplier in pairs(self.blackMarket.suppliers) do
        if supplier.unlocked then
            table.insert(suppliers, {
                id = supplier.id,
                name = supplier.name,
                region = supplier.region,
                reputation_required = supplier.reputation_required
            })
        end
    end
    return suppliers
end

--- Purchase an item from the black market
-- @param supplierId The supplier ID
-- @param itemId The item ID
-- @param quantity The quantity to purchase
-- @param baseId The destination base ID
-- @return boolean Success status
-- @return string Error message if failed
function BlackMarketService:purchaseItem(supplierId, itemId, quantity, baseId)
    if not self:isUnlocked() then
        return false, "Black market not unlocked"
    end

    -- Check supplier availability
    local supplier = self.blackMarket.suppliers[supplierId]
    if not supplier or not supplier.unlocked then
        return false, "Supplier not available"
    end

    -- Check if item is available from this supplier
    if not self:_supplierHasItem(supplier, itemId) then
        return false, "Item not available from supplier"
    end

    -- Calculate price with black market markup
    local price = self:_calculateBlackMarketPrice(itemId, quantity)

    -- Check funds
    if not self:_hasSufficientFunds(price) then
        return false, "Insufficient funds"
    end

    -- Process purchase
    local success, message = self.blackMarket:process_purchase(
        supplierId, itemId, quantity, baseId
    )

    if success then
        -- Apply reputation penalties
        self:_applyReputationPenalties(supplier, itemId)

        -- Emit purchase event
        if self.eventBus then
            self.eventBus:emit('blackmarket:purchase_completed', {
                supplierId = supplierId,
                itemId = itemId,
                quantity = quantity,
                baseId = baseId,
                price = price
            })
        end
    end

    return success, message
end

--- Sell an item to the black market
-- @param itemId The item ID
-- @param quantity The quantity
-- @param baseId The source base ID
-- @return boolean Success status
-- @return string Error message if failed
function BlackMarketService:sellItem(itemId, quantity, baseId)
    if not self:isUnlocked() then
        return false, "Black market not unlocked"
    end

    -- Check if item can be sold to black market
    if not self:_canSellToBlackMarket(itemId) then
        return false, "Item cannot be sold to black market"
    end

    -- Calculate black market sell price (lower than regular market)
    local sellPrice = self:_calculateBlackMarketSellPrice(itemId, quantity)

    -- Process sale
    local success = self.blackMarket:process_sale(itemId, quantity, baseId)

    if success then
        -- Apply reputation penalties for selling restricted items
        self:_applySalePenalties(itemId)

        -- Emit sale event
        if self.eventBus then
            self.eventBus:emit('blackmarket:sale_completed', {
                itemId = itemId,
                quantity = quantity,
                baseId = baseId,
                price = sellPrice
            })
        end
    end

    return success, success and "Sale completed" or "Sale failed"
end

--- Get black market price for an item
-- @param itemId The item ID
-- @param quantity The quantity
-- @return number Black market price
function BlackMarketService:getBlackMarketPrice(itemId, quantity)
    return self:_calculateBlackMarketPrice(itemId, quantity)
end

--- Check supplier unlock status
-- @param supplierId The supplier ID
-- @return boolean Whether the supplier is unlocked
function BlackMarketService:isSupplierUnlocked(supplierId)
    local supplier = self.blackMarket.suppliers[supplierId]
    return supplier and supplier.unlocked or false
end

--- Update black market state (monthly updates)
function BlackMarketService:updateBlackMarket()
    if not self:isUnlocked() then
        return
    end

    -- Update supplier availability
    self:_updateSupplierAvailability()

    -- Restock listings
    self.blackMarket:update_listings()
end

--- Check if supplier has specific item
-- @param supplier The supplier data
-- @param itemId The item ID
-- @return boolean Whether the supplier has the item
function BlackMarketService:_supplierHasItem(supplier, itemId)
    for _, listing in ipairs(supplier.listings) do
        if listing.item_id == itemId then
            return true
        end
    end
    return false
end

--- Calculate black market purchase price
-- @param itemId The item ID
-- @param quantity The quantity
-- @return number Purchase price
function BlackMarketService:_calculateBlackMarketPrice(itemId, quantity)
    -- Get regular market price
    local marketplaceService = self.registry:getService('marketplaceService')
    local marketPrice = marketplaceService and marketplaceService:getMarketPrices(itemId)

    local basePrice = marketPrice and marketPrice.buyPrice or 100
    local blackMarketMarkup = self.blackMarket.price_multiplier or 1.5

    return (basePrice * blackMarketMarkup) * quantity
end

--- Calculate black market sell price
-- @param itemId The item ID
-- @param quantity The quantity
-- @return number Sell price
function BlackMarketService:_calculateBlackMarketSellPrice(itemId, quantity)
    -- Black market pays less than regular market
    local marketplaceService = self.registry:getService('marketplaceService')
    local marketPrice = marketplaceService and marketplaceService:getMarketPrices(itemId)

    local basePrice = marketPrice and marketPrice.sellPrice or 50
    local blackMarketDiscount = 0.7 -- 30% less than regular sell price

    return (basePrice * blackMarketDiscount) * quantity
end

--- Apply reputation penalties for black market purchase
-- @param supplier The supplier data
-- @param itemId The item ID
function BlackMarketService:_applyReputationPenalties(supplier, itemId)
    -- TODO: Apply karma and fame penalties based on item/supplier
    local penalties = { karma = -5, fame = -2 } -- Default penalties

    if self.eventBus then
        self.eventBus:emit('reputation:penalties_applied', {
            source = 'black_market_purchase',
            penalties = penalties,
            supplierId = supplier.id,
            itemId = itemId
        })
    end
end

--- Apply penalties for selling to black market
-- @param itemId The item ID
function BlackMarketService:_applySalePenalties(itemId)
    -- TODO: Apply penalties based on item type
    local penalties = { karma = -10, fame = -5 } -- Default penalties for restricted items

    if self.eventBus then
        self.eventBus:emit('reputation:penalties_applied', {
            source = 'black_market_sale',
            penalties = penalties,
            itemId = itemId
        })
    end
end

--- Update supplier availability based on current game state
function BlackMarketService:_updateSupplierAvailability()
    for _, supplier in pairs(self.blackMarket.suppliers) do
        self.blackMarket:check_supplier_unlock(supplier)
    end
end

--- Check if item can be sold to black market
-- @param itemId The item ID
-- @return boolean Whether the item can be sold
function BlackMarketService:_canSellToBlackMarket(itemId)
    -- TODO: Check item restrictions
    return true -- Placeholder
end

--- Check if player has sufficient funds
-- @param amount The required amount
-- @return boolean Whether sufficient funds exist
function BlackMarketService:_hasSufficientFunds(amount)
    -- TODO: Integrate with finance system
    return true -- Placeholder
end

return BlackMarketService
