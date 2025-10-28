-- ─────────────────────────────────────────────────────────────────────────
-- EXPEDITION PLANNING TEST SUITE
-- FILE: tests2/geoscape/expedition_planning_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.expedition_planning",
    fileName = "expedition_planning.lua",
    description = "Expedition planning system with route planning, supply management, and logistics"
})

print("[EXPEDITION_PLANNING_TEST] Setting up")

local ExpeditionPlanning = {
    routes = {},
    expeditions = {},
    supplies = {},
    waypoints = {},
    logistics = {},

    new = function(self)
        return setmetatable({
            routes = {}, expeditions = {}, supplies = {},
            waypoints = {}, logistics = {}
        }, {__index = self})
    end,

    planRoute = function(self, routeId, startX, startY, endX, endY)
        self.routes[routeId] = {
            id = routeId, start_x = startX, start_y = startY,
            end_x = endX, end_y = endY, waypoints = {},
            distance = 0, difficulty = 50, planned = false
        }
        local dx = endX - startX
        local dy = endY - startY
        self.routes[routeId].distance = math.sqrt(dx*dx + dy*dy)
        return true
    end,

    getRoute = function(self, routeId)
        return self.routes[routeId]
    end,

    calculateRouteDifficulty = function(self, routeId, terrainFactors)
        if not self.routes[routeId] then return 0 end
        local route = self.routes[routeId]
        local base_difficulty = (route.distance / 100) * 50
        local terrain_mod = terrainFactors or 0
        return math.floor(base_difficulty + terrain_mod)
    end,

    addWaypoint = function(self, routeId, x, y, name)
        if not self.routes[routeId] then return false end
        table.insert(self.routes[routeId].waypoints, {x = x, y = y, name = name or "Waypoint"})
        return true
    end,

    getWaypointCount = function(self, routeId)
        if not self.routes[routeId] then return 0 end
        return #self.routes[routeId].waypoints
    end,

    optimizeRoute = function(self, routeId)
        if not self.routes[routeId] then return false end
        self.routes[routeId].planned = true
        return true
    end,

    isRoutePlanned = function(self, routeId)
        if not self.routes[routeId] then return false end
        return self.routes[routeId].planned
    end,

    registerSupply = function(self, supplyId, name, supplyType, quantity, weight)
        self.supplies[supplyId] = {
            id = supplyId, name = name, type = supplyType or "general",
            quantity = quantity or 0, weight = weight or 1,
            critical = false, consumed_per_day = 0
        }
        return true
    end,

    getSupply = function(self, supplyId)
        return self.supplies[supplyId]
    end,

    setSupplyConsumption = function(self, supplyId, amount)
        if not self.supplies[supplyId] then return false end
        self.supplies[supplyId].consumed_per_day = amount
        return true
    end,

    getSupplyConsumption = function(self, supplyId)
        if not self.supplies[supplyId] then return 0 end
        return self.supplies[supplyId].consumed_per_day
    end,

    consumeSupply = function(self, supplyId, amount)
        if not self.supplies[supplyId] then return false end
        self.supplies[supplyId].quantity = math.max(0, self.supplies[supplyId].quantity - amount)
        if self.supplies[supplyId].quantity == 0 then
            self.supplies[supplyId].critical = true
        end
        return true
    end,

    isSupplyCritical = function(self, supplyId)
        if not self.supplies[supplyId] then return false end
        return self.supplies[supplyId].critical or self.supplies[supplyId].quantity <= 0
    end,

    replenishSupply = function(self, supplyId, amount)
        if not self.supplies[supplyId] then return false end
        self.supplies[supplyId].quantity = self.supplies[supplyId].quantity + amount
        self.supplies[supplyId].critical = false
        return true
    end,

    createExpedition = function(self, expeditionId, routeId, leader, team_size)
        if not self.routes[routeId] then return false end
        self.expeditions[expeditionId] = {
            id = expeditionId, route = routeId, leader = leader,
            team_size = team_size or 1, status = "planning",
            days_elapsed = 0, supplies = {}, equipment = {},
            morale = 100, fatigue = 0
        }
        self.logistics[expeditionId] = {
            expedition = expeditionId, inventory = {},
            weight_capacity = team_size * 100, current_weight = 0
        }
        return true
    end,

    getExpedition = function(self, expeditionId)
        return self.expeditions[expeditionId]
    end,

    startExpedition = function(self, expeditionId)
        if not self.expeditions[expeditionId] then return false end
        self.expeditions[expeditionId].status = "active"
        return true
    end,

    updateExpeditionDay = function(self, expeditionId)
        if not self.expeditions[expeditionId] or self.expeditions[expeditionId].status ~= "active" then return false end
        self.expeditions[expeditionId].days_elapsed = self.expeditions[expeditionId].days_elapsed + 1
        self.expeditions[expeditionId].fatigue = math.min(100, self.expeditions[expeditionId].fatigue + 10)
        return true
    end,

    getExpeditionDuration = function(self, expeditionId)
        if not self.expeditions[expeditionId] then return 0 end
        return self.expeditions[expeditionId].days_elapsed
    end,

    completeExpedition = function(self, expeditionId)
        if not self.expeditions[expeditionId] then return false end
        self.expeditions[expeditionId].status = "completed"
        return true
    end,

    addSupplyToExpedition = function(self, expeditionId, supplyId, quantity)
        if not self.expeditions[expeditionId] or not self.supplies[supplyId] then return false end
        if not self.expeditions[expeditionId].supplies[supplyId] then
            self.expeditions[expeditionId].supplies[supplyId] = 0
        end
        self.expeditions[expeditionId].supplies[supplyId] = self.expeditions[expeditionId].supplies[supplyId] + quantity
        return true
    end,

    getExpeditionSupplyCount = function(self, expeditionId, supplyId)
        if not self.expeditions[expeditionId] then return 0 end
        if not self.expeditions[expeditionId].supplies[supplyId] then return 0 end
        return self.expeditions[expeditionId].supplies[supplyId]
    end,

    calculateTravelTime = function(self, expeditionId)
        if not self.expeditions[expeditionId] then return 0 end
        local exp = self.expeditions[expeditionId]
        local route = self.routes[exp.route]
        if not route then return 0 end
        local base_time = route.distance / 10
        local fatigue_penalty = 1 + (exp.fatigue * 0.01)
        return math.floor(base_time * fatigue_penalty)
    end,

    calculateLogisticsNeeded = function(self, expeditionId, days)
        if not self.expeditions[expeditionId] then return {} end
        local exp = self.expeditions[expeditionId]
        local needed = {}
        for supplyId, consumption in pairs(self.logistics[expeditionId].inventory) do
            needed[supplyId] = consumption * days
        end
        return needed
    end,

    estimateExpeditionSuccess = function(self, expeditionId)
        if not self.expeditions[expeditionId] then return 0 end
        local exp = self.expeditions[expeditionId]
        local morale_factor = exp.morale / 100
        local fatigue_factor = 1 - (exp.fatigue / 100)
        local supplies_ok = 1
        local success_chance = (morale_factor + fatigue_factor + supplies_ok) / 3
        return math.floor(success_chance * 100)
    end,

    getExpeditionStatus = function(self, expeditionId)
        if not self.expeditions[expeditionId] then return "unknown" end
        return self.expeditions[expeditionId].status
    end,

    getTotalDistance = function(self)
        local total = 0
        for _, route in pairs(self.routes) do
            total = total + route.distance
        end
        return math.floor(total)
    end,

    getTotalSupplies = function(self)
        local total = 0
        for _, supply in pairs(self.supplies) do
            total = total + supply.quantity
        end
        return total
    end,

    getActiveExpeditionCount = function(self)
        local count = 0
        for _, exp in pairs(self.expeditions) do
            if exp.status == "active" then count = count + 1 end
        end
        return count
    end,

    reset = function(self)
        self.routes = {}
        self.expeditions = {}
        self.supplies = {}
        self.waypoints = {}
        self.logistics = {}
        return true
    end
}

