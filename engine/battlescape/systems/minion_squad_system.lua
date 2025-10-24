---Minion Squad Management System
---
---Manages tactical control of summons, turrets, mind-controlled units, and other
---non-player squad members. Provides ability inheritance, formation bonuses,
---controllability tracking, and autonomous operation during player turns.
---
---Minion Types:
---  - TURRET: Automated defense turret (controlled by player)
---  - CONTROLLED: Mind-controlled enemy unit (temporary control)
---  - SUMMONED: Summon/pet from ability
---  - CLONE: Duplicate unit from ability
---
---Capabilities:
---  - Controllable by player during turn
---  - Ability inheritance from summoner
---  - Formation bonuses (+15% accuracy in squad formation)
---  - Autonomous behavior on player turn skip
---  - Loyalty tracking (for mind-controlled units)
---  - Leadership bonuses from master unit
---
---Key Exports:
---  - MinionSquadSystem.new(): Creates minion system
---  - createMinion(minionType, template): Creates new minion
---  - addToSquad(baseUnitId, minionId): Adds minion to squad
---  - updateSquadBonuses(baseUnitId): Recalculates formation bonuses
---  - getSquadUnits(baseUnitId): Gets all squad members
---  - removeMinionOnDeath(minionId): Cleanup on death
---
---Dependencies:
---  - battlescape.entities.unit: Unit base class
---  - battlescape.systems.abilities_system: Ability management
---  - battlescape.systems.morale_system: Loyalty tracking
---
---@module battlescape.systems.minion_squad_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MinionSquad = require("engine.battlescape.systems.minion_squad_system")
---  local system = MinionSquad.new()
---  local turret = system:createMinion("TURRET", {hp=20, ap=8})
---  system:addToSquad(playerUnitId, turret.id)
---  system:updateSquadBonuses(playerUnitId)

local MinionSquadSystem = {}
MinionSquadSystem.__index = MinionSquadSystem

--- Create new minion squad system
-- @return table New MinionSquadSystem instance
function MinionSquadSystem.new()
    local self = setmetatable({}, MinionSquadSystem)

    self.minions = {}          -- All minion units: minionId -> minion data
    self.squads = {}           -- Squad groups: baseUnitId -> {minionIds}
    self.minionMasters = {}    -- Minion ownership: minionId -> masterUnitId
    self.squadBonuses = {}     -- Squad formation bonuses: baseUnitId -> bonus data

    print("[MinionSquadSystem] Initialized minion squad system")

    return self
end

--- Create new minion unit
-- @param minionType string Type of minion (TURRET, CONTROLLED, SUMMONED, CLONE)
-- @param template table Minion template with stats
-- @return table New minion unit
function MinionSquadSystem:createMinion(minionType, template)
    local minion = {
        id = template.id or ("minion_" .. os.time() .. "_" .. math.random(1000, 9999)),
        type = minionType or "TURRET",
        name = template.name or ("Minion (" .. (minionType or "TURRET") .. ")"),

        -- Stats (inherited from template)
        hp = template.hp or 20,
        maxHp = template.maxHp or 20,
        ap = template.ap or 8,
        maxAp = template.maxAp or 8,
        accuracy = template.accuracy or 60,
        strength = template.strength or 50,

        -- Loyalty (for mind-controlled minions)
        loyalty = template.loyalty or 100,  -- 0-100, <20 = risk of breaking control
        loyaltyDecay = template.loyaltyDecay or 5,  -- per turn

        -- Capabilities
        controllable = template.controllable ~= false,
        canUseAbilities = template.canUseAbilities ~= false,
        autonomousAI = template.autonomousAI or true,

        -- Relationship to master
        masterUnitId = nil,
        inheritedAbilities = template.inheritedAbilities or {},
        masterBonus = template.masterBonus or 0,  -- Bonus from master leadership

        -- Squad position
        inSquad = false,
        formationBonus = 0,

        -- Combat state
        isDead = false,
        isSuppressed = false,
        statusEffects = {},

        -- Creation info
        createdAtTurn = template.createdAtTurn or 0,
        duration = template.duration or -1,  -- -1 = permanent, otherwise turns remaining
    }

    self.minions[minion.id] = minion
    print(string.format("[MinionSquadSystem] Created minion '%s' (type: %s, HP: %d, AP: %d)",
          minion.name, minionType, minion.hp, minion.ap))

    return minion
end

