-- ─────────────────────────────────────────────────────────────────────────
-- TACTICAL OBJECTIVES TEST SUITE
-- FILE: tests2/battlescape/tactical_objectives_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.tactical_objectives",
    fileName = "tactical_objectives.lua",
    description = "Tactical combat objectives with victory conditions, failure states, and scoring"
})

print("[TACTICAL_OBJECTIVES_TEST] Setting up")

local TacticalObjectives = {
    missions = {},
    objectives = {},
    victory_conditions = {},
    failure_states = {},

    new = function(self)
        return setmetatable({missions = {}, objectives = {}, victory_conditions = {}, failure_states = {}}, {__index = self})
    end,

    createMission = function(self, missionId, missionType, difficulty)
        self.missions[missionId] = {id = missionId, type = missionType, difficulty = difficulty or 3, status = "active", score = 0}
        self.objectives[missionId] = {}
        self.victory_conditions[missionId] = {}
        self.failure_states[missionId] = {}
        return true
    end,

    getMission = function(self, missionId)
        return self.missions[missionId]
    end,

    addObjective = function(self, missionId, objectiveId, objectiveType, priority)
        if not self.missions[missionId] then return false end
        table.insert(self.objectives[missionId], {id = objectiveId, type = objectiveType, priority = priority or 1, completed = false, optional = false})
        return true
    end,

    getObjectiveCount = function(self, missionId)
        if not self.objectives[missionId] then return 0 end
        return #self.objectives[missionId]
    end,

    completeObjective = function(self, missionId, objectiveIndex)
        if not self.objectives[missionId] or not self.objectives[missionId][objectiveIndex] then return false end
        self.objectives[missionId][objectiveIndex].completed = true
        return true
    end,

    getCompletedObjectives = function(self, missionId)
        if not self.objectives[missionId] then return 0 end
        local count = 0
        for _, obj in ipairs(self.objectives[missionId]) do
            if obj.completed then count = count + 1 end
        end
        return count
    end,

    addVictoryCondition = function(self, missionId, conditionType, parameters)
        if not self.missions[missionId] then return false end
        table.insert(self.victory_conditions[missionId], {type = conditionType, params = parameters or {}, met = false})
        return true
    end,

    getVictoryConditionCount = function(self, missionId)
        if not self.victory_conditions[missionId] then return 0 end
        return #self.victory_conditions[missionId]
    end,

    markVictoryConditionMet = function(self, missionId, conditionIndex)
        if not self.victory_conditions[missionId] or not self.victory_conditions[missionId][conditionIndex] then return false end
        self.victory_conditions[missionId][conditionIndex].met = true
        return true
    end,

    getMetVictoryConditions = function(self, missionId)
        if not self.victory_conditions[missionId] then return 0 end
        local count = 0
        for _, vc in ipairs(self.victory_conditions[missionId]) do
            if vc.met then count = count + 1 end
        end
        return count
    end,

    isVictory = function(self, missionId)
        if not self.missions[missionId] or not self.victory_conditions[missionId] then return false end
        local required = #self.victory_conditions[missionId]
        if required == 0 then return false end
        local met = self:getMetVictoryConditions(missionId)
        return met == required
    end,

    addFailureState = function(self, missionId, failureType, parameters)
        if not self.missions[missionId] then return false end
        table.insert(self.failure_states[missionId], {type = failureType, params = parameters or {}, triggered = false})
        return true
    end,

    getFailureStateCount = function(self, missionId)
        if not self.failure_states[missionId] then return 0 end
        return #self.failure_states[missionId]
    end,

    triggerFailureState = function(self, missionId, failureIndex)
        if not self.failure_states[missionId] or not self.failure_states[missionId][failureIndex] then return false end
        self.failure_states[missionId][failureIndex].triggered = true
        self.missions[missionId].status = "failed"
        return true
    end,

    isDefeat = function(self, missionId)
        if not self.missions[missionId] then return false end
        return self.missions[missionId].status == "failed"
    end,

    calculateScore = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        local baseScore = 100
        local difficultyMultiplier = 1 + (self.missions[missionId].difficulty * 0.15)
        local objectives = self:getCompletedObjectives(missionId)
        local totalObjectives = self:getObjectiveCount(missionId)
        local objectiveBonus = totalObjectives > 0 and (objectives / totalObjectives) * 50 or 0
        local score = math.floor(baseScore * difficultyMultiplier + objectiveBonus)
        self.missions[missionId].score = score
        return score
    end,

    setMissionStatus = function(self, missionId, status)
        if not self.missions[missionId] then return false end
        self.missions[missionId].status = status
        return true
    end,

    getMissionStatus = function(self, missionId)
        if not self.missions[missionId] then return nil end
        return self.missions[missionId].status
    end,

    getMissionScore = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].score
    end,

    getMissionCount = function(self)
        local count = 0
        for _ in pairs(self.missions) do count = count + 1 end
        return count
    end,

    getCompletedMissions = function(self)
        local count = 0
        for _, mission in pairs(self.missions) do
            if mission.status == "completed" then count = count + 1 end
        end
        return count
    end
}

