---Relations Manager System
---
---Tracks player relationships with countries, suppliers, and factions. Relations
---affect funding, marketplace prices, mission generation, and difficulty scaling.
---Provides central coordination for all relation-based game mechanics.
---
---Relation Values:
---  - Range: -100 (war) to +100 (allied)
---  - Thresholds: Allied (75+), Friendly (50-74), Positive (25-49),
---               Neutral (-24-24), Negative (-49--25), Hostile (-74--50), War (-100--75)
---
---Integration Points:
---  - Countries: Affects funding levels
---  - Suppliers: Affects marketplace prices and availability
---  - Factions: Affects mission generation and difficulty
---
---Key Exports:
---  - RelationsManager.new(): Create new manager
---  - getRelation(entityType, entityId): Get current relation
---  - setRelation(entityType, entityId, value): Set exact relation
---  - modifyRelation(entityType, entityId, delta, reason): Modify relation
---  - getRelationLabel(value): Get descriptive label
---  - getRelationColor(value): Get UI color for relation
---  - updateAllRelations(daysPassed): Time-based decay/growth
---
---Relations History:
---  - Tracks recent changes for UI display and debugging
---  - Maintains reason for each change (mission, purchase, diplomacy, event)
---  - Calculates trend (improving/declining/stable)
---
---Persistence:
---  - serialize(): Save relations to disk
---  - deserialize(data): Load relations from disk
---
---@module geoscape.systems.relations_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local RelationsManager = require("geoscape.systems.relations_manager")
---  local manager = RelationsManager.new()
---  manager:modifyRelation("country", "usa", 5, "Mission success")
---  print(manager:getRelationLabel(75))  -- "Allied"
---
---@see economy.marketplace.marketplace_system For supplier integration
---@see geoscape.mission_manager For faction mission generation
---@see geoscape.systems.funding_manager For country funding

local RelationsManager = {}
RelationsManager.__index = RelationsManager

---@class RelationThreshold
---@field min number Minimum relation value
---@field max number Maximum relation value
---@field label string Descriptive label
---@field color table RGB color {r, g, b}

---@class RelationEntry
---@field value number Current relation (-100 to +100)
---@field history table Recent changes {reason, delta, timestamp}
---@field trend string Trend: "improving", "declining", "stable"

--- Create new relations manager
---@return table New manager instance
function RelationsManager.new()
    local self = setmetatable({}, RelationsManager)
    
    -- Core relation storage
    self.countryRelations = {}      -- [countryId] = {value, history, trend}
    self.supplierRelations = {}     -- [supplierId] = {value, history, trend}
    self.factionRelations = {}      -- [factionId] = {value, history, trend}
    
    -- Relation thresholds with colors
    self.thresholds = {
        {min = 75,  max = 100,  label = "Allied",    color = {0, 200, 0}},
        {min = 50,  max = 74,   label = "Friendly",  color = {0, 150, 0}},
        {min = 25,  max = 49,   label = "Positive",  color = {0, 100, 0}},
        {min = -24, max = 24,   label = "Neutral",   color = {150, 150, 150}},
        {min = -49, max = -25,  label = "Negative",  color = {200, 100, 0}},
        {min = -74, max = -50,  label = "Hostile",   color = {200, 50, 0}},
        {min = -100, max = -75, label = "War",       color = {255, 0, 0}}
    }
    
    -- Configuration
    self.config = {
        maxRelation = 100,
        minRelation = -100,
        maxHistorySize = 20,        -- Keep last 20 changes
        decayRate = 0.01,           -- Decay per day (-1 relation per 100 days)
        growthRate = 0.005,         -- Growth for positive relations (half decay)
        eventMaxDelta = 5,          -- Max change per random event
    }
    
    print("[RelationsManager] Initialized relations system")
    
    return self
end

