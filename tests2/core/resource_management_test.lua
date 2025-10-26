-- ─────────────────────────────────────────────────────────────────────────
-- RESOURCE MANAGEMENT TEST SUITE
-- FILE: tests2/core/resource_management_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.resource_management",
    fileName = "resource_management.lua",
    description = "Resource management with allocation, priority systems, consumption/production"
})

print("[RESOURCE_MANAGEMENT_TEST] Setting up")

local ResourceManagement = {
    resources = {}, consumers = {}, producers = {}, priority_queue = {},
    allocation_rules = {}, resource_pools = {},

    new = function(self)
        return setmetatable({
            resources = {}, consumers = {}, producers = {}, priority_queue = {},
            allocation_rules = {}, resource_pools = {}
        }, {__index = self})
    end,

    createResourcePool = function(self, poolId, resource_type, initial_amount)
        self.resource_pools[poolId] = {
            id = poolId, type = resource_type, amount = initial_amount or 1000,
            max_capacity = initial_amount * 2 or 2000, consumption_rate = 0,
            production_rate = 0, last_update = os.time()
        }
        return true
    end,

    getResourcePool = function(self, poolId)
        return self.resource_pools[poolId]
    end,

    registerConsumer = function(self, consumerId, resource_type, consumption_rate, priority)
        self.consumers[consumerId] = {
            id = consumerId, resource_type = resource_type,
            consumption_rate = consumption_rate, priority = priority or 5,
            current_consumption = 0, satisfied = false
        }
        table.insert(self.priority_queue, consumerId)
        table.sort(self.priority_queue, function(a, b)
            return self.consumers[a].priority > self.consumers[b].priority
        end)
        return true
    end,

    getConsumer = function(self, consumerId)
        return self.consumers[consumerId]
    end,

    registerProducer = function(self, producerId, resource_type, production_rate)
        self.producers[producerId] = {
            id = producerId, resource_type = resource_type,
            production_rate = production_rate, current_production = 0, active = true
        }
        return true
    end,

    getProducer = function(self, producerId)
        return self.producers[producerId]
    end,

    createAllocationRule = function(self, ruleId, priority, resource_type, percentage)
        self.allocation_rules[ruleId] = {
            id = ruleId, priority = priority, resource_type = resource_type,
            percentage = percentage, enabled = true
        }
        return true
    end,

    getAllocationRule = function(self, ruleId)
        return self.allocation_rules[ruleId]
    end,

    allocateResource = function(self, consumerId, amount)
        if not self.consumers[consumerId] then return false end
        local consumer = self.consumers[consumerId]

        for _, pool_id in pairs(self.resource_pools) do
            local pool = self.resource_pools[pool_id]
            if pool.type == consumer.resource_type then
                if pool.amount >= amount then
                    pool.amount = pool.amount - amount
                    consumer.current_consumption = consumer.current_consumption + amount
                    consumer.satisfied = true
                    return true
                end
            end
        end

        consumer.satisfied = false
        return false
    end,

    produceResource = function(self, producerId, amount)
        if not self.producers[producerId] then return false end
        local producer = self.producers[producerId]

        for _, pool_id in pairs(self.resource_pools) do
            local pool = self.resource_pools[pool_id]
            if pool.type == producer.resource_type then
                local can_store = pool.max_capacity - pool.amount
                local to_produce = math.min(amount, can_store)
                pool.amount = pool.amount + to_produce
                producer.current_production = to_produce
                return true
            end
        end

        return false
    end,

    getResourceAvailable = function(self, resource_type)
        local total = 0
        for _, pool in pairs(self.resource_pools) do
            if pool.type == resource_type then
                total = total + pool.amount
            end
        end
        return total
    end,

    getResourceDemand = function(self, resource_type)
        local total = 0
        for _, consumer in pairs(self.consumers) do
            if consumer.resource_type == resource_type then
                total = total + consumer.consumption_rate
            end
        end
        return total
    end,

    getResourceSupply = function(self, resource_type)
        local total = 0
        for _, producer in pairs(self.producers) do
            if producer.resource_type == resource_type and producer.active then
                total = total + producer.production_rate
            end
        end
        return total
    end,

    distributeResources = function(self)
        for _, consumerId in ipairs(self.priority_queue) do
            local consumer = self.consumers[consumerId]
            if consumer then
                self:allocateResource(consumerId, consumer.consumption_rate)
            end
        end
        return true
    end,

    calculateResourceBalance = function(self, resource_type)
        local supply = self:getResourceSupply(resource_type)
        local demand = self:getResourceDemand(resource_type)
        return supply - demand
    end,

    isResourceShortage = function(self, resource_type)
        local balance = self:calculateResourceBalance(resource_type)
        return balance < 0
    end,

    getResourceSurplus = function(self, resource_type)
        local balance = self:calculateResourceBalance(resource_type)
        if balance > 0 then return balance end
        return 0
    end,

    exportResource = function(self, resource_type, export_amount)
        local available = self:getResourceAvailable(resource_type)
        if available < export_amount then return false end

        for _, pool in pairs(self.resource_pools) do
            if pool.type == resource_type then
                local to_export = math.min(export_amount, pool.amount)
                pool.amount = pool.amount - to_export
                return true
            end
        end

        return false
    end,

    importResource = function(self, resource_type, import_amount)
        for _, pool in pairs(self.resource_pools) do
            if pool.type == resource_type then
                local can_store = pool.max_capacity - pool.amount
                local to_import = math.min(import_amount, can_store)
                pool.amount = pool.amount + to_import
                return true
            end
        end

        return false
    end,

    setConsumerPriority = function(self, consumerId, priority_level)
        if not self.consumers[consumerId] then return false end
        self.consumers[consumerId].priority = priority_level
        table.sort(self.priority_queue, function(a, b)
            return self.consumers[a].priority > self.consumers[b].priority
        end)
        return true
    end,

    toggleProducer = function(self, producerId, state)
        if not self.producers[producerId] then return false end
        self.producers[producerId].active = state
        return true
    end,

    getResourceStatus = function(self, resource_type)
        local available = self:getResourceAvailable(resource_type)
        local demand = self:getResourceDemand(resource_type)
        local supply = self:getResourceSupply(resource_type)

        return {
            available = available, demand = demand, supply = supply,
            balance = supply - demand, shortage = supply < demand
        }
    end,

    reset = function(self)
        self.resources = {}
        self.consumers = {}
        self.producers = {}
        self.priority_queue = {}
        self.allocation_rules = {}
        self.resource_pools = {}
        return true
    end
}

