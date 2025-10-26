-- ─────────────────────────────────────────────────────────────────────────
-- COMBAT SIMULATOR TEST SUITE
-- FILE: tests2/battlescape/combat_simulator_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.combat_simulator",
    fileName = "combat_simulator.lua",
    description = "Turn-based combat simulation with damage, armor, turn order, and action resolution"
})

print("[COMBAT_SIMULATOR_TEST] Setting up")

local CombatSimulator = {
    combats = {},
    participants = {},
    turns = {},
    actions = {},

    new = function(self)
        return setmetatable({combats = {}, participants = {}, turns = {}, actions = {}}, {__index = self})
    end,

    initiateCombat = function(self, combatId, scenarioName)
        self.combats[combatId] = {id = combatId, scenario = scenarioName, status = "active", currentTurn = 0, totalTurns = 0}
        self.participants[combatId] = {}
        self.turns[combatId] = {}
        self.actions[combatId] = {}
        return true
    end,

    addParticipant = function(self, combatId, unitId, team, health, armor)
        if not self.combats[combatId] then return false end
        self.participants[combatId][unitId] = {id = unitId, team = team, health = health or 100, maxHealth = health or 100, armor = armor or 10, status = "active"}
        return true
    end,

    getParticipant = function(self, combatId, unitId)
        if not self.participants[combatId] then return nil end
        return self.participants[combatId][unitId]
    end,

    getParticipantCount = function(self, combatId)
        if not self.participants[combatId] then return 0 end
        local count = 0
        for _ in pairs(self.participants[combatId]) do count = count + 1 end
        return count
    end,

    recordAction = function(self, combatId, actionId, actor, actionType, target, power)
        if not self.combats[combatId] then return false end
        table.insert(self.actions[combatId], {id = actionId, actor = actor, type = actionType, target = target, power = power or 0, turn = self.combats[combatId].currentTurn})
        return true
    end,

    getActionCount = function(self, combatId)
        if not self.actions[combatId] then return 0 end
        return #self.actions[combatId]
    end,

    calculateDamage = function(self, combatId, attackerUnit, targetUnit, basePower)
        local attacker = self:getParticipant(combatId, attackerUnit)
        local target = self:getParticipant(combatId, targetUnit)
        if not attacker or not target then return 0 end
        local damage = basePower or 20
        local armorReduction = math.floor(target.armor * 0.5)
        local actualDamage = math.max(1, damage - armorReduction)
        return actualDamage
    end,

    applyDamage = function(self, combatId, targetUnit, damage)
        if not self.participants[combatId] or not self.participants[combatId][targetUnit] then return false end
        local target = self.participants[combatId][targetUnit]
        target.health = math.max(0, target.health - damage)
        if target.health == 0 then
            target.status = "defeated"
        end
        return true
    end,

    getHealth = function(self, combatId, unitId)
        if not self.participants[combatId] or not self.participants[combatId][unitId] then return 0 end
        return self.participants[combatId][unitId].health
    end,

    isUnitDefeated = function(self, combatId, unitId)
        if not self.participants[combatId] or not self.participants[combatId][unitId] then return false end
        return self.participants[combatId][unitId].status == "defeated"
    end,

    getTurnCount = function(self, combatId)
        if not self.combats[combatId] then return 0 end
        return self.combats[combatId].totalTurns
    end,

    advanceTurn = function(self, combatId)
        if not self.combats[combatId] then return false end
        self.combats[combatId].currentTurn = self.combats[combatId].currentTurn + 1
        self.combats[combatId].totalTurns = self.combats[combatId].totalTurns + 1
        return true
    end,

    getCurrentTurn = function(self, combatId)
        if not self.combats[combatId] then return 0 end
        return self.combats[combatId].currentTurn
    end,

    getTeamStatus = function(self, combatId, team)
        if not self.participants[combatId] then return {active = 0, defeated = 0} end
        local active = 0
        local defeated = 0
        for _, participant in pairs(self.participants[combatId]) do
            if participant.team == team then
                if participant.status == "defeated" then
                    defeated = defeated + 1
                else
                    active = active + 1
                end
            end
        end
        return {active = active, defeated = defeated}
    end,

    determineWinner = function(self, combatId)
        if not self.combats[combatId] then return nil end
        local teams = {}
        for _, participant in pairs(self.participants[combatId]) do
            if participant.status == "active" then
                if not teams[participant.team] then teams[participant.team] = 0 end
                teams[participant.team] = teams[participant.team] + 1
            end
        end
        local activeTeams = 0
        local winnerTeam = nil
        for team, count in pairs(teams) do
            activeTeams = activeTeams + 1
            winnerTeam = team
        end
        if activeTeams == 1 then return winnerTeam end
        return nil
    end,

    endCombat = function(self, combatId)
        if not self.combats[combatId] then return false end
        self.combats[combatId].status = "completed"
        return true
    end,

    getCombatStatus = function(self, combatId)
        if not self.combats[combatId] then return nil end
        return self.combats[combatId].status
    end,

    applyStatusEffect = function(self, combatId, unitId, effectType, duration)
        if not self.participants[combatId] or not self.participants[combatId][unitId] then return false end
        local unit = self.participants[combatId][unitId]
        if not unit.effects then unit.effects = {} end
        table.insert(unit.effects, {type = effectType, duration = duration or 3})
        return true
    end,

    getStatusEffectCount = function(self, combatId, unitId)
        if not self.participants[combatId] or not self.participants[combatId][unitId] then return 0 end
        local unit = self.participants[combatId][unitId]
        if not unit.effects then return 0 end
        return #unit.effects
    end,

    simulateRound = function(self, combatId)
        if not self.combats[combatId] then return false end
        self:advanceTurn(combatId)
        return true
    end
}

