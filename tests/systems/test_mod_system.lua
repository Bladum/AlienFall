--[[
    Mod System Test Suite
    
    Tests mod loading, validation, and data access
    Tests: ModManager, Asset Verifier, Mapblock Validator
]]

local TestFramework = require("tests.widgets.widget_test_framework")
local ModManager = require("core.mod_manager")
local TOML = require("utils.toml")

local ModSystemTests = {}

--[[
    Test ModManager functionality
]]
function ModSystemTests.testModManager()
    print("\n-===========================================================�")
    print("�         TESTING MOD MANAGER                              �")
    print("L===========================================================-")
    
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
        local modData = ModManager.getActiveMod()
        TestFramework.assertNotNil(modData, "Active mod data is nil")
        if modData then
            TestFramework.assertNotNil(modData.mod, "Mod metadata missing")
            TestFramework.assertNotNil(modData.paths, "Mod paths missing")
            if modData.mod then
                TestFramework.assertNotNil(modData.mod.id, "Mod ID missing")
            end
        end
    end)
    
    TestFramework.runTest("ModManager - Content path resolution", function()
        local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
        TestFramework.assertNotNil(terrainPath, "Terrain content path is nil")
        if terrainPath then
            TestFramework.assert(terrainPath:find("terrain.toml") ~= nil, "Terrain path incorrect")
        end
    end)
    
    TestFramework.runTest("ModManager - Mod discovery", function()
        local modList = ModManager.scanMods()
        TestFramework.assertNotNil(modList, "Mod list is nil")
        TestFramework.assert(#modList > 0, "No mods discovered")
    end)
end

--[[
    Test TOML parsing and validation
]]
function ModSystemTests.testTOMLParsing()
    print("\n-===========================================================�")
    print("�         TESTING TOML PARSING                             �")
    print("L===========================================================-")
    
    local TOML = require("utils.toml")
    
    TestFramework.runTest("TOML - Parse mod.toml", function()
        TestFramework.assertNotNil(TOML, "TOML library not loaded")
        TestFramework.assertNotNil(TOML.load, "TOML.load missing")
    end)
    
    TestFramework.runTest("TOML - Load mod configuration", function()
        local modPath = ModManager.getContentPath("../mod.toml")
        if modPath then
            local modConfig = TOML.load(modPath)
            TestFramework.assertNotNil(modConfig, "Failed to load mod.toml")
            if modConfig then
                TestFramework.assertNotNil(modConfig.mod, "Mod section missing")
                if modConfig.mod then
                    TestFramework.assertEqual(modConfig.mod.id, "xcom_simple", "Mod ID incorrect")
                end
            end
        else
            TestFramework.assert(false, "Could not get mod.toml path")
        end
    end)
    
    TestFramework.runTest("TOML - Parse terrain data", function()
        local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
        if terrainPath then
            local terrainData = TOML.load(terrainPath)
            TestFramework.assertNotNil(terrainData, "Failed to load terrain.toml")
            if terrainData then
                TestFramework.assertNotNil(terrainData.terrain, "Terrain section missing")
            end
        end
    end)
end

--[[
    Test error handling
]]
function ModSystemTests.testErrorHandling()
    print("\n-===========================================================�")
    print("�         TESTING ERROR HANDLING                           �")
    print("L===========================================================-")
    
    TestFramework.runTest("ModManager - Invalid mod ID", function()
        local result = ModManager.setActiveMod("nonexistent_mod")
        TestFramework.assertEqual(result, false, "Should fail for invalid mod ID")
    end)
    
    TestFramework.runTest("ModManager - No active mod", function()
        -- Temporarily clear active mod
        local oldActive = ModManager.activeMod
        ModManager.activeMod = nil
        
        local modData = ModManager.getActiveMod()
        TestFramework.assertNil(modData, "Should return nil when no active mod")
        
        -- Restore
        ModManager.activeMod = oldActive
    end)
    
    TestFramework.runTest("TOML - Invalid file", function()
        local TOML = require("utils.toml")
        local invalidData = TOML.load("nonexistent_file.toml")
        TestFramework.assertNil(invalidData, "Should return nil for invalid file")
    end)
end

--[[
    Test Data Loader
]]
function ModSystemTests.testDataLoader()
    print("\n-===========================================================�")
    print("�         TESTING DATA LOADER                              �")
    print("L===========================================================-")
    
    local DataLoader = require("core.data.data_loader")
    
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
    print("\n-===========================================================�")
    print("�         TESTING ASSET SYSTEM                             �")
    print("L===========================================================-")
    
    local Assets = require("core.assets.assets")
    
    TestFramework.runTest("Assets - Load placeholder", function()
        TestFramework.assertNotNil(Assets, "Assets system not loaded")
        TestFramework.assertNotNil(Assets.getPlaceholder, "Assets.getPlaceholder missing")
    end)
    
    TestFramework.runTest("Assets - Verify asset exists", function()
        local placeholder = Assets.getPlaceholder()
        TestFramework.assertNotNil(placeholder, "Failed to get placeholder")
    end)
end

--[[
    Test Mod Switching and Multi-Mod Scenarios
]]
function ModSystemTests.testModSwitching()
    print("\n-===========================================================�")
    print("�         TESTING MOD SWITCHING                            �")
    print("L===========================================================-")
    
    TestFramework.runTest("ModManager - Switch active mod", function()
        local currentMod = ModManager.getActiveMod()
        TestFramework.assertNotNil(currentMod, "No active mod to switch from")
        TestFramework.assertNotNil(currentMod.mod, "Current mod metadata missing")
        TestFramework.assertNotNil(currentMod.mod.id, "Current mod ID missing")
        
        -- Try to switch to the same mod (should succeed)
        local result = ModManager.setActiveMod(currentMod.mod.id)
        TestFramework.assert(result, "Failed to switch to same mod")
        
        -- Verify still active
        local newActive = ModManager.getActiveMod()
        TestFramework.assertNotNil(newActive, "New active mod is nil")
        TestFramework.assertNotNil(newActive.mod, "New active mod metadata missing")
        TestFramework.assertNotNil(newActive.mod.id, "New active mod ID missing")
        TestFramework.assertEqual(newActive.mod.id, currentMod.mod.id, "Mod switch failed")
    end)
    
    TestFramework.runTest("ModManager - Invalid mod switch", function()
        local result = ModManager.setActiveMod("nonexistent_mod_12345")
        TestFramework.assert(not result, "Should fail for invalid mod ID")
    end)
    
    TestFramework.runTest("ModManager - Mod list consistency", function()
        local modList = ModManager.scanMods()
        TestFramework.assertNotNil(modList, "Mod list is nil")
        TestFramework.assert(#modList > 0, "No mods in list")
        
        -- Check that active mod is in the list
        local activeMod = ModManager.getActiveMod()
        if activeMod then
            local found = false
            for _, mod in ipairs(modList) do
                if mod.id == activeMod.mod.id then
                    found = true
                    break
                end
            end
            TestFramework.assert(found, "Active mod not found in mod list")
        end
    end)
end

--[[
    Test Mod Dependencies and Validation
]]
function ModSystemTests.testModDependencies()
    print("\n-===========================================================�")
    print("�         TESTING MOD DEPENDENCIES                         �")
    print("L===========================================================-")
    
    TestFramework.runTest("ModManager - Validate mod structure", function()
        local activeMod = ModManager.getActiveMod()
        TestFramework.assertNotNil(activeMod, "No active mod to validate")
        
        -- Check required fields
        TestFramework.assertNotNil(activeMod.mod, "Mod metadata missing")
        if activeMod.mod then
            TestFramework.assertNotNil(activeMod.mod.id, "Mod ID missing")
            TestFramework.assertNotNil(activeMod.mod.name, "Mod name missing")
            TestFramework.assertNotNil(activeMod.mod.version, "Mod version missing")
        end
    end)
    
    TestFramework.runTest("ModManager - Content path validation", function()
        local paths = {"rules/battle/terrain.toml", "rules/item/weapons.toml", "rules/unit/classes.toml"}
        
        for _, path in ipairs(paths) do
            local fullPath = ModManager.getContentPath(path)
            TestFramework.assertNotNil(fullPath, "Content path is nil for: " .. path)
            if fullPath then
                TestFramework.assert(fullPath:find("%.toml$") ~= nil, "Invalid path format for: " .. path)
            end
        end
    end)
    
    TestFramework.runTest("ModManager - TOML file accessibility", function()
        local testFiles = {
            ["rules/battle/terrain.toml"] = "terrain",
            ["rules/item/weapons.toml"] = "weapons", 
            ["rules/unit/classes.toml"] = "classes"
        }
        
        for filePath, expectedSection in pairs(testFiles) do
            local fullPath = ModManager.getContentPath(filePath)
            if fullPath then
                local data = TOML.load(fullPath)
                TestFramework.assertNotNil(data, "Failed to load TOML: " .. filePath)
                if data then
                    TestFramework.assertNotNil(data[expectedSection], "Missing section '" .. expectedSection .. "' in " .. filePath)
                end
            end
        end
    end)
end

--[[
    Test Mod Content Resolution
]]
function ModSystemTests.testContentResolution()
    print("\n-===========================================================�")
    print("�         TESTING CONTENT RESOLUTION                       �")
    print("L===========================================================-")
    
    TestFramework.runTest("ModManager - Terrain type resolution", function()
        local terrainTypes = ModManager.getTerrainTypes()
        TestFramework.assertNotNil(terrainTypes, "Terrain types not resolved")
        TestFramework.assert(type(terrainTypes) == "table", "Terrain types not a table")
        TestFramework.assert(#terrainTypes > 0, "No terrain types resolved")
        
        -- Check structure of first terrain type
        local firstTerrain = terrainTypes[1]
        if firstTerrain then
            TestFramework.assertNotNil(firstTerrain.id, "Terrain missing ID")
            TestFramework.assertNotNil(firstTerrain.name, "Terrain missing name")
            TestFramework.assertNotNil(firstTerrain.image, "Terrain missing image")
        end
    end)
    
    TestFramework.runTest("ModManager - Weapon data resolution", function()
        local weapons = ModManager.getWeapons()
        TestFramework.assertNotNil(weapons, "Weapons not resolved")
        TestFramework.assert(type(weapons) == "table", "Weapons not a table")
        TestFramework.assert(#weapons > 0, "No weapons resolved")
    end)
    
    TestFramework.runTest("ModManager - Unit class resolution", function()
        local unitClasses = ModManager.getUnitClasses()
        TestFramework.assertNotNil(unitClasses, "Unit classes not resolved")
        TestFramework.assert(type(unitClasses) == "table", "Unit classes not a table")
        TestFramework.assert(#unitClasses > 0, "No unit classes resolved")
    end)
end

--[[
    Run all mod system tests
]]
function ModSystemTests.runAll()
    print("\n\n")
    print("-===========================================================�")
    print("�         MOD SYSTEM TEST SUITE                            �")
    print("L===========================================================-")
    
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
    
    local success4, err4 = pcall(ModSystemTests.testTOMLParsing)
    if not success4 then
        print("\n[ERROR] TOML parsing tests failed:")
        print(err4)
    end
    
    local success5, err5 = pcall(ModSystemTests.testErrorHandling)
    if not success5 then
        print("\n[ERROR] Error handling tests failed:")
        print(err5)
    end
    
    local success6, err6 = pcall(ModSystemTests.testModSwitching)
    if not success6 then
        print("\n[ERROR] Mod switching tests failed:")
        print(err6)
    end
    
    local success7, err7 = pcall(ModSystemTests.testModDependencies)
    if not success7 then
        print("\n[ERROR] Mod dependencies tests failed:")
        print(err7)
    end
    
    local success8, err8 = pcall(ModSystemTests.testContentResolution)
    if not success8 then
        print("\n[ERROR] Content resolution tests failed:")
        print(err8)
    end
    
    TestFramework.printSummary()
    
    return TestFramework.results
end

return ModSystemTests



























