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
            
            resetCount = resetCount + 1
        end
    end

    print(string.format("[TurnManager] Reset %d units for %s", resetCount, self.currentTeam.name))
    return true
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
