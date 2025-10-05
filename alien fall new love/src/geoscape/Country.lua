--- Country.lua
-- Country system for Alien Fall
-- Political and economic regions that fund player based on performance

-- GROK: Country represents political region aggregating province economies and funding player
-- GROK: Manages public score, funding levels, and diplomatic relations
-- GROK: Key methods: calculateFunding(), updatePublicScore(), getEconomicValue()
-- GROK: Handles visibility constraints and political state changes

local class = require 'lib.Middleclass'

Country = class('Country')

--- Initialize a new country
-- @param data The TOML data for this country
function Country:initialize(data)
    self.id = data.id
    self.name = data.name or "Unknown Country"
    self.description = data.description or ""

    -- Geographic scope (province IDs)
    self.province_ids = data.province_ids or {}

    -- Economic data
    self.base_funding_level = data.base_funding_level or 1
    self.current_funding_level = self.base_funding_level
    self.funding_modifier = data.funding_modifier or 1.0
    self.population = data.population or 0
    self.economy_value = data.economy_value or 0

    -- Public score system
    self.public_score = data.public_score or 0
    self.score_thresholds = data.score_thresholds or {
        excellent = 100,
        good = 50,
        neutral = 0,
        poor = -50,
        critical = -100
    }

    -- Funding calculation
    self.monthly_funding = 0
    self.last_funding_update = 0

    -- Diplomatic state
    self.diplomatic_state = data.diplomatic_state or "neutral"
    self.withdrawn = data.withdrawn or false

    -- World reference
    self.world = nil

    -- Event bus
    self.event_bus = nil

    -- Validate data
    self:_validate()
end

--- Validate the country data
function Country:_validate()
    assert(self.id, "Country must have an id")
    assert(self.name, "Country must have a name")
end

--- Set the world reference
-- @param world The World instance
function Country:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Add a province to this country
-- @param province The Province instance to add
function Country:addProvince(province)
    -- Add to province_ids if not already present
    local already_present = false
    for _, id in ipairs(self.province_ids) do
        if id == province.id then
            already_present = true
            break
        end
    end
    
    if not already_present then
        table.insert(self.province_ids, province.id)
    end
end

--- Get province IDs belonging to this country
-- @return Array of province IDs
function Country:getProvinceIds()
    return self.province_ids
end

--- Get provinces belonging to this country
-- @return Array of Province instances
function Country:getProvinces()
    if not self.world then
        return {}
    end

    local provinces = {}
    for _, province_id in ipairs(self.province_ids) do
        local province = self.world:getProvince(province_id)
        if province then
            table.insert(provinces, province)
        end
    end
    return provinces
end

--- Calculate total economic value of all provinces
-- @return Total economic value
function Country:getEconomicValue()
    local total = 0
    local provinces = self:getProvinces()

    for _, province in ipairs(provinces) do
        total = total + province:getEconomyValue()
    end

    return total
end

--- Get current public score
-- @return Public score value
function Country:getPublicScore()
    return self.public_score
end

--- Update public score based on visible actions
-- @param score_change The change in public score
-- @param reason The reason for the change (for logging)
function Country:updatePublicScore(score_change, reason)
    local old_score = self.public_score
    self.public_score = self.public_score + score_change

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("country:score_changed", {
            country_id = self.id,
            old_score = old_score,
            new_score = self.public_score,
            change = score_change,
            reason = reason or "unknown"
        })
    end

    -- Check for funding level changes
    self:_updateFundingLevel()
end

