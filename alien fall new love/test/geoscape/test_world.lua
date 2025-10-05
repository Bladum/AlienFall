--- Test World.lua
-- Tests for World class

local test_framework = require("test.framework.test_framework")
local World = require("src.geoscape.World")
local Province = require("src.geoscape.Province")
local Country = require("src.geoscape.Country")
local Region = require("src.geoscape.Region")
local Portal = require("src.geoscape.Portal")

local WorldTest = {}

function WorldTest.test_world_creation()
    local data = {
        id = "earth",
        name = "Earth",
        config = {rotation_period = 24},
        scale = {pixel_to_km = 25}
    }

    local world = World:new(data)

    test_framework.assert_equal(world.id, "earth")
    test_framework.assert_equal(world.name, "Earth")
    test_framework.assert_equal(world.rotation_period, 24)
    test_framework.assert_equal(world:getPixelToKmRatio(), 25)
end

function WorldTest.test_province_management()
    local world = World:new({id = "earth"})

    -- Create province
    local province_data = {
        id = "new_york",
        name = "New York",
        coordinates = {100, 200},
        biome_id = "urban",
        economy_value = 80
    }
    local province = Province:new(province_data)

    -- Add province
    world:addProvince(province)

    test_framework.assert_equal(world:getProvince("new_york"), province)
    test_framework.assert_equal(province.world, world)
    test_framework.assert_equal(#world:getProvinces(), 1)
end

function WorldTest.test_country_management()
    local world = World:new({id = "earth"})

    -- Create country
    local country_data = {
        id = "usa",
        name = "United States",
        province_ids = {"new_york", "los_angeles"}
    }
    local country = Country:new(country_data)

    -- Add country
    world:addCountry(country)

    test_framework.assert_equal(world:getCountry("usa"), country)
    test_framework.assert_equal(country.world, world)
    test_framework.assert_equal(#world:getCountries(), 1)
end

function WorldTest.test_region_management()
    local world = World:new({id = "earth"})

    -- Create region
    local region_data = {
        id = "northeast",
        name = "Northeast",
        province_ids = {"new_york", "boston"},
        classification = {"urban", "coastal"}
    }
    local region = Region:new(region_data)

    -- Add region
    world:addRegion(region)

    test_framework.assert_equal(world:getRegion("northeast"), region)
    test_framework.assert_equal(region.world, world)
    test_framework.assert_equal(#world:getRegions(), 1)
end

function WorldTest.test_portal_management()
    local world = World:new({id = "earth"})

    -- Create portal
    local portal_data = {
        id = "portal_1",
        name = "Mysterious Portal",
        type = "wormhole",
        location_province_id = "new_york",
        location_world_id = "earth",
        destination_province_id = "mars_city",
        destination_world_id = "mars"
    }
    local portal = Portal:new(portal_data)

    -- Add portal
    world:addPortal(portal)

    test_framework.assert_equal(world:getPortal("portal_1"), portal)
    test_framework.assert_true(portal:isInterWorld())
end

function WorldTest.test_coordinate_conversion()
    local world = World:new({
        id = "earth",
        tile_map = {
            tile_width = 20,
            tile_height = 20
        }
    })

    -- Test pixel to tile conversion
    local tile_x, tile_y = world:pixelToTile(50, 80)
    test_framework.assert_equal(tile_x, 3)  -- (50 / 20) + 1 = 3.5 -> 3
    test_framework.assert_equal(tile_y, 5)  -- (80 / 20) + 1 = 5

    -- Test tile to pixel conversion
    local pixel_x, pixel_y = world:tileToPixel(3, 5)
    test_framework.assert_equal(pixel_x, 50)  -- (3-1) * 20 + 10 = 50
    test_framework.assert_equal(pixel_y, 90)  -- (5-1) * 20 + 10 = 90
end

function WorldTest.test_distance_calculation()
    local world = World:new({id = "earth"})

    -- Create provinces
    local province1 = Province:new({
        id = "prov1",
        coordinates = {0, 0}
    })
    local province2 = Province:new({
        id = "prov2",
        coordinates = {100, 0}
    })

    world:addProvince(province1)
    world:addProvince(province2)

    -- Test pixel distance
    local pixel_distance = world:calculatePixelDistance(province1, province2)
    test_framework.assert_equal(pixel_distance, 100)
end

function WorldTest.test_illumination()
    local world = World:new({
        id = "earth",
        config = {rotation_period = 24}
    })

    -- Create province
    local province = Province:new({
        id = "test_prov",
        longitude = 0  -- At prime meridian
    })
    world:addProvince(province)

    -- Test illumination at different rotation angles
    world.current_rotation = 0  -- Midnight
    local illumination = world:getIlluminationAt(province)
    test_framework.assert_true(illumination < 0.5)  -- Should be dark

    world.current_rotation = 180  -- Noon
    illumination = world:getIlluminationAt(province)
    test_framework.assert_true(illumination > 0.5)  -- Should be light
end

function WorldTest.test_time_advancement()
    local world = World:new({id = "earth"})

    -- Create province
    local province = Province:new({
        id = "test_prov",
        alien_activity = 0.5
    })
    world:addProvince(province)

    local initial_activity = province:getAlienActivity()

    -- Advance time
    world:advanceTime(10)

    -- Activity should have changed (with some randomness)
    test_framework.assert_true(province:getAlienActivity() >= 0)
    test_framework.assert_true(province:getAlienActivity() <= 1)
end

function WorldTest.test_statistics()
    local world = World:new({id = "earth"})

    -- Add some entities
    world:addProvince(Province:new({id = "prov1"}))
    world:addProvince(Province:new({id = "prov2"}))
    world:addCountry(Country:new({id = "country1"}))
    world:addRegion(Region:new({id = "region1"}))

    local stats = world:getStatistics()
    test_framework.assert_equal(stats.provinces, 2)
    test_framework.assert_equal(stats.countries, 1)
    test_framework.assert_equal(stats.regions, 1)
end

--- Run all World tests
function WorldTest.run()
    test_framework.run_suite("World", {
        test_world_creation = WorldTest.test_world_creation,
        test_province_management = WorldTest.test_province_management,
        test_country_management = WorldTest.test_country_management,
        test_region_management = WorldTest.test_region_management,
        test_portal_management = WorldTest.test_portal_management,
        test_coordinate_conversion = WorldTest.test_coordinate_conversion,
        test_distance_calculation = WorldTest.test_distance_calculation,
        test_illumination = WorldTest.test_illumination,
        test_time_advancement = WorldTest.test_time_advancement,
        test_statistics = WorldTest.test_statistics
    })
end

return WorldTest