--- Squad Coordination System - Squad tactics and unit roles
---
--- Manages squad formations, unit roles (leader, heavy, medic, scout, support),
--- and coordination between squad members. Enables tactical squad-level AI
--- with formation control and role-based behaviors.
---
--- Key Features:
--- - Squad leader designation and command
--- - 5 unit role types (leader, heavy, medic, scout, support)
--- - Formation management (diamond, line, wedge, column)
--- - Role-specific tactical behaviors
--- - Squad cohesion tracking
---
--- Usage:
---   local Squad = require("engine.ai.squad_coordination")
---   local squad = Squad:new()
---   squad:designateLeader(units[1])
---   squad:assignRoles(units)
---   squad:arrangeFormation(units, "diamond", center_x, center_y)
---
--- @module engine.ai.squad_coordination
--- @author AlienFall Development Team

local SquadCoordination = {}
SquadCoordination.__index = SquadCoordination

--- Unit role types
SquadCoordination.ROLE_TYPES = {
    LEADER = "leader",      -- Commands squad, makes decisions
    HEAVY = "heavy",        -- Heavy weapons, tanking damage
    MEDIC = "medic",        -- Healing and support
    SCOUT = "scout",        -- Speed, reconnaissance, flanking
    SUPPORT = "support"     -- General combat support
}

--- Formation types
SquadCoordination.FORMATIONS = {
    DIAMOND = "diamond",    -- Flexible, good all-around
    LINE = "line",          -- Spread out for wide engagement
    WEDGE = "wedge",        -- Concentrated forward force
    COLUMN = "column"       -- Single file for narrow areas
}

--- Initialize Squad Coordination
---@return table SquadCoordination instance
function SquadCoordination:new()
    local self = setmetatable({}, SquadCoordination)
    self.squads = {}  -- {id = Squad table}
    self.nextSquadId = 1
    print("[SquadCoordination] Initialized")
    return self
end

