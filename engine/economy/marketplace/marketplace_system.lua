---Marketplace and Supplier System
---
---Manages purchasing, selling, suppliers, and dynamic pricing. Handles supplier
---relationships, delivery times, bulk discounts, and market fluctuations. Players
---buy equipment, sell salvage, and maintain supplier relations.
---
---Marketplace Features:
---  - Multiple suppliers with unique inventories
---  - Dynamic pricing based on relationships
---  - Bulk purchase discounts
---  - Delivery times and shipping
---  - Supplier reputation system
---  - Market fluctuations
---  - Buy and sell transactions
---
---Supplier Relationships:
---  - Range: -2.0 (hostile) to +2.0 (excellent)
---  - Affects: Prices, availability, delivery speed
---  - Modified by: Purchase volume, payment history, missions
---
---Key Exports:
---  - MarketplaceSystem.new(): Creates marketplace instance
---  - addSupplier(supplier): Registers new supplier
---  - purchaseItem(itemId, quantity, supplierId): Buys from supplier
---  - sellItem(itemId, quantity): Sells to marketplace
---  - getAvailableItems(supplierId): Lists supplier inventory
---  - updateRelationship(supplierId, delta): Modifies reputation
---
---Dependencies:
---  - shared.items: Item definitions and prices
---  - politics.relations: Reputation system
---  - geoscape.world.world_state: Global economy state
---
---@module economy.marketplace.marketplace_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Marketplace = require("economy.marketplace.marketplace_system")
---  local market = Marketplace.new()
---  market:purchaseItem("laser_rifle", 5, "supplier_1")
---  market:sellItem("alien_corpse", 10)
---
---@see economy.marketplace.black_market_system For illegal items
---@see scenes.basescape_screen For marketplace UI

local MarketplaceSystem = {}
MarketplaceSystem.__index = MarketplaceSystem

--- Create new marketplace system
-- @return table New MarketplaceSystem instance
function MarketplaceSystem.new()
    local self = setmetatable({}, MarketplaceSystem)

    self.suppliers = {}          -- All suppliers
    self.purchaseEntries = {}    -- Items available for purchase
    self.purchaseOrders = {}     -- Active orders being delivered
    self.relationships = {}      -- Supplier relationships (-2.0 to +2.0)

    print("[MarketplaceSystem] Initialized marketplace system")

    return self
end

--- Define supplier
-- @param supplierId string Unique supplier identifier
-- @param definition table Supplier definition
function MarketplaceSystem:defineSupplier(supplierId, definition)
    self.suppliers[supplierId] = {
        id = supplierId,
        name = definition.name or supplierId,
        description = definition.description or "",
        region = definition.region or "global",
        baseRelationship = definition.baseRelationship or 0.0
    }

    -- Initialize relationship
    if not self.relationships[supplierId] then
        self.relationships[supplierId] = self.suppliers[supplierId].baseRelationship
    end

    print(string.format("[MarketplaceSystem] Defined supplier '%s' (%s)",
          definition.name, definition.region))
end

--- Define purchase entry
-- @param entryId string Unique entry identifier
-- @param definition table Purchase entry definition
function MarketplaceSystem:definePurchaseEntry(entryId, definition)
    self.purchaseEntries[entryId] = {
        id = entryId,
        name = definition.name or entryId,
        description = definition.description or "",

        -- Pricing
        basePrice = definition.basePrice or 1000,
        sellPrice = definition.sellPrice or math.floor((definition.basePrice or 1000) * 0.7),

        -- Item produced
        itemId = definition.itemId or entryId,
        itemType = definition.itemType or "item", -- item | unit | craft
        quantity = definition.quantity or 1,

        -- Supplier
        supplierId = definition.supplierId or "general",

        -- Availability
        stock = definition.stock or -1, -- -1 = unlimited
        restockRate = definition.restockRate or 0,
        currentStock = definition.stock or -1,

        -- Prerequisites
        requiredResearch = definition.requiredResearch or {},
        requiredRelationship = definition.requiredRelationship or -2.0,
        requiredRegions = definition.requiredRegions or {},

        -- Delivery
        deliveryTime = definition.deliveryTime or 7 -- Days
    }

    print(string.format("[MarketplaceSystem] Defined purchase entry '%s' - $%d from %s",
          definition.name, definition.basePrice, definition.supplierId))
