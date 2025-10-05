--- Test suite for KarmaSystem class
-- @module test.organization.test_karma_system

local test_framework = require("test.framework.test_framework")
local KarmaSystem = require("src.organization.KarmaSystem")

local TestKarmaSystem = {}

function TestKarmaSystem.test_creation()
    local karma_system = KarmaSystem.new({})

    test_framework.assert_equal(karma_system:get_karma(), 0, "Initial karma should be 0")
    test_framework.assert_equal(karma_system:get_karma_alignment(), "Neutral", "Initial karma alignment should be Neutral")
end

function TestKarmaSystem.test_karma_modification()
    local karma_system = KarmaSystem.new({})

    -- Test positive karma change
    local new_karma = karma_system:modify_karma(15, "mission", "humanitarian rescue")
    test_framework.assert_equal(new_karma, 15, "Karma should increase by 15")
    test_framework.assert_equal(karma_system:get_karma(), 15, "Karma should be 15")

    -- Test negative karma change
    new_karma = karma_system:modify_karma(-10, "mission", "civilian casualties")
    test_framework.assert_equal(new_karma, 5, "Karma should decrease by 10")
    test_framework.assert_equal(karma_system:get_karma(), 5, "Karma should be 5")
end

function TestKarmaSystem.test_karma_alignments()
    local karma_system = KarmaSystem.new({ max_karma_change = 50 })

    -- Test Neutral alignment (-19 to 19)
    test_framework.assert_equal(karma_system:get_karma_alignment(), "Neutral", "Karma 0 should be Neutral")

    -- Test Principled alignment (20 to 59) - need to reach at least 20
    karma_system:modify_karma(20, "test", "test")  -- 0 + 20 = 20
    test_framework.assert_equal(karma_system:get_karma_alignment(), "Principled", "Karma 20 should be Principled")

    -- Test Paragon alignment (60 to 100)
    karma_system:modify_karma(40, "test", "test")
    test_framework.assert_equal(karma_system:get_karma_alignment(), "Paragon", "Karma 65 should be Paragon")

    -- Test Ruthless alignment (-20 to -59)
    karma_system = KarmaSystem.new({ max_karma_change = 50 })
    karma_system:modify_karma(-30, "test", "test")
    test_framework.assert_equal(karma_system:get_karma_alignment(), "Ruthless", "Karma -30 should be Ruthless")

    -- Test Renegade alignment (-100 to -60)
    karma_system:modify_karma(-40, "test", "test")
    test_framework.assert_equal(karma_system:get_karma_alignment(), "Renegade", "Karma -70 should be Renegade")
end

