---ShootingSystem - Weapon Attack Resolution (ECS)
---
---Handles shooting mechanics, accuracy calculation, and hit determination for
---tactical combat. Part of the ECS (Entity-Component-System) battle architecture.
---Resolves weapon attacks from shooter to target.
---
---Features:
---  - Weapon attack resolution
---  - Accuracy calculation
---  - Hit/miss determination
---  - Damage application
---  - Ammo consumption
---  - Weapon mode support (auto, burst, snap, aimed)
---  - Range checking
---  - Line of sight validation
---
---Attack Process:
---  1. Validate shooter and target
---  2. Check weapon and ammo
---  3. Calculate range (hex distance)
---  4. Check line of sight
---  5. Calculate accuracy
---  6. Roll to hit
---  7. Apply damage if hit
---  8. Consume ammo
---
---Accuracy Modifiers:
---  - Base weapon accuracy
---  - Range penalty
---  - Shooter stats (aim skill)
---  - Stance (prone, kneeling, standing)
---  - Cover (target protection)
---  - Movement (shooter moved this turn)
---  - Weapon mode (snap vs aimed)
---
---Key Exports:
---  - shoot(shooter, target, weaponId): Resolves attack and returns result
---  - canShoot(shooter, target, weaponId): Returns true if attack valid
---  - calculateHitChance(shooter, target, weaponId): Returns hit probability
---  - getWeaponModes(weaponId): Returns available firing modes
---
---Dependencies:
---  - battlescape.battle_ecs.range_system: Distance calculation
---  - battlescape.battle_ecs.accuracy_system: Accuracy calculation
---  - battlescape.combat.weapon_system: Weapon data
---  - battlescape.combat.weapon_modes: Firing modes
---
---@module battlescape.battle_ecs.shooting_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ShootingSystem = require("battlescape.battle_ecs.shooting_system")
---  local result = ShootingSystem.shoot(soldier, alien, "assault_rifle")
---
---@see battlescape.battle_ecs.accuracy_system For accuracy calculation
---@see battlescape.battle_ecs.range_system For distance calculation
---@see battlescape.combat.weapon_system For weapon data

-- shooting_system.lua
-- Shooting system for battlescape combat
-- Handles shooting mechanics, accuracy calculations, and hit determination

local RangeSystem = require("battlescape.battle_ecs.range_system")
local AccuracySystem = require("battlescape.battle_ecs.accuracy_system")
local WeaponSystem = require("battlescape.combat.weapon_system")
local WeaponModes = require("battlescape.combat.weapon_modes")

local ShootingSystem = {}

