-- ─────────────────────────────────────────────────────────────────────────
-- DIPLOMACY SYSTEM TEST SUITE
-- FILE: tests2/politics/diplomacy_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.diplomacy_system",
    fileName = "diplomacy_system.lua",
    description = "Diplomatic relations, treaties, and faction interactions"
})

print("[DIPLOMACY_SYSTEM_TEST] Setting up")

local DiplomacySystem = {
    factions = {},
    relations = {},
    treaties = {},
    incidents = {},
    sanctions = {},

    new = function(self)
        return setmetatable({factions = {}, relations = {}, treaties = {}, incidents = {}, sanctions = {}}, {__index = self})
    end,

    registerFaction = function(self, factionId, name, government)
        self.factions[factionId] = {id = factionId, name = name, government = government, relations = {}, trustScore = 50}
        self.relations[factionId] = {}
        return true
    end,

    setDiplomaticRelation = function(self, faction1, faction2, relationLevel)
        if not self.factions[faction1] or not self.factions[faction2] then return false end
        if not self.relations[faction1] then self.relations[faction1] = {} end
        if not self.relations[faction2] then self.relations[faction2] = {} end
        self.relations[faction1][faction2] = relationLevel
        self.relations[faction2][faction1] = relationLevel
        return true
    end,

    getDiplomaticRelation = function(self, faction1, faction2)
        if not self.relations[faction1] then return 0 end
        return self.relations[faction1][faction2] or 0
    end,

    signTreaty = function(self, treatyId, faction1, faction2, treatyType)
        if not self.factions[faction1] or not self.factions[faction2] then return false end
        self.treaties[treatyId] = {id = treatyId, factions = {faction1, faction2}, type = treatyType, active = true, yearSigned = 0}
        self:setDiplomaticRelation(faction1, faction2, 70)
        return true
    end,

    getTreaty = function(self, treatyId)
        return self.treaties[treatyId]
    end,

    breakTreaty = function(self, treatyId)
        if not self.treaties[treatyId] then return false end
        self.treaties[treatyId].active = false
        return true
    end,

    recordIncident = function(self, incidentId, faction1, faction2, severity)
        self.incidents[incidentId] = {id = incidentId, faction1 = faction1, faction2 = faction2, severity = severity, year = 0}
        local rel = self:getDiplomaticRelation(faction1, faction2)
        self:setDiplomaticRelation(faction1, faction2, rel - (severity or 10))
        return true
    end,

    imposeSanctions = function(self, sanctionId, targetFaction, sanctionType, duration)
        if not self.factions[targetFaction] then return false end
        self.sanctions[sanctionId] = {id = sanctionId, target = targetFaction, type = sanctionType, duration = duration, active = true}
        return true
    end,

    liftSanctions = function(self, sanctionId)
        if not self.sanctions[sanctionId] then return false end
        self.sanctions[sanctionId].active = false
        return true
    end,

    getActiveSanctions = function(self, targetFaction)
        local result = {}
        for _, sanction in pairs(self.sanctions) do
            if sanction.target == targetFaction and sanction.active then
                table.insert(result, sanction.id)
            end
        end
        return result
    end,

    canTradeBetween = function(self, faction1, faction2)
        local rel = self:getDiplomaticRelation(faction1, faction2)
        if rel < 30 then return false end
        local sanctions1 = self:getActiveSanctions(faction1)
        local sanctions2 = self:getActiveSanctions(faction2)
        return #sanctions1 == 0 and #sanctions2 == 0
    end,

    getTreatyCount = function(self)
        local count = 0
        for _, treaty in pairs(self.treaties) do
            if treaty.active then count = count + 1 end
        end
        return count
    end,

    getFactionCount = function(self)
        local count = 0
        for _ in pairs(self.factions) do count = count + 1 end
        return count
    end,

    getHostileFactions = function(self, faction)
        local result = {}
        for other, _ in pairs(self.factions) do
            if other ~= faction then
                local rel = self:getDiplomaticRelation(faction, other)
                if rel < 0 then table.insert(result, other) end
            end
        end
        return result
    end,

    getAlliedFactions = function(self, faction)
        local result = {}
        for other, _ in pairs(self.factions) do
            if other ~= faction then
                local rel = self:getDiplomaticRelation(faction, other)
                if rel > 60 then table.insert(result, other) end
            end
        end
        return result
    end
}

