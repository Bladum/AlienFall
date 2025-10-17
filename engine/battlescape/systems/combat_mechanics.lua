---Combat Mechanics System for Hex Grid Combat
---
---Implements core combat mechanics including weapon firing, damage calculation,
---accuracy, critical hits, armor effects, and area damage.
---
---Features:
---  - Weapon firing and hit calculation
---  - Accuracy based on distance and cover
---  - Armor damage reduction
---  - Critical hit chance
---  - Area damage effects (explosions, grenades)
---  - Status effects (burning, poisoned)
---  - Reaction fire system
---
---Key Exports:
---  - CombatMechanics.new(terrain_system, unit_system)
---  - resolveAttack(attacker, weapon, defender, targetHex, observers)
---  - calculateAccuracy(attacker, defender, distance, cover)
---  - calculateDamage(weapon, roll, armor)
---  - rollCritical(attacker)
---
---Dependencies:
---  - battlescape.systems.terrain: Terrain data
---  - battlescape.systems.line_of_sight: LOS calculations
---
---@module battlescape.systems.combat_mechanics
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local CombatMechanics = {}
CombatMechanics.__index = CombatMechanics

--- Create new combat mechanics system
---@param terrainSystem table Terrain system reference
---@param unitSystem table Unit system reference (optional)
---@return table New CombatMechanics instance
function CombatMechanics.new(terrainSystem, unitSystem)
    local self = setmetatable({}, CombatMechanics)
    
    self.terrainSystem = terrainSystem
    self.unitSystem = unitSystem
    
    -- Weapon accuracy base values
    self.weaponAccuracy = {
        rifle = 75,
        pistol = 50,
        grenade = 60,
        laser = 80,
        plasma = 75,
        shotgun = 40
    }
    
    -- Armor mitigation values (% damage reduction)
    self.armorMitigation = {
        light = 0.15,      -- 15% damage reduction
        medium = 0.25,     -- 25% damage reduction
        heavy = 0.40,      -- 40% damage reduction
        powered = 0.50     -- 50% damage reduction
    }
    
    -- Critical hit chance modifiers
    self.criticalModifiers = {
        headshot = 1.5,      -- 150% of normal damage
        rearAttack = 1.3,    -- 130% of normal damage
        highGround = 1.2     -- 120% of normal damage
    }
    
    print("[CombatMechanics] Initialized combat mechanics system")
    
    return self
end