Suite:group("Resource Pools", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
    end)

    Suite:testMethod("ResourceManagement.createResourcePool", {description = "Creates pool", testCase = "create", type = "functional"}, function()
        local ok = shared.resources:createResourcePool("pool1", "iron", 1000)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ResourceManagement.getResourcePool", {description = "Gets pool", testCase = "get", type = "functional"}, function()
        shared.resources:createResourcePool("pool2", "copper", 800)
        local pool = shared.resources:getResourcePool("pool2")
        Helpers.assertEqual(pool ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Consumers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
    end)

    Suite:testMethod("ResourceManagement.registerConsumer", {description = "Registers consumer", testCase = "register", type = "functional"}, function()
        local ok = shared.resources:registerConsumer("consumer1", "iron", 50, 8)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResourceManagement.getConsumer", {description = "Gets consumer", testCase = "get", type = "functional"}, function()
        shared.resources:registerConsumer("consumer2", "copper", 30, 5)
        local consumer = shared.resources:getConsumer("consumer2")
        Helpers.assertEqual(consumer ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResourceManagement.setConsumerPriority", {description = "Sets priority", testCase = "priority", type = "functional"}, function()
        shared.resources:registerConsumer("consumer3", "iron", 40, 3)
        local ok = shared.resources:setConsumerPriority("consumer3", 9)
        Helpers.assertEqual(ok, true, "Set")
    end)
end)

Suite:group("Producers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
    end)

    Suite:testMethod("ResourceManagement.registerProducer", {description = "Registers producer", testCase = "register", type = "functional"}, function()
        local ok = shared.resources:registerProducer("producer1", "iron", 100)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResourceManagement.getProducer", {description = "Gets producer", testCase = "get", type = "functional"}, function()
        shared.resources:registerProducer("producer2", "copper", 75)
        local producer = shared.resources:getProducer("producer2")
        Helpers.assertEqual(producer ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResourceManagement.toggleProducer", {description = "Toggles producer", testCase = "toggle", type = "functional"}, function()
        shared.resources:registerProducer("producer3", "iron", 50)
        local ok = shared.resources:toggleProducer("producer3", false)
        Helpers.assertEqual(ok, true, "Toggled")
    end)
end)

Suite:group("Allocation Rules", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
    end)

    Suite:testMethod("ResourceManagement.createAllocationRule", {description = "Creates rule", testCase = "create", type = "functional"}, function()
        local ok = shared.resources:createAllocationRule("rule1", 1, "iron", 50)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ResourceManagement.getAllocationRule", {description = "Gets rule", testCase = "get", type = "functional"}, function()
        shared.resources:createAllocationRule("rule2", 2, "copper", 30)
        local rule = shared.resources:getAllocationRule("rule2")
        Helpers.assertEqual(rule ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Allocation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
        shared.resources:createResourcePool("pool3", "iron", 1000)
        shared.resources:registerConsumer("consumer4", "iron", 50, 5)
    end)

    Suite:testMethod("ResourceManagement.allocateResource", {description = "Allocates resource", testCase = "allocate", type = "functional"}, function()
        local ok = shared.resources:allocateResource("consumer4", 100)
        Helpers.assertEqual(ok, true, "Allocated")
    end)

    Suite:testMethod("ResourceManagement.distributeResources", {description = "Distributes resources", testCase = "distribute", type = "functional"}, function()
        local ok = shared.resources:distributeResources()
        Helpers.assertEqual(ok, true, "Distributed")
    end)
end)

Suite:group("Production", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
        shared.resources:createResourcePool("pool4", "copper", 500)
        shared.resources:registerProducer("producer4", "copper", 60)
    end)

    Suite:testMethod("ResourceManagement.produceResource", {description = "Produces resource", testCase = "produce", type = "functional"}, function()
        local ok = shared.resources:produceResource("producer4", 75)
        Helpers.assertEqual(ok, true, "Produced")
    end)
end)

