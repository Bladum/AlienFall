-- Mock Map Data
-- Provides test data for map generation and battlescape tests

local MockMaps = {}

--- Get a mock map configuration
-- @param size string Map size (default: "MEDIUM")
-- @param biome string Biome type (default: "URBAN")
-- @return table Mock map config
function MockMaps.getMapConfig(size, biome)
    size = size or "MEDIUM"
    biome = biome or "URBAN"
    
    local sizes = {
        SMALL = {gridSize = 4, dimensions = {width = 40, height = 40}},
        MEDIUM = {gridSize = 5, dimensions = {width = 50, height = 50}},
        LARGE = {gridSize = 6, dimensions = {width = 60, height = 60}},
        HUGE = {gridSize = 7, dimensions = {width = 70, height = 70}}
    }
    
    local config = sizes[size] or sizes.MEDIUM
    
    return {
        size = size,
        biome = biome,
        gridSize = config.gridSize,
        dimensions = config.dimensions,
        landingZones = size == "SMALL" and 1 or (size == "MEDIUM" and 2 or 3),
        tileset = biome:lower(),
        heightLevels = 3
    }
end

--- Get mock mapblock data
-- @return table Mock mapblock
function MockMaps.getMapBlock()
    return {
        id = "test_block_01",
        width = 10,
        height = 10,
        layers = 3,
        tiles = {},
        entryPoints = {
            {x = 0, y = 5, direction = "EAST"},
            {x = 9, y = 5, direction = "WEST"}
        },
        objects = {
            {type = "COVER", x = 3, y = 3, height = 1},
            {type = "BUILDING", x = 5, y = 5, height = 2}
        }
    }
end

--- Generate mock map tiles
-- @param width number Map width
-- @param height number Map height
-- @return table 2D array of tiles
function MockMaps.generateTiles(width, height)
    width = width or 20
    height = height or 20
    
    local tiles = {}
    for y = 1, height do
        tiles[y] = {}
        for x = 1, width do
            tiles[y][x] = {
                type = math.random() > 0.3 and "FLOOR" or "EMPTY",
                height = 0,
                cover = math.random() > 0.7,
                occupied = false
            }
        end
    end
    
    return tiles
end

--- Get mock landing zones
-- @param count number Number of landing zones
-- @return table Array of landing zones
function MockMaps.getLandingZones(count)
    count = count or 2
    
    local zones = {}
    for i = 1, count do
        table.insert(zones, {
            id = "LZ" .. i,
            name = "Landing Zone " .. i,
            x = math.random(5, 50),
            y = math.random(5, 50),
            width = 3,
            height = 3,
            capacity = 6,
            available = true
        })
    end
    
    return zones
end

--- Validate mock map configuration
-- @param config table Map configuration to validate
-- @return boolean isValid True if valid
-- @return string? error Error message if invalid
function MockMaps.validateMapConfig(config)
    if not config then
        return false, "Map config is nil"
    end
    
    if not config.size then
        return false, "Map config missing size"
    end
    
    if not config.dimensions then
        return false, "Map config missing dimensions"
    end
    
    if not config.dimensions.width or not config.dimensions.height then
        return false, "Map config dimensions missing width/height"
    end
    
    if config.dimensions.width <= 0 or config.dimensions.height <= 0 then
        return false, "Map dimensions must be positive"
    end
    
    if config.landingZones and config.landingZones < 0 then
        return false, "Landing zones cannot be negative"
    end
    
    return true, nil
end

--- Validate mock mapblock
-- @param mapblock table Mapblock to validate
-- @return boolean isValid True if valid
-- @return string? error Error message if invalid
function MockMaps.validateMapBlock(mapblock)
    if not mapblock then
        return false, "Mapblock is nil"
    end
    
    if not mapblock.id then
        return false, "Mapblock missing id"
    end
    
    if not mapblock.width or not mapblock.height then
        return false, "Mapblock missing width/height"
    end
    
    if mapblock.width <= 0 or mapblock.height <= 0 then
        return false, "Mapblock dimensions must be positive"
    end
    
    if not mapblock.layers or mapblock.layers <= 0 then
        return false, "Mapblock must have positive layers"
    end
    
    return true, nil
end

--- Generate realistic map configurations with validation
-- @param count number Number of configs to generate
-- @return table Array of validated map configs
function MockMaps.generateValidatedConfigs(count)
    count = count or 5
    
    local configs = {}
    for i = 1, count do
        local config = MockMaps.getMapConfig()
        local isValid, error = MockMaps.validateMapConfig(config)
        if isValid then
            table.insert(configs, config)
        else
            print("[MockMaps] Generated invalid config: " .. error)
        end
    end
    
    return configs
end

--- Get mock tileset data
-- @param biome string Biome type
-- @return table Mock tileset
function MockMaps.getTileset(biome)
    biome = biome or "URBAN"
    
    return {
        id = biome:lower(),
        name = biome .. " Tileset",
        tiles = {
            {id = "FLOOR_01", type = "FLOOR", image = "floor_01.png"},
            {id = "WALL_01", type = "WALL", image = "wall_01.png", blocks = true},
            {id = "COVER_01", type = "COVER", image = "cover_01.png", coverValue = 50}
        },
        objects = {
            {id = "TREE", image = "tree.png", blocks = true, height = 2},
            {id = "CRATE", image = "crate.png", blocks = true, cover = 60}
        }
    }
end

--- Generate a simple test map
-- @param size string Map size
-- @return table Complete map data
function MockMaps.generateTestMap(size)
    size = size or "MEDIUM"
    local config = MockMaps.getMapConfig(size, "URBAN")
    
    return {
        config = config,
        tiles = MockMaps.generateTiles(config.dimensions.width, config.dimensions.height),
        landingZones = MockMaps.getLandingZones(config.landingZones),
        mapBlocks = {MockMaps.getMapBlock()},
        tileset = MockMaps.getTileset(config.biome)
    }
end

--- Get mock map generation parameters
-- @return table Map gen params
function MockMaps.getGenerationParams()
    return {
        seed = 12345,
        algorithm = "CELLULAR_AUTOMATA",
        density = 0.45,
        iterations = 4,
        smoothing = true,
        minRoomSize = 4,
        maxRooms = 8,
        corridorWidth = 2,
        heightVariation = true
    }
end

return MockMaps






















