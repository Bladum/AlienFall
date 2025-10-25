---MapGenerator - Unified Map Generation System
---
---Provides both procedural and MapBlock-based map generation with unified interface.
---Configurable through assets/data/mapgen_config.lua with fallback defaults.
---Legacy system being replaced by MapGenerationPipeline.
---
---Features:
---  - Procedural generation (cellular automata)
---  - MapBlock-based generation (template-based)
---  - Configuration file support
---  - Multiple algorithms (rooms, caves, buildings)
---  - Terrain type support
---  - Spawn point placement
---
---Generation Modes:
---  - Procedural: Cellular automata, noise-based
---  - MapBlock: Template-based using pre-designed blocks
---  - Hybrid: Combines both approaches
---
---Procedural Algorithms:
---  - Cellular automata: Organic cave/terrain generation
---  - Room placement: Rectangular rooms with corridors
---  - Building generation: Urban structures
---  - Noise-based: Perlin/simplex noise patterns
---
---MapBlock Generation:
---  - Load MapBlocks from files
---  - Arrange in grid pattern
---  - Apply rotations and variations
---  - Connect blocks with transitions
---
---Configuration:
---  - Load from assets/data/mapgen_config.lua
---  - Fallback to hardcoded defaults
---  - Per-mission customization
---
---Key Exports:
---  - MapGenerator.generate(config): Generates complete map
---  - MapGenerator.generateProcedural(config): Procedural only
---  - MapGenerator.generateMapBlock(config): MapBlock only
---  - MapGenerator.loadConfig(path): Loads configuration
---  - MapGenerator.getDefaultConfig(): Returns defaults
---
---Dependencies:
---  - core.data_loader: Configuration loading
---  - battlescape.battlefield.battlefield: Battlefield structure
---  - battlescape.combat.battle_tile: Tile definition
---
---@module battlescape.maps.map_generator
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapGenerator = require("battlescape.maps.map_generator")
---  local config = {width = 60, height = 60, algorithm = "cellular"}
---  local battlefield = MapGenerator.generate(config)
---
---@see battlescape.maps.map_generation_pipeline For new system
---@see battlescape.maps.mapblock_system For MapBlock management

-- MapGenerator Module
-- Provides both procedural and mapblock-based map generation
-- Unified interface for battlescape map creation

local DataLoader = require("core.data_loader")
local Battlefield = require("battlescape.battlefield.battlefield")
local BattleTile = require("battlescape.combat.battle_tile")

--- Provides unified map generation for tactical battlescape.
--- Supports both procedural generation using cellular automata and
--- mapblock-based generation using pre-designed terrain templates.
--- Configurable through assets/data/mapgen_config.lua with fallback defaults.
---
--- Configuration is loaded from assets/data/mapgen_config.lua with fallback defaults.
local MapGenerator = {}

-- Load configuration
local configLoaded, configData = pcall(require, "assets.data.mapgen_config")
if configLoaded then
    MapGenerator.config = {
        method = configData.method or "mapblock",
        proceduralSeed = configData.procedural.seed,
        proceduralWidth = configData.procedural.width or 60,
        proceduralHeight = configData.procedural.height or 60,
        mapblockGridSize = configData.mapblock.gridSize or {min = 4, max = 7},
        biomeWeights = configData.mapblock.biomeWeights or {}
    }
    print("[MapGenerator] Loaded configuration: method=" .. MapGenerator.config.method)
else
    -- Configuration defaults (fallback)
    MapGenerator.config = {
        method = "mapblock",  -- "procedural" or "mapblock"
        proceduralSeed = nil,  -- nil for random, number for reproducible
        proceduralWidth = 60,
        proceduralHeight = 60,
        mapblockGridSize = {min = 4, max = 7},
        biomeWeights = {
            urban = 0.3,
            forest = 0.25,
            industrial = 0.2,
            water = 0.1,
            rural = 0.1,
            mixed = 0.05
        }
    }
    print("[MapGenerator] Using default configuration")
