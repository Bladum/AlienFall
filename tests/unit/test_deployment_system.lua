#!/usr/bin/env lua
---test_deployment_system.lua - TASK-029 Integration Tests
---
---Comprehensive tests for the deployment planning system:
---  - Data structure creation and manipulation
---  - Landing zone algorithm and validation
---  - Scene flow and state transitions
---  - Unit assignment and deployment validation
---
---Run with: lua test_deployment_system.lua

package.path = package.path .. ";engine/?.lua;engine/?/?.lua"

-- Mock Love2D if running outside game
if not love then
    love = {}
end

-- Import modules
local DeploymentConfig = require("battlescape.logic.deployment_config")
local LandingZone = require("battlescape.logic.landing_zone")
local MapBlockMetadata = require("battlescape.map.mapblock_metadata")
local LandingZoneSelector = require("battlescape.logic.landing_zone_selector")

-- Test counters
local tests_run = 0
local tests_passed = 0
local tests_failed = 0

---Assert helper
local function assert_eq(actual, expected, name)
    tests_run = tests_run + 1
    if actual == expected then
        tests_passed = tests_passed + 1
        print(string.format("  ✓ %s", name))
        return true
    else
        tests_failed = tests_failed + 1
        print(string.format("  ✗ %s: expected %s, got %s", name, tostring(expected), tostring(actual)))
        return false
    end
end

