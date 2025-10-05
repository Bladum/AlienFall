--- Marketplace Service
-- Manages marketplace transactions, buy/sell operations, and pricing
--
-- @classmod economy.MarketplaceService

-- GROK: MarketplaceService handles buy/sell transactions with pricing and availability logic
-- GROK: Manages marketplace listings, purchase flow, and integration with transfer system
-- GROK: Key methods: getAvailableItems(), purchaseItem(), sellItem(), getMarketPrices()
-- GROK: Integrates with suppliers, finance, and transfer systems for complete transactions

local class = require 'lib.Middleclass'
local MarketManager = require 'economy.MarketManager'

--- MarketplaceService class
-- @type MarketplaceService
MarketplaceService = class('MarketplaceService')

--- Create a new MarketplaceService instance
-- @param registry Service registry for accessing other systems
-- @return MarketplaceService instance
function MarketplaceService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil

    -- Initialize market manager
    self.manager = MarketManager:new({
        researchTree = nil, -- Will be set by integration
        organization = nil, -- Will be set by integration
        suppliers = {},
        purchaseItems = {},
        unlockedSuppliers = {},
        stockLevels = {},
        config = self:_getDefaultConfig()
    })

    -- Load marketplace data
    self:_loadMarketplaceData()

    -- Register with service registry
    if registry then
        registry:registerService('marketplaceService', self)
    end
end

--- Get default configuration for marketplace
function MarketplaceService:_getDefaultConfig()
    return {
        defaultMarkup = 2.0,
        stockRefreshHours = 168, -- 1 week
        maxPurchaseQuantity = 100,
        bulkDiscountThreshold = 10
    }
end

--- Load marketplace data from data registry
function MarketplaceService:_loadMarketplaceData()
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then
        if self.logger then
            self.logger:warn("Data registry not available for loading marketplace data")
        end
        return
    end

    -- Load marketplace configuration from mod system
    local marketplaceData = dataRegistry:get("marketplace")
    if marketplaceData then
        self:_processMarketplaceData(marketplaceData)
    end
end

--- Process loaded marketplace data
-- @param data The loaded TOML data
function MarketplaceService:_processMarketplaceData(data)
    -- Process purchase items
    if data.items then
        for itemId, itemData in pairs(data.items) do
            local purchaseEntry = require('economy.PurchaseEntry'):new(itemData)
            table.insert(self.manager.purchaseItems, purchaseEntry)
        end
    end

    -- Process suppliers (get from supplier service)
    local supplierService = self.registry:getService('supplierService')
    if supplierService then
        -- Suppliers are managed by SupplierService
        self.manager.suppliers = {}
    end
end

--- Set research tree reference for requirements checking
-- @param researchTree The ResearchTree instance
function MarketplaceService:setResearchTree(researchTree)
    self.manager.researchTree = researchTree
end

--- Set organization reference for reputation checking
-- @param organization The organization instance
function MarketplaceService:setOrganization(organization)
    self.manager.organization = organization
end

--- Get all available items for purchase at a base
-- @param baseId The base ID to check availability for
-- @param regionId The region ID for regional restrictions
-- @return table Array of available item data
function MarketplaceService:getAvailableItems(baseId, regionId)
    return self.manager:getAvailableItems(baseId, regionId)
end

--- Check if an item can be purchased
-- @param itemId The item ID to check
-- @param baseId The base ID
-- @param regionId The region ID
-- @return boolean Whether the item can be purchased
function MarketplaceService:canPurchaseItem(itemId, baseId, regionId)
    return self.manager:canPurchaseItem(itemId, baseId, regionId)
end

