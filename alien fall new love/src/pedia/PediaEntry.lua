--- PediaEntry class for Alien Fall game
-- Represents individual encyclopedia entries with unlock conditions, provenance tracking, and staged reveals
-- @classmod PediaEntry
-- @author Your Name
-- @license MIT
-- @copyright 2024 Alien Fall Team

local PediaEntry = {}
PediaEntry.__index = PediaEntry

local EventBusClass = require 'engine.event_bus'
local EventBus = EventBusClass.new()

--- @class PediaEntry
--- @field id string Unique identifier for the entry
--- @field title string Localization key for the entry title
--- @field description string Localization key for the entry description
--- @field category string Entry category (unit, item, craft, facility, mission, lore, mechanic, tutorial)
--- @field tags table Array of tags for search and filtering
--- @field unlock_conditions table Unlock requirements and conditions
--- @field provenance table Unlock provenance and tracking information
--- @field images table Asset references for thumbnails and images
--- @field tabs table Ordered list of tabs for UI display
--- @field table_data table Key-value pairs for compact info display
--- @field related_entries table Array of related entry IDs
--- @field hooks table Event hooks for telemetry and analytics
--- @field spoiler_level string Spoiler level (public, restricted, classified)
--- @field stages table Staged reveal information for complex entries
--- @field current_stage number Current unlock stage (0 = locked, 1+ = unlocked stages)

--- PediaEntry constructor
--- @param data table YAML data structure for the entry
--- @return PediaEntry
function PediaEntry.new(data)
    local self = setmetatable({}, PediaEntry)
    data = data or {}
    self.id = data.id or ""
    self.title = data.title or ""
    self.description = data.description or ""
    self.category = data.category or "misc"
    self.tags = data.tags or {}
    self.unlock_conditions = data.unlock or {}
    self.provenance = data.provenance or {}
    self.images = data.images or {}
    self.tabs = data.tabs or {"Overview"}
    self.table_data = data.table or {}
    self.related_entries = data.related_entries or {}
    self.hooks = data.hooks or {}
    self.spoiler_level = data.spoiler_level or "public"
    self.stages = data.stages or {}
    self.current_stage = 0

    -- Validate required fields
    assert(self.id ~= "", "PediaEntry requires an id")
    assert(self.title ~= "", "PediaEntry requires a title")

    -- Initialize provenance tracking
    if not self.provenance.unlocked_by then
        self.provenance.unlocked_by = nil
        self.provenance.seed_locked = false
        self.provenance.unlock_timestamp = nil
        self.provenance.debug_info = {}
    end

    return self
end

--- Check if entry is unlocked
--- @return boolean True if entry is accessible to player
function PediaEntry:is_unlocked()
    return self.current_stage > 0
end

--- Check if entry can be unlocked based on current game state
--- @param game_state table Current game state for condition checking
--- @return boolean, string True if unlockable, plus reason if not
function PediaEntry:can_unlock(game_state)
    if self:is_unlocked() then
        return true, "Already unlocked"
    end

    -- Check unlock conditions
    local conditions = self.unlock_conditions

    -- Research completion check
    if conditions.tech_id and not self:_has_research(conditions.tech_id, game_state) then
        return false, "Research not completed: " .. conditions.tech_id
    end

    -- Quest completion check
    if conditions.quest_id and not self:_has_completed_quest(conditions.quest_id, game_state) then
        return false, "Quest not completed: " .. conditions.quest_id
    end

    -- Flag condition checks
    if conditions.condition_flags then
        for _, flag in ipairs(conditions.condition_flags) do
            if not self:_has_flag(flag, game_state) then
                return false, "Condition not met: " .. flag
            end
        end
    end

    -- Stage-specific conditions for multi-stage entries
    if #self.stages > 0 then
        local next_stage = self.current_stage + 1
        if next_stage <= #self.stages then
            local stage_conditions = self.stages[next_stage].unlock
            if stage_conditions then
                return self:_check_conditions(stage_conditions, game_state)
            end
        end
    end

    return true, "Ready to unlock"
end

--- Unlock the entry or advance to next stage
--- @param unlock_source string Source of the unlock (research, quest, event, etc.)
--- @param game_state table Current game state
--- @param seed number|nil Random seed for deterministic unlocks
--- @return boolean Success of unlock operation
function PediaEntry:unlock(unlock_source, game_state, seed)
    local can_unlock, reason = self:can_unlock(game_state)
    if not can_unlock then
        return false
    end

    -- Determine unlock stage
    local new_stage = 1
    if #self.stages > 0 then
        new_stage = self.current_stage + 1
        if new_stage > #self.stages then
            return false -- All stages already unlocked
        end
    end

    -- Update provenance
    self.provenance.unlocked_by = unlock_source
    self.provenance.seed_locked = (seed ~= nil)
    self.provenance.unlock_timestamp = os.time()
    self.provenance.debug_info.unlock_seed = seed
    self.provenance.debug_info.game_state_snapshot = self:_create_state_snapshot(game_state)

    -- Advance stage
    self.current_stage = new_stage

    -- Fire unlock hook
    if self.hooks.on_unlock then
        EventBus:publish("pedia:entry_unlocked", {
            entry_id = self.id,
            stage = self.current_stage,
            source = unlock_source,
            provenance = self.provenance
        })
    end

    return true
