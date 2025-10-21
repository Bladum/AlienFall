---Projectile Entity - In-Flight Weapon Projectile
---
---Represents a projectile in flight from a weapon attack. Used for bullets, lasers,
---grenades, thrown items, and other ranged attacks. Handles trajectory, animation,
---collision detection, and impact effects.
---
---Features:
---  - Smooth animation from start to end position
---  - Trajectory calculation
---  - Collision detection with obstacles and units
---  - Impact effects (damage, explosion, smoke)
---  - Visual representation (sprite, trail, particle effects)
---  - Multiple projectile types (ballistic, beam, arc, thrown)
---
---Projectile Types:
---  - Ballistic: Straight-line bullets (rifles, pistols)
---  - Beam: Instant laser/plasma beams
---  - Arc: Parabolic grenades and thrown items
---  - Guided: Tracking missiles
---
---Projectile Properties:
---  - Position: Current grid coordinates and animated position
---  - Velocity: Speed and direction
---  - Damage: Weapon damage and type
---  - Range: Maximum travel distance
---  - Visual: Sprite, color, trail effects
---
---Key Exports:
---  - Projectile.new(options): Creates new projectile
---  - update(dt): Updates position and checks collisions
---  - draw(): Renders projectile visual
---  - hasReachedTarget(): Checks if arrived at destination
---  - getPosition(): Returns current position
---  - destroy(): Removes projectile and triggers impact
---
---Dependencies:
---  - None (standalone entity)
---
---@module battlescape.entities.projectile
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Projectile = require("battlescape.entities.projectile")
---  local bullet = Projectile.new({
---    startX = 5, startY = 10,
---    targetX = 12, targetY = 15,
---    speed = 20,
---    damage = 25,
---    damageType = "kinetic"
---  })
---  bullet:update(dt)
---  bullet:draw()
---
---@see battlescape.combat.projectile_system For projectile management

-- Projectile Entity
-- Represents a projectile in flight from a weapon attack
-- Used for bullets, lasers, grenades, thrown items, etc.

local Projectile = {}
Projectile.__index = Projectile

--- Create a new projectile entity
-- @param options table Configuration table with projectile properties
-- @return table New projectile instance
function Projectile.new(options)
    print("[Projectile] Creating new projectile entity")
    
    local self = setmetatable({}, Projectile)
    
    -- Position data
    self.type = "projectile"
    self.x = options.startX or 0           -- Current grid X position
    self.y = options.startY or 0           -- Current grid Y position
    self.animX = options.startX or 0       -- Interpolated X for smooth animation
    self.animY = options.startY or 0       -- Interpolated Y for smooth animation
    self.startX = options.startX or 0      -- Starting position
    self.startY = options.startY or 0
    self.targetX = options.targetX or 0    -- Target position
    self.targetY = options.targetY or 0
    
    -- Movement data
    self.velocity = options.velocity or 500    -- Pixels per second
    self.travelled = 0                         -- Distance travelled so far
    self.maxDistance = 0                       -- Total distance to travel (calculated)
    self.active = true                         -- Is projectile in flight
    
    -- Trajectory type
    self.trajectoryType = options.trajectoryType or "straight"  -- straight, arc, beam
    self.arcHeight = options.arcHeight or 0                      -- For arc trajectories
    
    -- Damage properties
    self.damageMethod = options.damageMethod or "point"     -- POINT or AREA (how damage is applied)
    self.power = options.power or 10                        -- Base damage
    self.dropoff = options.dropoff or 2                     -- For area damage
    self.damageType = options.damageType or "kinetic"       -- Damage type (kinetic, plasma, laser, etc)
    self.damageModel = options.damageModel or "hurt"        -- Damage model (stun, hurt, morale, energy)
    
    -- Visual properties
    self.sprite = options.sprite or nil           -- Projectile sprite/effect
    self.trailEffect = options.trailEffect or nil -- Visual trail
    self.color = options.color or {255, 255, 0}   -- Default yellow
    self.size = options.size or 3                 -- Pixel size for simple rendering
    
    -- Collision properties
    self.hitUnit = nil        -- Unit that was hit (if any)
    self.hitTerrain = false   -- Did projectile hit terrain/wall
    self.impactX = nil        -- Final impact X position
    self.impactY = nil        -- Final impact Y position
    
    -- Source information
    self.shooterUnit = options.shooterUnit or nil  -- Who fired this projectile
    self.weaponId = options.weaponId or nil        -- What weapon fired this
    
    -- Calculate total distance to travel
    local dx = self.targetX - self.startX
    local dy = self.targetY - self.startY
    self.maxDistance = math.sqrt(dx * dx + dy * dy)
    
    print("[Projectile] Created: from (" .. self.startX .. "," .. self.startY .. ") to (" .. 
          self.targetX .. "," .. self.targetY .. ") distance=" .. self.maxDistance)
    
    return self
end

--- Update projectile position based on time delta
-- @param dt number Delta time in seconds
-- @return boolean True if projectile is still active, false if reached target
function Projectile:update(dt)
    if not self.active then
        return false
    end
    
    -- Move projectile
    local moveDistance = self.velocity * dt
    self.travelled = self.travelled + moveDistance
    
    -- Check if reached target
    if self.travelled >= self.maxDistance then
        self.travelled = self.maxDistance
        self.active = false
        self.animX = self.targetX
        self.animY = self.targetY
        self.x = math.floor(self.targetX + 0.5)
        self.y = math.floor(self.targetY + 0.5)
        return false
    end
    
    -- Calculate interpolated position
    local progress = self.travelled / self.maxDistance
    self.animX = self.startX + (self.targetX - self.startX) * progress
    self.animY = self.startY + (self.targetY - self.startY) * progress
    
    -- Apply arc trajectory if needed
    if self.trajectoryType == "arc" then
        -- Parabolic arc: height peaks at midpoint
        local arcProgress = 1.0 - math.abs(2.0 * progress - 1.0)  -- 0 -> 1 -> 0
        self.animY = self.animY - self.arcHeight * arcProgress
    end
    
    -- Update grid position
    self.x = math.floor(self.animX + 0.5)
    self.y = math.floor(self.animY + 0.5)
    
    return true
end

--- Get current position for rendering
-- @return number, number Animated X and Y positions
function Projectile:getAnimatedPosition()
    return self.animX, self.animY
end

--- Mark projectile as having hit something
-- @param targetUnit table Optional unit that was hit
-- @param impactX number Impact X position
-- @param impactY number Impact Y position
function Projectile:markImpact(targetUnit, impactX, impactY)
    self.active = false
    self.hitUnit = targetUnit
    self.hitTerrain = (targetUnit == nil)
    self.impactX = impactX or self.x
    self.impactY = impactY or self.y
    
    print("[Projectile] Impact at (" .. self.impactX .. "," .. self.impactY .. ")")
end

--- Check if projectile has reached target or impacted
-- @return boolean True if projectile is finished
function Projectile:isFinished()
    return not self.active
end

--- Get projectile info for debugging
-- @return string Debug info string
function Projectile:getDebugInfo()
    return string.format("Projectile at (%.1f, %.1f) -> (%.1f, %.1f) | Progress: %.1f%% | Active: %s",
        self.animX, self.animY, self.targetX, self.targetY,
        (self.travelled / self.maxDistance) * 100, tostring(self.active))
end

return Projectile

























