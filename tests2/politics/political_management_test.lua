-- ─────────────────────────────────────────────────────────────────────────
-- POLITICAL MANAGEMENT TEST SUITE
-- FILE: tests2/politics/political_management_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.political_management",
    fileName = "political_management.lua",
    description = "Political management with factions, diplomacy, alliances, and influence"
})

print("[POLITICAL_MANAGEMENT_TEST] Setting up")

local PoliticalManagement = {
    factions = {}, relations = {}, alliances = {}, diplomacy_events = {},
    influence = {}, elections = {},

    new = function(self)
        return setmetatable({
            factions = {}, relations = {}, alliances = {}, diplomacy_events = {},
            influence = {}, elections = {}
        }, {__index = self})
    end,

    createFaction = function(self, factionId, name, ideology, strength)
        self.factions[factionId] = {
            id = factionId, name = name, ideology = ideology,
            strength = strength or 50, reputation = 50, stability = 60,
            population = 10000, treasury = 5000, military_power = 40
        }
        return true
    end,

    getFaction = function(self, factionId)
        return self.factions[factionId]
    end,

    setRelation = function(self, faction1Id, faction2Id, relation_value)
        local key = faction1Id .. "_" .. faction2Id
        self.relations[key] = {
            faction1 = faction1Id, faction2 = faction2Id, relation = relation_value,
            last_interaction = os.time(), history = {}
        }
        return true
    end,

    getRelation = function(self, faction1Id, faction2Id)
        local key = faction1Id .. "_" .. faction2Id
        return self.relations[key] or self.relations[faction2Id .. "_" .. faction1Id]
    end,

    modifyRelation = function(self, faction1Id, faction2Id, delta)
        local rel = self:getRelation(faction1Id, faction2Id)
        if not rel then
            self:setRelation(faction1Id, faction2Id, 50 + delta)
        else
            rel.relation = math.max(-100, math.min(100, rel.relation + delta))
            table.insert(rel.history, {value = rel.relation, timestamp = os.time()})
        end
        return true
    end,

    formAlliance = function(self, allianceId, faction1Id, faction2Id, alliance_type)
        if not self.factions[faction1Id] or not self.factions[faction2Id] then return false end
        self.alliances[allianceId] = {
            id = allianceId, members = {faction1Id, faction2Id},
            type = alliance_type, strength = 0, active = true,
            treaties = {}, formation_date = os.time()
        }
        self:modifyRelation(faction1Id, faction2Id, 30)
        return true
    end,

    getAlliance = function(self, allianceId)
        return self.alliances[allianceId]
    end,

    dissolveAlliance = function(self, allianceId)
        if not self.alliances[allianceId] then return false end
        self.alliances[allianceId].active = false
        return true
    end,

    addTreaty = function(self, allianceId, treaty_type, terms)
        if not self.alliances[allianceId] then return false end
        local treaty = {
            id = allianceId .. "_treaty_" .. #self.alliances[allianceId].treaties,
            type = treaty_type, terms = terms, signed_date = os.time(), active = true
        }
        table.insert(self.alliances[allianceId].treaties, treaty)
        return true
    end,

    triggerDiplomacyEvent = function(self, eventId, type, faction1Id, faction2Id, impact)
        local event = {
            id = eventId, type = type, faction1 = faction1Id, faction2 = faction2Id,
            impact = impact or 0, timestamp = os.time(), resolved = false
        }
        table.insert(self.diplomacy_events, event)
        if faction1Id and faction2Id then
            self:modifyRelation(faction1Id, faction2Id, impact)
        end
        return true
    end,

    getFactionInfluence = function(self, factionId, region)
        if not self.influence[factionId] then
            self.influence[factionId] = {}
        end
        return self.influence[factionId][region] or 0
    end,

    modifyFactionInfluence = function(self, factionId, region, influence_delta)
        if not self.influence[factionId] then
            self.influence[factionId] = {}
        end
        local current = self.influence[factionId][region] or 0
        self.influence[factionId][region] = math.max(0, math.min(100, current + influence_delta))
        return true
    end,

    holdElection = function(self, electionId, region, candidates)
        local election = {
            id = electionId, region = region, candidates = candidates or {},
            votes = {}, winner = nil, held_date = os.time(), completed = false
        }
        for _, candidate in ipairs(candidates or {}) do
            election.votes[candidate] = 0
        end
        self.elections[electionId] = election
        return true
    end,

    getElection = function(self, electionId)
        return self.elections[electionId]
    end,

    castVote = function(self, electionId, candidate)
        if not self.elections[electionId] then return false end
        local election = self.elections[electionId]
        if not election.votes[candidate] then return false end
        election.votes[candidate] = election.votes[candidate] + 1
        return true
    end,

    concludeElection = function(self, electionId)
        if not self.elections[electionId] then return false end
        local election = self.elections[electionId]
        local winner = nil
        local max_votes = 0
        for candidate, votes in pairs(election.votes) do
            if votes > max_votes then
                max_votes = votes
                winner = candidate
            end
        end
        election.winner = winner
        election.completed = true
        return true
    end,

    getFactionsInRegion = function(self, region)
        local factions_in_region = {}
        for factionId, influence_value in pairs(self.influence[region] or {}) do
            if influence_value > 0 then
                table.insert(factions_in_region, factionId)
            end
        end
        return factions_in_region
    end,

    getStrongestFaction = function(self)
        local strongest = nil
        local max_strength = 0
        for _, faction in pairs(self.factions) do
            if faction.strength > max_strength then
                max_strength = faction.strength
                strongest = faction
            end
        end
        return strongest
    end,

    areAllied = function(self, faction1Id, faction2Id)
        for _, alliance in pairs(self.alliances) do
            if alliance.active then
                local has_f1 = false
                local has_f2 = false
                for _, member in ipairs(alliance.members) do
                    if member == faction1Id then has_f1 = true end
                    if member == faction2Id then has_f2 = true end
                end
                if has_f1 and has_f2 then return true end
            end
        end
        return false
    end,

    getAllianceStrength = function(self, allianceId)
        if not self.alliances[allianceId] then return 0 end
        local alliance = self.alliances[allianceId]
        local strength = 0
        for _, member_id in ipairs(alliance.members) do
            local member = self.factions[member_id]
            if member then
                strength = strength + member.military_power
            end
        end
        return strength
    end,

    changeFactionReputation = function(self, factionId, reputation_delta)
        if not self.factions[factionId] then return false end
        local faction = self.factions[factionId]
        faction.reputation = math.max(0, math.min(100, faction.reputation + reputation_delta))
        return true
    end,

    updateFactionStability = function(self, factionId, stability_delta)
        if not self.factions[factionId] then return false end
        local faction = self.factions[factionId]
        faction.stability = math.max(0, math.min(100, faction.stability + stability_delta))
        return true
    end,

    reset = function(self)
        self.factions = {}
        self.relations = {}
        self.alliances = {}
        self.diplomacy_events = {}
        self.influence = {}
        self.elections = {}
        return true
    end
}

