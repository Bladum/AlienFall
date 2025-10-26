---Movement - Movement Capability Component (ECS)
---
---Pure data component storing unit movement capabilities and action points. Part
---of the ECS (Entity-Component-System) battle architecture. Tracks AP, movement
---costs, and turn costs.
---
---Features:
---  - Action Point (AP) tracking (current/max)
---  - Movement cost per hex
---  - Turn cost (rotation)
---  - Movement mode support
---  - AP regeneration
---  - Movement history
---
---Component Data:
---  - maxAP: Maximum action points per turn
---  - currentAP: Current action points available
---  - moveCost: AP cost to move one hex (default 2)
---  - turnCost: AP cost to rotate 60° (default 1)
---  - moveMode: Current movement mode ("walk", "run", "sneak")
---
---Action Point System:
---  - Regenerates to maxAP at start of turn
---  - Consumed by actions (move, shoot, use item)
---  - Unused AP may carry over (optional rule)
---
---Key Exports:
---  - Movement.new(maxAP, moveCost, turnCost): Creates movement component
---  - consumeAP(movement, amount): Reduces current AP
---  - regenerateAP(movement): Restores to max
---  - hasAP(movement, amount): Returns true if enough AP
---
---Dependencies:
---  - None (pure data component)
---
---@module battlescape.battle_ecs.movement
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Movement = require("battlescape.battle_ecs.movement")
---  local movement = Movement.new(10, 2, 1)
---  movement.currentAP = movement.currentAP - 2  -- Move one hex
---
---@see battlescape.battle_ecs.movement_system For movement logic
---@see battlescape.battle_ecs.unit_entity For usage

-- movement.lua
-- Movement capability data component (pure data)
-- Part of ECS architecture for battle system

local Movement = {}

-- Create a new movement component
-- @param maxAP number: Maximum action points per turn
-- @param moveCost number: AP cost to move one hex (default 2)
-- @param turnCost number: AP cost to rotate 60 degrees (default 1)
-- @return table: Movement component
function Movement.new(maxAP, moveCost, turnCost)
    local instance = {
        maxAP = maxAP or 10,
        currentAP = maxAP or 10,
        moveCost = moveCost or 2,
        turnCost = turnCost or 1,
        path = nil  -- Array of {x, y} waypoints when moving
    }

    -- Add methods to instance
    instance.resetAP = function(self) Movement.resetAP(self) end
    instance.canAfford = function(self, cost) return Movement.canAfford(self, cost) end
    instance.spendAP = function(self, cost) return Movement.spendAP(self, cost) end

    return instance
end

-- Reset AP to maximum (for new turn)
function Movement.resetAP(movement)
    movement.currentAP = movement.maxAP
end

-- Check if unit can afford action
function Movement.canAfford(movement, cost)
    return movement.currentAP >= cost
end

-- Spend AP (returns true if successful)
function Movement.spendAP(movement, cost)
    if Movement.canAfford(movement, cost) then
        movement.currentAP = movement.currentAP - cost
        return true
    end
    return false
end

return Movement
