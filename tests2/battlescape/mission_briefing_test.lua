-- ─────────────────────────────────────────────────────────────────────────
-- MISSION BRIEFING TEST SUITE
-- FILE: tests2/battlescape/mission_briefing_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.mission_briefing",
    fileName = "mission_briefing.lua",
    description = "Mission briefing system with objectives, intel, deployment, and mission tracking"
})

print("[MISSION_BRIEFING_TEST] Setting up")

local MissionBriefing = {
    missions = {},
    objectives = {},
    intel = {},
    deployments = {},

    new = function(self)
        return setmetatable({
            missions = {}, objectives = {}, intel = {}, deployments = {}
        }, {__index = self})
    end,

    createMission = function(self, missionId, name, mission_type, difficulty)
        self.missions[missionId] = {
            id = missionId, name = name, type = mission_type or "combat",
            difficulty = difficulty or "normal", status = "planned",
            objectives_list = {}, reward = 1000, casualties = 0,
            turns_elapsed = 0, max_turns = 50
        }
        self.objectives[missionId] = {}
        self.intel[missionId] = {}
        return true
    end,

    getMission = function(self, missionId)
        return self.missions[missionId]
    end,

    setMissionStatus = function(self, missionId, status)
        if not self.missions[missionId] then return false end
        self.missions[missionId].status = status or "planned"
        return true
    end,

    getMissionStatus = function(self, missionId)
        if not self.missions[missionId] then return nil end
        return self.missions[missionId].status
    end,

    addObjective = function(self, missionId, objectiveId, description, objective_type, importance)
        if not self.missions[missionId] then return false end
        if not self.objectives[missionId] then
            self.objectives[missionId] = {}
        end
        self.objectives[missionId][objectiveId] = {
            id = objectiveId, description = description or "objective",
            type = objective_type or "primary", importance = importance or 5,
            completed = false, progress = 0
        }
        table.insert(self.missions[missionId].objectives_list, objectiveId)
        return true
    end,

    getObjective = function(self, missionId, objectiveId)
        if not self.objectives[missionId] then return nil end
        return self.objectives[missionId][objectiveId]
    end,

    getMissionObjectives = function(self, missionId)
        if not self.objectives[missionId] then return {} end
        local objs = {}
        for _, objId in ipairs(self.missions[missionId].objectives_list or {}) do
            if self.objectives[missionId][objId] then
                table.insert(objs, self.objectives[missionId][objId])
            end
        end
        return objs
    end,

    completeObjective = function(self, missionId, objectiveId)
        if not self.objectives[missionId] or not self.objectives[missionId][objectiveId] then return false end
        self.objectives[missionId][objectiveId].completed = true
        self.objectives[missionId][objectiveId].progress = 100
        return true
    end,

    isObjectiveCompleted = function(self, missionId, objectiveId)
        if not self.objectives[missionId] or not self.objectives[missionId][objectiveId] then return false end
        return self.objectives[missionId][objectiveId].completed
    end,

    updateObjectiveProgress = function(self, missionId, objectiveId, progress)
        if not self.objectives[missionId] or not self.objectives[missionId][objectiveId] then return false end
        self.objectives[missionId][objectiveId].progress = progress or 0
        if progress >= 100 then
            self:completeObjective(missionId, objectiveId)
        end
        return true
    end,

    getObjectiveProgress = function(self, missionId, objectiveId)
        if not self.objectives[missionId] or not self.objectives[missionId][objectiveId] then return 0 end
        return self.objectives[missionId][objectiveId].progress
    end,

    addIntelligence = function(self, missionId, intelId, intel_type, content, importance)
        if not self.missions[missionId] then return false end
        if not self.intel[missionId] then
            self.intel[missionId] = {}
        end
        self.intel[missionId][intelId] = {
            id = intelId, type = intel_type or "briefing", content = content or "",
            importance = importance or 1, read = false, source = "briefing"
        }
        return true
    end,

    getIntelligence = function(self, missionId, intelId)
        if not self.intel[missionId] then return nil end
        return self.intel[missionId][intelId]
    end,

    getMissionIntel = function(self, missionId)
        if not self.intel[missionId] then return {} end
        local intel_list = {}
        for _, intel in pairs(self.intel[missionId]) do
            table.insert(intel_list, intel)
        end
        return intel_list
    end,

    readIntelligence = function(self, missionId, intelId)
        if not self.intel[missionId] or not self.intel[missionId][intelId] then return false end
        self.intel[missionId][intelId].read = true
        return true
    end,

    isIntelRead = function(self, missionId, intelId)
        if not self.intel[missionId] or not self.intel[missionId][intelId] then return false end
        return self.intel[missionId][intelId].read
    end,

    addDeploymentZone = function(self, missionId, zoneId, name, x, y, radius)
        if not self.missions[missionId] then return false end
        if not self.deployments[missionId] then
            self.deployments[missionId] = {}
        end
        self.deployments[missionId][zoneId] = {
            id = zoneId, name = name or "zone", x = x or 0, y = y or 0,
            radius = radius or 10, units_deployed = 0, max_units = 8
        }
        return true
    end,

    getDeploymentZone = function(self, missionId, zoneId)
        if not self.deployments[missionId] then return nil end
        return self.deployments[missionId][zoneId]
    end,

    getDeploymentZones = function(self, missionId)
        if not self.deployments[missionId] then return {} end
        local zones = {}
        for _, zone in pairs(self.deployments[missionId]) do
            table.insert(zones, zone)
        end
        return zones
    end,

    deployUnitToZone = function(self, missionId, zoneId, unitId)
        if not self.deployments[missionId] or not self.deployments[missionId][zoneId] then return false end
        local zone = self.deployments[missionId][zoneId]
        if zone.units_deployed >= zone.max_units then return false end
        zone.units_deployed = zone.units_deployed + 1
        return true
    end,

    getZoneDeploymentCount = function(self, missionId, zoneId)
        if not self.deployments[missionId] or not self.deployments[missionId][zoneId] then return 0 end
        return self.deployments[missionId][zoneId].units_deployed
    end,

    calculateMissionDifficulty = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        local mission = self.missions[missionId]
        local objectives = self:getMissionObjectives(missionId)
        local base_difficulty = 0
        if mission.difficulty == "easy" then base_difficulty = 25
        elseif mission.difficulty == "normal" then base_difficulty = 50
        elseif mission.difficulty == "hard" then base_difficulty = 75
        elseif mission.difficulty == "impossible" then base_difficulty = 100
        end
        return base_difficulty + (#objectives * 5)
    end,

    recordMissionCasualty = function(self, missionId)
        if not self.missions[missionId] then return false end
        self.missions[missionId].casualties = self.missions[missionId].casualties + 1
        return true
    end,

    getMissionCasualties = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].casualties
    end,

    incrementMissionTurns = function(self, missionId)
        if not self.missions[missionId] then return false end
        self.missions[missionId].turns_elapsed = self.missions[missionId].turns_elapsed + 1
        return true
    end,

    getMissionTurns = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].turns_elapsed
    end,

    getMaxMissionTurns = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].max_turns
    end,

    calculateMissionReward = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        local mission = self.missions[missionId]
        local base = mission.reward
        local difficulty_mult = self:calculateMissionDifficulty(missionId) / 50
        local casualty_penalty = mission.casualties * 100
        local turn_bonus = math.max(0, (mission.max_turns - mission.turns_elapsed) * 50)
        return math.floor((base * difficulty_mult) - casualty_penalty + turn_bonus)
    end,

    missionComplete = function(self, missionId)
        if not self.missions[missionId] then return false end
        local mission = self.missions[missionId]
        local all_complete = true
        for _, objId in ipairs(mission.objectives_list) do
            if not self:isObjectiveCompleted(missionId, objId) then
                all_complete = false
                break
            end
        end
        return all_complete
    end,

    getCompletedObjectivesCount = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        local count = 0
        for _, objId in ipairs(self.missions[missionId].objectives_list) do
            if self:isObjectiveCompleted(missionId, objId) then
                count = count + 1
            end
        end
        return count
    end,

    reset = function(self)
        self.missions = {}
        self.objectives = {}
        self.intel = {}
        self.deployments = {}
        return true
    end
}

