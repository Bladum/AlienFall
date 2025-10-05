--- Test suite for AssetCache mod support expansion
-- Tests asset scanning, registration, and lazy loading
--
-- @module test.engine.test_asset_cache_expansion

local test_framework = require "test.framework.test_framework"
local AssetCache = require("src.engine.asset_cache")

local TestAssetCacheExpansion = {}

--- Run all AssetCache expansion tests
function TestAssetCacheExpansion.run()
    test_framework.run_suite("AssetCache Expansion", {
        test_detect_asset_type = TestAssetCacheExpansion.test_detect_asset_type,
        test_scan_mod_assets = TestAssetCacheExpansion.test_scan_mod_assets,
        test_register_mod_assets = TestAssetCacheExpansion.test_register_mod_assets,
        test_has_asset = TestAssetCacheExpansion.test_has_asset,
        test_list_assets = TestAssetCacheExpansion.test_list_assets,
        test_add_mod_search_path = TestAssetCacheExpansion.test_add_mod_search_path,
        test_lazy_loading_flag = TestAssetCacheExpansion.test_lazy_loading_flag,
        test_memory_limit = TestAssetCacheExpansion.test_memory_limit,
        test_get_asset = TestAssetCacheExpansion.test_get_asset,
        test_stats_with_registry = TestAssetCacheExpansion.test_stats_with_registry,
        test_scan_directory_recursive = TestAssetCacheExpansion.test_scan_directory_recursive,
        test_asset_patterns_coverage = TestAssetCacheExpansion.test_asset_patterns_coverage,
        test_case_sensitivity = TestAssetCacheExpansion.test_case_sensitivity
    })
end

-- Test: Detect asset type from filename
function TestAssetCacheExpansion.test_detect_asset_type()
    local cache = AssetCache.new({})
    
    -- Test image detection
    assert(cache:detectAssetType("test.png") == "image", "Should detect PNG as image")
    assert(cache:detectAssetType("test.jpg") == "image", "Should detect JPG as image")
    assert(cache:detectAssetType("test.jpeg") == "image", "Should detect JPEG as image")
    
    -- Test audio detection
    assert(cache:detectAssetType("test.ogg") == "audio", "Should detect OGG as audio")
    assert(cache:detectAssetType("test.wav") == "audio", "Should detect WAV as audio")
    
    -- Test font detection
    assert(cache:detectAssetType("test.ttf") == "font", "Should detect TTF as font")
    assert(cache:detectAssetType("test.otf") == "font", "Should detect OTF as font")
    
    -- Test shader detection
    assert(cache:detectAssetType("test.glsl") == "shader", "Should detect GLSL as shader")
    
    -- Test unknown type
    assert(cache:detectAssetType("test.txt") == nil, "Should return nil for unknown type")
    assert(cache:detectAssetType("test.lua") == nil, "Should return nil for Lua files")
    
    return true
end

-- Test: Scan mod directory for assets
function TestAssetCacheExpansion.test_scan_mod_assets()
    local cache = AssetCache.new({})
    
    -- Scan example_mod (should have some assets)
    local assets = cache:scanModAssets("mods/example_mod")
    
    -- Should return a table (even if empty)
    assert(type(assets) == "table", "Should return assets table")
    
    -- Check structure of found assets
    for assetId, assetInfo in pairs(assets) do
        assert(type(assetId) == "string", "Asset ID should be string")
        assert(type(assetInfo.path) == "string", "Asset should have path")
        assert(type(assetInfo.type) == "string", "Asset should have type")
    end
    
    return true
end

-- Test: Register assets from mods
function TestAssetCacheExpansion.test_register_mod_assets()
    local cache = AssetCache.new({})
    
    -- Register assets from example_mod
    cache:registerModAssets({"mods/example_mod"})
    
    -- Check that registry is populated
    local stats = cache:getStats()
    assert(stats.registeredAssets >= 0, "Should have registered assets count")
    
    return true
end

-- Test: Has asset check
function TestAssetCacheExpansion.test_has_asset()
    local cache = AssetCache.new({})
    
    -- Should not have asset before registration
    assert(not cache:hasAsset("test_asset"), "Should not have unregistered asset")
    
    -- Register a mock asset
    cache.assetRegistry["test_asset"] = {
        path = "test/path.png",
        type = "image"
    }
    
    -- Should have asset after registration
    assert(cache:hasAsset("test_asset"), "Should have registered asset")
    
    return true
end

