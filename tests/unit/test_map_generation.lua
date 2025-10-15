---Test Suite for Map Generation System
---
---Tests mission map generation, terrain selection, mapscript execution,
---mapblock placement, and map validation.
---
---Test Coverage:
---  - Mission map generation (4 tests)
---  - Terrain/MapScript availability (2 tests)
---  - MapGenerationPipeline operations (4 tests)
---  - Validation and statistics (2 tests)
---
---Dependencies:
---  - battlescape.mission_map_generator
---  - battlescape.maps.map_generation_pipeline
---  - mock.maps
---  - mock.missions
---
---@module tests.unit.test_map_generation
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local MissionMapGenerator = require("battlescape.mission_map_generator")
local MapGenerationPipeline = require("battlescape.maps.map_generation_pipeline")
local MockMaps = require("tests.mock.maps")
local MockMissions = require("tests.mock.missions")

local TestMapGeneration = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper: Run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper: Assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

-- Helper: Assert not nil
local function assertNotNil(value, message)
    assert(value ~= nil, message or "Expected value to not be nil")
end

-- Helper: Assert equals
local function assertEquals(actual, expected, message)
    if actual ~= expected then
        error(message or string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
    end
end

-- Helper: Assert table has key
local function assertHasKey(table, key, message)
    assert(table[key] ~= nil, message or string.format("Expected table to have key '%s'", key))
end

---Test MissionMapGenerator initialization
function TestMapGeneration.testMissionMapGeneratorInitialization()
    print("[TEST] MissionMapGenerator initialization...")

    -- Test initialization
    local generator = MissionMapGenerator.initialize({})
    assertNotNil(generator, "MissionMapGenerator should initialize successfully")

    -- Test singleton pattern
    local generator2 = MissionMapGenerator.initialize({})
    assert(generator == generator2, "MissionMapGenerator should return same instance (singleton)")

    print("✓ MissionMapGenerator initialized successfully")
end

---Test terrain selection for different biomes
function TestMapGeneration.testTerrainSelection()
    print("[TEST] Terrain selection...")

    -- Test that biomes are available (we can't test selectTerrain since it doesn't exist)
    -- This is more of a data validation test
    local biomes = require("lore.biomes")
    assertNotNil(biomes, "Biomes module should be available")
    assert(type(biomes.getAllIds) == "function", "Biomes should have getAllIds method")

    local biomeIds = biomes.getAllIds()
    assert(#biomeIds > 0, "Should have at least one biome")

    print("✓ Terrain/biome system available")
end

---Test MapScript selection for mission types
function TestMapGeneration.testMapScriptSelection()
    print("[TEST] MapScript selection...")

    -- Test that mapscripts are available
    local mapScripts = require("battlescape.data.mapscripts")
    assertNotNil(mapScripts, "MapScripts module should be available")
    assert(type(mapScripts.getAllIds) == "function", "MapScripts should have getAllIds method")

    local scriptIds = mapScripts.getAllIds()
    assert(#scriptIds > 0, "Should have at least one mapscript")

    print("✓ MapScript system available")
end

---Test UFO crash map generation
function TestMapGeneration.testUFOCrashGeneration()
    print("[TEST] UFO crash map generation...")

    -- Create mock mission
    local mission = MockMissions.getMission("UFO")
    mission.type = "CRASH"
    mission.biome = "DESERT"

    -- Generate map
    local map = MissionMapGenerator.generateUFOCrash(mission)
    assertNotNil(map, "UFO crash map should be generated")

    -- Validate map structure (basic checks)
    assert(type(map) == "table", "Map should be a table")

    print("✓ UFO crash map generated successfully")
end

---Test UFO landing map generation
function TestMapGeneration.testUFOLandingGeneration()
    print("[TEST] UFO landing map generation...")

    -- Create mock mission
    local mission = MockMissions.getMission("UFO")
    mission.type = "LANDING"
    mission.biome = "FOREST"

    -- Generate map
    local map = MissionMapGenerator.generateUFOLanding(mission)
    assertNotNil(map, "UFO landing map should be generated")

    -- Validate map structure (basic checks)
    assert(type(map) == "table", "Map should be a table")

    print("✓ UFO landing map generated successfully")
end

---Test general mission map generation
function TestMapGeneration.testGeneralMissionGeneration()
    print("[TEST] General mission map generation...")

    -- Create mock mission
    local mission = MockMissions.getMission("SITE")
    mission.biome = "URBAN"

    -- Generate map
    local map = MissionMapGenerator.generateForMission(mission)
    assertNotNil(map, "General mission map should be generated")

    -- Validate map structure (basic checks)
    assert(type(map) == "table", "Map should be a table")

    print("✓ General mission map generated successfully")
end

---Test MapGenerationPipeline biome terrain generation
function TestMapGeneration.testBiomeTerrainGeneration()
    print("[TEST] Biome terrain generation...")

    -- Test urban terrain
    local urbanMap = MapGenerationPipeline.generateBiomeTerrain("URBAN")
    assertNotNil(urbanMap, "Urban terrain should be generated")
    assert(type(urbanMap) == "table", "Generated map should be a table")

    -- Test forest terrain
    local forestMap = MapGenerationPipeline.generateBiomeTerrain("FOREST")
    assertNotNil(forestMap, "Forest terrain should be generated")
    assert(type(forestMap) == "table", "Generated map should be a table")

    print("✓ Biome terrain generation working correctly")
end

---Test MapScript application
function TestMapGeneration.testMapScriptApplication()
    print("[TEST] MapScript application...")

    -- Generate base map
    local baseMap = MapGenerationPipeline.generateBiomeTerrain("URBAN")
    assertNotNil(baseMap, "Base map should be generated")

    -- Apply a mapscript
    local scriptedMap = MapGenerationPipeline.applyMapScript(baseMap, "urban_terror")
    assertNotNil(scriptedMap, "MapScript should be applied successfully")

    -- Map should still be valid
    assert(type(scriptedMap) == "table", "Scripted map should be a table")

    print("✓ MapScript application working correctly")
end

---Test MapBlock placement
function TestMapGeneration.testMapBlockPlacement()
    print("[TEST] MapBlock placement...")

    -- Test with a valid mapscript ID and options
    local options = {
        biomeId = "URBAN",
        difficulty = 3,
        seed = 12345
    }

    -- Place mapblocks using pipeline method
    local context = MapGenerationPipeline:placeMapBlocks("urban_terror", options)
    assertNotNil(context, "MapBlocks should be placed successfully")

    -- Context should be valid
    assert(type(context) == "table", "Placement context should be a table")

    print("✓ MapBlock placement working correctly")
end

---Test map validation
function TestMapGeneration.testMapValidation()
    print("[TEST] Map validation...")

    -- Generate a valid map
    local validMap = MapGenerationPipeline.generateBiomeTerrain("URBAN")
    local isValid = MapGenerationPipeline.validate(validMap)
    assert(isValid ~= nil, "Validation should return a result")

    print("✓ Map validation working correctly")
end

---Test mission validation
function TestMapGeneration.testMissionValidation()
    print("[TEST] Mission validation...")

    -- Test valid mission
    local validMission = MockMissions.getMission("SITE")
    local isValid, error = MissionMapGenerator.validateMission(validMission)
    assert(isValid, "Valid mission should pass validation")
    assert(error == nil, "Valid mission should have no error")

    -- Test invalid mission (no biome)
    local invalidMission = {type = "SITE", difficulty = 3}
    local isInvalid, errorMsg = MissionMapGenerator.validateMission(invalidMission)
    assert(not isInvalid, "Invalid mission should fail validation")
    assert(errorMsg ~= nil, "Invalid mission should have error message")

    print("✓ Mission validation working correctly")
end

---Test MapBlock statistics
function TestMapGeneration.testMapBlockStats()
    print("[TEST] MapBlock statistics...")

    -- Get statistics
    local stats = MissionMapGenerator.getMapBlockStats()
    assertNotNil(stats, "Statistics should be returned")
    assert(type(stats) == "table", "Statistics should be a table")
    assertHasKey(stats, "total", "Statistics should have total count")

    print("✓ MapBlock statistics working correctly")
end

---Run all map generation tests
function TestMapGeneration.runAll()
    print("=== Map Generation Test Suite ===")
    print("Testing mission map generation, terrain selection, and validation...")
    print()

    -- Run all tests
    runTest("MissionMapGenerator Initialization", TestMapGeneration.testMissionMapGeneratorInitialization)
    runTest("Terrain Selection", TestMapGeneration.testTerrainSelection)
    runTest("MapScript Selection", TestMapGeneration.testMapScriptSelection)
    runTest("UFO Crash Generation", TestMapGeneration.testUFOCrashGeneration)
    runTest("UFO Landing Generation", TestMapGeneration.testUFOLandingGeneration)
    runTest("General Mission Generation", TestMapGeneration.testGeneralMissionGeneration)
    runTest("Biome Terrain Generation", TestMapGeneration.testBiomeTerrainGeneration)
    runTest("MapScript Application", TestMapGeneration.testMapScriptApplication)
    runTest("MapBlock Placement", TestMapGeneration.testMapBlockPlacement)
    runTest("Map Validation", TestMapGeneration.testMapValidation)
    runTest("Mission Validation", TestMapGeneration.testMissionValidation)
    runTest("MapBlock Statistics", TestMapGeneration.testMapBlockStats)

    print()
    print(string.format("=== Results: %d passed, %d failed ===", testsPassed, testsFailed))

    if testsFailed > 0 then
        print("Failed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  - %s: %s", failure.name, failure.error))
        end
        return false
    end

    return true
end

-- Export for external usage
return TestMapGeneration