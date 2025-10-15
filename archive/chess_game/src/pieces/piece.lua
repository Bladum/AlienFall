-- Base Piece class
local Constants = require("src.core.constants")

local Piece = {}
Piece.__index = Piece

function Piece.new(x, y, playerId, pieceType)
    local self = setmetatable({}, Piece)
    
    self.x = x
    self.y = y
    self.playerId = playerId
    self.pieceType = pieceType
    
    -- Get stats from constants
    local stats = Constants.PIECE_STATS[pieceType]
    self.maxHp = stats.hp
    self.hp = stats.hp
    self.attack = stats.attack
    self.vision = stats.vision
    self.cost = Constants.PIECE_COSTS[pieceType]
    self.tuCost = Constants.PIECE_TU_COSTS[pieceType]
    self.range = Constants.PIECE_RANGES[pieceType]
    
    -- State
    self.hasMoved = false
    self.isDead = false
    -- Animation state
    self._anim = nil -- {type='move'|'attack', path={}, seg=1, t=0, segDur=0.12, onComplete=fn, board=board, finalX, finalY, target}
    self._drawPos = nil -- {x=worldX, y=worldY}
    self._scale = 1
    self._shrink = false
    self._shrinkT = 0
    self._shrinkDur = Constants.ANIM.shrink_duration or 0.25
    self._onRemoved = nil -- optional callback when piece is fully removed after shrink
    
    return self
end

function Piece:getColor()
    return Constants.PLAYER_COLORS[self.playerId]
end

function Piece:canMoveTo(board, toX, toY)
    -- Override in subclasses
    return false
end

function Piece:getValidMoves(board)
    -- Override in subclasses
    return {}
end

function Piece:canAttack(board, targetX, targetY)
    local target = board:getPiece(targetX, targetY)
    if not target then
        return false
    end
    
    -- King cannot attack
    if self.pieceType == Constants.PIECE_TYPES.KING then
        return false
    end
    
    -- Cannot attack own pieces
    if target.playerId == self.playerId then
        return false
    end
    
    -- Check if target is within movement range
    return self:canMoveTo(board, targetX, targetY)
end

