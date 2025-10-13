# Task: Marketplace & Supplier System - Trade, Suppliers, and Relationships

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a comprehensive marketplace system with multiple suppliers, purchase entries, purchase orders, dynamic pricing based on supplier relationships, regional availability, transfer integration, and bulk purchasing mechanics.

---

## Purpose

The marketplace system allows players to buy and sell items, units, and crafts from various suppliers. Supplier relationships affect prices and availability. Purchases are delivered via transfer system to selected bases. The marketplace is the primary method for acquiring equipment before manufacturing becomes available.

---

## Requirements

### Functional Requirements
- [ ] Purchase Entry: Items available for purchase from suppliers
- [ ] Purchase Order: Active orders being delivered to bases
- [ ] Supplier System: Multiple suppliers with different inventories
- [ ] Supplier Relationships: Affect prices, availability, and delivery time
- [ ] Dynamic Pricing: Based on relationships, supply/demand, region
- [ ] Regional Availability: Some items only in certain regions
- [ ] Bulk Discounts: Lower per-unit cost for larger purchases
- [ ] Transfer Integration: Orders delivered via transfer system
- [ ] Selling System: Sell items back to marketplace
- [ ] Monthly Stock Refresh: Supplier inventories update monthly
- [ ] Research Unlocks: Some items require research to purchase

### Technical Requirements
- [ ] Data-driven supplier and purchase entry definitions (TOML)
- [ ] State persistence (save/load for orders, relationships)
- [ ] Event system for delivery completion
- [ ] Integration with transfer system
- [ ] Integration with research system (unlocks)
- [ ] Integration with relations system (pricing/availability)
- [ ] Per-supplier inventory tracking

### Acceptance Criteria
- [ ] Can browse suppliers and their inventories
- [ ] Can place purchase orders if prerequisites met
- [ ] Orders delivered via transfer system to selected base
- [ ] Supplier relationships affect prices (-50% to +100%)
- [ ] Regional restrictions enforced
- [ ] Research unlocks new purchase options
- [ ] Can sell items at marketplace price
- [ ] Monthly stock refresh changes available items
- [ ] Bulk discounts applied automatically
- [ ] Low relationships can block items entirely

---

## Plan

### Step 1: Purchase Entry Data Structure (8 hours)
**Description:** Define purchase entry schema and data loader  
**Files to create:**
- `engine/data/purchase_entries.lua` - Purchase entry data
- `engine/geoscape/logic/purchase_entry.lua` - PurchaseEntry class
- `engine/mods/core/marketplace/general.toml` - General equipment
- `engine/mods/core/marketplace/weapons.toml` - Weapon purchases
- `engine/mods/core/marketplace/vehicles.toml` - Vehicle purchases

**PurchaseEntry Schema:**
```lua
PurchaseEntry = {
    id = "rifle",
    name = "Assault Rifle",
    description = "Standard military rifle",
    
    -- Pricing
    basePrice = 10000,  -- Base price before modifiers
    sellPrice = 7000,   -- Price when selling (70% of base)
    
    -- Item produced
    itemId = "rifle",   -- Item to deliver
    itemType = "item",  -- item | unit | craft
    
    -- Supplier
    supplierId = "military_surplus",  -- Which supplier offers this
    
    -- Availability
    stock = 100,        -- Available quantity this month (-1 = unlimited)
    restockRate = 50,   -- Added per month
    
    -- Prerequisites
    requiredResearch = {},           -- Optional research needed
    requiredRelationship = -2.0,     -- Min supplier relationship (-2 to +2)
    requiredRegions = {},            -- Optional: only in these regions
    
    -- Delivery
    deliveryTime = 7,   -- Days to deliver
    
    -- Metadata
    category = "weapons",  -- weapons, armor, vehicles, crafts, equipment
    icon = "rifle.png",
}
```

**Estimated time:** 8 hours

---

### Step 2: Supplier System (10 hours)
**Description:** Multiple suppliers with inventories, relationships, regions  
**Files to create:**
- `engine/geoscape/logic/supplier.lua` - Supplier class
- `engine/geoscape/systems/supplier_manager.lua` - Supplier management
- `engine/mods/core/marketplace/suppliers.toml` - Supplier definitions

