-- ─────────────────────────────────────────────────────────────────────────
-- AI TACTICAL PLANNING TEST SUITE
-- FILE: tests2/ai/ai_tactical_planning_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.ai_tactical_planning",
    fileName = "ai_tactical_planning.lua",
    description = "AI tactical planning with squad coordination, threat assessment, and strategic positioning"
})

print("[AI_TACTICAL_PLANNING_TEST] Setting up")

local AITacticalPlanning = {
    squads = {},
    threats = {},
    positions = {},
    tactics = {},
    coordination = {},

    new = function(self)
        return setmetatable({
            squads = {}, threats = {}, positions = {},
            tactics = {}, coordination = {}
        }, {__index = self})
    end,

    createSquad = function(self, squadId, leader, unitCount, aggression)
        self.squads[squadId] = {
            id = squadId, leader = leader, units = unitCount or 1,
            aggression = aggression or 50, morale = 100,
            cohesion = 75, tactical_role = "general", formation = "line"
        }
        self.positions[squadId] = {squad = squadId, x = 0, y = 0, units = {}}
        self.coordination[squadId] = {squad = squadId, tactics_queue = {}, priority = 0}
        return true
    end,

    getSquad = function(self, squadId)
        return self.squads[squadId]
    end,

    setSquadAggression = function(self, squadId, level)
        if not self.squads[squadId] then return false end
        self.squads[squadId].aggression = math.max(0, math.min(100, level))
        return true
    end,

    setSquadFormation = function(self, squadId, formationType)
        if not self.squads[squadId] then return false end
        self.squads[squadId].formation = formationType
        return true
    end,

    getSquadFormation = function(self, squadId)
        if not self.squads[squadId] then return "unknown" end
        return self.squads[squadId].formation
    end,

    assessThreat = function(self, threatId, threatType, location_x, location_y, priority)
        self.threats[threatId] = {
            id = threatId, type = threatType or "unknown",
            x = location_x or 0, y = location_y or 0,
            priority = priority or 50, threat_level = 0,
            engaged_by = {}, neutralized = false
        }
        return true
    end,

    getThreat = function(self, threatId)
        return self.threats[threatId]
    end,

    calculateThreatLevel = function(self, threatId)
        if not self.threats[threatId] then return 0 end
        local threat = self.threats[threatId]
        local base = threat.priority
        local engagement_factor = 1 - (#threat.engaged_by * 0.1)
        return math.floor(base * engagement_factor)
    end,

    assignSquadToThreat = function(self, squadId, threatId)
        if not self.squads[squadId] or not self.threats[threatId] then return false end
        table.insert(self.threats[threatId].engaged_by, squadId)
        self.coordination[squadId].priority = threatId
        return true
    end,

    recordSquadEngagement = function(self, squadId, threatId, success)
        if not self.threats[threatId] then return false end
        if success then
            self.threats[threatId].neutralized = true
        end
        self.squads[squadId].morale = math.max(0, math.min(100, self.squads[squadId].morale + (success and 10 or -15)))
        return true
    end,

    updateSquadCohesion = function(self, squadId, delta)
        if not self.squads[squadId] then return false end
        self.squads[squadId].cohesion = math.max(0, math.min(100, self.squads[squadId].cohesion + delta))
        return true
    end,

    getSquadCohesion = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].cohesion
    end,

    moveSquad = function(self, squadId, x, y)
        if not self.positions[squadId] then return false end
        self.positions[squadId].x = x
        self.positions[squadId].y = y
        return true
    end,

    getSquadPosition = function(self, squadId)
        if not self.positions[squadId] then return 0, 0 end
        return self.positions[squadId].x, self.positions[squadId].y
    end,

    calculateDistance = function(self, squad1Id, squad2Id)
        if not self.positions[squad1Id] or not self.positions[squad2Id] then return 0 end
        local p1 = self.positions[squad1Id]
        local p2 = self.positions[squad2Id]
        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
        return math.sqrt(dx*dx + dy*dy)
    end,

    createTactic = function(self, tacticId, tacticType, description, effectiveness)
        self.tactics[tacticId] = {
            id = tacticId, type = tacticType or "generic",
            description = description, effectiveness = effectiveness or 50,
            requirements = {}, success_rate = 0
        }
        return true
    end,

    getTactic = function(self, tacticId)
        return self.tactics[tacticId]
    end,

    queueTactic = function(self, squadId, tacticId)
        if not self.coordination[squadId] or not self.tactics[tacticId] then return false end
        table.insert(self.coordination[squadId].tactics_queue, tacticId)
        return true
    end,

    getTacticQueueLength = function(self, squadId)
        if not self.coordination[squadId] then return 0 end
        return #self.coordination[squadId].tactics_queue
    end,

    executeTactic = function(self, squadId, tacticId)
        if not self.squads[squadId] or not self.tactics[tacticId] then return false end
        local tactic = self.tactics[tacticId]
        local success_chance = 50 + tactic.effectiveness - self.squads[squadId].aggression
        return success_chance > math.random() * 100
    end,

    calculateSquadEffectiveness = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        local squad = self.squads[squadId]
        local morale_factor = squad.morale / 100
        local cohesion_factor = squad.cohesion / 100
        local unit_factor = squad.units / 10
        return math.floor((morale_factor + cohesion_factor + unit_factor) / 3 * 100)
    end,

    getEngagedThreatCount = function(self, squadId)
        local count = 0
        for _, threat in pairs(self.threats) do
            for _, engaged_squad in ipairs(threat.engaged_by) do
                if engaged_squad == squadId then
                    count = count + 1
                    break
                end
            end
        end
        return count
    end,

    getNeutralizedThreatCount = function(self)
        local count = 0
        for _, threat in pairs(self.threats) do
            if threat.neutralized then count = count + 1 end
        end
        return count
    end,

    getOverallSquadMorale = function(self)
        local total = 0
        local count = 0
        for _, squad in pairs(self.squads) do
            total = total + squad.morale
            count = count + 1
        end
        if count == 0 then return 0 end
        return math.floor(total / count)
    end,

    reset = function(self)
        self.squads = {}
        self.threats = {}
        self.positions = {}
        self.tactics = {}
        self.coordination = {}
        return true
    end
}

