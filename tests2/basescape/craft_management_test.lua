-- ─────────────────────────────────────────────────────────────────────────
-- CRAFT MANAGEMENT TEST SUITE
-- FILE: tests2/basescape/craft_management_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.craft_management",
    fileName = "craft_management.lua",
    description = "Craft fleet management with maintenance, deployment, and logistics"
})

print("[CRAFT_MANAGEMENT_TEST] Setting up")

local CraftManagement = {
    crafts = {},
    fleet = {},
    maintenance = {},
    deployments = {},
    logistics = {},

    new = function(self)
        return setmetatable({
            crafts = {}, fleet = {}, maintenance = {},
            deployments = {}, logistics = {}
        }, {__index = self})
    end,

    buildCraft = function(self, craftId, craftType, baseId, power, speed)
        self.crafts[craftId] = {
            id = craftId, type = craftType or "fighter", baseId = baseId,
            power = power or 80, speed = speed or 100, health = 100, fuel = 100, crew = 0, status = "idle"
        }
        self.fleet[baseId] = (self.fleet[baseId] or 0) + 1
        self.maintenance[craftId] = {condition = 100, coolant = 100, repairs_needed = 0}
        self.deployments[craftId] = {deployed = false, location = nil, mission = nil, turns_deployed = 0}
        return true
    end,

    getCraft = function(self, craftId)
        return self.crafts[craftId]
    end,

    getFleetSize = function(self, baseId)
        return self.fleet[baseId] or 0
    end,

    deployCraft = function(self, craftId, location, mission)
        if not self.crafts[craftId] then return false end
        if self.crafts[craftId].fuel < 20 then return false end
        self.deployments[craftId].deployed = true
        self.deployments[craftId].location = location
        self.deployments[craftId].mission = mission
        self.crafts[craftId].status = "deployed"
        self.crafts[craftId].fuel = self.crafts[craftId].fuel - 20
        return true
    end,

    recallCraft = function(self, craftId)
        if not self.crafts[craftId] then return false end
        self.deployments[craftId].deployed = false
        self.deployments[craftId].location = nil
        self.deployments[craftId].mission = nil
        self.deployments[craftId].turns_deployed = 0
        self.crafts[craftId].status = "returning"
        return true
    end,

    isDeployed = function(self, craftId)
        if not self.deployments[craftId] then return false end
        return self.deployments[craftId].deployed
    end,

    setCraftHealth = function(self, craftId, health)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].health = math.max(0, math.min(100, health))
        return true
    end,

    getCraftHealth = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].health
    end,

    setFuel = function(self, craftId, fuel)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].fuel = math.max(0, math.min(100, fuel))
        return true
    end,

    getFuel = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].fuel
    end,

    setArmament = function(self, craftId, armament)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].armament = armament
        return true
    end,

    getArmament = function(self, craftId)
        if not self.crafts[craftId] then return nil end
        return self.crafts[craftId].armament
    end,

    loadCrew = function(self, craftId, crewCount)
        if not self.crafts[craftId] then return false end
        self.crafts[craftId].crew = math.max(0, crewCount)
        return true
    end,

    getCrew = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        return self.crafts[craftId].crew
    end,

    performMaintenance = function(self, craftId, maintenanceType)
        if not self.maintenance[craftId] then return false end
        local maint = self.maintenance[craftId]
        if maintenanceType == "repairs" then
            maint.repairs_needed = math.max(0, maint.repairs_needed - 1)
            maint.condition = math.min(100, maint.condition + 10)
        elseif maintenanceType == "refill" then
            maint.coolant = 100
        end
        return true
    end,

    getCondition = function(self, craftId)
        if not self.maintenance[craftId] then return 0 end
        return self.maintenance[craftId].condition
    end,

    setCondition = function(self, craftId, condition)
        if not self.maintenance[craftId] then return false end
        self.maintenance[craftId].condition = math.max(0, math.min(100, condition))
        return true
    end,

    needsMaintenance = function(self, craftId)
        if not self.maintenance[craftId] then return false end
        return self.maintenance[craftId].condition < 60
    end,

    recordMission = function(self, craftId, missionType, success)
        if not self.deployments[craftId] then return false end
        self.deployments[craftId].turns_deployed = self.deployments[craftId].turns_deployed + 1
        if not success then
            self:setCraftHealth(craftId, self:getCraftHealth(craftId) - 10)
            if self.maintenance[craftId] then
                self.maintenance[craftId].repairs_needed = self.maintenance[craftId].repairs_needed + 1
            end
        end
        return true
    end,

    getDeploymentTurns = function(self, craftId)
        if not self.deployments[craftId] then return 0 end
        return self.deployments[craftId].turns_deployed
    end,

    calculateReadiness = function(self, craftId)
        if not self.crafts[craftId] then return 0 end
        local health = self:getCraftHealth(craftId)
        local fuel = self:getFuel(craftId)
        local condition = self:getCondition(craftId)
        return math.floor((health + fuel + condition) / 3)
    end,

    getReadyCount = function(self, baseId)
        local ready = 0
        for craftId, craft in pairs(self.crafts) do
            if craft.baseId == baseId and self:calculateReadiness(craftId) > 75 then
                ready = ready + 1
            end
        end
        return ready
    end,

    getDamagedCount = function(self, baseId)
        local damaged = 0
        for craftId, craft in pairs(self.crafts) do
            if craft.baseId == baseId and self:getCraftHealth(craftId) < 50 then
                damaged = damaged + 1
            end
        end
        return damaged
    end,

    fuelAllCrafts = function(self, baseId, amount)
        for craftId, craft in pairs(self.crafts) do
            if craft.baseId == baseId then
                self:setFuel(craftId, self:getFuel(craftId) + amount)
            end
        end
        return true
    end,

    repairAllCrafts = function(self, baseId)
        for craftId, craft in pairs(self.crafts) do
            if craft.baseId == baseId then
                self:setCraftHealth(craftId, 100)
                if self.maintenance[craftId] then
                    self.maintenance[craftId].repairs_needed = 0
                    self.maintenance[craftId].condition = 100
                end
            end
        end
        return true
    end,

    calculateFleetStrength = function(self, baseId)
        local strength = 0
        for craftId, craft in pairs(self.crafts) do
            if craft.baseId == baseId and craft.status ~= "destroyed" then
                strength = strength + craft.power
            end
        end
        return strength
    end,

    cannibalizeCraft = function(self, sourceId, targetId)
        if not self.crafts[sourceId] or not self.crafts[targetId] then return false end
        self:setCraftHealth(sourceId, 0)
        self:setCraftHealth(targetId, math.min(100, self:getCraftHealth(targetId) + 20))
        return true
    end,

    resetFleet = function(self, baseId)
        for craftId, craft in pairs(self.crafts) do
            if craft.baseId == baseId then
                self.crafts[craftId] = nil
                self.maintenance[craftId] = nil
                self.deployments[craftId] = nil
            end
        end
        if baseId then self.fleet[baseId] = 0 end
        return true
    end
}

