---MapGenerationPipeline - Next-Gen Map Generator
---
---Next-generation map generator implementing the full pipeline: Biome → Terrain → MapScript
---→ MapBlock → Final Map. Replaces legacy map generation with modular, scriptable system.
---Part of TASK-031 map generation overhaul.
---
---Features:
---  - Biome-based generation (terrain, climate, vegetation)
---  - Terrain generation (procedural heightmaps, features)
---  - MapScript execution (lua-based map modifications)
---  - MapBlock assembly (prefab placement)
---  - Final map optimization and validation
---  - Difficulty scaling
---
---Generation Pipeline:
---  1. Biome: Select biome (urban, forest, desert, arctic)
---  2. Terrain: Generate base terrain and heightmap
---  3. MapScript: Execute lua scripts for features
---  4. MapBlock: Place prefab structures
---  5. Final: Optimize, validate, spawn units
---
---Biome Examples:
---  - Urban: Buildings, roads, vehicles
---  - Forest: Trees, rivers, clearings
---  - Desert: Sand, rocks, oasis
---  - Arctic: Snow, ice, igloos
---
---Key Exports:
---  - MapGenerationPipeline.generate(options): Generates complete map
---  - MapGenerationPipeline.generateBiomeTerrain(biomeId): Step 1
---  - MapGenerationPipeline.applyMapScript(map, scriptId): Step 2
---  - MapGenerationPipeline.placeMapBlocks(map, blocks): Step 3
---  - MapGenerationPipeline.finalize(map): Step 4
---  - MapGenerationPipeline.validate(map): Validates map
---
---Dependencies:
---  - battlescape.mapscripts.mapscript_executor: Lua script execution
---  - battlescape.data.mapscripts_v2: Script definitions
---  - battlescape.maps.mapblock_loader_v2: MapBlock loading
---
---@module battlescape.maps.map_generation_pipeline
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapPipeline = require("battlescape.maps.map_generation_pipeline")
---  local map = MapPipeline.generate({
---    biomeId = "urban",
---    difficulty = 5,
---    missionType = "crash",
---    size = {width = 60, height = 60}
---  })
---
---@see battlescape.mapscripts.mapscript_executor For script execution
---@see TASK-031 For pipeline specification

-- Map Generation Pipeline
-- Biome → Terrain → MapScript → MapBlock → Final Map
-- Next-generation map generator for TASK-031

local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")
local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")

local MapGenerationPipeline = {}

---@class GenerationOptions
---@field biomeId string Biome identifier
---@field difficulty number Mission difficulty (1-10)
---@field missionType? string Mission type (crash, landing, terror, etc.)
---@field size? table Preferred map size {width, height} in MapBlocks
---@field teams? table Team definitions {team, size, equipment}
---@field seed? number Random seed for reproducible generation

---@class GeneratedMap
---@field biomeId string Source biome
---@field terrainId string Selected terrain
---@field mapScriptId string Selected MapScript
---@field blocks table Array of placed blocks {x, y, blockId, rotation}
---@field size table Final size {width, height} in MapBlocks
---@field tileSize table Size in tiles {width, height}
---@field spawnZones table Team spawn zones
---@field metadata table Generation metadata
---@field placementResults table? Team placement results

---@class MapGenerationPipeline
---@field biomes table Biomes module
---@field terrains table Terrains module
---@field mapScripts table MapScripts module
---@field terrainSelector TerrainSelector
---@field mapScriptSelector MapScriptSelector
---@field mapBlockLoader MapBlockLoader
---@field generate fun(self, options: GenerationOptions): GeneratedMap?
---@field printMapInfo fun(self, map: GeneratedMap)
---@field generateUFOCrash fun(self, ufoSize: string, biomeId: string, difficulty: number): GeneratedMap?
---@field generateUFOLanding fun(self, ufoSize: string, biomeId: string, difficulty: number): GeneratedMap?
---@field generateBaseDefense fun(self, difficulty: number): GeneratedMap?

---Create a new map generation pipeline
---@param modules table {biomes, terrains, mapScripts, terrainSelector, mapScriptSelector, mapBlockLoader}
---@return MapGenerationPipeline
function MapGenerationPipeline.new(modules)
    local self = setmetatable({}, {__index = MapGenerationPipeline})
    
    self.biomes = modules.biomes
    self.terrains = modules.terrains
    self.mapScripts = modules.mapScripts
    self.terrainSelector = modules.terrainSelector
    self.mapScriptSelector = modules.mapScriptSelector
    self.mapBlockLoader = modules.mapBlockLoader
    
    return self
end

