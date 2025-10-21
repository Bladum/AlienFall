--- Turn Manager
--- Manages turn order, active teams, and turn transitions in tactical combat.
---
--- This module handles the turn-based gameplay mechanics, ensuring teams
--- take turns in proper order, resetting unit actions, and managing
--- turn transitions. Integrates with TeamManager and ActionSystem.
---
--- Example usage:
---   local turnManager = TurnManager.new(teamManager, actionSystem)
---   turnManager:initialize(units)
---   turnManager:startTeamTurn(units)
---   -- ... gameplay ...
---   turnManager:endTurn(units)

--- @class TurnManager
--- @field teamManager table Reference to TeamManager instance
--- @field actionSystem table Reference to ActionSystem instance
--- @field currentTeamIndex number Index of currently active team
--- @field turnNumber number Current turn/round number
--- @field activeTeams table Array of teams that can take turns
--- @field currentTeam table|nil Currently active team
local TurnManager = {}
TurnManager.__index = TurnManager

--- Create a new turn manager instance.
---
--- Initializes turn management with references to team and action systems.
---
--- @param teamManager table TeamManager instance
--- @param actionSystem table ActionSystem instance
--- @return table New TurnManager instance
function TurnManager.new(teamManager, actionSystem)
    local self = setmetatable({}, TurnManager)

    self.teamManager = teamManager
    self.actionSystem = actionSystem

    self.currentTeamIndex = 1
    self.turnNumber = 1
    self.activeTeams = {}
    self.currentTeam = nil

    return self
end

