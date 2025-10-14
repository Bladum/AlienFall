-- Hex Map Block System
-- Manages procedural map generation using 15x15 tile blocks
-- Blocks are arranged in a rotated hex grid (45° angle)

local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.logic.mapscript_executor")
local MapScriptsV2 = require("battlescape.data.mapscripts_v2")

--- @class MapBlockSystem
--- Manages procedural map generation using pre-designed 15x15 tile blocks.
--- Blocks are arranged in a rotated hex grid pattern for varied terrain layouts.
--- Supports TOML-based block definitions with biome categorization.
---
--- @field blockLibrary table[] Cached array of loaded MapBlock objects
local MapBlockSystem = {}

-- Map block library (cached)
MapBlockSystem.blockLibrary = {}

--- Loads all MapBlock definitions from a directory containing TOML files.
--- Blocks are cached in blockLibrary for reuse across generations.
---
--- @param directory string Path to directory containing TOML block files
--- @return number count Number of blocks loaded
function MapBlockSystem.loadLibrary(directory)
    print(string.format("[MapBlockSystem] Loading block library from: %s", directory))

    local count = MapBlockLoader.loadAll(directory)
    MapBlockSystem.blockLibrary = MapBlockLoader.blocks

    print(string.format("[MapBlockSystem] Loaded %d blocks", count))
    return count
end

--- Creates a procedural battlefield by arranging map blocks using MapScript system.
--- Uses the MapScriptExecutor to generate varied terrain layouts.
---
--- @param gridWidth number Width of the block grid (number of blocks)
--- @param gridHeight number Height of the block grid (number of blocks)
--- @param mapScriptId string? Optional MapScript ID (auto-selects if nil)
--- @return table|nil Generated execution context, or nil if generation fails
function MapBlockSystem.generateBattlefield(gridWidth, gridHeight, mapScriptId)
    print(string.format("[MapBlockSystem] Generating %dx%d battlefield from blocks", gridWidth, gridHeight))

    -- Auto-select MapScript if not provided
    if not mapScriptId then
        local scripts = MapScriptsV2.getAll()
        for id, script in pairs(scripts) do
            if script.mapSize and script.mapSize[1] == gridWidth and script.mapSize[2] == gridHeight then
                mapScriptId = id
                print(string.format("[MapBlockSystem] Auto-selected MapScript: %s", id))
                break
            end
        end
        
        -- Fallback: use first available script
        if not mapScriptId then
            for id, _ in pairs(scripts) do
                mapScriptId = id
                print(string.format("[MapBlockSystem] Using fallback MapScript: %s", id))
                break
            end
        end
    end

    if not mapScriptId then
        print("[MapBlockSystem] No suitable MapScript found for size")
        return nil
    end
    
    -- Get MapScript
    local script = MapScriptsV2.get(mapScriptId)
    if not script then
        print(string.format("[MapBlockSystem] MapScript not found: %s", tostring(mapScriptId)))
        return nil
    end
    
    -- Execute MapScript
    local seed = os.time()
    print(string.format("[MapBlockSystem] Executing MapScript with seed: %d", seed))
    
    local context = MapScriptExecutor.execute(script, seed)
    
    if not context then
        print("[MapBlockSystem] MapScript execution failed")
        return nil
    end
    
    -- Log statistics
    local stats = MapScriptExecutor.getStats(context)
    print(string.format("[MapBlockSystem] Generation complete: %.1f%% filled", stats.fillPercentage))
    
    return context
end

return MapBlockSystem

