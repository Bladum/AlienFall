--- MarketManager.lua
-- Marketplace management system for Alien Fall
-- Controls what can be bought/sold based on research and region unlocks

-- GROK: MarketManager controls marketplace availability and transactions
-- GROK: Integrates with research tree, suppliers, and reputation systems
-- GROK: Key methods: getAvailableItems(), canPurchaseItem(), processPurchase()
-- GROK: Manages supplier unlocks, regional restrictions, and stock levels

local class = require 'lib.Middleclass'

MarketManager = class('MarketManager')

--- Initialize a new market manager
-- @param data The market manager configuration
function MarketManager:initialize(data)
    -- Core systems integration
    self.eventBus = self:_getEventBus()
    self.researchTree = data.researchTree
    self.organization = data.organization  -- For reputation checks

    -- Supplier and item data
    self.suppliers = data.suppliers or {}  -- Array of Supplier objects
    self.purchaseItems = data.purchaseItems or {}  -- Array of PurchaseEntry objects

    -- Market state
    self.unlockedSuppliers = data.unlockedSuppliers or {}
    self.stockLevels = data.stockLevels or {}  -- supplierId -> itemId -> quantity
    self.lastStockReset = data.lastStockReset or 0

    -- Configuration
    self.config = data.config or self:_getDefaultConfig()

    -- Validate data
    self:_validate()
end

--- Get the event bus for integration
function MarketManager:_getEventBus()
    local registry = require 'services.registry'
    return registry:getService('eventBus')
end

--- Validate the market manager data
function MarketManager:_validate()
    assert(self.researchTree, "Market manager requires a research tree")
    assert(self.organization, "Market manager requires an organization system")

    -- Validate suppliers
    for i, supplier in ipairs(self.suppliers) do
        assert(supplier.id, "Supplier " .. i .. " must have an id")
        assert(supplier.name, "Supplier " .. i .. " must have a name")
    end

    -- Validate purchase items
    for i, item in ipairs(self.purchaseItems) do
        assert(item.id, "Purchase item " .. i .. " must have an id")
        assert(item.name, "Purchase item " .. i .. " must have a name")
    end
end

--- Get all available items for purchase at a specific base
-- @param baseId The base ID to check availability for
-- @param regionId The region ID for regional restrictions
function MarketManager:getAvailableItems(baseId, regionId)
    local availableItems = {}

    for _, item in ipairs(self.purchaseItems) do
        if self:canPurchaseItem(item.id, baseId, regionId) then
            local suppliers = self:_getItemSuppliers(item.id)
            local stockInfo = self:_getItemStockInfo(item.id)

            table.insert(availableItems, {
                item = item,
                suppliers = suppliers,
                stockInfo = stockInfo,
                bestPrice = self:_calculateBestPrice(item, suppliers)
            })
        end
    end

    return availableItems
end

--- Check if an item can be purchased
-- @param itemId The item ID to check
-- @param baseId The base ID (for regional restrictions)
-- @param regionId The region ID (for regional restrictions)
function MarketManager:canPurchaseItem(itemId, baseId, regionId)
    local item = self:_getPurchaseItem(itemId)
    if not item then return false end

    -- Check research requirements
    if not self:_meetsResearchRequirements(item) then
        return false
    end

    -- Check reputation requirements
    if not self:_meetsReputationRequirements(item) then
        return false
    end

    -- Check regional restrictions
    if not self:_meetsRegionalRequirements(item, regionId) then
        return false
    end

    -- Check supplier availability
    local availableSuppliers = self:_getAvailableSuppliersForItem(itemId)
    if #availableSuppliers == 0 then
        return false
    end

    -- Check stock availability
    if not self:_hasAvailableStock(itemId) then
        return false
    end

    return true
end

