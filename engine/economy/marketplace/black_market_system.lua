---Black Market System
---
---Provides access to illegal and restricted items with karma/fame costs and
---discovery risks. Players can purchase powerful equipment, alien technology,
---and banned items through underground contacts. High risk, high reward.
---
---Black Market Features:
---  - Illegal items unavailable in regular marketplace
---  - 33% price markup for underground goods
---  - Karma impact for unethical purchases
---  - Discovery chance (consequences for getting caught)
---  - Regional availability restrictions
---  - Black market reputation levels (1-3)
---  - Limited stock and periodic refresh
---
---Discovery Consequences:
---  - Fame/karma loss
---  - Supplier relationship penalties
---  - Country relationship damage
---  - Potential base raids
---
---Key Exports:
---  - BlackMarketSystem.new(): Creates black market instance
---  - purchaseItem(itemId, quantity): Buys illegal item
---  - checkDiscovery(): Rolls for transaction discovery
---  - getAvailableItems(region, level): Lists available items
---  - refreshStock(): Updates available inventory
---  - getLevelRequirement(itemId): Checks access level needed
---
---Dependencies:
---  - politics.karma: Karma system for ethics tracking
---  - politics.fame: Fame system for reputation
---  - politics.relations: Country relationship system
---  - shared.items: Item definitions
---
---@module economy.marketplace.black_market_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local BlackMarket = require("economy.marketplace.black_market_system")
---  local market = BlackMarket.new()
---  local items = market:getAvailableItems("europe", 2)
---  market:purchaseItem("plasma_rifle", 1)  -- Risky!
---
---@see politics.karma For karma system
---@see economy.marketplace.marketplace_system For legal marketplace

local BlackMarketSystem = {}
BlackMarketSystem.__index = BlackMarketSystem

---@class BlackMarketEntry
---@field id string Entry ID
---@field name string Item name
---@field itemId string Item to produce
---@field basePrice number Price (33% markup)
---@field stock number Available quantity
---@field karmaImpact number Karma loss per purchase
---@field discoveryChance number Base discovery chance (0-1)
---@field availableRegions table Region restrictions
---@field requiredLevel number Black market level (1-3)

--- Create new black market system
function BlackMarketSystem.new()
    local self = setmetatable({}, BlackMarketSystem)
    
    -- Black market entries
    self.entries = {}
    
    -- Dealers (underground contacts)
    self.dealers = {}
    self.discoveredDealers = {}
    
    -- Purchase history (for risk calculation)
    self.purchaseHistory = {}
    
    -- Black market level (unlocked via missions)
    self.marketLevel = 1  -- 1-3, unlocks more items
    
    -- Discovery penalties
    self.discoveryPenalties = {
        karmaMultiplier = 2.0,  -- Double karma loss
        fameLoss = -20,
        relationPenalty = -0.5,
        fundingCut = 0.8,  -- 20% funding cut
    }
    
    print("[BlackMarketSystem] Initialized")
    return self
end

--- Add black market entry
---@param entry BlackMarketEntry Entry data
function BlackMarketSystem:addEntry(entry)
    self.entries[entry.id] = entry
    print("[BlackMarketSystem] Added entry: " .. entry.name)
end

--- Get black market entry
---@param entryId string Entry ID
---@return BlackMarketEntry|nil Entry
function BlackMarketSystem:getEntry(entryId)
    return self.entries[entryId]
end

--- Get all available entries for current level
---@return table Array of entries
function BlackMarketSystem:getAvailableEntries()
    local available = {}
    
    for _, entry in pairs(self.entries) do
        if entry.requiredLevel <= self.marketLevel and entry.stock > 0 then
            table.insert(available, entry)
        end
    end
    
    return available
end

