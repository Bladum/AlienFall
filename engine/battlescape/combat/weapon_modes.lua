-- Weapon Modes System
-- Defines firing modes that modify weapon behavior: SNAP, AIM, LONG, AUTO, HEAVY, FINESSE
-- All weapons have base stats and a list of available modes
-- Modes apply common modifiers that aren't weapon-specific (unlike X-COM UFO)

local WeaponModes = {}

--- Weapon mode enumeration
WeaponModes.MODES = {
    SNAP = "snap",       -- Quick shot, low accuracy, low cost
    AIM = "aim",         -- Aimed shot, high accuracy, medium cost
    LONG = "long",       -- Long range shot, extended range, high cost
    AUTO = "auto",       -- Automatic burst, multiple bullets, very high cost
    HEAVY = "heavy",     -- Heavy attack, high damage, very high cost
    FINESSE = "finesse"  -- Precise attack, bonus accuracy, low damage
}

--- Weapon mode definitions
--- Each mode modifies base weapon stats with multipliers and additions
WeaponModes.DEFINITIONS = {
    -- SNAP: Quick reaction shot with reduced accuracy
    -- Low AP cost makes it ideal for reaction fire and multiple shots per turn
    snap = {
        name = "Snap Shot",
        description = "Quick shot with reduced accuracy",
        icon = "snap",
        modifiers = {
            apCost = 0.5,          -- 50% of base AP cost
            epCost = 0.5,          -- 50% of base EP cost
            damage = 1.0,          -- Normal damage
            accuracy = 0.7,        -- 70% accuracy
            range = 1.0,           -- Normal range
            bulletsPerShot = 1,    -- Single bullet
            recoil = 0.8          -- 80% recoil (easier to control)
        },
        requirements = {
            minRange = 0,
            maxRange = 999,
            requiresAmmo = true
        },
        color = {100, 255, 100}    -- Green (fast)
    },
    
    -- AIM: Carefully aimed shot with improved accuracy
    -- Balanced choice for most combat situations
    aim = {
        name = "Aimed Shot",
        description = "Carefully aimed shot with improved accuracy",
        icon = "aim",
        modifiers = {
            apCost = 1.0,          -- 100% of base AP cost (standard)
            epCost = 1.0,          -- 100% of base EP cost
            damage = 1.0,          -- Normal damage
            accuracy = 1.3,        -- 130% accuracy (major boost)
            range = 1.0,           -- Normal range
            bulletsPerShot = 1,    -- Single bullet
            recoil = 1.0          -- Normal recoil
        },
        requirements = {
            minRange = 0,
            maxRange = 999,
            requiresAmmo = true
        },
        color = {255, 255, 100}    -- Yellow (balanced)
    },
    
    -- LONG: Extended range shot with increased accuracy at distance
    -- Ideal for sniping and long-distance engagement
    long = {
        name = "Long Range",
        description = "Extended range shot with bonus accuracy at distance",
        icon = "long",
        modifiers = {
            apCost = 1.5,          -- 150% of base AP cost
            epCost = 1.2,          -- 120% of base EP cost
            damage = 1.1,          -- 110% damage (better placement)
            accuracy = 1.5,        -- 150% accuracy
            range = 1.5,           -- 150% range
            bulletsPerShot = 1,    -- Single bullet
            recoil = 1.2          -- 120% recoil (harder to control)
        },
        requirements = {
            minRange = 3,          -- Minimum 3 tiles distance
            maxRange = 999,
            requiresAmmo = true
        },
        color = {100, 200, 255}    -- Cyan (precision)
    },
    
    -- AUTO: Automatic burst fire with multiple bullets
    -- High damage output but expensive and less accurate per bullet
    auto = {
        name = "Auto Fire",
        description = "Automatic burst with multiple bullets",
        icon = "auto",
        modifiers = {
            apCost = 2.0,          -- 200% of base AP cost (very expensive)
            epCost = 2.5,          -- 250% of base EP cost (exhausting)
            damage = 0.8,          -- 80% damage per bullet
            accuracy = 0.6,        -- 60% accuracy per bullet
            range = 0.8,           -- 80% range (recoil reduces effective range)
            bulletsPerShot = 5,    -- 5 bullets per burst
            recoil = 2.0          -- 200% recoil (hard to control)
        },
        requirements = {
            minRange = 0,
            maxRange = 999,
            requiresAmmo = true,
            minAmmo = 5            -- Needs at least 5 bullets
        },
        color = {255, 150, 50}     -- Orange (aggressive)
    },
    
    -- HEAVY: Maximum damage shot with high resource cost
    -- Used for armored targets or critical moments
    heavy = {
        name = "Heavy Attack",
        description = "Maximum damage shot with high cost",
        icon = "heavy",
        modifiers = {
            apCost = 2.5,          -- 250% of base AP cost
            epCost = 3.0,          -- 300% of base EP cost (very tiring)
            damage = 1.5,          -- 150% damage
            accuracy = 0.9,        -- 90% accuracy (harder to aim heavy shot)
            range = 0.9,           -- 90% range
            bulletsPerShot = 1,    -- Single bullet
            recoil = 1.5,         -- 150% recoil
            critChance = 0.1      -- +10% critical hit chance
        },
        requirements = {
            minRange = 0,
            maxRange = 999,
            requiresAmmo = true
        },
        color = {255, 50, 50}      -- Red (powerful)
    },
    
    -- FINESSE: Precise shot with reduced damage but high accuracy
    -- Ideal for hitting weak points, critical areas, or avoiding collateral damage
    finesse = {
        name = "Finesse Shot",
        description = "Precise shot with bonus accuracy but reduced damage",
        icon = "finesse",
        modifiers = {
            apCost = 1.2,          -- 120% of base AP cost
            epCost = 0.8,          -- 80% of base EP cost (controlled)
            damage = 0.7,          -- 70% damage
            accuracy = 1.8,        -- 180% accuracy (very precise)
            range = 1.0,           -- Normal range
            bulletsPerShot = 1,    -- Single bullet
            recoil = 0.5,         -- 50% recoil (very controlled)
            critChance = 0.15     -- +15% critical hit chance
        },
        requirements = {
            minRange = 0,
            maxRange = 999,
            requiresAmmo = true
        },
        color = {200, 100, 255}    -- Purple (skillful)
    }
}

