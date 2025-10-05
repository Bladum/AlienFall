--- Test suite for PediaCategory class
-- @module test.pedia.test_pedia_category

local test_framework = require("test.framework.test_framework")
local PediaCategory = require("src.pedia.PediaCategory")

local TestPediaCategory = {}

function TestPediaCategory.test_creation()
    local category_data = {
        id = "test_category",
        name = "Test Category",
        description = "A test category",
        icon = "test_icon.png",
        sort_order = 1,
        tags = {"test"},
        entry_ids = {"entry1", "entry2"}
    }

    local category = PediaCategory.new(category_data)

    test_framework.assert_equal(category.id, "test_category", "Category ID should be set correctly")
    test_framework.assert_equal(category.name, "Test Category", "Category name should be set correctly")
    test_framework.assert_equal(#category.entry_ids, 2, "Category should have correct number of entries")
    test_framework.assert_false(category.is_unlocked, "New category should not be unlocked")
end

function TestPediaCategory.test_entry_management()
    local category_data = {
        id = "test_category",
        name = "Test Category"
    }

    local category = PediaCategory.new(category_data)

    -- Add entries
    test_framework.assert_true(category:add_entry("entry1"), "Should add entry successfully")
    test_framework.assert_true(category:add_entry("entry2"), "Should add second entry successfully")
    test_framework.assert_false(category:add_entry("entry1"), "Should not add duplicate entry")

    test_framework.assert_equal(#category.entry_ids, 2, "Category should have 2 entries")

    -- Remove entries
    test_framework.assert_true(category:remove_entry("entry1"), "Should remove entry successfully")
    test_framework.assert_false(category:remove_entry("entry1"), "Should not remove non-existent entry")

    test_framework.assert_equal(#category.entry_ids, 1, "Category should have 1 entry after removal")
end

function TestPediaCategory.test_subcategory_management()
    local category_data = {
        id = "parent_category",
        name = "Parent Category"
    }

    local category = PediaCategory.new(category_data)

    -- Add subcategories
    test_framework.assert_true(category:add_subcategory("child1"), "Should add subcategory successfully")
    test_framework.assert_true(category:add_subcategory("child2"), "Should add second subcategory successfully")
    test_framework.assert_false(category:add_subcategory("child1"), "Should not add duplicate subcategory")

    test_framework.assert_equal(#category.subcategories, 2, "Category should have 2 subcategories")
end

function TestPediaCategory.test_accessibility()
    local category_data = {
        id = "test_category",
        name = "Test Category",
        unlock_conditions = { tech_id = "test_tech" }
    }

    local category = PediaCategory.new(category_data)
    local game_state = { research = { completed = { ["test_tech"] = true } } }

    test_framework.assert_true(category:is_accessible(game_state), "Category should be accessible with required tech")

    local success = category:unlock(game_state)
    test_framework.assert_true(success, "Category unlock should succeed")
    test_framework.assert_true(category.is_unlocked, "Category should be unlocked after unlock call")
end

function TestPediaCategory.test_statistics()
    local category_data = {
        id = "test_category",
        name = "Test Category",
        entry_ids = {"entry1", "entry2", "entry3"}
    }

    local category = PediaCategory.new(category_data)
    category:unlock({}) -- Unlock category

    local stats = category:get_statistics({})

    test_framework.assert_equal(stats.total_entries, 3, "Statistics should show correct total entries")
    test_framework.assert_equal(stats.unlocked_entries, 3, "Statistics should show all entries unlocked for unlocked category")
    test_framework.assert_equal(stats.completion_percentage, 100, "Statistics should show 100% completion")
end

function TestPediaCategory.test_display_data()
    local category_data = {
        id = "test_category",
        name = "Test Category",
        description = "Test description",
        icon = "test_icon.png",
        sort_order = 5,
        tags = {"test"}
    }

    local category = PediaCategory.new(category_data)
    local display_data = category:get_display_data({})

    test_framework.assert_equal(display_data.id, "test_category", "Display data should include ID")
    test_framework.assert_equal(display_data.name, "Test Category", "Display data should include name")
    test_framework.assert_equal(display_data.icon, "test_icon.png", "Display data should include icon")
    test_framework.assert_equal(display_data.sort_order, 5, "Display data should include sort order")
    test_framework.assert_false(display_data.is_unlocked, "Display data should show unlock status")
end

--- Run all PediaCategory tests
function TestPediaCategory.run()
    test_framework.run_suite("PediaCategory", {
        test_creation = TestPediaCategory.test_creation,
        test_hierarchy = TestPediaCategory.test_hierarchy,
        test_accessibility = TestPediaCategory.test_accessibility,
        test_display_data = TestPediaCategory.test_display_data
    })
end

return TestPediaCategory
