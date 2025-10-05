-- Raycasting Demo with Textured Polygons
-- First-person 3D view with textured walls using polygons

local RaycasterDemo = {}

-- Game state
local map = {}
local mapWidth = 32
local mapHeight = 32
local player = {
    x = 2.5,  -- Grid position
    y = 2.5,
    dir = 0,  -- Direction in degrees (0, 90, 180, 270)
}

-- Wall colors for different types (RGB values)
local wallColors = {
    [1] = {0.7, 0.3, 0.3},  -- Red walls
    [2] = {0.3, 0.7, 0.3},  -- Green walls
    [3] = {0.3, 0.3, 0.7},  -- Blue walls
    [4] = {0.7, 0.7, 0.3},  -- Yellow walls
    [5] = {0.7, 0.3, 0.7},  -- Magenta walls
}

-- Display constants
local screenWidth = 800
local screenHeight = 600
local minimapSize = 200
local minimapCellSize = minimapSize / mapWidth

-- Raycasting constants
local FOV = math.pi / 2  -- 90 degrees field of view (wider for better visibility)
local HALF_FOV = FOV / 2
local NUM_RAYS = screenWidth
local DELTA_ANGLE = FOV / NUM_RAYS
local MAX_DEPTH = 20
local WALL_HEIGHT = 300  -- Base wall height in pixels
local DISTANCE_SCALE = 60  -- Scale factor for distance calculation

-- Textures
local wallTexture
local floorTexture

-- Initialize the demo
function RaycasterDemo.load()
    -- Create an open maze with some strategic walls for corridors and rooms (1 = wall, 0 = floor)
    map = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,0,0,0,0,0,3,3,3,3,0,0,0,0,0,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,0,0,0,0,0,3,0,0,3,0,0,0,0,0,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,0,0,0,0,0,3,0,0,3,0,0,0,0,0,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,0,0,0,0,0,3,3,3,3,0,0,0,0,0,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
    }

    -- Create simple textures
    wallTexture = love.graphics.newCanvas(64, 64)
    love.graphics.setCanvas(wallTexture)
    love.graphics.clear(0.7, 0.5, 0.3)  -- Brown wall
    love.graphics.setColor(0.8, 0.6, 0.4)
    for i = 0, 63, 8 do
        love.graphics.rectangle("fill", i, 0, 4, 64)
    end
    love.graphics.setCanvas()

    floorTexture = love.graphics.newCanvas(64, 64)
    love.graphics.setCanvas(floorTexture)
    love.graphics.clear(0.4, 0.8, 0.4)  -- Green floor
    love.graphics.setColor(0.5, 0.9, 0.5)
    for i = 0, 63, 16 do
        for j = 0, 63, 16 do
            love.graphics.rectangle("fill", i, j, 8, 8)
        end
    end
    love.graphics.setCanvas()
end

-- Get map cell value
local function getMapCell(x, y)
    if x < 1 or x > mapWidth or y < 1 or y > mapHeight then
        return 1  -- Out of bounds is wall
    end
    return map[math.floor(y)][math.floor(x)]
end

-- Cast a ray using DDA algorithm and return distance to wall, wall type, and side
local function castRay(angle)
    local sin = math.sin(angle)
    local cos = math.cos(angle)
    
    local x = player.x
    local y = player.y
    
    local mapX = math.floor(x)
    local mapY = math.floor(y)
    
    local deltaDistX = math.abs(1 / cos)
    local deltaDistY = math.abs(1 / sin)
    
    local stepX, stepY
    local sideDistX, sideDistY
    
    if cos < 0 then
        stepX = -1
        sideDistX = (x - mapX) * deltaDistX
    else
        stepX = 1
        sideDistX = (mapX + 1 - x) * deltaDistX
    end
    
    if sin < 0 then
        stepY = -1
        sideDistY = (y - mapY) * deltaDistY
    else
        stepY = 1
        sideDistY = (mapY + 1 - y) * deltaDistY
    end
    
    local hit = false
    local side = 0  -- 0 for x-side, 1 for y-side
    local wallType = 0
    
    while not hit and sideDistX < MAX_DEPTH and sideDistY < MAX_DEPTH do
        if sideDistX < sideDistY then
            sideDistX = sideDistX + deltaDistX
            mapX = mapX + stepX
            side = 0
        else
            sideDistY = sideDistY + deltaDistY
            mapY = mapY + stepY
            side = 1
        end
        
        local cell = getMapCell(mapX, mapY)
        if cell > 0 then
            hit = true
            wallType = cell
        end
    end
    
    if hit then
        local distance
        if side == 0 then
            distance = sideDistX - deltaDistX
        else
            distance = sideDistY - deltaDistY
        end
        return distance, wallType, side
    else
        return MAX_DEPTH, 0, 0
    end
end

