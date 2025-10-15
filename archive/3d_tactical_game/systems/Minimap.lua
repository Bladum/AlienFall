--- Minimap.lua
--- Renders a top-down 2D minimap overlay showing the tactical map, units, and visibility

local Minimap = {}

local Constants = require("config.constants")
local Colors = require("config.colors")

-- Minimap settings
local minimapSize = 200  -- Default size in pixels
local minimapPadding = 10
local minimapPosition = {x = 0, y = 0}  -- Top-left corner by default
local minimapScale = 1.0

-- Tile colors for minimap
local TILE_COLORS = {
    [Constants.TERRAIN.FLOOR] = {0.6, 0.6, 0.6, 1.0},     -- Gray
    [Constants.TERRAIN.WALL] = {0.2, 0.2, 0.2, 1.0},      -- Dark gray
    [Constants.TERRAIN.DOOR] = {0.5, 0.3, 0.1, 1.0},      -- Brown
}

-- Visibility colors for fog of war
local FOG_COLORS = {
    [Constants.VISIBILITY.HIDDEN] = {0, 0, 0, 0.9},        -- Almost black
    [Constants.VISIBILITY.EXPLORED] = {0, 0, 0, 0.5},      -- Dark overlay
    [Constants.VISIBILITY.VISIBLE] = {0, 0, 0, 0.0},       -- No overlay
}

--- Initialize the minimap
--- @param mapWidth number Width of the game map in tiles
--- @param mapHeight number Height of the game map in tiles
function Minimap.init(mapWidth, mapHeight)
    minimapSize = 200
    minimapScale = 1.0
    
    -- Position in top-right corner
    local screenW = love.graphics.getWidth()
    minimapPosition.x = screenW - minimapSize * minimapScale - minimapPadding
    minimapPosition.y = minimapPadding
    
    print(string.format("Minimap: Initialized %dx%d at (%d, %d)", 
        mapWidth, mapHeight, minimapPosition.x, minimapPosition.y))
end

--- Update minimap (called each frame)
--- @param dt number Delta time
function Minimap.update(dt)
    -- Update position if window resized
    local screenW = love.graphics.getWidth()
    minimapPosition.x = screenW - minimapSize * minimapScale - minimapPadding
end

--- Render the minimap overlay
--- @param game table The game state object
function Minimap.render(game)
    if not game.showMinimap then
        return
    end
    
    local map = game.map
    if not map then
        return
    end
    
    local mapWidth = map.width
    local mapHeight = map.height
    
    -- Calculate tile size on minimap
    local tileSize = math.min(minimapSize / mapWidth, minimapSize / mapHeight) * minimapScale
    local minimapWidth = mapWidth * tileSize
    local minimapHeight = mapHeight * tileSize
    
    -- Draw background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", minimapPosition.x, minimapPosition.y, minimapWidth, minimapHeight)
    
    -- Draw tiles
    for y = 1, mapHeight do
        for x = 1, mapWidth do
            local tile = map.tiles[y][x]
            local tileColor = TILE_COLORS[tile.terrainType] or {0.5, 0.5, 0.5, 1.0}
            
            -- Draw tile
            love.graphics.setColor(tileColor)
            local screenX = minimapPosition.x + (x - 1) * tileSize
            local screenY = minimapPosition.y + (y - 1) * tileSize
            love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
            
            -- Apply fog of war overlay
            local visibility = Minimap.getTileVisibility(tile, game)
            local fogColor = FOG_COLORS[visibility] or {0, 0, 0, 0}
            love.graphics.setColor(fogColor)
            love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
        end
    end
    
    -- Draw units
    Minimap.renderUnits(game, tileSize)
    
    -- Draw camera view indicator
    Minimap.renderCameraIndicator(game, tileSize)
    
    -- Draw border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", minimapPosition.x, minimapPosition.y, minimapWidth, minimapHeight)
    
    -- Draw minimap label
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Minimap (M to toggle)", minimapPosition.x, minimapPosition.y + minimapHeight + 5)
end

