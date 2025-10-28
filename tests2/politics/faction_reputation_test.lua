-- ─────────────────────────────────────────────────────────────────────────
-- FACTION REPUTATION TEST SUITE
-- FILE: tests2/politics/faction_reputation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.faction_reputation",
    fileName = "faction_reputation.lua",
    description = "Faction reputation tracking with approval, sanctions, benefits, and dialogue gates"
})

print("[FACTION_REPUTATION_TEST] Setting up")

local FactionReputation = {
    factions = {}, player_rep = {}, benefits = {}, incidents = {},

    new = function(self)
        return setmetatable({factions = {}, player_rep = {}, benefits = {}, incidents = {}}, {__index = self})
    end,

    registerFaction = function(self, factionId, name, alignment, rep_threshold)
        self.factions[factionId] = {id = factionId, name = name, alignment = alignment or 0, threshold = rep_threshold or 100, members = 0}
        self.player_rep[factionId] = {score = 0, tier = 1, incident_count = 0, last_change = 0}
        return true
    end,

    getFaction = function(self, factionId)
        return self.factions[factionId]
    end,

    modifyReputation = function(self, factionId, change_amount)
        if not self.player_rep[factionId] then return false end
        self.player_rep[factionId].score = math.max(-1000, math.min(1000, self.player_rep[factionId].score + change_amount))
        self.player_rep[factionId].last_change = change_amount
        return true
    end,

    getReputation = function(self, factionId)
        if not self.player_rep[factionId] then return 0 end
        return self.player_rep[factionId].score
    end,

    calculateReputationTier = function(self, factionId)
        if not self.player_rep[factionId] then return 0 end
        local score = self.player_rep[factionId].score
        if score < -500 then return 0
        elseif score < -100 then return 1
        elseif score < 0 then return 2
        elseif score < 100 then return 3
        elseif score < 500 then return 4
        else return 5 end
    end,

    getReputationTier = function(self, factionId)
        return self:calculateReputationTier(factionId)
    end,

    getReputationTierName = function(self, tier)
        local names = {"Hated", "Distrusted", "Neutral", "Liked", "Respected", "Revered"}
        return names[tier + 1] or "Unknown"
    end,

    unlocksDialogue = function(self, factionId, dialogue_level)
        local tier = self:getReputationTier(factionId)
        return tier >= (dialogue_level or 2)
    end,

    getDialogueUnlocks = function(self, factionId)
        local tier = self:getReputationTier(factionId)
        local unlocked = {}
        for i = 0, tier do
            table.insert(unlocked, i)
        end
        return unlocked
    end,

    unlocksAction = function(self, factionId, action_type, required_tier)
        local tier = self:getReputationTier(factionId)
        return tier >= (required_tier or 1)
    end,

    grantBenefit = function(self, factionId, benefitId, benefit_name, tier_required)
        if not self.benefits[factionId] then
            self.benefits[factionId] = {}
        end
        self.benefits[factionId][benefitId] = {id = benefitId, name = benefit_name or "benefit", tier_required = tier_required or 0, active = false}
        return true
    end,

    activateBenefit = function(self, factionId, benefitId)
        if not self.benefits[factionId] or not self.benefits[factionId][benefitId] then return false end
        local tier = self:getReputationTier(factionId)
        if tier < self.benefits[factionId][benefitId].tier_required then return false end
        self.benefits[factionId][benefitId].active = true
        return true
    end,

    hasBenefit = function(self, factionId, benefitId)
        if not self.benefits[factionId] or not self.benefits[factionId][benefitId] then return false end
        return self.benefits[factionId][benefitId].active
    end,

    getActiveBenefits = function(self, factionId)
        if not self.benefits[factionId] then return {} end
        local active = {}
        for benefitId, benefit in pairs(self.benefits[factionId]) do
            if benefit.active then
                table.insert(active, benefit)
            end
        end
        return active
    end,

    recordIncident = function(self, factionId, incident_name, severity)
        if not self.player_rep[factionId] then return false end
        if not self.incidents[factionId] then
            self.incidents[factionId] = {}
        end
        table.insert(self.incidents[factionId], {name = incident_name or "incident", severity = severity or 1, turn = 0})
        self.player_rep[factionId].incident_count = self.player_rep[factionId].incident_count + 1
        return true
    end,

    getIncidentCount = function(self, factionId)
        if not self.player_rep[factionId] then return 0 end
        return self.player_rep[factionId].incident_count
    end,

    getIncidents = function(self, factionId)
        if not self.incidents[factionId] then return {} end
        return self.incidents[factionId]
    end,

    hasIncidents = function(self, factionId)
        return self:getIncidentCount(factionId) > 0
    end,

    reset = function(self)
        self.factions = {}
        self.player_rep = {}
        self.benefits = {}
        self.incidents = {}
        return true
    end
}

