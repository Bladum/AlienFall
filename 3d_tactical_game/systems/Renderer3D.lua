--- Renderer3D System
--- Handles 3D rendering of tiles, units, and effects using G3D
--- Respects team-based visibility for fog of war

local g3d = require("g3d.g3d")
local Constants = require("config.constants")
local Colors = require("config.colors")
local VisibilitySystem = require("systems.VisibilitySystem")

--- @class Renderer3D
local Renderer3D = {}

-- Private state
local floorModel = nil
local wallModel = nil
local unitModel = nil
local textures = {}
local initialized = false

--- Initialize the renderer
--- Loads textures and creates G3D models
function Renderer3D.init()
    print("Renderer3D: Initializing...")
    
    -- Load textures
    Renderer3D.loadTextures()
    
    -- Create models
    Renderer3D.createModels()
    
    initialized = true
    print("Renderer3D: Initialization complete")
end

--- Load textures from assets folder
function Renderer3D.loadTextures()
    print("Renderer3D: Loading textures...")
    
    -- Try to load tile textures
    local textureFiles = {
        ["grass"] = "assets/tiles/grass.png",
        ["stone_floor"] = "assets/tiles/stone floor.png",
        ["stone_wall"] = "assets/tiles/stone wall.png",
        ["wood_wall"] = "assets/tiles/wood wall.png",
        ["wood_door"] = "assets/tiles/wood door.png",
        ["player"] = "assets/tiles/player.png",
        ["enemy"] = "assets/tiles/enemy.png",
    }
    
    for name, path in pairs(textureFiles) do
        local success, texture = pcall(love.graphics.newImage, path)
        if success then
            textures[name] = texture
            print(string.format("  Loaded: %s (type: %s)", name, type(texture)))
        else
            print(string.format("  Missing: %s (will use solid color)", name))
            -- Create a simple colored texture as fallback
            textures[name] = Renderer3D.createColorTexture(1, 1, 1, 1)
        end
    end
    
    print("Renderer3D: Checking textures table:")
    for k, v in pairs(textures) do
        print(string.format("  %s = %s", k, type(v)))
    end
end

--- Create a simple solid color texture
--- @param r number Red (0-1)
--- @param g number Green (0-1)
--- @param b number Blue (0-1)
--- @param a number Alpha (0-1)
--- @return table texture Love2D texture
function Renderer3D.createColorTexture(r, g, b, a)
    local imageData = love.image.newImageData(16, 16)
    imageData:mapPixel(function(x, y)
        return r, g, b, a
    end)
    return love.graphics.newImage(imageData)
end

--- Create G3D models for rendering
function Renderer3D.createModels()
    print("Renderer3D: Creating models...")
    
    -- Floor model (horizontal quad, 1x1 tile)
    -- Convert indexed vertices to triangles
    local floorVerts = {
        {-0.5, 0, -0.5,  0, 0,  0, 1, 0},  -- Top-left
        { 0.5, 0, -0.5,  1, 0,  0, 1, 0},  -- Top-right
        { 0.5, 0,  0.5,  1, 1,  0, 1, 0},  -- Bottom-right
        {-0.5, 0,  0.5,  0, 1,  0, 1, 0},  -- Bottom-left
    }
    floorModel = g3d.newModel({
        floorVerts[1], floorVerts[2], floorVerts[3],  -- Triangle 1
        floorVerts[1], floorVerts[3], floorVerts[4],  -- Triangle 2
    }, textures.grass)
    print(string.format("  Floor model: %s", tostring(floorModel)))
    
    -- Wall model (vertical quad, 1 unit tall)
    local wallVerts = {
        {-0.5, 0, 0,  0, 1,  0, 0, -1},  -- Bottom-left
        { 0.5, 0, 0,  1, 1,  0, 0, -1},  -- Bottom-right
        { 0.5, 1, 0,  1, 0,  0, 0, -1},  -- Top-right
        {-0.5, 1, 0,  0, 0,  0, 0, -1},  -- Top-left
    }
    wallModel = g3d.newModel({
        wallVerts[1], wallVerts[2], wallVerts[3],  -- Triangle 1
        wallVerts[1], wallVerts[3], wallVerts[4],  -- Triangle 2
    }, textures.stone_wall)
    print(string.format("  Wall model: %s", tostring(wallModel)))
    
    -- Unit model (billboard quad, 0.8 units tall)
    local unitVerts = {
        {-0.4, 0,    0,  0, 1,  0, 0, -1},  -- Bottom-left
        { 0.4, 0,    0,  1, 1,  0, 0, -1},  -- Bottom-right
        { 0.4, 0.8,  0,  1, 0,  0, 0, -1},  -- Top-right
        {-0.4, 0.8,  0,  0, 0,  0, 0, -1},  -- Top-left
    }
    unitModel = g3d.newModel({
        unitVerts[1], unitVerts[2], unitVerts[3],  -- Triangle 1
        unitVerts[1], unitVerts[3], unitVerts[4],  -- Triangle 2
    }, textures.player)
    print(string.format("  Unit model: %s", tostring(unitModel)))
    
    print("Renderer3D: Models created")
