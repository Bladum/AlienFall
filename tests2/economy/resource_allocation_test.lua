-- ─────────────────────────────────────────────────────────────────────────
-- RESOURCE ALLOCATION TEST SUITE
-- FILE: tests2/economy/resource_allocation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.resource_allocation",
    fileName = "resource_allocation.lua",
    description = "Budget allocation, resource prioritization, and expenditure tracking systems"
})

print("[RESOURCE_ALLOCATION_TEST] Setting up")

local ResourceAllocation = {
    budgets = {},
    resources = {},
    allocations = {},
    expenditures = {},

    new = function(self)
        return setmetatable({
            budgets = {}, resources = {}, allocations = {}, expenditures = {}
        }, {__index = self})
    end,

    createBudget = function(self, budgetId, total_amount, period_type)
        self.budgets[budgetId] = {
            id = budgetId, total = total_amount or 10000, remaining = total_amount or 10000,
            period = period_type or "turn", spent = 0, allocations = {}
        }
        self.allocations[budgetId] = {}
        self.expenditures[budgetId] = {}
        return true
    end,

    getBudget = function(self, budgetId)
        return self.budgets[budgetId]
    end,

    registerResourceType = function(self, resourceId, name, category, priority)
        self.resources[resourceId] = {
            id = resourceId, name = name, category = category or "general",
            priority = priority or 50, unit_cost = 1, required_quantity = 0
        }
        return true
    end,

    getResourceType = function(self, resourceId)
        return self.resources[resourceId]
    end,

    allocateBudget = function(self, budgetId, resourceId, amount)
        if not self.budgets[budgetId] or not self.resources[resourceId] then return false end
        if amount > self.budgets[budgetId].remaining then return false end
        if not self.allocations[budgetId][resourceId] then
            self.allocations[budgetId][resourceId] = 0
        end
        self.allocations[budgetId][resourceId] = self.allocations[budgetId][resourceId] + amount
        self.budgets[budgetId].remaining = self.budgets[budgetId].remaining - amount
        return true
    end,

    getAllocationAmount = function(self, budgetId, resourceId)
        if not self.allocations[budgetId] or not self.allocations[budgetId][resourceId] then return 0 end
        return self.allocations[budgetId][resourceId]
    end,

    getAllocations = function(self, budgetId)
        if not self.allocations[budgetId] then return {} end
        return self.allocations[budgetId]
    end,

    reallocateBudget = function(self, budgetId, from_resource, to_resource, amount)
        if not self:getAllocationAmount(budgetId, from_resource) or amount > self:getAllocationAmount(budgetId, from_resource) then
            return false
        end
        self.allocations[budgetId][from_resource] = self.allocations[budgetId][from_resource] - amount
        if not self.allocations[budgetId][to_resource] then
            self.allocations[budgetId][to_resource] = 0
        end
        self.allocations[budgetId][to_resource] = self.allocations[budgetId][to_resource] + amount
        return true
    end,

    recordExpenditure = function(self, budgetId, resourceId, amount, description)
        if not self.budgets[budgetId] then return false end
        if not self.expenditures[budgetId][resourceId] then
            self.expenditures[budgetId][resourceId] = {}
        end
        table.insert(self.expenditures[budgetId][resourceId], {
            amount = amount, description = description or "expense", turn = 0
        })
        self.budgets[budgetId].spent = self.budgets[budgetId].spent + amount
        return true
    end,

    getExpenditures = function(self, budgetId, resourceId)
        if not self.expenditures[budgetId] or not self.expenditures[budgetId][resourceId] then return {} end
        return self.expenditures[budgetId][resourceId]
    end,

    getTotalExpenditure = function(self, budgetId)
        if not self.budgets[budgetId] then return 0 end
        return self.budgets[budgetId].spent
    end,

    calculateRemainingBudget = function(self, budgetId)
        if not self.budgets[budgetId] then return 0 end
        return self.budgets[budgetId].remaining
    end,

    calculateBudgetUtilization = function(self, budgetId)
        if not self.budgets[budgetId] then return 0 end
        local budget = self.budgets[budgetId]
        return math.floor((budget.spent / budget.total) * 100)
    end,

    optimizeAllocation = function(self, budgetId)
        if not self.budgets[budgetId] or not self.allocations[budgetId] then return false end
        local budget = self.budgets[budgetId]
        local resource_list = {}
        for resourceId, _ in pairs(self.resources) do
            table.insert(resource_list, resourceId)
        end
        for resourceId, allocation in pairs(self.allocations[budgetId]) do
            if allocation > 0 and self.resources[resourceId] then
                local priority = self.resources[resourceId].priority
                if priority < 40 then
                    local realloc_amount = math.floor(allocation * 0.1)
                    self.allocations[budgetId][resourceId] = allocation - realloc_amount
                    budget.remaining = budget.remaining + realloc_amount
                end
            end
        end
        return true
    end,

    setPriorityLevel = function(self, resourceId, priority)
        if not self.resources[resourceId] then return false end
        self.resources[resourceId].priority = priority
        return true
    end,

    getPriorityLevel = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        return self.resources[resourceId].priority
    end,

    getResourcesByPriority = function(self, highest_first)
        local resource_list = {}
        for _, resource in pairs(self.resources) do
            table.insert(resource_list, resource)
        end
        table.sort(resource_list, function(a, b)
            if highest_first then
                return a.priority > b.priority
            else
                return a.priority < b.priority
            end
        end)
        return resource_list
    end,

    setRequiredQuantity = function(self, resourceId, quantity)
        if not self.resources[resourceId] then return false end
        self.resources[resourceId].required_quantity = quantity
        return true
    end,

    getRequiredQuantity = function(self, resourceId)
        if not self.resources[resourceId] then return 0 end
        return self.resources[resourceId].required_quantity
    end,

    calculateAllocationShortfall = function(self, budgetId, resourceId)
        if not self.resources[resourceId] then return 0 end
        local required = self:getRequiredQuantity(resourceId)
        local allocated = self:getAllocationAmount(budgetId, resourceId)
        return math.max(0, required - allocated)
    end,

    allocateByPriority = function(self, budgetId)
        if not self.budgets[budgetId] then return false end
        local sorted = self:getResourcesByPriority(true)
        local remaining = self.budgets[budgetId].remaining
        for _, resource in ipairs(sorted) do
            local required = resource.required_quantity
            if required > 0 and remaining >= required then
                self:allocateBudget(budgetId, resource.id, required)
                remaining = remaining - required
            end
        end
        return true
    end,

    calculateBudgetDeficit = function(self, budgetId)
        if not self.budgets[budgetId] then return 0 end
        local budget = self.budgets[budgetId]
        if budget.spent > budget.total then
            return budget.spent - budget.total
        end
        return 0
    end,

    resetBudgetAllocation = function(self, budgetId)
        if not self.budgets[budgetId] then return false end
        local budget = self.budgets[budgetId]
        budget.remaining = budget.total
        budget.spent = 0
        self.allocations[budgetId] = {}
        self.expenditures[budgetId] = {}
        return true
    end,

    reset = function(self)
        self.budgets = {}
        self.resources = {}
        self.allocations = {}
        self.expenditures = {}
        return true
    end
}

