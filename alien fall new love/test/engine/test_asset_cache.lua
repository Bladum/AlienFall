--- Test suite for Asset Cache
--
-- Tests the AssetCache functionality for resource loading, caching, and memory management.
--
-- @module test.engine.test_asset_cache

local test_framework = require "test.framework.test_framework"
local AssetCache = require "engine.asset_cache"

local test_asset_cache = {}

--- Run all Asset Cache tests
function test_asset_cache.run()
    test_framework.run_suite("Asset Cache", {
        test_initialization = test_asset_cache.test_initialization,
        test_fetch_image_builtin = test_asset_cache.test_fetch_image_builtin,
        test_fetch_with_custom_loader = test_asset_cache.test_fetch_with_custom_loader,
        test_caching_behavior = test_asset_cache.test_caching_behavior,
        test_flush_functionality = test_asset_cache.test_flush_functionality,
        test_error_handling = test_asset_cache.test_error_handling,
        test_telemetry_integration = test_asset_cache.test_telemetry_integration
    })
end

--- Test AssetCache initialization
function test_asset_cache.test_initialization()
    local cache = AssetCache.new()

    test_framework.assert_not_nil(cache)
    test_framework.assert_not_nil(cache.assets)
    test_framework.assert_equal(type(cache.assets), "table")
    test_framework.assert_nil(cache.telemetry)

    -- Test with telemetry
    local mockTelemetry = {}
    local cacheWithTelemetry = AssetCache.new({telemetry = mockTelemetry})
    test_framework.assert_equal(cacheWithTelemetry.telemetry, mockTelemetry)
end

--- Test fetching images with built-in loader
function test_asset_cache.test_fetch_image_builtin()
    local cache = AssetCache.new()

    -- Mock love.graphics.newImage for testing
    local originalNewImage = love.graphics.newImage
    local mockImage = {type = "MockImage"}
    love.graphics.newImage = function(path)
        return mockImage
    end

    -- Test successful fetch
    local result = cache:fetch("image", "test.png")
    test_framework.assert_equal(result, mockImage)

    -- Test caching - should return same object
    local result2 = cache:fetch("image", "test.png")
    test_framework.assert_equal(result2, mockImage)

    -- Restore original function
    love.graphics.newImage = originalNewImage
end

--- Test fetching with custom loader
function test_asset_cache.test_fetch_with_custom_loader()
    local cache = AssetCache.new()

    local customLoaderCalled = false
    local mockResource = {type = "CustomResource"}

    local customLoader = function()
        customLoaderCalled = true
        return mockResource
    end

    -- Test custom loader
    local result = cache:fetch("custom", "test_key", customLoader)
    test_framework.assert_equal(result, mockResource)
    test_framework.assert_true(customLoaderCalled)

    -- Test caching with custom loader
    customLoaderCalled = false
    local result2 = cache:fetch("custom", "test_key", customLoader)
    test_framework.assert_equal(result2, mockResource)
    test_framework.assert_false(customLoaderCalled) -- Should not call loader again
end

--- Test caching behavior across different kinds and keys
function test_asset_cache.test_caching_behavior()
    local cache = AssetCache.new()

    -- Mock loader that returns different objects
    local loadCount = 0
    local mockLoader = function()
        loadCount = loadCount + 1
        return {id = loadCount}
    end

    -- Test different kinds are separate
    local result1 = cache:fetch("type1", "key1", mockLoader)
    local result2 = cache:fetch("type2", "key1", mockLoader)
    test_framework.assert_not_equal(result1, result2)
    test_framework.assert_equal(loadCount, 2)

    -- Test different keys are separate
    local result3 = cache:fetch("type1", "key2", mockLoader)
    test_framework.assert_not_equal(result1, result3)
    test_framework.assert_equal(loadCount, 3)

    -- Test same kind/key returns cached
    local result4 = cache:fetch("type1", "key1", mockLoader)
    test_framework.assert_equal(result1, result4)
    test_framework.assert_equal(loadCount, 3) -- No additional load
end

--- Test flush functionality
function test_asset_cache.test_flush_functionality()
    local cache = AssetCache.new()

    local loadCount = 0
    local mockLoader = function()
        loadCount = loadCount + 1
        return {id = loadCount}
    end

    -- Load some assets
    local result1 = cache:fetch("test", "key1", mockLoader)
    local result2 = cache:fetch("test", "key2", mockLoader)
    test_framework.assert_equal(loadCount, 2)

    -- Flush cache
    cache:flush()
    test_framework.assert_equal(type(cache.assets), "table")

    -- Load again - should create new objects
    local result3 = cache:fetch("test", "key1", mockLoader)
    local result4 = cache:fetch("test", "key2", mockLoader)
    test_framework.assert_equal(loadCount, 4)
    test_framework.assert_not_equal(result1, result3)
    test_framework.assert_not_equal(result2, result4)
end

--- Test error handling
function test_asset_cache.test_error_handling()
    local cache = AssetCache.new()

    -- Test invalid kind
    local success1 = pcall(function() cache:fetch("", "key") end)
    test_framework.assert_false(success1)

    -- Test invalid key
    local success2 = pcall(function() cache:fetch("kind", "") end)
    test_framework.assert_false(success2)

    -- Test unsupported kind without loader
    local success3 = pcall(function() cache:fetch("unsupported", "key") end)
    test_framework.assert_false(success3)
end

--- Test telemetry integration
function test_asset_cache.test_telemetry_integration()
    local events = {}
    local mockTelemetry = {
        recordEvent = function(self, event)
            table.insert(events, event)
        end
    }

    local cache = AssetCache.new({telemetry = mockTelemetry})

    -- Mock love.graphics.newImage
    local originalNewImage = love.graphics.newImage
    love.graphics.newImage = function() return {type = "MockImage"} end

    -- Fetch asset - should record telemetry
    cache:fetch("image", "test.png")

    -- Check telemetry was recorded
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].type, "asset-loaded")
    test_framework.assert_equal(events[1].kind, "image")
    test_framework.assert_equal(events[1].key, "test.png")

    -- Fetch again - should not record additional telemetry (cached)
    cache:fetch("image", "test.png")
    test_framework.assert_equal(#events, 1)

    -- Restore original function
    love.graphics.newImage = originalNewImage
end

return test_asset_cache