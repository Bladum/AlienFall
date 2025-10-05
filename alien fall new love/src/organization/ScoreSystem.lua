--- ScoreSystem class for Alien Fall game
-- Manages performance evaluation, funding correlation, and strategic assessment
-- @classmod ScoreSystem
-- @author Your Name
-- @license MIT
-- @copyright 2024 Alien Fall Team

local class = require 'lib.Middleclass'

local ScoreSystem = {}
ScoreSystem.__index = ScoreSystem

local EventBusClass = require 'engine.event_bus'
local EventBus = EventBusClass.new()

--- @class ScoreSystem
--- @field province_scores table Map of province_id -> current score
--- @field country_score number Current aggregated country score
--- @field monthly_funding_level number Current monthly funding level
--- @field history table Score change history for analytics
--- @field last_update number Timestamp of last score update
--- @field config table System configuration

--- ScoreSystem constructor
--- @param config table Configuration options
--- @return ScoreSystem
function ScoreSystem.new(config)
    local self = setmetatable({}, ScoreSystem)
    config = config or {}
    self.province_scores = {}
    self.country_score = 0
    self.monthly_funding_level = 0
    self.history = {}
    self.last_update = os.time()
    self.config = config or {}

    -- Set default config
    self.config.base_funding_multiplier = self.config.base_funding_multiplier or 1000
    self.config.score_aggregation_method = self.config.score_aggregation_method or "sum"
    self.config.monthly_points_divisor = self.config.monthly_points_divisor or 250
    self.config.max_score_change = self.config.max_score_change or 50
    self.config.history_limit = self.config.history_limit or 5000

    -- Subscribe to relevant events
    self:_setup_event_listeners()

    return self
end

--- Get current score for a province
--- @param province_id string Province identifier
--- @return number|nil Current province score or nil if not tracked
function ScoreSystem:get_province_score(province_id)
    return self.province_scores[province_id]
end

--- Get current country score
--- @return number Current aggregated country score
function ScoreSystem:get_country_score()
    return self.country_score
end

--- Get current monthly funding level
--- @return number Current monthly funding level
function ScoreSystem:get_monthly_funding_level()
    return self.monthly_funding_level
end

--- Modify score for a province
--- @param province_id string Province identifier
--- @param delta number Score change amount (can be negative)
--- @param source string Source of the score change
--- @param reason string Reason for the change
--- @param visibility string Visibility level (public, restricted, classified)
--- @param seed number|nil Random seed for deterministic changes
--- @return number New province score
function ScoreSystem:modify_province_score(province_id, delta, source, reason, visibility, seed)
    -- Only process public actions
    if visibility == "classified" then
        return self.province_scores[province_id] or 0
    end

    local old_score = self.province_scores[province_id] or 0

    -- Clamp delta to prevent extreme changes
    delta = math.max(-self.config.max_score_change, math.min(self.config.max_score_change, delta))

    -- Apply change
    local new_score = old_score + delta
    self.province_scores[province_id] = new_score
    self.last_update = os.time()

    -- Record in history
    table.insert(self.history, {
        timestamp = self.last_update,
        province_id = province_id,
        old_score = old_score,
        new_score = new_score,
        delta = delta,
        source = source,
        reason = reason,
        visibility = visibility,
        seed = seed
    })

    -- Limit history size
    if #self.history > self.config.history_limit then
        table.remove(self.history, 1)
    end

    -- Recalculate country score
    self:_recalculate_country_score()

    -- Publish event
    EventBus:publish("score:province_changed", {
        province_id = province_id,
        old_score = old_score,
        new_score = new_score,
        delta = delta,
        source = source,
        reason = reason,
        visibility = visibility,
        country_score = self.country_score
    })

    return new_score
end

--- Process monthly funding calculation
--- @return number New monthly funding level
function ScoreSystem:calculate_monthly_funding()
    -- MonthlyPoints = floor(CountryTotalScore / 250)
    local monthly_points = math.floor(self.country_score / self.config.monthly_points_divisor)

    -- FundingLevel = max(0, min(100, MonthlyPoints))
    self.monthly_funding_level = math.max(0, math.min(100, monthly_points))

    -- Publish event
    EventBus:publish("score:monthly_funding_calculated", {
        country_score = self.country_score,
        monthly_points = monthly_points,
        funding_level = self.monthly_funding_level,
        base_funding = self.config.base_funding_multiplier
    })

    return self.monthly_funding_level
end

