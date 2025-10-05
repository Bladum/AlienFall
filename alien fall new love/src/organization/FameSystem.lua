--- FameSystem class for Alien Fall game
-- Manages organizational fame, public visibility, and reputation effects
-- @classmod FameSystem
-- @author Your Name
-- @license MIT
-- @copyright 2024 Alien Fall Team

local FameSystem = {}
FameSystem.__index = FameSystem

local EventBusClass = require 'engine.event_bus'
local EventBus = EventBusClass.new()

--- @class FameSystem
--- @field fame number Current fame level (0-100)
--- @field fame_level string Current fame level name (Obscure, Notable, Prominent, Famous, Legendary)
--- @field modifiers table Active fame modifiers
--- @field history table Fame change history for analytics
--- @field last_update number Timestamp of last fame update
--- @field config table System configuration

--- Fame level definitions
local FAME_LEVELS = {
    OBSCURE = { min = 0, max = 20, name = "Obscure" },
    NOTABLE = { min = 21, max = 40, name = "Notable" },
    PROMINENT = { min = 41, max = 60, name = "Prominent" },
    FAMOUS = { min = 61, max = 80, name = "Famous" },
    LEGENDARY = { min = 81, max = 100, name = "Legendary" }
}

--- FameSystem constructor
--- @param config table Configuration options
--- @return FameSystem
function FameSystem.new(config)
    local self = setmetatable({}, FameSystem)
    config = config or {}
    self.fame = 0
    self.fame_level = FAME_LEVELS.OBSCURE.name
    self.modifiers = {}
    self.history = {}
    self.last_update = os.time()
    self.config = config or {}

    -- Set default config
    self.config.base_funding_multiplier = self.config.base_funding_multiplier or 1.0
    self.config.base_recruitment_quality = self.config.base_recruitment_quality or 1.0
    self.config.base_mission_difficulty = self.config.base_mission_difficulty or 1.0

    -- Subscribe to relevant events
    self:_setup_event_listeners()

    return self
end

--- Get current fame level
--- @return number Current fame value (0-100)
function FameSystem:get_fame()
    return self.fame
end

--- Get current fame level name
--- @return string Fame level name
function FameSystem:get_fame_level()
    return self.fame_level
end

--- Get fame level data
--- @return table|nil Fame level information or nil if invalid fame value
function FameSystem:get_fame_level_data()
    for _, level in pairs(FAME_LEVELS) do
        if self.fame >= level.min and self.fame <= level.max then
            return {
                name = level.name,
                min = level.min,
                max = level.max,
                current = self.fame,
                progress = (self.fame - level.min) / (level.max - level.min)
            }
        end
    end
    return nil
end

--- Modify fame by a delta amount
--- @param delta number Fame change amount (can be negative)
--- @param source string Source of the fame change
--- @param reason string Reason for the change
--- @param seed number|nil Random seed for deterministic changes
--- @return number New fame value
function FameSystem:modify_fame(delta, source, reason, seed)
    local old_fame = self.fame
    local old_level = self.fame_level

    -- Apply modifiers to delta
    delta = self:_apply_modifiers_to_delta(delta, source)

    -- Clamp delta to prevent extreme changes
    delta = math.max(-20, math.min(20, delta))

    -- Apply change
    self.fame = math.max(0, math.min(100, self.fame + delta))
    self.last_update = os.time()

    -- Update fame level
    self.fame_level = self:_calculate_fame_level()

    -- Record in history
    table.insert(self.history, {
        timestamp = self.last_update,
        old_fame = old_fame,
        new_fame = self.fame,
        delta = delta,
        source = source,
        reason = reason,
        seed = seed,
        level_changed = (old_level ~= self.fame_level)
    })

    -- Publish events
    EventBus:publish("org:fame_changed", {
        old_fame = old_fame,
        new_fame = self.fame,
        delta = delta,
        source = source,
        reason = reason,
        level_changed = (old_level ~= self.fame_level),
        old_level = old_level,
        new_level = self.fame_level
    })

    -- Publish level change event if applicable
    if old_level ~= self.fame_level then
        EventBus:publish("org:fame_level_changed", {
            old_level = old_level,
            new_level = self.fame_level,
            fame = self.fame
        })
    end

    return self.fame
end

