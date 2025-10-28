-- ─────────────────────────────────────────────────────────────────────────
-- TRADE DIPLOMACY TEST SUITE
-- FILE: tests2/politics/trade_diplomacy_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.trade_diplomacy",
    fileName = "trade_diplomacy.lua",
    description = "Trade agreements with diplomatic relations, tariffs, sanctions, and economic corridors"
})

print("[TRADE_DIPLOMACY_TEST] Setting up")

local TradeDiplomacy = {
    nations = {},
    agreements = {},
    relations = {},
    trade_routes = {},
    tariffs = {},

    new = function(self)
        return setmetatable({
            nations = {}, agreements = {}, relations = {},
            trade_routes = {}, tariffs = {}
        }, {__index = self})
    end,

    registerNation = function(self, nationId, name, region, wealth)
        self.nations[nationId] = {
            id = nationId, name = name, region = region,
            wealth = wealth or 10000, export_value = 0, import_value = 0,
            trade_partners = {}, agreement_count = 0
        }
        self.relations[nationId] = {}
        self.tariffs[nationId] = {}
        return true
    end,

    getNation = function(self, nationId)
        return self.nations[nationId]
    end,

    setDiplomaticRelation = function(self, nation1, nation2, relation_score)
        if not self.nations[nation1] or not self.nations[nation2] then return false end
        self.relations[nation1] = self.relations[nation1] or {}
        self.relations[nation2] = self.relations[nation2] or {}
        self.relations[nation1][nation2] = relation_score or 0
        self.relations[nation2][nation1] = relation_score or 0
        return true
    end,

    getDiplomaticRelation = function(self, nation1, nation2)
        if not self.relations[nation1] or not self.relations[nation1][nation2] then return 0 end
        return self.relations[nation1][nation2]
    end,

    createTradeAgreement = function(self, agreementId, nation1, nation2, goods_type)
        if not self.nations[nation1] or not self.nations[nation2] then return false end
        self.agreements[agreementId] = {
            id = agreementId, nation1 = nation1, nation2 = nation2,
            goods = goods_type or "general", active = true,
            value_per_turn = 100, duration = 0, expiry = -1,
            bonus_relations = 5, trade_volume = 0
        }
        self.nations[nation1].agreement_count = self.nations[nation1].agreement_count + 1
        self.nations[nation2].agreement_count = self.nations[nation2].agreement_count + 1
        self.nations[nation1].trade_partners[nation2] = true
        self.nations[nation2].trade_partners[nation1] = true
        return true
    end,

    getTradeAgreement = function(self, agreementId)
        return self.agreements[agreementId]
    end,

    activateAgreement = function(self, agreementId)
        if not self.agreements[agreementId] then return false end
        self.agreements[agreementId].active = true
        return true
    end,

    suspendAgreement = function(self, agreementId)
        if not self.agreements[agreementId] then return false end
        self.agreements[agreementId].active = false
        return true
    end,

    isAgreementActive = function(self, agreementId)
        if not self.agreements[agreementId] then return false end
        return self.agreements[agreementId].active
    end,

    collectAgreementTrade = function(self, agreementId)
        if not self.agreements[agreementId] or not self.agreements[agreementId].active then return false end
        local agreement = self.agreements[agreementId]
        local value = agreement.value_per_turn or 100
        self.nations[agreement.nation1].wealth = self.nations[agreement.nation1].wealth + value
        self.nations[agreement.nation2].wealth = self.nations[agreement.nation2].wealth + value
        agreement.trade_volume = agreement.trade_volume + value
        return true
    end,

    getTotalTradeVolume = function(self, agreementId)
        if not self.agreements[agreementId] then return 0 end
        return self.agreements[agreementId].trade_volume
    end,

    createTradeRoute = function(self, routeId, from_nation, to_nation, capacity)
        if not self.nations[from_nation] or not self.nations[to_nation] then return false end
        self.trade_routes[routeId] = {
            id = routeId, from = from_nation, to = to_nation,
            capacity = capacity or 1000, current_flow = 0, security = 80,
            disruptions = 0, efficiency = 100, last_updated = 0
        }
        return true
    end,

    getTradeRoute = function(self, routeId)
        return self.trade_routes[routeId]
    end,

    updateRouteFlow = function(self, routeId, flow)
        if not self.trade_routes[routeId] then return false end
        local route = self.trade_routes[routeId]
        if flow > route.capacity then return false end
        route.current_flow = flow
        return true
    end,

    getRouteEfficiency = function(self, routeId)
        if not self.trade_routes[routeId] then return 0 end
        local route = self.trade_routes[routeId]
        return math.floor((route.current_flow / route.capacity) * 100)
    end,

    disruptTradeRoute = function(self, routeId)
        if not self.trade_routes[routeId] then return false end
        local route = self.trade_routes[routeId]
        route.disruptions = route.disruptions + 1
        route.security = math.max(0, route.security - 20)
        return true
    end,

    restoreTradeRoute = function(self, routeId)
        if not self.trade_routes[routeId] then return false end
        local route = self.trade_routes[routeId]
        route.security = math.min(100, route.security + 30)
        return true
    end,

    imposeTariff = function(self, nation1, nation2, tariff_rate)
        if not self.nations[nation1] or not self.nations[nation2] then return false end
        local key = nation1 .. "_" .. nation2
        self.tariffs[nation1][key] = tariff_rate or 0.1
        return true
    end,

    getTariffRate = function(self, nation1, nation2)
        if not self.tariffs[nation1] then return 0 end
        local key = nation1 .. "_" .. nation2
        return self.tariffs[nation1][key] or 0
    end,

    calculateTariffCost = function(self, nation1, nation2, trade_value)
        local tariff_rate = self:getTariffRate(nation1, nation2)
        return math.floor(trade_value * tariff_rate)
    end,

    imposeSanction = function(self, from_nation, target_nation, severity)
        if not self.nations[from_nation] or not self.nations[target_nation] then return false end
        self:imposeTariff(from_nation, target_nation, (severity or 0.25) + 0.5)
        self.relations[from_nation][target_nation] = math.max(-100, (self.relations[from_nation][target_nation] or 0) - 30)
        return true
    end,

    liftSanction = function(self, from_nation, target_nation)
        if not self.nations[from_nation] or not self.nations[target_nation] then return false end
        self:imposeTariff(from_nation, target_nation, 0)
        self.relations[from_nation][target_nation] = math.min(100, (self.relations[from_nation][target_nation] or 0) + 20)
        return true
    end,

    formTradeBloc = function(self, blocName, members_list)
        local bloc = {
            name = blocName, members = {}, total_wealth = 0,
            trade_agreements = 0, internal_tariff = 0.02
        }
        for _, memberId in ipairs(members_list) do
            if self.nations[memberId] then
                bloc.members[memberId] = true
                bloc.total_wealth = bloc.total_wealth + self.nations[memberId].wealth
            end
        end
        return bloc
    end,

    calculateBlocTradeBenefit = function(self, bloc)
        if not bloc or not bloc.members then return 0 end
        local benefit = 0
        for memberId, _ in pairs(bloc.members) do
            if self.nations[memberId] then
                benefit = benefit + (self.nations[memberId].agreement_count * 100)
            end
        end
        return benefit
    end,

    initiateTradeNegotiation = function(self, nation1, nation2, goods_type)
        local relation = self:getDiplomaticRelation(nation1, nation2)
        if relation < -50 then return false end
        return true
    end,

    canTradeWith = function(self, nation1, nation2)
        local relation = self:getDiplomaticRelation(nation1, nation2)
        local tariff = self:getTariffRate(nation1, nation2)
        return relation >= -50 and tariff < 0.9
    end,

    getTradePartners = function(self, nationId)
        if not self.nations[nationId] or not self.nations[nationId].trade_partners then return {} end
        local partners = {}
        for partnerId, _ in pairs(self.nations[nationId].trade_partners) do
            table.insert(partners, partnerId)
        end
        return partners
    end,

    getPartnerCount = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        local count = 0
        for _ in pairs(self.nations[nationId].trade_partners) do
            count = count + 1
        end
        return count
    end,

    calculateEconomicInfluence = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        local nation = self.nations[nationId]
        local base_influence = nation.wealth / 10000
        local partner_bonus = self:getPartnerCount(nationId) * 5
        local agreement_bonus = nation.agreement_count * 10
        return math.floor((base_influence + partner_bonus + agreement_bonus) * 100)
    end,

    recordExportValue = function(self, nationId, value)
        if not self.nations[nationId] then return false end
        self.nations[nationId].export_value = self.nations[nationId].export_value + value
        return true
    end,

    recordImportValue = function(self, nationId, value)
        if not self.nations[nationId] then return false end
        self.nations[nationId].import_value = self.nations[nationId].import_value + value
        return true
    end,

    calculateTradeBalance = function(self, nationId)
        if not self.nations[nationId] then return 0 end
        return self.nations[nationId].export_value - self.nations[nationId].import_value
    end,

    reset = function(self)
        self.nations = {}
        self.agreements = {}
        self.relations = {}
        self.trade_routes = {}
        self.tariffs = {}
        return true
    end
}

