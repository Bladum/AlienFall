--- Map Generator
-- Generates procedural maps for missions with terrain, cover, and objectives
--
-- @module procedure.MapGenerator

local class = require 'lib.Middleclass'

--- Map Generator
-- @type MapGenerator
MapGenerator = class('MapGenerator')

--- Terrain types
MapGenerator.TERRAIN_TYPES = {
    'grass', 'dirt', 'concrete', 'metal', 'water', 'rock', 'sand', 'ice'
}

--- Terrain colors for PNG export/import (RGB 0-1)
MapGenerator.TERRAIN_COLORS = {
    grass = {0, 1, 0},        -- Green
    dirt = {0.6, 0.3, 0},     -- Brown
    concrete = {0.5, 0.5, 0.5}, -- Gray
    metal = {0.8, 0.8, 0.8}, -- Silver
    water = {0, 0, 1},        -- Blue
    rock = {0.2, 0.2, 0.2},   -- Dark gray
    sand = {1, 1, 0},         -- Yellow
    ice = {0.5, 0.5, 1}       -- Light blue
}

--- Cover types
MapGenerator.COVER_TYPES = {
    'none', 'low', 'high', 'full'
}

--- Initialize map generator
-- @param rng Random number generator
function MapGenerator:initialize(rng)
    self.rng = rng
end

--- Generate a procedural map
-- @param mapType Type of map ('urban', 'forest', 'desert', etc.)
-- @param size Size table with width and height
-- @return Generated map data
function MapGenerator:generate(mapType, size)
    local map = {
        type = mapType,
        width = size.width,
        height = size.height,
        tiles = {},
        objectives = {},
        spawnPoints = {},
        coverMap = {},
        heightMap = {}
    }

    -- Generate base terrain
    self:generateTerrain(map, mapType)

    -- Generate height map for 3D-like terrain
    self:generateHeightMap(map)

    -- Generate cover objects
    self:generateCover(map, mapType)

    -- Place objectives
    self:placeObjectives(map, mapType)

    -- Generate spawn points
    self:generateSpawnPoints(map)

    -- Add special features based on map type
    self:addSpecialFeatures(map, mapType)

    return map
end

--- Generate base terrain for the map
-- @param map Map data table
-- @param mapType Type of map
function MapGenerator:generateTerrain(map, mapType)
    -- Define terrain probabilities based on map type
    local terrainWeights = self:getTerrainWeights(mapType)

    for x = 1, map.width do
        map.tiles[x] = {}
        for y = 1, map.height do
            local terrain = self:selectWeightedTerrain(terrainWeights)
            map.tiles[x][y] = {
                terrain = terrain,
                walkable = self:isTerrainWalkable(terrain),
                blocksSight = self:doesTerrainBlockSight(terrain)
            }
        end
    end

    -- Apply some noise/smoothing for more natural terrain
    self:smoothTerrain(map, 2)
end

--- Get terrain weights for map type
-- @param mapType Type of map
-- @return Terrain weights table
function MapGenerator:getTerrainWeights(mapType)
    local weights = {
        urban = {
            concrete = 60,
            metal = 10,
            dirt = 20,
            grass = 10
        },
        forest = {
            grass = 40,
            dirt = 30,
            rock = 20,
            water = 10
        },
        desert = {
            sand = 70,
            rock = 25,
            dirt = 5
        },
        research = {
            metal = 40,
            concrete = 30,
            dirt = 20,
            water = 10
        },
        military = {
            concrete = 50,
            dirt = 30,
            metal = 15,
            grass = 5
        },
        underground = {
            rock = 60,
            metal = 20,
            concrete = 15,
            dirt = 5
        }
    }

    return weights[mapType] or weights.urban
end

--- Select terrain based on weights
-- @param weights Terrain weights table
-- @return Selected terrain type
function MapGenerator:selectWeightedTerrain(weights)
    local total = 0
    for _, weight in pairs(weights) do
        total = total + weight
    end

    local roll = self.rng:random(1, total)
    local current = 0

    for terrain, weight in pairs(weights) do
        current = current + weight
        if roll <= current then
            return terrain
        end
    end

    return 'grass' -- fallback