---Generate a complete map from options
---@param options GenerationOptions Generation parameters
---@return GeneratedMap? map Generated map or nil on failure
function MapGenerationPipeline:generate(options)
    print("\n[MapGenerationPipeline] Starting map generation...")
    print(string.format("  Biome: %s, Difficulty: %d", options.biomeId, options.difficulty))
    
    -- Step 1: Select terrain from biome
    local terrainId = self:selectTerrain(options)
    if not terrainId then
        print("[MapGenerationPipeline] Failed to select terrain")
        return nil
    end
    
    -- Step 2: Select MapScript from terrain
    local mapScriptId = self:selectMapScript(terrainId, options)
    if not mapScriptId then
        print("[MapGenerationPipeline] Failed to select MapScript")
        return nil
    end
    
    -- Step 3: Execute MapScript
    local context = self:placeMapBlocks(mapScriptId, options)
    if not context then
        print("[MapGenerationPipeline] Failed to execute MapScript")
        return nil
    end
    
    -- Step 4: Convert context to blocks for compatibility
    local blocks = self:contextToBlocks(context)
    
    -- Step 4: Calculate map metadata
    local mapScript = self.mapScripts.get(mapScriptId)
    local generatedMap = {
        biomeId = options.biomeId,
        terrainId = terrainId,
        mapScriptId = mapScriptId,
        blocks = blocks,
        size = {width = context.width, height = context.height},
        tileSize = self:calculateTileSize(blocks),
        spawnZones = mapScript.spawnZones,
        metadata = {
            difficulty = options.difficulty,
            missionType = options.missionType,
            generatedAt = os.time(),
            fillPercentage = MapScriptExecutor.getStats(context).fillPercentage
        }
    }
    
    print(string.format("[MapGenerationPipeline] Generated map: %dx%d blocks (%dx%d tiles)",
        generatedMap.size.width, generatedMap.size.height,
        generatedMap.tileSize.width, generatedMap.tileSize.height))
    print(string.format("  Terrain: %s, MapScript: %s", terrainId, mapScriptId))
    
    return generatedMap
end

---Select terrain from biome with constraints
---@param options GenerationOptions Generation parameters
---@return string? terrainId Selected terrain ID or nil
function MapGenerationPipeline:selectTerrain(options)
    -- Build terrain selection constraints
    local constraints = {
        difficulty = options.difficulty
    }
    
    -- Add mission-specific constraints
    if options.missionType == "crash" then
        constraints.tags = {"ufo", "crash"}
    elseif options.missionType == "landing" then
        constraints.tags = {"ufo", "landing"}
    elseif options.missionType == "base_defense" then
        constraints.tags = {"xcom", "base"}
    end
    
    local terrainId = self.terrainSelector:selectTerrain(options.biomeId, constraints)
    return terrainId
end

---Select MapScript from terrain with constraints
---@param terrainId string Terrain ID
---@param options GenerationOptions Generation parameters
---@return string? mapScriptId Selected MapScript ID or nil
function MapGenerationPipeline:selectMapScript(terrainId, options)
    local terrain = self.terrains.get(terrainId)
    if not terrain then
        return nil
    end
    
    -- Build MapScript selection constraints
    local constraints = {
        difficulty = options.difficulty,
        biome = options.biomeId
    }
    
    -- Add size constraints if specified
    if options.size then
        constraints.maxWidth = options.size.width
        constraints.maxHeight = options.size.height
    end
    
    local mapScriptId = self.mapScriptSelector:selectMapScript(terrain, constraints)
    return mapScriptId
end

---Place MapBlocks according to MapScript commands (using MapScriptExecutor)
---@param mapScriptId string MapScript ID
---@param options GenerationOptions Generation parameters
---@return table? context Execution context or nil on failure
function MapGenerationPipeline:placeMapBlocks(mapScriptId, options)
    -- Get MapScript from v2 loader
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapGenerationPipeline] MapScript not found: " .. tostring(mapScriptId))
        return nil
    end
    
    -- Execute MapScript with seed
    local seed = options.seed or os.time()
    print(string.format("[MapGenerationPipeline] Executing MapScript '%s' with seed %d", mapScriptId, seed))
    
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapGenerationPipeline] MapScript execution failed")
        return nil
    end
    
    -- Log statistics
    local stats = MapScriptExecutor.getStats(context)
    print(string.format("[MapGenerationPipeline] Map generated: %.1f%% filled (%d empty, %d filled)",
        stats.fillPercentage, stats.emptyCount, stats.filledCount))
    
    return context
end

