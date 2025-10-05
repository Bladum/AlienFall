--- Test suite for ScoreSystem class
-- @module test.organization.test_score_system

local test_framework = require("test.framework.test_framework")
local ScoreSystem = require("src.organization.ScoreSystem")

local TestScoreSystem = {}

function TestScoreSystem.test_creation()
    local score_system = ScoreSystem.new({})

    test_framework.assert_equal(score_system:get_country_score(), 0, "Initial country score should be 0")
    test_framework.assert_equal(score_system:get_monthly_funding_level(), 0, "Initial funding level should be 0")
    test_framework.assert_not_nil(score_system.province_scores, "Score system should have province scores table")
end

function TestScoreSystem.test_province_score_modification()
    local score_system = ScoreSystem.new({})

    -- Test positive score change
    local new_score = score_system:modify_province_score("province1", 50, "mission", "successful interception", "public")
    test_framework.assert_equal(new_score, 50, "Province score should increase by 50")
    test_framework.assert_equal(score_system:get_province_score("province1"), 50, "Province score should be 50")

    -- Test negative score change
    new_score = score_system:modify_province_score("province1", -20, "mission", "civilian casualties", "public")
    test_framework.assert_equal(new_score, 30, "Province score should decrease by 20")
    test_framework.assert_equal(score_system:get_province_score("province1"), 30, "Province score should be 30")
end

function TestScoreSystem.test_country_score_aggregation()
    local score_system = ScoreSystem.new({})

    -- Add scores to multiple provinces (within clamping limits)
    score_system:modify_province_score("province1", 40, "test", "test", "public")  -- 40 (within 50 limit)
    score_system:modify_province_score("province2", 30, "test", "test", "public")  -- 30 (within 50 limit)
    score_system:modify_province_score("province3", -25, "test", "test", "public") -- -25 (within 50 limit)

    test_framework.assert_equal(score_system:get_country_score(), 45, "Country score should be sum of province scores (40+30-25=45)")
end

function TestScoreSystem.test_monthly_funding_calculation()
    local score_system = ScoreSystem.new({})

    -- Set up province scores
    score_system:modify_province_score("province1", 250, "test", "test", "public") -- 250 points = 1 funding level

    local funding_level = score_system:calculate_monthly_funding()
    test_framework.assert_equal(funding_level, 1, "250 country score should give 1 funding level (floor(250/250))")

    -- Add more score
    score_system:modify_province_score("province1", 250, "test", "test", "public") -- Now 500 total

    funding_level = score_system:calculate_monthly_funding()
    test_framework.assert_equal(funding_level, 2, "500 country score should give 2 funding level")
end

function TestScoreSystem.test_visibility_filtering()
    local score_system = ScoreSystem.new({})

    -- Public action should affect score
    score_system:modify_province_score("province1", 100, "mission", "public interception", "public")
    test_framework.assert_equal(score_system:get_province_score("province1"), 100, "Public action should affect score")

    -- Classified action should not affect score
    score_system:modify_province_score("province1", 100, "mission", "classified operation", "classified")
    test_framework.assert_equal(score_system:get_province_score("province1"), 100, "Classified action should not affect score")
end

function TestScoreSystem.test_mission_score_processing()
    local score_system = ScoreSystem.new({})

    -- Test successful public interception
    local delta = score_system:process_mission_score("province1", "interception", true, "public", 0)
    test_framework.assert_equal(delta, 50, "Successful public interception should give +50 score")

    -- Test failed mission with casualties
    delta = score_system:process_mission_score("province1", "base_attack", false, "public", 3)
    test_framework.assert_equal(delta, -55, "Failed mission with 3 casualties should give -55 score")

    test_framework.assert_equal(score_system:get_province_score("province1"), -5, "Total province score should be -5")
end

