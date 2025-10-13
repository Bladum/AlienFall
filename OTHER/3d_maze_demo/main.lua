-- Wolfenstein 3D Style First-Person Maze Demo with G3D
-- Minecraft-style textured walls and floor
local g3d = require "g3d.g3d"
local UnitSystem = require "unit_system"
local Unit = UnitSystem.Unit
local UnitManager = UnitSystem.UnitManager
local UnitRenderer = UnitSystem.UnitRenderer
local UnitFactory = UnitSystem.UnitFactory

local mazeSize = 60

-- Terrain type definitions
local TERRAIN = {
    STONE_WALL = 0,    -- Black (0,0,0) - stone walls
    GRASS = 1,         -- Dark green (0,0.5,0) - grass floor
    PATH = 2,          -- Brown (0.6,0.3,0) - dirt path
    STONE_FLOOR = 3,   -- Light gray (0.7,0.7,0.7) - stone floor
    WOOD_WALL = 4,     -- Light brown (0.6,0.4,0.2) - wood wall
    WOOD_DOOR = 5      -- Red (1,0,0) - wood door (walkable)
}

-- Terrain colors for PNG save/load
local TERRAIN_COLORS = {
    [TERRAIN.STONE_WALL] = {0, 0, 0},           -- Black
    [TERRAIN.GRASS] = {0, 0.5, 0},              -- Dark green
    [TERRAIN.PATH] = {0.6, 0.3, 0},             -- Brown
    [TERRAIN.STONE_FLOOR] = {0.7, 0.7, 0.7},    -- Light gray
    [TERRAIN.WOOD_WALL] = {0.6, 0.4, 0.2},      -- Light brown
    [TERRAIN.WOOD_DOOR] = {1, 0, 0}             -- Red
}

-- Global terrain textures table
local terrainTextures = {}

-- Global wall models table (one per terrain type)
local wallModels = {}

-- Global sky canvas for dynamic updates
local skyCanvas = nil

-- Check if terrain is walkable
local function isWalkable(terrain)
    return terrain ~= TERRAIN.STONE_WALL and terrain ~= TERRAIN.WOOD_WALL
end

local maze = {}
for i = 1, mazeSize do
    maze[i] = {}
    for j = 1, mazeSize do
        -- Create large empty space in the center (20x20 area)
        local centerStart = math.floor(mazeSize/2) - 9
        local centerEnd = math.floor(mazeSize/2) + 10
        local isInCenter = (i >= centerStart and i <= centerEnd and j >= centerStart and j <= centerEnd)
        
        local terrain = TERRAIN.GRASS
        if i == 1 or i == mazeSize or j == 1 or j == mazeSize then
            terrain = TERRAIN.STONE_WALL  -- Perimeter walls
        elseif isInCenter then
            terrain = TERRAIN.GRASS  -- Force grass in center
        elseif math.random() < 0.25 then
            terrain = TERRAIN.STONE_WALL  -- Random walls
        elseif i == j then  -- Diagonal path
            terrain = TERRAIN.PATH
        else
            terrain = TERRAIN.GRASS
        end
        
        maze[i][j] = {terrain = terrain}
    end
end

local player = {
    x = 30, y = 0.5, z = 30,
    gridX = 30, gridY = 30,
    angle = 0,
    startAngle = 0,
    targetAngle = 0,
    moving = false,
    turnTimer = 0,
    turnDuration = 0.1,  -- Faster turns for 45-degree increments
    moveTimer = 0,
    moveDuration = 0.1,  -- Faster movement
    startX = 30, startZ = 30,
    targetX = 30, targetZ = 30
}

-- Input delays for continuous movement/rotation
local moveDelay = 0
local turnDelay = 0
local inputDelayDuration = 0.15  -- Delay between actions when holding keys

-- Recording system
local isRecording = false
local recordingFrameCount = 0
local recordingStartTime = 0
local recordingFPS = 15  -- Record at 15 FPS for GIF creation
local lastRecordingFrame = 0

-- Mouse picking system
local mouseX, mouseY = 0, 0
local selectedTile = nil  -- {x, y, type} where type is "floor" or "wall"
local selectedEnemy = nil  -- Selected enemy unit for highlighting

-- Enemy units system
local enemyUnits = {}
local enemyTexture = nil

-- Player units system (similar to enemy units but controllable)
local playerUnits = {}
local currentPlayerIndex = 1
local playerTexture = nil  -- Will reuse enemy texture for now

-- Get current active player unit
local function getCurrentPlayer()
    return UnitManager.playerUnits[currentPlayerIndex]
end

-- Sprite system for proper billboarding (like LeadHaul)
local spriteDir = 0
local spritePitch = 0

-- Convert screen coordinates to world ray (simplified version)
local function screenToWorldRay(screenX, screenY)
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    
    -- Get camera forward direction
    local currentPlayer = getCurrentPlayer()
    local forwardX = math.sin(currentPlayer.angle)
    local forwardZ = -math.cos(currentPlayer.angle)
    
    -- Get camera right direction (perpendicular to forward)
    local rightX = -forwardZ
    local rightZ = forwardX
    
    -- Calculate field of view (approximate)
    local fov = math.pi / 3  -- 60 degrees
    local aspectRatio = width / height
    
    -- Convert screen coordinates to camera-relative angles
    local screenXNormalized = (screenX / width - 0.5) * 2
    local screenYNormalized = (screenY / height - 0.5) * 2
    
    -- Calculate ray direction
    local rayYaw = screenXNormalized * (fov / 2) * aspectRatio
    local rayPitch = -screenYNormalized * (fov / 2)
    
    -- Rotate ray direction by camera orientation
    local cosYaw = math.cos(rayYaw)
    local sinYaw = math.sin(rayYaw)
    local cosPitch = math.cos(rayPitch)
    local sinPitch = math.sin(rayPitch)
    
    -- Apply camera rotation
    local rayDirX = cosYaw * forwardX + sinYaw * rightX
    local rayDirZ = cosYaw * forwardZ + sinYaw * rightZ
    local rayDirY = sinPitch
    
    return {g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]}, 
           {rayDirX, rayDirY, rayDirZ}
end

-- Find intersection with floor (Y=0 plane)
local function rayIntersectFloor(rayOrigin, rayDir)
    if rayDir[2] >= 0 then return nil end  -- Ray pointing up, no intersection with floor
    
    local t = -rayOrigin[2] / rayDir[2]  -- Y=0 plane
    if t < 0 then return nil end  -- Intersection behind camera
    
    local hitX = rayOrigin[1] + rayDir[1] * t
    local hitZ = rayOrigin[3] + rayDir[3] * t
    
    return {x = hitX, z = hitZ, t = t}
end

-- Check if there's a clear line of sight between two points
-- Find intersection with wall planes
local function rayIntersectWalls(rayOrigin, rayDir)
    local closestHit = nil
    local closestT = math.huge
    
    -- Check all grid positions within reasonable range
    local camX, camZ = g3d.camera.position[1], g3d.camera.position[3]
    local checkRadius = 15  -- Increased from 10 to 15 to handle angled rays better
    
    for gridY = math.max(1, math.floor(camZ - checkRadius)), math.min(mazeSize, math.floor(camZ + checkRadius)) do
        for gridX = math.max(1, math.floor(camX - checkRadius)), math.min(mazeSize, math.floor(camX + checkRadius)) do
            -- Check each wall direction if there's a wall there
            local cell = maze[gridY][gridX]
            
            -- North wall (facing south, at Z = gridY - 0.5)
            if gridY > 1 and not isWalkable(maze[gridY-1][gridX].terrain) then
                local planeZ = gridY - 0.5
                local normal = {0, 0, -1}
                local denominator = rayDir[1]*normal[1] + rayDir[2]*normal[2] + rayDir[3]*normal[3]
                if math.abs(denominator) > 0.00001 then  -- Reduced threshold for better 45-degree angle detection
                    local t = ((planeZ - rayOrigin[3]) * normal[3]) / denominator
                    if t > 0 and t < closestT then
                        local hitX = rayOrigin[1] + rayDir[1] * t
                        local hitY = rayOrigin[2] + rayDir[2] * t
                        -- Check if hit is within wall bounds
                        if hitX >= gridX - 0.5 and hitX <= gridX + 0.5 and hitY >= 0 and hitY <= 1 then
                            closestHit = {x = gridX, y = gridY, type = "wall", direction = "north", hitX = hitX, hitY = hitY, hitZ = planeZ, t = t}
                            closestT = t
                        end
                    end
                end
            end
            
            -- South wall (facing north, at Z = gridY + 0.5)
            if gridY < mazeSize and not isWalkable(maze[gridY+1][gridX].terrain) then
                local planeZ = gridY + 0.5
                local normal = {0, 0, 1}
                local denominator = rayDir[1]*normal[1] + rayDir[2]*normal[2] + rayDir[3]*normal[3]
                if math.abs(denominator) > 0.00001 then  -- Reduced threshold for better 45-degree angle detection
                    local t = ((planeZ - rayOrigin[3]) * normal[3]) / denominator
                    if t > 0 and t < closestT then
                        local hitX = rayOrigin[1] + rayDir[1] * t
                        local hitY = rayOrigin[2] + rayDir[2] * t
                        if hitX >= gridX - 0.5 and hitX <= gridX + 0.5 and hitY >= 0 and hitY <= 1 then
                            closestHit = {x = gridX, y = gridY, type = "wall", direction = "south", hitX = hitX, hitY = hitY, hitZ = planeZ, t = t}
                            closestT = t
                        end
                    end
                end
            end
            
            -- East wall (facing west, at X = gridX + 0.5)
            if gridX < mazeSize and not isWalkable(maze[gridY][gridX+1].terrain) then
                local planeX = gridX + 0.5
                local normal = {1, 0, 0}
                local denominator = rayDir[1]*normal[1] + rayDir[2]*normal[2] + rayDir[3]*normal[3]
                if math.abs(denominator) > 0.00001 then  -- Reduced threshold for better 45-degree angle detection
                    local t = ((planeX - rayOrigin[1]) * normal[1]) / denominator
                    if t > 0 and t < closestT then
                        local hitY = rayOrigin[2] + rayDir[2] * t
                        local hitZ = rayOrigin[3] + rayDir[3] * t
                        if hitZ >= gridY - 0.5 and hitZ <= gridY + 0.5 and hitY >= 0 and hitY <= 1 then
                            closestHit = {x = gridX, y = gridY, type = "wall", direction = "east", hitX = planeX, hitY = hitY, hitZ = hitZ, t = t}
                            closestT = t
                        end
                    end
                end
            end
            
            -- West wall (facing east, at X = gridX - 0.5)
            if gridX > 1 and not isWalkable(maze[gridY][gridX-1].terrain) then
                local planeX = gridX - 0.5
                local normal = { -1, 0, 0}
                local denominator = rayDir[1]*normal[1] + rayDir[2]*normal[2] + rayDir[3]*normal[3]
                if math.abs(denominator) > 0.00001 then  -- Reduced threshold for better 45-degree angle detection
                    local t = ((planeX - rayOrigin[1]) * normal[1]) / denominator
                    if t > 0 and t < closestT then
                        local hitY = rayOrigin[2] + rayDir[2] * t
                        local hitZ = rayOrigin[3] + rayDir[3] * t
                        if hitZ >= gridY - 0.5 and hitZ <= gridY + 0.5 and hitY >= 0 and hitY <= 1 then
                            closestHit = {x = gridX, y = gridY, type = "wall", direction = "west", hitX = planeX, hitY = hitY, hitZ = hitZ, t = t}
                            closestT = t
                        end
                    end
                end
            end
        end
    end
    
    return closestHit
