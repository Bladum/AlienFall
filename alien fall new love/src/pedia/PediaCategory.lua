--- PediaCategory class for Alien Fall game
-- Manages content organization, taxonomy, and UI navigation for encyclopedia categories
-- @classmod PediaCategory
-- @author Your Name
-- @license MIT
-- @copyright 2024 Alien Fall Team

local class = require 'lib.Middleclass'

local PediaCategory = {}
PediaCategory.__index = PediaCategory

local EventBusClass = require 'engine.event_bus'
local EventBus = EventBusClass.new()

--- @class PediaCategory
--- @field id string Unique identifier for the category
--- @field name string Localization key for the category display name
--- @field description string Localization key for the category description
--- @field icon string Asset path for category icon
--- @field parent_id string|nil Parent category ID for hierarchical organization
--- @field subcategories table Array of subcategory IDs
--- @field entry_ids table Array of entry IDs belonging to this category
--- @field sort_order number Display order for UI navigation
--- @field tags table Array of tags associated with this category
--- @field unlock_conditions table Conditions required to access this category
--- @field is_unlocked boolean Whether the category is accessible to the player
--- @field view_count number Number of times this category has been viewed
--- @field last_viewed number Timestamp of last view

--- PediaCategory constructor
--- @param data table Configuration data for the category
--- @return PediaCategory
function PediaCategory.new(data)
    local self = setmetatable({}, PediaCategory)
    data = data or {}
    self.id = data.id or ""
    self.name = data.name or ""
    self.description = data.description or ""
    self.icon = data.icon or ""
    self.parent_id = data.parent_id or nil
    self.subcategories = data.subcategories or {}
    self.entry_ids = data.entry_ids or {}
    self.sort_order = data.sort_order or 0
    self.tags = data.tags or {}
    self.unlock_conditions = data.unlock_conditions or {}
    self.is_unlocked = false
    self.view_count = 0
    self.last_viewed = nil

    -- Validate required fields
    assert(self.id ~= "", "PediaCategory requires an id")
    assert(self.name ~= "", "PediaCategory requires a name")

    -- Initialize subcategory hierarchy
    self._children = {}
    self._parent = nil

    return self
end

--- Check if category is unlocked based on game state
--- @param game_state table Current game state
--- @return boolean True if category is accessible
function PediaCategory:is_accessible(game_state)
    if self.is_unlocked then
        return true
    end

    -- Check unlock conditions
    local conditions = self.unlock_conditions or {}

    -- Research completion check
    if conditions.tech_id and not self:_has_research(conditions.tech_id, game_state) then
        return false
    end

    -- Quest completion check
    if conditions.quest_id and not self:_has_completed_quest(conditions.quest_id, game_state) then
        return false
    end

    -- Flag condition checks
    if conditions.condition_flags then
        for _, flag in ipairs(conditions.condition_flags) do
            if not self:_has_flag(flag, game_state) then
                return false
            end
        end
    end

    -- Entry count requirements
    if conditions.min_entries_unlocked then
        local unlocked_count = self:_count_unlocked_entries(game_state)
        if unlocked_count < conditions.min_entries_unlocked then
            return false
        end
    end

    return true
end

--- Unlock the category
--- @param game_state table Current game state
--- @return boolean Success of unlock operation
function PediaCategory:unlock(game_state)
    if self.is_accessible(game_state) and not self.is_unlocked then
        self.is_unlocked = true

        -- Publish unlock event
        EventBus:publish("pedia:category_unlocked", {
            category_id = self.id,
            unlock_timestamp = os.time()
        })

        return true
    end

    return false
end

--- Record a category view for analytics
--- @param viewer_context table Context information about the view
function PediaCategory:record_view(viewer_context)
    self.view_count = self.view_count + 1
    self.last_viewed = os.time()

    -- Publish view event
    EventBus:publish("pedia:category_viewed", {
        category_id = self.id,
        view_count = self.view_count,
        context = viewer_context or {}
    })
end

--- Add an entry to this category
--- @param entry_id string ID of the entry to add
--- @return boolean Success of addition
function PediaCategory:add_entry(entry_id)
    if not self:_has_entry(entry_id) then
        table.insert(self.entry_ids, entry_id)
        return true
    end
    return false
end

--- Remove an entry from this category
--- @param entry_id string ID of the entry to remove
--- @return boolean Success of removal
function PediaCategory:remove_entry(entry_id)
    for i, id in ipairs(self.entry_ids) do
        if id == entry_id then
            table.remove(self.entry_ids, i)
            return true
        end
    end
    return false
end

--- Add a subcategory
--- @param subcategory_id string ID of the subcategory to add
--- @return boolean Success of addition
function PediaCategory:add_subcategory(subcategory_id)
    if not self:_has_subcategory(subcategory_id) then
        table.insert(self.subcategories, subcategory_id)
        return true
    end
    return false
end

--- Remove a subcategory
--- @param subcategory_id string ID of the subcategory to remove
--- @return boolean Success of removal
function PediaCategory:remove_subcategory(subcategory_id)
    for i, id in ipairs(self.subcategories) do
        if id == subcategory_id then
            table.remove(self.subcategories, i)
            return true
        end
    end
    return false