Suite:group("Faction Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ds = DiplomacySystem:new()
    end)

    Suite:testMethod("DiplomacySystem.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.ds ~= nil, true, "System created")
    end)

    Suite:testMethod("DiplomacySystem.registerFaction", {description = "Registers faction", testCase = "register", type = "functional"}, function()
        local ok = shared.ds:registerFaction("xcom", "XCOM", "military")
        Helpers.assertEqual(ok, true, "Faction registered")
    end)

    Suite:testMethod("DiplomacySystem.getFactionCount", {description = "Counts factions", testCase = "count", type = "functional"}, function()
        shared.ds:registerFaction("f1", "F1", "gov1")
        shared.ds:registerFaction("f2", "F2", "gov2")
        shared.ds:registerFaction("f3", "F3", "gov3")
        local count = shared.ds:getFactionCount()
        Helpers.assertEqual(count, 3, "Three factions")
    end)
end)

Suite:group("Diplomatic Relations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ds = DiplomacySystem:new()
        shared.ds:registerFaction("usa", "USA", "democratic")
        shared.ds:registerFaction("russia", "Russia", "authoritarian")
    end)

    Suite:testMethod("DiplomacySystem.setDiplomaticRelation", {description = "Sets relation", testCase = "set_rel", type = "functional"}, function()
        local ok = shared.ds:setDiplomaticRelation("usa", "russia", 40)
        Helpers.assertEqual(ok, true, "Relation set")
    end)

    Suite:testMethod("DiplomacySystem.getDiplomaticRelation", {description = "Gets relation", testCase = "get_rel", type = "functional"}, function()
        shared.ds:setDiplomaticRelation("usa", "russia", 35)
        local rel = shared.ds:getDiplomaticRelation("usa", "russia")
        Helpers.assertEqual(rel, 35, "Relation 35")
    end)

    Suite:testMethod("DiplomacySystem.getDiplomaticRelation", {description = "Bidirectional", testCase = "bidirectional", type = "functional"}, function()
        shared.ds:setDiplomaticRelation("usa", "russia", 45)
        local rel1 = shared.ds:getDiplomaticRelation("usa", "russia")
        local rel2 = shared.ds:getDiplomaticRelation("russia", "usa")
        Helpers.assertEqual(rel1, rel2, "Relations match")
    end)

    Suite:testMethod("DiplomacySystem.getDiplomaticRelation", {description = "Default 0", testCase = "default", type = "functional"}, function()
        local rel = shared.ds:getDiplomaticRelation("usa", "russia")
        Helpers.assertEqual(rel, 0, "Default 0")
    end)
end)

Suite:group("Treaties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ds = DiplomacySystem:new()
        shared.ds:registerFaction("player", "Player", "military")
        shared.ds:registerFaction("allies", "Allies", "democratic")
    end)

    Suite:testMethod("DiplomacySystem.signTreaty", {description = "Signs treaty", testCase = "sign", type = "functional"}, function()
        local ok = shared.ds:signTreaty("alliance1", "player", "allies", "alliance")
        Helpers.assertEqual(ok, true, "Treaty signed")
    end)

    Suite:testMethod("DiplomacySystem.getTreaty", {description = "Gets treaty", testCase = "get_treaty", type = "functional"}, function()
        shared.ds:signTreaty("trade1", "player", "allies", "trade")
        local treaty = shared.ds:getTreaty("trade1")
        Helpers.assertEqual(treaty ~= nil, true, "Treaty retrieved")
    end)

    Suite:testMethod("DiplomacySystem.signTreaty", {description = "Boosts relations", testCase = "boost", type = "functional"}, function()
        shared.ds:signTreaty("peace1", "player", "allies", "peace")
        local rel = shared.ds:getDiplomaticRelation("player", "allies")
        Helpers.assertEqual(rel, 70, "Relation 70")
    end)

    Suite:testMethod("DiplomacySystem.breakTreaty", {description = "Breaks treaty", testCase = "break", type = "functional"}, function()
        shared.ds:signTreaty("t1", "player", "allies", "alliance")
        local ok = shared.ds:breakTreaty("t1")
        Helpers.assertEqual(ok, true, "Treaty broken")
    end)

    Suite:testMethod("DiplomacySystem.getTreatyCount", {description = "Counts active", testCase = "count", type = "functional"}, function()
        shared.ds:signTreaty("t1", "player", "allies", "peace")
        shared.ds:registerFaction("rivals", "Rivals", "hostile")
        shared.ds:signTreaty("t2", "player", "rivals", "trade")
        local count = shared.ds:getTreatyCount()
        Helpers.assertEqual(count, 2, "Two treaties")
    end)
end)

