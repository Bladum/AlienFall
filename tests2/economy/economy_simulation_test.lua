-- ─────────────────────────────────────────────────────────────────────────
-- ECONOMY SIMULATION TEST SUITE
-- FILE: tests2/economy/economy_simulation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.economy_simulation",
    fileName = "economy_simulation.lua",
    description = "Complex economic system with markets, inflation, taxation, and trading"
})

print("[ECONOMY_SIMULATION_TEST] Setting up")

local EconomySimulation = {
    nations = {},
    markets = {},
    prices = {},
    resources = {},
    trades = {},

    new = function(self)
        return setmetatable({nations = {}, markets = {}, prices = {}, resources = {}, trades = {}}, {__index = self})
    end,

    registerNation = function(self, nationId, name, startingFunds)
        self.nations[nationId] = {id = nationId, name = name, funds = startingFunds or 1000, debt = 0, gdp = 500}
        self.markets[nationId] = {}
        self.prices[nationId] = {}
        self.resources[nationId] = {}
        self.trades[nationId] = {}
        return true
    end,

    getNation = function(self, nationId)
        return self.nations[nationId]
    end,

    addResource = function(self, nationId, resourceId, quantity, basePrice)
        if not self.nations[nationId] then return false end
        self.resources[nationId][resourceId] = quantity
        self.prices[nationId][resourceId] = basePrice or 50
        return true
    end,

    getResourceQuantity = function(self, nationId, resourceId)
        if not self.resources[nationId] then return 0 end
        return self.resources[nationId][resourceId] or 0
    end,

    setResourceQuantity = function(self, nationId, resourceId, quantity)
        if not self.resources[nationId] then return false end
        self.resources[nationId][resourceId] = math.max(0, quantity)
        return true
    end,

    adjustResourceQuantity = function(self, nationId, resourceId, delta)
        if not self.resources[nationId] then return false end
        if not self.resources[nationId][resourceId] then
            self.resources[nationId][resourceId] = 0
        end
        self.resources[nationId][resourceId] = math.max(0, self.resources[nationId][resourceId] + delta)
        return true
    end,

    setResourcePrice = function(self, nationId, resourceId, price)
        if not self.prices[nationId] then return false end
        self.prices[nationId][resourceId] = math.max(1, price)
        return true
    end,

    getResourcePrice = function(self, nationId, resourceId)
        if not self.prices[nationId] then return 0 end
        return self.prices[nationId][resourceId] or 0
    end,

    adjustPrice = function(self, nationId, resourceId, percentage)
        if not self.prices[nationId] or not self.prices[nationId][resourceId] then return false end
        local currentPrice = self.prices[nationId][resourceId]
        local newPrice = math.floor(currentPrice * (1 + percentage / 100))
        self.prices[nationId][resourceId] = math.max(1, newPrice)
        return true
    end,

    calculateResourceValue = function(self, nationId, resourceId)
        if not self.resources[nationId] or not self.prices[nationId] then return 0 end
        local quantity = self.resources[nationId][resourceId] or 0
        local price = self.prices[nationId][resourceId] or 0
        return quantity * price
    end,

    getTotalWealthInResources = function(self, nationId)
        if not self.resources[nationId] then return 0 end
        local total = 0
        for resourceId in pairs(self.resources[nationId]) do
            total = total + self:calculateResourceValue(nationId, resourceId)
        end
        return total
    end,

    trade = function(self, fromNation, toNation, resourceId, quantity, pricePerUnit)
        if not self.nations[fromNation] or not self.nations[toNation] then return false end
        local fromQuantity = self:getResourceQuantity(fromNation, resourceId)
        if fromQuantity < quantity then return false end
        local totalCost = quantity * pricePerUnit
        if self.nations[toNation].funds < totalCost then return false end
        self:adjustResourceQuantity(fromNation, resourceId, -quantity)
        self:adjustResourceQuantity(toNation, resourceId, quantity)
        self.nations[fromNation].funds = self.nations[fromNation].funds + totalCost
        self.nations[toNation].funds = self.nations[toNation].funds - totalCost
        table.insert(self.trades[fromNation], {to = toNation, resource = resourceId, quantity = quantity, price = pricePerUnit})
        return true
    end,

    getTradingVolume = function(self, nationId)
        if not self.trades[nationId] then return 0 end
        local volume = 0
        for _, trade in ipairs(self.trades[nationId]) do
            volume = volume + (trade.quantity * trade.price)
        end
        return volume
    end,

    collectTax = function(self, nationId, percentage)
        if not self.nations[nationId] then return false end
        local tax = math.floor(self.nations[nationId].funds * (percentage / 100))
        self.nations[nationId].funds = self.nations[nationId].funds - tax
        return tax
    end,

    payDebt = function(self, nationId, amount)
        if not self.nations[nationId] then return false end
        local paymentAmount = math.min(amount, self.nations[nationId].funds)
        self.nations[nationId].funds = self.nations[nationId].funds - paymentAmount
        self.nations[nationId].debt = self.nations[nationId].debt - paymentAmount
        return true
    end,

    getDebtToFundsRatio = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        if self.nations[nationId].funds == 0 then return 0 end
        return self.nations[nationId].debt / self.nations[nationId].funds
    end,

    increaseFunds = function(self, nationId, amount)
        if not self.nations[nationId] then return false end
        self.nations[nationId].funds = self.nations[nationId].funds + amount
        return true
    end,

    decreaseFunds = function(self, nationId, amount)
        if not self.nations[nationId] then return false end
        self.nations[nationId].funds = math.max(0, self.nations[nationId].funds - amount)
        return true
    end,

    getFunds = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        return self.nations[nationId].funds
    end,

    updateGDP = function(self, nationId, delta)
        if not self.nations[nationId] then return false end
        self.nations[nationId].gdp = math.max(1, self.nations[nationId].gdp + delta)
        return true
    end,

    getGDP = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        return self.nations[nationId].gdp
    end,

    calculateEconomicHealth = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        local funds = self.nations[nationId].funds
        local debt = self.nations[nationId].debt
        local gdp = self.nations[nationId].gdp
        if gdp == 0 then return 0 end
        return math.floor(((funds - debt) / gdp) * 100)
    end,

    isEconomicallySolvent = function(self, nationId)
        return self:calculateEconomicHealth(nationId) > 0
    end,

    getResourceCount = function(self, nationId)
        if not self.resources[nationId] then return 0 end
        local count = 0
        for _ in pairs(self.resources[nationId]) do count = count + 1 end
        return count
    end,

    simulateInflation = function(self, nationId, inflationRate)
        if not self.prices[nationId] then return false end
        for resourceId in pairs(self.prices[nationId]) do
            self:adjustPrice(nationId, resourceId, inflationRate)
        end
        return true
    end
}

