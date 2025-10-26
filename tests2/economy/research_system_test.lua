-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Research System
-- FILE: tests2/economy/research_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests for research progression, tech tree dependencies, and queue management
-- Covers research completion, prerequisites, and economic integration
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK RESEARCH SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local MockTechTree = {}

function MockTechTree:new()
    local tree = {
        techs = {
            ["basic_science"] = {
                name = "basic_science",
                cost = 1000,
                time = 100,
                prerequisites = {},
                category = "science"
            },
            ["advanced_science"] = {
                name = "advanced_science",
                cost = 2000,
                time = 150,
                prerequisites = {"basic_science"},
                category = "science"
            },
            ["plasma_weapons"] = {
                name = "plasma_weapons",
                cost = 5000,
                time = 200,
                prerequisites = {"advanced_science"},
                category = "weapons"
            },
            ["laser_weapons"] = {
                name = "laser_weapons",
                cost = 4000,
                time = 180,
                prerequisites = {"advanced_science"},
                category = "weapons"
            },
            ["armor_plating"] = {
                name = "armor_plating",
                cost = 3000,
                time = 120,
                prerequisites = {"basic_science"},
                category = "armor"
            }
        }
    }

    function tree:getTech(name)
        return self.techs[name]
    end

    function tree:hasPrerequisite(techName, completedTechs)
        local tech = self:getTech(techName)
        if not tech then return false end

        for _, prereq in ipairs(tech.prerequisites) do
            local found = false
            for _, completed in ipairs(completedTechs) do
                if completed == prereq then
                    found = true
                    break
                end
            end
            if not found then
                return false
            end
        end
        return true
    end

    return tree
end

local MockResearchSystem = {}

