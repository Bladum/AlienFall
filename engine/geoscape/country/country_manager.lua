---Country Manager System
---
---Manages all country definitions, state, and diplomatic relationships. Countries are the primary
---diplomatic and economic stakeholders in the game. Each country has properties, dynamic
---state (panic, funding, relations), and integration with missions and economy.
---
---Key Responsibilities:
---  - Load and manage country definitions from TOML
---  - Track country state (panic, funding levels, stability, morale)
---  - Manage diplomatic relations with history and trends
---  - Calculate monthly funding based on GDP, funding level, and relations
---  - Generate country-specific missions
---  - Handle panic accumulation and country collapse
---  - Integrate with RelationsManager, MissionManager, and EconomyManager
---
---Country Types:
---  - MAJOR: 5-8 countries with high influence (+30 relation start, 40% more missions)
---  - SECONDARY: 8-12 countries with moderate influence (standard)
---  - MINOR: 10-15 countries with low influence (easier relationship building)
---  - SUPRANATIONAL: 2-3 political organizations (diplomatic missions)
---
---Relations System:
---  - Range: -100 (war) to +100 (allied)
---  - Thresholds: Allied (75+), Friendly (50-74), Positive (25-49),
---               Neutral (-24-24), Negative (-49--25), Hostile (-74--50), War (-100--75)
---  - History tracking with trends (improving/declining/stable)
---  - Time-based decay and growth
---
---Key Exports:
---  - CountryManager.new(): Create new manager
---  - init(countries): Initialize from TOML definitions
---  - getCountry(id): Get country by ID
---  - getRelation(countryId): Get diplomatic relation
---  - modifyRelation(countryId, delta, reason): Change diplomatic relation
---  - calculateFunding(id): Calculate monthly income
---  - getTotalFunding(): Get total from all countries
---  - modifyPanic(id, delta, reason): Update panic level
---  - updateDailyState(days): Process daily updates
---
---Integration Points:
---  - MissionManager: Country-specific mission generation
---  - EconomyManager: Monthly funding application
---  - GeoScape: Country display and status information
---
---@module geoscape.country.country_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CountryManager = require("geoscape.country.country_manager")
---  local manager = CountryManager.new()
---  manager:init(countryDefinitions)
---  manager:modifyRelation("usa", 5, "Mission success")
---  manager:modifyPanic("usa", 12, "Terror mission completed")
---  local funding = manager:calculateFunding("usa")
---
---@see geoscape.mission_manager For mission generation
---@see economy.economy_manager For funding integration

local CountryManager = {}
CountryManager.__index = CountryManager

---@class RelationThreshold
---@field min number Minimum relation value
---@field max number Maximum relation value
---@field label string Descriptive label
---@field color table RGB color {r, g, b}

---@class RelationEntry
---@field value number Current relation (-100 to +100)
---@field history table Recent changes {reason, delta, timestamp}
---@field trend string Trend: "improving", "declining", "stable"

---Create new country manager instance
---@return table New manager instance
function CountryManager.new()
    local self = setmetatable({}, CountryManager)

    -- Country storage
    self.countries = {}              -- [countryId] = country state
    self.countryDefinitions = {}     -- [countryId] = definition from TOML
    self.countryIds = {}             -- Array of all country IDs (for ordering)

    -- Indexes for fast lookup
    self.countriesByType = {}        -- [MAJOR/SECONDARY/MINOR] = array of IDs
    self.countriesByRegion = {}      -- [regionId] = array of IDs

    -- Relations system (integrated from RelationsManager)
    self.relations = {}              -- [countryId] = {value, history, trend}

    -- Relation thresholds with colors
    self.relationThresholds = {
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
        minFundingLevel = 1,
        maxFundingLevel = 10,
        minPanic = 0,
        maxPanic = 100,
        panicCollapseThreshold = 100,
        panicDecayPerDay = 1,
        relationModifierRange = 0.5,  -- 0.5 to 1.0 based on relation
        maxRelation = 100,
        minRelation = -100,
        maxHistorySize = 20,        -- Keep last 20 changes
        decayRate = 0.01,           -- Decay per day (-1 relation per 100 days)
        growthRate = 0.005,         -- Growth for positive relations (half decay)
    }

    print("[CountryManager] Initialized country manager with integrated relations")

    return self