--- Process a purchase transaction
-- @param itemId The item to purchase
-- @param quantity The quantity to purchase
-- @param supplierId The supplier to purchase from
-- @param baseId The destination base
function MarketManager:processPurchase(itemId, quantity, supplierId, baseId)
    local item = self:_getPurchaseItem(itemId)
    local supplier = self:_getSupplier(supplierId)

    if not item or not supplier then
        return false, "Invalid item or supplier"
    end

    -- Validate purchase requirements
    if not self:canPurchaseItem(itemId, baseId) then
        return false, "Item not available for purchase"
    end

    -- Check stock availability
    local availableStock = self:_getItemStock(itemId, supplierId)
    if availableStock < quantity then
        return false, "Insufficient stock"
    end

    -- Calculate cost
    local cost = self:_calculatePurchaseCost(item, supplier, quantity)

    -- Check if player can afford
    if not self:_canAfford(cost) then
        return false, "Insufficient funds"
    end

    -- Process the transaction
    local success = self:_executePurchase(item, quantity, supplier, cost, baseId)

    if success then
        -- Update stock
        self:_reduceStock(itemId, supplierId, quantity)

        -- Apply reputation effects
        self:_applyReputationEffects(item)

        -- Emit purchase event
        self:_emitPurchaseEvent(item, quantity, supplier, cost, baseId)

        return true, "Purchase successful"
    else
        return false, "Purchase failed"
    end
end

--- Get suppliers that can provide a specific item
-- @param itemId The item ID to check
function MarketManager:_getItemSuppliers(itemId)
    local suppliers = {}

    for _, supplier in ipairs(self.suppliers) do
        if self:_supplierHasItem(supplier, itemId) and self:_isSupplierUnlocked(supplier.id) then
            table.insert(suppliers, supplier)
        end
    end

    return suppliers
end

--- Get available suppliers for an item (unlocked and accessible)
-- @param itemId The item ID to check
function MarketManager:_getAvailableSuppliersForItem(itemId)
    local suppliers = {}

    for _, supplier in ipairs(self.suppliers) do
        if self:_supplierHasItem(supplier, itemId) and
           self:_isSupplierUnlocked(supplier.id) and
           self:_supplierMeetsRequirements(supplier) then
            table.insert(suppliers, supplier)
        end
    end

    return suppliers
end

--- Check if a supplier has an item in stock
-- @param supplier The supplier object
-- @param itemId The item ID to check
function MarketManager:_supplierHasItem(supplier, itemId)
    if not supplier.inventory then return false end

    for _, itemEntry in ipairs(supplier.inventory) do
        if itemEntry.id == itemId then
            return true
        end
    end

    return false
end

--- Check if a supplier is unlocked
-- @param supplierId The supplier ID to check
function MarketManager:_isSupplierUnlocked(supplierId)
    return self.unlockedSuppliers[supplierId] == true
end

--- Check if a supplier meets all requirements
-- @param supplier The supplier object
function MarketManager:_supplierMeetsRequirements(supplier)
    -- Check research requirements
    if supplier.requirements and supplier.requirements.research then
        for _, researchId in ipairs(supplier.requirements.research) do
            if not self.researchTree:isCompleted(researchId) then
                return false
            end
        end
    end

    -- Check reputation requirements
    if supplier.requirements and supplier.requirements.karma then
        if self.organization:getKarma() < supplier.requirements.karma then
            return false
        end
    end

    if supplier.requirements and supplier.requirements.fame then
        if self.organization:getFame() < supplier.requirements.fame then
            return false
        end
    end

    return true
end

--- Check if research requirements are met for an item
-- @param item The purchase item
function MarketManager:_meetsResearchRequirements(item)
    if not item.requirements or not item.requirements.research then
        return true
    end

    for _, researchId in ipairs(item.requirements.research) do
        if not self.researchTree:isCompleted(researchId) then
            return false
        end
    end

    return true
end

--- Check if reputation requirements are met for an item
-- @param item The purchase item
function MarketManager:_meetsReputationRequirements(item)
    if not item.requirements then return true end

    if item.requirements.karma and self.organization:getKarma() < item.requirements.karma then
        return false
    end

    if item.requirements.fame and self.organization:getFame() < item.requirements.fame then
        return false
    end

    return true
end

--- Check if regional requirements are met for an item
-- @param item The purchase item
-- @param regionId The current region ID
function MarketManager:_meetsRegionalRequirements(item, regionId)
    if not item.requirements or not item.requirements.region then
        return true
    end

    -- Check if item is restricted to specific regions
    if item.requirements.region.restricted then
        local allowed = false
        for _, allowedRegion in ipairs(item.requirements.region.allowed) do
            if allowedRegion == regionId then
                allowed = true
                break
            end
        end
        if not allowed then return false end
    end

    return true
end

--- Get stock information for an item across all suppliers
-- @param itemId The item ID to check
function MarketManager:_getItemStockInfo(itemId)
    local stockInfo = {}

    for _, supplier in ipairs(self.suppliers) do
        if self:_supplierHasItem(supplier, itemId) then
            local stock = self:_getItemStock(itemId, supplier.id)
            stockInfo[supplier.id] = {
                available = stock,
                supplier = supplier
            }
        end
    end

    return stockInfo
