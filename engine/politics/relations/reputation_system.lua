---Reputation System - Aggregate Standing
---
---Combines fame, karma, and relations into unified reputation score. Provides
---overall standing calculation with entities (countries, factions, suppliers).
---Aggregates multiple reputation factors for comprehensive standing view.
---
---Reputation Calculation:
---  - Base: Fame + Karma combined score
---  - Modified by: Relations with specific entity
---  - Result: Overall standing from -100 (Despised) to +100 (Revered)
---
---Reputation Tiers:
---  - Despised (-100 to -50): Hostile, no cooperation
---  - Disliked (-49 to -20): Negative, limited access
---  - Neutral (-19 to +19): Standard relations
---  - Liked (+20 to +49): Positive, bonus access
---  - Revered (+50 to +100): Maximum cooperation and support
---
---Key Exports:
---  - ReputationSystem.new(fame, karma, relations): Creates reputation tracker
---  - calculateReputation(entityId): Computes overall standing
---  - getReputationTier(score): Returns tier for score
---  - getReputationEffects(entityId): Lists active modifiers
---  - updateReputation(): Recalculates all reputation scores
---
---Dependencies:
---  - politics.fame.fame_system: Fame component
---  - politics.karma.karma_system: Karma component
---  - politics.relations.relations_manager: Relations component
---
---@module politics.relations.reputation_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ReputationSystem = require("politics.relations.reputation_system")
---  local reputation = ReputationSystem.new(fameSystem, karmaSystem, relationsManager)
---  local standing = reputation:calculateReputation("country_usa")
---  print(reputation:getReputationTier(standing))  -- "Liked"
---
---@see politics.fame For fame tracking
---@see politics.karma For karma tracking
---@see politics.relations.relations_manager For relations

local ReputationSystem = {}
ReputationSystem.__index = ReputationSystem

--- Reputation tiers
local REPUTATION_TIERS = {
    {min = -100, max = -50, tier = "Despised",  color = {r=1.0, g=0.0, b=0.0}},
    {min = -49,  max = -20, tier = "Disliked",  color = {r=0.9, g=0.4, b=0.0}},
    {min = -19,  max = 19,  tier = "Neutral",   color = {r=0.7, g=0.7, b=0.7}},
    {min = 20,   max = 49,  tier = "Liked",     color = {r=0.5, g=0.8, b=0.5}},
    {min = 50,   max = 100, tier = "Revered",   color = {r=0.0, g=0.8, b=1.0}},
}

--- Create new reputation system
---@param fameSystem table FameSystem instance
---@param karmaSystem table KarmaSystem instance
function ReputationSystem.new(fameSystem, karmaSystem)
    local self = setmetatable({}, ReputationSystem)
    
    -- Link to other systems
    self.fameSystem = fameSystem
    self.karmaSystem = karmaSystem
    
    -- Weights for reputation calculation
    self.weights = {
        fame = 0.4,    -- 40% from fame
        karma = 0.3,   -- 30% from karma
        relations = 0.3, -- 30% from average relations
    }
    
    print("[ReputationSystem] Initialized")
    return self
end

--- Calculate overall reputation
---@param relationsManager table Optional relations manager (for average relations)
---@return number Reputation (-100 to +100)
function ReputationSystem:calculateReputation(relationsManager)
    -- Fame contribution (0-100 → -100 to +100)
    local fameValue = (self.fameSystem:getFame() - 50) * 2  -- Normalize to -100 to +100
    local fameContrib = fameValue * self.weights.fame
    
    -- Karma contribution (already -100 to +100)
    local karmaContrib = self.karmaSystem:getKarma() * self.weights.karma
    
    -- Relations contribution (if available)
    local relationsContrib = 0
    if relationsManager then
        local avgRelation = relationsManager:getAverageRelation()
        relationsContrib = avgRelation * self.weights.relations
    end
    
    -- Total reputation
    local reputation = fameContrib + karmaContrib + relationsContrib
    
    return math.max(-100, math.min(100, reputation))
end

--- Get reputation tier
---@param reputation number Reputation value
---@return string Tier name
function ReputationSystem:getTier(reputation)
    for _, tier in ipairs(REPUTATION_TIERS) do
        if reputation >= tier.min and reputation <= tier.max then
            return tier.tier
        end
    end
    return "Neutral"
end

--- Get reputation tier data
---@param reputation number Reputation value
---@return table Tier data {min, max, tier, color}
function ReputationSystem:getTierData(reputation)
    for _, tier in ipairs(REPUTATION_TIERS) do
        if reputation >= tier.min and reputation <= tier.max then
            return tier
        end
    end
    return REPUTATION_TIERS[3]  -- Neutral
end

--- Get reputation breakdown
---@param relationsManager table Optional relations manager
---@return table Breakdown {fame, karma, relations, total, tier}
function ReputationSystem:getBreakdown(relationsManager)
    local fameValue = (self.fameSystem:getFame() - 50) * 2
    local fameContrib = fameValue * self.weights.fame
    
    local karmaContrib = self.karmaSystem:getKarma() * self.weights.karma
    
    local relationsContrib = 0
    local avgRelation = 0
    if relationsManager then
        avgRelation = relationsManager:getAverageRelation()
        relationsContrib = avgRelation * self.weights.relations
    end
    
    local total = fameContrib + karmaContrib + relationsContrib
    
    return {
        fame = fameContrib,
        karma = karmaContrib,
        relations = relationsContrib,
        total = total,
        tier = self:getTier(total),
        
        -- Raw values for display
        rawFame = self.fameSystem:getFame(),
        rawKarma = self.karmaSystem:getKarma(),
        rawRelations = avgRelation,
    }
end

--- Get supplier price multiplier based on reputation
---@param relationsManager table Relations manager
---@return number Price multiplier (0.5 to 1.5)
function ReputationSystem:getSupplierPriceMultiplier(relationsManager)
    local reputation = self:calculateReputation(relationsManager)
    
    -- Reputation affects prices: -100 = 150% price, 0 = 100%, +100 = 50% price
    local multiplier = 1.0 - (reputation / 200)  -- Range: 0.5 to 1.5
    
    return math.max(0.5, math.min(1.5, multiplier))
end

--- Get funding multiplier based on reputation
---@param relationsManager table Relations manager
---@return number Funding multiplier (0.5 to 2.0)
function ReputationSystem:getFundingMultiplier(relationsManager)
    local reputation = self:calculateReputation(relationsManager)
    
    -- Higher reputation = more funding
    if reputation >= 50 then
        return 1.0 + (reputation - 50) / 50  -- 1.0 to 2.0
    elseif reputation <= -50 then
        return 0.5 + (reputation + 50) / 100  -- 0.5 to 1.0
    else
        return 1.0
    end
end

--- Print reputation report
---@param relationsManager table Optional relations manager
function ReputationSystem:printReport(relationsManager)
    local breakdown = self:getBreakdown(relationsManager)
    
    print("[ReputationSystem] === REPUTATION REPORT ===")
    print(string.format("  Fame:      %.0f (contributes %.1f)", breakdown.rawFame, breakdown.fame))
    print(string.format("  Karma:     %.0f (contributes %.1f)", breakdown.rawKarma, breakdown.karma))
    print(string.format("  Relations: %.0f (contributes %.1f)", breakdown.rawRelations, breakdown.relations))
    print(string.format("  TOTAL:     %.1f (%s)", breakdown.total, breakdown.tier))
    print("=======================================")
end

return ReputationSystem


























