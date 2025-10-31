---ExplosionSystem - Area-of-Effect Damage (Vertical Axial Hex)
---
---Handles explosive damage propagation with power falloff, obstacle absorption,
---chain reactions, and visual effects. Uses VERTICAL AXIAL hex system for accurate
---blast radius calculation from epicenter.
---
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - Epicenter position: axial coordinates {q, r}
---  - Blast radius: HexMath.hexesInRange(epicenterQ, epicenterR, radius)
---  - Distance falloff: HexMath.distance(epicenterQ, epicenterR, targetQ, targetR)
---  - LOS blocking: HexMath.hexLine() for obstacle checking
---
---Explosion Mechanics:
---  - Power propagation with hex distance-based falloff
---  - Obstacle absorption reducing blast reach
---  - Chain explosions from volatile objects
---  - Ring-based visual animation (expanding hex rings)
---  - Fire and smoke effect generation
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---Key Exports:
---  - new(battlefield, damageSystem, fireSystem, smokeSystem): Create explosion system
---  - createExplosion(epicenterQ, epicenterR, power, damageType, source): Trigger explosion
---  - calculateBlastRadius(power, obstacles): Calculate effective radius
---  - update(dt): Update active explosions and animations
---
---@module battlescape.effects.explosion_system
---@see engine.battlescape.battle_ecs.hex_math For hex mathematics

-- Explosion System (Vertical Axial)
-- Handles area-of-effect damage with hex-based blast radius

local HexMath = require("battlescape.battle_ecs.hex_math")
local DamageSystem = require("battlescape.combat.damage_system")

local ExplosionSystem = {}
ExplosionSystem.__index = ExplosionSystem

--- Ring animation delay in seconds
ExplosionSystem.RING_DELAY = 0.05  -- 50ms between rings

--- Maximum propagation distance (safety limit)
ExplosionSystem.MAX_PROPAGATION_DISTANCE = 20

--- Create a new explosion system instance
-- @param battlefield table Reference to battlefield for tile queries
-- @param damageSystem table Damage system instance
-- @param fireSystem table Optional fire system instance
-- @param smokeSystem table Optional smoke system instance
-- @return table New ExplosionSystem instance
function ExplosionSystem.new(battlefield, damageSystem, fireSystem, smokeSystem)
    print("[ExplosionSystem] Initializing explosion system")

    local self = setmetatable({}, ExplosionSystem)

    self.battlefield = battlefield
    self.damageSystem = damageSystem or DamageSystem.new()
    self.fireSystem = fireSystem
    self.smokeSystem = smokeSystem

    self.activeExplosions = {}      -- Currently animating explosions
    self.chainExplosionQueue = {}   -- Pending chain explosions

    return self
end

--- Create an explosion at a location (axial coordinates)
-- @param epicenterQ number Epicenter Q (axial) coordinate
-- @param epicenterR number Epicenter R (axial) coordinate
-- @param power number Initial explosion power
-- @param dropoff number Power reduction per hex ring
-- @param damageClass string Damage type (e.g., "explosive")
-- @param createFire boolean Create fire effects
-- @param createSmoke boolean Create smoke effects
-- @return table Explosion data
function ExplosionSystem:createExplosion(epicenterQ, epicenterR, power, dropoff, damageClass, createFire, createSmoke)
    print(string.format("[ExplosionSystem] Creating explosion at hex(%d,%d) power=%d, dropoff=%d",
          epicenterQ, epicenterR, power, dropoff))

    local explosion = {
        q = epicenterQ,
        r = epicenterR,
        power = power,
        dropoff = dropoff,
        damageClass = damageClass or "explosive",
        createFire = createFire or false,
        createSmoke = createSmoke or false,
        rings = {},              -- Damage rings data
        currentRing = 0,         -- Current ring being processed
        animationTimer = 0,      -- Timer for ring animation
        complete = false         -- Is explosion finished
    }

    -- Calculate damage propagation
    self:calculatePropagation(explosion)

    -- Add to active explosions for animation
    table.insert(self.activeExplosions, explosion)

    return explosion
end

