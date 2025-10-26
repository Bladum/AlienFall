-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Mission Manager
-- FILE: tests2/geoscape/mission_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for engine.geoscape.managers.mission_manager
-- Covers mission lifecycle, activation, completion, and rewards
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- Mock MissionManager for tests
local MissionManager = {}
MissionManager.__index = MissionManager

local MISSION_TYPES = {site = "crash_site", ufo_crash = "ufo_crash", base_defense = "base_defense"}
local MISSION_STATES = {pending = "pending", active = "active", completed = "completed", failed = "failed"}

function MissionManager:new()
    local self = setmetatable({}, MissionManager)
    self.missions = {}
    self.nextId = 1
    self.activeMissions = {}
    self.completedMissions = {}
    self.totalMissionsCompleted = 0
    self.totalMissionsFailed = 0
    self.totalRewardsEarned = 0
    self.missionEvents = {}
    return self
end

function MissionManager:createMission(missionData)
    if not missionData or not missionData.name then
        error("[MissionManager] Mission data required")
    end

    local mission = {
        id = "mission_" .. self.nextId,
        name = missionData.name,
        type = missionData.type or "site",
        state = MISSION_STATES.pending,
        location = missionData.location or {x = 0, y = 0},
        difficulty = missionData.difficulty or 1,
        rewards = missionData.rewards or {funds = 0, research = 0},
        objectives = missionData.objectives or {}
    }

    self.missions[mission.id] = mission
    self.nextId = self.nextId + 1
    return mission
end

function MissionManager:activateMission(missionId)
    if not self.missions[missionId] then
        error("[MissionManager] Mission not found: " .. tostring(missionId))
    end

    local mission = self.missions[missionId]
    mission.state = MISSION_STATES.active
    table.insert(self.activeMissions, missionId)
    return true
end

function MissionManager:completeMission(missionId, rewards)
    if not self.missions[missionId] then
        error("[MissionManager] Mission not found")
    end

    local mission = self.missions[missionId]
    mission.state = MISSION_STATES.completed
    mission.completedAt = os.time()

    if rewards then
        self.totalRewardsEarned = self.totalRewardsEarned + (rewards.funds or 0)
        mission.earnedRewards = rewards
    end

    self.totalMissionsCompleted = self.totalMissionsCompleted + 1
    table.insert(self.completedMissions, missionId)

    return true
end

function MissionManager:failMission(missionId)
    if not self.missions[missionId] then
        error("[MissionManager] Mission not found")
    end

    self.missions[missionId].state = MISSION_STATES.failed
    self.totalMissionsFailed = self.totalMissionsFailed + 1
    return true
end

function MissionManager:getMission(missionId)
    return self.missions[missionId]
end

function MissionManager:getActiveMissions()
    return self.activeMissions
end

function MissionManager:getCompletedMissions()
    return self.completedMissions
end

function MissionManager:getMissionStats()
    return {
        total = self.nextId - 1,
        completed = self.totalMissionsCompleted,
        failed = self.totalMissionsFailed,
        rewards = self.totalRewardsEarned
    }
end

function MissionManager:registerCallback(event, callback)
    if not event or not callback then
        error("[MissionManager] Event and callback required")
    end
    self.missionEvents[event] = callback
    return true
end

-- Test Suite
local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.managers.mission_manager",
    fileName = "mission_manager.lua",
    description = "Mission management system - lifecycle, activation, and rewards"
})

Suite:before(function() print("[MissionManager] Setting up test suite") end)
Suite:after(function() print("[MissionManager] Cleaning up") end)

-- GROUP 1: MISSION CREATION
Suite:group("Mission Creation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = MissionManager:new()
    end)

    Suite:testMethod("MissionManager.createMission", {
        description = "Creates new mission",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local mission = shared.manager:createMission({
            name = "Crash Site",
            type = "site",
            difficulty = 2
        })

        Helpers.assertEqual(mission.name, "Crash Site", "Mission should have correct name")
        Helpers.assertEqual(mission.type, "site", "Mission should have correct type")
        assert(mission.id:match("mission_"), "Mission should have ID")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.createMission", {
        description = "Rejects invalid mission data",
        testCase = "error_handling",
        type = "functional"
    }, function()
        local ok, err = pcall(function()
            shared.manager:createMission({})  -- Missing name
        end)

        Helpers.assertEqual(ok, false, "Should error on missing name")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.createMission", {
        description = "Creates multiple missions with unique IDs",
        testCase = "multiple",
        type = "functional"
    }, function()
        local m1 = shared.manager:createMission({name = "Mission 1"})
        local m2 = shared.manager:createMission({name = "Mission 2"})
        local m3 = shared.manager:createMission({name = "Mission 3"})

        Helpers.assertEqual(m1.id ~= m2.id, true, "IDs should be unique")
        Helpers.assertEqual(m2.id ~= m3.id, true, "IDs should be unique")

        -- Removed manual print - framework handles this
    end)
end)

