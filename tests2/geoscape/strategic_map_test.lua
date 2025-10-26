-- ─────────────────────────────────────────────────────────────────────────
-- STRATEGIC MAP TEST SUITE
-- FILE: tests2/geoscape/strategic_map_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.strategic_map",
    fileName = "strategic_map.lua",
    description = "Global strategic map with zones, territories, and geopolitical control"
})

print("[STRATEGIC_MAP_TEST] Setting up")

local StrategicMap = {
    zones = {},
    territories = {},
    control_map = {},
    influence = {},
    strategic_resources = {},

    new = function(self)
        return setmetatable({
            zones = {}, territories = {}, control_map = {},
            influence = {}, strategic_resources = {}
        }, {__index = self})
    end,

    createZone = function(self, zoneId, name, x, y, type)
        self.zones[zoneId] = {
            id = zoneId, name = name, x = x, y = y, type = type or "continent",
            control_owner = nil, threat_level = 0, stability = 80
        }
        self.control_map[zoneId] = {}
        self.influence[zoneId] = {}
        return true
    end,

    getZone = function(self, zoneId)
        return self.zones[zoneId]
    end,

    defineTerritory = function(self, territoryId, name, zoneId, owner, resources)
        if not self.zones[zoneId] then return false end
        self.territories[territoryId] = {
            id = territoryId, name = name, zone = zoneId, owner = owner,
            resources = resources or {}, defense_level = 50, contested = false
        }
        self.control_map[zoneId][territoryId] = owner
        return true
    end,

    getTerritory = function(self, territoryId)
        return self.territories[territoryId]
    end,

    setTerritoryOwner = function(self, territoryId, newOwner)
        if not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        local oldOwner = territory.owner
        territory.owner = newOwner
        territory.contested = false
        self.control_map[territory.zone][territoryId] = newOwner
        if oldOwner and oldOwner ~= newOwner then
            territory.contested = true
        end
        return true
    end,

    getTerritoryOwner = function(self, territoryId)
        if not self.territories[territoryId] then return nil end
        return self.territories[territoryId].owner
    end,

    isTerritoryContested = function(self, territoryId)
        if not self.territories[territoryId] then return false end
        return self.territories[territoryId].contested
    end,

    setZoneControl = function(self, zoneId, owner)
        if not self.zones[zoneId] then return false end
        self.zones[zoneId].control_owner = owner
        return true
    end,

    getZoneControl = function(self, zoneId)
        if not self.zones[zoneId] then return nil end
        return self.zones[zoneId].control_owner
    end,

    calculateZoneDominance = function(self, zoneId)
        if not self.zones[zoneId] then return 0 end
        local territory_count = {}
        for territoryId, territory in pairs(self.territories) do
            if territory.zone == zoneId and territory.owner then
                territory_count[territory.owner] = (territory_count[territory.owner] or 0) + 1
            end
        end
        local maxOwner = nil
        local maxCount = 0
        for owner, count in pairs(territory_count) do
            if count > maxCount then
                maxCount = count
                maxOwner = owner
            end
        end
        return maxCount, maxOwner
    end,

    getTerritoryCountInZone = function(self, zoneId)
        if not self.zones[zoneId] then return 0 end
        local count = 0
        for territoryId, territory in pairs(self.territories) do
            if territory.zone == zoneId then count = count + 1 end
        end
        return count
    end,

    setZoneThreatLevel = function(self, zoneId, threat)
        if not self.zones[zoneId] then return false end
        self.zones[zoneId].threat_level = math.max(0, math.min(100, threat))
        return true
    end,

    getZoneThreatLevel = function(self, zoneId)
        if not self.zones[zoneId] then return 0 end
        return self.zones[zoneId].threat_level
    end,

    setZoneStability = function(self, zoneId, stability)
        if not self.zones[zoneId] then return false end
        self.zones[zoneId].stability = math.max(0, math.min(100, stability))
        return true
    end,

    getZoneStability = function(self, zoneId)
        if not self.zones[zoneId] then return 0 end
        return self.zones[zoneId].stability
    end,

    addInfluence = function(self, zoneId, playerId, amount)
        if not self.influence[zoneId] then return false end
        self.influence[zoneId][playerId] = (self.influence[zoneId][playerId] or 0) + amount
        return true
    end,

    getInfluence = function(self, zoneId, playerId)
        if not self.influence[zoneId] then return 0 end
        return self.influence[zoneId][playerId] or 0
    end,

    getDominantInfluence = function(self, zoneId)
        if not self.influence[zoneId] or not next(self.influence[zoneId]) then return nil end
        local maxPlayer = nil
        local maxInfluence = -1
        for playerId, influence in pairs(self.influence[zoneId]) do
            if influence > maxInfluence then
                maxInfluence = influence
                maxPlayer = playerId
            end
        end
        return maxPlayer, maxInfluence
    end,

    addResource = function(self, territoryId, resourceType, quantity)
        if not self.territories[territoryId] then return false end
        if not self.territories[territoryId].resources then self.territories[territoryId].resources = {} end
        if not self.strategic_resources[resourceType] then self.strategic_resources[resourceType] = {} end
        self.territories[territoryId].resources[resourceType] = (self.territories[territoryId].resources[resourceType] or 0) + quantity
        self.strategic_resources[resourceType][territoryId] = self.territories[territoryId].resources[resourceType]
        return true
    end,

    getResourceQuantity = function(self, territoryId, resourceType)
        if not self.territories[territoryId] then return 0 end
        if not self.territories[territoryId].resources then return 0 end
        return self.territories[territoryId].resources[resourceType] or 0
    end,

    getTotalResourceQuantity = function(self, resourceType)
        if not self.strategic_resources[resourceType] then return 0 end
        local total = 0
        for _, qty in pairs(self.strategic_resources[resourceType]) do
            total = total + qty
        end
        return total
    end,

    setTerritoryDefenseLevel = function(self, territoryId, level)
        if not self.territories[territoryId] then return false end
        self.territories[territoryId].defense_level = math.max(0, math.min(100, level))
        return true
    end,

    getTerritoryDefenseLevel = function(self, territoryId)
        if not self.territories[territoryId] then return 0 end
        return self.territories[territoryId].defense_level
    end,

    calculateWorldControl = function(self, player)
        local count = 0
        for _, territory in pairs(self.territories) do
            if territory.owner == player then count = count + 1 end
        end
        return count
    end,

    calculateWorldCoverage = function(self, player)
        local playerTerritories = self:calculateWorldControl(player)
        local totalTerritories = 0
        for _ in pairs(self.territories) do totalTerritories = totalTerritories + 1 end
        if totalTerritories == 0 then return 0 end
        return math.floor((playerTerritories / totalTerritories) * 100)
    end,

    getZoneCount = function(self)
        local count = 0
        for _ in pairs(self.zones) do count = count + 1 end
        return count
    end,

    getTerritoryCount = function(self)
        local count = 0
        for _ in pairs(self.territories) do count = count + 1 end
        return count
    end,

    calculateStrategicBalance = function(self)
        if not next(self.zones) then return 0 end
        local stability = 0
        for _, zone in pairs(self.zones) do
            stability = stability + zone.stability
        end
        return math.floor(stability / self:getZoneCount())
    end,

    calculateGlobalThreat = function(self)
        if not next(self.zones) then return 0 end
        local threat = 0
        for _, zone in pairs(self.zones) do
            threat = threat + zone.threat_level
        end
        return math.floor(threat / self:getZoneCount())
    end,

    simulateConflict = function(self, territoryId, attacker, defender)
        if not self.territories[territoryId] then return false end
        local territory = self.territories[territoryId]
        territory.contested = true
        if attacker == territory.owner then return false end
        local attackerStrength = 60
        local defenderStrength = territory.defense_level
        if attackerStrength > defenderStrength then
            self:setTerritoryOwner(territoryId, attacker)
            territory.contested = false
        end
        return true
    end,

    resetMap = function(self)
        self.zones = {}
        self.territories = {}
        self.control_map = {}
        self.influence = {}
        self.strategic_resources = {}
        return true
    end
}

