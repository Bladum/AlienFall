---TASK-025 Phase 2: World Generation Tests
---Comprehensive test suite for all world generation systems

local test_count = 0
local passed_count = 0
local failed_count = 0

-- Test utilities
local function assert_equal(actual, expected, message)
    test_count = test_count + 1
    if actual == expected then
        passed_count = passed_count + 1
        print(string.format("  ✓ Test %d: %s", test_count, message))
    else
        failed_count = failed_count + 1
        print(string.format("  ✗ Test %d: %s (expected %s, got %s)",
            test_count, message, tostring(expected), tostring(actual)))
    end
end

local function assert_true(value, message)
    test_count = test_count + 1
    if value then
        passed_count = passed_count + 1
        print(string.format("  ✓ Test %d: %s", test_count, message))
    else
        failed_count = failed_count + 1
        print(string.format("  ✗ Test %d: %s (expected true, got false)", test_count, message))
    end
end

local function assert_range(value, min, max, message)
    test_count = test_count + 1
    if value >= min and value <= max then
        passed_count = passed_count + 1
        print(string.format("  ✓ Test %d: %s", test_count, message))
    else
        failed_count = failed_count + 1
        print(string.format("  ✗ Test %d: %s (expected %.2f-%.2f, got %.2f)",
            test_count, message, min, max, value))
    end
end

local function assert_less_than(value, max, message)
    test_count = test_count + 1
    if value < max then
        passed_count = passed_count + 1
        print(string.format("  ✓ Test %d: %s (%.2f < %.2f)", test_count, message, value, max))
    else
        failed_count = failed_count + 1
        print(string.format("  ✗ Test %d: %s (%.2f >= %.2f)", test_count, message, value, max))
    end
end

print("\n" .. string.rep("=", 70))
print("TASK-025 PHASE 2: WORLD GENERATION TESTS")
print(string.rep("=", 70) .. "\n")

-- ============================================================================
-- WorldMap Tests
-- ============================================================================

print("[TEST SUITE] WorldMap Unit Tests\n")

local WorldMap = require("engine.geoscape.world.world_map")

