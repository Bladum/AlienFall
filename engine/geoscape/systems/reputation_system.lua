---Reputation System - Aggregate Standing
---
---Calculates overall reputation as a weighted combination of Fame, Karma, and
---Relations (countries, suppliers). Reputation affects marketplace prices, item
---availability, mission access, funding multipliers, and recruit quality.
---
---Reputation Value:
---  - Range: 0 (terrible) to 100 (legendary)
---  - Levels: Terrible (0-29), Poor (30-49), Good (50-69), Excellent (70-89), Legendary (90-100)
---
---Component Weights:
---  - Fame: 40% (public recognition)
---  - Karma: 20% (moral standing)
---  - Country Relations: 30% (political influence)
---  - Supplier Relations: 10% (market standing)
---
---Reputation Effects:
---  - Marketplace Prices: -30% to +50%
---  - Item Availability: Some items require minimum reputation
---  - Mission Access: Special missions for high reputation
---  - Funding Multiplier: 0.5 to 1.5x
---  - Recruit Quality: Better recruits at high reputation
---  - Research: Tech access gates on reputation
---
---Key Exports:
---  - ReputationSystem.new(): Create system
---  - calculateReputation(): Update from components
---  - getReputation(): Get current value
---  - getLevel(reputation): Get descriptive level
---  - getMarketplaceModifier(): Get price multiplier
---  - getRecruitQualityModifier(): Get recruit stat multiplier
---
---@module geoscape.systems.reputation_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ReputationSystem = require("geoscape.systems.reputation_system")
---  local rep = ReputationSystem.new(fameSystem, karmaSystem, relationsManager)
---  rep:calculateReputation()
---  print("Level: " .. rep:getLevel(rep:getReputation()))

local ReputationSystem = {}
ReputationSystem.__index = ReputationSystem

--- Create new reputation system
---@param fameSystem table Reference to FameSystem
---@param karmaSystem table Reference to KarmaSystem
---@param relationsManager table Reference to RelationsManager
---@return table New reputation system instance
function ReputationSystem.new(fameSystem, karmaSystem, relationsManager)
    local self = setmetatable({}, ReputationSystem)
    
    -- Component systems
    self.fameSystem = fameSystem
    self.karmaSystem = karmaSystem
    self.relationsManager = relationsManager
    
    -- Core state
    self.reputation = 50  -- Start at "Good"
    self.history = {}  -- Calculation history
    
    -- Level definitions
    self.levels = {
        {min = 90,  max = 100, label = "Legendary",  color = {255, 215, 0}},
        {min = 70,  max = 89,  label = "Excellent",  color = {0, 255, 0}},
        {min = 50,  max = 69,  label = "Good",       color = {0, 150, 255}},
        {min = 30,  max = 49,  label = "Poor",       color = {200, 100, 0}},
        {min = 0,   max = 29,  label = "Terrible",   color = {255, 0, 0}}
    }
    
    -- Component weights
    self.weights = {
        fame = 0.40,          -- 40% from fame
        karma = 0.20,         -- 20% from karma
        countryRelations = 0.30,  -- 30% from country relations
        supplierRelations = 0.10,  -- 10% from supplier relations
    }
    
    -- Configuration
    self.config = {
        maxReputation = 100,
        minReputation = 0,
        maxHistorySize = 12,  -- Monthly history
    }
    
    -- Effects thresholds
    self.effectThresholds = {
        recruitsUnlock = 30,      -- Need 30+ to get better recruits
        specialMissions = 60,     -- 60+ to get special missions
        priceDiscount = 50,       -- 50+ for marketplace discount
        itemRestriction = 40,     -- Below 40 = some items unavailable
    }
    
    print("[ReputationSystem] Initialized with reputation = 50 (Good)")
    
    return self
end

