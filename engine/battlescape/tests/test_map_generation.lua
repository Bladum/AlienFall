-- Test Map Generation Pipeline
-- Verify biome → terrain → MapScript → MapBlock pipeline

local Biomes = require("geoscape.data.biomes")
local Terrains = require("battlescape.data.terrains")
local MapScripts = require("battlescape.data.mapscripts")
local TerrainSelector = require("battlescape.logic.terrain_selector")
local MapScriptSelector = require("battlescape.logic.mapscript_selector")
local MapBlockLoader = require("battlescape.map.mapblock_loader")
local MapGenerationPipeline = require("battlescape.map.map_generation_pipeline")
local TeamPlacement = require("battlescape.logic.team_placement")
local Battlefield = require("battlescape.logic.battlefield")

local TestMapGeneration = {}

---Run all tests
function TestMapGeneration.runAll()
    print("\n========================================")
    print("  MAP GENERATION PIPELINE TESTS")
    print("========================================\n")
    
    local passed = 0
    local failed = 0
    
    -- Test 1: Module Loading
    print("[TEST 1] Module Loading...")
    if TestMapGeneration.testModuleLoading() then
        passed = passed + 1
        print("✓ PASSED\n")
    else
        failed = failed + 1
        print("✗ FAILED\n")
    end
    
    -- Test 2: Terrain Selection
    print("[TEST 2] Terrain Selection...")
    if TestMapGeneration.testTerrainSelection() then
        passed = passed + 1
        print("✓ PASSED\n")
    else
        failed = failed + 1
        print("✗ FAILED\n")
    end
    
    -- Test 3: MapScript Selection
    print("[TEST 3] MapScript Selection...")
    if TestMapGeneration.testMapScriptSelection() then
        passed = passed + 1
        print("✓ PASSED\n")
    else
        failed = failed + 1
        print("✗ FAILED\n")
    end
    
    -- Test 4: Full Pipeline
    print("[TEST 4] Full Pipeline Generation...")
    if TestMapGeneration.testFullPipeline() then
        passed = passed + 1
        print("✓ PASSED\n")
    else
        failed = failed + 1
        print("✗ FAILED\n")
    end
    
    -- Test 5: Distribution Analysis
    print("[TEST 5] Distribution Analysis...")
    if TestMapGeneration.testDistribution() then
        passed = passed + 1
        print("✓ PASSED\n")
    else
        failed = failed + 1
        print("✗ FAILED\n")
    end
    
    -- Test 6: Team Placement
    print("[TEST 6] Team Placement...")
    if TestMapGeneration.testTeamPlacement() then
        passed = passed + 1
        print("✓ PASSED\n")
    else
        failed = failed + 1
        print("✗ FAILED\n")
    end
    
    -- Summary
    print("========================================")
    print(string.format("Tests Passed: %d", passed))
    print(string.format("Tests Failed: %d", failed))
    print(string.format("Total Tests: %d", passed + failed))
    print("========================================\n")
    
    return failed == 0
end

