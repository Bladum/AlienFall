--- Team System
--- Manages teams, sides, and team-based gameplay.
---
--- This module provides Team and TeamManager classes for organizing units
--- into sides (player, ally, enemy, neutral) and managing turn order,
--- visibility, and team statistics.
---
--- Example usage:
---   local Team = require("systems.team")
---   local playerTeam = Team.new("team1", "XCOM", Team.SIDES.PLAYER)
---   playerTeam:addUnit(soldier)
---   local canTakeTurn = playerTeam:canTakeTurn(allUnits)
---
--- Team Manager usage:
---   local manager = Team.Manager.new()
---   manager:addTeam(playerTeam)
---   manager:initializeVisibility(mapWidth, mapHeight)

--- @class Team
--- @field id string Unique team identifier
--- @field name string Display name
--- @field side string Team side (player/ally/enemy/neutral)
--- @field units table Array of unit IDs in this team
--- @field visibility table 2D array of fog states per tile
--- @field color table RGB color {r, g, b} for UI display
--- @field active boolean Whether team can take turns
local Team = {}
Team.__index = Team

--- Team side constants for gameplay organization.
--- Determines turn order and default colors.
Team.SIDES = {
    PLAYER = "player",    -- Player-controlled units
    ALLY = "ally",        -- Allied AI units
    ENEMY = "enemy",      -- Enemy AI units
    NEUTRAL = "neutral"   -- Neutral/civilian units
}

--- Side priority for turn order.
--- Lower numbers take turns first. Player always goes first.
Team.SIDE_PRIORITY = {
    [Team.SIDES.PLAYER] = 1,
    [Team.SIDES.ALLY] = 2,
    [Team.SIDES.ENEMY] = 3,
    [Team.SIDES.NEUTRAL] = 4
}

--- Create a new team instance.
---
--- Initializes team with ID, name, and side. Sets default color
--- based on side and initializes empty unit list.
---
--- @param id string Unique identifier for this team
--- @param name string Display name (e.g., "XCOM", "Aliens")
--- @param side string Team side from Team.SIDES constants
--- @return Team New team instance
function Team.new(id, name, side)
    local self = setmetatable({}, Team)

    self.id = id
    self.name = name
    self.side = side

    -- Units in this team
    self.units = {}  -- List of unit IDs

    -- Visibility map (2D array of fog states)
    self.visibility = {}  -- Will be initialized by battlefield

    -- Team properties
    self.color = Team.getDefaultColor(side)
    self.active = true  -- Whether team can take turns

    return self
end

--- Get default color for team side.
---
--- Returns RGB color table {r, g, b} with values 0-1.
--- Player=green, ally=blue, enemy=red, neutral=gray.
---
--- @param side string Team side constant
--- @return table RGB color {r, g, b}
function Team.getDefaultColor(side)
    local colors = {
        [Team.SIDES.PLAYER] = {0.2, 0.7, 0.3},    -- Green
        [Team.SIDES.ALLY] = {0.3, 0.5, 0.9},      -- Blue
        [Team.SIDES.ENEMY] = {0.9, 0.3, 0.2},     -- Red
        [Team.SIDES.NEUTRAL] = {0.7, 0.7, 0.7}    -- Gray
    }
    return colors[side] or {1, 1, 1}
end

--- Add unit to this team.
---
--- Adds unit ID to team's unit list and sets unit.team property.
--- Prints debug message.
---
--- @param unit table Unit instance with id and name fields
--- @return nil
function Team:addUnit(unit)
    if unit and unit.id then
        table.insert(self.units, unit.id)
        unit.team = self.id
        print(string.format("[Team] Added unit %s to team %s", unit.name, self.name))
    end
end

--- Remove unit from this team by ID.
---
--- Removes unit ID from team's unit list. Returns true if found.
---
--- @param unitId number Unit ID to remove
--- @return boolean True if unit was found and removed
function Team:removeUnit(unitId)
    for i, id in ipairs(self.units) do
        if id == unitId then
            table.remove(self.units, i)
            print(string.format("[Team] Removed unit %s from team %s", unitId, self.name))
            return true
        end
    end
    return false