**Supplier Schema:**
```lua
Supplier = {
    id = "military_surplus",
    name = "Global Military Surplus",
    description = "Standard military equipment supplier",
    
    -- Inventory
    entries = {},  -- List of purchase entry IDs offered
    
    -- Relationships
    baseRelationship = 0.0,  -- Starting relationship (-2 to +2)
    relationshipModifier = 0.0,  -- Current modifier
    
    -- Regional
    availableRegions = {},  -- Empty = global, otherwise specific regions
    
    -- Stock management
    monthlyRefreshDay = 1,  -- Day of month to refresh stock
    
    -- Pricing modifiers
    pricingTier = "standard",  -- budget, standard, premium, luxury
    
    -- Discovery
    requiresResearch = {},  -- Tech needed to discover supplier
    
    -- Metadata
    icon = "military_supplier.png",
    loreText = "A network of military surplus dealers...",
}
```

**Supplier Types:**
1. **Global Military Surplus** - Basic weapons, armor (always available)
2. **Advanced Defense Corp** - High-tech equipment (requires research)
3. **Regional Dealers** - Region-specific items
4. **Scientific Supply Co.** - Research equipment, materials
5. **Aerospace Industries** - Crafts, aerospace tech
6. **Underground Network** - (See TASK-035: Black Market)

**SupplierManager:**
```lua
SupplierManager = {
    suppliers = {},  -- supplier_id → Supplier
    relationships = {},  -- supplier_id → relationship value
}

SupplierManager:loadSuppliers()  -- Load from TOML
SupplierManager:getSupplier(id) -> Supplier
SupplierManager:getAllSuppliers() -> table
SupplierManager:getAvailableSuppliers(region) -> table
SupplierManager:getRelationship(supplierId) -> number
SupplierManager:modifyRelationship(supplierId, delta, reason)
SupplierManager:canPurchaseFrom(supplierId) -> boolean, reason
SupplierManager:monthlyRefresh()  -- Restock inventories
SupplierManager:unlockSupplier(supplierId)  -- Via research
```

**Estimated time:** 10 hours

---

### Step 3: Purchase Order System (10 hours)
**Description:** Active orders with delivery tracking via transfer system  
**Files to create:**
- `engine/geoscape/logic/purchase_order.lua` - PurchaseOrder class
- `engine/geoscape/systems/marketplace_manager.lua` - Marketplace operations

**PurchaseOrder:**
```lua
PurchaseOrder = {
    id = "order_001",
    entryId = "rifle",
    supplierId = "military_surplus",
    
    -- Quantity
    quantity = 10,
    
    -- Pricing
    pricePerUnit = 9000,  -- After relationship/bulk discounts
    totalPrice = 90000,
    
    -- Delivery
    destinationBaseId = "base_001",
    deliveryTime = 7,  -- Days remaining
    transferOrderId = "transfer_001",  -- Link to transfer system
    
    -- Status
    status = "pending",  -- pending | in_transit | delivered | cancelled
    
    -- Dates
    orderDate = {year = 1, month = 3, day = 15},
    deliveryDate = {year = 1, month = 3, day = 22},
}
```

**MarketplaceManager:**
```lua
MarketplaceManager = {
    suppliers = {},  -- All suppliers
    orders = {},     -- Active purchase orders
    salesHistory = {},  -- Items sold
}

MarketplaceManager:getPurchaseEntry(entryId) -> PurchaseEntry
MarketplaceManager:canPurchase(entryId, quantity) -> boolean, reason
MarketplaceManager:calculatePrice(entryId, quantity, supplierId) -> number
MarketplaceManager:placePurchaseOrder(entryId, quantity, baseId) -> PurchaseOrder
MarketplaceManager:cancelOrder(orderId) -> boolean
MarketplaceManager:sellItem(itemId, quantity) -> number  -- Returns credits earned
MarketplaceManager:dailyProgress()  -- Advance delivery times
MarketplaceManager:getAvailableItems(supplierId) -> table
MarketplaceManager:getActiveOrders() -> table
```