--- Make purchase
---@param entryId string Entry ID
---@param quantity number Quantity to buy
---@param baseId string Base receiving items
---@param karmaSystem table KarmaSystem instance
---@param fameSystem table FameSystem instance
---@return table|nil Order result {success, discovered, karmaLoss, order}
function BlackMarketSystem:makePurchase(entryId, quantity, baseId, karmaSystem, fameSystem)
    local entry = self:getEntry(entryId)
    
    if not entry then
        print("[BlackMarketSystem] Entry not found: " .. entryId)
        return {success = false, reason = "Entry not found"}
    end
    
    -- Check stock
    if entry.stock < quantity then
        print("[BlackMarketSystem] Insufficient stock")
        return {success = false, reason = "Insufficient stock"}
    end
    
    -- Check level
    if entry.requiredLevel > self.marketLevel then
        print("[BlackMarketSystem] Required level: " .. entry.requiredLevel)
        return {success = false, reason = "Level too low"}
    end
    
    -- Calculate total cost
    local totalCost = entry.basePrice * quantity
    
    -- Calculate karma loss
    local karmaLoss = entry.karmaImpact * quantity
    
    -- Apply karma loss immediately
    if karmaSystem then
        karmaSystem:modifyKarma(karmaLoss, "Black market: " .. entry.name)
    end
    
    -- Check for discovery
    local discovered = self:checkDiscovery(entry, quantity)
    
    if discovered then
        print("[BlackMarketSystem] BLACK MARKET PURCHASE DISCOVERED!")
        self:applyDiscoveryConsequences(entry, quantity, karmaSystem, fameSystem)
    end
    
    -- Reduce stock
    entry.stock = entry.stock - quantity
    
    -- Record purchase
    table.insert(self.purchaseHistory, {
        entryId = entryId,
        quantity = quantity,
        cost = totalCost,
        discovered = discovered,
        timestamp = os.time(),
    })
    
    -- Create order
    local order = {
        itemId = entry.itemId,
        quantity = quantity,
        cost = totalCost,
        baseId = baseId,
        deliveryDays = 1,  -- Black market is fast
    }
    
    print("[BlackMarketSystem] Purchase complete: " .. entry.name .. " x" .. quantity .. 
          " (Karma: " .. karmaLoss .. ", Discovered: " .. tostring(discovered) .. ")")
    
    return {
        success = true,
        discovered = discovered,
        karmaLoss = karmaLoss,
        order = order,
    }
end

--- Check if purchase is discovered
---@param entry BlackMarketEntry Entry
---@param quantity number Quantity
---@return boolean Discovered
function BlackMarketSystem:checkDiscovery(entry, quantity)
    local chance = self:calculateDiscoveryChance(entry, quantity)
    local roll = math.random()
    
    return roll <= chance
end

--- Calculate discovery chance
---@param entry BlackMarketEntry Entry
---@param quantity number Quantity
---@return number Chance (0-1)
function BlackMarketSystem:calculateDiscoveryChance(entry, quantity)
    local baseChance = entry.discoveryChance or 0.15
    
    -- Quantity modifier (+10% per item)
    local quantityMod = 1.0 + (quantity - 1) * 0.1
    
    -- Fame modifier (higher fame = more scrutiny)
    local fameMod = 1.0  -- Default if no fame system
    
    -- Regional modifier (lower risk in specific regions)
    local regionalMod = 1.0
    if entry.availableRegions and #entry.availableRegions > 0 then
        regionalMod = 0.8
    end
    
    local finalChance = baseChance * quantityMod * fameMod * regionalMod
    
    -- Cap at 50%
    return math.min(finalChance, 0.5)
end

--- Apply discovery consequences
---@param entry BlackMarketEntry Entry
---@param quantity number Quantity
---@param karmaSystem table KarmaSystem instance
---@param fameSystem table FameSystem instance
function BlackMarketSystem:applyDiscoveryConsequences(entry, quantity, karmaSystem, fameSystem)
    -- Additional karma loss (double penalty)
    if karmaSystem then
        local additionalKarma = entry.karmaImpact * quantity * self.discoveryPenalties.karmaMultiplier
        karmaSystem:modifyKarma(-additionalKarma, "Black market discovery")
    end
    
    -- Fame loss
    if fameSystem then
        fameSystem:modifyFame(self.discoveryPenalties.fameLoss, "Illegal arms deal exposed")
    end
    
    -- Note: Relations and funding penalties require integration with those systems
    -- This would be done in the Geoscape layer when those systems are available
    
    print("[BlackMarketSystem] Discovery consequences applied")
end

--- Unlock dealer (via mission or event)
---@param dealerId string Dealer ID
function BlackMarketSystem:unlockDealer(dealerId)
    if not self.discoveredDealers[dealerId] then
        self.discoveredDealers[dealerId] = true
        print("[BlackMarketSystem] Dealer unlocked: " .. dealerId)
    end
