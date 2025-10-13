# Task: Black Market System - Illegal Trade with Karma/Fame Impact

**Status:** TODO  
**Priority:** Medium  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement black market system for illegal/restricted items with karma/fame impact, limited availability, regional restrictions, risk mechanics, and discovery consequences. Black market provides access to powerful items but with ethical and reputation costs.

---

## Purpose

The black market offers players access to restricted items not available through normal suppliers, but with significant risks: karma loss, fame damage, potential funding cuts if discovered, and relationship penalties. Creates ethical dilemmas and risk/reward decisions.

---

## Requirements

### Functional Requirements
- [ ] Black Market Entries: Illegal/restricted items
- [ ] Black Market Suppliers: Underground dealers
- [ ] Karma Impact: Purchases reduce karma
- [ ] Fame Impact: Discovery damages reputation
- [ ] Risk System: Chance of discovery per transaction
- [ ] Regional Restrictions: Some items only in certain regions
- [ ] Discovery Consequences: Funding cuts, relation penalties
- [ ] Limited Availability: Monthly stock, no restocking
- [ ] Premium Pricing: Higher prices than normal market
- [ ] Research Unlocks: Some black market items require tech

### Technical Requirements
- [ ] Separate from normal marketplace system
- [ ] Integration with karma/fame system (TASK-036)
- [ ] Integration with relations system (country/supplier)
- [ ] Risk calculation per transaction
- [ ] Discovery event system
- [ ] State persistence

### Acceptance Criteria
- [ ] Black market accessible only after discovery (mission/event)
- [ ] Purchases reduce karma automatically
- [ ] Discovery chance calculated per transaction
- [ ] Discovery triggers fame loss and funding cuts
- [ ] Limited stock refreshes monthly
- [ ] Higher prices than normal suppliers
- [ ] Regional black markets have unique items

---

## Plan

### Step 1: Black Market Entry System (6 hours)
**Description:** Define black market items with karma costs  
**Files to create:**
- `engine/geoscape/logic/black_market_entry.lua`
- `engine/mods/core/black_market/illegal_weapons.toml`
- `engine/mods/core/black_market/alien_tech.toml`

**BlackMarketEntry Schema:**
```lua
BlackMarketEntry = {
    id = "alien_plasma_black",
    name = "Alien Plasma Rifle (Illegal)",
    description = "Smuggled alien weapon",
    
    -- Pricing (higher than normal)
    basePrice = 200000,  -- 33% markup over normal
    
    -- Item produced
    itemId = "plasma_rifle",
    itemType = "item",
    
    -- Black market supplier
    dealerId = "underground_network",
    
    -- Availability
    stock = 3,  -- Very limited
    restockRate = 0,  -- No restocking!
    
    -- Karma/Fame impact
    karmaImpact = -10,  -- Lose 10 karma per purchase
    fameRisk = 5,       -- 5% chance to damage fame if discovered
    
    -- Discovery risk
    discoveryChance = 0.15,  -- 15% chance per transaction
    
    -- Regional
    availableRegions = {"asia", "africa"},  -- Not in all regions
    
    -- Prerequisites
    requiredResearch = {},  -- Optional
    blackMarketLevel = 1,   -- 1-3, unlock via missions
}
```

**Estimated time:** 6 hours

---

### Step 2: Black Market Supplier System (8 hours)
**Description:** Underground dealers with unique inventories  
**Files to create:**
- `engine/geoscape/logic/black_market_dealer.lua`
- `engine/geoscape/systems/black_market_manager.lua`

**BlackMarketDealer Schema:**
```lua
BlackMarketDealer = {
    id = "underground_network",
    name = "Underground Arms Network",
    description = "Illegal weapons and tech dealer",
    
    -- Inventory
    entries = {},  -- Black market entry IDs
    
    -- Discovery
    discoveryMission = "raid_black_market",  -- How to unlock
    discovered = false,
    
    -- Regional
    availableRegions = {},  -- Where dealer operates
    
    -- Level system
    trustLevel = 1,  -- 1-3, unlocks more items
}
```

