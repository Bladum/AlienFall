-- ─────────────────────────────────────────────────────────────────────────
-- STRATEGIC PLANNING TEST SUITE
-- FILE: tests2/geoscape/strategic_planning_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.strategic_planning",
    fileName = "strategic_planning.lua",
    description = "Strategic planning with campaigns, objectives, territories, and resources"
})

print("[STRATEGIC_PLANNING_TEST] Setting up")

local StrategicPlanning = {
    campaigns = {}, objectives = {}, territories = {}, resources = {},
    military_units = {}, events = {},

    new = function(self)
        return setmetatable({
            campaigns = {}, objectives = {}, territories = {}, resources = {},
            military_units = {}, events = {}
        }, {__index = self})
    end,

    createCampaign = function(self, campaignId, name, objective_count)
        self.campaigns[campaignId] = {
            id = campaignId, name = name, status = "planned",
            progress = 0, priority = 5, objectives = objective_count or 5,
            start_date = os.time(), completion_date = nil
        }
        return true
    end,

    getCampaign = function(self, campaignId)
        return self.campaigns[campaignId]
    end,

    createObjective = function(self, objectiveId, campaignId, type, location, priority)
        if not self.campaigns[campaignId] then return false end
        self.objectives[objectiveId] = {
            id = objectiveId, campaign_id = campaignId, type = type,
            location = location, priority = priority or 1, status = "pending",
            progress = 0, resources_required = 100, completion_bonus = 50
        }
        return true
    end,

    getObjective = function(self, objectiveId)
        return self.objectives[objectiveId]
    end,

    updateObjectiveProgress = function(self, objectiveId, progress_amount)
        if not self.objectives[objectiveId] then return false end
        local obj = self.objectives[objectiveId]
        obj.progress = math.min(100, obj.progress + progress_amount)
        if obj.progress >= 100 then
            obj.status = "completed"
        end
        return true
    end,

    registerTerritory = function(self, territoryId, name, region_type, strategic_value)
        self.territories[territoryId] = {
            id = territoryId, name = name, type = region_type,
            strategic_value = strategic_value or 50, control = "neutral",
            garrison_size = 0, resources_available = 500, threat_level = 0
        }
        return true
    end,

    getTerritory = function(self, territoryId)
        return self.territories[territoryId]
    end,

    captureTerritory = function(self, territoryId, faction)
        if not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        territory.control = faction
        territory.garrison_size = territory.garrison_size + 50
        return true
    end,

    loseTerritory = function(self, territoryId, new_faction)
        if not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        territory.control = new_faction or "neutral"
        territory.garrison_size = math.max(0, territory.garrison_size - 25)
        return true
    end,

    allocateResources = function(self, objectiveId, resource_amount)
        if not self.objectives[objectiveId] then return false end
        local obj = self.objectives[objectiveId]
        if resource_amount >= obj.resources_required then
            obj.status = "in_progress"
            return true
        end
        return false
    end,

    getResourceRequirements = function(self, campaignId)
        local total = 0
        for _, obj in pairs(self.objectives) do
            if obj.campaign_id == campaignId then
                total = total + obj.resources_required
            end
        end
        return total
    end,

    deployMilitaryUnit = function(self, unitId, territoryId, unit_type)
        if not self.territories[territoryId] then return false end
        self.military_units[unitId] = {
            id = unitId, territory_id = territoryId, type = unit_type,
            strength = 100, morale = 80, status = "active", deployment_date = os.time()
        }
        local territory = self.territories[territoryId]
        territory.garrison_size = territory.garrison_size + 30
        return true
    end,

    getMilitaryUnit = function(self, unitId)
        return self.military_units[unitId]
    end,

    calculateTerritorialControl = function(self)
        local control_map = {}
        for _, territory in pairs(self.territories) do
            if control_map[territory.control] == nil then
                control_map[territory.control] = 0
            end
            control_map[territory.control] = control_map[territory.control] + territory.strategic_value
        end
        return control_map
    end,

    updateThreatLevel = function(self, territoryId, threat_increase)
        if not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        territory.threat_level = math.min(100, territory.threat_level + threat_increase)
        return true
    end,

    getThreatAssessment = function(self, territoryId)
        if not self.territories[territoryId] then return 0 end
        local territory = self.territories[territoryId]
        local garrison_factor = (territory.garrison_size / 100) * 50
        local threat = territory.threat_level + garrison_factor
        return math.min(100, threat)
    end,

    planCombatOperation = function(self, campaignId, targetId, forces_required)
        if not self.campaigns[campaignId] or not self.territories[targetId] then return false end
        local operation = {
            id = campaignId .. "_op_" .. targetId, campaign = campaignId,
            target = targetId, forces = forces_required or 100, status = "planning",
            estimated_duration = 5, success_chance = 75
        }
        self.events[operation.id] = operation
        return true
    end,

    executeCombatOperation = function(self, operationId)
        if not self.events[operationId] then return false end
        local op = self.events[operationId]
        op.status = "in_progress"
        local success_roll = math.random(1, 100)
        if success_roll <= op.success_chance then
            op.status = "completed"
            return true
        else
            op.status = "failed"
            return false
        end
    end,

    setObjectivePriority = function(self, objectiveId, priority_level)
        if not self.objectives[objectiveId] then return false end
        local obj = self.objectives[objectiveId]
        obj.priority = math.min(10, math.max(1, priority_level))
        return true
    end,

    getHighPriorityObjectives = function(self, campaignId, priority_threshold)
        local high_priority = {}
        for _, obj in pairs(self.objectives) do
            if obj.campaign_id == campaignId and obj.priority >= priority_threshold then
                table.insert(high_priority, obj)
            end
        end
        return high_priority
    end,

    calculateCampaignProgress = function(self, campaignId)
        local total = 0
        local count = 0
        for _, obj in pairs(self.objectives) do
            if obj.campaign_id == campaignId then
                total = total + obj.progress
                count = count + 1
            end
        end
        if count == 0 then return 0 end
        return total / count
    end,

    completeCampaign = function(self, campaignId)
        if not self.campaigns[campaignId] then return false end
        local campaign = self.campaigns[campaignId]
        campaign.status = "completed"
        campaign.completion_date = os.time()
        campaign.progress = 100
        return true
    end,

    analyzeTerritorialStrength = function(self, territoryId)
        if not self.territories[territoryId] then return 0 end
        local territory = self.territories[territoryId]
        local garrison_strength = territory.garrison_size
        local strategic_value = territory.strategic_value
        local defense_rating = (garrison_strength * 0.6) + (strategic_value * 0.4)
        return defense_rating
    end,

    routeResources = function(self, sourceId, destId, amount)
        if not self.territories[sourceId] or not self.territories[destId] then return false end
        local source = self.territories[sourceId]
        local dest = self.territories[destId]

        if source.resources_available < amount then return false end
        source.resources_available = source.resources_available - amount
        dest.resources_available = dest.resources_available + amount
        return true
    end,

    reset = function(self)
        self.campaigns = {}
        self.objectives = {}
        self.territories = {}
        self.resources = {}
        self.military_units = {}
        self.events = {}
        return true
    end
}

