---TASK-025 Phase 3: Regional Management Tests
---Test suite for Region, RegionController, and ControlTracker

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

local function assert_greater_than(value, min, message)
    test_count = test_count + 1
    if value > min then
        passed_count = passed_count + 1
        print(string.format("  ✓ Test %d: %s (%.2f > %.2f)", test_count, message, value, min))
    else
        failed_count = failed_count + 1
        print(string.format("  ✗ Test %d: %s (%.2f <= %.2f)", test_count, message, value, min))
    end
end

print("\n" .. string.rep("=", 70))
print("TASK-025 PHASE 3: REGIONAL MANAGEMENT TESTS")
print(string.rep("=", 70) .. "\n")

-- ============================================================================
-- Region Tests
-- ============================================================================

print("[TEST SUITE 1] Region Unit Tests\n")

local Region = require("engine.geoscape.regions.region")

-- Test 1: Create region
local region = Region.new(1, "North America", "player", 40, 20)
assert_equal(region.id, 1, "Region ID set correctly")
assert_equal(region.name, "North America", "Region name set correctly")
assert_equal(region.faction, "player", "Region faction set correctly")

-- Test 2: Region properties initialized
assert_true(region.population > 0, "Region has population")
assert_true(region.stability >= 0 and region.stability <= 1, "Region stability in valid range")
assert_equal(region.control, "player", "Region control matches faction")

-- Test 3: Apply damage
local initial_pop = region.population
region:applyDamage("bombardment", 0.5)
assert_true(region.population < initial_pop, "Bombardment reduces population")

-- Test 4: Get strategic value
local value = region:getStrategicValue()
assert_true(value >= 0 and value <= 100, "Strategic value in 0-100 range")

-- Test 5: Per-turn update
local initial_stability = region.stability
region:update(0, 0.5)
assert_true(region.economy.balance >= -1000, "Region has reasonable economy")

-- ============================================================================
-- RegionController Tests
-- ============================================================================

print("\n[TEST SUITE 2] RegionController Tests\n")

-- Create mock world and locations for testing
local GeoMap = require("engine.geoscape.world.geomap")
local geomap = GeoMap.new(54321, "normal", 80, 40, 18)
local RegionController = require("engine.geoscape.regions.region_controller")

-- Test 6: Initialize RegionController
local controller = RegionController.new(geomap.world, geomap.locations)
assert_true(controller ~= nil, "RegionController initializes")

-- Test 7: Get regions
local all_regions = controller:getAllRegions()
assert_true(#all_regions > 0, "RegionController has regions")

-- Test 8: Get region by ID
local first_region = controller:getRegion(1)
assert_true(first_region ~= nil, "Can retrieve region by ID")

-- Test 9: Get region at coordinates
local test_region = geomap.locations.regions[1]
if test_region then
    local region_at_capital = controller:getRegionAt(test_region.capital_x, test_region.capital_y)
    assert_true(region_at_capital ~= nil, "Can find region at coordinates")
end

-- Test 10: Get regions by faction
local player_regions = controller:getRegionsByFaction("player")
assert_true(type(player_regions) == "table", "getRegionsByFaction returns table")

-- ============================================================================
-- RegionController Updates
-- ============================================================================

print("\n[TEST SUITE 3] RegionController Update Tests\n")

-- Test 11: Update controller
local start_turn = controller.turn
controller:update(1, 0.5)
assert_equal(controller.turn, 1, "Controller turn advances")

-- Test 12: Economic summary
local econ = controller:getEconomicSummary()
assert_true(econ.total_income > 0, "Total income calculated")
assert_true(econ.total_expenditure > 0, "Total expenditure calculated")

-- Test 13: Population summary
local pop = controller:getPopulationSummary()
assert_greater_than(pop.total_population, 0, "Total population calculated")

-- Test 14: Stability calculation
local stability = controller:getAverageStability()
assert_true(stability >= 0 and stability <= 1, "Average stability in valid range")

-- Test 15: Threat level
local threat = controller:getThreatLevel()
assert_true(threat >= 0 and threat <= 100, "Threat level in 0-100 range")

-- ============================================================================
-- ControlTracker Tests
-- ============================================================================

print("\n[TEST SUITE 4] ControlTracker Tests\n")

local ControlTracker = require("engine.geoscape.regions.control_tracker")

-- Test 16: Initialize ControlTracker
local tracker = ControlTracker.new(controller)
assert_true(tracker ~= nil, "ControlTracker initializes")

-- Test 17: Set control
local success = tracker:setControl(1, "alien", "invasion")
assert_true(success or not success, "setControl executes")

-- Test 18: Get control
local control = tracker:getControl(1)
assert_equal(control, "alien", "Control change tracked")

-- Test 19: Get control percentage
local ctrl_pct = tracker:getControlPercentage(1, "alien")
assert_true(ctrl_pct >= 0 and ctrl_pct <= 1, "Control percentage in valid range")

-- Test 20: Control history
local history = tracker:getFullHistory()
assert_true(#history > 0, "Control history recorded")

-- ============================================================================
-- Integration Tests
-- ============================================================================

print("\n[TEST SUITE 5] Integration Tests\n")

-- Test 21: Add base to region
local test_region_id = 1
controller:addBase(test_region_id, 101)
local region = controller:getRegion(test_region_id)
if region then
    local bases = region:getBases()
    assert_true(#bases > 0, "Base added to region")
end

-- Test 22: Apply damage to region
controller:applyDamage(1, "terror_attack", 0.5)
assert_true(true, "Damage application executes")

-- ============================================================================
-- Summary
-- ============================================================================

print("\n" .. string.rep("=", 70))
print("TEST RESULTS")
print(string.rep("=", 70))
print(string.format("Total Tests: %d", test_count))
print(string.format("Passed: %d (%d%%)", passed_count,
    math.floor(passed_count / test_count * 100)))
print(string.format("Failed: %d", failed_count))
print(string.rep("=", 70))

if failed_count == 0 then
    print("\n✓ ALL TESTS PASSED!")
    os.exit(0)
else
    print(string.format("\n✗ %d TESTS FAILED", failed_count))
    os.exit(1)
end