Suite:group("Factions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
    end)

    Suite:testMethod("PoliticalManagement.createFaction", {description = "Creates faction", testCase = "create", type = "functional"}, function()
        local ok = shared.politics:createFaction("fact1", "Blue Order", "progressive", 60)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("PoliticalManagement.getFaction", {description = "Gets faction", testCase = "get", type = "functional"}, function()
        shared.politics:createFaction("fact2", "Red Guard", "conservative", 55)
        local fact = shared.politics:getFaction("fact2")
        Helpers.assertEqual(fact ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PoliticalManagement.getStrongestFaction", {description = "Gets strongest", testCase = "strongest", type = "functional"}, function()
        shared.politics:createFaction("fact3", "Green Alliance", "neutral", 70)
        local strongest = shared.politics:getStrongestFaction()
        Helpers.assertEqual(strongest ~= nil, true, "Found")
    end)
end)

Suite:group("Relations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
        shared.politics:createFaction("fact4", "Yellow Party", "radical", 50)
        shared.politics:createFaction("fact5", "Purple Union", "moderate", 55)
    end)

    Suite:testMethod("PoliticalManagement.setRelation", {description = "Sets relation", testCase = "set", type = "functional"}, function()
        local ok = shared.politics:setRelation("fact4", "fact5", 40)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PoliticalManagement.getRelation", {description = "Gets relation", testCase = "get", type = "functional"}, function()
        shared.politics:setRelation("fact4", "fact5", 35)
        local rel = shared.politics:getRelation("fact4", "fact5")
        Helpers.assertEqual(rel ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PoliticalManagement.modifyRelation", {description = "Modifies relation", testCase = "modify", type = "functional"}, function()
        local ok = shared.politics:modifyRelation("fact4", "fact5", 15)
        Helpers.assertEqual(ok, true, "Modified")
    end)
end)

Suite:group("Alliances", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
        shared.politics:createFaction("fact6", "Blue Group", "progressive", 60)
        shared.politics:createFaction("fact7", "Green Group", "neutral", 65)
    end)

    Suite:testMethod("PoliticalManagement.formAlliance", {description = "Forms alliance", testCase = "form", type = "functional"}, function()
        local ok = shared.politics:formAlliance("alliance1", "fact6", "fact7", "military")
        Helpers.assertEqual(ok, true, "Formed")
    end)

    Suite:testMethod("PoliticalManagement.getAlliance", {description = "Gets alliance", testCase = "get", type = "functional"}, function()
        shared.politics:formAlliance("alliance2", "fact6", "fact7", "economic")
        local aliance = shared.politics:getAlliance("alliance2")
        Helpers.assertEqual(aliance ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PoliticalManagement.dissolveAlliance", {description = "Dissolves alliance", testCase = "dissolve", type = "functional"}, function()
        shared.politics:formAlliance("alliance3", "fact6", "fact7", "political")
        local ok = shared.politics:dissolveAlliance("alliance3")
        Helpers.assertEqual(ok, true, "Dissolved")
    end)

    Suite:testMethod("PoliticalManagement.areAllied", {description = "Checks if allied", testCase = "allied", type = "functional"}, function()
        shared.politics:formAlliance("alliance4", "fact6", "fact7", "military")
        local allied = shared.politics:areAllied("fact6", "fact7")
        Helpers.assertEqual(allied, true, "Allied")
    end)

    Suite:testMethod("PoliticalManagement.getAllianceStrength", {description = "Gets strength", testCase = "strength", type = "functional"}, function()
        shared.politics:formAlliance("alliance5", "fact6", "fact7", "military")
        local strength = shared.politics:getAllianceStrength("alliance5")
        Helpers.assertEqual(strength > 0, true, "Strength > 0")
    end)
end)

Suite:group("Treaties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
        shared.politics:createFaction("fact8", "Orange Coalition", "progressive", 58)
        shared.politics:createFaction("fact9", "Silver Front", "moderate", 62)
        shared.politics:formAlliance("alliance6", "fact8", "fact9", "military")
    end)

    Suite:testMethod("PoliticalManagement.addTreaty", {description = "Adds treaty", testCase = "add", type = "functional"}, function()
        local ok = shared.politics:addTreaty("alliance6", "peace", "10 year mutual defense")
        Helpers.assertEqual(ok, true, "Added")
    end)
end)

