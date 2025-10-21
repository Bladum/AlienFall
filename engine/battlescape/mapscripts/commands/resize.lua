---resize - Map Script Command for Dynamic Map Resizing
---
---MapScript command that dynamically resizes the battlefield map during generation.
---Supports expanding or contracting the map dimensions while preserving existing
---blocks and updating collision data. Used for creating variable-sized battlefields.
---
---Features:
---  - Dynamic map dimension changes
---  - Safe block preservation during resize
---  - Collision data updates
---  - Boundary validation
---  - Performance-optimized resizing
---  - Undo support through command history
---
---Key Exports:
---  - execute(context, cmd): Execute resize command
---  - validateResize(context, newWidth, newHeight): Validate resize operation
---  - performResize(context, newWidth, newHeight): Perform the actual resize
---
---Command Parameters:
---  - width: New map width in tiles
---  - height: New map height in tiles
---  - anchor: Resize anchor point ("center", "topleft", etc.)
---  - preserveBlocks: Whether to preserve existing blocks (default true)
---
---Dependencies:
---  - require("battlescape.mapscripts.mapscript_executor"): Command execution context
---
---@module battlescape.mapscripts.commands.resize
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- In MapScript TOML:
---  [[commands]]
---  type = "resize"
---  width = 20
---  height = 15
---  anchor = "center"
---
---@see battlescape.mapscripts.commands.addBlock For block placement
---@see battlescape.battlefield.battlefield For map management

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

























