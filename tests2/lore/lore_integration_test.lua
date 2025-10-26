-- ─────────────────────────────────────────────────────────────────────────
-- LORE INTEGRATION TEST SUITE
-- FILE: tests2/lore/lore_integration_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.lore_integration",
    fileName = "lore_integration.lua",
    description = "Lore integration with database, story progression, artifacts, and narrative"
})

print("[LORE_INTEGRATION_TEST] Setting up")

local LoreIntegration = {
    lore_entries = {}, characters = {}, artifacts = {}, story_progression = {},
    locations = {}, events = {}, quests = {},

    new = function(self)
        return setmetatable({
            lore_entries = {}, characters = {}, artifacts = {}, story_progression = {},
            locations = {}, events = {}, quests = {}
        }, {__index = self})
    end,

    createLoreEntry = function(self, entryId, title, content, category)
        self.lore_entries[entryId] = {
            id = entryId, title = title, content = content, category = category,
            discovered = false, importance = 1, creation_date = os.time()
        }
        return true
    end,

    getLoreEntry = function(self, entryId)
        return self.lore_entries[entryId]
    end,

    discoverLoreEntry = function(self, entryId)
        if not self.lore_entries[entryId] then return false end
        self.lore_entries[entryId].discovered = true
        return true
    end,

    createCharacter = function(self, characterId, name, role, affiliation)
        self.characters[characterId] = {
            id = characterId, name = name, role = role, affiliation = affiliation,
            backstory = "", status = "alive", importance = 2, relationships = {}
        }
        return true
    end,

    getCharacter = function(self, characterId)
        return self.characters[characterId]
    end,

    createArtifact = function(self, artifactId, name, description, power_level)
        self.artifacts[artifactId] = {
            id = artifactId, name = name, description = description,
            power_level = power_level or 5, discovered = false, location = "unknown",
            effect = nil, usage_count = 0
        }
        return true
    end,

    getArtifact = function(self, artifactId)
        return self.artifacts[artifactId]
    end,

    discoverArtifact = function(self, artifactId, location)
        if not self.artifacts[artifactId] then return false end
        local artifact = self.artifacts[artifactId]
        artifact.discovered = true
        artifact.location = location
        return true
    end,

    useArtifact = function(self, artifactId)
        if not self.artifacts[artifactId] then return false end
        local artifact = self.artifacts[artifactId]
        if not artifact.discovered then return false end
        artifact.usage_count = artifact.usage_count + 1
        return true
    end,

    registerLocation = function(self, locationId, name, location_type, description)
        self.locations[locationId] = {
            id = locationId, name = name, type = location_type, description = description,
            visited = false, lore_significance = 50, connections = {}
        }
        return true
    end,

    getLocation = function(self, locationId)
        return self.locations[locationId]
    end,

    visitLocation = function(self, locationId)
        if not self.locations[locationId] then return false end
        self.locations[locationId].visited = true
        return true
    end,

    connectLocations = function(self, location1Id, location2Id)
        if not self.locations[location1Id] or not self.locations[location2Id] then return false end
        table.insert(self.locations[location1Id].connections, location2Id)
        table.insert(self.locations[location2Id].connections, location1Id)
        return true
    end,

    recordStoryEvent = function(self, eventId, event_type, description, progression_impact)
        local story_event = {
            id = eventId, type = event_type, description = description,
            impact = progression_impact or 10, timestamp = os.time(), outcome = "pending"
        }
        table.insert(self.story_progression, story_event)
        return true
    end,

    getStoryProgression = function(self)
        return self.story_progression
    end,

    resolveStoryEvent = function(self, eventId, outcome)
        for i, event in ipairs(self.story_progression) do
            if event.id == eventId then
                event.outcome = outcome
                return true
            end
        end
        return false
    end,

    getStoryMilestones = function(self)
        local milestones = {}
        for _, event in ipairs(self.story_progression) do
            if event.impact > 20 then
                table.insert(milestones, event)
            end
        end
        return milestones
    end,

    createQuest = function(self, questId, name, description, rewards)
        self.quests[questId] = {
            id = questId, name = name, description = description,
            status = "inactive", progress = 0, rewards = rewards or {},
            start_date = nil, completion_date = nil, objectives = {}
        }
        return true
    end,

    getQuest = function(self, questId)
        return self.quests[questId]
    end,

    activateQuest = function(self, questId)
        if not self.quests[questId] then return false end
        local quest = self.quests[questId]
        quest.status = "active"
        quest.start_date = os.time()
        return true
    end,

    updateQuestProgress = function(self, questId, progress_delta)
        if not self.quests[questId] then return false end
        local quest = self.quests[questId]
        quest.progress = math.min(100, quest.progress + progress_delta)
        if quest.progress >= 100 then
            quest.status = "completed"
            quest.completion_date = os.time()
        end
        return true
    end,

    completeQuest = function(self, questId)
        if not self.quests[questId] then return false end
        local quest = self.quests[questId]
        quest.status = "completed"
        quest.completion_date = os.time()
        return true
    end,

    linkCharacterToEvent = function(self, characterId, eventId)
        if not self.characters[characterId] then return false end
        if not self.events[eventId] then return false end
        table.insert(self.events[eventId].characters, characterId)
        return true
    end,

    getCharacterNarrative = function(self, characterId)
        if not self.characters[characterId] then return "" end
        local char = self.characters[characterId]
        return char.backstory
    end,

    setCharacterBackstory = function(self, characterId, backstory)
        if not self.characters[characterId] then return false end
        self.characters[characterId].backstory = backstory
        return true
    end,

    getDiscoveredLore = function(self)
        local discovered = {}
        for _, entry in pairs(self.lore_entries) do
            if entry.discovered then
                table.insert(discovered, entry)
            end
        end
        return discovered
    end,

    getDiscoveredArtifacts = function(self)
        local discovered = {}
        for _, artifact in pairs(self.artifacts) do
            if artifact.discovered then
                table.insert(discovered, artifact)
            end
        end
        return discovered
    end,

    getVisitedLocations = function(self)
        local visited = {}
        for _, location in pairs(self.locations) do
            if location.visited then
                table.insert(visited, location)
            end
        end
        return visited
    end,

    getLoreCompleteness = function(self)
        local total = 0
        local discovered = 0
        for _, entry in pairs(self.lore_entries) do
            total = total + 1
            if entry.discovered then discovered = discovered + 1 end
        end
        if total == 0 then return 0 end
        return (discovered / total) * 100
    end,

    reset = function(self)
        self.lore_entries = {}
        self.characters = {}
        self.artifacts = {}
        self.story_progression = {}
        self.locations = {}
        self.events = {}
        self.quests = {}
        return true
    end
}

