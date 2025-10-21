---Relations Manager - Entity Relationship Tracking
---
---Tracks relationships with countries, suppliers, and factions on a scale from
----100 (War) to +100 (Allied). Relations affect funding, equipment prices,
---item availability, mission generation, and political support.
---
---Relation Levels:
---  - Allied (+75 to +100): Maximum cooperation, best prices
---  - Friendly (+50 to +74): Strong support, good prices
---  - Positive (+25 to +49): Cooperative, standard prices
---  - Neutral (-24 to +24): No special treatment
---  - Negative (-49 to -25): Suspicious, price penalties
---  - Hostile (-74 to -50): Limited cooperation, poor prices
---  - War (-100 to -75): Active conflict, no trade
---
---Relation Sources:
---  - Mission outcomes (success/failure in country territory)
---  - Civilian casualties (major negative impact)
---  - UFO prevention (positive for affected countries)
---  - Trade volume (repeated purchases improve supplier relations)
---  - Political actions (alliances, betrayals)
---
---Relation Effects:
---  - Funding: Countries provide monthly resources based on relations
---  - Prices: Suppliers adjust prices by relation level
---  - Access: Some items require minimum relation level
---  - Missions: Better relations = more mission offers
---
---Key Exports:
---  - RelationsManager.new(): Creates relations tracker
---  - setRelation(entityId, value): Sets relation value
---  - modifyRelation(entityId, delta, reason): Changes relation
---  - getRelation(entityId): Returns current relation value
---  - getRelationLabel(entityId): Returns tier label
---  - getAllRelations(): Returns all tracked relations
---
---Dependencies:
---  - geoscape.geography.province: Country definitions
---  - economy.marketplace: Supplier price adjustments
---  - lore.factions: Faction definitions
---  - lore.missions: Mission generation based on relations
---
---@module politics.relations.relations_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local RelationsManager = require("politics.relations.relations_manager")
---  local relations = RelationsManager.new()
---  relations:setRelation("country_usa", 50)  -- Friendly
---  relations:modifyRelation("supplier_1", 10, "Large purchase")
---  print(relations:getRelationLabel("country_usa"))  -- "Friendly"
---
---@see geoscape.world.world_state For global political state
---@see economy.marketplace For supplier pricing

local RelationsManager = {}
RelationsManager.__index = RelationsManager

--- Relation thresholds with descriptive labels
local RELATION_THRESHOLDS = {
    {min = 75,  max = 100, label = "Allied",   color = {r=0.0, g=0.8, b=0.0}},
    {min = 50,  max = 74,  label = "Friendly", color = {r=0.4, g=0.7, b=0.2}},
    {min = 25,  max = 49,  label = "Positive", color = {r=0.6, g=0.6, b=0.3}},
    {min = -24, max = 24,  label = "Neutral",  color = {r=0.7, g=0.7, b=0.7}},
    {min = -49, max = -25, label = "Negative", color = {r=0.8, g=0.5, b=0.0}},
    {min = -74, max = -50, label = "Hostile",  color = {r=0.9, g=0.3, b=0.0}},
    {min = -100, max = -75, label = "War",     color = {r=1.0, g=0.0, b=0.0}},
}

--- Create new relations manager
function RelationsManager.new()
    local self = setmetatable({}, RelationsManager)
    
    -- Relations storage
    self.relations = {
        country = {},  -- [countryId] = relationValue
        supplier = {}, -- [supplierId] = relationValue
        faction = {},  -- [factionId] = relationValue
    }
    
    -- Relation history (for tracking changes)
    self.history = {}
    
    -- Decay/growth rates (per day)
    self.decayRates = {
        country = 0.1,   -- Countries slowly forget
        supplier = 0.05, -- Suppliers maintain relations
        faction = 0.2,   -- Factions change quickly
    }
    
    print("[RelationsManager] Initialized")
    return self
end

--- Get relation value
---@param entityType string "country", "supplier", or "faction"
---@param entityId string Entity ID
---@return number Relation value (-100 to +100)
function RelationsManager:getRelation(entityType, entityId)
    if not self.relations[entityType] then
        print("[RelationsManager] Invalid entity type: " .. entityType)
        return 0
    end
    
    return self.relations[entityType][entityId] or 0
end

--- Set relation value directly
---@param entityType string Entity type
---@param entityId string Entity ID
---@param value number Relation value (-100 to +100)
function RelationsManager:setRelation(entityType, entityId, value)
    if not self.relations[entityType] then
        print("[RelationsManager] Invalid entity type: " .. entityType)
        return
    end
    
    value = math.max(-100, math.min(100, value))
    self.relations[entityType][entityId] = value
    
    print(string.format("[RelationsManager] %s/%s set to %.0f (%s)", 
          entityType, entityId, value, self:getRelationLabel(value)))
end

--- Modify relation value
---@param entityType string Entity type
---@param entityId string Entity ID
---@param delta number Relation change
---@param reason string Reason for change
function RelationsManager:modifyRelation(entityType, entityId, delta, reason)
    local oldValue = self:getRelation(entityType, entityId)
    local oldLabel = self:getRelationLabel(oldValue)
    
    local newValue = math.max(-100, math.min(100, oldValue + delta))
    self.relations[entityType][entityId] = newValue
    
    local newLabel = self:getRelationLabel(newValue)
    
    -- Record history
    table.insert(self.history, {
        entityType = entityType,
        entityId = entityId,
        delta = delta,
        reason = reason,
        oldValue = oldValue,
        newValue = newValue,
        timestamp = os.time(),
    })
    
    print(string.format("[RelationsManager] %s/%s %+.0f: %s (%.0f → %.0f, %s → %s)", 
          entityType, entityId, delta, reason, oldValue, newValue, oldLabel, newLabel))