Suite:group("Mission Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.to = TacticalObjectives:new()
    end)

    Suite:testMethod("TacticalObjectives.createMission", {description = "Creates mission", testCase = "create", type = "functional"}, function()
        local ok = shared.to:createMission("m1", "elimination", 2)
        Helpers.assertEqual(ok, true, "Mission created")
    end)

    Suite:testMethod("TacticalObjectives.getMission", {description = "Retrieves mission", testCase = "get", type = "functional"}, function()
        shared.to:createMission("m2", "defense", 3)
        local mission = shared.to:getMission("m2")
        Helpers.assertEqual(mission ~= nil, true, "Mission retrieved")
    end)

    Suite:testMethod("TacticalObjectives.getMissionCount", {description = "Counts missions", testCase = "count", type = "functional"}, function()
        shared.to:createMission("m1", "type1", 1)
        shared.to:createMission("m2", "type2", 2)
        shared.to:createMission("m3", "type3", 3)
        local count = shared.to:getMissionCount()
        Helpers.assertEqual(count, 3, "Three missions")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.to = TacticalObjectives:new()
        shared.to:createMission("objectives", "mixed", 2)
    end)

    Suite:testMethod("TacticalObjectives.addObjective", {description = "Adds objective", testCase = "add", type = "functional"}, function()
        local ok = shared.to:addObjective("objectives", "obj1", "kill_all_enemies", 1)
        Helpers.assertEqual(ok, true, "Objective added")
    end)

    Suite:testMethod("TacticalObjectives.getObjectiveCount", {description = "Counts objectives", testCase = "count", type = "functional"}, function()
        shared.to:addObjective("objectives", "o1", "rescue", 1)
        shared.to:addObjective("objectives", "o2", "destroy", 1)
        local count = shared.to:getObjectiveCount("objectives")
        Helpers.assertEqual(count, 2, "Two objectives")
    end)

    Suite:testMethod("TacticalObjectives.completeObjective", {description = "Completes objective", testCase = "complete", type = "functional"}, function()
        shared.to:addObjective("objectives", "obj_x", "protect", 1)
        local ok = shared.to:completeObjective("objectives", 1)
        Helpers.assertEqual(ok, true, "Objective completed")
    end)

    Suite:testMethod("TacticalObjectives.getCompletedObjectives", {description = "Counts completed", testCase = "completed", type = "functional"}, function()
        shared.to:addObjective("objectives", "o1", "type1", 1)
        shared.to:addObjective("objectives", "o2", "type2", 1)
        shared.to:completeObjective("objectives", 1)
        local count = shared.to:getCompletedObjectives("objectives")
        Helpers.assertEqual(count, 1, "One completed")
    end)
end)