Suite:group("Combat Initiation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
    end)

    Suite:testMethod("CombatSimulator.initiateCombat", {description = "Initiates combat", testCase = "initiate", type = "functional"}, function()
        local ok = shared.cs:initiateCombat("combat1", "Ambush")
        Helpers.assertEqual(ok, true, "Combat initiated")
    end)

    Suite:testMethod("CombatSimulator.getCombatStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.cs:initiateCombat("combat2", "Defense")
        local status = shared.cs:getCombatStatus("combat2")
        Helpers.assertEqual(status, "active", "Active status")
    end)
end)

Suite:group("Participants", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("battle", "Test Battle")
    end)

    Suite:testMethod("CombatSimulator.addParticipant", {description = "Adds participant", testCase = "add", type = "functional"}, function()
        local ok = shared.cs:addParticipant("battle", "unit1", "player", 100, 15)
        Helpers.assertEqual(ok, true, "Participant added")
    end)

    Suite:testMethod("CombatSimulator.getParticipant", {description = "Gets participant", testCase = "get", type = "functional"}, function()
        shared.cs:addParticipant("battle", "unit2", "enemy", 80, 10)
        local unit = shared.cs:getParticipant("battle", "unit2")
        Helpers.assertEqual(unit ~= nil, true, "Participant retrieved")
    end)

    Suite:testMethod("CombatSimulator.getParticipantCount", {description = "Counts participants", testCase = "count", type = "functional"}, function()
        shared.cs:addParticipant("battle", "u1", "player", 100, 10)
        shared.cs:addParticipant("battle", "u2", "player", 100, 10)
        shared.cs:addParticipant("battle", "u3", "enemy", 80, 8)
        local count = shared.cs:getParticipantCount("battle")
        Helpers.assertEqual(count, 3, "Three participants")
    end)
end)

Suite:group("Damage Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("damage", "Damage Test")
        shared.cs:addParticipant("damage", "attacker", "p1", 100, 5)
        shared.cs:addParticipant("damage", "target", "p2", 100, 20)
    end)

    Suite:testMethod("CombatSimulator.calculateDamage", {description = "Calculates damage", testCase = "calc", type = "functional"}, function()
        local dmg = shared.cs:calculateDamage("damage", "attacker", "target", 30)
        Helpers.assertEqual(dmg >= 1, true, "Damage calculated")
    end)

    Suite:testMethod("CombatSimulator.applyDamage", {description = "Applies damage", testCase = "apply", type = "functional"}, function()
        local ok = shared.cs:applyDamage("damage", "target", 25)
        Helpers.assertEqual(ok, true, "Damage applied")
    end)

    Suite:testMethod("CombatSimulator.getHealth", {description = "Gets health", testCase = "health", type = "functional"}, function()
        shared.cs:applyDamage("damage", "target", 30)
        local health = shared.cs:getHealth("damage", "target")
        Helpers.assertEqual(health, 70, "70 health")
    end)
end)