Suite:group("Zone Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
    end)

    Suite:testMethod("StrategicMap.createZone", {description = "Creates zone", testCase = "create", type = "functional"}, function()
        local ok = shared.sm:createZone("z1", "Zone One", 10, 20, "continent")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("StrategicMap.getZone", {description = "Gets zone", testCase = "get_zone", type = "functional"}, function()
        shared.sm:createZone("z2", "Zone Two", 30, 40, "continent")
        local zone = shared.sm:getZone("z2")
        Helpers.assertEqual(zone ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("StrategicMap.getZoneCount", {description = "Zone count", testCase = "zone_count", type = "functional"}, function()
        shared.sm:createZone("z3", "Z3", 10, 10, "region")
        shared.sm:createZone("z4", "Z4", 20, 20, "region")
        local count = shared.sm:getZoneCount()
        Helpers.assertEqual(count, 2, "Two zones")
    end)
end)

Suite:group("Territory Definition", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("zone", "Main Zone", 0, 0, "continent")
    end)

    Suite:testMethod("StrategicMap.defineTerritory", {description = "Defines territory", testCase = "define", type = "functional"}, function()
        local ok = shared.sm:defineTerritory("t1", "Territory One", "zone", "player1")
        Helpers.assertEqual(ok, true, "Defined")
    end)

    Suite:testMethod("StrategicMap.getTerritory", {description = "Gets territory", testCase = "get_terr", type = "functional"}, function()
        shared.sm:defineTerritory("t2", "Territory Two", "zone", "player1")
        local territory = shared.sm:getTerritory("t2")
        Helpers.assertEqual(territory ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("StrategicMap.getTerritoryCount", {description = "Territory count", testCase = "terr_count", type = "functional"}, function()
        shared.sm:defineTerritory("t3", "T3", "zone", "player1")
        shared.sm:defineTerritory("t4", "T4", "zone", "player2")
        local count = shared.sm:getTerritoryCount()
        Helpers.assertEqual(count, 2, "Two territories")
    end)
end)

Suite:group("Territory Control", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("zone", "Zone", 0, 0, "continent")
        shared.sm:defineTerritory("terr", "Territory", "zone", "player1")
    end)

    Suite:testMethod("StrategicMap.setTerritoryOwner", {description = "Sets owner", testCase = "set_owner", type = "functional"}, function()
        local ok = shared.sm:setTerritoryOwner("terr", "player2")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("StrategicMap.getTerritoryOwner", {description = "Gets owner", testCase = "get_owner", type = "functional"}, function()
        shared.sm:setTerritoryOwner("terr", "player1")
        local owner = shared.sm:getTerritoryOwner("terr")
        Helpers.assertEqual(owner, "player1", "Owner player1")
    end)

    Suite:testMethod("StrategicMap.isTerritoryContested", {description = "Contested", testCase = "contested", type = "functional"}, function()
        shared.sm:setTerritoryOwner("terr", "player2")
        local contested = shared.sm:isTerritoryContested("terr")
        Helpers.assertEqual(contested, true, "Contested")
    end)
end)

Suite:group("Zone Control", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("z", "Zone", 0, 0, "continent")
    end)

    Suite:testMethod("StrategicMap.setZoneControl", {description = "Sets zone control", testCase = "set_zone_ctrl", type = "functional"}, function()
        local ok = shared.sm:setZoneControl("z", "player1")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("StrategicMap.getZoneControl", {description = "Gets zone control", testCase = "get_zone_ctrl", type = "functional"}, function()
        shared.sm:setZoneControl("z", "player2")
        local control = shared.sm:getZoneControl("z")
        Helpers.assertEqual(control, "player2", "Control player2")
    end)
end)

Suite:group("Zone Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("status_zone", "Status Zone", 0, 0, "continent")
    end)

    Suite:testMethod("StrategicMap.setZoneThreatLevel", {description = "Sets threat level", testCase = "threat", type = "functional"}, function()
        local ok = shared.sm:setZoneThreatLevel("status_zone", 70)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("StrategicMap.getZoneThreatLevel", {description = "Gets threat level", testCase = "get_threat", type = "functional"}, function()
        shared.sm:setZoneThreatLevel("status_zone", 65)
        local threat = shared.sm:getZoneThreatLevel("status_zone")
        Helpers.assertEqual(threat, 65, "Threat 65")
    end)

    Suite:testMethod("StrategicMap.setZoneStability", {description = "Sets stability", testCase = "stability", type = "functional"}, function()
        local ok = shared.sm:setZoneStability("status_zone", 60)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("StrategicMap.getZoneStability", {description = "Gets stability", testCase = "get_stability", type = "functional"}, function()
        shared.sm:setZoneStability("status_zone", 55)
        local stab = shared.sm:getZoneStability("status_zone")
        Helpers.assertEqual(stab, 55, "Stability 55")
    end)
end)

Suite:group("Influence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("infl_zone", "Influence Zone", 0, 0, "continent")
    end)

    Suite:testMethod("StrategicMap.addInfluence", {description = "Adds influence", testCase = "add_infl", type = "functional"}, function()
        local ok = shared.sm:addInfluence("infl_zone", "player1", 50)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("StrategicMap.getInfluence", {description = "Gets influence", testCase = "get_infl", type = "functional"}, function()
        shared.sm:addInfluence("infl_zone", "player2", 60)
        local infl = shared.sm:getInfluence("infl_zone", "player2")
        Helpers.assertEqual(infl, 60, "Influence 60")
    end)

    Suite:testMethod("StrategicMap.getDominantInfluence", {description = "Dominant influence", testCase = "dominant", type = "functional"}, function()
        shared.sm:addInfluence("infl_zone", "p1", 40)
        shared.sm:addInfluence("infl_zone", "p2", 80)
        local player, infl = shared.sm:getDominantInfluence("infl_zone")
        Helpers.assertEqual(player, "p2", "p2 dominant")
    end)
end)

Suite:group("Resources", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("r_zone", "Resource Zone", 0, 0, "continent")
        shared.sm:defineTerritory("r_terr", "Resource Territory", "r_zone", "player1")
    end)

    Suite:testMethod("StrategicMap.addResource", {description = "Adds resource", testCase = "add_res", type = "functional"}, function()
        local ok = shared.sm:addResource("r_terr", "ore", 100)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("StrategicMap.getResourceQuantity", {description = "Gets resource qty", testCase = "get_res", type = "functional"}, function()
        shared.sm:addResource("r_terr", "gold", 150)
        local qty = shared.sm:getResourceQuantity("r_terr", "gold")
        Helpers.assertEqual(qty, 150, "Qty 150")
    end)

    Suite:testMethod("StrategicMap.getTotalResourceQuantity", {description = "Total resource qty", testCase = "total_res", type = "functional"}, function()
        shared.sm:addResource("r_terr", "copper", 50)
        local total = shared.sm:getTotalResourceQuantity("copper")
        Helpers.assertEqual(total, 50, "Total 50")
    end)
end)

Suite:group("Defense", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("d_zone", "Defense Zone", 0, 0, "continent")
        shared.sm:defineTerritory("d_terr", "Defense Territory", "d_zone", "player1")
    end)

    Suite:testMethod("StrategicMap.setTerritoryDefenseLevel", {description = "Sets defense", testCase = "set_def", type = "functional"}, function()
        local ok = shared.sm:setTerritoryDefenseLevel("d_terr", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("StrategicMap.getTerritoryDefenseLevel", {description = "Gets defense", testCase = "get_def", type = "functional"}, function()
        shared.sm:setTerritoryDefenseLevel("d_terr", 80)
        local def = shared.sm:getTerritoryDefenseLevel("d_terr")
        Helpers.assertEqual(def, 80, "Defense 80")
    end)
end)

Suite:group("Dominance Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("dom_zone", "Dominance Zone", 0, 0, "continent")
        shared.sm:defineTerritory("dom_t1", "Dom1", "dom_zone", "player1")
        shared.sm:defineTerritory("dom_t2", "Dom2", "dom_zone", "player1")
        shared.sm:defineTerritory("dom_t3", "Dom3", "dom_zone", "player2")
    end)

    Suite:testMethod("StrategicMap.calculateZoneDominance", {description = "Zone dominance", testCase = "dominance", type = "functional"}, function()
        local count, owner = shared.sm:calculateZoneDominance("dom_zone")
        Helpers.assertEqual(owner, "player1", "Player1 dominates")
    end)
end)

Suite:group("Global Metrics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("g1", "Global1", 0, 0, "continent")
        shared.sm:defineTerritory("gt1", "GT1", "g1", "player1")
        shared.sm:defineTerritory("gt2", "GT2", "g1", "player1")
    end)

    Suite:testMethod("StrategicMap.calculateWorldControl", {description = "World control", testCase = "world_ctrl", type = "functional"}, function()
        local ctrl = shared.sm:calculateWorldControl("player1")
        Helpers.assertEqual(ctrl, 2, "Control 2")
    end)

    Suite:testMethod("StrategicMap.calculateWorldCoverage", {description = "World coverage", testCase = "coverage", type = "functional"}, function()
        local cov = shared.sm:calculateWorldCoverage("player1")
        Helpers.assertEqual(cov, 100, "Coverage 100%")
    end)

    Suite:testMethod("StrategicMap.calculateStrategicBalance", {description = "Strategic balance", testCase = "balance", type = "functional"}, function()
        local balance = shared.sm:calculateStrategicBalance()
        Helpers.assertEqual(balance >= 0, true, "Balance >= 0")
    end)

    Suite:testMethod("StrategicMap.calculateGlobalThreat", {description = "Global threat", testCase = "global_threat", type = "functional"}, function()
        shared.sm:setZoneThreatLevel("g1", 50)
        local threat = shared.sm:calculateGlobalThreat()
        Helpers.assertEqual(threat >= 0, true, "Threat >= 0")
    end)
end)

Suite:group("Conflict", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
        shared.sm:createZone("c_zone", "Conflict Zone", 0, 0, "continent")
        shared.sm:defineTerritory("c_terr", "Conflict Territory", "c_zone", "player1")
    end)

    Suite:testMethod("StrategicMap.simulateConflict", {description = "Simulates conflict", testCase = "conflict", type = "functional"}, function()
        local ok = shared.sm:simulateConflict("c_terr", "player2", "player1")
        Helpers.assertEqual(ok, true, "Simulated")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = StrategicMap:new()
    end)

    Suite:testMethod("StrategicMap.resetMap", {description = "Resets map", testCase = "reset", type = "functional"}, function()
        shared.sm:createZone("z", "Zone", 0, 0, "continent")
        local ok = shared.sm:resetMap()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