--- Create a new squad
---@param units table Array of unit objects
---@param leader_index number? Index of leader unit (default: 1)
---@return table Squad object
function SquadCoordination:createSquad(units, leader_index)
    leader_index = leader_index or 1
    
    local squad = {
        id = "squad_" .. self.nextSquadId,
        units = units or {},
        leader = nil,
        formation = self.FORMATIONS.DIAMOND,
        roles = {},
        status = "idle",
        objective = nil,
        cohesion = 100  -- 0-100 (drops when units separated)
    }
    
    self.nextSquadId = self.nextSquadId + 1
    self.squads[squad.id] = squad
    
    -- Assign initial leader
    if units and units[leader_index] then
        self:designateLeader(squad, units[leader_index])
    end
    
    -- Auto-assign roles
    self:assignRoles(squad)
    
    print(string.format("[SquadCoordination] Created squad %s with %d units",
        squad.id, #(squad.units or {})))
    
    return squad
end

--- Designate squad leader
---
---@param squad table Squad object
---@param leader_unit table Unit to designate as leader
function SquadCoordination:designateLeader(squad, leader_unit)
    -- Remove old leader flag if exists
    if squad.leader then
        squad.leader.is_leader = false
        squad.leader.squad_role = nil
    end
    
    -- Set new leader
    squad.leader = leader_unit
    leader_unit.is_leader = true
    leader_unit.squad_role = self.ROLE_TYPES.LEADER
    leader_unit.squad_id = squad.id
    
    print(string.format("[SquadCoordination] %s designated as squad leader",
        leader_unit.name or "Unit"))
end

--- Assign roles to squad members
---
--- Auto-assigns roles based on unit equipment and stats.
---
---@param squad table Squad object
function SquadCoordination:assignRoles(squad)
    for _, unit in ipairs(squad.units or {}) do
        if not unit.is_leader then
            local role = self:selectRoleForUnit(unit)
            self:assignRole(squad, unit, role)
        end
    end
end

--- Select optimal role for a unit
---
---@param unit table Unit to evaluate
---@return string Role type
function SquadCoordination:selectRoleForUnit(unit)
    -- Check equipment and stats
    local has_heavy_weapon = (unit.hasWeapon and unit:hasWeapon("heavy")) or false
    local has_medical_kit = (unit.hasEquipment and unit:hasEquipment("medical")) or false
    local experience = unit.experience_level or 0
    local speed = unit.speed or 8
    local max_speed = 12  -- Assume max speed for comparison
    
    -- Decision logic (priority order)
    if has_heavy_weapon then
        return self.ROLE_TYPES.HEAVY
    elseif has_medical_kit then
        return self.ROLE_TYPES.MEDIC
    elseif speed > (max_speed * 0.8) then
        return self.ROLE_TYPES.SCOUT
    else
        return self.ROLE_TYPES.SUPPORT
    end
end

--- Assign role to unit
---
---@param squad table Squad object
---@param unit table Unit to assign
---@param role string Role type from ROLE_TYPES
function SquadCoordination:assignRole(squad, unit, role)
    unit.squad_role = role
    unit.squad_id = squad.id
    squad.roles[role] = (squad.roles[role] or 0) + 1
    
    print(string.format("[SquadCoordination] %s assigned role: %s",
        unit.name or "Unit", role))
end

--- Arrange squad in formation
---
---@param squad table Squad object
---@param formation string Formation type
---@param center_x number Formation center X
---@param center_y number Formation center Y
function SquadCoordination:arrangeFormation(squad, formation, center_x, center_y)
    formation = formation or self.FORMATIONS.DIAMOND
    
    local positions = self:getFormationPositions(#(squad.units or 0), formation, center_x, center_y)
    
    -- Assign positions to units
    for i, unit in ipairs(squad.units or {}) do
        if positions[i] then
            unit.target_x = positions[i].x
            unit.target_y = positions[i].y
            unit.in_formation = true
        end
    end
    
    squad.formation = formation
    
    print(string.format("[SquadCoordination] Squad %s arranged in %s formation",
        squad.id, formation))
end

--- Get formation positions for squad size
---
---@param squad_size number Number of units
---@param formation string Formation type
---@param center_x number Center X
---@param center_y number Center Y
---@return table Array of {x, y} positions
function SquadCoordination:getFormationPositions(squad_size, formation, center_x, center_y)
    local positions = {}
    
    if formation == self.FORMATIONS.DIAMOND then
        -- Diamond: flexible, good all-around
        positions = {
            {x = center_x, y = center_y - 2},           -- Front
            {x = center_x - 2, y = center_y},           -- Left
            {x = center_x + 2, y = center_y},           -- Right
            {x = center_x, y = center_y + 2},           -- Back
            {x = center_x - 1, y = center_y + 1},       -- Back-left
            {x = center_x + 1, y = center_y + 1}        -- Back-right
        }
    elseif formation == self.FORMATIONS.LINE then
        -- Line: wide engagement
        for i = 1, squad_size do
            local offset = i - math.ceil(squad_size / 2)
            table.insert(positions, {
                x = center_x + offset,
                y = center_y
            })
        end
    elseif formation == self.FORMATIONS.WEDGE then
        -- Wedge: concentrated forward attack
        positions = {
            {x = center_x, y = center_y - 3},           -- Point
            {x = center_x - 1, y = center_y - 2},       -- Upper-left
            {x = center_x + 1, y = center_y - 2},       -- Upper-right
            {x = center_x - 2, y = center_y},           -- Left
            {x = center_x + 2, y = center_y},           -- Right
            {x = center_x - 1, y = center_y + 1}        -- Lower-left
        }
    elseif formation == self.FORMATIONS.COLUMN then
        -- Column: single file for narrow areas
        for i = 1, squad_size do
            table.insert(positions, {
                x = center_x,
                y = center_y - math.ceil(squad_size / 2) + i
            })
        end
    end
    
    return positions
end

--- Recommend best formation for situation
---
---@param squad table Squad object
---@param situation table Battle situation (enemy_count, terrain_type, etc)
---@return string Recommended formation
function SquadCoordination:recommendFormation(squad, situation)
    situation = situation or {}
    
    if situation.in_corridor or situation.narrow_space then
        return self.FORMATIONS.COLUMN  -- Single file
    elseif (situation.enemy_count or 1) > 5 then
        return self.FORMATIONS.LINE  -- Spread out
    elseif situation.enemy_count == 1 or situation.in_open then
        return self.FORMATIONS.WEDGE  -- Concentrated attack
    else
        return self.FORMATIONS.DIAMOND  -- Default flexible
    end
end

--- Get role-based tactical action for unit
---
---@param unit table Unit performing action
---@param squad table Squad object
---@param situation table Battle situation
---@return table Recommended action
function SquadCoordination:getRoleAction(unit, squad, situation)
    local role = unit.squad_role or self.ROLE_TYPES.SUPPORT
    situation = situation or {}
    
    if role == self.ROLE_TYPES.LEADER then
        return self:getLeaderAction(unit, squad, situation)
    elseif role == self.ROLE_TYPES.HEAVY then
        return self:getHeavyAction(unit, squad, situation)
    elseif role == self.ROLE_TYPES.MEDIC then
        return self:getMedicAction(unit, squad, situation)
    elseif role == self.ROLE_TYPES.SCOUT then
        return self:getScoutAction(unit, squad, situation)
    else
        return self:getSupportAction(unit, squad, situation)
    end
end

--- Leader tactical action
function SquadCoordination:getLeaderAction(unit, squad, situation)
    -- Priority 1: Heal injured squad members
    for _, member in ipairs(squad.units or {}) do
        if member.hp and member.max_hp and member.hp < member.max_hp * 0.3 then
            -- Order medic to help
            if squad.roles[self.ROLE_TYPES.MEDIC] and squad.roles[self.ROLE_TYPES.MEDIC] > 0 then
                return {
                    type = "order",
                    command = "heal",
                    target = member,
                    description = "Rally: medic heal this unit"
                }
            end
        end
    end
    
    -- Priority 2: Move to best cover/position
    return {
        type = "move",
        x = situation.best_cover_x or unit.x,
        y = situation.best_cover_y or unit.y,
        description = "Lead from strong position"
    }
end

--- Heavy trooper tactical action
function SquadCoordination:getHeavyAction(unit, squad, situation)
    -- Heavy focuses on suppression and crowd control
    if situation.enemy_group and situation.enemy_group[1] then
        return {
            type = "shoot",
            target = situation.enemy_group[1],
            weapon_type = "heavy",
            suppress = true,
            description = "Suppressive fire"
        }
    end
    
    return {type = "wait", description = "Ready heavy weapon"}
end

--- Medic tactical action
function SquadCoordination:getMedicAction(unit, squad, situation)
    -- Find most injured unit
    local injured = nil
    local lowest_hp = 101
    
    for _, member in ipairs(squad.units or {}) do
        if member.hp and member.max_hp then
            local hp_ratio = member.hp / member.max_hp
            if hp_ratio < lowest_hp and member ~= unit then
                injured = member
                lowest_hp = hp_ratio
            end
        end
    end
    
    if injured and lowest_hp < 0.8 then
        return {
            type = "heal",
            target = injured,
            description = "Provide medical support"
        }
    elseif situation.squad_center_x then
        return {
            type = "move",
            x = situation.squad_center_x,
            y = situation.squad_center_y or unit.y,
            description = "Stay with squad"
        }
    else
        return {type = "wait", description = "Stand ready"}
    end
end

--- Scout tactical action
function SquadCoordination:getScoutAction(unit, squad, situation)
    -- Scout prioritizes flanking and reconnaissance
    if situation.flank_position_x then
        return {
            type = "move",
            x = situation.flank_position_x,
            y = situation.flank_position_y,
            description = "Move to flank position"
        }
    elseif situation.unexplored_area then
        return {
            type = "scout",
            x = situation.unexplored_area.x,
            y = situation.unexplored_area.y,
            description = "Scout ahead"
        }
    else
        return {
            type = "move",
            x = situation.enemy_x or unit.x,
            y = situation.enemy_y or unit.y,
            description = "Move toward enemy"
        }
    end
end

--- Support trooper tactical action
function SquadCoordination:getSupportAction(unit, squad, situation)
    -- General combat support
    if situation.nearest_threat_x then
        return {
            type = "shoot",
            x = situation.nearest_threat_x,
            y = situation.nearest_threat_y,
            description = "Engage nearest threat"
        }
    else
        return {type = "wait", description = "Ready weapon"}
    end
end

--- Update squad cohesion
---
--- Drops when units are separated or members lost.
---
---@param squad table Squad object
function SquadCoordination:updateCohesion(squad)
    local cohesion = 100
    
    -- Penalty for separated units
    if squad.units and #squad.units > 1 then
        local max_distance = 0
        for i = 1, #squad.units do
            for j = i + 1, #squad.units do
                local unit1 = squad.units[i]
                local unit2 = squad.units[j]
                if unit1 and unit2 then
                    local dist = math.sqrt(
                        (unit1.x - unit2.x) ^ 2 + (unit1.y - unit2.y) ^ 2
                    )
                    max_distance = math.max(max_distance, dist)
                end
            end
        end
        
        -- Cohesion penalty for large separation
        if max_distance > 10 then
            cohesion = cohesion - 30
        elseif max_distance > 5 then
            cohesion = cohesion - 15
        end
    end
    
    -- Penalty for casualties
    if squad.initial_size and #(squad.units or {}) < squad.initial_size then
        local lost = squad.initial_size - #squad.units
        cohesion = cohesion - (lost * 20)
    end
    
    squad.cohesion = math.max(0, math.min(100, cohesion))
end

--- Get squad status summary
---
---@param squad table Squad object
---@return string Status text
function SquadCoordination:getStatus(squad)
    local status = string.format(
        "Squad Status: %d units, Formation: %s, Cohesion: %d%%",
        #(squad.units or 0),
        squad.formation or "none",
        squad.cohesion or 100
    )
    
    -- Add role breakdown
    if squad.roles then
        local role_text = {}
        for role, count in pairs(squad.roles) do
            if count > 0 then
                table.insert(role_text, string.format("%s×%d", role:sub(1,1), count))
            end
        end
        if #role_text > 0 then
            status = status .. " [" .. table.concat(role_text, ", ") .. "]"
        end
    end
    
    return status
end

return SquadCoordination