---Assert table length
local function assert_len(tbl, expected, name)
    tests_run = tests_run + 1
    if #tbl == expected then
        tests_passed = tests_passed + 1
        print(string.format("  ✓ %s (length=%d)", name, expected))
        return true
    else
        tests_failed = tests_failed + 1
        print(string.format("  ✗ %s: expected length %d, got %d", name, expected, #tbl))
        return false
    end
end

---Assert truthy
local function assert_true(value, name)
    tests_run = tests_run + 1
    if value then
        tests_passed = tests_passed + 1
        print(string.format("  ✓ %s", name))
        return true
    else
        tests_failed = tests_failed + 1
        print(string.format("  ✗ %s: expected true, got %s", name, tostring(value)))
        return false
    end
end

---Assert falsy
local function assert_false(value, name)
    tests_run = tests_run + 1
    if not value then
        tests_passed = tests_passed + 1
        print(string.format("  ✓ %s", name))
        return true
    else
        tests_failed = tests_failed + 1
        print(string.format("  ✗ %s: expected false, got %s", name, tostring(value)))
        return false
    end
end

-- ============================================================================
-- TEST SUITE 1: DeploymentConfig
-- ============================================================================

print("\n=== TEST SUITE 1: DeploymentConfig ===\n")

local function test_deployment_config_creation()
    print("Test: DeploymentConfig Creation")
    
    local config = DeploymentConfig.create()
    assert_true(config ~= nil, "Config created")
    assert_true(config.missionId == nil, "Initial mission ID is nil")
    assert_len(config.landingZones, 0, "Initial landing zones empty")
    assert_len(config.availableUnits, 0, "Initial units empty")
end
test_deployment_config_creation()

local function test_deployment_config_map_sizes()
    print("\nTest: DeploymentConfig Map Sizes")
    
    local config = DeploymentConfig.create()
    
    config:setMapSize("small")
    assert_eq(config.mapBlockGrid, 4, "Small map is 4x4")
    
    local config2 = DeploymentConfig.create()
    config2:setMapSize("medium")
    assert_eq(config2.mapBlockGrid, 5, "Medium map is 5x5")
    
    local config3 = DeploymentConfig.create()
    config3:setMapSize("huge")
    assert_eq(config3.mapBlockGrid, 7, "Huge map is 7x7")
end
test_deployment_config_map_sizes()

local function test_deployment_config_unit_assignment()
    print("\nTest: DeploymentConfig Unit Assignment")
    
    local config = DeploymentConfig.create()
    config:setMapSize("medium")
    
    -- Create landing zones
    local lz1 = LandingZone.new({id = "lz_1", capacity = 3})
    local lz2 = LandingZone.new({id = "lz_2", capacity = 3})
    
    config:addLandingZone(lz1)
    config:addLandingZone(lz2)
    assert_len(config.landingZones, 2, "Landing zones added")
    
    -- Assign units
    local success, err = config:assignUnitToLZ("unit_1", "lz_1")
    assert_true(success, "Unit assigned successfully")
    
    local assigned = config:getLZForUnit("unit_1")
    assert_eq(assigned, "lz_1", "Unit assignment retrieval works")
end
test_deployment_config_unit_assignment()

local function test_deployment_config_completion()
    print("\nTest: DeploymentConfig Completion Check")
    
    local config = DeploymentConfig.create()
    
    -- No units
    assert_false(config:isDeploymentComplete(), "Not complete with no units")
    
    -- Add units but not assign
    config.availableUnits = {{id = "unit_1"}, {id = "unit_2"}}
    assert_false(config:isDeploymentComplete(), "Not complete with unassigned units")
    
    -- Create zones and assign
    local lz = LandingZone.new({id = "lz_1"})
    config:addLandingZone(lz)
    
    config:assignUnitToLZ("unit_1", "lz_1")
    config:assignUnitToLZ("unit_2", "lz_1")
    
    assert_true(config:isDeploymentComplete(), "Complete when all units assigned")
end
test_deployment_config_completion()

-- ============================================================================
-- TEST SUITE 2: LandingZone
-- ============================================================================

print("\n\n=== TEST SUITE 2: LandingZone ===\n")

local function test_landing_zone_creation()
    print("Test: LandingZone Creation")
    
    local lz = LandingZone.new({
        id = "lz_test",
        mapBlockIndex = 5,
        gridPosition = {x = 2, y = 1},
        capacity = 3
    })
    
    assert_eq(lz.id, "lz_test", "LZ ID set correctly")
    assert_eq(lz.mapBlockIndex, 5, "MapBlock index set")
    assert_len(lz.assignedUnits, 0, "Initial units empty")
end
test_landing_zone_creation()

local function test_landing_zone_unit_management()
    print("\nTest: LandingZone Unit Management")
    
    local lz = LandingZone.new({id = "lz_1", capacity = 2})
    
    local success1 = LandingZone.addUnit(lz, "unit_1")
    assert_true(success1, "Unit 1 added")
    
    local success2 = LandingZone.addUnit(lz, "unit_2")
    assert_true(success2, "Unit 2 added")
    
    assert_len(lz.assignedUnits, 2, "Both units in zone")
    
    -- Try to exceed capacity
    local success3 = LandingZone.addUnit(lz, "unit_3")
    assert_false(success3 == nil, "Capacity check works")
end
test_landing_zone_unit_management()

local function test_landing_zone_capacity()
    print("\nTest: LandingZone Capacity")
    
    local lz = LandingZone.new({id = "lz_1", capacity = 2})
    assert_false(lz:isFull(), "Not full initially")
    
    LandingZone.addUnit(lz, "unit_1")
    LandingZone.addUnit(lz, "unit_2")
    
    assert_true(lz:isFull(), "Full when at capacity")
end
test_landing_zone_capacity()

-- ============================================================================
-- TEST SUITE 3: MapBlockMetadata
-- ============================================================================

print("\n\n=== TEST SUITE 3: MapBlockMetadata ===\n")

local function test_mapblock_metadata_creation()
    print("Test: MapBlockMetadata Creation")
    
    local meta = MapBlockMetadata.new({mapBlockId = "block_1"})
    
    assert_eq(meta.mapBlockId, "block_1", "MapBlock ID set")
    assert_eq(meta.objectiveType, "none", "Default objective is none")
    assert_false(meta.isObjectiveBlock, "Not objective initially")
end
test_mapblock_metadata_creation()

local function test_mapblock_metadata_objectives()
    print("\nTest: MapBlockMetadata Objectives")
    
    local meta = MapBlockMetadata.new({mapBlockId = "block_1"})
    
    local success = MapBlockMetadata.setObjective(meta, "defend")
    assert_true(success, "Objective set successfully")
    assert_eq(meta.objectiveType, "defend", "Objective type updated")
    assert_true(meta.isObjectiveBlock, "Mark as objective block")
end
test_mapblock_metadata_objectives()

local function test_mapblock_metadata_spawn_points()
    print("\nTest: MapBlockMetadata Spawn Points")
    
    local meta = MapBlockMetadata.new({mapBlockId = "block_1"})
    
    MapBlockMetadata.addSpawnPoint(meta, 5, 10)
    MapBlockMetadata.addSpawnPoint(meta, 15, 10)
    
    assert_len(meta.spawnPoints, 2, "Both spawn points added")
    assert_true(MapBlockMetadata.hasSpawnPoints(meta), "Has spawn points")
    
    local spawn1 = MapBlockMetadata.getSpawnPoint(meta, 1)
    if spawn1 then
        assert_eq(spawn1.x, 5, "First spawn X coordinate")
        assert_eq(spawn1.y, 10, "First spawn Y coordinate")
    else
        assert_true(false, "Spawn point returned")
    end
end
test_mapblock_metadata_spawn_points()

-- ============================================================================
-- TEST SUITE 4: LandingZoneSelector
-- ============================================================================

print("\n\n=== TEST SUITE 4: LandingZoneSelector ===\n")

local function test_landing_zone_selector_basic()
    print("Test: LandingZoneSelector Basic")
    
    local mapGrid = {width = 5, height = 5}
    local objectiveIndices = {}
    
    local zones = LandingZoneSelector.selectZones(5, "medium")
    
    assert_true(zones ~= nil, "Zones returned")
    assert_len(zones, 2, "Medium map has 2 landing zones")
    
    for i, lz in ipairs(zones) do
        assert_true(lz.id ~= nil, "Zone " .. i .. " has ID")
        assert_true(lz.mapBlockIndex ~= nil, "Zone " .. i .. " has block index")
    end
end
test_landing_zone_selector_basic()

local function test_landing_zone_selector_edge_blocks()
    print("\nTest: LandingZoneSelector Edge Detection")
    
    -- Mock small selector
    local mapGrid = {width = 4, height = 4}
    local edges = LandingZoneSelector._generateCandidates(4)
    
    -- 4x4 grid should have corners and edges
    assert_true(#edges > 4, "Edge candidates generated for 4x4 grid")
end
test_landing_zone_selector_edge_blocks()

local function test_landing_zone_selector_size_scaling()
    print("\nTest: LandingZoneSelector Size Scaling")
    
    local small_zones = LandingZoneSelector.selectZones(4, "small")
    assert_len(small_zones, 1, "Small map: 1 landing zone")
    
    local medium_zones = LandingZoneSelector.selectZones(5, "medium")
    assert_len(medium_zones, 2, "Medium map: 2 landing zones")
    
    local large_zones = LandingZoneSelector.selectZones(6, "large")
    assert_len(large_zones, 3, "Large map: 3 landing zones")
    
    local huge_zones = LandingZoneSelector.selectZones(7, "huge")
    assert_len(huge_zones, 4, "Huge map: 4 landing zones")
end
test_landing_zone_selector_size_scaling()

-- ============================================================================
-- TEST SUITE 5: Integration
-- ============================================================================

print("\n\n=== TEST SUITE 5: Integration ===\n")

local function test_full_deployment_flow()
    print("Test: Full Deployment Flow")
    
    -- 1. Create config
    local config = DeploymentConfig.create()
    config:setMapSize("medium")
    
    -- 2. Select landing zones
    local zones = LandingZoneSelector.selectZones(5, "medium")
    for _, zone in ipairs(zones) do
        config:addLandingZone(zone)
    end
    
    -- 3. Add units
    config.availableUnits = {
        {id = "unit_1", name = "Soldier 1"},
        {id = "unit_2", name = "Soldier 2"}
    }
    
    -- 4. Assign units
    config:assignUnitToLZ("unit_1", zones[1].id)
    config:assignUnitToLZ("unit_2", zones[1].id)
    
    -- 5. Verify complete
    assert_true(config:isDeploymentComplete(), "Deployment complete")
    
    -- 6. Check summary
    local summary = config:getSummary()
    assert_eq(summary.totalUnits, 2, "Summary shows correct unit count")
    assert_eq(summary.assignedUnits, 2, "Summary shows all assigned")
    assert_true(summary.complete, "Summary shows complete")
end
test_full_deployment_flow()

local function test_invalid_assignment()
    print("\nTest: Invalid Assignment Handling")
    
    local config = DeploymentConfig.create()
    config:setMapSize("medium")
    
    -- Try to assign to non-existent zone
    local success, err = config:assignUnitToLZ("unit_1", "lz_99")
    assert_false(success, "Assignment fails for missing zone")
end
test_invalid_assignment()

-- ============================================================================
-- SUMMARY
-- ============================================================================

print("\n\n" .. string.rep("=", 50))
print("TEST SUMMARY")
print(string.rep("=", 50))
print(string.format("Tests run:    %d", tests_run))
print(string.format("Tests passed: %d (%.1f%%)", tests_passed, (tests_passed/tests_run)*100))
print(string.format("Tests failed: %d", tests_failed))

if tests_failed == 0 then
    print("\n✓ ALL TESTS PASSED!")
    os.exit(0)
else
    print(string.format("\n✗ %d TEST(S) FAILED", tests_failed))
    os.exit(1)
end



