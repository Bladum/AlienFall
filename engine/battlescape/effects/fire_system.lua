---FireSystem - Fire Propagation and Damage Management
---
---Manages fire spreading across the battlefield, unit damage from flames, and
---smoke production. Fire spreads to adjacent flammable tiles based on terrain
---properties and random chance. Binary fire state (on/off) with duration tracking.
---
---Fire Mechanics:
---  - Terrain-based flammability (wood burns, metal doesn't)
---  - Adjacent tile spread with probability calculations
---  - Unit damage when standing in fire tiles
---  - Smoke generation affecting visibility
---  - Fire duration with natural burnout
---
---Features:
---  - Probabilistic fire spread based on terrain
---  - Unit damage calculation and application
---  - Smoke cloud generation and management
---  - Fire grid optimization for fast lookups
---  - Integration with explosion system
---  - Visual fire effects rendering
---
---Key Exports:
---  - new(): Create new fire system instance
---  - startFire(x, y, duration): Start fire at tile position
---  - extinguishFire(x, y): Put out fire at position
---  - spreadFire(): Process fire propagation each turn
---  - damageUnitsInFire(): Apply damage to units in fire
---  - isTileOnFire(x, y): Check if tile has active fire
---  - update(dt): Update fire durations and effects
---
---Dependencies:
---  - require("battlescape.battle_ecs.hex_math"): Hex coordinate calculations
---  - Battlefield reference for terrain checking
---
---@module battlescape.effects.fire_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local FireSystem = require("battlescape.effects.fire_system")
---  local fire = FireSystem.new()
---  fire:startFire(10, 10, 5)  -- Burn for 5 turns
---  fire:spreadFire()  -- Process fire propagation
---
---@see battlescape.effects.smoke_system For smoke generation
---@see battlescape.effects.explosion_system For fire ignition

-- Fire System
-- Manages fire spreading, unit damage, and smoke production
-- Fire is binary (on/off), spreads based on terrain flammability

local HexMath = require("battlescape.battle_ecs.hex_math")

--- @class FireSystem
--- Manages fire propagation, damage, and smoke generation in tactical combat.
--- Fire spreads to adjacent flammable tiles based on terrain properties and random chance.
--- Damages units standing in fire tiles and produces smoke that affects visibility.
---
--- @field activeFires table[] Array of active fire objects with {x, y, duration} fields
--- @field fireGrid table[][] 2D boolean grid for O(1) fire lookup [y][x] = true
local FireSystem = {}
FireSystem.__index = FireSystem

---
--- Configuration
---

local CONFIG = {
    fireSpreadChance = 0.3,  -- 30% chance to spread per turn
    fireDamagePerTurn = 5,    -- HP damage to units in fire
    smokeProductionChance = 0.7,  -- 70% chance to produce smoke per turn
    fireStartChance = 0.05,    -- 5% random fire start chance (if enabled)
}

---
--- Constructor
---

--- Creates a new fire system instance.
---
--- @return FireSystem A new FireSystem instance with empty fire tracking
function FireSystem.new()
    local self = setmetatable({}, FireSystem)
    self.activeFires = {}  -- Array of {x, y, duration}
    self.fireGrid = {}     -- [y][x] = true for O(1) lookup
    return self
end

---
--- Fire Management
---

--- Starts a fire at the specified position if the tile is flammable and not already burning.
---
--- @param battlefield table The battlefield containing the tile
--- @param x number Tile X coordinate (1-based)
--- @param y number Tile Y coordinate (1-based)
--- @return boolean True if fire was started, false otherwise
function FireSystem:startFire(battlefield, x, y)
    if not battlefield or not battlefield:isValidTile(x, y) then
        return false
    end

    local tile = battlefield:getTile(x, y)
    if not tile or not tile.terrain then
        return false
    end

    -- Check if tile is flammable
    local flammability = tile.terrain.flammability or 0
    if flammability <= 0 then
        print(string.format("[FireSystem] Tile (%d, %d) is not flammable (terrain: %s)",
            x, y, tile.terrain.id))
        return false
    end

    -- Check if already on fire
    if tile.effects and tile.effects.fire then
        return false
    end

    -- Initialize effects table if needed
    if not tile.effects then
        tile.effects = {}
    end

    -- Start fire
    tile.effects.fire = true
    tile.effects.fireDuration = 0

    -- Add to active fires list
    table.insert(self.activeFires, {x = x, y = y, duration = 0})

    -- Add to fire grid for O(1) lookup
    if not self.fireGrid[y] then
        self.fireGrid[y] = {}
    end
    self.fireGrid[y][x] = true

    print(string.format("[FireSystem] Fire started at (%d, %d)", x, y))
    return true
end

--- Stops the fire at the specified position if one exists.
---
--- @param battlefield table The battlefield containing the tile
--- @param x number Tile X coordinate (1-based)
--- @param y number Tile Y coordinate (1-based)
function FireSystem:stopFire(battlefield, x, y)
    local tile = battlefield:getTile(x, y)
    if tile and tile.effects and tile.effects.fire then
        tile.effects.fire = false
        tile.effects.fireDuration = nil

        -- Remove from grid
        if self.fireGrid[y] then
            self.fireGrid[y][x] = nil
        end

        -- Remove from active fires list
        for i = #self.activeFires, 1, -1 do
            local fire = self.activeFires[i]
            if fire.x == x and fire.y == y then
                table.remove(self.activeFires, i)
                break
            end
        end

        print(string.format("[FireSystem] Fire extinguished at (%d, %d)", x, y))
    end
end

--- Checks if the specified tile position has an active fire.
---
--- @param x number Tile X coordinate (1-based)
--- @param y number Tile Y coordinate (1-based)
--- @return boolean True if tile has fire, false otherwise
function FireSystem:hasFire(x, y)
    return self.fireGrid[y] and self.fireGrid[y][x] == true
end

---
--- Fire Spreading
---

--- Attempts to spread fire from the specified position to adjacent flammable tiles.
--- Uses hex neighbors and considers terrain flammability in spread probability.
---
--- @param battlefield table The battlefield containing the tiles
--- @param x number Source tile X coordinate (1-based)
--- @param y number Source tile Y coordinate (1-based)
function FireSystem:spreadFire(battlefield, x, y)
    local tile = battlefield:getTile(x, y)
    if not tile or not tile.effects or not tile.effects.fire then
        return
    end

    -- Get hex neighbors
    local q, r = HexMath.offsetToAxial(x, y)
    local neighbors = HexMath.getNeighbors(q, r)

    local spreadCount = 0
    for _, neighbor in ipairs(neighbors) do
        local nx, ny = HexMath.axialToOffset(neighbor.q, neighbor.r)

        -- Check if neighbor is valid and not already on fire
        if battlefield:isValidTile(nx, ny) then
            local neighborTile = battlefield:getTile(nx, ny)

            if neighborTile and not (neighborTile.effects and neighborTile.effects.fire) then
                local flammability = neighborTile.terrain.flammability or 0

                -- Roll for spread
                if flammability > 0 and math.random() < (CONFIG.fireSpreadChance * flammability) then
                    self:startFire(battlefield, nx, ny)
                    spreadCount = spreadCount + 1
                end
            end
        end
    end

    if spreadCount > 0 then
        print(string.format("[FireSystem] Fire at (%d, %d) spread to %d tiles", x, y, spreadCount))
    end
end

---
--- Smoke Production
---

--- Produces smoke in adjacent empty tiles around a fire.
--- Smoke affects visibility and can spread independently of fire.
---
--- @param battlefield table The battlefield containing the tiles
--- @param x number Fire tile X coordinate (1-based)
--- @param y number Fire tile Y coordinate (1-based)
--- @param smokeSystem table The smoke system to add smoke to
function FireSystem:produceSmoke(battlefield, x, y, smokeSystem)
    if not smokeSystem then return end

    local tile = battlefield:getTile(x, y)
    if not tile or not tile.effects or not tile.effects.fire then
        return
    end

    -- Get hex neighbors
    local q, r = HexMath.offsetToAxial(x, y)
    local neighbors = HexMath.getNeighbors(q, r)

    for _, neighbor in ipairs(neighbors) do
        local nx, ny = HexMath.axialToOffset(neighbor.q, neighbor.r)

        if battlefield:isValidTile(nx, ny) then
            local neighborTile = battlefield:getTile(nx, ny)

            -- Produce smoke if random chance succeeds
            if neighborTile and math.random() < CONFIG.smokeProductionChance then
                -- Smoke only on empty tiles (not walls)
                if not neighborTile.terrain.blocksSight then
                    smokeSystem:addSmoke(battlefield, nx, ny, 1)
                end
            end
        end
    end
end

---
--- Unit Damage
---

--- Damages all units standing in fire tiles and kills them if health reaches zero.
---
--- @param units table Table of units to check for fire damage
--- @return number Number of units that took damage
function FireSystem:damageUnitsInFire(units)
    local damagedCount = 0

    for _, unit in pairs(units) do
        if unit and unit.alive and self:hasFire(unit.x, unit.y) then
            unit.health = unit.health - CONFIG.fireDamagePerTurn

            if unit.health <= 0 then
                unit.health = 0
                unit.alive = false
                print(string.format("[FireSystem] %s killed by fire at (%d, %d)",
                    unit.name, unit.x, unit.y))
            else
                print(string.format("[FireSystem] %s took %d fire damage at (%d, %d) (HP: %d/%d)",
                    unit.name, CONFIG.fireDamagePerTurn, unit.x, unit.y, unit.health, unit.maxHealth))
            end

            damagedCount = damagedCount + 1
        end
    end

    return damagedCount
end

---
--- Turn Update
---

--- Updates all fires for a new turn: spreads fire, produces smoke, and damages units.
--- Should be called once per turn in the battle system.
---
--- @param battlefield table The battlefield containing fire tiles
--- @param units table Table of units that may be affected by fire
--- @param smokeSystem table|nil Optional smoke system for smoke production
function FireSystem:update(battlefield, units, smokeSystem)
    local updateStartTime = love and love.timer and love.timer.getTime() or 0

    print(string.format("[FireSystem] Update: %d active fires", #self.activeFires))

    -- Update fire duration and spread
    local firesToSpread = {}
    for i, fire in ipairs(self.activeFires) do
        local tile = battlefield:getTile(fire.x, fire.y)
        if tile and tile.effects and tile.effects.fire then
            -- Increment duration
            fire.duration = fire.duration + 1
            tile.effects.fireDuration = fire.duration

            -- Mark for spreading
            table.insert(firesToSpread, {x = fire.x, y = fire.y})
        end
    end

    -- Spread fires (do this after iteration to avoid modifying during iteration)
    for _, fire in ipairs(firesToSpread) do
        self:spreadFire(battlefield, fire.x, fire.y)

        -- Produce smoke
        if smokeSystem then
            self:produceSmoke(battlefield, fire.x, fire.y, smokeSystem)
        end
    end

    -- Damage units in fire
    local damagedCount = self:damageUnitsInFire(units)
    if damagedCount > 0 then
        print(string.format("[FireSystem] Damaged %d units in fire", damagedCount))
    end

    if love and love.timer then
        local updateTime = (love.timer.getTime() - updateStartTime) * 1000
        print(string.format("[FireSystem] Update complete in %.3f ms", updateTime))
    end
end

---
--- Statistics
---

--- Gets the current number of active fires.
---
--- @return number Number of active fires
function FireSystem:getFireCount()
    return #self.activeFires
end

--- Clears all active fires from the battlefield.
---
--- @param battlefield table The battlefield to clear fires from
function FireSystem:clearAllFires(battlefield)
    for i = #self.activeFires, 1, -1 do
        local fire = self.activeFires[i]
        self:stopFire(battlefield, fire.x, fire.y)
    end
    print("[FireSystem] All fires cleared")
end

return FireSystem






















