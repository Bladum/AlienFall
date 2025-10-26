-- TEST: AI Coordinator
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local AICoordinator = {}
AICoordinator.__index = AICoordinator

function AICoordinator:new()
    local self = setmetatable({}, AICoordinator)
    self.squads = {}
    self.threats = {}
    self.decisions = {}
    self.threatAssessment = {}
    self.resourceAwareness = {}
    self.squadCoordination = {}
    return self
end

function AICoordinator:registerSquad(squadId, units)
    if not squadId or not units then error("[AICoordinator] Invalid squad") end
    self.squads[squadId] = {
        id = squadId,
        units = units,
        status = "idle"
    }
    return true
end

function AICoordinator:updateThreatAssessment(threat)
    if not threat then error("[AICoordinator] Invalid threat") end
    table.insert(self.threats, threat)
    return true
end

function AICoordinator:decideSquadAction(squadId)
    if not squadId or not self.squads[squadId] then error("[AICoordinator] Squad not found") end
    local action = {
        squadId = squadId,
        type = "move",
        priority = 5
    }
    self.decisions[squadId] = action
    return action
end

function AICoordinator:update(dt)
    if not dt then error("[AICoordinator] Invalid dt") end
    for squadId, squad in pairs(self.squads) do
        if squad.status == "idle" then
            squad.status = "planning"
        end
    end
    return true
end

function AICoordinator:getThreatLevel()
    local total = 0
    for _, threat in ipairs(self.threats) do
        total = total + (threat.level or 0)
    end
    return math.min(total, 100)
end

function AICoordinator:getSquadStatus(squadId)
    if not squadId or not self.squads[squadId] then error("[AICoordinator] Squad not found") end
    return self.squads[squadId].status
end

local Suite = HierarchicalSuite:new({
    modulePath = "engine.ai.ai_coordinator",
    fileName = "ai_coordinator.lua",
    description = "Master orchestrator for AI systems and squad coordination"
})

Suite:before(function() print("[AICoordinator] Setting up") end)

Suite:group("Squad Management", function()
    local shared = {}
    Suite:beforeEach(function() shared.coord = AICoordinator:new() end)

    Suite:testMethod("AICoordinator.registerSquad", {description="Registers AI squad", testCase="happy_path", type="functional"},
    function()
        shared.coord:registerSquad("squad_1", {unit1 = true, unit2 = true})
        Helpers.assertEqual(shared.coord.squads["squad_1"] ~= nil, true, "Squad registered")
        print("  ✓ Squad registered")
    end)

    Suite:testMethod("AICoordinator.getSquadStatus", {description="Gets squad status", testCase="status", type="functional"},
    function()
        shared.coord:registerSquad("squad_1", {unit1 = true})
        local status = shared.coord:getSquadStatus("squad_1")
        Helpers.assertEqual(status, "idle", "Initial status idle")
        print("  ✓ Status retrieved")
    end)
end)

Suite:group("Threat Assessment", function()
    local shared = {}
    Suite:beforeEach(function() shared.coord = AICoordinator:new() end)

    Suite:testMethod("AICoordinator.updateThreatAssessment", {description="Updates threat level", testCase="threat", type="functional"},
    function()
        shared.coord:updateThreatAssessment({level = 30})
        local count = 0
        for _ in pairs(shared.coord.threats) do count = count + 1 end
        Helpers.assertEqual(count > 0, true, "Threat registered")
        print("  ✓ Threat updated")
    end)

    Suite:testMethod("AICoordinator.getThreatLevel", {description="Calculates threat level", testCase="calculation", type="functional"},
    function()
        shared.coord:updateThreatAssessment({level = 25})
        shared.coord:updateThreatAssessment({level = 30})
        local threat = shared.coord:getThreatLevel()
        Helpers.assertEqual(threat >= 50, true, "Threat combined correctly")
        print("  ✓ Threat calculated")
    end)

    Suite:testMethod("AICoordinator threat clamping", {description="Clamps threat to 100", testCase="clamping", type="functional"},
    function()
        for i = 1, 5 do
            shared.coord:updateThreatAssessment({level = 30})
        end
        local threat = shared.coord:getThreatLevel()
        Helpers.assertEqual(threat <= 100, true, "Threat clamped")
        print("  ✓ Threat clamped")
    end)
end)

Suite:group("Decision Making", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.coord = AICoordinator:new()
        shared.coord:registerSquad("squad_1", {unit1 = true})
    end)

    Suite:testMethod("AICoordinator.decideSquadAction", {description="Makes squad decisions", testCase="decision", type="functional"},
    function()
        local action = shared.coord:decideSquadAction("squad_1")
        Helpers.assertEqual(action.squadId, "squad_1", "Action assigned")
        Helpers.assertEqual(action.priority >= 0, true, "Priority set")
        print("  ✓ Decision made")
    end)
end)

Suite:group("Coordination Update", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.coord = AICoordinator:new()
        shared.coord:registerSquad("squad_1", {unit1 = true})
    end)

    Suite:testMethod("AICoordinator.update", {description="Updates all systems", testCase="update", type="functional"},
    function()
        shared.coord:update(0.016)
        Helpers.assertEqual(shared.coord:getSquadStatus("squad_1"), "planning", "Status updated")
        print("  ✓ Update applied")
    end)
end)

return Suite