end

-- Find intersection with enemy units (billboard sprites)
local function rayIntersectEnemies(rayOrigin, rayDir)
    local closestHit = nil
    local closestT = math.huge
    
    -- Get all units from UnitManager instead of just enemyUnits
    for _, unit in ipairs(UnitManager.units) do
        if unit.visible and unit.model then
            -- Unit bounding box: x: -0.4 to 0.4, y: -0.25 to 0.75, z: -0.4 to 0.4 (relative to unit position)
            -- But since it's a billboard, we need to check the actual oriented bounding box
            
            -- For simplicity, we'll use an axis-aligned bounding box around the unit
            -- This is approximate but should work well for mouse picking
            local minX = unit.x - 0.4
            local maxX = unit.x + 0.4
            local minY = unit.y - 0.25
            local maxY = unit.y + 0.75
            local minZ = unit.z - 0.4
            local maxZ = unit.z + 0.4
            
            -- Check intersection with each face of the bounding box
            local faces = {
                -- Front face (Z = maxZ)
                {plane = maxZ, normal = {0, 0, 1}, minX = minX, maxX = maxX, minY = minY, maxY = maxY},
                -- Back face (Z = minZ)
                {plane = minZ, normal = {0, 0, -1}, minX = minX, maxX = maxX, minY = minY, maxY = maxY},
                -- Right face (X = maxX)
                {plane = maxX, normal = {1, 0, 0}, minY = minY, maxY = maxY, minZ = minZ, maxZ = maxZ},
                -- Left face (X = minX)
                {plane = minX, normal = {-1, 0, 0}, minY = minY, maxY = maxY, minZ = minZ, maxZ = maxZ},
                -- Top face (Y = maxY)
                {plane = maxY, normal = {0, 1, 0}, minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ},
                -- Bottom face (Y = minY)
                {plane = minY, normal = {0, -1, 0}, minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ}
            }
            
            for _, face in ipairs(faces) do
                local denominator = rayDir[1]*face.normal[1] + rayDir[2]*face.normal[2] + rayDir[3]*face.normal[3]
                if math.abs(denominator) > 0.00001 then
                    local t
                    if face.normal[1] ~= 0 then
                        t = (face.plane - rayOrigin[1]) / denominator
                    elseif face.normal[2] ~= 0 then
                        t = (face.plane - rayOrigin[2]) / denominator
                    elseif face.normal[3] ~= 0 then
                        t = (face.plane - rayOrigin[3]) / denominator
                    end
                    
                    if t > 0 and t < closestT then
                        local hitX = rayOrigin[1] + rayDir[1] * t
                        local hitY = rayOrigin[2] + rayDir[2] * t
                        local hitZ = rayOrigin[3] + rayDir[3] * t
                        
                        -- Check if hit is within the face bounds
                        local withinBounds = true
                        if face.minX and (hitX < face.minX or hitX > face.maxX) then withinBounds = false end
                        if face.minY and (hitY < face.minY or hitY > face.maxY) then withinBounds = false end
                        if face.minZ and (hitZ < face.minZ or hitZ > face.maxZ) then withinBounds = false end
                        
                        if withinBounds then
                            closestHit = {enemy = unit, hitX = hitX, hitY = hitY, hitZ = hitZ, t = t}
                            closestT = t
                        end
                    end
                end
            end
        end
    end
    
    return closestHit
end

-- Update mouse picking
local function updateMousePicking()
    local rayOrigin, rayDir = screenToWorldRay(mouseX, mouseY)
    
    -- Check wall intersections first (walls are closer than floor)
    local wallHit = rayIntersectWalls(rayOrigin, rayDir)
    if wallHit then
        selectedTile = wallHit
        selectedEnemy = nil
        return
    end
    
    -- Check enemy intersections (before floor, as enemies are above floor)
    local enemyHit = rayIntersectEnemies(rayOrigin, rayDir)
    if enemyHit then
        selectedEnemy = enemyHit.enemy
        selectedTile = nil
        return
    end
    
    -- Check floor intersection
    local floorHit = rayIntersectFloor(rayOrigin, rayDir)
    if floorHit then
        local gridX = math.floor(floorHit.x + 0.5)
        local gridY = math.floor(floorHit.z + 0.5)
        
        if gridX >= 1 and gridX <= mazeSize and gridY >= 1 and gridY <= mazeSize then
            selectedTile = {x = gridX, y = gridY, type = "floor"}
            selectedEnemy = nil
            return
        end
    end
    
    -- No intersection found
    selectedTile = nil
    selectedEnemy = nil
end

-- Calculate sprite direction for billboarding (like LeadHaul)
local function calculateSpriteDirection()
    -- For billboarding, we want sprites to face the camera
    -- Calculate angle from sprite to camera position
    local camX, camY, camZ = g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]
    local currentPlayer = getCurrentPlayer()
    local playerX, playerZ = currentPlayer.x, currentPlayer.z

    -- Calculate direction from current player (approximate sprite position) to camera
    local dx = camX - playerX
    local dz = camZ - playerZ

    -- Calculate angle for billboarding
    spriteDir = math.atan2(dx, dz)  -- atan2(dx, dz) gives angle from positive Z axis
    spritePitch = 0  -- Keep pitch at 0 for now to avoid complex rotations
end

-- Update enemy unit orientation for billboarding
local function updateEnemyOrientation(enemy)
    if enemy.model then
        -- Set model rotation to face the direction calculated towards current player
        enemy.model:setRotation(0, enemy.angle, 0)
    end
end

-- Simple function to project 3D world coordinates to screen space
local function worldToScreen(x, y, z)
    -- Get relative position from camera
    local currentPlayer = getCurrentPlayer()
    local relX = x - currentPlayer.x
    local relY = y - currentPlayer.y  
    local relZ = z - currentPlayer.z
    
    -- Rotate relative to camera angle
    local cosA = math.cos(-currentPlayer.angle)
    local sinA = math.sin(-currentPlayer.angle)
    local rotX = relX * cosA - relZ * sinA
    local rotZ = relX * sinA + relZ * cosA
    
    -- Simple perspective projection
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local fov = g3d.camera.fov or math.pi/3
    local aspect = screenW / screenH
    
    if rotZ > 0.1 then  -- Only draw if in front of camera
        local screenX = screenW/2 + (rotX / rotZ) * (screenW/2) / math.tan(fov/2)
        local screenY = screenH/2 - (relY / rotZ) * (screenH/2) / math.tan(fov/2) / aspect
        
        -- Scale based on distance
        local scale = 1 / (rotZ * 0.1)
        
        return screenX, screenY, scale, true
    end
    
    return 0, 0, 0, false
end

-- Rain system
local isRaining = false
local rainDrops = {}
local maxRainDrops = 200  -- Number of rain particles

-- Particle system for smoke and fire
local smokeTiles = {}  -- List of {x, y} positions with smoke
local fireTiles = {}   -- List of {x, y} positions with fire
local smokeParticles = {}  -- Active smoke particles
local fireParticles = {}   -- Active fire particles
local maxSmokeParticles = 100
local maxFireParticles = 150

-- Snow system
local isSnowing = false
local snowFlakes = {}
local maxSnowFlakes = 150  -- Number of snow particles

local function saveMapToPNG()
    print("Saving map to PNG...")
    
    -- Create a canvas for the full map
    local mapCanvas = love.graphics.newCanvas(mazeSize, mazeSize)
    love.graphics.setCanvas(mapCanvas)
    love.graphics.clear(0, 0, 0, 1)
    
    -- Draw the full maze with terrain colors
    for y = 1, mazeSize do
        for x = 1, mazeSize do
            local color = TERRAIN_COLORS[maze[y][x].terrain] or {0, 0, 0}
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", x-1, y-1, 1, 1)
        end
    end
    
    -- Draw player position in yellow
    love.graphics.setColor(1, 1, 0, 1)
    local currentPlayer = getCurrentPlayer()
    love.graphics.rectangle("fill", currentPlayer.gridX-1, currentPlayer.gridY-1, 1, 1)
    
    love.graphics.setCanvas()
    
    -- Save to project directory
    local imageData = love.graphics.readbackTexture(mapCanvas)
    local projectPath = love.filesystem.getWorkingDirectory()
    local filename = projectPath .. "/maze_map_" .. os.date("%Y%m%d_%H%M%S") .. ".png"
    
    -- Use io to save to project directory
    local file = io.open(filename, "wb")
    if file then
        local pngData = imageData:encode("png"):getString()
        file:write(pngData)
        file:close()
        
        print("Map saved as: " .. filename)
        print("Color coding:")
        print("  #000000: Stone walls")
        print("  #008000: Grass")
        print("  #994D00: Path")
        print("  #B3B3B3: Stone floor")
        print("  #996633: Wood wall")
        print("  #FF0000: Wood door")
        print("  #FFFF00: Player start position")
    else
        print("Error: Failed to save PNG file to project directory")
    end
end

