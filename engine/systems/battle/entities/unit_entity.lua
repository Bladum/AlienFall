-- unit_entity.lua
-- Unit entity definition with component composition
-- Part of ECS architecture for battle system

local Transform = require("systems.battle.components.transform")
local Movement = require("systems.battle.components.movement")
local Vision = require("systems.battle.components.vision")
local Health = require("systems.battle.components.health")
local TeamComponent = require("systems.battle.components.team")

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