end

--- Get stock level for a specific item from a supplier
-- @param itemId The item ID
-- @param supplierId The supplier ID
function MarketManager:_getItemStock(itemId, supplierId)
    if not self.stockLevels[supplierId] then
        self.stockLevels[supplierId] = {}
    end

    return self.stockLevels[supplierId][itemId] or 0
end

--- Check if an item has any available stock
-- @param itemId The item ID to check
function MarketManager:_hasAvailableStock(itemId)
    for _, supplier in ipairs(self.suppliers) do
        if self:_getItemStock(itemId, supplier.id) > 0 then
            return true
        end
    end

    return false
end

--- Calculate the best price for an item across suppliers
-- @param item The purchase item
-- @param suppliers Array of available suppliers
function MarketManager:_calculateBestPrice(item, suppliers)
    if #suppliers == 0 then return nil end

    local bestPrice = math.huge
    local bestSupplier = nil

    for _, supplier in ipairs(suppliers) do
        local price = self:_calculateItemPrice(item, supplier)
        if price < bestPrice then
            bestPrice = price
            bestSupplier = supplier
        end
    end

    return {
        price = bestPrice,
        supplier = bestSupplier
    }
end

--- Calculate purchase cost for an item from a supplier
-- @param item The purchase item
-- @param supplier The supplier
-- @param quantity The quantity to purchase
function MarketManager:_calculatePurchaseCost(item, supplier, quantity)
    local unitPrice = self:_calculateItemPrice(item, supplier)
    return unitPrice * quantity
end

--- Calculate price for a single item from a supplier
-- @param item The purchase item
-- @param supplier The supplier
function MarketManager:_calculateItemPrice(item, supplier)
    local basePrice = item.cost.credits or 0

    -- Apply supplier markup
    local markup = supplier.pricing and supplier.pricing.markup or 1.0
    local price = basePrice * markup

    -- Apply reputation discounts
    local discount = self:_calculateReputationDiscount(supplier)
    price = price * (1 - discount)

    return math.floor(price)
end

--- Calculate reputation-based discount
-- @param supplier The supplier
function MarketManager:_calculateReputationDiscount(supplier)
    local discount = 0

    -- Fame-based discounts
    local fame = self.organization:getFame()
    if fame >= 80 then
        discount = discount + 0.1  -- 10% discount for high fame
    elseif fame <= 20 then
        discount = discount - 0.1  -- 10% surcharge for low fame
    end

    -- Karma-based discounts (for black market)
    if supplier.faction == "black_market" then
        local karma = self.organization:getKarma()
        if karma <= -50 then
            discount = discount + 0.15  -- 15% discount for very low karma
        elseif karma >= 50 then
            discount = discount - 0.2  -- 20% surcharge for high karma
        end
    end

    return discount
end

--- Check if player can afford a purchase
-- @param cost The cost in credits
function MarketManager:_canAfford(cost)
    -- This would integrate with the finance system
    -- For now, assume unlimited credits
    return true
end

--- Execute the actual purchase
-- @param item The purchase item
-- @param quantity The quantity purchased
-- @param supplier The supplier
-- @param cost The total cost
-- @param baseId The destination base
function MarketManager:_executePurchase(item, quantity, supplier, cost, baseId)
    -- Create transfer order for delivery
    local transferData = {
        id = "purchase_" .. item.id .. "_" .. os.time(),
        originBaseId = "void",  -- Market deliveries come from void
        destinationBaseId = baseId,
        priority = "normal",
        payload = {{
            type = item.type,
            id = item.id,
            quantity = quantity,
            size = item.stats and item.stats.size or 1,
            volume = item.stats and item.stats.volume or 1
        }}
    }

    -- Calculate delivery time
    local deliveryDays = supplier.pricing and supplier.pricing.deliveryTime or 1
    transferData.transitDays = deliveryDays
    transferData.remainingDays = deliveryDays

    -- Calculate cost (distance = 0 for market deliveries)
    local transferOrder = require 'economy.TransferOrder'(transferData)
    transferOrder:calculateCost(0, self.config.transfer)

    -- This would integrate with TransferManager to schedule the transfer
    -- For now, we'll just emit the event

    return true
end

