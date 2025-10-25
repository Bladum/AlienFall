---Pilot Progression System
---
---Manages pilot experience gain, ranking, and stat progression.
---Pilots gain XP only from interception combat, not ground battles.
---Three-rank system: Rookie → Veteran → Ace
---
---Key Features:
---  - XP tracking per pilot
---  - Rank progression with thresholds
---  - Automatic stat increases on rank-up
---  - Rank insignia management
---  - Performance metrics
---
---Key Exports:
---  - PilotProgression.gainXP() - Award XP to pilot
---  - PilotProgression.getRank() - Get pilot's current rank
---  - PilotProgression.getXP() - Get pilot's current XP
---  - PilotProgression.getRankInsignia() - Get rank display
---  - PilotProgression.applyRankBonuses() - Apply stat increases
---
---Dependencies:
---  - None (standalone system)
---
---@module PilotProgression
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local PilotProgression = {}

---Rank definitions and XP thresholds
PilotProgression.RANKS = {
    { id = 0, name = "Rookie", xp_required = 0, insignia = "bronze", color = {255, 200, 100} },
    { id = 1, name = "Veteran", xp_required = 100, insignia = "silver", color = {200, 200, 200} },
    { id = 2, name = "Ace", xp_required = 300, insignia = "gold", color = {255, 215, 0} },
}

---Stat bonuses per rank (applied on rank up)
PilotProgression.RANK_BONUSES = {
    speed = 1,
    aim = 2,
    reaction = 1,
}

---Per-pilot progression data
---@type table<number, table>
PilotProgression.pilots = {}

---Initialize pilot progression tracking
---@param pilotId number - Pilot unit ID
---@param initialRank number - Starting rank (0=Rookie)
function PilotProgression.initializePilot(pilotId, initialRank)
    if not pilotId then
        return
    end
    
    initialRank = initialRank or 0
    
    PilotProgression.pilots[pilotId] = {
        id = pilotId,
        current_rank = initialRank,
        current_xp = 0,
        total_xp_earned = 0,
        kills = 0,
        missions = 0,
        victories = 0,
        defeats = 0,
        created_at = os.time(),
        last_mission = nil,
    }
    
    print(string.format("[PilotProgression] Initialized pilot %d at rank %s", 
        pilotId, PilotProgression.RANKS[initialRank + 1].name))
end

---Award XP to a pilot
---@param pilotId number - Pilot unit ID
---@param xpAmount number - XP to award
---@param source string - Source of XP (e.g., "interception_victory", "kill")
---@return boolean - True if pilot ranked up
function PilotProgression.gainXP(pilotId, xpAmount, source)
    if not pilotId or not xpAmount or xpAmount <= 0 then
        return false
    end
    
    -- Initialize if needed
    if not PilotProgression.pilots[pilotId] then
        PilotProgression.initializePilot(pilotId, 0)
    end
    
    local pilot = PilotProgression.pilots[pilotId]
    pilot.current_xp = pilot.current_xp + xpAmount
    pilot.total_xp_earned = pilot.total_xp_earned + xpAmount
    
    source = source or "unknown"
    print(string.format("[PilotProgression] Pilot %d gained %d XP (%s) - Total: %d",
        pilotId, xpAmount, source, pilot.current_xp))
    
    -- Check for rank up
    return PilotProgression.checkRankUp(pilotId)
end

---Check if pilot should rank up and process if needed
---@param pilotId number - Pilot unit ID
---@return boolean - True if pilot ranked up
function PilotProgression.checkRankUp(pilotId)
    if not PilotProgression.pilots[pilotId] then
        return false
    end
    
    local pilot = PilotProgression.pilots[pilotId]
    local currentRankDef = PilotProgression.RANKS[pilot.current_rank + 1]
    local nextRankDef = PilotProgression.RANKS[pilot.current_rank + 2]
    
    -- Can't rank up beyond max
    if not nextRankDef then
        return false
    end
    
    -- Check if XP threshold met
    if pilot.current_xp >= nextRankDef.xp_required then
        pilot.current_rank = pilot.current_rank + 1
        pilot.current_xp = 0  -- Reset XP for next rank
        
        print(string.format("[PilotProgression] Pilot %d RANKED UP to %s!",
            pilotId, nextRankDef.name))
        
        -- Notify about rank-up bonuses
        print(string.format(
            "[PilotProgression] Rank-up bonuses applied: SPEED +%d, AIM +%d, REACTION +%d",
            PilotProgression.RANK_BONUSES.speed,
            PilotProgression.RANK_BONUSES.aim,
            PilotProgression.RANK_BONUSES.reaction
        ))
        
        return true
    end
    
    return false
end

---Get pilot's current rank
---@param pilotId number - Pilot unit ID
---@return number - Rank ID (0, 1, 2)
function PilotProgression.getRank(pilotId)
    if not PilotProgression.pilots[pilotId] then
        return 0
    end
    return PilotProgression.pilots[pilotId].current_rank
