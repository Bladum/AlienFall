-- Phase 4: Combat System Integration for 3D Shooting
-- Bridges ShootingSystem3D with existing ECS combat systems
-- Handles wound application, suppression, status effects, and AI reactions

local CombatIntegration = {}
local WoundSystem = require("battlescape.combat.wound_system_3d")
local SuppressionSystem = require("battlescape.combat.suppression_system_3d")

-- Damage type constants
local DAMAGE_TYPE_KINETIC = "kinetic"
local DAMAGE_TYPE_ENERGY = "energy"

function CombatIntegration.new()
    local self = {}
    self.lastShotLog = {}  -- Track recent shots for AI
    self.woundSystem = WoundSystem.new()  -- Wound tracking
    self.suppressionSystem = SuppressionSystem.new()  -- Suppression tracking

    return setmetatable(self, { __index = CombatIntegration })
end

-- Integrate 3D shooting result with ECS combat system
-- Args:
--   shootingResult: from ShootingSystem3D:shoot()
--   shooterUnit: unit that shot
--   targetUnit: unit that was shot
--   damageSystem: ECS DamageSystem instance
--   moraleSystem: ECS MoraleSystem instance
--   statusEffectSystem: for suppression/other effects
-- Returns:
--   comprehensive combat result
function CombatIntegration:integrate3DShot(shootingResult, shooterUnit, targetUnit,
                                           damageSystem, moraleSystem, statusEffectSystem)
    if not shootingResult.success or not shootingResult.isHit then
        return {
            success = shootingResult.success,
            isHit = false,
            hitChance = shootingResult.hitChance or 0,
            reason = shootingResult.reason,
            log = "Shot missed target"
        }
    end

    -- Create pseudo-projectile for damage resolution
    local projectile = {
        power = shootingResult.damage,
        damageClass = DAMAGE_TYPE_KINETIC,
        type = shooterUnit.weapon and shooterUnit.weapon.type or "rifle"
    }

    -- Resolve damage with existing system
    local damageResult = nil
    if damageSystem then
        damageResult = damageSystem:resolveDamage(projectile, targetUnit, shooterUnit)
    else
        -- Fallback if no damage system
        damageResult = self:resolveDamageBasic(projectile, targetUnit)
    end

    -- Apply wounds using Phase 4.1 system
    local distance = self:calculateDistance(shooterUnit, targetUnit)
    local hitZone = self.woundSystem:determineHitZone(shooterUnit, targetUnit, distance)
    local wound = self.woundSystem:applyWound(
        targetUnit,
        hitZone,
        shootingResult.damage,
        shooterUnit.weapon,
        distance
    )

    -- Apply status effects based on weapon type
    local statusEffects = self:getWeaponStatusEffects(shooterUnit.weapon)

    if statusEffectSystem and #statusEffects > 0 then
        for _, effect in ipairs(statusEffects) do
            statusEffectSystem:applyEffect(targetUnit, effect)
        end
    else
        -- Manual status effect application
        self:applyStatusEffects(targetUnit, statusEffects)
    end

    -- Apply suppression if heavy weapon
    local suppression = self:calculateSuppression(shooterUnit.weapon, shootingResult.damage)
    if suppression > 0 then
        if statusEffectSystem then
            statusEffectSystem:applySuppression(targetUnit, suppression)
        else
            self.suppressionSystem:applySuppression(targetUnit, suppression)
        end
    end

    -- Apply morale effects (witness damage)
    if moraleSystem then
        moraleSystem:applyWitnessDamage(targetUnit, shootingResult.damage)
    else
        self.suppressionSystem:applyMoraleChange(
            targetUnit,
            -math.ceil(shootingResult.damage / 2),
            "Taking damage"
        )
    end

    -- Log the shot for AI
    self:logShot(shooterUnit, targetUnit, shootingResult, damageResult)

    return {
        success = true,
        isHit = true,
        hitChance = shootingResult.hitChance,
        damage = shootingResult.damage,
        damageResult = damageResult,
        statusEffects = statusEffects,
        suppression = suppression,
        targetHealth = targetUnit.health,
        log = string.format("Shot successful: %d damage to %s",
                           shootingResult.damage, targetUnit.id or "Unit")
    }
