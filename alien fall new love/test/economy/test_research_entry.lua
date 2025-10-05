--- Test suite for ResearchEntry class
-- @module test.economy.test_research_entry

local test_framework = require("test.framework.test_framework")
local ResearchEntry = require("src.economy.ResearchEntry")

local TestResearchEntry = {}

function TestResearchEntry.test_creation()
    local research_data = {
        id = "laser_weapons",
        name = "Laser Weapons",
        description = "Advanced directed energy weapons",
        category = "weapons",
        cost = 1000,
        baseTime = 10,
        prerequisites = { "basic_laser" },
        unlocks = {
            { type = "technology", id = "laser_rifle" },
            { type = "item", id = "laser_pistol" }
        },
        effects = {
            { type = "unlock_item", itemId = "laser_rifle" }
        }
    }

    local research = ResearchEntry(research_data)

    test_framework.assert_equal(research.id, "laser_weapons", "Research ID should match")
    test_framework.assert_equal(research.name, "Laser Weapons", "Research name should match")
    test_framework.assert_equal(research.category, "weapons", "Category should match")
    test_framework.assert_equal(research.cost, 1000, "Cost should match")
    test_framework.assert_equal(#research.prerequisites, 1, "Should have 1 prerequisite")
    test_framework.assert_equal(#research.unlocks, 2, "Should have 2 unlocks")
end

function TestResearchEntry.test_prerequisite_checking()
    local research_data = {
        id = "advanced_laser",
        name = "Advanced Laser",
        prerequisites = { "basic_laser", "power_systems" },
        cost = 1500
    }

    local research = ResearchEntry(research_data)

    -- Test with no completed research
    local meets_prereqs = research:meetsPrerequisites({})
    test_framework.assert_false(meets_prereqs, "Should not meet prerequisites with no completed research")

    -- Test with partial completion
    meets_prereqs = research:meetsPrerequisites({ basic_laser = true })
    test_framework.assert_false(meets_prereqs, "Should not meet prerequisites with partial completion")

    -- Test with full completion
    meets_prereqs = research:meetsPrerequisites({ basic_laser = true, power_systems = true })
    test_framework.assert_true(meets_prereqs, "Should meet prerequisites with full completion")
end

function TestResearchEntry.test_cost_calculation()
    local research_data = {
        id = "test_research",
        name = "Test Research",
        cost = 1000
    }

    local research = ResearchEntry(research_data)

    -- Test base cost
    local cost = research:calculateCost({})
    test_framework.assert_equal(cost, 1000, "Base cost should be 1000")

    -- Test with modifiers
    local modifiers = {
        globalMultiplier = 1.5,
        categoryMultipliers = { general = 0.8 },
        difficultyMultiplier = 1.2
    }
    cost = research:calculateCost(modifiers)
    -- 1000 * 1.5 * 0.8 * 1.2 = 1440
    test_framework.assert_equal(cost, 1440, "Modified cost should be correct")
end

function TestResearchEntry.test_time_calculation()
    local research_data = {
        id = "test_research",
        name = "Test Research",
        cost = 1000,
        baseTime = 10
    }

    local research = ResearchEntry(research_data)

    -- Test base time calculation
    local time = research:calculateTime(5, 1, {})  -- 5 scientists, 1 lab
    -- cost / (scientists * 8 hours) = 1000 / (5 * 8) = 1000 / 40 = 25 days
    test_framework.assert_equal(time, 25, "Time calculation should be correct")

    -- Test with modifiers
    local modifiers = { timeMultiplier = 0.8 }
    time = research:calculateTime(5, 1, modifiers)
    test_framework.assert_equal(time, 20, "Modified time should be correct")
end

function TestResearchEntry.test_unlocks_by_type()
    local research_data = {
        id = "test_research",
        name = "Test Research",
        unlocks = {
            { type = "technology", id = "tech1" },
            { type = "item", id = "item1" },
            { type = "technology", id = "tech2" },
            { type = "facility", id = "facility1" }
        }
    }

    local research = ResearchEntry(research_data)

    local tech_unlocks = research:getUnlocksByType("technology")
    test_framework.assert_equal(#tech_unlocks, 2, "Should have 2 technology unlocks")

    local item_unlocks = research:getUnlocksByType("item")
    test_framework.assert_equal(#item_unlocks, 1, "Should have 1 item unlock")

    local facility_unlocks = research:getUnlocksByType("facility")
    test_framework.assert_equal(#facility_unlocks, 1, "Should have 1 facility unlock")
end

function TestResearchEntry.test_research_completion()
    local research_data = {
        id = "test_research",
        name = "Test Research",
        cost = 100,
        effects = {
            { type = "unlock_item", itemId = "test_item" }
        }
    }

    local research = ResearchEntry(research_data)

    -- Test initial state
    test_framework.assert_false(research:isResearchCompleted(), "Should not be completed initially")
    test_framework.assert_false(research.isStarted, "Should not be started initially")

    -- Start research
    local started = research:startResearch(1)
    test_framework.assert_true(started, "Should start successfully")
    test_framework.assert_true(research.isStarted, "Should be marked as started")
    test_framework.assert_equal(research.startTime, 1, "Start time should be set")

    -- Simulate progress
    research:updateProgress(11, 1, 1)  -- 10 days elapsed, should complete
    test_framework.assert_true(research:isResearchCompleted(), "Should be completed after sufficient time")
    test_framework.assert_equal(research.progress, 100, "Progress should be 100%")
end

function TestResearchEntry.test_research_cancellation()
    local research_data = {
        id = "test_research",
        name = "Test Research",
        cost = 100
    }

    local research = ResearchEntry(research_data)

    -- Start research
    research:startResearch(1)

    -- Cancel research
    local cancelled = research:cancelResearch()
    test_framework.assert_true(cancelled, "Should cancel successfully")
    test_framework.assert_false(research.isStarted, "Should not be started after cancellation")
    test_framework.assert_equal(research.progress, 0, "Progress should reset to 0")
end

function TestResearchEntry.test_effect_application()
    local research_data = {
        id = "effect_test",
        name = "Effect Test",
        effects = {
            { type = "modify_stat", stat = "test_stat", value = 10 },
            { type = "unlock_item", itemId = "test_item" }
        }
    }

    local research = ResearchEntry(research_data)

    -- Mock game state
    local gameState = {
        stats = {},
        unlockedItems = {}
    }

    -- Apply effects
    research:applyEffects(gameState)

    test_framework.assert_equal(gameState.stats.test_stat, 10, "Stat should be modified")
    test_framework.assert_true(gameState.unlockedItems.test_item, "Item should be unlocked")
    test_framework.assert_true(research.isCompleted, "Research should be marked completed")
end

function TestResearchEntry.test_summary_generation()
    local research_data = {
        id = "summary_test",
        name = "Summary Test",
        category = "test",
        cost = 500,
        prerequisites = { "prereq1" },
        unlocks = { { type = "item", id = "item1" } }
    }

    local research = ResearchEntry(research_data)

    local summary = research:getSummary()
    test_framework.assert_equal(summary.id, "summary_test", "Summary ID should match")
    test_framework.assert_equal(summary.name, "Summary Test", "Summary name should match")
    test_framework.assert_equal(summary.category, "test", "Summary category should match")
    test_framework.assert_equal(summary.cost, 500, "Summary cost should match")
    test_framework.assert_equal(#summary.prerequisites, 1, "Summary prerequisites count should match")
    test_framework.assert_equal(#summary.unlocks, 1, "Summary unlocks count should match")
end

return TestResearchEntry