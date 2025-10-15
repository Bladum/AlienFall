-- Test Tileset System
-- Validates tileset loading, Map Tile parsing, and KEY resolution

-- Add engine path for requires
package.path = package.path .. ";../engine/?.lua;../engine/?/init.lua"

local Tilesets = require("battlescape.data.tilesets")

local function testTilesetSystem()
    print("\n=== Testing Tileset System ===\n")
    
    -- Test 1: Load all tilesets
    print("Test 1: Loading all tilesets...")
    Tilesets.loadAll("mods/core")
    
    local tilesetCount = Tilesets.getCount()
    local tileCount = Tilesets.getTileCount()
    
    print(string.format("  ? Loaded %d tilesets with %d total tiles", tilesetCount, tileCount))
    assert(tilesetCount > 0, "Should load at least one tileset")
    assert(tileCount > 0, "Should load at least one tile")
    
    -- Test 2: Verify specific tiles
    print("\nTest 2: Verifying specific tiles...")
    
    local grassTile = Tilesets.getTile("GRASS")
    assert(grassTile, "Should find GRASS tile")
    assert(grassTile.tileset == "_common", "GRASS should be in _common tileset")
    assert(grassTile.passable == true, "GRASS should be passable")
    print("  ? GRASS tile found and valid")
    
    local wallBrickTile = Tilesets.getTile("WALL_BRICK")
    assert(wallBrickTile, "Should find WALL_BRICK tile")
    assert(wallBrickTile.tileset == "city", "WALL_BRICK should be in city tileset")
    assert(wallBrickTile.passable == false, "WALL_BRICK should not be passable")
    assert(wallBrickTile.cover == "full", "WALL_BRICK should provide full cover")
    print("  ? WALL_BRICK tile found and valid")
    
    local treePineTile = Tilesets.getTile("TREE_PINE")
    assert(treePineTile, "Should find TREE_PINE tile")
    assert(treePineTile.tileset == "farmland", "TREE_PINE should be in farmland tileset")
    assert(treePineTile.cover == "heavy", "TREE_PINE should provide heavy cover")
    assert(treePineTile.flammable == true, "TREE_PINE should be flammable")
    print("  ? TREE_PINE tile found and valid")
    
    -- Test 3: Verify multi-tile tiles
    print("\nTest 3: Verifying multi-tile tiles...")
    
    local tableLargeTile = Tilesets.getTile("TABLE_LARGE")
    assert(tableLargeTile, "Should find TABLE_LARGE tile")
    assert(tableLargeTile:isMultiTile(), "TABLE_LARGE should be multi-tile")
    assert(tableLargeTile.multiTileMode == "occupy", "TABLE_LARGE should use occupy mode")
    assert(tableLargeTile.cellWidth == 2, "TABLE_LARGE should be 2 cells wide")
    assert(tableLargeTile.cellHeight == 2, "TABLE_LARGE should be 2 cells tall")
    print("  ? TABLE_LARGE multi-tile found and valid")
    
    -- Test 4: List all tilesets
    print("\nTest 4: Listing all tilesets...")
    local tilesetIds = Tilesets.getAllIds()
    for _, id in ipairs(tilesetIds) do
        local tiles = Tilesets.getTileset(id)
        local count = 0
        for _ in pairs(tiles) do count = count + 1 end
        print(string.format("  - %s: %d tiles", id, count))
    end
    
    -- Test 5: Filter tiles
    print("\nTest 5: Filtering tiles...")
    
    local passableTiles = Tilesets.findTiles(function(tile)
        return tile:isPassable()
    end)
    print(string.format("  ? Found %d passable tiles", #passableTiles))
    
    local destructibleTiles = Tilesets.findTiles(function(tile)
        return tile:isDestructible()
    end)
    print(string.format("  ? Found %d destructible tiles", #destructibleTiles))
    
    local coverTiles = Tilesets.findTiles(function(tile)
        return tile:getCover() ~= "none"
    end)
    print(string.format("  ? Found %d tiles providing cover", #coverTiles))
    
    -- Test 6: Validate tile properties
    print("\nTest 6: Validating tile properties...")
    local invalidCount = 0
    for key, tile in pairs(Tilesets.tileIndex) do
        local valid, err = tile:validate()
        if not valid then
            print(string.format("  ? Invalid tile %s: %s", key, err))
            invalidCount = invalidCount + 1
        end
    end
    if invalidCount == 0 then
        print("  ? All tiles valid")
    else
        print(string.format("  ? %d invalid tiles found", invalidCount))
    end
    
    -- Test 7: Test unloading
    print("\nTest 7: Testing unload functionality...")
    local beforeCount = Tilesets.getTileCount()
    Tilesets.unload("_common")
    local afterCount = Tilesets.getTileCount()
    assert(afterCount < beforeCount, "Tile count should decrease after unload")
    print(string.format("  ? Unloaded _common tileset (%d -> %d tiles)", beforeCount, afterCount))
    
    -- Reload for further tests
    Tilesets.load("_common")
    print("  ? Reloaded _common tileset")
    
    print("\n=== All Tileset Tests Passed! ===\n")
    return true
end

-- Run tests
local success, err = pcall(testTilesetSystem)
if not success then
    print("\n? TEST FAILED: " .. tostring(err))
    print(debug.traceback())
    return false
end

return true






















