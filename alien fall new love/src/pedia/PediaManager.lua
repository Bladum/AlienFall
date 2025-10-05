--- PediaManager class for Alien Fall game
-- Manages encyclopedia entries, categories, unlocks, and search functionality
-- @classmod PediaManager
-- @author Your Name
-- @license MIT
-- @copyright 2024 Alien Fall Team

local PediaManager = {}
PediaManager.__index = PediaManager

local PediaEntry = require 'pedia.PediaEntry'
local PediaCategory = require 'pedia.PediaCategory'
local EventBusClass = require("engine.event_bus")
local EventBus = EventBusClass.new()
local Registry = require("core.services.registry")

--- @class PediaManager
--- @field entries table Map of entry_id -> PediaEntry objects
--- @field categories table Map of category_id -> PediaCategory objects
--- @field category_entries table Map of category_id -> array of entry_ids
--- @field entry_categories table Map of entry_id -> category_id
--- @field search_index table Search index for fast text searching
--- @field unlock_queue table Queue of pending unlocks to process
--- @field game_state table Reference to current game state
--- @field config table Manager configuration settings

--- PediaManager constructor
--- @param config table Configuration options
--- @return PediaManager
function PediaManager.new(config)
    local self = setmetatable({}, PediaManager)
    self.entries = {}
    self.categories = {}
    self.category_entries = {}
    self.entry_categories = {}
    self.search_index = {}
    self.unlock_queue = {}
    self.game_state = nil
    self.config = config or {}

    -- Set default config
    self.config.search_fuzzy_match = self.config.search_fuzzy_match ~= false
    self.config.max_search_results = self.config.max_search_results or 50
    self.config.unlock_batch_size = self.config.unlock_batch_size or 10

    -- Subscribe to relevant events
    self:_setup_event_listeners()

    return self
end

--- Load pedia data from configuration files
--- @param entries_data table Array of entry data structures
--- @param categories_data table Array of category data structures
function PediaManager:load_data(entries_data, categories_data)
    -- Load categories first (needed for entry assignment)
    self:_load_categories(categories_data or {})
    self:_load_entries(entries_data or {})

    -- Build search index
    self:_build_search_index()

    -- Process any pending unlocks
    self:_process_unlock_queue()
end

--- Set current game state reference
--- @param game_state table Current game state
function PediaManager:set_game_state(game_state)
    self.game_state = game_state
    self:_process_unlock_queue()
end

--- Get an entry by ID
--- @param entry_id string Entry identifier
--- @return PediaEntry|nil The entry object or nil if not found
function PediaManager:get_entry(entry_id)
    return self.entries[entry_id]
end

--- Get a category by ID
--- @param category_id string Category identifier
--- @return PediaCategory|nil The category object or nil if not found
function PediaManager:get_category(category_id)
    return self.categories[category_id]
end

--- Get all entries in a category
--- @param category_id string Category identifier
--- @param include_subcategories boolean Whether to include subcategory entries
--- @return table Array of entry IDs
function PediaManager:get_category_entries(category_id, include_subcategories)
    local category = self:get_category(category_id)
    if not category then
        return {}
    end

    return category:get_all_entries(include_subcategories)
end

--- Get all categories
--- @return table Array of category IDs
function PediaManager:get_all_categories()
    local result = {}
    for id, _ in pairs(self.categories) do
        table.insert(result, id)
    end
    table.sort(result)
    return result
end

--- Get all entries
--- @return table Array of entry IDs
function PediaManager:get_all_entries()
    local result = {}
    for id, _ in pairs(self.entries) do
        table.insert(result, id)
    end
    table.sort(result)
    return result
end

--- Check if an entry is unlocked
--- @param entry_id string Entry identifier
--- @return boolean|nil True if entry is unlocked, nil if entry not found
function PediaManager:is_entry_unlocked(entry_id)
    local entry = self:get_entry(entry_id)
    return entry and entry:is_unlocked()
end

--- Check if a category is accessible
--- @param category_id string Category identifier
--- @return boolean|nil True if category is accessible, nil if category not found
function PediaManager:is_category_accessible(category_id)
    local category = self:get_category(category_id)
    return category and category:is_accessible(self.game_state)
end

--- Attempt to unlock an entry
--- @param entry_id string Entry identifier
--- @param unlock_source string Source of the unlock
--- @param seed number|nil Random seed for deterministic unlocks
--- @return boolean Success of unlock operation
function PediaManager:unlock_entry(entry_id, unlock_source, seed)
    local entry = self:get_entry(entry_id)
    if not entry then
        return false
    end

    local success = entry:unlock(unlock_source, self.game_state, seed)
    if success then
        -- Update search index for unlocked content
        self:_update_search_index(entry_id)

        -- Publish manager-level event
        EventBus:publish("pedia:manager_entry_unlocked", {
            entry_id = entry_id,
            category_id = self.entry_categories[entry_id],
            unlock_source = unlock_source
        })
    end

    return success
end

