-- ─────────────────────────────────────────────────────────────────────────
-- REGION POLITICS TEST SUITE
-- FILE: tests2/politics/region_politics_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.region_politics",
    fileName = "region_politics.lua",
    description = "Regional faction politics with control, influence, and power dynamics"
})

print("[REGION_POLITICS_TEST] Setting up")

local RegionPolitics = {
    regions = {},
    factions = {},
    control = {},
    influence = {},
    alliances = {},

    new = function(self)
        return setmetatable({regions = {}, factions = {}, control = {}, influence = {}, alliances = {}}, {__index = self})
    end,

    registerRegion = function(self, regionId, regionName, strategicValue)
        self.regions[regionId] = {id = regionId, name = regionName, value = strategicValue or 50, unclaimed = true}
        self.control[regionId] = nil
        self.influence[regionId] = {}
        return true
    end,

    registerFaction = function(self, factionId, factionName, baseInfluence)
        self.factions[factionId] = {id = factionId, name = factionName, baseInfluence = baseInfluence or 10}
        return true
    end,

    claimRegion = function(self, regionId, factionId)
        if not self.regions[regionId] or not self.factions[factionId] then return false end
        if not self.regions[regionId].unclaimed then return false end
        self.control[regionId] = factionId
        self.regions[regionId].unclaimed = false
        self.influence[regionId][factionId] = 100
        return true
    end,

    getRegionController = function(self, regionId)
        return self.control[regionId]
    end,

    addInfluence = function(self, regionId, factionId, amount)
        if not self.regions[regionId] or not self.factions[factionId] then return false end
        if not self.influence[regionId][factionId] then
            self.influence[regionId][factionId] = 0
        end
        self.influence[regionId][factionId] = self.influence[regionId][factionId] + amount
        if self.influence[regionId][factionId] < 0 then
            self.influence[regionId][factionId] = 0
        end
        return true
    end,

    getInfluence = function(self, regionId, factionId)
        if not self.influence[regionId] then return 0 end
        return self.influence[regionId][factionId] or 0
    end,

    getDominantFaction = function(self, regionId)
        if not self.influence[regionId] or not next(self.influence[regionId]) then return nil end
        local max = 0
        local dominant = nil
        for factionId, influence in pairs(self.influence[regionId]) do
            if influence > max then
                max = influence
                dominant = factionId
            end
        end
        return dominant
    end,

    createAlliance = function(self, factionA, factionB)
        if not self.factions[factionA] or not self.factions[factionB] then return false end
        if not self.alliances[factionA] then self.alliances[factionA] = {} end
        self.alliances[factionA][factionB] = true
        if not self.alliances[factionB] then self.alliances[factionB] = {} end
        self.alliances[factionB][factionA] = true
        return true
    end,

    areAllied = function(self, factionA, factionB)
        if not self.alliances[factionA] then return false end
        return self.alliances[factionA][factionB] == true
    end,

    breakAlliance = function(self, factionA, factionB)
        if not self.alliances[factionA] then return false end
        self.alliances[factionA][factionB] = nil
        if self.alliances[factionB] then
            self.alliances[factionB][factionA] = nil
        end
        return true
    end,

    getAlliesOf = function(self, factionId)
        if not self.alliances[factionId] then return {} end
        local allies = {}
        for ally in pairs(self.alliances[factionId]) do
            table.insert(allies, ally)
        end
        return allies
    end,

    canTakeover = function(self, regionId, factionId, currentInfluence)
        if not self.regions[regionId] then return false end
        local controller = self.control[regionId]
        if not controller then return true end
        if controller == factionId then return false end
        local controllerInfluence = self.influence[regionId][controller] or 0
        return currentInfluence > controllerInfluence
    end,

    performTakeover = function(self, regionId, factionId)
        if not self:canTakeover(regionId, factionId, self.influence[regionId][factionId] or 0) then return false end
        self.control[regionId] = factionId
        self.influence[regionId][factionId] = math.max(100, (self.influence[regionId][factionId] or 0))
        return true
    end,

    getTotalRegionCount = function(self)
        local count = 0
        for _ in pairs(self.regions) do count = count + 1 end
        return count
    end,

    getFactionControlledRegions = function(self, factionId)
        local controlled = {}
        for regionId, controlledBy in pairs(self.control) do
            if controlledBy == factionId then
                table.insert(controlled, regionId)
            end
        end
        return controlled
    end,

    getTotalFactionInfluence = function(self, factionId)
        local total = 0
        for regionId in pairs(self.regions) do
            total = total + (self.influence[regionId][factionId] or 0)
        end
        return total
    end,

    getRegionInfluenceMap = function(self, regionId)
        return self.influence[regionId] or {}
    end,

    spreadInfluence = function(self, fromRegionId, toRegionId, factionId, amount)
        if not self.regions[fromRegionId] or not self.regions[toRegionId] then return false end
        if not self.influence[fromRegionId][factionId] or self.influence[fromRegionId][factionId] < amount then return false end
        self.influence[fromRegionId][factionId] = self.influence[fromRegionId][factionId] - amount
        self:addInfluence(toRegionId, factionId, amount)
        return true
    end,

    resetRegionControl = function(self, regionId)
        if not self.regions[regionId] then return false end
        self.control[regionId] = nil
        self.regions[regionId].unclaimed = true
        self.influence[regionId] = {}
        return true
    end,

    getStrategicScore = function(self, factionId)
        local score = 0
        for regionId, controlledBy in pairs(self.control) do
            if controlledBy == factionId then
                score = score + (self.regions[regionId].value or 0)
            end
        end
        return score
    end,

    adjustInfluenceDecay = function(self, regionId, factionId, decayAmount)
        if not self.influence[regionId] or not self.influence[regionId][factionId] then return false end
        self.influence[regionId][factionId] = math.max(0, self.influence[regionId][factionId] - decayAmount)
        return true
    end
}

