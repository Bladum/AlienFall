-- team.lua
-- Team affiliation data component (pure data)
-- Part of ECS architecture for battle system

local TeamComponent = {}

-- Create a new team component
-- @param teamId number: Team identifier (1 = player, 2+ = AI)
-- @param name string: Team display name
-- @return table: Team component
function TeamComponent.new(teamId, name)
    return {
        teamId = teamId or 1,
        name = name or "Unknown",
        isPlayer = (teamId == 1),
        isAI = (teamId ~= 1),
        color = TeamComponent.getTeamColor(teamId)
    }
end

-- Get standard team color
function TeamComponent.getTeamColor(teamId)
    local colors = {
        {r = 0, g = 128, b = 255},    -- Player: Blue
        {r = 255, g = 64, b = 64},    -- Enemy 1: Red
        {r = 255, g = 128, b = 0},    -- Enemy 2: Orange
        {r = 128, g = 0, b = 255}     -- Enemy 3: Purple
    }
    return colors[teamId] or {r = 128, g = 128, b = 128}
end

-- Check if two teams are hostile
function TeamComponent.areHostile(team1, team2)
    if not team1 or not team2 then
        return false
    end
    return team1.teamId ~= team2.teamId
end

-- Check if two teams are allies
function TeamComponent.areAllies(team1, team2)
    if not team1 or not team2 then
        return false
    end
    return team1.teamId == team2.teamId
end

return TeamComponent