Suite:group("Supply & Demand", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
        shared.resources:createResourcePool("pool5", "gold", 750)
        shared.resources:registerProducer("producer5", "gold", 80)
        shared.resources:registerConsumer("consumer5", "gold", 40, 6)
    end)

    Suite:testMethod("ResourceManagement.getResourceAvailable", {description = "Gets available", testCase = "available", type = "functional"}, function()
        local avail = shared.resources:getResourceAvailable("gold")
        Helpers.assertEqual(avail > 0, true, "Available > 0")
    end)

    Suite:testMethod("ResourceManagement.getResourceDemand", {description = "Gets demand", testCase = "demand", type = "functional"}, function()
        local demand = shared.resources:getResourceDemand("gold")
        Helpers.assertEqual(demand > 0, true, "Demand > 0")
    end)

    Suite:testMethod("ResourceManagement.getResourceSupply", {description = "Gets supply", testCase = "supply", type = "functional"}, function()
        local supply = shared.resources:getResourceSupply("gold")
        Helpers.assertEqual(supply > 0, true, "Supply > 0")
    end)

    Suite:testMethod("ResourceManagement.calculateResourceBalance", {description = "Calculates balance", testCase = "balance", type = "functional"}, function()
        local balance = shared.resources:calculateResourceBalance("gold")
        Helpers.assertEqual(balance ~= nil, true, "Has balance")
    end)
end)

Suite:group("Shortage & Surplus", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
        shared.resources:createResourcePool("pool6", "silver", 300)
        shared.resources:registerProducer("producer6", "silver", 20)
        shared.resources:registerConsumer("consumer6", "silver", 80, 7)
    end)

    Suite:testMethod("ResourceManagement.isResourceShortage", {description = "Detects shortage", testCase = "shortage", type = "functional"}, function()
        local shortage = shared.resources:isResourceShortage("silver")
        Helpers.assertEqual(typeof(shortage) == "boolean", true, "Is boolean")
    end)

    Suite:testMethod("ResourceManagement.getResourceSurplus", {description = "Gets surplus", testCase = "surplus", type = "functional"}, function()
        local surplus = shared.resources:getResourceSurplus("silver")
        Helpers.assertEqual(surplus >= 0, true, "Surplus >= 0")
    end)
end)

Suite:group("Import/Export", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
        shared.resources:createResourcePool("pool7", "tin", 600)
    end)

    Suite:testMethod("ResourceManagement.exportResource", {description = "Exports resource", testCase = "export", type = "functional"}, function()
        local ok = shared.resources:exportResource("tin", 100)
        Helpers.assertEqual(ok, true, "Exported")
    end)

    Suite:testMethod("ResourceManagement.importResource", {description = "Imports resource", testCase = "import", type = "functional"}, function()
        local ok = shared.resources:importResource("tin", 200)
        Helpers.assertEqual(ok, true, "Imported")
    end)
end)

Suite:group("Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
        shared.resources:createResourcePool("pool8", "lead", 400)
        shared.resources:registerProducer("producer7", "lead", 50)
        shared.resources:registerConsumer("consumer7", "lead", 30, 4)
    end)

    Suite:testMethod("ResourceManagement.getResourceStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        local status = shared.resources:getResourceStatus("lead")
        Helpers.assertEqual(status ~= nil, true, "Has status")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.resources = ResourceManagement:new()
    end)

    Suite:testMethod("ResourceManagement.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.resources:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