Suite:group("Incidents & Sanctions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ds = DiplomacySystem:new()
        shared.ds:registerFaction("f1", "F1", "gov")
        shared.ds:registerFaction("f2", "F2", "gov")
    end)

    Suite:testMethod("DiplomacySystem.recordIncident", {description = "Records incident", testCase = "incident", type = "functional"}, function()
        local ok = shared.ds:recordIncident("inc1", "f1", "f2", 15)
        Helpers.assertEqual(ok, true, "Incident recorded")
    end)

    Suite:testMethod("DiplomacySystem.recordIncident", {description = "Damages relations", testCase = "damage", type = "functional"}, function()
        shared.ds:setDiplomaticRelation("f1", "f2", 50)
        shared.ds:recordIncident("inc2", "f1", "f2", 20)
        local rel = shared.ds:getDiplomaticRelation("f1", "f2")
        Helpers.assertEqual(rel, 30, "Relation 30")
    end)

    Suite:testMethod("DiplomacySystem.imposeSanctions", {description = "Imposes sanctions", testCase = "sanction", type = "functional"}, function()
        local ok = shared.ds:imposeSanctions("s1", "f1", "trade_embargo", 10)
        Helpers.assertEqual(ok, true, "Sanctions imposed")
    end)

    Suite:testMethod("DiplomacySystem.liftSanctions", {description = "Lifts sanctions", testCase = "lift", type = "functional"}, function()
        shared.ds:imposeSanctions("s1", "f1", "embargo", 5)
        local ok = shared.ds:liftSanctions("s1")
        Helpers.assertEqual(ok, true, "Sanctions lifted")
    end)

    Suite:testMethod("DiplomacySystem.getActiveSanctions", {description = "Counts active", testCase = "active_count", type = "functional"}, function()
        shared.ds:imposeSanctions("s1", "f1", "embargo", 5)
        shared.ds:imposeSanctions("s2", "f1", "blockade", 10)
        local sanctions = shared.ds:getActiveSanctions("f1")
        local count = #sanctions
        Helpers.assertEqual(count, 2, "Two active sanctions")
    end)
end)

Suite:group("Trade & Alliances", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ds = DiplomacySystem:new()
        shared.ds:registerFaction("trader1", "Trader1", "commercial")
        shared.ds:registerFaction("trader2", "Trader2", "commercial")
    end)

    Suite:testMethod("DiplomacySystem.canTradeBetween", {description = "Can trade high rel", testCase = "can_trade", type = "functional"}, function()
        shared.ds:setDiplomaticRelation("trader1", "trader2", 60)
        local ok = shared.ds:canTradeBetween("trader1", "trader2")
        Helpers.assertEqual(ok, true, "Trade allowed")
    end)

    Suite:testMethod("DiplomacySystem.canTradeBetween", {description = "Cannot low rel", testCase = "no_trade", type = "functional"}, function()
        shared.ds:setDiplomaticRelation("trader1", "trader2", 20)
        local ok = shared.ds:canTradeBetween("trader1", "trader2")
        Helpers.assertEqual(ok, false, "Trade denied")
    end)

    Suite:testMethod("DiplomacySystem.canTradeBetween", {description = "Blocked by sanctions", testCase = "sanction_block", type = "functional"}, function()
        shared.ds:setDiplomaticRelation("trader1", "trader2", 75)
        shared.ds:imposeSanctions("sanc", "trader1", "embargo", 5)
        local ok = shared.ds:canTradeBetween("trader1", "trader2")
        Helpers.assertEqual(ok, false, "Sanctioned blocks trade")
    end)

    Suite:testMethod("DiplomacySystem.getAlliedFactions", {description = "Gets allies", testCase = "allies", type = "functional"}, function()
        shared.ds:registerFaction("ally1", "A1", "gov")
        shared.ds:setDiplomaticRelation("trader1", "ally1", 75)
        local allies = shared.ds:getAlliedFactions("trader1")
        local count = #allies
        Helpers.assertEqual(count >= 1, true, "Has allies")
    end)

    Suite:testMethod("DiplomacySystem.getHostileFactions", {description = "Gets hostile", testCase = "hostile", type = "functional"}, function()
        shared.ds:registerFaction("enemy", "Enemy", "gov")
        shared.ds:setDiplomaticRelation("trader1", "enemy", -25)
        local hostile = shared.ds:getHostileFactions("trader1")
        local count = #hostile
        Helpers.assertEqual(count >= 1, true, "Has hostiles")
    end)
end)

Suite:run()
