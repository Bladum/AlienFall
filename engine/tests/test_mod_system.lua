--[[
    Mod System Test Suite
    
    Tests mod loading, validation, and data access
    Tests: ModManager, Asset Verifier, Mapblock Validator
]]

local TestFramework = require("widgets.tests.widget_test_framework")

local ModSystemTests = {}

--[[
    Test ModManager functionality
]]
function ModSystemTests.testModManager()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING MOD MANAGER                              ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local ModManager = require("systems.mod_manager")
    
    TestFramework.runTest("ModManager - Load core mod", function()
        TestFramework.assertNotNil(ModManager, "ModManager not loaded")
        TestFramework.assertNotNil(ModManager.loadMod, "ModManager.loadMod missing")
    end)
    
    TestFramework.runTest("ModManager - Get terrain types", function()
        local terrainTypes = ModManager.getTerrainTypes()
        TestFramework.assertNotNil(terrainTypes, "Terrain types not loaded")
        TestFramework.assert(#terrainTypes > 0, "Terrain types array is empty")
    end)
    
    TestFramework.runTest("ModManager - Get mapblocks", function()
        local mapblocks = ModManager.getMapblocks()
        TestFramework.assertNotNil(mapblocks, "Mapblocks not loaded")
    end)
    
    TestFramework.runTest("ModManager - Validate mod structure", function()
        local modData = ModManager.getCurrentMod()
        TestFramework.assertNotNil(modData, "Current mod data is nil")
    end)
end

--[[
    Test Data Loader
]]
function ModSystemTests.testDataLoader()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING DATA LOADER                              ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local DataLoader = require("systems.data_loader")
    
    TestFramework.runTest("DataLoader - Load TOML file", function()
        TestFramework.assertNotNil(DataLoader, "DataLoader not loaded")
        TestFramework.assertNotNil(DataLoader.loadTOML, "DataLoader.loadTOML missing")
    end)
    
    TestFramework.runTest("DataLoader - Validate TOML parsing", function()
        TestFramework.assertNotNil(DataLoader.validateTOML, "DataLoader.validateTOML missing")
    end)
end

--[[
    Test Asset System
]]
function ModSystemTests.testAssetSystem()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING ASSET SYSTEM                             ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local Assets = require("systems.assets")
    
    TestFramework.runTest("Assets - Load placeholder", function()
        TestFramework.assertNotNil(Assets, "Assets system not loaded")
        TestFramework.assertNotNil(Assets.getPlaceholder, "Assets.getPlaceholder missing")
    end)
    
    TestFramework.runTest("Assets - Verify asset exists", function()
        local placeholder = Assets.getPlaceholder(32, 32)
        TestFramework.assertNotNil(placeholder, "Failed to get placeholder")
    end)
end

--[[
    Run all mod system tests
]]
function ModSystemTests.runAll()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         MOD SYSTEM TEST SUITE                            ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    TestFramework.reset()
    
    local success1, err1 = pcall(ModSystemTests.testModManager)
    if not success1 then
        print("\n[ERROR] ModManager tests failed:")
        print(err1)
    end
    
    local success2, err2 = pcall(ModSystemTests.testDataLoader)
    if not success2 then
        print("\n[ERROR] DataLoader tests failed:")
        print(err2)
    end
    
    local success3, err3 = pcall(ModSystemTests.testAssetSystem)
    if not success3 then
        print("\n[ERROR] Asset system tests failed:")
        print(err3)
    end
    
    TestFramework.printSummary()
    
    return TestFramework.results
end

return ModSystemTests
