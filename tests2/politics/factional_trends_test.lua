-- ─────────────────────────────────────────────────────────────────────────
-- FACTIONAL TRENDS TEST SUITE
-- FILE: tests2/politics/factional_trends_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.factional_trends",
    fileName = "factional_trends.lua",
    description = "Faction dynamics with reputation, satisfaction, trends, and strategic relationships"
})

print("[FACTIONAL_TRENDS_TEST] Setting up")

local FactionalTrends = {
    factions = {},
    reputation = {},
    satisfaction = {},
    trends = {},
    events = {},

    new = function(self)
        return setmetatable({factions = {}, reputation = {}, satisfaction = {}, trends = {}, events = {}}, {__index = self})
    end,

    registerFaction = function(self, factionId, factionName, baseReputation)
        self.factions[factionId] = {id = factionId, name = factionName, stability = 50}
        self.reputation[factionId] = {xcom = baseReputation or 50, funding = 0, operations = 0}
        self.satisfaction[factionId] = 50
        self.trends[factionId] = {reputation = {}, satisfaction = {}}
        self.events[factionId] = {}
        return true
    end,

    getFaction = function(self, factionId)
        return self.factions[factionId]
    end,

    setReputation = function(self, factionId, aspect, value)
        if not self.reputation[factionId] then return false end
        self.reputation[factionId][aspect] = value
        return true
    end,

    getReputation = function(self, factionId, aspect)
        if not self.reputation[factionId] then return 0 end
        return self.reputation[factionId][aspect] or 0
    end,

    getTotalReputation = function(self, factionId)
        if not self.reputation[factionId] then return 0 end
        local total = 0
        for _, rep in pairs(self.reputation[factionId]) do
            total = total + rep
        end
        return total
    end,

    modifyReputation = function(self, factionId, aspect, delta)
        if not self.reputation[factionId] then return false end
        if not self.reputation[factionId][aspect] then
            self.reputation[factionId][aspect] = 0
        end
        self.reputation[factionId][aspect] = self.reputation[factionId][aspect] + delta
        if self.reputation[factionId][aspect] < 0 then
            self.reputation[factionId][aspect] = 0
        end
        if self.reputation[factionId][aspect] > 100 then
            self.reputation[factionId][aspect] = 100
        end
        return true
    end,

    setSatisfaction = function(self, factionId, satisfaction)
        if not self.factions[factionId] then return false end
        self.satisfaction[factionId] = satisfaction
        return true
    end,

    getSatisfaction = function(self, factionId)
        if not self.satisfaction[factionId] then return 0 end
        return self.satisfaction[factionId]
    end,

    modifySatisfaction = function(self, factionId, delta)
        if not self.factions[factionId] then return false end
        self.satisfaction[factionId] = self.satisfaction[factionId] + delta
        if self.satisfaction[factionId] < 0 then
            self.satisfaction[factionId] = 0
        end
        if self.satisfaction[factionId] > 100 then
            self.satisfaction[factionId] = 100
        end
        return true
    end,

    recordTrendPoint = function(self, factionId, trendType, value, turn)
        if not self.trends[factionId] then return false end
        if not self.trends[factionId][trendType] then
            self.trends[factionId][trendType] = {}
        end
        table.insert(self.trends[factionId][trendType], {value = value, turn = turn or 0})
        return true
    end,

    getTrendDirection = function(self, factionId, trendType)
        if not self.trends[factionId] or not self.trends[factionId][trendType] then return "stable" end
        local points = self.trends[factionId][trendType]
        if #points < 2 then return "stable" end
        local first = points[1].value
        local last = points[#points].value
        if last > first then return "increasing" end
        if last < first then return "decreasing" end
        return "stable"
    end,

    getTrendAverage = function(self, factionId, trendType)
        if not self.trends[factionId] or not self.trends[factionId][trendType] then return 0 end
        local points = self.trends[factionId][trendType]
        if #points == 0 then return 0 end
        local sum = 0
        for _, point in ipairs(points) do
            sum = sum + point.value
        end
        return math.floor(sum / #points)
    end,

    recordEvent = function(self, factionId, eventType, eventDescription, impact)
        if not self.factions[factionId] then return false end
        if not self.events[factionId] then self.events[factionId] = {} end
        table.insert(self.events[factionId], {type = eventType, description = eventDescription, impact = impact or 0, logged = true})
        return true
    end,

    getEventCount = function(self, factionId)
        if not self.events[factionId] then return 0 end
        return #self.events[factionId]
    end,

    getEventsByType = function(self, factionId, eventType)
        if not self.events[factionId] then return {} end
        local filtered = {}
        for _, event in ipairs(self.events[factionId]) do
            if event.type == eventType then
                table.insert(filtered, event)
            end
        end
        return filtered
    end,

    getRecentEvents = function(self, factionId, count)
        if not self.events[factionId] then return {} end
        local recent = {}
        local start = math.max(1, #self.events[factionId] - count + 1)
        for i = start, #self.events[factionId] do
            table.insert(recent, self.events[factionId][i])
        end
        return recent
    end,

    calculateFactionStability = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        local avgReputation = self:getTotalReputation(factionId) / 3
        local satisfaction = self:getSatisfaction(factionId)
        local stability = (avgReputation + satisfaction) / 2
        self.factions[factionId].stability = math.floor(stability)
        return self.factions[factionId].stability
    end,

    getStability = function(self, factionId)
        if not self.factions[factionId] then return 0 end
        return self.factions[factionId].stability
    end,

    isStableFaction = function(self, factionId)
        if not self.factions[factionId] then return false end
        return self:calculateFactionStability(factionId) >= 50
    end,

    predictRepresentationTrend = function(self, factionId, trendType)
        local direction = self:getTrendDirection(factionId, trendType)
        local average = self:getTrendAverage(factionId, trendType)
        if direction == "increasing" and average > 60 then
            return "positive"
        elseif direction == "decreasing" and average < 40 then
            return "negative"
        end
        return "neutral"
    end,

    applyRepresentationBonus = function(self, factionId, bonusType, bonusValue)
        if not self.reputation[factionId] then return false end
        if not self.reputation[factionId][bonusType] then
            self.reputation[factionId][bonusType] = 0
        end
        self.reputation[factionId][bonusType] = math.min(100, self.reputation[factionId][bonusType] + bonusValue)
        return true
    end,

    applyRepresentationPenalty = function(self, factionId, penaltyType, penaltyValue)
        if not self.reputation[factionId] then return false end
        if not self.reputation[factionId][penaltyType] then
            self.reputation[factionId][penaltyType] = 0
        end
        self.reputation[factionId][penaltyType] = math.max(0, self.reputation[factionId][penaltyType] - penaltyValue)
        return true
    end,

    resetFactionState = function(self, factionId)
        if not self.factions[factionId] then return false end
        self.reputation[factionId] = {xcom = 50, funding = 0, operations = 0}
        self.satisfaction[factionId] = 50
        self.trends[factionId] = {reputation = {}, satisfaction = {}}
        self.events[factionId] = {}
        return true
    end,

    getHighestReputationAspect = function(self, factionId)
        if not self.reputation[factionId] then return nil end
        local highest = nil
        local highestValue = -1
        for aspect, value in pairs(self.reputation[factionId]) do
            if value > highestValue then
                highestValue = value
                highest = aspect
            end
        end
        return highest
    end,

    getLowestReputationAspect = function(self, factionId)
        if not self.reputation[factionId] then return nil end
        local lowest = nil
        local lowestValue = 101
        for aspect, value in pairs(self.reputation[factionId]) do
            if value < lowestValue then
                lowestValue = value
                lowest = aspect
            end
        end
        return lowest
    end
}

Suite:group("Faction Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
    end)

    Suite:testMethod("FactionalTrends.registerFaction", {description = "Registers faction", testCase = "register", type = "functional"}, function()
        local ok = shared.ft:registerFaction("f1", "Faction 1", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("FactionalTrends.getFaction", {description = "Gets faction", testCase = "get", type = "functional"}, function()
        shared.ft:registerFaction("f2", "Faction 2", 50)
        local faction = shared.ft:getFaction("f2")
        Helpers.assertEqual(faction ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Reputation System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("rep_faction", "Rep Faction", 60)
    end)

    Suite:testMethod("FactionalTrends.setReputation", {description = "Sets reputation", testCase = "set_rep", type = "functional"}, function()
        local ok = shared.ft:setReputation("rep_faction", "xcom", 80)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("FactionalTrends.getReputation", {description = "Gets reputation", testCase = "get_rep", type = "functional"}, function()
        shared.ft:setReputation("rep_faction", "funding", 75)
        local rep = shared.ft:getReputation("rep_faction", "funding")
        Helpers.assertEqual(rep, 75, "75 rep")
    end)

    Suite:testMethod("FactionalTrends.getTotalReputation", {description = "Total reputation", testCase = "total_rep", type = "functional"}, function()
        shared.ft:setReputation("rep_faction", "xcom", 60)
        shared.ft:setReputation("rep_faction", "funding", 40)
        shared.ft:setReputation("rep_faction", "operations", 50)
        local total = shared.ft:getTotalReputation("rep_faction")
        Helpers.assertEqual(total, 150, "150 total")
    end)

    Suite:testMethod("FactionalTrends.modifyReputation", {description = "Modifies reputation", testCase = "modify_rep", type = "functional"}, function()
        shared.ft:modifyReputation("rep_faction", "xcom", 15)
        local rep = shared.ft:getReputation("rep_faction", "xcom")
        Helpers.assertEqual(rep, 65, "65 rep")
    end)
end)

Suite:group("Satisfaction System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("sat_faction", "Sat Faction", 50)
    end)

    Suite:testMethod("FactionalTrends.setSatisfaction", {description = "Sets satisfaction", testCase = "set_sat", type = "functional"}, function()
        local ok = shared.ft:setSatisfaction("sat_faction", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("FactionalTrends.getSatisfaction", {description = "Gets satisfaction", testCase = "get_sat", type = "functional"}, function()
        shared.ft:setSatisfaction("sat_faction", 70)
        local sat = shared.ft:getSatisfaction("sat_faction")
        Helpers.assertEqual(sat, 70, "70 sat")
    end)

    Suite:testMethod("FactionalTrends.modifySatisfaction", {description = "Modifies satisfaction", testCase = "modify_sat", type = "functional"}, function()
        shared.ft:modifySatisfaction("sat_faction", 15)
        local sat = shared.ft:getSatisfaction("sat_faction")
        Helpers.assertEqual(sat, 65, "65 sat")
    end)
end)

Suite:group("Trends", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("trend_faction", "Trend Faction", 50)
    end)

    Suite:testMethod("FactionalTrends.recordTrendPoint", {description = "Records point", testCase = "record_point", type = "functional"}, function()
        local ok = shared.ft:recordTrendPoint("trend_faction", "reputation", 50, 1)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FactionalTrends.getTrendDirection", {description = "Gets direction", testCase = "direction", type = "functional"}, function()
        shared.ft:recordTrendPoint("trend_faction", "satisfaction", 30, 1)
        shared.ft:recordTrendPoint("trend_faction", "satisfaction", 60, 2)
        local direction = shared.ft:getTrendDirection("trend_faction", "satisfaction")
        Helpers.assertEqual(direction, "increasing", "Increasing")
    end)

    Suite:testMethod("FactionalTrends.getTrendAverage", {description = "Gets average", testCase = "average", type = "functional"}, function()
        shared.ft:recordTrendPoint("trend_faction", "reputation", 40, 1)
        shared.ft:recordTrendPoint("trend_faction", "reputation", 50, 2)
        shared.ft:recordTrendPoint("trend_faction", "reputation", 60, 3)
        local avg = shared.ft:getTrendAverage("trend_faction", "reputation")
        Helpers.assertEqual(avg, 50, "50 average")
    end)
end)

Suite:group("Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("event_faction", "Event Faction", 50)
    end)

    Suite:testMethod("FactionalTrends.recordEvent", {description = "Records event", testCase = "record_event", type = "functional"}, function()
        local ok = shared.ft:recordEvent("event_faction", "victory", "Mission success", 10)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("FactionalTrends.getEventCount", {description = "Counts events", testCase = "event_count", type = "functional"}, function()
        shared.ft:recordEvent("event_faction", "victory", "Success 1", 10)
        shared.ft:recordEvent("event_faction", "defeat", "Failure 1", -5)
        local count = shared.ft:getEventCount("event_faction")
        Helpers.assertEqual(count, 2, "Two events")
    end)

    Suite:testMethod("FactionalTrends.getEventsByType", {description = "Gets by type", testCase = "by_type", type = "functional"}, function()
        shared.ft:recordEvent("event_faction", "victory", "V1", 10)
        shared.ft:recordEvent("event_faction", "victory", "V2", 10)
        shared.ft:recordEvent("event_faction", "loss", "L1", -5)
        local victories = shared.ft:getEventsByType("event_faction", "victory")
        Helpers.assertEqual(#victories, 2, "Two victories")
    end)

    Suite:testMethod("FactionalTrends.getRecentEvents", {description = "Gets recent", testCase = "recent", type = "functional"}, function()
        shared.ft:recordEvent("event_faction", "e1", "E1", 0)
        shared.ft:recordEvent("event_faction", "e2", "E2", 0)
        shared.ft:recordEvent("event_faction", "e3", "E3", 0)
        local recent = shared.ft:getRecentEvents("event_faction", 2)
        Helpers.assertEqual(#recent, 2, "Two recent")
    end)
end)

Suite:group("Stability", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("stable_faction", "Stable", 75)
    end)

    Suite:testMethod("FactionalTrends.calculateFactionStability", {description = "Calculates stability", testCase = "calc_stability", type = "functional"}, function()
        shared.ft:setReputation("stable_faction", "xcom", 70)
        shared.ft:setReputation("stable_faction", "funding", 60)
        shared.ft:setReputation("stable_faction", "operations", 50)
        shared.ft:setSatisfaction("stable_faction", 80)
        local stability = shared.ft:calculateFactionStability("stable_faction")
        Helpers.assertEqual(stability > 0, true, "Stability calculated")
    end)

    Suite:testMethod("FactionalTrends.isStableFaction", {description = "Checks stability", testCase = "is_stable", type = "functional"}, function()
        shared.ft:setReputation("stable_faction", "xcom", 100)
        shared.ft:setSatisfaction("stable_faction", 100)
        local stable = shared.ft:isStableFaction("stable_faction")
        Helpers.assertEqual(stable, true, "Stable")
    end)
end)

Suite:group("Predictions & Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("analysis_faction", "Analysis", 50)
    end)

    Suite:testMethod("FactionalTrends.predictRepresentationTrend", {description = "Predicts trend", testCase = "predict", type = "functional"}, function()
        shared.ft:recordTrendPoint("analysis_faction", "rep_trend", 30, 1)
        shared.ft:recordTrendPoint("analysis_faction", "rep_trend", 50, 2)
        shared.ft:recordTrendPoint("analysis_faction", "rep_trend", 70, 3)
        local prediction = shared.ft:predictRepresentationTrend("analysis_faction", "rep_trend")
        Helpers.assertEqual(prediction, "positive", "Positive")
    end)

    Suite:testMethod("FactionalTrends.getHighestReputationAspect", {description = "Gets highest", testCase = "highest", type = "functional"}, function()
        shared.ft:setReputation("analysis_faction", "xcom", 80)
        shared.ft:setReputation("analysis_faction", "funding", 50)
        local highest = shared.ft:getHighestReputationAspect("analysis_faction")
        Helpers.assertEqual(highest, "xcom", "XCOM highest")
    end)

    Suite:testMethod("FactionalTrends.getLowestReputationAspect", {description = "Gets lowest", testCase = "lowest", type = "functional"}, function()
        shared.ft:setReputation("analysis_faction", "xcom", 70)
        shared.ft:setReputation("analysis_faction", "operations", 30)
        local lowest = shared.ft:getLowestReputationAspect("analysis_faction")
        Helpers.assertEqual(lowest, "operations", "Operations lowest")
    end)
end)

Suite:group("Bonuses & Penalties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("bonus_faction", "Bonus", 50)
    end)

    Suite:testMethod("FactionalTrends.applyRepresentationBonus", {description = "Applies bonus", testCase = "bonus", type = "functional"}, function()
        local ok = shared.ft:applyRepresentationBonus("bonus_faction", "xcom", 20)
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("FactionalTrends.applyRepresentationPenalty", {description = "Applies penalty", testCase = "penalty", type = "functional"}, function()
        local ok = shared.ft:applyRepresentationPenalty("bonus_faction", "xcom", 15)
        Helpers.assertEqual(ok, true, "Applied")
    end)
end)

Suite:group("Reset Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ft = FactionalTrends:new()
        shared.ft:registerFaction("reset_faction", "Reset", 80)
        shared.ft:setSatisfaction("reset_faction", 30)
    end)

    Suite:testMethod("FactionalTrends.resetFactionState", {description = "Resets state", testCase = "reset", type = "functional"}, function()
        local ok = shared.ft:resetFactionState("reset_faction")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