end

--- Increase black market level
---@param newLevel number New level (1-3)
function BlackMarketSystem:setMarketLevel(newLevel)
    self.marketLevel = math.max(1, math.min(3, newLevel))
    print("[BlackMarketSystem] Market level: " .. self.marketLevel)
end

--- Get purchase history
---@return table Array of purchases
function BlackMarketSystem:getPurchaseHistory()
    return self.purchaseHistory
end

--- Check if dealer is unlocked
---@param dealerId string Dealer ID
---@return boolean Unlocked
function BlackMarketSystem:isDealerUnlocked(dealerId)
    return self.discoveredDealers[dealerId] == true
end

--- Monthly stock refresh (called by calendar)
function BlackMarketSystem:monthlyRefresh()
    print("[BlackMarketSystem] Monthly stock refresh")
    
    -- Black market doesn't restock! Limited availability
    -- Only new entries may appear at higher levels
end

--- Save state
---@return table State
function BlackMarketSystem:saveState()
    return {
        entries = self.entries,
        dealers = self.dealers,
        discoveredDealers = self.discoveredDealers,
        purchaseHistory = self.purchaseHistory,
        marketLevel = self.marketLevel,
    }
end

--- Load state
---@param state table Saved state
function BlackMarketSystem:loadState(state)
    self.entries = state.entries or {}
    self.dealers = state.dealers or {}
    self.discoveredDealers = state.discoveredDealers or {}
    self.purchaseHistory = state.purchaseHistory or {}
    self.marketLevel = state.marketLevel or 1
    
    print("[BlackMarketSystem] State loaded")
end

---
--- EXTENDED SERVICES: Corpse Trading, Mission Generation, Event Purchasing
--- Integrated from: design/mechanics/BlackMarket.md
---

--- Sell corpse through Black Market
---@param corpseItem table Corpse item
---@param karmaSystem table Karma system
---@param treasury table Treasury system
---@return boolean success
---@return string|nil reason
---@return table|nil result
function BlackMarketSystem:sellCorpse(corpseItem, karmaSystem, treasury)
    local CorpseTrading = require("engine.economy.corpse_trading")
    return CorpseTrading.sellCorpse(corpseItem, self, karmaSystem, treasury)
end

--- Get corpse value
---@param corpseItem table Corpse item
---@return number value
function BlackMarketSystem:getCorpseValue(corpseItem)
    local CorpseTrading = require("engine.economy.corpse_trading")
    return CorpseTrading.getCorpseValue(corpseItem)
end

--- Get alternative uses for corpse (ethical options)
---@param corpseItem table Corpse item
---@return table alternatives
function BlackMarketSystem:getCorpseAlternatives(corpseItem)
    local CorpseTrading = require("engine.economy.corpse_trading")
    return CorpseTrading.getAlternativeUses(corpseItem)
end

--- Purchase mission from Black Market
---@param missionType string Mission type (assassination, sabotage, etc.)
---@param targetRegion string Target region
---@param karmaSystem table Karma system
---@param treasury table Treasury system
---@return boolean success
---@return string|nil reason
---@return table|nil result
function BlackMarketSystem:purchaseMission(missionType, targetRegion, karmaSystem, treasury)
    local MissionGeneration = require("engine.economy.mission_generation")
    return MissionGeneration.purchaseMission(missionType, targetRegion, self, karmaSystem, treasury)
end

--- Get available missions for purchase
---@param karma number Current karma
---@return table missions
function BlackMarketSystem:getAvailableMissions(karma)
    local MissionGeneration = require("engine.economy.mission_generation")
    return MissionGeneration.getAvailableMissions(karma)
end

--- Purchase event from Black Market
---@param eventType string Event type (improve_relations, sabotage_economy, etc.)
---@param targetId string Target ID
---@param karmaSystem table Karma system
---@param treasury table Treasury system
---@return boolean success
---@return string|nil reason
---@return table|nil result
function BlackMarketSystem:purchaseEvent(eventType, targetId, karmaSystem, treasury)
    local EventPurchasing = require("engine.economy.event_purchasing")
    return EventPurchasing.purchaseEvent(eventType, targetId, self, karmaSystem, treasury)
end

