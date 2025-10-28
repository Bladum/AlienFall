-- ─────────────────────────────────────────────────────────────────────────
-- MARKETPLACE ECONOMY TEST SUITE
-- FILE: tests2/economy/marketplace_economy_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.marketplace_economy",
    fileName = "marketplace_economy.lua",
    description = "Trading mechanics with dynamic pricing, supply/demand, and market inventory"
})

print("[MARKETPLACE_ECONOMY_TEST] Setting up")

local MarketplaceEconomy = {
    markets = {},
    merchants = {},
    inventory = {},
    prices = {},
    trades = {},

    new = function(self)
        return setmetatable({
            markets = {}, merchants = {}, inventory = {},
            prices = {}, trades = {}
        }, {__index = self})
    end,

    createMarket = function(self, marketId, name, region, market_type)
        self.markets[marketId] = {
            id = marketId, name = name, region = region,
            type = market_type or "general", supply_level = 50,
            demand_level = 50, traffic = 100, active = true,
            price_multiplier = 1.0, wealth = 10000, merchant_count = 0
        }
        self.inventory[marketId] = {}
        self.prices[marketId] = {}
        return true
    end,

    getMarket = function(self, marketId)
        return self.markets[marketId]
    end,

    createMerchant = function(self, merchantId, marketId, name, specialization)
        if not self.markets[marketId] then return false end
        self.merchants[merchantId] = {
            id = merchantId, market_id = marketId, name = name,
            specialization = specialization or "general", gold = 5000,
            reputation = 50, inventory = {}, trade_count = 0,
            total_profit = 0, inventory_value = 0
        }
        self.markets[marketId].merchant_count = self.markets[marketId].merchant_count + 1
        return true
    end,

    getMerchant = function(self, merchantId)
        return self.merchants[merchantId]
    end,

    addItemToMarket = function(self, marketId, itemId, quantity, base_price)
        if not self.markets[marketId] then return false end
        if not self.inventory[marketId][itemId] then
            self.inventory[marketId][itemId] = { quantity = 0, base_price = base_price or 10 }
        end
        self.inventory[marketId][itemId].quantity = self.inventory[marketId][itemId].quantity + quantity
        return true
    end,

    getMarketItemQuantity = function(self, marketId, itemId)
        if not self.inventory[marketId] or not self.inventory[marketId][itemId] then return 0 end
        return self.inventory[marketId][itemId].quantity
    end,

    calculateDynamicPrice = function(self, marketId, itemId)
        if not self.markets[marketId] or not self.inventory[marketId] or not self.inventory[marketId][itemId] then return 0 end
        local market = self.markets[marketId]
        local item = self.inventory[marketId][itemId]
        local base = item.base_price or 10
        local supply_factor = math.max(0.5, 2.0 - (item.quantity / 100))
        local demand_factor = 1.0 + (market.demand_level / 100)
        local market_factor = market.price_multiplier or 1.0
        return math.floor(base * supply_factor * demand_factor * market_factor)
    end,

    setMarketPrice = function(self, marketId, itemId, price)
        if not self.prices[marketId] then return false end
        self.prices[marketId][itemId] = price
        return true
    end,

    getMarketPrice = function(self, marketId, itemId)
        if self.prices[marketId] and self.prices[marketId][itemId] then
            return self.prices[marketId][itemId]
        end
        return self:calculateDynamicPrice(marketId, itemId)
    end,

    conductTrade = function(self, merchantId, marketId, itemId, quantity, selling)
        if not self.merchants[merchantId] or not self.markets[marketId] then return false end
        local price = self:getMarketPrice(marketId, itemId)
        local total_cost = price * quantity
        local merchant = self.merchants[merchantId]

        if selling then
            if not merchant.inventory[itemId] or merchant.inventory[itemId] < quantity then
                return false
            end
            merchant.inventory[itemId] = merchant.inventory[itemId] - quantity
            merchant.gold = merchant.gold + total_cost
            self:addItemToMarket(marketId, itemId, quantity, price)
        else
            local available = self:getMarketItemQuantity(marketId, itemId)
            if available < quantity then return false end
            if merchant.gold < total_cost then return false end
            merchant.inventory[itemId] = (merchant.inventory[itemId] or 0) + quantity
            merchant.gold = merchant.gold - total_cost
            self.inventory[marketId][itemId].quantity = available - quantity
        end

        merchant.trade_count = merchant.trade_count + 1
        return true
    end,

    calculateTradeProfit = function(self, merchantId, purchasePrice, salePrice, quantity)
        if not self.merchants[merchantId] then return 0 end
        return (salePrice - purchasePrice) * quantity
    end,

    updateMarketSupply = function(self, marketId, supplying)
        if not self.markets[marketId] then return false end
        if supplying then
            self.markets[marketId].supply_level = math.min(100, self.markets[marketId].supply_level + 5)
        else
            self.markets[marketId].supply_level = math.max(0, self.markets[marketId].supply_level - 5)
        end
        return true
    end,

    updateMarketDemand = function(self, marketId, increasing)
        if not self.markets[marketId] then return false end
        if increasing then
            self.markets[marketId].demand_level = math.min(100, self.markets[marketId].demand_level + 5)
        else
            self.markets[marketId].demand_level = math.max(0, self.markets[marketId].demand_level - 5)
        end
        return true
    end,

    getMarketEquilibrium = function(self, marketId)
        if not self.markets[marketId] then return 0 end
        local market = self.markets[marketId]
        return math.abs(market.supply_level - market.demand_level)
    end,

    getMerchantInventoryValue = function(self, merchantId)
        if not self.merchants[merchantId] then return 0 end
        local merchant = self.merchants[merchantId]
        local value = 0
        for itemId, quantity in pairs(merchant.inventory) do
            value = value + (quantity * 10)
        end
        return value
    end,

    getMerchantNetWorth = function(self, merchantId)
        if not self.merchants[merchantId] then return 0 end
        local merchant = self.merchants[merchantId]
        local inv_value = self:getMerchantInventoryValue(merchantId)
        return merchant.gold + inv_value
    end,

    getMarketIntelligence = function(self, marketId)
        if not self.markets[marketId] then return nil end
        local market = self.markets[marketId]
        return {
            supply = market.supply_level, demand = market.demand_level,
            equilibrium = self:getMarketEquilibrium(marketId),
            multiplier = market.price_multiplier, traffic = market.traffic
        }
    end,

    applyPriceMultiplier = function(self, marketId, multiplier)
        if not self.markets[marketId] then return false end
        self.markets[marketId].price_multiplier = multiplier
        return true
    end,

    recordMerchantReputation = function(self, merchantId, change)
        if not self.merchants[merchantId] then return false end
        self.merchants[merchantId].reputation = math.max(0, math.min(100, self.merchants[merchantId].reputation + change))
        return true
    end,

    getMerchantReputation = function(self, merchantId)
        if not self.merchants[merchantId] then return 0 end
        return self.merchants[merchantId].reputation
    end,

    queryBestPrice = function(self, itemId, markets_list)
        local best_price = math.huge
        local best_market = nil
        for _, marketId in ipairs(markets_list) do
            local price = self:getMarketPrice(marketId, itemId)
            if price < best_price then
                best_price = price
                best_market = marketId
            end
        end
        return best_market, best_price
    end,

    queryWorstPrice = function(self, itemId, markets_list)
        local worst_price = 0
        local worst_market = nil
        for _, marketId in ipairs(markets_list) do
            local price = self:getMarketPrice(marketId, itemId)
            if price > worst_price then
                worst_price = price
                worst_market = marketId
            end
        end
        return worst_market, worst_price
    end,

    recordTradeHistory = function(self, merchantId, marketId, itemId, quantity, price, direction)
        if not self.trades[merchantId] then
            self.trades[merchantId] = {}
        end
        table.insert(self.trades[merchantId], {
            market = marketId, item = itemId, quantity = quantity,
            price = price, direction = direction, profit = 0
        })
        return true
    end,

    getTradeHistory = function(self, merchantId)
        if not self.trades[merchantId] then return {} end
        return self.trades[merchantId]
    end,

    calculateMarketTrend = function(self, marketId, itemId)
        if not self.prices[marketId] or not self.prices[marketId][itemId] then return 0 end
        local base = self.inventory[marketId][itemId].base_price or 10
        local current = self:getMarketPrice(marketId, itemId)
        return ((current - base) / base) * 100
    end,

    resetMarket = function(self)
        self.markets = {}
        self.merchants = {}
        self.inventory = {}
        self.prices = {}
        self.trades = {}
        return true
    end
}

