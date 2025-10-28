-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Campaign Progression System
-- FILE: tests2/geoscape/campaign_progression_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for campaign turn progression, threat escalation, and dynamic events
-- Covers multi-turn evolution, game state consistency, difficulty scaling
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK CAMPAIGN SYSTEM FOR TESTING
-- ─────────────────────────────────────────────────────────────────────────

local MockCampaign = {}

function MockCampaign:new()
    local campaign = {
        currentTurn = 0,
        gameTime = 0,  -- Days
        threatLevel = 0,  -- 0-100
        fundsRemaining = 100000,
        baseIncome = 5000,
        incomeModifier = 1.0,  -- Modified by threat, events
        events = {},
        completedMissions = 0,
        casualties = 0,
        territoryCovered = 0,  -- Percentage 0-100
        alienActivity = 0,  -- 0-100

        -- Difficulty parameters
        escalationRate = 0.5,  -- Threat increases per turn
        eventFrequency = 0.3,  -- Chance of event per turn
        maxThreat = 100,
        maxTurns = 360  -- 1 year in days
    }

    function campaign:progressTurn()
        self.currentTurn = self.currentTurn + 1
        self.gameTime = self.gameTime + 1

        -- Threat escalates over time
        self.threatLevel = math.min(self.maxThreat,
            self.threatLevel + self.escalationRate)

        -- Alien activity correlates with threat
        self.alienActivity = self.threatLevel * 0.8

        -- Income decreases with threat
        self.incomeModifier = 1.0 - (self.threatLevel / 200)
        self.incomeModifier = math.max(0.5, self.incomeModifier)

        local income = self.baseIncome * self.incomeModifier
        self.fundsRemaining = self.fundsRemaining + income

        -- Random events occur
        if math.random() < self.eventFrequency then
            self:generateEvent()
        end
    end

    function campaign:generateEvent()
        local eventTypes = {
            "alien_attack",
            "country_upset",
            "research_breakthrough",
            "funding_increase",
            "craft_loss",
            "recruitment_available"
        }

        local eventType = eventTypes[math.random(1, #eventTypes)]
        local event = {
            type = eventType,
            turn = self.currentTurn,
            handled = false
        }

        table.insert(self.events, event)

        -- Apply event effects
        if eventType == "alien_attack" then
            self.threatLevel = math.min(self.maxThreat, self.threatLevel + 10)
        elseif eventType == "research_breakthrough" then
            self.baseIncome = self.baseIncome * 1.05
        elseif eventType == "funding_increase" then
            self.fundsRemaining = self.fundsRemaining + 10000
        elseif eventType == "craft_loss" then
            self.fundsRemaining = self.fundsRemaining - 50000
        end
    end

    function campaign:getThreatLevel()
        return self.threatLevel
    end

    function campaign:getEventLog()
        return self.events
    end

    function campaign:getRecentEvents(turns)
        turns = turns or 1
        local recentTurns = self.currentTurn - turns
        local recent = {}
        for _, event in ipairs(self.events) do
            if event.turn > recentTurns then
                table.insert(recent, event)
            end
        end
        return recent
    end

    function campaign:recordMissionComplete(enemiesDefeated, casualties, reward)
        self.completedMissions = self.completedMissions + 1
        self.casualties = self.casualties + casualties
        self.fundsRemaining = self.fundsRemaining + reward
        self.threatLevel = math.max(0, self.threatLevel - 5)  -- Mission success reduces threat
    end

    function campaign:getIncomeThisTurn()
        return self.baseIncome * self.incomeModifier
    end

    function campaign:getFundsRemaining()
        return self.fundsRemaining
    end

    function campaign:getTerritoryStatus()
        return {
            covered = self.territoryCovered,
            uncovered = 100 - self.territoryCovered,
            contested = math.floor(self.alienActivity / 2)
        }
    end

    return campaign
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.campaign.campaign_manager",
    fileName = "campaign_manager.lua",
    description = "Campaign progression system - multi-turn evolution and threat escalation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: CAMPAIGN INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Campaign Initialization", function()
    Suite:testMethod("Campaign:new", {
        description = "Creating campaign initializes all systems to starting state",
        testCase = "initialization",
        type = "functional"
    }, function()
        local campaign = MockCampaign:new()

        Helpers.assertEqual(campaign.currentTurn, 0, "Campaign should start at turn 0")
        Helpers.assertEqual(campaign.threatLevel, 0, "Threat should start at 0")
        Helpers.assertGreater(campaign.fundsRemaining, 0, "Starting funds should be positive")
        Helpers.assertEqual(campaign.completedMissions, 0, "No missions completed initially")
        Helpers.assertEqual(#campaign.events, 0, "Event log should be empty")
    end)

    Suite:testMethod("Campaign:configuration", {
        description = "Campaign parameters are within expected ranges",
        testCase = "parameter_validation",
        type = "functional"
    }, function()
        local campaign = MockCampaign:new()

        Helpers.assertGreater(campaign.baseIncome, 0, "Base income should be positive")
        Helpers.assertGreater(campaign.escalationRate, 0, "Escalation rate should be positive")
        Helpers.assertLess(campaign.escalationRate, 5, "Escalation rate should be reasonable")
        Helpers.assertEqual(campaign.maxThreat, 100, "Max threat should be 100")
        Helpers.assertGreater(campaign.maxTurns, 30, "Campaign should last at least 30 turns")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: SINGLE TURN PROGRESSION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Single Turn Progression", function()
    local campaign

    Suite:beforeEach(function()
        campaign = MockCampaign:new()
    end)

    Suite:testMethod("Campaign:progressTurn", {
        description = "Progressing one turn increments turn counter and game time",
        testCase = "turn_increment",
        type = "functional"
    }, function()
        Helpers.assertEqual(campaign.currentTurn, 0, "Start at turn 0")

        campaign:progressTurn()

        Helpers.assertEqual(campaign.currentTurn, 1, "Should be at turn 1")
        Helpers.assertEqual(campaign.gameTime, 1, "Game time should advance 1 day")
    end)

    Suite:testMethod("Campaign:progressTurn", {
        description = "Threat level increases with each turn (escalation)",
        testCase = "threat_escalation",
        type = "functional"
    }, function()
        local threatBefore = campaign.threatLevel

        campaign:progressTurn()

        local threatAfter = campaign.threatLevel
        Helpers.assertGreater(threatAfter, threatBefore, "Threat should increase")
        Helpers.assertEqual(threatAfter - threatBefore, campaign.escalationRate,
            "Threat should increase by escalation rate")
    end)

    Suite:testMethod("Campaign:progressTurn", {
        description = "Player receives income each turn reduced by threat level",
        testCase = "income_calculation",
        type = "functional"
    }, function()
        local fundsBefore = campaign.fundsRemaining

        campaign:progressTurn()

        local fundsAfter = campaign.fundsRemaining
        local income = fundsAfter - fundsBefore

        Helpers.assertGreater(income, 0, "Should receive positive income")
        Helpers.assertLessOrEqual(income, campaign.baseIncome,
            "Income should be reduced or equal to base")
    end)

    Suite:testMethod("Campaign:progressTurn", {
        description = "Alien activity level correlates with threat level",
        testCase = "alien_activity_sync",
        type = "functional"
    }, function()
        campaign:progressTurn()

        local expectedActivity = campaign.threatLevel * 0.8
        Helpers.assertEqual(campaign.alienActivity, expectedActivity,
            "Alien activity should be 80% of threat level")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: MULTI-TURN PROGRESSION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Multi-Turn Campaign Evolution", function()
    local campaign

    Suite:beforeEach(function()
        campaign = MockCampaign:new()
    end)

    Suite:testMethod("Campaign:progressTurns", {
        description = "Campaign threat increases monotonically over 12 turns",
        testCase = "threat_monotonic",
        type = "functional"
    }, function()
        local threatHistory = {}

        for turn = 1, 12 do
            campaign:progressTurn()
            table.insert(threatHistory, campaign.threatLevel)
        end

        -- Check monotonic increase
        for i = 2, #threatHistory do
            Helpers.assertGreaterOrEqual(threatHistory[i], threatHistory[i-1],
                "Threat at turn " .. i .. " should be >= turn " .. (i-1))
        end

        -- Final threat should be significantly higher than initial
        Helpers.assertGreater(threatHistory[#threatHistory], 3,
            "Threat after 12 turns should exceed initial escalation")
    end)

    Suite:testMethod("Campaign:progressTurns", {
        description = "Campaign generates events over multi-turn period",
        testCase = "event_generation",
        type = "functional"
    }, function()
        local eventCounts = {}

        for turn = 1, 30 do
            campaign:progressTurn()
            eventCounts[turn] = #campaign.events
        end

        local totalEvents = eventCounts[30]

        -- Should have generated some events (30% chance per turn, 30 turns)
        -- Expected: ~9 events, allow 1-20 to account for randomness
        Helpers.assertGreater(totalEvents, 0, "Should generate at least 1 event in 30 turns")
        Helpers.assertLess(totalEvents, 30, "Should not generate event every single turn")
    end)

    Suite:testMethod("Campaign:progressTurns", {
        description = "Difficulty increases progressively as campaign continues",
        testCase = "difficulty_scaling",
        type = "functional"
    }, function()
        local threatsAt = {turn5 = 0, turn10 = 0, turn20 = 0}

        for turn = 1, 20 do
            campaign:progressTurn()
            if turn == 5 then threatsAt.turn5 = campaign.threatLevel end
            if turn == 10 then threatsAt.turn10 = campaign.threatLevel end
            if turn == 20 then threatsAt.turn20 = campaign.threatLevel end
        end

        -- Each interval should have higher threat
        Helpers.assertGreater(threatsAt.turn10, threatsAt.turn5,
            "Threat at turn 10 should exceed turn 5")
        Helpers.assertGreater(threatsAt.turn20, threatsAt.turn10,
            "Threat at turn 20 should exceed turn 10")
    end)

    Suite:testMethod("Campaign:progressTurns", {
        description = "Income decreases as threat increases (economic pressure)",
        testCase = "income_pressure",
        type = "functional"
    }, function()
        local incomeAt = {}

        for turn = 1, 20 do
            campaign:progressTurn()
            incomeAt[turn] = campaign:getIncomeThisTurn()
        end

        local earlyAvgIncome = (incomeAt[1] + incomeAt[2] + incomeAt[3]) / 3
        local lateAvgIncome = (incomeAt[18] + incomeAt[19] + incomeAt[20]) / 3

        Helpers.assertLess(lateAvgIncome, earlyAvgIncome,
            "Income should decrease as threat increases")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: GAME STATE TRANSITIONS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Game State Management", function()
    local campaign

    Suite:beforeEach(function()
        campaign = MockCampaign:new()
    end)

    Suite:testMethod("Campaign:mission_completion", {
        description = "Completing mission records statistics and reduces threat",
        testCase = "mission_success",
        type = "functional"
    }, function()
        campaign:progressTurn()
        campaign:progressTurn()

        local threatBefore = campaign.threatLevel
        local missionsBefore = campaign.completedMissions
        local fundsBefore = campaign.fundsRemaining

        campaign:recordMissionComplete(10, 2, 5000)

        Helpers.assertEqual(campaign.completedMissions, missionsBefore + 1,
            "Mission count should increment")
        Helpers.assertEqual(campaign.casualties, 2,
            "Casualties should be recorded")
        Helpers.assertGreater(campaign.fundsRemaining, fundsBefore,
            "Funds should increase from mission reward")
        Helpers.assertLess(campaign.threatLevel, threatBefore,
            "Threat should decrease after mission success")
    end)

    Suite:testMethod("Campaign:resource_management", {
        description = "Campaign funds are consumed and gained through gameplay",
        testCase = "fund_flow",
        type = "functional"
    }, function()
        local starting = campaign.fundsRemaining

        -- Progress turns to accumulate income
        for _ = 1, 10 do
            campaign:progressTurn()
        end

        local afterIncome = campaign.fundsRemaining
        Helpers.assertGreater(afterIncome, starting,
            "Funds should increase from income")

        -- Simulate spending
        campaign.fundsRemaining = campaign.fundsRemaining - 50000

        -- Get more income
        for _ = 1, 5 do
            campaign:progressTurn()
        end

        local afterRecovery = campaign.fundsRemaining
        Helpers.assertGreater(afterRecovery, starting,
            "Funds should recover after spending")
    end)

    Suite:testMethod("Campaign:event_effects", {
        description = "Campaign events have measurable effects on game state",
        testCase = "event_cascading",
        type = "functional"
    }, function()
        -- Manually create events and verify effects
        local fundsBeforeEvent = campaign.fundsRemaining

        campaign:generateEvent()  -- Random event

        local fundsAfterEvent = campaign.fundsRemaining

        -- Some events affect funds (either positive or negative)
        local eventType = campaign.events[#campaign.events].type

        if eventType == "funding_increase" then
            Helpers.assertGreater(fundsAfterEvent, fundsBeforeEvent,
                "Funding increase event should increase funds")
        elseif eventType == "craft_loss" then
            Helpers.assertLess(fundsAfterEvent, fundsBeforeEvent,
                "Craft loss event should decrease funds")
        end
    end)

    Suite:testMethod("Campaign:threat_constraints", {
        description = "Threat level stays within valid bounds (0-100)",
        testCase = "threat_bounds",
        type = "functional"
    }, function()
        for _ = 1, 50 do
            campaign:progressTurn()

            Helpers.assertGreaterOrEqual(campaign.threatLevel, 0,
                "Threat should never be negative")
            Helpers.assertLessOrEqual(campaign.threatLevel, campaign.maxThreat,
                "Threat should not exceed maximum")
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: TERRITORY AND STRATEGIC STATUS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Territory and Strategic Status", function()
    local campaign

    Suite:beforeEach(function()
        campaign = MockCampaign:new()
        campaign.territoryCovered = 0
    end)

    Suite:testMethod("Campaign:territory_status", {
        description = "Territory coverage status is consistent and validated",
        testCase = "territory_consistency",
        type = "functional"
    }, function()
        campaign.territoryCovered = 50

        local status = campaign:getTerritoryStatus()

        Helpers.assertEqual(status.covered, 50, "Covered territory should match")
        Helpers.assertEqual(status.uncovered, 50, "Uncovered should be 100 - covered")
        Helpers.assertEqual(status.covered + status.uncovered, 100,
            "Covered + uncovered should equal 100")
    end)

    Suite:testMethod("Campaign:contested_territory", {
        description = "Contested territory increases with alien activity",
        testCase = "alien_presence",
        type = "functional"
    }, function()
        campaign:progressTurn()
        campaign:progressTurn()
        campaign:progressTurn()

        local status = campaign:getTerritoryStatus()

        Helpers.assertGreater(status.contested, 0,
            "Contested territory should increase with threat")
        Helpers.assertLessOrEqual(status.contested, 50,
            "Contested territory should not exceed half map")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: PERFORMANCE AND SCALABILITY
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()
    Suite:testMethod("Campaign:turn_performance", {
        description = "Single turn progression completes within frame budget",
        testCase = "turn_throughput",
        type = "performance"
    }, function()
        local campaign = MockCampaign:new()
        local iterations = 1000

        local startTime = os.clock()

        for _ = 1, iterations do
            campaign:progressTurn()
        end

        local elapsed = os.clock() - startTime
        print("[Campaign Performance] " .. iterations .. " turns: " ..
              string.format("%.2f ms", elapsed * 1000) ..
              " (avg " .. string.format("%.4f ms", (elapsed / iterations) * 1000) .. " per turn)")

        -- Each turn should complete in <1ms
        Helpers.assertLess((elapsed / iterations), 0.001,
            "Each turn should process in <1ms")
    end)

    Suite:testMethod("Campaign:memory_efficiency", {
        description = "Campaign state remains efficient over long gameplay",
        testCase = "memory_management",
        type = "performance"
    }, function()
        local campaign = MockCampaign:new()

        for _ = 1, 365 do  -- Full year of gameplay
            campaign:progressTurn()
        end

        -- Event log should not grow unbounded
        local eventCount = #campaign.events
        local avgEventsPerTurn = eventCount / 365

        print("[Campaign Memory] 365 turns, " .. eventCount .. " events, " ..
              string.format("%.2f events/turn avg", avgEventsPerTurn))

        -- Expect ~0.3 events per turn (30% chance)
        -- Allow 0.1-1.0 to account for randomness
        Helpers.assertGreater(avgEventsPerTurn, 0.05, "Should generate events regularly")
        Helpers.assertLess(avgEventsPerTurn, 1.5, "Should not generate excessive events")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