--- Add minion to a player's squad
-- @param baseUnitId string Master/base unit ID
-- @param minionId string Minion ID to add
-- @return boolean Success status
function MinionSquadSystem:addToSquad(baseUnitId, minionId)
    local minion = self.minions[minionId]

    if not minion then
        print(string.format("[MinionSquadSystem] ERROR: Minion not found: %s", minionId))
        return false
    end

    -- Initialize squad if needed
    if not self.squads[baseUnitId] then
        self.squads[baseUnitId] = {}
    end

    -- Add minion to squad
    table.insert(self.squads[baseUnitId], minionId)
    minion.inSquad = true
    minion.masterUnitId = baseUnitId
    self.minionMasters[minionId] = baseUnitId

    print(string.format("[MinionSquadSystem] Added '%s' to squad of unit %s",
          minion.name, baseUnitId))

    return true
end

--- Get all minions in a squad
-- @param baseUnitId string Master unit ID
-- @return table Array of minion units
function MinionSquadSystem:getSquadUnits(baseUnitId)
    local minionIds = self.squads[baseUnitId] or {}
    local units = {}

    for _, minionId in ipairs(minionIds) do
        local minion = self.minions[minionId]
        if minion and not minion.isDead then
            table.insert(units, minion)
        end
    end

    return units
end

--- Calculate and apply squad formation bonuses
-- @param baseUnitId string Master unit ID
function MinionSquadSystem:updateSquadBonuses(baseUnitId)
    local squadUnits = self:getSquadUnits(baseUnitId)
    local squadSize = #squadUnits

    if squadSize == 0 then
        self.squadBonuses[baseUnitId] = nil
        return
    end

    -- Formation bonus: +15% accuracy per squad member (max +45% with 3 units)
    -- Formation bonus: +5% defense per squad member (from collective positioning)
    local accuracyBonus = math.min(squadSize * 15, 45)
    local defenseBonus = squadSize * 5

    self.squadBonuses[baseUnitId] = {
        squadSize = squadSize,
        accuracyBonus = accuracyBonus,
        defenseBonus = defenseBonus,
        coordinationLevel = math.min(squadSize, 3),  -- 1-3
    }

    -- Apply bonuses to all squad members
    for _, minion in ipairs(squadUnits) do
        minion.formationBonus = accuracyBonus
    end

    print(string.format("[MinionSquadSystem] Squad %s bonuses updated: size=%d, accuracy+=%d%%, defense+=%d%%",
          baseUnitId, squadSize, accuracyBonus, defenseBonus))
end

--- Get squad bonus for unit
-- @param baseUnitId string Master unit ID
-- @return table Bonus data or nil
function MinionSquadSystem:getSquadBonus(baseUnitId)
    return self.squadBonuses[baseUnitId]
end

--- Update loyalty for controlled minions (decay each turn)
-- @param baseUnitId string Master unit ID
function MinionSquadSystem:processLoyaltyDecay(baseUnitId)
    local squadUnits = self:getSquadUnits(baseUnitId)

    for _, minion in ipairs(squadUnits) do
        -- Only controlled minions have loyalty
        if minion.type == "CONTROLLED" and minion.loyalty > 0 then
            minion.loyalty = math.max(0, minion.loyalty - (minion.loyaltyDecay or 5))

            -- Break control at 0 loyalty
            if minion.loyalty <= 0 then
                print(string.format("[MinionSquadSystem] Control broken: '%s' (loyalty 0)", minion.name))
                minion.type = "ENEMY"  -- Revert to enemy
            end
        end
    end
end

--- Check if minion can use abilities
-- @param minionId string Minion ID
-- @return boolean Can use abilities
function MinionSquadSystem:canUseAbilities(minionId)
    local minion = self.minions[minionId]

    if not minion then
        return false
    end

    return minion.canUseAbilities and not minion.isDead and minion.loyalty > 20
end

--- Get inherited abilities from master unit
-- @param minionId string Minion ID
-- @return table Array of inherited ability IDs
function MinionSquadSystem:getInheritedAbilities(minionId)
    local minion = self.minions[minionId]

    if not minion then
        return {}
    end

    return minion.inheritedAbilities or {}
end

--- Mark minion as dead and remove from squad
-- @param minionId string Minion ID
function MinionSquadSystem:removeMinionOnDeath(minionId)
    local minion = self.minions[minionId]

    if not minion then
        return
    end

    minion.isDead = true

    -- Remove from squad
    if minion.masterUnitId then
        local squad = self.squads[minion.masterUnitId]
        if squad then
            for i, id in ipairs(squad) do
                if id == minionId then
                    table.remove(squad, i)
                    break
                end
            end
        end

        -- Update squad bonuses
        self:updateSquadBonuses(minion.masterUnitId)
    end

    self.minionMasters[minionId] = nil

    print(string.format("[MinionSquadSystem] Minion '%s' marked as dead and removed from squad", minion.name))
