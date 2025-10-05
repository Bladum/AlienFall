--- Test Universe.lua
-- Tests for Universe class

local test_framework = require("test.framework.test_framework")
local Universe = require("src.geoscape.Universe")
local World = require("src.geoscape.World")

local UniverseTest = {}

function UniverseTest.test_universe_creation()
    local data = {
        id = "test_universe",
        name = "Test Universe",
        description = "A test universe"
    }

    local universe = Universe:new(data)

    test_framework.assert_equal(universe.id, "test_universe")
    test_framework.assert_equal(universe.name, "Test Universe")
    test_framework.assert_equal(#universe.world_order, 0)
end

function UniverseTest.test_world_management()
    local universe = Universe:new({id = "test_universe"})

    -- Create a mock world
    local world_data = {
        id = "earth",
        name = "Earth",
        config = {rotation_period = 24}
    }
    local world = World:new(world_data)

    -- Add world
    universe:addWorld(world)

    test_framework.assert_equal(#universe.world_order, 1)
    test_framework.assert_equal(universe:getWorld("earth"), world)
    test_framework.assert_equal(world.universe, universe)

    -- Remove world
    universe:removeWorld("earth")
    test_framework.assert_equal(#universe.world_order, 0)
    test_framework.assert_nil(universe:getWorld("earth"))
end

function UniverseTest.test_travel_requirements()
    local universe = Universe:new({id = "test_universe"})

    -- Set travel requirements
    universe:setTravelRequirements("earth", "mars", {
        research = {"portal_tech", "ftl_drive"}
    })

    local requirements = universe:getTravelRequirements("earth", "mars")
    test_framework.assert_not_nil(requirements)
    test_framework.assert_equal(#requirements.research, 2)
end

function UniverseTest.test_travel_validation()
    local universe = Universe:new({id = "test_universe"})

    -- Create worlds
    local earth = World:new({id = "earth", name = "Earth"})
    local mars = World:new({id = "mars", name = "Mars"})
    universe:addWorld(earth)
    universe:addWorld(mars)

    -- Set travel requirements
    universe:setTravelRequirements("earth", "mars", {
        research = {"portal_tech"}
    })

    -- Test same world travel (should always work)
    test_framework.assert_true(universe:canTravelBetweenWorlds("earth", "earth", {}))

    -- Test without required research
    test_framework.assert_false(universe:canTravelBetweenWorlds("earth", "mars", {}))

    -- Test with required research
    test_framework.assert_true(universe:canTravelBetweenWorlds("earth", "mars", {portal_tech = true}))
end

function UniverseTest.test_time_advancement()
    local universe = Universe:new({id = "test_universe"})

    -- Create a world
    local world = World:new({id = "earth", name = "Earth"})
    universe:addWorld(world)

    -- Advance time
    universe:advanceTime(30)  -- 30 days

    test_framework.assert_equal(universe.current_time, 30)
end

function UniverseTest.test_campaign_management()
    local universe = Universe:new({
        id = "test_universe",
        campaigns = {
            alien_invasion = {
                id = "alien_invasion",
                name = "Alien Invasion",
                activation_time = 10,
                required_worlds = {"earth"}
            }
        }
    })

    -- Create world
    local earth = World:new({id = "earth", name = "Earth"})
    universe:addWorld(earth)

    -- Advance time to activate campaign
    universe:advanceTime(15)

    local active_campaigns = universe:getActiveCampaigns()
    test_framework.assert_equal(#active_campaigns, 1)
    test_framework.assert_not_nil(active_campaigns.alien_invasion)
end

function UniverseTest.test_statistics()
    local universe = Universe:new({id = "test_universe"})

    -- Create worlds with provinces/countries/regions
    local earth = World:new({id = "earth", name = "Earth"})
    universe:addWorld(earth)

    local mars = World:new({id = "mars", name = "Mars"})
    universe:addWorld(mars)

    local stats = universe:getStatistics()
    test_framework.assert_equal(stats.total_worlds, 2)
    test_framework.assert_equal(stats.active_campaigns, 0)
end

--- Run all Universe tests
function UniverseTest.run()
    test_framework.run_suite("Universe", {
        test_universe_creation = UniverseTest.test_universe_creation,
        test_world_management = UniverseTest.test_world_management,
        test_travel_requirements = UniverseTest.test_travel_requirements,
        test_statistics = UniverseTest.test_statistics
    })
end

return UniverseTest