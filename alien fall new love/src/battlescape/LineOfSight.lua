--- LineOfSight.lua
-- Implements deterministic visibility model for battlescape
-- Separates personal unit sight from team union visibility for Fog-of-War
-- Uses sight budgets, occlusion costs, and data-driven modifiers

local Class = require("util.Class")
local RNG = require("services.rng")
local PerformanceCache = require("utils.performance_cache")

---@class LineOfSight
---@field private _missionSeed number Mission seed for deterministic calculations
---@field private _map table Reference to battle map for tile queries
---@field private _teamVisibility table Team union visibility state
---@field private _unitVisibility table Individual unit visibility states
---@field private _cache PerformanceCache Performance cache instance
---@field private _currentTurn number Current game turn (for cache invalidation)
local LineOfSight = Class()

---Initialize LineOfSight system
---@param missionSeed number Mission seed for deterministic RNG
---@param map table Battle map reference
---@param cache PerformanceCache Optional performance cache (will create if not provided)
function LineOfSight:init(missionSeed, map, cache)
    self._missionSeed = missionSeed
    self._map = map
    self._teamVisibility = {} -- tile -> visibility state
    self._unitVisibility = {} -- unitId -> {tile -> visibility state}
    self._cache = cache or PerformanceCache()
    self._currentTurn = 0
end

---Calculate effective sight budget for a unit
---@param unit table Unit entity with sight stats
---@param isNight boolean Whether it's night time
---@return number effectiveBudget
function LineOfSight:calculateEffectiveBudget(unit, isNight)
    local baseSight = unit.sight or 15
    local nightMultiplier = isNight and 0.5 or 1.0
    local equipmentBonus = unit.equipmentSightBonus or 0
    local traitBonus = unit.traitSightBonus or 0

    return math.floor((baseSight * nightMultiplier) + equipmentBonus + traitBonus)
end

---Calculate occlusion cost for a tile
---@param tile table Tile data
---@param environmentalEffects table Current environmental effects
---@return number occlusionCost
function LineOfSight:getOcclusionCost(tile, environmentalEffects)
    local baseCosts = {
        open = 1,
        semi_transparent = 2,
        smoke = 3,
        fire = 5,
        solid = 999 -- effectively blocking
    }

    local cost = baseCosts[tile.occlusionType] or 1

    -- Apply environmental modifiers
    if environmentalEffects.smoke and environmentalEffects.smoke[tile.x .. "," .. tile.y] then
        cost = cost + 2
    end
    if environmentalEffects.fire and environmentalEffects.fire[tile.x .. "," .. tile.y] then
        cost = cost + 3
    end

    return cost
end

---Calculate visibility from a unit's position
---@param unit table Unit entity
---@param maxRange number Maximum sight range
---@param isNight boolean Whether it's night time
---@param environmentalEffects table Current environmental effects
---@return table visibleTiles List of {x, y, distance, occlusionAccumulated}
function LineOfSight:calculateUnitVisibility(unit, maxRange, isNight, environmentalEffects)
    -- Check cache first
    local unitId = unit.id or 0
    local cachedVisibility = self._cache:getLOS(unitId, unit.x, unit.y, isNight, self._currentTurn)
    if cachedVisibility then
        return cachedVisibility
    end
    
    local visibleTiles = {}
    local startX, startY = unit.x, unit.y
    local effectiveBudget = self:calculateEffectiveBudget(unit, isNight)

    -- Use seeded RNG for any random elements
    local rng = RNG:createSeededRNG(self._missionSeed + unit.id)

    -- Simple flood fill with occlusion accumulation
    -- In a real implementation, this would use proper line-of-sight rays
    local visited = {}
    local queue = {{x = startX, y = startY, occlusion = 0, distance = 0}}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local key = current.x .. "," .. current.y

        if visited[key] then goto continue end
        visited[key] = true

        -- Check if tile is within budget
        if current.occlusion <= effectiveBudget then
            table.insert(visibleTiles, {
                x = current.x,
                y = current.y,
                distance = current.distance,
                occlusionAccumulated = current.occlusion
            })

            -- Add adjacent tiles if within range
            if current.distance < maxRange then
                local directions = {
                    {0, 1}, {1, 0}, {0, -1}, {-1, 0},
                    {1, 1}, {1, -1}, {-1, 1}, {-1, -1}
                }

                for _, dir in ipairs(directions) do
                    local nextX = current.x + dir[1]
                    local nextY = current.y + dir[2]
                    local nextKey = nextX .. "," .. nextY

                    if not visited[nextKey] and self._map:isValidTile(nextX, nextY) then
                        local tile = self._map:getTile(nextX, nextY)
                        local tileCost = self:getOcclusionCost(tile, environmentalEffects)
                        local newOcclusion = current.occlusion + tileCost
                        local newDistance = current.distance + 1

                        table.insert(queue, {
                            x = nextX,
                            y = nextY,
                            occlusion = newOcclusion,
                            distance = newDistance
                        })
                    end
                end
            end
        end

        ::continue::
    end

    -- Cache the result
    self._cache:cacheLOS(unitId, unit.x, unit.y, isNight, visibleTiles, self._currentTurn)

    return visibleTiles
