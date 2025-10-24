-- 3D Shooting System for First-Person Combat
-- Handles shooting mechanics, hit calculations, and feedback visualization

local ShootingSystem = {}
local BulletTracer = require("battlescape.combat.bullet_tracer")
local CombatIntegration = require("battlescape.combat.combat_integration_3d")

-- Shooting state
local SHOT_STATE_IDLE = "idle"
local SHOT_STATE_FIRING = "firing"
local SHOT_STATE_RECOVERING = "recovering"

function ShootingSystem.new()
    local self = {}
    self.state = SHOT_STATE_IDLE
    self.lastShotTime = 0
    self.shotRecoveryTime = 0.5  -- Time to recover from shot (seconds)
    self.activeShots = {}  -- Active tracers/effects
    self.hitMarkers = {}   -- Hit feedback markers
    self.bulletTracer = BulletTracer.new()  -- Bullet tracer system
    self.combatIntegration = CombatIntegration.new()  -- Combat integration for Phase 4

    return setmetatable(self, { __index = ShootingSystem })
end

-- Attempt to shoot at screen position in 3D space
-- Args:
--   screenX, screenY: screen coordinates to aim at
--   shootingUnit: unit performing the shot
--   targetSystem: for calculating hit probability
--   losSystem: for LOS checks
--   battlefieldSystem: for hit resolution
--   cameraAngle, cameraPitch: viewing angles
--   hexRaycaster: for raycasting to find target
--   effectsRenderer: for visual effects
--   billboard Renderer: for target detection
-- Returns:
--   result table with hit/miss info
function ShootingSystem:shoot(screenX, screenY, shootingUnit, targetSystem, losSystem, battlefieldSystem, cameraAngle, cameraPitch, hexRaycaster, effectsRenderer, billboardRenderer)
    -- Check if can shoot (not recovering from last shot)
    local currentTime = love.timer.getTime()
    if self.state == SHOT_STATE_RECOVERING and (currentTime - self.lastShotTime) < self.shotRecoveryTime then
        return {
            success = false,
            reason = "Weapon recovering"
        }
    end

    -- Calculate distance for range modifier
    local distance = self:calculateDistance(shootingUnit, targetUnit)
    if distance > (shootingUnit.weapon and shootingUnit.weapon.maxRange or 20) then
        return {
            success = false,
            reason = "Target out of range"
        }
    end

    -- Check weapon has ammunition
    if not shootingUnit or not shootingUnit.weapon or shootingUnit.weapon.ammo <= 0 then
        return {
            success = false,
            reason = "No ammunition"
        }
    end

    -- Use billboard renderer to find target at screen position
    local targetBillboard = billboardRenderer:getBillboardAtPosition(screenX, screenY, 12)
    if not targetBillboard or not targetBillboard.unit then
        return {
            success = false,
            reason = "No target"
        }
    end

    local targetUnit = targetBillboard.unit

    -- Calculate hit probability
    local hitChance = self:calculateHitChance(shootingUnit, targetUnit, targetSystem, losSystem)

    -- Distance modifier (closer = higher accuracy)
    local distanceModifier = math.max(0.3, 1.0 - (distance / 30))  -- 30 tile max range
    hitChance = hitChance * distanceModifier

    -- Determine hit/miss
    local isHit = math.random() < hitChance

    -- Calculate damage if hit
    local damage = 0
    if isHit then
        damage = self:calculateDamage(shootingUnit, targetUnit)
    end

    -- Create visual effects
    self:createMuzzleFlash(shootingUnit, effectsRenderer)

    -- Fire bullet tracer
    if self.bulletTracer then
        local weaponType = shootingUnit.weapon and shootingUnit.weapon.type or "rifle"
        self.bulletTracer:fireBullet(shootingUnit, targetUnit, weaponType, hexRaycaster, effectsRenderer)
    end

    self:createBulletTracer(shootingUnit, targetUnit, isHit, effectsRenderer)

    if isHit then
        self:createHitMarker(targetUnit, screenX, screenY, true)
        -- Create explosion effect at target location
        if effectsRenderer and targetUnit.position then
            effectsRenderer:addExplosion(targetUnit.position.q, targetUnit.position.r, 1.5)
        end
        -- Apply damage to target
        if battlefieldSystem then
            targetUnit.health = math.max(0, targetUnit.health - damage)
        end
    else
        self:createHitMarker(targetUnit, screenX, screenY, false)
    end

    -- Consume ammunition
    shootingUnit.weapon.ammo = shootingUnit.weapon.ammo - 1

    -- Update state
    self.state = SHOT_STATE_RECOVERING
    self.lastShotTime = currentTime

    print(string.format("[ShootingSystem] Shot: %s vs %s - %s (%.0f%% chance, %d dmg)",
        shootingUnit.id or "Unit",
        targetUnit.id or "Target",
        isHit and "HIT" or "MISS",
        hitChance * 100,
        damage))

    return {
        success = true,
        isHit = isHit,
        damage = damage,
        targetUnit = targetUnit,
        hitChance = hitChance
    }
end

