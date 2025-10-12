-- Turn Manager
-- Manages turn order, active teams, and turn transitions

local TurnManager = {}
TurnManager.__index = TurnManager

-- Create a new turn manager
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

-- Initialize turn system
function TurnManager:initialize(units)
    self.activeTeams = self.teamManager:getActiveTeams(units)
    self.currentTeamIndex = 1
    self.turnNumber = 1
    
    if #self.activeTeams > 0 then
        self.currentTeam = self.activeTeams[1]
        print(string.format("[TurnManager] Initialized with %d teams, starting with %s", 
              #self.activeTeams, self.currentTeam.name))
        return true
    end
    
    print("[TurnManager] ERROR: No active teams found!")
    return false
end

-- Start a team's turn
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
            resetCount = resetCount + 1
        end
    end
    
    print(string.format("[TurnManager] Reset %d units for %s", resetCount, self.currentTeam.name))
    return true
end

-- End current turn and move to next team
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

-- Get current team
function TurnManager:getCurrentTeam()
    return self.currentTeam
end

-- Get current turn number
function TurnManager:getTurnNumber()
    return self.turnNumber
end

-- Get active teams
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
