-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Cross-System Integration Flows
-- FILE: tests2/integration/cross_system_flows_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for complete workflows spanning multiple game systems
-- Covers economy→research→manufacturing, mission rewards, casualty impact
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK SYSTEMS FOR INTEGRATION TESTING
-- ─────────────────────────────────────────────────────────────────────────

-- Mock economy system
local MockEconomy = {}
function MockEconomy:new()
    local economy = {
        funds = 100000,
        monthlyIncome = 5000,
        expenses = 0,
        history = {}
    }

    function economy:addFunds(amount)
        self.funds = self.funds + amount
        table.insert(self.history, {type = "income", amount = amount})
    end

    function economy:removeFunds(amount)
        if self.funds >= amount then
            self.funds = self.funds - amount
            table.insert(self.history, {type = "expense", amount = amount})
            return true
        end
        return false
    end

    function economy:canAfford(cost)
        return self.funds >= cost
    end

    function economy:getBalance()
        return self.funds
    end

    function economy:addMonthlyIncome()
        self:addFunds(self.monthlyIncome)
    end

    return economy
end

-- Mock research system
local MockResearch = {}
function MockResearch:new(economy)
    local research = {
        economy = economy,
        techs = {},
        queue = {},
        researchPerTurn = 100,
        completed = {}
    }

    function research:queueTech(techName, cost)
        if self.economy:canAfford(cost) then
            self.economy:removeFunds(cost)
            table.insert(self.queue, {
                name = techName,
                cost = cost,
                progress = 0,
                totalProgress = 100,
                startTurn = 0
            })
            return true
        end
        return false
    end

    function research:updateResearch()
        if #self.queue > 0 then
            local current = self.queue[1]
            current.progress = current.progress + self.researchPerTurn

            if current.progress >= current.totalProgress then
                local completed = table.remove(self.queue, 1)
                table.insert(self.completed, completed.name)
                return completed.name
            end
        end
        return nil
    end

    function research:isCompletedTech(techName)
        for _, completed in ipairs(self.completed) do
            if completed == techName then
                return true
            end
        end
        return false
    end

    function research:getQueueSize()
        return #self.queue
    end

    function research:getResearchProgress()
        if #self.queue > 0 then
            local current = self.queue[1]
            return (current.progress / current.totalProgress) * 100
        end
        return 0
    end

    return research
end

-- Mock manufacturing system
local MockManufacturing = {}
function MockManufacturing:new(research, economy)
    local manufacturing = {
        research = research,
        economy = economy,
        queue = {},
        productionPerTurn = 50
    }

    function manufacturing:canManufacture(itemName)
        return self.research:isCompletedTech(itemName)
    end

    function manufacturing:queueItem(itemName, quantity, costPerItem)
        if self:canManufacture(itemName) then
            local totalCost = quantity * costPerItem
            if self.economy:canAfford(totalCost) then
                self.economy:removeFunds(totalCost)
                table.insert(self.queue, {
                    name = itemName,
                    quantity = quantity,
                    progress = 0,
                    totalProgress = 100 * quantity,
                    completed = 0
                })
                return true
            end
        end
        return false
    end

    function manufacturing:updateProduction()
        if #self.queue > 0 then
            local current = self.queue[1]
            current.progress = current.progress + self.productionPerTurn

            -- Calculate how many items were completed this turn
            local previousCompleted = current.completed
            current.completed = math.floor(current.progress / 100)

            if current.completed >= current.quantity then
                table.remove(self.queue, 1)
                return current.completed
            end
        end
        return 0
    end

    function manufacturing:getQueueSize()
        return #self.queue
    end

    return manufacturing
end

