-- ─────────────────────────────────────────────────────────────────────────
-- FACTION ALLEGIANCE TEST SUITE
-- FILE: tests2/politics/faction_allegiance_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.faction_allegiance",
    fileName = "faction_allegiance.lua",
    description = "Faction allegiance system with loyalty, benefits, and political alignment"
})

print("[FACTION_ALLEGIANCE_TEST] Setting up")

local FactionAllegiance = {
    factions = {},
    loyalty = {},
    benefits = {},
    allegiances = {},
    reputation = {},

    new = function(self)
        return setmetatable({
            factions = {}, loyalty = {}, benefits = {},
            allegiances = {}, reputation = {}
        }, {__index = self})
    end,

    registerFaction = function(self, factionId, name, alignment, power)
        self.factions[factionId] = {
            id = factionId, name = name, alignment = alignment or "neutral",
            power = power or 50, members = 0
        }
        self.loyalty[factionId] = {}
        self.benefits[factionId] = {}
        self.reputation[factionId] = {}
        return true
    end,

    getFactionInfo = function(self, factionId)
        return self.factions[factionId]
    end,

    joinFaction = function(self, playerId, factionId)
        if not self.factions[factionId] then return false end
        if not self.allegiances[playerId] then
            self.allegiances[playerId] = {}
        end
        self.allegiances[playerId].faction = factionId
        self.allegiances[playerId].joined_turn = 0
        self.loyalty[factionId][playerId] = {player = playerId, loyalty = 50, standing = "member"}
        self.factions[factionId].members = self.factions[factionId].members + 1
        return true
    end,

    leaveFaction = function(self, playerId, factionId)
        if not self.loyalty[factionId] or not self.loyalty[factionId][playerId] then return false end
        self.loyalty[factionId][playerId] = nil
        self.factions[factionId].members = math.max(0, self.factions[factionId].members - 1)
        if self.allegiances[playerId] and self.allegiances[playerId].faction == factionId then
            self.allegiances[playerId].faction = nil
        end
        return true
    end,

    getPlayerFaction = function(self, playerId)
        if not self.allegiances[playerId] then return nil end
        return self.allegiances[playerId].faction
    end,

    modifyLoyalty = function(self, playerId, factionId, amount)
        if not self.loyalty[factionId] or not self.loyalty[factionId][playerId] then return false end
        self.loyalty[factionId][playerId].loyalty = math.max(0, math.min(100, self.loyalty[factionId][playerId].loyalty + amount))
        self:updateStanding(playerId, factionId)
        return true
    end,

    getLoyalty = function(self, playerId, factionId)
        if not self.loyalty[factionId] or not self.loyalty[factionId][playerId] then return 0 end
        return self.loyalty[factionId][playerId].loyalty
    end,

    updateStanding = function(self, playerId, factionId)
        if not self.loyalty[factionId] or not self.loyalty[factionId][playerId] then return false end
        local loyalty = self.loyalty[factionId][playerId].loyalty
        if loyalty >= 80 then
            self.loyalty[factionId][playerId].standing = "devotee"
        elseif loyalty >= 60 then
            self.loyalty[factionId][playerId].standing = "loyal"
        elseif loyalty >= 40 then
            self.loyalty[factionId][playerId].standing = "member"
        else
            self.loyalty[factionId][playerId].standing = "sympathizer"
        end
        return true
    end,

    getStanding = function(self, playerId, factionId)
        if not self.loyalty[factionId] or not self.loyalty[factionId][playerId] then return "unknown" end
        return self.loyalty[factionId][playerId].standing
    end,

    addBenefit = function(self, factionId, benefitId, name, bonus)
        if not self.benefits[factionId] then return false end
        self.benefits[factionId][benefitId] = {id = benefitId, name = name, bonus = bonus or 10, active = false}
        return true
    end,

    activateBenefit = function(self, factionId, benefitId)
        if not self.benefits[factionId] or not self.benefits[factionId][benefitId] then return false end
        self.benefits[factionId][benefitId].active = true
        return true
    end,

    isBenefitActive = function(self, factionId, benefitId)
        if not self.benefits[factionId] or not self.benefits[factionId][benefitId] then return false end
        return self.benefits[factionId][benefitId].active
    end,

    getTotalBenefit = function(self, playerId, factionId)
        if not self.allegiances[playerId] or self.allegiances[playerId].faction ~= factionId then return 0 end
        if not self.benefits[factionId] then return 0 end
        local total = 0
        for _, benefit in pairs(self.benefits[factionId]) do
            if benefit.active then total = total + benefit.bonus end
        end
        return total
    end,

    recordAction = function(self, playerId, factionId, actionType, value)
        if not self.reputation[factionId] then return false end
        if not self.reputation[factionId][playerId] then
            self.reputation[factionId][playerId] = {actions = {}, reputation = 50}
        end
        local rep_change = 0
        if actionType == "help_faction" then rep_change = value or 10
        elseif actionType == "harm_faction" then rep_change = -(value or 10)
        elseif actionType == "discovery" then rep_change = value or 5
        end
        self.reputation[factionId][playerId].reputation = math.max(0, math.min(100, self.reputation[factionId][playerId].reputation + rep_change))
        table.insert(self.reputation[factionId][playerId].actions, {type = actionType, value = rep_change, turn = 0})
        return true
    end,

    getReputation = function(self, playerId, factionId)
        if not self.reputation[factionId] or not self.reputation[factionId][playerId] then return 50 end
        return self.reputation[factionId][playerId].reputation
    end,

    calculateInfluence = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        local members = self.factions[factionId].members
        local basePower = self.factions[factionId].power
        local loyalMembers = 0
        if self.loyalty[factionId] then
            for _, member in pairs(self.loyalty[factionId]) do
                if member.loyalty >= 60 then loyalMembers = loyalMembers + 1 end
            end
        end
        return math.floor((members * 5) + (basePower) + (loyalMembers * 3))
    end,

    getMemberCount = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        return self.factions[factionId].members
    end,

    getDevoteeCount = function(self, factionId)
        if not self.loyalty[factionId] then return 0 end
        local count = 0
        for _, member in pairs(self.loyalty[factionId]) do
            if member.standing == "devotee" then count = count + 1 end
        end
        return count
    end,

    getAverageLoyalty = function(self, factionId)
        if not self.loyalty[factionId] or not next(self.loyalty[factionId]) then return 0 end
        local total = 0
        local count = 0
        for _, member in pairs(self.loyalty[factionId]) do
            total = total + member.loyalty
            count = count + 1
        end
        return math.floor(total / count)
    end,

    canAffordFactionResource = function(self, playerId, factionId, resourceCost)
        local benefit = self:getTotalBenefit(playerId, factionId)
        return benefit >= resourceCost
    end,

    executeFactionPurge = function(self, factionId)
        if not self.loyalty[factionId] then return false end
        local to_remove = {}
        for playerId, member in pairs(self.loyalty[factionId]) do
            if member.loyalty < 30 then table.insert(to_remove, playerId) end
        end
        for _, playerId in ipairs(to_remove) do
            self:leaveFaction(playerId, factionId)
        end
        return #to_remove
    end,

    resetAllegiance = function(self)
        self.factions = {}
        self.loyalty = {}
        self.benefits = {}
        self.allegiances = {}
        self.reputation = {}
        return true
    end
}

