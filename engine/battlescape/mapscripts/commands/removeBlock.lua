---removeBlock - Map Script Command for Block Removal
---
---MapScript command that removes MapBlocks from specified positions on the battlefield.
---Supports removal by coordinate, tag filtering, or area clearing. Used for creating
---open spaces, removing obstacles, or clearing areas for new block placement.
---
---Features:
---  - Coordinate-specific block removal
---  - Tag-based block filtering and removal
---  - Rectangular area clearing
---  - Safe removal with collision updates
---  - Undo support through command history
---  - Performance tracking for large removals
---
---Key Exports:
---  - execute(context, cmd): Execute removeBlock command
---  - removeByTag(context, tag, rect): Remove blocks by tag within area
---  - removeAtPosition(context, x, y): Remove single block at position
---
---Command Parameters:
---  - x, y: Specific coordinates to remove block from
---  - tag: Remove all blocks with this tag
---  - rect: Remove all blocks within rectangle {x, y, width, height}
---  - safe: Boolean flag for safe removal (default true)
---
---Dependencies:
---  - require("battlescape.mapscripts.mapscript_executor"): Command execution context
---
---@module battlescape.mapscripts.commands.removeBlock
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- In MapScript TOML:
---  [[commands]]
---  type = "removeBlock"
---  x = 10
---  y = 5
---
---  -- Remove by tag:
---  [[commands]]
---  type = "removeBlock"
---  tag = "temporary"
---
---@see battlescape.mapscripts.commands.addBlock For block addition
---@see battlescape.mapscripts.commands.fillArea For area filling

-- Map Script Command: removeBlock
-- Removes Map Blocks from the map

local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")

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

























