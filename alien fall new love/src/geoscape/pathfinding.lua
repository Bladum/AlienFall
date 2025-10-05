--- Pathfinding for Geoscape Craft Movement
-- Simple pathfinding algorithm for craft navigation between provinces
-- Uses straight-line paths with obstacle avoidance
--
-- @module geoscape.pathfinding

local Pathfinding = {}

--- Calculate straight-line path between two points
-- @param startX number: Start X coordinate
-- @param startY number: Start Y coordinate
-- @param endX number: End X coordinate
-- @param endY number: End Y coordinate
-- @return table: Path waypoints {{x, y}, {x, y}, ...}
function Pathfinding.calculateStraightPath(startX, startY, endX, endY)
    return {
        {x = startX, y = startY},
        {x = endX, y = endY}
    }
end

--- Calculate distance between two points
-- @param x1 number: First point X
-- @param y1 number: First point Y
-- @param x2 number: Second point X
-- @param y2 number: Second point Y
-- @return number: Distance in pixels
function Pathfinding.calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

--- Calculate bearing (angle) from one point to another
-- @param x1 number: Start point X
-- @param y1 number: Start point Y
-- @param x2 number: End point X
-- @param y2 number: End point Y
-- @return number: Angle in radians
function Pathfinding.calculateBearing(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

--- Move a craft toward destination
-- @param craft table: Craft with position and destination
-- @param dt number: Delta time in seconds
-- @param speed number: Speed in pixels per second
-- @return boolean: True if arrived at destination
function Pathfinding.moveCraftTowardsDestination(craft, dt, speed)
    if not craft.position or not craft.destination then
        return false
    end
    
    local dx = craft.destination.x - craft.position.x
    local dy = craft.destination.y - craft.position.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Check if arrived (within 1 pixel)
    if distance < 1 then
        craft.position.x = craft.destination.x
        craft.position.y = craft.destination.y
        return true
    end
    
    -- Calculate movement
    local movement = speed * dt
    
    if movement >= distance then
        -- Will arrive this frame
        craft.position.x = craft.destination.x
        craft.position.y = craft.destination.y
        return true
    end
    
    -- Move toward destination
    local ratio = movement / distance
    craft.position.x = craft.position.x + dx * ratio
    craft.position.y = craft.position.y + dy * ratio
    
    return false
end

--- Calculate fuel cost for path
-- @param path table: Path waypoints
-- @param fuelPerPixel number: Fuel consumption per pixel
-- @return number: Total fuel cost
function Pathfinding.calculatePathFuelCost(path, fuelPerPixel)
    if not path or #path < 2 then return 0 end
    
    local totalDistance = 0
    for i = 1, #path - 1 do
        local p1 = path[i]
        local p2 = path[i + 1]
        totalDistance = totalDistance + Pathfinding.calculateDistance(p1.x, p1.y, p2.x, p2.y)
    end
    
    return totalDistance * fuelPerPixel
end

--- Calculate estimated time of arrival
-- @param distance number: Distance in pixels
-- @param speed number: Speed in pixels per second
-- @return number: ETA in seconds
function Pathfinding.calculateETA(distance, speed)
    if speed <= 0 then return 0 end
    return distance / speed
end

--- Check if point is within bounds
-- @param x number: X coordinate
-- @param y number: Y coordinate
-- @param bounds table: {minX, minY, maxX, maxY}
-- @return boolean: True if within bounds
function Pathfinding.isWithinBounds(x, y, bounds)
    return x >= bounds.minX and x <= bounds.maxX and
           y >= bounds.minY and y <= bounds.maxY
end

return Pathfinding