--- Update funding level based on current score
function Country:_updateFundingLevel()
    local score = self.public_score
    local new_level = self.base_funding_level

    -- Determine funding level based on score thresholds
    if score >= self.score_thresholds.excellent then
        new_level = 3  -- Excellent funding
    elseif score >= self.score_thresholds.good then
        new_level = 2  -- Good funding
    elseif score >= self.score_thresholds.neutral then
        new_level = 1  -- Normal funding
    elseif score >= self.score_thresholds.poor then
        new_level = 0.5  -- Reduced funding
    elseif score >= self.score_thresholds.critical then
        new_level = 0.25  -- Minimal funding
    else
        new_level = 0  -- No funding
        self.withdrawn = true
    end

    if new_level ~= self.current_funding_level then
        local old_level = self.current_funding_level
        self.current_funding_level = new_level

        -- Publish event
        if self.event_bus then
            self.event_bus:publish("country:funding_changed", {
                country_id = self.id,
                old_level = old_level,
                new_level = new_level,
                score = self.public_score
            })
        end
    end
end

--- Calculate monthly funding amount
-- @return Monthly funding in credits
function Country:calculateFunding()
    if self.withdrawn then
        return 0
    end

    local economic_value = self:getEconomicValue()
    local funding = self.current_funding_level * economic_value * self.funding_modifier * 1000

    self.monthly_funding = funding
    return funding
end

--- Get current funding level
-- @return Funding level (0-3)
function Country:getFundingLevel()
    return self.current_funding_level
end

--- Get diplomatic state
-- @return Diplomatic state string
function Country:getDiplomaticState()
    return self.diplomatic_state
end

--- Set diplomatic state
-- @param state New diplomatic state
function Country:setDiplomaticState(state)
    local old_state = self.diplomatic_state
    self.diplomatic_state = state

    -- Publish event
    if self.event_bus and old_state ~= state then
        self.event_bus:publish("country:diplomacy_changed", {
            country_id = self.id,
            old_state = old_state,
            new_state = state
        })
    end
end

--- Check if country has withdrawn funding
-- @return true if withdrawn
function Country:isWithdrawn()
    return self.withdrawn
end

--- Advance time for this country
-- @param days Number of days to advance
function Country:advanceTime(days)
    -- Process monthly funding updates
    self.last_funding_update = self.last_funding_update + days

    if self.last_funding_update >= 30 then  -- Monthly update
        self.last_funding_update = self.last_funding_update - 30
        self:_processMonthlyUpdate()
    end
end

--- Process monthly country updates
function Country:_processMonthlyUpdate()
    -- Recalculate funding
    local funding = self:calculateFunding()

    -- Publish monthly report event
    if self.event_bus then
        self.event_bus:publish("country:monthly_report", {
            country_id = self.id,
            funding = funding,
            score = self.public_score,
            economic_value = self:getEconomicValue(),
            funding_level = self.current_funding_level,
            withdrawn = self.withdrawn
        })
    end
end

--- Calculate country statistics from provinces
-- Updates population and economy_value based on current provinces
function Country:calculateStatistics()
    local total_population = 0
    local total_economy = 0
    
    local provinces = self:getProvinces()
    for _, province in ipairs(provinces) do
        total_population = total_population + (province.population or 0)
        total_economy = total_economy + (province.economy_value or 0)
    end
    
    self.population = total_population
    self.economy_value = total_economy
end

--- Get country statistics
-- @return Table with country statistics
function Country:getStatistics()
    return {
        province_count = #self.province_ids,
        economic_value = self:getEconomicValue(),
        public_score = self.public_score,
        funding_level = self.current_funding_level,
        monthly_funding = self.monthly_funding,
        diplomatic_state = self.diplomatic_state,
        withdrawn = self.withdrawn,
        population = self.population or 0,
        total_economy = self.economy_value or 0
    }
end

--- Get display information for UI
-- @return Table with display data
function Country:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        province_count = #self.province_ids,
        economic_value = self:getEconomicValue(),
        public_score = self.public_score,
        funding_level = self.current_funding_level,
        monthly_funding = self.monthly_funding,
        diplomatic_state = self.diplomatic_state,
        withdrawn = self.withdrawn
    }
end

--- Convert to string representation
-- @return String representation
function Country:__tostring()
    return string.format("Country{id='%s', name='%s', provinces=%d, score=%d, funding=%.1f}",
                        self.id, self.name, #self.province_ids, self.public_score, self.current_funding_level)
end

return Country
