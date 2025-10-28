---MapScriptExecutor - OpenXCOM-Style Map Generation
---
---Executes MapScript commands to generate procedural maps. Implements OpenXCOM-style
---command system with commands like addBlock, fillArea, digTunnel, addCraft, etc.
---Core engine for scriptable map generation.
---
---Features:
---  - OpenXCOM-compatible command execution
---  - Block placement (addBlock, addLine, fillArea)
---  - Terrain modification (digTunnel, addRamp)
---  - Object spawning (addCraft, addUFO, addCivilian)
---  - Constraint validation (checkBlock, removeBlocks)
---  - Random seed support for reproducibility
---
---MapScript Commands:
---  - addBlock: Place single MapBlock
---  - addLine: Place line of MapBlocks
---  - fillArea: Fill area with blocks
---  - digTunnel: Create connecting tunnels
---  - addCraft: Place player craft
---  - addUFO: Place UFO wreckage
---  - checkBlock: Validate block placement
---  - removeBlocks: Clear specific group
---
---Execution Context:
---  - Map grid being built
---  - Map dimensions (width, height)
---  - Block size (15×15 typically)
---  - Random seed and RNG
---  - Placed blocks tracking
---
---Key Exports:
---  - MapScriptExecutor.execute(mapScript, context): Executes full script
---  - MapScriptExecutor.executeCommand(command, context): Single command
---  - MapScriptExecutor.createContext(map, seed): Creates execution context
---  - MapScriptExecutor.validateScript(mapScript): Validates script syntax
---
---Dependencies:
---  - battlescape.maps.mapblock_loader_v2: MapBlock loading
---
---@module battlescape.mapscripts.mapscript_executor
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")
---  local context = MapScriptExecutor.createContext(map, 12345)
---  MapScriptExecutor.execute(mapScript, context)
---
---@see battlescape.maps.map_generation_pipeline For usage

-- Map Script Executor - OpenXCOM-style Command Execution
-- Executes Map Script commands to generate maps

local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")

local MapScriptExecutor = {}

---@class ExecutionContext
---@field map table The map grid being built
---@field mapWidth number Map width in tiles
---@field mapHeight number Map height in tiles
---@field blockWidth number Block width (15)
---@field blockHeight number Block height (15)
---@field seed number Random seed
---@field rng table Random number generator
---@field usedBlocks table<string, number> Block usage counts {blockId -> count}
---@field labels table<string, number> Label positions for conditionals
---@field script table The Map Script being executed
---@field craftSpawn table? Craft spawn position {x, y, blockId}
---@field ufoObjective table? UFO objective position {x, y, blockId}
---@field width number Map width in tiles (alias for mapWidth)
---@field height number Map height in tiles (alias for mapHeight)

---Create new execution context
---@param script table Map Script
---@param seed number Random seed
---@return ExecutionContext
function MapScriptExecutor.createContext(script, seed)
    seed = seed or os.time()
    
    -- Initialize random number generator
    local rng = love.math.newRandomGenerator(seed)
    
    -- Calculate map dimensions
    local mapWidth = script.mapSize[1] * 15  -- blocks to tiles
    local mapHeight = script.mapSize[2] * 15
    
    local context = {
        map = {},
        mapWidth = mapWidth,
        mapHeight = mapHeight,
        width = mapWidth,  -- Alias for compatibility
        height = mapHeight,  -- Alias for compatibility
        blockWidth = 15,
        blockHeight = 15,
        seed = seed,
        rng = rng,
        usedBlocks = {},
        labels = script.labels or {},
        script = script
    }
    
    -- Initialize empty map grid
    for y = 0, mapHeight - 1 do
        context.map[y] = {}
        for x = 0, mapWidth - 1 do
            context.map[y][x] = nil  -- Empty tile
        end
    end
    
    print(string.format("[MapScriptExecutor] Context created: %dx%d tiles (seed: %d)", 
        mapWidth, mapHeight, seed))
    
    return context
end