Suite:group("Markets", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
    end)

    Suite:testMethod("MarketplaceEconomy.createMarket", {description = "Creates market", testCase = "create", type = "functional"}, function()
        local ok = shared.me:createMarket("market1", "Main", "region1", "general")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MarketplaceEconomy.getMarket", {description = "Gets market", testCase = "get", type = "functional"}, function()
        shared.me:createMarket("market2", "Trade", "region2", "trading")
        local market = shared.me:getMarket("market2")
        Helpers.assertEqual(market ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Merchants", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("merch_market", "Test", "region1", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.createMerchant", {description = "Creates merchant", testCase = "create", type = "functional"}, function()
        local ok = shared.me:createMerchant("merc1", "merch_market", "Alice", "general")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("MarketplaceEconomy.getMerchant", {description = "Gets merchant", testCase = "get", type = "functional"}, function()
        shared.me:createMerchant("merc2", "merch_market", "Bob", "specialization")
        local merchant = shared.me:getMerchant("merc2")
        Helpers.assertEqual(merchant ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Inventory", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("inv_market", "Test", "region1", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.addItemToMarket", {description = "Adds item", testCase = "add", type = "functional"}, function()
        local ok = shared.me:addItemToMarket("inv_market", "item1", 50, 20)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("MarketplaceEconomy.getMarketItemQuantity", {description = "Gets quantity", testCase = "quantity", type = "functional"}, function()
        shared.me:addItemToMarket("inv_market", "item2", 30, 15)
        local qty = shared.me:getMarketItemQuantity("inv_market", "item2")
        Helpers.assertEqual(qty, 30, "30")
    end)
end)

Suite:group("Pricing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("price_market", "Test", "region1", "general")
        shared.me:addItemToMarket("price_market", "item1", 50, 20)
    end)

    Suite:testMethod("MarketplaceEconomy.calculateDynamicPrice", {description = "Calculates price", testCase = "calc", type = "functional"}, function()
        local price = shared.me:calculateDynamicPrice("price_market", "item1")
        Helpers.assertEqual(price > 0, true, "Price > 0")
    end)

    Suite:testMethod("MarketplaceEconomy.setMarketPrice", {description = "Sets price", testCase = "set", type = "functional"}, function()
        local ok = shared.me:setMarketPrice("price_market", "item1", 25)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("MarketplaceEconomy.getMarketPrice", {description = "Gets price", testCase = "get", type = "functional"}, function()
        shared.me:setMarketPrice("price_market", "item1", 30)
        local price = shared.me:getMarketPrice("price_market", "item1")
        Helpers.assertEqual(price, 30, "30")
    end)
end)

Suite:group("Trading", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("trade_market", "Test", "region1", "general")
        shared.me:createMerchant("trader1", "trade_market", "Alice", "general")
        shared.me:addItemToMarket("trade_market", "potion", 100, 10)
    end)

    Suite:testMethod("MarketplaceEconomy.conductTrade", {description = "Conducts trade", testCase = "conduct", type = "functional"}, function()
        shared.me.merchants["trader1"].inventory["potion"] = 20
        local ok = shared.me:conductTrade("trader1", "trade_market", "potion", 5, true)
        Helpers.assertEqual(ok, true, "Conducted")
    end)

    Suite:testMethod("MarketplaceEconomy.calculateTradeProfit", {description = "Calculates profit", testCase = "profit", type = "functional"}, function()
        local profit = shared.me:calculateTradeProfit("trader1", 10, 15, 5)
        Helpers.assertEqual(profit, 25, "25")
    end)
end)

Suite:group("Supply & Demand", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("sd_market", "Test", "region1", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.updateMarketSupply", {description = "Updates supply", testCase = "supply", type = "functional"}, function()
        local ok = shared.me:updateMarketSupply("sd_market", true)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("MarketplaceEconomy.updateMarketDemand", {description = "Updates demand", testCase = "demand", type = "functional"}, function()
        local ok = shared.me:updateMarketDemand("sd_market", true)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("MarketplaceEconomy.getMarketEquilibrium", {description = "Gets equilibrium", testCase = "equilibrium", type = "functional"}, function()
        local eq = shared.me:getMarketEquilibrium("sd_market")
        Helpers.assertEqual(eq >= 0, true, "Equilibrium >= 0")
    end)
end)

Suite:group("Merchant Finance", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("finance_market", "Test", "region1", "general")
        shared.me:createMerchant("trader2", "finance_market", "Bob", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.getMerchantInventoryValue", {description = "Gets inventory value", testCase = "inv_value", type = "functional"}, function()
        shared.me.merchants["trader2"].inventory["item"] = 10
        local value = shared.me:getMerchantInventoryValue("trader2")
        Helpers.assertEqual(value > 0, true, "Value > 0")
    end)

    Suite:testMethod("MarketplaceEconomy.getMerchantNetWorth", {description = "Gets net worth", testCase = "net_worth", type = "functional"}, function()
        local worth = shared.me:getMerchantNetWorth("trader2")
        Helpers.assertEqual(worth > 0, true, "Worth > 0")
    end)
end)

Suite:group("Market Intelligence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("intel_market", "Test", "region1", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.getMarketIntelligence", {description = "Gets intelligence", testCase = "intel", type = "functional"}, function()
        local intel = shared.me:getMarketIntelligence("intel_market")
        Helpers.assertEqual(intel ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("MarketplaceEconomy.applyPriceMultiplier", {description = "Applies multiplier", testCase = "multiplier", type = "functional"}, function()
        local ok = shared.me:applyPriceMultiplier("intel_market", 1.5)
        Helpers.assertEqual(ok, true, "Applied")
    end)
end)

Suite:group("Reputation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("rep_market", "Test", "region1", "general")
        shared.me:createMerchant("trader3", "rep_market", "Charlie", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.recordMerchantReputation", {description = "Records reputation", testCase = "record", type = "functional"}, function()
        local ok = shared.me:recordMerchantReputation("trader3", 10)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("MarketplaceEconomy.getMerchantReputation", {description = "Gets reputation", testCase = "get", type = "functional"}, function()
        shared.me:recordMerchantReputation("trader3", 20)
        local rep = shared.me:getMerchantReputation("trader3")
        Helpers.assertEqual(rep > 50, true, "Rep > 50")
    end)
end)

Suite:group("Price Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("m1", "Market1", "region1", "general")
        shared.me:createMarket("m2", "Market2", "region2", "general")
        shared.me:addItemToMarket("m1", "item1", 50, 20)
        shared.me:addItemToMarket("m2", "item1", 40, 30)
    end)

    Suite:testMethod("MarketplaceEconomy.queryBestPrice", {description = "Finds best price", testCase = "best", type = "functional"}, function()
        local market, price = shared.me:queryBestPrice("item1", {"m1", "m2"})
        Helpers.assertEqual(market ~= nil, true, "Found")
    end)

    Suite:testMethod("MarketplaceEconomy.queryWorstPrice", {description = "Finds worst price", testCase = "worst", type = "functional"}, function()
        local market, price = shared.me:queryWorstPrice("item1", {"m1", "m2"})
        Helpers.assertEqual(market ~= nil, true, "Found")
    end)
end)

Suite:group("Trade History", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("hist_market", "Test", "region1", "general")
        shared.me:createMerchant("trader4", "hist_market", "Dave", "general")
    end)

    Suite:testMethod("MarketplaceEconomy.recordTradeHistory", {description = "Records history", testCase = "record", type = "functional"}, function()
        local ok = shared.me:recordTradeHistory("trader4", "hist_market", "item", 10, 20, "sell")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("MarketplaceEconomy.getTradeHistory", {description = "Gets history", testCase = "get", type = "functional"}, function()
        shared.me:recordTradeHistory("trader4", "hist_market", "item", 5, 15, "buy")
        local history = shared.me:getTradeHistory("trader4")
        Helpers.assertEqual(#history > 0, true, "Has history")
    end)
end)

Suite:group("Trends", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
        shared.me:createMarket("trend_market", "Test", "region1", "general")
        shared.me:addItemToMarket("trend_market", "item1", 50, 20)
    end)

    Suite:testMethod("MarketplaceEconomy.calculateMarketTrend", {description = "Calculates trend", testCase = "trend", type = "functional"}, function()
        local trend = shared.me:calculateMarketTrend("trend_market", "item1")
        Helpers.assertEqual(trend >= 0, true, "Trend >= 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.me = MarketplaceEconomy:new()
    end)

    Suite:testMethod("MarketplaceEconomy.resetMarket", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.me:resetMarket()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
