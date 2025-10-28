---UnitProgression - Experience and Leveling System
---
---Handles unit experience, leveling, traits, and medals. Core progression mechanics
---for tactical units. Units gain XP from combat actions, level up, unlock traits,
---and earn medals for achievements.
---
---Features:
---  - Experience point (XP) tracking
---  - 7 rank levels (Rookie to Colonel)
---  - Trait system (passive abilities)
---  - Medal awards for achievements
---  - Stat improvements on level up
---  - Kill tracking and commendations
---
---Rank Levels (0-6):
---  - 0: Rookie (0 XP)
---  - 1: Squaddie (100 XP)
---  - 2: Corporal (300 XP)
---  - 3: Sergeant (600 XP)
---  - 4: Lieutenant (1000 XP)
---  - 5: Captain (1500 XP)
---  - 6: Colonel (2000 XP)
---
---XP Sources:
---  - Kill: 50-100 XP (varies by enemy)
---  - Assist: 25 XP
---  - Wound enemy: 10 XP
---  - Complete mission: 100 XP (all units)
---  - Survive mission: 50 XP
---
---Traits (Passive Abilities):
---  - Unlocked at specific levels
---  - Permanent stat bonuses
---  - Special abilities (overwatch, reload, etc.)
---  - Class-specific traits
---
---Medals (Awards):
---  - Star of Terra: 50+ kills
---  - Urban Warfare Expert: 25+ urban missions
---  - Medic Badge: 50+ heals
---  - Accuracy Award: 90%+ hit rate
---  - Many more...
---
---Key Exports:
---  - UnitProgression.awardXP(unit, amount, reason): Adds XP
---  - UnitProgression.levelUp(unit): Handles level up
---  - UnitProgression.unlockTrait(unit, traitId): Grants trait
---  - UnitProgression.awardMedal(unit, medalId): Grants medal
---  - UnitProgression.checkMedalConditions(unit): Checks for new medals
---
---Dependencies:
---  - None (standalone system)
---
---@module battlescape.logic.unit_progression
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local UnitProgression = require("battlescape.logic.unit_progression")
---  UnitProgression.awardXP(soldier, 50, "enemy_kill")
---  if soldier.xp >= UnitProgression.LEVEL_THRESHOLDS[soldier.level + 1] then
---      UnitProgression.levelUp(soldier)
---  end
---
---@see battlescape.logic.unit_recovery For post-mission recovery

-- Unit Progression System
-- Handles unit experience, leveling, traits, and medals
-- Core progression mechanics for tactical units

local UnitProgression = {}
UnitProgression.__index = UnitProgression

--- Experience level thresholds (7 levels: 0-6)
UnitProgression.LEVEL_THRESHOLDS = {
    [0] = 0,      -- Rookie
    [1] = 100,    -- Squaddie
    [2] = 300,    -- Corporal
    [3] = 600,    -- Sergeant
    [4] = 1000,   -- Lieutenant
    [5] = 1500,   -- Captain
    [6] = 2100    -- Colonel
}

--- Level names for display
UnitProgression.LEVEL_NAMES = {
    [0] = "Rookie",
    [1] = "Squaddie",
    [2] = "Corporal",
    [3] = "Sergeant",
    [4] = "Lieutenant",
    [5] = "Captain",
    [6] = "Colonel"
}

--- Stat bonuses per level
UnitProgression.LEVEL_BONUSES = {
    health = 2,      -- +2 HP per level
    aim = 1,         -- +1 aim per level
    will = 1,        -- +1 will per level
    energy = 2,      -- +2 energy per level
    react = 1        -- +1 reactions per level
}

--- Available unit traits (assigned at creation)
UnitProgression.TRAITS = {
    smart = {
        name = "Smart",
        description = "Learns 20% faster",
        xpMultiplier = 0.8,  -- Needs 20% less XP
        statMods = {}
    },
    fast = {
        name = "Fast",
        description = "+1 AP in combat",
        xpMultiplier = 1.0,
        statMods = {speed = 1}
    },
    pack_mule = {
        name = "Pack Mule",
        description = "+25% carrying capacity",
        xpMultiplier = 1.0,
        statMods = {strength = 2}
    },
    lucky = {
        name = "Lucky",
        description = "+5% critical hit chance",
        xpMultiplier = 1.0,
        statMods = {critBonus = 5}
    },
    tough = {
        name = "Tough",
        description = "+2 HP and +1 armor",
        xpMultiplier = 1.0,
        statMods = {health = 2, armour = 1}
    },
    keen_eye = {
        name = "Keen Eye",
        description = "+2 aim and +5 sight",
        xpMultiplier = 1.0,
        statMods = {aim = 2, sight = 5}
    }
}