end

--- Get all living units in this team.
---
--- Filters team's unit IDs and returns only units with alive=true.
---
--- @param allUnits table Map of unitId -> unit from battlefield
--- @return table Array of living unit instances
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

--- Check if team has any living units.
---
--- @param allUnits table Map of unitId -> unit from battlefield
--- @return boolean True if team has at least one living unit
function Team:hasLivingUnits(allUnits)
    return #self:getLivingUnits(allUnits) > 0
end

--- Check if team can take turn this round.
---
--- Returns true if team is active and has living units.
---
--- @param allUnits table Map of unitId -> unit from battlefield
--- @return boolean True if team can take turn
function Team:canTakeTurn(allUnits)
    return self.active and self:hasLivingUnits(allUnits)
end

--- Initialize visibility map for this team.
---
--- Creates 2D array mapHeight × mapWidth with all tiles set to "hidden".
--- Called once during battlefield initialization.
---
--- @param mapWidth number Map width in tiles
--- @param mapHeight number Map height in tiles
--- @return nil
function Team:initializeVisibility(mapWidth, mapHeight)
    self.visibility = {}
    for y = 1, mapHeight do
        self.visibility[y] = {}
        for x = 1, mapWidth do
            self.visibility[y][x] = "hidden"
        end
    end
end

--- Update visibility state for a specific tile.
---
--- Sets visibility[y][x] to state ("hidden", "explored", or "visible").
---
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @param state string Visibility state
--- @return nil
function Team:updateVisibility(x, y, state)
    if self.visibility[y] then
        self.visibility[y][x] = state
    end
end

--- Get visibility state for a specific tile.
---
--- Returns "hidden", "explored", or "visible". Returns "hidden" if out of bounds.
---
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @return string Visibility state
function Team:getVisibility(x, y)
    if self.visibility[y] then
        return self.visibility[y][x] or "hidden"
    end
    return "hidden"
end

--- Check if tile is currently visible to team.
---
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @return boolean True if tile is visible
function Team:isTileVisible(x, y)
    return self:getVisibility(x, y) == "visible"
end

--- Check if tile has been explored by team.
---
--- Returns true if tile is either explored or visible.
---
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @return boolean True if tile is explored or visible
function Team:isTileExplored(x, y)
    local state = self:getVisibility(x, y)
    return state == "explored" or state == "visible"
end

--- Reset all visible tiles to explored state.
---
--- Called during turn transitions to convert "visible" to "explored"
--- while preserving exploration progress. Then new visible tiles
--- are calculated for active units.
---
--- @return nil
function Team:resetVisibilityToExplored()
    for y, row in ipairs(self.visibility) do
        for x, state in ipairs(row) do
            if state == "visible" then
                self.visibility[y][x] = "explored"
            end
        end
    end
end

--- Update team visibility from unit line of sight.
---
--- Resets current visible tiles to explored, then marks tiles
--- in visibleTiles array as visible.
---
--- @param unit table Unit instance (currently unused)
--- @param visibleTiles table Array of {x, y} tiles
--- @return nil
function Team:updateFromUnitLOS(unit, visibleTiles)
    -- Reset previous visible tiles to explored
    self:resetVisibilityToExplored()

    -- Mark currently visible tiles
    for _, tile in ipairs(visibleTiles) do
        self:updateVisibility(tile.x, tile.y, "visible")
    end
end

--- Get team statistics summary.
---
--- Returns table with totalUnits, livingUnits, totalHealth, maxHealth.
---
--- @param allUnits table Map of unitId -> unit from battlefield
--- @return table Stats table
function Team:getStats(allUnits)
    local stats = {
        totalUnits = #self.units,
        livingUnits = 0,
        totalHealth = 0,
        maxHealth = 0
    }

    local living = self:getLivingUnits(allUnits)
    stats.livingUnits = #living

    for _, unit in ipairs(living) do
        stats.totalHealth = stats.totalHealth + unit.health
        stats.maxHealth = stats.maxHealth + unit.maxHealth
    end

    return stats
end

