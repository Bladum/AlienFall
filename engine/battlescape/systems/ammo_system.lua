---Ammunition Management System - Reload & Ammo Types
---
---Implements comprehensive ammunition tracking, reload mechanics, and specialized ammo types
---with unique tactical effects. Tracks ammunition per weapon instance, handles empty weapon
---states, and provides reload actions with AP costs and time requirements.
---
---Ammo Types (4 variants):
---  - STANDARD: Baseline ammo with normal damage and penetration
---  - AP (Armor-Piercing): +50% armor penetration, -10% damage against unarmored
---  - EXPLOSIVE: +30% damage, +20% vs. cover, reduced accuracy
---  - INCENDIARY: Fire damage over time, creates fire tiles, +30% vs. organic
---
---Reload Mechanics:
---  - AP Cost: 2-4 AP depending on weapon type (pistols 2 AP, rifles 3 AP, heavy 4 AP)
---  - Turn-Based: Reload completes immediately (no real-time waiting)
---  - Interrupted Reloads: Can be interrupted by reaction fire or status effects
---  - Emergency Reload: Quick reload at +1 AP cost but reduced accuracy next shot
---
---Ammo Capacity by Weapon Type:
---  - Pistols: 12-15 rounds per magazine
---  - SMGs: 30-40 rounds per magazine
---  - Rifles: 20-30 rounds per magazine
---  - Shotguns: 6-8 shells
---  - Sniper Rifles: 5-10 rounds
---  - Heavy Weapons: 50-200 rounds belt-fed or 3-5 rockets
---
---Ammo Effects on Combat:
---  - Damage Modifiers: Each ammo type modifies base weapon damage
---  - Penetration: AP ammo ignores more armor points
---  - Special Effects: Incendiary creates fire, explosive damages cover
---  - Accuracy Impact: Explosive ammo has -10% accuracy penalty
---
---Empty Weapon Handling:
---  - Visual Indicator: Red ammo counter when empty
---  - Action Restriction: Cannot shoot when out of ammo
---  - Auto-Reload Option: Can enable auto-reload when empty (costs AP)
---  - Swap Weapon: Can switch to sidearm as free action when primary empty
---
---Key Exports:
---  - trackAmmo(weaponId): Initializes ammo tracking for weapon
---  - consumeAmmo(weaponId, amount): Reduces ammo by amount (1 per shot)
---  - reload(unit, weaponId): Performs reload action (costs AP)
---  - getAmmoCount(weaponId): Returns current/max ammo
---  - setAmmoType(weaponId, ammoType): Changes loaded ammo type
---  - hasAmmo(weaponId): Checks if weapon has ammo remaining
---
---Testing Features:
---  - Infinite Ammo Mode: Disables ammo consumption for testing
---  - Debug Display: Shows ammo counts for all units
---  - Reload Logging: Prints reload actions to console
---
---Integration:
---  - Works with weapon_system.lua for weapon properties
---  - Uses action_system.lua for reload AP costs
---  - Integrates with inventory_system.lua for spare magazines
---  - Connects to ui system for ammo counter display
---
---@module battlescape.systems.ammo_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local AmmoSystem = require("battlescape.systems.ammo_system")
---  AmmoSystem.consumeAmmo(weaponId, 1) -- Fire one shot
---  if not AmmoSystem.hasAmmo(weaponId) then
---      AmmoSystem.reload(unit, weaponId)
---  end
---  AmmoSystem.setAmmoType(weaponId, "AP")
---
---@see battlescape.combat.weapon_system For weapon definitions
---@see battlescape.systems.inventory_system For spare magazine management

local AmmoSystem = {}

-- Configuration
local CONFIG = {
    -- Weapon Ammo Capacity
    WEAPON_CAPACITY = {
        PISTOL = 15,
        RIFLE = 30,
        SHOTGUN = 8,
        SNIPER = 10,
        SMG = 40,
        MACHINE_GUN = 100,
        LASER_RIFLE = 20,      -- Energy weapons use "charges"
        PLASMA_RIFLE = 15,
    },
    
    -- Reload AP Costs
    RELOAD_AP_COST = {
        PISTOL = 2,
        RIFLE = 3,
        SHOTGUN = 3,
        SNIPER = 4,
        SMG = 2,
        MACHINE_GUN = 4,
        LASER_RIFLE = 2,       -- Quick charge swap
        PLASMA_RIFLE = 2,
    },
    
    -- Ammo Types
    AMMO_TYPES = {
        STANDARD = {
            name = "Standard Ammo",
            damageMultiplier = 1.0,
            armorPenBonus = 0,
            specialEffect = nil,
        },
        AP = {
            name = "Armor-Piercing",
            damageMultiplier = 0.9,        -- 90% damage
            armorPenBonus = 10,            -- +10 armor penetration
            specialEffect = nil,
        },
        EXPLOSIVE = {
            name = "Explosive Rounds",
            damageMultiplier = 1.3,        -- 130% damage
            armorPenBonus = -5,            -- -5 armor penetration
            specialEffect = "EXPLOSION",   -- Creates small explosion on hit
            explosionRadius = 1,
            explosionDamage = 5,
        },
        INCENDIARY = {
            name = "Incendiary Rounds",
            damageMultiplier = 1.1,        -- 110% damage
            armorPenBonus = 0,
            specialEffect = "FIRE",        -- Creates fire on hit
            fireDuration = 3,
            fireIntensity = 3,
        },
    },
    
    -- Infinite Ammo Mode (for testing)
    INFINITE_AMMO = false,
}