end

--- Process minion duration (expiration after N turns)
-- @param turn number Current turn number
function MinionSquadSystem:processDurations(turn)
    local toRemove = {}

    for minionId, minion in pairs(self.minions) do
        -- Check duration
        if minion.duration > 0 and (turn - minion.createdAtTurn) >= minion.duration then
            print(string.format("[MinionSquadSystem] Minion '%s' duration expired (created turn %d, current %d)",
                  minion.name, minion.createdAtTurn, turn))
            self:removeMinionOnDeath(minionId)
        end
    end
end

--- Get all minions for a given type
-- @param minionType string Type filter (TURRET, CONTROLLED, SUMMONED, CLONE)
-- @return table Array of matching minions
function MinionSquadSystem:getMinionsByType(minionType)
    local result = {}

    for _, minion in pairs(self.minions) do
        if minion.type == minionType and not minion.isDead then
            table.insert(result, minion)
        end
    end

    return result
end

--- Get master unit for minion
-- @param minionId string Minion ID
-- @return table Master unit or nil
function MinionSquadSystem:getMasterUnit(minionId)
    local minion = self.minions[minionId]

    if not minion or not minion.masterUnitId then
        return nil
    end

    -- Return master unit object (requires integration with battle system)
    return minion.masterUnitId
end

--- Check if unit is in formation with another
-- @param unitId1 string First unit ID
-- @param unitId2 string Second unit ID
-- @return boolean True if in same formation
function MinionSquadSystem:isInFormation(unitId1, unitId2)
    -- Check if both are in same squad
    for baseUnitId, minionIds in pairs(self.squads) do
        local unitInSquad = false
        local minionInSquad = false

        for _, minionId in ipairs(minionIds) do
            if minionId == unitId1 then
                unitInSquad = true
            end
            if minionId == unitId2 then
                minionInSquad = true
            end
        end

        if unitInSquad and minionInSquad then
            return true
        end
    end

    return false
end

--- Get squad leader (master unit) for minion
-- @param minionId string Minion ID
-- @return string Master unit ID or nil
function MinionSquadSystem:getSquadLeader(minionId)
    return self.minionMasters[minionId]
end

--- Apply master leadership bonus to minion
-- @param minionId string Minion ID
-- @param bonusType string Type of bonus (ACCURACY, DAMAGE, MORALE, AP)
-- @return number Bonus value
function MinionSquadSystem:getLeadershipBonus(minionId, bonusType)
    local minion = self.minions[minionId]

    if not minion or not minion.masterUnitId then
        return 0
    end

    -- Leadership bonus scales with squad coordination level
    local bonus = self.squadBonuses[minion.masterUnitId]
    if not bonus then
        return 0
    end

    -- Different bonuses for different types
    if bonusType == "ACCURACY" then
        return math.floor(bonus.coordinationLevel * 5)  -- +5%, +10%, +15%
    elseif bonusType == "DAMAGE" then
        return math.floor(bonus.coordinationLevel * 3)  -- +3%, +6%, +9%
    elseif bonusType == "MORALE" then
        return bonus.coordinationLevel * 5  -- +5, +10, +15
    elseif bonusType == "AP" then
        return bonus.coordinationLevel > 2 and 1 or 0  -- +1 AP if level 3
    end

    return 0
end

--- Get squad statistics
-- @param baseUnitId string Master unit ID
-- @return table Squad stats
function MinionSquadSystem:getSquadStats(baseUnitId)
    local squad = self:getSquadUnits(baseUnitId)
    local totalHp = 0
    local totalAp = 0
    local totalAccuracy = 0

    for _, minion in ipairs(squad) do
        totalHp = totalHp + minion.hp
        totalAp = totalAp + minion.ap
        totalAccuracy = totalAccuracy + minion.accuracy
    end

    local size = #squad
    local avgAccuracy = size > 0 and math.floor(totalAccuracy / size) or 0

    return {
        size = size,
        totalHp = totalHp,
        totalAp = totalAp,
        averageAccuracy = avgAccuracy,
        bonus = self:getSquadBonus(baseUnitId),
    }
end

return MinionSquadSystem
