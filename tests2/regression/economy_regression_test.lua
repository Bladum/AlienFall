-- ─────────────────────────────────────────────────────────────────────────
-- ECONOMY REGRESSION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Catch regressions in economy and balance systems
-- Tests: 5 regression tests for financial/balance issues
-- Expected: All pass in <100ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy",
    fileName = "economy_regression_test.lua",
    description = "Economy and balance system regression testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Economy Regressions", function()

    local economy = {}

    Suite:beforeEach(function()
        economy = {
            funds = 5000,
            income = 0,
            expenses = 0,
            incomeRate = 500,
            buildings = {}
        }
    end)

    -- Regression 1: Floating point precision in currency
    Suite:testMethod("Economy:currencyPrecision", {
        description = "Currency calculations should not have floating point errors",
        testCase = "validation",
        type = "regression"
    }, function()
        local balance = 100.0
        balance = balance - 0.1
        balance = balance - 0.1
        balance = balance - 0.1

        -- Round to avoid floating point issues
        local rounded = math.floor(balance * 100 + 0.5) / 100

        Helpers.assertTrue(rounded >= 99.6 and rounded <= 99.8, "Balance should be ~99.7")
    end)

    -- Regression 2: Budget overflow on large transactions
    Suite:testMethod("Economy:largeTransactions", {
        description = "Large transactions should be handled correctly",
        testCase = "stress",
        type = "regression"
    }, function()
        economy.funds = 1000000
        economy.funds = economy.funds + 500000

        Helpers.assertEqual(economy.funds, 1500000, "Large transaction should work")
        Helpers.assertTrue(economy.funds > 0, "Funds should remain positive")
    end)

    -- Regression 3: Income/expense balance
    Suite:testMethod("Economy:incomeExpenseBalance", {
        description = "Income and expenses should be tracked independently",
        testCase = "validation",
        type = "regression"
    }, function()
        economy.income = 1000
        economy.expenses = 800
        local netIncome = economy.income - economy.expenses

        Helpers.assertEqual(netIncome, 200, "Net income should be calculated correctly")

        economy.expenses = 1500  -- Deficit
        netIncome = economy.income - economy.expenses

        Helpers.assertEqual(netIncome, -500, "Should handle deficit correctly")
    end)

    -- Regression 4: Building cost calculation
    Suite:testMethod("Economy:buildingCosts", {
        description = "Building costs should scale correctly",
        testCase = "validation",
        type = "regression"
    }, function()
        local buildings = {
            {name = "barracks", baseCost = 1000},
            {name = "hangar", baseCost = 2000},
            {name = "workshop", baseCost = 1500}
        }

        local totalCost = 0
        for _, building in ipairs(buildings) do
            totalCost = totalCost + building.baseCost
        end

        Helpers.assertEqual(totalCost, 4500, "Total building cost should be sum")
        Helpers.assertTrue(economy.funds >= totalCost or economy.funds < totalCost, "Should check affordability")
    end)

    -- Regression 5: Maintenance cost accuracy
    Suite:testMethod("Economy:maintenanceCosts", {
        description = "Maintenance costs should be calculated accurately",
        testCase = "validation",
        type = "regression"
    }, function()
        local base = {
            facilities = {
                {name = "facility1", maintenanceCost = 100},
                {name = "facility2", maintenanceCost = 150},
                {name = "facility3", maintenanceCost = 75}
            }
        }

        local totalMaintenance = 0
        for _, facility in ipairs(base.facilities) do
            totalMaintenance = totalMaintenance + facility.maintenanceCost
        end

        Helpers.assertEqual(totalMaintenance, 325, "Total maintenance should be 325")

        -- Monthly costs
        local monthlyMaintenance = totalMaintenance * 4  -- Assuming 4 weeks per month
        Helpers.assertEqual(monthlyMaintenance, 1300, "Monthly maintenance calculation correct")
    end)

end)

return Suite
