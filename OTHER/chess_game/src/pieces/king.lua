-- King piece - moves 1 tile in any direction, CANNOT ATTACK
local Constants = require("src.core.constants")
local Piece = require("src.pieces.piece")

local King = setmetatable({}, {__index = Piece})
King.__index = King

function King.new(x, y, playerId)
    local self = setmetatable(Piece.new(x, y, playerId, Constants.PIECE_TYPES.KING), King)
    return self
end

function King:canMoveTo(board, toX, toY)
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
    
    -- KING CANNOT ATTACK - cannot move to occupied tile
    if board:isOccupied(toX, toY) then
        return false
    end
    
    return true
end

function King:getValidMoves(board)
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

-- Override canAttack - King cannot attack
function King:canAttack(board, targetX, targetY)
    return false
end

return King
