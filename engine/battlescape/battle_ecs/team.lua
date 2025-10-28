---Team - Team Affiliation Component (ECS)
---
---Pure data component storing unit team membership and faction. Part of the
---ECS (Entity-Component-System) battle architecture. Determines allegiances,
---friend/foe identification, and AI behavior.
---
---Features:
---  - Team ID (1=player, 2+=AI teams)
---  - Team name/faction
---  - Player flag (convenience)
---  - Faction allegiance
---  - Color coding
---
---Component Data:
---  - teamId: Numeric team identifier
---  - name: Team display name ("XCOM", "Aliens", etc.)
---  - isPlayer: Boolean flag (true if teamId == 1)
---  - faction: Faction reference
---  - color: Team color for UI
---
---Team Assignments:
---  - Team 1: Player (XCOM)
---  - Team 2: Primary enemies (Aliens)
---  - Team 3+: Other factions (Civilians, Hostiles)
---
---Key Exports:
---  - TeamComponent.new(teamId, name): Creates team component
---  - isEnemy(team1, team2): Returns true if hostile
---  - isFriendly(team1, team2): Returns true if allied
---  - setFaction(team, faction): Assigns faction
---
---Dependencies:
---  - None (pure data component)
---
---@module battlescape.battle_ecs.team
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TeamComponent = require("battlescape.battle_ecs.team")
---  local team = TeamComponent.new(1, "XCOM")
---  if team.isPlayer then print("Player unit") end
---
---@see battlescape.battle_ecs.unit_entity For usage
---@see core.team For legacy team system

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
