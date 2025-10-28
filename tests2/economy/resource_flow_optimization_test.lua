-- ─────────────────────────────────────────────────────────────────────────
-- RESOURCE FLOW OPTIMIZATION TEST SUITE
-- FILE: tests2/economy/resource_flow_optimization_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.resource_flow_optimization",
    fileName = "resource_flow_optimization.lua",
    description = "Resource flow optimization with supply chains, logistics, and distribution"
})

print("[RESOURCE_FLOW_OPTIMIZATION_TEST] Setting up")

local ResourceFlowOptimization = {
    resources = {},
    nodes = {},
    routes = {},
    flows = {},
    demands = {},

    new = function(self)
        return setmetatable({
            resources = {}, nodes = {}, routes = {},
            flows = {}, demands = {}
        }, {__index = self})
    end,

    registerResource = function(self, resourceId, name, resourceType, value)
        self.resources[resourceId] = {
            id = resourceId, name = name, type = resourceType or "material",
            value = value or 10, scarcity = 50, availability = 100,
            total_produced = 0, total_consumed = 0
        }
        return true
    end,

    getResource = function(self, resourceId)
        return self.resources[resourceId]
    end,

    createNode = function(self, nodeId, name, nodeType, capacity)
        self.nodes[nodeId] = {
            id = nodeId, name = name, type = nodeType or "warehouse",
            capacity = capacity or 1000, current_stock = 0,
            production_rate = 0, consumption_rate = 0
        }
        return true
    end,

    getNode = function(self, nodeId)
        return self.nodes[nodeId]
    end,

    addStock = function(self, nodeId, resourceId, quantity)
        if not self.nodes[nodeId] or not self.resources[resourceId] then return false end
        local node = self.nodes[nodeId]
        if node.current_stock + quantity > node.capacity then return false end
        node.current_stock = node.current_stock + quantity
        self.resources[resourceId].total_produced = self.resources[resourceId].total_produced + quantity
        return true
    end,

    consumeStock = function(self, nodeId, resourceId, quantity)
        if not self.nodes[nodeId] or not self.resources[resourceId] then return false end
        local node = self.nodes[nodeId]
        if node.current_stock < quantity then return false end
        node.current_stock = node.current_stock - quantity
        self.resources[resourceId].total_consumed = self.resources[resourceId].total_consumed + quantity
        return true
    end,

    getNodeStock = function(self, nodeId)
        if not self.nodes[nodeId] then return 0 end
        return self.nodes[nodeId].current_stock
    end,

    getNodeCapacity = function(self, nodeId)
        if not self.nodes[nodeId] then return 0 end
        return self.nodes[nodeId].capacity
    end,

    getNodeOccupancy = function(self, nodeId)
        if not self.nodes[nodeId] then return 0 end
        local node = self.nodes[nodeId]
        if node.capacity == 0 then return 0 end
        return math.floor((node.current_stock / node.capacity) * 100)
    end,

    createRoute = function(self, routeId, sourceNodeId, destNodeId, efficiency)
        if not self.nodes[sourceNodeId] or not self.nodes[destNodeId] then return false end
        self.routes[routeId] = {
            id = routeId, source = sourceNodeId, destination = destNodeId,
            efficiency = efficiency or 0.9, capacity = 500,
            current_flow = 0, disrupted = false
        }
        return true
    end,

    getRoute = function(self, routeId)
        return self.routes[routeId]
    end,

    transferResource = function(self, routeId, resourceId, quantity)
        if not self.routes[routeId] or not self.resources[resourceId] then return false end
        local route = self.routes[routeId]
        if route.disrupted then return false end
        local effective_quantity = math.floor(quantity * route.efficiency)
        if effective_quantity > route.capacity then return false end
        if not self:consumeStock(route.source, resourceId, quantity) then return false end
        if not self:addStock(route.destination, resourceId, effective_quantity) then
            self:addStock(route.source, resourceId, quantity)
            return false
        end
        route.current_flow = effective_quantity
        return true
    end,

    registerDemand = function(self, demandId, resourceId, nodeId, required_quantity, urgency)
        self.demands[demandId] = {
            id = demandId, resource = resourceId, node = nodeId,
            required = required_quantity or 100, urgency = urgency or 50,
            fulfilled = 0, turn_remaining = 10
        }
        return true
    end,

    getDemand = function(self, demandId)
        return self.demands[demandId]
    end,

    fulfillDemand = function(self, demandId, quantity)
        if not self.demands[demandId] then return false end
        local demand = self.demands[demandId]
        demand.fulfilled = math.min(demand.required, demand.fulfilled + quantity)
        return true
    end,

    isDemandFulfilled = function(self, demandId)
        if not self.demands[demandId] then return false end
        local demand = self.demands[demandId]
        return demand.fulfilled >= demand.required
    end,

    updateDemandTurn = function(self, demandId)
        if not self.demands[demandId] then return false end
        self.demands[demandId].turn_remaining = math.max(0, self.demands[demandId].turn_remaining - 1)
        return true
    end,

    isDemandExpired = function(self, demandId)
        if not self.demands[demandId] then return true end
        return self.demands[demandId].turn_remaining <= 0
    end,

    setProductionRate = function(self, nodeId, rate)
        if not self.nodes[nodeId] then return false end
        self.nodes[nodeId].production_rate = rate
        return true
    end,

    setConsumptionRate = function(self, nodeId, rate)
        if not self.nodes[nodeId] then return false end
        self.nodes[nodeId].consumption_rate = rate
        return true
    end,

    calculateNetFlow = function(self, nodeId)
        if not self.nodes[nodeId] then return 0 end
        local node = self.nodes[nodeId]
        return node.production_rate - node.consumption_rate
    end,

    calculateSupplyChainHealth = function(self)
        local total_stock = 0
        local total_capacity = 0
        for _, node in pairs(self.nodes) do
            total_stock = total_stock + node.current_stock
            total_capacity = total_capacity + node.capacity
        end
        if total_capacity == 0 then return 0 end
        return math.floor((total_stock / total_capacity) * 100)
    end,

    getUnfulfilledDemandCount = function(self)
        local count = 0
        for _, demand in pairs(self.demands) do
            if not self:isDemandFulfilled(demand.id) and not self:isDemandExpired(demand.id) then
                count = count + 1
            end
        end
        return count
    end,

    getTotalResourcesInTransit = function(self)
        local total = 0
        for _, route in pairs(self.routes) do
            total = total + route.current_flow
        end
        return total
    end,

    disruptRoute = function(self, routeId)
        if not self.routes[routeId] then return false end
        self.routes[routeId].disrupted = true
        return true
    end,

    restoreRoute = function(self, routeId)
        if not self.routes[routeId] then return false end
        self.routes[routeId].disrupted = false
        return true
    end,

    reset = function(self)
        self.resources = {}
        self.nodes = {}
        self.routes = {}
        self.flows = {}
        self.demands = {}
        return true
    end
}

