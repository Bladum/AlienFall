--- Diplomatic Relations System - Country relationships and funding
---
--- Manages relationships with funding countries, diplomatic events,
--- and funding modifiers. Tracks country satisfaction, funding levels,
--- and consequences of player actions.
---
--- Relationship Range: -100 (War) to +100 (Allied)
--- Funding Categories: Government grants, per-country bonuses
--- Events: Relations changes, funding changes, diplomatic incidents
---
--- Usage:
---   local DiplomaticManager = require("engine.politics.diplomatic_manager")
---   local manager = DiplomaticManager:new()
---   manager:addCountry({id = "usa", name = "USA", funding = 50000})
---   manager:modifyRelations("usa", 10)
---   local funding = manager:calculateMonthlyFunding()
---
--- @module engine.politics.diplomatic_manager
--- @author AlienFall Development Team

local DiplomaticManager = {}
DiplomaticManager.__index = DiplomaticManager

-- Relationship tiers
local RELATIONSHIP_TIERS = {
    hostile = {min = -100, max = -50, multiplier = 0.0},
    hostile_careful = {min = -50, max = -25, multiplier = 0.25},
    tense = {min = -25, max = 0, multiplier = 0.5},
    neutral = {min = 0, max = 25, multiplier = 0.75},
    friendly = {min = 25, max = 50, multiplier = 1.0},
    allied = {min = 50, max = 100, multiplier = 1.5}
}

--- Initialize Diplomatic Manager
---@return table DiplomaticManager instance
function DiplomaticManager:new()
    local self = setmetatable({}, DiplomaticManager)
    
    self.countries = {}  -- {id = Country}
    self.relations = {}  -- {countryId = relationValue}
    self.funding = {}  -- {countryId = monthlyFunding}
    self.incidents = {}  -- Diplomatic incidents history
    self.diplomaticEvents = {}  -- {eventName = {callback, ...}}
    
    self.monthlyIncome = 0
    self.totalFunding = 0
    
    print("[DiplomaticManager] Initialized")
    
    return self
end

--- Add country to diplomatic network
---@param countryData table Country data
---@return boolean Success
function DiplomaticManager:addCountry(countryData)
    local country = {
        id = countryData.id or error("Country requires id"),
        name = countryData.name or "Unknown",
        baseRelations = countryData.baseRelations or 0,
        baseFunding = countryData.baseFunding or 0,
        region = countryData.region,
        
        -- Tracking
        satisfaction = 50,
        missionsCompleted = 0,
        incidentsCount = 0,
        relationshipHistory = {}
    }
    
    self.countries[country.id] = country
    self.relations[country.id] = country.baseRelations
    self.funding[country.id] = country.baseFunding
    
    print(string.format("[DiplomaticManager] Added country: %s | Base funding: $%d",
        country.name, country.baseFunding))
    
    return true
end

--- Get country
---@param countryId string Country ID
---@return table? Country or nil
function DiplomaticManager:getCountry(countryId)
    return self.countries[countryId]
end

--- Get all countries
---@return table List of countries
function DiplomaticManager:getAllCountries()
    local all = {}
    for _, country in pairs(self.countries) do
        table.insert(all, country)
    end
    return all
end

--- Modify relations with country
---@param countryId string Country ID
---@param delta number Change amount (-100 to +100)
---@param reason string? Reason for change
---@return boolean Success
function DiplomaticManager:modifyRelations(countryId, delta, reason)
    local country = self:getCountry(countryId)
    if not country then
        return false
    end
    
    local oldRelations = self.relations[countryId]
    self.relations[countryId] = math.max(-100, math.min(100, oldRelations + delta))
    
    local change = self.relations[countryId] - oldRelations
    local newTier = self:getRelationshipTier(self.relations[countryId])
    
    print(string.format("[DiplomaticManager] %s relations: %+d (%.0f -> %.0f) | Tier: %s | %s",
        country.name, change, oldRelations, self.relations[countryId], newTier, reason or ""))
    
    -- Record in history
    table.insert(country.relationshipHistory, {
        date = os.time(),
        delta = change,
        reason = reason,
        newValue = self.relations[countryId]
    })
    
    -- Trigger event if significant change
    if math.abs(change) >= 10 then
        self:triggerEvent("relations_changed", {
            country = countryId,
            oldValue = oldRelations,
            newValue = self.relations[countryId],
            reason = reason
        })
    end
    
    return true