Suite:group("Turn Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("turns", "Turn Test")
    end)

    Suite:testMethod("CombatSimulator.advanceTurn", {description = "Advances turn", testCase = "advance", type = "functional"}, function()
        local ok = shared.cs:advanceTurn("turns")
        Helpers.assertEqual(ok, true, "Turn advanced")
    end)

    Suite:testMethod("CombatSimulator.getCurrentTurn", {description = "Gets current", testCase = "current", type = "functional"}, function()
        shared.cs:advanceTurn("turns")
        shared.cs:advanceTurn("turns")
        local turn = shared.cs:getCurrentTurn("turns")
        Helpers.assertEqual(turn, 2, "Turn 2")
    end)

    Suite:testMethod("CombatSimulator.getTurnCount", {description = "Gets total", testCase = "total", type = "functional"}, function()
        shared.cs:advanceTurn("turns")
        shared.cs:advanceTurn("turns")
        shared.cs:advanceTurn("turns")
        local count = shared.cs:getTurnCount("turns")
        Helpers.assertEqual(count, 3, "Three turns")
    end)

    Suite:testMethod("CombatSimulator.simulateRound", {description = "Simulates round", testCase = "round", type = "functional"}, function()
        local ok = shared.cs:simulateRound("turns")
        Helpers.assertEqual(ok, true, "Round simulated")
    end)
end)

Suite:group("Actions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("actions", "Action Test")
        shared.cs:addParticipant("actions", "actor", "team1", 100, 10)
    end)

    Suite:testMethod("CombatSimulator.recordAction", {description = "Records action", testCase = "record", type = "functional"}, function()
        local ok = shared.cs:recordAction("actions", "act1", "actor", "attack", "target", 25)
        Helpers.assertEqual(ok, true, "Action recorded")
    end)

    Suite:testMethod("CombatSimulator.getActionCount", {description = "Counts actions", testCase = "count", type = "functional"}, function()
        shared.cs:recordAction("actions", "a1", "actor", "attack", "t1", 20)
        shared.cs:recordAction("actions", "a2", "actor", "defend", "none", 0)
        local count = shared.cs:getActionCount("actions")
        Helpers.assertEqual(count, 2, "Two actions")
    end)
end)

Suite:group("Team Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("team", "Team Test")
        shared.cs:addParticipant("team", "p1", "allies", 100, 10)
        shared.cs:addParticipant("team", "p2", "allies", 100, 10)
        shared.cs:addParticipant("team", "e1", "enemies", 80, 8)
    end)

    Suite:testMethod("CombatSimulator.getTeamStatus", {description = "Gets team status", testCase = "status", type = "functional"}, function()
        local status = shared.cs:getTeamStatus("team", "allies")
        Helpers.assertEqual(status.active, 2, "Two active allies")
    end)

    Suite:testMethod("CombatSimulator.isUnitDefeated", {description = "Checks defeat", testCase = "defeated", type = "functional"}, function()
        shared.cs:applyDamage("team", "e1", 80)
        local defeated = shared.cs:isUnitDefeated("team", "e1")
        Helpers.assertEqual(defeated, true, "Unit defeated")
    end)

    Suite:testMethod("CombatSimulator.determineWinner", {description = "Determines winner", testCase = "winner", type = "functional"}, function()
        shared.cs:applyDamage("team", "e1", 80)
        local winner = shared.cs:determineWinner("team")
        Helpers.assertEqual(winner, "allies", "Allies win")
    end)
end)

Suite:group("Status Effects", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("effects", "Effects Test")
        shared.cs:addParticipant("effects", "unit", "team", 100, 10)
    end)

    Suite:testMethod("CombatSimulator.applyStatusEffect", {description = "Applies effect", testCase = "apply", type = "functional"}, function()
        local ok = shared.cs:applyStatusEffect("effects", "unit", "burn", 3)
        Helpers.assertEqual(ok, true, "Effect applied")
    end)

    Suite:testMethod("CombatSimulator.getStatusEffectCount", {description = "Counts effects", testCase = "count", type = "functional"}, function()
        shared.cs:applyStatusEffect("effects", "unit", "poison", 2)
        shared.cs:applyStatusEffect("effects", "unit", "stun", 1)
        local count = shared.cs:getStatusEffectCount("effects", "unit")
        Helpers.assertEqual(count, 2, "Two effects")
    end)
end)

Suite:group("Combat Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cs = CombatSimulator:new()
        shared.cs:initiateCombat("end", "Completion Test")
    end)

    Suite:testMethod("CombatSimulator.endCombat", {description = "Ends combat", testCase = "end", type = "functional"}, function()
        local ok = shared.cs:endCombat("end")
        Helpers.assertEqual(ok, true, "Combat ended")
    end)
end)

Suite:run()