--- Apply reputation effects from a purchase
-- @param item The purchased item
function MarketManager:_applyReputationEffects(item)
    if item.reputationEffects then
        if item.reputationEffects.karma then
            self.organization:modifyKarma(item.reputationEffects.karma)
        end
        if item.reputationEffects.fame then
            self.organization:modifyFame(item.reputationEffects.fame)
        end
    end
end

--- Reduce stock levels after purchase
-- @param itemId The item ID
-- @param supplierId The supplier ID
-- @param quantity The quantity purchased
function MarketManager:_reduceStock(itemId, supplierId, quantity)
    if not self.stockLevels[supplierId] then
        self.stockLevels[supplierId] = {}
    end

    self.stockLevels[supplierId][itemId] = (self.stockLevels[supplierId][itemId] or 0) - quantity
end

--- Get a purchase item by ID
-- @param itemId The item ID to find
function MarketManager:_getPurchaseItem(itemId)
    for _, item in ipairs(self.purchaseItems) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

--- Get a supplier by ID
-- @param supplierId The supplier ID to find
function MarketManager:_getSupplier(supplierId)
    for _, supplier in ipairs(self.suppliers) do
        if supplier.id == supplierId then
            return supplier
        end
    end
    return nil
end

--- Emit purchase event
-- @param item The purchased item
-- @param quantity The quantity purchased
-- @param supplier The supplier
-- @param cost The total cost
-- @param baseId The destination base
function MarketManager:_emitPurchaseEvent(item, quantity, supplier, cost, baseId)
    if self.eventBus then
        self.eventBus:emit("market:purchase", {
            itemId = item.id,
            itemName = item.name,
            quantity = quantity,
            supplierId = supplier.id,
            supplierName = supplier.name,
            cost = cost,
            baseId = baseId
        })
    end
end

--- Reset monthly stock levels
function MarketManager:resetMonthlyStock()
    local currentTime = self:_getCurrentTime()

    -- Only reset once per month
    if currentTime - self.lastStockReset < 30 then
        return
    end

    for _, supplier in ipairs(self.suppliers) do
        if supplier.availability and supplier.availability.monthlyStock then
            for itemId, maxStock in pairs(supplier.availability.monthlyStock) do
                if not self.stockLevels[supplier.id] then
                    self.stockLevels[supplier.id] = {}
                end
                self.stockLevels[supplier.id][itemId] = maxStock
            end
        end
    end

    self.lastStockReset = currentTime
end

--- Unlock a supplier
-- @param supplierId The supplier ID to unlock
function MarketManager:unlockSupplier(supplierId)
    self.unlockedSuppliers[supplierId] = true

    if self.eventBus then
        self.eventBus:emit("market:supplier_unlocked", {
            supplierId = supplierId
        })
    end
end

--- Get current time (days elapsed)
function MarketManager:_getCurrentTime()
    local timeSystem = self:_getTimeSystem()
    return timeSystem and timeSystem:getDaysElapsed() or 0
end

--- Get the time system
function MarketManager:_getTimeSystem()
    local registry = require 'services.registry'
    return registry:getService('timeSystem')
end

--- Get default configuration
function MarketManager:_getDefaultConfig()
    return {
        transfer = {
            unitCostFactor = 10,
            itemCostFactor = 2,
            baseFixedCost = 50,
            daysPerTile = 1,
            fixedOverheadDays = 1,
            marketDeliveryTime = 1,
            lowPriorityMultiplier = 0.8,
            highPriorityMultiplier = 1.5,
            emergencyPriorityMultiplier = 2.0
        }
    }
end

--- Get market status summary
function MarketManager:getMarketSummary()
    local summary = {
        totalSuppliers = #self.suppliers,
        unlockedSuppliers = 0,
        availableItems = 0,
        totalStockValue = 0
    }

    for _, supplier in ipairs(self.suppliers) do
        if self:_isSupplierUnlocked(supplier.id) then
            summary.unlockedSuppliers = summary.unlockedSuppliers + 1
        end
    end

    local availableItems = self:getAvailableItems()
    summary.availableItems = #availableItems

    -- Calculate total stock value (simplified)
    for supplierId, items in pairs(self.stockLevels) do
        for itemId, stock in pairs(items) do
            if stock > 0 then
                local item = self:_getPurchaseItem(itemId)
                if item then
                    summary.totalStockValue = summary.totalStockValue + (item.cost.credits or 0) * stock
                end
            end
        end
    end

    return summary
end

return MarketManager
