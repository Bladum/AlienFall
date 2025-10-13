-- Hex Map Block System
-- Manages procedural map generation using 15x15 tile blocks
-- Blocks are arranged in a rotated hex grid (45° angle)

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
--- @return table[] Array of loaded MapBlock objects
function MapBlockSystem.loadLibrary(directory)
    print(string.format("[MapBlockSystem] Loading block library from: %s", directory))

    -- TODO: Implement TOML loading
    -- For now, return empty library
    local blocks = {}

    print(string.format("[MapBlockSystem] Loaded %d blocks", #blocks))
    return blocks
end

--- Creates a procedural battlefield by arranging map blocks in a hex grid pattern.
--- Uses the provided block library to generate varied terrain layouts.
---
--- @param gridWidth number Width of the block grid (number of blocks)
--- @param gridHeight number Height of the block grid (number of blocks)
--- @param blockLibrary table[] Array of available MapBlock objects to use
--- @return Battlefield|nil Generated battlefield, or nil if generation fails
function MapBlockSystem.generateBattlefield(gridWidth, gridHeight, blockLibrary)
    print(string.format("[MapBlockSystem] Generating %dx%d battlefield from blocks", gridWidth, gridHeight))

    -- TODO: Implement GridMap generation

    return nil
end

return MapBlockSystem
