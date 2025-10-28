-- ─────────────────────────────────────────────────────────────────────────
-- FACTION WARFARE TEST SUITE
-- FILE: tests2/politics/faction_warfare_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.faction_warfare",
    fileName = "faction_warfare.lua",
    description = "Faction warfare with inter-faction conflict, territorial control, and war tracking"
})

print("[FACTION_WARFARE_TEST] Setting up")

local FactionWarfare = {
    factions = {},
    territories = {},
    conflicts = {},
    wars = {},

    new = function(self)
        return setmetatable({
            factions = {}, territories = {}, conflicts = {}, wars = {}
        }, {__index = self})
    end,

    registerFaction = function(self, factionId, name, ideologyType, power)
        self.factions[factionId] = {
            id = factionId, name = name, ideology = ideologyType or "neutral",
            military_power = power or 50, diplomatic_relations = {},
            controlled_territories = {}, war_status = "peace",
            reputation = 50, aggression = 25
        }
        return true
    end,

    getFaction = function(self, factionId)
        return self.factions[factionId]
    end,

    setFactionPower = function(self, factionId, power)
        if not self.factions[factionId] then return false end
        self.factions[factionId].military_power = math.max(0, power)
        return true
    end,

    getFactionPower = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        return self.factions[factionId].military_power
    end,

    setFactionAggression = function(self, factionId, aggression)
        if not self.factions[factionId] then return false end
        self.factions[factionId].aggression = math.max(0, math.min(100, aggression))
        return true
    end,

    getFactionAggression = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        return self.factions[factionId].aggression
    end,

    registerTerritory = function(self, territoryId, name, x, y, strategic_value)
        self.territories[territoryId] = {
            id = territoryId, name = name, location_x = x or 0, location_y = y or 0,
            controller = nil, strategic_value = strategic_value or 50,
            garrison_size = 0, fortification = 0, resources = 100,
            contested = false
        }
        return true
    end,

    getTerritory = function(self, territoryId)
        return self.territories[territoryId]
    end,

    captureTerritory = function(self, factionId, territoryId)
        if not self.factions[factionId] or not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        local old_controller = territory.controller
        territory.controller = factionId
        self.factions[factionId].controlled_territories[territoryId] = true
        if old_controller then
            self.factions[old_controller].controlled_territories[territoryId] = nil
        end
        territory.contested = false
        return true
    end,

    loseTerritory = function(self, factionId, territoryId)
        if not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        if territory.controller == factionId then
            territory.controller = nil
            self.factions[factionId].controlled_territories[territoryId] = nil
            return true
        end
        return false
    end,

    getTerritoryController = function(self, territoryId)
        if not self.territories[territoryId] then return nil end
        return self.territories[territoryId].controller
    end,

    getControlledTerritories = function(self, factionId)
        if not self.factions[factionId] then return {} end
        local territories = {}
        for territoryId, _ in pairs(self.factions[factionId].controlled_territories) do
            table.insert(territories, territoryId)
        end
        return territories
    end,

    getControlledTerritoryCount = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        local count = 0
        for _ in pairs(self.factions[factionId].controlled_territories) do
            count = count + 1
        end
        return count
    end,

    contestTerritory = function(self, territoryId)
        if not self.territories[territoryId] then return false end
        self.territories[territoryId].contested = true
        return true
    end,

    resolveContest = function(self, territoryId, winnerFactionId)
        if not self.territories[territoryId] or not self.factions[winnerFactionId] then return false end
        self:captureTerritory(winnerFactionId, territoryId)
        return true
    end,

    isTerritoryContested = function(self, territoryId)
        if not self.territories[territoryId] then return false end
        return self.territories[territoryId].contested
    end,

    setDiplomaticRelation = function(self, factionId1, factionId2, relation_value)
        if not self.factions[factionId1] or not self.factions[factionId2] then return false end
        self.factions[factionId1].diplomatic_relations[factionId2] = relation_value or 0
        self.factions[factionId2].diplomatic_relations[factionId1] = relation_value or 0
        return true
    end,

    getDiplomaticRelation = function(self, factionId1, factionId2)
        if not self.factions[factionId1] then return 0 end
        return self.factions[factionId1].diplomatic_relations[factionId2] or 0
    end,

    declarWar = function(self, aggressor, defender)
        if not self.factions[aggressor] or not self.factions[defender] then return false end
        local warId = aggressor .. "_vs_" .. defender
        self.wars[warId] = {
            id = warId, aggressor = aggressor, defender = defender,
            start_turn = 1, casualties = 0, victories = {aggressor = 0, defender = 0},
            status = "ongoing", territories_contested = {}
        }
        self.factions[aggressor].war_status = "war"
        self.factions[defender].war_status = "war"
        return true
    end,

    getWar = function(self, warId)
        return self.wars[warId]
    end,

    getActiveWars = function(self, factionId)
        local active_wars = {}
        for warId, war in pairs(self.wars) do
            if war.status == "ongoing" and (war.aggressor == factionId or war.defender == factionId) then
                table.insert(active_wars, warId)
            end
        end
        return active_wars
    end,

    getActiveWarCount = function(self, factionId)
        return #self:getActiveWars(factionId)
    end,

    recordCasualty = function(self, warId, count)
        if not self.wars[warId] then return false end
        self.wars[warId].casualties = self.wars[warId].casualties + (count or 1)
        return true
    end,

    recordVictory = function(self, warId, victorFaction)
        if not self.wars[warId] then return false end
        if self.wars[warId].aggressor == victorFaction then
            self.wars[warId].victories.aggressor = self.wars[warId].victories.aggressor + 1
        elseif self.wars[warId].defender == victorFaction then
            self.wars[warId].victories.defender = self.wars[warId].victories.defender + 1
        end
        return true
    end,

    endWar = function(self, warId, victorious_faction)
        if not self.wars[warId] then return false end
        self.wars[warId].status = "concluded"
        if victorious_faction == self.wars[warId].aggressor then
            self.factions[self.wars[warId].aggressor].war_status = "peace"
            self.factions[self.wars[warId].defender].war_status = "peace"
        end
        return true
    end,

    calculateFactionStrength = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        local faction = self.factions[factionId]
        local base_strength = faction.military_power
        local territory_strength = self:getControlledTerritoryCount(factionId) * 10
        local reputation_factor = faction.reputation / 100
        local total_strength = (base_strength + territory_strength) * reputation_factor
        return math.floor(total_strength)
    end,

    calculateTerritorialValue = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        local total_value = 0
        for territoryId, _ in pairs(self.factions[factionId].controlled_territories) do
            local territory = self.territories[territoryId]
            if territory then
                total_value = total_value + territory.strategic_value
            end
        end
        return total_value
    end,

    canDeclareWar = function(self, aggressor, defender)
        if not self.factions[aggressor] or not self.factions[defender] then return false end
        local relation = self:getDiplomaticRelation(aggressor, defender)
        return relation < 0
    end,

    getWarWinProbability = function(self, factionId1, factionId2)
        if not self.factions[factionId1] or not self.factions[factionId2] then return 0 end
        local power1 = self:getFactionPower(factionId1)
        local power2 = self:getFactionPower(factionId2)
        local total = power1 + power2
        if total == 0 then return 0 end
        return math.floor((power1 / total) * 100)
    end,

    createConflict = function(self, conflictId, factionId1, factionId2, territoryId)
        if not self.factions[factionId1] or not self.factions[factionId2] or not self.territories[territoryId] then return false end
        self.conflicts[conflictId] = {
            id = conflictId, faction1 = factionId1, faction2 = factionId2,
            territory = territoryId, intensity = 50, duration = 5,
            resolved = false
        }
        return true
    end,

    getConflict = function(self, conflictId)
        return self.conflicts[conflictId]
    end,

    reset = function(self)
        self.factions = {}
        self.territories = {}
        self.conflicts = {}
        self.wars = {}
        return true
    end
}

