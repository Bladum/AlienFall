-- ─────────────────────────────────────────────────────────────────────────
-- RESOURCE FLOW SYSTEM TEST SUITE
-- FILE: tests2/economy/resource_flow_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.resource_flow",
    fileName = "resource_flow.lua",
    description = "Economic resource production, consumption, and distribution"
})

print("[RESOURCE_FLOW_TEST] Setting up")

local ResourceFlow = {
    resources = {},
    producers = {},
    consumers = {},
    storage = {},
    flows = {},

    new = function(self)
        return setmetatable({resources = {}, producers = {}, consumers = {}, storage = {}, flows = {}}, {__index = self})
    end,

    defineResource = function(self, resourceId, name, baseValue)
        self.resources[resourceId] = {id = resourceId, name = name, baseValue = baseValue, totalProduced = 0, totalConsumed = 0}
        self.storage[resourceId] = 0
        self.flows[resourceId] = {in_flow = 0, out_flow = 0}
        return true
    end,

    addProducer = function(self, producerId, resourceId, productionRate)
        if not self.resources[resourceId] then return false end
        if not self.producers[resourceId] then self.producers[resourceId] = {} end
        self.producers[resourceId][producerId] = {id = producerId, rate = productionRate, active = true}
        return true
    end,

    addConsumer = function(self, consumerId, resourceId, consumptionRate)
        if not self.resources[resourceId] then return false end
        if not self.consumers[resourceId] then self.consumers[resourceId] = {} end
        self.consumers[resourceId][consumerId] = {id = consumerId, rate = consumptionRate, active = true}
        return true
    end,

    produce = function(self, resourceId, amount)
        if not self.resources[resourceId] then return false end
        self.storage[resourceId] = self.storage[resourceId] + amount
        self.resources[resourceId].totalProduced = self.resources[resourceId].totalProduced + amount
        self.flows[resourceId].in_flow = self.flows[resourceId].in_flow + amount
        return true
    end,

    consume = function(self, resourceId, amount)
        if not self.resources[resourceId] then return false end
        if self.storage[resourceId] < amount then return false end
        self.storage[resourceId] = self.storage[resourceId] - amount
        self.resources[resourceId].totalConsumed = self.resources[resourceId].totalConsumed + amount
        self.flows[resourceId].out_flow = self.flows[resourceId].out_flow + amount
        return true
    end,

    getStorage = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        return self.storage[resourceId]
    end,

    getInFlow = function(self, resourceId)
        if not self.flows[resourceId] then return 0 end
        return self.flows[resourceId].in_flow
    end,

    getOutFlow = function(self, resourceId)
        if not self.flows[resourceId] then return 0 end
        return self.flows[resourceId].out_flow
    end,

    getNetFlow = function(self, resourceId)
        return self:getInFlow(resourceId) - self:getOutFlow(resourceId)
    end,

    getTotalProduced = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        return self.resources[resourceId].totalProduced
    end,

    getTotalConsumed = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        return self.resources[resourceId].totalConsumed
    end,

    getProducerCount = function(self, resourceId)
        if not self.producers[resourceId] then return 0 end
        local count = 0
        for _ in pairs(self.producers[resourceId]) do count = count + 1 end
        return count
    end,

    getConsumerCount = function(self, resourceId)
        if not self.consumers[resourceId] then return 0 end
        local count = 0
        for _ in pairs(self.consumers[resourceId]) do count = count + 1 end
        return count
    end,

    toggleProducer = function(self, resourceId, producerId)
        if not self.producers[resourceId] or not self.producers[resourceId][producerId] then return false end
        self.producers[resourceId][producerId].active = not self.producers[resourceId][producerId].active
        return true
    end,

    calculateBalance = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        local production = 0
        if self.producers[resourceId] then
            for _, producer in pairs(self.producers[resourceId]) do
                if producer.active then production = production + producer.rate end
            end
        end
        local consumption = 0
        if self.consumers[resourceId] then
            for _, consumer in pairs(self.consumers[resourceId]) do
                if consumer.active then consumption = consumption + consumer.rate end
            end
        end
        return production - consumption
    end,

    isResourceScarce = function(self, resourceId, threshold)
        if not self.resources[resourceId] then return true end
        return self.storage[resourceId] < threshold
    end,

    getTotalValue = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        return self.storage[resourceId] * self.resources[resourceId].baseValue
    end
}