end

---
--- PROCEDURAL GENERATION
---

--- Generates a completely random map using cellular automata smoothing.
--- Creates initial random terrain, applies smoothing passes, and adds feature rectangles.
---
--- @param width number Map width in tiles
--- @param height number Map height in tiles
--- @param seed number|nil Optional random seed for reproducible generation
--- @return Battlefield|nil Generated battlefield, or nil on error
function MapGenerator.generateProcedural(width, height, seed)
    print("[MapGenerator] Generating procedural map: " .. width .. "x" .. height)

    if seed then
        math.randomseed(seed)
        print("[MapGenerator] Using seed: " .. seed)
    end

    -- Create battlefield
    local battlefield = Battlefield.new(width, height)

    -- Get terrain types
    local terrainTypes = DataLoader.terrainTypes.getAll()
    local terrainIds = {}
    for id, _ in pairs(terrainTypes) do
        table.insert(terrainIds, id)
    end

    if #terrainIds == 0 then
        print("[MapGenerator] ERROR: No terrain types available")
        return nil
    end

    print("[MapGenerator] Available terrain types: " .. #terrainIds)

    -- Initialize with random terrain
    for y = 1, height do
        for x = 1, width do
            local randomTerrain = terrainIds[math.random(1, #terrainIds)]
            battlefield:setTile(x, y, BattleTile.new(x, y, randomTerrain))
        end
    end

    -- Apply cellular automata smoothing (3 passes)
    for pass = 1, 3 do
        MapGenerator._smoothTerrain(battlefield, terrainIds)
    end

    -- Add some variety features
    MapGenerator._addFeatures(battlefield, terrainIds)

    print("[MapGenerator] Procedural generation complete")
    return battlefield
end

--- Smooths terrain using cellular automata rules.
--- Converts tiles to match their most common neighbors with 50% probability.
---
--- @param battlefield Battlefield The battlefield to smooth
--- @param terrainIds table Array of available terrain IDs
function MapGenerator._smoothTerrain(battlefield, terrainIds)
    local width = battlefield.width
    local height = battlefield.height

    -- Create copy of current state
    local oldTiles = {}
    for y = 1, height do
        oldTiles[y] = {}
        for x = 1, width do
            local tile = battlefield:getTile(x, y)
            oldTiles[y][x] = tile and tile.terrainId or "floor"
        end
    end

    -- Apply smoothing
    for y = 1, height do
        for x = 1, width do
            local neighbors = MapGenerator._getNeighborTerrain(oldTiles, x, y, width, height)

            -- If most neighbors are the same type, convert this tile
            local mostCommon = MapGenerator._getMostCommonTerrain(neighbors)
            if mostCommon and #neighbors >= 4 then
                -- 50% chance to convert to most common neighbor
                if math.random() < 0.5 then
                    battlefield:setTile(x, y, BattleTile.new(x, y, mostCommon))
                end
            end
        end
    end
end

--- Gets the terrain types of all neighboring tiles (8-directional).
---
--- @param tiles table[][] 2D array of terrain IDs
--- @param x number Center tile X coordinate
--- @param y number Center tile Y coordinate
--- @param width number Map width
--- @param height number Map height
--- @return table Array of neighboring terrain IDs
function MapGenerator._getNeighborTerrain(tiles, x, y, width, height)
    local neighbors = {}
    local offsets = {
        {-1, 0}, {1, 0}, {0, -1}, {0, 1},  -- Cardinal
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1}  -- Diagonal
    }

    for _, offset in ipairs(offsets) do
        local nx = x + offset[1]
        local ny = y + offset[2]

        if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
            local terrainId = tiles[ny] and tiles[ny][nx]
            if terrainId then
                table.insert(neighbors, terrainId)
            end
        end
    end

    return neighbors
end

--- Finds the most common terrain type in a list of terrain IDs.
---
--- @param terrainList table Array of terrain IDs
--- @return string|nil The most common terrain ID, or nil if list is empty
function MapGenerator._getMostCommonTerrain(terrainList)
    if #terrainList == 0 then return nil end

    local counts = {}
    for _, terrain in ipairs(terrainList) do
        counts[terrain] = (counts[terrain] or 0) + 1
    end

    local maxCount = 0
    local mostCommon = nil
    for terrain, count in pairs(counts) do
        if count > maxCount then
            maxCount = count
            mostCommon = terrain
        end
    end

    return mostCommon
end

--- Adds random rectangular features (rooms, obstacles) to the map.
--- Creates 3-5 random rectangles filled with random terrain types.
---
--- @param battlefield Battlefield The battlefield to add features to
--- @param terrainIds table Array of available terrain IDs
function MapGenerator._addFeatures(battlefield, terrainIds)
    local width = battlefield.width
    local height = battlefield.height

    -- Add 3-5 random rectangular features
    local numFeatures = math.random(3, 5)

    for i = 1, numFeatures do
        local featureWidth = math.random(3, 8)
        local featureHeight = math.random(3, 8)
        local startX = math.random(5, width - featureWidth - 5)
        local startY = math.random(5, height - featureHeight - 5)

        -- Pick random terrain for this feature
        local featureTerrain = terrainIds[math.random(1, #terrainIds)]

        -- Fill rectangle
        for y = startY, startY + featureHeight - 1 do
            for x = startX, startX + featureWidth - 1 do
                if x >= 1 and x <= width and y >= 1 and y <= height then
                    battlefield:setTile(x, y, BattleTile.new(x, y, featureTerrain))
                end
            end
        end
    end
end

---
--- MAPBLOCK GENERATION
---

--- Generates a map using the mapblock system with themed biome selection.
--- Delegates to GridMap for actual generation and converts result to Battlefield.
---
--- @param blockPool table Array of available map blocks
--- @param gridSize number Size of the grid (gridSize x gridSize blocks)
--- @param biomePreferences table|nil Optional biome weight preferences
--- @return Battlefield|nil Generated battlefield, or nil on error
function MapGenerator.generateFromMapblocks(blockPool, gridSize, biomePreferences)
    print("[MapGenerator] Generating mapblock-based map: " .. gridSize .. "x" .. gridSize .. " blocks")

    if not blockPool or #blockPool == 0 then
        print("[MapGenerator] ERROR: Empty block pool")
        return nil
    end

    local GridMap = require("battlescape.maps.grid_map")

    -- Create GridMap
    local gridMap = GridMap.new(gridSize, gridSize)

    -- Generate themed map
    local success = gridMap:generateThemed(blockPool, biomePreferences)

    if not success then
        print("[MapGenerator] ERROR: Failed to generate themed map")
        return nil
    end

    -- Convert to battlefield
    local battlefield = gridMap:toBattlefield()

    print("[MapGenerator] Mapblock generation complete: " .. battlefield.width .. "x" .. battlefield.height .. " tiles")
    return battlefield
end

---
--- UNIFIED GENERATION INTERFACE
---

--- Generates a map using the configured method with optional overrides.
--- Supports both procedural and mapblock generation methods.
---
--- @param options table|nil Optional generation parameters
--- @return Battlefield|nil Generated battlefield, or nil on error
function MapGenerator.generate(options)
    options = options or {}

    -- Merge with defaults
    local method = options.method or MapGenerator.config.method
    local seed = options.seed or MapGenerator.config.proceduralSeed

    print("[MapGenerator] Generating map using method: " .. method)

    if method == "procedural" then
        local width = options.width or MapGenerator.config.proceduralWidth
        local height = options.height or MapGenerator.config.proceduralHeight

        return MapGenerator.generateProcedural(width, height, seed)

    elseif method == "mapblock" then
        local blockPool = options.blockPool
        if not blockPool then
            print("[MapGenerator] ERROR: blockPool required for mapblock generation")
            return nil
        end

        local gridSize = options.gridSize or math.random(
            MapGenerator.config.mapblockGridSize.min,
            MapGenerator.config.mapblockGridSize.max
        )

        local biomePreferences = options.biomePreferences or MapGenerator.config.biomeWeights

        return MapGenerator.generateFromMapblocks(blockPool, gridSize, biomePreferences)

    else
        print("[MapGenerator] ERROR: Unknown generation method: " .. tostring(method))
        return nil
    end
end

--- Sets the generation method for future generate() calls.
---
--- @param method string Generation method ("procedural" or "mapblock")
--- @return boolean True if method was set successfully, false otherwise
function MapGenerator.setMethod(method)
    if method == "procedural" or method == "mapblock" then
        MapGenerator.config.method = method
        print("[MapGenerator] Generation method set to: " .. method)
        return true
    else
        print("[MapGenerator] ERROR: Invalid generation method: " .. tostring(method))
        return false
    end
end

--- Gets the current generation method.
---
--- @return string Current generation method
function MapGenerator.getMethod()
    return MapGenerator.config.method
end

--- Sets procedural generation parameters.
---
--- @param width number|nil Map width in tiles
--- @param height number|nil Map height in tiles
--- @param seed number|nil Random seed for reproducible generation
function MapGenerator.setProceduralParams(width, height, seed)
    if width then MapGenerator.config.proceduralWidth = width end
    if height then MapGenerator.config.proceduralHeight = height end
    if seed then MapGenerator.config.proceduralSeed = seed end

    print(string.format("[MapGenerator] Procedural params: %dx%d, seed=%s",
        MapGenerator.config.proceduralWidth,
        MapGenerator.config.proceduralHeight,
        tostring(MapGenerator.config.proceduralSeed)))
end

---
--- MAPSCRIPT GENERATION (New System)
---

--- Generate map using MapScript system (recommended for structured layouts).
--- Uses the new MapScriptExecutor to execute TOML-based Map Scripts with commands.
---
--- @param mapScriptId string MapScript ID to execute
--- @param seed number? Optional seed for reproducibility
--- @return table|nil Execution context with generated map grid, or nil on failure
function MapGenerator.generateFromMapScript(mapScriptId, seed)
    print(string.format("[MapGenerator] Generating map from MapScript: %s", mapScriptId))
    
    local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")
    local MapScriptsV2 = require("battlescape.data.mapscripts_v2")
    
    -- Load MapScript
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print("[MapGenerator] MapScript not found: " .. mapScriptId)
        return nil
    end
    
    -- Use provided seed or generate random one
    seed = seed or os.time()
    print(string.format("[MapGenerator] Using seed: %d", seed))
    
    -- Execute MapScript
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapGenerator] MapScript execution failed")
        return nil
    end
    
    -- Log statistics
    local stats = MapScriptExecutor.getStats(context)
    print(string.format("[MapGenerator] Map generated successfully:"))
    print(string.format("  Size: %dx%d blocks (%dx%d tiles)",
        context.width, context.height,
        context.width * 15, context.height * 15))
    print(string.format("  Fill: %.1f%% (%d empty, %d filled tiles)",
        stats.fillPercentage, stats.emptyCount, stats.filledCount))
    
    -- Log craft and UFO spawn points if present
    if context.craftSpawn then
        print(string.format("  Craft spawn: (%d, %d) - %s",
            context.craftSpawn.x, context.craftSpawn.y, context.craftSpawn.blockId))
    end
    if context.ufoObjective then
        print(string.format("  UFO objective: (%d, %d) - %s",
            context.ufoObjective.x, context.ufoObjective.y, context.ufoObjective.blockId))
    end
    
    print("[MapGenerator] MapScript generation complete")
    return context
end

return MapGenerator



























