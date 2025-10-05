--- PediaService.lua
-- Pedia service for Alien Fall knowledge base
-- Manages encyclopedia entries, unlock system, search, and narrative integration

local class = require 'lib.Middleclass'
local PediaEntry = require 'pedia.PediaEntry'
local PediaCategory = require 'pedia.PediaCategory'

--- PediaService class
-- @type PediaService
PediaService = class('PediaService')

--- Entry types enumeration
PediaService.ENTRY_TYPES = {
    UNIT = "unit",
    ITEM = "item",
    CRAFT = "craft",
    FACILITY = "facility",
    MISSION = "mission",
    LORE = "lore",
    MECHANIC = "mechanic",
    TUTORIAL = "tutorial"
}

--- Spoiler levels enumeration
PediaService.SPOILER_LEVELS = {
    PUBLIC = "public",
    RESTRICTED = "restricted",
    CLASSIFIED = "classified"
}

--- Create a new PediaService instance
-- @param registry Service registry for accessing other systems
-- @return PediaService instance
function PediaService:initialize(registry)
    self.registry = registry

    -- Entry management
    self.entries = {} -- entry_id -> PediaEntry instance
    self.categories = {} -- category_id -> PediaCategory instance
    self.categoryEntries = {} -- category_id -> {entry_id -> true}

    -- Unlock system
    self.unlockedEntries = {} -- entry_id -> unlock_data
    self.pendingUnlocks = {} -- Queue of entries waiting to be unlocked

    -- Search index
    self.searchIndex = {} -- word -> {entry_id -> true}

    -- Configuration
    self.config = {
        fuzzyMatch = true,
        maxSearchResults = 50,
        unlockBatchSize = 10
    }

    -- Load pedia data
    self:_loadPediaData()

    -- Note: Service registration is handled by ServiceRegistry
end

--- Load pedia-related data from data files
function PediaService:_loadPediaData()
    if not self.registry then return end

    local dataRegistry = self.registry:resolve('data_registry')
    if not dataRegistry then return end

    -- Load categories
    self:_loadCategories(dataRegistry)

    -- Load entries
    self:_loadEntries(dataRegistry)

    -- Load unlocks
    self:_loadUnlocks(dataRegistry)

    -- Build search index
    self:_buildSearchIndex()
end

--- Load pedia categories
function PediaService:_loadCategories(dataRegistry)
    local categories = dataRegistry:get('pedia', 'categories') or {}

    for _, categoryData in ipairs(categories) do
        local category = PediaCategory(categoryData)
        self.categories[category.id] = category
        self.categoryEntries[category.id] = {}
    end

    -- Create default categories if not loaded
    local defaultCategories = {
        {id = "unit", name = "Units", description = "Soldier classes and equipment"},
        {id = "item", name = "Items", description = "Weapons, armor, and equipment"},
        {id = "craft", name = "Crafts", description = "Aircraft and vehicles"},
        {id = "facility", name = "Facilities", description = "Base buildings and installations"},
        {id = "mission", name = "Missions", description = "Mission types and objectives"},
        {id = "lore", name = "Lore", description = "Story and background information"},
        {id = "mechanic", name = "Mechanics", description = "Game systems and rules"},
        {id = "tutorial", name = "Tutorials", description = "How-to guides and tips"}
    }

    for _, categoryData in ipairs(defaultCategories) do
        if not self.categories[categoryData.id] then
            local category = PediaCategory.new(categoryData)
            self.categories[category.id] = category
            self.categoryEntries[category.id] = {}
        end
    end
end

--- Load pedia entries
function PediaService:_loadEntries(dataRegistry)
    local entries = dataRegistry:get('pedia', 'entries') or {}

    for _, entryData in ipairs(entries) do
        local entry = PediaEntry(entryData)
        self.entries[entry.id] = entry

        -- Add to category
        if entry.category and self.categoryEntries[entry.category] then
            self.categoryEntries[entry.category][entry.id] = true
        end
    end
end

--- Load unlock conditions
function PediaService:_loadUnlocks(dataRegistry)
    local unlocks = dataRegistry:get('pedia', 'unlocks') or {}

    for _, unlockData in ipairs(unlocks) do
        -- Store unlock conditions for each entry
        if unlockData.entry_id and self.entries[unlockData.entry_id] then
            self.entries[unlockData.entry_id].unlockConditions = unlockData.conditions
        end
    end
