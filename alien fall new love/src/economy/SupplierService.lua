--- Supplier Service
-- Manages marketplace suppliers, stock levels, and vendor relationships
--
-- @classmod economy.SupplierService

-- GROK: SupplierService manages marketplace vendors with stock tracking and relationship mechanics
-- GROK: Handles supplier availability, pricing, restocking, and access requirements
-- GROK: Key methods: getAvailableSuppliers(), purchaseFromSupplier(), updateStock(), checkRequirements()
-- GROK: Integrates with marketplace for buying/selling and transfer system for deliveries

local class = require 'lib.Middleclass'
local Supplier = require 'economy.Supplier'

--- SupplierService class
-- @type SupplierService
SupplierService = class('SupplierService')

--- Create a new SupplierService instance
-- @param registry Service registry for accessing other systems
-- @return SupplierService instance
function SupplierService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:getService('eventBus') or nil

    -- Supplier data
    self.suppliers = {} -- id -> Supplier instance
    self.supplierStock = {} -- supplierId -> itemId -> {quantity, lastRestockTime}
    self.supplierRelationships = {} -- supplierId -> {relationshipLevel, transactions}

    -- Load supplier data
    self:_loadSupplierData()

    -- Register with service registry
    if registry then
        registry:registerService('supplierService', self)
    end
end

--- Load supplier data from data registry
function SupplierService:_loadSupplierData()
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then
        if self.logger then
            self.logger:warn("Data registry not available for loading supplier data")
        end
        return
    end

    -- Load suppliers configuration from mod system
    local supplierData = dataRegistry:get("suppliers")
    if supplierData then
        for _, supplierConfig in ipairs(supplierData) do
            local supplier = Supplier:new(supplierConfig)
            self.suppliers[supplier.id] = supplier

            -- Initialize stock tracking
            self.supplierStock[supplier.id] = {}
            self.supplierRelationships[supplier.id] = {
                relationshipLevel = 0,
                transactions = 0
            }
        end
    end
end

--- Get all available suppliers for a base
-- @param baseId The base ID to check availability for
-- @return table Array of available Supplier instances
function SupplierService:getAvailableSuppliers(baseId)
    local available = {}

    for _, supplier in pairs(self.suppliers) do
        if self:_isSupplierAvailable(supplier, baseId) then
            table.insert(available, supplier)
        end
    end

    return available
end

--- Check if a supplier is available at a base
-- @param supplier The Supplier instance
-- @param baseId The base ID
-- @return boolean Whether the supplier is available
function SupplierService:_isSupplierAvailable(supplier, baseId)
    -- Check access requirements
    if not self:_meetsSupplierRequirements(supplier, baseId) then
        return false
    end

    -- Check tech level availability
    local techLevel = self:_getCurrentTechLevel()
    if not supplier:isAvailableAtTechLevel(techLevel) then
        return false
    end

    -- Check regional availability
    if not self:_isSupplierInRange(supplier, baseId) then
        return false
    end

    return true
end

--- Check if supplier requirements are met
-- @param supplier The Supplier instance
-- @param baseId The base ID
-- @return boolean Whether requirements are met
function SupplierService:_meetsSupplierRequirements(supplier, baseId)
    -- Check research requirements
    if supplier.requirements.research then
        local researchService = self.registry:getService('researchService')
        for _, researchId in ipairs(supplier.requirements.research) do
            if not researchService:isResearchCompleted(researchId) then
                return false
            end
        end
    end

    -- Check reputation requirements
    if supplier.requirements.karma_min then
        local currentKarma = self:_getCurrentKarma()
        if currentKarma < supplier.requirements.karma_min then
            return false
        end
    end

    if supplier.requirements.fame_min then
        local currentFame = self:_getCurrentFame()
        if currentFame < supplier.requirements.fame_min then
            return false
        end
    end

    return true
end

--- Check if supplier is within range of base
-- @param supplier The Supplier instance
-- @param baseId The base ID
-- @return boolean Whether supplier is in range
function SupplierService:_isSupplierInRange(supplier, baseId)
    -- TODO: Implement regional/geographic checks
    -- For now, assume all suppliers are globally available
    return true
end

--- Get current stock for a supplier item
-- @param supplierId The supplier ID
-- @param itemId The item ID
-- @return number Current stock quantity
function SupplierService:getStock(supplierId, itemId)
    local supplierStock = self.supplierStock[supplierId]
    if supplierStock and supplierStock[itemId] then
        return supplierStock[itemId].quantity
    end
    return 0
end