**Estimated time:** 10 hours

---

### Step 4: Dynamic Pricing System (8 hours)
**Description:** Price calculation based on relationships, bulk, region  
**Files to create:**
- `engine/geoscape/logic/marketplace_pricing.lua` - Pricing calculator

**Pricing Formula:**
```lua
MarketplacePricing:calculatePrice(entry, quantity, supplierId)
    local basePrice = entry.basePrice
    
    -- 1. Relationship modifier (-50% to +100%)
    local relationship = SupplierManager:getRelationship(supplierId)
    local relationshipMod = 1.0
    if relationship >= 2.0 then
        relationshipMod = 0.5  -- 50% discount (excellent)
    elseif relationship >= 1.0 then
        relationshipMod = 0.75  -- 25% discount (good)
    elseif relationship >= 0.0 then
        relationshipMod = 1.0  -- No modifier (neutral)
    elseif relationship >= -1.0 then
        relationshipMod = 1.25  -- 25% markup (poor)
    else
        relationshipMod = 2.0  -- 100% markup (hostile)
    end
    
    -- 2. Bulk discount (5% per 10 items, max 30%)
    local bulkDiscount = 1.0
    if quantity >= 10 then
        local bulkPercent = math.min(math.floor(quantity / 10) * 5, 30)
        bulkDiscount = 1.0 - (bulkPercent / 100)
    end
    
    -- 3. Regional modifier (optional)
    local regionalMod = 1.0
    -- Add regional pricing if needed
    
    -- Final price
    local pricePerUnit = basePrice * relationshipMod * bulkDiscount * regionalMod
    local totalPrice = pricePerUnit * quantity
    
    return pricePerUnit, totalPrice
end
```

**Relationship Impact:**
```
+2.0 (Excellent): 50% discount
+1.0 (Good):      25% discount
 0.0 (Neutral):   No modifier
-1.0 (Poor):      25% markup
-2.0 (Hostile):   100% markup + may block items
```

**Bulk Discounts:**
```
10-19 items:  5% discount
20-29 items: 10% discount
30-39 items: 15% discount
40-49 items: 20% discount
50-59 items: 25% discount
60+ items:   30% discount (max)
```

**Estimated time:** 8 hours

---

### Step 5: Transfer System Integration (8 hours)
**Description:** Orders delivered via existing transfer system  
**Dependencies:** Inter-base transfer system from TASK-029
**Files to modify:**
- `engine/basescape/systems/transfer_manager.lua` - Add purchase orders

**Purchase → Transfer Flow:**
```lua
MarketplaceManager:placePurchaseOrder(entryId, quantity, baseId)
    local entry = self:getPurchaseEntry(entryId)
    local supplier = SupplierManager:getSupplier(entry.supplierId)
    
    -- Calculate price
    local pricePerUnit, totalPrice = MarketplacePricing:calculatePrice(
        entry, quantity, supplier.id
    )
    
    -- Validate funds
    if GameState.credits < totalPrice then
        return nil, "Insufficient credits"
    end
    
    -- Validate stock
    if entry.stock > 0 and entry.stock < quantity then
        return nil, "Insufficient stock"
    end
    
    -- Deduct credits
    GameState.credits -= totalPrice
    
    -- Reduce stock
    if entry.stock > 0 then
        entry.stock -= quantity
    end
    
    -- Create transfer order
    local transferOrder = TransferManager:createExternalTransfer({
        itemId = entry.itemId,
        itemType = entry.itemType,
        quantity = quantity,
        destinationBaseId = baseId,
        deliveryDays = entry.deliveryTime,
        source = "marketplace",
    })
    
    -- Create purchase order
    local order = PurchaseOrder:new({
        entryId = entryId,
        supplierId = supplier.id,
        quantity = quantity,
        pricePerUnit = pricePerUnit,
        totalPrice = totalPrice,
        destinationBaseId = baseId,
        deliveryTime = entry.deliveryTime,
        transferOrderId = transferOrder.id,
    })
    
    table.insert(self.orders, order)
    
    -- Emit event
    EventManager:emit("purchase_order_placed", order)
    
    return order
end
```