end

--- Get relationship tier name
---@param relationValue number Relationship value
---@return string Tier name
function DiplomaticManager:getRelationshipTier(relationValue)
    if relationValue >= 50 then
        return "allied"
    elseif relationValue >= 25 then
        return "friendly"
    elseif relationValue >= 0 then
        return "neutral"
    elseif relationValue >= -25 then
        return "tense"
    elseif relationValue >= -50 then
        return "hostile_careful"
    else
        return "hostile"
    end
end

--- Get relations with country
---@param countryId string Country ID
---@return number Relations value
function DiplomaticManager:getRelations(countryId)
    return self.relations[countryId] or 0
end

--- Record diplomatic incident
---@param countryId string Country ID
---@param incidentType string Type of incident
---@param severity number Severity (0-100)
---@param description string Description
---@return boolean Success
function DiplomaticManager:recordIncident(countryId, incidentType, severity, description)
    local country = self:getCountry(countryId)
    if not country then
        return false
    end
    
    local incident = {
        date = os.time(),
        type = incidentType,
        severity = severity,
        description = description,
        relationsImpact = -math.ceil(severity / 10)
    }
    
    table.insert(self.incidents, incident)
    country.incidentsCount = country.incidentsCount + 1
    
    -- Modify relations based on severity
    self:modifyRelations(countryId, incident.relationsImpact, 
        "Incident: " .. description)
    
    print(string.format("[DiplomaticManager] Incident recorded: %s (%s) - %s",
        country.name, incidentType, description))
    
    self:triggerEvent("incident_recorded", incident)
    
    return true
end

--- Record mission completion for country
---@param countryId string Country ID
---@param success boolean Mission success
---@param quality number Mission quality (0-100)
---@return boolean Success
function DiplomaticManager:recordMissionCompletion(countryId, success, quality)
    local country = self:getCountry(countryId)
    if not country then
        return false
    end
    
    if success then
        quality = quality or 75
        local relationBonus = math.ceil(quality / 25)  -- +1 to +4 relations
        self:modifyRelations(countryId, relationBonus, "Mission completed successfully")
        country.missionsCompleted = country.missionsCompleted + 1
        country.satisfaction = math.min(100, country.satisfaction + (quality / 100))
    else
        self:modifyRelations(countryId, -5, "Mission failed")
        country.satisfaction = math.max(0, country.satisfaction - 10)
    end
    
    return true
end

--- Calculate funding modifiers for country
---@param countryId string Country ID
---@return number Funding multiplier
function DiplomaticManager:calculateFundingModifier(countryId)
    local relations = self.relations[countryId] or 0
    local tier = self:getRelationshipTier(relations)
    
    -- Get multiplier for this tier
    local tierData = RELATIONSHIP_TIERS[tier]
    return tierData.multiplier
end

--- Update country funding
---@param countryId string Country ID
---@param baseFunding number Base funding amount
---@return number Actual funding
function DiplomaticManager:updateFunding(countryId, baseFunding)
    local country = self:getCountry(countryId)
    if not country then
        return 0
    end
    
    local modifier = self:calculateFundingModifier(countryId)
    local actualFunding = math.floor(baseFunding * modifier)
    
    self.funding[countryId] = actualFunding
    
    return actualFunding
end

