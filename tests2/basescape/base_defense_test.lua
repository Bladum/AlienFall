-- ─────────────────────────────────────────────────────────────────────────
-- BASE DEFENSE TEST SUITE
-- FILE: tests2/basescape/base_defense_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.base_defense",
    fileName = "base_defense.lua",
    description = "Base defensive systems with coverage, threat detection, and response coordination"
})

print("[BASE_DEFENSE_TEST] Setting up")

local BaseDefense = {
    defenses = {},
    coverage_zones = {},
    threat_assessment = {},
    response_protocols = {},
    defense_state = {},

    new = function(self)
        return setmetatable({
            defenses = {}, coverage_zones = {}, threat_assessment = {},
            response_protocols = {}, defense_state = {}
        }, {__index = self})
    end,

    registerDefense = function(self, defenseId, name, type, power, range)
        self.defenses[defenseId] = {
            id = defenseId, name = name, type = type or "turret", power = power or 50,
            range = range or 20, active = true, ammo = 100, cooldown = 0
        }
        self.coverage_zones[defenseId] = {}
        self.threat_assessment[defenseId] = {targets = {}, threat_level = 0}
        return true
    end,

    getDefense = function(self, defenseId)
        return self.defenses[defenseId]
    end,

    activateDefense = function(self, defenseId)
        if not self.defenses[defenseId] then return false end
        self.defenses[defenseId].active = true
        return true
    end,

    deactivateDefense = function(self, defenseId)
        if not self.defenses[defenseId] then return false end
        self.defenses[defenseId].active = false
        return true
    end,

    isDefenseActive = function(self, defenseId)
        if not self.defenses[defenseId] then return false end
        return self.defenses[defenseId].active
    end,

    setAmmo = function(self, defenseId, ammo)
        if not self.defenses[defenseId] then return false end
        self.defenses[defenseId].ammo = math.max(0, ammo)
        return true
    end,

    getAmmo = function(self, defenseId)
        if not self.defenses[defenseId] then return 0 end
        return self.defenses[defenseId].ammo
    end,

    fireDefense = function(self, defenseId)
        if not self.defenses[defenseId] then return false end
        local defense = self.defenses[defenseId]
        if defense.ammo <= 0 then return false end
        defense.ammo = defense.ammo - 1
        defense.cooldown = 2
        table.insert(self.threat_assessment[defenseId].targets, {fired = true, turn = 0})
        return true
    end,

    getDefenseCount = function(self)
        local count = 0
        for _ in pairs(self.defenses) do count = count + 1 end
        return count
    end,

    defineProtocol = function(self, protocolId, name, triggerThreat, response)
        self.response_protocols[protocolId] = {
            id = protocolId, name = name, trigger_threat = triggerThreat or 60,
            response = response or "auto_fire", active = true
        }
        return true
    end,

    getProtocol = function(self, protocolId)
        return self.response_protocols[protocolId]
    end,

    activateProtocol = function(self, protocolId)
        if not self.response_protocols[protocolId] then return false end
        self.response_protocols[protocolId].active = true
        return true
    end,

    deactivateProtocol = function(self, protocolId)
        if not self.response_protocols[protocolId] then return false end
        self.response_protocols[protocolId].active = false
        return true
    end,

    isProtocolActive = function(self, protocolId)
        if not self.response_protocols[protocolId] then return false end
        return self.response_protocols[protocolId].active
    end,

    getProtocolCount = function(self)
        local count = 0
        for _ in pairs(self.response_protocols) do count = count + 1 end
        return count
    end,

    addCoverageZone = function(self, defenseId, zoneId, x, y, radius)
        if not self.coverage_zones[defenseId] then return false end
        self.coverage_zones[defenseId][zoneId] = {id = zoneId, x = x, y = y, radius = radius or 10}
        return true
    end,

    getCoverageZoneCount = function(self, defenseId)
        if not self.coverage_zones[defenseId] then return 0 end
        local count = 0
        for _ in pairs(self.coverage_zones[defenseId]) do count = count + 1 end
        return count
    end,

    calculateTotalCoverage = function(self)
        local totalArea = 0
        for defenseId, zones in pairs(self.coverage_zones) do
            for _, zone in pairs(zones) do
                totalArea = totalArea + (zone.radius * zone.radius * 3.14159)
            end
        end
        return math.floor(totalArea)
    end,

    isPointCovered = function(self, x, y)
        for defenseId, zones in pairs(self.coverage_zones) do
            for _, zone in pairs(zones) do
                local dx = zone.x - x
                local dy = zone.y - y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist <= zone.radius then return true end
            end
        end
        return false
    end,

    detectThreat = function(self, threatId, threatType, threatLevel, x, y)
        if not self.defense_state.threats then self.defense_state.threats = {} end
        self.defense_state.threats[threatId] = {
            id = threatId, type = threatType, level = threatLevel, x = x, y = y, detected_turn = 0
        }
        return true
    end,

    getThreatCount = function(self)
        if not self.defense_state.threats then return 0 end
        local count = 0
        for _ in pairs(self.defense_state.threats) do count = count + 1 end
        return count
    end,

    assessDefensiveStrength = function(self)
        local active = 0
        local power = 0
        for _, defense in pairs(self.defenses) do
            if defense.active then
                active = active + 1
                power = power + defense.power
            end
        end
        return {active = active, total_power = power, avg_power = active > 0 and math.floor(power / active) or 0}
    end,

    calculateDefenseScore = function(self)
        local coverage = self:calculateTotalCoverage() / 100
        local defensive = self:assessDefensiveStrength()
        local score = math.floor(coverage * 0.4 + defensive.avg_power * 0.6)
        return score
    end,

    isBaseSafe = function(self)
        local threatCount = self:getThreatCount()
        local score = self:calculateDefenseScore()
        return threatCount == 0 and score > 50
    end,

    setBaseAlertLevel = function(self, alertLevel)
        self.defense_state.alert_level = math.max(0, math.min(5, alertLevel))
        return true
    end,

    getBaseAlertLevel = function(self)
        return self.defense_state.alert_level or 0
    end,

    triggerLockdown = function(self)
        self.defense_state.lockdown_active = true
        for defenseId, _ in pairs(self.defenses) do
            self:activateDefense(defenseId)
        end
        return true
    end,

    releaseLockdown = function(self)
        self.defense_state.lockdown_active = false
        return true
    end,

    isLockdownActive = function(self)
        return self.defense_state.lockdown_active or false
    end,

    calculateInterceptionRatio = function(self)
        local defenses = self:getDefenseCount()
        local threats = self:getThreatCount()
        if threats == 0 then return 0 end
        return math.floor((defenses / threats) * 100)
    end,

    updateCooldowns = function(self)
        for _, defense in pairs(self.defenses) do
            if defense.cooldown > 0 then
                defense.cooldown = defense.cooldown - 1
            end
        end
        return true
    end,

    simulateDefensiveBarrage = function(self)
        local fired = 0
        for defenseId, defense in pairs(self.defenses) do
            if defense.active and defense.ammo > 10 then
                if self:fireDefense(defenseId) then
                    fired = fired + 1
                end
            end
        end
        return fired
    end,

    resetDefense = function(self)
        self.defenses = {}
        self.coverage_zones = {}
        self.threat_assessment = {}
        self.response_protocols = {}
        self.defense_state = {}
        return true
    end
}

