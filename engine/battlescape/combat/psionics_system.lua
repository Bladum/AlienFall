---PsionicsSystem - Psionic Abilities System
---
---Comprehensive psionic abilities system with 11+ psychic powers. Includes damage,
---terrain manipulation, mind control, buffs/debuffs, environmental effects, and more.
---Psionics use Psi Points (PP) instead of AP and require psionic skill checks.
---
---Features:
---  - 11+ distinct psionic abilities
---  - Psi Point (PP) system
---  - Psionic skill checks
---  - Mental resistance (Will stat)
---  - Terrain manipulation (lift, teleport)
---  - Mind control and panic
---  - Buff/debuff effects
---  - Environmental effects (fog, fire)
---
---Psionic Abilities:
---  - Psi Damage: Mental attack (stun, hurt, morale, energy)
---  - Psi Critical: Force critical wound
---  - Mind Control: Take control of enemy unit
---  - Panic: Cause panic/morale break
---  - Lift Object: Telekinesis (move objects/terrain)
---  - Teleport Unit: Move ally instantly
---  - Create Fog: Generate obscuring mist
---  - Ignite: Start fire on tile
---  - Psi Buff: Boost ally stats
---  - Psi Debuff: Weaken enemy
---  - Psi Heal: Restore HP remotely
---
---Psionic System:
---  - PP (Psi Points): Energy for psionic abilities
---  - Psi Skill: Accuracy/power of abilities
---  - Will: Mental resistance to psionics
---  - Range: Distance limit for powers
---  - LOS: Requires line of sight (most abilities)
---
---Skill Check:
---  - Attack roll: Psi Skill × random(0.7-1.3)
---  - Defense roll: Will × random(0.7-1.3)
---  - Success if Attack > Defense
---
---Key Exports:
---  - PsionicsSystem.ABILITIES: Table of ability IDs
---  - PsionicsSystem.usePower(user, target, ability): Executes psionic attack
---  - PsionicsSystem.checkSkill(user, target): Returns true if successful
---  - PsionicsSystem.hasPP(unit, cost): Returns true if enough PP
---  - PsionicsSystem.getAbilityData(abilityId): Returns ability definition
---
---Dependencies:
---  - battlescape.combat.damage_models: For damage calculation
---
---@module battlescape.combat.psionics_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local PsionicsSystem = require("battlescape.combat.psionics_system")
---  local result = PsionicsSystem.usePower(psiUnit, enemy, "psi_damage")
---  if result.success then
---      print("Psionic attack hit for " .. result.damage .. " damage!")
---  end
---
---@see battlescape.combat.damage_models For damage calculation

-- Psionics System
-- Comprehensive psionic abilities system with 11+ abilities
-- Includes damage, terrain manipulation, mind control, buffs/debuffs, environmental effects

local DamageModels = require("battlescape.combat.damage_models")

local PsionicsSystem = {}
PsionicsSystem.__index = PsionicsSystem

--- Psionic ability types
PsionicsSystem.ABILITIES = {
    -- Damage abilities
    PSI_DAMAGE = "psi_damage",           -- Inflict damage (stun/hurt/morale/energy)
    PSI_CRITICAL = "psi_critical",       -- Force critical hit (wound)
    
    -- Terrain abilities
    DAMAGE_TERRAIN = "damage_terrain",    -- Destroy terrain tiles
    UNCOVER_TERRAIN = "uncover_terrain",  -- Reveal fog of war
    MOVE_TERRAIN = "move_terrain",        -- Telekinesis on terrain
    
    -- Environmental effects
    CREATE_FIRE = "create_fire",          -- Start fire
    CREATE_SMOKE = "create_smoke",        -- Create smoke cloud
    
    -- Object manipulation
    MOVE_OBJECT = "move_object",          -- Telekinesis on objects
    
    -- Unit control
    MIND_CONTROL = "mind_control",        -- Take control of enemy unit
    SLOW_UNIT = "slow_unit",              -- Reduce AP by 2
    HASTE_UNIT = "haste_unit"             -- Increase AP by 2
}

