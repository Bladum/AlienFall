-- Damage Resolution System
-- Calculates damage from weapon power, applies armor resistance and value,
-- distributes to health/stun/morale/energy pools, handles wounds and effects

local DamageTypes = require("battlescape.combat.damage_types")
local DamageModels = require("battlescape.combat.damage_models")
local MoraleSystem = require("battlescape.combat.morale_system")

local DamageSystem = {}
DamageSystem.__index = DamageSystem

--- Base critical hit chance (can be modified by weapon and unit)
DamageSystem.BASE_CRITICAL_HIT_CHANCE = 0.05  -- 5% base chance

--- Wound bleeding damage per turn
DamageSystem.WOUND_BLEED_DAMAGE = 1

--- Create a new damage system instance
-- @param moraleSystem table Optional morale system instance
-- @return table New DamageSystem instance
function DamageSystem.new(moraleSystem)
    print("[DamageSystem] Initializing damage system")
    
    local self = setmetatable({}, DamageSystem)
    
    self.moraleSystem = moraleSystem or MoraleSystem.new()
    self.damageLog = {}  -- Log of recent damage events
    
    return self
end

--- Resolve damage from a projectile impact
-- @param projectile table Projectile that hit
-- @param targetUnit table Unit that was hit
-- @return table Damage result with breakdown
function DamageSystem:resolveDamage(projectile, targetUnit)
    print("[DamageSystem] Resolving damage: power=" .. projectile.power .. 
          ", type=" .. projectile.damageClass .. ", target=" .. (targetUnit.name or "Unknown"))
    
    -- Step 1: Get armor resistance for damage type
    local resistance = self:getArmorResistance(targetUnit, projectile.damageClass)
    
    -- Step 2: Apply resistance (divide by resistance value)
    local effectivePower = DamageTypes.applyResistance(projectile.power, resistance)
    
    -- Step 3: Get armor value and subtract it
    local armorValue = self:getArmorValue(targetUnit)
    local finalDamage = DamageTypes.applyArmorAbsorption(effectivePower, armorValue)
    
    print("[DamageSystem] Damage calculation: base=" .. projectile.power .. 
          ", resistance=" .. resistance .. ", effective=" .. effectivePower .. 
          ", armor=" .. armorValue .. ", final=" .. finalDamage)
    
    -- Step 4: Check for critical hit
    local isCritical = self:rollCriticalHit()
    if isCritical then
        finalDamage = finalDamage * 1.5  -- 50% bonus damage
        print("[DamageSystem] CRITICAL HIT! Damage increased to " .. finalDamage)
    end
    
    -- Step 5: Distribute damage to pools
    local damageResult = self:distributeDamage(targetUnit, projectile, finalDamage, isCritical)
    
    -- Step 6: Apply morale loss from taking damage
    if damageResult.healthDamage > 0 then
        local moraleLoss = self.moraleSystem:calculateDamageMoraleLoss(targetUnit, damageResult.healthDamage)
        self.moraleSystem:applyMoraleLoss(targetUnit, moraleLoss)
    end
    
    -- Step 7: Check for death/unconsciousness
    self:checkVitals(targetUnit)
    
    -- Log damage event
    table.insert(self.damageLog, {
        timestamp = love.timer.getTime(),
        target = targetUnit.name or "Unknown",
        damage = damageResult,
        critical = isCritical
    })
    
    return damageResult
end

--- Get armor resistance for a damage type
-- @param unit table Unit to check
-- @param damageType string Damage type
-- @return number Resistance value
function DamageSystem:getArmorResistance(unit, damageType)
    if not unit.armor or not unit.armor.resistances then
        return 1.0  -- No armor = no resistance
    end
    
    return DamageTypes.getResistance(unit.armor.resistances, damageType)
end

--- Get armor value (flat damage reduction)
-- @param unit table Unit to check
-- @return number Armor value
function DamageSystem:getArmorValue(unit)
    if not unit.armor then
        return 0
    end
    
    return unit.armor.value or 0
end

--- Roll for critical hit with weapon chance + unit class bonus
-- @param weapon table Optional weapon with critChance
-- @param attacker table Optional attacker unit with critBonus
-- @return boolean True if critical hit
function DamageSystem:rollCriticalHit(weapon, attacker)
    local baseCritChance = DamageSystem.BASE_CRITICAL_HIT_CHANCE
    
    -- Add weapon crit chance if available
    if weapon and weapon.critChance then
        baseCritChance = baseCritChance + weapon.critChance
    end
    
    -- Add unit class crit bonus if available
    if attacker and attacker.critBonus then
        baseCritChance = baseCritChance + attacker.critBonus
    end
    
    local roll = math.random()
    local isCrit = roll < baseCritChance
    
    if isCrit then
        print("[DamageSystem] CRITICAL HIT! Roll: " .. string.format("%.3f", roll) .. 
              " < " .. string.format("%.3f", baseCritChance))
    end
    
    return isCrit