--- Get actual funding amount for the month
--- @param country_economy_value number Economic value of the country
--- @return number Actual funding amount
function ScoreSystem:get_monthly_funding_amount(country_economy_value)
    local funding_level = self:get_monthly_funding_level()
    return funding_level * (country_economy_value or 1) * self.config.base_funding_multiplier
end

--- Process mission score change
--- @param province_id string Province where mission occurred
--- @param mission_type string Type of mission
--- @param success boolean Whether mission was successful
--- @param visibility string Mission visibility level
--- @param civilian_casualties number Number of civilian casualties
--- @return number Score change amount
function ScoreSystem:process_mission_score(province_id, mission_type, success, visibility, civilian_casualties)
    local delta = 0

    if success then
        -- Success bonuses based on visibility
        local visibility_bonuses = {
            public = 100,
            restricted = 50,
            classified = 0
        }
        delta = visibility_bonuses[visibility] or 50
    else
        -- Failure penalties
        delta = -25
    end

    -- Civilian casualty penalties
    delta = delta - (civilian_casualties * 10)

    -- Mission type modifiers
    local type_modifiers = {
        interception = 1.0,
        base_attack = 1.5,
        terror_mission = 0.8,
        research = 0.6,
        rescue = 1.2
    }
    delta = delta * (type_modifiers[mission_type] or 1.0)

    return self:modify_province_score(province_id, delta, "mission",
        string.format("%s_%s_casualties_%d", mission_type, success and "success" or "failure", civilian_casualties),
        visibility)
end

--- Process base event score change
--- @param province_id string Province where event occurred
--- @param event_type string Type of base event
--- @param success boolean Whether the event was successful
--- @return number Score change amount
function ScoreSystem:process_base_event_score(province_id, event_type, success)
    local delta = 0

    local event_modifiers = {
        attack_repelled = success and 80 or -40,
        base_destroyed = -150,
        new_base_construction = 30,
        public_facility_tour = 120
    }

    delta = event_modifiers[event_type] or 0

    return self:modify_province_score(province_id, delta, "base_event",
        string.format("%s_%s", event_type, success and "success" or "failure"), "public")
end

--- Process enemy base activity score change
--- @param province_id string Province affected by enemy base
--- @param base_level number Level of the enemy base
--- @param activity_type string Type of activity (daily_penalty, etc.)
--- @return number Score change amount
function ScoreSystem:process_enemy_base_score(province_id, base_level, activity_type)
    local delta = 0

    if activity_type == "daily_penalty" then
        -- Daily score reduction scaled by base level
        delta = -base_level * 5
    elseif activity_type == "level_penalty" then
        -- Significant penalty for high-level bases
        delta = -base_level * 25
    end

    return self:modify_province_score(province_id, delta, "enemy_base",
        string.format("level_%d_%s", base_level, activity_type), "public")
end

--- Process calendar event score change
--- @param province_id string Province affected
--- @param event_type string Type of calendar event
--- @param severity number Event severity level
--- @return number Score change amount
function ScoreSystem:process_calendar_event_score(province_id, event_type, severity)
    local delta = 0

    local event_modifiers = {
        threat_unresolved = -10 * severity,
        strategic_failure = -25 * severity,
        diplomatic_incident = -15 * severity,
        public_safety = 20 * severity
    }

    delta = event_modifiers[event_type] or 0

    return self:modify_province_score(province_id, delta, "calendar",
        string.format("%s_severity_%d", event_type, severity), "public")
end

--- Get all province scores
--- @return table Map of province_id -> score
function ScoreSystem:get_all_province_scores()
    local result = {}
    for province_id, score in pairs(self.province_scores) do
        result[province_id] = score
    end
    return result
end

--- Get score statistics
--- @return table Score system statistics
function ScoreSystem:get_statistics()
    local province_count = 0
    local total_score = 0
    local positive_provinces = 0
    local negative_provinces = 0
    local max_score = -math.huge
    local min_score = math.huge

    for province_id, score in pairs(self.province_scores) do
        province_count = province_count + 1
        total_score = total_score + score

        if score > 0 then
            positive_provinces = positive_provinces + 1
        elseif score < 0 then
            negative_provinces = negative_provinces + 1
        end

        max_score = math.max(max_score, score)
        min_score = math.min(min_score, score)
    end

    local average_score = province_count > 0 and (total_score / province_count) or 0

    return {
        province_count = province_count,
        total_score = total_score,
        country_score = self.country_score,
        average_score = average_score,
        positive_provinces = positive_provinces,
        negative_provinces = negative_provinces,
        max_score = max_score,
        min_score = min_score,
        monthly_funding_level = self.monthly_funding_level,
        history_entries = #self.history
    }
