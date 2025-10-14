-- Map Script Command: resize
-- Dynamically resizes the map during generation

local resize = {}

---Execute resize command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function resize.execute(context, cmd)
    -- Parse parameters
    local newSize = cmd.size or context.script.mapSize
    
    if not newSize or #newSize < 2 then
        print("[resize] Invalid size parameter")
        return false
    end
    
    local newWidth = newSize[1] * 15
    local newHeight = newSize[2] * 15
    
    print(string.format("[resize] Resizing map from %dx%d to %dx%d tiles", 
        context.mapWidth, context.mapHeight, newWidth, newHeight))
    
    -- Create new map grid
    local newMap = {}
    for y = 0, newHeight - 1 do
        newMap[y] = {}
        for x = 0, newWidth - 1 do
            -- Copy existing tiles if within old bounds
            if y < context.mapHeight and x < context.mapWidth and context.map[y] then
                newMap[y][x] = context.map[y][x]
            else
                newMap[y][x] = nil
            end
        end
    end
    
    -- Update context
    context.map = newMap
    context.mapWidth = newWidth
    context.mapHeight = newHeight
    
    print(string.format("[resize] Map resized to %dx%d", newWidth, newHeight))
    return true
end

return resize