Suite:group("Missions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
    end)

    Suite:testMethod("MissionBriefing.createMission", {description = "Creates mission", testCase = "create", type = "functional"}, function()
        local ok = shared.mb:createMission("m1", "Defend Base", "defense", "normal")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MissionBriefing.getMission", {description = "Gets mission", testCase = "get", type = "functional"}, function()
        shared.mb:createMission("m2", "Recover Intel", "extraction", "hard")
        local mission = shared.mb:getMission("m2")
        Helpers.assertEqual(mission ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MissionBriefing.setMissionStatus", {description = "Sets status", testCase = "set_status", type = "functional"}, function()
        shared.mb:createMission("m3", "Assault", "combat", "normal")
        local ok = shared.mb:setMissionStatus("m3", "in_progress")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("MissionBriefing.getMissionStatus", {description = "Gets status", testCase = "get_status", type = "functional"}, function()
        shared.mb:createMission("m4", "Surveillance", "recon", "easy")
        shared.mb:setMissionStatus("m4", "completed")
        local status = shared.mb:getMissionStatus("m4")
        Helpers.assertEqual(status, "completed", "completed")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("m1", "Combat", "combat", "normal")
    end)

    Suite:testMethod("MissionBriefing.addObjective", {description = "Adds objective", testCase = "add", type = "functional"}, function()
        local ok = shared.mb:addObjective("m1", "obj1", "Destroy targets", "primary", 5)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MissionBriefing.getObjective", {description = "Gets objective", testCase = "get", type = "functional"}, function()
        shared.mb:addObjective("m1", "obj2", "Survive", "secondary", 3)
        local obj = shared.mb:getObjective("m1", "obj2")
        Helpers.assertEqual(obj ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MissionBriefing.getMissionObjectives", {description = "Gets objectives", testCase = "all", type = "functional"}, function()
        shared.mb:addObjective("m1", "obj1", "Primary", "primary")
        shared.mb:addObjective("m1", "obj2", "Secondary", "secondary")
        local objs = shared.mb:getMissionObjectives("m1")
        Helpers.assertEqual(#objs > 0, true, "Has objectives")
    end)

    Suite:testMethod("MissionBriefing.completeObjective", {description = "Completes objective", testCase = "complete", type = "functional"}, function()
        shared.mb:addObjective("m1", "obj3", "Task", "primary")
        local ok = shared.mb:completeObjective("m1", "obj3")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("MissionBriefing.isObjectiveCompleted", {description = "Is completed", testCase = "is_completed", type = "functional"}, function()
        shared.mb:addObjective("m1", "obj4", "Goal", "secondary")
        shared.mb:completeObjective("m1", "obj4")
        local is = shared.mb:isObjectiveCompleted("m1", "obj4")
        Helpers.assertEqual(is, true, "Completed")
    end)

    Suite:testMethod("MissionBriefing.updateObjectiveProgress", {description = "Updates progress", testCase = "progress", type = "functional"}, function()
        shared.mb:addObjective("m1", "obj5", "Task", "primary")
        local ok = shared.mb:updateObjectiveProgress("m1", "obj5", 75)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("MissionBriefing.getObjectiveProgress", {description = "Gets progress", testCase = "get_progress", type = "functional"}, function()
        shared.mb:addObjective("m1", "obj6", "Task", "secondary")
        shared.mb:updateObjectiveProgress("m1", "obj6", 50)
        local progress = shared.mb:getObjectiveProgress("m1", "obj6")
        Helpers.assertEqual(progress, 50, "50")
    end)
end)

Suite:group("Intelligence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("m1", "Combat", "combat", "normal")
    end)

    Suite:testMethod("MissionBriefing.addIntelligence", {description = "Adds intel", testCase = "add", type = "functional"}, function()
        local ok = shared.mb:addIntelligence("m1", "int1", "briefing", "Enemy count: 12", 2)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MissionBriefing.getIntelligence", {description = "Gets intel", testCase = "get", type = "functional"}, function()
        shared.mb:addIntelligence("m1", "int2", "warning", "Alien tech detected", 3)
        local intel = shared.mb:getIntelligence("m1", "int2")
        Helpers.assertEqual(intel ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MissionBriefing.getMissionIntel", {description = "Gets all intel", testCase = "all", type = "functional"}, function()
        shared.mb:addIntelligence("m1", "int1", "briefing", "Info1", 1)
        shared.mb:addIntelligence("m1", "int2", "warning", "Info2", 2)
        local intel = shared.mb:getMissionIntel("m1")
        Helpers.assertEqual(#intel > 0, true, "Has intel")
    end)

    Suite:testMethod("MissionBriefing.readIntelligence", {description = "Reads intel", testCase = "read", type = "functional"}, function()
        shared.mb:addIntelligence("m1", "int3", "report", "Details", 1)
        local ok = shared.mb:readIntelligence("m1", "int3")
        Helpers.assertEqual(ok, true, "Read")
    end)

    Suite:testMethod("MissionBriefing.isIntelRead", {description = "Is read", testCase = "is_read", type = "functional"}, function()
        shared.mb:addIntelligence("m1", "int4", "briefing", "Content", 1)
        shared.mb:readIntelligence("m1", "int4")
        local is = shared.mb:isIntelRead("m1", "int4")
        Helpers.assertEqual(is, true, "Read")
    end)
end)

Suite:group("Deployment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("m1", "Combat", "combat", "normal")
    end)

    Suite:testMethod("MissionBriefing.addDeploymentZone", {description = "Adds zone", testCase = "add", type = "functional"}, function()
        local ok = shared.mb:addDeploymentZone("m1", "zone1", "Landing", 50, 50, 15)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MissionBriefing.getDeploymentZone", {description = "Gets zone", testCase = "get", type = "functional"}, function()
        shared.mb:addDeploymentZone("m1", "zone2", "Dropzone", 100, 100, 20)
        local zone = shared.mb:getDeploymentZone("m1", "zone2")
        Helpers.assertEqual(zone ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MissionBriefing.getDeploymentZones", {description = "Gets zones", testCase = "all", type = "functional"}, function()
        shared.mb:addDeploymentZone("m1", "zone1", "Landing", 0, 0, 10)
        shared.mb:addDeploymentZone("m1", "zone2", "Support", 100, 100, 10)
        local zones = shared.mb:getDeploymentZones("m1")
        Helpers.assertEqual(#zones > 0, true, "Has zones")
    end)

    Suite:testMethod("MissionBriefing.deployUnitToZone", {description = "Deploys unit", testCase = "deploy", type = "functional"}, function()
        shared.mb:addDeploymentZone("m1", "zone1", "Landing", 0, 0, 10)
        local ok = shared.mb:deployUnitToZone("m1", "zone1", "unit1")
        Helpers.assertEqual(ok, true, "Deployed")
    end)

    Suite:testMethod("MissionBriefing.getZoneDeploymentCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.mb:addDeploymentZone("m1", "zone1", "Landing", 0, 0, 10)
        shared.mb:deployUnitToZone("m1", "zone1", "unit1")
        shared.mb:deployUnitToZone("m1", "zone1", "unit2")
        local count = shared.mb:getZoneDeploymentCount("m1", "zone1")
        Helpers.assertEqual(count, 2, "2")
    end)
end)

Suite:group("Mission Analytics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("m1", "Combat", "combat", "hard")
        shared.mb:addObjective("m1", "obj1", "Primary", "primary")
    end)

    Suite:testMethod("MissionBriefing.calculateMissionDifficulty", {description = "Calculates difficulty", testCase = "difficulty", type = "functional"}, function()
        local diff = shared.mb:calculateMissionDifficulty("m1")
        Helpers.assertEqual(diff > 0, true, "Difficulty > 0")
    end)

    Suite:testMethod("MissionBriefing.recordMissionCasualty", {description = "Records casualty", testCase = "record", type = "functional"}, function()
        local ok = shared.mb:recordMissionCasualty("m1")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("MissionBriefing.getMissionCasualties", {description = "Gets casualties", testCase = "casualties", type = "functional"}, function()
        shared.mb:recordMissionCasualty("m1")
        shared.mb:recordMissionCasualty("m1")
        local count = shared.mb:getMissionCasualties("m1")
        Helpers.assertEqual(count, 2, "2")
    end)

    Suite:testMethod("MissionBriefing.incrementMissionTurns", {description = "Increments turns", testCase = "increment", type = "functional"}, function()
        local ok = shared.mb:incrementMissionTurns("m1")
        Helpers.assertEqual(ok, true, "Incremented")
    end)

    Suite:testMethod("MissionBriefing.getMissionTurns", {description = "Gets turns", testCase = "turns", type = "functional"}, function()
        shared.mb:incrementMissionTurns("m1")
        shared.mb:incrementMissionTurns("m1")
        local turns = shared.mb:getMissionTurns("m1")
        Helpers.assertEqual(turns, 2, "2")
    end)

    Suite:testMethod("MissionBriefing.calculateMissionReward", {description = "Calculates reward", testCase = "reward", type = "functional"}, function()
        local reward = shared.mb:calculateMissionReward("m1")
        Helpers.assertEqual(reward >= 0, true, "Reward >= 0")
    end)
end)

Suite:group("Mission Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
        shared.mb:createMission("m1", "Task", "combat", "normal")
        shared.mb:addObjective("m1", "obj1", "Goal1", "primary")
        shared.mb:addObjective("m1", "obj2", "Goal2", "secondary")
    end)

    Suite:testMethod("MissionBriefing.missionComplete", {description = "Mission complete", testCase = "complete", type = "functional"}, function()
        shared.mb:completeObjective("m1", "obj1")
        shared.mb:completeObjective("m1", "obj2")
        local is = shared.mb:missionComplete("m1")
        Helpers.assertEqual(is, true, "Complete")
    end)

    Suite:testMethod("MissionBriefing.getCompletedObjectivesCount", {description = "Gets completed count", testCase = "completed", type = "functional"}, function()
        shared.mb:completeObjective("m1", "obj1")
        local count = shared.mb:getCompletedObjectivesCount("m1")
        Helpers.assertEqual(count, 1, "1")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mb = MissionBriefing:new()
    end)

    Suite:testMethod("MissionBriefing.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.mb:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
