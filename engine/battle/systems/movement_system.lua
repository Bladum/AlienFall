-- movement_system.lua
-- Movement processing system using Movement and Transform components
-- Part of ECS architecture for battle system

local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

local MovementSystem = {}

-- Calculate movement cost from one hex to another
-- @param hexSystem HexSystem: The hex grid
-- @param fromQ number: Start q coordinate
-- @param fromR number: Start r coordinate
-- @param toQ number: End q coordinate
-- @param toR number: End r coordinate
-- @return number: Movement cost in AP (or nil if invalid)
function MovementSystem.getMovementCost(hexSystem, fromQ, fromR, toQ, toR)
    -- Check if move is valid
    if not hexSystem:isValidHex(toQ, toR) then
        return nil
    end
    
    if not hexSystem:isWalkable(toQ, toR) then
        return nil
    end
    
    -- Check if hexes are adjacent
    local distance = HexMath.distance(fromQ, fromR, toQ, toR)
    if distance ~= 1 then
        return nil  -- Only adjacent moves allowed
    end
    
    return 2  -- Standard move cost: 2 AP per hex
end

-- Calculate rotation cost to face a new direction
-- @param currentFacing number: Current facing (0-5)
-- @param targetFacing number: Target facing (0-5)
-- @return number: Rotation cost in AP
function MovementSystem.getRotationCost(currentFacing, targetFacing)
    local rotation = HexMath.rotationToFace(currentFacing, targetFacing)
    return math.abs(rotation)  -- 1 AP per 60° rotation
end

-- Try to move unit to new position
-- @param unit table: Unit with transform and movement components
-- @param hexSystem HexSystem: The hex grid
-- @param toQ number: Target q coordinate
-- @param toR number: Target r coordinate
-- @return boolean: Success or failure
function MovementSystem.tryMove(unit, hexSystem, toQ, toR)
    if not unit.transform or not unit.movement then
        Debug.warn("MovementSystem", "Unit missing transform or movement component")
        return false
    end
    
    local fromQ = unit.transform.q
    local fromR = unit.transform.r
    
    -- Check if there's a unit already at target
    local occupant = hexSystem:getUnitAt(toQ, toR)
    if occupant then
        Debug.log("MovementSystem", "Hex occupied by another unit")
        return false
    end
    
    -- Calculate cost
    local cost = MovementSystem.getMovementCost(hexSystem, fromQ, fromR, toQ, toR)
    if not cost then
        Debug.log("MovementSystem", "Invalid move target")
        return false
    end
    
    -- Check if unit can afford it
    if not unit.movement.canAfford or not unit.movement:canAfford(cost) then
        Debug.log("MovementSystem", "Insufficient AP for move")
        return false
    end
    
    -- Perform move
    unit.movement:spendAP(cost)
    unit.transform.q = toQ
    unit.transform.r = toR
    
    Debug.log("MovementSystem", string.format("Moved unit to (%d,%d) for %d AP", toQ, toR, cost))
    return true
end

-- Try to rotate unit to face new direction
-- @param unit table: Unit with transform and movement components
-- @param targetFacing number: Target facing (0-5)
-- @return boolean: Success or failure
function MovementSystem.tryRotate(unit, targetFacing)
    if not unit.transform or not unit.movement then
        Debug.warn("MovementSystem", "Unit missing transform or movement component")
        return false
    end
    
    -- Calculate cost
    local cost = MovementSystem.getRotationCost(unit.transform.facing, targetFacing)
    if cost == 0 then
        return true  -- Already facing that direction
    end
    
    -- Check if unit can afford it
    if not unit.movement.canAfford or not unit.movement:canAfford(cost) then
        Debug.log("MovementSystem", "Insufficient AP for rotation")
        return false
    end
    
    -- Perform rotation
    unit.movement:spendAP(cost)
    unit.transform.facing = targetFacing
    
    Debug.log("MovementSystem", string.format("Rotated unit to facing %d for %d AP", targetFacing, cost))
    return true
end

-- Calculate path from start to end (returns array of {q, r} or nil if no path)
-- @param hexSystem HexSystem: The hex grid
-- @param startQ number: Start q coordinate
-- @param startR number: Start r coordinate
-- @param endQ number: End q coordinate
-- @param endR number: End r coordinate
-- @return table: Array of waypoints or nil if no path
function MovementSystem.findPath(hexSystem, startQ, startR, endQ, endR)
    -- Simple A* pathfinding
    local openSet = {{q = startQ, r = startR, g = 0, h = HexMath.distance(startQ, startR, endQ, endR), parent = nil}}
    local closedSet = {}
    local cameFrom = {}
    
    while #openSet > 0 do
        -- Find node with lowest f score
        table.sort(openSet, function(a, b) return (a.g + a.h) < (b.g + b.h) end)
        local current = table.remove(openSet, 1)
        
        -- Check if reached goal
        if current.q == endQ and current.r == endR then
            -- Reconstruct path
            local path = {}
            local node = current
            while node do
                table.insert(path, 1, {q = node.q, r = node.r})
                node = cameFrom[node.q .. "_" .. node.r]
            end
            return path
        end
        
        -- Add to closed set
        local key = current.q .. "_" .. current.r
        closedSet[key] = true
        
        -- Check neighbors
        local neighbors = hexSystem:getValidNeighbors(current.q, current.r)
        for _, neighbor in ipairs(neighbors) do
            local nKey = neighbor.q .. "_" .. neighbor.r
            
            if not closedSet[nKey] and hexSystem:isWalkable(neighbor.q, neighbor.r) then
                local g = current.g + 1
                local h = HexMath.distance(neighbor.q, neighbor.r, endQ, endR)
                
                -- Check if already in open set
                local found = false
                for i, node in ipairs(openSet) do
                    if node.q == neighbor.q and node.r == neighbor.r then
                        if g < node.g then
                            node.g = g
                            cameFrom[nKey] = current
                        end
                        found = true
                        break
                    end
                end
                
                if not found then
                    table.insert(openSet, {q = neighbor.q, r = neighbor.r, g = g, h = h})
                    cameFrom[nKey] = current
                end
            end
        end
    end
    
    return nil  -- No path found
end

-- Reset movement points for all units (new turn)
function MovementSystem.resetAllAP(units)
    local count = 0
    for _, unit in pairs(units) do
        if unit.movement and unit.movement.resetAP then
            unit.movement:resetAP()
            count = count + 1
        end
    end
    Debug.print("MovementSystem", string.format("Reset AP for %d units", count))
end

return MovementSystem
