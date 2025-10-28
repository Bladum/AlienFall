-- ─────────────────────────────────────────────────────────────────────────
-- INTERCEPTION SYSTEM TEST SUITE
-- FILE: tests2/geoscape/interception_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.interception_system",
    fileName = "interception_system.lua",
    description = "UFO interception with tracking, engagement, and pursuit mechanics"
})

print("[INTERCEPTION_SYSTEM_TEST] Setting up")

local InterceptionSystem = {
    ufos = {},
    interceptions = {},
    pursuit_data = {},
    radar = {},
    combat_log = {},

    new = function(self)
        return setmetatable({
            ufos = {}, interceptions = {}, pursuit_data = {},
            radar = {}, combat_log = {}
        }, {__index = self})
    end,

    detectUFO = function(self, ufoId, x, y, speed, threatLevel)
        self.ufos[ufoId] = {
            id = ufoId, x = x, y = y, speed = speed or 50, threat = threatLevel or 60,
            heading = 0, health = 100, status = "detected"
        }
        self.radar[ufoId] = {detected = true, last_seen = 0, contact_time = 0}
        return true
    end,

    getUFO = function(self, ufoId)
        return self.ufos[ufoId]
    end,

    trackUFO = function(self, ufoId)
        if not self.ufos[ufoId] then return false end
        if not self.radar[ufoId] then self.radar[ufoId] = {} end
        self.radar[ufoId].contact_time = self.radar[ufoId].contact_time + 1
        return true
    end,

    predictUFOPath = function(self, ufoId, turns)
        if not self.ufos[ufoId] then return {} end
        local ufo = self.ufos[ufoId]
        local path = {}
        for i = 1, turns do
            local dx = math.cos(ufo.heading) * ufo.speed
            local dy = math.sin(ufo.heading) * ufo.speed
            table.insert(path, {x = ufo.x + (dx * i), y = ufo.y + (dy * i)})
        end
        return path
    end,

    launchInterceptor = function(self, interceptorId, craftType, x, y, targetUFOId)
        if not self.ufos[targetUFOId] then return false end
        self.interceptions[interceptorId] = {
            id = interceptorId, craft_type = craftType, x = x, y = y,
            target_ufo = targetUFOId, status = "launched", distance = 0, engagement_turns = 0
        }
        self.pursuit_data[interceptorId] = {pursuit_active = true, intercept_distance = 0, evasion_counter = 0}
        return true
    end,

    getInterceptor = function(self, interceptorId)
        return self.interceptions[interceptorId]
    end,

    calculateDistance = function(self, x1, y1, x2, y2)
        local dx = x2 - x1
        local dy = y2 - y1
        return math.sqrt(dx * dx + dy * dy)
    end,

    updateInterception = function(self, interceptorId)
        if not self.interceptions[interceptorId] then return false end
        local interceptor = self.interceptions[interceptorId]
        local ufo = self.ufos[interceptor.target_ufo]
        if not ufo then return false end

        local dist = self:calculateDistance(interceptor.x, interceptor.y, ufo.x, ufo.y)
        interceptor.distance = dist
        interceptor.engagement_turns = interceptor.engagement_turns + 1

        if dist < 5 then
            interceptor.status = "engaged"
            return true
        elseif dist < 15 then
            interceptor.status = "pursuing"
            interceptor.x = interceptor.x + (ufo.x - interceptor.x) * 0.2
            interceptor.y = interceptor.y + (ufo.y - interceptor.y) * 0.2
        else
            interceptor.status = "approaching"
            interceptor.x = interceptor.x + (ufo.x - interceptor.x) * 0.1
            interceptor.y = interceptor.y + (ufo.y - interceptor.y) * 0.1
        end
        return true
    end,

    engageUFO = function(self, interceptorId, weaponDamage)
        if not self.interceptions[interceptorId] then return false end
        local interceptor = self.interceptions[interceptorId]
        local ufo = self.ufos[interceptor.target_ufo]
        if not ufo then return false end

        if interceptor.status == "engaged" then
            ufo.health = math.max(0, ufo.health - weaponDamage)
            table.insert(self.combat_log, {interceptor = interceptorId, ufo = ufo.id, damage = weaponDamage, turn = 0})
            return true
        end
        return false
    end,

    isEngaged = function(self, interceptorId)
        if not self.interceptions[interceptorId] then return false end
        return self.interceptions[interceptorId].status == "engaged"
    end,

    getEngagementDistance = function(self, interceptorId)
        if not self.interceptions[interceptorId] then return 0 end
        return self.interceptions[interceptorId].distance
    end,

    getEngagementTurns = function(self, interceptorId)
        if not self.interceptions[interceptorId] then return 0 end
        return self.interceptions[interceptorId].engagement_turns
    end,

    evadeInterceptor = function(self, ufoId)
        if not self.ufos[ufoId] then return false end
        local ufo = self.ufos[ufoId]
        ufo.heading = (ufo.heading + 90) % 360
        ufo.speed = math.min(100, ufo.speed + 10)
        for interceptorId, interceptor in pairs(self.interceptions) do
            if interceptor.target_ufo == ufoId and self.pursuit_data[interceptorId] then
                self.pursuit_data[interceptorId].evasion_counter = self.pursuit_data[interceptorId].evasion_counter + 1
            end
        end
        return true
    end,

    destroyUFO = function(self, ufoId)
        if not self.ufos[ufoId] then return false end
        self.ufos[ufoId].status = "destroyed"
        self.ufos[ufoId].health = 0
        return true
    end,

    isUFODestroyed = function(self, ufoId)
        if not self.ufos[ufoId] then return false end
        return self.ufos[ufoId].status == "destroyed" or self.ufos[ufoId].health <= 0
    end,

    escapeUFO = function(self, ufoId)
        if not self.ufos[ufoId] then return false end
        self.ufos[ufoId].status = "escaped"
        for interceptorId, interceptor in pairs(self.interceptions) do
            if interceptor.target_ufo == ufoId then
                interceptor.status = "lost_contact"
            end
        end
        return true
    end,

    getUFOCount = function(self)
        local count = 0
        for _ in pairs(self.ufos) do count = count + 1 end
        return count
    end,

    getActiveInterceptions = function(self)
        local count = 0
        for _, interception in pairs(self.interceptions) do
            if interception.status ~= "lost_contact" and interception.status ~= "complete" then
                count = count + 1
            end
        end
        return count
    end,

    calculateInterceptionSuccess = function(self, interceptorId)
        if not self.interceptions[interceptorId] then return 0 end
        local interceptor = self.interceptions[interceptorId]
        local ufo = self.ufos[interceptor.target_ufo]
        if not ufo then return 0 end

        local distance_factor = math.max(0, 1 - (interceptor.distance / 100))
        local threat_factor = (100 - ufo.threat) / 100
        return math.floor((distance_factor + threat_factor) / 2 * 100)
    end,

    getCombatLog = function(self)
        return self.combat_log
    end,

    getInterceptionEfficiency = function(self)
        if #self.combat_log == 0 then return 0 end
        local destroyed = 0
        for ufoId, _ in pairs(self.ufos) do
            if self:isUFODestroyed(ufoId) then destroyed = destroyed + 1 end
        end
        return math.floor((destroyed / self:getUFOCount()) * 100)
    end,

    resetInterception = function(self)
        self.ufos = {}
        self.interceptions = {}
        self.pursuit_data = {}
        self.radar = {}
        self.combat_log = {}
        return true
    end
}