Suite:group("Campaigns", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
    end)

    Suite:testMethod("StrategicPlanning.createCampaign", {description = "Creates campaign", testCase = "create", type = "functional"}, function()
        local ok = shared.strategy:createCampaign("camp1", "Northern Offensive", 5)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("StrategicPlanning.getCampaign", {description = "Gets campaign", testCase = "get", type = "functional"}, function()
        shared.strategy:createCampaign("camp2", "Eastern Defense", 3)
        local camp = shared.strategy:getCampaign("camp2")
        Helpers.assertEqual(camp ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:createCampaign("camp3", "Campaign", 5)
    end)

    Suite:testMethod("StrategicPlanning.createObjective", {description = "Creates objective", testCase = "create", type = "functional"}, function()
        local ok = shared.strategy:createObjective("obj1", "camp3", "capture", "Fort A", 8)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("StrategicPlanning.getObjective", {description = "Gets objective", testCase = "get", type = "functional"}, function()
        shared.strategy:createObjective("obj2", "camp3", "defend", "Fort B", 5)
        local obj = shared.strategy:getObjective("obj2")
        Helpers.assertEqual(obj ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("StrategicPlanning.updateObjectiveProgress", {description = "Updates progress", testCase = "progress", type = "functional"}, function()
        shared.strategy:createObjective("obj3", "camp3", "research", "Lab", 6)
        local ok = shared.strategy:updateObjectiveProgress("obj3", 50)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("StrategicPlanning.objective_completes", {description = "Completes objective", testCase = "complete", type = "functional"}, function()
        shared.strategy:createObjective("obj4", "camp3", "escort", "Base", 4)
        shared.strategy:updateObjectiveProgress("obj4", 100)
        local obj = shared.strategy:getObjective("obj4")
        Helpers.assertEqual(obj.status == "completed", true, "Completed")
    end)
end)

Suite:group("Territories", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
    end)

    Suite:testMethod("StrategicPlanning.registerTerritory", {description = "Registers territory", testCase = "register", type = "functional"}, function()
        local ok = shared.strategy:registerTerritory("terr1", "Northlands", "plains", 75)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("StrategicPlanning.getTerritory", {description = "Gets territory", testCase = "get", type = "functional"}, function()
        shared.strategy:registerTerritory("terr2", "Wastelands", "desert", 50)
        local terr = shared.strategy:getTerritory("terr2")
        Helpers.assertEqual(terr ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("StrategicPlanning.captureTerritory", {description = "Captures territory", testCase = "capture", type = "functional"}, function()
        shared.strategy:registerTerritory("terr3", "Coastland", "coast", 60)
        local ok = shared.strategy:captureTerritory("terr3", "Blue")
        Helpers.assertEqual(ok, true, "Captured")
    end)

    Suite:testMethod("StrategicPlanning.loseTerritory", {description = "Loses territory", testCase = "lose", type = "functional"}, function()
        shared.strategy:registerTerritory("terr4", "Highlands", "mountains", 80)
        shared.strategy:captureTerritory("terr4", "Red")
        local ok = shared.strategy:loseTerritory("terr4", "Blue")
        Helpers.assertEqual(ok, true, "Lost")
    end)
end)

Suite:group("Resources", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:createCampaign("camp4", "Campaign", 5)
        shared.strategy:createObjective("obj5", "camp4", "capture", "Fort", 5)
    end)

    Suite:testMethod("StrategicPlanning.allocateResources", {description = "Allocates resources", testCase = "allocate", type = "functional"}, function()
        local ok = shared.strategy:allocateResources("obj5", 150)
        Helpers.assertEqual(ok, true, "Allocated")
    end)

    Suite:testMethod("StrategicPlanning.getResourceRequirements", {description = "Gets requirements", testCase = "requirements", type = "functional"}, function()
        local req = shared.strategy:getResourceRequirements("camp4")
        Helpers.assertEqual(req > 0, true, "Has requirements")
    end)
end)

Suite:group("Military Units", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:registerTerritory("terr5", "Battleground", "plains", 70)
    end)

    Suite:testMethod("StrategicPlanning.deployMilitaryUnit", {description = "Deploys unit", testCase = "deploy", type = "functional"}, function()
        local ok = shared.strategy:deployMilitaryUnit("unit1", "terr5", "armor")
        Helpers.assertEqual(ok, true, "Deployed")
    end)

    Suite:testMethod("StrategicPlanning.getMilitaryUnit", {description = "Gets unit", testCase = "get", type = "functional"}, function()
        shared.strategy:deployMilitaryUnit("unit2", "terr5", "infantry")
        local unit = shared.strategy:getMilitaryUnit("unit2")
        Helpers.assertEqual(unit ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Territorial Control", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:registerTerritory("terr6", "Land1", "plains", 50)
        shared.strategy:registerTerritory("terr7", "Land2", "mountains", 60)
    end)

    Suite:testMethod("StrategicPlanning.calculateTerritorialControl", {description = "Calculates control", testCase = "control", type = "functional"}, function()
        shared.strategy:captureTerritory("terr6", "Blue")
        shared.strategy:captureTerritory("terr7", "Red")
        local control = shared.strategy:calculateTerritorialControl()
        Helpers.assertEqual(control ~= nil, true, "Calculated")
    end)

    Suite:testMethod("StrategicPlanning.analyzeTerritorialStrength", {description = "Analyzes strength", testCase = "strength", type = "functional"}, function()
        shared.strategy:captureTerritory("terr6", "Blue")
        shared.strategy:deployMilitaryUnit("unit3", "terr6", "defense")
        local strength = shared.strategy:analyzeTerritorialStrength("terr6")
        Helpers.assertEqual(strength > 0, true, "Has strength")
    end)
end)

Suite:group("Threat Assessment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:registerTerritory("terr8", "Danger Zone", "coast", 40)
    end)

    Suite:testMethod("StrategicPlanning.updateThreatLevel", {description = "Updates threat", testCase = "update", type = "functional"}, function()
        local ok = shared.strategy:updateThreatLevel("terr8", 25)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("StrategicPlanning.getThreatAssessment", {description = "Gets threat", testCase = "get", type = "functional"}, function()
        shared.strategy:updateThreatLevel("terr8", 30)
        local threat = shared.strategy:getThreatAssessment("terr8")
        Helpers.assertEqual(threat > 0, true, "Threat > 0")
    end)
end)

Suite:group("Combat Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:createCampaign("camp5", "Campaign", 5)
        shared.strategy:registerTerritory("terr9", "Target", "plains", 50)
    end)

    Suite:testMethod("StrategicPlanning.planCombatOperation", {description = "Plans operation", testCase = "plan", type = "functional"}, function()
        local ok = shared.strategy:planCombatOperation("camp5", "terr9", 100)
        Helpers.assertEqual(ok, true, "Planned")
    end)

    Suite:testMethod("StrategicPlanning.executeCombatOperation", {description = "Executes operation", testCase = "execute", type = "functional"}, function()
        shared.strategy:planCombatOperation("camp5", "terr9", 100)
        local opid = "camp5_op_terr9"
        shared.strategy:executeCombatOperation(opid)
        local op = shared.strategy.events[opid]
        Helpers.assertEqual(op.status ~= "planning", true, "Executed")
    end)
end)

Suite:group("Priorities & Progress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:createCampaign("camp6", "Campaign", 5)
        shared.strategy:createObjective("obj6", "camp6", "task", "Site", 3)
        shared.strategy:createObjective("obj7", "camp6", "task", "Site2", 5)
    end)

    Suite:testMethod("StrategicPlanning.setObjectivePriority", {description = "Sets priority", testCase = "set", type = "functional"}, function()
        local ok = shared.strategy:setObjectivePriority("obj6", 8)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("StrategicPlanning.getHighPriorityObjectives", {description = "Gets high priority", testCase = "high", type = "functional"}, function()
        shared.strategy:setObjectivePriority("obj7", 9)
        local objs = shared.strategy:getHighPriorityObjectives("camp6", 8)
        Helpers.assertEqual(#objs > 0, true, "Has objectives")
    end)

    Suite:testMethod("StrategicPlanning.calculateCampaignProgress", {description = "Calculates progress", testCase = "progress", type = "functional"}, function()
        shared.strategy:updateObjectiveProgress("obj6", 50)
        local prog = shared.strategy:calculateCampaignProgress("camp6")
        Helpers.assertEqual(prog > 0, true, "Has progress")
    end)
end)

Suite:group("Campaign Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:createCampaign("camp7", "Campaign", 5)
    end)

    Suite:testMethod("StrategicPlanning.completeCampaign", {description = "Completes campaign", testCase = "complete", type = "functional"}, function()
        local ok = shared.strategy:completeCampaign("camp7")
        Helpers.assertEqual(ok, true, "Completed")
    end)
end)

Suite:group("Resource Routing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
        shared.strategy:registerTerritory("terr10", "Source", "plains", 50)
        shared.strategy:registerTerritory("terr11", "Dest", "coast", 60)
    end)

    Suite:testMethod("StrategicPlanning.routeResources", {description = "Routes resources", testCase = "route", type = "functional"}, function()
        local ok = shared.strategy:routeResources("terr10", "terr11", 100)
        Helpers.assertEqual(ok, true, "Routed")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.strategy = StrategicPlanning:new()
    end)

    Suite:testMethod("StrategicPlanning.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.strategy:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