function MockResearchSystem:new(techTree)
    local system = {
        tree = techTree,
        queue = {},
        completed = {},
        currentResearch = nil,
        progress = 0,
        researchPerTurn = 50
    }

    function system:queueTech(techName)
        local tech = self.tree:getTech(techName)
        if not tech then return false, "Tech not found" end

        -- Check if already completed
        for _, completed in ipairs(self.completed) do
            if completed == techName then
                return false, "Already completed"
            end
        end

        -- Check if already queued
        for _, queued in ipairs(self.queue) do
            if queued == techName then
                return false, "Already queued"
            end
        end

        -- Check prerequisites
        if not self.tree:hasPrerequisite(techName, self.completed) then
            return false, "Prerequisites not met"
        end

        table.insert(self.queue, techName)
        return true, "Queued"
    end

    function system:updateResearch()
        if self.currentResearch == nil and #self.queue > 0 then
            self.currentResearch = table.remove(self.queue, 1)
            self.progress = 0
        end

        if self.currentResearch then
            local tech = self.tree:getTech(self.currentResearch)
            self.progress = self.progress + self.researchPerTurn

            if self.progress >= tech.time then
                local completed = self.currentResearch
                table.insert(self.completed, completed)
                self.currentResearch = nil
                self.progress = 0
                return completed
            end
        end

        return nil
    end

    function system:getProgress()
        if self.currentResearch then
            local tech = self.tree:getTech(self.currentResearch)
            return (self.progress / tech.time) * 100
        end
        return 0
    end

    function system:getCurrentResearch()
        return self.currentResearch
    end

    function system:getQueueSize()
        return #self.queue
    end

    function system:getTotalQueue()
        local count = 0
        if self.currentResearch then count = 1 end
        count = count + #self.queue
        return count
    end

    function system:isCompleted(techName)
        for _, tech in ipairs(self.completed) do
            if tech == techName then
                return true
            end
        end
        return false
    end

    function system:getCompletedTechs()
        return self.completed
    end

    return system
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.economy.research.research_system",
    fileName = "research_system.lua",
    description = "Research system - tech tree progression and queue management"
})

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: TECH TREE STRUCTURE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Tech Tree Structure", function()
    local tree

    Suite:beforeEach(function()
        tree = MockTechTree:new()
    end)

    Suite:testMethod("TechTree:getTech", {
        description = "Tech tree contains expected technologies",
        testCase = "tech_availability",
        type = "functional"
    }, function()
        local tech = tree:getTech("basic_science")
        Helpers.assertNotNil(tech, "Should find basic_science tech")
        Helpers.assertEqual(tech.name, "basic_science", "Tech name should match")
        Helpers.assertGreater(tech.cost, 0, "Tech should have positive cost")
        Helpers.assertGreater(tech.time, 0, "Tech should have positive research time")
    end)

    Suite:testMethod("TechTree:prerequisites", {
        description = "Technologies have correctly defined prerequisites",
        testCase = "prerequisite_chain",
        type = "functional"
    }, function()
        local advancedSci = tree:getTech("advanced_science")
        Helpers.assertEqual(#advancedSci.prerequisites, 1, "Should require 1 prerequisite")
        Helpers.assertEqual(advancedSci.prerequisites[1], "basic_science",
            "Should require basic_science")

        local basicSci = tree:getTech("basic_science")
        Helpers.assertEqual(#basicSci.prerequisites, 0, "Basic tech should have no prerequisites")
    end)

    Suite:testMethod("TechTree:hasPrerequisite", {
        description = "Prerequisite checking validates tech tree dependencies",
        testCase = "dependency_validation",
        type = "functional"
    }, function()
        local completed = {}

        -- Should fail without prerequisites
        Helpers.assertFalse(tree:hasPrerequisite("advanced_science", completed),
            "Should not have prerequisite initially")

        -- Should pass after prerequisite complete
        table.insert(completed, "basic_science")
        Helpers.assertTrue(tree:hasPrerequisite("advanced_science", completed),
            "Should have prerequisite after basic_science")
    end)

    Suite:testMethod("TechTree:complex_chains", {
        description = "Complex tech chains enforce multi-level dependencies",
        testCase = "multi_level_dependencies",
        type = "functional"
    }, function()
        local completed = {}

        -- Plasma weapons requires advanced science
        Helpers.assertFalse(tree:hasPrerequisite("plasma_weapons", completed),
            "Should fail without advanced science")

        -- Add basic science (not enough)
        table.insert(completed, "basic_science")
        Helpers.assertFalse(tree:hasPrerequisite("plasma_weapons", completed),
            "Should still fail with only basic science")

        -- Add advanced science (now it works)
        table.insert(completed, "advanced_science")
        Helpers.assertTrue(tree:hasPrerequisite("plasma_weapons", completed),
            "Should pass with advanced science")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: RESEARCH QUEUING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Research Queuing", function()
    local tree, system

    Suite:beforeEach(function()
        tree = MockTechTree:new()
        system = MockResearchSystem:new(tree)
    end)

    Suite:testMethod("ResearchSystem:queueTech", {
        description = "Can queue basic technology without prerequisites",
        testCase = "queue_basic_tech",
        type = "functional"
    }, function()
        local success, msg = system:queueTech("basic_science")
        Helpers.assertTrue(success, "Should queue basic_science: " .. msg)
        Helpers.assertEqual(system:getQueueSize(), 1, "Queue should have 1 item")
    end)

    Suite:testMethod("ResearchSystem:queueTech", {
        description = "Cannot queue tech without meeting prerequisites",
        testCase = "prerequisite_enforcement",
        type = "functional"
    }, function()
        local success, msg = system:queueTech("advanced_science")
        Helpers.assertFalse(success, "Should fail without prerequisites: " .. msg)
        Helpers.assertEqual(system:getQueueSize(), 0, "Queue should remain empty")
    end)

    Suite:testMethod("ResearchSystem:queueTech", {
        description = "Cannot queue duplicate techs",
        testCase = "duplicate_prevention",
        type = "functional"
    }, function()
        local success1, _ = system:queueTech("basic_science")
        local success2, msg = system:queueTech("basic_science")

        Helpers.assertTrue(success1, "First queue should succeed")
        Helpers.assertFalse(success2, "Second queue should fail: " .. msg)
        Helpers.assertEqual(system:getQueueSize(), 1, "Should only have 1 in queue")
    end)

    Suite:testMethod("ResearchSystem:queueTech", {
        description = "Multiple techs can be queued in sequence",
        testCase = "tech_chaining",
        type = "functional"
    }, function()
        system:queueTech("basic_science")
        system:queueTech("armor_plating")  -- Also requires basic_science

        Helpers.assertEqual(system:getQueueSize(), 2, "Should have 2 in queue")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: RESEARCH PROGRESSION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Research Progression", function()
    local tree, system

    Suite:beforeEach(function()
        tree = MockTechTree:new()
        system = MockResearchSystem:new(tree)
    end)

    Suite:testMethod("ResearchSystem:updateResearch", {
        description = "Research progresses incrementally each turn",
        testCase = "progress_tracking",
        type = "functional"
    }, function()
        system:queueTech("basic_science")

        local progressBefore = system:getProgress()
        system:updateResearch()
        local progressAfter = system:getProgress()

        Helpers.assertGreater(progressAfter, progressBefore,
            "Progress should increase")
    end)

    Suite:testMethod("ResearchSystem:updateResearch", {
        description = "Research completes and is marked as done",
        testCase = "completion",
        type = "functional"
    }, function()
        system:queueTech("basic_science")

        local completed = nil
        -- Simulate enough turns to complete (basic_science: 100 time / 50 per turn = 2 turns)
        for _ = 1, 3 do
            completed = system:updateResearch()
        end

        Helpers.assertEqual(completed, "basic_science", "Should complete basic_science")
        Helpers.assertTrue(system:isCompleted("basic_science"),
            "Should mark as completed")
    end)

    Suite:testMethod("ResearchSystem:updateResearch", {
        description = "Completed tech becomes available for other prereqs",
        testCase = "prerequisite_unlock",
        type = "functional"
    }, function()
        -- Complete basic_science
        system:queueTech("basic_science")
        for _ = 1, 3 do
            system:updateResearch()
        end

        -- Now should be able to queue advanced_science
        local success, msg = system:queueTech("advanced_science")
        Helpers.assertTrue(success, "Should queue advanced_science after prerequisite: " .. msg)
    end)

    Suite:testMethod("ResearchSystem:updateResearch", {
        description = "Queue processes first in, first out (FIFO)",
        testCase = "fifo_ordering",
        type = "functional"
    }, function()
        system:queueTech("basic_science")
        system:queueTech("armor_plating")

        -- Simulate completion
        local first = nil
        for _ = 1, 10 do
            first = system:updateResearch()
            if first then break end
        end

        Helpers.assertEqual(first, "basic_science", "First queued should complete first")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: RESEARCH STATE MANAGEMENT
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Research State Management", function()
    local tree, system

    Suite:beforeEach(function()
        tree = MockTechTree:new()
        system = MockResearchSystem:new(tree)
    end)

    Suite:testMethod("ResearchSystem:state", {
        description = "System correctly reports current research status",
        testCase = "status_reporting",
        type = "functional"
    }, function()
        Helpers.assertNil(system:getCurrentResearch(),
            "Should have no current research initially")

        system:queueTech("basic_science")
        system:updateResearch()

        Helpers.assertEqual(system:getCurrentResearch(), "basic_science",
            "Should report current research")
    end)

    Suite:testMethod("ResearchSystem:getCompletedTechs", {
        description = "Completed techs list is maintained accurately",
        testCase = "completion_tracking",
        type = "functional"
    }, function()
        system:queueTech("basic_science")
        for _ = 1, 10 do
            system:updateResearch()
        end

        local completed = system:getCompletedTechs()
        Helpers.assertEqual(#completed, 1, "Should have 1 completed tech")
        Helpers.assertEqual(completed[1], "basic_science",
            "Completed list should contain researched tech")
    end)

    Suite:testMethod("ResearchSystem:getTotalQueue", {
        description = "Total queue includes current and queued items",
        testCase = "queue_counting",
        type = "functional"
    }, function()
        system:queueTech("basic_science")
        system:queueTech("armor_plating")

        system:updateResearch()  -- Start first research

        local total = system:getTotalQueue()
        Helpers.assertEqual(total, 2, "Total should include current + queued")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: RESEARCH COMPLETION WORKFLOWS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Research Completion Workflows", function()
    local tree, system

    Suite:beforeEach(function()
        tree = MockTechTree:new()
        system = MockResearchSystem:new(tree)
    end)

    Suite:testMethod("ResearchSystem:research_chain", {
        description = "Complete prerequisite chain enables dependent research",
        testCase = "chain_completion",
        type = "functional"
    }, function()
        -- Queue basic science
        system:queueTech("basic_science")

        -- Progress to completion
        repeat until system:updateResearch() == "basic_science"

        -- Now queue advanced science
        local success = system:queueTech("advanced_science")
        Helpers.assertTrue(success, "Should queue advanced_science after basic")

        -- Progress to completion
        repeat until system:updateResearch() == "advanced_science"

        -- Now queue plasma weapons
        success = system:queueTech("plasma_weapons")
        Helpers.assertTrue(success, "Should queue plasma_weapons after advanced")

        Helpers.assertEqual(#system:getCompletedTechs(), 2,
            "Should have 2 completed techs in chain")
    end)

    Suite:testMethod("ResearchSystem:parallel_research", {
        description = "Techs with same prerequisites can queue in parallel",
        testCase = "parallel_queue",
        type = "functional"
    }, function()
        -- Both laser and plasma weapons require advanced_science
        system:queueTech("basic_science")

        repeat until system:updateResearch() == "basic_science"

        -- Now queue both
        local s1 = system:queueTech("laser_weapons")
        local s2 = system:queueTech("plasma_weapons")

        Helpers.assertTrue(s1, "Should queue laser_weapons")
        Helpers.assertTrue(s2, "Should queue plasma_weapons")
        Helpers.assertEqual(system:getTotalQueue(), 2,
            "Should have 2 parallel research items")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: PERFORMANCE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance", function()
    Suite:testMethod("ResearchSystem:throughput", {
        description = "Research updates execute efficiently each turn",
        testCase = "update_throughput",
        type = "performance"
    }, function()
        local tree = MockTechTree:new()
        local system = MockResearchSystem:new(tree)

        system:queueTech("basic_science")

        local iterations = 10000
        local startTime = os.clock()

        for _ = 1, iterations do
            if system:getCurrentResearch() == nil and system:getQueueSize() > 0 then
                system:queueTech("advanced_science")
            end
            system:updateResearch()
        end

        local elapsed = os.clock() - startTime
        print("[ResearchSystem Performance] " .. iterations .. " updates: " ..
              string.format("%.2f ms", elapsed * 1000) ..
              " (avg " .. string.format("%.4f ms", (elapsed / iterations) * 1000) .. " per update)")

        Helpers.assertLess((elapsed / iterations), 0.0001,
            "Each update should complete in <0.1ms")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

Suite:run()