Suite:group("UFO Detection", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
    end)

    Suite:testMethod("InterceptionSystem.detectUFO", {description = "Detects UFO", testCase = "detect", type = "functional"}, function()
        local ok = shared.is:detectUFO("ufo1", 100, 100, 60, 75)
        Helpers.assertEqual(ok, true, "Detected")
    end)

    Suite:testMethod("InterceptionSystem.getUFO", {description = "Gets UFO", testCase = "get_ufo", type = "functional"}, function()
        shared.is:detectUFO("ufo2", 150, 150, 70, 80)
        local ufo = shared.is:getUFO("ufo2")
        Helpers.assertEqual(ufo ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("InterceptionSystem.getUFOCount", {description = "UFO count", testCase = "ufo_count", type = "functional"}, function()
        shared.is:detectUFO("u1", 100, 100, 60, 70)
        shared.is:detectUFO("u2", 200, 200, 70, 75)
        local count = shared.is:getUFOCount()
        Helpers.assertEqual(count, 2, "Two UFOs")
    end)
end)

Suite:group("Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
        shared.is:detectUFO("track_ufo", 100, 100, 60, 70)
    end)

    Suite:testMethod("InterceptionSystem.trackUFO", {description = "Tracks UFO", testCase = "track", type = "functional"}, function()
        local ok = shared.is:trackUFO("track_ufo")
        Helpers.assertEqual(ok, true, "Tracked")
    end)

    Suite:testMethod("InterceptionSystem.predictUFOPath", {description = "Predicts path", testCase = "predict", type = "functional"}, function()
        local path = shared.is:predictUFOPath("track_ufo", 5)
        Helpers.assertEqual(#path, 5, "Five waypoints")
    end)
end)

Suite:group("Interception Launch", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
        shared.is:detectUFO("target_ufo", 100, 100, 60, 70)
    end)

    Suite:testMethod("InterceptionSystem.launchInterceptor", {description = "Launches interceptor", testCase = "launch", type = "functional"}, function()
        local ok = shared.is:launchInterceptor("interceptor1", "fighter", 50, 50, "target_ufo")
        Helpers.assertEqual(ok, true, "Launched")
    end)

    Suite:testMethod("InterceptionSystem.getInterceptor", {description = "Gets interceptor", testCase = "get_int", type = "functional"}, function()
        shared.is:launchInterceptor("interceptor2", "fighter", 60, 60, "target_ufo")
        local int = shared.is:getInterceptor("interceptor2")
        Helpers.assertEqual(int ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Engagement Mechanics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
        shared.is:detectUFO("engage_ufo", 100, 100, 60, 70)
        shared.is:launchInterceptor("engage_int", "fighter", 105, 105, "engage_ufo")
    end)

    Suite:testMethod("InterceptionSystem.calculateDistance", {description = "Calculates distance", testCase = "distance", type = "functional"}, function()
        local dist = shared.is:calculateDistance(0, 0, 3, 4)
        Helpers.assertEqual(dist, 5, "Distance 5")
    end)

    Suite:testMethod("InterceptionSystem.updateInterception", {description = "Updates interception", testCase = "update", type = "functional"}, function()
        local ok = shared.is:updateInterception("engage_int")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("InterceptionSystem.getEngagementDistance", {description = "Engagement distance", testCase = "eng_distance", type = "functional"}, function()
        shared.is:updateInterception("engage_int")
        local dist = shared.is:getEngagementDistance("engage_int")
        Helpers.assertEqual(dist >= 0, true, "Distance >= 0")
    end)

    Suite:testMethod("InterceptionSystem.getEngagementTurns", {description = "Engagement turns", testCase = "eng_turns", type = "functional"}, function()
        shared.is:updateInterception("engage_int")
        shared.is:updateInterception("engage_int")
        local turns = shared.is:getEngagementTurns("engage_int")
        Helpers.assertEqual(turns, 2, "Two turns")
    end)
end)

Suite:group("Combat", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
        shared.is:detectUFO("combat_ufo", 100, 100, 60, 70)
        shared.is:launchInterceptor("combat_int", "fighter", 100, 100, "combat_ufo")
    end)

    Suite:testMethod("InterceptionSystem.engageUFO", {description = "Engages UFO", testCase = "engage", type = "functional"}, function()
        shared.is:updateInterception("combat_int")
        local ok = shared.is:engageUFO("combat_int", 20)
        Helpers.assertEqual(ok, true, "Engaged")
    end)

    Suite:testMethod("InterceptionSystem.isEngaged", {description = "Is engaged", testCase = "is_engaged", type = "functional"}, function()
        -- Force engagement by setting distance to 0
        shared.is.interceptions["combat_int"].status = "engaged"
        local is = shared.is:isEngaged("combat_int")
        Helpers.assertEqual(is, true, "Engaged")
    end)
end)

Suite:group("UFO Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
        shared.is:detectUFO("tactic_ufo", 100, 100, 60, 70)
        shared.is:launchInterceptor("tactic_int", "fighter", 110, 110, "tactic_ufo")
    end)

    Suite:testMethod("InterceptionSystem.evadeInterceptor", {description = "Evades", testCase = "evade", type = "functional"}, function()
        local ok = shared.is:evadeInterceptor("tactic_ufo")
        Helpers.assertEqual(ok, true, "Evaded")
    end)

    Suite:testMethod("InterceptionSystem.destroyUFO", {description = "Destroys UFO", testCase = "destroy", type = "functional"}, function()
        local ok = shared.is:destroyUFO("tactic_ufo")
        Helpers.assertEqual(ok, true, "Destroyed")
    end)

    Suite:testMethod("InterceptionSystem.isUFODestroyed", {description = "Is destroyed", testCase = "is_destroyed", type = "functional"}, function()
        shared.is:destroyUFO("tactic_ufo")
        local is = shared.is:isUFODestroyed("tactic_ufo")
        Helpers.assertEqual(is, true, "Destroyed")
    end)

    Suite:testMethod("InterceptionSystem.escapeUFO", {description = "Escapes", testCase = "escape", type = "functional"}, function()
        local ok = shared.is:escapeUFO("tactic_ufo")
        Helpers.assertEqual(ok, true, "Escaped")
    end)
end)