-- Calculate distance between units
-- Args:
--   shootingUnit: unit shooting
--   targetUnit: target unit
-- Returns:
--   distance in hex tiles
function ShootingSystem:calculateDistance(shootingUnit, targetUnit)
    if not shootingUnit.position or not targetUnit.position then
        return 0
    end

    -- Hex distance calculation
    local dq = targetUnit.position.q - shootingUnit.position.q
    local dr = targetUnit.position.r - shootingUnit.position.r

    -- Axial hex distance formula
    local distance = (math.abs(dq) + math.abs(dr) + math.abs(dq + dr)) / 2
    return distance
end

-- Calculate hit probability
-- Args:
--   shootingUnit: unit doing shooting
--   targetUnit: unit being shot at
--   targetSystem: target calculations
--   losSystem: LOS checks
-- Returns:
--   hit chance (0-1)
function ShootingSystem:calculateHitChance(shootingUnit, targetUnit, targetSystem, losSystem)
    local baseHitChance = 0.75  -- 75% base

    -- Check LOS - no hit if not visible
    if losSystem and shootingUnit.team then
        local visibility = losSystem:getVisibility(shootingUnit.team, targetUnit.position.q, targetUnit.position.r)
        if visibility == "hidden" or not visibility then
            return 0.0
        elseif visibility == "partially" then
            baseHitChance = baseHitChance * 0.5  -- 50% chance if partially visible
        end
        -- "visible" = normal visibility
    end

    -- Modifiers based on unit stats
    if shootingUnit.accuracy then
        baseHitChance = baseHitChance * (1.0 + (shootingUnit.accuracy / 100))
    end

    -- Target size (larger = easier hit)
    if targetUnit.armor == "heavy" then
        baseHitChance = baseHitChance * 1.2  -- 20% bonus for large targets
    elseif targetUnit.armor == "light" then
        baseHitChance = baseHitChance * 0.8  -- 20% penalty for small targets
    end

    -- Status effects
    if targetUnit.isMarked then
        baseHitChance = baseHitChance * 1.2  -- Marked targets easier to hit
    end
    if targetUnit.isSuppressed then
        baseHitChance = baseHitChance * 0.7  -- Suppressed units harder to hit
    end

    -- Clamp to valid range
    return math.max(0.05, math.min(0.95, baseHitChance))
end

-- Calculate damage dealt
-- Args:
--   shootingUnit: unit shooting
--   targetUnit: unit being shot
-- Returns:
--   damage amount
function ShootingSystem:calculateDamage(shootingUnit, targetUnit)
    if not shootingUnit or not shootingUnit.weapon then
        return 0
    end

    local baseDamage = shootingUnit.weapon.damage or 10

    -- Critical hit chance (10%)
    local isCritical = math.random() < 0.1
    local damageMult = isCritical and 1.5 or 1.0

    -- Target armor reduces damage
    local armorReduction = 0.8  -- 80% damage after armor
    if targetUnit.armor == "heavy" then
        armorReduction = 0.6  -- Heavy armor more protective
    elseif targetUnit.armor == "light" then
        armorReduction = 1.0  -- Light armor no protection
    end

    local damage = math.floor(baseDamage * damageMult * armorReduction)
    return math.max(1, damage)  -- Minimum 1 damage
end

-- Create muzzle flash effect
-- Args:
--   shootingUnit: unit firing
--   effectsRenderer: for effects
function ShootingSystem:createMuzzleFlash(shootingUnit, effectsRenderer)
    if not effectsRenderer or not shootingUnit then
        return
    end

    -- Muzzle flash is at unit position, bright orange flash
    -- Store as temporary visual effect
    if not self.muzzleFlashes then
        self.muzzleFlashes = {}
    end

    local flash = {
        unit = shootingUnit,
        createdAt = love.timer.getTime(),
        duration = 0.1,  -- 100ms flash
        intensity = 1.0
    }

    table.insert(self.muzzleFlashes, flash)
end

-- Create bullet tracer effect
-- Args:
--   shootingUnit: unit firing
--   targetUnit: target (for tracer destination)
--   isHit: whether it was a hit
--   effectsRenderer: for effects
function ShootingSystem:createBulletTracer(shootingUnit, targetUnit, isHit, effectsRenderer)
    if not effectsRenderer or not shootingUnit or not targetUnit then
        return
    end

    -- Store tracer effect
    if not self.tracers then
        self.tracers = {}
    end

    local tracer = {
        fromUnit = shootingUnit,
        toUnit = targetUnit,
        isHit = isHit,
        createdAt = love.timer.getTime(),
        duration = 0.3,  -- 300ms tracer
        color = isHit and {0, 1, 0} or {1, 0, 0}  -- Green hit, red miss
    }

    table.insert(self.tracers, tracer)
end

-- Create hit marker (visual feedback)
-- Args:
--   targetUnit: unit that was shot
--   screenX, screenY: screen position
--   isHit: hit or miss
function ShootingSystem:createHitMarker(targetUnit, screenX, screenY, isHit)
    if not self.hitMarkers then
        self.hitMarkers = {}
    end

    local marker = {
        screenX = screenX,
        screenY = screenY,
        isHit = isHit,
        createdAt = love.timer.getTime(),
        duration = 0.5,  -- 500ms marker display
        text = isHit and "HIT!" or "MISS",
        color = isHit and {0, 1, 0} or {1, 0, 0}  -- Green/Red
    }

    table.insert(self.hitMarkers, marker)
