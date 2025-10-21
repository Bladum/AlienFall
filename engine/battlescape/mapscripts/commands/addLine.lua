---addLine - Map Script Command for Linear Block Placement
---
---MapScript command that places lines of MapBlocks in horizontal, vertical, or both directions.
---Creates linear features like roads, rivers, or walls by placing blocks along specified axes.
---Supports weighted random selection and rectangular constraints.
---
---Features:
---  - Horizontal, vertical, or bidirectional line placement
---  - Weighted random block selection from groups
---  - Rectangular placement constraints
---  - Empty area validation before placement
---  - Random positioning within line bounds
---  - Integration with MapBlockLoader for block selection
---
---Key Exports:
---  - execute(context, cmd): Execute addLine command
---  - placeHorizontal(context, groups, freqs, rect): Place horizontal line
---  - placeVertical(context, groups, freqs, rect): Place vertical line
---  - selectBlock(context, groups, freqs, size): Select block for placement
---
---Command Parameters:
---  - groups: Array of group IDs to select blocks from
---  - freqs: Array of selection frequencies/weights
---  - direction: Line direction ("horizontal", "vertical", "both")
---  - rect: Constraint rectangle {x, y, width, height} in blocks
---
---Dependencies:
---  - require("battlescape.maps.mapblock_loader_v2"): Block loading and grouping
---  - require("battlescape.mapscripts.mapscript_executor"): Command execution context
---
---@module battlescape.mapscripts.commands.addLine
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- In MapScript TOML:
---  [[commands]]
---  type = "addLine"
---  groups = [5, 6]
---  freqs = [8, 2]
---  direction = "horizontal"
---  rect = [2, 2, 8, 1]
---
---@see battlescape.mapscripts.commands.addBlock For area block placement
---@see battlescape.mapscripts.mapscript_executor For command execution

-- Map Script Command: addLine
-- Adds a line of Map Blocks (horizontal, vertical, or both)

local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")

local addLine = {}

---Execute addLine command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function addLine.execute(context, cmd)
    -- Parse parameters
    local groups = cmd.groups or {}
    local freqs = cmd.freqs or {}
    local direction = cmd.direction or "horizontal"  -- horizontal, vertical, both
    local rect = cmd.rect  -- {x, y, width, height} in blocks
    
    if not rect then
        print("[addLine] Missing required parameter: rect")
        return false
    end
    
    print(string.format("[addLine] Creating %s line in rect (%d,%d,%d,%d)", 
        direction, rect[1], rect[2], rect[3], rect[4]))
    
    if direction == "horizontal" or direction == "both" then
        addLine.placeHorizontal(context, groups, freqs, rect)
    end
    
    if direction == "vertical" or direction == "both" then
        addLine.placeVertical(context, groups, freqs, rect)
    end
    
    return true
end

---Place horizontal line
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param rect number[] Rect {x, y, width, height} in blocks
function addLine.placeHorizontal(context, groups, freqs, rect)
    local startX = rect[1] * 15
    local startY = rect[2] * 15
    local width = rect[3]
    local height = rect[4]
    
    -- Place blocks along horizontal line
    for blockX = 0, width - 1 do
        -- Select random Y within rect
        local blockY = context.rng:random(0, height - 1)
        
        -- Select block from groups
        local block = addLine.selectBlock(context, groups, freqs, {1, 1})
        
        if block then
            local posX = startX + (blockX * 15)
            local posY = startY + (blockY * 15)
            
            if MapScriptExecutor.isAreaEmpty(context, posX, posY, block.width, block.height) then
                MapScriptExecutor.placeBlock(context, block, posX, posY)
            end
        end
    end
end

---Place vertical line
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param rect number[] Rect {x, y, width, height} in blocks
function addLine.placeVertical(context, groups, freqs, rect)
    local startX = rect[1] * 15
    local startY = rect[2] * 15
    local width = rect[3]
    local height = rect[4]
    
    -- Place blocks along vertical line
    for blockY = 0, height - 1 do
        -- Select random X within rect
        local blockX = context.rng:random(0, width - 1)
        
        -- Select block from groups
        local block = addLine.selectBlock(context, groups, freqs, {1, 1})
        
        if block then
            local posX = startX + (blockX * 15)
            local posY = startY + (blockY * 15)
            
            if MapScriptExecutor.isAreaEmpty(context, posX, posY, block.width, block.height) then
                MapScriptExecutor.placeBlock(context, block, posX, posY)
            end
        end
    end
end

---Select a block from groups
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param size number[] Size {width, height} in blocks
---@return table? block Selected Map Block or nil
function addLine.selectBlock(context, groups, freqs, size)
    -- Normalize freqs
    while #freqs < #groups do
        table.insert(freqs, 10)
    end
    
    -- Collect candidates
    local candidates = {}
    local totalWeight = 0
    
    for i, groupId in ipairs(groups) do
        local blocks = MapBlockLoader.getByGroup(groupId)
        local freq = freqs[i]
        
        for _, block in ipairs(blocks) do
            local blockSizeW = math.floor(block.width / 15)
            local blockSizeH = math.floor(block.height / 15)
            
            if blockSizeW == size[1] and blockSizeH == size[2] then
                table.insert(candidates, {
                    block = block,
                    weight = freq
                })
                totalWeight = totalWeight + freq
            end
        end
    end
    
    if #candidates == 0 then
        return nil
    end
    
    -- Weighted random selection
    local roll = context.rng:random() * totalWeight
    local cumulative = 0
    
    for _, candidate in ipairs(candidates) do
        cumulative = cumulative + candidate.weight
        if roll <= cumulative then
            return candidate.block
        end
    end
    
    return candidates[#candidates].block
end

return addLine

