--- Get available events for purchase
---@param karma number Current karma
---@param fame number Current fame
---@return table events
function BlackMarketSystem:getAvailableEvents(karma, fame)
    local EventPurchasing = require("engine.economy.event_purchasing")
    return EventPurchasing.getAvailableEvents(karma, fame)
end

--- Get access level based on karma and fame
---@param karma number Current karma (-100 to +100)
---@param fame number Current fame (0-100)
---@return string accessLevel "restricted"|"standard"|"enhanced"|"complete"
function BlackMarketSystem:getAccessLevel(karma, fame)
    -- Karma requirements for access tiers
    if karma >= 40 then
        return "none"  -- Too high karma, no access
    elseif karma >= 10 then
        if fame >= 25 then
            return "restricted"  -- Items only
        else
            return "none"  -- Need minimum fame
        end
    elseif karma >= -39 then
        if fame >= 25 then
            return "standard"  -- Items, units, some services
        else
            return "none"
        end
    elseif karma >= -74 then
        if fame >= 60 then
            return "enhanced"  -- All except extreme operations
        else
            return "standard"
        end
    else  -- karma <= -75
        if fame >= 75 then
            return "complete"  -- Everything available
        else
            return "enhanced"
        end
    end
end

--- Check if player can access specific service
---@param serviceName string Service name
---@param karma number Current karma
---@param fame number Current fame
---@return boolean canAccess
---@return string|nil reason
function BlackMarketSystem:canAccessService(serviceName, karma, fame)
    local accessLevel = self:getAccessLevel(karma, fame)

    if accessLevel == "none" then
        return false, "Insufficient karma or fame for Black Market access"
    end

    -- Service requirements
    local serviceRequirements = {
        items = "restricted",
        corpse_trading = "restricted",
        units = "standard",
        missions = "standard",
        events = "enhanced",
        craft = "enhanced",
        extreme_operations = "complete",
    }

    local required = serviceRequirements[serviceName] or "restricted"

    local accessOrder = {none = 0, restricted = 1, standard = 2, enhanced = 3, complete = 4}
    local playerLevel = accessOrder[accessLevel] or 0
    local requiredLevel = accessOrder[required] or 1

    if playerLevel >= requiredLevel then
        return true
    else
        return false, "Requires " .. required .. " access (current: " .. accessLevel .. ")"
    end
end

--- Get all available services based on access level
---@param karma number Current karma
---@param fame number Current fame
---@return table services Array of available service names
function BlackMarketSystem:getAvailableServices(karma, fame)
    local accessLevel = self:getAccessLevel(karma, fame)
    local services = {}

    if accessLevel == "none" then
        return services
    end

    -- Always available
    table.insert(services, "items")
    table.insert(services, "corpse_trading")

    if accessLevel == "standard" or accessLevel == "enhanced" or accessLevel == "complete" then
        table.insert(services, "units")
        table.insert(services, "missions")
    end

    if accessLevel == "enhanced" or accessLevel == "complete" then
        table.insert(services, "events")
        table.insert(services, "craft")
    end

    if accessLevel == "complete" then
        table.insert(services, "extreme_operations")
    end

    return services
end

--- Calculate cumulative discovery risk
---@return number risk 0.0-1.0 discovery chance
function BlackMarketSystem:getCumulativeDiscoveryRisk()
    local transactionCount = #self.purchaseHistory
    local baseRisk = 0.05  -- 5% base

    -- Increase risk with transaction count
    if transactionCount >= 31 then
        return baseRisk + 0.15
    elseif transactionCount >= 16 then
        return baseRisk + 0.10
    elseif transactionCount >= 6 then
        return baseRisk + 0.05
    else
        return baseRisk
    end
end

--- Get summary of Black Market status (for UI)
---@param karma number Current karma
---@param fame number Current fame
---@return table summary
function BlackMarketSystem:getStatusSummary(karma, fame)
    local accessLevel = self:getAccessLevel(karma, fame)
    local services = self:getAvailableServices(karma, fame)
    local discoveryRisk = self:getCumulativeDiscoveryRisk()

    return {
        access_level = accessLevel,
        available_services = services,
        transaction_count = #self.purchaseHistory,
        discovery_risk = discoveryRisk,
        discovered_dealers = self.discoveredDealers,
        market_level = self.marketLevel,
    }
end

return BlackMarketSystem


