--- Add a fame modifier
--- @param id string Unique modifier identifier
--- @param modifier table Modifier data {type, value, duration, source}
--- @return boolean Success of addition
function FameSystem:add_modifier(id, modifier)
    if self.modifiers[id] then
        return false -- Modifier already exists
    end

    self.modifiers[id] = {
        type = modifier.type or "multiplier",
        value = modifier.value or 1.0,
        duration = modifier.duration, -- nil for permanent
        source = modifier.source or "unknown",
        applied_at = os.time(),
        expires_at = modifier.duration and (os.time() + modifier.duration) or nil
    }

    -- Publish modifier event
    EventBus:publish("org:fame_modifier_added", {
        modifier_id = id,
        modifier = self.modifiers[id]
    })

    return true
end

--- Remove a fame modifier
--- @param id string Modifier identifier
--- @return boolean Success of removal
function FameSystem:remove_modifier(id)
    if not self.modifiers[id] then
        return false
    end

    local modifier = self.modifiers[id]
    self.modifiers[id] = nil

    -- Publish modifier event
    EventBus:publish("org:fame_modifier_removed", {
        modifier_id = id,
        modifier = modifier
    })

    return true
end

--- Get active fame modifiers
--- @return table Array of active modifier data
function FameSystem:get_modifiers()
    local active = {}
    local current_time = os.time()

    for id, modifier in pairs(self.modifiers) do
        -- Check if modifier has expired
        if modifier.expires_at and current_time > modifier.expires_at then
            self:remove_modifier(id)
        else
            table.insert(active, {
                id = id,
                type = modifier.type,
                value = modifier.value,
                source = modifier.source,
                applied_at = modifier.applied_at,
                expires_at = modifier.expires_at,
                remaining_duration = modifier.expires_at and (modifier.expires_at - current_time) or nil
            })
        end
    end

    return active
end

--- Get funding multiplier based on fame
--- @return number Funding multiplier
function FameSystem:get_funding_multiplier()
    local level_data = self:get_fame_level_data()
    if not level_data then return self.config.base_funding_multiplier end

    local multipliers = {
        [FAME_LEVELS.OBSCURE.name] = 0.5,
        [FAME_LEVELS.NOTABLE.name] = 0.75,
        [FAME_LEVELS.PROMINENT.name] = 1.0,
        [FAME_LEVELS.FAMOUS.name] = 1.5,
        [FAME_LEVELS.LEGENDARY.name] = 2.0
    }

    return multipliers[level_data.name] or self.config.base_funding_multiplier
end

--- Get recruitment quality multiplier based on fame
--- @return number Recruitment quality multiplier
function FameSystem:get_recruitment_quality_multiplier()
    local level_data = self:get_fame_level_data()
    if not level_data then return self.config.base_recruitment_quality end

    local multipliers = {
        [FAME_LEVELS.OBSCURE.name] = 0.7,
        [FAME_LEVELS.NOTABLE.name] = 0.85,
        [FAME_LEVELS.PROMINENT.name] = 1.0,
        [FAME_LEVELS.FAMOUS.name] = 1.3,
        [FAME_LEVELS.LEGENDARY.name] = 1.5
    }

    return multipliers[level_data.name] or self.config.base_recruitment_quality
end

--- Get mission difficulty multiplier based on fame
--- @return number Mission difficulty multiplier
function FameSystem:get_mission_difficulty_multiplier()
    local level_data = self:get_fame_level_data()
    if not level_data then return self.config.base_mission_difficulty end

    local multipliers = {
        [FAME_LEVELS.OBSCURE.name] = 0.8,
        [FAME_LEVELS.NOTABLE.name] = 0.9,
        [FAME_LEVELS.PROMINENT.name] = 1.0,
        [FAME_LEVELS.FAMOUS.name] = 1.2,
        [FAME_LEVELS.LEGENDARY.name] = 1.4
    }

    return multipliers[level_data.name] or self.config.base_mission_difficulty
end

--- Get economic effects data
--- @return table Economic effects summary
function FameSystem:get_economic_effects()
    return {
        funding_multiplier = self:get_funding_multiplier(),
        recruitment_quality_multiplier = self:get_recruitment_quality_multiplier(),
        mission_difficulty_multiplier = self:get_mission_difficulty_multiplier(),
        fame_level = self.fame_level,
        fame_value = self.fame
    }
end