end

--- Place purchase order
-- @param entryId string Purchase entry ID
-- @param quantity number Quantity to purchase
-- @param baseId string Destination base ID
-- @return boolean True if order placed
-- @return string|nil Error message if failed
function MarketplaceSystem:placePurchaseOrder(entryId, quantity, baseId)
    local entry = self.purchaseEntries[entryId]

    if not entry then
        return false, "Purchase entry not found"
    end

    -- Check stock
    if entry.currentStock ~= -1 and entry.currentStock < quantity then
        return false, string.format("Insufficient stock (available: %d)", entry.currentStock)
    end

    -- Check relationship requirement
    local relationship = self.relationships[entry.supplierId] or 0.0
    if relationship < entry.requiredRelationship then
        return false, string.format("Insufficient relationship with %s (need: %.1f, have: %.1f)",
                                    entry.supplierId, entry.requiredRelationship, relationship)
    end

    -- Check research prerequisites
    for _, researchId in ipairs(entry.requiredResearch) do
        if not self:isResearchComplete(researchId) then
            return false, string.format("Research required: %s", researchId)
        end
    end

    -- Calculate price with relationship modifier
    local priceModifier = self:getPriceModifier(entry.supplierId)
    local totalPrice = math.floor(entry.basePrice * quantity * priceModifier)

    -- Check if player has enough credits
    local hasCredits = self:checkPlayerCredits(baseId, totalPrice)
    if not hasCredits then
        return false, string.format("Insufficient credits (need: $%d)", totalPrice)
    end

    -- Create purchase order
    local order = {
        id = "order_" .. os.time() .. "_" .. math.random(1000, 9999),
        entryId = entryId,
        itemId = entry.itemId,
        itemType = entry.itemType,
        quantity = quantity,
        totalPrice = totalPrice,
        baseId = baseId,
        deliveryTime = entry.deliveryTime,
        daysRemaining = entry.deliveryTime,
        status = "in_transit"
    }

    -- Consume stock
    if entry.currentStock ~= -1 then
        entry.currentStock = entry.currentStock - quantity
    end

    -- Deduct credits from player
    self:deductCredits(baseId, totalPrice)

    -- Update supplier relationship (positive for purchase)
    self:modifyRelationship(entry.supplierId, 0.1)

    table.insert(self.purchaseOrders, order)

    print(string.format("[MarketplaceSystem] Placed order for %d x '%s' - $%d, delivery in %d days",
          quantity, entry.name, totalPrice, order.deliveryTime))

    return true, nil
end

--- Check if player has enough credits for purchase
-- @param baseId string Base identifier
-- @param creditCost number Amount required
-- @return boolean True if sufficient credits
function MarketplaceSystem:checkPlayerCredits(baseId, creditCost)
    -- Try to get from finance system
    local Finance = require("engine.economy.finance.finance_system")
    if Finance then
        local playerCredits = Finance:getPlayerCredits()
        if playerCredits and playerCredits >= creditCost then
            return true
        end
    end

    -- Fallback: check base credits
    if self.baseCredits and self.baseCredits[baseId] then
        if self.baseCredits[baseId] >= creditCost then
            return true
        end
    end

    print(string.format("[Marketplace] Insufficient credits: need $%d", creditCost))
    return false
end

--- Deduct credits from player for purchase
-- @param baseId string Base identifier
-- @param amount number Amount to deduct
-- @return boolean Success
function MarketplaceSystem:deductCredits(baseId, amount)
    -- Try to deduct from finance system
    local Finance = require("engine.economy.finance.finance_system")
    if Finance then
        return Finance:addCredits(-amount)  -- Negative to deduct
    end

    -- Fallback: deduct from base credits
    if self.baseCredits then
        if not self.baseCredits[baseId] then
            self.baseCredits[baseId] = 0
        end

        if self.baseCredits[baseId] >= amount then
            self.baseCredits[baseId] = self.baseCredits[baseId] - amount
            print(string.format("[Marketplace] Deducted $%d from base %s", amount, baseId))
            return true
        end
    end

    return false
