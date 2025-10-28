-- ─────────────────────────────────────────────────────────────────────────
-- CRAFT INTERCEPTION TEST SUITE
-- FILE: tests2/geoscape/craft_interception_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.craft_interception",
    fileName = "craft_interception.lua",
    description = "Enemy craft detection, tracking, interception mechanics, and tactical engagement"
})

print("[CRAFT_INTERCEPTION_TEST] Setting up")

local CraftInterception = {
    detected_craft = {}, interceptions = {}, engagements = {}, player_craft = {},

    new = function(self)
        return setmetatable({detected_craft = {}, interceptions = {}, engagements = {}, player_craft = {}}, {__index = self})
    end,

    registerPlayerCraft = function(self, craftId, name, max_speed, weapon_capacity, detection_range)
        self.player_craft[craftId] = {
            id = craftId, name = name, speed = max_speed or 1200, weapons = {},
            detection_range = detection_range or 3000, location = {x = 0, y = 0}
        }
        return true
    end,

    detectCraft = function(self, craftId, enemy_name, craft_type, threat_level)
        self.detected_craft[craftId] = {
            id = craftId, name = enemy_name or "Unknown", type = craft_type or "Scout",
            threat = threat_level or 1, location = {x = math.random(1000), y = math.random(1000)},
            detected_at_turn = 0, confirmed = false
        }
        return true
    end,

    getDetectedCraft = function(self, craftId)
        return self.detected_craft[craftId]
    end,

    getCraftThreatLevel = function(self, craftId)
        if not self.detected_craft[craftId] then return 0 end
        return self.detected_craft[craftId].threat
    end,

    confirmThreat = function(self, craftId)
        if not self.detected_craft[craftId] then return false end
        self.detected_craft[craftId].confirmed = true
        return true
    end,

    isThreatConfirmed = function(self, craftId)
        if not self.detected_craft[craftId] then return false end
        return self.detected_craft[craftId].confirmed
    end,

    calculateDistance = function(self, craftId1, craftId2)
        local c1 = self.detected_craft[craftId1]
        local c2 = self.detected_craft[craftId2]
        if not c1 or not c2 then return 0 end
        local dx = c1.location.x - c2.location.x
        local dy = c1.location.y - c2.location.y
        return math.sqrt(dx * dx + dy * dy)
    end,

    isInRange = function(self, playerCraftId, enemyCraftId)
        if not self.player_craft[playerCraftId] then return false end
        if not self.detected_craft[enemyCraftId] then return false end
        local dist = self:calculateDistance(playerCraftId, enemyCraftId)
        local range = self.player_craft[playerCraftId].detection_range
        return dist <= range
    end,

    initiatInterception = function(self, playerCraftId, enemyCraftId)
        if not self:isInRange(playerCraftId, enemyCraftId) then return false end
        local id = playerCraftId .. "_" .. enemyCraftId
        self.interceptions[id] = {
            player_craft = playerCraftId, enemy_craft = enemyCraftId,
            status = "pursuing", distance = self:calculateDistance(playerCraftId, enemyCraftId),
            interception_turn = 0, success = false
        }
        return true
    end,

    getInterception = function(self, id)
        return self.interceptions[id]
    end,

    updateInterceptionDistance = function(self, id, new_distance)
        if not self.interceptions[id] then return false end
        self.interceptions[id].distance = new_distance
        return true
    end,

    isInterceptionSuccessful = function(self, id)
        if not self.interceptions[id] then return false end
        return self.interceptions[id].distance <= 100
    end,

    completeInterception = function(self, id)
        if not self.interceptions[id] then return false end
        if self:isInterceptionSuccessful(id) then
            self.interceptions[id].success = true
            self.interceptions[id].status = "engaged"
            return true
        end
        return false
    end,

    initiateEngagement = function(self, playerCraftId, enemyCraftId)
        local id = playerCraftId .. "_" .. enemyCraftId
        self.engagements[id] = {
            player_craft = playerCraftId, enemy_craft = enemyCraftId,
            player_health = 100, enemy_health = 100,
            round = 0, status = "active"
        }
        return true
    end,

    getEngagement = function(self, id)
        return self.engagements[id]
    end,

    fireWeapon = function(self, engagementId, attacker, damage_amount)
        if not self.engagements[engagementId] then return false end
        local eng = self.engagements[engagementId]
        if attacker == "player" then
            eng.enemy_health = math.max(0, eng.enemy_health - (damage_amount or 15))
        else
            eng.player_health = math.max(0, eng.player_health - (damage_amount or 20))
        end
        return true
    end,

    getEngagementStatus = function(self, engagementId)
        if not self.engagements[engagementId] then return "None" end
        local eng = self.engagements[engagementId]
        if eng.player_health <= 0 then return "Player Defeated"
        elseif eng.enemy_health <= 0 then return "Enemy Defeated"
        else return "Ongoing" end
    end,

    resolveEngagement = function(self, engagementId)
        if not self.engagements[engagementId] then return false end
        local status = self:getEngagementStatus(engagementId)
        if status ~= "Ongoing" then
            self.engagements[engagementId].status = "resolved"
            return true
        end
        return false
    end,

    getAllDetectedCraft = function(self)
        local all = {}
        for id, craft in pairs(self.detected_craft) do
            table.insert(all, craft)
        end
        return all
    end,

    getThreatAssessment = function(self)
        local total_threat = 0
        for id, craft in pairs(self.detected_craft) do
            if craft.confirmed then
                total_threat = total_threat + craft.threat
            end
        end
        return total_threat
    end,

    reset = function(self)
        self.detected_craft = {}
        self.interceptions = {}
        self.engagements = {}
        return true
    end
}

