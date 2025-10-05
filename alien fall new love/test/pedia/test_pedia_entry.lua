--- Test suite for PediaEntry class
-- @module test.pedia.test_pedia_entry

local test_framework = require("test.framework.test_framework")
local PediaEntry = require("src.pedia.PediaEntry")

local TestPediaEntry = {}

function TestPediaEntry.test_creation()
    local entry_data = {
        id = "test_entry",
        title = "Test Entry",
        description = "A test encyclopedia entry",
        category = "unit",
        tags = {"test", "unit"},
        unlock_conditions = { tech_id = "test_tech" },
        table_data = { damage = 10, health = 100 }
    }

    local entry = PediaEntry.new(entry_data)

    test_framework.assert_equal(entry.id, "test_entry", "Entry ID should be set correctly")
    test_framework.assert_equal(entry.title, "Test Entry", "Entry title should be set correctly")
    test_framework.assert_equal(entry.category, "unit", "Entry category should be set correctly")
    test_framework.assert_equal(#entry.tags, 2, "Entry should have correct number of tags")
    test_framework.assert_false(entry:is_unlocked(), "New entry should not be unlocked")
end

function TestPediaEntry.test_unlock_conditions()
    local entry_data = {
        id = "test_entry",
        title = "Test Entry",
        category = "unit",
        unlock_conditions = { tech_id = "laser_weapons" }
    }

    local entry = PediaEntry.new(entry_data)
    local game_state = { research = { completed = { ["laser_weapons"] = true } } }

    test_framework.assert_true(entry:can_unlock(game_state), "Entry should be unlockable with required tech")

    local success = entry:unlock("research", game_state, 12345)
    test_framework.assert_true(success, "Entry unlock should succeed")
    test_framework.assert_true(entry:is_unlocked(), "Entry should be unlocked after unlock call")
    test_framework.assert_equal(entry.provenance.unlocked_by, "research", "Provenance should track unlock source")
end

function TestPediaEntry.test_staged_unlocks()
    local entry_data = {
        id = "test_entry",
        title = "Test Entry",
        category = "unit",
        stages = {
            { unlock = { tech_id = "basic_tech" }, description = "Basic info" },
            { unlock = { tech_id = "advanced_tech" }, description = "Advanced info" }
        }
    }

    local entry = PediaEntry(entry_data)
    local game_state = { research = { completed = { ["basic_tech"] = true } } }

    -- First stage unlock
    test_framework.assert_true(entry:can_unlock(game_state), "First stage should be unlockable")
    entry:unlock("research", game_state, 12345)
    test_framework.assert_equal(entry.current_stage, 1, "Entry should be at first stage")

    -- Second stage unlock
    game_state.research.completed["advanced_tech"] = true
    test_framework.assert_true(entry:can_unlock(game_state), "Second stage should be unlockable")
    entry:unlock("research", game_state, 12346)
    test_framework.assert_equal(entry.current_stage, 2, "Entry should be at second stage")
end

function TestPediaEntry.test_search_text()
    local entry_data = {
        id = "test_entry",
        title = "Laser Rifle",
        description = "A powerful energy weapon",
        category = "item",
        tags = {"weapon", "energy"},
        table_data = { damage = 50, range = 25 }
    }

    local entry = PediaEntry(entry_data)
    local search_text = entry:get_search_text()

    test_framework.assert_true(search_text:find("laser rifle") ~= nil, "Search text should contain title")
    test_framework.assert_true(search_text:find("powerful energy weapon") ~= nil, "Search text should contain description")
    test_framework.assert_true(search_text:find("weapon") ~= nil, "Search text should contain tags")
    test_framework.assert_true(search_text:find("energy") ~= nil, "Search text should contain tags")
end

function TestPediaEntry.test_display_data()
    local entry_data = {
        id = "test_entry",
        title = "Test Entry",
        description = "Test description",
        category = "unit",
        tags = {"test"},
        table_data = { stat = 10 }
    }

    local entry = PediaEntry.new(entry_data)
    local display_data = entry:get_display_data()

    test_framework.assert_equal(display_data.id, "test_entry", "Display data should include ID")
    test_framework.assert_equal(display_data.title, "Test Entry", "Display data should include title")
    test_framework.assert_equal(display_data.category, "unit", "Display data should include category")
    test_framework.assert_false(display_data.is_unlocked, "Display data should show unlock status")
end

--- Run all PediaEntry tests
function TestPediaEntry.run()
    test_framework.run_suite("PediaEntry", {
        test_creation = TestPediaEntry.test_creation,
        test_unlock_conditions = TestPediaEntry.test_unlock_conditions,
        test_staged_reveals = TestPediaEntry.test_staged_reveals,
        test_display_data = TestPediaEntry.test_display_data
    })
end

return TestPediaEntry
