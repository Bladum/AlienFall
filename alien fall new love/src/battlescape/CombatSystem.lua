--- Combat System
-- Handles deterministic combat resolution with accuracy tables and damage pipeline
--
-- @classmod battlescape.CombatSystem

-- GROK: CombatSystem implements deterministic combat with hit confirmation, damage roll, and armour mitigation
-- GROK: Manages accuracy tables, reactive fire (overwatch), and complex damage calculations
-- GROK: Key methods: resolveAttack(), resolveThrow(), calculateAccuracy()
-- GROK: Integrates with units, items, and environment for comprehensive battle resolution

local class = require 'lib.Middleclass'

--- CombatSystem class
-- @type CombatSystem
CombatSystem = class('CombatSystem')

--- Damage types
-- @field KINETIC Kinetic damage
-- @field ENERGY Energy damage
-- @field EXPLOSIVE Explosive damage
-- @field INCENDIARY Incendiary damage
CombatSystem.static.DAMAGE_TYPES = {
    KINETIC = "kinetic",
    ENERGY = "energy",
    EXPLOSIVE = "explosive",
    INCENDIARY = "incendiary"
}

--- Create a new CombatSystem instance
-- @param battleState Reference to the current battle state
-- @return CombatSystem instance
function CombatSystem:initialize(battleState)
    self.battleState = battleState
    self.combatHistory = {} -- Track all combat events for debugging
    self.accuracyTables = {} -- Loaded accuracy tables
    self.damageTables = {} -- Loaded damage tables
end