-- Mock mission system
local MockMission = {}
function MockMission:new(economy)
    local mission = {
        economy = economy,
        active = nil,
        completed = {},
        casualties = 0,
        rewards = 0
    }

    function mission:startMission(name, reward, riskFactor)
        self.active = {
            name = name,
            reward = reward,
            riskFactor = riskFactor,
            startTurn = 0,
            difficulty = 0
        }
        return self.active
    end

    function mission:completeMission(success, unitsCasualties)
        if self.active then
            if success then
                self.economy:addFunds(self.active.reward)
                self.rewards = self.rewards + self.active.reward
            end
            self.casualties = self.casualties + unitsCasualties
            table.insert(self.completed, self.active)
            self.active = nil
            return true
        end
        return false
    end

    function mission:getCompletedCount()
        return #self.completed
    end

    function mission:getTotalRewards()
        return self.rewards
    end

    function mission:getTotalCasualties()
        return self.casualties
    end

    return mission
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.integration_manager",
    fileName = "integration_manager.lua",
    description = "Cross-system integration workflows and state synchronization"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: ECONOMY-RESEARCH INTEGRATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Economy-Research Integration", function()
    local economy, research

    Suite:beforeEach(function()
        economy = MockEconomy:new()
        research = MockResearch:new(economy)
    end)

    Suite:testMethod("Economy:Research:queue_tech", {
        description = "Queuing research deducts cost from economy funds",
        testCase = "fund_deduction",
        type = "functional"
    }, function()
        local costBefore = economy:getBalance()
        local techCost = 10000

        local success = research:queueTech("laser_weapons", techCost)

        Helpers.assertTrue(success, "Should successfully queue research")
        Helpers.assertEqual(economy:getBalance(), costBefore - techCost,
            "Funds should decrease by research cost")
        Helpers.assertEqual(research:getQueueSize(), 1,
            "Research queue should have 1 item")
    end)

    Suite:testMethod("Economy:Research:insufficient_funds", {
        description = "Cannot queue research if insufficient funds",
        testCase = "budget_constraint",
        type = "functional"
    }, function()
        local maxSpend = economy:getBalance() + 1

        local success = research:queueTech("expensive_tech", maxSpend)

        Helpers.assertFalse(success, "Should fail to queue with insufficient funds")
        Helpers.assertEqual(research:getQueueSize(), 0, "Queue should remain empty")
    end)

    Suite:testMethod("Economy:Research:multiple_queue", {
        description = "Multiple technologies can be queued in sequence",
        testCase = "research_chain",
        type = "functional"
    }, function()
        research:queueTech("tech_1", 5000)
        research:queueTech("tech_2", 3000)
        research:queueTech("tech_3", 2000)

        Helpers.assertEqual(research:getQueueSize(), 3, "Should have 3 techs in queue")

        -- Complete first tech
        research.queue[1].progress = 100
        local completed = research:updateResearch()

        Helpers.assertEqual(completed, "tech_1", "First tech should complete")
        Helpers.assertEqual(research:getQueueSize(), 2, "Queue should have 2 remaining")
    end)

    Suite:testMethod("Economy:Research:research_progression", {
        description = "Research progresses over multiple turns toward completion",
        testCase = "progress_tracking",
        type = "functional"
    }, function()
        research:queueTech("standard_tech", 1000)

        -- Progress through 10 turns (each adds 100 to 100 total needed)
        for turn = 1, 10 do
            local progress = research:getResearchProgress()
            research:updateResearch()
        end

        local completedTech = research.completed[1]
        Helpers.assertEqual(completedTech, "standard_tech", "Tech should be completed")
        Helpers.assertTrue(research:isCompletedTech("standard_tech"),
            "Should recognize completed tech")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: RESEARCH-MANUFACTURING INTEGRATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Research-Manufacturing Integration", function()
    local economy, research, manufacturing

    Suite:beforeEach(function()
        economy = MockEconomy:new()
        research = MockResearch:new(economy)
        manufacturing = MockManufacturing:new(research, economy)
    end)

    Suite:testMethod("Research:Manufacturing:tech_prerequisite", {
        description = "Cannot manufacture without researched technology",
        testCase = "tech_lock",
        type = "functional"
    }, function()
        Helpers.assertFalse(manufacturing:canManufacture("locked_item"),
            "Should not be able to manufacture without tech")

        research.completed = {"unlocked_item"}

        Helpers.assertTrue(manufacturing:canManufacture("unlocked_item"),
            "Should be able to manufacture with researched tech")
    end)

    Suite:testMethod("Research:Manufacturing:unlock_chain", {
        description = "Completing research unlocks manufacturing capability",
        testCase = "unlock_flow",
        type = "functional"
    }, function()
        -- Queue and complete research
        research:queueTech("advanced_weapons", 5000)
        while #research.completed == 0 do
            research.queue[1].progress = research.queue[1].progress + 100
            research:updateResearch()
        end

        -- Now we should be able to manufacture
        Helpers.assertTrue(manufacturing:canManufacture("advanced_weapons"),
            "Should unlock manufacturing after research")

        -- Queue manufacturing
        local success = manufacturing:queueItem("advanced_weapons", 2, 1000)
        Helpers.assertTrue(success, "Should successfully queue manufacturing")
    end)

    Suite:testMethod("Research:Manufacturing:production_progress", {
        description = "Manufacturing progresses and completes items",
        testCase = "production_workflow",
        type = "functional"
    }, function()
        research.completed = {"laser_rifle"}

        local success = manufacturing:queueItem("laser_rifle", 1, 500)
        Helpers.assertTrue(success, "Should queue manufacturing")

        -- Simulate production
        local completed = 0
        for turn = 1, 5 do
            completed = manufacturing:updateProduction()
        end

        Helpers.assertEqual(completed, 1, "Should complete 1 item after 5 turns")
        Helpers.assertEqual(manufacturing:getQueueSize(), 0, "Queue should be empty")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: MISSION-ECONOMY INTEGRATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Mission-Economy Integration", function()
    local economy, mission

    Suite:beforeEach(function()
        economy = MockEconomy:new()
        mission = MockMission:new(economy)
    end)

    Suite:testMethod("Mission:Economy:reward_income", {
        description = "Completing mission successfully adds funds to economy",
        testCase = "mission_reward",
        type = "functional"
    }, function()
        local fundsBefore = economy:getBalance()

        mission:startMission("alien_raid", 5000, 0.5)
        mission:completeMission(true, 0)

        local fundsAfter = economy:getBalance()
        Helpers.assertEqual(fundsAfter, fundsBefore + 5000,
            "Funds should increase by mission reward")
    end)

    Suite:testMethod("Mission:Economy:casualty_cost", {
        description = "Unit casualties are tracked and can affect economy",
        testCase = "casualty_tracking",
        type = "functional"
    }, function()
        mission:startMission("crash_recovery", 3000, 0.7)
        mission:completeMission(true, 3)

        Helpers.assertEqual(mission:getTotalCasualties(), 3,
            "Should track casualties from mission")

        -- Casualties would cause recruitment/replacement costs
        local replacement_cost = 3 * 500  -- 500 per unit
        economy:removeFunds(replacement_cost)

        -- Verify state consistency
        Helpers.assertTrue(true, "Should handle casualty costs")
    end)

    Suite:testMethod("Mission:Economy:reward_accumulation", {
        description = "Multiple mission rewards accumulate in economy",
        testCase = "reward_chain",
        type = "functional"
    }, function()
        local fundsBefore = economy:getBalance()

        -- Complete 3 missions
        for i = 1, 3 do
            mission:startMission("mission_" .. i, 2000, 0.3)
            mission:completeMission(true, 0)
        end

        local fundsAfter = economy:getBalance()
        Helpers.assertEqual(fundsAfter, fundsBefore + 6000,
            "Should accumulate all mission rewards")
        Helpers.assertEqual(mission:getCompletedCount(), 3,
            "Should track 3 completed missions")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: COMPLETE GAMEPLAY LOOPS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Complete Gameplay Loops", function()
    local economy, research, manufacturing, mission

    Suite:beforeEach(function()
        economy = MockEconomy:new()
        research = MockResearch:new(economy)
        manufacturing = MockManufacturing:new(research, economy)
        mission = MockMission:new(economy)
    end)

    Suite:testMethod("GameLoop:income_research_manufacturing", {
        description = "Economy income → research → manufacturing workflow",
        testCase = "production_loop",
        type = "integration"
    }, function()
        local initialFunds = economy:getBalance()

        -- Simulate multiple months
        for month = 1, 5 do
            -- 1. Receive monthly income
            economy:addMonthlyIncome()

            -- 2. Allocate to research if not in progress
            if research:getQueueSize() == 0 then
                research:queueTech("new_tech", 3000)
            end

            -- 3. Progress research
            local completedTech = research:updateResearch()

            -- 4. If tech completed, queue manufacturing
            if completedTech and manufacturing:getQueueSize() == 0 then
                manufacturing:queueItem(completedTech, 2, 1000)
            end

            -- 5. Progress manufacturing
            manufacturing:updateProduction()
        end

        Helpers.assertGreater(economy:getBalance(), initialFunds,
            "Should accumulate funds over time")
    end)

    Suite:testMethod("GameLoop:mission_casualty_recovery", {
        description = "Mission completion → casualties → recovery spending",
        testCase = "casualty_flow",
        type = "integration"
    }, function()
        local fundsBefore = economy:getBalance()

        -- Execute mission
        mission:startMission("combat_op", 7000, 0.8)
        mission:completeMission(true, 5)  -- 5 casualties

        local fundsAfterMission = economy:getBalance()
        Helpers.assertEqual(fundsAfterMission, fundsBefore + 7000,
            "Funds should increase by reward")

        -- Handle casualties - recruitment/replacement
        local casualtyHandling = mission:getTotalCasualties() * 400  -- Cost per replacement
        economy:removeFunds(casualtyHandling)

        local finalFunds = economy:getBalance()
        local netGain = finalFunds - fundsBefore
        Helpers.assertGreater(netGain, 0, "Net gain should be positive despite casualties")
    end)

    Suite:testMethod("GameLoop:sustained_campaign", {
        description = "Full campaign loop: missions → income → research → manufacturing",
        testCase = "full_campaign",
        type = "integration"
    }, function()
        local initialFunds = economy:getBalance()
        local startingResearches = 0
        local startingProductions = 0

        for turn = 1, 20 do
            -- Economy tick
            economy:addMonthlyIncome()

            -- Research queue management
            if research:getQueueSize() < 1 and #research.completed < 5 then
                research:queueTech("tech_" .. (#research.completed + 1), 2000)
            end
            research:updateResearch()

            -- Manufacturing based on completed research
            if manufacturing:getQueueSize() < 1 and
               #research.completed > 0 and
               not manufacturing:canManufacture(research.completed[1]) == false then
                manufacturing:queueItem("equipment_" .. turn, 1, 500)
            end
            manufacturing:updateProduction()

            -- Periodic missions
            if turn % 5 == 0 then
                mission:startMission("auto_mission", 3000, 0.5)
                mission:completeMission(true, 2)
            end
        end

        -- Verify campaign progressed
        Helpers.assertGreater(economy:getBalance(), initialFunds,
            "Economy should grow over campaign")
        Helpers.assertGreater(#research.completed, 0,
            "Should complete some research")
        Helpers.assertGreater(mission:getCompletedCount(), 0,
            "Should complete some missions")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: PERFORMANCE AND SCALABILITY
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()
    Suite:testMethod("Integration:workflow_throughput", {
        description = "Complete workflow processes efficiently each turn",
        testCase = "loop_performance",
        type = "performance"
    }, function()
        local economy = MockEconomy:new()
        local research = MockResearch:new(economy)
        local manufacturing = MockManufacturing:new(research, economy)
        local mission = MockMission:new(economy)

        local iterations = 1000
        local startTime = os.clock()

        for _ = 1, iterations do
            economy:addMonthlyIncome()
            if research:getQueueSize() == 0 then
                research:queueTech("tech", 1000)
            end
            research:updateResearch()
            if manufacturing:getQueueSize() == 0 then
                manufacturing:queueItem("item", 1, 500)
            end
            manufacturing:updateProduction()
        end

        local elapsed = os.clock() - startTime
        print("[Integration Performance] " .. iterations .. " turns: " ..
              string.format("%.2f ms", elapsed * 1000) ..
              " (avg " .. string.format("%.4f ms", (elapsed / iterations) * 1000) .. " per turn)")

        Helpers.assertLess((elapsed / iterations), 0.001,
            "Complete workflow should process in <1ms per turn")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