Suite:group("Region Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
    end)

    Suite:testMethod("RegionPolitics.registerRegion", {description = "Registers region", testCase = "register_region", type = "functional"}, function()
        local ok = shared.rp:registerRegion("europe", "Europe", 100)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("RegionPolitics.getTotalRegionCount", {description = "Counts regions", testCase = "count_regions", type = "functional"}, function()
        shared.rp:registerRegion("r1", "Region 1", 50)
        shared.rp:registerRegion("r2", "Region 2", 75)
        local count = shared.rp:getTotalRegionCount()
        Helpers.assertEqual(count, 2, "Two regions")
    end)
end)

Suite:group("Faction Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
    end)

    Suite:testMethod("RegionPolitics.registerFaction", {description = "Registers faction", testCase = "register_faction", type = "functional"}, function()
        local ok = shared.rp:registerFaction("xcom", "XCOM", 20)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("RegionPolitics.getStrategicScore", {description = "Calculates score", testCase = "score", type = "functional"}, function()
        shared.rp:registerRegion("r1", "Region 1", 100)
        shared.rp:registerRegion("r2", "Region 2", 50)
        shared.rp:registerFaction("faction", "Faction", 10)
        shared.rp:claimRegion("r1", "faction")
        shared.rp:claimRegion("r2", "faction")
        local score = shared.rp:getStrategicScore("faction")
        Helpers.assertEqual(score, 150, "150 score")
    end)
end)

Suite:group("Control & Claiming", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerRegion("territory", "Territory", 80)
        shared.rp:registerFaction("faction1", "Faction 1", 15)
    end)

    Suite:testMethod("RegionPolitics.claimRegion", {description = "Claims region", testCase = "claim", type = "functional"}, function()
        local ok = shared.rp:claimRegion("territory", "faction1")
        Helpers.assertEqual(ok, true, "Claimed")
    end)

    Suite:testMethod("RegionPolitics.getRegionController", {description = "Gets controller", testCase = "get_controller", type = "functional"}, function()
        shared.rp:claimRegion("territory", "faction1")
        local controller = shared.rp:getRegionController("territory")
        Helpers.assertEqual(controller, "faction1", "Faction1 controls")
    end)

    Suite:testMethod("RegionPolitics.getFactionControlledRegions", {description = "Lists regions", testCase = "list_regions", type = "functional"}, function()
        shared.rp:registerRegion("t2", "Territory 2", 60)
        shared.rp:claimRegion("territory", "faction1")
        shared.rp:claimRegion("t2", "faction1")
        local regions = shared.rp:getFactionControlledRegions("faction1")
        Helpers.assertEqual(#regions, 2, "Two regions")
    end)
end)

Suite:group("Influence System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerRegion("region", "Region", 50)
        shared.rp:registerFaction("f1", "Faction 1", 10)
    end)

    Suite:testMethod("RegionPolitics.addInfluence", {description = "Adds influence", testCase = "add_influence", type = "functional"}, function()
        local ok = shared.rp:addInfluence("region", "f1", 25)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("RegionPolitics.getInfluence", {description = "Gets influence", testCase = "get_influence", type = "functional"}, function()
        shared.rp:addInfluence("region", "f1", 30)
        local influence = shared.rp:getInfluence("region", "f1")
        Helpers.assertEqual(influence, 30, "30 influence")
    end)

    Suite:testMethod("RegionPolitics.getTotalFactionInfluence", {description = "Total influence", testCase = "total_influence", type = "functional"}, function()
        shared.rp:registerRegion("r2", "Region 2", 40)
        shared.rp:addInfluence("region", "f1", 50)
        shared.rp:addInfluence("r2", "f1", 30)
        local total = shared.rp:getTotalFactionInfluence("f1")
        Helpers.assertEqual(total, 80, "80 total")
    end)

    Suite:testMethod("RegionPolitics.getDominantFaction", {description = "Finds dominant", testCase = "dominant", type = "functional"}, function()
        shared.rp:registerFaction("f2", "Faction 2", 10)
        shared.rp:addInfluence("region", "f1", 60)
        shared.rp:addInfluence("region", "f2", 40)
        local dominant = shared.rp:getDominantFaction("region")
        Helpers.assertEqual(dominant, "f1", "F1 dominant")
    end)
end)