**BlackMarketManager:**
```lua
BlackMarketManager = {
    dealers = {},  -- All black market dealers
    discoveredDealers = {},  -- Unlocked dealers
    purchaseHistory = {},  -- Track for discovery
}

BlackMarketManager:unlockDealer(dealerId)  -- Via mission/event
BlackMarketManager:canPurchase(entryId) -> boolean
BlackMarketManager:calculateRisk(entry) -> number
BlackMarketManager:makePurchase(entryId, quantity, baseId) -> order, discovered
BlackMarketManager:onDiscovery(dealerId)  -- Trigger consequences
BlackMarketManager:increaseTrustLevel(dealerId)  -- Via missions
```

**Estimated time:** 8 hours

---

### Step 3: Risk & Discovery System (8 hours)
**Description:** Calculate discovery chance and apply consequences  
**Files to create:**
- `engine/geoscape/logic/black_market_risk.lua`

**Risk Calculation:**
```lua
BlackMarketRisk:calculateDiscoveryChance(entry, quantity)
    local baseChance = entry.discoveryChance  -- 15%
    
    -- Quantity modifier
    local quantityMod = 1.0 + (quantity - 1) * 0.1  -- +10% per item
    
    -- Fame modifier (higher fame = more scrutiny)
    local fameMod = 1.0 + (FameSystem:getFameLevel() / 100)
    
    -- Regional modifier
    local regionalMod = 1.0
    if entry.availableRegions and #entry.availableRegions > 0 then
        regionalMod = 0.8  -- Lower risk in specific regions
    end
    
    local finalChance = baseChance * quantityMod * fameMod * regionalMod
    return math.min(finalChance, 0.5)  -- Max 50% chance
end

BlackMarketRisk:checkDiscovery(entry, quantity)
    local chance = self:calculateDiscoveryChance(entry, quantity)
    local roll = math.random()
    
    if roll <= chance then
        return true  -- Discovered!
    end
    
    return false
end

BlackMarketRisk:applyDiscoveryConsequences(entry, quantity)
    -- Karma loss (double)
    KarmaSystem:modifyKarma(-entry.karmaImpact * 2, "Black market discovery")
    
    -- Fame loss
    FameSystem:modifyFame(-20, "Illegal arms deal exposed")
    
    -- Funding cuts from all countries
    for country in CountryManager:getAllCountries() do
        RelationsManager:modifyRelation("country", country.id, -0.5, "Illegal activity")
        FundingManager:applyPenalty(country.id, 0.8)  -- 20% cut
    end
    
    -- Supplier relationship damage
    for supplier in SupplierManager:getAllSuppliers() do
        SupplierRelations:modifyRelationship(supplier.id, -0.3, "Illegal dealings")
    end
    
    -- Event log
    EventManager:emit("black_market_discovered", {
        entryId = entry.id,
        quantity = quantity,
        consequences = "Karma -" .. (entry.karmaImpact * 2) .. ", Fame -20, Funding cuts"
    })
end
```

**Estimated time:** 8 hours

---

### Step 4: Karma/Fame Integration (6 hours)
**Description:** Link to karma/fame system for impacts  
**Dependencies:** TASK-036 (Fame/Karma System)
**Files to modify:**
- `engine/geoscape/systems/karma_system.lua` - Add black market hooks
- `engine/geoscape/systems/fame_system.lua` - Add discovery penalties

**Karma Impact:**
```lua
-- Automatic karma loss on purchase
BlackMarketManager:makePurchase(entryId, quantity, baseId)
    local entry = self:getEntry(entryId)
    
    -- Deduct karma
    local karmaLoss = entry.karmaImpact * quantity
    KarmaSystem:modifyKarma(karmaLoss, "Black market purchase: " .. entry.name)
    
    -- Check discovery
    local discovered = BlackMarketRisk:checkDiscovery(entry, quantity)
    if discovered then
        BlackMarketRisk:applyDiscoveryConsequences(entry, quantity)
    end
    
    -- Proceed with purchase
    local order = self:createOrder(entry, quantity, baseId)
    return order, discovered
end
```

**Fame System Integration:**
- Discovery damages fame (public scandal)
- Low fame = less scrutiny (lower discovery chance)
- High fame = more media attention (higher discovery chance)

**Estimated time:** 6 hours

---

### Step 5: Regional Black Markets (6 hours)
**Description:** Different regions have different black market items  
**Files to create:**
- `engine/geoscape/logic/regional_black_markets.lua`