--- Initialize turn system with active teams.
---
--- Determines which teams can take turns and sets the first team as active.
--- Should be called at battle start.
---
--- @param units table Map of unitId -> unit from battlefield
--- @return boolean True if initialization successful
function TurnManager:initialize(units)
    self.activeTeams = self.teamManager:getActiveTeams(units)
    self.currentTeamIndex = 1
    self.turnNumber = 1

    print(string.format("[TurnManager] Found %d active teams", #self.activeTeams))
    for i, team in ipairs(self.activeTeams) do
        print(string.format("[TurnManager] Active team %d: %s", i, team.name))
    end

    if #self.activeTeams > 0 then
        self.currentTeam = self.activeTeams[1]
        print(string.format("[TurnManager] Initialized with %d teams, starting with %s",
              #self.activeTeams, self.currentTeam.name))
        return true
    end

    print("[TurnManager] ERROR: No active teams found!")
    return false
end

--- Start a team's turn by resetting their units.
---
--- Resets action points and movement for all living units in the current team.
--- Called automatically when a team's turn begins.
---
--- @param units table Map of unitId -> unit from battlefield
--- @return boolean True if turn started successfully
function TurnManager:startTeamTurn(units)
    if not self.currentTeam then
        print("[TurnManager] ERROR: No current team!")
        return false
    end

    print(string.format("[TurnManager] Starting turn for %s", self.currentTeam.name))

    -- Reset all units in team
    local resetCount = 0
    for _, unitId in ipairs(self.currentTeam.units) do
        local unit = units[unitId]
        if unit and unit.alive then
            self.actionSystem:resetUnit(unit)
            
            -- Regenerate energy
            unit:regenerateEnergy()
            
            -- Reduce weapon cooldowns
            unit:reduceWeaponCooldowns()
            
            -- Apply damage model recovery
            self:applyDamageModelRecovery(unit)
            
            -- Process bleeding damage from wounds
            self:processBleedingDamage(unit)
            
            -- Process buff/debuff durations
            self:processStatusEffects(unit)
            
            resetCount = resetCount + 1
        end
    end

    print(string.format("[TurnManager] Reset %d units for %s", resetCount, self.currentTeam.name))
    return true
end

--- Apply damage model recovery to a unit.
---
--- Recovers stun, morale, and energy based on damage model recovery rates.
--- Called each turn for all living units.
---
--- Recovery Rates:
--- - Stun: 2 points per turn
--- - Morale: 5 points per turn
--- - Energy: 3 points per turn (note: energy also has separate regeneration)
---
--- @param unit table Unit to apply recovery to
function TurnManager:applyDamageModelRecovery(unit)
    -- Stun recovery: 2 points per turn
    if unit.stun and unit.stun > 0 then
        local oldStun = unit.stun
        unit.stun = math.max(0, unit.stun - 2)
        if oldStun ~= unit.stun then
            print(string.format("[TurnManager] Unit %s recovered stun: %d -> %d", 
                  unit.name or "Unknown", oldStun, unit.stun))
        end
    end
    
    -- Morale recovery: 5 points per turn
    if unit.morale and unit.maxMorale then
        if unit.morale < unit.maxMorale then
            local oldMorale = unit.morale
            unit.morale = math.min(unit.maxMorale, unit.morale + 5)
            if oldMorale ~= unit.morale then
                print(string.format("[TurnManager] Unit %s recovered morale: %d -> %d", 
                      unit.name or "Unknown", oldMorale, unit.morale))
            end
        end
    end
    
    -- Energy recovery: 3 points per turn (in addition to other energy regen)
    -- This is specifically for damage model recovery
    if unit.energy and unit.maxEnergy then
        if unit.energy < unit.maxEnergy then
            local oldEnergy = unit.energy
            unit.energy = math.min(unit.maxEnergy, unit.energy + 3)
            if oldEnergy ~= unit.energy then
                print(string.format("[TurnManager] Unit %s recovered energy (damage model): %d -> %d", 
                      unit.name or "Unknown", oldEnergy, unit.energy))
            end
        end
    end
    
    -- Psi energy regeneration: 5 points per turn
    -- Only for psionic units (maxPsiEnergy > 0)
    if unit.psiEnergy and unit.maxPsiEnergy and unit.maxPsiEnergy > 0 then
        if unit.psiEnergy < unit.maxPsiEnergy then
            local oldPsiEnergy = unit.psiEnergy
            local regenAmount = unit.psiEnergyRegen or 5
            unit.psiEnergy = math.min(unit.maxPsiEnergy, unit.psiEnergy + regenAmount)
            if oldPsiEnergy ~= unit.psiEnergy then
                print(string.format("[TurnManager] Unit %s regenerated psi energy: %d -> %d (+%d)", 
                      unit.name or "Unknown", oldPsiEnergy, unit.psiEnergy, unit.psiEnergy - oldPsiEnergy))
            end
        end
    end
end

--- Process bleeding damage from wounds.
---
--- Applies 1 HP damage per turn for each active (non-stabilized) wound.
--- Called each turn for all living units.
---
--- @param unit table Unit to process bleeding for
function TurnManager:processBleedingDamage(unit)
    if not unit.wounds or unit.wounds <= 0 then
        return
    end
    
    -- Calculate total bleed damage from all wounds
    local totalBleedDamage = 0
    local activeWounds = 0
    
    if unit.woundList then
        for _, wound in ipairs(unit.woundList) do
            if not wound.stabilized then
                totalBleedDamage = totalBleedDamage + (wound.bleedRate or 1)
                activeWounds = activeWounds + 1
            end
        end
    else
        -- Fallback for units without wound tracking
        totalBleedDamage = unit.wounds
        activeWounds = unit.wounds
    end
    
    if totalBleedDamage > 0 then
        print(string.format("[TurnManager] Unit %s bleeding %d HP from %d active wound(s)",
              unit.name or "Unknown", totalBleedDamage, activeWounds))
        
        unit.health = math.max(0, (unit.health or 10) - totalBleedDamage)
        
        -- Check for death
        if unit.health <= 0 then
            unit.alive = false
            unit.isDead = true
            print(string.format("[TurnManager] Unit %s died from bleeding!", 
                  unit.name or "Unknown"))
        end
    end
end

--- Process status effects (buffs/debuffs).
---
--- Manages duration counters for temporary effects like:
--- - Mind control
--- - Slow/Haste
--- - Psionic buffs
--- Called each turn for all living units.
---
--- @param unit table Unit to process status effects for
function TurnManager:processStatusEffects(unit)
    -- Process mind control duration
    if unit.mindControlled and unit.mindControlDuration then
        unit.mindControlDuration = unit.mindControlDuration - 1
        
        if unit.mindControlDuration <= 0 then
            -- Mind control ends, return to original team
            unit.mindControlled = false
            unit.teamId = unit.originalTeamId or unit.teamId
            unit.mindControllerID = nil
            print(string.format("[TurnManager] Unit %s freed from mind control",
                  unit.name or "Unknown"))
        else
            print(string.format("[TurnManager] Unit %s mind controlled (%d turns remaining)",
                  unit.name or "Unknown", unit.mindControlDuration))
        end
    end
    
    -- Process slow effect duration
    if unit.slowed and unit.slowDuration then
        unit.slowDuration = unit.slowDuration - 1
        
        if unit.slowDuration <= 0 then
            unit.slowed = false
            unit.slowAPReduction = 0
            print(string.format("[TurnManager] Slow effect ended on %s",
                  unit.name or "Unknown"))
        else
            -- Apply AP reduction each turn
            if unit.actionPoints and unit.slowAPReduction then
                local oldAP = unit.actionPoints
                unit.actionPoints = math.max(0, unit.actionPoints - unit.slowAPReduction)
                print(string.format("[TurnManager] Unit %s slowed - AP: %d -> %d (%d turns remaining)",
                      unit.name or "Unknown", oldAP, unit.actionPoints, unit.slowDuration))
            end
        end
    end
    
    -- Process haste effect duration
    if unit.hasted and unit.hasteDuration then
        unit.hasteDuration = unit.hasteDuration - 1
        
        if unit.hasteDuration <= 0 then
            unit.hasted = false
            unit.hasteAPBonus = 0
            unit.hasteMaxAPBonus = 0
            print(string.format("[TurnManager] Haste effect ended on %s",
                  unit.name or "Unknown"))
        else
            -- Apply AP bonus each turn
            if unit.actionPoints and unit.hasteAPBonus then
                local oldAP = unit.actionPoints
                unit.actionPoints = unit.actionPoints + unit.hasteAPBonus
                print(string.format("[TurnManager] Unit %s hasted - AP: %d -> %d (%d turns remaining)",
                      unit.name or "Unknown", oldAP, unit.actionPoints, unit.hasteDuration))
            end
        end
    end
    
    -- Process psi critical buff (single-use)
    if unit.psiCriticalActive and unit.nextAttackCrit then
        print(string.format("[TurnManager] Unit %s has psi critical buff active",
              unit.name or "Unknown"))
        -- Buff is consumed when attack is made, not removed here
    end
end

--- End current turn and advance to next team.
---
--- Moves to the next team in turn order. If all teams have acted,
--- starts a new round and increments turn number.
---
--- @param units table Map of unitId -> unit from battlefield
--- @return boolean True if turn ended successfully
function TurnManager:endTurn(units)
    if not self.currentTeam then
        print("[TurnManager] ERROR: No current team!")
        return false
    end

    print(string.format("[TurnManager] Ending turn for %s", self.currentTeam.name))

    -- Move to next team
    self.currentTeamIndex = self.currentTeamIndex + 1

    if self.currentTeamIndex > #self.activeTeams then
        -- All teams have acted, start new round
        self.currentTeamIndex = 1
        self.turnNumber = self.turnNumber + 1
        print(string.format("[TurnManager] Starting turn %d", self.turnNumber))
    end

    self.currentTeam = self.activeTeams[self.currentTeamIndex]
    self:startTeamTurn(units)

    return true
end

--- Get the currently active team.
---
--- @return table|nil Current team or nil if none active
function TurnManager:getCurrentTeam()
    return self.currentTeam
end

--- Get the current turn/round number.
---
--- @return number Current turn number (starts at 1)
function TurnManager:getTurnNumber()
    return self.turnNumber
end

--- Get list of all active teams.
---
--- Returns teams that can currently take turns (have living units).
---
--- @return table Array of active team objects
function TurnManager:getActiveTeams()
    return self.activeTeams
end

-- Move to next team (for manual team switching)
function TurnManager:nextTeam()
    if #self.activeTeams == 0 then
        print("[TurnManager] No active teams!")
        return false
    end
    
    self.currentTeamIndex = self.currentTeamIndex + 1
    if self.currentTeamIndex > #self.activeTeams then
        self.currentTeamIndex = 1
    end
    
    self.currentTeam = self.activeTeams[self.currentTeamIndex]
    print(string.format("[TurnManager] Switched to %s", self.currentTeam.name))
    return true
end

-- Check if it's a specific team's turn
function TurnManager:isTeamsTurn(teamId)
    return self.currentTeam and self.currentTeam.id == teamId
end

-- Update active teams (in case teams are eliminated)
function TurnManager:updateActiveTeams(units)
    local oldCount = #self.activeTeams
    self.activeTeams = self.teamManager:getActiveTeams(units)
    local newCount = #self.activeTeams
    
    if newCount < oldCount then
        print(string.format("[TurnManager] Active teams reduced: %d -> %d", oldCount, newCount))
        
        -- Ensure current team is still valid
        if self.currentTeamIndex > #self.activeTeams then
            self.currentTeamIndex = 1
            self.currentTeam = self.activeTeams[1]
        end
    end
    
    return newCount > 0
end

return TurnManager

























