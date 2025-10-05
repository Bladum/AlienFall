--- MapGenerator.lua
-- Implements deterministic battle map generation pipeline
-- Composes maps from terrain rules, Map Scripts, and reusable block pools
-- Provides seeded generation for reproducible maps and testing

local Class = require("util.Class")
local RNG = require("services.rng")
local MapNode = require("battlescape.map.MapNode")
local TileSet = require("battlescape.map.TileSet")

---@class MapGenerator
---@field private _terrainRules table Terrain type definitions and constraints
---@field private _blockPool table Available Map Blocks with metadata
---@field private _mapScripts table Generation scripts and recipes
---@field private _tilesets table Available tilesets for graphics
local MapGenerator = Class()

---Initialize MapGenerator
---@param terrainRules table Terrain definitions
---@param blockPool table Available blocks
---@param mapScripts table Generation scripts
---@param tilesets table Available tilesets
function MapGenerator:init(terrainRules, blockPool, mapScripts, tilesets)
    self._terrainRules = terrainRules or {}
    self._blockPool = blockPool or {}
    self._mapScripts = mapScripts or {}
    self._tilesets = tilesets or {}
end

---Generate battle map using specified parameters
---@param missionSeed number Mission seed for deterministic generation
---@param biome string Biome type (urban, rural, etc.)
---@param missionType string Mission type (assault, crash, etc.)
---@param mapSize table {width, height} in blocks
---@param scriptName string Name of generation script to use
---@return table|nil battleMap Generated map data or nil on failure
function MapGenerator:generateMap(missionSeed, biome, missionType, mapSize, scriptName)
    local rng = RNG:createSeededRNG(missionSeed)

    -- Step 1: Gather input parameters
    local context = {
        seed = missionSeed,
        biome = biome,
        missionType = missionType,
        mapSize = mapSize,
        rng = rng
    }

    -- Step 2: Resolve block pool for this generation
    local availableBlocks = self:resolveBlockPool(context)
    if #availableBlocks == 0 then
        return nil -- No valid blocks
    end

    -- Step 3: Get and execute Map Script
    local script = self._mapScripts[scriptName]
    if not script then
        return nil -- Invalid script
    end

    local blockGrid = self:executeMapScript(script, context, availableBlocks)
    if not blockGrid then
        return nil -- Script execution failed
    end

    -- Step 4: Expand blocks to tiles
    local tileMap = self:expandBlocksToTiles(blockGrid, context)

    -- Step 5: Preprocessing for AI and navigation
    local aiData = self:preprocessAIAndNavigation(tileMap, context)

    -- Step 6: Place spawns and factions
    local spawnData = self:placeSpawnsAndFactions(tileMap, context, aiData)

    -- Step 7: Apply player deployment zones
    local deploymentZones = self:createDeploymentZones(tileMap, context)

    -- Step 8: Initialize Fog of War
    local fogOfWar = self:initializeFogOfWar(tileMap, spawnData, context)

    -- Step 9: Apply pre-battle effects
    self:applyPreBattleEffects(tileMap, context)

    -- Step 10: Final validation
    if not self:validateMap(tileMap, spawnData, deploymentZones) then
        return nil -- Validation failed
    end

    -- Create final map object
    local battleMap = {
        tiles = tileMap,
        aiData = aiData,
        spawnData = spawnData,
        deploymentZones = deploymentZones,
        fogOfWar = fogOfWar,
        metadata = {
            seed = missionSeed,
            biome = biome,
            missionType = missionType,
            scriptName = scriptName,
            generatedAt = os.time()
        }
    }

    return battleMap
end

---Resolve available blocks for generation context
---@param context table Generation context
---@return table availableBlocks Filtered list of blocks
function MapGenerator:resolveBlockPool(context)
    local availableBlocks = {}

    for _, block in ipairs(self._blockPool) do
        if self:blockMatchesContext(block, context) then
            table.insert(availableBlocks, block)
        end
    end

    -- Sort by weight for weighted selection
    table.sort(availableBlocks, function(a, b)
        return (a.weight or 1) > (b.weight or 1)
    end)

    return availableBlocks