-- Draw the first-person 3D view with colored polygons
local function draw3DView()
    -- Draw ceiling (darker gray-blue)
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle('fill', 0, 0, screenWidth, screenHeight / 2)
    
    -- Draw floor (darker gray-brown)
    love.graphics.setColor(0.3, 0.25, 0.2)
    love.graphics.rectangle('fill', 0, screenHeight / 2, screenWidth, screenHeight / 2)
    
    -- Cast rays for walls
    local startAngle = math.rad(player.dir) - HALF_FOV
    
    for ray = 0, NUM_RAYS - 1 do
        local angle = startAngle + ray * DELTA_ANGLE
        local distance, wallType, side = castRay(angle)
        
        if distance < MAX_DEPTH and wallType > 0 then
            -- Fix fish-eye effect
            local correctedDistance = distance * math.cos(angle - math.rad(player.dir))
            
            -- Calculate wall height on screen (closer = taller)
            local projectionHeight = (DISTANCE_SCALE * WALL_HEIGHT) / correctedDistance
            local wallTop = (screenHeight - projectionHeight) / 2
            local wallBottom = wallTop + projectionHeight
            
            -- Get base color for this wall type
            local baseColor = wallColors[wallType] or {0.5, 0.5, 0.5}
            
            -- Apply shading based on side (x-sides darker than y-sides for depth perception)
            local shadeFactor = (side == 0) and 0.7 or 1.0
            
            -- Apply distance fog (further = darker)
            local fogFactor = math.max(0.3, 1.0 - (distance / MAX_DEPTH) * 0.7)
            
            -- Calculate final color
            local r = baseColor[1] * shadeFactor * fogFactor
            local g = baseColor[2] * shadeFactor * fogFactor
            local b = baseColor[3] * shadeFactor * fogFactor
            
            -- Screen position
            local screenX = ray
            local wallWidth = 1  -- 1 pixel wide strip
            
            -- Draw wall strip as colored polygon
            love.graphics.setColor(r, g, b)
            love.graphics.rectangle('fill', screenX, wallTop, wallWidth, projectionHeight)
        end
    end
end

-- Draw the 2D minimap
local function drawMinimap()
    -- Draw semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', 10, 10, minimapSize, minimapSize)
    
    -- Draw map cells
    for y = 1, mapHeight do
        for x = 1, mapWidth do
            local cellX = 10 + (x - 1) * minimapCellSize
            local cellY = 10 + (y - 1) * minimapCellSize
            
            if map[y][x] == 1 then
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.rectangle('fill', cellX, cellY, minimapCellSize, minimapCellSize)
            else
                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle('fill', cellX, cellY, minimapCellSize, minimapCellSize)
            end
            
            -- Grid lines
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle('line', cellX, cellY, minimapCellSize, minimapCellSize)
        end
    end
    
    -- Draw player (centered in the cell)
    local playerScreenX = 10 + (player.x - 1) * minimapCellSize
    local playerScreenY = 10 + (player.y - 1) * minimapCellSize
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle('fill', playerScreenX, playerScreenY, 4)
    
    -- Draw player direction
    local dirLength = 12
    local dirX = playerScreenX + math.cos(math.rad(player.dir)) * dirLength
    local dirY = playerScreenY + math.sin(math.rad(player.dir)) * dirLength
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.setLineWidth(2)
    love.graphics.line(playerScreenX, playerScreenY, dirX, dirY)
    love.graphics.setLineWidth(1)
    
    -- Border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', 10, 10, minimapSize, minimapSize)
end

-- Update function
function RaycasterDemo.update(dt)
    -- Movement is handled in keypressed
end

-- Draw function
function RaycasterDemo.draw()
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Draw 3D view (includes floor, ceiling, and walls)
    draw3DView()
    
    -- Draw minimap
    drawMinimap()
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("WASD: Move | Q/E: Rotate 90° | ESC: Exit", 10, screenHeight - 30)
    love.graphics.print(string.format("Pos: (%.1f, %.1f) Dir: %d°", player.x, player.y, player.dir), 10, screenHeight - 50)
end

-- Handle key presses
function RaycasterDemo.keypressed(key)
    if key == 'w' then
        -- Move forward
        local newX = player.x + math.cos(math.rad(player.dir))
        local newY = player.y + math.sin(math.rad(player.dir))
        
        if getMapCell(math.floor(newX), math.floor(newY)) == 0 then
            player.x = newX
            player.y = newY
        end
    elseif key == 's' then
        -- Move backward
        local newX = player.x - math.cos(math.rad(player.dir))
        local newY = player.y - math.sin(math.rad(player.dir))
        
        if getMapCell(math.floor(newX), math.floor(newY)) == 0 then
            player.x = newX
            player.y = newY
        end
    elseif key == 'a' then
        -- Strafe left
        local newX = player.x + math.cos(math.rad(player.dir - 90))
        local newY = player.y + math.sin(math.rad(player.dir - 90))
        
        if getMapCell(math.floor(newX), math.floor(newY)) == 0 then
            player.x = newX
            player.y = newY
        end
    elseif key == 'd' then
        -- Strafe right
        local newX = player.x + math.cos(math.rad(player.dir + 90))
        local newY = player.y + math.sin(math.rad(player.dir + 90))
        
        if getMapCell(math.floor(newX), math.floor(newY)) == 0 then
            player.x = newX
            player.y = newY
        end
    elseif key == 'q' then
        -- Rotate left 90 degrees
        player.dir = (player.dir - 90) % 360
    elseif key == 'e' then
        -- Rotate right 90 degrees
        player.dir = (player.dir + 90) % 360
    elseif key == 'escape' then
        love.event.quit()
    end
end

return RaycasterDemo
