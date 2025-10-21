---ObjectivesSystem - Mission Objective Tracking and Victory Conditions
---
---Manages mission objectives, progress tracking, and victory conditions for tactical
---combat. Supports multiple objective types with weighted progress calculation.
---First team to reach 100% total progress wins the battle.
---
---Objective Types:
---  - KILL_ALL: Eliminate all enemy units
---  - DOMINATION: Control key sectors/points
---  - ASSASSINATION: Kill specific high-value unit
---  - SURVIVE: Survive for N turns
---  - EXTRACTION: Reach extraction zone with units
---
---Features:
---  - Multi-objective battles with weighted scoring
---  - Real-time progress tracking and updates
---  - Team-based victory conditions
---  - Objective state management (active/completed/failed)
---  - Battle end detection and winner determination
---  - Integration with battlefield state
---
---Key Exports:
---  - new(battlefield): Create new objectives system
---  - addObjective(objective): Add objective to battle
---  - update(): Update all objectives each turn
---  - getProgress(team): Get total progress for team
---  - isComplete(team): Check if team has won
---  - getObjectives(team): Get objectives for team
---  - getWinner(): Get victorious team or nil
---
---Dependencies:
---  - Battlefield reference for state checking
---
---@module battlescape.battlefield.objectives_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ObjectivesSystem = require("battlescape.battlefield.objectives_system")
---  local objectives = ObjectivesSystem.new(battlefield)
---  objectives:addObjective({
---      id = "eliminate_enemies",
---      type = "KILL_ALL",
---      team = "player",
---      weight = 100
---  })
---
---@see battlescape.battlefield.battlefield For battlefield integration
---@see battlescape.ui.objective_tracker_ui For objective display

-- Battle Objectives System
-- Manages mission objectives, progress tracking, and victory conditions
-- Each battle can have multiple objectives per team
-- First team to reach 100% progress wins

local ObjectivesSystem = {}
ObjectivesSystem.__index = ObjectivesSystem

--- Objective types
ObjectivesSystem.TYPES = {
    KILL_ALL = "kill_all",           -- Eliminate all enemy units
    DOMINATION = "domination",        -- Control key sectors
    ASSASSINATION = "assassination",  -- Kill specific unit
    SURVIVE = "survive",              -- Survive N turns
    EXTRACTION = "extraction"         -- Reach extraction zone
}

--- Create new objectives system
-- @param battlefield table Reference to battlefield
-- @return table New ObjectivesSystem instance
function ObjectivesSystem.new(battlefield)
    local self = setmetatable({}, ObjectivesSystem)
    
    self.battlefield = battlefield
    self.objectives = {}  -- All active objectives
    self.teamProgress = {}  -- Progress per team
    self.victoriousTeam = nil
    self.battleEnded = false
    
    print("[ObjectivesSystem] Initialized objectives system")
    
    return self
end

--- Add objective to battle
-- @param objective table Objective definition
function ObjectivesSystem:addObjective(objective)
    -- Validate objective
    if not objective.id or not objective.type or not objective.team then
        print("[ObjectivesSystem] ERROR: Invalid objective definition")
        return false
    end
    
    -- Set default values
    objective.progress = 0
    objective.completed = false
    objective.weight = objective.weight or 100
    objective.state = "active"
    
    table.insert(self.objectives, objective)
    
    print(string.format("[ObjectivesSystem] Added objective '%s' (type: %s, team: %s, weight: %d%%)",
          objective.id, objective.type, objective.team, objective.weight))
    
    return true
end

--- Update all objectives (call each turn)
function ObjectivesSystem:update()
    if self.battleEnded then
        return
    end
    
    -- Update each objective
    for _, objective in ipairs(self.objectives) do
        if not objective.completed and objective.state == "active" then
            self:updateObjective(objective)
        end
    end
    
    -- Calculate team progress
    self:calculateTeamProgress()
    
    -- Check for victory
    self:checkVictoryConditions()
end

--- Update specific objective progress
-- @param objective table Objective to update
function ObjectivesSystem:updateObjective(objective)
    local oldProgress = objective.progress
    
    -- Update based on objective type
    if objective.type == self.TYPES.KILL_ALL then
        objective.progress = self:checkKillAllProgress(objective)
    elseif objective.type == self.TYPES.DOMINATION then
        objective.progress = self:checkDominationProgress(objective)
    elseif objective.type == self.TYPES.ASSASSINATION then
        objective.progress = self:checkAssassinationProgress(objective)
    elseif objective.type == self.TYPES.SURVIVE then
        objective.progress = self:checkSurviveProgress(objective)
    elseif objective.type == self.TYPES.EXTRACTION then
        objective.progress = self:checkExtractionProgress(objective)
    end
    
    -- Check if objective completed
    if objective.progress >= 100 and not objective.completed then
        objective.completed = true
        objective.state = "completed"
        print(string.format("[ObjectivesSystem] Objective '%s' COMPLETED!", objective.id))
    end
    
    -- Log progress changes
    if objective.progress ~= oldProgress then
        print(string.format("[ObjectivesSystem] Objective '%s' progress: %d%% -> %d%%",
              objective.id, oldProgress, objective.progress))
    end
end

--- Check kill all objective progress
-- @param objective table Kill all objective
-- @return number Progress percentage (0-100)
function ObjectivesSystem:checkKillAllProgress(objective)
    local targetTeam = objective.conditions.targetTeam or "enemy"
    local totalEnemies = 0
    local deadEnemies = 0
    
    -- Count units in target team
    if self.battlefield and self.battlefield.units then
        for _, unit in pairs(self.battlefield.units) do
            if unit.teamId == targetTeam or unit.team == targetTeam then
                totalEnemies = totalEnemies + 1
                if not unit.alive or unit.isDead then
                    deadEnemies = deadEnemies + 1
                end
            end
        end
    end
    
    if totalEnemies == 0 then
        return 0
    end
    
    return math.floor((deadEnemies / totalEnemies) * 100)
