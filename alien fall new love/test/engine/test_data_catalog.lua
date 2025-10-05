--- Test suite for Data Catalog
--
-- Tests catalog registration, lookup, filtering, and management.
--
-- @module test.engine.test_data_catalog

local test_framework = require "test.framework.test_framework"
local DataCatalog = require "engine.data_catalog"

local test_data_catalog = {}

--- Mock logger
local function createMockLogger()
    return {
        info = function(self, msg) end,
        debug = function(self, msg) end,
        error = function(self, msg) end
    }
end

--- Run all data catalog tests
function test_data_catalog.run()
    test_framework.run_suite("Data Catalog", {
        test_initialization = test_data_catalog.test_initialization,
        test_register_and_get = test_data_catalog.test_register_and_get,
        test_category_operations = test_data_catalog.test_category_operations,
        test_filtering = test_data_catalog.test_filtering,
        test_existence_check = test_data_catalog.test_existence_check,
        test_counting = test_data_catalog.test_counting,
        test_clear_operations = test_data_catalog.test_clear_operations,
        test_statistics = test_data_catalog.test_statistics
    })
end

--- Test catalog initialization
function test_data_catalog.test_initialization()
    local logger = createMockLogger()
    local catalog = DataCatalog.new({logger = logger})
    
    test_framework.assert_not_nil(catalog, "Catalog should be created")
    test_framework.assert_not_nil(catalog.categories, "Categories should exist")
    test_framework.assert_not_nil(catalog.index, "Index should exist")
end

--- Test registering and getting data
function test_data_catalog.test_register_and_get()
    local catalog = DataCatalog.new()
    
    -- Register some units
    local units = {
        soldier = {id = "soldier", name = "Soldier", type = "unit"},
        alien = {id = "alien", name = "Alien", type = "unit"}
    }
    
    local success = catalog:register("units", units)
    test_framework.assert_true(success, "Registration should succeed")
    
    -- Get by ID
    local soldier, category = catalog:get("soldier")
    test_framework.assert_not_nil(soldier, "Should find soldier")
    test_framework.assert_equal(category, "units")
    test_framework.assert_equal(soldier.name, "Soldier")
    
    -- Get from specific category
    local alien = catalog:getFromCategory("units", "alien")
    test_framework.assert_not_nil(alien, "Should find alien in category")
    test_framework.assert_equal(alien.name, "Alien")
end

--- Test category operations
function test_data_catalog.test_category_operations()
    local catalog = DataCatalog.new()
    
    -- Register items
    local items = {
        rifle = {id = "rifle", name = "Rifle", type = "weapon"},
        armor = {id = "armor", name = "Armor", type = "armor"}
    }
    
    catalog:register("items", items)
    
    -- Get whole category
    local allItems = catalog:getCategory("items")
    test_framework.assert_not_nil(allItems, "Should get category")
    test_framework.assert_not_nil(allItems.rifle, "Category should contain rifle")
    test_framework.assert_not_nil(allItems.armor, "Category should contain armor")
    
    -- List categories
    local categories = catalog:listCategories()
    test_framework.assert_true(#categories > 0, "Should have categories")
end

--- Test filtering
function test_data_catalog.test_filtering()
    local catalog = DataCatalog.new()
    
    -- Register mixed items
    local items = {
        rifle1 = {id = "rifle1", name = "Rifle 1", type = "weapon", tier = 1},
        rifle2 = {id = "rifle2", name = "Rifle 2", type = "weapon", tier = 2},
        armor1 = {id = "armor1", name = "Armor 1", type = "armor", tier = 1}
    }
    
    catalog:register("items", items)
    
    -- Filter for weapons only
    local weapons = catalog:filter("items", function(id, item)
        return item.type == "weapon"
    end)
    
    test_framework.assert_not_nil(weapons.rifle1, "Should include rifle1")
    test_framework.assert_not_nil(weapons.rifle2, "Should include rifle2")
    test_framework.assert_nil(weapons.armor1, "Should not include armor")
    
    -- Filter for tier 1 items
    local tier1 = catalog:filter("items", function(id, item)
        return item.tier == 1
    end)
    
    test_framework.assert_not_nil(tier1.rifle1, "Should include tier 1 rifle")
    test_framework.assert_nil(tier1.rifle2, "Should not include tier 2 rifle")
end

--- Test existence checking
function test_data_catalog.test_existence_check()
    local catalog = DataCatalog.new()
    
    local units = {
        soldier = {id = "soldier", name = "Soldier"}
    }
    
    catalog:register("units", units)
    
    test_framework.assert_true(catalog:exists("soldier"), "Soldier should exist")
    test_framework.assert_false(catalog:exists("alien"), "Alien should not exist")
end

--- Test counting
function test_data_catalog.test_counting()
    local catalog = DataCatalog.new()
    
    local items = {
        item1 = {id = "item1"},
        item2 = {id = "item2"},
        item3 = {id = "item3"}
    }
    
    catalog:register("items", items)
    
    local count = catalog:count("items")
    test_framework.assert_equal(count, 3, "Should count 3 items")
    
    local emptyCount = catalog:count("units")
    test_framework.assert_equal(emptyCount, 0, "Empty category should count 0")
end

--- Test clear operations
function test_data_catalog.test_clear_operations()
    local catalog = DataCatalog.new()
    
    local items = {item1 = {id = "item1"}}
    local units = {unit1 = {id = "unit1"}}
    
    catalog:register("items", items)
    catalog:register("units", units)
    
    test_framework.assert_equal(catalog:count("items"), 1)
    test_framework.assert_equal(catalog:count("units"), 1)
    
    -- Clear specific category
    catalog:clearCategory("items")
    test_framework.assert_equal(catalog:count("items"), 0, "Items should be cleared")
    test_framework.assert_equal(catalog:count("units"), 1, "Units should remain")
    
    -- Clear all
    catalog:clear()
    test_framework.assert_equal(catalog:count("units"), 0, "All should be cleared")
end

--- Test statistics
function test_data_catalog.test_statistics()
    local catalog = DataCatalog.new()
    
    local items = {item1 = {id = "item1"}, item2 = {id = "item2"}}
    local units = {unit1 = {id = "unit1"}}
    
    catalog:register("items", items)
    catalog:register("units", units)
    
    local stats = catalog:getStats()
    test_framework.assert_equal(stats.total_items, 3, "Should count total items")
    test_framework.assert_equal(stats.categories.items, 2, "Should count items category")
    test_framework.assert_equal(stats.categories.units, 1, "Should count units category")
end

return test_data_catalog