end

---Initialize manager with country definitions from TOML
---@param countries_data table Array of country definitions
---@return boolean success
---@return string|nil error_message
function CountryManager:init(countries_data)
    if not countries_data then
        return false, "[CountryManager] No country data provided"
    end

    -- Clear existing data
    self.countries = {}
    self.countryDefinitions = {}
    self.countryIds = {}
    self.countriesByType = {}
    self.countriesByRegion = {}

    local loaded_count = 0

    -- Load country definitions
    for _, countryDef in ipairs(countries_data) do
        if countryDef and countryDef.id and countryDef.name then
            local countryId = countryDef.id

            -- Store definition
            self.countryDefinitions[countryId] = countryDef
            table.insert(self.countryIds, countryId)

            -- Create runtime state
            self.countries[countryId] = self:createCountryState(countryDef)

            -- Index by type
            local nationType = countryDef.nation_type or "SECONDARY"
            if not self.countriesByType[nationType] then
                self.countriesByType[nationType] = {}
            end
            table.insert(self.countriesByType[nationType], countryId)

            -- Index by region
            local region = countryDef.region or "unknown"
            if not self.countriesByRegion[region] then
                self.countriesByRegion[region] = {}
            end
            table.insert(self.countriesByRegion[region], countryId)

            loaded_count = loaded_count + 1
        end
    end

    print(string.format("[CountryManager] Loaded %d countries", loaded_count))

    -- Integrate with RelationsManager if available
    self:integrateWithRelationsManager()

    return true, nil
end

---Create initial country state from definition
---@param def table Country definition from TOML
---@return table Country state object
function CountryManager:createCountryState(def)
    local state = {
        -- Identity
        id = def.id,
        name = def.name,
        nation_type = def.nation_type or "SECONDARY",
        region = def.region or "unknown",

        -- Economy
        gdp = def.gdp or 10,
        military_power = def.military_power or 5,
        base_funding_level = def.base_funding_level or 5,
        funding_volatility = def.funding_volatility or 0.5,

        -- Dynamic state
        relation = def.starting_relation or 0,
        panic = 0,
        funding_level = def.base_funding_level or 5,
        stability = 75,
        military_readiness = 75,
        morale = 75,

        -- History
        last_mission_date = 0,
        missions_completed = 0,
        missions_failed = 0,
        ufos_defeated = 0,
        bases_raided = 0,

        -- Status
        is_collapsed = false,
        is_at_war = false,
        active_crises = {},
        panic_threshold = def.panic_threshold or 100,

        -- Territories
        territories = def.territories or {},
        capital_province = def.capital_province or "",

        -- Definition reference
        definition = def
    }

    -- Initialize relations entry
    self.relations[def.id] = {
        value = def.starting_relation or 0,
        history = {},
        trend = "stable"
    }

    return state
end

---Get country by ID
---@param country_id string Country identifier
---@return table|nil Country state or nil if not found
function CountryManager:getCountry(country_id)
    return self.countries[country_id]
end

---Get all countries
---@return table Array of country state objects
function CountryManager:getAllCountries()
    local result = {}
    for _, countryId in ipairs(self.countryIds) do
        table.insert(result, self.countries[countryId])
    end
    return result
end

---Get countries by type
---@param nation_type string MAJOR, SECONDARY, MINOR, or SUPRANATIONAL
---@return table Array of country IDs
function CountryManager:getCountriesByType(nation_type)
    return self.countriesByType[nation_type] or {}
end

---Get countries by region
---@param region_id string Region identifier
---@return table Array of country IDs
function CountryManager:getCountriesByRegion(region_id)
    return self.countriesByRegion[region_id] or {}
end

