---ExplosionSystem - Area-of-Effect Damage and Visual Effects
---
---Handles explosive damage propagation with power falloff, obstacle absorption,
---chain reactions, and visual ring animations. Creates fire and smoke effects
---at explosion sites. Core system for grenades, rockets, and explosive weapons.
---
---Explosion Mechanics:
---  - Power propagation with distance-based falloff
---  - Obstacle absorption reducing blast radius
---  - Chain explosions from volatile objects
---  - Ring-based visual animation (expanding circles)
---  - Fire and smoke effect generation
---
---Features:
---  - Configurable blast radius and power curves
---  - Terrain-based damage absorption
---  - Unit damage calculation with cover modifiers
---  - Visual ring animation with timing control
---  - Integration with fire and smoke systems
---  - Performance optimization for large explosions
---
---Key Exports:
---  - new(battlefield, damageSystem, fireSystem, smokeSystem): Create explosion system
---  - createExplosion(centerX, centerY, power, damageType, source): Trigger explosion
---  - calculateBlastRadius(power, obstacles): Calculate effective radius
---  - propagatePower(centerX, centerY, power, maxDistance): Calculate power falloff
---  - createRingAnimation(centerX, centerY, maxRadius): Create visual ring effect
---  - update(dt): Update active explosions and animations
---
---Dependencies:
---  - require("battlescape.combat.damage_system"): Damage calculation
---  - require("battlescape.effects.fire_system"): Fire effect creation
---  - require("battlescape.effects.smoke_system"): Smoke effect creation
---
---@module battlescape.effects.explosion_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ExplosionSystem = require("battlescape.effects.explosion_system")
---  local explosions = ExplosionSystem.new(battlefield, damageSystem)
---  explosions:createExplosion(10, 10, 100, "explosive", unit)
---
---@see battlescape.combat.damage_system For damage calculations
---@see battlescape.effects.fire_system For fire effects
---@see battlescape.effects.smoke_system For smoke effects

-- Explosion System
-- Handles area-of-effect damage with power propagation, obstacle absorption,
-- chain explosions, fire/smoke creation, and ring animation

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

--- Create an explosion at a location
-- @param x number Epicenter X position
-- @param y number Epicenter Y position
-- @param power number Initial explosion power
-- @param dropoff number Power reduction per ring
-- @param damageClass string Damage type (e.g., "explosive")
-- @param createFire boolean Create fire effects
-- @param createSmoke boolean Create smoke effects
-- @return table Explosion data
function ExplosionSystem:createExplosion(x, y, power, dropoff, damageClass, createFire, createSmoke)
    print("[ExplosionSystem] Creating explosion at (" .. x .. "," .. y .. ") power=" .. 
          power .. ", dropoff=" .. dropoff)
    
    local explosion = {
        x = x,
        y = y,
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

--- Calculate damage propagation using flood-fill algorithm
-- @param explosion table Explosion data
function ExplosionSystem:calculatePropagation(explosion)
    local visited = {}  -- Track visited tiles: key = "x,y", value = power
    local queue = {}    -- Queue for BFS: {x, y, power, ring}
    
    -- Start at epicenter
    table.insert(queue, {
        x = explosion.x,
        y = explosion.y,
        power = explosion.power,
        ring = 0
    })
    
    local key = explosion.x .. "," .. explosion.y
    visited[key] = explosion.power
    
    -- BFS flood-fill
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
        
        -- Store this tile in the appropriate ring
        if not explosion.rings[current.ring] then
            explosion.rings[current.ring] = {}
        end
        table.insert(explosion.rings[current.ring], {
            x = current.x,
            y = current.y,
            power = current.power
        })
        
        -- Get neighbors
        local neighbors = self:getHexNeighbors(current.x, current.y)
        
        -- Limit propagation: epicenter hits all 6 neighbors, others hit max 3
        local maxNeighbors = (current.ring == 0) and 6 or 3
        local neighborCount = 0
        
        for _, neighbor in ipairs(neighbors) do
            if neighborCount >= maxNeighbors then
                break
            end
            
            -- Calculate power after propagation
            local reducedPower = current.power - explosion.dropoff
            
            -- Apply obstacle absorption
            reducedPower = self:applyObstacleAbsorption(neighbor.x, neighbor.y, reducedPower)
            
            if reducedPower > 0 then
                local neighborKey = neighbor.x .. "," .. neighbor.y
                
                -- Only visit if we haven't been here or if this path has more power
                if not visited[neighborKey] or visited[neighborKey] < reducedPower then
                    visited[neighborKey] = reducedPower
                    
                    table.insert(queue, {
                        x = neighbor.x,
                        y = neighbor.y,
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






















