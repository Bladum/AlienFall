--- KarmaSystem class for Alien Fall game
-- Manages organizational karma, moral standing, and content access restrictions
-- @classmod KarmaSystem
-- @author Your Name
-- @license MIT
-- @copyright 2024 Alien Fall Team

local class = require 'lib.Middleclass'

local KarmaSystem = {}
KarmaSystem.__index = KarmaSystem

local EventBusClass = require 'engine.event_bus'
local EventBus = EventBusClass.new()

--- @class KarmaSystem
--- @field karma number Current karma level (-100 to +100)
--- @field karma_alignment string Current karma alignment (Renegade, Ruthless, Neutral, Principled, Paragon)
--- @field history table Karma change history for analytics
--- @field last_update number Timestamp of last karma update
--- @field config table System configuration

--- Karma alignment definitions
local KARMA_ALIGNMENTS = {
    RENEGADE = { min = -100, max = -60, name = "Renegade" },
    RUTHLESS = { min = -59, max = -20, name = "Ruthless" },
    NEUTRAL = { min = -19, max = 19, name = "Neutral" },
    PRINCIPLED = { min = 20, max = 59, name = "Principled" },
    PARAGON = { min = 60, max = 100, name = "Paragon" }
}

--- KarmaSystem constructor
--- @param config table Configuration options
--- @return KarmaSystem
function KarmaSystem.new(config)
    local self = setmetatable({}, KarmaSystem)
    config = config or {}
    self.karma = 0
    self.karma_alignment = KARMA_ALIGNMENTS.NEUTRAL.name
    self.history = {}
    self.last_update = os.time()
    self.config = config or {}

    -- Set default config
    self.config.max_karma_change = self.config.max_karma_change or 15
    self.config.history_limit = self.config.history_limit or 1000

    -- Subscribe to relevant events
    self:_setup_event_listeners()

    return self
end

--- Get current karma level
--- @return number Current karma value (-100 to +100)
function KarmaSystem:get_karma()
    return self.karma
end

--- Get current karma alignment
--- @return string Karma alignment name
function KarmaSystem:get_karma_alignment()
    return self.karma_alignment
end

--- Get karma alignment data
--- @return table|nil Karma alignment information or nil if invalid karma value
function KarmaSystem:get_karma_alignment_data()
    for _, alignment in pairs(KARMA_ALIGNMENTS) do
        if self.karma >= alignment.min and self.karma <= alignment.max then
            return {
                name = alignment.name,
                min = alignment.min,
                max = alignment.max,
                current = self.karma,
                progress = alignment.name == KARMA_ALIGNMENTS.NEUTRAL.name and 0 or
                          (self.karma - alignment.min) / (alignment.max - alignment.min)
            }
        end
    end
    return nil
end

--- Modify karma by a delta amount
--- @param delta number Karma change amount (can be negative)
--- @param source string Source of the karma change
--- @param reason string Reason for the change
--- @param seed number|nil Random seed for deterministic changes
--- @return number New karma value
function KarmaSystem:modify_karma(delta, source, reason, seed)
    local old_karma = self.karma
    local old_alignment = self.karma_alignment

    -- Clamp delta to prevent extreme changes
    delta = math.max(-self.config.max_karma_change, math.min(self.config.max_karma_change, delta))

    -- Apply change
    self.karma = math.max(-100, math.min(100, self.karma + delta))
    self.last_update = os.time()

    -- Update karma alignment
    self.karma_alignment = self:_calculate_karma_alignment()

    -- Record in history
    table.insert(self.history, {
        timestamp = self.last_update,
        old_karma = old_karma,
        new_karma = self.karma,
        delta = delta,
        source = source,
        reason = reason,
        seed = seed,
        alignment_changed = (old_alignment ~= self.karma_alignment)
    })

    -- Limit history size
    if #self.history > self.config.history_limit then
        table.remove(self.history, 1)
    end

    -- Publish events
    EventBus:publish("org:karma_changed", {
        old_karma = old_karma,
        new_karma = self.karma,
        delta = delta,
        source = source,
        reason = reason,
        alignment_changed = (old_alignment ~= self.karma_alignment),
        old_alignment = old_alignment,
        new_alignment = self.karma_alignment
    })

    -- Publish alignment change event if applicable
    if old_alignment ~= self.karma_alignment then
        EventBus:publish("org:karma_alignment_changed", {
            old_alignment = old_alignment,
            new_alignment = self.karma_alignment,
            karma = self.karma
        })
    end

    return self.karma
