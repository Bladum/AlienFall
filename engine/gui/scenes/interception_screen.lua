---Interception Screen - Craft Combat
---
---Turn-based card battle system for craft-vs-UFO combat. Tactical engagements
---occur across 3 altitude layers (air, land/water, underground/underwater) with
---card-based action selection and positioning mechanics.
---
---Combat Mechanics:
---  - Turn-based with initiative system
---  - 3 altitude layers: AIR, LAND/WATER, UNDERGROUND/UNDERWATER
---  - Card-based actions (attack, evade, change altitude, retreat)
---  - Weapon systems (missiles, cannons, lasers)
---  - Damage and armor mechanics
---  - Retreat and capture conditions
---
---Altitude Layers:
---  - AIR: High-speed craft combat, missiles effective
---  - LAND/WATER: Surface engagements, cannon combat
---  - UNDERGROUND/UNDERWATER: Stealthy approach, limited visibility
---
---Unit Status:
---  - ACTIVE: Ready for combat
---  - DAMAGED: Reduced capabilities
---  - DESTROYED: Eliminated from battle
---  - RETREATED: Fled from combat
---
---Key Exports:
---  - InterceptionScreen.new(craftData, ufoData): Creates interception battle
---  - takeTurn(unit, action): Executes unit action
---  - changeAltitude(unit, layer): Moves unit between layers
---  - retreat(unit): Attempts to flee combat
---  - checkVictory(): Evaluates battle outcome
---
---Dependencies:
---  - shared.crafts.craft: Player craft definitions
---  - lore.missions.mission: UFO definitions and behavior
---  - battlescape.combat.damage_system: Damage calculation
---  - widgets.init: Interception UI widgets
---
---@module scenes.interception_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local InterceptionScreen = require("scenes.interception_screen")
---  local battle = InterceptionScreen.new(playerCraft, ufo)
---  battle:takeTurn(playerCraft, "attack_missiles")
---  if battle:checkVictory() then
---    print("UFO destroyed!")
---  end
---
---@see shared.crafts.craft For craft definitions
---@see scenes.geoscape_screen For launching interceptions
---@see scenes.battlescape_screen For crash site missions

local InterceptionScreen = {}
InterceptionScreen.__index = InterceptionScreen

--- Altitude layers
InterceptionScreen.ALTITUDE = {
    AIR = "air",
    LAND = "land",
    UNDERGROUND = "underground"
}

--- Unit status
InterceptionScreen.STATUS = {
    ACTIVE = "active",
    DAMAGED = "damaged",
    DESTROYED = "destroyed",
    RETREATED = "retreated"
}

--- Create new interception screen
-- @param missionData table Mission information
-- @return table New InterceptionScreen instance
function InterceptionScreen.new(missionData)
    local self = setmetatable({}, InterceptionScreen)
    
    self.missionData = missionData
    self.playerUnits = {}        -- Player forces (crafts + bases)
    self.enemyUnits = {}         -- Enemy forces (UFOs + sites)
    self.turn = 1
    self.currentPhase = "player" -- "player" or "enemy"
    self.combatLog = {}
    self.outcome = nil           -- "victory", "defeat", "retreat"
    
    print("[InterceptionScreen] Initialized interception screen for mission: " .. missionData.id)
    
    return self
end

--- Add player unit (craft or base facility)
-- @param unitData table Unit configuration
function InterceptionScreen:addPlayerUnit(unitData)
    local unit = {
        id = unitData.id,
        name = unitData.name,
        type = unitData.type,       -- "craft" or "base_facility"
        side = "player",
        altitude = unitData.altitude or InterceptionScreen.ALTITUDE.AIR,
        
        -- Combat stats
        health = unitData.health or 100,
        maxHealth = unitData.maxHealth or 100,
        armor = unitData.armor or 0,
        
        -- Action economy
        ap = 4,                     -- Action Points per turn
        maxAP = 4,
        energy = unitData.maxEnergy or 100,
        maxEnergy = unitData.maxEnergy or 100,
        
        -- Weapons
        weapons = unitData.weapons or {},
        
        -- Status
        status = InterceptionScreen.STATUS.ACTIVE
    }
    
    table.insert(self.playerUnits, unit)
    
    print(string.format("[InterceptionScreen] Added player unit: %s (%s) at %s altitude",
          unit.name, unit.type, unit.altitude))
