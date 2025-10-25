---ProjectileSystem - Active Projectile Manager
---
---Manages all active projectiles in the battlescape. Handles projectile creation, update
---loop, collision detection, and impact resolution. Integrates with damage and explosion
---systems for combat resolution.
---
---Features:
---  - Active projectile tracking
---  - Projectile creation and lifecycle
---  - Collision detection (tiles, units, obstacles)
---  - Impact resolution (damage, explosions)
---  - Projectile pooling for performance
---  - Visual effects coordination
---
---Projectile Lifecycle:
---  1. Create: Spawn projectile at shooter position
---  2. Update: Move projectile along trajectory
---  3. Collision: Check for hits each frame
---  4. Impact: Apply damage/effects on hit
---  5. Destroy: Remove projectile and cleanup
---
---Collision Detection:
---  - Unit collision: Direct hit on enemy unit
---  - Tile collision: Hit wall or obstacle
---  - Miss: Projectile reaches max range
---
---Key Exports:
---  - ProjectileSystem.new(battlefield, damageSystem, explosionSystem): Creates system
---  - createProjectile(options): Spawns new projectile
---  - update(dt): Updates all active projectiles
---  - draw(): Renders all projectiles
---  - removeProjectile(projectile): Destroys specific projectile
---  - clear(): Removes all projectiles
---  - getActiveCount(): Returns number of active projectiles
---
---Dependencies:
---  - battlescape.entities.projectile: Projectile entity
---  - battlescape.maps.trajectory: Trajectory calculation
---
---@module battlescape.combat.projectile_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ProjectileSystem = require("battlescape.combat.projectile_system")
---  local projectiles = ProjectileSystem.new(battlefield, damageSys, explosionSys)
---  projectiles:createProjectile({
---    startX = 5, startY = 10,
---    targetX = 12, targetY = 15,
---    damage = 25, damageType = "kinetic"
---  })
---  projectiles:update(dt)
---  projectiles:draw()
---
---@see battlescape.entities.projectile For projectile entity

-- Projectile System
-- Manages all active projectiles in the battlescape
-- Handles creation, update, collision detection, and impact resolution

local Projectile = require("battlescape.entities.projectile")
local Trajectory = require("battlescape.maps.trajectory")

local ProjectileSystem = {}
ProjectileSystem.__index = ProjectileSystem

--- Create a new projectile system instance
-- @param battlefield table Reference to battlefield for collision queries
-- @param damageSystem table Damage system instance
-- @param explosionSystem table Explosion system instance
-- @return table New ProjectileSystem instance
function ProjectileSystem.new(battlefield, damageSystem, explosionSystem)
    print("[ProjectileSystem] Initializing projectile system")
    
    local self = setmetatable({}, ProjectileSystem)
    
    self.battlefield = battlefield
    self.damageSystem = damageSystem
    self.explosionSystem = explosionSystem
    self.activeProjectiles = {}  -- Array of active projectiles
    self.pendingImpacts = {}     -- Impacts waiting to be processed
    
    return self
end

--- Create and launch a projectile
-- @param options table Projectile configuration
-- @return table Created projectile entity
function ProjectileSystem:createProjectile(options)
    local projectile = Projectile.new(options)
    table.insert(self.activeProjectiles, projectile)
    
    print("[ProjectileSystem] Created projectile: " .. projectile:getDebugInfo())
    
    return projectile
end

--- Create projectile from weapon fire
-- @param weapon table Weapon data
-- @param shooterUnit table Unit firing the weapon
-- @param startX number Starting X position
-- @param startY number Starting Y position
-- @param targetX number Target X position
-- @param targetY number Target Y position
-- @return table Created projectile
function ProjectileSystem:createProjectileFromWeapon(weapon, shooterUnit, startX, startY, targetX, targetY)
    -- Default weapon properties if not specified
    local velocity = weapon.projectileVelocity or 500
    local trajectoryType = weapon.trajectoryType or "straight"
    local arcHeight = weapon.arcHeight or 3.0
    
    -- Damage properties
    local damageType = weapon.areaOfEffect and "area" or "point"
    local power = weapon.power or 10
    local dropoff = weapon.dropoff or 2
    local damageClass = weapon.damageClass or "kinetic"
    
    -- Damage distribution ratios
    local stunRatio = weapon.stunRatio or 0.25
    local healthRatio = weapon.healthRatio or 0.75
    local moraleRatio = weapon.moraleRatio or 0.0
    local energyRatio = weapon.energyRatio or 0.0
    
    local options = {
        startX = startX,
        startY = startY,
        targetX = targetX,
        targetY = targetY,
        velocity = velocity,
        trajectoryType = trajectoryType,
        arcHeight = arcHeight,
        damageType = damageType,
        power = power,
        dropoff = dropoff,
        damageClass = damageClass,
        stunRatio = stunRatio,
        healthRatio = healthRatio,
        moraleRatio = moraleRatio,
        energyRatio = energyRatio,
        shooterUnit = shooterUnit,
        weaponId = weapon.id,
        sprite = weapon.projectileSprite,
        color = weapon.projectileColor or {255, 255, 0},
        size = weapon.projectileSize or 3
    }
    
    return self:createProjectile(options)
