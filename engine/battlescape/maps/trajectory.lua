---Trajectory - Projectile Trajectory Calculation
---
---Provides trajectory calculation utilities for projectiles including straight lines,
---parabolic arcs, and beam paths. Used for bullets, grenades, lasers, and thrown items.
---Calculates waypoints for smooth projectile animation and collision detection.
---
---Features:
---  - Straight line trajectories (bullets, beams)
---  - Parabolic arc trajectories (grenades, thrown items)
---  - Waypoint generation for animation
---  - Distance and flight time calculation
---  - Collision prediction along path
---
---Trajectory Types:
---  - Straight: Direct line from A to B (bullets, lasers)
---  - Arc: Parabolic curve (grenades, thrown items)
---  - Beam: Instant hit (laser weapons)
---
---Waypoint Generation:
---  - Discretizes continuous path into steps
---  - Used for animation and collision checks
---  - Adjustable granularity based on projectile speed
---
---Key Exports:
---  - Trajectory.straightLine(startX, startY, endX, endY): Calculates straight path
---  - Trajectory.parabolicArc(startX, startY, endX, endY, height): Calculates arc
---  - Trajectory.getWaypoints(trajectory): Returns discrete waypoints
---  - Trajectory.getDistance(trajectory): Returns total path distance
---  - Trajectory.getFlightTime(trajectory, speed): Calculates travel duration
---
---Dependencies:
---  - None (standalone utility)
---
---@module battlescape.maps.trajectory
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Trajectory = require("battlescape.maps.trajectory")
---  local path = Trajectory.straightLine(5, 10, 12, 15)
---  local waypoints = Trajectory.getWaypoints(path)
---  for _, point in ipairs(waypoints) do
---    -- Animate projectile along path
---  end
---
---@see battlescape.entities.projectile For projectile entity

-- Trajectory Calculation Utilities
-- Provides trajectory calculation for projectiles including straight lines, arcs, and beam paths

local Trajectory = {}

--- Calculate straight line trajectory from point A to B
-- @param startX number Starting X coordinate
-- @param startY number Starting Y coordinate
-- @param endX number Ending X coordinate
-- @param endY number Ending Y coordinate
-- @return table Trajectory data with waypoints
function Trajectory.straightLine(startX, startY, endX, endY)
    local trajectory = {
        type = "straight",
        startX = startX,
        startY = startY,
        endX = endX,
        endY = endY,
        waypoints = {}
    }
    
    -- Calculate distance
    local dx = endX - startX
    local dy = endY - startY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Create waypoints along the line (every 1 unit)
    local steps = math.ceil(distance)
    for i = 0, steps do
        local t = i / steps
        table.insert(trajectory.waypoints, {
            x = startX + dx * t,
            y = startY + dy * t,
            t = t
        })
    end
    
    return trajectory
end

--- Calculate arc trajectory (for grenades, thrown items)
-- @param startX number Starting X coordinate
-- @param startY number Starting Y coordinate
-- @param endX number Ending X coordinate
-- @param endY number Ending Y coordinate
-- @param arcHeight number Height of arc at midpoint
-- @return table Trajectory data with waypoints
function Trajectory.arc(startX, startY, endX, endY, arcHeight)
    arcHeight = arcHeight or 5.0  -- Default arc height
    
    local trajectory = {
        type = "arc",
        startX = startX,
        startY = startY,
        endX = endX,
        endY = endY,
        arcHeight = arcHeight,
        waypoints = {}
    }
    
    -- Calculate distance
    local dx = endX - startX
    local dy = endY - startY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Create waypoints along the arc
    local steps = math.ceil(distance)
    for i = 0, steps do
        local t = i / steps
        
        -- Parabolic arc: height peaks at midpoint
        local arcProgress = 1.0 - math.abs(2.0 * t - 1.0)  -- 0 -> 1 -> 0
        local height = arcHeight * arcProgress
        
        table.insert(trajectory.waypoints, {
            x = startX + dx * t,
            y = startY + dy * t - height,  -- Subtract height for visual arc
            t = t,
            height = height
        })
    end
    
    return trajectory
end

--- Calculate beam trajectory (instant hit, for lasers)
-- @param startX number Starting X coordinate
-- @param startY number Starting Y coordinate
-- @param endX number Ending X coordinate
-- @param endY number Ending Y coordinate
-- @return table Trajectory data (instant)
function Trajectory.beam(startX, startY, endX, endY)
    local trajectory = {
        type = "beam",
        startX = startX,
        startY = startY,
        endX = endX,
        endY = endY,
        instant = true,
        waypoints = {
            {x = startX, y = startY, t = 0},
            {x = endX, y = endY, t = 1}
        }
    }
    
    return trajectory
end

--- Get all tiles that a trajectory passes through (for collision detection)
-- @param trajectory table Trajectory data
-- @return table Array of {x, y} tile coordinates
function Trajectory.getTilesAlongPath(trajectory)
    local tiles = {}
    local visited = {}  -- Prevent duplicates
    
    for _, waypoint in ipairs(trajectory.waypoints) do
        local tileX = math.floor(waypoint.x + 0.5)
        local tileY = math.floor(waypoint.y + 0.5)
        local key = tileX .. "," .. tileY
        
        if not visited[key] then
            visited[key] = true
            table.insert(tiles, {x = tileX, y = tileY})
        end
    end
    
    return tiles
end

--- Calculate time of flight based on distance and velocity
-- @param startX number Starting X coordinate
-- @param startY number Starting Y coordinate
-- @param endX number Ending X coordinate
-- @param endY number Ending Y coordinate
-- @param velocity number Velocity in pixels per second
-- @return number Time in seconds
function Trajectory.calculateFlightTime(startX, startY, endX, endY, velocity)
    local dx = endX - startX
    local dy = endY - startY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if velocity <= 0 then
        return 0
    end
    
    return distance / velocity
end

--- Check if a point is along a trajectory within tolerance
-- @param trajectory table Trajectory data
-- @param checkX number X coordinate to check
-- @param checkY number Y coordinate to check
-- @param tolerance number Distance tolerance (default 1.0)
-- @return boolean, number True if on path, progress value (0-1)
function Trajectory.isPointOnPath(trajectory, checkX, checkY, tolerance)
    tolerance = tolerance or 1.0
    
    -- Check each waypoint
    for _, waypoint in ipairs(trajectory.waypoints) do
        local dx = waypoint.x - checkX
        local dy = waypoint.y - checkY
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= tolerance then
            return true, waypoint.t
        end
    end
    
    return false, 0
end

--- Get interpolated position at progress t (0-1)
-- @param trajectory table Trajectory data
-- @param t number Progress value (0-1)
-- @return number, number X and Y coordinates
function Trajectory.getPositionAt(trajectory, t)
    t = math.max(0, math.min(1, t))  -- Clamp to [0, 1]
    
    local dx = trajectory.endX - trajectory.startX
    local dy = trajectory.endY - trajectory.startY
    local x = trajectory.startX + dx * t
    local y = trajectory.startY + dy * t
    
    -- Apply arc if needed
    if trajectory.type == "arc" then
        local arcProgress = 1.0 - math.abs(2.0 * t - 1.0)
        y = y - trajectory.arcHeight * arcProgress
    end
    
    return x, y
end

return Trajectory






