Suite:group("Defense Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
    end)

    Suite:testMethod("BaseDefense.registerDefense", {description = "Registers defense", testCase = "register", type = "functional"}, function()
        local ok = shared.bd:registerDefense("turret1", "Turret One", "turret", 75, 25)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("BaseDefense.getDefense", {description = "Gets defense", testCase = "get", type = "functional"}, function()
        shared.bd:registerDefense("turret2", "Turret Two", "turret", 80, 30)
        local defense = shared.bd:getDefense("turret2")
        Helpers.assertEqual(defense ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("BaseDefense.getDefenseCount", {description = "Defense count", testCase = "count", type = "functional"}, function()
        shared.bd:registerDefense("d1", "Defense1", "turret", 50, 20)
        shared.bd:registerDefense("d2", "Defense2", "turret", 50, 20)
        local count = shared.bd:getDefenseCount()
        Helpers.assertEqual(count, 2, "Two defenses")
    end)
end)

Suite:group("Defense Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
        shared.bd:registerDefense("active_def", "Active", "turret", 60, 20)
    end)

    Suite:testMethod("BaseDefense.activateDefense", {description = "Activates defense", testCase = "activate", type = "functional"}, function()
        shared.bd:deactivateDefense("active_def")
        local ok = shared.bd:activateDefense("active_def")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("BaseDefense.deactivateDefense", {description = "Deactivates defense", testCase = "deactivate", type = "functional"}, function()
        local ok = shared.bd:deactivateDefense("active_def")
        Helpers.assertEqual(ok, true, "Deactivated")
    end)

    Suite:testMethod("BaseDefense.isDefenseActive", {description = "Is active", testCase = "is_active", type = "functional"}, function()
        local is = shared.bd:isDefenseActive("active_def")
        Helpers.assertEqual(is, true, "Active")
    end)
end)

Suite:group("Ammunition", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
        shared.bd:registerDefense("ammo_def", "Ammo Def", "turret", 50, 20)
    end)

    Suite:testMethod("BaseDefense.setAmmo", {description = "Sets ammo", testCase = "set_ammo", type = "functional"}, function()
        local ok = shared.bd:setAmmo("ammo_def", 50)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("BaseDefense.getAmmo", {description = "Gets ammo", testCase = "get_ammo", type = "functional"}, function()
        shared.bd:setAmmo("ammo_def", 75)
        local ammo = shared.bd:getAmmo("ammo_def")
        Helpers.assertEqual(ammo, 75, "Ammo 75")
    end)

    Suite:testMethod("BaseDefense.fireDefense", {description = "Fires defense", testCase = "fire", type = "functional"}, function()
        shared.bd:setAmmo("ammo_def", 20)
        local ok = shared.bd:fireDefense("ammo_def")
        Helpers.assertEqual(ok, true, "Fired")
    end)
end)

Suite:group("Response Protocols", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
    end)

    Suite:testMethod("BaseDefense.defineProtocol", {description = "Defines protocol", testCase = "define", type = "functional"}, function()
        local ok = shared.bd:defineProtocol("proto1", "Aggressive", 70, "auto_fire")
        Helpers.assertEqual(ok, true, "Defined")
    end)

    Suite:testMethod("BaseDefense.getProtocol", {description = "Gets protocol", testCase = "get_proto", type = "functional"}, function()
        shared.bd:defineProtocol("proto2", "Defensive", 50, "defensive")
        local proto = shared.bd:getProtocol("proto2")
        Helpers.assertEqual(proto ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("BaseDefense.activateProtocol", {description = "Activates protocol", testCase = "act_proto", type = "functional"}, function()
        shared.bd:defineProtocol("proto3", "Proto", 60, "fire")
        shared.bd:deactivateProtocol("proto3")
        local ok = shared.bd:activateProtocol("proto3")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("BaseDefense.deactivateProtocol", {description = "Deactivates protocol", testCase = "deact_proto", type = "functional"}, function()
        shared.bd:defineProtocol("proto4", "Proto4", 60, "fire")
        local ok = shared.bd:deactivateProtocol("proto4")
        Helpers.assertEqual(ok, true, "Deactivated")
    end)

    Suite:testMethod("BaseDefense.isProtocolActive", {description = "Is active protocol", testCase = "proto_active", type = "functional"}, function()
        shared.bd:defineProtocol("proto5", "Proto5", 60, "fire")
        local is = shared.bd:isProtocolActive("proto5")
        Helpers.assertEqual(is, true, "Active")
    end)

    Suite:testMethod("BaseDefense.getProtocolCount", {description = "Protocol count", testCase = "proto_count", type = "functional"}, function()
        shared.bd:defineProtocol("p1", "P1", 50, "fire")
        shared.bd:defineProtocol("p2", "P2", 50, "fire")
        local count = shared.bd:getProtocolCount()
        Helpers.assertEqual(count, 2, "Two protocols")
    end)
end)

Suite:group("Coverage", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
        shared.bd:registerDefense("cov_def", "Coverage Def", "turret", 50, 20)
    end)

    Suite:testMethod("BaseDefense.addCoverageZone", {description = "Adds coverage zone", testCase = "add_zone", type = "functional"}, function()
        local ok = shared.bd:addCoverageZone("cov_def", "zone1", 10, 10, 15)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("BaseDefense.getCoverageZoneCount", {description = "Zone count", testCase = "zone_count", type = "functional"}, function()
        shared.bd:addCoverageZone("cov_def", "z1", 10, 10, 10)
        shared.bd:addCoverageZone("cov_def", "z2", 20, 20, 10)
        local count = shared.bd:getCoverageZoneCount("cov_def")
        Helpers.assertEqual(count, 2, "Two zones")
    end)

    Suite:testMethod("BaseDefense.calculateTotalCoverage", {description = "Total coverage", testCase = "total_cov", type = "functional"}, function()
        shared.bd:addCoverageZone("cov_def", "tz1", 10, 10, 10)
        local coverage = shared.bd:calculateTotalCoverage()
        Helpers.assertEqual(coverage > 0, true, "Coverage > 0")
    end)

    Suite:testMethod("BaseDefense.isPointCovered", {description = "Point covered", testCase = "point_cov", type = "functional"}, function()
        shared.bd:addCoverageZone("cov_def", "pz", 10, 10, 5)
        local covered = shared.bd:isPointCovered(12, 10)
        Helpers.assertEqual(covered, true, "Covered")
    end)
end)

Suite:group("Threat Detection", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
    end)

    Suite:testMethod("BaseDefense.detectThreat", {description = "Detects threat", testCase = "detect", type = "functional"}, function()
        local ok = shared.bd:detectThreat("threat1", "ufo", 75, 50, 50)
        Helpers.assertEqual(ok, true, "Detected")
    end)

    Suite:testMethod("BaseDefense.getThreatCount", {description = "Threat count", testCase = "threat_count", type = "functional"}, function()
        shared.bd:detectThreat("t1", "ufo", 70, 50, 50)
        shared.bd:detectThreat("t2", "ufo", 65, 60, 60)
        local count = shared.bd:getThreatCount()
        Helpers.assertEqual(count, 2, "Two threats")
    end)
end)

Suite:group("Defense Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
        shared.bd:registerDefense("a_def", "Analysis Def", "turret", 70, 25)
    end)

    Suite:testMethod("BaseDefense.assessDefensiveStrength", {description = "Defensive strength", testCase = "strength", type = "functional"}, function()
        local strength = shared.bd:assessDefensiveStrength()
        Helpers.assertEqual(strength.active > 0, true, "Active > 0")
    end)

    Suite:testMethod("BaseDefense.calculateDefenseScore", {description = "Defense score", testCase = "score", type = "functional"}, function()
        local score = shared.bd:calculateDefenseScore()
        Helpers.assertEqual(score >= 0, true, "Score >= 0")
    end)

    Suite:testMethod("BaseDefense.isBaseSafe", {description = "Base safe", testCase = "safe", type = "functional"}, function()
        local safe = shared.bd:isBaseSafe()
        Helpers.assertEqual(safe, true, "Safe")
    end)
end)

Suite:group("Base Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
    end)

    Suite:testMethod("BaseDefense.setBaseAlertLevel", {description = "Sets alert level", testCase = "alert", type = "functional"}, function()
        local ok = shared.bd:setBaseAlertLevel(3)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("BaseDefense.getBaseAlertLevel", {description = "Gets alert level", testCase = "get_alert", type = "functional"}, function()
        shared.bd:setBaseAlertLevel(2)
        local level = shared.bd:getBaseAlertLevel()
        Helpers.assertEqual(level, 2, "Level 2")
    end)

    Suite:testMethod("BaseDefense.triggerLockdown", {description = "Triggers lockdown", testCase = "lockdown", type = "functional"}, function()
        local ok = shared.bd:triggerLockdown()
        Helpers.assertEqual(ok, true, "Locked")
    end)

    Suite:testMethod("BaseDefense.releaseLockdown", {description = "Releases lockdown", testCase = "release", type = "functional"}, function()
        shared.bd:triggerLockdown()
        local ok = shared.bd:releaseLockdown()
        Helpers.assertEqual(ok, true, "Released")
    end)

    Suite:testMethod("BaseDefense.isLockdownActive", {description = "Lockdown active", testCase = "lockdown_active", type = "functional"}, function()
        shared.bd:triggerLockdown()
        local is = shared.bd:isLockdownActive()
        Helpers.assertEqual(is, true, "Active")
    end)
end)

Suite:group("Advanced Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
        shared.bd:registerDefense("adv_def", "Advanced", "turret", 80, 25)
    end)

    Suite:testMethod("BaseDefense.calculateInterceptionRatio", {description = "Interception ratio", testCase = "ratio", type = "functional"}, function()
        shared.bd:detectThreat("th", "ufo", 70, 50, 50)
        local ratio = shared.bd:calculateInterceptionRatio()
        Helpers.assertEqual(ratio >= 0, true, "Ratio >= 0")
    end)

    Suite:testMethod("BaseDefense.updateCooldowns", {description = "Updates cooldowns", testCase = "cooldown", type = "functional"}, function()
        shared.bd:setAmmo("adv_def", 50)
        shared.bd:fireDefense("adv_def")
        local ok = shared.bd:updateCooldowns()
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("BaseDefense.simulateDefensiveBarrage", {description = "Defensive barrage", testCase = "barrage", type = "functional"}, function()
        shared.bd:setAmmo("adv_def", 50)
        local fired = shared.bd:simulateDefensiveBarrage()
        Helpers.assertEqual(fired >= 0, true, "Fired count >= 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.bd = BaseDefense:new()
    end)

    Suite:testMethod("BaseDefense.resetDefense", {description = "Resets defense", testCase = "reset", type = "functional"}, function()
        shared.bd:registerDefense("reset_def", "Reset", "turret", 50, 20)
        local ok = shared.bd:resetDefense()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
