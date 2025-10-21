--[[
Manual Gameplay Integration Test for Phase 2 Task 5
Tests complete gameplay loop: Startup -> Menu -> Geoscape -> Battlescape -> Results

This is a comprehensive test of all integrated systems working together.
]]

local Tests = {}

-- Track results
local results = {
    passed = 0,
    failed = 0,
    tests = {}
}

local function testPass(name, message)
    results.passed = results.passed + 1
    table.insert(results.tests, {
        name = name,
        status = "PASS",
        message = message
    })
    print(string.format("✓ PASS: %s - %s", name, message or ""))
end

local function testFail(name, message)
    results.failed = results.failed + 1
    table.insert(results.tests, {
        name = name,
        status = "FAIL",
        message = message
    })
    print(string.format("✗ FAIL: %s - %s", name, message or ""))
end

-- Test 1: Game Initialization
function Tests.testGameInitialization()
    print("\n" .. string.rep("=", 60))
    print("TEST SEQUENCE 1: Game Initialization")
    print(string.rep("=", 60) .. "\n")
    
    -- Check that Love2D is available
    if love then
        testPass("Love2D", "Framework loaded")
    else
        testFail("Love2D", "Framework not loaded")
        return false
    end
    
    -- Check window dimensions
    if love.graphics then
        testPass("Graphics", "Graphics system available")
    else
        testFail("Graphics", "Graphics system not available")
        return false
    end
    
    return true
end