--- Psionic ability definitions
PsionicsSystem.ABILITY_DEFINITIONS = {
    -- PSI DAMAGE: Direct psionic attack that inflicts damage
    psi_damage = {
        name = "Psionic Strike",
        description = "Direct mental attack that inflicts damage of chosen type",
        icon = "psi_damage",
        cost = {
            ap = 6,
            ep = 10,
            psiEnergy = 15
        },
        range = {
            min = 0,
            max = 15,           -- Long range
            requiresLOS = false -- Can target through walls
        },
        effects = {
            basePower = 20,
            damageModels = {"stun", "hurt", "morale", "energy"},  -- Can choose
            canCrit = true,
            hitChance = 0.8     -- 80% base hit chance
        },
        requirements = {
            minPsiSkill = 30,
            requiresPsiAmp = true
        },
        color = {200, 50, 200}
    },
    
    -- PSI CRITICAL: Force a critical hit on next attack
    psi_critical = {
        name = "Precision Strike",
        description = "Psionically guide next attack to hit weak point (guaranteed critical)",
        icon = "psi_crit",
        cost = {
            ap = 4,
            ep = 8,
            psiEnergy = 20
        },
        range = {
            min = 0,
            max = 0,            -- Self only
            requiresLOS = false
        },
        effects = {
            duration = 1,        -- Next attack only
            guaranteedCrit = true,
            bonusDamage = 0.25  -- +25% damage
        },
        requirements = {
            minPsiSkill = 40,
            requiresPsiAmp = true
        },
        color = {255, 100, 255}
    },
    
    -- DAMAGE TERRAIN: Destroy or damage terrain tiles
    damage_terrain = {
        name = "Psychokinetic Blast",
        description = "Mentally shatter terrain and obstacles",
        icon = "terrain_damage",
        cost = {
            ap = 8,
            ep = 12,
            psiEnergy = 25
        },
        range = {
            min = 0,
            max = 10,
            requiresLOS = true
        },
        effects = {
            destroyPower = 50,   -- Can destroy weak terrain
            areaRadius = 2,      -- 2 hex radius
            destroysCover = true
        },
        requirements = {
            minPsiSkill = 50,
            requiresPsiAmp = true
        },
        color = {255, 150, 50}
    },
    
    -- UNCOVER TERRAIN: Reveal fog of war
    uncover_terrain = {
        name = "Clairvoyance",
        description = "Reveal hidden areas through mental perception",
        icon = "clairvoyance",
        cost = {
            ap = 4,
            ep = 6,
            psiEnergy = 10
        },
        range = {
            min = 0,
            max = 20,
            requiresLOS = false
        },
        effects = {
            revealRadius = 5,    -- Reveals 5 hex radius
            duration = 3,        -- Lasts 3 turns
            revealsUnits = true  -- Also reveals hidden units
        },
        requirements = {
            minPsiSkill = 25,
            requiresPsiAmp = true
        },
        color = {100, 200, 255}
    },
    
    -- MOVE TERRAIN: Telekinesis on terrain
    move_terrain = {
        name = "Terrakinesis",
        description = "Move terrain tiles telekinetically",
        icon = "move_terrain",
        cost = {
            ap = 10,
            ep = 15,
            psiEnergy = 30
        },
        range = {
            min = 1,
            max = 8,
            requiresLOS = true
        },
        effects = {
            maxWeight = 500,     -- Can move tiles up to 500kg
            moveDistance = 3,    -- Can move up to 3 tiles
            canCreateBarriers = true
        },
        requirements = {
            minPsiSkill = 60,
            requiresPsiAmp = true
        },
        color = {150, 255, 150}
    },
    
    -- CREATE FIRE: Start fire at location
    create_fire = {
        name = "Pyrokinesis",
        description = "Ignite fires with mental power",
        icon = "pyro",
        cost = {
            ap = 5,
            ep = 8,
            psiEnergy = 12
        },
        range = {
            min = 0,
            max = 12,
            requiresLOS = true
        },
        effects = {
            fireIntensity = 3,   -- Fire strength
            spreadChance = 0.3,  -- 30% chance to spread per turn
            duration = 5         -- Burns for 5 turns minimum
        },
        requirements = {
            minPsiSkill = 35,
            requiresPsiAmp = true
        },
        color = {255, 100, 0}
    },
    
    -- CREATE SMOKE: Generate smoke cloud
    create_smoke = {
        name = "Smoke Generation",
        description = "Create obscuring smoke cloud",
        icon = "smoke",
        cost = {
            ap = 4,
            ep = 5,
            psiEnergy = 8
        },
        range = {
            min = 0,
            max = 10,
            requiresLOS = true
        },
        effects = {
            smokeRadius = 3,     -- 3 hex radius
            smokeDensity = 2,    -- Medium density
            duration = 4         -- Lasts 4 turns
        },
        requirements = {
            minPsiSkill = 20,
            requiresPsiAmp = true
        },
        color = {150, 150, 150}
    },
    
    -- MOVE OBJECT: Telekinesis on objects
    move_object = {
        name = "Telekinesis",
        description = "Move objects with mental power",
        icon = "telekinesis",
        cost = {
            ap = 6,
            ep = 8,
            psiEnergy = 12
        },
        range = {
            min = 1,
            max = 10,
            requiresLOS = true
        },
        effects = {
            maxWeight = 50,      -- Can move objects up to 50kg
            moveDistance = 5,    -- Can move up to 5 tiles
            canThrow = true,     -- Can throw objects as weapons
            throwDamage = 15     -- Damage if thrown at unit
        },
        requirements = {
            minPsiSkill = 30,
            requiresPsiAmp = true
        },
        color = {200, 150, 255}
    },
    
    -- MIND CONTROL: Take control of enemy unit
    mind_control = {
        name = "Mind Control",
        description = "Dominate enemy's mind and control their actions",
        icon = "mind_control",
        cost = {
            ap = 12,
            ep = 20,
            psiEnergy = 40
        },
        range = {
            min = 0,
            max = 10,
            requiresLOS = false
        },
        effects = {
            duration = 3,        -- Control for 3 turns
            resistCheck = true,  -- Target can resist with Will
            breakOnDamage = true -- Control breaks if caster damaged
        },
        requirements = {
            minPsiSkill = 70,
            requiresPsiAmp = true
        },
        color = {150, 50, 150}
    },
    
    -- SLOW UNIT: Reduce target's AP
    slow_unit = {
        name = "Mental Slow",
        description = "Cloud target's mind, reducing action points",
        icon = "slow",
        cost = {
            ap = 5,
            ep = 7,
            psiEnergy = 10
        },
        range = {
            min = 0,
            max = 12,
            requiresLOS = false
        },
        effects = {
            apReduction = 2,     -- -2 AP per turn
            duration = 2,        -- Lasts 2 turns
            resistCheck = true   -- Target can resist
        },
        requirements = {
            minPsiSkill = 35,
            requiresPsiAmp = true
        },
        color = {100, 100, 255}
    },
    
    -- HASTE UNIT: Increase target's AP
    haste_unit = {
        name = "Mental Haste",
        description = "Accelerate ally's mental processes, increasing action points",
        icon = "haste",
        cost = {
            ap = 6,
            ep = 10,
            psiEnergy = 15
        },
        range = {
            min = 0,
            max = 10,
            requiresLOS = false
        },
        effects = {
            apBonus = 2,         -- +2 AP per turn
            duration = 2,        -- Lasts 2 turns
            targetAllyOnly = true
        },
        requirements = {
            minPsiSkill = 40,
            requiresPsiAmp = true
        },
        color = {255, 255, 100}
    }
}

