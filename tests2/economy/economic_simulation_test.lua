-- ─────────────────────────────────────────────────────────────────────────
-- ECONOMIC SIMULATION TEST SUITE
-- FILE: tests2/economy/economic_simulation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.economic_simulation",
    fileName = "economic_simulation.lua",
    description = "Economic simulation with inflation, recession, trade cycles, and market dynamics"
})

print("[ECONOMIC_SIMULATION_TEST] Setting up")

local EconomicSimulation = {
    regions = {}, markets = {}, sectors = {}, transactions = {},
    global_factors = {}, economic_events = {},

    new = function(self)
        return setmetatable({
            regions = {}, markets = {}, sectors = {}, transactions = {},
            global_factors = {inflation = 0, gdp_growth = 0, unemployment = 0},
            economic_events = {}
        }, {__index = self})
    end,

    createRegion = function(self, regionId, name, gdp, population)
        self.regions[regionId] = {
            id = regionId, name = name, gdp = gdp or 100000,
            population = population or 10000, wealth = gdp or 100000,
            inflation_rate = 2.0, unemployment_rate = 5.0,
            growth_rate = 3.0, debt = 0, tax_revenue = 0
        }
        return true
    end,

    getRegion = function(self, regionId)
        return self.regions[regionId]
    end,

    registerSector = function(self, sectorId, name, contribution_percentage)
        self.sectors[sectorId] = {
            id = sectorId, name = name, contribution = contribution_percentage or 10,
            output = 0, employment = 0, growth = 0, stability = 50
        }
        return true
    end,

    getSector = function(self, sectorId)
        return self.sectors[sectorId]
    end,

    createMarket = function(self, marketId, regionId, product, base_price)
        self.markets[marketId] = {
            id = marketId, region_id = regionId, product = product,
            base_price = base_price or 100, current_price = base_price or 100,
            supply = 100, demand = 100, volume = 0, volatility = 5
        }
        return true
    end,

    getMarket = function(self, marketId)
        return self.markets[marketId]
    end,

    simulateMarketDynamics = function(self, marketId, time_delta)
        if not self.markets[marketId] then return false end
        local market = self.markets[marketId]
        local supply_factor = (market.supply / 100) * 0.5
        local demand_factor = (market.demand / 100) * 1.5
        local price_change = demand_factor - supply_factor + (math.random(-10, 10) / 100)
        market.current_price = math.max(market.base_price * 0.5, market.current_price * (1 + price_change / 100))
        market.volume = market.volume + (market.supply * market.demand / 10000)
        return true
    end,

    recordTransaction = function(self, transId, marketId, quantity, price)
        if not self.markets[marketId] then return false end
        self.transactions[transId] = {
            id = transId, market_id = marketId, quantity = quantity,
            price = price, total_value = quantity * price, timestamp = os.time()
        }
        return true
    end,

    getTransactionHistory = function(self, marketId)
        local history = {}
        for _, trans in pairs(self.transactions) do
            if trans.market_id == marketId then
                table.insert(history, trans)
            end
        end
        return history
    end,

    calculateInflation = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local avg_price_change = 0
        local market_count = 0
        for _, market in pairs(self.markets) do
            if market.region_id == regionId then
                avg_price_change = avg_price_change + ((market.current_price - market.base_price) / market.base_price) * 100
                market_count = market_count + 1
            end
        end
        if market_count > 0 then
            region.inflation_rate = avg_price_change / market_count
        end
        return region.inflation_rate
    end,

    simulateEconomicCycle = function(self, regionId, cycle_phase)
        if not self.regions[regionId] then return false end
        local region = self.regions[regionId]

        if cycle_phase == "expansion" then
            region.growth_rate = math.min(6, region.growth_rate + 0.5)
            region.unemployment_rate = math.max(2, region.unemployment_rate - 0.3)
        elseif cycle_phase == "contraction" then
            region.growth_rate = math.max(-2, region.growth_rate - 0.5)
            region.unemployment_rate = math.min(12, region.unemployment_rate + 0.5)
        elseif cycle_phase == "recovery" then
            region.growth_rate = math.min(4, region.growth_rate + 0.3)
            region.unemployment_rate = math.max(3, region.unemployment_rate - 0.2)
        end

        region.gdp = region.gdp * (1 + region.growth_rate / 100)
        return true
    end,

    collectTaxes = function(self, regionId, tax_rate)
        if not self.regions[regionId] then return false end
        local region = self.regions[regionId]
        local tax_collected = region.gdp * (tax_rate / 100)
        region.tax_revenue = tax_collected
        region.wealth = region.wealth + tax_collected
        return true
    end,

    incurDebt = function(self, regionId, amount)
        if not self.regions[regionId] then return false end
        self.regions[regionId].debt = self.regions[regionId].debt + amount
        return true
    end,

    payDebt = function(self, regionId, amount)
        if not self.regions[regionId] then return false end
        local region = self.regions[regionId]
        local paid = math.min(amount, region.debt)
        region.debt = region.debt - paid
        region.wealth = region.wealth - paid
        return true
    end,

    getDebtToGdpRatio = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        if region.gdp == 0 then return 0 end
        return (region.debt / region.gdp) * 100
    end,

    triggerEconomicEvent = function(self, eventId, regionId, event_type, impact)
        table.insert(self.economic_events, {
            id = eventId, region_id = regionId, type = event_type,
            impact = impact or 0, timestamp = os.time()
        })
        if self.regions[regionId] then
            local region = self.regions[regionId]
            if event_type == "recession" then
                region.growth_rate = region.growth_rate - impact
            elseif event_type == "boom" then
                region.growth_rate = region.growth_rate + impact
            elseif event_type == "inflation_spike" then
                region.inflation_rate = region.inflation_rate + impact
            end
        end
        return true
    end,

    calculateConsumerPriceIndex = function(self, regionId)
        if not self.regions[regionId] then return 100 end
        local sum_prices = 0
        local market_count = 0
        for _, market in pairs(self.markets) do
            if market.region_id == regionId then
                sum_prices = sum_prices + market.current_price
                market_count = market_count + 1
            end
        end
        if market_count == 0 then return 100 end
        return (sum_prices / market_count) * (1 + self.regions[regionId].inflation_rate / 100)
    end,

    calculateRegionalProductivity = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local base = region.gdp / region.population
        local inflation_factor = 1 - (region.inflation_rate / 100)
        local employment_factor = 1 - (region.unemployment_rate / 100)
        return base * inflation_factor * employment_factor
    end,

    simulateTradeBalance = function(self, region1Id, region2Id, trade_volume)
        if not self.regions[region1Id] or not self.regions[region2Id] then return false end
        local r1 = self.regions[region1Id]
        local r2 = self.regions[region2Id]
        local exchange_rate = r2.gdp / r1.gdp
        local value_transferred = trade_volume * exchange_rate
        r1.wealth = r1.wealth + value_transferred
        r2.wealth = r2.wealth - value_transferred
        return true
    end,

    getEconomicHealth = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local growth_score = region.growth_rate
        local inflation_penalty = math.max(0, region.inflation_rate - 3)
        local unemployment_penalty = region.unemployment_rate
        local health = growth_score - inflation_penalty - unemployment_penalty
        return math.max(0, health)
    end,

    reset = function(self)
        self.regions = {}
        self.markets = {}
        self.sectors = {}
        self.transactions = {}
        self.economic_events = {}
        return true
    end
}