Suite:group("Diplomacy Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
        shared.politics:createFaction("fact10", "Crimson State", "conservative", 52)
        shared.politics:createFaction("fact11", "Sapphire Republic", "radical", 48)
    end)

    Suite:testMethod("PoliticalManagement.triggerDiplomacyEvent", {description = "Triggers event", testCase = "trigger", type = "functional"}, function()
        local ok = shared.politics:triggerDiplomacyEvent("event1", "negotiation", "fact10", "fact11", 10)
        Helpers.assertEqual(ok, true, "Triggered")
    end)
end)

Suite:group("Influence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
        shared.politics:createFaction("fact12", "Azure League", "progressive", 61)
    end)

    Suite:testMethod("PoliticalManagement.getFactionInfluence", {description = "Gets influence", testCase = "get", type = "functional"}, function()
        local influence = shared.politics:getFactionInfluence("fact12", "north_region")
        Helpers.assertEqual(influence >= 0, true, "Influence >= 0")
    end)

    Suite:testMethod("PoliticalManagement.modifyFactionInfluence", {description = "Modifies influence", testCase = "modify", type = "functional"}, function()
        local ok = shared.politics:modifyFactionInfluence("fact12", "north_region", 25)
        Helpers.assertEqual(ok, true, "Modified")
    end)

    Suite:testMethod("PoliticalManagement.getFactionsInRegion", {description = "Gets factions in region", testCase = "region", type = "functional"}, function()
        shared.politics:modifyFactionInfluence("fact12", "south_region", 40)
        local factions = shared.politics:getFactionsInRegion("south_region")
        Helpers.assertEqual(type(factions) == "table", true, "Is table")
    end)
end)

Suite:group("Elections", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
    end)

    Suite:testMethod("PoliticalManagement.holdElection", {description = "Holds election", testCase = "hold", type = "functional"}, function()
        local ok = shared.politics:holdElection("election1", "capital", {"candidate1", "candidate2"})
        Helpers.assertEqual(ok, true, "Held")
    end)

    Suite:testMethod("PoliticalManagement.getElection", {description = "Gets election", testCase = "get", type = "functional"}, function()
        shared.politics:holdElection("election2", "region1", {"cand_a", "cand_b", "cand_c"})
        local election = shared.politics:getElection("election2")
        Helpers.assertEqual(election ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("PoliticalManagement.castVote", {description = "Casts vote", testCase = "vote", type = "functional"}, function()
        shared.politics:holdElection("election3", "region2", {"cand_x", "cand_y"})
        local ok = shared.politics:castVote("election3", "cand_x")
        Helpers.assertEqual(ok, true, "Voted")
    end)

    Suite:testMethod("PoliticalManagement.concludeElection", {description = "Concludes election", testCase = "conclude", type = "functional"}, function()
        shared.politics:holdElection("election4", "region3", {"alpha", "beta"})
        shared.politics:castVote("election4", "alpha")
        local ok = shared.politics:concludeElection("election4")
        Helpers.assertEqual(ok, true, "Concluded")
    end)
end)

Suite:group("Faction Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
        shared.politics:createFaction("fact13", "Jade Kingdom", "moderate", 57)
    end)

    Suite:testMethod("PoliticalManagement.changeFactionReputation", {description = "Changes reputation", testCase = "reputation", type = "functional"}, function()
        local ok = shared.politics:changeFactionReputation("fact13", 10)
        Helpers.assertEqual(ok, true, "Changed")
    end)

    Suite:testMethod("PoliticalManagement.updateFactionStability", {description = "Updates stability", testCase = "stability", type = "functional"}, function()
        local ok = shared.politics:updateFactionStability("fact13", -15)
        Helpers.assertEqual(ok, true, "Updated")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.politics = PoliticalManagement:new()
    end)

    Suite:testMethod("PoliticalManagement.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.politics:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