---Calculate reputation from component systems
---@return number New reputation value
function ReputationSystem:calculateReputation()
    if not self.fameSystem or not self.karmaSystem or not self.relationsManager then
        print("[ReputationSystem] WARNING: Component systems not initialized")
        return self.reputation
    end
    
    -- Get component values
    local fameValue = self.fameSystem:getFame()  -- 0-100
    local karmaValue = self.karmaSystem:getKarma()  -- -100 to +100
    
    -- Convert karma from -100/+100 to 0/100 scale
    local karmaAsReputation = (karmaValue + 100) / 2
    
    -- Get average country relations
    local countryReputation = self:getAverageCountryReputation()
    
    -- Get average supplier relations
    local supplierReputation = self:getAverageSupplierReputation()
    
    -- Calculate weighted average
    local newReputation = 
        (fameValue * self.weights.fame) +
        (karmaAsReputation * self.weights.karma) +
        (countryReputation * self.weights.countryRelations) +
        (supplierReputation * self.weights.supplierRelations)
    
    -- Clamp to valid range
    newReputation = math.max(0, math.min(100, newReputation))
    
    -- Record change if significant
    if math.abs(newReputation - self.reputation) > 0.5 then
        table.insert(self.history, 1, {
            reputation = newReputation,
            fame = fameValue,
            karma = karmaAsReputation,
            countries = countryReputation,
            suppliers = supplierReputation,
            timestamp = os.time()
        })
        
        -- Keep only recent history
        if #self.history > self.config.maxHistorySize then
            table.remove(self.history, self.config.maxHistorySize + 1)
        end
    end
    
    self.reputation = newReputation
    
    return self.reputation
end

---Get average country relations as reputation value (0-100)
---@return number Average converted to 0-100 scale
function ReputationSystem:getAverageCountryReputation()
    if not self.relationsManager then
        return 50
    end
    
    local allCountries = self.relationsManager:getAllRelations("country")
    if #allCountries == 0 then
        return 50
    end
    
    local totalReputation = 0
    
    for _, countryData in ipairs(allCountries) do
        -- Convert -100 to +100 relation to 0-100 reputation
        local converted = (countryData.value + 100) / 2
        totalReputation = totalReputation + converted
    end
    
    return totalReputation / #allCountries
end

---Get average supplier relations as reputation value (0-100)
---@return number Average converted to 0-100 scale
function ReputationSystem:getAverageSupplierReputation()
    if not self.relationsManager then
        return 50
    end
    
    local allSuppliers = self.relationsManager:getAllRelations("supplier")
    if #allSuppliers == 0 then
        return 50
    end
    
    local totalReputation = 0
    
    for _, supplierData in ipairs(allSuppliers) do
        -- Convert -100 to +100 relation to 0-100 reputation
        local converted = (supplierData.value + 100) / 2
        totalReputation = totalReputation + converted
    end
    
    return totalReputation / #allSuppliers
end

---Get current reputation
---@return number Reputation value (0-100)
function ReputationSystem:getReputation()
    return self.reputation
end

---Set reputation to exact value
---@param value number Target reputation (0-100)
---@param reason string Reason for setting
function ReputationSystem:setReputation(value, reason)
    value = math.max(self.config.minReputation, math.min(self.config.maxReputation, value))
    self.reputation = value
    print(string.format("[ReputationSystem] Set to %d (%s)", value, reason or ""))
end

---Get level for reputation value
---@param value number Reputation value
---@return string Level name
function ReputationSystem:getLevel(value)
    for _, level in ipairs(self.levels) do
        if value >= level.min and value <= level.max then
            return level.label
        end
    end
    return "Unknown"
end

---Get color for reputation level (for UI)
---@return table RGB color {r, g, b}
function ReputationSystem:getReputationColor()
    local level = self:getLevel(self.reputation)
    
    for _, levelDef in ipairs(self.levels) do
        if levelDef.label == level then
            return levelDef.color
        end
    end
    
    return {150, 150, 150}  -- Default gray
end

---Get marketplace price modifier
---@return number Price multiplier (0.7 to 1.5)
function ReputationSystem:getMarketplaceModifier()
    -- 0 reputation = 1.5x price (expensive)
    -- 50 reputation = 1.0x price (normal)
    -- 100 reputation = 0.7x price (30% discount)
    
    local modifier = 1.5 - (self.reputation / 100) * 0.8
    return math.max(0.7, math.min(1.5, modifier))
end