end

--- Distribute damage across health/stun/morale/energy pools using damage model
-- @param unit table Target unit
-- @param projectile table Projectile data
-- @param totalDamage number Total damage to distribute
-- @param isCritical boolean Is this a critical hit
-- @return table Damage breakdown
function DamageSystem:distributeDamage(unit, projectile, totalDamage, isCritical)
    -- Get damage model distribution
    local damageModel = projectile.damageModel or "hurt"
    local distribution = DamageModels.getDistribution(damageModel)
    
    -- Calculate damage for each pool based on damage model
    local healthDamage = math.floor(totalDamage * distribution.health)
    local stunDamage = math.floor(totalDamage * distribution.stun)
    local moraleDamage = math.floor(totalDamage * distribution.morale)
    local energyDamage = math.floor(totalDamage * distribution.energy)
    
    print("[DamageSystem] Damage distribution (" .. damageModel .. " model): HP=" .. healthDamage .. 
          ", Stun=" .. stunDamage .. ", Morale=" .. moraleDamage .. ", Energy=" .. energyDamage)
    local healthDamage = math.floor(totalDamage * projectile.healthRatio)
    local stunDamage = math.floor(totalDamage * projectile.stunRatio)
    local moraleDamage = math.floor(totalDamage * projectile.moraleRatio)
    local energyDamage = math.floor(totalDamage * projectile.energyRatio)
    
    print("[DamageSystem] Damage distribution: HP=" .. healthDamage .. 
          ", Stun=" .. stunDamage .. ", Morale=" .. moraleDamage .. ", Energy=" .. energyDamage)
    
    -- Apply damage to pools
    if healthDamage > 0 then
        self:applyHealthDamage(unit, healthDamage)
    end
    
    if stunDamage > 0 then
        self:applyStunDamage(unit, stunDamage)
    end
    
    if moraleDamage > 0 then
        self.moraleSystem:applyMoraleLoss(unit, moraleDamage)
    end
    
    if energyDamage > 0 then
        self:applyEnergyDamage(unit, energyDamage)
    end
    
    -- Apply wound if critical hit
    local woundApplied = false
    if isCritical then
        -- Create wound source info
        local woundSource = {
            weaponId = projectile.weaponId or "unknown",
            attackerId = projectile.sourceId or "unknown",
            damageType = projectile.damageType or "kinetic",
            turn = projectile.turn or 0
        }
        self:applyWound(unit, woundSource)
        woundApplied = true
    end
    
    return {
        totalDamage = totalDamage,
        healthDamage = healthDamage,
        stunDamage = stunDamage,
        moraleDamage = moraleDamage,
        energyDamage = energyDamage,
        critical = isCritical,
        wound = woundApplied
    }
end

--- Apply health damage to unit
-- @param unit table Target unit
-- @param amount number Damage amount
function DamageSystem:applyHealthDamage(unit, amount)
    if not unit.health then
        unit.health = 100  -- Initialize if not set
        unit.maxHealth = 100
    end
    
    unit.health = unit.health - amount
    
    if unit.health < 0 then
        unit.health = 0
    end
    
    print("[DamageSystem] Unit " .. (unit.name or "Unknown") .. " health: " .. 
          unit.health .. "/" .. unit.maxHealth)
end

--- Apply stun damage to unit
-- @param unit table Target unit
-- @param amount number Stun damage amount
function DamageSystem:applyStunDamage(unit, amount)
    if not unit.stun then
        unit.stun = 0
        unit.maxStun = 100
    end
    
    unit.stun = unit.stun + amount
    
    print("[DamageSystem] Unit " .. (unit.name or "Unknown") .. " stun: " .. 
          unit.stun .. "/" .. unit.maxStun)
end

--- Apply energy damage to unit
-- @param unit table Target unit
-- @param amount number Energy damage amount
function DamageSystem:applyEnergyDamage(unit, amount)
    if not unit.energy then
        unit.energy = 100
        unit.maxEnergy = 100
    end
    
    unit.energy = unit.energy - amount
    
    if unit.energy < 0 then
        unit.energy = 0
    end
    
    print("[DamageSystem] Unit " .. (unit.name or "Unknown") .. " energy: " .. 
          unit.energy .. "/" .. unit.maxEnergy)
end

