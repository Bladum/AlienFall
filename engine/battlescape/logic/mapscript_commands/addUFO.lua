-- Map Script Command: addUFO
-- Adds UFO objective block

local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")

local addUFO = {}

---Execute addUFO command
---@param context ExecutionContext Execution context
---@param cmd table Command parameters
---@return boolean success Whether command succeeded
function addUFO.execute(context, cmd)
    -- Parse parameters
    local groups = cmd.groups or {}
    local freqs = cmd.freqs or {}
    local ufoType = cmd.ufoType or "scout"  -- UFO type identifier
    local rect = cmd.rect  -- Optional constraint rect
    
    print(string.format("[addUFO] Placing %s UFO from groups %s", 
        ufoType, table.concat(groups, ",")))
    
    -- Normalize freqs
    while #freqs < #groups do
        table.insert(freqs, 10)
    end
    
    -- Select UFO block
    local ufoBlock = addUFO.selectUFOBlock(context, groups, freqs, ufoType)
    
    if not ufoBlock then
        print("[addUFO] No eligible UFO blocks found")
        return false
    end
    
    -- Find placement position (prefer center)
    local posX, posY = addUFO.findUFOPosition(context, ufoBlock, rect)
    
    if not posX or not posY then
        print("[addUFO] Failed to find valid UFO position")
        return false
    end
    
    -- Place UFO block
    local success = MapScriptExecutor.placeBlock(context, ufoBlock, posX, posY)
    
    if success then
        -- Mark UFO objective in context
        context.ufoObjective = {
            x = posX + math.floor(ufoBlock.width / 2),
            y = posY + math.floor(ufoBlock.height / 2),
            blockId = ufoBlock.id,
            ufoType = ufoType
        }
        print(string.format("[addUFO] UFO objective at (%d, %d)", 
            context.ufoObjective.x, context.ufoObjective.y))
    end
    
    return success
end

---Select UFO block
---@param context ExecutionContext Execution context
---@param groups number[] Group IDs
---@param freqs number[] Frequencies
---@param ufoType string UFO type
---@return table? block Selected UFO block or nil
function addUFO.selectUFOBlock(context, groups, freqs, ufoType)
    local candidates = {}
    local totalWeight = 0
    
    for i, groupId in ipairs(groups) do
        local blocks = MapBlockLoader.getByGroup(groupId)
        local freq = freqs[i]
        
        for _, block in ipairs(blocks) do
            -- Check if block has UFO-related tags
            if block.tags and (
                block.tags:match("ufo") or 
                block.tags:match("alien") or
                block.tags:match("objective")
            ) then
                -- Prefer blocks matching UFO type
                local typeMatch = block.tags:match(ufoType) or block.id:match(ufoType)
                local weight = typeMatch and (freq * 2) or freq
                
                table.insert(candidates, {
                    block = block,
                    weight = weight
                })
                totalWeight = totalWeight + weight
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

---Find UFO position (prefer center of map)
---@param context ExecutionContext Execution context
---@param block table UFO block
---@param rect number[]? Optional constraint rect
---@return number? x Position X in tiles
---@return number? y Position Y in tiles
function addUFO.findUFOPosition(context, block, rect)
    local attempts = 50
    
    -- Calculate center region
    local centerX = math.floor((context.mapWidth - block.width) / 2)
    local centerY = math.floor((context.mapHeight - block.height) / 2)
    local radius = math.min(context.mapWidth, context.mapHeight) / 4
    
    -- Try center region first
    for _ = 1, attempts do
        local offsetX = context.rng:random(-radius, radius)
        local offsetY = context.rng:random(-radius, radius)
        
        local x = centerX + offsetX
        local y = centerY + offsetY
        
        -- Clamp to map bounds
        x = math.max(0, math.min(x, context.mapWidth - block.width))
        y = math.max(0, math.min(y, context.mapHeight - block.height))
        
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

return addUFO