---Test 1: Verify all modules load correctly
function TestMapGeneration.testModuleLoading()
    -- Check biomes
    local biomeIds = Biomes.getAllIds()
    print(string.format("  Loaded %d biomes", #biomeIds))
    if #biomeIds == 0 then
        print("  ERROR: No biomes loaded")
        return false
    end
    
    -- Check terrains
    local terrainIds = Terrains.getAllIds()
    print(string.format("  Loaded %d terrains", #terrainIds))
    if #terrainIds == 0 then
        print("  ERROR: No terrains loaded")
        return false
    end
    
    -- Check MapScripts
    local mapScriptIds = MapScripts.getAllIds()
    print(string.format("  Loaded %d MapScripts", #mapScriptIds))
    if #mapScriptIds == 0 then
        print("  ERROR: No MapScripts loaded")
        return false
    end
    
    return true
end

---Test 2: Verify terrain selection from biome
function TestMapGeneration.testTerrainSelection()
    local selector = TerrainSelector.new(Biomes, Terrains)
    
    -- Test forest biome
    local terrainId = selector:selectTerrain("forest", {difficulty = 3})
    print(string.format("  Forest biome → Terrain: %s", terrainId or "nil"))
    if not terrainId then
        print("  ERROR: Failed to select terrain from forest biome")
        return false
    end
    
    -- Test urban biome
    terrainId = selector:selectTerrain("urban", {difficulty = 4})
    print(string.format("  Urban biome → Terrain: %s", terrainId or "nil"))
    if not terrainId then
        print("  ERROR: Failed to select terrain from urban biome")
        return false
    end
    
    -- Test with difficulty filter
    terrainId = selector:selectTerrain("plains", {difficulty = 1})
    print(string.format("  Plains (diff 1) → Terrain: %s", terrainId or "nil"))
    if not terrainId then
        print("  ERROR: Failed to select terrain with difficulty filter")
        return false
    end
    
    return true
end

---Test 3: Verify MapScript selection from terrain
function TestMapGeneration.testMapScriptSelection()
    local selector = MapScriptSelector.new(MapScripts)
    
    -- Test forest terrain
    local terrain = Terrains.get("dense_forest")
    if not terrain then
        print("  ERROR: Forest terrain not found")
        return false
    end
    
    local mapScriptId = selector:selectMapScript(terrain, {difficulty = 3})
    print(string.format("  Dense forest → MapScript: %s", mapScriptId or "nil"))
    if not mapScriptId then
        print("  ERROR: Failed to select MapScript from forest terrain")
        return false
    end
    
    -- Test urban terrain
    terrain = Terrains.get("urban_street")
    if not terrain then
        print("  ERROR: Urban terrain not found")
        return false
    end
    
    mapScriptId = selector:selectMapScript(terrain, {difficulty = 4})
    print(string.format("  Urban street → MapScript: %s", mapScriptId or "nil"))
    if not mapScriptId then
        print("  ERROR: Failed to select MapScript from urban terrain")
        return false
    end
    
    return true
end

---Test 4: Full pipeline generation (without MapBlocks)
function TestMapGeneration.testFullPipeline()
    -- Create mock mod manager
    local mockModManager = {
        getActiveMods = function() return {"core"} end,
        getModPath = function() return nil end  -- No actual MapBlocks
    }
    
    -- Initialize components
    local terrainSelector = TerrainSelector.new(Biomes, Terrains)
    local mapScriptSelector = MapScriptSelector.new(MapScripts)
    local mapBlockLoader = MapBlockLoader.new(mockModManager)
    
    -- Create some mock blocks for testing
    local mockBlock = MapBlockLoader.createMockBlock("test_block", {"forest", "dense"})
    mapBlockLoader:registerBlock(mockBlock)
    
    local pipeline = MapGenerationPipeline.new({
        biomes = Biomes,
        terrains = Terrains,
        mapScripts = MapScripts,
        terrainSelector = terrainSelector,
        mapScriptSelector = mapScriptSelector,
        mapBlockLoader = mapBlockLoader
    })
    
    -- Test generation for forest mission
    local options = {
        biomeId = "forest",
        difficulty = 3,
        missionType = "patrol"
    }
    
    local map = pipeline:generate(options)
    if not map then
        print("  ERROR: Failed to generate map")
        return false
    end
    
    print(string.format("  Generated map: %s → %s → %s", 
        map.biomeId, map.terrainId, map.mapScriptId))
    print(string.format("  Size: %dx%d blocks", map.size.width, map.size.height))
    print(string.format("  Blocks placed: %d", #map.blocks))
    
    -- Validate map
    local valid, error = pipeline:validateMap(map)
    if not valid then
        print(string.format("  ERROR: Map validation failed: %s", error))
        return false
    end
    
    return true
end

---Test 5: Distribution analysis
function TestMapGeneration.testDistribution()
    local terrainSelector = TerrainSelector.new(Biomes, Terrains)
    
    -- Test forest biome distribution
    print("  Analyzing forest biome terrain distribution (100 samples)...")
    local distribution = terrainSelector:getDistribution("forest", 100)
    
    local count = 0
    for terrainId, samples in pairs(distribution) do
        count = count + 1
        print(string.format("    %s: %d (%.1f%%)", terrainId, samples, (samples/100)*100))
    end
    
    if count == 0 then
        print("  ERROR: No terrain distribution")
        return false
    end
    
    return true
end

---Test 6: Team placement
function TestMapGeneration.testTeamPlacement()
    -- Create a simple battlefield
    local battlefield = Battlefield.new(60, 60)
    
    -- Create mock spawn zones
    local spawnZones = {
        {team = "player", x = 0, y = 5, radius = 1},
        {team = "enemy", x = 5, y = 0, radius = 1}
    }
    
    -- Create team placement manager
    local teamPlacement = TeamPlacement.new(battlefield)
    
    -- Define team sizes
    local teamSizes = {
        player = 8,
        enemy = 12
    }
    
    -- Validate zones
    local valid, error = TeamPlacement.validateZones(spawnZones, teamSizes)
    print(string.format("  Zone validation: %s", valid and "PASS" or "FAIL: " .. error))
    
    -- Calculate capacities
    local capacities = TeamPlacement.calculateZoneCapacities(spawnZones)
    for team, capacity in pairs(capacities) do
        print(string.format("  %s capacity: ~%d positions", team, capacity))
    end
    
    -- Test grid position generation
    local gridPositions = TeamPlacement.createGridPositions(30, 30, 8, 2)
    print(string.format("  Generated %d grid positions", #gridPositions))
    if #gridPositions ~= 8 then
        print("  ERROR: Expected 8 grid positions")
        return false
    end
    
    return true
end

return TestMapGeneration