--- Purchase items from a supplier
-- @param supplierId The supplier ID
-- @param itemId The item ID
-- @param quantity The quantity to purchase
-- @param baseId The destination base ID
-- @return boolean Success status
-- @return string Error message if failed
function SupplierService:purchaseFromSupplier(supplierId, itemId, quantity, baseId)
    local supplier = self.suppliers[supplierId]
    if not supplier then
        return false, "Supplier not found"
    end

    -- Check availability
    if not self:_isSupplierAvailable(supplier, baseId) then
        return false, "Supplier not available"
    end

    -- Check stock
    local availableStock = self:getStock(supplierId, itemId)
    if availableStock < quantity then
        return false, "Insufficient stock"
    end

    -- Calculate price
    local price = self:_calculatePurchasePrice(supplier, itemId, quantity)

    -- Check funds
    if not self:_hasSufficientFunds(price) then
        return false, "Insufficient funds"
    end

    -- Create transfer order
    local transferService = self.registry:getService('transferService')
    local success, message = transferService:createPurchaseTransfer(
        supplierId, itemId, quantity, baseId, price
    )

    if success then
        -- Reduce stock
        self:_reduceStock(supplierId, itemId, quantity)

        -- Update relationship
        self:_updateSupplierRelationship(supplierId, price)

        -- Emit purchase event
        if self.eventBus then
            self.eventBus:emit('supplier:purchase_completed', {
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

--- Calculate purchase price for items
-- @param supplier The Supplier instance
-- @param itemId The item ID
-- @param quantity The quantity
-- @return number Total price
function SupplierService:_calculatePurchasePrice(supplier, itemId, quantity)
    -- Get base price (from item data)
    local basePrice = self:_getItemBasePrice(itemId)

    -- Apply supplier markup
    local markup = supplier:getMarkup()
    local itemPrice = basePrice * markup

    -- Apply bulk discount if applicable
    if quantity >= supplier:getBulkDiscountThreshold() then
        local discountRate = supplier:getBulkDiscountRate()
        itemPrice = itemPrice * (1 - discountRate)
    end

    return itemPrice * quantity
end

--- Reduce supplier stock
-- @param supplierId The supplier ID
-- @param itemId The item ID
-- @param quantity The quantity to reduce
function SupplierService:_reduceStock(supplierId, itemId, quantity)
    local supplierStock = self.supplierStock[supplierId]
    if supplierStock[itemId] then
        supplierStock[itemId].quantity = supplierStock[itemId].quantity - quantity
    end
end

--- Update supplier relationship
-- @param supplierId The supplier ID
-- @param transactionValue The value of the transaction
function SupplierService:_updateSupplierRelationship(supplierId, transactionValue)
    local relationship = self.supplierRelationships[supplierId]
    relationship.transactions = relationship.transactions + 1
    relationship.relationshipLevel = relationship.relationshipLevel + (transactionValue * 0.001)
end

--- Update supplier stock levels (monthly restock)
function SupplierService:updateStock()
    for supplierId, supplier in pairs(self.suppliers) do
        self:_restockSupplier(supplierId, supplier)
    end

    -- Emit restock event
    if self.eventBus then
        self.eventBus:emit('supplier:monthly_restock', {})
    end
end

--- Restock a supplier
-- @param supplierId The supplier ID
-- @param supplier The Supplier instance
function SupplierService:_restockSupplier(supplierId, supplier)
    -- TODO: Implement restock logic based on supplier configuration
    -- For now, simple restock to configured levels
end

--- Get supplier relationship level
-- @param supplierId The supplier ID
-- @return number Relationship level
function SupplierService:getSupplierRelationship(supplierId)
    local relationship = self.supplierRelationships[supplierId]
    return relationship and relationship.relationshipLevel or 0
end

--- Get supplier information
-- @param supplierId The supplier ID
-- @return table|nil Supplier data or nil if not found
function SupplierService:getSupplierInfo(supplierId)
    local supplier = self.suppliers[supplierId]
    if not supplier then return nil end

    return {
        id = supplier.id,
        name = supplier.name,
        type = supplier.type,
        relationship = self:getSupplierRelationship(supplierId),
        categories = supplier:getCategories(),
        reliability = supplier:getReliability()
    }
end

--- Placeholder methods (to be implemented with actual systems)
function SupplierService:_getCurrentTechLevel()
    return 1 -- TODO: Integrate with research system
end

function SupplierService:_getCurrentKarma()
    return 0 -- TODO: Integrate with reputation system
end

function SupplierService:_getCurrentFame()
    return 0 -- TODO: Integrate with reputation system
end

function SupplierService:_getItemBasePrice(itemId)
    return 100 -- TODO: Integrate with item system
end

function SupplierService:_hasSufficientFunds(amount)
    return true -- TODO: Integrate with finance system
end

return SupplierService