end

--- Get score history filtered by criteria
--- @param filters table Filter criteria (province_id, source, date_range, etc.)
--- @return table Array of filtered history entries
function ScoreSystem:get_history(filters)
    filters = filters or {}
    local result = {}

    for _, entry in ipairs(self.history) do
        local include = true

        if filters.province_id and entry.province_id ~= filters.province_id then
            include = false
        end

        if filters.source and entry.source ~= filters.source then
            include = false
        end

        if filters.visibility and entry.visibility ~= filters.visibility then
            include = false
        end

        if filters.date_from and entry.timestamp < filters.date_from then
            include = false
        end

        if filters.date_to and entry.timestamp > filters.date_to then
            include = false
        end

        if include then
            table.insert(result, entry)
        end
    end

    return result
end

--- Export score system data
--- @param format string Export format (json, yaml, lua)
--- @return string Exported data
function ScoreSystem:export(format)
    local data = {
        province_scores = self:get_all_province_scores(),
        country_score = self.country_score,
        monthly_funding_level = self.monthly_funding_level,
        statistics = self:get_statistics(),
        last_update = self.last_update,
        config = self.config
    }

    if format == "json" then
        return self:_to_json(data)
    elseif format == "yaml" then
        return self:_to_yaml(data)
    else -- lua
        return "return " .. self:_serialize_table(data)
    end
end

-- Private methods

function ScoreSystem:_setup_event_listeners()
    -- Listen for mission completion events
    EventBus:subscribe("mission:completed", function(data)
        if data.province_id then
            self:process_mission_score(
                data.province_id,
                data.mission_type,
                data.success,
                data.visibility or "public",
                data.civilian_casualties or 0
            )
        end
    end)

    -- Listen for base events
    EventBus:subscribe("base:event_occurred", function(data)
        if data.province_id then
            self:process_base_event_score(
                data.province_id,
                data.event_type,
                data.success
            )
        end
    end)

    -- Listen for enemy base activity
    EventBus:subscribe("enemy_base:active", function(data)
        if data.affected_provinces then
            for _, province_id in ipairs(data.affected_provinces) do
                self:process_enemy_base_score(
                    province_id,
                    data.base_level,
                    data.activity_type
                )
            end
        end
    end)

    -- Listen for calendar events
    EventBus:subscribe("calendar:event_processed", function(data)
        if data.affected_provinces then
            for _, province_id in ipairs(data.affected_provinces) do
                self:process_calendar_event_score(
                    province_id,
                    data.event_type,
                    data.severity or 1
                )
            end
        end
    end)

    -- Listen for monthly processing
    EventBus:subscribe("calendar:month_end", function(data)
        self:calculate_monthly_funding()
    end)
end

function ScoreSystem:_recalculate_country_score()
    local total = 0
    local count = 0

    for province_id, score in pairs(self.province_scores) do
        if self.config.score_aggregation_method == "sum" then
            total = total + score
        elseif self.config.score_aggregation_method == "average" then
            total = total + score
            count = count + 1
        end
    end

    if self.config.score_aggregation_method == "average" and count > 0 then
        self.country_score = total / count
    else
        self.country_score = total
    end
end

function ScoreSystem:_to_json(data)
    return "JSON export not implemented - would use proper JSON library"
end

function ScoreSystem:_to_yaml(data)
    return "YAML export not implemented - would use proper YAML library"
end

function ScoreSystem:_serialize_table(tbl, indent)
    indent = indent or ""
    local result = "{\n"

    for key, value in pairs(tbl) do
        result = result .. indent .. "  " .. self:_serialize_key(key) .. " = " .. self:_serialize_value(value, indent .. "  ") .. ",\n"
    end

    result = result .. indent .. "}"
    return result
end

function ScoreSystem:_serialize_key(key)
    if type(key) == "string" then
        return '["' .. key .. '"]'
    else
        return '[' .. tostring(key) .. ']'
    end
end

function ScoreSystem:_serialize_value(value, indent)
    local t = type(value)
    if t == "string" then
        return '"' .. value .. '"'
    elseif t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "table" then
        return self:_serialize_table(value, indent)
    else
        return '"' .. tostring(value) .. '"'
    end
end

return ScoreSystem