end

---Update team union visibility from all friendly units
---@param friendlyUnits table List of friendly unit entities
---@param isNight boolean Whether it's night time
---@param environmentalEffects table Current environmental effects
function LineOfSight:updateTeamVisibility(friendlyUnits, isNight, environmentalEffects)
    self._teamVisibility = {}

    for _, unit in ipairs(friendlyUnits) do
        local unitSight = self:calculateUnitVisibility(unit, 20, isNight, environmentalEffects)

        for _, tile in ipairs(unitSight) do
            local key = tile.x .. "," .. tile.y
            if not self._teamVisibility[key] then
                self._teamVisibility[key] = {
                    explored = true,
                    visible = true,
                    lastSeenTurn = self._map:getCurrentTurn()
                }
            end
        end
    end
end

---Update individual unit visibility
---@param unit table Unit entity
---@param isNight boolean Whether it's night time
---@param environmentalEffects table Current environmental effects
function LineOfSight:updateUnitVisibility(unit, isNight, environmentalEffects)
    local unitSight = self:calculateUnitVisibility(unit, 15, isNight, environmentalEffects)
    self._unitVisibility[unit.id] = {}

    for _, tile in ipairs(unitSight) do
        local key = tile.x .. "," .. tile.y
        self._unitVisibility[unit.id][key] = {
            visible = true,
            canFire = true, -- Would check LoF in real implementation
            distance = tile.distance
        }
    end
end

---Check if a tile is visible to team
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return boolean isVisible
function LineOfSight:isTileVisibleToTeam(x, y)
    local key = x .. "," .. y
    return self._teamVisibility[key] and self._teamVisibility[key].visible
end

---Check if a tile is visible to specific unit
---@param unitId number Unit ID
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return boolean isVisible
function LineOfSight:isTileVisibleToUnit(unitId, x, y)
    if not self._unitVisibility[unitId] then return false end
    local key = x .. "," .. y
    return self._unitVisibility[unitId][key] and self._unitVisibility[unitId][key].visible
end

---Get Fog-of-War state for a tile
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return string state ("unexplored"|"explored_dark"|"visible")
function LineOfSight:getTileFogState(x, y)
    local key = x .. "," .. y
    local teamVis = self._teamVisibility[key]

    if not teamVis then
        return "unexplored"
    elseif teamVis.visible then
        return "visible"
    else
        return "explored_dark"
    end
end

---Apply temporary reveal effect (flare, flashlight, etc.)
---@param centerX number Center X coordinate
---@param centerY number Center Y coordinate
---@param radius number Reveal radius
---@param duration number Effect duration in turns
---@param ownerSide string Owning side ("player"|"alien")
function LineOfSight:applyTemporaryReveal(centerX, centerY, radius, duration, ownerSide)
    -- This would create a temporary visibility zone
    -- Implementation depends on how temporary effects are handled
    -- For now, just mark tiles as visible for the duration
    for dx = -radius, radius do
        for dy = -radius, radius do
            if dx*dx + dy*dy <= radius*radius then
                local x, y = centerX + dx, centerY + dy
                if self._map:isValidTile(x, y) then
                    local key = x .. "," .. y
                    self._teamVisibility[key] = {
                        explored = true,
                        visible = true,
                        temporary = true,
                        duration = duration,
                        owner = ownerSide
                    }
                end
            end
        end
    end
end

---Update temporary effects (called each turn)
function LineOfSight:updateTemporaryEffects()
    for key, vis in pairs(self._teamVisibility) do
        if vis.temporary then
            vis.duration = vis.duration - 1
            if vis.duration <= 0 then
                vis.visible = false
                vis.temporary = nil
            end
        end
    end
end

---Update current turn (for cache invalidation)
---@param turn number Current game turn
function LineOfSight:setCurrentTurn(turn)
    self._currentTurn = turn
end

---Invalidate LOS cache (call when environment changes)
function LineOfSight:invalidateCache()
    self._cache:invalidateLOSCache()
end

---Get cache statistics
---@return table stats Cache performance statistics
function LineOfSight:getCacheStatistics()
    return self._cache:getStatistics()
end

return LineOfSight