--- Apply weapon mode modifiers to base weapon stats
-- @param baseStats table Base weapon statistics
-- @param modeName string Mode name to apply
-- @return table Modified stats
function WeaponModes.applyMode(baseStats, modeName)
    local mode = WeaponModes.DEFINITIONS[modeName]
    if not mode then
        print("[WeaponModes] Invalid mode: " .. tostring(modeName))
        return baseStats
    end
    
    local modifiers = mode.modifiers
    local modified = {}
    
    -- Apply multipliers to base stats
    modified.apCost = math.ceil((baseStats.apCost or 4) * modifiers.apCost)
    modified.epCost = math.ceil((baseStats.epCost or 2) * modifiers.epCost)
    modified.damage = math.floor((baseStats.damage or 10) * modifiers.damage)
    modified.accuracy = math.floor((baseStats.accuracy or 50) * modifiers.accuracy)
    modified.range = math.floor((baseStats.range or 10) * modifiers.range)
    modified.bulletsPerShot = modifiers.bulletsPerShot or 1
    modified.recoil = (baseStats.recoil or 1.0) * modifiers.recoil
    
    -- Add critical chance bonus if mode provides it
    modified.critChance = (baseStats.critChance or 0.0) + (modifiers.critChance or 0.0)
    
    -- Copy over mode name and requirements
    modified.modeName = modeName
    modified.modeDisplayName = mode.name
    modified.requirements = mode.requirements
    
    print("[WeaponModes] Applied mode '" .. modeName .. "': AP=" .. modified.apCost .. 
          ", Damage=" .. modified.damage .. ", Accuracy=" .. modified.accuracy .. 
          ", Bullets=" .. modified.bulletsPerShot)
    
    return modified