end

---Check if block matches generation context
---@param block table Block data
---@param context table Generation context
---@return boolean matches
function MapGenerator:blockMatchesContext(block, context)
    -- Check biome compatibility
    if block.biomes and not block.biomes[context.biome] then
        return false
    end

    -- Check mission type compatibility
    if block.missionTypes and not block.missionTypes[context.missionType] then
        return false
    end

    -- Check size constraints
    if block.size and (block.size.width > context.mapSize.width or block.size.height > context.mapSize.height) then
        return false
    end

    return true
end

---Execute Map Script to generate block grid
---@param script table Script definition
---@param context table Generation context
---@param availableBlocks table Available blocks
---@return table|nil blockGrid Block grid or nil on failure
function MapGenerator:executeMapScript(script, context, availableBlocks)
    local blockGrid = {}
    local placedBlocks = {}

    -- Initialize empty grid
    for x = 1, context.mapSize.width do
        blockGrid[x] = {}
        for y = 1, context.mapSize.height do
            blockGrid[x][y] = nil
        end
    end

    -- Execute script steps
    for _, step in ipairs(script.steps) do
        local success = self:executeScriptStep(step, blockGrid, context, availableBlocks, placedBlocks)
        if not success then
            return nil -- Step failed
        end
    end

    -- Fill remaining slots
    self:fillRemainingSlots(blockGrid, context, availableBlocks, placedBlocks)

    return blockGrid
end

---Execute individual script step
---@param step table Step definition
---@param blockGrid table Current block grid
---@param context table Generation context
---@param availableBlocks table Available blocks
---@param placedBlocks table Already placed blocks
---@return boolean success
function MapGenerator:executeScriptStep(step, blockGrid, context, availableBlocks, placedBlocks)
    if step.type == "place_anchored" then
        return self:placeAnchoredBlock(step, blockGrid, context, availableBlocks, placedBlocks)
    elseif step.type == "place_linear" then
        return self:placeLinearFeature(step, blockGrid, context, availableBlocks, placedBlocks)
    elseif step.type == "place_group" then
        return self:placeSpawnGroup(step, blockGrid, context, availableBlocks, placedBlocks)
    end

    return true -- Unknown step types are ignored
end

---Place anchored block at specific location
---@param step table Step parameters
---@param blockGrid table Block grid
---@param context table Context
---@param availableBlocks table Available blocks
---@param placedBlocks table Placed blocks
---@return boolean success
function MapGenerator:placeAnchoredBlock(step, blockGrid, context, availableBlocks, placedBlocks)
    local block = self:selectBlockByTag(step.tag, availableBlocks)
    if not block then return false end

    local x, y = step.x, step.y
    if self:canPlaceBlock(blockGrid, block, x, y, context.mapSize) then
        self:placeBlock(blockGrid, block, x, y, placedBlocks)
        return true
    end

    return false
end

---Select block by tag from available blocks
---@param tag string Block tag
---@param availableBlocks table Available blocks
---@return table|nil block Selected block or nil
function MapGenerator:selectBlockByTag(tag, availableBlocks)
    local candidates = {}

    for _, block in ipairs(availableBlocks) do
        if block.tags and block.tags[tag] then
            table.insert(candidates, block)
        end
    end

    if #candidates == 0 then return nil end

    -- Weighted random selection
    local totalWeight = 0
    for _, block in ipairs(candidates) do
        totalWeight = totalWeight + (block.weight or 1)
    end

    local roll = math.random() * totalWeight
    local currentWeight = 0

    for _, block in ipairs(candidates) do
        currentWeight = currentWeight + (block.weight or 1)
        if roll <= currentWeight then
            return block
        end
    end

    return candidates[1] -- Fallback
end

---Check if block can be placed at location
---@param blockGrid table Block grid
---@param block table Block to place
---@param x number X position
---@param y number Y position
---@param mapSize table Map size
---@return boolean canPlace
function MapGenerator:canPlaceBlock(blockGrid, block, x, y, mapSize)
    local width = block.size.width
    local height = block.size.height

    -- Check bounds
    if x + width - 1 > mapSize.width or y + height - 1 > mapSize.height then
        return false
    end

    -- Check if area is clear
    for bx = 0, width - 1 do
        for by = 0, height - 1 do
            if blockGrid[x + bx][y + by] then
                return false
            end
        end
    end

    return true
