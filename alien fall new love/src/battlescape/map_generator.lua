--- Map Generator for Battlescape
-- Procedural map generation from map blocks and scripts
-- Generates tactical maps with spawn points and objectives
--
-- @module battlescape.map_generator

local MapGenerator = {}

--- Generate a complete tactical map
-- @param mapScript table: Map generation script {blocks, size, theme}
-- @param missionType string: Type of mission
-- @param difficulty number: Difficulty rating (1-5)
-- @return table: Generated map data
function MapGenerator.generateMap(mapScript, missionType, difficulty)
    mapScript = mapScript or {}
    missionType = missionType or "standard"
    difficulty = difficulty or 2
    
    -- Default map size
    local width = mapScript.width or 50
    local height = mapScript.height or 50
    
    -- Initialize map structure
    local map = {
        width = width,
        height = height,
        tiles = {},
        spawn_points = {player = {}, enemy = {}, civilian = {}},
        objectives = {},
        theme = mapScript.theme or "urban",
        missionType = missionType
    }
    
    -- Initialize tiles
    for x = 1, width do
        map.tiles[x] = {}
        for y = 1, height do
            map.tiles[x][y] = {
                type = "floor",
                cover = 0,
                height = 0,
                passable = true,
                los_blocking = false
            }
        end
    end
    
    -- Place blocks if provided
    if mapScript.blocks then
        MapGenerator.placeBlocks(map, mapScript.blocks)
    else
        -- Generate random map
        MapGenerator.generateRandomMap(map)
    end
    
    -- Generate spawn points
    MapGenerator.generateSpawnPoints(map, "player", 8)
    MapGenerator.generateSpawnPoints(map, "enemy", math.floor(10 + difficulty * 2))
    
    -- Place objectives
    MapGenerator.placeObjectives(map, missionType)
    
    -- Validate map
    if not MapGenerator.validateMap(map) then
        print("Warning: Generated map failed validation")
    end
    
    return map
end

--- Place blocks on map according to script
-- @param map table: Map data
-- @param blocks table: Block placement data
function MapGenerator.placeBlocks(map, blocks)
    for _, blockData in ipairs(blocks) do
        local block = blockData.block
        local x = blockData.x or 0
        local y = blockData.y or 0
        local rotation = blockData.rotation or 0
        
        MapGenerator.placeBlock(map, block, x, y, rotation)
    end
end

--- Place a single block on the map
-- @param map table: Map data
-- @param block table: Block data
-- @param startX number: Block X position
-- @param startY number: Block Y position
-- @param rotation number: Rotation (0, 90, 180, 270)
function MapGenerator.placeBlock(map, block, startX, startY, rotation)
    if not block or not block.tiles then return end
    
    local blockSize = block.size or 10
    
    for bx = 1, blockSize do
        for by = 1, blockSize do
            local rotatedX, rotatedY = MapGenerator.rotateCoords(bx, by, blockSize, rotation)
            local mapX = startX + rotatedX
            local mapY = startY + rotatedY
            
            if mapX >= 1 and mapX <= map.width and mapY >= 1 and mapY <= map.height then
                local tile = block.tiles[bx][by]
                if tile then
                    map.tiles[mapX][mapY] = MapGenerator.copyTile(tile)
                end
            end
        end
    end
end

--- Rotate block coordinates
-- @param x number: X coordinate
-- @param y number: Y coordinate
-- @param size number: Block size
-- @param rotation number: Rotation angle (0, 90, 180, 270)
-- @return number, number: Rotated coordinates
function MapGenerator.rotateCoords(x, y, size, rotation)
    if rotation == 90 then
        return y, size - x + 1
    elseif rotation == 180 then
        return size - x + 1, size - y + 1
    elseif rotation == 270 then
        return size - y + 1, x
    else
        return x, y
    end
end

--- Copy tile data
-- @param tile table: Source tile
-- @return table: Copied tile
function MapGenerator.copyTile(tile)
    local copy = {}
    for k, v in pairs(tile) do
        copy[k] = v
    end
    return copy
end

--- Generate random map (fallback)
-- @param map table: Map data
function MapGenerator.generateRandomMap(map)
    -- Place random walls for cover
    for i = 1, math.floor(map.width * map.height * 0.1) do
        local x = math.random(1, map.width)
        local y = math.random(1, map.height)
        
        if map.tiles[x] and map.tiles[x][y] then
            map.tiles[x][y].type = "wall"
            map.tiles[x][y].cover = 80
            map.tiles[x][y].passable = false
            map.tiles[x][y].los_blocking = true
        end
    end
    
    -- Place some low cover
    for i = 1, math.floor(map.width * map.height * 0.15) do
        local x = math.random(1, map.width)
        local y = math.random(1, map.height)
        
        if map.tiles[x] and map.tiles[x][y] and map.tiles[x][y].passable then
            map.tiles[x][y].cover = 40
        end
    end
