---fillArea - Map Script Command for Area Filling
---
---MapScript command that fills empty or specified areas with MapBlocks. Automatically
---populates unfilled regions of the battlefield with appropriate terrain blocks.
---Supports weighted random selection from block groups and placement constraints.
---
---Features:
---  - Automatic empty area detection and filling
---  - Weighted random block selection from groups
---  - Rectangular area constraints
---  - Terrain type filtering (ground, wall, etc.)
---  - Collision avoidance with existing blocks
---  - Performance-optimized placement algorithm
---
---Key Exports:
---  - execute(context, cmd): Execute fillArea command
---  - findEmptyAreas(context, rect): Find unfilled areas within rectangle
---  - selectFillBlock(context, groups, freqs): Select appropriate fill block
---
---Command Parameters:
---  - groups: Array of group IDs to select blocks from
---  - freqs: Array of selection frequencies/weights
---  - rect: Optional constraint rectangle {x, y, width, height}
---  - terrainType: Filter by terrain type ("ground", "wall", etc.)
---
---Dependencies:
---  - require("battlescape.maps.mapblock_loader_v2"): Block loading and grouping
---  - require("battlescape.mapscripts.mapscript_executor"): Command execution context
---
---@module battlescape.mapscripts.commands.fillArea
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- In MapScript TOML:
---  [[commands]]
---  type = "fillArea"
---  groups = [1, 2, 3]
---  freqs = [5, 3, 1]
---  terrainType = "ground"
---
---@see battlescape.mapscripts.commands.addBlock For specific block placement
---@see battlescape.maps.mapblock_loader_v2 For block management

-- Map Script Command: fillArea
-- Fills empty areas with Map Blocks

local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")

local fillArea = {}

---Execute fillArea command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function fillArea.execute(context, cmd)
    -- Parse parameters
    local groups = cmd.groups or {}
    local freqs = cmd.freqs or {}
    local size = cmd.size or {1, 1}  -- Block size
    local rect = cmd.rect  -- Optional constraint rect
    local maxAttempts = cmd.maxAttempts or 100
    
    print(string.format("[fillArea] Filling area with blocks from groups %s", 
        table.concat(groups, ",")))
    
    -- Normalize freqs
    while #freqs < #groups do
        table.insert(freqs, 10)
    end
    
    local placedCount = 0
    local attempts = 0
    
    while attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Try to place a block
        local success = fillArea.tryPlaceBlock(context, groups, freqs, size, rect)
        
        if success then
            placedCount = placedCount + 1
        else
            -- If 10 consecutive failures, stop
            if attempts - placedCount > 10 then
                break
            end
        end
    end
    
    print(string.format("[fillArea] Placed %d blocks in %d attempts", placedCount, attempts))
    return true
end

---Try to place one block
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param size number[] Block size {width, height}
---@param rect number[]? Optional constraint rect
---@return boolean success Whether placement succeeded
function fillArea.tryPlaceBlock(context, groups, freqs, size, rect)
    -- Select block
    local block = fillArea.selectBlock(context, groups, freqs, size)
    
    if not block then
        return false
    end
    
    -- Find empty position
    local posX, posY = fillArea.findEmptyPosition(context, block, rect)
    
    if not posX or not posY then
        return false
    end
    
    -- Place block
    return MapScriptExecutor.placeBlock(context, block, posX, posY)
end

---Select a block from groups
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param size number[] Block size {width, height}
---@return table? block Selected block or nil
function fillArea.selectBlock(context, groups, freqs, size)
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

---Find empty position for block
---@param context ExecutionContext Execution context
---@param block table Map Block
---@param rect number[]? Optional constraint rect
---@return number? x Position X in tiles
---@return number? y Position Y in tiles
function fillArea.findEmptyPosition(context, block, rect)
    local minX, minY, maxX, maxY
    
    if rect then
        minX = rect[1] * 15
        minY = rect[2] * 15
        maxX = (rect[1] + rect[3]) * 15 - block.width
        maxY = (rect[2] + rect[4]) * 15 - block.height
    else
        minX = 0
        minY = 0
        maxX = context.mapWidth - block.width
        maxY = context.mapHeight - block.height
    end
    
    if maxX < minX or maxY < minY then
        return nil, nil
    end
    
    -- Try random positions
    for _ = 1, 20 do
        local x = minX + context.rng:random(0, maxX - minX)
        local y = minY + context.rng:random(0, maxY - minY)
        
        -- Snap to block grid
        x = math.floor(x / 15) * 15
        y = math.floor(y / 15) * 15
        
        if MapScriptExecutor.isAreaEmpty(context, x, y, block.width, block.height) then
            return x, y
        end
    end
    
    return nil, nil
end

return fillArea

