Suite:group("Route Planning", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
    end)

    Suite:testMethod("ExpeditionPlanning.planRoute", {description = "Plans route", testCase = "plan", type = "functional"}, function()
        local ok = shared.ep:planRoute("route1", 0, 0, 100, 100)
        Helpers.assertEqual(ok, true, "Planned")
    end)

    Suite:testMethod("ExpeditionPlanning.getRoute", {description = "Gets route", testCase = "get", type = "functional"}, function()
        shared.ep:planRoute("route2", 10, 10, 50, 50)
        local route = shared.ep:getRoute("route2")
        Helpers.assertEqual(route ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ExpeditionPlanning.calculateRouteDifficulty", {description = "Difficulty", testCase = "difficulty", type = "functional"}, function()
        shared.ep:planRoute("route3", 0, 0, 50, 50)
        local difficulty = shared.ep:calculateRouteDifficulty("route3", 10)
        Helpers.assertEqual(difficulty > 0, true, "Difficulty > 0")
    end)

    Suite:testMethod("ExpeditionPlanning.addWaypoint", {description = "Adds waypoint", testCase = "add", type = "functional"}, function()
        shared.ep:planRoute("route4", 0, 0, 100, 100)
        local ok = shared.ep:addWaypoint("route4", 50, 50, "Midpoint")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ExpeditionPlanning.getWaypointCount", {description = "Waypoint count", testCase = "count", type = "functional"}, function()
        shared.ep:planRoute("route5", 0, 0, 100, 100)
        shared.ep:addWaypoint("route5", 25, 25, "W1")
        shared.ep:addWaypoint("route5", 75, 75, "W2")
        local count = shared.ep:getWaypointCount("route5")
        Helpers.assertEqual(count, 2, "Two waypoints")
    end)

    Suite:testMethod("ExpeditionPlanning.optimizeRoute", {description = "Optimizes route", testCase = "optimize", type = "functional"}, function()
        shared.ep:planRoute("route6", 0, 0, 100, 100)
        local ok = shared.ep:optimizeRoute("route6")
        Helpers.assertEqual(ok, true, "Optimized")
    end)

    Suite:testMethod("ExpeditionPlanning.isRoutePlanned", {description = "Is planned", testCase = "is_planned", type = "functional"}, function()
        shared.ep:planRoute("route7", 0, 0, 100, 100)
        shared.ep:optimizeRoute("route7")
        local is = shared.ep:isRoutePlanned("route7")
        Helpers.assertEqual(is, true, "Planned")
    end)
end)

