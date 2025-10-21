---addBlock - Map Script Command for Block Placement
---
---MapScript command that adds MapBlocks to the battlefield with weighted random selection.
---Supports multiple block groups, frequency weights, usage limits, and size constraints.
---Used in procedural map generation to place terrain features and structures.
---
---Features:
---  - Weighted random block selection from groups
---  - Usage limits to prevent block repetition
---  - Size filtering (1x1, 2x2, etc. blocks)
---  - Rectangular placement constraints
---  - Multiple block placement in single command
---  - Integration with MapBlockLoader for TOML-based blocks
---
---Key Exports:
---  - execute(context, cmd): Execute addBlock command
---  - placeOne(context, groups, freqs, maxUses, size, rect): Place single block
---
---Command Parameters:
---  - groups: Array of group IDs to select from
---  - freqs: Array of selection frequencies/weights
---  - maxUses: Array of maximum usage counts per block
---  - size: Block size in tiles {width, height}
---  - amount: Number of blocks to place
---  - rect: Optional constraint rectangle {x, y, width, height}
---
---Dependencies:
---  - require("battlescape.maps.mapblock_loader_v2"): Block loading and grouping
---  - require("battlescape.mapscripts.mapscript_executor"): Command execution context
---
---@module battlescape.mapscripts.commands.addBlock
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- In MapScript TOML:
---  [[commands]]
---  type = "addBlock"
---  groups = [1, 2, 3]
---  freqs = [10, 5, 1]
---  maxUses = [3, 5, 1]
---  size = [1, 1]
---  amount = 5
---
---@see battlescape.mapscripts.mapscript_executor For command execution system
---@see battlescape.maps.mapblock_loader_v2 For block loading

-- Map Script Command: addBlock
-- Adds Map Blocks to the map with weighted random selection

local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")

local addBlock = {}

---Execute addBlock command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function addBlock.execute(context, cmd)
    -- Parse parameters
    local groups = cmd.groups or {}
    local freqs = cmd.freqs or {}
    local maxUses = cmd.maxUses or {}
    local size = cmd.size or {1, 1}  -- Size in blocks (1 = 15�15)
    local amount = cmd.amount or 1
    local rect = cmd.rect  -- Optional: {x, y, width, height} in blocks
    
    -- Normalize freqs and maxUses
    while #freqs < #groups do
        table.insert(freqs, 10)  -- Default frequency
    end
    while #maxUses < #groups do
        table.insert(maxUses, 999)  -- Default unlimited
    end
    
    print(string.format("[addBlock] Placing %d blocks from groups %s", 
        amount, table.concat(groups, ",")))
    
    -- Place blocks
    for i = 1, amount do
        local placed = addBlock.placeOne(context, groups, freqs, maxUses, size, rect)
        if not placed then
            print(string.format("[addBlock] Failed to place block %d/%d", i, amount))
        end
    end
    
    return true
end

---Place one block
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param maxUses number[] Max usage counts
---@param size number[] Size in blocks {width, height}
---@param rect number[]? Optional constraint rect
---@return boolean success Whether placement succeeded
function addBlock.placeOne(context, groups, freqs, maxUses, size, rect)
    -- Collect eligible blocks
    local candidates = {}
    local totalWeight = 0
    
    for i, groupId in ipairs(groups) do
        local blocks = MapBlockLoader.getByGroup(groupId)
        local freq = freqs[i] or 10
        local maxUse = maxUses[i] or 999
        
        for _, block in ipairs(blocks) do
            -- Check size match
            local blockSizeW = math.floor(block.width / 15)
            local blockSizeH = math.floor(block.height / 15)
            
            if blockSizeW == size[1] and blockSizeH == size[2] then
                -- Check max uses
                local used = context.usedBlocks[block.id] or 0
                if used < maxUse then
                    table.insert(candidates, {
                        block = block,
                        weight = freq
                    })
                    totalWeight = totalWeight + freq
                end
            end
        end
    end
    
    if #candidates == 0 then
        print("[addBlock] No eligible blocks found")
        return false
    end
    
    -- Weighted random selection
    local roll = context.rng:random() * totalWeight
    local cumulative = 0
    local selectedBlock = nil
    
    for _, candidate in ipairs(candidates) do
        cumulative = cumulative + candidate.weight
        if roll <= cumulative then
            selectedBlock = candidate.block
            break
        end
    end
    
    if not selectedBlock then
        selectedBlock = candidates[#candidates].block
    end
    
    -- Find placement position
    local attempts = 100
    for _ = 1, attempts do
        local posX, posY = addBlock.findPosition(context, selectedBlock, rect)
        
        if posX and posY then
            -- Check if area is empty
            if MapScriptExecutor.isAreaEmpty(context, posX, posY, selectedBlock.width, selectedBlock.height) then
                -- Place block
                return MapScriptExecutor.placeBlock(context, selectedBlock, posX, posY)
            end
        end
    end
    
    print(string.format("[addBlock] Failed to find valid position after %d attempts", attempts))
    return false
end

---Find a position for block placement
---@param context ExecutionContext Execution context
---@param block table Map Block
---@param rect number[]? Optional constraint rect {x, y, width, height} in blocks
---@return number? x Position X in tiles
---@return number? y Position Y in tiles
function addBlock.findPosition(context, block, rect)
    local minX, minY, maxX, maxY
    
    if rect then
        -- Constrain to rect
        minX = rect[1] * 15
        minY = rect[2] * 15
        maxX = (rect[1] + rect[3]) * 15 - block.width
        maxY = (rect[2] + rect[4]) * 15 - block.height
    else
        -- Use full map
        minX = 0
        minY = 0
        maxX = context.mapWidth - block.width
        maxY = context.mapHeight - block.height
    end
    
    -- Ensure valid range
    if maxX < minX or maxY < minY then
        return nil, nil
    end
    
    -- Random position
    local x = minX + context.rng:random(0, maxX - minX)
    local y = minY + context.rng:random(0, maxY - minY)
    
    -- Snap to block grid (15�15)
    x = math.floor(x / 15) * 15
    y = math.floor(y / 15) * 15
    
    return x, y
end

return addBlock

