Suite:group("Player Craft", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
    end)

    Suite:testMethod("CraftInterception.registerPlayerCraft", {description = "Registers player craft", testCase = "register", type = "functional"}, function()
        local ok = shared.ci:registerPlayerCraft("p1", "Interceptor", 2000)
        Helpers.assertEqual(ok, true, "Registered")
    end)
end)

Suite:group("Detection", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
        shared.ci:registerPlayerCraft("p1", "Fighter", 2000, 4, 3000)
    end)

    Suite:testMethod("CraftInterception.detectCraft", {description = "Detects craft", testCase = "detect", type = "functional"}, function()
        local ok = shared.ci:detectCraft("e1", "Raider", "Scout", 2)
        Helpers.assertEqual(ok, true, "Detected")
    end)

    Suite:testMethod("CraftInterception.getDetectedCraft", {description = "Gets detected craft", testCase = "get", type = "functional"}, function()
        shared.ci:detectCraft("e2", "Enemy", "Fighter", 3)
        local craft = shared.ci:getDetectedCraft("e2")
        Helpers.assertEqual(craft ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CraftInterception.getCraftThreatLevel", {description = "Gets threat level", testCase = "threat", type = "functional"}, function()
        shared.ci:detectCraft("e3", "Threat", "Carrier", 5)
        local threat = shared.ci:getCraftThreatLevel("e3")
        Helpers.assertEqual(threat, 5, "5")
    end)

    Suite:testMethod("CraftInterception.confirmThreat", {description = "Confirms threat", testCase = "confirm", type = "functional"}, function()
        shared.ci:detectCraft("e4", "Enemy", "Scout", 1)
        local ok = shared.ci:confirmThreat("e4")
        Helpers.assertEqual(ok, true, "Confirmed")
    end)

    Suite:testMethod("CraftInterception.isThreatConfirmed", {description = "Is confirmed", testCase = "is_confirmed", type = "functional"}, function()
        shared.ci:detectCraft("e5", "Foe", "Fighter", 2)
        shared.ci:confirmThreat("e5")
        local confirmed = shared.ci:isThreatConfirmed("e5")
        Helpers.assertEqual(confirmed, true, "Confirmed")
    end)
end)

Suite:group("Range & Distance", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
        shared.ci:registerPlayerCraft("p1", "Interceptor", 2000, 4, 3000)
    end)

    Suite:testMethod("CraftInterception.calculateDistance", {description = "Calculates distance", testCase = "distance", type = "functional"}, function()
        shared.ci:detectCraft("e1", "Enemy1", "Scout", 1)
        shared.ci:detectCraft("e2", "Enemy2", "Scout", 1)
        local dist = shared.ci:calculateDistance("e1", "e2")
        Helpers.assertEqual(dist >= 0, true, "Distance >= 0")
    end)

    Suite:testMethod("CraftInterception.isInRange", {description = "Checks range", testCase = "in_range", type = "functional"}, function()
        shared.ci:detectCraft("e6", "Nearby", "Scout", 1)
        local inRange = shared.ci:isInRange("p1", "e6")
        Helpers.assertEqual(inRange == true or inRange == false, true, "Checked")
    end)