--- Apply wound effect (causes bleeding)
-- @param unit table Target unit
-- @param source table Optional wound source info {weaponId, attackerId, damageType, turn}
function DamageSystem:applyWound(unit, source)
    if not unit.wounds then
        unit.wounds = 0
    end
    
    if not unit.woundList then
        unit.woundList = {}
    end
    
    unit.wounds = unit.wounds + 1
    
    -- Track wound source for medical treatment and UI display
    local woundInfo = {
        id = unit.wounds,  -- Wound number
        turn = (source and source.turn) or 0,
        weaponId = (source and source.weaponId) or "unknown",
        attackerId = (source and source.attackerId) or "unknown",
        damageType = (source and source.damageType) or "kinetic",
        bleedRate = DamageSystem.WOUND_BLEED_DAMAGE,
        stabilized = false
    }
    
    table.insert(unit.woundList, woundInfo)
    
    print(string.format("[DamageSystem] Unit %s now has %d wound(s) - latest from %s (%s damage)",
          unit.name or "Unknown", unit.wounds, woundInfo.weaponId, woundInfo.damageType))
end

--- Process bleeding damage from wounds (called each turn)
-- @param unit table Unit to process
function DamageSystem:processBleedingDamage(unit)
    if not unit.wounds or unit.wounds <= 0 then
        return
    end
    
    -- Calculate total bleed damage from all wounds
    local totalBleedDamage = 0
    local activeWounds = 0
    
    if unit.woundList then
        for _, wound in ipairs(unit.woundList) do
            if not wound.stabilized then
                totalBleedDamage = totalBleedDamage + wound.bleedRate
                activeWounds = activeWounds + 1
            end
        end
    else
        -- Fallback for units without wound tracking
        totalBleedDamage = unit.wounds * DamageSystem.WOUND_BLEED_DAMAGE
        activeWounds = unit.wounds
    end
    
    if totalBleedDamage > 0 then
        print(string.format("[DamageSystem] Unit %s bleeding %d HP from %d active wound(s) (total: %d wounds)",
              unit.name or "Unknown", totalBleedDamage, activeWounds, unit.wounds))
        
        self:applyHealthDamage(unit, totalBleedDamage)
        self:checkVitals(unit)
    end
end

--- Stabilize a wound (stops bleeding)
-- @param unit table Unit with wound
-- @param woundId number Optional specific wound ID, or nil for most recent
-- @return boolean True if wound stabilized
function DamageSystem:stabilizeWound(unit, woundId)
    if not unit.woundList or #unit.woundList == 0 then
        return false
    end
    
    local woundToStabilize = nil
    
    if woundId then
        -- Find specific wound
        for _, wound in ipairs(unit.woundList) do
            if wound.id == woundId then
                woundToStabilize = wound
                break
            end
        end
    else
        -- Stabilize most recent unstabilized wound
        for i = #unit.woundList, 1, -1 do
            if not unit.woundList[i].stabilized then
                woundToStabilize = unit.woundList[i]
                break
            end
        end
    end
    
    if woundToStabilize and not woundToStabilize.stabilized then
        woundToStabilize.stabilized = true
        print(string.format("[DamageSystem] Wound #%d stabilized for unit %s",
              woundToStabilize.id, unit.name or "Unknown"))
        return true
    end
    
    return false
end

--- Check if unit is dead or unconscious
-- @param unit table Unit to check
function DamageSystem:checkVitals(unit)
    -- Check for death
    if unit.health <= 0 then
        unit.isDead = true
        unit.isUnconscious = false
        print("[DamageSystem] Unit " .. (unit.name or "Unknown") .. " has DIED")
        return
    end
    
    -- Check for unconsciousness from stun
    if unit.stun and unit.stun >= unit.maxStun then
        unit.isUnconscious = true
        print("[DamageSystem] Unit " .. (unit.name or "Unknown") .. " is UNCONSCIOUS from stun")
        return
    end
    
    -- Check for unconsciousness from morale
    if self.moraleSystem:isUnconscious(unit) then
        unit.isUnconscious = true
        print("[DamageSystem] Unit " .. (unit.name or "Unknown") .. " is UNCONSCIOUS from morale")
        return
    end
    
    -- Unit is alive and conscious
    unit.isUnconscious = false
end

--- Notify witnesses of a death (for morale loss)
-- @param deceased table Unit that died
-- @param witnesses table Array of witnessing units
function DamageSystem:notifyDeathWitnesses(deceased, witnesses)
    print("[DamageSystem] Processing death witnesses for " .. (deceased.name or "Unknown"))
    
    for _, witness in ipairs(witnesses) do
        if not witness.isDead and not witness.isUnconscious then
            -- Calculate distance
            local dx = witness.x - deceased.x
            local dy = witness.y - deceased.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- Apply morale loss
            local moraleLoss = self.moraleSystem:calculateDeathWitnessMoraleLoss(witness, deceased, distance)
            self.moraleSystem:applyMoraleLoss(witness, moraleLoss)
        end
    end
end

--- Get recent damage log
-- @return table Array of damage events
function DamageSystem:getDamageLog()
    return self.damageLog
end

--- Clear damage log
function DamageSystem:clearDamageLog()
    self.damageLog = {}
end

return DamageSystem
