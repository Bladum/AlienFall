--- Test suite for FameSystem class
-- @module test.organization.test_fame_system

local test_framework = require("test.framework.test_framework")
local FameSystem = require("src.organization.FameSystem")

local TestFameSystem = {}

function TestFameSystem.test_creation()
    local fame_system = FameSystem.new({})

    test_framework.assert_equal(fame_system:get_fame(), 0, "Initial fame should be 0")
    test_framework.assert_equal(fame_system:get_fame_level(), "Obscure", "Initial fame level should be Obscure")
    test_framework.assert_not_nil(fame_system.modifiers, "Fame system should have modifiers table")
end

function TestFameSystem.test_fame_modification()
    local fame_system = FameSystem.new({})

    -- Test positive fame change (clamped to max 20)
    local new_fame = fame_system:modify_fame(25, "mission", "successful interception")
    test_framework.assert_equal(new_fame, 20, "Fame should increase by 20 (clamped)")
    test_framework.assert_equal(fame_system:get_fame(), 20, "Fame should be 20")

    -- Test negative fame change
    new_fame = fame_system:modify_fame(-10, "mission", "civilian casualties")
    test_framework.assert_equal(new_fame, 10, "Fame should decrease by 10")
    test_framework.assert_equal(fame_system:get_fame(), 10, "Fame should be 10")
end

function TestFameSystem.test_fame_levels()
    local fame_system = FameSystem.new({})

    -- Test Obscure level (0-20)
    test_framework.assert_equal(fame_system:get_fame_level(), "Obscure", "Fame 0 should be Obscure")

    -- Test Notable level (21-40) - need to reach at least 21
    fame_system:modify_fame(21, "test", "test")  -- This will be clamped to 20, so still Obscure
    test_framework.assert_equal(fame_system:get_fame_level(), "Obscure", "Fame 20 should still be Obscure")
    
    -- Add another 5 to reach Notable
    fame_system:modify_fame(5, "test", "test")
    test_framework.assert_equal(fame_system:get_fame_level(), "Notable", "Fame 25 should be Notable")

    -- Test Prominent level (41-60) - continue from 25
    fame_system:modify_fame(20, "test", "test")  -- 25 + 20 = 45
    test_framework.assert_equal(fame_system:get_fame_level(), "Prominent", "Fame 45 should be Prominent")

    -- Test Famous level (61-80)
    fame_system:modify_fame(20, "test", "test")  -- 45 + 20 = 65
    test_framework.assert_equal(fame_system:get_fame_level(), "Famous", "Fame 65 should be Famous")

    -- Test Legendary level (81-100)
    fame_system:modify_fame(20, "test", "test")  -- 65 + 20 = 85
    test_framework.assert_equal(fame_system:get_fame_level(), "Legendary", "Fame 85 should be Legendary")
end

function TestFameSystem.test_fame_modifiers()
    local fame_system = FameSystem.new({})

    -- Add a multiplier modifier
    test_framework.assert_true(fame_system:add_modifier("test_mod", {
        type = "multiplier",
        value = 2.0,
        source = "test"
    }), "Should add modifier successfully")

    -- Test that modifier exists
    local modifiers = fame_system:get_modifiers()
    test_framework.assert_equal(#modifiers, 1, "Should have 1 modifier")
    test_framework.assert_equal(modifiers[1].id, "test_mod", "Modifier should have correct ID")

    -- Remove modifier
    test_framework.assert_true(fame_system:remove_modifier("test_mod"), "Should remove modifier successfully")
    test_framework.assert_equal(#fame_system:get_modifiers(), 0, "Should have no modifiers after removal")
end

function TestFameSystem.test_economic_effects()
    local fame_system = FameSystem.new({})

    -- Test Obscure level effects
    local effects = fame_system:get_economic_effects()
    test_framework.assert_equal(effects.funding_multiplier, 0.5, "Obscure fame should have 0.5x funding")
    test_framework.assert_equal(effects.recruitment_quality_multiplier, 0.7, "Obscure fame should have 0.7x recruitment")
    test_framework.assert_equal(effects.mission_difficulty_multiplier, 0.8, "Obscure fame should have 0.8x difficulty")

    -- Test Legendary level effects
    fame_system:modify_fame(100, "test", "test")
    effects = fame_system:get_economic_effects()
    test_framework.assert_equal(effects.funding_multiplier, 2.0, "Legendary fame should have 2.0x funding")
    test_framework.assert_equal(effects.recruitment_quality_multiplier, 1.5, "Legendary fame should have 1.5x recruitment")
    test_framework.assert_equal(effects.mission_difficulty_multiplier, 1.4, "Legendary fame should have 1.4x difficulty")
end

function TestFameSystem.test_mission_fame()
    local fame_system = FameSystem.new({})

    -- Test successful mission
    local delta = fame_system:process_mission_fame("interception", true, "public", 0)
    test_framework.assert_equal(delta, 50, "Successful public interception should give +50 fame")

    -- Test failed mission with casualties
    delta = fame_system:process_mission_fame("base_attack", false, "public", 3)
    test_framework.assert_equal(delta, -55, "Failed mission with 3 casualties should give -55 fame (-25 + 3*-10)")

    test_framework.assert_equal(fame_system:get_fame(), -5, "Total fame should be -5")
end

function TestFameSystem.test_publicity_actions()
    local fame_system = FameSystem.new({})

    -- Test press release
    local new_fame = fame_system:process_publicity_action("press_release")
    test_framework.assert_equal(new_fame, 20, "Press release should set fame to +20")

    -- Test official denial
    new_fame = fame_system:process_publicity_action("official_denial")
    test_framework.assert_equal(new_fame, 10, "Official denial should set fame to 10")

    test_framework.assert_equal(fame_system:get_fame(), 10, "Total fame should be 10")
end

function TestFameSystem.test_research_fame()
    local fame_system = FameSystem.new({})

    -- Test stealth research
    local delta = fame_system:process_research_fame("stealth_suit", "standard")
    test_framework.assert_equal(delta, 3, "Standard research should give +3 fame")

    -- Test public relations research
    delta = fame_system:process_research_fame("media_training", "standard")
    test_framework.assert_equal(delta, 8, "PR research should give +8 fame")

    test_framework.assert_equal(fame_system:get_fame(), 11, "Total fame should be 11")
end

function TestFameSystem.test_history()
    local fame_system = FameSystem.new({})

    fame_system:modify_fame(10, "test1", "reason1")
    fame_system:modify_fame(20, "test2", "reason2")
    fame_system:modify_fame(-5, "test3", "reason3")

    local history = fame_system:get_history()
    test_framework.assert_equal(#history, 3, "Should have 3 history entries")

    test_framework.assert_equal(history[3].delta, -5, "Last history entry should be -5")
    test_framework.assert_equal(history[3].source, "test3", "Last history entry should have correct source")
end

--- Run all FameSystem tests
function TestFameSystem.run()
    test_framework.run_suite("FameSystem", {
        test_initialization = TestFameSystem.test_initialization,
        test_fame_modification = TestFameSystem.test_fame_modification,
        test_fame_levels = TestFameSystem.test_fame_levels,
        test_publicity_actions = TestFameSystem.test_publicity_actions,
        test_history_tracking = TestFameSystem.test_history_tracking
    })
end

return TestFameSystem