--- Attempt to unlock a category
--- @param category_id string Category identifier
--- @return boolean Success of unlock operation
function PediaManager:unlock_category(category_id)
    local category = self:get_category(category_id)
    if not category then
        return false
    end

    return category:unlock(self.game_state)
end

--- Search entries by text query
--- @param query string Search query
--- @param filters table Search filters (category, tags, spoiler_level, etc.)
--- @return table Array of matching entry IDs with relevance scores
function PediaManager:search(query, filters)
    filters = filters or {}

    -- Normalize query
    query = query:lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")

    if query == "" then
        return self:_get_filtered_entries(filters)
    end

    local results = {}
    local query_terms = self:_tokenize_query(query)

    -- Search through index
    for entry_id, index_data in pairs(self.search_index) do
        local entry = self:get_entry(entry_id)
        if entry and self:_matches_filters(entry, filters) then
            local score = self:_calculate_search_score(index_data, query_terms)
            if score > 0 then
                table.insert(results, {
                    entry_id = entry_id,
                    score = score,
                    category = self.entry_categories[entry_id]
                })
            end
        end
    end

    -- Sort by score (descending), then by entry ID (ascending)
    table.sort(results, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.entry_id < b.entry_id
    end)

    -- Limit results
    local max_results = filters.max_results or self.config.max_search_results
    if #results > max_results then
        local limited = {}
        for i = 1, max_results do
            table.insert(limited, results[i])
        end
        results = limited
    end

    -- Publish search event
    EventBus:publish("pedia:search_performed", {
        query = query,
        filters = filters,
        result_count = #results
    })

    return results
end

--- Get entries by category with filtering
--- @param category_id string Category identifier (nil for all categories)
--- @param filters table Additional filters
--- @return table Array of entry IDs
function PediaManager:get_entries_by_category(category_id, filters)
    filters = filters or {}
    filters.category = category_id

    return self:_get_filtered_entries(filters)
end

--- Process pending unlocks based on current game state
function PediaManager:process_unlocks()
    if not self.game_state then
        return
    end

    self:_process_unlock_queue()
end

--- Get pedia statistics
--- @return table Statistics about the pedia system
function PediaManager:get_statistics()
    local total_entries = 0
    local unlocked_entries = 0
    local total_categories = 0
    local accessible_categories = 0

    for _, entry in pairs(self.entries) do
        total_entries = total_entries + 1
        if entry:is_unlocked() then
            unlocked_entries = unlocked_entries + 1
        end
    end

    for _, category in pairs(self.categories) do
        total_categories = total_categories + 1
        if category:is_accessible(self.game_state) then
            accessible_categories = accessible_categories + 1
        end
    end

    return {
        total_entries = total_entries,
        unlocked_entries = unlocked_entries,
        locked_entries = total_entries - unlocked_entries,
        completion_percentage = total_entries > 0 and (unlocked_entries / total_entries) * 100 or 0,
        total_categories = total_categories,
        accessible_categories = accessible_categories,
        locked_categories = total_categories - accessible_categories
    }
end

--- Export pedia data for debugging or modding
--- @param format string Export format (json, yaml, lua)
--- @return string Exported data
function PediaManager:export(format)
    local data = {
        statistics = self:get_statistics(),
        entries = {},
        categories = {}
    }

    for id, entry in pairs(self.entries) do
        data.entries[id] = {
            id = id,
            title = entry.title,
            category = entry.category,
            unlocked = entry:is_unlocked(),
            current_stage = entry.current_stage,
            max_stages = #entry.stages
        }
    end

    for id, category in pairs(self.categories) do
        data.categories[id] = category:get_display_data(self.game_state)
    end

    if format == "json" then
        return self:_to_json(data)
    elseif format == "yaml" then
        return self:_to_yaml(data)
    else -- lua
        return "return " .. self:_serialize_table(data)
    end
end

-- Private methods

function PediaManager:_setup_event_listeners()
    -- Listen for game state changes that might trigger unlocks
    EventBus:subscribe("game:research_completed", function(data)
        self:_queue_unlock_check("research", data.tech_id)
    end)

    EventBus:subscribe("game:quest_completed", function(data)
        self:_queue_unlock_check("quest", data.quest_id)
    end)

    EventBus:subscribe("game:mission_completed", function(data)
        self:_queue_unlock_check("mission", data.mission_id)
    end)

    EventBus:subscribe("game:turn_advanced", function(data)
        self:_process_unlock_queue()
    end)
end

function PediaManager:_load_entries(entries_data)
    for _, entry_data in ipairs(entries_data) do
        local entry = PediaEntry(entry_data)
        self.entries[entry.id] = entry

        -- Assign to category
        if entry.category then
            self.entry_categories[entry.id] = entry.category
            if not self.category_entries[entry.category] then
                self.category_entries[entry.category] = {}
            end
            table.insert(self.category_entries[entry.category], entry.id)
        end
    end
end

function PediaManager:_load_categories(categories_data)
    -- First pass: create category objects
    for _, category_data in ipairs(categories_data) do
        local category = PediaCategory(category_data)
        self.categories[category.id] = category
    end

    -- Second pass: establish hierarchy
    for _, category in pairs(self.categories) do
        if category.parent_id then
            local parent = self.categories[category.parent_id]
            if parent then
                parent:add_subcategory(category.id)
            end
        end
    end
