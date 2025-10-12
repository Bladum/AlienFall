-- MapGenerator Module
-- Provides both procedural and mapblock-based map generation
-- Unified interface for battlescape map creation

local DataLoader = require("systems.data_loader")
local Battlefield = require("systems.battle.battlefield")
local BattleTile = require("systems.battle_tile")

local MapGenerator = {}

-- Load configuration
local configLoaded, configData = pcall(require, "data.mapgen_config")
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

-- Generate completely random map using cellular automata
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

-- Smooth terrain using cellular automata
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

-- Get neighboring terrain types
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

-- Find most common terrain in list
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

-- Add random features (rooms, obstacles, etc.)
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

-- Generate map from mapblock system (delegates to GridMap)
function MapGenerator.generateFromMapblocks(blockPool, gridSize, biomePreferences)
    print("[MapGenerator] Generating mapblock-based map: " .. gridSize .. "x" .. gridSize .. " blocks")
    
    if not blockPool or #blockPool == 0 then
        print("[MapGenerator] ERROR: Empty block pool")
        return nil
    end
    
    local GridMap = require("systems.battle.grid_map")
    
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

-- Generate map using configured method
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

-- Set generation method
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

-- Get current generation method
function MapGenerator.getMethod()
    return MapGenerator.config.method
end

-- Set procedural parameters
function MapGenerator.setProceduralParams(width, height, seed)
    if width then MapGenerator.config.proceduralWidth = width end
    if height then MapGenerator.config.proceduralHeight = height end
    if seed then MapGenerator.config.proceduralSeed = seed end
    
    print(string.format("[MapGenerator] Procedural params: %dx%d, seed=%s",
        MapGenerator.config.proceduralWidth,
        MapGenerator.config.proceduralHeight,
        tostring(MapGenerator.config.proceduralSeed)))
end

return MapGenerator