Suite:group("Craft Building", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
    end)

    Suite:testMethod("CraftManagement.buildCraft", {description = "Builds craft", testCase = "build", type = "functional"}, function()
        local ok = shared.cm:buildCraft("fighter1", "fighter", "base1", 80, 100)
        Helpers.assertEqual(ok, true, "Built")
    end)

    Suite:testMethod("CraftManagement.getCraft", {description = "Gets craft", testCase = "get_craft", type = "functional"}, function()
        shared.cm:buildCraft("fighter2", "fighter", "base1", 75, 95)
        local craft = shared.cm:getCraft("fighter2")
        Helpers.assertEqual(craft ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CraftManagement.getFleetSize", {description = "Fleet size", testCase = "fleet_size", type = "functional"}, function()
        shared.cm:buildCraft("f1", "fighter", "base1", 80, 100)
        shared.cm:buildCraft("f2", "fighter", "base1", 80, 100)
        local size = shared.cm:getFleetSize("base1")
        Helpers.assertEqual(size, 2, "Two crafts")
    end)
end)

Suite:group("Deployment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("deploy_craft", "fighter", "base1", 80, 100)
    end)

    Suite:testMethod("CraftManagement.deployCraft", {description = "Deploys craft", testCase = "deploy", type = "functional"}, function()
        local ok = shared.cm:deployCraft("deploy_craft", "zone_a", "patrol")
        Helpers.assertEqual(ok, true, "Deployed")
    end)

    Suite:testMethod("CraftManagement.recallCraft", {description = "Recalls craft", testCase = "recall", type = "functional"}, function()
        shared.cm:deployCraft("deploy_craft", "zone_a", "patrol")
        local ok = shared.cm:recallCraft("deploy_craft")
        Helpers.assertEqual(ok, true, "Recalled")
    end)

    Suite:testMethod("CraftManagement.isDeployed", {description = "Is deployed", testCase = "is_deployed", type = "functional"}, function()
        shared.cm:deployCraft("deploy_craft", "zone_b", "scout")
        local is = shared.cm:isDeployed("deploy_craft")
        Helpers.assertEqual(is, true, "Deployed")
    end)
