---MissionMapGenerator - Geoscape to Battlescape Bridge
---
---Bridges Geoscape missions to Battlescape map generation. Takes mission parameters
---(type, location, biome) and generates appropriate tactical map using MapBlocks,
---MapScripts, and terrain systems. Entry point for mission deployment.
---
---Features:
---  - Mission type to map conversion
---  - Biome-based terrain selection
---  - MapScript selection and execution
---  - Craft/UFO placement
---  - Team deployment
---  - Map validation
---
---Mission Types Supported:
---  - crash: UFO crash site maps
---  - landing: UFO landed maps
---  - terror: Terror site (urban) maps
---  - base: Alien base assault maps
---  - transport: Supply ship maps
---
---Generation Process:
---  1. Get mission parameters (type, biome, size)
---  2. Select terrain based on biome
---  3. Select MapScript for mission type
---  4. Execute MapScript (place MapBlocks)
---  5. Place craft/UFO spawns
---  6. Place teams (player, aliens)
---  7. Validate map (connectivity, spawns)
---  8. Return complete battlefield
---
---Map Constraints:
---  - Size: 60×60 tiles (typically)
---  - Terrain: Biome-appropriate (urban, forest, desert, etc.)
---  - Script: Mission-type specific
---  - Spawn points: Craft and aliens must be valid
---
---Key Exports:
---  - MissionMapGenerator.generate(mission): Returns battlefield map
---  - selectTerrain(biome): Returns terrain ID
---  - selectMapScript(missionType, terrain): Returns MapScript
---  - placeCraft(map, craftType): Returns spawn position
---  - placeAliens(map, missionType): Returns alien spawns
---
---Dependencies:
---  - battlescape.maps.map_generation_pipeline: Map generation core
---  - lore.biomes: Biome definitions
---  - battlescape.data.terrains: Terrain data
---  - battlescape.data.mapscripts: MapScript data
---  - battlescape.mapscripts.terrain_selector: Terrain selection
---  - battlescape.mapscripts.mapscript_selector: Script selection
---  - battlescape.maps.mapblock_loader: MapBlock loading
---
---@module battlescape.mission_map_generator
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MissionMapGenerator = require("battlescape.mission_map_generator")
---  local battlefield = MissionMapGenerator.generate(mission)
---
---@see battlescape.maps.map_generation_pipeline For map generation
---@see lore.missions.mission For mission data

-- Mission Map Generator Integration
-- Bridges Geoscape missions to Battlescape map generation

local MapGenerationPipeline = require("battlescape.maps.map_generation_pipeline")
local Biomes = require("lore.biomes")
local Terrains = require("battlescape.data.terrains")
local MapScripts = require("battlescape.data.mapscripts")
local TerrainSelector = require("battlescape.mapscripts.terrain_selector")
local MapScriptSelector = require("battlescape.mapscripts.mapscript_selector")
local MapBlockLoader = require("battlescape.maps.mapblock_loader")
-- local TeamPlacement = require("battlescape.logic.team_placement")

local MissionMapGenerator = {}

---@class MissionMapGenerator
---@field pipeline MapGenerationPipeline Map generation pipeline
---@field mapBlockLoader table Map block loader instance
---@field initialized boolean Whether generator is initialized

-- Singleton instance
MissionMapGenerator.instance = nil