end

--- Get available suppliers based on karma alignment
--- @return table Array of available supplier categories
function KarmaSystem:get_available_suppliers()
    local alignment = self:get_karma_alignment()

    local suppliers = {
        [KARMA_ALIGNMENTS.RENEGADE.name] = {"black_market", "arms_dealers", "rogue_scientists"},
        [KARMA_ALIGNMENTS.RUTHLESS.name] = {"black_market", "arms_dealers"},
        [KARMA_ALIGNMENTS.NEUTRAL.name] = {"standard", "medical", "technical", "military"},
        [KARMA_ALIGNMENTS.PRINCIPLED.name] = {"standard", "medical", "technical", "humanitarian", "international_aid"},
        [KARMA_ALIGNMENTS.PARAGON.name] = {"standard", "medical", "technical", "humanitarian", "international_aid", "peacekeeping"}
    }

    return suppliers[alignment] or suppliers[KARMA_ALIGNMENTS.NEUTRAL.name]
end

--- Get available research based on karma alignment
--- @return table Array of available research categories
function KarmaSystem:get_available_research()
    local alignment = self:get_karma_alignment()

    local research = {
        [KARMA_ALIGNMENTS.RENEGADE.name] = {"chemical_weapons", "mind_control", "enhanced_interrogation", "stealth", "weapons"},
        [KARMA_ALIGNMENTS.RUTHLESS.name] = {"chemical_weapons", "enhanced_interrogation", "stealth", "weapons"},
        [KARMA_ALIGNMENTS.NEUTRAL.name] = {"standard", "medical", "technical", "weapons", "aerospace"},
        [KARMA_ALIGNMENTS.PRINCIPLED.name] = {"non_lethal_weapons", "ethical_research", "humanitarian_tech", "medical", "technical"},
        [KARMA_ALIGNMENTS.PARAGON.name] = {"non_lethal_weapons", "ethical_research", "humanitarian_tech", "medical", "technical", "peacekeeping_tech"}
    }

    return research[alignment] or research[KARMA_ALIGNMENTS.NEUTRAL.name]
end

--- Get available mission types based on karma alignment
--- @return table Array of available mission types
function KarmaSystem:get_available_missions()
    local alignment = self:get_karma_alignment()

    local missions = {
        [KARMA_ALIGNMENTS.RENEGADE.name] = {"assassination", "ruthless_intervention", "covert_ops", "raid"},
        [KARMA_ALIGNMENTS.RUTHLESS.name] = {"covert_ops", "deniable_missions", "raid", "interception"},
        [KARMA_ALIGNMENTS.NEUTRAL.name] = {"interception", "base_attack", "terror_mission", "research", "rescue"},
        [KARMA_ALIGNMENTS.PRINCIPLED.name] = {"humanitarian", "protective_detail", "rescue", "interception", "research"},
        [KARMA_ALIGNMENTS.PARAGON.name] = {"peacekeeping", "rescue", "humanitarian", "protective_detail", "interception", "research"}
    }

    return missions[alignment] or missions[KARMA_ALIGNMENTS.NEUTRAL.name]
end

--- Check if a supplier category is available
--- @param supplier_category string Supplier category to check
--- @return boolean True if supplier category is available
function KarmaSystem:is_supplier_available(supplier_category)
    local available = self:get_available_suppliers()
    for _, category in ipairs(available) do
        if category == supplier_category then
            return true
        end
    end
    return false