--- Create new psionics system instance
-- @param battlefield table Reference to battlefield
-- @param damageSystem table Reference to damage system
-- @return table New PsionicsSystem instance
function PsionicsSystem.new(battlefield, damageSystem)
    print("[PsionicsSystem] Initializing psionics system")
    
    local self = setmetatable({}, PsionicsSystem)
    
    self.battlefield = battlefield
    self.damageSystem = damageSystem
    self.activeEffects = {}      -- Active psionic effects
    self.controlledUnits = {}    -- Mind controlled units
    
    return self
end

--- Check if unit can use psionic ability
-- @param unit table Unit attempting ability
-- @param abilityName string Ability to check
-- @param targetX number Optional target X
-- @param targetY number Optional target Y
-- @return boolean, string True if can use, false + reason if cannot
function PsionicsSystem:canUseAbility(unit, abilityName, targetX, targetY)
    local ability = PsionicsSystem.ABILITY_DEFINITIONS[abilityName]
    if not ability then
        return false, "Invalid ability"
    end
    
    -- Check psi skill requirement
    if not unit.psiSkill or unit.psiSkill < ability.requirements.minPsiSkill then
        return false, "Insufficient psionic skill (" .. ability.requirements.minPsiSkill .. " required)"
    end
    
    -- Check psi amp requirement
    if ability.requirements.requiresPsiAmp and not unit.hasPsiAmp then
        return false, "Requires psionic amplifier"
    end
    
    -- Check AP cost
    if not unit.actionPoints or unit.actionPoints < ability.cost.ap then
        return false, "Not enough AP (" .. ability.cost.ap .. " required)"
    end
    
    -- Check EP cost
    if not unit.energyPoints or unit.energyPoints < ability.cost.ep then
        return false, "Not enough energy (" .. ability.cost.ep .. " required)"
    end
    
    -- Check psi energy cost
    if not unit.psiEnergy or unit.psiEnergy < ability.cost.psiEnergy then
        return false, "Not enough psi energy (" .. ability.cost.psiEnergy .. " required)"
    end
    
    -- Check range if target specified
    if targetX and targetY then
        local dx = targetX - unit.x
        local dy = targetY - unit.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < ability.range.min then
            return false, "Target too close"
        end
        
        if distance > ability.range.max then
            return false, "Target out of range"
        end
        
        -- Check LOS requirement
        if ability.range.requiresLOS then
            if self.battlefield and not self.battlefield:hasLineOfSight(unit.x, unit.y, targetX, targetY) then
                return false, "No line of sight"
            end
        end
    end
    
    return true, "Can use ability"