---Initialize the mission map generator
---@param modManager table Mod manager instance
---@return MissionMapGenerator instance Generator instance
function MissionMapGenerator.initialize(modManager)
    if MissionMapGenerator.instance then
        return MissionMapGenerator.instance
    end

    print("[MissionMapGenerator] Initializing...")

    -- Create components
    local terrainSelector = TerrainSelector.new(Biomes, Terrains)
    local mapScriptSelector = MapScriptSelector.new(MapScripts)
    local mapBlockLoader = MapBlockLoader.new(modManager)

    -- Load MapBlocks from mods
    local blockCount = mapBlockLoader:loadAll()
    if blockCount == 0 then
        print("[MissionMapGenerator] WARNING: No MapBlocks loaded, using mock blocks")
        -- Create some mock blocks for testing
        local mockBlock = MapBlockLoader.createMockBlock("test_block", {"forest", "dense"})
        mapBlockLoader:registerBlock(mockBlock)
        mockBlock = MapBlockLoader.createMockBlock("test_urban", {"urban", "street"})
        mapBlockLoader:registerBlock(mockBlock)
        mockBlock = MapBlockLoader.createMockBlock("test_plains", {"plains", "grass"})
        mapBlockLoader:registerBlock(mockBlock)
    end

    -- Create pipeline
    local pipeline = MapGenerationPipeline.new({
        biomes = Biomes,
        terrains = Terrains,
        mapScripts = MapScripts,
        terrainSelector = terrainSelector,
        mapScriptSelector = mapScriptSelector,
        mapBlockLoader = mapBlockLoader
    })

    MissionMapGenerator.instance = {
        pipeline = pipeline,
        mapBlockLoader = mapBlockLoader,
        initialized = true
    }

    print("[MissionMapGenerator] Initialized successfully")
    return MissionMapGenerator.instance
end

---Get the singleton instance
---@return MissionMapGenerator instance Generator instance
function MissionMapGenerator.getInstance()
    if not MissionMapGenerator.instance then
        error("[MissionMapGenerator] Not initialized! Call initialize() first")
    end
    return MissionMapGenerator.instance
end

---Generate map for a mission
---@param mission table Mission data {biome, type, difficulty}
---@return GeneratedMap? map Generated map or nil on failure
function MissionMapGenerator.generateForMission(mission)
    local instance = MissionMapGenerator.getInstance()

    print(string.format("\n[MissionMapGenerator] Generating map for mission: %s", mission.type or "unknown"))

    -- Extract mission parameters
    local biomeId = mission.biome or mission.province and mission.province.biome or "forest"
    local difficulty = mission.difficulty or 3
    local missionType = mission.type or "patrol"

    -- Generate map using pipeline
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = missionType
    }

    local map = instance.pipeline:generate(options)

    if map then
        instance.pipeline:printMapInfo(map)
        return map
    else
        print("[MissionMapGenerator] ERROR: Map generation failed")
        return nil
    end
end

---Generate map for UFO crash mission
---@param mission table Mission data with UFO info
---@return GeneratedMap? map Generated map or nil on failure
function MissionMapGenerator.generateUFOCrash(mission)
    local instance = MissionMapGenerator.getInstance()

    local biomeId = mission.biome or mission.province and mission.province.biome or "forest"
    local difficulty = mission.difficulty or 4
    local ufoSize = mission.ufoSize or "small"

    print(string.format("\n[MissionMapGenerator] Generating UFO crash site: %s UFO", ufoSize))

    local map = instance.pipeline:generateUFOCrash(ufoSize, biomeId, difficulty)

    if map then
        instance.pipeline:printMapInfo(map)
    end

    return map
end

---Generate map for UFO landing mission
---@param mission table Mission data with UFO info
---@return GeneratedMap? map Generated map or nil on failure
function MissionMapGenerator.generateUFOLanding(mission)
    local instance = MissionMapGenerator.getInstance()

    local biomeId = mission.biome or mission.province and mission.province.biome or "forest"
    local difficulty = mission.difficulty or 5
    local ufoSize = mission.ufoSize or "small"

    print(string.format("\n[MissionMapGenerator] Generating UFO landing site: %s UFO", ufoSize))

    local map = instance.pipeline:generateUFOLanding(ufoSize, biomeId, difficulty)

    if map then
        instance.pipeline:printMapInfo(map)
    end

    return map
end

---Generate map for base defense mission
---@param mission table Mission data
---@return GeneratedMap? map Generated map or nil on failure
function MissionMapGenerator.generateBaseDefense(mission)
    local instance = MissionMapGenerator.getInstance()

    local difficulty = mission.difficulty or 7

    print("\n[MissionMapGenerator] Generating XCOM base defense map")

    local map = instance.pipeline:generateBaseDefense(difficulty)

    if map then
        instance.pipeline:printMapInfo(map)
    end

    return map
end

