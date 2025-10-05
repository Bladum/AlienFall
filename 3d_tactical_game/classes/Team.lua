---@class Team
-- Represents a team/faction in the game
-- Manages units, shared visibility, and team properties

local Constants = require("config.constants")
local Colors = require("config.colors")

local Team = {}
Team.__index = Team

--- Create a new Team
---@param id number Team ID from Constants.TEAM
---@param name string Team name
---@return Team
function Team.new(id, name)
    local self = setmetatable({}, Team)
    
    -- Identity
    self.id = id
    self.name = name or "Team " .. id
    self.color = Colors.TEAM[id] or {1, 1, 1, 1}
    
    -- Units
    self.units = {}  -- Array of Unit objects
    self.selectedUnit = nil  -- Currently selected unit
    
    -- Team state
    self.isPlayerControlled = (id == Constants.TEAM.PLAYER)
    self.active = true
    
    return self
end

--- Add a unit to this team
---@param unit any Unit object
function Team:addUnit(unit)
    table.insert(self.units, unit)
    unit.team = self
    unit.teamId = self.id
    
    -- Select first unit if none selected
    if not self.selectedUnit and self.isPlayerControlled then
        self.selectedUnit = unit
    end
end

--- Remove a unit from this team
---@param unit any Unit object
function Team:removeUnit(unit)
    for i, u in ipairs(self.units) do
        if u == unit then
            table.remove(self.units, i)
            
            -- Update selection if needed
            if self.selectedUnit == unit then
                self.selectedUnit = self.units[1] or nil
            end
            
            break
        end
    end
end

--- Get all units in this team
---@return table Array of Unit objects
function Team:getUnits()
    return self.units
end

--- Get only alive units in this team
---@return table Array of alive Unit objects
function Team:getAliveUnits()
    local alive = {}
    for _, unit in ipairs(self.units) do
        if unit:isAlive() then
            table.insert(alive, unit)
        end
    end
    return alive
end

--- Get number of units
---@return number
function Team:getUnitCount()
    return #self.units
end

--- Select a unit
---@param unit any Unit object
function Team:selectUnit(unit)
    if unit and unit.teamId == self.id then
        self.selectedUnit = unit
        return true
    end
    return false
end

--- Get currently selected unit
---@return any Unit object or nil
function Team:getSelectedUnit()
    return self.selectedUnit
end

--- Select next unit in team (cycle through units)
function Team:selectNextUnit()
    if #self.units == 0 then
        self.selectedUnit = nil
        return
    end
    
    if not self.selectedUnit then
        self.selectedUnit = self.units[1]
        return
    end
    
    -- Find current unit index
    for i, unit in ipairs(self.units) do
        if unit == self.selectedUnit then
            -- Select next unit (wrap around)
            local nextIndex = (i % #self.units) + 1
            self.selectedUnit = self.units[nextIndex]
            return
        end
    end
    
    -- Fallback to first unit
    self.selectedUnit = self.units[1]
end

--- Update all units in team
---@param dt number Delta time in seconds
function Team:update(dt)
    for _, unit in ipairs(self.units) do
        if unit.active then
            unit:update(dt)
        end
    end
end

--- Check if team has any active units
---@return boolean
function Team:hasActiveUnits()
    for _, unit in ipairs(self.units) do
        if unit.active and unit.health > 0 then
            return true
        end
    end
    return false
end

--- Get team color
---@return table RGBA color table
function Team:getColor()
    return self.color
end

--- Check if this is the player team
---@return boolean
function Team:isPlayer()
    return self.id == Constants.TEAM.PLAYER
end

--- Check if this team is allied with another team
---@param otherTeam Team Another team object
---@return boolean
function Team:isAlliedWith(otherTeam)
    if not otherTeam then return false end
    
    -- Player and Ally teams are allied
    if (self.id == Constants.TEAM.PLAYER and otherTeam.id == Constants.TEAM.ALLY) or
       (self.id == Constants.TEAM.ALLY and otherTeam.id == Constants.TEAM.PLAYER) then
        return true
    end
    
    -- Same team is allied
    if self.id == otherTeam.id then
        return true
    end
    
    return false
end

--- Check if this team is hostile to another team
---@param otherTeam Team Another team object
---@return boolean
function Team:isHostileTo(otherTeam)
    if not otherTeam then return false end
    
    -- Neutral is not hostile to anyone
    if self.id == Constants.TEAM.NEUTRAL or otherTeam.id == Constants.TEAM.NEUTRAL then
        return false
    end
    
    -- Not hostile to allies or self
    if self:isAlliedWith(otherTeam) then
        return false
    end
    
    return true
end

--- Convert to string for debugging
---@return string
function Team:toString()
    return string.format("Team[%s] - %d units", self.name, #self.units)
end

return Team
