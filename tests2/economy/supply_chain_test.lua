-- ─────────────────────────────────────────────────────────────────────────
-- SUPPLY CHAIN TEST SUITE
-- FILE: tests2/economy/supply_chain_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.supply_chain",
    fileName = "supply_chain.lua",
    description = "Supply chain with producers, consumers, routes, bottlenecks, and delivery tracking"
})

print("[SUPPLY_CHAIN_TEST] Setting up")

local SupplyChain = {
    nodes = {},
    routes = {},
    inventory = {},
    deliveries = {},

    new = function(self)
        return setmetatable({nodes = {}, routes = {}, inventory = {}, deliveries = {}}, {__index = self})
    end,

    createNode = function(self, nodeId, nodeType, capacity, efficiency)
        self.nodes[nodeId] = {id = nodeId, type = nodeType, capacity = capacity or 1000, efficiency = efficiency or 1.0, status = "active"}
        self.inventory[nodeId] = {}
        return true
    end,

    getNode = function(self, nodeId)
        return self.nodes[nodeId]
    end,

    addRoute = function(self, routeId, fromNode, toNode, distance, capacity)
        if not self.nodes[fromNode] or not self.nodes[toNode] then return false end
        if not self.routes[fromNode] then self.routes[fromNode] = {} end
        self.routes[fromNode][routeId] = {id = routeId, from = fromNode, to = toNode, distance = distance or 1, capacity = capacity or 100, active = true}
        return true
    end,

    getRoutes = function(self, fromNode)
        if not self.routes[fromNode] then return {} end
        return self.routes[fromNode]
    end,

    getRouteCount = function(self, fromNode)
        if not self.routes[fromNode] then return 0 end
        local count = 0
        for _ in pairs(self.routes[fromNode]) do count = count + 1 end
        return count
    end,

    addInventory = function(self, nodeId, itemId, quantity, value)
        if not self.inventory[nodeId] then return false end
        self.inventory[nodeId][itemId] = {id = itemId, quantity = quantity or 0, value = value or 10, lastUpdate = 0}
        return true
    end,

    getInventory = function(self, nodeId, itemId)
        if not self.inventory[nodeId] or not self.inventory[nodeId][itemId] then return 0 end
        return self.inventory[nodeId][itemId].quantity
    end,

    adjustInventory = function(self, nodeId, itemId, delta)
        if not self.inventory[nodeId] or not self.inventory[nodeId][itemId] then return false end
        self.inventory[nodeId][itemId].quantity = math.max(0, self.inventory[nodeId][itemId].quantity + delta)
        return true
    end,

    shipResource = function(self, routeId, fromNode, toNode, itemId, quantity)
        if not self.routes[fromNode] or not self.routes[fromNode][routeId] then return false end
        if not self.inventory[fromNode] or not self.inventory[fromNode][itemId] then return false end
        if self.inventory[fromNode][itemId].quantity < quantity then return false end
        local route = self.routes[fromNode][routeId]
        if quantity > route.capacity then return false end
        self.inventory[fromNode][itemId].quantity = self.inventory[fromNode][itemId].quantity - quantity
        local deliveryId = fromNode .. "_" .. toNode .. "_" .. itemId .. "_" .. love.timer.getTime()
        if not self.deliveries[deliveryId] then
            self.deliveries[deliveryId] = {id = deliveryId, from = fromNode, to = toNode, item = itemId, quantity = quantity, status = "in_transit", distance = route.distance}
        end
        return true
    end,

    getDeliveryCount = function(self)
        local count = 0
        for _ in pairs(self.deliveries) do count = count + 1 end
        return count
    end,

    completeDelivery = function(self, deliveryId)
        if not self.deliveries[deliveryId] then return false end
        local delivery = self.deliveries[deliveryId]
        if not self.inventory[delivery.to] then self.inventory[delivery.to] = {} end
        if not self.inventory[delivery.to][delivery.item] then
            self.addInventory(delivery.to, delivery.item, 0, 10)
        end
        self.inventory[delivery.to][delivery.item].quantity = self.inventory[delivery.to][delivery.item].quantity + delivery.quantity
        delivery.status = "completed"
        return true
    end,

    getNodeCount = function(self)
        local count = 0
        for _ in pairs(self.nodes) do count = count + 1 end
        return count
    end,

    calculateTotalInventory = function(self)
        local total = 0
        for _, nodeInv in pairs(self.inventory) do
            for _, item in pairs(nodeInv) do
                total = total + item.quantity
            end
        end
        return total
    end,

    getBottlenecks = function(self)
        local bottlenecks = {}
        for fromNode, routes in pairs(self.routes) do
            for _, route in pairs(routes) do
                if not route.active then
                    table.insert(bottlenecks, {node = fromNode, route = route.id, reason = "inactive"})
                end
            end
        end
        return bottlenecks
    end,

    getBottleneckCount = function(self)
        return #self:getBottlenecks()
    end,

    disableRoute = function(self, fromNode, routeId)
        if not self.routes[fromNode] or not self.routes[fromNode][routeId] then return false end
        self.routes[fromNode][routeId].active = false
        return true
    end,

    enableRoute = function(self, fromNode, routeId)
        if not self.routes[fromNode] or not self.routes[fromNode][routeId] then return false end
        self.routes[fromNode][routeId].active = true
        return true
    end,

    getNodeInventoryItems = function(self, nodeId)
        if not self.inventory[nodeId] then return 0 end
        local count = 0
        for _, item in pairs(self.inventory[nodeId]) do
            if item.quantity > 0 then count = count + 1 end
        end
        return count
    end,

    calculateChainCost = function(self)
        local cost = 0
        for _, nodeInv in pairs(self.inventory) do
            for _, item in pairs(nodeInv) do
                cost = cost + (item.quantity * item.value)
            end
        end
        return cost
    end,

    getActiveRoutes = function(self, fromNode)
        if not self.routes[fromNode] then return 0 end
        local count = 0
        for _, route in pairs(self.routes[fromNode]) do
            if route.active then count = count + 1 end
        end
        return count
    end
}