--- Purchase an item from the marketplace
-- @param itemId The item ID to purchase
-- @param quantity The quantity to purchase
-- @param supplierId The supplier ID to purchase from
-- @param baseId The destination base ID
-- @return boolean Success status
-- @return string Error message if failed
function MarketplaceService:purchaseItem(itemId, quantity, supplierId, baseId)
    -- Use supplier service for actual purchase
    local supplierService = self.registry:getService('supplierService')
    if supplierService then
        local success, message = supplierService:purchaseFromSupplier(
            supplierId, itemId, quantity, baseId
        )

        if success and self.eventBus then
            self.eventBus:emit('marketplace:purchase_completed', {
                itemId = itemId,
                quantity = quantity,
                supplierId = supplierId,
                baseId = baseId
            })
        end

        return success, message
    end

    return false, "Supplier service not available"
end

--- Sell an item to the marketplace
-- @param itemId The item ID to sell
-- @param quantity The quantity to sell
-- @param baseId The source base ID
-- @return boolean Success status
-- @return string Error message if failed
function MarketplaceService:sellItem(itemId, quantity, baseId)
    -- Check if item exists at base
    if not self:_hasItemAtBase(itemId, baseId, quantity) then
        return false, "Insufficient items at base"
    end

    -- Calculate sell price
    local sellPrice = self:_calculateSellPrice(itemId, quantity)

    -- Process sale
    local success = self:_processSale(itemId, quantity, baseId, sellPrice)

    if success and self.eventBus then
        self.eventBus:emit('marketplace:sale_completed', {
            itemId = itemId,
            quantity = quantity,
            baseId = baseId,
            price = sellPrice
        })
    end

    return success, success and "Sale completed" or "Sale failed"
end

--- Get market price information for an item
-- @param itemId The item ID to check
-- @return table Price information {buyPrice, sellPrice, suppliers}
function MarketplaceService:getMarketPrices(itemId)
    local item = self:_getPurchaseItem(itemId)
    if not item then return nil end

    local suppliers = self.manager:_getItemSuppliers(itemId)
    local bestPrice = self.manager:_calculateBestPrice(item, suppliers)
    local sellPrice = self:_calculateSellPrice(itemId, 1)

    return {
        itemId = itemId,
        buyPrice = bestPrice,
        sellPrice = sellPrice,
        suppliers = suppliers
    }
end

--- Get stock information for an item
-- @param itemId The item ID to check
-- @param supplierId Optional supplier ID to filter by
-- @return table Stock information
function MarketplaceService:getStockInfo(itemId, supplierId)
    return self.manager:_getItemStockInfo(itemId, supplierId)
end

--- Update marketplace state (called periodically)
function MarketplaceService:updateMarketplace()
    -- Update stock levels
    self.manager:_updateStockLevels()

    -- Check for supplier unlocks
    self:_checkSupplierUnlocks()
end

--- Check for newly unlocked suppliers
function MarketplaceService:_checkSupplierUnlocks()
    -- TODO: Implement supplier unlock checking based on research/conditions
end

--- Calculate sell price for an item
-- @param itemId The item ID
-- @param quantity The quantity
-- @return number Sell price
function MarketplaceService:_calculateSellPrice(itemId, quantity)
    -- Base sell price is typically 50% of buy price
    local buyPrice = self:getMarketPrices(itemId)
    if buyPrice then
        return (buyPrice.buyPrice * 0.5) * quantity
    end
    return 0
end

--- Check if base has sufficient items for sale
-- @param itemId The item ID
-- @param baseId The base ID
-- @param quantity The required quantity
-- @return boolean Whether sufficient items exist
function MarketplaceService:_hasItemAtBase(itemId, baseId, quantity)
    -- TODO: Integrate with base inventory system
    return true -- Placeholder
end

--- Process a sale transaction
-- @param itemId The item ID
-- @param quantity The quantity
-- @param baseId The base ID
-- @param sellPrice The sell price
-- @return boolean Success status
function MarketplaceService:_processSale(itemId, quantity, baseId, sellPrice)
    -- TODO: Remove items from base inventory
    -- TODO: Add credits to player funds
    return true -- Placeholder
end

--- Get purchase item by ID
-- @param itemId The item ID
-- @return PurchaseEntry|nil The item or nil if not found
function MarketplaceService:_getPurchaseItem(itemId)
    return self.manager:_getPurchaseItem(itemId)
end

return MarketplaceService
