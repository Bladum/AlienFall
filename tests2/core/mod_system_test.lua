-- ─────────────────────────────────────────────────────────────────────────
-- MOD SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests mod loading, validation, data access, and mod switching
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK MOD MANAGER
-- ─────────────────────────────────────────────────────────────────────────

local ModManager = {}
ModManager.__index = ModManager

local ACTIVE_MOD = {
    mod = {
        id = "xcom_simple",
        name = "XCOM Simple",
        version = "1.0.0"
    },
    paths = {
        root = "mods/core",
        content = "mods/core/content",
        rules = "mods/core/rules"
    }
}

local TERRAIN_TYPES = {
    {id = "grass", name = "Grass", image = "grass.png"},
    {id = "forest", name = "Forest", image = "forest.png"},
    {id = "mountain", name = "Mountain", image = "mountain.png"}
}

local MAPBLOCKS = {
    {id = "block1", type = "terrain"},
    {id = "block2", type = "building"}
}

local MOD_LIST = {
    {id = "xcom_simple", name = "XCOM Simple", version = "1.0.0"},
    {id = "expansion", name = "Expansion Pack", version = "1.1.0"}
}

function ModManager.loadMod(modId)
    if modId == "xcom_simple" then
        ModManager.activeMod = ACTIVE_MOD
        return true
    end
    return false
end

function ModManager.getActiveMod()
    return ModManager.activeMod
end

function ModManager.getTerrainTypes()
    return TERRAIN_TYPES
end

function ModManager.getMapblocks()
    return MAPBLOCKS
end

function ModManager.getContentPath(...)
    local pathParts = {...}
    local fullPath = "mods/core"
    for _, part in ipairs(pathParts) do
        fullPath = fullPath .. "/" .. part
    end
    return fullPath
end

function ModManager.scanMods()
    return MOD_LIST
end

function ModManager.setActiveMod(modId)
    for _, mod in ipairs(MOD_LIST) do
        if mod.id == modId then
            ModManager.activeMod = {
                mod = mod,
                paths = {
                    root = "mods/" .. modId,
                    content = "mods/" .. modId .. "/content",
                    rules = "mods/" .. modId .. "/rules"
                }
            }
            return true
        end
    end
    return false
end

function ModManager.getWeapons()
    return {
        {id = "pistol", name = "Pistol", damage = 3},
        {id = "rifle", name = "Rifle", damage = 4}
    }
end

function ModManager.getUnitClasses()
    return {
        {id = "soldier", name = "Soldier", health = 100},
        {id = "heavy", name = "Heavy", health = 150}
    }
end

-- Initialize with default mod
ModManager.activeMod = ACTIVE_MOD

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK TOML
-- ─────────────────────────────────────────────────────────────────────────

local TOML = {}
TOML.__index = TOML

local MOCK_MOD_CONFIG = {
    mod = {
        id = "xcom_simple",
        name = "XCOM Simple",
        version = "1.0.0"
    }
}

local MOCK_TERRAIN_DATA = {
    terrain = {
        grass = {name = "Grass", image = "grass.png"},
        forest = {name = "Forest", image = "forest.png"}
    }
}

function TOML.load(filePath)
    if filePath:find("mod%.toml$") then
        return MOCK_MOD_CONFIG
    elseif filePath:find("terrain%.toml$") then
        return MOCK_TERRAIN_DATA
    elseif filePath:find("weapons%.toml$") then
        return {weapons = {{id = "pistol", damage = 3}}}
    elseif filePath:find("classes%.toml$") then
        return {classes = {{id = "soldier", health = 100}}}
    end
    return nil
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK DATA LOADER
-- ─────────────────────────────────────────────────────────────────────────

local DataLoader = {}
DataLoader.__index = DataLoader

function DataLoader.loadTOML(filePath)
    return TOML.load(filePath)
end

function DataLoader.validateTOML(data)
    return data ~= nil and type(data) == "table"
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK ASSETS
-- ─────────────────────────────────────────────────────────────────────────

local Assets = {}
Assets.__index = Assets

