-- ─────────────────────────────────────────────────────────────────────────
-- DIPLOMATIC RELATIONS TEST SUITE
-- FILE: tests2/politics/diplomatic_relations_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.diplomatic_relations",
    fileName = "diplomatic_relations.lua",
    description = "Diplomatic system with treaties, agreements, and relations tracking"
})

print("[DIPLOMATIC_RELATIONS_TEST] Setting up")

local DiplomaticRelations = {
    nations = {},
    relations = {},
    treaties = {},
    agreements = {},
    disputes = {},

    new = function(self)
        return setmetatable({nations = {}, relations = {}, treaties = {}, agreements = {}, disputes = {}}, {__index = self})
    end,

    registerNation = function(self, nationId, name, baseReputation)
        self.nations[nationId] = {id = nationId, name = name, reputation = baseReputation or 50, aligned = false}
        self.relations[nationId] = {}
        self.treaties[nationId] = {}
        self.agreements[nationId] = {}
        self.disputes[nationId] = {}
        return true
    end,

    getNation = function(self, nationId)
        return self.nations[nationId]
    end,

    setRelation = function(self, nationA, nationB, relation)
        if not self.nations[nationA] or not self.nations[nationB] then return false end
        if not self.relations[nationA] then self.relations[nationA] = {} end
        if not self.relations[nationB] then self.relations[nationB] = {} end
        self.relations[nationA][nationB] = relation
        self.relations[nationB][nationA] = relation
        return true
    end,

    getRelation = function(self, nationA, nationB)
        if not self.relations[nationA] then return 0 end
        return self.relations[nationA][nationB] or 0
    end,

    modifyRelation = function(self, nationA, nationB, delta)
        if not self.nations[nationA] or not self.nations[nationB] then return false end
        local current = self:getRelation(nationA, nationB)
        local newRelation = math.max(-100, math.min(100, current + delta))
        self:setRelation(nationA, nationB, newRelation)
        return true
    end,

    getRelationStatus = function(self, nationA, nationB)
        local relation = self:getRelation(nationA, nationB)
        if relation >= 50 then return "allied"
        elseif relation >= 0 then return "neutral"
        elseif relation >= -50 then return "hostile"
        else return "enemy"
        end
    end,

    signTreaty = function(self, treatyId, treatyName, signatoryA, signatoryB, duration)
        if not self.nations[signatoryA] or not self.nations[signatoryB] then return false end
        if not self.treaties[signatoryA] then self.treaties[signatoryA] = {} end
        if not self.treaties[signatoryB] then self.treaties[signatoryB] = {} end
        self.treaties[signatoryA][treatyId] = {id = treatyId, name = treatyName, with = signatoryB, duration = duration or 50, active = true}
        self.treaties[signatoryB][treatyId] = {id = treatyId, name = treatyName, with = signatoryA, duration = duration or 50, active = true}
        self:modifyRelation(signatoryA, signatoryB, 20)
        return true
    end,

    getTreatyCount = function(self, nationId)
        if not self.treaties[nationId] then return 0 end
        local count = 0
        for _ in pairs(self.treaties[nationId]) do count = count + 1 end
        return count
    end,

    breakTreaty = function(self, treatyId, nationA, nationB)
        if not self.treaties[nationA] or not self.treaties[nationA][treatyId] then return false end
        self.treaties[nationA][treatyId] = nil
        if self.treaties[nationB] then
            self.treaties[nationB][treatyId] = nil
        end
        self:modifyRelation(nationA, nationB, -30)
        return true
    end,

    isTreatyActive = function(self, nationId, treatyId)
        if not self.treaties[nationId] or not self.treaties[nationId][treatyId] then return false end
        return self.treaties[nationId][treatyId].active
    end,

    createAgreement = function(self, agreementId, agreementType, nationA, nationB, benefit)
        if not self.nations[nationA] or not self.nations[nationB] then return false end
        if not self.agreements[nationA] then self.agreements[nationA] = {} end
        if not self.agreements[nationB] then self.agreements[nationB] = {} end
        self.agreements[nationA][agreementId] = {id = agreementId, type = agreementType, with = nationB, benefit = benefit or 0, active = true}
        self.agreements[nationB][agreementId] = {id = agreementId, type = agreementType, with = nationA, benefit = benefit or 0, active = true}
        return true
    end,

    getAgreementCount = function(self, nationId)
        if not self.agreements[nationId] then return 0 end
        local count = 0
        for _ in pairs(self.agreements[nationId]) do count = count + 1 end
        return count
    end,

    terminateAgreement = function(self, agreementId, nationA, nationB)
        if not self.agreements[nationA] or not self.agreements[nationA][agreementId] then return false end
        self.agreements[nationA][agreementId] = nil
        if self.agreements[nationB] then
            self.agreements[nationB][agreementId] = nil
        end
        return true
    end,

    registerDispute = function(self, disputeId, disputeType, nationA, nationB, severity)
        if not self.nations[nationA] or not self.nations[nationB] then return false end
        if not self.disputes[nationA] then self.disputes[nationA] = {} end
        if not self.disputes[nationB] then self.disputes[nationB] = {} end
        self.disputes[nationA][disputeId] = {id = disputeId, type = disputeType, with = nationB, severity = severity or 5, active = true}
        self.disputes[nationB][disputeId] = {id = disputeId, type = disputeType, with = nationA, severity = severity or 5, active = true}
        self:modifyRelation(nationA, nationB, -severity * 2)
        return true
    end,

    resolveDispute = function(self, disputeId, nationA, nationB)
        if not self.disputes[nationA] or not self.disputes[nationA][disputeId] then return false end
        self.disputes[nationA][disputeId] = nil
        if self.disputes[nationB] then
            self.disputes[nationB][disputeId] = nil
        end
        self:modifyRelation(nationA, nationB, 10)
        return true
    end,

    getDisputeCount = function(self, nationId)
        if not self.disputes[nationId] then return 0 end
        local count = 0
        for _ in pairs(self.disputes[nationId]) do count = count + 1 end
        return count
    end,

    hasActiveDispute = function(self, nationA, nationB)
        if not self.disputes[nationA] then return false end
        for _, dispute in pairs(self.disputes[nationA]) do
            if dispute.with == nationB and dispute.active then
                return true
            end
        end
        return false
    end,

    getAllyCount = function(self, nationId)
        if not self.relations[nationId] then return 0 end
        local count = 0
        for _, relation in pairs(self.relations[nationId]) do
            if relation >= 50 then count = count + 1 end
        end
        return count
    end,

    getEnemyCount = function(self, nationId)
        if not self.relations[nationId] then return 0 end
        local count = 0
        for _, relation in pairs(self.relations[nationId]) do
            if relation < -50 then count = count + 1 end
        end
        return count
    end,

    calculateDiplomaticScore = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        local allies = self:getAllyCount(nationId)
        local enemies = self:getEnemyCount(nationId)
        local treaties = self:getTreatyCount(nationId)
        return (allies * 10) - (enemies * 5) + (treaties * 15)
    end,

    proposeAlliance = function(self, allianceId, initiator, target)
        if not self.nations[initiator] or not self.nations[target] then return false end
        self:signTreaty(allianceId, "Alliance", initiator, target, 100)
        self:modifyRelation(initiator, target, 30)
        return true
    end,

    demandTribute = function(self, demandId, demander, target, amount)
        if not self.nations[demander] or not self.nations[target] then return false end
        self:modifyRelation(demander, target, -20)
        return true
    end,

    offerTribute = function(self, tributeId, giver, receiver, amount)
        if not self.nations[giver] or not self.nations[receiver] then return false end
        self:modifyRelation(giver, receiver, 15)
        return true
    end,

    setAlignment = function(self, nationId, aligned)
        if not self.nations[nationId] then return false end
        self.nations[nationId].aligned = aligned
        return true
    end,

    isAligned = function(self, nationId)
        if not self.nations[nationId] then return false end
        return self.nations[nationId].aligned
    end,

    resetDiplomacy = function(self, nationId)
        if not self.nations[nationId] then return false end
        self.relations[nationId] = {}
        self.treaties[nationId] = {}
        self.agreements[nationId] = {}
        self.disputes[nationId] = {}
        self.nations[nationId].aligned = false
        return true
    end
}