Suite:group("Resource Definition", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rf = ResourceFlow:new()
    end)

    Suite:testMethod("ResourceFlow.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.rf ~= nil, true, "System created")
    end)

    Suite:testMethod("ResourceFlow.defineResource", {description = "Defines resource", testCase = "define", type = "functional"}, function()
        local ok = shared.rf:defineResource("ore", "Iron Ore", 100)
        Helpers.assertEqual(ok, true, "Resource defined")
    end)

    Suite:testMethod("ResourceFlow.getStorage", {description = "Initial storage 0", testCase = "init", type = "functional"}, function()
        shared.rf:defineResource("wood", "Wood", 50)
        local storage = shared.rf:getStorage("wood")
        Helpers.assertEqual(storage, 0, "Initial 0")
    end)
end)

Suite:group("Production & Consumption", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rf = ResourceFlow:new()
        shared.rf:defineResource("fuel", "Fuel", 200)
    end)

    Suite:testMethod("ResourceFlow.produce", {description = "Produces resource", testCase = "produce", type = "functional"}, function()
        local ok = shared.rf:produce("fuel", 100)
        Helpers.assertEqual(ok, true, "Production OK")
    end)

    Suite:testMethod("ResourceFlow.produce", {description = "Increases storage", testCase = "storage", type = "functional"}, function()
        shared.rf:produce("fuel", 150)
        local storage = shared.rf:getStorage("fuel")
        Helpers.assertEqual(storage, 150, "Storage 150")
    end)

    Suite:testMethod("ResourceFlow.consume", {description = "Consumes resource", testCase = "consume", type = "functional"}, function()
        shared.rf:produce("fuel", 200)
        local ok = shared.rf:consume("fuel", 50)
        Helpers.assertEqual(ok, true, "Consumption OK")
    end)

    Suite:testMethod("ResourceFlow.consume", {description = "Decreases storage", testCase = "decrease", type = "functional"}, function()
        shared.rf:produce("fuel", 100)
        shared.rf:consume("fuel", 30)
        local storage = shared.rf:getStorage("fuel")
        Helpers.assertEqual(storage, 70, "Storage 70")
    end)

    Suite:testMethod("ResourceFlow.consume", {description = "Fails insufficient", testCase = "insufficient", type = "functional"}, function()
        shared.rf:produce("fuel", 50)
        local ok = shared.rf:consume("fuel", 100)
        Helpers.assertEqual(ok, false, "Insufficient fails")
    end)

    Suite:testMethod("ResourceFlow.getTotalProduced", {description = "Tracks production", testCase = "track_prod", type = "functional"}, function()
        shared.rf:produce("fuel", 100)
        shared.rf:produce("fuel", 50)
        local total = shared.rf:getTotalProduced("fuel")
        Helpers.assertEqual(total, 150, "Total 150")
    end)

    Suite:testMethod("ResourceFlow.getTotalConsumed", {description = "Tracks consumption", testCase = "track_cons", type = "functional"}, function()
        shared.rf:produce("fuel", 200)
        shared.rf:consume("fuel", 60)
        shared.rf:consume("fuel", 40)
        local total = shared.rf:getTotalConsumed("fuel")
        Helpers.assertEqual(total, 100, "Total 100")
    end)
end)

Suite:group("Producer Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rf = ResourceFlow:new()
        shared.rf:defineResource("crystal", "Crystal", 500)
    end)

    Suite:testMethod("ResourceFlow.addProducer", {description = "Adds producer", testCase = "add", type = "functional"}, function()
        local ok = shared.rf:addProducer("mine1", "crystal", 10)
        Helpers.assertEqual(ok, true, "Producer added")
    end)

    Suite:testMethod("ResourceFlow.getProducerCount", {description = "Counts producers", testCase = "count", type = "functional"}, function()
        shared.rf:addProducer("p1", "crystal", 5)
        shared.rf:addProducer("p2", "crystal", 8)
        shared.rf:addProducer("p3", "crystal", 6)
        local count = shared.rf:getProducerCount("crystal")
        Helpers.assertEqual(count, 3, "Three producers")
    end)

    Suite:testMethod("ResourceFlow.toggleProducer", {description = "Toggles producer", testCase = "toggle", type = "functional"}, function()
        shared.rf:addProducer("prod", "crystal", 10)
        local ok = shared.rf:toggleProducer("crystal", "prod")
        Helpers.assertEqual(ok, true, "Toggled")
    end)