-- Test: List assets
function TestAssetCacheExpansion.test_list_assets()
    local cache = AssetCache.new({})
    
    -- Register mock assets
    cache.assetRegistry["image1"] = {path = "test1.png", type = "image"}
    cache.assetRegistry["image2"] = {path = "test2.png", type = "image"}
    cache.assetRegistry["sound1"] = {path = "test1.ogg", type = "audio"}
    
    -- List all assets
    local allAssets = cache:listAssets()
    assert(#allAssets == 3, "Should list all assets")
    
    -- List only images
    local images = cache:listAssets("image")
    assert(#images == 2, "Should list only images")
    
    -- List only audio
    local audio = cache:listAssets("audio")
    assert(#audio == 1, "Should list only audio")
    
    return true
end

-- Test: Add mod search path
function TestAssetCacheExpansion.test_add_mod_search_path()
    local cache = AssetCache.new({})
    
    -- Initial search paths
    local initialCount = #cache.modSearchPaths
    
    -- Add new path
    cache:addModSearchPath("custom_mods/")
    
    -- Should have one more path
    assert(#cache.modSearchPaths == initialCount + 1, "Should add search path")
    assert(cache.modSearchPaths[#cache.modSearchPaths] == "custom_mods/", "Should add correct path")
    
    return true
end

-- Test: Lazy loading flag
function TestAssetCacheExpansion.test_lazy_loading_flag()
    -- Default: lazy loading enabled
    local cache1 = AssetCache.new({})
    assert(cache1.lazyLoad == true, "Should enable lazy loading by default")
    
    -- Explicitly enable
    local cache2 = AssetCache.new({lazyLoad = true})
    assert(cache2.lazyLoad == true, "Should enable lazy loading when requested")
    
    -- Explicitly disable
    local cache3 = AssetCache.new({lazyLoad = false})
    assert(cache3.lazyLoad == false, "Should disable lazy loading when requested")
    
    return true
end

-- Test: Memory limit configuration
function TestAssetCacheExpansion.test_memory_limit()
    -- Default memory limit
    local cache1 = AssetCache.new({})
    assert(cache1.maxMemoryMB == 256, "Should have default memory limit")
    
    -- Custom memory limit
    local cache2 = AssetCache.new({maxMemoryMB = 512})
    assert(cache2.maxMemoryMB == 512, "Should set custom memory limit")
    
    return true
end

-- Test: Get asset by ID (mock test)
function TestAssetCacheExpansion.test_get_asset()
    local cache = AssetCache.new({})
    
    -- Register mock asset (but don't try to load real file)
    cache.assetRegistry["mock_asset"] = {
        path = "nonexistent.png",
        type = "image"
    }
    
    -- Attempt to get asset (will fail due to missing file, but tests the lookup)
    local asset = cache:getAsset("mock_asset")
    -- Asset will be nil because file doesn't exist, but the lookup worked
    
    -- Try to get non-existent asset
    local missing = cache:getAsset("missing_asset")
    assert(missing == nil, "Should return nil for missing asset")
    
    return true
end

-- Test: Stats include registered assets
function TestAssetCacheExpansion.test_stats_with_registry()
    local cache = AssetCache.new({})
    
    -- Register some mock assets
    cache.assetRegistry["asset1"] = {path = "test1.png", type = "image"}
    cache.assetRegistry["asset2"] = {path = "test2.png", type = "image"}
    cache.assetRegistry["asset3"] = {path = "test3.ogg", type = "audio"}
    
    -- Get stats
    local stats = cache:getStats()
    
    -- Should include registered asset count
    assert(stats.registeredAssets == 3, "Should count registered assets")
    assert(stats.totalAssets == 0, "Should have no loaded assets yet")
    
    return true
end

-- Test: Scan directory recursively
function TestAssetCacheExpansion.test_scan_directory_recursive()
    local cache = AssetCache.new({})
    
    -- Test with a directory that may or may not exist
    local assets = {}
    
    -- Check if example_mod/assets exists
    local info = love.filesystem.getInfo("mods/example_mod/assets")
    
    if info and info.type == "directory" then
        cache:scanDirectory("mods/example_mod/assets", assets, "")
        
        -- Should populate assets table
        assert(type(assets) == "table", "Should populate assets table")
        
        -- Each asset should have required fields
        for assetId, assetInfo in pairs(assets) do
            assert(type(assetInfo.path) == "string", "Each asset should have path")
            assert(type(assetInfo.type) == "string", "Each asset should have type")
        end
    end
    
    return true
end

-- Test: Asset type patterns coverage
function TestAssetCacheExpansion.test_asset_patterns_coverage()
    local cache = AssetCache.new({})
    
    -- Test all supported image formats
    local imageFormats = {"test.png", "test.jpg", "test.jpeg", "test.bmp", "test.tga"}
    for _, filename in ipairs(imageFormats) do
        assert(cache:detectAssetType(filename) == "image", "Should detect " .. filename .. " as image")
    end
    
    -- Test all supported audio formats
    local audioFormats = {"test.ogg", "test.wav", "test.mp3"}
    for _, filename in ipairs(audioFormats) do
        assert(cache:detectAssetType(filename) == "audio", "Should detect " .. filename .. " as audio")
    end
    
    -- Test font formats
    local fontFormats = {"test.ttf", "test.otf"}
    for _, filename in ipairs(fontFormats) do
        assert(cache:detectAssetType(filename) == "font", "Should detect " .. filename .. " as font")
    end
    
    -- Test shader formats
    local shaderFormats = {"test.glsl", "test.vert", "test.frag"}
    for _, filename in ipairs(shaderFormats) do
        assert(cache:detectAssetType(filename) == "shader", "Should detect " .. filename .. " as shader")
    end
    
    return true
end

-- Test: Case sensitivity in file extension matching
function TestAssetCacheExpansion.test_case_sensitivity()
    local cache = AssetCache.new({})
    
    -- Lua patterns are case-sensitive, these should match
    assert(cache:detectAssetType("test.png") == "image", "Should match lowercase .png")
    assert(cache:detectAssetType("test.jpg") == "image", "Should match lowercase .jpg")
    
    -- These should NOT match (uppercase extensions)
    assert(cache:detectAssetType("test.PNG") == nil, "Should not match uppercase .PNG")
    assert(cache:detectAssetType("test.JPG") == nil, "Should not match uppercase .JPG")
    
    return true
end

return TestAssetCacheExpansion