end

--- Check if a research category is available
--- @param research_category string Research category to check
--- @return boolean True if research category is available
function KarmaSystem:is_research_available(research_category)
    local available = self:get_available_research()
    for _, category in ipairs(available) do
        if category == research_category then
            return true
        end
    end
    return false
end

--- Check if a mission type is available
--- @param mission_type string Mission type to check
--- @return boolean True if mission type is available
function KarmaSystem:is_mission_available(mission_type)
    local available = self:get_available_missions()
    for _, mtype in ipairs(available) do
        if mtype == mission_type then
            return true
        end
    end
    return false
end

--- Process mission karma change
--- @param mission_type string Type of mission
--- @param success boolean Whether mission was successful
--- @param civilian_casualties number Number of civilian casualties
--- @param collateral_damage boolean Whether there was significant collateral damage
--- @param hostage_rescue boolean Whether hostages were rescued non-lethally
--- @return number Karma change amount
function KarmaSystem:process_mission_karma(mission_type, success, civilian_casualties, collateral_damage, hostage_rescue)
    local delta = 0

    if success then
        -- Base success karma
        if civilian_casualties == 0 then
            delta = delta + 5 -- Humanitarian success
        end

        if hostage_rescue then
            delta = delta + 10 -- Ethical hostage rescue
        end
    end

    -- Casualty penalties
    delta = delta - (civilian_casualties * 5)

    -- Collateral damage penalty
    if collateral_damage then
        delta = delta - 8
    end

    -- Mission type modifiers
    local type_modifiers = {
        assassination = -10,
        ruthless_intervention = -5,
        humanitarian = 8,
        peacekeeping = 12,
        rescue = 5
    }
    delta = delta + (type_modifiers[mission_type] or 0)

    return self:modify_karma(delta, "mission", string.format("%s_casualties_%d_damage_%s_rescue_%s",
        mission_type, civilian_casualties, collateral_damage and "yes" or "no", hostage_rescue and "yes" or "no"))
end

--- Process capture and interrogation karma change
--- @param subject_type string Type of subject (alien, human, etc.)
--- @param method string Interrogation method used
--- @param outcome string Outcome of the interrogation
--- @return number Karma change amount
function KarmaSystem:process_interrogation_karma(subject_type, method, outcome)
    local delta = 0

    -- Base karma by subject type
    local subject_modifiers = {
        alien = 3, -- Preservation of life
        human_prisoner = 0,
        civilian = -2
    }
    delta = delta + (subject_modifiers[subject_type] or 0)

    -- Method modifiers
    local method_modifiers = {
        live_capture = 3,
        torture = -5,
        chemical = -3,
        mind_control = -8,
        ethical_study = 3
    }
    delta = delta + (method_modifiers[method] or 0)

    -- Outcome modifiers
    local outcome_modifiers = {
        successful = 0,
        escaped = -2,
        death = -5,
        recruited = 5
    }
    delta = delta + (outcome_modifiers[outcome] or 0)

    return self:modify_karma(delta, "interrogation", string.format("%s_%s_%s", subject_type, method, outcome))
end

--- Process equipment usage karma change
--- @param equipment_type string Type of equipment used
--- @param usage_context string Context of usage
--- @return number Karma change amount
function KarmaSystem:process_equipment_karma(equipment_type, usage_context)
    local delta = 0

    local equipment_modifiers = {
        non_lethal_weapon = { equip = 1, use = 2 },
        chemical_weapon = { equip = -2, use = -5 },
        mind_control_device = { equip = -3, use = -8 },
        medical_technology = { equip = 1, use = 3 },
        torture_device = { equip = -5, use = -10 }
    }

    local modifier = equipment_modifiers[equipment_type]
    if modifier then
        if usage_context == "equip" then
            delta = modifier.equip
        elseif usage_context == "use" then
            delta = modifier.use
        end
    end

    return self:modify_karma(delta, "equipment", string.format("%s_%s", equipment_type, usage_context))
