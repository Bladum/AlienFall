---Transform - Position and Spatial Component (ECS)
---
---Pure data component storing unit position, facing, and spatial data. Part of
---the ECS (Entity-Component-System) battle architecture. Core component for all
---entities requiring location and orientation.
---
---Features:
---  - Hex coordinate position (x, y)
---  - Facing direction (0-5 for 6 hex directions)
---  - Floor/level tracking (multi-level maps)
---  - Previous position history
---  - Rotation state
---
---Component Data:
---  - x: X position in hex coordinates
---  - y: Y position in hex coordinates
---  - facing: Direction (0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE)
---  - floor: Vertical level (0=ground, 1+=upper floors)
---  - prevX, prevY: Previous position for interpolation
---
---Hex Directions (facing values):
---  - 0: East (right)
---  - 1: North-East (up-right)
---  - 2: North-West (up-left)
---  - 3: West (left)
---  - 4: South-West (down-left)
---  - 5: South-East (down-right)
---
---Key Exports:
---  - Transform.new(x, y, facing): Creates transform component
---  - setPosition(transform, x, y): Updates position
---  - rotate(transform, direction): Changes facing
---  - getPosition(transform): Returns {x, y}
---
---Dependencies:
---  - None (pure data component)
---
---@module battlescape.battle_ecs.transform
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Transform = require("battlescape.battle_ecs.transform")
---  local transform = Transform.new(10, 15, 0)
---  transform.x = 11  -- Move east
---
---@see battlescape.battle_ecs.unit_entity For usage
---@see battlescape.battle_ecs.movement_system For movement logic

-- transform.lua
-- Position and spatial data component (pure data)
-- Part of ECS architecture for battle system

local Transform = {}

-- Create a new transform component
-- @param x number: X position in hex coordinates
-- @param y number: Y position in hex coordinates
-- @param facing number: Direction facing (0-5, hex directions)
-- @return table: Transform component
function Transform.new(x, y, facing)
    return {
        x = x or 0,
        y = y or 0,
        q = x or 0,  -- Alias for hex coordinates
        r = y or 0,  -- Alias for hex coordinates
        facing = facing or 0  -- 0=East, 1=NE, 2=NW, 3=West, 4=SW, 5=SE
    }
end

-- Create a copy of a transform component
function Transform.copy(transform)
    return {
        x = transform.x,
        y = transform.y,
        facing = transform.facing
    }
end

return Transform






