end

-- Update shooting system (animations, cleanup)
function ShootingSystem:update(dt)
    local currentTime = love.timer.getTime()

    -- Update recovery state
    if self.state == SHOT_STATE_RECOVERING and (currentTime - self.lastShotTime) >= self.shotRecoveryTime then
        self.state = SHOT_STATE_IDLE
    end

    -- Update bullet tracers
    if self.bulletTracer then
        self.bulletTracer:update(dt)
    end

    -- Clean up expired effects
    if self.muzzleFlashes then
        local toRemove = {}
        for i, flash in ipairs(self.muzzleFlashes) do
            if (currentTime - flash.createdAt) > flash.duration then
                table.insert(toRemove, i)
            end
        end
        for i = #toRemove, 1, -1 do
            table.remove(self.muzzleFlashes, toRemove[i])
        end
    end

    if self.tracers then
        local toRemove = {}
        for i, tracer in ipairs(self.tracers) do
            if (currentTime - tracer.createdAt) > tracer.duration then
                table.insert(toRemove, i)
            end
        end
        for i = #toRemove, 1, -1 do
            table.remove(self.tracers, toRemove[i])
        end
    end

    if self.hitMarkers then
        local toRemove = {}
        for i, marker in ipairs(self.hitMarkers) do
            if (currentTime - marker.createdAt) > marker.duration then
                table.insert(toRemove, i)
            end
        end
        for i = #toRemove, 1, -1 do
            table.remove(self.hitMarkers, toRemove[i])
        end
    end
end

-- Draw shooting effects
function ShootingSystem:drawEffects()
    love.graphics.push()

    -- Draw muzzle flashes
    if self.muzzleFlashes then
        for _, flash in ipairs(self.muzzleFlashes) do
            self:drawMuzzleFlash(flash)
        end
    end

    -- Draw bullet tracers
    if self.bulletTracer then
        self.bulletTracer:draw(nil, love.graphics.getWidth(), love.graphics.getHeight(),
            0, 0, 0, 0)  -- Would need camera params for full implementation
    end

    -- Draw old tracers
    if self.tracers then
        for _, tracer in ipairs(self.tracers) do
            self:drawTracer(tracer)
        end
    end

    -- Draw hit markers
    if self.hitMarkers then
        for _, marker in ipairs(self.hitMarkers) do
            self:drawHitMarker(marker)
        end
    end

    love.graphics.pop()
end

-- Draw muzzle flash
function ShootingSystem:drawMuzzleFlash(flash)
    local elapsed = love.timer.getTime() - flash.createdAt
    local progress = elapsed / flash.duration
    local opacity = 1.0 - progress

    -- Flash gets dimmer
    love.graphics.setColor(1, 0.8, 0.2, opacity * 0.7)
    love.graphics.circle("fill", 100, 100, 20 + (progress * 10))
end

-- Draw bullet tracer
function ShootingSystem:drawTracer(tracer)
    local elapsed = love.timer.getTime() - tracer.createdAt
    local progress = elapsed / tracer.duration

    -- Tracer line from unit to target (simplified - would need full positions)
    love.graphics.setColor(tracer.color[1], tracer.color[2], tracer.color[3], 1.0 - progress)
    love.graphics.setLineWidth(2)
    -- Line would be drawn from muzzle to target impact point
end

-- Draw hit marker
function ShootingSystem:drawHitMarker(marker)
    local elapsed = love.timer.getTime() - marker.createdAt
    local progress = elapsed / marker.duration
    local opacity = 1.0 - progress
    local scale = 1.0 + (progress * 0.5)

    love.graphics.setColor(marker.color[1], marker.color[2], marker.color[3], opacity)
    love.graphics.printf(marker.text,
        marker.screenX - 30 * scale,
        marker.screenY - 20 * scale,
        60 * scale,
        "center")
end

-- Get shooting state
function ShootingSystem:getState()
    return self.state
end

-- Can shoot check
function ShootingSystem:canShoot()
    return self.state == SHOT_STATE_IDLE
end

-- Apply full combat integration (Phase 4)
-- Args:
--   shootingResult: from shoot()
--   shooterUnit: unit that shot
--   targetUnit: unit that was shot
--   systems: {damageSystem, moraleSystem, statusEffectSystem, reactionSystem}
-- Returns:
--   comprehensive combat result with status effects, morale changes, etc
function ShootingSystem:applyCombatIntegration(shootingResult, shooterUnit, targetUnit, systems)
    if not self.combatIntegration or not shootingResult.success then
        return {
            success = false,
            reason = "Cannot apply combat integration"
        }
    end

    -- Apply full combat round result
    return self.combatIntegration:applyCombatRound(
        shootingResult,
        shooterUnit,
        targetUnit,
        systems or {}
    )
end

return ShootingSystem
