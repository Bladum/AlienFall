--- Test Biome.lua
-- Tests for Biome class

local test_framework = require("test.framework.test_framework")
local Biome = require("src.geoscape.Biome")

local BiomeTest = {}

function BiomeTest.test_biome_creation()
    local data = {
        id = "urban",
        name = "Urban Center",
        type = "urban",
        properties = {
            population_density = 0.8,
            infrastructure_level = 0.9,
            alien_activity = 0.3
        },
        terrain = {
            primary = "concrete",
            secondary = "steel",
            features = {"buildings", "roads", "power_lines"}
        },
        economy = {
            base_value = 1000,
            resource_types = {"industrial", "commercial"},
            development_cost = 500
        }
    }

    local biome = Biome.new(data)

    test_framework.assert_equal(biome.id, "urban")
    test_framework.assert_equal(biome.type, "urban")
    test_framework.assert_equal(biome:getPopulationDensity(), 0.8)
    test_framework.assert_equal(biome:getInfrastructureLevel(), 0.9)
    test_framework.assert_equal(biome:getAlienActivity(), 0.3)
end

function BiomeTest.test_terrain_selection()
    local biome = Biome.new({
        id = "forest",
        terrain = {
            primary = "trees",
            secondary = "undergrowth",
            features = {"clearings", "streams", "rocks"}
        }
    })

    local terrain = biome:getTerrainComposition()
    test_framework.assert_equal(terrain.primary, "trees")
    test_framework.assert_equal(terrain.secondary, "undergrowth")
    test_framework.assert_equal(#terrain.features, 3)
end

function BiomeTest.test_economy_driven_variations()
    local biome = Biome.new({
        id = "industrial",
        economy = {
            base_value = 1000,
            resource_types = {"industrial", "mining"},
            development_cost = 500
        }
    })

    -- Test base economy
    local economy = biome:getEconomyData()
    test_framework.assert_equal(economy.base_value, 1000)
    test_framework.assert_equal(#economy.resource_types, 2)
    test_framework.assert_equal(economy.development_cost, 500)

    -- Test economy scaling with development
    local scaled = biome:getScaledEconomy(2.0)  -- Double development
    test_framework.assert_equal(scaled.base_value, 2000)
    test_framework.assert_equal(scaled.development_cost, 1000)
end

function BiomeTest.test_mission_filtering()
    local biome = Biome.new({
        id = "mountain",
        properties = {
            alien_activity = 0.7,
            accessibility = 0.4
        },
        mission_types = {
            "reconnaissance",
            "research",
            "combat"
        },
        restrictions = {
            max_difficulty = 8,
            required_tech = {"climbing_gear"}
        }
    })

    -- Test mission type availability
    test_framework.assert_true(biome:supportsMissionType("reconnaissance"))
    test_framework.assert_true(biome:supportsMissionType("research"))
    test_framework.assert_false(biome:supportsMissionType("infiltration"))

    -- Test difficulty restrictions
    test_framework.assert_true(biome:allowsDifficulty(5))
    test_framework.assert_false(biome:allowsDifficulty(10))

    -- Test tech requirements
    test_framework.assert_false(biome:meetsTechRequirements({}))
    test_framework.assert_true(biome:meetsTechRequirements({climbing_gear = true}))
end

function BiomeTest.test_environmental_effects()
    local biome = Biome.new({
        id = "arctic",
        properties = {
            temperature = -30,
            visibility = 0.6,
            movement_penalty = 0.8
        },
        effects = {
            weather_events = {"blizzard", "frostbite"},
            environmental_hazards = {"ice_cracks", "avalanches"}
        }
    })

    local effects = biome:getEnvironmentalEffects()
    test_framework.assert_equal(effects.temperature, -30)
    test_framework.assert_equal(effects.visibility, 0.6)
    test_framework.assert_equal(effects.movement_penalty, 0.8)
    test_framework.assert_equal(#effects.weather_events, 2)
    test_framework.assert_equal(#effects.environmental_hazards, 2)
end

function BiomeTest.test_biome_variation_generation()
    local biome = Biome:new({
        id = "desert",
        properties = {
            base_variation = 0.5,
            max_variation = 0.2
        }
    })

    -- Mock random seed for deterministic testing
    math.randomseed(12345)

    local variation1 = biome:generateVariation()
    local variation2 = biome:generateVariation()

    -- Variations should be different but within bounds
    test_framework.assert_true(variation1 >= 0.3 and variation1 <= 0.7)  -- base ± max
    test_framework.assert_true(variation2 >= 0.3 and variation2 <= 0.7)
    test_framework.assert_not_equal(variation1, variation2)
end

function BiomeTest.test_resource_generation()
    local biome = Biome:new({
        id = "mining",
        economy = {
            resource_types = {"minerals", "rare_earths"},
            base_yield = 100
        },
        properties = {
            resource_richness = 0.8
        }
    })

    local resources = biome:generateResources(1.0)  -- Normal development multiplier

    test_framework.assert_equal(resources.minerals, 80)  -- base_yield * richness
    test_framework.assert_equal(resources.rare_earths, 80)

    -- Test with development multiplier
    resources = biome:generateResources(2.0)
    test_framework.assert_equal(resources.minerals, 160)
    test_framework.assert_equal(resources.rare_earths, 160)
end

function BiomeTest.test_display_info()
    local biome = Biome.new({
        id = "swamp",
        name = "Toxic Swamp",
        type = "wetland",
        properties = {
            population_density = 0.1,
            infrastructure_level = 0.2,
            alien_activity = 0.9
        },
        terrain = {
            primary = "mud",
            secondary = "vegetation"
        },
        economy = {
            base_value = 200,
            resource_types = {"chemicals"}
        }
    })

    local info = biome:getDisplayInfo()

    test_framework.assert_equal(info.id, "swamp")
    test_framework.assert_equal(info.name, "Toxic Swamp")
    test_framework.assert_equal(info.type, "wetland")
    test_framework.assert_equal(info.population_density, 0.1)
    test_framework.assert_equal(info.infrastructure_level, 0.2)
    test_framework.assert_equal(info.alien_activity, 0.9)
    test_framework.assert_equal(info.terrain.primary, "mud")
    test_framework.assert_equal(info.economy.base_value, 200)
end

function BiomeTest.test_biome_comparison()
    local biome1 = Biome.new({
        id = "forest1",
        properties = {alien_activity = 0.5}
    })

    local biome2 = Biome.new({
        id = "forest2",
        properties = {alien_activity = 0.7}
    })

    -- Test activity comparison
    test_framework.assert_true(biome2:hasHigherAlienActivity(biome1))
    test_framework.assert_false(biome1:hasHigherAlienActivity(biome2))

    -- Test equality
    local biome3 = Biome.new({
        id = "forest1",
        properties = {alien_activity = 0.5}
    })

    test_framework.assert_true(biome1:equals(biome3))
    test_framework.assert_false(biome1:equals(biome2))
end

function BiomeTest.test_biome_events()
    local biome = Biome:new({
        id = "volcanic",
        properties = {
            instability = 0.6
        }
    })

    -- Mock event bus
    local events = {}
    biome.event_bus = {
        publish = function(event, data)
            table.insert(events, {event = event, data = data})
        end
    }

    biome:triggerEnvironmentalEvent("eruption")
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].event, "biome:environmental_event")
    test_framework.assert_equal(events[1].data.event_type, "eruption")
end

--- Run all Biome tests
function BiomeTest.run()
    test_framework.run_suite("Biome", {
        test_biome_creation = BiomeTest.test_biome_creation,
        test_terrain_selection = BiomeTest.test_terrain_selection,
        test_mission_compatibility = BiomeTest.test_mission_compatibility,
        test_environmental_effects = BiomeTest.test_environmental_effects,
        test_biome_variation_generation = BiomeTest.test_biome_variation_generation,
        test_resource_generation = BiomeTest.test_resource_generation,
        test_display_info = BiomeTest.test_display_info,
        test_biome_comparison = BiomeTest.test_biome_comparison,
        test_biome_events = BiomeTest.test_biome_events
    })
end

return BiomeTest