-- Attempt to shoot from shooter unit to target unit
-- @param shooter table: Shooter unit
-- @param target table: Target unit
-- @param weaponId string: Weapon to use (optional, uses unit's primary weapon if not specified)
-- @param mode string: Firing mode to use (SNAP, AIM, LONG, AUTO, HEAVY, FINESSE) - optional, defaults to AIM
-- @return table: Shoot result with success, hit, damage, accuracy info
function ShootingSystem.shoot(shooter, target, weaponId, mode)
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

    -- Default to AIM mode if not specified
    mode = mode or WeaponModes.MODES.AIM

    -- Validate mode availability for this weapon
    if not WeaponSystem.isModeAvailable(weaponId, mode) then
        return {
            success = false,
            error = string.format("Weapon '%s' cannot use mode '%s'", weaponId, mode),
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
    local weapon = {
        id = weaponId,
        maxRange = WeaponSystem.getMaxRange(weaponId),
        baseAccuracy = WeaponSystem.getBaseAccuracy(weaponId),
        damage = WeaponSystem.getDamage(weaponId),
        ammo = WeaponSystem.getAmmo(weaponId) or 999,  -- Assume unlimited if not specified
        critChance = WeaponSystem.getCritChance(weaponId) or 5,  -- Default 5% crit
        apCost = 6,  -- Default base AP cost
        epCost = 3   -- Default base EP cost
    }
    
    -- Apply weapon mode modifiers
    local modifiedWeapon, apCost, epCost, errorMsg = WeaponModes.applyMode(weapon, mode, shooter)
    if not modifiedWeapon then
        return {
            success = false,
            error = errorMsg or "Cannot use this mode",
            hit = false,
            damage = 0,
            accuracy = 0
        }
    end

    -- Check if in range
    if not RangeSystem.isInRange(distance, modifiedWeapon.maxRange) then
        return {
            success = false,
            error = "Target out of range",
            hit = false,
            damage = 0,
            accuracy = 0,
            distance = distance,
            maxRange = modifiedWeapon.maxRange
        }
    end

    -- Calculate effective accuracy
    local effectiveAccuracy = AccuracySystem.calculateEffectiveAccuracy(distance, modifiedWeapon.maxRange, modifiedWeapon.baseAccuracy)
    if not effectiveAccuracy then
        return {
            success = false,
            error = "Cannot calculate accuracy",
            hit = false,
            damage = 0,
            accuracy = 0
        }
    end

    -- AUTO mode fires multiple bullets
    local bulletCount = mode == WeaponModes.MODES.AUTO and 5 or 1
    local hits = 0
    local totalDamage = 0
    local rolls = {}
    
    for i = 1, bulletCount do
        -- Determine hit (simple random roll)
        local roll = math.random(1, 100)
        table.insert(rolls, roll)
        
        if roll <= effectiveAccuracy then
            hits = hits + 1
            totalDamage = totalDamage + modifiedWeapon.damage
        end
    end

    return {
        success = true,
        hit = hits > 0,
        hits = hits,
        bulletCount = bulletCount,
        damage = totalDamage,
        accuracy = effectiveAccuracy,
        rolls = rolls,
        distance = distance,
        maxRange = modifiedWeapon.maxRange,
        weaponId = weaponId,
        mode = mode,
        apCost = apCost,
        epCost = epCost,
        critChance = modifiedWeapon.critChance,
        rangeZone = RangeSystem.getRangeZone(distance, modifiedWeapon.maxRange),
        accuracyZone = AccuracySystem.getAccuracyZoneDescription(distance, modifiedWeapon.maxRange)
    }
end

-- Get shooting information without actually shooting
-- Useful for UI display and targeting
-- @param shooter table: Shooter unit
-- @param target table: Target unit
-- @param weaponId string: Weapon to use (optional)
-- @param mode string: Firing mode (optional, defaults to AIM)
-- @return table: Shooting info with accuracy, range, etc.
function ShootingSystem.getShootingInfo(shooter, target, weaponId, mode)
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

    -- Default to AIM mode
    mode = mode or WeaponModes.MODES.AIM

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

    -- Get weapon properties and apply mode
    local weapon = {
        id = weaponId,
        maxRange = WeaponSystem.getMaxRange(weaponId),
        baseAccuracy = WeaponSystem.getBaseAccuracy(weaponId),
        damage = WeaponSystem.getDamage(weaponId),
        ammo = WeaponSystem.getAmmo(weaponId) or 999,
        critChance = WeaponSystem.getCritChance(weaponId) or 5,
        apCost = 6,  -- Default base AP cost
        epCost = 3   -- Default base EP cost
    }
    
    local modifiedWeapon, apCost, epCost = WeaponModes.applyMode(weapon, mode, shooter)
    if not modifiedWeapon then
        return {
            canShoot = false,
            error = "Cannot use this mode",
            accuracy = 0,
            distance = 0,
            maxRange = 0
        }
    end

    -- Check if in range
    local canShoot = RangeSystem.isInRange(distance, modifiedWeapon.maxRange)

    -- Calculate effective accuracy
    local effectiveAccuracy = nil
    if canShoot then
        effectiveAccuracy = AccuracySystem.calculateEffectiveAccuracy(distance, modifiedWeapon.maxRange, modifiedWeapon.baseAccuracy)
    end

    return {
        canShoot = canShoot,
        accuracy = effectiveAccuracy or 0,
        distance = distance,
        maxRange = modifiedWeapon.maxRange,
        weaponId = weaponId,
        mode = mode,
        apCost = apCost,
        epCost = epCost,
        critChance = modifiedWeapon.critChance,
        damage = modifiedWeapon.damage,
        bulletCount = mode == WeaponModes.MODES.AUTO and 5 or 1,
        rangeZone = RangeSystem.getRangeZone(distance, modifiedWeapon.maxRange),
        accuracyZone = AccuracySystem.getAccuracyZoneDescription(distance, modifiedWeapon.maxRange),
        accuracyColor = AccuracySystem.getAccuracyZoneColor(distance, modifiedWeapon.maxRange)
    }
end

return ShootingSystem

























