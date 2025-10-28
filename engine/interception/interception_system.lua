--- Interception Combat System - Pilot Experience Tracking
---
--- Manages interception battles and tracks pilot experience.
--- Pilots gain XP from successful interceptions based on enemy HP.
---
--- NEW SYSTEM: Uses craft.crew for pilot assignment (not deprecated pilots)
--- XP awarded via PilotManager.awardCrewXP() with position-based scaling
---
--- @module engine.interception.logic.interception_system
--- @author AlienFall Development Team

-- Use new PilotManager system (not deprecated PilotProgression)
local PilotManager = nil
pcall(function()
    PilotManager = require("geoscape.logic.pilot_manager")
end)
if not PilotManager then
    pcall(function()
        PilotManager = require("engine.geoscape.logic.pilot_manager")
    end)
end

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
--- NEW SYSTEM: Uses craft.crew and PilotManager.awardCrewXP()
--- XP scaled by crew position: pilot 100%, co-pilot 50%, crew 25%
---
---@param battle table Interception battle
---@param results table Results table to update
---@return table Updated results
function InterceptionSystem:awardPilotXP(battle, results)
    if not battle.craft or not battle.craft.crew or #battle.craft.crew == 0 then
        print("[InterceptionSystem] No crew assigned, no XP awarded")
        return results
    end
    
    -- Calculate base XP from UFO damage/destruction
    local base_xp = math.floor((battle.craft_damage or 0) / 10)
    
    -- Bonus XP for destroying UFO
    if battle.ufo_destroyed then
        base_xp = base_xp + 50
    end

    -- Bonus XP for victory without damage
    if battle.victory and battle.craft_damage_taken == 0 then
        base_xp = base_xp + 30  -- Perfect victory bonus
    end

    if base_xp <= 0 then
        print("[InterceptionSystem] No XP to award (insufficient damage)")
        return results
    end
    
    print(string.format("[InterceptionSystem] Awarding %d base XP to %d crew members",
        base_xp, #battle.craft.crew))

    -- Use PilotManager to award XP (handles position scaling)
    if PilotManager and PilotManager.awardCrewXP then
        PilotManager.awardCrewXP(battle.craft, base_xp, "interception_victory")

        -- Track in results (actual XP gain would need unit lookup)
        for i, crewId in ipairs(battle.craft.crew) do
            local multipliers = {1.0, 0.5, 0.25, 0.1, 0.1, 0.1}
            local multiplier = multipliers[i] or 0.1
            local xp = math.floor(base_xp * multiplier)
            results.xp_awarded[crewId] = xp
        end
    else
        print("[InterceptionSystem] WARNING: PilotManager not available, XP not awarded")
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