**On Transfer Completion:**
```lua
-- Listen for transfer_completed event
EventManager:on("transfer_completed", function(transfer)
    if transfer.source == "marketplace" then
        -- Find associated purchase order
        local order = MarketplaceManager:findOrderByTransfer(transfer.id)
        if order then
            order.status = "delivered"
            EventManager:emit("purchase_order_delivered", order)
        end
    end
end)
```

**Estimated time:** 8 hours

---

### Step 6: Supplier Relationships (8 hours)
**Description:** Relationship system affecting prices and availability  
**Dependencies:** TASK-036 (Relations System)
**Files to create:**
- `engine/geoscape/systems/supplier_relations.lua` - Relationship management

**Relationship Mechanics:**
```lua
SupplierRelations = {
    relationships = {},  -- supplier_id → value (-2.0 to +2.0)
}

SupplierRelations:modifyRelationship(supplierId, delta, reason)
    local current = self.relationships[supplierId] or 0.0
    local new = math.max(-2.0, math.min(2.0, current + delta))
    self.relationships[supplierId] = new
    
    print("[SupplierRelations] " .. supplierId .. ": " .. current .. " → " .. new)
    print("  Reason: " .. reason)
    
    EventManager:emit("supplier_relationship_changed", {
        supplierId = supplierId,
        oldValue = current,
        newValue = new,
        reason = reason,
    })

SupplierRelations:getRelationshipLabel(value)
    if value >= 2.0 then return "Excellent" end
    if value >= 1.0 then return "Good" end
    if value >= 0.0 then return "Neutral" end
    if value >= -1.0 then return "Poor" end
    return "Hostile"

-- Relationship changes
SupplierRelations:onPurchase(supplierId, totalPrice)
    -- Large purchases improve relationship
    local delta = math.floor(totalPrice / 100000) * 0.1  -- +0.1 per 100k
    self:modifyRelationship(supplierId, delta, "Large purchase")

SupplierRelations:onLatePayment(supplierId)
    self:modifyRelationship(supplierId, -0.2, "Late payment")

SupplierRelations:onContractFulfillment(supplierId)
    self:modifyRelationship(supplierId, 0.3, "Contract fulfilled")
```

**Relationship Effects:**
- **Excellent (+2.0):** 50% discount, exclusive items, priority delivery
- **Good (+1.0):** 25% discount, most items available
- **Neutral (0.0):** Standard prices
- **Poor (-1.0):** 25% markup, some items restricted
- **Hostile (-2.0):** 100% markup, most items blocked

**Items Blocked by Relationship:**
```lua
PurchaseEntry = {
    id = "plasma_rifle",
    requiredRelationship = 1.0,  -- Need "Good" or better
}

MarketplaceManager:canPurchase(entryId, quantity)
    local entry = self:getPurchaseEntry(entryId)
    local relationship = SupplierRelations:get(entry.supplierId)
    
    if relationship < entry.requiredRelationship then
        return false, "Insufficient relationship with supplier"
    end
    
    return true
end
```

**Estimated time:** 8 hours

---

### Step 7: Regional Availability (6 hours)
**Description:** Some items only available in certain regions  
**Files to create:**
- `engine/geoscape/logic/marketplace_regions.lua` - Regional restrictions

**Regional Restrictions:**
```lua
PurchaseEntry = {
    id = "regional_equipment",
    availableRegions = {"north_america", "europe"},  -- Only in these
}

Supplier = {
    id = "european_arms_dealer",
    availableRegions = {"europe"},  -- Supplier only in Europe
}

MarketplaceManager:getAvailableSuppliers(baseRegion)
    local available = {}
    for _, supplier in pairs(self.suppliers) do
        -- Check if supplier available in this region
        if #supplier.availableRegions == 0 or 
           contains(supplier.availableRegions, baseRegion) then
            table.insert(available, supplier)
        end
    end
    return available

MarketplaceManager:canPurchase(entryId, baseId)
    local entry = self:getPurchaseEntry(entryId)
    local base = BaseManager:getBase(baseId)
    local baseRegion = base.provinceId.regionId
    
    -- Check entry regional restriction
    if #entry.availableRegions > 0 then
        if not contains(entry.availableRegions, baseRegion) then
            return false, "Not available in " .. baseRegion
        end
    end
    
    -- Check supplier regional restriction
    local supplier = SupplierManager:getSupplier(entry.supplierId)
    if #supplier.availableRegions > 0 then
        if not contains(supplier.availableRegions, baseRegion) then
            return false, "Supplier not available in " .. baseRegion
        end
    end
    
    return true
end
```

