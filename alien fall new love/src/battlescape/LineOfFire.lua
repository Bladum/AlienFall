--- LineOfFire.lua
-- Implements deterministic ray-tracing framework for firing calculations
-- Uses Amanatides algorithm with supercover rules for stable tile inclusion
-- Provides planner and executor pipelines with miss dispersion

local Class = require("util.Class")
local RNG = require("services.rng")

---@class LineOfFire
---@field private _missionSeed number Mission seed for deterministic calculations
---@field private _map table Reference to battle map
local LineOfFire = Class()

---Initialize LineOfFire system
---@param missionSeed number Mission seed for deterministic RNG
---@param map table Battle map reference
function LineOfFire:init(missionSeed, map)
    self._missionSeed = missionSeed
    self._map = map
end

---Convert tile coordinates to continuous pixel coordinates
---@param tileX number Tile X coordinate
---@param tileY number Tile Y coordinate
---@return number pixelX, number pixelY
function LineOfFire:tileToPixel(tileX, tileY)
    return tileX * 32 + 16, tileY * 32 + 16 -- Center of 32x32 tile
end

---Convert pixel coordinates to tile coordinates
---@param pixelX number Pixel X coordinate
---@param pixelY number Pixel Y coordinate
---@return number tileX, number tileY
function LineOfFire:pixelToTile(pixelX, pixelY)
    return math.floor(pixelX / 32), math.floor(pixelY / 32)
end

---Get blocking value for a tile
---@param tile table Tile data
---@return number blocking Base blocking value (0-1)
function LineOfFire:getTileBlocking(tile)
    local blockingValues = {
        open = 0.0,
        low_cover = 0.3,
        high_cover = 0.7,
        wall = 1.0,
        solid = 1.0
    }

    return blockingValues[tile.coverType] or 0.0
end

---Calculate transmission through a tile fraction
---@param baseBlocking number Base blocking value
---@param fraction number Fraction of tile traversed (0-1)
---@param penetration number Weapon penetration modifier
---@return number transmission Transmission multiplier (0-1)
function LineOfFire:calculateTransmission(baseBlocking, fraction, penetration)
    -- Apply penetration modifier
    local effectiveBlocking = math.max(0, baseBlocking - penetration)

    -- Exponential model: transmission = (1 - blocking)^fraction
    return math.pow(1 - effectiveBlocking, fraction)
end

---Amanatides & Woo fast voxel traversal algorithm
---@param startX number Start pixel X
---@param startY number Start pixel Y
---@param endX number End pixel X
---@param endY number EndY Pixel Y
---@return table traversedTiles List of {x, y, entryFraction, exitFraction, distance}
function LineOfFire:traverseRay(startX, startY, endX, endY)
    local traversedTiles = {}

    local dx = endX - startX
    local dy = endY - startY
    local distance = math.sqrt(dx*dx + dy*dy)

    if distance == 0 then return traversedTiles end

    -- Determine step directions
    local stepX = dx > 0 and 1 or -1
    local stepY = dy > 0 and 1 or -1

    -- Calculate initial tile coordinates
    local tileX = math.floor(startX / 32)
    local tileY = math.floor(startY / 32)

    -- Calculate distances to next tile boundaries
    local nextX = (stepX > 0) and ((tileX + 1) * 32) or (tileX * 32)
    local nextY = (stepY > 0) and ((tileY + 1) * 32) or (tileY * 32)

    -- Calculate tMax and tDelta
    local tMaxX = dx ~= 0 and (nextX - startX) / dx or math.huge
    local tMaxY = dy ~= 0 and (nextY - startY) / dy or math.huge
    local tDeltaX = dx ~= 0 and (32 / math.abs(dx)) or math.huge
    local tDeltaY = dy ~= 0 and (32 / math.abs(dy)) or math.huge

    local t = 0
    local maxT = 1.0

    while t < maxT do
        -- Calculate fraction of tile traversed
        local entryT = t
        local exitT = math.min(tMaxX, tMaxY, maxT)

        if exitT > entryT then
            local fraction = exitT - entryT
            table.insert(traversedTiles, {
                x = tileX,
                y = tileY,
                entryFraction = entryT,
                exitFraction = exitT,
                fraction = fraction,
                distance = distance * entryT
            })
        end

        -- Step to next tile
        if tMaxX < tMaxY then
            tileX = tileX + stepX
            tMaxX = tMaxX + tDeltaX
        else
            tileY = tileY + stepY
            tMaxY = tMaxY + tDeltaY
        end

        t = math.min(tMaxX, tMaxY)
    end

    return traversedTiles
end

