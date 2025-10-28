-- Phase 4.1: Advanced Wound System for 3D Combat
-- Critical hit zones, wound severity, bleeding mechanics, medical recovery

local WoundSystem = {}

-- Wound severity levels
local WOUND_SEVERITY_LIGHT = 1
local WOUND_SEVERITY_MODERATE = 2
local WOUND_SEVERITY_CRITICAL = 3

-- Hit zones on unit
local HIT_ZONES = {
    HEAD = "head",
    TORSO = "torso",
    ARM_LEFT = "arm_left",
    ARM_RIGHT = "arm_right",
    LEG_LEFT = "leg_left",
    LEG_RIGHT = "leg_right"
}

-- Zone properties
local ZONE_PROPERTIES = {
    head = { critical = 0.30, armor = 0.8, bleed = 3 },
    torso = { critical = 0.15, armor = 1.0, bleed = 2 },
    arm_left = { critical = 0.05, armor = 0.9, bleed = 1 },
    arm_right = { critical = 0.05, armor = 0.9, bleed = 1 },
    leg_left = { critical = 0.10, armor = 0.9, bleed = 2 },
    leg_right = { critical = 0.10, armor = 0.9, bleed = 2 }
}

function WoundSystem.new()
    local self = {}
    self.woundLog = {}  -- Track all wounds for statistics

    return setmetatable(self, { __index = WoundSystem })
end

-- Determine hit zone from projectile direction
-- Args:
--   shooterUnit: unit that shot
--   targetUnit: unit that was hit
--   distance: hex distance between units
-- Returns:
--   hit zone name
function WoundSystem:determineHitZone(shooterUnit, targetUnit, distance)
    -- Random zone selection (can be improved with facing direction)
    local zones = {}
    for zone, _ in pairs(ZONE_PROPERTIES) do
        table.insert(zones, zone)
    end

    -- Slightly favor torso (center mass)
    local roll = math.random(1, 100)
    if roll < 40 then
        return HIT_ZONES.TORSO
    elseif roll < 55 then
        return HIT_ZONES.HEAD
    elseif roll < 70 then
        if math.random() < 0.5 then
            return HIT_ZONES.LEG_LEFT
        else
            return HIT_ZONES.LEG_RIGHT
        end
    else
        if math.random() < 0.5 then
            return HIT_ZONES.ARM_LEFT
        else
            return HIT_ZONES.ARM_RIGHT
        end
    end
end

-- Calculate critical hit probability for zone
-- Args:
--   zone: hit zone name
--   weapon: weapon data
--   distance: hex distance
-- Returns:
--   critical hit chance (0-1)
function WoundSystem:getCriticalChance(zone, weapon, distance)
    local baseChance = ZONE_PROPERTIES[zone].critical

    -- Weapon modifiers
    local weaponBonus = 0
    if weapon and weapon.type == "sniper" then
        weaponBonus = 0.10  -- +10% crit for sniper rifles
    end

    -- Distance modifier (closer = higher crit chance)
    local distanceModifier = math.max(0.5, 1.0 - (distance / 40))

    return math.min(0.95, baseChance + weaponBonus) * distanceModifier
end

-- Apply wound to unit
-- Args:
--   unit: target unit
--   zone: hit zone
--   damage: damage taken
--   weapon: weapon that caused wound
--   distance: hex distance
-- Returns:
--   wound info table
function WoundSystem:applyWound(unit, zone, damage, weapon, distance)
    if not unit then return nil end

    -- Initialize wounds table if needed
    if not unit.wounds then
        unit.wounds = {}
    end

    -- Determine severity
    local severity = WOUND_SEVERITY_LIGHT
    if damage >= 15 then
        severity = WOUND_SEVERITY_CRITICAL
    elseif damage >= 8 then
        severity = WOUND_SEVERITY_MODERATE
    end

    -- Check for critical hit
    local isCritical = math.random() < self:getCriticalChance(zone, weapon, distance)
    if isCritical then
        severity = math.min(WOUND_SEVERITY_CRITICAL, severity + 1)
    end

    -- Create wound entry
    local wound = {
        zone = zone,
        severity = severity,
        damage = damage,
        isCritical = isCritical,
        createdAt = love.timer.getTime(),
        bleedAmount = ZONE_PROPERTIES[zone].bleed * severity,
        healed = false
    }

    table.insert(unit.wounds, wound)

    -- Apply immediate effects
    self:applyWoundEffects(unit, wound)

    return wound
end

-- Apply immediate effects from wound
-- Args:
--   unit: wounded unit
--   wound: wound data
function WoundSystem:applyWoundEffects(unit, wound)
    if not unit or not wound then return end

    local zone = wound.zone
    local severity = wound.severity

    -- Apply stat penalties based on zone and severity
    if zone == HIT_ZONES.HEAD and severity >= WOUND_SEVERITY_MODERATE then
        -- Head wound: reduced accuracy
        unit.accuracyPenalty = (unit.accuracyPenalty or 0) + (severity * 10)
        unit.willPower = math.max(0, (unit.willPower or 100) - 20)
    elseif zone == HIT_ZONES.TORSO and severity >= WOUND_SEVERITY_CRITICAL then
        -- Critical torso: bleeding + immobilized
        unit.bleedingAmount = (unit.bleedingAmount or 0) + 2
        unit.immobilized = true
    elseif (zone == HIT_ZONES.LEG_LEFT or zone == HIT_ZONES.LEG_RIGHT) then
        -- Leg wound: reduced movement
        unit.movementPenalty = (unit.movementPenalty or 0) + (severity * 0.2)
    elseif (zone == HIT_ZONES.ARM_LEFT or zone == HIT_ZONES.ARM_RIGHT) then
        -- Arm wound: reduced weapon effectiveness
        unit.weaponPenalty = (unit.weaponPenalty or 0) + (severity * 15)
    end
