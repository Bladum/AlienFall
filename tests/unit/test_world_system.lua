-- Unit Tests for Geoscape World System
-- Tests world generation, hex coordinates, provinces, and day/night cycles

local WorldSystemTest = {}

-- Test world creation
function WorldSystemTest.testCreate()
    local World = require("geoscape.world.world")
    
    local world = World.new({
        width = 80,
        height = 60
    })
    
    assert(world ~= nil, "World not created")
    assert(world.width == 80, "Wrong width")
    assert(world.height == 60, "Wrong height")
    assert(world.tiles ~= nil, "Tiles table missing")
    assert(world.provinces ~= nil, "Provinces table missing")
    
    print("✓ testCreate passed")
end

-- Test hex coordinate system
function WorldSystemTest.testHexCoordinates()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    -- Test hex to pixel conversion
    local pixelX, pixelY = world:hexToPixel(10, 15)
    assert(type(pixelX) == "number", "Pixel X not a number")
    assert(type(pixelY) == "number", "Pixel Y not a number")
    
    -- Test pixel to hex conversion (round trip)
    local hexQ, hexR = world:pixelToHex(pixelX, pixelY)
    assert(hexQ == 10, "Hex Q mismatch after round trip")
    assert(hexR == 15, "Hex R mismatch after round trip")
    
    print("✓ testHexCoordinates passed")
end

-- Test tile get/set
function WorldSystemTest.testTiles()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    -- Set a tile
    world:setTile(10, 15, "OCEAN", 2, false)
    
    -- Get the tile
    local tile = world:getTile(10, 15)
    assert(tile ~= nil, "Tile not found")
    assert(tile.terrain == "OCEAN", "Wrong terrain")
    assert(tile.cost == 2, "Wrong cost")
    assert(tile.isLand == false, "Wrong land status")
    
    print("✓ testTiles passed")
end

-- Test province management
function WorldSystemTest.testProvinces()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    -- Add a province
    local province = {
        id = "province_test",
        name = "Test Province",
        hexes = {{q = 10, r = 15}, {q = 11, r = 15}},
        country = "USA"
    }
    
    world:addProvince(province)
    
    -- Get province by ID
    local retrieved = world:getProvince("province_test")
    assert(retrieved ~= nil, "Province not found")
    assert(retrieved.name == "Test Province", "Wrong province name")
    
    -- Get province at hex
    local atHex = world:getProvinceAtHex(10, 15)
    assert(atHex ~= nil, "Province not found at hex")
    assert(atHex.id == "province_test", "Wrong province at hex")
    
    print("✓ testProvinces passed")
end

-- Test day advancement
function WorldSystemTest.testDayAdvancement()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    local initialDate = world:getDate()
    local initialTurn = world:getTurn()
    
    -- Advance one day
    world:advanceDay()
    
    local newDate = world:getDate()
    local newTurn = world:getTurn()
    
    assert(newDate.day == initialDate.day + 1 or newDate.month > initialDate.month, 
           "Day not advanced")
    assert(newTurn == initialTurn + 1, "Turn not incremented")
    
    print("✓ testDayAdvancement passed")
end

-- Test light level and day/night
function WorldSystemTest.testLightLevel()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    -- Get light level at a position
    local lightLevel = world:getLightLevel(10, 15)
    assert(type(lightLevel) == "number", "Light level not a number")
    assert(lightLevel >= 0 and lightLevel <= 1, "Light level out of range")
    
    -- Check day/night
    local isDay = world:isDay(10, 15)
    assert(type(isDay) == "boolean", "isDay not a boolean")
    
    print("✓ testLightLevel passed")
end

-- Test world dimensions
function WorldSystemTest.testDimensions()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    local width, height = world:getDimensions()
    assert(width == 80, "Wrong width returned")
    assert(height == 60, "Wrong height returned")
    
    local scale = world:getScale()
    assert(type(scale) == "number", "Scale not a number")
    assert(scale > 0, "Scale not positive")
    
    print("✓ testDimensions passed")
end

-- Test province count
function WorldSystemTest.testProvinceCount()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    assert(world:getProvinceCount() == 0, "Initial province count not zero")
    
    -- Add provinces
    world:addProvince({id = "p1", name = "Province 1", hexes = {}})
    world:addProvince({id = "p2", name = "Province 2", hexes = {}})
    
    assert(world:getProvinceCount() == 2, "Province count incorrect")
    
    local allProvinces = world:getAllProvinces()
    assert(#allProvinces == 2, "getAllProvinces count mismatch")
    
    print("✓ testProvinceCount passed")
end

-- Test serialization
function WorldSystemTest.testSerialization()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    -- Add some data
    world:setTile(10, 15, "LAND", 1, true)
    world:addProvince({id = "p1", name = "Province 1", hexes = {}})
    
    -- Serialize
    local data = world:serialize()
    assert(data ~= nil, "Serialization failed")
    assert(data.width == 80, "Width not serialized")
    assert(data.date ~= nil, "Date not serialized")
    
    -- Create new world and deserialize
    local world2 = World.new({width = 80, height = 60})
    world2:deserialize(data)
    
    assert(world2:getProvinceCount() > 0, "Provinces not deserialized")
    
    print("✓ testSerialization passed")
end

-- Test daily events processing
function WorldSystemTest.testDailyEvents()
    local World = require("geoscape.world.world")
    
    local world = World.new({width = 80, height = 60})
    
    -- Should not crash
    local success, err = pcall(function()
        world:processDailyEvents()
    end)
    
    assert(success, "Daily events processing failed: " .. tostring(err))
    
    print("✓ testDailyEvents passed")
end

-- Run all tests
function WorldSystemTest.runAll()
    print("\n=== World System Tests ===")
    
    WorldSystemTest.testCreate()
    WorldSystemTest.testHexCoordinates()
    WorldSystemTest.testTiles()
    WorldSystemTest.testProvinces()
    WorldSystemTest.testDayAdvancement()
    WorldSystemTest.testLightLevel()
    WorldSystemTest.testDimensions()
    WorldSystemTest.testProvinceCount()
    WorldSystemTest.testSerialization()
    WorldSystemTest.testDailyEvents()
    
    print("✓ All World System tests passed!\n")
end

return WorldSystemTest



