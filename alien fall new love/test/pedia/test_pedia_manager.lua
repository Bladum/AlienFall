--- Test suite for PediaManager class
-- @module test.pedia.test_pedia_manager

local test_framework = require("test.framework.test_framework")
local PediaManager = require("src.pedia.PediaManager")

local TestPediaManager = {}

function TestPediaManager.test_creation()
    local manager = PediaManager.new({})

    test_framework.assert_not_nil(manager.entries, "Manager should have entries table")
    test_framework.assert_not_nil(manager.categories, "Manager should have categories table")
    test_framework.assert_not_nil(manager.search_index, "Manager should have search index")
end

function TestPediaManager.test_data_loading()
    local entries_data = {
        {
            id = "entry1",
            title = "Entry One",
            category = "unit",
            tags = {"test"}
        },
        {
            id = "entry2",
            title = "Entry Two",
            category = "item",
            tags = {"weapon"}
        }
    }

    local categories_data = {
        {
            id = "units",
            name = "Units",
            entry_ids = {"entry1"}
        },
        {
            id = "items",
            name = "Items",
            entry_ids = {"entry2"}
        }
    }

    local manager = PediaManager.new({})
    manager:load_data(entries_data, categories_data)

    test_framework.assert_not_nil(manager:get_entry("entry1"), "Manager should load entry1")
    test_framework.assert_not_nil(manager:get_entry("entry2"), "Manager should load entry2")
    test_framework.assert_not_nil(manager:get_category("units"), "Manager should load units category")
    test_framework.assert_not_nil(manager:get_category("items"), "Manager should load items category")
end

function TestPediaManager.test_entry_unlock()
    local entries_data = {
        {
            id = "test_entry",
            title = "Test Entry",
            category = "unit",
            unlock_conditions = { tech_id = "test_tech" }
        }
    }

    local manager = PediaManager.new({})
    manager:load_data(entries_data, {})
    manager:set_game_state({ research = { completed = { ["test_tech"] = true } } })

    test_framework.assert_false(manager:is_entry_unlocked("test_entry"), "Entry should not be unlocked initially")

    local success = manager:unlock_entry("test_entry", "research", 12345)
    test_framework.assert_true(success, "Entry unlock should succeed")
    test_framework.assert_true(manager:is_entry_unlocked("test_entry"), "Entry should be unlocked after unlock call")
end

function TestPediaManager.test_category_unlock()
    local categories_data = {
        {
            id = "test_category",
            name = "Test Category",
            unlock_conditions = { tech_id = "test_tech" }
        }
    }

    local manager = PediaManager.new({})
    manager:load_data({}, categories_data)
    manager:set_game_state({ research = { completed = { ["test_tech"] = true } } })

    test_framework.assert_false(manager:is_category_accessible("test_category"), "Category should not be accessible initially")

    local success = manager:unlock_category("test_category")
    test_framework.assert_true(success, "Category unlock should succeed")
    test_framework.assert_true(manager:is_category_accessible("test_category"), "Category should be accessible after unlock")
end

function TestPediaManager.test_search()
    local entries_data = {
        {
            id = "laser_rifle",
            title = "Laser Rifle",
            description = "A powerful energy weapon",
            category = "item",
            tags = {"weapon", "energy"}
        },
        {
            id = "sectoid",
            title = "Sectoid",
            description = "Small alien creature",
            category = "unit",
            tags = {"alien", "weak"}
        }
    }

    local manager = PediaManager.new({})
    manager:load_data(entries_data, {})

    -- Unlock entries for search
    manager:unlock_entry("laser_rifle", "manual")
    manager:unlock_entry("sectoid", "manual")

    -- Test search
    local results = manager:search("laser")
    test_framework.assert_equals(#results, 1, "Search should find one result for 'laser'")
    test_framework.assert_equals(results[1].entry_id, "laser_rifle", "Search should find laser rifle")

    local results2 = manager:search("alien")
    test_framework.assert_equals(#results2, 1, "Search should find one result for 'alien'")
    test_framework.assert_equals(results2[1].entry_id, "sectoid", "Search should find sectoid")
end

function TestPediaManager.test_statistics()
    local entries_data = {
        { id = "entry1", title = "Entry 1", category = "unit" },
        { id = "entry2", title = "Entry 2", category = "item" },
        { id = "entry3", title = "Entry 3", category = "unit" }
    }

    local categories_data = {
        { id = "units", name = "Units", entry_ids = {"entry1", "entry3"} },
        { id = "items", name = "Items", entry_ids = {"entry2"} }
    }

    local manager = PediaManager.new({})
    manager:load_data(entries_data, categories_data)

    local stats = manager:get_statistics()

    test_framework.assert_equals(stats.total_entries, 3, "Statistics should show correct total entries")
    test_framework.assert_equals(stats.total_categories, 2, "Statistics should show correct total categories")
    test_framework.assert_equals(stats.unlocked_entries, 0, "Statistics should show no unlocked entries initially")
end

function TestPediaManager.test_category_entries()
    local entries_data = {
        { id = "unit1", title = "Unit 1", category = "units" },
        { id = "unit2", title = "Unit 2", category = "units" },
        { id = "item1", title = "Item 1", category = "items" }
    }

    local categories_data = {
        { id = "units", name = "Units" },
        { id = "items", name = "Items" }
    }

    local manager = PediaManager.new({})
    manager:load_data(entries_data, categories_data)

    -- Manually assign entries to categories
    manager.categories["units"].entry_ids = {"unit1", "unit2"}
    manager.categories["items"].entry_ids = {"item1"}

    local unit_entries = manager:get_category_entries("units")
    test_framework.assert_equals(#unit_entries, 2, "Units category should have 2 entries")

    local item_entries = manager:get_category_entries("items")
    test_framework.assert_equals(#item_entries, 1, "Items category should have 1 entry")
end

--- Run all PediaManager tests
function TestPediaManager.run()
    test_framework.run_suite("PediaManager", {
        test_initialization = TestPediaManager.test_initialization,
        test_entry_management = TestPediaManager.test_entry_management,
        test_category_management = TestPediaManager.test_category_management,
        test_unlock_system = TestPediaManager.test_unlock_system,
        test_search_functionality = TestPediaManager.test_search_functionality,
        test_category_filtering = TestPediaManager.test_category_filtering
    })
end

return TestPediaManager