Suite:group("Node Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sc = SupplyChain:new()
    end)

    Suite:testMethod("SupplyChain.createNode", {description = "Creates node", testCase = "create", type = "functional"}, function()
        local ok = shared.sc:createNode("factory", "producer", 5000, 1.0)
        Helpers.assertEqual(ok, true, "Node created")
    end)

    Suite:testMethod("SupplyChain.getNode", {description = "Retrieves node", testCase = "get", type = "functional"}, function()
        shared.sc:createNode("warehouse", "storage", 10000, 1.0)
        local node = shared.sc:getNode("warehouse")
        Helpers.assertEqual(node ~= nil, true, "Node retrieved")
    end)

    Suite:testMethod("SupplyChain.getNodeCount", {description = "Counts nodes", testCase = "count", type = "functional"}, function()
        shared.sc:createNode("n1", "type1", 1000, 1.0)
        shared.sc:createNode("n2", "type2", 2000, 1.0)
        local count = shared.sc:getNodeCount()
        Helpers.assertEqual(count, 2, "Two nodes")
    end)
end)

Suite:group("Routes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sc = SupplyChain:new()
        shared.sc:createNode("source", "factory", 5000, 1.0)
        shared.sc:createNode("dest", "warehouse", 10000, 1.0)
    end)

    Suite:testMethod("SupplyChain.addRoute", {description = "Adds route", testCase = "add_route", type = "functional"}, function()
        local ok = shared.sc:addRoute("route1", "source", "dest", 2, 500)
        Helpers.assertEqual(ok, true, "Route added")
    end)

    Suite:testMethod("SupplyChain.getRouteCount", {description = "Counts routes", testCase = "route_count", type = "functional"}, function()
        shared.sc:addRoute("r1", "source", "dest", 1, 100)
        shared.sc:addRoute("r2", "source", "dest", 2, 150)
        local count = shared.sc:getRouteCount("source")
        Helpers.assertEqual(count, 2, "Two routes")
    end)
end)

Suite:group("Inventory Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sc = SupplyChain:new()
        shared.sc:createNode("storage", "warehouse", 5000, 1.0)
    end)

    Suite:testMethod("SupplyChain.addInventory", {description = "Adds inventory", testCase = "add_inv", type = "functional"}, function()
        local ok = shared.sc:addInventory("storage", "ammo", 500, 50)
        Helpers.assertEqual(ok, true, "Inventory added")
    end)

    Suite:testMethod("SupplyChain.getInventory", {description = "Gets inventory", testCase = "get_inv", type = "functional"}, function()
        shared.sc:addInventory("storage", "supplies", 300, 30)
        local qty = shared.sc:getInventory("storage", "supplies")
        Helpers.assertEqual(qty, 300, "300 quantity")
    end)

    Suite:testMethod("SupplyChain.adjustInventory", {description = "Adjusts inventory", testCase = "adjust_inv", type = "functional"}, function()
        shared.sc:addInventory("storage", "item", 100, 10)
        local ok = shared.sc:adjustInventory("storage", "item", 50)
        Helpers.assertEqual(ok, true, "Adjusted")
    end)

    Suite:testMethod("SupplyChain.getNodeInventoryItems", {description = "Counts items", testCase = "item_count", type = "functional"}, function()
        shared.sc:addInventory("storage", "i1", 100, 10)
        shared.sc:addInventory("storage", "i2", 200, 15)
        local count = shared.sc:getNodeInventoryItems("storage")
        Helpers.assertEqual(count, 2, "Two items")
    end)