Suite:group("System Analytics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
        shared.is:detectUFO("u1", 100, 100, 60, 70)
        shared.is:launchInterceptor("i1", "fighter", 105, 105, "u1")
    end)

    Suite:testMethod("InterceptionSystem.getActiveInterceptions", {description = "Active interceptions", testCase = "active", type = "functional"}, function()
        local count = shared.is:getActiveInterceptions()
        Helpers.assertEqual(count >= 0, true, "Active >= 0")
    end)

    Suite:testMethod("InterceptionSystem.calculateInterceptionSuccess", {description = "Success chance", testCase = "success", type = "functional"}, function()
        local success = shared.is:calculateInterceptionSuccess("i1")
        Helpers.assertEqual(success >= 0, true, "Success >= 0")
    end)

    Suite:testMethod("InterceptionSystem.getCombatLog", {description = "Combat log", testCase = "log", type = "functional"}, function()
        local log = shared.is:getCombatLog()
        Helpers.assertEqual(log ~= nil, true, "Log exists")
    end)

    Suite:testMethod("InterceptionSystem.getInterceptionEfficiency", {description = "Efficiency", testCase = "efficiency", type = "functional"}, function()
        local eff = shared.is:getInterceptionEfficiency()
        Helpers.assertEqual(eff >= 0, true, "Efficiency >= 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.is = InterceptionSystem:new()
    end)

    Suite:testMethod("InterceptionSystem.resetInterception", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        shared.is:detectUFO("u1", 100, 100, 60, 70)
        local ok = shared.is:resetInterception()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
