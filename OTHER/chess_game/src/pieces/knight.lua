-- Knight piece - L-shaped movement (standard chess knight)
local Constants = require("src.core.constants")
local Piece = require("src.pieces.piece")

local Knight = setmetatable({}, {__index = Piece})
Knight.__index = Knight

function Knight.new(x, y, playerId)
    local self = setmetatable(Piece.new(x, y, playerId, Constants.PIECE_TYPES.KNIGHT), Knight)
    return self
end

function Knight:canMoveTo(board, toX, toY)
    -- Can't move to same position
    if toX == self.x and toY == self.y then
        return false
    end
    
    -- Must be L-shaped (2+1 or 1+2 in perpendicular directions)
    local dx = math.abs(toX - self.x)
    local dy = math.abs(toY - self.y)
    
    if not ((dx == 2 and dy == 1) or (dx == 1 and dy == 2)) then
        return false
    end
    
    -- Check if destination is walkable
    if not board:isWalkable(toX, toY) then
        return false
    end
    
    -- Can move to occupied tile if enemy
    local target = board:getPiece(toX, toY)
    if target then
        return target.playerId ~= self.playerId
    end
    
    return true
end

function Knight:getValidMoves(board)
    local moves = {}
    
    -- All 8 possible knight moves
    local knightMoves = {
        {2, 1}, {2, -1}, {-2, 1}, {-2, -1},
        {1, 2}, {1, -2}, {-1, 2}, {-1, -2}
    }
    
    for _, move in ipairs(knightMoves) do
        local toX = self.x + move[1]
        local toY = self.y + move[2]
        
        if board:isValidPosition(toX, toY) and self:canMoveTo(board, toX, toY) then
            table.insert(moves, {x = toX, y = toY})
        end
    end
    
    return moves
end

return Knight