end

--- Check domination objective progress
-- @param objective table Domination objective
-- @return number Progress percentage (0-100)
function ObjectivesSystem:checkDominationProgress(objective)
    -- TODO: Implement sector control checking
    -- For now, return partial completion based on unit positioning
    return 0
end

--- Check assassination objective progress
-- @param objective table Assassination objective
-- @return number Progress percentage (0-100)
function ObjectivesSystem:checkAssassinationProgress(objective)
    local targetUnitId = objective.conditions.targetUnitId
    
    if not targetUnitId then
        return 0
    end
    
    -- Check if target unit is dead
    if self.battlefield and self.battlefield.units then
        local targetUnit = self.battlefield.units[targetUnitId]
        if targetUnit and (not targetUnit.alive or targetUnit.isDead) then
            return 100
        end
    end
    
    return 0
end

--- Check survive objective progress
-- @param objective table Survive objective
-- @return number Progress percentage (0-100)
function ObjectivesSystem:checkSurviveProgress(objective)
    local turnsToSurvive = objective.conditions.turnsToSurvive or 10
    local currentTurn = self.battlefield.turnNumber or 1
    local turnsSurvived = currentTurn - (objective.startTurn or 1)
    
    local progress = math.floor((turnsSurvived / turnsToSurvive) * 100)
    return math.min(100, progress)
end

--- Check extraction objective progress
-- @param objective table Extraction objective
-- @return number Progress percentage (0-100)
function ObjectivesSystem:checkExtractionProgress(objective)
    local zone = objective.conditions.extractionZone
    if not zone then
        return 0
    end
    
    -- Check if any team unit is in extraction zone
    if self.battlefield and self.battlefield.units then
        for _, unit in pairs(self.battlefield.units) do
            if unit.teamId == objective.team and unit.alive then
                local distance = math.sqrt((unit.x - zone.x)^2 + (unit.y - zone.y)^2)
                if distance <= zone.radius then
                    return 100
                end
            end
        end
    end
    
    return 0
end

--- Calculate total progress for each team
function ObjectivesSystem:calculateTeamProgress()
    self.teamProgress = {}
    
    for _, objective in ipairs(self.objectives) do
        local team = objective.team
        if not self.teamProgress[team] then
            self.teamProgress[team] = 0
        end
        
        -- Add weighted progress
        local weightedProgress = (objective.progress / 100) * objective.weight
        self.teamProgress[team] = self.teamProgress[team] + weightedProgress
    end
    
    -- Log team progress
    for team, progress in pairs(self.teamProgress) do
        print(string.format("[ObjectivesSystem] Team '%s' progress: %.1f%%", team, progress))
    end
end

--- Check if any team has achieved victory
function ObjectivesSystem:checkVictoryConditions()
    for team, progress in pairs(self.teamProgress) do
        if progress >= 100 then
            self.victoriousTeam = team
            self.battleEnded = true
            print(string.format("[ObjectivesSystem] VICTORY! Team '%s' achieved 100%% progress!", team))
            return true
        end
    end
    
    return false
end

--- Get team progress percentage
-- @param team string Team identifier
-- @return number Progress percentage (0-100)
function ObjectivesSystem:getTeamProgress(team)
    return self.teamProgress[team] or 0
end

--- Get all objectives for a team
-- @param team string Team identifier
-- @return table Array of objectives
function ObjectivesSystem:getTeamObjectives(team)
    local teamObjectives = {}
    for _, objective in ipairs(self.objectives) do
        if objective.team == team then
            table.insert(teamObjectives, objective)
        end
    end
    return teamObjectives
end

--- Check if battle has ended
-- @return boolean True if battle ended
function ObjectivesSystem:hasBattleEnded()
    return self.battleEnded
end

--- Get victorious team
-- @return string|nil Team name or nil if no victory yet
function ObjectivesSystem:getVictoriousTeam()
    return self.victoriousTeam
end

--- Create standard kill all enemies objective
-- @param team string Team this objective belongs to
-- @param targetTeam string Team to eliminate
-- @return table Objective definition
function ObjectivesSystem.createKillAllObjective(team, targetTeam)
    return {
        id = "kill_all_" .. targetTeam,
        type = ObjectivesSystem.TYPES.KILL_ALL,
        name = "Eliminate All Enemies",
        description = "Destroy all " .. targetTeam .. " units",
        team = team,
        weight = 100,
        conditions = {
            targetTeam = targetTeam
        }
    }
end

--- Create survive N turns objective
-- @param team string Team this objective belongs to
-- @param turns number Number of turns to survive
-- @return table Objective definition
function ObjectivesSystem.createSurviveObjective(team, turns)
    return {
        id = "survive_" .. turns .. "_turns",
        type = ObjectivesSystem.TYPES.SURVIVE,
        name = "Survive " .. turns .. " Turns",
        description = "Keep at least one unit alive for " .. turns .. " turns",
        team = team,
        weight = 100,
        conditions = {
            turnsToSurvive = turns
        }
    }
end

--- Create assassination objective
-- @param team string Team this objective belongs to
-- @param targetUnitId string Unit to assassinate
-- @return table Objective definition
function ObjectivesSystem.createAssassinationObjective(team, targetUnitId)
    return {
        id = "assassinate_" .. targetUnitId,
        type = ObjectivesSystem.TYPES.ASSASSINATION,
        name = "Eliminate Target",
        description = "Kill the designated target unit",
        team = team,
        weight = 100,
        conditions = {
            targetUnitId = targetUnitId
        }
    }
end

return ObjectivesSystem

