---Initialize with default entities
---@param countries table Array of country IDs
---@param suppliers table Array of supplier IDs
---@param factions table Array of faction IDs
function RelationsManager:initializeEntities(countries, suppliers, factions)
    print("[RelationsManager] Initializing " .. (#countries or 0) .. " countries, " ..
          (#suppliers or 0) .. " suppliers, " .. (#factions or 0) .. " factions")
    
    -- Initialize countries (start at neutral)
    if countries then
        for _, countryId in ipairs(countries) do
            self.countryRelations[countryId] = {
                value = 0,
                history = {},
                trend = "stable"
            }
        end
    end
    
    -- Initialize suppliers (some start negative, some positive)
    if suppliers then
        for _, supplierId in ipairs(suppliers) do
            -- Default to slightly positive for suppliers
            self.supplierRelations[supplierId] = {
                value = 10,
                history = {},
                trend = "stable"
            }
        end
    end
    
    -- Initialize factions (start at neutral to negative)
    if factions then
        for _, factionId in ipairs(factions) do
            self.factionRelations[factionId] = {
                value = -20,  -- Factions start as enemies
                history = {},
                trend = "stable"
            }
        end
    end
end

---Get current relation value
---@param entityType string "country" | "supplier" | "faction"
---@param entityId string Entity identifier
---@return number|nil Relation value (-100 to +100), or nil if not found
function RelationsManager:getRelation(entityType, entityId)
    local relations = self:getRelationTable(entityType)
    if not relations or not relations[entityId] then
        return nil
    end
    return relations[entityId].value
end

---Set relation to exact value
---@param entityType string "country" | "supplier" | "faction"
---@param entityId string Entity identifier
---@param value number Target relation (-100 to +100)
---@param reason string|nil Reason for change (for logging)
function RelationsManager:setRelation(entityType, entityId, value, reason)
    local relations = self:getRelationTable(entityType)
    if not relations[entityId] then
        relations[entityId] = {value = 0, history = {}, trend = "stable"}
    end
    
    value = math.max(self.config.minRelation, math.min(self.config.maxRelation, value))
    
    local oldValue = relations[entityId].value
    local delta = value - oldValue
    
    relations[entityId].value = value
    
    -- Record in history
    self:recordChange(entityType, entityId, delta, reason or "Direct set")
    
    -- Update trend
    self:updateTrend(entityType, entityId)
    
    print(string.format("[RelationsManager] %s '%s' set to %d (was %d): %s",
          entityType, entityId, value, oldValue, reason or "Direct set"))
end

---Modify relation by delta
---@param entityType string "country" | "supplier" | "faction"
---@param entityId string Entity identifier
---@param delta number Change amount
---@param reason string|nil Reason for change (for logging)
---@return number New relation value
function RelationsManager:modifyRelation(entityType, entityId, delta, reason)
    local relations = self:getRelationTable(entityType)
    if not relations[entityId] then
        relations[entityId] = {value = 0, history = {}, trend = "stable"}
    end
    
    -- Clamp delta to valid range
    local oldValue = relations[entityId].value
    local newValue = math.max(self.config.minRelation, 
                              math.min(self.config.maxRelation, oldValue + delta))
    
    relations[entityId].value = newValue
    
    -- Record in history
    self:recordChange(entityType, entityId, newValue - oldValue, reason or "Modification")
    
    -- Update trend
    self:updateTrend(entityType, entityId)
    
    print(string.format("[RelationsManager] %s '%s' modified: %d %c %d = %d (%s)",
          entityType, entityId, oldValue, delta >= 0 and '+' or ' ', delta, newValue, reason or ""))
    
    return newValue
end

---Record relation change in history
---@param entityType string Entity type
---@param entityId string Entity ID
---@param delta number Change amount
---@param reason string Reason for change
function RelationsManager:recordChange(entityType, entityId, delta, reason)
    local relations = self:getRelationTable(entityType)
    if not relations[entityId] then
        return
    end
    
    local history = relations[entityId].history
    
    -- Add new entry
    table.insert(history, 1, {
        delta = delta,
        reason = reason,
        timestamp = os.time()
    })
    
    -- Keep only recent history
    if #history > self.config.maxHistorySize then
        table.remove(history, self.config.maxHistorySize + 1)
    end
end

---Update trend (improving/declining/stable)
---@param entityType string Entity type
---@param entityId string Entity ID
function RelationsManager:updateTrend(entityType, entityId)
    local relations = self:getRelationTable(entityType)
    if not relations[entityId] or #relations[entityId].history == 0 then
        relations[entityId].trend = "stable"
        return
    end
    
    -- Calculate average delta from recent changes
    local recentChanges = math.min(5, #relations[entityId].history)
    local totalDelta = 0
    
    for i = 1, recentChanges do
        totalDelta = totalDelta + relations[entityId].history[i].delta
    end
    
    local avgDelta = totalDelta / recentChanges
    
    if avgDelta > 0.5 then
        relations[entityId].trend = "improving"
    elseif avgDelta < -0.5 then
        relations[entityId].trend = "declining"
    else
        relations[entityId].trend = "stable"
    end
end

---Get descriptive label for relation value
---@param value number Relation value
---@return string Descriptive label
function RelationsManager:getRelationLabel(value)
    for _, threshold in ipairs(self.thresholds) do
        if value >= threshold.min and value <= threshold.max then
            return threshold.label
        end
    end
    return "Unknown"
end

---Get color for relation value (for UI)
---@param value number Relation value
---@return table RGB color {r, g, b}
function RelationsManager:getRelationColor(value)
    for _, threshold in ipairs(self.thresholds) do
        if value >= threshold.min and value <= threshold.max then
            return threshold.color
        end
    end
    return {255, 255, 255}  -- White default
end

---Process daily updates (decay/growth)
---@param daysPassed number Days since last update
function RelationsManager:updateAllRelations(daysPassed)
    daysPassed = daysPassed or 1
    
    -- Update countries
    for countryId, entry in pairs(self.countryRelations) do
        self:applyTimeDecayGrowth(entry, daysPassed)
    end
    
    -- Update suppliers
    for supplierId, entry in pairs(self.supplierRelations) do
        self:applyTimeDecayGrowth(entry, daysPassed)
    end
    
    -- Update factions
    for factionId, entry in pairs(self.factionRelations) do
        self:applyTimeDecayGrowth(entry, daysPassed)
    end
    
    if daysPassed > 0 then
        print(string.format("[RelationsManager] Updated all relations after %d day(s)", daysPassed))
    end
end

---Apply time-based decay/growth to relation
---@param entry table Relation entry
---@param daysPassed number Days since last update
function RelationsManager:applyTimeDecayGrowth(entry, daysPassed)
    local delta = 0
    
    -- Positive relations decay (but more slowly)
    if entry.value > 0 then
        delta = -math.ceil(entry.value * self.config.decayRate * daysPassed / 100)
    
    -- Negative relations decay towards neutral (improve over time)
    elseif entry.value < 0 then
        delta = math.ceil(-entry.value * self.config.decayRate * daysPassed / 100)
    end
    
    if delta ~= 0 then
        entry.value = math.max(self.config.minRelation,
                               math.min(self.config.maxRelation, entry.value + delta))
    end
end

---Get all relations for an entity type
---@param entityType string "country" | "supplier" | "faction"
---@return table Relations table
function RelationsManager:getRelationTable(entityType)
    if entityType == "country" then
        return self.countryRelations
    elseif entityType == "supplier" then
        return self.supplierRelations
    elseif entityType == "faction" then
        return self.factionRelations
    else
        error("[RelationsManager] Invalid entity type: " .. entityType)
    end
end

---Get all relations of a type with details
---@param entityType string "country" | "supplier" | "faction"
---@return table Array of {id, value, label, color, trend}
function RelationsManager:getAllRelations(entityType)
    local relations = self:getRelationTable(entityType)
    local result = {}
    
    for entityId, entry in pairs(relations) do
        table.insert(result, {
            id = entityId,
            value = entry.value,
            label = self:getRelationLabel(entry.value),
            color = self:getRelationColor(entry.value),
            trend = entry.trend,
            history = entry.history
        })
    end
    
    return result
end

---Get recent history for an entity
---@param entityType string Entity type
---@param entityId string Entity ID
---@param maxEntries number Maximum history entries (default 10)
---@return table Array of {delta, reason, timestamp}
function RelationsManager:getHistory(entityType, entityId, maxEntries)
    maxEntries = maxEntries or 10
    
    local relations = self:getRelationTable(entityType)
    if not relations[entityId] then
        return {}
    end
    
    local history = {}
    for i = 1, math.min(maxEntries, #relations[entityId].history) do
        table.insert(history, relations[entityId].history[i])
    end
    
    return history
end

---Get status summary
---@return table Status including all relations and trends
function RelationsManager:getStatus()
    return {
        countries = self:getAllRelations("country"),
        suppliers = self:getAllRelations("supplier"),
        factions = self:getAllRelations("faction"),
        timestamp = os.time()
    }
end

---Serialize relations for save/load
---@return table Serialized state
function RelationsManager:serialize()
    print("[RelationsManager] Serializing relations...")
    
    return {
        countryRelations = self.countryRelations,
        supplierRelations = self.supplierRelations,
        factionRelations = self.factionRelations,
        lastUpdate = os.time()
    }
end

---Deserialize relations from save/load
---@param data table Serialized state
function RelationsManager:deserialize(data)
    if not data then
        print("[RelationsManager] No data to deserialize")
        return
    end
    
    self.countryRelations = data.countryRelations or {}
    self.supplierRelations = data.supplierRelations or {}
    self.factionRelations = data.factionRelations or {}
    
    print("[RelationsManager] Deserialized " ..
          (data.countryRelations and 1 or 0) .. " countries, " ..
          (data.supplierRelations and 1 or 0) .. " suppliers, " ..
          (data.factionRelations and 1 or 0) .. " factions")
end

---Get statistics about relations
---@return table Statistics: {averageCountry, averageSupplier, averageFaction, etc}
function RelationsManager:getStatistics()
    local function calculateAverage(table)
        local sum = 0
        local count = 0
        for _, entry in pairs(table) do
            if entry.value then
                sum = sum + entry.value
                count = count + 1
            end
        end
        return count > 0 and sum / count or 0
    end
    
    return {
        averageCountry = calculateAverage(self.countryRelations),
        averageSupplier = calculateAverage(self.supplierRelations),
        averageFaction = calculateAverage(self.factionRelations),
        countryCount = self:countEntities(self.countryRelations),
        supplierCount = self:countEntities(self.supplierRelations),
        factionCount = self:countEntities(self.factionRelations)
    }
end

---Count entities in a relation table
---@param table table Relation table
---@return number Count
function RelationsManager:countEntities(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

return RelationsManager