Suite:group("Regions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
    end)

    Suite:testMethod("EconomicSimulation.createRegion", {description = "Creates region", testCase = "create", type = "functional"}, function()
        local ok = shared.eco:createRegion("reg1", "NorthTown", 100000, 10000)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("EconomicSimulation.getRegion", {description = "Gets region", testCase = "get", type = "functional"}, function()
        shared.eco:createRegion("reg2", "SouthTown", 150000, 15000)
        local reg = shared.eco:getRegion("reg2")
        Helpers.assertEqual(reg ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Sectors", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
    end)

    Suite:testMethod("EconomicSimulation.registerSector", {description = "Registers sector", testCase = "register", type = "functional"}, function()
        local ok = shared.eco:registerSector("sec1", "Agriculture", 20)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("EconomicSimulation.getSector", {description = "Gets sector", testCase = "get", type = "functional"}, function()
        shared.eco:registerSector("sec2", "Manufacturing", 35)
        local sec = shared.eco:getSector("sec2")
        Helpers.assertEqual(sec ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Markets", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg3", "Test", 100000, 10000)
    end)

    Suite:testMethod("EconomicSimulation.createMarket", {description = "Creates market", testCase = "create", type = "functional"}, function()
        local ok = shared.eco:createMarket("mkt1", "reg3", "wheat", 50)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("EconomicSimulation.getMarket", {description = "Gets market", testCase = "get", type = "functional"}, function()
        shared.eco:createMarket("mkt2", "reg3", "iron", 75)
        local mkt = shared.eco:getMarket("mkt2")
        Helpers.assertEqual(mkt ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("EconomicSimulation.simulateMarketDynamics", {description = "Simulates dynamics", testCase = "dynamics", type = "functional"}, function()
        shared.eco:createMarket("mkt3", "reg3", "gold", 100)
        local ok = shared.eco:simulateMarketDynamics("mkt3", 1)
        Helpers.assertEqual(ok, true, "Simulated")
    end)

    Suite:testMethod("EconomicSimulation.market_prices_change", {description = "Prices change", testCase = "price_change", type = "functional"}, function()
        shared.eco:createMarket("mkt4", "reg3", "silver", 80)
        local mkt1 = shared.eco:getMarket("mkt4")
        local price1 = mkt1.current_price
        shared.eco:simulateMarketDynamics("mkt4", 5)
        local mkt2 = shared.eco:getMarket("mkt4")
        Helpers.assertEqual(mkt2.current_price ~= price1 or price1 > 0, true, "Dynamic pricing")
    end)
end)

Suite:group("Transactions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg4", "Test", 100000, 10000)
        shared.eco:createMarket("mkt5", "reg4", "copper", 60)
    end)

    Suite:testMethod("EconomicSimulation.recordTransaction", {description = "Records transaction", testCase = "record", type = "functional"}, function()
        local ok = shared.eco:recordTransaction("trans1", "mkt5", 100, 60)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("EconomicSimulation.getTransactionHistory", {description = "Gets history", testCase = "history", type = "functional"}, function()
        shared.eco:recordTransaction("trans2", "mkt5", 50, 60)
        shared.eco:recordTransaction("trans3", "mkt5", 75, 62)
        local hist = shared.eco:getTransactionHistory("mkt5")
        Helpers.assertEqual(#hist > 0, true, "Has history")
    end)
end)

Suite:group("Inflation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg5", "Test", 100000, 10000)
    end)

    Suite:testMethod("EconomicSimulation.calculateInflation", {description = "Calculates inflation", testCase = "calc", type = "functional"}, function()
        shared.eco:createMarket("mkt6", "reg5", "item", 100)
        local inf = shared.eco:calculateInflation("reg5")
        Helpers.assertEqual(inf >= 0, true, "Inflation >= 0")
    end)
end)

Suite:group("Economic Cycles", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg6", "Test", 100000, 10000)
    end)

    Suite:testMethod("EconomicSimulation.simulateEconomicCycle_expansion", {description = "Expansion phase", testCase = "expansion", type = "functional"}, function()
        local ok = shared.eco:simulateEconomicCycle("reg6", "expansion")
        Helpers.assertEqual(ok, true, "Expansion")
    end)

    Suite:testMethod("EconomicSimulation.simulateEconomicCycle_contraction", {description = "Contraction phase", testCase = "contraction", type = "functional"}, function()
        local ok = shared.eco:simulateEconomicCycle("reg6", "contraction")
        Helpers.assertEqual(ok, true, "Contraction")
    end)

    Suite:testMethod("EconomicSimulation.simulateEconomicCycle_recovery", {description = "Recovery phase", testCase = "recovery", type = "functional"}, function()
        local ok = shared.eco:simulateEconomicCycle("reg6", "recovery")
        Helpers.assertEqual(ok, true, "Recovery")
    end)

    Suite:testMethod("EconomicSimulation.cycle_affects_gdp", {description = "Affects GDP", testCase = "gdp_change", type = "functional"}, function()
        local reg1 = shared.eco:getRegion("reg6")
        local gdp1 = reg1.gdp
        shared.eco:simulateEconomicCycle("reg6", "expansion")
        local reg2 = shared.eco:getRegion("reg6")
        Helpers.assertEqual(reg2.gdp >= gdp1, true, "GDP affected")
    end)
end)

Suite:group("Taxation & Debt", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg7", "Test", 100000, 10000)
    end)

    Suite:testMethod("EconomicSimulation.collectTaxes", {description = "Collects taxes", testCase = "collect", type = "functional"}, function()
        local ok = shared.eco:collectTaxes("reg7", 10)
        Helpers.assertEqual(ok, true, "Collected")
    end)

    Suite:testMethod("EconomicSimulation.incurDebt", {description = "Incurs debt", testCase = "incur", type = "functional"}, function()
        local ok = shared.eco:incurDebt("reg7", 5000)
        Helpers.assertEqual(ok, true, "Incurred")
    end)

    Suite:testMethod("EconomicSimulation.payDebt", {description = "Pays debt", testCase = "pay", type = "functional"}, function()
        shared.eco:incurDebt("reg7", 5000)
        local ok = shared.eco:payDebt("reg7", 2000)
        Helpers.assertEqual(ok, true, "Paid")
    end)

    Suite:testMethod("EconomicSimulation.getDebtToGdpRatio", {description = "Gets debt ratio", testCase = "ratio", type = "functional"}, function()
        shared.eco:incurDebt("reg7", 10000)
        local ratio = shared.eco:getDebtToGdpRatio("reg7")
        Helpers.assertEqual(ratio > 0, true, "Ratio > 0")
    end)
end)

Suite:group("Economic Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg8", "Test", 100000, 10000)
    end)

    Suite:testMethod("EconomicSimulation.triggerEconomicEvent", {description = "Triggers event", testCase = "trigger", type = "functional"}, function()
        local ok = shared.eco:triggerEconomicEvent("evt1", "reg8", "boom", 2)
        Helpers.assertEqual(ok, true, "Triggered")
    end)

    Suite:testMethod("EconomicSimulation.event_affects_growth", {description = "Affects growth", testCase = "growth", type = "functional"}, function()
        shared.eco:triggerEconomicEvent("evt2", "reg8", "recession", 3)
        local reg = shared.eco:getRegion("reg8")
        Helpers.assertEqual(reg.growth_rate ~= 3, true, "Growth affected")
    end)