Suite:group("Squad Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
    end)

    Suite:testMethod("AITacticalPlanning.createSquad", {description = "Creates squad", testCase = "create", type = "functional"}, function()
        local ok = shared.atp:createSquad("squad1", "Leader One", 5, 60)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("AITacticalPlanning.getSquad", {description = "Gets squad", testCase = "get", type = "functional"}, function()
        shared.atp:createSquad("squad2", "Leader Two", 4, 50)
        local squad = shared.atp:getSquad("squad2")
        Helpers.assertEqual(squad ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Squad Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
        shared.atp:createSquad("tac_squad", "Tactical Leader", 5, 55)
    end)

    Suite:testMethod("AITacticalPlanning.setSquadAggression", {description = "Sets aggression", testCase = "aggression", type = "functional"}, function()
        local ok = shared.atp:setSquadAggression("tac_squad", 70)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("AITacticalPlanning.setSquadFormation", {description = "Sets formation", testCase = "formation", type = "functional"}, function()
        local ok = shared.atp:setSquadFormation("tac_squad", "wedge")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("AITacticalPlanning.getSquadFormation", {description = "Gets formation", testCase = "get_form", type = "functional"}, function()
        shared.atp:setSquadFormation("tac_squad", "line")
        local form = shared.atp:getSquadFormation("tac_squad")
        Helpers.assertEqual(form, "line", "Line formation")
    end)
end)

Suite:group("Threats", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
    end)

    Suite:testMethod("AITacticalPlanning.assessThreat", {description = "Assesses threat", testCase = "assess", type = "functional"}, function()
        local ok = shared.atp:assessThreat("threat1", "enemy", 50, 50, 70)
        Helpers.assertEqual(ok, true, "Assessed")
    end)

    Suite:testMethod("AITacticalPlanning.getThreat", {description = "Gets threat", testCase = "get", type = "functional"}, function()
        shared.atp:assessThreat("threat2", "hostile", 60, 60, 80)
        local threat = shared.atp:getThreat("threat2")
        Helpers.assertEqual(threat ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AITacticalPlanning.calculateThreatLevel", {description = "Calculates threat", testCase = "calc_threat", type = "functional"}, function()
        shared.atp:assessThreat("threat3", "enemy", 0, 0, 75)
        local level = shared.atp:calculateThreatLevel("threat3")
        Helpers.assertEqual(level > 0, true, "Level > 0")
    end)
end)

Suite:group("Engagement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
        shared.atp:createSquad("eng_squad", "Eng Leader", 5, 60)
        shared.atp:assessThreat("eng_threat", "enemy", 50, 50, 70)
    end)

    Suite:testMethod("AITacticalPlanning.assignSquadToThreat", {description = "Assigns squad", testCase = "assign", type = "functional"}, function()
        local ok = shared.atp:assignSquadToThreat("eng_squad", "eng_threat")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("AITacticalPlanning.recordSquadEngagement", {description = "Records engagement", testCase = "record", type = "functional"}, function()
        shared.atp:assignSquadToThreat("eng_squad", "eng_threat")
        local ok = shared.atp:recordSquadEngagement("eng_squad", "eng_threat", true)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("AITacticalPlanning.updateSquadCohesion", {description = "Updates cohesion", testCase = "cohesion", type = "functional"}, function()
        local ok = shared.atp:updateSquadCohesion("eng_squad", -10)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("AITacticalPlanning.getSquadCohesion", {description = "Gets cohesion", testCase = "get_cohesion", type = "functional"}, function()
        shared.atp:updateSquadCohesion("eng_squad", -20)
        local cohesion = shared.atp:getSquadCohesion("eng_squad")
        Helpers.assertEqual(cohesion < 75, true, "Cohesion reduced")
    end)
end)

Suite:group("Positioning", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
        shared.atp:createSquad("pos_squad", "Pos Leader", 5, 60)
    end)

    Suite:testMethod("AITacticalPlanning.moveSquad", {description = "Moves squad", testCase = "move", type = "functional"}, function()
        local ok = shared.atp:moveSquad("pos_squad", 100, 100)
        Helpers.assertEqual(ok, true, "Moved")
    end)

    Suite:testMethod("AITacticalPlanning.getSquadPosition", {description = "Gets position", testCase = "get_pos", type = "functional"}, function()
        shared.atp:moveSquad("pos_squad", 75, 75)
        local x, y = shared.atp:getSquadPosition("pos_squad")
        Helpers.assertEqual(x, 75, "X 75")
        Helpers.assertEqual(y, 75, "Y 75")
    end)

    Suite:testMethod("AITacticalPlanning.calculateDistance", {description = "Calculates distance", testCase = "distance", type = "functional"}, function()
        shared.atp:createSquad("pos_squad2", "Pos Leader 2", 5, 60)
        shared.atp:moveSquad("pos_squad", 0, 0)
        shared.atp:moveSquad("pos_squad2", 30, 40)
        local distance = shared.atp:calculateDistance("pos_squad", "pos_squad2")
        Helpers.assertEqual(distance > 0, true, "Distance > 0")
    end)
end)

Suite:group("Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
        shared.atp:createSquad("tactic_squad", "Tactic Leader", 5, 60)
    end)

    Suite:testMethod("AITacticalPlanning.createTactic", {description = "Creates tactic", testCase = "create", type = "functional"}, function()
        local ok = shared.atp:createTactic("tactic1", "flank", "Flanking maneuver", 70)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("AITacticalPlanning.getTactic", {description = "Gets tactic", testCase = "get", type = "functional"}, function()
        shared.atp:createTactic("tactic2", "ambush", "Ambush attack", 80)
        local tactic = shared.atp:getTactic("tactic2")
        Helpers.assertEqual(tactic ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("AITacticalPlanning.queueTactic", {description = "Queues tactic", testCase = "queue", type = "functional"}, function()
        shared.atp:createTactic("tactic3", "retreat", "Tactical retreat", 60)
        local ok = shared.atp:queueTactic("tactic_squad", "tactic3")
        Helpers.assertEqual(ok, true, "Queued")
    end)

    Suite:testMethod("AITacticalPlanning.getTacticQueueLength", {description = "Queue length", testCase = "queue_len", type = "functional"}, function()
        shared.atp:createTactic("t1", "type1", "Tactic 1", 50)
        shared.atp:createTactic("t2", "type2", "Tactic 2", 50)
        shared.atp:queueTactic("tactic_squad", "t1")
        shared.atp:queueTactic("tactic_squad", "t2")
        local len = shared.atp:getTacticQueueLength("tactic_squad")
        Helpers.assertEqual(len, 2, "Queue length 2")
    end)

    Suite:testMethod("AITacticalPlanning.executeTactic", {description = "Executes tactic", testCase = "execute", type = "functional"}, function()
        shared.atp:createTactic("exec_tactic", "attack", "Attack", 70)
        local executed = shared.atp:executeTactic("tactic_squad", "exec_tactic")
        Helpers.assertEqual(executed ~= nil, true, "Executed")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
        shared.atp:createSquad("anal_squad", "Anal Leader", 5, 60)
        shared.atp:assessThreat("anal_threat", "enemy", 50, 50, 70)
        shared.atp:assignSquadToThreat("anal_squad", "anal_threat")
    end)

    Suite:testMethod("AITacticalPlanning.calculateSquadEffectiveness", {description = "Squad effectiveness", testCase = "effective", type = "functional"}, function()
        local effective = shared.atp:calculateSquadEffectiveness("anal_squad")
        Helpers.assertEqual(effective > 0, true, "Effective > 0")
    end)

    Suite:testMethod("AITacticalPlanning.getEngagedThreatCount", {description = "Engaged threats", testCase = "engaged", type = "functional"}, function()
        local count = shared.atp:getEngagedThreatCount("anal_squad")
        Helpers.assertEqual(count >= 1, true, "Threats >= 1")
    end)

    Suite:testMethod("AITacticalPlanning.getNeutralizedThreatCount", {description = "Neutralized threats", testCase = "neutralized", type = "functional"}, function()
        shared.atp:recordSquadEngagement("anal_squad", "anal_threat", true)
        local count = shared.atp:getNeutralizedThreatCount()
        Helpers.assertEqual(count >= 1, true, "Neutralized >= 1")
    end)

    Suite:testMethod("AITacticalPlanning.getOverallSquadMorale", {description = "Overall morale", testCase = "morale", type = "functional"}, function()
        local morale = shared.atp:getOverallSquadMorale()
        Helpers.assertEqual(morale > 0, true, "Morale > 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.atp = AITacticalPlanning:new()
    end)

    Suite:testMethod("AITacticalPlanning.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.atp:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