function TestKarmaSystem.test_content_access()
    local karma_system = KarmaSystem.new({})

    -- Test Neutral alignment access
    local suppliers = karma_system:get_available_suppliers()
    test_framework.assert_true(#suppliers >= 3, "Neutral should have access to standard suppliers")

    local research = karma_system:get_available_research()
    test_framework.assert_true(#research >= 3, "Neutral should have access to standard research")

    local missions = karma_system:get_available_missions()
    test_framework.assert_true(#missions >= 3, "Neutral should have access to standard missions")

    -- Test Paragon alignment access
    karma_system:modify_karma(80, "test", "test")
    suppliers = karma_system:get_available_suppliers()
    test_framework.assert_true(#suppliers > 3, "Paragon should have access to more suppliers")

    research = karma_system:get_available_research()
    test_framework.assert_true(#research > 3, "Paragon should have access to more research")

    missions = karma_system:get_available_missions()
    test_framework.assert_true(#missions > 3, "Paragon should have access to more missions")
end

function TestKarmaSystem.test_mission_karma()
    local karma_system = KarmaSystem.new({})

    -- Test humanitarian mission
    local delta = karma_system:process_mission_karma("humanitarian", true, 0, false, true)
    test_framework.assert_equal(delta, 15, "Humanitarian success with rescue should give +15 karma (+5 success +10 rescue)")

    -- Test ruthless mission with casualties
    delta = karma_system:process_mission_karma("ruthless_intervention", true, 2, true, false)
    test_framework.assert_equal(delta, -13, "Ruthless mission with casualties should give -13 karma (-5 ruthless +2*-5 -8 collateral)")

    test_framework.assert_equal(karma_system:get_karma(), 2, "Total karma should be 2")
end

function TestKarmaSystem.test_interrogation_karma()
    local karma_system = KarmaSystem.new({})

    -- Test ethical interrogation
    local delta = karma_system:process_interrogation_karma("alien", "ethical_study", "successful")
    test_framework.assert_equal(delta, 6, "Ethical alien study should give +6 karma (+3 alien +3 ethical)")

    -- Test torture
    delta = karma_system:process_interrogation_karma("human_prisoner", "torture", "successful")
    test_framework.assert_equal(delta, -5, "Torture should give -5 karma")

    test_framework.assert_equal(karma_system:get_karma(), 1, "Total karma should be 1")
end

function TestKarmaSystem.test_equipment_karma()
    local karma_system = KarmaSystem.new({})

    -- Test non-lethal weapon equip
    local delta = karma_system:process_equipment_karma("non_lethal_weapon", "equip")
    test_framework.assert_equal(delta, 1, "Non-lethal weapon equip should give +1 karma")

    -- Test chemical weapon use
    delta = karma_system:process_equipment_karma("chemical_weapon", "use")
    test_framework.assert_equal(delta, -5, "Chemical weapon use should give -5 karma")

    test_framework.assert_equal(karma_system:get_karma(), -4, "Total karma should be -4")
end

function TestKarmaSystem.test_ethical_decisions()
    local karma_system = KarmaSystem.new({ max_karma_change = 50 })

    -- Test mercy decision
    local delta = karma_system:process_ethical_decision("prisoner_release", "mercy")
    test_framework.assert_equal(delta, 5, "Prisoner mercy should give +5 karma")

    -- Test ruthless decision
    delta = karma_system:process_ethical_decision("hostage_sacrifice", "utilitarian")
    test_framework.assert_equal(delta, -10, "Hostage sacrifice should set karma to -10")

    test_framework.assert_equal(karma_system:get_karma(), -10, "Total karma should be -10")
end

function TestKarmaSystem.test_history()
    local karma_system = KarmaSystem.new({})

    karma_system:modify_karma(10, "test1", "reason1")
    karma_system:modify_karma(-5, "test2", "reason2")
    karma_system:modify_karma(20, "test3", "reason3")

    local history = karma_system:get_history()
    test_framework.assert_equal(#history, 3, "Should have 3 history entries")

    test_framework.assert_equal(history[3].delta, 15, "Last history entry should be +15 (clamped)")
    test_framework.assert_equal(history[3].source, "test3", "Last history entry should have correct source")
end

function TestKarmaSystem.test_content_access_summary()
    local karma_system = KarmaSystem.new({})

    local access = karma_system:get_content_access()
    test_framework.assert_equal(access.karma, 0, "Access summary should show current karma")
    test_framework.assert_equal(access.alignment, "Neutral", "Access summary should show current alignment")
    test_framework.assert_not_nil(access.available_suppliers, "Access summary should include suppliers")
    test_framework.assert_not_nil(access.available_research, "Access summary should include research")
    test_framework.assert_not_nil(access.available_missions, "Access summary should include missions")
end

--- Run all KarmaSystem tests
function TestKarmaSystem.run()
    test_framework.run_suite("KarmaSystem", {
        test_initialization = TestKarmaSystem.test_initialization,
        test_karma_modification = TestKarmaSystem.test_karma_modification,
        test_karma_alignments = TestKarmaSystem.test_karma_alignments,
        test_ethical_decisions = TestKarmaSystem.test_ethical_decisions,
        test_history = TestKarmaSystem.test_history,
        test_content_access_summary = TestKarmaSystem.test_content_access_summary
    })
end

return TestKarmaSystem