---Execute a Map Script
---@param script table Map Script to execute
---@param seed number? Random seed (optional)
---@return ExecutionContext context The execution result
function MapScriptExecutor.execute(script, seed)
    print(string.format("[MapScriptExecutor] Executing script: %s", script.id))
    
    local context = MapScriptExecutor.createContext(script, seed)
    
    -- Execute commands in sequence
    local commandIndex = 1
    while commandIndex <= #script.commands do
        local cmd = script.commands[commandIndex]
        
        -- Check execution chance
        local chance = cmd.chance or 100
        if context.rng:random(1, 100) > chance then
            print(string.format("[MapScriptExecutor] Skipped command %d (chance: %d%%)", 
                commandIndex, chance))
            commandIndex = commandIndex + 1
            goto continue
        end
        
        -- Execute command
        local success, nextIndex = MapScriptExecutor.executeCommand(context, cmd, commandIndex)
        
        if not success then
            print(string.format("[MapScriptExecutor] Command %d failed: %s", 
                commandIndex, cmd.type))
        end
        
        -- Move to next command (or jump to label)
        if nextIndex then
            commandIndex = nextIndex
        else
            commandIndex = commandIndex + 1
        end
        
        ::continue::
    end
    
    print(string.format("[MapScriptExecutor] Execution complete: %s", script.id))
    return context
end

---Execute a single command
---@param context ExecutionContext Execution context
---@param cmd table Command to execute
---@param cmdIndex number Current command index
---@return boolean success Whether command succeeded
---@return number? nextIndex Next command index (for jumps)
function MapScriptExecutor.executeCommand(context, cmd, cmdIndex)
    local cmdType = cmd.type
    
    print(string.format("[MapScriptExecutor] Executing: %s", cmdType))
    
    -- Load command module
    local commandModule = MapScriptExecutor.getCommandModule(cmdType)
    if not commandModule then
        print(string.format("[MapScriptExecutor] Unknown command: %s", cmdType))
        return false
    end
    
    -- Execute command
    local success, result = pcall(commandModule.execute, context, cmd)
    
    if not success then
        print(string.format("[MapScriptExecutor] Error executing %s: %s", cmdType, tostring(result)))
        return false
    end
    
    -- Handle conditional jumps
    if cmd.label and cmd.conditionals then
        local nextIndex = MapScriptExecutor.evaluateConditionals(context, cmd)
        return true, nextIndex
    end
    
    return true
end

---Get command module
---@param cmdType string Command type
---@return table? Command module
function MapScriptExecutor.getCommandModule(cmdType)
    -- Lazy load command modules
    local modulePath = "battlescape.logic.mapscript_commands." .. cmdType
    local success, module = pcall(require, modulePath)
    
    if success then
        return module
    else
        print(string.format("[MapScriptExecutor] Failed to load command module: %s", modulePath))
        return nil
    end
end

---Evaluate conditionals and return next command index
---@param context ExecutionContext Execution context
---@param cmd table Command with conditionals
---@return number? nextIndex Next command index or nil
function MapScriptExecutor.evaluateConditionals(context, cmd)
    if not cmd.conditionals then
        return nil
    end
    
    for _, conditional in ipairs(cmd.conditionals) do
        local condition = conditional.condition
        local gotoLabel = conditional.goto
        
        -- Evaluate condition
        local result = MapScriptExecutor.evaluateCondition(context, condition)
        
        if result and gotoLabel then
            local labelIndex = context.labels[gotoLabel]
            if labelIndex then
                print(string.format("[MapScriptExecutor] Jumping to label: %s (index %d)", 
                    gotoLabel, labelIndex))
                return labelIndex
            else
                print(string.format("[MapScriptExecutor] Label not found: %s", gotoLabel))
            end
        end
    end
    
    return nil
end