---Get countries in a relation range
---@param min_relation number Minimum relation (-100 to +100)
---@param max_relation number Maximum relation (-100 to +100)
---@return table Array of countries in range
function CountryManager:getCountriesByRelation(min_relation, max_relation)
    local result = {}
    for _, country in ipairs(self:getAllCountries()) do
        if country.relation >= min_relation and country.relation <= max_relation then
            table.insert(result, country)
        end
    end
    return result
end

---Update country state
---@param country_id string Country identifier
---@param updates table Properties to update
---@return boolean True if successful
function CountryManager:updateCountryState(country_id, updates)
    local country = self:getCountry(country_id)
    if not country then
        return false
    end

    -- Update allowed properties
    if updates.panic ~= nil then
        country.panic = math.max(self.config.minPanic, math.min(self.config.maxPanic + 50, updates.panic))
    end
    if updates.funding_level ~= nil then
        country.funding_level = math.max(self.config.minFundingLevel,
                                         math.min(self.config.maxFundingLevel, updates.funding_level))
    end
    if updates.stability ~= nil then
        country.stability = math.max(0, math.min(100, updates.stability))
    end
    if updates.military_readiness ~= nil then
        country.military_readiness = math.max(0, math.min(100, updates.military_readiness))
    end
    if updates.morale ~= nil then
        country.morale = math.max(0, math.min(100, updates.morale))
    end

    return true
end

---Calculate monthly funding for a country
---@param country_id string Country identifier
---@return number Monthly funding amount
function CountryManager:calculateFunding(country_id)
    local country = self:getCountry(country_id)
    if not country or country.is_collapsed then
        return 0
    end

    -- Funding = GDP × Funding Level × Relation Modifier
    -- Relation Modifier = 0.5 to 1.0 based on relation (-100 to +100)
    local relationModifier = 0.5 + (country.relation / 100 * self.config.relationModifierRange)
    relationModifier = math.max(0.1, math.min(1.0, relationModifier))  -- Clamp

    local funding = country.gdp * country.funding_level * relationModifier
    return math.ceil(funding)
end

---Get total funding from all countries
---@return number Sum of all country funding
function CountryManager:getTotalFunding()
    local total = 0
    for _, country in ipairs(self:getAllCountries()) do
        total = total + self:calculateFunding(country.id)
    end
    return total
end

---Modify panic for a country
---@param country_id string Country identifier
---@param delta number Panic change (positive or negative)
---@param reason string Reason for change (logging)
---@return number|nil New panic level
---@return boolean True if country collapsed
function CountryManager:modifyPanic(country_id, delta, reason)
    local country = self:getCountry(country_id)
    if not country then
        print(string.format("[CountryManager] ERROR: Country '%s' not found", country_id))
        return nil, false
    end

    local oldPanic = country.panic
    country.panic = math.max(self.config.minPanic, country.panic + delta)

    -- Log change
    local direction = delta >= 0 and "+" or ""
    print(string.format("[CountryManager] %s panic: %d %s%d = %d (%s)",
        country.name, oldPanic, direction, delta, country.panic, reason or ""))

    -- Update morale based on panic
    country.morale = math.max(10, 100 - (country.panic * 0.8))

    -- Check for collapse
    if country.panic > country.panic_threshold then
        return country.panic, self:handleCountryCollapse(country_id)
    end

    return country.panic, false
end

---Handle country collapse mechanics
---@param country_id string Country identifier
---@return boolean True if collapsed
function CountryManager:handleCountryCollapse(country_id)
    local country = self:getCountry(country_id)
    if not country or country.is_collapsed then
        return false
    end

    -- Mark as collapsed
    country.is_collapsed = true

    print(string.format("[CountryManager] *** COUNTRY COLLAPSE: %s has fallen to alien forces! ***", country.name))
    print(string.format("[CountryManager] Panic level: %d (threshold: %d)", country.panic, country.panic_threshold))

    -- Immediate effects
    country.panic = country.panic_threshold + 1
    country.funding_level = 0
    country.morale = 0
    country.stability = 25

    -- Try to notify RelationsManager
    local RelationsManager = require("geoscape.systems.relations_manager")
    if RelationsManager and RelationsManager.getActiveMod then
        -- TODO: Notify other countries of loss
    end

    return true