---Planner pipeline: simulate firing for hit chance calculation
---@param attacker table Attacking unit
---@param targetTile table {x, y} target tile
---@param weapon table Weapon data
---@return table result {hitChance, transmission, traversedTiles, missRadius}
function LineOfFire:planShot(attacker, targetTile, weapon)
    local startPixelX, startPixelY = self:tileToPixel(attacker.x, attacker.y)
    local targetPixelX, targetPixelY = self:tileToPixel(targetTile.x, targetTile.y)

    -- Traverse ray from attacker to target
    local traversedTiles = self:traverseRay(startPixelX, startPixelY, targetPixelX, targetPixelY)

    -- Calculate cumulative transmission
    local cumulativeTransmission = 1.0
    local totalFraction = 0

    for _, tileData in ipairs(traversedTiles) do
        if self._map:isValidTile(tileData.x, tileData.y) then
            local tile = self._map:getTile(tileData.x, tileData.y)
            local blocking = self:getTileBlocking(tile)
            local transmission = self:calculateTransmission(blocking, tileData.fraction, weapon.penetration or 0)
            cumulativeTransmission = cumulativeTransmission * transmission
            totalFraction = totalFraction + tileData.fraction
        end
    end

    -- Calculate hit chance
    local baseAccuracy = weapon.accuracy or 0.8
    local rangeModifier = math.max(0.1, 1.0 - (totalFraction * 0.1)) -- Range penalty
    local transmissionModifier = cumulativeTransmission

    local hitChance = baseAccuracy * rangeModifier * transmissionModifier

    -- Calculate miss dispersion radius
    local distance = math.sqrt((targetTile.x - attacker.x)^2 + (targetTile.y - attacker.y)^2)
    local distanceFactor = math.min(1.0, distance / 10) -- Normalize to 0-1
    local dispersionScale = weapon.dispersionScale or 3
    local missRadius = math.ceil(distanceFactor * dispersionScale)

    return {
        hitChance = hitChance,
        transmission = cumulativeTransmission,
        traversedTiles = traversedTiles,
        missRadius = missRadius,
        distance = distance
    }
end

---Generate miss dispersion point
---@param targetTile table {x, y} intended target
---@param missRadius number Maximum miss radius
---@param seed number Seed for deterministic randomness
---@return table missTile {x, y} actual impact tile
function LineOfFire:calculateMissDispersion(targetTile, missRadius, seed)
    if missRadius <= 0 then
        return {x = targetTile.x, y = targetTile.y}
    end

    local rng = RNG:createSeededRNG(seed)

    -- Generate random point within diamond/circle radius
    local angle = rng:random() * 2 * math.pi
    local radius = rng:random() * missRadius

    local offsetX = math.floor(radius * math.cos(angle) + 0.5)
    local offsetY = math.floor(radius * math.sin(angle) + 0.5)

    return {
        x = targetTile.x + offsetX,
        y = targetTile.y + offsetY
    }
end

---Executor pipeline: resolve actual shot outcome
---@param planResult table Result from planShot
---@param weapon table Weapon data
---@param actionSeed number Seed for this specific action
---@return table result {hit, impactTile, damage, provenance}
function LineOfFire:executeShot(planResult, weapon, actionSeed)
    local rng = RNG:createSeededRNG(actionSeed)

    -- Determine hit/miss
    local hitRoll = rng:random()
    local isHit = hitRoll <= planResult.hitChance

    local impactTile
    if isHit then
        impactTile = {x = planResult.traversedTiles[#planResult.traversedTiles].x,
                      y = planResult.traversedTiles[#planResult.traversedTiles].y}
    else
        -- Calculate miss dispersion
        local missSeed = actionSeed + 1000 -- Different seed stream for misses
        impactTile = self:calculateMissDispersion(
            {x = planResult.traversedTiles[#planResult.traversedTiles].x,
             y = planResult.traversedTiles[#planResult.traversedTiles].y},
            planResult.missRadius,
            missSeed
        )
    end

    -- Resolve impact (simplified - would integrate with damage system)
    local damage = 0
    if isHit then
        damage = weapon.damage or 10
    end

    return {
        hit = isHit,
        impactTile = impactTile,
        damage = damage,
        provenance = {
            hitRoll = hitRoll,
            hitChance = planResult.hitChance,
            transmission = planResult.transmission,
            traversedTiles = #planResult.traversedTiles,
            missRadius = planResult.missRadius
        }
    }
end

---Check if line of fire exists between two points
---@param startTile table {x, y} start tile
---@param endTile table {x, y} end tile
---@param penetration number Weapon penetration
---@return boolean hasLoF, number transmission
function LineOfFire:hasLineOfFire(startTile, endTile, penetration)
    local startPixelX, startPixelY = self:tileToPixel(startTile.x, startTile.y)
    local endPixelX, endPixelY = self:tileToPixel(endTile.x, endTile.y)

    local traversedTiles = self:traverseRay(startPixelX, startPixelY, endPixelX, endPixelY)

    local cumulativeTransmission = 1.0
    for _, tileData in ipairs(traversedTiles) do
        if self._map:isValidTile(tileData.x, tileData.y) then
            local tile = self._map:getTile(tileData.x, tileData.y)
            local blocking = self:getTileBlocking(tile)
            local transmission = self:calculateTransmission(blocking, tileData.fraction, penetration or 0)
            cumulativeTransmission = cumulativeTransmission * transmission
        end
    end

    return cumulativeTransmission > 0.1, cumulativeTransmission -- Threshold for "clear" LoF
end

return LineOfFire