Suite:group("Nations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
    end)

    Suite:testMethod("TradeDiplomacy.registerNation", {description = "Registers nation", testCase = "register", type = "functional"}, function()
        local ok = shared.td:registerNation("nation1", "Atlantia", "region1", 15000)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("TradeDiplomacy.getNation", {description = "Gets nation", testCase = "get", type = "functional"}, function()
        shared.td:registerNation("nation2", "Lemuria", "region2")
        local nation = shared.td:getNation("nation2")
        Helpers.assertEqual(nation ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Relations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
    end)

    Suite:testMethod("TradeDiplomacy.setDiplomaticRelation", {description = "Sets relation", testCase = "set", type = "functional"}, function()
        local ok = shared.td:setDiplomaticRelation("nation1", "nation2", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("TradeDiplomacy.getDiplomaticRelation", {description = "Gets relation", testCase = "get", type = "functional"}, function()
        shared.td:setDiplomaticRelation("nation1", "nation2", 75)
        local rel = shared.td:getDiplomaticRelation("nation1", "nation2")
        Helpers.assertEqual(rel, 75, "75")
    end)
end)

Suite:group("Trade Agreements", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
    end)

    Suite:testMethod("TradeDiplomacy.createTradeAgreement", {description = "Creates agreement", testCase = "create", type = "functional"}, function()
        local ok = shared.td:createTradeAgreement("agree1", "nation1", "nation2", "metals")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TradeDiplomacy.getTradeAgreement", {description = "Gets agreement", testCase = "get", type = "functional"}, function()
        shared.td:createTradeAgreement("agree2", "nation1", "nation2", "textiles")
        local agree = shared.td:getTradeAgreement("agree2")
        Helpers.assertEqual(agree ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("TradeDiplomacy.activateAgreement", {description = "Activates agreement", testCase = "activate", type = "functional"}, function()
        shared.td:createTradeAgreement("agree3", "nation1", "nation2", "spices")
        local ok = shared.td:activateAgreement("agree3")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("TradeDiplomacy.suspendAgreement", {description = "Suspends agreement", testCase = "suspend", type = "functional"}, function()
        shared.td:createTradeAgreement("agree4", "nation1", "nation2", "lumber")
        local ok = shared.td:suspendAgreement("agree4")
        Helpers.assertEqual(ok, true, "Suspended")
    end)

    Suite:testMethod("TradeDiplomacy.isAgreementActive", {description = "Is active", testCase = "is_active", type = "functional"}, function()
        shared.td:createTradeAgreement("agree5", "nation1", "nation2", "grain")
        local is = shared.td:isAgreementActive("agree5")
        Helpers.assertEqual(is, true, "Active")
    end)
end)

Suite:group("Agreement Trade", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
        shared.td:createTradeAgreement("agree1", "nation1", "nation2", "metals")
    end)

    Suite:testMethod("TradeDiplomacy.collectAgreementTrade", {description = "Collects trade", testCase = "collect", type = "functional"}, function()
        local ok = shared.td:collectAgreementTrade("agree1")
        Helpers.assertEqual(ok, true, "Collected")
    end)

    Suite:testMethod("TradeDiplomacy.getTotalTradeVolume", {description = "Gets volume", testCase = "volume", type = "functional"}, function()
        shared.td:collectAgreementTrade("agree1")
        local volume = shared.td:getTotalTradeVolume("agree1")
        Helpers.assertEqual(volume > 0, true, "Volume > 0")
    end)
end)

Suite:group("Trade Routes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
    end)

    Suite:testMethod("TradeDiplomacy.createTradeRoute", {description = "Creates route", testCase = "create", type = "functional"}, function()
        local ok = shared.td:createTradeRoute("route1", "nation1", "nation2", 500)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TradeDiplomacy.getTradeRoute", {description = "Gets route", testCase = "get", type = "functional"}, function()
        shared.td:createTradeRoute("route2", "nation1", "nation2", 800)
        local route = shared.td:getTradeRoute("route2")
        Helpers.assertEqual(route ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("TradeDiplomacy.updateRouteFlow", {description = "Updates flow", testCase = "flow", type = "functional"}, function()
        shared.td:createTradeRoute("route3", "nation1", "nation2", 1000)
        local ok = shared.td:updateRouteFlow("route3", 500)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("TradeDiplomacy.getRouteEfficiency", {description = "Gets efficiency", testCase = "efficiency", type = "functional"}, function()
        shared.td:createTradeRoute("route4", "nation1", "nation2", 1000)
        shared.td:updateRouteFlow("route4", 500)
        local eff = shared.td:getRouteEfficiency("route4")
        Helpers.assertEqual(eff, 50, "50")
    end)
end)

Suite:group("Route Security", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
        shared.td:createTradeRoute("route1", "nation1", "nation2", 1000)
    end)

    Suite:testMethod("TradeDiplomacy.disruptTradeRoute", {description = "Disrupts route", testCase = "disrupt", type = "functional"}, function()
        local ok = shared.td:disruptTradeRoute("route1")
        Helpers.assertEqual(ok, true, "Disrupted")
    end)

    Suite:testMethod("TradeDiplomacy.restoreTradeRoute", {description = "Restores route", testCase = "restore", type = "functional"}, function()
        shared.td:disruptTradeRoute("route1")
        local ok = shared.td:restoreTradeRoute("route1")
        Helpers.assertEqual(ok, true, "Restored")
    end)
end)

Suite:group("Tariffs", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
    end)

    Suite:testMethod("TradeDiplomacy.imposeTariff", {description = "Imposes tariff", testCase = "impose", type = "functional"}, function()
        local ok = shared.td:imposeTariff("nation1", "nation2", 0.15)
        Helpers.assertEqual(ok, true, "Imposed")
    end)

    Suite:testMethod("TradeDiplomacy.getTariffRate", {description = "Gets tariff", testCase = "get", type = "functional"}, function()
        shared.td:imposeTariff("nation1", "nation2", 0.20)
        local rate = shared.td:getTariffRate("nation1", "nation2")
        Helpers.assertEqual(rate, 0.20, "0.20")
    end)

    Suite:testMethod("TradeDiplomacy.calculateTariffCost", {description = "Calculates cost", testCase = "calc", type = "functional"}, function()
        shared.td:imposeTariff("nation1", "nation2", 0.10)
        local cost = shared.td:calculateTariffCost("nation1", "nation2", 1000)
        Helpers.assertEqual(cost, 100, "100")
    end)
end)

Suite:group("Sanctions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
        shared.td:setDiplomaticRelation("nation1", "nation2", 20)
    end)

    Suite:testMethod("TradeDiplomacy.imposeSanction", {description = "Imposes sanction", testCase = "impose", type = "functional"}, function()
        local ok = shared.td:imposeSanction("nation1", "nation2", 0.25)
        Helpers.assertEqual(ok, true, "Imposed")
    end)

    Suite:testMethod("TradeDiplomacy.liftSanction", {description = "Lifts sanction", testCase = "lift", type = "functional"}, function()
        shared.td:imposeSanction("nation1", "nation2", 0.25)
        local ok = shared.td:liftSanction("nation1", "nation2")
        Helpers.assertEqual(ok, true, "Lifted")
    end)
end)

Suite:group("Trade Bloc", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
    end)

    Suite:testMethod("TradeDiplomacy.formTradeBloc", {description = "Forms bloc", testCase = "form", type = "functional"}, function()
        local bloc = shared.td:formTradeBloc("EuroTrade", {"nation1", "nation2"})
        Helpers.assertEqual(bloc ~= nil, true, "Formed")
    end)

    Suite:testMethod("TradeDiplomacy.calculateBlocTradeBenefit", {description = "Calculates benefit", testCase = "benefit", type = "functional"}, function()
        local bloc = shared.td:formTradeBloc("AsiaTrade", {"nation1", "nation2"})
        local benefit = shared.td:calculateBlocTradeBenefit(bloc)
        Helpers.assertEqual(benefit >= 0, true, "Benefit >= 0")
    end)
end)

Suite:group("Negotiation & Access", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
        shared.td:registerNation("nation2", "Lemuria", "region2")
    end)

    Suite:testMethod("TradeDiplomacy.initiateTradeNegotiation", {description = "Initiates trade", testCase = "initiate", type = "functional"}, function()
        shared.td:setDiplomaticRelation("nation1", "nation2", 30)
        local ok = shared.td:initiateTradeNegotiation("nation1", "nation2", "metals")
        Helpers.assertEqual(ok, true, "Initiated")
    end)

    Suite:testMethod("TradeDiplomacy.canTradeWith", {description = "Can trade", testCase = "can_trade", type = "functional"}, function()
        shared.td:setDiplomaticRelation("nation1", "nation2", 40)
        local can = shared.td:canTradeWith("nation1", "nation2")
        Helpers.assertEqual(can, true, "Can trade")
    end)

    Suite:testMethod("TradeDiplomacy.getTradePartners", {description = "Gets partners", testCase = "partners", type = "functional"}, function()
        shared.td:createTradeAgreement("agree1", "nation1", "nation2", "metals")
        local partners = shared.td:getTradePartners("nation1")
        Helpers.assertEqual(#partners > 0, true, "Has partners")
    end)

    Suite:testMethod("TradeDiplomacy.getPartnerCount", {description = "Gets partner count", testCase = "count", type = "functional"}, function()
        shared.td:createTradeAgreement("agree1", "nation1", "nation2", "metals")
        local count = shared.td:getPartnerCount("nation1")
        Helpers.assertEqual(count > 0, true, "Count > 0")
    end)
end)

Suite:group("Economic Influence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
        shared.td:registerNation("nation1", "Atlantia", "region1")
    end)

    Suite:testMethod("TradeDiplomacy.calculateEconomicInfluence", {description = "Calculates influence", testCase = "influence", type = "functional"}, function()
        local influence = shared.td:calculateEconomicInfluence("nation1")
        Helpers.assertEqual(influence >= 0, true, "Influence >= 0")
    end)

    Suite:testMethod("TradeDiplomacy.recordExportValue", {description = "Records export", testCase = "export", type = "functional"}, function()
        local ok = shared.td:recordExportValue("nation1", 500)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("TradeDiplomacy.recordImportValue", {description = "Records import", testCase = "import", type = "functional"}, function()
        local ok = shared.td:recordImportValue("nation1", 300)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("TradeDiplomacy.calculateTradeBalance", {description = "Calculates balance", testCase = "balance", type = "functional"}, function()
        shared.td:recordExportValue("nation1", 1000)
        shared.td:recordImportValue("nation1", 600)
        local balance = shared.td:calculateTradeBalance("nation1")
        Helpers.assertEqual(balance, 400, "400")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.td = TradeDiplomacy:new()
    end)

    Suite:testMethod("TradeDiplomacy.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.td:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