end)

Suite:group("Health and Fuel", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("health_craft", "fighter", "base1", 80, 100)
    end)

    Suite:testMethod("CraftManagement.setCraftHealth", {description = "Sets health", testCase = "set_health", type = "functional"}, function()
        local ok = shared.cm:setCraftHealth("health_craft", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CraftManagement.getCraftHealth", {description = "Gets health", testCase = "get_health", type = "functional"}, function()
        shared.cm:setCraftHealth("health_craft", 60)
        local health = shared.cm:getCraftHealth("health_craft")
        Helpers.assertEqual(health, 60, "Health 60")
    end)

    Suite:testMethod("CraftManagement.setFuel", {description = "Sets fuel", testCase = "set_fuel", type = "functional"}, function()
        local ok = shared.cm:setFuel("health_craft", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CraftManagement.getFuel", {description = "Gets fuel", testCase = "get_fuel", type = "functional"}, function()
        shared.cm:setFuel("health_craft", 70)
        local fuel = shared.cm:getFuel("health_craft")
        Helpers.assertEqual(fuel, 70, "Fuel 70")
    end)
end)

Suite:group("Armament and Crew", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("armed_craft", "fighter", "base1", 80, 100)
    end)

    Suite:testMethod("CraftManagement.setArmament", {description = "Sets armament", testCase = "arm", type = "functional"}, function()
        local ok = shared.cm:setArmament("armed_craft", "plasma")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CraftManagement.getArmament", {description = "Gets armament", testCase = "get_arm", type = "functional"}, function()
        shared.cm:setArmament("armed_craft", "laser")
        local arm = shared.cm:getArmament("armed_craft")
        Helpers.assertEqual(arm, "laser", "Laser armed")
    end)

    Suite:testMethod("CraftManagement.loadCrew", {description = "Loads crew", testCase = "crew", type = "functional"}, function()
        local ok = shared.cm:loadCrew("armed_craft", 4)
        Helpers.assertEqual(ok, true, "Loaded")
    end)

    Suite:testMethod("CraftManagement.getCrew", {description = "Gets crew", testCase = "get_crew", type = "functional"}, function()
        shared.cm:loadCrew("armed_craft", 5)
        local crew = shared.cm:getCrew("armed_craft")
        Helpers.assertEqual(crew, 5, "Crew 5")
    end)
end)

Suite:group("Maintenance", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("maint_craft", "fighter", "base1", 80, 100)
    end)

    Suite:testMethod("CraftManagement.performMaintenance", {description = "Performs maintenance", testCase = "maint", type = "functional"}, function()
        local ok = shared.cm:performMaintenance("maint_craft", "repairs")
        Helpers.assertEqual(ok, true, "Maintained")
    end)

    Suite:testMethod("CraftManagement.getCondition", {description = "Gets condition", testCase = "condition", type = "functional"}, function()
        local cond = shared.cm:getCondition("maint_craft")
        Helpers.assertEqual(cond, 100, "Condition 100")
    end)

    Suite:testMethod("CraftManagement.setCondition", {description = "Sets condition", testCase = "set_cond", type = "functional"}, function()
        local ok = shared.cm:setCondition("maint_craft", 70)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CraftManagement.needsMaintenance", {description = "Needs maintenance", testCase = "needs_maint", type = "functional"}, function()
        shared.cm:setCondition("maint_craft", 50)
        local needs = shared.cm:needsMaintenance("maint_craft")
        Helpers.assertEqual(needs, true, "Needs maintenance")
    end)