--- Render units on the minimap
--- @param game table The game state object
--- @param tileSize number Size of each tile on the minimap
function Minimap.renderUnits(game, tileSize)
    for teamId, team in pairs(game.teams) do
        for _, unit in ipairs(team.units) do
            -- Only show units that are visible to player
            local tile = game.map.tiles[unit.gridY][unit.gridX]
            local visibility = Minimap.getTileVisibility(tile, game)
            
            if visibility == Constants.VISIBILITY.VISIBLE then
                -- Determine unit color based on team
                local unitColor
                if teamId == Constants.TEAM.PLAYER then
                    unitColor = {0.2, 0.8, 0.2, 1.0}  -- Green
                elseif teamId == Constants.TEAM.ALLY then
                    unitColor = {0.2, 0.2, 0.8, 1.0}  -- Blue
                elseif teamId == Constants.TEAM.ENEMY then
                    unitColor = {0.8, 0.2, 0.2, 1.0}  -- Red
                else
                    unitColor = {0.8, 0.8, 0.2, 1.0}  -- Yellow
                end
                
                love.graphics.setColor(unitColor)
                local screenX = minimapPosition.x + (unit.gridX - 1) * tileSize + tileSize / 2
                local screenY = minimapPosition.y + (unit.gridY - 1) * tileSize + tileSize / 2
                local radius = math.max(2, tileSize * 0.3)
                love.graphics.circle("fill", screenX, screenY, radius)
                
                -- Highlight selected unit
                if unit == game.selectedUnit then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.circle("line", screenX, screenY, radius + 2)
                end
            end
        end
    end
end

--- Render camera view indicator (shows what the 3D camera is looking at)
--- @param game table The game state object
--- @param tileSize number Size of each tile on the minimap
function Minimap.renderCameraIndicator(game, tileSize)
    -- Draw a small indicator showing camera target position
    if g3d and g3d.camera then
        local targetX = g3d.camera.target[1]
        local targetZ = g3d.camera.target[3]
        
        -- Convert world coordinates to grid coordinates
        local gridX = math.floor(targetX + 0.5)
        local gridY = math.floor(targetZ + 0.5)
        
        -- Draw indicator
        love.graphics.setColor(1, 1, 0, 0.8)
        local screenX = minimapPosition.x + (gridX - 1) * tileSize + tileSize / 2
        local screenY = minimapPosition.y + (gridY - 1) * tileSize + tileSize / 2
        love.graphics.circle("line", screenX, screenY, tileSize * 0.5)
        
        -- Draw camera position
        local camX = g3d.camera.position[1]
        local camZ = g3d.camera.position[3]
        local camGridX = math.floor(camX + 0.5)
        local camGridY = math.floor(camZ + 0.5)
        
        local camScreenX = minimapPosition.x + (camGridX - 1) * tileSize + tileSize / 2
        local camScreenY = minimapPosition.y + (camGridY - 1) * tileSize + tileSize / 2
        
        -- Draw line from camera to target
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.line(camScreenX, camScreenY, screenX, screenY)
    end
end

--- Get visibility state for a tile
--- @param tile table The tile to check
--- @param game table The game state object
--- @return number Visibility constant
function Minimap.getTileVisibility(tile, game)
    local playerTeam = game.teams[Constants.TEAM.PLAYER]
    if not playerTeam then
        return Constants.VISIBILITY.HIDDEN
    end
    
    -- Check team visibility
    return tile.visibility[playerTeam.id] or Constants.VISIBILITY.HIDDEN
end

--- Toggle minimap visibility
--- @param game table The game state object
function Minimap.toggle(game)
    game.showMinimap = not (game.showMinimap or false)
end

--- Set minimap scale
--- @param scale number Scale multiplier (1.0 = normal, 2.0 = double size)
function Minimap.setScale(scale)
    minimapScale = math.max(0.5, math.min(3.0, scale))
end

--- Check if mouse is over minimap
--- @param mouseX number Mouse X coordinate
--- @param mouseY number Mouse Y coordinate
--- @param game table The game state object
--- @return boolean True if mouse is over minimap
function Minimap.isMouseOver(mouseX, mouseY, game)
    if not game.showMinimap then
        return false
    end
    
    local map = game.map
    if not map then
        return false
    end
    
    local tileSize = math.min(minimapSize / map.width, minimapSize / map.height) * minimapScale
    local minimapWidth = map.width * tileSize
    local minimapHeight = map.height * tileSize
    
    return mouseX >= minimapPosition.x and mouseX <= minimapPosition.x + minimapWidth and
           mouseY >= minimapPosition.y and mouseY <= minimapPosition.y + minimapHeight
end

--- Convert minimap screen coordinates to grid coordinates
--- @param mouseX number Mouse X coordinate
--- @param mouseY number Mouse Y coordinate
--- @param game table The game state object
--- @return number, number Grid X and Y coordinates (or nil if outside minimap)
function Minimap.screenToGrid(mouseX, mouseY, game)
    if not Minimap.isMouseOver(mouseX, mouseY, game) then
        return nil, nil
    end
    
    local map = game.map
    local tileSize = math.min(minimapSize / map.width, minimapSize / map.height) * minimapScale
    
    local gridX = math.floor((mouseX - minimapPosition.x) / tileSize) + 1
    local gridY = math.floor((mouseY - minimapPosition.y) / tileSize) + 1
    
    return gridX, gridY
end

return Minimap






