end

--- Update all active projectiles
-- @param dt number Delta time in seconds
function ProjectileSystem:update(dt)
    local i = 1
    while i <= #self.activeProjectiles do
        local projectile = self.activeProjectiles[i]
        
        -- Update projectile
        local stillActive = projectile:update(dt)
        
        if not stillActive then
            -- Projectile reached target or impacted
            self:handleImpact(projectile)
            
            -- Remove from active list
            table.remove(self.activeProjectiles, i)
        else
            -- Check for collision with terrain or units
            if self:checkCollision(projectile) then
                -- Collision detected, mark impact and remove
                table.remove(self.activeProjectiles, i)
            else
                i = i + 1
            end
        end
    end
end

--- Check for collision with terrain or units
-- @param projectile table Projectile to check
-- @return boolean True if collision detected
function ProjectileSystem:checkCollision(projectile)
    local tileX = projectile.x
    local tileY = projectile.y
    
    -- Check for terrain collision (walls, obstacles)
    if self.battlefield then
        local tile = self.battlefield:getTile(tileX, tileY)
        if tile and tile.blocksMovement then
            print("[ProjectileSystem] Projectile hit terrain at (" .. tileX .. "," .. tileY .. ")")
            projectile:markImpact(nil, tileX, tileY)
            self:handleImpact(projectile)
            return true
        end
        
        -- Check for unit collision (if not targeting that exact tile)
        if tileX ~= projectile.targetX or tileY ~= projectile.targetY then
            local unit = self.battlefield:getUnitAt(tileX, tileY)
            if unit then
                print("[ProjectileSystem] Projectile hit unit at (" .. tileX .. "," .. tileY .. ")")
                projectile:markImpact(unit, tileX, tileY)
                self:handleImpact(projectile)
                return true
            end
        end
    end
    
    return false
end

--- Handle projectile impact (damage, explosions, effects)
-- @param projectile table Impacted projectile
function ProjectileSystem:handleImpact(projectile)
    print("[ProjectileSystem] Processing impact at (" .. (projectile.impactX or projectile.x) .. 
          "," .. (projectile.impactY or projectile.y) .. ")")
    
    local impactX = projectile.impactX or projectile.x
    local impactY = projectile.impactY or projectile.y
    
    -- Check if this is area damage (explosion)
    if projectile.damageType == "area" and self.explosionSystem then
        -- Create explosion for area damage
        self.explosionSystem:createExplosion(
            impactX, 
            impactY, 
            projectile.power, 
            projectile.dropoff, 
            projectile.damageClass, 
            true,  -- create fire
            true   -- create smoke
        )
    else
        -- Point damage - apply directly to target unit if hit
        if projectile.targetUnit and self.damageSystem then
            local damageResult = self.damageSystem:resolveDamage(projectile, projectile.targetUnit)
            print("[ProjectileSystem] Applied point damage: " .. damageResult.healthDamage .. " HP")
        end
    end
    
    -- Impact visual effects are handled by the battlescape rendering system
    
    -- Queue impact for any additional processing if needed
    table.insert(self.pendingImpacts, {
        projectile = projectile,
        x = impactX,
        y = impactY,
        timestamp = love.timer.getTime()
    })
end

--- Get all pending impacts for processing
-- @return table Array of pending impact data
function ProjectileSystem:getPendingImpacts()
    return self.pendingImpacts
end

--- Clear processed impacts
function ProjectileSystem:clearPendingImpacts()
    self.pendingImpacts = {}
end

--- Get all active projectiles for rendering
-- @return table Array of active projectiles
function ProjectileSystem:getActiveProjectiles()
    return self.activeProjectiles
end

--- Clear all projectiles (for cleanup or reset)
function ProjectileSystem:clear()
    print("[ProjectileSystem] Clearing all projectiles")
    self.activeProjectiles = {}
    self.pendingImpacts = {}
end

--- Get projectile count for debugging
-- @return number Number of active projectiles
function ProjectileSystem:getProjectileCount()
    return #self.activeProjectiles
end

--- Debug info
-- @return string Debug information
function ProjectileSystem:getDebugInfo()
    return string.format("ProjectileSystem: %d active, %d pending impacts",
        #self.activeProjectiles, #self.pendingImpacts)
end

return ProjectileSystem


