end

---Place block in grid
---@param blockGrid table Block grid
---@param block table Block to place
---@param x number X position
---@param y number Y position
---@param placedBlocks table Placed blocks tracking
function MapGenerator:placeBlock(blockGrid, block, x, y, placedBlocks)
    local width = block.size.width
    local height = block.size.height

    for bx = 0, width - 1 do
        for by = 0, height - 1 do
            blockGrid[x + bx][y + by] = {
                blockId = block.id,
                localX = bx,
                localY = by,
                globalX = x + bx - 1,
                globalY = y + by - 1
            }
        end
    end

    table.insert(placedBlocks, {
        block = block,
        x = x,
        y = y
    })
end

---Fill remaining empty slots with random blocks
---@param blockGrid table Block grid
---@param context table Context
---@param availableBlocks table Available blocks
---@param placedBlocks table Placed blocks
function MapGenerator:fillRemainingSlots(blockGrid, context, availableBlocks, placedBlocks)
    for x = 1, context.mapSize.width do
        for y = 1, context.mapSize.height do
            if not blockGrid[x][y] then
                -- Select random block that fits
                local candidates = {}
                for _, block in ipairs(availableBlocks) do
                    if self:canPlaceBlock(blockGrid, block, x, y, context.mapSize) then
                        table.insert(candidates, block)
                    end
                end

                if #candidates > 0 then
                    local block = candidates[math.random(#candidates)]
                    self:placeBlock(blockGrid, block, x, y, placedBlocks)
                end
            end
        end
    end
end

---Expand block grid to tile grid using terrain tiles
---@param blockGrid table Block grid with character-based tile data
---@param context table Context including RNG
---@return table tileMap Tile map with battle tiles
function MapGenerator:expandBlocksToTiles(blockGrid, context)
    local tileMap = {}
    local tilesPerBlock = 15 -- 15x15 tiles per block

    -- Create a cache of terrain tiles for each character
    local terrainTileCache = {}

    for bx = 1, context.mapSize.width do
        for by = 1, context.mapSize.height do
            local blockData = blockGrid[bx][by]
            if blockData and blockData.tiles then
                -- Process each tile in the block
                for lx = 0, tilesPerBlock - 1 do
                    for ly = 0, tilesPerBlock - 1 do
                        local tileChar = blockData.tiles[lx + 1][ly + 1] -- 1-based indexing
                        if tileChar then
                            -- Get or create terrain tile for this character
                            local terrainTile = terrainTileCache[tileChar]
                            if not terrainTile then
                                terrainTile = self:createTerrainTile(tileChar)
                                terrainTileCache[tileChar] = terrainTile
                            end

                            -- Convert terrain tile to battle tile
                            local globalX = (bx - 1) * tilesPerBlock + lx
                            local globalY = (by - 1) * tilesPerBlock + ly

                            if not tileMap[globalX] then tileMap[globalX] = {} end
                            tileMap[globalX][globalY] = self:createBattleTile(terrainTile, context.rng)

                            tileMap[globalX][globalY] = mapNode:toBattleTile(context.rng)

                            -- Add provenance metadata
                            tileMap[globalX][globalY].blockId = blockData.blockId
                            tileMap[globalX][globalY].localX = lx
                            tileMap[globalX][globalY].localY = ly
                            tileMap[globalX][globalY].globalX = globalX
                            tileMap[globalX][globalY].globalY = globalY
                        end
                    end
                end
            end
        end
    end

    return tileMap
end

---Configure a MapNode based on its character
---@param mapNode table MapNode instance
---@param character string Character representing the tile type
function MapGenerator:configureMapNode(mapNode, character)
    -- Basic configuration based on character
    -- This should eventually be loaded from TOML configuration files

    if character == '.' then
        -- Floor/ground
        mapNode:setProperties({
            cover = 0,
            blocking = false,
            destructible = false,
            flammable = false,
            material = "ground",
            type = "floor"
        })
        mapNode:addGraphic("terrain", "00", 3) -- Common ground
        mapNode:addGraphic("terrain", "01", 1) -- Variant ground

    elseif character == '#' then
        -- Wall
        mapNode:setProperties({
            cover = 4,
            blocking = true,
            destructible = true,
            flammable = false,
            material = "concrete",
            type = "wall"
        })
        mapNode:addGraphic("structures", "10", 2) -- Wall
        mapNode:addGraphic("structures", "11", 1) -- Wall variant

    elseif character == 'T' then
        -- Tree
        mapNode:setProperties({
            cover = 3,
            blocking = true,
            destructible = true,
            flammable = true,
            material = "wood",
            type = "object"
        })
        mapNode:addGraphic("nature", "20", 2) -- Tree
        mapNode:addGraphic("nature", "21", 1) -- Tree variant

    elseif character == '+' then
        -- Door
        mapNode:setProperties({
            cover = 2,
            blocking = false, -- Doors start open
            destructible = true,
            flammable = false,
            material = "wood",
            type = "object"
        })
        mapNode:addGraphic("structures", "30", 1) -- Door

    else
        -- Default/fallback
        mapNode:setProperties({
            cover = 0,
            blocking = false,
            destructible = false,
            flammable = false,
            material = "ground",
            type = "floor"
        })
        mapNode:addGraphic("terrain", "00", 1)
    end
end

---Get block by ID
---@param blockId string Block ID
---@return table|nil block Block data
function MapGenerator:getBlockById(blockId)
    for _, block in ipairs(self._blockPool) do
        if block.id == blockId then
            return block
        end
    end
    return nil
end

---Preprocess AI navigation data
---@param tileMap table Tile map
---@param context table Context
---@return table aiData AI navigation data
function MapGenerator:preprocessAIAndNavigation(tileMap, context)
    -- This would create node graphs, connectivity data, etc.
    -- Simplified implementation
    return {
        nodes = {},
        connections = {},
        spawnPoints = {},
        coverPositions = {}
    }
end

---Place spawns and factions
---@param tileMap table Tile map
---@param context table Context
---@param aiData table AI data
---@return table spawnData Spawn placement data
function MapGenerator:placeSpawnsAndFactions(tileMap, context, aiData)
    -- Simplified spawn placement
    return {
        enemySpawns = {},
        allySpawns = {},
        civilianSpawns = {}
    }
end

---Create deployment zones
---@param tileMap table Tile map
---@param context table Context
---@return table deploymentZones Player deployment options
function MapGenerator:createDeploymentZones(tileMap, context)
    -- Simplified deployment zones
    return {
        zones = {}
    }
end

---Initialize Fog of War
---@param tileMap table Tile map
---@param spawnData table Spawn data
---@param context table Context
---@return table fogOfWar Initial fog state
function MapGenerator:initializeFogOfWar(tileMap, spawnData, context)
    -- Simplified fog of war initialization
    return {
        explored = {},
        visible = {}
    }
end

---Apply pre-battle effects
---@param tileMap table Tile map
---@param context table Context
function MapGenerator:applyPreBattleEffects(tileMap, context)
    -- Apply mission-specific damage, effects, etc.
    -- Implementation depends on mission flags
end

---Validate generated map
---@param tileMap table Tile map
---@param spawnData table Spawn data
---@param deploymentZones table Deployment zones
---@return boolean isValid
function MapGenerator:validateMap(tileMap, spawnData, deploymentZones)
    -- Check reachability, spawn validity, etc.
    return true -- Simplified
end

---Place linear feature (roads, rivers, etc.)
---@param step table Step parameters
---@param blockGrid table Block grid
---@param context table Context
---@param availableBlocks table Available blocks
---@param placedBlocks table Placed blocks
---@return boolean success
function MapGenerator:placeLinearFeature(step, blockGrid, context, availableBlocks, placedBlocks)
    -- Simplified linear placement - would implement pathfinding for features
    return true
end

---Place spawn group
---@param step table Step parameters
---@param blockGrid table Block grid
---@param context table Context
---@param availableBlocks table Available blocks
---@param placedBlocks table Placed blocks
---@return boolean success
function MapGenerator:placeSpawnGroup(step, blockGrid, context, availableBlocks, placedBlocks)
    -- Simplified spawn group placement
    return true
end

---Create a terrain tile based on character
---@param character string Character representing the tile type
---@return table terrainTile Terrain tile data
function MapGenerator:createTerrainTile(character)
    -- Basic terrain tile configuration based on character
    local tile = {
        character = character,
        properties = {},
        graphics = {}
    }

    if character == '.' then
        -- Floor/ground
        tile.properties = {
            cover = 0,
            blocking = false,
            destructible = false,
            flammable = false,
            material = "ground",
            type = "floor"
        }
        tile.graphics = {
            {tilesetKey = "terrain", positionKey = "00", weight = 3}, -- Common ground
            {tilesetKey = "terrain", positionKey = "01", weight = 1}  -- Variant ground
        }

    elseif character == '#' then
        -- Wall
        tile.properties = {
            cover = 4,
            blocking = true,
            destructible = true,
            flammable = false,
            material = "concrete",
            type = "wall"
        }
        tile.graphics = {
            {tilesetKey = "structures", positionKey = "10", weight = 2}, -- Wall
            {tilesetKey = "structures", positionKey = "11", weight = 1}  -- Wall variant
        }

    elseif character == 'T' then
        -- Tree
        tile.properties = {
            cover = 3,
            blocking = true,
            destructible = true,
            flammable = true,
            material = "wood",
            type = "object"
        }
        tile.graphics = {
            {tilesetKey = "nature", positionKey = "20", weight = 1} -- Tree
        }

    else
        -- Default/unknown
        tile.properties = {
            cover = 0,
            blocking = false,
            destructible = false,
            flammable = false,
            material = "ground",
            type = "floor"
        }
        tile.graphics = {
            {tilesetKey = "terrain", positionKey = "00", weight = 1}
        }
    end

    return tile
end

---Create a battle tile from terrain tile
---@param terrainTile table Terrain tile data
---@param rng table Random number generator
---@return table battleTile Battle tile with terrain + additional elements
function MapGenerator:createBattleTile(terrainTile, rng)
    -- Select random graphic based on weights
    local selectedGraphic = self:selectRandomGraphic(terrainTile.graphics, rng)

    -- Create battle tile data
    local battleTile = {
        -- Terrain properties
        cover = terrainTile.properties.cover or 0,
        blocking = terrainTile.properties.blocking or false,
        destructible = terrainTile.properties.destructible or false,
        flammable = terrainTile.properties.flammable or false,
        material = terrainTile.properties.material or "ground",

        -- Graphic information
        graphic = selectedGraphic,

        -- Additional battle elements
        unit = nil,        -- Unit occupying this tile
        objects = {},      -- Objects on this tile
        smoke_fire = nil,  -- Smoke or fire effect
        fog_of_war = true, -- Initially hidden

        -- Metadata
        terrainChar = terrainTile.character,
        terrainType = terrainTile.properties.type or "floor"
    }

    return battleTile
end

---Select a random graphic based on weights
---@param graphics table Array of graphic options
---@param rng table Random number generator
---@return table Selected graphic data
function MapGenerator:selectRandomGraphic(graphics, rng)
    if #graphics == 0 then
        return {tilesetKey = "default", positionKey = "00", weight = 1}
    end

    -- Calculate total weight
    local totalWeight = 0
    for _, graphic in ipairs(graphics) do
        totalWeight = totalWeight + graphic.weight
    end

    -- Select random value
    local randomValue = rng:random() * totalWeight

    -- Find selected graphic
    local currentWeight = 0
    for _, graphic in ipairs(graphics) do
        currentWeight = currentWeight + graphic.weight
        if randomValue <= currentWeight then
            return {
                tilesetKey = graphic.tilesetKey,
                positionKey = graphic.positionKey,
                weight = graphic.weight
            }
        end
    end

    -- Fallback to first graphic
    return graphics[1]
end

return MapGenerator
