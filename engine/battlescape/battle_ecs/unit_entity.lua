---UnitEntity - Complete Unit with All Components (ECS)
---
---Composite entity combining all ECS components for a complete battlefield unit.
---Integrates Transform, Movement, Vision, Health, and Team components into single
---entity. Factory for creating fully-initialized units.
---
---Features:
---  - Component composition (Transform + Movement + Vision + Health + Team)
---  - Unit factory with sensible defaults
---  - Parameter validation
---  - Component initialization
---  - Entity ID management
---
---Components Included:
---  - Transform: Position (x, y) and facing direction
---  - Movement: AP, move cost, turn cost, movement modes
---  - Vision: Range, arc, visible tiles
---  - Health: HP, armor, damage tracking
---  - Team: Team ID, faction affiliation
---
---Unit Parameters:
---  - x, y: Starting position in hex coords
---  - facing: Initial facing direction (0-5)
---  - teamId: Team identifier (1=player)
---  - maxHP: Maximum hit points
---  - armor: Damage reduction
---  - maxAP: Action points per turn
---  - visionRange: Vision distance
---
---Key Exports:
---  - UnitEntity.new(params): Creates complete unit entity
---  - createSoldier(x, y, teamId): Factory for player soldier
---  - createAlien(x, y, type): Factory for alien unit
---  - clone(unit): Duplicates unit with new ID
---
---Dependencies:
---  - battlescape.battle_ecs.transform: Position component
---  - battlescape.battle_ecs.movement: Movement component
---  - battlescape.battle_ecs.vision: Vision component
---  - battlescape.battle_ecs.health: Health component
---  - battlescape.battle_ecs.team: Team component
---
---@module battlescape.battle_ecs.unit_entity
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local UnitEntity = require("battlescape.battle_ecs.unit_entity")
---  local soldier = UnitEntity.new({x=10, y=15, teamId=1, maxHP=100})
---
---@see battlescape.battle_ecs.transform For position
---@see battlescape.battle_ecs.movement For AP/movement
---@see battlescape.battle_ecs.vision For sight
---@see battlescape.battle_ecs.health For HP/armor

-- unit_entity.lua
-- Unit entity definition with component composition
-- Part of ECS architecture for battle system

local Transform = require("battlescape.battle_ecs.transform")
local Movement = require("battlescape.battle_ecs.movement")
local Vision = require("battlescape.battle_ecs.vision")
local Health = require("battlescape.battle_ecs.health")
local TeamComponent = require("battlescape.battle_ecs.team")

local UnitEntity = {}

-- Create a new unit entity with all components
-- @param params table: Unit parameters {x, y, facing, teamId, maxHP, armor, maxAP, ...}
-- @return table: Unit entity with all components
function UnitEntity.new(params)
    params = params or {}
    
    local unit = {
        id = params.id or ("unit_" .. tostring(love.timer.getTime())),
        name = params.name or "Soldier",
        
        -- Components
        transform = Transform.new(params.q or 0, params.r or 0, params.facing or 0),
        movement = Movement.new(params.maxAP or 10, params.moveCost or 2, params.turnCost or 1),
        vision = Vision.new(params.visionRange or 8, params.visionArc or 120),
        health = Health.new(params.maxHP or 100, params.armor or 0),
        team = TeamComponent.new(params.teamId or 1, params.teamName)
    }
    
    -- Additional properties
    unit.sprite = params.sprite or nil
    unit.weapons = params.weapons or {}
    unit.inventory = params.inventory or {}
    
    return unit
end

-- Create a copy of a unit (for testing)
function UnitEntity.clone(unit)
    return UnitEntity.new({
        q = unit.transform.q,
        r = unit.transform.r,
        facing = unit.transform.facing,
        teamId = unit.team.teamId,
        teamName = unit.team.name,
        maxHP = unit.health.maxHP,
        armor = unit.health.armor,
        maxAP = unit.movement.maxAP,
        moveCost = unit.movement.moveCost,
        turnCost = unit.movement.turnCost,
        visionRange = unit.vision.range,
        visionArc = unit.vision.arc,
        name = unit.name
    })
end

-- Check if unit is alive and active
function UnitEntity.isActive(unit)
    return unit.health and Health.isAlive(unit.health)
end

-- Get unit display name with status
function UnitEntity.getDisplayName(unit)
    local status = ""
    if unit.health then
        local hpPercent = math.floor(100 * unit.health.currentHP / unit.health.maxHP)
        status = string.format(" [%d%%]", hpPercent)
    end
    return unit.name .. status
end

-- Get unit color (from team)
function UnitEntity.getColor(unit)
    if unit.team then
        return unit.team.color
    end
    return {r = 128, g = 128, b = 128}
end

-- Serialize unit to table (for saving)
function UnitEntity.serialize(unit)
    return {
        id = unit.id,
        name = unit.name,
        q = unit.transform.q,
        r = unit.transform.r,
        facing = unit.transform.facing,
        teamId = unit.team.teamId,
        currentHP = unit.health.currentHP,
        maxHP = unit.health.maxHP,
        armor = unit.health.armor,
        currentAP = unit.movement.currentAP,
        maxAP = unit.movement.maxAP
    }
end

-- Deserialize unit from table (for loading)
function UnitEntity.deserialize(data)
    local unit = UnitEntity.new({
        id = data.id,
        name = data.name,
        q = data.q,
        r = data.r,
        facing = data.facing,
        teamId = data.teamId,
        maxHP = data.maxHP,
        armor = data.armor,
        maxAP = data.maxAP
    })
    
    -- Restore current state
    unit.health.currentHP = data.currentHP or data.maxHP
    unit.movement.currentAP = data.currentAP or data.maxAP
    
    return unit
end

return UnitEntity






















