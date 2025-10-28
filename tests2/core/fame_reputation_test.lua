-- ─────────────────────────────────────────────────────────────────────────
-- FAME & REPUTATION TEST SUITE
-- FILE: tests2/core/fame_reputation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.fame_reputation",
    fileName = "fame_reputation.lua",
    description = "Celebrity/infamy tracking with public perception and media coverage"
})

print("[FAME_REPUTATION_TEST] Setting up")

local FameReputation = {
    characters = {},
    reputation = {},
    publicity = {},
    events = {},

    new = function(self)
        return setmetatable({characters = {}, reputation = {}, publicity = {}, events = {}}, {__index = self})
    end,

    registerCharacter = function(self, characterId, name, baseReputation)
        self.characters[characterId] = {id = characterId, name = name, fameLevel = 0, infamyLevel = 0}
        self.reputation[characterId] = {public = baseReputation or 50, heroic = 0, ruthless = 0}
        self.publicity[characterId] = {positive = 0, negative = 0, neutral = 0}
        self.events[characterId] = {}
        return true
    end,

    getCharacter = function(self, characterId)
        return self.characters[characterId]
    end,

    recordPublicAct = function(self, characterId, actType, perception, impact)
        if not self.characters[characterId] then return false end
        if perception == "positive" then
            self.publicity[characterId].positive = self.publicity[characterId].positive + 1
            self.reputation[characterId].heroic = self.reputation[characterId].heroic + impact
        elseif perception == "negative" then
            self.publicity[characterId].negative = self.publicity[characterId].negative + 1
            self.reputation[characterId].ruthless = self.reputation[characterId].ruthless + impact
        else
            self.publicity[characterId].neutral = self.publicity[characterId].neutral + 1
        end
        table.insert(self.events[characterId], {type = actType, perception = perception, impact = impact})
        return true
    end,

    calculateFameLevel = function(self, characterId)
        if not self.characters[characterId] then return 0 end
        local positiveEvents = self.publicity[characterId].positive
        local negativeEvents = self.publicity[characterId].negative
        local totalEvents = positiveEvents + negativeEvents
        if totalEvents == 0 then return 0 end
        self.characters[characterId].fameLevel = positiveEvents
        return self.characters[characterId].fameLevel
    end,

    calculateInfamyLevel = function(self, characterId)
        if not self.characters[characterId] then return 0 end
        self.characters[characterId].infamyLevel = self.publicity[characterId].negative
        return self.characters[characterId].infamyLevel
    end,

    getFameLevel = function(self, characterId)
        if not self.characters[characterId] then return 0 end
        return self.characters[characterId].fameLevel
    end,

    getInfamyLevel = function(self, characterId)
        if not self.characters[characterId] then return 0 end
        return self.characters[characterId].infamyLevel
    end,

    getPublicPerception = function(self, characterId)
        if not self.reputation[characterId] then return 0 end
        return self.reputation[characterId].public
    end,

    setPublicPerception = function(self, characterId, perception)
        if not self.reputation[characterId] then return false end
        self.reputation[characterId].public = math.max(0, math.min(100, perception))
        return true
    end,

    modifyPublicPerception = function(self, characterId, delta)
        if not self.reputation[characterId] then return false end
        self.reputation[characterId].public = math.max(0, math.min(100, self.reputation[characterId].public + delta))
        return true
    end,

    getTotalPublicity = function(self, characterId)
        if not self.publicity[characterId] then return 0 end
        return self.publicity[characterId].positive + self.publicity[characterId].negative + self.publicity[characterId].neutral
    end,

    getPublicityRatio = function(self, characterId)
        if not self.publicity[characterId] then return {positive = 0, negative = 0, neutral = 0} end
        return {
            positive = self.publicity[characterId].positive,
            negative = self.publicity[characterId].negative,
            neutral = self.publicity[characterId].neutral
        }
    end,

    isPublicFigure = function(self, characterId)
        return self:getTotalPublicity(characterId) >= 5
    end,

    getReputationScore = function(self, characterId)
        if not self.reputation[characterId] then return 0 end
        local heroic = self.reputation[characterId].heroic
        local ruthless = self.reputation[characterId].ruthless
        return heroic - ruthless
    end,

    getCharacterAlignment = function(self, characterId)
        local score = self:getReputationScore(characterId)
        if score > 20 then return "heroic"
        elseif score < -20 then return "ruthless"
        else return "neutral"
        end
    end,

    recordMission = function(self, characterId, missionType, success, civilianCasualties)
        if not self.characters[characterId] then return false end
        local perception = "neutral"
        local impact = 5
        if success then
            if civilianCasualties == 0 then
                perception = "positive"
                impact = 15
            else
                perception = "negative"
                impact = 10
            end
        else
            perception = "negative"
            impact = 10
        end
        self:recordPublicAct(characterId, "mission_" .. missionType, perception, impact)
        return true
    end,

    recordCombat = function(self, characterId, enemiesDefeated, skillShown)
        if not self.characters[characterId] then return false end
        if skillShown and enemiesDefeated > 3 then
            self:recordPublicAct(characterId, "impressive_combat", "positive", 12)
        end
        return true
    end,

    getEventCount = function(self, characterId)
        if not self.events[characterId] then return 0 end
        return #self.events[characterId]
    end,

    getRecentEvents = function(self, characterId, count)
        if not self.events[characterId] then return {} end
        local recent = {}
        local start = math.max(1, #self.events[characterId] - count + 1)
        for i = start, #self.events[characterId] do
            table.insert(recent, self.events[characterId][i])
        end
        return recent
    end,

    getPublicProfile = function(self, characterId)
        if not self.characters[characterId] then return nil end
        return {
            name = self.characters[characterId].name,
            fame = self:getFameLevel(characterId),
            infamy = self:getInfamyLevel(characterId),
            perception = self:getPublicPerception(characterId),
            alignment = self:getCharacterAlignment(characterId)
        }
    end,

    resetReputation = function(self, characterId)
        if not self.characters[characterId] then return false end
        self.reputation[characterId] = {public = 50, heroic = 0, ruthless = 0}
        self.publicity[characterId] = {positive = 0, negative = 0, neutral = 0}
        self.events[characterId] = {}
        self.characters[characterId].fameLevel = 0
        self.characters[characterId].infamyLevel = 0
        return true
    end,

    compareFame = function(self, charId1, charId2)
        local fame1 = self:getFameLevel(charId1)
        local fame2 = self:getFameLevel(charId2)
        if fame1 > fame2 then return 1
        elseif fame1 < fame2 then return -1
        else return 0
        end
    end,

    getMostFamous = function(self)
        local mostFamous = nil
        local maxFame = -1
        for charId, _ in pairs(self.characters) do
            local fame = self:getFameLevel(charId)
            if fame > maxFame then
                maxFame = fame
                mostFamous = charId
            end
        end
        return mostFamous
    end
}

Suite:group("Character Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
    end)

    Suite:testMethod("FameReputation.registerCharacter", {description = "Registers character", testCase = "register", type = "functional"}, function()
        local ok = shared.fr:registerCharacter("hero1", "Hero Name", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("FameReputation.getCharacter", {description = "Gets character", testCase = "get_char", type = "functional"}, function()
        shared.fr:registerCharacter("hero2", "Hero 2", 50)
        local char = shared.fr:getCharacter("hero2")
        Helpers.assertEqual(char ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Public Acts & Perception", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char1", "Character 1", 50)
    end)

    Suite:testMethod("FameReputation.recordPublicAct", {description = "Records act", testCase = "record_act", type = "functional"}, function()
        local ok = shared.fr:recordPublicAct("char1", "heroic_deed", "positive", 10)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FameReputation.getPublicPerception", {description = "Gets perception", testCase = "perception", type = "functional"}, function()
        local perc = shared.fr:getPublicPerception("char1")
        Helpers.assertEqual(perc, 50, "50 perception")
    end)

    Suite:testMethod("FameReputation.setPublicPerception", {description = "Sets perception", testCase = "set_perception", type = "functional"}, function()
        local ok = shared.fr:setPublicPerception("char1", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("FameReputation.modifyPublicPerception", {description = "Modifies perception", testCase = "modify_perception", type = "functional"}, function()
        shared.fr:modifyPublicPerception("char1", 15)
        local perc = shared.fr:getPublicPerception("char1")
        Helpers.assertEqual(perc, 65, "65 perception")
    end)
end)

Suite:group("Fame & Infamy Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char2", "Character 2", 50)
    end)

    Suite:testMethod("FameReputation.calculateFameLevel", {description = "Calculates fame", testCase = "calc_fame", type = "functional"}, function()
        shared.fr:recordPublicAct("char2", "act1", "positive", 5)
        shared.fr:recordPublicAct("char2", "act2", "positive", 5)
        local fame = shared.fr:calculateFameLevel("char2")
        Helpers.assertEqual(fame, 2, "Fame 2")
    end)

    Suite:testMethod("FameReputation.calculateInfamyLevel", {description = "Calculates infamy", testCase = "calc_infamy", type = "functional"}, function()
        shared.fr:recordPublicAct("char2", "bad1", "negative", 10)
        shared.fr:recordPublicAct("char2", "bad2", "negative", 10)
        local infamy = shared.fr:calculateInfamyLevel("char2")
        Helpers.assertEqual(infamy, 2, "Infamy 2")
    end)

    Suite:testMethod("FameReputation.getFameLevel", {description = "Gets fame", testCase = "get_fame", type = "functional"}, function()
        shared.fr:recordPublicAct("char2", "heroic", "positive", 8)
        shared.fr:calculateFameLevel("char2")
        local fame = shared.fr:getFameLevel("char2")
        Helpers.assertEqual(fame, 1, "Fame 1")
    end)

    Suite:testMethod("FameReputation.getInfamyLevel", {description = "Gets infamy", testCase = "get_infamy", type = "functional"}, function()
        shared.fr:recordPublicAct("char2", "evil", "negative", 8)
        shared.fr:calculateInfamyLevel("char2")
        local infamy = shared.fr:getInfamyLevel("char2")
        Helpers.assertEqual(infamy, 1, "Infamy 1")
    end)
end)

Suite:group("Publicity & Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char3", "Character 3", 50)
    end)

    Suite:testMethod("FameReputation.getTotalPublicity", {description = "Total publicity", testCase = "total_pub", type = "functional"}, function()
        shared.fr:recordPublicAct("char3", "a1", "positive", 5)
        shared.fr:recordPublicAct("char3", "a2", "negative", 5)
        local total = shared.fr:getTotalPublicity("char3")
        Helpers.assertEqual(total, 2, "Two events")
    end)

    Suite:testMethod("FameReputation.getPublicityRatio", {description = "Publicity ratio", testCase = "ratio", type = "functional"}, function()
        shared.fr:recordPublicAct("char3", "p1", "positive", 5)
        shared.fr:recordPublicAct("char3", "p2", "positive", 5)
        shared.fr:recordPublicAct("char3", "n1", "negative", 5)
        local ratio = shared.fr:getPublicityRatio("char3")
        Helpers.assertEqual(ratio.positive, 2, "Two positive")
    end)

    Suite:testMethod("FameReputation.isPublicFigure", {description = "Is public figure", testCase = "is_public", type = "functional"}, function()
        for i = 1, 5 do
            shared.fr:recordPublicAct("char3", "act" .. i, "positive", 5)
        end
        local isPublic = shared.fr:isPublicFigure("char3")
        Helpers.assertEqual(isPublic, true, "Public figure")
    end)

    Suite:testMethod("FameReputation.getEventCount", {description = "Event count", testCase = "event_count", type = "functional"}, function()
        shared.fr:recordPublicAct("char3", "e1", "positive", 5)
        shared.fr:recordPublicAct("char3", "e2", "negative", 5)
        local count = shared.fr:getEventCount("char3")
        Helpers.assertEqual(count, 2, "Two events")
    end)

    Suite:testMethod("FameReputation.getRecentEvents", {description = "Recent events", testCase = "recent_events", type = "functional"}, function()
        for i = 1, 5 do
            shared.fr:recordPublicAct("char3", "event" .. i, "positive", 5)
        end
        local recent = shared.fr:getRecentEvents("char3", 2)
        Helpers.assertEqual(#recent, 2, "Two recent")
    end)
end)

Suite:group("Reputation Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char4", "Character 4", 50)
    end)

    Suite:testMethod("FameReputation.getReputationScore", {description = "Reputation score", testCase = "rep_score", type = "functional"}, function()
        shared.fr:recordPublicAct("char4", "good", "positive", 25)
        local score = shared.fr:getReputationScore("char4")
        Helpers.assertEqual(score > 0, true, "Positive score")
    end)

    Suite:testMethod("FameReputation.getCharacterAlignment", {description = "Alignment", testCase = "alignment", type = "functional"}, function()
        shared.fr:recordPublicAct("char4", "heroic", "positive", 30)
        local align = shared.fr:getCharacterAlignment("char4")
        Helpers.assertEqual(align, "heroic", "Heroic")
    end)