end

--- Check if unit can use a weapon mode
-- @param unit table Unit attempting to use mode
-- @param weapon table Weapon stats
-- @param modeName string Mode to check
-- @param targetDistance number Optional distance to target
-- @return boolean, string True if can use, false + reason if cannot
function WeaponModes.canUseMode(unit, weapon, modeName, targetDistance)
    local mode = WeaponModes.DEFINITIONS[modeName]
    if not mode then
        return false, "Invalid mode"
    end
    
    -- Check if weapon supports this mode
    if weapon.availableModes and not weapon.availableModes[modeName] then
        return false, "Weapon doesn't support this mode"
    end
    
    -- Apply mode modifiers
    local modifiedStats = WeaponModes.applyMode(weapon, modeName)
    
    -- Check AP requirement
    if unit.actionPoints and unit.actionPoints < modifiedStats.apCost then
        return false, "Not enough AP (" .. modifiedStats.apCost .. " required)"
    end
    
    -- Check EP requirement
    if unit.energyPoints and unit.energyPoints < modifiedStats.epCost then
        return false, "Not enough energy (" .. modifiedStats.epCost .. " required)"
    end
    
    -- Check ammo requirement
    if mode.requirements.requiresAmmo then
        local ammoNeeded = modifiedStats.bulletsPerShot
        if mode.requirements.minAmmo then
            ammoNeeded = mode.requirements.minAmmo
        end
        
        if weapon.currentAmmo and weapon.currentAmmo < ammoNeeded then
            return false, "Not enough ammo (" .. ammoNeeded .. " required)"
        end
    end
    
    -- Check range requirement
    if targetDistance then
        if targetDistance < mode.requirements.minRange then
            return false, "Target too close (min " .. mode.requirements.minRange .. " tiles)"
        end
        
        if targetDistance > modifiedStats.range then
            return false, "Target out of range (max " .. modifiedStats.range .. " tiles)"
        end
    end
    
    return true, "Can use mode"
end

--- Get available modes for a weapon
-- @param weapon table Weapon data
-- @return table Array of available mode names
function WeaponModes.getAvailableModes(weapon)
    if weapon.availableModes then
        local modes = {}
        for mode, _ in pairs(weapon.availableModes) do
            table.insert(modes, mode)
        end
        return modes
    end
    
    -- Default: all weapons have snap and aim
    return {"snap", "aim"}
end

--- Get mode definition
-- @param modeName string Mode name
-- @return table Mode definition or nil
function WeaponModes.getMode(modeName)
    return WeaponModes.DEFINITIONS[modeName]
end

--- Get mode color for UI
-- @param modeName string Mode name
-- @return table RGB color {r, g, b}
function WeaponModes.getColor(modeName)
    local mode = WeaponModes.getMode(modeName)
    return mode and mode.color or {255, 255, 255}
end

--- Get mode info for UI display
-- @param modeName string Mode name
-- @return table Info with name, description, modifiers
function WeaponModes.getInfo(modeName)
    local mode = WeaponModes.getMode(modeName)
    if not mode then
        return nil
    end
    
    return {
        name = mode.name,
        description = mode.description,
        modifiers = mode.modifiers,
        requirements = mode.requirements,
        color = mode.color
    }
end

--- Example weapon with modes:
--[[
    local rifle = {
        name = "Assault Rifle",
        apCost = 6,
        epCost = 3,
        damage = 15,
        accuracy = 60,
        range = 12,
        critChance = 0.05,
        currentAmmo = 30,
        availableModes = {
            snap = true,
            aim = true,
            auto = true
        }
    }
    
    -- Snap shot: 3 AP, 2 EP, 15 damage, 42 accuracy (60*0.7)
    -- Aim shot: 6 AP, 3 EP, 15 damage, 78 accuracy (60*1.3)
    -- Auto burst: 12 AP, 8 EP, 12 damage per bullet (15*0.8), 36 accuracy (60*0.6), 5 bullets
]]

return WeaponModes
