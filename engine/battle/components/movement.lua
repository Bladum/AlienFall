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