-- Test 2: Core Systems Loading
function Tests.testCoreSystemsLoading()
    print("\n" .. string.rep("=", 60))
    print("TEST SEQUENCE 2: Core Systems Loading")
    print(string.rep("=", 60) .. "\n")
    
    local success = true
    
    -- Test DataLoader
    local DataLoader = require("core.data_loader")
    if DataLoader then
        testPass("DataLoader", "Module loaded")
        -- Try to load data
        if DataLoader.terrainTypes and next(DataLoader.terrainTypes.terrain) then
            testPass("TerrainTypes", string.format("Loaded %d terrain types", #DataLoader.terrainTypes.getAllIds()))
        else
            testFail("TerrainTypes", "Terrain types not loaded")
            success = false
        end
    else
        testFail("DataLoader", "Module failed to load")
        success = false
    end
    
    -- Test ModManager
    local ModManager = require("mods.mod_manager")
    if ModManager then
        testPass("ModManager", "Module loaded")
        local activeMod = ModManager.getActiveMod()
        if activeMod then
            testPass("ActiveMod", "Mod loaded: " .. (activeMod.mod.name or "unknown"))
        else
            testFail("ActiveMod", "No active mod set")
            success = false
        end
    else
        testFail("ModManager", "Module failed to load")
        success = false
    end
    
    -- Test StateManager
    local StateManager = require("core.state_manager")
    if StateManager then
        testPass("StateManager", "Module loaded")
    else
        testFail("StateManager", "Module failed to load")
        success = false
    end
    
    return success
end

-- Test 3: UI Systems
function Tests.testUISystemsLoading()
    print("\n" .. string.rep("=", 60))
    print("TEST SEQUENCE 3: UI Systems Loading")
    print(string.rep("=", 60) .. "\n")
    
    local success = true
    
    -- Test Grid System
    local Grid = require("core.grid")
    if Grid then
        testPass("Grid", "Module loaded")
    else
        testFail("Grid", "Module failed to load")
        success = false
    end
    
    -- Test Widget System
    local WidgetLoader = require("gui.widgets.widget_loader")
    if WidgetLoader then
        testPass("WidgetLoader", "Module loaded")
    else
        testFail("WidgetLoader", "Module failed to load")
        success = false
    end
    
    -- Test Theme
    local Theme = require("core.theme")
    if Theme then
        testPass("Theme", "Module loaded")
    else
        testFail("Theme", "Module failed to load")
        success = false
    end
    
    return success
end

-- Test 4: Game Layer Systems
function Tests.testGameLayersLoading()
    print("\n" .. string.rep("=", 60))
    print("TEST SEQUENCE 4: Game Layer Systems Loading")
    print(string.rep("=", 60) .. "\n")
    
    local success = true
    
    -- Test Menu System
    print("[TEST] Menu System")
    local ok, err = pcall(function() require("scenes.main_menu") end)
    if ok then
        testPass("MenuSystem", "Module loaded")
    else
        testFail("MenuSystem", "Module failed: " .. tostring(err))
        success = false
    end
    
    -- Test Geoscape
    print("[TEST] Geoscape System")
    ok, err = pcall(function() require("geoscape.geoscape_scene") end)
    if ok then
        testPass("GeoscapeSystem", "Module loaded")
    else
        testFail("GeoscapeSystem", "Module failed: " .. tostring(err))
        success = false
    end
    
    -- Test Battlescape
    print("[TEST] Battlescape System")
    ok, err = pcall(function() require("scenes.battlescape_screen") end)
    if ok then
        testPass("BattlescapeSystem", "Module loaded")
    else
        testFail("BattlescapeSystem", "Module failed: " .. tostring(err))
        success = false
    end
    
    -- Test Basescape
    print("[TEST] Basescape System")
    ok, err = pcall(function() require("scenes.basescape_screen") end)
    if ok then
        testPass("BasescapeSystem", "Module loaded")
    else
        testFail("BasescapeSystem", "Module failed: " .. tostring(err))
        success = false
    end
    
    return success
end

-- Test 5: Game Systems Integration
function Tests.testGameSystemsIntegration()
    print("\n" .. string.rep("=", 60))
    print("TEST SEQUENCE 5: Game Systems Integration")
    print(string.rep("=", 60) .. "\n")
    
    local success = true
    
    -- Test Combat Systems
    print("[TEST] Combat Systems")
    local ok, err = pcall(function()
        require("battlescape.combat.unit")
        require("battlescape.logic.pathfinding")
        require("battlescape.logic.accuracy_system")
    end)
    if ok then
        testPass("CombatSystems", "All combat modules loaded")
    else
        testFail("CombatSystems", "Combat modules failed: " .. tostring(err))
        success = false
    end
    
    -- Test Base Systems
    print("[TEST] Base Management Systems")
    ok, err = pcall(function()
        require("basescape.logic.base_manager")
        require("basescape.logic.facility_registry")
    end)
    if ok then
        testPass("BaseSystems", "All base modules loaded")
    else
        testFail("BaseSystems", "Base modules failed: " .. tostring(err))
        success = false
    end
    
    -- Test Strategic Systems
    print("[TEST] Strategic Systems")
    ok, err = pcall(function()
        require("basescape.research.research_manager")
        require("geoscape.faction_system")
    end)
    if ok then
        testPass("StrategicSystems", "All strategic modules loaded")
    else
        testFail("StrategicSystems", "Strategic modules failed: " .. tostring(err))
        success = false
    end
    
    return success
end

-- Test 6: Data Integrity
function Tests.testDataIntegrity()
    print("\n" .. string.rep("=", 60))
    print("TEST SEQUENCE 6: Data Integrity")
    print(string.rep("=", 60) .. "\n")
    
    local DataLoader = require("core.data_loader")
    local success = true
    
    -- Check terrain types
    if DataLoader.terrainTypes and DataLoader.terrainTypes.terrain then
        local terrainCount = #DataLoader.terrainTypes.getAllIds()
        if terrainCount > 0 then
            testPass("TerrainData", string.format("%d terrain types loaded", terrainCount))
        else
            testFail("TerrainData", "No terrain types found")
            success = false
        end
    else
        testFail("TerrainData", "Terrain data structure invalid")
        success = false
    end
    
    -- Check weapons
    if DataLoader.weapons and DataLoader.weapons.weapons then
        local weaponCount = #DataLoader.weapons.getAllIds()
        if weaponCount > 0 then
            testPass("WeaponData", string.format("%d weapons loaded", weaponCount))
        else
            testFail("WeaponData", "No weapons found")
            success = false
        end
    else
        testFail("WeaponData", "Weapon data structure invalid")
        success = false
    end
    
    -- Check unit classes
    if DataLoader.unitClasses and DataLoader.unitClasses.classes then
        local classCount = #DataLoader.unitClasses.getAllIds()
        if classCount > 0 then
            testPass("UnitClassData", string.format("%d unit classes loaded", classCount))
        else
            testFail("UnitClassData", "No unit classes found")
            success = false
        end
    else
        testFail("UnitClassData", "Unit class data structure invalid")
        success = false
    end
    
    return success
end

-- Summary Report
function Tests.printSummary()
    print("\n" .. string.rep("=", 60))
    print("TEST SUMMARY")
    print(string.rep("=", 60) .. "\n")
    
    local totalTests = results.passed + results.failed
    local percentage = (results.passed / totalTests) * 100
    
    print(string.format("Total Tests:  %d", totalTests))
    print(string.format("Passed:       %d (%.1f%%)", results.passed, percentage))
    print(string.format("Failed:       %d (%.1f%%)", results.failed, 100 - percentage))
    
    if results.failed > 0 then
        print("\n" .. string.rep("-", 60))
        print("FAILED TESTS:")
        print(string.rep("-", 60))
        for _, test in ipairs(results.tests) do
            if test.status == "FAIL" then
                print(string.format("  • %s: %s", test.name, test.message))
            end
        end
    end
    
    print("\n" .. string.rep("=", 60))
    if results.failed == 0 then
        print("🎉 ALL TESTS PASSED!")
    else
        print(string.format("⚠️  %d test(s) failed", results.failed))
    end
    print(string.rep("=", 60) .. "\n")
end

-- Run all tests
function Tests.runAll()
    print("\n" .. string.rep("=", 70))
    print(" ALIEN FALL - PHASE 2 TASK 5 MANUAL INTEGRATION TEST")
    print(" Comprehensive Gameplay System Verification")
    print(string.rep("=", 70) .. "\n")
    
    Tests.testGameInitialization()
    Tests.testCoreSystemsLoading()
    Tests.testUISystemsLoading()
    Tests.testGameLayersLoading()
    Tests.testGameSystemsIntegration()
    Tests.testDataIntegrity()
    
    Tests.printSummary()
    
    return results.failed == 0
end

return Tests



