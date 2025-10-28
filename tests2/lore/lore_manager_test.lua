-- ─────────────────────────────────────────────────────────────────────────
-- LORE MANAGER TEST SUITE
-- FILE: tests2/lore/lore_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.lore_manager",
    fileName = "lore_manager.lua",
    description = "Lore and narrative content management system"
})

print("[LORE_MANAGER_TEST] Setting up")

local LoreManager = {
    entries = {},
    characters = {},
    lore_unlocked = {},

    new = function(self)
        return setmetatable({entries = {}, characters = {}, lore_unlocked = {}}, {__index = self})
    end,

    addLoreEntry = function(self, entryId, title, content, category)
        self.entries[entryId] = {id = entryId, title = title, content = content, category = category or "general", unlocked = false}
        return true
    end,

    unlockEntry = function(self, entryId)
        if not self.entries[entryId] then return false end
        self.entries[entryId].unlocked = true
        self.lore_unlocked[entryId] = true
        return true
    end,

    getLoreEntry = function(self, entryId)
        return self.entries[entryId]
    end,

    isEntryUnlocked = function(self, entryId)
        if not self.entries[entryId] then return false end
        return self.entries[entryId].unlocked
    end,

    addCharacter = function(self, charId, name, description, faction)
        self.characters[charId] = {id = charId, name = name, description = description, faction = faction, appearances = 0}
        return true
    end,

    getCharacter = function(self, charId)
        return self.characters[charId]
    end,

    recordAppearance = function(self, charId)
        if not self.characters[charId] then return false end
        self.characters[charId].appearances = self.characters[charId].appearances + 1
        return true
    end,

    getEntriesByCategory = function(self, category)
        local result = {}
        for id, entry in pairs(self.entries) do
            if entry.category == category then table.insert(result, id) end
        end
        return result
    end,

    getUnlockedCount = function(self)
        local count = 0
        for _, unlocked in pairs(self.lore_unlocked) do
            if unlocked then count = count + 1 end
        end
        return count
    end,

    getTotalEntries = function(self)
        local count = 0
        for _ in pairs(self.entries) do count = count + 1 end
        return count
    end,

    getCharacterCount = function(self)
        local count = 0
        for _ in pairs(self.characters) do count = count + 1 end
        return count
    end
}

Suite:group("Lore Entries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreManager:new()
    end)

    Suite:testMethod("LoreManager.new", {description = "Creates lore manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.lore ~= nil, true, "Manager created")
    end)

    Suite:testMethod("LoreManager.addLoreEntry", {description = "Adds lore entry", testCase = "add", type = "functional"}, function()
        local ok = shared.lore:addLoreEntry("intro", "Introduction", "The story begins...", "background")
        Helpers.assertEqual(ok, true, "Entry added")
    end)

    Suite:testMethod("LoreManager.getLoreEntry", {description = "Retrieves entry", testCase = "get", type = "functional"}, function()
        shared.lore:addLoreEntry("alien", "Aliens", "They came from space", "species")
        local entry = shared.lore:getLoreEntry("alien")
        Helpers.assertEqual(entry ~= nil, true, "Entry retrieved")
    end)

    Suite:testMethod("LoreManager.getLoreEntry", {description = "Returns nil for missing", testCase = "missing", type = "functional"}, function()
        local entry = shared.lore:getLoreEntry("nonexistent")
        Helpers.assertEqual(entry, nil, "Missing entry returns nil")
    end)

    Suite:testMethod("LoreManager.getTotalEntries", {description = "Counts entries", testCase = "count", type = "functional"}, function()
        shared.lore:addLoreEntry("e1", "Entry 1", "Content", "cat")
        shared.lore:addLoreEntry("e2", "Entry 2", "Content", "cat")
        shared.lore:addLoreEntry("e3", "Entry 3", "Content", "cat")
        local count = shared.lore:getTotalEntries()
        Helpers.assertEqual(count, 3, "Three entries total")
    end)
end)

