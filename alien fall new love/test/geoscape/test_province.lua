--- Test Province.lua
-- Tests for Province class

local test_framework = require("test.framework.test_framework")
local Province = require("src.geoscape.Province")

local ProvinceTest = {}

function ProvinceTest.test_province_creation()
    local data = {
        id = "new_york",
        name = "New York",
        coordinates = {100, 200},
        biome_id = "urban",
        economy_value = 80,
        region_id = "northeast",
        country_id = "usa"
    }

    local province = Province:new(data)

    test_framework.assert_equal(province.id, "new_york")
    test_framework.assert_equal(province.name, "New York")
    test_framework.assert_equal(province:getCoordinates(), 100, 200)
    test_framework.assert_equal(province:getBiomeId(), "urban")
    test_framework.assert_equal(province:getEconomyValue(), 80)
end

function ProvinceTest.test_adjacency()
    local province1 = Province:new({
        id = "prov1",
        adjacencies = {"prov2", "prov3"}
    })

    test_framework.assert_true(province1:isAdjacentTo("prov2"))
    test_framework.assert_true(province1:isAdjacentTo("prov3"))
    test_framework.assert_false(province1:isAdjacentTo("prov4"))
end

function ProvinceTest.test_control()
    local province = Province:new({id = "test_prov"})

    -- Test initial state
    test_framework.assert_equal(province.controlled_by, "neutral")
    test_framework.assert_false(province:isPlayerControlled())
    test_framework.assert_false(province:isAlienControlled())

    -- Set player control
    province:setControl("player")
    test_framework.assert_true(province:isPlayerControlled())
    test_framework.assert_false(province:isAlienControlled())

    -- Set alien control
    province:setControl("alien")
    test_framework.assert_false(province:isPlayerControlled())
    test_framework.assert_true(province:isAlienControlled())
end

function ProvinceTest.test_base_hosting()
    local land_province = Province:new({
        id = "land_prov",
        is_water = false
    })

    local water_province = Province:new({
        id = "water_prov",
        is_water = true
    })

    test_framework.assert_true(land_province:canHostBase())
    test_framework.assert_false(water_province:canHostBase())

    -- Test with existing base
    land_province.base_present = true
    test_framework.assert_false(land_province:canHostBase())
end

function ProvinceTest.test_mission_management()
    local province = Province:new({
        id = "test_prov",
        max_concurrent_missions = 2
    })

    -- Test adding missions
    local mission1 = {id = "mission1", type = "recon"}
    local mission2 = {id = "mission2", type = "combat"}
    local mission3 = {id = "mission3", type = "research"}

    test_framework.assert_true(province:addMission(mission1))
    test_framework.assert_true(province:addMission(mission2))
    test_framework.assert_false(province:addMission(mission3))  -- At capacity

    test_framework.assert_equal(province:getActiveMissionCount(), 2)
    test_framework.assert_true(province:canAcceptMission())

    -- Test removing mission
    province:removeMission("mission1")
    test_framework.assert_equal(province:getActiveMissionCount(), 1)
    test_framework.assert_true(province:canAcceptMission())
end

function ProvinceTest.test_tags()
    local province = Province:new({
        id = "test_prov",
        tags = {"urban", "coastal", "industrial"}
    })

    test_framework.assert_true(province:hasTag("urban"))
    test_framework.assert_true(province:hasTag("coastal"))
    test_framework.assert_false(province:hasTag("rural"))
end

function ProvinceTest.test_time_advancement()
    local province = Province:new({
        id = "test_prov",
        alien_activity = 0.5
    })

    local initial_activity = province.alien_activity

    -- Advance time
    province:advanceTime(10)

    -- Activity should be clamped between 0 and 1
    test_framework.assert_true(province.alien_activity >= 0)
    test_framework.assert_true(province.alien_activity <= 1)
end

function ProvinceTest.test_detection_range()
    local province = Province:new({
        id = "urban_prov",
        tags = {"urban"}
    })

    local rural_province = Province:new({
        id = "rural_prov",
        tags = {"rural"}
    })

    local urban_range = province:calculateDetectionRange(100)
    local rural_range = rural_province:calculateDetectionRange(100)

    -- Urban should have better detection
    test_framework.assert_true(urban_range >= rural_range)
end

function ProvinceTest.test_display_info()
    local province = Province:new({
        id = "test_prov",
        name = "Test Province",
        economy_value = 75,
        alien_activity = 0.8,
        controlled_by = "player",
        base_present = true
    })

    local info = province:getDisplayInfo()

    test_framework.assert_equal(info.id, "test_prov")
    test_framework.assert_equal(info.economy_value, 75)
    test_framework.assert_equal(info.alien_activity, 0.8)
    test_framework.assert_equal(info.controlled_by, "player")
    test_framework.assert_true(info.base_present)
end

--- Run all Province tests
function ProvinceTest.run()
    test_framework.run_suite("Province", {
        test_province_creation = ProvinceTest.test_province_creation,
        test_adjacency = ProvinceTest.test_adjacency,
        test_control = ProvinceTest.test_control,
        test_base_hosting = ProvinceTest.test_base_hosting,
        test_mission_management = ProvinceTest.test_mission_management,
        test_tags = ProvinceTest.test_tags,
        test_time_advancement = ProvinceTest.test_time_advancement,
        test_detection_range = ProvinceTest.test_detection_range,
        test_display_info = ProvinceTest.test_display_info
    })
end

return ProvinceTest