end

---Check and trigger country collapse if needed
---@param country_id string Country identifier
---@return boolean True if country is collapsed
function CountryManager:checkCountryCollapse(country_id)
    local country = self:getCountry(country_id)
    if not country then
        return false
    end

    if country.panic > country.panic_threshold then
        return self:handleCountryCollapse(country_id)
    end

    return country.is_collapsed
end

---Update all countries based on time passage
---@param days_passed number Days elapsed since last update
function CountryManager:updateDailyState(days_passed)
    days_passed = days_passed or 1

    for _, country in ipairs(self:getAllCountries()) do
        if not country.is_collapsed then
            -- Panic decay (natural reduction over time)
            local panicDecay = self.config.panicDecayPerDay * days_passed
            if country.panic > 0 then
                self:modifyPanic(country.id, -panicDecay, "Natural decay")
            end

            -- Stability changes (very slow)
            if country.relation > 50 then
                country.stability = math.min(100, country.stability + 0.2 * days_passed)
            elseif country.relation < -50 then
                country.stability = math.max(20, country.stability - 0.3 * days_passed)
            end

            -- Military readiness decay (needs maintenance)
            country.military_readiness = math.max(40, country.military_readiness - 0.1 * days_passed)
        end
    end

    -- Update relations decay/growth
    self:updateAllRelations(days_passed)

    if days_passed > 0 then
        print(string.format("[CountryManager] Updated all countries and relations after %d day(s)", days_passed))
    end
end

---Apply time-based decay/growth to relations
---@param daysPassed number Days since last update
function CountryManager:updateAllRelations(daysPassed)
    daysPassed = daysPassed or 1

    -- Update country relations
    for countryId, entry in pairs(self.relations) do
        self:applyRelationTimeDecayGrowth(entry, daysPassed)
    end
end

---Apply time-based decay/growth to a single relation
---@param entry table Relation entry
---@param daysPassed number Days since last update
function CountryManager:applyRelationTimeDecayGrowth(entry, daysPassed)
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

        -- Update country state
        local country = self:getCountry(entry.id or next(self.relations, nil))  -- Fallback for finding country
        if country then
            country.relation = entry.value
        end

        -- Update trend
        self:updateRelationTrend(entry.id or next(self.relations, nil))
    end
end

---Get comprehensive status for a country
---@param country_id string Country identifier
---@return table|nil Status object
function CountryManager:getCountryStatus(country_id)
    local country = self:getCountry(country_id)
    if not country then
        return nil
    end

    local fundingAmount = self:calculateFunding(country_id)
    local relationEntry = self.relations[country_id] or {value = 0, trend = "stable"}

    -- Determine status labels
    local relation = relationEntry.value
    local relationLabel = self:getRelationLabel(relation)
    local relationColor = self:getRelationColor(relation)

    local panic = country.panic
    local panicLabel = "Low"
    if panic >= 76 then panicLabel = "Critical"
    elseif panic >= 51 then panicLabel = "High"
    elseif panic >= 26 then panicLabel = "Moderate"
    end

    return {
        id = country.id,
        name = country.name,
        nation_type = country.nation_type,
        status_label = relationLabel,
        relation = relation,
        relation_trend = relationEntry.trend,
        relation_color = relationColor,
        panic = panic,
        panic_label = panicLabel,
        funding = fundingAmount,
        funding_level = country.funding_level,
        stability = country.stability,
        morale = country.morale,
        military_readiness = country.military_readiness,
        is_collapsed = country.is_collapsed,
        is_at_war = country.is_at_war,
        crisis_count = #country.active_crises
    }
end