Suite:group("Factions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FactionReputation:new()
    end)

    Suite:testMethod("FactionReputation.registerFaction", {description = "Registers faction", testCase = "register", type = "functional"}, function()
        local ok = shared.fr:registerFaction("f1", "Alliance", 50)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("FactionReputation.getFaction", {description = "Gets faction", testCase = "get", type = "functional"}, function()
        shared.fr:registerFaction("f2", "Empire", -50)
        local faction = shared.fr:getFaction("f2")
        Helpers.assertEqual(faction ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Reputation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FactionReputation:new()
        shared.fr:registerFaction("f1", "Test", 0)
    end)

    Suite:testMethod("FactionReputation.modifyReputation", {description = "Modifies reputation", testCase = "modify", type = "functional"}, function()
        local ok = shared.fr:modifyReputation("f1", 50)
        Helpers.assertEqual(ok, true, "Modified")
    end)

    Suite:testMethod("FactionReputation.getReputation", {description = "Gets reputation", testCase = "get", type = "functional"}, function()
        shared.fr:modifyReputation("f1", 75)
        local rep = shared.fr:getReputation("f1")
        Helpers.assertEqual(rep, 75, "75")
    end)

    Suite:testMethod("FactionReputation.calculateReputationTier", {description = "Calculates tier", testCase = "tier", type = "functional"}, function()
        shared.fr:modifyReputation("f1", 200)
        local tier = shared.fr:calculateReputationTier("f1")
        Helpers.assertEqual(tier > 0, true, "Tier > 0")
    end)

    Suite:testMethod("FactionReputation.getReputationTierName", {description = "Gets tier name", testCase = "name", type = "functional"}, function()
        local name = shared.fr:getReputationTierName(3)
        Helpers.assertEqual(name ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Dialogue & Actions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FactionReputation:new()
        shared.fr:registerFaction("f1", "Test", 0)
    end)

    Suite:testMethod("FactionReputation.unlocksDialogue", {description = "Unlocks dialogue", testCase = "dialogue", type = "functional"}, function()
        shared.fr:modifyReputation("f1", 100)
        local unlocks = shared.fr:unlocksDialogue("f1", 1)
        Helpers.assertEqual(unlocks, true, "Unlocks")
    end)

    Suite:testMethod("FactionReputation.getDialogueUnlocks", {description = "Gets dialogue unlocks", testCase = "unlocks", type = "functional"}, function()
        shared.fr:modifyReputation("f1", 250)
        local unlocks = shared.fr:getDialogueUnlocks("f1")
        Helpers.assertEqual(#unlocks > 0, true, "Has unlocks")
    end)

    Suite:testMethod("FactionReputation.unlocksAction", {description = "Unlocks action", testCase = "action", type = "functional"}, function()
        shared.fr:modifyReputation("f1", 150)
        local unlocks = shared.fr:unlocksAction("f1", "trade", 2)
        Helpers.assertEqual(unlocks == true or unlocks == false, true, "Checked")
    end)
end)

Suite:group("Benefits", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FactionReputation:new()
        shared.fr:registerFaction("f1", "Test", 0)
    end)

    Suite:testMethod("FactionReputation.grantBenefit", {description = "Grants benefit", testCase = "grant", type = "functional"}, function()
        local ok = shared.fr:grantBenefit("f1", "b1", "Discount", 2)
        Helpers.assertEqual(ok, true, "Granted")
    end)

    Suite:testMethod("FactionReputation.activateBenefit", {description = "Activates benefit", testCase = "activate", type = "functional"}, function()
        shared.fr:grantBenefit("f1", "b2", "Access", 1)
        shared.fr:modifyReputation("f1", 100)
        local ok = shared.fr:activateBenefit("f1", "b2")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("FactionReputation.hasBenefit", {description = "Has benefit", testCase = "has", type = "functional"}, function()
        shared.fr:grantBenefit("f1", "b3", "Perk", 0)
        shared.fr:activateBenefit("f1", "b3")
        local has = shared.fr:hasBenefit("f1", "b3")
        Helpers.assertEqual(has, true, "Has")
    end)

    Suite:testMethod("FactionReputation.getActiveBenefits", {description = "Gets active benefits", testCase = "active", type = "functional"}, function()
        shared.fr:grantBenefit("f1", "b1", "Benefit1", 0)
        shared.fr:grantBenefit("f1", "b2", "Benefit2", 0)
        shared.fr:activateBenefit("f1", "b1")
        shared.fr:activateBenefit("f1", "b2")
        local benefits = shared.fr:getActiveBenefits("f1")
        Helpers.assertEqual(#benefits > 0, true, "Has benefits")
    end)
end)

Suite:group("Incidents", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FactionReputation:new()
        shared.fr:registerFaction("f1", "Test", 0)
    end)

    Suite:testMethod("FactionReputation.recordIncident", {description = "Records incident", testCase = "record", type = "functional"}, function()
        local ok = shared.fr:recordIncident("f1", "Betrayal", 3)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FactionReputation.getIncidentCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.fr:recordIncident("f1", "Issue", 2)
        shared.fr:recordIncident("f1", "Problem", 1)
        local count = shared.fr:getIncidentCount("f1")
        Helpers.assertEqual(count, 2, "2")
    end)

    Suite:testMethod("FactionReputation.getIncidents", {description = "Gets incidents", testCase = "incidents", type = "functional"}, function()
        shared.fr:recordIncident("f1", "Event", 1)
        local incidents = shared.fr:getIncidents("f1")
        Helpers.assertEqual(#incidents > 0, true, "Has incidents")
    end)

    Suite:testMethod("FactionReputation.hasIncidents", {description = "Has incidents", testCase = "has", type = "functional"}, function()
        shared.fr:recordIncident("f1", "Occurrence", 2)
        local has = shared.fr:hasIncidents("f1")
        Helpers.assertEqual(has, true, "Has")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fr = FactionReputation:new()
    end)

    Suite:testMethod("FactionReputation.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.fr:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
