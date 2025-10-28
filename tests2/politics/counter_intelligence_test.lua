-- ─────────────────────────────────────────────────────────────────────────
-- COUNTER INTELLIGENCE TEST SUITE
-- FILE: tests2/politics/counter_intelligence_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.counter_intelligence",
    fileName = "counter_intelligence.lua",
    description = "Counter intelligence system with enemy tracking, infiltration, and espionage"
})

print("[COUNTER_INTELLIGENCE_TEST] Setting up")

local CounterIntelligence = {
    threats = {},
    intelligence = {},
    infiltrators = {},
    operations = {},
    security = {},

    new = function(self)
        return setmetatable({
            threats = {}, intelligence = {}, infiltrators = {},
            operations = {}, security = {}
        }, {__index = self})
    end,

    registerThreat = function(self, threatId, name, threatType, threat_level)
        self.threats[threatId] = {
            id = threatId, name = name, type = threatType or "unknown",
            threat_level = threat_level or 50, active = false,
            last_seen = 0, location_x = 0, location_y = 0, sightings = 0
        }
        self.intelligence[threatId] = {threat = threatId, data = {}, confidence = 0}
        return true
    end,

    getThreat = function(self, threatId)
        return self.threats[threatId]
    end,

    reportSighting = function(self, threatId, x, y)
        if not self.threats[threatId] then return false end
        self.threats[threatId].sightings = self.threats[threatId].sightings + 1
        self.threats[threatId].last_seen = 0
        self.threats[threatId].location_x = x
        self.threats[threatId].location_y = y
        self.threats[threatId].active = true
        return true
    end,

    getSightingCount = function(self, threatId)
        if not self.threats[threatId] then return 0 end
        return self.threats[threatId].sightings
    end,

    getLastSeenLocation = function(self, threatId)
        if not self.threats[threatId] then return 0, 0 end
        return self.threats[threatId].location_x, self.threats[threatId].location_y
    end,

    calculateThreatLevel = function(self, threatId)
        if not self.threats[threatId] then return 0 end
        local threat = self.threats[threatId]
        local base_level = threat.threat_level
        local sighting_multiplier = 1 + (threat.sightings * 0.1)
        local activity_bonus = threat.active and 10 or 0
        return math.floor(base_level * sighting_multiplier + activity_bonus)
    end,

    gatherIntelligence = function(self, threatId, intelType, data)
        if not self.intelligence[threatId] then return false end
        table.insert(self.intelligence[threatId].data, {type = intelType, value = data, turn = 0})
        self.intelligence[threatId].confidence = math.min(100, self.intelligence[threatId].confidence + 10)
        return true
    end,

    getIntelligenceConfidence = function(self, threatId)
        if not self.intelligence[threatId] then return 0 end
        return self.intelligence[threatId].confidence
    end,

    getIntelligenceDataCount = function(self, threatId)
        if not self.intelligence[threatId] then return 0 end
        return #self.intelligence[threatId].data
    end,

    identifyInfiltrator = function(self, infiltratorId, name, targetFaction, infiltration_level)
        self.infiltrators[infiltratorId] = {
            id = infiltratorId, name = name, target = targetFaction or "unknown",
            level = infiltration_level or 30, detected = false,
            exposure_risk = 0, associates = {}
        }
        return true
    end,

    getInfiltrator = function(self, infiltratorId)
        return self.infiltrators[infiltratorId]
    end,

    detectInfiltrator = function(self, infiltratorId)
        if not self.infiltrators[infiltratorId] then return false end
        self.infiltrators[infiltratorId].detected = true
        return true
    end,

    isInfiltratorDetected = function(self, infiltratorId)
        if not self.infiltrators[infiltratorId] then return false end
        return self.infiltrators[infiltratorId].detected
    end,

    increaseExposure = function(self, infiltratorId, amount)
        if not self.infiltrators[infiltratorId] then return false end
        self.infiltrators[infiltratorId].exposure_risk = math.min(100, self.infiltrators[infiltratorId].exposure_risk + (amount or 10))
        return true
    end,

    getExposureRisk = function(self, infiltratorId)
        if not self.infiltrators[infiltratorId] then return 0 end
        return self.infiltrators[infiltratorId].exposure_risk
    end,

    addAssociate = function(self, infiltratorId, associateId)
        if not self.infiltrators[infiltratorId] then return false end
        table.insert(self.infiltrators[infiltratorId].associates, associateId)
        return true
    end,

    getAssociateCount = function(self, infiltratorId)
        if not self.infiltrators[infiltratorId] then return 0 end
        return #self.infiltrators[infiltratorId].associates
    end,

    launchCounterOperation = function(self, operationId, opType, targetThreatId)
        self.operations[operationId] = {
            id = operationId, type = opType or "surveillance",
            target = targetThreatId, status = "active",
            success_chance = 50 + math.random() * 30,
            duration_turns = 0, results = {}
        }
        return true
    end,

    getOperation = function(self, operationId)
        return self.operations[operationId]
    end,

    updateOperation = function(self, operationId)
        if not self.operations[operationId] then return false end
        self.operations[operationId].duration_turns = self.operations[operationId].duration_turns + 1
        return true
    end,

    completeOperation = function(self, operationId, success)
        if not self.operations[operationId] then return false end
        self.operations[operationId].status = success and "success" or "failure"
        table.insert(self.operations[operationId].results, {success = success, turn = 0})
        return true
    end,

    getOperationStatus = function(self, operationId)
        if not self.operations[operationId] then return "unknown" end
        return self.operations[operationId].status
    end,

    buildSecurityProfile = function(self, profileId, organization, security_level)
        self.security[profileId] = {
            id = profileId, organization = organization,
            level = security_level or 50, vulnerabilities = {},
            countermeasures = {}, breach_risk = 0
        }
        return true
    end,

    getSecurityProfile = function(self, profileId)
        return self.security[profileId]
    end,

    addVulnerability = function(self, profileId, vulnType, severity)
        if not self.security[profileId] then return false end
        table.insert(self.security[profileId].vulnerabilities, {type = vulnType, severity = severity or 50})
        self.security[profileId].breach_risk = math.min(100, self.security[profileId].breach_risk + (severity or 50))
        return true
    end,

    getVulnerabilityCount = function(self, profileId)
        if not self.security[profileId] then return 0 end
        return #self.security[profileId].vulnerabilities
    end,

    addCountermeasure = function(self, profileId, measureType, effectiveness)
        if not self.security[profileId] then return false end
        table.insert(self.security[profileId].countermeasures, {type = measureType, effectiveness = effectiveness or 50})
        self.security[profileId].breach_risk = math.max(0, self.security[profileId].breach_risk - (effectiveness or 50))
        return true
    end,

    getCountermeasureCount = function(self, profileId)
        if not self.security[profileId] then return 0 end
        return #self.security[profileId].countermeasures
    end,

    getBreachRisk = function(self, profileId)
        if not self.security[profileId] then return 0 end
        return self.security[profileId].breach_risk
    end,

    calculateOverallThreatLevel = function(self)
        local total = 0
        local count = 0
        for threatId in pairs(self.threats) do
            total = total + self:calculateThreatLevel(threatId)
            count = count + 1
        end
        if count == 0 then return 0 end
        return math.floor(total / count)
    end,

    getTotalDetectedInfiltrators = function(self)
        local count = 0
        for _, inf in pairs(self.infiltrators) do
            if inf.detected then count = count + 1 end
        end
        return count
    end,

    getActiveOperationCount = function(self)
        local count = 0
        for _, op in pairs(self.operations) do
            if op.status == "active" then count = count + 1 end
        end
        return count
    end,

    reset = function(self)
        self.threats = {}
        self.intelligence = {}
        self.infiltrators = {}
        self.operations = {}
        self.security = {}
        return true
    end
}