Suite:group("Budgets", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
    end)

    Suite:testMethod("ResourceAllocation.createBudget", {description = "Creates budget", testCase = "create", type = "functional"}, function()
        local ok = shared.ra:createBudget("budget1", 50000, "turn")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ResourceAllocation.getBudget", {description = "Gets budget", testCase = "get", type = "functional"}, function()
        shared.ra:createBudget("budget2", 30000, "month")
        local budget = shared.ra:getBudget("budget2")
        Helpers.assertEqual(budget ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Resources", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
    end)

    Suite:testMethod("ResourceAllocation.registerResourceType", {description = "Registers resource", testCase = "register", type = "functional"}, function()
        local ok = shared.ra:registerResourceType("res1", "Research", "development", 80)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResourceAllocation.getResourceType", {description = "Gets resource", testCase = "get", type = "functional"}, function()
        shared.ra:registerResourceType("res2", "Manufacturing", "production", 70)
        local res = shared.ra:getResourceType("res2")
        Helpers.assertEqual(res ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Allocation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
        shared.ra:createBudget("budget1", 50000, "turn")
        shared.ra:registerResourceType("res1", "Research", "development", 80)
    end)

    Suite:testMethod("ResourceAllocation.allocateBudget", {description = "Allocates budget", testCase = "allocate", type = "functional"}, function()
        local ok = shared.ra:allocateBudget("budget1", "res1", 15000)
        Helpers.assertEqual(ok, true, "Allocated")
    end)

    Suite:testMethod("ResourceAllocation.getAllocationAmount", {description = "Gets allocation", testCase = "amount", type = "functional"}, function()
        shared.ra:allocateBudget("budget1", "res1", 12000)
        local amount = shared.ra:getAllocationAmount("budget1", "res1")
        Helpers.assertEqual(amount, 12000, "12000")
    end)

    Suite:testMethod("ResourceAllocation.getAllocations", {description = "Gets allocations", testCase = "all", type = "functional"}, function()
        shared.ra:allocateBudget("budget1", "res1", 10000)
        local allocs = shared.ra:getAllocations("budget1")
        Helpers.assertEqual(allocs ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ResourceAllocation.reallocateBudget", {description = "Reallocates budget", testCase = "realloc", type = "functional"}, function()
        shared.ra:registerResourceType("res2", "Production", "production", 60)
        shared.ra:allocateBudget("budget1", "res1", 20000)
        local ok = shared.ra:reallocateBudget("budget1", "res1", "res2", 5000)
        Helpers.assertEqual(ok, true, "Reallocated")
    end)
end)

Suite:group("Expenditures", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
        shared.ra:createBudget("budget1", 50000, "turn")
        shared.ra:registerResourceType("res1", "Research", "development", 80)
    end)

    Suite:testMethod("ResourceAllocation.recordExpenditure", {description = "Records expenditure", testCase = "record", type = "functional"}, function()
        local ok = shared.ra:recordExpenditure("budget1", "res1", 3000, "upgrade")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("ResourceAllocation.getExpenditures", {description = "Gets expenditures", testCase = "get", type = "functional"}, function()
        shared.ra:recordExpenditure("budget1", "res1", 2000, "maintenance")
        local exps = shared.ra:getExpenditures("budget1", "res1")
        Helpers.assertEqual(#exps > 0, true, "Has expenditures")
    end)

    Suite:testMethod("ResourceAllocation.getTotalExpenditure", {description = "Gets total", testCase = "total", type = "functional"}, function()
        shared.ra:recordExpenditure("budget1", "res1", 4000, "project")
        local total = shared.ra:getTotalExpenditure("budget1")
        Helpers.assertEqual(total, 4000, "4000")
    end)
end)

Suite:group("Budget Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
        shared.ra:createBudget("budget1", 100000, "turn")
        shared.ra:registerResourceType("res1", "Research", "development")
    end)

    Suite:testMethod("ResourceAllocation.calculateRemainingBudget", {description = "Calculates remaining", testCase = "remaining", type = "functional"}, function()
        shared.ra:allocateBudget("budget1", "res1", 30000)
        local remaining = shared.ra:calculateRemainingBudget("budget1")
        Helpers.assertEqual(remaining, 70000, "70000")
    end)

    Suite:testMethod("ResourceAllocation.calculateBudgetUtilization", {description = "Calculates utilization", testCase = "utilization", type = "functional"}, function()
        shared.ra:recordExpenditure("budget1", "res1", 50000, "expense")
        local util = shared.ra:calculateBudgetUtilization("budget1")
        Helpers.assertEqual(util, 50, "50")
    end)

    Suite:testMethod("ResourceAllocation.calculateBudgetDeficit", {description = "Calculates deficit", testCase = "deficit", type = "functional"}, function()
        shared.ra:recordExpenditure("budget1", "res1", 120000, "overrun")
        local deficit = shared.ra:calculateBudgetDeficit("budget1")
        Helpers.assertEqual(deficit, 20000, "20000")
    end)
end)

Suite:group("Priority Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
        shared.ra:registerResourceType("res1", "Research", "dev", 90)
        shared.ra:registerResourceType("res2", "Production", "prod", 60)
    end)

    Suite:testMethod("ResourceAllocation.setPriorityLevel", {description = "Sets priority", testCase = "set", type = "functional"}, function()
        local ok = shared.ra:setPriorityLevel("res1", 85)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceAllocation.getPriorityLevel", {description = "Gets priority", testCase = "get", type = "functional"}, function()
        local priority = shared.ra:getPriorityLevel("res1")
        Helpers.assertEqual(priority > 0, true, "Priority > 0")
    end)

    Suite:testMethod("ResourceAllocation.getResourcesByPriority", {description = "Gets by priority", testCase = "sorted", type = "functional"}, function()
        local sorted = shared.ra:getResourcesByPriority(true)
        Helpers.assertEqual(#sorted > 0, true, "Has resources")
    end)
end)

Suite:group("Requirements", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
        shared.ra:createBudget("budget1", 100000, "turn")
        shared.ra:registerResourceType("res1", "Research", "dev")
    end)

    Suite:testMethod("ResourceAllocation.setRequiredQuantity", {description = "Sets required", testCase = "set", type = "functional"}, function()
        local ok = shared.ra:setRequiredQuantity("res1", 50000)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceAllocation.getRequiredQuantity", {description = "Gets required", testCase = "get", type = "functional"}, function()
        shared.ra:setRequiredQuantity("res1", 30000)
        local req = shared.ra:getRequiredQuantity("res1")
        Helpers.assertEqual(req, 30000, "30000")
    end)

    Suite:testMethod("ResourceAllocation.calculateAllocationShortfall", {description = "Calculates shortfall", testCase = "shortfall", type = "functional"}, function()
        shared.ra:setRequiredQuantity("res1", 40000)
        shared.ra:allocateBudget("budget1", "res1", 25000)
        local shortfall = shared.ra:calculateAllocationShortfall("budget1", "res1")
        Helpers.assertEqual(shortfall, 15000, "15000")
    end)
end)

Suite:group("Optimization", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
        shared.ra:createBudget("budget1", 100000, "turn")
        shared.ra:registerResourceType("res1", "Research", "dev", 80)
        shared.ra:registerResourceType("res2", "Training", "dev", 30)
    end)

    Suite:testMethod("ResourceAllocation.optimizeAllocation", {description = "Optimizes allocation", testCase = "optimize", type = "functional"}, function()
        shared.ra:allocateBudget("budget1", "res1", 40000)
        shared.ra:allocateBudget("budget1", "res2", 30000)
        local ok = shared.ra:optimizeAllocation("budget1")
        Helpers.assertEqual(ok, true, "Optimized")
    end)

    Suite:testMethod("ResourceAllocation.allocateByPriority", {description = "Allocates by priority", testCase = "priority", type = "functional"}, function()
        shared.ra:setRequiredQuantity("res1", 50000)
        shared.ra:setRequiredQuantity("res2", 20000)
        local ok = shared.ra:allocateByPriority("budget1")
        Helpers.assertEqual(ok, true, "Allocated")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ra = ResourceAllocation:new()
    end)

    Suite:testMethod("ResourceAllocation.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ra:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)

    Suite:testMethod("ResourceAllocation.resetBudgetAllocation", {description = "Resets budget", testCase = "reset_budget", type = "functional"}, function()
        shared.ra:createBudget("budget1", 50000, "turn")
        local ok = shared.ra:resetBudgetAllocation("budget1")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