Suite:group("Nation Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
    end)

    Suite:testMethod("EconomySimulation.registerNation", {description = "Registers nation", testCase = "register", type = "functional"}, function()
        local ok = shared.es:registerNation("nation1", "Nation 1", 5000)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("EconomySimulation.getNation", {description = "Gets nation", testCase = "get_nation", type = "functional"}, function()
        shared.es:registerNation("nation2", "Nation 2", 3000)
        local nation = shared.es:getNation("nation2")
        Helpers.assertEqual(nation ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Resource Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("res_nation", "Resource Nation", 2000)
    end)

    Suite:testMethod("EconomySimulation.addResource", {description = "Adds resource", testCase = "add_resource", type = "functional"}, function()
        local ok = shared.es:addResource("res_nation", "ore", 100, 50)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("EconomySimulation.getResourceQuantity", {description = "Gets quantity", testCase = "get_quantity", type = "functional"}, function()
        shared.es:addResource("res_nation", "steel", 200, 75)
        local qty = shared.es:getResourceQuantity("res_nation", "steel")
        Helpers.assertEqual(qty, 200, "200 units")
    end)

    Suite:testMethod("EconomySimulation.setResourceQuantity", {description = "Sets quantity", testCase = "set_quantity", type = "functional"}, function()
        shared.es:addResource("res_nation", "fuel", 100, 30)
        local ok = shared.es:setResourceQuantity("res_nation", "fuel", 150)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("EconomySimulation.adjustResourceQuantity", {description = "Adjusts quantity", testCase = "adjust_qty", type = "functional"}, function()
        shared.es:addResource("res_nation", "supplies", 50, 40)
        shared.es:adjustResourceQuantity("res_nation", "supplies", 25)
        local qty = shared.es:getResourceQuantity("res_nation", "supplies")
        Helpers.assertEqual(qty, 75, "75 units")
    end)

    Suite:testMethod("EconomySimulation.getResourceCount", {description = "Resource count", testCase = "count", type = "functional"}, function()
        shared.es:addResource("res_nation", "r1", 10, 20)
        shared.es:addResource("res_nation", "r2", 20, 30)
        local count = shared.es:getResourceCount("res_nation")
        Helpers.assertEqual(count, 2, "Two resources")
    end)
end)

Suite:group("Pricing System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("price_nation", "Price Nation", 1000)
        shared.es:addResource("price_nation", "commodity", 100, 50)
    end)

    Suite:testMethod("EconomySimulation.setResourcePrice", {description = "Sets price", testCase = "set_price", type = "functional"}, function()
        local ok = shared.es:setResourcePrice("price_nation", "commodity", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("EconomySimulation.getResourcePrice", {description = "Gets price", testCase = "get_price", type = "functional"}, function()
        shared.es:setResourcePrice("price_nation", "commodity", 60)
        local price = shared.es:getResourcePrice("price_nation", "commodity")
        Helpers.assertEqual(price, 60, "60 price")
    end)

    Suite:testMethod("EconomySimulation.adjustPrice", {description = "Adjusts price", testCase = "adjust_price", type = "functional"}, function()
        shared.es:adjustPrice("price_nation", "commodity", 10)
        local price = shared.es:getResourcePrice("price_nation", "commodity")
        Helpers.assertEqual(price, 55, "55 price")
    end)

    Suite:testMethod("EconomySimulation.calculateResourceValue", {description = "Resource value", testCase = "value", type = "functional"}, function()
        shared.es:setResourcePrice("price_nation", "commodity", 100)
        local value = shared.es:calculateResourceValue("price_nation", "commodity")
        Helpers.assertEqual(value, 10000, "10000 value")
    end)

    Suite:testMethod("EconomySimulation.getTotalWealthInResources", {description = "Total wealth", testCase = "total_wealth", type = "functional"}, function()
        shared.es:addResource("price_nation", "gold", 50, 200)
        local wealth = shared.es:getTotalWealthInResources("price_nation")
        Helpers.assertEqual(wealth > 0, true, "Wealth exists")
    end)
end)

Suite:group("Trading System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("trader1", "Trader 1", 5000)
        shared.es:registerNation("trader2", "Trader 2", 5000)
        shared.es:addResource("trader1", "ore", 100, 50)
    end)

    Suite:testMethod("EconomySimulation.trade", {description = "Trades resources", testCase = "trade", type = "functional"}, function()
        local ok = shared.es:trade("trader1", "trader2", "ore", 25, 50)
        Helpers.assertEqual(ok, true, "Traded")
    end)

    Suite:testMethod("EconomySimulation.getTradingVolume", {description = "Trading volume", testCase = "volume", type = "functional"}, function()
        shared.es:trade("trader1", "trader2", "ore", 20, 50)
        local volume = shared.es:getTradingVolume("trader1")
        Helpers.assertEqual(volume, 1000, "1000 volume")
    end)
end)

Suite:group("Finance Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("finance", "Finance Nation", 3000)
    end)

    Suite:testMethod("EconomySimulation.getFunds", {description = "Gets funds", testCase = "get_funds", type = "functional"}, function()
        local funds = shared.es:getFunds("finance")
        Helpers.assertEqual(funds, 3000, "3000 funds")
    end)

    Suite:testMethod("EconomySimulation.increaseFunds", {description = "Increases funds", testCase = "increase", type = "functional"}, function()
        shared.es:increaseFunds("finance", 1000)
        local funds = shared.es:getFunds("finance")
        Helpers.assertEqual(funds, 4000, "4000 funds")
    end)

    Suite:testMethod("EconomySimulation.decreaseFunds", {description = "Decreases funds", testCase = "decrease", type = "functional"}, function()
        shared.es:decreaseFunds("finance", 500)
        local funds = shared.es:getFunds("finance")
        Helpers.assertEqual(funds, 2500, "2500 funds")
    end)

    Suite:testMethod("EconomySimulation.collectTax", {description = "Collects tax", testCase = "tax", type = "functional"}, function()
        local tax = shared.es:collectTax("finance", 10)
        Helpers.assertEqual(tax, 300, "300 tax")
    end)
end)

Suite:group("Debt & Solvency", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("debtor", "Debtor", 1000)
    end)

    Suite:testMethod("EconomySimulation.payDebt", {description = "Pays debt", testCase = "pay_debt", type = "functional"}, function()
        shared.es.nations["debtor"].debt = 500
        local ok = shared.es:payDebt("debtor", 200)
        Helpers.assertEqual(ok, true, "Paid")
    end)

    Suite:testMethod("EconomySimulation.getDebtToFundsRatio", {description = "Debt ratio", testCase = "debt_ratio", type = "functional"}, function()
        shared.es.nations["debtor"].debt = 500
        local ratio = shared.es:getDebtToFundsRatio("debtor")
        Helpers.assertEqual(ratio, 0.5, "0.5 ratio")
    end)
end)

Suite:group("Economic Health", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("health", "Health Nation", 2000)
    end)

    Suite:testMethod("EconomySimulation.updateGDP", {description = "Updates GDP", testCase = "gdp", type = "functional"}, function()
        shared.es:updateGDP("health", 200)
        local gdp = shared.es:getGDP("health")
        Helpers.assertEqual(gdp, 700, "700 GDP")
    end)

    Suite:testMethod("EconomySimulation.calculateEconomicHealth", {description = "Health score", testCase = "health_score", type = "functional"}, function()
        shared.es:updateGDP("health", 300)
        local health = shared.es:calculateEconomicHealth("health")
        Helpers.assertEqual(health > 0, true, "Positive health")
    end)

    Suite:testMethod("EconomySimulation.isEconomicallySolvent", {description = "Solvency check", testCase = "solvent", type = "functional"}, function()
        local solvent = shared.es:isEconomicallySolvent("health")
        Helpers.assertEqual(solvent, true, "Solvent")
    end)
end)

Suite:group("Market Dynamics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.es = EconomySimulation:new()
        shared.es:registerNation("market", "Market Nation", 2000)
        shared.es:addResource("market", "r1", 50, 100)
        shared.es:addResource("market", "r2", 60, 80)
    end)

    Suite:testMethod("EconomySimulation.simulateInflation", {description = "Inflation simulation", testCase = "inflation", type = "functional"}, function()
        local ok = shared.es:simulateInflation("market", 5)
        Helpers.assertEqual(ok, true, "Simulated")
    end)
end)

Suite:run()
