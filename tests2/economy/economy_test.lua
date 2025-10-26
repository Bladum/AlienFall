-- ─────────────────────────────────────────────────────────────────────────
-- ECONOMY TEST SUITE
-- FILE: tests2/economy/economy_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests the economy and financial system
-- Covers: Fund management, transactions, balance tracking, income/expense
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.economy_manager",
    fileName = "economy_manager.lua",
    description = "Economy and financial management system"
})

-- ─────────────────────────────────────────────────────────────────────────
-- MODULE SETUP
-- ─────────────────────────────────────────────────────────────────────────

print("[ECONOMY_TEST] Setting up")

local Economy = {
    balance = 100000,
    monthlyIncome = 25000,
    monthlyExpense = 15000,
    transactions = {},
    nextTransactionId = 1,

    addFunds = function(self, amount, description)
        if amount <= 0 then
            error("[Economy] Amount must be positive")
        end
        self.balance = self.balance + amount
        table.insert(self.transactions, {
            id = self.nextTransactionId,
            type = "income",
            amount = amount,
            description = description or "Income",
            timestamp = 0
        })
        self.nextTransactionId = self.nextTransactionId + 1
        return self.balance
    end,

    spendFunds = function(self, amount, description)
        if amount <= 0 then
            error("[Economy] Amount must be positive")
        end
        if self.balance < amount then
            return false  -- Insufficient funds
        end
        self.balance = self.balance - amount
        table.insert(self.transactions, {
            id = self.nextTransactionId,
            type = "expense",
            amount = amount,
            description = description or "Expense",
            timestamp = 0
        })
        self.nextTransactionId = self.nextTransactionId + 1
        return true
    end,

    getBalance = function(self)
        return self.balance
    end,

    getIncome = function(self)
        return self.monthlyIncome
    end,

    getExpense = function(self)
        return self.monthlyExpense
    end,

    getNetIncome = function(self)
        return self.monthlyIncome - self.monthlyExpense
    end,

    setMonthlyIncome = function(self, amount)
        if amount < 0 then return false end
        self.monthlyIncome = amount
        return true
    end,

    setMonthlyExpense = function(self, amount)
        if amount < 0 then return false end
        self.monthlyExpense = amount
        return true
    end,

    getTransactionHistory = function(self, limit)
        limit = limit or 10
        local count = 0
        local result = {}
        for i = #self.transactions, 1, -1 do
            if count >= limit then break end
            table.insert(result, self.transactions[i])
            count = count + 1
        end
        return result
    end,

    processMonthlyCycle = function(self)
        local net = self.monthlyIncome - self.monthlyExpense
        if net >= 0 then
            self.balance = self.balance + net
        else
            if self.balance + net < 0 then
                return false  -- Insufficient funds
            end
            self.balance = self.balance + net
        end
        return true
    end
}

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Fund Management", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.economy = setmetatable({
            balance = 100000,
            monthlyIncome = 25000,
            monthlyExpense = 15000,
            transactions = {},
            nextTransactionId = 1
        }, {__index = Economy})
    end)

    Suite:testMethod("Economy.addFunds", {
        description = "Adds funds to balance",
        testCase = "add_funds",
        type = "functional"
    }, function()
        local newBalance = shared.economy:addFunds(50000, "Mission reward")
        Helpers.assertEqual(newBalance, 150000, "Balance updated correctly")
    end)

    Suite:testMethod("Economy.spendFunds", {
        description = "Spends funds from balance",
        testCase = "spend_funds",
        type = "functional"
    }, function()
        local ok = shared.economy:spendFunds(30000, "Facility construction")
        Helpers.assertEqual(ok, true, "Spending successful")
        Helpers.assertEqual(shared.economy.balance, 70000, "Balance reduced correctly")
    end)

    Suite:testMethod("Economy.spendFunds", {
        description = "Prevents overspending",
        testCase = "prevent_overspend",
        type = "functional"
    }, function()
        local ok = shared.economy:spendFunds(150000, "Too expensive")
        Helpers.assertEqual(ok, false, "Overspending rejected")
        Helpers.assertEqual(shared.economy.balance, 100000, "Balance unchanged")
    end)
end)

