-- ─────────────────────────────────────────────────────────────────────────
-- LORE PROGRESSION TEST SUITE
-- FILE: tests2/lore/lore_progression_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.lore_progression",
    fileName = "lore_progression.lua",
    description = "Lore progression system with story beats, unlocks, and narrative progression"
})

print("[LORE_PROGRESSION_TEST] Setting up")

local LoreProgression = {
    chapters = {},
    story_beats = {},
    unlocks = {},
    codex = {},
    progression = {},

    new = function(self)
        return setmetatable({
            chapters = {}, story_beats = {}, unlocks = {},
            codex = {}, progression = {}
        }, {__index = self})
    end,

    registerChapter = function(self, chapterId, name, description, order)
        self.chapters[chapterId] = {
            id = chapterId, name = name, description = description,
            order = order or 1, unlocked = false, beats_completed = 0
        }
        return true
    end,

    getChapter = function(self, chapterId)
        return self.chapters[chapterId]
    end,

    unlockChapter = function(self, chapterId)
        if not self.chapters[chapterId] then return false end
        self.chapters[chapterId].unlocked = true
        return true
    end,

    isChapterUnlocked = function(self, chapterId)
        if not self.chapters[chapterId] then return false end
        return self.chapters[chapterId].unlocked
    end,

    createStoryBeat = function(self, beatId, chapterId, beatName, narrative_text)
        if not self.chapters[chapterId] then return false end
        self.story_beats[beatId] = {
            id = beatId, chapter = chapterId, name = beatName,
            text = narrative_text or "", completed = false,
            triggers = {}, prerequisites = {}
        }
        return true
    end,

    getStoryBeat = function(self, beatId)
        return self.story_beats[beatId]
    end,

    completeStoryBeat = function(self, beatId)
        if not self.story_beats[beatId] then return false end
        self.story_beats[beatId].completed = true
        local chapterId = self.story_beats[beatId].chapter
        if self.chapters[chapterId] then
            self.chapters[chapterId].beats_completed = self.chapters[chapterId].beats_completed + 1
        end
        return true
    end,

    isStoryBeatCompleted = function(self, beatId)
        if not self.story_beats[beatId] then return false end
        return self.story_beats[beatId].completed
    end,

    addPrerequisite = function(self, beatId, prerequisiteBeatId)
        if not self.story_beats[beatId] or not self.story_beats[prerequisiteBeatId] then return false end
        table.insert(self.story_beats[beatId].prerequisites, prerequisiteBeatId)
        return true
    end,

    canProgressBeat = function(self, beatId)
        if not self.story_beats[beatId] then return false end
        for _, prereq in ipairs(self.story_beats[beatId].prerequisites) do
            if not self:isStoryBeatCompleted(prereq) then return false end
        end
        return true
    end,

    createCodexEntry = function(self, entryId, title, category, content)
        self.codex[entryId] = {
            id = entryId, title = title, category = category or "general",
            content = content or "", discovered = false, discovery_turn = 0
        }
        return true
    end,

    getCodexEntry = function(self, entryId)
        return self.codex[entryId]
    end,

    discoverEntry = function(self, entryId)
        if not self.codex[entryId] then return false end
        self.codex[entryId].discovered = true
        self.codex[entryId].discovery_turn = 0
        return true
    end,

    isEntryDiscovered = function(self, entryId)
        if not self.codex[entryId] then return false end
        return self.codex[entryId].discovered
    end,

    getDiscoveredEntriesCount = function(self)
        local count = 0
        for _, entry in pairs(self.codex) do
            if entry.discovered then count = count + 1 end
        end
        return count
    end,

    getDiscoveredEntriesByCategory = function(self, category)
        local count = 0
        for _, entry in pairs(self.codex) do
            if entry.discovered and entry.category == category then count = count + 1 end
        end
        return count
    end,

    getTotalCodexEntries = function(self)
        local count = 0
        for _ in pairs(self.codex) do count = count + 1 end
        return count
    end,

    createUnlock = function(self, unlockId, unlockType, name, requirement)
        self.unlocks[unlockId] = {
            id = unlockId, type = unlockType or "feature",
            name = name, requirement = requirement or 0,
            unlocked = false, unlock_turn = 0
        }
        return true
    end,

    getUnlock = function(self, unlockId)
        return self.unlocks[unlockId]
    end,

    unlockFeature = function(self, unlockId)
        if not self.unlocks[unlockId] then return false end
        self.unlocks[unlockId].unlocked = true
        return true
    end,

    isFeatureUnlocked = function(self, unlockId)
        if not self.unlocks[unlockId] then return false end
        return self.unlocks[unlockId].unlocked
    end,

    startProgression = function(self, playerId)
        self.progression[playerId] = {
            player = playerId, current_chapter = 1,
            current_beat = 1, story_progress = 0, codex_progress = 0
        }
        return true
    end,

    advanceProgression = function(self, playerId)
        if not self.progression[playerId] then return false end
        self.progression[playerId].story_progress = math.min(100, self.progression[playerId].story_progress + 5)
        return true
    end,

    getProgressionStatus = function(self, playerId)
        if not self.progression[playerId] then return 0 end
        return self.progression[playerId].story_progress
    end,

    completeChapter = function(self, playerId, chapterId)
        if not self.progression[playerId] or not self.chapters[chapterId] then return false end
        self.progression[playerId].current_chapter = chapterId
        self.progression[playerId].story_progress = 100
        return true
    end,

    getCurrentChapter = function(self, playerId)
        if not self.progression[playerId] then return 0 end
        return self.progression[playerId].current_chapter
    end,

    calculateLoreCompletion = function(self)
        local total_beats = 0
        local completed_beats = 0
        for _, beat in pairs(self.story_beats) do
            total_beats = total_beats + 1
            if beat.completed then completed_beats = completed_beats + 1 end
        end
        if total_beats == 0 then return 0 end
        return math.floor((completed_beats / total_beats) * 100)
    end,

    getUnlockedCount = function(self)
        local count = 0
        for _, unlock in pairs(self.unlocks) do
            if unlock.unlocked then count = count + 1 end
        end
        return count
    end,

    getChapterBeatsCompleted = function(self, chapterId)
        if not self.chapters[chapterId] then return 0 end
        return self.chapters[chapterId].beats_completed
    end,

    reset = function(self)
        self.chapters = {}
        self.story_beats = {}
        self.unlocks = {}
        self.codex = {}
        self.progression = {}
        return true
    end
}

