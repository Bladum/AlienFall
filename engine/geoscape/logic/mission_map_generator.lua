-- Mission Map Generator Integration
-- Bridges Geoscape missions to Battlescape map generation

local MapGenerationPipeline = require("battlescape.map.map_generation_pipeline")
local Biomes = require("geoscape.data.biomes")
local Terrains = require("battlescape.data.terrains")
local MapScripts = require("battlescape.data.mapscripts")
local TerrainSelector = require("battlescape.logic.terrain_selector")
local MapScriptSelector = require("battlescape.logic.mapscript_selector")
local MapBlockLoader = require("battlescape.map.mapblock_loader")
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
        -- TODO: Implement team placement
        -- local teamPlacement = TeamPlacement.new(battlefield)
        -- local placementResults = teamPlacement:placeAllTeams(map.spawnZones, teamSizes)
        -- TeamPlacement.printStatistics(placementResults)
        -- map.placementResults = placementResults
        print("[MissionMapGenerator] Team placement not yet implemented")
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