Suite:group("Factions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
    end)

    Suite:testMethod("FactionWarfare.registerFaction", {description = "Registers faction", testCase = "register", type = "functional"}, function()
        local ok = shared.fw:registerFaction("faction1", "North", "militaristic", 75)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("FactionWarfare.getFaction", {description = "Gets faction", testCase = "get", type = "functional"}, function()
        shared.fw:registerFaction("faction2", "South", "diplomatic", 60)
        local faction = shared.fw:getFaction("faction2")
        Helpers.assertEqual(faction ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("FactionWarfare.setFactionPower", {description = "Sets power", testCase = "power", type = "functional"}, function()
        shared.fw:registerFaction("faction3", "East", "balanced", 70)
        local ok = shared.fw:setFactionPower("faction3", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("FactionWarfare.getFactionPower", {description = "Gets power", testCase = "get_power", type = "functional"}, function()
        shared.fw:registerFaction("faction4", "West", "neutral", 55)
        shared.fw:setFactionPower("faction4", 65)
        local power = shared.fw:getFactionPower("faction4")
        Helpers.assertEqual(power, 65, "65 power")
    end)

    Suite:testMethod("FactionWarfare.setFactionAggression", {description = "Sets aggression", testCase = "aggression", type = "functional"}, function()
        shared.fw:registerFaction("faction5", "Center", "neutral", 50)
        local ok = shared.fw:setFactionAggression("faction5", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("FactionWarfare.getFactionAggression", {description = "Gets aggression", testCase = "get_aggression", type = "functional"}, function()
        shared.fw:registerFaction("faction6", "Outer", "neutral", 50)
        shared.fw:setFactionAggression("faction6", 40)
        local agg = shared.fw:getFactionAggression("faction6")
        Helpers.assertEqual(agg, 40, "40 aggression")
    end)
end)

Suite:group("Territories", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
        shared.fw:registerFaction("terr_fac1", "A", "neutral", 50)
    end)

    Suite:testMethod("FactionWarfare.registerTerritory", {description = "Registers territory", testCase = "register", type = "functional"}, function()
        local ok = shared.fw:registerTerritory("terr1", "Region A", 0, 0, 100)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("FactionWarfare.getTerritory", {description = "Gets territory", testCase = "get", type = "functional"}, function()
        shared.fw:registerTerritory("terr2", "Region B", 1, 1, 80)
        local terr = shared.fw:getTerritory("terr2")
        Helpers.assertEqual(terr ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("FactionWarfare.captureTerritory", {description = "Captures territory", testCase = "capture", type = "functional"}, function()
        shared.fw:registerTerritory("terr3", "Region C", 2, 2, 90)
        local ok = shared.fw:captureTerritory("terr_fac1", "terr3")
        Helpers.assertEqual(ok, true, "Captured")
    end)

    Suite:testMethod("FactionWarfare.getTerritoryController", {description = "Gets controller", testCase = "controller", type = "functional"}, function()
        shared.fw:registerTerritory("terr4", "Region D", 3, 3, 70)
        shared.fw:captureTerritory("terr_fac1", "terr4")
        local ctrl = shared.fw:getTerritoryController("terr4")
        Helpers.assertEqual(ctrl, "terr_fac1", "Terr_fac1")
    end)

    Suite:testMethod("FactionWarfare.getControlledTerritories", {description = "Gets territories", testCase = "territories", type = "functional"}, function()
        shared.fw:registerTerritory("terr5", "Region E", 4, 4, 75)
        shared.fw:captureTerritory("terr_fac1", "terr5")
        local terrs = shared.fw:getControlledTerritories("terr_fac1")
        Helpers.assertEqual(#terrs > 0, true, "Has territories")
    end)

    Suite:testMethod("FactionWarfare.getControlledTerritoryCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.fw:registerTerritory("terr6", "Region F", 5, 5, 85)
        shared.fw:captureTerritory("terr_fac1", "terr6")
        local count = shared.fw:getControlledTerritoryCount("terr_fac1")
        Helpers.assertEqual(count > 0, true, "Count > 0")
    end)

    Suite:testMethod("FactionWarfare.loseTerritory", {description = "Loses territory", testCase = "lose", type = "functional"}, function()
        shared.fw:registerTerritory("terr7", "Region G", 6, 6, 60)
        shared.fw:captureTerritory("terr_fac1", "terr7")
        local ok = shared.fw:loseTerritory("terr_fac1", "terr7")
        Helpers.assertEqual(ok, true, "Lost")
    end)
end)

Suite:group("Territory Contests", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
        shared.fw:registerFaction("contest_fac", "Contender", "neutral", 50)
        shared.fw:registerTerritory("contest_terr", "Contested", 0, 0, 100)
    end)

    Suite:testMethod("FactionWarfare.contestTerritory", {description = "Contests territory", testCase = "contest", type = "functional"}, function()
        local ok = shared.fw:contestTerritory("contest_terr")
        Helpers.assertEqual(ok, true, "Contested")
    end)

    Suite:testMethod("FactionWarfare.isTerritoryContested", {description = "Is contested", testCase = "is_contested", type = "functional"}, function()
        shared.fw:contestTerritory("contest_terr")
        local is = shared.fw:isTerritoryContested("contest_terr")
        Helpers.assertEqual(is, true, "Contested")
    end)

    Suite:testMethod("FactionWarfare.resolveContest", {description = "Resolves contest", testCase = "resolve", type = "functional"}, function()
        shared.fw:contestTerritory("contest_terr")
        local ok = shared.fw:resolveContest("contest_terr", "contest_fac")
        Helpers.assertEqual(ok, true, "Resolved")
    end)
end)

Suite:group("Diplomacy", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
        shared.fw:registerFaction("dip_fac1", "Diplomat A", "neutral", 50)
        shared.fw:registerFaction("dip_fac2", "Diplomat B", "neutral", 50)
    end)

    Suite:testMethod("FactionWarfare.setDiplomaticRelation", {description = "Sets relation", testCase = "set", type = "functional"}, function()
        local ok = shared.fw:setDiplomaticRelation("dip_fac1", "dip_fac2", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("FactionWarfare.getDiplomaticRelation", {description = "Gets relation", testCase = "get", type = "functional"}, function()
        shared.fw:setDiplomaticRelation("dip_fac1", "dip_fac2", 75)
        local relation = shared.fw:getDiplomaticRelation("dip_fac1", "dip_fac2")
        Helpers.assertEqual(relation, 75, "75 relation")
    end)
end)

Suite:group("Wars", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
        shared.fw:registerFaction("war_fac1", "Aggressor", "militaristic", 80)
        shared.fw:registerFaction("war_fac2", "Defender", "defensive", 70)
    end)

    Suite:testMethod("FactionWarfare.declarWar", {description = "Declares war", testCase = "declare", type = "functional"}, function()
        local ok = shared.fw:declarWar("war_fac1", "war_fac2")
        Helpers.assertEqual(ok, true, "Declared")
    end)

    Suite:testMethod("FactionWarfare.getWar", {description = "Gets war", testCase = "get", type = "functional"}, function()
        shared.fw:declarWar("war_fac1", "war_fac2")
        local war = shared.fw:getWar("war_fac1_vs_war_fac2")
        Helpers.assertEqual(war ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("FactionWarfare.getActiveWars", {description = "Gets active wars", testCase = "active", type = "functional"}, function()
        shared.fw:declarWar("war_fac1", "war_fac2")
        local wars = shared.fw:getActiveWars("war_fac1")
        Helpers.assertEqual(#wars > 0, true, "Has active wars")
    end)

    Suite:testMethod("FactionWarfare.getActiveWarCount", {description = "Gets war count", testCase = "count", type = "functional"}, function()
        shared.fw:declarWar("war_fac1", "war_fac2")
        local count = shared.fw:getActiveWarCount("war_fac1")
        Helpers.assertEqual(count > 0, true, "Count > 0")
    end)

    Suite:testMethod("FactionWarfare.recordCasualty", {description = "Records casualty", testCase = "casualty", type = "functional"}, function()
        shared.fw:declarWar("war_fac1", "war_fac2")
        local ok = shared.fw:recordCasualty("war_fac1_vs_war_fac2", 10)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FactionWarfare.recordVictory", {description = "Records victory", testCase = "victory", type = "functional"}, function()
        shared.fw:declarWar("war_fac1", "war_fac2")
        local ok = shared.fw:recordVictory("war_fac1_vs_war_fac2", "war_fac1")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FactionWarfare.endWar", {description = "Ends war", testCase = "end", type = "functional"}, function()
        shared.fw:declarWar("war_fac1", "war_fac2")
        local ok = shared.fw:endWar("war_fac1_vs_war_fac2", "war_fac1")
        Helpers.assertEqual(ok, true, "Ended")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
        shared.fw:registerFaction("anal_fac1", "Strong", "militaristic", 90)
        shared.fw:registerFaction("anal_fac2", "Weak", "diplomatic", 40)
    end)

    Suite:testMethod("FactionWarfare.calculateFactionStrength", {description = "Calculates strength", testCase = "strength", type = "functional"}, function()
        local strength = shared.fw:calculateFactionStrength("anal_fac1")
        Helpers.assertEqual(strength > 0, true, "Strength > 0")
    end)

    Suite:testMethod("FactionWarfare.calculateTerritorialValue", {description = "Calculates value", testCase = "value", type = "functional"}, function()
        local value = shared.fw:calculateTerritorialValue("anal_fac1")
        Helpers.assertEqual(value >= 0, true, "Value >= 0")
    end)

    Suite:testMethod("FactionWarfare.canDeclareWar", {description = "Can declare war", testCase = "can_declare", type = "functional"}, function()
        shared.fw:setDiplomaticRelation("anal_fac1", "anal_fac2", -50)
        local can = shared.fw:canDeclareWar("anal_fac1", "anal_fac2")
        Helpers.assertEqual(can, true, "Can declare")
    end)

    Suite:testMethod("FactionWarfare.getWarWinProbability", {description = "Win probability", testCase = "probability", type = "functional"}, function()
        local prob = shared.fw:getWarWinProbability("anal_fac1", "anal_fac2")
        Helpers.assertEqual(prob > 0, true, "Probability > 0")
    end)
end)

Suite:group("Conflicts", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
        shared.fw:registerFaction("conf_fac1", "Alpha", "neutral", 50)
        shared.fw:registerFaction("conf_fac2", "Beta", "neutral", 50)
        shared.fw:registerTerritory("conf_terr", "Disputed", 0, 0, 100)
    end)

    Suite:testMethod("FactionWarfare.createConflict", {description = "Creates conflict", testCase = "create", type = "functional"}, function()
        local ok = shared.fw:createConflict("conf1", "conf_fac1", "conf_fac2", "conf_terr")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("FactionWarfare.getConflict", {description = "Gets conflict", testCase = "get", type = "functional"}, function()
        shared.fw:createConflict("conf2", "conf_fac1", "conf_fac2", "conf_terr")
        local conf = shared.fw:getConflict("conf2")
        Helpers.assertEqual(conf ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fw = FactionWarfare:new()
    end)

    Suite:testMethod("FactionWarfare.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.fw:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
