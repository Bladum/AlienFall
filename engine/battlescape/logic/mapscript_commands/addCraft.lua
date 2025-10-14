-- Map Script Command: addCraft
-- Adds player craft spawn point

local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")

local addCraft = {}

---Execute addCraft command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function addCraft.execute(context, cmd)
    -- Parse parameters
    local groups = cmd.groups or {}
    local freqs = cmd.freqs or {}
    local craftType = cmd.craftType or "skyranger"  -- Craft type identifier
    local rect = cmd.rect  -- Optional constraint rect
    
    print(string.format("[addCraft] Placing %s craft from groups %s", 
        craftType, table.concat(groups, ",")))
    
    -- Normalize freqs
    while #freqs < #groups do
        table.insert(freqs, 10)
    end
    
    -- Select craft block
    local craftBlock = addCraft.selectCraftBlock(context, groups, freqs)
    
    if not craftBlock then
        print("[addCraft] No eligible craft blocks found")
        return false
    end
    
    -- Find placement position (prefer edges)
    local posX, posY = addCraft.findCraftPosition(context, craftBlock, rect)
    
    if not posX or not posY then
        print("[addCraft] Failed to find valid craft position")
        return false
    end
    
    -- Place craft block
    local success = MapScriptExecutor.placeBlock(context, craftBlock, posX, posY)
    
    if success then
        -- Mark craft spawn point in context
        context.craftSpawn = {
            x = posX + math.floor(craftBlock.width / 2),
            y = posY + math.floor(craftBlock.height / 2),
            blockId = craftBlock.id
        }
        print(string.format("[addCraft] Craft spawn at (%d, %d)", 
            context.craftSpawn.x, context.craftSpawn.y))
    end
    
    return success
end

---Select craft block
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@return table? block Selected craft block or nil
function addCraft.selectCraftBlock(context, groups, freqs)
    local candidates = {}
    local totalWeight = 0
    
    for i, groupId in ipairs(groups) do
        local blocks = MapBlockLoader.getByGroup(groupId)
        local freq = freqs[i]
        
        for _, block in ipairs(blocks) do
            -- Check if block has craft-related tags
            if block.tags and (
                block.tags:match("craft") or 
                block.tags:match("spawn") or
                block.tags:match("xcom")
            ) then
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

---Find craft position (prefer map edges)
---@param context ExecutionContext Execution context
---@param block table Craft block
---@param rect number[]? Optional constraint rect
---@return number? x Position X in tiles
---@return number? y Position Y in tiles
function addCraft.findCraftPosition(context, block, rect)
    local attempts = 50
    
    -- Try edges first
    for _ = 1, attempts do
        local edge = context.rng:random(1, 4)  -- 1=top, 2=right, 3=bottom, 4=left
        local x, y
        
        if edge == 1 then  -- Top
            x = context.rng:random(0, context.mapWidth - block.width)
            y = 0
        elseif edge == 2 then  -- Right
            x = context.mapWidth - block.width
            y = context.rng:random(0, context.mapHeight - block.height)
        elseif edge == 3 then  -- Bottom
            x = context.rng:random(0, context.mapWidth - block.width)
            y = context.mapHeight - block.height
        else  -- Left
            x = 0
            y = context.rng:random(0, context.mapHeight - block.height)
        end
        
        -- Snap to block grid
        x = math.floor(x / 15) * 15
        y = math.floor(y / 15) * 15
        
        -- Check if area is empty
        if MapScriptExecutor.isAreaEmpty(context, x, y, block.width, block.height) then
            return x, y
        end
    end
    
    -- Fall back to any position
    for _ = 1, attempts do
        local x = context.rng:random(0, context.mapWidth - block.width)
        local y = context.rng:random(0, context.mapHeight - block.height)
        
        x = math.floor(x / 15) * 15
        y = math.floor(y / 15) * 15
        
        if MapScriptExecutor.isAreaEmpty(context, x, y, block.width, block.height) then
            return x, y
        end
    end
    
    return nil, nil
end

return addCraft