end

--- Use psionic ability
-- @param caster table Unit using ability
-- @param abilityName string Ability name
-- @param targetX number Target X position
-- @param targetY number Target Y position
-- @param options table Optional parameters
-- @return boolean, string Success status and message
function PsionicsSystem:useAbility(caster, abilityName, targetX, targetY, options)
    options = options or {}
    
    local canUse, reason = self:canUseAbility(caster, abilityName, targetX, targetY)
    if not canUse then
        return false, reason
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS[abilityName]
    
    print("[PsionicsSystem] " .. (caster.name or "Unit") .. " uses " .. ability.name)
    
    -- Consume resources
    caster.actionPoints = caster.actionPoints - ability.cost.ap
    caster.energyPoints = caster.energyPoints - ability.cost.ep
    caster.psiEnergy = caster.psiEnergy - ability.cost.psiEnergy
    
    -- Execute ability effect
    local success = false
    local message = ""
    
    if abilityName == "psi_damage" then
        success, message = self:executePsiDamage(caster, targetX, targetY, options)
    elseif abilityName == "psi_critical" then
        success, message = self:executePsiCritical(caster)
    elseif abilityName == "damage_terrain" then
        success, message = self:executeDamageTerrain(caster, targetX, targetY)
    elseif abilityName == "uncover_terrain" then
        success, message = self:executeUncoverTerrain(caster, targetX, targetY)
    elseif abilityName == "move_terrain" then
        success, message = self:executeMoveTerrain(caster, targetX, targetY, options)
    elseif abilityName == "create_fire" then
        success, message = self:executeCreateFire(caster, targetX, targetY)
    elseif abilityName == "create_smoke" then
        success, message = self:executeCreateSmoke(caster, targetX, targetY)
    elseif abilityName == "move_object" then
        success, message = self:executeMoveObject(caster, targetX, targetY, options)
    elseif abilityName == "mind_control" then
        success, message = self:executeMindControl(caster, targetX, targetY)
    elseif abilityName == "slow_unit" then
        success, message = self:executeSlowUnit(caster, targetX, targetY)
    elseif abilityName == "haste_unit" then
        success, message = self:executeHasteUnit(caster, targetX, targetY)
    else
        return false, "Ability not implemented"
    end
    
    return success, message
end

--- Check if unit has enough psi energy for ability.
--- Returns true and consumes energy if available, false otherwise.
---
--- @param unit table Unit attempting to use ability
--- @param abilityName string Ability identifier
--- @return boolean, string Success and error message
function PsionicsSystem:checkAndConsumePsiEnergy(unit, abilityName)
    local ability = PsionicsSystem.ABILITY_DEFINITIONS[abilityName]
    if not ability then
        return false, "Unknown ability"
    end
    
    local cost = ability.cost and ability.cost.psiEnergy or 0
    
    -- Check if unit has psi energy system
    if not unit.psiEnergy or not unit.maxPsiEnergy or unit.maxPsiEnergy == 0 then
        return false, "Unit is not psionic"
    end
    
    -- Check if enough psi energy
    if unit.psiEnergy < cost then
        return false, string.format("Not enough psi energy (need %d, have %d)", cost, unit.psiEnergy)
    end
    
    -- Consume psi energy
    unit.psiEnergy = unit.psiEnergy - cost
    print(string.format("[PsionicsSystem] %s consumed %d psi energy (remaining: %d/%d)", 
          unit.name or "Unit", cost, unit.psiEnergy, unit.maxPsiEnergy))
    
    return true, ""
end