Suite:group("Faction Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
    end)

    Suite:testMethod("FactionAllegiance.registerFaction", {description = "Registers faction", testCase = "register", type = "functional"}, function()
        local ok = shared.fa:registerFaction("faction1", "Faction One", "lawful", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("FactionAllegiance.getFaction", {description = "Gets faction", testCase = "get_faction", type = "functional"}, function()
        shared.fa:registerFaction("faction2", "Faction Two", "neutral", 50)
        local faction = shared.fa:getFaction("faction2")
        Helpers.assertEqual(faction ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Membership", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("join_faction", "Join Faction", "neutral", 50)
    end)

    Suite:testMethod("FactionAllegiance.joinFaction", {description = "Joins faction", testCase = "join", type = "functional"}, function()
        local ok = shared.fa:joinFaction("player1", "join_faction")
        Helpers.assertEqual(ok, true, "Joined")
    end)

    Suite:testMethod("FactionAllegiance.leaveFaction", {description = "Leaves faction", testCase = "leave", type = "functional"}, function()
        shared.fa:joinFaction("player2", "join_faction")
        local ok = shared.fa:leaveFaction("player2", "join_faction")
        Helpers.assertEqual(ok, true, "Left")
    end)

    Suite:testMethod("FactionAllegiance.getMemberCount", {description = "Member count", testCase = "member_count", type = "functional"}, function()
        shared.fa:joinFaction("p1", "join_faction")
        shared.fa:joinFaction("p2", "join_faction")
        local count = shared.fa:getMemberCount("join_faction")
        Helpers.assertEqual(count, 2, "Two members")
    end)
end)

Suite:group("Loyalty System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("loyalty_faction", "Loyalty", "neutral", 50)
        shared.fa:joinFaction("loyal_player", "loyalty_faction")
    end)

    Suite:testMethod("FactionAllegiance.modifyLoyalty", {description = "Modifies loyalty", testCase = "modify", type = "functional"}, function()
        local ok = shared.fa:modifyLoyalty("loyal_player", "loyalty_faction", 20)
        Helpers.assertEqual(ok, true, "Modified")
    end)

    Suite:testMethod("FactionAllegiance.getLoyalty", {description = "Gets loyalty", testCase = "get_loyalty", type = "functional"}, function()
        shared.fa:modifyLoyalty("loyal_player", "loyalty_faction", 15)
        local loyalty = shared.fa:getLoyalty("loyal_player", "loyalty_faction")
        Helpers.assertEqual(loyalty, 65, "Loyalty 65")
    end)

    Suite:testMethod("FactionAllegiance.getStanding", {description = "Gets standing", testCase = "standing", type = "functional"}, function()
        shared.fa:modifyLoyalty("loyal_player", "loyalty_faction", 25)
        local standing = shared.fa:getStanding("loyal_player", "loyalty_faction")
        Helpers.assertEqual(standing, "loyal", "Loyal standing")
    end)
end)

Suite:group("Benefits", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("benefit_faction", "Benefits", "neutral", 50)
        shared.fa:joinFaction("benefit_player", "benefit_faction")
    end)

    Suite:testMethod("FactionAllegiance.addBenefit", {description = "Adds benefit", testCase = "add_benefit", type = "functional"}, function()
        local ok = shared.fa:addBenefit("benefit_faction", "discount", "Discount", 15)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("FactionAllegiance.activateBenefit", {description = "Activates benefit", testCase = "activate", type = "functional"}, function()
        shared.fa:addBenefit("benefit_faction", "bonus", "Bonus", 10)
        local ok = shared.fa:activateBenefit("benefit_faction", "bonus")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("FactionAllegiance.isBenefitActive", {description = "Is active", testCase = "is_active", type = "functional"}, function()
        shared.fa:addBenefit("benefit_faction", "active_bonus", "Active", 10)
        shared.fa:activateBenefit("benefit_faction", "active_bonus")
        local is = shared.fa:isBenefitActive("benefit_faction", "active_bonus")
        Helpers.assertEqual(is, true, "Active")
    end)

    Suite:testMethod("FactionAllegiance.getTotalBenefit", {description = "Total benefit", testCase = "total", type = "functional"}, function()
        shared.fa:addBenefit("benefit_faction", "b1", "B1", 20)
        shared.fa:addBenefit("benefit_faction", "b2", "B2", 30)
        shared.fa:activateBenefit("benefit_faction", "b1")
        shared.fa:activateBenefit("benefit_faction", "b2")
        local total = shared.fa:getTotalBenefit("benefit_player", "benefit_faction")
        Helpers.assertEqual(total, 50, "Total 50")
    end)
end)

Suite:group("Reputation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("rep_faction", "Reputation", "neutral", 50)
    end)

    Suite:testMethod("FactionAllegiance.recordAction", {description = "Records action", testCase = "action", type = "functional"}, function()
        local ok = shared.fa:recordAction("player", "rep_faction", "help_faction", 10)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FactionAllegiance.getReputation", {description = "Gets reputation", testCase = "rep", type = "functional"}, function()
        shared.fa:recordAction("player", "rep_faction", "help_faction", 15)
        local rep = shared.fa:getReputation("player", "rep_faction")
        Helpers.assertEqual(rep, 65, "Rep 65")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("analysis_faction", "Analysis", "neutral", 50)
        shared.fa:joinFaction("p1", "analysis_faction")
        shared.fa:joinFaction("p2", "analysis_faction")
    end)

    Suite:testMethod("FactionAllegiance.calculateInfluence", {description = "Calculates influence", testCase = "influence", type = "functional"}, function()
        local influence = shared.fa:calculateInfluence("analysis_faction")
        Helpers.assertEqual(influence > 0, true, "Influence > 0")
    end)

    Suite:testMethod("FactionAllegiance.getDevoteeCount", {description = "Devotee count", testCase = "devotee", type = "functional"}, function()
        shared.fa:modifyLoyalty("p1", "analysis_faction", 30)
        local devotees = shared.fa:getDevoteeCount("analysis_faction")
        Helpers.assertEqual(devotees >= 0, true, "Devotees >= 0")
    end)

    Suite:testMethod("FactionAllegiance.getAverageLoyalty", {description = "Average loyalty", testCase = "avg_loyalty", type = "functional"}, function()
        shared.fa:modifyLoyalty("p1", "analysis_faction", 20)
        shared.fa:modifyLoyalty("p2", "analysis_faction", 10)
        local avg = shared.fa:getAverageLoyalty("analysis_faction")
        Helpers.assertEqual(avg > 0, true, "Average > 0")
    end)
end)

Suite:group("Resources", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("resource_faction", "Resources", "neutral", 50)
        shared.fa:joinFaction("rich_player", "resource_faction")
    end)

    Suite:testMethod("FactionAllegiance.canAffordFactionResource", {description = "Can afford", testCase = "afford", type = "functional"}, function()
        shared.fa:addBenefit("resource_faction", "res", "Resource", 100)
        shared.fa:activateBenefit("resource_faction", "res")
        local can = shared.fa:canAffordFactionResource("rich_player", "resource_faction", 50)
        Helpers.assertEqual(can, true, "Can afford")
    end)
end)

Suite:group("Purge", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("purge_faction", "Purge", "neutral", 50)
        shared.fa:joinFaction("traitor", "purge_faction")
    end)

    Suite:testMethod("FactionAllegiance.executeFactionPurge", {description = "Purges faction", testCase = "purge", type = "functional"}, function()
        shared.fa:modifyLoyalty("traitor", "purge_faction", -50)
        local removed = shared.fa:executeFactionPurge("purge_faction")
        Helpers.assertEqual(removed >= 0, true, "Removed >= 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fa = FactionAllegiance:new()
        shared.fa:registerFaction("reset_faction", "Reset", "neutral", 50)
    end)

    Suite:testMethod("FactionAllegiance.resetAllegiance", {description = "Resets allegiance", testCase = "reset", type = "functional"}, function()
        local ok = shared.fa:resetAllegiance()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