---Get recruit quality modifier
---@return number Quality multiplier (0.8 to 1.2)
function ReputationSystem:getRecruitQualityModifier()
    -- Below 30: -20% stats
    -- 30-50: -10% stats
    -- 50-70: normal
    -- 70-90: +10% stats
    -- 90+: +20% stats
    
    if self.reputation < 30 then
        return 0.8
    elseif self.reputation < 50 then
        return 0.9
    elseif self.reputation < 70 then
        return 1.0
    elseif self.reputation < 90 then
        return 1.1
    else
        return 1.2
    end
end

---Get funding multiplier
---@return number Funding multiplier (0.5 to 1.5)
function ReputationSystem:getFundingMultiplier()
    -- Poor reputation reduces funding
    -- Good reputation increases funding
    
    local modifier = 0.75 + (self.reputation / 100) * 0.75
    return math.max(0.5, math.min(1.5, modifier))
end

---Check if special missions are available
---@return boolean True if available
function ReputationSystem:canAccessSpecialMissions()
    return self.reputation >= self.effectThresholds.specialMissions
end

---Check if recruit quality is improved
---@return boolean True if improved recruits available
function ReputationSystem:canGetBetterRecruits()
    return self.reputation >= self.effectThresholds.recruitsUnlock
end

---Check if item is restricted
---@param itemId string Item identifier
---@param itemRepRequired number Reputation required for item
---@return boolean True if player can purchase
function ReputationSystem:canPurchaseItem(itemId, itemRepRequired)
    if not itemRepRequired then
        return true  -- No restriction
    end
    return self.reputation >= itemRepRequired
end

---Get reputation description for UI
---@return string Formatted description
function ReputationSystem:getDescription()
    local level = self:getLevel(self.reputation)
    local marketMod = string.format("%.0f%%", (1.0 - self:getMarketplaceModifier()) * -100)
    local recruitMod = string.format("%.0f%%", (self:getRecruitQualityModifier() - 1.0) * 100)
    
    return string.format("%s (%d) | Prices: %s | Recruits: %+s%%",
                         level, math.floor(self.reputation), marketMod, recruitMod)
end

---Get breakdown of reputation components
---@return table Components {fame, karma, countries, suppliers}
function ReputationSystem:getComponentBreakdown()
    self:calculateReputation()  -- Update first
    
    if #self.history == 0 then
        return {
            fame = 50,
            karma = 50,
            countries = 50,
            suppliers = 50,
            total = 50
        }
    end
    
    local latest = self.history[1]
    return {
        fame = latest.fame,
        karma = latest.karma,
        countries = latest.countries,
        suppliers = latest.suppliers,
        total = latest.reputation
    }
end

---Get history
---@param maxEntries number Maximum entries (default 12)
---@return table Array of historical reputation values
function ReputationSystem:getHistory(maxEntries)
    maxEntries = maxEntries or 12
    local result = {}
    
    for i = 1, math.min(maxEntries, #self.history) do
        table.insert(result, self.history[i])
    end
    
    return result
end

---Get status summary
---@return table Complete status
function ReputationSystem:getStatus()
    self:calculateReputation()
    
    return {
        reputation = math.floor(self.reputation),
        level = self:getLevel(self.reputation),
        color = self:getReputationColor(),
        marketplace = self:getMarketplaceModifier(),
        recruits = self:getRecruitQualityModifier(),
        funding = self:getFundingMultiplier(),
        specialMissions = self:canAccessSpecialMissions(),
        betterRecruits = self:canGetBetterRecruits(),
        description = self:getDescription(),
        components = self:getComponentBreakdown()
    }
end

---Serialize for save/load
---@return table Serialized state
function ReputationSystem:serialize()
    return {
        reputation = self.reputation,
        history = self.history
    }
end

---Deserialize from save/load
---@param data table Serialized state
function ReputationSystem:deserialize(data)
    if not data then return end
    
    self.reputation = data.reputation or 50
    self.history = data.history or {}
    
    print(string.format("[ReputationSystem] Deserialized: reputation=%d, level=%s",
          math.floor(self.reputation), self:getLevel(self.reputation)))
end

return ReputationSystem