end

-- Basic damage resolution (fallback if no ECS system)
function CombatIntegration:resolveDamageBasic(projectile, targetUnit)
    -- Simple armor calculation
    local armor = targetUnit.armor or "normal"
    local armorValue = 0
    if armor == "light" then armorValue = 2
    elseif armor == "normal" then armorValue = 5
    elseif armor == "heavy" then armorValue = 8
    end

    -- Apply armor reduction
    local reducedDamage = math.max(1, projectile.power - armorValue)

    -- Apply damage to health
    targetUnit.health = math.max(0, targetUnit.health - reducedDamage)

    return {
        baseDamage = projectile.power,
        armorValue = armorValue,
        finalDamage = reducedDamage,
        targetHealth = targetUnit.health,
        unitAlive = targetUnit.health > 0
    }
end

-- Get status effects from weapon type
-- Args:
--   weapon: weapon data
-- Returns:
--   table of effect types to apply
function CombatIntegration:getWeaponStatusEffects(weapon)
    if not weapon then return {} end

    local effects = {}

    local weaponType = weapon.type or "rifle"
    if weaponType == "SMG" then
        table.insert(effects, "bleeding")
    elseif weaponType == "shotgun" then
        table.insert(effects, "stun")
    elseif weaponType == "sniper" then
        table.insert(effects, "critical_wound")
    end

    return effects
end

-- Apply status effects to target (fallback)
function CombatIntegration:applyStatusEffects(targetUnit, effects)
    if not targetUnit or not effects then return end

    for _, effect in ipairs(effects) do
        if effect == "bleeding" then
            targetUnit.isBleeding = true
            targetUnit.bleedingAmount = (targetUnit.bleedingAmount or 0) + 1
        elseif effect == "stun" then
            targetUnit.isStunned = true
            targetUnit.stunDuration = math.max(targetUnit.stunDuration or 0, 2)
        elseif effect == "critical_wound" then
            targetUnit.isCriticallyWounded = true
        end
    end
end

-- Calculate suppression from weapon
-- Args:
--   weapon: weapon data
--   damage: damage dealt
-- Returns:
--   suppression amount (0-100)
function CombatIntegration:calculateSuppression(weapon, damage)
    if not weapon then return 0 end

    local baseSuppression = {
        rifle = 15,
        smg = 20,
        lmg = 40,
        shotgun = 25,
        sniper = 10,
        default = 10
    }

    local suppression = baseSuppression[weapon.type] or baseSuppression.default
    -- Damage scales suppression
    suppression = suppression + (damage / 2)

    return math.min(100, suppression)  -- Cap at 100
end

-- Apply morale effects from witnessing damage (fallback)
function CombatIntegration:applyMoraleEffects(targetUnit, damage)
    if not targetUnit then return end

    -- Morale penalty when taking damage
    local moralePenalty = math.ceil(damage / 2)
    targetUnit.morale = math.max(0, (targetUnit.morale or 100) - moralePenalty)

    -- Check for panic (morale < 30)
    if targetUnit.morale < 30 then
        targetUnit.isPanicked = true
    end
end

-- Log shot for AI behavior
function CombatIntegration:logShot(shooterUnit, targetUnit, shootingResult, damageResult)
    local log = {
        shooter = shooterUnit.id or "Unit",
        target = targetUnit.id or "Unit",
        timestamp = love.timer.getTime(),
        hitChance = shootingResult.hitChance,
        damage = shootingResult.damage,
        wasHit = shootingResult.isHit
    }

    table.insert(self.lastShotLog, log)

    -- Keep only last 20 shots
    if #self.lastShotLog > 20 then
        table.remove(self.lastShotLog, 1)
    end
end

-- Calculate distance between units
function CombatIntegration:calculateDistance(shooterUnit, targetUnit)
    if not shooterUnit.position or not targetUnit.position then
        return 0
    end

    local dq = targetUnit.position.q - shooterUnit.position.q
    local dr = targetUnit.position.r - shooterUnit.position.r

    return (math.abs(dq) + math.abs(dr) + math.abs(dq + dr)) / 2
