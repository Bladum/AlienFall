-- Team System
-- Manages teams, sides, and team-based gameplay

local Team = {}
Team.__index = Team

-- Team sides (determines turn order)
Team.SIDES = {
    PLAYER = "player",
    ALLY = "ally",
    ENEMY = "enemy",
    NEUTRAL = "neutral"
}

-- Side priority for turn order (lower number = higher priority)
Team.SIDE_PRIORITY = {
    [Team.SIDES.PLAYER] = 1,
    [Team.SIDES.ALLY] = 2,
    [Team.SIDES.ENEMY] = 3,
    [Team.SIDES.NEUTRAL] = 4
}

-- Create a new team
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

-- Get default color for team side
function Team.getDefaultColor(side)
    local colors = {
        [Team.SIDES.PLAYER] = {0.2, 0.7, 0.3},    -- Green
        [Team.SIDES.ALLY] = {0.3, 0.5, 0.9},      -- Blue
        [Team.SIDES.ENEMY] = {0.9, 0.3, 0.2},     -- Red
        [Team.SIDES.NEUTRAL] = {0.7, 0.7, 0.7}    -- Gray
    }
    return colors[side] or {1, 1, 1}
end

-- Add unit to team
function Team:addUnit(unit)
    if unit and unit.id then
        table.insert(self.units, unit.id)
        unit.team = self.id
        print(string.format("[Team] Added unit %s to team %s", unit.name, self.name))
    end
end

-- Remove unit from team
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

-- Get all living units in team
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

-- Check if team has living units
function Team:hasLivingUnits(allUnits)
    return #self:getLivingUnits(allUnits) > 0
end

-- Check if team can take turn (has living units and is active)
function Team:canTakeTurn(allUnits)
    return self.active and self:hasLivingUnits(allUnits)
end

-- Initialize visibility map
function Team:initializeVisibility(mapWidth, mapHeight)
    self.visibility = {}
    for y = 1, mapHeight do
        self.visibility[y] = {}
        for x = 1, mapWidth do
            self.visibility[y][x] = "hidden"
        end
    end
end

-- Update visibility for a tile
function Team:updateVisibility(x, y, state)
    if self.visibility[y] then
        self.visibility[y][x] = state
    end
end

-- Get visibility state for a tile
function Team:getVisibility(x, y)
    if self.visibility[y] then
        return self.visibility[y][x] or "hidden"
    end
    return "hidden"
end

-- Check if tile is visible to team
function Team:isTileVisible(x, y)
    return self:getVisibility(x, y) == "visible"
end

-- Check if tile is explored by team
function Team:isTileExplored(x, y)
    local state = self:getVisibility(x, y)
    return state == "explored" or state == "visible"
end

-- Reset visibility to explored (for turn transitions)
function Team:resetVisibilityToExplored()
    for y, row in ipairs(self.visibility) do
        for x, state in ipairs(row) do
            if state == "visible" then
                self.visibility[y][x] = "explored"
            end
        end
    end
end

-- Update team visibility from unit LOS
function Team:updateFromUnitLOS(unit, visibleTiles)
    -- Reset previous visible tiles to explored
    self:resetVisibilityToExplored()

    -- Mark currently visible tiles
    for _, tile in ipairs(visibleTiles) do
        self:updateVisibility(tile.x, tile.y, "visible")
    end
end

-- Get team stats
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

-- Get team debug info
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

-- Team Manager (handles multiple teams)
local TeamManager = {}

-- Create team manager
function TeamManager.new()
    local self = setmetatable({}, {__index = TeamManager})

    self.teams = {}  -- {teamId = team}
    self.teamsList = {}  -- Ordered list for turn management

    return self
end

-- Add team
function TeamManager:addTeam(team)
    self.teams[team.id] = team
    table.insert(self.teamsList, team)
    self:sortTeamsByTurnOrder()
end

-- Get team by ID
function TeamManager:getTeam(teamId)
    return self.teams[teamId]
end

-- Get all teams
function TeamManager:getAllTeams()
    return self.teamsList
end

-- Sort teams by turn order (side priority)
function TeamManager:sortTeamsByTurnOrder()
    table.sort(self.teamsList, function(a, b)
        local priorityA = Team.SIDE_PRIORITY[a.side] or 999
        local priorityB = Team.SIDE_PRIORITY[b.side] or 999
        return priorityA < priorityB
    end)
end

-- Get teams that can take turns
function TeamManager:getActiveTeams(allUnits)
    local active = {}
    for _, team in ipairs(self.teamsList) do
        if team:canTakeTurn(allUnits) then
            table.insert(active, team)
        end
    end
    return active
end

-- Initialize visibility for all teams
function TeamManager:initializeVisibility(mapWidth, mapHeight)
    for _, team in ipairs(self.teamsList) do
        team:initializeVisibility(mapWidth, mapHeight)
    end
end

-- Update visibility for all teams from their units
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

-- Get debug info for all teams
function TeamManager:getDebugInfo(allUnits)
    local info = "Team Manager:\n"
    for _, team in ipairs(self.teamsList) do
        info = info .. team:getDebugInfo(allUnits) .. "\n"
    end
    return info
end

Team.Manager = TeamManager

return Team