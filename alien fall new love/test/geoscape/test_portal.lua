--- Test Portal.lua
-- Tests for Portal class

local test_framework = require("test.framework.test_framework")
local Portal = require("src.geoscape.Portal")

local PortalTest = {}

function PortalTest.test_portal_creation()
    local data = {
        id = "wormhole_1",
        name = "Alpha Centauri Wormhole",
        type = "wormhole",
        location_province_id = "earth_base",
        location_world_id = "earth",
        destination_province_id = "alien_colony",
        destination_world_id = "xenon",
        properties = {
            stability = 0.8,
            traffic_capacity = 2,
            travel_time = 300
        }
    }

    local portal = Portal:new(data)

    test_framework.assert_equal(portal.id, "wormhole_1")
    test_framework.assert_equal(portal.type, "wormhole")
    test_framework.assert_true(portal:isInterWorld())
    test_framework.assert_equal(portal:getStability(), 0.8)
    test_framework.assert_equal(portal:getTrafficCapacity(), 2)
    test_framework.assert_equal(portal:getTravelTime(), 300)
end

function PortalTest.test_intra_world_portal()
    local data = {
        id = "tunnel_1",
        name = "Underground Tunnel",
        type = "tunnel",
        location_province_id = "city_a",
        location_world_id = "earth",
        destination_province_id = "city_b",
        destination_world_id = "earth"  -- Same world
    }

    local portal = Portal:new(data)

    test_framework.assert_false(portal:isInterWorld())
end

function PortalTest.test_portal_states()
    local portal = Portal:new({
        id = "test_portal",
        status = "dormant"
    })

    test_framework.assert_false(portal:isActive())
    test_framework.assert_true(portal:isDormant())
    test_framework.assert_false(portal:isUnstable())

    portal.status = "active"
    test_framework.assert_true(portal:isActive())

    portal.status = "unstable"
    test_framework.assert_true(portal:isUnstable())
end

function PortalTest.test_stability_management()
    local portal = Portal:new({
        id = "test_portal",
        properties = {stability = 0.5}
    })

    test_framework.assert_equal(portal:getStability(), 0.5)

    portal:setStability(0.9)
    test_framework.assert_equal(portal:getStability(), 0.9)

    -- Test clamping
    portal:setStability(1.5)
    test_framework.assert_equal(portal:getStability(), 1.0)

    portal:setStability(-0.5)
    test_framework.assert_equal(portal:getStability(), 0.0)
end

function PortalTest.test_activation_requirements()
    local portal = Portal:new({
        id = "test_portal",
        requirements = {
            research = {"portal_tech", "stability_field"},
            activation = {"power_core", "stabilizer"}
        }
    })

    -- Test research requirements
    test_framework.assert_false(portal:meetsResearchRequirements({}))
    test_framework.assert_false(portal:meetsResearchRequirements({portal_tech = true}))
    test_framework.assert_true(portal:meetsResearchRequirements({
        portal_tech = true,
        stability_field = true
    }))

    -- Test activation requirements
    test_framework.assert_false(portal:canBeActivated({}))
    test_framework.assert_false(portal:canBeActivated({power_core = 1}))
    test_framework.assert_true(portal:canBeActivated({
        power_core = 1,
        stabilizer = 1
    }))
end

function PortalTest.test_detection_requirements()
    local portal = Portal:new({
        id = "test_portal",
        requirements = {
            detection = {"sensor_array", "quantum_scanner"}
        }
    })

    test_framework.assert_false(portal:canBeDetected({}))
    test_framework.assert_false(portal:canBeDetected({sensor_array = true}))
    test_framework.assert_true(portal:canBeDetected({
        sensor_array = true,
        quantum_scanner = true
    }))
end

function PortalTest.test_travel_success_calculation()
    local portal = Portal:new({
        id = "test_portal",
        properties = {stability = 1.0},
        effects = {reliability = 1.0}
    })

    -- Perfect conditions
    local success = portal:calculateTravelSuccess(100, 50)  -- Max skill and equipment
    test_framework.assert_true(success >= 95)  -- Should be near 100%

    -- Poor conditions
    portal:setStability(0.1)  -- Very unstable
    success = portal:calculateTravelSuccess(0, 0)  -- No skill or equipment
    test_framework.assert_true(success >= 5 and success <= 95)  -- Should be clamped
end

function PortalTest.test_travel_mechanics()
    local portal = Portal:new({
        id = "test_portal",
        status = "active",
        properties = {stability = 1.0},
        effects = {reliability = 1.0}
    })

    -- Mock event bus
    local events = {}
    portal.event_bus = {
        publish = function(event, data)
            table.insert(events, {event = event, data = data})
        end
    }

    -- Successful travel
    local success = portal:travel("test_craft", 100, 50)
    test_framework.assert_true(success)
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].event, "portal:travel_attempted")
    test_framework.assert_true(events[1].data.success)

    -- Check stability reduction
    test_framework.assert_true(portal:getStability() < 1.0)
end

function PortalTest.test_portal_activation()
    local portal = Portal:new({
        id = "test_portal",
        status = "dormant"
    })

    -- Mock event bus
    local events = {}
    portal.event_bus = {
        publish = function(event, data)
            table.insert(events, {event = event, data = data})
        end
    }

    portal:activate("player_command")
    test_framework.assert_true(portal:isActive())
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].event, "portal:activated")

    portal:deactivate()
    test_framework.assert_true(portal:isDormant())
end

function PortalTest.test_display_info()
    local portal = Portal:new({
        id = "test_portal",
        name = "Test Portal",
        type = "wormhole",
        status = "active",
        location_province_id = "earth_base",
        location_world_id = "earth",
        destination_province_id = "alien_base",
        destination_world_id = "mars",
        properties = {
            stability = 0.75,
            travel_time = 600,
            fuel_cost = 100
        }
    })

    local info = portal:getDisplayInfo()

    test_framework.assert_equal(info.id, "test_portal")
    test_framework.assert_equal(info.type, "wormhole")
    test_framework.assert_equal(info.status, "active")
    test_framework.assert_true(info.is_inter_world)
    test_framework.assert_equal(info.stability, 0.75)
    test_framework.assert_equal(info.travel_time, 600)
    test_framework.assert_equal(info.fuel_cost, 100)
end

--- Run all Portal tests
function PortalTest.run()
    test_framework.run_suite("Portal", {
        test_portal_creation = PortalTest.test_portal_creation,
        test_intra_world_portal = PortalTest.test_intra_world_portal,
        test_stability_management = PortalTest.test_stability_management,
        test_activation_requirements = PortalTest.test_activation_requirements,
        test_detection_requirements = PortalTest.test_detection_requirements,
        test_travel_success_calculation = PortalTest.test_travel_success_calculation,
        test_travel_mechanics = PortalTest.test_travel_mechanics,
        test_portal_activation = PortalTest.test_portal_activation,
        test_display_info = PortalTest.test_display_info
    })
end

return PortalTest