end

--- Get all entries in this category and subcategories (recursive)
--- @param include_subcategories boolean Whether to include entries from subcategories
--- @return table Array of all entry IDs
function PediaCategory:get_all_entries(include_subcategories)
    local entries = {}

    -- Add direct entries
    for _, entry_id in ipairs(self.entry_ids) do
        table.insert(entries, entry_id)
    end

    -- Add subcategory entries if requested
    if include_subcategories then
        for _, subcategory_id in ipairs(self.subcategories) do
            -- Note: This would need category manager to resolve subcategory objects
            -- For now, return direct entries only
        end
    end

    return entries
end

--- Get category statistics
--- @param game_state table Current game state for entry status
--- @return table Statistics about the category
function PediaCategory:get_statistics(game_state)
    local total_entries = #self.entry_ids
    local unlocked_entries = self:_count_unlocked_entries(game_state)
    local completion_percentage = total_entries > 0 and (unlocked_entries / total_entries) * 100 or 0

    return {
        total_entries = total_entries,
        unlocked_entries = unlocked_entries,
        locked_entries = total_entries - unlocked_entries,
        completion_percentage = completion_percentage,
        subcategory_count = #self.subcategories,
        view_count = self.view_count,
        last_viewed = self.last_viewed,
        is_unlocked = self.is_unlocked
    }
end

--- Get display data for UI rendering
--- @param game_state table Current game state
--- @return table Display-ready data structure
function PediaCategory:get_display_data(game_state)
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        icon = self.icon,
        parent_id = self.parent_id,
        subcategories = self.subcategories,
        entry_count = #self.entry_ids,
        sort_order = self.sort_order,
        tags = self.tags,
        is_unlocked = self.is_unlocked,
        is_accessible = self:is_accessible(game_state),
        statistics = self:get_statistics(game_state)
    }
end

--- Search entries within this category
--- @param query string Search query
--- @param game_state table Current game state
--- @return table Array of matching entry IDs
function PediaCategory:search_entries(query, game_state)
    -- This would need access to entry objects to perform actual search
    -- For now, return all accessible entries (would be filtered by manager)
    local results = {}

    for _, entry_id in ipairs(self.entry_ids) do
        -- Placeholder - actual search would check entry content
        table.insert(results, entry_id)
    end

    return results
end

--- Export category data for debugging or modding
--- @param format string Export format (json, yaml, lua)
--- @return string Exported data
function PediaCategory:export(format)
    local data = {
        id = self.id,
        name = self.name,
        description = self.description,
        icon = self.icon,
        parent_id = self.parent_id,
        subcategories = self.subcategories,
        entry_ids = self.entry_ids,
        sort_order = self.sort_order,
        tags = self.tags,
        unlock_conditions = self.unlock_conditions,
        is_unlocked = self.is_unlocked,
        view_count = self.view_count,
        last_viewed = self.last_viewed
    }

    if format == "json" then
        return self:_to_json(data)
    elseif format == "yaml" then
        return self:_to_yaml(data)
    else -- lua
        return "return " .. self:_serialize_table(data)
    end
end

-- Private helper methods

function PediaCategory:_has_research(tech_id, game_state)
    local research_system = game_state.research or {}
    return research_system.completed and research_system.completed[tech_id]
end

function PediaCategory:_has_completed_quest(quest_id, game_state)
    local quest_system = game_state.quests or {}
    return quest_system.completed and quest_system.completed[quest_id]
end

function PediaCategory:_has_flag(flag, game_state)
    local flags = game_state.condition_flags or {}
    return flags[flag] == true
end

function PediaCategory:_count_unlocked_entries(game_state)
    -- Placeholder - would need access to entry manager to check unlock status
    -- For now, assume all entries are unlocked if category is accessible
    return self.is_unlocked and #self.entry_ids or 0
end

function PediaCategory:_has_entry(entry_id)
    for _, id in ipairs(self.entry_ids) do
        if id == entry_id then
            return true
        end
    end
    return false
end

function PediaCategory:_has_subcategory(subcategory_id)
    for _, id in ipairs(self.subcategories) do
        if id == subcategory_id then
            return true
        end
    end
    return false
end

function PediaCategory:_to_json(data)
    return "JSON export not implemented - would use proper JSON library"
end

function PediaCategory:_to_yaml(data)
    return "YAML export not implemented - would use proper YAML library"
end

function PediaCategory:_serialize_table(tbl, indent)
    indent = indent or ""
    local result = "{\n"

    for key, value in pairs(tbl) do
        result = result .. indent .. "  " .. self:_serialize_key(key) .. " = " .. self:_serialize_value(value, indent .. "  ") .. ",\n"
    end

    result = result .. indent .. "}"
    return result
end

function PediaCategory:_serialize_key(key)
    if type(key) == "string" then
        return '["' .. key .. '"]'
    else
        return '[' .. tostring(key) .. ']'
    end
end

function PediaCategory:_serialize_value(value, indent)
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

return PediaCategory
