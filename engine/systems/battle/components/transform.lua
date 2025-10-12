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
