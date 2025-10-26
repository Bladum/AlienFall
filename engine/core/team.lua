--- Team management system for battlescape
--- Handles team creation, unit management, and fog of war

local Team = {}

-- Team side constants
Team.SIDES = {
    PLAYER = "player",
    ALLY = "ally",
    ENEMY = "enemy"
}

---Create a new team
---@param name string Team identifier
---@param displayName string Human-readable name
---@param side string Team side (player/ally/enemy)
---@return table Team instance
function Team.new(name, displayName, side)
    local self = setmetatable({}, {__index = Team})

    self.name = name
    self.displayName = displayName or name
    self.side = side or Team.SIDES.ENEMY
    self.color = {1, 1, 1}  -- Default white, can be overridden

    -- Unit management
    self.units = {}  -- Array of unit IDs
    self.unitMap = {}  -- Map of unit ID -> unit object

    -- Fog of war
    self.visibility = {}  -- 2D array of visibility states

    print(string.format("[Team] Created team '%s' (%s)", self.name, self.side))

    return self
end

---Add a unit to this team
---@param unit table Unit object with id field
function Team:addUnit(unit)
    if not unit or not unit.id then
        print("[Team] ERROR: Cannot add unit without ID")
        return
    end

    if self.unitMap[unit.id] then
        print(string.format("[Team] Unit %s already in team %s", unit.id, self.name))
        return
    end

    table.insert(self.units, unit.id)
    self.unitMap[unit.id] = unit

    print(string.format("[Team] Added unit %s to team %s", unit.id, self.name))
end

---Remove a unit from this team
---@param unitId number Unit ID to remove
function Team:removeUnit(unitId)
    if not self.unitMap[unitId] then
        return
    end

    self.unitMap[unitId] = nil

    -- Remove from units array
    for i, id in ipairs(self.units) do
        if id == unitId then
            table.remove(self.units, i)
            break
        end
    end

    print(string.format("[Team] Removed unit %s from team %s", unitId, self.name))
end

---Get unit count
---@return number Number of units in team
function Team:getUnitCount()
    return #self.units
end

---Get maximum unit count (for campaign tracking)
---@return number Maximum units this team has had
function Team:getMaxUnitCount()
    -- For now, just return current count
    -- Could be extended to track historical max
    return #self.units
end

---Get all living units
---@param allUnits table Map of unitId -> unit object
---@return table Array of living unit objects
function Team:getLivingUnits(allUnits)
    local living = {}

    for _, unitId in ipairs(self.units) do
        local unit = allUnits[unitId]
        if unit and unit.alive then
            table.insert(living, unit)
        end
    end

    return living
end

---Initialize fog of war visibility grid
---@param width number Map width
---@param height number Map height
function Team:initializeVisibility(width, height)
    self.visibility = {}

    for y = 1, height do
        self.visibility[y] = {}
        for x = 1, width do
            self.visibility[y][x] = "hidden"  -- hidden, explored, visible
        end
    end

    print(string.format("[Team] Initialized FOW grid %dx%d for team %s", width, height, self.name))
end

---Update visibility from unit LOS calculations
---@param unit table|nil Unit that performed LOS (nil for team-wide update)
---@param visibleTiles table Array of {x, y} visible tiles
function Team:updateFromUnitLOS(unit, visibleTiles)
    if not visibleTiles then return end

    for _, tile in ipairs(visibleTiles) do
        local x, y = tile.x, tile.y

        if self.visibility[y] and self.visibility[y][x] then
            -- Mark as visible, or explored if was hidden
            if self.visibility[y][x] == "hidden" then
                self.visibility[y][x] = "explored"
            end
            self.visibility[y][x] = "visible"
        end
    end
end

---Get visibility state at coordinates
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return string Visibility state ("hidden", "explored", "visible")
function Team:getVisibility(x, y)
    if not self.visibility[y] then return "hidden" end
    return self.visibility[y][x] or "hidden"
end

---Check if team has any living units
---@param allUnits table Map of unitId -> unit object
---@return boolean True if team has living units
function Team:hasLivingUnits(allUnits)
    return #self:getLivingUnits(allUnits) > 0
end

---Get team status summary
---@return table Status info
function Team:getStatus()
    return {
        name = self.name,
        displayName = self.displayName,
        side = self.side,
        unitCount = #self.units,
        color = self.color
    }
end

-- Team Manager class
Team.Manager = {}

---Create a new team manager
---@return table TeamManager instance
function Team.Manager.new()
    local self = setmetatable({}, {__index = Team.Manager})

    self.teams = {}  -- Array of teams
    self.teamMap = {}  -- Map of team name -> team object

    print("[TeamManager] Created team manager")

    return self
end

---Add a team to the manager
---@param team table Team object
function Team.Manager:addTeam(team)
    if self.teamMap[team.name] then
        print(string.format("[TeamManager] Team %s already exists", team.name))
        return
    end

    table.insert(self.teams, team)
    self.teamMap[team.name] = team

    print(string.format("[TeamManager] Added team %s", team.name))
end

---Get team by name
---@param name string Team name
---@return table|nil Team object or nil
function Team.Manager:getTeam(name)
    return self.teamMap[name]
end

---Get all teams
---@return table Array of team objects
function Team.Manager:getAllTeams()
    return self.teams
end

---Get teams by side
---@param side string Team side
---@return table Array of teams with specified side
function Team.Manager:getTeamsBySide(side)
    local result = {}

    for _, team in ipairs(self.teams) do
        if team.side == side then
            table.insert(result, team)
        end
    end

    return result
end

---Initialize visibility for all teams
---@param width number Map width
---@param height number Map height
function Team.Manager:initializeVisibility(width, height)
    for _, team in ipairs(self.teams) do
        team:initializeVisibility(width, height)
    end

    print(string.format("[TeamManager] Initialized FOW for %d teams", #self.teams))
end

---Get team count
---@return number Number of teams
function Team.Manager:getTeamCount()
    return #self.teams
end

---Check if any team has living units
---@param allUnits table Map of unitId -> unit object
---@return boolean True if any team has living units
function Team.Manager:hasLivingTeams(allUnits)
    for _, team in ipairs(self.teams) do
        if team:hasLivingUnits(allUnits) then
            return true
        end
    end
    return false
end

return Team