end

--- Build search index for fast text searching
function PediaService:_buildSearchIndex()
    self.searchIndex = {}

    for entryId, entry in pairs(self.entries) do
        local searchableText = string.lower(entry.title .. " " .. (entry.summary or "") .. " " .. table.concat(entry.tags or {}, " "))

        -- Tokenize and index
        for word in string.gmatch(searchableText, "%w+") do
            if not self.searchIndex[word] then
                self.searchIndex[word] = {}
            end
            self.searchIndex[word][entryId] = true
        end
    end
end

--- Get entry by ID
-- @param entryId The entry ID
-- @return PediaEntry instance or nil
function PediaService:getEntry(entryId)
    return self.entries[entryId]
end

--- Get category by ID
-- @param categoryId The category ID
-- @return PediaCategory instance or nil
function PediaService:getCategory(categoryId)
    return self.categories[categoryId]
end

--- Get all entries
-- @return Table of all entries (id -> entry)
function PediaService:getAllEntries()
    return self.entries
end

--- Get all categories
-- @return Table of all categories (id -> category)
function PediaService:getAllCategories()
    return self.categories
end

--- Get entries in category
-- @param categoryId The category ID
-- @return Array of entry IDs in the category
function PediaService:getEntriesInCategory(categoryId)
    local entries = {}
    if self.categoryEntries[categoryId] then
        for entryId, _ in pairs(self.categoryEntries[categoryId]) do
            table.insert(entries, entryId)
        end
    end
    return entries
end

--- Check if entry is unlocked
-- @param entryId The entry ID
-- @return is_unlocked, unlock_data
function PediaService:isEntryUnlocked(entryId)
    return self.unlockedEntries[entryId] ~= nil, self.unlockedEntries[entryId]
end

--- Unlock entry
-- @param entryId The entry ID
-- @param unlockSource The source of the unlock (research, encounter, etc.)
-- @param unlockData Additional unlock data
-- @return success, reason
function PediaService:unlockEntry(entryId, unlockSource, unlockData)
    local entry = self.entries[entryId]
    if not entry then
        return false, "Entry not found"
    end

    if self:isEntryUnlocked(entryId) then
        return false, "Entry already unlocked"
    end

    -- Check unlock conditions
    if not self:_checkUnlockConditions(entry, unlockSource, unlockData) then
        return false, "Unlock conditions not met"
    end

    -- Unlock the entry
    self.unlockedEntries[entryId] = {
        unlocked_at = os.time(),
        unlock_source = unlockSource,
        unlock_data = unlockData or {}
    }

    -- Fire unlock event
    self:_fireEvent('pedia:entry_unlocked', {
        entry_id = entryId,
        entry = entry,
        unlock_source = unlockSource,
        unlock_data = unlockData
    })

    return true
end

--- Check if unlock conditions are met
function PediaService:_checkUnlockConditions(entry, unlockSource, unlockData)
    if not entry.unlockConditions then
        return true -- No conditions = always available
    end

    local conditions = entry.unlockConditions

    -- Check research requirements
    if conditions.research_required then
        -- Would need to check with research service
        -- For now, assume available
    end

    -- Check encounter requirements
    if conditions.encounter_required then
        if unlockSource ~= "encounter" then
            return false
        end
    end

    -- Check mission requirements
    if conditions.mission_required then
        if unlockSource ~= "mission" then
            return false
        end
    end

    -- Check item analysis requirements
    if conditions.analysis_required then
        if unlockSource ~= "analysis" then
            return false
        end
    end

    return true
end

--- Get unlocked entries
-- @param category Optional category filter
-- @return Array of unlocked entry IDs
function PediaService:getUnlockedEntries(category)
    local unlocked = {}

    for entryId, _ in pairs(self.unlockedEntries) do
        local entry = self.entries[entryId]
        if entry and (not category or entry.category == category) then
            table.insert(unlocked, entryId)
        end
    end

    return unlocked
end