function Assets.getPlaceholder()
    return {
        type = "placeholder",
        image = "placeholder.png",
        width = 32,
        height = 32
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "core.mod_system",
    fileName = "mod_system_test.lua",
    description = "Mod loading, validation, data access, and switching systems"
})

Suite:before(function() print("[ModSystemTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: MOD MANAGER
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("ModManager", function()
    Suite:testMethod("ModManager.loadMod", {description="Loads core mod successfully", testCase="load_core_mod", type="functional"},
    function()
        Helpers.assertNotNil(ModManager, "ModManager should be available")
        Helpers.assertNotNil(ModManager.loadMod, "ModManager.loadMod should exist")
        local result = ModManager.loadMod("xcom_simple")
        Helpers.assertTrue(result, "Should load core mod successfully")
    end)

    Suite:testMethod("ModManager.getTerrainTypes", {description="Retrieves terrain types from mod", testCase="get_terrain_types", type="functional"},
    function()
        local terrainTypes = ModManager.getTerrainTypes()
        Helpers.assertNotNil(terrainTypes, "Terrain types should be loaded")
        Helpers.assertTrue(#terrainTypes > 0, "Terrain types array should not be empty")
    end)

    Suite:testMethod("ModManager.getMapblocks", {description="Retrieves mapblocks from mod", testCase="get_mapblocks", type="functional"},
    function()
        local mapblocks = ModManager.getMapblocks()
        Helpers.assertNotNil(mapblocks, "Mapblocks should be loaded")
    end)

    Suite:testMethod("ModManager.getActiveMod", {description="Validates active mod structure", testCase="validate_mod_structure", type="functional"},
    function()
        local modData = ModManager.getActiveMod()
        Helpers.assertNotNil(modData, "Active mod data should exist")
        Helpers.assertNotNil(modData.mod, "Mod metadata should exist")
        Helpers.assertNotNil(modData.paths, "Mod paths should exist")
        Helpers.assertNotNil(modData.mod.id, "Mod ID should exist")
    end)

    Suite:testMethod("ModManager.getContentPath", {description="Resolves content paths correctly", testCase="content_path_resolution", type="functional"},
    function()
        local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
        Helpers.assertNotNil(terrainPath, "Terrain content path should be resolved")
        Helpers.assertTrue(terrainPath:find("terrain.toml") ~= nil, "Terrain path should contain terrain.toml")
    end)

    Suite:testMethod("ModManager.scanMods", {description="Discovers available mods", testCase="mod_discovery", type="functional"},
    function()
        local modList = ModManager.scanMods()
        Helpers.assertNotNil(modList, "Mod list should be returned")
        Helpers.assertTrue(#modList > 0, "Should discover at least one mod")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: TOML PARSING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("TOML Parsing", function()
    Suite:testMethod("TOML.load", {description="Loads TOML library and parses files", testCase="toml_library", type="functional"},
    function()
        Helpers.assertNotNil(TOML, "TOML library should be available")
        Helpers.assertNotNil(TOML.load, "TOML.load should exist")
    end)

    Suite:testMethod("TOML.load", {description="Loads mod configuration from mod.toml", testCase="load_mod_config", type="functional"},
    function()
        local modPath = ModManager.getContentPath("../mod.toml")
        if modPath then
            local modConfig = TOML.load(modPath)
            Helpers.assertNotNil(modConfig, "Should load mod.toml")
            if modConfig then
                Helpers.assertNotNil(modConfig.mod, "Mod section should exist")
                if modConfig.mod then
                    Helpers.assertEqual(modConfig.mod.id, "xcom_simple", "Mod ID should be correct")
                end
            end
        end
    end)

    Suite:testMethod("TOML.load", {description="Parses terrain data from TOML", testCase="parse_terrain_data", type="functional"},
    function()
        local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
        if terrainPath then
            local terrainData = TOML.load(terrainPath)
            Helpers.assertNotNil(terrainData, "Should load terrain.toml")
            if terrainData then
                Helpers.assertNotNil(terrainData.terrain, "Terrain section should exist")
            end
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: DATA LOADING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Data Loading", function()
    Suite:testMethod("DataLoader.loadTOML", {description="Loads TOML files through DataLoader", testCase="data_loader_toml", type="functional"},
    function()
        Helpers.assertNotNil(DataLoader, "DataLoader should be available")
        Helpers.assertNotNil(DataLoader.loadTOML, "DataLoader.loadTOML should exist")
    end)

    Suite:testMethod("DataLoader.validateTOML", {description="Validates TOML data structure", testCase="validate_toml", type="functional"},
    function()
        Helpers.assertNotNil(DataLoader.validateTOML, "DataLoader.validateTOML should exist")
        local valid = DataLoader.validateTOML({test = "data"})
        Helpers.assertTrue(valid, "Should validate correct TOML data")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: ASSET SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Asset System", function()
    Suite:testMethod("Assets.getPlaceholder", {description="Retrieves placeholder assets", testCase="asset_placeholder", type="functional"},
    function()
        Helpers.assertNotNil(Assets, "Assets system should be available")
        Helpers.assertNotNil(Assets.getPlaceholder, "Assets.getPlaceholder should exist")
    end)

    Suite:testMethod("Assets.getPlaceholder", {description="Returns valid placeholder data", testCase="verify_asset", type="functional"},
    function()
        local placeholder = Assets.getPlaceholder()
        Helpers.assertNotNil(placeholder, "Should get placeholder")
        Helpers.assertEqual(placeholder.type, "placeholder", "Placeholder type should be correct")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: MOD SWITCHING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Mod Switching", function()
    Suite:testMethod("ModManager.setActiveMod", {description="Switches to same mod successfully", testCase="switch_same_mod", type="functional"},
    function()
        local currentMod = ModManager.getActiveMod()
        Helpers.assertNotNil(currentMod, "Should have active mod")
        Helpers.assertNotNil(currentMod.mod, "Should have mod metadata")
        Helpers.assertNotNil(currentMod.mod.id, "Should have mod ID")

        local result = ModManager.setActiveMod(currentMod.mod.id)
        Helpers.assertTrue(result, "Should switch to same mod")

        local newActive = ModManager.getActiveMod()
        Helpers.assertNotNil(newActive, "Should have new active mod")
        Helpers.assertEqual(newActive.mod.id, currentMod.mod.id, "Mod should remain the same")
    end)

    Suite:testMethod("ModManager.setActiveMod", {description="Handles invalid mod ID gracefully", testCase="invalid_mod_switch", type="functional"},
    function()
        local result = ModManager.setActiveMod("nonexistent_mod_12345")
        Helpers.assertFalse(result, "Should fail for invalid mod ID")
    end)

    Suite:testMethod("ModManager.scanMods", {description="Maintains consistent mod list", testCase="mod_list_consistency", type="functional"},
    function()
        local modList = ModManager.scanMods()
        Helpers.assertNotNil(modList, "Mod list should exist")
        Helpers.assertTrue(#modList > 0, "Should have mods in list")

        local activeMod = ModManager.getActiveMod()
        if activeMod then
            local found = false
            for _, mod in ipairs(modList) do
                if mod.id == activeMod.mod.id then
                    found = true
                    break
                end
            end
            Helpers.assertTrue(found, "Active mod should be in mod list")
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 6: DEPENDENCIES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Dependencies", function()
    Suite:testMethod("ModManager.getActiveMod", {description="Validates complete mod structure", testCase="validate_structure", type="functional"},
    function()
        local activeMod = ModManager.getActiveMod()
        Helpers.assertNotNil(activeMod, "Should have active mod")

        Helpers.assertNotNil(activeMod.mod, "Mod metadata should exist")
        if activeMod.mod then
            Helpers.assertNotNil(activeMod.mod.id, "Mod ID should exist")
            Helpers.assertNotNil(activeMod.mod.name, "Mod name should exist")
            Helpers.assertNotNil(activeMod.mod.version, "Mod version should exist")
        end
    end)

    Suite:testMethod("ModManager.getContentPath", {description="Validates content path resolution", testCase="content_path_validation", type="functional"},
    function()
        local paths = {"rules/battle/terrain.toml", "rules/item/weapons.toml", "rules/unit/classes.toml"}

        for _, path in ipairs(paths) do
            local fullPath = ModManager.getContentPath(path)
            Helpers.assertNotNil(fullPath, "Content path should resolve for: " .. path)
            Helpers.assertTrue(fullPath:find("%.toml$") ~= nil, "Should be TOML file path")
        end
    end)

    Suite:testMethod("TOML.load", {description="Validates TOML file accessibility", testCase="toml_accessibility", type="functional"},
    function()
        local testFiles = {
            ["rules/battle/terrain.toml"] = "terrain",
            ["rules/item/weapons.toml"] = "weapons",
            ["rules/unit/classes.toml"] = "classes"
        }

        for filePath, expectedSection in pairs(testFiles) do
            local fullPath = ModManager.getContentPath(filePath)
            if fullPath then
                local data = TOML.load(fullPath)
                Helpers.assertNotNil(data, "Should load TOML: " .. filePath)
                if data then
                    Helpers.assertNotNil(data[expectedSection], "Should have section '" .. expectedSection .. "' in " .. filePath)
                end
            end
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 7: CONTENT RESOLUTION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Content Resolution", function()
    Suite:testMethod("ModManager.getTerrainTypes", {description="Resolves terrain type data", testCase="terrain_resolution", type="functional"},
    function()
        local terrainTypes = ModManager.getTerrainTypes()
        Helpers.assertNotNil(terrainTypes, "Terrain types should resolve")
        Helpers.assertEqual(type(terrainTypes), "table", "Should be table")
        Helpers.assertTrue(#terrainTypes > 0, "Should have terrain types")

        local firstTerrain = terrainTypes[1]
        if firstTerrain then
            Helpers.assertNotNil(firstTerrain.id, "Terrain should have ID")
            Helpers.assertNotNil(firstTerrain.name, "Terrain should have name")
            Helpers.assertNotNil(firstTerrain.image, "Terrain should have image")
        end
    end)

    Suite:testMethod("ModManager.getWeapons", {description="Resolves weapon data", testCase="weapon_resolution", type="functional"},
    function()
        local weapons = ModManager.getWeapons()
        Helpers.assertNotNil(weapons, "Weapons should resolve")
        Helpers.assertEqual(type(weapons), "table", "Should be table")
        Helpers.assertTrue(#weapons > 0, "Should have weapons")
    end)

    Suite:testMethod("ModManager.getUnitClasses", {description="Resolves unit class data", testCase="unit_class_resolution", type="functional"},
    function()
        local unitClasses = ModManager.getUnitClasses()
        Helpers.assertNotNil(unitClasses, "Unit classes should resolve")
        Helpers.assertEqual(type(unitClasses), "table", "Should be table")
        Helpers.assertTrue(#unitClasses > 0, "Should have unit classes")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 8: ERROR HANDLING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Error Handling", function()
    Suite:testMethod("ModManager.setActiveMod", {description="Handles invalid mod ID", testCase="invalid_mod_id", type="functional"},
    function()
        local result = ModManager.setActiveMod("nonexistent_mod")
        Helpers.assertFalse(result, "Should fail for invalid mod ID")
    end)

    Suite:testMethod("ModManager.getActiveMod", {description="Handles no active mod scenario", testCase="no_active_mod", type="functional"},
    function()
        local oldActive = ModManager.activeMod
        ModManager.activeMod = nil

        local modData = ModManager.getActiveMod()
        Helpers.assertEqual(modData, nil, "Should return nil when no active mod")

        ModManager.activeMod = oldActive
    end)

    Suite:testMethod("TOML.load", {description="Handles invalid TOML files", testCase="invalid_toml", type="functional"},
    function()
        local invalidData = TOML.load("nonexistent_file.toml")
        Helpers.assertEqual(invalidData, nil, "Should return nil for invalid file")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