--- Resolve complete attack sequence
---@param attacker table Attacker unit
---@param weapon table Weapon data
---@param defender table Defender unit
---@param targetHex table Target hex {q, r}
---@param observers table List of observer units (for reaction fire)
---@return table Attack result: {hit, damage, critical, effects}
function CombatMechanics:resolveAttack(attacker, weapon, defender, targetHex, observers)
    observers = observers or {}
    
    local result = {
        attacker = attacker.id,
        defender = defender.id,
        weapon = weapon.id,
        hit = false,
        damage = 0,
        critical = false,
        effects = {},
        logs = {}
    }
    
    -- Calculate distance
    local distance = self:_hexDistance(attacker.hex, targetHex)
    table.insert(result.logs, string.format("Distance: %d hexes", distance))
    
    -- Check range
    if distance > weapon.max_range then
        result.logs[#result.logs] = result.logs[#result.logs] .. " (OUT OF RANGE)"
        return result
    end
    
    -- Calculate accuracy
    local baseAccuracy = self:calculateAccuracy(attacker, defender, distance, defender.cover_value or 0)
    local accuracyRoll = math.random(1, 100)
    
    table.insert(result.logs, string.format("Accuracy roll: %d vs %d", accuracyRoll, baseAccuracy))
    
    result.hit = accuracyRoll <= baseAccuracy
    
    if not result.hit then
        table.insert(result.logs, "MISS")
        return result
    end
    
    table.insert(result.logs, "HIT")
    
    -- Roll for critical
    result.critical = self:rollCritical(attacker, defender, targetHex)
    if result.critical then
        table.insert(result.logs, "CRITICAL HIT")
    end
    
    -- Calculate damage
    local baseDamage = weapon.damage or 20
    local damageRoll = math.random(math.floor(baseDamage * 0.8), math.ceil(baseDamage * 1.2))
    result.damage = self:calculateDamage(weapon, damageRoll, defender.armor)
    
    if result.critical then
        result.damage = math.floor(result.damage * 1.5)
    end
    
    table.insert(result.logs, string.format("Damage: %d HP", result.damage))
    
    -- Apply status effects from weapon
    if weapon.effects then
        for _, effect in ipairs(weapon.effects) do
            table.insert(result.effects, effect)
        end
    end
    
    -- Check for reaction fire from observers
    if #observers > 0 then
        local reactingUnits = self:_checkReactionFire(attacker, targetHex, observers)
        if #reactingUnits > 0 then
            table.insert(result.logs, string.format("%d units can perform reaction fire", #reactingUnits))
            result.reaction_fire_available = reactingUnits
        end
    end
    
    return result
end

--- Calculate accuracy for attack
---@param attacker table Attacker unit
---@param defender table Defender unit
---@param distance number Distance in hexes
---@param coverValue number Cover value (0-100)
---@return number Accuracy percentage (0-100)
function CombatMechanics:calculateAccuracy(attacker, defender, distance, coverValue)
    coverValue = coverValue or 0
    
    -- Base accuracy from weapon
    local baseAccuracy = self.weaponAccuracy[attacker.weapon_type] or 50
    
    -- Attacker skill modifier
    local attackerSkill = (attacker.accuracy or 50) / 50  -- Normalize to 1.0
    
    -- Distance modifier (-1% per hex beyond close range)
    local distanceModifier = 0
    if distance > 3 then
        distanceModifier = -(distance - 3) * 2
    end
    
    -- Cover modifier (-% based on cover value)
    local coverModifier = -coverValue * 0.5
    
    -- Defender movement modifier (if moved recently)
    local movementModifier = (defender.moved_this_turn and -10) or 0
    
    -- Calculate final accuracy
    local accuracy = baseAccuracy * attackerSkill + distanceModifier + coverModifier + movementModifier
    
    return math.max(5, math.min(95, accuracy))  -- Clamp 5-95%
end

--- Calculate damage after armor mitigation
---@param weapon table Weapon data
---@param roll number Damage roll
---@param armorType string Armor type (light/medium/heavy/powered)
---@return number Final damage after armor reduction
function CombatMechanics:calculateDamage(weapon, roll, armorType)
    local armor = armorType or "none"
    local mitigation = self.armorMitigation[armor] or 0
    
    -- Apply armor reduction
    local mitigatedDamage = roll * (1 - mitigation)
    
    -- Minimum 1 damage always gets through
    return math.max(1, math.floor(mitigatedDamage))
end

--- Roll for critical hit
---@param attacker table Attacker unit
---@param defender table Defender unit
---@param targetHex table Target hex
---@return boolean True if critical hit occurs
function CombatMechanics:rollCritical(attacker, defender, targetHex)
    -- Base critical chance from attacker
    local baseCritical = (attacker.critical_chance or 5) / 100
    
    -- Defender is unaware/flanked
    local flankModifier = (defender.facing and self:_isFlank(attacker.hex, targetHex, defender.facing)) and 1.5 or 1.0
    
    -- High ground bonus
    local heightModifier = (attacker.height and defender.height and attacker.height > defender.height) and 1.3 or 1.0
    
    local criticalChance = baseCritical * flankModifier * heightModifier
    
    return math.random() < criticalChance
end

--- PRIVATE: Check which observers can perform reaction fire
function CombatMechanics:_checkReactionFire(attacker, targetHex, observers)
    local reactors = {}
    
    for _, observer in ipairs(observers) do
        -- Can't react against allies
        if observer.faction ~= attacker.faction then
            -- Check if has reaction fire available
            if (observer.reaction_fire_remaining or 0) > 0 then
                -- Check if can see attacker
                local canSee = true  -- Simplified, would check LOS
                
                if canSee then
                    table.insert(reactors, observer)
                end
            end
        end
    end
    
    return reactors
end

--- PRIVATE: Check if attack is from flank
function CombatMechanics:_isFlank(attackerHex, targetHex, defenderFacing)
    -- Simplified: check if attacker is not in front of defender
    local angleToAttacker = self:_getAngle(targetHex, attackerHex)
    local frontAngle = defenderFacing or 0
    
    -- Front arc is ±60 degrees
    local angleDiff = math.abs(angleToAttacker - frontAngle)
    if angleDiff > 180 then
        angleDiff = 360 - angleDiff
    end
    
    return angleDiff > 60
end

--- PRIVATE: Calculate hex distance (simplified)
function CombatMechanics:_hexDistance(hex1, hex2)
    local dx = hex2.q - hex1.q
    local dy = hex2.r - hex1.r
    return (math.abs(dx) + math.abs(dy) + math.abs(-dx - dy)) / 2
end

--- PRIVATE: Get angle from one hex to another
function CombatMechanics:_getAngle(from, to)
    local dx = to.q - from.q
    local dy = to.r - from.r
    return math.atan2(dy, dx) * 180 / math.pi
end

--- Apply area damage (explosions, grenades)
---@param centerHex table Center hex {q, r}
---@param radius number Blast radius in hexes
---@param damage number Damage at center
---@param units table Array of units to check
---@return table Damage results for each affected unit
function CombatMechanics:applyAreaDamage(centerHex, radius, damage, units)
    local results = {}
    
    for _, unit in ipairs(units) do
        local distance = self:_hexDistance(centerHex, unit.hex)
        
        if distance <= radius then
            -- Damage reduces with distance
            local falloff = 1 - (distance / radius)
            local unitDamage = math.floor(damage * falloff)
            
            table.insert(results, {
                unit_id = unit.id,
                damage = unitDamage,
                distance = distance
            })
        end
    end
    
    return results
end

return CombatMechanics
