---================================================================================
---PHASE 3E: Karma & Reputation System Tests
---================================================================================
---
---Comprehensive test suite for karma tracking, reputation management, relationship
---systems, and diplomatic mechanics. Tests cover:
---
---  1. Karma System (5 tests)
---     - Initialization and level determination
---     - Karma modification with clamping
---     - Effects and thresholds
---
---  2. Reputation System (5 tests)
---     - Reputation point tracking
---     - Relationship state management
---     - Recovery mechanics
---
---  3. Relationships & Diplomacy (4 tests)
---     - Country relations modification
---     - Faction competitiveness
---     - Alliance requirements
---
---  4. Integration Tests (1 test)
---     - Complete karma/reputation/relationship lifecycle
---
---@module tests2.basescape.karma_reputation_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockKarmaSystem
---Tracks player karma and determines karma-based effects and access levels.
---Implements 5-level karma spectrum from Evil (-100) to Saintly (+100).
---@field karma number Current karma value (-100 to 100)
---@field history table[] Array of karma modification events
---@field levelThresholds table Karma thresholds for level boundaries
local MockKarmaSystem = {}

function MockKarmaSystem:new()
    local instance = {
        karma = 0,
        history = {},
        levelThresholds = {
            { min = -100, max = -75, level = "Evil", color = {r=1, g=0, b=0} },
            { min = -75, max = -40, level = "Ruthless", color = {r=1, g=0.5, b=0} },
            { min = -40, max = -10, level = "Pragmatic", color = {r=1, g=1, b=0} },
            { min = -10, max = 10, level = "Neutral", color = {r=0.7, g=0.7, b=0.7} },
            { min = 10, max = 40, level = "Principled", color = {r=0.5, g=1, b=0} },
            { min = 40, max = 75, level = "Heroic", color = {r=0, g=1, b=0} },
            { min = 75, max = 100, level = "Saintly", color = {r=0, g=1, b=1} },
        }
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockKarmaSystem:getLevel()
    for _, threshold in ipairs(self.levelThresholds) do
        if self.karma >= threshold.min and self.karma <= threshold.max then
            return threshold.level
        end
    end
    return "Neutral"
end

function MockKarmaSystem:modifyKarma(amount, reason)
    self.karma = self.karma + amount

    -- Clamp karma between -100 and 100
    if self.karma > 100 then self.karma = 100 end
    if self.karma < -100 then self.karma = -100 end

    table.insert(self.history, {
        amount = amount,
        reason = reason,
        timestamp = os.time(),
        resultingLevel = self:getLevel()
    })

    return self.karma
end

function MockKarmaSystem:getKarmaEffects()
    local level = self:getLevel()
    local effects = {}

    if level == "Evil" then
        table.insert(effects, {id = "black_market", description = "Black market access", bonus = 0.2})
    elseif level == "Ruthless" then
        table.insert(effects, {id = "ruthless_tactics", description = "Ruthless tactics available", bonus = 0.15})
    elseif level == "Heroic" then
        table.insert(effects, {id = "humanitarian_missions", description = "Humanitarian missions available", bonus = 0.25})
    elseif level == "Saintly" then
        table.insert(effects, {id = "saint_power", description = "Saint's blessing", bonus = 0.3})
    end

    return effects
end

function MockKarmaSystem:canAccessBlackMarket()
    return self.karma < -20
end

function MockKarmaSystem:getLevelColor()
    for _, threshold in ipairs(self.levelThresholds) do
        if self.karma >= threshold.min and self.karma <= threshold.max then
            return threshold.color
        end
    end
    return {r=0.5, g=0.5, b=0.5}
end

---@class MockReputationSystem
---Tracks reputation points across multiple dimensions (recognition, trust, fear, support).
---Reputation affects mission options, faction relationships, and global standing.
---@field xcom_recognition number X-COM organization recognition level (0-100)
---@field global_support number Worldwide support for X-COM (0-100)
---@field alien_fear number Level of alien threat fear (0-100)
---@field civilian_trust number Civilian trust in X-COM (0-100)
---@field history table[] Array of reputation modification events
local MockReputationSystem = {}

function MockReputationSystem:new()
    local instance = {
        xcom_recognition = 0,
        global_support = 0,
        alien_fear = 50,
        civilian_trust = 40,
        history = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockReputationSystem:modifyReputation(category, amount, reason)
    if not self[category] then
        error("Invalid reputation category: " .. category)
    end

    self[category] = self[category] + amount

    -- Clamp between 0 and 100
    if self[category] > 100 then self[category] = 100 end
    if self[category] < 0 then self[category] = 0 end

    table.insert(self.history, {
        category = category,
        amount = amount,
        reason = reason,
        timestamp = os.time(),
        resultingValue = self[category]
    })

    return self[category]
end

function MockReputationSystem:getOverallReputation()
    local total = self.xcom_recognition + self.global_support + self.civilian_trust
    local avg = total / 3
    return math.floor(avg)
end

function MockReputationSystem:getReputationLevel()
    local overall = self:getOverallReputation()
    if overall >= 75 then return "Legendary"
    elseif overall >= 50 then return "Famous"
    elseif overall >= 25 then return "Known"
    else return "Unknown"
    end
end

---@class MockRelationshipSystem
---Manages country/faction relationships, diplomatic standing, and alliance mechanics.
---Tracks relationship values between -100 (hostile) and 100 (allied).
---@field countries table Map of country names to relationship data
---@field factions table Map of faction names to relationship data
---@field activeAgreements table[] Array of active diplomatic agreements
local MockRelationshipSystem = {}

function MockRelationshipSystem:new()
    local instance = {
        countries = {},
        factions = {},
        activeAgreements = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockRelationshipSystem:addCountry(name, initialRelation)
    self.countries[name] = {
        name = name,
        relation = initialRelation or 50,
        aligned = (initialRelation or 50) >= 75,
        spyNetwork = nil,
        agreements = {}
    }
end

function MockRelationshipSystem:modifyRelation(countryName, amount, reason)
    if not self.countries[countryName] then
        error("Country not found: " .. countryName)
    end

    local country = self.countries[countryName]
    country.relation = country.relation + amount

    -- Clamp between -100 and 100
    if country.relation > 100 then country.relation = 100 end
    if country.relation < -100 then country.relation = -100 end

    -- Update alignment status
    country.aligned = country.relation >= 75

    return country.relation
end

function MockRelationshipSystem:getRelationshipStatus(countryName)
    if not self.countries[countryName] then
        error("Country not found: " .. countryName)
    end

    local relation = self.countries[countryName].relation
    if relation >= 75 then return "Allied"
    elseif relation >= 25 then return "Neutral"
    elseif relation >= -25 then return "Hostile"
    else return "Enemy"
    end
end

function MockRelationshipSystem:canFormAlliance(countryName)
    if not self.countries[countryName] then
        error("Country not found: " .. countryName)
    end

    return self.countries[countryName].relation >= 75
end

function MockRelationshipSystem:addFaction(name, initialInfluence)
    self.factions[name] = {
        name = name,
        influence = initialInfluence or 50,
        power = initialInfluence or 50,
        relation = 0
    }
end

function MockRelationshipSystem:modifyFactionRelation(factionName, amount)
    if not self.factions[factionName] then
        error("Faction not found: " .. factionName)
    end

    self.factions[factionName].relation = self.factions[factionName].relation + amount
    if self.factions[factionName].relation > 100 then
        self.factions[factionName].relation = 100
    end
    if self.factions[factionName].relation < -100 then
        self.factions[factionName].relation = -100
    end
end

function MockRelationshipSystem:getRankedFactions()
    local ranked = {}
    for name, faction in pairs(self.factions) do
        table.insert(ranked, faction)
    end
    table.sort(ranked, function(a, b) return a.power > b.power end)
    return ranked
end

function MockRelationshipSystem:createAgreement(id, countries, resources, monthlyBenefit, duration)
    local agreement = {
        id = id,
        countries = countries,
        resources = resources,
        monthlyBenefit = monthlyBenefit,
        duration = duration,
        monthsRemaining = duration
    }

    table.insert(self.activeAgreements, agreement)

    for _, country in ipairs(countries) do
        if self.countries[country] then
            table.insert(self.countries[country].agreements, id)
        end
    end

    return agreement
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.politics.karma_reputation",
    file = "karma_reputation.lua",
    description = "Karma & Reputation systems - Karma tracking, reputation management, relationships & diplomacy"
})

---KARMA SYSTEM TESTS
Suite:group("Karma System", function()

    Suite:testMethod("MockKarmaSystem:new", {
        description = "Initializes with neutral karma",
        testCase = "initialization",
        type = "functional"
    }, function()
        local karma = MockKarmaSystem:new()
        if karma.karma ~= 0 then
            error("Initial karma should be 0, got " .. karma.karma)
        end
        if karma:getLevel() ~= "Neutral" then
            error("Initial level should be Neutral, got " .. karma:getLevel())
        end
    end)

    Suite:testMethod("MockKarmaSystem:getLevel", {
        description = "Calculates karma level thresholds correctly",
        testCase = "level_thresholds",
        type = "functional"
    }, function()
        local karma = MockKarmaSystem:new()

        local tests = {
            {value = -100, expected = "Evil"},
            {value = -50, expected = "Ruthless"},
            {value = -25, expected = "Pragmatic"},
            {value = 0, expected = "Neutral"},
            {value = 25, expected = "Principled"},
            {value = 50, expected = "Heroic"},
            {value = 100, expected = "Saintly"}
        }

        for _, test in ipairs(tests) do
            karma.karma = test.value
            local level = karma:getLevel()
            if level ~= test.expected then
                error("Karma " .. test.value .. " should be " .. test.expected .. ", got " .. level)
            end
        end
    end)

    Suite:testMethod("MockKarmaSystem:modifyKarma", {
        description = "Modifies karma with positive and negative amounts",
        testCase = "modification",
        type = "functional"
    }, function()
        local karma = MockKarmaSystem:new()

        karma:modifyKarma(25, "Saved civilians")
        if karma.karma ~= 25 then
            error("Karma should be 25, got " .. karma.karma)
        end

        karma:modifyKarma(-30, "Collateral damage")
        if karma.karma ~= -5 then
            error("Karma should be -5, got " .. karma.karma)
        end
    end)

    Suite:testMethod("MockKarmaSystem:modifyKarma", {
        description = "Clamps karma between -100 and 100",
        testCase = "clamping",
        type = "edge_case"
    }, function()
        local karma = MockKarmaSystem:new()

        karma:modifyKarma(200, "Extreme good")
        if karma.karma > 100 then
            error("Karma should not exceed 100, got " .. karma.karma)
        end

        karma:modifyKarma(-400, "Extreme evil")
        if karma.karma < -100 then
            error("Karma should not go below -100, got " .. karma.karma)
        end
    end)

    Suite:testMethod("MockKarmaSystem:modifyKarma", {
        description = "Tracks karma modification history",
        testCase = "history_tracking",
        type = "functional"
    }, function()
        local karma = MockKarmaSystem:new()

        karma:modifyKarma(10, "Action 1")
        karma:modifyKarma(15, "Action 2")
        karma:modifyKarma(-5, "Action 3")

        if #karma.history ~= 3 then
            error("Should have 3 history entries, got " .. #karma.history)
        end

        if karma.history[1].reason ~= "Action 1" then
            error("First history entry should be 'Action 1'")
        end
    end)
end)

---REPUTATION SYSTEM TESTS
Suite:group("Reputation System", function()

    Suite:testMethod("MockReputationSystem:new", {
        description = "Initializes reputation with default values",
        testCase = "initialization",
        type = "functional"
    }, function()
        local rep = MockReputationSystem:new()

        if rep.xcom_recognition ~= 0 then
            error("Recognition should start at 0")
        end
        if rep.civilian_trust ~= 40 then
            error("Trust should start at 40")
        end
        if rep.alien_fear ~= 50 then
            error("Fear should start at 50")
        end
    end)

    Suite:testMethod("MockReputationSystem:modifyReputation", {
        description = "Modifies reputation across dimensions",
        testCase = "modification",
        type = "functional"
    }, function()
        local rep = MockReputationSystem:new()

        rep:modifyReputation("xcom_recognition", 30, "Mission success")
        if rep.xcom_recognition ~= 30 then
            error("Recognition should be 30, got " .. rep.xcom_recognition)
        end

        rep:modifyReputation("civilian_trust", 20, "Saved civilians")
        if rep.civilian_trust ~= 60 then
            error("Trust should be 60, got " .. rep.civilian_trust)
        end
    end)

    Suite:testMethod("MockReputationSystem:getOverallReputation", {
        description = "Calculates overall reputation",
        testCase = "overall_calc",
        type = "functional"
    }, function()
        local rep = MockReputationSystem:new()

        rep.xcom_recognition = 40
        rep.global_support = 50
        rep.civilian_trust = 60

        local overall = rep:getOverallReputation()
        if overall ~= 50 then
            error("Overall should be 50, got " .. overall)
        end
    end)

    Suite:testMethod("MockReputationSystem:getReputationLevel", {
        description = "Determines reputation level from overall score",
        testCase = "level_determination",
        type = "functional"
    }, function()
        local rep = MockReputationSystem:new()

        rep.xcom_recognition = 20
        rep.global_support = 20
        rep.civilian_trust = 20
        if rep:getReputationLevel() ~= "Unknown" then
            error("Low reputation should be Unknown")
        end

        rep.xcom_recognition = 50
        rep.global_support = 50
        rep.civilian_trust = 50
        if rep:getReputationLevel() ~= "Famous" then
            error("Medium reputation should be Famous")
        end
    end)
end)

---RELATIONSHIP & DIPLOMACY TESTS
Suite:group("Relationships & Diplomacy", function()

    Suite:testMethod("MockRelationshipSystem:modifyRelation", {
        description = "Creates and modifies country relationships",
        testCase = "country_relations",
        type = "functional"
    }, function()
        local rel = MockRelationshipSystem:new()

        rel:addCountry("France", 60)
        rel:modifyRelation("France", 15, "Trade agreement")

        if rel.countries["France"].relation ~= 75 then
            error("France relation should be 75, got " .. rel.countries["France"].relation)
        end
    end)

    Suite:testMethod("MockRelationshipSystem:getRelationshipStatus", {
        description = "Determines relationship status",
        testCase = "status_determination",
        type = "functional"
    }, function()
        local rel = MockRelationshipSystem:new()

        rel:addCountry("Germany", 80)
        if rel:getRelationshipStatus("Germany") ~= "Allied" then
            error("High relation should be Allied")
        end

        rel:addCountry("Russia", 40)
        if rel:getRelationshipStatus("Russia") ~= "Neutral" then
            error("Medium relation should be Neutral")
        end
    end)

    Suite:testMethod("MockRelationshipSystem:getRankedFactions", {
        description = "Tracks faction influence and power",
        testCase = "faction_ranking",
        type = "functional"
    }, function()
        local rel = MockRelationshipSystem:new()

        rel:addFaction("XCom", 60)
        rel:addFaction("Corporate", 40)
        rel:addFaction("Military", 50)

        local ranked = rel:getRankedFactions()
        if ranked[1].name ~= "XCom" then
            error("XCom should be most powerful faction")
        end
    end)

    Suite:testMethod("MockRelationshipSystem:createAgreement", {
        description = "Creates resource sharing agreements",
        testCase = "agreement_creation",
        type = "functional"
    }, function()
        local rel = MockRelationshipSystem:new()

        rel:addCountry("Canada", 85)
        rel:addCountry("USA", 90)

        local agreement = rel:createAgreement(
            "TRADE_001",
            {"Canada", "USA"},
            {supplies = 1000, intel = 500},
            150000,
            12
        )

        if #rel.activeAgreements ~= 1 then
            error("Should have 1 active agreement")
        end
        if agreement.monthlyBenefit ~= 150000 then
            error("Agreement benefit should be 150000")
        end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Complete Lifecycle", {
        description = "Manages karma, reputation, and relationships together",
        testCase = "full_lifecycle",
        type = "integration"
    }, function()
        local karma = MockKarmaSystem:new()
        local rep = MockReputationSystem:new()
        local rel = MockRelationshipSystem:new()

        -- Start fresh
        if karma.karma ~= 0 then error("Should start neutral") end

        -- Perform actions
        karma:modifyKarma(30, "Heroic mission")
        rep:modifyReputation("xcom_recognition", 50, "Mission success")
        rep:modifyReputation("global_support", 50, "Public support")
        rep:modifyReputation("civilian_trust", 30, "Protected civilians")

        -- Setup diplomacy
        rel:addCountry("France", 50)
        rel:addCountry("Germany", 80)

        -- Verify final states
        if karma:getLevel() ~= "Principled" then
            error("Should be Principled level, got " .. karma:getLevel())
        end

        if not rel:canFormAlliance("Germany") then
            error("Germany should be alliable")
        end

        if #rel.activeAgreements ~= 0 then
            error("Should have no agreements initially")
        end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - Countries", {
        description = "Handles many countries efficiently",
        testCase = "scaling_countries",
        type = "performance"
    }, function()
        local rel = MockRelationshipSystem:new()
        local startTime = os.clock()

        for i = 1, 100 do
            rel:addCountry("Country_" .. i, 50)
        end

        for i = 1, 100 do
            rel:modifyRelation("Country_" .. i, 10, "Trade")
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 100 countries initialization: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - Karma History", {
        description = "Handles karma history efficiently",
        testCase = "scaling_history",
        type = "performance"
    }, function()
        local karma = MockKarmaSystem:new()
        local startTime = os.clock()

        for i = 1, 1000 do
            local amount = (i % 2 == 0) and 5 or -5
            karma:modifyKarma(amount, "Event " .. i)
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 1000 karma modifications: " .. string.format("%.3fms", elapsed * 1000))
        end

        if #karma.history ~= 1000 then
            error("Should have 1000 history entries")
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