local function loadMapFromPNG(filename)
    print("Loading map from PNG: " .. filename)
    
    -- Try to load image directly
    local success, imageData = pcall(love.image.newImageData, filename)
    if not success then
        print("Error: Failed to load image data from: " .. filename)
        return false
    end
    
    local width = imageData:getWidth()
    local height = imageData:getHeight()
    
    print("PNG dimensions: " .. width .. "x" .. height .. ", maze size: " .. mazeSize .. "x" .. mazeSize)
    
    if width ~= mazeSize or height ~= mazeSize then
        print("Warning: PNG dimensions don't match maze size. Will scale/crop to fit.")
        -- Continue loading but scale/crop as needed
    end
    
    -- Helper function to find closest terrain by color
    local function getTerrainFromColor(r, g, b)
        local minDist = math.huge
        local closestTerrain = TERRAIN.GRASS
        
        for terrain, color in pairs(TERRAIN_COLORS) do
            local dr = r - color[1]
            local dg = g - color[2]
            local db = b - color[3]
            local dist = dr*dr + dg*dg + db*db
            
            if dist < minDist then
                minDist = dist
                closestTerrain = terrain
            end
        end
        
        return closestTerrain
    end
    
    -- Read the PNG and set maze data based on RGB values
    -- Handle scaling from image dimensions to maze dimensions
    local scaleX = width / mazeSize
    local scaleY = height / mazeSize
    
    local playerFound = false
    for y = 1, mazeSize do
        for x = 1, mazeSize do
            -- Scale coordinates to sample from the image
            local imageX = math.floor((x - 1) * scaleX)
            local imageY = math.floor((y - 1) * scaleY)
            imageX = math.min(imageX, width - 1)
            imageY = math.min(imageY, height - 1)
            
            local r, g, b, a = imageData:getPixel(imageX, imageY)
            
            -- Check for yellow (player start) - use more lenient range
            if r > 0.8 and g > 0.8 and b < 0.2 then
                -- Set position for first player unit instead of global player
                if #playerUnits > 0 then
                    playerUnits[1].gridX = x
                    playerUnits[1].gridY = y
                    playerUnits[1].x = x
                    playerUnits[1].z = y
                    -- Update the model position
                    if playerUnits[1].model then
                        playerUnits[1].model:setTranslation(x, playerUnits[1].y, y)
                    end
                end
                -- Also update global player as fallback
                player.gridX = x
                player.gridY = y
                player.x = x
                player.z = y
                maze[y][x] = {terrain = TERRAIN.GRASS}
                playerFound = true
                print("Player start found at: " .. x .. "," .. y)
            else
                -- Find closest terrain match
                local terrain = getTerrainFromColor(r, g, b)
                maze[y][x] = {terrain = terrain}
            end
        end
    end
    
    if not playerFound then
        print("Warning: No player start position (yellow pixel) found in PNG. Using center.")
        -- Set position for first player unit
        if #playerUnits > 0 then
            playerUnits[1].gridX = math.floor(mazeSize/2)
            playerUnits[1].gridY = math.floor(mazeSize/2)
            playerUnits[1].x = playerUnits[1].gridX
            playerUnits[1].z = playerUnits[1].gridY
            -- Update the model position
            if playerUnits[1].model then
                playerUnits[1].model:setTranslation(playerUnits[1].x, playerUnits[1].y, playerUnits[1].z)
            end
        end
        -- Also update global player as fallback
        player.gridX = math.floor(mazeSize/2)
        player.gridY = math.floor(mazeSize/2)
        player.x = player.gridX
        player.z = player.gridY
    end
    
    -- Rebuild models with new maze data
    rebuildModels()
    
    print("Map loaded successfully from: " .. filename)
    return true
end