--- Calculate damage propagation using flood-fill algorithm (vertical axial)
-- @param explosion table Explosion data with q, r epicenter
function ExplosionSystem:calculatePropagation(explosion)
    local visited = {}  -- Track visited hexes: key = "q,r", value = power
    local queue = {}    -- Queue for BFS: {q, r, power, ring}

    -- Start at epicenter
    table.insert(queue, {
        q = explosion.q,
        r = explosion.r,
        power = explosion.power,
        ring = 0
    })

    local key = string.format("%d,%d", explosion.q, explosion.r)
    visited[key] = explosion.power

    -- BFS flood-fill with hex distance
    while #queue > 0 do
        local current = table.remove(queue, 1)

        -- Safety check
        if current.ring > ExplosionSystem.MAX_PROPAGATION_DISTANCE then
            break
        end

        -- Stop if power is depleted
        if current.power <= 0 then
            goto continue
        end

        -- Store this hex in the appropriate ring
        if not explosion.rings[current.ring] then
            explosion.rings[current.ring] = {}
        end
        table.insert(explosion.rings[current.ring], {
            q = current.q,
            r = current.r,
            power = current.power
        })

        -- Get hex neighbors using HexMath (returns 6 adjacent hexes)
        local neighbors = HexMath.getNeighbors(current.q, current.r)

        -- Limit propagation: epicenter hits all 6 neighbors, others hit max 3
        local maxNeighbors = (current.ring == 0) and 6 or 3
        local neighborCount = 0

        for _, neighbor in ipairs(neighbors) do
            if neighborCount >= maxNeighbors then
                break
            end

            local nq, nr = neighbor.q, neighbor.r

            -- Calculate power after propagation
            local reducedPower = current.power - explosion.dropoff

            -- Apply obstacle absorption
            reducedPower = self:applyObstacleAbsorption(nq, nr, reducedPower)

            if reducedPower > 0 then
                local neighborKey = string.format("%d,%d", nq, nr)

                -- Only visit if we haven't been here or if this path has more power
                if not visited[neighborKey] or visited[neighborKey] < reducedPower then
                    visited[neighborKey] = reducedPower

                    table.insert(queue, {
                        q = nq,
                        r = nr,
                        power = reducedPower,
                        ring = current.ring + 1
                    })

                    neighborCount = neighborCount + 1
                end
            end
        end

        ::continue::
    end

    print("[ExplosionSystem] Propagation calculated: " .. #explosion.rings .. " rings")
end

--- Get hexagonal neighbors (6 adjacent tiles)
-- @param x number Center X
-- @param y number Center Y
-- @return table Array of {x, y} neighbors
function ExplosionSystem:getHexNeighbors(x, y)
    -- Standard hex grid neighbors (flat-top orientation)
    -- This is a simplified version - should match your hex grid system
    return {
        {x = x + 1, y = y},
        {x = x - 1, y = y},
        {x = x, y = y + 1},
        {x = x, y = y - 1},
        {x = x + 1, y = y - 1},
        {x = x - 1, y = y + 1}
    }
end

--- Apply obstacle absorption (units and terrain reduce power)
-- @param x number Tile X
-- @param y number Tile Y
-- @param power number Current power
-- @return number Reduced power
function ExplosionSystem:applyObstacleAbsorption(x, y, power)
    if not self.battlefield then
        return power
    end

    -- Check for units at this location
    local unit = self.battlefield:getUnitAt(x, y)
    if unit and unit.armor then
        local armorValue = unit.armor.value or 0
        power = power - armorValue
        print("[ExplosionSystem] Unit absorbed " .. armorValue .. " power at (" .. x .. "," .. y .. ")")
    end

    -- Check for terrain/walls
    local tile = self.battlefield:getTile(x, y)
    if tile and tile.armor then
        local terrainArmor = tile.armor or 0
        power = power - terrainArmor
        print("[ExplosionSystem] Terrain absorbed " .. terrainArmor .. " power at (" .. x .. "," .. y .. ")")
    end

    return math.max(0, power)
end

--- Update explosion animations
-- @param dt number Delta time in seconds
function ExplosionSystem:update(dt)
    local i = 1
    while i <= #self.activeExplosions do
        local explosion = self.activeExplosions[i]

        if not explosion.complete then
            explosion.animationTimer = explosion.animationTimer + dt

            -- Check if it's time to process the next ring
            if explosion.animationTimer >= ExplosionSystem.RING_DELAY then
                explosion.animationTimer = 0
                explosion.currentRing = explosion.currentRing + 1

                -- Process damage for this ring
                if explosion.rings[explosion.currentRing] then
                    self:processRingDamage(explosion, explosion.currentRing)
                else
                    -- No more rings, explosion complete
                    explosion.complete = true

                    -- Process chain explosions
                    self:processChainExplosions(explosion)
                end
            end

            i = i + 1
        else
            -- Remove completed explosion
            table.remove(self.activeExplosions, i)
        end
    end
end

--- Process damage for a specific ring
-- @param explosion table Explosion data
-- @param ringIndex number Ring index to process
function ExplosionSystem:processRingDamage(explosion, ringIndex)
    local ring = explosion.rings[ringIndex]
    if not ring then return end

    print("[ExplosionSystem] Processing ring " .. ringIndex .. " with " .. #ring .. " tiles")

    for _, tile in ipairs(ring) do
        -- Apply damage to units at this location
        if self.battlefield then
            local unit = self.battlefield:getUnitAt(tile.x, tile.y)
            if unit then
                -- Create a pseudo-projectile for damage calculation
                local projectile = {
                    power = tile.power,
                    damageClass = explosion.damageClass,
                    healthRatio = 0.75,
                    stunRatio = 0.25,
                    moraleRatio = 0.0,
                    energyRatio = 0.0
                }

                self.damageSystem:resolveDamage(projectile, unit)
            end

            -- Check for explosive terrain (for chain reactions)
            local terrain = self.battlefield:getTile(tile.x, tile.y)
            if terrain and terrain.explosive then
                self:queueChainExplosion(tile.x, tile.y, terrain.explosivePower or 5, 2)
            end
        end

        -- Create fire if enabled
        if explosion.createFire and self.fireSystem then
            local terrain = self.battlefield:getTile(tile.x, tile.y)
            if terrain and terrain.flammable then
                self.fireSystem:startFire(tile.x, tile.y)
            end
        end

        -- Create smoke if enabled
        if explosion.createSmoke and self.smokeSystem then
            local terrain = self.battlefield:getTile(tile.x, tile.y)
            if terrain and terrain.smokeable then
                self.smokeSystem:createSmoke(tile.x, tile.y)
            end
        end
    end
end

--- Queue a chain explosion
-- @param x number X position
-- @param y number Y position
-- @param power number Explosion power
-- @param dropoff number Power dropoff
function ExplosionSystem:queueChainExplosion(x, y, power, dropoff)
    print("[ExplosionSystem] Queueing chain explosion at (" .. x .. "," .. y .. ")")

    table.insert(self.chainExplosionQueue, {
        x = x,
        y = y,
        power = power,
        dropoff = dropoff
    })
end

--- Process all queued chain explosions
-- @param triggerExplosion table Explosion that triggered chains
function ExplosionSystem:processChainExplosions(triggerExplosion)
    if #self.chainExplosionQueue == 0 then
        return
    end

    print("[ExplosionSystem] Processing " .. #self.chainExplosionQueue .. " chain explosions")

    -- Process all queued chains
    while #self.chainExplosionQueue > 0 do
        local chain = table.remove(self.chainExplosionQueue, 1)
        self:createExplosion(chain.x, chain.y, chain.power, chain.dropoff,
                           triggerExplosion.damageClass, true, true)
    end
end

--- Get active explosions for rendering
-- @return table Array of active explosions
function ExplosionSystem:getActiveExplosions()
    return self.activeExplosions
end

--- Clear all explosions
function ExplosionSystem:clear()
    print("[ExplosionSystem] Clearing all explosions")
    self.activeExplosions = {}
    self.chainExplosionQueue = {}
end

--- Get debug info
-- @return string Debug information
function ExplosionSystem:getDebugInfo()
    return string.format("ExplosionSystem: %d active, %d queued chains",
        #self.activeExplosions, #self.chainExplosionQueue)
end

return ExplosionSystem
