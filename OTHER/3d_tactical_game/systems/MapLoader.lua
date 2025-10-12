--- MapLoader System
--- Loads maps from PNG files and converts them to Tile grids

local Tile = require("classes.Tile")
local Constants = require("config.constants")
local Colors = require("config.colors")

--- @class MapLoader
local MapLoader = {}

--- Load a map from a PNG file
--- @param filename string Path to the PNG file (relative to love filesystem)
--- @param gridWidth number Expected grid width
--- @param gridHeight number Expected grid height
--- @return table|nil tiles 2D array of Tile objects [y][x], or nil on failure
--- @return table|nil playerStarts Array of player start positions {x, y, teamId}
--- @return string|nil error Error message if loading failed
function MapLoader.loadFromPNG(filename, gridWidth, gridHeight)
    print("MapLoader: Loading map from " .. filename)
    
    -- Try to load the image data
    local success, imageData = pcall(love.image.newImageData, filename)
    if not success then
        local error = "Failed to load image data from: " .. filename
        print("MapLoader Error: " .. error)
        return nil, nil, error
    end
    
    local width = imageData:getWidth()
    local height = imageData:getHeight()
    
    print(string.format("MapLoader: PNG dimensions: %dx%d, target grid: %dx%d", 
                        width, height, gridWidth, gridHeight))
    
    -- Scaling factors if dimensions don't match
    local scaleX = width / gridWidth
    local scaleY = height / gridHeight
    
    -- Initialize tile grid
    local tiles = {}
    for y = 1, gridHeight do
        tiles[y] = {}
    end
    
    -- Track player spawn positions
    local playerStarts = {}
    
    -- Process each grid position
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            -- Scale coordinates to sample from the image
            local imageX = math.floor((x - 1) * scaleX)
            local imageY = math.floor((y - 1) * scaleY)
            imageX = math.min(imageX, width - 1)
            imageY = math.min(imageY, height - 1)
            
            -- Get pixel color (normalized 0-1)
            local r, g, b, a = imageData:getPixel(imageX, imageY)
            
            -- Check for special colors first
            
            -- Yellow = Player start (team 1)
            if MapLoader.isColorMatch(r, g, b, 1.0, 1.0, 0.0) then
                tiles[y][x] = Tile.new(x, y, Constants.TERRAIN.FLOOR)
                table.insert(playerStarts, {x = x, y = y, teamId = Constants.TEAM.PLAYER})
                print(string.format("MapLoader: Player start at (%d, %d)", x, y))
            
            -- Cyan = Ally start (team 2)
            elseif MapLoader.isColorMatch(r, g, b, 0.0, 1.0, 1.0) then
                tiles[y][x] = Tile.new(x, y, Constants.TERRAIN.FLOOR)
                table.insert(playerStarts, {x = x, y = y, teamId = Constants.TEAM.ALLY})
                print(string.format("MapLoader: Ally start at (%d, %d)", x, y))
            
            -- Magenta = Enemy start (team 3)
            elseif MapLoader.isColorMatch(r, g, b, 1.0, 0.0, 1.0) then
                tiles[y][x] = Tile.new(x, y, Constants.TERRAIN.FLOOR)
                table.insert(playerStarts, {x = x, y = y, teamId = Constants.TEAM.ENEMY})
                print(string.format("MapLoader: Enemy start at (%d, %d)", x, y))
            
            -- White = Neutral start (team 4)
            elseif MapLoader.isColorMatch(r, g, b, 1.0, 1.0, 1.0) then
                tiles[y][x] = Tile.new(x, y, Constants.TERRAIN.FLOOR)
                table.insert(playerStarts, {x = x, y = y, teamId = Constants.TEAM.NEUTRAL})
                print(string.format("MapLoader: Neutral start at (%d, %d)", x, y))
            
            else
                -- Match to terrain type using TERRAIN_MAP colors
                local terrainType = MapLoader.getTerrainFromColor(r, g, b)
                tiles[y][x] = Tile.new(x, y, terrainType)
            end
        end
    end
    
    print(string.format("MapLoader: Loaded %dx%d grid with %d spawn points", 
                        gridWidth, gridHeight, #playerStarts))
    
    -- Create map object with metadata
    local map = {
        tiles = tiles,
        width = gridWidth,
        height = gridHeight
    }
    
    return map, playerStarts, nil
end

--- Find the closest matching terrain type for a given RGB color
--- @param r number Red component (0-1)
--- @param g number Green component (0-1)
--- @param b number Blue component (0-1)
--- @return any terrainType Constant from Constants.TERRAIN
function MapLoader.getTerrainFromColor(r, g, b)
    local minDist = math.huge
    local closestTerrain = Constants.TERRAIN.FLOOR -- Default to floor
    
    for terrainType, color in pairs(Colors.TERRAIN_MAP) do
        -- Calculate Euclidean distance in RGB space
        local dr = r - color[1]
        local dg = g - color[2]
        local db = b - color[3]
        local dist = dr*dr + dg*dg + db*db
        
        if dist < minDist then
            minDist = dist
            closestTerrain = terrainType
        end
    end
    
    return closestTerrain
end

--- Check if an RGB color matches a target color (with tolerance)
--- @param r number Red component (0-1)
--- @param g number Green component (0-1)
--- @param b number Blue component (0-1)
--- @param targetR number Target red (0-1)
--- @param targetG number Target green (0-1)
--- @param targetB number Target blue (0-1)
--- @param tolerance number|nil Optional tolerance (default 0.15)
--- @return boolean matches True if color is within tolerance
function MapLoader.isColorMatch(r, g, b, targetR, targetG, targetB, tolerance)
    tolerance = tolerance or 0.15
    
    return math.abs(r - targetR) < tolerance and
           math.abs(g - targetG) < tolerance and
           math.abs(b - targetB) < tolerance
end

--- Find a valid spawn point in a given area
--- @param tiles table 2D array of tiles
--- @param width number Map width
--- @param height number Map height
--- @param minX number Minimum X coordinate
--- @param minY number Minimum Y coordinate
--- @param maxX number Maximum X coordinate
--- @param maxY number Maximum Y coordinate
--- @return table|nil Position {x, y} or nil if no valid position found
function MapLoader.findValidSpawnPoint(tiles, width, height, minX, minY, maxX, maxY)
    -- Try a few random positions in the area
    for attempt = 1, 50 do
        local x = math.random(minX, maxX)
        local y = math.random(minY, maxY)
        
        -- Ensure coordinates are in bounds
        if x >= 1 and x <= width and y >= 1 and y <= height then
            local tile = tiles[y][x]
            if tile and tile:isTraversable() then
                return {x = x, y = y}
            end
        end
    end
    
    -- Fallback: search systematically
    for y = minY, maxY do
        for x = minX, maxX do
            if x >= 1 and x <= width and y >= 1 and y <= height then
                local tile = tiles[y][x]
                if tile and tile:isTraversable() then
                    return {x = x, y = y}
                end
            end
        end
    end
    
    return nil  -- No valid spawn point found
end

--- Generate a simple test map procedurally
--- @param gridWidth number Grid width
--- @param gridHeight number Grid height
--- @return table tiles 2D array of Tile objects [y][x]
--- @return table playerStarts Array of player start positions
function MapLoader.generateTestMap(gridWidth, gridHeight)
    print(string.format("MapLoader: Generating test map %dx%d", gridWidth, gridHeight))
    
    local tiles = {}
    local playerStarts = {}
    
    for y = 1, gridHeight do
        tiles[y] = {}
        for x = 1, gridWidth do
            local terrainType
            
            -- Perimeter walls
            if x == 1 or x == gridWidth or y == 1 or y == gridHeight then
                terrainType = Constants.TERRAIN.WALL
            
            -- Random interior walls (25% chance)
            elseif math.random() < 0.25 then
                terrainType = Constants.TERRAIN.WALL
            
            -- Everything else is floor
            else
                terrainType = Constants.TERRAIN.FLOOR
            end
            
            tiles[y][x] = Tile.new(x, y, terrainType)
        end
    end
    
    -- Add some player spawn points
    -- Find valid floor tiles for spawn points
    
    -- Player team in bottom-left area
    local playerSpawn1 = MapLoader.findValidSpawnPoint(tiles, gridWidth, gridHeight, 
        math.floor(gridWidth * 0.1), math.floor(gridHeight * 0.1), 
        math.floor(gridWidth * 0.3), math.floor(gridHeight * 0.3))
    if playerSpawn1 then
        table.insert(playerStarts, {
            x = playerSpawn1.x,
            y = playerSpawn1.y,
            teamId = Constants.TEAM.PLAYER
        })
    end
    
    local playerSpawn2 = MapLoader.findValidSpawnPoint(tiles, gridWidth, gridHeight,
        math.floor(gridWidth * 0.1), math.floor(gridHeight * 0.1),
        math.floor(gridWidth * 0.3), math.floor(gridHeight * 0.3))
    if playerSpawn2 then
        table.insert(playerStarts, {
            x = playerSpawn2.x,
            y = playerSpawn2.y,
            teamId = Constants.TEAM.PLAYER
        })
    end
    
    -- Enemy team in top-right area
    local enemySpawn1 = MapLoader.findValidSpawnPoint(tiles, gridWidth, gridHeight,
        math.floor(gridWidth * 0.7), math.floor(gridHeight * 0.7),
        math.floor(gridWidth * 0.9), math.floor(gridHeight * 0.9))
    if enemySpawn1 then
        table.insert(playerStarts, {
            x = enemySpawn1.x,
            y = enemySpawn1.y,
            teamId = Constants.TEAM.ENEMY
        })
    end
    
    local enemySpawn2 = MapLoader.findValidSpawnPoint(tiles, gridWidth, gridHeight,
        math.floor(gridWidth * 0.7), math.floor(gridHeight * 0.7),
        math.floor(gridWidth * 0.9), math.floor(gridHeight * 0.9))
    if enemySpawn2 then
        table.insert(playerStarts, {
            x = enemySpawn2.x,
            y = enemySpawn2.y,
            teamId = Constants.TEAM.ENEMY
        })
    end
    
    print(string.format("MapLoader: Generated test map with %d spawn points", #playerStarts))
    
    -- Create map object with metadata
    local map = {
        tiles = tiles,
        width = gridWidth,
        height = gridHeight
    }
    
    return map, playerStarts
end

--- Save a tile grid to a PNG file
--- @param tiles table 2D array of Tile objects [y][x]
--- @param filename string Output filename
--- @return boolean success True if save succeeded
function MapLoader.saveToPNG(tiles, filename)
    local height = #tiles
    local width = tiles[1] and #tiles[1] or 0
    
    if width == 0 or height == 0 then
        print("MapLoader Error: Cannot save empty tile grid")
        return false
    end
    
    print(string.format("MapLoader: Saving %dx%d map to %s", width, height, filename))
    
    -- Create image data
    local imageData = love.image.newImageData(width, height)
    
    for y = 1, height do
        for x = 1, width do
            local tile = tiles[y][x]
            local color = Colors.TERRAIN_MAP[tile.terrainType] or {0.5, 0.5, 0.5}
            
            imageData:setPixel(x - 1, y - 1, color[1], color[2], color[3], 1.0)
        end
    end
    
    -- Encode and save
    local pngData = imageData:encode("png")
    local success = love.filesystem.write(filename, pngData)
    
    if success then
        print("MapLoader: Successfully saved to " .. filename)
    else
        print("MapLoader Error: Failed to save to " .. filename)
    end
    
    return success
end

return MapLoader