function TestScoreSystem.test_base_event_score_processing()
    local score_system = ScoreSystem.new({})

    -- Test successful base defense
    local delta = score_system:process_base_event_score("province1", "attack_repelled", true)
    test_framework.assert_equal(delta, 80, "Repelled attack should give +80 score")

    -- Test base destruction
    delta = score_system:process_base_event_score("province1", "base_destroyed", false)
    test_framework.assert_equal(delta, -150, "Base destruction should give -150 score")

    test_framework.assert_equal(score_system:get_province_score("province1"), -70, "Total province score should be -70")
end

function TestScoreSystem.test_enemy_base_score_processing()
    local score_system = ScoreSystem.new({})

    -- Test daily penalty from level 3 base
    local delta = score_system:process_enemy_base_score("province1", 3, "daily_penalty")
    test_framework.assert_equal(delta, -15, "Level 3 base daily penalty should give -15 score")

    -- Test level penalty from level 4 base
    delta = score_system:process_enemy_base_score("province1", 4, "level_penalty")
    test_framework.assert_equal(delta, -100, "Level 4 base level penalty should give -100 score")

    test_framework.assert_equal(score_system:get_province_score("province1"), -115, "Total province score should be -115")
end

function TestScoreSystem.test_statistics()
    local score_system = ScoreSystem.new({})

    -- Set up test data
    score_system:modify_province_score("province1", 100, "test", "test", "public")
    score_system:modify_province_score("province2", 50, "test", "test", "public")
    score_system:modify_province_score("province3", -25, "test", "test", "public")

    local stats = score_system:get_statistics()

    test_framework.assert_equal(stats.province_count, 3, "Should track 3 provinces")
    test_framework.assert_equal(stats.total_score, 125, "Total score should be 125")
    test_framework.assert_equal(stats.country_score, 125, "Country score should be 125")
    test_framework.assert_equal(stats.positive_provinces, 2, "Should have 2 positive provinces")
    test_framework.assert_equal(stats.negative_provinces, 1, "Should have 1 negative province")
    test_framework.assert_equal(stats.average_score, 125/3, "Average score should be correct")
end

function TestScoreSystem.test_history()
    local score_system = ScoreSystem.new({})

    score_system:modify_province_score("province1", 100, "mission", "interception", "public")
    score_system:modify_province_score("province1", -20, "mission", "casualties", "public")
    score_system:modify_province_score("province2", 50, "base", "defense", "public")

    local history = score_system:get_history()
    test_framework.assert_equal(#history, 3, "Should have 3 history entries")

    -- Test filtering
    local province1_history = score_system:get_history({ province_id = "province1" })
    test_framework.assert_equal(#province1_history, 2, "Province1 should have 2 history entries")

    local mission_history = score_system:get_history({ source = "mission" })
    test_framework.assert_equal(#mission_history, 2, "Should have 2 mission history entries")
end

function TestScoreSystem.test_funding_amount_calculation()
    local score_system = ScoreSystem.new({})

    -- Set up score for funding level 2
    score_system:modify_province_score("province1", 500, "test", "test", "public")
    score_system:calculate_monthly_funding()

    local funding_amount = score_system:get_monthly_funding_amount(1000) -- $1000 economy
    test_framework.assert_equal(funding_amount, 2000, "Funding level 2 with $1000 economy should give $2000")

    local funding_amount2 = score_system:get_monthly_funding_amount(2000) -- $2000 economy
    test_framework.assert_equal(funding_amount2, 4000, "Funding level 2 with $2000 economy should give $4000")
end

--- Run all ScoreSystem tests
function TestScoreSystem.run()
    test_framework.run_suite("ScoreSystem", {
        test_initialization = TestScoreSystem.test_initialization,
        test_province_scoring = TestScoreSystem.test_province_scoring,
        test_country_score_aggregation = TestScoreSystem.test_country_score_aggregation,
        test_funding_calculation = TestScoreSystem.test_funding_calculation,
        test_history = TestScoreSystem.test_history,
        test_funding_levels = TestScoreSystem.test_funding_levels
    })
end

return TestScoreSystem
