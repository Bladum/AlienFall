-- Board class for game board management
local Constants = require("src.core.constants")
local Tile = require("src.board.tile")

local Board = {}
Board.__index = Board

function Board.new(width, height, obstaclePercentage)
    local self = setmetatable({}, Board)
    
    self.width = width or Constants.DEFAULT_BOARD_WIDTH
    self.height = height or Constants.DEFAULT_BOARD_HEIGHT
    self.tiles = {}
    
    -- Initialize tiles
    for y = 1, self.height do
        self.tiles[y] = {}
        for x = 1, self.width do
            self.tiles[y][x] = Tile.new(x, y, Constants.TILE_TYPES.NORMAL)
        end
    end
    
    -- Generate obstacles
    self:generateObstacles(obstaclePercentage or Constants.OBSTACLE_PERCENTAGE)
    
    return self
end

function Board:generateObstacles(percentage)
    -- Island-style obstacle generation: more obstacles near edges, with noise
    percentage = percentage or Constants.OBSTACLE_PERCENTAGE
    -- clamp to configured maximum
    if Constants.MAX_OBSTACLE_PERCENTAGE and percentage > Constants.MAX_OBSTACLE_PERCENTAGE then
        percentage = Constants.MAX_OBSTACLE_PERCENTAGE
    end
    local w, h = self.width, self.height
    -- Optional deterministic seed
    if Constants.DEFAULT_MAP_SEED then
        love.math.setRandomSeed(Constants.DEFAULT_MAP_SEED)
    end
    local cx, cy = (w + 1) / 2, (h + 1) / 2

    -- Initial pass: distance + noise threshold
    for y = 1, h do
        for x = 1, w do
            -- normalized distance from center (0..1)
            local nx = (x - cx) / (w / 2)
            local ny = (y - cy) / (h / 2)
            local dist = math.sqrt(nx * nx + ny * ny) / math.sqrt(2)

            -- edge factor increases chance of obstacle toward edges
            local edge_factor = math.max(0, math.min(1, dist))

            -- noise to add organic variation
            local noise = love.math.random() * 0.6 - 0.3 -- in [-0.3, 0.3]

            -- probability influenced by base percentage and edge factor
            local prob = percentage * 1.5 + edge_factor * 0.9 + noise
            prob = math.max(0.01, math.min(0.95, prob))

            if love.math.random() < prob then
                self.tiles[y][x].tileType = Constants.TILE_TYPES.OBSTACLE
            else
                self.tiles[y][x].tileType = Constants.TILE_TYPES.NORMAL
            end
        end
    end

    -- Cellular smoothing to round edges (3 passes)
    local passes = 3
    for p = 1, passes do
        local newTypes = {}
        for y = 1, h do
            newTypes[y] = {}
            for x = 1, w do
                local obstacleCount = 0
                for oy = y-1, y+1 do
                    for ox = x-1, x+1 do
                        if not (ox == x and oy == y) and ox >= 1 and ox <= w and oy >= 1 and oy <= h then
                            if self.tiles[oy][ox].tileType == Constants.TILE_TYPES.OBSTACLE then
                                obstacleCount = obstacleCount + 1
                            end
                        end
                    end
                end

                if obstacleCount >= 5 then
                    newTypes[y][x] = Constants.TILE_TYPES.OBSTACLE
                else
                    newTypes[y][x] = Constants.TILE_TYPES.NORMAL
                end
            end
        end

        for y = 1, h do
            for x = 1, w do
                self.tiles[y][x].tileType = newTypes[y][x]
            end
        end
    end
    -- Enforce obstacle caps / exact count if configured
    local total = w * h
    local maxObstacles = math.floor(total * Constants.MAX_OBSTACLE_PERCENTAGE)
    local exactCount = nil
    if Constants.EXACT_OBSTACLE_COUNT then
        exactCount = math.floor(total * percentage)
    end
    if exactCount then
        maxObstacles = exactCount
    end
        -- count current obstacles
        local obs = {}
        local count = 0
        for y = 1, h do
            for x = 1, w do
                if self.tiles[y][x].tileType == Constants.TILE_TYPES.OBSTACLE then
                    count = count + 1
                    table.insert(obs, { x = x, y = y })
                end
            end
        end
        -- If there are too many obstacles, randomly turn some into normal until at cap
        if count > maxObstacles then
            local toRemove = count - maxObstacles
            -- shuffle obs
            for i = #obs, 2, -1 do
                local j = love.math.random(1, i)
                obs[i], obs[j] = obs[j], obs[i]
            end
            for i = 1, toRemove do
                local p = obs[i]
                if p then
                    self.tiles[p.y][p.x].tileType = Constants.TILE_TYPES.NORMAL
                end
            end
        end
        -- Recount and log obstacle stats for debugging/verification
        local finalCount = 0
        for y = 1, h do
            for x = 1, w do
                if self.tiles[y][x].tileType == Constants.TILE_TYPES.OBSTACLE then
                    finalCount = finalCount + 1
                end
            end
        end
        local finalPct = finalCount / total
        print(string.format("Obstacle generation: %d obstacles (%.2f%% of %d tiles). Max allowed: %d" , finalCount, finalPct * 100, total, maxObstacles))
    end

