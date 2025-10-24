--- Interception Combat System - Pilot Experience Tracking
---
--- Manages interception battles and tracks pilot experience.
--- Pilots gain XP from successful interceptions based on enemy HP.
---
--- XP Formula: enemy_hp / 10 (per kill/damage contribution)
--- Pilots must be assigned to craft to gain XP
---
--- @module engine.interception.logic.interception_system
--- @author AlienFall Development Team

local PilotProgression = require("basescape.logic.pilot_progression")

local InterceptionSystem = {}
InterceptionSystem.__index = InterceptionSystem

--- Initialize interception battle
---@param craft table Player craft
---@param ufo table UFO entity
---@return table Interception battle session
function InterceptionSystem:createBattle(craft, ufo)
    local battle = {
        id = "interception_" .. os.time(),
        craft = craft,
        ufo = ufo,
        
        -- Tracking
        craft_damage = 0,
        ufo_health_remaining = ufo.health or 100,
        pilots = craft.pilots or {},  -- Assigned pilots
        
        -- Status
        active = true,
        turn_count = 0,
        
        -- Results (filled on completion)
        victory = false,
        ufo_destroyed = false,
        craft_damage_taken = 0,
        pilots_killed = {},
        pilots_damaged = {},
        xp_awarded = {}
    }
    
    print(string.format("[InterceptionSystem] Battle started: %s vs UFO (HP: %d)",
        craft.name or "Unknown", ufo.health or 100))
    
    return battle
end

--- Record damage to UFO
---@param battle table Interception battle
---@param damage number Damage amount
---@param pilotId string|nil Pilot responsible (for XP attribution)
---@return boolean Success
function InterceptionSystem:damageUFO(battle, damage, pilotId)
    if not battle then
        return false
    end
    
    battle.ufo_health_remaining = math.max(0, battle.ufo_health_remaining - damage)
    battle.craft_damage = battle.craft_damage + damage
    
    print(string.format("[InterceptionSystem] UFO damaged: -%d HP (Remaining: %d)",
        damage, battle.ufo_health_remaining))
    
    return true
end

--- Record damage to craft
---@param battle table Interception battle
---@param damage number Damage amount
---@return boolean Success
function InterceptionSystem:damageCraft(battle, damage)
    if not battle then
        return false
    end
    
    battle.craft_damage_taken = battle.craft_damage_taken + damage
    
    print(string.format("[InterceptionSystem] Craft damaged: -%d HP", damage))
    
    return true
end

--- Check if battle is over
---@param battle table Interception battle
---@return boolean Over, string reason
function InterceptionSystem:isBattleOver(battle)
    if not battle then
        return false, "Invalid battle"
    end
    
    -- UFO destroyed
    if battle.ufo_health_remaining <= 0 then
        return true, "UFO destroyed"
    end
    
    -- Craft destroyed
    if battle.craft_damage_taken >= (battle.craft.health or 100) then
        return true, "Craft destroyed"
    end
    
    -- Time limit (30 turns)
    if battle.turn_count >= 30 then
        return true, "Time limit reached"
    end
    
    return false, "Battle ongoing"
end

--- End interception battle and award XP
---@param battle table Interception battle
---@return table Results {victory, xp_awarded, pilots_leveled}
function InterceptionSystem:endBattle(battle)
    if not battle then
        return {victory = false, xp_awarded = {}}
    end
    
    -- Determine victory
    battle.victory = battle.ufo_health_remaining <= 0 and battle.craft_damage_taken < (battle.craft.health or 100)
    battle.ufo_destroyed = battle.ufo_health_remaining <= 0
    
    local results = {
        victory = battle.victory,
        xp_awarded = {},
        pilots_leveled = {}
    }
    
    print(string.format("[InterceptionSystem] Battle ended: %s",
        battle.victory and "VICTORY" or "DEFEAT"))
    
    -- Award XP to pilots
    if battle.victory and battle.craft_damage > 0 then
        results = self:awardPilotXP(battle, results)
    end
    
    return results
end

--- Award XP to pilots for successful interception
---
--- XP Formula: (enemy_hp / 10) per pilot
--- Shared among all pilots assigned to craft
---
---@param battle table Interception battle
---@param results table Results table to update
---@return table Updated results
function InterceptionSystem:awardPilotXP(battle, results)
    if not battle.pilots or #battle.pilots == 0 then
        return results
    end
    
    -- Calculate base XP from UFO damage
    local base_xp = math.floor((battle.craft_damage or 0) / 10)
    
    if base_xp <= 0 then
        return results
    end
    
    -- Split XP among pilots
    local xp_per_pilot = math.floor(base_xp / #battle.pilots)
    
    print(string.format("[InterceptionSystem] Awarding XP: %d base, %d per pilot",
        base_xp, xp_per_pilot))
    
    for _, pilotId in ipairs(battle.pilots) do
        if pilotId then
            local didRankUp = PilotProgression.gainXP(pilotId, xp_per_pilot, "interception")
            
            results.xp_awarded[pilotId] = xp_per_pilot
            
            if didRankUp then
                table.insert(results.pilots_leveled, pilotId)
                local rank = PilotProgression.getRank(pilotId)
                print(string.format("[InterceptionSystem] Pilot %s ranked up to %d!",
                    pilotId, rank))
            end
        end
    end
    
    return results
end

--- Get battle summary for display
---@param battle table Interception battle
---@param results table Battle results
---@return string Formatted summary
function InterceptionSystem:formatBattleSummary(battle, results)
    if not battle or not results then
        return "No battle data"
    end
    
    local summary = "=== INTERCEPTION SUMMARY ===\n"
    summary = summary .. string.format("Result: %s\n",
        results.victory and "VICTORY" or "DEFEAT")
    summary = summary .. string.format("Craft: %s | Damage: %d HP\n",
        battle.craft.name or "Unknown", battle.craft_damage_taken)
    summary = summary .. string.format("UFO: %s | Destroyed: %s\n",
        battle.ufo.name or "Unknown", results.ufo_destroyed and "YES" or "NO")
    
    if results.xp_awarded and next(results.xp_awarded) then
        summary = summary .. "\nPilot XP Gained:\n"
        for pilotId, xp in pairs(results.xp_awarded) do
            summary = summary .. string.format("  %s: +%d XP\n", pilotId, xp)
        end
    end
    
    if results.pilots_leveled and #results.pilots_leveled > 0 then
        summary = summary .. "\nPilots Promoted:\n"
        for _, pilotId in ipairs(results.pilots_leveled) do
            local rank = PilotProgression.getRank(pilotId)
            summary = summary .. string.format("  %s -> Rank %d\n", pilotId, rank)
        end
    end
    
    return summary
end

return InterceptionSystem