--- Resolve an attack from attacker to target
-- @param attacker The attacking unit
-- @param target The target unit
-- @param weapon The weapon being used (optional, uses unit's equipped weapon)
-- @return boolean hit, number damage, table effects
function CombatSystem:resolveAttack(attacker, target, weapon)
    weapon = weapon or attacker:getWeapon()
    if not weapon then
        return false, 0, {error = "No weapon equipped"}
    end

    -- Calculate accuracy
    local accuracy = self:calculateAccuracy(attacker, target, weapon)

    -- Hit confirmation
    local hitRoll = math.random(1, 100)
    local hit = hitRoll <= accuracy

    local damage = 0
    local effects = {}

    if hit then
        -- Calculate damage
        damage, effects = self:calculateDamage(attacker, target, weapon)

        -- Apply damage
        target:takeDamage(damage, weapon:getDamageType())

        -- Apply additional effects
        self:applyCombatEffects(attacker, target, weapon, effects)
    end

    -- Record combat event
    local combatEvent = {
        attacker = attacker,
        target = target,
        weapon = weapon,
        accuracy = accuracy,
        hitRoll = hitRoll,
        hit = hit,
        damage = damage,
        effects = effects,
        turn = self.battleState:getCurrentTurn()
    }
    table.insert(self.combatHistory, combatEvent)

    -- Trigger event
    self.battleState:triggerEvent('battlescape:combat_resolved', combatEvent)

    return hit, damage, effects
end

--- Calculate accuracy for an attack
-- @param attacker The attacking unit
-- @param target The target unit
-- @param weapon The weapon being used
-- @return number Accuracy percentage (0-100)
function CombatSystem:calculateAccuracy(attacker, target, weapon)
    -- Base accuracy from weapon
    local accuracy = weapon:getBaseAccuracy()

    -- Distance modifier
    local distance = self.battleState:getMap():getDistance(attacker:getPosition(), target:getPosition())
    accuracy = accuracy + self:getRangeModifier(weapon, distance)

    -- Stance modifiers
    accuracy = accuracy + self:getStanceModifier(attacker, target)

    -- Movement modifiers
    if attacker:hasMovedThisTurn() then
        accuracy = accuracy - 20 -- Moving reduces accuracy
    end

    -- Suppression modifiers
    if attacker:isSuppressed() then
        accuracy = accuracy - 30
    end

    -- Cover modifiers
    local coverModifier = self:getCoverModifier(attacker:getPosition(), target:getPosition())
    accuracy = accuracy + coverModifier

    -- Environmental modifiers
    local envModifier = self:getEnvironmentalModifier(attacker:getPosition(), target:getPosition())
    accuracy = accuracy + envModifier

    -- Unit skill modifiers
    accuracy = accuracy + attacker:getAccuracyModifier()

    -- Status effect modifiers
    if attacker:hasStatusEffect("panicked") then
        accuracy = accuracy - 25
    elseif attacker:hasStatusEffect("berserk") then
        accuracy = accuracy + 10 -- Reckless but aggressive
    end

    -- Clamp to valid range
    return math.max(5, math.min(95, accuracy))
end

--- Get range modifier for weapon at distance
-- @param weapon The weapon
-- @param distance Distance to target
-- @return number Accuracy modifier
function CombatSystem:getRangeModifier(weapon, distance)
    local rangeTable = weapon:getAccuracyTable()
    if not rangeTable then return 0 end

    -- Find appropriate range band
    for _, band in ipairs(rangeTable) do
        if distance >= band.minRange and distance <= band.maxRange then
            return band.modifier
        end
    end

    -- Beyond maximum range
    local maxBand = rangeTable[#rangeTable]
    if distance > maxBand.maxRange then
        return maxBand.modifier - (distance - maxBand.maxRange) * 5 -- -5% per tile beyond range
    end

    return 0
end

--- Get stance modifier
-- @param attacker The attacking unit
-- @param target The target unit
-- @return number Accuracy modifier
function CombatSystem:getStanceModifier(attacker, target)
    local modifier = 0

    -- Attacker stance
    if attacker:getStance() == "crouch" then
        modifier = modifier - 10 -- Crouching reduces accuracy
    elseif attacker:getStance() == "prone" then
        modifier = modifier - 20 -- Prone significantly reduces accuracy
    end

    -- Target stance
    if target:getStance() == "crouch" then
        modifier = modifier - 15 -- Harder to hit crouching targets
    elseif target:getStance() == "prone" then
        modifier = modifier - 25 -- Very hard to hit prone targets
    end

    return modifier
end

--- Get cover modifier
-- @param attackerPos Attacker position
-- @param targetPos Target position
-- @return number Accuracy modifier
function CombatSystem:getCoverModifier(attackerPos, targetPos)
    -- Check line of fire for cover
    if not self.battleState:getLineOfFire():hasLineOfFire(attackerPos, targetPos) then
        return -50 -- No line of fire
    end

    -- Check for partial cover
    local coverValue = self.battleState:getLineOfFire():getCoverAlongLine(attackerPos, targetPos)
    return -coverValue * 2 -- -2% per point of cover
end

--- Get environmental modifier
-- @param attackerPos Attacker position
-- @param targetPos Target position
-- @return number Accuracy modifier
function CombatSystem:getEnvironmentalModifier(attackerPos, targetPos)
    local modifier = 0

    -- Check for smoke between positions
    local smokeDensity = self.battleState:getEnvironmentSystem():getSmokeDensityBetween(attackerPos, targetPos)
    modifier = modifier - smokeDensity * 10 -- -10% per smoke intensity level

    -- Check for weather effects
    local weather = self.battleState:getEnvironmentSystem():getWeather()
    if weather == "rainy" then
        modifier = modifier - 10
    elseif weather == "foggy" then
        modifier = modifier - 15
    end

    return modifier
end

--- Calculate damage for a successful hit
-- @param attacker The attacking unit
-- @param target The target unit
-- @param weapon The weapon being used
-- @return number damage, table effects
function CombatSystem:calculateDamage(attacker, target, weapon)
    -- Base damage
    local damage = weapon:getBaseDamage()

    -- Damage roll (weapons have damage variance)
    local variance = weapon:getDamageVariance()
    local roll = math.random(-variance, variance)
    damage = damage + roll

    -- Armor mitigation
    local armorValue = target:getArmorValue(weapon:getDamageType())
    damage = damage - armorValue

    -- Critical hits
    local critChance = weapon:getCritChance() + attacker:getCritModifier()
    local isCrit = math.random(1, 100) <= critChance

    if isCrit then
        damage = damage * weapon:getCritMultiplier()
    end

    -- Minimum damage
    damage = math.max(1, damage)

    -- Additional effects
    local effects = {}

    if isCrit then
        effects.critical = true
    end

    -- Weapon-specific effects
    if weapon:getDamageType() == self.DAMAGE_TYPES.INCENDIARY then
        effects.fire = {intensity = 2, duration = 3}
    elseif weapon:getDamageType() == self.DAMAGE_TYPES.EXPLOSIVE then
        effects.stun = {duration = 1}
    end

    -- Status effects
    if weapon:causesBleeding() and math.random(1, 100) <= 30 then
        effects.bleeding = {duration = 3, damage = 1}
    end

    return math.floor(damage), effects
end

--- Apply combat effects to target
-- @param attacker The attacking unit
-- @param target The target unit
-- @param weapon The weapon used
-- @param effects Effects to apply
function CombatSystem:applyCombatEffects(attacker, target, weapon, effects)
    -- Apply environmental effects
    if effects.fire then
        self.battleState:getEnvironmentSystem():applyEffect(
            target:getPosition().x, target:getPosition().y,
            "fire", effects.fire.intensity, effects.fire.duration, weapon:getName()
        )
    end

    -- Apply status effects
    if effects.stun then
        target:setStatusEffect("stunned", true, effects.stun.duration)
    end

    if effects.bleeding then
        target:setStatusEffect("bleeding", true, effects.bleeding.duration)
        target:setBleedingDamage(effects.bleeding.damage)
    end

    -- Morale effects
    local moraleDamage = 0
    if effects.critical then
        moraleDamage = moraleDamage + 10
    end

    if target:getHealth() < target:getMaxHealth() * 0.25 then
        moraleDamage = moraleDamage + 5 -- Low health panic
    end

    if moraleDamage > 0 then
        self.battleState:getMoraleSystem():applyMoraleDamage(target, moraleDamage, "combat_damage")
    end

    -- Suppression effects
    if weapon:getSuppressionValue() > 0 then
        self:applySuppression(target, weapon:getSuppressionValue())
    end
end

--- Apply suppression to a unit
-- @param unit The unit to suppress
-- @param suppressionValue Amount of suppression
function CombatSystem:applySuppression(unit, suppressionValue)
    -- Check if unit resists suppression
    if unit:getTrait("resilient") then
        suppressionValue = suppressionValue * 0.5
    end

    unit:addSuppression(suppressionValue)

    -- Check for suppression break
    if unit:getSuppression() >= 100 then
        unit:setStatusEffect("suppressed", true)
        self.battleState:getMoraleSystem():applyMoraleDamage(unit, 15, "suppression")
    end
end

--- Resolve thrown item/grenade
-- @param attacker The throwing unit
-- @param targetPos Target position
-- @param item The item being thrown
-- @return boolean hit, table effects
function CombatSystem:resolveThrow(attacker, targetPos, item)
    -- Calculate throw accuracy
    local distance = self.battleState:getMap():getDistance(attacker:getPosition(), targetPos)
    local accuracy = self:calculateThrowAccuracy(attacker, distance, item)

    -- Hit confirmation
    local hitRoll = math.random(1, 100)
    local hit = hitRoll <= accuracy

    local effects = {}

    if hit then
        -- Apply throw effects
        effects = self:applyThrowEffects(targetPos, item)

        -- Check for units in blast radius
        local affectedUnits = self:getUnitsInRadius(targetPos, item:getBlastRadius())
        for _, unit in ipairs(affectedUnits) do
            local distance = self.battleState:getMap():getDistance(targetPos, unit:getPosition())
            local damageFalloff = 1.0 - (distance / item:getBlastRadius())
            local damage = math.floor(item:getThrowDamage() * damageFalloff)

            if damage > 0 then
                unit:takeDamage(damage, item:getDamageType())

                -- Apply effects to affected units
                if item:getDamageType() == self.DAMAGE_TYPES.EXPLOSIVE then
                    unit:setStatusEffect("stunned", true, 1)
                elseif item:getDamageType() == self.DAMAGE_TYPES.INCENDIARY then
                    self.battleState:getEnvironmentSystem():applyEffect(
                        unit:getPosition().x, unit:getPosition().y,
                        "fire", 3, 2, item:getName()
                    )
                end
            end
        end
    end

    -- Record throw event
    local throwEvent = {
        attacker = attacker,
        targetPos = targetPos,
        item = item,
        accuracy = accuracy,
        hitRoll = hitRoll,
        hit = hit,
        effects = effects,
        turn = self.battleState:getCurrentTurn()
    }
    table.insert(self.combatHistory, throwEvent)

    -- Trigger event
    self.battleState:triggerEvent('battlescape:throw_resolved', throwEvent)

    return hit, effects
end

--- Calculate throw accuracy
-- @param attacker The throwing unit
-- @param distance Throw distance
-- @param item The item being thrown
-- @return number Accuracy percentage
function CombatSystem:calculateThrowAccuracy(attacker, distance, item)
    -- Base throw accuracy
    local accuracy = 60

    -- Distance modifier
    if distance <= 3 then
        accuracy = accuracy + 20
    elseif distance <= 6 then
        accuracy = accuracy - 10
    elseif distance <= 10 then
        accuracy = accuracy - 30
    else
        accuracy = accuracy - 50
    end

    -- Unit skill modifier
    accuracy = accuracy + attacker:getThrowAccuracyModifier()

    -- Item-specific modifier
    accuracy = accuracy + item:getThrowAccuracyModifier()

    -- Status effects
    if attacker:hasStatusEffect("panicked") then
        accuracy = accuracy - 25
    end

    return math.max(5, math.min(95, accuracy))
end

--- Apply throw effects to target area
-- @param targetPos Target position
-- @param item The thrown item
-- @return table Effects applied
function CombatSystem:applyThrowEffects(targetPos, item)
    local effects = {}

    -- Environmental effects
    if item:getDamageType() == self.DAMAGE_TYPES.INCENDIARY then
        self.battleState:getEnvironmentSystem():applyEffect(
            targetPos.x, targetPos.y, "fire", 4, 4, item:getName()
        )
        effects.fire = true
    elseif item:getDamageType() == self.DAMAGE_TYPES.EXPLOSIVE then
        -- Create crater/destruction
        self.battleState:getEnvironmentSystem():applyTerrainDamage(targetPos.x, targetPos.y, 50)
        effects.destruction = true
    end

    -- Smoke effects
    if item:producesSmoke() then
        self.battleState:getEnvironmentSystem():applyEffect(
            targetPos.x, targetPos.y, "smoke", 5, 6, item:getName()
        )
        effects.smoke = true
    end

    return effects
end

--- Get units within radius of position
-- @param centerPos Center position
-- @param radius Radius to check
-- @return table List of units in radius
function CombatSystem:getUnitsInRadius(centerPos, radius)
    local units = {}

    for _, unit in ipairs(self.battleState:getAllUnits()) do
        local distance = self.battleState:getMap():getDistance(centerPos, unit:getPosition())
        if distance <= radius then
            table.insert(units, unit)
        end
    end

    return units
end

--- Process overwatch reactions
-- @param movingUnit The unit that triggered overwatch
-- @param path The path the unit is moving along
function CombatSystem:processOverwatchReactions(movingUnit, path)
    local overwatchUnits = self.battleState:getUnitsOnOverwatch()

    for _, overwatchUnit in ipairs(overwatchUnits) do
        -- Check if moving unit crosses line of sight/fire
        for _, tile in ipairs(path) do
            if self.battleState:getLineOfSight():hasLineOfSight(overwatchUnit:getPosition(), tile) and
               self.battleState:getLineOfFire():hasLineOfFire(overwatchUnit:getPosition(), tile) then

                -- Trigger overwatch attack
                local hit, damage, effects = self:resolveAttack(overwatchUnit, movingUnit, overwatchUnit:getWeapon())

                -- Overwatch unit spends AP
                overwatchUnit:spendAP(3) -- Overwatch costs 3 AP

                -- Remove overwatch if AP insufficient for another shot
                if overwatchUnit:getAP() < 3 then
                    overwatchUnit:setOverwatch(false)
                end

                break -- Only one overwatch shot per unit per movement
            end
        end
    end
end

--- Get combat history
-- @return table Combat event history
function CombatSystem:getCombatHistory()
    return self.combatHistory
end

--- Clear combat history (for new battle)
function CombatSystem:clearHistory()
    self.combatHistory = {}
end

--- Load accuracy tables from data
function CombatSystem:loadAccuracyTables()
    -- This would load from TOML files
    -- For now, using placeholder data
    self.accuracyTables = {
        pistol = {
            {minRange = 1, maxRange = 5, modifier = 0},
            {minRange = 6, maxRange = 10, modifier = -10},
            {minRange = 11, maxRange = 15, modifier = -25}
        },
        rifle = {
            {minRange = 1, maxRange = 10, modifier = 0},
            {minRange = 11, maxRange = 20, modifier = -5},
            {minRange = 21, maxRange = 30, modifier = -20}
        }
    }
end

--- Load damage tables from data
function CombatSystem:loadDamageTables()
    -- This would load from TOML files
    -- For now, using placeholder data
    self.damageTables = {
        kinetic = {armorMultiplier = 1.0},
        energy = {armorMultiplier = 0.8},
        explosive = {armorMultiplier = 0.5},
        incendiary = {armorMultiplier = 0.3}
    }
end

return CombatSystem