local function buildWallNorth(verts, x, y)
    -- Calculate distance from player to this wall tile
    local currentPlayer = getCurrentPlayer() or player
    local dist = math.sqrt((x - currentPlayer.x)^2 + (y - currentPlayer.z)^2)
    
    -- Apply distance-based lighting: different ranges for day/night
    local brightness = 1.0
    if isNight then
        -- Night: 0-5 full, 5-10 fade, 10+ minimum visibility
        if dist < 5 then
            brightness = 1.0
        elseif dist < 10 then
            brightness = 1.0 - ((dist - 5) / 5)
        else
            brightness = 0.1  -- Minimum visibility beyond 10 tiles
        end
    else
        -- Day: 0-10 full, 10-20 fade, 20+ minimum visibility
        if dist < 10 then
            brightness = 1.0
        elseif dist < 20 then
            brightness = 1.0 - ((dist - 10) / 10)
        else
            brightness = 0.1  -- Minimum visibility beyond 20 tiles
        end
    end
    
    -- Use RGB tinting for brightness - assumes texture is designed for this
    local r, g, b, a = brightness, brightness, brightness, 1.0
    
    -- Apply night color effect: reduce R and G by 30%
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    -- Normal for north-facing wall
    local nx, ny, nz = 0, 0, -1
    local u, v, nu, nv = 0, 1, 1, 0
    table.insert(verts, {x + 0.5, 1, y - 0.5, u, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 1, y - 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 1, y - 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y - 0.5, nu, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
end

local function buildWallSouth(verts, x, y)
    -- Calculate distance from player to this wall tile
    local currentPlayer = getCurrentPlayer() or player
    local dist = math.sqrt((x - currentPlayer.x)^2 + (y - currentPlayer.z)^2)
    
    -- Apply distance-based lighting: different ranges for day/night
    local brightness = 1.0
    if isNight then
        -- Night: 0-5 full, 5-10 fade, 10+ minimum visibility
        if dist < 5 then
            brightness = 1.0
        elseif dist < 10 then
            brightness = 1.0 - ((dist - 5) / 5)
        else
            brightness = 0.1  -- Minimum visibility beyond 10 tiles
        end
    else
        -- Day: 0-10 full, 10-20 fade, 20+ minimum visibility
        if dist < 10 then
            brightness = 1.0
        elseif dist < 20 then
            brightness = 1.0 - ((dist - 10) / 10)
        else
            brightness = 0.1  -- Minimum visibility beyond 20 tiles
        end
    end
    
    -- Use RGB tinting for brightness - assumes texture is designed for this
    local r, g, b, a = brightness, brightness, brightness, 1.0
    
    -- Apply night color effect: reduce R and G by 30%
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    -- Normal for south-facing wall
    local nx, ny, nz = 0, 0, 1
    local u, v, nu, nv = 0, 1, 1, 0
    table.insert(verts, {x - 0.5, 1, y + 0.5, u, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y + 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y + 0.5, nu, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y + 0.5, u, v, nx, ny, nz, r, g, b, a})
end

local function buildWallWest(verts, x, y)
    -- Calculate distance from player to this wall tile
    local currentPlayer = getCurrentPlayer() or player
    local dist = math.sqrt((x - currentPlayer.x)^2 + (y - currentPlayer.z)^2)
    
    -- Apply distance-based lighting: different ranges for day/night
    local brightness = 1.0
    if isNight then
        -- Night: 0-5 full, 5-10 fade, 10+ minimum visibility
        if dist < 5 then
            brightness = 1.0
        elseif dist < 10 then
            brightness = 1.0 - ((dist - 5) / 5)
        else
            brightness = 0.1  -- Minimum visibility beyond 10 tiles
        end
    else
        -- Day: 0-10 full, 10-20 fade, 20+ minimum visibility
        if dist < 10 then
            brightness = 1.0
        elseif dist < 20 then
            brightness = 1.0 - ((dist - 10) / 10)
        else
            brightness = 0.1  -- Minimum visibility beyond 20 tiles
        end
    end
    
    -- Use RGB tinting for brightness - assumes texture is designed for this
    local r, g, b, a = brightness, brightness, brightness, 1.0
    
    -- Apply night color effect: reduce R and G by 30%
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    -- Normal for west-facing wall
    local nx, ny, nz = -1, 0, 0
    local u, v, nu, nv = 0, 1, 1, 0
    table.insert(verts, {x - 0.5, 1, y + 0.5, u, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 1, y - 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y + 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 1, y - 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y - 0.5, nu, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y + 0.5, u, v, nx, ny, nz, r, g, b, a})
end

local function buildFloor(verts, x, y, floorTex)
    -- Calculate distance from player to this floor tile
    local currentPlayer = getCurrentPlayer() or player
    local dist = math.sqrt((x - currentPlayer.x)^2 + (y - currentPlayer.z)^2)
    
    -- Apply distance-based lighting: different ranges for day/night
    local brightness = 1.0
    if isNight then
        -- Night: 0-5 full, 5-10 fade, 10+ minimum visibility
        if dist < 5 then
            brightness = 1.0
        elseif dist < 10 then
            brightness = 1.0 - ((dist - 5) / 5)
        else
            brightness = 0.1  -- Minimum visibility beyond 10 tiles
        end
    else
        -- Day: 0-10 full, 10-20 fade, 20+ minimum visibility
        if dist < 10 then
            brightness = 1.0
        elseif dist < 20 then
            brightness = 1.0 - ((dist - 10) / 10)
        else
            brightness = 0.1  -- Minimum visibility beyond 20 tiles
        end
    end
    
    -- Use RGB tinting for brightness - assumes texture is designed for this
    local r, g, b, a = brightness, brightness, brightness, 1.0
    
    -- Apply night color effect: reduce R and G by 30%
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    -- Normal for floor
    local nx, ny, nz = 0, 1, 0
    -- UV coordinates based on floorTex: 0 = top half (0-0.5), 1 = bottom half (0.5-1)
    local u, v, nu, nv
    if floorTex == 0 then
        u, v, nu, nv = 0, 0, 1, 0.5
    else
        u, v, nu, nv = 0, 0.5, 1, 1
    end
    table.insert(verts, {x - 0.5, 0, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y - 0.5, nu, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 0, y + 0.5, u, nv, nx, ny, nz, r, g, b, a})
end

local function buildSky(verts, x, y, skyTex)
    -- Sky uses vertex colors for the actual sky color, not tinting
    local r, g, b, a
    if isNight then
        r, g, b, a = 0.02, 0.02, 0.08, 1.0  -- Night sky color
    else
        r, g, b, a = 0.4, 0.7, 1.0, 1.0  -- Day sky color
    end
    -- Normal for ceiling (facing down)
    local nx, ny, nz = 0, -1, 0
    -- UV coordinates based on skyTex: 0 = top half (0-0.5), 1 = bottom half (0.5-1)
    local u, v, nu, nv
    if skyTex == 0 then
        u, v, nu, nv = 0, 0, 1, 0.5
    else
        u, v, nu, nv = 0, 0.5, 1, 1
    end
    table.insert(verts, {x - 0.5, 1, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y - 0.5, nu, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 1, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x - 0.5, 1, y + 0.5, u, nv, nx, ny, nz, r, g, b, a})
end

local function buildWallEast(verts, x, y)
    -- Calculate distance from player to this wall tile
    local currentPlayer = getCurrentPlayer() or player
    local dist = math.sqrt((x - currentPlayer.x)^2 + (y - currentPlayer.z)^2)
    
    -- Apply distance-based lighting: different ranges for day/night
    local brightness = 1.0
    if isNight then
        -- Night: 0-5 full, 5-10 fade, 10+ minimum visibility
        if dist < 5 then
            brightness = 1.0
        elseif dist < 10 then
            brightness = 1.0 - ((dist - 5) / 5)
        else
            brightness = 0.1  -- Minimum visibility beyond 10 tiles
        end
    else
        -- Day: 0-10 full, 10-20 fade, 20+ minimum visibility
        if dist < 10 then
            brightness = 1.0
        elseif dist < 20 then
            brightness = 1.0 - ((dist - 10) / 10)
        else
            brightness = 0.1  -- Minimum visibility beyond 20 tiles
        end
    end
    
    -- Use RGB tinting for brightness - assumes texture is designed for this
    local r, g, b, a = brightness, brightness, brightness, 1.0
    
    -- Apply night color effect: reduce R and G by 30%
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    -- Normal for east-facing wall
    local nx, ny, nz = 1, 0, 0
    local u, v, nu, nv = 0, 1, 1, 0
    table.insert(verts, {x + 0.5, 1, y - 0.5, u, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 1, y + 0.5, nu, nv, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y + 0.5, nu, v, nx, ny, nz, r, g, b, a})
    table.insert(verts, {x + 0.5, 0, y - 0.5, u, v, nx, ny, nz, r, g, b, a})
end

function rebuildModels()
    -- Update sky texture based on day/night
    if skyCanvas then
        love.graphics.setCanvas(skyCanvas)
        love.graphics.clear(1.0, 1.0, 1.0, 1.0)  -- White texture for vertex color tinting
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setCanvas()
        skyTexture = love.graphics.newImage(love.graphics.readbackTexture(skyCanvas))
        skyTexture:setFilter("nearest", "nearest")
        skyTexture:setWrap("repeat", "repeat")
    end
    
    -- Create separate wall models for each terrain type
    local wallVerticesByType = {}
    for y = 1, mazeSize do
        for x = 1, mazeSize do
            local terrain = maze[y][x].terrain
            local isWall = not isWalkable(terrain) or terrain == TERRAIN.WOOD_DOOR
            if isWall then
                -- Initialize vertex table for this terrain type if not exists
                if not wallVerticesByType[terrain] then
                    wallVerticesByType[terrain] = {}
                end
                
                local isNorthWalkable = y == 1 or isWalkable(maze[y-1][x].terrain)
                local isSouthWalkable = y == mazeSize or isWalkable(maze[y+1][x].terrain)
                local isWestWalkable = x == 1 or isWalkable(maze[y][x-1].terrain)
                local isEastWalkable = x == mazeSize or isWalkable(maze[y][x+1].terrain)
                
                if isNorthWalkable then
                    buildWallNorth(wallVerticesByType[terrain], x, y)
                end
                if isSouthWalkable then
                    buildWallSouth(wallVerticesByType[terrain], x, y)
                end
                if isWestWalkable then
                    buildWallWest(wallVerticesByType[terrain], x, y)
                end
                if isEastWalkable then
                    buildWallEast(wallVerticesByType[terrain], x, y)
                end
            end
        end
    end
    
    -- Create wall models for each terrain type
    wallModels = {}
    for terrainType, vertices in pairs(wallVerticesByType) do
        if terrainTextures[terrainType] and #vertices > 0 then
            wallModels[terrainType] = g3d.newModel(vertices, terrainTextures[terrainType])
        end
    end
    
    local floorVertices = {}
    for y = 1, mazeSize do
        for x = 1, mazeSize do
            if isWalkable(maze[y][x].terrain) then
                local floorTex = (maze[y][x].terrain == TERRAIN.PATH) and 1 or 0
                buildFloor(floorVertices, x, y, floorTex)
            end
        end
    end
    floorModel = g3d.newModel(floorVertices, floorAtlas)
    
    local skyVertices = {}
    for y = 1, mazeSize do
        for x = 1, mazeSize do
            -- Sky texture based on terrain: stone floors get different sky texture
            local skyTex = (maze[y][x].terrain == TERRAIN.STONE_FLOOR) and 1 or 0
            buildSky(skyVertices, x, y, skyTex)
        end
    end
    skyModel = g3d.newModel(skyVertices, skyAtlas)
    
    -- Note: Enemy models are now updated separately only when lighting changes
end

-- Separate function to update enemy models (only when lighting changes)
function updateEnemyModels()
    -- Update all unit models using the new UnitRenderer
    UnitRenderer:updateAllModels()
end

function love.load()
    print("=== Loading Wolfenstein-Style 3D Maze Demo ===")
    love.window.setMode(1280, 720, {resizable=true, vsync=false, depth=true})
    love.window.setTitle("Wolfenstein-Style 3D Maze Demo")
    
    love.graphics.setDepthMode("lequal", true)
    
    -- Create sky canvas for dynamic lighting
    skyCanvas = love.graphics.newCanvas(16, 16)
    
    -- Load terrain textures from tiles folder FIRST
    local textureMapping = {
        [TERRAIN.STONE_WALL] = "tiles/stone wall.png",
        [TERRAIN.GRASS] = "tiles/grass.png", 
        [TERRAIN.PATH] = "tiles/path.png",
        [TERRAIN.STONE_FLOOR] = "tiles/stone floor.png", -- Use proper stone floor texture
        [TERRAIN.WOOD_WALL] = "tiles/wood wall.png",
        [TERRAIN.WOOD_DOOR] = "tiles/wood door.png"
    }
    
    -- Load all terrain textures
    for terrainType, texturePath in pairs(textureMapping) do
        local success, texture = pcall(love.graphics.newImage, texturePath)
        if success then
            texture:setFilter("nearest", "nearest")
            texture:setWrap("repeat", "repeat")
            terrainTextures[terrainType] = texture
            print("Loaded texture: " .. texturePath)
        else
            print("Failed to load texture: " .. texturePath)
            -- Fallback to a default texture
            terrainTextures[terrainType] = love.graphics.newImage(love.image.newImageData(16, 16))
        end
    end
    
    -- Set default wall and floor textures for backward compatibility
    wallTexture = terrainTextures[TERRAIN.STONE_WALL] or love.graphics.newImage(love.image.newImageData(16, 16))
    floorTexture = terrainTextures[TERRAIN.GRASS] or love.graphics.newImage(love.image.newImageData(16, 16))
    floor2Texture = terrainTextures[TERRAIN.PATH] or love.graphics.newImage(love.image.newImageData(16, 16))
    
    -- Create floor atlas (floor.png on top, floor2.png below)
    local floorWidth = floorTexture:getWidth()
    local floorHeight = floorTexture:getHeight()
    local atlasCanvas = love.graphics.newCanvas(floorWidth, floorHeight * 2)
    love.graphics.setCanvas(atlasCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.draw(floorTexture, 0, 0)
    love.graphics.draw(floor2Texture, 0, floorHeight)
    love.graphics.setCanvas()
    floorAtlas = love.graphics.newImage(love.graphics.readbackTexture(atlasCanvas))
    floorAtlas:setFilter("nearest", "nearest")
    floorAtlas:setWrap("repeat", "repeat")
    
-- Create sky textures
-- Create stone sky texture first
local stoneSkyCanvas = love.graphics.newCanvas(16, 16)
love.graphics.setCanvas(stoneSkyCanvas)
local stoneRoofTexture = nil
local success, tex = pcall(love.graphics.newImage, "tiles/stone roof.png")
if success then
    stoneRoofTexture = tex
    stoneRoofTexture:setFilter("nearest", "nearest")
    love.graphics.draw(stoneRoofTexture, 0, 0, 0, 16/stoneRoofTexture:getWidth(), 16/stoneRoofTexture:getHeight())
    print("Loaded stone roof texture for sky")
else
    print("Failed to load stone roof texture, using solid color")
    love.graphics.clear(0.5, 0.5, 0.5, 1.0)  -- Gray for stone
end
love.graphics.setCanvas()
local stoneSkyTexture = love.graphics.newImage(love.graphics.readbackTexture(stoneSkyCanvas))
stoneSkyTexture:setFilter("nearest", "nearest")
stoneSkyTexture:setWrap("repeat", "repeat")

-- Create sky atlas (regular sky on top, stone sky below)
local skyWidth = 256
local skyHeight = 256
local skyAtlasCanvas = love.graphics.newCanvas(skyWidth, skyHeight * 2)
love.graphics.setCanvas(skyAtlasCanvas)
love.graphics.clear(0, 0, 0, 0)

-- Top half: regular sky (day color)
love.graphics.setColor(1, 1, 1, 1)
love.graphics.clear(0.4, 0.7, 1.0, 1.0)  -- Day sky color

-- Bottom half: stone sky
love.graphics.setCanvas(skyAtlasCanvas)
-- Draw stone sky texture scaled to fit
love.graphics.draw(stoneSkyTexture, 0, skyHeight, 0, skyWidth/16, skyHeight/16)

love.graphics.setCanvas()
skyAtlas = love.graphics.newImage(love.graphics.readbackTexture(skyAtlasCanvas))
skyAtlas:setFilter("nearest", "nearest")
skyAtlas:setWrap("repeat", "repeat")

-- Create star field texture for night sky
--[[
local starFieldCanvas = love.graphics.newCanvas(256, 256)
love.graphics.setCanvas(starFieldCanvas)
love.graphics.clear(0, 0, 0, 0)  -- Transparent background
love.graphics.setColor(1, 1, 1, 1)
-- Generate random stars
for i = 1, 200 do
    local x = math.random(0, 255)
    local y = math.random(0, 255)
    local brightness = math.random(0.3, 1.0)
    love.graphics.setColor(brightness, brightness, brightness, 1)
    love.graphics.points(x, y)
end
love.graphics.setColor(1, 1, 1, 1)
love.graphics.setCanvas()
starFieldTexture = love.graphics.newImage(love.graphics.readbackTexture(starFieldCanvas))
starFieldTexture:setFilter("nearest", "nearest")
starFieldTexture:setWrap("repeat", "repeat")
--]]

    -- Load enemy texture
    local success, enemyTex = pcall(love.graphics.newImage, "tiles/enemy.png")
    if success then
        enemyTex:setFilter("nearest", "nearest")
        enemyTexture = enemyTex
        print("Loaded enemy texture: tiles/enemy.png")
    else
        print("Failed to load enemy texture: tiles/enemy.png")
        enemyTexture = love.graphics.newImage(love.image.newImageData(16, 16))
    end

    -- Load player texture
    local success2, playerTex = pcall(love.graphics.newImage, "tiles/player.png")
    if success2 then
        playerTex:setFilter("nearest", "nearest")
        playerTexture = playerTex
        print("Loaded player texture: tiles/player.png")
    else
        print("Failed to load player texture: tiles/player.png")
        playerTexture = love.graphics.newImage(love.image.newImageData(16, 16))
    end
    
    -- Initialize new unit system
    UnitManager:init()
    UnitRenderer:init(g3d)
    
    -- Load shared textures for unit system
    UnitRenderer:loadTexture("default", "tiles/player.png")
    UnitRenderer:loadTexture("player", "tiles/player.png")
    UnitRenderer:loadTexture("enemy", "tiles/enemy.png")
    
    -- Always try to load/create map from PNG file
    local mapFilename = "maze_map.png"
    
    if not loadMapFromPNG(mapFilename) then
        print("Creating default maze_map.png...")
        -- Create a default maze and save it as PNG
        for i = 1, mazeSize do
            for j = 1, mazeSize do
                -- Create large empty space in the center (20x20 area)
                local centerStart = math.floor(mazeSize/2) - 9
                local centerEnd = math.floor(mazeSize/2) + 10
                local isInCenter = (i >= centerStart and i <= centerEnd and j >= centerStart and j <= centerEnd)
                
                local terrain = TERRAIN.GRASS
                if i == 1 or i == mazeSize or j == 1 or j == mazeSize then
                    terrain = TERRAIN.STONE_WALL  -- Perimeter walls
                elseif isInCenter then
                    terrain = TERRAIN.GRASS  -- Force grass in center
                elseif math.random() < 0.25 then
                    terrain = TERRAIN.STONE_WALL  -- Random walls
                elseif i == j then  -- Diagonal path
                    terrain = TERRAIN.PATH
                else
                    terrain = TERRAIN.GRASS
                end
                
                maze[i][j] = {terrain = terrain}
            end
        end
        
        -- Set default player position
        player.gridX = math.floor(mazeSize/2)
        player.gridY = math.floor(mazeSize/2)
        player.x = player.gridX
        player.z = player.gridY
        
        -- Save the default maze as PNG
        saveMapToPNG()
        print("Default maze created and saved as maze_map.png")
    end
    
    -- Initial model build
    rebuildModels()
    
    print("Wall and floor models created")
    
    print("\n=== Map Editor Controls ===")
    print("P - Save current map to PNG file")
    print("L - Load most recent map from PNG file")
    print("Edit the PNG file with an image editor to create custom maps!")
    print("Color coding for editing:")
    print("  Black pixels = Walls")
    print("  Light gray pixels = Floor texture 0") 
    print("  Dark gray pixels = Floor texture 1")
    print("  Yellow pixel = Player start position")
    
    print("\n=== Recording Controls ===")
    print("F10 - Take screenshot (saved as PNG)")
    print("F11 - Toggle frame recording mode (15 FPS for GIF/video creation)")
    print("For video/GIF recording, use external tools:")
    print("  - OBS Studio (free, recommended for full video)")
    print("  - Bandicam, Fraps, or similar screen recorders")
    print("  - Convert F11 frames to GIF using online tools or FFmpeg")
    
    -- Initialize player units using factory
    local playerUnitPositions = {
        {x = 10, z = 10, angle = 0},      -- North corner
        {x = 50, z = 10, angle = math.pi/2}, -- East corner  
        {x = 50, z = 50, angle = math.pi},   -- South corner
        {x = 10, z = 50, angle = -math.pi/2}, -- West corner
        {x = 30, z = 30, angle = math.pi/4}  -- Center
    }
    
    for i, pos in ipairs(playerUnitPositions) do
        -- Ensure player unit is placed on a walkable tile
        local finalX, finalZ = pos.x, pos.z
        if not (finalX >= 1 and finalX <= mazeSize and finalZ >= 1 and finalZ <= mazeSize and isWalkable(maze[finalZ][finalX].terrain)) then
            -- Find nearest walkable tile
            local found = false
            for radius = 1, 10 do
                for dx = -radius, radius do
                    for dz = -radius, radius do
                        if math.abs(dx) == radius or math.abs(dz) == radius then
                            local testX = pos.x + dx
                            local testZ = pos.z + dz
                            if testX >= 1 and testX <= mazeSize and testZ >= 1 and testZ <= mazeSize and isWalkable(maze[testZ][testX].terrain) then
                                finalX, finalZ = testX, testZ
                                found = true
                                break
                            end
                        end
                    end
                    if found then break end
                end
                if found then break end
            end
            -- If still no walkable tile found, place at player start position
            if not found then
                finalX, finalZ = player.gridX, player.gridY
            end
        end
        
        -- Create unit using factory
        local playerUnit = UnitFactory.createPlayerSoldier(finalX, finalZ)
        playerUnit.angle = pos.angle
        playerUnit.texture = playerTexture
        UnitManager:addUnit(playerUnit)
    end
    
    -- Initialize lighting based on current player position (same as player switching)
    updateEnemyModels()  -- Recalculate lighting for enemies and player units
    rebuildModels()      -- Recalculate wall/floor/sky lighting
    
    -- Set up camera - angle 0 = north (-Z), 90 = east (+X), 180 = south (+Z), 270 = west (-X)
    local currentPlayer = getCurrentPlayer()
    g3d.camera.position = {currentPlayer.x, currentPlayer.y + 0.5, currentPlayer.z}
    g3d.camera.target = {currentPlayer.x + math.sin(currentPlayer.angle), currentPlayer.y + 0.5, currentPlayer.z - math.cos(currentPlayer.angle)}
    g3d.camera.up = {0, 1, 0}
    g3d.camera:updateViewMatrix()
    g3d.camera.fov = math.pi / 3
    g3d.camera.nearClip = 0.01
    g3d.camera.farClip = 10000
    
    -- Initialize enemy units using factory
    for i = 1, 30 do
        local x, y
        local attempts = 0
        repeat
            x = math.random(1, mazeSize)
            y = math.random(1, mazeSize)
            attempts = attempts + 1
        until (x >= 1 and x <= mazeSize and y >= 1 and y <= mazeSize and isWalkable(maze[y][x].terrain)) or attempts > 100
        
        -- If we couldn't find a walkable tile after many attempts, place near current player as fallback
        if not (x >= 1 and x <= mazeSize and y >= 1 and y <= mazeSize and isWalkable(maze[y][x].terrain)) then
            local currentPlayer = getCurrentPlayer()
            x = currentPlayer.gridX + math.random(-3, 3)
            y = currentPlayer.gridY + math.random(-3, 3)
            -- Final fallback to current player position
            if not (x >= 1 and x <= mazeSize and y >= 1 and y <= mazeSize and isWalkable(maze[y][x].terrain)) then
                x, y = currentPlayer.gridX, currentPlayer.gridY
            end
        end
        
        -- Create enemy using factory
        local enemy = UnitFactory.createEnemy(x, y)
        enemy.texture = enemyTexture
        UnitManager:addUnit(enemy)
    end
    
    -- Initialize rain drops (screen-space)
    for i = 1, maxRainDrops do
        rainDrops[i] = {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            speed = math.random(200, 400),
            length = math.random(10, 20)
        }
    end
    
    -- Initialize snow flakes (screen-space)
    for i = 1, maxSnowFlakes do
        snowFlakes[i] = {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            speed = math.random(20, 50),
            drift = math.random(-10, 10),
            size = math.random(2, 5)
        }
    end
    
    -- Initialize smoke tiles (20 random floor tiles)
    for i = 1, 20 do
        local x, y
        repeat
            x = math.random(2, mazeSize-1)
            y = math.random(2, mazeSize-1)
        until isWalkable(maze[y][x].terrain)  -- Only place on walkable tiles
        table.insert(smokeTiles, {x = x, y = y})
    end
    
    -- Initialize fire tiles (30 random floor tiles, different from smoke tiles)
    for i = 1, 30 do
        local x, y
        local attempts = 0
        repeat
            x = math.random(2, mazeSize-1)
            y = math.random(2, mazeSize-1)
            attempts = attempts + 1
        until (isWalkable(maze[y][x].terrain) and attempts < 100)  -- Only place on walkable tiles
        table.insert(fireTiles, {x = x, y = y})
    end
    
    print("=== Ready ===")
end

function love.update(dt)
    -- Limit to 30 FPS
    local targetFPS = 30
    local targetFrameTime = 1.0 / targetFPS
    dt = math.min(dt, targetFrameTime)  -- Cap dt to prevent large jumps
    
    -- Update input delays
    if moveDelay > 0 then moveDelay = moveDelay - dt end
    if turnDelay > 0 then turnDelay = turnDelay - dt end
    
    -- Handle continuous movement input for current player unit
    local currentPlayer = getCurrentPlayer()
    if moveDelay <= 0 and (not currentPlayer.moveTimer or currentPlayer.moveTimer <= 0) then
        local newX, newY = currentPlayer.gridX, currentPlayer.gridY
        local snappedAngle = math.floor((currentPlayer.angle / (math.pi/4)) + 0.5) * (math.pi/4) % (2 * math.pi)
        
        if love.keyboard.isDown("w") then
            -- Forward
            if snappedAngle == 0 then newY = newY - 1
            elseif snappedAngle == math.pi/4 then newY = newY - 1; newX = newX + 1
            elseif snappedAngle == math.pi/2 then newX = newX + 1
            elseif snappedAngle == 3*math.pi/4 then newY = newY + 1; newX = newX + 1
            elseif snappedAngle == math.pi then newY = newY + 1
            elseif snappedAngle == 5*math.pi/4 then newY = newY + 1; newX = newX - 1
            elseif snappedAngle == 3*math.pi/2 then newX = newX - 1
            elseif snappedAngle == 7*math.pi/4 then newY = newY - 1; newX = newX - 1
            end
        elseif love.keyboard.isDown("s") then
            -- Backward
            if snappedAngle == 0 then newY = newY + 1
            elseif snappedAngle == math.pi/4 then newY = newY + 1; newX = newX - 1
            elseif snappedAngle == math.pi/2 then newX = newX - 1
            elseif snappedAngle == 3*math.pi/4 then newY = newY - 1; newX = newX - 1
            elseif snappedAngle == math.pi then newY = newY - 1
            elseif snappedAngle == 5*math.pi/4 then newY = newY - 1; newX = newX + 1
            elseif snappedAngle == 3*math.pi/2 then newX = newX + 1
            elseif snappedAngle == 7*math.pi/4 then newY = newY + 1; newX = newX + 1
            end
        elseif love.keyboard.isDown("a") then
            -- Strafe left (perpendicular to facing)
            if snappedAngle == 0 then newX = newX - 1
            elseif snappedAngle == math.pi/4 then newX = newX - 1; newY = newY - 1
            elseif snappedAngle == math.pi/2 then newY = newY - 1
            elseif snappedAngle == 3*math.pi/4 then newX = newX + 1; newY = newY - 1
            elseif snappedAngle == math.pi then newX = newX + 1
            elseif snappedAngle == 5*math.pi/4 then newX = newX + 1; newY = newY + 1
            elseif snappedAngle == 3*math.pi/2 then newY = newY + 1
            elseif snappedAngle == 7*math.pi/4 then newX = newX - 1; newY = newY + 1
            end
        elseif love.keyboard.isDown("d") then
            -- Strafe right (perpendicular to facing)
            if snappedAngle == 0 then newX = newX + 1
            elseif snappedAngle == math.pi/4 then newX = newX + 1; newY = newY + 1
            elseif snappedAngle == math.pi/2 then newY = newY + 1
            elseif snappedAngle == 3*math.pi/4 then newX = newX - 1; newY = newY + 1
            elseif snappedAngle == math.pi then newX = newX - 1
            elseif snappedAngle == 5*math.pi/4 then newX = newX - 1; newY = newY - 1
            elseif snappedAngle == 3*math.pi/2 then newY = newY - 1
            elseif snappedAngle == 7*math.pi/4 then newX = newX + 1; newY = newY - 1
            end
        end
        
        -- Check bounds and walkability, start movement if valid
        if newX ~= currentPlayer.gridX or newY ~= currentPlayer.gridY then
            if newX >= 1 and newX <= mazeSize and newY >= 1 and newY <= mazeSize then
                if isWalkable(maze[newY][newX].terrain) then
                    -- Check if there's an enemy unit at the target position
                    local enemyAtPosition = false
                    for _, enemy in ipairs(enemyUnits) do
                        if enemy.gridX == newX and enemy.gridY == newY then
                            enemyAtPosition = true
                            break
                        end
                    end

                    -- Check if there's another player unit at the target position
                    local playerAtPosition = false
                    for i, playerUnit in ipairs(playerUnits) do
                        if i ~= currentPlayerIndex and playerUnit.gridX == newX and playerUnit.gridY == newY then
                            playerAtPosition = true
                            break
                        end
                    end

                    if not enemyAtPosition and not playerAtPosition then
                        -- Set up movement animation
                        currentPlayer.startX = currentPlayer.x
                        currentPlayer.startZ = currentPlayer.z
                        currentPlayer.targetX = newX
                        currentPlayer.targetZ = newY
                        currentPlayer.gridX = newX
                        currentPlayer.gridY = newY
                        currentPlayer.moveTimer = currentPlayer.moveDuration or 0.2
                        currentPlayer.moveDuration = currentPlayer.moveDuration or 0.2
                        currentPlayer.moving = true
                        moveDelay = inputDelayDuration
                    end
                end
            end
        end
    end
    
    -- Handle continuous turning input for current player unit
    if turnDelay <= 0 and (not currentPlayer.turnTimer or currentPlayer.turnTimer <= 0) then
        if love.keyboard.isDown("q") then
            -- Turn left
            currentPlayer.startAngle = currentPlayer.angle
            currentPlayer.targetAngle = currentPlayer.angle - math.pi/4  -- 45 degrees
            currentPlayer.turnTimer = currentPlayer.turnDuration or 0.15
            currentPlayer.turnDuration = currentPlayer.turnDuration or 0.15
            currentPlayer.moving = true
            turnDelay = inputDelayDuration
        elseif love.keyboard.isDown("e") then
            -- Turn right
            currentPlayer.startAngle = currentPlayer.angle
            currentPlayer.targetAngle = currentPlayer.angle + math.pi/4  -- 45 degrees
            currentPlayer.turnTimer = currentPlayer.turnDuration or 0.15
            currentPlayer.turnDuration = currentPlayer.turnDuration or 0.15
            currentPlayer.moving = true
            turnDelay = inputDelayDuration
        end
    end
    
    -- Handle turning animation for current player unit
    if currentPlayer.turnTimer and currentPlayer.turnTimer > 0 then
        currentPlayer.turnTimer = currentPlayer.turnTimer - dt
        if currentPlayer.turnTimer <= 0 then
            currentPlayer.turnTimer = 0
            -- Ensure final angle is exactly one of the 45-degree increments
            currentPlayer.angle = math.floor((currentPlayer.targetAngle / (math.pi/4)) + 0.5) * (math.pi/4) % (2 * math.pi)
        else
            -- Interpolate angle smoothly during turn from startAngle to targetAngle
            local progress = (currentPlayer.turnDuration - currentPlayer.turnTimer) / currentPlayer.turnDuration
            local angleDiff = currentPlayer.targetAngle - currentPlayer.startAngle
            -- Handle angle wrapping (e.g., 2π to 0)
            if angleDiff > math.pi then
                angleDiff = angleDiff - 2 * math.pi
            elseif angleDiff < -math.pi then
                angleDiff = angleDiff + 2 * math.pi
            end
            currentPlayer.angle = currentPlayer.startAngle + angleDiff * progress
            -- Ensure angle stays within 0-2π range
            currentPlayer.angle = currentPlayer.angle % (2 * math.pi)
            -- Snap to nearest 45-degree increment during animation for visual consistency
            local snappedAngle = math.floor((currentPlayer.angle / (math.pi/4)) + 0.5) * (math.pi/4)
            player.angle = snappedAngle % (2 * math.pi)
            
            -- Update all units to face the turning current player
            for _, enemy in ipairs(enemyUnits) do
                local dx = currentPlayer.x - enemy.x
                local dz = currentPlayer.z - enemy.z
                enemy.angle = math.atan2(-dz, dx)
            end
            for i, playerUnit in ipairs(playerUnits) do
                if i ~= currentPlayerIndex then  -- Don't change current player's angle
                    local dx = currentPlayer.x - playerUnit.x
                    local dz = currentPlayer.z - playerUnit.z
                    playerUnit.angle = math.atan2(-dz, dx)
                end
            end
        end
    end
    
    -- Handle movement animation for current player unit
    local currentPlayer = getCurrentPlayer()
    if currentPlayer.moveTimer and currentPlayer.moveTimer > 0 then
        currentPlayer.moveTimer = currentPlayer.moveTimer - dt
        if currentPlayer.moveTimer <= 0 then
            currentPlayer.moveTimer = 0
            currentPlayer.moving = false
            -- Ensure final position is exactly at the target grid position
            currentPlayer.x = currentPlayer.targetX
            currentPlayer.z = currentPlayer.targetZ
            
            -- Update current player unit model position to final position
            if currentPlayer.model then
                currentPlayer.model:setTranslation(currentPlayer.x, currentPlayer.y, currentPlayer.z)
            end
            
            -- Update lighting based on new player position
            updateEnemyModels()  -- Recalculate lighting for enemies and player units
            rebuildModels()      -- Recalculate wall/floor/sky lighting
        else
            -- Interpolate position smoothly during move
            local progress = (currentPlayer.moveDuration - currentPlayer.moveTimer) / currentPlayer.moveDuration
            currentPlayer.x = currentPlayer.startX + (currentPlayer.targetX - currentPlayer.startX) * progress
            currentPlayer.z = currentPlayer.startZ + (currentPlayer.targetZ - currentPlayer.startZ) * progress
            
            -- Update current player unit model position during movement
            if currentPlayer.model then
                currentPlayer.model:setTranslation(currentPlayer.x, currentPlayer.y, currentPlayer.z)
            end
            
            -- Update all units to face the moving current player
            for _, enemy in ipairs(enemyUnits) do
                local dx = currentPlayer.x - enemy.x
                local dz = currentPlayer.z - enemy.z
                enemy.angle = math.atan2(-dz, dx)
            end
            for i, playerUnit in ipairs(playerUnits) do
                if i ~= currentPlayerIndex then  -- Don't change current player's angle
                    local dx = currentPlayer.x - playerUnit.x
                    local dz = currentPlayer.z - playerUnit.z
                    playerUnit.angle = math.atan2(-dz, dx)
                end
            end
        end
    end
    
    -- Update camera position to follow current player unit
    g3d.camera.position = {currentPlayer.x, currentPlayer.y + 0.5, currentPlayer.z}
    g3d.camera.target = {currentPlayer.x + math.sin(currentPlayer.angle), currentPlayer.y + 0.5, currentPlayer.z - math.cos(currentPlayer.angle)}
    g3d.camera.up = {0, 1, 0}
    g3d.camera:updateViewMatrix()
    
    -- Make all units face towards the current player
    for _, enemy in ipairs(enemyUnits) do
        local dx = currentPlayer.x - enemy.x
        local dz = currentPlayer.z - enemy.z
        enemy.angle = math.atan2(-dz, dx)  -- atan2(-dz, dx) gives correct angle for facing
    end
    
    for i, playerUnit in ipairs(playerUnits) do
        if i ~= currentPlayerIndex then  -- Don't change current player's angle
            local dx = currentPlayer.x - playerUnit.x
            local dz = currentPlayer.z - playerUnit.z
            playerUnit.angle = math.atan2(-dz, dx)
        end
    end
    
    -- Calculate sprite direction for billboarding (like LeadHaul)
    calculateSpriteDirection()
    
    -- Update mouse picking for tile highlighting
    updateMousePicking()
    
    -- Update enemy orientations to face camera (proper billboarding)
    for _, enemy in ipairs(enemyUnits) do
        updateEnemyOrientation(enemy)
    end
    
    -- Update player unit orientations to face camera (proper billboarding)
    for _, playerUnit in ipairs(playerUnits) do
        updateEnemyOrientation(playerUnit)  -- Reuse the same function
    end
    
    -- Note: Models are only rebuilt when lighting changes (day/night), not every frame
    
    -- Handle frame recording
    if isRecording then
        local currentTime = love.timer.getTime()
        if currentTime - lastRecordingFrame >= 1.0 / recordingFPS then
            recordingFrameCount = recordingFrameCount + 1
            local filename = string.format("recording/frame_%04d.png", recordingFrameCount)
            love.graphics.captureScreenshot(filename)
            lastRecordingFrame = currentTime
            
            -- Limit recording to prevent filling disk
            if recordingFrameCount >= 900 then  -- 60 seconds at 15 FPS
                isRecording = false
                print("Recording stopped automatically (60 second limit reached)")
                print("Recorded " .. recordingFrameCount .. " frames")
                print("Use FFmpeg or online tools to convert frames to video/GIF")
            end
        end
    end
    
    -- Update rain drops if raining (screen-space effect)
    if isRaining then
        for i, drop in ipairs(rainDrops) do
            -- Move rain drops down the screen
            drop.y = drop.y + drop.speed * dt
            
            -- Reset rain drop when it goes off screen
            if drop.y > love.graphics.getHeight() + 20 then
                drop.x = math.random(0, love.graphics.getWidth())
                drop.y = math.random(-20, 0)
                drop.speed = math.random(200, 400)
                drop.length = math.random(10, 20)
            end
        end
    end
    
    -- Update snow flakes if snowing (screen-space effect)
    if isSnowing then
        for i, flake in ipairs(snowFlakes) do
            -- Move snow flakes down the screen with drift
            flake.y = flake.y + flake.speed * dt
            flake.x = flake.x + flake.drift * dt
            
            -- Reset snow flake when it goes off screen
            if flake.y > love.graphics.getHeight() + 10 or flake.x < -10 or flake.x > love.graphics.getWidth() + 10 then
                flake.x = math.random(0, love.graphics.getWidth())
                flake.y = math.random(-20, 0)
                flake.speed = math.random(20, 50)
                flake.drift = math.random(-10, 10)
                flake.size = math.random(2, 5)
            end
        end
    end
    
    -- Update smoke particles
    -- Remove old particles
    for i = #smokeParticles, 1, -1 do
        local particle = smokeParticles[i]
        particle.life = particle.life - dt
        if particle.life <= 0 or particle.y > 3 then  -- Disappear after rising 3 units
            table.remove(smokeParticles, i)
        else
            -- Update particle position (rise and drift)
            particle.y = particle.y + particle.speed * dt
            particle.x = particle.x + particle.drift * dt
            particle.alpha = particle.alpha - dt * 0.3  -- Fade out
            -- Size changes as it rises
            particle.size = particle.size + dt * 0.01  -- Grow slightly
        end
    end
    
    -- Spawn new smoke particles from smoke tiles
    if particlesEnabled then
        local currentPlayer = getCurrentPlayer()
        for _, tile in ipairs(smokeTiles) do
            if #smokeParticles < maxSmokeParticles and math.random() < 0.2 then  -- 20% chance per frame
                local dist = math.sqrt((tile.x - currentPlayer.x)^2 + (tile.y - currentPlayer.z)^2)
                if dist < 20 then  -- Only spawn if close to current player
                    table.insert(smokeParticles, {
                        x = tile.x + math.random(-0.2, 0.2),
                        y = 0.1,  -- Start at floor level
                        z = tile.y + math.random(-0.2, 0.2),
                        speed = math.random(0.8, 1.5),
                        drift = math.random(-0.1, 0.1),
                        alpha = 0.6,
                        life = math.random(4, 8),
                        size = 0.02  -- Small particles
                    })
                end
            end
        end
    end
    
    -- Update fire particles
    -- Remove old particles
    for i = #fireParticles, 1, -1 do
        local particle = fireParticles[i]
        particle.life = particle.life - dt
        if particle.life <= 0 or particle.y > 2 then  -- Disappear after rising 2 units
            table.remove(fireParticles, i)
        else
            -- Update particle position (rise and flicker)
            particle.y = particle.y + particle.speed * dt
            particle.x = particle.x + particle.drift * dt
            particle.alpha = particle.alpha - dt * 0.8  -- Fade out faster
            -- Size changes as it rises
            particle.size = particle.size - dt * 0.02  -- Shrink slightly
            -- Fire particles flicker
            particle.size = particle.size + math.sin(love.timer.getTime() * 15 + i) * 0.005
        end
    end
    
    -- Spawn new fire particles from fire tiles
    if particlesEnabled then
        for _, tile in ipairs(fireTiles) do
            if #fireParticles < maxFireParticles and math.random() < 0.4 then  -- 40% chance per frame
                local dist = math.sqrt((tile.x - player.x)^2 + (tile.y - player.z)^2)
                if dist < 20 then  -- Only spawn if close to player
                    table.insert(fireParticles, {
                        x = tile.x + math.random(-0.15, 0.15),
                        y = 0.1,  -- Start at floor level
                        z = tile.y + math.random(-0.15, 0.15),
                        speed = math.random(1.5, 3),
                        drift = math.random(-0.2, 0.2),
                        alpha = 1.0,
                        life = math.random(1.5, 3),
                        size = math.random(0.03, 0.08),  -- Small particles
                        color = math.random()  -- For color variation
                    })
                end
            end
        end
    end
    
    -- Update all units through UnitManager
    UnitManager:updateAll(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        -- Switch to next player unit using UnitManager
        UnitManager:nextPlayerUnit()
        local newPlayer = getCurrentPlayer()
        print("Switched to player unit " .. currentPlayerIndex .. " at position (" .. newPlayer.gridX .. ", " .. newPlayer.gridY .. ")")
        
        -- Update everything that depends on player position
        updateEnemyModels()  -- Recalculate lighting based on new player position
        rebuildModels()      -- Recalculate wall/floor/sky lighting based on new player position
    elseif key == "p" then
        -- Save map to PNG
        saveMapToPNG()
    elseif key == "l" then
        -- Load most recent map from PNG
        print("Loading map... (this may take a moment)")
        loadMapFromPNG("maze_map.png")
        print("Map loaded!")
    elseif key == "f" then
        -- Toggle day/night
        isNight = not isNight
        print("Switched to " .. (isNight and "night" or "day") .. " mode")
        rebuildModels()
        updateEnemyModels()  -- Update enemy lighting when day/night changes
    elseif key == "f4" then
        -- Toggle rain
        isRaining = not isRaining
        if isRaining then
            isSnowing = false  -- Disable snow when rain starts
        end
        print("Rain " .. (isRaining and "started" or "stopped"))
    elseif key == "f5" then
        -- Toggle snow
        isSnowing = not isSnowing
        if isSnowing then
            isRaining = false  -- Disable rain when snow starts
        end
        print("Snow " .. (isSnowing and "started" or "stopped"))
    elseif key == "f6" then
        -- Toggle smoke/fire particles
        particlesEnabled = not particlesEnabled
        print("Smoke/Fire particles " .. (particlesEnabled and "enabled" or "disabled"))
    elseif key == "f10" then
        -- Take screenshot for recording
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local filename = string.format("screenshot_%s.png", timestamp)
        love.graphics.captureScreenshot(filename)
        print("Screenshot saved: " .. filename)
        print("For video recording, use external tools like OBS Studio or Bandicam")
    elseif key == "f11" then
        -- Toggle frame recording mode
        isRecording = not isRecording
        if isRecording then
            recordingFrameCount = 0
            recordingStartTime = love.timer.getTime()
            lastRecordingFrame = 0
            -- Create recording directory if it doesn't exist
            love.filesystem.createDirectory("recording")
            print("Frame recording started (15 FPS)")
            print("Press F11 again to stop, or wait for auto-stop after 60 seconds")
        else
            print("Frame recording stopped")
            print("Recorded " .. recordingFrameCount .. " frames to 'recording/' folder")
            print("Use FFmpeg or online tools to convert frames to video/GIF:")
            print("  ffmpeg -framerate 15 -i recording/frame_%04d.png -c:v libx264 output.mp4")
        end
    end
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.15, 1, true, true)
    love.graphics.setDepthMode("lequal", true)
    g3d.camera:updateProjectionMatrix()

    -- Draw floor
    floorModel:draw()
    
    -- Draw sky
    skyModel:draw()

    -- Draw walls first (they use proper depth testing)
    for _, model in pairs(wallModels) do
        model:draw()
    end

    -- Draw all units using the new UnitRenderer
    UnitRenderer:drawUnits()

    -- Draw highlighted selected tile
    if selectedTile then
        love.graphics.setDepthMode("always", false)
        if selectedTile.type == "floor" then
            -- Highlight floor tile with a 3D model
            local highlightVertices = {
                {selectedTile.x - 0.5, 0.01, selectedTile.y - 0.5, 0, 0},
                {selectedTile.x + 0.5, 0.01, selectedTile.y - 0.5, 1, 0},
                {selectedTile.x + 0.5, 0.01, selectedTile.y + 0.5, 1, 1},
                {selectedTile.x - 0.5, 0.01, selectedTile.y + 0.5, 0, 1},
                {selectedTile.x - 0.5, 0.01, selectedTile.y - 0.5, 0, 0},
                {selectedTile.x + 0.5, 0.01, selectedTile.y + 0.5, 1, 1}
            }
            -- Create a simple yellow texture for highlighting
            local highlightTexture = love.graphics.newCanvas(1, 1)
            love.graphics.setCanvas(highlightTexture)
            love.graphics.setColor(1, 1, 0, 0.25)  -- Reduced from 0.5 to 0.25 (50% less impact)
            love.graphics.rectangle("fill", 0, 0, 1, 1)
            love.graphics.setCanvas()
            love.graphics.setColor(1, 1, 1, 1)
            
            local highlightModel = g3d.newModel(highlightVertices, highlightTexture, {0, 0, 0}, nil, {1, 1, 1})
            highlightModel:draw()
        elseif selectedTile.type == "wall" then
            -- Highlight entire wall surface (not just hit point)
            local highlightVertices = {}
            
            if selectedTile.direction == "north" then
                -- North wall (facing south, at Z = gridY - 0.5) - highlight entire wall
                local z = selectedTile.y - 0.5
                highlightVertices = {
                    {selectedTile.x - 0.5, 1.0, z, 0, 0},
                    {selectedTile.x + 0.5, 1.0, z, 1, 0},
                    {selectedTile.x + 0.5, 0.0, z, 1, 1},
                    {selectedTile.x - 0.5, 0.0, z, 0, 1},
                    {selectedTile.x - 0.5, 1.0, z, 0, 0},
                    {selectedTile.x + 0.5, 0.0, z, 1, 1}
                }
            elseif selectedTile.direction == "south" then
                -- South wall (facing north, at Z = gridY + 0.5) - highlight entire wall
                local z = selectedTile.y + 0.5
                highlightVertices = {
                    {selectedTile.x + 0.5, 1.0, z, 0, 0},
                    {selectedTile.x - 0.5, 1.0, z, 1, 0},
                    {selectedTile.x - 0.5, 0.0, z, 1, 1},
                    {selectedTile.x + 0.5, 0.0, z, 0, 1},
                    {selectedTile.x + 0.5, 1.0, z, 0, 0},
                    {selectedTile.x - 0.5, 0.0, z, 1, 1}
                }
            elseif selectedTile.direction == "east" then
                -- East wall (facing west, at X = gridX + 0.5) - highlight entire wall
                local x = selectedTile.x + 0.5
                highlightVertices = {
                    {x, 1.0, selectedTile.y + 0.5, 0, 0},
                    {x, 1.0, selectedTile.y - 0.5, 1, 0},
                    {x, 0.0, selectedTile.y - 0.5, 1, 1},
                    {x, 0.0, selectedTile.y + 0.5, 0, 1},
                    {x, 1.0, selectedTile.y + 0.5, 0, 0},
                    {x, 0.0, selectedTile.y - 0.5, 1, 1}
                }
            elseif selectedTile.direction == "west" then
                -- West wall (facing east, at X = gridX - 0.5) - highlight entire wall
                local x = selectedTile.x - 0.5
                highlightVertices = {
                    {x, 1.0, selectedTile.y - 0.5, 0, 0},
                    {x, 1.0, selectedTile.y + 0.5, 1, 0},
                    {x, 0.0, selectedTile.y + 0.5, 1, 1},
                    {x, 0.0, selectedTile.y - 0.5, 0, 1},
                    {x, 1.0, selectedTile.y - 0.5, 0, 0},
                    {x, 0.0, selectedTile.y + 0.5, 1, 1}
                }
            end
            
            -- Create a simple red texture for wall highlighting
            local highlightTexture = love.graphics.newCanvas(1, 1)
            love.graphics.setCanvas(highlightTexture)
            love.graphics.setColor(1, 0, 0, 0.4)  -- Reduced from 0.8 to 0.4 (50% less impact)
            love.graphics.rectangle("fill", 0, 0, 1, 1)
            love.graphics.setCanvas()
            love.graphics.setColor(1, 1, 1, 1)
            
            local highlightModel = g3d.newModel(highlightVertices, highlightTexture, {0, 0, 0}, nil, {1, 1, 1})
            highlightModel:draw()
        end
        love.graphics.setDepthMode("lequal", true)
    end

    -- Draw highlighted selected enemy
    if selectedEnemy then
        love.graphics.setDepthMode("always", false)
        -- Highlight enemy with a 3D bounding box outline
        local enemy = selectedEnemy
        
        -- Create a simple green texture for enemy highlighting
        local highlightTexture = love.graphics.newCanvas(1, 1)
        love.graphics.setCanvas(highlightTexture)
        love.graphics.setColor(0, 1, 0, 0.3)  -- Green highlight for enemies
        love.graphics.rectangle("fill", 0, 0, 1, 1)
        love.graphics.setCanvas()
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Create highlight vertices for enemy bounding box (slightly larger than actual enemy)
        local highlightVertices = {
            -- Front face
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z + 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z + 0.5, 1, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z + 0.5, 1, 1},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z + 0.5, 0, 1},
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z + 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z + 0.5, 1, 1},
            
            -- Back face
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z - 0.5, 0, 0},
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z - 0.5, 1, 0},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z - 0.5, 1, 1},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z - 0.5, 0, 1},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z - 0.5, 0, 0},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z - 0.5, 1, 1},
            
            -- Right face
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z + 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z - 0.5, 1, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z - 0.5, 1, 1},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z + 0.5, 0, 1},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z + 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z - 0.5, 1, 1},
            
            -- Left face
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z - 0.5, 0, 0},
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z + 0.5, 1, 0},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z + 0.5, 1, 1},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z - 0.5, 0, 1},
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z - 0.5, 0, 0},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z + 0.5, 1, 1},
            
            -- Top face
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z - 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z - 0.5, 1, 0},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z + 0.5, 1, 1},
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z + 0.5, 0, 1},
            {enemy.x - 0.5, enemy.y + 0.8, enemy.z - 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y + 0.8, enemy.z + 0.5, 1, 1},
            
            -- Bottom face
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z + 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z + 0.5, 1, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z - 0.5, 1, 1},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z - 0.5, 0, 1},
            {enemy.x - 0.5, enemy.y - 0.3, enemy.z + 0.5, 0, 0},
            {enemy.x + 0.5, enemy.y - 0.3, enemy.z - 0.5, 1, 1}
        }
        
        local highlightModel = g3d.newModel(highlightVertices, highlightTexture, {0, 0, 0}, nil, {1, 1, 1})
        highlightModel:draw()
        love.graphics.setDepthMode("lequal", true)
    end

    -- Draw smoke particles (with depth testing)
    if particlesEnabled then
        for _, particle in ipairs(smokeParticles) do
            local dist = math.sqrt((particle.x - player.x)^2 + (particle.z - player.z)^2)
            if dist < 20 then
                local screenX, screenY, scale, visible = worldToScreen(particle.x, particle.y, particle.z)
                if visible then
                    -- Only draw if particle is in front of walls (simple check)
                    local gridX = math.floor(particle.x + 0.5)
                    local gridY = math.floor(particle.z + 0.5)
                    if gridX >= 1 and gridX <= mazeSize and gridY >= 1 and gridY <= mazeSize then
                        -- Check if there's a wall between particle and player
                        local particleHeight = particle.y
                        if particleHeight > 0.5 then  -- Only show particles above floor level
                            love.graphics.setColor(0.5, 0.5, 0.5, particle.alpha)
                            love.graphics.circle("fill", screenX, screenY, particle.size * 100 * scale)
                        end
                    end
                end
            end
        end
    end
    
    -- Draw fire particles (with depth testing)
    if particlesEnabled then
        for _, particle in ipairs(fireParticles) do
            local dist = math.sqrt((particle.x - player.x)^2 + (particle.z - player.z)^2)
            if dist < 20 then
                local screenX, screenY, scale, visible = worldToScreen(particle.x, particle.y, particle.z)
                if visible then
                    -- Only draw if particle is in front of walls
                    local gridX = math.floor(particle.x + 0.5)
                    local gridY = math.floor(particle.z + 0.5)
                    if gridX >= 1 and gridX <= mazeSize and gridY >= 1 and gridY <= mazeSize then
                        local particleHeight = particle.y
                        if particleHeight > 0.5 then  -- Only show particles above floor level
                            local r = 1.0
                            local g = 0.3 + particle.color * 0.4
                            local b = 0.0
                            love.graphics.setColor(r, g, b, particle.alpha)
                            love.graphics.circle("fill", screenX, screenY, particle.size * 80 * scale)
                            
                            love.graphics.setColor(r, g, b, particle.alpha * 0.4)
                            love.graphics.circle("fill", screenX, screenY, particle.size * 150 * scale)
                        end
                    end
                end
            end
        end
    end

    -- Draw rain if enabled (screen-space effect)
    if isRaining then
        love.graphics.setColor(0.7, 0.8, 1.0, 0.6)  -- Light blue rain drops
        for _, drop in ipairs(rainDrops) do
            -- Draw rain as screen-space lines falling from top
            local screenX = drop.x
            local startY = drop.y
            local endY = drop.y + drop.length
            
            love.graphics.line(screenX, startY, screenX, endY)
        end
    end
    
    -- Draw snow if enabled (screen-space effect)
    if isSnowing then
        love.graphics.setColor(1.0, 1.0, 1.0, 0.8)  -- White snow flakes
        for _, flake in ipairs(snowFlakes) do
            -- Draw snow flake as a small circle on screen
            love.graphics.circle("fill", flake.x, flake.y, flake.size)
        end
    end

    love.graphics.setDepthMode()
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Recording indicator
    if isRecording then
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.rectangle("fill", 10, 10, 200, 30)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("REC [" .. recordingFrameCount .. " frames]", 15, 15)
    end
    
    -- Minimap - show 3 tiles around player + tiles visible in 3D view
    local minimapSize = 200
    local minimapX = 20
    local minimapY = 20
    local alwaysVisibleRadius = 3  -- 3 tiles in all directions (7x7 area)
    local viewDistance = isNight and 10 or 20  -- 20 tiles day, 10 tiles night
    local viewAngle = math.pi / 4  -- ±45 degrees (90 degree cone total)
    local maxRange = math.max(alwaysVisibleRadius, viewDistance)
    local scale = minimapSize / (maxRange * 2 + 1)
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", minimapX, minimapY, minimapSize, minimapSize)
    
    -- Function to check if a tile is visible on minimap
    local function isTileVisibleOnMinimap(tx, ty)
        local currentPlayer = getCurrentPlayer()
        local dx = tx - currentPlayer.gridX
        local dy = ty - currentPlayer.gridY
        local distance = math.sqrt(dx*dx + dy*dy)
        
        -- Always visible within 3 tiles
        if distance <= alwaysVisibleRadius then
            return true
        end
        
        -- Check if within viewing distance and angle
        if distance <= viewDistance then
            -- Calculate angle to tile relative to player's facing direction
            -- Player faces (sin(angle), 0, -cos(angle)) when angle=0
            local facingX = math.sin(player.angle)
            local facingZ = -math.cos(player.angle)
            local tileX = dx
            local tileZ = dy  -- dy is in Z direction in our coordinate system
            
            -- Dot product to find angle between facing direction and tile direction
            local dot = facingX * tileX + facingZ * tileZ
            local facingMag = math.sqrt(facingX*facingX + facingZ*facingZ)
            local tileMag = math.sqrt(tileX*tileX + tileZ*tileZ)
            local cosAngle = dot / (facingMag * tileMag)
            cosAngle = math.max(-1, math.min(1, cosAngle))  -- Clamp to avoid floating point errors
            local angleToTile = math.acos(cosAngle)
            
            -- Within ±45 degrees of facing direction
            if angleToTile <= viewAngle then
                return true
            end
        end
        
        return false
    end
    
    -- Draw visible portion of maze with terrain colors
    local currentPlayer = getCurrentPlayer()
    local startX = math.max(1, currentPlayer.gridX - maxRange)
    local endX = math.min(mazeSize, currentPlayer.gridX + maxRange)
    local startY = math.max(1, currentPlayer.gridY - maxRange)
    local endY = math.min(mazeSize, currentPlayer.gridY + maxRange)
    
    for y = startY, endY do
        for x = startX, endX do
            if isTileVisibleOnMinimap(x, y) then
                local terrain = maze[y][x].terrain
                local color = TERRAIN_COLORS[terrain] or {0, 0, 0}
                love.graphics.setColor(color[1], color[2], color[3], 0.9)
                
                -- Position relative to minimap center
                local relX = x - currentPlayer.gridX
                local relY = y - currentPlayer.gridY
                love.graphics.rectangle("fill", 
                    minimapX + minimapSize/2 + relX * scale - scale/2, 
                    minimapY + minimapSize/2 + relY * scale - scale/2, 
                    scale, scale)
            end
        end
    end
    
    -- Draw white outline on top of tiles
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", minimapX, minimapY, minimapSize, minimapSize)

    -- Draw player in center of minimap
    local currentPlayer = getCurrentPlayer()
    love.graphics.setColor(0, 1, 0, 1)  -- Green for current player
    love.graphics.circle("fill", minimapX + minimapSize/2, minimapY + minimapSize/2, scale * 0.3)

    -- Draw other player units as green dots on minimap
    love.graphics.setColor(0, 1, 0, 1)  -- Green for other player units
    for i, playerUnit in ipairs(playerUnits) do
        if i ~= currentPlayerIndex then  -- Don't draw current player unit (already drawn as green)
            local relX = playerUnit.gridX - currentPlayer.gridX
            local relY = playerUnit.gridY - currentPlayer.gridY
            local distance = math.sqrt(relX^2 + relY^2)
            -- Only draw player units within minimap visibility
            if distance <= maxRange and isTileVisibleOnMinimap(playerUnit.gridX, playerUnit.gridY) then
                local unitX = minimapX + minimapSize/2 + relX * scale
                local unitY = minimapY + minimapSize/2 + relY * scale
                love.graphics.circle("fill", unitX, unitY, scale * 0.25)
            end
        end
    end

    -- Draw enemy units as red dots on minimap
    love.graphics.setColor(1, 0, 0, 1)
    for _, enemy in ipairs(enemyUnits) do
        local relX = enemy.gridX - currentPlayer.gridX
        local relY = enemy.gridY - currentPlayer.gridY
        local distance = math.sqrt(relX^2 + relY^2)
        -- Only draw enemies within minimap visibility
        if distance <= maxRange and isTileVisibleOnMinimap(enemy.gridX, enemy.gridY) then
            local enemyX = minimapX + minimapSize/2 + relX * scale
            local enemyY = minimapY + minimapSize/2 + relY * scale
            love.graphics.circle("fill", enemyX, enemyY, scale * 0.3)
        end
    end

    -- Draw facing direction
    love.graphics.setColor(1, 0, 0, 1)
    local centerX = minimapX + minimapSize/2
    local centerY = minimapY + minimapSize/2
    love.graphics.line(centerX, centerY, centerX + math.sin(currentPlayer.angle) * scale * 0.8, centerY - math.cos(currentPlayer.angle) * scale * 0.8)

    love.graphics.setColor(1, 1, 1)
end

function love.mousemoved(x, y, dx, dy)
    mouseX, mouseY = x, y
end

function love.resize(w, h)
    -- Reinitialize rain and snow particles to cover the new screen size
    if isRaining then
        for i = 1, maxRainDrops do
            rainDrops[i] = {
                x = math.random(0, w),
                y = math.random(0, h),
                speed = math.random(200, 400),
                length = math.random(10, 20)
            }
        end
    end
    
    if isSnowing then
        for i = 1, maxSnowFlakes do
            snowFlakes[i] = {
                x = math.random(0, w),
                y = math.random(0, h),
                speed = math.random(20, 50),
                drift = math.random(-10, 10),
                size = math.random(2, 5)
            }
        end
    end
end