end

--- Add enemy unit (UFO or alien site)
-- @param unitData table Unit configuration
function InterceptionScreen:addEnemyUnit(unitData)
    local unit = {
        id = unitData.id,
        name = unitData.name,
        type = unitData.type,       -- "ufo", "alien_site", "alien_base"
        side = "enemy",
        altitude = unitData.altitude or InterceptionScreen.ALTITUDE.AIR,
        
        -- Combat stats
        health = unitData.health or 100,
        maxHealth = unitData.maxHealth or 100,
        armor = unitData.armor or 0,
        
        -- Action economy
        ap = 4,
        maxAP = 4,
        energy = unitData.maxEnergy or 100,
        maxEnergy = unitData.maxEnergy or 100,
        
        -- Weapons
        weapons = unitData.weapons or {},
        
        -- Status
        status = InterceptionScreen.STATUS.ACTIVE
    }
    
    table.insert(self.enemyUnits, unit)
    
    print(string.format("[InterceptionScreen] Added enemy unit: %s (%s) at %s altitude",
          unit.name, unit.type, unit.altitude))
end

--- Start new turn
function InterceptionScreen:startTurn()
    self.turn = self.turn + 1
    self.currentPhase = "player"
    
    -- Reset AP and energy for all units
    for _, unit in ipairs(self.playerUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE then
            unit.ap = unit.maxAP
            unit.energy = math.min(unit.maxEnergy, unit.energy + 10) -- Recover 10 energy per turn
        end
    end
    
    for _, unit in ipairs(self.enemyUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE then
            unit.ap = unit.maxAP
            unit.energy = math.min(unit.maxEnergy, unit.energy + 10)
        end
    end
    
    self:log(string.format("=== TURN %d START ===", self.turn))
    print(string.format("[InterceptionScreen] Turn %d started", self.turn))
end

--- Execute weapon attack
-- @param attacker table Attacking unit
-- @param target table Target unit
-- @param weaponIndex number Weapon index (1-based)
-- @return boolean True if attack executed
function InterceptionScreen:attack(attacker, target, weaponIndex)
    local weapon = attacker.weapons[weaponIndex]
    
    if not weapon then
        self:log("ERROR: Invalid weapon")
        return false
    end
    
    -- Check AP cost
    if attacker.ap < weapon.apCost then
        self:log(string.format("%s has insufficient AP (need: %d, have: %d)",
                 attacker.name, weapon.apCost, attacker.ap))
        return false
    end
    
    -- Check energy cost
    if attacker.energy < weapon.energyCost then
        self:log(string.format("%s has insufficient energy (need: %d, have: %d)",
                 attacker.name, weapon.energyCost, attacker.energy))
        return false
    end
    
    -- Check cooldown
    if weapon.cooldownRemaining and weapon.cooldownRemaining > 0 then
        self:log(string.format("%s is on cooldown (%d turns)",
                 weapon.name, weapon.cooldownRemaining))
        return false
    end
    
    -- Check range and altitude compatibility
    if not self:canTarget(attacker, target, weapon) then
        self:log("Cannot target unit (range or altitude restriction)")
        return false
    end
    
    -- Consume AP and energy
    attacker.ap = attacker.ap - weapon.apCost
    attacker.energy = attacker.energy - weapon.energyCost
    
    -- Set cooldown
    if weapon.cooldown then
        weapon.cooldownRemaining = weapon.cooldown
    end
    
    -- Calculate damage
    local baseDamage = weapon.damage
    local actualDamage = math.max(0, baseDamage - target.armor)
    target.health = math.max(0, target.health - actualDamage)
    
    self:log(string.format("%s attacked %s with %s: %d damage (-%d armor)",
             attacker.name, target.name, weapon.name, actualDamage, target.armor))
    
    -- Check for destruction
    if target.health <= 0 then
        target.status = InterceptionScreen.STATUS.DESTROYED
        self:log(string.format("%s DESTROYED!", target.name))
    elseif target.health < target.maxHealth * 0.3 then
        target.status = InterceptionScreen.STATUS.DAMAGED
    end
    
    return true
end

--- Check if attacker can target with weapon
-- @param attacker table Attacking unit
-- @param target table Target unit
-- @param weapon table Weapon definition
-- @return boolean True if can target
function InterceptionScreen:canTarget(attacker, target, weapon)
    -- Check altitude restrictions
    local altitudeOk = false
    
    if weapon.targetAltitudes then
        for _, alt in ipairs(weapon.targetAltitudes) do
            if alt == target.altitude then
                altitudeOk = true
                break
            end
        end
    else
        -- No restriction = can target any altitude
        altitudeOk = true
    end
    
    if not altitudeOk then
        return false
    end
    
    -- Check range (placeholder - in full implementation would calculate distance)
    return true
end

--- Process enemy AI turn
function InterceptionScreen:processEnemyTurn()
    self.currentPhase = "enemy"
    self:log("=== ENEMY PHASE ===")
    
    for _, enemy in ipairs(self.enemyUnits) do
        if enemy.status == InterceptionScreen.STATUS.ACTIVE and enemy.ap > 0 then
            -- Simple AI: Attack first available player unit
            local target = self:findValidTarget(enemy)
            
            if target and #enemy.weapons > 0 then
                self:attack(enemy, target, 1) -- Use first weapon
            end
        end
    end
    
    -- Decrement cooldowns
    for _, unit in ipairs(self.enemyUnits) do
        for _, weapon in ipairs(unit.weapons) do
            if weapon.cooldownRemaining and weapon.cooldownRemaining > 0 then
                weapon.cooldownRemaining = weapon.cooldownRemaining - 1
            end
        end
    end
end

--- Find valid target for unit
-- @param attacker table Attacking unit
-- @return table|nil Target unit
function InterceptionScreen:findValidTarget(attacker)
    local targets = (attacker.side == "player") and self.enemyUnits or self.playerUnits
    
    for _, target in ipairs(targets) do
        if target.status == InterceptionScreen.STATUS.ACTIVE then
            return target
        end
    end
    
    return nil
end

--- Check win/loss conditions
-- @return boolean True if combat is over
function InterceptionScreen:checkEndConditions()
    -- Count active units
    local playerActive = 0
    local enemyActive = 0
    
    for _, unit in ipairs(self.playerUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE or 
           unit.status == InterceptionScreen.STATUS.DAMAGED then
            playerActive = playerActive + 1
        end
    end
    
    for _, unit in ipairs(self.enemyUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE or 
           unit.status == InterceptionScreen.STATUS.DAMAGED then
            enemyActive = enemyActive + 1
        end
    end
    
    -- Check victory
    if enemyActive == 0 then
        self.outcome = "victory"
        self:log("=== VICTORY ===")
        print("[InterceptionScreen] Player victory!")
        return true
    end
    
    -- Check defeat
    if playerActive == 0 then
        self.outcome = "defeat"
        self:log("=== DEFEAT ===")
        print("[InterceptionScreen] Player defeat!")
        return true
    end
    
    return false
end

--- Player retreats from combat
function InterceptionScreen:retreat()
    self.outcome = "retreat"
    self:log("=== PLAYER RETREATED ===")
    print("[InterceptionScreen] Player retreated")
    
    -- Mark all player units as retreated
    for _, unit in ipairs(self.playerUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE then
            unit.status = InterceptionScreen.STATUS.RETREATED
        end
    end
end

--- Add message to combat log
-- @param message string Log message
function InterceptionScreen:log(message)
    table.insert(self.combatLog, {
        turn = self.turn,
        message = message
    })
    print("[InterceptionScreen] " .. message)
end

--- Get combat summary
-- @return table Combat summary data
function InterceptionScreen:getSummary()
    return {
        outcome = self.outcome,
        turns = self.turn,
        playerUnits = self.playerUnits,
        enemyUnits = self.enemyUnits,
        combatLog = self.combatLog
    }
end

--- Get active player units
-- @return table Array of active units
function InterceptionScreen:getActivePlayerUnits()
    local active = {}
    for _, unit in ipairs(self.playerUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE or 
           unit.status == InterceptionScreen.STATUS.DAMAGED then
            table.insert(active, unit)
        end
    end
    return active
end

--- Get active enemy units
-- @return table Array of active units
function InterceptionScreen:getActiveEnemyUnits()
    local active = {}
    for _, unit in ipairs(self.enemyUnits) do
        if unit.status == InterceptionScreen.STATUS.ACTIVE or 
           unit.status == InterceptionScreen.STATUS.DAMAGED then
            table.insert(active, unit)
        end
    end
    return active
end

return InterceptionScreen

