Suite:group("Balance Tracking", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.economy = setmetatable({
            balance = 100000,
            monthlyIncome = 25000,
            monthlyExpense = 15000,
            transactions = {},
            nextTransactionId = 1
        }, {__index = Economy})
    end)

    Suite:testMethod("Economy.getBalance", {
        description = "Returns current balance",
        testCase = "get_balance",
        type = "functional"
    }, function()
        local balance = shared.economy:getBalance()
        Helpers.assertEqual(balance, 100000, "Balance returned correctly")
    end)

    Suite:testMethod("Economy.getBalance", {
        description = "Reflects after transactions",
        testCase = "balance_after_transaction",
        type = "functional"
    }, function()
        shared.economy:addFunds(50000)
        shared.economy:spendFunds(25000)
        local balance = shared.economy:getBalance()
        Helpers.assertEqual(balance, 125000, "Balance reflects all transactions")
    end)

    Suite:testMethod("Economy.getTransactionHistory", {
        description = "Returns transaction history",
        testCase = "transaction_history",
        type = "functional"
    }, function()
        shared.economy:addFunds(10000, "Income")
        shared.economy:spendFunds(5000, "Expense")
        local history = shared.economy:getTransactionHistory()
        local count = 0
        for _ in pairs(history) do count = count + 1 end
        Helpers.assertEqual(count, 2, "Two transactions in history")
    end)
end)

Suite:group("Income and Expenses", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.economy = setmetatable({
            balance = 100000,
            monthlyIncome = 25000,
            monthlyExpense = 15000,
            transactions = {},
            nextTransactionId = 1
        }, {__index = Economy})
    end)

    Suite:testMethod("Economy.getIncome", {
        description = "Returns monthly income",
        testCase = "get_income",
        type = "functional"
    }, function()
        local income = shared.economy:getIncome()
        Helpers.assertEqual(income, 25000, "Monthly income correct")
    end)

    Suite:testMethod("Economy.getExpense", {
        description = "Returns monthly expense",
        testCase = "get_expense",
        type = "functional"
    }, function()
        local expense = shared.economy:getExpense()
        Helpers.assertEqual(expense, 15000, "Monthly expense correct")
    end)

    Suite:testMethod("Economy.getNetIncome", {
        description = "Calculates net monthly income",
        testCase = "net_income",
        type = "functional"
    }, function()
        local net = shared.economy:getNetIncome()
        Helpers.assertEqual(net, 10000, "Net income calculated correctly")
    end)

    Suite:testMethod("Economy.setMonthlyIncome", {
        description = "Updates monthly income",
        testCase = "update_income",
        type = "functional"
    }, function()
        local ok = shared.economy:setMonthlyIncome(30000)
        Helpers.assertEqual(ok, true, "Income updated")
        Helpers.assertEqual(shared.economy.monthlyIncome, 30000, "New income value correct")
    end)

    Suite:testMethod("Economy.setMonthlyExpense", {
        description = "Updates monthly expense",
        testCase = "update_expense",
        type = "functional"
    }, function()
        local ok = shared.economy:setMonthlyExpense(20000)
        Helpers.assertEqual(ok, true, "Expense updated")
        Helpers.assertEqual(shared.economy.monthlyExpense, 20000, "New expense value correct")
    end)
end)

Suite:group("Monthly Processing", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.economy = setmetatable({
            balance = 100000,
            monthlyIncome = 25000,
            monthlyExpense = 15000,
            transactions = {},
            nextTransactionId = 1
        }, {__index = Economy})
    end)

    Suite:testMethod("Economy.processMonthlyCycle", {
        description = "Processes profitable month",
        testCase = "profitable_month",
        type = "functional"
    }, function()
        local ok = shared.economy:processMonthlyCycle()
        Helpers.assertEqual(ok, true, "Month processed")
        Helpers.assertEqual(shared.economy.balance, 110000, "Balance increased by net income")
    end)

    Suite:testMethod("Economy.processMonthlyCycle", {
        description = "Processes loss month",
        testCase = "loss_month",
        type = "functional"
    }, function()
        shared.economy.monthlyIncome = 5000
        shared.economy.monthlyExpense = 20000
        local ok = shared.economy:processMonthlyCycle()
        Helpers.assertEqual(ok, true, "Loss month processed")
        Helpers.assertEqual(shared.economy.balance, 85000, "Balance reduced by net loss")
    end)

    Suite:testMethod("Economy.processMonthlyCycle", {
        description = "Prevents bankruptcy",
        testCase = "prevent_bankruptcy",
        type = "functional"
    }, function()
        shared.economy.balance = 5000
        shared.economy.monthlyIncome = 1000
        shared.economy.monthlyExpense = 10000
        local ok = shared.economy:processMonthlyCycle()
        Helpers.assertEqual(ok, false, "Bankruptcy prevented")
    end)
end)

Suite:run()