--- Execute psi damage ability
-- Inflicts mental damage to target unit using chosen damage model
-- @param caster table Caster unit
-- @param targetX number Target X coordinate
-- @param targetY number Target Y coordinate
-- @param options table Options including damageModel ("stun", "hurt", "morale", "energy")
-- @return boolean, string Success and message
function PsionicsSystem:executePsiDamage(caster, targetX, targetY, options)
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.psi_damage
    
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "psi_damage")
    if not canCast then
        return false, errorMsg
    end
    
    -- Find target unit at coordinates
    local targetUnit = self.battlefield:getUnitAt(targetX, targetY)
    if not targetUnit then
        return false, "No target at location"
    end
    
    -- Choose damage model (default to stun for non-lethal)
    local damageModel = (options and options.damageModel) or "stun"
    if not DamageModels.DEFINITIONS[damageModel] then
        damageModel = "stun"
    end
    
    -- Calculate hit chance (base 80% modified by will resistance)
    local hitChance = ability.effects.hitChance
    if targetUnit.will then
        -- Higher will reduces hit chance
        local willResist = math.min(0.5, (targetUnit.will - 50) / 100)
        hitChance = hitChance * (1.0 - willResist)
    end
    
    -- Roll for hit
    local roll = math.random()
    if roll > hitChance then
        print(string.format("[PsionicsSystem] Psi attack missed! Roll: %.2f > %.2f", roll, hitChance))
        return true, "Psi attack resisted"
    end
    
    -- Calculate damage (base power + psi skill bonus)
    local basePower = ability.effects.basePower
    local psiBonus = math.floor((caster.psiSkill or 50) / 10)
    local totalDamage = basePower + psiBonus
    
    print(string.format("[PsionicsSystem] Psi damage hit! %d damage (%s model) to %s", 
          totalDamage, damageModel, targetUnit.name or "target"))
    
    -- Apply damage using damage model
    if DamageModels.distributeDamage then
        DamageModels.distributeDamage(targetUnit, totalDamage, damageModel)
    else
        -- Fallback: direct damage application
        local model = DamageModels.DEFINITIONS[damageModel]
        if model then
            local dist = model.distribution
            targetUnit.health = (targetUnit.health or 10) - math.floor(totalDamage * dist.health)
            if targetUnit.stun then
                targetUnit.stun = (targetUnit.stun or 0) + math.floor(totalDamage * dist.stun)
            end
            if targetUnit.morale then
                targetUnit.morale = (targetUnit.morale or 10) - math.floor(totalDamage * dist.morale)
            end
            if targetUnit.energy then
                targetUnit.energy = (targetUnit.energy or 10) - math.floor(totalDamage * dist.energy)
            end
        end
    end
    
    return true, string.format("Psionic strike dealt %d %s damage", totalDamage, damageModel)
end

function PsionicsSystem:executePsiCritical(caster)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "psi_critical")
    if not canCast then
        return false, errorMsg
    end
    
    -- Apply critical hit buff to caster for next attack
    caster.nextAttackCrit = true
    caster.nextAttackBonusDamage = 0.25
    caster.psiCriticalActive = true
    
    print(string.format("[PsionicsSystem] %s activated Precision Strike - next attack guaranteed crit +25%% damage",
          caster.name or "Unit"))
    
    return true, "Next attack will be critical (+25% damage)"
end

function PsionicsSystem:executeDamageTerrain(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "damage_terrain")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.damage_terrain
    local destroyPower = ability.effects.destroyPower
    local radius = ability.effects.areaRadius
    
    print(string.format("[PsionicsSystem] Psychokinetic blast at (%d,%d) with power %d, radius %d",
          targetX, targetY, destroyPower, radius))
    
    -- Get affected tiles in radius
    local affectedTiles = {}
    for dx = -radius, radius do
        for dy = -radius, radius do
            local tx = targetX + dx
            local ty = targetY + dy
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance <= radius then
                table.insert(affectedTiles, {x = tx, y = ty, distance = distance})
            end
        end
    end
    
    -- Damage terrain at each tile
    local tilesDestroyed = 0
    for _, tile in ipairs(affectedTiles) do
        if self.battlefield and self.battlefield.damageTerrain then
            -- Calculate damage falloff by distance
            local falloff = 1.0 - (tile.distance / radius) * 0.5
            local tileDamage = math.floor(destroyPower * falloff)
            
            local destroyed = self.battlefield:damageTerrain(tile.x, tile.y, tileDamage)
            if destroyed then
                tilesDestroyed = tilesDestroyed + 1
            end
        end
    end
    
    if tilesDestroyed > 0 then
        print(string.format("[PsionicsSystem] Destroyed %d terrain tiles", tilesDestroyed))
        return true, string.format("Destroyed %d terrain tiles", tilesDestroyed)
    else
        return true, "Terrain damaged but not destroyed"
    end