---Generate map with team placement
---@param mission table Mission data
---@param teamSizes table Map of team -> unit count
---@param battlefield? Battlefield Optional battlefield instance
---@return GeneratedMap? map Generated map with placement results
function MissionMapGenerator.generateWithTeams(mission, teamSizes, battlefield)
    -- Generate base map
    local map

    if mission.type == "crash" then
        map = MissionMapGenerator.generateUFOCrash(mission)
    elseif mission.type == "landing" then
        map = MissionMapGenerator.generateUFOLanding(mission)
    elseif mission.type == "base_defense" then
        map = MissionMapGenerator.generateBaseDefense(mission)
    else
        map = MissionMapGenerator.generateForMission(mission)
    end

    if not map then
        return nil
    end

    -- Place teams if battlefield provided
    if battlefield and teamSizes then
        -- Implement team placement algorithm
        local alliedUnits = teamSizes.allies or {}
        local enemyUnits = teamSizes.enemies or {}

        -- Find spawn zones from map
        local allySpawnZone = (map.spawnZones and map.spawnZones.allies) or {{q=1, r=1}, {q=2, r=1}, {q=1, r=2}}
        local enemySpawnZone = (map.spawnZones and map.spawnZones.enemies) or {{q=88, r=44}, {q=87, r=44}, {q=88, r=43}}

        -- Place allied units
        local units = {}
        for i, unit in ipairs(alliedUnits) do
            local spawnPos = allySpawnZone[(i % #allySpawnZone) + 1] or {q=1, r=1}
            unit.position = spawnPos
            unit.team = "allies"
            table.insert(units, unit)
        end

        -- Place enemy units
        for i, unit in ipairs(enemyUnits) do
            local spawnPos = enemySpawnZone[(i % #enemySpawnZone) + 1] or {q=88, r=44}
            unit.position = spawnPos
            unit.team = "enemies"
            table.insert(units, unit)
        end

        map.placementResults = {
            alliedCount = #alliedUnits,
            enemyCount = #enemyUnits,
            totalUnits = #alliedUnits + #enemyUnits,
            success = true,
            units = units
        }
        print(string.format("[MissionMapGenerator] Placed %d allies + %d enemies", #alliedUnits, #enemyUnits))
    end

    return map
end

---Validate mission can be generated
---@param mission table Mission data
---@return boolean valid True if mission can be generated
---@return string? error Error message if invalid
function MissionMapGenerator.validateMission(mission)
    -- Check biome exists
    local biomeId = mission.biome or mission.province and mission.province.biome
    if not biomeId then
        return false, "Mission has no biome"
    end

    local biome = Biomes.get(biomeId)
    if not biome then
        return false, string.format("Unknown biome: %s", biomeId)
    end

    -- Check difficulty is valid
    local difficulty = mission.difficulty or 3
    if difficulty < 1 or difficulty > 10 then
        return false, string.format("Invalid difficulty: %d (must be 1-10)", difficulty)
    end

    return true, nil
end

---Get MapBlock statistics
---@return table stats Block statistics {total, byTag, byMod}
function MissionMapGenerator.getMapBlockStats()
    local instance = MissionMapGenerator.getInstance()

    return {
        total = instance.mapBlockLoader:getCount(),
        tags = instance.mapBlockLoader:getAllTags(),
        blocks = instance.mapBlockLoader:getAllIds()
    }
end

---Print generator statistics
function MissionMapGenerator.printStatistics()
    local instance = MissionMapGenerator.getInstance()

    print("\n[MissionMapGenerator] Statistics")
    print("========================================")

    print("\nBiomes:")
    local biomes = Biomes.getAllIds()
    print(string.format("  Total: %d", #biomes))

    print("\nTerrains:")
    local terrains = Terrains.getAllIds()
    print(string.format("  Total: %d", #terrains))

    print("\nMapScripts:")
    local mapScripts = MapScripts.getAllIds()
    print(string.format("  Total: %d", #mapScripts))

    print("\nMapBlocks:")
    instance.mapBlockLoader:printStatistics()

    print("========================================\n")
end

return MissionMapGenerator