end

--- Render the entire game world
--- @param map table 2D array of Tile objects [y][x]
--- @param teams table Array of Team objects
--- @param viewerTeamId number Team ID for visibility (usually player team)
--- @param gridWidth number Map width
--- @param gridHeight number Map height
function Renderer3D.render(map, teams, viewerTeamId, gridWidth, gridHeight)
    if not initialized then
        Renderer3D.init()
    end
    
    -- Set up 3D rendering
    g3d.camera:updateViewMatrix()
    love.graphics.setDepthMode("lequal", true)
    
    print("RENDERING: " .. gridWidth .. "x" .. gridHeight .. " map")
    
    -- Render tiles
    Renderer3D.renderTiles(map, viewerTeamId, gridWidth, gridHeight)
    
    -- Render units
    Renderer3D.renderUnits(teams, map, viewerTeamId)
    
    -- Clean up 3D state
    love.graphics.setDepthMode()
end

--- Render all visible tiles
--- @param map table Map object with tiles, width, height
--- @param viewerTeamId number Team ID for visibility
--- @param gridWidth number Map width
--- @param gridHeight number Map height
function Renderer3D.renderTiles(map, viewerTeamId, gridWidth, gridHeight)
    local tiles = map.tiles or map  -- Support both map object and legacy 2D array
    
    local visibleCount = 0
    local floorCount = 0
    local wallCount = 0
    
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local tile = tiles[y][x]
            
            -- Get brightness based on visibility
            local brightness = VisibilitySystem.getBrightness(tile, viewerTeamId)
            
            -- Skip completely hidden tiles
            if brightness > 0 then
                visibleCount = visibleCount + 1
                if tile.terrainType == Constants.TERRAIN.FLOOR then
                    floorCount = floorCount + 1
                elseif tile.terrainType == Constants.TERRAIN.WALL then
                    wallCount = wallCount + 1
                end
                Renderer3D.renderTile(tile, brightness)
            end
        end
    end
    
    -- print(string.format("  Rendered %d visible tiles (%d floors, %d walls)", visibleCount, floorCount, wallCount))
end

--- Render a single tile
--- @param tile table Tile object
--- @param brightness number Brightness multiplier (0-1)
function Renderer3D.renderTile(tile, brightness)
    if not floorModel or not wallModel then
        print("ERROR: Models not initialized!")
        return
    end
    
    -- Set color with brightness
    love.graphics.setColor(brightness, brightness, brightness, 1)
    
    -- Render floor
    if tile.terrainType == Constants.TERRAIN.FLOOR or 
       tile.terrainType == Constants.TERRAIN.DOOR then
        -- Position floor at tile center
        floorModel:setTransform(
            {tile.gridX, 0, tile.gridY},  -- Position
            {0, 0, 0},                    -- Rotation
            {1, 1, 1}                     -- Scale
        )
        floorModel:draw()
    end
    
    -- Render wall
    if tile.terrainType == Constants.TERRAIN.WALL then
        -- Position wall at tile center, raised up
        wallModel:setTransform(
            {tile.gridX, 0, tile.gridY},
            {0, 0, 0},
            {1, 1, 1}
        )
        wallModel:draw()
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

--- Get texture for a terrain type
--- @param terrainType number Terrain type constant
--- @return table texture Love2D texture
function Renderer3D.getTerrainTexture(terrainType)
    if terrainType == Constants.TERRAIN.FLOOR then
        return textures["grass"] or textures["stone_floor"]
    elseif terrainType == Constants.TERRAIN.WALL then
        return textures["stone_wall"]
    elseif terrainType == Constants.TERRAIN.DOOR then
        return textures["wood_door"]
    end
    
    -- Fallback
    return textures["grass"]
end