end

--- Generate spawn points for faction
-- @param map table: Map data
-- @param faction string: Faction name
-- @param count number: Number of spawn points
function MapGenerator.generateSpawnPoints(map, faction, count)
    local spawnZone = MapGenerator.getSpawnZone(map, faction)
    local attempts = 0
    local maxAttempts = count * 10
    
    while #map.spawn_points[faction] < count and attempts < maxAttempts do
        attempts = attempts + 1
        
        local x = math.random(spawnZone.minX, spawnZone.maxX)
        local y = math.random(spawnZone.minY, spawnZone.maxY)
        
        if MapGenerator.isValidSpawnPoint(map, x, y) then
            table.insert(map.spawn_points[faction], {x = x, y = y})
        end
    end
end

--- Get spawn zone for faction
-- @param map table: Map data
-- @param faction string: Faction name
-- @return table: {minX, minY, maxX, maxY}
function MapGenerator.getSpawnZone(map, faction)
    if faction == "player" then
        -- Player spawns in bottom quarter
        return {
            minX = 1,
            minY = math.floor(map.height * 0.75),
            maxX = map.width,
            maxY = map.height
        }
    elseif faction == "enemy" then
        -- Enemy spawns in top half
        return {
            minX = 1,
            minY = 1,
            maxX = map.width,
            maxY = math.floor(map.height * 0.5)
        }
    else
        -- Civilians spawn in middle
        return {
            minX = math.floor(map.width * 0.25),
            minY = math.floor(map.height * 0.25),
            maxX = math.floor(map.width * 0.75),
            maxY = math.floor(map.height * 0.75)
        }
    end
end

--- Check if location is valid for spawn point
-- @param map table: Map data
-- @param x number: X coordinate
-- @param y number: Y coordinate
-- @return boolean: True if valid
function MapGenerator.isValidSpawnPoint(map, x, y)
    if not map.tiles[x] or not map.tiles[x][y] then
        return false
    end
    
    local tile = map.tiles[x][y]
    if not tile.passable then
        return false
    end
    
    -- Check for nearby spawn points (min 3 tiles apart)
    for _, spawnList in pairs(map.spawn_points) do
        for _, spawn in ipairs(spawnList) do
            local dist = math.sqrt((x - spawn.x)^2 + (y - spawn.y)^2)
            if dist < 3 then
                return false
            end
        end
    end
    
    return true
end

--- Place mission objectives
-- @param map table: Map data
-- @param missionType string: Mission type
function MapGenerator.placeObjectives(map, missionType)
    if missionType == "elimination" then
        -- No special objectives, just kill all enemies
        map.objectives = {{type = "eliminate_all", description = "Eliminate all hostiles"}}
        
    elseif missionType == "extraction" then
        -- Place extraction point
        local x = math.random(math.floor(map.width * 0.3), math.floor(map.width * 0.7))
        local y = math.random(1, math.floor(map.height * 0.3))
        table.insert(map.objectives, {
            type = "extraction",
            position = {x = x, y = y},
            description = "Reach extraction zone"
        })
        
    elseif missionType == "terror" then
        -- Civilians to save
        map.objectives = {{type = "save_civilians", minimum = 5, description = "Save at least 5 civilians"}}
        
    elseif missionType == "ufo_crash" then
        -- Secure UFO power core
        local x = math.floor(map.width / 2)
        local y = math.floor(map.height / 4)
        table.insert(map.objectives, {
            type = "secure_item",
            position = {x = x, y = y},
            item = "ufo_core",
            description = "Secure UFO power core"
        })
    else
        -- Default objective
        map.objectives = {{type = "eliminate_all", description = "Complete mission objectives"}}
    end
end

--- Validate map structure
-- @param map table: Map data
-- @return boolean: True if valid
function MapGenerator.validateMap(map)
    -- Check basic structure
    if not map.tiles or not map.spawn_points then
        return false
    end
    
    -- Check spawn points exist
    if #map.spawn_points.player == 0 then
        print("Error: No player spawn points")
        return false
    end
    
    if #map.spawn_points.enemy == 0 then
        print("Error: No enemy spawn points")
        return false
    end
    
    -- Check map dimensions
    if map.width < 20 or map.height < 20 then
        print("Error: Map too small")
        return false
    end
    
    return true
end

--- Get tile at position
-- @param map table: Map data
-- @param x number: X coordinate
-- @param y number: Y coordinate
-- @return table: Tile data or nil
function MapGenerator.getTile(map, x, y)
    if map.tiles[x] then
        return map.tiles[x][y]
    end
    return nil
end

--- Check if position is passable
-- @param map table: Map data
-- @param x number: X coordinate
-- @param y number: Y coordinate
-- @return boolean: True if passable
function MapGenerator.isPassable(map, x, y)
    local tile = MapGenerator.getTile(map, x, y)
    return tile and tile.passable
end

return MapGenerator