-- Test 1: Create world
local world = WorldMap.new(80, 40)
assert_equal(world.width, 80, "WorldMap width initialized to 80")
assert_equal(world.height, 40, "WorldMap height initialized to 40")
assert_equal(#world.provinces, 3200, "WorldMap has 3200 provinces")

-- Test 2: Set and get province
local test_province = {
    x = 10, y = 5,
    biome = "desert",
    elevation = 0.5,
    population = 1000,
    region_id = 0,
    control = "neutral",
    resources = {},
    has_city = false,
}
world:setProvince(10, 5, test_province)
local retrieved = world:getProvince(10, 5)
if retrieved then
    assert_equal(retrieved.biome, "desert", "Province biome retrieved correctly")
    assert_equal(retrieved.population, 1000, "Province population retrieved correctly")
end

-- Test 3: Out of bounds handling
local oob = world:getProvince(-1, 0)
assert_equal(oob, nil, "Out of bounds returns nil")

-- Test 4: Neighbor queries
world:setProvince(9, 5, {x = 9, y = 5, biome = "forest", elevation = 0.4, population = 0, region_id = 0, control = "neutral", resources = {}, has_city = false})
world:setProvince(11, 5, {x = 11, y = 5, biome = "urban", elevation = 0.6, population = 0, region_id = 0, control = "neutral", resources = {}, has_city = false})
local neighbors = world:getNeighbors(10, 5, 1)
assert_true(#neighbors >= 2, "Neighbors query returns adjacent provinces")

-- Test 5: Distance calculation
local dist = world:getDistance({x = 0, y = 0}, {x = 3, y = 4})
assert_equal(dist, 7, "Manhattan distance calculated correctly")

-- ============================================================================
-- BiomeSystem Tests
-- ============================================================================

print("\n[TEST SUITE] BiomeSystem Unit Tests\n")

local BiomeSystem = require("engine.geoscape.world.biome_system")

local biome_system = BiomeSystem.new()

-- Test 6: Biome generation speed
local start = os.clock()
local biomes = biome_system:generateMap(80, 40, 12345)
local gen_time = (os.clock() - start) * 1000
assert_less_than(gen_time, 100, "Biome generation completes in <100ms")

-- Test 7: Biome distribution
local counts = {urban = 0, desert = 0, forest = 0, arctic = 0, water = 0}
for _, biome in ipairs(biomes) do
    counts[biome] = counts[biome] + 1
end
assert_true(counts.water > 0, "Water biome present in generated map")
assert_true(counts.urban > 0, "Urban biome present in generated map")

-- Test 8: Biome properties exist
local desert_props = biome_system:getProperties("desert")
assert_equal(desert_props.movement_cost, 1.5, "Desert movement cost is 1.5")
assert_true(not desert_props.can_place_city, "Desert cannot place cities")

-- Test 9: Deterministic generation (same seed = same result)
local biomes1 = biome_system:generateMap(80, 40, 99999)
local biomes2 = biome_system:generateMap(80, 40, 99999)
local same = true
for i = 1, #biomes1 do
    if biomes1[i] ~= biomes2[i] then
        same = false
        break
    end
end
assert_true(same, "Same seed produces identical biome maps")

-- Test 10: Different seed = different result
local biomes3 = biome_system:generateMap(80, 40, 88888)
local different = false
for i = 1, #biomes1 do
    if biomes1[i] ~= biomes3[i] then
        different = true
        break
    end
end
assert_true(different, "Different seed produces different biome maps")

-- ============================================================================
-- ProceduralGenerator Tests
-- ============================================================================

print("\n[TEST SUITE] ProceduralGenerator Integration Tests\n")

local ProceduralGenerator = require("engine.geoscape.world.procedural_generator")

-- Test 11: Generation completes
local generator = ProceduralGenerator.new(54321, "normal")
local start = os.clock()
local result = generator:generate(80, 40)
local total_time = (os.clock() - start) * 1000
assert_less_than(total_time, 150, "Full generation completes in <150ms")

-- Test 12: Generated world is valid
assert_true(result.world ~= nil, "Generation returns a world object")
assert_equal(result.world.width, 80, "Generated world has correct width")
assert_equal(result.world.height, 40, "Generated world has correct height")

-- Test 13: All provinces initialized
local province_count = 0
result.world:forEachProvince(function(x, y, province)
    province_count = province_count + 1
    assert_true(province.biome ~= nil, "Province has biome")
end)
assert_equal(province_count, 3200, "All 3200 provinces initialized")

-- Test 14: Resources distributed
local has_resources = false
result.world:forEachProvince(function(x, y, province)
    if province.resources and province.resources.mineral then
        has_resources = true
    end
end)
assert_true(has_resources, "Resources distributed to provinces")

-- Test 15: Alien bases generated
local base_count = #result.alien_bases
assert_true(base_count >= 2, "Alien bases generated for normal difficulty")

-- ============================================================================
-- LocationSystem Tests
-- ============================================================================

print("\n[TEST SUITE] LocationSystem Integration Tests\n")

local LocationSystem = require("engine.geoscape.world.location_system")

-- Test 16: Location system initialization
local locations = LocationSystem.new(result.world, 54321)
assert_true(locations ~= nil, "LocationSystem initializes successfully")

-- Test 17: Region generation
locations:generateLocations(18)
assert_true(#locations.regions > 0, "Regions generated")

-- Test 18: Cities placed
local city_count = 0
result.world:forEachProvince(function(x, y, province)
    city_count = city_count + (#province.cities or 0)
end)
assert_true(city_count > 0, "Cities placed on world")

-- Test 19: Capitals exist
local capital_count = 0
result.world:forEachProvince(function(x, y, province)
    for _, city in ipairs(province.cities or {}) do
        if city.is_capital then
            capital_count = capital_count + 1
        end
    end
end)
assert_true(capital_count >= 10, "Capitals placed (at least 10)")

-- Test 20: Regions have provinces
local province_assigned = false
result.world:forEachProvince(function(x, y, province)
    if province.region_id > 0 then
        province_assigned = true
    end
end)
assert_true(province_assigned, "Provinces assigned to regions")

-- ============================================================================
-- GeoMap Wrapper Tests
-- ============================================================================

print("\n[TEST SUITE] GeoMap Wrapper Integration Tests\n")

local GeoMap = require("engine.geoscape.world.geomap")

-- Test 21: GeoMap creation
local geomap = GeoMap.new(11111, "normal", 80, 40, 18)
assert_true(geomap ~= nil, "GeoMap creates successfully")
assert_true(geomap.world ~= nil, "GeoMap contains world")
assert_true(geomap.time ~= nil, "GeoMap contains time system")

-- Test 22: Time advancement
local start_turn = geomap.time.turn
geomap:advanceTurn()
assert_equal(geomap.time.turn, start_turn + 1, "Time advances by 1 turn")

print("\n" .. string.rep("=", 70))
print("TEST RESULTS")
print(string.rep("=", 70))
print(string.format("Total Tests: %d", test_count))
print(string.format("Passed: %d (%d%%)", passed_count,
    math.floor(passed_count / test_count * 100)))
print(string.format("Failed: %d", failed_count))

if failed_count == 0 then
    print("\n✓ ALL TESTS PASSED!")
    os.exit(0)
else
    print(string.format("\n✗ %d TESTS FAILED", failed_count))
    os.exit(1)
end