---Integrate with RelationsManager
function CountryManager:integrateWithRelationsManager()
    -- Relations are now integrated directly into CountryManager
    -- No external RelationsManager needed for countries
    print(string.format("[CountryManager] Relations system integrated for %d countries", #self:getAllCountries()))
end

---Serialize country state for saving
---@return table Serialized state
function CountryManager:serialize()
    local data = {}

    for _, country in ipairs(self:getAllCountries()) do
        local countryData = {
            id = country.id,
            relation = country.relation,
            panic = country.panic,
            funding_level = country.funding_level,
            stability = country.stability,
            military_readiness = country.military_readiness,
            morale = country.morale,
            is_collapsed = country.is_collapsed,
            is_at_war = country.is_at_war,
            missions_completed = country.missions_completed,
            missions_failed = country.missions_failed,
            ufos_defeated = country.ufos_defeated,
            bases_raided = country.bases_raided
        }
        data[country.id] = countryData
    end

    -- Include relations data
    local relationsData = {}
    for countryId, entry in pairs(self.relations) do
        relationsData[countryId] = {
            value = entry.value,
            history = entry.history,
            trend = entry.trend
        }
    end

    print("[CountryManager] Serialized country and relations state")
    return {
        countries = data,
        relations = relationsData
    }
end

---Deserialize country state from save
---@param data table Serialized state
function CountryManager:deserialize(data)
    if not data then
        print("[CountryManager] No serialized data to load")
        return
    end

    local countriesData = data.countries or data  -- Support old format
    local relationsData = data.relations or {}

    for countryId, countryData in pairs(countriesData) do
        local country = self:getCountry(countryId)
        if country then
            country.relation = countryData.relation or 0
            country.panic = countryData.panic or 0
            country.funding_level = countryData.funding_level or 5
            country.stability = countryData.stability or 75
            country.military_readiness = countryData.military_readiness or 75
            country.morale = countryData.morale or 75
            country.is_collapsed = countryData.is_collapsed or false
            country.is_at_war = countryData.is_at_war or false
            country.missions_completed = countryData.missions_completed or 0
            country.missions_failed = countryData.missions_failed or 0
            country.ufos_defeated = countryData.ufos_defeated or 0
            country.bases_raided = countryData.bases_raided or 0
        end
    end

    -- Load relations data
    for countryId, entry in pairs(relationsData) do
        if self.relations[countryId] then
            self.relations[countryId].value = entry.value or 0
            self.relations[countryId].history = entry.history or {}
            self.relations[countryId].trend = entry.trend or "stable"
        end
    end

    print("[CountryManager] Deserialized country and relations state")
end

---Record mission completion for a country
---@param country_id string Country identifier
---@param success boolean True if mission was successful
function CountryManager:recordMission(country_id, success)
    local country = self:getCountry(country_id)
    if not country then return end

    country.last_mission_date = os.time()
    if success then
        country.missions_completed = country.missions_completed + 1
    else
        country.missions_failed = country.missions_failed + 1
    end
end

---Record UFO defeat in country territory
---@param country_id string Country identifier
---@param ufo_threat_level number Threat level of UFO (1-10)
function CountryManager:recordUFODefeat(country_id, ufo_threat_level)
    local country = self:getCountry(country_id)
    if not country then return end

    country.ufos_defeated = country.ufos_defeated + 1

    -- Apply beneficial panic change
    local panicReduction = 5 + (ufo_threat_level * 2)
    self:modifyPanic(country_id, -panicReduction, "UFO destroyed in territory (threat " .. ufo_threat_level .. ")")
end

---Get current diplomatic relation with country
---@param country_id string Country identifier
---@return number|nil Relation value (-100 to +100), or nil if not found
function CountryManager:getRelation(country_id)
    if not self.relations[country_id] then
        return nil
    end
    return self.relations[country_id].value
end

---Set diplomatic relation to exact value
---@param country_id string Country identifier
---@param value number Target relation (-100 to +100)
---@param reason string|nil Reason for change (for logging)
function CountryManager:setRelation(country_id, value, reason)
    if not self.relations[country_id] then
        self.relations[country_id] = {value = 0, history = {}, trend = "stable"}
    end

    value = math.max(self.config.minRelation, math.min(self.config.maxRelation, value))

    local oldValue = self.relations[country_id].value
    local delta = value - oldValue

    self.relations[country_id].value = value

    -- Update country state
    local country = self:getCountry(country_id)
    if country then
        country.relation = value
    end

    -- Record in history
    self:recordRelationChange(country_id, delta, reason or "Direct set")

    -- Update trend
    self:updateRelationTrend(country_id)

    print(string.format("[CountryManager] Relation with '%s' set to %d (was %d): %s",
          country_id, value, oldValue, reason or "Direct set"))
end

---Modify diplomatic relation by delta
---@param country_id string Country identifier
---@param delta number Change amount
---@param reason string|nil Reason for change (for logging)
---@return number New relation value
function CountryManager:modifyRelation(country_id, delta, reason)
    if not self.relations[country_id] then
        self.relations[country_id] = {value = 0, history = {}, trend = "stable"}
    end

    -- Clamp delta to valid range
    local oldValue = self.relations[country_id].value
    local newValue = math.max(self.config.minRelation,
                              math.min(self.config.maxRelation, oldValue + delta))

    self.relations[country_id].value = newValue

    -- Update country state
    local country = self:getCountry(country_id)
    if country then
        country.relation = newValue
    end

    -- Record in history
    self:recordRelationChange(country_id, newValue - oldValue, reason or "Modification")

    -- Update trend
    self:updateRelationTrend(country_id)

    print(string.format("[CountryManager] Relation with '%s' modified: %d %c %d = %d (%s)",
          country_id, oldValue, delta >= 0 and '+' or ' ', delta, newValue, reason or ""))

    return newValue
end

---Record relation change in history
---@param country_id string Country ID
---@param delta number Change amount
---@param reason string Reason for change
function CountryManager:recordRelationChange(country_id, delta, reason)
    if not self.relations[country_id] then
        return
    end

    local history = self.relations[country_id].history

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

---Update relation trend (improving/declining/stable)
---@param country_id string Country ID
function CountryManager:updateRelationTrend(country_id)
    if not self.relations[country_id] or #self.relations[country_id].history == 0 then
        self.relations[country_id].trend = "stable"
        return
    end

    -- Calculate average delta from recent changes
    local recentChanges = math.min(5, #self.relations[country_id].history)
    local totalDelta = 0

    for i = 1, recentChanges do
        totalDelta = totalDelta + self.relations[country_id].history[i].delta
    end

    local avgDelta = totalDelta / recentChanges

    if avgDelta > 0.5 then
        self.relations[country_id].trend = "improving"
    elseif avgDelta < -0.5 then
        self.relations[country_id].trend = "declining"
    else
        self.relations[country_id].trend = "stable"
    end
end

---Get descriptive label for relation value
---@param value number Relation value
---@return string Descriptive label
function CountryManager:getRelationLabel(value)
    for _, threshold in ipairs(self.relationThresholds) do
        if value >= threshold.min and value <= threshold.max then
            return threshold.label
        end
    end
    return "Unknown"
end

---Get color for relation value (for UI)
---@param value number Relation value
---@return table RGB color {r, g, b}
function CountryManager:getRelationColor(value)
    for _, threshold in ipairs(self.relationThresholds) do
        if value >= threshold.min and value <= threshold.max then
            return threshold.color
        end
    end
    return {255, 255, 255}  -- White default
end

---Get recent relation history for a country
---@param country_id string Country ID
---@param maxEntries number Maximum history entries (default 10)
---@return table Array of {delta, reason, timestamp}
function CountryManager:getRelationHistory(country_id, maxEntries)
    maxEntries = maxEntries or 10

    if not self.relations[country_id] then
        return {}
    end

    local history = {}
    for i = 1, math.min(maxEntries, #self.relations[country_id].history) do
        table.insert(history, self.relations[country_id].history[i])
    end

    return history
end

return CountryManager