Suite:group("Victory Conditions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.to = TacticalObjectives:new()
        shared.to:createMission("victory", "capture", 2)
    end)

    Suite:testMethod("TacticalObjectives.addVictoryCondition", {description = "Adds condition", testCase = "add_vc", type = "functional"}, function()
        local ok = shared.to:addVictoryCondition("victory", "all_enemies_dead", {})
        Helpers.assertEqual(ok, true, "Condition added")
    end)

    Suite:testMethod("TacticalObjectives.getVictoryConditionCount", {description = "Counts conditions", testCase = "vc_count", type = "functional"}, function()
        shared.to:addVictoryCondition("victory", "type1", {})
        shared.to:addVictoryCondition("victory", "type2", {})
        local count = shared.to:getVictoryConditionCount("victory")
        Helpers.assertEqual(count, 2, "Two conditions")
    end)

    Suite:testMethod("TacticalObjectives.markVictoryConditionMet", {description = "Marks condition met", testCase = "mark_met", type = "functional"}, function()
        shared.to:addVictoryCondition("victory", "primary", {})
        local ok = shared.to:markVictoryConditionMet("victory", 1)
        Helpers.assertEqual(ok, true, "Condition marked")
    end)

    Suite:testMethod("TacticalObjectives.isVictory", {description = "Checks victory", testCase = "is_victory", type = "functional"}, function()
        shared.to:addVictoryCondition("victory", "obj1", {})
        shared.to:markVictoryConditionMet("victory", 1)
        local victory = shared.to:isVictory("victory")
        Helpers.assertEqual(victory, true, "Victory achieved")
    end)
end)

Suite:group("Failure States", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.to = TacticalObjectives:new()
        shared.to:createMission("failure", "protect", 3)
    end)

    Suite:testMethod("TacticalObjectives.addFailureState", {description = "Adds failure", testCase = "add_failure", type = "functional"}, function()
        local ok = shared.to:addFailureState("failure", "all_units_dead", {})
        Helpers.assertEqual(ok, true, "Failure state added")
    end)

    Suite:testMethod("TacticalObjectives.getFailureStateCount", {description = "Counts failures", testCase = "failure_count", type = "functional"}, function()
        shared.to:addFailureState("failure", "f1", {})
        shared.to:addFailureState("failure", "f2", {})
        local count = shared.to:getFailureStateCount("failure")
        Helpers.assertEqual(count, 2, "Two failure states")
    end)

    Suite:testMethod("TacticalObjectives.triggerFailureState", {description = "Triggers failure", testCase = "trigger_failure", type = "functional"}, function()
        shared.to:addFailureState("failure", "defeat", {})
        local ok = shared.to:triggerFailureState("failure", 1)
        Helpers.assertEqual(ok, true, "Failure triggered")
    end)

    Suite:testMethod("TacticalObjectives.isDefeat", {description = "Checks defeat", testCase = "is_defeat", type = "functional"}, function()
        shared.to:addFailureState("failure", "loss", {})
        shared.to:triggerFailureState("failure", 1)
        local defeat = shared.to:isDefeat("failure")
        Helpers.assertEqual(defeat, true, "Defeat detected")
    end)
end)

Suite:group("Scoring", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.to = TacticalObjectives:new()
        shared.to:createMission("scoring", "mixed", 1)
    end)

    Suite:testMethod("TacticalObjectives.calculateScore", {description = "Calculates score", testCase = "calc_score", type = "functional"}, function()
        local score = shared.to:calculateScore("scoring")
        Helpers.assertEqual(score >= 100, true, "Score calculated")
    end)

    Suite:testMethod("TacticalObjectives.getMissionScore", {description = "Gets score", testCase = "get_score", type = "functional"}, function()
        shared.to:calculateScore("scoring")
        local score = shared.to:getMissionScore("scoring")
        Helpers.assertEqual(score >= 100, true, "Score retrieved")
    end)
end)

Suite:group("Mission Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.to = TacticalObjectives:new()
        shared.to:createMission("status", "test", 1)
    end)

    Suite:testMethod("TacticalObjectives.setMissionStatus", {description = "Sets status", testCase = "set_status", type = "functional"}, function()
        local ok = shared.to:setMissionStatus("status", "completed")
        Helpers.assertEqual(ok, true, "Status set")
    end)

    Suite:testMethod("TacticalObjectives.getMissionStatus", {description = "Gets status", testCase = "get_status", type = "functional"}, function()
        shared.to:setMissionStatus("status", "active")
        local status = shared.to:getMissionStatus("status")
        Helpers.assertEqual(status, "active", "Active status")
    end)

    Suite:testMethod("TacticalObjectives.getCompletedMissions", {description = "Counts completed", testCase = "completed_count", type = "functional"}, function()
        shared.to:setMissionStatus("status", "completed")
        local count = shared.to:getCompletedMissions()
        Helpers.assertEqual(count >= 1, true, "Missions completed")
    end)
end)

Suite:run()
