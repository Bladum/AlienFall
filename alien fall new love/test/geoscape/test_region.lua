--- Test Region.lua
-- Tests for Region class

local test_framework = require("test.framework.test_framework")
local Region = require("src.geoscape.Region")

local RegionTest = {}

function RegionTest.test_region_creation()
    local data = {
        id = "northeast",
        name = "Northeast",
        province_ids = {"new_york", "boston", "philadelphia"},
        classification = {"urban", "coastal"},
        base_spawn_weight = 1.5
    }

    local region = Region:new(data)

    test_framework.assert_equal(region.id, "northeast")
    test_framework.assert_equal(region.name, "Northeast")
    test_framework.assert_equal(#region.province_ids, 3)
    test_framework.assert_equal(region:getSpawnWeight(), 1.5)
end

function RegionTest.test_province_containment()
    local region = Region:new({
        id = "test_region",
        province_ids = {"prov1", "prov2", "prov3"}
    })

    test_framework.assert_true(region:containsProvince("prov1"))
    test_framework.assert_true(region:containsProvince("prov2"))
    test_framework.assert_false(region:containsProvince("prov4"))
end

function RegionTest.test_classification()
    local region = Region:new({
        id = "test_region",
        classification = {"arctic", "coastal", "urban"}
    })

    test_framework.assert_true(region:hasClassification("arctic"))
    test_framework.assert_true(region:hasClassification("coastal"))
    test_framework.assert_false(region:hasClassification("desert"))
end

function RegionTest.test_spawn_weight_modifiers()
    local region = Region:new({
        id = "test_region",
        base_spawn_weight = 1.0
    })

    -- Test base weight
    test_framework.assert_equal(region:getSpawnWeight(), 1.0)

    -- Add modifier
    region:adjustSpawnWeight("campaign_modifier", 2.0)
    test_framework.assert_equal(region:getSpawnWeight(), 2.0)

    -- Add another modifier
    region:adjustSpawnWeight("event_modifier", 0.5)
    test_framework.assert_equal(region:getSpawnWeight(), 1.0)  -- 2.0 * 0.5

    -- Remove modifier
    region:removeSpawnWeightModifier("campaign_modifier")
    test_framework.assert_equal(region:getSpawnWeight(), 0.5)
end

function RegionTest.test_faction_preferences()
    local region = Region:new({
        id = "test_region",
        faction_preferences = {
            sectoids = 1.5,
            mutons = 0.8
        }
    })

    test_framework.assert_equal(region:getFactionPreference("sectoids"), 1.5)
    test_framework.assert_equal(region:getFactionPreference("mutons"), 0.8)
    test_framework.assert_equal(region:getFactionPreference("unknown"), 1.0)  -- Default
end

function RegionTest.test_mission_filtering()
    local region = Region:new({
        id = "ocean_region",
        mission_tags = {"ocean"},
        blocked_missions = {"land_assault"}
    })

    -- Test allowed missions
    test_framework.assert_true(region:isMissionAllowed("naval_patrol"))
    test_framework.assert_false(region:isMissionAllowed("land_assault"))

    -- Test with explicit allowed list
    region.allowed_missions = {"ocean_patrol", "research"}
    test_framework.assert_true(region:isMissionAllowed("ocean_patrol"))
    test_framework.assert_false(region:isMissionAllowed("land_assault"))
end

function RegionTest.test_telemetry()
    local region = Region:new({id = "test_region"})

    -- Record incidents
    region:recordIncident("ufo_sighting")
    region:recordIncident("terror_attack")

    -- Record resources
    region:recordResourceYield(100)
    region:recordResourceYield(50)

    -- Update score
    region:updatePublicScore(25)

    local telemetry = region:getTelemetry()
    test_framework.assert_equal(telemetry.incident_count, 2)
    test_framework.assert_equal(telemetry.resource_yield, 150)
    test_framework.assert_equal(telemetry.public_score, 25)
end

function RegionTest.test_time_advancement()
    local region = Region:new({
        id = "test_region",
        spawn_modifiers = {
            ["temp_boost_timer"] = 10  -- 10 days remaining
        }
    })

    -- Advance time
    region:advanceTime(5)

    -- Timer should be reduced
    test_framework.assert_equal(region.spawn_modifiers["temp_boost_timer"], 5)

    -- Advance past timer expiration
    region:advanceTime(6)
    test_framework.assert_nil(region.spawn_modifiers["temp_boost_timer"])
end

function RegionTest.test_aggregated_statistics()
    local region = Region:new({
        id = "test_region",
        province_ids = {"prov1", "prov2"}
    })

    -- Mock provinces
    local mock_provinces = {
        {
            getEconomyValue = function() return 50 end,
            getPopulation = function() return 1000000 end,
            getAlienActivity = function() return 0.3 end,
            isPlayerControlled = function() return true end,
            base_present = true,
            getActiveMissionCount = function() return 2 end
        },
        {
            getEconomyValue = function() return 75 end,
            getPopulation = function() return 2000000 end,
            getAlienActivity = function() return 0.7 end,
            isPlayerControlled = function() return false end,
            isAlienControlled = function() return true end,
            base_present = false,
            getActiveMissionCount = function() return 1 end
        }
    }

    -- Mock getProvinces method
    region.getProvinces = function() return mock_provinces end

    local stats = region:getAggregatedStatistics()

    test_framework.assert_equal(stats.total_provinces, 2)
    test_framework.assert_equal(stats.total_economy, 125)
    test_framework.assert_equal(stats.total_population, 3000000)
    test_framework.assert_equal(stats.player_controlled_provinces, 1)
    test_framework.assert_equal(stats.alien_controlled_provinces, 1)
    test_framework.assert_equal(stats.bases_present, 1)
    test_framework.assert_equal(stats.active_missions, 3)
end

--- Run all Region tests
function RegionTest.run()
    test_framework.run_suite("Region", {
        test_region_creation = RegionTest.test_region_creation,
        test_province_containment = RegionTest.test_province_containment,
        test_classification = RegionTest.test_classification,
        test_spawn_weight_modifiers = RegionTest.test_spawn_weight_modifiers,
        test_faction_preferences = RegionTest.test_faction_preferences,
        test_mission_filtering = RegionTest.test_mission_filtering,
        test_telemetry = RegionTest.test_telemetry,
        test_aggregated_statistics = RegionTest.test_aggregated_statistics
    })
end

return RegionTest