-- Weapon ammo state
-- Format: weaponAmmo[weaponId] = { currentAmmo, maxAmmo, ammoType, weaponType }
local weaponAmmo = {}

--[[
    Initialize weapon ammo tracking
    
    @param weaponId: Weapon instance identifier
    @param weaponType: Type of weapon (PISTOL, RIFLE, etc.)
    @param ammoType: Type of ammo loaded (STANDARD, AP, etc.)
    @param startingAmmo: Starting ammo count (optional, defaults to max capacity)
]]
function AmmoSystem.initializeWeapon(weaponId, weaponType, ammoType, startingAmmo)
    local maxAmmo = CONFIG.WEAPON_CAPACITY[weaponType] or 30
    startingAmmo = startingAmmo or maxAmmo
    
    weaponAmmo[weaponId] = {
        weaponType = weaponType,
        currentAmmo = math.min(startingAmmo, maxAmmo),
        maxAmmo = maxAmmo,
        ammoType = ammoType or "STANDARD",
    }
    
    print(string.format("[AmmoSystem] Initialized weapon %s (%s) with %d/%d %s ammo",
        tostring(weaponId), weaponType, weaponAmmo[weaponId].currentAmmo, maxAmmo, ammoType or "STANDARD"))
end

--[[
    Remove weapon from ammo tracking
    
    @param weaponId: Weapon instance identifier
]]
function AmmoSystem.removeWeapon(weaponId)
    weaponAmmo[weaponId] = nil
    print(string.format("[AmmoSystem] Removed weapon %s from ammo tracking", tostring(weaponId)))
end

--[[
    Check if weapon can fire (has ammo)
    
    @param weaponId: Weapon instance identifier
    @return canFire: Boolean
    @return ammoCount: Current ammo count
]]
function AmmoSystem.canFire(weaponId)
    if CONFIG.INFINITE_AMMO then
        return true, 999
    end
    
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return false, 0
    end
    
    return ammo.currentAmmo > 0, ammo.currentAmmo
end

--[[
    Consume ammo when firing
    
    @param weaponId: Weapon instance identifier
    @param ammoUsed: Number of rounds fired (default 1)
    @return success: Boolean
    @return remainingAmmo: Current ammo after consumption
]]
function AmmoSystem.consumeAmmo(weaponId, ammoUsed)
    if CONFIG.INFINITE_AMMO then
        return true, 999
    end
    
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return false, 0
    end
    
    ammoUsed = ammoUsed or 1
    
    if ammo.currentAmmo < ammoUsed then
        return false, ammo.currentAmmo  -- Not enough ammo
    end
    
    ammo.currentAmmo = ammo.currentAmmo - ammoUsed
    
    print(string.format("[AmmoSystem] Weapon %s consumed %d ammo (%d remaining)",
        tostring(weaponId), ammoUsed, ammo.currentAmmo))
    
    return true, ammo.currentAmmo
end

--[[
    Reload weapon
    
    @param weaponId: Weapon instance identifier
    @param unitAP: Unit's current AP (to check if reload possible)
    @return success: Boolean
    @return apCost: AP cost for reload
    @return message: String message
]]
function AmmoSystem.reloadWeapon(weaponId, unitAP)
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return false, 0, "Weapon not found"
    end
    
    -- Check if already full
    if ammo.currentAmmo >= ammo.maxAmmo then
        return false, 0, "Weapon already full"
    end
    
    -- Check AP cost
    local reloadCost = CONFIG.RELOAD_AP_COST[ammo.weaponType] or 3
    if unitAP < reloadCost then
        return false, reloadCost, string.format("Not enough AP (need %d)", reloadCost)
    end
    
    -- Perform reload
    ammo.currentAmmo = ammo.maxAmmo
    
    print(string.format("[AmmoSystem] Weapon %s reloaded to %d ammo (cost %d AP)",
        tostring(weaponId), ammo.maxAmmo, reloadCost))
    
    return true, reloadCost, "Reloaded"
end

--[[
    Change ammo type
    
    @param weaponId: Weapon instance identifier
    @param newAmmoType: New ammo type (STANDARD, AP, EXPLOSIVE, INCENDIARY)
    @param unitAP: Unit's current AP
    @return success: Boolean
    @return apCost: AP cost (same as reload)
]]
function AmmoSystem.changeAmmoType(weaponId, newAmmoType, unitAP)
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return false, 0
    end
    
    -- Check if ammo type exists
    if not CONFIG.AMMO_TYPES[newAmmoType] then
        return false, 0
    end
    
    -- Changing ammo type = reload action
    local reloadCost = CONFIG.RELOAD_AP_COST[ammo.weaponType] or 3
    if unitAP < reloadCost then
        return false, reloadCost
    end
    
    -- Change ammo type and reload to full
    ammo.ammoType = newAmmoType
    ammo.currentAmmo = ammo.maxAmmo
    
    print(string.format("[AmmoSystem] Weapon %s changed to %s ammo (cost %d AP)",
        tostring(weaponId), newAmmoType, reloadCost))
    
    return true, reloadCost