**Regional Availability:**
```lua
-- Different dealers in different regions
BlackMarketDealer = {
    id = "asian_syndicate",
    name = "Asian Crime Syndicate",
    availableRegions = {"asia"},
    entries = {"alien_artifacts_asia", "bio_weapons", "stealth_tech"},
}

BlackMarketDealer = {
    id = "african_warlords",
    name = "African Arms Dealers",
    availableRegions = {"africa"},
    entries = {"heavy_weapons", "military_vehicles", "merc_units"},
}

BlackMarketDealer = {
    id = "european_underground",
    name = "European Black Market",
    availableRegions = {"europe"},
    entries = {"alien_tech_europe", "advanced_armor", "black_ops_gear"},
}
```

**Strategic Importance:**
- Players need bases in different regions for full black market access
- Regional items are unique (not available elsewhere)
- Adds strategic base placement decisions

**Estimated time:** 6 hours

---

### Step 6: Trust Level System (6 hours)
**Description:** Unlock more items via trust with dealers  
**Files to create:**
- `engine/geoscape/logic/black_market_trust.lua`

**Trust Levels:**
```lua
BlackMarketDealer = {
    trustLevel = 1,  -- Current level (1-3)
    
    -- Level requirements
    trustLevels = {
        [1] = {purchases = 0, missions = 0},   -- Starting
        [2] = {purchases = 5, missions = 1},   -- Medium trust
        [3] = {purchases = 15, missions = 3},  -- High trust
    },
}

BlackMarketEntry = {
    blackMarketLevel = 2,  -- Requires trust level 2+
}

BlackMarketTrust:increaseTrust(dealerId)
    local dealer = BlackMarketManager:getDealer(dealerId)
    local purchases = dealer.totalPurchases
    local missions = dealer.missionsCompleted
    
    -- Check if can level up
    for level = 3, 1, -1 do
        local req = dealer.trustLevels[level]
        if purchases >= req.purchases and missions >= req.missions then
            dealer.trustLevel = level
            EventManager:emit("black_market_trust_increased", {
                dealerId = dealerId,
                newLevel = level,
            })
            break
        end
    end
```

**Estimated time:** 6 hours

---

### Step 7: UI Implementation (12 hours)
**Description:** Black market screen with risk visualization  
**Files to create:**
- `engine/geoscape/ui/black_market_screen.lua`
- `engine/geoscape/ui/black_market_entry_card.lua`

**UI Features:**
- Warning messages about karma/fame impact
- Discovery risk percentage shown
- Trust level visualization
- "Are you sure?" confirmation dialog

**Estimated time:** 12 hours

---

### Step 8: Data Files (8 hours)
**Description:** Black market items and dealers  
**Files to create:**
- `engine/mods/core/black_market/dealers.toml`
- `engine/mods/core/black_market/illegal_weapons.toml`
- `engine/mods/core/black_market/alien_tech.toml`
- `engine/mods/core/black_market/restricted_items.toml`

**Example Items:**
- Alien weapons (smuggled)
- Bio weapons (illegal)
- Experimental tech (stolen)
- Mercenary units (gray area)
- Restricted materials (controlled substances)

**Estimated time:** 8 hours

---

### Step 9: Testing & Documentation (8 hours)
**Description:** Unit tests and API documentation  

**Test Cases:**
- Purchase reduces karma
- Discovery triggers consequences
- Trust levels unlock items
- Regional restrictions work
- Risk calculation accurate

**Estimated time:** 8 hours

---

## Time Estimate

**Total: 72 hours (9 days)**

- Step 1: Black Market Entry System - 6h
- Step 2: Black Market Supplier System - 8h
- Step 3: Risk & Discovery System - 8h
- Step 4: Karma/Fame Integration - 6h
- Step 5: Regional Black Markets - 6h
- Step 6: Trust Level System - 6h
- Step 7: UI Implementation - 12h
- Step 8: Data Files - 8h
- Step 9: Testing & Documentation - 8h

---

## Dependencies

- **TASK-034:** Normal marketplace system (black market is separate but related)
- **TASK-036:** Fame/Karma/Reputation system (for impacts)
- **TASK-027:** Relations system (for consequences)
- **TASK-025:** Calendar for monthly refresh