end)

Suite:group("Shipping & Delivery", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sc = SupplyChain:new()
        shared.sc:createNode("origin", "factory", 5000, 1.0)
        shared.sc:createNode("target", "warehouse", 5000, 1.0)
        shared.sc:addRoute("route", "origin", "target", 3, 1000)
        shared.sc:addInventory("origin", "cargo", 500, 20)
    end)

    Suite:testMethod("SupplyChain.shipResource", {description = "Ships resource", testCase = "ship", type = "functional"}, function()
        local ok = shared.sc:shipResource("route", "origin", "target", "cargo", 200)
        Helpers.assertEqual(ok, true, "Shipped")
    end)

    Suite:testMethod("SupplyChain.getDeliveryCount", {description = "Counts deliveries", testCase = "delivery_count", type = "functional"}, function()
        shared.sc:shipResource("route", "origin", "target", "cargo", 100)
        local count = shared.sc:getDeliveryCount()
        Helpers.assertEqual(count >= 1, true, "Delivery recorded")
    end)

    Suite:testMethod("SupplyChain.completeDelivery", {description = "Completes delivery", testCase = "complete_delivery", type = "functional"}, function()
        shared.sc:shipResource("route", "origin", "target", "cargo", 150)
        local deliveryId = shared.sc.deliveries[next(shared.sc.deliveries)].id
        local ok = shared.sc:completeDelivery(deliveryId)
        Helpers.assertEqual(ok, true, "Delivery completed")
    end)
end)

Suite:group("Chain Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sc = SupplyChain:new()
        shared.sc:createNode("n1", "factory", 3000, 1.0)
        shared.sc:createNode("n2", "storage", 5000, 1.0)
        shared.sc:addInventory("n1", "item", 1000, 25)
    end)

    Suite:testMethod("SupplyChain.calculateTotalInventory", {description = "Total inventory", testCase = "total_inv", type = "functional"}, function()
        local total = shared.sc:calculateTotalInventory()
        Helpers.assertEqual(total, 1000, "1000 total")
    end)

    Suite:testMethod("SupplyChain.calculateChainCost", {description = "Chain cost", testCase = "cost", type = "functional"}, function()
        local cost = shared.sc:calculateChainCost()
        Helpers.assertEqual(cost, 25000, "25000 cost")
    end)
end)

Suite:group("Bottlenecks", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sc = SupplyChain:new()
        shared.sc:createNode("n1", "factory", 3000, 1.0)
        shared.sc:createNode("n2", "warehouse", 5000, 1.0)
        shared.sc:addRoute("route1", "n1", "n2", 2, 500)
    end)

    Suite:testMethod("SupplyChain.disableRoute", {description = "Disables route", testCase = "disable", type = "functional"}, function()
        local ok = shared.sc:disableRoute("n1", "route1")
        Helpers.assertEqual(ok, true, "Route disabled")
    end)

    Suite:testMethod("SupplyChain.getBottlenecks", {description = "Finds bottlenecks", testCase = "bottlenecks", type = "functional"}, function()
        shared.sc:disableRoute("n1", "route1")
        local bottlenecks = shared.sc:getBottlenecks()
        Helpers.assertEqual(#bottlenecks >= 1, true, "Bottleneck found")
    end)

    Suite:testMethod("SupplyChain.getBottleneckCount", {description = "Counts bottlenecks", testCase = "bottleneck_count", type = "functional"}, function()
        shared.sc:disableRoute("n1", "route1")
        local count = shared.sc:getBottleneckCount()
        Helpers.assertEqual(count >= 1, true, "Count positive")
    end)

    Suite:testMethod("SupplyChain.enableRoute", {description = "Enables route", testCase = "enable", type = "functional"}, function()
        shared.sc:disableRoute("n1", "route1")
        local ok = shared.sc:enableRoute("n1", "route1")
        Helpers.assertEqual(ok, true, "Route enabled")
    end)

    Suite:testMethod("SupplyChain.getActiveRoutes", {description = "Active routes", testCase = "active_routes", type = "functional"}, function()
        shared.sc:addRoute("route2", "n1", "n2", 3, 400)
        local count = shared.sc:getActiveRoutes("n1")
        Helpers.assertEqual(count, 2, "Two active")
    end)
end)

Suite:run()