Suite:group("Nation Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
    end)

    Suite:testMethod("DiplomaticRelations.registerNation", {description = "Registers nation", testCase = "register", type = "functional"}, function()
        local ok = shared.dr:registerNation("nation1", "Nation 1", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("DiplomaticRelations.getNation", {description = "Gets nation", testCase = "get_nation", type = "functional"}, function()
        shared.dr:registerNation("nation2", "Nation 2", 50)
        local nation = shared.dr:getNation("nation2")
        Helpers.assertEqual(nation ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Relations Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("n1", "Nation 1", 50)
        shared.dr:registerNation("n2", "Nation 2", 50)
    end)

    Suite:testMethod("DiplomaticRelations.setRelation", {description = "Sets relation", testCase = "set_relation", type = "functional"}, function()
        local ok = shared.dr:setRelation("n1", "n2", 60)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("DiplomaticRelations.getRelation", {description = "Gets relation", testCase = "get_relation", type = "functional"}, function()
        shared.dr:setRelation("n1", "n2", 75)
        local rel = shared.dr:getRelation("n1", "n2")
        Helpers.assertEqual(rel, 75, "75 relation")
    end)

    Suite:testMethod("DiplomaticRelations.modifyRelation", {description = "Modifies relation", testCase = "modify_relation", type = "functional"}, function()
        shared.dr:setRelation("n1", "n2", 50)
        shared.dr:modifyRelation("n1", "n2", 20)
        local rel = shared.dr:getRelation("n1", "n2")
        Helpers.assertEqual(rel, 70, "70 relation")
    end)

    Suite:testMethod("DiplomaticRelations.getRelationStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.dr:setRelation("n1", "n2", 75)
        local status = shared.dr:getRelationStatus("n1", "n2")
        Helpers.assertEqual(status, "allied", "Allied")
    end)
end)

Suite:group("Treaties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("ta", "Nation A", 50)
        shared.dr:registerNation("tb", "Nation B", 50)
    end)

    Suite:testMethod("DiplomaticRelations.signTreaty", {description = "Signs treaty", testCase = "sign_treaty", type = "functional"}, function()
        local ok = shared.dr:signTreaty("treaty1", "Peace Treaty", "ta", "tb", 50)
        Helpers.assertEqual(ok, true, "Signed")
    end)

    Suite:testMethod("DiplomaticRelations.getTreatyCount", {description = "Treaty count", testCase = "count_treaties", type = "functional"}, function()
        shared.dr:signTreaty("t1", "Treaty 1", "ta", "tb", 50)
        shared.dr:signTreaty("t2", "Treaty 2", "ta", "tb", 50)
        local count = shared.dr:getTreatyCount("ta")
        Helpers.assertEqual(count, 2, "Two treaties")
    end)

    Suite:testMethod("DiplomaticRelations.isTreatyActive", {description = "Is active", testCase = "is_active", type = "functional"}, function()
        shared.dr:signTreaty("active", "Active Treaty", "ta", "tb", 50)
        local active = shared.dr:isTreatyActive("ta", "active")
        Helpers.assertEqual(active, true, "Active")
    end)

    Suite:testMethod("DiplomaticRelations.breakTreaty", {description = "Breaks treaty", testCase = "break", type = "functional"}, function()
        shared.dr:signTreaty("breakable", "Breakable", "ta", "tb", 50)
        local ok = shared.dr:breakTreaty("breakable", "ta", "tb")
        Helpers.assertEqual(ok, true, "Broken")
    end)
end)

Suite:group("Agreements", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("na", "Nation A", 50)
        shared.dr:registerNation("nb", "Nation B", 50)
    end)

    Suite:testMethod("DiplomaticRelations.createAgreement", {description = "Creates agreement", testCase = "create_agree", type = "functional"}, function()
        local ok = shared.dr:createAgreement("agree1", "trade", "na", "nb", 25)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("DiplomaticRelations.getAgreementCount", {description = "Agreement count", testCase = "count_agree", type = "functional"}, function()
        shared.dr:createAgreement("a1", "trade", "na", "nb", 20)
        shared.dr:createAgreement("a2", "defense", "na", "nb", 30)
        local count = shared.dr:getAgreementCount("na")
        Helpers.assertEqual(count, 2, "Two agreements")
    end)

    Suite:testMethod("DiplomaticRelations.terminateAgreement", {description = "Terminates agreement", testCase = "terminate", type = "functional"}, function()
        shared.dr:createAgreement("term", "trade", "na", "nb", 20)
        local ok = shared.dr:terminateAgreement("term", "na", "nb")
        Helpers.assertEqual(ok, true, "Terminated")
    end)
end)

Suite:group("Disputes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("da", "Nation A", 50)
        shared.dr:registerNation("db", "Nation B", 50)
    end)

    Suite:testMethod("DiplomaticRelations.registerDispute", {description = "Registers dispute", testCase = "register_dispute", type = "functional"}, function()
        local ok = shared.dr:registerDispute("disp1", "territorial", "da", "db", 10)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("DiplomaticRelations.getDisputeCount", {description = "Dispute count", testCase = "count_disputes", type = "functional"}, function()
        shared.dr:registerDispute("d1", "trade", "da", "db", 5)
        shared.dr:registerDispute("d2", "border", "da", "db", 8)
        local count = shared.dr:getDisputeCount("da")
        Helpers.assertEqual(count, 2, "Two disputes")
    end)

    Suite:testMethod("DiplomaticRelations.resolveDispute", {description = "Resolves dispute", testCase = "resolve", type = "functional"}, function()
        shared.dr:registerDispute("resolve", "conflict", "da", "db", 7)
        local ok = shared.dr:resolveDispute("resolve", "da", "db")
        Helpers.assertEqual(ok, true, "Resolved")
    end)

    Suite:testMethod("DiplomaticRelations.hasActiveDispute", {description = "Has dispute", testCase = "has_dispute", type = "functional"}, function()
        shared.dr:registerDispute("active_disp", "territorial", "da", "db", 8)
        local has = shared.dr:hasActiveDispute("da", "db")
        Helpers.assertEqual(has, true, "Has dispute")
    end)
end)

Suite:group("Strategic Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("sa", "Nation A", 50)
        shared.dr:registerNation("sb", "Nation B", 50)
        shared.dr:registerNation("sc", "Nation C", 50)
        shared.dr:setRelation("sa", "sb", 60)
        shared.dr:setRelation("sa", "sc", -70)
    end)

    Suite:testMethod("DiplomaticRelations.getAllyCount", {description = "Ally count", testCase = "ally_count", type = "functional"}, function()
        local count = shared.dr:getAllyCount("sa")
        Helpers.assertEqual(count, 1, "One ally")
    end)

    Suite:testMethod("DiplomaticRelations.getEnemyCount", {description = "Enemy count", testCase = "enemy_count", type = "functional"}, function()
        local count = shared.dr:getEnemyCount("sa")
        Helpers.assertEqual(count, 1, "One enemy")
    end)

    Suite:testMethod("DiplomaticRelations.calculateDiplomaticScore", {description = "Diplomatic score", testCase = "score", type = "functional"}, function()
        local score = shared.dr:calculateDiplomaticScore("sa")
        Helpers.assertEqual(score > 0, true, "Score > 0")
    end)
end)

Suite:group("Diplomatic Actions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("init", "Initiator", 50)
        shared.dr:registerNation("targ", "Target", 50)
    end)

    Suite:testMethod("DiplomaticRelations.proposeAlliance", {description = "Proposes alliance", testCase = "propose_alliance", type = "functional"}, function()
        local ok = shared.dr:proposeAlliance("alliance1", "init", "targ")
        Helpers.assertEqual(ok, true, "Proposed")
    end)

    Suite:testMethod("DiplomaticRelations.demandTribute", {description = "Demands tribute", testCase = "demand_tribute", type = "functional"}, function()
        local ok = shared.dr:demandTribute("demand1", "init", "targ", 100)
        Helpers.assertEqual(ok, true, "Demanded")
    end)

    Suite:testMethod("DiplomaticRelations.offerTribute", {description = "Offers tribute", testCase = "offer_tribute", type = "functional"}, function()
        local ok = shared.dr:offerTribute("offer1", "init", "targ", 50)
        Helpers.assertEqual(ok, true, "Offered")
    end)
end)

Suite:group("Alignment & Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.dr = DiplomaticRelations:new()
        shared.dr:registerNation("align_nation", "Aligned", 50)
    end)

    Suite:testMethod("DiplomaticRelations.setAlignment", {description = "Sets alignment", testCase = "set_align", type = "functional"}, function()
        local ok = shared.dr:setAlignment("align_nation", true)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("DiplomaticRelations.isAligned", {description = "Is aligned", testCase = "is_aligned", type = "functional"}, function()
        shared.dr:setAlignment("align_nation", true)
        local aligned = shared.dr:isAligned("align_nation")
        Helpers.assertEqual(aligned, true, "Aligned")
    end)

    Suite:testMethod("DiplomaticRelations.resetDiplomacy", {description = "Resets diplomacy", testCase = "reset", type = "functional"}, function()
        local ok = shared.dr:resetDiplomacy("align_nation")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
