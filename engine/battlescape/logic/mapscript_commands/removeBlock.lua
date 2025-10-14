-- Map Script Command: removeBlock
-- Removes Map Blocks from the map

local MapScriptExecutor = require("battlescape.logic.mapscript_executor")

local removeBlock = {}

---Execute removeBlock command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function removeBlock.execute(context, cmd)
    -- Parse parameters
    local rect = cmd.rect  -- {x, y, width, height} in blocks
    
    if not rect then
        print("[removeBlock] Missing required parameter: rect")
        return false
    end
    
    -- Convert blocks to tiles
    local startX = rect[1] * 15
    local startY = rect[2] * 15
    local width = rect[3] * 15
    local height = rect[4] * 15
    
    print(string.format("[removeBlock] Clearing area (%d,%d,%d,%d) tiles", 
        startX, startY, width, height))
    
    -- Clear tiles in rect
    local clearedCount = 0
    for y = startY, startY + height - 1 do
        for x = startX, startX + width - 1 do
            if x < context.mapWidth and y < context.mapHeight then
                if context.map[y] and context.map[y][x] then
                    context.map[y][x] = nil
                    clearedCount = clearedCount + 1
                end
            end
        end
    end
    
    print(string.format("[removeBlock] Cleared %d tiles", clearedCount))
    return true
end

return removeBlock