**Use Cases:**
- European suppliers only in Europe
- Asian tech only in Asia
- Regional resources (e.g., rare materials)
- Strategic base placement importance

**Estimated time:** 6 hours

---

### Step 8: Selling System (6 hours)
**Description:** Sell items back to marketplace for credits  
**Files to create:**
- `engine/geoscape/logic/marketplace_sales.lua` - Selling mechanics

**Selling Mechanics:**
```lua
MarketplaceManager:sellItem(itemId, quantity, baseId)
    local base = BaseManager:getBase(baseId)
    
    -- Validate item in inventory
    local available = base.inventory:getItemCount(itemId)
    if available < quantity then
        return nil, "Insufficient items"
    end
    
    -- Get sell price
    local entry = self:findPurchaseEntry(itemId)
    if not entry then
        -- Use base item price
        entry = ItemDatabase:getItem(itemId)
    end
    
    local pricePerUnit = entry.sellPrice or (entry.basePrice * 0.7)
    local totalPrice = pricePerUnit * quantity
    
    -- Remove from inventory
    base.inventory:removeItem(itemId, quantity)
    
    -- Add credits
    GameState.credits += totalPrice
    
    -- Track sale
    table.insert(self.salesHistory, {
        itemId = itemId,
        quantity = quantity,
        pricePerUnit = pricePerUnit,
        totalPrice = totalPrice,
        date = Calendar:getCurrentDate(),
    })
    
    -- Emit event
    EventManager:emit("item_sold", {
        itemId = itemId,
        quantity = quantity,
        totalPrice = totalPrice,
    })
    
    print("[Marketplace] Sold " .. quantity .. "x " .. itemId .. " for $" .. totalPrice)
    
    return totalPrice
```

**Sell Price:**
- Default: 70% of base purchase price
- Can be modified by market conditions
- Bulk selling has no discount (same per-unit price)

**Estimated time:** 6 hours

---

### Step 9: Monthly Stock Refresh (6 hours)
**Description:** Supplier inventories update monthly  
**Files to create:**
- `engine/geoscape/systems/marketplace_refresh.lua` - Monthly updates

**Monthly Refresh:**
```lua
MarketplaceRefresh:monthlyUpdate()
    for _, supplier in pairs(SupplierManager.suppliers) do
        -- Restock items
        for _, entryId in ipairs(supplier.entries) do
            local entry = MarketplaceManager:getPurchaseEntry(entryId)
            
            if entry.stock >= 0 then  -- -1 = unlimited
                entry.stock += entry.restockRate
                print("[Marketplace] Restocked " .. entry.name .. ": +" .. entry.restockRate)
            end
        end
        
        -- Add random items (optional)
        -- Add special offers (optional)
    end
    
    EventManager:emit("marketplace_refreshed")
```

**Integration with Calendar:**
```lua
-- In calendar system
Calendar:onMonthStart()
    MarketplaceRefresh:monthlyUpdate()
```

**Estimated time:** 6 hours

---

### Step 10: UI Implementation (16 hours)
**Description:** Marketplace screen with suppliers, items, orders  
**Files to create:**
- `engine/geoscape/ui/marketplace_screen.lua` - Main marketplace UI
- `engine/geoscape/ui/supplier_panel.lua` - Supplier selection
- `engine/geoscape/ui/purchase_entry_list.lua` - Available items
- `engine/geoscape/ui/purchase_order_panel.lua` - Active orders

