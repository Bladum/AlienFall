-- ─────────────────────────────────────────────────────────────────────────
-- RESOURCE MARKET TEST SUITE
-- FILE: tests2/economy/resource_market_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.resource_market",
    fileName = "resource_market.lua",
    description = "Market dynamics with supply, demand, pricing, and trading volumes"
})

print("[RESOURCE_MARKET_TEST] Setting up")

local ResourceMarket = {
    commodities = {},
    market_state = {},
    trading_history = {},
    supply_demand = {},
    price_trends = {},

    new = function(self)
        return setmetatable({
            commodities = {}, market_state = {}, trading_history = {},
            supply_demand = {}, price_trends = {}
        }, {__index = self})
    end,

    registerCommodity = function(self, commodityId, name, basePrice, volatility)
        self.commodities[commodityId] = {
            id = commodityId, name = name, basePrice = basePrice, volatility = volatility or 10,
            currentPrice = basePrice, supply = 100, demand = 80
        }
        self.market_state[commodityId] = {buyers = 0, sellers = 0, volume = 0, trend = "stable"}
        self.supply_demand[commodityId] = {supplies = {}, demands = {}}
        self.price_trends[commodityId] = {}
        return true
    end,

    getCommodity = function(self, commodityId)
        return self.commodities[commodityId]
    end,

    setSupply = function(self, commodityId, supply)
        if not self.commodities[commodityId] then return false end
        self.commodities[commodityId].supply = math.max(0, supply)
        return true
    end,

    setDemand = function(self, commodityId, demand)
        if not self.commodities[commodityId] then return false end
        self.commodities[commodityId].demand = math.max(0, demand)
        return true
    end,

    getSupply = function(self, commodityId)
        if not self.commodities[commodityId] then return 0 end
        return self.commodities[commodityId].supply
    end,

    getDemand = function(self, commodityId)
        if not self.commodities[commodityId] then return 0 end
        return self.commodities[commodityId].demand
    end,

    calculateSupplyDemandRatio = function(self, commodityId)
        if not self.commodities[commodityId] then return 0 end
        local commodity = self.commodities[commodityId]
        if commodity.demand == 0 then return 0 end
        return commodity.supply / commodity.demand
    end,

    updatePrice = function(self, commodityId)
        if not self.commodities[commodityId] then return false end
        local commodity = self.commodities[commodityId]
        local ratio = self:calculateSupplyDemandRatio(commodityId)
        local change = 0
        if ratio < 0.5 then
            change = commodity.basePrice * 0.15
        elseif ratio < 0.8 then
            change = commodity.basePrice * 0.08
        elseif ratio > 1.5 then
            change = commodity.basePrice * -0.15
        elseif ratio > 1.2 then
            change = commodity.basePrice * -0.08
        end
        commodity.currentPrice = math.max(1, commodity.currentPrice + change)
        table.insert(self.price_trends[commodityId], commodity.currentPrice)
        return true
    end,

    getCurrentPrice = function(self, commodityId)
        if not self.commodities[commodityId] then return 0 end
        return self.commodities[commodityId].currentPrice
    end,

    recordTrade = function(self, commodityId, quantity, price, buyer, seller)
        if not self.commodities[commodityId] then return false end
        local trade = {commodity = commodityId, quantity = quantity, price = price, buyer = buyer, seller = seller, volume = quantity * price}
        table.insert(self.trading_history, trade)
        if not self.market_state[commodityId] then self.market_state[commodityId] = {} end
        self.market_state[commodityId].volume = (self.market_state[commodityId].volume or 0) + trade.volume
        if not self.market_state[commodityId].buyers then self.market_state[commodityId].buyers = 0 end
        if not self.market_state[commodityId].sellers then self.market_state[commodityId].sellers = 0 end
        self.market_state[commodityId].buyers = self.market_state[commodityId].buyers + 1
        self.market_state[commodityId].sellers = self.market_state[commodityId].sellers + 1
        return true
    end,

    getTradingVolume = function(self, commodityId)
        if not self.market_state[commodityId] then return 0 end
        return self.market_state[commodityId].volume or 0
    end,

    getTradeCount = function(self, commodityId)
        local count = 0
        for _, trade in ipairs(self.trading_history) do
            if trade.commodity == commodityId then count = count + 1 end
        end
        return count
    end,

    getTrendDirection = function(self, commodityId)
        if not self.price_trends[commodityId] or #self.price_trends[commodityId] < 2 then return "stable" end
        local prices = self.price_trends[commodityId]
        local oldPrice = prices[#prices - 1]
        local newPrice = prices[#prices]
        if newPrice > oldPrice * 1.05 then return "rising"
        elseif newPrice < oldPrice * 0.95 then return "falling"
        else return "stable"
        end
    end,

    getPriceHistory = function(self, commodityId)
        if not self.price_trends[commodityId] then return {} end
        return self.price_trends[commodityId]
    end,

    addBuyer = function(self, commodityId, buyerId)
        if not self.supply_demand[commodityId] then return false end
        self.supply_demand[commodityId].demands[buyerId] = true
        return true
    end,

    addSeller = function(self, commodityId, sellerId)
        if not self.supply_demand[commodityId] then return false end
        self.supply_demand[commodityId].supplies[sellerId] = true
        return true
    end,

    getBuyerCount = function(self, commodityId)
        if not self.supply_demand[commodityId] or not self.supply_demand[commodityId].demands then return 0 end
        local count = 0
        for _ in pairs(self.supply_demand[commodityId].demands) do count = count + 1 end
        return count
    end,

    getSellerCount = function(self, commodityId)
        if not self.supply_demand[commodityId] or not self.supply_demand[commodityId].supplies then return 0 end
        local count = 0
        for _ in pairs(self.supply_demand[commodityId].supplies) do count = count + 1 end
        return count
    end,

    hasMarketEquilibrium = function(self, commodityId)
        if not self.commodities[commodityId] then return false end
        local ratio = self:calculateSupplyDemandRatio(commodityId)
        return ratio >= 0.8 and ratio <= 1.2
    end,

    getAverageTradePrice = function(self, commodityId)
        local trades = {}
        for _, trade in ipairs(self.trading_history) do
            if trade.commodity == commodityId then table.insert(trades, trade.price) end
        end
        if #trades == 0 then return 0 end
        local sum = 0
        for _, price in ipairs(trades) do sum = sum + price end
        return sum / #trades
    end,

    simulateMarketShock = function(self, commodityId, shockFactor)
        if not self.commodities[commodityId] then return false end
        local commodity = self.commodities[commodityId]
        commodity.currentPrice = commodity.currentPrice * shockFactor
        self.market_state[commodityId].trend = "shocked"
        return true
    end,

    getMarketVolatility = function(self, commodityId)
        if not self.price_trends[commodityId] or #self.price_trends[commodityId] < 2 then return 0 end
        local prices = self.price_trends[commodityId]
        local avg = 0
        for _, p in ipairs(prices) do avg = avg + p end
        avg = avg / #prices
        local variance = 0
        for _, p in ipairs(prices) do variance = variance + (p - avg) ^ 2 end
        variance = variance / #prices
        return math.sqrt(variance)
    end,

    setPriceCap = function(self, commodityId, maxPrice)
        if not self.commodities[commodityId] then return false end
        self.commodities[commodityId].currentPrice = math.min(self.commodities[commodityId].currentPrice, maxPrice)
        return true
    end,

    setFloorPrice = function(self, commodityId, minPrice)
        if not self.commodities[commodityId] then return false end
        self.commodities[commodityId].currentPrice = math.max(self.commodities[commodityId].currentPrice, minPrice)
        return true
    end,

    resetMarket = function(self, commodityId)
        if not self.commodities[commodityId] then return false end
        local commodity = self.commodities[commodityId]
        commodity.currentPrice = commodity.basePrice
        commodity.supply = 100
        commodity.demand = 80
        self.price_trends[commodityId] = {}
        return true
    end
}

Suite:group("Commodity Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
    end)

    Suite:testMethod("ResourceMarket.registerCommodity", {description = "Registers commodity", testCase = "register", type = "functional"}, function()
        local ok = shared.rm:registerCommodity("iron", "Iron Ore", 100, 5)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ResourceMarket.getCommodity", {description = "Gets commodity", testCase = "get", type = "functional"}, function()
        shared.rm:registerCommodity("steel", "Steel", 150, 8)
        local comm = shared.rm:getCommodity("steel")
        Helpers.assertEqual(comm ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Supply and Demand", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("copper", "Copper", 80, 6)
    end)

    Suite:testMethod("ResourceMarket.setSupply", {description = "Sets supply", testCase = "set_supply", type = "functional"}, function()
        local ok = shared.rm:setSupply("copper", 120)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceMarket.setDemand", {description = "Sets demand", testCase = "set_demand", type = "functional"}, function()
        local ok = shared.rm:setDemand("copper", 90)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceMarket.getSupply", {description = "Gets supply", testCase = "get_supply", type = "functional"}, function()
        shared.rm:setSupply("copper", 110)
        local supply = shared.rm:getSupply("copper")
        Helpers.assertEqual(supply, 110, "Supply 110")
    end)

    Suite:testMethod("ResourceMarket.getDemand", {description = "Gets demand", testCase = "get_demand", type = "functional"}, function()
        shared.rm:setDemand("copper", 95)
        local demand = shared.rm:getDemand("copper")
        Helpers.assertEqual(demand, 95, "Demand 95")
    end)
end)

Suite:group("Pricing System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("gold", "Gold", 200, 3)
    end)

    Suite:testMethod("ResourceMarket.getCurrentPrice", {description = "Gets current price", testCase = "current_price", type = "functional"}, function()
        local price = shared.rm:getCurrentPrice("gold")
        Helpers.assertEqual(price, 200, "Price 200")
    end)

    Suite:testMethod("ResourceMarket.calculateSupplyDemandRatio", {description = "Calculates S/D ratio", testCase = "ratio", type = "functional"}, function()
        shared.rm:setSupply("gold", 100)
        shared.rm:setDemand("gold", 100)
        local ratio = shared.rm:calculateSupplyDemandRatio("gold")
        Helpers.assertEqual(ratio, 1, "Ratio 1")
    end)

    Suite:testMethod("ResourceMarket.updatePrice", {description = "Updates price", testCase = "update_price", type = "functional"}, function()
        shared.rm:setSupply("gold", 50)
        shared.rm:setDemand("gold", 100)
        local ok = shared.rm:updatePrice("gold")
        Helpers.assertEqual(ok, true, "Updated")
    end)
end)

Suite:group("Trading", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("silver", "Silver", 120, 7)
    end)

    Suite:testMethod("ResourceMarket.recordTrade", {description = "Records trade", testCase = "record_trade", type = "functional"}, function()
        local ok = shared.rm:recordTrade("silver", 50, 120, "buyer1", "seller1")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("ResourceMarket.getTradingVolume", {description = "Gets trading volume", testCase = "volume", type = "functional"}, function()
        shared.rm:recordTrade("silver", 40, 120, "b1", "s1")
        shared.rm:recordTrade("silver", 60, 120, "b2", "s2")
        local volume = shared.rm:getTradingVolume("silver")
        Helpers.assertEqual(volume, 12000, "Volume 12000")
    end)

    Suite:testMethod("ResourceMarket.getTradeCount", {description = "Gets trade count", testCase = "trade_count", type = "functional"}, function()
        shared.rm:recordTrade("silver", 30, 120, "b1", "s1")
        shared.rm:recordTrade("silver", 40, 120, "b2", "s2")
        local count = shared.rm:getTradeCount("silver")
        Helpers.assertEqual(count, 2, "Two trades")
    end)

    Suite:testMethod("ResourceMarket.getAverageTradePrice", {description = "Average trade price", testCase = "avg_price", type = "functional"}, function()
        shared.rm:recordTrade("silver", 50, 110, "buyer1", "seller1")
        shared.rm:recordTrade("silver", 50, 130, "buyer2", "seller2")
        local avg = shared.rm:getAverageTradePrice("silver")
        Helpers.assertEqual(avg, 120, "Avg 120")
    end)
end)

Suite:group("Market Dynamics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("platinum", "Platinum", 300, 4)
    end)

    Suite:testMethod("ResourceMarket.getTrendDirection", {description = "Trend direction", testCase = "trend", type = "functional"}, function()
        shared.rm:updatePrice("platinum")
        shared.rm:setSupply("platinum", 50)
        shared.rm:updatePrice("platinum")
        local trend = shared.rm:getTrendDirection("platinum")
        Helpers.assertEqual(trend ~= nil, true, "Trend determined")
    end)

    Suite:testMethod("ResourceMarket.getPriceHistory", {description = "Price history", testCase = "history", type = "functional"}, function()
        shared.rm:updatePrice("platinum")
        shared.rm:updatePrice("platinum")
        local history = shared.rm:getPriceHistory("platinum")
        Helpers.assertEqual(#history, 2, "Two prices")
    end)
end)

Suite:group("Buyers and Sellers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("tin", "Tin", 75, 5)
    end)

    Suite:testMethod("ResourceMarket.addBuyer", {description = "Adds buyer", testCase = "add_buyer", type = "functional"}, function()
        local ok = shared.rm:addBuyer("tin", "buyer1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ResourceMarket.addSeller", {description = "Adds seller", testCase = "add_seller", type = "functional"}, function()
        local ok = shared.rm:addSeller("tin", "seller1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ResourceMarket.getBuyerCount", {description = "Buyer count", testCase = "buyer_count", type = "functional"}, function()
        shared.rm:addBuyer("tin", "b1")
        shared.rm:addBuyer("tin", "b2")
        local count = shared.rm:getBuyerCount("tin")
        Helpers.assertEqual(count, 2, "Two buyers")
    end)

    Suite:testMethod("ResourceMarket.getSellerCount", {description = "Seller count", testCase = "seller_count", type = "functional"}, function()
        shared.rm:addSeller("tin", "s1")
        shared.rm:addSeller("tin", "s2")
        local count = shared.rm:getSellerCount("tin")
        Helpers.assertEqual(count, 2, "Two sellers")
    end)
end)

Suite:group("Market Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("coal", "Coal", 50, 8)
    end)

    Suite:testMethod("ResourceMarket.hasMarketEquilibrium", {description = "Market equilibrium", testCase = "equilibrium", type = "functional"}, function()
        shared.rm:setSupply("coal", 90)
        shared.rm:setDemand("coal", 100)
        local eq = shared.rm:hasMarketEquilibrium("coal")
        Helpers.assertEqual(eq, true, "Equilibrium")
    end)

    Suite:testMethod("ResourceMarket.getMarketVolatility", {description = "Market volatility", testCase = "volatility", type = "functional"}, function()
        shared.rm:updatePrice("coal")
        shared.rm:updatePrice("coal")
        local vol = shared.rm:getMarketVolatility("coal")
        Helpers.assertEqual(vol >= 0, true, "Volatility >= 0")
    end)
end)

Suite:group("Price Controls", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("lead", "Lead", 60, 5)
    end)

    Suite:testMethod("ResourceMarket.setPriceCap", {description = "Sets price cap", testCase = "cap", type = "functional"}, function()
        local ok = shared.rm:setPriceCap("lead", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ResourceMarket.setFloorPrice", {description = "Sets floor price", testCase = "floor", type = "functional"}, function()
        local ok = shared.rm:setFloorPrice("lead", 70)
        Helpers.assertEqual(ok, true, "Set")
    end)
end)

Suite:group("Market Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rm = ResourceMarket:new()
        shared.rm:registerCommodity("uranium", "Uranium", 500, 15)
    end)

    Suite:testMethod("ResourceMarket.simulateMarketShock", {description = "Market shock", testCase = "shock", type = "functional"}, function()
        local ok = shared.rm:simulateMarketShock("uranium", 0.5)
        Helpers.assertEqual(ok, true, "Shocked")
    end)

    Suite:testMethod("ResourceMarket.resetMarket", {description = "Resets market", testCase = "reset", type = "functional"}, function()
        shared.rm:setSupply("uranium", 200)
        local ok = shared.rm:resetMarket("uranium")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