function Board:addControlPoint(x, y)
    if self:isValidPosition(x, y) then
        self.tiles[y][x].tileType = Constants.TILE_TYPES.CONTROL_POINT
        return true
    end
    return false
end

function Board:getTile(x, y)
    if self:isValidPosition(x, y) then
        return self.tiles[y][x]
    end
    return nil
end

function Board:isValidPosition(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function Board:isWalkable(x, y)
    local tile = self:getTile(x, y)
    return tile and tile:isWalkable()
end

function Board:isOccupied(x, y)
    local tile = self:getTile(x, y)
    return tile and tile:isOccupied()
end

function Board:getPiece(x, y)
    local tile = self:getTile(x, y)
    return tile and tile.piece or nil
end

function Board:setPiece(x, y, piece)
    local tile = self:getTile(x, y)
    if tile then
        tile:setPiece(piece)
        return true
    end
    return false
end

function Board:removePiece(x, y)
    local tile = self:getTile(x, y)
    if tile then
        return tile:removePiece()
    end
    return nil
end

function Board:movePiece(fromX, fromY, toX, toY)
    local piece = self:removePiece(fromX, fromY)
    if piece then
        self:setPiece(toX, toY, piece)
        return true
    end
    return false
end

function Board:draw(camera, activePlayerId)
    local animated = {}
    -- First pass: draw tiles and non-animating pieces
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            local screenX, screenY = camera:worldToScreen((x - 1) * Constants.TILE_SIZE, (y - 1) * Constants.TILE_SIZE)

            -- Only draw tiles that are on screen
            if screenX > -Constants.TILE_SIZE and screenX < Constants.WINDOW_WIDTH and
               screenY > -Constants.TILE_SIZE and screenY < Constants.WINDOW_HEIGHT then
                tile:draw(screenX, screenY, Constants.TILE_SIZE * camera.zoom, camera, activePlayerId)

                -- Collect animating pieces to draw later on top
                if tile.piece then
                    local p = tile.piece
                    if p._anim then
                        -- determine draw Y (prefer animated draw pos if available)
                        local drawY = p._drawPos and p._drawPos.y or screenY
                        table.insert(animated, { piece = p, drawX = p._drawPos and p._drawPos.x or screenX, drawY = drawY })
                    else
                        -- Draw piece if present and visible (static pieces)
                        if tile.isVisible and tile:isVisible(activePlayerId) then
                            tile.piece:draw(screenX, screenY, Constants.TILE_SIZE * camera.zoom, camera, activePlayerId)
                        end
                    end
                end
            end
        end
    end

    -- Draw all animated pieces on top, sorted by screen Y so deeper pieces are drawn first
    table.sort(animated, function(a,b) return a.drawY < b.drawY end)
    for _, entry in ipairs(animated) do
        local p = entry.piece
        -- If animated draw position is present use it, otherwise compute screen pos for piece.x,y
        local dx, dy = entry.drawX, entry.drawY
        if not dx or not dy then
            dx, dy = camera:worldToScreen((p.x - 1) * Constants.TILE_SIZE, (p.y - 1) * Constants.TILE_SIZE)
        end
        -- Draw shadow under animated piece
        local shadowScale = Constants.VISUALS.shadow_scale or 0.7
        local shadowW = Constants.TILE_SIZE * camera.zoom * shadowScale
        local shadowH = shadowW * 0.5
        love.graphics.setColor(Constants.VISUALS.shadow_color.r, Constants.VISUALS.shadow_color.g, Constants.VISUALS.shadow_color.b, Constants.VISUALS.shadow_color.a)
        love.graphics.ellipse("fill", dx + (Constants.TILE_SIZE * camera.zoom) / 2, dy + (Constants.TILE_SIZE * camera.zoom) * 0.85, shadowW / 2, shadowH / 2)
        love.graphics.setColor(1,1,1)
        -- Always draw animated pieces regardless of fog so they remain visible while moving
        p:draw(dx, dy, Constants.TILE_SIZE * camera.zoom, camera, activePlayerId)
    end
end

function Board:getNeighbors(x, y, includeDiagonals)
    local neighbors = {}
    
    -- Orthogonal directions
    local directions = {
        {0, -1},  -- North
        {1, 0},   -- East
        {0, 1},   -- South
        {-1, 0}   -- West
    }
    
    local diags = includeDiagonals or Constants.ALLOW_DIAGONAL_MOVEMENT
    if diags then
        table.insert(directions, {1, -1})  -- NE
        table.insert(directions, {1, 1})   -- SE
        table.insert(directions, {-1, 1})  -- SW
        table.insert(directions, {-1, -1}) -- NW
    end
    
    for _, dir in ipairs(directions) do
        local nx, ny = x + dir[1], y + dir[2]
        if self:isValidPosition(nx, ny) then
            table.insert(neighbors, {x = nx, y = ny, tile = self.tiles[ny][nx]})
        end
    end
    
    return neighbors
end

-- A* pathfinding on the tile grid. Returns array of points from start to goal (inclusive) or nil if no path.
-- allowGoalIfOccupied: if true, the goal may be occupied (useful for attack moves)
function Board:findPath(startX, startY, goalX, goalY, includeDiagonals, allowGoalIfOccupied)
    if not self:isValidPosition(startX, startY) or not self:isValidPosition(goalX, goalY) then
        return nil
    end

    local function heuristic(ax, ay, bx, by)
        -- Manhattan heuristic (works for 4/8-neighbor grids)
        return math.abs(ax - bx) + math.abs(ay - by)
    end

    local openSet = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}

    local function key(x, y) return x .. ',' .. y end

    gScore[key(startX, startY)] = 0
    fScore[key(startX, startY)] = heuristic(startX, startY, goalX, goalY)
    openSet[key(startX, startY)] = { x = startX, y = startY, f = fScore[key(startX, startY)] }

    while next(openSet) do
        -- find node in openSet with lowest f
        local currentKey, current
        for k, v in pairs(openSet) do
            if not current or v.f < current.f then
                currentKey = k
                current = v
            end
        end

        if current.x == goalX and current.y == goalY then
            -- reconstruct path
            local path = {}
            local ck = currentKey
            while ck do
                local px, py = string.match(ck, "(%d+),(%d+)")
                px = tonumber(px); py = tonumber(py)
                table.insert(path, 1, { x = px, y = py })
                ck = cameFrom[ck]
            end
            return path
        end

        openSet[currentKey] = nil

        local neighbors = self:getNeighbors(current.x, current.y, includeDiagonals)
        for _, n in ipairs(neighbors) do
            local nx, ny = n.x, n.y
            local nKey = key(nx, ny)

            -- skip if not walkable
            if not self:isWalkable(nx, ny) then goto continue end

            -- if occupied and not the goal (or goal not allowed), skip
            if self:isOccupied(nx, ny) then
                if not (nx == goalX and ny == goalY and allowGoalIfOccupied) then
                    goto continue
                end
            end

            local tentativeG = gScore[currentKey] + 1
            if not gScore[nKey] or tentativeG < gScore[nKey] then
                cameFrom[nKey] = currentKey
                gScore[nKey] = tentativeG
                fScore[nKey] = tentativeG + heuristic(nx, ny, goalX, goalY)
                openSet[nKey] = { x = nx, y = ny, f = fScore[nKey] }
            end
            ::continue::
        end
    end

    return nil
end

function Board:clearFogForPlayer(playerId, pieces)
    -- First, set all tiles to explored or hidden
    for y = 1, self.height do
        for x = 1, self.width do
            local t = self.tiles[y][x]
            -- If previously visible for this player, mark explored
            if type(t.getFogState) == "function" and t:getFogState(playerId) == Constants.FOW_VISIBLE then
                t:setFogState(playerId, Constants.FOW_EXPLORED)
            end
        end
    end
    
    -- Then reveal tiles within vision range of player's pieces
    for _, piece in ipairs(pieces) do
        if piece.playerId == playerId then
            self:revealTilesAroundPosition(playerId, piece.x, piece.y, piece.vision)
        end
    end
end

function Board:revealTilesAroundPosition(playerId, x, y, range)
    -- Reveal tiles around (x,y) for a specific player
    if not playerId or not x or not y or not range then return end
    for dy = -range, range do
        for dx = -range, range do
            local distance = math.abs(dx) + math.abs(dy) -- Manhattan distance
            if distance <= range then
                local tx, ty = x + dx, y + dy
                if self:isValidPosition(tx, ty) then
                    self.tiles[ty][tx]:setFogState(playerId, Constants.FOW_VISIBLE)
                end
            end
        end
    end
end

return Board






