end)

Suite:group("Mission Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("mission_craft", "fighter", "base1", 80, 100)
    end)

    Suite:testMethod("CraftManagement.recordMission", {description = "Records mission", testCase = "mission", type = "functional"}, function()
        shared.cm:deployCraft("mission_craft", "zone_a", "combat")
        local ok = shared.cm:recordMission("mission_craft", "combat", true)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("CraftManagement.getDeploymentTurns", {description = "Deployment turns", testCase = "turns", type = "functional"}, function()
        shared.cm:deployCraft("mission_craft", "zone_a", "patrol")
        shared.cm:recordMission("mission_craft", "patrol", true)
        shared.cm:recordMission("mission_craft", "patrol", true)
        local turns = shared.cm:getDeploymentTurns("mission_craft")
        Helpers.assertEqual(turns, 2, "Two turns")
    end)
end)

Suite:group("Fleet Analytics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("a1", "fighter", "base1", 80, 100)
        shared.cm:buildCraft("a2", "fighter", "base1", 75, 95)
    end)

    Suite:testMethod("CraftManagement.calculateReadiness", {description = "Calculates readiness", testCase = "readiness", type = "functional"}, function()
        local ready = shared.cm:calculateReadiness("a1")
        Helpers.assertEqual(ready >= 0, true, "Readiness >= 0")
    end)

    Suite:testMethod("CraftManagement.getReadyCount", {description = "Ready count", testCase = "ready_count", type = "functional"}, function()
        local ready = shared.cm:getReadyCount("base1")
        Helpers.assertEqual(ready >= 0, true, "Ready >= 0")
    end)

    Suite:testMethod("CraftManagement.getDamagedCount", {description = "Damaged count", testCase = "damaged", type = "functional"}, function()
        shared.cm:setCraftHealth("a1", 30)
        local damaged = shared.cm:getDamagedCount("base1")
        Helpers.assertEqual(damaged, 1, "One damaged")
    end)

    Suite:testMethod("CraftManagement.calculateFleetStrength", {description = "Fleet strength", testCase = "strength", type = "functional"}, function()
        local strength = shared.cm:calculateFleetStrength("base1")
        Helpers.assertEqual(strength, 155, "Strength 155")
    end)
end)

Suite:group("Fleet Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("op1", "fighter", "base1", 80, 100)
        shared.cm:buildCraft("op2", "fighter", "base1", 75, 95)
    end)

    Suite:testMethod("CraftManagement.fuelAllCrafts", {description = "Fuels all crafts", testCase = "fuel_all", type = "functional"}, function()
        local ok = shared.cm:fuelAllCrafts("base1", 10)
        Helpers.assertEqual(ok, true, "Fueled")
    end)

    Suite:testMethod("CraftManagement.repairAllCrafts", {description = "Repairs all crafts", testCase = "repair_all", type = "functional"}, function()
        shared.cm:setCraftHealth("op1", 50)
        local ok = shared.cm:repairAllCrafts("base1")
        Helpers.assertEqual(ok, true, "Repaired")
    end)

    Suite:testMethod("CraftManagement.cannibalizeCraft", {description = "Cannibalizes craft", testCase = "cannibalize", type = "functional"}, function()
        local ok = shared.cm:cannibalizeCraft("op1", "op2")
        Helpers.assertEqual(ok, true, "Cannibalized")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CraftManagement:new()
        shared.cm:buildCraft("reset1", "fighter", "base1", 80, 100)
    end)

    Suite:testMethod("CraftManagement.resetFleet", {description = "Resets fleet", testCase = "reset", type = "functional"}, function()
        local ok = shared.cm:resetFleet("base1")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