**Marketplace Screen Layout (960×720, 24px grid):**
```
┌─────────────────────────────────────────┐
│ Marketplace              Credits: 500k  │ (Top bar)
├──────────┬──────────────────────────────┤
│ Suppliers│  Available Items             │
│ ┌──────┐│  ┌────────────────────────┐  │
│ │Global││  │ Assault Rifle          │  │
│ │Mil.  ││  │ Price: $10,000         │  │
│ │Surp. ││  │ Stock: 50              │  │
│ └──────┘│  │ Delivery: 7 days       │  │
│ ┌──────┐│  │ [Buy x10] [Buy x50]    │  │
│ │Adv.  ││  └────────────────────────┘  │
│ │Def.  ││  ┌────────────────────────┐  │
│ │Corp. ││  │ Body Armor             │  │
│ └──────┘│  │ Price: $15,000         │  │
│          │  └────────────────────────┘  │
├──────────┴──────────────────────────────┤
│ Active Orders                           │
│ ┌────────────────────────────────────┐ │
│ │ 10x Rifle → Base Alpha: 3 days     │ │
│ │ 5x Armor → Base Omega: 5 days      │ │
│ └────────────────────────────────────┘ │
│ [Sell Items] [View History]            │
└─────────────────────────────────────────┘
```

**Widgets (all grid-aligned 24px):**
- MarketplaceScreen (full screen)
- SupplierList (scrollable, show relationships)
- PurchaseEntryCard (4×3 grid cells)
- PurchaseOrderPanel (list active orders)
- QuantitySelector (quick buy buttons)
- BaseSelector (choose delivery destination)

**Estimated time:** 16 hours

---

### Step 11: Data Files (12 hours)
**Description:** Create comprehensive marketplace data for core mod  
**Files to create:**
- `engine/mods/core/marketplace/suppliers.toml` - Supplier definitions
- `engine/mods/core/marketplace/general.toml` - General equipment
- `engine/mods/core/marketplace/weapons.toml` - Weapons
- `engine/mods/core/marketplace/armor.toml` - Armor
- `engine/mods/core/marketplace/vehicles.toml` - Vehicles
- `engine/mods/core/marketplace/crafts.toml` - Crafts

**Example: Suppliers**
```toml
[military_surplus]
id = "military_surplus"
name = "Global Military Surplus"
description = "Standard military equipment supplier"
base_relationship = 0.0
available_regions = []  # Global
pricing_tier = "standard"
icon = "military_supplier.png"

[advanced_defense]
id = "advanced_defense"
name = "Advanced Defense Corporation"
description = "High-tech military contractor"
base_relationship = -0.5  # Starts neutral-poor
available_regions = ["north_america", "europe"]
pricing_tier = "premium"
requires_research = ["advanced_materials"]

[regional_asia]
id = "regional_asia"
name = "Pan-Asian Defense Consortium"
description = "Asian regional supplier"
available_regions = ["asia"]
pricing_tier = "standard"

[aerospace_ind]
id = "aerospace_ind"
name = "Global Aerospace Industries"
description = "Civilian and military aerospace"
available_regions = []
pricing_tier = "luxury"
requires_research = ["advanced_aeronautics"]
```

**Example: Weapons**
```toml
[rifle]
id = "rifle"
name = "Assault Rifle"
description = "Standard military rifle"
base_price = 10000
sell_price = 7000
item_id = "rifle"
item_type = "item"
supplier_id = "military_surplus"
stock = 100
restock_rate = 50
required_relationship = -2.0  # Always available
delivery_time = 7
category = "weapons"

[laser_rifle]
id = "laser_rifle"
name = "Laser Rifle"
base_price = 50000
sell_price = 35000
item_id = "laser_rifle"
supplier_id = "advanced_defense"
stock = 20
restock_rate = 10
required_research = ["laser_weapons"]
required_relationship = 0.0  # Need neutral or better
delivery_time = 14
category = "weapons"
available_regions = ["north_america", "europe"]

[plasma_rifle]
id = "plasma_rifle"
name = "Plasma Rifle"
base_price = 150000
item_id = "plasma_rifle"
supplier_id = "advanced_defense"
stock = 5
restock_rate = 2
required_research = ["plasma_weapons"]
required_relationship = 1.0  # Need good relationship
delivery_time = 21
category = "weapons"
```

**Estimated time:** 12 hours

---