--- Search entries
-- @param query The search query
-- @param category Optional category filter
-- @param tags Optional tag filters
-- @return Array of matching entry IDs with relevance scores
function PediaService:searchEntries(query, category, tags)
    local results = {}
    local queryWords = {}

    -- Tokenize query
    for word in string.gmatch(string.lower(query), "%w+") do
        table.insert(queryWords, word)
    end

    if #queryWords == 0 then
        return results
    end

    -- Score entries
    local scores = {}

    for _, word in ipairs(queryWords) do
        local wordMatches = self.searchIndex[word]
        if wordMatches then
            for entryId, _ in pairs(wordMatches) do
                local entry = self.entries[entryId]
                if entry and self:isEntryUnlocked(entryId) and
                   (not category or entry.category == category) and
                   (not tags or self:_matchesTags(entry, tags)) then

                    scores[entryId] = (scores[entryId] or 0) + 1
                end
            end
        end
    end

    -- Convert to sorted results
    for entryId, score in pairs(scores) do
        table.insert(results, {id = entryId, score = score})
    end

    table.sort(results, function(a, b) return a.score > b.score end)

    -- Limit results
    if #results > self.config.maxSearchResults then
        local limited = {}
        for i = 1, self.config.maxSearchResults do
            table.insert(limited, results[i])
        end
        results = limited
    end

    return results
end

--- Check if entry matches tag filters
function PediaService:_matchesTags(entry, requiredTags)
    if not entry.tags then return false end

    for _, requiredTag in ipairs(requiredTags) do
        local found = false
        for _, entryTag in ipairs(entry.tags) do
            if entryTag == requiredTag then
                found = true
                break
            end
        end
        if not found then
            return false
        end
    end

    return true
end

--- Get related entries
-- @param entryId The entry ID
-- @return Array of related entry IDs
function PediaService:getRelatedEntries(entryId)
    local entry = self.entries[entryId]
    if not entry or not entry.relatedEntries then
        return {}
    end

    local related = {}
    for _, relatedId in ipairs(entry.relatedEntries) do
        if self:isEntryUnlocked(relatedId) then
            table.insert(related, relatedId)
        end
    end

    return related
end

--- Process pending unlocks
-- @param gameState Current game state for checking conditions
function PediaService:processPendingUnlocks(gameState)
    local processed = 0

    for entryId, unlockData in pairs(self.pendingUnlocks) do
        if self:_checkUnlockConditions(self.entries[entryId], unlockData.source, unlockData.data) then
            self:unlockEntry(entryId, unlockData.source, unlockData.data)
            self.pendingUnlocks[entryId] = nil
            processed = processed + 1

            if processed >= self.config.unlockBatchSize then
                break
            end
        end
    end

    return processed
end

--- Queue entry for unlock checking
-- @param entryId The entry ID
-- @param unlockSource The unlock source
-- @param unlockData Additional data
function PediaService:queueForUnlock(entryId, unlockSource, unlockData)
    self.pendingUnlocks[entryId] = {
        source = unlockSource,
        data = unlockData or {},
        queued_at = os.time()
    }
end

--- Get pedia statistics
-- @return Statistics table
function PediaService:getStats()
    local totalEntries = 0
    local unlockedEntries = 0
    local categoryStats = {}

    for _, entry in pairs(self.entries) do
        totalEntries = totalEntries + 1
        if self:isEntryUnlocked(entry.id) then
            unlockedEntries = unlockedEntries + 1
        end

        categoryStats[entry.category] = (categoryStats[entry.category] or 0) + 1
    end

    return {
        total_entries = totalEntries,
        unlocked_entries = unlockedEntries,
        unlock_percentage = totalEntries > 0 and (unlockedEntries / totalEntries * 100) or 0,
        categories = categoryStats,
        pending_unlocks = #self.pendingUnlocks
    }
end

--- Fire an event through the event bus
function PediaService:_fireEvent(eventType, data)
    if self.registry then
        local eventBus = self.registry:getService('eventBus')
        if eventBus then
            eventBus:fire(eventType, data)
        end
    end
end

--- Save pedia service state
-- @return Serializable state data
function PediaService:saveState()
    return {
        unlockedEntries = self.unlockedEntries,
        pendingUnlocks = self.pendingUnlocks,
        config = self.config
    }
end

--- Load pedia service state
-- @param state Saved state data
function PediaService:loadState(state)
    self.unlockedEntries = state.unlockedEntries or {}
    self.pendingUnlocks = state.pendingUnlocks or {}
    self.config = state.config or self.config
end

--- Convert to string representation
-- @return String representation
function PediaService:__tostring()
    local stats = self:getStats()
    return string.format("PediaService{entries=%d/%d unlocked, categories=%d}",
                        stats.unlocked_entries, stats.total_entries, #self.categories)
end

return PediaService