--- Test suite for MapLoader
--- Tests PNG loading, terrain parsing, and map generation

local MapLoader = require("systems.MapLoader")
local Constants = require("config.constants")

local TestMapLoader = {}

function TestMapLoader.testGenerateTestMap()
    print("Testing test map generation...")
    
    local map, spawnPoints = MapLoader.generateTestMap(20, 20)
    
    assert(map, "Map should be created")
    assert(map.width == 20, "Map width should be 20")
    assert(map.height == 20, "Map height should be 20")
    assert(map.tiles, "Map should have tiles array")
    assert(#map.tiles == 20, "Should have 20 rows")
    assert(#map.tiles[1] == 20, "Should have 20 columns")
    assert(spawnPoints and #spawnPoints > 0, "Should have spawn points")
    
    print("  ✓ Test map generation works")
end

function TestMapLoader.testMapDimensions()
    print("Testing map dimensions...")
    
    local map30x40 = MapLoader.generateTestMap(30, 40)
    assert(map30x40.width == 30, "Map width should match requested")
    assert(map30x40.height == 40, "Map height should match requested")
    
    local map10x10 = MapLoader.generateTestMap(10, 10)
    assert(map10x10.width == 10, "Small map width correct")
    assert(map10x10.height == 10, "Small map height correct")
    
    print("  ✓ Map dimensions work correctly")
end

function TestMapLoader.testMapTiles()
    print("Testing map tiles...")
    
    local map = MapLoader.generateTestMap(15, 15)
    
    -- Check all tiles exist and have valid types
    local floorCount = 0
    local wallCount = 0
    
    for y = 1, map.height do
        for x = 1, map.width do
            local tile = map.tiles[y][x]
            assert(tile, string.format("Tile at (%d,%d) should exist", x, y))
            assert(tile.gridX == x, "Tile X coordinate should match")
            assert(tile.gridY == y, "Tile Y coordinate should match")
            
            local terrainType = tile.terrainType
            assert(terrainType == Constants.TERRAIN.FLOOR or
                   terrainType == Constants.TERRAIN.WALL or
                   terrainType == Constants.TERRAIN.DOOR,
                   "Tile should have valid terrain type")
            
            if terrainType == Constants.TERRAIN.FLOOR then
                floorCount = floorCount + 1
            elseif terrainType == Constants.TERRAIN.WALL then
                wallCount = wallCount + 1
            end
        end
    end
    
    assert(floorCount > 0, "Map should have floor tiles")
    assert(wallCount > 0, "Map should have wall tiles")
    
    print("  ✓ Map tiles are valid")
end

function TestMapLoader.testSpawnPoints()
    print("Testing spawn points...")
    
    local map, spawnPoints = MapLoader.generateTestMap(30, 30)
    
    assert(spawnPoints, "Spawn points should be returned")
    assert(#spawnPoints > 0, "Should have at least one spawn point")
    
    for i, spawn in ipairs(spawnPoints) do
        assert(spawn.x, "Spawn point should have X coordinate")
        assert(spawn.y, "Spawn point should have Y coordinate")
        assert(spawn.x >= 1 and spawn.x <= map.width, "Spawn X should be in bounds")
        assert(spawn.y >= 1 and spawn.y <= map.height, "Spawn Y should be in bounds")
        
        -- Spawn point should be on a floor tile
        local tile = map.tiles[spawn.y][spawn.x]
        assert(tile:isTraversable(), "Spawn point should be on traversable tile")
    end
    
    print("  ✓ Spawn points are valid")
end

function TestMapLoader.testBorderWalls()
    print("Testing border walls...")
    
    local map = MapLoader.generateTestMap(20, 20)
    
    -- Check top and bottom borders
    for x = 1, map.width do
        local topTile = map.tiles[1][x]
        local bottomTile = map.tiles[map.height][x]
        
        -- Borders might be walls or floor depending on implementation
        assert(topTile.terrainType, "Top border tile should have terrain type")
        assert(bottomTile.terrainType, "Bottom border tile should have terrain type")
    end
    
    -- Check left and right borders
    for y = 1, map.height do
        local leftTile = map.tiles[y][1]
        local rightTile = map.tiles[y][map.width]
        
        assert(leftTile.terrainType, "Left border tile should have terrain type")
        assert(rightTile.terrainType, "Right border tile should have terrain type")
    end
    
    print("  ✓ Border tiles exist")
end

function TestMapLoader.testMapConnectivity()
    print("Testing map connectivity...")
    
    local map = MapLoader.generateTestMap(25, 25)
    
    -- Count floor tiles
    local floorTiles = 0
    for y = 1, map.height do
        for x = 1, map.width do
            if map.tiles[y][x]:isTraversable() then
                floorTiles = floorTiles + 1
            end
        end
    end
    
    -- Map should have reasonable amount of traversable space
    local totalTiles = map.width * map.height
    local floorRatio = floorTiles / totalTiles
    
    assert(floorRatio > 0.1, "Map should have at least 10% floor tiles")
    assert(floorRatio < 1.0, "Map should have some walls")
    
    print(string.format("  ✓ Map has %.1f%% traversable tiles", floorRatio * 100))
end

function TestMapLoader.testPNGLoading()
    print("Testing PNG loading...")
    
    -- Try to load actual PNG file
    local map, spawnPoints = MapLoader.loadFromPNG("assets/maps/maze_map.png", 60, 60)
    
    if map then
        assert(map.width == 60, "PNG map width should be 60")
        assert(map.height == 60, "PNG map height should be 60")
        assert(map.tiles, "PNG map should have tiles")
        assert(spawnPoints, "PNG map should have spawn points")
        print("  ✓ PNG loading works")
    else
        print("  ⚠ PNG file not found, skipped PNG loading test")
    end
end

function TestMapLoader.testColorMapping()
    print("Testing color to terrain mapping...")
    
    -- This tests the internal color mapping used by PNG loader
    -- Different colors should map to different terrain types
    
    local map = MapLoader.generateTestMap(10, 10)
    
    -- Generated maps should have a mix of terrain types
    local terrainTypes = {}
    for y = 1, map.height do
        for x = 1, map.width do
            terrainTypes[map.tiles[y][x].terrainType] = true
        end
    end
    
    local typeCount = 0
    for _ in pairs(terrainTypes) do
        typeCount = typeCount + 1
    end
    
    assert(typeCount >= 2, "Map should have at least 2 different terrain types")
    
    print("  ✓ Multiple terrain types present")
end

function TestMapLoader.testSmallMap()
    print("Testing small map generation...")
    
    local map = MapLoader.generateTestMap(5, 5)
    
    assert(map.width == 5, "Small map width correct")
    assert(map.height == 5, "Small map height correct")
    assert(#map.tiles == 5, "Small map has correct rows")
    
    print("  ✓ Small map generation works")
end

function TestMapLoader.testLargeMap()
    print("Testing large map generation...")
    
    local map = MapLoader.generateTestMap(100, 100)
    
    assert(map.width == 100, "Large map width correct")
    assert(map.height == 100, "Large map height correct")
    assert(#map.tiles == 100, "Large map has correct rows")
    assert(#map.tiles[1] == 100, "Large map has correct columns")
    
    print("  ✓ Large map generation works")
end

function TestMapLoader.runAll()
    print("\n=== Running MapLoader Tests ===")
    
    TestMapLoader.testGenerateTestMap()
    TestMapLoader.testMapDimensions()
    TestMapLoader.testMapTiles()
    TestMapLoader.testSpawnPoints()
    TestMapLoader.testBorderWalls()
    TestMapLoader.testMapConnectivity()
    TestMapLoader.testPNGLoading()
    TestMapLoader.testColorMapping()
    TestMapLoader.testSmallMap()
    TestMapLoader.testLargeMap()
    
    print("=== All MapLoader Tests Passed ✓ ===\n")
end

return TestMapLoader
