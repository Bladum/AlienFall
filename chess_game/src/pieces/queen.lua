-- Queen piece - moves in any direction, max range 3
local Constants = require("src.core.constants")
local Piece = require("src.pieces.piece")

local Queen = setmetatable({}, {__index = Piece})
Queen.__index = Queen

function Queen.new(x, y, playerId)
    local self = setmetatable(Piece.new(x, y, playerId, Constants.PIECE_TYPES.QUEEN), Queen)
    return self
end

function Queen:canMoveTo(board, toX, toY)
    -- Can't move to same position
    if toX == self.x and toY == self.y then
        return false
    end
    
    -- Must be on straight line or diagonal
    local isStraight = self:isStraightLine(self.x, self.y, toX, toY)
    local isDiag = self:isDiagonal(self.x, self.y, toX, toY)
    
    if not (isStraight or isDiag) then
        return false
    end
    
    -- Check range (max 3)
    if not self:isWithinRange(self.x, self.y, toX, toY, self.range) then
        return false
    end
    
    -- Check if destination is walkable
    if not board:isWalkable(toX, toY) then
        return false
    end
    
    -- Check if path is clear
    if not self:isPathClear(board, self.x, self.y, toX, toY) then
        return false
    end
    
    -- Can move to occupied tile if enemy
    local target = board:getPiece(toX, toY)
    if target then
        return target.playerId ~= self.playerId
    end
    
    return true
end

function Queen:getValidMoves(board)
    local moves = {}
    
    -- All 8 directions (orthogonal + diagonal)
    local directions = {
        {0, -1}, {0, 1}, {-1, 0}, {1, 0},  -- Orthogonal
        {1, 1}, {1, -1}, {-1, 1}, {-1, -1} -- Diagonal
    }
    
    for _, dir in ipairs(directions) do
        for dist = 1, self.range do
            local toX = self.x + dir[1] * dist
            local toY = self.y + dir[2] * dist
            
            if board:isValidPosition(toX, toY) and self:canMoveTo(board, toX, toY) then
                table.insert(moves, {x = toX, y = toY})
                
                -- Stop if we hit a piece
                if board:isOccupied(toX, toY) then
                    break
                end
            else
                break
            end
        end
    end
    
    return moves
end

return Queen
