--- Test suite for Data Loader Service
--
-- Tests the DataLoader service functionality including file loading,
-- caching, path resolution, and directory loading.
--
-- @module test.engine.test_data_loader

local test_framework = require "test.framework.test_framework"
local DataLoader = require "engine.data_loader"

local test_data_loader = {}

--- Mock logger for testing
local function createMockLogger()
    return {
        info = function(self, msg) end,
        debug = function(self, msg) end,
        error = function(self, msg) end,
        warn = function(self, msg) end
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

--- Run all data loader tests
function test_data_loader.run()
    test_framework.run_suite("Data Loader Service", {
        test_initialization = test_data_loader.test_initialization,
        test_parse_string = test_data_loader.test_parse_string,
        test_path_resolution = test_data_loader.test_path_resolution,
        test_cache_functionality = test_data_loader.test_cache_functionality,
        test_search_paths = test_data_loader.test_search_paths,
        test_load_directory = test_data_loader.test_load_directory,
        test_telemetry_integration = test_data_loader.test_telemetry_integration
    })
end

--- Test DataLoader initialization
function test_data_loader.test_initialization()
    local logger = createMockLogger()
    local telemetry = createMockTelemetry()
    
    local loader = DataLoader.new({
        logger = logger,
        telemetry = telemetry
    })
    
    test_framework.assert_not_nil(loader, "DataLoader should be created")
    test_framework.assert_not_nil(loader.cache, "Cache should be initialized")
    test_framework.assert_not_nil(loader.searchPaths, "Search paths should be initialized")
end

--- Test parsing TOML string
function test_data_loader.test_parse_string()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Test simple TOML
    local tomlContent = [[
title = "Test Document"
version = 1.0
enabled = true

[database]
server = "192.168.1.1"
port = 5432
]]
    
    local data, err = loader:parseString(tomlContent)
    
    test_framework.assert_not_nil(data, "Data should be parsed")
    test_framework.assert_nil(err, "No error should occur")
    test_framework.assert_equal(data.title, "Test Document")
    test_framework.assert_equal(data.version, 1.0)
    test_framework.assert_true(data.enabled)
    test_framework.assert_equal(data.database.server, "192.168.1.1")
    test_framework.assert_equal(data.database.port, 5432)
end

--- Test path resolution
function test_data_loader.test_path_resolution()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Test with example mod path (should exist)
    local resolved = loader:resolvePath("example_mod/main.toml")
    test_framework.assert_not_nil(resolved, "Should resolve example mod path")
    
    -- Test with non-existent path
    local notFound = loader:resolvePath("nonexistent/file.toml")
    test_framework.assert_nil(notFound, "Should return nil for non-existent path")
end

--- Test cache functionality
function test_data_loader.test_cache_functionality()
    local logger = createMockLogger()
    local telemetry = createMockTelemetry()
    local loader = DataLoader.new({ logger = logger, telemetry = telemetry })
    
    -- Parse and cache a string
    local tomlContent = [[
name = "Test"
value = 42
]]
    
    local data1 = loader:parseString(tomlContent)
    test_framework.assert_not_nil(data1)
    
    -- Check cache stats
    local stats = loader:getCacheStats()
    test_framework.assert_equal(type(stats), "table")
    test_framework.assert_equal(type(stats.cached_files), "number")
    
    -- Clear cache
    loader:clearCache()
    local statsAfterClear = loader:getCacheStats()
    test_framework.assert_equal(statsAfterClear.cached_files, 0)
    
    -- Verify telemetry
    test_framework.assert_true(telemetry:getMetric("data_loader.cache_clears") > 0)
end

--- Test adding search paths
function test_data_loader.test_search_paths()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    local initialCount = #loader.searchPaths
    
    -- Add a new search path
    loader:addSearchPath("custom/path/")
    test_framework.assert_equal(#loader.searchPaths, initialCount + 1)
    
    -- Add path without trailing slash (should be added automatically)
    loader:addSearchPath("another/path")
    test_framework.assert_equal(#loader.searchPaths, initialCount + 2)
    
    -- Verify the path ends with /
    local lastPath = loader.searchPaths[#loader.searchPaths]
    test_framework.assert_true(lastPath:sub(-1) == "/")
end

--- Test loading directory
function test_data_loader.test_load_directory()
    local logger = createMockLogger()
    local telemetry = createMockTelemetry()
    local loader = DataLoader.new({ logger = logger, telemetry = telemetry })
    
    -- Try to load example mod data directory
    -- This test will only pass if example_mod exists
    local results, errors = loader:loadDirectory("mods/example_mod/data/units")
    
    -- Should return tables even if directory doesn't exist
    test_framework.assert_equal(type(results), "table")
    test_framework.assert_equal(type(errors), "table")
    
    -- Verify telemetry was incremented
    test_framework.assert_true(telemetry:getMetric("data_loader.directory_loads") > 0)
end

--- Test telemetry integration
function test_data_loader.test_telemetry_integration()
    local telemetry = createMockTelemetry()
    local loader = DataLoader.new({ telemetry = telemetry })
    
    -- Parse some strings to generate metrics
    loader:parseString("key = 'value'")
    loader:parseString("another = 123")
    
    -- Verify metrics were recorded
    test_framework.assert_equal(telemetry:getMetric("data_loader.string_parses"), 2)
end

--- Test validation functionality
function test_data_loader.test_validation()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Test mod config validation
    local validModToml = [[
[mod]
id = "test_mod"
name = "Test Mod"
version = "1.0.0"
]]
    
    local data, err = loader:parseString(validModToml, {
        validate = true,
        schema = "mod"
    })
    
    test_framework.assert_not_nil(data, "Valid mod config should parse")
    test_framework.assert_nil(err, "No error should occur")
    
    -- Test invalid mod config
    local invalidModToml = [[
[mod]
id = "test_mod"
]]
    
    local badData, badErr = loader:parseString(invalidModToml, {
        validate = true,
        schema = "mod"
    })
    
    test_framework.assert_nil(badData, "Invalid mod config should fail")
    test_framework.assert_not_nil(badErr, "Error should be returned")
end

--- Test error handling
function test_data_loader.test_error_handling()
    local logger = createMockLogger()
    local loader = DataLoader.new({ logger = logger })
    
    -- Test malformed TOML
    local malformedToml = [[
[section
missing = "closing bracket"
]]
    
    local data, err = loader:parseString(malformedToml)
    
    -- Should handle error gracefully
    -- Note: Actual error handling depends on TOML parser implementation
    test_framework.assert_true(data == nil or err ~= nil, 
        "Should handle malformed TOML gracefully")
end

return test_data_loader