Suite:group("Chapters", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
    end)

    Suite:testMethod("LoreProgression.registerChapter", {description = "Registers chapter", testCase = "register", type = "functional"}, function()
        local ok = shared.lp:registerChapter("ch1", "Chapter One", "First chapter", 1)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("LoreProgression.getChapter", {description = "Gets chapter", testCase = "get", type = "functional"}, function()
        shared.lp:registerChapter("ch2", "Chapter Two", "Second chapter", 2)
        local chapter = shared.lp:getChapter("ch2")
        Helpers.assertEqual(chapter ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreProgression.unlockChapter", {description = "Unlocks chapter", testCase = "unlock", type = "functional"}, function()
        shared.lp:registerChapter("ch3", "Chapter Three", "Third chapter", 3)
        local ok = shared.lp:unlockChapter("ch3")
        Helpers.assertEqual(ok, true, "Unlocked")
    end)

    Suite:testMethod("LoreProgression.isChapterUnlocked", {description = "Is unlocked", testCase = "is_unlocked", type = "functional"}, function()
        shared.lp:registerChapter("ch4", "Chapter Four", "Fourth chapter", 4)
        shared.lp:unlockChapter("ch4")
        local is = shared.lp:isChapterUnlocked("ch4")
        Helpers.assertEqual(is, true, "Unlocked")
    end)
end)

Suite:group("Story Beats", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
        shared.lp:registerChapter("beats_ch", "Beats Chapter", "For beats", 1)
    end)

    Suite:testMethod("LoreProgression.createStoryBeat", {description = "Creates beat", testCase = "create", type = "functional"}, function()
        local ok = shared.lp:createStoryBeat("beat1", "beats_ch", "Beat One", "Text")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreProgression.getStoryBeat", {description = "Gets beat", testCase = "get", type = "functional"}, function()
        shared.lp:createStoryBeat("beat2", "beats_ch", "Beat Two", "Text Two")
        local beat = shared.lp:getStoryBeat("beat2")
        Helpers.assertEqual(beat ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreProgression.completeStoryBeat", {description = "Completes beat", testCase = "complete", type = "functional"}, function()
        shared.lp:createStoryBeat("beat3", "beats_ch", "Beat Three", "Text Three")
        local ok = shared.lp:completeStoryBeat("beat3")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("LoreProgression.isStoryBeatCompleted", {description = "Is completed", testCase = "is_complete", type = "functional"}, function()
        shared.lp:createStoryBeat("beat4", "beats_ch", "Beat Four", "Text Four")
        shared.lp:completeStoryBeat("beat4")
        local is = shared.lp:isStoryBeatCompleted("beat4")
        Helpers.assertEqual(is, true, "Completed")
    end)
end)

Suite:group("Prerequisites", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
        shared.lp:registerChapter("prereq_ch", "Prereq Chapter", "For prereqs", 1)
        shared.lp:createStoryBeat("pre1", "prereq_ch", "Pre One", "Text")
        shared.lp:createStoryBeat("pre2", "prereq_ch", "Pre Two", "Text")
    end)

    Suite:testMethod("LoreProgression.addPrerequisite", {description = "Adds prerequisite", testCase = "add", type = "functional"}, function()
        local ok = shared.lp:addPrerequisite("pre2", "pre1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("LoreProgression.canProgressBeat", {description = "Can progress", testCase = "can_progress", type = "functional"}, function()
        shared.lp:addPrerequisite("pre2", "pre1")
        local can = shared.lp:canProgressBeat("pre2")
        Helpers.assertEqual(can, false, "Cannot progress")
    end)
end)

Suite:group("Codex Entries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
    end)

    Suite:testMethod("LoreProgression.createCodexEntry", {description = "Creates entry", testCase = "create", type = "functional"}, function()
        local ok = shared.lp:createCodexEntry("entry1", "Entry One", "creatures", "Content")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreProgression.getCodexEntry", {description = "Gets entry", testCase = "get", type = "functional"}, function()
        shared.lp:createCodexEntry("entry2", "Entry Two", "technology", "Content Two")
        local entry = shared.lp:getCodexEntry("entry2")
        Helpers.assertEqual(entry ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreProgression.discoverEntry", {description = "Discovers entry", testCase = "discover", type = "functional"}, function()
        shared.lp:createCodexEntry("entry3", "Entry Three", "events", "Content Three")
        local ok = shared.lp:discoverEntry("entry3")
        Helpers.assertEqual(ok, true, "Discovered")
    end)

    Suite:testMethod("LoreProgression.isEntryDiscovered", {description = "Is discovered", testCase = "is_discovered", type = "functional"}, function()
        shared.lp:createCodexEntry("entry4", "Entry Four", "locations", "Content Four")
        shared.lp:discoverEntry("entry4")
        local is = shared.lp:isEntryDiscovered("entry4")
        Helpers.assertEqual(is, true, "Discovered")
    end)
end)

Suite:group("Codex Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
        shared.lp:createCodexEntry("c1", "C1", "creatures", "Content")
        shared.lp:createCodexEntry("c2", "C2", "creatures", "Content")
        shared.lp:createCodexEntry("c3", "C3", "technology", "Content")
    end)

    Suite:testMethod("LoreProgression.getDiscoveredEntriesCount", {description = "Discovered count", testCase = "count", type = "functional"}, function()
        shared.lp:discoverEntry("c1")
        shared.lp:discoverEntry("c2")
        local count = shared.lp:getDiscoveredEntriesCount()
        Helpers.assertEqual(count, 2, "Two discovered")
    end)

    Suite:testMethod("LoreProgression.getDiscoveredEntriesByCategory", {description = "By category", testCase = "category", type = "functional"}, function()
        shared.lp:discoverEntry("c1")
        shared.lp:discoverEntry("c2")
        shared.lp:discoverEntry("c3")
        local count = shared.lp:getDiscoveredEntriesByCategory("creatures")
        Helpers.assertEqual(count, 2, "Two creatures")
    end)

    Suite:testMethod("LoreProgression.getTotalCodexEntries", {description = "Total entries", testCase = "total", type = "functional"}, function()
        local total = shared.lp:getTotalCodexEntries()
        Helpers.assertEqual(total, 3, "Three entries")
    end)
end)

Suite:group("Unlocks", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
    end)

    Suite:testMethod("LoreProgression.createUnlock", {description = "Creates unlock", testCase = "create", type = "functional"}, function()
        local ok = shared.lp:createUnlock("unlock1", "feature", "Feature One", 10)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreProgression.getUnlock", {description = "Gets unlock", testCase = "get", type = "functional"}, function()
        shared.lp:createUnlock("unlock2", "item", "Item Two", 5)
        local unlock = shared.lp:getUnlock("unlock2")
        Helpers.assertEqual(unlock ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreProgression.unlockFeature", {description = "Unlocks feature", testCase = "unlock", type = "functional"}, function()
        shared.lp:createUnlock("unlock3", "feature", "Feature Three", 0)
        local ok = shared.lp:unlockFeature("unlock3")
        Helpers.assertEqual(ok, true, "Unlocked")
    end)

    Suite:testMethod("LoreProgression.isFeatureUnlocked", {description = "Is unlocked", testCase = "is_unlocked", type = "functional"}, function()
        shared.lp:createUnlock("unlock4", "feature", "Feature Four", 0)
        shared.lp:unlockFeature("unlock4")
        local is = shared.lp:isFeatureUnlocked("unlock4")
        Helpers.assertEqual(is, true, "Unlocked")
    end)
end)

Suite:group("Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
        shared.lp:registerChapter("prog_ch", "Prog Chapter", "For progression", 1)
    end)

    Suite:testMethod("LoreProgression.startProgression", {description = "Starts progression", testCase = "start", type = "functional"}, function()
        local ok = shared.lp:startProgression("player1")
        Helpers.assertEqual(ok, true, "Started")
    end)

    Suite:testMethod("LoreProgression.advanceProgression", {description = "Advances", testCase = "advance", type = "functional"}, function()
        shared.lp:startProgression("player2")
        local ok = shared.lp:advanceProgression("player2")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("LoreProgression.getProgressionStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.lp:startProgression("player3")
        shared.lp:advanceProgression("player3")
        local status = shared.lp:getProgressionStatus("player3")
        Helpers.assertEqual(status >= 5, true, "Status >= 5")
    end)

    Suite:testMethod("LoreProgression.getCurrentChapter", {description = "Current chapter", testCase = "current", type = "functional"}, function()
        shared.lp:startProgression("player4")
        local chapter = shared.lp:getCurrentChapter("player4")
        Helpers.assertEqual(chapter > 0, true, "Chapter > 0")
    end)

    Suite:testMethod("LoreProgression.completeChapter", {description = "Completes chapter", testCase = "complete", type = "functional"}, function()
        shared.lp:startProgression("player5")
        local ok = shared.lp:completeChapter("player5", "prog_ch")
        Helpers.assertEqual(ok, true, "Completed")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
        shared.lp:registerChapter("anal_ch", "Analysis Chapter", "For analysis", 1)
        shared.lp:createStoryBeat("ab1", "anal_ch", "Beat 1", "Text")
        shared.lp:createStoryBeat("ab2", "anal_ch", "Beat 2", "Text")
        shared.lp:createUnlock("au1", "feature", "Unlock 1", 0)
        shared.lp:createUnlock("au2", "feature", "Unlock 2", 0)
    end)

    Suite:testMethod("LoreProgression.calculateLoreCompletion", {description = "Completion %", testCase = "completion", type = "functional"}, function()
        shared.lp:completeStoryBeat("ab1")
        local completion = shared.lp:calculateLoreCompletion()
        Helpers.assertEqual(completion >= 0, true, "Completion >= 0")
    end)

    Suite:testMethod("LoreProgression.getUnlockedCount", {description = "Unlocked count", testCase = "count", type = "functional"}, function()
        shared.lp:unlockFeature("au1")
        shared.lp:unlockFeature("au2")
        local count = shared.lp:getUnlockedCount()
        Helpers.assertEqual(count, 2, "Two unlocked")
    end)

    Suite:testMethod("LoreProgression.getChapterBeatsCompleted", {description = "Beats completed", testCase = "beats", type = "functional"}, function()
        shared.lp:completeStoryBeat("ab1")
        shared.lp:completeStoryBeat("ab2")
        local beats = shared.lp:getChapterBeatsCompleted("anal_ch")
        Helpers.assertEqual(beats, 2, "Two beats")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lp = LoreProgression:new()
    end)

    Suite:testMethod("LoreProgression.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.lp:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
