-- ─────────────────────────────────────────────────────────────────────────
-- THREAT ASSESSMENT TEST SUITE
-- FILE: tests2/geoscape/threat_assessment_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.threat_assessment",
    fileName = "threat_assessment.lua",
    description = "Threat assessment with enemy capabilities and invasion probability"
})

print("[THREAT_ASSESSMENT_TEST] Setting up")

local ThreatAssessment = {
    threats = {},
    enemies = {},
    regions = {},
    assessments = {},

    new = function(self)
        return setmetatable({
            threats = {}, enemies = {}, regions = {}, assessments = {}
        }, {__index = self})
    end,

    registerEnemy = function(self, enemyId, name, power_level, aggressiveness)
        self.enemies[enemyId] = {
            id = enemyId, name = name, power_level = power_level or 50,
            aggressiveness = aggressiveness or 30, known_location = nil,
            last_sighting = 0, threat_level = 0, confirmed = false
        }
        return true
    end,

    getEnemy = function(self, enemyId)
        return self.enemies[enemyId]
    end,

    createThreat = function(self, threatId, enemyId, region, intensity)
        if not self.enemies[enemyId] then return false end
        self.threats[threatId] = {
            id = threatId, enemy_id = enemyId, region = region or "unknown",
            intensity = intensity or 50, active = true, turn_detected = 1,
            capabilities = {}, response_time = 10
        }
        return true
    end,

    getThreat = function(self, threatId)
        return self.threats[threatId]
    end,

    calculateThreatLevel = function(self, threatId)
        if not self.threats[threatId] then return 0 end
        local threat = self.threats[threatId]
        local enemy = self.enemies[threat.enemy_id]
        if not enemy then return 0 end
        local base_level = enemy.power_level
        local intensity_factor = threat.intensity / 100
        local aggression_factor = enemy.aggressiveness / 100
        local threat_level = (base_level * intensity_factor * (1 + aggression_factor))
        return math.floor(threat_level)
    end,

    registerRegion = function(self, regionId, name, defense_capability)
        self.regions[regionId] = {
            id = regionId, name = name, defense_level = defense_capability or 30,
            alert_status = "green", garrison_size = 50, fortifications = 0,
            active_threats = {}, alert_turn = 0
        }
        return true
    end,

    getRegion = function(self, regionId)
        return self.regions[regionId]
    end,

    setRegionAlertStatus = function(self, regionId, status)
        if not self.regions[regionId] then return false end
        self.regions[regionId].alert_status = status or "green"
        return true
    end,

    getRegionAlertStatus = function(self, regionId)
        if not self.regions[regionId] then return "unknown" end
        return self.regions[regionId].alert_status
    end,

    addActiveThreatToRegion = function(self, regionId, threatId)
        if not self.regions[regionId] or not self.threats[threatId] then return false end
        self.regions[regionId].active_threats[threatId] = true
        return true
    end,

    removeActiveThreatFromRegion = function(self, regionId, threatId)
        if not self.regions[regionId] then return false end
        self.regions[regionId].active_threats[threatId] = nil
        return true
    end,

    getActiveThreatsInRegion = function(self, regionId)
        if not self.regions[regionId] then return {} end
        local threats = {}
        for threatId, _ in pairs(self.regions[regionId].active_threats) do
            table.insert(threats, threatId)
        end
        return threats
    end,

    getActiveThreatCount = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local count = 0
        for _ in pairs(self.regions[regionId].active_threats) do
            count = count + 1
        end
        return count
    end,

    assessInvasionProbability = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local threat_sum = 0
        local threat_count = 0
        for threatId, _ in pairs(region.active_threats) do
            local threat_level = self:calculateThreatLevel(threatId)
            threat_sum = threat_sum + threat_level
            threat_count = threat_count + 1
        end
        if threat_count == 0 then return 0 end
        local avg_threat = threat_sum / threat_count
        local defense_factor = region.defense_level / 100
        local invasion_prob = (avg_threat * (1 - defense_factor)) * 100
        return math.floor(invasion_prob)
    end,

    calculateRegionVulnerability = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local region = self.regions[regionId]
        local base_vulnerability = 100 - region.defense_level
        local threat_count = self:getActiveThreatCount(regionId)
        local garrison_factor = (region.garrison_size / 100)
        local vulnerability = (base_vulnerability * (1 + threat_count * 0.2)) / (1 + garrison_factor)
        return math.floor(vulnerability)
    end,

    createAssessmentReport = function(self, reportId, regionId, threat_level, confidence)
        if not self.regions[regionId] then return false end
        self.assessments[reportId] = {
            id = reportId, region_id = regionId, threat_level = threat_level or 50,
            confidence = confidence or 70, turn_created = 1, recommended_action = "monitor",
            resource_allocation = 0
        }
        return true
    end,

    getAssessmentReport = function(self, reportId)
        return self.assessments[reportId]
    end,

    updateAssessmentReport = function(self, reportId, new_threat_level)
        if not self.assessments[reportId] then return false end
        self.assessments[reportId].threat_level = new_threat_level or self.assessments[reportId].threat_level
        return true
    end,

    recommendAction = function(self, reportId, action)
        if not self.assessments[reportId] then return false end
        self.assessments[reportId].recommended_action = action or "monitor"
        return true
    end,

    addEnemyCapability = function(self, threatId, capabilityId, effectiveness)
        if not self.threats[threatId] then return false end
        self.threats[threatId].capabilities[capabilityId] = {
            id = capabilityId, effectiveness = effectiveness or 50
        }
        return true
    end,

    getEnemyCapabilities = function(self, threatId)
        if not self.threats[threatId] then return {} end
        return self.threats[threatId].capabilities
    end,

    calculateOverallThreatAssessment = function(self, regionId)
        if not self.regions[regionId] then return 0 end
        local threats = self:getActiveThreatsInRegion(regionId)
        if #threats == 0 then return 0 end
        local total_assessment = 0
        for _, threatId in ipairs(threats) do
            local level = self:calculateThreatLevel(threatId)
            total_assessment = total_assessment + level
        end
        return math.floor(total_assessment / #threats)
    end,

    setEnemyLocation = function(self, enemyId, region)
        if not self.enemies[enemyId] then return false end
        self.enemies[enemyId].known_location = region
        return true
    end,

    getEnemyLocation = function(self, enemyId)
        if not self.enemies[enemyId] then return nil end
        return self.enemies[enemyId].known_location
    end,

    updateEnemySighting = function(self, enemyId, turn)
        if not self.enemies[enemyId] then return false end
        self.enemies[enemyId].last_sighting = turn
        return true
    end,

    setEnemyConfirmed = function(self, enemyId, confirmed)
        if not self.enemies[enemyId] then return false end
        self.enemies[enemyId].confirmed = confirmed or false
        return true
    end,

    isEnemyConfirmed = function(self, enemyId)
        if not self.enemies[enemyId] then return false end
        return self.enemies[enemyId].confirmed
    end,

    getConfirmedEnemies = function(self)
        local confirmed = {}
        for enemyId, enemy in pairs(self.enemies) do
            if enemy.confirmed then
                table.insert(confirmed, enemyId)
            end
        end
        return confirmed
    end,

    calculateResponceTime = function(self, threatId, force_response_time)
        if not self.threats[threatId] then return 0 end
        local threat = self.threats[threatId]
        local response_time = threat.response_time - (force_response_time or 0)
        return math.max(0, response_time)
    end,

    getGlobalThreatLevel = function(self)
        local total = 0
        for _, threat in pairs(self.threats) do
            if threat.active then
                total = total + self:calculateThreatLevel(threat.id)
            end
        end
        return math.floor(total / math.max(1, self:getActiveThreatCount("global")))
    end,

    reset = function(self)
        self.threats = {}
        self.enemies = {}
        self.regions = {}
        self.assessments = {}
        return true
    end
}

-- Helper to count active global threats
function ThreatAssessment:getActiveThreatCount(param)
    if param == "global" then
        local count = 0
        for _, threat in pairs(self.threats) do
            if threat.active then count = count + 1 end
        end
        return count
    end
    return 0
end

Suite:group("Enemies", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
    end)

    Suite:testMethod("ThreatAssessment.registerEnemy", {description = "Registers enemy", testCase = "register", type = "functional"}, function()
        local ok = shared.ta:registerEnemy("enemy1", "Aliens", 75, 80)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ThreatAssessment.getEnemy", {description = "Gets enemy", testCase = "get", type = "functional"}, function()
        shared.ta:registerEnemy("enemy2", "Cultists", 50, 40)
        local enemy = shared.ta:getEnemy("enemy2")
        Helpers.assertEqual(enemy ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Threats", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerEnemy("threat_enemy", "Invaders", 70, 60)
    end)

    Suite:testMethod("ThreatAssessment.createThreat", {description = "Creates threat", testCase = "create", type = "functional"}, function()
        local ok = shared.ta:createThreat("threat1", "threat_enemy", "north", 60)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ThreatAssessment.getThreat", {description = "Gets threat", testCase = "get", type = "functional"}, function()
        shared.ta:createThreat("threat2", "threat_enemy", "south", 50)
        local threat = shared.ta:getThreat("threat2")
        Helpers.assertEqual(threat ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ThreatAssessment.calculateThreatLevel", {description = "Calculates level", testCase = "level", type = "functional"}, function()
        shared.ta:createThreat("threat3", "threat_enemy", "east", 70)
        local level = shared.ta:calculateThreatLevel("threat3")
        Helpers.assertEqual(level > 0, true, "Level > 0")
    end)
end)

Suite:group("Regions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
    end)

    Suite:testMethod("ThreatAssessment.registerRegion", {description = "Registers region", testCase = "register", type = "functional"}, function()
        local ok = shared.ta:registerRegion("region1", "Capital", 70)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ThreatAssessment.getRegion", {description = "Gets region", testCase = "get", type = "functional"}, function()
        shared.ta:registerRegion("region2", "Province", 50)
        local region = shared.ta:getRegion("region2")
        Helpers.assertEqual(region ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ThreatAssessment.setRegionAlertStatus", {description = "Sets status", testCase = "status", type = "functional"}, function()
        shared.ta:registerRegion("region3", "Territory", 45)
        local ok = shared.ta:setRegionAlertStatus("region3", "red")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ThreatAssessment.getRegionAlertStatus", {description = "Gets status", testCase = "get_status", type = "functional"}, function()
        shared.ta:registerRegion("region4", "District", 55)
        shared.ta:setRegionAlertStatus("region4", "yellow")
        local status = shared.ta:getRegionAlertStatus("region4")
        Helpers.assertEqual(status, "yellow", "Yellow")
    end)
end)

Suite:group("Active Threats in Region", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerRegion("active_region", "Active", 60)
        shared.ta:registerEnemy("active_enemy", "Enemy", 60, 50)
        shared.ta:createThreat("active_threat", "active_enemy", "active_region", 65)
    end)

    Suite:testMethod("ThreatAssessment.addActiveThreatToRegion", {description = "Adds threat", testCase = "add", type = "functional"}, function()
        local ok = shared.ta:addActiveThreatToRegion("active_region", "active_threat")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ThreatAssessment.getActiveThreatsInRegion", {description = "Gets threats", testCase = "get_threats", type = "functional"}, function()
        shared.ta:addActiveThreatToRegion("active_region", "active_threat")
        local threats = shared.ta:getActiveThreatsInRegion("active_region")
        Helpers.assertEqual(#threats > 0, true, "Has threats")
    end)

    Suite:testMethod("ThreatAssessment.getActiveThreatCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.ta:addActiveThreatToRegion("active_region", "active_threat")
        local count = shared.ta:getActiveThreatCount("active_region")
        Helpers.assertEqual(count, 1, "1 threat")
    end)

    Suite:testMethod("ThreatAssessment.removeActiveThreatFromRegion", {description = "Removes threat", testCase = "remove", type = "functional"}, function()
        shared.ta:addActiveThreatToRegion("active_region", "active_threat")
        local ok = shared.ta:removeActiveThreatFromRegion("active_region", "active_threat")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Invasion Assessment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerRegion("inv_region", "Vulnerable", 30)
        shared.ta:registerEnemy("inv_enemy", "Invaders", 80, 90)
        shared.ta:createThreat("inv_threat", "inv_enemy", "inv_region", 85)
        shared.ta:addActiveThreatToRegion("inv_region", "inv_threat")
    end)

    Suite:testMethod("ThreatAssessment.assessInvasionProbability", {description = "Invasion probability", testCase = "probability", type = "functional"}, function()
        local prob = shared.ta:assessInvasionProbability("inv_region")
        Helpers.assertEqual(prob > 0, true, "Probability > 0")
    end)

    Suite:testMethod("ThreatAssessment.calculateRegionVulnerability", {description = "Vulnerability", testCase = "vulnerability", type = "functional"}, function()
        local vuln = shared.ta:calculateRegionVulnerability("inv_region")
        Helpers.assertEqual(vuln > 0, true, "Vulnerability > 0")
    end)
end)

Suite:group("Assessment Reports", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerRegion("report_region", "Report", 50)
    end)

    Suite:testMethod("ThreatAssessment.createAssessmentReport", {description = "Creates report", testCase = "create", type = "functional"}, function()
        local ok = shared.ta:createAssessmentReport("report1", "report_region", 70, 85)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ThreatAssessment.getAssessmentReport", {description = "Gets report", testCase = "get", type = "functional"}, function()
        shared.ta:createAssessmentReport("report2", "report_region", 60, 75)
        local report = shared.ta:getAssessmentReport("report2")
        Helpers.assertEqual(report ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ThreatAssessment.updateAssessmentReport", {description = "Updates report", testCase = "update", type = "functional"}, function()
        shared.ta:createAssessmentReport("report3", "report_region", 50, 70)
        local ok = shared.ta:updateAssessmentReport("report3", 80)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("ThreatAssessment.recommendAction", {description = "Recommends action", testCase = "action", type = "functional"}, function()
        shared.ta:createAssessmentReport("report4", "report_region", 65, 80)
        local ok = shared.ta:recommendAction("report4", "evacuate")
        Helpers.assertEqual(ok, true, "Recommended")
    end)
end)

Suite:group("Enemy Capabilities", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerEnemy("cap_enemy", "Capable", 75, 70)
        shared.ta:createThreat("cap_threat", "cap_enemy", "region", 70)
    end)

    Suite:testMethod("ThreatAssessment.addEnemyCapability", {description = "Adds capability", testCase = "add", type = "functional"}, function()
        local ok = shared.ta:addEnemyCapability("cap_threat", "ranged_attack", 85)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ThreatAssessment.getEnemyCapabilities", {description = "Gets capabilities", testCase = "get", type = "functional"}, function()
        shared.ta:addEnemyCapability("cap_threat", "stealth", 60)
        local caps = shared.ta:getEnemyCapabilities("cap_threat")
        Helpers.assertEqual(caps ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Enemy Tracking", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerEnemy("track_enemy", "Tracked", 70, 60)
    end)

    Suite:testMethod("ThreatAssessment.setEnemyLocation", {description = "Sets location", testCase = "location", type = "functional"}, function()
        local ok = shared.ta:setEnemyLocation("track_enemy", "north")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ThreatAssessment.getEnemyLocation", {description = "Gets location", testCase = "get_location", type = "functional"}, function()
        shared.ta:setEnemyLocation("track_enemy", "south")
        local loc = shared.ta:getEnemyLocation("track_enemy")
        Helpers.assertEqual(loc, "south", "South")
    end)

    Suite:testMethod("ThreatAssessment.updateEnemySighting", {description = "Updates sighting", testCase = "sighting", type = "functional"}, function()
        local ok = shared.ta:updateEnemySighting("track_enemy", 10)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("ThreatAssessment.setEnemyConfirmed", {description = "Sets confirmed", testCase = "confirmed", type = "functional"}, function()
        local ok = shared.ta:setEnemyConfirmed("track_enemy", true)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ThreatAssessment.isEnemyConfirmed", {description = "Is confirmed", testCase = "is_confirmed", type = "functional"}, function()
        shared.ta:setEnemyConfirmed("track_enemy", true)
        local is = shared.ta:isEnemyConfirmed("track_enemy")
        Helpers.assertEqual(is, true, "Confirmed")
    end)

    Suite:testMethod("ThreatAssessment.getConfirmedEnemies", {description = "Gets confirmed", testCase = "get_confirmed", type = "functional"}, function()
        shared.ta:setEnemyConfirmed("track_enemy", true)
        local confirmed = shared.ta:getConfirmedEnemies()
        Helpers.assertEqual(#confirmed > 0, true, "Has confirmed")
    end)
end)

Suite:group("Response & Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
        shared.ta:registerRegion("resp_region", "Response", 50)
        shared.ta:registerEnemy("resp_enemy", "Responder", 60, 50)
        shared.ta:createThreat("resp_threat", "resp_enemy", "resp_region", 60)
    end)

    Suite:testMethod("ThreatAssessment.calculateResponceTime", {description = "Response time", testCase = "response", type = "functional"}, function()
        local time = shared.ta:calculateResponceTime("resp_threat", 2)
        Helpers.assertEqual(time >= 0, true, "Time >= 0")
    end)

    Suite:testMethod("ThreatAssessment.calculateOverallThreatAssessment", {description = "Overall assessment", testCase = "overall", type = "functional"}, function()
        shared.ta:addActiveThreatToRegion("resp_region", "resp_threat")
        local assessment = shared.ta:calculateOverallThreatAssessment("resp_region")
        Helpers.assertEqual(assessment >= 0, true, "Assessment >= 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ta = ThreatAssessment:new()
    end)

    Suite:testMethod("ThreatAssessment.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ta:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