--- Calculate monthly funding from all countries
---@return number Total monthly funding
function DiplomaticManager:calculateMonthlyFunding()
    self.monthlyIncome = 0
    
    for countryId, country in pairs(self.countries) do
        local funding = self.funding[countryId] or 0
        self.monthlyIncome = self.monthlyIncome + funding
    end
    
    self.totalFunding = self.totalFunding + self.monthlyIncome
    
    print(string.format("[DiplomaticManager] Monthly funding: $%d | Total earned: $%d",
        self.monthlyIncome, self.totalFunding))
    
    return self.monthlyIncome
end

--- Get funding breakdown by country
---@return table Funding breakdown
function DiplomaticManager:getFundingBreakdown()
    local breakdown = {}
    
    for countryId, country in pairs(self.countries) do
        breakdown[countryId] = {
            name = country.name,
            funding = self.funding[countryId] or 0,
            relations = self.relations[countryId] or 0,
            tier = self:getRelationshipTier(self.relations[countryId] or 0)
        }
    end
    
    return breakdown
end

--- Get country status
---@param countryId string Country ID
---@return table Status
function DiplomaticManager:getCountryStatus(countryId)
    local country = self:getCountry(countryId)
    if not country then
        return {status = "not_found"}
    end
    
    return {
        id = country.id,
        name = country.name,
        relations = self.relations[countryId] or 0,
        tier = self:getRelationshipTier(self.relations[countryId] or 0),
        funding = self.funding[countryId] or 0,
        satisfaction = country.satisfaction,
        missionsCompleted = country.missionsCompleted,
        incidents = country.incidentsCount
    }
end

--- Get diplomatic network status
---@return table Status
function DiplomaticManager:getStatus()
    local countryCount = 0
    local totalFunding = 0
    local avgRelations = 0
    
    for countryId, country in pairs(self.countries) do
        countryCount = countryCount + 1
        totalFunding = totalFunding + (self.funding[countryId] or 0)
        avgRelations = avgRelations + (self.relations[countryId] or 0)
    end
    
    if countryCount > 0 then
        avgRelations = avgRelations / countryCount
    end
    
    return {
        countries = countryCount,
        monthlyFunding = totalFunding,
        avgRelations = avgRelations,
        totalIncidents = #self.incidents,
        status = string.format(
            "Diplomatic Status:\n" ..
            "  Countries: %d\n" ..
            "  Monthly Funding: $%d\n" ..
            "  Average Relations: %.1f\n" ..
            "  Total Incidents: %d",
            countryCount,
            totalFunding,
            avgRelations,
            #self.incidents
        )
    }
end

--- Get relations with all countries
---@return table Relations summary
function DiplomaticManager:getAllRelations()
    local relations = {}
    
    for countryId, country in pairs(self.countries) do
        relations[countryId] = {
            name = country.name,
            value = self.relations[countryId] or 0,
            tier = self:getRelationshipTier(self.relations[countryId] or 0)
        }
    end
    
    return relations
end

--- Register for diplomatic events
---@param eventName string Event name
---@param callback function Callback function
function DiplomaticManager:onDiplomaticEvent(eventName, callback)
    if not self.diplomaticEvents[eventName] then
        self.diplomaticEvents[eventName] = {}
    end
    table.insert(self.diplomaticEvents[eventName], callback)
end

--- Trigger diplomatic event
---@param eventName string Event name
---@param data any Event data
function DiplomaticManager:triggerEvent(eventName, data)
    if self.diplomaticEvents[eventName] then
        for _, callback in ipairs(self.diplomaticEvents[eventName]) do
            callback(data)
        end
    end
end

--- Serialize for save/load
---@return table Serialized data
function DiplomaticManager:serialize()
    return {
        countries = self.countries,
        relations = self.relations,
        funding = self.funding,
        incidents = self.incidents,
        monthlyIncome = self.monthlyIncome,
        totalFunding = self.totalFunding
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function DiplomaticManager:deserialize(data)
    self.countries = data.countries
    self.relations = data.relations
    self.funding = data.funding
    self.incidents = data.incidents
    self.monthlyIncome = data.monthlyIncome
    self.totalFunding = data.totalFunding
    print("[DiplomaticManager] Deserialized from save")
end

return DiplomaticManager