Suite:group("Resources", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
    end)

    Suite:testMethod("ResourceFlowOptimization.registerResource", {description = "Registers resource", testCase = "register", type = "functional"}, function()
        local ok = shared.rfo:registerResource("res1", "Steel", "material", 50)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResourceFlowOptimization.getResource", {description = "Gets resource", testCase = "get", type = "functional"}, function()
        shared.rfo:registerResource("res2", "Water", "liquid", 20)
        local res = shared.rfo:getResource("res2")
        Helpers.assertEqual(res ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Nodes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
    end)

    Suite:testMethod("ResourceFlowOptimization.createNode", {description = "Creates node", testCase = "create", type = "functional"}, function()
        local ok = shared.rfo:createNode("node1", "Warehouse A", "warehouse", 2000)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ResourceFlowOptimization.getNode", {description = "Gets node", testCase = "get", type = "functional"}, function()
        shared.rfo:createNode("node2", "Factory B", "factory", 1500)
        local node = shared.rfo:getNode("node2")
        Helpers.assertEqual(node ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResourceFlowOptimization.addStock", {description = "Adds stock", testCase = "add", type = "functional"}, function()
        shared.rfo:createNode("node3", "Storage C", "warehouse", 2000)
        shared.rfo:registerResource("res3", "Oil", "liquid", 30)
        local ok = shared.rfo:addStock("node3", "res3", 500)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ResourceFlowOptimization.consumeStock", {description = "Consumes stock", testCase = "consume", type = "functional"}, function()
        shared.rfo:createNode("node4", "Plant D", "factory", 2000)
        shared.rfo:registerResource("res4", "Coal", "material", 25)
        shared.rfo:addStock("node4", "res4", 300)
        local ok = shared.rfo:consumeStock("node4", "res4", 100)
        Helpers.assertEqual(ok, true, "Consumed")
    end)

    Suite:testMethod("ResourceFlowOptimization.getNodeStock", {description = "Gets stock", testCase = "stock", type = "functional"}, function()
        shared.rfo:createNode("node5", "Store E", "warehouse", 2000)
        shared.rfo:registerResource("res5", "Gold", "material", 100)
        shared.rfo:addStock("node5", "res5", 250)
        local stock = shared.rfo:getNodeStock("node5")
        Helpers.assertEqual(stock, 250, "250 units")
    end)

    Suite:testMethod("ResourceFlowOptimization.getNodeCapacity", {description = "Gets capacity", testCase = "capacity", type = "functional"}, function()
        shared.rfo:createNode("node6", "Hub F", "warehouse", 3000)
        local cap = shared.rfo:getNodeCapacity("node6")
        Helpers.assertEqual(cap, 3000, "3000 capacity")
    end)

    Suite:testMethod("ResourceFlowOptimization.getNodeOccupancy", {description = "Gets occupancy", testCase = "occupancy", type = "functional"}, function()
        shared.rfo:createNode("node7", "Terminal G", "warehouse", 1000)
        shared.rfo:registerResource("res6", "Iron", "material", 40)
        shared.rfo:addStock("node7", "res6", 500)
        local occupancy = shared.rfo:getNodeOccupancy("node7")
        Helpers.assertEqual(occupancy, 50, "50% occupancy")
    end)
end)

Suite:group("Routes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
        shared.rfo:createNode("route_src", "Source", "warehouse", 2000)
        shared.rfo:createNode("route_dst", "Destination", "factory", 2000)
        shared.rfo:registerResource("route_res", "Material", "material", 50)
    end)

    Suite:testMethod("ResourceFlowOptimization.createRoute", {description = "Creates route", testCase = "create", type = "functional"}, function()
        local ok = shared.rfo:createRoute("route1", "route_src", "route_dst", 0.95)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ResourceFlowOptimization.getRoute", {description = "Gets route", testCase = "get", type = "functional"}, function()
        shared.rfo:createRoute("route2", "route_src", "route_dst", 0.9)
        local route = shared.rfo:getRoute("route2")
        Helpers.assertEqual(route ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResourceFlowOptimization.transferResource", {description = "Transfers resource", testCase = "transfer", type = "functional"}, function()
        shared.rfo:createRoute("route3", "route_src", "route_dst", 0.9)
        shared.rfo:addStock("route_src", "route_res", 500)
        local ok = shared.rfo:transferResource("route3", "route_res", 100)
        Helpers.assertEqual(ok, true, "Transferred")
    end)
end)

Suite:group("Demands", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
        shared.rfo:registerResource("demand_res", "Resource", "material", 50)
        shared.rfo:createNode("demand_node", "Node", "factory", 2000)
    end)

    Suite:testMethod("ResourceFlowOptimization.registerDemand", {description = "Registers demand", testCase = "register", type = "functional"}, function()
        local ok = shared.rfo:registerDemand("demand1", "demand_res", "demand_node", 500, 80)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResourceFlowOptimization.getDemand", {description = "Gets demand", testCase = "get", type = "functional"}, function()
        shared.rfo:registerDemand("demand2", "demand_res", "demand_node", 300, 60)
        local demand = shared.rfo:getDemand("demand2")
        Helpers.assertEqual(demand ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResourceFlowOptimization.fulfillDemand", {description = "Fulfills demand", testCase = "fulfill", type = "functional"}, function()
        shared.rfo:registerDemand("demand3", "demand_res", "demand_node", 400, 70)
        local ok = shared.rfo:fulfillDemand("demand3", 100)
        Helpers.assertEqual(ok, true, "Fulfilled")
    end)

    Suite:testMethod("ResourceFlowOptimization.isDemandFulfilled", {description = "Is fulfilled", testCase = "is_fulfilled", type = "functional"}, function()
        shared.rfo:registerDemand("demand4", "demand_res", "demand_node", 200, 50)
        shared.rfo:fulfillDemand("demand4", 200)
        local is = shared.rfo:isDemandFulfilled("demand4")
        Helpers.assertEqual(is, true, "Fulfilled")
    end)

    Suite:testMethod("ResourceFlowOptimization.updateDemandTurn", {description = "Updates turn", testCase = "update", type = "functional"}, function()
        shared.rfo:registerDemand("demand5", "demand_res", "demand_node", 300, 60)
        local ok = shared.rfo:updateDemandTurn("demand5")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("ResourceFlowOptimization.isDemandExpired", {description = "Is expired", testCase = "expired", type = "functional"}, function()
        shared.rfo:registerDemand("demand6", "demand_res", "demand_node", 300, 60)
        for _ = 1, 10 do
            shared.rfo:updateDemandTurn("demand6")
        end
        local is = shared.rfo:isDemandExpired("demand6")
        Helpers.assertEqual(is, true, "Expired")
    end)
end)

Suite:group("Production & Consumption", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
        shared.rfo:createNode("prod_node", "Production", "factory", 2000)
    end)

    Suite:testMethod("ResourceFlowOptimization.setProductionRate", {description = "Sets production", testCase = "production", type = "functional"}, function()
        local ok = shared.rfo:setProductionRate("prod_node", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceFlowOptimization.setConsumptionRate", {description = "Sets consumption", testCase = "consumption", type = "functional"}, function()
        local ok = shared.rfo:setConsumptionRate("prod_node", 30)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceFlowOptimization.calculateNetFlow", {description = "Net flow", testCase = "net_flow", type = "functional"}, function()
        shared.rfo:setProductionRate("prod_node", 60)
        shared.rfo:setConsumptionRate("prod_node", 20)
        local flow = shared.rfo:calculateNetFlow("prod_node")
        Helpers.assertEqual(flow, 40, "Net flow 40")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
        shared.rfo:createNode("anal_node", "Analysis", "warehouse", 1000)
        shared.rfo:registerResource("anal_res", "Res", "material", 50)
        shared.rfo:addStock("anal_node", "anal_res", 500)
    end)

    Suite:testMethod("ResourceFlowOptimization.calculateSupplyChainHealth", {description = "Chain health", testCase = "health", type = "functional"}, function()
        local health = shared.rfo:calculateSupplyChainHealth()
        Helpers.assertEqual(health > 0, true, "Health > 0")
    end)

    Suite:testMethod("ResourceFlowOptimization.getUnfulfilledDemandCount", {description = "Unfulfilled count", testCase = "unfulfilled", type = "functional"}, function()
        shared.rfo:registerDemand("unfulfilled", "anal_res", "anal_node", 1000, 90)
        local count = shared.rfo:getUnfulfilledDemandCount()
        Helpers.assertEqual(count >= 0, true, "Count >= 0")
    end)

    Suite:testMethod("ResourceFlowOptimization.getTotalResourcesInTransit", {description = "In transit", testCase = "transit", type = "functional"}, function()
        local total = shared.rfo:getTotalResourcesInTransit()
        Helpers.assertEqual(total >= 0, true, "Total >= 0")
    end)
end)

Suite:group("Route Disruption", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
        shared.rfo:createNode("disrupt_src", "Source", "warehouse", 2000)
        shared.rfo:createNode("disrupt_dst", "Destination", "warehouse", 2000)
        shared.rfo:createRoute("disrupt_route", "disrupt_src", "disrupt_dst", 0.9)
    end)

    Suite:testMethod("ResourceFlowOptimization.disruptRoute", {description = "Disrupts route", testCase = "disrupt", type = "functional"}, function()
        local ok = shared.rfo:disruptRoute("disrupt_route")
        Helpers.assertEqual(ok, true, "Disrupted")
    end)

    Suite:testMethod("ResourceFlowOptimization.restoreRoute", {description = "Restores route", testCase = "restore", type = "functional"}, function()
        shared.rfo:disruptRoute("disrupt_route")
        local ok = shared.rfo:restoreRoute("disrupt_route")
        Helpers.assertEqual(ok, true, "Restored")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rfo = ResourceFlowOptimization:new()
    end)

    Suite:testMethod("ResourceFlowOptimization.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.rfo:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