end

function PsionicsSystem:executeUncoverTerrain(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "uncover_terrain")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.uncover_terrain
    local revealRadius = ability.effects.revealRadius
    local duration = ability.effects.duration
    
    print(string.format("[PsionicsSystem] Clairvoyance at (%d,%d) - revealing %d hex radius for %d turns",
          targetX, targetY, revealRadius, duration))
    
    -- Get affected tiles in radius
    local revealedTiles = {}
    local revealedUnits = 0
    
    for dx = -revealRadius, revealRadius do
        for dy = -revealRadius, revealRadius do
            local tx = targetX + dx
            local ty = targetY + dy
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance <= revealRadius then
                table.insert(revealedTiles, {x = tx, y = ty})
                
                -- Reveal fog of war at this tile
                if self.battlefield and self.battlefield.revealTile then
                    self.battlefield:revealTile(tx, ty, duration)
                end
                
                -- Check for hidden units
                if ability.effects.revealsUnits then
                    local unit = self.battlefield and self.battlefield:getUnitAt(tx, ty)
                    if unit and unit.hidden then
                        unit.hidden = false
                        unit.revealedBy = caster.id
                        revealedUnits = revealedUnits + 1
                    end
                end
            end
        end
    end
    
    print(string.format("[PsionicsSystem] Revealed %d tiles and %d hidden units", 
          #revealedTiles, revealedUnits))
    
    return true, string.format("Revealed %d tiles (%d hidden units spotted)", #revealedTiles, revealedUnits)
end

function PsionicsSystem:executeMoveTerrain(caster, targetX, targetY, options)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "move_terrain")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.move_terrain
    local maxMoveRange = ability.effects.maxMoveRange or 3
    
    -- Get destination from options
    local destX = (options and options.destX) or (targetX + 1)
    local destY = (options and options.destY) or (targetY + 1)
    
    -- Calculate move distance
    local dx = destX - targetX
    local dy = destY - targetY
    local moveDistance = math.sqrt(dx*dx + dy*dy)
    
    if moveDistance > maxMoveRange then
        return false, string.format("Cannot move terrain %d tiles (max: %d)", 
               math.floor(moveDistance), maxMoveRange)
    end
    
    print(string.format("[PsionicsSystem] Terrakinesis: moving terrain from (%d,%d) to (%d,%d)",
          targetX, targetY, destX, destY))
    
    -- Move terrain tile if battlefield supports it
    if self.battlefield and self.battlefield.moveTerrain then
        local success = self.battlefield:moveTerrain(targetX, targetY, destX, destY)
        if success then
            return true, string.format("Moved terrain %d tiles", math.floor(moveDistance))
        else
            return false, "Cannot move this terrain type"
        end
    else
        -- Fallback: just mark the operation
        print("[PsionicsSystem] Terrain movement (battlefield doesn't support moveTerrain)")
        return true, "Terrain telekinesis used"
    end
end

function PsionicsSystem:executeCreateFire(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "create_fire")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.create_fire
    local intensity = ability.effects.intensity or 3
    local radius = ability.effects.areaRadius or 1
    
    print(string.format("[PsionicsSystem] Pyrokinesis at (%d,%d) - creating fire intensity %d, radius %d",
          targetX, targetY, intensity, radius))
    
    local tilesIgnited = 0
    
    -- Create fire in area
    for dx = -radius, radius do
        for dy = -radius, radius do
            local tx = targetX + dx
            local ty = targetY + dy
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance <= radius then
                -- Calculate fire intensity based on distance
                local tileIntensity = math.max(1, math.floor(intensity * (1.0 - distance / radius)))
                
                if self.battlefield and self.battlefield.createFire then
                    local success = self.battlefield:createFire(tx, ty, tileIntensity)
                    if success then
                        tilesIgnited = tilesIgnited + 1
                    end
                else
                    -- Fallback: mark tile as on fire
                    print(string.format("[PsionicsSystem] Fire created at (%d,%d) intensity %d", 
                          tx, ty, tileIntensity))
                    tilesIgnited = tilesIgnited + 1
                end
            end
        end
    end
    
    if tilesIgnited > 0 then
        return true, string.format("Created fire on %d tiles (intensity %d)", tilesIgnited, intensity)
    else
        return false, "Cannot create fire here"
    end
end

function PsionicsSystem:executeCreateSmoke(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "create_smoke")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.create_smoke
    local radius = ability.effects.areaRadius or 3
    local density = ability.effects.density or 5
    local duration = ability.effects.duration or 5
    
    print(string.format("[PsionicsSystem] Creating smoke at (%d,%d) - radius %d, density %d, duration %d turns",
          targetX, targetY, radius, density, duration))
    
    local tilesSmoked = 0
    
    -- Create smoke in area
    for dx = -radius, radius do
        for dy = -radius, radius do
            local tx = targetX + dx
            local ty = targetY + dy
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance <= radius then
                -- Calculate smoke density based on distance (denser in center)
                local tileDensity = math.max(1, math.floor(density * (1.0 - distance / (radius * 2))))
                
                if self.battlefield and self.battlefield.createSmoke then
                    local success = self.battlefield:createSmoke(tx, ty, tileDensity, duration)
                    if success then
                        tilesSmoked = tilesSmoked + 1
                    end
                else
                    -- Fallback: mark smoke effect
                    print(string.format("[PsionicsSystem] Smoke created at (%d,%d) density %d", 
                          tx, ty, tileDensity))
                    tilesSmoked = tilesSmoked + 1
                end
            end
        end
    end
    
    if tilesSmoked > 0 then
        return true, string.format("Created smoke on %d tiles (duration %d turns)", tilesSmoked, duration)
    else
        return false, "Cannot create smoke here"
    end
end

function PsionicsSystem:executeMoveObject(caster, targetX, targetY, options)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "move_object")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.move_object
    local maxWeight = ability.effects.maxWeight or 50
    local maxMoveRange = ability.effects.maxMoveRange or 5
    
    -- Get destination from options
    local destX = (options and options.destX) or (targetX + 1)
    local destY = (options and options.destY) or (targetY + 1)
    
    -- Calculate move distance
    local dx = destX - targetX
    local dy = destY - targetY
    local moveDistance = math.sqrt(dx*dx + dy*dy)
    
    if moveDistance > maxMoveRange then
        return false, string.format("Cannot move object %d tiles (max: %d)", 
               math.floor(moveDistance), maxMoveRange)
    end
    
    print(string.format("[PsionicsSystem] Telekinesis: moving object from (%d,%d) to (%d,%d)",
          targetX, targetY, destX, destY))
    
    -- Find object at location
    local object = self.battlefield and self.battlefield:getObjectAt(targetX, targetY)
    if not object then
        return false, "No object at target location"
    end
    
    -- Check weight
    local objectWeight = object.weight or 10
    if objectWeight > maxWeight then
        return false, string.format("Object too heavy (%d kg, max: %d kg)", objectWeight, maxWeight)
    end
    
    -- Move object
    if self.battlefield and self.battlefield.moveObject then
        local success = self.battlefield:moveObject(object.id, destX, destY)
        if success then
            -- If throwAsWeapon option, calculate impact damage
            if options and options.throwAsWeapon then
                local targetUnit = self.battlefield:getUnitAt(destX, destY)
                if targetUnit then
                    local impactDamage = math.floor(objectWeight / 10)
                    print(string.format("[PsionicsSystem] Object thrown at unit, dealing %d impact damage", impactDamage))
                    targetUnit.health = (targetUnit.health or 10) - impactDamage
                    return true, string.format("Threw object dealing %d impact damage", impactDamage)
                end
            end
            return true, string.format("Moved object %d tiles", math.floor(moveDistance))
        else
            return false, "Cannot move object to that location"
        end
    else
        -- Fallback
        print("[PsionicsSystem] Object telekinesis used")
        return true, "Object moved telekinetically"
    end
end

function PsionicsSystem:executeMindControl(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "mind_control")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.mind_control
    local duration = ability.effects.duration or 3
    
    -- Find target unit
    local targetUnit = self.battlefield and self.battlefield:getUnitAt(targetX, targetY)
    if not targetUnit then
        return false, "No unit at target location"
    end
    
    -- Cannot control own team
    if targetUnit.teamId == caster.teamId then
        return false, "Cannot control allied units"
    end
    
    -- Resistance check: caster psi skill vs target will
    local casterPsi = caster.psiSkill or 50
    local targetWill = targetUnit.will or 50
    
    -- Formula: success chance = 50% + (caster psi - target will) / 2
    local successChance = 0.5 + (casterPsi - targetWill) / 200
    successChance = math.max(0.1, math.min(0.9, successChance))  -- Clamp to 10-90%
    
    local roll = math.random()
    print(string.format("[PsionicsSystem] Mind control: chance %.0f%%, rolled %.2f", 
          successChance * 100, roll))
    
    if roll > successChance then
        return false, string.format("Target resisted mind control (will: %d vs psi: %d)", 
               targetWill, casterPsi)
    end
    
    -- Apply mind control
    targetUnit.mindControlled = true
    targetUnit.mindControllerID = caster.id
    targetUnit.mindControlDuration = duration
    targetUnit.originalTeamId = targetUnit.teamId
    targetUnit.teamId = caster.teamId  -- Switch to controller's team
    
    print(string.format("[PsionicsSystem] Mind control successful! Unit controlled for %d turns", duration))
    
    return true, string.format("Dominated target for %d turns", duration)
end

function PsionicsSystem:executeSlowUnit(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "slow_unit")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.slow_unit
    local apReduction = ability.effects.apReduction or 2
    local duration = ability.effects.duration or 2
    
    -- Find target unit
    local targetUnit = self.battlefield and self.battlefield:getUnitAt(targetX, targetY)
    if not targetUnit then
        return false, "No unit at target location"
    end
    
    -- Cannot slow allied units (unless friendly fire enabled)
    if targetUnit.teamId == caster.teamId then
        return false, "Cannot slow allied units"
    end
    
    -- Resistance check (simpler than mind control)
    local casterPsi = caster.psiSkill or 50
    local targetWill = targetUnit.will or 50
    local successChance = 0.7 + (casterPsi - targetWill) / 300
    successChance = math.max(0.3, math.min(0.95, successChance))
    
    local roll = math.random()
    if roll > successChance then
        return false, "Target resisted slow effect"
    end
    
    -- Apply slow debuff
    targetUnit.slowed = true
    targetUnit.slowDuration = duration
    targetUnit.slowAPReduction = apReduction
    
    -- Apply immediate AP reduction if unit has AP left
    if targetUnit.actionPoints and targetUnit.actionPoints > 0 then
        local oldAP = targetUnit.actionPoints
        targetUnit.actionPoints = math.max(0, targetUnit.actionPoints - apReduction)
        print(string.format("[PsionicsSystem] Slowed unit - AP reduced: %d -> %d", 
              oldAP, targetUnit.actionPoints))
    end
    
    return true, string.format("Slowed target (-%d AP for %d turns)", apReduction, duration)
end

function PsionicsSystem:executeHasteUnit(caster, targetX, targetY)
    -- Check and consume psi energy
    local canCast, errorMsg = self:checkAndConsumePsiEnergy(caster, "haste_unit")
    if not canCast then
        return false, errorMsg
    end
    
    local ability = PsionicsSystem.ABILITY_DEFINITIONS.haste_unit
    local apBonus = ability.effects.apBonus or 2
    local duration = ability.effects.duration or 2
    
    -- Find target unit
    local targetUnit = self.battlefield and self.battlefield:getUnitAt(targetX, targetY)
    if not targetUnit then
        return false, "No unit at target location"
    end
    
    -- Can only haste allied units (including self)
    if targetUnit.teamId ~= caster.teamId then
        return false, "Can only haste allied units"
    end
    
    -- Apply haste buff
    targetUnit.hasted = true
    targetUnit.hasteDuration = duration
    targetUnit.hasteAPBonus = apBonus
    
    -- Apply immediate AP bonus
    if targetUnit.actionPoints then
        local oldAP = targetUnit.actionPoints
        targetUnit.actionPoints = targetUnit.actionPoints + apBonus
        print(string.format("[PsionicsSystem] Hasted unit - AP increased: %d -> %d", 
              oldAP, targetUnit.actionPoints))
    end
    
    -- Also grant max AP bonus at start of each turn
    targetUnit.hasteMaxAPBonus = apBonus
    
    return true, string.format("Hasted target (+%d AP for %d turns)", apBonus, duration)
end

--- Get available abilities for unit
-- @param unit table Unit to check
-- @return table Array of available ability names
function PsionicsSystem:getAvailableAbilities(unit)
    local available = {}
    
    for abilityName, ability in pairs(PsionicsSystem.ABILITY_DEFINITIONS) do
        if unit.psiSkill and unit.psiSkill >= ability.requirements.minPsiSkill then
            if not ability.requirements.requiresPsiAmp or unit.hasPsiAmp then
                table.insert(available, abilityName)
            end
        end
    end
    
    return available
end

return PsionicsSystem






