end

--- Get current stage data for multi-stage entries
--- @return table|nil Current stage information or nil if single-stage
function PediaEntry:get_current_stage_data()
    if #self.stages == 0 or self.current_stage == 0 then
        return nil
    end

    return self.stages[self.current_stage]
end

--- Get display data for UI rendering
--- @return table Display-ready data structure
function PediaEntry:get_display_data()
    local stage_data = self:get_current_stage_data()

    return {
        id = self.id,
        title = self.title,
        description = self.description,
        category = self.category,
        tags = self.tags,
        images = self.images,
        tabs = self.tabs,
        table_data = self.table_data,
        related_entries = self.related_entries,
        spoiler_level = self.spoiler_level,
        current_stage = self.current_stage,
        max_stages = #self.stages,
        stage_data = stage_data,
        provenance = self.provenance,
        is_unlocked = self:is_unlocked()
    }
end

--- Get searchable text content
--- @return string Combined text for search indexing
function PediaEntry:get_search_text()
    local texts = {self.title, self.description}

    -- Add table data values
    for key, value in pairs(self.table_data) do
        table.insert(texts, tostring(key))
        table.insert(texts, tostring(value))
    end

    -- Add tags
    for _, tag in ipairs(self.tags) do
        table.insert(texts, tag)
    end

    -- Add stage-specific content if unlocked
    local stage_data = self:get_current_stage_data()
    if stage_data then
        if stage_data.description then
            table.insert(texts, stage_data.description)
        end
        if stage_data.table then
            for key, value in pairs(stage_data.table) do
                table.insert(texts, tostring(key))
                table.insert(texts, tostring(value))
            end
        end
    end

    return table.concat(texts, " "):lower()
end

--- Export entry data for debugging or modding
--- @param format string Export format (json, yaml, lua)
--- @return string Exported data
function PediaEntry:export(format)
    local data = {
        id = self.id,
        title = self.title,
        description = self.description,
        category = self.category,
        tags = self.tags,
        unlock_conditions = self.unlock_conditions,
        provenance = self.provenance,
        images = self.images,
        tabs = self.tabs,
        table_data = self.table_data,
        related_entries = self.related_entries,
        hooks = self.hooks,
        spoiler_level = self.spoiler_level,
        stages = self.stages,
        current_stage = self.current_stage
    }

    if format == "json" then
        return self:_to_json(data)
    elseif format == "yaml" then
        return self:_to_yaml(data)
    else -- lua
        return self:_to_lua(data)
    end
end

-- Private helper methods

function PediaEntry:_has_research(tech_id, game_state)
    -- Check if research is completed
    local research_system = game_state.research or {}
    return research_system.completed and research_system.completed[tech_id]
end

function PediaEntry:_has_completed_quest(quest_id, game_state)
    -- Check if quest is completed
    local quest_system = game_state.quests or {}
    return quest_system.completed and quest_system.completed[quest_id]
end

function PediaEntry:_has_flag(flag, game_state)
    -- Check if condition flag is set
    local flags = game_state.condition_flags or {}
    return flags[flag] == true
end

function PediaEntry:_check_conditions(conditions, game_state)
    -- Generic condition checking logic
    if conditions.tech_id and not self:_has_research(conditions.tech_id, game_state) then
        return false, "Research not completed: " .. conditions.tech_id
    end

    if conditions.quest_id and not self:_has_completed_quest(conditions.quest_id, game_state) then
        return false, "Quest not completed: " .. conditions.quest_id
    end

    if conditions.condition_flags then
        for _, flag in ipairs(conditions.condition_flags) do
            if not self:_has_flag(flag, game_state) then
                return false, "Condition not met: " .. flag
            end
        end
    end

    return true, "Conditions met"
end

function PediaEntry:_create_state_snapshot(game_state)
    -- Create a lightweight snapshot for debugging
    return {
        turn = game_state.turn,
        research_count = game_state.research and #game_state.research.completed or 0,
        quest_count = game_state.quests and #game_state.quests.completed or 0,
        flag_count = game_state.condition_flags and #game_state.condition_flags or 0
    }
end

function PediaEntry:_to_json(data)
    -- Simple JSON export (would use proper JSON library in real implementation)
    return "JSON export not implemented - would use proper JSON library"
end

function PediaEntry:_to_yaml(data)
    -- Simple YAML export (would use proper YAML library in real implementation)
    return "YAML export not implemented - would use proper YAML library"
end

function PediaEntry:_to_lua(data)
    -- Lua table export
    return "return " .. self:_serialize_table(data)
end

function PediaEntry:_serialize_table(tbl, indent)
    indent = indent or ""
    local result = "{\n"

    for key, value in pairs(tbl) do
        result = result .. indent .. "  " .. self:_serialize_key(key) .. " = " .. self:_serialize_value(value, indent .. "  ") .. ",\n"
    end

    result = result .. indent .. "}"
    return result
end

function PediaEntry:_serialize_key(key)
    if type(key) == "string" then
        return '["' .. key .. '"]'
    else
        return '[' .. tostring(key) .. ']'
    end
end

function PediaEntry:_serialize_value(value, indent)
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

return PediaEntry