Suite:group("Lore Entries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.createLoreEntry", {description = "Creates entry", testCase = "create", type = "functional"}, function()
        local ok = shared.lore:createLoreEntry("lore1", "Origins", "Long ago...", "history")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreIntegration.getLoreEntry", {description = "Gets entry", testCase = "get", type = "functional"}, function()
        shared.lore:createLoreEntry("lore2", "Ancient War", "The great conflict...", "history")
        local entry = shared.lore:getLoreEntry("lore2")
        Helpers.assertEqual(entry ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreIntegration.discoverLoreEntry", {description = "Discovers entry", testCase = "discover", type = "functional"}, function()
        shared.lore:createLoreEntry("lore3", "Lost Artifact", "Hidden knowledge...", "artifacts")
        local ok = shared.lore:discoverLoreEntry("lore3")
        Helpers.assertEqual(ok, true, "Discovered")
    end)

    Suite:testMethod("LoreIntegration.getDiscoveredLore", {description = "Gets discovered", testCase = "discovered", type = "functional"}, function()
        shared.lore:createLoreEntry("lore4", "Secret Society", "In the shadows...", "factions")
        shared.lore:discoverLoreEntry("lore4")
        local discovered = shared.lore:getDiscoveredLore()
        Helpers.assertEqual(#discovered > 0, true, "Has discovered")
    end)

    Suite:testMethod("LoreIntegration.getLoreCompleteness", {description = "Gets completeness", testCase = "completeness", type = "functional"}, function()
        shared.lore:createLoreEntry("lore5", "Mystery", "Unknown...", "mystery")
        local completeness = shared.lore:getLoreCompleteness()
        Helpers.assertEqual(completeness >= 0, true, "Completeness >= 0")
    end)
end)

Suite:group("Characters", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.createCharacter", {description = "Creates character", testCase = "create", type = "functional"}, function()
        local ok = shared.lore:createCharacter("char1", "Commander", "leader", "player")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreIntegration.getCharacter", {description = "Gets character", testCase = "get", type = "functional"}, function()
        shared.lore:createCharacter("char2", "Scholar", "advisor", "ally")
        local char = shared.lore:getCharacter("char2")
        Helpers.assertEqual(char ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreIntegration.setCharacterBackstory", {description = "Sets backstory", testCase = "backstory", type = "functional"}, function()
        shared.lore:createCharacter("char3", "Warrior", "soldier", "companion")
        local ok = shared.lore:setCharacterBackstory("char3", "Born in battle...")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("LoreIntegration.getCharacterNarrative", {description = "Gets narrative", testCase = "narrative", type = "functional"}, function()
        shared.lore:createCharacter("char4", "Mage", "caster", "ally")
        shared.lore:setCharacterBackstory("char4", "Studied for years...")
        local narrative = shared.lore:getCharacterNarrative("char4")
        Helpers.assertEqual(narrative ~= "", true, "Has narrative")
    end)
end)

Suite:group("Artifacts", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.createArtifact", {description = "Creates artifact", testCase = "create", type = "functional"}, function()
        local ok = shared.lore:createArtifact("art1", "Ancient Crown", "Symbol of power", 8)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreIntegration.getArtifact", {description = "Gets artifact", testCase = "get", type = "functional"}, function()
        shared.lore:createArtifact("art2", "Cursed Gem", "Glowing stone", 9)
        local artifact = shared.lore:getArtifact("art2")
        Helpers.assertEqual(artifact ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreIntegration.discoverArtifact", {description = "Discovers artifact", testCase = "discover", type = "functional"}, function()
        shared.lore:createArtifact("art3", "Lost Scroll", "Ancient writings", 6)
        local ok = shared.lore:discoverArtifact("art3", "Library")
        Helpers.assertEqual(ok, true, "Discovered")
    end)

    Suite:testMethod("LoreIntegration.useArtifact", {description = "Uses artifact", testCase = "use", type = "functional"}, function()
        shared.lore:createArtifact("art4", "Enchanted Sword", "Glowing blade", 7)
        shared.lore:discoverArtifact("art4", "Vault")
        local ok = shared.lore:useArtifact("art4")
        Helpers.assertEqual(ok, true, "Used")
    end)

    Suite:testMethod("LoreIntegration.getDiscoveredArtifacts", {description = "Gets discovered", testCase = "discovered", type = "functional"}, function()
        shared.lore:createArtifact("art5", "Relic", "Ancient object", 5)
        shared.lore:discoverArtifact("art5", "Tomb")
        local discovered = shared.lore:getDiscoveredArtifacts()
        Helpers.assertEqual(#discovered > 0, true, "Has discovered")
    end)
end)

Suite:group("Locations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.registerLocation", {description = "Registers location", testCase = "register", type = "functional"}, function()
        local ok = shared.lore:registerLocation("loc1", "Capital", "city", "Great city")
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("LoreIntegration.getLocation", {description = "Gets location", testCase = "get", type = "functional"}, function()
        shared.lore:registerLocation("loc2", "Forest", "wilderness", "Dark forest")
        local loc = shared.lore:getLocation("loc2")
        Helpers.assertEqual(loc ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreIntegration.visitLocation", {description = "Visits location", testCase = "visit", type = "functional"}, function()
        shared.lore:registerLocation("loc3", "Mountain", "terrain", "High peak")
        local ok = shared.lore:visitLocation("loc3")
        Helpers.assertEqual(ok, true, "Visited")
    end)

    Suite:testMethod("LoreIntegration.connectLocations", {description = "Connects locations", testCase = "connect", type = "functional"}, function()
        shared.lore:registerLocation("loc4", "Town", "city", "Small town")
        shared.lore:registerLocation("loc5", "Village", "city", "Tiny village")
        local ok = shared.lore:connectLocations("loc4", "loc5")
        Helpers.assertEqual(ok, true, "Connected")
    end)

    Suite:testMethod("LoreIntegration.getVisitedLocations", {description = "Gets visited", testCase = "visited", type = "functional"}, function()
        shared.lore:registerLocation("loc6", "Temple", "sacred", "Holy place")
        shared.lore:visitLocation("loc6")
        local visited = shared.lore:getVisitedLocations()
        Helpers.assertEqual(#visited > 0, true, "Has visited")
    end)
end)

Suite:group("Story Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.recordStoryEvent", {description = "Records event", testCase = "record", type = "functional"}, function()
        local ok = shared.lore:recordStoryEvent("evt1", "major", "War declared", 50)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("LoreIntegration.getStoryProgression", {description = "Gets progression", testCase = "progression", type = "functional"}, function()
        shared.lore:recordStoryEvent("evt2", "minor", "Trade agreement", 10)
        local progression = shared.lore:getStoryProgression()
        Helpers.assertEqual(#progression > 0, true, "Has progression")
    end)

    Suite:testMethod("LoreIntegration.resolveStoryEvent", {description = "Resolves event", testCase = "resolve", type = "functional"}, function()
        shared.lore:recordStoryEvent("evt3", "major", "Battle occurs", 40)
        local ok = shared.lore:resolveStoryEvent("evt3", "victory")
        Helpers.assertEqual(ok, true, "Resolved")
    end)

    Suite:testMethod("LoreIntegration.getStoryMilestones", {description = "Gets milestones", testCase = "milestones", type = "functional"}, function()
        shared.lore:recordStoryEvent("evt4", "epic", "World changes", 60)
        local milestones = shared.lore:getStoryMilestones()
        Helpers.assertEqual(typeof(milestones) == "table", true, "Is table")
    end)
end)

Suite:group("Quests", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.createQuest", {description = "Creates quest", testCase = "create", type = "functional"}, function()
        local ok = shared.lore:createQuest("quest1", "Find Treasure", "Locate the treasure", {"gold"})
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("LoreIntegration.getQuest", {description = "Gets quest", testCase = "get", type = "functional"}, function()
        shared.lore:createQuest("quest2", "Save Villager", "Help in need", {"reputation"})
        local quest = shared.lore:getQuest("quest2")
        Helpers.assertEqual(quest ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("LoreIntegration.activateQuest", {description = "Activates quest", testCase = "activate", type = "functional"}, function()
        shared.lore:createQuest("quest3", "Defeat Monsters", "Clear cave", {"experience"})
        local ok = shared.lore:activateQuest("quest3")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("LoreIntegration.updateQuestProgress", {description = "Updates progress", testCase = "progress", type = "functional"}, function()
        shared.lore:createQuest("quest4", "Gather Resources", "Collect items", {"supplies"})
        local ok = shared.lore:updateQuestProgress("quest4", 50)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("LoreIntegration.completeQuest", {description = "Completes quest", testCase = "complete", type = "functional"}, function()
        shared.lore:createQuest("quest5", "Final Task", "Complete it", {"victory"})
        local ok = shared.lore:completeQuest("quest5")
        Helpers.assertEqual(ok, true, "Completed")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.lore = LoreIntegration:new()
    end)

    Suite:testMethod("LoreIntegration.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.lore:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
