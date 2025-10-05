-- Tile class for individual board tiles
local Constants = require("src.core.constants")

local Tile = {}
Tile.__index = Tile

function Tile.new(x, y, tileType)
    local self = setmetatable({}, Tile)
    
    self.x = x
    self.y = y
    self.tileType = tileType or Constants.TILE_TYPES.NORMAL
    self.piece = nil -- Piece occupying this tile
    -- fogState is a table mapping playerId -> fog state (visible/explored/hidden)
    self.fogState = {}
    self.controlledBy = nil -- Player ID if it's a control point
    
    return self
end

function Tile:isWalkable()
    return self.tileType ~= Constants.TILE_TYPES.OBSTACLE
end

function Tile:isOccupied()
    return self.piece ~= nil
end

function Tile:setPiece(piece)
    self.piece = piece
    if piece then
        piece.x = self.x
        piece.y = self.y
    end
end

function Tile:removePiece()
    local piece = self.piece
    self.piece = nil
    return piece
end

function Tile:isControlPoint()
    return self.tileType == Constants.TILE_TYPES.CONTROL_POINT
end

-- Set fog state for a specific player
function Tile:setFogState(playerId, state)
    if not playerId then return end
    self.fogState[playerId] = state
end

-- Get fog state for a specific player (defaults to HIDDEN)
function Tile:getFogState(playerId)
    if not playerId then return Constants.FOW_HIDDEN end
    return self.fogState[playerId] or Constants.FOW_HIDDEN
end

-- Convenience: is tile visible for a given player
function Tile:isVisible(playerId)
    return self:getFogState(playerId) == Constants.FOW_VISIBLE
end

function Tile:draw(screenX, screenY, tileSize, camera, activePlayerId)
    local color
    
    -- Determine tile color
    if self.tileType == Constants.TILE_TYPES.OBSTACLE then
        color = Constants.UI_COLORS.OBSTACLE
    elseif self.tileType == Constants.TILE_TYPES.CONTROL_POINT then
        color = Constants.UI_COLORS.CONTROL_POINT
    else
        -- Use single uniform tile color to avoid checkerboard confusion
        color = Constants.UI_COLORS.TILE
    end
    
    -- Draw tile
    love.graphics.setColor(color.r, color.g, color.b)
    love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
    
    -- Draw grid lines
    love.graphics.setColor(Constants.UI_COLORS.GRID.r, Constants.UI_COLORS.GRID.g, Constants.UI_COLORS.GRID.b)
    love.graphics.rectangle("line", screenX, screenY, tileSize, tileSize)
    
    -- Draw fog of war for the active player
    local fogState = self:getFogState(activePlayerId)
    if fogState == Constants.FOW_HIDDEN then
        local fog = Constants.UI_COLORS.FOG
        love.graphics.setColor(fog.r, fog.g, fog.b, fog.a)
        love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
    elseif fogState == Constants.FOW_EXPLORED then
        -- Make explored tiles visibly darker but not fully hidden so player can see terrain
        local fog = Constants.UI_COLORS.FOG
        local exploredAlpha = math.min(0.85, (fog.a or 0.7) * 0.7 + 0.15)
        love.graphics.setColor(fog.r, fog.g, fog.b, exploredAlpha)
        love.graphics.rectangle("fill", screenX, screenY, tileSize, tileSize)
    end

    -- Draw piece if present and visible for active player
    if self.piece and self:isVisible(activePlayerId) then
        self.piece:draw(screenX, screenY, tileSize, camera, activePlayerId)
    end

    love.graphics.setColor(1, 1, 1)
end

return Tile
