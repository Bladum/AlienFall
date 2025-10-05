--- Integration test for Data Loader with Example Mod
--
-- Tests loading actual TOML files from the example mod
--
-- @module test.integration.test_data_loader_integration

local test_framework = require "test.framework.test_framework"
local DataLoader = require "engine.data_loader"

local test_data_loader_integration = {}

--- Mock logger for testing
local function createMockLogger()
    return {
        info = function(self, msg) print("[INFO] " .. msg) end,
        debug = function(self, msg) end,
        error = function(self, msg) print("[ERROR] " .. msg) end,
        warn = function(self, msg) print("[WARN] " .. msg) end
    }
end

--- Mock telemetry for testing
local function createMockTelemetry()
    local metrics = {}
    return {
        increment = function(self, metric)
            metrics[metric] = (metrics[metric] or 0) + 1
        end,
        getMetric = function(self, metric)
            return metrics[metric] or 0
        end
    }
end

--- Run all integration tests
function test_data_loader_integration.run()
    test_framework.run_suite("Data Loader Integration", {
        test_load_example_mod_main = test_data_loader_integration.test_load_example_mod_main,
        test_load_unit_classes = test_data_loader_integration.test_load_unit_classes,
        test_load_items = test_data_loader_integration.test_load_items,
        test_load_facilities = test_data_loader_integration.test_load_facilities,
        test_cache_behavior = test_data_loader_integration.test_cache_behavior
    })
end

--- Test loading example mod's main.toml
function test_data_loader_integration.test_load_example_mod_main()
    local logger = createMockLogger()
    local telemetry = createMockTelemetry()
    local loader = DataLoader.new({ logger = logger, telemetry = telemetry })
    
    -- Load the example mod's main.toml
    local data, err = loader:loadFile("mods/example_mod/main.toml", {
        validate = true,
        schema = "mod"
    })
    
    test_framework.assert_not_nil(data, "Should load example mod main.toml")
    test_framework.assert_nil(err, "No error should occur: " .. tostring(err))
    
    if data then
        test_framework.assert_equal(data.mod.id, "example_mod")
        test_framework.assert_equal(data.mod.name, "Example Mod")
        test_framework.assert_equal(data.mod.version, "1.0.0")
        test_framework.assert_not_nil(data.content, "Content section should exist")
    end
end

--- Test loading unit classes from example mod
function test_data_loader_integration.test_load_unit_classes()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Load unit classes
    local data, err = loader:loadFile("mods/example_mod/data/units/unit_classes.toml")
    
    test_framework.assert_not_nil(data, "Should load unit classes")
    test_framework.assert_nil(err, "No error should occur: " .. tostring(err))
    
    if data and data.unit_class then
        -- Verify at least one unit class exists
        local count = 0
        for _ in pairs(data.unit_class) do
            count = count + 1
        end
        test_framework.assert_true(count > 0, "Should have at least one unit class")
    end
end

--- Test loading items from example mod
function test_data_loader_integration.test_load_items()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Try to load item files
    local armorData, err1 = loader:loadFile("mods/example_mod/data/items/item_unit_armour.toml")
    local weaponData, err2 = loader:loadFile("mods/example_mod/data/items/item_unit_weapon.toml")
    
    -- At least one should load successfully
    local loaded = (armorData ~= nil) or (weaponData ~= nil)
    test_framework.assert_true(loaded, "Should load at least one item file")
end

--- Test loading facilities from example mod
function test_data_loader_integration.test_load_facilities()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Load facilities
    local data, err = loader:loadFile("mods/example_mod/data/base/base_facilities.toml")
    
    test_framework.assert_not_nil(data, "Should load facilities")
    test_framework.assert_nil(err, "No error should occur: " .. tostring(err))
    
    if data and data.facility then
        -- Verify at least one facility exists
        local count = 0
        for _ in pairs(data.facility) do
            count = count + 1
        end
        test_framework.assert_true(count > 0, "Should have at least one facility")
    end
end

--- Test cache behavior with multiple loads
function test_data_loader_integration.test_cache_behavior()
    local logger = createMockLogger()
    local telemetry = createMockTelemetry()
    local loader = DataLoader.new({ logger = logger, telemetry = telemetry })
    
    -- Load the same file twice
    local data1 = loader:loadFile("mods/example_mod/main.toml")
    local data2 = loader:loadFile("mods/example_mod/main.toml")
    
    -- Both should succeed
    test_framework.assert_not_nil(data1, "First load should succeed")
    test_framework.assert_not_nil(data2, "Second load should succeed")
    
    -- Should be the same table (cached)
    test_framework.assert_equal(data1, data2, "Should return cached instance")
    
    -- Clear cache
    loader:clearCache()
    
    -- Load again after clearing
    local data3 = loader:loadFile("mods/example_mod/main.toml")
    test_framework.assert_not_nil(data3, "Load after cache clear should succeed")
    
    -- Verify telemetry
    test_framework.assert_true(telemetry:getMetric("data_loader.cache_clears") >= 1,
        "Should record cache clear")
end

return test_data_loader_integration