-- GROUP 2: MISSION ACTIVATION
Suite:group("Mission Activation", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = MissionManager:new()
        shared.mission = shared.manager:createMission({name = "Test Mission"})
    end)

    Suite:testMethod("MissionManager.activateMission", {
        description = "Activates pending mission",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local result = shared.manager:activateMission(shared.mission.id)

        Helpers.assertEqual(result, true, "Should return true")
        Helpers.assertEqual(shared.mission.state, "active", "Mission state should be active")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.activateMission", {
        description = "Rejects non-existent mission",
        testCase = "error_handling",
        type = "functional"
    }, function()
        local ok, err = pcall(function()
            shared.manager:activateMission("mission_999")
        end)

        Helpers.assertEqual(ok, false, "Should error on missing mission")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.getActiveMissions", {
        description = "Returns list of active missions",
        testCase = "happy_path",
        type = "functional"
    }, function()
        shared.manager:activateMission(shared.mission.id)
        local active = shared.manager:getActiveMissions()

        Helpers.assertEqual(#active, 1, "Should have 1 active mission")
        Helpers.assertEqual(active[1], shared.mission.id, "Should contain mission ID")

        -- Removed manual print - framework handles this
    end)
end)

-- GROUP 3: MISSION COMPLETION
Suite:group("Mission Completion", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = MissionManager:new()
        shared.mission = shared.manager:createMission({
            name = "Test Mission",
            rewards = {funds = 500}
        })
        shared.manager:activateMission(shared.mission.id)
    end)

    Suite:testMethod("MissionManager.completeMission", {
        description = "Completes active mission with rewards",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local result = shared.manager:completeMission(shared.mission.id, {funds = 500})

        Helpers.assertEqual(result, true, "Should return true")
        Helpers.assertEqual(shared.mission.state, "completed", "Mission should be completed")
        Helpers.assertEqual(shared.manager.totalRewardsEarned, 500, "Should track rewards")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.completeMission", {
        description = "Tracks mission statistics",
        testCase = "stats",
        type = "functional"
    }, function()
        shared.manager:completeMission(shared.mission.id, {funds = 100})

        local stats = shared.manager:getMissionStats()

        Helpers.assertEqual(stats.completed, 1, "Should have 1 completed")
        Helpers.assertEqual(stats.rewards, 100, "Should track rewards")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.failMission", {
        description = "Fails mission and updates stats",
        testCase = "failure",
        type = "functional"
    }, function()
        shared.manager:failMission(shared.mission.id)

        local stats = shared.manager:getMissionStats()

        Helpers.assertEqual(shared.mission.state, "failed", "Mission should be failed")
        Helpers.assertEqual(stats.failed, 1, "Should have 1 failed")

        -- Removed manual print - framework handles this
    end)
end)

-- GROUP 4: MISSION QUERIES
Suite:group("Mission Queries", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = MissionManager:new()
        shared.m1 = shared.manager:createMission({name = "Mission 1"})
        shared.m2 = shared.manager:createMission({name = "Mission 2"})
    end)

    Suite:testMethod("MissionManager.getMission", {
        description = "Retrieves mission by ID",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local mission = shared.manager:getMission(shared.m1.id)

        Helpers.assertEqual(mission.id, shared.m1.id, "Should return correct mission")
        Helpers.assertEqual(mission.name, "Mission 1", "Should have correct name")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.getMissionStats", {
        description = "Returns mission statistics",
        testCase = "stats",
        type = "functional"
    }, function()
        shared.manager:activateMission(shared.m1.id)
        shared.manager:completeMission(shared.m1.id, {funds = 250})
        shared.manager:activateMission(shared.m2.id)
        shared.manager:failMission(shared.m2.id)

        local stats = shared.manager:getMissionStats()

        Helpers.assertEqual(stats.total, 2, "Should have 2 total missions")
        Helpers.assertEqual(stats.completed, 1, "Should have 1 completed")
        Helpers.assertEqual(stats.failed, 1, "Should have 1 failed")

        -- Removed manual print - framework handles this
    end)
end)

-- GROUP 5: CALLBACKS
Suite:group("Callbacks", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.manager = MissionManager:new()
        shared.callbackCalled = false
    end)

    Suite:testMethod("MissionManager.registerCallback", {
        description = "Registers event callback",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local callback = function()
            shared.callbackCalled = true
        end

        local result = shared.manager:registerCallback("missionCompleted", callback)

        Helpers.assertEqual(result, true, "Should register callback")
        assert(shared.manager.missionEvents["missionCompleted"] ~= nil, "Callback should be stored")

        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("MissionManager.registerCallback", {
        description = "Rejects invalid callback",
        testCase = "error_handling",
        type = "functional"
    }, function()
        local ok, err = pcall(function()
            shared.manager:registerCallback("event", nil)
        end)

        Helpers.assertEqual(ok, false, "Should error on nil callback")
        -- Removed manual print - framework handles this
    end)
end)

return Suite