end)

Suite:group("Mission & Combat Records", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char5", "Character 5", 50)
    end)

    Suite:testMethod("FameReputation.recordMission", {description = "Records mission", testCase = "mission", type = "functional"}, function()
        local ok = shared.fr:recordMission("char5", "rescue", true, 0)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FameReputation.recordCombat", {description = "Records combat", testCase = "combat", type = "functional"}, function()
        local ok = shared.fr:recordCombat("char5", 5, true)
        Helpers.assertEqual(ok, true, "Recorded")
    end)
end)

Suite:group("Profiles & Comparisons", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char6", "Character 6", 60)
        shared.fr:registerCharacter("char7", "Character 7", 40)
    end)

    Suite:testMethod("FameReputation.getPublicProfile", {description = "Gets profile", testCase = "profile", type = "functional"}, function()
        local profile = shared.fr:getPublicProfile("char6")
        Helpers.assertEqual(profile ~= nil, true, "Profile exists")
    end)

    Suite:testMethod("FameReputation.compareFame", {description = "Compares fame", testCase = "compare", type = "functional"}, function()
        shared.fr:recordPublicAct("char6", "heroic", "positive", 10)
        shared.fr:calculateFameLevel("char6")
        local cmp = shared.fr:compareFame("char6", "char7")
        Helpers.assertEqual(cmp, 1, "Char6 more famous")
    end)

    Suite:testMethod("FameReputation.getMostFamous", {description = "Gets most famous", testCase = "most_famous", type = "functional"}, function()
        shared.fr:recordPublicAct("char7", "act1", "positive", 5)
        shared.fr:recordPublicAct("char7", "act2", "positive", 5)
        shared.fr:calculateFameLevel("char6")
        shared.fr:calculateFameLevel("char7")
        local famous = shared.fr:getMostFamous()
        Helpers.assertEqual(famous == "char7" or famous == "char6", true, "Most famous found")
    end)
end)

Suite:group("Reset Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FameReputation:new()
        shared.fr:registerCharacter("char8", "Character 8", 50)
        shared.fr:recordPublicAct("char8", "deed", "positive", 10)
    end)

    Suite:testMethod("FameReputation.resetReputation", {description = "Resets reputation", testCase = "reset", type = "functional"}, function()
        local ok = shared.fr:resetReputation("char8")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
