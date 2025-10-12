--- Test suite for Tile class
--- Tests terrain types, visibility, occupancy, and LOS blocking

local Tile = require("classes.Tile")
local Constants = require("config.constants")

local TestTile = {}

function TestTile.testTileCreation()
    print("Testing Tile creation...")
    
    local tile = Tile.new(5, 10, Constants.TERRAIN.FLOOR)
    
    assert(tile.gridX == 5, "Tile X position incorrect")
    assert(tile.gridY == 10, "Tile Y position incorrect")
    assert(tile.terrainType == Constants.TERRAIN.FLOOR, "Terrain type incorrect")
    assert(tile.occupant == nil, "New tile should not have occupant")
    
    print("  ✓ Tile creation successful")
end

function TestTile.testFloorTraversable()
    print("Testing floor traversability...")
    
    local floor = Tile.new(1, 1, Constants.TERRAIN.FLOOR)
    assert(floor:isTraversable() == true, "Floor should be traversable")
    assert(floor:blocksLOS() == false, "Floor should not block LOS")
    
    print("  ✓ Floor is traversable and doesn't block LOS")
end

function TestTile.testWallBlocking()
    print("Testing wall blocking...")
    
    local wall = Tile.new(1, 1, Constants.TERRAIN.WALL)
    assert(wall:isTraversable() == false, "Wall should not be traversable")
    assert(wall:blocksLOS() == true, "Wall should block LOS")
    
    print("  ✓ Wall blocks movement and LOS")
end

function TestTile.testDoorTraversable()
    print("Testing door traversability...")
    
    local door = Tile.new(1, 1, Constants.TERRAIN.DOOR)
    assert(door:isTraversable() == true, "Door should be traversable")
    assert(door:blocksLOS() == false, "Door should not block LOS")
    
    print("  ✓ Door is traversable and doesn't block LOS")
end

function TestTile.testVisibility()
    print("Testing visibility system...")
    
    local tile = Tile.new(1, 1, Constants.TERRAIN.FLOOR)
    
    -- Initial state: all teams have hidden visibility
    for teamId = 1, 4 do
        assert(tile:getVisibility(teamId) == Constants.VISIBILITY.HIDDEN, 
               "Initial visibility should be HIDDEN")
    end
    
    -- Set visible for team 1
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.VISIBLE)
    assert(tile:isVisibleTo(Constants.TEAM.PLAYER), "Tile should be visible to player")
    assert(not tile:isVisibleTo(Constants.TEAM.ENEMY), "Tile should not be visible to enemy")
    
    -- Set explored for team 2
    tile:setVisibility(Constants.TEAM.ALLY, Constants.VISIBILITY.EXPLORED)
    assert(tile:isExploredBy(Constants.TEAM.ALLY), "Tile should be explored by ally")
    assert(not tile:isVisibleTo(Constants.TEAM.ALLY), "Explored tile is not currently visible")
    
    print("  ✓ Visibility tracking works correctly")
end

function TestTile.testOccupancy()
    print("Testing tile occupancy...")
    
    local tile = Tile.new(1, 1, Constants.TERRAIN.FLOOR)
    local mockUnit = {id = 1, name = "TestUnit"}
    
    assert(tile:isOccupied() == false, "New tile should not be occupied")
    assert(tile:getOccupant() == nil, "New tile should have no occupant")
    
    tile:setOccupant(mockUnit)
    assert(tile:isOccupied() == true, "Tile should be occupied after setting occupant")
    assert(tile:getOccupant() == mockUnit, "Should return correct occupant")
    
    tile:setOccupant(nil)
    assert(tile:isOccupied() == false, "Tile should not be occupied after clearing")
    
    print("  ✓ Occupancy tracking works correctly")
end

function TestTile.testBrightness()
    print("Testing brightness calculation...")
    
    local tile = Tile.new(1, 1, Constants.TERRAIN.FLOOR)
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.HIDDEN)
    assert(tile:getBrightness(Constants.TEAM.PLAYER) == Constants.LIGHT_HIDDEN,
           "Hidden tile should have HIDDEN brightness")
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.EXPLORED)
    assert(tile:getBrightness(Constants.TEAM.PLAYER) == Constants.LIGHT_EXPLORED,
           "Explored tile should have EXPLORED brightness")
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.VISIBLE)
    assert(tile:getBrightness(Constants.TEAM.PLAYER) == Constants.LIGHT_VISIBLE,
           "Visible tile should have VISIBLE brightness")
    
    print("  ✓ Brightness calculation works correctly")
end

function TestTile.testUpdate()
    print("Testing tile update...")
    
    local tile = Tile.new(1, 1, Constants.TERRAIN.FLOOR)
    local mockEffect = {
        update = function(self, dt) self.time = (self.time or 0) + dt end,
        isExpired = function(self) return self.time and self.time > 1.0 end
    }
    
    tile:setEffect(mockEffect)
    assert(tile:getEffect() == mockEffect, "Effect should be set")
    
    -- Update for 0.5 seconds
    tile:update(0.5)
    assert(tile:getEffect() == mockEffect, "Effect should still be present")
    
    -- Update for another 0.6 seconds (total 1.1)
    tile:update(0.6)
    assert(tile:getEffect() == nil, "Expired effect should be removed")
    
    print("  ✓ Tile update and effect management works")
end

function TestTile.runAll()
    print("\n=== Running Tile Tests ===")
    
    TestTile.testTileCreation()
    TestTile.testFloorTraversable()
    TestTile.testWallBlocking()
    TestTile.testDoorTraversable()
    TestTile.testVisibility()
    TestTile.testOccupancy()
    TestTile.testBrightness()
    TestTile.testUpdate()
    
    print("=== All Tile Tests Passed ✓ ===\n")
end

return TestTile