--- Available medals (one-time XP bonuses)
UnitProgression.MEDALS = {
    sniper_i = {name = "Sniper I", xpBonus = 50, requirement = "5 kills with ranged weapons"},
    sniper_ii = {name = "Sniper II", xpBonus = 100, requirement = "15 kills with ranged weapons"},
    medic_i = {name = "Medic I", xpBonus = 50, requirement = "Heal 50 HP"},
    survivor = {name = "Survivor", xpBonus = 75, requirement = "Survive 10 missions"},
    hero = {name = "Hero", xpBonus = 150, requirement = "Complete mission objective solo"}
}

--- Initialize unit progression data
-- @param unit table Unit entity to initialize
function UnitProgression.initializeUnit(unit)
    unit.experience = unit.experience or 0
    unit.level = unit.level or 0
    unit.trait = unit.trait or nil
    unit.medals = unit.medals or {}
    unit.transformation = unit.transformation or nil
    unit.missionsCompleted = unit.missionsCompleted or 0
    unit.kills = unit.kills or 0
    
    print(string.format("[UnitProgression] Initialized unit %s (Level %d, %d XP)",
          unit.name or "Unknown", unit.level, unit.experience))
end

--- Assign random trait to unit (at creation)
-- @param unit table Unit entity
function UnitProgression.assignRandomTrait(unit)
    local traitKeys = {}
    for key, _ in pairs(UnitProgression.TRAITS) do
        table.insert(traitKeys, key)
    end
    
    if #traitKeys == 0 then
        return
    end
    
    local traitKey = traitKeys[math.random(1, #traitKeys)]
    unit.trait = traitKey
    
    -- Apply trait stat modifiers
    local trait = UnitProgression.TRAITS[traitKey]
    if trait and trait.statMods then
        for stat, bonus in pairs(trait.statMods) do
            if unit[stat] then
                unit[stat] = unit[stat] + bonus
            end
        end
    end
    
    print(string.format("[UnitProgression] Assigned trait '%s' to unit %s",
          trait.name, unit.name or "Unknown"))
end

--- Award experience to unit
-- @param unit table Unit entity
-- @param xp number Experience points to award
function UnitProgression.awardExperience(unit, xp)
    if not unit.experience then
        UnitProgression.initializeUnit(unit)
    end
    
    -- Apply trait XP multiplier
    if unit.trait and UnitProgression.TRAITS[unit.trait] then
        local multiplier = UnitProgression.TRAITS[unit.trait].xpMultiplier or 1.0
        xp = math.floor(xp * multiplier)
    end
    
    local oldLevel = unit.level
    unit.experience = unit.experience + xp
    
    -- Check for level up
    local newLevel = UnitProgression.calculateLevel(unit.experience)
    
    if newLevel > oldLevel then
        UnitProgression.levelUp(unit, newLevel)
    end
    
    print(string.format("[UnitProgression] Unit %s gained %d XP (total: %d, level: %d)",
          unit.name or "Unknown", xp, unit.experience, unit.level))
end

--- Calculate level from experience points
-- @param xp number Total experience points
-- @return number Level (0-6)
function UnitProgression.calculateLevel(xp)
    for level = 6, 0, -1 do
        if xp >= UnitProgression.LEVEL_THRESHOLDS[level] then
            return level
        end
    end
    return 0
end

--- Level up unit and apply bonuses
-- @param unit table Unit entity
-- @param newLevel number New level to reach
function UnitProgression.levelUp(unit, newLevel)
    local oldLevel = unit.level or 0
    unit.level = newLevel
    
    -- Apply stat bonuses for each level gained
    local levelsGained = newLevel - oldLevel
    
    for stat, bonusPerLevel in pairs(UnitProgression.LEVEL_BONUSES) do
        local totalBonus = bonusPerLevel * levelsGained
        if unit[stat] then
            unit[stat] = unit[stat] + totalBonus
        end
        if stat == "health" and unit.maxHealth then
            unit.maxHealth = unit.maxHealth + totalBonus
        end
        if stat == "energy" and unit.maxEnergy then
            unit.maxEnergy = unit.maxEnergy + totalBonus
        end
    end
    
    print(string.format("[UnitProgression] LEVEL UP! Unit %s reached level %d (%s)",
          unit.name or "Unknown", newLevel, UnitProgression.LEVEL_NAMES[newLevel]))
end

--- Award medal to unit (one-time XP bonus)
-- @param unit table Unit entity
-- @param medalId string Medal identifier
-- @return boolean True if medal awarded, false if already has it
function UnitProgression.awardMedal(unit, medalId)
    if not unit.medals then
        unit.medals = {}
    end
    
    -- Check if unit already has this medal
    for _, earnedMedal in ipairs(unit.medals) do
        if earnedMedal == medalId then
            print(string.format("[UnitProgression] Unit %s already has medal %s",
                  unit.name or "Unknown", medalId))
            return false
        end
    end
    
    -- Award medal
    table.insert(unit.medals, medalId)
    
    -- Award XP bonus
    local medal = UnitProgression.MEDALS[medalId]
    if medal and medal.xpBonus then
        UnitProgression.awardExperience(unit, medal.xpBonus)
        print(string.format("[UnitProgression] Unit %s earned medal '%s' (+%d XP bonus)",
              unit.name or "Unknown", medal.name, medal.xpBonus))
    end
    
    return true
end

--- Get unit's level name
-- @param unit table Unit entity
-- @return string Level name
function UnitProgression.getLevelName(unit)
    local level = unit.level or 0
    return UnitProgression.LEVEL_NAMES[level] or "Unknown"
end

--- Get XP needed for next level
-- @param unit table Unit entity
-- @return number XP needed, or 0 if max level
function UnitProgression.getXPToNextLevel(unit)
    local currentLevel = unit.level or 0
    local nextLevel = currentLevel + 1
    
    if nextLevel > 6 then
        return 0  -- Max level
    end
    
    local currentXP = unit.experience or 0
    local nextThreshold = UnitProgression.LEVEL_THRESHOLDS[nextLevel]
    
    return nextThreshold - currentXP
end

--- Get unit's trait information
-- @param unit table Unit entity
-- @return table|nil Trait definition or nil
function UnitProgression.getTrait(unit)
    if not unit.trait then
        return nil
    end
    return UnitProgression.TRAITS[unit.trait]
end

--- Process post-mission rewards
-- @param unit table Unit entity
-- @param missionData table Mission completion data
function UnitProgression.processMissionRewards(unit, missionData)
    -- Base mission XP
    local baseXP = 30
    
    -- Bonus XP for mission completion
    if missionData.victory then
        baseXP = baseXP + 20
    end
    
    -- Bonus XP for kills
    if missionData.kills and missionData.kills > 0 then
        baseXP = baseXP + (missionData.kills * 10)
        unit.kills = (unit.kills or 0) + missionData.kills
    end
    
    -- Bonus XP for objectives
    if missionData.objectivesCompleted then
        baseXP = baseXP + (missionData.objectivesCompleted * 15)
    end
    
    -- Award experience
    UnitProgression.awardExperience(unit, baseXP)
    
    -- Increment missions completed
    unit.missionsCompleted = (unit.missionsCompleted or 0) + 1
    
    -- Check for medal awards
    UnitProgression.checkMedalEligibility(unit)
    
    print(string.format("[UnitProgression] Post-mission rewards for %s: %d XP, %d total missions",
          unit.name or "Unknown", baseXP, unit.missionsCompleted))
end

--- Check if unit is eligible for any medals
-- @param unit table Unit entity
function UnitProgression.checkMedalEligibility(unit)
    local kills = unit.kills or 0
    local missions = unit.missionsCompleted or 0
    
    -- Sniper medals
    if kills >= 5 and not UnitProgression.hasMedal(unit, "sniper_i") then
        UnitProgression.awardMedal(unit, "sniper_i")
    end
    if kills >= 15 and not UnitProgression.hasMedal(unit, "sniper_ii") then
        UnitProgression.awardMedal(unit, "sniper_ii")
    end
    
    -- Survivor medal
    if missions >= 10 and not UnitProgression.hasMedal(unit, "survivor") then
        UnitProgression.awardMedal(unit, "survivor")
    end
end

--- Check if unit has specific medal
-- @param unit table Unit entity
-- @param medalId string Medal identifier
-- @return boolean True if unit has medal
function UnitProgression.hasMedal(unit, medalId)
    if not unit.medals then
        return false
    end
    
    for _, earnedMedal in ipairs(unit.medals) do
        if earnedMedal == medalId then
            return true
        end
    end
    
    return false
end

--- Get unit progression summary for UI display
-- @param unit table Unit entity
-- @return table Progression summary
function UnitProgression.getProgressionSummary(unit)
    return {
        level = unit.level or 0,
        levelName = UnitProgression.getLevelName(unit),
        experience = unit.experience or 0,
        xpToNextLevel = UnitProgression.getXPToNextLevel(unit),
        trait = UnitProgression.getTrait(unit),
        medals = unit.medals or {},
        missionsCompleted = unit.missionsCompleted or 0,
        kills = unit.kills or 0
    }
end

return UnitProgression


