end

--- Process ethical decision karma change
--- @param decision_type string Type of ethical decision
--- @param choice string Choice made
--- @return number Karma change amount
function KarmaSystem:process_ethical_decision(decision_type, choice)
    local delta = 0

    local decision_modifiers = {
        hostage_sacrifice = { utilitarian = -15, refuse = 5 },
        civilian_evacuation = { prioritize = 8, abandon = -10 },
        prisoner_release = { mercy = 5, retain = -3 },
        unethical_experimentation = { proceed = -12, refuse = 8 }
    }

    local modifier = decision_modifiers[decision_type]
    if modifier then
        delta = modifier[choice] or 0
    end

    return self:modify_karma(delta, "ethical_decision", string.format("%s_%s", decision_type, choice))
end

--- Get karma history
--- @param limit number|nil Maximum number of history entries to return
--- @return table Array of karma change history
function KarmaSystem:get_history(limit)
    limit = limit or #self.history
    local result = {}

    for i = math.max(1, #self.history - limit + 1), #self.history do
        table.insert(result, self.history[i])
    end

    return result
end

--- Get content access summary
--- @return table Content access information
function KarmaSystem:get_content_access()
    return {
        karma = self.karma,
        alignment = self.karma_alignment,
        available_suppliers = self:get_available_suppliers(),
        available_research = self:get_available_research(),
        available_missions = self:get_available_missions()
    }
end

--- Export karma system data
--- @param format string Export format (json, yaml, lua)
--- @return string Exported data
function KarmaSystem:export(format)
    local data = {
        karma = self.karma,
        karma_alignment = self.karma_alignment,
        history = self.history,
        last_update = self.last_update,
        content_access = self:get_content_access()
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

function KarmaSystem:_setup_event_listeners()
    -- Listen for mission completion events
    EventBus:subscribe("mission:completed", function(data)
        self:process_mission_karma(
            data.mission_type,
            data.success,
            data.civilian_casualties or 0,
            data.collateral_damage or false,
            data.hostage_rescue or false
        )
    end)

    -- Listen for interrogation events
    EventBus:subscribe("interrogation:completed", function(data)
        self:process_interrogation_karma(
            data.subject_type,
            data.method,
            data.outcome
        )
    end)

    -- Listen for equipment usage events
    EventBus:subscribe("equipment:used", function(data)
        self:process_equipment_karma(
            data.equipment_type,
            data.usage_context
        )
    end)

    -- Listen for ethical decisions
    EventBus:subscribe("decision:ethical_made", function(data)
        self:process_ethical_decision(
            data.decision_type,
            data.choice
        )
    end)
end

function KarmaSystem:_calculate_karma_alignment()
    for _, alignment in pairs(KARMA_ALIGNMENTS) do
        if self.karma >= alignment.min and self.karma <= alignment.max then
            return alignment.name
        end
    end
    return KARMA_ALIGNMENTS.NEUTRAL.name
end

function KarmaSystem:_to_json(data)
    return "JSON export not implemented - would use proper JSON library"
end

function KarmaSystem:_to_yaml(data)
    return "YAML export not implemented - would use proper YAML library"
end

function KarmaSystem:_serialize_table(tbl, indent)
    indent = indent or ""
    local result = "{\n"

    for key, value in pairs(tbl) do
        result = result .. indent .. "  " .. self:_serialize_key(key) .. " = " .. self:_serialize_value(value, indent .. "  ") .. ",\n"
    end

    result = result .. indent .. "}"
    return result
end

function KarmaSystem:_serialize_key(key)
    if type(key) == "string" then
        return '["' .. key .. '"]'
    else
        return '[' .. tostring(key) .. ']'
    end
end

function KarmaSystem:_serialize_value(value, indent)
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

return KarmaSystem
