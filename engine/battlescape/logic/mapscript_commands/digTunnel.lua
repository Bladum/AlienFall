-- Map Script Command: digTunnel
-- Creates tunnels/corridors by removing tiles

local digTunnel = {}

---Execute digTunnel command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function digTunnel.execute(context, cmd)
    -- Parse parameters
    local from = cmd.from  -- {x, y} in tiles
    local to = cmd.to  -- {x, y} in tiles
    local width = cmd.width or 3  -- Tunnel width in tiles
    
    if not from or not to then
        print("[digTunnel] Missing required parameters: from, to")
        return false
    end
    
    print(string.format("[digTunnel] Creating tunnel from (%d,%d) to (%d,%d) width %d", 
        from[1], from[2], to[1], to[2], width))
    
    -- Use Bresenham's line algorithm
    local x1, y1 = from[1], from[2]
    local x2, y2 = to[1], to[2]
    
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    local clearedCount = 0
    
    while true do
        -- Clear area around current position
        clearedCount = clearedCount + digTunnel.clearArea(context, x1, y1, width)
        
        if x1 == x2 and y1 == y2 then
            break
        end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
    
    print(string.format("[digTunnel] Cleared %d tiles", clearedCount))
    return true
end

---Clear area around position
---@param context ExecutionContext Execution context
---@param centerX number Center X
---@param centerY number Center Y
---@param width number Width/radius
---@return number count Number of tiles cleared
function digTunnel.clearArea(context, centerX, centerY, width)
    local count = 0
    local radius = math.floor(width / 2)
    
    for y = centerY - radius, centerY + radius do
        for x = centerX - radius, centerX + radius do
            if x >= 0 and x < context.mapWidth and y >= 0 and y < context.mapHeight then
                if context.map[y] and context.map[y][x] then
                    context.map[y][x] = nil
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

return digTunnel