---Convert execution context to block list for compatibility
---@param context table MapScript execution context
---@return table blocks Array of {x, y, blockId, key}
function MapGenerationPipeline:contextToBlocks(context)
    local blocks = {}
    
    if not context or not context.grid then
        return blocks
    end
    
    for y = 1, context.height do
        for x = 1, context.width do
            local key = string.format("%d_%d", x - 1, y - 1)
            local tileKey = context.grid[key]
            
            if tileKey and tileKey ~= "EMPTY" then
                table.insert(blocks, {
                    x = x - 1,
                    y = y - 1,
                    blockId = "map_tile",
                    key = tileKey
                })
            end
        end
    end
    
    return blocks
end

---Select a MapBlock for a specific position (deprecated, use MapScriptExecutor)
---@param blockDef table Block definition {x, y, tags, required}
---@param options GenerationOptions Generation parameters
---@return string? blockId Selected block ID or nil
function MapGenerationPipeline:selectMapBlockForPosition(blockDef, options)
    -- Use tags from block definition
    local requiredTags = blockDef.tags or {}
    
    -- Find matching MapBlocks
    local blockId = self.mapBlockLoader:getRandomByTags(requiredTags)
    
    if not blockId then
        -- Fallback: try with fewer tags if no exact match
        if #requiredTags > 1 then
            blockId = self.mapBlockLoader:getRandomByTags({requiredTags[1]})
        end
    end
    
    return blockId
end

---Calculate total tile size from placed blocks
---@param blocks table Array of placed blocks
---@return table size {width, height} in tiles
function MapGenerationPipeline:calculateTileSize(blocks)
    -- For now, assume standard MapBlock size (10x10 tiles)
    -- This should be refined based on actual MapBlock dimensions
    
    local maxX = 0
    local maxY = 0
    
    for _, block in ipairs(blocks) do
        maxX = math.max(maxX, block.x)
        maxY = math.max(maxY, block.y)
    end
    
    local blockTileSize = 10 -- Standard MapBlock size in tiles
    
    return {
        width = (maxX + 1) * blockTileSize,
        height = (maxY + 1) * blockTileSize
    }
end

---Generate map for specific mission type
---@param missionType string Mission type
---@param biomeId string Biome ID
---@param difficulty number Difficulty level
---@return GeneratedMap? map Generated map or nil
function MapGenerationPipeline:generateForMission(missionType, biomeId, difficulty)
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = missionType
    }
    
    return self:generate(options)
end

---Generate UFO crash site map
---@param ufoSize string UFO size (small, medium, large)
---@param biomeId string Biome ID
---@param difficulty number Difficulty level
---@return GeneratedMap? map Generated map or nil
function MapGenerationPipeline:generateUFOCrash(ufoSize, biomeId, difficulty)
    -- Force crash terrain
    local terrainId = "ufo_crash"
    
    -- Select appropriate MapScript based on UFO size
    local mapScriptId
    if ufoSize == "small" then
        mapScriptId = "ufo_small_crash"
    elseif ufoSize == "medium" then
        mapScriptId = "ufo_medium_crash"
    elseif ufoSize == "large" then
        mapScriptId = "ufo_large_crash"
    else
        mapScriptId = "ufo_small_crash"
    end
    
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = "crash"
    }
    
    -- Manually set terrain and MapScript
    local blocks = self:placeMapBlocks(mapScriptId, options)
    if not blocks then
        return nil
    end
    
    local mapScript = self.mapScripts.get(mapScriptId)
    
    return {
        biomeId = biomeId,
        terrainId = terrainId,
        mapScriptId = mapScriptId,
        blocks = blocks,
        size = mapScript.size,
        tileSize = self:calculateTileSize(blocks),
        spawnZones = mapScript.spawnZones,
        metadata = {
            difficulty = difficulty,
            missionType = "crash",
            ufoSize = ufoSize,
            generatedAt = os.time()
        }
    }
end

---Generate UFO landing site map
---@param ufoSize string UFO size (small, medium, large)
---@param biomeId string Biome ID
---@param difficulty number Difficulty level
---@return GeneratedMap? map Generated map or nil
function MapGenerationPipeline:generateUFOLanding(ufoSize, biomeId, difficulty)
    local terrainId = "ufo_landing"
    
    local mapScriptId
    if ufoSize == "small" then
        mapScriptId = "ufo_small_landing"
    elseif ufoSize == "medium" then
        mapScriptId = "ufo_medium_landing"
    elseif ufoSize == "large" then
        mapScriptId = "ufo_large_landing"
    else
        mapScriptId = "ufo_small_landing"
    end
    
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = "landing"
    }
    
    local blocks = self:placeMapBlocks(mapScriptId, options)
    if not blocks then
        return nil
    end
    
    local mapScript = self.mapScripts.get(mapScriptId)
    
    return {
        biomeId = biomeId,
        terrainId = terrainId,
        mapScriptId = mapScriptId,
        blocks = blocks,
        size = mapScript.size,
        tileSize = self:calculateTileSize(blocks),
        spawnZones = mapScript.spawnZones,
        metadata = {
            difficulty = difficulty,
            missionType = "landing",
            ufoSize = ufoSize,
            generatedAt = os.time()
        }
    }