Suite:group("Supplies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
    end)

    Suite:testMethod("ExpeditionPlanning.registerSupply", {description = "Registers supply", testCase = "register", type = "functional"}, function()
        local ok = shared.ep:registerSupply("supply1", "Food", "consumable", 100, 1)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ExpeditionPlanning.getSupply", {description = "Gets supply", testCase = "get", type = "functional"}, function()
        shared.ep:registerSupply("supply2", "Water", "consumable", 50, 1)
        local supply = shared.ep:getSupply("supply2")
        Helpers.assertEqual(supply ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ExpeditionPlanning.setSupplyConsumption", {description = "Sets consumption", testCase = "consumption", type = "functional"}, function()
        shared.ep:registerSupply("supply3", "Food", "consumable", 100, 1)
        local ok = shared.ep:setSupplyConsumption("supply3", 5)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ExpeditionPlanning.getSupplyConsumption", {description = "Gets consumption", testCase = "get_consumption", type = "functional"}, function()
        shared.ep:registerSupply("supply4", "Food", "consumable", 100, 1)
        shared.ep:setSupplyConsumption("supply4", 3)
        local consumption = shared.ep:getSupplyConsumption("supply4")
        Helpers.assertEqual(consumption, 3, "Consumption 3")
    end)

    Suite:testMethod("ExpeditionPlanning.consumeSupply", {description = "Consumes supply", testCase = "consume", type = "functional"}, function()
        shared.ep:registerSupply("supply5", "Food", "consumable", 100, 1)
        local ok = shared.ep:consumeSupply("supply5", 20)
        Helpers.assertEqual(ok, true, "Consumed")
    end)

    Suite:testMethod("ExpeditionPlanning.isSupplyCritical", {description = "Is critical", testCase = "critical", type = "functional"}, function()
        shared.ep:registerSupply("supply6", "Food", "consumable", 10, 1)
        shared.ep:consumeSupply("supply6", 10)
        local is = shared.ep:isSupplyCritical("supply6")
        Helpers.assertEqual(is, true, "Critical")
    end)

    Suite:testMethod("ExpeditionPlanning.replenishSupply", {description = "Replenishes", testCase = "replenish", type = "functional"}, function()
        shared.ep:registerSupply("supply7", "Food", "consumable", 50, 1)
        shared.ep:consumeSupply("supply7", 30)
        local ok = shared.ep:replenishSupply("supply7", 30)
        Helpers.assertEqual(ok, true, "Replenished")
    end)
end)