--- Render all visible units
--- @param teams table Array of Team objects
--- @param map table 2D array of Tile objects
--- @param viewerTeamId number Team ID for visibility
function Renderer3D.renderUnits(teams, map, viewerTeamId)
    local renderedCount = 0
    for _, team in pairs(teams) do
        for _, unit in ipairs(team:getUnits()) do
            if unit:isAlive() then
                -- Check if unit's tile is visible
                local tiles = map.tiles or map  -- Support both map object and legacy 2D array
                local tile = tiles[unit.gridY] and tiles[unit.gridY][unit.gridX]
                if tile and VisibilitySystem.isVisibleToTeam(tiles, unit.gridX, unit.gridY, viewerTeamId) then
                    Renderer3D.renderUnit(unit, team)
                    renderedCount = renderedCount + 1
                end
            end
        end
    end
    -- print(string.format("  Rendered %d units", renderedCount))
end

--- Render a single unit as a billboard
--- @param unit table Unit object
--- @param team table Team object
function Renderer3D.renderUnit(unit, team)
    -- Get team color
    local teamColor = team.color or {1, 1, 1}
    
    -- Get unit world position (with interpolation)
    local pos = unit:getPosition()
    
    -- Set color based on team
    love.graphics.setColor(teamColor[1], teamColor[2], teamColor[3], 1)
    
    -- Make billboard face camera
    local camX, camY, camZ = g3d.camera.position[1], g3d.camera.position[2], g3d.camera.position[3]
    local dx = camX - pos.x
    local dz = camZ - pos.z
    local angle = math.atan2(dx, dz)
    
    -- Position and rotate unit model
    unitModel:setTransform(
        {pos.x, pos.y, pos.z},
        {0, angle, 0},
        {1, 1, 1}
    )
    
    unitModel:draw()
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
    
    -- TODO: Add health bar, selection indicator
end

--- Render a simple sky gradient
function Renderer3D.renderSky()
    -- Simple gradient background
    love.graphics.clear(0.4, 0.6, 0.9, 1)  -- Sky blue
end

--- Update camera to follow a unit
--- @param unit table Unit to follow (can be nil)
--- @param dt number Delta time
function Renderer3D.updateCamera(unit, dt)
    if not unit then return end
    
    local pos = unit:getPosition()
    
    -- Camera position: behind and above the unit
    local cameraDistance = 15
    local cameraHeight = 10
    
    -- Calculate desired camera position
    local targetCamX = pos.x
    local targetCamY = cameraHeight
    local targetCamZ = pos.z + cameraDistance
    
    -- Smooth camera movement (lerp)
    local smoothing = 5 * dt
    
    -- Get current camera position
    local camX = g3d.camera.position[1] or targetCamX
    local camY = g3d.camera.position[2] or targetCamY
    local camZ = g3d.camera.position[3] or targetCamZ
    
    -- Lerp to target position
    g3d.camera.position[1] = camX + (targetCamX - camX) * smoothing
    g3d.camera.position[2] = camY + (targetCamY - camY) * smoothing
    g3d.camera.position[3] = camZ + (targetCamZ - camZ) * smoothing
    
    -- Look at unit position
    g3d.camera.target[1] = pos.x
    g3d.camera.target[2] = pos.y + 0.5
    g3d.camera.target[3] = pos.z
    
    -- Update view matrix
    g3d.camera:updateViewMatrix()
end

--- Render 2D UI overlay (HUD)
--- @param selectedUnit table Currently selected unit
--- @param team table Current team
function Renderer3D.renderUI(selectedUnit, team)
    -- Switch to 2D rendering
    love.graphics.setColor(1, 1, 1, 1)
    
    local uiY = 10
    
    -- Team info
    if team then
        love.graphics.print(string.format("Team: %s", team.name or "Unknown"), 10, uiY)
        uiY = uiY + 20
        love.graphics.print(string.format("Units: %d", team:getUnitCount()), 10, uiY)
        uiY = uiY + 20
    end
    
    -- Selected unit info
    if selectedUnit then
        uiY = uiY + 10
        love.graphics.print(string.format("Selected Unit:"), 10, uiY)
        uiY = uiY + 20
        love.graphics.print(string.format("  Position: (%d, %d)", 
                                         selectedUnit.gridX, selectedUnit.gridY), 10, uiY)
        uiY = uiY + 20
        love.graphics.print(string.format("  Health: %d/%d", 
                                         selectedUnit.health, selectedUnit.maxHealth), 10, uiY)
        uiY = uiY + 20
    end
    
    -- Instructions
    love.graphics.print("Controls: WASD=Move, SPACE=Next Unit, ESC=Quit", 10, love.graphics.getHeight() - 30)
end

--- Cleanup resources
function Renderer3D.cleanup()
    -- G3D handles cleanup automatically
    initialized = false
    print("Renderer3D: Cleanup complete")
end

return Renderer3D
