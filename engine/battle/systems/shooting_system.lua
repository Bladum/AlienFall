-- shooting_system.lua
-- Shooting system for battlescape combat
-- Handles shooting mechanics, accuracy calculations, and hit determination

local RangeSystem = require("battle.systems.range_system")
local AccuracySystem = require("battle.systems.accuracy_system")
local WeaponSystem = require("systems.weapon_system")

local ShootingSystem = {}

-- Attempt to shoot from shooter unit to target unit
-- @param shooter table: Shooter unit
-- @param target table: Target unit
-- @param weaponId string: Weapon to use (optional, uses unit's primary weapon if not specified)
-- @return table: Shoot result with success, hit, damage, accuracy info
function ShootingSystem.shoot(shooter, target, weaponId)
    if not shooter or not target then
        return {
            success = false,
            error = "Invalid shooter or target",
            hit = false,
            damage = 0,
            accuracy = 0
        }
    end

    -- Determine weapon to use
    weaponId = weaponId or shooter.weapon1
    if not weaponId then
        return {
            success = false,
            error = "No weapon equipped",
            hit = false,
            damage = 0,
            accuracy = 0
        }
    end

    -- Check if weapon is ranged
    if not WeaponSystem.isRanged(weaponId) then
        return {
            success = false,
            error = "Weapon is not ranged",
            hit = false,
            damage = 0,
            accuracy = 0
        }
    end

    -- Calculate distance
    local distance = RangeSystem.calculateDistance(
        {x = shooter.x, y = shooter.y},
        {x = target.x, y = target.y}
    )

    -- Get weapon properties
    local maxRange = WeaponSystem.getMaxRange(weaponId)
    local baseAccuracy = WeaponSystem.getBaseAccuracy(weaponId)
    local damage = WeaponSystem.getDamage(weaponId)

    -- Check if in range
    if not RangeSystem.isInRange(distance, maxRange) then
        return {
            success = false,
            error = "Target out of range",
            hit = false,
            damage = 0,
            accuracy = 0,
            distance = distance,
            maxRange = maxRange
        }
    end

    -- Calculate effective accuracy
    local effectiveAccuracy = AccuracySystem.calculateEffectiveAccuracy(distance, maxRange, baseAccuracy)
    if not effectiveAccuracy then
        return {
            success = false,
            error = "Cannot calculate accuracy",
            hit = false,
            damage = 0,
            accuracy = 0
        }
    end

    -- Determine hit (simple random roll for now)
    local roll = math.random(1, 100)
    local hit = roll <= effectiveAccuracy

    local resultDamage = 0
    if hit then
        resultDamage = damage  -- Could add damage variance later
    end

    return {
        success = true,
        hit = hit,
        damage = resultDamage,
        accuracy = effectiveAccuracy,
        roll = roll,
        distance = distance,
        maxRange = maxRange,
        weaponId = weaponId,
        rangeZone = RangeSystem.getRangeZone(distance, maxRange),
        accuracyZone = AccuracySystem.getAccuracyZoneDescription(distance, maxRange)
    }
end

-- Get shooting information without actually shooting
-- Useful for UI display and targeting
-- @param shooter table: Shooter unit
-- @param target table: Target unit
-- @param weaponId string: Weapon to use (optional)
-- @return table: Shooting info with accuracy, range, etc.
function ShootingSystem.getShootingInfo(shooter, target, weaponId)
    if not shooter or not target then
        return {
            canShoot = false,
            error = "Invalid shooter or target",
            accuracy = 0,
            distance = 0,
            maxRange = 0
        }
    end

    -- Determine weapon to use
    weaponId = weaponId or shooter.weapon1
    if not weaponId then
        return {
            canShoot = false,
            error = "No weapon equipped",
            accuracy = 0,
            distance = 0,
            maxRange = 0
        }
    end

    -- Check if weapon is ranged
    if not WeaponSystem.isRanged(weaponId) then
        return {
            canShoot = false,
            error = "Weapon is not ranged",
            accuracy = 0,
            distance = 0,
            maxRange = 0
        }
    end

    -- Calculate distance
    local distance = RangeSystem.calculateDistance(
        {x = shooter.x, y = shooter.y},
        {x = target.x, y = target.y}
    )

    -- Get weapon properties
    local maxRange = WeaponSystem.getMaxRange(weaponId)
    local baseAccuracy = WeaponSystem.getBaseAccuracy(weaponId)

    -- Check if in range
    local canShoot = RangeSystem.isInRange(distance, maxRange)

    -- Calculate effective accuracy
    local effectiveAccuracy = nil
    if canShoot then
        effectiveAccuracy = AccuracySystem.calculateEffectiveAccuracy(distance, maxRange, baseAccuracy)
    end

    return {
        canShoot = canShoot,
        accuracy = effectiveAccuracy or 0,
        distance = distance,
        maxRange = maxRange,
        weaponId = weaponId,
        rangeZone = RangeSystem.getRangeZone(distance, maxRange),
        accuracyZone = AccuracySystem.getAccuracyZoneDescription(distance, maxRange),
        accuracyColor = AccuracySystem.getAccuracyZoneColor(distance, maxRange)
    }
end

return ShootingSystem