function Piece:takeDamage(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        self.isDead = true
    end
    return self.isDead
end

function Piece:attack_piece(target)
    if target then
        return target:takeDamage(self.attack)
    end
    return false
end

function Piece:draw(screenX, screenY, tileSize, camera, activePlayerId)
    -- Use animated draw position if present
    local drawX, drawY = screenX, screenY
    if self._drawPos then
        drawX = self._drawPos.x
        drawY = self._drawPos.y
    end

    local color = self:getColor()
    love.graphics.setColor(color.r, color.g, color.b)

    -- Draw piece as circle
    local centerX = drawX + tileSize / 2
    local centerY = drawY + tileSize / 2
    local baseRadius = tileSize * 0.35
    local radius = baseRadius * (self._scale or 1)
    
    love.graphics.circle("fill", centerX, centerY, radius)
    
    -- Draw piece type indicator
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text = string.sub(self.pieceType, 1, 1):upper()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.print(text, centerX - textWidth / 2, centerY - textHeight / 2)
    
    -- Draw HP bar if damaged
    if self.hp < self.maxHp then
        local barWidth = tileSize * 0.7
        local barHeight = 4
        local barX = screenX + (tileSize - barWidth) / 2
        local barY = screenY + tileSize - 10
        
        -- Background
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
        
        -- HP
        local hpPercent = self.hp / self.maxHp
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", barX, barY, barWidth * hpPercent, barHeight)
    end
    
    love.graphics.setColor(1, 1, 1)

    -- Draw move availability indicator when this piece belongs to active player
    if activePlayerId and self.playerId == activePlayerId then
    local dotSize = math.max(2, tileSize * (Constants.VISUALS.dot_size_factor or 0.12))
    local dotX = drawX + tileSize - dotSize - (Constants.VISUALS.dot_offset or 4)
    local dotY = drawY + (Constants.VISUALS.dot_offset or 4)
        if self.hasMoved then
            -- small gray dot in corner for already moved
            love.graphics.setColor(0.25, 0.25, 0.25)
            love.graphics.circle("fill", dotX + dotSize/2, dotY + dotSize/2, dotSize/2)
        else
            -- green dot for ready-to-move
            love.graphics.setColor(0.2, 1, 0.2)
            love.graphics.circle("fill", dotX + dotSize/2, dotY + dotSize/2, dotSize/2)
        end
        love.graphics.setColor(1,1,1)
    end
end

function Piece:update(dt)
    -- Advance movement/attack animations
    if self._anim then
        local a = self._anim
        a.t = a.t + dt
        -- compute total progress in segments (floating)
        local total = (a.seg - 1) + (a.t / a.segDur)
        local finished = false
        if total >= (#a.path - 1) then
            finished = true
        end

        if finished then
            -- finalize
            local last = a.path[#a.path]
            if a.type == 'move' then
                self.x = a.finalX or last.x
                self.y = a.finalY or last.y
            elseif a.type == 'attack' then
                self.x = a.finalX or last.x
                self.y = a.finalY or last.y
                if a.target and a.target.isDead then
                    a.target._shrink = true
                    a.target._shrinkT = 0
                end
            end
            self._drawPos = nil
            if a.onComplete then a.onComplete() end
            self._anim = nil
        else
            -- compute current segment and alpha
            local prog = math.max(0, math.min(#a.path - 1 - 1e-6, total))
            local segIdx = math.floor(prog) + 1
            local alpha = prog - (segIdx - 1)
            local p0 = a.path[segIdx]
            local p1 = a.path[segIdx + 1]
            -- ease-in-out using cosine
            local ease = 0.5 - 0.5 * math.cos(math.min(1, math.max(0, alpha)) * math.pi)
            local worldX = (1 - ease) * ((p0.x - 1) * a.tileSize) + ease * ((p1.x - 1) * a.tileSize)
            local worldY = (1 - ease) * ((p0.y - 1) * a.tileSize) + ease * ((p1.y - 1) * a.tileSize)
            if a.camera then
                local sx, sy = a.camera:worldToScreen(worldX, worldY)
                self._drawPos = { x = sx, y = sy }
            end
            -- update seg and internal t for next frame
            a.seg = segIdx
            a.t = (alpha) * a.segDur
        end
    end

    -- Shrink animation when dying
    if self._shrink then
        self._shrinkT = self._shrinkT + dt
        local p = math.min(1, self._shrinkT / self._shrinkDur)
        self._scale = 1 - p
        if p >= 1 then
            -- fully shrunk: mark dead and call removal callback if present
            self.isDead = true
            self._shrink = false
            if self._onRemoved then
                self._onRemoved(self)
            end
        end
    end
end

-- Helper function to check if position is within range
function Piece:isWithinRange(fromX, fromY, toX, toY, range)
    local dx = math.abs(toX - fromX)
    local dy = math.abs(toY - fromY)
    return math.max(dx, dy) <= range
end

-- Helper function to check straight line (for rook)
function Piece:isStraightLine(fromX, fromY, toX, toY)
    return fromX == toX or fromY == toY
end

-- Helper function to check diagonal (for bishop)
function Piece:isDiagonal(fromX, fromY, toX, toY)
    local dx = math.abs(toX - fromX)
    local dy = math.abs(toY - fromY)
    return dx == dy
end

-- Helper function to check if path is clear
function Piece:isPathClear(board, fromX, fromY, toX, toY)
    local dx = toX - fromX
    local dy = toY - fromY
    local steps = math.max(math.abs(dx), math.abs(dy))
    
    if steps == 0 then
        return true
    end
    
    local stepX = dx / steps
    local stepY = dy / steps
    
    for i = 1, steps - 1 do
        local checkX = math.floor(fromX + stepX * i + 0.5)
        local checkY = math.floor(fromY + stepY * i + 0.5)
        
        if not board:isWalkable(checkX, checkY) or board:isOccupied(checkX, checkY) then
            return false
        end
    end
    
    return true
end

return Piece






















