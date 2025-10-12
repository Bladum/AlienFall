-- Battlefield Renderer
-- Handles all drawing operations for the battlefield

local Assets = require("systems.assets")
local Debug = require("systems.battle.utils.debug")

local BattlefieldRenderer = {}
BattlefieldRenderer.__index = BattlefieldRenderer

-- Create a new renderer
function BattlefieldRenderer.new(tileSize)
    local self = setmetatable({}, BattlefieldRenderer)
    
    self.tileSize = tileSize or 24
    self.showGrid = false
    self.debugViewTeam = nil  -- Set to team ID for debug visibility
    
    return self
end

-- Toggle grid display
function BattlefieldRenderer:toggleGrid()
    self.showGrid = not self.showGrid
    print("[Renderer] Grid: " .. tostring(self.showGrid))
end

-- Set debug view team
function BattlefieldRenderer:setDebugViewTeam(teamId)
    self.debugViewTeam = teamId
    print("[Renderer] Debug view: " .. (teamId or "normal"))
end

-- Draw the battlefield
function BattlefieldRenderer:draw(battlefield, camera, teamManager, currentTeam, isNight, viewportWidth, viewportHeight)
    -- Get visible bounds to only render tiles that are on screen
    local bounds = camera:getVisibleBounds(viewportWidth or 720, viewportHeight or 720, self.tileSize, battlefield.width, battlefield.height)
    
    for y = bounds.minY, bounds.maxY do
        for x = bounds.minX, bounds.maxX do
            local tile = battlefield:getTile(x, y)
            if tile then
                local screenX = ((x - 1) * self.tileSize) * camera.zoom + camera.x
                -- Offset alternate columns to simulate hex grid
                local offsetY = (x % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
                local screenY = ((y - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
                
                -- Determine visibility
                local visibility = self:getVisibility(tile, x, y, teamManager, currentTeam)
                
                -- Draw tile based on visibility
                if visibility == "visible" then
                    local brightness = isNight and 0.6 or 1.0  -- Dim tiles at night
                    self:drawTileTerrain(tile, screenX, screenY, camera.zoom, brightness)
                elseif visibility == "explored" then
                    local brightness = isNight and 0.2 or 0.3  -- Even dimmer explored tiles at night
                    self:drawTileTerrain(tile, screenX, screenY, camera.zoom, brightness)
                else
                    -- Hidden
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.rectangle("fill", screenX, screenY, self.tileSize * camera.zoom, self.tileSize * camera.zoom)
                end
                
                -- Draw grid
                if self.showGrid then
                    love.graphics.setColor(0.2, 0.2, 0.2)
                    love.graphics.rectangle("line", screenX, screenY, self.tileSize * camera.zoom, self.tileSize * camera.zoom)
                end
            end
        end
    end
end

-- Get visibility for a tile
function BattlefieldRenderer:getVisibility(tile, x, y, teamManager, currentTeam)
    -- If fog of war is disabled, show everything as visible
    if not Debug.showFOW then
        return "visible"
    end
    
    if self.debugViewTeam then
        return tile:getFOW(self.debugViewTeam)
    else
        local team = teamManager:getTeam(currentTeam.id)
        if team then
            return team:getVisibility(x, y)
        end
        return "hidden"
    end
end

-- Draw tile terrain
function BattlefieldRenderer:drawTileTerrain(tile, screenX, screenY, zoom, brightness)
    local terrain = tile.terrain
    
    -- Map terrain ID to image name
    local imageName
    if terrain.id == "floor" then
        imageName = "stone floor"
    elseif terrain.id == "wall" then
        imageName = "stone wall"
    elseif terrain.id == "wood_wall" then
        imageName = "wood wall"
    elseif terrain.id == "tree" then
        imageName = "tree"
    elseif terrain.id == "road" then
        imageName = "path"
    elseif terrain.id == "door" then
        imageName = "stone door close"
    elseif terrain.id == "bushes" then
        imageName = "plant small 01"
    else
        imageName = "stone floor" -- default
    end
    
    -- Get image from assets
    love.graphics.setColor(brightness, brightness, brightness)
    
    local image, quad, isTileVariation = Assets.get("terrain", imageName)
    if image then
        if tile.quadIndex and tile.quadIndex > 1 and isTileVariation then
            -- Use specific quad for tile variations
            local quadImage, specificQuad = Assets.getQuad("terrain", imageName, tile.quadIndex)
            if quadImage and specificQuad then
                love.graphics.draw(quadImage, specificQuad, screenX, screenY, 0, zoom, zoom)
            else
                -- Fallback to default quad
                love.graphics.draw(image, quad, screenX, screenY, 0, zoom, zoom)
            end
        else
            -- Use default/first quad or full image
            if quad then
                love.graphics.draw(image, quad, screenX, screenY, 0, zoom, zoom)
            else
                love.graphics.draw(image, screenX, screenY, 0, zoom, zoom)
            end
        end
    else
        -- Fallback to colored rectangle
        local colors = {
            floor = {0.4, 0.4, 0.4},
            rough = {0.5, 0.4, 0.3},
            slope = {0.3, 0.3, 0.5},
            wall = {0.2, 0.2, 0.25},
            low_wall = {0.25, 0.25, 0.3},
            window = {0.3, 0.3, 0.35},
            door = {0.4, 0.3, 0.2},
            water = {0.2, 0.3, 0.5},
            pit = {0.1, 0.1, 0.1},
            bushes = {0.2, 0.4, 0.2},
            trees = {0.15, 0.3, 0.15},
            smoke = {0.3, 0.3, 0.3},
            fire = {0.8, 0.4, 0.1}
        }
        
        local color = colors[terrain.id] or {0.4, 0.4, 0.4}
        
        -- Apply brightness
        love.graphics.setColor(color[1] * brightness, color[2] * brightness, color[3] * brightness)
        love.graphics.rectangle("fill", screenX, screenY, self.tileSize * zoom, self.tileSize * zoom)
    end
    
    -- Draw environmental effects
    if tile.effects.smoke > 0 then
        love.graphics.setColor(0.5, 0.5, 0.5, tile.effects.smoke * 0.1)
        love.graphics.rectangle("fill", screenX, screenY, self.tileSize, self.tileSize)
    end
    
    if tile.effects.fire > 0 then
        love.graphics.setColor(1, 0.5, 0, tile.effects.fire * 0.1)
        love.graphics.rectangle("fill", screenX, screenY, self.tileSize, self.tileSize)
    end
end

-- Draw units
function BattlefieldRenderer:drawUnits(units, camera, teamManager, debugViewTeam)
    for _, unit in pairs(units) do
        if unit.alive then
            -- Check visibility
            local isVisible = self:isUnitVisible(unit, teamManager, debugViewTeam)
            
            if isVisible then
                self:drawUnit(unit, camera, teamManager)
            end
        end
    end
end

-- Check if unit is visible
function BattlefieldRenderer:isUnitVisible(unit, teamManager, debugViewTeam)
    if debugViewTeam then
        -- Debug mode: use specified team
        local team = teamManager:getTeam(debugViewTeam)
        if team then
            for _, tilePos in ipairs(unit:getOccupiedTiles()) do
                if team:isTileVisible(tilePos.x, tilePos.y) then
                    return true
                end
            end
        end
        return false
    else
        -- Normal mode: unit is visible if it's on the current team or if any team can see it
        -- For now, show all units (can be refined later for proper fog of war)
        return true
    end
end

-- Draw a single unit
function BattlefieldRenderer:drawUnit(unit, camera, teamManager)
    -- Use animation position if available, otherwise use actual position
    local drawX = unit.animX or unit.x
    local drawY = unit.animY or unit.y
    local drawFacing = unit.animFacing or unit.facing
    
    local screenX = ((drawX - 1) * self.tileSize) * camera.zoom + camera.x
    -- Offset alternate columns to simulate hex grid
    local offsetY = (math.floor(drawX) % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
    local screenY = ((drawY - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
    
    -- Get team color for tinting
    local team = teamManager:getTeam(unit.team)
    local teamColor = {1, 1, 1}  -- Default white
    if team and team.color then
        teamColor = team.color
    end
    
    -- Get unit image
    local image = Assets.get("units", "unit test")
    if image then
        -- Draw the unit image scaled to fill the tile (24x24 pixels)
        love.graphics.setColor(teamColor[1], teamColor[2], teamColor[3])
        -- Scale to fit tile size regardless of source image size
        local imageWidth, imageHeight = image:getDimensions()
        local scaleX = (self.tileSize * camera.zoom) / imageWidth
        local scaleY = (self.tileSize * camera.zoom) / imageHeight
        
        love.graphics.draw(image, screenX, screenY, 0, scaleX, scaleY)
    else
        -- Fallback: draw colored circle
        love.graphics.setColor(teamColor[1], teamColor[2], teamColor[3])
        
        local centerX = screenX + (self.tileSize * camera.zoom) / 2
        local centerY = screenY + (self.tileSize * camera.zoom) / 2
        local radius = self.tileSize * unit.stats.size * 0.4 * camera.zoom
        love.graphics.circle("fill", centerX, centerY, radius)
    end
    
    -- Draw health bar
    local centerX = screenX + (self.tileSize * camera.zoom) / 2
    local centerY = screenY + (self.tileSize * camera.zoom) / 2
    local radius = self.tileSize * unit.stats.size * 0.4 * camera.zoom
    self:drawHealthBar(centerX, centerY, radius, unit.health, unit.maxHealth, camera.zoom)
end

-- Draw unit health bar
function BattlefieldRenderer:drawHealthBar(centerX, centerY, radius, health, maxHealth, zoom)
    local barHeight = 3 * zoom
    local barY = centerY + radius + 2 * zoom
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("fill", centerX - radius, barY, radius * 2, barHeight)
    love.graphics.setColor(0, 0.8, 0)
    local healthWidth = radius * 2 * (health / maxHealth)
    love.graphics.rectangle("fill", centerX - radius, barY, healthWidth, barHeight)
end

-- Draw selection highlight
function BattlefieldRenderer:drawSelectionHighlight(unit, camera, time)
    if not unit then return end
    
    -- Use animation position
    local drawX = unit.animX or unit.x
    local drawY = unit.animY or unit.y
    
    local screenX = ((drawX - 1) * self.tileSize) * camera.zoom + camera.x
    -- Offset alternate columns to simulate hex grid
    local offsetY = (math.floor(drawX) % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
    local screenY = ((drawY - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
    
    -- Animated white rectangle with pulsing alpha
    local pulse = 0.7 + 0.3 * math.sin((time or 0) * 3)  -- Pulse between 0.7 and 1.0
    love.graphics.setColor(1, 1, 1, pulse)
    love.graphics.setLineWidth(3 * camera.zoom)
    love.graphics.rectangle("line", screenX, screenY, self.tileSize * camera.zoom, self.tileSize * camera.zoom)
    love.graphics.setLineWidth(1)  -- Reset line width
end

-- Draw visible tile indicators (yellow dots for tiles visible to selected unit)
function BattlefieldRenderer:drawVisibleTileIndicators(visibleTiles, camera)
    if not visibleTiles or #visibleTiles == 0 then return end
    
    love.graphics.setColor(1, 1, 0, 0.8)  -- Yellow with 80% opacity
    
    for _, tile in ipairs(visibleTiles) do
        local screenX = ((tile.x - 1) * self.tileSize) * camera.zoom + camera.x
        -- Offset alternate columns to simulate hex grid
        local offsetY = (math.floor(tile.x) % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
        local screenY = ((tile.y - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
        
        -- Draw yellow dot in center of tile
        local centerX = screenX + (self.tileSize * camera.zoom) / 2
        local centerY = screenY + (self.tileSize * camera.zoom) / 2
        local dotRadius = 4 * camera.zoom  -- Increased from 2 to 4 for better visibility
        
        love.graphics.circle("fill", centerX, centerY, dotRadius)
    end
    
    love.graphics.setColor(1, 1, 1)  -- Reset color
end

-- Draw movement range
function BattlefieldRenderer:drawMovementRange(movementRange, camera, hoveredPath)
    if not movementRange then return end
    
    -- Build set of tiles in path for quick lookup
    local pathTiles = {}
    if hoveredPath then
        for _, step in ipairs(hoveredPath) do
            pathTiles[string.format("%d,%d", step.x, step.y)] = step
        end
    end
    
    -- Set font for MP cost display
    love.graphics.setFont(love.graphics.newFont(12))
    
    for _, tile in ipairs(movementRange) do
        local screenX = ((tile.x - 1) * self.tileSize) * camera.zoom + camera.x
        -- Offset alternate columns to simulate hex grid
        local offsetY = (tile.x % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
        local screenY = ((tile.y - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
        
        local centerX = screenX + (self.tileSize * camera.zoom) / 2
        local centerY = screenY + (self.tileSize * camera.zoom) / 2
        local radius = (self.tileSize * camera.zoom) * 0.4
        
        -- Check if this tile is in the hovered path
        local tileKey = string.format("%d,%d", tile.x, tile.y)
        local isInPath = pathTiles[tileKey] ~= nil
        
        if isInPath then
            -- Draw blue circle and text for path tiles
            love.graphics.setColor(0.2, 0.4, 1.0, 0.6)
            love.graphics.circle("fill", centerX, centerY, radius)
            love.graphics.setColor(0.2, 0.4, 1.0, 0.8)
            love.graphics.circle("line", centerX, centerY, radius)
            
            -- Draw MP cost in white/blue
            love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
            local costText = tostring(tile.cost)
            local textWidth = love.graphics.getFont():getWidth(costText)
            local textHeight = love.graphics.getFont():getHeight()
            love.graphics.print(costText, centerX - textWidth/2, centerY - textHeight/2)
        else
            -- Draw subtle green circle outline for normal range
            love.graphics.setColor(0.3, 0.7, 0.3, 0.4)
            love.graphics.circle("line", centerX, centerY, radius)
            
            -- Draw MP cost in green
            love.graphics.setColor(0.3, 0.7, 0.3, 0.8)
            local costText = tostring(tile.cost)
            local textWidth = love.graphics.getFont():getWidth(costText)
            local textHeight = love.graphics.getFont():getHeight()
            love.graphics.print(costText, centerX - textWidth/2, centerY - textHeight/2)
        end
    end
end

-- Draw movement path preview
function BattlefieldRenderer:drawMovementPath(movementPath, camera)
    if not movementPath then return end
    
    love.graphics.setColor(0.2, 0.8, 0.2, 0.8)
    for _, step in ipairs(movementPath) do
        local screenX = ((step.x - 1) * self.tileSize) * camera.zoom + camera.x
        -- Offset alternate columns to simulate hex grid
        local offsetY = (step.x % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
        local screenY = ((step.y - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
        love.graphics.rectangle("line", screenX, screenY, self.tileSize * camera.zoom, self.tileSize * camera.zoom)
    end
end

-- Draw hovered tile highlight
function BattlefieldRenderer:drawHoveredTile(hoveredTile, camera)
    if not hoveredTile then return end
    
    love.graphics.setColor(1, 1, 0, 0.8)
    local screenX = ((hoveredTile.x - 1) * self.tileSize) * camera.zoom + camera.x
    -- Offset alternate columns to simulate hex grid
    local offsetY = (hoveredTile.x % 2 == 0) and (self.tileSize * camera.zoom * 0.5) or 0
    local screenY = ((hoveredTile.y - 1) * self.tileSize) * camera.zoom + camera.y + offsetY
    love.graphics.rectangle("line", screenX, screenY, self.tileSize * camera.zoom, self.tileSize * camera.zoom)
end

-- Draw turn indicator
function BattlefieldRenderer:drawTurnIndicator(turnNumber, currentTeam, screenWidth)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    local turnText = "TURN: " .. turnNumber .. " - " .. currentTeam.name
    love.graphics.print(turnText, screenWidth / 2 - 150, 15)
end

-- Draw unit info panel
function BattlefieldRenderer:drawUnitInfo(unit, panelX, panelY)
    if not unit then return end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    
    love.graphics.print(unit.name .. " (" .. unit.team .. ")", panelX, panelY)
    love.graphics.print("Health: " .. unit.health .. "/" .. unit.maxHealth, panelX, panelY + 20)
    love.graphics.print("AP: " .. unit.actionPointsLeft .. "/4", panelX, panelY + 40)
    love.graphics.print("MP: " .. unit.movementPoints, panelX, panelY + 60)
    love.graphics.print("Position: (" .. unit.x .. ", " .. unit.y .. ")", panelX, panelY + 80)
end

-- Draw selection
function BattlefieldRenderer:drawSelection(selection, camera, animationSystem, losSystem, isDay, showVisibleTiles)
    if not selection then return end
    
    -- Calculate visible tiles based on unit's current position (animated if moving)
    local visibleTiles = selection.visibleTiles or {}
    if selection.selectedUnit and losSystem then
        local unitIsMoving = animationSystem and animationSystem:isUnitAnimating(selection.selectedUnit)
        if unitIsMoving then
            -- Calculate visible tiles from animated position during movement
            local animUnit = {
                x = math.floor(selection.selectedUnit.animX + 0.5),  -- Round to nearest tile
                y = math.floor(selection.selectedUnit.animY + 0.5),
                stats = selection.selectedUnit.stats
            }
            visibleTiles = losSystem:calculateVisibilityForUnit(animUnit, nil, isDay) or {}
        end
    end
    
    -- Draw visible tile indicators (yellow dots) - draw first so they're under other elements
    if showVisibleTiles and visibleTiles and #visibleTiles > 0 then
        self:drawVisibleTileIndicators(visibleTiles, camera)
    end
    
    -- Draw selection highlight
    if selection.selectedUnit then
        self:drawSelectionHighlight(selection.selectedUnit, camera)
    end
    
    -- Draw movement range (pass path for highlighting) - but only if unit is not moving
    local unitIsMoving = animationSystem and animationSystem:isUnitAnimating(selection.selectedUnit)
    if selection.movementRange and not unitIsMoving then
        self:drawMovementRange(selection.movementRange, camera, selection.movementPath)
    end
    
    -- Draw movement path is now integrated into drawMovementRange
    -- if selection.movementPath then
    --     self:drawMovementPath(selection.movementPath, camera)
    -- end
    
    -- Draw hovered tile
    if selection.hoveredTile then
        self:drawHoveredTile(selection.hoveredTile, camera)
    end
end

return BattlefieldRenderer