--- Get debug information string for this team.
---
--- Returns multi-line string with team name, side, active status,
--- unit count, health totals, and unit IDs.
---
--- @param allUnits table Map of unitId -> unit from battlefield
--- @return string Multi-line debug info
function Team:getDebugInfo(allUnits)
    local info = string.format("Team: %s (%s)\n", self.name, self.side)
    info = info .. string.format("Active: %s\n", tostring(self.active))

    local stats = self:getStats(allUnits)
    info = info .. string.format("Units: %d/%d living\n", stats.livingUnits, stats.totalUnits)
    info = info .. string.format("Health: %d/%d\n", stats.totalHealth, stats.maxHealth)

    if #self.units > 0 then
        info = info .. "Unit IDs: "
        for _, unitId in ipairs(self.units) do
            info = info .. unitId .. " "
        end
        info = info .. "\n"
    end

    return info
end

--- Team Manager - Manages multiple teams and turn order.
---
--- Provides centralized management of all teams in a battle,
--- including turn order sorting and visibility aggregation.
---
--- @class TeamManager
--- @field teams table Map of teamId -> team
--- @field teamsList table Ordered array of teams for turn management
local TeamManager = {}

--- Create new team manager instance.
---
--- @return TeamManager New manager instance
function TeamManager.new()
    local self = setmetatable({}, {__index = TeamManager})

    self.teams = {}  -- {teamId = team}
    self.teamsList = {}  -- Ordered list for turn management

    return self
end

--- Add team to manager. @param team table Team instance @return nil
function TeamManager:addTeam(team)
    self.teams[team.id] = team
    table.insert(self.teamsList, team)
    self:sortTeamsByTurnOrder()
end

--- Get team by ID. @param teamId string Team ID @return table|nil Team or nil
function TeamManager:getTeam(teamId)
    return self.teams[teamId]
end

--- Get all teams. @return table Array of teams
function TeamManager:getAllTeams()
    return self.teamsList
end

--- Sort teams by turn order based on side priority. @return nil
function TeamManager:sortTeamsByTurnOrder()
    table.sort(self.teamsList, function(a, b)
        local priorityA = Team.SIDE_PRIORITY[a.side] or 999
        local priorityB = Team.SIDE_PRIORITY[b.side] or 999
        return priorityA < priorityB
    end)
end

--- Get teams that can take turns. @param allUnits table Unit map @return table Active teams
function TeamManager:getActiveTeams(allUnits)
    local active = {}
    for _, team in ipairs(self.teamsList) do
        if team:canTakeTurn(allUnits) then
            table.insert(active, team)
        end
    end
    return active
end

--- Initialize visibility for all teams. @param mapWidth number @param mapHeight number @return nil
function TeamManager:initializeVisibility(mapWidth, mapHeight)
    for _, team in ipairs(self.teamsList) do
        team:initializeVisibility(mapWidth, mapHeight)
    end
end

--- Update visibility for all teams from their units' LOS. @param allUnits table @param losSystem table @param battlefield table @return nil
function TeamManager:updateVisibility(allUnits, losSystem, battlefield)
    for _, team in ipairs(self.teamsList) do
        if team.active then
            local livingUnits = team:getLivingUnits(allUnits)
            local allVisible = {}

            -- Aggregate visibility from all units in team
            for _, unit in ipairs(livingUnits) do
                local visible = losSystem:calculateVisibilityForUnit(unit, battlefield)
                for _, tile in ipairs(visible) do
                    allVisible[string.format("%d,%d", tile.x, tile.y)] = tile
                end
            end

            -- Convert back to array
            local visibleArray = {}
            for _, tile in pairs(allVisible) do
                table.insert(visibleArray, tile)
            end

            -- Update team visibility
            team:updateFromUnitLOS(nil, visibleArray)
        end
    end
end

--- Get debug info for all teams. @param allUnits table Unit map @return string Multi-line debug info
function TeamManager:getDebugInfo(allUnits)
    local info = "Team Manager:\n"
    for _, team in ipairs(self.teamsList) do
        info = info .. team:getDebugInfo(allUnits) .. "\n"
    end
    return info
end

Team.Manager = TeamManager

return Team