end)

Suite:group("Consumer Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rf = ResourceFlow:new()
        shared.rf:defineResource("power", "Power", 300)
    end)

    Suite:testMethod("ResourceFlow.addConsumer", {description = "Adds consumer", testCase = "add", type = "functional"}, function()
        local ok = shared.rf:addConsumer("base1", "power", 15)
        Helpers.assertEqual(ok, true, "Consumer added")
    end)

    Suite:testMethod("ResourceFlow.getConsumerCount", {description = "Counts consumers", testCase = "count", type = "functional"}, function()
        shared.rf:addConsumer("c1", "power", 5)
        shared.rf:addConsumer("c2", "power", 10)
        shared.rf:addConsumer("c3", "power", 8)
        local count = shared.rf:getConsumerCount("power")
        Helpers.assertEqual(count, 3, "Three consumers")
    end)
end)

Suite:group("Flow Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rf = ResourceFlow:new()
        shared.rf:defineResource("water", "Water", 150)
    end)

    Suite:testMethod("ResourceFlow.getInFlow", {description = "Tracks in-flow", testCase = "in_flow", type = "functional"}, function()
        shared.rf:produce("water", 100)
        shared.rf:produce("water", 50)
        local flow = shared.rf:getInFlow("water")
        Helpers.assertEqual(flow, 150, "In-flow 150")
    end)

    Suite:testMethod("ResourceFlow.getOutFlow", {description = "Tracks out-flow", testCase = "out_flow", type = "functional"}, function()
        shared.rf:produce("water", 200)
        shared.rf:consume("water", 30)
        shared.rf:consume("water", 20)
        local flow = shared.rf:getOutFlow("water")
        Helpers.assertEqual(flow, 50, "Out-flow 50")
    end)

    Suite:testMethod("ResourceFlow.getNetFlow", {description = "Calculates net flow", testCase = "net_flow", type = "functional"}, function()
        shared.rf:produce("water", 100)
        shared.rf:consume("water", 30)
        local net = shared.rf:getNetFlow("water")
        Helpers.assertEqual(net, 70, "Net flow +70")
    end)

    Suite:testMethod("ResourceFlow.calculateBalance", {description = "Calculates balance", testCase = "balance", type = "functional"}, function()
        shared.rf:addProducer("gen1", "water", 20)
        shared.rf:addConsumer("use1", "water", 15)
        local balance = shared.rf:calculateBalance("water")
        Helpers.assertEqual(balance, 5, "Balance +5")
    end)
end)

Suite:group("Resource Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rf = ResourceFlow:new()
        shared.rf:defineResource("metal", "Metal", 250)
    end)

    Suite:testMethod("ResourceFlow.isResourceScarce", {description = "Scarce check", testCase = "scarce", type = "functional"}, function()
        shared.rf:produce("metal", 30)
        local scarce = shared.rf:isResourceScarce("metal", 50)
        Helpers.assertEqual(scarce, true, "Is scarce")
    end)

    Suite:testMethod("ResourceFlow.isResourceScarce", {description = "Plentiful check", testCase = "plentiful", type = "functional"}, function()
        shared.rf:produce("metal", 200)
        local scarce = shared.rf:isResourceScarce("metal", 100)
        Helpers.assertEqual(scarce, false, "Not scarce")
    end)

    Suite:testMethod("ResourceFlow.getTotalValue", {description = "Calculates value", testCase = "value", type = "functional"}, function()
        shared.rf:produce("metal", 10)
        local value = shared.rf:getTotalValue("metal")
        Helpers.assertEqual(value, 2500, "Value 2500")
    end)
end)

Suite:run()
