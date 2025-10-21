---MapBlockSystem - Procedural Map Block Manager
---
---Manages procedural map generation using pre-designed 15×15 tile blocks. Blocks are
---arranged in a rotated hex grid pattern (45° angle) for varied terrain layouts. Supports
---TOML-based block definitions with biome categorization.
---
---Features:
---  - Block library loading from TOML files
---  - Rotated hex grid arrangement (45° angle)
---  - Biome-based block filtering
---  - Random block selection with weights
---  - Block caching for performance
---  - MapScript integration
---
---Block Structure:
---  - Size: 15×15 tiles per block
---  - Format: TOML with KEY-based tiles
---  - Biome: Tagged for terrain matching
---  - Placement: Hex grid coordinates
---
---Grid Layout:
---  - Rotated hex grid (45° rotation)
---  - Block spacing: 15 tiles
---  - Neighbor calculation: Hex adjacency
---
---Key Exports:
---  - MapBlockSystem.init(): Initializes system
---  - MapBlockSystem.loadBlocks(biomeId): Loads blocks for biome
---  - MapBlockSystem.selectBlock(biome, criteria): Random block selection
---  - MapBlockSystem.placeBlock(map, block, x, y, rotation): Places block on map
---  - MapBlockSystem.getBlockLibrary(): Returns cached blocks
---
---Dependencies:
---  - battlescape.maps.mapblock_loader_v2: TOML block loading
---  - battlescape.mapscripts.mapscript_executor: Script execution
---  - battlescape.data.mapscripts_v2: Script definitions
---
---@module battlescape.maps.mapblock_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapBlockSystem = require("battlescape.maps.mapblock_system")
---  MapBlockSystem.init()
---  local block = MapBlockSystem.selectBlock("urban", {difficulty = 5})
---  MapBlockSystem.placeBlock(map, block, 0, 0, 0)
---
---@see battlescape.maps.mapblock_loader_v2 For block loading

-- Hex Map Block System
-- Manages procedural map generation using 15x15 tile blocks
-- Blocks are arranged in a rotated hex grid (45° angle)

local MapBlockLoader = require("battlescape.maps.mapblock_loader_v2")
local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")
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


