end

--- Check if research is complete
-- @param researchId string Research project ID
-- @return boolean True if research complete
function MarketplaceSystem:isResearchComplete(researchId)
    local Research = require("engine.basescape.logic.research_system")
    if Research then
        local research = Research.getResearch(researchId)
        if research then
            return research.status == "complete" or research.progress >= 100
        end
    end

    return true -- Default allow if research system unavailable
end

--- Process daily delivery progress
function MarketplaceSystem:processDailyDeliveries()
    if #self.purchaseOrders == 0 then
        return
    end

    print(string.format("[MarketplaceSystem] Processing %d active orders", #self.purchaseOrders))

    for i = #self.purchaseOrders, 1, -1 do
        local order = self.purchaseOrders[i]

        if order.status == "in_transit" then
            order.daysRemaining = order.daysRemaining - 1

            print(string.format("[MarketplaceSystem] Order %s: %d days remaining",
                  order.id, order.daysRemaining))

            -- Check for delivery
            if order.daysRemaining <= 0 then
                self:deliverOrder(order)
                table.remove(self.purchaseOrders, i)
            end
        end
    end
end

--- Deliver completed order
-- @param order table Purchase order
function MarketplaceSystem:deliverOrder(order)
    -- Try to add items to base inventory
    local success = self:addItemsToBaseInventory(order.baseId, order.itemId, order.itemType, order.quantity)

    if success then
        -- Update marketplace stock if applicable
        local entry = self:getMarketplaceEntry(order.entryId)
        if entry then
            entry.lastPurchased = os.time()
            entry.purchaseCount = (entry.purchaseCount or 0) + order.quantity
        end

        -- Improve supplier relationship for successful delivery
        self:modifyRelationship(order.supplierId, 0.05)
    end

    print(string.format("[MarketplaceSystem] ORDER DELIVERED: %d x %s to base %s (success=%s)",
          order.quantity, order.itemId, order.baseId, tostring(success)))

    order.status = "delivered"
end

--- Calculate price modifier based on relationship
-- @param supplierId string Supplier ID
-- @return number Price modifier (0.5 to 2.0)
function MarketplaceSystem:getPriceModifier(supplierId)
    local relationship = self.relationships[supplierId] or 0.0

    -- Relationship range: -2.0 (worst) to +2.0 (best)
    -- Price modifier: 2.0 (worst) to 0.5 (best)
    -- Formula: 1.25 - (relationship * 0.375)
    -- At -2.0: 1.25 - (-2 * 0.375) = 1.25 + 0.75 = 2.0
    -- At  0.0: 1.25 - (0 * 0.375) = 1.25
    -- At +2.0: 1.25 - (2 * 0.375) = 1.25 - 0.75 = 0.5

    local modifier = 1.25 - (relationship * 0.375)
    return math.max(0.5, math.min(2.0, modifier))
end

--- Get purchase price for entry
-- @param entryId string Purchase entry ID
-- @param quantity number Quantity (for bulk discount calculation)
-- @return number|nil Price per unit, or nil if not available
function MarketplaceSystem:getPurchasePrice(entryId, quantity)
    local entry = self.purchaseEntries[entryId]

    if not entry then
        return nil
    end

    local priceModifier = self:getPriceModifier(entry.supplierId)
    local basePrice = entry.basePrice * priceModifier

    -- Apply bulk discount
    local bulkDiscount = self:getBulkDiscount(quantity)
    local finalPrice = math.floor(basePrice * bulkDiscount)

    return finalPrice
end

--- Calculate bulk discount
-- @param quantity number Quantity being purchased
-- @return number Discount multiplier (0.7 to 1.0)
function MarketplaceSystem:getBulkDiscount(quantity)
    if quantity >= 100 then
        return 0.7 -- 30% discount
    elseif quantity >= 50 then
        return 0.8 -- 20% discount
    elseif quantity >= 20 then
        return 0.9 -- 10% discount
    elseif quantity >= 10 then
        return 0.95 -- 5% discount
    else
        return 1.0 -- No discount
    end
end

--- Sell items to marketplace
-- @param itemId string Item identifier
-- @param quantity number Quantity to sell
-- @return number Credits received
function MarketplaceSystem:sellItems(itemId, quantity)
    -- Find purchase entry for this item
    local entry = nil
    for _, purchaseEntry in pairs(self.purchaseEntries) do
        if purchaseEntry.itemId == itemId then
            entry = purchaseEntry
            break
        end
    end

    if not entry then
        print(string.format("[MarketplaceSystem] No market entry for item '%s'", itemId))
        return 0
    end

    local totalPrice = entry.sellPrice * quantity

    -- Restock supplier inventory
    if entry.currentStock ~= -1 then
        entry.currentStock = entry.currentStock + quantity
    end

    print(string.format("[MarketplaceSystem] Sold %d x '%s' for $%d",
          quantity, entry.name, totalPrice))

    return totalPrice
end

--- Process monthly stock refresh
function MarketplaceSystem:processMonthlyRestock()
    print("[MarketplaceSystem] Processing monthly restock")

    for entryId, entry in pairs(self.purchaseEntries) do
        if entry.currentStock ~= -1 and entry.restockRate > 0 then
            local oldStock = entry.currentStock
            entry.currentStock = math.min(entry.stock, entry.currentStock + entry.restockRate)

            print(string.format("[MarketplaceSystem] Restocked '%s': %d -> %d (+%d)",
                  entry.name, oldStock, entry.currentStock, entry.restockRate))
        end
    end
end

--- Check if research is complete
-- @param researchId string Research ID
-- @return boolean True if complete
function MarketplaceSystem:isResearchComplete(researchId)
    local Research = require("engine.basescape.research.research_system")
    if Research and Research.isComplete then
        return Research.isComplete(researchId)
    end
    return true -- Default allow if research system unavailable
end

--- Check if player has sufficient credits for purchase
-- @param baseId string Base ID
-- @param amount number Credit amount needed
-- @return boolean True if player has enough credits
function MarketplaceSystem:checkPlayerCredits(baseId, amount)
    local Finance = require("engine.basescape.finance.finance_system")
    if Finance and Finance.getBalance then
        local balance = Finance.getBalance(baseId)
        if balance < amount then
            print(string.format("[MarketplaceSystem] Insufficient credits: need $%d, have $%d", amount, balance))
            return false
        end
        return true
    end
    return true -- Default allow if finance system unavailable
end

--- Deduct credits for purchase
-- @param baseId string Base ID
-- @param amount number Credit amount to deduct
-- @return boolean True if deduction successful
function MarketplaceSystem:deductCredits(baseId, amount)
    local Finance = require("engine.basescape.finance.finance_system")
    if Finance and Finance.deductCredits then
        return Finance.deductCredits(baseId, amount)
    end
    return true -- Default allow if finance system unavailable
end

--- Modify supplier relationship
-- @param supplierId string Supplier ID
-- @param change number Relationship change (-0.5 to +0.5 typical)
function MarketplaceSystem:modifyRelationship(supplierId, change)
    local oldRelationship = self.relationships[supplierId] or 0.0
    self.relationships[supplierId] = math.max(-2.0, math.min(2.0, oldRelationship + change))

    print(string.format("[MarketplaceSystem] Supplier '%s' relationship: %.2f -> %.2f (%.2f)",
          supplierId, oldRelationship, self.relationships[supplierId], change))
end

--- Get available purchase entries for player
-- @param region string|nil Player's region (optional filter)
-- @return table Array of available entries
function MarketplaceSystem:getAvailablePurchases(region)
    local available = {}

    for entryId, entry in pairs(self.purchaseEntries) do
        -- Check stock
        if entry.currentStock == -1 or entry.currentStock > 0 then
            -- Check relationship
            local relationship = self.relationships[entry.supplierId] or 0.0
            if relationship >= entry.requiredRelationship then
                -- Check region
                if not region or #entry.requiredRegions == 0 or
                   self:isRegionAllowed(region, entry.requiredRegions) then
                    -- Check research
                    local researchOk = true
                    for _, researchId in ipairs(entry.requiredResearch) do
                        if not self:isResearchComplete(researchId) then
                            researchOk = false
                            break
                        end
                    end

                    if researchOk then
                        table.insert(available, entry)
                    end
                end
            end
        end
    end

    return available
end

--- Check if region is allowed
-- @param playerRegion string Player's region
-- @param requiredRegions table Array of allowed regions
-- @return boolean True if allowed
function MarketplaceSystem:isRegionAllowed(playerRegion, requiredRegions)
    for _, region in ipairs(requiredRegions) do
        if region == playerRegion then
            return true
        end
    end
    return false
end

--- Get active purchase orders
-- @return table Array of orders
function MarketplaceSystem:getPurchaseOrders()
    return self.purchaseOrders
end

--- Initialize default suppliers and entries
function MarketplaceSystem:initializeDefaults()
    -- Define suppliers
    self:defineSupplier("military_surplus", {
        name = "Military Surplus",
        description = "General military equipment",
        region = "global",
        baseRelationship = 0.0
    })

    self:defineSupplier("black_market", {
        name = "Black Market",
        description = "Questionable goods and exotic items",
        region = "global",
        baseRelationship = -1.0
    })

    self:defineSupplier("government", {
        name = "Government Supply",
        description = "Official government equipment",
        region = "global",
        baseRelationship = 0.5
    })

    -- Define purchase entries
    self:definePurchaseEntry("rifle", {
        name = "Assault Rifle",
        description = "Standard military rifle",
        basePrice = 10000,
        itemId = "rifle",
        supplierId = "military_surplus",
        stock = 100,
        restockRate = 50,
        deliveryTime = 3
    })

    self:definePurchaseEntry("pistol", {
        name = "Pistol",
        description = "Sidearm pistol",
        basePrice = 3000,
        itemId = "pistol",
        supplierId = "military_surplus",
        stock = 200,
        restockRate = 100,
        deliveryTime = 2
    })

    self:definePurchaseEntry("grenade", {
        name = "Grenade",
        description = "Fragmentation grenade",
        basePrice = 1500,
        itemId = "grenade",
        supplierId = "military_surplus",
        stock = 150,
        restockRate = 75,
        deliveryTime = 2
    })

    self:definePurchaseEntry("light_armour", {
        name = "Light Armor",
        description = "Basic protective armor",
        basePrice = 15000,
        itemId = "light_armour",
        supplierId = "government",
        stock = 50,
        restockRate = 25,
        deliveryTime = 5
    })

    self:definePurchaseEntry("soldier", {
        name = "Recruit Soldier",
        description = "Trained combat recruit",
        basePrice = 20000,
        itemId = "soldier_rookie",
        itemType = "unit",
        supplierId = "government",
        stock = -1, -- Unlimited
        deliveryTime = 7
    })

    print("[MarketplaceSystem] Initialized 3 suppliers and 5 purchase entries")
end

--- Add items to base inventory on delivery
-- @param baseId string Base identifier
-- @param itemId string Item identifier
-- @param itemType string Item type (weapon, armor, unit, etc.)
-- @param quantity number Quantity to add
-- @return boolean Success
function MarketplaceSystem:addItemsToBaseInventory(baseId, itemId, itemType, quantity)
    -- Try to get base
    local Base = require("engine.basescape.logic.base")
    if not Base then
        print("[Marketplace] Cannot load Base system for inventory delivery")
        return false
    end

    -- Try to get base instance
    local base = Base.getBase(baseId)
    if not base then
        print(string.format("[Marketplace] Base %s not found", baseId))
        return false
    end

    -- Route to appropriate inventory system based on item type
    if itemType == "unit" then
        return self:addUnitsToBase(base, itemId, quantity)
    elseif itemType == "weapon" then
        return self:addWeaponsToInventory(base, itemId, quantity)
    elseif itemType == "armor" then
        return self:addArmorToInventory(base, itemId, quantity)
    elseif itemType == "equipment" then
        return self:addEquipmentToInventory(base, itemId, quantity)
    else
        -- Generic fallback - add to supplies
        return self:addSupplies(base, itemId, quantity)
    end
end

--- Add units (soldiers, recruits) to base
-- @param base table Base object
-- @param unitId string Unit template ID
-- @param quantity number Number of units
-- @return boolean Success
function MarketplaceSystem:addUnitsToBase(base, unitId, quantity)
    if not base.units then
        base.units = {}
    end

    for i = 1, quantity do
        local unit = {
            id = "unit_" .. os.time() .. "_" .. i,
            templateId = unitId,
            name = string.format("Soldier %d", #base.units + 1),
            rank = "rookie",
            status = "active",
            health = 100,
            morale = 50,
            skills = {}
        }
        table.insert(base.units, unit)
    end

    print(string.format("[Marketplace] Added %d units (%s) to base", quantity, unitId))
    return true
end

--- Add weapons to base equipment inventory
-- @param base table Base object
-- @param weaponId string Weapon ID
-- @param quantity number Quantity
-- @return boolean Success
function MarketplaceSystem:addWeaponsToInventory(base, weaponId, quantity)
    if not base.inventory then
        base.inventory = {}
    end
    if not base.inventory.weapons then
        base.inventory.weapons = {}
    end

    if not base.inventory.weapons[weaponId] then
        base.inventory.weapons[weaponId] = 0
    end

    base.inventory.weapons[weaponId] = base.inventory.weapons[weaponId] + quantity

    print(string.format("[Marketplace] Added %d x %s to base weapons inventory", quantity, weaponId))
    return true
end

--- Add armor to base equipment inventory
-- @param base table Base object
-- @param armorId string Armor ID
-- @param quantity number Quantity
-- @return boolean Success
function MarketplaceSystem:addArmorToInventory(base, armorId, quantity)
    if not base.inventory then
        base.inventory = {}
    end
    if not base.inventory.armor then
        base.inventory.armor = {}
    end

    if not base.inventory.armor[armorId] then
        base.inventory.armor[armorId] = 0
    end

    base.inventory.armor[armorId] = base.inventory.armor[armorId] + quantity

    print(string.format("[Marketplace] Added %d x %s to base armor inventory", quantity, armorId))
    return true
end

--- Add equipment to base inventory
-- @param base table Base object
-- @param equipmentId string Equipment ID
-- @param quantity number Quantity
-- @return boolean Success
function MarketplaceSystem:addEquipmentToInventory(base, equipmentId, quantity)
    if not base.inventory then
        base.inventory = {}
    end
    if not base.inventory.equipment then
        base.inventory.equipment = {}
    end

    if not base.inventory.equipment[equipmentId] then
        base.inventory.equipment[equipmentId] = 0
    end

    base.inventory.equipment[equipmentId] = base.inventory.equipment[equipmentId] + quantity

    print(string.format("[Marketplace] Added %d x %s to base equipment inventory", quantity, equipmentId))
    return true
end

--- Add generic supplies to base
-- @param base table Base object
-- @param supplyId string Supply ID
-- @param quantity number Quantity
-- @return boolean Success
function MarketplaceSystem:addSupplies(base, supplyId, quantity)
    if not base.supplies then
        base.supplies = {}
    end

    if not base.supplies[supplyId] then
        base.supplies[supplyId] = 0
    end

    base.supplies[supplyId] = base.supplies[supplyId] + quantity

    print(string.format("[Marketplace] Added %d x %s to base supplies", quantity, supplyId))
    return true
end

return MarketplaceSystem

