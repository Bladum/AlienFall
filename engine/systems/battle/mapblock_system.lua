-- Hex Map Block System
-- Manages procedural map generation using 15x15 tile blocks
-- Blocks are arranged in a rotated hex grid (45° angle)

--[[
    ARCHITECTURE OVERVIEW
    
    1. MapBlock: 15x15 tile template loaded from TOML
       - Contains terrain data for each tile
       - Self-contained but edge-compatible
       - Can be multi-size (15x15, 30x15, 45x15, etc.)
    
    2. GridMap: 4x4 to 7x7 array of MapBlocks
       - Randomly selects blocks from library
       - Arranges in rotated hex grid pattern
       - Assembles into single Battlefield
    
    3. HexRotated: Coordinate conversion utilities
       - Block grid coords → World tile coords
       - 45° rotated hex grid mathematics
       - Screen rendering transformations
    
    COORDINATE SYSTEMS
    
    - Block Grid: (blockX, blockY) in grid array [0-6, 0-6]
    - World Tiles: (tileX, tileY) in assembled battlefield [1-90, 1-90]
    - Local Tiles: (localX, localY) within a block [1-15, 1-15]
    - Axial Hex: (q, r) for hex mathematics
    - Offset Hex: (col, row) for square grid simulation
    
    ROTATED HEX GRID
    
    The image shows red hexes arranged at 45° angle:
    - Standard hex grid rotated 45 degrees
    - Even rows offset by half block width
    - Maintains hex neighbor relationships
    - Visual "diamond" pattern on square tiles
    
    TOML FORMAT
    
    [metadata]
    id = "urban_01"
    name = "Urban Intersection"
    width = 15
    height = 15
    biome = "urban"
    
    [tiles]
    # Format: "row_col" = "terrain_id"
    "0_0" = "road"
    "0_1" = "road"
    ...
    
    USAGE
    
    -- Load block library
    local blocks = MapBlockSystem.loadLibrary("mods/core/mapblocks/")
    
    -- Generate random grid map
    local gridMap = GridMap.new(5, 5)
    gridMap:generateRandom(blocks)
    
    -- Convert to battlefield
    local battlefield = gridMap:toBattlefield()
]]

local MapBlockSystem = {}

-- Map block library (cached)
MapBlockSystem.blockLibrary = {}

-- Load all MapBlocks from directory
function MapBlockSystem.loadLibrary(directory)
    print(string.format("[MapBlockSystem] Loading block library from: %s", directory))
    
    -- TODO: Implement TOML loading
    -- For now, return empty library
    local blocks = {}
    
    print(string.format("[MapBlockSystem] Loaded %d blocks", #blocks))
    return blocks
end

-- Create procedural battlefield from blocks
function MapBlockSystem.generateBattlefield(gridWidth, gridHeight, blockLibrary)
    print(string.format("[MapBlockSystem] Generating %dx%d battlefield from blocks", gridWidth, gridHeight))
    
    -- TODO: Implement GridMap generation
    
    return nil
end

return MapBlockSystem