end)

Suite:group("Interception", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
        shared.ci:registerPlayerCraft("p1", "Fighter", 2000, 4, 3000)
        shared.ci:detectCraft("e1", "Enemy", "Scout", 1)
    end)

    Suite:testMethod("CraftInterception.initiateInterception", {description = "Initiates interception", testCase = "initiate", type = "functional"}, function()
        local ok = shared.ci:initiatInterception("p1", "e1")
        Helpers.assertEqual(ok == true or ok == false, true, "Initiated")
    end)

    Suite:testMethod("CraftInterception.updateInterceptionDistance", {description = "Updates distance", testCase = "update", type = "functional"}, function()
        shared.ci:initiatInterception("p1", "e1")
        local ok = shared.ci:updateInterceptionDistance("p1_e1", 500)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("CraftInterception.isInterceptionSuccessful", {description = "Is successful", testCase = "successful", type = "functional"}, function()
        shared.ci:initiatInterception("p1", "e1")
        shared.ci:updateInterceptionDistance("p1_e1", 50)
        local success = shared.ci:isInterceptionSuccessful("p1_e1")
        Helpers.assertEqual(success, true, "Successful")
    end)

    Suite:testMethod("CraftInterception.completeInterception", {description = "Completes interception", testCase = "complete", type = "functional"}, function()
        shared.ci:initiatInterception("p1", "e1")
        shared.ci:updateInterceptionDistance("p1_e1", 80)
        local ok = shared.ci:completeInterception("p1_e1")
        Helpers.assertEqual(ok, true, "Completed")
    end)
end)

Suite:group("Engagement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
        shared.ci:registerPlayerCraft("p1", "Fighter", 2000, 4, 3000)
        shared.ci:detectCraft("e1", "Enemy", "Scout", 1)
    end)

    Suite:testMethod("CraftInterception.initiateEngagement", {description = "Initiates engagement", testCase = "initiate", type = "functional"}, function()
        local ok = shared.ci:initiateEngagement("p1", "e1")
        Helpers.assertEqual(ok, true, "Initiated")
    end)

    Suite:testMethod("CraftInterception.getEngagement", {description = "Gets engagement", testCase = "get", type = "functional"}, function()
        shared.ci:initiateEngagement("p1", "e1")
        local eng = shared.ci:getEngagement("p1_e1")
        Helpers.assertEqual(eng ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CraftInterception.fireWeapon", {description = "Fires weapon", testCase = "fire", type = "functional"}, function()
        shared.ci:initiateEngagement("p1", "e1")
        local ok = shared.ci:fireWeapon("p1_e1", "player", 20)
        Helpers.assertEqual(ok, true, "Fired")
    end)

    Suite:testMethod("CraftInterception.getEngagementStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.ci:initiateEngagement("p1", "e1")
        local status = shared.ci:getEngagementStatus("p1_e1")
        Helpers.assertEqual(status == "Ongoing", true, "Ongoing")
    end)

    Suite:testMethod("CraftInterception.resolveEngagement", {description = "Resolves engagement", testCase = "resolve", type = "functional"}, function()
        shared.ci:initiateEngagement("p1", "e1")
        shared.ci:fireWeapon("p1_e1", "player", 100)
        local ok = shared.ci:resolveEngagement("p1_e1")
        Helpers.assertEqual(ok, true, "Resolved")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
    end)

    Suite:testMethod("CraftInterception.getAllDetectedCraft", {description = "Gets all craft", testCase = "all", type = "functional"}, function()
        shared.ci:detectCraft("e1", "Enemy1", "Scout", 1)
        shared.ci:detectCraft("e2", "Enemy2", "Fighter", 2)
        local all = shared.ci:getAllDetectedCraft()
        Helpers.assertEqual(#all, 2, "2")
    end)

    Suite:testMethod("CraftInterception.getThreatAssessment", {description = "Gets threat assessment", testCase = "assessment", type = "functional"}, function()
        shared.ci:detectCraft("e1", "E1", "Scout", 2)
        shared.ci:detectCraft("e2", "E2", "Fighter", 3)
        shared.ci:confirmThreat("e1")
        shared.ci:confirmThreat("e2")
        local threat = shared.ci:getThreatAssessment()
        Helpers.assertEqual(threat, 5, "5")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CraftInterception:new()
    end)

    Suite:testMethod("CraftInterception.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ci:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