---Evaluate a condition
---@param context ExecutionContext Execution context
---@param condition string Condition expression
---@return boolean result Condition result
function MapScriptExecutor.evaluateCondition(context, condition)
    -- Simple condition evaluation
    -- Format: "blockUsed(blockId) > 5"
    
    if condition:match("^blockUsed") then
        local blockId, op, value = condition:match("blockUsed%(\"([^\"]+)\")%s*([<>=!]+)%s*(%d+)")
        if blockId and op and value then
            local count = context.usedBlocks[blockId] or 0
            value = tonumber(value)
            
            if op == ">" then
                return count > value
            elseif op == "<" then
                return count < value
            elseif op == ">=" then
                return count >= value
            elseif op == "<=" then
                return count <= value
            elseif op == "==" then
                return count == value
            elseif op == "!=" then
                return count ~= value
            end
        end
    elseif condition:match("^mapFilled") then
        local percentage = condition:match("mapFilled%s*([<>=!]+)%s*(%d+)")
        if percentage then
            local filledCount = 0
            local totalCount = context.mapWidth * context.mapHeight
            
            for y = 0, context.mapHeight - 1 do
                for x = 0, context.mapWidth - 1 do
                    if context.map[y][x] then
                        filledCount = filledCount + 1
                    end
                end
            end
            
            local fillPercentage = (filledCount / totalCount) * 100
            local targetPercentage = tonumber(percentage)
            
            -- Parse operator from condition
            local op = condition:match("mapFilled%s*([<>=!]+)")
            if op == ">" then
                return fillPercentage > targetPercentage
            elseif op == "<" then
                return fillPercentage < targetPercentage
            elseif op == ">=" then
                return fillPercentage >= targetPercentage
            elseif op == "<=" then
                return fillPercentage <= targetPercentage
            end
        end
    end
    
    return false
end

---Place a Map Block on the map
---@param context ExecutionContext Execution context
---@param block table Map Block to place
---@param startX number Start X in tiles
---@param startY number Start Y in tiles
---@return boolean success Whether placement succeeded
function MapScriptExecutor.placeBlock(context, block, startX, startY)
    -- Check bounds
    if startX < 0 or startY < 0 or 
       startX + block.width > context.mapWidth or 
       startY + block.height > context.mapHeight then
        print(string.format("[MapScriptExecutor] Block placement out of bounds: %s at (%d, %d)", 
            block.id, startX, startY))
        return false
    end
    
    -- Place tiles
    local placedCount = 0
    for coord, tileKey in pairs(block.tiles) do
        local x, y = coord:match("(%d+)_(%d+)")
        x, y = tonumber(x), tonumber(y)
        
        if x and y then
            local mapX = startX + x
            local mapY = startY + y
            
            if mapX < context.mapWidth and mapY < context.mapHeight then
                context.map[mapY][mapX] = tileKey
                placedCount = placedCount + 1
            end
        end
    end
    
    -- Track usage
    context.usedBlocks[block.id] = (context.usedBlocks[block.id] or 0) + 1
    
    print(string.format("[MapScriptExecutor] Placed block: %s at (%d, %d) - %d tiles", 
        block.id, startX, startY, placedCount))
    
    return true
end

---Check if area is empty
---@param context ExecutionContext Execution context
---@param startX number Start X in tiles
---@param startY number Start Y in tiles
---@param width number Width in tiles
---@param height number Height in tiles
---@return boolean isEmpty Whether area is empty
function MapScriptExecutor.isAreaEmpty(context, startX, startY, width, height)
    for y = startY, startY + height - 1 do
        for x = startX, startX + width - 1 do
            if x >= context.mapWidth or y >= context.mapHeight then
                return false
            end
            if context.map[y] and context.map[y][x] then
                return false
            end
        end
    end
    return true
end

---Get map statistics
---@param context ExecutionContext Execution context
---@return table stats {filled, empty, fillPercentage}
function MapScriptExecutor.getStats(context)
    local filled = 0
    local total = context.mapWidth * context.mapHeight
    
    for y = 0, context.mapHeight - 1 do
        for x = 0, context.mapWidth - 1 do
            if context.map[y][x] then
                filled = filled + 1
            end
        end
    end
    
    return {
        filled = filled,
        empty = total - filled,
        total = total,
        fillPercentage = (filled / total) * 100
    }
end

return MapScriptExecutor


