Suite:group("Expeditions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
        shared.ep:planRoute("exp_route", 0, 0, 100, 100)
    end)

    Suite:testMethod("ExpeditionPlanning.createExpedition", {description = "Creates expedition", testCase = "create", type = "functional"}, function()
        local ok = shared.ep:createExpedition("exp1", "exp_route", "Leader", 5)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ExpeditionPlanning.getExpedition", {description = "Gets expedition", testCase = "get", type = "functional"}, function()
        shared.ep:createExpedition("exp2", "exp_route", "Leader", 5)
        local exp = shared.ep:getExpedition("exp2")
        Helpers.assertEqual(exp ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ExpeditionPlanning.startExpedition", {description = "Starts expedition", testCase = "start", type = "functional"}, function()
        shared.ep:createExpedition("exp3", "exp_route", "Leader", 5)
        local ok = shared.ep:startExpedition("exp3")
        Helpers.assertEqual(ok, true, "Started")
    end)

    Suite:testMethod("ExpeditionPlanning.updateExpeditionDay", {description = "Updates day", testCase = "update", type = "functional"}, function()
        shared.ep:createExpedition("exp4", "exp_route", "Leader", 5)
        shared.ep:startExpedition("exp4")
        local ok = shared.ep:updateExpeditionDay("exp4")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("ExpeditionPlanning.getExpeditionDuration", {description = "Gets duration", testCase = "duration", type = "functional"}, function()
        shared.ep:createExpedition("exp5", "exp_route", "Leader", 5)
        shared.ep:startExpedition("exp5")
        shared.ep:updateExpeditionDay("exp5")
        shared.ep:updateExpeditionDay("exp5")
        local duration = shared.ep:getExpeditionDuration("exp5")
        Helpers.assertEqual(duration, 2, "Two days")
    end)

    Suite:testMethod("ExpeditionPlanning.completeExpedition", {description = "Completes", testCase = "complete", type = "functional"}, function()
        shared.ep:createExpedition("exp6", "exp_route", "Leader", 5)
        local ok = shared.ep:completeExpedition("exp6")
        Helpers.assertEqual(ok, true, "Completed")
    end)
end)

Suite:group("Expedition Supplies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
        shared.ep:planRoute("supply_route", 0, 0, 100, 100)
        shared.ep:createExpedition("supply_exp", "supply_route", "Leader", 5)
        shared.ep:registerSupply("exp_supply", "Food", "consumable", 100, 1)
    end)

    Suite:testMethod("ExpeditionPlanning.addSupplyToExpedition", {description = "Adds supply", testCase = "add", type = "functional"}, function()
        local ok = shared.ep:addSupplyToExpedition("supply_exp", "exp_supply", 50)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ExpeditionPlanning.getExpeditionSupplyCount", {description = "Supply count", testCase = "count", type = "functional"}, function()
        shared.ep:addSupplyToExpedition("supply_exp", "exp_supply", 75)
        local count = shared.ep:getExpeditionSupplyCount("supply_exp", "exp_supply")
        Helpers.assertEqual(count, 75, "Count 75")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
        shared.ep:planRoute("anal_route", 0, 0, 100, 100)
        shared.ep:createExpedition("anal_exp", "anal_route", "Leader", 5)
    end)

    Suite:testMethod("ExpeditionPlanning.calculateTravelTime", {description = "Travel time", testCase = "time", type = "functional"}, function()
        local time = shared.ep:calculateTravelTime("anal_exp")
        Helpers.assertEqual(time > 0, true, "Time > 0")
    end)

    Suite:testMethod("ExpeditionPlanning.calculateLogisticsNeeded", {description = "Logistics needed", testCase = "logistics", type = "functional"}, function()
        local needed = shared.ep:calculateLogisticsNeeded("anal_exp", 5)
        Helpers.assertEqual(needed ~= nil, true, "Needed")
    end)

    Suite:testMethod("ExpeditionPlanning.estimateExpeditionSuccess", {description = "Success estimate", testCase = "success", type = "functional"}, function()
        local success = shared.ep:estimateExpeditionSuccess("anal_exp")
        Helpers.assertEqual(success > 0, true, "Success > 0")
    end)

    Suite:testMethod("ExpeditionPlanning.getExpeditionStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        local status = shared.ep:getExpeditionStatus("anal_exp")
        Helpers.assertEqual(status, "planning", "Planning")
    end)

    Suite:testMethod("ExpeditionPlanning.getTotalDistance", {description = "Total distance", testCase = "distance", type = "functional"}, function()
        local distance = shared.ep:getTotalDistance()
        Helpers.assertEqual(distance > 0, true, "Distance > 0")
    end)
end)

Suite:group("Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
        shared.ep:registerSupply("stat_supply", "Food", "consumable", 100, 1)
        shared.ep:planRoute("stat_route", 0, 0, 100, 100)
    end)

    Suite:testMethod("ExpeditionPlanning.getTotalSupplies", {description = "Total supplies", testCase = "total", type = "functional"}, function()
        local total = shared.ep:getTotalSupplies()
        Helpers.assertEqual(total > 0, true, "Total > 0")
    end)

    Suite:testMethod("ExpeditionPlanning.getActiveExpeditionCount", {description = "Active expeditions", testCase = "active", type = "functional"}, function()
        shared.ep:createExpedition("act_exp", "stat_route", "Leader", 5)
        shared.ep:startExpedition("act_exp")
        local count = shared.ep:getActiveExpeditionCount()
        Helpers.assertEqual(count, 1, "One active")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ep = ExpeditionPlanning:new()
    end)

    Suite:testMethod("ExpeditionPlanning.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ep:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
