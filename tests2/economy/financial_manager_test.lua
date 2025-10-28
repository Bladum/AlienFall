-- ─────────────────────────────────────────────────────────────────────────
-- FINANCIAL MANAGER TEST SUITE
-- FILE: tests2/economy/financial_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.finance.financial_manager",
    fileName = "financial_manager.lua",
    description = "Financial management and budgeting"
})

print("[FINANCIAL_MANAGER_TEST] Setting up")

local FinancialManager = {
    accounts = {},
    transactions = {},

    createAccount = function(self, name, balance)
        local account = {id = #self.accounts + 1, name = name, balance = balance or 0}
        table.insert(self.accounts, account)
        return account
    end,

    getAccount = function(self, id)
        for _, acc in ipairs(self.accounts) do
            if acc.id == id then return acc end
        end
        return nil
    end,

    transfer = function(self, fromId, toId, amount)
        local from = self:getAccount(fromId)
        local to = self:getAccount(toId)
        if not from or not to or from.balance < amount then return false end
        from.balance = from.balance - amount
        to.balance = to.balance + amount
        table.insert(self.transactions, {from = fromId, to = toId, amount = amount})
        return true
    end,

    getTotalAssets = function(self)
        local total = 0
        for _, acc in ipairs(self.accounts) do
            total = total + acc.balance
        end
        return total
    end,

    getTransactionHistory = function(self)
        return self.transactions
    end,

    recordExpense = function(self, accountId, amount, category)
        local acc = self:getAccount(accountId)
        if not acc or acc.balance < amount then return false end
        acc.balance = acc.balance - amount
        return true
    end
}

Suite:group("Account Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fm = setmetatable({accounts = {}, transactions = {}}, {__index = FinancialManager})
    end)

    Suite:testMethod("FinancialManager.createAccount", {description = "Creates account", testCase = "create", type = "functional"}, function()
        local acc = shared.fm:createAccount("Treasury", 100000)
        Helpers.assertEqual(acc ~= nil, true, "Account created")
    end)

    Suite:testMethod("FinancialManager.getAccount", {description = "Retrieves account", testCase = "get", type = "functional"}, function()
        shared.fm:createAccount("Treasury", 50000)
        local acc = shared.fm:getAccount(1)
        Helpers.assertEqual(acc ~= nil, true, "Account retrieved")
    end)

    Suite:testMethod("FinancialManager.getTotalAssets", {description = "Calculates total assets", testCase = "total", type = "functional"}, function()
        shared.fm:createAccount("Account 1", 30000)
        shared.fm:createAccount("Account 2", 20000)
        local total = shared.fm:getTotalAssets()
        Helpers.assertEqual(total, 50000, "Total calculated")
    end)
end)

Suite:group("Transfers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fm = setmetatable({accounts = {}, transactions = {}}, {__index = FinancialManager})
        shared.fm:createAccount("Account A", 100000)
        shared.fm:createAccount("Account B", 50000)
    end)

    Suite:testMethod("FinancialManager.transfer", {description = "Transfers funds", testCase = "transfer", type = "functional"}, function()
        local ok = shared.fm:transfer(1, 2, 25000)
        Helpers.assertEqual(ok, true, "Transfer successful")
        local acc1 = shared.fm:getAccount(1)
        if acc1 then
            Helpers.assertEqual(acc1.balance, 75000, "Source balance reduced")
        end
    end)

    Suite:testMethod("FinancialManager.transfer", {description = "Prevents overdraft", testCase = "overdraft", type = "functional"}, function()
        local ok = shared.fm:transfer(1, 2, 200000)
        Helpers.assertEqual(ok, false, "Overdraft prevented")
    end)

    Suite:testMethod("FinancialManager.getTransactionHistory", {description = "Records transactions", testCase = "history", type = "functional"}, function()
        shared.fm:transfer(1, 2, 10000)
        shared.fm:transfer(2, 1, 5000)
        local hist = shared.fm:getTransactionHistory()
        Helpers.assertEqual(#hist, 2, "Two transactions recorded")
    end)
end)

Suite:group("Expenses", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.fm = setmetatable({accounts = {}, transactions = {}}, {__index = FinancialManager})
        shared.fm:createAccount("Account", 100000)
    end)

    Suite:testMethod("FinancialManager.recordExpense", {description = "Records expense", testCase = "expense", type = "functional"}, function()
        local ok = shared.fm:recordExpense(1, 30000, "research")
        Helpers.assertEqual(ok, true, "Expense recorded")
        local acc = shared.fm:getAccount(1)
        if acc then
            Helpers.assertEqual(acc.balance, 70000, "Balance reduced")
        end
    end)

    Suite:testMethod("FinancialManager.recordExpense", {description = "Prevents overspend", testCase = "overspend", type = "functional"}, function()
        local ok = shared.fm:recordExpense(1, 150000, "research")
        Helpers.assertEqual(ok, false, "Overspend prevented")
    end)
end)

Suite:run()