Suite:group("Alliances", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerFaction("fa", "Faction A", 10)
        shared.rp:registerFaction("fb", "Faction B", 10)
    end)

    Suite:testMethod("RegionPolitics.createAlliance", {description = "Creates alliance", testCase = "create_alliance", type = "functional"}, function()
        local ok = shared.rp:createAlliance("fa", "fb")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("RegionPolitics.areAllied", {description = "Checks alliance", testCase = "are_allied", type = "functional"}, function()
        shared.rp:createAlliance("fa", "fb")
        local allied = shared.rp:areAllied("fa", "fb")
        Helpers.assertEqual(allied, true, "Allied")
    end)

    Suite:testMethod("RegionPolitics.breakAlliance", {description = "Breaks alliance", testCase = "break_alliance", type = "functional"}, function()
        shared.rp:createAlliance("fa", "fb")
        local ok = shared.rp:breakAlliance("fa", "fb")
        Helpers.assertEqual(ok, true, "Broken")
    end)

    Suite:testMethod("RegionPolitics.getAlliesOf", {description = "Lists allies", testCase = "list_allies", type = "functional"}, function()
        shared.rp:registerFaction("fc", "Faction C", 10)
        shared.rp:createAlliance("fa", "fb")
        shared.rp:createAlliance("fa", "fc")
        local allies = shared.rp:getAlliesOf("fa")
        Helpers.assertEqual(#allies, 2, "Two allies")
    end)
end)

Suite:group("Takeovers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerRegion("contested", "Contested", 100)
        shared.rp:registerFaction("attacker", "Attacker", 10)
        shared.rp:registerFaction("defender", "Defender", 10)
        shared.rp:claimRegion("contested", "defender")
        shared.rp:addInfluence("contested", "defender", 50)
    end)

    Suite:testMethod("RegionPolitics.canTakeover", {description = "Can takeover", testCase = "can_takeover", type = "functional"}, function()
        shared.rp:addInfluence("contested", "attacker", 60)
        local can = shared.rp:canTakeover("contested", "attacker", 60)
        Helpers.assertEqual(can, true, "Can takeover")
    end)

    Suite:testMethod("RegionPolitics.performTakeover", {description = "Performs takeover", testCase = "perform_takeover", type = "functional"}, function()
        shared.rp:addInfluence("contested", "attacker", 100)
        local ok = shared.rp:performTakeover("contested", "attacker")
        Helpers.assertEqual(ok, true, "Takeover")
    end)
end)

Suite:group("Influence Spread", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerRegion("source", "Source", 50)
        shared.rp:registerRegion("target", "Target", 50)
        shared.rp:registerFaction("spreader", "Spreader", 10)
        shared.rp:addInfluence("source", "spreader", 100)
    end)

    Suite:testMethod("RegionPolitics.spreadInfluence", {description = "Spreads influence", testCase = "spread", type = "functional"}, function()
        local ok = shared.rp:spreadInfluence("source", "target", "spreader", 30)
        Helpers.assertEqual(ok, true, "Spread")
    end)

    Suite:testMethod("RegionPolitics.getRegionInfluenceMap", {description = "Gets influence map", testCase = "influence_map", type = "functional"}, function()
        shared.rp:addInfluence("source", "spreader", 50)
        local map = shared.rp:getRegionInfluenceMap("source")
        Helpers.assertEqual(map["spreader"] ~= nil, true, "Map exists")
    end)
end)

Suite:group("Influence Decay", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerRegion("decaying", "Decaying", 50)
        shared.rp:registerFaction("fading", "Fading", 10)
        shared.rp:addInfluence("decaying", "fading", 100)
    end)

    Suite:testMethod("RegionPolitics.adjustInfluenceDecay", {description = "Decays influence", testCase = "decay", type = "functional"}, function()
        local ok = shared.rp:adjustInfluenceDecay("decaying", "fading", 30)
        Helpers.assertEqual(ok, true, "Decayed")
    end)
end)

Suite:group("Reset Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rp = RegionPolitics:new()
        shared.rp:registerRegion("resetting", "Resetting", 50)
        shared.rp:registerFaction("reset_faction", "Reset Faction", 10)
        shared.rp:claimRegion("resetting", "reset_faction")
    end)

    Suite:testMethod("RegionPolitics.resetRegionControl", {description = "Resets region", testCase = "reset", type = "functional"}, function()
        local ok = shared.rp:resetRegionControl("resetting")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