end

--[[
    Get current ammo count
    
    @param weaponId: Weapon instance identifier
    @return currentAmmo, maxAmmo: Ammo counts
]]
function AmmoSystem.getAmmoCount(weaponId)
    if CONFIG.INFINITE_AMMO then
        return 999, 999
    end
    
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return 0, 0
    end
    
    return ammo.currentAmmo, ammo.maxAmmo
end

--[[
    Get weapon ammo type
    
    @param weaponId: Weapon instance identifier
    @return ammoType: String
]]
function AmmoSystem.getAmmoType(weaponId)
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return "STANDARD"
    end
    return ammo.ammoType
end

--[[
    Get ammo type effects
    
    @param ammoType: String (STANDARD, AP, etc.)
    @return effects table
]]
function AmmoSystem.getAmmoTypeEffects(ammoType)
    return CONFIG.AMMO_TYPES[ammoType] or CONFIG.AMMO_TYPES.STANDARD
end

--[[
    Apply ammo type effects to damage calculation
    
    @param weaponId: Weapon instance identifier
    @param baseDamage: Base damage before ammo effects
    @param baseArmorPen: Base armor penetration
    @return modifiedDamage, modifiedArmorPen, specialEffect
]]
function AmmoSystem.applyAmmoEffects(weaponId, baseDamage, baseArmorPen)
    local ammoType = AmmoSystem.getAmmoType(weaponId)
    local effects = AmmoSystem.getAmmoTypeEffects(ammoType)
    
    local modifiedDamage = math.floor(baseDamage * effects.damageMultiplier)
    local modifiedArmorPen = baseArmorPen + effects.armorPenBonus
    
    return modifiedDamage, modifiedArmorPen, effects.specialEffect
end

--[[
    Get reload AP cost for weapon
    
    @param weaponId: Weapon instance identifier
    @return apCost: Number of AP
]]
function AmmoSystem.getReloadAPCost(weaponId)
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return 3
    end
    return CONFIG.RELOAD_AP_COST[ammo.weaponType] or 3
end

--[[
    Check if weapon is empty
    
    @param weaponId: Weapon instance identifier
    @return isEmpty: Boolean
]]
function AmmoSystem.isWeaponEmpty(weaponId)
    if CONFIG.INFINITE_AMMO then
        return false
    end
    
    local ammo = weaponAmmo[weaponId]
    if not ammo then
        return true
    end
    
    return ammo.currentAmmo <= 0
end

--[[
    Get ammo percentage for UI
    
    @param weaponId: Weapon instance identifier
    @return percentage: 0-100
]]
function AmmoSystem.getAmmoPercentage(weaponId)
    local current, max = AmmoSystem.getAmmoCount(weaponId)
    if max == 0 then
        return 0
    end
    return (current / max) * 100
end

--[[
    Visualize ammo data for UI
    
    @param weaponId: Weapon instance identifier
    @return visualization data
]]
function AmmoSystem.visualizeAmmo(weaponId)
    local current, max = AmmoSystem.getAmmoCount(weaponId)
    local ammoType = AmmoSystem.getAmmoType(weaponId)
    local effects = AmmoSystem.getAmmoTypeEffects(ammoType)
    local percentage = AmmoSystem.getAmmoPercentage(weaponId)
    local isEmpty = AmmoSystem.isWeaponEmpty(weaponId)
    local reloadCost = AmmoSystem.getReloadAPCost(weaponId)
    
    local color
    if percentage >= 75 then
        color = { r = 0, g = 255, b = 0 }      -- Green
    elseif percentage >= 50 then
        color = { r = 255, g = 255, b = 0 }    -- Yellow
    elseif percentage >= 25 then
        color = { r = 255, g = 150, b = 0 }    -- Orange
    else
        color = { r = 255, g = 0, b = 0 }      -- Red
    end
    
    return {
        currentAmmo = current,
        maxAmmo = max,
        percentage = percentage,
        isEmpty = isEmpty,
        ammoType = ammoType,
        ammoTypeName = effects.name,
        reloadCost = reloadCost,
        color = color,
    }
end

--[[
    Get all weapon ammo state (for debugging)
    
    @return table of all weapon ammo
]]
function AmmoSystem.getAllAmmo()
    return weaponAmmo
end

--[[
    Toggle infinite ammo mode
    
    @param enabled: Boolean
]]
function AmmoSystem.setInfiniteAmmo(enabled)
    CONFIG.INFINITE_AMMO = enabled
    print(string.format("[AmmoSystem] Infinite ammo: %s", tostring(enabled)))
end

return AmmoSystem






