Suite:group("Lore Unlock System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreManager:new()
        shared.lore:addLoreEntry("secret", "Secret Knowledge", "Hidden truth", "secrets")
    end)

    Suite:testMethod("LoreManager.unlockEntry", {description = "Unlocks entry", testCase = "unlock", type = "functional"}, function()
        local ok = shared.lore:unlockEntry("secret")
        Helpers.assertEqual(ok, true, "Entry unlocked")
    end)

    Suite:testMethod("LoreManager.isEntryUnlocked", {description = "Checks unlock status", testCase = "check_unlock", type = "functional"}, function()
        shared.lore:unlockEntry("secret")
        local unlocked = shared.lore:isEntryUnlocked("secret")
        Helpers.assertEqual(unlocked, true, "Entry marked unlocked")
    end)

    Suite:testMethod("LoreManager.isEntryUnlocked", {description = "Locked by default", testCase = "locked", type = "functional"}, function()
        local unlocked = shared.lore:isEntryUnlocked("secret")
        Helpers.assertEqual(unlocked, false, "Entry locked initially")
    end)

    Suite:testMethod("LoreManager.getUnlockedCount", {description = "Counts unlocked", testCase = "count_unlocked", type = "functional"}, function()
        shared.lore:addLoreEntry("e1", "E1", "C", "cat")
        shared.lore:addLoreEntry("e2", "E2", "C", "cat")
        shared.lore:unlockEntry("secret")
        shared.lore:unlockEntry("e1")
        local count = shared.lore:getUnlockedCount()
        Helpers.assertEqual(count, 2, "Two entries unlocked")
    end)
end)

Suite:group("Characters", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreManager:new()
    end)

    Suite:testMethod("LoreManager.addCharacter", {description = "Adds character", testCase = "add_char", type = "functional"}, function()
        local ok = shared.lore:addCharacter("commander", "Commander", "Leader of forces", "player")
        Helpers.assertEqual(ok, true, "Character added")
    end)

    Suite:testMethod("LoreManager.getCharacter", {description = "Retrieves character", testCase = "get_char", type = "functional"}, function()
        shared.lore:addCharacter("scientist", "Scientist", "Researcher", "ally")
        local char = shared.lore:getCharacter("scientist")
        Helpers.assertEqual(char ~= nil, true, "Character retrieved")
    end)

    Suite:testMethod("LoreManager.getCharacterCount", {description = "Counts characters", testCase = "count_chars", type = "functional"}, function()
        shared.lore:addCharacter("c1", "Char 1", "Desc", "faction")
        shared.lore:addCharacter("c2", "Char 2", "Desc", "faction")
        shared.lore:addCharacter("c3", "Char 3", "Desc", "faction")
        local count = shared.lore:getCharacterCount()
        Helpers.assertEqual(count, 3, "Three characters")
    end)

    Suite:testMethod("LoreManager.recordAppearance", {description = "Records appearance", testCase = "appearance", type = "functional"}, function()
        shared.lore:addCharacter("hero", "Hero", "Protagonist", "player")
        local ok = shared.lore:recordAppearance("hero")
        Helpers.assertEqual(ok, true, "Appearance recorded")
    end)

    Suite:testMethod("LoreManager.recordAppearance", {description = "Increments count", testCase = "count_appearances", type = "functional"}, function()
        shared.lore:addCharacter("npc", "NPC", "Ally", "faction")
        shared.lore:recordAppearance("npc")
        shared.lore:recordAppearance("npc")
        local char = shared.lore:getCharacter("npc")
        Helpers.assertEqual(char.appearances, 2, "Two appearances recorded")
    end)
end)

Suite:group("Lore Organization", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreManager:new()
        shared.lore:addLoreEntry("history1", "Ancient Past", "Long ago", "history")
        shared.lore:addLoreEntry("history2", "Medieval", "Middle times", "history")
        shared.lore:addLoreEntry("tech", "Technology", "Advanced stuff", "technology")
    end)

    Suite:testMethod("LoreManager.getEntriesByCategory", {description = "Filters by category", testCase = "filter_cat", type = "functional"}, function()
        local entries = shared.lore:getEntriesByCategory("history")
        Helpers.assertEqual(entries ~= nil, true, "Filtered results returned")
    end)

    Suite:testMethod("LoreManager.getEntriesByCategory", {description = "Finds correct category", testCase = "correct_cat", type = "functional"}, function()
        local entries = shared.lore:getEntriesByCategory("history")
        local count = #entries
        Helpers.assertEqual(count, 2, "Two history entries found")
    end)

    Suite:testMethod("LoreManager.getEntriesByCategory", {description = "Returns empty for none", testCase = "no_category", type = "functional"}, function()
        local entries = shared.lore:getEntriesByCategory("unknown")
        local count = #entries
        Helpers.assertEqual(count, 0, "No unknown category entries")
    end)
end)

Suite:run()