--- Process mission fame change
--- @param mission_type string Type of mission
--- @param success boolean Whether mission was successful
--- @param visibility string Mission visibility level
--- @param civilian_casualties number Number of civilian casualties
--- @return number Fame change amount
function FameSystem:process_mission_fame(mission_type, success, visibility, civilian_casualties)
    local delta = 0

    if success then
        -- Base success fame
        local base_fame = {
            high_visibility = 10,
            standard = 5,
            low_visibility = 1
        }
        delta = base_fame[visibility] or 5
    else
        -- Failure penalty
        delta = -2
    end

    -- Civilian casualty penalty
    delta = delta - (civilian_casualties * 3)

    -- Apply mission type modifiers
    local type_modifiers = {
        interception = 1.2,
        base_attack = 1.5,
        terror_mission = 0.8,
        research = 0.5
    }
    delta = delta * (type_modifiers[mission_type] or 1.0)

    return self:modify_fame(delta, "mission", string.format("%s_%s_casualties_%d",
        mission_type, success and "success" or "failure", civilian_casualties))
end

--- Process publicity action fame change
--- @param action_type string Type of publicity action
--- @return number Fame change amount
function FameSystem:process_publicity_action(action_type)
    local deltas = {
        press_release = 20,
        public_celebration = 15,
        official_denial = -10,
        media_blackout = -5
    }

    local delta = deltas[action_type] or 0
    return self:modify_fame(delta, "publicity", action_type)
end

--- Process research completion fame change
--- @param research_id string Research identifier
--- @param visibility string Research visibility level
--- @return number Fame change amount
function FameSystem:process_research_fame(research_id, visibility)
    local deltas = {
        stealth = 2,
        public_relations = 8,
        cloaking = 1,
        weapons = 3,
        medical = 4
    }

    -- Determine research category (simplified)
    local category = "standard"
    if research_id:find("stealth") then category = "stealth"
    elseif research_id:find("cloaking") then category = "cloaking"
    elseif research_id:find("weapon") then category = "weapons"
    elseif research_id:find("medical") then category = "medical"
    elseif research_id:find("pr") or research_id:find("media") then category = "public_relations"
    end

    local delta = deltas[category] or 3
    return self:modify_fame(delta, "research", research_id)
end

--- Get fame history
--- @param limit number|nil Maximum number of history entries to return
--- @return table Array of fame change history
function FameSystem:get_history(limit)
    limit = limit or #self.history
    local result = {}

    for i = math.max(1, #self.history - limit + 1), #self.history do
        table.insert(result, self.history[i])
    end

    return result
end

--- Export fame system data
--- @param format string Export format (json, yaml, lua)
--- @return string Exported data
function FameSystem:export(format)
    local data = {
        fame = self.fame,
        fame_level = self.fame_level,
        modifiers = self:get_modifiers(),
        history = self.history,
        last_update = self.last_update,
        economic_effects = self:get_economic_effects()
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

function FameSystem:_setup_event_listeners()
    -- Listen for mission completion events
    EventBus:subscribe("mission:completed", function(data)
        self:process_mission_fame(
            data.mission_type,
            data.success,
            data.visibility,
            data.civilian_casualties or 0
        )
    end)

    -- Listen for research completion events
    EventBus:subscribe("research:completed", function(data)
        self:process_research_fame(data.research_id, data.visibility or "standard")
    end)

    -- Listen for publicity actions
    EventBus:subscribe("org:publicity_action", function(data)
        self:process_publicity_action(data.action_type)
    end)
end

function FameSystem:_calculate_fame_level()
    for _, level in pairs(FAME_LEVELS) do
        if self.fame >= level.min and self.fame <= level.max then
            return level.name
        end
    end
    return FAME_LEVELS.OBSCURE.name
end

function FameSystem:_apply_modifiers_to_delta(delta, source)
    local modified_delta = delta

    for _, modifier in pairs(self.modifiers) do
        if modifier.type == "multiplier" then
            modified_delta = modified_delta * modifier.value
        elseif modifier.type == "additive" then
            modified_delta = modified_delta + modifier.value
        end
    end

    return modified_delta
end

function FameSystem:_to_json(data)
    return "JSON export not implemented - would use proper JSON library"
end

function FameSystem:_to_yaml(data)
    return "YAML export not implemented - would use proper YAML library"
end

function FameSystem:_serialize_table(tbl, indent)
    indent = indent or ""
    local result = "{\n"

    for key, value in pairs(tbl) do
        result = result .. indent .. "  " .. self:_serialize_key(key) .. " = " .. self:_serialize_value(value, indent .. "  ") .. ",\n"
    end

    result = result .. indent .. "}"
    return result
end

function FameSystem:_serialize_key(key)
    if type(key) == "string" then
        return '["' .. key .. '"]'
    else
        return '[' .. tostring(key) .. ']'
    end
end

function FameSystem:_serialize_value(value, indent)
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

return FameSystem