end

--- Check if terrain is walkable
-- @param terrain Terrain type
-- @return Boolean indicating if walkable
function MapGenerator:isTerrainWalkable(terrain)
    local nonWalkable = { 'water', 'lava', 'void' }
    for _, t in ipairs(nonWalkable) do
        if terrain == t then
            return false
        end
    end
    return true
end

--- Check if terrain blocks line of sight
-- @param terrain Terrain type
-- @return Boolean indicating if blocks sight
function MapGenerator:doesTerrainBlockSight(terrain)
    local blocking = { 'rock', 'metal', 'concrete' }
    for _, t in ipairs(blocking) do
        if terrain == t then
            return true
        end
    end
    return false
end

--- Smooth terrain to reduce noise
-- @param map Map data
-- @param iterations Number of smoothing iterations
function MapGenerator:smoothTerrain(map, iterations)
    for _ = 1, iterations do
        for x = 2, map.width - 1 do
            for y = 2, map.height - 1 do
                local neighbors = {}
                for dx = -1, 1 do
                    for dy = -1, 1 do
                        if not (dx == 0 and dy == 0) then
                            local nx, ny = x + dx, y + dy
                            if nx >= 1 and nx <= map.width and ny >= 1 and ny <= map.height then
                                table.insert(neighbors, map.tiles[nx][ny].terrain)
                            end
                        end
                    end
                end

                -- If most neighbors are the same, change to match them
                local current = map.tiles[x][y].terrain
                local counts = {}
                for _, terrain in ipairs(neighbors) do
                    counts[terrain] = (counts[terrain] or 0) + 1
                end

                local maxCount = 0
                local mostCommon = current
                for terrain, count in pairs(counts) do
                    if count > maxCount then
                        maxCount = count
                        mostCommon = terrain
                    end
                end

                if maxCount >= 5 then -- If 5+ neighbors agree
                    map.tiles[x][y].terrain = mostCommon
                end
            end
        end
    end
end

--- Generate height map for terrain elevation
-- @param map Map data
function MapGenerator:generateHeightMap(map)
    -- Simple noise-based height generation
    for x = 1, map.width do
        map.heightMap[x] = {}
        for y = 1, map.height do
            -- Base height with some noise
            local height = 0

            -- Large scale variation
            height = height + math.sin(x * 0.1) * 2
            height = height + math.cos(y * 0.1) * 2

            -- Medium scale noise
            height = height + self.rng:random(-1, 1)

            -- Small scale noise
            height = height + self.rng:random() * 0.5

            map.heightMap[x][y] = math.floor(height + 0.5)
        end
    end
end

--- Generate cover objects on the map
-- @param map Map data
-- @param mapType Type of map
function MapGenerator:generateCover(map, mapType)
    local coverDensity = self:getCoverDensity(mapType)

    for x = 1, map.width do
        map.coverMap[x] = {}
        for y = 1, map.height do
            if self.rng:random() < coverDensity and map.tiles[x][y].walkable then
                map.coverMap[x][y] = self:generateCoverObject(mapType)
            else
                map.coverMap[x][y] = 'none'
            end
        end
    end
end

--- Get cover density for map type
-- @param mapType Type of map
-- @return Cover density (0-1)
function MapGenerator:getCoverDensity(mapType)
    local densities = {
        urban = 0.4,
        forest = 0.6,
        desert = 0.2,
        research = 0.3,
        military = 0.25,
        underground = 0.35
    }

    return densities[mapType] or 0.3
end