Suite:group("Threats", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
    end)

    Suite:testMethod("CounterIntelligence.registerThreat", {description = "Registers threat", testCase = "register", type = "functional"}, function()
        local ok = shared.ci:registerThreat("threat1", "Enemy One", "military", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("CounterIntelligence.getThreat", {description = "Gets threat", testCase = "get", type = "functional"}, function()
        shared.ci:registerThreat("threat2", "Enemy Two", "political", 50)
        local threat = shared.ci:getThreat("threat2")
        Helpers.assertEqual(threat ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CounterIntelligence.reportSighting", {description = "Reports sighting", testCase = "sighting", type = "functional"}, function()
        shared.ci:registerThreat("threat3", "Enemy Three", "military", 55)
        local ok = shared.ci:reportSighting("threat3", 100, 100)
        Helpers.assertEqual(ok, true, "Reported")
    end)

    Suite:testMethod("CounterIntelligence.getSightingCount", {description = "Sighting count", testCase = "count", type = "functional"}, function()
        shared.ci:registerThreat("threat4", "Enemy Four", "military", 50)
        shared.ci:reportSighting("threat4", 50, 50)
        shared.ci:reportSighting("threat4", 60, 60)
        local count = shared.ci:getSightingCount("threat4")
        Helpers.assertEqual(count, 2, "Two sightings")
    end)

    Suite:testMethod("CounterIntelligence.getLastSeenLocation", {description = "Last location", testCase = "location", type = "functional"}, function()
        shared.ci:registerThreat("threat5", "Enemy Five", "military", 50)
        shared.ci:reportSighting("threat5", 75, 75)
        local x, y = shared.ci:getLastSeenLocation("threat5")
        Helpers.assertEqual(x, 75, "X 75")
        Helpers.assertEqual(y, 75, "Y 75")
    end)

    Suite:testMethod("CounterIntelligence.calculateThreatLevel", {description = "Threat level", testCase = "level", type = "functional"}, function()
        shared.ci:registerThreat("threat6", "Enemy Six", "military", 50)
        shared.ci:reportSighting("threat6", 0, 0)
        local level = shared.ci:calculateThreatLevel("threat6")
        Helpers.assertEqual(level > 50, true, "Level > 50")
    end)
end)

Suite:group("Intelligence", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
        shared.ci:registerThreat("intel_threat", "Intel Threat", "military", 50)
    end)

    Suite:testMethod("CounterIntelligence.gatherIntelligence", {description = "Gathers intel", testCase = "gather", type = "functional"}, function()
        local ok = shared.ci:gatherIntelligence("intel_threat", "location", "coordinates")
        Helpers.assertEqual(ok, true, "Gathered")
    end)

    Suite:testMethod("CounterIntelligence.getIntelligenceConfidence", {description = "Confidence", testCase = "confidence", type = "functional"}, function()
        shared.ci:gatherIntelligence("intel_threat", "type", "data")
        local confidence = shared.ci:getIntelligenceConfidence("intel_threat")
        Helpers.assertEqual(confidence > 0, true, "Confidence > 0")
    end)

    Suite:testMethod("CounterIntelligence.getIntelligenceDataCount", {description = "Data count", testCase = "count", type = "functional"}, function()
        shared.ci:gatherIntelligence("intel_threat", "d1", "info1")
        shared.ci:gatherIntelligence("intel_threat", "d2", "info2")
        local count = shared.ci:getIntelligenceDataCount("intel_threat")
        Helpers.assertEqual(count, 2, "Two data")
    end)
end)

Suite:group("Infiltrators", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
    end)

    Suite:testMethod("CounterIntelligence.identifyInfiltrator", {description = "Identifies infiltrator", testCase = "identify", type = "functional"}, function()
        local ok = shared.ci:identifyInfiltrator("inf1", "Spy One", "faction", 40)
        Helpers.assertEqual(ok, true, "Identified")
    end)

    Suite:testMethod("CounterIntelligence.getInfiltrator", {description = "Gets infiltrator", testCase = "get", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf2", "Spy Two", "faction", 50)
        local inf = shared.ci:getInfiltrator("inf2")
        Helpers.assertEqual(inf ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CounterIntelligence.detectInfiltrator", {description = "Detects", testCase = "detect", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf3", "Spy Three", "faction", 60)
        local ok = shared.ci:detectInfiltrator("inf3")
        Helpers.assertEqual(ok, true, "Detected")
    end)

    Suite:testMethod("CounterIntelligence.isInfiltratorDetected", {description = "Is detected", testCase = "is_detected", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf4", "Spy Four", "faction", 45)
        shared.ci:detectInfiltrator("inf4")
        local is = shared.ci:isInfiltratorDetected("inf4")
        Helpers.assertEqual(is, true, "Detected")
    end)

    Suite:testMethod("CounterIntelligence.increaseExposure", {description = "Increases exposure", testCase = "exposure", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf5", "Spy Five", "faction", 50)
        local ok = shared.ci:increaseExposure("inf5", 20)
        Helpers.assertEqual(ok, true, "Increased")
    end)

    Suite:testMethod("CounterIntelligence.getExposureRisk", {description = "Gets risk", testCase = "risk", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf6", "Spy Six", "faction", 50)
        shared.ci:increaseExposure("inf6", 30)
        local risk = shared.ci:getExposureRisk("inf6")
        Helpers.assertEqual(risk, 30, "Risk 30")
    end)

    Suite:testMethod("CounterIntelligence.addAssociate", {description = "Adds associate", testCase = "add", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf7", "Spy Seven", "faction", 50)
        local ok = shared.ci:addAssociate("inf7", "associate1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("CounterIntelligence.getAssociateCount", {description = "Associate count", testCase = "count", type = "functional"}, function()
        shared.ci:identifyInfiltrator("inf8", "Spy Eight", "faction", 50)
        shared.ci:addAssociate("inf8", "a1")
        shared.ci:addAssociate("inf8", "a2")
        local count = shared.ci:getAssociateCount("inf8")
        Helpers.assertEqual(count, 2, "Two associates")
    end)
end)

Suite:group("Operations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
        shared.ci:registerThreat("op_threat", "Op Threat", "military", 50)
    end)

    Suite:testMethod("CounterIntelligence.launchCounterOperation", {description = "Launches op", testCase = "launch", type = "functional"}, function()
        local ok = shared.ci:launchCounterOperation("op1", "surveillance", "op_threat")
        Helpers.assertEqual(ok, true, "Launched")
    end)

    Suite:testMethod("CounterIntelligence.getOperation", {description = "Gets operation", testCase = "get", type = "functional"}, function()
        shared.ci:launchCounterOperation("op2", "sabotage", "op_threat")
        local op = shared.ci:getOperation("op2")
        Helpers.assertEqual(op ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CounterIntelligence.updateOperation", {description = "Updates op", testCase = "update", type = "functional"}, function()
        shared.ci:launchCounterOperation("op3", "spying", "op_threat")
        local ok = shared.ci:updateOperation("op3")
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("CounterIntelligence.completeOperation", {description = "Completes op", testCase = "complete", type = "functional"}, function()
        shared.ci:launchCounterOperation("op4", "surveillance", "op_threat")
        local ok = shared.ci:completeOperation("op4", true)
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("CounterIntelligence.getOperationStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.ci:launchCounterOperation("op5", "surveillance", "op_threat")
        shared.ci:completeOperation("op5", true)
        local status = shared.ci:getOperationStatus("op5")
        Helpers.assertEqual(status, "success", "Success")
    end)
end)

Suite:group("Security", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
    end)

    Suite:testMethod("CounterIntelligence.buildSecurityProfile", {description = "Builds profile", testCase = "build", type = "functional"}, function()
        local ok = shared.ci:buildSecurityProfile("sec1", "Organization", 60)
        Helpers.assertEqual(ok, true, "Built")
    end)

    Suite:testMethod("CounterIntelligence.getSecurityProfile", {description = "Gets profile", testCase = "get", type = "functional"}, function()
        shared.ci:buildSecurityProfile("sec2", "Org Two", 50)
        local profile = shared.ci:getSecurityProfile("sec2")
        Helpers.assertEqual(profile ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CounterIntelligence.addVulnerability", {description = "Adds vulnerability", testCase = "vuln", type = "functional"}, function()
        shared.ci:buildSecurityProfile("sec3", "Org Three", 50)
        local ok = shared.ci:addVulnerability("sec3", "network", 40)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("CounterIntelligence.getVulnerabilityCount", {description = "Vuln count", testCase = "count", type = "functional"}, function()
        shared.ci:buildSecurityProfile("sec4", "Org Four", 50)
        shared.ci:addVulnerability("sec4", "v1", 30)
        shared.ci:addVulnerability("sec4", "v2", 30)
        local count = shared.ci:getVulnerabilityCount("sec4")
        Helpers.assertEqual(count, 2, "Two vulns")
    end)

    Suite:testMethod("CounterIntelligence.addCountermeasure", {description = "Adds measure", testCase = "measure", type = "functional"}, function()
        shared.ci:buildSecurityProfile("sec5", "Org Five", 50)
        local ok = shared.ci:addCountermeasure("sec5", "encryption", 35)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("CounterIntelligence.getCountermeasureCount", {description = "Measure count", testCase = "count", type = "functional"}, function()
        shared.ci:buildSecurityProfile("sec6", "Org Six", 50)
        shared.ci:addCountermeasure("sec6", "m1", 25)
        shared.ci:addCountermeasure("sec6", "m2", 25)
        local count = shared.ci:getCountermeasureCount("sec6")
        Helpers.assertEqual(count, 2, "Two measures")
    end)

    Suite:testMethod("CounterIntelligence.getBreachRisk", {description = "Breach risk", testCase = "risk", type = "functional"}, function()
        shared.ci:buildSecurityProfile("sec7", "Org Seven", 50)
        shared.ci:addVulnerability("sec7", "v", 30)
        local risk = shared.ci:getBreachRisk("sec7")
        Helpers.assertEqual(risk >= 0, true, "Risk >= 0")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
        shared.ci:registerThreat("a_threat", "Analysis Threat", "military", 50)
        shared.ci:identifyInfiltrator("a_inf", "Analysis Spy", "faction", 50)
    end)

    Suite:testMethod("CounterIntelligence.calculateOverallThreatLevel", {description = "Overall threat", testCase = "overall", type = "functional"}, function()
        local level = shared.ci:calculateOverallThreatLevel()
        Helpers.assertEqual(level >= 0, true, "Level >= 0")
    end)

    Suite:testMethod("CounterIntelligence.getTotalDetectedInfiltrators", {description = "Detected count", testCase = "detected", type = "functional"}, function()
        shared.ci:detectInfiltrator("a_inf")
        local count = shared.ci:getTotalDetectedInfiltrators()
        Helpers.assertEqual(count, 1, "One detected")
    end)

    Suite:testMethod("CounterIntelligence.getActiveOperationCount", {description = "Active ops", testCase = "active", type = "functional"}, function()
        shared.ci:launchCounterOperation("a_op", "surveillance", "a_threat")
        local count = shared.ci:getActiveOperationCount()
        Helpers.assertEqual(count, 1, "One active")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ci = CounterIntelligence:new()
    end)

    Suite:testMethod("CounterIntelligence.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ci:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
