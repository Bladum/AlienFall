-- Pawn piece - moves/attacks 1 tile in any direction
local Constants = require("src.core.constants")
local Piece = require("src.pieces.piece")

local Pawn = setmetatable({}, {__index = Piece})
Pawn.__index = Pawn

function Pawn.new(x, y, playerId)
    local self = setmetatable(Piece.new(x, y, playerId, Constants.PIECE_TYPES.PAWN), Pawn)
    return self
end

function Pawn:canMoveTo(board, toX, toY)
    -- Can't move to same position
    if toX == self.x and toY == self.y then
        return false
    end
    
    -- Must be within 1 tile in any direction (8 directions)
    local dx = math.abs(toX - self.x)
    local dy = math.abs(toY - self.y)
    
    if dx > 1 or dy > 1 then
        return false
    end
    
    -- Check if destination is walkable
    if not board:isWalkable(toX, toY) then
        return false
    end
    
    -- Can move to occupied tile (to attack)
    local target = board:getPiece(toX, toY)
    if target then
        return target.playerId ~= self.playerId
    end
    
    return true
end

function Pawn:getValidMoves(board)
    local moves = {}
    
    -- Check all 8 directions
    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local toX = self.x + dx
                local toY = self.y + dy
                
                if self:canMoveTo(board, toX, toY) then
                    table.insert(moves, {x = toX, y = toY})
                end
            end
        end
    end
    
    return moves
end

return Pawn
