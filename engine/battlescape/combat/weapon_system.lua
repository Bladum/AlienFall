---WeaponSystem - Weapon Definition Loader and Manager
---
---Manages weapon definitions and properties. Loads weapon data from TOML files
---in mod directories and provides weapon information lookups. Central registry
---for all weapon statistics, properties, and behaviors.
---
---Features:
---  - TOML-based weapon loading
---  - Weapon definition caching
---  - Mod content integration
---  - Weapon property lookups
---  - Validation and error checking
---
---Weapon Properties (from TOML):
---  - id: Unique identifier
---  - name: Display name
---  - damage: Base damage value
---  - accuracy: Base accuracy (0.0-1.0)
---  - range: Maximum range in tiles
---  - apCost: Action point cost to fire
---  - ammoCapacity: Magazine size
---  - modes: Available firing modes (snap, aim, auto, etc.)
---  - damageType: Damage type (kinetic, explosive, energy, etc.)
---
---Loading Process:
---  1. Scan mod directories for weapons/*.toml
---  2. Parse TOML files
---  3. Validate weapon definitions
---  4. Cache in weaponCache
---  5. Return weapon data on request
---
---Key Exports:
---  - WeaponSystem.loadWeapons(): Loads all weapons from mods
---  - WeaponSystem.getWeapon(id): Returns weapon definition
---  - WeaponSystem.getAllWeapons(): Returns all weapons
---  - WeaponSystem.validateWeapon(weapon): Validates weapon data
---  - WeaponSystem.clearCache(): Clears cached weapons
---
---Dependencies:
---  - core.data_loader: TOML file loading
---
---@module battlescape.combat.weapon_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local WeaponSystem = require("battlescape.combat.weapon_system")
---  WeaponSystem.loadWeapons()
---  local rifle = WeaponSystem.getWeapon("assault_rifle")
---
---@see battlescape.combat.weapon_modes For firing modes
---@see battlescape.combat.damage_types For damage types

-- weapon_system.lua
-- Weapon system for managing weapon definitions and properties
-- Loads weapon data from TOML files and provides weapon information

local DataLoader = require("core.data_loader")

local WeaponSystem = {}

-- Cache for loaded weapon definitions
WeaponSystem.weaponCache = {}

-- Load weapon definitions from mods
function WeaponSystem.loadWeapons()
    if next(WeaponSystem.weaponCache) then
        return WeaponSystem.weaponCache  -- Already loaded
    end

    print("[WeaponSystem] Loading weapon definitions...")

    -- Load weapons from all enabled mods
    local weaponsData = DataLoader.loadWeapons()
    if weaponsData then
        for weaponId, weaponDef in pairs(weaponsData) do
            WeaponSystem.weaponCache[weaponId] = weaponDef
            print(string.format("[WeaponSystem] Loaded weapon: %s (%s)", weaponDef.name, weaponId))
        end
    else
        print("[ERROR] WeaponSystem.loadWeapons: Failed to load weapon data")
    end

    return WeaponSystem.weaponCache
end

-- Get weapon definition by ID
-- @param weaponId string: Weapon identifier
-- @return table|nil: Weapon definition or nil if not found
function WeaponSystem.getWeapon(weaponId)
    if not weaponId then
        return nil
    end

    -- Load weapons if not already loaded
    if not next(WeaponSystem.weaponCache) then
        WeaponSystem.loadWeapons()
    end

    return WeaponSystem.weaponCache[weaponId]
end

-- Get weapon base accuracy as percentage (0-100)
-- @param weaponId string: Weapon identifier
-- @return number: Base accuracy percentage (0-100)
function WeaponSystem.getBaseAccuracy(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getBaseAccuracy: Weapon '%s' not found", weaponId or "nil"))
        return 50  -- Default 50% accuracy
    end

    return weapon.base_accuracy or 50
end

-- Get weapon AP cost
-- @param weaponId string: Weapon identifier
-- @return number: Action points required to use weapon
function WeaponSystem.getApCost(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getApCost: Weapon '%s' not found", weaponId or "nil"))
        return 1  -- Default AP cost
    end

    return weapon.ap_cost or 1
end

-- Get weapon EP cost
-- @param weaponId string: Weapon identifier
-- @return number: Energy points required to use weapon
function WeaponSystem.getEpCost(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getEpCost: Weapon '%s' not found", weaponId or "nil"))
        return 1  -- Default EP cost
    end

    return weapon.ep_cost or 1
end

-- Get weapon cooldown
-- @param weaponId string: Weapon identifier
-- @return number: Cooldown in turns (0 = no cooldown)
function WeaponSystem.getCooldown(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getCooldown: Weapon '%s' not found", weaponId or "nil"))
        return 0  -- Default no cooldown
    end

    return weapon.cooldown or 0
end

-- Get weapon maximum range
-- @param weaponId string: Weapon identifier
-- @return number: Maximum range in tiles
function WeaponSystem.getMaxRange(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getMaxRange: Weapon '%s' not found", weaponId or "nil"))
        return 10  -- Default range
    end

    return weapon.range or 10
end

-- Get weapon damage
-- @param weaponId string: Weapon identifier
-- @return number: Base damage value
function WeaponSystem.getDamage(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getDamage: Weapon '%s' not found", weaponId or "nil"))
        return 1  -- Default damage
    end

    return weapon.damage or 1
end

-- Check if weapon is ranged
-- @param weaponId string: Weapon identifier
-- @return boolean: True if weapon is ranged
function WeaponSystem.isRanged(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        return false
    end

    return weapon.type == "ranged"
end

-- Get weapon type
-- @param weaponId string: Weapon identifier
-- @return string: Weapon type ("ranged", "melee", "grenade", "special")
function WeaponSystem.getWeaponType(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        return "unknown"
    end

    return weapon.type or "unknown"
end

-- Get all loaded weapons
-- @return table: Table of weapon definitions keyed by weapon ID
function WeaponSystem.getAllWeapons()
    if not next(WeaponSystem.weaponCache) then
        WeaponSystem.loadWeapons()
    end

    return WeaponSystem.weaponCache
end

--- Check if a unit can use a specific weapon.
---
--- Validates weapon exists, unit has sufficient AP/EP, weapon is not on cooldown,
--- and unit has the weapon equipped.
---
--- @param unit table Unit entity
--- @param weaponId string Weapon identifier
--- @return boolean True if weapon can be used
--- @return string|nil Error message if cannot use
function WeaponSystem.canUseWeapon(unit, weaponId)
    -- Check if weapon exists
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        return false, "Weapon not found: " .. weaponId
    end

    -- Check if unit has weapon equipped
    if unit.left_weapon ~= weaponId and unit.right_weapon ~= weaponId then
        return false, "Weapon not equipped: " .. weaponId
    end

    -- Check action points
    local apCost = WeaponSystem.getApCost(weaponId)
    if unit.actionPointsLeft < apCost then
        return false, string.format("Insufficient AP: need %d, have %d", apCost, unit.actionPointsLeft)
    end

    -- Check energy points
    local epCost = WeaponSystem.getEpCost(weaponId)
    if unit.energy < epCost then
        return false, string.format("Insufficient EP: need %d, have %d", epCost, unit.energy)
    end

    -- Check cooldown
    if unit:isWeaponOnCooldown(weaponId) then
        local cooldown = unit.weapon_cooldowns[weaponId]
        return false, string.format("Weapon on cooldown: %d turns remaining", cooldown)
    end

    return true, nil
end

--- Calculate accuracy for shooting at a target.
---
--- Takes into account weapon base accuracy, range to target, and any modifiers.
--- Accuracy falls off based on distance from target.
---
--- @param unit table Shooting unit
--- @param weaponId string Weapon being used
--- @param targetX number Target X position
--- @param targetY number Target Y position
--- @return number Accuracy percentage (0-100)
function WeaponSystem.calculateAccuracy(unit, weaponId, targetX, targetY)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        return 0
    end

    local baseAccuracy = WeaponSystem.getBaseAccuracy(weaponId)
    local maxRange = WeaponSystem.getMaxRange(weaponId)

    -- Calculate distance
    local distance = math.sqrt((unit.x - targetX)^2 + (unit.y - targetY)^2)

    -- Cannot shoot beyond 125% of max range
    if distance > maxRange * 1.25 then
        return 0
    end

    -- Accuracy zones
    local accuracyMultiplier
    if distance <= maxRange * 0.75 then
        -- 0% to 75% of max range: 100% accuracy
        accuracyMultiplier = 1.0
    elseif distance <= maxRange then
        -- 75% to 100% of max range: Linear drop from 100% to 50%
        local ratio = (distance - maxRange * 0.75) / (maxRange * 0.25)
        accuracyMultiplier = 1.0 - (ratio * 0.5)
    else
        -- 100% to 125% of max range: Linear drop from 50% to 0%
        local ratio = (distance - maxRange) / (maxRange * 0.25)
        accuracyMultiplier = 0.5 - (ratio * 0.5)
    end

    -- Ensure multiplier is within bounds
    accuracyMultiplier = math.max(0, math.min(1, accuracyMultiplier))

    local finalAccuracy = baseAccuracy * accuracyMultiplier
    return math.floor(finalAccuracy + 0.5) -- Round to nearest integer
end

--- Get weapon critical hit chance bonus.
---
--- Returns the weapon's base critical hit chance bonus percentage.
--- This is added to the base 5% crit + unit class bonus.
---
--- @param weaponId string Weapon identifier
--- @return number Critical hit chance bonus percentage (0-20+)
function WeaponSystem.getCritChance(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getCritChance: Weapon '%s' not found", weaponId or "nil"))
        return 5  -- Default 5% crit
    end

    return weapon.critChance or 5
end

--- Get weapon damage type (for armor resistance).
---
--- Returns the damage type used for armor penetration calculations.
--- Examples: kinetic, explosive, laser, plasma, acid, fire, etc.
---
--- @param weaponId string Weapon identifier
--- @return string Damage type identifier
function WeaponSystem.getDamageType(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getDamageType: Weapon '%s' not found", weaponId or "nil"))
        return "kinetic"  -- Default kinetic damage
    end

    return weapon.damageType or "kinetic"
end

--- Get weapon damage model (for stat distribution).
---
--- Returns how damage is distributed to unit stats after armor calculation.
--- Options: hurt (75% HP + 25% stun), stun (100% stun), morale (100% morale), energy (80% EP + 20% stun)
---
--- @param weaponId string Weapon identifier
--- @return string Damage model identifier
function WeaponSystem.getDamageModel(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getDamageModel: Weapon '%s' not found", weaponId or "nil"))
        return "hurt"  -- Default hurt model (lethal damage)
    end

    return weapon.damageModel or "hurt"
end

--- Get weapon ammo capacity.
---
--- Returns maximum ammo capacity for the weapon.
--- Returns nil for unlimited ammo weapons.
---
--- @param weaponId string Weapon identifier
--- @return number|nil Ammo capacity or nil for unlimited
function WeaponSystem.getAmmo(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        return nil
    end

    return weapon.ammo
end

--- Get weapon available firing modes.
---
--- Returns array of available firing modes for this weapon.
--- Modes: SNAP (quick), AIM (careful), LONG (sniper), AUTO (spray), HEAVY (power), FINESSE (precision)
--- If no modes defined, returns ["SNAP", "AIM"] as default.
---
--- @param weaponId string Weapon identifier
--- @return table Array of mode strings
function WeaponSystem.getAvailableModes(weaponId)
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        print(string.format("[ERROR] WeaponSystem.getAvailableModes: Weapon '%s' not found", weaponId or "nil"))
        return {"SNAP", "AIM"}  -- Default modes
    end

    return weapon.availableModes or {"SNAP", "AIM"}
end

--- Check if weapon supports a specific firing mode.
---
--- Returns true if the weapon can use the specified mode.
--- Used by UI to gray out unavailable modes and by shooting system to validate.
---
--- @param weaponId string Weapon identifier
--- @param mode string Mode to check (SNAP, AIM, LONG, AUTO, HEAVY, FINESSE)
--- @return boolean True if mode is available
function WeaponSystem.isModeAvailable(weaponId, mode)
    if not weaponId or not mode then
        return false
    end

    local availableModes = WeaponSystem.getAvailableModes(weaponId)
    
    for _, availableMode in ipairs(availableModes) do
        if availableMode == mode then
            return true
        end
    end

    return false
end

--- ========== DUAL-WIELD SYSTEM ==========

--- Check if unit can perform dual-wield attack
---
--- Validates:
--- - Unit has two_weapon_proficiency perk
--- - Both weapon slots filled with compatible weapons
--- - Both weapons are identical (same ID)
--- - Unit has sufficient AP
---
--- @param unit table Unit entity
--- @return boolean Can perform dual-wield
--- @return string|nil Reason if cannot
function WeaponSystem.canDualWield(unit)
    if not unit then
        return false, "Unit is nil"
    end
    
    -- Check if unit has dual-wield perk
    local PerkSystem = require("battlescape.systems.perks_system")
    if not PerkSystem.hasPerk(unit.id, "two_weapon_proficiency") then
        return false, "Unit lacks two_weapon_proficiency perk"
    end
    
    -- Check if both weapon slots are filled
    if not unit.left_weapon or not unit.right_weapon then
        return false, "Both weapon slots must be filled"
    end
    
    -- Check if weapons are identical
    if unit.left_weapon ~= unit.right_weapon then
        return false, "Weapons must be identical for dual-wield"
    end
    
    -- Check if unit has enough AP for dual-wield (1 AP)
    if unit.actionPointsLeft < 1 then
        return false, "Insufficient AP for dual-wield attack (need 1)"
    end
    
    return true, nil
end

--- Get accuracy penalty for dual-wield
---
--- Dual-wield attack has -10% accuracy penalty vs single weapon
---
--- @return number Accuracy penalty percentage
function WeaponSystem.getDualWieldAccuracyPenalty()
    return -10  -- -10% accuracy for dual-wield
end

--- Calculate dual-wield attack properties
---
--- - Weapon cost: 1 AP (same as single attack)
--- - Accuracy: -10% penalty
--- - Energy: 2× energy cost (both weapons)
--- - Damage: Sum of both weapon damages
---
--- @param unit table Unit entity
--- @param weaponId string Weapon ID
--- @return table|nil Stats table or nil on error
--- @return string|nil Error message
function WeaponSystem.calculateDualWieldStats(unit, weaponId)
    if not unit then
        return {}, "Unit is nil"
    end
    
    local weapon = WeaponSystem.getWeapon(weaponId)
    if not weapon then
        return {}, "Weapon not found: " .. weaponId
    end
    
    local canDW, reason = WeaponSystem.canDualWield(unit)
    if not canDW then
        return {}, reason
    end
    
    local stats = {
        ap_cost = 1,                                          -- 1 AP for both weapons
        accuracy_penalty = WeaponSystem.getDualWieldAccuracyPenalty(),  -- -10%
        energy_cost = (weapon.ep_cost or 1) * 2,            -- 2× energy
        total_damage = (weapon.damage or 1) * 2              -- Sum damage from both
    }
    
    return stats, nil
end

--- Format dual-wield info for display
---
--- @param unit table Unit entity
--- @return string Formatted dual-wield info
function WeaponSystem.formatDualWieldInfo(unit)
    local canDW, reason = WeaponSystem.canDualWield(unit)
    
    if not canDW then
        return "Cannot dual-wield: " .. (reason or "Unknown reason")
    end
    
    local weapon = WeaponSystem.getWeapon(unit.left_weapon)
    if not weapon then
        return "Dual-wield ready (weapon not found)"
    end
    
    local stats = WeaponSystem.calculateDualWieldStats(unit, unit.left_weapon)
    if not stats then
        return "Error calculating dual-wield"
    end
    
    return string.format("Dual-Wield: 1 AP | Dmg: %d | Acc: %d%% | EP: %d",
        stats.total_damage,
        WeaponSystem.getBaseAccuracy(unit.left_weapon) + stats.accuracy_penalty,
        stats.energy_cost)
end

return WeaponSystem


