end

---Generate XCOM base defense map
---@param difficulty number Difficulty level
---@return GeneratedMap? map Generated map or nil
function MapGenerationPipeline:generateBaseDefense(difficulty)
    local terrainId = "xcom_base"
    local mapScriptId = "xcom_base_defense"
    local biomeId = "urban" -- Bases are always urban
    
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = "base_defense"
    }
    
    local blocks = self:placeMapBlocks(mapScriptId, options)
    if not blocks then
        return nil
    end
    
    local mapScript = self.mapScripts.get(mapScriptId)
    
    return {
        biomeId = biomeId,
        terrainId = terrainId,
        mapScriptId = mapScriptId,
        blocks = blocks,
        size = mapScript.size,
        tileSize = self:calculateTileSize(blocks),
        spawnZones = mapScript.spawnZones,
        metadata = {
            difficulty = difficulty,
            missionType = "base_defense",
            generatedAt = os.time()
        }
    }
end

---Validate generated map
---@param map GeneratedMap Generated map
---@return boolean valid True if map is valid
---@return string? error Error message if invalid
function MapGenerationPipeline:validateMap(map)
    if not map then
        return false, "Map is nil"
    end
    
    if not map.blocks or #map.blocks == 0 then
        return false, "No blocks placed"
    end
    
    if not map.spawnZones or #map.spawnZones == 0 then
        return false, "No spawn zones defined"
    end
    
    -- Verify all blocks exist
    for _, block in ipairs(map.blocks) do
        if not self.mapBlockLoader:getBlock(block.blockId) then
            return false, string.format("Block not found: %s", block.blockId)
        end
    end
    
    return true, nil
end

---Print generation statistics
---@param map GeneratedMap Generated map
function MapGenerationPipeline:printMapInfo(map)
    print("\n[MapGenerationPipeline] Map Information")
    print("----------------------------------------")
    print(string.format("Biome: %s", map.biomeId))
    print(string.format("Terrain: %s", map.terrainId))
    print(string.format("MapScript: %s", map.mapScriptId))
    print(string.format("Size: %dx%d blocks (%dx%d tiles)",
        map.size.width, map.size.height,
        map.tileSize.width, map.tileSize.height))
    print(string.format("Blocks placed: %d", #map.blocks))
    print(string.format("Spawn zones: %d", #map.spawnZones))
    
    if map.metadata.missionType then
        print(string.format("Mission type: %s", map.metadata.missionType))
    end
    if map.metadata.ufoSize then
        print(string.format("UFO size: %s", map.metadata.ufoSize))
    end
    print(string.format("Difficulty: %d", map.metadata.difficulty))
    print("----------------------------------------\n")
end

---Generate UFO crash site map
---@param ufoSize string UFO size ("small", "medium", "large")
---@param biomeId string Biome identifier
---@param difficulty number Mission difficulty (1-10)
---@return GeneratedMap? map Generated map or nil on failure
function MapGenerationPipeline:generateUFOCrash(ufoSize, biomeId, difficulty)
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = "ufo_crash",
        ufoSize = ufoSize
    }
    return self:generate(options)
end

---Generate UFO landing site map
---@param ufoSize string UFO size ("small", "medium", "large")
---@param biomeId string Biome identifier
---@param difficulty number Mission difficulty (1-10)
---@return GeneratedMap? map Generated map or nil on failure
function MapGenerationPipeline:generateUFOLanding(ufoSize, biomeId, difficulty)
    local options = {
        biomeId = biomeId,
        difficulty = difficulty,
        missionType = "ufo_landing",
        ufoSize = ufoSize
    }
    return self:generate(options)
end

---Generate base defense map
---@param difficulty number Mission difficulty (1-10)
---@return GeneratedMap? map Generated map or nil on failure
function MapGenerationPipeline:generateBaseDefense(difficulty)
    local options = {
        biomeId = "base",
        difficulty = difficulty,
        missionType = "base_defense"
    }
    return self:generate(options)
end

return MapGenerationPipeline






















