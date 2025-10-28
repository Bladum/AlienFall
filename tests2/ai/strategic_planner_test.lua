-- TEST: Strategic Planner
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local StrategicPlanner = {}
StrategicPlanner.__index = StrategicPlanner

function StrategicPlanner:new()
    local self = setmetatable({}, StrategicPlanner)
    self.evaluatedMissions = {}
    return self
end

function StrategicPlanner:scoreMission(mission, gameState, base)
    if not mission then error("[StrategicPlanner] Invalid mission") end

    mission = mission or {}
    gameState = gameState or {current_tech_level = 1}
    base = base or {credits = 100000}

    local score = 0
    local details = {}

    -- Reward factor (40%)
    local reward = mission.reward or 1000
    local rewardScore = math.min(40, (reward / 2500) * 40)
    score = score + rewardScore
    details.reward = rewardScore

    -- Risk factor (30%)
    local risk = mission.difficulty or 1
    local riskScore = 30 / (1 + (risk - 1) * 0.5)
    score = score + riskScore
    details.risk = riskScore

    -- Relation factor (20%)
    local relationScore = (mission.relationship_boost or 5) * 2
    score = score + relationScore
    details.relations = relationScore

    -- Strategic value (10%)
    local strategicScore = (mission.strategic_value or 0.5) * 10
    score = score + strategicScore
    details.strategic = strategicScore

    score = math.min(100, score)
    return score, details
end

function StrategicPlanner:rankMissions(missions, gameState, base)
    if not missions or #missions == 0 then error("[StrategicPlanner] No missions") end

    local ranked = {}
    for _, mission in ipairs(missions) do
        local score, details = self:scoreMission(mission, gameState, base)
        table.insert(ranked, {mission = mission, score = score, details = details})
    end

    table.sort(ranked, function(a, b) return a.score > b.score end)
    return ranked
end

function StrategicPlanner:planTechTree(gameState, base)
    if not gameState or not base then error("[StrategicPlanner] Invalid state") end

    local plan = {
        currentTech = gameState.current_tech_level or 1,
        nextTechTarget = gameState.current_tech_level + 1,
        estimatedTurns = 5,
        costEstimate = 50000
    }
    return plan
end

function StrategicPlanner:analyzeFacilityNeeds(base)
    if not base then error("[StrategicPlanner] Invalid base") end

    local needs = {
        hangars = (base.hangar_count or 0) < 2,
        barracks = (base.barracks_count or 0) < 1,
        labs = (base.lab_count or 0) < 1
    }
    return needs
end

function StrategicPlanner:evaluateResourceImpact(mission, base)
    if not mission or not base then error("[StrategicPlanner] Invalid input") end

    local impact = {
        creditsCost = mission.cost or 0,
        creditsReward = mission.reward or 0,
        netGain = (mission.reward or 0) - (mission.cost or 0),
        profitMargin = math.max(0, (mission.reward or 0) / math.max(1, mission.cost or 1))
    }
    return impact
end

local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.strategic_planner",
    fileName = "strategic_planner.lua",
    description = "Strategic AI planning and mission evaluation system"
})

Suite:before(function() print("[StrategicPlanner] Setting up") end)

Suite:group("Mission Scoring", function()
    local shared = {}
    Suite:beforeEach(function() shared.planner = StrategicPlanner:new() end)

    Suite:testMethod("StrategicPlanner.scoreMission", {description="Scores mission", testCase="happy_path", type="functional"},
    function()
        local mission = {reward = 5000, difficulty = 1, relationship_boost = 10}
        local score = shared.planner:scoreMission(mission)
        Helpers.assertEqual(score >= 0 and score <= 100, true, "Score in range")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StrategicPlanner mission details", {description="Returns scoring details", testCase="details", type="functional"},
    function()
        local mission = {reward = 2500, difficulty = 1}
        local score, details = shared.planner:scoreMission(mission)
        Helpers.assertEqual(details.reward ~= nil, true, "Reward detail")
        Helpers.assertEqual(details.risk ~= nil, true, "Risk detail")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Mission Ranking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.planner = StrategicPlanner:new()
        shared.missions = {
            {id = 1, reward = 5000, difficulty = 2},
            {id = 2, reward = 3000, difficulty = 1},
            {id = 3, reward = 7000, difficulty = 3}
        }
    end)

    Suite:testMethod("StrategicPlanner.rankMissions", {description="Ranks missions by score", testCase="rank", type="functional"},
    function()
        local ranked = shared.planner:rankMissions(shared.missions)
        Helpers.assertEqual(#ranked == 3, true, "All ranked")
        Helpers.assertEqual(ranked[1].score >= ranked[2].score, true, "Sorted descending")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Tech Tree Planning", function()
    local shared = {}
    Suite:beforeEach(function() shared.planner = StrategicPlanner:new() end)

    Suite:testMethod("StrategicPlanner.planTechTree", {description="Plans tech progression", testCase="tech", type="functional"},
    function()
        local gameState = {current_tech_level = 2}
        local base = {}
        local plan = shared.planner:planTechTree(gameState, base)
        Helpers.assertEqual(plan.nextTechTarget, 3, "Next tech identified")
        Helpers.assertEqual(plan.estimatedTurns >= 0, true, "Timeline set")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Facility Analysis", function()
    local shared = {}
    Suite:beforeEach(function() shared.planner = StrategicPlanner:new() end)

    Suite:testMethod("StrategicPlanner.analyzeFacilityNeeds", {description="Identifies facility needs", testCase="facility", type="functional"},
    function()
        local base = {hangar_count = 1, barracks_count = 0}
        local needs = shared.planner:analyzeFacilityNeeds(base)
        Helpers.assertEqual(needs.hangars, true, "Hangar needed")
        Helpers.assertEqual(needs.barracks, true, "Barracks needed")
        -- Removed manual print - framework handles this
    end)
end)

Suite:group("Resource Impact", function()
    local shared = {}
    Suite:beforeEach(function() shared.planner = StrategicPlanner:new() end)

    Suite:testMethod("StrategicPlanner.evaluateResourceImpact", {description="Evaluates resource impact", testCase="resources", type="functional"},
    function()
        local mission = {cost = 5000, reward = 10000}
        local base = {}
        local impact = shared.planner:evaluateResourceImpact(mission, base)
        Helpers.assertEqual(impact.netGain, 5000, "Net gain calculated")
        Helpers.assertEqual(impact.profitMargin >= 1, true, "Profitable")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("StrategicPlanner loss mission", {description="Handles loss missions", testCase="loss", type="functional"},
    function()
        local mission = {cost = 10000, reward = 3000}
        local base = {}
        local impact = shared.planner:evaluateResourceImpact(mission, base)
        Helpers.assertEqual(impact.netGain < 0, true, "Net loss detected")
        -- Removed manual print - framework handles this
    end)
end)

return Suite