end

---Get pilot's current XP
---@param pilotId number - Pilot unit ID
---@return number - Current XP in this rank
function PilotProgression.getXP(pilotId)
    if not PilotProgression.pilots[pilotId] then
        return 0
    end
    return PilotProgression.pilots[pilotId].current_xp
end

---Get total XP earned by pilot
---@param pilotId number - Pilot unit ID
---@return number - Total XP earned across all ranks
function PilotProgression.getTotalXP(pilotId)
    if not PilotProgression.pilots[pilotId] then
        return 0
    end
    return PilotProgression.pilots[pilotId].total_xp_earned
end

---Get rank definition
---@param rankId number - Rank ID (0, 1, or 2)
---@return table|nil - Rank definition or nil
function PilotProgression.getRankDef(rankId)
    if rankId < 0 or rankId >= #PilotProgression.RANKS then
        return nil
    end
    return PilotProgression.RANKS[rankId + 1]
end

---Get rank insignia (for UI display)
---@param pilotId number - Pilot unit ID
---@return table - Insignia info {name, type, color}
function PilotProgression.getRankInsignia(pilotId)
    local rank = PilotProgression.getRank(pilotId)
    local rankDef = PilotProgression.getRankDef(rank)
    
    if not rankDef then
        return { name = "Unknown", type = "unknown", color = {128, 128, 128} }
    end
    
    return {
        name = rankDef.name,
        type = rankDef.insignia,
        color = rankDef.color,
    }
end

---Get XP progress to next rank (as percentage)
---@param pilotId number - Pilot unit ID
---@return number - Percentage (0-100) or 100 if at max rank
function PilotProgression.getXPProgress(pilotId)
    local rank = PilotProgression.getRank(pilotId)
    local currentXP = PilotProgression.getXP(pilotId)
    
    -- At max rank
    if rank >= #PilotProgression.RANKS - 1 then
        return 100
    end
    
    local nextRankDef = PilotProgression.RANKS[rank + 2]
    if not nextRankDef then
        return 100
    end
    
    local xpNeeded = nextRankDef.xp_required
    local progress = math.floor((currentXP / xpNeeded) * 100)
    
    return math.min(progress, 100)
end

---Record mission participation
---@param pilotId number - Pilot unit ID
---@param victory boolean - Whether mission was won
---@param kills number - Number of enemies killed
---@param damage_dealt number - Damage dealt in combat
function PilotProgression.recordMission(pilotId, victory, kills, damage_dealt)
    if not PilotProgression.pilots[pilotId] then
        PilotProgression.initializePilot(pilotId, 0)
    end
    
    local pilot = PilotProgression.pilots[pilotId]
    pilot.missions = pilot.missions + 1
    pilot.kills = (pilot.kills or 0) + (kills or 0)
    
    if victory then
        pilot.victories = pilot.victories + 1
        -- Award XP based on damage dealt
        local xpReward = math.floor((damage_dealt or 0) / 10)
        PilotProgression.gainXP(pilotId, xpReward, "mission_victory")
    else
        pilot.defeats = pilot.defeats + 1
    end
    
    pilot.last_mission = os.time()
end

---Apply rank bonuses to unit stats
---@param pilotId number - Pilot unit ID
---@param statKey string - Stat key (speed, aim, reaction)
---@return number - Bonus value for this stat
function PilotProgression.getStatBonus(pilotId, statKey)
    local rank = PilotProgression.getRank(pilotId)
    local bonus = PilotProgression.RANK_BONUSES[statKey] or 0
    
    -- Multiply bonus by rank
    return bonus * rank
end

---Get comprehensive pilot stats
---@param pilotId number - Pilot unit ID
---@return table - Complete pilot progression data
function PilotProgression.getPilotStats(pilotId)
    if not PilotProgression.pilots[pilotId] then
        return {}
    end
    
    local pilot = PilotProgression.pilots[pilotId]
    local rankDef = PilotProgression.getRankDef(pilot.current_rank)
    
    if not rankDef then
        return {}
    end
    
    return {
        id = pilot.id,
        rank = rankDef.name,
        rank_id = pilot.current_rank,
        xp_current = pilot.current_xp,
        xp_total = pilot.total_xp_earned,
        xp_progress = PilotProgression.getXPProgress(pilotId),
        kills = pilot.kills,
        missions_flown = pilot.missions,
        victories = pilot.victories,
        defeats = pilot.defeats,
        insignia = PilotProgression.getRankInsignia(pilotId),
        stat_bonuses = {
            speed = PilotProgression.getStatBonus(pilotId, "speed"),
            aim = PilotProgression.getStatBonus(pilotId, "aim"),
            reaction = PilotProgression.getStatBonus(pilotId, "reaction"),
        },
    }
end

---Reset all pilot data (for testing)
function PilotProgression.reset()
    PilotProgression.pilots = {}
    print("[PilotProgression] All pilot progression data reset")
end

return PilotProgression