end

--- Get relation label
---@param value number Relation value
---@return string Label
function RelationsManager:getRelationLabel(value)
    for _, threshold in ipairs(RELATION_THRESHOLDS) do
        if value >= threshold.min and value <= threshold.max then
            return threshold.label
        end
    end
    return "Neutral"
end

--- Get relation threshold data
---@param value number Relation value
---@return table Threshold data {min, max, label, color}
function RelationsManager:getRelationThreshold(value)
    for _, threshold in ipairs(RELATION_THRESHOLDS) do
        if value >= threshold.min and value <= threshold.max then
            return threshold
        end
    end
    return RELATION_THRESHOLDS[4]  -- Neutral
end

--- Get all relations for entity type
---@param entityType string Entity type
---@return table Relations {[entityId] = value}
function RelationsManager:getAllRelations(entityType)
    return self.relations[entityType] or {}
end

--- Get average relation across all entities
---@return number Average relation
function RelationsManager:getAverageRelation()
    local total = 0
    local count = 0
    
    for _, entityRelations in pairs(self.relations) do
        for _, value in pairs(entityRelations) do
            total = total + value
            count = count + 1
        end
    end
    
    if count == 0 then return 0 end
    return total / count
end

--- Apply time-based decay/growth
---@param daysPassed number Days elapsed
function RelationsManager:applyTimeDecay(daysPassed)
    for entityType, entityRelations in pairs(self.relations) do
        local decayRate = self.decayRates[entityType] or 0.1
        
        for entityId, value in pairs(entityRelations) do
            -- Relations decay toward neutral (0)
            if value > 0 then
                -- Positive relations decay
                local decay = decayRate * daysPassed
                entityRelations[entityId] = math.max(0, value - decay)
            elseif value < 0 then
                -- Negative relations also decay toward neutral
                local decay = decayRate * daysPassed
                entityRelations[entityId] = math.min(0, value + decay)
            end
        end
    end
end

--- Get funding modifier from relation
---@param relationValue number Relation value
---@return number Funding multiplier (0 to 2.0)
function RelationsManager:getFundingModifier(relationValue)
    if relationValue >= 75 then
        -- Allied: +50% to +100%
        return 0.5 + (relationValue - 75) / 50
    elseif relationValue >= 50 then
        -- Friendly: +25% to +50%
        return 0.25 + (relationValue - 50) / 48
    elseif relationValue >= 25 then
        -- Positive: +10% to +25%
        return 0.1 + (relationValue - 25) / 60
    elseif relationValue >= -24 then
        -- Neutral: 0%
        return 0.0
    elseif relationValue >= -49 then
        -- Negative: -10% to -25%
        return -0.1 - (math.abs(relationValue + 24) / 100)
    elseif relationValue >= -74 then
        -- Hostile: -25% to -50%
        return -0.25 - (math.abs(relationValue + 49) / 100)
    else
        -- War: -50% to -75%
        return -0.5 - (math.abs(relationValue + 74) / 104)
    end
end

--- Get price modifier from relation
---@param relationValue number Relation value
---@return number Price multiplier (0.5 to 2.0)
function RelationsManager:getPriceModifier(relationValue)
    if relationValue >= 75 then
        -- Allied: -30% to -50% discount
        return 0.5 + (100 - relationValue) / 100
    elseif relationValue >= 50 then
        -- Friendly: -15% to -30%
        return 0.7 + (75 - relationValue) / 100
    elseif relationValue >= 25 then
        -- Positive: -5% to -15%
        return 0.85 + (50 - relationValue) / 100
    elseif relationValue >= -24 then
        -- Neutral: 0%
        return 1.0
    elseif relationValue >= -49 then
        -- Negative: +10% to +25%
        return 1.1 + (math.abs(relationValue) / 200)
    elseif relationValue >= -74 then
        -- Hostile: +25% to +50%
        return 1.25 + (math.abs(relationValue + 49) / 100)
    else
        -- War: +50% to +100%
        return 1.5 + (math.abs(relationValue + 74) / 52)
    end
end

--- Get recent relation changes
---@param count number Number of recent entries (default 20)
---@return table Array of history entries
function RelationsManager:getRecentHistory(count)
    count = count or 20
    local start = math.max(1, #self.history - count + 1)
    local recent = {}
    
    for i = start, #self.history do
        table.insert(recent, self.history[i])
    end
    
    return recent
end

--- Save state
---@return table State
function RelationsManager:saveState()
    return {
        relations = self.relations,
        history = self.history,
    }
end

--- Load state
---@param state table Saved state
function RelationsManager:loadState(state)
    self.relations = state.relations or {country = {}, supplier = {}, faction = {}}
    self.history = state.history or {}
    
    print("[RelationsManager] State loaded")
end

--- Print relations report
function RelationsManager:printReport()
    print("[RelationsManager] === RELATIONS REPORT ===")
    
    for entityType, entityRelations in pairs(self.relations) do
        print("  " .. entityType:upper() .. ":")
        for entityId, value in pairs(entityRelations) do
            local label = self:getRelationLabel(value)
            print(string.format("    %s: %.0f (%s)", entityId, value, label))
        end
    end
    
    local avg = self:getAverageRelation()
    print(string.format("  AVERAGE: %.1f (%s)", avg, self:getRelationLabel(avg)))
    print("=========================================")
end

return RelationsManager

























