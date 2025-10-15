---Minimap System - Tactical Overview
---
---Minimap showing fog of war, unit positions, objectives, with zoom
---and click-to-center navigation for tactical overview. Provides real-time
---tactical awareness and navigation assistance during battlescape missions.
---
---Features:
---  - Fog of war visualization (fog, explored, visible)
---  - Unit position tracking (player/enemy teams)
---  - Objective markers
---  - Click-to-center camera navigation
---  - Zoom controls
---  - Grid-based rendering
---
---Key Exports:
---  - MinimapSystem.init(mapWidth, mapHeight): Initialize minimap
---  - MinimapSystem.setFog(x, y, state): Update fog of war
---  - MinimapSystem.addUnit(unitId, x, y, team): Add unit marker
---  - MinimapSystem.addObjective(id, x, y): Add objective marker
---  - MinimapSystem.draw(): Render minimap UI
---  - MinimapSystem.handleClick(x, y): Handle click navigation
---
---Dependencies:
---  - Battlescape map system for terrain data
---  - Unit system for position tracking
---  - Camera system for navigation
---
---@module battlescape.ui.minimap_system
---@author UI Systems
---@license Open Source

local MinimapSystem = {}

local CONFIG = {
    WIDTH = 192,
    HEIGHT = 144,
    X = 960 - 192 - 12,
    Y = 12,
    CELL_SIZE = 2,
    COLORS = {
        FOG = {r=20,g=20,b=30},
        EXPLORED = {r=60,g=60,b=70},
        VISIBLE = {r=100,g=100,b=110},
        PLAYER_UNIT = {r=80,g=200,b=80},
        ENEMY_UNIT = {r=220,g=60,b=60},
        OBJECTIVE = {r=220,g=180,b=60},
    },
}

local minimapData = {
    mapWidth = 60,
    mapHeight = 60,
    fogOfWar = {},
    units = {},
    objectives = {},
}

function MinimapSystem.init(mapWidth, mapHeight)
    minimapData.mapWidth = mapWidth
    minimapData.mapHeight = mapHeight
    minimapData.fogOfWar = {}
    minimapData.units = {}
    minimapData.objectives = {}
end

function MinimapSystem.setFog(x, y, state)
    if not minimapData.fogOfWar[y] then minimapData.fogOfWar[y] = {} end
    minimapData.fogOfWar[y][x] = state  -- 0=fog, 1=explored, 2=visible
end

function MinimapSystem.addUnit(unitId, x, y, team)
    minimapData.units[unitId] = {x=x, y=y, team=team}
end

function MinimapSystem.removeUnit(unitId)
    minimapData.units[unitId] = nil
end

function MinimapSystem.draw()
    local x = CONFIG.X
    local y = CONFIG.Y
    
    -- Background
    love.graphics.setColor(20, 20, 30, 240)
    love.graphics.rectangle("fill", x, y, CONFIG.WIDTH, CONFIG.HEIGHT)
    
    -- Border
    love.graphics.setColor(100, 100, 120, 255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, CONFIG.WIDTH, CONFIG.HEIGHT)
    
    -- Map cells
    for ty = 0, minimapData.mapHeight - 1 do
        for tx = 0, minimapData.mapWidth - 1 do
            local fog = (minimapData.fogOfWar[ty] and minimapData.fogOfWar[ty][tx]) or 0
            local color = fog == 0 and CONFIG.COLORS.FOG or
                         fog == 1 and CONFIG.COLORS.EXPLORED or
                         CONFIG.COLORS.VISIBLE
            
            love.graphics.setColor(color.r, color.g, color.b, 255)
            local cellX = x + (tx / minimapData.mapWidth) * CONFIG.WIDTH
            local cellY = y + (ty / minimapData.mapHeight) * CONFIG.HEIGHT
            love.graphics.rectangle("fill", cellX, cellY, CONFIG.CELL_SIZE, CONFIG.CELL_SIZE)
        end
    end
    
    -- Units
    for unitId, unit in pairs(minimapData.units) do
        local color = unit.team == "PLAYER" and CONFIG.COLORS.PLAYER_UNIT or CONFIG.COLORS.ENEMY_UNIT
        love.graphics.setColor(color.r, color.g, color.b, 255)
        local ux = x + (unit.x / minimapData.mapWidth) * CONFIG.WIDTH
        local uy = y + (unit.y / minimapData.mapHeight) * CONFIG.HEIGHT
        love.graphics.circle("fill", ux, uy, 3)
    end
end

function MinimapSystem.handleClick(mouseX, mouseY)
    if mouseX >= CONFIG.X and mouseX <= CONFIG.X + CONFIG.WIDTH and
       mouseY >= CONFIG.Y and mouseY <= CONFIG.Y + CONFIG.HEIGHT then
        local mapX = ((mouseX - CONFIG.X) / CONFIG.WIDTH) * minimapData.mapWidth
        local mapY = ((mouseY - CONFIG.Y) / CONFIG.HEIGHT) * minimapData.mapHeight
        return math.floor(mapX), math.floor(mapY)
    end
    return nil, nil
end

return MinimapSystem






