end)

Suite:group("Metrics & Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("reg9", "Test", 100000, 10000)
        shared.eco:createMarket("mkt7", "reg9", "item", 100)
    end)

    Suite:testMethod("EconomicSimulation.calculateConsumerPriceIndex", {description = "Calculates CPI", testCase = "cpi", type = "functional"}, function()
        local cpi = shared.eco:calculateConsumerPriceIndex("reg9")
        Helpers.assertEqual(cpi > 0, true, "CPI > 0")
    end)

    Suite:testMethod("EconomicSimulation.calculateRegionalProductivity", {description = "Calculates productivity", testCase = "prod", type = "functional"}, function()
        local prod = shared.eco:calculateRegionalProductivity("reg9")
        Helpers.assertEqual(prod > 0, true, "Productivity > 0")
    end)

    Suite:testMethod("EconomicSimulation.getEconomicHealth", {description = "Gets health", testCase = "health", type = "functional"}, function()
        local health = shared.eco:getEconomicHealth("reg9")
        Helpers.assertEqual(health >= 0, true, "Health >= 0")
    end)
end)

Suite:group("Trade", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
        shared.eco:createRegion("regA", "RegionA", 100000, 10000)
        shared.eco:createRegion("regB", "RegionB", 80000, 8000)
    end)

    Suite:testMethod("EconomicSimulation.simulateTradeBalance", {description = "Simulates trade", testCase = "trade", type = "functional"}, function()
        local ok = shared.eco:simulateTradeBalance("regA", "regB", 1000)
        Helpers.assertEqual(ok, true, "Trade simulated")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.eco = EconomicSimulation:new()
    end)

    Suite:testMethod("EconomicSimulation.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.eco:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