end

function PediaManager:_build_search_index()
    self.search_index = {}

    for entry_id, entry in pairs(self.entries) do
        self.search_index[entry_id] = {
            text = entry:get_search_text(),
            category = entry.category,
            tags = entry.tags,
            spoiler_level = entry.spoiler_level
        }
    end
end

function PediaManager:_update_search_index(entry_id)
    local entry = self:get_entry(entry_id)
    if entry then
        self.search_index[entry_id] = {
            text = entry:get_search_text(),
            category = entry.category,
            tags = entry.tags,
            spoiler_level = entry.spoiler_level
        }
    end
end

function PediaManager:_process_unlock_queue()
    if not self.game_state then
        return
    end

    local processed = 0
    local max_batch = self.config.unlock_batch_size

    -- Process entry unlocks
    for entry_id, entry in pairs(self.entries) do
        if processed >= max_batch then
            break
        end

        if not entry:is_unlocked() then
            local can_unlock, reason = entry:can_unlock(self.game_state)
            if can_unlock then
                self:unlock_entry(entry_id, "automatic", nil)
                processed = processed + 1
            end
        end
    end

    -- Process category unlocks
    for category_id, category in pairs(self.categories) do
        if not category.is_unlocked and category:is_accessible(self.game_state) then
            self:unlock_category(category_id)
        end
    end
end

function PediaManager:_queue_unlock_check(trigger_type, trigger_id)
    table.insert(self.unlock_queue, {
        type = trigger_type,
        id = trigger_id,
        timestamp = os.time()
    })
end

function PediaManager:_tokenize_query(query)
    local terms = {}
    for term in query:gmatch("%S+") do
        table.insert(terms, term)
    end
    return terms
end

function PediaManager:_calculate_search_score(index_data, query_terms)
    local score = 0
    local text = index_data.text

    for _, term in ipairs(query_terms) do
        -- Exact word match gets highest score
        local exact_matches = 0
        for word in text:gmatch("%S+") do
            if word == term then
                exact_matches = exact_matches + 1
            end
        end
        score = score + exact_matches * 10

        -- Partial match gets lower score
        if text:find(term, 1, true) then
            score = score + 5
        end

        -- Fuzzy match (if enabled)
        if self.config.search_fuzzy_match then
            -- Simple fuzzy matching - could be enhanced
            local fuzzy_score = self:_fuzzy_match_score(text, term)
            score = score + fuzzy_score
        end
    end

    return score
end

function PediaManager:_fuzzy_match_score(text, term)
    -- Simple fuzzy matching implementation
    if #term < 3 then
        return 0
    end

    local score = 0
    local term_chars = {}
    for i = 1, #term do
        term_chars[i] = term:sub(i, i)
    end

    for i, char in ipairs(term_chars) do
        if text:find(char, 1, true) then
            score = score + (1 / #term) -- Distribute score across characters
        end
    end

    return score >= 0.6 and score * 2 or 0 -- Require 60% character match
end

function PediaManager:_matches_filters(entry, filters)
    -- Category filter
    if filters.category and entry.category ~= filters.category then
        return false
    end

    -- Tag filters
    if filters.tags then
        for _, required_tag in ipairs(filters.tags) do
            local has_tag = false
            for _, entry_tag in ipairs(entry.tags) do
                if entry_tag == required_tag then
                    has_tag = true
                    break
                end
            end
            if not has_tag then
                return false
            end
        end
    end

    -- Spoiler level filter
    if filters.spoiler_level and entry.spoiler_level ~= filters.spoiler_level then
        return false
    end

    -- Unlock status filter
    if filters.unlocked_only and not entry:is_unlocked() then
        return false
    end

    return true
end

function PediaManager:_get_filtered_entries(filters)
    local results = {}

    for entry_id, entry in pairs(self.entries) do
        if self:_matches_filters(entry, filters) then
            table.insert(results, {
                entry_id = entry_id,
                score = 1, -- Default score for non-search results
                category = entry.category
            })
        end
    end

    -- Sort by entry ID
    table.sort(results, function(a, b) return a.entry_id < b.entry_id end)

    return results
end

function PediaManager:_to_json(data)
    return "JSON export not implemented - would use proper JSON library"
end

function PediaManager:_to_yaml(data)
    return "YAML export not implemented - would use proper YAML library"
end

function PediaManager:_serialize_table(tbl, indent)
    indent = indent or ""
    local result = "{\n"

    for key, value in pairs(tbl) do
        result = result .. indent .. "  " .. self:_serialize_key(key) .. " = " .. self:_serialize_value(value, indent .. "  ") .. ",\n"
    end

    result = result .. indent .. "}"
    return result
end

function PediaManager:_serialize_key(key)
    if type(key) == "string" then
        return '["' .. key .. '"]'
    else
        return '[' .. tostring(key) .. ']'
    end
end

function PediaManager:_serialize_value(value, indent)
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

return PediaManager