end

-- Get recent aggression level for unit
-- Args:
--   targetUnit: unit to check
--   timePeriod: how many seconds to look back (default 5)
-- Returns:
--   number indicating recent damage received
function CombatIntegration:getRecentAggressionLevel(targetUnit, timePeriod)
    timePeriod = timePeriod or 5
    local currentTime = love.timer.getTime()
    local totalDamage = 0
    local shotCount = 0

    for _, log in ipairs(self.lastShotLog) do
        if log.target == (targetUnit.id or "Unit") and
           (currentTime - log.timestamp) <= timePeriod then
            totalDamage = totalDamage + log.damage
            shotCount = shotCount + 1
        end
    end

    return {
        totalDamage = totalDamage,
        shotCount = shotCount,
        avgDamagePerShot = shotCount > 0 and (totalDamage / shotCount) or 0,
        level = shotCount > 2 and "high" or (shotCount > 0 and "medium" or "low")
    }
end

-- Check if unit should trigger suppression AI response
function CombatIntegration:shouldTriggerSuppressionResponse(targetUnit)
    if not targetUnit then return false end

    -- Check suppression level
    if targetUnit.suppressionLevel and targetUnit.suppressionLevel > 50 then
        return true
    end

    -- Check if recently hit
    local aggression = self:getRecentAggressionLevel(targetUnit, 3)
    if aggression.shotCount >= 2 then
        return true
    end

    return false
end

-- Check if unit should trigger panic AI response
function CombatIntegration:shouldTriggerPanicResponse(targetUnit)
    if not targetUnit then return false end

    -- Check morale
    if targetUnit.morale and targetUnit.morale < 25 then
        return true
    end

    -- Check if heavily wounded
    if targetUnit.health and targetUnit.maxHealth then
        local healthPercent = (targetUnit.health / targetUnit.maxHealth) * 100
        if healthPercent < 30 and targetUnit.suppressionLevel and targetUnit.suppressionLevel > 30 then
            return true
        end
    end

    return false
end

-- Apply retaliation behavior for unit
-- Args:
--   targetUnit: unit being retaliated by
--   shooterUnit: unit that shot
--   returnsSystem: reaction fire system
-- Returns:
--   retaliation result
function CombatIntegration:triggerRetaliation(targetUnit, shooterUnit, reactionSystem)
    if not targetUnit or not shooterUnit or not reactionSystem then
        return { success = false, reason = "Missing parameters" }
    end

    -- Check if unit can retaliate
    if not targetUnit.alive or targetUnit.isStunned or targetUnit.isSuppressed then
        return { success = false, reason = "Unit cannot retaliate" }
    end

    -- Use reaction fire system if available
    if reactionSystem.executeReaction then
        return reactionSystem:executeReaction(targetUnit, shooterUnit)
    end

    return { success = false, reason = "No reaction system" }
end

-- Integration point: apply full combat round result
function CombatIntegration:applyCombatRound(shootingResult, shooterUnit, targetUnit,
                                            systems)
    -- systems = {damageSystem, moraleSystem, statusEffectSystem, reactionSystem}

    -- 1. Integrate shooting with combat
    local combatResult = self:integrate3DShot(
        shootingResult,
        shooterUnit,
        targetUnit,
        systems.damageSystem,
        systems.moraleSystem,
        systems.statusEffectSystem
    )

    -- 2. Check for AI responses
    if self:shouldTriggerSuppressionResponse(targetUnit) then
        combatResult.aiResponse = "suppression"
    elseif self:shouldTriggerPanicResponse(targetUnit) then
        combatResult.aiResponse = "panic"
    end

    -- 3. Trigger retaliation if able
    if systems.reactionSystem and targetUnit.alive then
        local retaliationResult = self:triggerRetaliation(
            targetUnit,
            shooterUnit,
            systems.reactionSystem
        )
        combatResult.retaliation = retaliationResult
    end

    return combatResult
end

return CombatIntegration