end

-- Update bleeding damage per turn
-- Args:
--   unit: wounded unit
--   dt: delta time (optional for animation)
-- Returns:
--   total bleed damage
function WoundSystem:updateBleeding(unit, dt)
    if not unit or not unit.wounds or #unit.wounds == 0 then
        return 0
    end

    local totalBleed = 0

    for _, wound in ipairs(unit.wounds) do
        if not wound.healed and wound.bleedAmount > 0 then
            -- Bleeding damage each turn
            totalBleed = totalBleed + wound.bleedAmount

            -- Gradually reduce bleed amount (without medical aid)
            wound.bleedAmount = math.max(0, wound.bleedAmount - 0.1)
        end
    end

    -- Apply bleed damage to unit
    if totalBleed > 0 then
        unit.health = math.max(0, unit.health - totalBleed)
    end

    return totalBleed
end

-- Get wound summary for unit
-- Args:
--   unit: unit to check
-- Returns:
--   summary table with stats
function WoundSystem:getWoundSummary(unit)
    if not unit or not unit.wounds or #unit.wounds == 0 then
        return {
            totalWounds = 0,
            criticalWounds = 0,
            totalBleed = 0,
            immobilized = false
        }
    end

    local summary = {
        totalWounds = #unit.wounds,
        criticalWounds = 0,
        moderateWounds = 0,
        lightWounds = 0,
        totalBleed = 0,
        immobilized = unit.immobilized or false,
        byZone = {}
    }

    for _, wound in ipairs(unit.wounds) do
        if wound.severity == WOUND_SEVERITY_CRITICAL then
            summary.criticalWounds = summary.criticalWounds + 1
        elseif wound.severity == WOUND_SEVERITY_MODERATE then
            summary.moderateWounds = summary.moderateWounds + 1
        else
            summary.lightWounds = summary.lightWounds + 1
        end

        summary.totalBleed = summary.totalBleed + wound.bleedAmount

        -- Track by zone
        if not summary.byZone[wound.zone] then
            summary.byZone[wound.zone] = 0
        end
        summary.byZone[wound.zone] = summary.byZone[wound.zone] + 1
    end

    return summary
end

-- Heal wounds with medical item/ability
-- Args:
--   unit: wounded unit
--   healAmount: amount to heal
--   targetZone: specific zone to heal (optional)
-- Returns:
--   healing result
function WoundSystem:healWounds(unit, healAmount, targetZone)
    if not unit or not unit.wounds or #unit.wounds == 0 then
        return { success = false, reason = "No wounds to heal" }
    end

    local healed = 0
    local woundsHealed = 0

    for _, wound in ipairs(unit.wounds) do
        if not wound.healed and (not targetZone or wound.zone == targetZone) then
            if healed < healAmount then
                wound.healed = true
                wound.bleedAmount = 0
                healed = healed + 1
                woundsHealed = woundsHealed + 1
            end
        end
    end

    -- Remove immobilization if critical wound healed
    if unit.immobilized and woundsHealed > 0 then
        local criticalRemaining = 0
        for _, wound in ipairs(unit.wounds) do
            if not wound.healed and wound.severity == WOUND_SEVERITY_CRITICAL then
                criticalRemaining = criticalRemaining + 1
            end
        end
        if criticalRemaining == 0 then
            unit.immobilized = false
        end
    end

    return {
        success = woundsHealed > 0,
        woundsHealed = woundsHealed,
        totalHealed = healed
    }
end

-- Check if unit is incapacitated
function WoundSystem:isIncapacitated(unit)
    if not unit then return false end

    -- Dead
    if not unit.alive then return true end

    -- Immobilized by critical wounds
    if unit.immobilized then return true end

    -- Multiple critical wounds (3+)
    local summary = self:getWoundSummary(unit)
    if summary.criticalWounds >= 3 then return true end

    -- Critically low health
    if unit.health and unit.maxHealth and unit.health < (unit.maxHealth * 0.1) then
        return true
    end

    return false
end

-- Get unit status description
function WoundSystem:getUnitStatus(unit)
    if not unit then return "Unknown" end

    if not unit.alive then
        return "Dead"
    end

    local summary = self:getWoundSummary(unit)

    if summary.totalWounds == 0 then
        return "Healthy"
    elseif summary.criticalWounds > 0 then
        return "Critically Wounded"
    elseif summary.moderateWounds > 0 then
        return "Heavily Wounded"
    else
        return "Lightly Wounded"
    end
end

return WoundSystem