### Step 12: Testing & Validation (10 hours)
**Description:** Unit tests, integration tests, manual testing  
**Files to create:**
- `engine/geoscape/tests/test_purchase_entry.lua`
- `engine/geoscape/tests/test_supplier.lua`
- `engine/geoscape/tests/test_marketplace_manager.lua`
- `engine/geoscape/tests/test_marketplace_pricing.lua`

**Test Cases:**
1. **Pricing:**
   - Base price correct
   - Relationship modifiers applied
   - Bulk discounts calculated
   - Regional modifiers
   
2. **Purchase Orders:**
   - Order placed successfully
   - Credits deducted
   - Stock reduced
   - Transfer created
   
3. **Relationships:**
   - Pricing changes with relationship
   - Items blocked at low relationship
   - Large purchases improve relationship
   
4. **Regional:**
   - Regional suppliers filtered
   - Regional items restricted
   
5. **Selling:**
   - Sell price correct (70% of base)
   - Items removed from inventory
   - Credits added

**Manual Testing:**
```bash
lovec "engine"
```
1. Open marketplace screen
2. Browse suppliers
3. Select supplier (military surplus)
4. View available items
5. Check pricing with neutral relationship
6. Place order (10 rifles to Base Alpha)
7. Verify credits deducted
8. Check active orders panel
9. Advance calendar 7 days
10. Verify rifles delivered to Base Alpha
11. Sell rifles back to marketplace
12. Verify 70% refund received

**Estimated time:** 10 hours

---

### Step 13: Documentation (6 hours)
**Description:** Update API docs, FAQ, wiki  
**Files to update:**
- `wiki/API.md` - MarketplaceManager, Supplier APIs
- `wiki/FAQ.md` - How to buy/sell equipment
- `wiki/DEVELOPMENT.md` - Marketplace system architecture
- `wiki/wiki/marketplace.md` - Complete marketplace guide

**Estimated time:** 6 hours

---

## Implementation Details

### Architecture

**Data Layer:**
- TOML files define suppliers and purchase entries
- Per-supplier inventory tracking
- Monthly stock refresh

**Logic Layer:**
- MarketplaceManager: Purchase/sell operations
- SupplierManager: Supplier management
- MarketplacePricing: Dynamic price calculation
- SupplierRelations: Relationship tracking

**System Layer:**
- Calendar integration for monthly refresh
- Transfer system integration for delivery
- Event system for orders and deliveries
- Relations system integration

**UI Layer:**
- Supplier browser (filter, sort)
- Item catalog (by category, supplier)
- Order tracking (delivery times)
- Sell interface

### Key Components

1. **PurchaseEntry:** Item available for purchase
2. **Supplier:** Vendor with inventory and relationships
3. **PurchaseOrder:** Active order with delivery tracking
4. **MarketplaceManager:** Central marketplace operations
5. **MarketplacePricing:** Dynamic pricing calculator

### Dependencies

- **TASK-029:** Transfer system for delivery
- **TASK-032:** Research system for unlocks
- **TASK-036:** Relations system for supplier relationships
- **TASK-025 Phase 2:** Calendar for monthly refresh

---

## Testing Strategy

### Unit Tests
- Pricing calculation
- Relationship modifiers
- Bulk discounts
- Regional filtering

### Integration Tests
- Purchase → Transfer → Delivery flow
- Relationship changes affecting prices
- Monthly stock refresh

### Manual Tests
- Browse marketplace
- Place orders
- Track deliveries
- Sell items
- Test different relationships

---

## Time Estimate

**Total: 120 hours (15 days)**

- Step 1: Purchase Entry Data Structure - 8h
- Step 2: Supplier System - 10h
- Step 3: Purchase Order System - 10h
- Step 4: Dynamic Pricing System - 8h
- Step 5: Transfer System Integration - 8h
- Step 6: Supplier Relationships - 8h
- Step 7: Regional Availability - 6h
- Step 8: Selling System - 6h
- Step 9: Monthly Stock Refresh - 6h
- Step 10: UI Implementation - 16h
- Step 11: Data Files - 12h
- Step 12: Testing & Validation - 10h
- Step 13: Documentation - 6h