--- Generate a cover object
-- @param mapType Type of map
-- @return Cover type
function MapGenerator:generateCoverObject(mapType)
    local coverOptions = {
        urban = { 'low', 'low', 'high', 'full' },
        forest = { 'low', 'high', 'high', 'full' },
        desert = { 'low', 'low', 'low', 'high' },
        research = { 'low', 'high', 'full', 'full' },
        military = { 'low', 'high', 'full', 'none' },
        underground = { 'low', 'high', 'full', 'none' }
    }

    local options = coverOptions[mapType] or { 'low', 'high' }
    return options[self.rng:random(#options)]
end

--- Place mission objectives on the map
-- @param map Map data
-- @param mapType Type of map
function MapGenerator:placeObjectives(map, mapType)
    -- Place primary extraction point
    local extractX = self.rng:random(2, map.width - 1)
    local extractY = self.rng:random(2, map.height - 1)

    table.insert(map.objectives, {
        type = 'extraction',
        x = extractX,
        y = extractY,
        name = 'Extraction Point'
    })

    -- Place secondary objectives
    local numSecondary = self.rng:random(1, 3)
    for i = 1, numSecondary do
        local objX, objY
        repeat
            objX = self.rng:random(2, map.width - 1)
            objY = self.rng:random(2, map.height - 1)
        until math.abs(objX - extractX) > 5 or math.abs(objY - extractY) > 5

        local objTypes = { 'data_terminal', 'enemy_cache', 'civilian', 'artifact' }
        table.insert(map.objectives, {
            type = objTypes[self.rng:random(#objTypes)],
            x = objX,
            y = objY,
            name = 'Objective ' .. i
        })
    end
end

--- Generate spawn points for units
-- @param map Map data
function MapGenerator:generateSpawnPoints(map)
    -- Player spawn near one edge
    local playerSpawn = {
        x = self.rng:random(2, 5),
        y = self.rng:random(2, map.height - 1),
        faction = 'player'
    }

    -- Enemy spawns distributed around map
    local enemySpawns = {}
    local numEnemySpawns = self.rng:random(3, 6)

    for i = 1, numEnemySpawns do
        local spawn = {
            x = self.rng:random(map.width - 5, map.width - 2),
            y = self.rng:random(2, map.height - 1),
            faction = 'enemy'
        }
        table.insert(enemySpawns, spawn)
    end

    map.spawnPoints = {
        player = { playerSpawn },
        enemy = enemySpawns
    }
end

--- Add special features based on map type
-- @param map Map data
-- @param mapType Type of map
function MapGenerator:addSpecialFeatures(map, mapType)
    if mapType == 'urban' then
        self:addBuildings(map)
    elseif mapType == 'forest' then
        self:addTrees(map)
    elseif mapType == 'research' then
        self:addResearchFeatures(map)
    elseif mapType == 'underground' then
        self:addUndergroundFeatures(map)
    end
end

--- Add buildings to urban maps
-- @param map Map data
function MapGenerator:addBuildings(map)
    local numBuildings = self.rng:random(3, 8)

    for i = 1, numBuildings do
        local width = self.rng:random(3, 6)
        local height = self.rng:random(3, 6)
        local x = self.rng:random(1, map.width - width)
        local y = self.rng:random(1, map.height - height)

        -- Mark building area
        for bx = x, x + width - 1 do
            for by = y, y + height - 1 do
                if bx >= 1 and bx <= map.width and by >= 1 and by <= map.height then
                    map.tiles[bx][by].building = true
                    map.coverMap[bx][by] = 'full'
                end
            end
        end
    end
end

--- Add trees to forest maps
-- @param map Map data
function MapGenerator:addTrees(map)
    local numTrees = self.rng:random(10, 20)

    for i = 1, numTrees do
        local x = self.rng:random(1, map.width)
        local y = self.rng:random(1, map.height)

        if map.tiles[x][y].walkable then
            map.tiles[x][y].decoration = 'tree'
            map.coverMap[x][y] = 'high'
        end
    end
end

--- Add research features to research maps
-- @param map Map data
function MapGenerator:addResearchFeatures(map)
    -- Add some research terminals
    local numTerminals = self.rng:random(2, 4)

    for i = 1, numTerminals do
        local x = self.rng:random(2, map.width - 1)
        local y = self.rng:random(2, map.height - 1)

        map.tiles[x][y].decoration = 'research_terminal'
        table.insert(map.objectives, {
            type = 'research_terminal',
            x = x,
            y = y,
            name = 'Research Terminal ' .. i
        })
    end
end

--- Add underground features
-- @param map Map data
function MapGenerator:addUndergroundFeatures(map)
    -- Add some cave-ins or structural damage
    local numFeatures = self.rng:random(2, 5)

    for i = 1, numFeatures do
        local x = self.rng:random(2, map.width - 1)
        local y = self.rng:random(2, map.height - 1)

        if self.rng:random() < 0.5 then
            map.tiles[x][y].decoration = 'cave_in'
            map.tiles[x][y].walkable = false
        else
            map.tiles[x][y].decoration = 'structural_damage'
            map.coverMap[x][y] = 'low'
        end
    end
end

--- Save map to PNG file with RGB color coding
-- @param map Map data table
-- @param filename PNG filename
-- @return success boolean
function MapGenerator:saveMapToPNG(map, filename)
    print("Saving map to PNG: " .. filename)
    
    -- Create canvas
    local canvas = love.graphics.newCanvas(map.width, map.height)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1) -- Black background for unknown
    
    -- Draw each tile with its terrain color
    for x = 1, map.width do
        for y = 1, map.height do
            local tile = map.tiles[x][y]
            local color = self.TERRAIN_COLORS[tile.terrain] or {0, 0, 0}
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", x-1, y-1, 1, 1)
        end
    end
    
    love.graphics.setCanvas() -- Reset
    
    -- Save to PNG
    local imageData = canvas:newImageData()
    local success = imageData:encode("png", filename)
    
    if success then
        print("Map saved successfully to: " .. filename)
        print("Color coding:")
        for terrain, color in pairs(self.TERRAIN_COLORS) do
            print(string.format("  %s: RGB(%.1f, %.1f, %.1f)", terrain, color[1], color[2], color[3]))
        end
    else
        print("Error: Failed to save PNG")
    end
    
    return success
end

--- Load map from PNG file, interpreting RGB colors as terrain
-- @param filename PNG filename
-- @param mapType Map type for generation context
-- @return map table or nil on error
function MapGenerator:loadMapFromPNG(filename, mapType)
    print("Loading map from PNG: " .. filename)
    
    -- Load image
    local imageData = love.image.newImageData(filename)
    local width = imageData:getWidth()
    local height = imageData:getHeight()
    
    -- Create map structure
    local map = {
        type = mapType or 'custom',
        width = width,
        height = height,
        tiles = {},
        objectives = {},
        spawnPoints = {},
        coverMap = {},
        heightMap = {}
    }
    
    -- Initialize tiles
    for x = 1, width do
        map.tiles[x] = {}
        map.coverMap[x] = {}
        map.heightMap[x] = {}
        for y = 1, height do
            local r, g, b = imageData:getPixel(x-1, y-1)
            r, g, b = r/255, g/255, b/255
            
            -- Find closest terrain match
            local terrain = self:getTerrainFromColor(r, g, b)
            
            map.tiles[x][y] = {
                terrain = terrain,
                walkable = self:isTerrainWalkable(terrain),
                blocksSight = self:doesTerrainBlockSight(terrain)
            }
            map.coverMap[x][y] = 'none'
            map.heightMap[x][y] = 0
        end
    end
    
    -- Generate spawn points and objectives (basic)
    self:generateSpawnPoints(map)
    self:placeObjectives(map, mapType or 'urban')
    
    print("Map loaded successfully from: " .. filename)
    return map
end

--- Get terrain type from RGB color (find closest match)
-- @param r Red (0-1)
-- @param g Green (0-1)
-- @param b Blue (0-1)
-- @return terrain string
function MapGenerator:getTerrainFromColor(r, g, b)
    local closestTerrain = 'grass'
    local closestDist = math.huge
    
    for terrain, color in pairs(self.TERRAIN_COLORS) do
        local dr = r - color[1]
        local dg = g - color[2]
        local db = b - color[3]
        local dist = dr*dr + dg*dg + db*db
        
        if dist < closestDist then
            closestDist = dist
            closestTerrain = terrain
        end
    end
    
    return closestTerrain
end

return MapGenerator